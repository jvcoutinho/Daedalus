extends KinematicBody

export(float) var speed := 4

# Movement
var direction := Vector3.ZERO
var swipe_initial_position: Vector2

# Items
var using_wings := false

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			swipe_initial_position = event.position
		else:
			var swipe_final_position: Vector2 = event.position
			direction = _calculate_direction(swipe_initial_position, swipe_final_position)

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

func _on_Item_Detector_body_entered(body: Node):
	if body.is_in_group("items"):
		body.queue_free() # Remove from the maze.
		if body.name.begins_with("Wings"):
			using_wings = true
			speed = 6.0