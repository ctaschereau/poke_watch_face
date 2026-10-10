const { execFileSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const root = path.resolve(__dirname, '..');
const device = process.env.DEVICE || 'instinct2';
const keyPath = process.env.CIQ_KEY || path.join(os.homedir(), 'developer_key');

const sdk = fs
  .readFileSync(path.join(process.env.APPDATA, 'Garmin', 'ConnectIQ', 'current-sdk.cfg'), 'utf8')
  .trim();

fs.mkdirSync(path.join(root, 'bin'), { recursive: true });

execFileSync(
  'java',
  [
    '-Xms1g',
    '-Dfile.encoding=UTF-8',
    '-Dapple.awt.UIElement=true',
    '-jar', path.join(sdk, 'bin', 'monkeybrains.jar'),
    '-o', path.join(root, 'bin', 'poke_watch_face.prg'),
    '-f', path.join(root, 'monkey.jungle'),
    '-y', keyPath,
    '-d', device,
    '-w', '-r',
  ],
  { stdio: 'inherit' }
);