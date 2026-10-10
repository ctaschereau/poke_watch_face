const { execSync } = require('child_process');
const path = require('path');

const run = (cmd) => execSync(cmd, { stdio: 'inherit', cwd: path.resolve(__dirname, '..') });

run('npm version patch -m "Release v%s"'); // bumps package.json, commits, tags (needs a clean git tree)
const { version } = require('../package.json');

run('npm run build');
run('git push --follow-tags');
run(`gh release create v${version} bin/poke_watch_face.prg --title "v${version}" --generate-notes`);
run('npm run deploy');