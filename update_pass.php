<?php
$host = 'localhost';
$db = 'xsdipen_livebacklink';
$user = 'xsdipen_livebacklinkcom';
$pass = 'UBdM+!g&v$L#vXDG';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$db", $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $newHash = password_hash('admin1234', PASSWORD_BCRYPT);
    $pdo->exec("UPDATE users SET password_hash = '$newHash' WHERE email = 'admin@livebacklink.com'");
    echo "Password updated successfully!\n";
} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
