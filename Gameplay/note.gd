extends CharacterBody2D #Nœud physique de Godot prévu pour les entités animées

var speed = 10
var direction = Vector2.DOWN #Vecteur qui fait descendre la note
var color = "bleu" #Représente une piste/une touche que le joueur devra presser
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D #Affiche l'image de la note


func _physics_process(delta: float) -> void:
	if color == "bleu":
		animated_sprite_2d.frame = 0 #La note aura pour image le sprite 0
	elif color == "jaune":
		animated_sprite_2d.frame = 1 #La note aura pour image le sprite 1
	elif color == "vert":
		animated_sprite_2d.frame = 2 #La note aura pour image le sprite 2
	elif color == "marron":
		animated_sprite_2d.frame = 3 #La note aura pour image le sprite 3
		
	var v = direction * speed * delta #Sens + direction dans laquelle descend la note
	global_position = global_position + v #Permet l'animation fluide de la note qui descend

	if global_position.y > 650: #Si la note passe sous l'écran
		get_parent().increaseScore(0) #Miss
		queue_free() #Détruit la note
		
