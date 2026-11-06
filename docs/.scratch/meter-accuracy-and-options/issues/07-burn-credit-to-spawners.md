# 07: Burn damage credited to Spawners

**What to build:** Burns applied by a Structure, such as a flame turret, count toward that Structure's Spawner. The base game credits every Engineering-scaled burn to the flame turret item. Burns from anything that isn't a Structure stay as they are today. See the parent spec's user stories 8–9.

**Blocked by:** 05 (Spawner crediting for turrets).

**Status:** ready-for-agent

- [ ] Burn damage started by a Structure that has a Spawner is credited to that Spawner (per Wrench instance, or the Turret item).
- [x] ~~If the burn's `from` reference turns out to be unreliable, stop and ask the maintainer.~~ Resolved (2026-11-06): `from` is always null for turret burns, and Structures are pooled. The maintainer approved the "tag" approach: tag each turret's own `stats.burning_data.tracking_key_hash` with its Spawner key at spawn and in `reload_data`/`set_current_stats`, and wrap `unit.gd _on_BurningTimer_timeout` to credit the Spawner. Do NOT set `burning_data.from`; that changes gameplay.
- [ ] The base game's blanket flame-turret (`item_turret_flame`) credit for that burn tick is subtracted, so nothing is counted twice.
- [ ] Burns from non-Structures are credited exactly as before.
- [ ] The burn tag goes in the shared Turret `set_data`/`reload_data` path, so it also covers Crowbar turrets.
- [ ] ADR 0001's Consequences describes the burn-tag dependency, replacing the current mention of the `from` reference.
- [ ] In-game check: tier 2 Wrench flame turret alone; Turret item flame turrets plus a tier 2 Wrench; for 1 player and for 3–4 players.
