'use strict'

###
Hexagon geometry
@author Drahomír Hanák
###

THREE = require "three"


class HexagonGeometry extends THREE.Geometry

  ###
  @constructor
  @param {Number} [radius]
  @param {Number} [depth]
  ###
  constructor: (radius = 1, depth = 1) ->
    super()

    # tg 60
    angle = 1.7320508075688767
    h = angle * 0.5 # height of a triangle

    @vertices.push new THREE.Vector3(0,   0,      1)
    @vertices.push new THREE.Vector3(0,   1,      1)
    @vertices.push new THREE.Vector3(-h,  0.5,    1)
    @vertices.push new THREE.Vector3(-h,  -0.5,   1)
    @vertices.push new THREE.Vector3(0,   -1,     1)
    @vertices.push new THREE.Vector3(h,   -0.5,   1)
    @vertices.push new THREE.Vector3(h,   0.5,    1)
    @vertices.map (vertex) -> vertex.multiply new THREE.Vector3(radius, radius, radius * depth)

    @faces.push new THREE.Face3 0, 1, 2
    @faces.push new THREE.Face3 0, 2, 3
    @faces.push new THREE.Face3 0, 3, 4
    @faces.push new THREE.Face3 0, 4, 5
    @faces.push new THREE.Face3 0, 5, 6
    @faces.push new THREE.Face3 0, 6, 1


module.exports = HexagonGeometry
