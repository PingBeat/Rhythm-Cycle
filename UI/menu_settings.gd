extends Control

var bus_index

# --- 1. DÉCLARATION DES ÉLÉMENTS ---
@onready var fond_pingouin: TextureRect = $TextureRect
@onready var fond_gris: ColorRect = $FondGris
@onready var in_menu_controls = $InMenu
@onready var in_game_controls = $InGameBox
@onready var slider_volume = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/SliderVolume
@onready var val_label = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/ValueLabel

func _ready():
	bus_index = AudioServer.get_bus_index("Master")
	
	if slider_volume:
		var init_vol = AudioServer.get_bus_volume_db(bus_index)
		slider_volume.value = db_to_linear(init_vol)
		val_label.text = str(round(slider_volume.value * 10))
	
	# --- 2. MODE PAUSE VS MODE MENU PRINCIPAL ---
	if get_tree().current_scene == self:
		fond_pingouin.visible = true
		fond_gris.visible = false
		in_game_controls.visible = false
		in_menu_controls.visible = true
	else:
		fond_pingouin.visible = false
		fond_gris.visible = true
		in_game_controls.visible = true
		in_menu_controls.visible = false

# --- 3. GESTION DU SON ---
func _on_slider_volume_value_changed(value):
	val_label.text = str(round(value * 10))
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Levelmanager.save_settings(value)
	AudioServer.set_bus_mute(bus_index, value <= 0.001)

func _on_check_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# --- 4. LOGIQUE DES BOUTONS (PAUSE ET MENU) ---

# Bouton "Reprendre" (en jeu) ou "Retour" (menu)
func _on_play_button_pressed():
	get_tree().paused = false
	if get_tree().current_scene == self:
		LoadingScreen.change_scene("res://UI/main_menu.tscn")
	else:
		# On supprime le CanvasLayer qui contient ce menu
		get_parent().queue_free()

# Bouton "Réessayer" (en jeu)
func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	get_parent().queue_free()

# Bouton "Niveaux / Menu" (en jeu)
func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	LoadingScreen.change_scene("res://UI/select_level.tscn")

# Bouton "Valider" (quand on est dans le menu principal)
func _on_bouton_valider_pressed():
	LoadingScreen.change_scene("res://UI/select_level.tscn")

func _on_bouton_retour_pressed():
	# Si on est dans la scène des paramètres (hors jeu)
	if get_tree().current_scene == self or get_tree().current_scene.name == "MenuSettings":
		LoadingScreen.change_scene(Levelmanager.scene_retour_settings)
	else:
		# Si on est EN JEU (Pause), on ferme juste le menu
		get_tree().paused = false
		if get_parent() is CanvasLayer:
			get_parent().queue_free()
		else:
			queue_free()

# --- 5. EFFETS DE SURVOL (INDIVIDUELS) ---

# --- Boutons du Menu Principal ---
func _on_bouton_retour_mouse_entered():
	$InMenu/InMenuRetourBox/BoutonRetour.modulate = Color("b2b2b2ff")
func _on_bouton_retour_mouse_exited():
	$InMenu/InMenuRetourBox/BoutonRetour.modulate = Color("ffffffff")

func _on_bouton_valider_mouse_entered():
	$InMenu/InMenuLevelBox/BoutonValider.modulate = Color("b2b2b2ff")
func _on_bouton_valider_mouse_exited():
	$InMenu/InMenuLevelBox/BoutonValider.modulate = Color("ffffffff")

# --- Boutons de la Pause (In Game) ---
func _on_menu_button_mouse_entered():
	$InGameBox/BoxNiv/Menu_Button.modulate = Color("b2b2b2ff")
func _on_menu_button_mouse_exited():
	$InGameBox/BoxNiv/Menu_Button.modulate = Color("ffffffff")

func _on_play_button_mouse_entered():
	$InGameBox/BoxSuivant/Play_Button.modulate = Color("b2b2b2ff")
func _on_play_button_mouse_exited():
	$InGameBox/BoxSuivant/Play_Button.modulate = Color("ffffffff")

func _on_retry_button_mouse_entered():
	$InGameBox/BoxRetry/Retry_Button.modulate = Color("b2b2b2ff")
func _on_retry_button_mouse_exited():
	$InGameBox/BoxRetry/Retry_Button.modulate = Color("ffffffff")
