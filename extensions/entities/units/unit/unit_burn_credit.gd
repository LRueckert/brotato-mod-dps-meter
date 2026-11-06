extends "res://entities/units/unit/unit.gd"

# Burn crediting (ADR 0001): the base burn tick credits every Engineering-scaled
# burn to item_turret_flame, and then the burn's own tracking key. For a burn
# tagged by a Spawner's turret, the RunData hook credits the Spawner from the
# second call; this takes the blanket item_turret_flame credit back so the
# tick is counted once. A tagged burn another source has taken over ticks under
# the base game's own key instead, so its Spawner isn't credited. Enemy, Boss,
# Player, Pet and Neutral inherit this.

const DMGMETER_BURN_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/burn_credit.gd")


func _on_BurningTimer_timeout() -> void:
	if _burning == null or not RunData.dmgmeter_is_burn_tracking_hash(_burning.tracking_key_hash):
		._on_BurningTimer_timeout()
		return
	var burn_key_hash = _burning.tracking_key_hash
	# A freed `from` still counts as set: some source took the burn over.
	var has_from = typeof(_burning.from) == TYPE_OBJECT
	var own_key_hash = Keys.generate_hash(RunData.dmgmeter_burn_own_tracking_key(_burning.tracking_key))
	var tick_key_hash = DMGMETER_BURN_CREDIT.tick_key(burn_key_hash, own_key_hash, has_from)
	if tick_key_hash != burn_key_hash:
		_burning.tracking_key_hash = tick_key_hash
		._on_BurningTimer_timeout()
		# Put the tag back: the base game keeps a running burn's first key, and the
		# Spawner is credited again if its turret takes the burn back.
		if _burning != null and _burning.tracking_key_hash == tick_key_hash:
			_burning.tracking_key_hash = burn_key_hash
		return
	var player_index = _burning_player_index
	var flame_before = RunData.dmgmeter_tracked_int(player_index, Keys.item_turret_flame_hash)
	var forwarded_before = RunData.dmgmeter_burn_forwarded(player_index, Keys.item_turret_flame_hash)
	._on_BurningTimer_timeout()
	var flame_delta = RunData.dmgmeter_tracked_int(player_index, Keys.item_turret_flame_hash) - flame_before
	var forwarded_delta = RunData.dmgmeter_burn_forwarded(player_index, Keys.item_turret_flame_hash) - forwarded_before
	RunData.dmgmeter_untrack(player_index, Keys.item_turret_flame_hash, DMGMETER_BURN_CREDIT.blanket_refund(flame_delta, forwarded_delta))