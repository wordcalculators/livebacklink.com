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
        await client.downloadTo("ci_log.txt", "backend/writable/logs/log-2026-10-10.log");
        console.log("Downloaded log!");
    } catch(err) {
        console.error(err);
    }
    client.close();
}
run();
