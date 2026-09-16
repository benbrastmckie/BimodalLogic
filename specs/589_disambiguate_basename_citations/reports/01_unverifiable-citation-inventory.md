# Sweep Evidence Report: Task #589

**Task**: 589 — Disambiguate the 35 basename citations C20 cannot verify
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence. The complete list of all 35 is below — no further measurement is needed.
**Effort**: Medium. 22 are mechanical path qualifications; 13 need one convention decision that covers all of them.
**Dependencies**: **584** and **585** (both edit files these citations point *into*, so line numbers move) and **591** (Automation renames change cited paths). Run last, so each qualified citation is verified against a settled tree.
**Sources/Inputs**:
- `bash scripts/check-module-invariants.sh` C20 INFO block, plus a full re-derivation using C20's own resolver logic
- `scripts/check-module-invariants.sh` C20 section (lines ~1820–1940)
- `specs/reviews/review-2026-09-16.md`, Finding M4

## Executive Summary

- **C20 tier 1 verifies 1,012 `file.lean:NNN` citations** land on a real, non-blank line. A
  further **35 are unverifiable** — the check reports them and moves on, because it will not guess
  which file was meant.
- They split cleanly: **22 ambiguous** (the basename resolves to 2+ live files) and **13
  unresolved** (it resolves to none).
- **The 22 are mechanical**: qualify the path. Five basenames account for all of them —
  `Axioms.lean` ×7, `Defs.lean` ×7, `Formula.lean` ×6, `Completeness.lean` ×1, `Soundness.lean` ×1.
- **The 13 need one decision, not thirteen.** Eleven cite files in `FormalSystem/Boneyard/` and
  two cite a path inside Mathlib. Neither is in C20's `live` set by construction (the walker prunes
  `Boneyard` and never leaves the repo), so neither can ever resolve. The right outcome is a
  citation convention that marks an intentionally-external target, not 13 edits.
- **These are the citations most likely to be silently wrong.** A basename ambiguous to the
  checker is also ambiguous to a human reader, and none of the 35 has ever had its line number
  verified.

## The 22 ambiguous citations

| Citing site | Cited | Candidates |
|---|---|---|
| `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:763` | `Axioms.lean:524` | 4 |
| `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:772` | `Axioms.lean:377` | 4 |
| `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:774` | `Formula.lean:163` | 4 |
| `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:908` | `Axioms.lean:398` | 4 |
| `Metalogic/BXCanonical/CompletenessDedekind.lean:581` | `Completeness.lean:72` | 3 |
| `Metalogic/Decidability/Tableau.lean:163` | `Axioms.lean:113` | 4 |
| `Metalogic/Decidability/Tableau.lean:1222` | `Axioms.lean:238` | 4 |
| `Metalogic/Decidability/Tableau.lean:1638` | `Axioms.lean:377` | 4 |
| `Metalogic/Decidability/Tableau.lean:1924` | `Formula.lean:131` | 4 |
| `Metalogic/Decidability/Tableau.lean:1924` | `Formula.lean:141` | 4 |
| `Metalogic/WeakCanonical/DenseModelSurgery/BadIntervals.lean:198` | `Defs.lean:461` | 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean:17` | `Defs.lean:384` | 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean:356` | `Defs.lean:197` | 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean:463` | `Defs.lean:367` | 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean:108` | `Defs.lean:461` | 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean:171` | `Defs.lean:340` | 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Singletons.lean:95` | `Soundness.lean:1601` | 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Singletons.lean:122` | `Defs.lean:461` | 3 |
| `Metalogic/WeakCanonical/Kamp/PriorINF.lean:76` | `Formula.lean:163` | 4 |
| `Metalogic/WeakCanonical/Kamp/PriorINF.lean:110` | `Formula.lean:163` | 4 |
| `Tests/BimodalTest/TableauConformance.lean:306` | `Axioms.lean:113` | 4 |
| `Tests/BimodalTest/TableauConformance.lean:460` | `Formula.lean:180` | 4 |

Useful structure to exploit: the `DenseModelSurgery/` cluster (7 citations) almost certainly all
mean `Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean`, its own sibling — and `Defs.lean:461`
appears three times from three different files, so resolving it once resolves three. Likewise
`Axioms.lean:377` and `Formula.lean:163` each appear twice from different files.

**Qualifying the path is only half the fix.** Once the path resolves, C20 tier 1 will check the
line number — and these line numbers have never been checked. Expect some to be wrong. Verify
each against what the citing prose claims to be citing, and correct the number, not the prose.

## The 13 unresolved citations

**Eleven cite the archive** (`FormalSystem/Boneyard/`), which every C20 walker prunes by name:

| Citing site | Cited |
|---|---|
| `Metalogic/WeakCanonical/Kamp/EANegationFix/NegFix.lean:36` | `Boneyard/NegationIndep.lean:346` |
| `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean:101` | `Boneyard/NegationIndep.lean:357` |
| `Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean:75` | `Boneyard/NegationIndep.lean:341` |
| `Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean:134` | `Boneyard/NegationIndep.lean:346` |
| `Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean:238` | `Boneyard/NegationIndep.lean:193` |
| `Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean:246` | `Boneyard/NegationIndep.lean:196` |
| `Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean:162` | `Boneyard/NegationIndep.lean:346` |
| `Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean:190` | `Boneyard/NegationIndep.lean:357` |
| `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberK.lean:32` | `RefutationF2.lean:335` |
| `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberK.lean:34` | `RefutationF2.lean:582` |
| `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedConverseK.lean:102` | `ExteriorPinnedProbeK.lean:181` |

All three targets are real archived files:
`Boneyard/Kamp/KampWeakCanonical/VecEANormalForm/NegationIndep.lean`,
`Boneyard/Kamp/KampWeakCanonical/TranslationEra/RefutationF2.lean`, and
`Boneyard/Kamp/KampWeakCanonical/ProbeIterations/ExteriorPinnedProbeK.lean`. Citing the archive is
legitimate — these are live modules recording why an archived approach was abandoned — but the
citation is unverifiable as written and its line numbers are frozen against files that no longer
move, which is either an argument for checking them or an argument for not using line numbers.

**Two cite Mathlib**, from `scripts/check-copyright-headers.sh:5` and `:14`, both
`Mathlib/Tactic/Linter/Header.lean:{259,182}`. Those are genuinely external and are doing useful
work: the script's header explains *why* Mathlib's own header linter cannot see this project, and
cites the exact gate (`isInLibraryRoot`) and the predicate it mirrors. This is a citation that
should stay, with a marker saying it is external.

## The decision this task needs

One convention covering both unresolved classes. Options:

- **A marker suffix** — e.g. `Boneyard/NegationIndep.lean:346 (archived)` and
  `Mathlib/Tactic/Linter/Header.lean:259 (upstream)` — with C20 taught to recognise it and report
  such citations as *intentionally external* rather than *unverifiable*. This preserves the
  information and shrinks the INFO block to genuine problems.
- **Extend C20's resolver** to search `Boneyard/` as a secondary set and verify archive citations
  for real, while keeping Mathlib citations marked. More work, more value: archived files still
  drift when the archive is reorganised, and the repository has reorganised its archive before
  (ADR-005 consolidated two trees into one).
- **Drop the line numbers** from archive citations, citing by declaration name instead. This is
  already the repository's documented preference elsewhere — C15 resolves paper anchors "by
  `\label{}` / `\aitem{}` name, never by line number, … which is what lets the lint survive the
  paper's repeated reflowing", and commit `a16df671f` de-line-numbered a set of citations for
  exactly this reason.

The third is most consistent with how this repository already thinks about citations. Recommend
evaluating it first.

## Verification

- `bash scripts/check-module-invariants.sh` C20 INFO count is 0, or is exactly the set of
  citations the new convention marks as intentionally external.
- C20 tier 1 count rises by the number of newly-resolvable citations and still reports zero
  out-of-range or blank-line landings — i.e. every newly-qualified citation was also *correct*.
- C20 tier 2 still reports zero citations in publication-facing scope.
- `lake build` unaffected (these are all comments).
