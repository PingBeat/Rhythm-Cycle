extends Control

@onready var label_score: Label = $VBoxContainer/ScoreFinal

func afficher_resultats(score_du_joueur: int):
	label_score.text = "Niveau Terminé !\nScore : " + str(score_du_joueur)
	Levelmanager._unlock_level(Levelmanager.current_level + 1)

func _on_bouton_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_bouton_suivant_pressed() -> void:
	get_tree().paused = false
	Levelmanager.current_level += 1

	var level_to_load = Levelmanager._load_level(Levelmanager.current_level)
	if level_to_load != "":
		get_tree().change_scene_to_file(level_to_load)
	else:
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
