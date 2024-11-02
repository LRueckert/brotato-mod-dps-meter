class_name DmgMeterItem
extends Container

var item: Resource
onready var _icon: TextureRect = $Icon
onready var _dmg_label: Label = $Label

func set_element(item_data: Resource)->void :
	item = item_data
	_icon.texture = item_data.icon

func set_number(number: int)->void :
	_dmg_label.text = str(number)

func trigger_update()->void :
	set_number(item.dmg_dealt_last_wave)

