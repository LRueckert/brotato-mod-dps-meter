class_name HealingMeter
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter.gd"


# =============================================================================
# Base Class Overrides
# Meter-specific hooks called by Meter.
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
				if not sources.has(source):
					add_healing_source(source)
				set_source_total(source, player.healing_meter_totals[source])
			break

#endregion


func is_healing_source(item_data: ItemParentData) -> bool:
	return item_data.tracking_text == "HEALTH_RECOVERED" or item_data.my_id == "item_torture"


func add_healing_source(source: String) -> void:
	if sources.has(source):
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
