extends Spatial

var rotationSpeed = 0
var enabled = false

export var actionKey = "mouse_1"
export var lookUpVector = Vector3.FORWARD

onready var parent = get_parent()

onready var raycast = $WeaponHolder/MinigunBody/RayCast
onready var Muzzleflash = $WeaponHolder/MinigunBody/Muzzleflash
onready var MinigunTop = $WeaponHolder/MinigunBody/MinigunTop
onready var timer = $WeaponHolder/Timer
onready var shootSound = $WeaponHolder/Shoot

onready var decal = preload("res://Entities/Decals/Decal.tscn")

func _ready():
	Muzzleflash.hide()
	disable()

func _process(delta):
	MinigunTop.rotation.y += rotationSpeed * delta
	
	if rotationSpeed >= 20:
		Muzzleflash.show()
		$Particles.emitting = true
		parent.rotate_y(0.004 * rand_range(-1, 1))
		parent.rotate_x(0.004 * rand_range(-1, 1))
	else:
		Muzzleflash.hide()
		$Particles.emitting = false
	
	if Input.is_action_pressed(actionKey):
		rotationSpeed = clamp(rotationSpeed + 25 * delta, 0, 25)
	else:
		rotationSpeed = lerp(rotationSpeed, 0, delta * 2)

func enable():
	enabled = true
	set_process(true)
	
	timer.start()

func disable():
	enabled = true
	set_process(false)
	Muzzleflash.hide()
	
	timer.stop()

func shoot():
	if rotationSpeed >= 20:
		shootSound.play()
		for i in range(4):
			raycast.rotation = Vector3.ZERO
			raycast.rotation = Vector3(rand_range(-0.05, 0.05), rand_range(-0.05, 0.05), rand_range(-0.05, 0.05))
			
			raycast.force_raycast_update()
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				$Particles.global_transform.origin = raycast.get_collision_point()
				#decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
				if collider.has_method("damage"):
					collider.damage(25, Vector3.ZERO, raycast.get_collision_point(), global_transform.origin)
				if collider.has_method("piercing_damage"):
					collider.piercing_damage(2, Vector3.ZERO, raycast.get_collision_point(), global_transform.origin)

func decal(collider:Spatial, c_point, c_normal)->void :
	if not is_instance_valid(collider):
		return 
	if collider.get_collision_layer_bit(0) == true:
		var decal_new
		decal_new = decal.instance()
		collider.add_child(decal_new)
		decal_new.global_transform.basis = align_up(decal_new.global_transform.basis, c_normal)
		decal_new.global_transform.origin = c_point + c_normal * 1e-08

func align_up(node_basis, normal)->Basis:
	var result = Basis()
	var scale = node_basis.get_scale()

	result.x = normal.cross(node_basis.z) + Vector3(1e-05, 0, 0)
	result.y = normal + Vector3(0, 1e-05, 0)
	result.z = node_basis.x.cross(normal) + Vector3(0, 0, 1e-05)
	
	result = result.orthonormalized()
	result.x *= scale.x
	result.y *= scale.y
	result.z *= scale.z

	return result
