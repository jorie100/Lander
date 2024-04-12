extends Node3D

signal world_generated(world: WorldSettings)

# Settings del mundo
@export_category("WorldSettings")
@export var world_settings: WorldSettings

func _ready() -> void:
	
	# Para que el punto (0,0) sea el centro del mundo
	var width = world_settings.width
	var height = world_settings.height
	var width_fixed = int(-width/2.0)
	var height_fixed = int(-height/2.0)
	
	# Generar Astar2DGrid
	var astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(width_fixed,height_fixed, width, height)
	astar_grid.cell_size = Vector2(16,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	world_settings.astar_grid = astar_grid
	
	## Generar matriz
	#var world_points: Array
	#world_points.resize(width)
	#for x in width:
		#var world_points_y = []
		#world_points_y.resize(height)
		#world_points[x] = world_points_y
		#for y in height:
			#world_points[x][y] = 0
	#world_settings.world_points = world_points
	
	world_generated.emit(world_settings)

func set_world_point(x: int, y: int, solid: bool) -> void:
	world_settings.astar_grid.set_point_solid(Vector2i(x,y),solid)
	world_settings.world_changed.emit(world_settings)
