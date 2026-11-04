# 03: Combine duplicate weapons option

**What to build:** A new "Combine duplicate weapons" option, off by default. When it's on, Duplicate Weapons (same weapon, tier, cursed state, and mechanized state) appear as one Source with a "×N" count and their summed Total. This applies to every Meter and to Wave Snapshots, and flipping the option takes effect immediately. See the parent spec's user stories 21–30.

**Blocked by:** 02 (Meter Model and headless test runner).

**Status:** ready-for-agent

- [ ] The toggle is registered with ModOptions, off by default, and works with that default when ModOptions isn't installed.
- [ ] The Meter Model combines only weapon Sources, and only when weapon ID, tier, cursed, and mechanized all match; the combined Total is the sum, and the row shows "×N".
- [ ] Item, character, and grouped Sources are never combined; co-op players' Sources are never combined across players.
- [ ] Wave Snapshots are saved uncombined, with weapon ID, Source kind, tier, cursed, and mechanized fields.
- [ ] Flipping the toggle mid-wave immediately updates every Meter Panel; flipping it in the shop or level-up screen immediately updates the Wave Snapshot on screen.
- [ ] Headless tests cover: each match field (a mismatch in any one field keeps weapons separate), the ×N count, non-weapon Sources never combining, and an uncombined snapshot giving the same rows as the live Meters.
- [ ] README Options section documents the toggle.
- [ ] In-game check with several SMGs of mixed tiers, toggling on and off mid-wave and in the shop.
