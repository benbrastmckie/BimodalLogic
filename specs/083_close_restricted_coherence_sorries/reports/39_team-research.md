# Team Research: Bundle Architecture vs BXCanonical — Path Analysis

- **Task**: 83 - Close Restricted Coherence Sorries
- **Type**: lean4
- **Focus**: Drawing on Burgess's ideas to fix Bundle Architecture vs porting chain construction into BXCanonical
- **Date**: 2026-04-08
- **Mode**: Team Research (3 teammates)
- **Session**: sess_1775629478_49f031
- **Sources**: Reports 35-38, Teammate A (Bundle improvement), Teammate B (BXCanonical porting), Teammate C (critical risk analysis)

## Executive Summary

All three teammates converge on a decisive conclusion: **Path A (fix the Bundle architecture) is the only viable path. Path B (port chain construction into BXCanonical) is mathematically impossible.**

The user's key insight is confirmed: **FMCS families indexed by Int already IS exactly Burgess's chain construction.** The `FMCS Int` type with `mcs : Int → Set Formula` and coherence conditions (forward_G, backward_H) is precisely a ℤ-indexed chain of MCS with g_content/h_content propagation. Truth IS already evaluated at (FMCS, time, model) via `bmcs_truth fam t φ`. FMCSs are NOT points — they are entire time-indexed families.

The fix requires a single new construction: an **enriched-Succ chain builder** that includes active Until formulas in the Lindenbaum seed at each step, with dovetailed scheduling over the finite subformula closure. This resolves `succ_chain_forward_F` (the longstanding sorry) and enables the Until/Since truth lemma cases. Estimated effort: 800-1200 LOC new code, ~60% reuse from existing infrastructure.

## 1. The FMCS-as-Chain Correspondence (All Teammates Agree)

| Burgess Concept | Lean Implementation | Status |
|-----------------|-------------------|--------|
| ℤ-indexed chain of MCS | `FMCS.mcs : Int → Set Formula` | Exact match |
| g_content propagation (forward) | `FMCS.forward_G` | Exact match |
| h_content propagation (backward) | `FMCS.backward_H` | Exact match |
| Bundle of chains | `BFMCS.families : Set (FMCS Int)` | Exact match |
| Modal coherence | `BFMCS.modal_forward/backward` | Exact match |
| Chain → WorldHistory | `to_history` in CanonicalConstruction.lean | Exact match |
| Truth at (chain, time) | `truth_at M Ω (to_history fam) t φ` | Exact match |

**What IS missing from FMCS** (Teammate C): Until/Since eventuality resolution and dovetailed scheduling are not part of the FMCS type definition. The type captures G/H propagation (the easy half) but not Until/Since resolution (the hard half). This is correct — Until/Since resolution is a property of how the FMCS is *constructed*, not part of the type signature.

## 2. Why Path B (BXCanonical Port) Is Impossible

All three teammates independently confirmed this with the same argument:

**The structural blocker**: The 4 BXCanonical sorry stubs quantify over ALL BXPoints:
```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

A chain construction only gives φ at chain members (w₀, w₁, ..., wₙ). An arbitrary BXPoint between w and v in the g_content preorder is NOT necessarily on any chain.

**Why this cannot be fixed** (Teammates B, C):
1. **bx_le is not linear**: Report 37 proved this — two BXPoints above w can be incomparable under bx_le
2. **BX7 cannot establish interval linearity**: BX7 orders Until witnesses within a single MCS, not across the MCS ordering (Teammate B)
3. **φ U ψ does not propagate through g_content**: G(φ U ψ) does not follow from φ U ψ (semantically invalid — Until is consumed at the witness) (Teammate B)
4. **No sound axiom addition helps**: Report 37 proved BX axiom 4 (Burgess-Xu) is semantically invalid; no variant is strong enough (Teammate B)
5. **Changing the quantification breaks the truth lemma**: The semantic Until definition quantifies over ALL model points; restricting to chain members means the model must BE the chain (Teammate B)

**A hybrid (BXCanonical for Box/G/H + chain for Until/Since) is architecturally incoherent**: A single model cannot be "all MCS" for Box and "chain members only" for Until. The evaluation points must be uniform across all formula cases (Teammate B).

**Confidence**: 95% that Path B is blocked (all 3 teammates, reports 35-37 as evidence).

## 3. Path A: How to Fix the Bundle Architecture

### 3.1 The Core Fix: Enriched Chain Construction

The current `SuccChainFMCS` builds chains using plain successor existence, which fails for F-resolution because `f_nesting_is_bounded` is mathematically false. The fix:

**Enriched seed at step i (forward direction):**
```
seed(wᵢ, i) = g_content(wᵢ) ∪ scheduled_target(wᵢ, i)
```

Where `scheduled_target(wᵢ, i)` picks one active F-formula or Until-formula from wᵢ using round-robin scheduling (step i mod k, where k = |subformula closure|) and places its witness directly into the seed.

**Why this works:**
1. **Seed consistency**: `{target} ∪ g_content(wᵢ)` is consistent — already proven as `targeted_g_content_seed_consistent` in SuccChainFMCS.lean (Teammate A)
2. **F-resolution**: By dovetailing, every F(φ) ∈ w₀ is eventually scheduled. At that step, φ enters the seed, so φ ∈ wⱼ for some j > 0
3. **Until resolution**: For φ U ψ ∈ wᵢ: BX9 gives φ ∈ wᵢ (guard). When ψ is scheduled at step j, seed consistency follows from BX10. Guard verified at all intermediate chain members via BX5 self-accumulation + BX9

### 3.2 The Backward Direction

Two approaches identified (report 38, confirmed by Teammate C):

**Recommended — Contradiction via negation unfolding:**
1. Assume ¬(φ U ψ) ∈ w₀
2. Since φ ∈ w₀ (given guard), ¬φ ∉ w₀
3. Derive: ¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))
4. Since ¬φ ∉ w₀: G(¬(φ U ψ)) ∈ w₀
5. This propagates ¬(φ U ψ) to all future wᵢ via g_content
6. At witness wⱼ: ¬(φ U ψ) ∈ wⱼ, but ψ ∈ wⱼ → φ U ψ ∈ wⱼ (BX8). Contradiction.

**Key derivation**: Step 3 requires `¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))`. Teammate C confirms this follows from BX6 (absorption): `φ ∧ F(φ U ψ) → φ U ψ`, which gives the contrapositive direction needed. **BX6 IS in our axiom set.**

**Risk**: MEDIUM (70% confidence). The derivation appears sound but has not been formally verified in Lean. This should be verified first before committing to implementation.

### 3.3 Concrete File Changes

**Files that need NO changes** (Teammates A, C agree):
- `FMCSDef.lean` — type definition is already correct
- `BFMCS.lean` — bundle structure is already correct
- `TemporalCoherence.lean` — backward lemmas are already correct

**New file needed** (~400-800 LOC):
- `EnrichedChain.lean` (or `ChainCanonical/Chain.lean`) in `Metalogic/Bundle/`:
  - Enriched-Succ chain construction with dovetailed scheduling
  - Seed consistency proof (reuses `targeted_g_content_seed_consistent`)
  - Proof that chain satisfies FMCS coherence (forward_G, backward_H)
  - Proof of `forward_F` and `backward_P` from scheduling guarantees

**Existing file modifications** (~200-400 LOC):
- `CanonicalConstruction.lean`: Fill Until/Since truth lemma cases (lines 628-629) using chain-based eventuality resolution + BX5/BX6/BX8/BX9 axioms
- OR create a new `ChainTruthLemma.lean` that provides Until/Since proofs separately (Teammate C recommends this to avoid risking existing sorry-free proofs)

### 3.4 Infrastructure Reuse

| Existing Infrastructure | Location | Reuse in Path A |
|------------------------|----------|-----------------|
| `targeted_g_content_seed_consistent` | SuccChainFMCS.lean:2040 | Direct reuse for seed consistency |
| `g_content_closed_derivation` | Frame.lean | Direct reuse for derivation arguments |
| `to_history` (FMCS → WorldHistory) | CanonicalConstruction.lean:290 | Direct reuse |
| `CanonicalOmega` | CanonicalConstruction.lean | Direct reuse for Ω construction |
| `shifted_truth_lemma` | CanonicalConstruction.lean | Direct reuse |
| Dovetailing pattern | DovetailedChain.lean (Boneyard) | Scheduling idea reusable (Nat.unpair) |
| BX axiom lemmas | BXCanonical/Frame.lean | Direct reuse (BX5, BX6, BX8, BX9, BX10) |

## 4. Why Prior Enriched-Seed Attempts Failed (Teammate C)

All 6 Boneyard chain files failed for a **single root cause**: they used DRM-based (restricted MCS) chains, not full MCS chains.

| Report | Approach | Failure Mode |
|--------|----------|-------------|
| Report 6 | Theoretical only | No implementation attempted; used reflexive semantics (mismatch) |
| Report 17 | Chain unification | Conflated DRM chains with deterministic chains; x_content collapses |
| Report 22 | Finite deferral cycle | Backward_G requires forward_F — circular dependency |
| Report 28 | Forward_F blocker | Same circularity; formula size increases prevent well-founded induction |

**Critical insight**: No full-MCS enriched chain with dovetailed scheduling has ever been attempted. The approach proposed here is structurally different from all prior attempts. The enriched seed approach sidesteps the forward_F/backward_G circularity entirely by resolving F-obligations via seed enrichment (putting target directly into Lindenbaum seed), which does NOT require backward_G.

## 5. Conflicts Between Teammates

### 5.1 Module Organization

- **Teammate A**: Create `EnrichedChainFMCS.lean` within `Bundle/` (~400 LOC)
- **Teammate B**: Create new `ChainCanonical/` module (4 files, ~800-1200 LOC) replacing BXCanonical entirely
- **Teammate C**: New module, don't modify FMCS/BFMCS definitions, possibly new truth lemma file

**Resolution**: Teammate A's approach is most aligned with the user's directive to "improve and fix the Bundle Architecture." The enriched chain is a new FMCS construction within the existing Bundle framework, not a replacement architecture. Create `EnrichedChain.lean` within `Bundle/` for the chain construction, and either fill the Until/Since cases in `CanonicalConstruction.lean` directly or create a parallel truth lemma file. BXCanonical remains as-is (its sorries become irrelevant once Bundle-based completeness is achieved).

### 5.2 LOC Estimates

- Teammate A: ~400 LOC new + ~200 LOC modifications
- Teammate B: 800-1200 LOC new
- Teammate C: 800-1200 new + ~300 existing modifications

**Resolution**: The range depends on how much existing infrastructure is directly reusable. Teammate A's lower estimate assumes heavy reuse of `targeted_successor`. Teammate B/C's higher estimates account for the full truth lemma reproof for Until/Since. Realistic range: **600-1000 LOC new code**.

### 5.3 Whether to Modify CanonicalConstruction.lean

- Teammate A: Fill the sorry cases directly
- Teammate C: Create a separate truth lemma file to avoid breaking existing proofs

**Resolution**: Start by filling the sorry cases directly (lower complexity). If integration proves difficult, fall back to a parallel file. The sorry cases are clearly delineated (lines 628-629) and should not affect surrounding proofs.

## 6. Path Comparison Summary

| Criterion | Path A (Bundle Fix) | Path B (BXCanonical Port) |
|-----------|-------------------|--------------------------|
| **Viability** | YES | NO (mathematically impossible) |
| **Core blocker resolved** | Enriched seeds + dovetailing | BXPoint universal quantifier (unfixable) |
| **New LOC** | 600-1000 | N/A |
| **Mathematical risk** | MEDIUM (backward direction) | CRITICAL (structural impossibility) |
| **Prior failure applicability** | None — this approach is novel | N/A |
| **Infrastructure reuse** | ~60% from existing Bundle | N/A |
| **Backward direction** | BX6 contradiction (feasible) | N/A |
| **Confidence** | 75-85% | 0% |

## 7. Recommendations

### 7.1 Immediate Next Steps

1. **Verify backward direction derivation first**: Before any coding, formally derive `¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))` from BX1-BX10 in Lean. This is the key risk. If it fails, the backward approach needs revision.

2. **Create `EnrichedChain.lean`** in `Metalogic/Bundle/`:
   - Enriched-Succ chain with dovetailed scheduling
   - Reuse `targeted_g_content_seed_consistent` for seed consistency
   - Prove FMCS coherence + forward_F + backward_P

3. **Fill Until/Since truth lemma cases** in CanonicalConstruction.lean:
   - Forward Until: chain provides witness + guard verification via BX5+BX9
   - Backward Until: contradiction via negation unfolding + BX6+BX8
   - Since: mirror of Until

4. **Do NOT touch BXCanonical**: Its sorries are unfillable but harmless. It can remain as reference/alternative architecture.

### 7.2 What NOT To Do

- Do NOT attempt to fix BXCanonical Frame.lean sorries (proven impossible)
- Do NOT build DRM-based chains (6 Boneyard failures)
- Do NOT modify FMCS/BFMCS type definitions (architecturally sound as-is)
- Do NOT attempt forward_F via finite deferral cycle (circular dependency)

## 8. Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Bundle Architecture improvement | completed | HIGH (85%) |
| B | BXCanonical chain porting analysis | completed | HIGH (90%) |
| C | Critical risk analysis + path comparison | completed | MEDIUM-HIGH (75%) |

## References

- Burgess, J.P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic* Vol. II.
- Reports 35-38 in this task directory
- Teammate findings: 39_teammate-{a,b,c}-findings.md
- Codebase: FMCSDef.lean, BFMCS.lean, SuccChainFMCS.lean, CanonicalConstruction.lean, BXCanonical/Frame.lean
