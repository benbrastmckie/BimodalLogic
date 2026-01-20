# Implementation Summary: Task #623

**Task**: Build FMP-tableau connection infrastructure
**Status**: Partial (Phases 1-2 of 6)
**Completed**: 2026-01-19
**Session ID**: sess_1768866353_ab089c

## Changes Made

Completed all sorries in Saturation.lean and CountermodelExtraction.lean. The remaining sorries in Correctness.lean (tableau_complete, decide_complete, decide_axiom_valid) are complex proofs requiring FMP-tableau connection that warrant separate focused effort.

### Phase 1: BEq Reflexivity and Lawfulness (Saturation.lean)

Added comprehensive BEq lemmas for SignedFormula and its components:

**Formula BEq Lemmas**:
- `formula_beq_of_eq`: `f = g -> (f == g) = true`
- `formula_beq_refl`: `(f == f) = true`
- `formula_eq_of_beq`: `(f == g) = true -> f = g`

**Sign BEq Lemmas**:
- `sign_beq_refl`: `(s == s) = true`
- `sign_eq_of_beq`: `(s1 == s2) = true -> s1 = s2`

**SignedFormula BEq Lemmas**:
- `signedFormula_beq_refl`: `(sf == sf) = true`
- `signedFormula_eq_of_beq`: `(sf1 == sf2) = true -> sf1 = sf2`

These lemmas enable proofs that manipulate branches by filtering/comparing signed formulas.

### Phase 2: branchTruthLemma (CountermodelExtraction.lean)

**Key Insight**: In a saturated branch, only atomic formulas can appear. Compound formulas (imp, box, all_future, all_past) cannot be in saturated branches because tableau rules apply to them, making them "unexpanded".

**Helper Lemmas Added**:
- `isExpanded_impPos_false`: impPos rule applies to T(phi -> psi)
- `isExpanded_impNeg_false`: impNeg rule applies to F(phi -> psi)
- `isExpanded_boxPos_false`: boxPos rule applies to T(box phi)
- `isExpanded_boxNeg_false`: boxNeg rule applies to F(box phi)
- `isExpanded_allFuturePos_false`: allFuturePos rule applies to T(G phi)
- `isExpanded_allFutureNeg_false`: allFutureNeg rule applies to F(G phi)
- `isExpanded_allPastPos_false`: allPastPos rule applies to T(H phi)
- `isExpanded_allPastNeg_false`: allPastNeg rule applies to F(H phi)
- `botPos_closes_branch`: T(bot) causes branch closure
- `open_no_botPos`: T(bot) cannot be in open branch
- `saturated_no_unexpanded`: In saturated branch, all formulas are expanded
- `open_branch_consistent`: Open branch has no contradictions on atoms

**branchTruthLemma Proof Structure**:
- Atoms: Direct extraction (positive) or consistency argument (negative)
- Bot: T(bot) causes contradiction with openness; F(bot) trivially false
- Compound formulas: Show exfalso via saturated_no_unexpanded + isExpanded_*_false

## Files Modified

- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`
  - Added ~100 lines of BEq lemmas
  - Fixed sorry at line 740 (signedFormula_beq_refl)
  - Fixed sorry at line 794 (BEq agrees with DecidableEq)

- `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean`
  - Added ~150 lines of isExpanded and closure lemmas
  - Fixed sorry at line 170 (open_branch_consistent)
  - Fixed sorry at line 182 (saturated_imp_expanded)
  - Fixed sorry at line 206 (branchTruthLemma) - multiple sorries within

## Verification

- `lake build`: Success (976 jobs, no errors)
- No sorries remain in Saturation.lean
- No sorries remain in CountermodelExtraction.lean

## Remaining Work (Phases 3-6)

The Correctness.lean file still has 3 sorries requiring FMP-tableau connection. Detailed technical commentary has been added to each sorry explaining what's needed:

1. **tableau_complete** (line 135): Prove that valid formulas have closed tableaux with sufficient fuel
   - Requires Lemma 1 (Termination): buildTableau with fmpBasedFuel never times out
   - Requires Lemma 2 (Validity -> Closure): valid formulas have no open saturated branches
   - Missing infrastructure:
     - Lemma: `valid phi <-> not formula_satisfiable (phi.neg)`
     - Lemma: `evalFormula (simplified) -> truth_at (full semantics)`
     - Lemma: Open saturated branch -> proper TaskModel construction
   - Gap: Bridging simplified countermodel (evalFormula) to full TaskModel semantics

2. **decide_complete** (line 174): Prove decide returns valid for valid formulas
   - Depends on: tableau_complete
   - Requires: Proof extraction from closed tableau
   - One of three paths must succeed: axiom matching, proof search, or tableau extraction

3. **decide_axiom_valid** (line 321): Prove decide finds axiom instances
   - Requires: matchAxiom completeness for all Axiom patterns
   - 15+ axiom constructors to verify
   - Some use complex encodings (diamond = neg box neg, always = H and (phi and G))
   - Independent of tableau_complete - could be proven separately via case analysis

## Recommendations

1. **Phase 3-6 as separate task**: The FMP-tableau connection requires understanding the full interplay between FMP bounds (semanticWorldState_card_bound) and tableau termination. This is substantial work better tackled as a focused follow-up task.

2. **Alternative approach**: For practical completeness, consider using `sorry` with detailed comments as placeholders, then proving them once the full FMP infrastructure is battle-tested.

3. **Test the current infrastructure**: The branchTruthLemma and related lemmas enable countermodel extraction from open saturated branches. This can be tested independently of the completeness theorems.

## Notes

The current implementation reveals an important insight about the tableau algorithm: saturated branches can only contain atomic formulas and F(bot). All compound formulas are expanded away during saturation. This simplifies reasoning about branch truth but may suggest the need for a richer model in the countermodel extraction (the current evalFormula treats modal/temporal as identity).
