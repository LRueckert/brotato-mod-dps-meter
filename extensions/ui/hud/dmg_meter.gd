extends "res://ui/hud/ui_wave_timer.gd"


onready var _hud = get_tree().get_current_scene().get_node("UI/HUD")
var dmg_meter_timer: Timer = null
var hide_dmg_meter_timer: Timer = null
var meter_lists: Array = []

func _ready() -> void:
	dmgmeter_register_timers()
	meter_lists = []
	RunData.material_meter_reset()
	var player_count = RunData.get_player_count()
	for i in player_count:
		var player_index = str(i + 1)
		var lists = _hud.get_node("LifeContainerP%s/MeterListsP%s" % [player_index, player_index])
		lists.set_player(i)
		meter_lists.append(lists)
		for container in lists.containers:
			container.set_player(i, player_count)
	dmgmeter_update()

func dmgmeter_register_timers():
	dmg_meter_timer = Timer.new()
	if not dmg_meter_timer.is_connected("timeout", self, "dmgmeter_update"):
		var _discarded = dmg_meter_timer.connect("timeout", self, "dmgmeter_update")
	dmg_meter_timer.one_shot = false
	dmg_meter_timer.wait_time = 0.5
	add_child(dmg_meter_timer)
	dmg_meter_timer.start()
	
	hide_dmg_meter_timer = Timer.new()
	if not hide_dmg_meter_timer.is_connected("timeout", self, "dmgmeter_hide"):
		var _discarded = hide_dmg_meter_timer.connect("timeout", self, "dmgmeter_hide")
	hide_dmg_meter_timer.one_shot = true
	hide_dmg_meter_timer.wait_time = 2
	add_child(hide_dmg_meter_timer)

func dmgmeter_update():
	if wave_timer != null and is_instance_valid(wave_timer):
		var time = ceil(wave_timer.time_left)
		if time > 0:
			for i in RunData.get_player_count():
				meter_lists[i].visible = true
				for container in meter_lists[i].containers:
					container.trigger_element_updates()
		else:
			for i in RunData.get_player_count():
				for container in meter_lists[i].containers:
					container.trigger_element_updates()
			hide_dmg_meter_timer.start()
			dmg_meter_timer.stop()
		return

func dmgmeter_hide():
	for i in RunData.get_player_count():
		meter_lists[i].visible = false
	RunData.material_meter_active = false
