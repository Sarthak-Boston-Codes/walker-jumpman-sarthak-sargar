Assignment: Assignment 1 - Extend Walker Jumpman
Student: Sarthak Sargar
Project name: walker-jumpman-ss
GitHub repository/folder URL: https://github.com/Sarthak-Boston-Codes/walker-jumpman-sarthak-sargar
Submitted commit SHA: (this commit — see Canvas submission note)
Game-source revision shown in the film: 31eca6a
Godot version and operating system: Godot 4.7.2 (stable) / Windows 11
Final film URL and filename: https://northeastern-my.sharepoint.com/:v:/g/personal/sargar_s_northeastern_edu/IQAI6TLJ44oVTpC0t40GsbD_ASeZmowyjVz6L6keweiPBq8?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=pLeb0A / claude-liam-walker-jumpman-walkthrough.mp4
Final film SHA-256: 2196cc0b98f354a57392acde2160b6af08f33842fd658a6e0bd4173991180696
Summary of my changes: Replaced the starter's rectangle-stack runner with an original character, "Cardinal," and added a new level section, "Two-Step Crossing," with two required-jump landings and a relocated finish.
Known limitations:
- Early full jump reaches Landing 1. A full held jump taken early off the original ledge (takeoff x ≈ 900–940) lands on Landing 1, so holding right for both Two-Step jumps can succeed. Accepted, not a bug — see CHANGE-BRIEF.md Revisions.
- Reduced beak-to-body contrast. The body color fix (orange `f07a2a`, for contrast against the spikes) lowered contrast between the yellow beak and the body to about 1.5:1. Not yet confirmed in live play.
- Hint text may overlap the committed jump. The jump from Landing 1 passes through the "Short hop. Then commit." hint. Whether this is distracting is not yet confirmed.
- HUD reads ~99.2% at flag trigger. The finish triggers when the collider touches the flag, slightly before the progress span ends. Cosmetic; not fixed.
