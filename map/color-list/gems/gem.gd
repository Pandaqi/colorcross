extends Node2D
class_name Gem

@export var sprite : Sprite2D
@export var shine : Sprite2D

var base_size := 256.0
var color : Rainbow.ColorName

func _ready() -> void:
	shine.hide()

func set_color(c:Rainbow.ColorName) -> void:
	color = c
	sprite.modulate = Rainbow.convert_color_to_object(c)

func set_size(s:float) -> void:
	var target_scale := (s / base_size) * Vector2.ONE
	sprite.set_scale(target_scale)
	shine.set_scale(target_scale)

func set_focus(has_focus:bool) -> Tween:
	shine.set_visible(has_focus)
	
	if not has_focus: 
		set_scale(Vector2.ONE)
		z_index = 0
		return null
	
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tw.tween_property(self, "scale", 2.0 * Vector2.ONE, 0.2)
	z_index = 100
	return tw
