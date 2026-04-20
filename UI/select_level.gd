extends Control

@onready var office_btn := $TVContainer/LevelsBox/OfficeCycleButton
@onready var beach_btn := $TVContainer/LevelsBox/BeachCycleButton
@onready var coffee_btn := $TVContainer/LevelsBox/CoffeeCycleButton
@onready var btn_retour := $BottomBar/RetourBox/BtnRetour
@onready var btn_settings := $BottomBar/SettingsBox/BtnSettings

func _ready() -> void:
	# Connect level button
	office_btn.pressed.connect(_on_office_pressed)
	beach_btn.pressed.connect(_on_beach_pressed)
	coffee_btn.pressed.connect(_on_coffee_pressed)
	
	# Hover effects for level button
	office_btn.mouse_entered.connect(_on_button_hover.bind(office_btn))
	office_btn.mouse_exited.connect(_on_button_exit.bind(office_btn))
	beach_btn.mouse_entered.connect(_on_button_hover.bind(beach_btn))
	beach_btn.mouse_exited.connect(_on_button_exit.bind(beach_btn))
	coffee_btn.mouse_entered.connect(_on_button_hover.bind(coffee_btn))
	coffee_btn.mouse_exited.connect(_on_button_exit.bind(coffee_btn))

	# Connect bottom bar buttons
	btn_retour.pressed.connect(_on_retour_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)

	btn_retour.mouse_entered.connect(_on_bottom_hover.bind(btn_retour))
	btn_retour.mouse_exited.connect(_on_bottom_exit.bind(btn_retour))
	btn_settings.mouse_entered.connect(_on_bottom_hover.bind(btn_settings))
	btn_settings.mouse_exited.connect(_on_bottom_exit.bind(btn_settings))
	
	Levelmanager.scene_retour_settings = "res://UI/select_level.tscn"

func _on_office_pressed() -> void:
	Levelmanager.current_level = 2
	LoadingScreen.call_deferred("change_scene", Levelmanager._load_level(2))

func _on_beach_pressed() -> void:
	Levelmanager.current_level = 3
	LoadingScreen.call_deferred("change_scene", Levelmanager._load_level(3))

func _on_coffee_pressed() -> void:
	Levelmanager.current_level = 1
	LoadingScreen.call_deferred("change_scene", Levelmanager._load_level(1))

func _on_retour_pressed() -> void:
	LoadingScreen.change_scene("res://UI/main_menu.tscn")

func _on_settings_pressed() -> void:
	LoadingScreen.change_scene("res://UI/menu_settings.tscn")

# Hover effects (optional, if you want visual feedback)
func _on_button_hover(btn: Button) -> void:
	btn.modulate = Color("e0e0e0")

func _on_button_exit(btn: Button) -> void:
	btn.modulate = Color("ffffff")

func _on_bottom_hover(btn: Button) -> void:
	btn.modulate = Color("b2b2b2")

func _on_bottom_exit(btn: Button) -> void:
	btn.modulate = Color("ffffff")




func _on_bottom_bar_mouse_entered() -> void:
	$BottomBar/RetourBox/BtnRetour.modulate = Color("b2b2b2ff")
	$BottomBar/SettingsBox/BtnSettings.modulate = Color("b2b2b2ff")


func _on_bottom_bar_mouse_exited() -> void:
	$BottomBar/RetourBox/BtnRetour.modulate = Color("fff")
	$BottomBar/SettingsBox/BtnSettings.modulate = Color("fff")
