# Code Review Report — Post-Cleanup-Batch

**Date**: 2026-07-24
**Scope**: all (full codebase, immediately after the tasks 384/385/386/359/375 cleanup batch)
**Reviewed by**: Claude

## Summary

- Total files reviewed: 279 live .lean files (424 incl. Boneyards) + lakefile, Tests/, ROADMAP.md
- Critical issues: 0
- High priority issues: 0
- Medium priority issues: 1
- Low priority issues: 3
- Informational confirmations (passed): 6

The codebase is in its healthiest recorded state: the flagship results
(`completeness_discrete`, `completeness_dense`, and the full Kamp chain
`nf_nvar_exist_all_depths` → `US_expressively_complete_over_prior`) kernel-verify at exactly
`[propext, Classical.choice, Quot.sound]`; no non-Boneyard file imports a Boneyard module;
the test suite references no archived modules; both Boneyard READMEs match measured inventory.

## Critical Issues

None.

## High Priority Issues

None.

## Medium Priority Issues

### Tier-2 excision spec for `ghr93_cases_III_IV` undersells its dead-code closure
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean:2162`
**Description**: The archived Boneyard-hygiene audit's Tier-2 table lists this 7-sorry
declaration as near-consumer-free, but the actual dead closure is a 4-declaration chain:
`ghr93_cases_III_IV` → `ghr93_cases_II_III_IV` (:3604) → `ghr93_inductive_step` (:3660) →
`Theorem6.lean:124,413`'s two exported theorems (zero call sites repo-wide; `WeakCanonical.lean`
and `Transfer.lean` import `Theorem6` but never call either export).
**Impact**: A literal execution of the existing Tier-2 row would freshly orphan two
intermediate declarations — the very anti-pattern the hygiene methodology was designed to avoid.
**Recommended fix**: Before executing this row, widen the excision spec to the full
4-declaration closure (plus any `Theorem6.lean` decl exclusively consumed by the two dead
exports), or confirm `Theorem6.lean` must stay with only the dead theorems excised.

## Low Priority Issues

### Live-tree sorry count is 40, not ~36 — Algebraic zone omitted from all inventories
**File**: `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean:83`,
`Algebraic/LindenbaumQuotient.lean:177,182`, `WeakCanonical/Expressiveness/CaseAnalysis.lean:3380`
**Description**: Precise comment-stripped scan finds 40 statement-position sorries.
`G_monotone` (zero consumers) and `provEquiv_all_future_congr` (backs `G_quot`, whose consumers
are file-local/dead; `BooleanStructure.lean` on the live cone never references it) were never
enumerated in any prior debt inventory. The CaseAnalysis extra is a counting gap in an
already-tracked cluster.
**Impact**: None on audited axiom sets (verified transitively dead), but the inventory is
incomplete and the "~36" figure is stale.
**Recommended fix**: Add both Algebraic declarations to the Tier-2 dead-code sweep candidate
list; re-baseline the figure to 40.

### Stale "sorry'd" language in hypothesis-gated (non-sorry) proofs
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean:55,149`
**Description**: Docstrings for `d_consistency_left`/`d_consistency_right` say "interior case
sorry'd", but the bodies contain zero `sorry` tokens — the interior case is discharged via the
`h_interior_d` hypothesis parameter. Sibling Kamp files use explicit "NOT a sorry" callouts for
this exact pattern.
**Impact**: Cosmetic, but can mislead both grep-based debt counting and human readers.
**Recommended fix**: Reword both docstrings to "interior case is hypothesis-gated
(`h_interior_d` parameter), not sorry'd", matching the established convention.

### NOTE:/TODO: tag counts are scan-methodology-dependent
**File**: repo-wide
**Description**: Ad hoc greps do not reconcile cleanly with the canonical `/fix-it` scan
(colon-vs-no-colon, file-type scope). The single repo-wide TODO hit is non-actionable
boilerplate in `scripts/readme-inventory.sh`.
**Impact**: Informational only.
**Recommended fix**: Use `/fix-it` for any precise tag inventory.

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| TODO count | 1 (boilerplate, non-actionable) | Info |
| FIXME count | 0 | OK |
| Statement-position sorries (live tree) | 40 (all classified: documented debt or verified dead) | Info |
| Live Kamp-zone sorries | 0 | OK |
| Boneyard import leaks | 0 | OK |
| Flagship axiom set | [propext, Classical.choice, Quot.sound] | OK |
| Build status | Pass (verified during batch, 1789 jobs) | OK |

## Confirmations (all passed)

1. No non-Boneyard file imports a Boneyard module.
2. `lakefile.lean` consistent: two `lean_lib` targets, no `BoneyardArchive` residue, ten `lean_exe`.
3. `Tests/BimodalTest/` imports only live modules.
4. Boneyard README inventory (83 files) matches measured count.
5. Tier-1 archival (EANegation pair, CarrierK1V endInterval skeleton) confirmed executed.
6. `native_decide` docstring claims consistent across `Metalogic.lean`,
   `BXCanonical/Completeness.lean`, and ROADMAP.md — correctly scoped to exclude the 4
   out-of-cone `SignedFormula.lean` sites; ROADMAP's "0 live Kamp-zone sorries" verified.

## Roadmap Progress

### Completed Since Last Review
The entire batch proposed by `review-2026-07-24-metalogic-cleanup.md` landed:
- [x] Fix flagship status docs (Task 384)
- [x] Orphan triage of the Metalogic import closure (Task 385)
- [x] Re-point general completeness; isolate Base-MCS debt (Task 386)
- [x] Boneyard archive hygiene (Task 359)
- [x] Kamp completeness final assembly + axiom audit (Task 375)

ROADMAP.md's Current-state section was refreshed to 2026-07-24 by Task 375 and verified
accurate by this review (no annotation changes needed; the roadmap-integration pass made 0
annotations, 1 item skipped as line-not-found).

### Recommended Next Tasks
1. Execute the Tier-2 dead-sorry sweep with the widened `ghr93` closure and the two
   newly-found Algebraic candidates (Medium+Low findings above).
2. Reword the `DConsistencyTransport.lean` docstrings to the "NOT a sorry" convention (Low).

## Recommendations

1. The Tier-2 sweep is the only substantive remaining cleanup item; fold findings 1+2 into its
   spec before execution so the excision computes full dead closures.
2. Treat the 40-sorry figure as the new baseline; all 40 are classified (documented debt or
   verified dead) — none contaminate the flagship axiom sets.
