extends "res://singletons/run_data.gd"

func init_tracked_effects() -> Dictionary:
	var tracked_effects = .init_tracked_effects()
	# All the other items and characters are tracked here so lets add the romantic character
	tracked_effects["character_romantic"] = 0
	return tracked_effects
