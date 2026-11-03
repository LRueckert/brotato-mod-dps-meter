class_name MeterListContainer
extends VBoxContainer


const MOD_ID := "lrueckert-DmgMeter"

# =============================================================================
# Configuration
# Runtime values loaded from Mod Options.
# =============================================================================
var MAX_ITEMS_1_2_PLAYERS: int = 25
var MAX_ITEMS_3_4_PLAYERS: int = 6


export(PackedScene) var element_scene = null

var player_index: int = 0
var display_position: int = 0
var rows: Dictionary = {}
onready var rows_container: VBoxContainer = $Rows
onready var heading: TextureRect = $Heading
onready var mod_options = get_node_or_null("/root/ModLoader/Oudstand-ModOptions/ModOptions")


# =============================================================================
# HUD Interface
# Called by the HUD component to initialize and refresh this list.
# =============================================================================
#region HUD Interface

func set_player(index: int) -> void:
	player_index = index
	load_settings()
	set_display_position(index)
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

func add_source(source_key: String, texture: Texture, source_data: Dictionary, item_data = null):
	if rows.has(source_key):
		return rows[source_key].row
	var row = create_row()
	row.set_element(texture, display_position)
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


func load_settings() -> void:
	if not mod_options:
		return
	if not mod_options.is_connected("config_changed", self, "_on_mod_options_config_changed"):
		mod_options.connect("config_changed", self, "_on_mod_options_config_changed")
		mod_options.connect("mod_registered", self, "_on_mod_options_registered")
	if MOD_ID in mod_options.get_registered_mods():
		MAX_ITEMS_1_2_PLAYERS = int(mod_options.get_value(MOD_ID, "max_entries_1_2_players"))
		MAX_ITEMS_3_4_PLAYERS = int(mod_options.get_value(MOD_ID, "max_entries_3_4_players"))
		hide_bottom_elements()


func _on_mod_options_registered(mod_id: String) -> void:
	if mod_id == MOD_ID:
		load_settings()


func _on_mod_options_config_changed(mod_id: String, option_id: String, value) -> void:
	if mod_id != MOD_ID:
		return
	if option_id == "max_entries_1_2_players":
		MAX_ITEMS_1_2_PLAYERS = int(value)
		hide_bottom_elements()
	elif option_id == "max_entries_3_4_players":
		MAX_ITEMS_3_4_PLAYERS = int(value)
		hide_bottom_elements()


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
	var limit = MAX_ITEMS_1_2_PLAYERS if RunData.get_player_count() <= 2 else MAX_ITEMS_3_4_PLAYERS
	var children = rows_container.get_children()
	for index in children.size():
		children[index].visible = children[index].get_total() > 0 and (limit == 0 or index < limit)