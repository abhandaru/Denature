#!/usr/bin/env node
var del = require('del');
var path = require('path');
var webpack = require('webpack');


// The defualt mode to bundle assets for.
var mode = 'dev';

// Continually recompile assests whenever a resource file changes
var watch = false;
var watchDelay = 200;

// Compile stats display options
var statsOpts = {
  assetsSort: 'name',
  colors: true,
  children: false,
  chunks: false,
  modules: false
};


// Digest arguments
var args = process.argv.slice(2) || [ ];
args.forEach(function(option) {
  switch (option) {
    case '--watch': watch = true; break;
    default:
      console.log('[webpack] unrecognized option:', option);
      process.exit();
  }
});


// Delete old build
var config = require('./webpack/config/webpack-' + mode + '.config');
del.sync(config.buildDir);


// Init webpack compiler
var compiler = webpack(config.config);
var resultsFn = function (err, stats) {
  if (err) throw err;
  console.log(stats.toString(statsOpts));
};


// Compile!
if (watch) {
  compiler.watch(watchDelay, resultsFn);
} else {
  compiler.run(resultsFn);
}
