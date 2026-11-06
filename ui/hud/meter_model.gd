extends Reference

# Meter Model: turns one Meter's Source records plus display options into the
# ordered rows a Meter or Wave Snapshot shows. Pure: no game globals, nodes or
# textures. Display data (icon, icon colour) is carried through untouched.
#
# Records come from source_record() / weapon_record(). build_rows() options:
#   entry_limit (int, 0 = no limit), percentage_bars (bool).
# Each row is a copy of its record plus "count" (Sources in the row) and
# "ratio" (Percentage Bar share of the highest shown Total).
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


static func build_rows(records: Array, options: Dictionary) -> Array:
	var rows = []
	for index in records.size():
		if records[index]["total"] <= 0:
			continue
		var row = records[index].duplicate()
		row["_order"] = index
		rows.append(row)
	rows.sort_custom(RowSorter, "sorts_before")
	var entry_limit = int(options.get("entry_limit", 0))
	if entry_limit > 0 and rows.size() > entry_limit:
		rows.resize(entry_limit)
	var percentage_bars = bool(options.get("percentage_bars", true))
	var highest_total = rows[0]["total"] if not rows.empty() else 0
	for row in rows:
		row.erase("_order")
		row["count"] = 1
		row["ratio"] = float(row["total"]) / highest_total if percentage_bars else 0.0
	return rows


class RowSorter:
	static func sorts_before(first: Dictionary, second: Dictionary) -> bool:
		if first["total"] == second["total"]:
			return first["_order"] < second["_order"]
		return first["total"] > second["total"]
