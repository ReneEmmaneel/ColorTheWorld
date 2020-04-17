extends AudioStreamPlayer

var is_playing = true

func _ready():
	self.play(0)

func _on_AudioStreamPlayer_finished():
	if is_playing:
		self.play()

func toggle_music():
	if is_playing:
		self.stop()
	else:
		self.play()
	is_playing = !is_playing
