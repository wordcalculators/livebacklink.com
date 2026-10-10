const ftp = require('basic-ftp');
async function run() {
    const client = new ftp.Client();
    try {
        await client.access({
            host: "premium172.web-hosting.com",
            user: "livebacklink@livebacklink.com",
            password: "LuT5=2u-%;J7M=2D",
            secure: false
        });
        await client.uploadFrom("backend/app/Controllers/Admin.php", "backend/app/Controllers/Admin.php");
        console.log("Uploaded Admin.php!");
    } catch(err) {
        console.error(err);
    }
    client.close();
}
run();
