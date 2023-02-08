import * as esbuild from "esbuild";
import manifestPlugin from "esbuild-plugin-manifest";

const args = process.argv.slice(2)

const watch = args.includes("--watch")
const precompile = args.includes("--precompile")

const entryPoints = process.env.ESBUILD_ENTRY_POINTS.split(" ");
const outDir = process.env.ESBUILD_OUTDIR;

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
}

let opts = {}
const generalOptions = {
  bundle: true,
  entryPoints: entryPoints,
  outdir: outDir,
  loader: loader,
  plugins: [],
}

if (watch) {
  const watchOptions = {
    logLevel: process.env.ESBUILD_LOG_LEVEL || "silent",
    minify: false,
    sourcemap: false,
  }

  opts = {...generalOptions, ...watchOptions};

  let ctx = await esbuild.context(opts);
  await ctx.watch();
}

if (precompile) {
  const precompileOpts = {
    logLevel: process.env.ESBUILD_LOG_LEVEL || "info",
    minify: process.env.ESBUILD_MINIFY || true,
    sourcemap: process.env.ESBUILD_SOURCEMAP || true,
    entryNames: "[dir]/[name]-[hash]",
    plugins: [manifestPlugin()],
  }

  opts = {...generalOptions, ...precompileOpts};

  await esbuild
    .build(opts)
    .catch(err => {
      console.log(err);
      process.exit(1);
    });
}
