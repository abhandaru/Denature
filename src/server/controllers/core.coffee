module.exports =
  index: (req, res) ->
    res.render "index",
      message: "Hello world!"
