# Implementation Plan: Task #750

**Task**: Refactor forward Truth Lemma - Remove sorries
**Version**: 005
**Created**: 2026-01-29
**Language**: lean
**Research Input**: research-011.md (Approach 1: MCS-Restricted Truth Lemma)

## Overview

This plan implements **Approach 1: MCS-Restricted Truth Lemma** from research-011.md. Instead of proving truth correspondence for ALL `SemanticWorldState` instances (which fails due to the `IsLocallyConsistent` gap), we restrict to `MCSDerivedWorldState` - a subtype of states built from Closure Maximal Consistent sets.

### Key Insight

The gap in `truth_at_implies_semantic_truth` exists because `IsLocallyConsistent` only enforces the **modus ponens direction** for implications:
- `v(psi -> chi) = true AND v(psi) = true → v(chi) = true`

But for truth correspondence, we need the **biconditional**:
- `v(psi -> chi) = true ↔ (v(psi) = true → v(chi) = true)`

MCS-derived states have this biconditional via `closure_mcs_imp_iff` (already proven in Closure.lean).

### Existing Infrastructure

Already available (sorry-free):
- `IsMCSDerived phi w` - predicate in FiniteWorldState.lean (line 479)
- `worldStateFromClosureMCS_is_mcs_derived` - construction yields MCS-derived states
- `closure_mcs_imp_iff` - implication biconditional for MCS
- `closure_mcs_neg_complete` - negation completeness for MCS
- `worldStateFromClosureMCS_models_iff` - membership equals assignment
- `semantic_weak_completeness` - sorry-free completeness theorem

### Why This Suffices for Completeness

1. `valid phi → ⊢ phi` needs: "If phi valid, then no countermodel"
2. `semantic_weak_completeness` constructs countermodels from MCS
3. All countermodels it produces ARE MCS-derived
4. So: `valid phi → true at all MCS-derived states → ⊢ phi`

We just need the middle implication: valid → true at MCS-derived states.

## Goals & Non-Goals

**Goals**:
- Create `MCSDerivedSemanticWorldState phi` subtype
- Prove `mcs_truth_correspondence`: truth_at ↔ assignment for MCS-derived states
- Prove `valid_implies_mcs_truth`: validity → semantic truth at MCS-derived states
- Remove sorry from completeness path (valid → provable)

**Non-Goals**:
- Fixing `truth_at_implies_semantic_truth` for arbitrary states (architecturally impossible)
- Removing sorries from TruthLemma.lean (different module, different purpose)
- Changing `FiniteWorldState` or `IsLocallyConsistent` definitions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box case requires MCS modal property not yet proven | High | Medium | Check MCSProperties.lean; add if needed |
| Temporal cases (all_past, all_future) complex | Medium | Medium | Use existing `set_mcs_all_future_all_future` patterns |
| Type coercion complexity between SemanticWorldState and FiniteWorldState | Medium | Low | Use explicit conversion functions |
| induction on Formula doesn't terminate | Low | Low | Lean's structural recursion handles this |

## Implementation Phases

### Phase 1: Define MCSDerivedSemanticWorldState [COMPLETED]

**Goal**: Create the restricted subtype that carries proof of MCS derivation

**Tasks**:
1. Create `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`
2. Define `MCSDerivedSemanticWorldState phi` as subtype:
   ```lean
   structure MCSDerivedSemanticWorldState (phi : Formula) where
     state : SemanticWorldState phi
     underlying_mcs : Set Formula
     underlying_mcs_proof : ClosureMaximalConsistent phi underlying_mcs
     derivation_proof : state.toFiniteWorldState = worldStateFromClosureMCS phi underlying_mcs underlying_mcs_proof
   ```
3. Prove `mk_from_closureMCS`: constructor from ClosureMCS
4. Prove `underlying_world_state_models_iff`: membership in MCS ↔ assignment in state
5. Add imports to parent module

**Files**:
- CREATE: `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`
- MODIFY: `Theories/Bimodal/Metalogic/FMP/FMP.lean` (add import)

**Verification**:
- `lake build Bimodal.Metalogic.FMP.MCSDerivedWorldState` succeeds
- No sorries in new file

---

### Phase 2: Prove MCS Truth Lemma for Propositions [COMPLETED]

**Goal**: Prove truth correspondence for base cases (atoms, negation, implication, bot)

**Depends on**: Phase 1

**Tasks**:
1. In MCSDerivedWorldState.lean, prove:
   ```lean
   theorem mcs_truth_at_atom (w : MCSDerivedSemanticWorldState phi)
       (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
       (h_eq : tau.states 0 ht = w.state)
       (p : Nat) (h_clos : Formula.atom p ∈ closure phi) :
       truth_at (SemanticCanonicalModel phi) tau 0 (Formula.atom p) ↔
       w.state.toFiniteWorldState.assignment ⟨Formula.atom p, h_clos⟩ = true
   ```
2. Prove `mcs_truth_at_bot` (should be trivial - bot is always false)
3. Prove `mcs_truth_at_imp` using `closure_mcs_imp_iff`
4. Prove `mcs_truth_at_neg` using MCS negation completeness

**Files**:
- MODIFY: `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`

**Verification**:
- All four base case theorems compile without sorry
- `lake build` succeeds

---

### Phase 3: Prove MCS Truth Lemma for Modal Cases [NOT STARTED]

**Goal**: Prove truth correspondence for box operator

**Depends on**: Phase 2

**Tasks**:
1. Verify/add MCS box property in MCSProperties.lean:
   ```lean
   theorem closure_mcs_box_iff (phi : Formula) (S : Set Formula)
       (h_mcs : ClosureMaximalConsistent phi S)
       (psi : Formula) (h_box_clos : Formula.box psi ∈ closure phi) :
       Formula.box psi ∈ S ↔ (∀ S', accessible_mcs S S' → psi ∈ S')
   ```
   (Check if this exists; may need different formulation for finite model)
2. Prove `mcs_truth_at_box`:
   ```lean
   theorem mcs_truth_at_box (w : MCSDerivedSemanticWorldState phi)
       (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
       (h_eq : tau.states 0 ht = w.state)
       (psi : Formula) (h_clos : Formula.box psi ∈ closure phi) :
       truth_at (SemanticCanonicalModel phi) tau 0 (Formula.box psi) ↔
       w.state.toFiniteWorldState.assignment ⟨Formula.box psi, h_clos⟩ = true
   ```
3. This is the hardest case - requires showing box truth matches assignment

**Key Insight**: In the canonical model, `box psi` is true at history tau iff psi is true at all accessible histories. For MCS-derived states, the accessibility is determined by MCS membership properties.

**Files**:
- MODIFY: `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` (if needed)
- MODIFY: `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`

**Verification**:
- `mcs_truth_at_box` compiles without sorry
- `lake build` succeeds

---

### Phase 4: Prove MCS Truth Lemma for Temporal Cases [NOT STARTED]

**Goal**: Prove truth correspondence for temporal operators

**Depends on**: Phase 3

**Tasks**:
1. Verify existing temporal MCS properties:
   - `set_mcs_all_future_all_future`
   - `set_mcs_all_past_all_past`
2. Prove `mcs_truth_at_all_future`:
   ```lean
   theorem mcs_truth_at_all_future (w : MCSDerivedSemanticWorldState phi)
       (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
       (h_eq : tau.states 0 ht = w.state)
       (psi : Formula) (h_clos : Formula.all_future psi ∈ closure phi) :
       truth_at (SemanticCanonicalModel phi) tau 0 (Formula.all_future psi) ↔
       w.state.toFiniteWorldState.assignment ⟨Formula.all_future psi, h_clos⟩ = true
   ```
3. Prove analogous `mcs_truth_at_all_past`
4. Handle `some_future`, `some_past` (should follow from all_future/all_past + negation)

**Files**:
- MODIFY: `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`

**Verification**:
- All temporal case theorems compile without sorry
- `lake build` succeeds

---

### Phase 5: Combine into Full Truth Lemma [NOT STARTED]

**Goal**: Prove the main MCS truth correspondence theorem by structural induction

**Depends on**: Phases 2-4

**Tasks**:
1. Prove the main theorem:
   ```lean
   theorem mcs_truth_correspondence (phi : Formula)
       (w : MCSDerivedSemanticWorldState phi)
       (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
       (h_eq : tau.states 0 ht = w.state)
       (psi : Formula) (h_clos : psi ∈ closure phi) :
       truth_at (SemanticCanonicalModel phi) tau 0 psi ↔
       w.state.toFiniteWorldState.assignment ⟨psi, h_clos⟩ = true
   ```
2. Proof by cases on psi structure, using lemmas from Phases 2-4
3. Verify structural recursion terminates (Formula is inductively defined)

**Files**:
- MODIFY: `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`

**Verification**:
- `mcs_truth_correspondence` compiles without sorry
- `lake build` succeeds

---

### Phase 6: Connect to Completeness [NOT STARTED]

**Goal**: Use MCS truth lemma to prove sorry-free completeness

**Depends on**: Phase 5

**Tasks**:
1. Prove that completeness countermodels are MCS-derived:
   ```lean
   theorem completeness_countermodel_is_mcs_derived (phi : Formula)
       (w : SemanticWorldState phi)
       (h_constructed : w is from semantic_weak_completeness construction) :
       ∃ mw : MCSDerivedSemanticWorldState phi, mw.state = w
   ```
2. Prove:
   ```lean
   theorem valid_implies_mcs_semantic_truth (phi : Formula) :
       valid phi → ∀ w : MCSDerivedSemanticWorldState phi,
         semantic_truth_at_v2 phi w.state (BoundedTime.origin _) phi
   ```
3. Update `sorry_free_weak_completeness` to use MCS path instead of calling `truth_at_implies_semantic_truth`

**Files**:
- MODIFY: `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`
- MODIFY: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

**Verification**:
- `valid_implies_mcs_semantic_truth` compiles without sorry
- `sorry_free_weak_completeness` compiles without sorry
- `lake build` succeeds with no sorries on critical path

---

### Phase 7: Documentation and Cleanup [NOT STARTED]

**Goal**: Document the architecture and clean up

**Depends on**: Phase 6

**Tasks**:
1. Add module docstring to MCSDerivedWorldState.lean explaining the approach
2. Mark `truth_at_implies_semantic_truth` as deprecated with comment explaining why
3. Update any README files in FMP/
4. Create implementation summary

**Files**:
- MODIFY: `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean`
- MODIFY: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- CREATE: `specs/750_refactor_forward_truth_lemma_remove_sorries/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- Documentation accurately describes the architecture
- No orphan sorries on completeness path

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new sorries introduced in MCSDerivedWorldState.lean
- [ ] `mcs_truth_correspondence` is sorry-free
- [ ] `valid_implies_mcs_semantic_truth` is sorry-free
- [ ] `sorry_free_weak_completeness` no longer transitively depends on any sorry
- [ ] Existing `semantic_weak_completeness` unaffected

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean` (new file)
- `specs/750_refactor_forward_truth_lemma_remove_sorries/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If MCS truth lemma proves infeasible:

**Partial Progress**:
1. Keep `MCSDerivedSemanticWorldState` definition (useful for future approaches)
2. Document which cases are proven, which have sorries
3. Mark remaining sorries with clear explanation of gap

**Fallback**: Implementation-004 (Hybrid Approach) remains as alternative

## Notes

**Relationship to prior plans**:
- v001-v003: Various approaches that encountered the same truth lemma gap
- v004: Hybrid approach bypassing truth lemma via algebraic consistency witness
- v005 (this): Directly proves truth lemma for restricted domain where it's provable

**Why this approach is sound**:
- Mathlib's `FirstOrder.Language.Theory.IsMaximal.mem_iff_models` follows same pattern
- Restricting to maximal/MCS structures is standard in completeness proofs
- We don't need truth lemma for ALL states - just the ones completeness uses
