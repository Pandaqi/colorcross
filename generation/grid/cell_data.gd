extends PuzzleCell
class_name CellData

var colors : Array[Rainbow.ColorName] = []
var collectibles : Array[CollectibleData] = []
var allow_collecting := false
var mix_colors := true

func recolor(c:Rainbow.ColorName) -> void:
	colors.append(c)
	changed.emit()

func should_collect(c:CollectibleData) -> bool:
	if not allow_collecting: return false
	return c.color == get_color()

func undo_last_recolor(c:Rainbow.ColorName) -> void:
	if colors.size() <= 0: return
	if colors.back() != c: return # sanity check
	colors.pop_back()
	changed.emit()

func was_color_before(c:Rainbow.ColorName) -> bool:
	var first_idx := colors.find(c)
	if first_idx == -1: return false
	if first_idx >= (colors.size() - 1): return false # color is last element, so we were never it BEFORE
	return true

func add_collectible(c:CollectibleData) -> void:
	collectibles.append(c)
	changed.emit()

func remove_collectible(c:CollectibleData) -> void:
	collectibles.erase(c)
	changed.emit()

func has_collectible() -> bool:
	return count_collectibles() > 0

func count_collectibles() -> int:
	return collectibles.size()

func count_colors() -> int:
	return colors.size()

func has_color() -> bool:
	return count_colors() > 0

func get_color() -> Rainbow.ColorName:
	if not has_color(): return Rainbow.ColorName.NONE
	if mix_colors:
		return Rainbow.mix_colors_in_sequence(colors)
	return colors.back()

func get_color_as_object() -> Color:
	return Rainbow.convert_color_to_object(get_color())

func clear_colors() -> void:
	colors = []
