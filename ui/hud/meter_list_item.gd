class_name MeterListItem
extends HBoxContainer

var total: int = 0
onready var amount_label: Label = $Label
onready var icon_panel: Panel = $IconPanel
onready var icon: TextureRect = $IconPanel/Icon
onready var _default_icon_style: StyleBoxFlat = icon_panel.get_stylebox("panel").duplicate()


func set_element(texture: Texture, index: int) -> void:
	icon.texture = texture
	set_hud_position(index)
	icon_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_hud_position(position_index: int) -> void:
	var left = position_index == 0 or position_index == 2
	alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	move_child(amount_label, icon_panel.get_index() + 1 if left else 0)


func update_background_color(item_data: ItemParentData) -> void:
	var stylebox = _default_icon_style.duplicate()
	icon_panel._curse.visible = item_data != null and item_data.is_cursed
	if item_data != null:
		ItemService.change_inventory_element_stylebox_from_tier(stylebox, item_data.tier, 0.3)
	icon_panel.add_stylebox_override("panel", stylebox)


func get_total() -> int:
	return total


func set_total(value: int) -> void:
	total = value
	amount_label.text = Text.get_formatted_number(total)
