# Implementation Summary: Task #745

- **Task**: 745 - Requirement (C) of the ray-product verdict: Hit-level completeness with a computable bound -- settle HitPresented first
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T23:51:39Z
- **Completed**: 2026-10-09T00:18:00Z
- **Effort**: ~0.45 hours (phase 1 ~0.2, phase 2 ~0.25)
- **Dependencies**: None ((S) is an independent sibling record; (W) is downstream of both)
- **Artifacts**: plans/01_hit-presented-model-a.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Two single-phase dispatches of the eight-phase plan, each confined to one phase per its dispatch's
phase mission. **Phase 1** (dispatch 5) states the Hit-level hypothesis `HitPresented` in the
library beside `Presented` and records that it is strictly weaker, via
`hitPresented_of_presented`; both land sorry-free in
`FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` with the plan's required axiom foot.
**Phase 2** (dispatch 6) creates the evidence probe
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` with its full header, the
model-A fixture transcription, and the step-path classification `path_classify`. Phases 3-8 — the
splice identification and closure-letter read-out, the truncation bound, the presentation data,
the run characterization, the assembly, and the wiring/pins/docs/bound-verdict — are NOT attempted
and remain `[NOT STARTED]`.

Nothing is claimed about requirement (C) itself by either phase. `HitPresented` is a
*declaration*, not yet a *discharged* hypothesis: no model satisfies it in the tree, and the
fixture-level discharge is phases 3-7's work. Phase 2 lands no statement mentioning `HitCl`,
`hitOf` or `HitPresented` at all — what it lands is the rigidity fact the discharge will rest on.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — +44 lines inside
  `section Presented`, after `hit_eq_hitOf_of_presented`:
  - `HitPresented` — a `def … : Prop`, body `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`:
    (C) at the HIT level, an equality of family-triple sets rather than of trace sets.
  - `hitPresented_of_presented` — `Presented → HitPresented` at every depth `k ≥ 1`, as the term
    `hit_eq_hitOf_of_presented M τ t φ lab step k hk hP`.
- `typst/generated/status.typ` — regenerated line count (347508 → 347552, exactly the +44 above)
  and commit/date stamp. Not a plan-declared file; staged because the blocking pre-commit gate's
  own remedy requires it (see Plan Deviations).
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — new, 276 lines (phase 2):
  - a 65-line header carrying every disclaimer the phase's task list mandates — what is
    established, the fixture, the argument in two sentences, the no-bound / forward-only /
    no-decidability / nothing-about-general-regular-ℤ-models limits, the non-generality of the
    fixture (model A's splices are eventually constant in both directions), the explicit statement
    that `Probe735.not_presented` is neither weakened nor retired, the decision held in place, the
    axiom record, and the compile line;
  - the fixture transcribed from `presented-not-complete.lean` (transcribed, never imported):
    `St`, `a`, `b`, `pa`, `Fp`, `RA`, `RA_fwd`, `RA_bwd`, `RA_aa`, `RA_ab`, `RA_bb`, `FA`,
    `instFARegular`, `ab_ne`, `MA`, `stayA`, `stayA_state`, `jump`, `jump_state`, `p_iff`,
    `Fp_iff`, `jump_p_iff`, `jump_Fp`;
  - the step-path classification: `stepA`, `time_eq` (the time component advances by one, so it is
    pinned by its value at `t`), `bwd_a` (`a` is reachable only from `a`, so the slice is pinned at
    `a` at and before the seam), `fwd_dichotomy`, `fwd_absorb` (`b` absorbs), and `path_classify`
    — every step path through `(t, a)` is the constant `a`-path or an `a`-then-`b` jump path with
    jump time `w ≥ t`;
  - a `#print axioms` foot over `path_classify`, `stayA` and `jump`.

## Decisions

- `HitPresented` is a `def … : Prop` whose body IS its pinned statement, so
  `hitPresented_of_presented` closes by definitional unfolding to `hit_eq_hitOf_of_presented`'s
  conclusion — a bare term application, no tactic block and no `unfold`/`show` step.
- Both docstrings carry the plan's three disclaimers explicitly: fixture-only, forward-only, and
  non-constructive (`∃ L` out of `Set.Finite.bddAbove`, so no bound). Neither mentions
  decidability, a decision procedure, or `PlusValidZTime` in any form — audited mechanically over
  the new block, whose only `Decidab`-shaped hits are the `[DecidableEq Q]` instance binders the
  pinned signature requires.
- Both docstrings state that `Probe735.not_presented` is NOT weakened or retired: that probe
  refutes a TRACE-set equality, `HitPresented` is a FAMILY-TRIPLE-set equality, the pumped trace's
  forward type is what the refutation turns on, and a type-level demand gives that argument
  nothing to bite on — so both hold of the same fixture at once.
- Phase 2 is a transcription, not a re-derivation. The research dispatch's compiled scratch file
  `rigid745.lean` was still present in the session scratchpad, so every tactic choice the report
  recorded as load-bearing transcribed verbatim and compiled green on the first attempt:
  `Int.induction_on` with case names `zero`/`succ`/`pred`; `push_cast at h ih ⊢` BEFORE the
  `show … by ring` rewrite in `bwd_a`; `simp only [not_exists]` in place of deprecated `push_neg`;
  an explicit `IsStepPath` hypothesis per theorem (this toolchain does not auto-include a
  propositional `variable`). No proof search was run and no alternative route was considered.
- Phase 2's `#print axioms` foot was added now rather than deferred to phase 7's assembly, because
  phase 2's own task list requires the header to carry "the axiom record" and an unverified record
  would have been prose. Phase 7 extends the foot to the headline.

## Plan Deviations

- **Task 1.3** (the `HitPresented` docstring) altered: the plan directs the docstring to say the
  hypothesis "is discharged in this tree … by the wired probe
  `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`". That file does not exist
  at phase 1 — the plan's own phase 2 creates it and phase 8 wires it — so the reference is
  written as a forward reference ("landed by this record's later phases"). Every other element of
  the item (Hit-vs-trace weakening, `presented_localRun` unavailable, finiteness by
  `kType_finite`, fixture-only, non-constructive, no bound, `Paper: —` anchor) is verbatim.
  Annotated inline on the plan's checklist item.
- **Phase 1 Scope Hypothesis** overrun, not a step deviation: predicted ~15-25 added lines,
  actual 44. The two declarations plus bodies are 12 lines; the remaining 32 are docstring prose
  the phase's own task list mandates in detail. Recorded in `issues.jsonl`.
- **Out-of-scope staged path**: `typst/generated/status.typ`. The pre-commit
  `typst-sync-check.sh` Check 2 gate BLOCKED the phase commit because the committed
  `formalsystem-line-count` lagged live by exactly the 44 lines this phase added. The gate's
  `--no-verify` bypass is explicitly reserved for drift caused by *another* writer, so it did not
  apply; the documented remedy (full `lake build`, then `typst-sync-check.sh --fix`, then stage
  the file) was run instead. Every later phase of this record that adds Lean lines will hit the
  same gate, and this path is not in the plan's `file_scope` — recorded in `issues.jsonl` so
  phases 2-8 expect it.
- **Phase 2 fixture transcription** altered: the plan's transcription list names 19 identifiers;
  `RA_aa`, `RA_ab`, `RA_bb` and `ab_ne` were transcribed as well, because `stayA`, `jump` and
  `bwd_a` do not elaborate without them. Also `a`, `b` and `pa` are landed as `def`, as in
  `presented-not-complete.lean` which the item names as the transcription source, rather than as
  the `abbrev` the plan's `## Lean Challenge Statements` block shows — that block states in its own
  preamble that the `abbrev` form was a plan-time device to make the declared identifier set equal
  the `**Goals**:` set, and none of `St`/`a`/`b`/`pa`/`Fp` is a pinned goal. Every identifier that
  IS pinned landed at its pinned signature with a real body. Annotated inline on the checklist.
- **Phase 2 Scope Hypothesis** overshoot, not a step deviation: predicted ~200-230 lines (header
  ~60, fixture ~50, classification ~110); actual 276 (header 65, fixture ~100, classification
  ~96). Header and classification estimates were accurate; the fixture estimate was low by ~50,
  because `jump`'s well-definedness proof plus the three `RA` step facts it and `stayA` consume do
  not fit in 50 lines. No scope beyond the plan's enumerated items was added. Recorded in
  `issues.jsonl`.
- **The pre-commit gate did NOT fire for phase 2**, refining phase 1's expectation: the
  `typst-sync-check.sh` Check 2 gate tracks `formalsystem-line-count`, and the probe lives under
  `specs/`, outside `FormalSystem/`. Phases 3-7 touch only that probe, so they will not hit the
  gate either; phase 8's `Tests/` edit may.

## Verification

- Build: Success. Scoped `FormalSystem.Metalogic.Decidability.RaySummary.Trace` (guard exit 0,
  1929 jobs); the two plan-enumerated direct dependents
  `FormalSystem.Metalogic.Decidability.RaySummary` (guard exit 0, 1931 jobs) and
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (guard exit 0, 2178 jobs); and the full project
  (guard exit 0, 2836 jobs, `Build completed successfully`). Zero `error:` lines across every
  captured stream. `Trace.olean` is newer than `Trace.lean`.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
- Sorry inventory: empty. None introduced, none inherited.
- Vacuous count: 1, unchanged from `HEAD~1` and pre-existing —
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, where
  `intTimeHistory.domain t` genuinely reduces to `True`, so `trivial` is the honest proof. Zero
  introduced by this phase; the baseline is reported rather than rounded to 0.
- Axiom count: 14, unchanged from `HEAD~1` (verified by `git grep` at both revisions). No `axiom`
  added.
- Axiom foot: `#print axioms …hitPresented_of_presented` reports exactly
  `[propext, Classical.choice, Quot.sound]` — the list the plan's Phase 1 verification requires.
- Statement fidelity: both signatures confirmed against the plan's
  `## Lean Challenge Statements` entries by `#check @…` against the live build — same binders,
  same instance binders, same order, same conclusion.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

### Phase 2 verification (dispatch 6)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  through `lake-build-guard.sh`, detached, guard exit 0. Captured output is exactly the three
  `#print axioms` info lines — zero errors, zero warnings.
- Full project build re-run after the phase: guard exit 0, `Build completed successfully
  (2836 jobs)`, zero `error:` lines over both captured streams, `Trace.olean` newer than
  `Trace.lean`. Phase 2 touched no file in the Lake build graph (the probe is under `specs/`,
  which no Lake target root reaches), so this re-run confirms no regression rather than new
  coverage.
- Sorry count: 0, repo-wide, re-run via `lean-sorry-census.sh --cross-check` over all eight
  resolved source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`,
  `cross_check: MATCH`. `grep -c sorry` on the probe is 0.
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Axiom foot, observed not predicted: `Probe745.path_classify`, `Probe745.stayA` and
  `Probe745.jump` each report exactly `[propext, Classical.choice, Quot.sound]`.
- Statement fidelity: `path_classify`'s landed signature was extracted from the probe and from the
  plan's `## Lean Challenge Statements` block and diffed mechanically — byte-identical, no added
  hypothesis, no specialized quantifier, no weakened conclusion.
- `lean-challenge-snapshot.sh --check`: UNAVAILABLE, not green. No snapshot manifest exists at
  `specs/745_hit_level_completeness_computable_bound/challenge/manifest.json` (none was taken at
  plan time), so the script refuses. The plan lists this check as ADVISORY; the mechanical diff
  above stands in its place for the one signature this phase lands.
- `Probe735.not_presented` untouched: `presented-not-complete.lean`'s last commit is still task
  735's own wiring commit, and nothing in the new probe imports, weakens or contradicts it.

## Impacts

- `path_classify` is the rigidity fact the whole positive construction rests on: it says the
  seam's step paths form a one-parameter family indexed by `w ≥ t` plus the constant path, and
  nothing else. Phase 3 turns it into a statement about the seam's SPLICES (`splice_classify`) via
  `pathFibreEquiv`/`seamOmegaEquiv` and `WorldHistory.ext_state`.
- The probe is NOT yet in any gate: it lives under `specs/`, which no Lake target root reaches, so
  `lake build` never compiles it and it can rot silently until phase 8 wires it into
  `scripts/check-evidence-probes.sh`. Until then its only check is the explicit `lake env lean`
  compile line in its own header.
- `HitPresented` is now a declaration in `FormalSystem.Metalogic.Decidability.RaySummary`, so
  phases 2-7's probe can discharge a library name rather than a local one, and the ray-product
  verdict's requirement (C) has a formal statement to be measured against.
- `hitPresented_of_presented` fixes the hypothesis ordering formally: anything proved under
  `Presented` transfers to `HitPresented` at `k ≥ 1` for free, so the two hypotheses need not be
  carried separately downstream.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` now contains a FALSE claim in three
  places — the `(C)` requirements-table row and two prose occurrences say `HitPresented` "is not
  a declaration in this tree". Phase 8 owns that README update; flagged in the phase handoff.

## Follow-ups

- Phases 3-8 of `plans/01_hit-presented-model-a.md`, all `[NOT STARTED]`. Phase 3
  (splice-to-history identification and the closure-letter read-out) is next and touches only the
  probe file. Its first obligation is to re-resolve `seamOmegaEquiv`, `SeqPair`, `ZPathFibre`,
  `pathFibreEquiv`, `spliced` and `WorldHistory.ext_state` BY NAME, and to re-derive
  `(plusSubformulaClosure Fp).card` by `#eval` — that figure is CARRIED-UNVERIFIED from the report
  and the plan assigns its re-derivation to phase 3, not earlier.
- Phase 6's run characterization remains the plan's single Medium-confidence, uncompiled link. If
  it cannot be carried out as written, the plan requires marking it `[BLOCKED]` rather than
  substituting the rejected `mem_hitOf_iff_live` route or weakening the pinned statement.
- Phase 8 owes: the README verdict update, `docs/theorem-index.md` rows for both new
  declarations, axiom pins in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` in the
  same commit as the index rows, and the recorded bound verdict. Both docstrings already end with
  a `Paper: —` anchor line so the index rows are admissible when they land.
- The `typst-sync-check.sh` Check 2 gate blocks a commit only when `FormalSystem/` line counts
  drift; phase 2 confirmed it does not fire for the `specs/`-resident probe, so phases 3-7 need
  not budget for it. Phase 8's `Tests/` axiom-pin edit may still trip it.
- No Challenge snapshot manifest exists for this record, so the advisory
  `lean-challenge-snapshot.sh --check` drift gate is unavailable for all 17 pinned identifiers.
  Each phase has been diffing its own landed signature against the plan's pin by hand instead.

## References

- `specs/745_hit_level_completeness_computable_bound/plans/01_hit-presented-model-a.md` — the plan,
  Phase 1 and the `## Lean Challenge Statements` pins.
- `specs/745_hit_level_completeness_computable_bound/reports/01_hit-level-completeness-probe.md` —
  the research the plan executes.
- `specs/745_hit_level_completeness_computable_bound/handoffs/phase-1-handoff-20261008T235902Z.md`
  and `handoffs/phase-2-handoff-20261009T001229Z.md` — the two phase-end handoffs, each with its
  next action and carried constraints.
- `specs/745_hit_level_completeness_computable_bound/issues.jsonl` — the scope-hypothesis overrun
  and the pre-commit gate collision.
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — the two new declarations.
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — the new probe: header,
  fixture, and `path_classify`.
- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` — `Probe735.not_presented`,
  the trace-level refutation these docstrings and the new probe's header are careful not to
  weaken, and the transcription source for the fixture.
