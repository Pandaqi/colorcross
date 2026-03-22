extends Node2D
class_name Cell

var data : CellData

@export var sprite : Sprite2D
@export var area : Area2D

@export var collectible_scene : PackedScene
var collectibles : Array[Collectible]
var collectibles_currently_visible : Array[Collectible] = []
var active_tween : Tween
var base_size := 256.0

@export var audio_clicked : AudioStreamPlayer2D

var collectible_positions := [
	[],
	[Vector2i.ZERO],
	[Vector2i(-1,-1), Vector2i(1,1)],
	[Vector2i(-1,-1), Vector2i(1,-1), Vector2i(0,1)],
	[Vector2i(-1,-1), Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1)]
]

signal clicked(c:Cell)
signal hover(c:Cell, active:bool)

func _ready() -> void:
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	play_popup_tween()

func get_top_right() -> Vector2:
	return global_position + Vector2(1,-1) * (base_size * 0.5 * 0.85)

func play_popup_tween() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.2, 0.6)
	set_scale(Vector2.ZERO)
	tw.tween_property(self, "scale", Vector2.ONE, dur)

func play_popdown_tween() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.2, 0.6)
	tw.tween_property(self, "scale", Vector2.ZERO, dur)

func sync_data(cd:CellData) -> void:
	data = cd
	create_collectibles()
	data.changed.connect(_on_data_changed)
	_on_data_changed()

func create_collectibles() -> void:
	collectibles = []
	var num_collectibles := data.count_collectibles()
	for i in range(num_collectibles):
		var co : Collectible = collectible_scene.instantiate()
		co.sync_data(data.collectibles[i])
		add_child(co)
		collectibles.append(co)

func on_clicked() -> void:
	PuzzleAudio.play_audio_nice(audio_clicked)

func _on_data_changed() -> void:
	var mod_col := data.get_color_as_object()
	
	# animate color change
	if active_tween: 
		active_tween.pause()
		active_tween.custom_step(1)
	
	if is_inside_tree():
		var tw := get_tree().create_tween()
		var pos := get_position()
		var pos_jumped := Vector2(pos.x, pos.y - 16.0)
		
		var dur := randf_range(0.05, 0.2)
		tw.tween_property(sprite, "modulate", mod_col, dur)
		tw.parallel().tween_property(self, "position", pos_jumped, 0.5*dur)
		tw.tween_property(self, "position", pos, 0.5*dur)
		active_tween = tw
	else:
		sprite.modulate = mod_col
	
	# animate collectible change
	# (by tracking which have CHANGED from last time, and making those appear/disappear)
	var collectibles_visible : Array[Collectible] = []
	for collectible in collectibles:
		var is_currently_visible := collectibles_currently_visible.has(collectible)
		var should_be_visible := data.collectibles.has(collectible.data)
		if should_be_visible: collectibles_visible.append(collectible)
		
		if is_currently_visible and not should_be_visible:
			collectible.disappear()
		if not is_currently_visible and should_be_visible:
			collectible.appear()
	
	collectibles_currently_visible = collectibles_visible
	
	var num_collectibles_visible := collectibles_visible.size()
	var positions = collectible_positions[num_collectibles_visible]
	for i in range(num_collectibles_visible):
		collectibles_visible[i].set_position(positions[i] * base_size * 0.125)

func _on_input_event(_vp:Node, ev:InputEvent, _shape_idx:int) -> void:
	if not (ev is InputEventMouseButton) and not (ev is InputEventScreenTouch): return
	if not ev.is_released(): return
	clicked.emit(self)

func _on_mouse_entered() -> void:
	hover.emit(self, true)

func _on_mouse_exited() -> void:
	hover.emit(self, false)

func get_collectibles_left() -> Array[Collectible]:
	return collectibles_currently_visible
