extends ScrollContainer


const METER_ROW_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_item.tscn")

var _entry_limit: int = 0
onready var _rows_container: VBoxContainer = $RowsContainer


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
		row.set_total(int(entry["total"]))
	_update_row_visibility()


func set_entry_limit(value: int) -> void:
	_entry_limit = value
	_update_row_visibility()


func _update_row_visibility() -> void:
	for index in _rows_container.get_child_count():
		var row = _rows_container.get_child(index)
		row.visible = row.get_total() > 0 and (_entry_limit == 0 or index < _entry_limit)