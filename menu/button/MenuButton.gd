extends Button

export(String) var scene_to_load
export(bool) var save_level = false

func _ready():
	pass

func _on_ContinueGameButton_pressed():
	get_tree().quit()
