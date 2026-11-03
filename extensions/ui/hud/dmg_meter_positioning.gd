extends "res://ui/hud/player_ui_elements.gd"

func set_hud_position(position_index: int) -> void:
	# call original function
	.set_hud_position(position_index)
	# extension
	var bottom = position_index > 1
	var lists = hud_container.get_node("MeterListsP%s" % str(player_index + 1))
	lists.set_hud_position(position_index)
	if bottom:
		hud_container.move_child(lists, 0)
