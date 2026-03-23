# Teammate A Findings: Nesting Boundary Bypass (Alternative 3B)

**Task**: 34 - prove_succ_seed_consistency_axioms
**Focus**: Verify viability of Alternative 3B (bypass local F-step via nesting boundary)
**Date**: 2026-03-23
**Confidence**: HIGH

## Executive Summary

**Is Alternative 3B viable?** **NO**

The bypass hypothesis is fundamentally flawed. While `f_nesting_boundary` correctly identifies *where* an F-witness must exist, the `bounded_witness` theorem still requires building a *chain of Succ-related MCSes* to propagate the witness. Each link in that chain requires the F-step property, which for backward chain indices depends on `predecessor_f_step_axiom`.

## Analysis

### What Alternative 3B Claimed

The previous research suggested:

> "The truth lemma may not need local F-step at every predecessor. Instead, F-witnesses only need to *eventually resolve* somewhere in the chain, which is already guaranteed by `f_nesting_boundary` and `p_nesting_boundary`."

### What I Found

#### Dependency Chain (Traced Through Code)

```
SuccChainTruth.lean (truth lemma backward G direction)
  -> temporal_backward_G (TemporalCoherence.lean:166)
    -> forward_F (TemporalCoherentFamily structure)
      -> succ_chain_forward_F (SuccChainFMCS.lean:794)
        -> for negative indices: succ_chain_forward_F_neg (line 750)
          -> succ_chain_canonicalTask_forward_MCS_from (line 525)
            -> succ_chain_fam_succ (line 292)
              -> for negative indices: backward_chain_pred (line 252)
                -> predecessor_succ (SuccExistence.lean:660)
                  -> predecessor_f_step_axiom (line 652)
```

#### The Critical Mechanism

The `bounded_witness` theorem (CanonicalTaskRelation.lean:651) is the key mechanism for proving F-coherence. It requires THREE inputs:

1. `iter_F n phi in u` - nesting boundary provides this
2. `iter_F (n+1) phi not in u` - nesting boundary provides this
3. **`CanonicalTask_forward_MCS u n v`** - REQUIRES building a chain

The third requirement is where the bypass fails. Building a chain of n MCSes requires:

```lean
inductive CanonicalTask_forward_MCS : Set Formula -> Nat -> Set Formula -> Prop
  | base (h_mcs : SetMaximalConsistent u) : CanonicalTask_forward_MCS u 0 u
  | step (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
         (h_succ : Succ u v)  -- <-- REQUIRES Succ relation
         (h_chain : CanonicalTask_forward_MCS v n w) :
         CanonicalTask_forward_MCS u (n + 1) w
```

Each step requires `Succ u v`, which has two conditions:
1. `g_content(u) subseteq v` (G-persistence)
2. **`f_content(u) subseteq v union f_content(v)`** (F-step) - THE AXIOM

#### Why `single_step_forcing` Needs F-step

The proof of `bounded_witness` uses `single_step_forcing` at each step (SuccRelation.lean:233):

```
If F(phi) in u AND FF(phi) not in u AND Succ(u, v), then phi in v
```

The proof critically uses the F-step property (line 261-262):
```lean
-- Step 6: phi in f_content(u), so by F-step: phi in v OR phi in f_content(v)
have h_phi_in_f_content_u : phi in f_content u := h_F
have h_union : phi in v union f_content v := h_succ.2 h_phi_in_f_content_u
```

Without F-step (`h_succ.2`), we cannot conclude `phi in v union f_content(v)`.

#### Why Nesting Boundary Alone Is Insufficient

The nesting boundary tells us:
- There exists d >= 1 with `iter_F d phi in M` and `iter_F (d+1) phi not in M`

But it does NOT tell us:
- That the witness phi actually appears at some specific MCS in the chain
- How to propagate the witness through intermediate MCSes

The witness MUST propagate through each link of the chain because:
- At step 1: `F(iter_F (d-1) phi) in u, FF(iter_F (d-1) phi) not in u` => `iter_F (d-1) phi in w`
- At step 2: Similar reasoning for next step
- ...
- At step d: Finally `phi in v`

Each propagation requires F-step to ensure the witness doesn't "disappear" into `f_content` without reaching the target.

### What Would Be Needed for a True Bypass

A genuine bypass would require proving that F-witnesses "teleport" directly to their destination without intermediate propagation. This would require either:

1. **Direct witness existence**: A theorem stating that if `F(phi) in M` at index n, then `phi in M'` at some index m > n, without building an intermediate chain.

2. **Global F-coherence from frame conditions**: Deriving F-witness existence from discrete frame properties alone.

Neither is available in the current infrastructure, and both would essentially BE the axiom in different form.

### The Fundamental Asymmetry (Confirmed)

The previous research correctly identified the h/g vs f/p asymmetry:

| Property | Transfer Direction | Axiom | Status |
|----------|-------------------|-------|--------|
| G-persistence | `g_content(u) subseteq v` | temp_a | **Proven** |
| F-step | `f_content(u) subseteq v union f_content(v)` | NONE | **Axiom** |

The G-persistence follows from `phi -> G(P(phi))` (temp_a axiom), but no analogous axiom gives F-step.

## Conclusion

**Alternative 3B is NOT viable.**

The bypass hypothesis conflates two distinct requirements:
1. Knowing WHERE the witness must exist (nesting boundary provides this)
2. Proving the witness PROPAGATES correctly (requires F-step at each chain link)

The `f_nesting_boundary` and `p_nesting_boundary` provide (1) but cannot provide (2).

## Recommendations

1. **Accept `predecessor_f_step_axiom` as permanent** with the documented semantic justification (discrete linear frames enforce this property).

2. **Do not invest further in bypass approaches** - the chain-building requirement is fundamental to the bounded_witness mechanism.

3. **Consider alternative approaches only if axiom-freedom becomes a hard requirement**:
   - Constrained Lindenbaum (Alternative 1/2)
   - Stage-by-stage construction (Segerberg/Verbrugge)
   - Both require major infrastructure refactoring

## Code References

| File | Line | Purpose |
|------|------|---------|
| SuccExistence.lean | 652 | `predecessor_f_step_axiom` definition |
| SuccExistence.lean | 660 | `predecessor_succ` using axiom |
| SuccChainFMCS.lean | 252 | `backward_chain_pred` using `predecessor_succ` |
| SuccChainFMCS.lean | 292 | `succ_chain_fam_succ` using `backward_chain_pred` |
| SuccChainFMCS.lean | 525 | `succ_chain_canonicalTask_forward_MCS_from` building chain |
| SuccChainFMCS.lean | 750 | `succ_chain_forward_F_neg` using chain |
| SuccChainFMCS.lean | 738 | `f_nesting_boundary` (has sorry in boundedness) |
| CanonicalTaskRelation.lean | 651 | `bounded_witness` requiring chain |
| SuccRelation.lean | 233 | `single_step_forcing` using F-step |
| TemporalCoherence.lean | 166 | `temporal_backward_G` using `forward_F` |
