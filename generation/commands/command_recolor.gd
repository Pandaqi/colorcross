extends PuzzleCommand
class_name CommandRecolor

enum RecolorType
{
	ROW,
	COLUMN
}

var color : Rainbow.ColorName
var type : RecolorType
var index : int
var exclude : Array[CellData]
var cells_affected : Array[CellData]

func _init(col:Rainbow.ColorName, tp:RecolorType, idx:int, e : Array[CellData] = []):
	color = col
	type = tp
	index = idx
	exclude = e

func get_cells_affected(cmds:Commands) -> Array[CellData]:
	var arr : Array[CellData] = []
	var cells := cmds.generator.grid.get_row(index) if (type == RecolorType.ROW) else cmds.generator.grid.get_column(index)
	arr.assign(cells)
	return arr

func do(cmds:PuzzleCommands) -> bool:
	cells_affected = get_cells_affected(cmds as Commands)
	for cell in cells_affected:
		# on columns we ignore the cell we clicked, otherwise we'd recolor/evaluate that one TWICE
		# (because it's in both row and column)
		if exclude.has(cell): continue
		
		cell.recolor(color)
		
		# reverse loop because we'll be deleting from the same array as we do it
		for i in range(cell.collectibles.size() -1, -1, -1):
			var collectible := cell.collectibles[i]
			if not cell.should_collect(collectible): continue
			cmds.execute_command(CommandCollect.new(cell, collectible))
		
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	for cell in cells_affected:
		cell.undo_last_recolor(color)
	return true
