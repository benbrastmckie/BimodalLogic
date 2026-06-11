# Phase 3 Handoff: Deep Analysis of k+1 Backward Direction

**Task**: 273 | **Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Current State

NegationClosure.lean: 1 sorry remains at line 366. No code changes from prior state.

### Sorry Location
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean:366`
- Context: `master_induction`, P2(k+1) backward direction
- Goal: `∃ x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x fun x ↦ t) sub_nf`
- Given: `h_formula : temporal_truth M atomMap t (nf_exist_formula atomMap h_surj (k + 1) char_kp1 parent_atoms sub_nf)`

## Root Cause Analysis (Definitive)

The formula `nf_exist_formula` at depth k+1 encodes:
- Atom compatibility of witness x with sub_nf at variable 0
- Order between x and t (via Until/Since/identity)
- Depth-(k+1) arity-1 NF characterization of x (via char_kp1)

It does NOT encode the **quantifier part** of sub_nf (sub_nf.2). Therefore, the backward direction is UNPROVABLE: the formula truth guarantees x has the right atoms and the right 1-var NF, but the 2-var NF of (x,t) might differ from sub_nf in its quantifier part.

### Why the Composition Theorem Fails

The "composition theorem" — that the depth-k 2-var NF of (x,t) is determined by the depth-k 1-var NFs of x and t plus their order — is FALSE at all depths k ≥ 1 on Prior structures.

**Concrete counterexample**: Consider a Prior structure M with points t < x. The depth-1 1-var NF of x says "∃ y < x with depth-0 1-var NF τ". The depth-1 1-var NF of t says "∃ y > t with type τ". But "∃ y ∈ (t,x) with type τ" is NOT determined by these facts alone — all type-τ points below x could be ≤ t, and all type-τ points above t could be ≥ x.

The interval existence "∃ y ∈ (t,x) with type τ" is part of the depth-1 2-var NF of (x,t) (via the quantifier part that asks about depth-0 3-var NFs (y,x,t)). It is genuinely NOT determined by the 1-var NFs of x and t.

### Why NF-Transfer Fails

The "NF-transfer" approach — showing that two points with the same depth-(k+1) 1-var NF agree on whether `∃ x, nf_eval_nf M (k+1) 2 (x,t) sub_nf` — fails because the existential has monadic FO quantifier depth k+2, exceeding the depth-(k+1) NF agreement provided by `doets_lemma_1_1`.

Even on Prior structures, two points with the same depth-(k+1) 1-var NF can disagree on depth-(k+2) properties.

### Why the Classical Approach Fails

Defining `good_nf(nf_t) = ∃ M₀ h_UZ₀ h_SZ₀ t₀, nf_t_satisfies ∧ existential_holds` and building `A = ∨_{good nf_t} char_kp1(nf_t)`:
- Forward direction: trivially proved
- Backward direction: requires transferring the existential from M₀ to M when both have NF nf_t. This IS NF-transfer, which fails.

## Correct Approach: Explicit Interval-Based Formula

The formula for P2(k+1) must explicitly encode sub_nf.2 (the quantifier part) using temporal operators. This is the Rabinovich VEF negation closure content.

### Formula Construction

For the Until case (sub_nf says t < x):

1. **Non-interval conditions** (y > x, y = x, y < t, y = t): These conditions on sub_nf.2 are encoded in the NF of x (for y > x, y = x) and t (for y < t, y = t). They become boolean conditions on which nf_x values are compatible with sub_nf.2.

2. **Interval conditions** (y ∈ (t,x)): For each ssn : NF sig k 3 with sub_nf.2(ssn) = true and ssn requiring y ∈ (t,x): place a witness of the appropriate type in the interval using **nested Until / buildRight**.

3. **Negative interval conditions** (y ∈ (t,x) must NOT exist): Encode using the **Until guard** — `∀ r ∈ (t,x), ¬char_k(τ_forbidden)(r)`.

4. **Disjunction over orderings**: The interval witnesses can appear in any order, so take a disjunction over all orderings of the positive interval types.

### Formula Structure

```
∨_{nf_x compatible with sub_nf, ordering σ}
  Until(
    char_k(τ_{σ(1)}),          -- first interval witness
    ¬forbidden_types ∧ Until(
      char_k(τ_{σ(2)}),        -- second interval witness
      ¬forbidden_types ∧ Until(
        ...
        Until(
          char_kp1(nf_x) ∧ [at-x conditions],  -- main witness x
          ¬forbidden_types
        )
      )
    )
  )
```

This is exactly the `buildRight` construction from Translation.lean.

### Recursive Structure for k > 0

At depth k > 0, the 3-var NF ssn has quantifier information. The type τ of an interval witness y is NOT just the depth-k 1-var NF of y — it includes depth-(k-1) interactions between y, x, and t.

To handle this, generalize P2 to all arities: P2_n(k) for n ≥ 2. The chain of dependencies:
- P2_2(k+1) needs P2_3(k) (for 3-var quantifier conditions)
- P2_3(k) needs P2_4(k-1) (for 4-var quantifier conditions)
- ...
- P2_{k+3}(0) is trivially atoms

Total chain length: k+1 levels. At depth 0, all arities are handled (atoms only).

### Implementation Estimate

- Define P2_n(k) for general n: ~50 lines
- Build the interval formula (using buildRight/buildLeft): ~200 lines
- Prove forward direction (existential → formula): ~150 lines (follows nf_exist_formula_forward pattern)
- Prove backward direction (formula → existential): ~300 lines (main content: extracting witnesses, showing atom/quantifier conditions, handling interval decomposition with Prior-UZ/SZ)
- Wire into master_induction: ~50 lines

Total: ~750 lines

### Alternative: Simpler Approach for Prior Structures

On Prior structures, first occurrences are ATTAINED (the K+ disjunct is vacuous). This simplifies the interval decomposition: instead of handling the K+ case, we always have an actual witness point.

Furthermore, the interval conditions simplify because Prior-UZ guarantees first occurrences with gaps. So "∃ y ∈ (t,x) with type τ" can be checked via Prior-UZ at t: the first occurrence of type τ above t is either in (t,x) or ≥ x, and this is determined by the formula.

## Immediate Next Action

Implement P2_n(k) for all arities by induction on k, using the buildRight/buildLeft infrastructure from Translation.lean. The proof should:
1. Define a generalized existence formula that encodes the full NF (atoms + quantifiers)
2. Prove both forward and backward directions
3. Replace the current P2(k+1) formula and proof in master_induction

## File Inventory

| File | Sorries |
|------|---------|
| Kamp/NegationClosure.lean | 1 (k+1 backward, line 366) |
| Kamp/NfCharFormula.lean | 1 (nf_2var_exist_formula_prior) |
| Kamp/KampPrior.lean | 1 (nf_characterizable_temporal_prior k+1) |
| All others | 0 |
