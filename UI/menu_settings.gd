extends Control

# L'index du bus audio "Master" dans le système audio de Godot.
# On le stocke ici pour ne pas avoir à le recalculer à chaque appel.
var bus_index

# ============================================================
# --- 1. RÉFÉRENCES AUX NŒUDS ---
# @onready = Godot va chercher ces nœuds automatiquement dès que la scène est prête.
# Le $ est un raccourci pour get_node("...").
# ============================================================

@onready var fond_pingouin: TextureRect = $TextureRect          # Image de fond (mode menu principal)
@onready var fond_gris: ColorRect = $FondGris                   # Fond semi-transparent sombre (mode pause)
@onready var in_menu_controls = $InMenu                         # Groupe de boutons affiché DEPUIS le menu principal
@onready var in_game_controls = $InGameBox                      # Groupe de boutons affiché EN JEU (pause)
@onready var slider_volume = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/SliderVolume  # Slider de volume
@onready var val_label = $TVColor/TVContent/UniversalSettings/VolumeRow/SliderBox/ValueLabel        # Label "0" à "10"

# ============================================================
# --- 2. ÉTAT DE LA POPUP REMAPPING ---
# Ces variables gèrent la fenêtre de reconfiguration des touches.
# ============================================================

var key_popup: Control = null       # Référence à la popup une fois construite (null = pas encore créée)
var key_buttons: Dictionary = {}    # Dictionnaire qui associe chaque action à son bouton : { "bleu": Button, ... }
var action_en_attente: String = ""  # Nom de l'action dont on attend la nouvelle touche ("" = aucune)
var _font = null                    # Police Inter Tight Bold (chargée une fois dans _ready et réutilisée partout)

# ============================================================
func _ready():
	# Récupère l'index du bus audio nommé "Master" pour pouvoir modifier son volume ensuite
	bus_index = AudioServer.get_bus_index("Master")

	# Charge la police bold personnalisée depuis les assets du projet
	_font = load("res://Assets/Texte/Inter_Tight/static/InterTight-Bold.ttf")

	# Initialise le slider au volume actuellement appliqué dans le moteur audio.
	# AudioServer retourne le volume en décibels (dB), mais le slider attend une valeur linéaire (0.0 à 1.0).
	# db_to_linear() fait cette conversion.
	if slider_volume:
		var init_vol = AudioServer.get_bus_volume_db(bus_index)
		slider_volume.value = db_to_linear(init_vol)
		# Affiche la valeur arrondie sur une échelle de 0 à 10 (plus lisible pour l'utilisateur)
		val_label.text = str(round(slider_volume.value * 10))

	# --- 3. MODE PAUSE VS MODE MENU PRINCIPAL ---
	# Ce menu est réutilisé dans deux contextes différents :
	#   - Ouvert depuis le menu principal → il EST la scène courante
	#   - Ouvert pendant une partie (pause) → il est ajouté par-dessus la scène de jeu
	# On adapte l'affichage selon le cas.
	if get_tree().current_scene == self:
		# Contexte menu principal : fond décoratif visible, boutons de pause cachés
		fond_pingouin.visible = true
		fond_gris.visible = false
		in_game_controls.visible = false
		in_menu_controls.visible = true
	else:
		# Contexte pause en jeu : fond semi-transparent, boutons de jeu visibles
		fond_pingouin.visible = false
		fond_gris.visible = true
		in_game_controls.visible = true
		in_menu_controls.visible = false

# ============================================================
# --- 4. GESTION DU SON ---
# ============================================================

# Appelé automatiquement chaque fois que le slider bouge.
# 'value' est la valeur du slider : un float entre 0.0 (silence) et 1.0 (max).
func _on_slider_volume_value_changed(value):
	# Met à jour l'affichage textuel (on affiche 0-10 au lieu de 0.0-1.0)
	val_label.text = str(round(value * 10))

	# Applique le volume au bus audio Master.
	# linear_to_db() convertit la valeur linéaire en décibels (requis par Godot).
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

	# Sauvegarde la valeur dans le fichier settings.cfg via le Levelmanager
	Levelmanager.save_settings(value)

	# Si le volume est quasi nul, on coupe carrément l'audio (mute).
	# Écriture condensée équivalente à : if value <= 0.001 → mute = true, sinon false
	AudioServer.set_bus_mute(bus_index, value <= 0.001)

# Appelé quand la case "Plein écran" est cochée ou décochée.
func _on_check_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# ============================================================
# --- 5. LOGIQUE DES BOUTONS NAVIGATION ---
# ============================================================

# Bouton "Reprendre" (en mode pause) OU bouton retour vers menu principal (si on est dans le menu)
func _on_play_button_pressed():
	get_tree().paused = false  # Toujours démettre en pause avant de changer de scène
	if get_tree().current_scene == self:
		# On est dans le menu principal → on va au menu principal
		LoadingScreen.change_scene("res://UI/main_menu.tscn")
	else:
		# On est en overlay (pause) → on détruit juste ce panneau, le jeu reprend
		get_parent().queue_free()

# Bouton "Recommencer" : recharge entièrement la scène de jeu courante
func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()  # Recharge la scène active depuis zéro
	get_parent().queue_free()          # Supprime le CanvasLayer qui contient ce menu

# Bouton "Menu" (en mode pause) : quitte la partie et retourne à la sélection de niveau
func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	LoadingScreen.change_scene("res://UI/select_level.tscn")

# Bouton "Valider" (depuis le menu principal) : retourne à la sélection de niveau
func _on_bouton_valider_pressed():
	LoadingScreen.change_scene("res://UI/select_level.tscn")

# Bouton "Retour" : comportement différent selon le contexte
func _on_bouton_retour_pressed():
	# Si on est dans le menu principal (ou si la scène s'appelle "MenuSettings")
	if get_tree().current_scene == self or get_tree().current_scene.name == "MenuSettings":
		# Levelmanager.scene_retour_settings contient la scène depuis laquelle on est venu
		LoadingScreen.change_scene(Levelmanager.scene_retour_settings)
	else:
		# On est en overlay (pause) → on dépause et on ferme le panneau
		get_tree().paused = false
		if get_parent() is CanvasLayer:
			# Le parent est un CanvasLayer créé dynamiquement → on le supprime entièrement
			get_parent().queue_free()
		else:
			# Cas inhabituel : on supprime juste ce nœud
			queue_free()

# ============================================================
# --- 6. POPUP REMAPPING DES TOUCHES ---
# Cette section gère une fenêtre modale qui permet au joueur
# de reconfigurer les touches de jeu (bleu, jaune, vert, marron).
# ============================================================

# Ouvre la popup de configuration des touches.
# Si elle a déjà été construite, on la réaffiche simplement sans la reconstruire.
func _open_key_config() -> void:
	if key_popup != null and is_instance_valid(key_popup):
		# La popup existe déjà → on la rend visible et on rafraîchit les labels de touches
		key_popup.visible = true
		_refresh_key_labels()
		return
	# Première ouverture → construction complète de la popup
	_build_key_popup()

# Ferme la popup de configuration des touches.
func _close_key_config() -> void:
	# Si une touche était en cours d'écoute, on annule proprement
	if action_en_attente != "" and key_buttons.has(action_en_attente):
		_set_btn_waiting(key_buttons[action_en_attente], false)  # Remet le bouton en état normal
		action_en_attente = ""
	if key_popup != null and is_instance_valid(key_popup):
		key_popup.visible = false

# Retourne le nom lisible de la touche assignée à une action (ex: "Q", "W", "O"...).
# Utilise le code physique (indépendant de la disposition clavier AZERTY/QWERTY).
func _get_key_label(action: String) -> String:
	# Récupère la liste des événements d'entrée associés à cette action dans l'InputMap
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			# Tente de convertir le code physique en code logique (selon la disposition du clavier de l'OS)
			var kc = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			if kc != KEY_NONE:
				return OS.get_keycode_string(kc)       # Ex : "Q" sur AZERTY
			return OS.get_keycode_string(event.physical_keycode)  # Fallback si pas de correspondance
	return "?"  # Aucune touche assignée

# Met à jour le texte de tous les boutons de touche (sauf celui en cours d'écoute).
func _refresh_key_labels() -> void:
	for action in key_buttons:
		if action != action_en_attente:  # On ne touche pas au bouton qui affiche "..."
			key_buttons[action].text = _get_key_label(action)

# --- Écoute de la nouvelle touche ---
# Cette fonction est appelée automatiquement par Godot pour CHAQUE événement d'entrée.
# On ne l'utilise que quand une action est en attente de remapping.
func _input(event: InputEvent) -> void:
	if action_en_attente == "":
		return  # Pas de remapping en cours → on ignore tout

	# On attend une vraie pression de touche clavier (pas un relâchement, pas une répétition)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			# Échap = annulation du remapping
			_set_btn_waiting(key_buttons[action_en_attente], false)
			action_en_attente = ""
			_refresh_key_labels()
			get_viewport().set_input_as_handled()  # Empêche l'événement de fermer d'autres menus
			return

		# Nouvelle touche valide → on l'applique dans l'InputMap et on la sauvegarde
		Levelmanager.apply_control(action_en_attente, event.physical_keycode)
		Levelmanager.save_controls(action_en_attente, event.physical_keycode)

		# Remet le bouton en état normal et rafraîchit tous les labels
		_set_btn_waiting(key_buttons[action_en_attente], false)
		action_en_attente = ""
		_refresh_key_labels()
		get_viewport().set_input_as_handled()  # Consomme l'événement pour qu'il ne se propage pas

# Appelé quand le joueur clique sur un bouton de touche pour le reconfigurer.
func _on_remap_pressed(action: String) -> void:
	# Si un autre bouton était déjà en attente, on l'annule d'abord
	if action_en_attente != "" and key_buttons.has(action_en_attente):
		_set_btn_waiting(key_buttons[action_en_attente], false)
	# On enregistre quelle action est maintenant en attente
	action_en_attente = action
	# On met le bouton correspondant en mode "attente" (affiche "...")
	_set_btn_waiting(key_buttons[action], true)

# Change visuellement un bouton entre l'état "normal" et l'état "en attente de touche".
# waiting = true  → affiche "...", fond orange (signale que le jeu attend une frappe)
# waiting = false → restore l'apparence par défaut
func _set_btn_waiting(btn: Button, waiting: bool) -> void:
	if waiting:
		btn.text = "..."  # Indique visuellement qu'on attend une frappe

		# Crée un StyleBoxFlat = un fond personnalisé avec bords arrondis et bordure
		var s = StyleBoxFlat.new()
		s.bg_color = Color(0.70, 0.44, 0.04, 1)         # Fond orange
		s.corner_radius_top_left     = 8
		s.corner_radius_top_right    = 8
		s.corner_radius_bottom_right = 8
		s.corner_radius_bottom_left  = 8
		s.border_width_left   = 2; s.border_width_top    = 2
		s.border_width_right  = 2; s.border_width_bottom = 2
		s.border_color = Color(1.0, 0.72, 0.10, 1)      # Bordure jaune dorée

		# Applique le style et la couleur de texte au bouton
		btn.add_theme_stylebox_override("normal", s)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		# Supprime les overrides → le bouton retrouve son style par défaut
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_color_override("font_color")

# ============================================================
# --- 7. CONSTRUCTION DE LA POPUP (entièrement en code) ---
# Toute la popup est créée ici par code GDScript, sans scène .tscn.
# L'arbre de nœuds créé est :
#   key_popup (Control, plein écran, bloque clics)
#     └── overlay (ColorRect semi-transparent)
#     └── panel (Panel centré avec style arrondi)
#           └── margin (MarginContainer pour le padding)
#                 └── vbox (VBoxContainer vertical)
#                       ├── Titre
#                       ├── Aide
#                       ├── HSeparator
#                       ├── grid (GridContainer 2 colonnes : nom | bouton touche)
#                       ├── HSeparator
#                       └── Bouton "Fermer"
# ============================================================

func _build_key_popup() -> void:
	key_buttons.clear()  # Repart d'un dictionnaire vide au cas où

	# --- Couche racine : occupe tout l'écran et bloque les clics derrière la popup ---
	key_popup = Control.new()
	key_popup.name = "KeyConfigPopup"
	key_popup.set_anchors_preset(Control.PRESET_FULL_RECT)  # S'étend sur tout l'écran
	key_popup.mouse_filter = Control.MOUSE_FILTER_STOP      # Bloque les événements souris derrière
	add_child(key_popup)

	# --- Fond sombre semi-transparent pour assombrir ce qui est derrière ---
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.06, 0.80)            # Quasi-noir, 80% opaque
	overlay.mouse_filter = Control.MOUSE_FILTER_PASS        # Laisse passer les clics (le parent les bloque)
	key_popup.add_child(overlay)

	# --- Style visuel du panneau modal (arrondi, bordure bleue, ombre) ---
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color(0.10, 0.10, 0.18, 0.98)            # Fond bleu très sombre
	ps.border_width_left   = 2; ps.border_width_top    = 2
	ps.border_width_right  = 2; ps.border_width_bottom = 2
	ps.border_color = Color(0.45, 0.45, 0.78, 0.90)        # Bordure bleue/violette
	ps.corner_radius_top_left     = 16; ps.corner_radius_top_right    = 16
	ps.corner_radius_bottom_right = 16; ps.corner_radius_bottom_left  = 16
	ps.shadow_color = Color(0, 0, 0, 0.55)                 # Ombre portée
	ps.shadow_size  = 14

	# --- Panneau centré sur l'écran (420x480 px, ancré au centre) ---
	var panel = Panel.new()
	panel.anchor_left   = 0.5; panel.anchor_top    = 0.5   # Ancrage au centre de l'écran
	panel.anchor_right  = 0.5; panel.anchor_bottom = 0.5
	panel.offset_left  = -210.0; panel.offset_top    = -240.0  # Moitié largeur/hauteur vers la gauche/haut
	panel.offset_right =  210.0; panel.offset_bottom =  240.0  # Moitié largeur/hauteur vers la droite/bas
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical   = Control.GROW_DIRECTION_BOTH
	panel.add_theme_stylebox_override("panel", ps)
	key_popup.add_child(panel)

	# --- MarginContainer : ajoute un espace intérieur autour du contenu ---
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   26)
	margin.add_theme_constant_override("margin_right",  26)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	# --- VBoxContainer : empile les éléments verticalement ---
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)    # 14px d'espace entre chaque enfant
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	# Titre de la popup
	_popup_label(vbox, "⌨️  Configurer les touches", 27, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER)

	# Texte d'aide avec retour à la ligne automatique
	var help = _popup_label(vbox, "Cliquez sur un bouton puis appuyez sur la touche voulue  •  Échap pour annuler", 13, Color(0.62, 0.62, 0.80, 1), HORIZONTAL_ALIGNMENT_CENTER)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # Coupe intelligemment les mots longs

	vbox.add_child(HSeparator.new())  # Ligne de séparation horizontale

	# --- Grille 2 colonnes : [Nom de la couleur] [Bouton touche] ---
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)  # Espace horizontal entre colonnes
	grid.add_theme_constant_override("v_separation", 12)  # Espace vertical entre lignes
	vbox.add_child(grid)

	# Données des 4 actions : [nom de l'action dans l'InputMap, label affiché]
	var actions_data = [
		["bleu",   "🔵  Bleu"],
		["jaune",  "🟡  Jaune"],
		["vert",   "🟢  Vert"],
		["marron", "🟤  Marron"],
	]

	# Pour chaque action, on crée une ligne : label à gauche, bouton à droite
	for ad in actions_data:
		# Colonne gauche : nom de la couleur
		var lbl = _popup_label(grid, ad[1], 21, Color(0.90, 0.90, 0.95), HORIZONTAL_ALIGNMENT_LEFT)
		lbl.custom_minimum_size = Vector2(145, 0)              # Largeur minimale pour aligner les boutons
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL   # S'étire pour remplir l'espace disponible

		# Colonne droite : bouton affichant la touche actuelle
		var btn = _make_key_btn(ad[0])   # ad[0] = nom de l'action ("bleu", "jaune"...)
		grid.add_child(btn)
		key_buttons[ad[0]] = btn         # Mémorise la référence pour pouvoir le mettre à jour

	vbox.add_child(HSeparator.new())     # Séparateur avant le bouton fermer

	# Bouton de fermeture en bas
	var close_btn = _make_close_btn()
	vbox.add_child(close_btn)

# ============================================================
# --- Helpers de construction de la popup ---
# Fonctions utilitaires pour créer les éléments visuels sans répéter le code.
# ============================================================

# Crée et ajoute un Label stylisé à un nœud parent.
# Paramètres : parent (où l'ajouter), txt (texte), size (taille police), color, align (alignement horizontal)
func _popup_label(parent: Node, txt: String, size: int, color: Color, align: int) -> Label:
	var lbl = Label.new()
	lbl.text = txt
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = align
	if _font:
		lbl.add_theme_font_override("font", _font)  # Applique la police Inter Tight Bold si chargée
	parent.add_child(lbl)
	return lbl  # Retourne la référence au cas où on veut modifier d'autres propriétés après

# Crée un bouton affichant la touche actuelle d'une action.
# Clique → déclenche _on_remap_pressed(action) grâce à .bind(action).
func _make_key_btn(action: String) -> Button:
	var btn = Button.new()
	btn.text = _get_key_label(action)            # Affiche le nom de la touche actuelle
	btn.custom_minimum_size = Vector2(110, 40)   # Taille minimale du bouton

	if _font:
		btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

	# Style "normal" : fond bleu sombre avec bordure
	var ns = StyleBoxFlat.new()
	ns.bg_color = Color(0.20, 0.20, 0.36, 1)
	ns.corner_radius_top_left     = 8; ns.corner_radius_top_right    = 8
	ns.corner_radius_bottom_right = 8; ns.corner_radius_bottom_left  = 8
	ns.border_width_left  = 1; ns.border_width_top    = 1
	ns.border_width_right = 1; ns.border_width_bottom = 1
	ns.border_color = Color(0.45, 0.45, 0.70, 0.8)
	btn.add_theme_stylebox_override("normal", ns)

	# Style "hover" : fond un peu plus clair quand la souris passe dessus
	var hs = StyleBoxFlat.new()
	hs.bg_color = Color(0.30, 0.30, 0.52, 1)
	hs.corner_radius_top_left     = 8; hs.corner_radius_top_right    = 8
	hs.corner_radius_bottom_right = 8; hs.corner_radius_bottom_left  = 8
	btn.add_theme_stylebox_override("hover", hs)

	# Connecte le signal "pressed" à la fonction de remapping, en passant l'action en paramètre
	# .bind(action) = pré-remplit le paramètre de _on_remap_pressed avec le nom de l'action
	btn.pressed.connect(_on_remap_pressed.bind(action))
	return btn

# Crée le bouton vert "Fermer" en bas de la popup.
func _make_close_btn() -> Button:
	var btn = Button.new()
	btn.text = "✓  Fermer"
	btn.custom_minimum_size = Vector2(130, 44)

	if _font:
		btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 21)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

	# Style "normal" : fond vert foncé
	var ns = StyleBoxFlat.new()
	ns.bg_color = Color(0.12, 0.42, 0.20, 1)
	ns.corner_radius_top_left     = 10; ns.corner_radius_top_right    = 10
	ns.corner_radius_bottom_right = 10; ns.corner_radius_bottom_left  = 10
	ns.border_width_left  = 1; ns.border_width_top    = 1
	ns.border_width_right = 1; ns.border_width_bottom = 1
	ns.border_color = Color(0.22, 0.80, 0.34, 0.6)
	btn.add_theme_stylebox_override("normal", ns)

	# Style "hover" : vert légèrement plus vif
	var hs = StyleBoxFlat.new()
	hs.bg_color = Color(0.17, 0.58, 0.28, 1)
	hs.corner_radius_top_left     = 10; hs.corner_radius_top_right    = 10
	hs.corner_radius_bottom_right = 10; hs.corner_radius_bottom_left  = 10
	btn.add_theme_stylebox_override("hover", hs)

	# Connecte directement à la fonction de fermeture
	btn.pressed.connect(_close_key_config)
	return btn

# ============================================================
# --- 8. EFFETS DE SURVOL (hover) ---
# Quand la souris passe sur un bouton → on le grise légèrement.
# Quand elle repart → on le remet blanc (couleur normale).
# Color("b2b2b2ff") = gris clair | Color("ffffffff") = blanc (aucune teinte)
# ============================================================

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
