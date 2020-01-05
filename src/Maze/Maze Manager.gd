extends Spatial

onready var current_maze := $"Current Maze"
onready var next_maze := $"Next Maze"

const Floor = preload("res://src/Maze/Components/Floor.tscn")
const Wall =  preload("res://src/Maze/Components/Wall.tscn")

export(float) var cell_width = 4.0
export(float) var cell_height = 2.0
export(float) var wall_height = 2.0

func get_world_coordinates(row: int, column: int) -> Vector3:
	return Vector3(row * cell_width, 0, column * cell_height)

func instantiate_maze() -> void:
	var generator := $"Maze Generator"
	var maze: Maze = generator.generate_maze()
	
	var offset = 0 #cell_size * 0.5 * (maze.number_rows)po
	
	for row in maze.number_rows:
		for column in maze.number_columns:
			var cell := maze.cell_at(row, column) 
			
			var left_boundary: float = cell_width * column - offset
			var right_boundary: float = cell_width * (column + 0.5) - offset
			var top_boundary: float = -(cell_height * row - offset) # Negative to invert axis
			var bottom_boundary: float = -(cell_height * (row - 0.5) - offset)
			
			# Instantiate floor.
			var maze_floor := Floor.instance()
			maze_floor.width = cell_width
			maze_floor.depth = cell_height
			maze_floor.translate(Vector3(left_boundary, 0, bottom_boundary))
			current_maze.add_child(maze_floor)
			
			# Instantiate walls.
			if cell.walls.E:
				instantiate_wall(right_boundary, bottom_boundary, PI / 2, cell_height)
				
			if cell.walls.S:
				instantiate_wall(left_boundary, bottom_boundary + cell_height * 0.5, 0, cell_width)
				
			if cell.walls.W:
				instantiate_wall(left_boundary - cell_width * 0.5, bottom_boundary, PI / 2, cell_height)
				
			if cell.walls.N:
				instantiate_wall(left_boundary, top_boundary, 0, cell_width)
				
func instantiate_wall(x: float, z: float, y_rotation: float, width: float):
	var wall = Wall.instance()
	wall.translate(Vector3(x, 0, z))
	wall.width = width
	wall.height = wall_height
	wall.rotate_y(y_rotation)
	current_maze.add_child(wall)