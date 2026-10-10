const fs = require('fs');
const path = require('path');

const src = path.resolve(__dirname, '..', 'bin', 'poke_watch_face.prg');
const dest = process.env.GARMIN_APPS || 'D:\\GARMIN\\APPS';

if (!fs.existsSync(dest)) {
  console.error(`Watch not found at ${dest} (is it plugged in?)`);
  process.exit(1);
}
fs.copyFileSync(src, path.join(dest, 'poke_watch_face.prg'));
console.log(`Copied to ${dest}`);