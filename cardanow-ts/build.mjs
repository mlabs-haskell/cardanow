import { build } from 'esbuild';

build({
  entryPoints: ['./src/main.ts'],
  bundle: true,
  outfile: 'build/bundle.js',
  platform: 'node',
  target: 'es2020',
  minify: true,
  sourcemap: true,
}).catch(() => process.exit(1));
