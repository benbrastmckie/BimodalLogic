# Handoff: Phase 2 Three-Part Seed Consistency Blocker

## Session: sess_1777696621_abe53e
## Date: 2026-05-01

## Summary

Fixed 4 compilation errors and eliminated 4 sorry sites (Phase 3 membership proofs).
The build now compiles cleanly. However, the core Phase 2 sorry sites remain because
the proof approach (filter L to subset, derive bot from subset via weakening) is
**mathematically incorrect**. Weakening goes from smaller context to larger (Gamma ⊆ Delta
gives DerivationTree Gamma phi → DerivationTree Delta phi), not the reverse.

## What Was Accomplished

1. **Fixed compilation errors** at lines 1272, 1296, 1344 by replacing incorrect
   weakening-based proofs with documented sorry markers
2. **Eliminated 4 sorry sites** in Phase 3 (lemma_2_7 membership proofs) using
   simp-based proofs showing seed elements propagate to D via Lindenbaum extension
3. **Build compiles cleanly** (no errors, only sorry warnings)

## Current Sorry Count in PointInsertion.lean: 7

| Line | Phase | Description | Difficulty |
|------|-------|-------------|------------|
| 1091 | 2 | Since condition bypass | ACCEPTED (Report 52) |
| 1226 | 2 | Consistent case: L_H ⊢ bot from L ⊢ bot | HARD (see analysis) |
| 1276 | 2 | Inconsistent case: B ∪ g_content ∪ h_content consistency | HARD (same issue) |
| 1300 | 2 | Inconsistent case: G(bot) from L_G subset | HARD (same issue) |
| 1348 | 2 | Inconsistent case: H(bot) from L_H subset | HARD (same issue) |
| 1445 | 3 | lemma_2_7_seed_consistent | HARD (BX axiom chain) |
| 1518 | 3 | eta in B' (maximality) | MEDIUM |

## Core Blocker: Phase 2 Three-Part Seed Consistency

### The Problem

The splitting_seed is `{beta.neg} ∪ g_content(A) ∪ h_content(C)`. Proving its
consistency requires showing: for any finite L ⊆ seed with L ⊢ bot, contradiction.

The current approach filters L into components and tries to derive bot from a
single component via weakening. This is IMPOSSIBLE because:
- DerivationTree.weakening requires Gamma ⊆ Delta (goes UP, not DOWN)
- L_filtered ⊆ L (filter is a subset of the original)
- We'd need L ⊆ L_filtered to use weakening, which is false

### Mathematical Analysis

The seed IS semantically consistent (verified by semantic argument: at any time
point between A and C, both g_content(A) and h_content(C) hold). But the
SYNTACTIC proof is non-trivial because:

1. **g_content(A) ⊄ A** (no temporal T-axiom: G(phi) does not imply phi)
2. **h_content(C) ⊄ C** (no past T-axiom: H(phi) does not imply phi)
3. **h_content(C) ⊄ g_content(A)** (would need phi in A → G(phi) in A, i.e., the 5-axiom)
4. Combined lifts don't work: g_content uses G-lift to A, h_content uses H-lift to C,
   but these are DIFFERENT MCSs and you can't split a single derivation between two lifts.

### Known Facts

- h_content(C) ⊆ A (from g_content_sub_imp_h_content_sub')
- g_content(A) ⊆ C (hypothesis h_gc)
- {beta.neg} ∪ g_content(A) is consistent (forward_temporal_witness_seed_consistent)
- F(beta.neg) ∈ A (from BX5+BX14+BX10 chain)

### Potential Correct Approaches

**Approach 1: Lindenbaum + Duality (Most Promising)**
1. Extend {beta.neg} ∪ g_content(A) to MCS M (possible since consistent)
2. Show g_content(A) ⊆ M gives h_content(M) ⊆ A (via duality)
3. Show h_content(C) ⊆ M by showing M and C have the right accessibility relation
4. The key gap: proving h_content(C) ⊆ M for an ARBITRARY MCS M extending the seed.
   This likely requires INCLUDING additional formulas in the seed that force the
   relationship (e.g., some Since/Until formulas as in Burgess's original D0).

**Approach 2: Burgess's Direct D0 Seed (Per Paper)**
Replace splitting_seed with Burgess's actual D0:
D0 = {S(alpha, beta) : alpha in A, beta in B} ∪ B ∪ {neg-delta} ∪ {U(gamma, beta) : gamma in C, beta in B}
Then prove consistency by showing each conjunction zeta = S(alpha,beta) ∧ beta ∧ neg-delta ∧ U(gamma,beta)
is consistent via BX5+BX14 chain. This is what Burgess actually does.

**Approach 3: Enriched Seed (Quasimodel Pattern)**
Add extra formulas to the seed that force the accessibility relationship.
Specifically, add g_content(A) elements' G-versions: {G(phi) | G(phi) in A} = the actual
G-formulas from A. Then the resulting MCS D automatically has g_content(D) ⊆ C by construction.

### Recommendation

**Approach 2 (Burgess's original D0)** is likely correct but requires restructuring
splitting_seed to match Burgess's actual construction. The current simplified seed
({beta.neg} ∪ g_content ∪ h_content) is an INSUFFICIENT simplification of Burgess's
full D0 which includes S and U formulas that carry the structural information needed
for the consistency proof.

A `/revise` of the plan should investigate whether:
1. The seed should be changed to Burgess's D0 (requires significant refactoring)
2. Or whether approach 1 (adding structural constraints to force h_content(C) ⊆ M) can work

## Phase 3 Progress

- Membership proofs (h_xi_D, h_B_sub_D, h_untl_D, h_snce_D): COMPLETED
- lemma_2_7_seed_consistent: NOT STARTED (same structural issue as Phase 2)
- eta in B': NOT STARTED (requires seed consistency first)

## Files Modified

- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean
  - Lines 1270-1276: Replaced broken weakening proof with sorry + documentation
  - Lines 1293-1300: Same fix
  - Lines 1341-1348: Same fix
  - Lines 1465-1490: Replaced 4 sorry sites with working simp proofs
