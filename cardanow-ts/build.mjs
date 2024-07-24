import { build } from 'esbuild';

build({
  entryPoints: ['./src/main.ts'], // replace with your entry point
  bundle: true,
  outfile: 'build/bundle.js',
  platform: 'node', // or 'browser' depending on your target environment
  target: 'es2020',
  minify: true,
  sourcemap: true,
}).catch(() => process.exit(1));
