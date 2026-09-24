# FRICTIONAL.md

Honest build log. Specific accounts of what was tried and what actually happened — not a polished narrative. Label anything written after the fact as retrospective. If something worked on the first try, say that plainly and explain how you checked it — that's worth full credit too.

## Attempts and outcomes
[What you tried, in order, and what actually happened — including anything that didn't work.]

**Author playtest (after the body color fix; written up after the session).** Played the built game as the author. Controls (Enter, A/D/arrows, Space, R, Esc/P) all worked as expected. Falling to a hazard triggered retry and respawn via R, and play continued forward through the level normally afterward. Progressed through the Two-Step Crossing and reached the relocated flag, which ended the level.

## Checked, changed, or learned
[What you verified, what you changed in response, and any open questions you didn't resolve.]

**Author playtest.** Checked: controls, hazard retry/respawn, HUD progress percentage (tracked correctly throughout, including the new section), and that the relocated flag ends the level — all worked as expected. Changed: nothing in response. Open, not specifically observed: how early the hop-then-commit decision reads before a first failure; which route was taken off the original ledge; beak legibility against the orange body in live play; whether the hint text is distracting mid-air.

## Human / AI contribution
[What Claude proposed or implemented, and what you personally accepted, modified, or rejected. Specific, not "AI helped with everything."]

**What Claude (Claude Code) proposed, measured, found, or implemented**
- **Plan (no edits):** read the brief, build report, and code; proposed a five-step plan (Step 0 brief revision → Step 1 character → Step 2 level → Step 3 HUD → Step 4 evidence). Simulated the unchanged tuning and found a standing jump and a running jump differ by only ~9 px (97.8 vs. 106.7 px) because air control is full, so "standing lands / running overshoots" couldn't be made reliable; flagged this as a conflict with the unchanged-tuning rule and proposed the "short hop, then commit" rewording. Found the camera clamp and right wall already derive from `level.width`, so predicted failure case 2 was mostly wrong and the real risk was hard-coded drawing; confirmed failure case 1 (`(x-64)/852` in `hud.gd`); noticed spikes always draw at y 304–320.
- **Baseline:** ran the existing checks on Windows before any change (25/0 mechanics, 9/0 keyboard).
- **Step 0:** drafted the first three CHANGE-BRIEF.md Revisions entries.
- **Step 1:** implemented the Cardinal drawing; noticed `is_on_floor()` is false before the first physics tick and added an `airborne` flag so the menu pose isn't winged; added `wing-pose-follows-floor`; inspected zoomed renders.
- **Step 2:** proposed the geometry, verified it with a real-engine sweep, and found the early-full-jump route onto Landing 1 (takeoff x ≈ 900–940); implemented drawing fixes, the route-driver hold marks, and seven extension checks; added the "Short hop. Then commit." hint (new copy, flagged as removable).
- **Step 3:** derived HUD progress from level data; added two checks; observed the ~99.2% reading at flag trigger.
- **Step 4:** regenerated screenshots and evidence, filled in the machine-check rows of TEST-REPORT.md, updated BUILD-REPORT.md and SOURCES.md; found from the new screenshots that the menu still said "two gaps" and that the body was hard to tell from the spikes.
- **Color fix:** compared candidate body colors by contrast ratio against the spike, beak, and wing; chose `f07a2a` and noted the lower beak contrast it causes.
- **Write-ups:** wrote up the student's playtest and known limitations from the student's own account, without adding findings.

**What the student decided**
- Approved each step before it was implemented, and chose to keep every evidence run.
- Approved the "short hop, then commit" rewording after Claude flagged the tuning conflict, keeping the tuning unchanged.
- Decided to accept the early-full-jump-reaches-Landing-1 gap and record it, rather than force a fix; told Claude not to try to close it.
- Decided to fix the menu copy and the color contrast issue Claude found, keeping everything else about the design unchanged.
- Decided not to chase the hint-text overlap or the ~99.2% HUD reading for now.
- Ran the author playtest and supplied its findings, including which things were not specifically observed.

## Traceability
[Link entries above to actual commits, prompts, tests, or observations — e.g. "see commit a1b2c3d" or "see TEST-REPORT.md row 3."]

**Commits** (branch `extension/cardinal-two-step-crossing`, on top of `f2933f2`)
- `882bd02` — Cardinal character, Two-Step Crossing, drawing and HUD fixes, menu copy, extended route and new checks, regenerated evidence (Steps 0–4).
- `31eca6a` — Cardinal body color `e0532f` → `f07a2a`.
- `9cdadbb` — CHANGE-BRIEF.md Revisions entry for the color change.
- `0007b1f` — author playtest (TEST-REPORT.md, the entries above) and README.md known limitations.
- `dbceab3` — this Human / AI contribution and Traceability write-up.
- `6d8f175` — records `dbceab3` here and as TEST-REPORT.md's source revision (a commit can't contain its own SHA).
- `6cd0cb4` — README.md Final film section: status note that the walkthrough is not yet rendered.

**Decisions and the records that back them**
| Decision | CHANGE-BRIEF.md Revisions | TEST-REPORT.md | Commit |
|---|---|---|---|
| "Short hop, then commit" rewording | "Level decision reworded (before build)" | Inspect-and-revise cycle 1 | `882bd02` |
| Camera left alone; drawing fixed instead | "Failure case 2 (camera/bounds) re-scoped after reading the code" | Camera and presentation row; `camera-shows-landing-2-from-landing-1` | `882bd02` |
| HUD progress derived from level data | "Failure case 1 (HUD percent) confirmed" | Cycle 3; `hud-below-100-at-old-finish`, `hud-100-at-new-finish` | `882bd02` |
| `airborne` flag for the wing pose | — | Cycle 4; `wing-pose-follows-floor` | `882bd02` |
| Accept the early-full-jump gap | "Same-input gap found in the built geometry (accepted)" | Cycle 2; README.md Known limitations | `882bd02`, `0007b1f` |
| Fix the menu copy | — | Cycle 5 | `882bd02` |
| Fix the color contrast | "Cardinal body color changed from warm red-orange to orange (after build)" | Cycle 6 | `31eca6a`, `9cdadbb` |
| Leave the hint-text overlap and ~99.2% HUD reading | — | Open issues list; README.md Known limitations | `0007b1f` |
| Author playtest findings | — | Playtester section | `0007b1f` |

**Evidence files:** baseline before any change — `evidence/mechanics-1790276710.21.json`, `evidence/keyboard-1790276712.29.json`; latest run — `evidence/mechanics-1790280443.662.json`, `evidence/keyboard-1790280445.224.json`; `evidence/build-manifest.json`; screenshots in `evidence/screens/`.
