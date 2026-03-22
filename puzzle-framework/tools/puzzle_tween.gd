class_name PuzzleTween

static func play_popup_tween(obj:Node2D, dur_bounds := Vector2(0.2, 0.6)) -> Tween:
	var tw := obj.get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(dur_bounds.x, dur_bounds.y)
	obj.set_scale(Vector2.ZERO)
	tw.tween_property(obj, "scale", Vector2.ONE, dur)
	return tw

static func play_popdown_tween(obj:Node2D, dur_bounds := Vector2(0.2, 0.6)) -> void:
	var tw := obj.get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(dur_bounds.x, dur_bounds.y)
	tw.tween_property(obj, "scale", Vector2.ZERO, dur)

static func force_tween_completion(tw:Tween, dur := 10.0) -> void:
	tw.pause()
	tw.custom_step(dur)

# @TODO: this likely won't work; can I make an easy system for remembering properties and resetting as if the tween never happened/started?
# Why the fuck is this not a standard feature of Tweens?
static func force_tween_reset(tw:Tween, dur := 10.0) -> void:
	tw.pause()
	tw.custom_step(-dur)
