# 05: Spawner crediting for turrets (Wrench and Turret item)

**What to build:** Turrets credit their damage to their Spawner. A Wrench's turrets count toward that specific Wrench, and the Turret item's turrets count toward the Turret item, even when a player owns both or holds two Wrenches. This is the first slice of ADR 0001: the turret's tracking key is swapped for one that identifies its Spawner when the turret spawns. See the parent spec's user stories 1–4, 11–13.

**Blocked by:** 01 (Rename everything to glossary terms), 02 (Meter Model and headless test runner).

**Status:** ready-for-agent

- [ ] **First, investigate:** confirm in the base game that each Wrench instance's turret StructureEffect can be told apart (separate objects, or another per-instance handle). If per-instance attribution isn't possible without significantly more work, **stop and ask the maintainer**; don't fall back to splitting by weapon type.
- [ ] When a turret spawns, its tracking key is set to one that identifies its Spawner (that Wrench instance, or the Turret item), following the key-swap technique Oudstand-DamageMeter uses for Bot-o-Mine.
- [ ] The Damage Meter adds Spawner credit to the Spawner's own Total; turrets with a Spawner are no longer separate Sources.
- [ ] The hard-coded Wrench → turret mapping is removed.
- [ ] Co-op: each player's turrets credit only that player's Spawner.
- [ ] Players without Wrench or Turret item see no change.
- [ ] Each base-game method this ticket overrides keeps the base game's signature and calls the base implementation; any dependency on base-game internals is listed in ADR 0001's Consequences if it isn't there already.
- [ ] In-game check: Wrench alone at each tier; Turret item plus a Wrench; two same-tier Wrenches; for 1 player and for 3–4 players.
