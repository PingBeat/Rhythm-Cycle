extends Node

var current_level: int = 1
var level_unlocked: int = 1
var max_level: int = 4

func _unlock_level(level_to_unlock: int) -> void:
	if level_to_unlock > level_unlocked:
		level_unlocked = level_to_unlock

func _load_level(level_to_load: int) -> String:
	if level_to_load > max_level:
		return ""
	return str("res://Levels/game.tscn")

var save_path = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	load_settings()

func save_settings(value):
	config.set_value("audio", "master_volume", value)
	config.save(save_path)

func load_settings():
	var err = config.load(save_path)
	if err != OK: return # Si le fichier n'existe pas encore
	
	var vol = config.get_value("audio", "master_volume", 1.0)
	# On applique le volume au bus Master
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol))
