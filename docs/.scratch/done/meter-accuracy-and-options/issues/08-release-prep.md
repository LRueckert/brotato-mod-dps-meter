# 08: Release prep

**What to build:** Gets the finished work ready for the Steam Workshop. The full playtest checklist passes, the version and CHANGELOG reflect the breaking option reset, the docs are accurate, and the Release Package is built.

**Blocked by:** 03 (Combine duplicate weapons option), 04 (Harvesting and Other Sources), 06 (Spawner crediting for landmines and Pocket Factory), 07 (Burn damage credited to Spawners).

**Status:** done

- [x] Every item on the parent spec's manual playtest checklist passes, for 1 player and for 3–4 players, including two combined Wrenches whose Total includes their turrets' Spawner credit.
- [x] The headless tests pass.
- [x] The manifest version is bumped to signal the breaking change (saved options reset once), and the CHANGELOG has an entry describing the user-facing changes.
- [x] README, AGENTS.md, GLOSSARY, and ADR 0001 match the shipped behaviour.
- [x] The release script builds the Release Package; its contents include no test files.
