extends "base_test.gd"

const SnapshotScene = preload("../../ui/hud/wave_snapshot_meter.tscn")
const MeterModel = preload("../../ui/hud/meter_model.gd")


func test_snapshot_rows_are_visible_for_each_player() -> void:
	for player_index in 4:
		var meter = SnapshotScene.instance()
		Engine.get_main_loop().root.add_child(meter)
		var record = MeterModel.source_record("item", MeterModel.KIND_ITEM, 10 + player_index, {}, -1, false, false, 2)
		meter.set_entries([record])
		var sources = meter.get_node("ScrollContainer/Sources")
		assert_eq(sources.get_child_count(), 1, "snapshot row created")
		var row = sources.get_child(0)
		assert_eq(row.is_visible_in_tree(), true, "snapshot row visible for player %d" % player_index)
		assert_eq(row.get_total(), 10 + player_index, "snapshot total")
		assert_eq(row.icon_panel._coop_count.text, "×2", "snapshot item count")
		meter.free()
