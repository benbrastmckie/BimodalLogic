# Task 517 — Phase 3 handoff (task complete)

**Next action**: none — all three phases closed. Orchestrator postflight.

**What landed**: the prose coherence pass, no Lean surface and no rebuild.
- `specs/paper-definitions-of-record.md` — dated "Rename absorption (2026-09-02)" entry, recording
  both re-keyed anchors and their checksums, why this is a key migration and not a drift
  correction, why the sentinels are not re-pinned, and what was deliberately left alone.
- `latex/subfiles/02-Semantics.tex` — the `⊇` qualifier at 3 sites (~77, ~85, ~96), not the 2 the
  plan named.
- `Tests/BimodalTest/Semantics/README.md` — both missing file-table rows plus a Coverage bullet.

**Verification**: `check-module-invariants.sh` exit 0, ALL CHECKS PASSED (C12 in particular, since
this phase adds slash-shaped source paths to markdown). `git grep -io "spherical"` outside
`specs/` still 3. No `.lean` file touched, so no rebuild.

**Left open, deliberately**: the record file's entry heading ``def:directed`` — directed family
(used by Spherical)`` still says *Spherical*. It is the record's own navigation rather than quoted
paper text, so the historical-record rule does not protect it, but it is outside this task's
declared scope. Flagged in the absorption entry and in the summary.
