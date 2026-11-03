extends "res://ui/menus/shop/stats_container.gd"


const MOD_ID := "lrueckert-DmgMeter"
const PANEL_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/wave_snapshot_panel.tscn")
const CATEGORY_NAMES = ["DAMAGE", "HEALING", "MATERIALS"]
const CATEGORY_ICONS = [
	preload("res://items/stats/percent_damage.png"),
	preload("res://items/stats/max_hp.png"),
	preload("res://items/materials/material_ui.png")
]

# =============================================================================
# Configuration
# Runtime values loaded from Mod Options.
# =============================================================================
var WAVE_SNAPSHOTS: bool = true


var _dmgmeter_category_buttons: Array = []
var _dmgmeter_snapshot_panels: Array = []
var _dmgmeter_selected_category: int = 0
var _dmgmeter_native_tab_layout: Array = []
var _dmgmeter_native_tab_separation: int = 0
var _dmgmeter_compact_tab_font: DynamicFont
onready var mod_options = get_node_or_null("/root/ModLoader/Oudstand-ModOptions/ModOptions")


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

	for category_index in CATEGORY_NAMES.size():
		var button = Button.new()
		button.rect_min_size = Vector2(32, 32)
		button.connect("pressed", self, "_dmgmeter_on_snapshot_tab_pressed", [category_index + 2])
		_buttons_container.add_child(button)
		var icon = TextureRect.new()
		icon.texture = CATEGORY_ICONS[category_index]
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		icon.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		icon.margin_left = -12
		icon.margin_top = -12
		icon.margin_right = 12
		icon.margin_bottom = 12
		if category_index == 2:
			icon.modulate = Color(1, 0.78, 0.25, 1)
		_dmgmeter_category_buttons.append(button)

		var panel = PANEL_SCENE.instance()
		panel.name = "DmgMeter%sSnapshot" % CATEGORY_NAMES[category_index].capitalize()
		panel.visible = false
		tabs_parent.add_child(panel)
		_dmgmeter_snapshot_panels.append(panel)

	_primary_tab.connect("pressed", self, "_dmgmeter_on_native_tab_pressed", [0])
	_secondary_tab.connect("pressed", self, "_dmgmeter_on_native_tab_pressed", [1])
	connect("visibility_changed", self, "_dmgmeter_refresh_snapshot_tabs")
	_dmgmeter_selected_category = int(focused_tab)
	load_settings()
	_dmgmeter_select_category(_dmgmeter_selected_category)


func load_settings() -> void:
	if not mod_options:
		return
	if not mod_options.is_connected("config_changed", self, "_on_mod_options_config_changed"):
		mod_options.connect("config_changed", self, "_on_mod_options_config_changed")
		mod_options.connect("mod_registered", self, "_on_mod_options_registered")
	if MOD_ID in mod_options.get_registered_mods():
		WAVE_SNAPSHOTS = bool(mod_options.get_value(MOD_ID, "wave_snapshots"))
		_dmgmeter_refresh_snapshot_tabs()


func _on_mod_options_registered(mod_id: String) -> void:
	if mod_id == MOD_ID:
		load_settings()


func _on_mod_options_config_changed(mod_id: String, option_id: String, value) -> void:
	if mod_id != MOD_ID:
		return
	if option_id == "wave_snapshots":
		WAVE_SNAPSHOTS = bool(value)
		_dmgmeter_refresh_snapshot_tabs()


func _dmgmeter_refresh_snapshot_tabs() -> void:
	var has_snapshot = WAVE_SNAPSHOTS and not RunData.dmgmeter_wave_snapshot.empty()
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
	var has_snapshot = WAVE_SNAPSHOTS and not RunData.dmgmeter_wave_snapshot.empty()
	var category_count = 5 if has_snapshot else 2
	_dmgmeter_selected_category = posmod(_dmgmeter_selected_category + direction, category_count)
	call_deferred("_dmgmeter_select_category", _dmgmeter_selected_category)
	get_tree().set_input_as_handled()


func _dmgmeter_on_native_tab_pressed(category_index: int) -> void:
	_dmgmeter_select_category(category_index)


func _dmgmeter_on_snapshot_tab_pressed(category_index: int) -> void:
	_dmgmeter_select_category(category_index)


func _dmgmeter_select_category(category_index: int) -> void:
	if category_index >= 2 and (not WAVE_SNAPSHOTS or RunData.dmgmeter_wave_snapshot.empty()):
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