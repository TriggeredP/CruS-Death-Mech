extends Area

# I hate this fucking script - TriggeredP
var enabled = false

var original_camera

func _process(delta):
	if $Camera.current and enabled:
		$Camera.look_at(Global.player.global_transform.origin + Vector3.UP, Vector3.UP)

func _on_Area_body_entered(body):
	if enabled:
		$Camera.current = true
		$Camera / Weapon.disabled = false
		$Camera / Weapon.show()
		$Camera / Weapon.current_weapon = 6
		$Camera / Weapon.damage[6] = 200
		$Camera / Weapon / RayCast.set_collision_mask_bit(1, 1)
		Global.player.rotation_helper.hide()
		Global.player.weapon.disabled = true

func _on_Area_body_exited(body):
	if enabled:
		$Camera.current = false
		$Camera / Weapon.disabled = true
		$Camera / Weapon.hide()
		$Camera / Weapon / RayCast.set_collision_mask_bit(1, 1)
		Global.player.rotation_helper.show()
		Global.player.weapon.disabled = false
