# walker-jumpman-ss

Extension of [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) ("First Steps") by Nik Bear Brown — not a new game. Built for CSYE 7270, Assignment 1.

(Project name is a placeholder — keep the `walker-` prefix, swap `ss` for whatever suffix you actually use.)

## Starter credit
Base project, movement model, session/state-machine structure, and level format: nikbearbrown/walker-jumpman, Godot 4.7.2. This repository extends it; it does not replace it. See SOURCES.md for the exact original-vs-new split.

## Engine
Godot 4.7.2 (stable), GDScript. No .NET runtime, no external assets, no paid services required.

## Run instructions
1. Install Godot 4.7.2 (standard build) from godotengine.org.
2. Clone this repository.
3. Open `godot/project.godot` in the Godot editor and press Play (F5) — or run `godot --path godot` from the cloned folder.

## Controls
Enter to start · A/D or arrow keys to move · Space to jump · R to retry · Escape or P to pause. Reach the flag. Retries are unlimited.

## What changed
- **Character:** replaced the starter's single-eye rectangle-stack runner with an original geometric redesign, "Cardinal." Same 18×28 collider, same movement tuning. Full concept in CHANGE-BRIEF.md.
- **Level:** added a new section, "Two-Step Crossing," past the original finish — two new required-jump landings, a spike hazard, and the finish flag relocated to the far landing. The original two zones are unchanged and still fully playable.

## Known limitations
- **Early full jump reaches Landing 1.** A full held jump taken early off the original ledge (takeoff x ≈ 900–940) lands on Landing 1, so holding right for both Two-Step jumps can succeed. Accepted, not a bug — see CHANGE-BRIEF.md Revisions.
- **Reduced beak-to-body contrast.** The body color fix (orange `f07a2a`, for contrast against the spikes) lowered contrast between the yellow beak and the body to about 1.5:1. Not yet confirmed in live play.
- **Hint text may overlap the committed jump.** The jump from Landing 1 passes through the "Short hop. Then commit." hint. Whether this is distracting is not yet confirmed.
- **HUD reads ~99.2% at flag trigger.** The finish triggers when the collider touches the flag, slightly before the progress span ends. Cosmetic; not fixed.

## Final film
[link — add once the Brutalist walkthrough is rendered]
