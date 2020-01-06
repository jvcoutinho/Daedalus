extends Spatial

onready var maze_manager := $"Maze Manager"
onready var camera := $Camera
onready var player := $Daedalus

func _ready():
	maze_manager.instantiate_maze()
	player.translate(maze_manager.get_world_coordinates(0, 0))
	
func _process(delta):
	camera.translation = Vector3(player.translation.x, camera.translation.y, player.translation.z + 2.5)
	$Label.text = str(Engine.get_frames_per_second())
	$GUI/MarginContainer/Life.text = "LIFE: " + str(ceil(player.life))
