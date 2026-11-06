extends "res://ui/hud/ui_wave_timer.gd"


onready var _hud = get_tree().get_current_scene().get_node("UI/HUD")
var meter_update_timer: Timer = null
var meter_panel_hide_timer: Timer = null
var meter_panels: Array = []

func _ready() -> void:
	call_deferred("dmgmeter_initialize")

func dmgmeter_initialize() -> void:
	dmgmeter_register_timers()
	meter_panels = []
	RunData.materials_meter_reset()
	RunData.dmgmeter_spawner_credit_reset()
	RunData.dmgmeter_wave_snapshot = []
	var player_count = RunData.get_player_count()
	for i in player_count:
		var player_number = str(i + 1)
		var meter_panel = _hud.get_node("LifeContainerP%s/MeterPanelP%s" % [player_number, player_number])
		meter_panel.set_player(i)
		meter_panels.append(meter_panel)
	dmgmeter_update()

func dmgmeter_register_timers():
	meter_update_timer = Timer.new()
	if not meter_update_timer.is_connected("timeout", self, "dmgmeter_update"):
		var _discarded = meter_update_timer.connect("timeout", self, "dmgmeter_update")
	meter_update_timer.one_shot = false
	meter_update_timer.wait_time = 0.5
	add_child(meter_update_timer)
	meter_update_timer.start()
	
	meter_panel_hide_timer = Timer.new()
	if not meter_panel_hide_timer.is_connected("timeout", self, "dmgmeter_hide"):
		var _discarded = meter_panel_hide_timer.connect("timeout", self, "dmgmeter_hide")
	meter_panel_hide_timer.one_shot = true
	meter_panel_hide_timer.wait_time = 2
	add_child(meter_panel_hide_timer)

func dmgmeter_update():
	if wave_timer != null and is_instance_valid(wave_timer):
		var time = ceil(wave_timer.time_left)
		if time > 0:
			for i in RunData.get_player_count():
				meter_panels[i].visible = true
				for meter in meter_panels[i].meters:
					meter.refresh_sources()
		else:
			for i in RunData.get_player_count():
				for meter in meter_panels[i].meters:
					meter.refresh_sources()
			dmgmeter_capture_wave_snapshot()
			meter_panel_hide_timer.start()
			meter_update_timer.stop()
		return


func dmgmeter_capture_wave_snapshot() -> void:
	var snapshot = []
	for meter_panel in meter_panels:
		var player_snapshot = []
		for meter in meter_panel.meters:
			player_snapshot.append(meter.get_wave_snapshot_entries())
		snapshot.append(player_snapshot)
	RunData.dmgmeter_wave_snapshot = snapshot


func dmgmeter_hide():
	for i in RunData.get_player_count():
		meter_panels[i].visible = false
	RunData.materials_meter_active = false

