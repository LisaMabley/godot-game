# godot-game

A Vampire Survivors–style arena survival game built in **Godot 4.7** (Forward+), written in **GDScript**.
The player auto-attacks with abilities, collects experience gems from killed enemies, and picks upgrades on level-up until the arena timer runs out (win) or they die (lose).

## Working in this repo

- Godot 4.7.1 is on PATH as `godot` (a `godot.cmd` shim in `~/.local/bin` pointing at the console build). Use it from PowerShell/cmd (`cmd /c "godot ..."` if needed):
  - `godot --headless --path . --import` loads every scene/script and reports parse errors and broken references. Run it after renames, moves, or `.tscn` edits.
  - Gameplay still needs a human. Ask the user to playtest feel and balance changes.
- Prefer editing `.gd` scripts. `.tscn` / `.tres` files are editor-managed: small, targeted text edits (an exported property, a node path) are fine, but don't hand-author new scenes. Describe the node setup for the user to build in the editor instead. Never invent `uid://` values.
- `README.md` is the human-facing overview. When a change adds or alters a feature, control, or top-level folder, update its Features/Controls/structure sections too.
- Commit messages use a conventional prefix: `feat:`, `fix:`, `bug:`. Lowercase, short.
- Display: 640x360 viewport, stretched to 1920x1080, pixel art (nearest texture filter).

## Layout

- `scenes/main/`: root `Main` scene. Holds the managers, UI, `TileMapLayer`, and two layer nodes found by group: `Entities` (`entities_layer`) and `Foreground` (`foreground_layer`).
- `scenes/manager/`: game-wide logic nodes (arena time/difficulty, enemy spawning, experience/leveling, upgrades).
- `scenes/component/`: reusable components composed onto game objects (see below).
- `scenes/game_object/`: player, enemies, drops, camera. Each in its own folder with `.gd` + `.tscn`.
- `scenes/ability/`: each ability has an `*_ability_controller` (timer-driven, spawns instances, listens for upgrades) and an `*_ability` (the spawned attack with a `HitboxComponent`).
- `scenes/ui/`: HUD, upgrade screen/cards, end screen, floating damage text.
- `scenes/autoload/game_events.gd`: `GameEvents` autoload, the global signal bus.
- `resources/`: custom `Resource` classes and their `.tres` data (upgrades, loot tables).
- `scripts/weighted_table.gd`: `WeightedTable`, used for enemy spawns, upgrade pool, and loot.
- `assets/potential_sprites/`: unused assets parked for later.
- `theme/theme.tres`: project-wide UI theme (custom font, panel styles).

## Architecture & patterns

- **Composition via components.** Entities are assembled from component nodes wired with `@export` references in the editor:
  - `HealthComponent`: `died`, `health_changed` signals; frees its `owner` on death.
  - `HurtboxComponent` (Area2D): *receives* damage from overlapping `HitboxComponent`s and spawns floating text.
  - `HitboxComponent` (Area2D): *deals* damage; `damage` is set by the ability controller at spawn.
  - Naming follows the standard convention: **hitbox = deals hits; hurtbox = can be hurt.** (These were swapped once on 2026-10-26; older commits use the reverse.)
  - `VelocityComponent`, `DeathComponent`, `HitflashComponent`, `LootDropComponent`, `PickupAnimationComponent`.
- **Global signal bus.** Cross-system events go through `GameEvents` (`emit_*` helper methods wrap each signal). Local wiring uses direct signal connections in `_ready()`.
- **Groups for lookups.** `player`, `enemy`, `entities_layer`, `foreground_layer`, `upgrade_card`, accessed via `get_tree().get_first_node_in_group(...)`. Always null-check the player.
- **Upgrades.** `AbilityUpgrade` resource (`id`, `max_quantity`, `name`, `description`); `Ability` extends it with `ability_controller_scene`. `UpgradeManager` keeps `current_upgrades[id] = {resource, quantity}` and a `WeightedTable` pool. When an upgrade hits `max_quantity`, it's removed from the pool. Unlocking an ability adds its follow-up upgrades in `update_upgrade_pool`. Ability controllers react to `GameEvents.ability_upgrade_added` by matching on `upgrade.id`.
- **Difficulty.** `ArenaTimeManager` emits `arena_difficulty_increased` every 5s; `EnemyManager` shortens spawn time and adds/reweights enemies at difficulty thresholds.
- **Physics layers:** 1 Terrain, 2 Player, 3 Enemy, 4 EnemyCollision, 5 PlayerPickup.

## Adding things (checklists)

- **New upgrade:** create a `.tres` in `resources/upgrades/` (unique `id`), preload it in `upgrade_manager.gd`, add it to the pool (in `_ready`, or in `update_upgrade_pool` if it depends on an ability), and handle its `id` in the relevant controller's `_on_ability_upgrade_added`. The `description` text is hand-written, so keep any numbers in it (e.g. "+15%") in sync with the controller's math.
- **New ability:** controller scene + ability scene under `scenes/ability/`, an `Ability` `.tres` pointing to the controller scene, then register it as an upgrade (above).
- **New enemy:** scene under `scenes/game_object/enemies/` with the standard components, a loot table `.tres` in `resources/loot_tables/`, and an `@export` + table entry in `enemy_manager.gd`.

## Code style

- Tabs for indentation. Two blank lines between functions.
- `snake_case` names; `class_name` in PascalCase for types referenced elsewhere.
- **Function naming:** functions used only inside their own script get a leading underscore (`_get_spawn_position`); functions called from other scripts or scenes have none (`damage`, `set_ability_upgrades`). Signal handlers are internal: `_on_<source>_<signal>`. Some older code doesn't follow this yet. Fix it when touching that code, and update every caller.
- `@onready var x = $Node` for child references; `@export` for cross-scene references.
- Frame-rate-independent smoothing uses `lerp(..., 1 - exp(-k * delta))`.
