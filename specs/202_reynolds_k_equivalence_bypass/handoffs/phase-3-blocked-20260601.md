# Phase 3 Handoff: Reynolds Model Surgery (Task 202)

## Session: sess_1780325631_z4lda
## Date: 2026-06-01

## Status
- Phase 1 [COMPLETED]: gap formula construction
- Phase 2 [COMPLETED]: R-interval analysis (R_holds_at_a proved, SZ reduced to UZ)
- Phase 3 [BLOCKED]: model surgery / class homogeneity / contradiction derivation

## Key Achievement This Session
**Added sorry-free `invariant_formula_constant` lemma** (Reynolds Lemma 9 generalization): Any MonadicFormula sig 1 that is contemp_equiv-invariant is constant on M (true everywhere or false everywhere). This generalizes the h_R_everywhere proof pattern to ALL invariant formulas.

## Remaining Sorry
File: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
Location: Inside `gap_prior_UZ_contradiction`, after `invariant_formula_constant` and `h_R_everywhere`
Content: From "R holds everywhere" derive `False`

### What's proved inside the sorry'd theorem (sorry-free)
- `R` (gap_formula_R) is defined
- `h_R_at_a : temporal_truth M atomMap a R` is proved
- `any_succ_closed`: every class is succ-closed
- `h_R_iff_rgcp`: R iff right_gap_class_prop at every point
- `h_R_everywhere`: R holds at every point of M
- `invariant_formula_constant`: any contemp_equiv-invariant MonadicFormula sig 1 is constant on M

### What's needed to close the sorry
From h_R_everywhere (every class bounded above + succ-closed), derive False.

Three possible approaches (see plan Phase 3 BLOCKER for details):
- (A) Prove Doets Lemma 1.5 (OrderedSum.lean, ~100-200 lines)
- (B) Full model surgery with truth preservation (~300 lines)
- (C) Direct Z+Z ~k Z lemma (~50-100 lines)

## Mathematical Analysis Summary

### Why R holds everywhere (not just at a)
The proof uses Prior-UZ/SZ first/last transition lemmas: if R fails at any z, there's a transition point c where R(c) but not R(succ(c)). Since c ~M succ(c) (no_boundary_at_successor) and right_gap_class_prop is invariant under contemp_equiv, this is a contradiction. So R can't fail anywhere.

### Why invariant_formula_constant doesn't suffice by itself
invariant_formula_constant shows contemp_equiv-invariant formulas are constant. This means all class-restricted sentences evaluate the same way (class homogeneity). But class homogeneity alone doesn't give a contradiction: Z+Z+...+Z with identical copies of Z and gaps between them is a valid structure.

### Why the contradiction needs model surgery or Doets 1.5
The contradiction comes from showing that if adjacent classes have the same k-type, the cross-gap subinterval is good (k-equivalent to a Z-interval). This would make M very_good, hence contemp_equiv everywhere, contradicting h_not_equiv. The cross-gap goodness requires Z+Z ~k Z (two copies of same-type Z concatenated with a gap are k-equivalent to a single Z). This is Doets Lemma 1.5 specialized to ℤ-indexed families.

## Immediate Next Action
The successor agent should pursue approach (C): prove Z+Z ~k Z as a specialized lemma, using either:
1. Direct NormalForm argument: show nf_characteristic of orderedSum is determined by the shared type
2. KEquivalenceFramework: define a Duplicator strategy for orderedSum Bool matching
3. Then use this to close the sorry: class homogeneity + Z+Z~kZ -> cross-gap good -> very_good -> contemp_equiv everywhere -> contradiction

## Key Decisions Made (This Session)
1. `invariant_formula_constant` proved as a generalization of h_R_everywhere pattern
2. Extensively analyzed 6+ alternative approaches before concluding model surgery / Doets 1.5 is required
3. Identified approach (C) (direct Z+Z ~k Z) as likely shortest path (~50-100 lines vs 300+)

## Files Modified This Session
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (+67 lines)
- `specs/202_reynolds_k_equivalence_bypass/plans/18_reynolds-model-surgery-v17.md` (Phase 3 marked BLOCKED)

## Anti-Patterns (from failure history + this session)
- DO NOT try to derive False from h_R_everywhere without either model surgery or Doets 1.5
- DO NOT expect Prior-UZ/SZ to directly contradict R holding everywhere (U(R, R.neg) is vacuously satisfied)
- DO NOT expect class homogeneity alone to give contemp_equiv (it gives same class theory but not same 1-variable type in full M)
- DO NOT bypass model surgery with shortcuts -- extensively analyzed, no shortcut exists
