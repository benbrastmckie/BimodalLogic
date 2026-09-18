# Implementation Summary: Task #606

- **Task**: 606 - Adopt the paper axiom system and derive the surplus axioms
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T04:00:00-07:00
- **Completed**: 2026-09-18T07:12:00-07:00
- **Effort**: ~3.2 hours
- **Dependencies**: None
- **Artifacts**: plans/01_paper-axiom-system.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`inductive Axiom` now has exactly the paper's 29 primitive schemata. TL, CN and TS are stated as the paper states them, with the 3-way disjunctions right-associated. All 16 former surplus constructors are now proved derived definitions in namespace `FormalSystem.ProofSystem.DerivedAxioms`:
- the 12 time-reflection (TR) mirrors,
- `modal_4` and `modal_b`,
- `prior_SZ` and `prior_S_gap`.

Three pre-paper forms are also derived: TL and CN in their old order and grouping, and TS as `⊤ → F⊤`. The full build, the test library, all 13 executables, `check-module-invariants.sh` and `typst-sync-check.sh` are all green. No sorry or axiom was added.

## What Changed

- `FormalSystem/ProofSystem/Axioms.lean`:
  - 16 constructors deleted, leaving 29.
  - TL is restated as `F(Fφ∧ψ) ∨ (F(φ∧ψ) ∨ F(φ∧Fψ))`.
  - CN is restated as `A ∨ (B ∨ C)`.
  - TS is restated as bare `F⊤`.
  - The `minFrameClass` arms for the removed constructors are gone.
  - Docstrings rewritten; the NA docstring now says that `discrete_propagate_bwd` *is* NA.
- `FormalSystem/ProofSystem/DerivedAxioms.lean` (new):
  - 10 Base TR mirrors (`serialPast`, `leftMonoSinceH`, `rightMonoSince`, `connectPast`, `enrichmentSince`, `selfAccumSince`, `absorbSince`, `sinceP`, `pSinceEquiv`, `discreteSymmBwd`).
  - The gated `priorSZ (h : ZTime ≤ fc)` and `priorSGap (h : RTime ≤ fc)`.
  - `serialFutureImp`.
  - Each has a context-lifted `…At Γ` form.
- `FormalSystem/Theorems/Combinators.lean`, in the `DerivedAxioms` namespace:
  - `modalB` and `modal4`, derived from MT, M5 and MK with a local EFQ+Peirce double-negation step.
  - The computable permutation combinators `contraSwap`, `orRotate` and `orAssocRev`.
  - `tempLinearityLegacy`, `linearUntilLegacy`, `tempLinearityPast` and `linearSince`.
- Soundness:
  - New lemmas `temp_linearity_paper_valid`, `linear_until_paper_valid` and `serial_future_paper_valid`.
  - The generic lemmas `validIn_imp_or_rotate` / `validIn_imp_or_assoc` and `serial_future_paper_swap_valid`.
  - Dispatcher arms updated in `Soundness.lean`, `FrameClassVariants.lean`, `PlusLanguage/{Derivation,Substitution}.lean` and `Independence/{LexInt,Rational}Witness.lean`.
- TM⁺ / TM⋆ lockstep:
  - `PlusAxiom` and `StarAxiom` TL, CN and TS are restated identically.
  - New Star lemmas: `starValid_*_paper`, `starValid_serial_future_imp` and `starValid_serial_past_bare`.
  - New Plus/Coarsened transfer lemmas: `plusValidIn_of_tm_deriv`, `plusValidIn_swap_of_tm_deriv`, `cValid_of_tm_deriv` and `cValid_swap_of_tm_deriv`.
- Automation and the decision procedure:
  - `ProofSearch/Core.lean`: new `mirrorCandidate` / `matchMirror` / `matchPriorSZ`, and a top-level `F⊤` arm in `matchAxiom`.
  - `Tactics/Search.lean`: new `tryGatedDerivedMatch`; the Base mirrors are `@[tmLemma]`.
  - `FormulaEnumerator`: indices compacted to 29.
  - `RuleSpec`: grounded in the TR primaries.
  - `Closure.lean`: `ClosureReason.axiomNeg` now carries a derivation, so negated derived schemata still close tableau branches.
  - Axiom name lists are down to 29.
- About 440 call sites in `Theorems/`, `Metalogic/`, `Automation/` and `Tests/` were rewritten to the derived definitions.
- Data, docs and generated files:
  - Dataset metadata now carries `axiom_system: "paper-29"`.
  - `docs/reference/axiom-reference.md` is rewritten: the primitive system, a "Derived schemata" table, and the paper-key table.
  - `paper-definitions-of-record.md` note updated.
  - Typst chapters 03 and 06 and `SYNC-MAP.md` updated.
  - `typst/generated/{machine-appendix.*,status.typ,automation-module-map.typ}` regenerated (29 axiom rows).
  - About 25 README and doc count claims fixed.
  - The `check-module-invariants.sh` C14 stale-count set now includes 45.

## Decisions

- **Naming (deviates from the plan's Challenge Statements)**:
  - The derived definitions use lowerCamelCase: `since_P` becomes `sinceP`, `modal_4` becomes `modal4`, and `temp_linearity_legacy` becomes `tempLinearityLegacy`.
  - Reason: the repository enforces C16 `defsWithUnderscore` and the C26 snake_case-`def` scan, and its nolint admission bar rejects "we prefer the old name" as a reason for an exemption.
  - The statements are exactly the Challenge Statements; only the identifiers differ. All call sites were rewritten, so nothing depends on the old names.
- **Where `modal4`, `modalB` and the linearity mirrors live**:
  - They are in `Combinators.lean`, not in a new `ModalPrimitiveDerived.lean`. A local double-negation step removed the dependency on `Propositional.Core`, so `temporalFutureDerived` did not have to move.
  - Every permutation is built from K, S, B, C and double-negation elimination, so the derivations stay computable for proof search and extraction.
- **Tableau closure**: the tableau's negated-axiom closure was generalized to accept a derivation (`axiomNeg φ fc₀ d label`). Without this, `TableauConformance` regressed on the BX11', BX10' and BX7' rows.
- **`discrete_propagate_bwd`** keeps its name, because the machine-appendix and dataset wire tags depend on it. Its documentation now states that it is NA itself.

## Plan Deviations

- **Phase 2**:
  - `ModalPrimitiveDerived.lean` was not created; the definitions were placed in `Combinators.lean` instead.
  - The `temporalFutureDerived` relocation and its import edits were skipped as unnecessary.
- **Phase 3**:
  - A single scripted rewrite of 136 sites (which also covered the phase 5 test sites) and one build replaced per-module commits.
  - `applyDerivTo` was skipped, because no caller passes `modal_4` or `modal_b`.
- **Phase 4**:
  - The mirrors went into a new `mirrorCandidate` rather than `matchDerived`.
  - A gated tactic strategy was added.
  - The `axiomNeg` closure was generalized (not in the plan).
  - Enumerator indices were compacted.
- **Phase 7**:
  - The existing validity lemmas keep their statements. The paper forms are obtained through generic permutation lemmas.
  - `dischargeTempLinearity` was not simplified; it routes through `tempLinearityLegacyAt`.
- **Phase 9**: the machine appendix does not list theorems, so no derived rows were added to it.
- **All phases**: lowerCamelCase names instead of the Challenge-Statement identifiers (see Decisions).

## Verification

- **Build**: Success. The full guarded `lake build FormalSystem BimodalTest` plus all 13 `lean_exe` targets finished green (4219 jobs). `scripts/check-module-invariants.sh` reported ALL CHECKS PASSED, which includes its own C1 `lake build`.
- **Sorry count**: 0 outside Boneyard, unchanged from baseline.
- **Vacuous count**: 0 new. The one pre-existing hit, `Examples/TemporalStructures.lean:480`, is a genuine `True`-typed goal and is unchanged.
- **Axiom count**: 0 `axiom` declarations, unchanged. `#print axioms` / `lean_verify`:
  - All 19 derived definitions depend on `[propext]` only.
  - `soundness_validIn`, `BXCanonical.completeness`, `completeness_rtime` and `sound_of_isValid` remain at `[propext, Classical.choice, Quot.sound]`.
- **Tests**:
  - Passed: `BimodalTest` builds green, including `TableauConformance` (pinned verdict tables unchanged), `TacticsTest` (the `modal_search` mirror and `prior_SZ` goals), `LemmaDBTest` and `ProofSearchTest`.
  - `typst-sync-check.sh` PASS, and the manual compiles.
- **Constructor count**: 29 in `inductive Axiom`. The machine appendix has 29 axiom rows, and `status.typ` has `axiom-count = 29`.
- **Files verified**: Yes.

## Impacts

- Every downstream proof now uses TR-derived mirrors. Soundness recursion is unchanged: TR remains a rule.
- Newly generated datasets serialize mirror steps as `time_reflection` over primitives and carry `axiom_system: "paper-29"`. Existing `data/*.jsonl` files are untouched.
- `FormulaEnumerator` schema indices changed from 45 to 29 slots, so seeded random generation differs from earlier runs.
- The `status.typ` axiom-report table now reflects live declarations: two rows resolve with file "?". This comes from earlier declaration renames and is not caused by this task.

## Follow-ups

- Optional: remove the mirror constructors from `PlusAxiom`, `StarAxiom` and `DetAxiom`. These are separate systems and were out of scope.
- Optional: simplify `dischargeTempLinearity` now that TL is verbatim.
- Optional: fix the stale `typst-axiom-report-modules.txt` entries that render file "?" (predates this task).

## References

- specs/606_adopt_paper_axiom_system_and_derive_surplus_axioms/plans/01_paper-axiom-system.md
- specs/606_adopt_paper_axiom_system_and_derive_surplus_axioms/reports/01_paper-axiom-audit.md
- docs/reference/axiom-reference.md, docs/reference/paper-definitions-of-record.md
