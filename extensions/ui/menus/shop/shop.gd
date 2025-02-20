extends "res://ui/menus/shop/shop.gd"

func _ready() -> void:
	# TODO: Make this work for co-op
	var shop_elite_wave_container = get_node("Content/MarginContainer/HBoxContainer/VBoxContainer2")
	var totaldamagePanel = get_node("%TotalDamagePanel") as TotalDamagePanel
	shop_elite_wave_container.move_child(totaldamagePanel, 2)
	# TODO: Obtain last waves total damage
	# The data calculated by Dmgmeter during a wave is lost
	# once we enter the shop so we should try to save it into RunData
	# or maybe Rundata.players_data
	totaldamagePanel.info_box.text = "Total Damage: yes"
	
