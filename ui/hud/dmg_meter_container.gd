class_name DmgMeterContainer
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_container.gd"

# =============================================================================
# Base Class Overrides
# List-specific hooks called by MeterListContainer.
# =============================================================================
#region Base Class Overrides

func discover_sources() -> void:
	for element in RunData.get_player_weapons(player_index):
		add_damage_source(element)
	for element in RunData.get_player_items(player_index):
		if is_damage_source(element):
			add_damage_source(element)


func update_totals() -> void:
	for source_key in rows:
		set_source_total(source_key, get_damage_total(source_key))

#endregion


func is_damage_source(element: ItemParentData) -> bool:
	return element.tracking_text in ["DAMAGE_DEALT", "EXPLOSION_DAMAGE_DEALT"] or element.name == "ITEM_BUILDER_TURRET"


func add_damage_source(element: ItemParentData) -> void:
	var source_key = "item:%s" % element.my_id
	if element.get_category() == Category.WEAPON:
		source_key = "weapon:%s" % element.get_instance_id()
	if rows.has(source_key):
		return
	if ["WEAPON_WRENCH", "WEAPON_SCREWDRIVER", "ITEM_BOT_O_MINE"].has(element.name):
		handle_spawner(element)
	var wave_start_value = 0
	if [Category.ITEM, Category.CHARACTER].has(element.get_category()) && not element.name == "ITEM_BUILDER_TURRET":
		wave_start_value = get_tracked_value(element)
	var source_data = {"item": element, "wave_start_value": wave_start_value}
	add_source(source_key, element.icon, source_data, element)


func handle_spawner(element: ItemParentData) -> void:
	var item_id = ""
	match element.name:
		"WEAPON_SCREWDRIVER", "ITEM_BOT_O_MINE":
			item_id = "item_landmines"
		"WEAPON_WRENCH":
			match element.tier:
				Tier.COMMON:
					item_id = "item_turret"
				Tier.UNCOMMON:
					item_id = "item_turret_flame"
				Tier.RARE:
					item_id = "item_turret_laser"
				Tier.LEGENDARY:
					item_id = "item_turret_rocket"
	if not item_id.empty():
		add_damage_source(ItemService.get_item_from_id(Keys.generate_hash(item_id)))


func get_damage_total(source_key: String) -> int:
	var data = rows[source_key].data
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
