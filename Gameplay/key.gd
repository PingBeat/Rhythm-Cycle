extends Node2D #Classe de base Node de Godot

#Initialisation de variables
var perfect := false
var good := false
var ok := false
var note = null #Null si pas de note dans la zone
@export var key := "bleu" #Nom de l'action à detecter

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(key): #Si une touche du jeu est pressée
		if note != null:
			if perfect: #Si perfect
				get_parent().increaseScore(3) #Score + 3
				show_feedback("Perfect!", Color(1, 0.85, 0)) #Affichage du texte 'Perfect' en jaune
			elif good:
				get_parent().increaseScore(2)
				show_feedback("Good!", Color(0.4, 1, 0.4))
			elif ok:
				get_parent().increaseScore(1)
				show_feedback("Ok", Color(0.6, 0.8, 1))
			note.queue_free() #Détruit la note une fois frappée
		else:
			get_parent().increaseScore(0)
			show_feedback("Miss", Color(1, 0.3, 0.3))

func show_feedback(text: String, color: Color) -> void:
	#Affiche un texte flottant ("Perfect!", "Miss", etc.) qui monte et disparaît
	var label = Label.new() #Noeud de texte
	label.text = text #Assigne le texte à afficher
	label.modulate = color #Applique la couleur
	label.add_theme_font_size_override("font_size", 28) #Modifie la taille
	label.position = Vector2(-30, -80) #Positionne le texte
	add_child(label)
	var tween = create_tween() #Gestionnaire d'animation
	tween.tween_property(label, "position", label.position + Vector2(0, -50), 0.6) #Anime le texte vers le haut
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6) #Change l'oppacité en même temps
	tween.tween_callback(label.queue_free) #Une fois fini, supprime le label proprement

#Recepteur de signaux physiques
func _on_perfect_body_entered(_body: Node2D) -> void:
	perfect = true
func _on_perfect_body_exited(_body: Node2D) -> void:
	perfect = false
func _on_good_body_entered(_body: Node2D) -> void:
	good = true
func _on_good_body_exited(_body: Node2D) -> void:
	good = false
func _on_ok_body_entered(body: Node2D) -> void:
	ok = true
	note = body
func _on_ok_body_exited(_body: Node2D) -> void:
	ok = false
	note = null
