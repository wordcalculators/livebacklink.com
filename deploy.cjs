const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const ftp = require('basic-ftp');

console.log('📦 1. Building React Frontend (npm run build)...');
try {
    execSync('npm run build', { stdio: 'inherit' });
} catch (error) {
    console.error('❌ Build failed!');
    process.exit(1);
}

console.log('\n📂 2. Preparing deployment folder...');
try {
    execSync('rm -rf LIVEBACKLINK_DEPLOY', { stdio: 'ignore' });
    execSync('mkdir -p LIVEBACKLINK_DEPLOY', { stdio: 'ignore' });
    
    execSync('cp -r dist/* LIVEBACKLINK_DEPLOY/');
    execSync('cp .htaccess LIVEBACKLINK_DEPLOY/');
    execSync('cp -r backend LIVEBACKLINK_DEPLOY/');
    execSync('cp database-schema.sql LIVEBACKLINK_DEPLOY/');
    execSync('cp db_install.php LIVEBACKLINK_DEPLOY/');
    
    console.log('✅ Deployment folder prepared successfully.');
} catch (error) {
    console.error('❌ Failed to prepare deployment folder.', error.message);
    process.exit(1);
}

console.log('\n🚀 3. Uploading to Namecheap Server via FTP...');

const ftpHost = process.env.LIVEBACKLINK_FTP_HOST;
const ftpUser = process.env.LIVEBACKLINK_FTP_USER;
const ftpPassword = process.env.LIVEBACKLINK_FTP_PASSWORD;

if (!ftpHost || !ftpUser || !ftpPassword) {
    console.error('❌ Missing LIVEBACKLINK_FTP_HOST, LIVEBACKLINK_FTP_USER, or LIVEBACKLINK_FTP_PASSWORD.');
    process.exit(1);
}

async function deploy() {
    const client = new ftp.Client();
    client.ftp.verbose = true;
    try {
        await client.access({
            host: ftpHost,
            user: ftpUser,
            password: ftpPassword,
            secure: false
        });
        console.log("✅ Connected securely!");
        await client.ensureDir("/"); // Root of livebacklink.com virtual ftp
        await client.clearWorkingDir();
        await client.uploadFromDir("LIVEBACKLINK_DEPLOY");
        console.log('\n\n✅ DEPLOYMENT COMPLETE!');
        console.log('🌐 Your backend API and frontend are now LIVE on the server!');
    }
    catch(err) {
        console.log("❌ FTP DEPLOYMENT ERROR:");
        console.log(err);
    }
    client.close();
}

deploy();
