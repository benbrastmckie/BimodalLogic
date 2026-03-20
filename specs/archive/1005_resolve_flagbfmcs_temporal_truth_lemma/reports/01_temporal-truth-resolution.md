# Temporal Truth Lemma Resolution Analysis

**Task**: 1005
**Date**: 2026-03-19
**Session**: sess_1773964179_ce8c92

## Executive Summary

The two sorries in `FlagBFMCSTruthLemma.lean` (`mem_of_satisfies_at_all_future` and `mem_of_satisfies_at_all_past`) stem from a fundamental architectural gap: F/P witnesses from `chainFMCS_forward_F_in_CanonicalMCS` exist in CanonicalMCS but may not lie within the same Flag. After detailed analysis, **Path B (Cross-Flag Temporal Satisfaction)** is recommended as the most principled solution.

## Problem Statement

### Current Goal States

At `mem_of_satisfies_at_all_future` (line 257):
```lean
case inr
h_neg_G : φ.all_future.neg ∈ chainFMCS_mcs F x
⊢ φ.all_future ∈ (chainFMCS F).mcs x
```

At `mem_of_satisfies_at_all_past` (line 295):
```lean
case inr
h_neg_H : φ.all_past.neg ∈ chainFMCS_mcs F x
⊢ φ.all_past ∈ (chainFMCS F).mcs x
```

### Why This Cannot Be Proven

The intended proof strategy is contraposition:
1. Assume `neg(G phi)` in MCS at x
2. By temporal duality (`neg_all_future_to_some_future_neg`): `F(neg phi)` in MCS at x
3. By `chainFMCS_forward_F_in_CanonicalMCS`: exists witness `s > x` with `neg(phi)` in `s.world`
4. But `h_sat` says phi satisfied at all `x' > x` **in the same Flag**
5. **GAP**: The witness `s` is in CanonicalMCS, not necessarily in Flag F

The current `satisfies_at` definition (lines 64-65):
```lean
| .all_future φ => ∀ (x' : ChainFMCSDomain F), x < x' → satisfies_at B F hF x' φ
```

quantifies only over elements in the same Flag, while the witness may be in a different Flag.

## Resolution Path Analysis

### Path A: Extend closedFlags with Temporal Witness Closure

**Concept**: Modify `closedFlags` construction to ensure temporal witnesses land in the same Flag.

**Changes Required**:
1. New definition: `TemporallyClosedFlagSet` requiring F/P witnesses internal to each Flag
2. Modify `addWitnessFlags` to add temporal witnesses, not just modal witnesses
3. Prove temporal closure for `closedFlags`

**Analysis**:
- The `addWitnessFlags` construction (ClosedFlagBundle.lean:137-140) currently only adds modal (Diamond) witnesses
- A Flag is a maximal chain in CanonicalMCS (Mathlib `Flag` type)
- F/P witnesses from Lindenbaum may not be comparable with all Flag elements
- As noted in SaturatedChain.lean (lines 280-278): "Different F-obligations may require witnesses that are mutually incomparable"

**Infrastructure**:
- `ChainFSaturated`/`ChainPSaturated` predicates exist in SaturatedChain.lean
- `FlagSaturated` predicate defined but not constructive
- No mechanism to guarantee Lindenbaum witnesses are comparable with a chain

**Risk**: HIGH - Forcing temporal witnesses into the same Flag may be impossible since Lindenbaum constructions produce arbitrary MCSs. The witness comparability problem (SaturatedChain.lean:268-275) is fundamental.

**Verdict**: NOT RECOMMENDED - violates chain structure

### Path B: Cross-Flag Temporal Satisfaction Relation

**Concept**: Redefine `satisfies_at` for temporal operators to quantify across all Flags, consistent with standard bundle semantics.

**Proposed Change**:
```lean
-- Current (same-Flag quantification):
| .all_future φ => ∀ (x' : ChainFMCSDomain F), x < x' → satisfies_at B F hF x' φ

-- Proposed (cross-Flag quantification):
| .all_future φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags)
    (x' : ChainFMCSDomain F'), x.val < x'.val → satisfies_at B F' hF' x' φ
```

**Required Changes**:
1. Modify `satisfies_at` definition for `.all_future` and `.all_past` cases
2. Update truth lemma proofs (both directions)
3. The backward direction becomes immediate since F-witness is in some Flag in B.flags
4. The forward direction needs adjustment but should work via `closedFlags` properties

**Semantic Justification**:
- In standard bundle semantics, temporal accessibility relates positions across different "histories"
- The preorder on CanonicalMCS (CanonicalR) already relates MCSs from different Flags
- This aligns with Goldblatt's treatment of tense logic bundles

**Infrastructure**:
- `chainFMCS_forward_F_in_CanonicalMCS` gives witness in CanonicalMCS
- `canonicalMCS_in_some_flag` puts any CanonicalMCS in some Flag
- `closedFlags` ensures modal saturation; can be extended for temporal saturation

**Proof Impact**:
- `satisfies_at_all_future_of_mem` (backward): May need cross-Flag induction
- `mem_of_satisfies_at_all_future` (forward): Becomes straightforward via Lindenbaum

**Risk**: MEDIUM - Requires significant refactoring but aligns with standard semantics

**Verdict**: RECOMMENDED - principled semantic fix

### Path C: Accept Partial Completeness

**Concept**: Document the temporal gap as a known limitation; the modal cases are fully proven.

**Current Status**:
- `satisfies_at_box_of_mem` and `mem_of_satisfies_at_box` are complete (no sorries)
- Atom, bot, and implication cases are complete
- Only temporal operators have gaps

**Documentation Approach**:
1. Add `sorry`-free modal completeness theorem
2. Document temporal limitation in module docstring
3. Note that full completeness requires Path B

**Use Cases**:
- Sufficient for pure S5 reasoning (no temporal operators)
- Sufficient for temporal operators in the "forward" direction only
- NOT sufficient for full bimodal completeness

**Risk**: LOW - just documentation, no code changes

**Verdict**: ACCEPTABLE as intermediate milestone, not as final solution

## Detailed Path B Implementation Plan

### Phase 1: Modify Satisfaction Relation

**File**: `FlagBFMCSTruthLemma.lean`

```lean
/-- Satisfaction with cross-Flag temporal quantification -/
def satisfies_at (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) : Formula → Prop
  | .atom p => Formula.atom p ∈ (chainFMCS F).mcs x
  | .bot => False
  | .imp ψ χ => satisfies_at B F hF x ψ → satisfies_at B F hF x χ
  | .box φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world →
      satisfies_at B F' hF' x' φ
  -- MODIFIED: Cross-Flag quantification
  | .all_future φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags)
      (x' : ChainFMCSDomain F'), x.val < x'.val → satisfies_at B F' hF' x' φ
  | .all_past φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags)
      (x' : ChainFMCSDomain F'), x'.val < x.val → satisfies_at B F' hF' x' φ
```

### Phase 2: Update Truth Lemma (Backward Direction)

The backward directions (`satisfies_at_all_future_of_mem`, `satisfies_at_all_past_of_mem`) need modification:

**Current Proof (lines 216-224)**:
```lean
theorem satisfies_at_all_future_of_mem ... (h_mem : φ.all_future ∈ (chainFMCS F).mcs x) :
    satisfies_at B F hF x φ.all_future := by
  simp only [satisfies_at]
  intro x' h_lt
  rw [ih x']
  exact chainFMCS_forward_G F x x' φ h_lt h_mem
```

**Modified Proof Sketch**:
```lean
theorem satisfies_at_all_future_of_mem ... (h_mem : φ.all_future ∈ (chainFMCS F).mcs x) :
    satisfies_at B F hF x φ.all_future := by
  simp only [satisfies_at]
  intro F' hF' x' h_lt
  rw [ih F' hF' x']
  -- Need: φ ∈ (chainFMCS F').mcs x'
  -- From h_mem: G(φ) ∈ x.val.world
  -- From h_lt: x.val < x'.val (CanonicalR x.val.world x'.val.world)
  -- Need to show: G(φ) in x.val.world propagates to φ in x'.val.world
  exact g_content_propagation x.val x'.val φ h_mem h_lt  -- new lemma needed
```

**Required New Lemma**:
```lean
theorem g_content_propagation (M M' : CanonicalMCS) (φ : Formula)
    (h_G : φ.all_future ∈ M.world) (h_R : M < M') : φ ∈ M'.world
```

This follows from `CanonicalR M.world M'.world` meaning `g_content M.world ⊆ M'.world`, and `G(φ) ∈ M.world` implying `φ ∈ g_content M.world`.

**Infrastructure Exists**: `g_content` is defined in ChainFMCS.lean; `CanonicalR` definition matches.

### Phase 3: Update Truth Lemma (Forward Direction)

The forward directions become straightforward:

**Modified Proof for `mem_of_satisfies_at_all_future`**:
```lean
theorem mem_of_satisfies_at_all_future ... (h_sat : satisfies_at B F hF x φ.all_future) :
    φ.all_future ∈ (chainFMCS F).mcs x := by
  have h_mcs := chainFMCS_is_mcs F x
  rcases SetMaximalConsistent.negation_complete h_mcs φ.all_future with h_G | h_neg_G
  · exact h_G
  · -- neg(G phi) in MCS means F(neg phi) in MCS
    have h_F : (φ.neg).some_future ∈ x.val.world :=
      neg_all_future_to_some_future_neg x.val.world x.val.is_mcs φ h_neg_G
    -- Get witness in CanonicalMCS
    obtain ⟨s, h_lt, h_neg_phi⟩ := canonicalMCS_forward_F x.val φ.neg h_F
    -- s is in some Flag F' in B.flags
    obtain ⟨F', hF', hs⟩ := canonicalMCS_in_some_flag s
    let x' : ChainFMCSDomain F' := ⟨s, hs⟩
    -- By h_sat (cross-Flag): φ satisfied at x'
    have h_sat_x' : satisfies_at B F' hF' x' φ := h_sat F' hF' x' h_lt
    -- By IH: φ ∈ s.world
    have h_phi : φ ∈ s.world := (ih F' hF' x').mp h_sat_x'
    -- Contradiction: both φ and neg(φ) in s.world
    exact absurd h_phi (set_consistent_not_both s.is_mcs.1 φ · h_neg_phi)
```

### Phase 4: Verify Induction Generalizes

The main theorem `satisfies_at_iff_mem` uses structural induction on formulas. With cross-Flag quantification, the IH must be stated for all Flags:

```lean
theorem satisfies_at_iff_mem (B : FlagBFMCS) (φ : Formula) :
    ∀ (F : Flag CanonicalMCS) (hF : F ∈ B.flags) (x : ChainFMCSDomain F),
    satisfies_at B F hF x φ ↔ φ ∈ (chainFMCS F).mcs x := by
  induction φ with
  | all_future ψ ih =>
    intro F hF x
    constructor
    · exact mem_of_satisfies_at_all_future B F hF x ψ ih
    · exact satisfies_at_all_future_of_mem B F hF x ψ ih
  ...
```

This generalization is natural and required for cross-Flag reasoning.

## Infrastructure Assessment

### Existing Components (Ready to Use)

| Component | Location | Purpose |
|-----------|----------|---------|
| `neg_all_future_to_some_future_neg` | TemporalCoherence.lean:92-101 | Temporal duality |
| `canonicalMCS_forward_F` | ChainFMCS.lean | F-witness in CanonicalMCS |
| `canonicalMCS_in_some_flag` | ChainFMCS.lean | Every MCS in some Flag |
| `closedFlags_closed_under_witnesses` | ClosedFlagBundle.lean | Modal saturation |
| `g_content` definition | ChainFMCS.lean:147-148 | Temporal content extraction |
| `CanonicalR` definition | CanonicalFrame.lean | Temporal accessibility |

### New Components Required

1. **g_content_propagation**: G(φ) in M + M < M' implies φ in M' (simple from definitions)
2. **h_content_propagation**: H(φ) in M + M' < M implies φ in M' (symmetric to above)
3. **Cross-Flag induction infrastructure**: Minor modifications to theorem statements

### Estimated Effort

- Phase 1 (modify satisfies_at): ~30 lines changed
- Phase 2 (backward direction): ~50 lines modified
- Phase 3 (forward direction): ~40 lines modified
- Phase 4 (induction generalization): ~20 lines changed
- New supporting lemmas: ~30 lines

**Total**: ~170 lines of changes

## Recommendation

**Implement Path B (Cross-Flag Temporal Satisfaction)**

Rationale:
1. Aligns with standard bundle semantics where temporal relations cross histories
2. Uses existing infrastructure (Lindenbaum, closedFlags, g_content)
3. Avoids the impossible chain comparability problem of Path A
4. Provides full bimodal completeness, not just modal completeness

### Implementation Priority

1. **Immediate**: Add the g_content/h_content propagation lemmas (trivial)
2. **Main Work**: Modify satisfies_at definition and update proofs
3. **Verification**: Ensure main truth lemma compiles with no sorries

### Alternative: Path C as Milestone

If Path B is blocked by unforeseen issues:
1. Document current modal completeness (Box case proven)
2. Mark temporal cases as known limitation
3. Proceed with applications that don't require temporal truth lemma

## Appendix: Key Code References

### Goal State at Sorry (line 257)
```lean
case inr
B : FlagBFMCS
F : Flag CanonicalMCS
hF : F ∈ B.flags
x : ChainFMCSDomain F
φ : Formula
ih : ∀ (x' : ChainFMCSDomain F), satisfies_at B F hF x' φ ↔ φ ∈ (chainFMCS F).mcs x'
h_sat : satisfies_at B F hF x φ.all_future
h_mcs : SetMaximalConsistent (chainFMCS_mcs F x)
h_neg_G : φ.all_future.neg ∈ chainFMCS_mcs F x
⊢ φ.all_future ∈ (chainFMCS F).mcs x
```

### Witness Existence Theorem (ChainFMCS.lean:660-664)
```lean
theorem chainFMCS_forward_F_in_CanonicalMCS (flag : Flag CanonicalMCS)
    (w : ChainFMCSDomain flag) (phi : Formula)
    (h_F : Formula.some_future phi ∈ chainFMCS_mcs flag w) :
    ∃ s : CanonicalMCS, w.val ≤ s ∧ phi ∈ s.world :=
  canonicalMCS_forward_F w.val phi h_F
```

### Chain Saturation Limitation (SaturatedChain.lean:270-275)
```
**When is a Lindenbaum witness comparable?**
The witness W for F(phi) at M satisfies `CanonicalR M.world W`, so M < {W}.
For W to be in the same flag as M, we need W comparable with all other flag elements.

This is NOT automatically true. Different F-obligations may require witnesses
that are mutually incomparable.
```
