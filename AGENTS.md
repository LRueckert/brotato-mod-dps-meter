# Agents & Skills

This repository is configured for use with Copilot engineering skills.

## Project

DmgMeter is a Brotato mod (Godot 3.x, GDScript, Godot Mod Loader 6.2). Each player's Meter Panel shows per-wave damage, healing, and materials Meters during waves, and Wave Snapshots in the level-up and shop screens. See `README.md` for behaviour and `docs/GLOSSARY.md` for terms.

- **Base game source**: the decompiled game is at `../../` (`res://`). Read the original script there before changing anything in `extensions/`.
- **Hooking**: changes to the base game go through `ModLoaderMod.install_script_extension` in `mod_main.gd`. Files in `extensions/` sit in the folder of the base script they extend, but their names differ, so check each file's `extends` line for the actual target.
- **Co-op**: everything is tracked per player, for 1–4 players. Test every change against both single-player and 3–4-player layouts.
- **Options**: `Oudstand-ModOptions` is optional. Options are defined in `ui/hud/meter_config.gd`, and the defaults must work when ModOptions isn't installed.

## Release

Build the Release Package (`lrueckert-DmgMeter.zip`) with `powershell -ExecutionPolicy Bypass -File .\tools\build-release.ps1`.

## Agent skills

### Issue tracker

Issues live as markdown files under `docs/.scratch/<feature>/` in this repo. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context layout: `GLOSSARY.md` and `adr/` live in `docs/`. See `docs/agents/domain.md`.
