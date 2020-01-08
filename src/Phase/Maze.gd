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
var initial: Cell
var goal: Cell
var pathfinder: AStar

func _ready():
	var maze := generate_maze()
	grid = maze.grid
	initial = choose_cell(maze, 0)
	goal = choose_cell(maze, number_rows - 1)
	MazeInstancer.instantiate_maze(self, maze, cell_width, cell_height, wall_height)
	pathfinder = build_pathfinder()

func choose_cell(maze: Maze, row: int) -> Cell:
	var random_column = randi() % number_columns
	return maze.grid[row][random_column]
	
func build_pathfinder() -> AStar:
	"""
	Performs a breadth-first search to build the AStar pathfinder.
	"""
	var pathfinder := AStar.new()
	
	var first_cell = cell_at(0, 0)
	var frontier = [first_cell]
	_add_point(pathfinder, first_cell)
	
	while not frontier.empty():
		var cell: Cell = frontier.pop_front()
		var cell_id := pathfinder_id(cell)
		
		var neighbours = get_neighbours(cell)
		for neighbour in neighbours:
			var neighbour_id := pathfinder_id(neighbour)
			if not pathfinder.has_point(neighbour_id):
				_add_point(pathfinder, neighbour)
				pathfinder.connect_points(cell_id, neighbour_id)
				frontier.push_back(neighbour)
			elif frontier.has(neighbour):
				pathfinder.connect_points(cell_id, neighbour_id)

	return pathfinder
	
func _add_point(pathfinder: AStar, cell: Cell) -> void:
	var id = pathfinder_id(cell)
	var coordinate = Vector3(cell.row, cell.column, 0)
	pathfinder.add_point(id, coordinate)
	
func pathfinder_id(cell: Cell) -> int:
	return cell.row * number_columns + cell.column

func get_neighbours(cell: Cell) -> Array:
	var neighbours = []
	
	if cell.column > 0 and not cell.walls.W: # Get western neighbour
		neighbours.append(cell_at(cell.row, cell.column - 1))
	
	if cell.column < number_columns - 1 and not cell.walls.E: # Get eastern neighbour
		neighbours.append(cell_at(cell.row, cell.column + 1))
		
	if cell.row > 0 and not cell.walls.S: # Get southern neighbour
		neighbours.append(cell_at(cell.row - 1, cell.column))
		
	if cell.row < number_rows - 1 and not cell.walls.N: # Get northern neighbour
		neighbours.append(cell_at(cell.row + 1, cell.column))

	return neighbours

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
	
func enlight_path(initial_cell: Cell, final_cell: Cell) -> void:
	var initial_cell_id = pathfinder_id(initial_cell)
	var final_cell_id = pathfinder_id(final_cell)
	var path: PoolVector3Array = pathfinder.get_point_path(initial_cell_id, final_cell_id)
	
	for point in path:
		var world_cell := world_cell_at(point.x, point.y)
		var floor_node: Spatial = world_cell.get_node("Floor")
		enlight(floor_node)

func enlight(floor_node: Spatial) -> void:
	floor_node.material.albedo_color = Color.gray
	
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
	
func world_to_maze_cell(position: Vector3) -> Cell:
	var cell_coordinates: Vector2 = to_maze_coordinates(position.x, position.z)
	return cell_at(int(cell_coordinates.x), int(cell_coordinates.y))
	
func _on_Player_used_ink(player_position: Vector3, wall: String, color: Color):
	var player_cell: Cell = world_to_maze_cell(player_position)
	paint_adjacent_walls(player_cell, wall, color)
	
func _on_Player_used_fire(player_position: Vector3):
	var player_cell: Cell = world_to_maze_cell(player_position)
	enlight_path(player_cell, goal)
	