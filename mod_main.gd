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
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("entities/units/enemies/enemy.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/run_data.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("dlcs/dlc_1/effect_behaviors/enemy/charm_enemy_effect_behavior.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("global/dlc_data.gd"))

func add_translations() -> void:
	translations_dir_path = mod_dir_path.plus_file("translations")
	# ModLoaderMod.add_translation(translations_dir_path.plus_file(...))


func _ready() -> void:
	ModLoaderLog.info("Ready!", LRUECKERT_DMGMETER_LOG_NAME)
	var mainSzene = load("res://main.tscn").instance()
	for index in 4:
		var player_index = str(index + 1)
		var node_name = "DmgMeterContainerP%s" % player_index
		var parent_node = "UI/HUD/LifeContainerP%s" % player_index
		ModLoaderMod.append_node_in_scene(mainSzene, node_name, parent_node, "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/dmg_meter_container.tscn")
	ModLoaderMod.save_scene(mainSzene, "res://main.tscn")
