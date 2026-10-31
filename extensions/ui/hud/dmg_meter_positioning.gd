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
	for index in lists.containers.size():
		var container = lists.containers[index]
		headings.move_child(container.heading, index if left else lists.containers.size() - index - 1)
		container.alignment = BoxContainer.ALIGN_END if bottom else BoxContainer.ALIGN_BEGIN
	if bottom:
		hud_container.move_child(lists, 0)
