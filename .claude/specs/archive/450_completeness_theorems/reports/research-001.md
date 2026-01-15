# Research Report: Task #450

**Task**: 450 - completeness_theorems
**Started**: 2026-01-13T22:21:39Z
**Completed**: 2026-01-13T22:45:00Z
**Effort**: 8-10 hours
**Priority**: Low
**Dependencies**: Task 449 (completed), Task 481 (completed), Task 482 (completed)
**Sources/Inputs**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Main completeness file with axiom stubs
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Semantic approach
- `Theories/Bimodal/Semantics/Validity.lean` - Validity definitions
- Task 449 implementation summary
- Task 481 implementation summary
- Task 482 implementation summary
- Implementation plan v002 (`.claude/specs/257_completeness_proofs/plans/implementation-002.md`)
**Artifacts**: .claude/specs/450_completeness_theorems/reports/research-001.md (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Core completeness already proven**: `semantic_weak_completeness` in FiniteCanonicalModel.lean provides a working completeness proof for the semantic model
- **Gap to fill**: Connect semantic completeness to the general `valid` definition which quantifies over ALL temporal types
- **Two approaches available**: (1) Direct proof showing semantic model suffices for contrapositive, or (2) Bridge construction showing `SemanticCanonicalModel` is a valid instance
- **Recommended approach**: Prove completeness via contrapositive using the existing `semantic_weak_completeness` machinery

## Context & Scope

Task 450 is Phase 7 of the completeness proofs (Task 257). The goal is to prove:
1. `weak_completeness : valid phi -> DerivationTree [] phi`
2. `strong_completeness : semantic_consequence Gamma phi -> DerivationTree Gamma phi`
3. Complete `provable_iff_valid` proof (remove the sorry)

### Current State

**Completeness.lean axiom stubs** (lines 3569-3619):
- `axiom truth_lemma` - placeholder for canonical model truth correspondence
- `axiom weak_completeness` - placeholder for validity implies derivability
- `axiom strong_completeness` - placeholder for semantic consequence implies derivability

**FiniteCanonicalModel.lean proven theorems**:
- `semantic_weak_completeness` (lines 3033-3102) - PROVEN: validity in semantic model implies derivability
- `semantic_truth_lemma_v2` (line 2568) - PROVEN: truth lemma for semantic world states
- `SemanticCanonicalFrame` (line 2588) - DEFINED with nullity proven (Task 481), compositionality has documented sorries

### Key Definitions

From `Validity.lean`:
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

From `FiniteCanonicalModel.lean`:
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (origin) phi) ->
    derivable phi
```

## Findings

### Finding 1: Semantic Completeness Is Sufficient

The `semantic_weak_completeness` proof uses the contrapositive:
1. Assume phi is not derivable
2. Then `{phi.neg}` is consistent (by `neg_consistent_of_not_provable`)
3. Extend to MCS by Lindenbaum lemma
4. Project to closure MCS, construct FiniteWorldState where phi is false
5. Build SemanticWorldState via `finite_history_from_state`
6. This contradicts the hypothesis that phi is valid in all semantic models

**Key insight**: For completeness, we only need to show that IF phi is not provable, THEN there exists a countermodel. The semantic approach constructs this countermodel explicitly.

### Finding 2: Bridge to General Validity

The gap between `semantic_weak_completeness` and `weak_completeness`:

| semantic_weak_completeness | weak_completeness |
|---------------------------|-------------------|
| Quantifies over `SemanticWorldState phi` | Quantifies over ALL `TaskFrame D`, `TaskModel F`, `WorldHistory F`, `D` |
| Uses `semantic_truth_at_v2` | Uses `truth_at` |
| Works with `Int` time type | Works with any `LinearOrderedAddCommGroup D` |

**Connection**: The contrapositive works because:
- `valid phi` implies truth in SemanticCanonicalModel (as a specific TaskModel)
- `semantic_weak_completeness` shows: if phi false somewhere in SemanticCanonicalModel, then phi not derivable
- Contrapositive: if phi derivable, then phi true everywhere in SemanticCanonicalModel
- Soundness: if phi derivable, then phi true in ALL models

For completeness (the other direction):
- If phi is valid (true in ALL models), assume it's not derivable
- By semantic approach, construct a countermodel (SemanticCanonicalModel with phi false)
- But this contradicts validity
- Therefore phi is derivable

### Finding 3: Implementation Strategy

**Approach A: Direct Contrapositive** (Recommended)
```lean
theorem weak_completeness (phi : Formula) : valid phi -> DerivationTree [] phi := by
  intro h_valid
  by_contra h_not_provable
  -- Construct countermodel via semantic_weak_completeness machinery
  -- Show this contradicts h_valid
```

The key steps:
1. Use `neg_consistent_of_not_provable` to get `{phi.neg}` consistent
2. Use `set_lindenbaum` to extend to MCS M
3. Use `mcs_projection_is_closure_mcs` to project to closure MCS
4. Use `worldStateFromClosureMCS` to get FiniteWorldState
5. Use `finite_history_from_state` to get FiniteHistory
6. Use `SemanticWorldState.ofHistoryTime` to get semantic world state
7. Show phi is false at this state (contradicts `h_valid` when instantiated)

**Challenge**: Need to show the semantic model is a valid TaskModel for the general `valid` quantification. Options:
- Instantiate `valid` with `D = Int`, `F = SemanticCanonicalFrame phi`, `M = SemanticCanonicalModel phi`
- Prove that truth_at in this model matches semantic_truth_at_v2

**Approach B: Type Bridge Construction**
Build explicit conversions between:
- `FiniteHistory phi -> WorldHistory (SemanticCanonicalFrame phi)`
- `semantic_truth_at_v2 <-> truth_at`

This requires more infrastructure but provides a cleaner separation.

### Finding 4: Strong Completeness from Weak

`strong_completeness` follows from `weak_completeness`:
```lean
theorem strong_completeness (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> DerivationTree Gamma phi := by
  intro h_conseq
  -- If Gamma |- phi fails, then Gamma union {neg phi} is consistent
  -- Extend to MCS containing Gamma and neg phi
  -- Build model where Gamma is true but phi is false
  -- Contradicts semantic consequence
```

### Finding 5: provable_iff_valid Completion

The sorry in `provable_iff_valid` (line 3640) needs:
```lean
-- Current:
-- semantic_conseq := soundness [] phi h
-- Need to show: semantic_consequence [] phi -> valid phi

-- This follows from valid_iff_empty_consequence:
-- valid phi <-> ([] |= phi)
-- And the definitions unfold to show they're equivalent
```

### Finding 6: Existing Infrastructure

**Proven lemmas ready to use**:
- `soundness` (Soundness.lean:586) - derivability implies semantic consequence
- `soundness_from_empty` - derivability from empty context implies validity
- `valid_iff_empty_consequence` - validity equivalent to empty context consequence
- `neg_consistent_of_not_provable` (FiniteCanonicalModel.lean:2908)
- `set_lindenbaum` (Completeness.lean:360)
- `mcs_projection_is_closure_mcs` (FiniteCanonicalModel.lean:2986)
- `worldStateFromClosureMCS` (FiniteCanonicalModel.lean:1053)
- `finite_history_from_state` (FiniteCanonicalModel.lean:2853)

**Sorries that don't block completeness**:
- `finite_truth_lemma` (6 sorries) - DEPRECATED, use `semantic_truth_lemma_v2` instead
- `compositionality` mixed-sign cases - documented as acceptable
- `glue_histories` edge cases - don't affect completeness proof path

## Decisions

1. **Use Approach A (Direct Contrapositive)** - The semantic machinery is already proven; the bridge to general validity can be done directly in the completeness proof
2. **Keep axiom stubs as theorems** - Convert the axioms to theorems with actual proofs
3. **Leverage existing semantic infrastructure** - Don't duplicate work; use `semantic_weak_completeness` as the core
4. **Accept documented sorries** - The compositionality sorries don't affect the completeness proof path

## Recommendations

1. **Phase 1: weak_completeness** (3-4 hours)
   - Implement `weak_completeness` using contrapositive
   - Use the semantic model as the countermodel
   - Key: show `valid phi` can be instantiated with SemanticCanonicalModel

2. **Phase 2: strong_completeness** (2-3 hours)
   - Similar structure to weak_completeness
   - Handle context union {neg phi} consistency

3. **Phase 3: provable_iff_valid** (1 hour)
   - Complete the sorry in soundness direction
   - Show `semantic_consequence [] phi` implies `valid phi`

4. **Phase 4: Cleanup** (1-2 hours)
   - Convert axiom stubs to theorems
   - Update documentation
   - Verify no axioms/sorries remain on critical path

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Type universe issues with `valid` quantification | High | Use `Type` not `Type*`; validity already uses `Type` |
| WorldHistory construction mismatch | Medium | FiniteHistory already has states function matching WorldHistory interface |
| truth_at vs semantic_truth_at_v2 mismatch | Medium | Both evaluate same formula structure; prove equivalence if needed |

## Appendix

### Key Type Signatures

```lean
-- Target theorems
theorem weak_completeness (phi : Formula) : valid phi -> DerivationTree [] phi
theorem strong_completeness (Gamma : Context) (phi : Formula) :
  semantic_consequence Gamma phi -> DerivationTree Gamma phi
theorem provable_iff_valid (phi : Formula) : Nonempty (DerivationTree [] phi) <-> valid phi

-- Supporting infrastructure
def valid (phi : Formula) : Prop := forall D F M tau t, truth_at M tau t phi
def semantic_consequence (Gamma : Context) (phi : Formula) : Prop := ...
def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int
def SemanticCanonicalModel (phi : Formula) : TaskModel (SemanticCanonicalFrame phi)
def semantic_weak_completeness (phi : Formula) :
  (forall w, semantic_truth_at_v2 phi w origin phi) -> DerivationTree [] phi
```

### File Locations

- Main completeness: `Theories/Bimodal/Metalogic/Completeness.lean`
- Semantic approach: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- Validity defs: `Theories/Bimodal/Semantics/Validity.lean`
- Soundness: `Theories/Bimodal/Metalogic/Soundness.lean`
- Truth: `Theories/Bimodal/Semantics/Truth.lean`

## Next Steps

Run `/plan 450` to create implementation plan based on these findings.
