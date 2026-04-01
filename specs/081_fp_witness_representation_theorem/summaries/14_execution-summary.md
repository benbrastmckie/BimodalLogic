# Execution Summary: Plan v14 (Safe Target Approach)

**Task**: 81 -- F/P Witness Representation Theorem
**Plan**: plans/14_safe-target-approach.md
**Session**: sess_1775082342_38e2c2
**Status**: BLOCKED at Phase 1 (validation reveals fundamental mathematical obstacle)

## What Was Accomplished

### Phase 1: Map Sorry Chain and Validate Approach [COMPLETED]

Comprehensive analysis of the sorry chain and validation of the safe target approach.

#### Sorry Chain Mapping

The sorry chain from `completeness_over_Int` to the ground-level proof gap:

1. `completeness_over_Int` (Completeness.lean:305) -- delegates to `bundle_validity_implies_provability`
2. `bundle_validity_implies_provability` (Completeness.lean:262) -- uses `bfmcs_from_mcs_temporally_coherent`
3. `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237) -- **SORRY** -- needs family-level forward_F/backward_P
4. Each family in `boxClassFamilies` is `shifted_fmcs (SuccChainFMCS S) k`
5. Need `forward_F` for `SuccChainFMCS S` = `succ_chain_fam S` (unrestricted chain)
6. `succ_chain_fam` uses `constrained_successor_from_seed` at each step
7. This gives `Succ` relation (f_step: resolve or defer) but does NOT target specific F-obligations
8. Without targeted resolution, F-obligations can be deferred indefinitely

#### Additional Sorries Discovered

The restricted chain approach has **deeper** sorry issues than previously understood:

| File | Line | Theorem | Status |
|------|------|---------|--------|
| SuccChainFMCS.lean | 1976 | `constrained_successor_seed_restricted_consistent` | **FALSE** -- counterexample documented |
| SuccChainFMCS.lean | 1998 | `augmented_seed_consistent` | **FALSE** -- reduces to above |
| SuccChainFMCS.lean | 2315 | `sorry` in multi-BRS case | **FALSE** -- same root cause |
| SuccChainFMCS.lean | 5619 | fuel=0 backward bounded witness | MOOT -- depends on false theorem |
| SuccChainFMCS.lean | 5777 | fuel=0 combined bounded witness F | MOOT -- depends on false theorem |
| SuccChainFMCS.lean | 5973 | fuel=0 combined bounded witness P | MOOT -- depends on false theorem |
| SimplifiedChain.lean | 195 | `targeted_restricted_seed_consistent` | **OPEN** -- the core mathematical problem |
| Completeness.lean | 237 | `bfmcs_from_mcs_temporally_coherent` | **OPEN** -- the top-level sorry |

#### Why the Safe Target Approach Is Blocked

The safe target approach requires proving: for any MCS `M` with `F(target) in M`, the seed `{target} union constrained_successor_seed(M)` is consistent. This consistency is **provably NOT achievable** in general:

**Concrete counterexample**: Take `M` with `F(target) in M`, `F(psi) in M`, and `G(target -> neg(psi) and G(neg(psi))) in M`. Then:
- `G(target -> neg(d)) in G_theory(M) subset temporal_box_seed(M)` where `d = psi or F(psi)`
- By T-axiom: `target -> neg(d)` is derivable from `temporal_box_seed(M)`
- So `{target} union temporal_box_seed(M) |- neg(d)`
- Adding `d = psi or F(psi)` (from `deferralDisjunctions(M)`) gives inconsistency
- The enriched seed `{target} union constrained_successor_seed(M)` is inconsistent

This counterexample applies to ALL enriched seed approaches:
- `{target} union g_content(M) union deferralDisjunctions(M)` -- inconsistent (proven above)
- `{target} union simplified_restricted_seed(M)` -- inconsistent (same reason)
- `{target} union constrained_successor_seed(M)` -- inconsistent (same reason)

#### The Fundamental Mathematical Obstacle

The F/P witness problem reduces to a tension between three requirements:

1. **F-step** (Succ relation): requires `deferralDisjunctions` in the seed, ensuring each F-obligation is either resolved or deferred
2. **Target resolution**: requires `{target}` in the seed, forcing a specific F-obligation to be resolved
3. **Consistency**: the combined seed must be consistent

Requirements (1) and (2) can individually be satisfied:
- `{target} union g_content(M)` is consistent (sorry-free: `single_target_with_g_content_consistent`)
- `constrained_successor_seed(M)` is consistent (sorry-free: subset of M)

But their UNION `{target} union constrained_successor_seed(M)` is NOT consistently provable because deferralDisjunctions are NOT G-liftable, and the G-lift technique is the ONLY known consistency argument for adding target to a seed containing formulas from M.

#### F-Persistence Failure

Even without the enriched seed, the "resolve one at a time" approach fails because F-obligations are NOT preserved across chain steps:

- `F(psi) in chain(t)` does NOT imply `F(psi) in chain(t+1)`
- The Lindenbaum extension at step t+1 can freely introduce `G(neg(psi))`, killing `F(psi)`
- This was independently confirmed by DovetailedChain.lean (extensive design analysis, lines 340-595) and blocker analysis report 13

### Phases 2-5: NOT STARTED (BLOCKED)

Phase 2 (safe target lemma), Phase 3 (composition), Phase 4 (wiring), and Phase 5 (verification) cannot proceed because the fundamental consistency obstacle identified in Phase 1 blocks the approach.

## Key Findings

1. **The restricted chain infrastructure (SuccChainFMCS.lean lines 2333-6161) is built on a FALSE theorem** (`constrained_successor_seed_restricted_consistent`). All theorems downstream -- including `restricted_forward_chain_forward_F`, `restricted_bounded_witness`, and `build_restricted_tc_family` -- are unsound.

2. **The DovetailedChain.lean file** (already in the codebase) documents the same analysis independently, arriving at the same conclusion: Lindenbaum-based chain steps cannot preserve F-obligations.

3. **Every known approach** to same-family forward_F has the same blocker: either the enriched seed is inconsistent (bulk resolution) or F-persistence fails (one-at-a-time resolution).

4. **The only sorry-free single-step constructions** are:
   - `single_target_with_g_content_consistent` (consistency of `{target} union g_content(M)`)
   - `temporal_theory_witness_exists` (same but extended to full MCS)
   - `build_targeted_successor` (DRM-level single-step resolution)

   None of these compose into a chain with forward_F.

## Recommendations

### The problem may require a fundamentally new approach:

1. **Algebraic temporal shift** (ROADMAP line 124): Define FMCS via algebraic automorphism of the Lindenbaum algebra. This sidesteps F-obligation enumeration entirely by working at the algebra level where temporal operators are interior operators. This is the most principled approach but requires significant new infrastructure.

2. **Modified Lindenbaum that preserves F-obligations**: Instead of standard Zorn's lemma extension, develop a constrained Lindenbaum that respects F-obligation preservation. This would require proving that the constraint "don't add G(neg(psi)) for pending F(psi)" is consistent, which is a novel proof-theoretic result.

3. **Restricted completeness**: Prove completeness for formulas whose deferralClosure has no "conflicting F-obligations" (formulas psi and neg(psi) both F-reachable from the same MCS). This covers a useful class of formulas and may be publishable as a partial result.

4. **Accept bundle-level coherence**: Redefine the model construction to use bundle-level temporal coherence instead of family-level. This requires a different truth lemma that allows F-witnesses from different families. The semantic cost: the canonical model would use a non-standard temporal interpretation.

## Files Examined

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (6161 lines)
- `Theories/Bimodal/FrameConditions/Completeness.lean` (394 lines)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (3714 lines)
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (605 lines)
- `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` (206 lines)
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean` (309+ lines)
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (600+ lines)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (89 lines)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (223 lines)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (778+ lines)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (179+ lines)
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` (100+ lines)

## No Code Changes

No source files were modified. The task is blocked at the mathematical analysis stage.
