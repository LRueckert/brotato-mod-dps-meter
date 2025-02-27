class_name DmgMeterContainer
extends VBoxContainer

export(PackedScene) var element_scene = null
var items = []
var max_items = 0
var total_dmg_item = null


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
	total_dmg_item = null  # Reset total damage item reference

func update_total_damage() -> void:
	var total_damage = 0
	for child in get_children():
		if child != total_dmg_item:
			total_damage += child.get_dmg_dealt()
	total_dmg_item.set_total_damage(total_damage)

func add_element(element: ItemParentData, player_index: int) -> void:
	player_index = player_index
	if ["WEAPON_WRENCH", "WEAPON_SCREWDRIVER"].has(element.name):
		handle_spawner(element, player_index)
	items.append(element.my_id)
	var instance = element_scene.instance()
	add_child(instance)
	instance.set_element(element, player_index)

func add_total_damage_item(player_index: int) -> void:
	total_dmg_item = element_scene.instance()
	add_child(total_dmg_item)
	total_dmg_item.set_total_damage_element(player_index)

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
	update_total_damage()  # Update total damage after children update
	sort_elements()
	hide_bottom_elements()

func sort_elements() -> void:
	var sorted = false
	while not sorted:
		var swapped = false
		var children = get_children()
		var non_total_children = children.slice(1, children.size())  # Exclude total damage item

		for i in range(non_total_children.size() - 1):
			if non_total_children[i].get_dmg_dealt() < non_total_children[i + 1].get_dmg_dealt():
				move_child(non_total_children[i], i + 2)  # +2 to keep total damage at index 0
				children = get_children()
				non_total_children = children.slice(1, children.size())
				swapped = true
		sorted = !swapped

	# Ensure the total damage item stays at the top
	move_child(total_dmg_item, 0)



func hide_bottom_elements() -> void:
	var children = get_children()
	for i in children.size():
		children[i].visible = max_items == 0 || i < max_items
