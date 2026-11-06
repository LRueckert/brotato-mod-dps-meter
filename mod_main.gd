extends Node


const METER_CONFIG = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_config.gd")
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
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/hud/meter_panel_updates.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/hud/meter_panel_positioning.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/menus/shop/stats_container.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/menus/shop/coop_shop_player_container.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/menus/ingame/coop_upgrades_ui_player_container.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("entities/units/player/healing_meter.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/run_data.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/materials_meter.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("materials_meter.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/spawner_credit.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("entities/structures/turret/turret_spawner_credit.gd"))


func add_translations() -> void:
	translations_dir_path = mod_dir_path.plus_file("translations")
	# ModLoaderMod.add_translation(translations_dir_path.plus_file(...))


func _ready() -> void:
	ModLoaderLog.info("Ready!", LRUECKERT_DMGMETER_LOG_NAME)
	var meter_config = METER_CONFIG.new()
	meter_config.name = "MeterConfig"
	add_child(meter_config)
	call_deferred("_register_mod_options")


func _register_mod_options() -> void:
	var mod_options = get_node_or_null("/root/ModLoader/Oudstand-ModOptions/ModOptions")
	if not mod_options:
		return
	mod_options.register_mod_options(LRUECKERT_DMGMETER_DIR, METER_CONFIG.OPTIONS)
