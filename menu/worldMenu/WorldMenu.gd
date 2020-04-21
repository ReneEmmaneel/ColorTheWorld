extends Control

func _ready():
	set_size(global.get_screen_size())
	$Menu/BackToWorldmapButton.grab_focus()
	for button in $Menu.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load, button.save_level, button])

func _on_button_pressed(scene_to_load, save_level, button):
	if $Menu/BackToWorldmapButton and button == $Menu/BackToWorldmapButton:
		get_parent().cancel_pressed()
	if $Menu/ContinueGameButton and button == $Menu/ContinueGameButton:
		get_parent().back_to_titlescreen()
