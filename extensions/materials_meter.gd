extends "res://main.gd"


func on_gold_picked_up(gold: Node, player_index: int) -> void:
	if not RunData.material_meter_active or gold.already_picked_up or player_index < 0:
		.on_gold_picked_up(gold, player_index)
		return
	var value = gold.value
	var increase = RunData.get_player_effect(Keys.increase_material_value_hash, player_index)
	value += value * (increase / 100.0)
	var first_player = _next_gold_player
	var context = {"boost": 1}
	RunData.material_meter_pickup_contexts.append(context)
	.on_gold_picked_up(gold, player_index)
	RunData.material_meter_pickup_contexts.pop_back()
	RunData.material_meter_record_pickup(value, context.boost, first_player)