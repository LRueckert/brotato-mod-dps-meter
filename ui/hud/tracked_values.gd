extends Reference

# Pure helpers for base-game tracked values (RunData.tracked_item_effects). No
# game globals, nodes, or textures, so headless tests in tools/tests/ can load
# it. A tracked value is an int, or for a few items an array of counters.

# Counters of array-tracked damage items that aren't damage, by item id
# (base game: run_data.gd init_tracked_items, item_parent_data.gd tooltips).
const NON_DAMAGE_COUNTERS = {
	"item_bot_o_mine": [1], # dropped_landmines
	"item_hungry_hungry_dinosaur": [1], # fruits_eaten
}


static func total(tracked, skipped_counters: Array = []) -> int:
	if not tracked is Array:
		return tracked
	var value = 0
	for index in tracked.size():
		if not skipped_counters.has(index):
			value += tracked[index]
	return value


static func damage_total(item_id: String, tracked) -> int:
	return total(tracked, NON_DAMAGE_COUNTERS.get(item_id, []))
