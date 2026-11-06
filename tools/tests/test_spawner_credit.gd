extends "base_test.gd"

const SpawnerCredit = preload("../../ui/hud/spawner_credit.gd")

const TURRET_HASH = 1001


class FakeStructureEffect extends Resource:
	export(int) var spawn_cooldown = -1
	export(String) var tracking_key = ""
	var tracking_key_hash: int = 0
	var is_cursed: bool = false


class FakeWrapperEffect extends Resource:
	export(int) var value = 0
	export(Resource) var structure_effect = null


class FakeStatEffect extends Resource:
	export(int) var value = 0


# Like ItemExplodingEffect: a duplicate regenerates tracking_key_hash from
# tracking_key one frame later.
class FakeExplodingEffect extends Resource:
	export(float) var scale = 1.0
	export(String) var tracking_key = ""
	var tracking_key_hash: int = 0

	func _generate_hashes() -> void:
		tracking_key_hash = tracking_key.hash()


func _structure(tracking_key: String = "item_turret") -> Resource:
	var effect = FakeStructureEffect.new()
	effect.spawn_cooldown = 10
	effect.tracking_key = tracking_key
	effect.tracking_key_hash = TURRET_HASH
	return effect


func test_weapon_spawner_key_matches_its_damage_meter_source_key() -> void:
	assert_eq(SpawnerCredit.weapon_key(42), "weapon:42")
	assert_eq(SpawnerCredit.item_key("item_turret"), "item:item_turret")


func test_tracking_name_differs_per_spawner_and_structure_key() -> void:
	var first = SpawnerCredit.tracking_name("weapon:1", TURRET_HASH)
	assert_eq(first == SpawnerCredit.tracking_name("weapon:2", TURRET_HASH), false, "other spawner")
	assert_eq(first == SpawnerCredit.tracking_name("weapon:1", 2002), false, "other structure key")
	assert_eq(first.is_valid_integer(), false, "usable with Keys.generate_hash")


func test_weapon_gets_its_own_tagged_copy_of_a_shared_structure_effect() -> void:
	var shared = _structure()
	shared.is_cursed = true
	var stat = FakeStatEffect.new()
	var weapon_effects = [stat, shared]
	# The Turret item and the Wrench both pushed the same object.
	var structures = [shared, shared]
	var owned = SpawnerCredit.own_effects(weapon_effects, "weapon:7", structures)
	var copy = owned[1]
	assert_eq(copy == shared, false, "copy is a new object")
	assert_eq(owned[0] == stat, true, "other effects are kept")
	assert_eq(weapon_effects[1] == shared, true, "the input array is left alone")
	assert_eq(SpawnerCredit.spawner_key_of(copy), "weapon:7", "copy is tagged")
	assert_eq(SpawnerCredit.spawner_key_of(shared), "", "shared original stays untagged")
	assert_eq(copy.tracking_key_hash, TURRET_HASH, "non-exported tracking hash kept")
	assert_eq(copy.is_cursed, true, "non-exported cursed state kept")
	assert_eq(copy.spawn_cooldown, 10, "exported fields kept")
	assert_eq(structures[0] == copy, true, "one occurrence swapped for the copy")
	assert_eq(structures[1] == shared, true, "the other Spawner keeps the original")


func test_wrapper_and_its_nested_structure_effect_are_copied_and_the_nested_one_tagged() -> void:
	# Crowbar: every Crowbar of a tier and the Blood Turret item share these objects.
	var shared_turret = _structure("item_bleeding_turret")
	var shared_wrapper = FakeWrapperEffect.new()
	shared_wrapper.value = 18
	shared_wrapper.structure_effect = shared_turret
	var structures = [shared_turret]
	var owned = SpawnerCredit.own_effects([shared_wrapper], "weapon:9", structures)
	var wrapper = owned[0]
	assert_eq(wrapper == shared_wrapper, false, "wrapper is copied")
	assert_eq(wrapper.value, 18, "wrapper fields kept")
	assert_eq(wrapper.structure_effect == shared_turret, false, "nested effect is copied")
	assert_eq(shared_wrapper.structure_effect == shared_turret, true, "shared wrapper left alone")
	assert_eq(SpawnerCredit.spawner_key_of(wrapper.structure_effect), "weapon:9", "nested copy tagged")
	assert_eq(SpawnerCredit.spawner_key_of(shared_turret), "", "Blood Turret item's effect stays untagged")
	assert_eq(structures[0] == shared_turret, true, "wrapped effects are not in the structures list")


func test_two_weapons_sharing_an_effect_each_credit_only_their_own_copy() -> void:
	var shared = _structure()
	var structures = [shared, shared]
	var first = SpawnerCredit.own_effects([shared], "weapon:1", structures)[0]
	var second = SpawnerCredit.own_effects([shared], "weapon:2", structures)[0]
	assert_eq(SpawnerCredit.spawner_key_of(first), "weapon:1")
	assert_eq(SpawnerCredit.spawner_key_of(second), "weapon:2")
	assert_eq(structures.has(first) and structures.has(second), true, "both copies spawn")
	assert_eq(structures.has(shared), false, "the shared original no longer spawns")


func test_resumed_weapon_effects_are_tagged_in_place() -> void:
	# After resume_from_state each weapon already holds its own deserialized objects,
	# and those same objects are in the structures list.
	var structure = _structure()
	var nested = _structure("item_bleeding_turret")
	var wrapper = FakeWrapperEffect.new()
	wrapper.structure_effect = nested
	var effects = [structure, wrapper]
	SpawnerCredit.tag_effects(effects, "weapon:3")
	assert_eq(effects[0] == structure and effects[1] == wrapper and wrapper.structure_effect == nested, true, "same objects")
	assert_eq(SpawnerCredit.spawner_key_of(structure), "weapon:3", "structure effect")
	assert_eq(SpawnerCredit.spawner_key_of(nested), "weapon:3", "nested structure effect")


func test_spawner_credit_is_added_to_the_spawner_source_total() -> void:
	var ledger = SpawnerCredit.new_ledger()
	SpawnerCredit.record(ledger, "weapon:1", TURRET_HASH, 30)
	SpawnerCredit.record(ledger, "weapon:1", TURRET_HASH, 20.7)
	# The Wrench's own melee hits are 15.
	assert_eq(SpawnerCredit.source_total(ledger, "weapon:1", 15), 65)
	assert_eq(SpawnerCredit.source_total(ledger, "weapon:2", 15), 15, "other weapon gets nothing")


func test_item_source_loses_the_credit_forwarded_to_its_key() -> void:
	# Turret item plus Wrench: the base game's item_turret total holds both.
	var ledger = SpawnerCredit.new_ledger()
	SpawnerCredit.record(ledger, "weapon:1", TURRET_HASH, 50)
	var item_turret_tracked = 150
	assert_eq(SpawnerCredit.source_total(ledger, "item:item_turret", item_turret_tracked, TURRET_HASH), 100, "Turret item")
	assert_eq(SpawnerCredit.source_total(ledger, "weapon:1", 0), 50, "Wrench")


func test_item_source_total_never_goes_negative() -> void:
	var ledger = SpawnerCredit.new_ledger()
	SpawnerCredit.record(ledger, "weapon:1", TURRET_HASH, 50)
	assert_eq(SpawnerCredit.source_total(ledger, "item:item_turret", 20, TURRET_HASH), 0)


func test_kept_weapon_adopts_the_copy_left_by_an_identical_removed_weapon() -> void:
	# Two Wrenches A and B. Selling B makes the base game drop A from the weapons
	# list but erase B's copy from the structures list, so A's copy keeps spawning.
	var shared = _structure()
	var structures = [shared, shared]
	var a_effects = SpawnerCredit.own_effects([shared], "weapon:A", structures)
	var b_effects = SpawnerCredit.own_effects([shared], "weapon:B", structures)
	structures.erase(b_effects[0])
	SpawnerCredit.adopt_structure_effects(b_effects, a_effects, "weapon:B")
	assert_eq(b_effects[0] == structures[0], true, "B now owns the copy that still spawns")
	assert_eq(SpawnerCredit.spawner_key_of(structures[0]), "weapon:B", "and its turrets credit B")
	assert_eq(a_effects[0] == structures[0], true, "a later unapply of A still erases it")


func test_landmine_explosion_is_a_copy_tracked_under_the_spawner_name() -> void:
	# Screwdriver, Carbon Bow and Bot-o-Mine mines share one explosion effect with the Landmines item.
	var shared = FakeExplodingEffect.new()
	shared.scale = 1.75
	shared.tracking_key = "item_landmines"
	shared.tracking_key_hash = 2002
	var extra = FakeStatEffect.new()
	var mine_effects = [shared, extra]
	var name = SpawnerCredit.tracking_name("weapon:4", 2002)
	var retracked = SpawnerCredit.retrack_explosion(mine_effects, name, name.hash())
	var copy = retracked[0]
	assert_eq(copy == shared, false, "explosion is copied")
	assert_eq(copy.scale, 1.75, "explosion fields kept")
	assert_eq(copy.tracking_key_hash, name.hash(), "copy tracks under the Spawner")
	copy._generate_hashes()
	assert_eq(copy.tracking_key_hash, name.hash(), "still after its hashes are regenerated")
	assert_eq(retracked[1] == extra, true, "other effects are kept")
	assert_eq(mine_effects[0] == shared and shared.tracking_key_hash == 2002 and shared.tracking_key == "item_landmines", true, "shared array and effect left alone")


func test_mine_without_effects_is_left_alone() -> void:
	assert_eq(SpawnerCredit.retrack_explosion([], "x", 1), [])


func test_tagged_copy_leaves_the_shared_effect_to_its_other_spawners() -> void:
	# Pocket Factory spawns from the Turret item's own turret effect.
	var shared = _structure()
	var copy = SpawnerCredit.tagged_copy(shared, "item:item_pocket_factory")
	assert_eq(copy == shared, false, "copy is a new object")
	assert_eq(SpawnerCredit.spawner_key_of(copy), "item:item_pocket_factory", "copy is tagged")
	assert_eq(SpawnerCredit.spawner_key_of(shared), "", "Turret item's effect stays untagged")
	assert_eq(copy.tracking_key_hash, TURRET_HASH, "copy keeps the base tracking key")


func test_wrapper_without_a_structure_effect_is_not_copied() -> void:
	# Carbon Bow's non-Engineering stat effects hold no structure_effect.
	var plain = FakeWrapperEffect.new()
	var engineering = FakeWrapperEffect.new()
	engineering.structure_effect = _structure("item_landmines")
	var owned = SpawnerCredit.own_effects([plain, engineering], "weapon:5", [])
	assert_eq(owned[0] == plain, true, "plain wrapper kept")
	assert_eq(SpawnerCredit.spawner_key_of(owned[1].structure_effect), "weapon:5", "engineering mines tagged")
	assert_eq(SpawnerCredit.spawner_key_of(engineering.structure_effect), "", "Landmines item's effect stays untagged")
