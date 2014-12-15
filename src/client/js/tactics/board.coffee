Denature = require "denature"
THREE = require "three"

Tile = require "./tile"

class Board extends Denature.Model

  @size: 11
  @tapering: 2

  initialize: (options) ->
    # Create all the tiles
    radius = Math.floor(Board.size / 2)
    for i in [-radius..radius]
      for j in [-radius..radius]
        manhatten = Math.abs(i) + Math.abs(j)
        if manhatten <= Board.size - 1 - Board.tapering
          @insert new Tile(row: i, col: j)


module.exports = Board
