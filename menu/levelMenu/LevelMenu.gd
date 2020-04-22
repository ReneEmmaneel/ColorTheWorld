extends Node2D

func _ready():
	$Menu/ContinueLevelButton.grab_focus()
	for button in $Menu.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load, button.save_level, button])


func _on_button_pressed(scene_to_load, save_level, button):
	if $Menu/ContinueLevelButton and button == $Menu/ContinueLevelButton:
		get_parent().cancel_pressed()

	if save_level:
		var level = get_parent().get_parent().get_level()
		global.level_not_beaten(level)
	if scene_to_load != "":
		get_tree().change_scene(scene_to_load)
