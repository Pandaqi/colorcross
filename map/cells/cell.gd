extends Node2D
class_name Cell

var data : CellData

@export var sprite : Sprite2D
@export var area : Area2D

@export var collectible_scene : PackedScene
var collectibles : Array[Collectible]

var collectible_positions := [
	[],
	[Vector2i.ZERO],
	[Vector2i(-1,-1), Vector2i(1,1)],
	[Vector2i(-1,-1), Vector2i(0,1), Vector2i(1,-1)],
	[Vector2i(-1,-1), Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1)]
]

signal clicked(c:Cell)

func _ready() -> void:
	area.input_event.connect(_on_input_event)

func sync_data(cd:CellData) -> void:
	data = cd
	create_collectibles()
	data.changed.connect(_on_data_changed)
	_on_data_changed()

func create_collectibles() -> void:
	collectibles = []
	var num_collectibles := data.count_collectibles()
	var positions = collectible_positions[num_collectibles]
	for i in range(num_collectibles):
		var co : Collectible = collectible_scene.instantiate()
		co.sync_data(data.collectibles[i])
		co.set_position(positions[i] * 16.0)
		add_child(co)
		collectibles.append(co)

func _on_data_changed() -> void:
	var mod_col := data.get_color_as_object()
	sprite.modulate = mod_col
	
	for collectible in collectibles:
		collectible.set_visible(data.collectibles.has(collectible.data))

func _on_input_event(_vp:Node, ev:InputEvent, _shape_idx:int) -> void:
	if not (ev is InputEventMouseButton) and not (ev is InputEventScreenTouch): return
	if not ev.is_released(): return
	clicked.emit(self)
