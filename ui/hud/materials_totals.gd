extends Reference

# Pure materials math for the Materials Meter's grouped Sources. No game
# globals, nodes, or textures, so headless tests in tools/tests/ can load it.


# Returns {"harvesting": int, "other": int} for one player's wave.
# total_gains: every material gain this wave, Harvesting included.
# tracked_gains: sum of the item/weapon-tracked Sources (Metal Detector included).
static func split(total_gains: int, pickups: int, harvesting_gains: int, tracked_gains: int) -> Dictionary:
	var harvesting = int(max(0, harvesting_gains))
	return {
		"harvesting": harvesting,
		"other": int(max(0, total_gains - pickups - harvesting - tracked_gains)),
	}
