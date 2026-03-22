extends Node2D
class_name ColorList

@export var gem_scene : PackedScene
@export var audio_narration : AudioStreamPlayer

var color_names : Array[Rainbow.ColorName] = []
var color_sprites : Array[Gem] = []
var sprite_size := 36.0
var margin := 4.0
var current_index := -1
var active_tween : Tween

signal changed()

func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()

func _on_size_changed() -> void:
	position.x = 0.5*get_viewport_rect().size.x

func initialize(gen:PuzzleGenerator) -> void:
	color_names = []
	for cmd in gen.solution:
		color_names.append(cmd.color)
	
	for color_name in color_names:
		var g : Gem = gem_scene.instantiate()
		g.set_color(color_name)
		g.set_size(sprite_size)
		color_sprites.append(g)
		add_child(g)
	
	current_index = 0
	change_active_color(0)
	refresh()

func refresh() -> void:
	var num_sprites := color_sprites.size()
	var sprite_size_total := sprite_size + margin
	var offset := -0.5 * (num_sprites - 1) * sprite_size_total * Vector2.RIGHT
	for i in range(num_sprites):
		var pos := offset + i * sprite_size_total * Vector2.RIGHT
		color_sprites[i].set_position(pos)
	
	highlight_current()

func is_at_start() -> bool:
	return current_index <= 0

func is_at_end() -> bool:
	return current_index >= color_names.size()

func get_current_index() -> int:
	return clampi(current_index, 0, color_names.size() - 1)

func change_active_color(dc:int) -> void:
	current_index += dc
	highlight_current()
	changed.emit()

func get_current_color() -> Rainbow.ColorName:
	return color_names[get_current_index()]

func get_current_object() -> Gem:
	return color_sprites[get_current_index()]

func highlight_current() -> void:
	if active_tween: 
		active_tween.pause()
		active_tween.custom_step(1.0)
	
	var cur_audio := Rainbow.convert_color_to_audio(get_current_color())
	var should_narrate : bool = (cur_audio != "" and not is_at_end()) and (PuzzleFramework.get_setting_value("narrate_colors") == true)
	if should_narrate:
		audio_narration.stream = load("res://map/color-list/sounds/" + cur_audio + ".ogg")
		audio_narration.bus = "Game"
		audio_narration.play()
	
	for sprite in color_sprites:
		sprite.set_focus(false)
	
	var cur_sprite := color_sprites[get_current_index()]
	active_tween = cur_sprite.set_focus(true)

func play_removal_tween() -> void:
	if active_tween: 
		active_tween.pause()
		active_tween.custom_step(1.0)

	for sprite in color_sprites:
		var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		var dur := randf_range(0.1, 0.3)
		tw.tween_property(sprite, "scale", Vector2.ZERO, dur)
