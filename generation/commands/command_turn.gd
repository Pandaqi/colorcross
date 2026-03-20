extends PuzzleCommand
class_name CommandTurn

var color : Rainbow.ColorName
var pos : Vector2i
var cells_affected : Array[CellData]

func _init(c:Rainbow.ColorName, p:Vector2i):
	color = c
	pos = p

func do(cmds:PuzzleCommands) -> bool:
	var recolor_row := CommandRecolor.new(color, CommandRecolor.RecolorType.ROW, pos.y)
	cmds.execute_command(recolor_row)
	var recolor_col := CommandRecolor.new(color, CommandRecolor.RecolorType.COLUMN, pos.x)
	cmds.execute_command(recolor_col)
	cells_affected = recolor_row.cells_affected.duplicate(false) + recolor_col.cells_affected
	return true

# This command merely adds other commands, so undoing is handled by THOSE
func undo(cmds:PuzzleCommands) -> bool:
	cells_affected = []
	return true
