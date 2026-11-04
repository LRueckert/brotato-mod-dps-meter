# 06: Spawner crediting for landmines and Pocket Factory

**What to build:** Extends Spawner crediting to the remaining Structures. Screwdriver landmines count toward that Screwdriver, landmines laid by the Bot-o-Mine pet count toward Bot-o-Mine, and turrets that trees spawn because of Pocket Factory count toward Pocket Factory. See the parent spec's user stories 5–7.

**Blocked by:** 05 (Spawner crediting for turrets).

**Status:** ready-for-agent

- [ ] Landmines spawned by a Screwdriver credit that Screwdriver instance.
- [ ] Landmines laid by Bot-o-Mine credit the Bot-o-Mine item.
- [ ] Turrets spawned by trees due to Pocket Factory credit Pocket Factory.
- [ ] The remaining hard-coded spawner mappings (Screwdriver, Bot-o-Mine) are removed; generic Landmines or Turret Sources appear only for Structures with no Spawner.
- [ ] Doc Moth healing and Lootworm materials are still credited to their pet items.
- [ ] Each override keeps the base signature and calls the base implementation; ADR 0001's Consequences lists any new base-game dependency.
- [ ] In-game check: Screwdriver; Bot-o-Mine; Pocket Factory with trees; Screwdriver plus Bot-o-Mine together; for 1 player and for 3–4 players.
