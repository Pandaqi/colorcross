extends Node
class_name PuzzleCommands

## Contains all commands executed on every turn => Array[Array[PuzzleCommand]]
var history : Array = []

## True while it's busy doing/undoing commands (which allows you to check if you're able/allowed to make a new action happen or not)
var busy := false

## You can set this to true while generating because you might want certain things to not happen (rr happen differently) while generating compared to while playing
var generating := false

func has_turns() -> bool:
	return history.size() > 0

func is_busy() -> bool:
	return busy

func get_current_turn() -> Array[PuzzleCommand]:
	var arr : Array[PuzzleCommand] = []
	if not has_turns(): return arr
	arr.assign(history.back())
	return arr

func register_command(cmd:PuzzleCommand) -> void:
	history.back().append(cmd)

func start_new_turn() -> void:
	history.append([])

func delete_last_turn() -> void:
	history.pop_back()

func execute_command(cmd:PuzzleCommand) -> void:
	busy = true
	
	register_command(cmd)
	cmd.do(self)
	
	busy = false

func undo_last_turn() -> void:
	if not has_turns(): return
	
	busy = true
	
	var commands : Array[PuzzleCommand] = get_current_turn()
	commands.reverse()
	
	for cmd in commands:
		cmd.undo(self)
	
	delete_last_turn()
	busy = false
