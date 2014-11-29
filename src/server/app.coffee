bodyParser = require "body-parser"
errorHandler = require "errorhandler"
express = require "express"
methodOverride = require "method-override"
morgan = require "morgan"

env = require "./env"


# Routes
coreRoutes = require "./routes/core"


# Configuration
app = express()
app.set("views", env.views)
app.set("view engine", "jade")
app.use express.static(env.public)
app.use bodyParser.urlencoded(extended: false)
app.use methodOverride()
app.use morgan("dev")
app.use errorHandler(
  dumpExceptions: true
  showStack: true
)


# Routing
coreRoutes app

# Server
app.listen(env.port, () ->
  console.log "|- Express server listening on port %d in %s mode.",
    env.port, app.settings.env
)

module.exports = app
