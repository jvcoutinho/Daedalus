extends "res://addons/gut/test.gd"

const MazeManager = preload("res://src/Maze/Maze Manager.tscn")
var maze_manager: Spatial

func before_each():
	maze_manager = MazeManager.instance()
	add_child(maze_manager)
	
func after_each():
	maze_manager.free()
	
func test_maze_generation():
	maze_manager.instantiate_maze()
	var current_maze := maze_manager.get_node("Current Maze")
	var grid_size = current_maze.number_rows * current_maze.number_columns
	
	# Counting number of floors
	var num_floors := 0
	for child in current_maze.get_children():
		if child.get_name().find("Floor") != -1:
			num_floors += 1
			
	# Counting number of walls
	var num_walls: int = current_maze.number_rows * 2 + current_maze.number_columns * 2
	for child in current_maze.get_children():
		if child.get_name().find("Wall") != -1:
			num_walls += 1
			
	assert_eq(num_floors, grid_size, "The number of floors instantiated equals the grid size.")
	assert_gt(num_walls, grid_size, "The number of instantiated walls is greater than the grid size.")
	assert_lt(num_walls, grid_size * 4, "But it isn't the case that all of the cells have 4 walls.")