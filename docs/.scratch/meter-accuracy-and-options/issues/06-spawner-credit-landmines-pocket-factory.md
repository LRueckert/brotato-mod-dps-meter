# 06: Spawner crediting for landmines and Pocket Factory

**What to build:** Extends Spawner crediting to the remaining Structures. Screwdriver landmines count toward that Screwdriver, landmines laid by the Bot-o-Mine pet count toward Bot-o-Mine, and turrets that trees spawn because of Pocket Factory count toward Pocket Factory. See the parent spec's user stories 5–7.

**Blocked by:** 05 (Spawner crediting for turrets).

**Status:** ready-for-agent

- [ ] Landmines spawned by a Screwdriver credit that Screwdriver instance.
- [ ] Landmines laid by Bot-o-Mine credit the Bot-o-Mine item.
- [ ] Turrets spawned by trees due to Pocket Factory credit Pocket Factory.
- [ ] Dart traps spawned by an Awl credit that Awl instance (needs a `DartTrap.set_data` post-hook).
- [ ] Dart traps from the Dart Trap item credit the Dart Trap item. The base game leaves their tracking key empty and drops the damage, so use the fallback key `item_dart_trap`.
- [ ] Landmines dropped by Carbon Bow's Engineering arrows credit that Carbon Bow instance, not `item_landmines`. Use the same nested-`structure_effect` duplication as Crowbar in ticket 05.
- [ ] The Landmines item, Screwdriver and Bot-o-Mine Sources no longer include Carbon Bow mines.
- [ ] The remaining hard-coded spawner mappings (Screwdriver, Bot-o-Mine) are removed; generic Landmines or Turret Sources appear only for Structures with no Spawner.
- [ ] Doc Moth healing and Lootworm materials are still credited to their pet items.
- [ ] Each override keeps the base signature and calls the base implementation; ADR 0001's Consequences lists any new base-game dependency.
- [ ] In-game check: Screwdriver; Bot-o-Mine; Pocket Factory with trees; Screwdriver plus Bot-o-Mine together; Awl alone; Awl plus Dart Trap item; Carbon Bow (Engineering arrows) alone and with the Landmines item; for 1 player and for 3–4 players.
