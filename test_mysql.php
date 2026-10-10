<?php
$host = 'localhost';
$db = 'xsdipen_livebacklink';
$user = 'xsdipen_livebacklinkcom';
$pass = 'UBdM+!g&v$L#vXDG';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8", $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    echo "Connected to MySQL successfully.\n";
    $stmt = $pdo->query("SHOW TABLES");
    echo "Tables count: " . $stmt->rowCount() . "\n";
} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
