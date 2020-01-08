extends Node

onready var maze := $Maze
onready var player := $Player
onready var camera := $Camera
onready var gui := $GUI

func _ready():
	translate_player()
	camera.target = player
	player.connect("used_ink", maze, "_on_Player_used_ink")
	
func _process(_delta):
	var life_text = str(ceil(player.life))
	gui.update_life(life_text)

func translate_player() -> void:
	var player_position: Vector3 = maze.to_world_coordinates(0, 0)
	player.translation = player_position



func _on_Player_used_ink(player_position, wall, color):
	pass # Replace with function body.
