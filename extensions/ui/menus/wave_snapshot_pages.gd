extends Node


const MOD_ID := "lrueckert-DmgMeter"
const CATEGORY_NAMES = ["DAMAGE", "HEALING", "MATERIALS"]
const CATEGORY_ICONS = [
	preload("res://items/stats/percent_damage.png"),
	preload("res://items/stats/max_hp.png"),
	preload("res://items/materials/material_ui.png")
]
const PANEL_SCRIPT = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/wave_snapshot_panel.gd")

# =============================================================================
# Configuration
# Runtime values loaded from Mod Options.
# =============================================================================
var WAVE_SNAPSHOTS: bool = true


var player_index: int = -1
onready var carousel = get_parent()
onready var mod_options = get_node_or_null("/root/ModLoader/Oudstand-ModOptions/ModOptions")


func _ready() -> void:
	carousel.connect("visibility_changed", self, "add_pages")
	load_settings()
	add_pages()


func load_settings() -> void:
	if not mod_options:
		return
	if not mod_options.is_connected("config_changed", self, "_on_mod_options_config_changed"):
		mod_options.connect("config_changed", self, "_on_mod_options_config_changed")
		mod_options.connect("mod_registered", self, "_on_mod_options_registered")
	if MOD_ID in mod_options.get_registered_mods():
		WAVE_SNAPSHOTS = bool(mod_options.get_value(MOD_ID, "wave_snapshots"))
		add_pages()


func _on_mod_options_registered(mod_id: String) -> void:
	if mod_id == MOD_ID:
		load_settings()


func _on_mod_options_config_changed(mod_id: String, option_id: String, value) -> void:
	if mod_id != MOD_ID:
		return
	if option_id == "wave_snapshots":
		WAVE_SNAPSHOTS = bool(value)
		add_pages()


func add_pages() -> void:
	var headings = carousel.get_node("%Headings")
	var content = carousel.get_node("%Content")
	for parent in [headings, content]:
		for child in parent.get_children():
			if child.has_meta("dmgmeter_snapshot_page"):
				parent.remove_child(child)
				child.queue_free()
	if not WAVE_SNAPSHOTS or player_index < 0 or player_index >= RunData.dmgmeter_wave_snapshot.size():
		carousel.index = carousel.index
		return
	var player_snapshot = RunData.dmgmeter_wave_snapshot[player_index]
	for category_index in CATEGORY_NAMES.size():
		var heading = CenterContainer.new()
		heading.set_meta("dmgmeter_snapshot_page", true)
		heading.mouse_filter = Control.MOUSE_FILTER_PASS
		heading.rect_min_size = Vector2(200, 40)
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		headings.add_child(heading)
		var icon = TextureRect.new()
		icon.texture = CATEGORY_ICONS[category_index]
		icon.rect_min_size = Vector2(24, 24)
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if category_index == 2:
			icon.modulate = Color(1, 0.78, 0.25, 1)
		heading.add_child(icon)

		var entries = player_snapshot[category_index] if category_index < player_snapshot.size() else []
		var page = PANEL_SCRIPT.new()
		page.set_meta("dmgmeter_snapshot_page", true)
		page.anchor_right = 1.0
		page.anchor_bottom = 1.0
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content.add_child(page)
		page.set_entries(entries)

	carousel.index = carousel.index