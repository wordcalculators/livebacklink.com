<?php
$dbPath = __DIR__ . '/backend/writable/database.db';
$schemaFile = __DIR__ . '/backend/database/schema-sqlite.sql';

if (!extension_loaded('pdo_sqlite') || !extension_loaded('sqlite3')) {
    echo "<div style='color:red; font-family: sans-serif; padding: 20px; text-align: center;'>
          <h2>❌ SQLite Extension is Disabled</h2>
          <p>Your Namecheap server has the SQLite extension disabled.</p>
          <p><b>How to fix this:</b><br>
          1. Go to cPanel -> Select PHP Version.<br>
          2. Check the boxes next to <b>pdo_sqlite</b> and <b>sqlite3</b>.<br>
          3. Reload this page.</p>
          </div>";
    exit;
}

try {
    $pdo = new PDO('sqlite:' . $dbPath, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    
    if (file_exists($schemaFile)) {
        $sql = file_get_contents($schemaFile);
        $statements = explode(';', $sql);
        foreach ($statements as $statement) {
            $stmt = trim($statement);
            if (!empty($stmt) && strpos($stmt, '--') !== 0) {
                $stmt = preg_replace('/--.*$/m', '', $stmt);
                if(trim($stmt) !== '') {
                    $pdo->exec($stmt);
                }
            }
        }
        
        // Guarantee Admin User
        $pdo->exec("DELETE FROM users WHERE email='admin@livebacklink.com'");
        $adminPassHash = password_hash('admin1234', PASSWORD_BCRYPT);
        $pdo->exec("INSERT INTO users (name, email, password_hash, role, status, email_verified) VALUES ('Admin', 'admin@livebacklink.com', '$adminPassHash', 'admin', 'active', 1)");
        
        echo "<div style='color:green; font-family: sans-serif; padding: 30px; text-align: center; margin-top: 50px;'>
            <h1>🎉 SUCCESS! AUTO-SETUP COMPLETE!</h1>
            <p>Your Database is now fully connected and working automatically.</p>
            <p>You can now log in to the admin panel!</p>
            <div style='background: #f4f4f4; padding: 15px; display: inline-block; border-radius: 8px; margin-top: 20px;'>
                <b>Admin URL:</b> <a href='https://livebacklink.com/admin'>https://livebacklink.com/admin</a><br><br>
                <b>Email:</b> admin@livebacklink.com<br>
                <b>Password:</b> admin1234
            </div>
            <br><br><br>
            <small style='color: red;'>Note: You can delete this db_install.php file now for security.</small>
        </div>";
        
    } else {
        echo "<div style='color:red;'>Schema file missing.</div>";
    }
} catch (Exception $e) {
    echo "<div style='color:red; font-family: sans-serif; padding: 20px;'>
          <h2>❌ Setup Error:</h2><p>" . htmlspecialchars($e->getMessage()) . "</p>
          <p>Please make sure the backend/writable folder has 755 or 777 permissions.</p>
          </div>";
}
