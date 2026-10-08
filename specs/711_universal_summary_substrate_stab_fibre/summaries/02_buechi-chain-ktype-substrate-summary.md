# Implementation Summary: Task #711

- **Task**: 711 - Universal-summary substrate for the `⊡` fibre check on the seam-gluing route
- **Status**: [COMPLETED]
- **Started**: 2026-10-08T00:36:04Z
- **Completed**: 2026-10-08T03:05:00Z
- **Effort**: ~2.5 hours wall clock for Phases 2-9 (Phase 1 carried from the previous dispatch); plan estimate 14.5 hours
- **Dependencies**: 732 (satisfied, E3 reported); 736 (no dependency edge; its report was the plan revision's primary input)
- **Artifacts**: plans/02_buechi-chain-ktype-substrate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The universal-summary substrate for the `⊡` fibre check is built as Büchi's complementation chain
transposed to monadic `k`-types over the `ℤ` time axis: a public cluster
`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/` carrying chain steps 2, 3, 3′, 4, 5a and 5b
sorry-free on the standard axiom profile, a consumer-facing seam interface
`FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` stating the `⊡` bridge against a
hypothesis bundle it does not discharge, axiom pins in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`,
and two wired evidence probes. Nothing here is a decidability result, nothing reduces a `⊡`
condition to a `k`-type-determined target (that reduction, the MSO-to-ω-regular correspondence, is
unformalized in every proof assistant and is carried as the hypothesis field `Presents.colours`),
and no complexity bound is claimed.

## What Changed

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Basic.lean` — new; cluster root with the six-step chain and scope disclaimer; step 2, `kType_finite` (the summary alphabet is finite)
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Segment.lean` — new; `segZ` and `kEquiv_zFiber_segSum` (step 3′) moved byte-identically from `GroupModel/RamseyFactorization.lean`, `private` dropped, namespace unchanged
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Family.lean` — new; `SegmentFactorization` (the former private `ZFactorization`, renamed, with the middle segment's type `τzero`/`zero_type` added), `exists_zFactorization` (the Ramsey cover, made public; the Ramsey ingredient called as `Nat.exists_strictMono_const_pair_colour`), `InFamily`, `family_cover`, the pinned `exists_matching_factorization` (steps 3-4)
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean` — new; `kTypeColouring_eq_of_matching_segments`, the pinned headline `kEquiv_zFiber_of_matching_segments`, the pinned `kTypeOf_zFiber_eq_of_sameTriple`, `kTypeOf_zFiber_eq_of_inFamily` (step 5a: the block `k`-type is a function of the family)
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean` — new; `DeterminedByKType`, `determinedByKType_nfEval`, `family_saturation`, `finite_family_triples`, `target_eq_union_of_families` (step 5b, for `k`-type-determined targets only)
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean`, `KTypeSummary/README.md` — new; aggregator and cluster README (six-step table with final statuses, measured import closure, evidence paragraph, scope disclaimer, recorded follow-ups)
- `FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` — new; `SeamSummary`, the four-field hypothesis bundle `Presents` (`colours`, `determined`, `realized`, `verdict`), the bridge `plusStab_iff_seamSummary`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `RaySummary/README.md` — new; aggregator and README
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` — the four relocated declarations removed, two imports added, two `obtain` patterns widened for the added fields, prose updated; no other proof edit (836 → 700 lines)
- `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` — prose only: the falsified `Nat.nth` note corrected
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — new; 11 `#guard_msgs` + `#print axioms` pins, all on `[propext, Classical.choice, Quot.sound]`; registered in `Tests/BimodalTest.lean`
- `specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean` — new (268 lines); the chain run end to end on a concrete infinite fibre; two distinct blocks in one family are `k`-equal (`zFiber_cPar_eq_cOdd`)
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` — new (344 lines); E2, the depth-2 stratification probe on a state-dependent fixture; falsifier check positive on that fixture
- `scripts/check-evidence-probes.sh` — two `WIRED` entries with doc blocks appended (append only; 17 → 19)
- Registration edits: `FormalSystem.lean` (regenerated), `FormalSystem/Metalogic/WeakCanonical.lean`, `WeakCanonical/README.md`, `GroupModel/README.md`, `FormalSystem/Metalogic/Decidability.lean`, `Decidability/README.md`, inventory rollups in `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, `README.md`, and `typst/generated/status.typ`

## Decisions

- The route is Büchi's chain transposed to `k`-types, exactly as plan v2 fixed it; nothing from v1's `FwdPresentation`/`Profile` design was built.
- Challenge-pinned signatures were kept verbatim. Where their `[Fintype sig.preds] [DecidableEq sig.preds]` binders are consumed only by the proof (`kType_finite`, `exists_matching_factorization`, `finite_family_triples`), Mathlib's `unusedFintypeInType`/`unusedDecidableInType` linters — which have no disposition row in `scripts/warning-budget.txt`, so any emission is a C28 exit 2 — are suppressed declaration-scoped with a C29 reason comment rather than by changing the pinned statement.
- The relocation phases kept every fully-qualified name: the new modules sit in namespace `FormalSystem.Metalogic.WeakCanonical`; `RamseyFactorization.lean` imports them. The Risks-table fallback (drop `private` in place) was never needed; `inflate_left`/`inflate_right` keep their axiom profiles.
- Step 5a closed by the plan's settled design (`funext` + `congrArg` on the pointwise-equal colourings, then the mixing lemma); the recorded fallback through `kEquiv_colourStructure_anchored` and its `MonoDiscrete` import was not needed, so the cluster's measured closure (141 modules, no group-model front) is unchanged.
- `Presents` has four fields, not three: `verdict` (the summary's `Bool` is `T` at a representative block) was added under the plan's own "add a fourth rather than weaken" clause, because without it `holds` is unconstrained; `colours` lands each ray pair's block in the summary's family, and the resulting one-family-per-summary limitation is documented in the module docstring and README with the finite-set-of-triples generalisation named as the consumer's option. `family_cover` is not used by the bridge; it is the consumer's tool for producing a summary.
- The substrate probe uses a genuinely different second colouring (odd parity, cut at the odd times) rather than a shifted cutting of the same colouring, so the central `k`-equality is non-trivial; the parity triple's degeneracy is confirmed by `rfl` rather than assumed; no `k`-type distinctness is claimed.

## Plan Deviations

- **Phase 2** altered: `kType_finite` keeps the pinned binders with a declaration-scoped suppression of the two unused-instance linters (reason comment at the site).
- **Phase 4** altered: `exists_zFactorization` keeps its name so the two downstream call sites are untouched, and its two `infinite_ramsey_pairs` calls become `Nat.exists_strictMono_const_pair_colour` because the alias lives downstream (importing it would be a cycle); otherwise byte-identical. The structure is renamed `SegmentFactorization` with the two added fields appended last.
- **Phase 7** altered: a fourth `Presents` field (`verdict`) added, and `colours` restricted to the summary's family, both recorded at the site.
- **Phase 8** altered: different-colouring second block instead of a shifted cutting; family-cover agreement recorded as agreement of statements; `Presents` not inhabited (honest limit, in the header).
- **Phases 2-7, 9** altered: `bash scripts/check-module-invariants.sh` fails on exactly one pre-existing check, C9 at `scripts/check-phantom-citations.sh:145` (a file outside this task's `file_scope`, committed before this task); each such phase is `[COMPLETED WITH EXCLUSIONS]` with a Reasoned Exclusions table, as Phase 1 was. The `--emit-inventory` rollups and `typst/generated/status.typ` (a pre-commit gate) were regenerated and staged with each phase.
- **Phase 9** altered: the raw `^axiom ` census read 15 against the Phase 1 baseline of 14 because a docstring line in the new test module began with the word "axiom" (the same prose false positive the census already produces on two pre-existing test files); the line was rewrapped and the count is 14, with zero `axiom` declarations added by this task.

## Verification

- Build: Success — unscoped guarded `lake build` exit 0 (`Build completed successfully (2828 jobs)`, 0 errors, 0 warnings); guarded `lake build BimodalTest` exit 0 (2890 jobs); every touched module's `.olean` newer than its source (Tier 3)
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved roots; `grep sorry` over `KTypeSummary/` and `RaySummary/` empty)
- Vacuous count: 1 — pre-existing and unchanged (`FormalSystem/Examples/TemporalStructures.lean:495`, recorded as such in the Phase 1 handoff); none introduced
- Axiom count: 14 (unchanged from the Phase 1 baseline; see Plan Deviations for the prose false positive that was rewrapped)
- Tests: Passed — `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` builds with all 11 `#guard_msgs` matching; `bash scripts/check-evidence-probes.sh` 19/19 PASS, exit 0
- `lean_verify` on every headline (`kType_finite`, `kEquiv_zFiber_segSum`, `family_cover`, `exists_matching_factorization`, `kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple`, `family_saturation`, `target_eq_union_of_families`, `plusStab_iff_seamSummary`, and `inflate_left`/`inflate_right` after each relocation): `[propext, Classical.choice, Quot.sound]`, no sorry
- Harness: `bash scripts/check-module-invariants.sh` — every check PASS (C1, C2, C3, C4, C5, C8, C14, C15, C16, C20, C23, C24, C28 with 0 warnings, C29, C30, C31, C32, C33, INV) except the pre-existing out-of-territory C9
- Plan compliance spot-check: all five `**Goals**` identifiers found (`exists_matching_factorization`, `inflate_right`, `kEquiv_zFiber_of_matching_segments`, `kType_finite`, `kTypeOf_zFiber_eq_of_sameTriple`); no replacement-target integrity failure
- No cslib dependency: `grep Cslib lakefile.toml lake-manifest.json` empty; no `import Cslib` anywhere
- Files verified: Yes
- Comparator gate: not requested (`compare_flag` absent), no `comparator` block

## Impacts

- `FormalSystem.Metalogic.WeakCanonical.{kType_finite, segZ, kEquiv_zFiber_segSum, SegmentFactorization, exists_zFactorization, InFamily, family_cover, exists_matching_factorization, kTypeColouring_eq_of_matching_segments, kEquiv_zFiber_of_matching_segments, kTypeOf_zFiber_eq_of_sameTriple, kTypeOf_zFiber_eq_of_inFamily, DeterminedByKType, determinedByKType_nfEval, family_saturation, finite_family_triples, target_eq_union_of_families}` are now public, consumable by the decidability side without importing the group-model front.
- `FormalSystem.Metalogic.Decidability.RaySummary.{SeamSummary, Presents, plusStab_iff_seamSummary}` give the consumer (the decidable `⊡`-check assembly, task 735) a single named interface; producing a `SeamSummary` and discharging `Presents` for a concrete frame is that consumer's work.
- `GroupModel/RamseyFactorization.lean` is 136 lines shorter and imports the summary cluster; `inflate_left`/`inflate_right` are unchanged in statement and axiom profile.
- The evidence collection grew from 17 to 19 wired probes.
- The two carried limits are preserved, not smoothed: the backward `⊡(Pp)` real-formula bridge stays fixed by the asymmetric-fixture probe only; the MSO-over-`⟨ℤ,<⟩` reduction remains Medium-confidence and is exactly what `Presents.colours` leaves as a hypothesis.

## Follow-ups

- Restate `kType_finite`, `exists_matching_factorization` and `finite_family_triples` over `[Finite sig.preds]` (strictly stronger; the pinned `[Fintype] [DecidableEq]` forms were kept for statement fidelity, with linter suppressions at the site).
- E2's real test: a fixture with three or more states, two of them sharing the depth-1 stratum, and the `⊡(Fp → ⊡Pp)`-shaped mixed formulas; the two-state fixture answers the falsifier's question trivially in the affirmative.
- Generalise `Presents` to finitely many family triples via `finite_family_triples`/`target_eq_union_of_families` if the consumer's seams spread over several families.
- A task-type-neutral home for the `k`-type kernel (`KType`, `kTypeOf`, `KEquiv`, the mixing lemma) outside `WeakCanonical/` — considered and deferred, recorded in the cluster README.
- The pre-existing C9 citation at `scripts/check-phantom-citations.sh:145` is outside this task's territory and remains the harness's one red check.
- Operator hand-off items from task 736's summary (two stale statements in `specs/ROADMAP.md`'s E3 section) are untouched here, as the plan's Roadmap Alignment required.

## References

- specs/711_universal_summary_substrate_stab_fibre/plans/02_buechi-chain-ktype-substrate.md
- specs/711_universal_summary_substrate_stab_fibre/reports/01_universal-summary-substrate.md
- specs/736_cslib_omega_automata_survey_and_e3_reopen_check/reports/01_cslib-omega-automata-survey.md
- specs/711_universal_summary_substrate_stab_fibre/handoffs/ (phase-2 through phase-9 handoffs)
- specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean
- specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean
- specs/evidence/seam-gluing-ray-product/device-selection-probe.lean (E3)
- Commits: 58a1f221d (phase 2), 1c5240459 (phase 3), 0ec4bdc2f (phase 4), 8f1e4a800 (phase 5), b892e9ea6 (phase 6), 060c05951 (phase 7), 0cb63681f (phase 8)
