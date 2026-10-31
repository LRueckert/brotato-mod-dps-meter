class_name MeterListItem
extends HBoxContainer

var total: int = 0
onready var amount_label: Label = $Label
onready var icon_panel: Panel = $IconPanel
onready var icon: TextureRect = $IconPanel/Icon


func set_element(texture: Texture, index: int, tooltip: String = "") -> void:
	icon.texture = texture
	hint_tooltip = tooltip
	set_hud_position(index)
	icon_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_hud_position(position_index: int) -> void:
	var left = position_index == 0 or position_index == 2
	alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	move_child(amount_label, icon_panel.get_index() + 1 if left else 0)


func update_background_color(item_data: ItemParentData) -> void:
	remove_stylebox_override("panel")
	if item_data == null:
		return
	var stylebox = icon_panel.get_stylebox("panel").duplicate()
	ItemService.change_inventory_element_stylebox_from_tier(stylebox, item_data.tier, 0.3)
	icon_panel.add_stylebox_override("panel", stylebox)
	icon_panel._curse.visible = item_data.is_cursed


func get_total() -> int:
	return total


func set_total(value: int) -> void:
	total = value
	amount_label.text = Text.get_formatted_number(total)