# Research Report: G-Content Path Analysis for Boundary Case Sorries

**Task**: 48 (prove_succ_chain_fam_bounded_f_depth)  
**Focus**: Can GF(psi) be in chain(k) when FF(psi) is not in deferralClosure?  
**Session**: sess_1774306569_1740b3  
**Date**: 2026-03-23  

## Executive Summary

The g_content path IS a real threat. The theorem `restricted_succ_propagates_F_not` as currently stated is **FALSE** in the boundary case where `F(psi) ∈ deferralClosure` but `FF(psi) ∉ deferralClosure`. The theorem `restricted_single_step_forcing` has a corresponding sorry that is also unfillable with the current approach. The fix requires restructuring the proof strategy, not filling the sorries.

## Question 1: Is GF(psi) ∈ chain(k) possible when FF(psi) ∉ deferralClosure?

**Answer: YES.**

### Proof

Consider `phi = G(F(p))` for an atom `p`. The subformulaClosure of this formula is:

```
{G(F(p)), F(p), G(neg(p)), neg(p), p, bot}
```

- `GF(p) = G(F(p))` is the formula itself, so `GF(p) ∈ subformulaClosure(phi) ⊆ deferralClosure(phi)`.
- `FF(p) = F(F(p)) = some_future(some_future(p))`. This is NOT a subformula of `G(F(p))`.

Since `FF(p)` is a `some_future` formula, by `some_future_in_deferralClosure_is_in_closureWithNeg`, if `FF(p) ∈ deferralClosure(phi)` then `FF(p) ∈ closureWithNeg(phi)`. But `closureWithNeg = subformulaClosure ∪ image neg subformulaClosure`, and `FF(p)` is not in either set (it's not a subformula, and it's not the negation of a subformula since `some_future` terms are not `imp` at the outer level in the sense needed). Therefore `FF(p) ∉ deferralClosure(phi)`.

So we have:
- `GF(p) ∈ deferralClosure(phi)` -- YES
- `FF(p) ∈ deferralClosure(phi)` -- NO
- `F(p) ∈ deferralClosure(phi)` -- YES

### Consequence for chain construction

In a chain where `G(F(p)) ∈ chain(k)`:
1. By temp_4 axiom (`G(phi) -> G(G(phi))`): `GG(F(p)) ∈ chain(k)`, since `G(F(p)) ∈ chain(k)` and `G(G(F(p))) ∈ dc` (as `G(G(F(p)))` would need to be a subformula... actually, `GG(F(p))` may not be in dc if it's not a subformula of phi).

Wait, let me correct this. For `phi = G(F(p))`:
- `GG(F(p)) = G(G(F(p)))` -- is this a subformula? The subformulas of `G(F(p))` are `{G(F(p)), F(p), G(neg(p)), neg(p), p, bot}`. `G(G(F(p)))` is NOT a subformula. So `GG(F(p)) ∉ dc`.

This means `GG(F(p)) ∉ chain(k)` even though `G(F(p)) ∈ chain(k)`. So `G(F(p)) ∉ g_content(chain(k))`, and `F(p)` does NOT enter chain(k+1) via g_persistence from chain(k).

But wait -- by the temp_4 axiom in the MCS: `G(F(p)) -> G(G(F(p)))`. So if `G(F(p)) ∈ chain(k)` (an MCS), then `G(G(F(p))) ∈ chain(k)` by the axiom + modus ponens closure. But `G(G(F(p))) ∉ dc`, and `chain(k) ⊆ dc`! 

This is a CONTRADICTION. So `G(F(p)) ∉ chain(k)` for the restricted chain with `phi = G(F(p))`!

Let me re-examine this. The restricted MCS `chain(k)` satisfies `chain(k) ⊆ deferralClosure(phi)`. The temp_4 axiom says `G(F(p)) -> G(G(F(p)))` is provable. If `G(F(p)) ∈ chain(k)` then, for a FULL MCS, `G(G(F(p))) ∈ chain(k)`. But a restricted MCS is NOT a full MCS -- it's maximal WITHIN deferralClosure. So the restricted MCS doesn't necessarily contain all provable consequences, only those in deferralClosure.

So the restricted MCS can have `G(F(p)) ∈ chain(k)` without having `G(G(F(p))) ∈ chain(k)`, because `G(G(F(p))) ∉ dc`.

But is this consistent? The restricted MCS must be consistent (no finite subset derives bot). If `G(F(p)) ∈ chain(k)`, then the set `chain(k)` contains `G(F(p))`. From `G(F(p))` we can derive `G(G(F(p)))` using temp_4. But `G(G(F(p))) ∉ chain(k)`. That's fine for consistency -- `chain(k)` is just not deductively closed. It's only MAXIMALLY CONSISTENT within dc.

The consistency requirement is: no finite subset of `chain(k)` derives `bot`. The presence of `G(F(p))` without `G(G(F(p)))` doesn't cause inconsistency.

But wait, does the absence of `G(G(F(p)))` block the g_persistence propagation?

g_persistence says: `g_content(chain(k)) ⊆ chain(k+1)`. `g_content(chain(k)) = {chi | G(chi) ∈ chain(k)}`. So `F(p) ∈ g_content(chain(k))` iff `G(F(p)) ∈ chain(k)`. If `G(F(p)) ∈ chain(k)`, then `F(p) ∈ chain(k+1)` via g_persistence.

Now: does `G(F(p)) ∈ chain(k+1)`? For that, we need `G(F(p)) ∈ g_content(chain(k))`, which means `G(G(F(p))) ∈ chain(k)`. Since `G(G(F(p))) ∉ dc`, this is false. So `G(F(p)) ∉ g_content(chain(k))`, and `G(F(p))` does NOT propagate to chain(k+1) via g_persistence.

But `G(F(p)) ∈ dc`, so by negation completeness within dc: either `G(F(p)) ∈ chain(k+1)` or `F(p).neg... no, neg(G(F(p))) = F(neg(F(p)))... 

Actually, `neg(G(F(p))) = (all_future(some_future(p))).neg`. And `F(p) = neg(G(neg(p)))`, so `G(F(p)) = all_future(neg(G(neg(p)))) = all_future((imp (all_future (imp p bot)) bot))`.

`neg(G(F(p))) = G(F(p)).neg`. For negation completeness, either `G(F(p)) ∈ chain(k+1)` or `G(F(p)).neg ∈ chain(k+1)`. But `G(F(p)).neg` needs to be in dc too. Is `neg(G(F(p))) ∈ dc`?

`closureWithNeg = subformulaClosure ∪ neg(subformulaClosure)`. Since `G(F(p)) ∈ subformulaClosure(phi)`, `neg(G(F(p))) ∈ closureWithNeg(phi) ⊆ dc`. Yes.

So by negation completeness: either `G(F(p)) ∈ chain(k+1)` or `neg(G(F(p))) ∈ chain(k+1)`. If `neg(G(F(p))) ∈ chain(k+1)`, then `G(F(p)) ∉ chain(k+1)`, and the g_persistence path for F(p) into chain(k+2) is blocked.

The Lindenbaum extension decides. It could go either way. So `G(F(p))` might or might not persist.

Hmm, but this makes the analysis more nuanced. Let me think about concrete scenarios.

**Scenario A**: `G(F(p)) ∈ chain(k)` and `G(F(p)) ∈ chain(k+1)`. Then `F(p) ∈ chain(k+1)` by g_persistence (wait, `F(p) ∈ g_content(chain(k))` since `G(F(p)) ∈ chain(k)`, so `F(p) ∈ chain(k+1)` -- yes). And this could repeat: `G(F(p)) ∈ chain(k+m)` for all m, giving `F(p) ∈ chain(k+m)` for all m.

**Scenario B**: `G(F(p)) ∈ chain(k)` but `neg(G(F(p))) ∈ chain(k+1)`. Then `G(F(p)) ∉ chain(k+1)`.

In Scenario A, `F(p)` persists indefinitely. For `restricted_succ_propagates_F_not`, the claim `F(p) ∉ chain(k+1)` is FALSE.

So the question is: can Scenario A actually occur? The chain construction is deterministic (not non-deterministic Lindenbaum). Let me check what the restricted Lindenbaum does.

Actually, I realize the chain construction IS deterministic -- it uses a specific enumeration for Lindenbaum. Whether `G(F(p))` enters chain(k+1) depends on this enumeration. But the theorem `restricted_succ_propagates_F_not` claims `F(psi) ∉ chain(k+1)` for ALL chains, not specific ones. So if there EXISTS a chain where `F(psi) ∈ chain(k+1)`, the theorem is false.

And as I showed, Scenario A is consistent (no logical contradiction), so the Lindenbaum construction CAN produce it.

OK, I'm now confident the theorem is false. Let me write the complete report.

<function_calls>
<invoke name="Bash">
<parameter name="command">cat > /home/benjamin/Projects/ProofChecker/specs/048_prove_succ_chain_fam_bounded_f_depth/reports/10_g-content-path.md << 'REPORTEOF'
# Research Report: G-Content Path Analysis for Boundary Case Sorries

**Task**: 48 (prove_succ_chain_fam_bounded_f_depth)  
**Focus**: Can GF(psi) be in chain(k) when FF(psi) is not in deferralClosure?  
**Session**: sess_1774306569_1740b3  
**Date**: 2026-03-23  

## Executive Summary

The g_content path IS a real threat. The theorem `restricted_succ_propagates_F_not` (line 3236 sorry) as currently stated is **provably false** in the boundary case. Similarly, `restricted_single_step_forcing` (line 3077 sorry) cannot be filled with the current approach. However, the ULTIMATE goal (`restricted_forward_chain_forward_F`) may still be provable via a restructured proof that bypasses these false intermediate lemmas.

## Question 1: Can GF(psi) be in deferralClosure when FF(psi) is NOT?

**Answer: YES.** This is a genuine boundary case that arises for natural formulas.

### Concrete Example

Let `phi = G(F(p))` (= `all_future(some_future(p))`) for atom `p`.

The subformulaClosure of phi contains exactly:
```
G(F(p)), F(p), G(neg(p)), neg(p), p, bot
```

- `GF(p) = G(F(p)) = phi` itself, so `GF(p) IN subformulaClosure(phi) SUBSET deferralClosure(phi)`.
- `F(p) IN subformulaClosure(phi) SUBSET deferralClosure(phi)`.
- `FF(p) = F(F(p))` is NOT a subformula of `G(F(p))`. Since `FF(p)` is a `some_future` formula, by `some_future_in_deferralClosure_is_in_closureWithNeg`, `FF(p) IN deferralClosure` would imply `FF(p) IN closureWithNeg`. But `FF(p)` is not in `subformulaClosure(phi)` and not the negation of any subformula. So `FF(p) NOT IN deferralClosure(phi)`.

### Why This Matters

If `G(F(psi)) IN chain(k)`, then by g_persistence (`g_content(chain(k)) SUBSET chain(k+1)`), we get `F(psi) IN chain(k+1)`. This means:

1. **`restricted_succ_propagates_F_not` is FALSE**: It claims `F(psi) NOT IN chain(k+1)` given only `FF(psi) NOT IN chain(k)`, but g_persistence injects `F(psi)` into chain(k+1).

2. **`restricted_single_step_forcing` cannot be proven**: It assumes `F(psi) NOT IN chain(k+1)` to force `psi IN chain(k+1)`, but the f_step disjunction `psi IN chain(k+1) OR F(psi) IN chain(k+1)` cannot be resolved when the second disjunct holds.

## Question 2: How Does Succ Propagate Formulas via g_content vs f_content?

### Definitions (from TemporalContent.lean and SuccRelation.lean)

```
g_content(M) = {phi | G(phi) IN M}     -- formulas under G
f_content(M) = {phi | F(phi) IN M}     -- formulas under F

Succ(u, v) iff:
  (1) g_content(u) SUBSET v             -- G-persistence
  (2) f_content(u) SUBSET v UNION f_content(v)  -- F-step
```

### Propagation Paths for F(psi) into chain(k+1)

F(psi) can enter chain(k+1) via THREE paths:

1. **f_content path**: `FF(psi) IN chain(k)` implies `F(psi) IN chain(k+1) OR FF(psi) IN chain(k+1)` by f_step. BLOCKED when `FF(psi) NOT IN dc`.

2. **g_content path**: `G(F(psi)) IN chain(k)` implies `F(psi) IN chain(k+1)` by g_persistence. ACTIVE when `G(F(psi)) IN dc` (which is independent of whether `FF(psi) IN dc`).

3. **Lindenbaum extension**: F(psi) is added during maximality if consistent with seed. UNPREDICTABLE (depends on enumeration order).

### Why the Unrestricted Case Works

In the unrestricted `single_step_forcing` (SuccRelation.lean:233):
- Step 1: `FF(psi) NOT IN u` implies `neg(FF(psi)) IN u` by FULL negation completeness.
- Step 2: `neg(FF(psi))` derives `GG(neg(psi))` by `neg_FF_implies_GG_neg_in_mcs`.
- Step 3: `GG(neg(psi)) IN u` gives `G(neg(psi)) IN g_content(u)`.
- Step 4: `G(neg(psi)) IN v` by g_persistence.
- Step 5: `G(neg(psi)) IN v` implies `F(psi) NOT IN v` (they are negations: `F(psi) = neg(G(neg(psi)))`).
- Step 6: `psi IN v UNION f_content(v)` and `F(psi) NOT IN v` gives `psi IN v`.

This argument relies on UNRESTRICTED negation completeness at Step 1. The restricted MCS cannot derive `neg(FF(psi))` when `FF(psi) NOT IN dc`.

## Question 3: Analysis of Sorry at Line 3077 (restricted_single_step_forcing)

### Goal State
```
case neg.inr
F(psi) IN chain(k), FF(psi) NOT IN chain(k), FF(psi) NOT IN dc, F(psi) IN dc
psi IN f_content(chain(k+1))   -- i.e., F(psi) IN chain(k+1)
GOAL: psi IN chain(k+1)
```

### Analysis

The proof gets stuck because:
- `psi IN chain(k+1) OR F(psi) IN chain(k+1)` by f_step (already derived as `h_union`).
- The case split lands in `psi IN f_content(v)`, meaning `F(psi) IN chain(k+1)`.
- To conclude `psi IN chain(k+1)`, we need to rule out `F(psi) IN chain(k+1)`.
- We CANNOT rule this out because `G(F(psi))` might be in chain(k), propagating `F(psi)` to chain(k+1).

**Verdict**: This sorry is UNFILLABLE with the current proof structure. The lemma is asking to derive `psi IN chain(k+1)` from premises that don't guarantee it.

## Question 4: Analysis of Sorry at Line 3236 (restricted_succ_propagates_F_not)

### Goal State
```
case pos
FF(psi) NOT IN chain(k), FF(psi) NOT IN dc, F(psi) IN dc
GOAL: F(psi) NOT IN chain(k+1)
```

### Analysis

This theorem claims `F(psi) NOT IN chain(k+1)` given only `FF(psi) NOT IN chain(k)`. As shown:
- If `G(F(psi)) IN chain(k)`, then `F(psi) IN chain(k+1)` by g_persistence, making the claim false.
- `G(F(psi)) IN chain(k)` is consistent with all hypotheses when `G(F(psi)) IN dc`.

**Verdict**: This theorem is **FALSE as stated**. A counterexample exists when `phi` contains `G(F(psi))` as a subformula.

## Question 5: Structure of deferralClosure

### Definition
```
deferralClosure(phi) = closureWithNeg(phi) UNION deferralDisjunctionSet(phi) UNION backwardDeferralSet(phi)
closureWithNeg(phi) = subformulaClosure(phi) UNION image(neg, subformulaClosure(phi))
deferralDisjunctionSet(phi) = image(toFutureDeferral, filter(IsFutureFormula, closureWithNeg(phi)))
```

### Key Properties

1. **NOT subformula-closed in the traditional sense**: deferralClosure adds deferral disjunctions (`chi OR F(chi)`) and negations, but does NOT add arbitrary superformulas.

2. **G and F formulas are independent**: `G(F(psi)) IN dc` does NOT imply `F(F(psi)) IN dc`. They correspond to different formula constructors (`all_future` vs iterated `some_future`).

3. **G-formulas in dc are in closureWithNeg**: By `all_future_in_deferralClosure_is_in_closureWithNeg`, any `G(chi) IN dc` must be in `closureWithNeg`, and since `G(chi) = all_future(chi)` is not a `neg` image, it must be in `subformulaClosure`.

4. **F-formulas in dc are in closureWithNeg**: By `some_future_in_deferralClosure_is_in_closureWithNeg`, similarly verified via f_nesting_depth argument.

5. **The boundary case**: `F(psi) IN dc AND FF(psi) NOT IN dc` occurs precisely when `F(psi)` is a subformula of phi but `F(F(psi))` is not. This is common -- e.g., for `phi = G(F(p))`.

## Proof Strategy Recommendations

### Option A: Restructure bounded_witness to handle g_content persistence

Replace the current approach (decrease F-depth by 1 at each step) with a two-phase argument:

**Phase 1**: Track g_content persistence depth. Define `g_depth(chi, phi)` = max n such that `G^n(chi) IN subformulaClosure(phi)`. Since subformulaClosure is finite, g_depth is bounded.

**Phase 2**: For each step where `F(psi)` persists via g_content, `G(F(psi))` must be in chain(k). But `G(G(F(psi)))` might not be in dc, so `G(F(psi))` itself might not persist. Use a LEXICOGRAPHIC termination measure: (g_depth of current G-formula, chain position).

**Difficulty**: HIGH. Requires significant restructuring of the bounded_witness induction.

### Option B: Prove restricted_forward_chain_forward_F by contradiction using finiteness

Since deferralClosure is finite, the chain is eventually periodic (pigeonhole on `2^|dc|` possible states). If `F(psi)` persists forever but `psi` never appears, derive a contradiction:

1. `F(psi) IN chain(m)` and `neg(psi) IN chain(m)` for all m in the periodic part.
2. By seriality axiom `G(phi) -> F(phi)`: `G(neg(psi)) IN chain(m)` would give `F(neg(psi)) IN chain(m)`.
3. Actually, `G(neg(psi))` and `F(psi)` are negations, so both can't be in the same MCS.
4. Since `F(psi) IN chain(m)`, `G(neg(psi)) NOT IN chain(m)`.
5. By negation completeness on `G(neg(psi))` (which IS in dc): `neg(G(neg(psi))) = F(psi) IN chain(m)` -- tautological.

This approach gets STUCK because individual MCS consistency of `neg(psi) AND F(psi)` is not contradictory. The contradiction only arises at the MODEL level (the chain as a whole can't satisfy F-coherence while deferring forever), but we can't access model-theoretic arguments inside the proof.

**Difficulty**: VERY HIGH. May require introducing new infrastructure (e.g., omega-model construction).

### Option C: Modify the chain construction to force F-resolution (RECOMMENDED)

Instead of using unrestricted Lindenbaum for the restricted successor, use a **priority-based** or **fair** extension that ensures F-obligations are eventually resolved.

Concretely: When building chain(k+1) from the seed, if `F(psi) IN chain(k)` and `psi IN dc`, prioritize adding `psi` over `neg(psi)` in the Lindenbaum enumeration. This ensures `psi` enters chain(k+1) whenever consistent.

The claim `psi IN chain(k+1)` then follows from:
1. The seed is consistent.
2. `psi` is consistent with the seed (since `F(psi) IN chain(k)` and the deferral disjunction `psi OR F(psi)` is provable).
3. The fair extension adds `psi` before `neg(psi)`.

**Difficulty**: MEDIUM. Requires modifying `constrained_successor_seed_restricted` to include a "resolution" component, and proving the modified seed is still consistent.

**Key insight**: Instead of adding `psi` directly to the seed, add the deferral disjunction `psi OR F(psi)` to the seed (which is already done -- it's in `deferralDisjunctions`). Then show that in the case where `FF(psi) NOT IN dc`, the Lindenbaum extension resolves this disjunction to `psi` (not `F(psi)`) because maintaining `F(psi)` without the ability to defer further would require G-propagation.

Actually, the deferral disjunction `psi OR F(psi)` is already in the seed. The issue is that the MCS might choose the `F(psi)` disjunct. We need to show it chooses `psi`.

### Option D: Strengthen the theorem hypotheses (SIMPLEST FIX)

Modify `restricted_succ_propagates_F_not` and `restricted_single_step_forcing` to add the hypothesis `G(F(psi)) NOT IN chain(k)`. This blocks the g_content path.

Then prove `restricted_bounded_witness` with an additional case analysis: when `G(F(psi)) IN chain(k)` at the boundary, handle it separately by showing `G(F(psi))` cannot persist forever (using the finite g_depth argument).

**Theorem modification**:
```lean
theorem restricted_succ_propagates_F_not (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_FF_not : FF(psi) NOT IN chain(k))
    (h_GF_not : G(F(psi)) NOT IN chain(k))  -- NEW HYPOTHESIS
    : F(psi) NOT IN chain(k+1)
```

Then in `restricted_bounded_witness`, handle the case `G(F(psi)) IN chain(k)` separately, tracking g_depth decrease.

**Difficulty**: MEDIUM-LOW. The existing proofs for the non-boundary case remain intact. Only the boundary case handling changes.

## Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- sorry locations at lines 3077 and 3236
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- Succ definition, unrestricted single_step_forcing
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/SubformulaClosure.lean` -- deferralClosure, closureWithNeg, subformulaClosure definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- g_content, f_content definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` -- axiom definitions (temp_4, seriality, etc.)

## Critical Correctness Note

The g_content path persistence depends on whether `G^n(F(psi))` stays within deferralClosure. Since deferralClosure is finite and only contains subformulas and their negations, the chain of G-prefixes `G(F(psi)), G(G(F(psi))), G(G(G(F(psi)))), ...` must eventually leave dc. At that point, the g_content propagation chain breaks.

However, the SINGLE step `G(F(psi)) IN chain(k)` is already sufficient to inject `F(psi)` into chain(k+1), making `restricted_succ_propagates_F_not` false as stated.

The fix must either:
1. Add hypotheses to block the g_content path, OR
2. Restructure the induction to account for g_content persistence, OR
3. Modify the chain construction to prevent the problematic scenario.

Option D (strengthen hypotheses) is recommended as the path of least resistance.
