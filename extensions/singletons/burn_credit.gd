extends "res://singletons/run_data.gd"

# Burn crediting (ADR 0001). Turrets spawned by a Spawner tag their own burns
# with a burn tracking key; the base game's burn tick credits that key, and
# this credits the Spawner on its Structure's player's ledger and forwards the
# value to the base game's own key. The burn tick hook in unit.gd refunds the
# blanket item_turret_flame credit. Needs the ledgers from extensions/singletons/spawner_credit.gd.

const DMGMETER_BURN_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/burn_credit.gd")


# Burn tracking key hash -> {"spawner_key": String, "base_key_hash": int,
# "structure_player_index": int, "own_tracking_key": String}
var _dmgmeter_burn_tracking_keys: Dictionary = {}
# "<player_index>|<base key hash>" -> value forwarded by burn ticks, run total.
var _dmgmeter_burn_forwarded: Dictionary = {}


# Returns the burn tracking key a Spawner's turret tags its burn with.
# own_tracking_key is the burn's tracking key without the mod.
func dmgmeter_burn_tracking_name(spawner_key: String, base_key_hash: int, structure_player_index: int, own_tracking_key: String) -> String:
	var tracking_name = DMGMETER_BURN_CREDIT.tracking_name(spawner_key, base_key_hash, structure_player_index)
	var tracking_hash = Keys.generate_hash(tracking_name)
	if not _dmgmeter_burn_tracking_keys.has(tracking_hash):
		_dmgmeter_burn_tracking_keys[tracking_hash] = {"spawner_key": spawner_key, "base_key_hash": base_key_hash, "structure_player_index": structure_player_index, "own_tracking_key": own_tracking_key}
	return tracking_name


func dmgmeter_is_burn_tracking_hash(tracking_key: int) -> bool:
	return _dmgmeter_burn_tracking_keys.has(tracking_key)


# The tracking key a burn has without the mod, for tagged and untagged burns.
func dmgmeter_burn_own_tracking_key(tracking_key: String) -> String:
	var burn = _dmgmeter_burn_tracking_keys.get(Keys.generate_hash(tracking_key))
	return burn["own_tracking_key"] if burn != null else tracking_key


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
	var structure_player_index = burn["structure_player_index"]
	var player_count = get_player_count()
	if structure_player_index >= 0 and structure_player_index < player_count and player_index >= 0 and player_index < player_count:
		var offset_key = base_key_hash if forwarded else Keys.empty_hash
		# Declared by the spawner_credit.gd extension, so called through the singleton.
		DMGMETER_BURN_CREDIT.record(RunData.dmgmeter_spawner_ledger(structure_player_index), RunData.dmgmeter_spawner_ledger(player_index), burn["spawner_key"], offset_key, Keys.empty_hash, value)
	if forwarded:
		var forwarded_key = "%s|%s" % [player_index, base_key_hash]
		_dmgmeter_burn_forwarded[forwarded_key] = _dmgmeter_burn_forwarded.get(forwarded_key, 0) + int(value)
		.add_tracked_value(player_index, base_key_hash, value, index)


func reset(restart: bool = false) -> void:
	_dmgmeter_burn_forwarded = {}
	.reset(restart)
