extends WATTest

const Daedalus = preload("res://src/Characters/Daedalus.gd")
var daedalus: Object

func title():
	return "Daedalus' movement and behaviour tests"

func pre():
	daedalus = Daedalus.new()
	
func pos():
	daedalus.free()

func test_swipe_change_direction():
	parameters([
		["initial_position", "final_position", "desired_direction"],
		[Vector2(0, 0), Vector2(100, 0), Vector3.RIGHT],
		[Vector2(-50, 0), Vector2(-70, 0), Vector3.LEFT],
		[Vector2(100, 50), Vector2(150, 49), Vector3.RIGHT],
		[Vector2(0, 100), Vector2(10, 200), Vector3.BACK],
		[Vector2(0, 100), Vector2(0, 0), Vector3.FORWARD]
	])
	describe("Tests if swipe changes directions")
	
	# First touch.
	var touch = InputEventScreenTouch.new()
	touch.position = p.initial_position
	touch.pressed = true
	daedalus._input(touch)
	
	# Drag it.
	var drag = InputEventScreenDrag.new()
	drag.position = p.initial_position
	drag.relative = p.final_position - p.initial_position
	daedalus._input(drag)
	
	# Release finger.
	touch.position = p.final_position
	touch.pressed = false
	daedalus._input(touch)
	
	asserts.is_equal(p.desired_direction, daedalus.direction)
	
func test_swipe_requires_drag():
	describe("Touching in two different positions of the screen without dragging does not alter direction")
		
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
	
	asserts.is_equal(Vector3.ZERO, daedalus.direction)
	
func test_swipe_too_short():
	describe("Swipping too shortly doesn't change direction")
	
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
	
	asserts.is_equal(Vector3.ZERO, daedalus.direction)
	
func test_using_icarus_wings():
	describe("Using Icarus' Wings increases Daedalus' speed")
	
	daedalus.use_wings()
	asserts.is_equal(daedalus.WINGS_SPEED, daedalus.speed)
	
func test_using_ancient_greek_food():
	describe("Eating Ancient Greek's Food fills Daedalus' life and prevents it to decrease for some seconds")
	
	daedalus.use_food()
	yield(until_timeout(daedalus.FOOD_FULL_TIME), YIELD)
	asserts.is_equal(daedalus.life, 100)
	
	
	