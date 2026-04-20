extends CanvasLayer #S'affiche par-dessus tout le reste

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
	"Réparez vos objets cassés plutôt que d'en racheter neufs systématiquement."
]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tip_label: RichTextLabel = $Control/TipLabel

var scene_to_load: String = ""

func _ready() -> void:
	$Control.hide() # Caché par défaut
	var bg_path = "res://Assets/Images/loading_bg.png"# Charge l'image
	if ResourceLoader.exists(bg_path): #Vérifie que l'image existe
		var tex = ResourceLoader.load(bg_path)
		$Control/Background.texture = tex

func change_scene(target_path: String) -> void:
	scene_to_load = target_path
	
	# Choisir un conseil aléatoire
	var random_tip = tips[randi() % tips.size()]
	tip_label.text = "[center]" + random_tip + "[/center]"
	
	# Lancer l'animation d'apparition
	$Control.show()
	animation_player.play("fade_in")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		# Quand l'écran est totalement noir/visible, on change de scène
		get_tree().change_scene_to_file(scene_to_load)
		# On ajoute un petit délai avec un timer pour laisser le temps de lire le conseil
		await get_tree().create_timer(1.2).timeout
		# Puis on relance l'animation pour disparaître
		animation_player.play("fade_out")
	elif anim_name == "fade_out":
		$Control.hide()
