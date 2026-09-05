/**
 * TrainWake Admin Privilege Tool
 * 
 * Securely assigns or revokes Firebase Custom User Claims ({ admin: true }).
 * Never exposes admin credentials or emails inside the mobile Flutter app.
 *
 * Usage:
 *   node set_admin.js user@example.com           -> Grant Admin
 *   node set_admin.js --check user@example.com   -> Check Status
 *   node set_admin.js --revoke user@example.com  -> Revoke Admin
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const keyPath = path.join(__dirname, 'serviceAccountKey.json');

// Initialize Firebase Admin SDK
try {
  if (fs.existsSync(keyPath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: 'train-wake',
    });
  } else {
    // Attempt ADC (Application Default Credentials)
    admin.initializeApp({
      projectId: 'train-wake',
    });
  }
} catch (e) {
  console.error('\n❌ Could not initialize Firebase Admin SDK:');
  console.error(e.message);
  console.error('\n👉 Please download serviceAccountKey.json from Firebase Console:');
  console.error('   https://console.firebase.google.com/project/train-wake/settings/serviceaccounts/adminsdk');
  console.error('   and place it in this folder:\n   ' + __dirname + '\n');
  process.exit(1);
}

const args = process.argv.slice(2);

if (args.length === 0) {
  console.log('\nTrainWake Admin Tool');
  console.log('--------------------');
  console.log('Usage:');
  console.log('  node set_admin.js <email>          Grant admin privileges');
  console.log('  node set_admin.js --check <email>  Check if an email is admin');
  console.log('  node set_admin.js --revoke <email> Revoke admin privileges');
  console.log('  node set_admin.js --list           List registered users and admin status');
  console.log('\nExample:');
  console.log('  node set_admin.js developer@gmail.com\n');
  process.exit(0);
}

async function run() {
  if (args[0] === '--list') {
    try {
      console.log('\n📋 Fetching registered TrainWake Firebase users...');
      const listUsersResult = await admin.auth().listUsers(50);
      if (listUsersResult.users.length === 0) {
        console.log('No users registered yet.');
        return;
      }
      console.log('\nRegistered Users:');
      console.log('------------------------------------------------------------');
      listUsersResult.users.forEach((u) => {
        const isAdmin = u.customClaims?.admin === true;
        console.log(`• ${u.email || '(No Email)'} [${isAdmin ? '👑 ADMIN' : '👤 USER'}] (UID: ${u.uid})`);
      });
      console.log('------------------------------------------------------------\n');
      return;
    } catch (err) {
      console.error('Error listing users:', err.message);
      return;
    }
  }

  let mode = 'grant';
  let targetEmail = '';

  if (args[0] === '--check') {
    mode = 'check';
    targetEmail = args[1];
  } else if (args[0] === '--revoke') {
    mode = 'revoke';
    targetEmail = args[1];
  } else {
    targetEmail = args[0];
  }

  if (!targetEmail || !targetEmail.includes('@')) {
    console.error('❌ Please provide a valid email address.');
    process.exit(1);
  }

  try {
    console.log(`\n🔍 Looking up user: ${targetEmail}...`);
    const user = await admin.auth().getUserByEmail(targetEmail.trim());
    console.log(`✅ Found user: UID = ${user.uid}`);

    const existingClaims = user.customClaims || {};

    if (mode === 'check') {
      const isAdmin = existingClaims.admin === true;
      console.log(`\nℹ️  Admin status for ${targetEmail}: ${isAdmin ? '👑 ADMIN' : '👤 REGULAR USER'}`);
      console.log(`   All custom claims:`, existingClaims);
      return;
    }

    if (mode === 'revoke') {
      const updatedClaims = { ...existingClaims };
      delete updatedClaims.admin;
      await admin.auth().setCustomUserClaims(user.uid, updatedClaims);
      console.log(`\n✅ Successfully revoked Admin privileges for ${targetEmail}.`);
      return;
    }

    // Grant mode
    const updatedClaims = { ...existingClaims, admin: true };
    await admin.auth().setCustomUserClaims(user.uid, updatedClaims);

    console.log('\n======================================================');
    console.log(`🎉 SUCCESS! ${targetEmail} is now a TrainWake ADMIN!`);
    console.log('======================================================');
    console.log('Claim set: { admin: true }');
    console.log('\nNote: If the user is currently signed in on the app,');
    console.log('they must Sign Out and Sign In again (or trigger a token reload)');
    console.log('for the new admin claims to take effect.\n');
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.error(`\n❌ No user found with email: ${targetEmail}`);
      console.error('Please make sure the user has created an account in the app first.');
    } else {
      console.error('\n❌ Firebase error:', error.message);
      if (!fs.existsSync(keyPath)) {
        console.error('\n👉 Missing serviceAccountKey.json. Download it from:');
        console.error('   https://console.firebase.google.com/project/train-wake/settings/serviceaccounts/adminsdk');
        console.error('   and place it inside: ' + __dirname + '\n');
      }
    }
  }
}

run();
