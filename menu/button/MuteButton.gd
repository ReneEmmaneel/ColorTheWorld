extends Button

export(String) var scene_to_load
export(bool) var save_level = false

func update_label():
	if music.is_playing:
		$Label.text = "Mute music"
	else:
		$Label.text = "Unmute music"

func _ready():
	update_label()

func _on_Mute_pressed():
	music.toggle_music()
	update_label()
