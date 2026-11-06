# Playtest checklist

Spawner crediting ([ADR 0001](adr/0001-credit-spawners-via-spawn-time-tagging.md)) depends on base-game internals that the headless tests can't reach. Re-run this checklist in game after every Brotato update, and after changing anything in `extensions/`.

Run each check for **1 player** and for **3–4 players**. Give items and weapons through the debug menu. Each check passes when the Damage Meter shows what it describes, the matching Wave Snapshot shows the same rows after the wave, and no errors appear in the log.

## Spawner crediting

- [ ] **Wrench alone, each tier (1–4):** the Wrench's row includes its turrets' damage, and no separate Turret Source appears.
- [ ] **Turret item plus a Wrench:** the Turret item's row shows only its own turrets, and the Wrench's row shows only its own.
- [ ] **Two Wrenches of the same tier, Combine duplicate weapons off:** each Wrench row shows only the turrets it built.
- [ ] **Two Wrenches of the same tier, Combine duplicate weapons on:** one "×2" row whose Total is the sum of both.
- [ ] **Crowbar:** the Crowbar's row includes its bleeding turrets' damage. With the Blood Turret item as well, each shows only its own turrets.
- [ ] **Screwdriver:** the Screwdriver's row includes its landmines' damage, and no separate Landmines Source appears.
- [ ] **Carbon Bow (with Engineering, so it drops landmines):** the Carbon Bow's row includes its landmines' damage. The Landmines item, if owned, shows only its own mines.
- [ ] **Awl:** the Awl's row includes its dart traps' damage. With the Dart Trap item as well, each shows only its own traps.
- [ ] **Dart Trap item:** its row shows its traps' damage (the base game doesn't track it).
- [ ] **Pocket Factory with trees:** Pocket Factory shows its tree turrets as its own Source.
- [ ] **Bot-o-Mine:** its row shows the mines it lays. Its Total is damage only: it doesn't grow by one for each landmine dropped (compare it with the item tooltip's damage line).
- [ ] **Tier 2 Wrench flame turret:** its burns count toward that Wrench, not the Flame Turret item. With the Flame Turret item as well, the item's row shows only its own turrets' burns.
- [ ] **Co-op burns (3–4 players):** player A owns a tier 2 Wrench, player B a burning weapon. When B's weapon re-burns an enemy A's flame turret set alight, those ticks don't show up on A's Wrench row, and the Totals of A's Wrench and B's weapon stay plausible.
- [ ] **Doc Moth healing and Lootworm materials:** still credited to the pet item, as before.

## Materials and options

- [ ] **Positive Harvesting:** the end-of-wave payout shows up as the Harvesting Source.
- [ ] **Negative Harvesting:** Harvesting shows 0 and Other isn't reduced.
- [ ] **Harvesting in the Wave Snapshot:** the payout is included in the snapshot of the wave that just ended.
- [ ] **Flip Combine duplicate weapons mid-wave:** the live Meters update straight away.
- [ ] **Flip Combine duplicate weapons in the shop or level-up screen:** the Wave Snapshot on screen updates straight away.
- [ ] **Without Oudstand-ModOptions installed:** every Meter works with its defaults.
- [ ] **Resume a run saved by the previous version:** nothing crashes. The Wave Snapshot may be empty until the next wave ends.
