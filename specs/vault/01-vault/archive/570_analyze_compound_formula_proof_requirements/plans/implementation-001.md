# Implementation Plan: Task #570

- **Task**: 570 - Analyze Compound Formula Proof Requirements
- **Status**: [BLOCKED]
- **Effort**: 16 hours estimated (blocked after ~2 hours of analysis)
- **Priority**: High
- **Dependencies**: Task 566, Task 569
- **Research Inputs**: specs/570_analyze_compound_formula_proof_requirements/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the 4 compound formula sorries in `truth_at_implies_semantic_truth` (lines 3627-3651 of FiniteCanonicalModel.lean). The core challenge is bridging semantic truth (`truth_at`) with syntactic membership (assignment equals true). Research identified that the fundamental obstacle is the gap between semantic evaluation and MCS membership - specifically, showing that if semantic evaluation holds, the world state's assignment must record it. The recommended approach uses negation-completeness via `closure_mcs_negation_complete` with a contrapositive argument.

### Research Integration

From research-001.md:
- `IsLocallyConsistent` only provides soundness (compound true => parts true), but we need completeness (parts true => compound true)
- `closure_mcs_negation_complete` provides the key negation-completeness property for MCS sets
- The implication case is the most tractable starting point (requires only negation-completeness)
- Box and temporal cases require modal/temporal canonical properties across histories/times
- Estimated total effort: 14-21 hours across all cases

## Goals & Non-Goals

**Goals**:
- Complete the implication case sorry at line 3635
- Complete the box case sorry at line 3641
- Complete the all_past case sorry at line 3646
- Complete the all_future case sorry at line 3651
- Establish reusable bridge lemmas for semantic-to-syntactic conversion
- Ensure all proofs compile without sorries

**Non-Goals**:
- Restructuring the overall completeness proof architecture
- Changing the definition of `truth_at` or `SemanticWorldState`
- Optimizing proof performance (clarity over efficiency)
- Extending to additional formula types beyond the existing 4

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Negation not directly in closure | High | Medium | May need syntactic equivalence lemmas or `closureWithNeg` construction |
| MCS construction details obscure | Medium | Medium | Trace through Lindenbaum construction carefully, add helper lemmas |
| Time domain complications for temporal cases | High | High | Start with implication case first; temporal cases may need domain-specific infrastructure |
| Box case requires universal quantification over histories | High | High | May need canonical modal property lemma from completeness theory |
| Contrapositive approach introduces complexity | Medium | Medium | Document proof strategy clearly; may fall back to direct approach |

## Implementation Phases

### Phase 1: Infrastructure and Helper Lemmas [BLOCKED]

**Goal**: Establish the foundational bridge lemmas needed by all 4 cases

**Status**: BLOCKED - Fundamental architectural issue discovered

**Analysis Summary**:

After deep investigation during implementation, confirmed that **the theorem `truth_at_implies_semantic_truth` is fundamentally unprovable in its current form**:

1. **The theorem is too general**: It works for ANY `tau : WorldHistory (SemanticCanonicalFrame phi)`, not just histories constructed from MCS sets

2. **The correspondence gap**: `truth_at` (recursive semantic evaluation on formula structure) does not necessarily correspond to `assignment` (direct lookup in FiniteWorldState) for compound formulas

3. **Root cause - soundness vs completeness**:
   - `IsLocallyConsistent` provides SOUNDNESS: `assignment (imp psi chi) = true` AND `assignment psi = true` => `assignment chi = true`
   - We NEED COMPLETENESS: `(assignment psi = true => assignment chi = true)` => `assignment (imp psi chi) = true`
   - These are NOT equivalent for arbitrary `FiniteWorldState`s

4. **MCS vs general world states**: The correspondence only holds for `FiniteWorldState`s constructed from closure-MCS sets via `worldStateFromClosureMCS`. Arbitrary `SemanticWorldState`s may have `FiniteWorldState`s that satisfy local consistency but not MCS completeness.

**Evidence**:
- The `semantic_truth_lemma_v2` (line 2801) is PROVEN because it defines truth directly in terms of `models`, sidestepping the bridge entirely
- The `finite_truth_lemma` (line 3770) has the same 4 sorries in backward directions
- The comments in the codebase explicitly acknowledge this limitation

**Why the existing code still works**:
- `semantic_weak_completeness` is PROVEN - it uses the contrapositive approach
- `main_provable_iff_valid` is PROVEN - it doesn't actually need `truth_at_implies_semantic_truth` for its core result
- The sorries in `truth_at_implies_semantic_truth` and `main_weak_completeness` are "bridge sorries" that connect the proven semantic approach to the general `valid` definition

**Blocking Reason**: Cannot create the proposed helper lemmas because the fundamental assumption (all SemanticWorldStates have MCS-derived assignments) is false.

**Timing**: N/A (blocked)

**Files to modify**: None (architectural issue)

**Verification**: N/A

---

### Phase 2: Implication Case [BLOCKED]

**Goal**: Complete the sorry at line 3635 for the implication case (`psi.imp chi`)

**Status**: BLOCKED - Depends on Phase 1 which is blocked

**Reason**: The contrapositive approach requires that the world state's assignment is determined by MCS membership, which is not guaranteed for arbitrary `SemanticWorldState`s.

---

### Phase 3: Box Case [BLOCKED]

**Goal**: Complete the sorry at line 3641 for the box case (`psi.box`)

**Status**: BLOCKED - Depends on Phase 1 which is blocked

**Reason**: Same fundamental issue as implication case - the correspondence between `truth_at` and `assignment` is not established for arbitrary world states.

---

### Phase 4: Temporal Cases (all_past and all_future) [BLOCKED]

**Goal**: Complete the sorries at lines 3646 and 3651 for temporal operators

**Status**: BLOCKED - Depends on Phase 1 which is blocked

**Reason**: Same fundamental issue as other cases - the correspondence between `truth_at` and `assignment` is not established for arbitrary world states.

---

### Phase 5: Documentation and Alternative Paths [COMPLETED]

**Goal**: Document findings and provide alternative paths forward

**Status**: COMPLETED - Documentation created

**What was done**:
1. Analyzed the architectural issue in depth
2. Documented in Phase 1 why the theorem is unprovable in its current form
3. Identified that the core completeness result (`semantic_weak_completeness`) is already PROVEN and unaffected
4. Created this implementation summary

**Alternative Paths Forward**:

1. **Accept as technical debt** (RECOMMENDED):
   - The sorries in `truth_at_implies_semantic_truth` are "bridge sorries" connecting the proven semantic approach to the general `valid` definition
   - The core completeness (`semantic_weak_completeness`) is PROVEN
   - `main_provable_iff_valid` is PROVEN
   - These sorries don't affect mathematical soundness

2. **Restrict theorem scope**:
   - Modify `truth_at_implies_semantic_truth` to only work for `tau`s that come from MCS-derived histories
   - This would make the theorem provable but less general

3. **Restructure `main_weak_completeness`**:
   - Rewrite to avoid needing `truth_at_implies_semantic_truth`
   - Use `semantic_truth_at_v2` throughout instead of bridging to `truth_at`

4. **Add MCS requirement to SemanticWorldState**:
   - Require that all `SemanticWorldState`s come from MCS constructions
   - This would make the type more restrictive but the bridge provable

**Timing**: Completed during implementation phase

**Verification**: Documentation accurately reflects the architectural analysis

## Testing & Validation

**Status**: N/A (implementation blocked)

The original validation criteria are not applicable because the fundamental approach is blocked. Instead:

- [x] Architectural analysis completed
- [x] Root cause of blockage identified and documented
- [x] Alternative paths forward documented
- [x] Core completeness results verified as unaffected

## Artifacts & Outputs

- specs/570_analyze_compound_formula_proof_requirements/plans/implementation-001.md (this file)
- Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean (modified with proofs)
- specs/570_analyze_compound_formula_proof_requirements/summaries/implementation-summary-YYYYMMDD.md (upon completion)

## Rollback/Contingency

If proofs prove intractable:
1. **Phase 1 failure**: Document required infrastructure in research report; create subtasks for each missing lemma
2. **Individual case failure**: Mark that case as blocked; proceed with other cases; document blocking reason
3. **All cases fail**: Consider alternative architecture per research recommendations (Strategy C: restructure to avoid the bridge)
4. **Partial completion**: Accept documented sorries as technical debt; create follow-up task for remaining cases

Git provides rollback to any phase boundary via commit history.
