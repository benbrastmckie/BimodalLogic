# Phase 3 Handoff: Gap Elimination (BLOCKED)

## Session
- **Session ID**: sess_1778968202_8779ea
- **Date**: 2026-05-16
- **Agent**: lean-implementation-agent

## Current State

Phase 2 is COMPLETED and committed (sorry-free). Phase 3 is BLOCKED.

### What Was Accomplished
1. **Phase 2 complete**: Added `good_one` theorem (75 lines) proving every structure is good at depth 1. Replaced the k=1 sorry in `good_of_split_at_succ` with `exact good_one sig (orderedSum sig Bool witnesses)`. Verified via `lean_verify` -- `good_of_split_at_succ`, `contemp_equiv_is_equiv`, `good_one` all show NO `sorryAx`. Build passes.
2. **Plan updated**: Phase 2 marked [COMPLETED], tasks 2.4b', 2.4c, 2.7 marked [x].
3. **Phase 3 analysis**: Thorough analysis of Reynolds Theorem 14 gap elimination argument completed. The argument is fundamentally harder than initially apparent.

### Why Phase 3 Is Blocked

Reynolds Theorem 14 proves "~M classes don't end at gaps in Prior structures." The proof is a 6-page, 8-lemma chain (Lemmas 6-13) that:

1. Defines ρ(x) = "x's class ends in a gap on the right" (first-order formula)
2. Constructs temporal equivalent R via expressive completeness (= table_correctness)
3. Shows R-intervals have specific structure (Lemmas 7-8)
4. Shows classes within R-intervals are elementarily equivalent (Lemma 9)
5. Performs MODEL SURGERY: replaces a "bad interval" by one of its classes (Lemma 12)
6. Shows the surgery preserves temporal truth (60+ lines of case analysis on Until/Since)
7. Derives contradiction: R holds in modified structure N, but N is also a Prior structure, and R's definition implies N can't have the gap (Lemma 13)

Key insight: Prior-UZ does NOT directly contradict gaps via a single formula application (in discrete orders, U(φ, ¬φ) is trivially satisfied by s=succ(t) with vacuous intermediate condition). The contradiction is INDIRECT via model transformation.

### Three Options for Unblocking

**OPTION A: Faithful Reynolds (8+ hours)**
- Formalize Lemmas 6-13 step by step
- Requires defining ρ(x) as a MonadicFormula (existential + universal over the carrier)
- Requires constructing its temporal equivalent via table_correctness
- Requires the model-surgery lemma (Lemma 12) -- biggest single sub-proof
- Result: `no_gaps_discrete` works for ALL Prior structures (not just chronicles)

**OPTION B: Z1 shortcut for chronicle (4-6 hours)**
- Prove that Z1 semantic validity + specific k-type structure → IsSuccArchimedean
- Only works for the chronicle (monadic structure has enough predicates to distinguish points)
- Key challenge: showing the chronicle's atom map provides "enough resolution" for the Z1 backward induction
- Result: `chronicle_is_good` works; general `no_gaps_discrete` remains sorry'd

**OPTION C: Direct succ_cofinal from Z1 (3-5 hours)**
- Prove `succ_cofinal` for the chronicle domain using Z1 ∈ MCS + backward induction on MCS membership
- This is essentially the converse of the Z1 soundness proof applied to the chronicle's MCS structure
- Key insight: Z1(φ) ∈ fmcs(t) for all t and all φ. Combined with MCS properties (consistency, maximality, deductive closure), this constrains the ordering to be succ-Archimedean.
- Result: `limitDomSubtype_isSuccArchimedean` gets a real proof; existing `one_class` + `chronicle_is_good` work unchanged

### Immediate Next Action

Choose one of Options A/B/C and start implementation. Option C is likely shortest but most novel (not in Reynolds). Option A follows the plan faithfully but is longest.

### Key Decisions Made
- Phase 2 k=1 sorry: resolved using finite model property (good_one theorem)
- Prior-UZ gap elimination: CANNOT be done by simple formula substitution in discrete case (vacuous intermediate condition)
- The Reynolds argument is fundamentally a model-transformation proof, not a direct Prior-UZ contradiction

### File Locations
- Main file: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
- Lines 804-822: `no_gaps_discrete` (current, uses IsSuccArchimedean)
- Lines 851-864: `one_class` (current, uses IsSuccArchimedean)
- Lines 872-894: `very_good_implies_good` (uses orderIsoIntOfLinearSuccPredArch)
- Lines 901-922: `chronicle_is_good` (uses orderIsoIntOfLinearSuccPredArch)
- Literature: `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` lines 470-816
- Table.lean: `table_correctness` (sorry-free), `temporal_truth` definition
- ChronicleExtraction.lean: `ChronicleAsPriorModel` structure with `prior_UZ_valid` field
