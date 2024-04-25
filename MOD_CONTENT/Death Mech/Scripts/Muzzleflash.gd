extends Spatial

func _physics_process(delta):
	if not visible:
		return 
	rotation.y = rand_range( - PI, PI)
