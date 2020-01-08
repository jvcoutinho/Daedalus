extends "res://addons/gut/test.gd"

const Daedalus = preload("res://src/Characters/Player.tscn")
var daedalus: Spatial

func before_each():
	daedalus = Daedalus.instance()
	add_child(daedalus)
	
func after_each():
	daedalus.free()
	
func test_swipe_change_direction():	
	_simulate_swipe(Vector2(0, 0), Vector2(100, 0))
	assert_eq(daedalus.direction, Vector3.RIGHT, "Swipe changes direction")
	
	_simulate_swipe(Vector2(-50, 50), Vector2(-100, 49))
	assert_eq(daedalus.direction, Vector3.LEFT, "Swipe changes direction")
	
	_simulate_swipe(Vector2(100, 50), Vector2(150, 49))
	assert_eq(daedalus.direction, Vector3.RIGHT, "Swipe changes direction")

	_simulate_swipe(Vector2(0, 100), Vector2(10, 200))
	assert_eq(daedalus.direction, Vector3.BACK, "Swipe changes direction")
	
	_simulate_swipe(Vector2(0, 100), Vector2(0, 0))
	assert_eq(daedalus.direction, Vector3.FORWARD, "Swipe changes direction")
	
func _simulate_swipe(initial_position: Vector2, final_position: Vector2) -> void:
	# First touch.
	var touch := InputEventScreenTouch.new()
	touch.position = initial_position
	touch.pressed = true
	daedalus._input(touch)
	
	# Drag it.
	var drag := InputEventScreenDrag.new()
	drag.position = initial_position
	drag.relative = final_position - initial_position
	daedalus._input(drag)
	
	# Release finger.
	touch.position = final_position
	touch.pressed = false
	daedalus._input(touch)
	
func test_swipe_requires_drag():
	# First touch.
	var touch = InputEventScreenTouch.new()
	touch.index = 0
	touch.position = Vector2(0, 0)
	touch.pressed = true
	daedalus._input(touch)
	
	# Second touch.
	var touch2 = InputEventScreenTouch.new()
	touch2.index = 1
	touch2.position = Vector2(10, 0)
	touch2.pressed = true
	daedalus._input(touch2)
	
	# Release the second touch.
	touch2.pressed = false
	daedalus._input(touch2)
	
	# Release the first touch.
	touch.pressed = false
	daedalus._input(touch)
	
	assert_eq(daedalus.direction, Vector3.ZERO,
			"Touching in two different positions of the screen without dragging does not alter direction")
	
func test_swipe_too_short():
	# First touch.
	var touch = InputEventScreenTouch.new()
	touch.position = Vector2(0, 0)
	touch.pressed = true
	daedalus._input(touch)
	
	# Drag it.
	var drag = InputEventScreenDrag.new()
	drag.position = Vector2(0, 0)
	drag.relative = Vector2(daedalus.SWIPE_MINIMUM_LENGTH, 0)
	daedalus._input(drag)
	
	# Release finger.
	touch.position = Vector2(daedalus.SWIPE_MINIMUM_LENGTH, 0)
	touch.pressed = false
	daedalus._input(touch)
	
	assert_eq(daedalus.direction, Vector3.ZERO, "Swipping too shortly doesn't change direction")
	
func test_using_icarus_wings():
	var current_speed = daedalus.speed
	daedalus.use_wings()
	assert_gt(daedalus.speed, current_speed, "Using Icarus' Wings increases Daedalus' speed")

func test_using_ancient_greek_food():
	daedalus.life = 30.0
	
	daedalus.use_food()
	yield(yield_for(daedalus.FOOD_FULL_TIME + 0.5), YIELD)
	assert_gt(daedalus.life, 90.0, 
			"Eating Ancient Greek's Food fills Daedalus' life and prevents it to decrease for some seconds")
			
func test_using_apolo_ink():
	var maze: Spatial = load("res://src/Phase/Maze.gd").new()
	maze.number_rows = 2
	maze.number_columns = 5
	maze.random_seed = 1
	add_child(maze)
	
	var error := daedalus.connect("used_ink", maze, "_on_Player_used_ink")
	assert_not_null(error)
	daedalus.translation = maze.to_world_coordinates(0, 0)
	
	daedalus.use_ink(WallOrientation.WEST_WALL, Color.green)
	assert_true(walls_are_painted(maze, maze.get_column(0), WallOrientation.WEST_WALL, Color.green), "Paints all column")
	
	daedalus.use_ink(WallOrientation.SOUTH_WALL, Color.red)
	assert_true(walls_are_painted(maze, [maze.cell_at(0, 0)], WallOrientation.SOUTH_WALL, Color.red), "Paints only the first cell")
	
	daedalus.use_ink(WallOrientation.EAST_WALL, Color.green)
	assert_true(walls_are_painted(maze, [maze.cell_at(0, 0)], WallOrientation.EAST_WALL, Color.green), "Paints only the first column")
	
	daedalus.use_ink(WallOrientation.NORTH_WALL, Color.blue)
	assert_false(walls_are_painted(maze, [maze.cell_at(0, 0)], WallOrientation.NORTH_WALL, Color.blue), "Paints nothing")
		
	maze.free()
	
func walls_are_painted(maze: Node, cells: Array, wall: String, color: Color) -> bool:
	for cell in cells:
		var world_cell_name = MazeInstancer.get_cell_node_name(cell.row, cell.column)
		var world_cell = maze.get_node(world_cell_name)
		if not world_cell.has_node(wall):
			return false
		var world_wall = world_cell.get_node(wall)
		printt(world_wall.material.albedo_color, color)
		if world_wall.material.albedo_color != color:
			return false
	return true
	
func test_using_living_fire():
	var maze: Spatial = load("res://src/Phase/Maze.gd").new()
	maze.number_rows = 2
	maze.number_columns = 5
	maze.random_seed = 1
	add_child(maze)
	
	var error := daedalus.connect("used_fire", maze, "_on_Player_used_fire")
	assert_not_null(error)
	daedalus.translation = maze.to_world_coordinates(0, 2)
	
	daedalus.use_fire()
	var cells_to_enlight = [maze.cell_at(0, 2), maze.cell_at(1, 2), maze.cell_at(1, 1), maze.cell_at(1, 0)]
	for cell in cells_to_enlight:
		var world_cell = maze.world_cell_at(cell.row, cell.column)
		var floor_node = world_cell.get_node("Floor")
		assert_eq(floor_node.material.albedo_color, Color.gray)

	maze.free()
	
func test_using_creator_axe():
	var maze: Spatial = load("res://src/Phase/Maze.gd").new()
	maze.number_rows = 2
	maze.number_columns = 5
	maze.random_seed = 1
	add_child(maze)
	
	var error := daedalus.connect("used_axe", maze, "_on_Player_used_axe")
	assert_not_null(error)
	daedalus.translation = maze.to_world_coordinates(0, 0)
	
	var world_cell = maze.world_cell_at(0, 0)
	daedalus.use_axe(WallOrientation.EAST_WALL)
	daedalus.use_axe(WallOrientation.WEST_WALL)
	daedalus.use_axe(WallOrientation.SOUTH_WALL)
	yield(yield_for(1), YIELD)
	assert_false(world_cell.has_node(WallOrientation.EAST_WALL), "Deletes when not at borders.")	
	assert_true(world_cell.has_node(WallOrientation.WEST_WALL), "Does not delete at west borders.")	
	assert_true(world_cell.has_node(WallOrientation.SOUTH_WALL), "Does not delete at south borders.")
	
	world_cell = maze.world_cell_at(1, 4)
	daedalus.translation = maze.to_world_coordinates(1, 4)
	daedalus.use_axe(WallOrientation.NORTH_WALL)
	daedalus.use_axe(WallOrientation.EAST_WALL)
	yield(yield_for(1), YIELD)
	assert_true(world_cell.has_node(WallOrientation.NORTH_WALL), "Does not delete at north borders.")	
	assert_true(world_cell.has_node(WallOrientation.EAST_WALL), "Does not delete at east borders.")
	

	maze.free()