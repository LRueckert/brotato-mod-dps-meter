extends Node


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")
const PANEL_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/wave_snapshot_container.tscn")


var player_index: int = -1
var _meter_config
var _snapshot_headings: Array = []
var _snapshot_panels: Array = []
onready var carousel = get_parent()


func _ready() -> void:
	carousel.connect("visibility_changed", self, "add_pages")
	_meter_config = get_node(METER_CONFIG.NODE_PATH)
	_meter_config.connect("dmgmeter_config_changed", self, "add_pages")
	add_pages()


func add_pages() -> void:
	if not carousel.is_visible_in_tree():
		return
	if not _meter_config.wave_snapshots or player_index < 0 or player_index >= RunData.dmgmeter_wave_snapshot.size():
		for node in _snapshot_headings + _snapshot_panels:
			node.get_parent().remove_child(node)
			node.queue_free()
		_snapshot_headings.clear()
		_snapshot_panels.clear()
	else:
		if _snapshot_panels.empty():
			_create_pages()
		var player_snapshot = RunData.dmgmeter_wave_snapshot[player_index]
		for category_index in _snapshot_panels.size():
			var entries = player_snapshot[category_index] if category_index < player_snapshot.size() else []
			var panel = _snapshot_panels[category_index]
			panel.set_entry_limit(_meter_config.entry_limit)
			panel.set_percentage_bars_enabled(_meter_config.percentage_bars)
			panel.set_percentage_bar_width(_meter_config.percentage_bar_width)
			panel.set_category_color(METER_CONFIG.CATEGORIES[category_index]["color"])
			panel.set_entries(entries)
	var previous_index = carousel.index
	carousel.index = carousel.index
	if carousel.index != previous_index:
		carousel.emit_signal("index_changed", carousel.index)


func _create_pages() -> void:
	var headings = carousel.get_node("%Headings")
	var content = carousel.get_node("%Content")
	for category in METER_CONFIG.CATEGORIES:
		var heading = CenterContainer.new()
		heading.mouse_filter = Control.MOUSE_FILTER_PASS
		heading.rect_min_size = Vector2(200, 40)
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		headings.add_child(heading)
		_snapshot_headings.append(heading)
		var icon = TextureRect.new()
		icon.texture = category["icon"]
		icon.modulate = category["color"]
		icon.rect_min_size = Vector2(24, 24)
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		heading.add_child(icon)

		var page = PANEL_SCENE.instance()
		page.anchor_right = 1.0
		page.anchor_bottom = 1.0
		content.add_child(page)
		_snapshot_panels.append(page)