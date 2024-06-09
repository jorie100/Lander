extends Resource
class_name StructureData

@export var structure_name: String = ""  ## The name of the structure
@export var structure_position: Vector3 = Vector3(0, 0, 0)  ## The origin position of the structure on the world grid
@export var structure_shape: Array[Vector2i] = []  ## Array to define the shape of the structure
@export var structure_scene: PackedScene  ## The associated scene for the structure
#@export var data: Dictionary = {}  ## Additional data specific to the structure

#@export_category("Construction")
#@export var build_time: float = 0.0  ## Time required to build the structure (in seconds)
#@export var build_cost: Dictionary = {"wood": 0, "stone": 0, "gold": 0}  ## Resource cost to build the structure
#
#@export_category("Stats")
#@export var health: int = 100  ## The health of the structure
#@export var defense: int = 0  ## The defense value or armor of the structure
#@export var attack_power: int = 0  ## The attack power if the structure can attack
#@export var attack_range: float = 0.0  ## The attack range of the structure
#@export var attack_speed: float = 1.0  ## The attack speed (attacks per second)
#
#@export_category("Production")
#@export var resource_production_rate: Dictionary = {"wood": 0, "stone": 0, "gold": 0}  ## Resource production rate per second
#@export var storage_capacity: Dictionary = {"wood": 0, "stone": 0, "gold": 0}  ## Resource storage capacity
#@export var population_capacity: int = 0  ## The population capacity added by the structure
#
#@export_category("Upgrades")
#@export var upgrade_cost: Dictionary = {"wood": 0, "stone": 0, "gold": 0}  ## Resource cost to upgrade the structure
#@export var upgrade_time: float = 0.0  ## Time required to upgrade the structure (in seconds)
#@export var upgrade_to: StructureData  ## Reference to the next upgrade of the structure
#
#@export_category("States")
#@export var is_active: bool = true  ## Indicates if the structure is active
#@export var is_destroyed: bool = false  ## Indicates if the structure is destroyed
#
## Function to check if a given point is within the structure's shape
##func is_point_in_shape(point: Vector2) -> bool:
	##for relative_point in structure_shape:
		##if structure_position + Vector2(relative_point[0], relative_point[1]) == point:
			##return true
	##return false
#
### Function to calculate the damage received, considering the defense value
#func calculate_damage(incoming_damage: int) -> int:
	#var effective_damage = max(incoming_damage - defense, 0)
	#health -= effective_damage
	#if health <= 0:
		#is_destroyed = true
		#health = 0
	#return effective_damage
#
### Function to produce resources over a given time interval (delta)
#func produce_resources(delta: float) -> Dictionary:
	#var produced_resources = {}
	#for resource in resource_production_rate.keys():
		#produced_resources[resource] = resource_production_rate[resource] * delta
	#return produced_resources
