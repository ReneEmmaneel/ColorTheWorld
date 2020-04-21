extends Node2D

export (Color) var bgColor = "#EEEEEE"
export (Color) var fgColor = "#AAAAAA"
export (int) var width = 15
export (int) var height = 10

# Extract the level number from its internal name
func get_level() -> int:
	return get_tree().get_current_scene().get_name().right(5).to_int()

func center_camera():
	var Camera = $Camera2D
	Camera.position.x = width * 64 / 2
	Camera.position.y = height * 64 / 2

func color_ground():
	var bg = $Background
	var fg = $Foreground
	bg.color = bgColor
	fg.color = fgColor

	var screen_size = global.get_screen_size()

	bg.set_global_position(-1 * screen_size / 2 + $Camera2D.position)
	bg.set_size(screen_size)

	fg.set_global_position(Vector2(0,0))
	fg.set_size(Vector2(width * 64, height * 64))

func check_outside_map(target):
	var inside = target.x >= 0 && target.x < width && target.y >= 0 && target.y < height
	return !inside

func _ready():
	$FadeRect.visible = true
	center_camera()
	color_ground()
	$Fade.play("FadeIn")
