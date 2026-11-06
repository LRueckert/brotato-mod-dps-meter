# Credit Spawners by re-keying Structures at spawn time

In Brotato, Structures (turrets, landmines) record their damage under their own item key, such as `item_turret` or `item_landmines`. So the Turret item, a Wrench, and Pocket Factory tree turrets all add to one number. We want each Spawner credited with exactly its own Structures, even when two Spawners create the same Structure type and even per weapon instance. To do that, we extend the base game's Structure scripts so each spawned Structure gets a tracking key that identifies its Spawner.

## Considered Options

- **Relabel shared totals** (what Oudstand-DamageMeter 1.2.0 does): show the `item_turret*` or `item_landmines` total under the Spawner's icon. It's cheap and touches no Structure code, but it is wrong whenever two Spawners share a Structure type, for example the Turret item plus a Wrench. Rejected.
- **Re-key at spawn time** (chosen): extends the same technique Oudstand uses for Bot-o-Mine landmines to all Structures.

## Consequences

The mod now depends on internals and method signatures of `turret.gd`, `landmine.gd`, and the Structure spawn path. Burn damage from Structures goes through the `from` reference on the burn in `unit.gd`, because the base game credits every Engineering-scaled burn to `item_turret_flame`. Game updates that change any of these can silently break attribution, so check these first after every Brotato update.

The base game shares one StructureEffect object between every weapon of a tier and the matching item (Wrench T1 and the Turret item both use `turret_effect_1.tres`; every Crowbar and the Blood Turret item share `bleeding_turret_effect_1.tres`). So per-instance credit also depends on these `RunData` internals:

- `add_weapon(weapon, player_index, is_selection)`: a post-hook gives the new weapon its own copy of each StructureEffect and of each wrapper's nested `structure_effect` (for example `SpawnStructureEveryKilledEnemiesEffect`), tags the copy with the Spawner key as meta, and swaps the copy into the player's `structures` effect list. The copy keeps non-exported fields such as `tracking_key_hash` and `is_cursed`.
- `remove_weapon(weapon, player_index)`: the base removes the first weapon `ItemService.is_same_weapon` matches but unapplies the effects of the weapon it was given. When those differ, the kept weapon takes over the removed weapon's copies.
- `resume_from_state(state)`: resumed weapons own separately deserialized effects, matched to the `structures` list by `player_run_data.gd _get_or_deserialize_effect`, and are tagged again in place.
- `add_tracked_value(player_index, tracking_key, value, index)`: Spawner tracking keys are credited to the mod's per-wave ledger and then forwarded to the base game's own key, so item tooltips and run stats keep their totals. The Damage Meter subtracts the forwarded part from the item Source that owns that key.
- `turret.gd set_data(data)` and its `_damage_tracking_key_hash` field: the key is swapped after the base sets it. Subclasses (FlameTurret, BuilderTurret, Garden, WanderingBot) inherit the hook; only tagged data changes anything.

The Spawner key equals the Spawner's Damage Meter Source key (`weapon:<WeaponData instance id>` or `item:<item id>`), and the pure helper `ui/hud/spawner_credit.gd` builds keys, copies and tags effects, and keeps the ledger.
