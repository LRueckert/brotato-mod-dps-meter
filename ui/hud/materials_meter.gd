class_name MaterialsMeter
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter.gd"


const MATERIALS_TOTALS = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/materials_totals.gd")
const MATERIAL_ICON = preload("res://items/materials/material_ui.png")
const OTHER_ICON = preload("res://items/materials/material_bag_icon.png")


var _refresh_pending: bool = false


# =============================================================================
# Base Class Overrides
# Meter-specific hooks called by Meter.
# =============================================================================
#region Base Class Overrides

func discover_sources() -> void:
	add_source("pickups", MATERIAL_ICON, {}, null, Utils.GOLD_COLOR)
	add_source("harvesting", ItemService.get_stat(Keys.stat_harvesting_hash).small_icon, {})
	add_source("other", OTHER_ICON, {})
	add_material_source(ItemService.get_item_from_id(Keys.item_metal_detector_hash))
	for item_data in RunData.get_player_weapons(player_index):
		if is_material_source(item_data):
			add_material_source(item_data)
	for item_data in RunData.get_player_items(player_index):
		if is_material_source(item_data):
			add_material_source(item_data)
	if not RunData.is_connected("gold_changed", self, "on_materials_changed"):
		RunData.connect("gold_changed", self, "on_materials_changed")


func update_totals() -> void:
	if player_index >= RunData.materials_meter_gains.size():
		return
	var pickups = RunData.materials_meter_pickups[player_index]
	set_source_total("pickups", pickups)
	var generated = 0
	for source_key in sources:
		var data = sources[source_key].data
		if not data.has("item"):
			continue
		var total = get_material_total(data.item) - data.wave_start_value
		if data.item.my_id_hash == Keys.item_metal_detector_hash:
			total = RunData.materials_meter_pickup_bonuses[player_index]
		set_source_total(source_key, total)
		generated += get_source_total(source_key)
	var totals = MATERIALS_TOTALS.split(RunData.materials_meter_gains[player_index], pickups, RunData.materials_meter_harvesting[player_index], generated)
	set_source_total("harvesting", totals["harvesting"])
	set_source_total("other", totals["other"])

#endregion


func is_material_source(item_data: ItemParentData) -> bool:
	return item_data.tracking_text == "MATERIALS_GAINED"


func add_material_source(item_data: ItemParentData) -> void:
	var source_key = "item:%s" % item_data.my_id
	if item_data.get_category() == Category.WEAPON:
		source_key = "weapon:%s" % item_data.get_instance_id()
	if sources.has(source_key):
		return
	var source_data = {"item": item_data, "wave_start_value": get_material_total(item_data)}
	add_source(source_key, item_data.icon, source_data, item_data)


func get_material_total(item_data: ItemParentData) -> int:
	if item_data.get_category() == Category.WEAPON:
		return item_data.tracked_value
	var tracked = RunData.tracked_item_effects[player_index].get(item_data.my_id_hash, 0)
	if tracked is Array:
		var total = 0
		for value in tracked:
			total += value
		return total
	return tracked


func on_materials_changed(_new_value: int, index: int) -> void:
	if index == player_index and RunData.materials_meter_active and not _refresh_pending:
		_refresh_pending = true
		call_deferred("_refresh_materials")


func _refresh_materials() -> void:
	_refresh_pending = false
	if RunData.materials_meter_active:
		refresh_sources()
