<?php
header('Content-Type: application/json');
$env = [];
foreach (file(__DIR__ . '/backend/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
    $line = trim($line);
    if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) continue;
    [$key, $value] = array_map('trim', explode('=', $line, 2));
    $env[$key] = trim($value, " \t\n\r\0\x0B'\"");
}
$host = $env['database.default.hostname'] ?? '';
$database = $env['database.default.database'] ?? '';
$username = $env['database.default.username'] ?? '';
$port = (int)($env['database.default.port'] ?? 3306);
$result = [
    'php' => PHP_VERSION,
    'mysqli' => extension_loaded('mysqli'),
    'host' => $host,
    'database' => $database,
    'username' => $username,
    'port' => $port,
];
if (!extension_loaded('mysqli')) {
    $result['error'] = 'mysqli extension is not enabled';
    http_response_code(503);
    echo json_encode($result);
    exit;
}
mysqli_report(MYSQLI_REPORT_OFF);
$db = @new mysqli($host, $username, $env['database.default.password'] ?? '', $database, $port);
$result['connected'] = !$db->connect_errno;
if ($db->connect_errno) {
    $result['error_code'] = $db->connect_errno;
    $result['error'] = $db->connect_error;
    http_response_code(503);
} else {
    $result['query'] = $db->query('SELECT 1') ? 'ok' : $db->error;
    $db->close();
}
echo json_encode($result);
