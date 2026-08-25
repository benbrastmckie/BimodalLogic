# Implementation Plan: Task #477

- **Task**: 477 - T-A: Target-structure plumbing for the groupable-companion route
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/477_ta_qz_target_structure_plumbing/reports/01_qz-target-structure-plumbing.md`
- **Artifacts**: plans/01_qz-target-structure-plumbing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land `QZStructure` (carrier `ℚ ×ₗ ℤ`), its `toMonadic`/`toOrdered` projections, the `goodGroupable`
∃-notion, its two transfer lemmas, and the two endpoint corollaries, as a new module
`FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean`. The complete Lean content
already exists and compiles sorry-free with clean axioms as a research probe, so this is a
transcription-plus-documentation job, not a discovery job. Definition of done: `lake build` green,
`check-module-invariants.sh` C1–C11 all pass, five `#print axioms` checks report the clean
baseline, and the sole structural sorry (`countermodel_discrete`) count is unchanged.

### Research Integration

Report `01_qz-target-structure-plumbing.md` is integrated in full. The four findings that shape
this plan:

1. **The deliverable is pre-compiled.** `verification/qz_structure_probe.lean` (91 lines) holds
   every declaration, elaborates end-to-end, and reports `[propext, Classical.choice, Quot.sound]`
   on all five checked declarations. Phase 1 transcribes it; it does not re-derive it.
2. **Design ruling 1 — full carrier, not an `Option`-bounds interval.** `ZIntervalStructure`'s
   `lo hi : Option ℤ` representation must NOT be mirrored: ord-connected subsets of `ℚ ×ₗ ℤ` are
   provably not endpoint-determined (machine-checked witness at
   `verification/qz_interval_not_endpoint_determined.lean`), and an interval of the carrier is not
   a group, which T-C's `multiFamTaskFrameGen` requires. Mirror the sibling modules' **API shape**,
   not their representation.
3. **Design ruling 2 — no `veryGoodGroupable`.** At `k ≥ 2` the analogue is unsatisfiable
   (`noMaxOrder_of_kEquiv` / `noMinOrder_of_kEquiv` force the target's unboundedness onto any
   closed subinterval), so every theorem proved from it would be vacuous. The two corollaries that
   establish this — `noMaxOrder_of_goodGroupable`, `noMinOrder_of_goodGroupable` — DO land, as the
   guardrail.
4. **Build wiring.** C8 (aggregator convention) does not reach `WeakCanonical/` subdirectories, so
   no `GroupModel.lean` aggregator may be created. C6 (unreachable-module guard) does apply, so an
   explicit `-- CI edge only` import in `WeakCanonical.lean` is mandatory on the
   `DenseModelSurgery/` precedent. C9 forbids task-number citations in the module header.

Tactic facts carried forward from report §7 so the implementer does not re-derive them:
`Prod.Lex.right _ (by simp)` closes the `NoMaxOrder`/`NoMinOrder` goals — `by omega` **fails**
there, because it cannot see through `ofLex (toLex …)`. `noMaxOrder_of_goodGroupable` needs
`hQ.symm`, not `hQ`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only (it was not passed as `roadmap_path`, and no roadmap
phases are included). Line 56 records the Base frame-class row: exactly one reachable sorry
remains, `countermodel_discrete`; route (i) is refuted by a `ℤ ×ₗ ℤ` witness, and **route (ii),
direct construction over the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`, is the recommended
route**. This task lands the target-structure vocabulary for exactly that route. It advances no
roadmap item to done — the row stays open until the successor chain (T-B, T-C) discharges
`countermodel_discrete`. Do not edit ROADMAP.md in this task.

## Goals & Non-Goals

**Goals**:
- Land `QZStructure sig` with carrier `ℚ ×ₗ ℤ` plus `toMonadic`, `toOrdered`, and the
  `toOrdered_carrier` `rfl` lemma.
- Land `goodGroupable sig k M := ∃ Q : QZStructure sig, KEquiv sig k M (Q.toOrdered sig)`, with
  `goodGroupable_of_kEquiv` and `goodGroupable_of_orderIso`.
- Land the `NoMaxOrder`/`NoMinOrder (ℚ ×ₗ ℤ)` instances and the two `*_of_goodGroupable`
  corollaries as the §5 guardrail.
- Land the four `example … := inferInstance` carrier-gate lines that make the four
  `valid`/`SemanticConsequence` binders a compile-time invariant T-C inherits.
- Wire the new module into the `lake build` closure via an explicit `-- CI edge only` import.
- Write a repo-standard module header recording the Reynolds §8 p.185 anchor and both design
  rulings, so the reasoning survives without the specs/ artifacts.

**Non-Goals**:
- The companion lemma itself (that is T-B).
- Any edit to `countermodel_discrete` or its `sorry`.
- Re-attempting the O1 isomorphism or `succ_cofinal` — both settled negatively.
- The S1 carrier-generic refactor of the dense cantor machinery — retired for this branch.
- A `veryGoodGroupable` definition (see design ruling 2 — forbidden, not merely deferred).
- A `GroupModel.lean` aggregator (see C8 finding — forbidden, not merely optional).
- A `QZSegmentStructure` interval type — speculative surface area; add it in T-B if T-B's own
  planning discovers it is genuinely wanted.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missing `import Mathlib.Algebra.Order.Monoid.Prod` → `synthInstanceFailed` on the `IsOrderedAddMonoid` gate line | M | L | Import set is fixed at exactly three (report §6); Phase 1 transcribes it verbatim and the gate line fails loudly at build if dropped |
| Implementer "improves" the probe into an `Option`-bounds interval mirror per the task brief's literal wording | H | M | Design ruling 1 is a Goal/Non-Goal here and must be recorded in the module header with its machine-checked reason; the brief says mirror `ZIntervalStructure`, and this plan overrides that to mean API shape only |
| Implementer adds a `veryGoodGroupable` by symmetry with both pattern sources | H | M | Design ruling 2 is an explicit Non-Goal and a required header note |
| C6 fails — new leaf module falls out of the build closure with no consumer until T-B | M | M | Phase 1 adds the `-- CI edge only` import to `WeakCanonical.lean`; Phase 3 runs the invariant script that catches it |
| C9 fails — task-number citation in the module header | M | M | Header cites Reynolds §8 p.185 and the two sibling module paths as durable anchors; Phase 2 verification greps for the pattern |
| `by omega` re-attempted on the `NoMaxOrder` goal (fails; cost two iterations in research) | L | M | Recorded in Research Integration above; transcribe `Prod.Lex.right _ (by simp)` verbatim |
| Accidental increase in sorry or axiom count | H | L | Phase 3 gate re-runs C2 and C3 and the five `#print axioms` checks against the recorded baseline |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Land the module body and the build edge [COMPLETED]

**Goal**: `FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean` exists with the
probe's full declaration set, is inside the `lake build` closure, and `lake build` is green.

**Tasks**:
- [ ] Record the pre-change baseline: `lake build` exit code and job count; `grep -rn 'sorry'` census
      outside `Boneyard/` (expect exactly one bare `sorry`, `Transfer.lean` inside
      `countermodel_discrete`).
- [ ] Create directory `FormalSystem/Metalogic/WeakCanonical/GroupModel/`.
- [ ] Create `GoodGroupable.lean` with the standard four-line copyright block (copy the shape from
      `RealModel/GoodDense.lean:1-5`), then the exactly-three import set:
      `…IntegerModel.GoodStructures`, `…RealModel.GoodDense`, `Mathlib.Algebra.Order.Monoid.Prod`.
- [ ] Transcribe the probe body verbatim from
      `specs/477_ta_qz_target_structure_plumbing/verification/qz_structure_probe.lean`: namespace
      and `open`s, the four `example … := inferInstance` carrier-gate lines, `QZStructure`,
      `QZStructure.toMonadic`, `QZStructure.toOrdered`, `QZStructure.toOrdered_carrier`,
      `goodGroupable`, `goodGroupable_of_kEquiv`, `goodGroupable_of_orderIso`, the
      `NoMaxOrder`/`NoMinOrder (ℚ ×ₗ ℤ)` instances, `noMaxOrder_of_goodGroupable`,
      `noMinOrder_of_goodGroupable`. Drop the probe's five `#print axioms` lines and its probe-only
      top comment; keep everything else.
- [ ] Add the `-- CI edge only` import for the new module to
      `FormalSystem/Metalogic/WeakCanonical.lean`, with a comment on the `DenseModelSurgery/`
      precedent explaining that this is a leaf with no consumer until the companion lemma lands.
      Do NOT create a `GroupModel.lean` aggregator. Do NOT register it in
      `scripts/module-invariants-manifest.txt`.
- [ ] `lake build` → exit 0. Commit.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts (a) exactly two files touched — one new
`GroupModel/GoodGroupable.lean` and one edited `WeakCanonical.lean` — and (b) ~91 lines of
transcribed body. Confirm at implementation time with `git status --short` (expect exactly those
two paths) and `wc -l` on the new file before the header is added. If the transcription requires
any declaration not present in the probe, stop and record why — the research finding is that none
is needed.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean` - new; the full declaration set
- `FormalSystem/Metalogic/WeakCanonical.lean` - add one `-- CI edge only` import with comment

**Verification**:
- `lake build` exits 0; job count is baseline (2487) plus a small increase for the new module.
- `grep -c 'sorry' FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean` → 0.
- The new import appears in `WeakCanonical.lean` and no `GroupModel.lean` file was created.

---

### Phase 2: Write the repo-standard module header [COMPLETED]

**Goal**: The module carries a `/-! … -/` header matching the sibling modules' conventions, so that
the Reynolds anchor and both design rulings survive independently of the specs/ artifacts.

**Tasks**:
- [ ] Write the title and source anchor: Reynolds 1992, *An Axiomatization for Until and Since over
      the Reals without the IRR Rule*, §8 *"Doets' Theorem"*, printed **p.185** — the *good*
      definitional preliminaries. Quote the *"Say that `M` is good iff there is some `N ≡_k M` such
      that …"* line as the sentence `goodGroupable` transcribes. Do not re-derive the transcription;
      `GoodDense.lean:24-41` already holds the verbatim block and this module consumes it.
- [ ] Write a step-map table (source phrase → declaration in this module), on the
      `GoodDense.lean:95-108` pattern.
- [ ] Write the `## ADAPTED-FROM` section on the `GoodDense.lean:110-134` pattern, naming
      `IntegerModel/GoodStructures.lean` (`ZIntervalStructure`, `good`, `VeryGood`) and
      `RealModel/GoodDense.lean` (`RIntervalStructure`, `goodDense`, `veryGoodDense`) as the two
      sibling analogues, both **read, not edited**, by this module.
- [ ] Under "what changed and why it is not cosmetic", record design ruling 1: `ZIntervalStructure`
      works with `lo hi : Option ℤ` because every interval of `ℤ` is endpoint-determined; that is
      false at `ℚ ×ₗ ℤ` — `{x | (ofLex x).1 < 0}` is `Set.OrdConnected`, has no greatest element,
      and its complement has no least element, so no `Option`-endpoint pair denotes it. State the
      second reason too: an interval of the carrier is not a group, and the frame-side construction
      needs the group binders. Hence the full carrier.
- [ ] Record design ruling 2 as an explicit warning: no `veryGoodGroupable` analogue may be added,
      because at `k ≥ 2` the carrier's `NoMaxOrder`/`NoMinOrder` propagate through
      `noMaxOrder_of_kEquiv`/`noMinOrder_of_kEquiv` to force every closed subinterval to fail
      `goodGroupable`, making any such definition identically false and every theorem from it
      vacuous. Name `noMaxOrder_of_goodGroupable` and `noMinOrder_of_goodGroupable` as the
      guardrail that establishes this.
- [ ] Add a short note on why the third import is present: it is needed only by the
      `IsOrderedAddMonoid` carrier-gate line, and the gate is the point — it makes the carrier's
      admissibility as a duration group a compile-time invariant.
- [ ] Verify no task-number citation of any form (`task 477`, `task-477`, `#477`) appears anywhere
      in the file; cite the durable anchors (Reynolds §8 p.185, the two sibling module paths)
      instead. Rebuild the single module. Commit.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts one file touched and ~120–200 header lines (giving a
150–300 line total for the module, matching the task brief's estimate). Confirm with
`git status --short` (expect one path) and `wc -l` on the file. A total materially outside
150–300 lines means either the header is thin on the two rulings or it has drifted into
re-deriving content the siblings already hold — check which before proceeding.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean` - prepend the `/-! … -/` header

**Verification**:
- `lake build FormalSystem.Metalogic.WeakCanonical.GroupModel.GoodGroupable` exits 0 (the header is
  a Lean doc comment and does elaborate, so a single-module build is the in-phase check).
- `grep -niE 'task[ -]?477|#477' FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean`
  → no matches.
- The header contains both design rulings and names both sibling modules.

---

### Phase 3: Acceptance gate [COMPLETED]

**Goal**: Every acceptance criterion in the task brief is machine-checked and the results recorded,
with the sorry and axiom baselines demonstrably unchanged.

**Tasks**:
- [ ] `lake build` → exit 0. Record the job count against the 2487 baseline.
- [ ] `bash scripts/check-module-invariants.sh` → C1–C11 all pass. Confirm specifically: C2 (flagship
      axiom baselines) unchanged; C3 (sole structural sorry, asserted by content) unchanged; C6
      (the new module is reachable, i.e. the CI edge works); C8 (no aggregator expected or missing);
      C9 (no task-number citation).
- [ ] Run the five `#print axioms` checks — on `QZStructure.toOrdered`, `goodGroupable_of_kEquiv`,
      `goodGroupable_of_orderIso`, `noMaxOrder_of_goodGroupable`, `noMinOrder_of_goodGroupable`
      (fully qualified under `FormalSystem.Metalogic.WeakCanonical`) — each must report
      `[propext, Classical.choice, Quot.sound]`. Use the `lean_verify` MCP tool or a scratch file
      outside `FormalSystem/`; do NOT leave `#print axioms` lines in the landed module.
- [ ] `grep -rn 'sorry' FormalSystem/Metalogic/WeakCanonical/GroupModel/` → no bare `sorry`.
- [ ] Re-run the repo-wide sorry census and confirm it is identical to the Phase 1 baseline: exactly
      one bare `sorry` outside `Boneyard/`, inside `countermodel_discrete`.
- [ ] Record all gate results in the task summary. Commit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the sorry census is exactly one and the axiom set is
exactly the three-element clean baseline on all five declarations. Both are hypotheses inherited
from research and must be re-confirmed here against the Phase 1 pre-change baseline, not assumed.
If either differs, the phase is BLOCKED, not COMPLETED — do not adjust the baseline to match.

**Files to modify**:
- None (verification only; scratch verification files, if any, go under
  `specs/477_ta_qz_target_structure_plumbing/verification/`, never under `FormalSystem/`)

**Verification**:
- All of C1–C11 report pass.
- All five declarations report the clean three-axiom baseline.
- Repo-wide sorry census identical to the Phase 1 baseline.

## Testing & Validation

- [ ] `lake build` exits 0.
- [ ] `bash scripts/check-module-invariants.sh` — C1 through C11 all pass.
- [ ] `#print axioms` on all five checked declarations → `[propext, Classical.choice, Quot.sound]`.
- [ ] No bare `sorry` anywhere under `FormalSystem/Metalogic/WeakCanonical/GroupModel/`.
- [ ] Repo-wide structural sorry count unchanged at one (`countermodel_discrete`).
- [ ] No new axiom introduced (C2 flagship baselines unchanged).
- [ ] No `GroupModel.lean` aggregator exists.
- [ ] No task-number citation under `FormalSystem/` (C9).
- [ ] No `veryGoodGroupable` declaration exists.

## Artifacts & Outputs

- `FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean` — the new module
  (~150–300 lines: ~91 body plus header).
- `FormalSystem/Metalogic/WeakCanonical.lean` — one added `-- CI edge only` import with comment.
- `specs/477_ta_qz_target_structure_plumbing/summaries/01_*-summary.md` — execution summary
  recording the gate results.

## Rollback/Contingency

The change is additive and confined to two files, so rollback is a `git revert` of the phase
commits — nothing existing is modified except the one added import line in `WeakCanonical.lean`.
Deleting `GroupModel/` and that import line restores HEAD exactly.

Per-phase contingency:
- **Phase 1 build failure**: almost certainly the missing `Mathlib.Algebra.Order.Monoid.Prod`
  import (the `IsOrderedAddMonoid` gate line fails with `synthInstanceFailed` without it). If the
  failure is elsewhere, diff the transcription against the probe before improvising — the probe
  compiles as written.
- **C6 failure in Phase 3**: the CI edge is missing or misplaced in `WeakCanonical.lean`; add it
  next to the `DenseModelSurgery/` block, not at the top of the import list.
- **Any acceptance criterion failing**: mark the phase `[BLOCKED]` with the concrete failure
  recorded, and do NOT relax the criterion. There is no legitimate outcome of this task that
  increases the sorry count or the axiom set.
