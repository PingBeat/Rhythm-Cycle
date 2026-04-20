extends AudioStreamPlayer #Noeud Godot pour jouer des sons 2D

#Déclaration de variables
@onready var start_timer: Timer = $StartTimer
@export var songBPM: int #Tempo de la musique
var beatBeforeStart: int #Battement avant début de la musique
var secPerBeat: float #Durée d'un temps en secondes
var songPosition: float #Position de lecture en seconde
var songPositioninBeats := 0 #Position de lecture en battement
var prevSongPositioninBeats := 0 #Position précédente de lecture en battement
signal beatSignal(position) #Crée un signal avec la position de lecture

func _ready() -> void:
	secPerBeat = 60.0/songBPM #Calcule la durée d'un battement
	#Niveau 1 = 80BPM, Niveau 2 = 120BPM, Niveau 3 = 144BPM

func _physics_process(_delta: float) -> void:
	#Appelée 60 fois par seconde pour suivre la musique avec précision
	if playing:
		songPosition = get_playback_position() + AudioServer.get_time_since_last_mix() #Calcule la position
		songPosition -= AudioServer.get_output_latency() #en tenant compte de la latence
		songPositioninBeats = int(floor(songPosition / secPerBeat)) + beatBeforeStart #Convertit en battement
		report_beat() #Emet un signal qui donne le battement actuel
		
func report_beat():
	#Emet un signal qui donne le battement actuel et fait apparaitre une note
	if (prevSongPositioninBeats < songPositioninBeats): #Si la position dans le son change
		emit_signal("beatSignal",songPositioninBeats) #Emet un signal
		prevSongPositioninBeats = songPositioninBeats #Actualise la position
		
func playWithBeatOffset(beats):
	#Démarre la musique avec un décalage pour laisser les notes descendre avant que la musique ne commence
	beatBeforeStart = beats #Nombre de battements avant de commencer la musique
	start_timer.wait_time = secPerBeat #Compte un certains nombres de battements avant de commencer la musique
	start_timer.start() #Démarre le timer du temps d'attente
	
func _on_start_timer_timeout() -> void:
	#Gère le décompte en temps réel
	songPositioninBeats += 1
	if songPositioninBeats < beatBeforeStart - 1 : #Si la musique n'a pas encore commencée
		start_timer.start() #Lance le timer 
	elif songPositioninBeats == beatBeforeStart - 1: #Si on est juste avant le début de la musique
		start_timer.wait_time = start_timer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()) #On prend en compte la latence
		start_timer.start() #On relance le timer
	else: #Sinon on peut commencer la musique
		play()
		start_timer.stop() #Stop le timer
	report_beat() #Emet un signal qui donne le battement actuel
