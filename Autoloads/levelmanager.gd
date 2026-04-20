extends Node #Classe de base Node de Godot

#Variables d'etats :
var current_level: int = 1 #Numéro du niveau que le joueur est en train de jouer (1, 2 ou 3)
var max_level: int = 3 #Nombre total de niveaux dans le jeu
var level_unlocked: int = 3 #Tous les niveaux sont débloqués dès le départ, agit pour le bouton 'niveau suivant'
var dernier_score: int = 0
var meilleurs_scores: Dictionary = {
	1: 0, 
	2: 0, 
	3: 0
}
var niveaux_termines : Array = [] 
var via_fin_de_jeu : bool = false

func _unlock_level(level_to_unlock: int) -> void:
	#Appelée depuis finish.gd à la fin d'une partie, permet de passer au niveau suivant
	if level_to_unlock > level_unlocked:
		level_unlocked = level_to_unlock #Modifie la variable

func _load_level(level_to_load: int) -> String:
	#Génère le chemin du fichier de scène correspondant au numéro de niveau
	if level_to_load > max_level:
		return "" # Plus de niveaux, on retournera au menu
	# On convertit le numéro du niveau en texte pour créer le chemin
	# Exemple: si level_to_load est 2, ça donnera "res://Levels/2.tscn"
	return "res://Levels/" + str(level_to_load) + ".tscn"

var save_path = "user://settings.cfg" #Variable qui stock le chemin où enregistrer les paramètres du jeu
var config = ConfigFile.new() #Classe Godot qui permet de lire/écrire un fichier de configuration

func _ready():
	#Dès que le jeu démarre, on charge les paramètres sauvegardés.
	load_settings()

func save_settings(value):
	#Sauvegarde le volume sur le disque
	#Ecrit dans la section [audio] du fichier, la clé master_volume avec la valeur du slider
	config.set_value("audio", "master_volume", value) 
	config.save(save_path) # écrit physiquement le fichier settings.cfg sur le disque.

func load_settings():
	#Charge et applique le volume au démarrage
	var err = config.load(save_path) #retourne un code d'erreur : OK si le fichier n'existe pas
	var vol = 1.0
	if err == OK: 
		#Si le fichier n'existe pas (première fois qu'on lance le jeu), vol reste à 1.0 (100%)
		vol = config.get_value("audio", "master_volume", 1.0)
	#Sinon on applique le volume au bus Master
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol))
	if vol <= 0.001:
		#Si le volume est quasi nul, on coupe le son
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
