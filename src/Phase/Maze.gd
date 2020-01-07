extends Spatial

const MazeGenerator = preload("res://src/Maze/Maze Generator/Maze Generator.gd")

const Wings = preload("res://src/Maze/Items/Wings.tscn")
const Food = preload("res://src/Maze/Items/Food.tscn")

export(MazeGenerator.MazeGenerationAlgorithm) var algorithm = MazeGenerator.MazeGenerationAlgorithm.RECURSIVE_BACKTRACKER
export(int) var number_rows: int = 3
export(int) var number_columns: int = 3
export(float) var cell_width: float = 5.0 
export(float) var cell_height: float = 3.0
export(float) var wall_height: float = 3.0
export(int) var random_seed: int = 255

var grid: Array

func _ready():
	var maze := generate_maze()
	MazeInstancer.instantiate_maze(self, maze, cell_width, cell_height, wall_height)

func generate_maze() -> Maze:
	var generator := MazeGenerator.new()
	_copy_attributes(generator)
	return generator.generate_maze()
	
func _copy_attributes(generator: MazeGenerator):
	generator.number_of_rows = number_rows
	generator.number_of_columns = number_columns
	generator.seed_ = random_seed
	generator.algorithm = algorithm

func to_world_coordinates(row: int, column: int) -> Vector3:
	var correspondent_cell_node := MazeInstancer.get_cell_node_name(row, column)
	return get_node(correspondent_cell_node).translation
	
func cell_at(row: int, column: int) -> Cell:
	return grid[row][column]
	
func get_row(row: int) -> Array:
	return grid[row]
	
func get_column(column: int) -> Array:
	var cells := []
	for row in number_rows:
		cells.append(cell_at(row, column))
	return cells