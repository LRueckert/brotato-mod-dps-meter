extends "base_test.gd"

const TrackedValues = preload("../../ui/hud/tracked_values.gd")


func test_single_tracked_value_is_its_own_total() -> void:
	assert_eq(TrackedValues.total(42), 42)


func test_tracked_array_totals_every_counter() -> void:
	assert_eq(TrackedValues.total([30, 12]), 42)


func test_bot_o_mine_damage_leaves_out_its_dropped_landmine_count() -> void:
	# Base game: item_bot_o_mine tracks [damage, dropped_landmines].
	assert_eq(TrackedValues.damage_total("item_bot_o_mine", [250, 7]), 250)


func test_hungry_hungry_dinosaur_damage_leaves_out_its_fruits_eaten() -> void:
	# Base game: item_hungry_hungry_dinosaur tracks [damage, fruits_eaten].
	assert_eq(TrackedValues.damage_total("item_hungry_hungry_dinosaur", [90, 4]), 90)


func test_bonk_dog_damage_counts_both_its_explosion_and_its_bite() -> void:
	# Base game: item_bonk_dog tracks [explosion damage, damage_dealt].
	assert_eq(TrackedValues.damage_total("item_bonk_dog", [60, 25]), 85)


func test_other_items_damage_is_their_tracked_value() -> void:
	assert_eq(TrackedValues.damage_total("item_turret", 120), 120)
