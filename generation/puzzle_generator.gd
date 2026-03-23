class_name PuzzleGenerator

var grid : PuzzleGrid

## Grid size of the puzzle
@export var puzzle_size := Vector2i(4,4)

## Number of moves
@export var num_moves_bounds := Vector2i(5, 8)

## [min,max] number of collectibles allowed in this puzzle
@export var num_collectibles_bounds := Vector2i(2, 14)

## Max number of collections happening with a single move
@export var max_collections_single_move := 3

## Max number of collectibles saved on a single cell
@export var max_collectibles_per_cell := 3

## Whether to allow mixing or not (if not allowed, cells with collectibles are only allowed to have a history of ONE)
@export var allow_mixing := true

## If false, only allows primary colors on turns. Otherwise just allows all.
@export var allow_all_colors := false

## Final solution found by generator
var solution : Array[CommandTurn]

func generate() -> void:
	PuzzleFramework.apply_difficulty_settings(self)
	var counter := 0
	while true:
		print("PuzzleGenerator | Attempt | " + str(counter))
		counter += 1
		
		create_grid()
		var is_valid := take_random_turns()
		if not is_valid: continue
		
		is_valid = clean_up()
		if is_valid: break

func create_grid() -> void:
	grid = PuzzleGrid.new()
	grid.creation_callback = func(pos:Vector2i): return CellData.new(pos)
	grid.create(puzzle_size)

func take_random_turns() -> bool:
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
		if allow_all_colors: random_color = Rainbow.get_random_color()
		last_color = random_color
		
		# tap a random space (which recolors row/column)
		commands.start_new_turn()
		var random_turn := CommandTurn.new(random_color, random_cell)
		commands.execute_command(random_turn)
		solution.append(random_turn)
		
		# from the changed cells, 
		# randomly pick some empty ones; pretend there was an object there of the current color
		# also don't pick cells that would've been collected already on an earlier turn
		var cells_allowed := random_turn.cells_affected.filter(func(c:PuzzleCell): 
			if not allow_mixing and (c as CellData).count_colors() > 1: return false
			return (c as CellData).count_collectibles() < max_collectibles_per_cell and not (c as CellData).was_color_before(random_color)
		)
		
		# sort them ascending (we pick from back), so we prefer those with a long history
		# with a small bit of randomness to not become predictable
		cells_allowed.sort_custom(func(c1:CellData, c2:CellData):
			return (c1.count_colors() + randi()) < c2.count_colors()
		)
		
		var max_num_allowed := mini(cells_allowed.size(), mini(num_collectibles_bounds.y - num_collectibles_placed, max_collections_single_move))
		var min_num_wanted := mini(1, max_num_allowed)
		var num_collectibles_to_place := randi_range(min_num_wanted, max_num_allowed)
		
		# if mixing is not allowed, then every turn MUST collect something, or it's pointless
		if not allow_mixing: 
			num_collectibles_to_place = maxi(1, num_collectibles_to_place)
		
		if num_collectibles_to_place > cells_allowed.size(): return false
		
		for c in range(num_collectibles_to_place):
			var cell : CellData = cells_allowed.pop_back()
			var new_col := CollectibleData.new(cell.get_color())
			cell.add_collectible(new_col)
			num_collectibles_placed += 1
	
	return true

func count_collectibles() -> int:
	var num_collectibles := 0
	for cell in grid.get_cells():
		num_collectibles += (cell as CellData).count_collectibles()
	return num_collectibles

func get_all_moves(cur_depth:int) -> Array[PuzzleCommand]:
	var arr : Array[PuzzleCommand] = []
	var cur_color := solution[cur_depth].color
	for cell in grid.get_cells():
		arr.append(CommandTurn.new(cur_color, cell))
	return arr

func is_end_state() -> bool:
	return count_collectibles() <= 0

func get_state_hash() -> String:
	var final := ""
	for cell in grid.get_cells():
		final += cell.hash_state()
	return final

func clean_up() -> bool:
	# too few collectibles placed = bad
	if count_collectibles() < num_collectibles_bounds.x: 
		print("PuzzleGenerator | Invalidated | Placed too few collectibles")
		return false
	
	# remove any data that's for the player to puzzle
	# open up the cell for dynamic play
	for cell in grid.get_cells():
		cell.clear_colors()
		cell.allow_collecting = true
	
	# TOO FUCKING SLOW!!!
	# brute force search for shorter solutions
	# this SHOULD return the grid to its original state once done (backtracking)
	#var sm := PuzzleSearchMoves.new()
	#sm.commands = Commands.new(self)
	#sm.commands.play_audio = false
	#sm.max_depth = solution.size() - 1 # find any solutions that are 1 or more SHORTER
	#sm.callback_moves = get_all_moves 
	#sm.callback_success = is_end_state
	#sm.callback_state_hash = get_state_hash
	#
	#var solutions := sm.search()
	#if solutions.size() > 0:
		#print("PuzzleGenerator | Invalidated | Found shorter solutions")
		#return false
	
	return true
