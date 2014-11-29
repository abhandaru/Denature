var _ = require('lodash');
var glob = require('glob');
var path = require('path');
var webpack = require('webpack');

var aliasConfig = require('./config/alias.config');

module.exports = WebpackConfigBuilder;


//
// Webpack plugins.
// Non-default Webpack plugins must be npm installed.
//
var DedupePlugin = webpack.optimize.DedupePlugin;
var DefinePlugin = webpack.DefinePlugin;
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var OccurrenceOrderPlugin = webpack.optimize.OccurrenceOrderPlugin;
var SourceMapPlugin = webpack.SourceMapDevToolPlugin;
var UglifyPlugin = webpack.optimize.UglifyJsPlugin;


//
// Common config
//
// Root directory of the project and resources
var root = path.join(__dirname, '../..');
var resources = 'src/client';
// Build context root directory
var context = path.join(root, resources);
// Output directory for generated assets
var outputPath = path.join(root, 'dist');
// Additional directories to search when resolving dependencies
// For instance, you might bower install into lib.
var modulesDirectories = ['node_modules', 'lib'];
// Additional search paths for loaders (enables custom loaders)
var customLoaderPath = path.join(__dirname, 'loaders');
var loaderDirectories = ['node_modules', customLoaderPath];
// Extensions to append when looking up modules
var extensionsConfig = ['', '.coffee', '.js'];


//
// Customizable config
//
// Default parameters for webpack.config clients
var defaults = {
  // Turns on various annotations and logging
  debug: true,
  // Label assets with hashes for cache-busting (for prod)
  hashing: false,
  // Turns on minification, code deduping, etc.
  optimization: false,
  // Whether to include source maps, helpful with js bundles
  sourceMaps: true,
  // Production path to assets (such as cdn)
  publicPath: '/'
};


//
// Config builder
//
function WebpackConfigBuilder(options) {
  var params = _.extend({ }, defaults, options);
  this.buildDir = path.join(context, outputPath);
  this.config = generateConfig(resolveParams(params));
}


// This is the actual webpack config object.
// More info: http://webpack.github.io/docs/configuration.html
function generateConfig(params) {
  return {
    debug: params.debug,
    context: context,
    entry: entryConfig(params),
    output: outputConfig(params),
    plugins: pluginsConfig(params),
    module: {
      loaders: loadersConfig(params)
    },
    resolve: {
      alias: aliasConfig,
      extensions: extensionsConfig,
      modulesDirectories: modulesDirectories
    },
    resolveLoader: {
      modulesDirectories: loaderDirectories
    }
  };
}


// Extract any other params from those that are given.
function resolveParams(params, lang) {
  var cssOpts = [ ];
  if (params.optimization) cssOpts.push('minimize');
  if (params.sourceMaps) cssOpts.push('sourcemap');

  var hash = params.hashing ? '.[hash]' : '';
  var contenthash = params.hashing ? '.[hash]' : '';
  var bundleName = '[name].bundle' + contenthash;

  var imgOpts = {name: '/img/[name]' + hash + '.[ext]'};
  var fontOpts = {name: '/font/[name]' + hash + '.[ext]'};

  return _.extend({ }, params, {
    imgQuery: queryStr(imgOpts),
    fontQuery: queryStr(fontOpts),
    cssQuery: queryStr(cssOpts),
    cssBundleName: bundleName + '.css',
    jsBundleName: bundleName + '.js'
  });
}


// Find top level modules to build bundles for.
// By convention we search the js/pages/ directory for top level files.
function entryConfig(params) {
  return {
    app: path.join(context, 'js/app.coffee')
  };
}


// Output compiled assets into the specified `outputPath`
// The directory format is [outputPath]/[lang]/js/[name].bundle.js
function outputConfig(params) {
  return {
    filename: path.join('js', params.jsBundleName),
    path: outputPath,
    pathinfo: params.debug,
    publicPath: path.join(params.publicPath),
    sourcePrefix: ''
  };
}


function loadersConfig(params) {
  return [
    // Interpret coffee script files
    { test: /\.coffee$/, loader: 'coffee' },

    // Extract mustache templates using Hogan
    { test: /\.mustache$/, loader: 'mustache' },

    // Extract css bundle into a separate file
    {
      test: /\.less$/,
      loader: ExtractTextPlugin.extract('style-loader', 'css' + params.cssQuery + '!less')
    },

    // Extract images and separately output them
    { test: /.*\.(gif|png|jpe?g|svg)$/, loader: 'file' + params.imgQuery },

    // Extract fonts and separately output them
    { test: /.*\.(ttf|woff|eot)$/, loader: 'file' + params.fontQuery }
  ];
}


function pluginsConfig(params) {
  var plugins = [ ];

  // Additional global params exposed to the bundle
  plugins.push(new DefinePlugin({
    DEBUG: params.debug
  }));

  // Extract css bundle into a separate file
  plugins.push(new ExtractTextPlugin(
    path.join('css', params.cssBundleName)
  ));

  // Generate source maps with bundles
  if (params.sourceMaps) {
    plugins.push(new SourceMapPlugin(
      '[file].map', null,
      '[absolute-resource-path]', '[absolute-resource-path]'
    ));
  }

  // Optimization techniques
  if (params.optimization) {
    plugins.push(
      new DedupePlugin(),
      new OccurrenceOrderPlugin(),
      new UglifyPlugin()
    );
  }

  return plugins;
}


// Creates a query string from an array of flags or a params object
// with string keys and values.
function queryStr(params) {
  var mapFn;
  if (params instanceof Array)
    mapFn = function(val, key) { return val; }
  else
    mapFn = function(val, key) { return key + '=' + val; }
  var str = _.map(params, mapFn).join('&');
  return (str.length ? '?' : '') + str;
}
