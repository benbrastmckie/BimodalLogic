# SubformulaClosure Design Gap Under U/S-Based Temporal Definitions

## 1. Literature Analysis

### 1.1 Burgess 1982: The Canonical Construction

Burgess 1982 (Section 2) proves completeness of the axiomatic system J_0 for U/S tense logic over the class of all linear orders. His construction is fundamentally different from the standard Kripke-style canonical model used for G/H tense logics.

**Key structural elements**:

1. **Chronicles, not canonical models**: Burgess does not use a single canonical model built from all MCSs. Instead, he constructs a *chronicle* -- a finite structure `(f, g)` where `f` maps rational numbers to MCSs and `g` maps intervals `(x,y)` to deductively closed sets (DCSs) representing formulas true throughout the interval.

2. **No explicit subformula closure**: Burgess's construction operates on *all* MCSs (which are infinite sets containing all formulas and their consequences). There is no finite closure set. The finiteness that drives termination comes from the fact that only finitely many counterexamples to conditions C4/C5 exist at each stage (since `dom f` is finite).

3. **Duality is built-in**: The crucial relations `r(A, beta, C)` and `R(A, B, C)` (Sections 2.3-2.8) encode the interval structure. Because G and H are *abbreviations* (`G(alpha) = ~F(~alpha)`, `F(alpha) = U(alpha, top)`), their behavior is derived from the U/S axioms (A1a-A7a). There is no need for separate "blocking" formulas because:
   - The MCSs are *full* (they contain every formula or its negation)
   - Deductive closure handles all logical consequences automatically
   - Conditions C4a/C5a directly reference `U(gamma, delta)` and `~U(gamma, delta)`, not G/H

**Implication for our problem**: Burgess's completeness proof for arbitrary linear orders does NOT use a finite subformula closure. It operates on full MCSs. Our formalization, which uses *restricted* MCSs (DeferralRestrictedMCS) constrained to a finite `deferralClosure`, introduces a finiteness constraint that Burgess avoids.

### 1.2 The Fischer-Ladner Closure in Temporal Logic

The standard "Fischer-Ladner closure" (from Fischer & Ladner 1979, adapted to temporal logic) is the finite-model-theory approach used for decidability and tableau-based completeness proofs. The key references are:

- **Lichtenstein & Pnueli 1985**: Define a closure `cl(phi)` for LTL formulas that includes, for each formula in the closure, its negation, and is closed under subformulas. Crucially, for U formulas: if `psi U chi` is in `cl(phi)`, then both `psi` and `chi` are in `cl(phi)`, AND the "next-step unfolding" `chi OR (psi AND X(psi U chi))` is semantically ensured.

- **Gabbay, Hodkinson, Reynolds 1994 (Ch. 10)**: The separation theorem approach. Their proof of expressive completeness proceeds by syntactic rewriting (eliminating nested U/S occurrences), not by canonical models. They do not explicitly construct a finite closure for completeness; instead, they show that any formula can be rewritten into a separated form.

- **Reynolds 1992**: For US/R (Until-Since over Reals), uses Burgess's full-MCS approach extended with Prior axioms and the Sep axiom. Again, no finite closure -- full MCSs.

### 1.3 Venema 1993: Completeness via Expressive Completeness

Venema uses an indirect approach: show the axiom system is complete for linear orders (via Burgess), then use expressive completeness to transfer the result to well-orderings. He defines G and H differently from Burgess:

```
G(phi) = U(bot, phi)    -- "phi holds at all strictly future times" via "never bot until phi"
H(phi) = S(bot, phi)    -- dual
F(phi) = ~G(~phi)
P(phi) = ~H(~phi)
```

This is an *alternative* encoding where G is primitive (via U) and F is derived. Note this is the *opposite* of our encoding where F is primitive (via U) and G is derived.

**Important observation**: Under Venema's definitions, `G(phi) = U(bot, phi)` IS a direct subformula of any formula containing it, because it uses the U constructor. Under our definitions, `G(phi) = ~F(~phi) = ~(U(~phi, top))`, which is a complex derived term.

### 1.4 The Core Insight: Two Approaches to Finitization

The literature reveals two fundamentally different approaches:

**Approach A (Burgess, Reynolds, Venema)**: Work with full infinite MCSs. No finite closure needed. Completeness is for single formulas (weak completeness). The finiteness in the construction comes from the chronicle being built incrementally with finitely many points.

**Approach B (Fischer-Ladner, Tableau methods)**: Work with finite closures for decidability/tableau completeness. The closure must be explicitly "fattened" to include all formulas needed during the construction.

Our formalization uses a *hybrid*: Burgess-style MCS reasoning but with *restricted* MCSs constrained to a finite `deferralClosure`. This hybrid creates the design gap.

## 2. The Mathematically Correct Fix

### 2.1 The Problem Precisely Stated

Under the new definitions:
```
F(chi) = U(chi, top)     -- F is primitive via U
P(chi) = S(chi, top)     -- P is primitive via S
G(chi) = ~F(~chi) = (U(~chi, top)).imp bot    -- G is derived
H(chi) = ~P(~chi) = (S(~chi, top)).imp bot    -- H is derived
```

The structural subformulas of `P(chi) = S(chi, top)` are:
- `chi`
- `top = bot.imp bot`
- `bot`

The formula `H(~chi) = (S(~chi, top)).imp bot` is NOT a subformula of `P(chi)`. The two formulas share no structural containment relationship.

However, the completeness proof *requires* that if `P(chi)` is in the closure, then `H(~chi)` is also in the closure, because:
1. If `P(chi) notin u` (an MCS), then `~P(chi) in u` (maximality)
2. `~P(chi) = H(~chi)` (by definition)
3. The proof needs `H(~chi)` in the restricted closure to apply DRM maximality

### 2.2 The Standard Solution: Extended Closure

The standard approach in finite-model-theory treatments of temporal logic is to define a closure that is closed under the **semantic duality** of temporal operators, not just structural subformulas.

**Definition (Temporal Duality Closure)**: For a formula `phi`, define:

```
temporalDualSet(phi) = 
  { H(~chi) | F(chi) in closureWithNeg(phi) } ∪
  { G(~chi) | P(chi) in closureWithNeg(phi) } ∪
  { ~H(~chi) | F(chi) in closureWithNeg(phi) } ∪   -- = P(chi) via def
  { ~G(~chi) | P(chi) in closureWithNeg(phi) }      -- = F(chi) via def
```

Wait -- this is circular. Let me be more precise.

The key duality pairs under the new definitions are:
- `~P(chi) = H(~chi)` (definitionally equal, by unfolding)
- `~F(chi) = G(~chi)` (definitionally equal, by unfolding)

The issue is that `P(chi) = S(chi, top)` while `H(~chi) = (S(~chi, top)).imp bot`. These are *definitionally* related (`H(~chi) = ~P(chi) = P(chi).neg = P(chi).imp bot`) but *structurally* unrelated (snce vs. imp constructors at the top level).

**The fix**: When `P(chi) = S(chi, top)` is in `closureWithNeg(phi)`, we need `(S(chi, top)).imp bot` (which equals `H(~chi)`) to also be in the deferral closure. But `(S(chi, top)).imp bot = P(chi).neg`, and `closureWithNeg` already includes `psi.neg` for every `psi in subformulaClosure(phi)`.

**Wait -- this means the fix might already be present!** Let me re-examine.

If `P(chi) in subformulaClosure(phi)`, then `P(chi).neg in closureWithNeg(phi)`. And `P(chi).neg = (S(chi, top)).imp bot = H(~chi)` by unfolding the definitions.

So the question reduces to: **is `P(chi).neg` the same as `H(~chi)` definitionally in Lean?**

### 2.3 Definitional Equality Check

Let us trace the definitions:
```
P(chi).neg = (Formula.some_past chi).neg
           = (Formula.snce chi Formula.top).imp Formula.bot

H(~chi) = Formula.all_past (chi.neg)
         = (Formula.some_past (chi.neg).neg).neg
         = (Formula.some_past (chi.imp bot).imp bot)).neg
         = ((Formula.snce ((chi.imp bot).imp bot) (bot.imp bot)).imp bot)
```

Wait, let me be more careful:
```
chi.neg = chi.imp bot

Formula.some_past (chi.neg) = Formula.snce (chi.imp bot) (bot.imp bot)

(Formula.some_past (chi.neg)).neg = (Formula.snce (chi.imp bot) (bot.imp bot)).imp bot

Formula.all_past (chi.neg) = (Formula.some_past (chi.neg.neg)).neg
                            WRONG -- let me re-read the definition
```

From the code:
```lean
def all_past (φ : Formula) : Formula := (some_past φ.neg).neg
```

So:
```
H(~chi) = all_past (chi.neg)
         = all_past (chi.imp bot)
         = (some_past (chi.imp bot).neg).neg
         = (some_past ((chi.imp bot).imp bot)).neg
         = (snce ((chi.imp bot).imp bot) (bot.imp bot)).imp bot
```

And:
```
P(chi).neg = (some_past chi).neg
           = (snce chi (bot.imp bot)).imp bot
```

These are **NOT** definitionally equal! 

- `H(~chi)` = `(snce ((chi.imp bot).imp bot) (bot.imp bot)).imp bot`
- `P(chi).neg` = `(snce chi (bot.imp bot)).imp bot`

The first argument to `snce` differs: `(chi.imp bot).imp bot` vs `chi`.

The issue is that `H(~chi) = ~P(~~chi)`, not `~P(chi)`. And `~~chi != chi` structurally (even though they are logically equivalent).

### 2.4 The Real Gap

The real mathematical relationship is:
```
~P(chi) = H(~chi)    -- by definition, since P(chi) = ~H(~chi)

But expanded:
~P(chi) = P(chi).neg = (snce chi top).imp bot

H(~chi) = all_past (chi.neg)
         = (some_past (chi.neg.neg)).neg
         = (snce (chi.neg.neg) top).imp bot
         = (snce ((chi.imp bot).imp bot) top).imp bot
```

So `~P(chi)` and `H(~chi)` differ in their first snce argument: `chi` vs `(chi.imp bot).imp bot` (i.e., `~~chi`). They are provably equivalent (since `chi <-> ~~chi` is a tautology), but they are NOT definitionally equal in Lean.

This means the proof cannot simply use `closureWithNeg` membership of `P(chi).neg`. The proof needs `H(~chi)` -- which has `~~chi` as its inner formula -- to be in the closure, and this is a *different* formula from `~P(chi)`.

### 2.5 The Correct Fix: Temporal Blocking Set

The standard solution is to extend the `baseDeferralClosure` with a **temporal blocking set** (also called "temporal dual closure" in some literature):

**Definition**: For a formula `phi`, define:
```
temporalBlockingSet(phi) = 
  { all_past (chi.neg) | some_past chi in closureWithNeg(phi) } ∪
  { all_future (chi.neg) | some_future chi in closureWithNeg(phi) }
```

In Lean terms:
```lean
def temporalBlockingSet (phi : Formula) : Finset Formula :=
  let pastBlocking := (closureWithNeg phi).image (fun f => 
    match extractPastInner f with
    | some chi => Formula.all_past chi.neg
    | none => Formula.bot)  -- dummy, filtered out
  let futureBlocking := (closureWithNeg phi).image (fun f =>
    match extractFutureInner f with  
    | some chi => Formula.all_future chi.neg
    | none => Formula.bot)
  pastBlocking.filter (· != Formula.bot) ∪ futureBlocking.filter (· != Formula.bot)
```

Or more cleanly using the existing `IsPastFormula`/`IsFutureFormula` predicates:
```lean
def temporalBlockingSet (phi : Formula) : Finset Formula :=
  let pastFormulas := (closureWithNeg phi).filter IsPastFormula
  let futureFormulas := (closureWithNeg phi).filter IsFutureFormula
  pastFormulas.image (fun f => match extractPastInner f with
    | some chi => Formula.all_past chi.neg | none => f) ∪
  futureFormulas.image (fun f => match extractFutureInner f with
    | some chi => Formula.all_future chi.neg | none => f)
```

Then redefine:
```lean
def baseDeferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi 
  ∪ serialityFormulas ∪ temporalBlockingSet phi
```

### 2.6 Why This Is Mathematically Correct

The temporal blocking set ensures the following **duality invariant**:

> For any P-formula `P(chi)` in the closure, its dual `H(~chi)` is also in the closure.
> For any F-formula `F(chi)` in the closure, its dual `G(~chi)` is also in the closure.

This invariant is needed because:

1. **MCS maximality**: In a deferral-restricted MCS, if `P(chi) notin M` and `P(chi) in deferralClosure`, then `M ∪ {P(chi)}` is inconsistent. From this inconsistency, the proof derives `~P(chi) in M`. But the proof then needs to reason about `H(~chi)` (the "all-past" version), which is provably equivalent to `~P(chi)` but structurally different.

2. **The structural mismatch**: `~P(chi)` has the form `(S(chi, top)).imp bot`, while `H(~chi)` has the form `(S(~~chi, top)).imp bot`. The proof needs `H(~chi)` in the closure because downstream lemmas pattern-match on the `all_past` structure.

3. **Finiteness preservation**: The temporal blocking set is at most as large as the closure it derives from (one blocking formula per F/P formula), so the overall closure remains finite.

## 3. Implementation Recommendations

### 3.1 Immediate Fix: Add `temporalBlockingSet` to `baseDeferralClosure`

**File**: `Theories/Bimodal/Syntax/SubformulaClosure.lean`

1. Define `temporalBlockingSet` after the existing `backwardDeferralSet` definition (around line 780).

2. Modify `baseDeferralClosure`:
```lean
def baseDeferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi 
  ∪ serialityFormulas ∪ temporalBlockingSet phi
```

3. Prove the key membership lemmas:
```lean
-- If P(chi) is in closureWithNeg, then H(~chi) is in deferralClosure
theorem all_past_neg_mem_deferralClosure_of_some_past 
    (phi chi : Formula) 
    (h : Formula.some_past chi ∈ closureWithNeg phi) :
    Formula.all_past chi.neg ∈ deferralClosure phi

-- If F(chi) is in closureWithNeg, then G(~chi) is in deferralClosure
theorem all_future_neg_mem_deferralClosure_of_some_future 
    (phi chi : Formula) 
    (h : Formula.some_future chi ∈ closureWithNeg phi) :
    Formula.all_future chi.neg ∈ deferralClosure phi
```

### 3.2 Cascading Changes

The change to `baseDeferralClosure` affects approximately 15-20 membership proofs in `SubformulaClosure.lean` that pattern-match on the union structure. Specifically:

1. **`deferralClosure` structure proofs**: Any proof that unfolds `deferralClosure` → `baseDeferralClosure` and then does `Finset.mem_union` case analysis will get an additional case (the `temporalBlockingSet` case). These proofs need an additional `rcases` branch.

2. **`some_past_in_deferralClosure_cases`** and **`some_future_in_deferralClosure_cases`**: These will need to handle the new case where a P/F formula is in the temporal blocking set. However, blocking formulas are H/G formulas, not P/F formulas, so this case should discharge by constructor discrimination.

3. **`closureWithNeg_subset_deferralClosure`**: Still holds, just with one more union layer.

### 3.3 Fixing the Sorry Sites

**Sorry 1 (line 244 in SuccExistence.lean)**: `p_step_blocking_restricted_subset_deferralClosure`
- After adding `temporalBlockingSet`, the proof becomes:
  ```
  If P(chi) ∈ deferralClosure and P(chi) ∈ closureWithNeg,
  then H(~chi) ∈ temporalBlockingSet ⊆ deferralClosure. QED.
  ```

**Sorry 2 (line 966 in RestrictedMCS.lean)**: `p_step_blocking_restricted_subset` 
- Same fix pattern as Sorry 1.

**Sorry 3 (line 460 in SuccExistence.lean)**: `constrained_successor_seed_consistent`
- This sorry is `g_content u ⊆ u`, which is about `G(phi) → phi` (reflexivity of G). This is a **different** problem -- it is about the BX1 axiom, not about the subformula closure gap. Under irreflexive semantics, `G(phi) → phi` does not hold. This sorry is unrelated to the temporal blocking set.

**Sorry 4 (line 763 in SuccExistence.lean)**: `successor_deferral_seed_consistent_axiom`
- Same as Sorry 3 -- `g_content u ⊆ u` under irreflexive semantics. Unrelated to the closure gap.

**Sorry 5 (line 837 in SuccExistence.lean)**: `predecessor_deferral_seed_consistent_axiom`
- Dual of Sorry 4 -- `h_content u ⊆ u` under irreflexive semantics. Also unrelated.

**Sorry 6 (line 1399 in RestrictedMCS.lean)**: `neg_FF_implies_GG_neg_in_drm`
- This sorry needs intermediate formulas `G(~F(psi))` and `GG(~psi)` in the deferral closure. The temporal blocking set helps partially: if `F(psi)` is in the closure, then `G(~psi)` is in the closure. But `G(~F(psi))` requires `F(psi)` to be treated as the "chi" in a new F-formula. This requires **nested blocking**: if `F(F(psi))` is in the closure, we need `G(~F(psi))`, which requires `F(psi)` as the blocked formula.

### 3.4 Handling the Nested F Case (Sorry 6)

The `neg_FF_implies_GG_neg_in_drm` theorem needs:
- `~F(F(psi))` ∈ M (given)
- Want: `G(G(~psi))` ∈ M

The proof chain is:
1. `~F(F(psi))` → `G(~F(psi))` (by `~F = G~` definitional equivalence, but NOT structural)
2. `G(~F(psi))` → `G(G(~psi))` (by `⊢ G(~F(psi) → G(~psi))` and BX3)

Step 1 requires `G(~F(psi))` in the deferral closure. Under the temporal blocking set:
- If `F(F(psi))` is in `closureWithNeg`, then `G(~F(psi))` is in `temporalBlockingSet` (since `F(F(psi))` is an F-formula with inner `F(psi)`).

Step 2 requires `G(G(~psi))` in the deferral closure. This is trickier:
- We need `G(~psi)` in the closure first (which follows if `F(psi)` is in `closureWithNeg`)
- Then we need `G(G(~psi))` -- but this is `G` applied to a `G`-formula, not directly in the blocking set.

**Extended solution**: The blocking set as defined handles single-level duality. For the nested case, we need either:

**(a) Extend the blocking set to include G/H applied to blocking formulas**:
```
temporalBlockingSet_level2(phi) = 
  temporalBlockingSet(phi) ∪
  { all_future (f) | f ∈ temporalBlockingSet(phi) } ∪
  { all_past (f) | f ∈ temporalBlockingSet(phi) }
```

**(b) Restructure `neg_FF_implies_GG_neg_in_drm` to use proof-theoretic equivalences within the DRM framework**, avoiding the need for intermediate formulas in the closure. Specifically:
- Since `~F(F(psi)) = (F(F(psi))).neg = (untl (untl psi top) top).imp bot`
- And `G(G(~psi)) = ((untl (untl (~psi) top) top).imp bot).neg.imp bot` (after full expansion)
- Show these are provably equivalent and use MCS closure under provable implication
- This approach requires the provable equivalence `~F(F(psi)) <-> G(G(~psi))` to be derivable within the proof system, and the DRM to be closed under implications where both sides are in the closure.

Option (b) is more elegant and avoids further closure bloat. The key insight is that the DRM is closed under *provable implications* as long as the conclusion is in the deferral closure. But we still need the conclusion `G(G(~psi))` to be in the closure somewhere.

**Recommendation**: Use a **two-level temporal blocking set** that applies the blocking operation twice. This is finite (bounded by `|closureWithNeg|^2` in the worst case) and handles all cases in the current proofs.

## 4. Additional Formulas Beyond the Blocking Set

### 4.1 Formulas Needed

Beyond the basic temporal blocking set `{H(~chi) | P(chi) in closure} ∪ {G(~chi) | F(chi) in closure}`, the following are also needed:

1. **Negations of blocking formulas**: `~H(~chi)` and `~G(~chi)`. But `~H(~chi) = P(chi)` and `~G(~chi) = F(chi)`, which are already in the closure. So no new formulas needed.

2. **Nested G/H on blocking formulas** (for the `neg_FF_implies_GG_neg` case):
   - `G(G(~chi))` when `F(F(chi))` is in the closure
   - `H(H(~chi))` when `P(P(chi))` is in the closure
   - `G(~F(chi))` when `F(F(chi))` is in the closure (intermediate)
   - `H(~P(chi))` when `P(P(chi))` is in the closure (intermediate)

3. **Double-negation bridge formulas**: The gap between `~P(chi)` (= `(S(chi,top)).imp bot`) and `H(~chi)` (= `(S(~~chi,top)).imp bot`) could be bridged by including `~~chi → chi` style implications, but this is handled proof-theoretically rather than by closure membership.

### 4.2 Summary of Required Closure Extensions

| Formula in closure | Required addition | Reason |
|---|---|---|
| `P(chi)` = `S(chi, top)` | `H(~chi)` = `(S(~~chi, top)).imp bot` | MCS blocking set membership |
| `F(chi)` = `U(chi, top)` | `G(~chi)` = `(U(~~chi, top)).imp bot` | MCS blocking set membership |
| `F(F(chi))` | `G(~F(chi))`, `G(G(~chi))` | neg_FF_implies_GG_neg proof |
| `P(P(chi))` | `H(~P(chi))`, `H(H(~chi))` | Dual of above |

### 4.3 Finiteness Guarantee

The temporal blocking set (even at level 2) is bounded by `O(n)` where `n = |closureWithNeg(phi)|`:
- Level 1: at most `2n` formulas (one G/H per F/P in closure)
- Level 2: at most `2n` additional formulas (G/H applied to level-1 formulas)
- Total: at most `4n` additional formulas

This preserves the finiteness of `deferralClosure`.

## 5. Recommended Implementation Plan

### Phase 1: Define temporalBlockingSet (SubformulaClosure.lean)

1. Add helper functions to extract inner formulas from F/P formulas
2. Define `temporalBlockingSet` at level 1
3. Define `temporalBlockingSetL2` at level 2 (if needed for nested case)
4. Modify `baseDeferralClosure` to include the blocking set

### Phase 2: Fix membership proofs (SubformulaClosure.lean)

1. Update all proofs that pattern-match on `baseDeferralClosure` union structure
2. Prove `all_past_neg_mem_deferralClosure_of_some_past`
3. Prove `all_future_neg_mem_deferralClosure_of_some_future`
4. Update `some_past_in_deferralClosure_cases` and `some_future_in_deferralClosure_cases`

### Phase 3: Close sorry sites (SuccExistence.lean, RestrictedMCS.lean)

1. Fix `p_step_blocking_restricted_subset_deferralClosure` (line 244)
2. Fix `p_step_blocking_restricted_subset` (line 966 in RestrictedMCS.lean)
3. Attempt `neg_FF_implies_GG_neg_in_drm` (line 1399 in RestrictedMCS.lean) -- may need level-2 blocking set

### Phase 4: Do NOT attempt to fix the g_content/h_content sorries

The sorries at lines 460, 763, 837 in SuccExistence.lean are about `g_content u ⊆ u` (= `G(phi) → phi`, the reflexivity axiom BX1). These are unrelated to the subformula closure gap and are a consequence of the irreflexive semantics design decision. They should be addressed separately.

## 6. Alternative Approaches Considered and Rejected

### 6.1 Use Venema's G = U(bot, phi) encoding

Re-encoding `G(phi) = U(bot, phi)` instead of `G(phi) = ~F(~phi)` would make G a structural subformula of any formula containing it. However, this would require re-doing the entire task 116 refactoring and changing the semantic evaluation.

**Rejected**: Too large a change, and the current encoding follows Burgess 1982 Section 1.1 faithfully.

### 6.2 Switch to full (unrestricted) MCSs

If we used full MCSs (like Burgess), there would be no closure constraint and no gap. However, the restricted MCS approach is needed for the specific termination arguments in the bundle construction.

**Rejected**: Would require fundamental restructuring of the completeness proof architecture.

### 6.3 Add double-negation normalization to the closure

Instead of adding blocking formulas, normalize all formulas in the closure by eliminating double negations. Then `~P(chi)` would normalize to `H(~chi)` (since `~~chi` normalizes to `chi`).

**Rejected**: Double-negation normalization would break structural equality throughout the codebase and create far more cascading changes than the blocking set approach.
