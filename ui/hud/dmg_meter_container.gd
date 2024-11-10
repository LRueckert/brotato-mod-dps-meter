class_name DmgMeterContainer
extends VBoxContainer

export(PackedScene) var element_scene = null
var items = []
var max_items = 0

func set_elements(elements: Array, player_index: int, player_count: int, replace: bool = true) -> void:
	max_items = 0 if player_count < 3 else 6
	if replace:
		clear_elements()

	for element in elements:
		add_element(element, player_index)


func clear_elements() -> void:
	items = []
	for n in get_children():
		remove_child(n)
		n.queue_free()


func add_element(element: ItemParentData, player_index: int) -> void:
	if ["WEAPON_WRENCH", "WEAPON_SCREWDRIVER"].has(element.name):
		handle_spawner(element, player_index)
	items.append(element.my_id)
	var instance = element_scene.instance()
	add_child(instance)
	instance.set_element(element, player_index)


func handle_spawner(element: ItemParentData, player_index: int) -> void:
	match element.name:
		"WEAPON_SCREWDRIVER":
			if not items.has("item_landmines"):
				add_element(ItemService.get_item_from_id("item_landmines"), player_index)
		"WEAPON_WRENCH":
			match element.tier:
				Tier.COMMON:
					if not items.has("item_turret"):
						add_element(ItemService.get_item_from_id("item_turret"), player_index)
				Tier.UNCOMMON:
					if not items.has("item_turret_flame"):
						add_element(ItemService.get_item_from_id("item_turret_flame"), player_index)
				Tier.RARE:
					if not items.has("item_turret_laser"):
						add_element(ItemService.get_item_from_id("item_turret_laser"), player_index)
				Tier.LEGENDARY:
					if not items.has("item_turret_rocket"):
						add_element(ItemService.get_item_from_id("item_turret_rocket"), player_index)


func trigger_element_updates() -> void:
	for child in get_children():
		child.trigger_update()
	sort_elements()
	hide_bottom_elements()

func sort_elements() -> void:
	var sorted = false
	while not sorted:
		var swapped = false
		var children = get_children()
		for i in children.size() - 1:
			if children[i].get_dmg_dealt() < children[i + 1].get_dmg_dealt():
				move_child(children[i], i + 1)
				children = get_children()
				swapped = true
		sorted = !swapped


func hide_bottom_elements() -> void:
	var children = get_children()
	for i in children.size():
		children[i].visible = max_items == 0 || i < max_items
