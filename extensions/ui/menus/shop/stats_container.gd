extends "res://ui/menus/shop/stats_container.gd"


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")
const PANEL_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/wave_snapshot_container.tscn")


var _meter_config
var _dmgmeter_category_buttons: Array = []
var _dmgmeter_snapshot_panels: Array = []
var _dmgmeter_selected_category: int = 0
var _dmgmeter_native_tab_layout: Array = []
var _dmgmeter_native_tab_separation: int = 0
var _dmgmeter_compact_tab_font: DynamicFont


func _ready() -> void:
	if show_buttons:
		call_deferred("_dmgmeter_setup_snapshot_categories")


func _dmgmeter_setup_snapshot_categories() -> void:
	var tabs_parent = _buttons_container.get_parent()
	_dmgmeter_native_tab_separation = _buttons_container.get_constant("separation")
	_dmgmeter_compact_tab_font = _primary_tab.get_font("font").duplicate()
	_dmgmeter_compact_tab_font.size = 18
	for tab in [_primary_tab, _secondary_tab]:
		_dmgmeter_native_tab_layout.append({
			"button": tab,
			"font": tab.get_font("font"),
			"min_size": tab.rect_min_size,
			"size_flags": tab.size_flags_horizontal
		})

	for category_index in METER_CONFIG.CATEGORIES.size():
		var category = METER_CONFIG.CATEGORIES[category_index]
		var button = Button.new()
		button.rect_min_size = Vector2(32, 32)
		button.connect("pressed", self, "_dmgmeter_on_snapshot_tab_pressed", [category_index + 2])
		_buttons_container.add_child(button)
		var icon = TextureRect.new()
		icon.texture = category["icon"]
		icon.modulate = category["color"]
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		icon.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		icon.margin_left = -12
		icon.margin_top = -12
		icon.margin_right = 12
		icon.margin_bottom = 12
		_dmgmeter_category_buttons.append(button)

		var panel = PANEL_SCENE.instance()
		panel.name = "DmgMeter%sSnapshot" % category["name"].capitalize()
		panel.visible = false
		tabs_parent.add_child(panel)
		_dmgmeter_snapshot_panels.append(panel)

	_primary_tab.connect("pressed", self, "_dmgmeter_on_native_tab_pressed", [0])
	_secondary_tab.connect("pressed", self, "_dmgmeter_on_native_tab_pressed", [1])
	connect("visibility_changed", self, "_dmgmeter_refresh_snapshot_tabs")
	_dmgmeter_selected_category = int(focused_tab)
	_meter_config = get_node(METER_CONFIG.NODE_PATH)
	_meter_config.connect("dmgmeter_config_changed", self, "_dmgmeter_apply_settings")
	_dmgmeter_apply_settings()
	_dmgmeter_select_category(_dmgmeter_selected_category)


func _dmgmeter_apply_settings() -> void:
	for index in _dmgmeter_snapshot_panels.size():
		var panel = _dmgmeter_snapshot_panels[index]
		panel.set_entry_limit(_meter_config.entry_limit)
		panel.set_percentage_bars_enabled(_meter_config.percentage_bars)
		panel.set_percentage_bar_width(_meter_config.percentage_bar_width)
		panel.set_category_color(METER_CONFIG.CATEGORIES[index]["color"])
	_dmgmeter_refresh_snapshot_tabs()


func _dmgmeter_refresh_snapshot_tabs() -> void:
	var has_snapshot = _meter_config.wave_snapshots and not RunData.dmgmeter_wave_snapshot.empty()
	for button in _dmgmeter_category_buttons:
		button.visible = has_snapshot
	_buttons_container.add_constant_override("separation", 4 if has_snapshot else _dmgmeter_native_tab_separation)
	for index in _dmgmeter_native_tab_layout.size():
		var layout = _dmgmeter_native_tab_layout[index]
		var tab = layout["button"]
		tab.add_font_override("font", _dmgmeter_compact_tab_font if has_snapshot else layout["font"])
		tab.rect_min_size = Vector2(110 if index == 0 else 130, layout["min_size"].y) if has_snapshot else layout["min_size"]
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL if has_snapshot else layout["size_flags"]
	if not has_snapshot and _dmgmeter_selected_category >= 2:
		_dmgmeter_select_category(Tab.PRIMARY)


func _input(event: InputEvent) -> void:
	if not show_buttons or not is_visible_in_tree() or _dmgmeter_snapshot_panels.empty():
		return
	var direction = 0
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return
		if event.scancode == KEY_Q:
			direction = -1
		elif event.scancode == KEY_E:
			direction = 1
	elif event is InputEventJoypadButton:
		if event.is_action_pressed("ltrigger"):
			direction = -1
		elif event.is_action_pressed("rtrigger"):
			direction = 1
	if direction == 0:
		return
	var has_snapshot = _meter_config.wave_snapshots and not RunData.dmgmeter_wave_snapshot.empty()
	var category_count = 2 + METER_CONFIG.CATEGORIES.size() if has_snapshot else 2
	_dmgmeter_selected_category = posmod(_dmgmeter_selected_category + direction, category_count)
	call_deferred("_dmgmeter_select_category", _dmgmeter_selected_category)
	get_tree().set_input_as_handled()


func _dmgmeter_on_native_tab_pressed(category_index: int) -> void:
	_dmgmeter_select_category(category_index)


func _dmgmeter_on_snapshot_tab_pressed(category_index: int) -> void:
	_dmgmeter_select_category(category_index)


func _dmgmeter_select_category(category_index: int) -> void:
	if category_index >= 2 and (not _meter_config.wave_snapshots or RunData.dmgmeter_wave_snapshot.empty()):
		category_index = Tab.PRIMARY
	_dmgmeter_selected_category = category_index
	_dmgmeter_refresh_snapshot_tabs()
	for panel in _dmgmeter_snapshot_panels:
		panel.hide()

	if category_index < 2:
		.update_tab(category_index)
	else:
		.update_tab(Tab.PRIMARY)
		_general_stats.hide()
		_primary_stats.hide()
		_secondary_stats.hide()
		var snapshot_index = category_index - 2
		var player_snapshot = RunData.dmgmeter_wave_snapshot[0] if not RunData.dmgmeter_wave_snapshot.empty() else []
		var entries = player_snapshot[snapshot_index] if snapshot_index < player_snapshot.size() else []
		var panel = _dmgmeter_snapshot_panels[snapshot_index]
		panel.set_entries(entries)
		panel.show()
		_primary_tab.flat = false
		_secondary_tab.flat = false

	for index in _dmgmeter_category_buttons.size():
		_dmgmeter_category_buttons[index].flat = index + 2 == category_index