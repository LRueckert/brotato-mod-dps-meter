class_name DmgMeterContainer
extends VBoxContainer

export(PackedScene) var element_scene = null
var player_index: int = 0
var items = []
var row_data: Dictionary = {}
var max_items = 0
onready var rows_container: VBoxContainer = $Rows
onready var heading: TextureRect = $Heading

func set_player(index: int, player_count: int) -> void:
	player_index = index
	max_items = 0 if player_count < 3 else 6
	heading.size_flags_horizontal = 0 if player_index == 0 or player_index == 2 else Control.SIZE_SHRINK_END
	clear_elements()

	for element in RunData.get_player_weapons(player_index):
		add_element(element)
	for element in RunData.get_player_items(player_index):
		if not items.has(element.my_id) && element.tracking_text == "DAMAGE_DEALT" || element.tracking_text == "EXPLOSION_DAMAGE_DEALT" || element.name == "ITEM_BUILDER_TURRET":
			add_element(element)


func clear_elements() -> void:
	items = []
	row_data.clear()
	for n in rows_container.get_children():
		rows_container.remove_child(n)
		n.queue_free()


func add_element(element: ItemParentData) -> void:
	if ["WEAPON_WRENCH", "WEAPON_SCREWDRIVER", "ITEM_BOT_O_MINE"].has(element.name):
		handle_spawner(element)
	items.append(element.my_id)
	var instance = element_scene.instance()
	rows_container.add_child(instance)
	instance.set_element(element.icon, player_index, Text.text(element.name))
	instance.update_background_color(element)
	var wave_start_value = 0
	if [Category.ITEM, Category.CHARACTER].has(element.get_category()) && not element.name == "ITEM_BUILDER_TURRET":
		wave_start_value = get_tracked_value(element)
	row_data[instance] = {"item": element, "wave_start_value": wave_start_value}


func handle_spawner(element: ItemParentData) -> void:
	match element.name:
		"WEAPON_SCREWDRIVER":
			if not items.has("item_landmines"):
				add_element(ItemService.get_item_from_id(Keys.generate_hash("item_landmines")))
		"ITEM_BOT_O_MINE":
			if not items.has("item_landmines"):
				add_element(ItemService.get_item_from_id(Keys.generate_hash("item_landmines")))
		"WEAPON_WRENCH":
			match element.tier:
				Tier.COMMON:
					if not items.has("item_turret"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret")))
				Tier.UNCOMMON:
					if not items.has("item_turret_flame"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret_flame")))
				Tier.RARE:
					if not items.has("item_turret_laser"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret_laser")))
				Tier.LEGENDARY:
					if not items.has("item_turret_rocket"):
						add_element(ItemService.get_item_from_id(Keys.generate_hash("item_turret_rocket")))


func trigger_element_updates() -> void:
	for child in rows_container.get_children():
		child.set_total(get_damage_total(child))
	sort_elements()
	hide_bottom_elements()

func get_damage_total(row) -> int:
	var data = row_data[row]
	var element: ItemParentData = data.item
	if element.get_category() == Category.WEAPON:
		return element.dmg_dealt_last_wave
	return get_tracked_value(element) - data.wave_start_value


func get_tracked_value(element: ItemParentData) -> int:
	var value = 0
	var tracked = RunData.tracked_item_effects[player_index][element.my_id_hash]
	if tracked is Array:
		for total in tracked:
			value += total
	else:
		value = tracked
	return value


func sort_elements() -> void:
	var sorted = false
	while not sorted:
		var swapped = false
		var children = rows_container.get_children()
		for i in children.size() - 1:
			if children[i].get_total() < children[i + 1].get_total():
				rows_container.move_child(children[i], i + 1)
				children = rows_container.get_children()
				swapped = true
		sorted = !swapped


func hide_bottom_elements() -> void:
	var children = rows_container.get_children()
	for i in children.size():
		children[i].visible = max_items == 0 || i < max_items
