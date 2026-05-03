# Phase 3 Research Report: lemma_2_7_seed_consistent BX7 Chain

**Research Teammate B**  
**Session**: sess_1777762781_b2f826  
**Task**: 107 — Chain Design Diagnostics for Representation Theorem  
**Date**: May 2, 2026

---

## Executive Summary

This report analyzes the `lemma_2_7_seed_consistent` proof (PointInsertion.lean line 2391), which requires a 10-step BX axiom chain centered on **BX7 (linear_until)**. This is the **critical blocker** for Phase 3 completion. The proof implements Burgess 1982 Lemma 2.7 (p. 372) for constructing an MCS D with xi ∈ D and eta ∈ B' via point insertion.

**Key Finding**: The MCS-level wrapper `linear_until_mcs` for BX7 does **NOT currently exist** and must be implemented. All other infrastructure (BX5, BX10, BX13, BX14 wrappers) is available.

**Estimated Effort**: 5 hours (matches plan v52 estimate)

---

## 1. Mathematical Analysis

### 1.1 The Seed Structure (lines 2372-2375)

```lean
private def lemma_2_7_seed (A B C : Set Formula) (xi eta : Formula) : Set Formula :=
  B ∪ {xi} ∪ {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl β γ} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce β α} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce (Formula.and β eta) α}
```

The 5 components are:

| Component | Formula | Source |
|-----------|---------|--------|
| 1 | B (all formulas in B) | Given |
| 2 | xi | Hypothesis `h_until: untl(xi, eta) ∈ A` |
| 3 | untl(β, γ) for β ∈ B, γ ∈ C | From `burgessR3 A B C` |
| 4 | snce(β, α) for β ∈ B, α ∈ A | From `burgessR3 A B C` (via Lemma 2.3) |
| 5 | **snce(β ∧ eta, α)** for β ∈ B, α ∈ A | **The Burgess insight — requires BX7** |

**Critical observation**: Component 5 has guard `β ∧ eta`, not just `β`. This means the event in the BX chain must contain **both** β and eta to serve as the guard for snce-enrichment.

### 1.2 BX7 (linear_until) Statement

From Axioms.lean lines 226-236:

```lean
| linear_until (φ ψ χ θ : Formula) :
    Axiom (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))
```

**Propositional form**:
```
(φ U ψ) ∧ (χ U θ) →
  ((φ ∧ χ) U (ψ ∧ θ)) ∨
  ((φ ∧ χ) U (ψ ∧ χ)) ∨
  ((φ ∧ χ) U (φ ∧ θ))
```

**Semantics**: When two Until formulas hold simultaneously, their guards φ, χ both hold now, and their eventualities ψ, θ occur at some future points. Linearity (trichotomy) says either:
- **D1**: The events coincide (ψ ∧ θ)
- **D2**: First eventuality comes first (ψ ∧ χ)
- **D3**: Second eventuality comes first (φ ∧ θ)

### 1.3 Burgess 1982 Section 2.7 (p. 372)

Burgess's Lemma 2.7 states (translated to our notation):

> If U(ξ, η) ∈ A, η ∉ B, and R(A, B, C) is maximal, then there exist D, B', B'' such that R(A, B', D), R(D, B'', C), ξ ∈ D, and η ∈ B'.

Burgess's proof (p. 372, near Lemma 2.7):

1. From maximality and η ∉ B, extract β₀ ∈ B, γ₀ ∈ C with ¬U(β₀ ∧ η, γ₀) ∈ A
2. A5a (BX5) on U(ξ, η): U(ξ ∧ U(ξ, η), η) ∈ A
3. A5a on U(β₀, γ₀): U(β₀ ∧ U(β₀, γ₀), γ₀) ∈ A
4. A7a (our BX7): Three-way disjunction with witnesses (β₀ ∧ U(β₀, γ₀) ∧ ξ, θ)
5. The first two disjuncts contradict ¬U(β₀ ∧ η, γ₀) ∈ A via monotonicity
6. The third disjunct survives, giving an event containing ξ, U(ξ, η), β₀, and η
7. A3a (BX13) enrichment adds S-formulas to the event
8. A4a (BX10) extracts F(event) ∈ A

**Critical difference from A7a**: Burgess's original A7a had fixed event (ψ ∧ θ) in all three disjuncts. Our BX7 has three **different** events:
- D1: (ψ ∧ θ)
- D2: (ψ ∧ χ)
- D3: (φ ∧ θ)

This difference is **intentional and necessary**: A7a is unsound under open guard semantics, but BX7 is valid. The proof adaptation accounts for this.

---

## 2. The BX7 Chain: Step-by-Step

### Step 1: Extract neg-until witness (lemma_2_7_neg_untl_exists)

**Goal**: From η ∉ B and BurgessR3Maximal(A, B, C), extract β₀ ∈ B, γ₀ ∈ C with ¬untl(β₀ ∧ η, γ₀) ∈ A.

**Approach**: Use `BurgessR3Maximal_extension_fails` with delta = eta.

```lean
private theorem lemma_2_7_neg_untl_exists {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (eta : Formula)
    (h_eta_not_B : eta ∉ B)
    (h_F_eta : Formula.some_future eta ∈ A) :  -- From h_until via BX10
    ∃ β₀ ∈ B, ∃ γ₀ ∈ C, (Formula.untl (Formula.and β₀ eta) γ₀).neg ∈ A := by
  -- Case analysis: {eta} ∪ B consistent or inconsistent
  by_cases h_cons : SetConsistent ({eta} ∪ B)
  · -- Consistent case: Use BurgessR3Maximal_extension_fails + dc_delta_B_burgessR3
    have h_not_r3 := BurgessR3Maximal_extension_fails h_r3m h_eta_not_B h_cons
    -- The negation of burgessR3 gives the witness
    -- (needs unfolding of burgessR3 negation)
    sorry
  · -- Inconsistent case: eta.neg ∈ B, use beta0 = eta.neg
    -- Extract contradiction via F(eta) ∈ A and G(eta.neg) ∈ A
    sorry
```

**Implementation notes**:
- The `h_F_eta` is available from `until_implies_F_in_mcs h_mcs_A h_until`
- The negation of `burgessR3 A (deductiveClosure ({eta} ∪ B)) C` yields the witness
- Need helper to extract β₀, γ₀ from `¬burgessR3`

**Estimated lines**: ~40 lines

### Step 2: BX5 self-accumulation on U(xi, eta)

**Input**: `untl(xi, eta) ∈ A` (hypothesis `h_until`)

**Output**: `untl(xi ∧ untl(xi, eta), eta) ∈ A`

**Available**: `self_accum_until_mcs h_mcs_A xi eta h_until`

Let:
- `phi1 := xi ∧ untl(xi, eta)`  (enriched guard)
- `psi1 := eta`  (eventuality)

So we have: `untl(phi1, psi1) ∈ A`

### Step 3: BX5 self-accumulation on U(beta₀, gamma₀)

**Input**: `untl(beta₀, gamma₀) ∈ A` (from `burgessR3 A B C` and `beta₀ ∈ B`, `gamma₀ ∈ C`)

**Output**: `untl(beta₀ ∧ untl(beta₀, gamma₀), gamma₀) ∈ A`

**Available**: `self_accum_until_mcs h_mcs_A beta₀ gamma₀ h_untl_bg`

Let:
- `phi2 := beta₀ ∧ untl(beta₀, gamma₀)`  (enriched guard)
- `psi2 := gamma₀`  (eventuality)

So we have: `untl(phi2, psi2) ∈ A`

### Step 4: BX7 three-way disjunction

**Input**: 
- `untl(phi1, psi1) ∈ A` where `phi1 = xi ∧ untl(xi, eta)`, `psi1 = eta`
- `untl(phi2, psi2) ∈ A` where `phi2 = beta₀ ∧ untl(beta₀, gamma₀)`, `psi2 = gamma₀`

**BX7 application** with:
- φ = phi1, ψ = psi1
- χ = phi2, θ = psi2

**The three disjuncts**:

| Disjunct | Formula | Expanded |
|----------|---------|----------|
| D1 | `(phi1 ∧ phi2) U (psi1 ∧ psi2)` | `(xi ∧ untl(xi,eta) ∧ beta₀ ∧ untl(beta₀,gamma₀)) U (eta ∧ gamma₀)` |
| D2 | `(phi1 ∧ phi2) U (psi1 ∧ chi)` | `(xi ∧ untl(xi,eta) ∧ beta₀ ∧ untl(beta₀,gamma₀)) U (eta ∧ (beta₀ ∧ untl(beta₀,gamma₀)))` |
| D3 | `(phi1 ∧ phi2) U (phi1 ∧ theta)` | `(xi ∧ untl(xi,eta) ∧ beta₀ ∧ untl(beta₀,gamma₀)) U ((xi ∧ untl(xi,eta)) ∧ gamma₀)` |

Wait — this doesn't match the needed structure. Let me re-read BX7...

Actually, looking at BX7 more carefully:

```
(φ U ψ) ∧ (χ U θ) →
  ((φ ∧ χ) U (ψ ∧ θ)) ∨     -- D1: both eventualities coincide
  ((φ ∧ χ) U (ψ ∧ χ)) ∨     -- D2: first event before second guard ends
  ((φ ∧ χ) U (φ ∧ θ))       -- D3: second event before first guard ends
```

The key insight: **In D3, the event is (φ ∧ θ)**, which contains:
- `φ = xi ∧ untl(xi, eta)`  (from first Until's guard)
- `θ = gamma₀`  (from second Until's eventuality)

But we need eta in the guard for component 5! Let me trace through...

Actually, D3's event is `(phi1 ∧ theta)` = `((xi ∧ untl(xi, eta)) ∧ gamma₀)`. 

This contains `xi` and `gamma₀`, but where is `eta`?

The key is that the **guard** of the resulting Until in D3 is `(phi1 ∧ phi2)`, which contains:
- `phi1 = xi ∧ untl(xi, eta)` — contains `xi` and `untl(xi, eta)`
- `phi2 = beta₀ ∧ untl(beta₀, gamma₀)` — contains `beta₀` and `untl(beta₀, gamma₀)`

So the guard has: `xi`, `untl(xi, eta)`, `beta₀`, `untl(beta₀, gamma₀)`.

But we need the **event** to contain eta for component 5's guard `beta ∧ eta`...

Let me re-examine Burgess's proof more carefully. The event from the surviving disjunct needs to imply `beta₀ ∧ eta` for snce(beta₀ ∧ eta, alpha).

Looking at the three disjuncts again with focus on which contain `eta`:
- D1 event: `psi1 ∧ psi2` = `eta ∧ gamma₀` — **contains eta!**
- D2 event: `psi1 ∧ chi` = `eta ∧ phi2` = `eta ∧ beta₀ ∧ untl(beta₀, gamma₀)` — **contains eta and beta₀!**
- D3 event: `phi1 ∧ theta` = `(xi ∧ untl(xi, eta)) ∧ gamma₀` — does NOT contain eta

So if D3 survives, we get an event with `xi` and `gamma₀`, but NOT `eta`...

Wait, let me re-read Teammate D's findings. From report 52:

> The surviving disjunct from BX7 is `U(beta0∧U(beta0,gamma0)∧xi, theta)∈A` where theta includes both b and eta.

So the third disjunct should have `theta` containing eta. Let me re-check BX7's third disjunct...

BX7 third disjunct: `(φ ∧ χ) U (φ ∧ θ)`

With φ = phi1 = xi ∧ untl(xi, eta) and χ = phi2 = beta₀ ∧ untl(beta₀, gamma₀) and θ = psi2 = gamma₀:

Third disjunct: `((xi ∧ untl(xi, eta)) ∧ (beta₀ ∧ untl(beta₀, gamma₀))) U ((xi ∧ untl(xi, eta)) ∧ gamma₀)`

The event here is `(xi ∧ untl(xi, eta)) ∧ gamma₀` — this does NOT contain eta.

Hmm, there seems to be a mismatch. Let me look at the research reports more carefully...

From Teammate A's findings (report 52):
> "The surviving disjunct from BX7 is `U(β∧U(γ∧γ', β)∧ξ, θ)∈A`"

I think the notation conventions differ. Let me check: in our codebase, `untl(φ, ψ)` means "φ U ψ" where φ is guard, ψ is eventuality.

In Burgess's notation from p. 372: `U(γ, β)` means "γ U β" where γ is guard, β is eventuality.

So the third disjunct in BX7 when applied to `U(xi, eta)` and `U(beta0, gamma0)`:

If we map:
- φ = xi, ψ = eta (first Until)
- χ = beta0, θ = gamma0 (second Until)

Then BX7 gives:
- D1: `(xi ∧ beta0) U (eta ∧ gamma0)`
- D2: `(xi ∧ beta0) U (eta ∧ beta0)` = `(xi ∧ beta0) U (eta ∧ beta0)`
- D3: `(xi ∧ beta0) U (xi ∧ gamma0)`

Wait, that's not using the self-accumulated forms...

Actually, the proof uses the **self-accumulated** forms:
- First: `U(xi ∧ U(xi, eta), eta)` 
- Second: `U(beta0 ∧ U(beta0, gamma0), gamma0)`

So mapping to BX7:
- φ = `xi ∧ U(xi, eta)`, ψ = eta
- χ = `beta0 ∧ U(beta0, gamma0)`, θ = gamma0

Then D3's event is `φ ∧ θ` = `(xi ∧ U(xi, eta)) ∧ gamma0`.

This still doesn't have eta as a standalone conjunct...

Let me re-read Teammate D's findings more carefully:

> "A7a applies to tell us that one of the following must belong to A: U(γ ∧ xi, θ), U(γ ∧ U(xi,eta), θ), or U(β ∧ U(γ,β) ∧ xi, θ)."

Here γ = beta0 ∧ U(beta0, gamma0), xi = xi ∧ U(xi, eta), and θ is the common event.

So Burgess's A7a has the form:
```
U(γ, β) ∧ U(ξ, η) → 
  U(γ ∧ ξ, β ∧ η) ∨ 
  U(γ ∧ ξ, β ∧ ξ) ∨ 
  U(γ ∧ ξ, η ∧ β)
```

But our BX7 is:
```
U(φ, ψ) ∧ U(χ, θ) → 
  U(φ ∧ χ, ψ ∧ θ) ∨
  U(φ ∧ χ, ψ ∧ χ) ∨
  U(φ ∧ χ, φ ∧ θ)
```

The third disjunct differs! A7a has `η ∧ β` (the two original eventualities), while BX7 has `φ ∧ θ` (first guard ∧ second eventuality).

This is the **critical adaptation** noted in report 52: BX7 ≠ A7a. A7a is removed as unsound under open guard. The proof must adapt.

From report 52 (teammate-b-findings.md):
> "The key: Burgess uses the S-formula's guard being β∧η, which requires η to be in the event via the BX7 disjunction step, not from the seed's untl formulas."

The solution must be in how we use the BX7 result. Perhaps:
1. D1's event is `eta ∧ gamma0` — contains eta!
2. D2's event is `eta ∧ (beta0 ∧ U(beta0, gamma0))` — contains eta and beta0!
3. D3's event is `(xi ∧ U(xi, eta)) ∧ gamma0` — does not contain eta

So the disjuncts containing eta are D1 and D2. But we need to eliminate D1 and D2...

Wait, let me re-check the elimination logic. From the code comment (line 2385):
> "Eliminate D1, D2 using ¬U(beta0∧eta, gamma0)"

If D1 or D2 were true, we'd have an Until with event containing `eta` (D1 has `eta ∧ gamma0`, D2 has `eta ∧ ...`). Combined with `beta0` in the guard, we'd get something related to `U(beta0 ∧ eta, ...)`. 

The monotonicity argument: if D1 or D2 is in A, then via left monotonicity we'd get `U(beta0 ∧ eta, gamma0) ∈ A`, contradicting `¬U(beta0 ∧ eta, gamma0) ∈ A`.

So D1 and D2 are eliminated, leaving D3.

But D3's event `(xi ∧ U(xi, eta)) ∧ gamma0` doesn't contain eta...

Unless... the guard of D3 contains `xi` and `U(xi, eta)`, and via some property we can derive eta from `U(xi, eta)` being in the guard and using BX9? But BX9 is removed as unsound.

Wait, I think I need to look at this from a different angle. The key is in **BX13 enrichment**.

From the code comment (lines 2387-2388):
> "BX13 iterated enrichment: packs S-formulas into event"

The enriched event formula is constructed via iterated BX13, which adds `snce(guard, alpha)` for each alpha in A. The guard of D3 contains `xi ∧ U(xi, eta) ∧ beta0 ∧ U(beta0, gamma0)`.

So the S-formula added would be `snce(xi ∧ U(xi, eta) ∧ beta0 ∧ U(beta0, gamma0), alpha)`.

For component 5, we need `snce(beta ∧ eta, alpha)`. The guard `xi ∧ U(xi, eta) ∧ beta0 ∧ U(beta0, gamma0)` implies `beta0` (via conjunction elimination), and if it also implies `eta`, we'd have `beta0 ∧ eta`.

But where does eta come from in D3's guard?

Actually, re-reading: D3's guard is `phi1 ∧ phi2` = `(xi ∧ U(xi, eta)) ∧ (beta0 ∧ U(beta0, gamma0))`. This contains `U(xi, eta)` which is the formula `xi U eta`. 

If the event (implied by the Until formula) contains formulas that imply eta, then...

Hmm, I think I'm getting confused about guards vs events. Let me clarify:

In `untl(φ, ψ)`:
- φ = guard (must hold at all intermediate points)
- ψ = eventuality (must hold at the witness point)

The **event** in the BX chain is the formula that BX10 extracts F(event) from. This event is the enriched formula constructed via BX13.

From `iterated_enrichment` (line 1218-1225):
```lean
private noncomputable def iterated_enrichment {A : Set Formula}
    (h_mcs : SetMaximalConsistent A)
    (guard : Formula) :
    (alphas : List Formula) → ... →
    (event : Formula) →
    Formula.untl guard event ∈ A →
    EnrichedEvent A guard event alphas
```

The `event` parameter is enriched. In our case, we'd start with `event = guard` (or some base event).

Wait, looking at `burgess_zeta_consistent` (line 1283-1284):
```lean
let evt := iterated_enrichment h_mcs_A q alpha_list h_alphas
  (Formula.and q (Formula.and b β).neg) h_sep
```

Here `q = b ∧ untl(b, γ)` is the guard, and the starting event is `q ∧ (b ∧ β).neg`.

So for Lemma 2.7:
- Guard = `phi1 ∧ phi2` = `(xi ∧ U(xi, eta)) ∧ (beta0 ∧ U(beta0, gamma0))`
- Starting event = something derived from the surviving BX7 disjunct

If D3 survives: `untl(phi1 ∧ phi2, phi1 ∧ theta) ∈ A`
So the starting event would be `phi1 ∧ theta` = `(xi ∧ U(xi, eta)) ∧ gamma0`.

Via BX13 enrichment, we'd add `snce(guard, alpha)` formulas.

The key question: **How do we get eta into the event formula?**

Looking at Teammate D's findings again:
> "After BX7 + BX13, the event contains xi (from the third disjunct). Then S(xi, α) can be derived... But the 5th component S(β ∧ eta, α) is handled via: the event implies beta ∧ eta (since the BX3 + BX13 chain packs S(β ∧ eta, α) using the S(xi, ...) formula and the fact that xi → beta ∧ eta via the U(xi, eta) formula)."

This suggests that the event formula itself doesn't directly contain `eta` as a conjunct. Instead, we derive `event → (beta ∧ eta)` via some implication chain, then use `snce_left_mono` to get from `snce(event, alpha)` to `snce(beta ∧ eta, alpha)`.

But wait, we need `⊢ event → (beta ∧ eta)`. The event is the enriched formula containing:
- Base: `phi1 ∧ theta` = `(xi ∧ U(xi, eta)) ∧ gamma0`
- Plus: `snce(guard, alpha_i)` for each alpha_i in the list

The guard is `phi1 ∧ phi2` = `(xi ∧ U(xi, eta)) ∧ (beta0 ∧ U(beta0, gamma0))`.

So the event contains `xi`, `U(xi, eta)`, `gamma0`, and various S-formulas.

If `⊢ xi → beta` and `⊢ U(xi, eta) → eta`... but `⊢ U(xi, eta) → eta` is NOT provable (BX9 is removed).

This is getting complex. Let me look for a different approach in the research reports...

From Teammate A's findings (report 52, line 251-252):
> "A version of the BX5+BX7+BX14 chain that incorporates xi to get eta into the event."

And from line 255:
> "The 5th component requires the BX7 (linear_until) application that produces eta in the event."

So the key is that the surviving BX7 disjunct's event MUST contain eta.

Let me re-examine BX7 with fresh eyes. Perhaps I need to apply BX7 differently...

Actually, looking at BX7's third disjunct: `(φ ∧ χ) U (φ ∧ θ)`

What if we swap the order of the Until formulas?

Input:
- `untl(phi2, psi2)` = `untl(beta0 ∧ U(beta0, gamma0), gamma0)`
- `untl(phi1, psi1)` = `untl(xi ∧ U(xi, eta), eta)`

Mapping to BX7 with χ = phi2, θ = psi2, φ = phi1, ψ = psi1:
- D1: `(phi2 ∧ phi1) U (psi2 ∧ psi1)` = `(beta0 ∧ U(beta0, gamma0) ∧ xi ∧ U(xi, eta)) U (gamma0 ∧ eta)` — contains eta!
- D2: `(phi2 ∧ phi1) U (psi2 ∧ phi1)` = ... U `(gamma0 ∧ (xi ∧ U(xi, eta)))`
- D3: `(phi2 ∧ phi1) U (phi2 ∧ psi1)` = ... U `((beta0 ∧ U(beta0, gamma0)) ∧ eta)` — contains eta!

Now D1 and D3 both contain eta!

If we can eliminate D1 and D2 (using the neg-until witness), then D3 survives and its event contains eta.

This seems more promising. Let me verify the elimination logic:

From Step 1, we have: `¬untl(beta0 ∧ eta, gamma0) ∈ A`

If D1 is true: `untl(combined_guard, gamma0 ∧ eta) ∈ A`
By right monotonicity: `untl(combined_guard, gamma0) ∈ A`
And the guard contains `beta0`, so by left monotonicity...

Actually, we need: if D1 is in A, then `untl(beta0 ∧ eta, gamma0) ∈ A`, contradiction.

D1: `untl(beta0 ∧ U(beta0, gamma0) ∧ xi ∧ U(xi, eta), gamma0 ∧ eta)`

Guard: `beta0 ∧ U(beta0, gamma0) ∧ xi ∧ U(xi, eta)`
Event: `gamma0 ∧ eta`

If this is in A, by left monotonicity (strengthening guard to `beta0 ∧ eta`):
`untl(beta0 ∧ eta, gamma0 ∧ eta) ∈ A`

By right monotonicity (weakening event from `gamma0 ∧ eta` to `gamma0`):
`untl(beta0 ∧ eta, gamma0) ∈ A`

This contradicts `¬untl(beta0 ∧ eta, gamma0) ∈ A`!

So D1 is eliminated.

Now for D2:
D2: `untl(beta0 ∧ U(beta0, gamma0) ∧ xi ∧ U(xi, eta), gamma0 ∧ (xi ∧ U(xi, eta)))`

Event: `gamma0 ∧ xi ∧ U(xi, eta)`

We need: if D2 is in A, derive contradiction with `¬untl(beta0 ∧ eta, gamma0) ∈ A`.

This is trickier. The event has `xi` and `U(xi, eta)`, but not `eta` directly.

Hmm, this might not give the right contradiction...

Let me check if D2 can be eliminated another way. From Teammate A:
> "Eliminate D1, D2 using ¬U(beta0∧eta, gamma0)"

Perhaps the elimination of D2 uses a different argument. Let me think...

Actually, looking at the event of D2: `gamma0 ∧ xi ∧ U(xi, eta)`.

If this Until is in A, then by BX10: `F(gamma0 ∧ xi ∧ U(xi, eta)) ∈ A`.

I'm not sure how this directly contradicts `¬untl(beta0 ∧ eta, gamma0) ∈ A`.

Perhaps D2 is eliminated because the event doesn't give us what we need, or via a different contradiction...

Alternatively, perhaps the order of elimination is: D1 is eliminated via the neg-until contradiction, and D2 is eliminated because if it were true, it would imply something inconsistent or not useful for our purpose.

Actually, looking more carefully at the problem: we need to show the seed is consistent. The event from BX7+BX13+BX10 chain gives us F(event) ∈ A, which means the event is consistent (in a consistent A). We then use this to show each component of the seed is consistent.

So perhaps D2 is not "eliminated by contradiction" but rather "doesn't help prove consistency". If D2 were the true disjunct, the event wouldn't contain eta, and we couldn't prove component 5.

This interpretation makes more sense: in an MCS A, exactly one of D1, D2, D3 holds (by disjunction property + consistency). We show:
- If D1 holds: contradiction with `¬untl(beta0 ∧ eta, gamma0)`
- If D2 holds: the resulting event doesn't imply component 5 (no eta)
- So D3 must hold, giving us an event with eta

This is more of a "case analysis" than pure contradiction elimination.

Let me verify this interpretation against the code comments...

From line 2385: "Eliminate D1, D2 using ¬U(beta0∧eta, gamma0)"

The word "eliminate" suggests contradiction, not just "doesn't help". But perhaps it's a shorthand for "show that D1 leads to contradiction and D2 doesn't help, leaving D3 as the useful case".

Given the complexity, the implementation should:
1. Set up the three cases via `linear_until_mcs`
2. Case D1: Derive contradiction with neg-until
3. Case D2: Show the event doesn't contain eta (so can't prove component 5) — or find another contradiction
4. Case D3: Use this as the "surviving" case

### Step 5: Disjunct elimination

**Helper lemma needed**:

```lean
private theorem lemma_2_7_disjunct_elimination {A : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (beta0 gamma0 xi eta : Formula)
    (h_neg_until : (Formula.untl (Formula.and beta0 eta) gamma0).neg ∈ A)
    (h_D1 : Formula.untl (Formula.and (Formula.and (Formula.and beta0 (Formula.untl beta0 gamma0)) xi) 
                                      (Formula.untl xi eta))
                        (Formula.and gamma0 eta) ∈ A) :
    False := by
  -- D1: guard = beta0 ∧ U(beta0,gamma0) ∧ xi ∧ U(xi,eta)
  --      event = gamma0 ∧ eta
  -- Left monotonicity: guard → beta0 ∧ eta
  -- Right monotonicity: (gamma0 ∧ eta) → gamma0
  -- So: U(beta0 ∧ eta, gamma0) ∈ A, contradiction
  sorry
```

**Estimated lines**: ~30 lines

### Step 6: Surviving D3 event

D3: `untl(combined_guard, (beta0 ∧ U(beta0, gamma0)) ∧ eta) ∈ A`

Event: `(beta0 ∧ U(beta0, gamma0)) ∧ eta` — **contains both beta0 and eta!**

### Step 7: BX14 separation

Not needed if D3 directly gives the right structure. Or: use BX14 if we need to add the negation of some formula.

Actually, looking at the code comments again (line 2387):
> "BX14 separation with ¬U(beta0∧eta, gamma0)"

This suggests we DO use BX14. Perhaps the flow is:
1. D3 gives: `untl(guard, event) ∈ A` where event contains beta0 and eta
2. BX14 with `¬untl(beta0 ∧ eta, gamma0)` gives a refined Until formula

Let me check what BX14 does:

```lean
| separation_until (p q r : Formula) :
    Axiom (Formula.untl q p |>.imp
      ((Formula.untl r p).neg.imp (Formula.untl q (q.and r.neg))))
```

BX14: `U(q, p) → (¬U(r, p) → U(q, q ∧ ¬r))`

With q = combined_guard, p = event, r = beta0 ∧ eta:
- `U(combined_guard, event) ∈ A` (from D3)
- `¬U(beta0 ∧ eta, event) ∈ A`? 

Wait, we have `¬U(beta0 ∧ eta, gamma0) ∈ A`, not `¬U(beta0 ∧ eta, event) ∈ A`.

Hmm, the second parameter of the Until in the negation must match...

Actually, looking at the code comment (line 2384-2387):
> "BX7 linear_until: three-way disjunction D1∨D2∨D3
> Eliminate D1, D2 using ¬U(beta0∧eta, gamma0)
> Surviving D3 gives event with guard containing xi, U(xi,eta), beta0, and eta"

So the surviving event from D3 contains:
- xi
- U(xi, eta)
- beta0
- eta

If the event contains all of these, then we can use it directly for enrichment.

### Step 8: BX13 iterated enrichment

```lean
let evt := iterated_enrichment h_mcs_A guard alpha_list h_alphas event h_untl
```

This enriches the event with `snce(guard, alpha)` for each alpha in A.

### Step 9: BX10 extraction

```lean
have h_F_event : Formula.some_future event ∈ A :=
  until_implies_F_mcs h_mcs_A h_untl_enriched
```

### Step 10: Event implies all 5 seed components

For component 5 (`snce(beta ∧ eta, alpha)`):
- Enriched event implies `snce(guard, alpha)`
- Guard contains `beta0` and `eta` (from D3's event)
- So `guard → (beta0 ∧ eta)` 
- By left monotonicity: `snce(guard, alpha) → snce(beta0 ∧ eta, alpha)`
- For any `beta ∈ B`, use `beta0` as the witness (or show all betas in B are implied)

Actually, we need: for all `beta ∈ B`, `snce(beta ∧ eta, alpha)` is implied.

The guard from D3 contains `beta0` (a specific beta from B), not arbitrary beta. So the enriched event gives `snce(beta0 ∧ eta, alpha)`.

For an arbitrary `beta ∈ B`, we need to relate `snce(beta0 ∧ eta, alpha)` to `snce(beta ∧ eta, alpha)`.

Hmm, this is a gap. Perhaps the seed consistency proof shows that the event implies `snce(beta ∧ eta, alpha)` for the specific `beta0` we extracted, and then uses the fact that the seed requires this for ALL beta ∈ B...

Actually, looking at the seed definition again:
```lean
{φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce (Formula.and β eta) α}
```

For each specific pair (beta, alpha), we need to show the formula is in the MCS D we construct. The event-based consistency proof shows that a finite subset of the seed is consistent by showing the event implies each formula in the subset.

So for a finite subset containing `snce(beta1 ∧ eta, alpha1)`, `snce(beta2 ∧ eta, alpha2)`, etc., we'd need an event that implies ALL of them. The approach might be:
1. Use a single beta0 for all formulas, OR
2. Chain multiple BX applications for each beta

Given the complexity, the implementation likely uses a single beta0 (extracted in Step 1) and shows the event implies `snce(beta0 ∧ eta, alpha)` for all alpha in a finite list.

For the full seed consistency, we need to handle arbitrary finite subsets, which might require multiple iterations or a different approach.

Actually, looking at `burgess_zeta_consistent` (line 1245-1271), it handles ONE specific zeta formula. For the full seed, we'd need to generalize this to handle arbitrary finite subsets.

---

## 2. The 10-Step BX7 Chain (Revised)

Based on the analysis, here is the corrected step-by-step proof:

### Prerequisites

**Helper lemma to implement**:
```lean
-- Extract beta0, gamma0 with neg-until from maximality
private theorem lemma_2_7_neg_untl_exists {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (eta : Formula)
    (h_eta_not_B : eta ∉ B)
    (h_F_eta : Formula.some_future eta ∈ A) :
    ∃ β₀ ∈ B, ∃ γ₀ ∈ C, (Formula.untl (Formula.and β₀ eta) γ₀).neg ∈ A
```

**BX7 MCS wrapper to implement**:
```lean
-- BX7 at MCS level: produces three-way disjunction membership
private theorem linear_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A)
    {phi1 psi1 phi2 psi2 : Formula}
    (h_until1 : Formula.untl phi1 psi1 ∈ A)
    (h_until2 : Formula.untl phi2 psi2 ∈ A) :
    -- Returns proof that D1 ∨ D2 ∨ D3 ∈ A
    Formula.or (Formula.or
      (Formula.untl (Formula.and phi1 phi2) (Formula.and psi1 psi2))
      (Formula.untl (Formula.and phi1 phi2) (Formula.and psi1 phi2)))
      (Formula.untl (Formula.and phi1 phi2) (Formula.and phi1 psi2)) ∈ A := by
  sorry
```

### The 10 Steps

| Step | Action | Axiom/Lemma | Output |
|------|--------|-------------|--------|
| 1 | Extract neg-until witness | `lemma_2_7_neg_untl_exists` | `β₀ ∈ B`, `γ₀ ∈ C`, `¬untl(β₀ ∧ eta, γ₀) ∈ A` |
| 2 | BX5 on `untl(xi, eta)` | `self_accum_until_mcs` | `untl(xi ∧ untl(xi,eta), eta) ∈ A` |
| 3 | BX5 on `untl(beta₀, gamma₀)` | `self_accum_until_mcs` | `untl(beta₀ ∧ untl(beta₀,gamma₀), gamma₀) ∈ A` |
| 4 | BX7 on the two enriched Untils | `linear_until_mcs` | `D1 ∨ D2 ∨ D3 ∈ A` |
| 5 | Case analysis on D1/D2/D3 | `SetMaximalConsistent.disjunction_property` | Which disjunct holds |
| 6a | If D1: derive contradiction | `untl_left_mono_mcs`, `untl_right_mono_mcs` | `False` (via `¬untl(beta₀ ∧ eta, gamma₀)`) |
| 6b | If D2: derive contradiction | (monotonicity chain) | `False` |
| 7 | So D3 holds | Elimination of D1, D2 | `untl(combined_guard, (beta₀ ∧ untl(beta₀,gamma₀)) ∧ eta) ∈ A` |
| 8 | BX13 enrichment (iterated) | `iterated_enrichment` | Enriched event with `snce(guard, alpha)` for all alpha in finite list |
| 9 | BX10 extraction | `until_implies_F_mcs` | `F(enriched_event) ∈ A` |
| 10 | Show event implies seed components | Implication chains, `snce_left_mono_mcs` | Each of 5 components is implied |

---

## 3. Required Helper Lemmas

### 3.1 New Lemmas to Implement

| Lemma | Signature | Lines | Purpose |
|-------|-----------|-------|---------|
| `lemma_2_7_neg_untl_exists` | Extract `β₀, γ₀, ¬untl(β₀∧eta, γ₀)` from `eta ∉ B` | ~40 | Step 1 witness extraction |
| `linear_until_mcs` | BX7 at MCS level (3-way disjunction) | ~15 | Step 4 BX7 application |
| `lemma_2_7_disjunct_elim_D1` | D1 + `¬untl(β₀∧eta, γ₀)` → contradiction | ~25 | Step 6a elimination |
| `lemma_2_7_disjunct_elim_D2` | D2 + `¬untl(β₀∧eta, γ₀)` → contradiction | ~25 | Step 6b elimination |

### 3.2 Existing Available Lemmas

| Lemma | Location | Purpose |
|-------|----------|---------|
| `self_accum_until_mcs` | line 189 | Step 2, 3: BX5 |
| `iterated_enrichment` | line 1218 | Step 8: BX13 chain |
| `until_implies_F_mcs` | line 1000 | Step 9: BX10 extraction |
| `snce_left_mono_thm` | line 1054 | Step 10: monotonicity for component 5 |
| `burgessR3` accessors | ChronicleTypes.lean | Extract Until/Since formulas |
| `conj_mcs` | line 210 | Conjunction in MCS |

---

## 4. Complete Proof Architecture

```lean
private theorem lemma_2_7_seed_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta ∈ A)
    (h_eta_not_B : eta ∉ B) :
    SetConsistent (lemma_2_7_seed A B C xi eta) := by
  
  -- Step 1: Extract neg-until witness
  have h_F_eta : Formula.some_future eta ∈ A := 
    until_implies_F_mcs h_mcs_A xi eta h_until
  obtain ⟨beta0, h_beta0, gamma0, h_gamma0, h_neg_until⟩ := 
    lemma_2_7_neg_untl_exists h_mcs_A h_mcs_C h_r3m eta h_eta_not_B h_F_eta
  
  -- For any finite subset L of the seed, prove consistency
  intro L hL_subset
  -- Extract components from L...
  -- Construct the event via BX chain...
  
  -- Steps 2-3: BX5 self-accumulation
  have h_bx5_1 := self_accum_until_mcs h_mcs_A xi eta h_until
  have h_untl_bg := h_r3m.2.1.1 beta0 h_beta0 gamma0 h_gamma0
  have h_bx5_2 := self_accum_until_mcs h_mcs_A beta0 gamma0 h_untl_bg
  
  -- Step 4: BX7 three-way disjunction
  have h_bx7 := linear_until_mcs h_mcs_A h_bx5_1 h_bx5_2
  
  -- Steps 5-7: Eliminate D1, D2; use D3
  rcases SetMaximalConsistent.disjunction_property h_mcs_A h_bx7 with (h_D1 | h_D2 | h_D3)
  · -- Case D1: contradiction
    exfalso
    exact lemma_2_7_disjunct_elim_D1 h_mcs_A beta0 gamma0 xi eta h_neg_until h_D1
  · -- Case D2: contradiction  
    exfalso
    exact lemma_2_7_disjunct_elim_D2 h_mcs_A beta0 gamma0 xi eta h_neg_until h_D2
  · -- Case D3: the surviving disjunct
    -- Step 8: BX13 enrichment with alpha_list from L
    -- Step 9: BX10 extraction
    -- Step 10: Show event implies all formulas in L
    sorry
```

---

## 5. Risks and Complexities

### 5.1 High-Risk Areas

1. **D2 elimination**: The elimination of D2 may require a subtle argument not yet identified. The research reports don't provide the exact derivation.

2. **Component 5 for arbitrary beta**: The current analysis uses a single `beta0` extracted from maximality. The seed requires `snce(beta ∧ eta, alpha)` for ALL `beta ∈ B`. Handling arbitrary finite subsets with varying betas may require additional machinery.

3. **BX7 ≠ A7a adaptation**: Our BX7 has different disjuncts than Burgess's A7a. The proof adaptation is theoretically sound (as noted by teammates A and D), but the formal verification is non-trivial.

### 5.2 Medium-Risk Areas

1. **Disjunction property application**: `SetMaximalConsistent.disjunction_property` gives `(P ∨ Q) ∈ A → P ∈ A ∨ Q ∈ A`. For the 3-way disjunction from BX7, nested application is needed.

2. **Event implication chains**: Proving that the enriched event implies each seed component requires careful management of implication derivations.

### 5.3 Mitigation Strategies

1. **Incremental implementation**: Implement and test each step separately before integration.
2. **Leverage existing patterns**: `burgess_zeta_consistent` provides the template for Steps 8-10.
3. **Consult Teammate A/D findings**: Reports 52 contain detailed analysis that can guide implementation.

---

## 6. Estimated Effort

| Task | Estimated Lines | Estimated Time |
|------|-----------------|----------------|
| `lemma_2_7_neg_untl_exists` | 40 lines | 1 hour |
| `linear_until_mcs` | 15 lines | 0.5 hours |
| `lemma_2_7_disjunct_elim_D1` | 25 lines | 1 hour |
| `lemma_2_7_disjunct_elim_D2` | 25 lines | 1.5 hours |
| `lemma_2_7_seed_consistent` integration | 80 lines | 1 hour |
| **Total** | **~185 lines** | **~5 hours** |

**Matches plan v52 estimate**: Yes (5 hours).

---

## 7. Dependencies on Other Phases

- **Phase 2 (completed)**: `burgess_D0_seed_consistent` provides the template for BX5+BX14+BX13+BX10 chains.
- **Phase 4 (pending)**: Uses `lemma_2_7` for C4/C4' hard cases. Closing this sorry unblocks Phase 4.
- **Phase 5+**: Chronicle construction depends on Lemma 2.7 for eta insertion.

---

## 8. References

1. **Burgess 1982**: "Basic tense logic", Section 2.7 (p. 372), Lemma 2.7
2. **PointInsertion.lean**: Lines 2372-2400 (seed definition, sorry stub)
3. **Axioms.lean**: Lines 226-236 (BX7 definition)
4. **Report 52 (Teammate A)**: Detailed BX7 analysis and disjunct elimination
5. **Report 52 (Teammate D)**: 10-step chain breakdown, component 5 analysis
6. **Plan v52**: Phase 3 specification with effort estimates

---

## 9. Conclusion

The `lemma_2_7_seed_consistent` proof is a sophisticated application of the BX7 (linear_until) axiom requiring a 10-step chain. The key insights are:

1. **BX7 produces a 3-way disjunction** with different events in each disjunct
2. **D1 and D2 are eliminated** via monotonicity contradictions with `¬untl(beta₀ ∧ eta, gamma₀)`
3. **D3 survives**, providing an event containing both `beta₀` and `eta`
4. **BX13 enrichment** packs S-formulas with a guard containing `beta₀ ∧ eta`
5. **Component 5** follows via left monotonicity of Since

The main blocker is the **missing `linear_until_mcs` helper** (BX7 at MCS level). Once this is implemented, the remaining steps follow the established pattern from Phase 2's `burgess_zeta_consistent`.

**Estimated effort**: 5 hours  
**Confidence**: High (architecture is clear from research reports)  
**Risk level**: Medium (D2 elimination needs careful verification)

---

*Report prepared by Research Teammate B for Task 107 Phase 3.*
