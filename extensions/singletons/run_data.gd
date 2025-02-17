extends "res://singletons/run_data.gd"

func init_tracked_effects() -> Dictionary:
	var tracked_effects = .init_tracked_effects()
	tracked_effects["character_romantic"] = 0
	return tracked_effects
