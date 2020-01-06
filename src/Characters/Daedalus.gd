extends KinematicBody

export(float) var regular_speed: float = 3.0 # Pixels/second
export(float) var wings_speed: float = 5.0
var speed := regular_speed

# Movement
var direction := Vector3.ZERO
var swipe_initial_position: Vector2
var swipe_final_position: Vector2
var swipping := false

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
			direction = _calculate_direction(swipe_initial_position, swipe_final_position)
			swipping = false
	elif event is InputEventScreenDrag and swipping: # Swipping.
		swipe_final_position += event.relative

func _physics_process(delta):
	move_and_collide(direction * speed * delta)

func _calculate_direction(initial: Vector2, final: Vector2) -> Vector3:
	var direction = (final - initial).normalized()
	
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
			
func uses_wings():
	speed = wings_speed

func _on_Item_Detector_body_entered(body: Node):
	if body.is_in_group("items"):
		body.queue_free() # Remove from the maze.
		if body.name.begins_with("Wings"):
			uses_wings()