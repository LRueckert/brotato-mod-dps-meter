extends "res://ui/hud/player_ui_elements.gd"

func set_hud_position(position_index: int) -> void:
	# call original function
	.set_hud_position(position_index)
	# extension
	var bottom = position_index > 1
	var dmg_meter_container = hud_container.get_node("DmgMeterContainerP%s" % str(player_index + 1))
	if bottom:
		hud_container.move_child(dmg_meter_container, 0)