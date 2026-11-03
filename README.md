# DmgMeter (3358859974)
Per-wave damage, healing, and material meters for Brotato.

- **Damage:** weapons, items, characters, and spawned sources.
	Overkill Damage does not count.
- **Healing:** regeneration, lifesteal, consumables, and direct healing effects.
	Only actual HP restored counts.
- **Materials:** ground pickups, pickup bonuses, and weapon/item-generated income.
	Other income is grouped separately; spending and discounts are excluded.

<img src="modicon.png" alt="Mod icon"/>

Use **Q/E** or a controller's **shoulder buttons/triggers** to cycle lists independently per player.

Totals are tracked per player, reset each wave, and sorted highest first.
Zero totals are hidden; each list shows up to 25 sources by default with one or two players, or six sources with three or four players.
Material pickups follow the game's co-op sharing.
At the end of each wave, damage, healing, and materials snapshots are available as categories in the level-up and shop screens.

## Options

With **Oudstand-ModOptions** installed, open **Options > Mods > DmgMeter** to change options, otherwise default values will work fine.
Changes are saved automatically and apply immediately to all lists and players.

- **Wave snapshots:** Show wave snapshots between rounds in the stats panel, default **enabled**
- **Percentage Bars:** Show each entry's value relative to the highest value in its category, default **disabled**.
- **Percentage bar width:** Set the HUD bar width from **50-280 px** (capped on HP bar size), default **150 px**.
- **HUD entries per list (1-2 players):** **1-25**, default **25**.
- **HUD entries per list (3-4 players):** **1-25**, default **6**.

## Development Notes

Follow steam guide: https://steamcommunity.com/sharedfiles/filedetails/?id=2931079751