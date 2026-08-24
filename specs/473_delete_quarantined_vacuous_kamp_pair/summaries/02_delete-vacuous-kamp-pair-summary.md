# Implementation Summary: Task #473

- **Task**: 473 - Delete the quarantined vacuous Kamp Prop 4.2 pair
- **Plan**: specs/473_delete_quarantined_vacuous_kamp_pair/plans/02_delete-vacuous-kamp-pair.md
- **Research**: specs/473_delete_quarantined_vacuous_kamp_pair/reports/01_delete-quarantined-vacuous-kamp-pair.md
- **Status**: All 4 phases COMPLETED
- **Type**: lean4

## What Was Done

Deleted two quarantined, sorry-free but vacuous theorems and swept every prose site that
presented them as landed Rabinovich Prop 4.2 deliverables. Nothing was proved, no sorry was
closed, no axiom was introduced, and no attempt was made to repair the pair into a contentful
form.

### Phase 1 — Re-verify by symbol, then delete (COMPLETED)

Re-verified the zero-consumer claim independently before editing, by word-boundary grep over
all non-Boneyard `.lean` under `FormalSystem/` and `Tests/`:

| Symbol | Code consumers | Result |
|---|---|---|
| `neg_2var_vec_ea` | 1 (the body of `reflatten_neg_step`) | deletable once its consumer went |
| `reflatten_neg_step` | 0 | deletable |

The STOP condition was not triggered. Baseline `lake build` was confirmed green (exit 0, 2458
jobs) before any edit. Both blocks were located by their opening docstring text, not by line
number, and the boundaries were confirmed against the live files before cutting.

Deleted:
- `reflatten_neg_step` (docstring + declaration + trailing blank) in `NavigatedSpine.lean` — 32 lines
- `neg_2var_vec_ea` (docstring + declaration + trailing blank) in `EANegationClosure.lean` — 41 lines

Result: 73 deletions, **zero insertions**, two files, no `import` line touched. The orphaned
`neg_disjunct_list` / `neg_vecEA2` chain was deliberately left in place (explicit non-goal).

### Phase 2 — Sweep prose in the five consumer files (COMPLETED)

Ten sites rewritten or removed, all confined to comments and docstrings:

- `EANegationClosure.lean` — deleted the module-header bullet and the `## Key Theorems` bullet;
  re-worded the surrounding paragraph so it no longer implies a live model-dependent counterpart
  to `neg_2var_vec_ea_indep`.
- `NavigatedSpine.lean` — source-mapping entry now records the Prop 4.2 negation step as NOT
  discharged; deleted the "Consumed-asset signatures confirmed present" bullet; rewrote the
  "already had the two hardest halves landed" claim to name only what is genuinely landed
  (`VVecEA2.disj_holds`, `VVecEA2.conj_holds_vvecEA2`) and state that the negation half is open;
  rewrote `reflatten_prop43`'s docstring to say it covers the `∨`-collapse only.
- `NfMultiAnchorBridge.lean` — put the re-export clause into the past tense (the NOTE's purpose,
  making the guard root-reachable, survives in substance); dropped `/Prop 4.2` from the
  EANegationClosure import NOTE's asset list. The import itself was NOT removed — the edge still
  transitively supplies `PriorINF`.
- `AggregateHookDischarge.lean` — kept the aggregation verdict and its reasoning; replaced the
  named declaration with a pointer to `Prop42Vacuity`.
- `SubBracket2V.lean` — the Lemma 3.2(2) cross-reference row now points at `Prop42Contentful` as
  the *unbuilt* target. The Lemma 3.4 / `VVecEA2.conjStruct` row was left alone.

### Phase 3 — Update the vacuity record files (COMPLETED)

Both record files were KEPT; only cross-references naming the deleted declarations changed. No
theorem statement, no proof, and no `import` line was altered in either file.

- `Prop42Vacuity.lean` — the file now introduces itself as the record of a *deleted* declaration.
  The central edit replaced the section `## Live declarations still presenting the vacuous shape`
  ("deliberately not deleted — they are consumed live"), which had become outright false, with
  `## Declarations deleted for presenting the vacuous shape`, recording that both were removed
  because they were quarantined, naming them by symbol only. Frozen regions preserved: the
  refutation mathematics, the anti-pattern guard paragraph ("does not claim ... broken, unproved,
  or unsound" — tense-adjusted only, not weakened), the root-reachability sentence, and
  `prop42_conclusion_is_vacuous`'s statement and proof.
- `Prop42Contentful.lean` — dropped the rotted anchor and tense-adjusted to "the shape the deleted
  `neg_2var_vec_ea` had"; dropped the dangling parenthetical at the `private` re-proof
  justification, whose import-weight reasoning still stands. The two-bullet vacuity taxonomy, the
  constructive core, is preserved exactly.

Anchor policy honored throughout: every `file.lean:NNN` anchor pointing at the deleted pair was
replaced with a symbol-name reference. **No new line numbers were computed anywhere**, including
for the secondary rotted `Boneyard/` anchors, which were converted to symbol/file references.

### Phase 4 — Final verification gate (COMPLETED)

| Gate | Result |
|---|---|
| `lake build` | exit 0 (2462 jobs) |
| `lake build BimodalTest` | exit 0 (2512 jobs) |
| `scripts/check-module-invariants.sh` | exit 0, **ALL CHECKS PASSED** |
| C2 (four flagship axiom sets) | **PASS** — match baseline, no movement |
| C3 (sole structural sorry) | **PASS** — `countermodel_discrete` in `WeakCanonical/Transfer.lean` |
| C9 (task-number citations under `FormalSystem/`) | **PASS** — zero |
| New `sorry` / new axiom | zero (the change is deletion plus prose) |
| File-scope containment | exactly the seven declared paths |

The C2/C3 hard stop was never reached: neither check moved, confirming nothing deleted was
load-bearing.

Residual symbol grep over non-Boneyard `.lean`: 13 hits, all inside comment/docstring regions,
all historical — `Prop42Vacuity.lean` (10), `NfMultiAnchorBridge.lean` (2),
`Prop42Contentful.lean` (1). **Zero code references remain**; the two declarations and the single
call site are gone.

## Build Environment Note

Several other agents were editing `FormalSystem/` and running `lake build` concurrently against
this same working tree during the dispatch. Two intermediate builds failed with race artifacts
(`GoodStructuresModelSurgery` / `EpsilonDense`, then a missing
`Verified/Termination/Fuel.olean`) that were traced to concurrent activity, not to this change —
both modules built successfully in the completed log, and the final full-tree gate build is green.
Every gate result reported above comes from a build that was actually run.

## Plan Deviations

- **Phase 2, `NfMultiAnchorBridge.lean` (~`:102-103`)** *(altered)*: this site retains both symbol
  names as explicit historical referents ("the now-deleted `neg_2var_vec_ea` /
  `NavigatedSpine.reflatten_neg_step` pair"), following the phase's own task list and the research
  report's suggested shape. The phase's separate "returns ZERO hits in these five files" grep
  bullet is therefore satisfied in substance — no surviving mention presents either symbol as a
  landed asset — rather than as a literal zero-hit count. The two bullets contradicted each other;
  the task-list wording was treated as authoritative because it keeps the import-edge NOTE
  comprehensible.

No other deviations. All other phase items were executed as written.

## Files Changed

| File | Change |
|---|---|
| `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` | `neg_2var_vec_ea` deleted; 2 prose sites |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedSpine.lean` | `reflatten_neg_step` deleted; 4 prose sites |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` | 2 import-NOTE sites |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean` | 1 site |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SubBracket2V.lean` | 1 site |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Vacuity.lean` | 7 sites incl. the deletion-record section |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean` | 2 cross-reference sites |

## Follow-Up (out of scope here, reported only)

Deleting `neg_2var_vec_ea` orphans a ~110-line private chain inside `EANegationClosure.lean`:
`neg_disjunct_list` (whose only consumer was `neg_2var_vec_ea`) and `neg_vecEA2` (whose only
consumer is `neg_disjunct_list`). This is build-safe — Lean 4 has no default unused-declaration
linter — and was left in place per the plan's explicit non-goal. Removing it is a separate
scoping decision with its own build surface.
