extends "res://main.gd"

# Spawner crediting (ADR 0001): turrets that trees spawn because of Pocket
# Factory credit Pocket Factory. main.turret_effect is the Turret item's own
# effect, so Pocket Factory spawns from a tagged copy instead.

const SPAWNER_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/spawner_credit.gd")


func _on_neutral_died(neutral: Neutral, args: Entity.DieArgs) -> void:
	if turret_effect != null and SPAWNER_CREDIT.spawner_key_of(turret_effect).empty():
		turret_effect = SPAWNER_CREDIT.tagged_copy(turret_effect, SPAWNER_CREDIT.item_key("item_pocket_factory"))
	._on_neutral_died(neutral, args)
