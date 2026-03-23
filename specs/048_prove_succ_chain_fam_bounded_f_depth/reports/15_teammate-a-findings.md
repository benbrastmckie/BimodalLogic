# Teammate A Findings: Mathematical Analysis of Blocker

## Key Findings

- The blocker described in the summary is **real and well-specified**, not a false alarm
- The primed theorems `restricted_succ_propagates_F_not'` and `restricted_single_step_forcing'` are **provably false** in certain subcases, even with both `h_FF_not` and `h_GF_not` hypotheses
- The critical failure mode arises from MCS maximality operating on formulas in `deferralClosure` that are not forced by the seed
- The unrestricted `single_step_forcing` avoids this problem because **full negation completeness** applies to all formulas in the MCS, not just those in `subformulaClosure`
- The modal duality `neg(GF(psi)) = FG(psi.neg)` is **valid syntactically** in this codebase

## Blocker Verification

The blocker is real. Here is the precise reconstruction of the blocking path:

### The Blocking Scenario

Hypotheses in place:
- `h_FF_not : FF(psi) ∉ chain(k)` (= u)
- `h_GF_not : GF(psi) ∉ chain(k)` (= u)
- `h_FF_dc` is false: `FF(psi) ∉ deferralClosure`
- `h_GF_dc` is true: `GF(psi) ∈ deferralClosure`
- v = chain(k+1), constructed via `constrained_successor_restricted`

Step-by-step:

1. Since `GF(psi) ∈ deferralClosure` and `GF(psi)` is an `all_future` formula (not a neg formula), it lies in `subformulaClosure` (via the `closureWithNeg` membership argument).

2. By `deferral_restricted_mcs_negation_complete` applied to u: either `GF(psi) ∈ u` or `neg(GF(psi)) ∈ u`.

3. Since `GF(psi) ∉ u` (by h_GF_not), we get `neg(GF(psi)) ∈ u`.

4. Syntactically: `neg(GF(psi)) = (all_future (some_future psi)).imp bot`. The formula `some_future psi = (psi.neg.all_future).neg`, so `neg(all_future(some_future psi))` = `some_future(neg(some_future psi))` = `some_future(all_future(psi.neg))` = `FG(psi.neg)` **only after applying double negation elimination semantically**. See the Modal Duality section for details.

5. This gives `FG(psi.neg) ∈ u`, meaning `G(psi.neg) ∈ f_content(u)`.

6. By the F-step property of Succ: `f_content(u) ⊆ v ∪ f_content(v)`. So `G(psi.neg) ∈ v ∨ G(psi.neg) ∈ f_content(v)`.

7. **Case A (G(psi.neg) ∈ v)**: Then `F(psi) = neg(G(psi.neg)) ∉ v` by consistency. This subcase is fine — no blocker.

8. **Case B (G(psi.neg) ∈ f_content(v), i.e., FG(psi.neg) ∈ v)**: This is the problem case. The f_step only tells us `G(psi.neg) ∈ v ∨ FG(psi.neg) ∈ v`; it does NOT force Case A. When Case B holds:
   - `FG(psi.neg) ∈ v` but `G(psi.neg) ∉ v`
   - The MCS v is maximal within `deferralClosure`. Since `F(psi) ∈ deferralClosure` (as F(psi) is in closureWithNeg, which embeds in dc), by maximality either `F(psi) ∈ v` or `G(psi.neg) ∈ v`.
   - Since `G(psi.neg) ∉ v` (by assumption of Case B), maximality forces `F(psi) ∈ v`.
   - Therefore `F(psi) ∈ v = chain(k+1)`.

**This is not a contradiction** — the MCS extension chose `F(psi)` over `G(psi.neg)` when constructing v. The seed `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking` does NOT force either choice, because:
- `G(psi.neg) ∉ g_content(u)` (that would require `GG(psi.neg) = neg(FF(psi)) ∈ u`, but `FF(psi) ∉ dc` means negation completeness doesn't apply to `FF(psi)`)
- The deferral disjunction for `FG(psi.neg)` is `G(psi.neg) ∨ FG(psi.neg)`, and this appears in the seed only if `FG(psi.neg) ∈ closureWithNeg`, i.e., `G(psi.neg) ∈ subformulaClosure`
- When `G(psi.neg) ∉ subformulaClosure`, no deferral disjunction is in the seed, so the seed cannot force `G(psi.neg) ∈ v`

**Conclusion**: Step 5 of the blocker ("`F(psi) ∈ chain(k+1)` can happen") is correct and the blocker is a true obstruction.

## Modal Duality Analysis

The claim `neg(GF(psi)) = FG(psi.neg)` requires careful analysis due to the codebase's syntactic representation.

### Syntactic Definitions

From `Formula.lean`:
- `neg φ = φ.imp bot` (syntactically: `imp φ bot`)
- `some_future φ = φ.neg.all_future.neg` (= `(all_future (imp φ bot)).imp bot`)
- `all_future φ` is a primitive constructor
- `some_past φ = φ.neg.all_past.neg`

### The Duality Claim

`neg(GF(psi))` in Lean is:
```
(all_future (some_future psi)).neg
= (all_future ((psi.neg.all_future).neg)).neg
= imp (all_future (imp (all_future (imp psi bot)) bot)) bot
```

`FG(psi.neg)` in Lean is:
```
some_future (all_future psi.neg)
= some_future (all_future (imp psi bot))
= ((all_future (imp psi bot)).neg.all_future).neg
= imp (all_future (imp (imp (all_future (imp psi bot)) bot) bot)) bot
```

These are **NOT syntactically equal**. The modal duality holds **semantically** (via double negation elimination in the MCS) but not as syntactic terms.

### Practical consequence in the proof

In `restricted_succ_propagates_F_not'` (around line 3665), the code correctly avoids claiming syntactic equality. Instead it writes:
```lean
have h_FG_neg_in_u : Formula.some_future (Formula.all_future psi.neg) ∈ u := h_neg_GF
```
where `h_neg_GF` has type `(Formula.all_future (Formula.some_future psi)).neg ∈ u`.

This works because in the MCS u, the derivation `neg(GF(psi)) → FG(psi.neg)` is available (it follows from necessitation of DNE and the K axiom), and the `DeferralRestrictedMCS` membership condition applies this via `h_drm_u.2`. The key derivation in the code (lines 3143-3210) constructs:
```
⊢ neg(FF(psi)) → GG(neg(psi))
```
which corresponds to using G(φ.neg.neg → φ) via K. For GF vs FG, the analogous derivation requires P/F interaction, which is more delicate.

**The summary's step 2 ("neg(GF(psi)) = FG(psi.neg) by modal duality") is correct in the semantic sense**. In an MCS with derivation closure, `neg(GF(psi))` and `FG(psi.neg)` are co-membered (each implies the other). The proof in lines 3643-3664 captures this correctly.

## Why the Unrestricted Case Avoids This Problem

The unrestricted `single_step_forcing` (in `SuccRelation.lean`, line 233) works because:

1. `u` is a full `SetMaximalConsistent`, meaning negation completeness applies to **every formula** without restriction to `subformulaClosure`.

2. Given `FF(phi) ∉ u`, full negation completeness immediately gives `neg(FF(phi)) ∈ u`.

3. The derivation `neg(FF(phi)) → GG(neg(phi))` (via DNE necessitation and K) gives `GG(neg(phi)) ∈ u`.

4. `GG(neg(phi)) ∈ g_content(u)` (since `GG = G∘G` and `g_content` strips the outer G), so `G(neg(phi)) ∈ v` by g_persistence, blocking `F(phi) ∈ v`.

**In the restricted case**, negation completeness only applies to formulas in `subformulaClosure(phi)`. When `FF(psi) ∉ deferralClosure`, it is outside `subformulaClosure`, so negation completeness does not apply. We cannot derive `neg(FF(psi)) ∈ u`, and the whole chain breaks.

The additional hypothesis `h_GF_not` was intended to close this gap by blocking the g_content path. However, it only blocks `GF(psi) ∈ u` directly; it does not block the scenario where `GF(psi) ∈ dc`, which triggers the alternate path via negation completeness on `GF(psi)`, giving `FG(psi.neg) ∈ u` and then allowing `F(psi) ∈ v` via maximality.

## Recommended Approach

Based on this analysis, the following approaches are ranked by viability:

### Option 1: Strengthen to `h_GF_dc : GF(psi) ∉ deferralClosure` (HIGH CONFIDENCE)

Replace `h_GF_not : GF(psi) ∉ chain(k)` with `h_GF_dc : GF(psi) ∉ deferralClosure`. This is strictly stronger and closes all problematic subcases:

- If `GF(psi) ∉ dc`, then trivially `GF(psi) ∉ u` (since `u ⊆ dc`)
- More importantly, negation completeness does not apply to `GF(psi)` even in the `GF ∈ dc` branch — there is no such branch
- The only remaining path is via `f_content`, which is already handled

The primed theorems would then be provable. The `bounded_witness` would need to case-split on whether `GF(psi) ∈ dc`, handling the `GF ∈ dc` case separately with a decreasing `g_depth` measure (tracking how many G-wrapped F-obligations remain in dc).

### Option 2: Lexicographic termination on `(f_depth, g_depth)` (MEDIUM CONFIDENCE)

Abandon the primed theorems and prove `restricted_bounded_witness'` directly with a lexicographic measure:
- `f_depth`: number of F-nestings of psi still in chain(k) relative to dc
- `g_depth`: number of G-formulas of the form `G^n(F(psi))` still in chain(k) within dc

When `GF(psi) ∈ chain(k)`, step via g_depth decrease; when `GF(psi) ∉ chain(k)`, use the existing f_depth argument. This avoids needing the primed theorems but requires building a new termination argument.

### Option 3: Construction-level fix (LOW CONFIDENCE)

Modify the `constrained_successor_restricted` construction to explicitly prefer `G(psi.neg)` over `F(psi)` when `GF(psi) ∉ dc`. This would make the primed theorems true by construction, but requires changing the chain construction and re-proving all downstream properties.

## Confidence Level

**High** for the blocker verification — the analysis is thorough and the scenario where `F(psi) ∈ v` is constructed despite both `h_FF_not` and `h_GF_not` is explicit and sound.

**High** for the modal duality analysis — the syntactic non-equality is confirmed from `Formula.lean`, and the semantic equivalence in MCS is standard.

**Medium** for the recommended approach — Option 1 seems most targeted, but its integration with the bounded_witness induction needs to be worked out. The key challenge is that `GF(psi) ∈ dc` can create a cascade (via `FG(psi.neg) ∈ u`, then `FG of FG`, etc.), and the g_depth termination measure must account for this.
