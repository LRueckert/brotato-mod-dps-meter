extends "res://entities/structures/dart_trap/dart_trap.gd"

# Spawner crediting (ADR 0001): a dart trap spawned from a tagged StructureEffect
# (Awl) tracks its darts under its Spawner's tracking key. Untagged traps (the
# Dart Trap item) have an empty tracking key in the base game, so their hits
# were dropped; they fall back to the Dart Trap item's key.

const SPAWNER_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/spawner_credit.gd")
const DART_TRAP_FALLBACK_KEY = "item_dart_trap"


func set_data(data: Resource) -> void:
	.set_data(data)
	_damage_tracking_key_hash = SPAWNER_CREDIT.structure_tracking_hash(data, _damage_tracking_key_hash, RunData)
	if _damage_tracking_key_hash == Keys.empty_hash:
		_damage_tracking_key_hash = Keys.generate_hash(DART_TRAP_FALLBACK_KEY)
