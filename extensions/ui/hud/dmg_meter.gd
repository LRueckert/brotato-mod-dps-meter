extends "res://ui/hud/ui_wave_timer.gd"


onready var _hud = get_tree().get_current_scene().get_node("UI/HUD")
var dmg_meter_timer: Timer = null
var hide_dmg_meter_timer: Timer = null
onready var dmg_meter_containers: Array = []

func _ready() -> void:
	dmgmeter_register_timers()
	dmg_meter_containers = []
	var player_count = RunData.get_player_count()
	for i in player_count:
		var player_index = str(i + 1)
		var dmg_meter_container = _hud.get_node("LifeContainerP%s/DmgMeterContainerP%s" % [player_index, player_index])
		dmg_meter_containers.append(dmg_meter_container)
		dmg_meter_containers[i].set_elements(RunData.get_player_weapons(i), i, player_count, true)
		for el in RunData.get_player_items(i):
			if not dmg_meter_containers[i].items.has(el.my_id) && el.tracking_text == "DAMAGE_DEALT" || el.name == "ITEM_BUILDER_TURRET":
				dmg_meter_containers[i].add_element(el, i)
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
				dmg_meter_containers[i].visible = true
				dmg_meter_containers[i].trigger_element_updates()
		else:
			hide_dmg_meter_timer.start()
			dmg_meter_timer.stop()
		return

func dmgmeter_hide():
	for i in RunData.get_player_count():
		dmg_meter_containers[i].visible = false
