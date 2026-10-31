class_name MeterListContainer
extends VBoxContainer


export(PackedScene) var element_scene = null

var player_index: int = 0
var max_items: int = 0
var rows: Dictionary = {}
onready var rows_container: VBoxContainer = $Rows
onready var heading: TextureRect = $Heading


# =============================================================================
# HUD Interface
# Called by the HUD component to initialize and refresh this list.
# =============================================================================
#region HUD Interface

func set_player(index: int, player_count: int) -> void:
	player_index = index
	max_items = 0 if player_count < 3 else 6
	heading.size_flags_horizontal = 0 if index == 0 or index == 2 else Control.SIZE_SHRINK_END
	clear_elements()
	discover_sources()


func trigger_element_updates() -> void:
	update_totals()
	sort_elements()
	hide_bottom_elements()

#endregion

# =============================================================================
# Abstract Methods
# Need to be implemented by type specific subclasses
# =============================================================================
#region Abstract Methods

func discover_sources() -> void:
	pass


func update_totals() -> void:
	pass

#endregion

func create_row():
	var row = element_scene.instance()
	rows_container.add_child(row)
	return row


func clear_elements() -> void:
	rows.clear()
	for row in rows_container.get_children():
		rows_container.remove_child(row)
		row.queue_free()




func sort_elements() -> void:
	var sorted_rows = rows_container.get_children()
	sorted_rows.sort_custom(self, "compare_rows")
	for index in sorted_rows.size():
		if sorted_rows[index].get_index() != index:
			rows_container.move_child(sorted_rows[index], index)


func compare_rows(first, second) -> bool:
	if first.get_total() == second.get_total():
		return first.get_index() < second.get_index()
	return first.get_total() > second.get_total()


func hide_bottom_elements() -> void:
	var children = rows_container.get_children()
	for index in children.size():
		children[index].visible = children[index].get_total() > 0 and (max_items == 0 or index < max_items)