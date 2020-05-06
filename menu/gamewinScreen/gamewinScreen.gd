extends Control

func _ready():
	var screen_size = global.get_screen_size()
	$Pos.rect_size = screen_size

	var levels_beaten = global.levels_beaten.size()
	var tot_levels = global.all_level_scenes.size()

	$Pos/Label.text = "Levels beaten: {0}/{1}".format([levels_beaten, tot_levels])

	$Pos/Menu/TitlescreenButton.grab_focus()
	for button in $Pos/Menu.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load, button.save_level, button])


func _on_button_pressed(scene_to_load, save_level, button):
	if scene_to_load != "":
		get_tree().change_scene(scene_to_load)

func setup_particles():
	var particles = $Pos/Particles2D
	particles.process_material.emission_box_extents = Vector3($Pos.width, 0, 0)
	particles.position = Vector2($Pos.width / 2, -20)
