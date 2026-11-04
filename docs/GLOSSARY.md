# DmgMeter

A Brotato mod that shows per-wave damage, healing, and material gains in per-player HUD lists.

## Language

### Tracking

**Meter**:
One of the three trackers: the Damage Meter (damage dealt, excluding overkill), the Healing Meter (HP actually restored), or the Materials Meter (materials gained, excluding spending).
_Avoid_: list, category, tracker

**Meter Panel**:
A player's HUD panel holding all three Meters, showing one at a time.
_Avoid_: lists, HUD list

**Active Meter**:
The Meter a Meter Panel currently shows; each player switches it independently.
_Avoid_: selected list, current list

**Source**:
Anything a Meter credits value to: a weapon, item, or character, or a grouped bucket in the Materials Meter (Pickups, Harvesting, Other).
_Avoid_: element, row, contributor

**Pickups**:
The Materials Meter Source for materials collected from the ground.
_Avoid_: drops, collected

**Percentage Bar**:
A bar showing a Total as a share of the highest Total in the same Meter.
_Avoid_: value bar, progress bar

**Harvesting**:
The Materials Meter Source for the end-of-wave harvesting payout, including its wave-end bonuses. It counts toward the wave that just ended, and a negative payout counts as zero.
_Avoid_: Other

**Other**:
The Materials Meter Source for gains that no other Source claims, such as per-step and character-ability materials.
_Avoid_: misc, harvesting

**Spawner**:
The weapon or item that created a Structure or Pet. Everything a Structure or Pet does, including burns it applies, is credited to its Spawner; a pet item is its own Spawner.
_Avoid_: owner, parent, creator

**Duplicate Weapons**:
Weapons that match in weapon, tier, cursed state, and mechanized state. Players can choose to show them as one combined Source.
_Avoid_: copies, stacks

**Total**:
The value one Source has accumulated in one Meter for one player during the current wave. It resets when a wave starts.
_Avoid_: value, amount, sum

**Wave Snapshot**:
A frozen copy of every Meter's Totals for each player, taken when a wave ends and shown in the level-up and shop screens. It is saved with the run.
_Avoid_: snapshot category, recap, summary

### Releasing

**Release Package**:
The zip uploaded to the Steam Workshop. It holds `mods-unpacked/lrueckert-DmgMeter/` with only the files the game needs at runtime.
_Avoid_: build, export, release zip
