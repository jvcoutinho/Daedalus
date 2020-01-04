extends CSGSphere

export(float) var speed = 4

func _physics_process(delta):
	var direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		direction = Vector3.FORWARD
	elif Input.is_key_pressed(KEY_D):
		direction = Vector3.RIGHT
	elif Input.is_key_pressed(KEY_S):
		direction = Vector3.BACK
	elif Input.is_key_pressed(KEY_A):
		direction = Vector3.LEFT
	
	translation += direction * speed * delta
