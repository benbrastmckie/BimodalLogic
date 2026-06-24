# Phase 2 Dispatch 3 Handoff -- NfDepth0Generalized Forward Direction

## Immediate Next Action

Implement the translateEF1-based forward direction for `nf_nvar_exist_depth0_tl`
succ case at NfDepth0Generalized.lean line 521.

## Current State

- **Phase 2 status**: IN PROGRESS (1 sorry remaining at line 521)
- **Sorry location**: Forward direction of biconditional in succ n case
- **Backward direction**: PROVED (sorry-free, lines 532-635 -- MUST PRESERVE)
- **Build status**: Builds with 1 sorry (no other errors)
- **Import**: Translation.lean is NOT yet imported (needs adding)

## Deep Analysis Result

### Why the Current Approach Fails

The current formula uses `restrict_inner` (positions 0..n with free variable at
position n = x). The IH at x gives env' satisfying conditions among themselves
and relative to x. Cross-conditions between env'(i) and t are NOT captured.

This is FUNDAMENTAL: in temporal logic, a formula evaluated at point x can only
produce witnesses relative to x. It cannot constrain witnesses relative to some
other point t. So any formula of the form `S(A_inner, top)` where A_inner is
evaluated at x will always have this cross-condition gap.

### Why Transitivity Doesn't Help

Even establishing NF-boolean transitivity from a satisfying assignment doesn't
fix the issue. The problem: if env'(i) > x and x < t, transitivity tells us
sub_nf(.order i (n+1)) should be SOME value. But the IH produces env'(i) > x
without constraining env'(i) relative to t. So env'(i) might be between x and t
(satisfying env'(i) < t) or beyond t (satisfying env'(i) > t). The formula
doesn't distinguish these cases.

### The Correct Solution: translateEF1

Use `translateEF1` from Translation.lean to handle ALL n+2 positions in a single
Since/Until chain. This avoids cross-conditions because the chain nesting
automatically enforces the relative ordering of all positions.

**translateEF1 signature**:
```lean
translateEF1 (n : Nat) (k : Fin (n + 1))
    (alpha : Fin (n + 1) → TemporalPred) (beta : Fin (n + 2) → TemporalPred) : Formula
```

**translateEF1_correct**:
```lean
temporal_truth M atomMap t (translateEF1 n k alpha beta) ↔
    (alpha k).eval_at M atomMap t ∧
    buildRight_spec M atomMap (right_pairs) (beta ⟨n + 1, _⟩) t ∧
    buildLeft_spec M atomMap (left_pairs) (beta ⟨0, _⟩) t
```

At depth 0, beta = TemporalPred.top for all intervals.

### Implementation Plan

1. **Add import**: `import Bimodal.Metalogic.WeakCanonical.Kamp.Translation`

2. **Replace the succ case** (lines 191-635) with:

```
| succ n _ih =>
  by_cases h_empty : ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      ¬ ∃ env, nf_eval_nf M 0 (n+2) (insertEnv env t) sub_nf
  · -- Empty: bot
    exact ⟨Formula.bot, fun M t => ⟨False.elim, fun h => h_empty M t h⟩⟩
  · -- Non-empty: build translateEF1 formula
    push_neg at h_empty
    obtain ⟨M₀, t₀, env₀, h_nf₀⟩ := h_empty
    -- Define sorted permutation from the satisfying assignment
    -- Build alpha/beta arrays
    -- Use translateEF1 with k = rank of t
    -- Prove biconditional using translateEF1_correct
```

3. **Sorting infrastructure**: Define the rank of each position using
   the satisfying assignment. The rank of position j = number of positions
   with strictly smaller image under `insertEnv env₀ t₀`. Use
   `Fintype.card {i // insertEnv env₀ t₀ i < insertEnv env₀ t₀ j}`.

4. **Alpha/beta construction**:
   - `alpha(rank) = nfPredAtPos atomMap h_surj sub_nf (pos_at_rank rank)`
   - `beta(i) = TemporalPred.top` for all i

5. **Correctness proof**: Show that `buildRight_spec` and `buildLeft_spec`
   from translateEF1_correct correspond to the existential from nf_eval_nf.
   The right chain places witnesses > t in increasing order, the left chain
   places witnesses < t in decreasing order.

### Key Technical Challenges

- **Rank might not be injective**: Two positions with the same image
  (pts(i) = pts(j)) share the same rank. Handle by using a tie-breaking
  rule (e.g., by index). Use `Fintype.card {k // pts k < pts j ∨ (pts k = pts j ∧ k.val < j.val)}`
  for a strict total order on ranks.

- **Rank depends on M₀**: The rank function is defined using the satisfying
  assignment in M₀. But the formula must work for ALL M. The key: the
  formula's structure depends only on the COMBINATORIAL ordering (which
  equals sub_nf's order booleans), not on the specific M₀. So the rank
  equals `#{i | sub_nf(.order i j) = true}` for positions with strictly
  distinct images (no ties in the satisfying assignment).

- **Proving the biconditional**: The main proof work. Need to show that
  the buildRight_spec witnesses correspond to the "above t" existential
  variables, and buildLeft_spec witnesses correspond to the "below t"
  existential variables.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| NfDepth0Generalized.lean | 521 | nf_nvar_exist_depth0_tl (forward direction of succ case) | That the temporal formula implies the existential with all cross-conditions | Current formula cannot capture cross-conditions between inner variables and t when they're on the same side of x | Replace succ case with translateEF1-based formula that handles all positions simultaneously |

## Key Files

- NfDepth0Generalized.lean: 645 lines, 1 sorry at line 521
- Translation.lean: has translateEF1, translateEF1_correct, buildRight_correct, buildLeft_correct (all sorry-free)
- ExistsForallNF.lean: has buildRight, buildLeft, translateEF1 definitions
- NfToVecEA.lean: has nf_2var_exist_depth0_tl (arity-2 reference, sorry-free)

## Critical Constraints

1. PRESERVE the backward direction proof (lines 532-635) -- it is sorry-free
2. The convenience wrappers at lines 637-645 depend on nf_nvar_exist_depth0_tl and must continue to work
3. The zero case (lines 169-190) is sorry-free and must not change
