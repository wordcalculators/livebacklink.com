<?php
/**
 * PostgreSQL Schema Auto-Installer
 */
$dsn = "pgsql:host=localhost;port=5432;dbname=xsdipen_livebacklink;";
$user = "xsdipen_livebacklinkcom";
$password = "UBdM+!g&v\$L#vXDG";

try {
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    
    // Import schema
    $schemaFile = __DIR__ . '/backend/database/schema.sql';
    if (!file_exists($schemaFile)) {
        $schemaFile = __DIR__ . '/database-schema.sql';
    }
    
    if (file_exists($schemaFile)) {
        $sql = file_get_contents($schemaFile);
        $pdo->exec($sql);
        
        // Seed Admin User
        $pdo->exec("DELETE FROM users WHERE email='admin@livebacklink.com'");
        $adminPassHash = password_hash('admin1234', PASSWORD_BCRYPT);
        $pdo->exec("INSERT INTO users (name, email, password_hash, role, status, email_verified) VALUES ('Admin', 'admin@livebacklink.com', '$adminPassHash', 'admin', 'active', 1)");
        
        echo "<div style='color:green; padding:30px; font-family:sans-serif; text-align:center;'>
                <h1>🎉 POSTGRESQL SUCCESS!</h1>
                <p>The database schema has been imported automatically!</p>
                <p>You can now login at <a href='https://livebacklink.com/admin'>https://livebacklink.com/admin</a></p>
              </div>";
    } else {
        echo "Error: Schema file not found.";
    }
} catch (PDOException $e) {
    echo "<div style='color:red; padding:30px; font-family:sans-serif;'>
            <h1>❌ POSTGRESQL ERROR</h1>
            <p>" . htmlspecialchars($e->getMessage()) . "</p>
          </div>";
}
