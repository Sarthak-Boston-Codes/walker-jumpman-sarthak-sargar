# SOURCES.md

## Starter
nikbearbrown/walker-jumpman ("First Steps"), by Nik Bear Brown. No LICENSE file is present in the starter repository; this project is coursework built on it under the Assignment 1 instruction to extend that starter, not a redistribution claim. Godot 4.7.2, GDScript. Provides: the movement model, collider setup, the session state machine, the level JSON format, the base HUD, and (where present) the starter's automated checks.

## Original vs. new
- **Unchanged from the starter:** tuning.gd, the 18×28 collider, the original two zones (the corresponding entries in godot/levels/first_steps.json), pause/retry handling, controls.
- **New:** the Cardinal character redesign in godot/features/player/player.gd's drawing code, plus a visual-only `airborne` flag and `wings_open()`; the Two-Step Crossing level section (width 1280, Landing 1, Landing 2, second spike, relocated finish) in first_steps.json; drawing-only changes in godot/game/session.gd (background/grid follow `level.width`, a background hill, the "03 / TWO-STEP CROSSING" label and hint, "FINISH" label follows the flag); the HUD progress span in godot/ui/hud.gd now derived from level data, and its menu copy updated for the third crossing; the extended route fixture, ten new checks in test_game.gd, and a fifth screenshot in capture_game.gd; CHANGE-BRIEF.md, TEST-REPORT.md, FRICTIONAL.md, this file, and the film materials.
- **Camera/bounds:** no change needed — the starter's camera clamp and right wall already derive from `level.width` (see CHANGE-BRIEF.md Revisions).

## AI contribution
Claude Code was used for implementation, following the assignment's expected workflow: propose a plan, implement one approved step at a time, show the diff, run the relevant checks.

Claude Code (2026-09-24), each step approved before implementation:
- **Plan:** read the brief and code; found the camera clamp was already data-driven and the real risk was hard-coded drawing; simulated the tuning and flagged that "standing vs. running" differs by only ~9 px under full air control.
- **Step 0:** drafted the CHANGE-BRIEF.md Revisions entries (rewording to "short hop, then commit"; re-scoped failure case 2; confirmed failure case 1). Accepted as worded.
- **Step 1:** implemented the Cardinal drawing, the `airborne` flag, and `wing-pose-follows-floor`.
- **Step 2:** proposed and sweep-verified the new geometry, drawing fixes, route-driver hold marks, and seven extension checks; found the early-full-jump gap. Decision to accept the gap and record it in Revisions was made by the student.
- **Step 3:** HUD progress from level data, with two checks.
- **Step 4:** regenerated evidence and screenshots, updated these reports, added `05-crossing` to the build record.
- **Follow-up (student request):** menu copy "Cross two gaps." → "Cross the gaps."
- **Follow-up (student request):** Cardinal body fill `e0532f` → `f07a2a` for contrast against the spike red; Claude compared candidate colors by contrast ratio against the spike, beak, and wing and chose the balance point.

[Student: add what you modified by hand after these steps, and anything you rejected.]

## Assets
No imported art, sprite sheets, or external assets. All visuals are original geometric drawing (draw_rect / draw_colored_polygon or equivalent) in `_draw()`, consistent with the starter's approach.
