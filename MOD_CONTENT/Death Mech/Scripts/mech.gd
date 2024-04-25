extends KinematicBody

var velocity = Vector3.ZERO
const gravity = 9.8

var player

onready var health = get_tree().get_nodes_in_group("MechSpawner")[0].settings.mechHealth

signal health_changed(health)

var canTakeDamage = false
var death = false

func _ready():
	$crus_mech/MechModel/Skeleton/BoneAttachment7/Mech/Collision.parent = self
	$MechController.mech = self
	player = Global.player
	
	emit_signal("health_changed", health)

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if is_on_floor() and not $MechController.enabled:
		velocity.x = lerp(velocity.x, 0.0, delta * 12.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 12.0)
	
	move_and_slide(velocity, Vector3.UP)

func mech_entered():
	if not death:
		$MechController.enable()
		$crus_mech.hide()
		$MechController.show()
		
		$crus_mech/MechModel/Skeleton/BoneAttachment7/Mech/Collision.set_collision_layer_bit(8,false)
		Global.player.grab_hand.hide()
		
		player.set_process(false)
		player.set_physics_process(false)
		player.set_process_input(false)
		player.weapon.set_process(false)
		player.weapon.hide()
		player.hide()
		
		player.damageTaker = self

func mech_exited():
	$MechController.disable()
	$crus_mech.show()
	$MechController.hide()
	
	$crus_mech/MechModel/Skeleton/BoneAttachment7/Mech/Collision.set_collision_layer_bit(8,true)
	
	player.set_process(true)
	player.set_physics_process(true)
	player.set_process_input(true)
	player.weapon.set_process(true)
	player.weapon.show()
	player.show()
	
	player.damageTaker = null
	
	player.global_transform.origin = global_transform.origin + Vector3(0,4,0)
	player.global_rotation = global_rotation
	player.player_velocity = velocity
	
	if death:
		$crus_mech/MechModel/Skeleton/BoneAttachment7/Mech/Collision.set_collision_layer_bit(8,false)
		$AnimationController.play("Explosion")

func enable_damage():
	canTakeDamage = true

func disable_damage():
	canTakeDamage = false

func damage(damage, collision_n, collision_p, shooter_pos):
	if canTakeDamage:
		if damage >= 1000:
			if not player.visible:
				mech_exited()
			$AnimationController.play("InstaExplosion")
		else:
			health -= damage
			$Damage.play()
			if health <= 0:
				health = 0
				disable_damage()
				mech_death()
			emit_signal("health_changed", health)

func mech_death():
	death = true
	var lostCost = get_tree().get_nodes_in_group("MechSpawner")[0].settings.mechLostCost
	Global.player.UI.notify("You paid " + str(lostCost) + "$ for mech lost", Color.red)
	Global.money -= lostCost
	Global.save_game()
	$MechController/Camera/LerpNode/Explosion.start_explosion()

func destroy():
	if not player.visible:
		mech_exited()
		$AnimationController.play("InstaExplosion")

func delete():
	queue_free()
