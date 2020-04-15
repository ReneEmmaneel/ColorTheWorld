extends Control

func _ready():
	$Menu/MapButton.grab_focus()
	for button in $Menu.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load, button.save_level])


func _on_button_pressed(scene_to_load, save_level):
	if save_level:
		var level = get_parent().get_parent().get_level()
		global.level_not_beaten(level)
	get_tree().change_scene(scene_to_load)
