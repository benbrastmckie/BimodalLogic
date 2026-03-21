# Wave 2 Research Report: Optimal Path to Sorry-Free Proofs

**Task**: 880 - Investigate augmented extension seed approach (CONTINUATION)
**Date**: 2026-02-12
**Focus**: Determine which approach offers the most mathematically elegant path to sorry-free proofs
**Role**: Wave 2 Teammate A

## Sorry Site Analysis

### ZornFamily.lean (12 sorry sites)

| Line | Location | Difficulty | Root Cause | Approach |
|------|----------|-----------|------------|----------|
| 844 | `multi_witness_seed_consistent_future` (Psis nonempty case) | **IMPOSSIBLE** | FALSE lemma -- multiple F-witnesses can conflict (F(p) and F(neg p)) | Delete or weaken |
| 874 | `multi_witness_seed_consistent_past` (Psis nonempty case) | **IMPOSSIBLE** | FALSE lemma -- symmetric to above | Delete or weaken |
| 888 | `extensionSeed_consistent` (cross-sign case) | **HARD** | Both past and future domain times; need GContent + HContent + FObl + PObl compatible | Solvable with collect-into-reference-MCS |
| 1120 | `extensionSeed_consistent` (pure past, F-obligations present) | **IMPOSSIBLE** | Depends on `multi_witness_seed_consistent_future` which is false | Needs architectural change |
| 1260 | `extensionSeed_consistent` (pure future, P-obligations present) | **IMPOSSIBLE** | Depends on `multi_witness_seed_consistent_past` which is false | Needs architectural change |
| 1764 | `extendFamilyAtUpperBoundary.forward_F` (old to new) | MEDIUM | F phi in old MCS, need phi in new MCS at upper boundary; solvable if FObl in seed and seed subset of mcs_t | Seed inclusion argument |
| 1786 | `extendFamilyAtUpperBoundary.backward_P` (new to old) | **HARD** | P phi in new MCS, need phi in old MCS for old time s < t; not derivable from seed structure | Requires reverse-direction argument |
| 1928 | `extendFamilyAtLowerBoundary.forward_F` (new to old) | **HARD** | Symmetric to line 1786 | Requires reverse-direction argument |
| 1968 | `extendFamilyAtLowerBoundary.backward_P` (old to new) | MEDIUM | Symmetric to line 1764 | Seed inclusion argument |
| 2091 | `non_total_has_boundary` (internal gap case) | MEDIUM | s_below < t < s_above, all in domain, t not in domain | Needs general extension or alternative boundary-finding argument |
| 2161 | `maximal_implies_total.h_G_from_new` | MEDIUM-HARD | G phi in new MCS must propagate to old MCS at s > t (lower boundary case) | Requires controlled Lindenbaum |
| 2168 | `maximal_implies_total.h_H_from_new` | MEDIUM-HARD | H phi in new MCS must propagate to old MCS at s < t (upper boundary case) | Requires controlled Lindenbaum |

**Classification Summary**:
- **3 IMPOSSIBLE**: Lines 844, 874, 1120/1260 -- depend on false lemmas about multi-witness consistency
- **3 HARD**: Lines 888, 1786, 1928 -- require significant new arguments
- **4 MEDIUM**: Lines 1764, 1968, 2091, 2161/2168 -- solvable with moderate effort
- **2 MEDIUM-HARD**: Lines 2161, 2168 -- require controlled Lindenbaum or alternative

### DovetailingChain.lean (4 sorry sites)

| Line | Location | Difficulty | Root Cause | Approach |
|------|----------|-----------|------------|----------|
| 606 | `buildDovetailingChainFamily.forward_G` (t < 0 cross-sign) | **HARD** | G phi in backward chain at t < 0 must propagate to forward chain at t' >= 0 | Needs global chain property |
| 617 | `buildDovetailingChainFamily.backward_H` (t >= 0 cross-sign) | **HARD** | H phi in forward chain at t >= 0 must propagate to backward chain at t' < 0 | Needs global chain property |
| 633 | `buildDovetailingChainFamily_forward_F` | **HARD** | Existential F witness -- requires dovetailing enumeration construction | Entire construction redesign |
| 640 | `buildDovetailingChainFamily_backward_P` | **HARD** | Existential P witness -- symmetric to above | Entire construction redesign |

**Classification Summary**: All 4 are HARD, none are impossible.

## Recommended Primary Approach: "Drop forward_F/backward_P, Fix Remaining"

### Approach Description

Remove the `forward_F` and `backward_P` fields from `GHCoherentPartialFamily`, returning to the original G/H-only coherence design. Then:

1. The Zorn construction preserves G/H coherence through chains (already proven).
2. Maximality implies totality using ONLY G/H seed (no F/P obligations in seed).
3. For total families, F/P satisfaction follows from a **separate post-hoc argument** using maximality + temporal logic axioms.

### Detailed Justification

**Why this works**: The research-001 report identifies the fundamental tension -- `forward_F` as a structural field is **incompatible** with domain extension because F(p) and F(neg p) can coexist in the same MCS. Removing forward_F/backward_P from the structure eliminates:

1. **Lines 844, 874 (IMPOSSIBLE)**: No longer needed -- `multi_witness_seed_consistent_future/past` is never called because there are no F/P obligations in the seed.
2. **Lines 1120, 1260 (IMPOSSIBLE)**: Same -- pure past/future cases no longer include F/P obligations.
3. **Lines 1764, 1786, 1928, 1968 (extension sorries)**: Gone entirely -- extension functions no longer need forward_F/backward_P fields.
4. **Lines 2161, 2168 (maximal_implies_total)**: Simplified -- only G/H propagation from new to old, which is more tractable.

**What remains after dropping forward_F/backward_P**:

| Line | Difficulty After Drop | Notes |
|------|----------------------|-------|
| 888 | MEDIUM | Cross-sign seed: GContent + HContent only (no F/P obligations). Solvable via propagation to reference MCS. |
| 2091 | MEDIUM | Internal gap: still needs general extension, but seed is simpler. |
| 2161 | MEDIUM | G from new to old at lower boundary: G phi in mcs_t, need phi in F.mcs s for s > t. This follows from T-axiom if mcs_t is built correctly. |
| 2168 | MEDIUM | H from new to old at upper boundary: symmetric to 2161. |
| **NEW** | HARD | F/P recovery for total families -- the core theorem that was previously "free" from the structural field. |

**The critical remaining challenge**: Proving F/P recovery for total G/H-coherent families. This is the **single domino sorry** whose resolution cascades to all others.

### F/P Recovery Theorem (the Key Lemma)

**Statement**: If F is a maximal G/H-coherent partial family with domain = Set.univ, and F(phi) is in F.mcs(t), then there exists s > t with phi in F.mcs(s).

**Proof Strategy**: By contradiction. If no such s exists, then for all s > t, phi is NOT in F.mcs(s). Since each F.mcs(s) is an MCS, neg(phi) is in F.mcs(s) for all s > t. Then G(neg phi) holds universally from t, meaning G(neg phi) should be in F.mcs(t) (by maximality / "reverse necessitation" argument). But F(phi) = neg(G(neg phi)) is also in F.mcs(t), contradiction.

**Technical challenge**: The step "neg(phi) in F.mcs(s) for all s > t implies G(neg phi) in F.mcs(t)" is NOT immediate from forward_G. It is a kind of "reverse necessitation" or "omega-rule" argument. This step requires either:
- (a) A compactness argument: if neg(phi) holds at all future times, then by compactness of the proof system, G(neg phi) is derivable.
- (b) A maximality argument: if the family is maximal (cannot be extended), then it must be "saturated" in a strong sense.
- (c) A more direct argument from the structure of the Zorn construction.

**Reality check**: This is NOT straightforward. The omega-rule does not hold in general for finitary proof systems. The argument "if phi holds everywhere, then G(phi) holds" is a SEMANTICS fact (about frames with universal future accessibility), not a SYNTACTIC fact. In the Zorn-based construction, we are building syntactic objects (MCS), so this semantic argument does not directly apply.

**Alternative for F/P recovery**: The MCS F.mcs(t) is maximal consistent. If F(phi) is in it, then neg(G(neg phi)) is in it, so G(neg phi) is NOT in it. But this does not immediately give us phi in some future F.mcs(s). The issue is that "G(neg phi) not in F.mcs(t)" tells us about what is derivable from F.mcs(t), not about what is in F.mcs(s) for specific s.

### Reassessment: The F/P Recovery Gap

After careful analysis, I must revise the optimism about the "drop forward_F/backward_P" approach:

**The F/P recovery problem is exactly as hard as the original problem.** The reason forward_F was added as a structural field is precisely because F/P recovery for total G/H-only families could not be proven. The circular dependency noted at line 2221-2222 is real:

- To prove F/P recovery, you need F/P obligations in the seed
- To have F/P obligations in the seed, you need forward_F in the structure
- To preserve forward_F through Zorn chains, you need it at each step
- At each step, proving forward_F requires seed consistency with F/P obligations
- Seed consistency with F/P obligations requires multi_witness_seed_consistent, which is FALSE

This is a genuine mathematical impasse for the Zorn approach.

## Evaluation: DovetailingChain as Alternative

### DovetailingChain Sorry Analysis

The 4 DovetailingChain sorries divide into two pairs:

**Pair 1: Cross-sign G/H propagation (lines 606, 617)**

The forward and backward chains share M_0 but are otherwise independent. For t < 0, t' > 0:
- G phi in M_t (backward chain) implies G phi in M_0 (backward chain root) -- NOT directly provable because the backward chain propagates H, not G.
- Specifically: the backward chain step n+1 extends HContent(M_n), so H phi propagates forward in the backward chain. But G phi does NOT propagate in the backward chain.

**This is fundamentally the same cross-sign problem as ZornFamily line 888.** It requires showing that G-content from one direction of the chain flows through M_0 to the other direction. This would need M_0 to somehow "transfer" G phi forward and H phi backward simultaneously.

**Key insight**: The cross-sign problem for DovetailingChain requires the same mathematical argument as ZornFamily -- temporal content propagation across a shared reference MCS. Neither approach has a clear advantage here.

**Pair 2: F/P witness construction (lines 633, 640)**

These require a completely different construction where the chain is built with dovetailing enumeration to place witnesses. The current construction does NOT include F/P obligations in the seeds. Resolving these sorries requires:

1. Redesigning the chain construction to include F-obligations in forward seeds and P-obligations in backward seeds.
2. Proving that the augmented seeds remain consistent (single-witness version is proven via `temporal_witness_seed_consistent`).
3. Implementing a dovetailing enumeration to ensure EVERY F/P obligation eventually gets a witness.

The dovetailing approach is actually more tractable than ZornFamily for F/P witnesses because:
- Each step adds ONE witness to ONE obligation (single-witness seed consistency IS proven)
- The dovetailing enumeration ensures coverage
- The construction is explicit, not non-constructive like Zorn

**However**, the dovetailing enumeration infrastructure does not yet exist and would be substantial to build.

### Tractability Comparison

| Aspect | ZornFamily | DovetailingChain |
|--------|-----------|-----------------|
| **Cross-sign G/H** | Same difficulty in both approaches |  |
| **F/P witnesses** | Fundamentally blocked (multi-witness false) | Tractable but requires significant new infrastructure |
| **IMPOSSIBLE sorries** | 3 (lines 844, 874, 1120+1260) | 0 |
| **Current proof infrastructure** | More developed (~2400 lines) | Less developed (~667 lines) |
| **Architectural cleanliness** | Complex (6 fields in structure, chain upper bound for all 6) | Clean (2-chain design, explicit construction) |
| **Effort to complete** | Requires fundamental rethinking | Requires infrastructure + enumeration |

## Minimum Viable Change Definition

### Option 1: Cross-Sign Only (Smallest Change, Most Impact for ZornFamily)

**Target**: Resolve the cross-sign sorry at line 888 in `extensionSeed_consistent`.

**Change**: In the cross-sign case where both past and future domain times exist:
1. Find s_max (max past time in domain) and s_min (min future time in domain)
2. Show all GContent from past propagates to GContent(mcs(s_max)) via `GContent_propagates_forward`
3. Show all HContent from future propagates to HContent(mcs(s_min)) via `HContent_propagates_backward`
4. Use forward_G to propagate GContent(mcs(s_max)) into mcs(s_min)
5. Show HContent(mcs(s_min)) is already in mcs(s_min) via T-axiom
6. All elements end up in mcs(s_min) which is consistent

**Impact**: Resolves 1 sorry directly. Unlocks: nothing directly (F/P sorries remain).

**Effort**: Medium -- the argument is well-understood from research-001.

**But**: This does NOT resolve any of the IMPOSSIBLE sorries or the F/P structural problem.

### Option 2: Remove forward_F/backward_P, Accept F/P as Separate Theorem with Sorry (Moderate Change)

**Target**: Simplify GHCoherentPartialFamily to G/H-only, prove maximality implies totality, accept single sorry for F/P recovery.

**Change**:
1. Remove `forward_F` and `backward_P` fields from `GHCoherentPartialFamily`
2. Remove `FObligations` and `PObligations` from `extensionSeed`
3. Simplify extension functions (remove 4 sorry sites for F/P in extensions)
4. Prove cross-sign seed consistency (GContent + HContent only -- much simpler)
5. Prove internal gap case or avoid it
6. Prove maximality implies totality with simplified seed
7. Add single sorry for F/P recovery theorem

**Impact**: Eliminates 8 sorry sites (844, 874, 1120, 1260, 1764, 1786, 1928, 1968). Reduces total to ~3-4 sorries (cross-sign seed, internal gap, F/P recovery, possibly G/H from new to old).

**Effort**: High -- requires significant refactoring of the 2400-line file.

### Option 3: Pivot to DovetailingChain with Dovetailing Enumeration (Largest Change, Best Outcome)

**Target**: Build complete sorry-free proof via DovetailingChain with explicit witness construction.

**Change**:
1. Extend DovetailingChain construction to include F-obligations in forward chain seeds and P-obligations in backward chain seeds
2. Build dovetailing enumeration infrastructure for witness coverage
3. Prove cross-sign G/H propagation (same difficulty as ZornFamily)
4. Prove F/P witness satisfaction via enumeration coverage

**Impact**: All 4 DovetailingChain sorries resolved. Complete sorry-free temporal coherent family.

**Effort**: Very high -- requires substantial new infrastructure.

## Evidence (Verified Lemma Names)

### Proven and Available

| Lemma | File | Relevance |
|-------|------|-----------|
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | Single F-witness + GContent consistent |
| `temporal_witness_seed_consistent_past` | TemporalLindenbaum.lean | Single P-witness + HContent consistent (past analog) |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | Same as above (local copy) |
| `GContent_consistent` | ZornFamily.lean | GContent of MCS is consistent |
| `HContent_consistent` | ZornFamily.lean | HContent of MCS is consistent |
| `GContent_propagates_forward` | ZornFamily.lean | GContent(s1) subset GContent(s2) for s1 < s2 via 4-axiom |
| `HContent_propagates_backward` | ZornFamily.lean | HContent(s2) subset HContent(s1) for s1 < s2 via 4-axiom |
| `GContent_union_contained_at_max` | ZornFamily.lean | Finite list from GContent union has max source time |
| `HContent_union_contained_at_min` | ZornFamily.lean | Finite list from HContent union has min source time |
| `set_mcs_all_future_all_future` | MCSProperties.lean | G phi in MCS implies GG phi in MCS (4-axiom) |
| `set_mcs_all_past_all_past` | MCSProperties.lean | H phi in MCS implies HH phi in MCS (4-axiom) |
| `generalized_temporal_k` | GeneralizedNecessitation.lean | If Gamma derives phi, then G(Gamma) derives G(phi) |
| `generalized_past_k` | GeneralizedNecessitation.lean | If Gamma derives phi, then H(Gamma) derives H(phi) |
| `set_mcs_closed_under_derivation` | MCSProperties.lean | MCS closed under derivation |
| `set_mcs_implication_property` | (MCSProperties or Completeness) | MCS closed under modus ponens |
| `set_lindenbaum` | MaximalConsistent.lean | Every consistent set extends to MCS |
| `zorn_le_nonempty_0` | Mathlib | Zorn's lemma |
| `chainUpperBound_extends` | ZornFamily.lean | Chain upper bound extends all members |
| `coherent_chain_has_upper_bound` | ZornFamily.lean | Every chain has upper bound |

### FALSE Lemmas (Cannot Be Proven)

| Lemma | Location | Counterexample |
|-------|----------|---------------|
| `multi_witness_seed_consistent_future` | ZornFamily.lean:806 | M with F(p), F(neg p); seed {p, neg p} union GContent(M) inconsistent |
| `multi_witness_seed_consistent_past` | ZornFamily.lean:849 | Symmetric |

## Confidence Level

**Overall confidence**: MEDIUM-HIGH

- **Sorry site analysis**: HIGH confidence -- the categorization of IMPOSSIBLE vs HARD vs MEDIUM is well-supported by the counterexample analysis from research-001 and structural analysis of the code.

- **Recommendation (Option 2)**: MEDIUM confidence -- removing forward_F/backward_P eliminates the most sorries with the clearest path, but the remaining F/P recovery sorry is genuinely hard and may be provably impossible via the Zorn approach alone.

- **DovetailingChain assessment**: MEDIUM confidence -- the cross-sign problem is genuinely hard for both approaches, and the F/P enumeration infrastructure is substantial but conceptually sound.

- **Key uncertainty**: Whether F/P recovery can be proven for maximal G/H-only families WITHOUT construction-level information. This is the central open mathematical question. If the answer is "no", then only an explicit construction approach (DovetailingChain with enumeration) can achieve sorry-free completeness.

## Summary of Findings

1. **ZornFamily has 3 IMPOSSIBLE sorries** caused by false multi-witness seed consistency lemmas. These cannot be resolved without architectural changes.

2. **DovetailingChain has 0 IMPOSSIBLE sorries** -- all 4 are genuinely HARD but mathematically valid targets.

3. **The "Drop forward_F/backward_P" approach** (Option 2) is the best minimum viable change for ZornFamily, reducing 12 sorries to approximately 3-4 by removing the structural field that creates the impossibility. However, it introduces a new sorry for F/P recovery that may be equally hard.

4. **DovetailingChain** (Option 3) offers the best path to a fully sorry-free proof if the dovetailing enumeration infrastructure is built, but requires the most effort and must still solve the cross-sign propagation problem.

5. **The cross-sign propagation problem** is common to both approaches and is the genuine "domino" sorry -- resolving it would unblock significant progress in either approach.

6. **No single minimum viable change eliminates all sorries.** The problem is structurally deep: Zorn's non-constructive maximality is fundamentally in tension with the constructive witness placement that F/P satisfaction requires.
