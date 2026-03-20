extends Node2D

@export var vis : PuzzleVisualizer

func _ready() -> void:
	var gen := PuzzleGenerator.new()
	gen.generate()
	vis.visualize(gen)
