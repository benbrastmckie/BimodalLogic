# Implementation Summary: BL (TM) Soundness by Composition

- **Task**: 489 — Prove soundness for the BaseLanguage (BL) proof system at `FrameClass.Base`
  and its Dense/Discrete/Dedekind extensions
- **Plan**: `specs/489_prove_baselanguage_soundness_base_and_extensions/plans/01_bl-soundness-composition.md`
- **Research**: `specs/489_prove_baselanguage_soundness_base_and_extensions/reports/01_bl-soundness-by-composition.md`
- **Type**: lean4
- **Outcome**: all six phases completed; full gate green on the merged tree

## What Was Built

Three new modules, plus registration and documentation sync.

### `FormalSystem/Semantics/BLTruth.lean` (new, 200 lines)

`BLTruthAt : TaskModel F → WorldHistory F → D → BLFormula → Prop`, defined by **native
six-clause recursion on `BLFormula`**, transcribing `def:BL-semantics` clause for clause. The
box clause quantifies over total world-histories (`∀ σ, σ.IsTotal → …`, the `H_F` reading,
identical to `TruthAt`'s); the `allPast`/`allFuture` clauses state the paper's strict `s < t` /
`t < s` universal quantification directly rather than routing through BL⁺'s `untl`/`snce`
abbreviations. The atom clause carries the `∃ (ht : τ.domain t), …` domain conjunct inherited
knowingly from Decision A of `specs/decisions/total-history-validity-decisions.md`, which is
documented in the module docstring and is what makes the bridge's atom case `Iff.rfl`.

**The forbidden design was not used.** `BLTruthAt` is not `TruthAt (tr φ)`; the file contains no
reference to `tr` at all (`grep -c 'tr ' → 0`).

Thirteen `BLTruth.*` characterization lemmas: `bot_false`, `imp_iff`, `box_iff`, `past_iff`,
`future_iff` (the primitive clauses); `neg_iff`, `top_true`, `and_iff`, `or_iff` (derived
Booleans); `diamond_iff`, `somePast_iff`, `someFuture_iff` (the derived existentials, each the
classical `¬∀¬ ↔ ∃` step, written with `push Not` rather than the deprecated `push_neg`); and
`always_iff`.

### `FormalSystem/Semantics/BLValidity.lean` (new, 178 lines)

Five predicates, binder-for-binder mirrors of `Semantics/Validity.lean` with only
`Formula ↦ BLFormula` and `TruthAt ↦ BLTruthAt` substituted, `Type` (not `Type*`) throughout:
`BLValid`, `BLSemanticConsequence`, `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense`.

**No density-free `BLValidDedekind` exists**, and the module docstring carries the BL-native
reason: `(Axiom.dn φ).minFrameClass = .Dense`, `FrameClass.Dense ≤ FrameClass.Dedekind`, so `dn`
(`GGφ → Gφ`) is admissible in any `.Dedekind` BL derivation; it is false on `ℤ` (take `φ` true
exactly at times `≥ t + 2`), and `ℤ` satisfies every binder of the density-free form.

Three inclusion lemmas plus `blValid_iff_empty_consequence`.

### `FormalSystem/Metalogic/BaseLanguageSoundness.lean` (new, 318 lines)

- `truthAt_tr : TruthAt M τ t (tr φ) ↔ BLTruthAt M τ t φ`, **proved by induction**
  (`induction φ generalizing τ t`). `atom`/`bot` are `Iff.rfl`; `imp`/`box` are congruence;
  `allPast`/`allFuture` are the two cases with content, discharged by the existing `@[simp]`
  `Truth.past_iff` and `Truth.future_iff`.
- Corollaries `truthAt_trCtx` (the side-condition discharger) and `blValid_iff_valid_tr`, the
  latter stated **as a theorem** precisely so the distinction from the forbidden definitional
  shortcut is visible in the file.
- `bl_soundness`, `bl_soundness_dense`, `bl_soundness_discrete`, `bl_soundness_dedekind` — each
  one expression: `Conservativity.translate`, then the BL⁺ soundness theorem of the same frame
  class (`Soundness.lean:1086/1260/1406/1933`), then across the bridge. Each copies its source's
  binder bundle; `bl_soundness_dedekind` threads `h_lub` in the same position, between `D` and
  `F`, and carries `[DenselyOrdered D]`.
- The four empty-context validity forms. `bl_soundness_dedekind_valid` concludes at
  `BLValidDedekindDense`, inheriting `soundness_dedekind`'s target.
- `bl_not_derivable_nil_bot` and `bl_not_derivable_nil_bot_discrete`, mirroring
  `not_derivable_nil_bot` (`Soundness.lean:1993`) and its discrete sibling. Dense and Dedekind
  corollaries are deliberately absent — no dense or complete witness frame exists in the tree —
  and the module docstring says so rather than leaving the asymmetry unexplained.
- Three native spot-check `example`s (TK, T4, MT) proving BL axiom schemes valid directly
  against `BLTruthAt`. MT is the informative one: it closes because `τ` is itself total, the
  `H_F` reading of the box clause.

### Module invariant

The plan chose placement **outside** `FormalSystem/BaseLanguage/`, so the invariant
("nothing under `BaseLanguage/` imports anything from `Semantics/`") stays literally true rather
than being weakened. It was nevertheless amended in **both** docstrings
(`FormalSystem/BaseLanguage.lean` and `FormalSystem/BaseLanguage/Formula.lean`) to state
explicitly that it is **directional**: it forbids `BaseLanguage/ → Semantics/` and permits the
converse, which is how `Semantics/BLTruth.lean` acquires `BLFormula`. It is not left silently
ambiguous.

## Measured Gate Results

Recorded verbatim, not paraphrased.

### `#print axioms` — all seven headline results

Re-run in this dispatch with `lake env lean` on a probe importing
`FormalSystem.Metalogic.BaseLanguageSoundness`, against the fully built merged tree (exit 0);
identical to the phase-3 prototype run.

```
'FormalSystem.Semantics.truthAt_tr' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_soundness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_soundness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_soundness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_soundness_dedekind' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_not_derivable_nil_bot' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_not_derivable_nil_bot_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Guard checks

- `grep -c 'tr ' FormalSystem/Semantics/BLTruth.lean` → `0`. The definition never mentions the
  translation.
- `grep -E '^(noncomputable )?def BLValidDedekind\b' FormalSystem/Semantics/BLValidity.lean` →
  no match. Only `BLValidDedekindDense` is defined.
- The three spot-check `example`s elaborate.
- Zero `sorry` and zero new `axiom` declarations in the three new modules.

### Phase 6 full gate — `lake build` and `scripts/check-module-invariants.sh`

Both run on the **merged** tree, after three sibling lean4 tasks landed commits in this
repository (see "Concurrency Observed"). This is the first verification of the combined state.

`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --`, detached:

```
Build completed successfully (2501 jobs).

[exited with code 0]
```

`bash scripts/check-module-invariants.sh`, exit 0, ending:

```
PASS  C5   all module-shaped paths in 1671 markdown files resolve (4 allowlisted)
PASS  C6   all 17 unreachable live module(s) are manifested
PASS  C6   all 15 manifested module(s) still compile in isolation
PASS  C8   every FormalSystem/ and Metalogic/ subdirectory has exactly one sibling aggregator
PASS  C9   zero task-number citations under FormalSystem/
PASS  C12  all slash-shaped source paths in 71 markdown files resolve
PASS  C13  all relative markdown links in 68 markdown files resolve (3 file(s) allowlisted)
PASS  C14  no stale axiom or sorry counts documented in docs/ + README.md + FormalSystem/*.lean
PASS  C15  all 46 paper-anchor citation(s) resolve against specs/paper-definitions-of-record.md

===========================================================
ALL CHECKS PASSED
```

The immediately preceding run of the same script — taken after the Phase 4 Lean edits and before
the Phase 5 markdown edits, so the two runs bracket Phase 5 — reported the same verdict and
additionally showed the checks the tail above cuts off:

```
PASS  C1   lake build exits 0
PASS  C1   lake build BimodalTest exits 0

PASS  C2   all four flagship axiom sets match baseline
            'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]

PASS  C3   structural sorry inventory is ZERO across FormalSystem/ (Boneyard/ excluded)
```

So C2's four pinned baselines are unchanged — the new theorems are additions, not edits to the
pinned set — and C6 passes with the three new modules **reachable** through the two aggregators
rather than manifested (`scripts/module-invariants-manifest.txt` was not touched). No `FAIL C6`
transient appeared in either run.

### Sorry, vacuity, and axiom census

- `bash .claude/scripts/lean-sorry-census.sh FormalSystem/` returns hits only under
  `FormalSystem/Boneyard/` (archived, and excluded by C3, which reports ZERO across the live
  tree). Zero in the three new modules.
- The vacuous-definition regex returns exactly one hit repo-wide,
  `FormalSystem/Examples/TemporalStructures.lean:541`
  (`theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`) — a genuine
  proof of a true proposition about a universal domain, pre-existing and untouched by this task,
  not a placeholder.
- The `^axiom ` regex returns seven hits, **all of them docstring prose** in which a line happens
  to begin with the word "axiom" after a wrap. Zero real `axiom` declarations were introduced.

## Plan Deviations

- **Phase 1 Scope Hypothesis (count confirmed, +1)**: 13 `BLTruth.*` declarations landed, not 12
  — the twelve the report enumerated plus `always_iff`, which the plan listed separately. No
  discrepancy against `BaseLanguage/Formula.lean`'s derived-operator set.
- **Phase 2 Scope Hypothesis (count corrected, 3 of 5)**: `Validity.lean` carries a five-member
  inclusion family; three were mirrored. The two omitted (`valid_implies_validDedekind`,
  `validDedekindDense_of_validDedekind`) both mention `ValidDedekind`, whose BL counterpart is
  deliberately not defined; mirroring them would require the refutable `BLValidDedekind` the plan
  forbids. Recorded in the `BLValidity` namespace docstring. One mirror beyond the family,
  `blValid_iff_empty_consequence`, was added as the report's recommended unfolding lemma for
  `BLSemanticConsequence`.
- **Phase 2 verification line was mis-specified**: the plan asks that
  `grep -n 'BLValidDedekind\b' FormalSystem/Semantics/BLValidity.lean` return nothing. It returns
  five hits, all *prose* warning against defining it. The discriminating check is the
  declaration-level `grep -E '^def BLValidDedekind\b'`, which returns nothing.
- **Phase 1/6 verification line was mis-specified**: the plan asks that
  `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/` return nothing. It never could:
  at the commit preceding this task's first, it already returned two hits, both docstring prose
  (`BaseLanguage/Formula.lean:48` and `BaseLanguage/AxiomDischarge.lean:67`). It now returns
  three, the added one being the Phase 4 directional-invariant sentence in `Formula.lean`. The
  import-level check `grep -rn '^import.*FormalSystem.Semantics' FormalSystem/BaseLanguage/`
  returns nothing, which is the invariant that actually matters, and the amended
  `BaseLanguage.lean` docstring now says in as many words that the grep's only matches are prose
  mentions and that no `import` line matches — so the check sentence a future reader runs no
  longer looks like a failure when it prints those lines.
- **Phase 4 (one site beyond the four)**: the four asserted stale claims were found and amended,
  and no fifth absence-claim existed. A fifth edit was made anyway — the "## No semantics"
  section's closing sentence — so the section's diagram and its prose agree about where the left
  arrow is now built.
- **Phase 5 Scope Hypothesis (six asserted, nine found)**: three additional inventory sites were
  amended — `docs/user-guide/architecture.md` (the `FormalSystem/` directory tree),
  `docs/project-info/implementation-status.md` (the Layer 1 and Layer 2 module tables plus the
  Soundness bullet list), and `FormalSystem/BaseLanguage/README.md`.
  `FormalSystem/Metalogic/README.md` additionally carried a written-out count ("**Five** loose
  files"), corrected to "**Six**".
- **Correction to an earlier record in this same summary**: an earlier revision of this file
  stated that `FormalSystem/BaseLanguage/README.md` "carries no inventory and no absence claim,
  and was left untouched". That reading was wrong on both counts. The file carries a `## Modules`
  table with per-file line counts — `Formula.lean`'s was stale by exactly the seven lines the
  Phase 4 invariant amendment added — and a `## Dependencies` section whose "Imported by" line
  named only `Metalogic.Conservativity`, which the new `Semantics.BLTruth → BaseLanguage.Formula`
  edge falsified. Both were corrected, and a `## Where the BL semantics lives` section was added
  pointing at the three new modules by path, so a reader who arrives at the directory looking for
  a semantics is told where it is instead of concluding there is none.
- **Phase 5 (beyond the plan): stale line counts in `FormalSystem/Metalogic/README.md`**. The
  loose-file table's per-file counts had drifted and were refreshed against `wc -l`:
  `Soundness.lean` 2,022 → 2,042 and `Conservativity.lean` 295 → 311 (both drifted by this task's
  own Phase 4 docstring amendments — 311 is 295 plus exactly the 16 lines added), the root
  `Metalogic.lean` 199 → 218, and `StrongCompleteness.lean` 807 → 930 with `SetConsequence.lean`
  338 → 346. The last two drifted from concurrent sibling work on the compactness bridge, not
  from this task; they were corrected anyway rather than leaving one table half-true. The
  aggregator table immediately above was checked against `wc -l` and was already accurate. No
  invariant check enforces these numbers — C14(i) covers axiom and sorry counts only — so this is
  a documentation-truth fix, not a gate requirement.
- **Verification route, phases 1-3 (and a corrected record)**: the three scoped
  `lake-build-guard.sh` invocations issued during phases 1 and 2 were **malformed** — they passed
  `-- FormalSystem.Semantics.BLTruth` where the guard requires `-- build
  FormalSystem.Semantics.BLTruth`, since everything after `--` is forwarded to `lake` verbatim
  including the subcommand. Each exited with `error: unknown command 'FormalSystem.Semantics.…'`
  and built nothing. The phase-1 and phase-2 handoff notes, written before this was discovered,
  cite `.olean` files as evidence those scoped builds succeeded; those `.olean` files were in fact
  produced by concurrent full builds started by sibling dispatches, and the inference in those
  notes is withdrawn here.

  What the phase-level verification actually rests on is sound and was run directly:
  `lake env lean` on each new module against the built library — the identical elaboration, and
  the mechanism the research prototypes used — all at exit 0 with zero errors and zero warnings,
  plus the concatenated three-module prototype that produced the `#print axioms` block quoted
  above. The authoritative full `lake build`, with corrected arguments, is the Phase 6 gate below.
  Contributing background: the guard queue was 11-15 deep for most of the run, behind several
  concurrent full builds from sibling dispatches.

## Concurrency Observed

Three sibling lean4 dispatches were active in this repository throughout. Commits from
`task 496 phase 1` (aggregator wiring, `FormalSystem/Metalogic.lean` + `Metalogic/README.md`) and
`task 491 phase 1` landed mid-run. `FormalSystem/Metalogic/SetConsequence.lean` and
`FormalSystem/Metalogic/StrongCompleteness.lean` carried foreign uncommitted modifications for
the whole run; they were left untouched and never staged. Nothing foreign was reverted or
"fixed".

Implementation then stopped mid-phase, between the Phase 3 commit and any Phase 4/5 commit, and
was resumed in a later dispatch. All three sibling tasks completed in the interval: task 490
landed both compactness bridge theorems (editing `Metalogic/SetConsequence.lean`,
`Metalogic/StrongCompleteness.lean` and prose in `Metalogic.lean`), task 496 wired the
`Algebraic` aggregator into the build graph (a second new import line in `Metalogic.lean`), and
task 491 added `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`.
`FormalSystem/Metalogic.lean` therefore now carries all three tasks' edits — this task's
`BaseLanguageSoundness` import at line 16, task 496's `Algebraic` import at line 17, and task
490's prose. Those are legitimate sibling commits and were left in place. The resuming dispatch
audited the half-applied Phase 4/5 working-tree edits before committing any of them, finishing
what was partial (`FormalSystem/BaseLanguage/README.md`, and the stale line counts in
`FormalSystem/Metalogic/README.md`) rather than committing them as found or reverting them.

The Phase 6 gate above is consequently the **first** verification of the combined four-task
state, and it is green. Nothing in it failed, so no sibling-caused failure had to be escalated.

## Files

**New**
- `FormalSystem/Semantics/BLTruth.lean`
- `FormalSystem/Semantics/BLValidity.lean`
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean`

**Modified — registration**
- `FormalSystem/Semantics.lean`, `FormalSystem/Metalogic.lean`

**Modified — Lean docstrings**
- `FormalSystem/BaseLanguage.lean`, `FormalSystem/BaseLanguage/Formula.lean`,
  `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem/Semantics/Truth.lean`,
  `FormalSystem/Metalogic/Soundness.lean`

**Modified — markdown inventories**
- `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/README.md`, `FormalSystem/BaseLanguage/README.md`,
  `docs/development/MODULE_ORGANIZATION.md`,
  `docs/reference/API_REFERENCE.md`, `docs/project-info/known-limitations.md`,
  `docs/user-guide/architecture.md`, `docs/project-info/implementation-status.md`
