class_name PuzzleGenerator

var grid : PuzzleGrid

## Grid size of the puzzle
@export var puzzle_size := Vector2i(4,4)

## Number of moves
@export var num_moves_bounds := Vector2i(5, 8)

## Maximum number of collectibles allowed in this puzzle
@export var max_collectibles := 14

## Max number of collections happening with a single move
@export var max_collections_single_move := 3

## Max number of collectibles saved on a single cell
@export var max_collectibles_per_cell := 3

## Final solution found by generator
var solution : Array[CommandTurn]

func generate() -> void:
	create_grid()
	take_random_turns()
	clean_up()

func create_grid() -> void:
	grid = PuzzleGrid.new()
	grid.creation_callback = func(pos:Vector2i): return CellData.new(pos)
	grid.create(puzzle_size)

func take_random_turns() -> void:
	# prepare command center to handle everything
	var commands := Commands.new(self)
	solution = []
	
	# take random moves
	var num_moves := randi_range(num_moves_bounds.x, num_moves_bounds.y)
	var num_collectibles_placed := 0
	var last_color := Rainbow.ColorName.NONE
	for m in range(num_moves):
		var random_cell := grid.get_random_cell()
		var random_color := Rainbow.get_random_color_primary([last_color])
		last_color = random_color
		
		# tap a random space (which recolors row/column)
		commands.start_new_turn()
		var random_turn := CommandTurn.new(random_color, random_cell.pos)
		commands.execute_command(random_turn)
		solution.append(random_turn)
		
		# from the changed cells, 
		# randomly pick some empty ones; pretend there was an object there of the current color
		# also don't pick cells that would've been collected already on an earlier turn
		var cells_allowed := random_turn.cells_affected.filter(func(c:PuzzleCell): 
			return (c as CellData).count_collectibles() < max_collectibles_per_cell and not (c as CellData).was_color_before(random_color)
		)
		
		# sort them ascending (we pick from back), so we prefer those with a long history
		# with a small bit of randomness to not become predictable
		cells_allowed.sort_custom(func(c1:CellData, c2:CellData):
			return (c1.count_colors() + randi()) < c2.count_colors()
		)
		
		var max_num_allowed := mini(cells_allowed.size(), mini(max_collectibles - num_collectibles_placed, max_collections_single_move))
		var min_num_wanted := mini(1, max_num_allowed)
		var num_collectibles_to_place := randi_range(min_num_wanted, max_num_allowed)
		
		for c in range(num_collectibles_to_place):
			var cell : CellData = cells_allowed.pop_back()
			var new_col := CollectibleData.new(cell.get_color())
			cell.add_collectible(new_col)
			num_collectibles_placed += 1

func clean_up() -> void:
	for cell in grid.get_cells():
		cell.clear_colors()
		cell.allow_collecting = true
