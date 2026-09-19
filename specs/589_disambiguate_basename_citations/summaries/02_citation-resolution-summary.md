# Implementation Summary: Task #589

- **Task**: 589 - Disambiguate the 35 basename citations C20 cannot verify (and absorb three broken `specs/` docstring citations)
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T00:00:00Z
- **Completed**: 2026-09-18T00:00:00Z
- **Effort**: ~3 hours
- **Dependencies**: None
- **Artifacts**: plans/02_citation-resolution-plan.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

C20 reported 35 citations it could not check. It now reports none, and every edit is to comment or docstring text. The 22 ambiguous citations had their paths qualified to a unique suffix and their line numbers corrected; 21 of the 22 numbers were wrong. The 13 citations of files outside the live tree (Boneyard and Mathlib) and the 4 broken `specs/` references were changed to cite by name with no line number. This is option 3, and the convention is now written into the C20 header.

## What Changed

- `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/{BadIntervals,Lemma34,Lemma5,Singletons}.lean`: `Defs.lean:*` became `DenseModelSurgery/Defs.lean:{671,584,197,567,540}`, and `Soundness.lean:1601` became `Metalogic/Soundness.lean:1065`. The adjacent wrong `ProofSystem/Axioms.lean:422` became `:453`.
- `FormalSystem/Metalogic/Decidability/Tableau.lean`, `Tests/BimodalTest/TableauConformance.lean` and `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`: the paths are qualified and the numbers corrected (for example `ProofSystem/Axioms.lean:176/277/442/453`, `ProofSystem/DerivedAxioms.lean:85/165`, `Syntax/Formula.lean:136/149/159/198/211` and `BXCanonical/Completeness.lean:77`). Two companion numbers that pointed at the wrong file (`serialPast` and `priorSGap` live in `DerivedAxioms.lean`) were fixed as well.
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` and `FormalSystem/Metalogic/WeakCanonical/Kamp/PriorINF.lean`: the three `Formula.lean:163-179` citations, which would have landed on blank lines, now point at `Syntax/Formula.lean:189` (the NAME-COLLISION WARNING). The empty slot is filled with `:174`, `Dedekind` is renamed to `RTime`, and `Core/MaximalConsistent.lean:491` is corrected to `:462`.
- Six `Kamp/` files cite the Boneyard by name: `NegFix`, `NfMultiAnchorBridge`, `ExteriorFiberK`, `ExteriorPinnedConverseK`, `Prop42Contentful` and `Section5Correspondence`. They now give the path plus a declaration name or a quoted comment marker, such as "PHASE 3 RESOLUTION", "B.1 gap remains UNFIXABLE", `f2sub1`/`f2sub2` or `f2_carrier_eq`. `Prop42Faithful.lean`, `NfMultiAnchorBridge.lean` and `Section5Correspondence.lean` had 8 inbound line citations shifted by +1 or +2 so they follow the added lines.
- `FormalSystem/Syntax/BigConj.lean`, `FormalSystem/Syntax/MinusLanguage/Axioms.lean` and `Tests/BimodalTest/Property.lean`: the dead `specs/` references are removed. In `.../NfMultiAnchorBridge/CarrierK1V.lean`, `specs/305 report 40` became the Lemma 3.2(2) anchor.
- `scripts/check-copyright-headers.sh`: the Mathlib line ranges are dropped and the declaration names kept.
- `scripts/check-module-invariants.sh`: the C20 header records the qualify-or-cite-by-name convention, and the INFO message now says how to fix a flagged row. The resolver logic is unchanged.

## Decisions

- Line counts were kept unchanged in any file that other modules cite by line. Where a paragraph could not be reflowed within 100 columns, three things were done instead: prose was tightened slightly, a second declaration was cited by name only, or a companion `:NNN` form was used. When a line count had to change, every inbound citation was shifted mechanically using a difflib line map, so each one still lands on the same line content.
- `Kamp/PriorINF.lean:~93` and the extension-less `VecEADecomp:233/244` and `KampPrior:307` are left as they are. C20 does not read them, and they were outside the plan's required scope.

## Plan Deviations

- **Task 1.6** altered: to keep line counts stable, three sentences were slightly tightened, and the adjacent `Axioms.lean:422` was corrected.
- **Task 2.5** altered: `DerivedAxioms.serialPast` at Tableau ~:165 is cited by name only. `FormalSystem/` was dropped at ~:1926, the companion form `:159` is used at ~:1928, and two files grew by one line (neither has inbound citations).
- **Task 3.4** altered: the empty slot was filled with `:174`, `Dedekind` became `RTime`, `MaximalConsistent:491` became `:462`, and `priorSGap` is cited by name only.
- **Task 4.8** altered: NegFix cites the Boneyard path without the `FormalSystem/` prefix. CarrierK1V is worded more compactly. Two files grew, and their inbound citations were shifted. The optional CarrierK1V conversions were skipped.
- **Task 5.1** altered: tier 1 is 1031, not the 1028 the plan predicted. The extra 3 come from splitting companion lists into separately qualified citations (+4) and one companion form (-1).

## Verification

- Build: Success. `lake build FormalSystem BimodalTest.Property BimodalTest.TableauConformance` completed with 2672 jobs and no warnings or errors.
- C20: INFO is absent (0). Tier 1 is `PASS all 1031 resolvable`, with zero out-of-range or blank landings. Tier 2 is `PASS zero`.
- Full `scripts/check-module-invariants.sh`: ALL CHECKS PASSED.
- `scripts/check-copyright-headers.sh`: runs.
- Sorry count: 0 introduced. Every diff is to comment or docstring text.
- Vacuous count: 0 (no declarations changed).
- Axiom count: unchanged.
- Task-reference lint: the added lines contain no `task N` or `specs/` references. `grep 'specs/[0-9]'` finds no live `.lean` hits.
- Tests: N/A. The test modules compile.
- Files verified: Yes. Each companion number C20 does not read was checked by hand against its declaration.

## Impacts

- C20 now covers every `file.lean:NNN` citation in the live tree. Because the convention is recorded, future citations of archived or Mathlib files will not reintroduce INFO rows.

## Follow-ups

- Many citations still pass tier 1 but point at the wrong line. Examples are `NoGaps.lean:153/157`, several `PriorINF.lean:86/93/230` citations, and `NegFix.lean:669`. The proposed tier-1.5 name-near-line check (report Recommendation 5) would catch these.
- The `~NNN` and extension-less citations (`PriorINF.lean:~93`, `VecEADecomp:233`, `KampPrior:307`, `PriorDefs:22`) are out of C20's regex.

## References

- specs/589_disambiguate_basename_citations/plans/02_citation-resolution-plan.md
- specs/589_disambiguate_basename_citations/reports/02_citation-resolution-map.md
- specs/589_disambiguate_basename_citations/reports/01_unverifiable-citation-inventory.md
