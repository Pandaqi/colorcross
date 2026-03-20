extends PuzzleCommand
class_name CommandCollect

var cell_data : CellData
var collectible : CollectibleData

func _init(cd:CellData, c:CollectibleData):
	cell_data = cd
	collectible = c

func do(_cmds:PuzzleCommands) -> bool:
	cell_data.remove_collectible(collectible)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	cell_data.add_collectible(collectible)
	return true
