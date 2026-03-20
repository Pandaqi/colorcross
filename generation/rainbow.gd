class_name Rainbow

enum ColorName
{
	NONE,
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	CYAN,
	BLUE,
	PURPLE,
	PINK
}

static var color_names_to_indices : Dictionary[ColorName, int] = {
	ColorName.NONE: -1,
	ColorName.RED: 0,
	ColorName.ORANGE: 1,
	ColorName.YELLOW: 2,
	ColorName.GREEN: 3,
	ColorName.CYAN: 4,
	ColorName.BLUE: 5,
	ColorName.PURPLE: 6,
	ColorName.PINK: 7
}

static var color_names_to_colors : Dictionary[ColorName, Color] = {
	ColorName.NONE: Color.WHITE,
	ColorName.RED: Color.RED,
	ColorName.ORANGE: Color.ORANGE,
	ColorName.YELLOW: Color.YELLOW,
	ColorName.GREEN: Color.GREEN,
	ColorName.CYAN: Color.CYAN,
	ColorName.BLUE: Color.BLUE,
	ColorName.PURPLE: Color.PURPLE,
	ColorName.PINK: Color.PINK
}

static func get_all_colors() -> Array[ColorName]:
	var arr : Array[ColorName] = []
	arr.assign(ColorName.values())
	arr.erase(ColorName.NONE)
	return arr

static func get_all_colors_primary() -> Array[ColorName]:
	return [ColorName.RED, ColorName.GREEN, ColorName.BLUE]

static func get_random_color_primary(exclude : Array[ColorName] = []) -> ColorName:
	var list := get_all_colors_primary()
	for col in exclude: list.erase(col)
	return list.pick_random()

static func get_random_color() -> ColorName:
	return get_all_colors().pick_random()

static func convert_color_to_object(c:ColorName) -> Color:
	return color_names_to_colors[c]

static func mix_colors_in_sequence(colors:Array[ColorName]) -> ColorName:
	var current_color := ColorName.NONE
	for color in colors:
		current_color = mix_colors(current_color, color)
	return current_color

static func mix_colors(a:ColorName, b:ColorName) -> ColorName:
	if a == ColorName.NONE: return b
	if b == ColorName.NONE: return a
	
	# get the position of colors on color wheel
	var idx1 := color_names_to_indices[a]
	var idx2 := color_names_to_indices[b]
	
	# get shortest possible route (if too far apart, move the other once across the whole wheel)
	if abs(idx1 - idx2) > 4: 
		if idx1 < idx2: idx1 += 8
		else: idx2 += 8
	
	# get the average/middle point between the two
	# (by rounding we always get a sensible result even on tertiary colors)
	var new_idx := (roundi(0.5 * (idx1 + idx2)) + 8) % 8
	
	# return whatever color matches that
	for color in color_names_to_indices:
		if color_names_to_indices[color] == new_idx:
			return color
	
	return ColorName.NONE
