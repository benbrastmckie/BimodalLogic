# Research Report: Derivability Blocker Analysis

**Task**: 48 (prove_succ_chain_fam_bounded_f_depth)
**Date**: 2026-03-23
**Session**: sess_1774310298_3c1a2d
**Focus**: Mathematically rigorous analysis of augmented_seed_consistent blocker

## Executive Summary

The blocker in `augmented_seed_consistent` (line 1973 of SuccChainFMCS.lean) stems from a fundamental gap: the proof shows `chi.neg not IN old_seed` but needs `chi.neg NOT DERIVABLE FROM old_seed`. Since `old_seed subset u` (an MCS), derivability would imply membership in u. The key finding is that **chi.neg CAN be in u** while satisfying all boundary_resolution_set conditions. This makes the current consistency proof strategy incomplete.

**Recommended Solution**: The most viable approach is to strengthen the boundary_resolution_set definition to require `chi is in u`. This guarantees non-derivability of chi.neg (since u is consistent). For cases where `chi not in u` (implying `chi.neg in u`), the F-obligation F(chi) is legitimately deferred - the successor will satisfy chi, not u.

## Problem Analysis

### What the Proof Currently Shows

The existing lemmas establish that `chi.neg` is not directly in any component of `old_seed`:

1. **neg_not_in_g_content_when_F_in**: Shows `chi.neg not in g_content(u)` because `G(chi.neg) = neg(F(chi))` and having both `F(chi)` and `neg(F(chi))` in u violates consistency.

2. **neg_not_in_deferralDisjunctions**: Shows `chi.neg not in deferralDisjunctions` because deferral disjunctions have the form `psi OR F(psi)` (an OR formula), while `chi.neg = chi.imp bot` (an IMP formula) - different constructors.

3. **neg_not_in_p_step_blocking_restricted**: Shows `chi.neg not in p_step_blocking_formulas_restricted` because blocking formulas have form `H(neg xi)` (an ALL_PAST formula), while `chi.neg` is an IMP formula.

4. **neg_not_in_constrained_successor_seed_restricted**: Combines the above to conclude `chi.neg not in old_seed`.

### What the Proof NEEDS But Does NOT Show

The proof of `augmented_seed_consistent` requires:

```
SetConsistent (old_seed union {chi})
```

By the contrapositive of `context_not_derivable_implies_extended_consistent`, this requires showing:

```
old_seed does NOT derive chi.neg
```

The current proof shows `chi.neg not in old_seed` (direct membership), but this is **strictly weaker** than non-derivability.

### Why Derivability Matters

For any MCS u with `old_seed subset u`:
- If `old_seed derives chi.neg`, then `chi.neg is in u` (by SetMaximalConsistent.closed_under_derivation)
- Adding chi to old_seed creates an inconsistent set (chi and chi.neg derive bot)

### The Gap: chi.neg COULD Be in u

Consider chi in boundary_resolution_set(phi, u). The conditions are:
1. `F(chi) is in u`
2. `FF(chi) is NOT in deferralClosure`
3. `GF(chi) is NOT in u`

**Critically**, these conditions do NOT exclude `chi.neg is in u`. Let me verify:

- `F(chi) = neg(G(chi.neg))`. So `F(chi) is in u` means `neg(G(chi.neg)) is in u`.
- By consistency of u: `G(chi.neg) is NOT in u`.
- But `chi.neg not in u` does NOT follow from `G(chi.neg) not in u`!
- The T axiom gives `G(phi) -> phi`, so `G(chi.neg) is in u` would imply `chi.neg is in u`.
- But the converse (chi.neg in u implies G(chi.neg) in u) is FALSE in general.

**Example scenario where chi.neg is in u**:
- chi = p (atomic proposition)
- u contains: p.neg (i.e., not-p), F(p) = neg(G(p.neg))
- u does NOT contain: G(p.neg) (consistent with F(p) = neg(G(p.neg)) in u)
- This is consistent: "p is false now, but there exists a future where p is true"

So chi.neg being in u is perfectly compatible with the boundary_resolution_set conditions!

### Why Modal Axioms Cannot Help

The comments in the code (lines 1927-1935) explore whether modal axioms could derive chi.neg from old_seed:

**T axiom analysis**: `G(chi.neg) -> chi.neg`
- If `G(chi.neg) is in old_seed`, then chi.neg is derivable.
- `G(chi.neg) is in g_content(u)` iff `GG(chi.neg) is in u`.
- `GG(chi.neg) = G(G(chi.neg))` - a deeply nested formula.
- Whether `GG(chi.neg) is in u` depends on the specific structure of phi and u.

The code recognizes (line 1904-1911) that chi.neg might be derivable from old_seed, which would make the augmented seed inconsistent.

## Solution Analysis

### Option 1: Strengthen boundary_resolution_set to Require chi in u

**Definition change**:
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         chi ∈ u ∧  -- NEW CONDITION
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}
```

**Why this works**:
- If `chi is in u`, then `chi.neg is NOT in u` (by MCS negation exclusion: SetMaximalConsistent.neg_excludes)
- Since `old_seed subset u` and `chi.neg is not in u`, old_seed cannot derive chi.neg
- Therefore `old_seed union {chi}` is consistent (as old_seed union {chi} subset u which is consistent)

**Impact on bounded_witness**:
- This restricts boundary_resolution_set to cases where chi is ALREADY resolved in u
- The remaining unresolved cases (chi not in u, chi.neg in u) need different handling
- But wait: if chi.neg is in u and F(chi) is in u, what is the semantic meaning?
  - "chi is false now, but chi will be true in some future" - this is the essence of F(chi)!
  - The successor should satisfy chi (from F(chi)), even if u has chi.neg
  - So we should NOT require chi in u; we SHOULD include chi in seed even when chi.neg in u

### Option 2: Semantic Consistency Argument

Instead of syntactic derivability analysis, use a semantic argument:

**Claim**: old_seed union boundary_resolution_set has a model.

**Proof sketch**:
- u is an MCS, hence has a model M where world w satisfies u
- F(chi) in u means some successor w' satisfies chi
- old_seed = g_content(u) union deferralDisjunctions union p_step_blocking
- All formulas in old_seed are satisfied at w' (need to verify each component)
- chi is satisfied at w' (by definition of F(chi))
- Therefore old_seed union {chi} is satisfiable, hence consistent

**The verification needed**:
1. g_content(u) at w': If G(psi) in u, then psi is true at all successors including w'. CHECK.
2. deferralDisjunctions at w': psi OR F(psi) where F(psi) in u. Either psi or F(psi) true at w'. NEED TO VERIFY.
3. p_step_blocking at w': H(neg xi) where P(xi) not in u and xi not in u. Need H(neg xi) true at w', i.e., all past times have neg(xi) true. But w' is a FUTURE of w. UNCLEAR.

The p_step_blocking case is problematic: H(neg xi) at w' means all times before w' satisfy neg(xi). This includes times between w and w', which we don't control.

### Option 3: Direct Derivation Replacement (F(chi) Substitution)

**Idea**: If L subset (old_seed union {chi}) derives bot, replace chi with F(chi) using the deferral disjunction chi OR F(chi) in old_seed.

**Formalization**:
- L derives bot with chi as an assumption
- By propositional reasoning with chi OR F(chi) in old_seed:
  - Case chi: original derivation gives bot
  - Case F(chi): we need L\{chi} union {F(chi)} to also derive bot
- If both cases derive bot, then old_seed (without chi) derives bot
- But old_seed is consistent (subset of u)
- So we need to show: if chi-case derives bot, the F(chi)-case does NOT derive bot

This approach has a flaw: the derivation might use chi essentially (not just as an assumption), making the F(chi) substitution invalid. We need the derivation to be "modular" in its use of chi.

### Option 4: Induction on brs Elements in L

The code attempts this at lines 1728-1768 but recognizes it's "getting too complex".

**Structure**:
- If L subset (old_seed union brs) derives bot
- If L intersect brs is empty, then L subset old_seed, contradicting old_seed consistency
- If L intersect brs is non-empty, pick chi in L intersect brs
- For each chi: replace with F(chi) using disjunction
- Eventually get derivation from old_seed union {F(chi_1), ..., F(chi_n)}
- But F(chi_i) in u for each chi_i in brs
- And old_seed subset u
- So L' = old_seed union {F(chi_i)} subset u
- L' derives bot contradicts u consistency

**Why this should work**: The key is that we're not substituting within a single derivation, but constructing a new derivation. The disjunction chi OR F(chi) in old_seed allows us to do case analysis. In the chi-case, we use the original derivation. In the F(chi)-case, we need to construct a new derivation - but we can just note that F(chi) in u, so if the F(chi)-case leads to inconsistency, u would be inconsistent.

**Formal statement**: For any finite L subset (old_seed union brs), if L derives bot, then there exists L' subset u such that L' derives bot.

**Proof by strong induction on |L intersect brs|**:
- Base case: |L intersect brs| = 0. Then L subset old_seed subset u. Take L' = L.
- Inductive case: |L intersect brs| = k+1. Pick chi in L intersect brs.
  - chi OR F(chi) in old_seed
  - L = L'' union {chi} where chi not in L''
  - Case 1: L'' derives chi.neg. Then L'' derives chi.neg, and with chi OR F(chi), derives F(chi). So L'' union {F(chi)} derives F(chi) and chi.neg, hence derives bot (since F(chi) = neg(G(chi.neg)) and... wait, this doesn't give bot directly).

Actually, the issue is that F(chi) and chi.neg do NOT give a contradiction directly. They are different formulas: F(chi) = neg(G(chi.neg)) and chi.neg. We have chi.neg but not G(chi.neg), so F(chi) = neg(G(chi.neg)) is consistent with chi.neg.

**This is why the substitution argument fails**: chi and F(chi) are not interchangeable from a consistency perspective. Having chi and chi.neg gives bot. Having F(chi) and chi.neg does NOT give bot.

## Recommended Approach

After this analysis, **Option 2 (semantic argument)** is the cleanest approach, but it requires careful handling of p_step_blocking formulas.

However, a more pragmatic approach exists:

### Practical Solution: Split the Proof

**Key insight**: The augmented seed can be shown consistent by showing it's a subset of a larger consistent set.

Define:
```lean
def resolution_extension (phi : Formula) (u : Set Formula) : Set Formula :=
  u ∪ boundary_resolution_set phi u
```

**Claim**: `resolution_extension phi u` is consistent when u is a DeferralRestrictedMCS.

**Proof**:
- For each chi in boundary_resolution_set: F(chi) in u
- By negation completeness in deferralClosure: either chi in u or chi.neg in u
- Case chi in u: resolution_extension adds chi which is already in u. No change.
- Case chi.neg in u: resolution_extension adds chi to u union {chi.neg}. This is INCONSISTENT.

Wait, this shows resolution_extension is NOT always consistent!

### Revised Understanding

The boundary_resolution_set contains chi where:
1. F(chi) in u
2. FF(chi) not in dc
3. GF(chi) not in u

These conditions do NOT guarantee chi in u. In fact, chi.neg might be in u, making the augmented seed inconsistent.

**This is a fundamental obstruction**: If chi.neg is in u, we CANNOT add chi to the seed without breaking consistency.

### Final Recommendation: Modify the Construction

The only viable solution is to **restrict boundary_resolution_set to chi where chi is in u**:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         chi ∈ u ∧  -- REQUIRED for consistency
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}
```

For chi where chi.neg is in u:
- F(chi) in u means the F-obligation defers to a successor
- chi.neg in u means chi is false at u
- At the successor, chi must be true (from F(chi))
- But this is handled by the normal deferral mechanism: chi OR F(chi) in seed
- The Lindenbaum extension will (by maximality) resolve chi OR F(chi) to chi in the successor
- Because in the successor, chi.neg is NOT forced (it's not in g_content(u))

**Wait**: The issue was precisely that Lindenbaum might NOT choose chi - it might choose F(chi). But F(chi) at successor means FF(chi) was in the original closure. Since FF(chi) not in dc, F(chi) at successor is not even in dc!

So when FF(chi) not in dc:
- F(chi) not in dc (since F(chi) in dc would require FF(chi) in dc by the deferral construction)
- So F(chi) cannot be in the successor (which is within dc)
- Therefore chi OR F(chi) must resolve to chi

**This is the missing argument**: When FF(chi) not in dc, the deferral disjunction chi OR F(chi) MUST resolve to chi because F(chi) is not available in the restricted closure!

## CORRECTION: Initial "Corrected Solution" Was Wrong

The initial analysis suggested that FF(chi) not in dc would imply F(chi) not in dc. **This is FALSE.**

**Counterexample**: Let phi = F(p). Then:
- F(p) is in subformulaClosure (it's phi itself)
- F(p) is in closureWithNeg
- F(p) is in deferralClosure
- But FF(p) = F(F(p)) is NOT in subformulaClosure (F(p) doesn't contain FF(p))
- So FF(p) is NOT in deferralClosure

Therefore F(chi) CAN be in deferralClosure even when FF(chi) is NOT.

## Corrected Final Analysis

Since F(chi) can be in dc when FF(chi) is not, the deferral disjunction `chi OR F(chi)` does NOT automatically resolve to chi. The Lindenbaum extension CAN choose F(chi).

**This means boundary_resolution_set IS necessary** - we cannot rely on the standard deferral mechanism alone.

The question returns to: how do we prove `augmented_seed_consistent` with boundary_resolution_set?

## Final Recommendation

The most mathematically sound approach is:

### Option A: Restrict boundary_resolution_set to chi in u

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         chi ∈ u ∧  -- NEW: Only include chi when it's already in u
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}
```

**Pros**:
- Trivially consistent: augmented_seed subset u, and u is consistent
- Eliminates the derivability question entirely

**Cons**:
- What happens when chi.neg in u? Then F(chi) remains unresolved at u.
- The successor will need to satisfy F(chi) via some other mechanism.

### Option B: Semantic/Model-theoretic Argument

Show that if u has a model M at world w, then old_seed union {chi} has a model M at successor w' (where F(chi) is witnessed).

This requires careful analysis of each component of old_seed at w'.

### Option C: Induction on |L intersect brs|

Prove consistency by showing any inconsistent L subset (old_seed union brs) can be transformed to an inconsistent L' subset u (contradicting u's consistency). This is the approach sketched in lines 1730-1768 but requires formalizing the disjunction replacement argument.

## Conclusion

The `augmented_seed_consistent` blocker is genuine and mathematically non-trivial. The key insight is that **chi.neg could be in u**, which makes the augmented seed potentially inconsistent.

**Recommended path forward**:
1. Try Option A (restrict to chi in u) - simplest if it suffices for bounded_witness
2. If Option A is insufficient, implement Option C (induction on brs elements)
3. Option B (semantic) is theoretically cleanest but hardest to formalize

The next step should verify whether Option A's restriction affects the bounded_witness proof - specifically, does bounded_witness require chi not in u for some boundary case?

## Files Referenced

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 1569-1973)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (lines 316-350)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MCSProperties.lean` (SetMaximalConsistent lemmas)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` (SetConsistent definition)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Construction.lean` (context_not_derivable_implies_extended_consistent)
