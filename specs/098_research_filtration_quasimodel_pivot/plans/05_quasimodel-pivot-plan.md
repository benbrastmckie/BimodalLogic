# Implementation Plan: Quasimodel Pivot via Direct BX7 Proof (v5)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Status**: [NOT STARTED]
- **Effort**: 30-50 hours (point estimate: 38h)
- **Dependencies**: Task 99 (COMPLETED). Parallel-safe with tasks 93, 94.
- **Research Inputs**:
  - specs/098_research_filtration_quasimodel_pivot/reports/09_phase5-blocker-resolution.md (round 5, primary v5 driver)
  - specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md
  - specs/098_research_filtration_quasimodel_pivot/reports/08_team-research.md
  - specs/098_research_filtration_quasimodel_pivot/handoffs/phase5_blocker_analysis.md
- **Artifacts**: plans/05_quasimodel-pivot-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v4 Phases 5-8 are abandoned due to two independent structural
obstacles in the chain realization approach: strict seed inconsistency
when G-formulas fall outside the enriched Sigma, and G-formula
non-persistence through Hintikka chains. Round 5 research (report 09)
recommends bypassing chain realization entirely and proving the four
Frame.lean sorries (`bx_until_eventuality_resolution`,
`bx_until_backward`, `bx_since_eventuality_resolution`,
`bx_since_backward`) directly at the MCS level using BX7 (Until
linearity) and BX11 (temporal linearity). Once Frame.lean is closed,
the six Realization.lean sorries become trivially closable by
delegation to Frame.lean. Definition of done: `lake build` succeeds
with zero new sorries and zero new axioms in the targeted theorems.

### Research Integration

- **09_phase5-blocker-resolution.md** (round 5, primary v5 driver) --
  Identified Path 4 (direct BX7-based proof) as the recommended
  approach. Analyzed five candidate paths; dismissed chain-based
  approaches (Paths 1, 2, 5) due to structural Hintikka/MCS gap.
  Provided proof sketches for all four Frame.lean sorries.
- **phase5_blocker_analysis.md** -- Detailed mathematical analysis of
  the two obstacles (strict seed inconsistency, G non-persistence)
  that block the chain realization.
- **08_team-research.md** -- Round 4 critic findings (C.4, C.5, C.7)
  that informed v4; now superseded by v5's approach change.

### Prior Plan Reference

Plan v4 Phases 1-4b are COMPLETED and validated. Infrastructure built
(EnrichedClosure, bigconj, BXPoint-backed HintikkaStepOracle,
chain_step_seed_consistent_enriched, Since dual) remains in the
codebase and is not consumed by v5 but is not wasted -- it provides
useful background infrastructure. The key lesson from v4 is that the
chain realization approach encounters a structural Hintikka/MCS
abstraction gap that cannot be patched incrementally. V5 abandons
the chain approach entirely and attacks Frame.lean directly.

### Roadmap Alignment

Task 98 advances the BX canonical-model completeness milestone by
closing the 4 Until/Since sorries in Frame.lean and the 6 delegating
sorries in Realization.lean. These 10 sorries represent the main
blocker on the completeness path. Remains parallel-safe with tasks 93
(TaskModel embedding) and 94 (legacy sorry archival).

## Goals & Non-Goals

**Goals**:

- Close the 4 Frame.lean sorries (`bx_until_eventuality_resolution`,
  `bx_until_backward`, `bx_since_eventuality_resolution`,
  `bx_since_backward`) using direct MCS-level proofs with BX axioms.
- Close the 6 Realization.lean sorries by delegating to the now-proved
  Frame.lean infrastructure.
- Preserve `lake build` cleanliness and zero-debt compliance (no new
  axioms, no new sorries).
- Establish reusable lemma infrastructure for BX7/BX11-based interval
  reasoning on BXPoints.

**Non-Goals**:

- Modifying `bx_le` definition (g_content-based ordering is kept).
- Completing the chain realization (Phases 5-8 of v4 are abandoned).
- Building the TaskModel embedding (task 93).
- Touching TruthLemma.lean G/H/Box cases.
- Adding new BX axioms or any axioms.
- Archiving legacy sorries (task 94).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX7 three-way disjunction does not close guard gap | H | M (35%) | Phase 5 is a focused proof-of-concept; if it stalls after 15h, trigger fallback to quotient/filtration (Phase 9 contingency). |
| bx_le non-totality blocks interval reasoning | H | M (30%) | BX11 (temporal linearity) constrains configurations; build interval lemmas in Phase 5 to test viability early. |
| Backward direction (Phase 6) is harder than forward | M | M (40%) | Research report 09 identified this; Phase 6 has a larger budget. The enriched_seed_consistent_until infrastructure from Phase 4a is reusable. |
| Since mirrors require non-trivial adaptation | M | L (20%) | Since mirrors are structurally symmetric; budget Phase 7 conservatively. |
| Proof-of-concept succeeds but full proof exceeds 50h | M | L (25%) | Gate D at 40h triggers explicit descope: close proven sorries, defer remainder to new task. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4a, 4b | -- (all COMPLETED) |
| 2 | 5 | -- (no dependency on 1-4b) |
| 3 | 6 | 5 |
| 4 | 7 | 5, 6 |
| 5 | 8 | 5, 6, 7 |

Phases within the same wave can execute in parallel.

**Checkpoint gates**:

- **Gate D** (end of Phase 5): `bx_until_eventuality_resolution` proven
  sorry-free. If failed after 15h, halt and evaluate whether the
  approach is viable. If viable but slow, continue. If fundamentally
  blocked, trigger Phase 9 (quotient/filtration fallback).
- **Gate E** (end of Phase 6): Both forward and backward Until proven.
  Since mirrors (Phase 7) are mechanical from here.
- **Budget gate** (40h cumulative): If total effort exceeds 40h with
  sorries remaining, descope remaining sorries into a new task.

---

### Phase 1: Bigconj and EnrichedClosure Definition [COMPLETED]

**Goal**: Define `bigconj`, `neg_bigconj`, and the Fisher-Ladner
`EnrichedClosure` plus closure/negation-pairing lemmas.

**Tasks**: (completed in v3)

- [x] `Theories/Bimodal/Syntax/BigConj.lean` with `bigconj`,
  `neg_bigconj`, and derivation-tree helpers.
- [x] `EnrichedClosure.lean` with `enrichedClosure`,
  `enriched_target_mem`, `enriched_subformula_mem`,
  `enriched_g_neg_bigconj_mem`, `enriched_h_neg_bigconj_mem`,
  `enriched_neg_pairing`, `enriched_finite`.

**Timing**: 0h (already in tree)

**Depends on**: none

**Verification**: already satisfied.

---

### Phase 2: Migrate HintikkaPoint / Construction to EnrichedClosure [COMPLETED]

**Goal**: Route `HintikkaPoint`, `Construction`, `Realization`, and
`LocusControl` through `enrichedClosure` as the Sigma of record.

**Tasks**: (completed in v3)

- [x] `HintikkaPoint Sigma` quantification updated.
- [x] `sigma_signature_mem`, `locally_maximal` re-verified under
  `EnrichedClosure`.

**Timing**: 0h (already in tree)

**Depends on**: 1

**Verification**: already satisfied.

---

### Phase 3: Integrate the BXPoint-backed HintikkaStepOracle (task 99 payload) [COMPLETED]

**Goal**: Adopt task 99's `WitnessedHintikka` / `ChainWitnessed` /
`HintikkaStepOracle` / `hintikka_chain_exists` /
`chain_step_seed_consistent` as the chain-construction API.

**Tasks**: (completed in v4)

- [x] Task 99 declarations confirmed present in Construction.lean.
- [x] Adapter `quasimodel_chain_exists` defined.
- [x] `lake build` clean; `lean_verify` passed.
- [x] Gate A passed.

**Timing**: 0h (already in tree)

**Depends on**: 1, 2

**Verification**: already satisfied.

---

### Phase 4a: Consume chain_step_seed_consistent for Until realization [COMPLETED]

**Goal**: Prove `chain_step_seed_consistent_enriched` consuming
task 99's `chain_step_seed_consistent`.

**Tasks**: (completed in v4)

- [x] `chain_step_seed_consistent_enriched` proven.
- [x] Supporting lemmas: `bigconj_mem_hintikka_via_witness`,
  `neg_bigconj_mem_next_hintikka`.
- [x] `lake build` clean.

**Timing**: 0h (already in tree)

**Depends on**: 3

**Verification**: already satisfied.

---

### Phase 4b: Since dual -- witness-backed HintikkaStepOracleSince [COMPLETED]

**Goal**: Port task 99's BXPoint-backed witness pattern to the Since
dual.

**Tasks**: (completed in v4)

- [x] `HintikkaStepOracleSince` strengthened with `WitnessedHintikka`.
- [x] `hintikka_chain_exists_since` with `ChainWitnessed`.
- [x] `chain_step_seed_consistent_since` and
  `chain_step_seed_consistent_enriched_since` proven.
- [x] `lake build` clean.

**Timing**: 0h (already in tree)

**Depends on**: 4a

**Verification**: already satisfied.

---

### Phase 5: Forward Until -- BX7 Direct Proof [BLOCKED]

**Goal**: Prove `bx_until_eventuality_resolution` in Frame.lean
sorry-free, using BX7 (Until linearity), BX5 (self-accumulation),
BX4 (connectedness), and BX11 (temporal linearity) at the MCS level.
This is the central technical phase of v5 and the proof-of-concept
for the direct BX7 approach.

**Tasks**:

- [ ] Build BX7 interval lemma library in Frame.lean:
  - `bx7_until_witness_ordering`: Given `phi U psi in w` and
    `chi U theta in w`, the three-way BX7 disjunction constrains
    the ordering of their witnesses.
  - `bx11_temporal_linearity_mcs`: Extract usable MCS-level
    consequences of BX11 (`(F phi and F psi) -> F(phi and psi) or
    F(phi and F psi) or F(psi and F phi)`).
  - `bx_le_interval_cases`: For `bx_le w u`, `bx_le u v`,
    `bx_le w v`, establish case analysis on the relative position
    of `u` within the `[w, v]` interval using BX7/BX11.
- [ ] Prove `bx_until_eventuality_resolution` (Frame.lean:632-653):
  - Stage 1 (witness): `F(psi) in w` from BX10. Get `v >= w` with
    `psi in v` via `bx_forward_witness`. (Already sketched in code.)
  - Stage 2 (guard): For `u` with `bx_le w u`, `bx_le u v`,
    `not bx_le v u`:
    1. From BX4: `G(P(phi U psi)) in w`, so `P(phi U psi) in u`.
    2. From `bx_backward_witness`: get `u'` with `phi U psi in u'`
       and `bx_le u' u`.
    3. Apply BX7 at `u'` to `(phi U psi)` and `(top U psi)`:
       - `top U psi in u'` because `F(psi) in u'` (from
         `bx_le u' u`, `bx_le u v`, `psi in v`, and F_from_above)
         plus BX12 (`F psi -> top U psi`).
       - BX7 three-way disjunction on these two Until formulas.
       - Each case: analyze whether `phi in u` follows from the
         combined guard structure.
    4. Close gap: the critical step is showing that in all three
       BX7 cases, the guard of `phi U psi` covers `u`. Use BX5
       self-accumulation (`phi U psi -> (phi and phi U psi) U psi`)
       and BX6 absorption to tighten the witness analysis.
- [ ] Verify: `lean_verify bx_until_eventuality_resolution` shows
  only standard axioms.
- [ ] **GATE D**: If proof stalls after 15h, evaluate feasibility.

**Timing**: 12-20 hours

**Depends on**: none (operates directly on Frame.lean, does not
depend on Phases 1-4b infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (lines 620-653,
  plus new interval lemma section)

**Verification**:
- [ ] `bx_until_eventuality_resolution` compiles sorry-free.
- [ ] Zero new axioms.
- [ ] `lake build` clean.
- [ ] Gate D passed.

---

### Phase 6: Backward Until + Full Until Closure [NOT STARTED]

**Goal**: Prove `bx_until_backward` in Frame.lean, then close the
two `until_eventuality_resolution` sorries and the one
`until_backward` sorry in Realization.lean by delegating to the
now-proved Frame.lean theorems.

**Tasks**:

- [ ] Prove `bx_until_backward` (Frame.lean:664-675):
  - Contradiction approach: assume `neg(phi U psi) in w`.
  - Use enriched seed `{neg(phi U psi)} U g_content(w) U h_content(v)`.
  - `enriched_seed_consistent_until` (already proven in Realization.lean)
    gives consistent seed. Extend to MCS `u` via Lindenbaum.
  - Establish `bx_le w u` (from g_content(w) in seed) and
    `bx_le u v` (from h_content(v) in seed via
    `h_content_subset_implies_g_content_reverse`).
  - Show `not bx_le v u`: from `psi in v` and BX8 (`psi -> phi U psi`),
    `phi U psi in v`. If `bx_le v u`, then `G(phi U psi) in v` would
    give `phi U psi in u`, contradicting `neg(phi U psi) in u`. Need
    `G(phi U psi) in v` -- from BX4 on `phi U psi in v`:
    `G(P(phi U psi)) in v`, not `G(phi U psi)` directly. Use
    alternative: from `bx_le u v` and `F(psi) in u` (established via
    F_from_above), apply BX7 to `neg(phi U psi)` analysis and derive
    contradiction.
  - Apply guard: `phi in u`. Derive `phi in u and neg(phi U psi) in u`.
  - Use BX7 on `(top U psi)` and the temporal structure to derive
    that `psi` must be reached before or at `v`, contradicting
    `neg(phi U psi) in u` when combined with the guard.
- [ ] Close Realization.lean sorries (lines 499-500, 503-504, 564):
  - Replace `until_eventuality_resolution` body with delegation to
    `Frame.bx_until_eventuality_resolution`.
  - Replace `until_backward` body with delegation to
    `Frame.bx_until_backward`.
- [ ] Verify: `lean_verify` on all three theorems.
- [ ] **GATE E**: Both Frame.lean Until theorems sorry-free.

**Timing**: 8-14 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (lines 664-675)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  (lines 471-564)

**Verification**:
- [ ] `bx_until_backward` compiles sorry-free.
- [ ] `until_eventuality_resolution` and `until_backward` in
  Realization.lean compile sorry-free.
- [ ] Zero new axioms.
- [ ] `lake build` clean.
- [ ] Gate E passed.

---

### Phase 7: Since Mirrors [NOT STARTED]

**Goal**: Prove `bx_since_eventuality_resolution` and
`bx_since_backward` in Frame.lean by mirroring the Until proofs
with h_content/BX5'/BX7'/BX9'/BX10'/BX11'/BX12'. Then close the
three Since sorries in Realization.lean.

**Tasks**:

- [ ] Prove `bx_since_eventuality_resolution` (Frame.lean:683-690):
  mirror of Phase 5 using `bx_backward_witness`, h_content,
  BX5' (since self-accumulation), BX4' (connect_past),
  BX7' (since linearity), BX10' (S -> P), BX12' (P -> top S).
- [ ] Prove `bx_since_backward` (Frame.lean:697-704):
  mirror of Phase 6 backward direction using h_content seed,
  `enriched_seed_consistent_since`.
- [ ] Close Realization.lean Since sorries (lines 589-592, 622):
  - `since_eventuality_resolution`: delegate to Frame.lean.
  - `since_backward`: delegate to Frame.lean.
- [ ] Verify: `lean_verify` on all four Since theorems.

**Timing**: 6-10 hours

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (lines 683-704)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  (lines 566-622)

**Verification**:
- [ ] `bx_since_eventuality_resolution` and `bx_since_backward`
  compile sorry-free.
- [ ] `since_eventuality_resolution` and `since_backward` in
  Realization.lean compile sorry-free.
- [ ] Zero new axioms.
- [ ] `lake build` clean.

---

### Phase 8: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify all 10 targeted sorries are closed, run full
project build, audit axioms, and clean up documentation.

**Tasks**:

- [ ] Full `lake build` at project root.
- [ ] `lean_verify` on all 10 closed theorems (4 Frame.lean +
  6 Realization.lean) confirms only `[propext, Classical.choice,
  Quot.sound]`.
- [ ] Verify Frame.lean lines 140-583 are untouched (only lines
  620-707 modified).
- [ ] Verify TruthLemma.lean is unchanged.
- [ ] Update sorry-count documentation in Realization.lean header
  and Frame.lean module docstring.
- [ ] Remove or update the phase 5 blocker analysis status
  comments in Frame.lean (lines 628-631, 658-662, 681, 695) to
  reflect that the sorries are now closed.
- [ ] Verify Completeness.lean sorry (line 154, TaskModel embedding)
  is unaffected (it depends on separate task 93 work).

**Timing**: 2-4 hours

**Depends on**: 5, 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (documentation
  updates only)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  (header documentation only)

**Verification**:
- [ ] Zero sorries in Frame.lean for the four targeted theorems.
- [ ] Zero sorries in Realization.lean for the six targeted theorems.
- [ ] `lake build` clean at project root.
- [ ] No new axioms anywhere.
- [ ] Task 98 ready for `[COMPLETED]` status.

---

## Testing & Validation

- [ ] `lake build` clean at project root at the end of each phase.
- [ ] Sorry count decreases monotonically: 4 after Phase 5, 2-3 after
  Phase 6, 0 after Phase 7.
- [ ] `lean_verify` on every theorem closed in Phases 5-8 shows only
  standard Lean/Mathlib axioms (`propext`, `Classical.choice`,
  `Quot.sound`). **No new axioms are acceptable.**
- [ ] Frame.lean lines 140-583 unchanged (verify with `git diff`).
- [ ] TruthLemma.lean unchanged.
- [ ] Task 99 declarations unchanged (reference-only).
- [ ] Completeness.lean sorry (TaskModel embedding) unaffected.

## Artifacts & Outputs

- `specs/098_research_filtration_quasimodel_pivot/plans/05_quasimodel-pivot-plan.md` (this file)
- Updates to `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
  (Phases 5, 6, 7: four sorry theorems replaced with proofs + interval
  lemma library)
- Updates to `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  (Phases 6, 7: six sorry theorems replaced with Frame.lean delegations)
- Final implementation summary at
  `specs/098_research_filtration_quasimodel_pivot/summaries/05_implementation-summary.md`

## Rollback/Contingency

- **Per-phase rollback**: each phase is scoped to a single logical
  commit; `git revert` restores the prior state.
- **Gate D failure (end of Phase 5)**: BX7 approach does not close
  `bx_until_eventuality_resolution` after 15h. Evaluate:
  - If close but needs more time: extend budget by 10h.
  - If fundamentally blocked: trigger Phase 9 (quotient/filtration
    fallback).
- **Phase 9 (contingency -- quotient/filtration fallback)**: If the
  direct BX7 approach is abandoned, pivot to the quotient/filtration
  model construction (Path 3 from report 09). This is a well-understood
  construction from the literature (Goldblatt 1992, Blackburn et al.
  2001). Estimated 40-60h additional effort, 85% confidence. Would
  require: (a) equivalence relation on BXPoints by Sigma-agreement,
  (b) quotient ordering total by BX11, (c) quotient truth lemma,
  (d) lifting. This would be a new task (101+) rather than extending
  task 98.
- **Budget overrun (>50h)**: Descope remaining sorries into a new task.
  Ship whatever is proven, mark task 98 `[PARTIAL]`.
- **Baseline recovery**: `git reset` to the Phase 4b commit and mark
  task 98 `[BLOCKED]` pending fresh approach.
