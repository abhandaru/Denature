###
We implement these functions ourselves to remove a dependency on underscore or
lodash. We follow the same API as those described by UnderscoreJS
###
extend = (result, overrides...) ->
  for hash in overrides
    if hash?
      for key in Object.keys(hash)
        result[key] = hash[key]
  result


module.exports =
  extend: extend
