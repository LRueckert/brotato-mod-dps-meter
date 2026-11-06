extends "base_test.gd"

# Checks the game hooks installed by mod_main.gd: each extension file exists in
# this checkout, extends a base script that exists, and compiles against the
# game. Mod paths (res://mods-unpacked/lrueckert-DmgMeter/) are pointed at this
# checkout, so a worktree checks its own files.

const MOD_PATH = "res://mods-unpacked/lrueckert-DmgMeter/"


func _checkout_dir() -> String:
	return get_script().resource_path.get_base_dir().get_base_dir().get_base_dir()


func _read(path: String) -> String:
	var file = File.new()
	if file.open(path, File.READ) != OK:
		return ""
	var text = file.get_as_text()
	file.close()
	return text


func _installed_extensions() -> Array:
	var regex = RegEx.new()
	regex.compile("install_script_extension\\(extensions_dir_path\\.plus_file\\(\"([^\"]+)\"\\)\\)")
	var paths = []
	for result in regex.search_all(_read(_checkout_dir().plus_file("mod_main.gd"))):
		paths.append(result.get_string(1))
	return paths


func test_mod_main_installs_extensions() -> void:
	assert_eq(_installed_extensions().size() > 0, true)


func test_every_installed_extension_exists_and_extends_an_existing_base_script() -> void:
	var extends_regex = RegEx.new()
	extends_regex.compile("^extends \"([^\"]+)\"")
	for path in _installed_extensions():
		var source = _read(_checkout_dir().plus_file("extensions").plus_file(path))
		assert_eq(source.empty(), false, "%s exists" % path)
		var match_result = extends_regex.search(source)
		assert_eq(match_result != null, true, "%s extends a script path" % path)
		if match_result != null:
			assert_eq(File.new().file_exists(match_result.get_string(1)), true, "%s base %s exists" % [path, match_result.get_string(1)])


func test_every_installed_extension_compiles() -> void:
	var extends_regex = RegEx.new()
	extends_regex.compile("^extends \"([^\"]+)\"")
	var index = 0
	for path in _installed_extensions():
		var source = _read(_checkout_dir().plus_file("extensions").plus_file(path))
		var match_result = extends_regex.search(source)
		if match_result != null:
			# ModLoader already extended the base script with the main checkout's
			# hooks, so compile against a fresh copy of the base game's script.
			var base_path = match_result.get_string(1)
			var vanilla = ResourceLoader.load(base_path, "", true)
			index += 1
			var alias = "res://dmgmeter_hook_test_base_%s.gd" % index
			vanilla.resource_path = alias
			source = source.replace("extends \"%s\"" % base_path, "extends \"%s\"" % alias)
		var script = GDScript.new()
		script.source_code = source.replace(MOD_PATH, _checkout_dir() + "/")
		assert_eq(script.reload(), OK, "%s compiles" % path)
