extends VBoxContainer


const MOD_ID := "lrueckert-DmgMeter"
const SOLO_OPTION := "show_all_lists_solo"

# =============================================================================
# Configuration
# Runtime values loaded from Mod Options.
# =============================================================================
var SHOW_ALL_LISTS_SOLO: bool = false


var player_index: int = -1
var selected_list: int = 0
var hud_position: int = 0
var solo_hosts: Array = []
onready var containers: Array = [$DmgMeterContainer, $HealingMeterContainer, $MaterialsMeterContainer]
onready var headings: HBoxContainer = $Headings
onready var mod_options = get_node_or_null("/root/ModLoader/Oudstand-ModOptions/ModOptions")


func _ready() -> void:
	for container in containers:
		var heading = container.heading
		container.remove_child(heading)
		headings.add_child(heading)
	connect("visibility_changed", self, "_sync_solo_visibility")


func set_player(index: int) -> void:
	player_index = index
	hud_position = index
	_load_settings()
	apply_layout()


func _input(event: InputEvent) -> void:
	if player_index < 0 or not is_visible_in_tree() or get_tree().paused or _uses_solo_layout():
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
	if _uses_solo_layout():
		_apply_solo_layout()
	else:
		_apply_player_layout()
	_update_heading_layout()
	update_list_visibility()
	_sync_solo_visibility()


func _apply_player_layout() -> void:
	for container in containers:
		_move_node(container, self)
		_move_node(container.heading, headings)
		container.set_display_position(hud_position)
	for host in solo_hosts:
		host.get_parent().remove_child(host)
		host.queue_free()
	solo_hosts.clear()


func _update_heading_layout() -> void:
	var left = hud_position == 0 or hud_position == 2
	headings.alignment = BoxContainer.ALIGN_BEGIN if left else BoxContainer.ALIGN_END
	for index in headings.get_child_count():
		var container_index = index if left else containers.size() - index - 1
		if containers[container_index].heading.get_parent() == headings:
			headings.move_child(containers[container_index].heading, index)


func _uses_solo_layout() -> bool:
	return SHOW_ALL_LISTS_SOLO and player_index == 0 and RunData.get_player_count() == 1


func _apply_solo_layout() -> void:
	if solo_hosts.empty():
		var hud = get_parent().get_parent()
		var notification_rows = hud.get_node("ThingsToProcessMarginContainer/VBoxContainer/HBoxContainer/UIThingsToProcessPlayerContainer1/VBoxContainer")
		_create_solo_host(containers[1], hud.get_node("LifeContainerP4"), true)
		_create_solo_host(containers[2], notification_rows, false)
	containers[0].set_display_position(0)
	containers[1].set_display_position(3)
	containers[2].set_display_position(1)


func _create_solo_host(container: MeterListContainer, parent: Node, bottom: bool) -> void:
	var host = VBoxContainer.new()
	host.name = "SoloMeterList"
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.size_flags_horizontal = Control.SIZE_SHRINK_END
	host.size_flags_vertical = Control.SIZE_SHRINK_END if bottom else 0
	parent.add_child(host)
	solo_hosts.append(host)
	_move_node(container.heading, host)
	_move_node(container, host)


func _move_node(node: Node, parent: Node) -> void:
	if node.get_parent() != parent:
		node.get_parent().remove_child(node)
		parent.add_child(node)


func update_list_visibility() -> void:
	var show_all = _uses_solo_layout()
	for index in containers.size():
		var active = show_all or selected_list == index
		containers[index].visible = active
		containers[index].heading.self_modulate = Color.white if active else Color(0.5, 0.5, 0.5, 0.5)


func _sync_solo_visibility() -> void:
	for host in solo_hosts:
		host.visible = is_visible_in_tree()


func _load_settings() -> void:
	if not mod_options:
		return
	if not mod_options.is_connected("config_changed", self, "_on_mod_options_config_changed"):
		mod_options.connect("config_changed", self, "_on_mod_options_config_changed")
		mod_options.connect("mod_registered", self, "_on_mod_options_registered")
	if MOD_ID in mod_options.get_registered_mods():
		SHOW_ALL_LISTS_SOLO = mod_options.get_value(MOD_ID, SOLO_OPTION) == true


func _on_mod_options_config_changed(mod_id: String, option_id: String, value) -> void:
	if mod_id == MOD_ID and option_id == SOLO_OPTION:
		SHOW_ALL_LISTS_SOLO = value == true
		apply_layout()


func _on_mod_options_registered(mod_id: String) -> void:
	if mod_id == MOD_ID:
		_load_settings()
		apply_layout()