extends "res://entities/units/unit/unit.gd"

# Burn crediting (ADR 0001): the base burn tick credits every Engineering-scaled
# burn to item_turret_flame, and then the burn's own tracking key. For a burn
# tagged by a Spawner's turret, the RunData hook credits the Spawner from the
# second call; this takes the blanket item_turret_flame credit back so the
# tick is counted once. Enemy, Boss, Player, Pet and Neutral inherit this.

const DMGMETER_BURN_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/burn_credit.gd")


func _on_BurningTimer_timeout() -> void:
	if _burning == null or not RunData.dmgmeter_is_burn_tracking_hash(_burning.tracking_key_hash):
		._on_BurningTimer_timeout()
		return
	var player_index = _burning_player_index
	var flame_before = RunData.dmgmeter_tracked_int(player_index, Keys.item_turret_flame_hash)
	var forwarded_before = RunData.dmgmeter_burn_forwarded(player_index, Keys.item_turret_flame_hash)
	._on_BurningTimer_timeout()
	var flame_delta = RunData.dmgmeter_tracked_int(player_index, Keys.item_turret_flame_hash) - flame_before
	var forwarded_delta = RunData.dmgmeter_burn_forwarded(player_index, Keys.item_turret_flame_hash) - forwarded_before
	RunData.dmgmeter_untrack(player_index, Keys.item_turret_flame_hash, DMGMETER_BURN_CREDIT.blanket_refund(flame_delta, forwarded_delta))
