extends "res://ui/hud/ui_wave_timer.gd"

onready var dmgmeter_hud: MarginContainer = get_tree().get_current_scene().get_node("UI/HUD")

signal dmg_meter_update

var dmg_meter_container
var _dmg_meter_timer = null

func _ready()->void:
	dmg_meter_container = load("res://mods-unpacked/lrueckert-DmgMeter/ui/hud/dmg_meter_container.tscn").instance()
	dmgmeter_hud.margin_bottom = 0
	dmgmeter_hud.anchor_bottom = 1
	dmgmeter_hud.call_deferred("add_child", dmg_meter_container)
	dmgmeter_hud.mouse_filter = MOUSE_FILTER_IGNORE
	
	_dmg_meter_timer = Timer.new()
	add_child(_dmg_meter_timer)
	_dmg_meter_timer.connect("timeout", self, "_update_stats_ui")
	_dmg_meter_timer.set_one_shot(false) # Make sure it loops
	_dmg_meter_timer.set_wait_time(0.5)
	_dmg_meter_timer.start()
	
	var t = Timer.new()
	
	t.set_wait_time(.2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")

	var player_weapons = RunData.get_player_weapons(0)
	dmg_meter_container.set_elements(player_weapons, true)
	_update_stats_ui()

func _update_stats_ui():
	if wave_timer != null and is_instance_valid(wave_timer) and not is_run_lost:
		var time = ceil(wave_timer.time_left)
		if time > 0:
			dmg_meter_container.visible = true
			dmg_meter_container.trigger_element_updates()
		else:
			dmg_meter_container.visible = false
			return


