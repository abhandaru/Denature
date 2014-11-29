del = require "del"
path = require "path"
webpack = require "webpack"


# The defualt mode to bundle assets for.
mode = "dev"

# Continually recompile assests whenever a resource file changes
watch = false
watchDelay = 200

# Compile stats display options
statsOpts =
  assetsSort : "name"
  colors     : true
  children   : false
  chunks     : false
  modules    : false


# Digest arguments
args = process.argv.slice(2) or [ ];
args.forEach (option) ->
  switch option
    when "--watch" then watch = true
    else
      console.log "[webpack] unrecognized option:", option
      process.exit()


# Delete old build
config = require "./config/webpack-" + mode + ".config"
del.sync config.buildDir


# Init webpack compiler
compiler = webpack config.config
resultsFn = (err, stats) ->
  throw err if err
  console.log stats.toString(statsOpts)


# Compile!
if watch
  compiler.watch watchDelay, resultsFn
else
  compiler.run resultsFn
