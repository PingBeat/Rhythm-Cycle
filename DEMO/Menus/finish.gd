extends Node

func _game_time_finish(time: int) -> void:
	if time == 0:
		Levelmanager.current_level += 1
		Levelmanager._unlock_level(Levelmanager.current_level)
		var level_to_load: String = Levelmanager._load_level(Levelmanager.current_level)
		if level_to_load == "":
			return
		LoadingScreen.call_deferred("change_scene", level_to_load)
