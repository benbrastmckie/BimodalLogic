# Implementation Plan: Stability Condition (C5) on the Branching Witness Frame

- **Task**: 690 - Build the stability condition (C5) `StabFaithful` on the branching witness frame
- **Status**: [IMPLEMENTING]
- **Effort**: 41 hours
- **Dependencies**: None blocking. Territory overlap with concurrent tasks 623 and 684 on the
  registration/aggregator files — see Risks & Mitigations R1 and Phase 22.
- **Research Inputs**: `specs/690_stability_condition_over_branching_frame/reports/01_stability-condition-branching-frame.md`
- **Artifacts**: plans/01_stability-condition-branching-frame.md (this file), summaries/01_stability-condition-branching-frame-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Route 1 of the research report, as chosen by the recorded user decision: state (C5)
`StabFaithful` natively over `PlusFormula.stab` on an L⁺-indexed certificate, built on a
**label-free `SharingSkeleton`** so that the 1,065 already-green, label-agnostic lines of
`Sharing/{Basic,Thread,Frame,Histories}.lean` are reused rather than duplicated. The shipping
deterministic bi-lasso certificate and its JSON export contract are unchanged in name, meaning
and shape; the L⁺ certificate is a new, parallel export that a consumer adopts only when it
wants `⊡`. Route 2 (atomization, which would add a pairing field to the shipping certificate) is
explicitly not taken.

The condition itself is settled and is not re-litigated here (research D1):

```lean
∀ (i : Fin S.lassos.length) (u : ℤ) (φ : PlusFormula),
  PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Δ) →
    (PlusFormula.stab φ ∈ S.L i u ↔ ∀ j, S.skeleton.share u i j → φ ∈ S.L j u)
```

It quantifies over `Fin S.lassos.length` at one time, never over walks, so decidability is
preserved by construction: the decision procedure is the landed (C0) `AtomCoherent` template of
`Sharing/Decide.lean` with `Formula.atom` replaced by `PlusFormula.stab`, against the same
window.

**What makes (C5) a pinned obligation rather than a signature.** The dispatch's hard constraint
is that a `sorry`-bodied `def` carrying a prose statement is not a pinned obligation. Three
things pin it here, and the task is not done until all three are green:

1. `plusTruth_iff_mem` (Phase 19) — the `stab` case of the agreement theorem *consumes*
   `StabFaithful` as a hypothesis and cannot be discharged without it.
2. `stabFamily_separates` (Phase 21) — a concrete two-lasso family on which `Fp` is labelled and
   `⊡Fp` is not, so the condition is non-vacuous and strictly stronger than the `box` clause.
3. `stabFaithful_diagonal` (Phase 21) — on the deterministic diagonal (C5) collapses to
   `⊡φ ↔ φ`, recovering `PlusDeterminism.stab_iff_of_deterministic` inside the device and
   showing the branching substrate is what makes the condition bite.

**Definition of done.** `lake build` green from clean, zero new `sorry`, zero new axioms beyond
`[propext, Classical.choice, Quot.sound]`, the deterministic path byte-identical (no content
diff, `#print axioms` unchanged, `WitnessFamily/Examples.lean`'s `#guard`s still fire), and the
thirty-four pinned declarations below all elaborating with real proofs.

**Phase structure and the recorded "seven phases".** The user decision describes Route 1 as
"seven phases"; that is the research report's seven **stages** A–G. Those stages are preserved
verbatim as the grouping below, decomposed into 22 numbered phases so that each fits one agent
run (~100–500 lines) and none exceeds two hours. No stage is added, dropped or resequenced.

### Research Integration

- **D1 (statement settled)**: adopted verbatim; no phase re-derives (C5)'s shape.
- **D5 (cost correction)**: the dispatch's "≈2,257 lines of `Formula`-side closure analogue" is
  corrected to ≈250 lines — the certificate stack imports only
  `Syntax/SubformulaClosure/Closure.lean` and consumes nine declarations from it. Phases 6–7 are
  sized against the corrected figure, carried as a Scope Hypothesis.
- **F4 (label-free substrate)**: `Sharing/{Basic,Thread,Frame,Histories}.lean` use `Formula`,
  `.L`, `.lab` and `.bx` **zero** times (re-measured in this plan's preparation: 1,065 lines,
  all four counts zero). This licenses Stage A, Phases 2–5.
- **F2 (decidability template)**: (C5) has (C0)'s quantifier signature — one representative map,
  one label row — so Phase 15 is a line-for-line transcription against the same
  `cohWindowLo`/`cohWindowHi` window and the same `exists_window_repr`. No new window arithmetic.
- **F3 (the `stab` truth case)**: the `box` case with `share`-gating; `Thread.const` +
  `const_idx` forward, `total_eq_thread` + `share_of_cls_eq` backward. Phase 19.
- **F7 (non-vacuity blueprint)**: `Metalogic/Independence/StabUndefinable.lean`'s `⊡Fp`/`Fp`
  separation, transcribed to a two-lasso family. Phase 21.
- **D2 (polymorphism rejected)**: accepted; no phase introduces a type parameter on
  `LabelledLasso`/`WitnessFamily`.
- **D3 (no `Encoding` in the condition)**: honored — (C5) quantifies over `PlusFormula` gated by
  `plusClosureOf` membership, which is a `Finset PlusFormula`, so every instance computes and no
  phase introduces `open Classical` into a decision path.
- **R3 (Fulfil variance)**: the report's instruction that Stage E's first objective be a
  *measurement* is honored as Phase 1, whose output gates Phases 16–17's budget.

### Prior Plan Reference

No prior plan for this task; this is round 1. The superseded plan of task 683
(`specs/683_state_sharing_witness_structure_and_c3/plans/01_state-sharing-witness-structure.md`)
is reference context only and no phase is copied from it. Three lessons are carried forward:
(i) its effort calibration — thirteen phases delivered the branching substrate at ~23.5 hours, so
the ~2,400–3,900 new lines here calibrate to ~41 hours; (ii) its Phase 6 closed as
`[COMPLETED WITH EXCLUSIONS]` precisely because (C5) was not stateable at `Formula`, which is the
gap this plan closes; (iii) its Challenge-Statements discipline — declare the new structures in
the block so every later statement elaborates — is reused.

### Roadmap Alignment

`roadmap_path` was not provided in the delegation context, so no roadmap consultation was
dispatched and no roadmap phases are included. `specs/ROADMAP.md` exists in the repository.
Treat roadmap alignment as unassessed rather than as none.

## Goals & Non-Goals

**Goals**:

Pinned Challenge-module identifiers. `lean-challenge-snapshot.sh` cross-validates its declared
set against exactly the backticked, undotted tokens in this list, so the list is written at that
granularity; the fully qualified members of each follow below.

- `SharingSkeleton` — Stage A's label-free branching substrate
- `SharingWitnessFamily` — the existing branching family, which gains the skeleton projection
- `PlusFormula` — the L-plus inductive, which gains a subformula recursion
- `plusSubformulaClosure` — the single-formula L-plus closure
- `plusClosureOf` — the context-level L-plus closure the certificate is indexed by
- `PlusLabelledLasso` — the L-plus labelled bi-lasso
- `PlusWitnessFamily` — the L-plus certificate and its label-pool conditions
- `PlusSharingWitnessFamily` — the branching L-plus certificate, where (C5) lives

Fully qualified, the thirty-four pinned declarations are: `SharingSkeleton.share`,
`SharingSkeleton.Thread`, `SharingSkeleton.frame`, `SharingSkeleton.hist`,
`SharingSkeleton.total_eq_thread`, `SharingWitnessFamily.skeleton`,
`PlusFormula.subformulas`, `PlusLabelledLasso.lab`, `PlusWitnessFamily.mainIdx`,
`PlusWitnessFamily.L`, `PlusWitnessFamily.PlusBoxFaithful`, `PlusWitnessFamily.PlusTarget`,
`PlusWitnessFamily.PlusRefutes`, `PlusSharingWitnessFamily.skeleton`,
`PlusSharingWitnessFamily.PlusAtomCoherent`,
`PlusSharingWitnessFamily.PlusLocalCoherentShare`,
`PlusSharingWitnessFamily.PlusThreadFulfilling`, `PlusSharingWitnessFamily.StabFaithful`,
`PlusSharingWitnessFamily.stabFaithful_share_congr`,
`PlusSharingWitnessFamily.decidableStabFaithful`, `PlusSharingWitnessFamily.model`,
`PlusSharingWitnessFamily.plusTruth_iff_mem`, `PlusSharingWitnessFamily.PlusCertifies`,
`PlusSharingWitnessFamily.decidablePlusCertifies`,
`PlusSharingWitnessFamily.plusRefutes_of_certifies`, `PlusSharingWitnessFamily.stabFamily`,
`PlusSharingWitnessFamily.stabFamily_separates`,
`PlusSharingWitnessFamily.stabFaithful_diagonal`, plus the five structures and closures named
undotted above.

Beyond those pinned declarations the phases below also deliver supporting plumbing (the periodic
decoding lemmas re-sited on the skeleton, the L-plus subformula projections, the position-graph
re-index, the window-collapse congruences, and README/theorem-index updates). Those carry no
pinned statement and are therefore not listed as Goals identifiers.

**Non-Goals**:
- Any change to the shipping deterministic certificate's fields (`back`, `mid`, `fwd`, `bx`,
  `lassos`, `repBack`, `repMid`, `repFwd`) or to its JSON export contract. Route 2's pairing
  field is explicitly excluded by the recorded user decision.
- Stating (C5) at `FormalSystem.Syntax.Formula` in any form, vacuous, box-shaped or otherwise.
- A completeness half: no claim that every L⁺ countermodel compresses to a
  `PlusSharingWitnessFamily`, and no `Decidable (PlusValidZTime φ)` assembly.
- An L⁺ `SemanticConsequenceIn` relation and its `not_consequence_ztime` corollary. The
  deliverable interface is `PlusRefutes`, the joint-countermodel existential, mirroring
  `WitnessFamily.Refutes`.
- Any polymorphic (type-parameterized) rewrite of `LabelledLasso`/`WitnessFamily` (research D2).
- Any `sorry`, strategic or otherwise. This is not a skeleton plan
  (`plan_metadata.skeleton: false`); `## Planned Strategic Sorries` is deliberately absent.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1. Territory collision with tasks 623/684 on `FormalSystem.lean`, `Decidability.lean`, `WitnessFamily.lean`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh` | H | H | All new modules are written and built first; every registration file is touched only in Phase 22, re-read immediately beforehand, staged as named single files (never a directory or glob `git add`), and committed separately. A foreign commit, foreign uncommitted modification, or a build this task did not start: STOP and report after checking `git log`. |
| R2. Stage A (Phases 2–5) must be provably behaviour-preserving on the shipping path | H | M | Every existing name and statement stays in place as a thin re-export; acceptance is green `lake build`, unchanged `#print axioms` on every landed goal, `WitnessFamily/Examples.lean`'s `#guard`s still firing, and no content diff in any downstream file. On any failure, revert Stage A and proceed by duplicating the 1,065 lines onto the L⁺ side — costs lines, risks nothing on the deterministic path. |
| R3. Phases 16–17 (`Fulfil.lean` re-index) are the wide-variance item: ≈500 lines if the position graph factors onto the skeleton, ≈1,700 if not | H | M | Phase 1 is a measurement, not a transcription, and its result is a hard gate: no budget is committed for Phases 16–17 before the measured number exists. If the measurement says the position graph does not factor, Phase 16 splits into 16.1/16.2 at implementation time and the plan is revised rather than overrun. |
| R4. Module-invariant C8: every subdirectory needs exactly one sibling aggregator | M | H | New subdirectory `PlusWitnessFamily/` ships its sibling `PlusWitnessFamily.lean` in the same commit (Phase 22); `bash scripts/check-module-invariants.sh` runs before any phase is declared green. |
| R5. Axiom census (C2/C14) and dead-declaration scan (C17) | M | M | Every new declaration goes through the same machinery as its (C0)/`box` analogue, which already meets the census. Phase 22 adds the new goals' census lines and confirms every new base identifier is referenced outside its declaring line (or is an `instance`, which C17 excludes). |
| R6. Choice-freedom regression: an `open Classical` or a `Classical.choice` leaking into a decision path would break the "all instances compute" invariant | M | L | Research D3. No phase introduces `open Classical` into `PlusWitnessFamily/Decide.lean` or `Fulfil.lean`; Phase 20 confirms `decidablePlusCertifies` by `inferInstance` in an `example`, exactly as `Sharing/Agreement.lean` does today. |
| R7. Deploy-freshness: the deployed `.claude/` tree is stale for `core`, `lean`, `typst` | L | H | Any phase relying on a documented `.claude/` command verifies it against the source store named by `.claude-extensions.json`, or redeploys via `bash .claude/scripts/deploy-headless.sh`. Never hand-patch under `.claude/**`. |
| R8. Effort overrun on a 41-hour, 22-phase plan exhausting the per-run work-cycle budget | M | H | Every phase ends green and committed (`per-substep` except where `atomic-batch` is declared), so re-invoking `/orchestrate` resumes at the next phase with no lost work. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 6 | -- |
| 2 | 2, 7 | 1; 6 |
| 3 | 3, 8 | 2; 7 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 9 | 5, 8 |
| 7 | 10, 11, 12 | 9 |
| 8 | 13, 16 | 10, 11; 1, 5, 11 |
| 9 | 14, 15, 17 | 13; 12, 13; 16 |
| 10 | 18 | 10, 11, 14, 17 |
| 11 | 19 | 12, 18 |
| 12 | 20 | 15, 19 |
| 13 | 21 | 20 |
| 14 | 22 | 21 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Substrate measurement and siting decision [COMPLETED]

**Goal**: Replace the two open cost questions with measured numbers before any line is written,
and fix where the new modules live.

**Tasks**:
- [x] Measure label dependence of `Sharing/Fulfil.lean` (1,669 lines) the way research F4
      measured the substrate: per-declaration counts of `Formula`, `.L `, `.lab`, `.bx`, and the
      line span of each maximal label-free region. The preparatory counts to confirm or refute
      are: `Formula` 52, `.L ` 98, `.lab` 0, `.bx` 0.
- [x] Classify each `Fulfil.lean` section as (a) position-graph/fixpoint machinery reachable by
      the skeleton, or (b) label-dependent. Record the line counts of each class.
- [x] Do the same for `Sharing/Decide.lean` (567 lines; preparatory counts `Formula` 32, `.L ` 14,
      `.lab` 2, `.bx` 1) and `Sharing/Agreement.lean` (411 lines; `Formula` 16, `.L ` 8).
- [x] Decide and record module siting: `Sharing/Skeleton.lean` for Stage A; a new
      `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` subtree with sibling aggregator
      `PlusWitnessFamily.lean` for Stages C–G; `FormalSystem/PlusLanguage/Subformulas.lean` for
      Stage B (pure syntax, respecting the invariant that nothing under `PlusLanguage/` imports
      `Semantics/`).
- [x] Record the pre-change baseline: `#print axioms` output for every currently-pinned goal, and
      the current `WitnessFamily/Examples.lean` `#guard` set, as the Stage A comparison target.
- [x] Write the measurement record to
      `specs/690_stability_condition_over_branching_frame/.measurements/01_substrate-measurement.md`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts no scope of its own; it *produces* the measurement that
Phases 16–17's scope estimate depends on. Confirm at implementation time that the preparatory
grep counts quoted above reproduce; if they do not, the divergence itself is the finding and must
be recorded before proceeding.

**Files to modify**:
- `specs/690_stability_condition_over_branching_frame/.measurements/01_substrate-measurement.md` — new; the measurement record

**Verification**:
- The measurement record exists and gives a line count for each `Fulfil.lean` class, with the
  grep commands that produced it quoted verbatim so a reader can re-run them
- No `.lean` file is modified in this phase (`git status --short FormalSystem/` is empty)

---

### Phase 2: `Sharing/Skeleton.lean` — the label-free structure, `rep` and `share` [COMPLETED]

**Goal**: Extract the periodic representative structure from `SharingWitnessFamily` into a
standalone `SharingSkeleton`, with `rep`, `share` and their periodicity/idempotence lemmas, and
make `Sharing/Basic.lean` a thin re-export over it.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` with
      `structure SharingSkeleton` carrying `n`, `n_pos`, `repBack`, `repMid`, `repFwd`,
      `repBack_ne`, `repFwd_ne`, `rep_idem`
- [x] Move `rep`, `rep_def`, `nbr`/`nmr`/`nfr`, `nbr_pos`, `nfr_pos`, `nmr_nonneg`,
      `rep_sub_back_length`, `rep_add_fwd_length` onto the skeleton
- [x] Move `share`, `share_def`, `share_refl`, `share_symm`, `share_trans`,
      `share_sub_back_length`, `share_add_fwd_length`, `rep_mem_or_id`, `rep_idem'`, `share_rep`,
      `share_iff_rep_eq`, `decidableShare` onto the skeleton
- [x] Add `def SharingWitnessFamily.skeleton` in `Sharing/Basic.lean`
- [x] Replace each moved declaration in `Sharing/Basic.lean` by a thin re-export (`abbrev` or a
      one-line `theorem ... := K.lemma`) preserving the existing name, statement and implicit /
      explicit argument structure exactly
- [x] Register `Skeleton.lean` in `Sharing`'s import chain by importing it from `Sharing/Basic.lean`
      only (the aggregator `WitnessFamily.lean` is Phase 22's, per R1)

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: `Sharing/Basic.lean` is 254 lines and mentions `Formula`, `.L`, `.lab` and
`.bx` zero times; the hypothesis is that all 254 lines move to the skeleton unchanged except the
structure's `Γ Del` indexing. Confirm by `grep -c` on the four tokens before the move and by the
post-move line split between `Skeleton.lean` and the re-export shell.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` — new; the skeleton and its `rep`/`share` theory
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean` — `skeleton` projection plus thin re-exports

**Verification**:
- `lake build` green
- `git diff` shows no change to any file outside the two above
- Every name previously exported by `Sharing/Basic.lean` still resolves at its original
  statement (spot-check via `lean_hover_info` on `share_trans`, `rep_add_fwd_length`,
  `decidableShare`)

---

### Phase 3: Skeleton — `Thread`, `Step`, `ReachN` [COMPLETED]

**Goal**: Restate the thread layer on `SharingSkeleton`, leaving `Sharing/Thread.lean` as a
re-export shell.

**Tasks**:
- [x] Move `Thread` (the structure), `Thread.ext`, `Thread.const`, `instNonemptyThread`,
      `Thread.const_idx` onto the skeleton
- [x] Move `Step`, `step_of_share_succ`, `step_refl`, `step_congr_left`, `step_congr_right`,
      `decidableStep`
- [x] Move `ReachN`, `reachN_zero`, `reachN_succ`, `reachN_congr_left`, `reachN_congr_right`,
      `reachN_const`, `reachN_one`, `reachN_add`, `decidableReachN`, `Thread.step'`,
      `Thread.reachN`
- [x] Leave `SharingWitnessFamily.Thread` as an `abbrev` for `S.skeleton.Thread` so downstream *(deviation: altered — the `abbrev` alone left `θ.step u` stated at `S.skeleton.share`, which broke two `rw [S.share_def]` sites in `Fulfil.lean`; the `abbrev` is kept and a family-level `Thread.step` restatement was added beside it, which dot notation resolves first, so `Fulfil.lean` is unmodified as this phase requires)*
      statements (`ThreadFulfilling`, `Fulfil.lean`, `Agreement.lean`) are unchanged

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: `Sharing/Thread.lean` is 273 lines with zero `Formula`/`.L`/`.lab`/`.bx`
mentions; the hypothesis is that all 273 lines move. Confirm by the same grep and by checking
that `Sharing/Predicates.lean`'s `ThreadFulfilling` and `Sharing/Fulfil.lean` compile with no
edit.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` — thread layer added
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Thread.lean` — re-export shell

**Verification**:
- `lake build` green
- `Sharing/Predicates.lean`, `Sharing/Fulfil.lean`, `Sharing/Agreement.lean`,
  `Sharing/Specialize.lean` all unmodified and compiling

---

### Phase 4: Skeleton — the quotient frame [COMPLETED]

**Deviation (altered)**: Phases 4 and 5 were closed as a single atomic batch. `Histories.lean`
reads `Conn` definitionally (`unfold Conn` at `total_eq_thread`), so between Phase 4's move of
`Conn` to the skeleton and Phase 5's move of the histories layer the tree does not compile; there
is no green intermediate state to commit. Both phases' own tasks and verification criteria were
executed in full.

**Goal**: Restate the branching frame on `SharingSkeleton`: the setoid, the world states, the
connectivity relation, `RelZ`, `frame`, and the four frame constraints.

**Tasks**:
- [x] Move `shareSetoid`, `WorldState`, `cls`, `cls_eq`, `share_of_cls_eq`, `time`, `time_cls`
- [x] Move `Conn`, `conn_of_reachN`, `conn_symm`, `conn_congr_left`, `conn_congr_right`
- [x] Move `RelZ`, `relZ_cls`, `relZ_reflection`, `exists_cls`, `relZ_comp`, `relZ_serial`
- [x] Move `frame`, `frame_taskRel`, `frame_comp`, `frame_serial`, `relZ_zero`, `time_of_relZ`,
      `relZ_limit`, `relZ_fib_finite`, `relZ_saturation`, `frame_limit`, `frame_saturation`,
      `instIsRegular`, `instIsRegularTask`, `frame_isZTime`, `frame_sat_ztime`, `frame_sat_base`
- [x] Leave `SharingWitnessFamily.frame`, `.WorldState`, `.cls` and the two instances as
      re-exports at their exact existing statements

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: `Sharing/Frame.lean` is 397 lines with zero label mentions; the hypothesis
is a full move. The instance declarations (`instIsRegular`, `instIsRegularTask`) are the risk
point — confirm that synthesis still finds them through the `abbrev` re-export rather than
silently failing over to a different instance, by an `example ... := inferInstance` at both.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` — frame layer added
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Frame.lean` — re-export shell

**Verification**:
- `lake build` green
- `example (S : SharingWitnessFamily Γ Del) : S.frame.IsRegular := inferInstance` elaborates
- No modification to `Sharing/Agreement.lean` or `Sharing/Specialize.lean`

---

### Phase 5: Skeleton — histories, `total_eq_thread`, and Stage A closeout [COMPLETED]

**Goal**: Complete the skeleton with the histories layer, then prove Stage A behaviour-preserving
against Phase 1's recorded baseline.

**Tasks**:
- [x] Move `conn_thread`, `hist`, `hist_state`, `thread_is_history`, `total_eq_thread` onto the
      skeleton
- [x] Leave `Sharing/Histories.lean` as a re-export shell at the exact existing statements
- [x] Stage A closeout: `lake build` from clean; diff `#print axioms` for every goal in Phase 1's
      baseline; confirm `WitnessFamily/Examples.lean`'s `#guard`s still fire; confirm
      `git diff --stat` touches only the five `Sharing/` files this stage owns
- [x] Add the short `Sharing/README.md` section research recommends: name `SharingSkeleton`, state
      the measurement (four modules, 1,065 lines, zero uses of `Formula`/`.L`/`.lab`/`.bx`) that
      licenses it, so a future reader does not re-derive it
- [ ] If any closeout check fails: revert Stage A entirely and record the R2 fallback (duplicate *(deviation: not applicable — no closeout check attributable to Stage A failed, so the R2 fallback was not taken)*
      the 1,065 lines onto the L⁺ side) as the path Phases 9+ will take

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: `Sharing/Histories.lean` is 141 lines with zero label mentions, and the five
Stage A files total 1,065 moved lines. Confirm the moved total against Phase 1's baseline and
record the actual split in the commit message.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` — histories layer added
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Histories.lean` — re-export shell
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` — skeleton section

**Verification**:
- `lake build` green from clean
- `#print axioms` unchanged on every Phase 1 baseline goal
- `WitnessFamily/Examples.lean` `#guard`s fire
- `bash scripts/check-module-invariants.sh` passes (C1, C2, C3, C4)
- `bash .claude/scripts/lean-sorry-census.sh` reports zero new sorries

---

### Phase 6: L⁺ subformulas and `plusSubformulaClosure` [COMPLETED]

**Goal**: The seven-arm structural recursion and its `Finset` closure, with the eight projections
the L⁺ agreement induction will consume.

**Tasks**:
- [x] Create `FormalSystem/PlusLanguage/Subformulas.lean` (pure syntax; imports
      `FormalSystem.PlusLanguage.Formula` only, respecting the invariant that nothing under
      `PlusLanguage/` imports `Semantics/`)
- [x] `PlusFormula.subformulas : PlusFormula → List PlusFormula`, seven arms mirroring
      `Formula.subformulas` plus `| φ@(.stab ψ) => φ :: subformulas ψ`
- [x] `self_mem_subformulas` and the eight membership lemmas: `imp_left`, `imp_right`, `box`,
      `untl_left`, `untl_right`, `snce_left`, `snce_right`, `stab`
- [x] `plusSubformulaClosure : PlusFormula → Finset PlusFormula` as `(subformulas φ).toFinset`,
      with `self_mem_plusSubformulaClosure` and the decidable-membership instance
- [x] The eight closure projections `plusClosure_imp_left`, …, `plusClosure_stab`

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Research D5 corrects the dispatch's "≈2,257 lines" to ≈250 lines for the
whole L⁺ closure requirement, of which this phase is ≈150. Confirm at implementation time by
comparing the finished file's line count against `FormalSystem/Syntax/Subformulas.lean` plus the
nine consumed declarations of `Syntax/SubformulaClosure/Closure.lean`; if the finished file
exceeds 300 lines, the hypothesis failed and the excess must be explained before Phase 7 starts.

**Files to modify**:
- `FormalSystem/PlusLanguage/Subformulas.lean` — new

**Verification**:
- `lake build` of the single module green
- `#print axioms PlusFormula.subformulas` within `[propext, Classical.choice, Quot.sound]`
- No `Semantics` import appears in the file

---

### Phase 7: `plusClosureOf` — the set-level closure over `PlusContext` [COMPLETED]

**Goal**: The context-level closure the certificate is indexed by, with the projections the
agreement induction consumes.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Closure.lean`
- [x] `plusClosureOf (S : PlusContext) : Finset PlusFormula`, by the same `foldr` over the mapped
      list that `closureOf` uses (stays on `List` primitives so it computes)
- [x] `mem_plusClosureOf`, `self_mem_plusClosureOf`
- [x] The eight set-level projections `plusClosureOf_imp_left`, `plusClosureOf_imp_right`,
      `plusClosureOf_box`, `plusClosureOf_untl_left`, `plusClosureOf_untl_right`,
      `plusClosureOf_snce_left`, `plusClosureOf_snce_right`, **`plusClosureOf_stab`**
- [x] `decidableMemPlusClosureOf`
- [x] `plusPremise_mem_closure` / `plusConclusion_mem_closure`, the two `Γ`/`Δ` membership lemmas
      `Target`-style consumers need

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: ≈100 lines, mirroring `WitnessFamily/Closure.lean`'s 131 lines with one
extra projection. Confirm by line count at phase end.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Closure.lean` — new

**Verification**:
- `lake build` green
- `#eval` a small `plusClosureOf` instance to confirm it computes (no `Classical.choice` in the
  evaluation path)
- `plusClosureOf_stab` elaborates and is the projection `StabFaithful` will gate on

---

### Phase 8: `PlusLabelledLasso` and `PlusWitnessFamily` [COMPLETED]

**Goal**: The L⁺ certificate's two base datatypes, transcribed from `WitnessFamily/Basic.lean`.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean`
- [x] `structure PlusLabelledLasso (C : Finset PlusFormula)` with `back`, `mid`, `fwd`,
      `back_ne`, `fwd_ne`, `label_sub`, `deriving DecidableEq`
- [x] `lab`, `lab_def`, `nb`/`nm`/`nf`, `nb_pos`, `nf_pos`, `nm_nonneg`, `lab_sub_back_length`,
      `lab_add_fwd_length`, `lab_subset` — all through `Periodic.unrollOf`, no constructor match
      (research F5: these are already language-agnostic in substance)
- [x] `structure PlusWitnessFamily (Γ Δ : PlusContext)` with `bx : PlusFormula → Bool`,
      `lassos : List (PlusLabelledLasso (plusClosureOf (Γ ++ Δ)))`, `lassos_ne`
- [x] `lassos_length_pos`, `mainIdx`, `PlusWitnessFamily.L`, `main`, `subset_plusClosureOf`

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: local

**Scope Hypothesis**: ≈200 lines against `WitnessFamily/Basic.lean`'s 201. The `deriving
DecidableEq` on `PlusLabelledLasso` is the risk point (research D2 notes its fragility); confirm
it derives before proceeding, and if it does not, hand-write the instance rather than dropping it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean` — new

**Verification**:
- `lake build` green
- `example : DecidableEq (PlusLabelledLasso C) := inferInstance` elaborates
- `#print axioms PlusWitnessFamily.L` within the permitted set

---

### Phase 9: `PlusSharingWitnessFamily` over the skeleton [COMPLETED]

**Goal**: The branching L⁺ certificate: `PlusWitnessFamily` plus the periodic representative maps,
projecting onto the Stage A `SharingSkeleton` so the whole substrate is inherited, not duplicated.

**Tasks**:
- [x] Extend `PlusWitnessFamily/Basic.lean` (or a new `PlusWitnessFamily/Sharing.lean`, per
      Phase 1's siting record) with
      `structure PlusSharingWitnessFamily (Γ Δ : PlusContext) extends PlusWitnessFamily Γ Δ`
      carrying `repBack`, `repMid`, `repFwd`, `repBack_ne`, `repFwd_ne`, `rep_idem`
- [x] `def PlusSharingWitnessFamily.skeleton : SharingSkeleton`
- [x] Thin re-exports so the L⁺ side reads naturally: `S.rep u`, `S.share u i j`, `S.Thread`,
      `S.cls`, `S.frame`, `S.hist`, `S.total_eq_thread` as `abbrev`/one-line delegations to
      `S.skeleton.*`
- [x] Confirm `S.skeleton.n = S.lassos.length` definitionally (a `rfl` lemma
      `skeleton_n`), so `Fin S.lassos.length` and `Fin S.skeleton.n` interchange without
      coercion friction downstream
- [ ] If Phase 5's Stage A closeout failed and the R2 fallback is in force, duplicate the *(deviation: not applicable — Phase 5 closed green, so no substrate was duplicated on the L-plus side)*
      substrate onto the L⁺ side here instead and record the deviation

**Timing**: 1.5 hours

**Depends on**: 5, 8

**Verification Tier**: interface

**Scope Hypothesis**: ≈120 lines, and **zero** lines of substrate duplication. The claim to
confirm is that no `Thread`/`Step`/`ReachN`/`Conn`/`RelZ`/`frame`/`hist` proof is re-proved on
this side; confirm by grepping the new file for those proof bodies and finding only delegations.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean` — the sharing datatype and skeleton projection

**Verification**:
- `lake build` green
- `example (S : PlusSharingWitnessFamily Γ Δ) : S.frame.IsRegular := inferInstance` elaborates
  through the skeleton's instance
- `skeleton_n` is `rfl`

---

### Phase 10: Conditions (C0) and (C1') at L⁺ [COMPLETED]

**Goal**: `PlusAtomCoherent` and `PlusLocalCoherentShare`, re-indexed with the `stab` position
present-but-unconstrained in the clause enumeration (it is (C5)'s job, and stating it twice would
be a second, weaker copy).

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean`
- [x] `PlusAtomCoherent` — `share`-gated atom agreement, transcribed from
      `SharingWitnessFamily.AtomCoherent` with `Formula.atom` → `PlusFormula.atom`
- [x] `PlusLocalCoherentShare` — the five clauses (`bot`, `imp`, `box`, `untl` across shared
      successors, `snce` across shared predecessors) with `Formula` → `PlusFormula` and
      `closureOf` → `plusClosureOf`
- [x] `plusUntl_self_of_share` and `plusSnce_self_of_share`, the reflexive instances
- [x] A header note recording that the `stab` clause is deliberately absent from (C1') and lives
      in (C5), with the reason (it is a same-time, cross-index condition, not a one-step
      unfolding)

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: ≈120 lines against `Sharing/Predicates.lean`'s (C0)+(C1') span. Confirm the
clause count is five, not six: an accidental sixth `stab` clause here would be the box-shaped
duplicate the dispatch forbids.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean` — new

**Verification**:
- `lake build` green
- `grep -c 'PlusFormula.stab' PlusWitnessFamily/Predicates.lean` counts only the (C5)-pointing
  header note at this phase, not a clause

---

### Phase 11: Conditions (C2'), (C3), (C4) at L⁺ [COMPLETED]

**Goal**: `PlusThreadFulfilling`, `PlusBoxFaithful`, `PlusTarget`, and the two unconditional
reductions to the deterministic-shaped conditions.

**Tasks**:
- [x] `PlusThreadFulfilling` — the `A[g U e]` universal-thread form for `untl` and its past
      mirror for `snce`, quantified over `S.Thread` (which is `S.skeleton.Thread`)
- [x] `PlusBoxFaithful` — `bx χ = true ↔ ∀ i t, χ ∈ W.L i t`, gated on
      `PlusFormula.box χ ∈ plusClosureOf (Γ ++ Δ)`; reused verbatim in shape, as research and
      `Sharing/Predicates.lean`'s header establish for the `Formula` side
- [x] `PlusTarget` — `(∀ γ ∈ Γ, γ ∈ W.main t) ∧ (∀ σ ∈ Δ, σ ∉ W.main t)`
- [x] `plusLocalCoherentLab_of_share` and `plusFulfillingLab_of_thread`, the two reductions, via *(deviation: altered — there is no deterministic L-plus certificate to reduce to, so the reduction targets `PlusWitnessFamily.PlusLocalCoherentLab` and `PlusFulfillingLab`, the one-position and per-lasso *shapes* of (C1') and (C2'), stated in this phase alongside them)*
      `share_refl` and `Thread.const` respectively

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: ≈110 lines. The reductions are one-liners over `Thread.const` /
`share_refl`; if either needs more than ten lines, the skeleton re-export from Phase 9 is not
transparent and that is the defect to fix, not the proof.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean` — (C2'), (C3), (C4) added

**Verification**:
- `lake build` green
- Both reduction theorems elaborate with proofs structurally matching
  `localCoherentLab_of_share` / `fulfillingLab_of_thread`

---

### Phase 12: (C5) `StabFaithful` — the deliverable [COMPLETED]

**Goal**: State the stability condition natively over `PlusFormula.stab`, and prove the
label-level form of `stab_state_only` from it.

**Tasks**:
- [x] Add to `PlusWitnessFamily/Predicates.lean`:
      ```lean
      def StabFaithful (S : PlusSharingWitnessFamily Γ Δ) : Prop :=
        ∀ (i : Fin S.lassos.length) (u : ℤ) (φ : PlusFormula),
          PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Δ) →
            (PlusFormula.stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u)
      ```
- [x] Prove `stabFaithful_share_congr`: from `StabFaithful` and `share u i j`,
      `PlusFormula.stab φ ∈ S.L i u ↔ PlusFormula.stab φ ∈ S.L j u`. This is the label-level
      reading of `PlusTruth.stab_state_only` and follows because `share u` is an equivalence
      (the kernel of `rep u`) — no side condition is introduced and none is needed
- [x] Prove the reflexive consequence `stabFaithful_self`: `stab φ ∈ S.L i u → φ ∈ S.L i u`, via
      `share_refl`, which is the T-axiom direction a consumer will reach for first
- [x] Write the module header recording *why* this is not a clause of (C1'): it is same-time and
      cross-index, whereas (C1')'s temporal clauses are one-step and (C3)'s box clause is global

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: ≈60 lines. The claim to confirm is that no part of the definition mentions
`Encoding`, `Classical`, or any quantifier over threads/walks: confirm by grep on the finished
declaration and by Phase 15's decidability instance elaborating without `open Classical`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean` — (C5) added

**Verification**:
- `lake build` green
- `stabFaithful_share_congr` and `stabFaithful_self` both prove with no `sorry`
- `grep -n 'Encoding\|Classical' ` over the (C5) span returns nothing
- The definition quantifies over `Fin S.lassos.length`, never over `S.Thread` or a walk

---

### Phase 13: Decide — window arithmetic re-index [COMPLETED]

**AMENDED** (cycle 5 user decision, Option 1 on the Phase 16 gate — see
`specs/690_stability_condition_over_branching_frame/.decisions.json`): this phase gains one
additive item, executed after its original tasks had already landed.

- [x] Add `SharingWindow`, a structure extending `SharingSkeleton` with the combined-period
      triple `(NB, NF, NM)` together with `NB_pos`, `NF_pos`, `NM_nonneg` and the three
      compatibility facts the representative congruences need (`nbr_dvd_NB`, `nfr_dvd_NF`,
      `nmr_le_NM`), plus `PlusSharingWitnessFamily.window` supplying it from the combined periods
      this phase already defines *(deviation: altered — sited in the new label-free module
      `WitnessFamily/Sharing/Window.lean` rather than in `PlusWitnessFamily/Decide.lean`, because
      the structure and everything built on it mention no formula, no label and no language; the
      `window` projection itself is in `PlusWitnessFamily/Decide.lean` as this phase's file list
      says)*

This amendment is what discharges Phase 1's finding **F-M3**, that the combined periods do not
factor through `SharingSkeleton`: they do not, and `SharingWindow` is the structure they factor
through instead.

**Goal**: The shared window machinery every L⁺ condition's decision procedure stands on, re-indexed
once so Phases 14–15 are transcriptions rather than arithmetic.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean`
- [x] Re-index `perBack`/`perFwd`/`perMid`, `NB`/`NF`/`NM`, `NB_pos`, `NF_pos`, `NM_nonneg`,
      `nbr_dvd_NB`, `nfr_dvd_NF`, `nmr_le_NM`, `lasso_nb_dvd_NB`, `lasso_nf_dvd_NF`,
      `lasso_nm_le_NM`
- [x] Re-index `rep_congr_back`, `rep_congr_fwd`, `data_congr_back`, `data_congr_fwd`,
      `cohWindowLo`, `cohWindowHi`, `exists_window_repr`
- [x] Where a lemma is label-free, delegate to the Phase 2–5 skeleton rather than re-proving; record *(deviation: altered — `rep_congr_back`/`rep_congr_fwd` are label-free but could NOT be sited on `SharingSkeleton`: the `Periodic.unrollOf_congr_back`/`_fwd` lemmas they instantiate are declared in `Sharing/Decide.lean`, downstream of `Skeleton.lean` in the import order. They are stated here as three-line instantiations instead, and the module header records both this and Phase 1 finding F-M3, that the combined periods do not factor through the skeleton at all.)*
      in the header which lemmas delegated and which needed the label row

**Timing**: 2 hours

**Depends on**: 10, 11

**Verification Tier**: local

**Scope Hypothesis**: `Sharing/Decide.lean` is 567 lines of which Phase 1 measured the
label-dependent share; this phase claims ≈250 of them. Confirm against Phase 1's measurement
record before writing, and record the actual split at phase end.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` — new

**Verification**:
- `lake build` green
- `exists_window_repr` elaborates at the L⁺ family with the same statement shape as its
  `Formula`-side analogue
- No `open Classical` in the file

---

### Phase 14: Decide — (C0) and (C1') collapses and instances [COMPLETED]

**Goal**: `decidablePlusAtomCoherent` and `decidablePlusLocalCoherentShare`, by the landed
seven-step pattern.

**Tasks**:
- [x] `plusAtomClauseAt`, `instDecidablePlusAtomClauseAt`, `plusAtomCoherentData`,
      `PlusAtomCoherentAt`, `decidablePlusAtomCoherentAt`, `plusAtomCoherent_iff_at`,
      `plusAtomCoherentAt_congr`, `plusAtomCoherent_iff_window`, `decidablePlusAtomCoherent`
- [x] The (C1') analogues: `plusShareClauseAt`, `plusCoherentShareData`, `PlusCoherentShareAt`,
      `plusLocalCoherentShare_iff_at`, `plusCoherentShareAt_congr`,
      `plusLocalCoherentShare_iff_window`, `decidablePlusLocalCoherentShare`
- [x] Confirm every instance computes: an `example ... := inferInstance` at each

**Timing**: 2 hours

**Depends on**: 13

**Verification Tier**: local

**Scope Hypothesis**: ≈220 lines, transcribed from `Sharing/Decide.lean:347-533`. Confirm no new
window lemma was needed: if this phase adds arithmetic rather than transcribing it, Phase 13 was
incomplete and that is the defect to fix.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` — (C0)/(C1') decision layer

**Verification**:
- `lake build` green
- Both `inferInstance` examples elaborate
- `#print axioms decidablePlusAtomCoherent` within `[propext, Classical.choice, Quot.sound]`

---

### Phase 15: Decide — (C5) collapse and `decidableStabFaithful` [COMPLETED]

**Goal**: The decision procedure for the stability condition, which is the hard constraint
"decidability must be preserved" discharged mechanically rather than argued.

**Tasks**:
- [x] `stabClauseAt (Li Lj : Finset PlusFormula) : PlusFormula → Prop` — the per-constructor
      clause, `stab`-armed, everything else trivially true; plus its `Decidable` instance
- [x] `stabFaithfulData` at explicit data `(C, rt, L)` — the per-time datum is `(S.rep u, fun i =>
      S.L i u)`, identical in shape to (C0)'s, so no new datum type is introduced
- [x] `StabFaithfulAt` at one time, with `decidableStabFaithfulAt`
- [x] `stabFaithful_iff_at` (closure-gating), `stabFaithfulAt_congr` (per-time congruence)
- [x] `stabFaithful_iff_window` — the window collapse, against the **same**
      `cohWindowLo`/`cohWindowHi` and the same `exists_window_repr` as (C0)
- [x] `decidableStabFaithful`
- [x] An `#eval` or `#guard` on a small concrete family, demonstrating the instance reduces to a
      Boolean rather than merely elaborating

**Timing**: 2 hours

**Depends on**: 12, 13

**Verification Tier**: local

**Scope Hypothesis**: ≈90 lines, per research F2's claim that (C5) is *cheaper* than (C1') (one
label row and one representative map, against (C1')'s three and two). Confirm by line count; if
this phase exceeds 150 lines, the condition as stated in Phase 12 is doing more work than (C0)
does and that discrepancy must be explained.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` — (C5) decision layer

**Verification**:
- `lake build` green
- `example (S : PlusSharingWitnessFamily Γ Δ) : Decidable S.StabFaithful := inferInstance`
- The `#eval`/`#guard` on the small family produces a Boolean, confirming the instance computes
- `grep -c 'open Classical' PlusWitnessFamily/Decide.lean` is `0`

---

### Phase 16: Fulfil re-index — position graph and the `A[g U e]` fixpoint [COMPLETED]

**GATE RESOLVED** (Phase 16): the measurement gate this phase stopped at has been decided by the
user, recorded in `specs/690_stability_condition_over_branching_frame/.decisions.json` (cycle 5).

- **Decision**: Option 1 — **adopt `SharingWindow` and proceed**. A structure extending
  `SharingSkeleton` with the combined-period triple `(NB, NF, NM)` and its positivity facts is
  added in an **amended Phase 13**; the position graph is then a function of that window alone and
  genuinely delegates. This is **additive** to Stage A, not a revision of it.
- **Explicitly excluded by the decision**: do NOT split this phase into 16.1/16.2 (Option 2), and
  do NOT re-budget Stage E (Option 3).
- **Consequence for F-M1** (`Sharing/Fulfil.lean`'s measured 723-line label-dependent span, above
  the ≈700 revise threshold this phase's own Scope Hypothesis names): the threshold is discharged
  by the decision rather than by the measurement. The re-budget it would otherwise have triggered
  is replaced by the `SharingWindow` siting, which moves the position graph, the two fold
  relations and the walk layer out of the label-dependent span entirely.
- **Consequence for F-M3** (the position graph does not factor onto `SharingSkeleton`, because
  `perBack` joins skeleton data with label data): resolved by construction. `SharingWindow`
  carries the combined periods as fields, so the graph factors through it even though it does not
  factor through the bare skeleton.
- **Prior blocker entry**: superseded and removed. Nothing was papered over while this phase was
  blocked; no `sorry`, no vacuous definition and no placeholder was introduced at any point.

**Also recorded**: Phase 21's two non-vacuity theorems, `stabFamily_separates` and
`stabFaithful_diagonal`, were executed out of plan order ahead of Phases 16–20 and are
[COMPLETED]. Their declared `**Depends on**: 20` was wrong — the phase touches no part of the
certificate bundle; its real dependencies are Phases 12 and 15, both [COMPLETED]. Nothing in
Phase 21 bears on this phase.


**Goal**: The (C2') decision machinery's graph-and-fixpoint half, taken from the skeleton where
Phase 1's measurement says it factors and transcribed where it does not.

**Tasks**:
- [x] Re-read Phase 1's measurement record and fix this phase's budget from it **before** writing
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean`
- [x] Port the position-graph layer: positions, the step relation on positions, reachability, and
      the finite-index argument — delegating to `SharingSkeleton` for every declaration Phase 1
      classified as label-free *(deviation: altered — delegated to `SharingWindow`, not to
      `SharingSkeleton`, per the cycle-5 decision; the layer is sited once and label-free in the
      new `WitnessFamily/Sharing/Window.lean` (639 lines) rather than transcribed into the L⁺
      module, so this phase's own L⁺ file carries only what reads a label)*
- [x] Port the `A[g U e]` least fixpoint and its termination measure, with the label row at
      `PlusFormula` *(deviation: altered — the termination measure was **not** ported. `AUFix` is
      already stated at an arbitrary vertex type, an arbitrary `Finset`-valued successor function
      and two arbitrary `Bool` predicates, so `step`, `iter`, `exists_stab`, `lfp`, `lfp_fixed`,
      `lfp_least`, `mem_lfp_iff` and `lfp_induction` are imported from `Sharing/Fulfil.lean` and
      instantiated verbatim. Only the two instantiations `untlFix`/`snceFix` and their four
      consequences are new.)*
- [x] If the measurement says the position graph does **not** factor, split this phase into
      16.1 (graph) and 16.2 (fixpoint) and record the split; do not overrun silently
      *(deviation: skipped — the cycle-5 user decision explicitly rejects this split (Option 2)
      in favour of `SharingWindow` (Option 1). The graph now factors, so the condition this task
      is guarded by no longer holds.)*

**Measured outcome** (recorded as this phase's Scope Hypothesis requires):

| File | Lines | Label-free? |
|------|-------|-------------|
| `WitnessFamily/Sharing/Window.lean` (new) | 639 | yes — mentions no formula, label or language |
| `PlusWitnessFamily/Fulfil.lean` (new, this phase's share) | 225 | no — this is the whole re-index |
| `PlusWitnessFamily/Decide.lean` (the `window` projection) | +66 | no |
| `AUFix` (reused from `Sharing/Fulfil.lean`) | 0 new | reused verbatim |

Against the ≈1,270-line position-graph estimate the Scope Hypothesis carried, the genuinely
label-dependent cost of this phase is **225 lines**. The 639-line window module is new but
language-agnostic and is consumed by any future certificate over any language.

**Timing**: 2 hours

**Depends on**: 1, 5, 11

**Verification Tier**: local

**Scope Hypothesis**: `Sharing/Fulfil.lean` is 1,669 lines; research estimates ≈1,270 of them are
position-graph machinery reachable by the skeleton, leaving ≈400 label-dependent. Preparatory
greps found 52 `Formula` and 98 `.L ` occurrences, consistent with that split but not confirming
it. **Phase 1's measurement is the authority**; this phase's budget is invalid until that record
exists, and a measured label-dependent span above ≈700 lines is grounds to revise the plan rather
than proceed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean` — new
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean` — new *(deviation:
  altered — added by the cycle-5 decision; the label-free half of this phase is sited here)*
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` — the `window` projection
  *(deviation: altered — the amended Phase 13 item, landed with this phase)*
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — register `Sharing.Window` and the
  previously-unregistered `Sharing.Skeleton` in the subtree aggregator

**Verification**:
- `lake build` green — confirmed for `...Sharing.Window`, `...PlusWitnessFamily.Decide` and
  `...PlusWitnessFamily.Fulfil`
- The fixpoint's termination is accepted without `decreasing_by` gymnastics beyond what the
  landed analogue uses — vacuously: the measure is not re-proved at all, `AUFix` is reused
- Delegation count matches Phase 1's label-free classification: every declaration the measurement
  marked label-free is delegated, and none is re-proved. The L⁺ module contains no re-proved body
  of any window, graph, fold or walk declaration.

---

### Phase 17: Fulfil re-index — window reduction and `decidablePlusThreadFulfilling` [COMPLETED]

**Goal**: Close (C2') at L⁺ by connecting the fixpoint to the window, producing the instance.

**Tasks**:
- [x] Port the window reduction connecting `PlusThreadFulfilling` to the finite fixpoint
      — the (C1') propagation layer (`plusUntl_propagate`/`plusSnce_propagate` and their `_le`
      /`_ge` forms, `plusUntl_fulfil_of_exists`/`plusSnce_fulfil_of_exists`), the two soundness
      theorems (`thread_untl_of_mem_untlFix`/`thread_snce_of_mem_snceFix`), `PlusFulfilWindow`
      with its decidability, both directions (`plusThreadFulfilling_of_window`,
      `window_of_plusThreadFulfilling`) and `plusThreadFulfilling_iff_window`
- [x] `decidablePlusThreadFulfilling`
- [x] `example ... := inferInstance` confirming synthesis, and a small `#eval`/`#guard`
      demonstrating the instance computes *(deviation: altered — the standalone
      `example (S) : Decidable S.PlusThreadFulfilling := inferInstance` does **not** hold and was
      not written. `decidablePlusThreadFulfilling` takes `PlusLocalCoherentShare` as a proof
      argument and is therefore a `Decidable` **term**, not an instance — exactly as on the
      `Formula` side, and for the same reason: the far-left case of `plusThreadFulfilling_of_window`
      walks its obligation into the window by (C1') propagation, which a standalone instance has
      no access to. The synthesis check is on the conjunction instead,
      `Decidable (S.PlusLocalCoherentShare ∧ S.PlusThreadFulfilling) := inferInstance`, which is
      the form a certificate consumes. Three `#guard`s were added on a concrete single-lasso L⁺
      family: `winTimes = {-2,-1,0,1,2,3}`, `untlFix p p` projects to `{-1}`, `snceFix p p`
      projects to `{1}` — singletons rather than `∅` or the whole window, so the fixpoint
      demonstrably fires and demonstrably does not fire everywhere.)*

**Timing**: 2 hours

**Depends on**: 16

**Verification Tier**: local

**Scope Hypothesis**: ≈250 lines, the label-dependent remainder of `Fulfil.lean` after Phase 16.
Confirm against Phase 1's measured label-dependent span minus what Phase 16 consumed; report the
residual explicitly at phase end.

**Measured residual, reported explicitly as this hypothesis requires**: the phase added **864**
lines to `PlusWitnessFamily/Fulfil.lean` (225 → 1,089), of which ≈88 are the computed smoke test.
The ≈250-line hypothesis was wrong by roughly 3x, and it was wrong for a reason worth recording
rather than smoothing over: Phase 16's `SharingWindow` siting removed the *position graph* from
the label-dependent span, but the (C1') propagation layer, the two soundness theorems and the
counterexample-thread construction in `window_of_plusThreadFulfilling` are **all** label-dependent
and none of them was counted in the ≈250. Against the `Formula`-side source span
(`Sharing/Fulfil.lean:901-1598`, 698 lines) the re-index is close to 1:1, which is the honest
shape of this work: the graph factored, the reduction did not.

This overrun does **not** trip this phase's own budget gate — Phase 16's ≈700-line revise
threshold was specific to Phase 16 and was itself discharged by the cycle-5 decision. It is
recorded here so the remaining Stage E and F phases are not budgeted off a number this phase has
now shown to be optimistic.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean` — window reduction and instance

**Verification**:
- `lake build` green — confirmed
- `example (S : PlusSharingWitnessFamily Γ Δ) : Decidable S.PlusThreadFulfilling := inferInstance`
  — **not available**, see the deviation on the third task. The available synthesis check,
  `Decidable (S.PlusLocalCoherentShare ∧ S.PlusThreadFulfilling) := inferInstance`, elaborates.
- No `open Classical` — confirmed, `grep -c 'open Classical'` is `0`
- `#print axioms` on `plusThreadFulfilling_iff_window` and
  `decidablePlusCoherentShareAndFulfilling`: both `{propext, Classical.choice, Quot.sound}`

---

### Phase 18: Agreement — the model, and the six L cases of `plusTruth_iff_mem` [COMPLETED]

**Goal**: The presented model and the six non-`stab` constructor cases of the L⁺ agreement
theorem, each a transcription of its landed `Formula`-side analogue.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean`
- [x] `PlusSharingWitnessFamily.model (hat : S.PlusAtomCoherent) : TaskModel S.frame.toTaskFrame`
      — the `Quotient.lift` valuation, well defined exactly by (C0)
- [x] `valuation_cls`
- [x] `plusUntl_mem_along_thread` and `plusSnce_mem_along_thread`, the two inner inductions along
      a thread
- [x] `plusTruth_iff_mem`, with the `atom`, `bot`, `imp`, `box`, `untl`, `snce` cases proved. The
      `stab` case is Phase 19; carry it as an explicitly-named open case in this phase's working
      state, **not** as a `sorry` — the theorem is not committed until Phase 19 closes it
      *(deviation: altered — the seventh case was written in the same working pass rather than
      carried as an open case across two passes. The **constraint the task exists to enforce was
      met exactly**: no `sorry` and no placeholder was written at any point, and the theorem
      first appears on disk complete. Only the intermediate two-pass working state was skipped.)*

**Timing**: 2 hours

**Depends on**: 10, 11, 14, 17

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ≈300 lines against `Sharing/Agreement.lean:129-245`'s analogue. The
`atomic-batch` mode is declared because `plusTruth_iff_mem` cannot be committed green until Phase
19 supplies the seventh case: the two phases form one committed unit. Confirm at Phase 19's end
that exactly one commit carries the complete theorem.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` — new

**Verification**:
- Every case except `stab` elaborates with a complete proof — and so does `stab`; see Phase 19
- `model` and `valuation_cls` elaborate and build green independently — confirmed
- No `sorry` is written at any point (the `stab` case is left unwritten, not stubbed) —
  confirmed: `grep -c sorry` on the new module is `0`

**Measured outcome**: `PlusWitnessFamily/Agreement.lean` is **417** lines carrying Phases 18, 19
and 20 together, against the ≈300 + ≈20 + ≈150 the three Scope Hypotheses budgeted (≈470). Under
budget, and the reason is the one Phase 16 established: the frame, the threads, the histories and
`total_eq_thread` are all inherited from `SharingSkeleton`, so only the valuation is new.

---

### Phase 19: Agreement — the `stab` case, which pins (C5) [COMPLETED]

**Goal**: Discharge the seventh case of `plusTruth_iff_mem` using `StabFaithful`, which is what
makes (C5) a pinned obligation rather than a signature.

**Tasks**:
- [x] Add `(hstab : S.StabFaithful)` to `plusTruth_iff_mem`'s hypotheses
- [x] Forward direction: given `∀ σ` with matching state, `φ` true — for each `j` with
      `share u i j`, take `Thread.const S j` at offset `s`; `hist_state` + `cls_eq` give the state
      match; the induction hypothesis gives `φ ∈ S.L j u`; `hstab` gives `stab φ ∈ S.L i u`
- [x] Backward direction: given `stab φ ∈ S.L i u` and `σ` with matching state — `total_eq_thread`
      gives `σ = S.hist θ' s'` via `WorldHistory.ext_state`; `share_of_cls_eq` turns the state
      match into `share u i (θ'.idx (s'+t))`; `hstab` gives membership; the induction hypothesis
      concludes
- [x] Commit Phases 18+19 as the single atomic unit declared in Phase 18 *(deviation: altered —
      the single commit also carries Phase 20, because Phase 20's `plusTruth_main_iff_mem`,
      `PlusCertifies` and `plusRefutes_of_certifies` live in the same file and the file must build
      as a unit. The declared requirement — that exactly one commit carries the complete
      `plusTruth_iff_mem` — is met.)*
- [x] Record in the module header that the `stab` case is the `box` case with `share`-gating, and
      that it is unprovable without (C5)

**Timing**: 1.5 hours

**Depends on**: 12, 18

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: research F3 estimates 15–20 lines and calls this the lowest-risk item in the
task. Confirm by line count; an overrun past ~60 lines means the Phase 12 statement of (C5) is not
the form the semantics needs, which would be a substantive finding to report, not a proof problem
to grind through.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` — the `stab` case

**Verification**:
- `plusTruth_iff_mem` elaborates complete, all seven cases, no `sorry` — confirmed
- `lake build` green — confirmed
- Removing `hstab` from the hypotheses makes the `stab` case fail to elaborate — **confirmed
  mechanically.** A per-binder drop-and-re-elaborate check over all six explicit hypotheses
  reports every one of them `load-bearing`, and the break `hstab` produces is located at the
  `rw [hstab ...]` inside the `stab` case and nowhere else. Stated precisely, so the evidence is
  not overclaimed: this establishes that the proof term genuinely consumes (C5) in the `stab`
  case — it is not a proof that no other proof of the case exists without it. The semantic reason
  it cannot is the one recorded in the module header: without (C5) the label `stab φ ∈ S.L i u`
  has no connection at all to the labels at the other indices of the `share`-class, which is
  exactly what `PlusTruthAt`'s `stab` clause quantifies over.
- `#print axioms PlusSharingWitnessFamily.plusTruth_iff_mem` within
  `[propext, Classical.choice, Quot.sound]` — confirmed, exactly that set

**Measured outcome**: the `stab` case is **24** lines, against research F3's 15–20 estimate and
well inside the ~60-line tripwire that would have signalled a mis-stated (C5). The Phase 12
statement of (C5) is the form the semantics needs.

---

### Phase 20: The certificate bundle and the refutation interface [COMPLETED]

**Goal**: `PlusCertifies` (six conditions including (C5)), its decision instance, and the
joint-countermodel producer.

**Tasks**:
- [x] `PlusCertifies (S) (t) : Prop` bundling `PlusAtomCoherent`, `(PlusLocalCoherentShare ∧
      PlusThreadFulfilling)`, `PlusBoxFaithful`, `PlusTarget t`, and **`StabFaithful`**, in the
      cheapest-first projection order a checker evaluates in
- [x] `decidablePlusCertifies`, by `inferInstanceAs` over the five component instances
      *(deviation: altered — **two of the five component instances did not exist.** Neither
      `Decidable PlusBoxFaithful` (C3) nor `Decidable (PlusTarget t)` (C4) had been written by any
      earlier phase; the `Formula` side has both in `WitnessFamily/Decide.lean:924,928` and no
      phase of this plan was ever assigned their L⁺ analogues. This is a **plan gap**, not a
      proof difficulty: the first `inferInstanceAs` simply failed to synthesize. The missing layer
      — `PlusLabelledLasso.mem_all_neg_of_period`/`mem_all_fwd_of_period`/`mem_all_iff_window`,
      `PlusWitnessFamily.mem_all_iff_window`, `instDecidablePlusMemAll`, `plusBoxClause` and its
      instance, `plusBoxFaithful_iff_forall`, `decidablePlusBoxFaithful`, `decidablePlusTarget`,
      ≈130 lines — was written into `PlusWitnessFamily/Decide.lean`, the module that owns the rest
      of the L⁺ decision procedures, and is recorded in this phase's file list below.)*
- [x] `PlusWitnessFamily.PlusRefutes (Γ Δ : PlusContext) : Prop` — the joint-countermodel
      existential over `PlusTruthAt`, mirroring `WitnessFamily.Refutes`
- [x] `plusTruth_main_iff_mem`, then `plusJoint_countermodel`, then
      `plusRefutes_of_certifies`
- [x] `example (S) (t) : Decidable (S.PlusCertifies t) := inferInstance`, confirming synthesis
      rather than asserting it

**Timing**: 2 hours

**Depends on**: 15, 19

**Verification Tier**: local

**Scope Hypothesis**: ≈150 lines against `Sharing/Agreement.lean:329-411`'s analogue plus one
extra bundle component. Confirm the bundle has **six** components, not five: a five-component
bundle would mean (C5) was dropped from the checked conditions, which is the exact regression this
task exists to prevent.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` — bundle and refutation interface
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` — the (C3) and (C4)
  decision layer *(deviation: altered — added by this phase to close the plan gap described on
  the second task above)*

**Verification**:
- `lake build` green — confirmed, zero warnings
- The `inferInstance` example elaborates — confirmed
- `PlusCertifies` mentions `StabFaithful` (grep confirms) — confirmed; the bundle has **six**
  components, not five
- `#print axioms plusRefutes_of_certifies` within the permitted set — confirmed,
  `{propext, Classical.choice, Quot.sound}`

---

### Phase 21: Non-vacuity and the deterministic diagonal [COMPLETED]

**Goal**: The two halves of non-vacuity — a branching family where (C5) bites, and the diagonal
where it degenerates — so that the condition is demonstrably neither vacuous nor box-shaped.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean`
- [x] `stabFamily (p : Atom)` — the two-lasso family of research F7, at target context
      `[stab (Fp)]` with `Fp := untl ⊤ (atom p)`, transcribed from
      `Metalogic/Independence/StabUndefinable.lean`'s `⊡Fp` / `Fp` separation: lassos `0` and `1`
      sharing a state at `u = 0`, `p` labelled on lasso `0` at `t = 1` and nowhere on lasso `1`
      *(deviation: altered — the two lassos share a state at `u = 0` as specified, but `p` is
      labelled on lasso `0` at every time **except** `u = 0` rather than only at `t = 1`. A
      lasso's labels are periodic, so "only at `t = 1`" is not expressible on a singleton cycle,
      and the origin had to be the position where `p` is absent so that (C0) atom coherence also
      holds across the one shared class. The separation the phase asks for is unaffected: `Fp` is
      labelled at the main lasso's origin and `⊡Fp` is not.)*
- [x] `stabFamily_separates` — `Fp ∈ L mainIdx 0` while `stab Fp ∉ L mainIdx 0`, with the
      family satisfying (C5). This is the non-vacuity witness: (C5) is strictly stronger than the
      `box` clause and is not satisfied trivially
- [x] `stabFaithful_diagonal` — on the deterministic specialization (the L⁺ analogue of
      `WitnessFamily.toSharing`, where every `rep u` is `id` and `share u i j ↔ i = j`), (C5)
      collapses to `stab φ ∈ S.L i u ↔ φ ∈ S.L i u`, recovering
      `PlusDeterminism.stab_iff_of_deterministic` inside the device
      *(deviation: altered — stated at the pinned signature's `hdet` hypothesis rather than
      against a constructed L⁺ `toSharing`. Building `toSharing` would have been Phase 20's
      bundle work; the hypothesis form covers every deterministic specialization, including the
      one Phase 20 will build.)*
- [x] A `#guard` or `#eval` confirming `decidableStabFaithful` accepts `stabFamily` by computation

**Timing**: 2 hours

**Depends on**: 20 *(deviation: altered — corrected to 12 and 15. Phase 21 touches no part of the
Phase 20 bundle; it was executed ahead of Phases 16–20 while Phase 16 is BLOCKED.)*

**Verification Tier**: local

**Scope Hypothesis**: ≈250 lines. The claim to confirm is that `stabFamily` is a *concrete*
family with literal label lists, decidable by `#guard` — not an abstract family asserted to
exist. If the witness cannot be made concrete, that is a finding about (C5)'s strength to report,
not a reason to weaken the phase to an existence claim.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` — new

**Verification**:
- `lake build` green
- `#guard` on `stabFamily`'s (C5) check fires
- `stabFamily_separates` and `stabFaithful_diagonal` both prove with no `sorry`
- `#print axioms` on both within `[propext, Classical.choice, Quot.sound]`

---

### Phase 22: Registration, module invariants, and documentation [COMPLETED WITH EXCLUSIONS]

**Goal**: Land the new tree in the build description and the repository's documentation gates, in
a single separately-committed, territory-aware phase.

**Tasks**:
- [x] **Re-read each registration file immediately before editing it** (R1). If a foreign commit,
      a foreign uncommitted modification, or a build this task did not start is observed, STOP and
      report after checking `git log` — do not proceed and do not dismiss it as noise
      *(observed and cleared: `git log` shows `ae7cfa600`, the sibling task's completion commit,
      landed between this task's phases. `git show --stat` confirms it touched only `specs/**` —
      no `FormalSystem/**`, no registration file, no shared script. Nothing to stop for.)*
- [x] Create the sibling aggregator
      `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` importing every module of the
      new subtree, satisfying invariant C8 in the same commit that creates the subdirectory
      *(deviation: altered — the subdirectory was created in Phase 8, several commits earlier, so
      "the same commit" was already impossible by the time this phase ran. The aggregator imports
      all seven modules and C8 passes.)*
- [x] Register `PlusWitnessFamily` in `FormalSystem/Metalogic/Decidability.lean`
- [x] Register `FormalSystem/PlusLanguage/Subformulas.lean` in `FormalSystem/PlusLanguage.lean`
- [ ] Regenerate `FormalSystem.lean`'s import list with
      `lake exe mk_all --lib FormalSystem`. **This regeneration is REPOSITORY-WIDE and is EXPECTED
      TO BE WIDE**: it is not a single-line edit, and a diff touching many import lines is the
      correct outcome, not a Scope-Hypothesis violation — do not stop on its breadth. Gate C33
      currently reports **16** modules missing from the root aggregator, and this phase covers all
      of them plus whatever the remaining phases of this task add:
  - 9 inherited from the state-sharing witness work:
    `WitnessFamily/Sharing/{Agreement,Basic,Decide,Frame,Fulfil,Histories,Predicates,Specialize,Thread}`
  - 6 from this task: `WitnessFamily/Sharing/Skeleton`,
    `PlusWitnessFamily/{Basic,Closure,Decide,Predicates}`, `PlusLanguage/Subformulas`
  - 1 transferred here from the stability-condition-at-`Formula` task, which closes as
    complete-modulo-registration on the same user decision: `WitnessFamily/Sharing/Stability`
      Note `mk_all` is **not** declared in this repository's `lakefile.toml`; it resolves through
      Mathlib at `.lake/packages/mathlib/.lake/build/bin/mk_all`.
- [x] Update `docs/theorem-index.md` with the pinned declarations and their paper anchors (or the
      literal `Paper: —` plus a reason), per invariant C15 — six rows added to the Decidability
      section, all `—` (the results are the formalization's own; none is a paper theorem)
- [x] Update the axiom census baselines that `scripts/check-module-invariants.sh` C2/C14 assert,
      adding the new goals' census lines *(deviation: altered — all six new census lines went to
      **C2** and none to C14. C14's second half pins two specific headline theorems that C2's set
      does not cover; it is not a general census, so adding to it would have been the wrong
      mechanism. C2's section comment and pass message were updated from "four flagship theorems"
      to reflect the extension.)*
- [x] Update `WitnessFamily/README.md` with the note research recommends: the nine declarations
      the certificate stack actually consumes from `Syntax/SubformulaClosure/Closure.lean` —
      enumerated and verified by grep: `subformulaClosure`, `self_mem_subformulaClosure`,
      `closure_imp_left`, `closure_imp_right`, `closure_box`, `closure_untl_left`,
      `closure_untl_right`, `closure_snce_left`, `closure_snce_right`
- [x] Write `PlusWitnessFamily/README.md` documenting the six conditions, the (C5) statement, and
      the fact that this is a **parallel** export leaving the deterministic JSON contract untouched
- [x] Amend `Sharing/Predicates.lean`'s "Recorded gap: (C5) is not stateable here" header to point
      at the L⁺ module that now states it, keeping the explanation of why it is not stateable at
      `Formula`
- [x] Stage each file by name (never a directory or glob `git add`) and commit separately
      *(deviation: altered — staged by name, but landed as **one** commit rather than several.
      The aggregator, `Decidability.lean`, `PlusLanguage.lean` and the regenerated
      `FormalSystem.lean` do not build as separate commits: C33 compares the generated root
      against the tree, so a commit adding the aggregator without regenerating the root is red by
      construction, and vice versa. Splitting them would have produced a sequence of
      known-red commits, which the repository's own commit discipline forbids.)*

**Timing**: 2 hours

**Depends on**: 21

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: eight registration/documentation files, four of which
(`FormalSystem.lean`, `Decidability.lean`, `docs/theorem-index.md`,
`scripts/check-module-invariants.sh`) are in tasks 623/684's declared scope. Confirm the exact set
by re-reading the dispatch's territory JSON at phase start; if a sibling has already landed a
conflicting edit, report rather than merge.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` — new aggregator
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` — new
- `FormalSystem/Metalogic/Decidability.lean` — register the subtree
- `FormalSystem/PlusLanguage.lean` — register `Subformulas`
- `FormalSystem.lean` — register the new modules
- `docs/theorem-index.md` — pinned declarations
- `scripts/check-module-invariants.sh` — axiom census lines for the new goals
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — the nine-declaration note
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean` — header now points at the L⁺ statement

**Verification**:
- `lake build` green — confirmed, 2,769 jobs, zero errors
- `bash scripts/check-module-invariants.sh` passes, including C1, C2, C3, C4, C8, C14, C15, C17 —
  **all eight named checks pass.** C2 now pins ten axiom sets, C3 reports zero sorries, C8 finds
  exactly one sibling aggregator per subdirectory, C15 finds all 219 theorem-index rows anchored,
  C33 finds `FormalSystem.lean` byte-for-byte generated (603 imports), and C5, C16, C29 and INV —
  none of them named above, all four red when this phase began — were repaired and now pass.
- `bash .claude/scripts/lean-sorry-census.sh` reports zero sorries — confirmed, `sorry_count: 0`
- `bash .claude/scripts/check-task-references.sh` passes — confirmed, 0 occurrences across 4 trees
- `git log --oneline -1` shows this phase's own commit only; no foreign hunks staged

**Exclusions** (why this phase is `[COMPLETED WITH EXCLUSIONS]` rather than `[COMPLETED]`): two
check groups remain red. Neither is repairable inside this task's territory, and both are
reported rather than suppressed.

1. **C28, compiler-warning budget** — one entry above baseline:
   `WitnessFamily/Compression/Cycle.lean`, a `push_neg` deprecation. That file was last touched by
   a different task (`6bcbbfe79`), this task never edited it, and the warning is a Mathlib
   deprecation, not a defect introduced here. Running `--update` would have grandfathered another
   task's debt under this task's commit, so it was not run. **Every warning this task *did*
   introduce was fixed**: five `linter.style.longLine` warnings from the `Paper: —` anchor lines
   were wrapped, and C28's count for this task's own files is zero.
2. **C23, naming conventions** — two sub-assertions:
   - `NM_nonneg` at `PlusWitnessFamily/Decide.lean:228` **and** at
     `Sharing/Decide.lean:192`. The second predates this task (`e3155fd32`), so the check was
     already red on this exact name. The first is this task's deliberate 1:1 mirror of it. The
     linter's suggested `NM.nonneg` would break the name correspondence between the two
     certificate sides that the whole L⁺ re-index is organized around, and fixing only one side
     would leave the check red anyway while destroying the correspondence. Renaming both is a
     cross-task rename of a landed API and is not this task's to make.
   - Eleven outer-shadows-inner pairs, of which this task contributes one
     (`SharingWindow.cohWindowLo`, shadowed by `BiLasso/Decide.lean:378`). The same name already
     had two such pairs before this task, so the check was already red; the new one is the same
     mirrored-API pattern.

**Repaired along the way** (not in the task list, but this phase's own gate run surfaced them):
three redundant `@[simp]` attributes on `SharingWitnessFamily.relZ_cls`, `frame_taskRel` and
`hist_state` — delegating wrappers left behind by this task's own Stage A skeleton split, which
`simpNF` correctly reported as not in simp normal form because the skeleton's originals already
fire on the same terms and rewrite further. The attributes were dropped, the theorems kept as
API, and the full build stayed green. Two `linter.hashCommand` suppressions in
`Sharing/Fulfil.lean` also gained the reason comment C29 requires; that is a comment-only edit
and leaves the deterministic device's behaviour untouched.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Agreement
import FormalSystem.PlusLanguage.PlusTruth

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

namespace FormalSystem.PlusLanguage

/-- All subformulas of an L⁺ formula, including itself. Seven arms: the six of
`Formula.subformulas` plus `stab`. -/
def PlusFormula.subformulas : PlusFormula → List PlusFormula := sorry

/-- The subformula closure of an L⁺ formula, as a `Finset`. -/
def plusSubformulaClosure (φ : PlusFormula) : Finset PlusFormula := sorry

end FormalSystem.PlusLanguage

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

/-! ### Stage A — the label-free branching substrate -/

/-- The periodic representative structure the branching device stands on, with no labels and no
formula type. Both the `Formula`-indexed and the `PlusFormula`-indexed certificate project to it,
so `Sharing/{Basic,Thread,Frame,Histories}.lean`'s 1,065 lines are reused rather than
duplicated. -/
structure SharingSkeleton where
  /-- The number of lassos. -/
  n : ℕ
  /-- There is at least one lasso. -/
  n_pos : 0 < n
  /-- Representative maps for the leftward cycle. -/
  repBack : List (Fin n → Fin n)
  /-- Representative maps for the finite window. -/
  repMid : List (Fin n → Fin n)
  /-- Representative maps for the rightward cycle. -/
  repFwd : List (Fin n → Fin n)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  repBack_ne : repBack ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  repFwd_ne : repFwd ≠ []
  /-- Every listed map is idempotent, so it is a choice of class representatives. -/
  rep_idem : ∀ f ∈ repBack ++ repMid ++ repFwd, ∀ i, f (f i) = f i

/-- Two indices name the same world state at time `u`. -/
def SharingSkeleton.share (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) : Prop := sorry

/-- A bi-infinite choice of index, stepping only across shared states. -/
structure SharingSkeleton.Thread (K : SharingSkeleton) where
  /-- The index held at each time. -/
  idx : ℤ → Fin K.n
  /-- Consecutive indices name the same world state at the later time. -/
  step : ∀ u : ℤ, K.share (u + 1) (idx u) (idx (u + 1))

/-- The branching frame over `intOrder`, built without `ShiftSet`. -/
def SharingSkeleton.frame (K : SharingSkeleton) : FrameOver intOrder := sorry

/-- The world history traced by a thread from a time offset. -/
def SharingSkeleton.hist (K : SharingSkeleton) (θ : K.Thread) (s : ℤ) :
    WorldHistory K.frame.toTaskFrame := sorry

/-- **The histories characterization**, on the skeleton. Every world history of the branching
frame is the trace of a thread. Replaces `ShiftSet.total_eq_orbit`, which holds only because the
deterministic device's task relation is functional. -/
theorem SharingSkeleton.total_eq_thread (K : SharingSkeleton)
    (σ : WorldHistory K.frame.toTaskFrame) :
    ∃ θ : K.Thread, ∃ s : ℤ, ∀ t : ℤ, σ.state t = (K.hist θ s).state t := sorry

/-- The existing `Formula`-indexed branching family's skeleton. Stage A's behaviour-preservation
obligation is that every landed name on `SharingWitnessFamily` still resolves, through this
projection, at its original statement. -/
def SharingWitnessFamily.skeleton {Gam Del : FormalSystem.Syntax.Context}
    (S : SharingWitnessFamily Gam Del) : SharingSkeleton := sorry

/-! ### Stages B–C — the L⁺ closure and certificate datatypes -/

/-- The set-level subformula closure of an L⁺ context: the union of its members' closures. -/
def plusClosureOf (S : PlusContext) : Finset PlusFormula := sorry

/-- A labelled bi-lasso at L⁺: three label segments decoded by `Periodic.unrollOf`, every listed
label inside the target closure. -/
structure PlusLabelledLasso (C : Finset PlusFormula) where
  /-- Labels for the leftward cycle. -/
  back : List (Finset PlusFormula)
  /-- Labels for the finite window. -/
  mid : List (Finset PlusFormula)
  /-- Labels for the rightward cycle. -/
  fwd : List (Finset PlusFormula)
  /-- The leftward cycle is non-empty. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty. -/
  fwd_ne : fwd ≠ []
  /-- Every listed label is a set of L⁺ formulas from the target closure. -/
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C
  deriving DecidableEq

/-- The decoded bi-infinite label function of an L⁺ lasso, by `Periodic.unrollOf`. -/
def PlusLabelledLasso.lab {C : Finset PlusFormula} (Lam : PlusLabelledLasso C) (t : ℤ) :
    Finset PlusFormula := sorry

/-- An L⁺ witness family: a box guess plus a non-empty list of L⁺ labelled lassos. A **new**
export alongside the deterministic one; the shipping certificate's fields are untouched. -/
structure PlusWitnessFamily (Gam Del : PlusContext) where
  /-- The box guess, read only at formulas boxed inside the target closure. -/
  bx : PlusFormula → Bool
  /-- The lassos of the family; lasso `0` is the main one. -/
  lassos : List (PlusLabelledLasso (plusClosureOf (Gam ++ Del)))
  /-- The family has at least one lasso. -/
  lassos_ne : lassos ≠ []

/-- The main lasso's index, pinned at `0`, where the target is read. -/
def PlusWitnessFamily.mainIdx {Gam Del : PlusContext} (W : PlusWitnessFamily Gam Del) :
    Fin W.lassos.length := sorry

/-- The family's decoded label function, indexed by lasso and time. -/
def PlusWitnessFamily.L {Gam Del : PlusContext} (W : PlusWitnessFamily Gam Del)
    (i : Fin W.lassos.length) (t : ℤ) : Finset PlusFormula := sorry

/-- An L⁺ witness family extended by the periodic representative maps that make its frame branch. -/
structure PlusSharingWitnessFamily (Gam Del : PlusContext) extends PlusWitnessFamily Gam Del where
  /-- Representative maps for the leftward cycle. -/
  repBack : List (Fin toPlusWitnessFamily.lassos.length → Fin toPlusWitnessFamily.lassos.length)
  /-- Representative maps for the finite window. -/
  repMid : List (Fin toPlusWitnessFamily.lassos.length → Fin toPlusWitnessFamily.lassos.length)
  /-- Representative maps for the rightward cycle. -/
  repFwd : List (Fin toPlusWitnessFamily.lassos.length → Fin toPlusWitnessFamily.lassos.length)
  /-- The leftward cycle is non-empty. -/
  repBack_ne : repBack ≠ []
  /-- The rightward cycle is non-empty. -/
  repFwd_ne : repFwd ≠ []
  /-- Every listed map is idempotent. -/
  rep_idem : ∀ f ∈ repBack ++ repMid ++ repFwd, ∀ i, f (f i) = f i

variable {Gam Del : PlusContext}

/-- The L⁺ family's skeleton: the whole branching substrate, inherited rather than duplicated. -/
def PlusSharingWitnessFamily.skeleton (S : PlusSharingWitnessFamily Gam Del) :
    SharingSkeleton := sorry

/-! ### Stage D — the six conditions -/

/-- (C0) Atoms agree across a shared state, so the class-level valuation is well defined. -/
def PlusSharingWitnessFamily.PlusAtomCoherent (S : PlusSharingWitnessFamily Gam Del) : Prop :=
  sorry

/-- (C1') Local coherence with the two temporal clauses taken across `share`-linked index pairs.
Five clauses, not six: the stability modal is (C5)'s, not a one-step unfolding. -/
def PlusSharingWitnessFamily.PlusLocalCoherentShare (S : PlusSharingWitnessFamily Gam Del) :
    Prop := sorry

/-- (C2') Every thread through a position discharges the eventualities labelled there. -/
def PlusSharingWitnessFamily.PlusThreadFulfilling (S : PlusSharingWitnessFamily Gam Del) : Prop :=
  sorry

/-- (C3) The box guess is exactly global label membership. Reused verbatim in shape. -/
def PlusWitnessFamily.PlusBoxFaithful (W : PlusWitnessFamily Gam Del) : Prop := sorry

/-- (C4) A time on the main lasso at which every premise is labelled and no conclusion is. -/
def PlusWitnessFamily.PlusTarget (W : PlusWitnessFamily Gam Del) (t : ℤ) : Prop := sorry

/--
**(C5) Stability faithfulness** — the deliverable.

`⊡φ` is labelled at `(i, u)` exactly when `φ` is labelled at every index naming the same world
state at `u` --

    stab φ ∈ S.L i u ↔ ∀ j, S.skeleton.share u i j → φ ∈ S.L j u

-- closure-gated on `stab φ`. It quantifies over `Fin S.lassos.length` at one time, never over the
frame's infinitely many walks, so decidability is preserved by construction. It mentions no
`Encoding`, so every instance computes.
-/
def PlusSharingWitnessFamily.StabFaithful (S : PlusSharingWitnessFamily Gam Del) : Prop := sorry

/-- **(C5) implies the label-level `stab_state_only`.** `share u` is an equivalence (the kernel of
`rep u`), so indices naming the same state agree on every stability-modal label. No side condition
is needed and none is generated. -/
theorem PlusSharingWitnessFamily.stabFaithful_share_congr (S : PlusSharingWitnessFamily Gam Del)
    (h : S.StabFaithful) (u : ℤ) (i j : Fin S.lassos.length)
    (hs : S.skeleton.share u i j) (φ : PlusFormula)
    (hc : PlusFormula.stab φ ∈ plusClosureOf (Gam ++ Del)) :
    (PlusFormula.stab φ ∈ S.L i u ↔ PlusFormula.stab φ ∈ S.L j u) := sorry

/-! ### Stage E — decidability -/

/-- **(C5) decides.** By the landed (C0) `AtomCoherent` template against the same window: one
representative map and one label row, so (C5) is cheaper than (C1'). -/
instance PlusSharingWitnessFamily.decidableStabFaithful (S : PlusSharingWitnessFamily Gam Del) :
    Decidable S.StabFaithful := sorry

/-! ### Stage F — agreement and the refutation interface -/

/-- The presented model: the valuation is a `Quotient.lift` over `share`-classes, well defined
exactly by (C0). -/
def PlusSharingWitnessFamily.model (S : PlusSharingWitnessFamily Gam Del)
    (hat : S.PlusAtomCoherent) : TaskModel S.skeleton.frame.toTaskFrame := sorry

/--
**T1 for the L⁺ branching device.**

L⁺ truth in the presented model agrees with label membership, along every thread, at every offset
and every formula of the target closure. The `stab` case is the `box` case with `share`-gating and
**consumes `hstab`**: this is what makes (C5) a pinned obligation rather than a signature.
-/
theorem PlusSharingWitnessFamily.plusTruth_iff_mem (S : PlusSharingWitnessFamily Gam Del)
    (hat : S.PlusAtomCoherent) (hloc : S.PlusLocalCoherentShare)
    (hful : S.PlusThreadFulfilling) (hbox : S.toPlusWitnessFamily.PlusBoxFaithful)
    (hstab : S.StabFaithful) :
    ∀ ψ : PlusFormula, ψ ∈ plusClosureOf (Gam ++ Del) →
      ∀ (θ : S.skeleton.Thread) (s t : ℤ),
        PlusTruthAt (S.model hat) (S.skeleton.hist θ s) t ψ ↔
          ψ ∈ S.L (θ.idx (s + t)) (s + t) := sorry

/-- **The six certificate conditions, bundled at a target time.** Six, not five: dropping (C5)
here is the exact regression this task exists to prevent. -/
def PlusSharingWitnessFamily.PlusCertifies (S : PlusSharingWitnessFamily Gam Del) (t : ℤ) : Prop :=
  sorry

/-- **The bundle decides**, from five component instances. -/
instance PlusSharingWitnessFamily.decidablePlusCertifies (S : PlusSharingWitnessFamily Gam Del)
    (t : ℤ) : Decidable (S.PlusCertifies t) := sorry

/-- An L⁺ joint countermodel: an explicit ℤ-time frame, model, history and time at which every
premise of `Gam` is L⁺-true and every conclusion of `Del` is L⁺-false. -/
def PlusWitnessFamily.PlusRefutes (Gam Del : PlusContext) : Prop := sorry

/-- **The composition an accepting checker branch applies**: the bundled six conditions at a
target time produce an L⁺ joint countermodel. -/
theorem PlusSharingWitnessFamily.plusRefutes_of_certifies (S : PlusSharingWitnessFamily Gam Del)
    {t : ℤ} (h : S.PlusCertifies t) : PlusWitnessFamily.PlusRefutes Gam Del := sorry

/-! ### Stage G — non-vacuity and the deterministic diagonal -/

/-- The two-lasso non-vacuity witness: lassos `0` and `1` share a state at `u = 0`, `p` is
labelled on lasso `0` at `t = 1` and nowhere on lasso `1`. Transcribed from
`Metalogic/Independence/StabUndefinable.lean`'s `⊡Fp` / `Fp` separation. -/
def PlusSharingWitnessFamily.stabFamily (p : Atom) :
    PlusSharingWitnessFamily
      [PlusFormula.stab (.untl (.imp .bot .bot) (.atom p))] [] := sorry

/-- **(C5) is not vacuous and not box-shaped.** On `stabFamily` the eventuality `Fp` is labelled
where `⊡Fp` is not, so the condition is strictly stronger than the `box` clause and is not
satisfied trivially. -/
theorem PlusSharingWitnessFamily.stabFamily_separates (p : Atom) :
    (PlusSharingWitnessFamily.stabFamily p).StabFaithful ∧
      PlusFormula.untl (.imp .bot .bot) (.atom p) ∈
        (PlusSharingWitnessFamily.stabFamily p).L
          (PlusSharingWitnessFamily.stabFamily p).toPlusWitnessFamily.mainIdx 0 ∧
      PlusFormula.stab (.untl (.imp .bot .bot) (.atom p)) ∉
        (PlusSharingWitnessFamily.stabFamily p).L
          (PlusSharingWitnessFamily.stabFamily p).toPlusWitnessFamily.mainIdx 0 := sorry

/-- **The diagonal collapse.** On the deterministic specialization — every `rep u` the identity,
so `share u i j ↔ i = j` — (C5) degenerates to `⊡φ ↔ φ`, recovering
`PlusDeterminism.stab_iff_of_deterministic` inside the device. This is the other half of
non-vacuity: the branching substrate is what makes the condition bite. -/
theorem PlusSharingWitnessFamily.stabFaithful_diagonal (S : PlusSharingWitnessFamily Gam Del)
    (hdet : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.skeleton.share u i j ↔ i = j)
    (h : S.StabFaithful) (i : Fin S.lassos.length) (u : ℤ) (φ : PlusFormula)
    (hc : PlusFormula.stab φ ∈ plusClosureOf (Gam ++ Del)) :
    (PlusFormula.stab φ ∈ S.L i u ↔ φ ∈ S.L i u) := sorry

end FormalSystem.Metalogic.Decidability
```

## Testing & Validation

- [ ] `lake build` green from clean at every phase boundary, and at task end
- [ ] `bash .claude/scripts/lean-sorry-census.sh` reports zero sorries across the Lean source roots
- [ ] `bash scripts/check-module-invariants.sh` passes, with attention to C1 (build), C2 and C14
      (axiom census), C3 (zero structural sorry), C4 (imports resolve), C8 (aggregator
      convention), C15 (paper anchors), C17 (no dead declarations)
- [ ] `bash .claude/scripts/check-task-references.sh` passes — no task-number citations under
      `FormalSystem/**`, `docs/**` or `scripts/**`
- [ ] `#print axioms` on each of the thirty-four pinned Goal identifiers is within
      `[propext, Classical.choice, Quot.sound]` and contains no `sorryAx`
- [ ] **Deterministic-path byte-identity**: `git diff` over
      `FormalSystem/Metalogic/Decidability/WitnessFamily/{Basic,Predicates,Std,Agreement,Decide,Examples}.lean`
      and `FormalSystem/Metalogic/Decidability/BiLasso/**` shows no content change; the five
      `Sharing/` files changed by Stage A show re-export shells only, at unchanged statements
- [ ] `WitnessFamily/Examples.lean`'s `#guard`s still fire
- [ ] **Decidability is real, not merely typed**: `#eval`/`#guard` on a concrete family reduces
      `decidableStabFaithful`, `decidablePlusThreadFulfilling` and `decidablePlusCertifies` to
      Booleans
- [ ] **(C5) is load-bearing**: removing `hstab` from `plusTruth_iff_mem` makes the `stab` case
      fail to elaborate (recorded in Phase 19)
- [ ] `grep -rn 'open Classical' FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` returns
      nothing
- [ ] No new field on `SharingWitnessFamily`, `WitnessFamily` or `LabelledLasso`: the shipping
      JSON export contract is unchanged in name, meaning and shape

## Artifacts & Outputs

- `specs/690_stability_condition_over_branching_frame/plans/01_stability-condition-branching-frame.md` (this file)
- `specs/690_stability_condition_over_branching_frame/.measurements/01_substrate-measurement.md` (Phase 1)
- `specs/690_stability_condition_over_branching_frame/summaries/01_stability-condition-branching-frame-summary.md` (at completion)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` (new)
- `FormalSystem/PlusLanguage/Subformulas.lean` (new)
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Closure,Basic,Predicates,Decide,Fulfil,Agreement,Examples}.lean` (new)
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` (new)
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` (new aggregator)
- Modified: the five `Sharing/` re-export shells, `Sharing/README.md`,
  `Sharing/Predicates.lean`'s recorded-gap header, `WitnessFamily/README.md`,
  `FormalSystem/PlusLanguage.lean`, `FormalSystem/Metalogic/Decidability.lean`,
  `FormalSystem.lean`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`

## Rollback/Contingency

**Per-phase.** Every phase ends green and committed, so the cheapest rollback is `git revert` of
that phase's own commit. Phases 2–5, 18–19 and 22 are `atomic-batch`: revert the batch, never a
file within it.

**Stage A (Phases 2–5) specifically.** This is the only stage that edits files the shipping
deterministic path depends on, and its acceptance criteria are designed to detect a regression
before it lands (R2). If any closeout check in Phase 5 fails, revert Phases 2–5 as a unit and
take the recorded fallback: duplicate the 1,065 substrate lines onto the L⁺ side in Phase 9. That
costs lines and carries no risk to the deterministic path. Phases 6–8 are independent of Stage A
and are not reverted.

**Phases 16–17 (Fulfil).** If Phase 1's measurement shows the label-dependent span exceeds ~700
lines, do not proceed on this plan's budget: stop, report, and revise the plan. An overrun here is
the one place a 41-hour estimate can become a 60-hour one.

**Whole-task revert.** If the task must be abandoned mid-flight with uncommitted work in the tree,
take a snapshot before any destructive git command: see `context/contracts/recovery.md`'s rollback
rung for the exact invocation shape, including its `--allow-out-of-scope` override for the
deliberate whole-tree case. Do not emit a bare reverting `git-snapshot.sh` as a routine
start-of-phase precaution; a defensive checkpoint before risky work uses `--no-revert`.

**What is never rolled back by this task.** The shipping deterministic certificate and its JSON
export contract are never modified, so no rollback of this task can affect the consuming model
checker.
