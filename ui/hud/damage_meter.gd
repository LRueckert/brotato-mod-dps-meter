class_name DamageMeter
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter.gd"

# =============================================================================
# Base Class Overrides
# Meter-specific hooks called by Meter.
# =============================================================================
#region Base Class Overrides

func discover_sources() -> void:
	for item_data in RunData.get_player_weapons(player_index):
		add_damage_source(item_data)
	for item_data in RunData.get_player_items(player_index):
		if is_damage_source(item_data):
			add_damage_source(item_data)


func update_totals() -> void:
	for source_key in sources:
		set_source_total(source_key, get_damage_total(source_key))

#endregion


func is_damage_source(item_data: ItemParentData) -> bool:
	return item_data.tracking_text in ["DAMAGE_DEALT", "EXPLOSION_DAMAGE_DEALT"] or item_data.name == "ITEM_BUILDER_TURRET"


func add_damage_source(item_data: ItemParentData) -> void:
	var source_key = "item:%s" % item_data.my_id
	if item_data.get_category() == Category.WEAPON:
		source_key = "weapon:%s" % item_data.get_instance_id()
	if sources.has(source_key):
		return
	if ["WEAPON_WRENCH", "WEAPON_SCREWDRIVER", "ITEM_BOT_O_MINE"].has(item_data.name):
		handle_spawner(item_data)
	var wave_start_value = 0
	if [Category.ITEM, Category.CHARACTER].has(item_data.get_category()) && not item_data.name == "ITEM_BUILDER_TURRET":
		wave_start_value = get_tracked_value(item_data)
	var source_data = {"item": item_data, "wave_start_value": wave_start_value}
	add_source(source_key, item_data.icon, source_data, item_data)


func handle_spawner(item_data: ItemParentData) -> void:
	var item_id = ""
	match item_data.name:
		"WEAPON_SCREWDRIVER", "ITEM_BOT_O_MINE":
			item_id = "item_landmines"
		"WEAPON_WRENCH":
			match item_data.tier:
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
	var data = sources[source_key].data
	var item_data: ItemParentData = data.item
	if item_data.get_category() == Category.WEAPON:
		return item_data.dmg_dealt_last_wave
	return get_tracked_value(item_data) - data.wave_start_value


func get_tracked_value(item_data: ItemParentData) -> int:
	return sum_tracked_value(RunData.tracked_item_effects[player_index].get(item_data.my_id_hash, 0))


func sum_tracked_value(tracked) -> int:
	var value = 0
	if tracked is Array:
		for total in tracked:
			value += total
	else:
		value = tracked
	return value
