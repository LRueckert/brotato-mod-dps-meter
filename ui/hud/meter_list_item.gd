class_name MeterListItem
extends HBoxContainer

var total: int = 0
onready var icon_panel: Panel = $IconPanel
onready var icon: TextureRect = $IconPanel/Icon
onready var value_container: Control = $ValueContainer
onready var amount_label: Label = $ValueContainer/Label
onready var value_bar: Control = $ValueContainer/ValueBar
onready var value_track: Panel = $ValueContainer/ValueBar/Track
onready var value_fill: Panel = $ValueContainer/ValueBar/Fill
onready var _fill_style: StyleBoxFlat = value_fill.get_stylebox("panel").duplicate()
onready var _default_icon_style: StyleBoxFlat = icon_panel.get_stylebox("panel").duplicate()
var _bar_color: Color
var _has_bar_color: bool = false
var _percentage_bar_ratio: float = 0.0
var _bar_grows_left: bool = false


func set_element(texture: Texture, index: int) -> void:
	icon.texture = texture
	set_hud_position(index)
	icon_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_hud_position(position_index: int) -> void:
	var left = position_index == 0 or position_index == 2
	_bar_grows_left = not left
	alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	if left:
		move_child(icon_panel, 0)
		move_child(value_container, 1)
		amount_label.align = Label.ALIGN_LEFT
	else:
		move_child(value_container, 0)
		move_child(icon_panel, 1)
		amount_label.align = Label.ALIGN_RIGHT
	_update_bar_fill()


func set_bar_color(color: Color) -> void:
	if _has_bar_color and _bar_color == color:
		return
	_bar_color = color
	_has_bar_color = true
	_fill_style.bg_color = Color(color.r, color.g, color.b, 0.5)
	value_fill.add_stylebox_override("panel", _fill_style)


func set_percentage_bar_ratio(ratio: float, show_percentage_bar: bool, bar_width: int) -> void:
	_percentage_bar_ratio = clamp(ratio, 0.0, 1.0)
	value_bar.visible = show_percentage_bar
	value_container.rect_min_size.x = float(bar_width) if show_percentage_bar else amount_label.get_minimum_size().x + 8.0
	_update_bar_fill()


func _update_bar_fill() -> void:
	value_fill.anchor_left = 1.0 - _percentage_bar_ratio if _bar_grows_left else 0.0
	value_fill.anchor_right = 1.0 if _bar_grows_left else _percentage_bar_ratio
	value_fill.margin_left = 0.0
	value_fill.margin_right = 0.0


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
