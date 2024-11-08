extends "res://ui/hud/player_ui_elements.gd"

func set_hud_position(position_index: int)->void :
	# original code
	var left = position_index == 0 or position_index == 2
	var top = position_index <= 1
	hud_container.size_flags_horizontal = 0 if left else Control.SIZE_SHRINK_END
	hud_container.size_flags_vertical = 0 if top else Control.SIZE_SHRINK_END
	hud_container.move_child(gold, xp_bar.get_index() + 1 if top else 0)
	gold.alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	# extension
	var dmg_meter_container = hud_container.get_node("DmgMeterContainerP%s" % str(player_index+1))
	if not top:
		hud_container.move_child(dmg_meter_container, 0)