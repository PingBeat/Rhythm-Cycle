extends Control

var tips: Array[String] = [
	"Pensez à éteindre la lumière en quittant une pièce.",
	"Privilégiez les transports en commun, le vélo ou la marche.",
	"Utilisez des sacs réutilisables pour vos courses.",
	"Ne laissez pas l'eau couler pendant que vous vous brossez les dents.",
	"Triez vos déchets pour faciliter le recyclage.",
	"Réduisez votre consommation de viande pour diminuer votre empreinte carbone.",
	"Débranchez les appareils électroniques lorsque vous ne les utilisez pas.",
	"Privilégiez les produits locaux et de saison.",
	"Utilisez une gourde plutôt que des bouteilles en plastique.",
	"Réparez vos objets cassés plutôt que d'en racheter neufs systématiquement.",
	"Savais-tu que pour chaque tonne de verre recyclée, la Métropole de Lyon verse deux euros à la Ligue contre le cancer ?!"
]

@onready var tips_txt: RichTextLabel = $TipsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# On pioche une phrase au hasard dans le tableau 'tips' et on remplace le texte de la télé
	tips_txt.text = tips.pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	pass


func _on_options_pressed() -> void:
	LoadingScreen.change_scene("res://UI/menu_settings.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	LoadingScreen.change_scene("res://UI/CreditsMenu.tscn") 

func _on_bouton_retour_mouse_entered():
	$HBoxContainer/BlocExit/Exit.modulate = Color("b2b2b2ff") 
	$HBoxContainer/BlocPlay/Play.modulate = Color("b2b2b2ff") 
	$HBoxContainer/BlocOptions/Options.modulate = Color("b2b2b2ff") 

func _on_bouton_retour_mouse_exited():
	$HBoxContainer/BlocExit/Exit.modulate = Color("ffffffff")
	$HBoxContainer/BlocPlay/Play.modulate = Color("ffffffff")
	$HBoxContainer/BlocOptions/Options.modulate = Color("ffffffff")


func _on_play_pressed() -> void:
	LoadingScreen.change_scene("res://UI/select_level.tscn")
