extends Control

var bus_index

# --- 1. RÉFÉRENCES AUX NŒUDS ---
@onready var fond_pingouin: TextureRect = $TextureRect
@onready var fond_gris: ColorRect = $FondGris
@onready var in_menu_controls = $InMenu
@onready var in_game_controls = $InGameBox
@onready var slider_volume = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/SliderVolume
@onready var val_label = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/ValueLabel

# --- 2. ÉTAT DE LA POPUP REMAPPING ---
var key_popup: Control = null
var key_buttons: Dictionary = {}    # action → Button
var action_en_attente: String = ""  # action en cours d'écoute de touche
var _font = null                    # Police Inter Tight Bold

# ============================================================
func _ready():
	bus_index = AudioServer.get_bus_index("Master")
	_font = load("res://Assets/Texte/Inter_Tight/static/InterTight-Bold.ttf")

	if slider_volume:
		var init_vol = AudioServer.get_bus_volume_db(bus_index)
		slider_volume.value = db_to_linear(init_vol)
		val_label.text = str(round(slider_volume.value * 10))

	# --- 3. MODE PAUSE VS MODE MENU PRINCIPAL ---
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

# ============================================================
# --- 4. GESTION DU SON ---
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

# ============================================================
# --- 5. LOGIQUE DES BOUTONS NAVIGATION ---

func _on_play_button_pressed():
	get_tree().paused = false
	if get_tree().current_scene == self:
		LoadingScreen.change_scene("res://UI/main_menu.tscn")
	else:
		get_parent().queue_free()

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	get_parent().queue_free()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	LoadingScreen.change_scene("res://UI/select_level.tscn")

func _on_bouton_valider_pressed():
	LoadingScreen.change_scene("res://UI/select_level.tscn")

func _on_bouton_retour_pressed():
	if get_tree().current_scene == self or get_tree().current_scene.name == "MenuSettings":
		LoadingScreen.change_scene(Levelmanager.scene_retour_settings)
	else:
		get_tree().paused = false
		if get_parent() is CanvasLayer:
			get_parent().queue_free()
		else:
			queue_free()

# ============================================================
# --- 6. POPUP REMAPPING DES TOUCHES ---

func _open_key_config() -> void:
	if key_popup != null and is_instance_valid(key_popup):
		key_popup.visible = true
		_refresh_key_labels()
		return
	_build_key_popup()

func _close_key_config() -> void:
	# Annuler toute écoute en cours
	if action_en_attente != "" and key_buttons.has(action_en_attente):
		_set_btn_waiting(key_buttons[action_en_attente], false)
		action_en_attente = ""
	if key_popup != null and is_instance_valid(key_popup):
		key_popup.visible = false

# --- Affichage du nom propre de la touche (sans "Physical") ---
func _get_key_label(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			var kc = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			if kc != KEY_NONE:
				return OS.get_keycode_string(kc)
			return OS.get_keycode_string(event.physical_keycode)
	return "?"

func _refresh_key_labels() -> void:
	for action in key_buttons:
		if action != action_en_attente:
			key_buttons[action].text = _get_key_label(action)

# --- Écoute de la nouvelle touche ---
func _input(event: InputEvent) -> void:
	if action_en_attente == "":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			_set_btn_waiting(key_buttons[action_en_attente], false)
			action_en_attente = ""
			_refresh_key_labels()
			get_viewport().set_input_as_handled()
			return
		# Appliquer + sauvegarder
		Levelmanager.apply_control(action_en_attente, event.physical_keycode)
		Levelmanager.save_controls(action_en_attente, event.physical_keycode)
		_set_btn_waiting(key_buttons[action_en_attente], false)
		action_en_attente = ""
		_refresh_key_labels()
		get_viewport().set_input_as_handled()

func _on_remap_pressed(action: String) -> void:
	# Réinitialiser le bouton précédent si besoin
	if action_en_attente != "" and key_buttons.has(action_en_attente):
		_set_btn_waiting(key_buttons[action_en_attente], false)
	action_en_attente = action
	_set_btn_waiting(key_buttons[action], true)

func _set_btn_waiting(btn: Button, waiting: bool) -> void:
	if waiting:
		btn.text = "..."
		var s = StyleBoxFlat.new()
		s.bg_color = Color(0.70, 0.44, 0.04, 1)
		s.corner_radius_top_left    = 8
		s.corner_radius_top_right   = 8
		s.corner_radius_bottom_right = 8
		s.corner_radius_bottom_left  = 8
		s.border_width_left  = 2; s.border_width_top    = 2
		s.border_width_right = 2; s.border_width_bottom = 2
		s.border_color = Color(1.0, 0.72, 0.10, 1)
		btn.add_theme_stylebox_override("normal", s)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_color_override("font_color")

# ============================================================
# --- 7. CONSTRUCTION DE LA POPUP (entièrement en code) ---

func _build_key_popup() -> void:
	key_buttons.clear()

	# --- Couche racine (bloque les clics derrière) ---
	key_popup = Control.new()
	key_popup.name = "KeyConfigPopup"
	key_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	key_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(key_popup)

	# --- Fond semi-transparent ---
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.06, 0.80)
	overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	key_popup.add_child(overlay)

	# --- Style du panneau modal ---
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color(0.10, 0.10, 0.18, 0.98)
	ps.border_width_left   = 2; ps.border_width_top    = 2
	ps.border_width_right  = 2; ps.border_width_bottom = 2
	ps.border_color = Color(0.45, 0.45, 0.78, 0.90)
	ps.corner_radius_top_left    = 16; ps.corner_radius_top_right   = 16
	ps.corner_radius_bottom_right = 16; ps.corner_radius_bottom_left = 16
	ps.shadow_color = Color(0, 0, 0, 0.55)
	ps.shadow_size  = 14

	# --- Panneau centré ---
	var panel = Panel.new()
	panel.anchor_left   = 0.5; panel.anchor_top    = 0.5
	panel.anchor_right  = 0.5; panel.anchor_bottom = 0.5
	panel.offset_left  = -210.0; panel.offset_top    = -240.0
	panel.offset_right =  210.0; panel.offset_bottom =  240.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical   = Control.GROW_DIRECTION_BOTH
	panel.add_theme_stylebox_override("panel", ps)
	key_popup.add_child(panel)

	# --- Marges internes ---
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   26)
	margin.add_theme_constant_override("margin_right",  26)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	# --- Contenu vertical ---
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	# Titre
	_popup_label(vbox, "⌨️  Configurer les touches", 27, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER)

	# Aide
	var help = _popup_label(vbox, "Cliquez sur un bouton puis appuyez sur la touche voulue  •  Échap pour annuler", 13, Color(0.62, 0.62, 0.80, 1), HORIZONTAL_ALIGNMENT_CENTER)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	vbox.add_child(HSeparator.new())

	# Grille 2 colonnes : label | bouton
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	var actions_data = [
		["bleu",   "🔵  Bleu"],
		["jaune",  "🟡  Jaune"],
		["vert",   "🟢  Vert"],
		["marron", "🟤  Marron"],
	]

	for ad in actions_data:
		var lbl = _popup_label(grid, ad[1], 21, Color(0.90, 0.90, 0.95), HORIZONTAL_ALIGNMENT_LEFT)
		lbl.custom_minimum_size = Vector2(145, 0)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var btn = _make_key_btn(ad[0])
		grid.add_child(btn)
		key_buttons[ad[0]] = btn

	vbox.add_child(HSeparator.new())

	# Bouton Fermer
	var close_btn = _make_close_btn()
	vbox.add_child(close_btn)

# --- Helpers de construction ---

func _popup_label(parent: Node, txt: String, size: int, color: Color, align: int) -> Label:
	var lbl = Label.new()
	lbl.text = txt
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = align
	if _font:
		lbl.add_theme_font_override("font", _font)
	parent.add_child(lbl)
	return lbl

func _make_key_btn(action: String) -> Button:
	var btn = Button.new()
	btn.text = _get_key_label(action)
	btn.custom_minimum_size = Vector2(110, 40)
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

	# Style normal
	var ns = StyleBoxFlat.new()
	ns.bg_color = Color(0.20, 0.20, 0.36, 1)
	ns.corner_radius_top_left    = 8; ns.corner_radius_top_right   = 8
	ns.corner_radius_bottom_right = 8; ns.corner_radius_bottom_left = 8
	ns.border_width_left  = 1; ns.border_width_top    = 1
	ns.border_width_right = 1; ns.border_width_bottom = 1
	ns.border_color = Color(0.45, 0.45, 0.70, 0.8)
	btn.add_theme_stylebox_override("normal", ns)

	# Style hover
	var hs = StyleBoxFlat.new()
	hs.bg_color = Color(0.30, 0.30, 0.52, 1)
	hs.corner_radius_top_left    = 8; hs.corner_radius_top_right   = 8
	hs.corner_radius_bottom_right = 8; hs.corner_radius_bottom_left = 8
	btn.add_theme_stylebox_override("hover", hs)

	btn.pressed.connect(_on_remap_pressed.bind(action))
	return btn

func _make_close_btn() -> Button:
	var btn = Button.new()
	btn.text = "✓  Fermer"
	btn.custom_minimum_size = Vector2(130, 44)
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 21)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

	var ns = StyleBoxFlat.new()
	ns.bg_color = Color(0.12, 0.42, 0.20, 1)
	ns.corner_radius_top_left    = 10; ns.corner_radius_top_right   = 10
	ns.corner_radius_bottom_right = 10; ns.corner_radius_bottom_left = 10
	ns.border_width_left  = 1; ns.border_width_top    = 1
	ns.border_width_right = 1; ns.border_width_bottom = 1
	ns.border_color = Color(0.22, 0.80, 0.34, 0.6)
	btn.add_theme_stylebox_override("normal", ns)

	var hs = StyleBoxFlat.new()
	hs.bg_color = Color(0.17, 0.58, 0.28, 1)
	hs.corner_radius_top_left    = 10; hs.corner_radius_top_right   = 10
	hs.corner_radius_bottom_right = 10; hs.corner_radius_bottom_left = 10
	btn.add_theme_stylebox_override("hover", hs)

	btn.pressed.connect(_close_key_config)
	return btn

# ============================================================
# --- 8. EFFETS DE SURVOL ---

func _on_bouton_retour_mouse_entered():
	$InMenu/InMenuRetourBox/BoutonRetour.modulate = Color("b2b2b2ff")
func _on_bouton_retour_mouse_exited():
	$InMenu/InMenuRetourBox/BoutonRetour.modulate = Color("ffffffff")

func _on_bouton_valider_mouse_entered():
	$InMenu/InMenuLevelBox/BoutonValider.modulate = Color("b2b2b2ff")
func _on_bouton_valider_mouse_exited():
	$InMenu/InMenuLevelBox/BoutonValider.modulate = Color("ffffffff")

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
