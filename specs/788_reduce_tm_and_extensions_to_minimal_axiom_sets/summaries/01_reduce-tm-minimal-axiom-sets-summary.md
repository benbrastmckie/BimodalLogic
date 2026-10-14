# Implementation Summary: Task #788

- **Task**: 788 - Reduce TM and its extensions TM_z, TM_d, and TM_r to minimal axiom sets
- **Status**: [COMPLETED]
- **Started**: 2026-10-14T16:25:00Z
- **Completed**: 2026-10-14T21:15:01Z
- **Effort**: ~4 hours agent time (plus detached build wall-clock)
- **Dependencies**: None
- **Artifacts**: plans/01_reduce-tm-minimal-axiom-sets.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`inductive Axiom` is reduced from 29 to 20 constructors (Base 16 / ZTime 1 / Dense 1 / RTime 2).
The nine demoted schemata are machine-checked derived theorems: UE, UT, NF (and TR of NF) in
`ProofSystem/DerivedAxioms.lean`; TC, NP, NA in the new `Theorems/ConnectDerived.lean`; TL (from
CN) and DN (from NN) in the new `Theorems/LinearityDerived.lean`; Z1 recovered through the ZTime
completeness engine in the new `Metalogic/CompletenessDerived.lean`. Every call site, automation
table, Plus/C-validity bridge, Independence pin, test, tooling entry, Typst output, and document
named by the task was repointed, and the stale underivability claim about TL was retracted.

## What Changed

- `FormalSystem/ProofSystem/Axioms.lean` — nine constructors and the `density`/`z1`
  `minFrameClass` rows deleted; docstring (layers, Sources table, counts) refreshed
- `FormalSystem/ProofSystem/DerivedAxioms.lean` — `untilF` (UE), `fUntilEquiv` (UT),
  `discretePropagateFwd` (NF), `discretePropagateFwdMirror`; exported `impTop`, `guardMonoThm`,
  `eventMonoThm`; `sinceP`/`pSinceEquiv` reflect the derived primaries; TC/NP mirrors moved out
- `FormalSystem/Theorems/ConnectDerived.lean` — Created: `connectFuture` (TC), `fHImp`,
  `discreteSymmFwd` (NP), `discretePropagateBwd` (NA), the mirrors `connectPast`,
  `discreteSymmBwd` (+`At` forms), and the computable stock `compLeft`, `compRight`, `curryThm`,
  `lceImpThm`, `rceImpThm`, `untlBotFalseThm`, `gMonoThm`
- `FormalSystem/Theorems/LinearityDerived.lean` — Created: `tempLinearity` (TL from CN, UF, UE),
  `density` (DN from NN), `tempLinearityLegacy`/`tempLinearityPast` (+`At` forms, moved from
  `Combinators`), `orInlThm`, `orInrThm`, `claviusThm`, `orElimThm`
- `FormalSystem/Metalogic/CompletenessDerived.lean` — Created: `z1Derivable`, `z1Thm`,
  `densityDerivable` (cross-check)
- `FormalSystem/ProofSystem/LinearityDerivedFacts.lean` — rewritten as the CN/TL record; the
  branching-frame underivability claim retracted (that frame refutes CN itself)
- `FormalSystem/Metalogic/WeakCanonical/FrameProperties.lean` — `z1_in_frame` deleted (no
  dependents)
- Repointed consumers: `Theorems/{TemporalDerived,ContextualProofs,DiscreteUnfolding,
  DedekindDerived,ModalDerived,Combinators,Propositional/Core}.lean`, `Examples/Walkthrough.lean`,
  the BXCanonical/WeakCanonical/Bundle/Chronicle/Quasimodel engines,
  `Decidability/Verified/RuleSpec.lean` (`ruleAxioms` rows), `Automation/Tactics/Search.lean`
  (`axiomCtors`, `tryGatedDerivedMatch` gains `density` and `z1Thm`),
  `Automation/ProofSearch/Core.lean` (nine `matchAxiom` arms deleted, seven computable derived
  arms added to `mirrorCandidate`), `Conservativity/Backward.lean` (`z1_translate` via `z1Thm`),
  `MinusLanguage/AxiomDischarge.lean`, `Conservativity/Plus/AxiomValidity.lean` and
  `Independence/CoarsenedModels.lean` (`_of_tm_deriv` idiom), `Independence/{ZTimeSharpness,
  DenseRTimeSharpness,RationalWitness,LexIntWitness}.lean`, `PlusLanguage/{Derivation,
  Substitution}.lean`, `Metalogic/{Soundness,SoundnessLemmas/FrameClassVariants,
  ConvexConsequence/SurvivalTable}.lean` (exhaustive arms), seven test files, and the tooling
  (`AxiomNames`, `MachineAppendixMain` 29→20, `ProofStepExtractor`, `DatasetGenerator`,
  `FormulaEnumerator` reindexed 0-19, `ProofExtractorMain`, `TableauProofStepsMain`,
  `Tests/BimodalToolsTest/ProofFirstTests.lean`)
- `FormalSystem.lean` — regenerated (`mk_all`) with the three new modules
- `typst/generated/{status,machine-appendix,automation-module-map}.*` — regenerated (20 axiom
  entries); `typst/chapters/{03-proof-theory,06-notes,00-introduction,p4-proof-automation}.typ` —
  the nine rows marked derived and repointed (sync Check 1 required the moved identifiers)
- `docs/reference/axiom-reference.md`, `docs/reference/paper-definitions-of-record.md` (dated
  amendment), `docs/theorem-index.md` (eleven new rows with `Paper:` anchors at each
  declaration), `docs/{ARCHITECTURE,user-guide/architecture,project-info/*,development/
  MODULE_ORGANIZATION}.md`, `README.md`, module READMEs — counts and narrative refreshed;
  `scripts/lean-citation-manifest.json` regenerated

## Decisions

- **TL decision**: derived from CN (`LinearityDerived.tempLinearity`); Burgess A4a not restored.
  Anchors: Xu 1988 §3 (Σ₄ complete for linear frames without A4a) and §4 Theorem 4.3 ((13)
  strictly weaker than (10)). `LinearityDerivedFacts.lean` records the retraction.
- **Computable derivations** (plan deviation, recorded in `issues.jsonl`): the scratch proofs
  of TC/NP/NA/TL/DN go through `deductionTheorem`/`orElim`/`lceImp`/`rceImp`/`pastKDist`/
  `untlBotFalse`, all `noncomputable`, while their consumers (`ProofSearch/Core.mirrorCandidate`
  evaluated by `#guard`, `BimodalTools/ProofExtractorMain`, `connectFutureThm`) are computable.
  Every statement is verbatim; the proof terms were rebuilt from `bCombinator`, `theoremFlip`,
  `pairing`, `notNotIntro`, `doubleNegation`, `contraposeImp`, `combineImpConj`, `efqAxiom`,
  `someFutureMono`, TN and TR. All nine verify with `propext` only.
- **`ruleAxioms` rows** (plan deviation): GATE 3 (`ruleAxioms_covers_ruleFrameClass`, by
  `decide`) forbids `[]` above `.Base`, so `densityRule`/`z1Rule` are grounded in
  `dense_indicator`/`prior_UZ` (the constructors their derivations consume, the `priorSZ`
  precedent); `orderTrichotomy`/`timeLinearity` are `[]` as planned.
- **Z1 stays engine-recovered** (`Classical.choice`); its four runtime rows in
  `ProofExtractorMain` were deleted (no walkable tree) and the two `modal_search` Z1 tests became
  `noncomputable example`s. A direct computable Z1 derivation remains the plan's optional
  follow-up.
- **Machine appendix** keeps the primitive-only schema (20 rows); the derived schemata are
  documented in the reference manual, `axiom-reference.md` and `theorem-index.md`.
- Plan counts corrected: by class the reduced inductive is Base 16 / ZTime 1 / Dense 1 /
  RTime 2 (the plan's "Base 17" was an off-by-one).

## Plan Deviations

- **Phase 2/3 (altered)**: computable proof terms in place of the scratch's deduction-theorem
  route (statements unchanged) — see Decisions.
- **Phase 5 (altered)**: `densityRule`/`z1Rule` grounded in `dense_indicator`/`prior_UZ`
  instead of `[]` (GATE 3).
- **Phase 6 (skipped)**: `MinusTemporalDerived.lean:353,360` and `SpCountermodel.lean:153` are
  `MinusLanguage.Axiom.temp_linearity` (the Minus system's own constructor), not the TM one.
- **Phase 6/7 (altered)**: `ProofExtractorMain`'s z1 runtime rows deleted (noncomputable
  `z1Thm`); `FormulaEnumerator` arms deleted and reindexed (its matcher returns `Σ φ, Axiom φ`).
- **Phase 7 (altered/skipped)**: `StarLanguage/Embedding.lean` arms match `PlusAxiom` (kept, not
  dead); `RuleSpec`'s "constructor enumeration" is over `TableauRule`; three plan-unlisted
  exhaustive matches fixed (`PlusLanguage/Substitution.lean`, `Independence/RationalWitness.lean`,
  `Independence/LexIntWitness.lean`); `Derivation.lean`'s `Axiom.density` example retargeted at
  `dense_indicator`.
- **Phase 8 (scope addition)**: `typst/chapters/*.typ` rows updated (sync Check 1 forced the four
  moved identifiers; the remaining rows were corrected for honesty); `typst/FormalFoundations.typ`
  untouched per the plan.

## Verification

- Build: Success — guarded whole-tree build of `FormalSystem`, `BimodalTest`, `BimodalTools`,
  `BimodalToolsTest` and all 15 `lean_exe` roots (4968 jobs, zero errors, zero warnings);
  see the Final pass line below
- Sorry count: 0
- Vacuous count: 1 — `Examples/TemporalStructures.lean:495` (`int_domain_universal … := trivial`),
  present unchanged at the base commit d04e7d46a; a `trivial` proof of a universal-domain
  statement, not a placeholder; outside this task's files
- Axiom count: 0 `axiom` declarations (the 14 `^axiom ` grep hits are prose lines, identical to
  the base commit)
- `lean_verify`: `untilF`, `fUntilEquiv`, `discretePropagateFwd`, `discretePropagateFwdMirror`,
  `connectFuture`, `discreteSymmFwd`, `discretePropagateBwd`, `tempLinearity`, `density` —
  `propext` only; `z1Derivable`, `z1Thm` — `propext`, `Classical.choice`, `Quot.sound`
- Tests: Passed — `BimodalTest`/`BimodalToolsTest` build (their `#guard`/`#eval` tests run at
  elaboration), incl. `WeakeningSearchTest`, `TacticsTest`, `EdgeCaseTest`, `ProofFirstTests`
- Gates: `check-module-invariants.sh --no-build` exit 0 (C14, C15 incl. all 288 ledger rows,
  C20, C21, C22 (20 names), C28, C33, C35, INV); `typst-sync-check.sh` PASS (4 checks);
  `readme-lint.sh` PASS; `verify-deploy.sh` PASS (15 checks)
- Out-of-task findings: `check-paper-definitions.sh` exits 1 — 26 recorded blocks of the
  external paper drifted (its `def:frame` wording etc.); this task's only edit to the record is
  the 15-line amendment, which the block-hash comparison does not read. `lean-challenge-snapshot.sh
  --check 788 .` exits 71 (advisory): no plan-time snapshot manifest exists.
- Plan compliance spot-check: all eleven Goals declarations found; the two `[MISSING]` hits are
  `minFrameClass` (exists as `Axiom.minFrameClass`, a dotted name the loop cannot match) and
  `z1_in_frame` (a deletion target, correctly absent)
- Files verified: Yes
- Final pass: `lake-build-guard.sh build -- build FormalSystem BimodalTest BimodalTools BimodalToolsTest <15 exes>` on the committed tree: GUARD_EXIT=0, `Build completed successfully (4968 jobs)`, 0 errors, 0 warnings, every touched `.olean` newer than its source

## Impacts

- Downstream modules consume TC/UE/UT/TL/NP/NF/NA/DN/Z1 as theorems; `modal_search` reaches all
  nine (`@[tmLemma]` and `tryGatedDerivedMatch`), and the runtime `boundedSearchWithProof`
  closes the seven Base shapes through `mirrorCandidate`
- `PlusAxiom`/`StarAxiom`/`MinusLanguage.Axiom` are unchanged; their TM-validity bridges use the
  derived theorems
- The dataset/extractor outputs no longer carry the nine axiom names as steps; the z1 rows are gone

## Follow-ups

- Optional (plan non-goal): a direct computable Z1 derivation (UZ, CN-mirror, US, UF, UE, TC) so
  the extractor can regain z1 rows and `tryGatedDerivedMatch` can drop `Classical.choice`
- Re-baseline `check-paper-definitions.sh` against the externally edited paper (pre-existing)
- Take the lean-challenge snapshot for future `--check` runs (never created for this task)
- Two pre-existing `TODO: add description` inventory rows in `Metalogic/README.md`
  (`Deterministic.lean`, `ZTimeProvability.lean`) are untouched

## References

- specs/788_reduce_tm_and_extensions_to_minimal_axiom_sets/plans/01_reduce-tm-minimal-axiom-sets.md
- specs/788_reduce_tm_and_extensions_to_minimal_axiom_sets/reports/01_reduce-tm-minimal-axiom-sets.md
- specs/788_reduce_tm_and_extensions_to_minimal_axiom_sets/evidence/Scratch788.lean
- specs/788_reduce_tm_and_extensions_to_minimal_axiom_sets/issues.jsonl
- specs/788_reduce_tm_and_extensions_to_minimal_axiom_sets/handoffs/
- Commits: 458d09d4e (P1), 79c244ac7 (P4), fc536b6a1 (P3), 032d21f9a (P2), 078e6109f (P5),
  ba6c0f5dd (P6), de8a7e472 (P7), c3a3dd6aa (P8), 717df1f48 (P9)
