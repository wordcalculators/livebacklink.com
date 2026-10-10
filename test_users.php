<?php
$host = 'localhost';
$db = 'xsdipen_livebacklink';
$user = 'xsdipen_livebacklinkcom';
$pass = 'UBdM+!g&v$L#vXDG';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$db", $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $stmt = $pdo->query("SELECT * FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($users);
} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
