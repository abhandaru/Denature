path = require "path"


root = path.join __dirname, "../../.."
client = path.join root, "src/client"


###
Webpack alias mapping described below:
[regex-pattern] -> [substitution]
###
module.exports =
  # Path shortcuts
  "css"       : path.join client, "css"
  "js"        : path.join client, "js"
  "models"    : path.join client, "models"
  "shaders"   : path.join client, "shaders"
  "templates" : path.join client, "templates"

  # Component nick-names
  "denature$" : "denature/denature"
  "three$"    : "bower_components/threejs/build/three"
