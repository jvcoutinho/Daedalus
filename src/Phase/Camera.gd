extends Camera

var target: Spatial = null

func _process(_delta):
	if target != null:
		translation = Vector3(target.translation.x, translation.y, target.translation.z + 2.5)
