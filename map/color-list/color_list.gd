extends Node2D
class_name ColorList

var color_names : Array[Rainbow.ColorName] = []
var color_sprites : Array[Sprite2D] = []
var sprite_size := 32.0
var sprite_size_base := 128.0
var current_index := -1

func initialize(gen:PuzzleGenerator) -> void:
	color_names = []
	for cmd in gen.solution:
		color_names.append(cmd.color)
	
	for color_name in color_names:
		var c := Sprite2D.new()
		c.texture = load("res://map/cells/color-crate-overlay.png")
		c.modulate = Rainbow.convert_color_to_object(color_name)
		color_sprites.append(c)
		add_child(c)
	
	current_index = 0
	refresh()

func refresh() -> void:
	var num_sprites := color_sprites.size()
	var offset := -0.5 * (num_sprites - 1) * sprite_size * Vector2.RIGHT
	for i in range(num_sprites):
		var pos := offset + i * sprite_size * Vector2.RIGHT
		color_sprites[i].set_position(pos)
	
	highlight_current()

func is_at_start() -> bool:
	return current_index <= 0

func is_at_end() -> bool:
	return current_index >= (color_names.size() - 1)

func get_current_index() -> int:
	return clampi(current_index, 0, color_names.size() - 1)

func change_active_color(dc:int) -> void:
	current_index += dc
	highlight_current()

func get_current_color() -> Rainbow.ColorName:
	return color_names[get_current_index()]

func highlight_current() -> void:
	for sprite in color_sprites:
		sprite.set_scale((sprite_size / sprite_size_base) * Vector2.ONE)
	color_sprites[get_current_index()].set_scale(Vector2.ONE)
