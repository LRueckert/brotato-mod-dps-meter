class_name MeterListContainer
extends VBoxContainer


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")


export(PackedScene) var element_scene = null

var entry_limit: int = 0
var player_index: int = 0
var display_position: int = 0
var percentage_bars_enabled: bool = true
var percentage_bar_width: int = METER_CONFIG.DEFAULT_PERCENTAGE_BAR_WIDTH
var category_color: Color = Color.white
var rows: Dictionary = {}
onready var rows_container: VBoxContainer = $Rows
onready var heading: TextureRect = $Heading


# =============================================================================
# HUD Interface
# Called by the HUD component to initialize and refresh this list.
# =============================================================================
#region HUD Interface

func set_player(index: int) -> void:
	player_index = index
	set_display_position(index)
	clear_elements()
	discover_sources()


func trigger_element_updates() -> void:
	update_totals()
	sort_elements()
	hide_bottom_elements()
	_update_row_bars()

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

func get_snapshot_entries() -> Array:
	var entries = []
	for row in rows_container.get_children():
		if row.get_total() > 0:
			entries.append({"texture": row.icon.texture, "icon_color": row.icon.modulate, "total": row.get_total()})
	return entries


func add_source(source_key: String, texture: Texture, source_data: Dictionary, item_data = null):
	if rows.has(source_key):
		return rows[source_key].row
	var row = create_row()
	row.set_element(texture, display_position)
	row.set_bar_color(category_color)
	row.update_background_color(item_data)
	rows[source_key] = {"row": row, "data": source_data}
	return row


func set_source_total(source_key: String, total: int) -> void:
	if not rows.has(source_key):
		return
	var row = rows[source_key].row
	row.set_total(max(row.get_total(), total))


func create_row():
	var row = element_scene.instance()
	rows_container.add_child(row)
	return row


func clear_elements() -> void:
	rows.clear()
	for row in rows_container.get_children():
		rows_container.remove_child(row)
		row.queue_free()


func set_display_position(position_index: int) -> void:
	display_position = position_index
	var left = position_index == 0 or position_index == 2
	heading.size_flags_horizontal = 0 if left else Control.SIZE_SHRINK_END
	alignment = BoxContainer.ALIGN_END if position_index > 1 else BoxContainer.ALIGN_BEGIN
	for row in rows_container.get_children():
		row.set_hud_position(position_index)


func set_entry_limit(value: int) -> void:
	entry_limit = value
	hide_bottom_elements()


func set_percentage_bars_enabled(value: bool) -> void:
	percentage_bars_enabled = value
	_update_row_bars()


func set_percentage_bar_width(value: int) -> void:
	percentage_bar_width = value
	_update_row_bars()


func set_category_color(value: Color) -> void:
	category_color = value
	for row in rows_container.get_children():
		row.set_bar_color(category_color)


func _update_row_bars() -> void:
	var highest_total = 0
	for row in rows_container.get_children():
		highest_total = max(highest_total, row.get_total())
	for row in rows_container.get_children():
		var ratio = float(row.get_total()) / highest_total if highest_total > 0 else 0.0
		row.set_percentage_bar_ratio(ratio, percentage_bars_enabled, percentage_bar_width)


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
		children[index].visible = children[index].get_total() > 0 and (entry_limit == 0 or index < entry_limit)