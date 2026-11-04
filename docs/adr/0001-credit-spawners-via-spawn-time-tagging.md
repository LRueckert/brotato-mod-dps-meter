# Credit Spawners by re-keying Structures at spawn time

In Brotato, Structures (turrets, landmines) record their damage under their own item key, such as `item_turret` or `item_landmines`. So the Turret item, a Wrench, and Pocket Factory tree turrets all add to one number. We want each Spawner credited with exactly its own Structures, even when two Spawners create the same Structure type and even per weapon instance. To do that, we extend the base game's Structure scripts so each spawned Structure gets a tracking key that identifies its Spawner.

## Considered Options

- **Relabel shared totals** (what Oudstand-DamageMeter 1.2.0 does): show the `item_turret*` or `item_landmines` total under the Spawner's icon. It's cheap and touches no Structure code, but it is wrong whenever two Spawners share a Structure type, for example the Turret item plus a Wrench. Rejected.
- **Re-key at spawn time** (chosen): extends the same technique Oudstand uses for Bot-o-Mine landmines to all Structures.

## Consequences

The mod now depends on internals and method signatures of `turret.gd`, `landmine.gd`, and the Structure spawn path. Burn damage from Structures goes through the `from` reference on the burn in `unit.gd`, because the base game credits every Engineering-scaled burn to `item_turret_flame`. Game updates that change any of these can silently break attribution, so check these first after every Brotato update.
