# JD=1 Circularity Analysis — Task 157 Phase 3

**Date**: 2026-05-19
**Status**: BLOCKED
**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` lines ~1773 and ~1806

## Problem Statement

`all_formulas_separable_aux` uses `Nat.strongRecOn` on `junction_depth`. At each JD level n, structural induction handles the formula cases. The `.snce a b` and `.untl a b` cases at JD level n:

1. Get separated forms of a and b (via structural IH)
2. Box-normalize to `.snce χa χb` (or swap for `.untl`)
3. Prove `no_S_nested_in_U` and `junction_depth ≤ 1`
4. Apply `no_S_nested_in_U_separable_param_jd` with a callback from the JD IH

The callback receives formulas ζ with `no_S_nested_in_U ζ` and `junction_depth ζ ≤ 1`.

- **n ≥ 2**: `junction_depth ζ ≤ 1 < 2 ≤ n`, so `ih_jd 1 (by omega)` works. PROVED.
- **n = 0**: Direct `jd_zero_sep`. PROVED.
- **n = 1**: Need `junction_depth ζ ≤ 0` but only have `junction_depth ζ ≤ 1`. **GAP**.

## Root Cause: Identity Roundtrip

The callback formula ζ comes from `subst_in_separated_separable_jd` at a `.snce c d` node in the separated form. For the identity roundtrip case:

```
φ = .snce (.untl A B) q     -- count_U = 1, JD = 1
abstract .untl A B:  φ' = .snce (atom p) q     -- count_U = 0, U-free
separated form:      psi = .snce (atom p) q     -- already separated
substitute back:     subst psi p (.untl A B)
  at top .snce:      c = atom p, d = q          -- both U-free
  callback:          .snce (.untl A B) q = φ    -- SAME FORMULA!
```

The callback returns the **exact same formula**. No measure on a single formula decreases:
- `count_U_subformulas`: 1 → 1 (unchanged)
- `sizeOf`: S → S (unchanged)
- `junction_depth`: 1 → 1 (unchanged)
- `snce_depth_of_U`: 1 → 1 (unchanged)

## Why Each Approach Fails

### Approach A: Prove callback JD = 0
**Disproved by counterexample.** The callback `.snce (.untl A B) q` has `junction_depth_S (.untl A B) = 1 + max(JD A, JD B) = 1` (A, B S-free → JD = 0). So `junction_depth = max(1, JD_S q)`. If q is U-free: `JD_S q = 0`. Callback JD = 1, not 0.

### Approach B: Lexicographic (count_U, sizeOf) induction
**Fails because neither component decreases.** The callback count_U equals the original count_U in the identity roundtrip case.

### Approach C: snce_depth_of_U as measure
**Fails because it can increase.** If the separated form has nested `.snce`, the substitution can place `.untl A B` under two `.snce` nodes, giving `snce_depth_of_U ≥ 2 > 1`.

### Approach D: Self-recursive callback
**Non-terminating.** Processing the callback formula through `no_S_nested_in_U_separable_param_jd` reproduces the same callback (identity roundtrip), creating an infinite loop.

### Approach E: Process χa, χb separately
**Gives is_separable for each arg but not for .snce of them.** Processing χa via `no_S_nested_in_U_separable_param_jd` works (inner `.snce` callbacks have JD = 0 because the fresh atom is NOT inside `.snce` args of the separated form — key structural insight: in a separated formula, `.untl` is not inside `.snce` args, so after abstraction the atom is not inside `.snce` args). But we already have `is_separable a` and `is_separable b` from the structural IH. The gap is `is_separable (.snce a b)` given `is_separable a` and `is_separable b` — this IS `snce_separable`.

### Approach F: Cases 1-8 directly
**Requires U-free A, B.** At JD=1, the `.untl A B` args A, B are S-free but NOT necessarily U-free (S-free formulas can contain `.untl`). Cases 1-8 all require both U-free AND S-free a, q, A, B.

### Approach G: Change junction_depth definition (+1)
**Just shifts the problem.** Adding 1 to `.snce`/`.untl` in `junction_depth` makes JD=1 trivial (`.snce` with U-free args → separated) but creates the same gap at JD=2 (or wherever the first non-trivial case occurs).

## Fundamental Insight

The 2 sorry calls are **mathematically equivalent to `snce_separable`**: given `is_separable a` and `is_separable b`, prove `is_separable (.snce a b)`. This is the temporal closure axiom. The current proof architecture tries to derive it via abstraction/substitution + JD induction, but the JD=1 callback is circular.

## Possible Restructurings (Require Significant New Work)

### Path 1: Change junction_depth definition so JD=1 is trivial
- Add +1 to `.snce` and `.untl` in junction_depth
- New JD=0: no temporal operators → trivially separated
- New JD=1: `.snce`/`.untl` with args having JD_S/JD_U = 0 → args are U-free/S-free → syntactically separated
- The gap moves to JD=2, but at JD=2 the `.untl A B` args have JD(A) = 0, JD(B) = 0 under the new definition, which means A, B are purely boolean (no temporal operators) → BOTH S-free AND U-free → Cases 1-8 apply
- **Cost**: Re-prove ~20 JD-related lemmas (`jd_imp_le_left`, `jd_snce_le_left`, `callback_jd_le_one`, `snce_of_boxfree_sep_jd_le_one`, etc.)
- **Risk**: The callback JD at new JD=2 needs to be ≤ 1 (not ≤ 2). Need to verify this bound holds with the new definition.

### Path 2: Replace count_U induction with direct structural decomposition
- For `no_S_nested_in_U` formulas with JD ≤ 1: prove separability WITHOUT abstraction/substitution
- Use structural induction on the formula, handling each `.snce` directly via Cases 1-8 after ensuring U-free + S-free args
- May require a sub-lemma that "flattens" nested `.untl` in S-free args to produce U-free equivalents
- **Cost**: New lemma + structural induction proof (~200-400 LOC)
- **Risk**: S-free formulas with nested `.untl` cannot be made U-free in general

### Path 3: Global ordinal measure
- Use well-founded induction on a measure like `ω² × snce_above_untl + ω × count_U + sizeOf` that accounts for the entire callback chain
- The key insight: across multiple levels of callback, the TOTAL work decreases even though individual callbacks may not
- **Cost**: Custom `WellFoundedRelation` + complex termination proof (~300-500 LOC)
- **Risk**: Hard to formalize in Lean 4; the termination argument is conceptually clear but technically subtle

### Path 4 (RECOMMENDED): Change junction_depth + verify callback bound
The cleanest approach is Path 1. The key verification: with the +1 definition, at JD=2 (corresponding to current JD=1), the `.untl A B` args have JD = 0 under the new definition, meaning:
- No `.snce` in A (S-free from `no_S_nested_in_U`)
- No `.untl` in A (because `junction_depth_U A = 0` and with +1, `.untl` contributes 1)

Wait — with +1, `junction_depth (.untl a b) = 1 + max(jd_U a, jd_U b)`. For A S-free: `jd_U (.untl c d) = max(jd_U c, jd_U d)`. If A = `.untl (atom 1) (atom 2)`: `jd A = 1 + max(0, 0) = 1`. So at new JD=2: `jd_S (.untl A B) = 1 + max(jd A, jd B) = 1 + 1 = 2`. And the `.snce` level: `jd (.snce χa χb) = 1 + max(jd_S χa, jd_S χb) = 1 + 2 = 3`.

So the gap is at JD=3 now, not JD=2. The +1 approach shifts the problem but doesn't eliminate it unless the specific structure at the new JD ensures the `.untl` args are U-free.

**REVISED RECOMMENDATION**: Path 1 only works if we can prove that at the NEW lowest non-trivial JD level, the `.untl` args are guaranteed to be both S-free AND U-free. This requires careful analysis of the JD bounds under the modified definition.

## Next Action

Review this analysis and decide which restructuring path to pursue. Paths 1 and 2 are the most promising. Path 3 is the most general but hardest to implement.
