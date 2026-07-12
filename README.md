# Simple Menu — Cyberpunk 2.31 Compatibility Fork

A community fork of **Simple Menu** — the all-in-one cheat, debug, and exploration helper for Cyberpunk 2077 — updated and hardened for **Cyberpunk 2077 2.31** with maximum backwards-compatibility.

> **Original mod:** [Simple Menu on Nexus Mods (mod #818)](https://www.nexusmods.com/cyberpunk2077/mods/818)
> **Original creator:** [Dank Rafft](https://www.nexusmods.com/cyberpunk2077/users/4334902)
> **Upstream maintainer (2.0+ era):** [capncoolio2](https://www.nexusmods.com/cyberpunk2077/users/78694482)
> **This fork:** [Artheriax](https://github.com/Artheriax)

---

## Credits & License

This fork is a derivative work and would not exist without the work of the people below. **All credit for the original mod belongs to them.**

| Role | Person | Link |
|---|---|---|
| Original creator / original author of Simple Menu | **Dank Rafft** | [Nexus profile](https://www.nexusmods.com/profile/DankRafft) |
| Current upstream maintainer (2.0+ / Phantom Liberty / 2.3 / 2.31 ports) | **capncoolio2** | [Nexus profile](https://www.nexusmods.com/profile/capncoolio2) |
| Original Nexus mod page | Dank Rafft (with capncoolio2 credited as maintainer) | https://www.nexusmods.com/cyberpunk2077/mods/818 |
| Breach Protocol tab | Corvellt | [Nexus profile](https://www.nexusmods.com/profile/Corvellt) |
| Original Infinite Ammo script | TheBs65422 | — |
| Original item upgrade script | Expired | — |
| `cp2077-cet-kit` (Cron / GameSession / GameHUD) | psiberx | [github.com/psiberx/cp2077-cet-kit](https://github.com/psiberx/cp2077-cet-kit) (MIT) |

This fork:
- Adds **no new features** on top of upstream — it is a stability, compatibility, and bug-fix release.
- Is released under the same terms as the original mod. The bundled `cp2077-cet-kit` libraries remain under their original MIT license (see `bin/x64/plugins/cyber_engine_tweaks/mods/simplemenu/libs/cp2077-cet-kit/LICENSE.txt`).
- If you are Dank Rafft or capncoolio2 and want anything in this repo changed, please open an issue and I will respond immediately.

---

## What this fork fixes (vs. the upstream snapshot it was forked from)

### Compatibility
- **Bundled `Cron.lua` updated from `1.0.2` → `1.0.3`** — pulls in the upstream psiberx fix for unexpected timer execution order ([cp2077-cet-kit issue #7](https://github.com/psiberx/cp2077-cet-kit)). This fixes subtle timing bugs where button timers and the loading progress bar could tick out of order.
- **Belt-and-suspenders `pcall` protection** on every potentially-fragile game API call (police toggle, achievement unlock, vehicle repair, quest ending, item quality lookup). A missing or renamed method on any future patch will now print a warning instead of killing the menu.
- **`PostLoadActions` hardened** — guards against `Game.GetPlayer()` being briefly nil during hot-reloads, and wraps `RefreshCraftBookMenu` / `DisablePolice` in `pcall` so a failure in one subsystem no longer blocks the others.

### Bug fixes
- **Search tab: Type list now filters by selected Category.** Previously, selecting a category like "Weapon" still showed every item type in the Type listbox (including irrelevant ones like "Tarot Card" or "Crafting Spec"). The type list now dynamically rebuilds to show only types that actually have at least one item in the selected category. Switching back to "(All)" restores the full type list. The type selection resets to "(All)" whenever the category changes.
- **`Misc.ChangeFact` no longer double-prints.** Previously, setting a Romance fact (category 3) printed both *"Romance quest fact …"* and *"Quest fact …"* because the early-return was missing. The fact was also written twice. Now it prints exactly once.
- **`ItemRecord:GetQuality` logic corrected.** The ternary used `or` where it should have used `and` — `nil or X` always returns `X`, so the function always returned the quality name even when it was empty. Now correctly returns `nil` for empty quality strings (so the search UI shows `--` instead of a blank cell).
- **`Items.GetFilteredRecords` dead code removed.** The `return result` line referenced a `result` variable that was never assigned — it silently returned `nil`. Now the function correctly documents that results are written into the `outRecordList` argument (passed by reference), matching actual behaviour.
- **`Misc.Kill` no longer prints "Killed NPC" when nothing was killed.** It now returns `true`/`false` and prints a context-appropriate message (`"no target under crosshair"`, `"target is not an NPC"`, or `"Killed NPC"`).
- **`Misc.EndQuest` no longer crashes when there's no tracked quest.** Adds nil guards at every step of the `GetTrackedEntry → GetParentEntry → GetParentEntry → GetEntryHash → ChangeEntryStateByHash` chain.
- **`Misc.FixCar` no longer crashes when not looking at a vehicle.** Adds nil guards for `Game.GetPlayer()`, `Game.GetTargetingSystem()`, the look-at object, and the `IsExactlyA` calls (wrapped in `pcall` for safety against modded vehicle classes).

### Config migration
- **Non-destructive config migration.** The previous behaviour wiped the entire user config whenever the mod's internal version number changed — losing all hotkeys, saved teleport positions, and toggle states. The new `mergeDefaults` function recursively merges new default keys into the existing config, preserving every user preference that still has a corresponding default. The config version has been bumped to `52`.
- **`Util.ResetConfig` no longer corrupts the defaults table.** Previously it did `Util.configuration = Util.configurationDefault` (a direct reference), so any later mutation of the user's config would silently mutate the defaults that future fresh installs would inherit. It now uses a proper deep copy.

### Project hygiene
- Added a `.gitignore` so user-generated config files (`config.json`, `quickTele.json`, `lang.json`) and runtime logs are no longer accidentally committed.
- Updated the header comment in `init.lua` to credit both the original creator (Dank Rafft), the upstream maintainer (capncoolio2), and this fork.

---

## Requirements

| Component | Minimum version | Recommended | Why |
|---|---|---|---|
| **Cyberpunk 2077** | 2.21 | **2.31** | This fork is built and tested against 2.31. The codebase already supports 2.0 → 2.31, but 2.31 is the recommended target. |
| **Cyber Engine Tweaks (CET)** | 1.34.0 | **1.37.1** | CET 1.37.1 is the latest release that supports Cyberpunk 2.31. Older versions will not load on 2.31. [Download from GitHub](https://github.com/maximegmd/CyberEngineTweaks/releases). |
| **RED4ext** | 2.2.0 | **2.31-compatible build** | Required by CET 1.37.x. [Download from GitHub](https://github.com/WopsS/RED4ext/releases). |
| **TweakXL** (optional) | 1.7.0+ | latest | Only required if you use TweakXL-dependent mods alongside Simple Menu. |
| **ArchiveXL** (optional) | 1.7.0+ | latest | Only required if you use ArchiveXL-dependent mods alongside Simple Menu. |

> **Note:** The canonical CET repository has moved from `yamashi/CyberEngineTweaks` to **`maximegmd/CyberEngineTweaks`**. The old URL redirects, but please update any bookmarks.

---

## Installation

### Fresh install

1. Install **Cyber Engine Tweaks 1.37.1** (or newer) by extracting its `bin/` folder into your Cyberpunk 2077 install directory. ([CET releases](https://github.com/maximegmd/CyberEngineTweaks/releases))
2. Install **RED4ext** (the build matching your game version). ([RED4ext releases](https://github.com/WopsS/RED4ext/releases))
3. Download this fork (clone the repo or grab a release `.zip`).
4. Copy the `bin/` folder from this repo into your Cyberpunk 2077 install directory. The final path should look like:
   ```
   <Cyberpunk 2077>/bin/x64/plugins/cyber_engine_tweaks/mods/simplemenu/init.lua
   ```
5. Launch the game. Once you load a save (or start a new game), open the CET overlay (default: the grave accent / backtick key `` ` ``) and the Simple Menu window will appear. You can also bind a hotkey to toggle the menu in *Settings → Key Bindings → Mods*.

### Updating from the upstream Simple Menu

1. **Back up your config first.** Copy these files somewhere safe:
   - `bin/x64/plugins/cyber_engine_tweaks/mods/simplemenu/config/config.json`
   - `bin/x64/plugins/cyber_engine_tweaks/mods/simplemenu/config/quickTele.json`
   - `bin/x64/plugins/cyber_engine_tweaks/mods/simplemenu/translation/lang.json`
2. Delete the existing `simplemenu/` folder.
3. Install this fork as above.
4. Restore your backed-up config files. The new non-destructive migration will preserve all your settings and add any new defaults the fork introduces.
5. **Delete the modded TweakDB cache** (see Troubleshooting below) — this is mandatory after any core-mod update.

---

## Features (inherited from upstream)

Simple Menu is a one-stop cheat and exploration menu. Major features include:

- **Items tab** — add any weapon, clothing, consumable, crafting material, grenade, cyberware, or junk item to your inventory; force any quality tier; upgrade all equipped gear in one click; remove quest tags from items; infinite ammo (magazine or inventory); super reload / accuracy / zoom / range; no recoil; "ultra kill" and "psycho mode" weapon cheats; smart-gun "big brain" targeting; tech-pierce "penetrator"; beast mode for melee; infinite melee combo.
- **Player tab** — god mode; infinite stamina / oxygen; one-click max level / max attributes / max street cred; add attribute / perk / relic points; reset perks; modify individual stats (permanently or temporarily); toggle invisibility (with hostile-NPC pacification); 12 instant-cooldown cheats (heal item, grenade, projectile launcher, cloak, sandevistan, berserk, kerenzikov, overclock, quickhack cooldown, quickhack cost, memory regen, faceplate); infinite double jump; infinite air dash.
- **Misc tab** — set / step wanted level; toggle the entire police system off; end the current tracked quest; untrack the current quest; unlock all achievements; kill the NPC under your crosshair; slow-motion (with separate global / player dilation sliders and a self-effect toggle); freeze game time; freeze vehicle mission timers; teleport to any apartment or to a saved custom position; quick-teleport to V's apartment / Viktor's clinic; "door buster" forward-jump teleport; repair your vehicle; unlock / lock any player vehicle; unlock all vehicles; toggle instant vehicle spawn.
- **Search tab** — searchable index of every TweakDB item in the game (filtered by type, category, quality tier, and iconic flag). Add any item, in any quantity, at any forced quality tier. The indexer runs in the background and shows a progress bar on first load.
- **Crafting tab** — manage known crafting recipes; refresh the craftbook; (v51-beta) browse and toggle craftable recipes.
- **Breach Protocol tab** — freeze the breach timer; customise the time limit, grid size, and buffer size; force the puzzle length.
- **Config tab** — per-menu visibility toggles; weapon-mod customisers (smart-gun reticle pitch/yaw, projectile velocity, lock range, max locks; psycho-mode projectile count and fire rate; super-zoom level); search loading-bar speed; debug / log level; popups on/off; auto-open with CET overlay.

Most features have a hotkey (bindable in *Settings → Key Bindings → Mods*).

---

## Troubleshooting

### "CET won't load / overlay key does nothing / no `cyber_engine_tweaks.log` file is created" on 2.31

This is **almost always caused by Windows Update KB5095093**, which ships a broken Visual C++ runtime that CET depends on. It is **not** a Simple Menu bug. The official Cyberpunk Modding Discord fix:

1. Control Panel → Windows Update → Update History → confirm KB5095093 is installed.
2. Uninstall KB5095093 → reboot.
3. Repair the Visual C++ Redistributable (x64) via *Settings → Apps → Installed apps → Microsoft Visual C++ 2015–2022 Redistributable (x64) → Modify → Repair* → reboot.
4. Launch the game.

If you can't uninstall KB5095093 (e.g. on Windows 11), installing the **latest** Visual C++ Redistributable directly from Microsoft over the top also fixes it in most cases.

### "Main menu is stuck / text is missing / mods don't load" after updating any core mod

You have a stale modded TweakDB cache. This is the single most common cause of post-update breakage. Fix:

1. Close the game.
2. Delete `<Cyberpunk 2077>/r6/cache/modded/tweakdb.bin`.
3. (Optional but recommended) Also delete `<Cyberpunk 2077>/r6/cache/final/tweakdb.bin` — it will be rebuilt on next launch.
4. Launch the game. The first launch after this will take longer as the cache is rebuilt.

### CET and CyberCMD conflict

If you have both CET and **CyberCMD** installed, CET may fail to load. CyberCMD's own page warns against this combination. Pick one or the other — for Simple Menu, you need CET.

### Simple Menu window doesn't appear

- Make sure you've loaded a save (or started a new game) — the menu only initialises after the game world is loaded, not on the main menu.
- Open the CET overlay first (default key: `` ` ``). If `autoUI` is on (the default), Simple Menu will appear automatically with the overlay. Otherwise, bind and press the "Toggle Simple Menu" hotkey in *Settings → Key Bindings → Mods*.
- Check `<Cyberpunk 2077>/bin/x64/plugins/cyber_engine_tweaks/mods/simplemenu/simplemenu.log` for Lua errors.

### Reporting bugs in this fork

Please open an issue at <https://github.com/Artheriax/simple-menu-cp2077-fork/issues> with:
- Your game version (e.g. 2.31).
- Your CET version (e.g. 1.37.1).
- The contents of `simplemenu.log`.
- What you expected vs. what happened.

For bugs that exist in the upstream mod (not specific to this fork), please report them on the [Nexus Mods page](https://www.nexusmods.com/cyberpunk2077/mods/818) so capncoolio2 sees them.

---

## For developers

### Repository layout

```
bin/x64/plugins/cyber_engine_tweaks/mods/simplemenu/
├── init.lua                          # Mod entry point; event registration, lifecycle
├── simplemenu.log                    # Runtime log (gitignored; created at first run)
├── db.sqlite3                        # Pre-baked item DB used by the search tab
├── classes/
│   ├── colour.lua                    # Colour helper (RGBA, hex, presets)
│   └── itemrecord.lua                # ItemRecord class (wraps a TweakDB item record)
├── config/
│   ├── hotkeys.lua                   # Hotkey registration
│   ├── util.lua                      # Config load/save/migration + ternary/spairs helpers
│   ├── config.json                   # User config (gitignored; created at first run)
│   └── quickTele.json                # User quick-teleport positions (gitignored)
├── items/
│   ├── ammo.lua                      # Weapon & player modifiers (infinite ammo, super reload, etc.)
│   ├── items.lua                     # Item indexing, filtering, add-to-inventory logic
│   ├── shop.lua                      # Sell/disassemble/convert helpers
│   └── upgrade.lua                   # Equipment upgrade / quality change / quest-tag removal
├── libs/
│   └── cp2077-cet-kit/               # psiberx's Cron / GameSession / GameHUD (MIT)
│       ├── Cron.lua                  # v1.0.3 — updated in this fork from v1.0.2
│       ├── GameSession.lua           # v1.4.5
│       ├── GameHUD.lua               # v0.4.1
│       └── LICENSE.txt
├── misc/
│   ├── cetUtils.lua                  # Misc Lua helpers (rounding, arrays, string, table printers)
│   ├── delegates.lua                 # Observe/Override delegate functions
│   ├── deprecatedRecipes.lua         # Hard-coded list of TweakDB recipe IDs to skip in crafting tab
│   ├── misc.lua                      # Quest / police / time / slow-mo / breach / vehicle helpers
│   └── travel.lua                    # Teleportation & vehicle unlock helpers
├── player/
│   ├── perks.lua                     # Perk enum list & buy/sell helpers (by Corvellt)
│   └── player.lua                    # Player stat modifiers (god mode, inf. stamina, cooldowns, etc.)
├── translation/
│   ├── lang.json                     # Selected language (gitignored; created at first run)
│   ├── labels/
│   │   └── en.json                   # English UI strings
│   └── meta/
│       └── default-en-meta.json      # English metadata
└── ui/
    ├── elements.lua                  # ImGui helper elements (tooltips, headers, lists, etc.)
    ├── main.lua                      # Top-level tab bar
    ├── notifications.lua             # On-screen toggle notifications
    └── tabs/
        ├── config.lua                # Config tab UI
        ├── crafting.lua              # Crafting tab UI
        ├── items.lua                 # Items tab UI
        ├── misc.lua                  # Misc tab UI
        ├── player.lua                # Player tab UI
        └── search.lua                # Search tab UI
```

### Defensive-coding patterns used in this fork

The game's Lua bindings will hard-crash the entire CET runtime if you call a method on a nil object, or call a method that no longer exists on a given patch. This fork adopts the following patterns to maximise compatibility across 2.21 → 2.31 (and hopefully beyond):

1. **`pcall`-wrap every fragile accessor.** `classes/itemrecord.lua` now wraps `:Quality()`, `:Value()`, `:Type()`, and the localised-text lookup in `pcall` so that modded or malformed TweakDB records (which the search indexer will encounter) no longer abort the indexing loop.
2. **Nil-guard at function entry.** Every public function in `misc/misc.lua` and `items/items.lua` that calls `Game.GetPlayer()` now checks for nil before proceeding, with an explanatory log message.
3. **`pcall`-wrap system mutators.** `Misc.DisablePolice` wraps the belt-and-suspenders `ps:TogglePreventionSystem(...)` call in `pcall` so that if the direct method is ever removed (the maintained mod switched to `ScriptedSystemRequest`), the queued request still goes through.
4. **`pcall`-wrap one-shot APIs.** `Misc.UnlockAchieve` wraps `Game.UnlockAllAchievements()` — an API that was temporarily removed in v48 then re-added — so future removals degrade gracefully.
5. **Belt-and-suspenders for system toggles.** `Misc.DisablePolice` sends both a `TogglePreventionSystem.new()` request via `QueueRequest` *and* calls `ps:TogglePreventionSystem(...)` directly. Different patch levels honour different paths; sending both maximises compatibility.
6. **`wrappedFunc` Override pattern.** Every `Override(...)` in `misc/delegates.lua` calls `wrappedFunc(...)` first to get the vanilla return value, then conditionally modifies it only when the corresponding feature is enabled. This means features are off-by-default and the mod behaves like vanilla when nothing is toggled on.
7. **Config-gating.** All behavioural changes are gated behind `Util.configuration.functions.<feature>` flags, so a fresh/default config produces vanilla behaviour.

### Validating against future game patches

When a new Cyberpunk patch drops, the fastest way to verify whether this mod still works is to check [NativeDB](https://nativedb.red4ext.com) — it is an RTTI dump of the game's scripting API and is tagged with the game version it was generated from. Cross-reference every class/method/enum the mod uses against the current NativeDB; anything missing needs a `pcall` wrap or a replacement API.

The research that informed this fork's compatibility work (verified against NativeDB v2.31) confirmed that **every** class, method, and enum value used by this mod is still present in 2.31. The hardening is therefore forward-looking — it makes the mod resilient to *future* removals rather than fixing any current 2.31 breakage.

---

## Changelog (this fork)

### v52 (2.31 compatibility fork)
- **Compatibility:** bundled `Cron.lua` updated 1.0.2 → 1.0.3 (timer execution order fix).
- **Compatibility:** `pcall` protection added to `Misc.DisablePolice` direct-toggle call, `Misc.UnlockAchieve`, `Misc.FixCar` `IsExactlyA` calls, `ItemRecord:new` quality lookup, `PostLoadActions` `RefreshCraftBookMenu` and `DisablePolice` calls.
- **Compatibility:** nil guards added to `Misc.PoliceLevel`, `Misc.PoliceLevelStep`, `Misc.DisablePolice`, `Misc.Kill`, `Misc.FixCar`, `Misc.EndQuest`, `Items.AddItem`, `PostLoadActions`.
- **Bug fix:** Search tab — Type listbox now dynamically filters to show only types that exist in the selected Category (e.g. selecting "Weapon" hides "Tarot Card", "Crafting Spec", etc.). Switching back to "(All)" restores the full list. Type selection resets to "(All)" on category change.
- **Bug fix:** `Misc.ChangeFact` no longer prints/double-writes for romance facts (category 3).
- **Bug fix:** `ItemRecord:GetQuality` `or` → `and` (was always returning the quality name).
- **Bug fix:** `Items.GetFilteredRecords` dead `return result` removed.
- **Bug fix:** `Misc.Kill` now returns `true`/`false` and prints context-appropriate messages instead of always printing "Killed NPC".
- **Bug fix:** `Util.ResetConfig` now uses a deep copy instead of a direct reference, so user mutations can no longer corrupt the defaults table.
- **Improvement:** non-destructive config migration via new `Util.mergeDefaults` / `Util.DeepCopy` helpers. User preferences are preserved across version bumps.
- **Hygiene:** added `.gitignore` for user-generated config files and runtime logs.
- **Hygiene:** updated `init.lua` header comment to credit all maintainers.
- **Docs:** this README.

---

## Disclaimer

This mod is not affiliated with, endorsed by, or sponsored by CD Projekt Red. "Cyberpunk 2077" and all related trademarks are property of CD Projekt Red. This is a fan-made mod tool provided free of charge for personal use.

Using cheats in online/streamed play is at your own discretion. Simple Menu is a single-player-only tool and does not interact with any online service.
