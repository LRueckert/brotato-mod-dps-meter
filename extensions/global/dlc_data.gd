extends "res://global/dlc_data.gd"

func add_resources() -> void:
	.add_resources()
	var el = ItemService.get_element(ItemService.characters, "character_romantic")
	el.tracking_text = "DAMAGE_DEALT"
