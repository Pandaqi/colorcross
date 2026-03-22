extends Node2D
class_name ColorHelper

@export var overlay : Sprite2D
@export var color_wheel : Sprite2D

func update_color(cell:Cell, gem:Gem) -> void:
	show()
	
	var color_mixed := Rainbow.mix_colors(cell.data.get_color(), gem.color)
	var no_mixing_happened := color_mixed == gem.color
	if no_mixing_happened: 
		color_wheel.show()
		overlay.hide()
		return
	
	color_wheel.hide()
	overlay.show()
	overlay.modulate = Rainbow.convert_color_to_object(color_mixed)
