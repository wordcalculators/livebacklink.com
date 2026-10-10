<?php
$host = 'localhost';
$db = 'xsdipen_livebacklink';
$user = 'xsdipen_livebacklinkcom';
$pass = 'UBdM+!g&v$L#vXDG';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$db", $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    echo "Connected to PostgreSQL successfully.\n";
    $stmt = $pdo->query("SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'");
    echo "Tables count: " . $stmt->fetchColumn() . "\n";
} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
