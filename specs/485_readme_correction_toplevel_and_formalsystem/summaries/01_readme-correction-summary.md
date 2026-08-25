# Implementation Summary: README Correction — Top-Level and `FormalSystem/**`

- **Task**: 485
- **Plan**: `specs/485_readme_correction_toplevel_and_formalsystem/plans/01_readme-correction.md`
- **Status**: COMPLETED — all 10 phases
- **Type**: lean4 (documentation; one `.lean` module docstring)

## Gate results

| Gate | Baseline | Final |
|------|----------|-------|
| `bash scripts/check-module-invariants.sh` | ALL CHECKS PASSED | **ALL CHECKS PASSED** (exit 0; C1 `lake build` PASS, C2/C3/C5/C8/C9 PASS) |
| `bash scripts/readme-lint.sh` broken references | 5 | **0** |
| `bash scripts/readme-lint.sh` missing READMEs | 9 | 9 (unchanged — out of scope) |

Both layer tables (`FormalSystem/README.md`, `FormalSystem/ProofSystem/README.md`) sum to **45**
across ten rows in nine numbered layers, and agree with each other.

## Source-derived ground truth (re-verified at implementation time)

Counted directly from `inductive Axiom` in `FormalSystem/ProofSystem/Axioms.lean`:
4 + 5 + 18 + 4 + 1 + 5 + 2 + 1 + 2 + 3 = **45**, nine numbered layers with layer 3 split into
3 (BX Temporal, 18) and 3b (Additional BX Temporal, 4). Cumulative per class from
`Axiom.minFrameClass`: Base 37, Dense 39, Discrete 40, Dedekind 42.

## What changed

**`README.md`** (Phases 1-2): deleted the "Active sorry obligations" section, which named
`WeakCanonical/Transfer.lean` and `WeakCanonical/Separation/` as carrying sorries when the
structural inventory is zero. Replaced "axiom-free" with the house phrasing from
`FormalSystem/Metalogic.lean`. Marked Discrete and Dedekind completeness proven. Added the
three-way strong-completeness split (Discrete refuted, Base/Dense open, Dedekind not stated) and
the `ValidDedekindDense` binder clause. Renamed Continuous to Dedekind with the TM⁺_c gap note.
Corrected all constructor and per-class counts. Added a Decidability subsection. Regenerated the
Project Structure tree from the filesystem. Expanded `WeakCanonical/`. Repaired the metrics-table
formatting slip.

**`FormalSystem/README.md`** (Phase 3): removed the "decidability fully proven" over-claim,
replacing it with the sound-direction-only statement and the retired-as-vacuous record; added the
fourth variant with a `### TM Dedekind` section; swept 42 -> 45 and "8 layers" -> nine; rebuilt
the root-file table from `wc -l` with the Lake root *pair* described and `BaseLanguage.lean`
added; added `BaseLanguage/` unlinked and `Boneyard/` as the archive; `lake build Bimodal` ->
`lake build FormalSystem`; `../../` -> `../`.

**`FormalSystem/ProofSystem/README.md`** (Phase 4): fixed the Dense/Discrete split on the correct
side; swept 42 -> 45; added the fourth variant; deleted the `Substitution.lean` row and the
`Formula.subst` entry (neither exists); refreshed four line counts.

**`Metalogic/Algebraic/`, `Metalogic/BXCanonical/`** (Phase 5): deleted two phantom file rows;
reconciled three contradictory scope statements against the corrected anchor; repaired the last
two sibling-aggregator rows in the house pattern; widened BXCanonical to four classes; removed
the phantom `truth_lemma` and named the nine real `TruthLemma.lean` declarations; refreshed both
module tables.

**`Metalogic/WeakCanonical/`** (Phase 6): replaced four phantom Key Results with
`countermodel_discrete` and `truth_transfer`; rebuilt the module table to 19 loose modules and 8
subdirectories; removed the archived `ExpressiveCompleteness/` from the live architecture.

**`Metalogic/{Bundle,Decidability,Core}/`, `FrameConditions/`** (Phase 7): removed the Bundle
hedges against nonexistent sorries; un-staled the Decidability sound-direction claim while
preserving the biconditional-not-established bullet byte-identical; repaired the Core aggregator
row and flowchart; corrected FrameConditions' `FrameClass` citation (`:378` -> `:519`), class
count, five marker typeclasses with the `DedekindTemporalFrame` docstring transcribed, and four
line counts.

**`Semantics/`, `Theorems/`, `FormalSystem/Theorems.lean`** (Phase 8): completed both inventories;
rewrote four PROVEN/SORRY-FREE-conflating status tokens; repointed a directory-shaped link.

**B14** (Phase 9): repointed four archived references into `Boneyard/Kamp/KampWeakCanonical/`,
labelled as archived; repointed `Bridge.lean` -> `MonotonicityDuality.lean`; replaced the P1-P5
range with a six-row table naming each declaration and its site.

## Decisions taken

- **D1**: `BaseLanguage/` listed as a plain unlinked Submodule Navigation row with README column
  "No" — adding a link would have created a sixth broken reference and failed the gate.
- **D2**: `Bimodal.*` renamed to `FormalSystem.*` inside this task's file scope only.
- **D3**: `Metalogic/README.md` not edited; `Algebraic/README.md` cites the `BXCanonical` ->
  `Algebraic.FlowFrame` dependency by naming the four importing sites and transcribes **no**
  import count.
- **D4**: `file_scope` in `specs/state.json` extended from 13 to 17 entries before Phase 9 edited
  its four files.
- **D5**: archived references repointed rather than deleted.

## Plan Deviations

- **Phase 2** — altered: the Project Structure tree is rooted at `.` (repository root) rather than
  a directory name. The clone target is `ProofChecker` while the working directory is
  `BimodalLogic`; `.` is copy-pasteable either way.
- **Phase 3, Unlisted 5** — altered: the stale BX-Temporal `22` was in the layer table's BX
  Temporal row, not at the line the plan named. Rebuilt as 18 + a 3b row of 4. An unlisted defect
  in the same table and at the Dense variant section was fixed alongside: `density` was printed as
  `Gφ → GGφ`, but `Axioms.lean` states it as `GGφ → Gφ`.
- **Phase 9** — altered: `Perpetuity/README.md`'s Helper and Bridge lemma lists named snake_case
  declarations (`box_to_future`, `modal_duality_neg`, `box_mono`, `dne`, …) that do not exist; the
  live names are camelCase. Fixed alongside — same file, same defect class.
- **Phase 10** — added: `Metalogic/Bundle/README.md` carried a fifth "axiom-free" occurrence at
  its "Axiom-Free Reflexive Semantics" heading, unlisted by the plan but caught by the gate's own
  `grep -rn 'axiom-free'` sweep. Rewritten to the house phrasing.

## Corrections to the plan's own figures

Two Shared-ground-truth sites were re-derived at implementation time and differ from the plan's
table; the observed values were used, per each phase's Scope Hypothesis:

- `completeness_discrete` is at `Metalogic/StrongCompleteness.lean:781`, not
  `Metalogic/BXCanonical/Completeness.lean:296`.
- `completeness_dedekind` is at `Metalogic/StrongCompleteness.lean:469` (as the plan states), and
  `completeness` (Base) at `BXCanonical/Completeness.lean:26`, not `:196`.

## Downstream handoffs

1. **D2 remainder**: roughly 30 `Bimodal.*` module references remain outside this task's file
   scope. They are currently invisible to check C5, whose regex is anchored on
   `FormalSystem|BimodalTest`. A repo-wide sweep should rename them.
2. **D3 remainder**: `FormalSystem/Metalogic/README.md:44-45` gives "2 import lines" for both
   `BXCanonical -> WeakCanonical` and `BXCanonical -> Algebraic`. The re-derived values are **9**
   and **4**. The substantive claim is correct; only the numerals are stale.
3. `docs/reference/axiom-reference.md` still needs its 42-to-45 sweep.
4. `FormalSystem/Metalogic/Bundle/README.md` carries four readme-lint Check 2 "NOT LISTED"
   entries (`LimitMCS.lean`, `LimitMCSCoherence.lean`, `RealExtension.lean`,
   `RealExtensionBundle.lean`). Check 2 is not part of this task's gate and the plan assigned
   Bundle only B8.
5. One `axiom-free` occurrence survives in a `.lean` docstring
   (`Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean:322`). Editing it is outside this
   task's non-goals (no `.lean` changes beyond the `Theorems.lean` docstring).
6. `FormalSystem/Metalogic/WeakCanonical/TruthLemma.lean:39` claims "6 documented sorries" in its
   module docstring, which C3 contradicts. Same `.lean` non-goal applies.

## Provenance note

The A7 metrics figures (539 files / ~170,898 lines of code / ~96,290 comment lines) arrived in the
working tree **before** this task and were carried forward unchanged; only the dropped space in
`| Comment lines | ~96,290|` was this task's own edit.

## Files modified (18)

`README.md`, `FormalSystem/README.md`, `FormalSystem/ProofSystem/README.md`,
`FormalSystem/Metalogic/Algebraic/README.md`, `FormalSystem/Metalogic/BXCanonical/README.md`,
`FormalSystem/Metalogic/WeakCanonical/README.md`, `FormalSystem/Metalogic/Bundle/README.md`,
`FormalSystem/Metalogic/Decidability/README.md`, `FormalSystem/Metalogic/Core/README.md`,
`FormalSystem/FrameConditions/README.md`, `FormalSystem/Semantics/README.md`,
`FormalSystem/Theorems/README.md`, `FormalSystem/Theorems.lean`,
`FormalSystem/Metalogic/WeakCanonical/EFGames/README.md`,
`FormalSystem/Metalogic/WeakCanonical/Expressiveness/README.md`,
`FormalSystem/Metalogic/WeakCanonical/Separation/README.md`,
`FormalSystem/Theorems/Perpetuity/README.md`, `specs/state.json`.
