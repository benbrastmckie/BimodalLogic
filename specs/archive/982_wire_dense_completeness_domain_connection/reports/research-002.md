# Research Report 002: Principled Approaches for timelineQuot_not_valid_of_neg_consistent

**Task**: 982 - Wire dense completeness domain connection
**Focus**: Final sorry in TimelineQuotCompleteness.lean line 127
**Date**: 2026-03-16
**Session**: sess_1773707336_126

## 1. Blocker Analysis

### Current State

The single remaining sorry is in `timelineQuot_not_valid_of_neg_consistent`:

```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (phi : Formula) (h_cons : ContextConsistent [phi.neg]) :
    let M_0 := lindenbaumMCS [phi.neg] h_cons
    let h_M0_mcs := lindenbaumMCS_is_mcs [phi.neg] h_cons
    let D := TimelineQuot M_0 h_M0_mcs
    let acg := timelineQuotAddCommGroup M_0 h_M0_mcs
    let oam := timelineQuotIsOrderedAddMonoid M_0 h_M0_mcs
    not @valid_over D acg inferInstance oam phi := by
  intro M_0 h_M0_mcs D acg oam
  -- Need to show: exists F M Omega tau h_sc h_mem t, not truth_at M Omega tau t phi
  sorry
```

### What the Proof Requires

To show `not valid_over D phi`, we must construct a countermodel:
1. **TaskFrame F** over TimelineQuot with appropriate task_rel
2. **TaskModel M** with valuation reflecting MCS membership
3. **Omega** (shift-closed set of world histories)
4. **tau** (a specific history in Omega)
5. **t** (a time point)
6. Proof that `not truth_at M Omega tau t phi`

The key insight: Since `phi.neg in M_0` (the Lindenbaum MCS), we need a truth lemma that converts MCS membership to semantic truth.

## 2. Existing Infrastructure Analysis

### 2.1 Int-based Truth Lemma (CanonicalConstruction.lean)

The codebase has a complete, sorry-free truth lemma for `D = Int`:

```lean
theorem shifted_truth_lemma (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (phi : Formula)
    (fam : FMCS Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <->
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t phi
```

This uses:
- `CanonicalTaskFrame` with `D = Int`, `WorldState = CanonicalWorldState` (MCS subtype)
- `CanonicalTaskModel` with `valuation M p = (atom p in M.val)`
- `ShiftClosedCanonicalOmega B` for shift-closed histories
- `to_history fam` converting FMCS to WorldHistory

### 2.2 CanonicalMCS-based BFMCS (CanonicalFMCS.lean)

The `temporal_coherent_family_exists_CanonicalMCS` theorem provides:
- FMCS over `CanonicalMCS` (all MCSes with CanonicalR preorder)
- Forward_F and backward_P (sorry-free)
- Context preservation

### 2.3 TimelineQuot Infrastructure (TimelineQuotCompleteness.lean)

Already has:
- `timelineQuotMCS`: Extract MCS from TimelineQuot element via `ofAntisymmetrization`
- `timelineQuotMCS_is_mcs`: The extracted MCS is maximal consistent
- `timelineQuotAddCommGroup`, `timelineQuotIsOrderedAddMonoid`: Algebraic structure

### 2.4 Gap Identification

The fundamental gap is a **domain mismatch**:

| Component | Domain |
|-----------|--------|
| BFMCS + Truth Lemma | `D = Int` with `WorldState = CanonicalWorldState` |
| Dense Completeness | `D = TimelineQuot` |
| CanonicalMCS BFMCS | `D = CanonicalMCS` (preorder, not TimelineQuot) |

The existing truth lemma requires a BFMCS structure, but:
1. BFMCS is indexed by `D : Type*` with `[Preorder D]`
2. TimelineQuot has `LinearOrder` but needs FMCS/BFMCS infrastructure built over it
3. The Int truth lemma cannot be directly reused for TimelineQuot

## 3. Approach Evaluation

### Approach A: Direct Truth Lemma over TimelineQuot

**Description**: Build FMCS and BFMCS structures directly indexed by TimelineQuot, then prove a truth lemma.

**Requirements**:
1. Define `FMCS TimelineQuot` - family of MCSes indexed by TimelineQuot
2. Define `BFMCS TimelineQuot` - bundle with modal coherence
3. Define `CanonicalTaskFrame` over TimelineQuot
4. Prove truth lemma by structural induction

**Effort**: HIGH (500-800 lines, ~3-4 hours)
- Port all FMCS/BFMCS infrastructure
- Prove forward_G, backward_H, forward_F, backward_P
- Prove modal_forward, modal_backward for BFMCS
- Prove truth lemma cases (atom, bot, imp, box, all_future, all_past)

**Risk**: LOW - follows established pattern from Int case
**Quality**: HIGH - direct, principled, no axioms

### Approach B: Satisfiability Transfer via Order Isomorphism

**Description**: Use the Cantor isomorphism `TimelineQuot ≃o Rat` and `Rat ≃o Int` (countable dense linear orders without endpoints are all isomorphic to Q) to transfer satisfiability.

**Concept**:
1. Build BFMCS and countermodel over Int (existing infrastructure)
2. Transfer via the isomorphism: `not valid_over Int phi -> not valid_over TimelineQuot phi`

**Problem**: This direction is BACKWARDS for our needs.
- We have `phi.neg in M_0` where `M_0` is built from `[phi.neg]`
- We need a countermodel over TimelineQuot specifically
- The isomorphism goes `TimelineQuot ≃o Rat`, not the other way
- Order isomorphisms preserve validity, but we need to BUILD the countermodel starting from the specific MCS `M_0`

**Effort**: MODERATE but BLOCKED
**Risk**: HIGH - direction mismatch is fundamental
**Quality**: N/A - approach not viable

### Approach C: Semantic Argument with MCS Membership

**Description**: Directly construct the countermodel components without full BFMCS infrastructure.

**Requirements**:
1. Define a TaskFrame over TimelineQuot using `timelineQuotMCS` for states
2. Define valuation via MCS membership
3. Construct Omega from TimelineQuot histories
4. Prove truth for specific formula `phi` at specific point

**Key Insight**: We don't need the FULL truth lemma (all formulas, all times). We only need:
- `phi.neg in M_0` implies `not truth_at ... phi` at the root

**Simplification**: For the negation `phi.neg`, we can use:
- `phi.neg = phi.imp bot`
- If `phi` were true, then `phi.imp bot` would give `bot` true, contradiction

**Effort**: MODERATE (200-400 lines, ~1-2 hours)
- Define minimal TaskFrame/TaskModel over TimelineQuot
- Prove only the cases needed for the specific formula structure
- Use MCS properties directly without full induction

**Risk**: MODERATE - need to handle all formula constructors that appear in phi
**Quality**: MODERATE - ad-hoc, not reusable for other purposes

### Approach D: Leverage Existing CanonicalMCS Infrastructure

**Description**: Observe that CanonicalMCS and TimelineQuot are both quotients/structures built from MCSes. Use the CanonicalMCS BFMCS infrastructure with an embedding.

**Key Observation**:
- TimelineQuot elements are equivalence classes of StagedPoint
- StagedPoint contains an MCS
- CanonicalMCS IS an MCS
- The Lindenbaum MCS `M_0` from `[phi.neg]` is both a CanonicalMCS element AND generates a TimelineQuot

**Strategy**:
1. Use `temporal_coherent_family_exists_CanonicalMCS` with `Gamma = [phi.neg]`
2. Get FMCS over CanonicalMCS with root containing `phi.neg`
3. Build canonical model and show `phi.neg` is satisfiable there
4. Embed this into TimelineQuot semantics

**Problem**: The embedding needs to show that validity over CanonicalMCS implies validity over TimelineQuot, but we're trying to show NON-validity.

**Effort**: MODERATE (300-500 lines)
**Risk**: HIGH - embedding direction is tricky
**Quality**: MODERATE - indirect

## 4. Recommended Approach: Approach A (Direct Truth Lemma)

### Justification

1. **Publication Quality**: A direct truth lemma over TimelineQuot is the mathematically cleanest approach. It follows the standard completeness proof structure without any transfer tricks.

2. **Reusability**: Once built, the TimelineQuot FMCS/BFMCS infrastructure can be reused for any future work involving dense temporal completeness.

3. **Proven Pattern**: The Int-based truth lemma in CanonicalConstruction.lean provides a complete template. Each lemma and theorem has a direct analog for TimelineQuot.

4. **Zero-Debt Compliance**: No axioms, no sorries, no technical debt.

### Implementation Plan

**Phase 1: FMCS over TimelineQuot** (~200 lines)
1. Define `TimelineQuotFMCS` structure
   - `mcs : TimelineQuot -> Set Formula` using `timelineQuotMCS`
   - `is_mcs` from `timelineQuotMCS_is_mcs`
   - `forward_G`, `backward_H` from CanonicalR relationships

2. Prove temporal coherence conditions:
   - Forward_G: Uses CanonicalR transitivity (already proven)
   - Backward_H: Uses g_content/h_content duality (already proven)

**Phase 2: BFMCS over TimelineQuot** (~150 lines)
1. Define bundle structure with modal coherence
2. Prove modal_forward, modal_backward
   - These follow from BFMCS construction

**Phase 3: TaskFrame/TaskModel over TimelineQuot** (~100 lines)
1. Define task_rel using CanonicalR on representative MCSes
2. Define valuation via MCS membership
3. Define to_history for converting TimelineQuot FMCS to WorldHistory

**Phase 4: Truth Lemma** (~300 lines)
1. Port canonical_truth_lemma structure
2. Prove each formula case:
   - atom: Direct from valuation definition
   - bot: MCS consistency
   - imp: MCS implication property
   - box: modal_forward/modal_backward from BFMCS
   - all_future: forward_G + temporal T-axiom
   - all_past: backward_H + temporal T-axiom

**Phase 5: Completeness Wiring** (~50 lines)
1. Use truth lemma to show `phi.neg` true at root
2. Derive `not truth_at ... phi`
3. Complete `timelineQuot_not_valid_of_neg_consistent`

### Estimated Total: 800 lines, 3-4 hours

## 5. Alternative: Simplified Approach C

If time is constrained, Approach C (minimal semantic argument) can work:

1. The countermodel only needs to witness ONE falsifying point
2. We can directly construct:
   - TaskFrame with identity task_rel
   - Valuation from `M_0` membership
   - Singleton Omega with one constant history
   - Time 0

3. For the specific `phi`, show `not truth_at` by:
   - `phi.neg in M_0` means `phi notin M_0` (negation completeness of MCS)
   - Atom case: `atom p notin M_0` means valuation false
   - Imp case: Recursive on structure

**Risk**: This requires handling ALL subformulas of phi, but avoids full infrastructure.

## 6. Conclusion

**Recommended**: Approach A (Direct Truth Lemma over TimelineQuot)

This is the principled, publication-quality approach that:
- Follows established mathematical patterns
- Produces reusable infrastructure
- Achieves zero technical debt
- Provides complete proof with no gaps

**Fallback**: Approach C (Simplified Semantic Argument) if time-constrained

The key insight is that TimelineQuot elements carry MCSes (via `timelineQuotMCS`), and all the CanonicalR-based reasoning from the Int case applies once we define the appropriate structures.

## 7. Next Steps for Implementation

1. Create `TimelineQuotCanonical.lean` with FMCS/BFMCS definitions
2. Port truth lemma proof structure from CanonicalConstruction.lean
3. Complete `timelineQuot_not_valid_of_neg_consistent` using the truth lemma
4. Verify `dense_completeness_theorem` compiles with zero sorries
