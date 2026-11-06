extends "res://singletons/run_data.gd"

# Burn crediting (ADR 0001). Turrets spawned by a Spawner tag their own burns
# with a burn tracking key; the base game's burn tick credits that key, and
# this credits the Spawner on its owner's ledger and forwards the value to the
# base game's own key. The burn tick hook in unit.gd refunds the blanket
# item_turret_flame credit. Needs the ledgers from extensions/singletons/spawner_credit.gd.

const DMGMETER_BURN_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/burn_credit.gd")


# Burn tracking key hash -> {"spawner_key": String, "base_key_hash": int, "owner": int}
var _dmgmeter_burn_tracking_keys: Dictionary = {}
# "<player_index>|<base key hash>" -> value forwarded by burn ticks, run total.
var _dmgmeter_burn_forwarded: Dictionary = {}


func dmgmeter_burn_tracking_hash(spawner_key: String, base_key_hash: int, owner_index: int) -> int:
	var tracking_hash = Keys.generate_hash(DMGMETER_BURN_CREDIT.tracking_name(spawner_key, base_key_hash, owner_index))
	if not _dmgmeter_burn_tracking_keys.has(tracking_hash):
		_dmgmeter_burn_tracking_keys[tracking_hash] = {"spawner_key": spawner_key, "base_key_hash": base_key_hash, "owner": owner_index}
	return tracking_hash


func dmgmeter_is_burn_tracking_hash(tracking_key: int) -> bool:
	return _dmgmeter_burn_tracking_keys.has(tracking_key)


func dmgmeter_burn_forwarded(player_index: int, base_key_hash: int) -> int:
	return _dmgmeter_burn_forwarded.get("%s|%s" % [player_index, base_key_hash], 0)


func dmgmeter_tracked_int(player_index: int, tracking_key: int) -> int:
	if player_index < 0 or player_index >= tracked_item_effects.size():
		return 0
	var value = tracked_item_effects[player_index].get(tracking_key, 0)
	return value if value is int else 0


func dmgmeter_untrack(player_index: int, tracking_key: int, amount: int) -> void:
	if amount == 0 or player_index < 0 or player_index >= tracked_item_effects.size():
		return
	if tracked_item_effects[player_index].get(tracking_key) is int:
		tracked_item_effects[player_index][tracking_key] -= amount


func add_tracked_value(player_index: int, tracking_key: int, value: float, index: int = 0) -> void:
	var burn = _dmgmeter_burn_tracking_keys.get(tracking_key)
	if burn == null:
		.add_tracked_value(player_index, tracking_key, value, index)
		return
	var base_key_hash = burn["base_key_hash"]
	var forwarded = player_index >= 0 and player_index < tracked_item_effects.size() and tracked_item_effects[player_index].has(base_key_hash)
	var owner_index = burn["owner"]
	# Declared by the spawner_credit.gd extension, which may sit above this one.
	var ledgers = get("dmgmeter_spawner_ledgers")
	if ledgers is Array and owner_index >= 0 and owner_index < ledgers.size() and player_index >= 0 and player_index < ledgers.size():
		var offset_key = base_key_hash if forwarded else Keys.empty_hash
		DMGMETER_BURN_CREDIT.record(ledgers[owner_index], ledgers[player_index], burn["spawner_key"], offset_key, Keys.empty_hash, value)
	if forwarded:
		var forwarded_key = "%s|%s" % [player_index, base_key_hash]
		_dmgmeter_burn_forwarded[forwarded_key] = _dmgmeter_burn_forwarded.get(forwarded_key, 0) + int(value)
		.add_tracked_value(player_index, base_key_hash, value, index)


func reset(restart: bool = false) -> void:
	_dmgmeter_burn_forwarded = {}
	.reset(restart)
