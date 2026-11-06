extends Reference

# Pure burn crediting logic (ADR 0001). No game globals, nodes, or textures,
# so headless tests in tools/tests/ can load it. Game hooks call these helpers.
#
# A turret spawned by a Spawner tags its own stats.burning_data with a burn
# tracking key (tracking_name below). The base game's burn tick credits that
# key, and RunData credits the Spawner on its Structure's player's ledger. The
# base game also credits every Engineering-scaled burn tick to
# item_turret_flame; that blanket credit is refunded for tagged ticks
# (blanket_refund).

const TRACKING_PREFIX = "dmgmeter_burn|"


# The base game gives a burn without a `from` reference to a random player in
# co-op, so the Structure's player travels in the key.
static func tracking_name(spawner_key: String, base_key_hash: int, structure_player_index: int) -> String:
	return "%s%s|%s|%s" % [TRACKING_PREFIX, spawner_key, base_key_hash, structure_player_index]


# Global burns (burn_chance player effect) belong to the item granting them.
static func should_tag(spawner_key: String, is_global_burn: bool) -> bool:
	return not spawner_key.empty() and not is_global_burn


# Sets a burn's tracking key to the burn tracking key. tracking_key is set too,
# because every new or duplicated BurningData regenerates tracking_key_hash
# from it a frame later.
static func tag(burning_data, burn_tracking_name: String, burn_tracking_hash: int) -> void:
	burning_data.tracking_key = burn_tracking_name
	burning_data.tracking_key_hash = burn_tracking_hash


# The base-game key a tagged burn tick is forwarded to, so item tooltips and
# run stats keep their totals: the burn's own tracking key if it has one,
# otherwise item_turret_flame for Engineering-scaled burns (where the base
# game's blanket credit would have gone), otherwise none (empty_hash).
static func base_key(burn_key_hash: int, is_engineering: bool, flame_hash: int, empty_hash: int) -> int:
	if burn_key_hash != empty_hash:
		return burn_key_hash
	if is_engineering:
		return flame_hash
	return empty_hash


# Credits one burn tick to the Spawner on its Structure's player's ledger, and offsets the
# forwarded value on the ledger of the player the base game credited.
static func record(structure_ledger: Dictionary, burn_ledger: Dictionary, spawner_key: String, base_key_hash: int, empty_hash: int, value: float) -> void:
	# Truncated per tick, like RunData.add_tracked_value.
	var amount = int(value)
	structure_ledger["credit"][spawner_key] = structure_ledger["credit"].get(spawner_key, 0) + amount
	if base_key_hash != empty_hash:
		burn_ledger["forwarded"][base_key_hash] = burn_ledger["forwarded"].get(base_key_hash, 0) + amount


# What to take back from item_turret_flame after a tagged burn tick:
# flame_delta is how much that key grew during the tick, forwarded_delta the
# part of it that was the tick's own forwarded value. The rest is the base
# game's blanket credit.
static func blanket_refund(flame_delta: int, forwarded_delta: int) -> int:
	return int(max(0, flame_delta - forwarded_delta))


# The tracking key a burn tick should run under. Turret burns carry no `from`,
# so a burn that has one was re-applied by another source (a weapon, pet or
# builder turret) that took it over: apply_burning moves it to that source's
# player but keeps the turret's burn tracking key. Such a tick runs under the
# base game's own key (own_key_hash), as it would without the mod, so the
# Spawner isn't credited and the base game's normal credit stays.
static func tick_key(burn_key_hash: int, own_key_hash: int, has_from: bool) -> int:
	return own_key_hash if has_from else burn_key_hash
