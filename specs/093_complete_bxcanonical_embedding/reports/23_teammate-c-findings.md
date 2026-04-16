# Research Report: Teammate C (Critic) — Round 23 Critical Analysis

**Task**: 93 — Complete BXCanonical embedding (6 sorry sites in RootScopedChain.lean)
**Date**: 2026-04-16
**Session**: sess_1776360019_c23cc
**Role**: Teammate C (Critic)

---

## Key Findings

### Finding 1: The fold-order trick (Teammate A's "highest-priority attempt") has a fatal flaw — and it is NOT the one identified in Round 22

The Round 22 synthesis correctly identified that Case 2 deferral is NOT prevented by
processing target last. But the synthesis missed a more fundamental issue:

**The BX11 fold in `enriched_fwd_fold_with_witness` always starts with `target` in
the `tracked` list, and folds `others` one at a time.**

When target is processed last (i.e., added as the final element in `others` instead
of the initial `β`), the call to `resolving_enriched_fwd_exists` would need to pass
`others ++ [target]` — but the function takes a dedicated `target` argument that is
the seed's direct starting formula. The function signature is:

```
resolving_enriched_fwd_exists h_mcs target h_F_target others h_F_others
```

The fold in `enriched_fwd_fold_with_witness` starts with `β = target` and folds
`others` into it. If we want target to be last, we would need to start with `β = others[0]`
(some other formula) and fold the rest including target at the end.

**But `resolving_enriched_fwd_exists` calls the fold with `[target]` as the initial
tracked list and `target` as the initial `β`**, then folds `others`. There is no
interface to start the fold with a different formula. Reordering requires restructuring
the entire fold machinery, which IS the ~30-theorem downstream re-proof.

More critically: if we make `β = others[0]` initially, then `F(others[0]) ∈ M` must
hold, and the seed `{β} ∪ g_content(M)` must be consistent for the Lindenbaum extension
at line 382-384. But `resolving_enriched_fwd_exists` uses
`forward_temporal_witness_seed_consistent M h_mcs β h_Fβ'` — which requires `F(β) ∈ M`,
and β is the fold-output compound (not any fixed formula). The fold-order trick does NOT
change the seed: the seed is still `{β'} ∪ g_content(M)` where `β'` is the BX11 compound.

**Conclusion**: The fold-order trick is not a "2-hour test" for the current infrastructure.
It requires changing the seed itself, which reintroduces the same problem.

### Finding 2: The Round 22 "extended_defect_seed_consistent" lemma is the right mathematical target, but the proof strategy proposed has a gap

The Round 22 Teammate A proposed:

```lean
theorem extended_defect_seed_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M)
    (defects : List Formula)
    (h_F : ∀ ψ ∈ defects, Formula.some_future ψ ∈ M) :
    defects.length > 0 →
    ∃ j : Fin defects.length,
      SetConsistent ({defects.get j} ∪
        (defects.toFinset.erase (defects.get j)).image Formula.some_future ∪
        g_content M)
```

The 2-defect case is `ordered_two_defect_seed_consistent`, which is proved. The
n-defect case is proposed via "running-compound BX11 iteration." Here is the **precise
gap**:

The running-compound iteration produces a formula `β'` such that `F(β') ∈ M` and
from `β' ∈ M'`, each defect satisfies (ψ ∈ M') ∨ (F(ψ) ∈ M'). This is exactly what
`enriched_fwd_fold` already proves. It does NOT prove the existential form of
`extended_defect_seed_consistent`.

The existential form requires: there exists ONE specific j such that the seed
`{defects[j]} ∪ {F(defects[k]) | k ≠ j} ∪ g_content(M)` is consistent.

For this to follow from the fold, we need: among all defects, the SPECIFIC formula
`w` that is guaranteed to be in M' (the direct witness from `enriched_fwd_fold_with_witness`)
satisfies `w = defects[j]` for some specific j, AND the other defects in M' are
all F-protected rather than directly present (so the seed matches exactly).

**The gap**: `enriched_fwd_fold_with_witness` guarantees ∃w such that w ∈ M' AND
each other defect χ satisfies (χ ∈ M') ∨ (F(χ) ∈ M'). But the seed
`{w} ∪ {F(χ) | χ ∈ defects, χ ≠ w} ∪ g_content(M)` needs to be consistent — and
this is NOT the same as what `enriched_resolving_seed_consistent` gives. The fold
builds a compound β', not the actual seed. The seed consistency must be argued
separately.

Specifically: `extended_defect_seed_consistent` with the seed containing ACTUAL
F-formulas for k ≠ j is equivalent to the inconsistent `f_carry`-style seed
when k has formulas not in sigma_list. Round 22 claims the RESTRICTED sigma_list seed
avoids the counterexample — but this claim requires careful verification:

The f_carry counterexample uses `G(F(α) → ¬ψ) ∈ M` with α NOT in sigma_list.
With the restricted seed `{ψ_j} ∪ {F(ψ_k) | k ≠ j, ψ_k ∈ sigma_list} ∪ g_content(M)`,
the issue is whether for any ψ_j in sigma_list, there can be formulas in g_content(M)
that derive ¬ψ_j given the F-formulas of other sigma_list elements. **This is
model-theoretically possible**: if M contains G((F(ψ_1) ∧ F(ψ_2)) → ¬ψ_3) (which
is a G-formula, hence in g_content), and ψ_1, ψ_2, ψ_3 ∈ sigma_list, then
`{ψ_3, F(ψ_1), F(ψ_2)} ∪ g_content(M)` is inconsistent (via
`(F(ψ_1) ∧ F(ψ_2)) → ¬ψ_3 ∈ M'` by g_content, and ψ_3 ∈ seed).

**This specific interaction needs to be checked**: is `G((F(ψ_1) ∧ F(ψ_2)) → ¬ψ_3) ∈ M`
consistent with `F(ψ_1) ∈ M, F(ψ_2) ∈ M, F(ψ_3) ∈ M` for ψ_1, ψ_2, ψ_3 ∈ sigma_list?
Yes, it is: take a frame with times 0 < 1 < 2 < 3 where ψ_1 at t=1, ψ_2 at t=2,
ψ_3 at t=3. At t=0: F(ψ_1), F(ψ_2), F(ψ_3) all hold. G((F(ψ_1)∧F(ψ_2)) → ¬ψ_3)
at t=0 says: at any t ≥ 0, if ψ_1 and ψ_2 have future witnesses, then ¬ψ_3 at t.
At t=0: ψ_3 is not at t=0 (only at t=3), so ¬ψ_3 holds at t=0. ✓
But wait: the seed has ψ_3 (target) and G((F(ψ_1)∧F(ψ_2)) → ¬ψ_3) propagates
`(F(ψ_1)∧F(ψ_2)) → ¬ψ_3` to M' (by g_content). If F(ψ_1) and F(ψ_2) are ALSO in
the seed, then M' derives ¬ψ_3, contradicting ψ_3 in the seed.

**Conclusion**: The restricted sigma_list seed `{ψ_j} ∪ {F(ψ_k) | k ≠ j} ∪ g_content(M)`
IS potentially inconsistent even with only sigma_list F-formulas. The Round 22 claim
that restricting to sigma_list avoids the counterexample is NOT obviously correct.
A concrete 3-defect inconsistency counterexample exists (above), meaning
`extended_defect_seed_consistent` is FALSE IN GENERAL for n ≥ 3.

### Finding 3: The 2-defect base case (ordered_two_defect_seed_consistent) works precisely because BX11 eliminates cross-contamination — and this DOES NOT generalize

`ordered_two_defect_seed_consistent` proves: `F(ψ₁ ∧ F(ψ₂)) ∈ M → {ψ₁, F(ψ₂)} ∪ g_content(M)` is consistent.

Why does this work? Because `F(ψ₁ ∧ F(ψ₂)) ∈ M` witnesses an actual MCS M' where
ψ₁ ∈ M' AND F(ψ₂) ∈ M' AND g_content(M) ⊆ M' (by `enriched_resolving_seed_consistent`).
This M' is the Lindenbaum extension of `{ψ₁ ∧ F(ψ₂)} ∪ g_content(M)`, and `F(ψ₁ ∧ F(ψ₂)) ∈ M`
guarantees this seed is consistent. The key is that we use ONE compound formula
`ψ₁ ∧ F(ψ₂)` as the witness, not two separate formulas.

For 3 defects: `extended_defect_seed_consistent` with j=0 requires the seed
`{ψ_0, F(ψ_1), F(ψ_2)} ∪ g_content(M)` to be consistent. This would follow if
`F(ψ_0 ∧ F(ψ_1) ∧ F(ψ_2)) ∈ M` or `F(ψ_0 ∧ (F(ψ_1) ∧ F(ψ_2))) ∈ M`, because then
we could use `enriched_resolving_seed_consistent` with compound `F(ψ_1) ∧ F(ψ_2)` as α.

**The question**: Does BX11 guarantee `F(ψ_0 ∧ F(ψ_1) ∧ F(ψ_2)) ∈ M` (for SOME ordering
j=0,1,2) given `F(ψ_0), F(ψ_1), F(ψ_2) ∈ M`?

The answer hinges on the 3-cycle problem. BX11 gives either `bx11_earlier M ψ_0 ψ_1`
or `bx11_earlier M ψ_1 ψ_0`. Say `bx11_earlier M ψ_0 ψ_1`, meaning
`F(ψ_0 ∧ ψ_1) ∈ M OR F(ψ_0 ∧ F(ψ_1)) ∈ M`. Apply BX11 again to `F(ψ_0)` (or
`F(ψ_0 ∧ ψ_1)`, or `F(ψ_0 ∧ F(ψ_1))`) and `F(ψ_2)`:
In the best case (Case 2), we get `F((ψ_0 ∧ F(ψ_1)) ∧ F(ψ_2)) ∈ M`, which gives
the consistent seed `{ψ_0, F(ψ_1), F(ψ_2)} ∪ g_content(M)` via
`enriched_resolving_seed_consistent` with `α = F(ψ_1) ∧ F(ψ_2)`.

In Case 3: `F(F(ψ_0 ∧ F(ψ_1)) ∧ ψ_2) ∈ M`, which gives the consistent seed
`{ψ_2, F(ψ_0 ∧ F(ψ_1))} ∪ g_content(M)`, and from F-monotonicity:
`F(ψ_0), F(ψ_1) ∈ M'` (via F(ψ_0 ∧ F(ψ_1)) → F(ψ_0)). So the seed becomes
consistent for j=2, not j=0.

**This actually WORKS for the existential version of extended_defect_seed_consistent!**
In ALL cases of BX11, some ordering of the formulas gives a consistent compound seed.
The existential form (∃ j, seed is consistent) follows from the BX11 fold iterating
through all 3 formulas. The concrete counterexample above (with G((F(ψ_1)∧F(ψ_2))→¬ψ_3))
may not actually show inconsistency in the EXISTENTIAL version — it shows j=3 won't work
but j=1 or j=2 might.

**Revised assessment**: The Round 22 claim about `extended_defect_seed_consistent`
(existential version) may actually be CORRECT. The BX11 fold always produces some β'
such that the Lindenbaum extension of `{β'} ∪ g_content(M)` gives an M' where one
specific formula (the direct witness w) is in M' and others have F-versions. The seed
`{w} ∪ {F(χ) | χ ≠ w, F(χ) ∈ M} ∪ g_content(M)` is a SUBSET of M' (since each
F-formula in M' is in M' and is from the sigma_list), hence consistent.

**Wait — this is not quite right either.** The problem is: "F(χ) ∈ M'" in the Lindenbaum
extension does NOT mean F(χ) was in the seed. The seed is `{β'} ∪ g_content(M)`. The
Lindenbaum extension may add F(χ) to M' arbitrarily (because F(χ) is consistent with
the seed). But if F(χ) is NOT in the seed, it could also add G(¬χ) to M'. So
`{w, F(χ₁), ..., F(χₖ)} ∪ g_content(M)` is a subset of M' ONLY IF the Lindenbaum
extension actually chose to include F(χᵢ) rather than G(¬χᵢ).

The Lindenbaum extension for the seed `{β'} ∪ g_content(M)` does NOT guarantee
F(χ) ∈ M' for all χ with F(χ) ∈ M. It only guarantees the properties extractable
from β' ∈ M'. So the consistent seed claim requires using the fold compound's
extraction property directly — not the Lindenbaum extension.

### Finding 4: A possible route through extended_defect_seed_consistent that avoids the round-robin chain entirely

The BX11 fold gives, for the n defects {ψ_0, ..., ψ_{n-1}}:
1. A compound β' with F(β') ∈ M
2. A direct witness w ∈ {ψ_0, ..., ψ_{n-1}} such that from β' ∈ M': w ∈ M' directly
3. For all other χ: from β' ∈ M': χ ∈ M' ∨ F(χ) ∈ M'

Use `enriched_resolving_seed_consistent` with β' as α and w as the target:
`{w, β'} ∪ g_content(M)` is consistent (since `F(w ∧ β') ∈ M` — wait, is this true?).

Actually, `F(β') ∈ M` and `F(w) ∈ M`. BX11 gives three cases for these. This does NOT
directly give `F(w ∧ β') ∈ M`. The compound β' may be from the fold and may not
relate to w's F-membership via a single conjunction.

**The correct argument**: β' is the fold compound such that from β' ∈ M', w ∈ M'.
The seed for `extended_defect_seed_consistent` with j=index(w) should be:
`{w} ∪ {F(ψ_k) | k ≠ j} ∪ g_content(M)`.
The Lindenbaum extension of `{β'} ∪ g_content(M)` gives M' where w ∈ M' and for
each other ψ_k: ψ_k ∈ M' ∨ F(ψ_k) ∈ M'. This subset property does NOT require
F(ψ_k) ∈ M' for all k ≠ j; it only requires one or the other.

So the seed `{w} ∪ {F(ψ_k)} ∪ g_content(M)` is consistent IFF there EXISTS an MCS
containing w, F(ψ_k) for all k ≠ j, and g_content(M). The Lindenbaum extension M'
has w ∈ M' and for each k: ψ_k ∈ M' ∨ F(ψ_k) ∈ M'. This does NOT place F(ψ_k) in
M' — it could place ψ_k directly. So M' might have {w, ψ₁, ψ₂, ...} rather than
{w, F(ψ₁), F(ψ₂), ...}.

For the seed to be consistent, we need to find any MCS containing BOTH w AND F(ψ_k) for
all k ≠ j. Such an MCS exists IFF the set is consistent. But inconsistency could arise
if g_content(M) derives ¬w from the F-formulas (as in the concrete counterexample above).

**Net conclusion**: `extended_defect_seed_consistent` (existential version, restricted
to sigma_list) is still uncertain. The 2-defect case is proved cleanly. The n-defect
case has a potential proof path via induction and BX11 fold, but requires showing that
the g_content of M cannot derive ¬w given F-formulas of OTHER sigma_list elements.
This requires an analysis of which G-formulas can be in M given the F-obligations
of sigma_list elements — and this is a non-trivial interaction between the temporal
and G-content of M.

### Finding 5: The sorry sites are in the right place — the problem formulation is correct

After reading `rr_fwd_chain_forward_F` and `dd_fmcs_forward_F`, the claim at line 1313 is:
```
F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s)
```
where ψ ∈ sigma_list (a finite list of formulas being tracked).

This is exactly the right thing to prove for the completeness theorem. The
`dd_bfmcs_restricted_tc` at line 1406 requires this for all formulas in `deferralClosure(root)`.
And `deferralClosure(root)` ⊆ sigma_list by the hypothesis `h_sub`. So the statement is
correctly formulated.

**Could we weaken the sorry to something provable?** The sorry at line 1319
`rr_fwd_chain_forward_F` requires `n < s` (strict). If we used `n ≤ s` it would be
trivially provable with `s = n`. The strictness is essential. No weaker formulation
would suffice for the truth lemma (which requires G-formulas to have STRICT future witnesses).

The backward sorry at line 1350 (dd_fmcs_forward_F, t < 0 case) has an interesting structure:
when t < 0 (in the backward chain), F(ψ) ∈ bwd_chain(-t) could mean ψ was witnessed
even earlier (more negative) or in the forward part. This case is potentially independent
of the forward chain issue and may have its own proof path via the backward-to-forward
bridge at M₀.

### Finding 6: The restricted_tc, restricted_buc, restricted_fuc dependency hierarchy is clearer than previously reported

Examining the actual definitions at TemporalCoherence.lean:295, 535, 565:

- `restricted_tc` (line 1406 sorry): requires `forward_F` for φ ∈ deferralClosure(root).
  This IS the same as proving `rr_fwd_chain_forward_F` for sigma_list ⊇ deferralClosure(root).
  **Directly depends on forward_F.** No independence.

- `restricted_fuc` (line 1417 sorry): the definition at line 535-544 requires:
  `∀ t φ ψ, (φ U ψ) ∈ subformulaClosure(root) → (φ U ψ) ∈ fam.mcs t →
  ∃ s ≥ t, ψ ∈ fam.mcs s ∧ ∀ r, t ≤ r < s, φ ∈ fam.mcs r`
  Under **reflexive** Until (s ≥ t, not s > t), the base case s = t gives ψ ∈ fam.mcs t
  directly (from BX9: (φ U ψ) → (φ ∨ ψ), and if ψ ∉ fam.mcs t then from BX10:
  F(ψ) ∈ fam.mcs t, giving forward_F for ψ).
  The s > t case comes from BX10: (φ U ψ) → F(ψ), then forward_F gives s > t.
  **Reduces to forward_F in the strict case, but may be provable via BX10 + forward_F.**
  The BX10 path requires: `(φ U ψ) ∈ fam.mcs t → F(ψ) ∈ fam.mcs t` (trivial from BX10),
  then `forward_F` gives s. **But also need φ ∈ fam.mcs r for t ≤ r < s** (the guard!).
  This guard condition requires additional chain properties beyond just forward_F.
  Specifically: (φ U ψ) ∈ fam.mcs t and forward_F gives ψ ∈ fam.mcs s — but we
  need φ ∈ fam.mcs r for ALL r between t and s. This does NOT follow from forward_F alone.

  **Assessment**: restricted_fuc is NOT trivially reducible to just forward_F — it also
  requires the guard condition, which needs (φ U ψ) ∈ fam.mcs r for t ≤ r < s,
  or equivalently that F(ψ) ∈ fam.mcs r for r between t and s (via BX1/reflexivity).
  The guard `φ ∈ fam.mcs r` for the dd_chain steps between t and s may need additional
  chain-step properties.

- `restricted_buc` (line 1412 sorry): the definition at line 565-574 requires:
  given ψ ∈ fam.mcs s ∧ φ ∈ fam.mcs r for t ≤ r < s, then (φ U ψ) ∈ fam.mcs t.
  Under reflexive Until, the case s = t: ψ ∈ fam.mcs t → (φ U ψ) ∈ fam.mcs t via BX8.
  The case s > t requires step transfer: `(φ U ψ) ∈ fam.mcs r+1 ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`.
  UntilSinceCoherence.lean lines 27-28 explicitly note this step transfer is NOT derivable
  from bare FMCS structure (g_content/h_content).
  **This is genuinely independent of forward_F but requires new chain infrastructure.**

### Finding 7: The dead-in-the-water observation about the negative part (t < 0) case in dd_fmcs_forward_F

The sorry at line 1350 covers the case where t < 0 and F(ψ) ∈ bwd_chain(-t). The comment
says "This sorry depends on rr_fwd_chain_forward_F being proved first."

However, there is a subtle issue: when t < 0 (in the backward chain), F(ψ) ∈ bwd_chain(-t.toNat)
means ψ has a future witness from that backward chain's perspective. But the forward
witness must be at some integer s > t. If t = -5 and F(ψ) ∈ bwd_chain(5), the forward
witness could be at any integer > -5, including positive integers (in the forward chain).

The comment in RootScopedChain.lean:1343-1348 identifies the obstacle: G(F(ψ)) ∈ M₀
would be needed to propagate F(ψ) forward. But G(F(ψ)) is NOT guaranteed from F(ψ) ∈ M.

**An alternative**: Since bwd_chain(-t) is an MCS with g_content propagation from bwd_chain(0) = M₀,
and M₀ → fwd_chain — if F(ψ) ∈ bwd_chain(-t), then by F-obligation stability
(rr_bwd_chain_F_obligation_trans or similar), F(ψ) might propagate backward and forward
to M₀. The key question is whether there exists an analog of
`rr_bwd_chain_F_obligation_persists` for the backward chain. Looking at the backward
chain definition: `bwd_pred M h_mcs target` uses a PAST seed (h_content, not g_content).
F(ψ) is NOT preserved by h_content steps (h_content is about G-formulas in the past,
not F-formulas). So F(ψ) can be lost at backward steps. The t < 0 case is genuinely
harder than the t ≥ 0 case.

---

## Gaps and Shortcomings

### Gap 1: Round 22 confidence in "extended_defect_seed_consistent" is overestimated

Round 22 synthesis rates this at 55-65% and calls it "the KEY mathematical contribution."
The analysis above shows:
- The 2-defect case (proved) works because of a specific structural property
- The n-defect case requires showing g_content cannot derive ¬w from F-formulas of
  OTHER sigma_list elements, which is a non-trivial interaction not yet analyzed
- A concrete potential 3-defect counterexample exists (G((F(ψ_1)∧F(ψ_2))→¬ψ_3) ∈ M
  with all three in sigma_list)
- Whether this counterexample is ACTUALLY realizable in an MCS used for the chain
  requires more careful model-theoretic analysis

The revised estimate should be 35-50% confidence, not 55-65%.

### Gap 2: The guard condition for restricted_fuc is not adequately analyzed

Round 22 treats restricted_fuc as "follows via BX10 reduction" to forward_F.
Finding 6 above shows this misses the guard condition: we need φ ∈ fam.mcs r for
ALL r between t and s, not just ψ ∈ fam.mcs s. This guard may require additional
chain properties (persistence of Until formulas between visits).

### Gap 3: The backward chain (t < 0) F-preservation is treated as identical to forward

The dd_fmcs_forward_F negative case (line 1350) is treated as "once forward_F is proved,
this follows." But the backward chain uses h_content (past preservation), not g_content.
F-formulas are NOT preserved through backward steps. This case may require a completely
different argument — possibly showing F(ψ) ∈ bwd_chain(-t) implies F(ψ) was already
in M₀, then using the forward chain.

### Gap 4: Dead code identification does not reduce any proving burden

Round 22 Teammate D identifies dead code in CanonicalModel.lean. While correct, this
observation has no bearing on the actual sorry site count (the 6 sorries are all in
RootScopedChain.lean) and the suggestion to "mark or delete" them should not be
conflated with progress on the actual task.

---

## Critical Questions

**Q1**: Does the existential version of `extended_defect_seed_consistent` avoid the
G((F(ψ_1)∧F(ψ_2))→¬ψ_3) counterexample? Is there a model where all three conditions
hold and the existential cannot be satisfied?

Specifically: given F(ψ_1), F(ψ_2), F(ψ_3) ∈ M and G((F(ψ_1)∧F(ψ_2))→¬ψ_3) ∈ M,
can the BX11 fold ALWAYS find some j such that the seed {ψ_j, F(ψ_k), k≠j} ∪ g_content(M)
is consistent? The answer is: for j=1 or j=2, the seed is {ψ_1, F(ψ_2), F(ψ_3)} or
{ψ_2, F(ψ_1), F(ψ_3)}, neither of which contains both F(ψ_1) and F(ψ_2) simultaneously.
So `(F(ψ_1)∧F(ψ_2))→¬ψ_3` doesn't apply to seeds with j=1 or j=2. **The answer appears
to be YES — the existential version might be provable.**

**Q2**: Does the guard condition for restricted_fuc (φ ∈ fam.mcs r for t ≤ r < s) follow
from the dd_chain structure? Specifically: if (φ U ψ) ∈ dd_chain(t) and ψ ∈ dd_chain(s)
(from forward_F applied to F(ψ)), can we prove φ ∈ dd_chain(r) for t ≤ r < s?

From `(φ U ψ) ∈ chain(t)` and BX9 (`(φ U ψ) → φ ∨ ψ`) and g_content propagation:
if φ ∈ chain(t), does φ ∈ chain(r) for r > t? NOT necessarily — g_content only
propagates G-formulas. φ itself is not necessarily a G-formula.

**Q3**: Is there a reason why the axiom system does NOT have a theorem
`F(φ ∧ ψ) ∨ F(¬φ) → F(ψ)` that would let us "unpack" F-conjunctions more aggressively?
Such a theorem would help the seed consistency argument. Does BX11 together with other
axioms imply such a transfer principle?

**Q4**: For the `dd_fmcs_backward_P` sorry (line 1357), is the proof completely symmetric
to `dd_fmcs_forward_F`? Is there any structural asymmetry in the forward/backward chains
that makes one harder?

---

## Confidence Level

**High confidence** (90%+) on the following:

1. The fold-order trick IS more subtle than Round 22 suggests. It does NOT reduce to a
   2-hour test and requires at minimum restructuring the fold interface.

2. `restricted_buc` requires step transfer that is independent of forward_F. This is
   non-trivial and requires new chain infrastructure (possibly the g_content-enriched
   Until propagation).

3. The 2-defect `ordered_two_defect_seed_consistent` is proved correctly and the logic
   generalizes to the existential n-defect form — but only if the Round 22 counterexample
   concern is resolved (Finding 4 above).

4. The axiom system is CORRECT and SOUND. There is no missing axiom and no wrong
   formulation. BX11 is necessary and sufficient for temporal linearity. The sorry sites
   are genuine proof gaps, not formalization errors.

5. ALL 6 sorry sites depend on either forward_F (sites 1, 2, 3, 4) or on chain-step
   properties for Until/Since (sites 5, 6). The dependency is correctly mapped in Round 22.

**Medium confidence** (50-70%):

6. The existential version of `extended_defect_seed_consistent` is TRUE. The potential
   counterexample (Finding 2) does NOT defeat the existential form. A proof path exists
   via the BX11 fold applied to the specific sigma_list restricted case.

7. The t < 0 case of `dd_fmcs_forward_F` requires a separate argument (possibly showing
   F(ψ) ∈ bwd_chain(-t) implies G(ψ) ∈ M₀ or F(ψ) ∈ M₀ at some level) rather than
   directly reusing the forward chain argument.

**Low confidence** (under 35%):

8. The fold-order trick (processing target last) closes forward_F. Even with a correct
   implementation, Case 2 deferral persists.

9. Any approach based on the n-defect seed with FULL F-carry (not just sigma_list) is
   consistent. The f_carry counterexample from Report 11 is valid.

---

## Summary

The fundamental mathematical question is now narrowed to one specific claim:
**Is the existential version of `extended_defect_seed_consistent` true?**

The Round 22 claim (55-65%) should be revised down to 35-50% due to the concrete
potential 3-defect scenario identified above. However, initial analysis (Finding 4)
suggests the EXISTENTIAL version may still be provable because the problematic
G-formula `G((F(ψ_1)∧F(ψ_2))→¬ψ_3)` is defeated by choosing j=1 or j=2 (which
do not put both F(ψ_1) and F(ψ_2) in the same seed). This needs to be verified
with a formal proof attempt.

**Recommended immediate test**: Before committing to the full Plan v18 (15-25 hours),
try to prove or disprove `extended_defect_seed_consistent` for the 3-defect case:
```
given F(ψ₁), F(ψ₂), F(ψ₃) ∈ M, show ∃ j ∈ {1,2,3},
SetConsistent ({ψⱼ} ∪ {F(ψₖ) | k ≠ j} ∪ g_content M)
```
This is a self-contained lemma that does not require chain replacement.
If provable, it unblocks the n-defect generalization.
If a counterexample is found, we have identified the true mathematical obstacle and
must pivot to the semantic/quasimodel approach.
