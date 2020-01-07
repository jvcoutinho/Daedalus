extends Node

onready var maze := $Maze
onready var player := $Player
onready var camera := $Camera
onready var gui := $GUI

func _ready():
	translate_player()
	camera.target = player
	
func _process(delta):
	var life_text = str(ceil(player.life))
	gui.update_life(life_text)

func translate_player() -> void:
	var player_position: Vector3 = maze.to_world_coordinates(0, 0)
	player.translation = player_position
