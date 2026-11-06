Status: ready-for-agent

# Accurate Source crediting, Duplicate Weapons, and glossary renames

## Problem Statement

As a DmgMeter player, I can't trust some of what the Meters show me:

- When I build turrets with a Wrench, plant landmines with a Screwdriver, or get turrets from trees with Pocket Factory, their damage shows up on a generic Turret or Landmines Source instead of the weapon or item that made them. If I also own the Turret item, all of that damage lands in one shared number, so I can't tell which part of my build is pulling its weight. Burn damage from flame turrets is lumped in the same way.
- The Materials Meter's "Other" Source uses the Harvesting icon, but it also contains per-step materials and materials from character abilities. I can't see how much my Harvesting actually paid out.
- With several copies of the same weapon, each copy takes its own row. That's useful for some builds, but on a six-SMG build it crowds out everything else. There's no option to combine them.
- The wording players see and the code use "list", "category", "element" and "row" inconsistently for what the glossary calls Meter and Source, which makes the mod harder to describe and to maintain.

## Solution

- Every Structure is credited to its **Spawner**. Wrench turrets count toward that Wrench, Screwdriver landmines toward that Screwdriver, Pocket Factory tree turrets toward Pocket Factory, and Bot-o-Mine landmines toward Bot-o-Mine. This includes burns the Structures apply. Each weapon instance is credited separately, so two Wrenches each show only their own turrets. Pet items still credit themselves.
- The Materials Meter splits the end-of-wave payout into its own **Harvesting** Source. It counts toward the wave that just ended and shows 0 if the payout is negative. **Other** keeps only what's left over.
- A new **Combine duplicate weapons** option, off by default, shows Duplicate Weapons as one Source with a "×N" count. Weapons count as duplicates when weapon, tier, cursed state and mechanized state all match. It applies to weapon Sources in all three Meters, and flipping it takes effect immediately in the live Meters and in Wave Snapshots on screen.
- The code, option IDs, option labels and README switch to the glossary terms: Meter, Meter Panel, Active Meter, Source, Total, Percentage Bar, Wave Snapshot.

## User Stories

### Spawner crediting

1. As a player with a Wrench, I want my turrets' damage credited to the Wrench, so that I can judge how strong the Wrench is.
2. As a player with both the Turret item and a Wrench, I want each credited only with its own turrets, so that I can compare them.
3. As a player with two Wrenches of the same tier and Combine duplicate weapons turned off, I want each Wrench credited only with the turrets it built, so that each row is accurate.
4. As a player with a Wrench of a different tier, I want its higher-tier turrets credited to that Wrench, so that every tier is credited correctly.
5. As a player with a Screwdriver, I want its landmines' damage credited to the Screwdriver, so that I can see what it contributes.
6. As a player with Pocket Factory, I want the turrets that spawn from trees credited to Pocket Factory, so that I can see whether the item is worth it.
7. As a player with Bot-o-Mine, I want the landmines it lays credited to Bot-o-Mine, so that the pet's real impact is visible.
8. As a player with a flame turret from a Wrench, I want the burn damage it applies credited to the Wrench, so that most of a tier 2 Wrench's damage doesn't go missing.
9. As a player with the Turret item's flame turrets, I want their burn damage credited to the Turret item.
10. As a player with pets like Doc Moth or Lootworm, I want their healing and materials to stay credited to the pet item, so that pets show up as they do today.
11. As a player who owns no Spawners, I want the Meters to behave exactly as before.
12. As a co-op player, I want each player's Structures credited to that player's Spawner, so that no damage crosses between players.
13. As a player, I want generic Turret or Landmines Sources to appear only for Structures that have no Spawner, so that nothing is counted twice.

### Materials: Harvesting and Other

14. As a player with Harvesting, I want the end-of-wave payout shown as its own Harvesting Source, so that I can see what my Harvesting stat earned.
15. As a player, I want the wave-end bonuses paid with Harvesting (Pacifist, Cryptid, elite kills, living enemies, charmed enemies) included in the Harvesting Source, because the game pays them together.
16. As a player, I want the Harvesting payout counted toward the wave that just ended and included in that wave's Wave Snapshot.
17. As a player with negative Harvesting, I want the Harvesting Total to stay at 0 and not cut into other Sources' Totals.
18. As a player, I want Other to contain only gains no other Source claims, such as per-step and character-ability materials, so that its meaning is honest.
19. As a player, I want Other to have its own icon, not the Harvesting icon, so that the two can't be confused.
20. As a player, I want Pickups, the Metal Detector bonus, and item-tracked materials counted exactly as before.

### Duplicate Weapons

21. As a player with many copies of one weapon, I want an option to combine Duplicate Weapons into one Source, so that the Meter has room for my other Sources.
22. As a player, I want that option off by default, so that the current behaviour doesn't change unless I opt in.
23. As a player, I want weapons combined only when weapon, tier, cursed state and mechanized state all match, so that different variants stay separate.
24. As a player, I want a combined Source to show its count as "×N", so that I don't mistake it for one very strong weapon.
25. As a player, I want a combined Source's Total to be the sum of its weapons' Totals, Spawner credit included.
26. As a player, I want the option to apply to weapon Sources in the Damage, Healing and Materials Meters, so that my weapons look the same in every Meter.
27. As a player, I want item, character and grouped Sources left alone by the option.
28. As a player, I want flipping the option during a wave to update the live Meters straight away.
29. As a player, I want flipping the option in the shop or level-up screen to update the Wave Snapshot on screen straight away.
30. As a co-op player, I want the option to combine only within each player's own Sources.

### Wording and options

31. As a player, I want the option labels to use the glossary terms, for example "Sources per Meter (1-2 players)".
32. As a player, I want the README to describe Meters, the Meter Panel, the Active Meter and Wave Snapshots using the same words as the options.
33. As a player upgrading the mod, I accept that saved options go back to their defaults once, because the option IDs change.
34. As a player resuming a run saved by an older version, I accept that its Wave Snapshot may be empty until the next wave ends, as long as nothing crashes.
35. As a player without Oudstand-ModOptions, I want every new behaviour to work with its defaults.

### Maintainer

36. As the maintainer, I want the code to use the glossary terms, so that it reads the same way the domain is discussed.
37. As the maintainer, I want the rename done as its own change that doesn't alter behaviour, so that the feature changes are easy to review.
38. As the maintainer, I want the logic that turns Source records into displayed rows tested headless, so that combining, sorting and Harvesting/Other math can be checked without starting the game.
39. As the maintainer, I want a playtest checklist for Spawner crediting, so that I can re-check it after every Brotato update, as ADR 0001 asks.
40. As the maintainer, I want the test runner and the tests left out of the Release Package.

## Implementation Decisions

- **The rename comes first.** It's one behaviour-neutral change: code identifiers, scene node names, script and scene file names, option IDs and option labels move to the glossary terms. All hard-coded resource paths and node lookups must be updated together, because no editor fixes references here. The README wording is updated to match. The save-state key for the Wave Snapshot is renamed too; resuming a run saved by an older version must not crash.
- **New Meter Model module.** A pure GDScript module with no references to `RunData`, other always-on game globals, nodes or textures:
  - **Input**: one Meter's Source records, plus display options (Combine duplicate weapons, entry limit, Percentage Bars on or off).
  - **Source record fields**: a stable Source key, a Source kind (weapon, item, character, grouped), the Total, and display fields kept as opaque data (icon reference, colour, tier, cursed, mechanized). Weapon records also carry the weapon ID and an instance identity.
  - **Output**: the ordered, visible rows. Each row has its Total, an optional "×N" count, and its Percentage Bar ratio.
  - **Rules it owns**: combining Duplicate Weapons (by weapon, tier, cursed, mechanized; weapons only; Totals summed), sorting by Total descending with a stable tie-break, hiding zero Totals, the entry limit, and Percentage Bar ratios against the highest visible Total.
  - **Who uses it**: both the live Meters and the Wave Snapshot screen.
- **Materials math moves into a pure helper next to the Meter Model.** Given total gains, Pickups, Harvesting gains and item/weapon-tracked gains, it returns the Harvesting and Other Totals. Harvesting is floored at 0, and Other is what's left, never negative.
- **Wave Snapshots are saved uncombined.** Each entry keeps the weapon ID, Source kind, tier, cursed and mechanized fields, so the Meter Model can combine or split them at display time when the option changes.
- **Harvesting capture.** The mod extends the base game's end-of-wave Harvesting step so it can tell, while that step runs, that any gain it makes belongs to Harvesting. Harvesting is only counted while the mod's materials tracking is active, which already covers the end-of-wave window. Losses during that step aren't counted.
- **Spawner crediting, per ADR 0001.** When a Structure spawns, its tracking key is swapped for one that identifies its Spawner, down to the individual weapon. This uses the same technique Oudstand-DamageMeter uses for Bot-o-Mine landmines, generalised to turrets and landmines.
  - It covers Wrench (all tiers), Screwdriver, Pocket Factory tree turrets, Bot-o-Mine landmines and the Turret item.
  - Burns applied by a Structure are credited to its Spawner through the burn's `from` reference, overriding the base game's blanket credit of every Engineering-scaled burn to the flame turret item.
  - The Damage Meter reads Spawner credit per weapon instance and per item, and adds it to the Spawner's own Total.
  - If the game turns out not to keep separate objects per weapon instance for Structure effects, per-instance crediting needs extra work. **Stop and ask the maintainer** instead of falling back to splitting by weapon type.
- **The hard-coded spawner table goes away.** The Damage Meter's current mapping (Wrench/Screwdriver/Bot-o-Mine → separate turret or landmine Sources) is removed. Structures are no longer separate Sources unless they have no Spawner.
- **New option**: "Combine duplicate weapons", a toggle, off by default. It's registered with ModOptions and stored with the other settings, and a change is pushed to all Meter Panels and open Wave Snapshot screens straight away.
- **AGENTS.md is kept accurate** if the extension layout changes.

## Testing Decisions

- **What a good test checks**: only the Meter Model's and materials helper's inputs and outputs (Source records in, displayed rows out). Never node trees, internal fields, or how the rows are drawn.
- **Automated (headless)**: a small test runner script plus test scripts in the dev-tools folder, which the release script already leaves out of the Release Package. They run with the Godot 3.6 editor binary using `--no-window -s` against the Brotato export project. The tests can't use the game's always-on globals, which is why the Meter Model must be pure. No GUT or other framework is added. The runner exits non-zero on failure, and the README's Development Notes document how to run it.
- **Tested modules**: the Meter Model and the materials helper. Cases:
  - combining by each match field, and a mismatch in any one field keeping weapons apart
  - the ×N count
  - item, character and grouped Sources never combining
  - sort order and tie-break
  - zero Totals hidden
  - the entry limit
  - Percentage Bar ratios
  - Harvesting floored at 0
  - Other never negative
  - an uncombined Wave Snapshot giving the same rows as live Meters for the same Sources
- **Manual playtest checklist** (in game, using the debug menu to give items), for 1 player and for 3–4 players:
  - Wrench alone (each tier)
  - Turret item plus a Wrench
  - two Wrenches with the option off and on
  - Screwdriver
  - Pocket Factory with trees
  - Bot-o-Mine
  - a tier 2 Wrench flame turret's burns
  - Doc Moth healing and Lootworm materials unchanged
  - positive and negative Harvesting
  - Harvesting showing up in the Wave Snapshot
  - flipping the option mid-wave and in the shop
  - running without ModOptions installed
  - resuming a run saved by the previous version
- **Prior art**: none. The repo has no tests yet; this spec sets up the first ones.

## Out of Scope

- Uploading to the Steam Workshop (stays manual).
- Crediting burns that don't come from a Structure differently from today.
- Spawner crediting for anything other than Structures; pet items already credit themselves.
- Changing the per-wave reset, the Meter Panel layout, Q/E switching, or the Percentage Bar look.
- Translations.
- Keeping old option values or old Wave Snapshot save data across the rename.

## Further Notes

- **Scope addition (2026-11-06, maintainer):** Spawner crediting also covers the newer structure Spawners. Crowbar's bleeding turrets go in ticket 05. Awl and Dart Trap item dart traps, and Carbon Bow landmines, go in ticket 06. Dart Trap item damage is dropped by the base game today because its tracking key is empty. Research notes are in the implementation session's `notes/unhandled-structures.md`.
- Terms follow the project glossary (`docs/GLOSSARY.md`); the Spawner approach follows ADR 0001 (`docs/adr/`).
- Oudstand-DamageMeter 1.2.0 shows the key-swap technique works for Bot-o-Mine landmines. It relabels Wrench, Screwdriver and Pocket Factory damage but doesn't separate them; that's the rejected option in ADR 0001.
- Changing option IDs resets players' settings once, so a version number signalling a breaking change and a CHANGELOG entry should go with this release.
