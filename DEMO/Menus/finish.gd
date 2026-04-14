extends Node

func _game_time_finish(time: int) -> void:
	if time == 0:
		Levelmanager.current_level += 1
		Levelmanager._unlock_level(Levelmanager.current_level)
		var level_to_load: String = Levelmanager._load_level(Levelmanager.current_level)
		if level_to_load == "":
			return
		get_tree().call_deferred("change_scene_to_file", level_to_load)
