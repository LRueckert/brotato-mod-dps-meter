class_name HealingMeterContainer
extends VBoxContainer


export(PackedScene) var element_scene = null

var player_index: int = 0
var max_items: int = 0
var rows: Dictionary = {}
onready var rows_container: VBoxContainer = $Rows
onready var heading: TextureRect = $Heading


func set_player(index: int, player_count: int) -> void:
	player_index = index
	max_items = 0 if player_count < 3 else 6
	heading.size_flags_horizontal = 0 if index == 0 or index == 2 else Control.SIZE_SHRINK_END
	for source in ["regeneration", "lifesteal", "consumables"]:
		set_total(source, 0)


func set_total(source: String, total: int) -> void:
	if not rows.has(source):
		var row = element_scene.instance()
		rows_container.add_child(row)
		set_healing_source(row, source)
		rows[source] = row
	rows[source].set_total(total)


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


func trigger_element_updates() -> void:
	for player in get_tree().get_nodes_in_group("dmgmeter_healing_players"):
		if player.player_index == player_index:
			for source in player.healing_meter_totals:
				set_total(source, player.healing_meter_totals[source])
			break
	var sorted_rows = rows.values()
	sorted_rows.sort_custom(self, "compare_rows")
	for index in sorted_rows.size():
		rows_container.move_child(sorted_rows[index], index)
		sorted_rows[index].visible = max_items == 0 or index < max_items


func compare_rows(first, second) -> bool:
	if first.get_total() == second.get_total():
		return first.hint_tooltip < second.hint_tooltip
	return first.get_total() > second.get_total()