extends "res://singletons/run_data.gd"

# Spawner crediting (ADR 0001). Gives each weapon its own tagged copy of its
# StructureEffects, credits hits under Spawner tracking keys to a per-player
# ledger, and forwards them to the base game's own tracking key.

const SPAWNER_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/spawner_credit.gd")


var dmgmeter_spawner_ledgers: Array = []
# Spawner tracking key hash -> {"spawner_key": String, "base_key_hash": int}
var _dmgmeter_spawner_tracking_keys: Dictionary = {}


# Returns the tracking key hash a Structure spawned by spawner_key uses instead
# of base_key_hash (the key the base game would have used).
func dmgmeter_spawner_tracking_hash(spawner_key: String, base_key_hash: int) -> int:
	var tracking_hash = Keys.generate_hash(SPAWNER_CREDIT.tracking_name(spawner_key, base_key_hash))
	if not _dmgmeter_spawner_tracking_keys.has(tracking_hash):
		_dmgmeter_spawner_tracking_keys[tracking_hash] = {"spawner_key": spawner_key, "base_key_hash": base_key_hash}
	return tracking_hash


func dmgmeter_spawner_credit_reset() -> void:
	dmgmeter_spawner_ledgers = []
	for _index in get_player_count():
		dmgmeter_spawner_ledgers.append(SPAWNER_CREDIT.new_ledger())


func dmgmeter_spawner_ledger(player_index: int) -> Dictionary:
	if player_index < 0 or player_index >= dmgmeter_spawner_ledgers.size():
		return SPAWNER_CREDIT.new_ledger()
	return dmgmeter_spawner_ledgers[player_index]


func add_tracked_value(player_index: int, tracking_key: int, value: float, index: int = 0) -> void:
	var spawner = _dmgmeter_spawner_tracking_keys.get(tracking_key)
	if spawner == null:
		.add_tracked_value(player_index, tracking_key, value, index)
		return
	var base_key_hash = spawner["base_key_hash"]
	if player_index >= 0 and player_index < dmgmeter_spawner_ledgers.size():
		SPAWNER_CREDIT.record(dmgmeter_spawner_ledgers[player_index], spawner["spawner_key"], base_key_hash, value)
	# The base game keeps its own totals (item tooltips, run stats) as before.
	if player_index >= 0 and player_index < tracked_item_effects.size() and tracked_item_effects[player_index].has(base_key_hash):
		.add_tracked_value(player_index, base_key_hash, value, index)


func add_weapon(weapon: WeaponData, player_index: int, is_selection: bool = false) -> WeaponData:
	var new_weapon = .add_weapon(weapon, player_index, is_selection)
	var structures = get_player_effect(Keys.structures_hash, player_index)
	new_weapon.effects = SPAWNER_CREDIT.own_effects(new_weapon.effects, SPAWNER_CREDIT.weapon_key(new_weapon.get_instance_id()), structures)
	return new_weapon


func remove_weapon(weapon: WeaponData, player_index: int) -> int:
	var removed_weapon = null
	for current_weapon in players_data[player_index].weapons:
		if ItemService.is_same_weapon(current_weapon, weapon):
			removed_weapon = current_weapon
			break
	var removed_weapon_tracked_value = .remove_weapon(weapon, player_index)
	if removed_weapon != null and removed_weapon != weapon and players_data[player_index].weapons.has(weapon):
		SPAWNER_CREDIT.adopt_structure_effects(weapon.effects, removed_weapon.effects, SPAWNER_CREDIT.weapon_key(weapon.get_instance_id()))
	return removed_weapon_tracked_value


# Resumed weapons already hold their own deserialized effects, which are also
# the objects in the structures list, so they only need their tags again.
func resume_from_state(state: Dictionary) -> void:
	.resume_from_state(state)
	for player_data in players_data:
		for weapon in player_data.weapons:
			SPAWNER_CREDIT.tag_effects(weapon.effects, SPAWNER_CREDIT.weapon_key(weapon.get_instance_id()))


func reset(restart: bool = false) -> void:
	dmgmeter_spawner_ledgers = []
	.reset(restart)
