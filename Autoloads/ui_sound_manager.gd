extends Node

var click_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Pour que le son marche même quand le jeu est en pause
	click_player = AudioStreamPlayer.new()

	# preload() est obligatoire ici, sinon Godot n'emballe pas le fichier dans le .exe
	click_player.stream = preload("res://Assets/Audio/click.wav")
		
	add_child(click_player)
	
	get_tree().node_added.connect(_on_node_added)
	
	_connect_buttons(get_tree().root)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		if not node.pressed.is_connected(_on_button_pressed):
			node.pressed.connect(_on_button_pressed)

func _connect_buttons(node: Node) -> void:
	if node is BaseButton:
		if not node.pressed.is_connected(_on_button_pressed):
			node.pressed.connect(_on_button_pressed)
			
	for child in node.get_children():
		_connect_buttons(child)

func _on_button_pressed() -> void:
	# Dès qu'on clique, on lance le bruit
	if click_player.stream != null:
		# On copie le lecteur au cas où on clique super vite plusieurs fois
		var duplicate_player = click_player.duplicate()
		add_child(duplicate_player)
		duplicate_player.play()
		duplicate_player.finished.connect(duplicate_player.queue_free)
