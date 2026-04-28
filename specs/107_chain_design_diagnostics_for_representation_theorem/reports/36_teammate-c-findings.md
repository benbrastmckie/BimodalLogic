# Critic Findings: Task 107 — Burgess Chronicle Under Strict Semantics

**Teammate**: C (Critic)
**Date**: 2026-04-27
**Session**: sess_1777349941_ed4386

## Gaps Found

### GAP 1: "BX5+BX7 Subsume A4a" Is an UNPROVEN CLAIM — Likely FALSE for D₀ (CRITICAL)

The header in PointInsertion.lean (lines 21-22) and TemporalDerived.lean (lines 537-538) assert:
> "BX5 + BX6 (absorb_until) + BX7 (linear_until) subsume A4a's role"

**This is stated as a comment, not as a theorem. It has never been formally proved.** There is no lemma anywhere in the codebase that derives A4a or its relevant consequences from BX5+BX6+BX7.

More critically, the claim appears to be **FALSE for the specific use in Lemma 2.6**. Here's why:

Burgess's A4a (in our code convention): `untl(β, γ) ∧ ¬untl(β∧δ, γ) → untl(β, β∧¬δ)`

This takes one POSITIVE Until and one NEGATIVE Until and produces a new positive Until containing ¬δ. This is the essential step in the D₀ consistency proof: it produces a positive Until formula that bundles ¬δ with other D₀ components, allowing Lemma 2.2 to conclude consistency.

BX7 (linearity): `untl(φ,ψ) ∧ untl(χ,θ) → ...three disjuncts...`

BX7 requires **two POSITIVE Until formulas** as input. The maximality witness from `BurgessR3Maximal_maximality_combined` gives `¬untl(β∧δ, γ) ∈ A`, which is **negative**. You cannot feed a negative Until into BX7.

The plan's sketch (report 35, §3) proposes using BX7 on `untl(β ∧ untl(β,γ), γ)` and `¬untl(β∧δ, γ)`, then "eliminating 2 of 3 disjuncts." But BX7's hypothesis is a **conjunction of two positive Untils**, not a positive and a negative.

**Verification**: Search the entire codebase — there is no sorry-free theorem that derives `untl(β, β∧¬δ)` from `untl(β,γ)` and `¬untl(β∧δ,γ)` using BX axioms. The existing `left_mono_contrapositive_neg_delta` derives `¬δ ∈ A ∨ F(¬δ) ∈ A`, which is different and insufficient.

**Confidence**: HIGH. The syntactic mismatch between A4a (takes positive+negative) and BX7 (takes positive+positive) is clear. This is not a matter of clever encoding — the axioms have different shapes.

### GAP 2: The "Mixed A/C Problem" Is Real, Not a Misunderstanding (HIGH)

The handoff (35_d0-consistency-handoff.md) identifies the "mixed A/C problem": D₀ contains elements from both A (Until formulas) and C (Since formulas), and showing their joint consistency requires the A3a step.

Report 35 dismissed this as a "false alarm" about conventions. But the convention analysis is correct — the **actual** problem is that **A3a is unavailable under strict semantics**, and the A3a step in Burgess's proof is what ties the Since formulas (from C) into the Until formula (in A), enabling Lemma 2.2 to conclude consistency of the full ζ.

Burgess's key step: from `α ∈ A` and `U(β ∧ U(γ,β) ∧ ¬δ, β) ∈ A` (obtained via A4a), A3a gives `U(β ∧ U(γ,β) ∧ ¬δ ∧ S(α,β), β) ∈ A`. This bundles the Since formula S(α,β) into the Until formula, and Lemma 2.2 on the whole thing proves ζ is consistent.

Under strict semantics, A3a is invalid (the counterexample in TemporalDerived.lean lines 521-526 is correct). The claim that "BX4+BX5 subsume A3a's role" is again an unproven comment. BX4 gives `φ → G(P(φ))`, which only connects φ to its past at future points — it does NOT inject φ into the guard of an Until formula at the current point.

**Confidence**: HIGH.

### GAP 3: Lemma 2.2 (Consistency Criterion) Is Weakened Under Strict Semantics (MEDIUM)

Burgess's Lemma 2.2: If U(γ,δ) ∈ MCS A, then {γ} is consistent.

The code (RRelation.lean, lines 47-65) explicitly notes this is **FALSE** under strict semantics. The counterexample: γ = ⊥, and ⊥ U δ can be in an MCS because BX9 only gives ⊥ ∨ δ = δ, not ⊥. So {⊥} is inconsistent but ⊥ U δ can exist in an MCS.

The weaker replacement (`until_disjunction_in_mcs`: γ U δ ∈ A → γ ∨ δ ∈ A) is proved. But the `until_guard_in_mcs` (γ U δ ∈ A → γ ∈ A) is ALSO proved — and this is actually STRONGER than Lemma 2.2! Under half-open guard [t,s), the guard holds at t, so γ ∈ A directly.

So the consistency criterion is actually not weakened in the way that matters. If U(γ,δ) ∈ A then γ ∈ A, so {γ} is consistent (since A is consistent). This means Burgess's Lemma 2.2 is in fact provable under strict semantics via a DIFFERENT route (until_guard instead of the original ¬γ → G(¬γ) → ¬F(γ) chain).

**However**, the D₀ proof doesn't just need {γ} consistent — it needs the full conjunction ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(β,γ) to be consistent. Burgess's approach produces a single Until formula containing all components of ζ and applies Lemma 2.2 to that. This requires A3a and A4a to enrich the Until formula's guard.

**Confidence**: MEDIUM — the Lemma 2.2 issue is a red herring; the real issue is A3a/A4a.

### GAP 4: Two Parallel r-Relation Systems Create Confusion (MEDIUM)

The codebase maintains TWO independent r-relation systems:

1. **Obligation-based** (`rRelation`, `R3Maximal`): Propagation-style. r(A,B) means B propagates Until obligations from A. MONOTONE in B.
2. **Content-based** (`burgessR3`, `BurgessR3Maximal`): Burgess-style. burgessR3(A,B,C) means B generates Until/Since formulas between A and C. ANTI-MONOTONE in B.

The chronicle conditions mix these: `c2` uses obligation-based `r3Relation`, while `c2'` uses content-based `burgessR3`. The relationship between them is unclear and undocumented. The `lemma_2_6_full` (lines 505-530) works for obligation-based R3Maximal but trivially returns D=B (useless for splitting). The content-based version is the one stuck at sorry.

This dual system has been a source of confusion throughout 35+ research rounds.

**Confidence**: MEDIUM.

### GAP 5: Withdrawn Lemmas 2.7/2.8 May Be Premature (LOW-MEDIUM)

Lemmas 2.7 and 2.8 are marked as "WITHDRAWN" (lines 49-53) with claims they are "FALSE under strict semantics." The specific claim is:
- `lemma_2_7`: "D2 branch cannot produce xi at future MCS"
- `lemma_2_8`: "Depends on lemma_2_7"

These are the C5 counterexample lemmas (adding an Until witness point between existing points). If these are truly false, the entire C5 elimination strategy for the n>0 case (inserting between existing points) collapses, which would mean the omega-chain construction cannot handle C5 counterexamples that arise between existing domain points.

The current workaround (only handling the n=0 case, i.e., adding points after all existing points) may be sufficient for the initial completeness proof, but this should be verified.

**Confidence**: LOW-MEDIUM — would need formal countermodels to confirm.

## Assumptions Questioned

1. **"BX5+BX6+BX7 subsume A4a"** — Likely false for the D₀ use case (see Gap 1).
2. **"BX4+BX5 subsume A3a"** — Unproven and likely insufficient for injecting Since into Until guards.
3. **"The convention mismatch was the blocker"** — Report 35 correctly identifies no convention mismatch, but incorrectly concludes the D₀ proof is now straightforward. The real blocker is A4a unavailability.
4. **"The two-seed approach bypasses D₀"** — The handoff's suggestion (approach 4) of using a weaker seed {¬δ} ∪ B may actually work, but it requires proving burgessR3(A,B,D) and burgessR3(D,B,C) for the Lindenbaum extension D, which may face the same A3a/A4a issues.

## Root Cause Analysis

### Why 35+ Research Rounds?

The fundamental issue has been misidentified repeatedly. Each round discovers a symptom and proposes a fix, but the root cause persists:

**A3a and A4a are structurally necessary for Burgess's proof, and no BX axiom combination has been shown to replace them.**

The cycle:
1. Agent attempts proof → blocked by missing A4a-equivalent step
2. Research diagnoses symptom (convention mismatch, wrong g-function, missing infrastructure, etc.)
3. Agent implements fix for symptom → still blocked
4. New research round

The comments claiming "BX5+BX7 subsume A4a" were written speculatively early in the project and have been treated as proven facts ever since. Every plan since then assumes this is true.

### The Actual Decision Point

The project faces a genuine mathematical decision: **Burgess's proof strategy may not work under strict (irreflexive) Until semantics without either A3a/A4a or provably equivalent replacements.**

Options:
1. **Prove BX→A4a/A3a**: Formally derive A4a and A3a (or their consequences in the D₀ proof) from BX axioms. This may be impossible.
2. **Adopt different axiom system**: Add A3a and A4a to the BX axiom system (they're valid under reflexive semantics but not strict). This changes the logic.
3. **Use a different completeness proof**: Reynolds 1992 and Xu 1988 (in the literature directory) provide alternative completeness proofs that may avoid A3a/A4a. Reynolds specifically axiomatizes Until/Since WITHOUT irreflexivity.
4. **Modify semantics**: Switch from strict to non-strict Until/Since at the guard boundary (make the guard half-open or closed differently). This recovers A3a/A4a soundness.
5. **Find a different D₀ seed**: The "weaker seed" approach from the handoff. But this must be verified to not need A3a/A4a elsewhere.

## Recommendations

1. **IMMEDIATELY**: Attempt to formally prove `⊢ untl(β,γ) ∧ ¬untl(β∧δ,γ) → untl(β, β∧¬δ)` from BX axioms alone, or construct a countermodel showing it's unprovable. This is the decisive test for whether the Burgess approach works under strict semantics.

2. **If unprovable**: Read Reynolds 1992 ("An axiomatization of Until and Since over the reals without the IRR rule") and Xu 1988 carefully. They may provide D₀ consistency proofs that avoid A4a, or use structurally different completeness strategies.

3. **Stop assuming comments are proofs**: The "BX5+BX7 subsume A4a" claim should be either proved or retracted. Do not plan another implementation round that assumes this.

4. **Consider the weaker seed**: The handoff's approach 4 (seed = {¬δ} ∪ B, then prove burgessR3 conditions hold) avoids the full D₀. This deserves formal investigation, since `dcs_neg_union_consistent` already gives consistency of {¬δ} ∪ B, and the Lindenbaum extension D might satisfy burgessR3(A,B,D) via `left_mono_contrapositive_neg_delta`.

## Confidence Level

**Overall: HIGH** that Gap 1 (A4a unavailability) is the true root cause. MEDIUM on whether alternative approaches (weaker seed, different completeness proof) can work.
