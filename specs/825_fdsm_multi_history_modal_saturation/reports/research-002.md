# Research Report: Task #825

**Task**: FDSM Multi-History Modal Saturation - Implementation Gap Analysis
**Date**: 2026-02-03
**Focus**: Analyzing what was planned vs what was implemented in task 816
**Session ID**: sess_1770087038_6c6841

## Summary

The implementation-003.md plan for task 816 outlined a 6-phase FDSM construction to achieve sorry-free completeness. While Phase 4 (Saturation Fixed Point) was marked [DEFERRED] in the plan, the actual implementation took a shortcut by using a **single-history construction** that trivializes modal semantics. This report analyzes the gap between the planned multi-history modal saturation approach and the implemented single-history workaround.

## 1. Implementation Plan Analysis

### 1.1 Phase Status Summary

| Phase | Name | Plan Status | Actual Status | Gap |
|-------|------|-------------|---------------|-----|
| 1 | FDSM Core Structures | [COMPLETED] | Implemented | Minimal |
| 2 | Temporal Saturation | [COMPLETED] | Partially implemented | Helper lemmas, no coherence proof |
| 3 | Modal Saturation Construction | [COMPLETED] | Partially implemented | Framework only, key lemmas sorry |
| 4 | Saturation Fixed Point | [DEFERRED] | Not implemented | Complete gap |
| 5 | FDSM Truth Lemma | [COMPLETED] | Mostly sorry | All non-trivial cases sorry |
| 6 | Validity Bridge and Completeness | [COMPLETED] | Single-history workaround | Trivializes modal semantics |

### 1.2 Phase 1: FDSM Core Structures

**Planned**:
- FDSMTime, FDSMWorldState, FDSMHistory types
- FiniteDynamicalSystemModel with modal_saturated field
- Temporal coherence constraints in FDSMHistory

**Implemented**:
- Types defined correctly (Core.lean lines 66-72)
- FiniteDynamicalSystemModel structure exists (lines 189-213)
- `modal_saturated` field has **sorry** at line 205 for closure membership

**Gap**: The `modal_saturated` field definition includes a sorry in its type signature for closure membership. Additionally, FDSMHistory lacks built-in temporal coherence constraints - these were deferred to the model level.

### 1.3 Phase 2: Temporal Saturation

**Planned**:
- `temporally_saturated_history` construction
- `finite_temporal_backward_G` and `finite_temporal_backward_H` theorems
- Prove backward coherence for finite time domain

**Implemented**:
- `futureSet`, `pastSet` with membership lemmas (Core.lean lines 84-118)
- `finite_all_future_holds`, `finite_all_past_holds` (lines 326-342)
- `decidableFutureAll`, `decidablePastAll` (lines 376-388)
- Constant history helpers (lines 400-416)

**Gap**: The phase intended to prove that finite time domain makes temporal backward directions **provable**, but the actual implementation only provides helper lemmas. No proof exists that constant histories satisfy temporal coherence, nor that `G psi` can be derived from finite conjunction in the MCS.

### 1.4 Phase 3: Modal Saturation Construction

**Planned**:
- `diamond_formulas` identification
- `witness_set` construction
- `witness_set_consistent` theorem
- `add_witness_history` that produces valid FDSMHistory

**Implemented**:
- `isDiamondFormula`, `diamondInner?` (ModalSaturation.lean lines 55-65)
- `witnessSet` definition with membership lemmas (lines 82-99)
- `witness_set_consistent` - **HAS 2 SORRIES** (lines 190, 212)
- `modal_backward_from_saturation` - **HAS SORRY** (line 280)

**Gap**: The core lemma `witness_set_consistent` is not proven. This is the critical lemma that enables adding witness histories. Without it, the saturation construction cannot proceed. The sorry requires proving that if the witness set is inconsistent, then Box(neg psi) is derivable, contradicting the diamond assumption.

### 1.5 Phase 4: Saturation Fixed Point [CRITICAL GAP]

**Planned**:
- `saturation_step` - one round of adding witnesses
- `saturated_histories` - fixed-point construction
- Termination proof via 2^closureSize bound
- `saturated_histories_modal_saturated` theorem
- `saturated_modal_backward` derivation

**Implemented**:
- `needsWitness` - **placeholder returning none** (lines 292-297)
- `maxHistories` definition only (lines 304-305)

**Gap**: **This phase was entirely skipped.** The plan explicitly marked it [DEFERRED], and the implementation matches. No saturation step, no fixed-point construction, no termination proof, no saturation property theorem. This is the most significant gap.

### 1.6 Phase 5: FDSM Truth Lemma

**Planned**:
- `fdsm_truth_at` definition
- `fdsm_truth_lemma` by structural induction
- All six cases (atom, bot, imp, box, G, H) sorry-free

**Implemented**:
- `fdsm_truth_at` definition with sorry in atom case (TruthLemma.lean lines 72-85)
- `fdsm_truth_lemma` structure exists (lines 148-225)
- Individual case lemmas attempted

**Gap**: **13 sorries in TruthLemma.lean.** The key cases that were supposed to be solved by FDSM:
- Box backward (line 200) - requires modal saturation
- G backward (line 214) - supposed to be finite conjunction
- H backward (line 225) - supposed to be finite conjunction

### 1.7 Phase 6: Completeness

**Planned**:
- `fdsm_to_task_frame`, `fdsm_to_task_model` bridging
- `fdsm_weak_completeness` for Validity.lean semantics
- Alternative `fdsm_internal_completeness` directly

**Implemented**:
- `fdsm_from_closure_mcs` using **single history** (Completeness.lean lines 67-91)
- `fdsm_internal_completeness` theorem (lines 240-249)
- `neg_consistent_of_not_provable` helper (lines 151-174)

**Gap**: The implementation uses a **single-history construction** that trivializes modal semantics:
- Box phi becomes equivalent to phi (line 77 comment admits this)
- modal_saturated is satisfied trivially because with one history, Diamond psi = psi
- This validates **invalid modal principles** as warned in research-013.md

## 2. Root Cause Analysis

### 2.1 Why Single-History Was Used

The single-history approach was a **shortcut** to avoid implementing Phase 4. From Completeness.lean lines 64-66:

```
This is the simplest FDSM construction - a single constant history.
...
Note: This construction satisfies modal saturation trivially because
there's only one history.
```

And lines 77-78:

```
In single-history semantics, Box chi = chi for all chi
So Diamond psi = neg(neg psi) = psi
```

This is mathematically correct but **semantically wrong** - it collapses the modal dimension.

### 2.2 Why Phase 4 Was Deferred

The plan marked Phase 4 as [DEFERRED] likely due to:
1. **Complexity**: The saturation fixed-point requires proving termination
2. **Dependencies**: Requires `witness_set_consistent` which has sorries
3. **Time constraints**: Other phases were prioritized

### 2.3 The Technical Debt

The current implementation has **28 sorries** across the FDSM module:
- Core.lean: 1 sorry (modal_saturated closure membership)
- ModalSaturation.lean: 3 sorries (witness_set_consistent x2, modal_backward)
- TruthLemma.lean: 13+ sorries (closure membership, case proofs)
- Completeness.lean: 3 sorries (modal_saturated proof, MCS lemmas)

## 3. What research-014.md Promised vs Reality

### 3.1 Promised Approach (research-014.md)

The research report correctly identified:
- Single-family BMCS cannot satisfy modal_backward (Section 5.1)
- Single-history TaskModel trivializes Box (Section 5.2)
- FBM/FDSM with multi-history and modal saturation solves both

Key quote from Section 5.4:
> "| Modal backward | Multi-history with saturation |"
> "| Modal trivialization | Multiple distinct histories |"

### 3.2 Reality (Completeness.lean)

The implementation **ignored** these insights and used exactly what research-014.md warned against:
- Single history construction (line 67)
- Modal trivialization (lines 77-78 comment)
- No multi-history saturation

The comments even acknowledge this:
> "The FDSM approach trades model expressiveness (single history) for proof simplicity"

This is a **known regression** from the research recommendations.

## 4. What Remains To Be Done

### 4.1 Core Missing Components

1. **Complete `witness_set_consistent`** (ModalSaturation.lean lines 121-212)
   - Requires modal necessitation reasoning
   - K axiom + Box distribution over finite context
   - Estimated: 50-100 lines of proof

2. **Implement `saturation_step`** (Phase 4)
   - `unsatisfiedDiamonds` - find diamond formulas without witnesses
   - `buildWitnessHistory` - construct witness from witness set
   - `saturation_step` - one round of adding witnesses

3. **Implement fixed-point construction**
   - Either fuel-based or well-founded recursion
   - Prove termination via 2^closureSize bound
   - Prove `is_modally_saturated` at fixed point

4. **Derive `modal_backward_from_saturation`**
   - Contrapositive: if psi at all histories, Box psi holds
   - Uses MCS negation completeness + saturation

5. **Update Completeness.lean**
   - Replace `fdsm_from_closure_mcs` with multi-history construction
   - Use `saturated_histories` instead of single history
   - Preserve completeness theorem structure

6. **Complete TruthLemma.lean**
   - Fix closure membership alignment sorries
   - Prove box backward using modal saturation
   - Prove temporal backward using finite conjunction

### 4.2 Estimated Effort

| Task | Lines | Hours |
|------|-------|-------|
| witness_set_consistent | 50-100 | 2-3 |
| saturation_step + helpers | 100-150 | 2-3 |
| Fixed-point + termination | 80-120 | 2-3 |
| modal_backward derivation | 40-60 | 1-2 |
| Update Completeness.lean | 50-80 | 1-2 |
| Fix TruthLemma sorries | 100-150 | 3-4 |
| **Total** | **420-660** | **11-17** |

### 4.3 Dependency Order

```
witness_set_consistent
    |
    v
buildWitnessHistory
    |
    v
saturation_step
    |
    v
saturated_histories (fixed point)
    |
    +--> is_modally_saturated theorem
    |
    +--> modal_backward_from_saturation
              |
              v
         Update Completeness.lean
              |
              v
         Fix TruthLemma sorries
```

## 5. Recommendations

### 5.1 Implementation Strategy

**Recommended approach**: Bottom-up from `witness_set_consistent`

1. **First**: Complete `witness_set_consistent` with full modal reasoning
   - This is the foundational lemma everything else depends on
   - Requires explicit K axiom + necessitation infrastructure

2. **Second**: Build saturation infrastructure
   - Implement helper functions for diamond detection
   - Build witness history construction
   - Implement saturation step

3. **Third**: Fixed-point and termination
   - Use fuel-based approach (simpler than well-founded recursion)
   - Prove cardinality bounds
   - Derive saturation property

4. **Fourth**: Connect to completeness
   - Replace single-history construction
   - Verify truth lemma cases work with multi-history

### 5.2 Alternative: Accept Single-History Limitation

If the multi-history implementation proves too complex, the project could:
- Document that FDSM uses single-history semantics
- Note that this validates weaker modal principles
- Keep existing FMP.semantic_weak_completeness as the "real" result
- Mark FDSM as an alternative approach with limitations

**Not recommended** - this leaves the original problem unsolved.

### 5.3 Incremental Approach

The existing research-001.md for task 825 provides detailed implementation guidance. That report should be used alongside this gap analysis to guide Phase 4 completion.

## 6. Sorries Inventory

### 6.1 Blocking Sorries (Must Fix)

| File | Line | Function | Issue |
|------|------|----------|-------|
| ModalSaturation.lean | 190, 212 | witness_set_consistent | Modal necessitation proof |
| ModalSaturation.lean | 280 | modal_backward_from_saturation | Closure + saturation |
| Core.lean | 205 | modal_saturated field | Closure membership |
| Completeness.lean | 87 | fdsm_from_closure_mcs.modal_saturated | Single-history trivial |

### 6.2 Downstream Sorries (Will Resolve)

| File | Lines | Issue |
|------|-------|-------|
| TruthLemma.lean | 76, 119, 133 | Closure membership alignment |
| TruthLemma.lean | 160-163 | Atom case closure alignment |
| TruthLemma.lean | 184, 187, 195, 200, 208, 214, 221, 225 | Induction cases |
| Completeness.lean | 123, 142 | MCS bridge lemmas |

## 7. Conclusion

The implementation-003.md plan correctly identified that FDSM with multi-history modal saturation would eliminate the target sorries. However, Phase 4 was skipped, and the implementation took a shortcut using single-history construction that trivializes modal semantics.

**Key finding**: The current FDSM implementation has Box phi equivalent to phi, which validates invalid modal principles. This is the exact problem research-013.md and research-014.md warned against.

**Action required**: Implement Phase 4 (saturation fixed point) to restore proper multi-history modal semantics and achieve a mathematically sound completeness proof.

## References

### Codebase Files Analyzed
- `specs/816_bmcs_temporal_modal_coherence_strengthening/plans/implementation-003.md` - Original 6-phase plan
- `specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-014.md` - FBM/FDSM strategy
- `Theories/Bimodal/Metalogic/FDSM/Core.lean` - FDSM type definitions
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Partial Phase 3
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean` - Truth lemma with sorries
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` - Single-history workaround

### Prior Research
- research-001.md (task 825) - Detailed Phase 4 implementation guidance
- research-013.md (task 816) - Multi-family modal saturation analysis
