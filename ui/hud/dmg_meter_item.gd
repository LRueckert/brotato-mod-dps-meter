class_name DmgMeterItem
extends HBoxContainer

var item: ItemParentData
var player_index: int
onready var dmg_label: Label = $Label
onready var icon_panel: Panel = $IconPanel
onready var icon: TextureRect = $IconPanel/Icon

var wave_start_value: int = 0
var is_total_damage_item = false

func set_element(item_data: ItemParentData, index: int) -> void:
	item = item_data
	player_index = index
	icon.texture = item_data.icon
	set_hud_position(player_index)
	update_background_color()
	if [Category.ITEM, Category.CHARACTER].has(item.get_category()) && not item.name == "ITEM_BUILDER_TURRET":
		wave_start_value = RunData.tracked_item_effects[player_index][item.my_id]


func set_hud_position(position_index: int) -> void:
	var left = position_index == 0 or position_index == 2
	self.alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	self.move_child(dmg_label, icon_panel.get_index() + 1 if left else 0)


func update_background_color() -> void:
	remove_stylebox_override("panel")
	var stylebox = icon_panel.get_stylebox("panel").duplicate()
	if item:
		ItemService.change_inventory_element_stylebox_from_tier(stylebox, item.tier, 0.3)
		icon_panel._update_stylebox(item.is_cursed)
	else:
		ItemService.change_inventory_element_stylebox_from_tier(stylebox, 0, 0.3)
		icon_panel._update_stylebox(false)
	icon_panel.add_stylebox_override("panel", stylebox)
	

func get_dmg_dealt() -> int:
	if item == null:
		return 0
	if item.get_category() == Category.WEAPON:
		return item.dmg_dealt_last_wave
	else:
		return RunData.tracked_item_effects[player_index][item.my_id] - wave_start_value

func trigger_update() -> void:
	dmg_label.text = Utils.format_number(get_dmg_dealt())
	
func set_total_damage_element(index: int) -> void:
	player_index = index
	icon.texture = load("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/total_damage_ui.png")
	set_hud_position(player_index)
	update_background_color()

func set_total_damage(amount: int) -> void:	
	dmg_label.text = Utils.format_number(amount)
	RunData.last_wave_total_damage[player_index] = amount

