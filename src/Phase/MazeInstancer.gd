class_name MazeInstancer

const Floor = preload("res://src/Maze/Components/Floor.tscn")
const Wall =  preload("res://src/Maze/Components/Wall.tscn")

static func instantiate_maze(parent: Node, maze: Maze, cell_width: float, cell_height: float, wall_height: float) -> void:
	for row in maze.number_rows:
		for column in maze.number_columns:
			var cell := maze.cell_at(row, column)
			var cell_node := instantiate_cell_node(cell, cell_width, cell_height)

			instantiate_floor(cell_node, cell_width, cell_height)
			instantiate_walls(cell_node, cell.walls, cell_width, cell_height, wall_height)
			
			parent.add_child(cell_node, true)
			
static func instantiate_cell_node(cell: Cell, cell_width: float, cell_height: float) -> Node:
	var cell_center_x = cell_width * (cell.column + 0.5)
	var cell_center_y = -cell_height * (cell.row + 0.5)
	
	var node = Spatial.new()
	node.name = get_cell_node_name(cell.row, cell.column)
	node.translation = Vector3(cell_center_x, 0, cell_center_y)
	return node
	
static func get_cell_node_name(row: int, column: int) -> String:
	return "(" + str(row) + ", " + str(column) + ")"
	
static func instantiate_floor(parent: Node, width: float, height: float) -> void:
	var mfloor := Floor.instance() 
	mfloor.width = width
	mfloor.depth = height
	mfloor.translation = Vector3.ZERO
	parent.add_child(mfloor, true)

static func instantiate_walls(parent: Node, walls: Dictionary, cell_width: float, cell_height: float, wall_height: float) -> void:
	var bottom_boundary := cell_height * 0.5
	var top_boundary := -bottom_boundary
	var right_boundary := cell_width * 0.5
	var left_boundary := -right_boundary
	
	if walls.N:
		instantiate_wall(parent, 0, top_boundary, 0, cell_width, wall_height, WallOrientation.NORTH_WALL)
	if walls.E:
		instantiate_wall(parent, right_boundary, 0, PI / 2, cell_height, wall_height, WallOrientation.EAST_WALL) 
	if walls.S:
		instantiate_wall(parent, 0, bottom_boundary, 0, cell_width, wall_height, WallOrientation.SOUTH_WALL)
	if walls.W:
		instantiate_wall(parent, left_boundary, 0, PI / 2, cell_height, wall_height, WallOrientation.WEST_WALL)

static func instantiate_wall(parent: Node, x: float, z: float, y_rotation: float, width: float, height: float, name: String) -> void:
	var wall = Wall.instance()
	wall.translate(Vector3(x, 0, z))
	wall.name = name
	wall.width = width
	wall.height = height
	wall.rotate_y(y_rotation)
	parent.add_child(wall, true)