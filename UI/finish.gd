extends Control

@onready var label_score: Label = $VBoxContainer/ScoreFinal

func afficher_resultats(score_du_joueur: int):
	label_score.text = "Niveau Terminé !\nScore : " + str(score_du_joueur)
	Levelmanager._unlock_level(Levelmanager.current_level + 1)

func _on_bouton_menu_pressed() -> void:
	get_tree().paused = false
	LoadingScreen.change_scene("res://UI/main_menu.tscn")

func _on_bouton_suivant_pressed() -> void:
	get_tree().paused = false
	Levelmanager.current_level += 1

	var level_to_load = Levelmanager._load_level(Levelmanager.current_level)
	if level_to_load != "":
		LoadingScreen.change_scene(level_to_load)
	else:
		LoadingScreen.change_scene("res://UI/main_menu.tscn")
