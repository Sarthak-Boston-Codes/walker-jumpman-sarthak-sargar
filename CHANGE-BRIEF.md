# CHANGE-BRIEF.md

## Starter
nikbearbrown/walker-jumpman ("First Steps"), Godot 4.7.2 / GDScript. Baseline: a single-eye, stacked-rectangle runner, 18×28 collider, two zones (two gaps, one spike), a 960px-wide level, flag finish.

## Character concept — Cardinal
A scout-bird, built from rounded shapes instead of stacked rectangles:
- **Body:** one large oval/teardrop polygon, warm red-orange.
- **Beak:** a small triangle on the leading edge — flips with facing direction, taking over the role the starter's single eye plays now.
- **Crest:** two or three short triangles on the head.
- **Wings:** triangular flaps held flush against the body while grounded; swept outward and enlarged while airborne (jumping or falling). This is a third visual state, tied to the floor check rather than to left/right facing.
- **Legs:** two short rectangles, close to the starter's leg treatment, so the silhouette still reads as "standing" at the same height.

What distinguishes it from the starter: a rounded silhouette instead of a rectangle stack, a beak instead of a bare eye, an added crest, and a state-dependent wing pose. Same collider, same movement tuning — a redesign plus one new visual state, not a rebuild.

## Level extension — Two-Step Crossing
Placed after the original finish flag. The original two zones stay intact and fully walkable.

- A gap too wide to clear in a single jump.
- **Landing 1:** a narrow floating platform positioned so a standing jump from the last original ledge lands on it — a full-speed running jump overshoots past it into the gap.
- **Landing 2 (new finish):** reachable only with a running jump from Landing 1 — a standing jump from Landing 1 falls short into the gap.
- A spike sits just before Landing 2, placed so a full-speed arc from Landing 1 clears it, but a short or mistimed hop drops the player onto it or into the gap.
- **The decision this creates:** the two jumps need opposite technique back to back — controlled/standing off the first ledge, then committed/running off Landing 1. Repeating the same input for both fails one of them.
- The finish flag moves to Landing 2. The original finish position becomes a pass-through point, not a stopping point.

## Must remain unchanged
Controls (A/D or arrows, Space to jump, R to retry, Escape/P to pause), every value in tuning.gd, the 18×28 collider, the original two zones' geometry and existing spike, collision/hazard detection logic, pause and retry state handling. Any necessary departure from this gets written here with a reason before it's built, not discovered after.

## Predicted failure cases

**1. HUD completion percent breaks on the new width.**
The starter's progress readout (godot/ui/hud.gd) computes percent from a fixed span tied to the original 960px level, rather than deriving it from level data or the finish position. Widening the level for the new section will likely make the bar hit 100% before the player actually reaches the new flag.
*Check:* walk to the old finish position and watch the percent readout — it should not read 100% there. It should only hit 100% at Landing 2.

**2. Camera/bounds clamp cuts off the new section.**
godot/game/session.gd likely clamps the camera's right edge to the original level width. The new landings and spike may exist in level data but sit off-screen or get cut off at the old boundary.
*Check:* walk to the far right edge and confirm the camera keeps scrolling, and that both new landings, the spike, and the relocated flag are on-screen and readable before the player reaches them.

Revisions to these predictions get added below with a date — the originals stay as written.

## Revisions
(none yet)
