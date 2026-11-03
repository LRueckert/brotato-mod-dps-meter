extends "res://ui/menus/shop/coop_shop_player_container.gd"


const SNAPSHOT_PAGES = preload("res://mods-unpacked/lrueckert-DmgMeter/extensions/ui/menus/wave_snapshot_pages.gd")


func _ready() -> void:
	if player_index >= 0 and player_index < RunData.get_player_count():
		var snapshot_pages = SNAPSHOT_PAGES.new()
		snapshot_pages.player_index = player_index
		carousel.add_child(snapshot_pages)