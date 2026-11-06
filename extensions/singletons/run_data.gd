extends "res://singletons/run_data.gd"


const METER_MODEL = preload("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/meter_model.gd")


var dmgmeter_wave_snapshot: Array = []


func get_state() -> Dictionary:
	var state = .get_state()
	var saved_snapshot = []
	for player_snapshot in dmgmeter_wave_snapshot:
		var saved_player = []
		for records in player_snapshot:
			var saved_records = []
			for record in records:
				var texture = record["display"].get("icon")
				if texture != null and not texture.resource_path.empty():
					saved_records.append({
						"key": str(record["key"]),
						"kind": str(record["kind"]),
						"weapon_id": str(record.get("weapon_id", "")),
						"texture_path": texture.resource_path,
						"icon_color": record["display"].get("icon_color", Color.white).to_html(),
						"tier": int(record["tier"]),
						"cursed": bool(record["cursed"]),
						"mechanized": bool(record["mechanized"]),
						"total": int(record["total"])
					})
			saved_player.append(saved_records)
		saved_snapshot.append(saved_player)
	state["lrueckert_dmgmeter_wave_snapshot"] = saved_snapshot
	return state


func resume_from_state(state: Dictionary) -> void:
	.resume_from_state(state)
	dmgmeter_wave_snapshot = []
	for saved_player in state.get("lrueckert_dmgmeter_wave_snapshot", []):
		var player_snapshot = []
		for saved_records in saved_player:
			var records = []
			for saved in saved_records:
				var record = _dmgmeter_resume_record(saved)
				if not record.empty():
					records.append(record)
			player_snapshot.append(records)
		dmgmeter_wave_snapshot.append(player_snapshot)


func _dmgmeter_resume_record(saved: Dictionary) -> Dictionary:
	var texture_path = str(saved.get("texture_path", ""))
	if not texture_path.begins_with("res://") or not ResourceLoader.exists(texture_path):
		return {}
	var texture = load(texture_path)
	if not texture is Texture:
		return {}
	var display = {"icon": texture, "icon_color": Color(saved.get("icon_color", "ffffffff"))}
	var key = str(saved.get("key", ""))
	var kind = str(saved.get("kind", METER_MODEL.KIND_GROUPED))
	var total = int(saved.get("total", 0))
	var tier = int(saved.get("tier", -1))
	var cursed = bool(saved.get("cursed", false))
	var mechanized = bool(saved.get("mechanized", false))
	if kind == METER_MODEL.KIND_WEAPON:
		return METER_MODEL.weapon_record(key, str(saved.get("weapon_id", "")), -1, total, display, tier, cursed, mechanized)
	return METER_MODEL.source_record(key, kind, total, display, tier, cursed, mechanized)

func reset(restart: bool = false) -> void:
	dmgmeter_wave_snapshot = []
	.reset(restart)