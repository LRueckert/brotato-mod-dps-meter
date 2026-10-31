extends VBoxContainer


var player_index: int = -1
var selected_list: int = 0
onready var damage_container = $DmgMeterContainer
onready var healing_container = $HealingMeterContainer
onready var headings: HBoxContainer = $Headings


func _ready() -> void:
	for container in [damage_container, healing_container]:
		var heading = container.heading
		container.remove_child(heading)
		headings.add_child(heading)


func set_player(index: int) -> void:
	player_index = index
	update_list_visibility()


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
	selected_list = posmod(selected_list + direction, 2)
	update_list_visibility()


func update_list_visibility() -> void:
	damage_container.visible = selected_list == 0
	healing_container.visible = selected_list == 1
	damage_container.heading.self_modulate = Color.white if selected_list == 0 else Color(0.5, 0.5, 0.5, 0.5)
	healing_container.heading.self_modulate = Color.white if selected_list == 1 else Color(0.5, 0.5, 0.5, 0.5)