extends Control

var bus_index

# --- 1. DÉCLARATION DES ÉLÉMENTS VISUELS ---
@onready var fond_pingouin: TextureRect = $TextureRect
@onready var fond_gris: ColorRect = $FondGris
@onready var tv_color = $TVColor
@onready var in_menu_controls = $InMenu
@onready var in_game_controls = $InGameBox
@onready var slider_volume = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/SliderVolume
@onready var val_label = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/ValueLabel

func _ready():
	bus_index = AudioServer.get_bus_index("Master")
	
	if slider_volume:
		var init_vol = Levelmanager.config.get_value("audio", "master_volume", 0.8)
		slider_volume.set_value_no_signal(init_vol)
		val_label.text = str(round(init_vol * 10))
	
	# --- 2. GESTION DU MODE PAUSE VS MODE MENU PRINCIPAL ---
	if get_tree().current_scene == self:
		fond_pingouin.visible = true
		fond_gris.visible = false
		in_game_controls.visible = false
		in_menu_controls.visible = true
	else:
		fond_pingouin.visible = false
		fond_gris.visible = true
		in_game_controls.visible = true
		# On cache les boutons tv stand si on est en jeu
		in_menu_controls.visible = false

# --- 3. FERMER AVEC ÉCHAP ---
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_bouton_retour_pressed()

# --- 4. GESTION DU SON ET AFFICHAGE ---
func _on_slider_volume_value_changed(value):
	val_label.text = str(round(value * 10))
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Levelmanager.save_settings(value)
	
	if value == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

func _on_check_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# --- 5. LES BOUTONS ---
func _on_bouton_retour_pressed():
	if get_tree().current_scene == self:
		# Retour sans rien valider, on remet au volume d'avant si on voulait
		LoadingScreen.change_scene("res://UI/main_menu.tscn")
	else:
		get_tree().paused = false
		get_parent().queue_free()

func _on_bouton_valider_pressed():
	# Bouton Valider du menu d'accueil
	if get_tree().current_scene == self:
		LoadingScreen.change_scene("res://UI/main_menu.tscn")
	else:
		get_tree().paused = false
		get_parent().queue_free()

func _on_bouton_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	get_parent().queue_free()

func _on_bouton_exit_pressed() -> void:
	get_tree().paused = false
	LoadingScreen.change_scene("res://UI/main_menu.tscn")

func _on_in_menu_mouse_entered() -> void:
	$InMenu/InMenuRetourBox/BoutonRetour.modulate = Color("b2b2b2ff")
	$InMenu/InMenuLevelBox/BoutonValider.modulate = Color("b2b2b2ff")


func _on_in_menu_mouse_exited() -> void:
	$InMenu/InMenuLevelBox/BoutonValider.modulate = Color("fff")
	$InMenu/InMenuRetourBox/BoutonRetour.modulate = Color("fff")


func _on_in_game_box_mouse_entered() -> void:
	$InGameBox/BoxNiv/Menu_Button.modulate = Color("b2b2b2ff")
	$InGameBox/BoxSuivant/Play_Button.modulate = Color("b2b2b2ff")
	$InGameBox/BoxRetry/Retry_Button.modulate = Color("b2b2b2ff")

func _on_in_game_box_mouse_exited() -> void:
	$InGameBox/BoxNiv/Menu_Button.modulate = Color("b2b2b2ff")
	$InGameBox/BoxSuivant/Play_Button.modulate = Color("b2b2b2ff")
	$InGameBox/BoxRetry/Retry_Button.modulate = Color("b2b2b2ff")
