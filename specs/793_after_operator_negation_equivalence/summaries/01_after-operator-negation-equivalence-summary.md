# Implementation Summary: Task #793

- **Task**: 793 - Prove lem:after-negation and the cut cor:after-negation-stable for the event operators of def:event-operators
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T07:15:00Z
- **Completed**: 2026-10-15T09:05:00Z
- **Effort**: ~1.8 hours wall clock, ~45 minutes of it the single full build
- **Dependencies**: None
- **Artifacts**: plans/01_after-operator-negation-equivalence.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`def:event-operators`' `After` and `Before` are now operators of the tree, `lem:after-negation`
is a machine-checked validity over every task frame, and the cut `cor:after-negation-stable` is
machine-checked in both its existential and universal readings natively in L⁺. The mathematics —
next-`φ`-time uniqueness and the pointwise negation equivalence under the `After(φ,⊤)` guard — is
proved **once**, language-generically, in the clause tier of
`FormalSystem/Semantics/TruthClauses.lean`, and instantiated three times: at L, and twice at L⁺.
All seven plan phases are `[COMPLETED]`; the two out-of-tree `.tex` steps of Phase 7 were dropped
by a recorded user decision and are deferred to the paper's own owner.

## What Changed

- `FormalSystem/Syntax/Formula.lean` — `Formula.after φ ψ = Formula.untl φ.neg (φ.and ψ)` and
  `Formula.before φ ψ = (Formula.release φ.neg ψ).and (Formula.someFuture φ)`, each with the
  paper's equation pinned by an `example … := rfl` against its literal primitive expansion. No
  `reflect_time_*` entry, no `complexity` arm, no `reflect_time_norm` registration — `after` and
  `before` have no past dual in the paper, and the attribute block still carries exactly the
  eleven lemmas it did before.
- `FormalSystem/Semantics/TruthClauses.lean` — a new `After` section after `end Future`, over any
  `L` with `[TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]`: the `abbrev after`, the
  `def IsNextTime` (strictly future, `φ` there, `φ` nowhere strictly between), and four theorems
  — `isNextTime_unique` (two next `φ`-times coincide; linearity of `F.Duration` is the only
  order-theoretic input), `after_top_iff` (the guard reads as "there is a next `φ`-time"),
  `after_iff_of_isNextTime` (under a next `φ`-time `z`, `After(φ,χ)` reads `χ` at `z`), and
  `after_negation` (`lem:after-negation`, pointwise). `isNextTime_unique` carries
  `omit [BotClause L] [ImpClause L] [UntlClause L] in` to clear `unusedSectionVars`. No existing
  declaration touched; nothing attribute-tagged.
- `FormalSystem/Metalogic/SoundnessLemmas/EventOperators.lean` — **new module** carrying
  `after_negation_valid : Valid (After(φ,⊤) → (¬After(φ,ψ) ↔ After(φ,¬ψ)))`, with the
  biconditional in the house `(A.imp B).and (B.imp A)` encoding since `Formula` has no `iff`.
  Imports `FormalSystem.Semantics.Validity` and nothing else; written on the `CoValidity.lean`
  precedent, copyright header and module docstring included.
- `FormalSystem/Metalogic/SoundnessLemmas.lean`, `FormalSystem/Metalogic/SoundnessLemmas/README.md`,
  `FormalSystem.lean` — the new module's import line (in alphabetical position in all three), its
  `## Contents` bullet, and its inventory row with a hand-written description.
- `FormalSystem/PlusLanguage/Formula.lean` — `PlusFormula.after`, `Formula.after`'s right-hand
  side verbatim, plus the `ofFormula` commutation `rfl` pin in the existing pin block and the
  operator's name in the module docstring inventory.
- `FormalSystem/PlusLanguage/PlusValidity.lean` — `after_negation_stable_dstab` and
  `after_negation_stable_stab`, both readings of `cor:after-negation-stable`, under a section
  docstring recording that it is cut material implemented from specification and why the
  embedding cannot carry it.
- `Tests/BimodalTest/Syntax/FormulaTest.lean` — `#guard` rows pinning the measured complexities
  (`after` 4, `before` 12) and three `example … := rfl` construction pins including the
  `release`-level spelling of `before`.
- `Tests/BimodalTest/Automation/NormalizationTest.lean` — four `#guard` rows pinning
  `matchBinaryDerived == none` and `foldedBinaryTag == none` for both operators, so a later
  widening of the `strongRelease` arm cannot silently reclassify them.
- `docs/architecture/untl-snce-argument-order.md` — a new "Derived binary operators" section
  recording that `Formula.release a b` is the paper's `Release(b, a)` (same reversal for
  `trigger`), that `Before` therefore ports as `Formula.release φ.neg ψ`, and naming the `rfl`
  pins as the evidence.
- `docs/reference/paper-definitions-of-record.md` — three `KNOWN-ANCHORS` rows (see Plan
  Deviations).
- `FormalSystem/PlusLanguage/README.md`, `FormalSystem/README.md`, `FormalSystem/Syntax/README.md`,
  `FormalSystem/Metalogic/README.md`, `README.md`, `typst/generated/status.typ` — regenerated
  inventory and line-count blocks.

## Decisions

- **`cor:after-negation-stable` is stated natively in L⁺, not through the embedding, and not
  deferred.** This answers the dispatch's explicit open question. `plusValid_ofFormula_iff`
  transports only formulas in the range of `ofFormula`; `ofFormula_ne_stab` proves nothing in
  that range is a top-level `stab`; and the corollary is schematic over arbitrary L⁺ `φ`, `ψ`
  which may themselves contain `⊡`. Because the mathematics lives in the generic clause tier,
  the native L⁺ statements are transcriptions rather than a second proof.
- **The paper's `⊡χ → χ` opening step is not needed.** The `stab` clause *is*
  `∀ σ, τ.state t = σ.state t → …`, so the guard is available at each `σ` directly and the
  reflexive instance never has to be extracted.
- **`Formula.before` is `Formula.release φ.neg ψ`, not `Formula.release ψ φ.neg`.**
  `Formula.release` reverses the paper's `Release` arguments. This is enforced by an `rfl` pin
  against the literal primitive expansion, not by a comment, and recorded in the decision record
  that already owns the argument-order question.
- **No dataset-tooling registration.** `BimodalTools/FormulaEnumerator.lean` was left untouched,
  so the three pinned enumerator counts (`7852`, `75914`, `45111`) are unchanged. Registering the
  new operators would have broken them, and this task does not update that tooling.

## Plan Deviations

- **Phase 7, both out-of-tree `.tex` steps** skipped: the `% PORT:` marker deletion in
  `JPL/possible_worlds.tex` and the two `\leanproof` additions there and in
  `JPL/appendix_cut_material.tex`. Dropped by a recorded user decision (keep all paper edits out
  of scope; implement agents touch only this repository). The paper-side clearance is
  **deferred to the user**, not incomplete work — the `% PORT:` marker under `lem:after-negation`
  is still in place, and `SoundnessLemmas.after_negation_valid` is the declaration a `\leanproof`
  line should name when the paper's owner closes it, with `after_negation_stable_dstab` and
  `after_negation_stable_stab` the pair for the cut corollary.
- **Non-Goals altered**: `docs/reference/paper-definitions-of-record.md` was edited, against the
  plan's Non-Goal. C15 in `check-module-invariants.sh` requires a manifest or `KNOWN-ANCHORS` row
  for every `def:`/`lem:`/`cor:` anchor cited under `FormalSystem/ Tests/ BimodalTools/ typst/
  docs/ README.md`, and the plan's own Phase 7 gate list requires C15 to exit 0, so the citations
  these new docstrings carry made the rows mandatory. Three rows added:
  `def:event-operators` and `lem:after-negation` as `LIVE-UNPINNED` (the docstrings transcribe
  operator structure rather than quoting the paper's prose — the `sent:det` precedent), and
  `cor:after-negation-stable` as `DANGLING` on the `thm:nomic-primitive` precedent, since it
  lives in the untracked cut-material appendix and `--resolve` structurally cannot read it. The
  Non-Goal's stated rationale was concurrent-sibling territory, and every sibling in this batch
  had completed and committed before the edit. A manual replay of C15's own scan confirmed these
  three were the only unresolved anchors, so nothing inherited was absorbed.
- **Phase 3 scope widened by one file**: `FormalSystem.lean` was not in Phase 3's file list, but
  C33 asserts that file is byte-for-byte the generated root, one import line per `.lean` file
  under `FormalSystem/`. The new module's import line was added there in alphabetical position;
  C33 passes at 689 import lines.

## Verification

- Build: **Success**. `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build
  FormalSystem BimodalTest BimodalTools BimodalToolsTest`, detached with the guard's exit captured
  un-piped: `GUARD_EXIT=0`, "Build completed successfully (2963 jobs)", **0** `error:` and **0**
  `warning:` occurrences across both captured streams, and the `.olean` of every one of the eight
  modules this task touched is newer than its source. All three verdict tiers agree.
- Sorry count: **0** (`lean-sorry-census.sh` over all eight resolved source roots).
- Vacuous count: **0** new. The single grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, is byte-identical at the pre-task baseline
  and is an honest `trivial` for a `True`-valued predicate, not a placeholder.
- Axiom count: **unchanged at 14** (`^axiom ` lines over the same roots, identical at the
  pre-task baseline). Per-declaration: `isNextTime_unique` is `[propext]`;
  `after_top_iff`, `after_iff_of_isNextTime`, `after_negation`, `after_negation_valid`,
  `after_negation_stable_dstab` and `after_negation_stable_stab` are all
  `[propext, Classical.choice, Quot.sound]` — measured with `#print axioms`, not asserted. No
  `sorryAx` anywhere.
- Statement fidelity: **machine-checked**. A compiled probe states all five of the plan's
  `## Lean Challenge Statements` verbatim in their primitive spelling (`untl (¬φ) (φ ∧ ψ)` rather
  than the named operator) and discharges each with the implemented theorem; all five elaborate,
  so no implemented statement is weaker than its pinned one.
- Gates, each exit status recorded individually:
  - `scripts/check-module-invariants.sh` — **0**, "ALL CHECKS PASSED", including C15 (81 anchor
    citations resolve), C16 (env_linter: no un-nolisted finding), C23, C26, C28 (0 warnings),
    C33, C34a and C34b.
  - `scripts/check-module-invariants.sh --emit-inventory --check` — **0**.
  - `scripts/check-copyright-headers.sh` — **0** (689 files, 0 missing, 0 nonconforming).
  - `scripts/readme-lint.sh` — **0**.
  - `scripts/check-phantom-citations.sh` — **0**.
  - `.claude/scripts/verify-deploy.sh` — **0**, 15 checks, 0 failures.
  - `scripts/check-paper-definitions.sh` — **1**, on exactly **ten inherited** drifted anchors:
    `CO`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:TMplus`, `app:discrete`, `def:id`,
    `def:strongest`, `thm:exist`, `lem:uniq`. Run without tail-truncation; the full
    `--- anchor:` list was read. **None of this task's anchors appear**, and no sentinel was
    re-pinned. Pre-existing and not absorbed.
  - `lean-challenge-snapshot.sh --check` — **not runnable**: no Challenge manifest exists for this
    task, so there is nothing to diff. Advisory only; the fidelity probe above is the substitute,
    and is a stronger check than a signature diff.
- Enumerator counts: `BimodalTools/FormulaEnumerator.lean` untouched, so `7852`, `75914` and
  `45111` are unchanged, confirmed by the green `BimodalToolsTest` build.
- Files verified: Yes.

## Impacts

- `Formula.after`, `Formula.before` and `PlusFormula.after` are available to every downstream
  module; the `rfl` pins make a future argument-order regression a build failure.
- `TruthClauses.after_negation` and `TruthClauses.isNextTime_unique` are available to any language
  instantiating `UntlClauses` — L, L⁺ and L⋆ today, and any fifth language tomorrow — so a
  further port of the event operators costs a transcription, not a proof.
- `TruthClauses.IsNextTime` gives the tree a named next-time predicate at the semantic layer,
  which it did not have; anything needing "the next `φ`-time" can now quantify over it and reuse
  the uniqueness lemma.
- `FormalSystem/Semantics/TruthClauses.lean` sits high in the dependency graph, so this change
  invalidated the tree; the cost is paid and the rebuild is cached.

## Follow-ups

- The paper-side clearance is **deferred to the user** (see Plan Deviations): the `% PORT:` marker
  under `lem:after-negation` in `JPL/possible_worlds.tex` is still in place, and neither
  `\leanproof` line was added.
- `PlusFormula.release` and `PlusFormula.before` were deliberately not mirrored — the corollary
  does not mention `Before`. A later task wanting `Before` at L⁺ adds two definitions and two
  `rfl` pins.
- No `reflect_time_*` entry exists for `after`/`before`. Adding one would require inventing a past
  dual the paper does not have; the omission is recorded at each operator's docstring.
- No proof-theoretic (derivation-level) counterpart of either result; both deliverables are
  semantic validities, as the plan's Non-Goals specify.

## References

- `specs/793_after_operator_negation_equivalence/plans/01_after-operator-negation-equivalence.md`
- `specs/793_after_operator_negation_equivalence/reports/01_after-operator-negation-equivalence.md`
- `specs/793_after_operator_negation_equivalence/.dispatch/21.md`
- `specs/793_after_operator_negation_equivalence/.decisions.json` (the cycle-3 paper-edit decision)
- `specs/793_after_operator_negation_equivalence/handoffs/`
- `docs/architecture/untl-snce-argument-order.md`
- `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` (the module precedent followed)
