extends Node2D
class_name PuzzleVisualizer

var commands : PuzzleCommands
var cell_size := 128.0
var cells : Array[Cell]

@export var color_list : ColorList

@export var cell_scene : PackedScene

signal game_over(we_won:bool)

func visualize(gen:PuzzleGenerator) -> void:
	commands = Commands.new(gen)

	cells = []
	for cell_data in gen.grid.get_cells():
		var c : Cell = cell_scene.instantiate()
		c.set_position(convert_grid_pos_to_real_pos(cell_data.pos))
		c.sync_data(cell_data)
		add_child(c)
		cells.append(c)
		c.clicked.connect(_on_cell_clicked)
	
	color_list.initialize(gen)

func convert_grid_pos_to_real_pos(pos:Vector2i) -> Vector2:
	return Vector2(pos * cell_size)

func get_current_color() -> Rainbow.ColorName:
	return color_list.get_current_color()

func _on_cell_clicked(c:Cell) -> void:
	if commands.is_busy(): return
	
	var new_turn := CommandTurn.new(get_current_color(), c.data.pos)
	commands.start_new_turn()
	commands.execute_command(new_turn)
	commands.execute_command(CommandTurnEnd.new(color_list))
	
	check_game_over()

func check_game_over() -> void:
	if not color_list.is_at_end(): return
	
	for cell in cells:
		if cell.data.has_collectible():
			game_over.emit(false)
			return
	
	game_over.emit(true)

func _input(ev:InputEvent) -> void:
	if commands.is_busy(): return
	
	if ev.is_action_released("ui_left"):
		commands.undo_last_turn()
