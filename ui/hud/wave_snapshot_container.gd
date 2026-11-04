extends CenterContainer


const METER_ROW_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_item.tscn")
const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")

var _percentage_bars_enabled: bool = true
var _percentage_bar_width: int = METER_CONFIG.DEFAULT_PERCENTAGE_BAR_WIDTH
var _category_color: Color = Color.white
onready var _rows_container: VBoxContainer = $ScrollContainer/RowsContainer


func set_entries(entries: Array) -> void:
	while _rows_container.get_child_count() > entries.size():
		var row = _rows_container.get_child(_rows_container.get_child_count() - 1)
		_rows_container.remove_child(row)
		row.queue_free()
	for index in entries.size():
		var entry = entries[index]
		var row
		if index < _rows_container.get_child_count():
			row = _rows_container.get_child(index)
		else:
			row = METER_ROW_SCENE.instance()
			_rows_container.add_child(row)
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.set_element(entry["texture"], 0)
		row.icon.modulate = entry.get("icon_color", Color.white)
		row.set_background_tier(int(entry.get("tier", -1)))
		row.set_item_cursed(bool(entry.get("is_cursed", false)))
		row.set_mechanized(bool(entry.get("is_mecha", false)))
		row.set_total(int(entry["total"]))
		row.set_bar_color(_category_color)
	_update_row_bars()
	_update_row_visibility()


func set_percentage_bars_enabled(value: bool) -> void:
	_percentage_bars_enabled = value
	_update_row_bars()


func set_percentage_bar_width(value: int) -> void:
	_percentage_bar_width = value
	_update_row_bars()


func set_category_color(value: Color) -> void:
	_category_color = value
	for row in _rows_container.get_children():
		row.set_bar_color(_category_color)
	_update_row_bars()


func _update_row_bars() -> void:
	var highest_total = 0
	for row in _rows_container.get_children():
		highest_total = max(highest_total, row.get_total())
	for row in _rows_container.get_children():
		var ratio = float(row.get_total()) / highest_total if highest_total > 0 else 0.0
		row.set_percentage_bar_ratio(ratio, _percentage_bars_enabled, _percentage_bar_width)


func _update_row_visibility() -> void:
	for index in _rows_container.get_child_count():
		var row = _rows_container.get_child(index)
		row.visible = row.get_total() > 0