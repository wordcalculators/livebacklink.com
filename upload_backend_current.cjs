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
    await client.uploadFromDir('backend', 'backend');
    console.log('Uploaded current backend.');
  } finally {
    client.close();
  }
}

run().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
