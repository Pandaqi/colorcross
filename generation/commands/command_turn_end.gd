extends PuzzleCommand
class_name CommandTurnEnd

var color_list : ColorList

func _init(cl:ColorList):
	color_list = cl

func do(_cmds:PuzzleCommands) -> bool:
	color_list.change_active_color(+1)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	color_list.change_active_color(-1)
	return true
