extends "res://entities/structures/landmine/landmine.gd"

# Spawner crediting (ADR 0001): a mine spawned from a tagged StructureEffect
# (Screwdriver, Carbon Bow, Bot-o-Mine) explodes with its own copy of the shared
# explosion effect, tracked under its Spawner's tracking key. Base set_data
# resets effects to the data's shared array on every spawn, pooled mines included.

const SPAWNER_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/spawner_credit.gd")


func set_data(data: Resource) -> void:
	.set_data(data)
	var spawner_key = SPAWNER_CREDIT.spawner_key_of(data)
	if spawner_key.empty() or effects.empty():
		return
	var base_key_hash = effects[0].tracking_key_hash
	var tracking_name = SPAWNER_CREDIT.tracking_name(spawner_key, base_key_hash)
	effects = SPAWNER_CREDIT.retrack_explosion(effects, tracking_name, RunData.dmgmeter_spawner_tracking_hash(spawner_key, base_key_hash))
