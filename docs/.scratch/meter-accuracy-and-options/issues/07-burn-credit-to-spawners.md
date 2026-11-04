# 07: Burn damage credited to Spawners

**What to build:** Burns applied by a Structure, such as a flame turret, count toward that Structure's Spawner. The base game credits every Engineering-scaled burn to the flame turret item. Burns from anything that isn't a Structure stay as they are today. See the parent spec's user stories 8–9.

**Blocked by:** 05 (Spawner crediting for turrets).

**Status:** ready-for-agent

- [ ] Burn damage whose `from` is a Structure with a Spawner is credited to that Spawner (per Wrench instance, or the Turret item).
- [ ] The base game's blanket flame-turret credit for that burn is no longer counted, so nothing is counted twice.
- [ ] Burns from non-Structures are credited exactly as before.
- [ ] If the burn's `from` reference turns out to be unreliable (for example freed before the burn ticks), **stop and ask the maintainer** with the evidence.
- [ ] ADR 0001's Consequences lists the burn dependency (already noted; update if the hook point differs).
- [ ] In-game check: tier 2 Wrench flame turret alone; Turret item flame turrets plus a tier 2 Wrench; for 1 player and for 3–4 players.
