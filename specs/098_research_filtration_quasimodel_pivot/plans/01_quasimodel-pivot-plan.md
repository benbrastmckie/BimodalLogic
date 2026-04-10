# Implementation Plan: Local Hintikka-Set Quasimodel for Until/Since Truth Lemma

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Status**: [PARTIAL]
- **Effort**: 25-45 hours
- **Dependencies**: None (independent of tasks 96, 97; parallel research track)
- **Research Inputs**: specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md
- **Artifacts**: plans/01_quasimodel-pivot-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan implements the "local Hintikka-set quasimodel" approach recommended by the task 98 research report to close the four Until/Since sorries in `BXCanonical/Frame.lean` (lines 653, 675, 690, 704). The approach introduces a new `Quasimodel.lean` module containing finite subformula closures, Hintikka point definitions, a Burgess-Xu one-step quasimodel construction with defect-discharge, and a realization lifting lemma that converts quasimodel chains back to BXPoint chains. The existing Box/G/H infrastructure in `Frame.lean` and `TruthLemma.lean` remains entirely untouched. Definition of done: `lake build` succeeds with the four Until/Since sorries replaced by proofs, and no new sorries introduced.

### Research Integration

Key findings from the research report (01_filtration-quasimodel-pivot.md):
- Classical filtration is rejected: quotienting destroys the `g_content`-based order needed by Box/G/H.
- The local quasimodel variant keeps BXPoint for Box/G/H and introduces Hintikka sets only at the Until/Since step.
- Cascade-cost audit: zero existing sorry-free theorems need re-proof under the local variant.
- Two load-bearing lemmas identified: realization lifting (step 3) and locus-control (step 5).
- Effort decomposed into 6 subtasks (S1-S6) totaling 25-45h.
- Conditions: C1 (realization lifting proven early), C2 (Sigma-closure rich enough), C3 (Since standalone), C4 (bx_le unchanged).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the following roadmap items from `specs/ROAD_MAP.md`:
- **Task 92**: "Implement chosen Until/Since approach; close 4 Frame.lean sorries" -- this plan provides the structural approach for closing those sorries.
- **Completeness pipeline**: Phases 4-5 of the roadmap (tasks 90 -> 92 -> 93 -> 95) depend on closing the Until/Since sorries. This plan is the implementation path for the task-92 blocker.
- **Sorry count reduction**: Closes 4 of 6 active-path sorries, leaving only Box modal-witness (task 93) and TaskModel embedding (task 93).

## Goals & Non-Goals

**Goals**:
- Define `SubformulaClosure` (finite Sigma-closure) with closure operations for negation, subformulas, and Burgess-Xu accumulate/absorb
- Define `HintikkaPoint` over a Sigma-closure with local consistency, maximality, and BX truth conditions
- Construct a Burgess-Xu one-step quasimodel with defect-discharge for Until formulas
- Prove the realization lifting lemma: lift Hintikka chains to BXPoint chains with `bx_le`
- Prove the locus-control lemma: arbitrary strict-interval BXPoints map to quasimodel indices via Sigma-signatures
- Close the four sorry targets: `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`
- Maintain `lake build` clean with zero new sorries

**Non-Goals**:
- Modifying any existing sorry-free theorem in Frame.lean (lines 140-583)
- Modifying TruthLemma.lean G/H/Box cases
- Building the TaskModel embedding (that is task 93)
- Implementing a global quasimodel (replacing BXPoint everywhere)
- Implementing classical filtration
- Proving the finite model property

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Realization lifting lemma fails over general linear orders | H | Low (10-20%) | Gate in Phase 3: prove lifting before proceeding to Phase 4-5. If it fails, halt and escalate to global quasimodel fallback (40-60h). |
| Sigma-closure enrichment blows up beyond finite control | M | Very Low (<5%) | Use published Sigma-closure operator from Reynolds 1996 section 2 rather than inventing one. |
| Since mirror requires additional BX axiom support | M | Medium (20-30%) | Phase 5 budget allocates standalone Since construction. If new axiom needed, escalate to task 96 results. |
| Locus-control lemma needs more Sigma-formulas than expected | M | Low (10%) | Include all G(chi) and H(chi) for chi a subformula of the Until/Since target in Sigma-closure from the start (Phase 1). |
| Lean formalization of finite Hintikka enumeration is harder than pen-and-paper | M | Medium (25%) | Use `Finset` + `Decidable` instances throughout. Budget extra time in Phase 2. |
| Lake build breaks from new module import ordering | L | Low | Add Quasimodel.lean as downstream import of Frame.lean, upstream of TruthLemma.lean. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Sigma-Closure Infrastructure [COMPLETED]

**Goal**: Define the finite subformula closure type and prove its closure operations, providing the foundation for Hintikka points.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean`
- [ ] Define `SubformulaClosure (target : Formula) : Finset Formula` that includes:
  - The target formula and all its subformulas
  - Negation closure (for each chi in Sigma, neg chi in Sigma)
  - Burgess-Xu accumulate closure: if `phi U psi` in Sigma, then `(phi && (phi U psi)) U psi` in Sigma
  - Burgess-Xu absorb closure: if `phi U psi` in Sigma, then `phi U (phi && (phi U psi))` in Sigma
  - G/H enrichment: for each chi a subformula of the target Until/Since, `G(chi)` and `H(chi)` in Sigma (needed for locus-control)
- [ ] Prove `SubformulaClosure` is finite (`Finset`-valued)
- [ ] Prove basic membership lemmas: `target_mem`, `neg_mem`, `subformula_mem`, `accum_mem`, `absorb_mem`, `g_enrichment_mem`, `h_enrichment_mem`
- [ ] Prove `SubformulaClosure` is closed under the BX subformula relation
- [ ] Add module to `BXCanonical.lean` import list
- [ ] Verify `lake build` succeeds

**Timing**: 3-5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- add import

**Verification**:
- `lake build` succeeds
- `SubformulaClosure` produces a `Finset Formula` for any input formula
- All closure membership lemmas type-check without sorry

---

### Phase 2: HintikkaPoint Definition and Properties [COMPLETED]

**Goal**: Define the Hintikka point structure over a Sigma-closure with local consistency, maximality, and BX truth conditions, and prove basic decidability and equality properties.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean`
- [ ] Define `HintikkaPoint (Sigma : Finset Formula)` structure:
  - `formulas : Finset Formula` (subset of Sigma)
  - `subset_sigma : formulas ⊆ Sigma`
  - `locally_consistent : ∀ chi ∈ formulas, ¬chi ∉ formulas` (no formula and its negation)
  - `bot_free : Formula.bot ∉ formulas`
  - `locally_maximal : ∀ chi ∈ Sigma, chi ∈ formulas ∨ ¬chi ∈ formulas` (via negation closure)
  - BX truth conditions on Sigma:
    - `imp_closed`: `(phi.imp psi) ∈ formulas ↔ (phi ∈ formulas → psi ∈ formulas)` for `phi.imp psi ∈ Sigma`
    - `and_closed`: conjunction closure
    - `until_one_step`: `(phi U psi) ∈ formulas → psi ∈ formulas ∨ (phi ∈ formulas ∧ defect phi psi)` (local BX9-like condition)
    - `since_one_step`: mirror
- [ ] Prove `DecidableEq` for `HintikkaPoint Sigma` (via `Finset` decidability)
- [ ] Prove `Fintype (HintikkaPoint Sigma)` (finitely many subsets of a finite set)
- [ ] Define `sigma_signature (w : BXPoint) (Sigma : Finset Formula) : Finset Formula := w.formulas ∩ Sigma`
- [ ] Prove `sigma_signature` of any BXPoint yields a valid `HintikkaPoint` (the extraction lemma)
- [ ] Verify `lake build` succeeds

**Timing**: 4-6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` -- new file

**Verification**:
- `lake build` succeeds
- `Fintype (HintikkaPoint Sigma)` instance available
- `sigma_signature` extraction lemma proved without sorry

---

### Phase 3: Quasimodel Construction with Defect-Discharge [COMPLETED]

**Goal**: Construct the Burgess-Xu one-step quasimodel: a finite linear sequence of Hintikka points with the defect-discharge property for a given Until formula. This is the core mathematical construction.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
- [ ] Define the Burgess-Xu one-step relation `hintikka_step (h1 h2 : HintikkaPoint Sigma)` capturing:
  - G-propagation: `G(chi) ∈ h1 → chi ∈ h2` for `G(chi) ∈ Sigma`
  - H-backward: `H(chi) ∈ h2 → chi ∈ h1` for `H(chi) ∈ Sigma`
  - Until defect propagation: if `(phi U psi) ∈ h1` and `psi ∉ h1`, then `phi ∈ h1` and `(phi U psi) ∈ h2` (via BX5 self-accumulation)
- [ ] Define `UntilDefect (h : HintikkaPoint Sigma) (phi psi : Formula)` as `(phi U psi) ∈ h.formulas ∧ psi ∉ h.formulas`
- [ ] Construct the quasimodel chain: given a Hintikka point h0 with `UntilDefect h0 phi psi`, produce a finite sequence `h0, h1, ..., hk` where:
  - Each consecutive pair satisfies `hintikka_step`
  - `psi ∈ hk.formulas` (defect discharged)
  - `phi ∈ hi.formulas` for all i < k (guard maintained)
  - Termination: use `Fintype.card (HintikkaPoint Sigma)` as the well-founded measure (defects decrease or Hintikka sets change, bounded by finite cardinality)
- [ ] Prove `quasimodel_chain_exists`: the main existence theorem
- [ ] Prove `quasimodel_chain_guard`: the guard property for the strict interval
- [ ] Prove `quasimodel_chain_witness`: the discharge property at the endpoint
- [ ] Verify `lake build` succeeds

**Timing**: 6-10 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- new file

**Verification**:
- `lake build` succeeds
- `quasimodel_chain_exists` proved without sorry
- Chain guard and witness properties proved without sorry
- Termination proof accepted by Lean (no `partial` or `sorry` on termination)

---

### Phase 4: Realization Lifting Lemma [PARTIAL]

**Goal**: Prove that each step of the Hintikka quasimodel chain can be realized as a BXPoint, lifting the abstract chain to a concrete chain in the canonical model with `bx_le` between consecutive points. This is the first of two critical gate lemmas (condition C1).

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
- [ ] Define `realize_hintikka (h : HintikkaPoint Sigma) : BXPoint` using Lindenbaum extension:
  - Start with `h.formulas` as a seed
  - Show the seed is consistent (from Hintikka local consistency)
  - Apply Lindenbaum's lemma to extend to a full MCS
  - Wrap as BXPoint
- [ ] Prove `realize_preserves_membership`: `chi ∈ h.formulas → chi ∈ (realize_hintikka h).formulas`
- [ ] Prove `realize_preserves_non_membership`: `chi ∈ Sigma → chi ∉ h.formulas → chi ∉ (realize_hintikka h).formulas`
- [ ] Prove the **realization lifting lemma**: if `hintikka_step h1 h2` then there exist BXPoints `v1, v2` realizing `h1, h2` with `bx_le v1 v2`
  - Key argument: the combined seed `{chi | G(chi) ∈ v1} ∪ h2.formulas` is consistent
  - Uses `bx_forward_witness` from Frame.lean (existing, sorry-free) for the one-step extension
  - This is the Verbrugge "Completeness by Construction" lifting argument
- [ ] Prove chain realization: lift the entire quasimodel chain `h0, ..., hk` to BXPoints `v0, ..., vk` with `bx_le vi v(i+1)` for each i
- [ ] Prove `bx_le v0 vk` by transitivity (`bx_le_trans`, existing sorry-free)
- [ ] **GATE CHECK**: If the realization lifting lemma cannot be proved, HALT and report. Do not proceed to Phase 5.
- [ ] Verify `lake build` succeeds

**Timing**: 4-8 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- new file

**Verification**:
- `lake build` succeeds
- Realization lifting lemma proved without sorry
- Chain realization proved without sorry
- Gate check passed: proceed to Phase 5

---

### Phase 5: Locus-Control, Until/Since Helpers, and Sorry Closure [PARTIAL]

**Goal**: Prove the locus-control lemma, then use the full quasimodel machinery to close all four Until/Since sorries in Frame.lean. Since requires a standalone proof (not a dual rename of Until, per Phase 0 Probe 6).

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean`
- [ ] Prove the **locus-control lemma**: for any BXPoint `u` with `bx_le w u` and `bx_le u vk`, the Sigma-signature of `u` equals some `hi` in the quasimodel chain (index determined by position in the chain)
  - Key argument: Sigma-signatures are totally ordered by the Burgess-Xu one-step relation (quasimodel's defining property)
  - Uses G/H enrichment of Sigma from Phase 1 to ensure Sigma-signatures determine bx_le comparisons
- [ ] Prove `bx_until_eventuality_resolution`: replace the sorry at Frame.lean:653
  - Given: `phi U psi ∈ w.formulas`, `psi ∉ w.formulas`
  - Build Sigma-closure of `phi U psi`
  - Extract Hintikka point h0 from w's Sigma-signature
  - Apply quasimodel chain construction (Phase 3) to get discharge chain
  - Apply realization lifting (Phase 4) to get BXPoint chain
  - Apply locus-control to handle arbitrary strict-interval points
  - Return: witness BXPoint v with `bx_le w v`, `psi ∈ v`, and guard `phi ∈ u` for all u in (w, v)
- [ ] Prove `bx_until_backward`: replace the sorry at Frame.lean:675
  - Given: `bx_le w v`, `psi ∈ v`, guard `phi` on `[w, v)`, `psi ∉ w`
  - Show `phi U psi ∈ w.formulas` using BX8/BX9 and the guard/witness conditions
  - Contrapositive approach: assume `neg(phi U psi) ∈ w`, use BX4 to propagate, derive contradiction
- [ ] Prove `bx_since_eventuality_resolution`: replace the sorry at Frame.lean:690
  - **Standalone proof** (not a dual of Until): Since uses `h_content` and backward ordering
  - Mirror the Until construction using `bx_backward_witness`, Since-specific Sigma-closure, and H-propagation
  - BX5' (self_accum_since), BX9' (since_elim), BX10' (since_P) replace their Until counterparts
- [ ] Prove `bx_since_backward`: replace the sorry at Frame.lean:704
  - Standalone proof using BX8' (refl_intro_since) and BX4' (connect_past)
- [ ] Remove all four `sorry` placeholders from Frame.lean
- [ ] Verify `lake build` succeeds with zero new sorries in the quasimodel module

**Timing**: 6-12 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- replace 4 sorries with proof terms

**Verification**:
- `lake build` succeeds
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` returns zero matches for the four target locations
- No new sorries introduced in any Quasimodel/ file
- `#check @bx_until_eventuality_resolution` and `#check @bx_since_eventuality_resolution` succeed

---

### Phase 6: Integration, Build Verification, and Regression [COMPLETED]

**Goal**: Wire the new Quasimodel module into the BXCanonical import hierarchy, verify that no existing sorry-free proofs are broken, and confirm the sorry count reduction.

**Tasks**:
- [ ] Verify `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` imports the new Quasimodel submodules in the correct order
- [ ] Run `lake clean && lake build` to verify full clean build
- [ ] Verify that Frame.lean lines 140-583 (Box/G/H layer) have no changes via `git diff`
- [ ] Verify that TruthLemma.lean has no changes via `git diff`
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/` and confirm:
  - Frame.lean:440 (`bx_modal_witness`) still has sorry (task 93 scope)
  - Completeness.lean:154 (`bx_completeness`) still has sorry (task 93 scope)
  - The four Until/Since sorries at Frame.lean:653, 675, 690, 704 are gone
  - No new sorries in Quasimodel/ files
- [ ] Verify active-path sorry count reduced from 6 to 2
- [ ] Update roadmap sorry table if appropriate (read-only check -- actual update is out of scope)

**Timing**: 2-4 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- possibly adjust imports

**Verification**:
- `lake clean && lake build` succeeds
- Sorry count in BXCanonical/ reduced from 6 to 2
- No regressions: all previously sorry-free theorems remain sorry-free
- `git diff` confirms Frame.lean Box/G/H layer and TruthLemma.lean are untouched

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lake clean && lake build` succeeds after Phase 6
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/` shows exactly 2 sorries (bx_modal_witness, bx_completeness)
- [ ] Frame.lean lines 140-583 unchanged (verified by git diff)
- [ ] TruthLemma.lean unchanged (verified by git diff)
- [ ] `#check @bx_until_eventuality_resolution` type-checks without sorry
- [ ] `#check @bx_since_eventuality_resolution` type-checks without sorry
- [ ] `#check @bx_until_backward` type-checks without sorry
- [ ] `#check @bx_since_backward` type-checks without sorry
- [ ] Phase 4 gate check passed (realization lifting lemma proved)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` -- new file (Phase 1)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` -- new file (Phase 2)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- new file (Phase 3)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- new file (Phase 4)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- new file (Phase 5)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- modified: 4 sorries replaced (Phase 5)
- `specs/098_research_filtration_quasimodel_pivot/plans/01_quasimodel-pivot-plan.md` -- this plan
- `specs/098_research_filtration_quasimodel_pivot/summaries/01_quasimodel-pivot-summary.md` -- post-implementation

## Rollback/Contingency

- **Phase 4 gate failure (realization lifting)**: Halt implementation. The existing sorries remain. Escalate to the global quasimodel fallback (40-60h, replaces BXPoint with HintikkaPoint throughout) or wait for task 96 (new axiom) / task 97 (layered bx_le) results.
- **Since mirror failure (Phase 5)**: If Since requires an axiom not in the current BX set, halt the Since half and escalate to task 96. The Until half can still land independently, closing 2 of 4 sorries.
- **Build regression**: If any existing sorry-free proof breaks, immediately `git checkout` the affected file and investigate. The local quasimodel design guarantees no existing proofs are touched, so a regression indicates a bug in the new module's imports or instances.
- **Full rollback**: `git revert` the implementation commits. The new Quasimodel/ directory is self-contained and has no effect on the rest of the codebase when removed.
