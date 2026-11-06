extends "base_test.gd"

const MeterModel = preload("../../ui/hud/meter_model.gd")


func _item(key: String, total: int) -> Dictionary:
	return MeterModel.source_record(key, MeterModel.KIND_ITEM, total)


func _keys(rows: Array) -> Array:
	var keys = []
	for row in rows:
		keys.append(row["key"])
	return keys


func test_rows_are_sorted_by_total_descending() -> void:
	var rows = MeterModel.build_rows([_item("a", 5), _item("b", 20), _item("c", 10)], {})
	assert_eq(_keys(rows), ["b", "c", "a"])
	assert_eq(rows[0]["total"], 20, "row total")


func test_equal_totals_keep_their_input_order() -> void:
	var records = []
	var expected_high = []
	var expected_low = []
	for index in 40:
		var high = index % 2 == 0
		var key = "s%d" % index
		records.append(_item(key, 9 if high else 7))
		if high:
			expected_high.append(key)
		else:
			expected_low.append(key)
	assert_eq(_keys(MeterModel.build_rows(records, {})), expected_high + expected_low)


func test_zero_totals_are_hidden() -> void:
	var rows = MeterModel.build_rows([_item("a", 0), _item("b", 3), _item("c", 0)], {})
	assert_eq(_keys(rows), ["b"])


func test_entry_limit_keeps_only_the_highest_totals() -> void:
	var records = [_item("a", 1), _item("b", 4), _item("c", 3), _item("d", 2)]
	assert_eq(_keys(MeterModel.build_rows(records, {"entry_limit": 2})), ["b", "c"])


func test_entry_limit_zero_shows_every_source() -> void:
	var records = [_item("a", 1), _item("b", 4), _item("c", 3)]
	assert_eq(_keys(MeterModel.build_rows(records, {"entry_limit": 0})), ["b", "c", "a"])


func test_percentage_bar_ratios_are_relative_to_the_highest_visible_total() -> void:
	var records = [_item("a", 50), _item("b", 200), _item("c", 100)]
	var rows = MeterModel.build_rows(records, {"percentage_bars": true})
	assert_almost_eq(rows[0]["ratio"], 1.0, "b")
	assert_almost_eq(rows[1]["ratio"], 0.5, "c")
	assert_almost_eq(rows[2]["ratio"], 0.25, "a")


func test_percentage_bar_ratios_ignore_sources_cut_by_the_entry_limit() -> void:
	var rows = MeterModel.build_rows([_item("a", 40), _item("b", 80)], {"entry_limit": 1, "percentage_bars": true})
	assert_eq(rows.size(), 1)
	assert_almost_eq(rows[0]["ratio"], 1.0)


func test_percentage_bar_ratios_are_zero_when_bars_are_off() -> void:
	var rows = MeterModel.build_rows([_item("a", 40), _item("b", 80)], {"percentage_bars": false})
	assert_almost_eq(rows[0]["ratio"], 0.0, "b")
	assert_almost_eq(rows[1]["ratio"], 0.0, "a")


func test_all_zero_totals_give_no_rows() -> void:
	var rows = MeterModel.build_rows([_item("a", 0), _item("b", 0)], {"percentage_bars": true})
	assert_eq(rows, [])


func test_rows_carry_record_fields_and_display_data_through() -> void:
	var display = {"icon": "opaque icon", "icon_color": Color.gold}
	var record = MeterModel.source_record("weapon:1", MeterModel.KIND_WEAPON, 12, display, 2, true, true)
	var row = MeterModel.build_rows([record], {})[0]
	assert_eq(row["key"], "weapon:1")
	assert_eq(row["kind"], MeterModel.KIND_WEAPON)
	assert_eq(row["total"], 12)
	assert_eq(row["count"], 1)
	assert_eq(row["tier"], 2)
	assert_eq(row["cursed"], true)
	assert_eq(row["mechanized"], true)
	assert_eq(row["display"], display)


func test_weapon_rows_carry_weapon_id_and_instance_identity() -> void:
	var record = MeterModel.weapon_record("weapon:7", "weapon_smg", 7, 30, {}, 1, false, false)
	var row = MeterModel.build_rows([record], {})[0]
	assert_eq(row["kind"], MeterModel.KIND_WEAPON)
	assert_eq(row["weapon_id"], "weapon_smg")
	assert_eq(row["instance_id"], 7)
	assert_eq(row["tier"], 1)
