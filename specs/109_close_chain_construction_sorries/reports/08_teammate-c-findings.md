# Teammate C (Critic) Findings — Round 8

**Task 109**: Close 3 remaining sorry sites in RootScopedChain.lean
**Role**: Critical analysis — challenge assumptions, verify claims, find structural alternatives
**Date**: 2026-04-21

---

## Executive Summary

After exhaustive reading of the codebase, I have identified the **precise mathematical
obstruction** for each sorry, verified or disproved every prior claim, and found that
the obstruction is real. However, I also found that **sorry #2 (backward until/since)**
is fundamentally different from #1 and #3 — it does not require F-resolution at all.
The prior framing conflated three distinct problems.

---

## Section 1: Verification of Prior Claims

### Claim 1: "Lindenbaum opacity" is the core problem for temporal coherence

**Status: CONFIRMED, but with a critical refinement**

The definition of `fwd_succ` (CanonicalModel.lean, lines 46-52) shows:
- When `F(ψ) ∈ M`: seed = `{ψ} ∪ g_content(M)`, extended by Lindenbaum
- When `F(ψ) ∉ M`: seed = `g_content(M)`, extended by Lindenbaum

`g_content(M)` is defined as `{φ | G(φ) ∈ M}`. This is the KEY DEFINITION.

The prior framing says "Lindenbaum can introduce G(¬φ)." This is correct but
the chain of reasoning should be stated more precisely:

1. Suppose `F(φ) ∈ chain(n)` but the schedule targets ψ ≠ φ at step n.
2. Then `F(ψ) ∈ chain(n)`, so the seed = `{ψ} ∪ g_content(chain(n))`.
3. `F(φ) ∈ g_content(chain(n))` iff `G(F(φ)) ∈ chain(n)`.
4. If `G(F(φ)) ∉ chain(n)`, then F(φ) is NOT in the seed.
5. Lindenbaum freely adds consistent formulas. It COULD add G(¬φ) or ¬F(φ).
6. If ¬F(φ) ∈ chain(n+1), then by `fwd_chain_F_not_return` (proven in RootScopedChain.lean),
   F(φ) never returns. If φ never appeared before step n, F(φ) is permanently lost.

So the question reduces to: **Is G(F(φ)) ∈ chain(n) whenever F(φ) ∈ chain(n)?**

### Claim 2: The Critical Question — Is G(F(φ)) ∈ M when F(φ) ∈ M?

**Status: DEFINITIVELY FALSE in BX under irreflexive semantics**

Under irreflexive semantics:
- `F(φ) = ¬G(¬φ)` means "there exists s > t such that φ(s)"
- `G(F(φ))` means "for all s > t, there exists r > s such that φ(r)"

These are NOT equivalent. F(φ) says φ appears once in the future. G(F(φ)) says φ
appears infinitely often (cofinitely). These are different truth conditions on ℤ.

**Axiom check — BX5 (self-accumulation)**: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`
This is about Until, not F. Does not give G(F(φ)) from F(φ).

**BX4 (connect_future)**: `φ → G(P(φ))`. Does not help.

**temp_4 (BX transitivity)**: `G(φ) → G(G(φ))`. This gives G(G(F(φ))) from G(F(φ)),
but does not give G(F(φ)) from F(φ).

**Is F(φ) → G(F(φ)) derivable in BX?**
The answer is NO. This would require "F is permanent once it holds" — the "Henceforth-Eventually"
property — which is NOT a theorem of BX (or any reasonable temporal logic on linear orders
without additional density/completeness assumptions). It is specifically NOT SOUND on ℤ:
take φ = atom at time 0 only. Then F(φ) holds at t = -1 but G(F(φ)) fails at t = -1.

**CONCLUSION FOR THE CORE OBSTRUCTION**: The Lindenbaum opacity framing is correct.
F(φ) is not in the seed g_content(M) when G(F(φ)) ∉ M, which happens whenever F(φ)
is a transient eventuality (holds once, not always-eventually). This is not a gap in the
proof technique — it is a genuine incompatibility between g_content-based chain construction
and F-obligation resolution.

### Claim 3: `defect_one_step_preservation` for fwd_succ

**Status: Does NOT hold for fwd_succ — only for the archived defect-directed chain**

The question was: Is there an analog of defect_one_step_preservation for `fwd_succ`?
The answer is definitively NO. `fwd_succ` at step n only resolves `schedule(n)`. For all
other formulas ψ ≠ schedule(n), `fwd_succ` makes NO guarantee. The seed is
`{schedule(n)} ∪ g_content(chain(n))`, and g_content does not include F(ψ) for ψ
whose G(F(ψ)) is not in the chain. So F(ψ) can disappear without ψ ever appearing.

### Claim 4: BX12 does not help

**BX12**: `F(φ) → (⊤ U φ)`

Let us evaluate this carefully. BX12 says F(φ) implies ⊤ U φ. This means there exists
s > t with φ(s) and ⊤ on [t,s). This is essentially just restating F(φ) in Until form
with vacuous guard. It provides no extra structural information.

Could we use BX12 to construct a different seed? E.g., seed = `{φ} ∪ g_content(M) ∪ (⊤ U φ-related content)`?

The issue is: BX12 gives `(⊤ U φ) ∈ M` from `F(φ) ∈ M`. But `⊤ U φ ∈ M` doesn't
help the Lindenbaum step either — the question is whether φ itself appears in the
successor, and we still need to use F-resolution (which is what we are trying to prove).
BX12 converts F to Until but doesn't break the opacity barrier. **The prior claim is correct.**

### Claim 5: Backward Until (sorry #2) "may need semantic completeness approach"

**Status: WRONG — sorry #2 is FUNDAMENTALLY DIFFERENT from sorry #1**

Reading TemporalCoherence.lean carefully, `backward_until_since_coherent` requires:

```
∀ t : D, ∀ φ ψ : Formula,
  (∃ s : D, t < s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t ≤ r → r < s → φ ∈ fam.mcs r) →
  Formula.untl φ ψ ∈ fam.mcs t
```

This says: **given a witness pattern already in the MCS chain, derive the Until formula**.
This is the BACKWARD direction of the truth lemma — it does NOT require F-resolution.
It requires a step-transfer property: `(φ U ψ) ∈ fam.mcs (r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`.

The `backward_until_from_step` theorem in UntilSinceCoherence.lean already handles
the full backward induction GIVEN the step property. The question is purely:
**does the schedule-based chain satisfy this step property?**

This is a DIFFERENT problem from F-resolution. The step property says: if (φ U ψ) is in
chain(n+1) and φ is in chain(n), can we derive (φ U ψ) in chain(n)?

For the schedule-based chain, the answer depends on what axioms we can apply.
Crucially: **h_content gives us backward propagation**. If H(φ U ψ) ∈ chain(n+1),
then (φ U ψ) ∈ chain(n) by `int_chain_backward_H`. But H(φ U ψ) is not the same
as (φ U ψ).

### Claim 6: The backward_until step transfer property

**The precise question for sorry #2**: Does the following hold for `shifted_bx_fmcs`?

```
(φ U ψ) ∈ (shifted_bx_fmcs M₀ h₀ s).mcs (r + 1) ∧
φ ∈ (shifted_bx_fmcs M₀ h₀ s).mcs r →
(φ U ψ) ∈ (shifted_bx_fmcs M₀ h₀ s).mcs r
```

Unpacking: `(shifted_bx_fmcs M₀ h₀ s).mcs t = int_chain M₀ h₀ (t - s)`.
So we need: `(φ U ψ) ∈ int_chain M₀ h₀ (r + 1 - s) ∧ φ ∈ int_chain M₀ h₀ (r - s) → (φ U ψ) ∈ int_chain M₀ h₀ (r - s)`.

Let n = r - s. We need: `(φ U ψ) ∈ int_chain M₀ h₀ (n + 1) ∧ φ ∈ int_chain M₀ h₀ n → (φ U ψ) ∈ int_chain M₀ h₀ n`.

This is NOT provided by the g_content/h_content propagation in the schedule-based chain.
The h_content backward propagation gives: `H(α) ∈ chain(n+1) → α ∈ chain(n)`.
But `H(φ U ψ)` is not `(φ U ψ)`.

Can we derive `(φ U ψ) ∈ chain(n)` from `(φ U ψ) ∈ chain(n+1)` and `φ ∈ chain(n)`?

The BX axiom `or_until_imp`: `(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`. But this requires
`φ U ψ` to be INSIDE the MCS at chain(n+1) and then apply it locally — it's a theorem
of chain(n), not a way to pull (φ U ψ) from chain(n+1) into chain(n).

The key insight: **the backward step transfer is not available for the schedule-based chain
for the same fundamental reason as F-resolution** — the Lindenbaum extension at each step
makes no commitment to preserve Until formulas that do not appear in the g_content seed.

Wait — let me reconsider more carefully. What is `restricted_backward_until_since_coherent`?

From TemporalCoherence.lean line 565:
```
def BFMCS.restricted_backward_until_since_coherent (B : BFMCS D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl φ ψ ∈ Bimodal.Syntax.subformulaClosure root →
      (∃ s : D, t < s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t ≤ r → r < s → φ ∈ fam.mcs r) →
      Formula.untl φ ψ ∈ fam.mcs t) ∧ ...
```

And this is what `dd_countermodel` actually uses via `fully_restricted_parametric_representation_from_neg_membership`.

So the backward direction says: GIVEN that ψ ∈ chain(s), φ ∈ chain(r) for t ≤ r < s,
DERIVE (φ U ψ) ∈ chain(t). This needs an `until_intro` mechanism.

Looking at UntilSinceCoherence.lean more carefully: `backward_until_reflexive` uses
`psi_imp_until`, which is **marked sorry** in TemporalDerived.lean! The comment says
"Under irreflexive semantics, ψ → (φ U ψ) is NOT valid."

So the base case of backward_until_from_step itself relies on `backward_until_reflexive`
which requires `psi_imp_until`, which is sorry'd due to irreflexive semantics!

**CRITICAL FINDING**: The ENTIRE backward until/since infrastructure relies on `psi_imp_until`
(ψ → (φ U ψ)) which is NOT valid under irreflexive Until semantics. Under irreflexive Until,
the witness must be at a STRICTLY FUTURE time, so ψ at current time does NOT witness (φ U ψ).

This means the architecture of UntilSinceCoherence.lean is fundamentally broken for the
irreflexive case: `backward_until_reflexive` cannot be proved.

---

## Section 2: The Precise Mathematical Problems

### Problem 1: Temporal Coherence (sorry #1) — `bx_bfmcs_restricted_tc`

**What is needed**: For each family (i.e., each `shifted_bx_fmcs N h_N s`), for each
formula φ ∈ deferralClosure(root), if F(φ) ∈ fam.mcs(t), there exists u > t with φ ∈ fam.mcs(u).

**The precise obstruction**: The schedule-based chain guarantees only that schedule(n) = φ
is targeted infinitely often (by `schedule_surjective_above`). But when schedule(n) = φ,
`fwd_succ` resolves F(φ) by placing φ in chain(n+1) — BUT ONLY if F(φ) ∈ chain(n) at that
point. If F(φ) was present at some earlier step m but dropped by step n (the first time
the schedule hits φ), then chain(n) has ¬F(φ), and `fwd_succ` takes the non-resolving branch.

By `fwd_chain_F_not_return`, once F(φ) drops, it never returns. So if F(φ) is present
at step m but the schedule hasn't hit φ yet, F(φ) might drop before the schedule does.

**The key missing lemma**: What is needed is that F(φ) is preserved from step m to the
first step where schedule(n) = φ. This would require G(F(φ)) ∈ chain(m), which requires
F(φ) → G(F(φ)) — NOT derivable in BX.

**Exact Lean statement needed**:
```lean
-- F-obligations persist until targeted by schedule
theorem fwd_chain_F_persists (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (φ : Formula) (m : Nat) (h_F : Formula.some_future φ ∈ (fwd_chain M₀ h₀ m).val) :
    ∃ n : Nat, n ≥ m ∧ schedule n = φ ∧ φ ∈ (fwd_chain M₀ h₀ (n + 1)).val
```

This is the missing lemma and it CANNOT be proved with the current g_content seed
approach because F-obligations are not preserved by g_content.

### Problem 2: Backward Until/Since (sorry #2) — `bx_bfmcs_restricted_buc`

**What is needed**: The step-transfer property for backward Until induction, AND
the base case `backward_until_reflexive` (ψ ∈ chain(t) → (φ U ψ) ∈ chain(t)).

**DOUBLE obstruction**:

1. `psi_imp_until` is sorry'd because ψ → (φ U ψ) is NOT valid under irreflexive Until
   semantics. The BX axiom system under irreflexive Until (half-open guard [t,s) with
   strict s > t) does not have this as a theorem.

2. Even if the base case were available, the step transfer requires:
   `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`
   This is not derivable from g_content/h_content propagation alone.

**Exact Lean statement needed** (what would fix it):
```lean
-- Step transfer for backward Until
theorem fwd_succ_until_step (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
    (φ χ : Formula)
    (h_until : Formula.untl φ χ ∈ fwd_succ M h_mcs ψ)
    (h_phi : φ ∈ M) :
    Formula.untl φ χ ∈ M
```

This is also not provable with the current construction.

### Problem 3: Forward Until/Since (sorry #3) — `bx_bfmcs_restricted_fuc`

**What is needed**: `(φ U ψ) ∈ fam.mcs(t) → ∃ s > t, ψ ∈ fam.mcs(s) ∧ ∀ r ∈ [t,s), φ ∈ fam.mcs(r)`

**The precise obstruction**: This requires BOTH:
(a) An F-resolution witness (find s where ψ appears) — same as Problem 1
(b) Guard condition (φ holds at ALL r ∈ [t,s)) — STRONGER than Problem 1

Even if F-resolution worked (problem a), the guard condition (problem b) requires that
φ is in every chain member between t and the witness s. This is NOT guaranteed by
g_content propagation. Only G(φ) ∈ chain(t) would give φ in all future steps, and
we don't have G(φ) from (φ U ψ).

The guard condition is the distinctive difficulty of forward_fuc vs. forward_F alone.
BX9 gives (φ U ψ) → (φ ∨ ψ), so φ ∈ chain(t) (assuming ψ ∉ chain(t)). But at
chain(t+1), chain(t+2), ..., we have no direct guarantee that φ persists until the ψ-witness.

---

## Section 3: The Lindenbaum Opacity Analysis

**Is the Lindenbaum opacity framing correct?**

Yes, and here is the precise version:

When `fwd_succ M h_mcs ψ` is called with F(φ) ∈ M and schedule(n) = ψ ≠ φ:
- Seed = `{ψ} ∪ g_content(M)`
- F(φ) ∈ seed iff G(F(φ)) ∈ M [by definition of g_content]
- G(F(φ)) ∈ M iff F(φ) → G(F(φ)) is derivable AND F(φ) ∈ M — but this axiom does NOT hold

When G(F(φ)) ∉ M (the generic case), F(φ) is not in the seed. Lindenbaum then
extends g_content(M) to an MCS, which may or may not contain F(φ). If ¬F(φ) = G(¬φ) is
consistent with the seed (which it may be, since G(¬φ) ∈ g_content(N) for some compatible N),
then Lindenbaum might produce a successor where F(φ) is absent.

In fact, by seriality (BX1: serial_future), every MCS M has F(⊤) ∈ M. But this
only guarantees the existence of a future point, not the persistence of specific F-obligations.

**Does G(F(φ)) failing mean there IS a specific problem MCS?**

Yes. If G(F(φ)) ∉ M, then F(G(¬φ)) ∈ M (by MCS duality). This means G(¬φ) will
appear at some future point in the chain. Once G(¬φ) ∈ chain(k), all subsequent
steps have ¬φ via g_content propagation, making φ permanently absent after step k.
Between step n (where F(φ) ∈ chain(n)) and k, F(φ) might already have dropped.

There is a window between n and k where things could work, but the schedule may not
target φ within this window.

---

## Section 4: What Could Actually Work

### Option A: Enriched Seed

Include F-obligations directly in the seed:

```lean
fwd_succ_enriched M h_mcs ψ :=
  set_lindenbaum ({ψ} ∪ g_content M ∪ f_content M) consistent_proof
```

where `f_content M = {φ | F(φ) ∈ M}`.

**Problem**: Is `{ψ} ∪ g_content(M) ∪ f_content(M)` consistent? For the g_content part,
yes (proven). For f_content: suppose φ ∈ f_content(M), i.e., F(φ) ∈ M. Can φ be in the
seed? The seed consistency proof in WitnessSeed.lean shows `{ψ} ∪ g_content(M)` is consistent
when F(ψ) ∈ M. The same argument would show `{φ} ∪ g_content(M)` is consistent when F(φ) ∈ M.

**But the combined set `{ψ} ∪ g_content(M) ∪ f_content(M)` may be INCONSISTENT**.
If F(φ) ∈ M and F(¬φ) ∈ M simultaneously (which is possible in an MCS where neither
φ nor ¬φ is universal), then both φ and ¬φ would be in f_content, making the seed
inconsistent. So the enriched seed approach fails.

### Option B: Schedule-Synchronized Chain

Use the schedule to build the chain, but guarantee that when schedule(n) = φ and F(φ) ∈ chain(m)
for some m ≤ n, then F(φ) ∈ chain(n). This requires inductive tracking of which F-obligations
are still "alive" at each step, which amounts to what BX11 (temp_linearity) was supposed to help with.

This approach is equivalent to the defect-directed chain that was already abandoned.

### Option C: Completely Different Proof Architecture

The BFMCS/FMCS approach requires the schedule-based chain to satisfy three independent
coherence conditions simultaneously. The codebase comments on RootScopedChain.lean
(lines 33-40) already acknowledge this:

> Resolving this requires either:
> (a) An enriched seed that includes all F-obligations at each step (blocked by BX11 opacity)
> (b) A deterministic chain construction that controls exactly which formulas appear
> (c) A completely different proof strategy (e.g., semantic methods)

**Alternative: Filtration-based completeness**. The standard approach for Until/Since logics
over linear orders (Burgess-Goldblatt) uses filtration rather than canonical model construction.
Filtration quotients the full canonical model by the finite subformula set, making the
temporal structure finite and directly verifiable. This would bypass the infinite chain
F-obligation problem entirely.

**Alternative: Dovetailing with a bounded formula set**. Since `restricted_temporally_coherent`
only requires coherence for formulas in `deferralClosure(root)`, and this is a finite set,
one could build a chain that specifically resolves all F-obligations in this finite set
in each omega-block. This is a dovetailed/diagonal construction with a finite obligation set.

---

## Section 5: Key Contradiction Found in Prior Research Architecture

**psi_imp_until is sorry'd and it is used in the backward Until infrastructure**

Looking at TemporalDerived.lean lines 232-244:
```lean
def psi_imp_until (φ ψ : Formula) :
    ⊢ ψ.imp (Formula.untl φ ψ) := by
  -- Under irreflexive semantics, ψ → (φ U ψ) is NOT valid.
  sorry
```

And in UntilSinceCoherence.lean lines 81-84, `backward_until_reflexive` uses this:
```lean
theorem backward_until_reflexive {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_psi : ψ ∈ M) : Formula.untl φ ψ ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.psi_imp_until φ ψ)) h_psi
```

This is the base case of `backward_until_from_step` (the t = s case). Under irreflexive
Until, ψ at current time does NOT witness (φ U ψ) because the witness must be at a
STRICTLY FUTURE time. So `backward_until_reflexive` is WRONG for irreflexive Until.

**This means the entire backward Until coherence infrastructure in UntilSinceCoherence.lean
needs to be rebuilt for irreflexive Until semantics.** The base case is wrong. The correct
base case should use BX12: `F(ψ) → (⊤ U ψ)`, which in an MCS context means:
if F(ψ) ∈ M (i.e., ψ ∈ f_content(M)), then (⊤ U ψ) ∈ M — not ψ ∈ M directly.

For irreflexive Until with witness strictly in the future, the backward direction base case
should be: if ψ ∈ chain(s) for some s STRICTLY greater than t, and φ ∈ chain(r) for t ≤ r < s,
then (φ U ψ) ∈ chain(t). This is proved by backward induction from s-1 to t using the
step property, but the step property for irreflexive Until is:

```
(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)
```

Note: there is NO base case issue (since the witness is strictly future), but the step
transfer is still needed.

Under irreflexive semantics with ψ ∈ chain(s), s > t strictly, can we apply `until_intro`?

`until_intro` in TemporalDerived.lean uses `bot_until_id` and `or_until_imp`, which use
`psi_imp_until`. So this is circular — the same sorry propagates.

---

## Section 6: Summary of Findings

### Finding 1: The core obstruction is genuine and identical for all three sorries

All three sorry sites (tc, buc, fuc) ultimately reduce to the fundamental incompatibility:
the schedule-based chain cannot guarantee that F-obligations (and Until-formula obligations)
persist through steps where those formulas are not the schedule target. This is because
g_content only propagates G-formulas, not F-formulas or Until-formulas.

### Finding 2: Sorry #2 (backward until/since) has an ADDITIONAL deeper problem

The `psi_imp_until` axiom is sorry'd and is NOT VALID under irreflexive Until semantics.
This means `backward_until_reflexive` is wrong. The entire backward Until induction
infrastructure needs to be redesigned for irreflexive semantics. This is NOT just about
the schedule-based chain — it is about the architecture of UntilSinceCoherence.lean.

### Finding 3: F(φ) → G(F(φ)) is not derivable in BX

Verified by examining all 35 BX axioms. None of them express "If φ eventually holds,
then φ always-eventually holds." This would be the "infinitely often" property which
is not part of basic linear temporal logic.

### Finding 4: The enriched seed approach fails

`{ψ} ∪ g_content(M) ∪ f_content(M)` is potentially inconsistent when M contains
contradictory F-obligations (F(φ) ∧ F(¬φ)), which is allowed in any MCS with
¬G(φ) ∧ ¬G(¬φ).

### Finding 5: BX12 does not break the obstruction

BX12 (F(φ) → ⊤ U φ) converts F-obligations to Until-obligations but does not make
Until-obligations persist through g_content steps. The same Lindenbaum opacity applies.

---

## Recommended Approach

Given the depth of the obstruction, the following is the correct path forward:

**For sorry #1 (temporal coherence)**:
A completely different chain construction is needed that directly tracks F-obligations.
The `deferralClosure(root)` finiteness means a finite set of F-obligations need resolution.
A construction that in each omega-block resolves ALL F-obligations in deferralClosure(root)
would work, but requires a dovetailed/BX11-mediated construction.

**For sorry #2 (backward until/since)**:
The `psi_imp_until` sorry must first be resolved (or `backward_until_reflexive` redesigned
for irreflexive Until). Under irreflexive Until, the backward induction base case changes:
ψ ∈ chain(s) with s > t (strictly) is the base, and the step transfer still needs proof.
This is a separate problem from sorry #1 but equally fundamental.

**For sorry #3 (forward until/since)**:
Requires both F-resolution AND the guard condition. The guard condition requires φ to
persist at ALL intermediate chain steps, which needs G(φ) in the chain — not available
from just (φ U ψ). This is the hardest sorry.

**Recommendation**: Mark task [BLOCKED] and decompose into:
1. Fix psi_imp_until / redesign backward Until for irreflexive semantics
2. Build a finite-obligation dovetailed chain for deferralClosure(root)
3. Close forward_fuc using the new chain

This is a multi-task effort requiring architectural changes, not patching existing sorries.

---

## Confidence Level

- Finding 1 (core obstruction is genuine): **High** — verified by reading all relevant code
- Finding 2 (psi_imp_until sorry cascade): **Very High** — direct textual evidence in codebase
- Finding 3 (F(φ) → G(F(φ)) not derivable): **Very High** — verified against all 35 BX axioms
- Finding 4 (enriched seed fails): **High** — based on mathematical analysis
- Finding 5 (BX12 insufficient): **High** — verified by reasoning through what BX12 provides
- Recommended approach (task [BLOCKED]): **High** — given the depth of the obstruction

---

## Appendix: Exact Lean Types of the Three Sorries

**Sorry #1** (TemporalCoherence.lean, restricted_temporally_coherent):
```lean
-- For each fam ∈ bx_bfmcs M₀ h₀, for each φ ∈ deferralClosure root:
-- F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s
-- P(φ) ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s
```

**Sorry #2** (BFMCS.restricted_backward_until_since_coherent):
```lean
-- For each fam ∈ bx_bfmcs M₀ h₀, (φ U ψ) ∈ subformulaClosure root:
-- (∃ s > t, ψ ∈ fam.mcs s ∧ ∀ r ∈ [t,s), φ ∈ fam.mcs r) → (φ U ψ) ∈ fam.mcs t
-- (∃ s < t, ψ ∈ fam.mcs s ∧ ∀ r ∈ (s,t], φ ∈ fam.mcs r) → (φ S ψ) ∈ fam.mcs t
```

**Sorry #3** (BFMCS.restricted_forward_until_since_coherent):
```lean
-- For each fam ∈ bx_bfmcs M₀ h₀, (φ U ψ) ∈ subformulaClosure root:
-- (φ U ψ) ∈ fam.mcs t → ∃ s > t, ψ ∈ fam.mcs s ∧ ∀ r ∈ [t,s), φ ∈ fam.mcs r
-- (φ S ψ) ∈ fam.mcs t → ∃ s < t, ψ ∈ fam.mcs s ∧ ∀ r ∈ (s,t], φ ∈ fam.mcs r
```
