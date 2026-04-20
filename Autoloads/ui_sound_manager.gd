extends Node #Classe de base Node de Godot
var click_player: AudioStreamPlayer #Noeud Godot pour jouer des sons 2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Pour que le son marche même quand le jeu est en pause
	click_player = AudioStreamPlayer.new() #Crée le nœud de lecture audio
	click_player.stream = preload("res://Assets/Audio/click.wav") #charge le fichier audio à la compilation
	add_child(click_player) #Attache le lecteur audio au noeud
	get_tree().node_added.connect(_on_node_added) #Connecte les boutons créées dynamiquement
	_connect_buttons(get_tree().root) #Connecte les boutons déjà créées

func _on_node_added(node: Node) -> void:
	#Detecte quand un noeud est ajouté
	if node is BaseButton: #Si c'est un bouton
		if not node.pressed.is_connected(_on_button_pressed):
			node.pressed.connect(_on_button_pressed) #Connecte le son lié si ce n'est pas déjà fait

func _connect_buttons(node: Node) -> void:
	#Fonction récursive qui parcours les noeuds et connecte les boutons
	if node is BaseButton: #Si le noeud est un bouton
		if not node.pressed.is_connected(_on_button_pressed):
			node.pressed.connect(_on_button_pressed) #Connecte le son lié si ce n'est pas déjà fait
	for child in node.get_children(): #Parcours les noeuds enfants
		_connect_buttons(child)

func _on_button_pressed() -> void:
	#Joue le son de clic de manière sécurisée
	if click_player.stream != null:
		var duplicate_player = click_player.duplicate()#On copie le lecteur au cas où on clique vite plusieurs fois
		add_child(duplicate_player) #On crée le noeud
		duplicate_player.play() #On joue le son
		duplicate_player.finished.connect(duplicate_player.queue_free) #On libère la fil
