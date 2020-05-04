extends Node

var is_playing = true
var walk_sounds
var curr_walk = 0

func _ready():
	if !global.debug_start_muted:
		$MusicWorldmap.play(0)
	else:
		is_playing = false
	walk_sounds = [$SoundMove]

func _on_AudioStreamPlayer_finished():
	if is_playing:
		$MusicWorldmap.play()

func toggle_music():
	if is_playing:
		$MusicWorldmap.stop()
	else:
		$MusicWorldmap.play()
	is_playing = !is_playing

func is_sound_on():
	return !AudioServer.is_bus_mute(AudioServer.get_bus_index("Sounds"))

func toggle_sound():
	var bus = AudioServer.get_bus_index("Sounds")
	AudioServer.set_bus_mute(bus, !AudioServer.is_bus_mute(bus))

func play_sound(sound):
	match sound:
		"move":
			walk_sounds[curr_walk].play()
			curr_walk = (curr_walk + 1) % walk_sounds.size()
		"explosion":
			$Explosion.play()
		"door":
			$Door.play()
		"win":
			$Win.play()
