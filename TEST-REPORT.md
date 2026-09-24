# TEST-REPORT.md

Source revision: `dbceab3` on branch `extension/cardinal-two-step-crossing` (game source last changed in `31eca6a`; later commits are documentation only)
Engine version: Godot 4.7.2 (stable), `4.7.2.stable.official.ed1daf0bf`, Windows 11, Compatibility renderer

Machine checks below were run by Claude Code on 2026-09-24. They verify mechanics and presentation facts; they are not a playtest and make no claim about fun, fairness, or clarity for a new player.

| Check | Evidence to collect | Result |
|---|---|---|
| Startup and controls | Project runs; movement, jump, pause/resume, and restart still work | PASS (machine). 9/9 keyboard checks inject real key events (Enter start, D move, Space jump, Esc pause, Enter resume, R retry, Enter replay, P→M menu, Enter restart) — [evidence/keyboard-1790280445.224.json](evidence/keyboard-1790280445.224.json). Normal main-scene launch ran 120 frames with no script errors. |
| Character appearance | Left/right, standing, and jumping views; no misleading visual/collision mismatch | PASS (machine) with caveats. `wing-pose-follows-floor`: wings closed on ground, open 10 ticks into a jump, closed after landing. Zoomed renders confirmed beak/eye flip with facing. Collider unchanged at 18×28; the beak extends 3 px past it horizontally and the crest 3 px above it — visual only. |
| Extended route | A normal playable route reaches both new landings and the relocated finish | PASS (machine). `complete-real-route`: 0 deaths, 7 jumps, 466 ticks (~7.8 s) to the flag at x = 1236. `short-hop-lands-landing-1` lands at x = 1022.6; `full-jump-from-landing-1-clears-spike` lands at x = 1167.3. Known fast route, not a predicted new-player time. |
| Failure and recovery | A real hazard or missed landing produces the expected retry; replay works after completion | PASS (machine). Existing spike/fall/respawn/twenty-retries/replay checks all pass. New: `full-hold-off-ledge-edge-overshoots` and `short-hop-from-landing-1-fails` both end in DYING via a real fall. |
| Camera and presentation | The extension and important landing/finish information remain visible and readable | PASS (machine) for visibility. `camera-shows-landing-2-from-landing-1`: camera at its data-derived limit (960) with the spike and flag fully in view. `hud-below-100-at-old-finish` (72.7% at x = 916) and `hud-100-at-new-finish` (100% at x = 1236). `old-finish-is-pass-through`: standing at the old flag position does not complete the level. Readability is a human judgment — see below. |
| Automated checks | Commands run, results, and any failed or updated tests, with an explanation | `test_game.gd`: **35 checks / 0 failures** — [evidence/mechanics-1790280443.662.json](evidence/mechanics-1790280443.662.json). `test_keyboard.gd`: **9 / 0**. `capture_game.gd`: 5 rendered-viewport screenshots, route completed with 0 deaths. Baseline before any change: 25/0 and 9/0 ([mechanics](evidence/mechanics-1790276710.21.json), [keyboard](evidence/keyboard-1790276712.29.json)). No existing assertion was removed or loosened; 10 checks were added. |

Commands (from the repo root):
```
godot --headless --path godot --script res://tests/test_game.gd
godot --headless --path godot --script res://tests/test_keyboard.gd
godot --path godot --script res://tests/capture_game.gd
node scripts/record-build.cjs
```

## Route fixture note
The supplied route (`godot/tests/route_driver.gd`) held right for the whole run and jumped at five x-positions ending at 712; after the extension it would have run past the old flag into the new gap and failed `complete-real-route`. It was extended, not weakened: each mark is now `[x, hold]`, where `hold = -1` keeps right held through the jump (all five original marks, unchanged positions) and `hold = N` releases right N ticks after takeoff until landing. Two marks were added: `[955, 22]` (short hop onto Landing 1) and `[1048, -1]` (committed jump to Landing 2). The `complete-real-route` assertion itself is unchanged (COMPLETE with zero deaths).
New checks covering the extension: `original-geometry-intact`, `full-hold-off-ledge-edge-overshoots`, `short-hop-lands-landing-1`, `short-hop-from-landing-1-fails`, `full-jump-from-landing-1-clears-spike`, `old-finish-is-pass-through`, `camera-shows-landing-2-from-landing-1`, `hud-below-100-at-old-finish`, `hud-100-at-new-finish`, plus `wing-pose-follows-floor` for the character.

## Inspect-and-revise cycle
These cycles came from machine inspection during the build; the human playtest cycle is still required below.

1. **Observed:** simulating the unchanged tuning showed a standing jump holding right travels 97.8 px vs. 106.7 px running — a ~9 px difference, because air control is full. **Changed:** the level decision was reworded from "standing vs. running" to "short hop (release early) vs. full held jump" before any geometry was built (CHANGE-BRIEF.md Revisions). **Why:** the original wording couldn't be made reliable without changing the protected tuning.
2. **Observed:** a real-engine sweep of the built geometry showed a full held jump taken early (x ≈ 900–940) also lands on Landing 1, so holding right twice can succeed. **Changed:** nothing in geometry; the gap was recorded and accepted in Revisions. **Why:** closing it needs a new obstacle over the original ledge or an air-control change, both outside the brief's constraints.
3. **Observed:** the 1× render with the player standing on Landing 1 showed the HUD bar already full — the brief's predicted failure case 1, visible in the real renderer. **Changed:** `hud.gd` progress now derives from `level.spawn` and `level.finish` (Step 3). **Why:** the old hard-coded span (852) ended at the old flag. Re-render showed ~82% on Landing 1.
4. **Observed (while planning the wing pose):** `is_on_floor()` is false before the first physics tick, so wings tied directly to it would show open on the menu. **Changed:** added an `airborne` flag set after `move_and_slide()` and cleared on reset. **Why:** keeps the menu and retry poses grounded; confirmed in the regenerated `01-menu.png`.

5. **Observed:** the regenerated `01-menu.png` still said "Cross two gaps." — the level now has a third crossing. **Changed:** menu copy in `hud.gd` to "Cross the gaps. Clear the spikes. Reach the flag." **Why:** the old count was no longer true; the new line fits the card at the same size (confirmed in the re-rendered menu).

6. **Observed:** in `02-failure.png` the Cardinal's body (`e0532f`) was nearly the same luminance as the spike red (`d24e42`) — contrast ratio 1.11:1, hue 12° vs 5° — so the bird was separated from the spikes mainly by its ink outline. **Changed:** body fill only, to orange `f07a2a` (1.53:1 against the spike, hue 24°); crest, wings, beak, outline, shapes, and collider untouched. **Why:** lighter oranges raised spike contrast further but dropped the yellow beak toward invisibility (e.g. `f29a2e`: 1.92 vs spike, 1.21 vs beak); `f07a2a` keeps both at ~1.5:1. Confirmed in the re-rendered `02-failure.png`, where the orange body reads distinctly against the red spikes.

## Open issues found by inspection, not fixed
- The committed jump from Landing 1 passes through the "Short hop. Then commit." hint text.
- Progress reads ~99.2% at the instant the flag triggers (collider touches the flag before x reaches 1236).

## Playtester
**Author playtest** — played the built game, after the body color fix, as the author.

Observed:
- Controls worked as expected: Enter, A/D and arrow keys, Space, R, and Esc/P.
- Falling to a hazard triggered retry and respawn via R, and play continued forward through the level normally afterward.
- The HUD progress percentage tracked correctly throughout, including through the new section.
- Progressed through the Two-Step Crossing and reached the relocated flag, which correctly ended the level.

Not specifically observed (not confirmed either way):
- How early the hop-then-commit decision reads before a first failure.
- Which route was taken off the original ledge.
- Beak legibility against the new orange body during live play.
- Whether the hint text is distracting mid-air.
