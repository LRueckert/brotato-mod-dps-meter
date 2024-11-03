class_name DmgMeterItem
extends Container

var item: WeaponData
onready var _dmg_label: Label = $Label
onready var icon_panel: Panel = $ IconPanel
onready var _icon = $ IconPanel / Icon as TextureRect

func set_element(item_data: WeaponData)->void :
	item = item_data
	_icon.texture = item_data.icon
	update_background_color()

func update_background_color()->void :
	remove_stylebox_override("panel")
	if item == null:
		return 
	var stylebox = icon_panel.get_stylebox("panel").duplicate()
	ItemService.change_inventory_element_stylebox_from_tier(stylebox, item.tier, 0.3)
	icon_panel.add_stylebox_override("panel", stylebox)
	icon_panel._update_stylebox(item.is_cursed)

func trigger_update()->void :
	_dmg_label.text = str(item.dmg_dealt_last_wave)

