extends Node #Classe de base Node de Godot

#Variables
#Charge les scènes en mémoire
const MENU_SETTINGS = preload("res://UI/menu_settings.tscn") 
const FINISH_MENU = preload("res://UI/finish.tscn") 
var note = preload("res://Gameplay/note.tscn")
#Récupère les références aux éléments visuels de la scène pour les animer
@onready var bouton_bleu: AnimatedSprite2D = $Key/boutonBleu
@onready var bouton_jaune: AnimatedSprite2D = $Key2/boutonJaune
@onready var bouton_vert: AnimatedSprite2D = $Key3/boutonVert
@onready var bouton_marron: AnimatedSprite2D = $Key4/boutonMarron
@onready var conductor: AudioStreamPlayer = $Conductor
#Autres
var score = 0
var combo = 1
@onready var score_label: RichTextLabel = $FondScore/scoreLabel
@onready var combo_label: RichTextLabel = $FondScore/comboLabel
var rng = RandomNumberGenerator.new() #Pour choisir dans quelles pistes tombe la note
@export var beatsBeforeStart: int

func _ready() -> void:
	#Met les boutons dans leur état relâché au démarrage
	bouton_bleu.frame = 1
	bouton_jaune.frame = 1
	bouton_vert.frame = 1
	bouton_marron.frame = 1
	conductor.playWithBeatOffset(beatsBeforeStart) #Démarre la mécanique de rythme avec le compte à rebours

func _process(_delta: float) -> void:
	#Anime les boutons visuels selon la pression des touches : frame 0 = pressé, frame 1 = relâché
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

func _pause_game() -> void:
	if not has_node("MenuSettingsCanvas"): #Evite d'ouvrir deux fois le menu pause
		var canvas = CanvasLayer.new()
		canvas.name = "MenuSettingsCanvas"
		canvas.layer = 100 #S'affiche par-dessus tout le reste 
		var menu = MENU_SETTINGS.instantiate() #Crée une instance de la scène du menu
		canvas.add_child(menu)
		add_child(canvas)
		get_tree().paused = true #Met tout le jeu en pause

func _input(event: InputEvent) -> void:
	#Met le jeu en pause si touche echap pressée
	if event.is_action_pressed("ui_cancel"):
		_pause_game()
	
	# --- RACCOURCI TRICHE (TOUCHE FIN) ---
	if event.is_action_pressed("skip_level"):
		conductor.stop() 
		_on_conductor_finished()

func increaseScore(value):
	if value == 0: #Si note ratée
		combo = 1 #Combo repasse à 1
	else:
		combo += 1 #Sinon combo + 1
	score = score + value * combo #Le combo multiplie le score
	#Affichage
	score_label.text = str("Score: ", score) 
	combo_label.text = str("Combo x", combo)

func _on_conductor_beat_signal(_position: Variant) -> void:
	#Appelé à chaque beat par le signal du conductor
	var lane = rng.randi_range(0,3) #Choisit une piste aléatoire
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
	noteinstance.global_position.y=-300 #On place la note au dessus de l'écran
	noteinstance.speed = (280+300)/(conductor.secPerBeat * beatsBeforeStart) #Calcul pour que la note tombe au bon moment
	add_child(noteinstance)

func _on_conductor_finished() -> void:
	# 1. Sauvegarde du score actuel
	Levelmanager.dernier_score = score
	# 2. Mise à jour du record spécifique à ce niveau
	var niveau_actuel = Levelmanager.current_level
	if score > Levelmanager.meilleurs_scores[niveau_actuel]:
		Levelmanager.meilleurs_scores[niveau_actuel] = score
		Levelmanager.save_scores() # Persiste le nouveau record sur disque
	# 3. On note que ce niveau a été terminé (pour l'Easter Egg)
	if not Levelmanager.niveaux_termines.has(niveau_actuel):
		Levelmanager.niveaux_termines.append(niveau_actuel)
	# 4. Vérification de la fin du jeu (Niveau 3)
	if niveau_actuel == 3:
		Levelmanager.via_fin_de_jeu = true
		get_tree().change_scene_to_file("res://UI/CreditsMenu.tscn")
	else:
		# Sinon, on affiche le menu de fin normal
		var canvas = CanvasLayer.new()
		canvas.layer = 100
		var menu_fin = FINISH_MENU.instantiate()
		canvas.add_child(menu_fin)
		add_child(canvas)
		get_tree().paused = true

func _on_options_pressed() -> void:
	_pause_game()

func _on_options_mouse_entered() -> void:
	$Options.modulate = Color("b2b2b2ff") 

func _on_options_mouse_exited() -> void:
	$Options.modulate = Color("ffffffff")
