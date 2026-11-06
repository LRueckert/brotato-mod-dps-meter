extends "base_test.gd"

const BurnCredit = preload("../../ui/hud/burn_credit.gd")
const SpawnerCredit = preload("../../ui/hud/spawner_credit.gd")

const EMPTY_HASH = 5381
const FLAME_HASH = 3003
const OWN_KEY_HASH = 4004


func test_burn_tracking_name_differs_per_owner_and_from_hit_tracking() -> void:
	var name = BurnCredit.tracking_name("weapon:1", FLAME_HASH, 0)
	assert_eq(name == BurnCredit.tracking_name("weapon:1", FLAME_HASH, 1), false, "other owner")
	assert_eq(name == BurnCredit.tracking_name("weapon:2", FLAME_HASH, 0), false, "other spawner")
	assert_eq(name == SpawnerCredit.tracking_name("weapon:1", FLAME_HASH), false, "not a hit key")
	assert_eq(name.is_valid_integer(), false, "usable with Keys.generate_hash")


func test_only_spawned_structures_own_burns_are_tagged() -> void:
	assert_eq(BurnCredit.should_tag("weapon:1", false), true, "Wrench flame turret")
	assert_eq(BurnCredit.should_tag("", false), false, "Turret item flame turret keeps the base credit")
	assert_eq(BurnCredit.should_tag("weapon:1", true), false, "global burn belongs to the item granting it")


func test_flame_turret_burn_forwards_to_the_blanket_flame_key() -> void:
	assert_eq(BurnCredit.base_key(EMPTY_HASH, true, FLAME_HASH, EMPTY_HASH), FLAME_HASH)


func test_burn_with_its_own_tracking_key_forwards_there() -> void:
	assert_eq(BurnCredit.base_key(OWN_KEY_HASH, true, FLAME_HASH, EMPTY_HASH), OWN_KEY_HASH, "engineering")
	assert_eq(BurnCredit.base_key(OWN_KEY_HASH, false, FLAME_HASH, EMPTY_HASH), OWN_KEY_HASH, "elemental")


func test_untracked_non_engineering_burn_forwards_nowhere() -> void:
	assert_eq(BurnCredit.base_key(EMPTY_HASH, false, FLAME_HASH, EMPTY_HASH), EMPTY_HASH)


func test_burn_tick_credits_the_owner_and_offsets_the_burning_player() -> void:
	# Co-op: the base game gave the turret's burn to a random player (1),
	# but the Wrench belongs to player 0.
	var owner_ledger = SpawnerCredit.new_ledger()
	var burn_ledger = SpawnerCredit.new_ledger()
	BurnCredit.record(owner_ledger, burn_ledger, "weapon:1", FLAME_HASH, EMPTY_HASH, 12.9)
	assert_eq(owner_ledger["credit"].get("weapon:1"), 12, "owner's Wrench gets the tick, truncated")
	assert_eq(owner_ledger["forwarded"].has(FLAME_HASH), false, "owner's flame row untouched")
	assert_eq(burn_ledger["forwarded"].get(FLAME_HASH), 12, "burning player's flame row offset")
	assert_eq(burn_ledger["credit"].has("weapon:1"), false)


func test_burn_tick_for_the_owner_itself_lands_in_one_ledger() -> void:
	var ledger = SpawnerCredit.new_ledger()
	BurnCredit.record(ledger, ledger, "weapon:1", FLAME_HASH, EMPTY_HASH, 7)
	assert_eq(ledger["credit"].get("weapon:1"), 7)
	assert_eq(ledger["forwarded"].get(FLAME_HASH), 7)


func test_burn_tick_without_a_base_key_is_not_offset_anywhere() -> void:
	var ledger = SpawnerCredit.new_ledger()
	BurnCredit.record(ledger, ledger, "weapon:1", EMPTY_HASH, EMPTY_HASH, 7)
	assert_eq(ledger["credit"].get("weapon:1"), 7)
	assert_eq(ledger["forwarded"].empty(), true)


func test_blanket_credit_is_refunded_when_the_tick_was_also_forwarded_to_the_flame_key() -> void:
	# Blanket 9 + forwarded 9 landed on item_turret_flame: one of them is extra.
	assert_eq(BurnCredit.blanket_refund(18, 9), 9)


func test_blanket_credit_is_refunded_when_the_tick_was_forwarded_to_its_own_key() -> void:
	assert_eq(BurnCredit.blanket_refund(9, 0), 9)


func test_no_refund_without_a_blanket_credit() -> void:
	assert_eq(BurnCredit.blanket_refund(0, 0), 0, "elemental burn")
	assert_eq(BurnCredit.blanket_refund(9, 9), 0, "forward only")
	assert_eq(BurnCredit.blanket_refund(0, 9), 0, "never negative")


func test_wrench_flame_turret_burns_leave_the_turret_flame_item_row() -> void:
	# Turret-flame item turrets burned for 40 (blanket only). A tier 2 Wrench
	# turret's burn ticks for 10: blanket 10 + forwarded 10, then 10 refunded.
	var ledger = SpawnerCredit.new_ledger()
	var flame_tracked = 40
	var flame_before = flame_tracked
	flame_tracked += 10
	BurnCredit.record(ledger, ledger, "weapon:1", FLAME_HASH, EMPTY_HASH, 10)
	flame_tracked += 10
	flame_tracked -= BurnCredit.blanket_refund(flame_tracked - flame_before, 10)
	assert_eq(flame_tracked, 50, "base game total counts the tick once")
	assert_eq(SpawnerCredit.source_total(ledger, "item:item_turret_flame", flame_tracked, FLAME_HASH), 40, "item row")
	assert_eq(SpawnerCredit.source_total(ledger, "weapon:1", 0), 10, "Wrench row")
