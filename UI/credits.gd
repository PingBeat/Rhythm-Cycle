extends Control

@export var vitesse_defilement: float = 60.0 
@onready var texte_credits: RichTextLabel = $RichTextLabel
@onready var musique: AudioStreamPlayer = $MusiqueCredits
var musique_normale = preload("res://Assets/Audio/Rhythm-Cycle-Menu.mp3")
var musique_easter_egg = preload("res://Assets/Audio/Les_Maîtres_du_Code.mp3")
# Sécurité pour éviter de changer de scène 100 fois par seconde
var deja_en_train_de_quitter: bool = false

func _ready():
	texte_credits.position.y = get_viewport_rect().size.y #Place le texte sous l'écran pour le faire remonter
	if Levelmanager.via_fin_de_jeu == true: #Si tous les niveaux on été fait, joue une autre musique
		musique.stream = musique_easter_egg
	else:
		musique.stream = musique_normale
	musique.play()
	#le menu revienne AUTOMATIQUEMENT seulement quand la musique est finie:
	musique.finished.connect(_on_bouton_retour_pressed)
	
func _process(delta: float):
	# On fait défiler le texte
	texte_credits.position.y -= vitesse_defilement * delta
	# Si le texte est complètement sorti par le haut
	if texte_credits.position.y < -texte_credits.get_content_height():
		# On ne fait rien ici ! On laisse le joueur cliquer sur "Retour" ou on attend que la musique se finisse.
		pass
func _on_bouton_retour_pressed():
	if deja_en_train_de_quitter:
		return
	deja_en_train_de_quitter = true
	Levelmanager.via_fin_de_jeu = false
	LoadingScreen.change_scene("res://UI/main_menu.tscn") #Charge le menu
func _on_bouton_retour_mouse_entered():
	$BoutonRetour.modulate = Color("b2b2b2ff") 
func _on_bouton_retour_mouse_exited():
	$BoutonRetour.modulate = Color("ffffffff")
func _on_musique_credits_finished() -> void:
	pass 
