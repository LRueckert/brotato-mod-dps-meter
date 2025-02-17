extends "res://entities/units/enemies/enemy.gd"

func _dmgmeter_get_charm_enemy_effect_behavior_from_hitbox(hitbox: Object) -> CharmEnemyEffectBehavior:
	# Hitboxes are children of Units and we can reference the parent with 'from'
	var unit = hitbox.from
	# We only care to check for effect behavior if it is an enemy
	if unit is Enemy:
		var effect_behaviors = unit.effect_behaviors.get_children()
		for behavior in effect_behaviors:
			if behavior is CharmEnemyEffectBehavior:
				return behavior 
	return null

func take_damage(value: int, args: TakeDamageArgs)->Array:
	var dmg = .take_damage(value, args)
	# Not everything that does damage has a hitbox
	# For example, the Lucky character innate ability does damage without a hitbox
	if args.hitbox:
		var charm_enemy_effect_behavior = _dmgmeter_get_charm_enemy_effect_behavior_from_hitbox(args.hitbox)
		# Use get() because above function could return Nil
		if charm_enemy_effect_behavior.get("charmed"):
			# Damage is structured as a 3 element array. 
			# First element is full damage, second element is damage after overkill, third element is boolean for dodge
			RunData.add_tracked_value(charm_enemy_effect_behavior.charmed_by_player_index, "character_romantic", dmg[1])
	return dmg
