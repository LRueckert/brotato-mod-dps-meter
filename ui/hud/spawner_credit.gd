extends Reference

# Pure Spawner crediting logic (ADR 0001). No game globals, nodes, or textures,
# so headless tests in tools/tests/ can load it. Game hooks call these helpers.
#
# A Spawner key names the Spawner and equals its Damage Meter Source key
# ("weapon:<WeaponData instance id>" or "item:<item id>"). It is stored as meta
# on the StructureEffect a Structure spawns from. At spawn, the Structure swaps
# its tracking key for Keys.generate_hash(tracking_name(spawner_key, base_hash)),
# and RunData's add_tracked_value override credits the Spawner in a per-player
# ledger before forwarding the value to the base game's own key.

const META_SPAWNER_KEY = "dmgmeter_spawner"
const TRACKING_PREFIX = "dmgmeter_spawner|"


static func weapon_key(weapon_instance_id: int) -> String:
	return "weapon:%s" % weapon_instance_id


static func item_key(item_id: String) -> String:
	return "item:%s" % item_id


# The name a Structure tracks its hits under. base_key_hash is the key the
# base game would have used, so the value can still be forwarded there.
static func tracking_name(spawner_key: String, base_key_hash: int) -> String:
	return "%s%s|%s" % [TRACKING_PREFIX, spawner_key, base_key_hash]


static func spawner_key_of(effect) -> String:
	if effect == null or not effect.has_meta(META_SPAWNER_KEY):
		return ""
	return str(effect.get_meta(META_SPAWNER_KEY))


# The tracking key hash a Structure spawned from data uses for its hits:
# its Spawner's tracking key if data is tagged, otherwise base_key_hash.
# registry is RunData (dmgmeter_spawner_tracking_hash).
static func structure_tracking_hash(data, base_key_hash: int, registry) -> int:
	var spawner_key = spawner_key_of(data)
	if spawner_key.empty():
		return base_key_hash
	return registry.dmgmeter_spawner_tracking_hash(spawner_key, base_key_hash)


static func tag(effect, spawner_key: String) -> void:
	effect.set_meta(META_SPAWNER_KEY, spawner_key)


# A copy of a shared StructureEffect that only this Spawner spawns from.
static func tagged_copy(effect: Resource, spawner_key: String) -> Resource:
	var copy = copy_effect(effect)
	tag(copy, spawner_key)
	return copy


static func is_structure_effect(effect) -> bool:
	return effect is Resource and "spawn_cooldown" in effect and "tracking_key_hash" in effect


# Wrapper effects (e.g. SpawnStructureEveryKilledEnemiesEffect) spawn the
# StructureEffect they hold instead of going through the structures list.
static func is_structure_wrapper(effect) -> bool:
	return effect is Resource and "structure_effect" in effect and effect.structure_effect is Resource


# Shallow duplicate that also keeps non-exported script variables
# (tracking_key_hash, is_cursed, ...), which Resource.duplicate() drops.
static func copy_effect(effect: Resource) -> Resource:
	var copy = effect.duplicate()
	for property in effect.get_property_list():
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE and not property["usage"] & PROPERTY_USAGE_STORAGE:
			copy.set(property["name"], effect.get(property["name"]))
	return copy


# A mine explodes with effects[0] and tracks its hits under that effect's
# tracking_key_hash. Returns a new array whose [0] is a copy tracking under the
# Spawner. tracking_key is set too, because a duplicated exploding effect
# regenerates tracking_key_hash from it a frame later (and so does boost()).
static func retrack_explosion(mine_effects: Array, spawner_tracking_name: String, spawner_tracking_hash: int) -> Array:
	var retracked = mine_effects.duplicate()
	if retracked.empty():
		return retracked
	var explosion = copy_effect(retracked[0])
	explosion.tracking_key = spawner_tracking_name
	explosion.tracking_key_hash = spawner_tracking_hash
	retracked[0] = explosion
	return retracked


# Returns a new effects array in which every StructureEffect, and every
# wrapper's nested StructureEffect, is this Spawner's own tagged copy. Copies
# of StructureEffects replace one occurrence of the original in structures
# (the player's structures list), so the StructureTimer spawns the copy.
static func own_effects(effects: Array, spawner_key: String, structures: Array) -> Array:
	var owned = effects.duplicate()
	for index in owned.size():
		var effect = owned[index]
		if is_structure_effect(effect):
			var copy = copy_effect(effect)
			tag(copy, spawner_key)
			var position = structures.find(effect)
			if position != -1:
				structures[position] = copy
			owned[index] = copy
		elif is_structure_wrapper(effect):
			var wrapper = copy_effect(effect)
			wrapper.structure_effect = copy_effect(effect.structure_effect)
			tag(wrapper.structure_effect, spawner_key)
			owned[index] = wrapper
	return owned


# Tags the StructureEffects (and wrappers' nested ones) a Spawner already owns,
# e.g. after resume_from_state rebuilt them as separate objects.
static func tag_effects(effects: Array, spawner_key: String) -> void:
	for effect in effects:
		if is_structure_effect(effect):
			tag(effect, spawner_key)
		elif is_structure_wrapper(effect):
			tag(effect.structure_effect, spawner_key)


# One player's Spawner credit for the current wave: "credit" maps Spawner keys
# to damage, "forwarded" maps base-game tracking key hashes to the part of
# their tracked value that was really dealt by a Spawner's Structures.
static func new_ledger() -> Dictionary:
	return {"credit": {}, "forwarded": {}}


static func record(ledger: Dictionary, spawner_key: String, base_key_hash: int, value: float) -> void:
	# Truncated per hit, like RunData.add_tracked_value.
	var amount = int(value)
	ledger["credit"][spawner_key] = ledger["credit"].get(spawner_key, 0) + amount
	ledger["forwarded"][base_key_hash] = ledger["forwarded"].get(base_key_hash, 0) + amount


# A Source's Total: its own value, minus what Spawners' Structures added to its
# base-game key (own_key_hash), plus the credit of its own Structures.
static func source_total(ledger: Dictionary, source_key: String, own_total: int, own_key_hash: int = 0) -> int:
	var own = own_total
	if own_key_hash != 0:
		own = int(max(0, own - ledger["forwarded"].get(own_key_hash, 0)))
	return own + ledger["credit"].get(source_key, 0)


# RunData.remove_weapon removes the first identical weapon from the list but
# unapplies the effects of the weapon it was given. When those differ, the kept
# weapon's copies are gone from the structures list and the removed weapon's
# copies remain. The kept weapon takes those over so it is credited and a later
# unapply of either weapon erases them.
static func adopt_structure_effects(kept_effects: Array, removed_effects: Array, kept_key: String) -> void:
	for index in min(kept_effects.size(), removed_effects.size()):
		var removed = removed_effects[index]
		if is_structure_effect(kept_effects[index]) and is_structure_effect(removed) and kept_effects[index] != removed:
			tag(removed, kept_key)
			kept_effects[index] = removed
