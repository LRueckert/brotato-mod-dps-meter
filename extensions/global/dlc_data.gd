extends "res://global/dlc_data.gd"

func add_resources() -> void:
	.add_resources()
	var el = ItemService.get_element(ItemService.characters, "character_romantic")
	# By adding this tracking text, the game will add Damage Dealt text to the character UI
	# Additionally, dmgmeter searches this key when determining what items to display and update
	el.tracking_text = "DAMAGE_DEALT"
