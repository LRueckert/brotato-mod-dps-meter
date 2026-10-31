class_name DmgMeterContainer
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_container.gd"

# =============================================================================
# Base Class Overrides
# List-specific hooks called by MeterListContainer.
# =============================================================================
#region Base Class Overrides

func discover_sources() -> void:
	for element in RunData.get_player_weapons(player_index):
		add_element(element)
	for element in RunData.get_player_items(player_index):
		if is_damage_source(element):
			add_element(element)


func update_totals() -> void:
	for child in rows_container.get_children():
		child.set_total(max(child.get_total(), get_damage_total(child)))

#endregion


func is_damage_source(element: ItemParentData) -> bool:
	return element.tracking_text in ["DAMAGE_DEALT", "EXPLOSION_DAMAGE_DEALT"] or element.name == "ITEM_BUILDER_TURRET"


func has_item(item_id: String) -> bool:
	for data in rows.values():
		if data.item.my_id == item_id:
			return true
	return false


func add_element(element: ItemParentData) -> void:
	if element.get_category() != Category.WEAPON and has_item(element.my_id):
		return
	if ["WEAPON_WRENCH", "WEAPON_SCREWDRIVER", "ITEM_BOT_O_MINE"].has(element.name):
		handle_spawner(element)
	var instance = create_row()
	instance.set_element(element.icon, player_index, Text.text(element.name))
	instance.update_background_color(element)
	var wave_start_value = 0
	if [Category.ITEM, Category.CHARACTER].has(element.get_category()) && not element.name == "ITEM_BUILDER_TURRET":
		wave_start_value = get_tracked_value(element)
	rows[instance] = {"item": element, "wave_start_value": wave_start_value}


func handle_spawner(element: ItemParentData) -> void:
	match element.name:
		"WEAPON_SCREWDRIVER":
			if not has_item("item_landmines"):
				add_element(ItemService.get_item_from_id(Keys.generate_hash("item_landmines")))
		"ITEM_BOT_O_MINE":
			if not has_item("item_landmines"):
				add_element(ItemService.get_item_from_id(Keys.generate_hash("item_landmines")))
		"WEAPON_WRENCH":
			match element.tier:
				Tier.COMMON:
					if not has_item("item_turret"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret")))
				Tier.UNCOMMON:
					if not has_item("item_turret_flame"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret_flame")))
				Tier.RARE:
					if not has_item("item_turret_laser"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret_laser")))
				Tier.LEGENDARY:
					if not has_item("item_turret_rocket"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret_rocket")))


func get_damage_total(row) -> int:
	var data = rows[row]
	var element: ItemParentData = data.item
	if element.get_category() == Category.WEAPON:
		return element.dmg_dealt_last_wave
	return get_tracked_value(element) - data.wave_start_value


func get_tracked_value(element: ItemParentData) -> int:
	return sum_tracked_value(RunData.tracked_item_effects[player_index].get(element.my_id_hash, 0))


func sum_tracked_value(tracked) -> int:
	var value = 0
	if tracked is Array:
		for total in tracked:
			value += total
	else:
		value = tracked
	return value
