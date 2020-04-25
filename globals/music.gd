extends Node

var is_playing = true

func _ready():
	if !global.debug_start_muted:
		$MusicWorldmap.play(0)
	else:
		is_playing = false

func _on_AudioStreamPlayer_finished():
	if is_playing:
		$MusicWorldmap.play()

func toggle_music():
	if is_playing:
		$MusicWorldmap.stop()
	else:
		$MusicWorldmap.play()
	is_playing = !is_playing

func play_sound(sound):
	match sound:
		"move":
			if false:
				$SoundMove.play() #sounds kinda bad
