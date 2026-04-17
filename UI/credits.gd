extends Control

@export var vitesse_defilement: float = 60.0 # Tu pourras modifier la vitesse dans l'inspecteur

@onready var texte_credits: RichTextLabel = $RichTextLabel

func _ready():
	texte_credits.position.y = get_viewport_rect().size.y

func _process(delta: float):
	texte_credits.position.y -= vitesse_defilement * delta

func _on_bouton_retour_pressed():
	LoadingScreen.change_scene("res://UI/main_menu.tscn")


func _on_bouton_retour_mouse_entered():
	$BoutonRetour.modulate = Color("b2b2b2ff") 

func _on_bouton_retour_mouse_exited():
	$BoutonRetour.modulate = Color("ffffffff")
