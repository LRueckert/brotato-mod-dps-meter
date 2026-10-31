class_name HealingMeterContainer
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_container.gd"


# =============================================================================
# Base Class Overrides
# List-specific hooks called MeterListContainer.
# =============================================================================
#region Base Class Overrides

func discover_sources() -> void:
	for source in ["regeneration", "lifesteal", "consumables"]:
		add_healing_source(source)
	for item in RunData.get_player_items(player_index):
		if is_healing_source(item):
			var source = str(item.my_id_hash)
			add_healing_source(source)


func update_totals() -> void:
	for player in get_tree().get_nodes_in_group("dmgmeter_healing_players"):
		if player.player_index == player_index:
			for source in player.healing_meter_totals:
				if not rows.has(source):
					add_healing_source(source)
				set_source_total(source, player.healing_meter_totals[source])
			break

#endregion


func is_healing_source(element: ItemParentData) -> bool:
	return element.tracking_text == "HEALTH_RECOVERED" or element.my_id == "item_torture"


func add_healing_source(source: String) -> void:
	if rows.has(source):
		return
	var texture: Texture = null
	var item: ItemParentData = null
	match source:
		"regeneration":
			texture = ItemService.get_stat(Keys.stat_hp_regeneration_hash).small_icon
		"lifesteal":
			texture = ItemService.get_stat(Keys.stat_lifesteal_hash).small_icon
		"consumables":
			texture = load("res://items/consumables/fruit/fruit_data.tres").icon
		_:
			texture = ItemService.get_stat(Keys.stat_hp_regeneration_hash).small_icon
			if source.is_valid_integer():
				for item_data in ItemService.items:
					if item_data.my_id_hash == int(source):
						item = item_data
						texture = item.icon
						break
	add_source(source, texture, {"item": item}, item)