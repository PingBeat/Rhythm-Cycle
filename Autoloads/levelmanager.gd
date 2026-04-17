extends Node

var current_level: int = 1
var level_unlocked: int = 3 
var max_level: int = 3

func _unlock_level(level_to_unlock: int) -> void:
	if level_to_unlock > level_unlocked:
		level_unlocked = level_to_unlock

func _load_level(level_to_load: int) -> String:
	if level_to_load > max_level:
		return "" # Plus de niveaux, on retournera au menu
		
	# On convertit le numéro du niveau en texte pour créer le chemin
	# Exemple: si level_to_load est 2, ça donnera "res://Levels/2.tscn"
	return "res://Levels/" + str(level_to_load) + ".tscn"

var save_path = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	load_settings()

func save_settings(value):
	config.set_value("audio", "master_volume", value)
	config.save(save_path)

func load_settings():
	var err = config.load(save_path)
	var vol = 1.0
	if err == OK: 
		vol = config.get_value("audio", "master_volume", 1.0)
	
	# On applique le volume au bus Master
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol))
	
	if vol <= 0.001:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
