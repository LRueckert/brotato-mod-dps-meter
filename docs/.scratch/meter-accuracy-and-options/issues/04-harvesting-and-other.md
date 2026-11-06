# 04: Harvesting and Other Sources

**What to build:** The Materials Meter shows a Harvesting Source for the end-of-wave harvesting payout and its wave-end bonuses. It counts toward the wave that just ended, shows in that wave's Wave Snapshot, and shows 0 when the payout is negative. Other keeps only gains that no other Source claims, and gets its own icon. See the parent spec's user stories 14–20.

**Blocked by:** 02 (Meter Model and headless test runner).

**Status:** needs-playtest

- [x] The mod extends the base game's end-of-wave harvesting step so gold added during that step is credited to Harvesting; losses during it are ignored.
- [x] A pure materials helper takes total gains, Pickups, Harvesting gains, and tracked item/weapon gains, and returns the Harvesting Total (floored at 0) and the Other Total (never negative).
- [x] The Harvesting Source uses the Harvesting stat icon; Other uses a different icon.
- [ ] Harvesting is included in the Wave Snapshot of the wave that just ended.
- [ ] Pickups, Metal Detector bonus, and item/weapon-tracked materials are unchanged.
- [x] Headless tests cover the helper: positive Harvesting, negative Harvesting floored at 0, Other never negative, and no Harvesting.
- [x] README Materials description mentions Harvesting and Other.
- [ ] In-game check: a positive-Harvesting run and a negative-Harvesting run, for 1 player and for 3–4 players.
