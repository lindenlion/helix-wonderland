// Build one self-contained page: compile Elm with --optimize and inline it into
// public/index.html at the <!-- ELM --> marker. Output: dist/helix-wonderland.html
import { execFileSync } from 'node:child_process';
import { mkdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';

const compiled = 'build/elm.js';
const output = 'dist/helix-wonderland.html';

execFileSync('npx', ['elm', 'make', 'src/Main.elm', '--optimize', `--output=${compiled}`], { stdio: 'inherit' });

const page = readFileSync('public/index.html', 'utf8');
const script = readFileSync(compiled, 'utf8').replaceAll('</script', '<\\/script');
mkdirSync('dist', { recursive: true });
writeFileSync(output, page.replace('<!-- ELM -->', () => `<script>\n${script}\n</script>`));
console.log(`${output}  (${Math.round(statSync(output).size / 1024)} KB)`);
