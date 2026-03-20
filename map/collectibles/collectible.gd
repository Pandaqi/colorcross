extends Node2D
class_name Collectible

@export var sprite : Sprite2D
var data : CollectibleData

func sync_data(cd:CollectibleData) -> void:
	data = cd
	
	var color := Rainbow.convert_color_to_object(data.color)
	sprite.modulate = color
