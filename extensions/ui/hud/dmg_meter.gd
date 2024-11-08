extends "res://ui/hud/ui_wave_timer.gd"


onready var _hud = get_tree().get_current_scene().get_node("UI/HUD")
var dmg_meter_timer: Timer = null
var hide_dmg_meter_timer: Timer = null
onready var dmg_meter_containers: Array = []

func _ready()->void:
	register_timers()
	dmg_meter_containers = []
	for i in RunData.get_player_count():
		var player_index = str(i+1)
		var dmg_meter_container = _hud.get_node("LifeContainerP%s/DmgMeterContainerP%s" % [player_index,player_index])
		dmg_meter_containers.append(dmg_meter_container)
		var player_weapons = RunData.get_player_weapons(i)
		dmg_meter_containers[i].set_elements(player_weapons, i, true)
	update_dmg_meters()

func register_timers():
	dmg_meter_timer = Timer.new()
	dmg_meter_timer.connect("timeout", self, "update_dmg_meters")
	dmg_meter_timer.one_shot = false  # Make sure it loops
	dmg_meter_timer.wait_time = 0.5
	add_child(dmg_meter_timer)
	dmg_meter_timer.start()
	
	hide_dmg_meter_timer = Timer.new()
	hide_dmg_meter_timer.connect("timeout", self, "hide_dmg_meters")
	hide_dmg_meter_timer.one_shot = true
	hide_dmg_meter_timer.wait_time = 2
	add_child(
	hide_dmg_meter_timer)

func update_dmg_meters():
	if wave_timer != null and is_instance_valid(wave_timer) and not is_run_lost:
		var time = ceil(wave_timer.time_left)
		if time > 0:
			for i in RunData.get_player_count():
				dmg_meter_containers[i].visible = true
				dmg_meter_containers[i].trigger_element_updates()
		else:
			hide_dmg_meter_timer.start()
			dmg_meter_timer.stop()
		return

func hide_dmg_meters():
	for i in RunData.get_player_count():
		dmg_meter_containers[i].visible = false
