class_name HealingMeterContainer
extends "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_list_container.gd"


# =============================================================================
# Base Class Overrides
# List-specific hooks called MeterListContainer.
# =============================================================================
#region Base Class Overrides

func discover_sources() -> void:
	for source in ["regeneration", "lifesteal", "consumables"]:
		set_total(source, 0)
	for item in RunData.get_player_items(player_index):
		if item.tracking_text == "HEALTH_RECOVERED" or item.my_id == "item_torture":
			var source = str(item.my_id_hash)
			if not rows.has(source):
				set_total(source, 0)


func update_totals() -> void:
	for player in get_tree().get_nodes_in_group("dmgmeter_healing_players"):
		if player.player_index == player_index:
			for source in player.healing_meter_totals:
				set_total(source, player.healing_meter_totals[source])
			break

#endregion


func set_total(source: String, total: int) -> void:
	if not rows.has(source):
		var row = create_row()
		set_healing_source(row, source)
		rows[source] = row
	rows[source].set_total(max(rows[source].get_total(), total))


func set_healing_source(row, source: String) -> void:
	var texture: Texture = null
	var tooltip = ""
	var item: ItemParentData = null
	match source:
		"regeneration":
			texture = ItemService.get_stat(Keys.stat_hp_regeneration_hash).small_icon
			tooltip = Text.text("STAT_HP_REGENERATION")
		"lifesteal":
			texture = ItemService.get_stat(Keys.stat_lifesteal_hash).small_icon
			tooltip = Text.text("STAT_LIFESTEAL")
		"consumables":
			texture = load("res://items/consumables/fruit/fruit_data.tres").icon
			tooltip = "Consumables"
		_:
			tooltip = "Other healing"
			texture = ItemService.get_stat(Keys.stat_hp_regeneration_hash).small_icon
			if source.is_valid_integer():
				for item_data in ItemService.items:
					if item_data.my_id_hash == int(source):
						item = item_data
						texture = item.icon
						tooltip = Text.text(item.name)
						break
	row.set_element(texture, player_index, tooltip)
	row.update_background_color(item)