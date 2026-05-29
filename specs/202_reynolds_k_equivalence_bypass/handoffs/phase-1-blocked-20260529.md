# Phase 1 Handoff: BLOCKED — F-Persistence Through Lindenbaum Extensions

**Task**: 202 — Reynolds k-equivalence bypass for sorry-free completeness_discrete
**Phase**: 1 — One-at-a-Time Henkin Chain Construction
**Status**: BLOCKED
**Date**: 2026-05-29
**Session**: sess_1780065348_537480

## Immediate Next Action

Resolve the F-persistence blocker using one of the four paths documented in the plan blocker annotation (task 129 conservative extension, augmented seed consistency proof, restricted MCS truth lemma, or construction-level gap analysis).

## Current State

- `HenkinDiscreteChain.lean` compiles with `g_content_consistent` and `h_content_consistent` (both sorry-free)
- Extensive analysis documented in the file's module docstring
- No new sorries introduced, no code changes to other files
- Build passes (1581 jobs)

## Blocker Summary

The Henkin chain approach requires F-persistence: if `F(ψ) ∈ mcs(n)` and the chain resolves a DIFFERENT formula at step n+1, then `F(ψ)` must still be in `mcs(n+1)`. This fails because:

1. `mcs(n+1)` is a Lindenbaum extension of `{witness} ∪ g_content(mcs(n))`
2. `F(ψ) ∉ g_content(mcs(n))` (F-formulas are existential, not in g_content)
3. The Lindenbaum extension (Classical.choice) may arbitrarily include `G(¬ψ)` instead of `F(ψ)`
4. Once `G(¬ψ)` enters, it propagates forward forever via temp_4 (G(φ) → G(G(φ)))

## Approaches Attempted

| # | Approach | Result |
|---|----------|--------|
| 1 | Simple g_content chain (bx_fmcs pattern) | F(ψ) drops out |
| 2 | Augmented seed with F-formulas from M | {ψ} ∪ g_content(M) ∪ {F(χ)} can be inconsistent |
| 3 | Multi-family BFMCS (one per obligation) | restricted_tc requires same family |
| 4 | Schedule with infinite visits | F(ψ) may never return after dropping |
| 5 | Restricted Lindenbaum within deferralClosure | Requires new truth lemma infrastructure |

## Resolution Paths (Priority Order)

1. **Task 129**: Conservative extension from reflexive semantics (most architecturally sound, ~8-12h)
2. **Augmented seed consistency**: Prove `{ψ} ∪ g_content(M) ∪ {F(χ) | F(χ) ∈ M, χ ∈ DC}` consistent using temporal axiom interactions (~4-8h, might fail)
3. **Restricted MCS truth lemma**: Build parallel infrastructure for restricted extensions (~10-15h)
4. **Gap analysis for succ_cofinal**: Direct construction-level proof (~8-12h, uncertain)

## Key Decisions

- Preserved `g_content_consistent` and `h_content_consistent` as sorry-free infrastructure
- Did NOT introduce any sorries or vacuous definitions
- Did NOT modify any existing files (only extended HenkinDiscreteChain.lean)
- Documented all 5+ approaches and their failure modes in the plan file

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean` — analysis docs + 2 sorry-free lemmas
- `specs/202_reynolds_k_equivalence_bypass/plans/03_henkin-chain-plan.md` — Phase 1 marked [BLOCKED] with blocker annotation
