class_name Meter
extends VBoxContainer


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")


export(PackedScene) var source_display_scene = null

var entry_limit: int = 0
var player_index: int = 0
var display_position: int = 0
var percentage_bars_enabled: bool = true
var percentage_bar_width: int = METER_CONFIG.DEFAULT_PERCENTAGE_BAR_WIDTH
var meter_color: Color = Color.white
var sources: Dictionary = {}
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
	sort_sources()
	hide_excess_sources()
	_update_percentage_bars()

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
	for source_display in source_displays_container.get_children():
		if source_display.get_total() > 0:
			entries.append({
				"texture": source_display.icon.texture,
				"icon_color": source_display.icon.modulate,
				"tier": source_display.get_background_tier(),
				"is_cursed": source_display.is_item_cursed(),
				"is_mecha": source_display.is_mechanized(),
				"total": source_display.get_total()
			})
	return entries


func add_source(source_key: String, texture: Texture, source_data: Dictionary, item_data = null):
	if sources.has(source_key):
		return sources[source_key].display
	var source_display = create_source_display()
	source_display.set_source(texture, display_position)
	source_display.set_bar_color(meter_color)
	source_display.update_background_color(item_data)
	sources[source_key] = {"display": source_display, "data": source_data}
	return source_display


func set_source_total(source_key: String, total: int) -> void:
	if not sources.has(source_key):
		return
	var source_display = sources[source_key].display
	source_display.set_total(max(source_display.get_total(), total))


func create_source_display():
	var source_display = source_display_scene.instance()
	source_displays_container.add_child(source_display)
	return source_display


func clear_sources() -> void:
	sources.clear()
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
	hide_excess_sources()


func set_percentage_bars_enabled(value: bool) -> void:
	percentage_bars_enabled = value
	_update_percentage_bars()


func set_percentage_bar_width(value: int) -> void:
	percentage_bar_width = value
	_update_percentage_bars()


func set_meter_color(value: Color) -> void:
	meter_color = value
	for source_display in source_displays_container.get_children():
		source_display.set_bar_color(meter_color)


func _update_percentage_bars() -> void:
	var highest_total = 0
	for source_display in source_displays_container.get_children():
		highest_total = max(highest_total, source_display.get_total())
	for source_display in source_displays_container.get_children():
		var ratio = float(source_display.get_total()) / highest_total if highest_total > 0 else 0.0
		source_display.set_percentage_bar_ratio(ratio, percentage_bars_enabled, percentage_bar_width)


func sort_sources() -> void:
	var sorted_displays = source_displays_container.get_children()
	sorted_displays.sort_custom(self, "compare_source_displays")
	for index in sorted_displays.size():
		if sorted_displays[index].get_index() != index:
			source_displays_container.move_child(sorted_displays[index], index)


func compare_source_displays(first, second) -> bool:
	if first.get_total() == second.get_total():
		return first.get_index() < second.get_index()
	return first.get_total() > second.get_total()


func hide_excess_sources() -> void:
	var children = source_displays_container.get_children()
	for index in children.size():
		children[index].visible = children[index].get_total() > 0 and (entry_limit == 0 or index < entry_limit)
