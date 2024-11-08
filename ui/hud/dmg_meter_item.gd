class_name DmgMeterItem
extends HBoxContainer

var item: WeaponData
onready var dmg_label: Label = $Label
onready var icon_panel: Panel = $ IconPanel
onready var icon: TextureRect = $ IconPanel / Icon


func set_element(item_data: WeaponData, index: int)->void :
	item = item_data
	icon.texture = item_data.icon
	set_hud_position(index)
	update_background_color()


func set_hud_position(position_index: int)->void :
	var left = position_index == 0 or position_index == 2
	self.alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	self.move_child(dmg_label, icon_panel.get_index() + 1 if left else 0)


func update_background_color()->void :
	remove_stylebox_override("panel")
	if item == null:
		return 
	var stylebox = icon_panel.get_stylebox("panel").duplicate()
	ItemService.change_inventory_element_stylebox_from_tier(stylebox, item.tier, 0.3)
	icon_panel.add_stylebox_override("panel", stylebox)
	icon_panel._update_stylebox(item.is_cursed)


func trigger_update()->void :
	dmg_label.text =  Text.get_formatted_number(item.dmg_dealt_last_wave)

