extends "res://entities/units/player/player.gd"


var healing_meter_totals: Dictionary = {}
var healing_meter_source: String = ""


func _ready() -> void:
	add_to_group("dmgmeter_healing_players")
	healing_meter_totals.clear()


func _on_ItemPickupArea_area_entered(area: Area2D) -> void:
	var previous_source = healing_meter_source
	healing_meter_source = "consumables"
	._on_ItemPickupArea_area_entered(area)
	healing_meter_source = previous_source


func on_health_regen(loop_count: int) -> void:
	var previous_source = healing_meter_source
	healing_meter_source = "regeneration"
	.on_health_regen(loop_count)
	healing_meter_source = previous_source


func on_lifesteal_effect(value: int) -> void:
	var previous_source = healing_meter_source
	healing_meter_source = "lifesteal"
	.on_lifesteal_effect(value)
	healing_meter_source = previous_source


func on_heal_over_time_timer_timeout() -> void:
	var previous_source = healing_meter_source
	healing_meter_source = "consumables"
	.on_heal_over_time_timer_timeout()
	healing_meter_source = previous_source


func on_healing_effect(value: int, tracking_key: int = Keys.empty_hash, from_torture: bool = false) -> int:
	var source = healing_meter_source
	if tracking_key != Keys.empty_hash:
		source = str(tracking_key)
	elif from_torture:
		source = str(Keys.generate_hash("item_torture"))
	elif source.empty():
		source = "other"
	var healed = .on_healing_effect(value, tracking_key, from_torture)
	if healed > 0 and not cleaning_up:
		healing_meter_totals[source] = healing_meter_totals.get(source, 0) + healed
	return healed