class_name WorldSettings
extends Resource

signal world_changed(world: WorldSettings)

@export var width: int = 16
@export var height: int = 16
@export var floor_height: int = 0
@export var spawn_size: int = 18

var astar_grid: AStarGrid2D: set = set_astar_grid
var world_points: Array

func set_astar_grid(value):
	astar_grid = value
	world_changed.emit()
