# 01: Rename everything to glossary terms

**What to build:** A rename that doesn't change behaviour. The mod plays exactly as before, but the code and the wording players see use the glossary terms (Meter, Meter Panel, Active Meter, Source, Total, Percentage Bar, Wave Snapshot) instead of list, category, element, row, and similar. See the parent spec's "Implementation Decisions" (rename) and user stories 31–37.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [x] Class names, variables, functions, scene node names, and mod-owned script and scene file names use glossary terms. Files in the extensions folder keep their folder placement.
- [x] Every hard-coded resource path, `preload`/`load`, `extends "res://…"`, and node lookup (including the injected per-player HUD node names) is updated; a text search for every old name finds nothing.
- [ ] Option IDs and labels use glossary terms (for example "Sources per Meter (1-2 players)"); ModOptions shows the renamed options with the same defaults.
- [ ] The save-state key for the Wave Snapshot is renamed; resuming a run saved by the previous version doesn't crash (the snapshot may be empty).
- [x] README wording uses glossary terms.
- [ ] In-game smoke test for 1 player and for 3–4 players: Meters update during a wave, Q/E switches the Active Meter, and the Wave Snapshot appears in the level-up and shop screens.
- [x] The release script still builds a Release Package with all renamed files.
