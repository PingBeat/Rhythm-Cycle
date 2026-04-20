extends Control

@export var vitesse_defilement: float = 60.0 

@onready var texte_credits: RichTextLabel = $RichTextLabel
@onready var musique: AudioStreamPlayer = $MusiqueCredits

# --- Tes fichiers audio (à vérifier dans ton dossier Assets) ---
var musique_normale = preload("res://Assets/Audio/Rhythm-Cycle-Menu.mp3")
var musique_easter_egg = preload("res://Assets/Audio/Les_Maîtres_du_Code.mp3")

func _ready():
	# On place le texte en bas de l'écran pour le faire monter
	texte_credits.position.y = get_viewport_rect().size.y
	
	# --- LOGIQUE DE L'EASTER EGG ---
	if Levelmanager.via_fin_de_jeu == true:
		# Si on vient de finir le jeu, on joue la musique spéciale
		musique.stream = musique_easter_egg
	else:
		# Sinon, musique normale
		musique.stream = musique_normale
	
	musique.play()

func _process(delta: float):
	texte_credits.position.y -= vitesse_defilement * delta
	
	# Si les crédits sont finis (optionnel), on peut retourner au menu
	if texte_credits.position.y < -texte_credits.get_content_height():
		_on_bouton_retour_pressed()

func _on_bouton_retour_pressed():
	# IMPORTANT : On remet le flag à faux pour la prochaine fois
	Levelmanager.via_fin_de_jeu = false
	LoadingScreen.change_scene("res://UI/main_menu.tscn")

func _on_bouton_retour_mouse_entered():
	$BoutonRetour.modulate = Color("b2b2b2ff") 

func _on_bouton_retour_mouse_exited():
	$BoutonRetour.modulate = Color("ffffffff")
