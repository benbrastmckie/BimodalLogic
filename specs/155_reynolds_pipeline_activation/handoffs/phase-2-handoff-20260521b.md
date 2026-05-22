# Phase 2 Handoff (Round 2): Lemma 9 Gap Detection

## Summary

No additional sorry sites closed this round. Instead, deep analysis revealed that **`std_untl_gap_detection` and `std_snce_gap_detection` as stated are provably incorrect**, blocking 6 of the 9 remaining sorry sites.

## Critical Finding: std_untl_gap_detection is FALSE

### The Bug

`std_untl_gap_detection` (EFGames.lean:2682) claims:
```
U(X,D)^mu at point m ↔ ∃ gap γ, gap_definable_on_left γ D ∧ ...
```

This is FALSE when D is trivially true (e.g., D = `.base Formula.top`):
- **LHS**: U(X, top)^mu at m = ∃ s > m (mu-point), X^mu(s). TRUE if X holds anywhere above m.
- **RHS**: Requires `gap_definable_on_left γ (.base Formula.top)` for some gap γ. But this is ALWAYS FALSE for any gap.

### Lean-Verified Proof

```lean
example (sig : MonadicSignature) (M : OrderedMonadicStructure sig) 
    (atomMap : Formula → sig.preds) (γ : Gap M.carrier) :
    ¬ gap_definable_on_left M atomMap γ (.base Formula.top) := by
  intro ⟨_, h2⟩
  apply h2
  have ⟨x, hx⟩ : ∃ x, x ∉ γ.cut := by
    by_contra h; push_neg at h; exact γ.proper (Set.eq_univ_iff_forall.mpr h)
  exact ⟨x, hx, fun u _ _ => by
    simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id⟩
```

This compiles and proves that no gap can be definable on the left by Formula.top. Since the LHS of std_untl_gap_detection can be true when D = top, the biconditional is false.

### Root Cause

Standard Until U(X,D) has no "D fails somewhere" condition — D holds on an open interval (m,s), which is consistent with D being true everywhere. Stavi Until U'(X,D) has explicit condition (2): ∃ u_fail, ¬D(u_fail), which prevents this.

The gap construction requires D to FAIL somewhere to create the gap boundary. U' guarantees this; U does not.

### Why stavi_untl_gap_detection is Correct

For `stavi_untl_gap_detection` with D = top: the FO table condition (2) requires ∃ u, ¬top(u) = False. So the LHS is also False. Both sides false → biconditional holds.

### Impact: 6 Sorry Sites Blocked

The incorrect theorems block:

| Theorem | Case | Uses |
|---------|------|------|
| left_formula_gap_detection | .stavi_snce A B | std_untl_gap_detection |
| left_formula_gap_detection | .std_snce A B | std_untl_gap_detection |
| left_formula_gap_detection | .base (.snce f g) | std_untl_gap_detection |
| right_formula_gap_detection | .stavi_untl A B | std_snce_gap_detection |
| right_formula_gap_detection | .std_untl A B | std_snce_gap_detection |
| right_formula_gap_detection | .base (.untl f g) | std_snce_gap_detection |

`std_snce_gap_detection` has the exact same bug (past direction dual).

## Proposed Fix: Add D-Failure Hypothesis

### Option A: Minimal Fix (Recommended)

Add a hypothesis to std_untl_gap_detection and std_snce_gap_detection:

```lean
-- std_untl: add hypothesis that D fails somewhere above m
theorem std_untl_gap_detection ... 
    (h_D_nontrivial : ∃ q : M.carrier, m < q ∧ ¬stavi_temporal_truth M atomMap q D) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (.std_untl X D) ↔ ...

-- std_snce: add hypothesis that D fails somewhere below m  
theorem std_snce_gap_detection ...
    (h_D_nontrivial : ∃ q : M.carrier, q < m ∧ ¬stavi_temporal_truth M atomMap q D) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (.std_snce X D) ↔ ...
```

**Downstream**: Each usage site provides the hypothesis from the compound structure:
- `left(S'(A,B), D) = U(compound, D)` where compound includes `¬U'(D, B∧D)`, which guarantees D-failure
- `left(S(A,B), D) = U(compound, D)` with same structure
- `right(U'(A,B), D) = S(compound, D)` dual

**Caveat**: Even with h_D_nontrivial, the gap construction needs the complement to have no minimum. With U(X,D), D holds on (m,s) and fails at q > m. If q ≥ s, the D-failure boundary near s might be a point (not a proper gap). The full proof may require the STRONGER hypothesis that U'(⊤, D) also holds — see Option B.

### Option B: ALSO BROKEN — Backward Direction Fails Too

The backward direction (gap → std_untl) is ALSO invalid:
- If s = complement point u₀: X(u₀) ✓, but (m,u₀) includes complement points near gap where D fails (gap_definable_on_left says ¬D is dense in initial complement). So D on (m,u₀) FAILS.
- If s = cut point: D on (m,s) ✓ (all points between m and s are cut), but X(s) is NOT given (hypothesis only gives X at complement points, not cut points).

Neither choice works. **The entire biconditional is wrong, not just the forward direction.**

This rules out adding hypotheses to fix the theorem. The theorem fundamentally cannot be stated as gap_conditions ↔ std_untl.

### Option C: Prove Cases Directly (ONLY VIABLE OPTION)

**Delete std_untl_gap_detection and std_snce_gap_detection.** Replace their `sorry` with a comment explaining they are false.

For each affected case in left/right_formula_gap_detection, prove directly by:
1. Unpacking the compound (which includes U'(⊤, B∧D) or S'(⊤, B∧D))
2. Applying stavi_untl/stavi_snce_gap_detection to the internal U'/S' to get a (B∧D)-gap
3. Proving the (B∧D)-gap is also D-definable on the left, using ¬U'(D, B∧D) to show D-failure in complement
4. Proving the D-between condition: D holds from m to the (B∧D)-gap boundary (combining D on (m,s) from std_untl with D at cut points from the (B∧D)-gap)
5. Proving A^mu at the gap from the compound's other components (S'(A,B) or S(A,B) from compound)

Estimated ~200 lines per case × 3 cases (base.snce + stavi_snce + std_snce in left_formula) + 3 dual cases in right_formula = ~1200 lines total. Can share infrastructure via helper lemmas for steps 3-4.

## Secondary Finding: stavi_snce_gap_detection RHS Asymmetry

The RHS of `stavi_snce_gap_detection` asks for `X^mu at Sum.inr γ` (mu-truth at the gap), while `stavi_untl_gap_detection` asks for `X at complement points below s_bound` (standard truth at actual points).

The stavi_untl pattern is WEAKER and easier to prove. The bridge from "X at nearby points" to "X^mu at gap" is done in left_formula_gap_detection (the backward direction sorry sites, which need the FO-table shift lemma).

The stavi_snce RHS requires this bridge to be built INTO the gap detection theorem, making it harder. Consider refactoring to match the untl pattern:

```lean
-- Current (harder):
  stavi_temporal_truth_mu M atomMap r (Sum.inr γ) X

-- Proposed (matches untl pattern):
  (∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
    stavi_temporal_truth M atomMap u X)
```

## Current Sorry Status (9 of 11 remaining)

| # | Location | Status | Blocker |
|---|----------|--------|---------|
| 1 | std_untl_gap_detection (2682) | INCORRECT | Theorem is false (see above) |
| 2 | base.snce (2899) | BLOCKED | Depends on #1 |
| 3 | stavi_untl backward (3164) | BLOCKED | Needs FO-table shift lemma |
| 4 | stavi_snce case (3168) | BLOCKED | Depends on #7 |
| 5 | std_untl backward (3215) | BLOCKED | Needs FO-table shift lemma |
| 6 | std_snce case (3219) | BLOCKED | Depends on #8 |
| 7 | stavi_snce_gap_detection (3241) | NEEDS REFACTOR | RHS too strong; provable with weaker RHS |
| 8 | std_snce_gap_detection (3256) | INCORRECT | Same bug as #1 (past dual) |
| 9 | right_formula_gap_detection (3269) | BLOCKED | Depends on #7, #8 |

## Recommended Approach (Ordered)

1. **Fix std_untl/std_snce theorem statements** — either Option A (add hypothesis) or Option C (remove theorems, prove cases directly). Research needed to determine if Option A's hypothesis suffices for gap construction.

2. **Refactor stavi_snce_gap_detection RHS** to match the untl pattern (with s_bound and X at cut points). Then prove by mirroring the ~250-line stavi_untl proof with reversed inequalities.

3. **Develop the FO-table shift lemma** — needed for backward directions (#3, #5) and for bridging X at nearby points to X^mu at gap in left/right_formula_gap_detection.

4. **Close remaining cases** using the fixed/new infrastructure.

## Files Analyzed (Not Modified)

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` — all analysis
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` — stavi_temporal_truth definition
