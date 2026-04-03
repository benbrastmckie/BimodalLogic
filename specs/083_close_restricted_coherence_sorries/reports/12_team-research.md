# Research Report: Task #83 — g_content Blocker Root Cause and Resolution

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Mode**: Team Research (4 teammates: 3 researchers + 1 critic)
**Session**: sess_1775239846_892a9f
**Builds on**: Report 11 (strict refactor specification), implementation summary (phases 1-4 complete)

## Summary

Four agents investigated the `g_content(M) ⊆ successor(M)` blocker that arose after removing the T-axiom (`G(φ) → φ`) under strict semantics. The team found three independent resolution paths covering all 26 sorry sites, with the critical breakthrough being a derivation of `G(a) → X(a)` from the existing 33-axiom system using `prop_s` (weakening) + `until_induction`.

**The headline finding**: The blocker decomposes into three independent tiers requiring different fix strategies. Tier 1 (seed-based, ~11 sites) requires NO new theorems — the sorry sites were using an unnecessary T-axiom detour when the seed already contained g_content directly. Tier 2 (coherence theorems, ~8 sites) requires the derived theorem `G(a) → X(a)` plus changing `≥` to `>` in theorem statements. Tier 3 (algebraic/ultrafilter, ~7 sites) requires restructuring since `R_G` is NOT reflexive under strict semantics.

## Key Findings

### 1. `g_content(M) ⊆ successor(M)` Is Semantically Valid (ALL teammates — HIGH confidence)

All teammates agree unanimously: under strict semantics on ℤ, if `G(a) ∈ MCS(t)` (meaning `a` at all `s > t`), then `a ∈ MCS(t+1)` (since `t+1 > t`). The property is semantically correct. The issue is purely proof-theoretic — finding a derivation route that doesn't use the now-invalid T-axiom.

### 2. `G(a) → X(a)` IS Derivable from the Current 33 Axioms (Teammates A, B — HIGH confidence; Teammate D initially skeptical but derivation is valid)

**This is the central mathematical finding of this research round.**

The derivation uses `prop_s` (weakening: `a → (B → a)`) as the key insight to satisfy `until_induction`'s second premise without circularity:

```
THEOREM: G(a) → X(a)   where X(a) = ⊥ U a

PROOF:
  1. ⊢ a → ((⊤ ∧ X(a)) → a)          -- prop_s instance (a → (B → a))
  2. ⊢ G(a → ((⊤ ∧ X(a)) → a))        -- temporal necessitation of step 1
  3. ⊢ G(a → ((⊤ ∧ X(a)) → a))
       → (G(a) → G((⊤ ∧ X(a)) → a))   -- temp_k_dist
  4. G(a) ⊢ G((⊤ ∧ X(a)) → a)         -- MP on steps 2-3 with hypothesis G(a)
  5. ⊢ a → a                            -- identity (propositional tautology)
  6. ⊢ G(a → a)                         -- temporal necessitation of step 5
  7. G(a) ⊢ G(a→a) ∧ G((⊤∧X(a))→a)    -- conjunction of steps 4, 6
  8. until_induction(φ=⊤, ψ=a, χ=a):
     G(a→a) ∧ G((⊤∧X(a))→a)
       → (⊤ U a → X(a))                -- axiom instance
  9. G(a) ⊢ ⊤ U a → X(a)               -- MP on steps 7-8
  10. ⊢ G(a) → F(a)                     -- seriality_future
  11. ⊢ F(a) → ⊤ U a                   -- F_until_equiv
  12. G(a) ⊢ X(a)                        -- chain: G(a)→F(a)→⊤ U a→X(a)

  Therefore: ⊢ G(a) → X(a)  (by deduction theorem)
```

**Why Teammate D's objection was wrong**: D argued the second premise `G(⊤ ∧ X(a) → a)` requires knowing `a` at each future time point, creating circularity. But `prop_s` gives `a → (anything → a)` as a purely propositional tautology — no temporal content needed. Temporal necessitation + K-distribution then yield `G(a) → G(anything → a)` from `G(a)` alone.

**Dual theorem**: `H(a) → Y(a)` (where `Y(a) = ⊥ S a`) follows symmetrically using `since_induction`, `seriality_past`, and `P_since_equiv`.

**Required axioms**: `prop_s`, `temp_k_dist`, `seriality_future`, `F_until_equiv`, `until_induction` — all present in the current system. No 34th axiom needed.

### 3. The Sorry Sites Decompose Into Three Independent Tiers (Teammates A, B, C — HIGH confidence)

| Tier | Sites | Fix Strategy | Difficulty |
|------|-------|-------------|------------|
| 1: Seed-based | ~11 | Direct seed membership | EASY |
| 2: Coherence theorems | ~8 | G(a)→X(a) derivation + strict inequality | MEDIUM |
| 3: Algebraic/ultrafilter | ~7 | Structural restructuring (R_G not reflexive) | HARD |

### 4. Tier 1: Seed-Based Fixes — No New Theorems Needed (Teammates A, B — HIGH confidence)

**Critical discovery**: Many sorry sites were using an unnecessary T-axiom detour. The witness seeds already contain `g_content(M)` directly:

- `temporal_theory_witness_exists` builds from seed `{φ} ∪ G_theory(M) ∪ box_theory(M)`. While this seed contains `G(a)` (not `a` directly), Teammate B showed the seed can be EXTENDED to include `g_content(M)` with a clean consistency proof.
- `successor_deferral_seed` is defined as `g_content(u) ∪ deferralDisjunctions(u)` — already includes g_content directly.

**The seed enrichment consistency proof** (Teammates B, C — HIGH confidence):

All elements of `temporal_box_seed(M) ∪ g_content(M)` are G-liftable:
- `G_theory(M)` elements: G-liftable via `temp_4` (`G(a) → G(G(a))`)
- `box_theory(M)` elements: G-liftable via existing `G_of_box_theory` proof
- `g_content(M)` elements `a`: G-liftable by definition (`G(a) ∈ M`)

If the enriched seed `{φ} ∪ temporal_box_seed(M) ∪ g_content(M)` were inconsistent, the G-lift argument gives `G(⊥) ∈ M`, contradicting `G(⊤) ∈ M` (theorem, via seriality). QED.

**Affected sites**: `forward_step_g_content` (DovetailedChain:142), `temporal_witness_g_persistence` (UltrafilterChain:2591), `build_targeted_successor_g_persistence` (MCSWitnessSuccessor:259), and mirror H-direction sites.

### 5. Tier 2: Coherence Theorems Need G(a)→X(a) + Strict Inequality (Teammates A, C — HIGH confidence)

The forward/backward coherence theorems currently state:
```
G(φ) ∈ chain(n) → φ ∈ chain(m) for m ≥ n
```

Under strict semantics, the `m = n` case is FALSE (that's the T-axiom). The correct statement is:
```
G(φ) ∈ chain(n) → φ ∈ chain(m) for m > n  (strictly greater)
```

**Base case** (`m = n+1`): Uses `G(a) → X(a)` to get `X(a) ∈ chain(n)`, then chain successor resolves `X(a)` to give `a ∈ chain(n+1)`.

**Inductive step** (`m > n+1`): `G(a) ∈ chain(n) → G(a) ∈ chain(n+1)` by G-propagation (temp_4), then apply the base case at `n+1`.

**Affected sites**: `forward_dovetailed_forward_G`, `forward_dovetailed_backward_H`, backward chain duals.

### 6. Tier 3: Algebraic Path — R_G Is NOT Reflexive (ALL teammates — HIGH confidence)

Under strict semantics, `R_G U U` (defined as `∀ a, G(a) ∈ U → a ∈ U`) is FALSE for general ultrafilters. The Lindenbaum algebra sites that assert `G(a) ≤ a` are semantically invalid.

**Specifically FALSE**:
- `R_G_refl` (UltrafilterChain:97)
- `R_H_refl` (UltrafilterChain:267)
- `forward_G` lattice ordering (UltrafilterChain:520)
- `backward_H` lattice ordering (UltrafilterChain:565)

**Exception**: `G(⊥) → ⊥` IS derivable (via seriality: `G(⊥) → F(⊥)`, and `F(⊥) = ¬G(⊤)` contradicts the theorem `G(⊤)`). So UltrafilterChain:1009 and :1318 can be fixed.

**Resolution options** (Teammate D's analysis):
1. Delete `R_G_refl`/`R_H_refl` entirely; restructure the algebraic approach to use strict accessibility
2. Replace `R_G` with `R_X` (next-step relation)
3. Accept that the algebraic/ultrafilter path is secondary and may carry sorries while the primary MCS-chain path is sorry-free

### 7. SuccChainFMCS Pattern B: g_content(u) ⊆ u Is FALSE (Teammate D — HIGH confidence)

The `DeferralRestrictedMCS` construction assumes `g_content(u) ⊆ u` (formulas `a` where `G(a) ∈ u` are also in `u`). This is semantically false under strict semantics — an MCS can contain `G(a)` without containing `a`.

**However**, the downstream proofs may only need `g_content(u_parent) ⊆ u` (parent's g_content in the child), which IS guaranteed by the seed construction. Teammate C identified that the `neg_neg_bot` case (SuccChainFMCS:4419) has a clean fix since `¬¬⊥` is a propositional tautology.

**Recommendation**: Audit whether SuccChainFMCS actually needs self-g_content (`g_content(u) ⊆ u`) or only parent-g_content (`g_content(parent) ⊆ u`). If only the latter, the sorry sites are resolvable without restructuring.

## Conflicts Resolved

### Conflict 1: Is G(a) → X(a) derivable?

- **Teammates A, B**: YES, via `prop_s` + `until_induction`
- **Teammate D**: Initially NO (85% confidence)
- **Resolution**: A and B's derivation is correct. The key insight (`prop_s` gives `G(a) → G(B → a)` for ANY `B`) resolves Teammate D's circularity objection. D's analysis missed that `prop_s` is a propositional axiom requiring no temporal content.

### Conflict 2: Is seed enrichment or G(a)→X(a) the primary fix?

- **Teammate B**: Seed enrichment is primary; G(a)→X(a) is "useful but does NOT fix the sorries"
- **Teammate A**: G(a)→X(a) is primary for Track 3; seed-based is Track 1
- **Resolution**: BOTH are needed. They address different tiers. Seed enrichment handles Tier 1 (direct membership). G(a)→X(a) handles Tier 2 (coherence theorems). Neither alone resolves everything.

### Conflict 3: How many sorry sites are there?

- **Teammate C**: 26 sites
- **Teammate A**: ~32 sites
- **Teammate D**: 14 sites
- **Resolution**: Teammate C's count of 26 is the most precise (file-by-file inventory). The discrepancy comes from different counting of related sites (some are in comments or dead code).

## Gaps Identified

1. **SuccChainFMCS self-g_content audit**: Need to verify whether downstream proofs need `g_content(u) ⊆ u` or only `g_content(parent) ⊆ u`. This determines whether SuccChainFMCS needs restructuring.

2. **Exact derivation tree for G(a) → X(a)**: The proof sketch is complete but the actual Lean `DerivationTree` construction needs implementation. This is mechanical but non-trivial.

3. **Algebraic path decision**: Whether to fix, defer, or abandon the R_G-based algebraic/ultrafilter approach under strict semantics. This is an architectural decision.

4. **Boneyard review**: All past failures (FPreservingSeed, BidirectionalSeed, CoherentZChain) tried adding non-G-liftable elements to seeds — this pattern consistently fails. Strategy A (adding only G-liftable elements) succeeds because g_content elements ARE G-liftable by definition.

## Recommendations

### Implementation Priority Order

1. **Prove `G(a) → X(a)` and `H(a) → Y(a)` as derived theorems** (new file or in Combinators)
   - Uses: `prop_s`, `temp_k_dist`, `seriality_future`, `F_until_equiv`, `until_induction`
   - This is the mathematical crux; everything else is mechanical

2. **Enrich `temporal_box_seed` to include `g_content(M)`**
   - Add `g_content(M)` to the seed
   - Prove consistency via the G-lift argument (all elements G-liftable)
   - This resolves Tier 1 sorry sites immediately

3. **Fix coherence theorems with strict inequality**
   - Change `m ≥ n` to `m > n` in forward_G, backward_H theorems
   - Base case uses `G(a) → X(a)` + successor resolution
   - Inductive step uses `temp_4` + base case

4. **Handle R_G/R_H reflexivity**
   - Delete `R_G_refl`, `R_H_refl`
   - Fix `G(⊥) → ⊥` via seriality argument
   - Decide on algebraic path: restructure or defer with sorries

5. **Audit and fix SuccChainFMCS Pattern B sites**
   - Check if self-g_content is needed or parent-g_content suffices
   - Fix `neg_neg_bot` case (propositional tautology, trivial)

### Estimated Effort

| Tier | Sites | Effort | Dependencies |
|------|-------|--------|--------------|
| Derived theorem G→X, H→Y | 0 (foundational) | 2-3 hours | None |
| Tier 1: Seed enrichment | ~11 | 3-4 hours | G→X for consistency proof |
| Tier 2: Coherence strict inequality | ~8 | 2-3 hours | G→X theorem |
| Tier 3: Algebraic restructure | ~7 | 4-6 hours | Decision on approach |
| SuccChainFMCS audit + fixes | ~4 | 2-3 hours | Tier 1 |
| **Total** | **~30** | **13-19 hours** | |

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|-----------------|------------|
| A | Root cause | completed | G(a)→X(a) derivation via prop_s; two-track classification | HIGH |
| B | Alternatives | completed | Seed enrichment strategy; G-lift consistency proof; Boneyard review | HIGH |
| C | Lean code | completed | 26-site inventory with exact signatures; 4-category taxonomy | HIGH |
| D | Critic | completed | Pattern B (self-g_content) identified as FALSE; R_G non-reflexivity | HIGH |

## References

- Teammate A findings: `reports/12_teammate-a-findings.md`
- Teammate B findings: `reports/12_teammate-b-findings.md`
- Teammate C findings: `reports/12_teammate-c-findings.md`
- Teammate D findings: `reports/12_teammate-d-findings.md`
- Prior research: `reports/10_team-research.md` (strict semantics analysis)
- Refactor specification: `reports/11_strict-refactor-specification.md`
- Boneyard: `Theories/Bimodal/Boneyard/UltrafilterDeadCode/`
