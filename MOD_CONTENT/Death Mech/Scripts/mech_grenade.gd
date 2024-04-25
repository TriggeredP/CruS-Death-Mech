extends RigidBody

var flash_max = 15
var flash = 0

func flash_toggle():
	$Flash.visible = !$Flash.visible
	
	if $Flash.visible:
		$FlashSound.play()
		$FlashSound.pitch_scale += 0.2
		flash += 1
		if $Timer.wait_time >= 0.1:
			$Timer.wait_time -= 0.05
	
	if flash >= flash_max:
		$DestroySound.play()
		$Grenade.visible = false
		$Flash.visible = false
		$Timer.stop()
		
		var mech = load("res://MOD_CONTENT/Death Mech/Scenes/mech.tscn").instance()
		get_parent().add_child(mech)
		mech.global_transform.origin = global_transform.origin
		
		mech.look_at(Global.player.global_transform.origin, Vector3.UP)
		
		mech.rotation.x = 0
		mech.rotation.z = 0
		
		mech.rotation_degrees.y += 180
