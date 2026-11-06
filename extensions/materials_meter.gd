extends "res://main.gd"


func _enter_tree() -> void:
	var meter_panel_scene = load("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_panel.tscn")
	for index in 4:
		var player_number = str(index + 1)
		var parent = get_node("UI/HUD/LifeContainerP%s" % player_number)
		var node_name = "MeterPanelP%s" % player_number
		if parent.has_node(node_name):
			continue
		var meter_panel = meter_panel_scene.instance()
		meter_panel.name = node_name
		parent.add_child(meter_panel)


func on_gold_picked_up(gold: Node, player_index: int) -> void:
	if not RunData.materials_meter_active or gold.already_picked_up or player_index < 0:
		.on_gold_picked_up(gold, player_index)
		return
	var value = gold.value
	var increase = RunData.get_player_effect(Keys.increase_material_value_hash, player_index)
	value += value * (increase / 100.0)
	var first_player = _next_gold_player
	var context = {"boost": 1}
	RunData.materials_meter_pickup_contexts.append(context)
	.on_gold_picked_up(gold, player_index)
	RunData.materials_meter_pickup_contexts.pop_back()
	RunData.materials_meter_record_pickup(value, context.boost, first_player)