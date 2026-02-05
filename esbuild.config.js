/*
 * Video: https://www.youtube.com/watch?v=qOptalp8zUY&t=797s
 * Code: https://github.com/gorails-screencasts/jsbundling-esbuild/blob/main/esbuild.config.js
 */
const path = require('path');
const rails = require('esbuild-rails');
const { TsconfigPathsPlugin } = require('@esbuild-plugins/tsconfig-paths');

require('esbuild')
  .build({
    entryPoints: ['application.ts'],
    bundle: true,
    outdir: path.join(process.cwd(), 'app/assets/builds'),
    absWorkingDir: path.join(process.cwd(), 'app/javascript'),
    watch: process.argv.includes('--watch'),
    plugins: [
      rails(),
      TsconfigPathsPlugin({}),
    ],
    // For dev
    sourcemap: process.argv.includes('--dev'),
    // For prod
    minify: !process.argv.includes('--dev'),
  })
  .catch(() => process.exit(1));
