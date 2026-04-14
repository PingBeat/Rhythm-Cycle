extends Control

var bus_index

func _ready():
	# On repère le canal "Master" (le son général)
	bus_index = AudioServer.get_bus_index("Master")

# Cette fonction gère le volume
func _on_slider_volume_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	if value == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

# Cette fonction gère le plein écran
func _on_check_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Cette fonction gère le bouton retour
func _on_bouton_retour_pressed():
	# Si on a ouvert le menu depuis le menu principal
	if get_tree().current_scene == self:
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
	else:
		# Si on l'a ouvert par-dessus le jeu :
		get_tree().paused = false
		# On détruit le parent (la vitre CanvasLayer) pour tout faire disparaître
		get_parent().queue_free()
