# Implementation Summary: Task #653

- **Task**: 653 - What sees recurrence and transposition in a task frame: state registers, state nominals, since/until, and the stability modal (verdict-first)
- **Status**: [COMPLETED]
- **Started**: 2026-09-22T17:06:58Z
- **Completed**: 2026-09-22T17:20:00Z
- **Effort**: ~15 minutes of agent time (one guarded scoped build, one full build, one new 94-line probe compiled first try)
- **Dependencies**: 645 (translation-product port; delivered). Related, not blocking: 624, 628, 651 (sibling, concurrent).
- **Artifacts**: plans/01_what-sees-recurrence.md, reports/01_what-sees-recurrence.md, probes/04_quantified-transposition.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The research round had already answered Q1–Q5 with three sorry-free probes and a numbered
report; this implementation round stayed inside the task directory, as the task contract
requires, and did three things: re-verified probes 01–03 against `.olean`s rebuilt from source
and pinned their measured axiom profiles; closed the one routinely checkable UNVERIFIED item
(the quantified transposition sentence) with a fourth probe whose `qTrans_defines` signature is
byte-identical to the plan's challenge block; and wrote the three hand-offs below so the report's
recommendations can be acted on without re-deriving them. Nothing under `FormalSystem/`,
`Tests/`, `docs/`, or `scripts/` was touched, and the manuscript was not edited.

## What Changed

- `specs/653_what_sees_recurrence_language_extensions/probes/04_quantified-transposition.lean` — Created (94 lines, namespace `Probe653`): `qTrans` (abbrev, the sentence `∀p ∀q (Atom_r(p) → Atom_r(q) → ¬(E(p ∧ F q) ∧ E(q ∧ F p)))`), `qTrans_valid` (true everywhere on a recurrence-free frame; the `←` core is `recurrenceFree_not_transposed` reused verbatim), `qTrans_defines` (valid on a frame iff the frame is recurrence-free; `→` instantiates both quantifiers at the singleton of a recurring state, as `qRec_defines` does). `lake env lean` exit 0, no output; profile `[propext, Classical.choice, Quot.sound]`; no `sorryAx`.
- `specs/653_what_sees_recurrence_language_extensions/reports/01_what-sees-recurrence.md` — Appendix A: re-verification record for probes 01–03 with four measured profiles lighter than first stated (`BoxFree` none; `constHist` and `hybridValidOn_iff_hsatSet_univ` `[propext, Quot.sound]`; `hsatSet` `[propext]`) and a probe 04 entry; §6 table cell Transposition × "L + ∀p (standard)" now **visible** (`qTrans_defines`); Appendix B item 6 closed; Recommendation 1 port list gains `QuantLanguage/QuantRecurrence.lean: qTrans, qTrans_valid, qTrans_defines`, estimate ~400 lines; Sources/Artifacts headers list probe 04.
- `specs/653_what_sees_recurrence_language_extensions/plans/01_what-sees-recurrence.md` — phase markers and checklist annotations.

**Four-probe inventory (all sorry-free; `lake env lean` exit 0, no output, against source-rebuilt `.olean`s):**

| Probe | Lines | Declarations | Measured profiles |
|---|---|---|---|
| 01_invariant-languages-blind | 265 | 12 | `boxFree_histMap_invariance` `[propext]`; `BoxFree` (def) none; 10 others `[propext, Classical.choice, Quot.sound]` |
| 02_nominals-break-product | 259 | 13 | `hybridTruthAt_iff_mem_hsatSet`, `hsatSet` `[propext]`; `constHist`, `hybridValidOn_iff_hsatSet_univ` `[propext, Quot.sound]`; 9 others the triple |
| 03_limit-closure-device | 44 | 2 | both the triple |
| 04_quantified-transposition | 94 | 3 | `qTrans` none; `qTrans_valid`, `qTrans_defines` the triple |

## Decisions

- Built ten modules in the Phase 1 scoped build (the nine the probes import plus
  `QuantLanguage.QuantRecurrence`) so probe 04 elaborated against the same fresh build; no
  second build was needed before the final full one.
- `qTrans_valid` reads the doubly updated model's `p`- and `q`-valuations through
  `updateAtom_valuation_of_ne _ hpq` / `updateAtom_valuation_self` exactly as the plan directs,
  so all three inequalities `p ≠ q`, `p ≠ r`, `q ≠ r` are consumed; the plan's scope hypothesis
  (three atoms suffice, no fourth inequality) held.
- Plan items 2(d) and 2(f) name the same sentence (Appendix B item 6 is the only occurrence of
  "628 Appendix B item 4, unchanged"), so one edit covered both.
- The one repo-wide vacuous-pattern grep hit (`int_domain_universal … := trivial`,
  `Examples/TemporalStructures.lean`) predates this task, is untouched by it, and is a real
  proof of a universal domain predicate; it is recorded, not counted against this task.

## Plan Deviations

- **Phase 1, scoped build** altered: ten modules built instead of nine (added
  `QuantLanguage.QuantRecurrence` so Phase 2 shared the fresh build).
- **Phase 1, commit** altered: the plan file (checklist annotations) was committed alongside the
  report rather than the report alone.
- **Phase 2, report edits** altered: the Executive Summary's "~350 lines" mention was updated to
  "~400 lines" alongside Recommendation 1 to keep the two consistent.

## Verification

- Build: Success — full `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached, guard exit 0, `Build completed successfully (2704 jobs)`, zero `error:` over both streams; `.olean` newer than source for `QuantLanguage/QuantRecurrence` and `HybridLanguage/HybridTransposition` (the modules probe 04 exercises) and for all nine modules probes 01–03 import.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; in the task directory the only `sorry` string is the docstring phrase "sorry-free")
- Vacuous count: 0 in any file this task touched (one pre-existing repo-wide hit, see Decisions)
- Axiom count: 14 (baseline 14; this task touched no file under the source roots, so unchanged)
- Tests: N/A (no library file changed)
- Files verified: Yes — `qTrans_defines` and `qTrans` diff empty against the challenge block; `git show --name-only` of this task's commits lists only `specs/653_what_sees_recurrence_language_extensions/**`; `grep -rn "task 653" FormalSystem Tests docs scripts README.md` prints nothing.
- Comparator gate: not requested (`compare_flag` absent); the plan anticipated `solution_module_unresolved` in any case since the solution lives under `specs/`.

## Impacts

- The report's feature table now has every Transposition cell compiled or labelled: state
  nominals and standard propositional quantifiers see recurrence *and* transposition; every
  morphism-invariant language (L, L⁺, L^▷, L⋆, L⁺ + `[≡]`, the since/until fragment) sees neither.
- UNVERIFIED items 1, 2, 3, 4, 5, 7, 8 remain, as the task's hard constraints permit; item 6 is
  closed.
- No downstream module changes: the library is exactly as the research round left it.

## Follow-ups

### 1. Follow-up port task (Recommendation i) — ready to paste; this task did NOT create it

Per the prior-cycle decision recorded in `.decisions.json` ("Open the follow-up port task from
the drafted description once this task completes"), the description below is for a `/task`
call, type `lean4`:

> Port the translation-product invariance and hybrid-determinism probes into the library.
> Source: the four sorry-free probes under specs/653_what_sees_recurrence_language_extensions/probes/ (namespace Probe653), every declaration of which compiles against the live tree. Targets: (1) `FormalSystem/Semantics/Frames/TranslationProduct.lean` — add `classValid_iff_recurrenceFree_of_prodInvariant` (the meta-theorem: for any truth predicate invariant along the projection for lifted models, class validity equals validity over the recurrence-free members), restate the three `*ValidIn_iff_recurrenceFree` as its instances, and add `stabClass_lift_unique`, `projH_mem_stabClass` (the projection restricts to a bijection of stability classes); (2) new `FormalSystem/OpenLanguage/OpenInvariance.lean` — `state_eq_lift`, `open_invariance`, `openValidIn_iff_recurrenceFree` (proved directly on the product, not through `HistMorphism`, whose `lift` is too weak for the open-future/open-past clauses — keep the docstring saying so); (3) `FormalSystem/HybridLanguage/HybridInvariance.lean` — `regFree_prod_invariance`, `regFreeValidIn_iff_recurrenceFree`, and delete the "Not formalized" row in that file and in `HybridLanguage/README.md`; (4) new `FormalSystem/Metalogic/Independence/HybridDeterminismUndefinable.lean` — `hsatSet`, `hybridTruthAt_iff_mem_hsatSet`, `hybridValidOn_iff_hsatSet_univ`, `fzero_hybridValidOn_iff_f1`, `deterministic_not_hybridDefinable`; (5) `FormalSystem/Semantics/Truth.lean` or a small new `FormalSystem/Semantics/TenseFragment.lean` — `BoxFree`, `boxFree_histMap_invariance`; (6) `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` — `blc_cRefuted_product`, `liftK_eK_pasteClosed` as the worked instance; (7) `FormalSystem/QuantLanguage/QuantRecurrence.lean` — `qTrans`, `qTrans_valid`, `qTrans_defines`. Also port from probe 02 as the library's own record: `recF_valid_product`, `transF_valid_product`, `recF_separates`, `transF_separates`, `recF_separates_trivial`, `reg_not_prodInvariant`, `hybridValidOn_incomparable` (place them with the product results or in `HybridInvariance.lean`). Constraints: no new axiom (profiles are `[propext, Classical.choice, Quot.sound]` at most; `boxFree_histMap_invariance`, `hybridTruthAt_iff_mem_hsatSet`, `hsatSet` are `[propext]`); every probe declaration ported, none rediscovered or re-proved from scratch; the "proof device, never an intended model" caveat of `TranslationProduct.lean` restated in every new docstring; manuscript cited by label or quotable phrase only; no task-number references in any file under FormalSystem/, Tests/, docs/, or scripts/. Registration files a module-adding port touches: `FormalSystem.lean`, the aggregators `FormalSystem/Semantics/Frames.lean`, `FormalSystem/OpenLanguage.lean`, `FormalSystem/HybridLanguage.lean`, `FormalSystem/QuantLanguage.lean`, `FormalSystem/Metalogic/Independence.lean`, the READMEs of each touched directory, `scripts/measure-refactor-partitions.py`, the C14 pins in `scripts/check-module-invariants.sh`, `docs/theorem-index.md`, and the axiom-profile tests under `Tests/BimodalTest/Semantics/` (`HybridLanguageAxiomTest.lean`, `OpenLanguageAxiomTest.lean`, `QuantLanguageAxiomTest.lean`). Dependencies: none blocking (645 and 628 delivered; this task, 653, completed). Estimate ~400 lines, one round.

Suggested `file_scope`: `FormalSystem.lean`, `FormalSystem/Semantics/Frames.lean`,
`FormalSystem/Semantics/Frames/TranslationProduct.lean`, `FormalSystem/Semantics/Truth.lean`,
`FormalSystem/Semantics/TenseFragment.lean`, `FormalSystem/OpenLanguage.lean`,
`FormalSystem/OpenLanguage/OpenInvariance.lean`, `FormalSystem/OpenLanguage/README.md`,
`FormalSystem/HybridLanguage.lean`, `FormalSystem/HybridLanguage/HybridInvariance.lean`,
`FormalSystem/HybridLanguage/README.md`, `FormalSystem/QuantLanguage.lean`,
`FormalSystem/QuantLanguage/QuantRecurrence.lean`, `FormalSystem/QuantLanguage/README.md`,
`FormalSystem/Metalogic/Independence.lean`,
`FormalSystem/Metalogic/Independence/HybridDeterminismUndefinable.lean`,
`FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean`,
`FormalSystem/Metalogic/Independence/README.md`, `Tests/BimodalTest/Semantics/HybridLanguageAxiomTest.lean`,
`Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean`,
`Tests/BimodalTest/Semantics/QuantLanguageAxiomTest.lean`, `scripts/measure-refactor-partitions.py`,
`scripts/check-module-invariants.sh`, `docs/theorem-index.md`.

### 2. Manuscript remark (Recommendation ii) — text and placement only; no edit made

Placement: `sub:Conclusion`, immediately after the unfolding sentence ("the branching tree of
states is not posited but may be recovered by unfolding the transitions that the task relation
permits"). Alternative: `sec:Construction`, after "it is by specifying a time x in a history τ
that we may determine which world states occur before or after x in τ". Text, verbatim from the
report's §5.3:

> Although the possible worlds may revisit a world state and may pass through the same world
> states in different orders, the languages `BL`, `BL` with `⊡`, and `BL⋆` cannot express either:
> over any class of task frames each validates exactly the sentences it validates over the
> frames whose possible worlds never revisit a world state, as the Lean 4 repository shows by
> unfolding each frame along an absolute clock. Recurrence and transposition are secured by the
> choice of primitives rather than asserted by the logic, as the simulation metasemantics of
> §`sub:AbsoluteTime` intends; a register that stores a *world state*, rather than a time or a
> world, is the least addition that expresses them, `↓ᵢ ¬(i ∧ (P i ∨ F i))` being valid exactly
> over the frames free of recurrence.

Optional one clause at `sub:Extension`, after "cross reference either times or worlds": that
storing times and worlds still does not re-identify a world state, and that a state register
would.

Repository evidence to cite: for the blindness half, `validIn_iff_recurrenceFree`,
`plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree`
(`FormalSystem/Semantics/Frames/TranslationProduct.lean`); for the visibility half,
`recF_defines`, `bindRec_defines`, `transF_defines` (`FormalSystem/HybridLanguage/`), and now
`qTrans_defines` for the quantifier form (probe 04; `QuantLanguage/QuantRecurrence.lean` after
the port). Optionally, beside the existing footnote on `sent:det`, `deterministic_not_hybridDefinable`
(probe 02, once ported) to say that state registers and time registers see disjoint features.
The remark touches no theorem and no definition of the paper.

### 3. Completeness take-aways (Recommendation iii) — citable by this summary's path

- (a) Clocked canonical frames are WLOG for L, L⁺, L⋆, L^▷ and L⁺ + `[≡]` at every frame class
  — witness `classValid_iff_recurrenceFree_of_prodInvariant` (probe 01) — and NOT for any
  system with state nominals — witness `hybridValidOn_incomparable` (probe 02): frame-level
  validity of a frame and its product are incomparable once nominals enter. Fix the language
  before choosing the engine.
- (b) The since/until (`□`-free) fragment transfers along any history-lifting *map*, neither
  `onto` nor `lift` consulted — witness `boxFree_histMap_invariance` (probe 01, `[propext]`
  only); a canonical bundle need not be onto histories for the tense part of a truth lemma.
- (c) Nominals buy nothing for closure — witness `blc_cRefuted_product` (probe 03): the coarse
  countermodel and its paste-closure survive the product — and nothing for determinism —
  witness `deterministic_not_hybridDefinable` (probe 02); a nominal engine still needs the
  closure schemata and still cannot axiomatize the deterministic class without time registers.
- (d) The device that yields `blc` is the Extension Theorem (`exists_maximal_of_chainClosed`),
  not a morphism of bundles: treat "every closure trace is the trace of a coherent chronicle" as
  the whole problem.

### 4. Other

- The report's Context Extension Recommendation (a `morphism-invariance-table.md` pattern file
  under `context/project/lean4/patterns/`) is unactioned; it belongs to the agent-system source
  store, not this repository's deliverables.

## References

- `specs/653_what_sees_recurrence_language_extensions/plans/01_what-sees-recurrence.md`
- `specs/653_what_sees_recurrence_language_extensions/reports/01_what-sees-recurrence.md`
- `specs/653_what_sees_recurrence_language_extensions/probes/0{1,2,3,4}_*.lean`
- `specs/653_what_sees_recurrence_language_extensions/handoffs/` (phase-1, phase-2 handoffs)
- `specs/653_what_sees_recurrence_language_extensions/.decisions.json` (prior-cycle decision on the port task and the manuscript remark)
- `specs/624_translation_product_task_semantics_visibility/reports/01_translation-product-visibility.md` (originating research)
- `FormalSystem/QuantLanguage/QuantRecurrence.lean`, `FormalSystem/HybridLanguage/HybridTransposition.lean` (the two modules probe 04 composes)
- Commits: `786ac9300` (phase 1), `247e3b785` (phase 2)
