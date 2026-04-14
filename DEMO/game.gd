extends Node

const MENU_SETTINGS = preload("res://Menus/menu_settings.tscn") 

@onready var bouton_bleu: AnimatedSprite2D = $Key/boutonBleu
@onready var bouton_jaune: AnimatedSprite2D = $Key2/boutonJaune
@onready var bouton_vert: AnimatedSprite2D = $Key3/boutonVert
@onready var bouton_marron: AnimatedSprite2D = $Key4/boutonMarron
@onready var conductor: AudioStreamPlayer = $Conductor

var score = 0
var combo = 1
@onready var score_label: RichTextLabel = $scoreLabel
@onready var combo_label: RichTextLabel = $comboLabel

var note = preload("res://note.tscn")
var rng = RandomNumberGenerator.new()

@export var beatsBeforeStart: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bouton_bleu.frame = 1
	bouton_jaune.frame = 1
	bouton_vert.frame = 1
	bouton_marron.frame = 1
	conductor.playWithBeatOffset(beatsBeforeStart)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("bleu"):
		bouton_bleu.frame = 0
	if Input.is_action_pressed("jaune"):
		bouton_jaune.frame = 0
	if Input.is_action_pressed("vert"):
		bouton_vert.frame = 0
	if Input.is_action_pressed("marron"):
		bouton_marron.frame = 0
	if Input.is_action_just_released("bleu"):
		bouton_bleu.frame = 1
	if Input.is_action_just_released("jaune"):
		bouton_jaune.frame = 1
	if Input.is_action_just_released("vert"):
		bouton_vert.frame = 1
	if Input.is_action_just_released("marron"):
		bouton_marron.frame = 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# On vérifie si notre "vitre" (Canvas) existe déjà
		if not has_node("MenuSettingsCanvas"):
			# 1. On crée le CanvasLayer (la vitre)
			var canvas = CanvasLayer.new()
			canvas.name = "MenuSettingsCanvas"
			canvas.layer = 100 # On s'assure que ça passe par-dessus tout ton décor
			# 2. On charge ton menu
			var menu = MENU_SETTINGS.instantiate()
			# 3. On colle le menu sur la vitre, puis on met la vitre dans le jeu
			canvas.add_child(menu)
			add_child(canvas)
			# 4. On fige le jeu
			get_tree().paused = true

func increaseScore(value):
	if value == 0:
		combo = 1
	else : 
		combo += 1
	score = score + value * combo
	score_label.text = str("Score: ", score)
	combo_label.text = str("Combo x", combo)


func _on_conductor_beat_signal(position: Variant) -> void:
	var lane = rng.randi_range(0,3)
	var noteinstance = note.instantiate()
	if lane == 0:
		noteinstance.global_position=bouton_bleu.global_position
		noteinstance.color = "bleu"
	elif lane==1:
		noteinstance.global_position=bouton_jaune.global_position
		noteinstance.color = "jaune"
	elif lane==2:
		noteinstance.global_position=bouton_marron.global_position
		noteinstance.color = "marron"
	elif lane==3:
		noteinstance.global_position=bouton_vert.global_position
		noteinstance.color = "vert"
	noteinstance.global_position.y=-300
	noteinstance.speed  = (280+300)/(conductor.secPerBeat * beatsBeforeStart)
	add_child(noteinstance)
