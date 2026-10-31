extends "res://singletons/run_data.gd"


var material_meter_gains: Array = []
var material_meter_pickups: Array = []
var material_meter_pickup_bonuses: Array = []
var material_meter_pickup_contexts: Array = []
var material_meter_active: bool = false


func material_meter_reset() -> void:
	material_meter_gains.clear()
	material_meter_pickups.clear()
	material_meter_pickup_bonuses.clear()
	material_meter_pickup_contexts.clear()
	for index in get_player_count():
		material_meter_gains.append(0)
		material_meter_pickups.append(0)
		material_meter_pickup_bonuses.append(0)
	material_meter_active = true


func add_gold(value: int, player_index: int) -> void:
	if material_meter_active and value > 0 and player_index >= 0 and player_index < material_meter_gains.size():
		material_meter_gains[player_index] += value
	.add_gold(value, player_index)


func apply_common_gold_pickup_effects(value: int, player_index: int) -> int:
	var boost = .apply_common_gold_pickup_effects(value, player_index)
	if not material_meter_pickup_contexts.empty():
		var context = material_meter_pickup_contexts.back()
		context.boost = boost
	return boost


func material_meter_record_pickup(value: float, boost: int, first_player: int) -> void:
	var player_count = get_player_count()
	var total = int(ceil(max(0, value * boost)))
	var base_total = min(int(ceil(max(0, value))), total)
	var bonus_total = total - base_total
	var bonus_first_player = (first_player + base_total) % player_count
	for index in player_count:
		var base_position = posmod(index - first_player, player_count)
		var bonus_position = posmod(index - bonus_first_player, player_count)
		material_meter_pickups[index] += int(base_total / player_count) + int(base_position < base_total % player_count)
		material_meter_pickup_bonuses[index] += int(bonus_total / player_count) + int(bonus_position < bonus_total % player_count)