extends Node


const LRUECKERT_DMGMETER_DIR := "lrueckert-DmgMeter"
const LRUECKERT_DMGMETER_LOG_NAME := "lrueckert-DmgMeter:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

# Before v6.1.0
# func _init(modLoader = ModLoader) -> void:
func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(LRUECKERT_DMGMETER_DIR)
	# Add extensions
	install_script_extensions()
	# Add translations
	add_translations()


func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.plus_file("extensions")
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/hud/dmg_meter.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/hud/dmg_meter_positioning.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("entities/units/player/healing_meter.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/materials_meter.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("materials_meter.gd"))


func add_translations() -> void:
	translations_dir_path = mod_dir_path.plus_file("translations")
	# ModLoaderMod.add_translation(translations_dir_path.plus_file(...))


func _ready() -> void:
	ModLoaderLog.info("Ready!", LRUECKERT_DMGMETER_LOG_NAME)
	call_deferred("_register_mod_options")


func _register_mod_options() -> void:
	var mod_options = get_node_or_null("/root/ModLoader/Oudstand-ModOptions/ModOptions")
	if not mod_options:
		return
	mod_options.register_mod_options(LRUECKERT_DMGMETER_DIR, {
		"tab_title": "DmgMeter",
		"options": [{
			"type": "slider",
			"id": "max_entries",
			"label": "Entries per list",
			"min": 1.0,
			"max": 25.0,
			"step": 1.0,
			"default": 6.0,
			"display_as_integer": true
		}, {
			"type": "toggle",
			"id": "show_all_lists_solo",
			"label": "Show all lists in single player",
			"default": false
		}]
	})
