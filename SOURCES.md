# SOURCES.md

## Starter
nikbearbrown/walker-jumpman ("First Steps"), by Nik Bear Brown. No LICENSE file is present in the starter repository; this project is coursework built on it under the Assignment 1 instruction to extend that starter, not a redistribution claim. Godot 4.7.2, GDScript. Provides: the movement model, collider setup, the session state machine, the level JSON format, the base HUD, and (where present) the starter's automated checks.

## Original vs. new
- **Unchanged from the starter:** tuning.gd, the 18×28 collider, the original two zones (the corresponding entries in godot/levels/first_steps.json), pause/retry handling, controls.
- **New:** the Cardinal character redesign in godot/features/player/player.gd's drawing code; the Two-Step Crossing level section and its entries in first_steps.json; whatever camera/bounds/HUD changes turn out to be needed for the wider level (see CHANGE-BRIEF.md's predicted failure cases); CHANGE-BRIEF.md, TEST-REPORT.md, FRICTIONAL.md, this file, and the film materials.

## AI contribution
Claude Code was used for implementation, following the assignment's expected workflow: propose a plan, implement one approved step at a time, show the diff, run the relevant checks.

[Fill in as work proceeds — be specific: which pieces Claude implemented, what you accepted as-is, what you modified, and anything Claude proposed that you rejected and why.]

## Assets
No imported art, sprite sheets, or external assets. All visuals are original geometric drawing (draw_rect / draw_colored_polygon or equivalent) in `_draw()`, consistent with the starter's approach.
