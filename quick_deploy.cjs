const ftp = require('basic-ftp');

async function deploy() {
    const client = new ftp.Client();
    client.ftp.verbose = true;
    try {
        await client.access({
            host: "premium172.web-hosting.com",
            user: "livebacklink@livebacklink.com",
            password: "LuT5=2u-%;J7M=2D",
            secure: false
        });
        
        console.log("✅ Connected securely!");
        
        // Upload dist/ files directly to root
        await client.uploadFromDir("dist");
        console.log("✅ Uploaded frontend dist");

        // Upload backend/.env and Database.php
        await client.uploadFrom("backend/.env", "backend/.env");
        await client.uploadFrom("backend/app/Config/Database.php", "backend/app/Config/Database.php");
        await client.uploadFrom("backend/app/Config/Filters.php", "backend/app/Config/Filters.php");
        console.log("✅ Uploaded database config");

        // Upload run_schema.php and .htaccess
        await client.uploadFrom(".htaccess", ".htaccess");
        await client.uploadFrom("run_schema.php", "run_schema.php");
        await client.uploadFrom("check_db.php", "check_db.php");
        console.log("✅ Uploaded run_schema.php and .htaccess");

    }
    catch(err) {
        console.log("❌ FTP DEPLOYMENT ERROR:");
        console.log(err);
    }
    client.close();
}

deploy();
