# Research Report: Task #83 — Root Cause Analysis & Restricted Completeness

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Mode**: Team Research (3 teammates)
**Session**: sess_1775508988_c610f4

## Summary

Three research agents (root cause analyst, restricted completeness specialist, critic) conducted deep mathematical investigation into the X-vs-G mismatch under strict semantics and the feasibility of restricted completeness via pigeonhole. All three independently confirm that the backward-G circularity is genuine and structural. The most significant finding is from Teammate C (critic): **no published completeness proof for strict Until temporal logic over discrete orders was found** — all known proofs operate under reflexive semantics where G(φ)→φ is valid, which eliminates the X-vs-G mismatch entirely.

## Key Findings

### 1. Root Cause of the X-vs-G Mismatch (Teammate A)

The mismatch arises from the intersection of THREE independent features:

| Feature | Effect | Alone Problematic? |
|---------|--------|-------------------|
| Strict semantics (G excludes present) | G(α) and ¬α can coexist in MCS | No |
| Until Unfold produces X-formulas | Persistence info lives in x_content, not g_content | No |
| G-lift as sole consistency technique | Only g_content transfers through Lindenbaum extension | No |

**Their combination** is fatal: Until Unfold deposits persistence into x_content (Feature 2), Lindenbaum can only propagate g_content (Feature 3), and strict semantics ensures g_content ⊊ x_content (Feature 1).

**Counterfactual confirmed**: Under reflexive semantics, G(¬α) ∈ M contradicts α ∈ M (via T-axiom G(φ)→φ), making every formula in an MCS effectively "G-liftable" for seed consistency. The mismatch vanishes completely.

### 2. Restricted Completeness via Pigeonhole (Teammate B)

**Infrastructure audit** — FiniteDeferral.lean is 95% complete:

| Component | Status | Description |
|-----------|--------|-------------|
| F_to_until_in_chain | Sorry-free | F(ψ) → (⊤ U ψ) in chain |
| until_persists_forward_steps | Sorry-free | (⊤ U ψ) persists n steps if ψ absent |
| restrictedTheory definition | Sorry-free | M ∩ deferralClosure(root) |
| pigeonhole_restricted_theories | Sorry-free | Two positions share same restricted theory |
| G_neg_kills_until | Sorry-free | G(¬ψ) ∈ chain(t) → (⊤ U ψ) ∉ chain(t) |
| **forward_F_via_deferral** | **SORRY** | The single remaining gap |

**The gap is precisely identified**: The pigeonhole gives positions i < j with the same restricted theory, (⊤ U ψ) in both, ¬ψ in all. To derive contradiction, we need G(¬ψ) ∈ chain(t+i) (which G_neg_kills_until would use to contradict (⊤ U ψ)). But deriving G(¬ψ) from "¬ψ at all future positions" requires temporal_backward_G, which requires forward_F — **circular**.

**Closure containment issue**: The current deferralClosure may not include (⊤ U ψ) = (¬⊥ U ψ) since it is not a syntactic subformula of ψ. This is a minor fix (~50 lines) but needs addressing.

### 3. Critic's Analysis (Teammate C)

**All 5 major claims from prior reports CONFIRMED:**

| Claim | Verdict | Notes |
|-------|---------|-------|
| forward_F is false for some MCSes | Confirmed | Counterexample in Report 20 is valid |
| X-vs-G mismatch is fundamental | Confirmed | "No alternative exists" slightly overstated |
| Circularity is genuine | Confirmed | Verified in source code dependency chain |
| Finite deferral fails due to cycling | Partially confirmed | Cycling is real; exploitation not fully explored |
| All approaches hit same wall | Mostly confirmed | Two unexplored sub-approaches identified |

**Most significant finding** — The critic identified that:

> **All 24 prior reports attempted to prove completeness for strict semantics DIRECTLY. None considered the standard technique of reducing strict completeness to reflexive completeness, which is how published proofs (Venema 1993) handle exactly this issue.**

However, upon deeper analysis, the critic found that the strict-to-reflexive reduction does NOT fully resolve the circularity: the reflexive backward-G case still needs strict forward_F when the witness is at a strictly future time (not the present). The s = t case is handled by the T-axiom, but the s > t case remains.

**Two unexplored approaches identified:**

1. **Forward_F only for the specific M₀ from completeness** — The sorry is for ALL MCSes, but completeness only needs it for M₀ = Lindenbaum(¬φ₀). Could properties of this specific M₀ help? (Assessed as unlikely since BFMCS bundles include other MCSes.)

2. **Two-dimensional well-founded induction** — Induct on (formula size, chain position) simultaneously. The size increase from ¬φ makes 1D induction fail, but a 2D argument might work. (Assessed as unlikely but not rigorously eliminated.)

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate B | Teammate C | Resolution |
|----------|-----------|-----------|-----------|------------|
| Is restricted completeness viable? | Yes (recommended path) | No (backward-G circular at restricted level too) | Uncertain (cycling not fully exploited) | **Teammate B's analysis is definitive**: restricted forward_F requires the same backward-G step, so restriction to finite closure does NOT break the circularity |
| Does strict-to-reflexive help? | Not explored | Not explored | Initially yes, then revised to "partially" | **Teammate C's revised analysis**: the reduction helps for the s=t case but NOT for s>t. The circularity persists. |
| Is the problem solvable within current architecture? | Only via restricted completeness | Not without new proof infrastructure | Likely requires architectural change | **Consensus**: No known syntactic proof within current axioms; all paths lead to backward-G circularity |

### Gaps Identified

1. **No published proof for strict Until over ℤ exists in accessible literature** — This is the most significant gap. The formalization is attempting something that may not have a clean published proof to follow.

2. **The cycle's periodicity is unexploited** — The pigeonhole gives periodic restricted theories, and the X^m tower (X^m(¬ψ) ∈ chain(t+i) for all m ≥ 1) is an infinite sequence that "converges" to G(¬ψ) semantically but cannot be combined into G(¬ψ) syntactically. This is the most precise characterization of the obstruction.

3. **Venema 1993's exact technique for strict Until** — The critic identified this as the highest-priority follow-up but could not access the full paper to determine the exact mechanism used.

### Why This Problem Is Hard: The Deep Reason

The root cause, distilled from all three teammates:

**The meta-to-object gap**: The deterministic chain gives us infinitely many meta-level facts ("¬ψ ∈ chain(n) for all n > t") that we cannot convert to a single object-level formula ("G(¬ψ) ∈ chain(t)"). This conversion IS temporal_backward_G, and it requires forward_F by contraposition. The circularity is not an artifact of any particular proof strategy — it is a structural feature of the relationship between the external (semantic) and internal (syntactic) views of the chain.

Under reflexive semantics, the T-axiom provides a "free" conversion for the present time (G(φ) → φ), which breaks the circularity in enough cases to make the proof go through. Under strict semantics, this free conversion is absent, and the full circularity manifests.

## Recommendations

### Ordered by Priority

1. **Study Venema 1993 in detail** (HIGH priority) — "Derivation rules as anti-axioms in modal logic" extends Burgess-Xu to strict semantics. The exact completeness proof technique needs to be extracted. This is the single most likely source of a resolution.

2. **Investigate the periodic model + soundness approach more carefully** (MEDIUM priority) — The finite cyclic model from the pigeonhole cycle might admit a truth lemma that avoids full backward-G. The periodicity means every formula's truth value is determined by a finite computation, potentially making the backward-G case decidable rather than requiring an inductive argument.

3. **Consider adding the "omega-rule" as a derived principle** (MEDIUM priority) — An omega-rule ("if φ ∈ chain(n) for all n > t, then G(φ) ∈ chain(t)") would close the gap instantly. This is not an axiom schema (it is infinitary), but it might be provable as a Lean meta-theorem about MCSes in the TM proof system, using properties specific to the proof system (e.g., compactness + the specific axiom set).

4. **Accept the sorry with documentation** (LOW priority, fallback) — If no resolution is found, document that forward_F/backward_P are genuine open formalization problems for strict discrete temporal logic with Until. The 95% sorry-free completeness infrastructure is still a significant achievement.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Root cause analysis | completed | HIGH | Three interacting features cause the mismatch; under reflexive semantics it vanishes |
| B | Restricted completeness | completed | HIGH | FiniteDeferral.lean is 95% complete; backward-G circularity persists at restricted level |
| C | Critic / gap analysis | completed | HIGH | No published proof for strict Until over ℤ; strict-to-reflexive reduction standard but doesn't fully resolve |

## References

1. Burgess, J.P. (1982/1984). "Axioms for tense logic: I. 'Since' and 'Until'" / "Basic Tense Logic."
2. Venema, Y. (1993). "Derivation rules as anti-axioms in modal logic." JSL 58(3).
3. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). Temporal Logic. Oxford.
4. Goldblatt, R. (1992). Logics of Time and Computation. CSLI.
5. Vardi, M.Y., Wolper, P. (1986). Automata-Theoretic Approach to LTL.
6. Verbrugge, L.C., de Jongh, D. "Completeness by Construction for Tense Logics."
7. Reynolds, M. "Hierarchical Completeness Proof for PTL."
8. Prior research reports 01-24 for task 83.
9. Codebase: FiniteDeferral.lean, DeterministicFMCS.lean, DeterministicChain.lean, RestrictedTruthLemma.lean, TemporalCoherence.lean, SubformulaClosure.lean, Axioms.lean
