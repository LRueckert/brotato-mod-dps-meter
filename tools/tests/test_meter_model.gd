extends "base_test.gd"

const MeterModel = preload("../../ui/hud/meter_model.gd")


func _item(key: String, total: int, count: int = 1) -> Dictionary:
	return MeterModel.source_record(key, MeterModel.KIND_ITEM, total, {}, -1, false, false, count)


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


func _smg(key: String, total: int, tier: int = 0, cursed: bool = false, mechanized: bool = false, weapon_id: String = "weapon_smg") -> Dictionary:
	return MeterModel.weapon_record(key, weapon_id, key.hash(), total, {}, tier, cursed, mechanized)


func _combined(records: Array) -> Array:
	return MeterModel.build_rows(records, {"combine_duplicate_weapons": true})


func test_duplicate_weapons_combine_into_one_row_with_summed_total_and_count() -> void:
	var rows = _combined([_smg("w1", 10), _smg("w2", 25), _smg("w3", 5)])
	assert_eq(rows.size(), 1, "row count")
	assert_eq(rows[0]["total"], 40, "summed total")
	assert_eq(rows[0]["count"], 3, "count")


func test_duplicate_weapons_stay_separate_by_default() -> void:
	var rows = MeterModel.build_rows([_smg("w1", 10), _smg("w2", 25)], {})
	assert_eq(_keys(rows), ["w2", "w1"])
	assert_eq(rows[0]["count"], 1, "count")


func test_weapons_differing_in_any_match_field_stay_separate() -> void:
	var cases = {
		"weapon id": _smg("other", 7, 0, false, false, "weapon_minigun"),
		"tier": _smg("other", 7, 1),
		"cursed": _smg("other", 7, 0, true),
		"mechanized": _smg("other", 7, 0, false, true),
	}
	for field in cases:
		var rows = _combined([_smg("w1", 10), _smg("w2", 20), cases[field]])
		assert_eq(_keys(rows), ["w1", "other"], field)
		assert_eq(rows[0]["total"], 30, field + " combined total")
		assert_eq(rows[1]["count"], 1, field + " separate count")


func test_item_character_and_grouped_sources_never_combine() -> void:
	for kind in [MeterModel.KIND_ITEM, MeterModel.KIND_CHARACTER, MeterModel.KIND_GROUPED]:
		var records = [
			MeterModel.source_record("a", kind, 10, {}, 0),
			MeterModel.source_record("b", kind, 20, {}, 0),
		]
		var rows = _combined(records)
		assert_eq(_keys(rows), ["b", "a"], kind)
		assert_eq(rows[0]["count"], 1, kind + " count")


func test_combined_row_uses_the_first_weapons_key_and_display_data() -> void:
	var first = MeterModel.weapon_record("w1", "weapon_smg", 1, 5, {"icon": "first"}, 0)
	var second = MeterModel.weapon_record("w2", "weapon_smg", 2, 50, {"icon": "second"}, 0)
	var row = _combined([first, second])[0]
	assert_eq(row["key"], "w1")
	assert_eq(row["display"]["icon"], "first")


func test_item_rows_show_their_inventory_stack_count() -> void:
	var stacked = _item("stacked", 10, 4)
	assert_eq(stacked["count"], 4, "record count")
	for options in [{}, {"combine_duplicate_weapons": true}]:
		var rows = MeterModel.build_rows([stacked, _item("single", 5)], options)
		assert_eq(rows[0]["count"], 4, "stacked item count")
		assert_eq(rows[1]["count"], 1, "single item count")


func test_combined_row_counts_duplicates_whose_own_total_is_zero() -> void:
	var rows = _combined([_smg("w1", 0), _smg("w2", 12), _smg("w3", 0)])
	assert_eq(rows.size(), 1, "row count")
	assert_eq(rows[0]["total"], 12, "total")
	assert_eq(rows[0]["count"], 3, "count")


func test_combined_duplicates_with_zero_totals_are_hidden() -> void:
	assert_eq(_combined([_smg("w1", 0), _smg("w2", 0)]), [])


func test_combined_rows_sort_and_apply_entry_limit_and_ratios_by_summed_total() -> void:
	var records = [_item("item", 30), _smg("w1", 20), _smg("w2", 20)]
	var rows = MeterModel.build_rows(records, {"combine_duplicate_weapons": true, "entry_limit": 1, "percentage_bars": true})
	assert_eq(_keys(rows), ["w1"])
	assert_almost_eq(rows[0]["ratio"], 1.0)


func _row_summary(rows: Array) -> Array:
	var summary = []
	for row in rows:
		summary.append([row["key"], row["total"], row["count"], row["ratio"]])
	return summary


func test_uncombined_wave_snapshot_gives_the_same_rows_as_the_live_meter() -> void:
	var records = [
		_smg("w1", 0), _smg("w2", 12), _smg("w3", 8, 1),
		_item("item", 15), MeterModel.source_record("grouped", MeterModel.KIND_GROUPED, 3),
	]
	var entries = MeterModel.wave_snapshot_entries(records)
	for combine in [false, true]:
		var options = {"combine_duplicate_weapons": combine, "percentage_bars": true}
		assert_eq(str(_row_summary(MeterModel.build_rows(entries, options))), str(_row_summary(MeterModel.build_rows(records, options))), "combine %s" % combine)


func test_wave_snapshot_entries_are_uncombined_copies_with_weapon_fields() -> void:
	var records = [_smg("w1", 4, 2, true, true), _smg("w2", 6, 2, true, true)]
	var entries = MeterModel.wave_snapshot_entries(records)
	records[0]["total"] = 99
	assert_eq(entries.size(), 2, "entry count")
	assert_eq(entries[0]["total"], 4, "copied total")
	assert_eq(entries[0]["weapon_id"], "weapon_smg")
	assert_eq(entries[0]["kind"], MeterModel.KIND_WEAPON)
	assert_eq(entries[0]["tier"], 2)
	assert_eq(entries[0]["cursed"], true)
	assert_eq(entries[0]["mechanized"], true)
