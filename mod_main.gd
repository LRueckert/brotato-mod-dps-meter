extends Node

const LRUECKERT_DMGMETER_DIR := "lrueckert-DmgMeter"
const LRUECKERT_DMGMETER_LOG_NAME := "lrueckert-DmgMeter:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

func _init() -> void:
	ModLoaderLog.info("Init!", LRUECKERT_DMGMETER_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(LRUECKERT_DMGMETER_DIR)
	install_script_extensions()
	add_translations()


func install_script_extensions() -> void:	
	extensions_dir_path = mod_dir_path.plus_file("extensions")
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/hud/dmg_meter.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/hud/dmg_meter_positioning.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/run_data.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/utils.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("global/dlc_data.gd"))
	# Need to load specific scripts depending on whether certain DLC is found
	if _get_abyssal_terrors_dlc():
		ModLoaderLog.info("Configuring Abyssal Terrors-specific scripts", LRUECKERT_DMGMETER_LOG_NAME)
		ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("entities/units/enemies/enemy.gd"))
		ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("dlcs/dlc_1/effect_behaviors/enemy/charm_enemy_effect_behavior.gd"))
	else:
		ModLoaderLog.info("No DLC found", LRUECKERT_DMGMETER_LOG_NAME)
	

func add_translations() -> void:
	translations_dir_path = mod_dir_path.plus_file("translations")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.en.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.de.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.es.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.fr.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.it.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.ja.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.ko.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.pl.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.pt.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.ru.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.tr.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.zh_Hans_CN.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/lrueckert-DmgMeter/translations/lrueckert-DmgMeter.zh_Hant_TW.translation")



func _ready() -> void:
	ModLoaderLog.info("Ready", LRUECKERT_DMGMETER_LOG_NAME)
	var mainSzene = load("res://main.tscn").instance()
	for index in 4:
		var player_index = str(index + 1)
		var node_name = "DmgMeterContainerP%s" % player_index
		var parent_node = "UI/HUD/LifeContainerP%s" % player_index
		ModLoaderMod.append_node_in_scene(mainSzene, node_name, parent_node, "res://mods-unpacked/lrueckert-DmgMeter/ui/hud/dmg_meter_container.tscn")
	ModLoaderMod.save_scene(mainSzene, "res://main.tscn")

	var statsContainerScene = load("res://ui/menus/shop/stats_container.tscn").instance()
	ModLoaderMod.append_node_in_scene(statsContainerScene, "TotalDamageContainer", "MarginContainer/VBoxContainer2/SecondaryStats", "res://mods-unpacked/lrueckert-DmgMeter/ui/menus/shop/last_wave_damage_container.tscn")
	ModLoaderMod.save_scene(statsContainerScene, "res://ui/menus/shop/stats_container.tscn")
	ModLoaderLog.info("Done", LRUECKERT_DMGMETER_LOG_NAME)


# The method for determining what DLC is available depending on whether we are in context
# of the editor/decompiled game or normal game runtime
# Because the script extensions are installed prior game runtime, we have to initialize our
# own DLC detection
func _get_abyssal_terrors_dlc() -> bool:	
	if OS.has_feature("editor"):
		ModLoaderLog.info("Checking for DLC in editor mode", LRUECKERT_DMGMETER_LOG_NAME)
		var dir = Directory.new()
		var dir_path = "res://dlcs/"
		ModLoaderLog.info("Checking " + dir_path, LRUECKERT_DMGMETER_LOG_NAME)
		if not dir.dir_exists(dir_path):
			ModLoaderLog.info(dir_path + " does not exist", LRUECKERT_DMGMETER_LOG_NAME)
			return false
	
		dir.open(dir_path)
		dir.list_dir_begin(true)
	
		var dlc_dirs: Array = []
	
		var dir_name = dir.get_next()
		while dir_name != "":
			if dir.current_is_dir():
				dlc_dirs.push_back(dir_path + dir_name)
			dir_name = dir.get_next()
	
		for path in dlc_dirs:
			dir.open(path)
			dir.list_dir_begin(true)
			var file_name = dir.get_next()
			ModLoaderLog.info("Found DLC: " + file_name, LRUECKERT_DMGMETER_LOG_NAME)
			while file_name != "":
				if file_name == "dlc_data.tres":
					var dlc_data: = load(path + "/" + file_name) as DLCData
					if dlc_data.my_id == "abyssal_terrors":
						return true
				file_name = dir.get_next()
		return false
	else:
		ModLoaderLog.info("Checking for DLC in normal runtime mode", LRUECKERT_DMGMETER_LOG_NAME)
		return _load_dlc_pcks()

# Taken from ProgressData.load_dlc_packs
func _load_dlc_pcks() -> bool :
	var file = File.new()
	var dlc_path: String = _get_game_dir() + "/" + "BrotatoAbyssalTerrors.pck"
	ModLoaderLog.info("Searching Abyssal Terrors DLC at " + dlc_path, LRUECKERT_DMGMETER_LOG_NAME)
	return file.file_exists(dlc_path)

# Taken from Utils.get_game_dir
func _get_game_dir() -> String:
	var game_install_directory: = OS.get_executable_path().get_base_dir()

	if OS.get_name() == "OSX":
		game_install_directory = game_install_directory.get_base_dir().get_base_dir()

	if OS.has_feature("editor"):
		game_install_directory = "res://"

	return game_install_directory