extends CenterContainer


const SOURCE_DISPLAY_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/source_display.tscn")
const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")
const METER_MODEL = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_model.gd")

var _entries: Array = []
var _percentage_bars_enabled: bool = true
var _percentage_bar_width: int = METER_CONFIG.DEFAULT_PERCENTAGE_BAR_WIDTH
var _meter_color: Color = Color.white
onready var _source_displays_container: VBoxContainer = $ScrollContainer/Sources


func set_entries(entries: Array) -> void:
	_entries = entries
	_show_rows()


func set_percentage_bars_enabled(value: bool) -> void:
	_percentage_bars_enabled = value
	_show_rows()


func set_percentage_bar_width(value: int) -> void:
	_percentage_bar_width = value
	_show_rows()


func set_meter_color(value: Color) -> void:
	_meter_color = value
	for source_display in _source_displays_container.get_children():
		source_display.set_bar_color(_meter_color)


func _show_rows() -> void:
	var rows = METER_MODEL.build_rows(_entries, {"percentage_bars": _percentage_bars_enabled})
	while _source_displays_container.get_child_count() > rows.size():
		var source_display = _source_displays_container.get_child(_source_displays_container.get_child_count() - 1)
		_source_displays_container.remove_child(source_display)
		source_display.queue_free()
	for index in rows.size():
		var row = rows[index]
		var source_display
		if index < _source_displays_container.get_child_count():
			source_display = _source_displays_container.get_child(index)
		else:
			source_display = SOURCE_DISPLAY_SCENE.instance()
			_source_displays_container.add_child(source_display)
			source_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		source_display.set_source(row["display"].get("icon"), 0)
		source_display.icon.modulate = row["display"].get("icon_color", Color.white)
		source_display.set_background_tier(row["tier"])
		source_display.set_item_cursed(row["cursed"])
		source_display.set_mechanized(row["mechanized"])
		source_display.set_total(row["total"])
		source_display.set_bar_color(_meter_color)
		source_display.set_percentage_bar_ratio(row["ratio"], _percentage_bars_enabled, _percentage_bar_width)
