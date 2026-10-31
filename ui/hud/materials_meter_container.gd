class_name MaterialsMeterContainer
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_container.gd"


const MATERIAL_ICON = preload("res://items/materials/material_ui.png")


# =============================================================================
# Base Class Overrides
# List-specific hooks called by MeterListContainer.
# =============================================================================
#region Base Class Overrides

func discover_sources() -> void:
	add_source("pickups", MATERIAL_ICON, {})
	add_source("other", ItemService.get_stat(Keys.stat_harvesting_hash).small_icon, {})
	add_material_source(ItemService.get_item_from_id(Keys.item_metal_detector_hash))
	for element in RunData.get_player_weapons(player_index):
		if is_material_source(element):
			add_material_source(element)
	for element in RunData.get_player_items(player_index):
		if is_material_source(element):
			add_material_source(element)
	if not RunData.is_connected("gold_changed", self, "on_materials_changed"):
		RunData.connect("gold_changed", self, "on_materials_changed")


func update_totals() -> void:
	if player_index >= RunData.material_meter_gains.size():
		return
	var pickups = RunData.material_meter_pickups[player_index]
	set_source_total("pickups", pickups)
	var generated = 0
	for source_key in rows:
		var data = rows[source_key].data
		if not data.has("item"):
			continue
		var total = get_material_total(data.item) - data.wave_start_value
		if data.item.my_id_hash == Keys.item_metal_detector_hash:
			total = RunData.material_meter_pickup_bonuses[player_index]
		set_source_total(source_key, total)
		generated += rows[source_key].row.get_total()
	set_source_total("other", RunData.material_meter_gains[player_index] - pickups - generated)

#endregion


func is_material_source(element: ItemParentData) -> bool:
	return element.tracking_text == "MATERIALS_GAINED"


func add_material_source(element: ItemParentData) -> void:
	var source_key = "item:%s" % element.my_id
	if element.get_category() == Category.WEAPON:
		source_key = "weapon:%s" % element.get_instance_id()
	if rows.has(source_key):
		return
	var source_data = {"item": element, "wave_start_value": get_material_total(element)}
	add_source(source_key, element.icon, source_data, element)


func get_material_total(element: ItemParentData) -> int:
	if element.get_category() == Category.WEAPON:
		return element.tracked_value
	var tracked = RunData.tracked_item_effects[player_index].get(element.my_id_hash, 0)
	if tracked is Array:
		var total = 0
		for value in tracked:
			total += value
		return total
	return tracked


func on_materials_changed(_new_value: int, index: int) -> void:
	if index == player_index and RunData.material_meter_active:
		call_deferred("trigger_element_updates")