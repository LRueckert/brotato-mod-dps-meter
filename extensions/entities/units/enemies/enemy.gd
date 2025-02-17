extends "res://entities/units/enemies/enemy.gd"

func _dmgmeter_get_charm_enemy_effect_behavior_from_hitbox(hitbox: Object) -> CharmEnemyEffectBehavior:
	var unit = hitbox.from
	if unit is Enemy:
		var effect_behaviors = unit.effect_behaviors.get_children()
		for behavior in effect_behaviors:
			if behavior is CharmEnemyEffectBehavior:
				return behavior 
	return null

func take_damage(value: int, args: TakeDamageArgs)->Array:
	var dmg = .take_damage(value, args)
	if args.hitbox:
		var charm_enemy_effect_behavior = _dmgmeter_get_charm_enemy_effect_behavior_from_hitbox(args.hitbox)
		if charm_enemy_effect_behavior and charm_enemy_effect_behavior.charmed:
			# Damage is structured as a 3 element array. 
			# First element is full damage, second element is damage after overkill, third element is boolean for dodge
			RunData.add_tracked_value(charm_enemy_effect_behavior.charmed_by_player_index, "character_romantic", dmg[1])
	return dmg
