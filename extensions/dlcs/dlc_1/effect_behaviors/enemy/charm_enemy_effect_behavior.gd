extends "res://dlcs/dlc_1/effect_behaviors/enemy/charm_enemy_effect_behavior.gd"

# We need to track the player that charmed the enemy
# so that the correct character damage stats can be updated
func _ready()->void:
	var charmed_by_player_index: int

# Once the enemy has been charmed, 
# set the player who charmed them to the CharmEnemyEffectBehavior object	
func charm(from_player_index: int) -> void :
	.charm(from_player_index)
	self.charmed_by_player_index = from_player_index
