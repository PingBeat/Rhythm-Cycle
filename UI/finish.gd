extends Control

@onready var label_score_actuel = $Panel/VBoxContainer/Score
@onready var label_meilleur_score = $Panel/VBoxContainer/BestScore

func _ready():
	label_score_actuel.text = "Score : " + str(Levelmanager.dernier_score) + " points"
	label_meilleur_score.text = "Meilleur Score : " + str(Levelmanager.meilleur_score) + " points"
	Levelmanager._unlock_level(Levelmanager.current_level + 1)
	

#func _on_bouton_menu_pressed() -> void:
	#get_tree().paused = false
	#LoadingScreen.change_scene("res://UI/main_menu.tscn")

#func _on_bouton_suivant_pressed() -> void:
	#get_tree().paused = false
	#Levelmanager.current_level += 1
#
	#var level_to_load = Levelmanager._load_level(Levelmanager.current_level)
	#if level_to_load != "":
		#LoadingScreen.change_scene(level_to_load)
	#else:
		#LoadingScreen.change_scene("res://UI/main_menu.tscn")
		
func _on_bouton_retour_mouse_entered():
	$"Panel/HBoxContainer/Menu-Button".modulate = Color("b2b2b2ff") 
	$"Panel/HBoxContainer/Retry-Button".modulate = Color("b2b2b2ff") 
	$"Panel/HBoxContainer/Play-Button".modulate = Color("b2b2b2ff") 

func _on_bouton_retour_mouse_exited():
	$"Panel/HBoxContainer/Menu-Button".modulate = Color("ffffffff")
	$"Panel/HBoxContainer/Play-Button".modulate = Color("ffffffff")
	$"Panel/HBoxContainer/Retry-Button".modulate = Color("ffffffff")


func _on_menu_button_pressed() -> void:
	LoadingScreen.change_scene("res://UI/select_level.tscn")


func _on_play_button_pressed() -> void:
	get_tree().paused = false
	Levelmanager.current_level += 1

	var level_to_load = Levelmanager._load_level(Levelmanager.current_level)
	if level_to_load != "":
		LoadingScreen.change_scene(level_to_load)
	else:
		LoadingScreen.change_scene("res://UI/main_menu.tscn")


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	# On recharge le niveau en cours sans l'augmenter
	var current_level_path = Levelmanager._load_level(Levelmanager.current_level)
	LoadingScreen.change_scene(current_level_path)
