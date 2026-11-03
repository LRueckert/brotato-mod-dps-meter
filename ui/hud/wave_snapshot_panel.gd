extends ScrollContainer


const METER_ROW_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_item.tscn")

onready var _rows_container: VBoxContainer = $RowsContainer


func set_entries(entries: Array) -> void:
	for child in _rows_container.get_children():
		_rows_container.remove_child(child)
		child.queue_free()
	for entry in entries:
		var row = METER_ROW_SCENE.instance()
		_rows_container.add_child(row)
		row.visible = true
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.set_element(entry["texture"], 0)
		row.icon.modulate = entry.get("icon_color", Color.white)
		row.set_total(int(entry["total"]))