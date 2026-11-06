extends SceneTree

# Headless test runner. Runs every test_*.gd script next to this file and
# exits with a non-zero code if any test fails. See README "Development Notes".


func _init() -> void:
	# Counts as a failure if this function aborts before quit() below (run with --quit).
	OS.exit_code = 1
	call_deferred("_run_tests")


func _run_tests() -> void:
	var tests_dir = get_script().resource_path.get_base_dir()
	var passed = 0
	var failed = 0
	for file_name in _list_test_scripts(tests_dir):
		var script = load(tests_dir.plus_file(file_name))
		var test_case = script.new() if script != null and script.can_instance() else null
		if test_case == null:
			print("FAIL %s: could not load script" % file_name)
			failed += 1
			continue
		for method in test_case.get_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			test_case.failures.clear()
			test_case.assertion_count = 0
			test_case.call(method_name)
			if test_case.assertion_count == 0:
				test_case.failures.append("no assertions ran (script error?)")
			if test_case.failures.empty():
				print("PASS %s: %s" % [file_name, method_name])
				passed += 1
			else:
				print("FAIL %s: %s" % [file_name, method_name])
				for failure in test_case.failures:
					print("    %s" % failure)
				failed += 1
	print("%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 or passed == 0 else 0)


func _list_test_scripts(tests_dir: String) -> Array:
	var files = []
	var dir = Directory.new()
	if dir.open(tests_dir) != OK:
		print("Cannot open test folder %s" % tests_dir)
		return files
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while not file_name.empty():
		if file_name.begins_with("test_") and file_name.ends_with(".gd"):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	files.sort()
	return files
