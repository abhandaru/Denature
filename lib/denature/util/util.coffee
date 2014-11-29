module.exports =
  extend: (result, overrides...) ->
    for hash in overrides
      for key in Object.keys(hash)
        result[key] = hash[key]
