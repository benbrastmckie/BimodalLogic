# Handoff: Phase 1 Complete, Phase 2 Analysis

## Session: sess_1777945075_1eebea
## Status: Phase 1 COMPLETED, Phases 2-7 NOT STARTED

## Completed Work

### Phase 1: Revert Definition and Restructure

1. **Reverted `BurgessR3Maximal` maximality clause** (ChronicleTypes.lean:323):
   Changed `ClosedUnderDerivation D` back to `SetDeductivelyClosed D`.

2. **Eliminated RRelation.lean:801 sorry**: The Zorn proof now uses the simple argument:
   since D is `SetDeductivelyClosed` (which includes consistency), D is in the
   `burgessR3DCSExtensions` set, so Zorn maximality gives B = D (contradicting B subset D).
   No case split on consistency needed.

3. **Added consistency hypothesis to `BurgessR3Maximal_extension_fails`**:
   New signature requires `h_cons : SetConsistent ({delta} union B)`.
   Uses `deductiveClosure_is_dcs` (existing lemma) for the DCS proof.

4. **Created `BurgessR3Maximal_neg_or_ext_fails`** (unified interface):
   Handles both branches: `delta.neg in B` (inconsistent) OR `not burgessR3(...)` (consistent).
   Placed after `neg_mem_of_inconsistent_union` to avoid forward reference.

5. **Updated call site** at line ~2021: passed `h_cons` to `BurgessR3Maximal_extension_fails`.

6. **Build passes**: `lake build` succeeds with no errors.

## Sorry Count Change

- Before: 13 sorries (1 in RRelation, 3 in PointInsertion, 7 in CounterexampleElimination, 2 in ChronicleToCountermodel)
- After: 12 sorries (0 in RRelation, 3 in PointInsertion, 7 in CounterexampleElimination, 2 in ChronicleToCountermodel)

## Phase 2 Analysis: Event Implication Sorries

### Problem Statement

The two sorries at PointInsertion.lean:1886-1887 require:
- `h_ev_b : DerivationTree [] (event.imp b)` 
- `h_ev_untl : DerivationTree [] (event.imp (Formula.untl b gamma_hat))`

These are inside `burgess_D0_finite_subset_consistent_incons` (the INCONSISTENT case of
Lemma 2.6 seed consistency, where beta.neg in B).

### Root Cause

The `iterated_enrichment` is called with:
- guard = q = b AND untl(b, gamma_hat)
- event (initial) = gamma_hat
- result: event' with `event' -> gamma_hat` (h_impl) and `untl(q, event') in A`

The enrichment provides `event' -> gamma_hat` but NOT `event' -> q` or `event' -> b`.
The event formula has the form: `gamma_hat AND snce(q, alpha1) AND snce(q, alpha2) AND ...`.
There is no way to derive `b` from `gamma_hat` and snce-formulas without BX9 (removed).

### Why the Plan's Suggested Fix Is Insufficient

Plan Task 2.4 says "use q as the base of enrichment". This requires `untl(q, q) in A`,
which cannot be derived from `untl(q, gamma_hat) in A` without:
- BX9 (removed as unsound under open guard)
- Right-mono in the strengthening direction (G(gamma_hat -> q) not available)
- Any density axiom

### Why BX14 Doesn't Help in the Inconsistent Case

In the CONSISTENT case: maximality witnesses give `(untl(b AND beta, gamma_hat)).neg in A`,
enabling BX14 separation to produce `untl(q, q AND (b AND beta).neg) in A`, which puts
q in the event.

In the INCONSISTENT case (beta.neg in B): we have `(b AND beta).neg` is a THEOREM
(since b contains beta.neg). But this does NOT yield `(untl(b AND beta, gamma_hat)).neg in A`
-- there is no axiom deriving neg-until from a contradictory guard without density.

### Possible Approaches

1. **Case split on `(untl(b AND beta, gamma_hat)).neg in A`**:
   - If YES: call `burgess_zeta_consistent` directly (same as consistent case).
   - If NO (meaning `untl(b AND beta, gamma_hat) in A`): use BX7 linearity.
     From BX7 on `untl(q, gamma_hat)` and `untl(b AND beta, gamma_hat)`:
     D3 gives `untl(q AND (b AND beta), q AND gamma_hat)` -- event = `q AND gamma_hat`
     gives `event' -> q -> b`. D2 gives `event' -> gamma_hat AND (b AND beta) -> b`.
     D1 (problematic) gives only `event' -> gamma_hat AND gamma_hat`. Handle D1 specially.

2. **Add irr_until axiom** (the branch is named for this): An axiom like
   `G(phi.neg) -> (untl(phi, psi)).neg` would make `(untl(b AND beta, gamma_hat)).neg in A`
   derivable when the guard is contradictory. This would make Phase 2 trivial.

3. **Restructure to avoid the inconsistent case entirely**: Show that the inconsistent
   case of Lemma 2.6 can be handled without this function (e.g., by showing D0 is
   trivially a subset of some known-consistent set in this case).

### Recommendation

Approach 1 (BX7 case split) is the most faithful to the axiom system. Approach 2
(new axiom) may be appropriate given the branch name. Both require significant work.
Consider running `/revise 107` to update the plan with the BX7-based approach.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (line 323)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (lines 766-784)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (lines 567-593, 703-714, 2021)

## Current State

- Branch: `irr_until`
- Build: passes (`lake build` success)
- No new axioms introduced
- Sorry count: 12 (down from 13)
