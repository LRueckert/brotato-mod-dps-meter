extends "res://entities/structures/turret/turret.gd"

# Burn crediting (ADR 0001): a turret spawned from a tagged StructureEffect
# gives its own stats.burning_data a burn tracking key naming its Spawner and
# player. The base game replaces stats (and so burning_data) in reload_data and
# set_current_stats, so the tag is applied again there. The burn's `from`
# reference is left alone: setting it changes gameplay.

const DMGMETER_SPAWNER_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/spawner_credit.gd")
const DMGMETER_BURN_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/burn_credit.gd")


var _dmgmeter_burn_spawner_key: String = ""


func set_data(data: Resource) -> void:
	# The base set_data calls reload_data, which applies the tag.
	_dmgmeter_burn_spawner_key = DMGMETER_SPAWNER_CREDIT.spawner_key_of(data)
	.set_data(data)


func reload_data() -> void:
	.reload_data()
	# A fresh stats object owned by this turret alone.
	_dmgmeter_tag_burn(stats.burning_data)


func set_current_stats(new_stats: RangedWeaponStats) -> void:
	.set_current_stats(new_stats)
	# StatsManager hands every turret of a scene and player the same cached
	# stats object, which another turret may have tagged. Use an own copy
	# whenever the burn key differs from this turret's.
	var burning_data = stats.burning_data
	if burning_data == null or burning_data.tracking_key == _dmgmeter_burn_tracking_key(burning_data):
		return
	stats = DMGMETER_SPAWNER_CREDIT.copy_effect(stats)
	stats.burning_data = burning_data.duplicate()
	_dmgmeter_tag_burn(stats.burning_data)


func _dmgmeter_tag_burn(burning_data) -> void:
	if burning_data != null:
		var tracking_key = _dmgmeter_burn_tracking_key(burning_data)
		DMGMETER_BURN_CREDIT.tag(burning_data, tracking_key, Keys.generate_hash(tracking_key))


# The tracking key this turret's burns should carry: its Spawner's burn
# tracking key, or the base game's own key for untagged turrets and global burns.
func _dmgmeter_burn_tracking_key(burning_data) -> String:
	var own_tracking_key = RunData.dmgmeter_burn_own_tracking_key(burning_data.tracking_key)
	if burning_data.is_not_burning() or not DMGMETER_BURN_CREDIT.should_tag(_dmgmeter_burn_spawner_key, burning_data.is_global_burn):
		return own_tracking_key
	var is_engineering = Utils.get_first_scaling_stat(burning_data.scaling_stats) == Keys.stat_engineering_hash
	var base_key_hash = DMGMETER_BURN_CREDIT.base_key(Keys.generate_hash(own_tracking_key), is_engineering, Keys.item_turret_flame_hash, Keys.empty_hash)
	return RunData.dmgmeter_burn_tracking_name(_dmgmeter_burn_spawner_key, base_key_hash, player_index, own_tracking_key)