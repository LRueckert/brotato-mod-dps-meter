extends Node


# =============================================================================
# Shared Node Identity and Signals
# =============================================================================
signal dmgmeter_config_changed


const MOD_ID := "lrueckert-DmgMeter"
const NODE_PATH := "/root/ModLoader/" + MOD_ID + "/MeterConfig"


# =============================================================================
# Option Definitions
# =============================================================================
const OPTION_WAVE_SNAPSHOTS := "wave_snapshots"
const OPTION_PERCENTAGE_BARS := "percentage_bars"
const OPTION_PERCENTAGE_BAR_WIDTH := "percentage_bar_width"
const OPTION_SOURCES_PER_METER_1_2_PLAYERS := "sources_per_meter_1_2_players"
const OPTION_SOURCES_PER_METER_3_4_PLAYERS := "sources_per_meter_3_4_players"
const OPTION_COMBINE_DUPLICATE_WEAPONS := "combine_duplicate_weapons"

const MIN_PERCENTAGE_BAR_WIDTH := 50
const MAX_PERCENTAGE_BAR_WIDTH := 280
const SNAPSHOT_PERCENTAGE_BAR_WIDTH := 300 
const DEFAULT_WAVE_SNAPSHOTS := true
const DEFAULT_PERCENTAGE_BARS := false
const DEFAULT_PERCENTAGE_BAR_WIDTH := 150
const DEFAULT_SOURCES_PER_METER_1_2_PLAYERS := 25
const DEFAULT_SOURCES_PER_METER_3_4_PLAYERS := 6
const DEFAULT_COMBINE_DUPLICATE_WEAPONS := false

const OPTIONS = {
	"tab_title": "DmgMeter",
	"options": [ {
		"type": "toggle",
		"id": OPTION_WAVE_SNAPSHOTS,
		"label": "Wave Snapshots",
		"default": DEFAULT_WAVE_SNAPSHOTS
	}, {
		"type": "toggle",
		"id": OPTION_PERCENTAGE_BARS,
		"label": "Percentage Bars",
		"default": DEFAULT_PERCENTAGE_BARS
	}, {
		"type": "slider",
		"id": OPTION_PERCENTAGE_BAR_WIDTH,
		"label": "Percentage Bar width during wave",
		"min": float(MIN_PERCENTAGE_BAR_WIDTH),
		"max": float(MAX_PERCENTAGE_BAR_WIDTH),
		"step": 10.0,
		"default": float(DEFAULT_PERCENTAGE_BAR_WIDTH),
		"display_as_integer": true
	}, {
		"type": "slider",
		"id": OPTION_SOURCES_PER_METER_1_2_PLAYERS,
		"label": "Sources per Meter (1-2 players)",
		"min": 1.0,
		"max": 25.0,
		"step": 1.0,
		"default": float(DEFAULT_SOURCES_PER_METER_1_2_PLAYERS),
		"display_as_integer": true
	}, {
		"type": "slider",
		"id": OPTION_SOURCES_PER_METER_3_4_PLAYERS,
		"label": "Sources per Meter (3-4 players)",
		"min": 1.0,
		"max": 25.0,
		"step": 1.0,
		"default": float(DEFAULT_SOURCES_PER_METER_3_4_PLAYERS),
		"display_as_integer": true
	}, {
		"type": "toggle",
		"id": OPTION_COMBINE_DUPLICATE_WEAPONS,
		"label": "Combine duplicate weapons",
		"default": DEFAULT_COMBINE_DUPLICATE_WEAPONS
	}]
}


# =============================================================================
# Meter Metadata
# =============================================================================
const METERS = [ {
	"name": "DAMAGE",
	"icon": preload("res://items/stats/percent_damage.png"),
	"color": Color(0.78, 0.35, 0.35, 1)
}, {
	"name": "HEALING",
	"icon": preload("res://items/stats/max_hp.png"),
	"color": Color(0.36, 0.68, 0.43, 1)
}, {
	"name": "MATERIALS",
	"icon": preload("res://items/materials/material_ui.png"),
	"color": Color(1, 0.78, 0.25, 1)
}]


# =============================================================================
# Current Settings
# =============================================================================
var entry_limit: int setget , get_entry_limit
var wave_snapshots: bool = DEFAULT_WAVE_SNAPSHOTS
var percentage_bars: bool = DEFAULT_PERCENTAGE_BARS
var percentage_bar_width: int = DEFAULT_PERCENTAGE_BAR_WIDTH
var combine_duplicate_weapons: bool = DEFAULT_COMBINE_DUPLICATE_WEAPONS

var _sources_per_meter_1_2_players: int = DEFAULT_SOURCES_PER_METER_1_2_PLAYERS
var _sources_per_meter_3_4_players: int = DEFAULT_SOURCES_PER_METER_3_4_PLAYERS


func get_entry_limit() -> int:
	return _sources_per_meter_1_2_players if RunData.get_player_count() <= 2 else _sources_per_meter_3_4_players


# =============================================================================
# Mod Options Handling
# =============================================================================
onready var _mod_options = get_node_or_null("/root/ModLoader/Oudstand-ModOptions/ModOptions")


func _ready() -> void:
	if _mod_options:
		_mod_options.connect("config_changed", self, "_on_mod_options_config_changed")
		_mod_options.connect("mod_registered", self, "_on_mod_options_registered")
	load_settings()


func load_settings() -> void:
	_sources_per_meter_1_2_players = DEFAULT_SOURCES_PER_METER_1_2_PLAYERS
	_sources_per_meter_3_4_players = DEFAULT_SOURCES_PER_METER_3_4_PLAYERS
	wave_snapshots = DEFAULT_WAVE_SNAPSHOTS
	percentage_bars = DEFAULT_PERCENTAGE_BARS
	percentage_bar_width = DEFAULT_PERCENTAGE_BAR_WIDTH
	combine_duplicate_weapons = DEFAULT_COMBINE_DUPLICATE_WEAPONS
	if _mod_options and MOD_ID in _mod_options.get_registered_mods():
		_sources_per_meter_1_2_players = int(_mod_options.get_value(MOD_ID, OPTION_SOURCES_PER_METER_1_2_PLAYERS))
		_sources_per_meter_3_4_players = int(_mod_options.get_value(MOD_ID, OPTION_SOURCES_PER_METER_3_4_PLAYERS))
		wave_snapshots = bool(_mod_options.get_value(MOD_ID, OPTION_WAVE_SNAPSHOTS))
		percentage_bars = bool(_mod_options.get_value(MOD_ID, OPTION_PERCENTAGE_BARS))
		percentage_bar_width = int(clamp(int(_mod_options.get_value(MOD_ID, OPTION_PERCENTAGE_BAR_WIDTH)), MIN_PERCENTAGE_BAR_WIDTH, MAX_PERCENTAGE_BAR_WIDTH))
		combine_duplicate_weapons = bool(_mod_options.get_value(MOD_ID, OPTION_COMBINE_DUPLICATE_WEAPONS))
	emit_signal("dmgmeter_config_changed")


func _on_mod_options_registered(mod_id: String) -> void:
	if mod_id == MOD_ID:
		load_settings()


func _on_mod_options_config_changed(mod_id: String, option_id: String, _value) -> void:
	if mod_id == MOD_ID and option_id in [OPTION_WAVE_SNAPSHOTS, OPTION_PERCENTAGE_BARS, OPTION_PERCENTAGE_BAR_WIDTH, OPTION_SOURCES_PER_METER_1_2_PLAYERS, OPTION_SOURCES_PER_METER_3_4_PLAYERS, OPTION_COMBINE_DUPLICATE_WEAPONS]:
		load_settings()
