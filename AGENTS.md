# Agents & Skills

This repository is configured for use with Copilot engineering skills.

## Project

DmgMeter is a Brotato mod (Godot 3.x, GDScript, Godot Mod Loader 6.2). Each player's Meter Panel shows per-wave damage, healing, and materials Meters during waves, and Wave Snapshots in the level-up and shop screens. See `README.md` for behaviour and `docs/GLOSSARY.md` for terms.

- **Base game source**: the decompiled game is at `../../` (`res://`). Read the original script there before changing anything in `extensions/`.
- **Hooking**: changes to the base game go through `ModLoaderMod.install_script_extension` in `mod_main.gd`. Files in `extensions/` sit in the folder of the base script they extend, but their names differ, so check each file's `extends` line for the actual target.
- **Co-op**: everything is tracked per player, for 1–4 players. Test every change against both single-player and 3–4-player layouts.
- **Options**: `Oudstand-ModOptions` is optional. Options are defined in `ui/hud/meter_config.gd`, and the defaults must work when ModOptions isn't installed.
- **Meter Model**: `ui/hud/meter_model.gd` turns Source records into the rows the live Meters and Wave Snapshots show (sorting, hiding zero Totals, entry limit, Percentage Bar ratios). Keep it pure (no game globals, nodes, or textures) so its headless tests in `tools/tests/` can run; see README "Headless tests" for the command.
- **Spawner crediting**: `ui/hud/spawner_credit.gd` is the pure helper for ADR 0001 (Spawner keys, per-weapon effect copies and tags, the per-wave credit ledger), tested headless like the Meter Model. Its game hooks are `extensions/singletons/spawner_credit.gd` (extends `run_data.gd`), `extensions/entities/structures/turret/turret_spawner_credit.gd` (extends `turret.gd`), `extensions/entities/structures/landmine/landmine_spawner_credit.gd` (extends `landmine.gd`), `extensions/entities/structures/dart_trap/dart_trap_spawner_credit.gd` (extends `dart_trap.gd`), `extensions/entities/units/pet/bot_o_mine/bot_o_mine_spawner_credit.gd` (extends `bot_o_mine.gd`) and `extensions/main_spawner_credit.gd` (extends `main.gd`, Pocket Factory). New Structure hooks should swap their tracking key with `structure_tracking_hash(data, base_key_hash, RunData)`.
- **Burn crediting**: `ui/hud/burn_credit.gd` is the pure helper for crediting Structure burns to Spawners (ADR 0001), tested headless. Its game hooks are `extensions/singletons/burn_credit.gd` (extends `run_data.gd`), `extensions/entities/structures/turret/turret_burn_credit.gd` (tags `stats.burning_data`, both `tracking_key` and `tracking_key_hash`), and `extensions/entities/units/unit/unit_burn_credit.gd` (refunds the blanket `item_turret_flame` credit per tick; a burn another source took over ticks under its base-game key). Never set `burning_data.from`.

## Release

Build the Release Package (`lrueckert-DmgMeter.zip`) with `powershell -ExecutionPolicy Bypass -File .\tools\build-release.ps1`.

## Agent skills

### Issue tracker

Issues live as markdown files under `docs/.scratch/<feature>/` in this repo. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context layout: `GLOSSARY.md` and `adr/` live in `docs/`. See `docs/agents/domain.md`.
