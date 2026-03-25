# Teammate C: BFMCS Construction Design

**Task**: 64 - Critical path review
**Date**: 2026-03-25
**Focus**: Design a `construct_bfmcs` function that produces a modally saturated BFMCS with temporal coherence using only sorry-free infrastructure

---

## Key Findings

### Verified Sorry Status (via #print axioms)

| Theorem | Axioms | Status |
|---------|--------|--------|
| `Bimodal.Metalogic.Bundle.restricted_forward_chain_forward_F` | includes `sorryAx` | **BLOCKED** |
| `Bimodal.Metalogic.Algebraic.UltrafilterChain.temporal_theory_witness_exists` | no `sorryAx` | **SORRY-FREE** |
| `Bimodal.Metalogic.Algebraic.UltrafilterChain.past_theory_witness_exists` | no `sorryAx` | **SORRY-FREE** |
| `Bimodal.Metalogic.Algebraic.UltrafilterChain.box_theory_witness_exists` | no `sorryAx` | **SORRY-FREE** |
| `Bimodal.Metalogic.Algebraic.UltrafilterChain.boxClassFamilies_modal_forward` | no `sorryAx` | **SORRY-FREE** |
| `Bimodal.Metalogic.Algebraic.UltrafilterChain.boxClassFamilies_modal_backward` | no `sorryAx` | **SORRY-FREE** |

**Critical confirmation**: `restricted_forward_chain_forward_F` depends on `sorryAx` through `restricted_bounded_witness`'s termination sorry. This eliminates Path A (FMCS-first using restricted chains) unless the termination sorry is fixed first.

**Critical finding**: The team synthesis report recommended verifying `restricted_forward_chain_forward_F` as the FIRST step. That verification now confirms the synthesis was wrong to list it as "sorry-free" — it has the sorry. The sorry-free path must use the three witness theorems listed above.

---

## Why Singleton BFMCS Trivializes Modal Structure

A singleton BFMCS (one family, all formulas evaluated on a single MCS chain) cannot satisfy `modal_backward`:

```
modal_backward: φ ∈ ALL fam'.mcs t (for all fam' ∈ B.families) → Box(φ) ∈ fam.mcs t
```

With one family, "for all fam'" is vacuously satisfied by any formula — including contradictory ones. The entire point of having multiple families is that `box_theory_witness_exists` provides a **different** family for each Diamond-formula: when `Diamond(ψ) ∈ M`, we need a family containing `ψ` whose box-content agrees with `M`. Multiple families represent the multiplicity of accessible worlds.

Without multiple families, `modal_backward` becomes `φ ∈ fam.mcs t → Box(φ) ∈ fam.mcs t`, which forces the MCS to be Box-closed — contradicting completeness (the canonical model would validate Box(p) → p for every p, which is not a theorem of TM).

---

## Proposed Architecture: Per-Obligation Iterated Witness BFMCS

### Core Insight

The sorry-free machinery gives us:
1. **Modal witnesses**: `box_theory_witness_exists` produces W with `ψ ∈ W` and `box_class_agree(M, W)` for any `Diamond(ψ) ∈ M`. This is the basis for `boxClassFamilies_modal_forward/backward`.
2. **Temporal witnesses**: `temporal_theory_witness_exists` and `past_theory_witness_exists` produce W for any `F(φ) ∈ M` or `P(φ) ∈ M`.

The key: **for temporal coherence, we need witnesses WITHIN A CHAIN, not just witnesses somewhere in MCS-space.**

The existing `boxClassFamilies` construction builds chains via `SuccChainFMCS`, which uses a DETERMINISTIC successor function that fails temporal coherence because it cannot satisfy all F-obligations simultaneously (the `f_nesting_is_bounded` problem).

### The Architecture

Instead of building chains deterministically, build them by **iterated noncomputable choice** over the sorry-free witness theorems.

**Step 1: Build a temporally coherent ℤ-indexed chain for a given MCS M**

Given M (MCS), build chain `c : ℤ → Set Formula` by transfinite/iterated choice:
- `c(0) = M`
- For each `n ≥ 0`, choose `c(n+1)` to be a **resolving successor** of `c(n)`:
  - `c(n+1)` must satisfy: `F(φ) ∈ c(n) → φ ∈ c(n+1)` for ALL F-formulas in `c(n)`
  - `c(n+1)` must satisfy: G-theory persistence and box_class_agree with M
- For each `n ≤ 0`, choose `c(n-1)` to be a **resolving predecessor** of `c(n)`:
  - Symmetric using `past_theory_witness_exists`

**Step 2: Prove temporal coherence by construction**

`F(φ) ∈ c(n) → φ ∈ c(n+1)` holds by the choice rule — c(n+1) was chosen to resolve ALL F-obligations of c(n).

**Step 3: Build boxClassFamilies using these temporally coherent chains**

Replace `SuccChainFMCS` with the new temporally coherent chain in the `boxClassFamilies` definition. Modal coherence follows from the same `boxClassFamilies_modal_forward/backward` argument (it only needs `box_class_agree`, which the new chains preserve).

---

## How It Handles Modal Saturation

Modal saturation requires: for every `Diamond(ψ) ∈ fam.mcs t`, there exists `fam' ∈ B.families` such that `ψ ∈ fam'.mcs t`.

This is handled by the `boxClassFamilies` construction: for any `Diamond(ψ) ∈ M`, `box_theory_witness_exists` gives W with `ψ ∈ W` and `box_class_agree(M, W)`. We build the temporally coherent chain from W (starting at time t), and this chain is in the bundle.

The existing `boxClassFamilies_modal_forward` and `boxClassFamilies_modal_backward` proofs are sorry-free and apply to ANY collection of families indexed by box-class-agreeing MCSes with shifted chains. They do not depend on HOW the chains are built internally — only that `box_class_agree` holds and `Box` formulas are persistent. Both properties hold for the new construction.

---

## How It Handles Temporal Coherence

### The Central Challenge

The challenge is building a "resolving successor" that satisfies **ALL** F-obligations of the current node simultaneously, not just one.

The `resolving_successor_seed` infrastructure (already in `UltrafilterChain.lean`) handles single-obligation resolution: given `F(φ) ∈ M`, the seed `{φ} ∪ temporal_box_seed M` is consistent (proven sorry-free by `resolving_successor_seed_consistent`). But the chain needs to resolve ALL F-obligations at each step.

### The Multi-Obligation Seed

The key question is: given `F(φ₁), F(φ₂), ..., F(φₙ) ∈ M`, is `{φ₁, φ₂, ..., φₙ} ∪ temporal_box_seed M` consistent?

**Positive case (all φᵢ already implied by G-content)**:
If all φᵢ are in `g_content M` (i.e., `G(φᵢ) ∈ M`), then by G-persistence, they are all in any temporal witness. So `{φ₁, ..., φₙ} ∪ temporal_box_seed M` is consistent because `temporal_box_seed M` already contains them.

**General case (some φᵢ not in g_content M)**:
If `F(φᵢ) ∈ M` and `G(φᵢ) ∉ M`, then by MCS negation completeness, `F(neg(φᵢ))... no wait — `¬G(φᵢ) ∈ M` means `F(¬φᵢ) ∈ M` (by TM axioms). So we have both `F(φᵢ) ∈ M` and `F(¬φᵢ) ∈ M`. This means we need a successor containing BOTH `φᵢ` and `¬φᵢ`, which is impossible.

**Resolution**: This is NOT required. `F(φ) ∈ M` and `F(¬φ) ∈ M` can coexist (e.g., on the integers, a world sees two different futures — one with φ and one with ¬φ). Temporal coherence only requires that EACH F-formula has SOME future witness, not a COMMON future witness.

This means: we cannot resolve ALL F-obligations at a single successor step in general. We need one step per F-obligation, or we need to prove that the multi-obligation seed is consistent.

---

## The Central Technical Challenge

**The fundamental problem**: `F(φ) ∈ M` and `F(¬φ) ∈ M` can coexist in an MCS. So we cannot have a single successor containing `φ` AND `¬φ`. Therefore we cannot satisfy ALL F-obligations of M in a single successor.

This means temporal coherence via "one-step resolution" is impossible in general. The chain must satisfy F-obligations **eventually** (at some point in the future), not necessarily at the immediately next step.

### What `temporal_theory_witness_exists` Actually Gives

The theorem provides W with:
1. `φ ∈ W`
2. G-theory agreement: `G(a) ∈ M → G(a) ∈ W`
3. `box_class_agree(M, W)`

But NOT: `F(ψ) ∈ M → F(ψ) ∈ W` (no F-obligation inheritance). So the successor may have DIFFERENT F-obligations than M.

However: G-theory agreement ensures that G-consequences of M persist. By the TM axiom `G(φ) → G(G(φ))` (G is idempotent), the G-content is stable. But F-obligations can come and go.

### The Omega-Enumeration Approach

**Proposed solution**: Instead of satisfying all F-obligations at once, use **dovetailing**: enumerate all F-obligations of `c(n)` as `φ₁(n), φ₂(n), ...` (finitely or countably many) and resolve them one by one across the chain.

Specifically:
- `c(n+1)` resolves the **oldest unresolved** F-obligation using `temporal_theory_witness_exists`
- An F-obligation `F(φ) ∈ c(t)` is "resolved at step s > t" if `φ ∈ c(s)`
- Dovetailing ensures every F-obligation is eventually resolved in finite steps

**Coherence proof**: For any `F(φ) ∈ c(t)`, the obligation `(t, φ)` is in the enumeration at step t. By dovetailing, it is resolved at some step `t + k`, so `∃ s > t, φ ∈ c(s)`. This is exactly `forward_F`.

**Key properties preserved at each step**:
- G-theory agreement propagates by induction: G-content accumulates along the chain
- box_class_agree is preserved: `temporal_theory_witness_exists` gives `box_class_agree` for each step

This gives temporal coherence BY CONSTRUCTION, with no termination issues (it's an infinite chain defined by Choice, not a recursive function).

---

## Proposed Solutions to the Challenge

### Solution 1: Omega-Enumeration Chain (Primary Recommendation)

**Construction**:
```
-- Given MCS M, enumerate all F-obligations ever arising in the chain
-- c(0) = M
-- At step n+1: pick the oldest unresolved (t, φ) pair (where F(φ) ∈ c(t))
--              use temporal_theory_witness_exists to get c(n+1) with φ ∈ c(n+1)
--              and box_class_agree(c(n), c(n+1))
-- Backward: symmetric with past_theory_witness_exists
```

**Why it works**: Dovetailing ensures every `F(φ) ∈ c(t)` is resolved in finitely many steps. The chain is noncomputable but well-defined by iterated Choice (which Lean already uses for Lindenbaum). G-theory propagation gives the needed persistence.

**Lean formalization**:
- Define `omega_chain_forward : ℕ → Set Formula` by `Nat.rec` + `Classical.choice`
- Prove `omega_chain_forward_coherent : ∀ n φ, F(φ) ∈ chain(n) → ∃ m > n, φ ∈ chain(m)` by induction on the enumeration order
- The backward direction mirrors this

**Key lemma needed (not yet in codebase)**:
```
omega_chain_all_F_eventually_resolved (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ c : ℕ → Set Formula,
      c 0 = M ∧
      (∀ n, SetMaximalConsistent (c n)) ∧
      (∀ n, box_class_agree M (c n)) ∧
      (∀ n φ, Formula.some_future φ ∈ c n → ∃ m > n, φ ∈ c m)
```

**Challenges**:
1. Formalizing the dovetailing enumeration cleanly in Lean
2. Proving G-theory persistence propagates through the chain (G(a) ∈ c(0) → G(a) ∈ c(n) for all n)
3. Showing box_class_agree is preserved at each step (not just from M to the next, but transitively? — actually each step uses `temporal_theory_witness_exists` which gives box_class_agree with the PREVIOUS node, not with M₀. Need transitivity of box_class_agree.)

**Critical sub-challenge**: `box_class_agree` transitivity. If `box_class_agree(M, W)` and `box_class_agree(W, V)`, does `box_class_agree(M, V)` hold? This is needed for the chain to stay in the same box class as M₀.

### Solution 2: Fix Restricted Chain Termination (Alternative)

Fix the `all_goals sorry` in `restricted_bounded_witness` (SuccChainFMCS.lean:2402-2405) by replacing the termination measure `d` with a lexicographic measure `(global_bound - k, d)` where `global_bound` is the maximum F-nesting depth in `deferralClosure(φ)`.

**Why this works**: Within `deferralClosure(φ)`, F-nesting is bounded by `f_nesting_is_bounded_restricted` (sorry-free). So there is a global bound K on F-depths in the chain. The recursive call in the `d' > 1` case increases the depth but the chain can only defer finitely many times before being forced to resolve. The lexicographic measure `(K × max_pos - cumulative_steps, d)` is decreasing.

**Challenges**:
1. Need to formalize the global fuel argument — requires threading a bound K through the recursion
2. The current function signature doesn't include K; restructuring needed
3. After fixing, still need the backward chain (`restricted_backward_chain`) — ~200 LOC new work
4. After that, dovetailing forward and backward into a ℤ-indexed FMCS — ~100 LOC
5. After that, singleton BFMCS wrapper — but this FAILS (see "Why Singleton Fails" above)

**Revised singleton issue**: The synthesis report proposed singleton BFMCS but the team lead confirms this is wrong. So after fixing the termination sorry and building the ℤ-chain, we still need the boxClassFamilies approach for modal saturation. The temporal coherence proof for boxClassFamilies must be re-done using the fixed restricted chain — feasible but requires replacing `SuccChainFMCS` with a temporally coherent chain in the bundle definition.

---

## Risk Analysis

| Approach | Core Difficulty | Estimated LOC | Confidence |
|----------|----------------|---------------|------------|
| Solution 1: Omega enumeration | `box_class_agree` transitivity + dovetailing formalization | ~500-700 | MEDIUM (55%) |
| Solution 2: Fix termination sorry | Restructuring recursive proof with global fuel | ~400-600 + 200 backward | MEDIUM-LOW (40%) |

**Shared risk**: Both solutions require proving that the constructed families are in the same box class as M₀ throughout the chain. Solution 1 makes this explicit (must prove `box_class_agree` transitivity); Solution 2 relies on `DeferralRestrictedMCS` staying in the same box class (which should hold since the restricted chain was designed for this).

**Biggest uncertainty — `box_class_agree` transitivity**:
```lean
-- Is this provable?
theorem box_class_agree_trans (M W V : Set Formula)
    (h1 : box_class_agree M W) (h2 : box_class_agree W V) : box_class_agree M V
```
This holds for S5 (Box formulas are absolute in S5 — they evaluate the same in any accessible world). Since `box_class_agree M W` means `∀ φ, Box(φ) ∈ M ↔ Box(φ) ∈ W`, transitivity follows immediately by iff-transitivity. **This IS provable and is likely already in the codebase or trivially provable.** Let me flag this as a required check.

---

## Architecture Summary

The target architecture for `construct_bfmcs`:

```
-- Input: M (MCS)
-- Output: BFMCS B with B.temporally_coherent, containing M at some time t

1. Build omega_chain_forward(M) : ℕ → Set Formula  [sorry-free by construction]
2. Build omega_chain_backward(M) : ℕ → Set Formula  [sorry-free by construction]
3. Dovetail into ℤ-chain: c(n) = forward(n) for n≥0, backward(-n) for n<0
4. Wrap as FMCS_from_chain M
5. Build boxClassFamilies using FMCS_from_chain instead of SuccChainFMCS
   -- i.e., redefine boxClassFamilies to use the omega chain
6. Prove temporal_coherence for the new bundle:
   -- forward_F: by omega_chain_forward_coherent
   -- backward_P: by omega_chain_backward_coherent
7. Prove modal_coherence: same proof as boxClassFamilies_modal_forward/backward
   -- Only needs box_class_agree, which omega chain preserves
8. Provide to parametric_algebraic_representation_conditional
```

This yields a sorry-free `construct_bfmcs` because:
- Steps 1-2 use `temporal_theory_witness_exists` / `past_theory_witness_exists` (sorry-free)
- Step 6 temporal coherence holds by construction (dovetailing)
- Step 7 modal coherence reuses the existing sorry-free proofs
- No `f_nesting_is_bounded`, no `restricted_bounded_witness`, no `boundary_resolution_set`

---

## Effort Estimate

**Minimum path** (Solution 1, if `box_class_agree` transitivity is provable and dovetailing formalizes cleanly):
- `omega_chain_forward` construction + properties: ~150 LOC
- `omega_chain_backward` construction + properties: ~150 LOC
- ℤ-chain dovetailing: ~80 LOC
- New `boxClassFamilies_temporal` (replacing SuccChainFMCS with omega chain): ~100 LOC
- Temporal coherence proof for new bundle: ~100 LOC
- Wire to `parametric_algebraic_representation_conditional`: ~50 LOC
- **Total**: ~630 LOC, estimated 8-12 hours

**Blocking sub-lemma to verify first**:
```lean
theorem box_class_agree_trans : box_class_agree M W → box_class_agree W V → box_class_agree M V
```
If this is already in the codebase (check `UltrafilterChain.lean`) or trivially provable (it should be), the architecture is sound. If it is not provable (which would be surprising for S5), the whole approach collapses.

---

## Confidence Level

**HIGH** on the diagnosis:
- `restricted_forward_chain_forward_F` confirmed sorry-blocked (verified with #print axioms)
- Singleton BFMCS confirmed wrong (would trivialize modal_backward)
- Three witness theorems confirmed sorry-free
- `boxClassFamilies_modal_forward/backward` confirmed sorry-free

**MEDIUM** on the proposed solution:
- The omega-enumeration approach is mathematically sound
- The dovetailing argument is standard in completeness proofs for temporal logics
- The main risk is whether the Lean formalization of the omega chain is clean or requires unexpected infrastructure
- `box_class_agree` transitivity is the critical check — if this is provable (very likely), confidence rises to MEDIUM-HIGH

**Recommended immediate action**: Check if `box_class_agree_trans` exists or is trivially provable in `UltrafilterChain.lean`. If yes, the omega-enumeration architecture is the clear path forward.

---

## References

### Source Files Examined
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:1130-1660` — `temporal_theory_witness_exists`, `past_theory_witness_exists`, `resolving_successor_seed`, `boxClassFamilies`, modal forward/backward proofs
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:2370-2497` — `restricted_bounded_witness` (sorry location), `restricted_forward_chain_forward_F`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean:252-270` — `parametric_algebraic_representation_conditional` signature

### Axiom Verifications (via #print axioms)
- `restricted_forward_chain_forward_F`: CONFIRMED sorryAx
- `temporal_theory_witness_exists`: CONFIRMED sorry-free
- `past_theory_witness_exists`: CONFIRMED sorry-free
- `box_theory_witness_exists`: CONFIRMED sorry-free
- `boxClassFamilies_modal_forward`: CONFIRMED sorry-free
- `boxClassFamilies_modal_backward`: CONFIRMED sorry-free
