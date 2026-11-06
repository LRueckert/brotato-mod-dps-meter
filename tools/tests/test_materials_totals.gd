extends "base_test.gd"

const MaterialsTotals = preload("../../ui/hud/materials_totals.gd")


func test_positive_harvesting_is_split_out_of_other() -> void:
	# 100 gained: 40 Pickups, 25 Harvesting, 20 from items/weapons, 15 unclaimed.
	var totals = MaterialsTotals.split(100, 40, 25, 20)
	assert_eq(totals["harvesting"], 25, "harvesting")
	assert_eq(totals["other"], 15, "other")


func test_negative_harvesting_shows_zero_and_does_not_cut_into_other() -> void:
	var totals = MaterialsTotals.split(30, 20, -8, 5)
	assert_eq(totals["harvesting"], 0, "harvesting")
	assert_eq(totals["other"], 5, "other")


func test_other_is_never_negative() -> void:
	# Claimed gains exceed the recorded total (e.g. a tracked item counted a gain the meter missed).
	var totals = MaterialsTotals.split(10, 6, 3, 4)
	assert_eq(totals["harvesting"], 3, "harvesting")
	assert_eq(totals["other"], 0, "other")


func test_no_harvesting_leaves_unclaimed_gains_in_other() -> void:
	var totals = MaterialsTotals.split(50, 30, 0, 12)
	assert_eq(totals["harvesting"], 0, "harvesting")
	assert_eq(totals["other"], 8, "other")
