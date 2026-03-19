# Research Report: Task 987 - Algebraic Base Completeness

## Executive Summary

Task 987 aims to wire the algebraic base completeness theorem: use the BFMCS construction from task 986 as the `construct_bfmcs` argument to `parametric_algebraic_representation_conditional` (D = Int), then prove `valid phi -> provable phi`.

**Critical Finding**: Task 986 is PARTIAL with 2 sorries remaining (`intFMCS_forward_F` and `intFMCS_backward_P`). These sorries prevent using the Int-indexed chain construction as the `construct_bfmcs` argument because the BFMCS would not be temporally coherent.

**Key Insight**: The CanonicalMCS-based BFMCS in `CanonicalFMCS.lean` IS sorry-free and has proven forward_F/backward_P. However, it is indexed by `CanonicalMCS` (a Preorder type), not by `Int`. The type mismatch identified in the task description is not between `CanonicalWorldState` and `ParametricCanonicalWorldState` (these are identical definitions), but rather between:
1. **D = Int** (required by parametric infrastructure)
2. **D = CanonicalMCS** (what has sorry-free temporal coherence)

**Recommendation**: There are two viable paths forward:
1. **Path A**: Complete the Int-indexed dovetailing construction in task 986 to eliminate the 2 sorries
2. **Path B**: Use the CanonicalMCS-based completeness directly without the parametric algebraic infrastructure

## Investigation Areas

### 1. Task 986 BFMCS Construction

**File**: `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (614 lines)

**Status**: PARTIAL with 2 sorries

**Completed Work**:
- `successorMCS`: Produces successor MCS with CanonicalR via Lindenbaum extension of g_content
- `predecessorMCS`: Produces predecessor MCS with CanonicalR via h_content duality
- `intChainMCS`: Int-indexed chain combining positive and negative chains
- `intChain_forward_G`: SORRY-FREE proof of G-coherence (forward propagation)
- `intChain_backward_H`: SORRY-FREE proof of H-coherence (backward propagation)
- `intFMCS_basic`: FMCS Int with forward_G and backward_H

**Blocked (2 Sorries)**:
- `intFMCS_forward_F` (line 557): If F(phi) in mcs(t), find s > t with phi in mcs(s)
- `intFMCS_backward_P` (line 570): If P(phi) in mcs(t), find s < t with phi in mcs(s)

**Root Cause**: The simple chain construction (successorMCS/predecessorMCS) does NOT guarantee F/P witnesses land in the chain. The witness from `canonical_forward_F` is constructed via `Lindenbaum({phi} union g_content(M))`, while the chain's successor is `Lindenbaum(g_content(M))` - these may differ.

**Resolution Options from Task 986**:
1. Implement enriched dovetailing construction (~4-6 hours)
2. Use CanonicalMCS-indexed BFMCS (changes type requirements)
3. Accept conditional theorem pending BFMCS construction

### 2. Parametric Algebraic Representation

**File**: `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`

**Key Theorem** (lines 215-232):
```lean
theorem parametric_algebraic_representation_conditional
    (phi : Formula) (h_not_prov : not Nonempty (DerivationTree [] phi))
    (construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
      Sigma' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam in B.families) (t : D),
         M = fam.mcs t) :
    exists (B : BFMCS D) (h_tc : B.temporally_coherent)
      (fam : FMCS D) (hfam : fam in B.families) (t : D),
      not (truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t phi)
```

**Type Signature of `construct_bfmcs` Argument**:
- Input: MCS `M` and proof `SetMaximalConsistent M`
- Output: PSigma containing:
  - `B : BFMCS D` - the bundle
  - `h_tc : B.temporally_coherent` - temporal coherence proof
  - `fam : FMCS D` - a family in the bundle
  - `hfam : fam in B.families` - membership proof
  - `t : D` - time point
  - `M = fam.mcs t` - witness that M is placed at time t

**Type Constraints**: D must satisfy `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

### 3. Type Compatibility Analysis

**CanonicalWorldState vs ParametricCanonicalWorldState**:

These are **definitionally identical**:
```lean
-- From CanonicalConstruction.lean (line 126):
def CanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

-- From ParametricCanonical.lean (line 63):
def ParametricCanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }
```

**No type mismatch here** - they are the same subtype.

**The Real Type Mismatch**:

The mismatch is between the **duration type D**:

| Infrastructure | Duration Type D | Temporal Coherence |
|----------------|-----------------|-------------------|
| IntBFMCS (task 986) | Int | 2 sorries (forward_F, backward_P) |
| CanonicalFMCS | CanonicalMCS (Preorder) | Sorry-free |
| Parametric infrastructure | Generic D with group structure | Requires caller to provide |

CanonicalMCS satisfies `[Preorder]` but NOT `[AddCommGroup]` or `[LinearOrder]`, so it cannot be used as D in the parametric infrastructure.

### 4. CanonicalMCS-Based Infrastructure

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

**Key Achievement**: Sorry-free temporal coherence for ALL MCSs

```lean
theorem canonicalMCS_forward_F
    (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi in canonicalMCS_mcs w) :
    exists s : CanonicalMCS, w <= s and phi in canonicalMCS_mcs s := by
  obtain <W, h_W_mcs, h_R, h_phi_W> := canonical_forward_F w.world w.is_mcs phi h_F
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  exact <s, CanonicalMCS.le_of_canonicalR w s h_R, h_phi_W>

theorem canonicalMCS_backward_P
    (w : CanonicalMCS) (phi : Formula)
    (h_P : Formula.some_past phi in canonicalMCS_mcs w) :
    exists s : CanonicalMCS, s <= w and phi in canonicalMCS_mcs s := by
  -- Similar, uses canonical_backward_P
```

**Why CanonicalMCS Works**: Every MCS is in the domain by construction, so witnesses from `canonical_forward_F`/`canonical_backward_P` are automatically present.

### 5. Base Completeness Existing Infrastructure

**File**: `Theories/Bimodal/Metalogic/BaseCompleteness.lean`

**Current State**: Documents the completeness infrastructure but does NOT prove the closed completeness theorem.

**Available Components**:
- `base_truth_lemma`: Re-exports `canonical_truth_lemma` for Int
- `base_shifted_truth_lemma`: Re-exports `shifted_truth_lemma` for shift-closed Omega
- `base_omega_shift_closed`: Proves ShiftClosedCanonicalOmega is shift-closed

**Missing**: The actual `completeness_base : valid phi -> Nonempty (deriv [] phi)` theorem

### 6. Completeness Via Non-Parametric Path

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

This file has a complete, sorry-free truth lemma for D = Int:
```lean
theorem shifted_truth_lemma (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (phi : Formula)
    (fam : FMCS Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <->
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t phi
```

However, to use this, we need a temporally coherent `BFMCS Int`, which requires solving the same forward_F/backward_P problem from task 986.

## Key Findings

### Relevant Definitions

| Name | File | Line | Description |
|------|------|------|-------------|
| `parametric_algebraic_representation_conditional` | ParametricRepresentation.lean | 215 | Main conditional representation theorem |
| `ParametricCanonicalWorldState` | ParametricCanonical.lean | 63 | MCS subtype (identical to CanonicalWorldState) |
| `ParametricCanonicalTaskFrame D` | ParametricCanonical.lean | 199 | D-parametric TaskFrame |
| `intFMCS_basic` | IntBFMCS.lean | 520 | Int-indexed FMCS (missing F/P coherence) |
| `canonicalMCSBFMCS` | CanonicalFMCS.lean | 184 | Sorry-free CanonicalMCS-indexed FMCS |
| `shifted_truth_lemma` | CanonicalConstruction.lean | 685 | Int-indexed truth lemma |

### Relevant Lemmas

| Name | File | Status | Description |
|------|------|--------|-------------|
| `intChain_forward_G` | IntBFMCS.lean | Proven | G-coherence for Int chain |
| `intChain_backward_H` | IntBFMCS.lean | Proven | H-coherence for Int chain |
| `intFMCS_forward_F` | IntBFMCS.lean | SORRY | F-witness existence (blocked) |
| `intFMCS_backward_P` | IntBFMCS.lean | SORRY | P-witness existence (blocked) |
| `canonicalMCS_forward_F` | CanonicalFMCS.lean | Proven | F-witness in all-MCS domain |
| `canonicalMCS_backward_P` | CanonicalFMCS.lean | Proven | P-witness in all-MCS domain |
| `temporal_coherent_family_exists_CanonicalMCS` | CanonicalFMCS.lean | Proven | Temporally coherent family exists |

### Architectural Relationships

```
                    parametric_algebraic_representation_conditional
                                       |
                                       v
                              construct_bfmcs : BFMCS D
                                       |
                    +------------------+------------------+
                    |                                     |
                    v                                     v
         BFMCS Int (task 986)              BFMCS CanonicalMCS (CanonicalFMCS)
         2 sorries (F/P)                   Sorry-free but wrong type D
```

## Recommendations

### Option 1: Complete Task 986 First (RECOMMENDED)

**Prerequisites**: Implement enriched dovetailing construction in IntBFMCS.lean

**Steps**:
1. Mark task 987 as BLOCKED on task 986
2. Complete task 986's dovetailing construction for forward_F/backward_P
3. Define `construct_bfmcs_int` using the completed IntBFMCS
4. Apply `parametric_algebraic_representation_conditional` with D = Int
5. Wire to completeness theorem

**Effort**: ~4-6 hours for dovetailing + ~2 hours for wiring

### Option 2: Bypass Parametric Infrastructure

**Approach**: Use CanonicalMCS-based completeness directly

**Steps**:
1. Create `AlgebraicBaseCompleteness.lean` importing CanonicalFMCS
2. Prove completeness using `temporal_coherent_family_exists_CanonicalMCS`
3. Wire truth lemma from CanonicalConstruction (needs BFMCS construction helper)

**Challenge**: Still need to construct a BFMCS Int, which has the same F/P problem

**Reality Check**: Both paths require solving the F/P witness problem for Int-indexed construction.

### Option 3: Semantic Equivalence Argument

**Approach**: Prove that completeness over CanonicalMCS implies completeness over Int

**Idea**:
- CanonicalMCS has sorry-free temporal coherence
- If valid over ALL TaskFrames, then valid over CanonicalMCS TaskFrame
- Completeness over CanonicalMCS implies provability
- Provability is D-independent

**Advantage**: Avoids Int-specific F/P witness construction entirely

**This may be the cleanest path forward.**

## Blockers and Risks

### Primary Blocker

**Task 986 sorries**: The `intFMCS_forward_F` and `intFMCS_backward_P` sorries block the direct path.

### Secondary Considerations

1. **Dovetailing Complexity**: The enriched dovetailing construction is non-trivial (~4-6 hours estimated)
2. **Type System Constraints**: CanonicalMCS doesn't satisfy the group structure requirements for D
3. **Semantic Equivalence Gap**: Option 3 requires proving that CanonicalMCS models are "representative enough"

### Zero-Debt Policy Compliance

Per proof-debt-policy.md, we MUST NOT:
- Use sorry deferral ("fix F/P in follow-up task")
- Accept partial sorries in the final implementation
- Introduce new axioms to bridge the gap

If no sorry-free approach is found, the task should be marked [BLOCKED] for user review.

## Implementation Strategy (If Proceeding)

Given the analysis, the most practical strategy is:

### Phase 1: Explore Semantic Equivalence Path

1. Investigate whether `valid phi` over ALL D implies `valid` over the CanonicalMCS model
2. If yes, use `temporal_coherent_family_exists_CanonicalMCS` + truth lemma
3. This would provide completeness without Int-specific BFMCS

### Phase 2: If Phase 1 Fails, Complete Task 986

1. Implement enriched dovetailing in IntBFMCS.lean
2. Prove `intFMCS_forward_F` and `intFMCS_backward_P`
3. Define `construct_bfmcs_int` function
4. Wire to parametric representation

### Phase 3: Create AlgebraicBaseCompleteness.lean

```lean
-- Target signature:
theorem algebraic_base_completeness (phi : Formula) :
    valid phi -> Nonempty (DerivationTree [] phi)
```

## References

### Files Consulted

| File | Lines | Purpose |
|------|-------|---------|
| ParametricRepresentation.lean | 263 | Conditional representation theorem |
| ParametricCanonical.lean | 245 | D-parametric TaskFrame definition |
| ParametricTruthLemma.lean | ~400 | Shifted truth lemma for parametric model |
| DiscreteInstantiation.lean | 185 | D = Int instantiation infrastructure |
| IntBFMCS.lean | 614 | Task 986 chain construction (2 sorries) |
| CanonicalFMCS.lean | 313 | Sorry-free CanonicalMCS construction |
| CanonicalConstruction.lean | 825 | Int-indexed truth lemma |
| BaseCompleteness.lean | 178 | Existing base completeness infrastructure |

### Task Dependencies

- Task 986: BFMCS Construction for Int (PARTIAL, 2 sorries)
- Task 985: Lindenbaum-Tarski Representation Theorem (provides parametric infrastructure)
- Task 988: Dense Algebraic Completeness (BLOCKED on similar F/P issues)

### External Resources

- Boneyard/Metalogic/Metalogic_v2/Representation/: Older completeness proofs (reference only)
