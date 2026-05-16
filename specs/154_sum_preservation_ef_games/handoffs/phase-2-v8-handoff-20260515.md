# Phase 2 Handoff v8 - Build Error Fixes

**Task**: 154 - sum_preservation_ef_games
**Session**: sess_1778910329_ef322a
**Timestamp**: 2026-05-15

## Status
Phase 2, Task 2.6 - Partially complete. Fixed 2 of 17 build errors. 15 remain.

## What Was Fixed
- **Category 1 (h_nf_rewrite cast)**: Both occurrences (forward oracle line ~508, backward oracle line ~597) fixed by replacing the `cast (by congr 1 ...) this` pattern with `nf_agreement_monotone (K + 1) (budget - cd.sz j) (cd.sz j) (by omega) ... (fun nf' => cd.agree j nf') nf`. This avoids the dependent type cast entirely by using monotonicity.

## Remaining Errors (15 total)

### Category 2: h_idx' projection (6 errors at lines 548-550, 629-631)
**Problem**: `(Fin.cons (show (orderedSum sig I ms).carrier from <j, c>) env_M p).1` fails because Lean can't resolve `.1` projection on a `Fin.cons` term when the first element uses `show ... from`.

**Recommended fix**: Use `let envM' := Fin.cons <j,c> env_M` + tactic-mode `h_idx'`. Then restructure CompData fields (eM, eN, agree, bound, consistent) to work with `envM'/envN'` using `nf_agreement_monotone` for the agree field and avoiding `subst` for consistent.

### Category 4: sum_lift_one_var agree field (11 errors at lines 788-812)
**Problem**: The agree/bound/consistent fields fail due to subst eliminating outer variable `i`, and `convert/funext/simp` patterns not reducing opaque `show ... from by rw` terms.

**Recommended fix**: Use `nf_agreement_monotone` for agree, avoid subst that shadows outer vars, use explicit hypothesis references instead.

## Key Insight
The pattern that WORKS for dependent type casts in this file: `nf_agreement_monotone d1 d2 n (by omega) ms eM ms' eN (fun nf' => cd.agree j nf') nf` - it bridges any depth mismatch where d1 <= d2.

The pattern that FAILS: `cast (by congr 1; omega) nf` followed by trying to match types.

## Next Actions
1. Fix Category 2: Full CompData restructuring with let-bindings
2. Fix Category 4: sum_lift_one_var cd0 fields
3. After build passes: verify doets_lemma_1_4, run final checks
