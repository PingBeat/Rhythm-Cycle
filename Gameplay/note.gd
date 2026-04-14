extends CharacterBody2D

var speed = 10
var direction = Vector2.DOWN
var color = "bleu"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if color == "bleu":
		animated_sprite_2d.frame = 0
	elif color == "jaune":
		animated_sprite_2d.frame = 1
	elif color == "vert":
		animated_sprite_2d.frame = 2
	elif color == "marron":
		animated_sprite_2d.frame = 3
		
	var v = direction * speed * delta
	global_position = global_position + v

	if global_position.y > 650:
		get_parent().increaseScore(0)
		queue_free()
		
	
