# 02: Meter Model and headless test runner

**What to build:** Preparation work that doesn't change behaviour. A new pure Meter Model turns one Meter's Source records plus display options into the ordered rows that are shown. The live Meters and the Wave Snapshot screen both show their rows through it, and players see no difference. One command runs the headless tests for it. See the parent spec's "Meter Model" and "Testing Decisions".

**Blocked by:** 01 (Rename everything to glossary terms).

**Status:** ready-for-agent

- [ ] The Meter Model has no references to `RunData`, other always-on game globals, nodes, or textures. Display data such as the icon is carried through as opaque values.
- [ ] Source record fields: Source key, Source kind (weapon, item, character, grouped), Total, tier, cursed, mechanized, and opaque display data; weapons also carry weapon ID and instance identity.
- [ ] It owns sorting (Total descending, stable tie-break), hiding zero Totals, the entry limit, and Percentage Bar ratios against the highest visible Total.
- [ ] The live Meters and the Wave Snapshot screen display through the Meter Model; the duplicated sort, visibility, and bar logic is removed from both.
- [ ] A headless test runner lives in the dev-tools folder (left out of the Release Package), runs with the Godot 3.6 editor binary using `--no-window -s`, prints each result, and exits non-zero on failure. No GUT or other framework is added.
- [ ] Tests cover sort order and tie-break, zero Totals hidden, entry limit, and Percentage Bar ratios (including all-zero).
- [ ] The README's Development Notes document the test command.
- [ ] In-game check: Meters and Wave Snapshots look and behave as before for 1 player and for 3–4 players.
