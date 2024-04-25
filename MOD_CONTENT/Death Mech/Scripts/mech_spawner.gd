extends Node

var settings = {
	"mechRentCost": 2500,
	"mechLostCost": 45000,
	"mechBind": KEY_T,
	"mechHealth": 2000
}

func _ready():
	if not load_data():
		save_data()

func _input(event):
	if event is InputEventKey and not event.echo and event.pressed:
		var key = event.scancode

		if key == settings.mechBind:
			if Global.player.health == null:
				print("[ Death mech ]: player didn't exist")
			else:
				if(Global.money < settings.mechRentCost):
					Global.player.UI.notify("You don't have enough money (" + str(settings.mechRentCost) + "$)", Color.red)
				else:
					var grenade = load("res://MOD_CONTENT/Death Mech/Scenes/mech_grenade.tscn").instance()
					Global.player.get_parent().add_child(grenade)
					Global.player.UI.notify("You paid " + str(settings.mechRentCost) + "$ for mech rent", Color.red)
					Global.money -= settings.mechRentCost
					Global.save_game()
					grenade.global_transform.origin = Global.player.global_transform.origin + Vector3(0,1.5,0) + (Global.player.global_transform.origin - Global.player.front_pos_helper.global_transform.origin).normalized() * -1
					grenade.linear_velocity = Global.player.player_velocity + (Global.player.global_transform.origin - Global.player.front_pos_helper.global_transform.origin).normalized() * -10

func save_data():
	var dir = Directory.new()
	if not dir.dir_exists("user://mod_config/"):
		dir.make_dir("user://mod_config/")
	
	var mod_config = File.new()
	mod_config.open("user://mod_config/DeathMech.save", File.WRITE)
	mod_config.store_line(to_json(settings))
	mod_config.close()
	
	print("[Death mech]: Saved")

func load_data() -> bool:
	var dir = Directory.new()
	if not dir.dir_exists("user://mod_config/"):
		dir.make_dir("user://mod_config/")

	var file = File.new()
	if file.file_exists("user://mod_config/DeathMech.save"):
		file.open("user://mod_config/DeathMech.save", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			settings = data
			
			print("[Death mech]: Loaded")
			return true
		else:
			printerr("[Death mech]: Corrupted data!")
			return false
	else:
		printerr("[Death mech]: No saved data!")
		return false
