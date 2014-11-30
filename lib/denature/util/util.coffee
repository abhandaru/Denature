extend = (result, overrides...) ->
  for hash in overrides
    if hash?
      for key in Object.keys(hash)
        result[key] = hash[key]
  result


module.exports =
  extend: extend
