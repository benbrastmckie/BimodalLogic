# Team Research: Chain Construction for Task Semantics — Synthesis

- **Task**: 83 - Close Restricted Coherence Sorries
- **Type**: lean4
- **Focus**: Porting Burgess's chain construction to Task Semantics, with extensibility to dense/discrete
- **Date**: 2026-04-08
- **Mode**: Team Research (3 teammates)
- **Session**: sess_1775625087_9b0bc5
- **Sources**: Reports 35-37, Teammate A (chain construction), Teammate B (canonical world histories), Teammate C (critical analysis)

## Executive Summary

All three teammates converge on a unified conclusion: **Burgess's enriched-Succ chain construction is the mathematically correct and practically implementable path** for closing the 4 remaining sorries. The construction maps cleanly to the Task Semantics framework (TaskFrame, WorldHistory, TaskModel), and the existing Bundle infrastructure provides substantial reuse. Three key insights emerged:

1. **Canonical world histories = g_content-chains**: A WorldHistory in the canonical TaskFrame is precisely a ℤ-indexed sequence of MCS where g_content(wᵢ) ⊆ wᵢ₊₁. This correspondence is exact and well-supported by existing infrastructure (Teammate B).

2. **Enriched-Succ chains resolve Until/Since**: The seed at each step includes g_content PLUS active Until formulas directly, bypassing the g_content propagation gap entirely. Seed consistency follows from g_content_closed_derivation + MCS properties. BX5 self-accumulation ensures the guard formula φ is extractable at every intermediate step via BX9 (Teammate A).

3. **The backward direction is the subtlest part**: `bx_until_backward` requires deriving φ U ψ ∈ w₀ from knowing ψ ∈ wⱼ and φ ∈ wᵢ for i < j. Two approaches are viable: (a) step-by-step backward induction using BX5+BX6, or (b) contradiction using the negation unfolding ¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ))). Both are technically feasible but require careful formalization (Teammates A, B, C).

**Critical risks** (from Teammate C): Prior Boneyard failures were caused by building restricted MCS chains instead of full MCS chains — the new approach avoids this. Dense extension (ℚ) requires a fundamentally different construction (not a chain), so the architecture should be designed parametrically from the start.

**Estimated effort**: 800-1200 LOC in new module(s), reusing ~60% of existing Bundle infrastructure. Closes 4 sorries in Frame.lean plus potentially 1 in Completeness.lean.

## 1. The Chain Construction (Synthesis from Teammates A + C)

### 1.1 Overview

Given φ₀ consistent, build a ℤ-indexed chain (..., w₋₁, w₀, w₁, ...) of MCS where:
- w₀ contains φ₀ (from Lindenbaum extension)
- Each wᵢ → wᵢ₊₁ is an enriched-Succ step
- Every Until/Since eventuality is eventually resolved

### 1.2 The Enriched-Succ Seed

At step i (forward direction), the seed for wᵢ₊₁ is:

```
seed(wᵢ) = g_content(wᵢ) ∪ f_step(wᵢ) ∪ active_untils(wᵢ, i)
```

Where:
- **g_content(wᵢ)** = {α : G(α) ∈ wᵢ} — temporal persistence
- **f_step(wᵢ)** = {φ : F(φ) ∈ wᵢ, φ ∉ wᵢ} — F-eventuality targets for scheduled resolution
- **active_untils(wᵢ, i)** = Until formulas that must persist forward

The scheduling uses dovetailing over the finite subformula closure: at step i, schedule eventuality number (i mod k) for forced resolution (where k = number of Until/Since subformulas).

### 1.3 Seed Consistency

**Theorem**: seed(wᵢ) is consistent whenever wᵢ is an MCS.

**Proof sketch** (Teammate A, confirmed by Teammate C):
- If L ⊆ seed(wᵢ) and L ⊢ ⊥, split L into L_g ⊆ g_content(wᵢ) and L_extra (the non-g_content formulas).
- If L_extra = ∅: contradicts g_content_set_consistent.
- If L_extra ≠ ∅: for each formula α ∈ L_extra, we have either F(α) ∈ wᵢ or α U β ∈ wᵢ (so the formula is derivable from wᵢ's contents). By the deduction theorem and g_content_closed_derivation, derive G(¬α) ∈ wᵢ, then ¬α ∈ wᵢ by BX1, contradicting α's presence in wᵢ or its derivability from wᵢ.

The existing `until_witness_seed_consistent` infrastructure in WitnessSeed.lean partially covers this argument.

### 1.4 Until Resolution

Given φ U ψ ∈ w₀, ψ ∉ w₀:

1. By BX9: φ ∈ w₀ (guard at origin)
2. By BX5: (φ ∧ (φ U ψ)) U ψ ∈ w₀ (self-accumulation)
3. φ U ψ is placed in seed(w₀), so φ U ψ ∈ w₁ (by Lindenbaum)
4. At w₁: if ψ ∈ w₁, done (j = 1). If ψ ∉ w₁: by BX9, φ ∈ w₁. Repeat.
5. Eventually dovetailing schedules ψ for forced resolution: ψ goes into the seed at step j
6. Seed {ψ} ∪ g_content(wⱼ₋₁) ∪ {φ U ψ} is consistent (by BX10 + seed consistency argument)
7. So wⱼ has ψ ∈ wⱼ

**Guard verification**: For all i ∈ [0, j): φ U ψ ∈ wᵢ (by seed propagation), ψ ∉ wᵢ (by step choice), so φ ∈ wᵢ by BX9. ∎

### 1.5 The Backward Direction

Two approaches were identified:

**Approach A (Step-by-step backward induction, Teammate A)**:
Given wⱼ with ψ ∈ wⱼ and wᵢ with φ ∈ wᵢ for all i < j:
- At wⱼ: ψ ∈ wⱼ → φ U ψ ∈ wⱼ by BX8
- At wⱼ₋₁: φ ∈ wⱼ₋₁ and F(φ U ψ) ∈ wⱼ₋₁ (from P-witness or chain construction)
- Derive: φ ∧ F(φ U ψ) → φ U ψ (from BX5 + BX6 via derived theorem)
- Induct backwards to w₀

**Approach B (Contradiction, Teammate B)**:
- Suppose ¬(φ U ψ) ∈ w₀
- Derive: ¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ))) (negation unfolding)
- Since φ ∈ w₀ (given in guard), ¬φ ∉ w₀, so G(¬(φ U ψ)) ∈ w₀
- This propagates ¬(φ U ψ) to all future wᵢ via g_content
- At wⱼ: ¬(φ U ψ) ∈ wⱼ. But ψ ∈ wⱼ → φ U ψ ∈ wⱼ by BX8. Contradiction.

**Assessment**: Approach B is cleaner and avoids the derived theorem requirement. Teammate C flagged that the negation unfolding ¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ))) must be verified as derivable from BX1-BX10. This is expected to hold (it's the dual of BX9 + BX5 applied to the complement).

## 2. Mapping to Task Semantics (Synthesis from Teammates A + B)

### 2.1 Chain → WorldHistory

A ℤ-indexed chain of MCS (w_n)_{n∈ℤ} maps to a WorldHistory:

```lean
def chain_to_history (chain : ℤ → Set Formula)
    (h_mcs : ∀ n, SetMaximalConsistent (chain n))
    (h_succ : ∀ n, g_content (chain n) ⊆ chain (n + 1)) :
    WorldHistory CanonicalTaskFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => ⟨chain t, h_mcs t⟩
  respects_task := -- follows from g_content transitivity (temp_4)
```

The `respects_task` obligation for non-consecutive indices (t - s > 1) follows from transitivity: g_content(wᵢ) ⊆ wᵢ₊₁ and the derived g_content(wᵢ) ⊆ g_content(wᵢ₊₁) (via temp_4: G(φ) → G(G(φ))) give g_content(wᵢ) ⊆ wⱼ for all j > i by induction. The existing `existsTask_transitive`/`canonicalR_transitive` handles this.

### 2.2 Omega Design

**The critical design question** (Teammate B): What is Ω?

For the **Box truth lemma** (□φ ∈ w₀ ↔ ∀ τ ∈ Ω, truth_at M Ω τ 0 φ):
- Forward: □φ ∈ w₀ must imply φ true at all τ ∈ Ω at time 0. This requires: for every τ ∈ Ω, the MCS at time 0 in τ must be modally saturated relative to w₀.
- Backward: ◇φ ∈ w₀ (i.e., ¬□¬φ ∈ w₀) must give a τ ∈ Ω with φ true at time 0.

Ω cannot be ALL world histories (too many — Box truth lemma forward direction fails). It must be a BFMCS-style bundle:

**Definition**: Ω = all chain-based histories where:
1. Each history is a g_content-chain of MCS
2. At each time t, the MCS across different histories form a modally coherent family (they agree on all □/◇ formulas)

This matches the existing BFMCS structure. The existing `CanonicalOmega` and `ShiftClosedCanonicalOmega` infrastructure can be reused.

### 2.3 Shift-Closure

**Theorem** (Teammate A): If τ is a chain-based history in Ω, then the time-shifted history τ' defined by τ'(t) = τ(t + k) is also in Ω.

This follows because:
1. g_content-chain property is preserved by shifting
2. Modal coherence at each time is preserved (the family of MCS at time t+k in the shifted history is the same as at time t+k in the original)

The existing `shifted_truth_lemma` infrastructure handles this.

## 3. The BXCanonical → Chain Bridge (Synthesis from all teammates)

### 3.1 The Fundamental Tension

Teammate B identified a critical point: **the 4 BXCanonical sorry stubs quantify over ALL BXPoints**, not just chain members. The stubs say:

```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

This requires φ at ALL BXPoints between w and v. But the chain construction only gives φ at chain members. A random BXPoint between w and v might not be on the chain.

### 3.2 Resolution: Two Options

**Option 1 (Recommended by Teammates A, B, C): New ChainCanonical Module**

Build a new completeness proof that bypasses BXCanonical entirely:
- New `ChainCanonical/` module with chain-based truth lemma
- Wire directly to TaskFrame completeness
- The 4 BXCanonical sorries become moot (they stay as sorry but are unused)
- The completeness theorem uses the chain path

**Option 2: Hybrid Approach (Teammate B suggestion)**

Keep BXCanonical for Box/G/H and prove Until/Since via chains:
- Build a chain from w to v within the BXCanonical framework
- Show the chain provides enough structure for the guard
- Issue: the guard quantifies over all BXPoints, not just chain members

**Decision**: Option 1 is cleaner. The BXCanonical module can remain as an alternative approach or be archived. The new ChainCanonical module provides a self-contained, sorry-free completeness proof.

## 4. Extensibility to Dense and Discrete (Synthesis from all teammates)

### 4.1 Discrete Extension (D = ℤ, with X/Y)

Chain construction is natural — the Succ relation maps directly to the X (next) operator. The existing SuccRelation.lean infrastructure is directly applicable. Enriched-Succ seeds handle Until resolution identically.

### 4.2 Dense Extension (D = ℚ)

**Critical finding** (Teammate C): Chain construction is **fundamentally incompatible** with dense time. Between any two rationals there is another, so:
- There is no "next" state
- The Succ relation does not exist
- A ℤ-indexed chain is insufficient

**Dense approach** (Teammate A): Use a family of MCS indexed by ℚ, built via:
1. **Dedekind completion**: Build MCS at rational points by interpolation
2. **Dense chain**: For any two MCS with g_content relation, insert intermediate MCS
3. **Cantor's theorem**: Use density axiom DN to characterize the canonical order as ℚ-like

The D-parametric TaskFrame already supports ℚ. The dense completeness proof requires a different construction module (`DenseChainCanonical/`), but the TaskFrame/WorldHistory/TaskModel layer remains unchanged.

### 4.3 Recommended Architecture

```
Metalogic/
├── ChainCanonical/              -- Base logic (D = ℤ)
│   ├── Chain.lean               -- Chain construction + seed consistency
│   ├── ChainWorldHistory.lean   -- Chain → WorldHistory + Omega
│   ├── TruthLemma.lean          -- Until/Since truth lemma
│   └── Completeness.lean        -- Wiring to validity
├── DiscreteChainCanonical/      -- Discrete extension (X/Y)
│   ├── Chain.lean               -- Succ-based chain with X/Y resolution
│   └── TruthLemma.lean          -- Extended truth lemma
├── DenseCanonical/              -- Dense extension (ℚ)
│   ├── DenseConstruction.lean   -- ℚ-indexed MCS family
│   └── TruthLemma.lean          -- Dense truth lemma
├── BXCanonical/                 -- (Existing, preserved for reference)
└── Bundle/                      -- (Existing, reused infrastructure)
```

This cleanly separates base/dense/discrete while maximizing reuse at the TaskFrame level.

## 5. Boneyard Lessons (from Teammate C)

Prior chain attempts failed for a **single root cause**: building chains of restricted MCS (DeferralRestrictedMCS) and trying to lift to full MCS, rather than building full MCS chains directly.

Specific failures:
- `TargetedChain.lean`: Built restricted seeds that couldn't guarantee Until persistence
- `ResolvingChain.lean`: Attempted deferral-based resolution within restricted sets
- `MCSWitnessChain.lean`: Started with full MCS but tried to restrict the witness search

**Lesson**: The new approach must build FULL MCS chains from the start. The seed includes formulas from g_content + active Until formulas, and the Lindenbaum extension completes to a full MCS. No intermediate restricted MCS step.

## 6. Conflicts Between Teammates

### 6.1 Backward Direction Approach

- Teammate A: Step-by-step backward induction using BX5+BX6
- Teammate B: Contradiction via negation unfolding
- Teammate C: Flagged backward direction as HIGH risk regardless of approach

**Resolution**: Both approaches are mathematically valid. Approach B (contradiction) is recommended as primary because it avoids the need for the derived theorem `φ ∧ F(φ U ψ) → φ U ψ` and maps cleanly to MCS properties. Approach A is fallback.

### 6.2 Whether BXCanonical Should Be Preserved

- Teammate A: New module, BXCanonical preserved for reference
- Teammate B: Hybrid approach keeping BXCanonical for Box/G/H
- Teammate C: Converge on Bundle architecture, BXCanonical to Boneyard

**Resolution**: New ChainCanonical module as primary. BXCanonical preserved (not boneyarded) as it provides infrastructure (BXPoint, g_content, axiom lemmas) that ChainCanonical reuses.

### 6.3 Dense Extension Feasibility

- Teammate A: Feasible via ℚ-indexed families
- Teammate C: Fundamentally different construction needed, HIGH risk

**Resolution**: Both are correct — dense extension is feasible but requires its own construction module, not a direct extension of the chain approach. The architecture should accommodate this from the start.

## 7. Recommendations

### 7.1 Implementation Plan

1. **Phase 1**: Define enriched-Succ chain construction (Chain.lean)
   - Chain type, seed construction, seed consistency proof
   - Forward and backward chain building
   - Until/Since eventuality scheduling

2. **Phase 2**: Build WorldHistory bridge (ChainWorldHistory.lean)
   - chain_to_history conversion
   - Omega construction with modal coherence
   - Shift-closure proof

3. **Phase 3**: Prove truth lemma (TruthLemma.lean)
   - Mutual induction on formula complexity
   - Until forward: enriched seed propagation + BX9
   - Until backward: contradiction via negation unfolding
   - Box: modal coherence of Omega
   - G/H: g_content/h_content propagation

4. **Phase 4**: Wire completeness (Completeness.lean)
   - Contrapositive: consistent formula → satisfiable in canonical model
   - Connect to existing validity infrastructure

### 7.2 Effort Estimate

| Component | LOC (new) | LOC (reused) | Difficulty |
|-----------|-----------|--------------|------------|
| Chain construction | 200-300 | 100 (WitnessSeed, TemporalContent) | Medium |
| WorldHistory bridge | 150-200 | 200 (CanonicalConstruction) | Medium |
| Truth lemma | 300-400 | 150 (TruthLemma patterns) | High |
| Completeness wiring | 100-150 | 50 (Completeness) | Low |
| **Total** | **750-1050** | **500** | |

### 7.3 Key Risks to Monitor

| Risk | Severity | Mitigation |
|------|----------|------------|
| Backward direction derivation | HIGH | Use contradiction approach; verify negation unfolding early |
| Multiple Until scheduling | MEDIUM | Dovetailing over finite subformula closure; well-founded |
| Omega modal coherence | MEDIUM | Reuse existing BFMCS infrastructure |
| Dense extension design | LOW (deferred) | Parametric architecture from start; separate module later |

## 8. Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Chain construction + Task Semantics mapping | completed | high |
| B | Canonical world histories + Omega design | completed | high |
| C | Critical analysis + risk assessment | completed | high |

## References

- Burgess, J.P. (1982). "Axioms for Tense Logic I: Since and Until." *NDJFL* 23(4).
- Burgess, J.P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic* Vol. II.
- Xu, M. (1988). "On Some US-Tense Logics." *JPL* 17(2).
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI.
- Reports 35-37 in this task directory.
- Teammate findings: 38_teammate-{a,b,c}-findings.md.
- Codebase: Frame.lean, CanonicalConstruction.lean, SuccRelation.lean, WitnessSeed.lean, Truth.lean, WorldHistory.lean, TaskFrame.lean.
