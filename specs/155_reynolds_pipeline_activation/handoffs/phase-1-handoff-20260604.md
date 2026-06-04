# Phase 1 Handoff: Bridge A Implementation Attempt

## Session: sess_1780597716_8961c0
## Status: BLOCKED
## Phase: 1 of 5

## What Was Done

### Infrastructure Lemmas (COMPLETED)
Added 8 discrete order infrastructure lemmas to NFGameBridge.lean:
- rdefinable_gap_empty_of_no_gaps: Gap M.carrier empty => RDefinableGap empty
- discrete_extended_is_point: every ExtendedCarrier element is extendPoint of actual point
- discrete_extendPoint_surj: extendPoint is surjective for discrete orders
- discrete_mu_trivial: mu_holds is true for all ExtendedCarrier elements
- discrete_extended_isPoint: IsPoint holds for all elements
- discrete_extended_not_isGap: IsGap is false for all elements
- discrete_inClosedInterval_iff: interval reduces to M.carrier ordering
- discrete_extendPoint_lt_iff: strict ordering reduces to M.carrier

All compile. lake build succeeds.

### Analysis of the Plan's Core Mathematical Claim (NEW FINDING)

The plan claims r = k works for discrete orders with no 2x depth penalty.
After thorough analysis, this claim has a subtlety that needs resolution.

The depth chain:
1. rank_type at rank r uses StaviFormulas of stavi_depth <= r
2. StaviFormulas of stavi_depth d have FO depth stavi_fo_depth <= 2*d
3. nf_profile at depth 2*r determines rank_type at rank r
4. nf_profile uses nf_characteristic (extendedStructureWithMu M atomMap r) (2*r) 1
5. For discrete orders, mu is trivially true, so NF agreement on M at depth d
   should imply NF agreement on extendedStructureWithMu at depth d

The issue: We have NF agreement at depth k on M. We need nf_profile agreement
at depth 2*r. If r = k, we need agreement at depth 2*k. Even with step (5),
we only get depth k on extendedStructureWithMu from depth-k on M. So r <= k/2.

### Three Possible Paths Forward

1. Prove depth-bounded nf_characterizable_by_stavi: Show the StaviFormula
   characterizing depth-k NFs has stavi_depth <= k. This lets char_k_correct
   connect NFs to rank_type directly.

2. Prove discrete mu-simplification: For discrete orders, show nf_profile at
   depth 2*k on extendedStructureWithMu is determined by NF at depth k on M.
   Requires showing mu-relativized quantifiers add no effective depth when mu
   is trivially true.

3. Use game at rank floor(k/2): Accept the 2x penalty. May be insufficient
   for transfer at all j < k.

## Key Files
- Modified: Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean
- Plan: specs/155_reynolds_pipeline_activation/plans/65_discrete-game-bypass.md

## Immediate Next Action
Research Path 1 or Path 2 to resolve the depth arithmetic obstruction.
