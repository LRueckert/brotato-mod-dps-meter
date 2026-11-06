extends Reference

# Meter Model: turns one Meter's Source records plus display options into the
# ordered rows a Meter or Wave Snapshot shows. Pure: no game globals, nodes or
# textures. Display data (icon, icon colour) is carried through untouched.
#
# Records come from source_record() / weapon_record(). build_rows() options:
#   entry_limit (int, 0 = no limit), percentage_bars (bool),
#   combine_duplicate_weapons (bool, default false).
# Each row is a copy of its record plus "count" (Sources in the row) and
# "ratio" (Percentage Bar share of the highest shown Total). Combined Duplicate
# Weapons (same weapon ID, tier, cursed, mechanized) form one row that keeps the
# first record's key and display data, with the summed Total and their count.
# Zero Totals are hidden after combining.
# Records with equal Totals keep their input order.

const KIND_WEAPON = "weapon"
const KIND_ITEM = "item"
const KIND_CHARACTER = "character"
const KIND_GROUPED = "grouped"


static func source_record(key: String, kind: String, total: int, display: Dictionary = {}, tier: int = -1, cursed: bool = false, mechanized: bool = false) -> Dictionary:
	return {
		"key": key,
		"kind": kind,
		"total": total,
		"tier": tier,
		"cursed": cursed,
		"mechanized": mechanized,
		"display": display,
	}


static func weapon_record(key: String, weapon_id: String, instance_id: int, total: int, display: Dictionary = {}, tier: int = -1, cursed: bool = false, mechanized: bool = false) -> Dictionary:
	var record = source_record(key, KIND_WEAPON, total, display, tier, cursed, mechanized)
	record["weapon_id"] = weapon_id
	record["instance_id"] = instance_id
	return record


# Wave Snapshots keep every record uncombined (zero Totals included), so
# build_rows() can combine or split them when the option changes.
static func wave_snapshot_entries(records: Array) -> Array:
	var entries = []
	for record in records:
		entries.append(record.duplicate(true))
	return entries


static func build_rows(records: Array, options: Dictionary) -> Array:
	var combine_duplicate_weapons = bool(options.get("combine_duplicate_weapons", false))
	var rows = []
	var combined_rows = {}
	for index in records.size():
		var record = records[index]
		var duplicate_key = _duplicate_weapon_key(record) if combine_duplicate_weapons else ""
		if combined_rows.has(duplicate_key):
			var combined_row = combined_rows[duplicate_key]
			combined_row["total"] += record["total"]
			combined_row["count"] += 1
			continue
		var row = record.duplicate()
		row["_order"] = index
		row["count"] = 1
		rows.append(row)
		if not duplicate_key.empty():
			combined_rows[duplicate_key] = row
	var visible_rows = []
	for row in rows:
		if row["total"] > 0:
			visible_rows.append(row)
	rows = visible_rows
	rows.sort_custom(RowSorter, "sorts_before")
	var entry_limit = int(options.get("entry_limit", 0))
	if entry_limit > 0 and rows.size() > entry_limit:
		rows.resize(entry_limit)
	var percentage_bars = bool(options.get("percentage_bars", true))
	var highest_total = rows[0]["total"] if not rows.empty() else 0
	for row in rows:
		row.erase("_order")
		row["ratio"] = float(row["total"]) / highest_total if percentage_bars else 0.0
	return rows


# Duplicate Weapons share this key; "" means the record never combines.
static func _duplicate_weapon_key(record: Dictionary) -> String:
	if record["kind"] != KIND_WEAPON or str(record.get("weapon_id", "")).empty():
		return ""
	return "%s|%d|%s|%s" % [record["weapon_id"], record["tier"], record["cursed"], record["mechanized"]]


class RowSorter:
	static func sorts_before(first: Dictionary, second: Dictionary) -> bool:
		if first["total"] == second["total"]:
			return first["_order"] < second["_order"]
		return first["total"] > second["total"]
