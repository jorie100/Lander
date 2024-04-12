class_name WorldSettings
extends Resource

signal world_changed(world: WorldSettings)

@export var width: int = 16
@export var height: int = 16
@export var floor_height: int = 0
@export var spawn_size: int = 18

var astar_grid: AStarGrid2D
var world_points: Array
