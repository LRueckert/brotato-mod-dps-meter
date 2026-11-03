extends "res://singletons/run_data.gd"


var dmgmeter_wave_snapshot: Array = []


func get_state() -> Dictionary:
	var state = .get_state()
	var saved_snapshot = []
	for player_snapshot in dmgmeter_wave_snapshot:
		var saved_player = []
		for entries in player_snapshot:
			var saved_entries = []
			for entry in entries:
				var texture = entry["texture"]
				if texture != null and not texture.resource_path.empty():
					saved_entries.append({
						"texture_path": texture.resource_path,
						"icon_color": entry.get("icon_color", Color.white).to_html(),
						"total": int(entry["total"])
					})
			saved_player.append(saved_entries)
		saved_snapshot.append(saved_player)
	state["dmgmeter_wave_snapshot"] = saved_snapshot
	return state


func resume_from_state(state: Dictionary) -> void:
	.resume_from_state(state)
	dmgmeter_wave_snapshot = []
	for saved_player in state.get("dmgmeter_wave_snapshot", []):
		var player_snapshot = []
		for saved_entries in saved_player:
			var entries = []
			for entry in saved_entries:
				var texture_path = str(entry.get("texture_path", ""))
				if not texture_path.begins_with("res://") or not ResourceLoader.exists(texture_path):
					continue
				var texture = load(texture_path)
				if texture is Texture:
					entries.append({
						"texture": texture,
						"icon_color": Color(entry.get("icon_color", "ffffffff")),
						"total": int(entry.get("total", 0))
					})
			player_snapshot.append(entries)
		dmgmeter_wave_snapshot.append(player_snapshot)


func reset(restart: bool = false) -> void:
	dmgmeter_wave_snapshot = []
	.reset(restart)