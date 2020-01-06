extends WATTest

const MazeManager = preload("res://src/Maze/Maze Manager.tscn")
var maze_manager

func title():
	return "Maze Manager's Tests"

func pre():
	maze_manager = MazeManager.instance()
	
func pos():
	maze_manager.free()

func test_maze_generation():
	describe("When generates a maze, instantiate the walls and floors")
	maze_manager.instantiate_maze()
	
	# Counting number of floors
	var num_floors := 0
	for child in maze_manager.get_node("Current Maze").get_children():
		if child.get_name().begins_with("Floor"):
			num_floors += 1
			
	asserts.is_equal(maze_manager.num_rows * maze_manager.num_columns, num_floors)