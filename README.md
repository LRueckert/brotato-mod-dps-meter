# DmgMeter (3358859974)
Per-wave Damage, Healing, and Materials Meters for Brotato.

- **Damage:** weapons, items, characters, and spawned Sources.
	Overkill Damage does not count.
	Turrets count toward the weapon or item that spawned them: each Wrench or Crowbar shows its own turrets' damage, and the Turret and Blood Turret items show only theirs. Burns from a Wrench's flame turrets count toward that Wrench, not the Flame Turret item.
	The same goes for landmines and traps: each Screwdriver, Carbon Bow (Engineering arrows), or Awl shows its own Structures' damage, Bot-o-Mine shows the mines it lays (damage only, not how many it dropped), Pocket Factory shows its tree turrets, and the Landmines and Dart Trap items show only theirs.
- **Healing:** regeneration, lifesteal, consumables, and direct healing effects.
	Only actual HP restored counts.
- **Materials:** ground pickups, pickup bonuses, weapon/item-generated income, and the end-of-wave Harvesting payout.
	Harvesting includes its wave-end bonuses, counts toward the wave that just ended, and shows 0 when the payout is negative.
	Income no other Source claims (such as per-step or character-ability materials) is grouped into the Other Source; spending and discounts are excluded.

<img src="modicon.png" alt="Mod icon"/>

Use **Q/E** or a controller's **shoulder buttons/triggers** to switch the Active Meter in each player's Meter Panel independently.

Totals are tracked per player, reset each wave, and sorted highest first.
Zero Totals are hidden; each Meter shows up to 25 Sources by default with one or two players, or six Sources with three or four players.
Material pickups follow the game's co-op sharing.
At the end of each wave, a Wave Snapshot of every Meter is available in the level-up and shop screens.

## Options

With **Oudstand-ModOptions** installed, open **Options > Mods > DmgMeter** to change options, otherwise default values will work fine.
Changes are saved automatically and apply immediately to all Meter Panels and players.
Updating from 3.x resets saved options to their defaults once.

- **Wave Snapshots:** Show Wave Snapshots between rounds in the stats panel, default **enabled**
- **Percentage Bars:** Show each Source's Total relative to the highest Total in its Meter, default **disabled**.
- **Percentage Bar width during wave:** Set the HUD Percentage Bar width from **50-280 px** (capped on HP bar size), default **150 px**.
- **Sources per Meter (1-2 players):** **1-25**, default **25**.
- **Sources per Meter (3-4 players):** **1-25**, default **6**.
- **Combine duplicate weapons:** Show copies of the same weapon with the same tier, cursed state, and mechanized state as one Source with a "×N" count and their summed Total. Default **disabled**.

## Development Notes

Build the Release Package from the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build-release.ps1
```

This creates `lrueckert-DmgMeter.zip` containing `mods-unpacked/lrueckert-DmgMeter/` with only the `.gd`, `.tscn`, `.tres`, `manifest.json` and `README.md` files.

It then opens Brotato's Steam Workshop folder (`C:\Program Files (x86)\Steam\steamapps\workshop\content\1942280`); pass `-WorkshopPath <folder>` if Steam is installed elsewhere.

Follow steam guide: https://steamcommunity.com/sharedfiles/filedetails/?id=2931079751

### Playtest checklist

Spawner crediting depends on base-game internals (see ADR 0001). After every Brotato update, re-run the in-game [playtest checklist](docs/playtest-checklist.md) for 1 player and for 3–4 players.

### Headless tests

The Meter Model (`ui/hud/meter_model.gd`), the materials helper (`ui/hud/materials_totals.gd`), the tracked-value helper (`ui/hud/tracked_values.gd`), the Spawner crediting helper (`ui/hud/spawner_credit.gd`), and the burn crediting helper (`ui/hud/burn_credit.gd`) have headless tests in `tools/tests/`. Run them from the repo root (the main checkout or any git worktree) with the Godot 3.6 editor binary against the Brotato export project:

```powershell
& "C:\Godot\win64-g36-s161-gs328\godotsteam.36.editor.windows.64.exe" --path C:\Godot\Brotato\brotatoexport --no-window --quit -s "$PWD\tools\tests\run_tests.gd"; "exit code: $LASTEXITCODE"
```

Adjust the two paths to your Godot binary and Brotato export project. The runner runs every `test_*.gd` next to it, prints a `PASS`/`FAIL` line per test and a summary, and exits non-zero if any test fails. The game's own startup log and errors are printed around the results and can be ignored. Tests load the scripts they test by paths relative to their own file, so they test the checkout they live in. `test_hooks_load.gd` checks that every extension `mod_main.gd` installs exists, extends an existing base script, and compiles against the base game's scripts. `tools/` is left out of the Release Package.