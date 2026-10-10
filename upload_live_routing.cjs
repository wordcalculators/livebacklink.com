const ftp = require('basic-ftp');

async function run() {
  const client = new ftp.Client();
  try {
    await client.access({
      host: 'premium172.web-hosting.com',
      user: 'livebacklink@livebacklink.com',
      password: 'LuT5=2u-%;J7M=2D',
      secure: false,
    });
    await client.uploadFrom('backend/app/Controllers/PublicController.php', 'backend/app/Controllers/PublicController.php');
    await client.uploadFrom('.htaccess', '.htaccess');
    await client.uploadFrom('debug_db.php', 'debug_db.php');
    console.log('Uploaded health controller and root routing rules.');
  } finally {
    client.close();
  }
}

run().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
