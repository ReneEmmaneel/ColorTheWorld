extends Button

export(String) var scene_to_load
export(bool) var save_level = false

func update_label():
	if music.is_sound_on():
		$Label.text = "Mute sounds"
	else:
		$Label.text = "Unmute sounds"

func _ready():
	update_label()

func _on_MuteSoundsButton_pressed():
	music.toggle_sound()
	update_label()
