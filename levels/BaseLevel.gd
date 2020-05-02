extends Node2D

export (Color) var bgColor = "#EEEEEE"
export (Color) var fgColor = "#AAAAAA"
export (int) var width = 15
export (int) var height = 10
export (int) var level_id
export (bool) var is_world_level = false

func get_level() -> int:
	return level_id

func center_camera():
	if !is_world_level:
		var Camera = $Camera2D
		Camera.position.x = width * 64 / 2
		Camera.position.y = height * 64 / 2
		var screen_size = global.get_screen_size()
		while width * 64 > screen_size.x || height * 64 > screen_size.y:
			screen_size *= 1.2
			Camera.zoom *= 1.2

func color_ground():
	if !is_world_level:
		var bg = $Background
		var fg = $Foreground
		bg.color = bgColor
		fg.color = fgColor

		var screen_size = global.get_screen_size()

		bg.set_global_position(-1 * (screen_size * $Camera2D.zoom) / 2 + $Camera2D.position)
		bg.set_size(screen_size * $Camera2D.zoom)

		fg.set_global_position(Vector2(0,0))
		fg.set_size(Vector2(width * 64, height * 64))

func check_outside_map(target):
	if is_world_level:
		return false
	var inside = target.x >= 0 && target.x < width && target.y >= 0 && target.y < height
	return !inside

func _ready():
	if !is_world_level:
		$"FadeRectParent/FadeRect".visible = true
		center_camera()
		color_ground()
		$Fade.play("FadeIn")
