extends Node2D

var perfect := false
var good := false
var ok := false
var note = null
@export var key := "bleu"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(key):
		if note != null:
			if perfect:
				get_parent().increaseScore(3)
			elif good:
				get_parent().increaseScore(2)
			elif ok:
				get_parent().increaseScore(1)
			note.queue_free()
		else:
			get_parent().increaseScore(0)

func _on_perfect_body_entered(body: Node2D) -> void:
	perfect = true



func _on_perfect_body_exited(body: Node2D) -> void:
	perfect = false



func _on_good_body_entered(body: Node2D) -> void:
	good = true


func _on_good_body_exited(body: Node2D) -> void:
	good = false


func _on_ok_body_entered(body: Node2D) -> void:
	ok = true
	note = body
	


func _on_ok_body_exited(body: Node2D) -> void:
	ok = false
	note = null
	
