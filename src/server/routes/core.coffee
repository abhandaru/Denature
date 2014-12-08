core = require "../controllers/core"

module.exports = (app) ->
  # Root
  app.get "/", core.index

  # Tactics
  app.get "/tactics", core.tactics
