# Research Report: Task #109 — Reflexive Until with Irreflexive G/H Evaluation

**Task**: Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-21
**Session**: sess_1776787407_73b01a
**Focus**: Evaluate the best Until/Since convention for completeness over irreflexive G/H semantics

## Executive Summary

This report evaluates the prospects for establishing representation and completeness theorems under **irreflexive G/H semantics** (strict `<` for temporal operators G and H) by optimizing the Until/Since conventions. The key finding is that **reflexive Until (witness s ≥ t) with half-open guard [t,s)** is the optimal combination. It restores BX8 (ψ → φ U ψ), preserves BX9, and requires only a minor weakening of BX10. Combined with an enriched-seed chain construction using the already-proved Ordered Seed Consistency theorem, this approach provides a viable path to closing all 3 sorry sites while preserving irreflexive G/H.

## Part 1: The Convention Space

### 1.1 Fixed Constraints

The following are held fixed throughout this analysis:

```
G(φ) at t:  ∀s, t < s → φ(s)       -- strict future (irreflexive)
H(φ) at t:  ∀s, s < t → φ(s)       -- strict past (irreflexive)
F(φ) at t:  ∃s, t < s ∧ φ(s)       -- derived: strict future existential
P(φ) at t:  ∃s, s < t ∧ φ(s)       -- derived: strict past existential
```

These give `F(φ) = ¬G(¬φ)` and `P(φ) = ¬H(¬φ)` with strict temporal reference in both cases.

### 1.2 Convention Candidates for Until

| ID | Witness | Guard | Description |
|----|---------|-------|-------------|
| A1 | s > t (strict) | (t, s) open | Standard strict / Kamp-Venema |
| A2 | s > t (strict) | [t, s) half-open | Current ProofChecker convention |
| B1 | s ≥ t (reflexive) | [t, s) half-open | CS/LTL-compatible with irreflexive G |
| B2 | s ≥ t (reflexive) | (t, s) open | Non-standard hybrid |

Since conventions are symmetric for Since, the analysis focuses on Until.

### 1.3 Axiom Soundness Matrix

Each BX axiom was checked against all four conventions under irreflexive G/H:

| Axiom | A1 (strict/open) | A2 (strict/half-open) | B1 (reflexive/half-open) | B2 (reflexive/open) |
|-------|-------------------|-----------------------|--------------------------|---------------------|
| BX1 (serial_future) | ✓ | ✓ | ✓ | ✓ |
| BX2 (left_mono_until) | ✓ | ✓ | ✓ | ✗ (guard mismatch) |
| BX3 (right_mono_until) | ✓ | ✓ | ✓ | ✓ |
| BX4 (connect_future) | ✓ | ✓ | ✓ | ✓ |
| BX5 (self_accum_until) | ✓ | ✓ | ✓ | ✓ |
| BX6 (absorb_until) | ✓ | ✓ | ✓ | ✓ |
| BX7 (linear_until) | ✓ | ✓ | ✓ | ✓ |
| **BX8 (until_intro)** | **✗** | **✗** | **✓** | **✗** |
| BX9 (until_elim) | ✗ (φ not at t) | ✓ | ✓ | ✗ (φ not at t) |
| **BX10 (until_F)** | ✓ | ✓ | **✗** | ✓ |
| BX11 (temp_linearity) | ✓ | ✓ | ✓ | ✓ |
| BX12 (F_until_equiv) | ✓ | ✓ | ✓ | ✓ |
| temp_4 | ✓ | ✓ | ✓ | ✓ |
| temp_k_dist | ✓ | ✓ | ✓ | ✓ |

**Key observations**:
- **A1** (strict/open): Loses both BX8 and BX9. Major axiom overhaul needed.
- **A2** (strict/half-open): Loses BX8. Current status — 60+ rounds of failed attempts.
- **B1** (reflexive/half-open): Loses only BX10. **Optimal trade-off.**
- **B2** (reflexive/open): Loses BX2, BX8, BX9. Worse than B1 in every way.

### 1.4 Recommendation: Convention B1

**Reflexive Until witness (s ≥ t) with half-open guard [t, s)** is the clear winner:
- Restores BX8 (the missing Until-introduction axiom)
- Preserves BX9 (current-time elimination)
- Preserves BX2 (left monotonicity — requires guard to cover t)
- Loses only BX10, which has a clean replacement (Section 2)
- Aligns with the CS/LTL tradition for Until

## Part 2: The Modified BX10

### 2.1 Why BX10 Fails Under B1

BX10 states: `(φ U ψ) → F(ψ)`.

Under B1: `φ U ψ` at t has witness s ≥ t. When s = t, ψ(t) holds. But F(ψ) requires ∃s' > t with ψ(s'), and having ψ at the current time t does not provide a strictly future witness. **BX10 is unsound when s = t.**

### 2.2 The Sound Replacement: BX10'

```
BX10': (φ U ψ) → ψ ∨ F(ψ)
```

**Soundness proof**: Under B1, `φ U ψ` at t gives witness s ≥ t with ψ(s).
- If s = t: ψ(t) holds. So ψ ∨ F(ψ) via the left disjunct. ✓
- If s > t: ψ(s) with s > t gives F(ψ). So ψ ∨ F(ψ) via the right disjunct. ✓

### 2.3 Why BX10' Suffices for the Chain Construction

In any MCS M where `(φ U ψ) ∈ M`:
- By BX10': `ψ ∈ M` or `F(ψ) ∈ M`
- If `ψ ∈ M`: the Until obligation is immediately resolved (reflexive witness at current time)
- If `ψ ∉ M`: since M is maximal consistent, `¬ψ ∈ M`. Combined with `ψ ∨ F(ψ) ∈ M`, we get `F(ψ) ∈ M` (by MCS disjunction and exclusion). This gives the F-obligation that the chain construction must resolve.

So from the chain construction's perspective, BX10' is equivalent to BX10 in all non-trivial cases. The only difference is the reflexive base case, which is handled directly by BX8.

### 2.4 Impact on Existing Codebase

`until_imp_F` (TemporalDerived.lean:269) is a direct invocation of BX10. Under the modified system:
- Replace with `until_imp_or_F : ⊢ (φ U ψ).imp (ψ.or (F ψ))`
- Every consumer that pattern-matches on `F(ψ)` from Until must first case-split on `ψ ∨ F(ψ)`
- In MCS contexts, the case split is trivial (if ψ ∈ M, the obligation is resolved; if ψ ∉ M, get F(ψ) ∈ M)

## Part 3: What B1 Fixes

### 3.1 Sorry #2: Backward Until/Since Coherence (`bx_bfmcs_restricted_buc`)

**Currently blocked by**: `psi_imp_until` sorry (ψ → φ U ψ is invalid under A2)

**Under B1**: ψ → φ U ψ becomes sound and provable (BX8 restored as an axiom). The proof:
- Take witness s = t. Guard [t, t) = ∅ (vacuously satisfied). ψ(t) holds. ✓

This unblocks the entire backward Until coherence chain:
```
psi_imp_until [NOW PROVABLE via BX8]
  → backward_until_reflexive [UNBLOCKED: base case s = t]
    → backward_until_from_step [UNBLOCKED: induction works]
      → bx_bfmcs_restricted_buc [CLOSABLE with step transfer]
```

The step transfer property (`(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`) is semantically valid under B1: if `φ U ψ` at r+1 has witness s ≥ r+1, and φ holds at r, then at r we have: witness s ≥ r+1 > r with ψ(s), guard φ on [r, s) = {r} ∪ [r+1, s). φ(r) is given; φ on [r+1, s) comes from the Until at r+1 (where the guard covers [r+1, s)). So `φ U ψ` at r. ✓

### 3.2 Sorry #3: Forward Until/Since Coherence (`bx_bfmcs_restricted_fuc`)

**Currently blocked by**: F-resolution + guard persistence

**Under B1**: Given `(φ U ψ) ∈ chain(t)`:
1. BX10' gives `ψ ∈ chain(t)` or `F(ψ) ∈ chain(t)`
2. If `ψ ∈ chain(t)`: witness at s = t (reflexive). Guard [t, t) = ∅. Done.
3. If `F(ψ) ∈ chain(t)`: reduces to F-resolution (sorry #1). Once resolved (ψ at some s > t), the guard φ on [t, s) follows from BX5 (self-accumulation) + BX9 (elimination): at any intermediate r with `(φ U ψ) ∈ chain(r)` and `ψ ∉ chain(r)`, BX9 gives `φ ∈ chain(r)`.

So sorry #3 reduces entirely to sorry #1 under B1.

### 3.3 Sorry #1: F/P Resolution (`bx_bfmcs_restricted_tc`)

**This sorry is independent of the Until convention.** It depends only on the irreflexive G semantics and the g_content opacity problem. Changing Until to reflexive does not help here.

However, the enriched-seed approach described in Part 4 provides a viable path.

## Part 4: F-Resolution via Enriched-Seed Chain Construction

### 4.1 The Core Obstruction (Unchanged by B1)

Under irreflexive G: `g_content(M) = {α | G(α) ∈ M}` does not include M itself (no T-axiom G(φ) → φ). So the Lindenbaum seed `{target} ∪ g_content(M)` at each chain step is impoverished relative to M. F-obligations `F(ψ) ∈ M` are not G-formulas and are invisible to g_content. The Lindenbaum extension (`Classical.choice`) can freely add `G(¬ψ)`, permanently killing `F(ψ)` without `ψ` ever appearing.

**F-obligation monotonicity** (proved sorry-free in `RootScopedChain.lean:113-143`): Once F(ψ) leaves the chain, it never returns. This means F-obligations can only be lost, never regained — so the chain must resolve them before they are lost.

### 4.2 The Enriched-Seed Solution

The key idea (from task 93 report 13): **explicitly include all F-obligations in the Lindenbaum seed at every step**, preventing `Classical.choice` from destroying them.

**At each step n**, compute:
```
D_n = {ψ ∈ Σ | F(ψ) ∈ chain(n), ψ ∉ chain(n)}    -- current F-defects
```
where Σ = deferralClosure(root) (finite).

**Choose** a resolvable defect ψ_j ∈ D_n (via iterated BX11, see Section 4.4).

**Build** chain(n+1) as Lindenbaum extension of the enriched seed:
```
{ψ_j} ∪ g_content(chain(n)) ∪ {F(ψ_k) | ψ_k ∈ D_n, k ≠ j}
```

If D_n = ∅ (no defects), use plain g_content seed.

### 4.3 The Ordered Seed Consistency Theorem

**Theorem** (proved sorry-free in `OrderedSeedConsistency.lean`):
If `F(ψ₁ ∧ F(ψ₂)) ∈ M`, then `{ψ₁, F(ψ₂)} ∪ g_content(M)` is consistent.

**Proof sketch** (verified by Teammate A in report 09):
1. Suppose for contradiction: `{ψ₁, F(ψ₂)} ∪ L_g ⊢ ⊥` where L_g ⊆ g_content(M).
2. By deduction + DNE: `L_g ⊢ ψ₁ → G(¬ψ₂)`.
3. By generalized temporal K: `G(ψ₁ → G(¬ψ₂)) ∈ M`.
4. Propositional manipulation: `G(¬(ψ₁ ∧ F(ψ₂))) ∈ M`.
5. Contradicts `F(ψ₁ ∧ F(ψ₂)) ∈ M` (these are negations of each other). □

**Critical**: This proof uses only temp_4, temp_k_dist, G/F duality, and MCS properties. It does **NOT** use the T-axiom G(φ) → φ. Therefore it is valid under irreflexive G.

**Generalization**: By induction, if `F(ψ_j ∧ ⋀_{k≠j} F(ψ_k)) ∈ M`, then `{ψ_j} ∪ {F(ψ_k) | k ≠ j} ∪ g_content(M)` is consistent.

### 4.4 BX11-Based Defect Resolution Ordering

Given F-defects D_n = {ψ₁, ..., ψ_m} with F(ψ_i) ∈ chain(n) for each i:

**For m = 2**: BX11 applied to F(ψ₁) and F(ψ₂) gives one of:
- `F(ψ₁ ∧ ψ₂) ∈ M` — witnesses coincide; either can be resolved
- `F(ψ₁ ∧ F(ψ₂)) ∈ M` — ψ₁'s witness comes first; resolve ψ₁
- `F(F(ψ₁) ∧ ψ₂) ∈ M` — ψ₂'s witness comes first; resolve ψ₂

**For m > 2**: Apply BX11 iteratively. Given `F(ψ_j ∧ F(ψ_k)) ∈ M` (j earlier than k) and `F(ψ_j ∧ F(ψ_l)) ∈ M` (j earlier than l), the seed `{ψ_j, F(ψ_k), F(ψ_l)} ∪ g_content(M)` is consistent by the generalized theorem.

For general m: apply BX11 to pairs `(F(ψ_j), F(ψ_k))` for each k ≠ j, accumulating the compound formula. The derivation:
1. Start with `F(ψ_j ∧ F(ψ₂)) ∈ M` (from BX11 on ψ_j and ψ₂)
2. Apply BX11 to `F(ψ_j ∧ F(ψ₂))` and `F(ψ₃)`:
   - If "same time": `F(ψ_j ∧ F(ψ₂) ∧ ψ₃) ∈ M` — at the witness, `F(ψ₂)` and `ψ₃` both hold, giving `F(ψ₃)` or a resolved ψ₃
   - If ψ_j's compound comes first: `F((ψ_j ∧ F(ψ₂)) ∧ F(ψ₃)) ∈ M = F(ψ_j ∧ F(ψ₂) ∧ F(ψ₃)) ∈ M` ✓
   - If ψ₃ comes first: work from ψ₃ as the resolution target instead
3. Continue until all defects are covered.

**The 3-cycle issue**: With 3+ defects, pairwise BX11 ordering can exhibit cycles (A before B, B before C, C before A). However, cycles do not prevent resolution — they only prevent finding a *global* minimum. At each step, at least one defect ψ_j satisfies the compound formula condition for the enriched seed consistency proof. The iterated BX11 construction always terminates with some valid resolution candidate, even if it's not the "earliest" one globally.

**Practical approach**: Use a round-robin schedule over the finite defect set Σ. At each step, attempt to resolve the next defect in the rotation. If BX11 doesn't produce the required compound formula for that defect, skip to the next. Since |Σ| is finite, at least one defect can always be resolved.

### 4.5 F-Defect Dynamics

**F-Defect Monotonicity for new formulas** (proved in report 13, Section 2.3):

If `F(α) ∉ chain(n)` (not a defect at step n), then `F(α) ∉ chain(n+k)` for all k ≥ 1.

*Proof*: F(α) ∉ chain(n) → G(¬α) ∈ chain(n) (MCS neg-completeness) → G(G(¬α)) ∈ chain(n) (temp_4) → G(¬α) ∈ g_content(chain(n)) ⊆ chain(n+1) → F(α) ∉ chain(n+1). By induction. ✓

**This does NOT use the T-axiom** — it works under irreflexive G.

**Defect re-emergence for resolved formulas**: If ψ_j was resolved at step n (ψ_j ∈ chain(n+1)), ψ_j may leave the chain at a later step, and F(ψ_j) could reappear. This creates a "cycling" pattern where defects are resolved, re-emerge, and get resolved again.

**Why cycling is acceptable**: Restricted temporal coherence requires: for every t, if `F(ψ) ∈ chain(t)` then `∃s > t, ψ ∈ chain(s)`. With the enriched-seed construction:
- If `F(ψ) ∈ chain(t)` and `ψ ∉ chain(t)` (ψ is a defect), then `F(ψ)` is explicitly preserved in the enriched seed at every subsequent step until ψ is resolved.
- The round-robin schedule ensures ψ is targeted for resolution within at most |Σ| steps.
- At the resolution step s, ψ ∈ chain(s+1) with s+1 > t. ✓

Even if ψ re-emerges as a defect later, each instance is resolved independently. The key invariant is: **F-obligations are never silently destroyed** because they are explicitly carried in the enriched seed.

### 4.6 Forward_G Property of the Enriched Chain

The FMCS structure requires forward_G: `G(φ) ∈ fam.mcs(t) → φ ∈ fam.mcs(s)` for all s > t.

**Proof that this holds**: 
- G(φ) ∈ chain(t) → G(G(φ)) ∈ chain(t) (by temp_4) → G(φ) ∈ g_content(chain(t))
- g_content(chain(t)) ⊆ chain(t+1) (by Lindenbaum seed inclusion) → G(φ) ∈ chain(t+1)
- By induction: G(φ) ∈ chain(s) for all s > t
- For each s > t: G(φ) ∈ chain(s-1) → φ ∈ g_content(chain(s-1)) ⊆ chain(s)
- Therefore: φ ∈ chain(s) for all s > t. ✓

This proof uses only temp_4 and g_content propagation. It does **NOT** require the T-axiom.

### 4.7 Backward_H Property (Symmetric)

Symmetric argument using past_4 (`H(φ) → H(H(φ))`) and h_content propagation for the backward chain.

## Part 5: Complete Sorry Closure Analysis Under B1

### 5.1 Sorry #1: `bx_bfmcs_restricted_tc` (F/P Resolution)

**Approach**: Enriched-seed chain construction (Section 4).

**Key steps**:
1. Replace `fwd_succ` with `enriched_fwd_succ` that takes the current defect set and uses the enriched seed
2. Prove enriched seed consistency via Ordered Seed Consistency (already sorry-free)
3. Prove F-defect preservation (F-obligations explicitly in seed)
4. Prove resolution: schedule ensures every defect is targeted within bounded steps
5. Symmetric construction for backward P-resolution

**Dependencies**: Ordered Seed Consistency theorem (proved), F-Defect Monotonicity (proved for new formulas), BX11 iteration (needs formalization).

### 5.2 Sorry #2: `bx_bfmcs_restricted_buc` (Backward Until/Since Coherence)

**Approach**: Direct from restored BX8 + step transfer.

**Key steps**:
1. `psi_imp_until` becomes provable (BX8 axiom)
2. `backward_until_reflexive` unblocked (base case uses psi_imp_until)
3. Step transfer: `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`
   - Semantically valid under B1 (guard [r, s) = {r} ∪ [r+1, s))
   - Provable from the enriched chain structure: chain(r+1) extends g_content(chain(r)), and the Until formula propagates backward via BX8 + BX9 + BX5
4. `backward_until_from_step` induction works with the restored base case

**Dependencies**: BX8 restoration (requires B1 semantic change), step transfer formalization.

### 5.3 Sorry #3: `bx_bfmcs_restricted_fuc` (Forward Until/Since Coherence)

**Approach**: BX10' + F-resolution + guard persistence.

**Key steps**:
1. Given `(φ U ψ) ∈ chain(t)`:
2. By BX10': `ψ ∈ chain(t)` or `F(ψ) ∈ chain(t)`
3. If `ψ ∈ chain(t)`: witness at s = t (reflexive). Guard [t, t) = ∅. Done.
4. If `F(ψ) ∈ chain(t)`: by sorry #1 resolution, ∃s > t with ψ ∈ chain(s)
5. Guard φ on [t, s): by BX5 (self-accumulation), `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`. At each intermediate r ∈ [t, s): if `(φ U ψ) ∈ chain(r)` and `ψ ∉ chain(r)`, then by BX9: `φ ∈ chain(r)`.
6. The Until formula persists at intermediate positions because it's in the enriched seed (as an F-obligation via BX10' → F(ψ)).

**Dependencies**: Sorry #1 resolution, BX5/BX9 interaction formalized.

### 5.4 Additional Sorry Sites Closed

| Sorry Site | File | Under B1 |
|-----------|------|----------|
| `psi_imp_until` | TemporalDerived.lean:232 | **CLOSED** — direct BX8 axiom |
| `psi_imp_since` | TemporalDerived.lean:242 | **CLOSED** — direct BX8' axiom |
| `G_bot_absurd` | TemporalDerived.lean:67 | Provable from seriality (independent of B1) |
| `H_bot_absurd` | TemporalDerived.lean:72 | Provable from seriality (independent of B1) |
| `bx_le_refl` | Frame.lean:202 | **STILL SORRY** — requires T-axiom, not available under irreflexive G |

## Part 6: Implementation Plan

### Phase 1: Semantic Change (5-8 hours)

**Truth.lean** (lines 127-130):
```lean
-- BEFORE (A2):
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ

-- AFTER (B1):
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ
```

Changes: `t < s` → `t ≤ s` in Until witness, `s < t` → `s ≤ t` in Since witness. G/H definitions remain unchanged (strict `<`).

### Phase 2: Axiom System Update (3-5 hours)

1. **Re-add BX8/BX8'** to Axiom inductive type:
   ```lean
   | until_intro (φ ψ : Formula) : Axiom (ψ.imp (Formula.untl φ ψ))
   | since_intro (φ ψ : Formula) : Axiom (ψ.imp (Formula.snce φ ψ))
   ```

2. **Replace BX10/BX10'**:
   ```lean
   -- BEFORE: | until_F (φ ψ : Formula) : Axiom ((Formula.untl φ ψ).imp (Formula.some_future ψ))
   -- AFTER:
   | until_disj_F (φ ψ : Formula) :
       Axiom ((Formula.untl φ ψ).imp (Formula.or ψ (Formula.some_future ψ)))
   | since_disj_P (φ ψ : Formula) :
       Axiom ((Formula.snce φ ψ).imp (Formula.or ψ (Formula.some_past ψ)))
   ```

3. Update `Axiom.frameClass` and compatibility predicates (all remain Base).

### Phase 3: Soundness Re-proofs (5-8 hours)

Most soundness proofs need minor adjustments:
- BX8/BX8' soundness: straightforward (witness s = t, vacuous guard)
- BX10' soundness: case split on s = t vs s > t (Section 2.2)
- BX2 soundness: verify guard coverage still works (it does: guard [t,s) covered by (φ→χ)(t) and G(φ→χ) covering (t,s))
- Existing proofs for BX1-BX7, BX9, BX11-BX12: require `<` → `≤` in Until/Since witness conditions, structurally similar proofs
- `truth_at` shift preservation: `≤` is shift-invariant, so these should be mechanical

### Phase 4: Enriched Chain Construction (10-15 hours)

1. **Define `enriched_fwd_succ`**: Takes current MCS, defect set, and resolution target; builds enriched seed
2. **Prove enriched seed consistency**: Instantiate Ordered Seed Consistency theorem
3. **Define `enriched_fwd_chain`**: Recursive chain using enriched_fwd_succ with round-robin defect scheduling
4. **Prove F-defect preservation**: F-obligations explicitly in seed ⊆ successor MCS
5. **Prove resolution**: Every defect resolved within |Σ| steps
6. **Prove restricted_tc**: From defect preservation + resolution
7. **Prove restricted_fuc**: From BX10' + restricted_tc + BX5/BX9
8. **Prove restricted_buc**: From BX8 + step transfer + backward induction

### Phase 5: Close Remaining Sorry Sites (3-5 hours)

1. `psi_imp_until` / `psi_imp_since`: Direct BX8/BX8' axiom application
2. `G_bot_absurd` / `H_bot_absurd`: From seriality (⊤ → F(⊤) gives ∃s > t, ⊤(s); if G(⊥) then ⊥ at s, contradiction)
3. Wire enriched chain into `bx_bfmcs` and `dd_countermodel`

### Phase 6: Verification (2-4 hours)

1. `lake build` — full project compilation
2. Check `#print axioms bx_completeness` — should show only `propext`, `Classical.choice`, `Quot.sound`
3. Run test suite

**Total estimated effort: 28-45 hours**

## Part 7: Risk Assessment

### 7.1 Low Risk

| Risk | Mitigation |
|------|-----------|
| BX8/BX9 soundness under B1 | Verified by hand; straightforward formalization |
| BX10' sufficiency for chain construction | Proved equivalent to BX10 in MCS contexts |
| Forward_G/Backward_H for enriched chain | Proved in Section 4.6 (only uses temp_4) |

### 7.2 Medium Risk

| Risk | Mitigation |
|------|-----------|
| BX11 iteration for m > 2 defects | Generalization argument is sound; formalization may need 5-10 auxiliary lemmas |
| Step transfer formalization | Semantically valid; needs careful proof term construction |
| Defect re-emergence handling | Cycling is bounded by |Σ|; may need explicit cycle-length bounds |

### 7.3 High Risk

| Risk | Mitigation |
|------|-----------|
| Soundness re-proofs cascading | Some proofs may need non-trivial restructuring; budget extra time |
| BX10' downstream consumers | Every use of `until_imp_F` must be updated; may reveal hidden dependencies |
| `bx_le_refl` remains sorry | Independent of this work; does not block completeness |

## Part 8: Comparison with Alternatives

| Approach | Closes All 3? | Effort | Irreflexive G? | Standard? |
|----------|---------------|--------|----------------|-----------|
| **B1 + enriched seed (this report)** | **Yes** | **28-45h** | **Yes** | **Closest to CS/LTL** |
| Full reflexive restoration (Path B) | Yes | 20-35h | No | Burgess/Goldblatt |
| Semantic completeness (Path C) | Yes | 40-60h | Yes | GHR/Reynolds |
| Stay with A2, no change | No | ∞ | Yes | Non-standard |

The B1 + enriched seed approach is the only option that preserves irreflexive G/H while using chain-based completeness and closing all sorry sites within a feasible effort budget.

## References

### Codebase
- `Theories/Bimodal/Semantics/Truth.lean` — semantic definitions (lines 125-130)
- `Theories/Bimodal/ProofSystem/Axioms.lean` — all 35 BX axioms
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 3 sorry sites
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — fwd_succ, schedule chain
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — g_content, bx_forward_witness
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — forward_temporal_witness_seed
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — backward_until_from_step
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — psi_imp_until (sorry'd)
- `OrderedSeedConsistency.lean` — Ordered Seed Consistency theorem (sorry-free)

### Literature
- Burgess (1982/1984): Reflexive G/H, reflexive Until; constructive chain completeness
- Xu (1988): Simplified Burgess; reflexive conventions
- Goldblatt (1992): Canonical model with schedule; reflexive temporal operators
- Venema (1993): Strict-ordering extensions; F(φ) → (¬φ) U φ axiom
- GHR (1994, Ch. 6): Quasimodel unraveling; defect-count descent

### Prior Research
- Task 93 Report 13: Ordered Seed Consistency theorem + defect-discharge chain sketch
- Task 109 Reports 01-09: All chain-based approaches under A2 exhaustively explored
