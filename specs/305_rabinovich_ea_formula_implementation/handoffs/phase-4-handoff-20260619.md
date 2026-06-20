# Phase 4 Handoff: Lemma 5.1 Inductive Step

## Status: BLOCKED

Phase 4 (Lemma 5.1 full negation closure) remains blocked. The sorry at EANegation.lean:865 (`neg_bracket_is_vbracket` inductive step) and the sorry at EANegation.lean:878 (`neg_partialBracketExist_is_vbracket`) are both still present.

## What Was Accomplished

- Thorough analysis of 5 different proof approaches for the BracketFormula inductive step
- Identification of the fundamental obstacle: the "interval mismatch" for x_0 > r_0
- Identification of the correct approach: VecEA2 endpoint convention matching the paper
- Updated plan file with detailed BLOCKER documentation
- Updated sorry comments in EANegation.lean with analysis and correct approach

## Root Cause Analysis

The paper's Lemma 5.1 proof uses three cases based on the first endpoint condition alpha_0(z_0):
1. alpha_0(z_0) fails -> trivial negation
2. alpha_0(z_0) AND first segment everywhere -> reduces to fewer interior witnesses
3. alpha_0(z_0) AND first segment fails -> split at failure point

Cases 2 and 3 REQUIRE alpha_0 at the ENDPOINT z_0 (not an interior witness). In our BracketFormula convention, ALL witnesses are interior. When we find the first occurrence r_0 of alpha_0 in (z_0, z_1), there can be LATER occurrences x_0 > r_0 where the bracket formula holds with different segment conditions. The soundness argument for the prepend construction FAILS for x_0 > r_0 because:

- rightPart.holds(x_0, z_1) does NOT imply rightPart.holds(r_0, z_1)
- The first segment of rightPart widens from (x_0, w_1) to (r_0, w_1)
- We don't know beta_1 on the extra piece (r_0, x_0)

## Correct Approach

1. **Prove `neg_vecEA2_is_vvecEA2`**: Induction on n (VecEA2 parameter = interior witness count). The VecEA2 convention places alpha_0 at the ENDPOINT z_0 (as endpointLeft), eliminating the "x_0 > r_0" case. The three cases work correctly:
   - Case 1: not eL(z_0) -> trivial VVecEA2 disjunct
   - Case 2: eL(z_0) AND first segment everywhere -> bracket simplifies. The bracket.holds becomes "exists x_0, alpha_0(x_0) AND rightPart.holds(x_0, z_1)" where rightPart has n-1 witnesses. Apply IH (n-1 < n) OR reduce to Corollary 5.4.
   - Case 3: eL(z_0) AND first segment fails -> find first failure point using HasAttainedINF, split interval, apply IH on sub-brackets.

2. **Derive `neg_bracket_is_vbracket`** from `neg_vecEA2_is_vvecEA2`:
   - Convert: `VecEA2.fromBracket bf` has trivial endpoints (top/top)
   - Apply VecEA2 negation: get VVecEA2
   - Convert VVecEA2 to VBracketFormula: show that for trivial-endpoint VecEA2, the negation's VVecEA2 disjuncts can be expressed as VBracketFormula disjuncts

3. **Key infrastructure needed**:
   - `neg_vecEA2_is_vvecEA2 : forall n, forall vea : VecEA2 n, exists v : VVecEA2, v.holds <-> not vea.holds`
   - `VVecEA2.toVBracketFormula_trivial_endpoints`: conversion for the trivial-endpoint case
   - Possibly: reverse partial bracket existential (`exists z, bracket.holds(z, z_1)` varying left endpoint)
   - Possibly: `VecEA2.simplifiedBracket`: when first segment is trivial, extract BracketFormula (n-1)

## Case 2 Detail

Under Case 2 for VecEA2 n (n >= 1):
- eL(z_0) holds, segmentTypes(0) = beta_0 holds everywhere on (z_0, z_1)
- bracket.holds = exists x_0, alpha_0(x_0) AND rightPart(0).holds(x_0, z_1)
- rightPart(0) : BracketFormula (n-1) has n-1 witnesses
- not bracket.holds = forall x_0, not alpha_0(x_0) OR not rightPart.holds(x_0, z_1)
- By IH on rightPart (n-1 < n): exists v_R with v_R.holds <-> not rightPart.holds
- The universal "forall x_0" needs to be expressed as V-bracket

Two sub-approaches for the universal:
A. Use Corollary 5.4 (already sorry-free for forward direction): the bracket.holds under Case 2 is a partial bracket existential varying the LEFT endpoint. Need a "reverse Corollary 5.4" or symmetric argument.
B. Direct argument on Prior structures: use HasAttainedINF to find first alpha_0 occurrence r_0, then at r_0 rightPart must fail (since bf.holds would give a contradiction). The key: since eL is at the ENDPOINT z_0 (VecEA2), NOT interior, the prepend at r_0 IS sound because the only "earlier" point is z_0 itself, and eL(z_0) is already verified.

Sub-approach B is the paper's actual proof. With VecEA2 convention, r_0 IS the first INTERIOR witness, and there's no "x_0 between z_0 and r_0" issue because z_0 is the endpoint.

## Estimated Remaining Work

- `neg_vecEA2_is_vvecEA2`: ~200-300 lines (3 cases, each with forward/backward)
- VVecEA2-to-VBracketFormula conversion: ~50-100 lines
- `neg_bracket_is_vbracket` corollary: ~30 lines
- `neg_partialBracketExist_is_vbracket`: ~50 lines (uses neg_bracket_is_vbracket)
- Total: ~330-480 lines

## Sorry Inventory

1. `EANegation.lean:865` -- `neg_bracket_is_vbracket` inductive step
   - Depends on: `neg_vecEA2_is_vvecEA2` (not yet defined)
   - Next dispatch: implement neg_vecEA2_is_vvecEA2, then derive corollary

2. `EANegation.lean:878` -- `neg_partialBracketExist_is_vbracket`
   - Depends on: `neg_bracket_is_vbracket`
   - Next dispatch: follows from neg_bracket_is_vbracket once proved

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- sorries at lines 865, 878
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- VecEA2, VVecEA2 definitions
- `specs/305_rabinovich_ea_formula_implementation/plans/01_ea-formula-plan.md` -- plan with BLOCKER

## Immediate Next Action

Implement `neg_vecEA2_is_vvecEA2` by induction on n in EANegation.lean, then derive `neg_bracket_is_vbracket` as corollary. Start with VecEA2 base case (n=0), then Cases 1-3 for inductive step.
