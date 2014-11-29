path = require "path"


# namespace
env = { }

# env
env.debug = "-debug" in process.argv
env.production = process.env.NODE_ENV is "production"

# ports
env.devPort = 4000
env.prodPort = process.env.PORT? or env.devPort
env.port = if env.production then env.prodPort else env.devPort

# paths
env.appRoot = __dirname
env.root = path.join env.appRoot, "../.."
env.views = path.join env.appRoot, "views"
env.public = path.join env.root, "dist"

# export
module.exports = env
