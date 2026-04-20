extends Control

# On récupère les labels de score
@onready var score_label = $Panel/VBoxContainer/Score
@onready var best_score_label = $Panel/VBoxContainer/BestScore

# On récupère les boutons (les "TextureButton" qui ont les signaux)
@onready var btn_menu = $"Panel/HBoxContainer/BoxNiv/Menu-Button"
@onready var btn_suivant = $"Panel/HBoxContainer/BoxSuivant/Play-Button"
@onready var btn_retry = $"Panel/HBoxContainer/BoxRetry/Retry-Button"

func _ready() -> void:
	# 1. On affiche le score qu'on vient de faire
	score_label.text = "Score : " + str(Levelmanager.dernier_score) + " points"
	
	# 2. On affiche le meilleur score du niveau actuel
	var niveau_actuel = Levelmanager.current_level
	var record = Levelmanager.meilleurs_scores[niveau_actuel]
	best_score_label.text = "Meilleur Score : " + str(record) + " points"

# --- LOGIQUE DES BOUTONS ---

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/select_level.tscn")

func _on_play_button_pressed() -> void:
	get_tree().paused = false
	# On passe au niveau suivant
	Levelmanager.current_level += 1
	if Levelmanager.current_level > Levelmanager.max_level:
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	else:
		get_tree().reload_current_scene()

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# --- EFFETS DE SURVOL (HOVER) ---

# Pour le bouton Menu (Niveaux)
func _on_menu_button_mouse_entered() -> void:
	btn_menu.modulate = Color("b2b2b2ff")

func _on_menu_button_mouse_exited() -> void:
	btn_menu.modulate = Color("ffffffff")

# Pour le bouton Suivant
func _on_play_button_mouse_entered() -> void:
	btn_suivant.modulate = Color("b2b2b2ff")

func _on_play_button_mouse_exited() -> void:
	btn_suivant.modulate = Color("ffffffff")

# Pour le bouton Réessayer
func _on_retry_button_mouse_entered() -> void:
	btn_retry.modulate = Color("b2b2b2ff")

func _on_retry_button_mouse_exited() -> void:
	btn_retry.modulate = Color("ffffffff")
