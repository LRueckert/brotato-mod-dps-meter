# 05: Spawner crediting for turrets (Wrench and Turret item)

**What to build:** Turrets credit their damage to their Spawner. A Wrench's turrets count toward that specific Wrench, and the Turret item's turrets count toward the Turret item, even when a player owns both or holds two Wrenches. This is the first slice of ADR 0001: the turret's tracking key is swapped for one that identifies its Spawner when the turret spawns. See the parent spec's user stories 1–4, 11–13.

**Blocked by:** 01 (Rename everything to glossary terms), 02 (Meter Model and headless test runner).

**Status:** done

- [x] **First, investigate:** confirm in the base game that each Wrench instance's turret StructureEffect can be told apart (separate objects, or another per-instance handle). If per-instance attribution isn't possible without significantly more work, **stop and ask the maintainer**; don't fall back to splitting by weapon type.
  - Resolved (2026-11-06): the effects are shared between instances. The maintainer approved a post-hook on `RunData.add_weapon` that gives each weapon its own duplicate of its StructureEffect, swaps it into the player's structures list, and tags it again after `resume_from_state`.
- [ ] Bleeding turrets spawned by a Crowbar (any tier, including cursed and mechanized) credit that Crowbar instance. Blood Turret item turrets keep crediting the Blood Turret item, even when a player owns both.
- [x] The `add_weapon` post-hook also gives each weapon its own copy of any wrapper effect that holds a `structure_effect` (for example `SpawnStructureEveryKilledEnemiesEffect`) and of that nested `structure_effect`, and tags both again after `resume_from_state`.
- [x] When a turret spawns, its tracking key is set to one that identifies its Spawner (that Wrench instance, or the Turret item), following the key-swap technique Oudstand-DamageMeter uses for Bot-o-Mine.
- [x] The Damage Meter adds Spawner credit to the Spawner's own Total; turrets with a Spawner are no longer separate Sources.
- [x] The hard-coded Wrench → turret mapping is removed.
- [ ] Co-op: each player's turrets credit only that player's Spawner.
- [ ] Players without Wrench or Turret item see no change.
- [x] Each base-game method this ticket overrides keeps the base game's signature and calls the base implementation; any dependency on base-game internals is listed in ADR 0001's Consequences if it isn't there already.
- [ ] In-game check: Wrench alone at each tier; Turret item plus a Wrench; two same-tier Wrenches; Crowbar alone; Crowbar plus Blood Turret item; two same-tier Crowbars; for 1 player and for 3–4 players.
