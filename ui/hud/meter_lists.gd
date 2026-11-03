extends VBoxContainer


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")


var player_index: int = -1
var selected_list: int = 0
var hud_position: int = 0
var _meter_config
onready var containers: Array = [$DmgMeterContainer, $HealingMeterContainer, $MaterialsMeterContainer]
onready var headings: HBoxContainer = $Headings


func _ready() -> void:
	for container in containers:
		var heading = container.heading
		container.remove_child(heading)
		headings.add_child(heading)
	_meter_config = get_node(METER_CONFIG.NODE_PATH)
	_meter_config.connect("dmgmeter_config_changed", self, "_apply_settings")
	_apply_settings()


func set_player(index: int) -> void:
	player_index = index
	hud_position = index
	_apply_settings()
	for container in containers:
		container.set_player(index)
	apply_layout()


func _apply_settings() -> void:
	for index in containers.size():
		var container = containers[index]
		container.set_entry_limit(_meter_config.entry_limit)
		container.set_percentage_bars_enabled(_meter_config.percentage_bars)
		container.set_percentage_bar_width(_meter_config.percentage_bar_width)
		container.set_category_color(METER_CONFIG.CATEGORIES[index]["color"])


func _input(event: InputEvent) -> void:
	if player_index < 0 or not is_visible_in_tree() or get_tree().paused:
		return
	var direction = 0
	var device = event.device
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return
		if event.scancode == KEY_Q:
			direction = -1
		elif event.scancode == KEY_E:
			direction = 1
		if device == 0:
			device = CoopService.KEYBOARD_REMAPPED_DEVICE_ID
	elif event is InputEventJoypadButton:
		if not event.pressed:
			return
		if event.button_index in [JOY_L, JOY_L2]:
			direction = -1
		elif event.button_index in [JOY_R, JOY_R2]:
			direction = 1
		if device == 0:
			device = CoopService.GAMEPAD_REMAPPED_DEVICE_ID
	else:
		return
	if direction == 0:
		return
	if RunData.is_coop_run and device != CoopService.get_remapped_player_device(player_index):
		return
	selected_list = posmod(selected_list + direction, containers.size())
	update_list_visibility()


func set_hud_position(position_index: int) -> void:
	hud_position = position_index
	apply_layout()


func apply_layout() -> void:
	_apply_player_layout()
	_update_heading_layout()
	update_list_visibility()


func _apply_player_layout() -> void:
	for container in containers:
		_move_node(container, self)
		_move_node(container.heading, headings)
		container.set_display_position(hud_position)


func _update_heading_layout() -> void:
	var left = hud_position == 0 or hud_position == 2
	headings.alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	for index in headings.get_child_count():
		if containers[index].heading.get_parent() == headings:
			headings.move_child(containers[index].heading, index)


func _move_node(node: Node, parent: Node) -> void:
	if node.get_parent() != parent:
		node.get_parent().remove_child(node)
		parent.add_child(node)


func update_list_visibility() -> void:
	for index in containers.size():
		var active = selected_list == index
		containers[index].visible = active
		containers[index].heading.self_modulate = Color.white if active else Color(0.5, 0.5, 0.5, 0.5)