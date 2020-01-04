extends Spatial

onready var maze_manager := $"Maze Manager"
onready var camera := $Camera
onready var daedalus := $Daedalus

func _ready():
	maze_manager.instantiate_maze()

func _physics_process(delta):
	camera.translation = Vector3(daedalus.translation.x, camera.translation.y, daedalus.translation.z + 2)
