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

**2026-09-24 — Level decision reworded (before build).**
Simulating the unchanged tuning.gd values at 60 Hz shows takeoff speed barely changes jump distance: a full-speed jump holding right covers 106.7 px, a standing jump holding right covers 97.8 px — a ~9 px difference, less than half the 18 px collider. The player reaches full speed in ~7 ticks and has full air control (same acceleration grounded or airborne), so the distance is set by how long the direction is held *in the air*, not by the run-up. "Standing lands / running overshoots" can't be made reliable without changing tuning or air control, both of which stay unchanged.
The decision is therefore reworded: **a short, controlled hop onto Landing 1 (release the direction early), then a full committed jump to Landing 2 (hold it the whole way).** It is still two opposite techniques back to back, and repeating the same input for both still fails one of them. The geometry intent in the Level extension section is otherwise unchanged; "standing jump" there should be read as "short hop," and "running jump" as "full held jump."

**2026-09-24 — Failure case 2 (camera/bounds) re-scoped after reading the code.**
The camera clamp (`session.gd` `_physics_process`) and the right boundary wall (`session.gd` `_ready`) already derive from `level.width`, so widening the level in data extends both. The real risk is in the drawing code, which is hard-coded to the original level: the background grid stops at x = 960, the background rect ends at x = 1400, the "FINISH" label is fixed at x = 878, and the flag pole always starts at y = 320. The check stays the same — walk to the far right and confirm the camera keeps scrolling and the new landings, spike, and flag are visible and readable — but the fix targets the drawing, not the clamp.
Related constraint: spikes are always drawn at y 304–320 regardless of their data position (collision uses the real position), so the new spike will sit on a y = 320 surface to keep drawing and collision aligned without touching hazard logic.

**2026-09-24 — Failure case 1 (HUD percent) confirmed.**
`hud.gd` computes progress as `(x - 64) / 852`, where 852 is the original finish x (916) minus spawn x (64). As predicted, it would read 100% at the old flag. Fix: derive the span from `level.spawn` and `level.finish`.

**2026-09-24 — Same-input gap found in the built geometry (accepted).**
A real-engine sweep of the Two-Step Crossing (Landing 1 `[1016, 320, 32, 16]`, spike `[1104, 304, 24, 16]`, Landing 2 `[1104, 320, 176, 64]`) shows the "repeating the same input for both fails one of them" claim holds only partly:
- A full held jump taken at the old ledge's edge (x ≥ 950) overshoots Landing 1 and dies, and a short hop from Landing 1 always falls short — so jump-at-the-edge-and-hold twice, or short-hop twice, both fail as intended.
- But a full held jump taken *early* off the old ledge (takeoff x ≈ 900–940, a ~40 px / ~15-tick window) lands on Landing 1. A player who jumps early can therefore hold right for both jumps and succeed.
- Measured windows: short hop from the edge lands with ~18–30 ticks of right held; the committed jump from Landing 1 needs takeoff x ≥ 1036 (the last ~20 px of the platform).
The gap can't be closed by moving Landing 1 alone, because air control is full and the old ledge is 176 px long. Closing it would need a new obstacle over the end of the original ledge (changes zone-2 space) or an air-control change (breaks the unchanged-tuning rule). Decision: accept it. The intended read is "jump at the edge, then control the hop," which zone 2 already teaches; the early-jump route is a legitimate alternative skill, not a bypass of the section. Playtesting should record which route new players actually take.
