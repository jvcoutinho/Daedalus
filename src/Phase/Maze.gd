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
	grid = maze.grid
	MazeInstancer.instantiate_maze(self, maze, cell_width, cell_height, wall_height)

func generate_maze() -> Maze:
	var generator := MazeGenerator.new()
	_copy_attributes(generator)
	return generator.generate_maze()
	
func paint_adjacent_walls(start_cell: Cell, wall: String, color: Color) -> void:
	var neighbours: Array
	
	# Vertical painting.
	if wall == Constants.EAST_WALL or wall == Constants.WEST_WALL:
		neighbours = get_vertical_neighbours(start_cell)
	else:
		neighbours = get_horizontal_neighbours(start_cell)
		
	paint(start_cell, wall, color)
	for neighbour in neighbours:
		paint(neighbour, wall, color)
		
func paint(cell: Cell, wall: String, color: Color) -> void:
	var world_cell := world_cell_at(cell.row, cell.column)
	if world_cell.has_node(wall): # this should be removed
		var world_wall := world_cell.get_node(wall)
		world_wall.material.albedo_color = color
		
func get_vertical_neighbours(cell: Cell) -> Array:
	var neighbours := []
	
	# Up.
	for row in range(cell.row + 1, number_rows):
		var neighbour := cell_at(row, cell.column) 
		if not neighbour.walls.S:
			neighbours.append(neighbour)
		else:
			break
			
	# Down.
	for row in range(0, cell.row):
		var neighbour := cell_at(cell.row - row, cell.column) 
		if not neighbour.walls.N:
			neighbours.append(neighbour)
		else:
			break
	return neighbours
	
func get_horizontal_neighbours(cell: Cell) -> Array:
	var neighbours := []
	
	# Right.
	for column in range(cell.column + 1, number_columns):
		var neighbour := cell_at(cell.row, column) 
		if not neighbour.walls.W:
			neighbours.append(neighbour)
		else:
			break
			
	# Left.
	for column in range(0, cell.column):
		var neighbour := cell_at(cell.row, cell.column - column) 
		if not neighbour.walls.E:
			neighbours.append(neighbour)
		else:
			break
	return neighbours
	
func _copy_attributes(generator: MazeGenerator):
	generator.number_of_rows = number_rows
	generator.number_of_columns = number_columns
	generator.seed_ = random_seed
	generator.algorithm = algorithm

func to_world_coordinates(row: int, column: int) -> Vector3:
	var correspondent_cell_node := MazeInstancer.get_cell_node_name(row, column)
	return get_node(correspondent_cell_node).translation
	
func to_maze_coordinates(x: float, z: float) -> Vector2:
	var row := floor(-z / cell_height)
	var column := floor(x / cell_width)
	return Vector2(row, column)
	
func world_cell_at(row: int, column: int) -> Node:
	return get_node(MazeInstancer.get_cell_node_name(row, column))
	
func cell_at(row: int, column: int) -> Cell:
	return grid[row][column]
	
func get_row(row: int) -> Array:
	return grid[row]
	
func get_column(column: int) -> Array:
	var cells := []
	for row in number_rows:
		cells.append(cell_at(row, column))
	return cells
	
func _on_Player_used_ink(player_position: Vector3, wall: String, color: Color):
	var player_cell_coordinates: Vector2 = to_maze_coordinates(player_position.x, player_position.z)
	var player_cell: Cell = cell_at(int(player_cell_coordinates.x), int(player_cell_coordinates.y))
	paint_adjacent_walls(player_cell, wall, color)