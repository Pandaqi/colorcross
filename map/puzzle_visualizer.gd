extends Node2D
class_name PuzzleVisualizer

var commands : PuzzleCommands
var cell_size := 256.0
var cells : Array[Cell]
var level_bounds : Rect2
var busy := false
var generator : PuzzleGenerator
var num_moves_made := 0
var cells_hovered : Array[Cell] = []

@export var camera : PuzzleCamera

@export var color_list : ColorList
@export var game_menu : PuzzleGameMenu
@export var cell_scene : PackedScene
@export var tutorial : Tutorial

func _ready() -> void:
	color_list.changed.connect(_on_active_color_changed)

func _on_active_color_changed() -> void:
	tutorial.highlight_move(self)

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	num_moves_made = 0
	
	commands = Commands.new(gen)
	add_child(commands)
	commands.do_finished.connect(_on_commands_finished)
	commands.undo_finished.connect(_on_commands_finished)
	
	game_menu.commands = commands

	cells = []
	for cell_data in gen.grid.get_cells():
		var c : Cell = cell_scene.instantiate()
		c.set_position(convert_grid_pos_to_real_pos(cell_data.pos))
		add_child(c)
		c.sync_data(cell_data)
		cells.append(c)
		c.hover.connect(_on_cell_hover)
		c.clicked.connect(_on_cell_clicked)
	
	color_list.initialize(gen)
	
	level_bounds = Rect2(Vector2.ZERO, gen.puzzle_size * cell_size)
	camera.set_target(level_bounds)
	
	PuzzleFramework.start_puzzle()

func convert_grid_pos_to_real_pos(pos:Vector2i) -> Vector2:
	return Vector2(pos * cell_size + Vector2(0.5, 0.5) * cell_size)

func get_current_color() -> Rainbow.ColorName:
	return color_list.get_current_color()

func _on_cell_clicked(c:Cell) -> void:
	if commands.is_busy() or busy: return
	
	busy = true
	
	num_moves_made += 1
	c.on_clicked()
	
	var new_turn := CommandTurn.new(get_current_color(), c.data)
	commands.start_new_turn()
	await commands.execute_command(new_turn)
	commands.execute_command(CommandTurnEnd.new(color_list))
	
	await get_tree().create_timer(0.35).timeout
	
	check_game_over()
	
	busy = false

func _on_commands_finished() -> void:
	refresh_hover()

func refresh_hover() -> void:
	if cells_hovered.size() < 0: return
	_on_cell_hover(cells_hovered.back(), true)

func _on_cell_hover(c:Cell, active:bool) -> void:
	if not active: cells_hovered.erase(c)
	if active and (not cells_hovered.has(c)): cells_hovered.append(c)
	
	if cells_hovered.size() <= 0:
		tutorial.hide_helper()
		return
	
	tutorial.show_helper(cells_hovered.back(), self)

func check_game_over() -> void:
	var collectibles_left := false
	for cell in cells:
		if cell.get_collectibles_left().size() > 0:
			collectibles_left = true
			break
	
	if collectibles_left and color_list.is_at_end():
		PuzzleFramework.finish_puzzle(false)
		return
	
	if collectibles_left: return
	
	PuzzleFramework.finish_puzzle(true)
	
	color_list.play_removal_tween()
	for cell in cells:
		cell.play_popdown_tween()

func _input(ev:InputEvent) -> void:
	if commands.is_busy(): return
	if not OS.is_debug_build(): return
	
	if ev.is_action_released("ui_left"):
		commands.undo_last_turn()

func get_current_solution_cell() -> Cell:
	var turn_index := color_list.get_current_index()
	var cell_data := generator.solution[turn_index].cell
	# for some fucking reason Godot does not recognize that c.data == cell_data if we do `.find()`
	# which is cleaner and faster than manual stuff below
	for cell in cells:
		if cell.data == cell_data:
			return cell
	return null
