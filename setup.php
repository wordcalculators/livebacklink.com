<?php

declare(strict_types=1);

header('Content-Type: text/html; charset=utf-8');

$root = __DIR__;
$envFile = $root . '/backend/.env';
$schemaFile = $root . '/database-schema.sql';
$lockFile = $root . '/backend/writable/.setup_complete';

function page(string $title, string $message, bool $success = false): never
{
    $color = $success ? '#166534' : '#991B1B';
    $background = $success ? '#F0FDF4' : '#FEF2F2';
    echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>' . htmlspecialchars($title) . '</title><style>body{font-family:Arial,sans-serif;background:#F8FAFC;color:#0F172A;padding:40px}.box{max-width:720px;margin:40px auto;background:white;border:1px solid #E2E8F0;border-radius:12px;padding:28px;box-shadow:0 8px 24px #00000012}h1{font-size:22px}p{line-height:1.6}.status{color:' . $color . ';background:' . $background . ';border:1px solid ' . $color . '33;padding:14px;border-radius:8px}code{background:#F1F5F9;padding:2px 5px;border-radius:4px}</style></head><body><main class="box"><h1>' . htmlspecialchars($title) . '</h1><div class="status">' . $message . '</div></main></body></html>';
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    page('Invalid request', 'Open this setup URL with a normal browser request.');
}

if (is_file($lockFile)) {
    page('Setup already completed', 'The installer is locked because this application has already been initialized. Delete <code>setup.php</code> from the hosting account after confirming the site works.', true);
}

if (!is_file($envFile) || !is_file($schemaFile)) {
    page('Setup files missing', 'The server package is incomplete. Confirm that <code>backend/.env</code> and <code>database-schema.sql</code> exist.');
}

$settings = [];
foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
    $line = trim($line);
    if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) {
        continue;
    }
    [$key, $value] = array_map('trim', explode('=', $line, 2));
    $settings[$key] = trim($value, " \t\n\r\0\x0B'\"");
}

$host = $settings['database.default.hostname'] ?? '';
$database = $settings['database.default.database'] ?? '';
$username = $settings['database.default.username'] ?? '';
$password = $settings['database.default.password'] ?? '';
$port = (int)($settings['database.default.port'] ?? 3306);

if ($host === '' || $database === '' || $username === '') {
    page('Database configuration missing', 'Complete the database settings in <code>backend/.env</code> before opening this URL.');
}

mysqli_report(MYSQLI_REPORT_OFF);
$db = @new mysqli($host, $username, $password, $database, $port);
if ($db->connect_errno) {
    page('Database connection failed', 'The configured database could not be reached. Check the database name, username, password, host, port, and cPanel privileges.');
}

$db->set_charset('utf8mb4');
$usersTable = $db->query("SHOW TABLES LIKE 'users'");
$tableExists = $usersTable instanceof mysqli_result && $usersTable->num_rows > 0;

if (!$tableExists) {
    $schema = file_get_contents($schemaFile);
    if ($schema === false || !$db->multi_query($schema)) {
        $error = htmlspecialchars($db->error ?: 'Unknown schema installation error.');
        $db->close();
        page('Database setup failed', $error);
    }

    do {
        $result = $db->store_result();
        if ($result instanceof mysqli_result) {
            $result->free();
        }
    } while ($db->more_results() && $db->next_result());

    if ($db->errno) {
        $error = htmlspecialchars($db->error);
        $db->close();
        page('Database setup failed', $error);
    }
}

$adminEmail = 'admin@livebacklink.com';
$adminPasswordHash = password_hash('admin1234', PASSWORD_BCRYPT);
$adminName = 'Dipen Bishwas';
$adminCompany = 'LiveBacklink Inc.';
$stmt = $db->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $adminEmail);
$stmt->execute();
$stmt->store_result();
$adminExists = $stmt->num_rows > 0;
$stmt->close();

if (!$adminExists) {
    $stmt = $db->prepare("INSERT INTO users (name, email, password_hash, role, status, email_verified, company, created_at, updated_at) VALUES (?, ?, ?, 'admin', 'active', 1, ?, NOW(), NOW())");
    $stmt->bind_param('ssss', $adminName, $adminEmail, $adminPasswordHash, $adminCompany);
    if (!$stmt->execute()) {
        $error = htmlspecialchars($stmt->error);
        $stmt->close();
        $db->close();
        page('Administrator setup failed', $error);
    }
    $stmt->close();
}

$db->close();

$writable = dirname($lockFile);
if (!is_dir($writable)) {
    @mkdir($writable, 0755, true);
}
@file_put_contents($lockFile, 'Setup completed at ' . date('c'));

page('Setup completed successfully', 'Database initialization is complete.<br><br><strong>Admin URL:</strong> <code>/admin</code><br><strong>Email:</strong> <code>admin@livebacklink.com</code><br><strong>Password:</strong> <code>admin1234</code><br><br>Delete <code>setup.php</code> from the hosting account now, then open the admin URL.', true);
