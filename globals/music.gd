extends AudioStreamPlayer

var is_playing = true

func _ready():
	if !global.debug_start_muted:
		self.play(0)
	else:
		is_playing = false

func _on_AudioStreamPlayer_finished():
	if is_playing:
		self.play()

func toggle_music():
	if is_playing:
		self.stop()
	else:
		self.play()
	is_playing = !is_playing
