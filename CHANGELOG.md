# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Removed

### Fixed

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

[unreleased]: https://github.com/LRueckert/brotato-mod-dps-meter/compare/v3.0.0...HEAD
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