extends Control

var bus_index

# --- 1. DÉCLARATION DES ÉLÉMENTS VISUELS ---
@onready var fond_pingouin: TextureRect = $TextureRect
@onready var fond_gris: ColorRect = $FondGris
@onready var panel_container = $PanelContainer
@onready var pause_controls = $PanelContainer/MarginContainer/BoitePrincipale/PauseControls
@onready var universal_settings = $PanelContainer/MarginContainer/BoitePrincipale/UniversalSettings
@onready var slider_volume = $PanelContainer/MarginContainer/BoitePrincipale/UniversalSettings/SliderVolume

func _ready():
	# On repère le canal "Master" (le son général)
	bus_index = AudioServer.get_bus_index("Master")
	
	# Initialiser le slider à la valeur sauvegardée
	if slider_volume:
		slider_volume.set_value_no_signal(Levelmanager.config.get_value("audio", "master_volume", 0.8))
	
	# Sécurité : On s'assure que le menu central n'est pas caché
	panel_container.visible = true
	
	# --- 2. GESTION DU MODE PAUSE VS MODE MENU PRINCIPAL ---
	if get_tree().current_scene == self:
		# On est dans le Main Menu : 
		fond_pingouin.visible = true
		fond_gris.visible = false
		pause_controls.visible = false     # On cache les boutons Restart/Exit
		universal_settings.visible = true  # On affiche le Volume/Plein écran
	else:
		# On est en PAUSE dans le jeu : 
		fond_pingouin.visible = false
		fond_gris.visible = true
		pause_controls.visible = true      # On affiche les boutons Restart/Exit
		universal_settings.visible = true  # On garde le Volume/Plein écran affiché

# --- 3. FERMER AVEC ÉCHAP ---
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_bouton_retour_pressed()

# --- 4. GESTION DU SON ET AFFICHAGE ---
func _on_slider_volume_value_changed(value):
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
