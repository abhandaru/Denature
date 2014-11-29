#
# Entry point for application
#
require "css/app.less"
Denature = require "denature"


class App extends Denature.App
  init: (el, options) ->
    console.log "Hello world!"


module.exports = self.App = App
