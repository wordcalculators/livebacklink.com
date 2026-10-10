<?php
$host = 'localhost';
$db = 'xsdipen_livebacklink';
$user = 'xsdipen_livebacklinkcom';
$pass = 'UBdM+!g&v$L#vXDG';
try {
    $pdo = new PDO("pgsql:host=$host;dbname=$db", $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $pdo->exec("DELETE FROM login_logs");
    echo "Logs cleared.\n";
} catch(Exception $e) { echo $e->getMessage(); }
