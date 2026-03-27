# Research Findings: Disjunctive Reasoning for Multi-BRS Consistency

**Task**: 58 - wire_completeness_to_frame_conditions
**Date**: 2026-03-27
**Investigator**: Teammate D (Disjunctive Reasoning)
**Focus**: Can we use `psi v F(psi)` to avoid needing psi directly in the seed?

---

## Executive Summary

Disjunctive reasoning **CAN** provide a viable path to proving seed consistency, but with important caveats. The key insight is that we can use the `or_elim_neg_neg` lemma to perform case analysis on derivations. However, the approach requires proving **both branches** derive bot, which creates a recursive structure.

**Confidence Level**: Medium-High (65%)

**Recommendation**: The disjunctive reasoning approach should be combined with the G-wrapping technique from Phase 1 to create a complete proof strategy.

---

## Key Findings

### 1. The Disjunction Property

For each BRS element psi:
- `F(psi) in u` (BRS membership condition)
- `psi v F(psi) in u` (proven: `deferralDisjunctions_subset_deferral_restricted_mcs`)
- `psi notin u` (BRS definition)
- Therefore `psi.neg in u` (by DRM maximality)

**Critical observation**: The disjunction `psi v F(psi) = psi.neg -> F(psi)` is definitionally an implication.

### 2. The Disjunctive Cut Principle

**Lemma** (sketch): If `L u {psi} derives bot` and `L u {F(psi)} derives bot`, then `L u {psi v F(psi)} derives bot`.

**Proof**: The codebase has `or_elim_neg_neg` (Propositional.lean:1686):

```lean
noncomputable def or_elim_neg_neg (Gamma : Context) (A B : Formula)
    (h_or : Gamma derives A.or B)
    (h_neg_A : Gamma derives A.neg)
    (h_neg_B : Gamma derives B.neg) :
    Gamma derives Formula.bot
```

By applying deduction theorem to each branch:
- From `L u {psi} derives bot`, get `L derives psi.neg`
- From `L u {F(psi)} derives bot`, get `L derives F(psi).neg`

Then `or_elim_neg_neg` gives us `L u {psi v F(psi)} derives bot`.

Since `psi v F(psi) in u`, we get `L' subset u` with `L' derives bot`, contradicting u's consistency.

### 3. The Problem: Second Branch is Not Free

For the disjunctive cut to work, we need BOTH branches:
- Branch 1: `L u {psi} derives bot` -- this is our hypothesis from the inconsistency assumption
- Branch 2: `L u {F(psi)} derives bot` -- THIS IS NOT AUTOMATIC

**Why Branch 2 is problematic**:
- F(psi) is NOT in the seed in general (only psi is in BRS)
- We cannot assume a derivation from `L u {F(psi)}` exists

**However**, there is a saving observation:

### 4. The F(psi) Branch Analysis

**Case A: F(psi) in seed (in non-BRS part)**

If F(psi) in g_content(u) u deferralDisjunctions(u) u p_step_blocking_restricted(u):
- Then F(psi) in u
- This is TRUE: F(psi) in u by BRS membership
- But wait: is F(psi) in one of these specific seed components?
  - F(psi) in g_content(u) iff G(F(psi)) in u -- not guaranteed
  - F(psi) in deferralDisjunctions(u) iff F(psi) = chi v F(chi) for some chi with F(chi) in u -- only if psi has specific form
  - F(psi) in p_step_blocking_restricted(u) -- structural constraint

**Key insight**: F(psi) is NOT necessarily in the seed! It's in u, but the seed is a specific subset of u plus BRS.

**Case B: L u {F(psi)} subset u (without F(psi) in seed)**

If the derivation `L u {psi} derives bot` can be transformed so that after removing psi, the remaining L_rest subset u:
- Then `L_rest u {F(psi)}` might be inconsistent IF `F(psi) in L_rest` or if we can derive something from F(psi)

**This is the core difficulty**: We need to show that replacing psi with F(psi) in the derivation still produces bot.

### 5. The Deferral Substitution Insight

**Key question**: Can we replace psi with `psi v F(psi)` in a derivation?

Syntactically, NO -- derivation substitution is invalid in Hilbert systems.

However, we can reason about WHAT the derivation proves:

**Scenario**: Suppose `L_rest u {psi} derives bot` where `L_rest subset u`.

By deduction theorem: `L_rest derives psi.neg`

Now, we also have `psi v F(psi) in u` (deferralDisjunction in u).

**Composition**:
- `L_rest derives psi.neg` (from deduction theorem)
- `u` contains `psi.neg -> F(psi)` (since psi v F(psi) = psi.neg -> F(psi))
- So if `psi.neg -> F(psi)` is in L_rest (or derivable from L_rest), then `L_rest derives F(psi)`

BUT: F(psi) in u already, and we're NOT trying to derive F(psi) -- we're trying to get bot!

### 6. The Recursive Structure

The correct approach is **strong induction on the number of BRS elements in L**:

**Base case (k=0)**: L contains no BRS elements, so L subset u. If L derives bot, this contradicts u's consistency.

**Inductive case (k=n+1)**: L contains n+1 BRS elements. Pick one, call it psi.

We want to show L cannot derive bot. Suppose it does.

**Attempt to apply disjunctive cut**:
- Branch 1: `L derives bot` (given)
- Branch 2: Need `(L \ {psi}) u {F(psi)} derives bot` -- NOT given

**The gap**: We cannot freely assume Branch 2 holds.

### 7. Alternative: The psi.neg Substitution

Instead of replacing psi with F(psi), replace psi with psi.neg:

**Observation**: For each BRS element psi in L:
- psi.neg in u (by DRM maximality)
- psi.neg notin seed (by `neg_not_in_seed_when_in_brs`)

**Construction**: Let L' = (L \ BRS_elements) u {psi_i.neg : psi_i in L inter BRS}

Then L' subset u.

**Goal**: Show that if L derives bot, then L' derives bot.

**Approach via proof transformation**:

If the original derivation `L derives bot` uses psi in a specific way, we can potentially replace occurrences of psi with reasoning about psi.neg.

**The challenge**: Derivations in Hilbert systems are NOT easily transformed. We cannot just swap psi for psi.neg.

### 8. The G-Wrapping + Disjunction Combination

**Insight from Phase 1**: The `single_brs_element_with_g_content_consistent` theorem uses G-wrapping:

From `L subset g_content(u) u {psi}` with `L derives bot`:
1. By deduction: `L \ {psi} derives psi.neg`
2. G-wrap: `G(L \ {psi}) derives G(psi.neg)`
3. Since G(L \ {psi}) subset u and G(psi.neg) in deferralClosure: `G(psi.neg) in u`
4. But `F(psi) = neg(G(psi.neg)) in u` -- contradiction!

**Can we extend this to multiple BRS elements?**

YES, with careful induction:

For each BRS element psi_i:
- If we can show that `g_content(u) u {psi_1, ..., psi_k} derives bot` implies a contradiction
- Then by induction on k, the full set is consistent

**The Multi-BRS G-Wrapping Argument**:

Suppose `L subset g_content(u) u BRS` with `L derives bot`.

Let psi_1, ..., psi_k be the BRS elements in L.

Apply the G-wrapping argument to psi_1 first:
- If psi_1 notin L, remove it (still in the set we care about)
- If psi_1 in L, apply deduction theorem: `L \ {psi_1} derives psi_1.neg`

Now `L \ {psi_1}` might still contain BRS elements psi_2, ..., psi_k.

**Key**: The derivation `L \ {psi_1} derives psi_1.neg` involves at most k-1 BRS elements.

By induction hypothesis (if `L' derives phi` and L' has < k BRS elements, then...?), we need to be careful.

The actual induction should be on the CONCLUSION being bot:
- If L with k BRS elements derives bot, then apply G-wrapping to one element
- Get a derivation involving k-1 BRS elements that derives G(psi.neg)
- Use DRM closure to show G(psi.neg) in u, contradicting F(psi) in u

### 9. The Disjunction Alternative for Non-G-Content Elements

For elements NOT in g_content(u) (i.e., deferralDisjunctions, p_step_blocking_restricted, and BRS):

**deferralDisjunctions and p_step_blocking_restricted** are subsets of u, so they don't need special handling.

**BRS elements** need the G-wrapping argument (since F(psi) in u gives the contradiction).

**Combining**:
1. Separate L into L_u (elements in u) and L_brs (BRS elements not in u)
2. If L_brs is empty, L subset u contradicts u's consistency
3. If L_brs is non-empty, apply G-wrapping argument to one element
4. Recurse with one fewer BRS element

---

## Specific Proof Strategy

### Strategy: Induction on BRS Count with G-Wrapping

```lean
-- Prove by strong induction on the count of BRS elements in L
theorem seed_consistent_induction (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) (L : List Formula)
    (h_L_sub : forall x, x in L -> x in constrained_successor_seed_restricted phi u) :
    not (L derives bot)

-- Proof sketch:
-- Let k = |{x in L : x in boundary_resolution_set phi u}|
-- Induction on k:
-- - k = 0: L subset (non-BRS part of seed) subset u. Use u's consistency.
-- - k = n+1: Pick psi in L inter BRS. Apply G-wrapping argument:
--   - If psi notin L, trivially proceed with smaller set
--   - If psi in L, from L derives bot, apply deduction theorem to get L' derives psi.neg
--   - L' has n BRS elements (one fewer)
--   - G-wrap: G(L') derives G(psi.neg)
--   - All of G(L') are in u (because non-BRS elements have G-structure from g_content,
--     and BRS elements... wait, BRS elements don't have G-structure)
```

**Issue identified**: The G-wrapping only works when L subset g_content(u) u {psi}. When L contains OTHER BRS elements, G(L') is not necessarily in u.

### Refined Strategy: Nested G-Wrapping

For L = L_gc u {psi_1, ..., psi_k} where L_gc subset g_content(u):

1. **Process psi_1**: From `L derives bot`, get `L \ {psi_1} derives psi_1.neg`
   - Now `L \ {psi_1} = L_gc u {psi_2, ..., psi_k}`

2. **Process psi_2**: From `L_gc u {psi_2, ..., psi_k} derives psi_1.neg`, get...
   - Actually, we need `derives bot`, not `derives psi_1.neg`

**Problem**: After applying deduction theorem once, we no longer have `derives bot`.

### Revised Strategy: Process ALL BRS Elements at Once

Use **iterated deduction theorem**:

From `L_gc u {psi_1, ..., psi_k} derives bot`:

Apply deduction theorem k times:
`L_gc derives psi_1 -> (psi_2 -> ... -> (psi_k -> bot)...)`

Now G-wrap the entire derivation:
`G(L_gc) derives G(psi_1 -> (psi_2 -> ... -> (psi_k -> bot)...))`

Since `G(L_gc) subset u` (all elements of g_content have their G in u), we have:
`u derives G(psi_1 -> (psi_2 -> ... -> (psi_k -> bot)...))`

**Key temporal axiom**: `G(A -> B) -> (G(A) -> G(B))` (temporal K distribution)

By applying this k times:
`G(psi_1) -> (G(psi_2) -> ... -> (G(psi_k) -> G(bot))...)`

**But**: We do NOT have `G(psi_i) in u` in general. We have `F(psi_i) in u`.

**The Duality**: F(psi) = neg(G(neg(psi)))

So `G(psi.neg) = neg(F(psi))`.

If we could get `G(psi_i.neg)` from u, we'd have `neg(F(psi_i)) in u`, contradicting `F(psi_i) in u`.

**Adjusted approach**: Instead of G-wrapping psi directly, we G-wrap psi.neg:

From `L_gc u {psi_1, ..., psi_k} derives bot`:

Note that `psi_i.neg in u` for all i (by DRM maximality).

Actually, we want to derive `psi_i.neg` from `L_gc`, then G-wrap to get `G(psi_i.neg) in u`.

From `L_gc u {psi_1, ..., psi_k} derives bot`:
Apply deduction theorem to psi_1: `L_gc u {psi_2, ..., psi_k} derives psi_1.neg`

Hmm, but now we have psi_2, ..., psi_k in the premise, which we can't directly G-wrap.

---

## Viability Assessment

### Can Disjunctive Reasoning Work?

**Yes, but not alone**. The disjunctive approach provides the `or_elim_neg_neg` infrastructure, but:

1. We need BOTH branches to derive bot
2. The second branch (replacing psi with F(psi)) is not automatic
3. The proof requires careful induction structure

### Recommended Combined Approach

**Stage 1**: Prove `g_content(u) u BRS is consistent` via G-wrapping (as in plan v16)
- This uses the fact that BRS elements have their F in u
- The G-wrapping contradiction works for this restricted seed

**Stage 2**: Show adding `deferralDisjunctions u p_step_blocking_restricted` preserves consistency
- These are all subsets of u
- Use: if S is consistent and T subset u (consistent), then S u T might not be automatically consistent...
- Actually, this needs: if S subset deferralClosure and S is consistent, and T subset u, then S u T is consistent IF S u T subset u union S

**The Gap in Stage 2**: Adding elements from u to a consistent S does NOT automatically preserve consistency. We need the "no new contradictions" argument.

However, for our specific S = g_content(u) u BRS:
- Elements of S that are not in u are exactly BRS elements
- Their negations are in u
- Adding deferralDisjunctions (which are in u) cannot introduce {psi, psi.neg} pairs because psi.neg notin deferralDisjunctions (structural)

**Conclusion**: The disjunctive approach supports the overall proof strategy but is not a standalone solution. It provides the `or_elim_neg_neg` tool and the "no contradictory pairs" analysis for Stage 2.

---

## Confidence Assessment

| Aspect | Confidence | Notes |
|--------|------------|-------|
| `psi v F(psi)` is a tautology | HIGH | Derivable from F(psi) via disjunction introduction |
| `psi v F(psi) in u` for BRS psi | HIGH | Proven: deferralDisjunctions_subset_deferral_restricted_mcs |
| `or_elim_neg_neg` can be used | HIGH | Tool exists in codebase |
| Disjunctive cut works in single-step | HIGH | If both branches derive bot |
| Second branch is automatic | LOW | This is the gap |
| Combined G-wrapping + disjunction works | MEDIUM | Requires careful proof structure |

**Overall Confidence**: 65% (Medium-High)

---

## Recommendations

1. **Proceed with G-wrapping approach (Plan v16 Phase 1-2)** for the core consistency proof
2. **Use disjunctive reasoning** as a supporting tool for analyzing non-BRS seed elements
3. **The `or_elim_neg_neg` lemma** is available and should be used when both branches are derivable
4. **Do NOT rely solely on disjunctive substitution** -- it requires proving both branches independently

---

## References

| File | Line | Content |
|------|------|---------|
| Propositional.lean | 1614 | `de` (disjunction elimination) |
| Propositional.lean | 1686 | `or_elim_neg_neg` |
| SuccExistence.lean | 77 | `deferralDisjunctions` definition |
| SuccChainFMCS.lean | 1236 | `deferralDisjunctions_subset_deferral_restricted_mcs` |
| SuccChainFMCS.lean | 1444 | `single_brs_element_with_g_content_consistent` |
| Formula.lean | 282 | `Formula.or` definition (psi.neg.imp) |
