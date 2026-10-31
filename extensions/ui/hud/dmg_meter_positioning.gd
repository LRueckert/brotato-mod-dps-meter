extends "res://ui/hud/player_ui_elements.gd"

func set_hud_position(position_index: int) -> void:
	# call original function
	.set_hud_position(position_index)
	# extension
	var bottom = position_index > 1
	var lists = hud_container.get_node("MeterListsP%s" % str(player_index + 1))
	var left = position_index == 0 or position_index == 2
	var headings = lists.get_node("Headings")
	headings.alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	headings.move_child(lists.get_node("DmgMeterContainer").heading, 0 if left else 1)
	for container in [lists.get_node("DmgMeterContainer"), lists.get_node("HealingMeterContainer")]:
		container.alignment = BoxContainer.ALIGN_END if bottom else BoxContainer.ALIGN_BEGIN
	if bottom:
		hud_container.move_child(lists, 0)
