extends CenterContainer


const SOURCE_DISPLAY_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/source_display.tscn")
const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")

var _percentage_bars_enabled: bool = true
var _percentage_bar_width: int = METER_CONFIG.DEFAULT_PERCENTAGE_BAR_WIDTH
var _meter_color: Color = Color.white
onready var _source_displays_container: VBoxContainer = $ScrollContainer/Sources


func set_entries(entries: Array) -> void:
	while _source_displays_container.get_child_count() > entries.size():
		var source_display = _source_displays_container.get_child(_source_displays_container.get_child_count() - 1)
		_source_displays_container.remove_child(source_display)
		source_display.queue_free()
	for index in entries.size():
		var entry = entries[index]
		var source_display
		if index < _source_displays_container.get_child_count():
			source_display = _source_displays_container.get_child(index)
		else:
			source_display = SOURCE_DISPLAY_SCENE.instance()
			_source_displays_container.add_child(source_display)
			source_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		source_display.set_source(entry["texture"], 0)
		source_display.icon.modulate = entry.get("icon_color", Color.white)
		source_display.set_background_tier(int(entry.get("tier", -1)))
		source_display.set_item_cursed(bool(entry.get("is_cursed", false)))
		source_display.set_mechanized(bool(entry.get("is_mecha", false)))
		source_display.set_total(int(entry["total"]))
		source_display.set_bar_color(_meter_color)
	_update_percentage_bars()
	_update_source_visibility()


func set_percentage_bars_enabled(value: bool) -> void:
	_percentage_bars_enabled = value
	_update_percentage_bars()


func set_percentage_bar_width(value: int) -> void:
	_percentage_bar_width = value
	_update_percentage_bars()


func set_meter_color(value: Color) -> void:
	_meter_color = value
	for source_display in _source_displays_container.get_children():
		source_display.set_bar_color(_meter_color)
	_update_percentage_bars()


func _update_percentage_bars() -> void:
	var highest_total = 0
	for source_display in _source_displays_container.get_children():
		highest_total = max(highest_total, source_display.get_total())
	for source_display in _source_displays_container.get_children():
		var ratio = float(source_display.get_total()) / highest_total if highest_total > 0 else 0.0
		source_display.set_percentage_bar_ratio(ratio, _percentage_bars_enabled, _percentage_bar_width)


func _update_source_visibility() -> void:
	for index in _source_displays_container.get_child_count():
		var source_display = _source_displays_container.get_child(index)
		source_display.visible = source_display.get_total() > 0
