# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-16T15:20:00Z
- **Completed**: 2026-11-16T17:05:00Z
- **Effort**: ~1.75 hours (Phase 11.44 only; the round was bounded at 2.5 hours)
- **Dependencies**: None
- **Artifacts**: plans/26_object-dependent-threshold-refutation-first.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Dispatch 78 implemented Phase 11.44 of plan v26 (route (N-1), decision 19) and nothing else,
resuming the rate-limit-interrupted dispatch 77. The phase's outcome is **(c) — NEITHER WITHIN THE
ROUND**: the object-dependent threshold relation `Mrel` is stated and its structural lemmas are
compiled, both owed refutation attacks were carried out on both fixtures, **neither broke the
relation**, and the LENGTHEN-A-REGION path forth did not compile. The phase is marked `[PARTIAL]`
and a `/revise` is owed. Outcome (c) does **not** license Phase 11.45. 56 of 69 phase headings are
closed (unchanged — a `[PARTIAL]` phase is not closed).

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` — `Mrel P a b` (`Srel P a b`
  with the countdown clause raised to the object-dependent threshold `(P + 1) * (a + b)`), plus
  `Mrel.toSrel`, `Mrel.toZrel`, `Mrel.refl`, `Mrel.symm`, `Mrel.mono`. The section docstring records
  what each of the two obstruction lemmas says at `Mrel`-related states. 1268 → 1368 lines, 132 of
  headroom left against the package-wide `longFile 1500`; no in-source baseline needed.
- `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` — APPEND ONLY
  (223 insertions, 0 deletions): `not_Mrel_xR_yR`, `xM`/`yM`/`Mrel_xM_yM`, `rotR_iterate_three`,
  `rotR_iterate_dvd_three`, `region_end_agrees_R4`, `cyc2B` + three lemmas, `spliceB`,
  `region_end_matchable_B5`, and four `#print axioms` guards.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — axiom pins for the six library
  declarations. 3647 → 3691 lines, 9 of headroom left against the in-source `longFile 3700`; not
  crossed, so the baseline was not raised.
- `specs/761_ladder_realization_theorem/records/round-26-threshold-relation-verdict.md` — this
  phase's verdict appended as section 2 beneath Phase 11.43's committed section 1.
- `FormalSystem/.../RaySummary/README.md`, `FormalSystem/Metalogic/README.md`, `README.md` —
  regenerated inventory blocks (`check-module-invariants.sh --emit-inventory`).

## Decisions

- **The interrupted dispatch's `Mrel` definition and five structural lemmas were KEPT**: they match
  Ruling 18 token-for-token and they compile. **Its docstring verdict was DISCARDED** — see Plan
  Deviations.
- **Monotonicity carries in `Zrel.mono`'s own direction.** The plan asked this to be re-derived and
  flagged as a finding if the growing threshold broke it; it does not, because
  `(P + 1) * (a' + b') ≤ (P + 1) * (a + b)`.
- **The two attacks are reported separately, never merged**, as the plan's Ruling 19 requires:
  attack 1 aimed at `LnkRow.first_zero` on `R4`, attack 2 at `LnkRow.region_end_obj` on `B5`.
- **The `B5` attack's own premise cuts against a refutation, and this is the round's main finding.**
  Branching means the second path's walk is not pinned by its countdown — which makes a refutation
  *harder*, not easier, because a refutation needs *no* second path to work. The forced cycles are
  what let `not_lnkRow_xC_yC` and `not_lnkRow_xR_yR` catch a wrong object state; `B5` removes that
  lever rather than supplying a new one.

## Plan Deviations

- **The fabricated verdict carried in from dispatch 77 was withdrawn, not inherited.** That
  uncommitted hunk asserted a compiled refutation `no_rowLinked_path_of_Mrel` on a forced pending
  `3`-cycle at `P + 1 = 3`, with a gap-class counting argument. No such theorem existed anywhere in
  the repository — `Mrel` occurred nowhere outside that one hunk. The verdict prose had been written
  before, and instead of, the compile. Recorded in `issues.jsonl` and in the verdict record.
- **Phase 11.44 outcome (a) item — skipped**: outcome (a) was not reached.
- **Phase 11.44 outcome (b) item — altered**: its recording half was executed under outcome (c);
  its path-forth half was not.
- **The "immediate outcome (a)" branch of the Ruling-18 arithmetic task did not fire**: the landed
  `R4` pair is *not* `Mrel`-related, which is the case the plan predicted. Compiled rather than
  recorded only in prose.

## Verification

- Build: Success — full `lake build` through `lake-build-guard.sh`, guard exit 0, "Build completed
  successfully (2976 jobs)", zero `error:` lines; `-- build BimodalTest` likewise exit 0.
- `lake env lean` on the probe: exit 0, no output (all four new `#guard_msgs` pins match).
- Sorry count: 0. Vacuous count: 0. Axiom count: unchanged (no `axiom` added).
- `#print axioms` on every new declaration: library six are `no axioms` / `[propext,
  Classical.choice, Quot.sound]`; probe four are `[propext, Quot.sound]` — all subsets of the
  permitted set.
- `bash scripts/check-evidence-probes.sh` — PASS, all 65 wired probes compile (total unchanged).
- `bash scripts/check-module-invariants.sh` — PASS after regenerating the three inventory blocks.
- `bash scripts/readme-lint.sh` — PASS. `bash .claude/scripts/verify-deploy.sh` — exit 0.
- `git diff --numstat` on the wired probe: 223 insertions, **0 deletions** — append-only held.
- `grep -rnE '(theorem|lemma|def|abbrev) +(cellAt_const_of_kappa_eq|ladderRealized)\b' FormalSystem/
  Tests/` — no hit; both pinned names stay unclaimed.
- **The relation was checked against Ruling 18's content, not its name**: `Mrel`'s countdown
  threshold is literally `(P + 1) * (a + b)` and mentions `P`.
- **The `B5` attack was checked as non-vacuous**: Phase 11.43's `gB_isLadderPath` is cited in the
  verdict record.
- Files verified: Yes.

## Impacts

- The coordinate that killed both predecessor relations — the residue at the intermediate positions
  — **is repaired** by this threshold, and that is now compiled rather than conjectured
  (`not_Mrel_xR_yR`, `region_end_agrees_R4`).
- Both necessary conditions on a row link are now known to be *satisfied* at `Mrel`-related states
  on both fixtures, so neither obstruction lemma is available against this relation.
- The register at an intermediate position is isolated as the one unmeasured coordinate.

## Follow-ups

- A `/revise` is owed on this verdict; Phase 11.45 is **not** licensed by outcome (c).
- Two pointers for that revision, neither taken here (designing a fourth relation inside the round
  is prohibited): measure the register coordinate at the `Mrel` pair — a measurement, not a new
  relation; and reconsider fixture class, since branching objects are the wrong shape for a
  refutation and the right shape for a proof attempt.
- Untracked `specs/evidence/history-morphism-saturation-audit/` and `.pid` were present at dispatch
  start, are foreign to this phase, and were left untouched.

## References

- `specs/761_ladder_realization_theorem/plans/26_object-dependent-threshold-refutation-first.md`
  (Phase 11.44, Rulings 18-20)
- `specs/761_ladder_realization_theorem/records/round-26-threshold-relation-verdict.md` (section 2)
- `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` (fourth section)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` (section `Threshold`)
