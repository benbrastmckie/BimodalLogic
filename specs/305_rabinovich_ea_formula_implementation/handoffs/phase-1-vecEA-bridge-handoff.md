# Phase 1 Handoff: VecEA Bridge (BLOCKED)

## Status: BLOCKED

Phase 1 of plan v10 (VecEA bridge for zone-3 existential transfer) is blocked.
The standalone bridge lemma approach is fundamentally incorrect.

## What Was Attempted

Extensive analysis (40+ tool calls) of 5 approaches for depth-0 bounded
existential transfer via VecEA pipeline + 1-var NF agreement:

1. **cross_extend from both endpoints**: Gives w₂ > t' (from t) and w₁ < x' (from x), but neither is guaranteed to be in (t', x'). Can have w₂ ≥ x' AND w₁ ≤ t' simultaneously.

2. **VecEA2.translateLeft temporal formula**: holdsLeft existentially quantifies the right endpoint. Transfer gives ∃ x'' > t', ∃ w' ∈ (t', x''), but x'' ≠ x' in general.

3. **Nested Until via char_fn**: Formula `True U (char_fn nf_w AND (True U char_fn nf_x))` at t encodes ∃ w > t with pred_w AND ∃ v > w with pred_x. Captured by depth-2 1-var NF. Transfer gives v' > w' > t' with pred_x(v'), but v' ≠ x', so w' may not be < x'.

4. **Prior-UZ/SZ first/last occurrence**: First occurrence of pred_w above t' may be ≥ x'. Last occurrence below x' may be ≤ t'. UZ/SZ don't prevent "no pred_w in (t', x')".

5. **Depth-1 2-var NF quantifier conditions**: Encode 3-var conditions (∃ v > w with pred_x) in the depth-1 pair NF at [w,t]. Transfer gives the 3-var condition on N side, but the v' produced is not x', so the bound w < x doesn't transfer.

## Root Cause

1-var NF agreement at individual endpoints does NOT jointly constrain the interval between them. Each endpoint's NF captures half-line conditions, not conditions bounded by the other endpoint. The bounded existential ∃ w ∈ (t', x') requires JOINT pair information about [x,t], which is the very 2-var agreement being proved.

## Correct Resolution (from Research Report 07)

Generalize the outer strong induction in `prior_nonconstenv_2var_agree_until` to prove **r-var agreement for ALL r ≥ 2 simultaneously**:

```lean
theorem prior_nonconstenv_rvar_agree_gen
    (K : Nat) : ∀ (r : Nat) (hr : r ≥ 2)
      (M N) (env : Fin r → M.carrier) (env' : Fin r → N.carrier)
      (h_1var_depth_K2 : ∀ i, ∀ nf : NormalForm sig (K+2) 1, ...)
      (h_order : ∀ i j, env i < env j ↔ env' i < env' j)
      (char_fn char_correct),
      ∀ nf : NormalForm sig (K+2) r, M agrees with N
```

Then ih_strong at m=K-1 with arity r+1 gives depth-(K+1) (r+1)-var agreement.
The new variable's 1-var agreement comes from cross_extend (depth K+1), and its
order relative to all env elements is encoded in the (r+1)-var NF atoms.

## Recommended Next Steps

1. **Revise plan v10**: Replace Phases 1-3 with a single phase that restructures `prior_nonconstenv_2var_agree_until` into `prior_nonconstenv_rvar_agree_gen`.

2. **Key implementation**: The outer `Nat.strong_induction_on K` stays. The quantifier step at depth K+2, arity r needs:
   - Atom agreement: from `nonconstenv_atom_agree` generalized to r-var
   - Quantifier conditions: apply ih_strong at m=K-1, arity r+1, with:
     - New variable from cross_extend (gives depth-(K+1) 2-var agreement at [z, env_ref])
     - 1-var for new variable: extract from the 2-var agreement (depth K+1)
     - Order for new variable: extract from the 2-var agreement (atoms)
     - All env components: h_1var weakened from depth K+2 to depth K+1

3. **Preserve**: All sorry-free infrastructure (VecEADecomp, VecEATranslation, NfToVecEA, etc.) remains untouched.

## File Created

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorExistPart.lean` (placeholder with blocker documentation)

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| PriorComposition.lean | 524 | `prior_exist_transfer_one_dir` | One-directional existential transfer on Prior structures | Approach via standalone bridge lemmas is incorrect; needs generalized arity induction | Revise plan, implement rvar_agree_gen |
| PriorComposition.lean | 595 | sorry in `prior_nonconstenv_2var_agree_until` (forward) | nf_eval N (K+1) 3 [w₂,x',t'] sub_nf from hw₂ | Same root cause as line 524 | Follows from rvar_agree_gen |
| PriorComposition.lean | 599 | sorry in `prior_nonconstenv_2var_agree_until` (backward) | Symmetric to 595 | Same root cause | Follows from rvar_agree_gen |
| PriorComposition.lean | 650 | sorry in `prior_nonconstenv_2var_agree_since` (forward) | Since-zone version of 595 | Same root cause | Follows from rvar_agree_gen |
| PriorComposition.lean | 654 | sorry in `prior_nonconstenv_2var_agree_since` (backward) | Since-zone version of 599 | Same root cause | Follows from rvar_agree_gen |
