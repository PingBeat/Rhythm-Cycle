extends AudioStreamPlayer
@onready var start_timer: Timer = $StartTimer

@export var songBPM: int
var beatBeforeStart: int

var secPerBeat: float

var songPosition: float

var songPositioninBeats := 0
var prevSongPositioninBeats := 0 

signal beatSignal(position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	secPerBeat = 60.0/songBPM


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if playing:
		songPosition = get_playback_position() + AudioServer.get_time_since_last_mix()
		songPosition -= AudioServer.get_output_latency()
		songPositioninBeats = int(floor(songPosition / secPerBeat)) + beatBeforeStart
		report_beat()
		
func report_beat():
	if (prevSongPositioninBeats < songPositioninBeats):
		emit_signal("beatSignal",songPositioninBeats)
		prevSongPositioninBeats = songPositioninBeats
		
func playWithBeatOffset(beats):
	beatBeforeStart = beats
	start_timer.wait_time = secPerBeat
	start_timer.start()
	
func _on_start_timer_timeout() -> void:
	songPositioninBeats += 1
	if songPositioninBeats < beatBeforeStart - 1 :
		start_timer.start()
	elif songPositioninBeats == beatBeforeStart - 1:
		start_timer.wait_time = start_timer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		start_timer.start()
	else:
		play()
		start_timer.stop()
	report_beat()
