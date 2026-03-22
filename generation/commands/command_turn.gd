extends PuzzleCommand
class_name CommandTurn

var color : Rainbow.ColorName
var cell : CellData
var cells_affected : Array[CellData]

func _init(c:Rainbow.ColorName, ce:CellData):
	color = c
	cell = ce

func do(cmds:PuzzleCommands) -> bool:
	var recolor_row := CommandRecolor.new(color, CommandRecolor.RecolorType.ROW, cell.pos.y)
	cmds.execute_command(recolor_row)
	var recolor_col := CommandRecolor.new(color, CommandRecolor.RecolorType.COLUMN, cell.pos.x, [cell])
	cmds.execute_command(recolor_col)
	cells_affected = recolor_row.cells_affected.duplicate(false) + recolor_col.cells_affected
	return true

# This command merely adds other commands, so undoing is handled by THOSE
func undo(_cmds:PuzzleCommands) -> bool:
	cells_affected = []
	return true
