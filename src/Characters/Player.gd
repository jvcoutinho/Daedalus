extends KinematicBody

signal used_ink(player_position, wall, color)
signal used_fire(player_position)
signal used_axe(player_position, wall)

const REGULAR_SPEED: float = 3.0 # Pixels/second
const WINGS_SPEED: float = 5.0
const SWIPE_MINIMUM_LENGTH: float = 20.0
const REGULAR_LIFE_DECAIMENT: float = 1.0
const FOOD_FULL_TIME: float = 5.0

# Movement
var speed := REGULAR_SPEED
var direction := Vector3.ZERO
var swipe_initial_position: Vector2
var swipe_final_position: Vector2
var swipping := false

# Life
var life: float = 100.0
var life_decaiment := REGULAR_LIFE_DECAIMENT

func _input(event):
	"""
	Implements swipe.
	"""
	if event is InputEventScreenTouch:
		if event.is_pressed() and not swipping: # Touching.
			swipe_initial_position = event.position
			swipe_final_position = swipe_initial_position
			swipping = true
		elif not event.is_pressed() and swipping: # Releasing touch.
			var swipe = swipe_final_position - swipe_initial_position
			if swipe.length() > SWIPE_MINIMUM_LENGTH:
				direction = _calculate_direction(swipe)
			swipping = false
	elif event is InputEventScreenDrag and swipping: # Swipping.
		swipe_final_position = event.position + event.relative
	
func _physics_process(delta):
	var _collision := move_and_collide(direction * speed * delta)
	
func _process(delta):
	life -= life_decaiment * delta

func _calculate_direction(swipe: Vector2) -> Vector3:
	var direction = swipe.normalized()
	
	if direction.length() == 0:
		return Vector3.ZERO
		
	# Horizontal swipe
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			return Vector3.RIGHT
		else:
			return Vector3.LEFT
	# Vertical swipe
	else:
		if direction.y > 0:
			return Vector3.BACK
		else:
			return Vector3.FORWARD
			
func use_wings():
	speed = WINGS_SPEED
	
func use_food():
	life = 100
	life_decaiment = 0
	yield(get_tree().create_timer(FOOD_FULL_TIME), "timeout")
	life_decaiment = REGULAR_LIFE_DECAIMENT
	
func use_ink(wall: String, color: Color):
	emit_signal("used_ink", translation, wall, color)
	
func use_fire():
	emit_signal("used_fire", translation)
	
func use_axe(wall: String):
	emit_signal("used_axe", translation, wall)

func _on_Item_Detector_body_entered(body: Node):
	if body.is_in_group("items"):
		body.queue_free() # Remove from the maze.
		if body.name.begins_with("Wings"):
			use_wings()