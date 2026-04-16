extends Node2D

var perfect := false
var good := false
var ok := false
var note = null
@export var key := "bleu"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(key):
		if note != null:
			if perfect:
				get_parent().increaseScore(3)
				show_feedback("Perfect!", Color(1, 0.85, 0))
			elif good:
				get_parent().increaseScore(2)
				show_feedback("Good!", Color(0.4, 1, 0.4))
			elif ok:
				get_parent().increaseScore(1)
				show_feedback("Ok", Color(0.6, 0.8, 1))
			note.queue_free()
		else:
			get_parent().increaseScore(0)
			show_feedback("Miss", Color(1, 0.3, 0.3))

func show_feedback(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 28)
	label.position = Vector2(-30, -80)
	add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -50), 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)

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
