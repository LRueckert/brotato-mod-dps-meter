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
const OPTION_MAX_ENTRIES_1_2_PLAYERS := "max_entries_1_2_players"
const OPTION_MAX_ENTRIES_3_4_PLAYERS := "max_entries_3_4_players"

const DEFAULT_WAVE_SNAPSHOTS := true
const DEFAULT_MAX_ENTRIES_1_2_PLAYERS := 25
const DEFAULT_MAX_ENTRIES_3_4_PLAYERS := 6

const OPTIONS = {
	"tab_title": "DmgMeter",
	"options": [{
		"type": "toggle",
		"id": OPTION_WAVE_SNAPSHOTS,
		"label": "Wave snapshots",
		"default": DEFAULT_WAVE_SNAPSHOTS
	}, {
		"type": "slider",
		"id": OPTION_MAX_ENTRIES_1_2_PLAYERS,
		"label": "Entries per list (1-2 players)",
		"min": 1.0,
		"max": 25.0,
		"step": 1.0,
		"default": float(DEFAULT_MAX_ENTRIES_1_2_PLAYERS),
		"display_as_integer": true
	}, {
		"type": "slider",
		"id": OPTION_MAX_ENTRIES_3_4_PLAYERS,
		"label": "Entries per list (3-4 players)",
		"min": 1.0,
		"max": 25.0,
		"step": 1.0,
		"default": float(DEFAULT_MAX_ENTRIES_3_4_PLAYERS),
		"display_as_integer": true
	}]
}


# =============================================================================
# Category Metadata
# =============================================================================
const CATEGORIES = [{
	"name": "DAMAGE",
	"icon": preload("res://items/stats/percent_damage.png"),
	"color": Color.white
}, {
	"name": "HEALING",
	"icon": preload("res://items/stats/max_hp.png"),
	"color": Color.white
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

var _max_entries_1_2_players: int = DEFAULT_MAX_ENTRIES_1_2_PLAYERS
var _max_entries_3_4_players: int = DEFAULT_MAX_ENTRIES_3_4_PLAYERS


func get_entry_limit() -> int:
	return _max_entries_1_2_players if RunData.get_player_count() <= 2 else _max_entries_3_4_players


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
	_max_entries_1_2_players = DEFAULT_MAX_ENTRIES_1_2_PLAYERS
	_max_entries_3_4_players = DEFAULT_MAX_ENTRIES_3_4_PLAYERS
	wave_snapshots = DEFAULT_WAVE_SNAPSHOTS
	if _mod_options and MOD_ID in _mod_options.get_registered_mods():
		_max_entries_1_2_players = int(_mod_options.get_value(MOD_ID, OPTION_MAX_ENTRIES_1_2_PLAYERS))
		_max_entries_3_4_players = int(_mod_options.get_value(MOD_ID, OPTION_MAX_ENTRIES_3_4_PLAYERS))
		wave_snapshots = bool(_mod_options.get_value(MOD_ID, OPTION_WAVE_SNAPSHOTS))
	emit_signal("dmgmeter_config_changed")


func _on_mod_options_registered(mod_id: String) -> void:
	if mod_id == MOD_ID:
		load_settings()


func _on_mod_options_config_changed(mod_id: String, option_id: String, _value) -> void:
	if mod_id == MOD_ID and option_id in [OPTION_WAVE_SNAPSHOTS, OPTION_MAX_ENTRIES_1_2_PLAYERS, OPTION_MAX_ENTRIES_3_4_PLAYERS]:
		load_settings()