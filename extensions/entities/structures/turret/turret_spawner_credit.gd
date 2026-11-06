extends "res://entities/structures/turret/turret.gd"

# Spawner crediting (ADR 0001): a turret spawned from a tagged StructureEffect
# tracks its hits under its Spawner's tracking key. set_data runs on every
# spawn, pooled turrets included, so the key is never stale.

const SPAWNER_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/spawner_credit.gd")


func set_data(data: Resource) -> void:
	.set_data(data)
	var spawner_key = SPAWNER_CREDIT.spawner_key_of(data)
	if not spawner_key.empty():
		_damage_tracking_key_hash = RunData.dmgmeter_spawner_tracking_hash(spawner_key, _damage_tracking_key_hash)
