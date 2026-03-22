extends Node2D
class_name Tutorial

var show_helpers := true
var show_tutorial := false

@export var indicator : Node2D
@export var helper : ColorHelper

var active_tweens : Array[Tween] = []

func _ready() -> void:
	show_helpers = PuzzleFramework.get_setting_value("show_helpers") and PuzzleFramework.get_puzzle_difficulty().properties.allow_mixing
	hide_helper()
	
	show_tutorial = PuzzleFramework.get_puzzle_difficulty_level() == PuzzleDifficulty.Difficulty.EASIEST and PuzzleFramework.get_setting_value("show_tutorial")
	indicator.hide()

func highlight_move(vis:PuzzleVisualizer) -> void:
	# finish any existing tweens first
	disable() 
	
	if not show_tutorial: return
	if vis.num_moves_made >= 2 or vis.color_list.is_at_end(): return
	
	var cur_gem := vis.color_list.get_current_object()
	var cur_color := vis.color_list.get_current_color()
	var cur_move := vis.get_current_solution_cell()
	
	var matching_collectibles : Array[Collectible] = []
	for cell in vis.cells:
		for collectible in cell.collectibles:
			if collectible.data.color == cur_color:
				matching_collectibles.append(collectible)
	
	# show current gem color
	var tw1 := PuzzleTutorial.play_focus_grab_tween(cur_gem)
	active_tweens.append(tw1)
	await tw1.finished
	
	# show all matching collectibles (only wait for one to finish, not all in sequence)
	var first_tween = null
	for collectible in matching_collectibles:
		var tw2 := PuzzleTutorial.play_focus_grab_tween(collectible)
		active_tweens.append(tw2)
		if not first_tween: first_tween = tw2
	await first_tween.finished
	
	# show pointing hand at the right move
	var tw3 := PuzzleTutorial.play_pointer_tween(indicator, cur_move.global_position)
	active_tweens.append(tw3)

func disable() -> void:
	for tween in active_tweens:
		tween.pause()
		tween.custom_step(10.0)
	active_tweens = []

func hide_helper() -> void:
	helper.hide()

func show_helper(c:Cell, vis:PuzzleVisualizer) -> void:
	if not show_helpers: return
	helper.update_color(c, vis.color_list.get_current_object())
	helper.set_position(c.get_top_right())
