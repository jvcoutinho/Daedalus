extends "res://addons/gut/test.gd"

const Daedalus = preload("res://src/Characters/Daedalus.tscn")
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
	yield(yield_for(5), YIELD)
	assert_eq(daedalus.life, 100.0, 
			"Eating Ancient Greek's Food fills Daedalus' life and prevents it to decrease for some seconds")