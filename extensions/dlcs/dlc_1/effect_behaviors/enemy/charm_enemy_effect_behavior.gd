extends "res://dlcs/dlc_1/effect_behaviors/enemy/charm_enemy_effect_behavior.gd"

func _ready()->void:
	var charmed_by_player_index: int
	
func charm(from_player_index: int) -> void :
	.charm(from_player_index)
	self.charmed_by_player_index = from_player_index
