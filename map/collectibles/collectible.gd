extends Node2D
class_name Collectible

@export var overlay : Sprite2D
var data : CollectibleData
var active_tween : Tween

@export var audio_collected : AudioStreamPlayer2D

func sync_data(cd:CollectibleData) -> void:
	data = cd
	
	var color := Rainbow.convert_color_to_object(data.color)
	overlay.modulate = color

func appear() -> void:
	if active_tween: active_tween.stop()
	
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.1, 0.3)
	set_scale(Vector2.ZERO)
	show()
	tw.tween_property(self, "scale", Vector2.ONE, dur)
	active_tween = tw

func disappear() -> void:
	if active_tween: active_tween.stop()
	
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.1, 0.3)
	tw.tween_property(self, "scale", Vector2.ZERO, dur)
	tw.tween_callback(self.hide)
	active_tween = tw
	
	PuzzleAudio.play_audio_nice(audio_collected)
