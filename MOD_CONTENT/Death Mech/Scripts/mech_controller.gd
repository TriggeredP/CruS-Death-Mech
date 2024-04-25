extends Spatial

var mech
var sensitivity

const jump_velocity = 15

var defSpeed = 10.0
var defAirSpeed = 15.0

onready var maxHealth = get_tree().get_nodes_in_group("MechSpawner")[0].settings.mechHealth

var speed = 10.0
var air_speed = 15.0

var enabled = false

var player

onready var lerpNode = $"%LerpNode"

onready var camera = $"%Camera"
onready var subCamera = $"%SubCamera"

onready var weapons = [
	$"%WeaponA",
	$"%WeaponB"
]

onready var monitorTimer = $"%MonitorTimer"

func _ready():
	sensitivity = ( Global.player.x_mouse_sensitivity * Global.player.player_view.fov / Global.FOV ) * 0.025
	disable()
	
	player = Global.player

func change_health_speed(health):
	speed = defSpeed + clamp(float(maxHealth) / float(health) * 2.0, 1.0, 10.0)
	air_speed = defAirSpeed + clamp(float(maxHealth) / float(health) * 2.0, 1.0, 10.0)

func _input(event):

	player.global_transform = $PlayerHolder.global_transform

	if event is InputEventMouseMotion:
		mech.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		
		lerpNode.rotate_y(-event.relative.x * sensitivity * -0.25)
		lerpNode.rotate_x(-event.relative.y * sensitivity * -0.25)
		
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -75, 75)

	if event is InputEventKey and not event.echo and event.pressed:
		var key = event.scancode

		if key == KEY_R:
			mech.mech_exited()

func _process(delta):
	subCamera.global_transform = camera.global_transform
	
	lerpNode.rotation_degrees.x = clamp(lerp(lerpNode.rotation_degrees.x, 0, delta * 2.0), -30, 30)
	lerpNode.rotation_degrees.y = clamp(lerp(lerpNode.rotation_degrees.y, 0, delta * 2.0), -30, 30)
	lerpNode.rotation_degrees.z = clamp(lerp(lerpNode.rotation_degrees.z, 0, delta * 12.0), -30, 30)

	if Input.is_action_just_pressed("movement_jump") and mech.is_on_floor():
		mech.velocity.y = jump_velocity
		$Jump.play()

	var input_dir = Input.get_vector("movement_right", "movement_left", "movement_backward", "movement_forward")
	var direction = (mech.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if mech.is_on_floor():
		if direction:
			mech.velocity.x = direction.x * speed
			mech.velocity.z = direction.z * speed
		else:
			mech.velocity.x = lerp(mech.velocity.x, direction.x * speed, delta * 12.0)
			mech.velocity.z = lerp(mech.velocity.z, direction.z * speed, delta * 12.0)
	else:
		mech.velocity.x = lerp(mech.velocity.x, direction.x * air_speed, delta * 10.0)
		mech.velocity.z = lerp(mech.velocity.z, direction.z * air_speed, delta * 10.0)

func enable():
	enabled = true
	
	lerpNode.rotation_degrees.x = 0
	lerpNode.rotation_degrees.y = 0
	lerpNode.rotation_degrees.z = 0
	
	set_process_input(true)
	set_process(true)
	
	camera.current = true
	subCamera.current = true
	
	player.player_view.current = false
	
	for weapon in weapons:
		weapon.enable()
	
	monitorTimer.start()

func disable():
	enabled = false
	set_process_input(false)
	set_process(false)
	
	camera.current = false
	subCamera.current = false
	
	player.player_view.current = true
	
	for weapon in weapons:
		weapon.disable()
	
	monitorTimer.stop()

func step():
	if mech.is_on_floor() and abs(mech.velocity.x) + abs(mech.velocity.z) > 0.05:
		$Step.play()
