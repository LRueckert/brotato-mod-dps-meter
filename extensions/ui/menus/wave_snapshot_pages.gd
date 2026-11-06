extends Node


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")
const WAVE_SNAPSHOT_METER_SCENE = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/wave_snapshot_meter.tscn")


var player_index: int = -1
var _meter_config
var _wave_snapshot_headings: Array = []
var _wave_snapshot_meters: Array = []
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
		for node in _wave_snapshot_headings + _wave_snapshot_meters:
			node.get_parent().remove_child(node)
			node.queue_free()
		_wave_snapshot_headings.clear()
		_wave_snapshot_meters.clear()
	else:
		if _wave_snapshot_meters.empty():
			_create_pages()
		var player_snapshot = RunData.dmgmeter_wave_snapshot[player_index]
		for meter_index in _wave_snapshot_meters.size():
			var entries = player_snapshot[meter_index] if meter_index < player_snapshot.size() else []
			var wave_snapshot_meter = _wave_snapshot_meters[meter_index]
			wave_snapshot_meter.set_percentage_bars_enabled(_meter_config.percentage_bars)
			wave_snapshot_meter.set_percentage_bar_width(METER_CONFIG.SNAPSHOT_PERCENTAGE_BAR_WIDTH)
			wave_snapshot_meter.set_combine_duplicate_weapons(_meter_config.combine_duplicate_weapons)
			wave_snapshot_meter.set_meter_color(METER_CONFIG.METERS[meter_index]["color"])
			wave_snapshot_meter.set_entries(entries)
	var previous_index = carousel.index
	carousel.index = carousel.index
	if carousel.index != previous_index:
		carousel.emit_signal("index_changed", carousel.index)


func _create_pages() -> void:
	var headings = carousel.get_node("%Headings")
	var content = carousel.get_node("%Content")
	for meter in METER_CONFIG.METERS:
		var heading = CenterContainer.new()
		heading.mouse_filter = Control.MOUSE_FILTER_PASS
		heading.rect_min_size = Vector2(200, 40)
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		headings.add_child(heading)
		_wave_snapshot_headings.append(heading)
		var icon = TextureRect.new()
		icon.texture = meter["icon"]
		icon.modulate = meter["color"]
		icon.rect_min_size = Vector2(24, 24)
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		heading.add_child(icon)

		var page = WAVE_SNAPSHOT_METER_SCENE.instance()
		page.anchor_right = 1.0
		page.anchor_bottom = 1.0
		content.add_child(page)
		_wave_snapshot_meters.append(page)
