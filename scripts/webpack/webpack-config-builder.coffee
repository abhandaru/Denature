_ = require "lodash"
glob = require "glob"
path = require "path"
webpack = require "webpack"

aliasConfig = require "./config/alias.config"


###
Webpack plugins.
Non-default Webpack plugins must be npm installed.
###
DedupePlugin = webpack.optimize.DedupePlugin
DefinePlugin = webpack.DefinePlugin
ExtractTextPlugin = require("extract-text-webpack-plugin")
OccurrenceOrderPlugin = webpack.optimize.OccurrenceOrderPlugin
SourceMapPlugin = webpack.SourceMapDevToolPlugin
UglifyPlugin = webpack.optimize.UglifyJsPlugin


###
Common config
###
# Root directory of the project and resources
root = path.join __dirname, "../.."
resources = "src/client"
context = path.join root, resources
outputPath = path.join root, "dist"
modulesDirectories = ["node_modules", "lib"]
customLoaderPath = path.join __dirname, "loaders"
loaderDirectories = ["node_modules", customLoaderPath]
extensionsConfig = ["", ".coffee", ".js"];


class WebpackConfigBuilder
  ###
  Customizable config
  ###
  defaults =
    debug: true
    hashing: false
    optimization: false
    sourceMaps: true
    publicPath: "/"


  ###
  Config builder
  ###
  constructor: (options) ->
    params = _.extend { }, @defaults, options
    @buildDir = path.join context, outputPath
    @config = @generateConfig(@resolveParams(params))


  ###
  This is the actual webpack config object.
  More info: http:#webpack.github.io/docs/configuration.html
  ###
  generateConfig: (params) ->
    debug: params.debug
    context: context
    entry: @entryConfig(params)
    output: @outputConfig(params)
    plugins: @pluginsConfig(params)
    module:
      loaders: @loadersConfig(params)
    resolve:
      alias: aliasConfig
      extensions: extensionsConfig
      modulesDirectories: modulesDirectories
    resolveLoader:
      modulesDirectories: loaderDirectories


  # Extract any other params from those that are given.
  resolveParams: (params, lang) ->
    hash = if params.hashing then ".[hash]" else ""
    contenthash = if params.hashing then ".[hash]" else ""
    bundleName = "[name].bundle#{contenthash}"

    cssOpts = [ ]
    cssOpts.push "minimize" if params.optimization
    cssOpts.push "sourcemap" if params.sourceMaps
    imgOpts = name: "/img/[name]#{hash}.[ext]"
    fontOpts = name: "/font/[name]#{hash}.[ext]"

    _.extend({ }, params,
      imgQuery: @queryStr imgOpts
      fontQuery: @queryStr fontOpts
      cssQuery: @queryStr cssOpts
      cssBundleName: "#{bundleName}.css"
      jsBundleName: "#{bundleName}.js"
    )


  # Top level modules to build bundles for.
  entryConfig: (params) ->
    app: path.join context, "js/app.coffee"


  ###
  Output compiled assets into the specified `outputPath`
  The directory format is [outputPath]/js/[name].bundle.js
  ###
  outputConfig: (params) ->
    filename: path.join("js", params.jsBundleName)
    path: outputPath
    pathinfo: params.debug
    publicPath: path.join params.publicPath
    sourcePrefix: ""


  loadersConfig: (params) ->
    [
      # Interpret coffee script files
      { test: /\.coffee$/, loader: "coffee" }
      # Extract mustache templates using Hogan
      { test: /\.mustache$/, loader: "mustache" }
      # Extract css bundle into a separate file
      {
        test: /\.less$/,
        loader: ExtractTextPlugin.extract "style-loader", "css#{params.cssQuery}!less"
      }
      # Extract images and separately output them
      { test: /.*\.(gif|png|jpe?g|svg)$/, loader: "file#{params.imgQuery}" }
      # Extract fonts and separately output them
      { test: /.*\.(ttf|woff|eot)$/, loader: "file#{params.fontQuery}" }
    ]


  pluginsConfig: (params) ->
    plugins = [ ]
    # Additional global params exposed to the bundle
    plugins.push new DefinePlugin(DEBUG: params.debug)
    # Extract css bundle into a separate file
    plugins.push new ExtractTextPlugin(path.join "css", params.cssBundleName)
    # Generate source maps with bundles
    if params.sourceMaps
      plugins.push new SourceMapPlugin(
        "[file].map", null,
        "[absolute-resource-path]", "[absolute-resource-path]"
      )
    # Optimization techniques
    if params.optimization
      plugins.push(
        new DedupePlugin(),
        new OccurrenceOrderPlugin(),
        new UglifyPlugin()
      )
    plugins


  # Creates a query string from an array of flags or a params object
  # with string keys and values.
  queryStr: (params) ->
    if params instanceof Array
      mapFn = (val) -> val
    else
      mapFn = (val, key) -> "#{key}=#{val}"
    str = _.map(params, mapFn).join "&"
    return if str.length then "?#{str}" else str


module.exports = WebpackConfigBuilder
