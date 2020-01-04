extends Spatial

onready var current_maze := $"Current Maze"
onready var next_maze := $"Next Maze"

const Floor = preload("res://src/Maze/Components/Floor.tscn")
const Wall =  preload("res://src/Maze/Components/Wall.tscn")

export(float) var cell_size = 2.0

func instantiate_maze() -> void:
	var generator := $"Maze Generator"
	var maze: Maze = generator.generate_maze()
	
	var offset = 0 #cell_size * 0.5 * (maze.number_rows)po
	
	for row in maze.number_rows:
		for column in maze.number_columns:
			var cell := maze.cell_at(row, column) 
			
			var left_boundary: float = cell_size * column - offset
			var right_boundary: float = cell_size * (column + 0.5) - offset
			var top_boundary: float = cell_size * (row + 0.5) - offset
			var bottom_boundary: float = cell_size * row - offset
			
			# Instantiate floor.
			var maze_floor := Floor.instance()
			maze_floor.width = cell_size
			maze_floor.depth = cell_size
			maze_floor.translate(Vector3(left_boundary, 0, bottom_boundary))
			current_maze.add_child(maze_floor)
			
			# Instantiate walls.
			if cell.walls.E:
				instantiate_wall(right_boundary, bottom_boundary, PI / 2)
				
			if cell.walls.S:
				instantiate_wall(left_boundary, bottom_boundary - cell_size * 0.5, 0)
				
			if cell.walls.W:
				instantiate_wall(left_boundary - cell_size * 0.5, bottom_boundary, PI / 2)
				
			if cell.walls.N:
				instantiate_wall(left_boundary, top_boundary, 0)
				
func instantiate_wall(x: float, z: float, y_rotation: float):
	var wall = Wall.instance()
	wall.translate(Vector3(x, 0, z))
	wall.rotate_y(y_rotation)
	current_maze.add_child(wall)