class_name LastWaveDamageContainer
extends SecondaryStatContainer

func _ready():
	call_deferred("_deferred_move_to_top")
	

func update_player_stat(player_index: int) -> void:	
	var total_damage = RunData.last_wave_total_damage[player_index]
	_value.text = Utils.format_number(total_damage as int)

func _deferred_move_to_top():
	var parent = get_parent()
	if parent:
		parent.move_child(self, 0)
