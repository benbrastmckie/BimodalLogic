# Research Report: Task #577

**Task**: 577 - prove_compound_formula_bridge_cases
**Started**: 2026-01-18T23:13:15Z
**Completed**: 2026-01-19T00:00:00Z
**Effort**: 3-4 hours
**Priority**: High
**Dependencies**: 576 (completed)
**Sources/Inputs**: FiniteCanonicalModel.lean, Metalogic_v2/Representation/CanonicalModel.lean, Mathlib
**Artifacts**: specs/577_prove_compound_formula_bridge_cases/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Finding 1**: The compound formula cases (imp, box, all_past, all_future) in `truth_at_implies_semantic_truth` require MCS negation completeness which is NOW PROVEN via `closure_mcs_negation_complete` (line 681) using the closureWithNeg infrastructure from task 575.

- **Finding 2**: The theorem `mcs_imp_iff_material` (lines 1365-1400) contains the key material implication property needed for the `imp` case but has 2 sorries. These can be filled using `closure_mcs_negation_complete` and `closure_mcs_imp_closed`.

- **Finding 3**: The alternative proof path via `main_provable_iff_valid` in ContextProvability.lean is FULLY PROVEN, making the compound formula bridge cases in the old file potentially unnecessary. However, completing them would provide a cleaner direct proof.

- **Recommended approach**: Use `closure_mcs_negation_complete` to complete `mcs_imp_iff_material`, then use that to prove the imp case. For box/temporal cases, leverage the modal and temporal accessibility properties with negation completeness.

## Context & Scope

### What Was Researched

Task 577 requires proving 4 compound formula cases in `truth_at_implies_semantic_truth`:
1. `Formula.imp psi chi` (line 3959)
2. `Formula.box psi` (line 3969)
3. `Formula.all_past psi` (line 3975)
4. `Formula.all_future psi` (line 3980)

The research investigated:
1. Current state of the sorries in each case
2. Available infrastructure from tasks 575 (closureWithNeg) and 576 (negation completeness)
3. Relevant theorems in Metalogic_v2 that might provide patterns
4. Alternative proof strategies that bypass these lemmas

### Constraints

- Must use the closureWithNeg infrastructure established in task 575
- Must leverage the proven `closure_mcs_negation_complete` theorem
- Must maintain compatibility with `main_weak_completeness` proof structure
- Dependent task 578 blocks on this task's completion

## Findings

### 1. Implication Case Analysis

**Location**: `truth_at_implies_semantic_truth`, lines 3959-3967

**Current State**:
```lean
| Formula.imp psi chi =>
    -- truth_at for imp is material implication: truth_at psi → truth_at chi
    -- This is more complex as it requires recursive truth
    -- For the target formula phi = imp psi chi, we need models (imp psi chi)
    -- The assignment for implication is determined by consistency
    unfold FiniteWorldState.models
    -- The assignment for phi = psi.imp chi should be true if
    -- the world state is consistent
    sorry  -- Complex: requires understanding of assignment for compound formulas
```

**Required Approach**:

The key insight is that for MCS-derived world states, we have the equivalence:
```
(psi → chi) ∈ S ↔ (psi ∈ S → chi ∈ S)
```

This is captured by `mcs_imp_iff_material` (lines 1365-1400), which has 2 sorry gaps.

**Proving mcs_imp_iff_material**:

Forward direction (line 1388 sorry): If `(psi → chi) ∈ S` and `psi ∈ S`, then `chi ∈ S`
- Uses `closure_mcs_imp_closed` (lines 817-828) - PROVEN

Backward direction (line 1400 sorry): If `psi ∈ S → chi ∈ S`, then `(psi → chi) ∈ S`
- By contrapositive: if `(psi → chi) ∉ S`, then by `closure_mcs_negation_complete`, `(psi → chi).neg ∈ S`
- Need to show: `(psi → chi).neg ∈ S` implies `psi ∈ S ∧ chi ∉ S`
- This follows from consistency: if `(psi → chi).neg` and `chi` are both in S, derive contradiction

**Relevant Theorems**:
- `closure_mcs_negation_complete`: For ψ ∈ closure phi, either ψ ∈ S or ψ.neg ∈ S (PROVEN)
- `closure_mcs_imp_closed`: If (ψ → χ) ∈ S and ψ ∈ S, then χ ∈ S (PROVEN)
- `mcs_modus_ponens` (CanonicalModel.lean, line 274): Full MCS version (PROVEN)

### 2. Box Case Analysis

**Location**: `truth_at_implies_semantic_truth`, lines 3969-3973

**Current State**:
```lean
| Formula.box psi =>
    -- truth_at for box: ∀ σ, truth_at M σ t psi
    -- This quantifies over ALL histories, which is very strong
    unfold FiniteWorldState.models
    sorry  -- Complex: requires modal consistency
```

**Required Approach**:

The box case requires connecting:
- `truth_at (SemanticCanonicalModel phi) tau 0 (Formula.box psi)`
- `(tau.states 0 ht).toFiniteWorldState.models (Formula.box psi) h_mem`

For MCS-derived states, `□ψ ∈ S` means ψ holds at all box-accessible worlds.

**Key Properties Needed**:
1. Box accessibility in canonical model: `∀ φ, □φ ∈ w.carrier → φ ∈ w'.carrier`
2. MCS property: For closure MCS, if `□ψ ∈ S` and ψ is accessible, then relevant subformulas transfer

**Relevant Theorems**:
- `mcs_box_accessibility` (CanonicalModel.lean, line 315): Box property for MCS (PROVEN)
- `finite_task_rel` box transfer (lines 1437-1440): Box transfer in finite model

### 3. Temporal Cases Analysis

**Location**: `truth_at_implies_semantic_truth`, lines 3975-3983

**all_past Case**:
```lean
| Formula.all_past psi =>
    -- truth_at for all_past: ∀ s < t, truth_at M τ s psi
    unfold FiniteWorldState.models
    sorry  -- Complex: requires temporal consistency
```

**all_future Case**:
```lean
| Formula.all_future psi =>
    -- truth_at for all_future: ∀ s > t, truth_at M τ s psi
    unfold FiniteWorldState.models
    sorry  -- Complex: requires temporal consistency
```

**Required Approach**:

Temporal cases follow similar pattern to box but with time direction:
- `Hψ ∈ S` means ψ held at all past times (strict: s < t)
- `Gψ ∈ S` means ψ will hold at all future times (strict: s > t)

**Key Properties Needed**:
1. Temporal accessibility: Past/future transfer in `finite_task_rel` (lines 1442-1450)
2. History construction: `finite_history_from_state` provides properly connected histories

**Complication**: The TM logic uses strict temporal semantics (∀ s < t, ∀ s > t), which differs from reflexive temporal logics. This is documented in `closure_mcs_implies_locally_consistent` (lines 1260-1270) as an architectural mismatch.

### 4. Alternative Proof Path

**Key Finding**: The Metalogic_v2 architecture provides a FULLY PROVEN alternative:

```lean
theorem representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ := by
  intro h_sem
  have h_valid : valid φ := (Validity.valid_iff_empty_consequence φ).mpr h_sem
  have h_prov : Nonempty (⊢ φ) := (main_provable_iff_valid φ).mpr h_valid
  exact h_prov
```

This theorem in ContextProvability.lean (lines 221-229) uses `main_provable_iff_valid` which is PROVEN in FiniteCanonicalModel.lean. The comment on line 214 confirms "Status: Fully proven, no sorries."

**Implication**: The compound formula cases may be bypassed entirely for the core completeness result. However, proving them provides:
1. Direct understanding of the MCS→semantic bridge
2. Foundation for other theorems that may need this bridge
3. Cleaner proof of `main_weak_completeness` without the contrapositive detour

### 5. Infrastructure Summary

| Theorem | Location | Status | Needed For |
|---------|----------|--------|------------|
| `closure_mcs_negation_complete` | FCM:681-811 | PROVEN | All cases |
| `closure_mcs_imp_closed` | FCM:817-828 | PROVEN | imp case |
| `mcs_imp_iff_material` | FCM:1365-1400 | 2 sorries | imp case |
| `closure_mcs_implies_locally_consistent` | FCM:1048 | 1 sorry | All cases |
| `worldStateFromClosureMCS_models_iff` | FCM:1282-1299 | PROVEN | All cases |
| `mcs_box_accessibility` | CM:315-318 | PROVEN | box case |
| `finite_task_rel` | FCM:1434-1462 | PROVEN | temporal cases |

(FCM = FiniteCanonicalModel.lean, CM = CanonicalModel.lean)

## Decisions

1. **Priority Strategy**: Focus on completing `mcs_imp_iff_material` first, as it unlocks the imp case and provides the pattern for other cases.

2. **Architecture Choice**: The compound formula cases SHOULD be proven to provide a direct bridge, even though an alternative path exists. This enables simpler proofs of dependent theorems.

3. **Temporal Caveat**: The temporal cases (all_past, all_future) have an architectural complexity due to strict temporal semantics. These may need to be marked as [PARTIAL] if the reflexivity issue cannot be resolved.

## Recommendations

1. **Prove mcs_imp_iff_material (1-2 hours)**:
   - Forward: Already uses `closure_mcs_imp_closed`, just need to remove sorry
   - Backward: Use negation completeness and derive contradiction from `(psi → chi).neg ∈ S` with `chi ∈ S`

2. **Prove imp case in truth_at_implies_semantic_truth (1 hour)**:
   - Use `mcs_imp_iff_material` to establish material implication equivalence
   - Connect to `FiniteWorldState.models` via `worldStateFromClosureMCS_models_iff`

3. **Prove box case (1 hour)**:
   - Use box accessibility from canonical model construction
   - Apply negation completeness for the "if not box, then diamond neg" argument

4. **Assess temporal cases (1-2 hours)**:
   - Review strict vs reflexive temporal semantics issue
   - Either prove using strict semantics or document as architectural limitation

5. **Alternative path**: If any case proves intractable, document the limitation and rely on the proven `representation_theorem_backward_empty` path.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Temporal reflexivity mismatch | High | Document as architectural limitation, use alternative path |
| Negation closure complexity | Medium | closureWithNeg infrastructure already handles this |
| Proof complexity escalation | Medium | Start with imp case as proof of concept |
| Dependent task 578 blocked | High | Alternative path via representation_theorem provides backup |

## Appendix

### Search Queries Used

1. `lean_local_search("closure_mcs")` - Found 6 related theorems
2. `lean_local_search("mcs_imp")` - Found `mcs_imp_iff_material`
3. `lean_local_search("mcs_box")` - Found `mcs_box_accessibility`
4. `lean_leansearch("maximal consistent set implication membership iff material implication")` - Found Mathlib patterns
5. `lean_leanfinder("maximal consistent set implication if and only if material implication monotonicity")` - Found theoretical context

### File Locations

| Theorem | File | Lines | Status |
|---------|------|-------|--------|
| `closure_mcs_negation_complete` | FiniteCanonicalModel.lean | 681-811 | PROVEN |
| `mcs_imp_iff_material` | FiniteCanonicalModel.lean | 1365-1400 | 2 SORRIES |
| `truth_at_implies_semantic_truth` | FiniteCanonicalModel.lean | 3920-3983 | 5 SORRIES |
| `representation_theorem_backward_empty` | ContextProvability.lean | 221-229 | PROVEN |
| `main_provable_iff_valid` | FiniteCanonicalModel.lean | ~4800 | PROVEN |

### Proof Sketch for imp case

```lean
| Formula.imp psi chi =>
  -- h_truth : truth_at (SemanticCanonicalModel phi) tau 0 (psi.imp chi)
  -- Goal: (tau.states 0 ht).toFiniteWorldState.models (psi.imp chi) h_mem

  -- The SemanticWorldState at tau.states 0 is MCS-derived
  -- Get the underlying MCS
  obtain ⟨S, h_mcs, h_eq⟩ := semantic_world_state_is_mcs_derived phi (tau.states 0 ht)

  -- truth_at for imp: ¬truth_at psi ∨ truth_at chi (material implication)
  -- Convert to MCS membership via IH or direct argument

  -- Use mcs_imp_iff_material: (psi.imp chi ∈ S) ↔ (psi ∈ S → chi ∈ S)
  -- The truth_at semantics gives us the right-hand side
  -- Therefore psi.imp chi ∈ S

  -- By worldStateFromClosureMCS_models_iff: psi.imp chi ∈ S ↔ models psi.imp chi
  -- QED
```

### Sorry Census in FiniteCanonicalModel.lean

Total sorries: ~45 (many are in non-critical lemmas)

Critical sorries for this task:
1. Line 1388: `mcs_imp_iff_material` forward direction (uses closure_mcs_imp_closed, should be fillable)
2. Line 1400: `mcs_imp_iff_material` backward direction (needs negation completeness argument)
3. Line 3967: `truth_at_implies_semantic_truth` imp case (needs mcs_imp_iff_material)
4. Line 3973: `truth_at_implies_semantic_truth` box case (needs box accessibility argument)
5. Line 3978: `truth_at_implies_semantic_truth` all_past case (temporal consistency)
6. Line 3983: `truth_at_implies_semantic_truth` all_future case (temporal consistency)

### Alternative Architecture Note

The Metalogic_v2 architecture in `ContextProvability.lean` demonstrates that the representation theorem IS fully proven via Strategy C:
1. `semantic_consequence [] φ` → `valid φ` via `valid_iff_empty_consequence`
2. `valid φ` → `Nonempty (⊢ φ)` via `main_provable_iff_valid`
3. `Nonempty (⊢ φ)` → `ContextDerivable [] φ` (trivial)

This means completeness IS achieved, but through a contrapositive argument rather than a direct MCS→semantic bridge. Task 577 aims to provide the direct bridge for conceptual clarity and future use.
