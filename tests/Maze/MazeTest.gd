extends "res://addons/gut/test.gd"

const Maze = preload("res://src/Phase/Maze.gd")
var maze: Spatial

func before_each():
	maze = Maze.new()
	add_child(maze)
	
func after_each():
	maze.free()
	
func test_maze_generation():
	var grid_size = maze.number_rows * maze.number_columns
	
	# Counting number of cells
	var num_cells := maze.get_children().size()
	assert_eq(num_cells, grid_size)
	
	# Assuring all floors were instantiated and at least one wall
	for row in maze.number_rows:
		for column in maze.number_columns:
			var cell = maze.get_node(MazeInstancer.get_cell_node_name(row, column)) 
			assert_not_null(cell.get_node("Floor"), "A floor exists for each cell")
			assert_true(has_at_least_a_wall(cell), "There is at least one wall")

func has_at_least_a_wall(cell: Node) -> bool:
	for child in cell.get_children():
		if child.name.find("Wall") != -1:
			return true
	return false