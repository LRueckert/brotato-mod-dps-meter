# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [v4.0.0] - 2026-11-06

Saved options reset to their defaults once, because the option IDs changed. A Wave Snapshot saved by an older version is dropped.

### Added

- Combine duplicate weapons option, off by default. Copies of the same weapon with the same tier, cursed state, and mechanized state show as one Source with a "×N" count and their summed Total, in every Meter and in Wave Snapshots. Items, characters, and grouped Sources are never combined, and each player's weapons are combined separately.
- Harvesting Source in the Materials Meter for the end-of-wave Harvesting payout, including its wave-end bonuses. It counts toward the wave that just ended and shows 0 when the payout is negative.

### Changed

- Turret damage counts toward the weapon or item that spawned it. Each Wrench and Crowbar shows its own turrets' damage in its row, and the Turret and Blood Turret items show only their own turrets; Wrenches no longer add a separate Turret Source. Burns started by a Wrench's flame turrets count toward that Wrench instead of the Flame Turret item, until another source (such as another player's weapon) takes the burn over.
- Landmine and trap damage counts toward its Spawner too. Each Screwdriver, Carbon Bow (Engineering arrows) and Awl shows its own Structures' damage, Bot-o-Mine shows the mines it lays, and Pocket Factory shows its tree turrets as its own Source. Screwdriver and Bot-o-Mine no longer add a separate Landmines Source, and the Landmines item no longer includes their mines or Carbon Bow's.
- The Materials Meter's Other Source holds only income no other Source claims, such as per-step and character-ability materials, and has its own icon instead of the Harvesting icon.
- Option labels and the README use consistent terms: Meter, Meter Panel, Active Meter, Source, Total, Percentage Bar, and Wave Snapshot.
- Item Sources always show a "×N" count when the player owns more than one copy of the item, in the Meters and in Wave Snapshots.

### Fixed

- Dart traps from the Dart Trap item now count toward it; the base game never tracked their damage.
- Bot-o-Mine's damage Total no longer adds the number of landmines it dropped, and Hungry Hungry Dinosaur's no longer adds the fruits it ate.

## [v3.1.1] - 2026-11-03

### Fixed

- Icon styling in Wave Snapshot panels

## [v3.1.0] - 2026-11-03

### Added

- Wave-end damage, healing, and materials snapshots in the level-up and shop screens.
- Configurable percentage bars that compare each entry with the highest value in its category.
- Oudstand-ModOptions settings for snapshots, percentage bars, bar width, and list entry limits.

### Fixed

- Breaking ModOptions

## [v3.0.0] - 2026-10-31

### Added

- Healing meter covering regeneration, lifesteal, consumables, and direct healing effects.
- Materials meter covering pickups, pickup bonuses, and weapon/item-generated income.
- Independent per-player list switching using Q/E, controller shoulder buttons, or triggers.
- Category icons with highlighting for the active list.

### Changed

- Hide sources with zero totals and preserve their recorded contributions throughout the wave.
- Use shared container and row implementations for all three meter types.

### Fixed

- Prevent duplicate item and spawned-source rows without merging individual weapons.

## [v2.2.0] - 2026-02-16

### Added

- Pet support

### Fixed

- Update 1.1.14.0 breaking the mod
- Item colors

## [v2.1.3] - 2025-06-19

### Fixed

- Update 1.1.11.0 breaking the mod

## [v2.1.2] - 2025-02-13

### Fixed

- Brotato update breaking Character stat reset
- Actually using mod version as well

## [v2.1.1] - 2024-11-10

### Fixed

- Actually show as many items as will fit for up to two players

## [v2.1.0] - 2024-11-09

### Added

- Sorting for damage meter
- Support for items and characters (if more than 2 players only top 6 elements shown)
- Support for Wrenches and Screwdrivers to show their spawned structures

## [v2.0.0] - 2024-11-08

### Added

- Support for local co-op

### Changed

- Damage labels with thousand separators

## [v1.0.1] - 2024-11-04

### Fixed

- Method name collision with MoreUI mod

## [v1.0.0] - 2024-11-03

### Added

- Use orignal item panel to get background color and curse style

## [v0.1.0] - 2024-11-02

### Added

- Icons and raw damage numbers

[unreleased]: https://github.com/LRueckert/brotato-mod-dps-meter/compare/v4.0.0...HEAD
[v4.0.0]: https://github.com/LRueckert/brotato-mod-dps-meter/compare/v3.1.1...v4.0.0
[v3.1.1]: https://github.com/LRueckert/brotato-mod-dps-meter/compare/v3.1.0...v3.1.1
[v3.1.0]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v3.1.0
[v3.0.0]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v3.0.0
[v2.2.0]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v2.2.0
[v2.1.3]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v2.1.3
[v2.1.2]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v2.1.2
[v2.1.1]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v2.1.1
[v2.1.0]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v2.1.0
[v2.0.0]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v2.0.0
[v1.0.1]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v1.0.1
[v1.0.0]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v1.0.0
[v0.1.0]: https://github.com/LRueckert/brotato-mod-dps-meter/releases/tag/v0.1.0