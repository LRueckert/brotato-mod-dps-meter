extends Reference

# Base class for headless tests. Methods named test_* are run by run_tests.gd.

var failures: Array = []
var assertion_count: int = 0


func assert_eq(actual, expected, message: String = "") -> void:
	assertion_count += 1
	if typeof(actual) != typeof(expected) or actual != expected:
		failures.append("%sexpected %s, got %s" % [_prefix(message), str(expected), str(actual)])


func assert_almost_eq(actual, expected: float, message: String = "") -> void:
	assertion_count += 1
	if typeof(actual) != TYPE_REAL or abs(actual - expected) > 0.0001:
		failures.append("%sexpected %s, got %s" % [_prefix(message), str(expected), str(actual)])


func _prefix(message: String) -> String:
	return "" if message.empty() else message + ": "
