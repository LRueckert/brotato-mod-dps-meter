extends "res://entities/units/pet/bot_o_mine/bot_o_mine.gd"

# Spawner crediting (ADR 0001): mines Bot-o-Mine lays credit the Bot-o-Mine
# item. Its landmine StructureEffect is its own (not shared with the Landmines
# item), and is rebuilt on resume, so it is tagged whenever the pet gets it.

const SPAWNER_CREDIT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/spawner_credit.gd")


func update_data(effect: PetEffect) -> void:
	.update_data(effect)
	if _landmine_effect != null:
		SPAWNER_CREDIT.tag(_landmine_effect, SPAWNER_CREDIT.item_key("item_bot_o_mine"))
