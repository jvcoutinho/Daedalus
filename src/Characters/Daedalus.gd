extends CSGSphere

export(float) var speed := 4

var direction := Vector3.ZERO
var swipe_initial_position: Vector2

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			swipe_initial_position = event.position
		else:
			var swipe_final_position: Vector2 = event.position
			direction = _calculate_direction(swipe_initial_position, swipe_final_position)

func _physics_process(delta):
	translation += direction * speed * delta
	
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