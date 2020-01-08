extends Node

onready var maze := $Maze
onready var player := $Player
onready var camera := $Camera
onready var gui := $GUI

func _ready():
	translate_player()
	camera.target = player
	player.connect("used_ink", maze, "_on_Player_used_ink")
	player.connect("used_fire", maze, "_on_Player_used_fire")
	
func _process(_delta):
	var life_text = str(ceil(player.life))
	gui.update_life(life_text)

func translate_player() -> void:
	var initial_cell: Cell = maze.initial
	var player_position: Vector3 = maze.to_world_coordinates(initial_cell.row, initial_cell.column)
	player.translation = player_position
