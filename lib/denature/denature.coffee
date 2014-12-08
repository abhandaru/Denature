###
Dentature namespace contains no state.
@copyright 2014
@author Adu Bhandaru
###

App = require "./core/app"
Event = require "./events/event"
flags = require "./util/flags"
Model = require "./core/model"


###
Export the following under the Denature namespace
###
module.exports =
  # Expose metadata.
  version: 0.1
  webGL: flags.webGL

  # Expose base classes.
  App: App
  Event: Event
  Model: Model
