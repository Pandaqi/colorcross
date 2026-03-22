extends PuzzleCommands
class_name Commands

var generator : PuzzleGenerator

func _init(gen:PuzzleGenerator):
	generator = gen
	play_audio = true
