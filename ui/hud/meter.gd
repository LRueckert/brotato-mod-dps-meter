class_name Meter
extends VBoxContainer


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")
const METER_MODEL = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_model.gd")


export(PackedScene) var source_display_scene = null

var entry_limit: int = 0
var player_index: int = 0
var display_position: int = 0
var percentage_bars_enabled: bool = true
var percentage_bar_width: int = METER_CONFIG.DEFAULT_PERCENTAGE_BAR_WIDTH
var meter_color: Color = Color.white
var sources: Dictionary = {}
var _source_order: Array = []
onready var source_displays_container: VBoxContainer = $Sources
onready var heading: TextureRect = $Heading


# =============================================================================
# Meter Panel Interface
# Called by the Meter Panel to initialize and refresh this Meter.
# =============================================================================
#region Meter Panel Interface

func set_player(index: int) -> void:
	player_index = index
	set_display_position(index)
	clear_sources()
	discover_sources()


func refresh_sources() -> void:
	update_totals()
	_show_rows()

#endregion

# =============================================================================
# Abstract Methods
# Need to be implemented by Meter specific subclasses
# =============================================================================
#region Abstract Methods

func discover_sources() -> void:
	pass


func update_totals() -> void:
	pass

#endregion

func get_wave_snapshot_entries() -> Array:
	var entries = []
	for record in _get_source_records():
		if record["total"] > 0:
			entries.append(record.duplicate(true))
	return entries


func add_source(source_key: String, texture: Texture, source_data: Dictionary, item_data = null, icon_color: Color = Color.white):
	if sources.has(source_key):
		return sources[source_key].display
	var source_display = create_source_display()
	source_display.set_source(texture, display_position)
	source_display.icon.modulate = icon_color
	source_display.set_bar_color(meter_color)
	source_display.update_background_color(item_data)
	source_display.visible = false
	var record = _create_source_record(source_key, item_data, {"icon": texture, "icon_color": icon_color})
	sources[source_key] = {"display": source_display, "data": source_data, "record": record}
	_source_order.append(source_key)
	return source_display


func set_source_total(source_key: String, total: int) -> void:
	if not sources.has(source_key):
		return
	var record = sources[source_key].record
	record["total"] = max(record["total"], total)


func get_source_total(source_key: String) -> int:
	if not sources.has(source_key):
		return 0
	return sources[source_key].record["total"]


func create_source_display():
	var source_display = source_display_scene.instance()
	source_displays_container.add_child(source_display)
	return source_display


func clear_sources() -> void:
	sources.clear()
	_source_order.clear()
	for source_display in source_displays_container.get_children():
		source_displays_container.remove_child(source_display)
		source_display.queue_free()


func set_display_position(position_index: int) -> void:
	display_position = position_index
	var left = position_index == 0 or position_index == 2
	heading.size_flags_horizontal = 0 if left else Control.SIZE_SHRINK_END
	alignment = BoxContainer.ALIGN_END if position_index > 1 else BoxContainer.ALIGN_BEGIN
	for source_display in source_displays_container.get_children():
		source_display.set_hud_position(position_index)


func set_entry_limit(value: int) -> void:
	entry_limit = value
	_show_rows()


func set_percentage_bars_enabled(value: bool) -> void:
	percentage_bars_enabled = value
	_show_rows()


func set_percentage_bar_width(value: int) -> void:
	percentage_bar_width = value
	_show_rows()


func set_meter_color(value: Color) -> void:
	meter_color = value
	for source_display in source_displays_container.get_children():
		source_display.set_bar_color(meter_color)


func _create_source_record(source_key: String, item_data, display: Dictionary) -> Dictionary:
	if item_data == null:
		return METER_MODEL.source_record(source_key, METER_MODEL.KIND_GROUPED, 0, display)
	var category = item_data.get_category()
	if category == Category.WEAPON:
		return METER_MODEL.weapon_record(source_key, item_data.weapon_id, item_data.get_instance_id(), 0, display, item_data.tier, item_data.is_cursed, item_data.is_meca)
	var kind = METER_MODEL.KIND_CHARACTER if category == Category.CHARACTER else METER_MODEL.KIND_ITEM
	return METER_MODEL.source_record(source_key, kind, 0, display, item_data.tier, item_data.is_cursed, item_data.is_meca)


func _get_source_records() -> Array:
	var records = []
	for source_key in _source_order:
		records.append(sources[source_key].record)
	return records


func _show_rows() -> void:
	var rows = METER_MODEL.build_rows(_get_source_records(), {
		"entry_limit": entry_limit,
		"percentage_bars": percentage_bars_enabled,
	})
	var ordered_keys = []
	for index in rows.size():
		var row = rows[index]
		var source_display = sources[row["key"]].display
		source_displays_container.move_child(source_display, index)
		source_display.visible = true
		source_display.set_total(row["total"])
		source_display.set_percentage_bar_ratio(row["ratio"], percentage_bars_enabled, percentage_bar_width)
		ordered_keys.append(row["key"])
	for source_key in _source_order:
		if not ordered_keys.has(source_key):
			sources[source_key].display.visible = false
			ordered_keys.append(source_key)
	# Feeding the shown order back in keeps equal Totals from swapping places between refreshes.
	_source_order = ordered_keys
