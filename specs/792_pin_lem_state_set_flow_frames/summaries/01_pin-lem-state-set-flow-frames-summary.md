# Implementation Summary: Task #792

- **Task**: 792 - Pin `lem:state-set` to the tree by discharging its remaining hypothesis
- **Status**: [COMPLETED]
- **Started**: 2026-10-14
- **Completed**: 2026-10-14
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_pin-lem-state-set-flow-frames.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`lem:state-set` was already present in the tree as mathematics but absent as a statement: `satSet`,
`plusTruthAt_iff_mem_satSet`, `plusValidOn_iff_satSet_univ` and `determined_of_orderFlow` all stood
over two hypotheses, `OrderFlow F` (which *is* `def:flow`'s order-isomorphism condition) and
`StateOccurs F` (which the paper discharges by `cor:occurrence`). This task composes them: one
discharge theorem derives (H2) from the bundling class `[F.IsRegular]`, and three `_of_isRegular`
corollaries state the lemma's three sentences over `def:flow`'s hypotheses alone, under names the
paper can cite. All five phases completed; `lake build` green over the whole project, zero `sorry`,
zero new axioms, and the two choice-free originals byte-identical.

## What Changed

- `FormalSystem/Metalogic/Independence/OrderTransfer.lean` — `StateOccurs.of_isRegular (F : TaskFrame) [F.IsRegular] : StateOccurs F`,
  proved `fun w x => PartialHistory.occurrence F w x`, in the existing (H2) section. 15 lines added,
  none changed.
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — a new trailing `section Regular` with
  the three corollaries, plus two module-docstring records. 92 lines added, none changed:
  - `plusTruthAt_iff_mem_satSet_of_isRegular` — `lem:state-set`'s first sentence (the bridge)
  - `determined_of_orderFlow_of_isRegular` — its second sentence (*Determined* is frame-valid)
  - `plusValidOn_iff_satSet_univ_of_isRegular` — its third sentence (validity iff the state set
    exhausts the carrier under every assignment)
  - a `## The two hypothesis forms` note recording that (H2) is derivable for a regular frame while
    the two-hypothesis forms are retained for `Independence/DeterminismUndefinable.lean`, which
    discharges (H2) by explicit affine witnesses and so stays choice-free
  - a `## References` forward pointer recording that `prop:nomic-tense-free` runs the same state-set
    induction over the tense-free fragment with `□` and the nomic operator sharing one clause and no
    temporal clauses, its `□` case consuming `cor:occurrence` and its nomic case
    `lem:nomic-occurrence`, with no nomic machinery in this tree to wire to
- `docs/reference/paper-definitions-of-record.md` — five pointer-only `LIVE-UNPINNED` KNOWN-ANCHORS
  rows (`def:flow`, `def:state-set`, `lem:nomic-occurrence`, `lem:state-set`,
  `prop:nomic-tense-free`), the C15 unblock the docstring citations require. Exactly 5 insertions,
  0 deletions, 0 `sha256:` lines
- `FormalSystem/Metalogic/Independence/README.md` — regenerated per-file line counts, plus two
  hand-written description cells and an extended `## Key Results` bullet naming the four new
  declarations and their axiom asymmetry
- `FormalSystem/Metalogic/README.md`, `README.md` — regenerated inventory count rows only
- `typst/generated/status.typ` — regenerated whole-tree line count (and its stamp), three times,
  once per `.lean`-touching commit

`FormalSystem/README.md` was left untouched: its `rows=loose` block did not change, so the generator
did not rewrite it.

## Decisions

- The three corollaries write their binders explicitly rather than taking a section-local `variable`
  line. The plan's Phase 3 task list called for
  `variable {F : TaskFrame} [LinearOrder F.WorldState] [F.IsRegular]` inside `section Regular`, but a
  second such line would shadow the file's ambient `F`; explicit binders make each signature
  textually identical to the one `## Lean Challenge Statements` pins, and leave the originals
  provably untouched (92 insertions, 0 deletions on the file).
- The pre-existing `check-paper-definitions.sh` drift wave was left unabsorbed. Absorbing 10 drifted
  MANIFEST anchors is a re-quote-and-re-hash exercise against a paper in another repository, outside
  this task's scope; the five rows added here are pointer-only and commit no hash.
- The single vacuous-pattern grep hit, `int_domain_universal` in
  `FormalSystem/Examples/TemporalStructures.lean`, is pre-existing and honest: the goal is literally
  `True` for a total history, so `trivial` is its proof rather than a placeholder. Nothing was
  changed there.

## Plan Deviations

- **Phase 3** altered: the `section Regular` carries no `variable` line; binders are written
  explicitly in each of the three signatures. Rationale above; resulting signatures are identical.
- **Phases 2-4** altered: each phase's `check-module-invariants.sh --no-build exits 0` criterion is
  unsatisfiable mid-sequence. The first `.lean` line-count change makes the INV generated-inventory
  group stale, and the plan assigns inventory regeneration to Phase 5 alone. Every check those
  phases name by number (C15, C34a, C34b, C9, C20, C33) passed at each phase; whole-script exit 0
  was reached in Phase 5 after `--emit-inventory`.
- **Phase 1 and Phase 5** altered: `check-paper-definitions.sh` exits 1, not 0, on a pre-existing
  drift wave of 10 recorded MANIFEST anchors (`CO`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:TMplus`,
  `app:discrete`, `def:id`, `def:strongest`, `thm:exist`, `lem:uniq`) — none of them this task's
  five, and this task changed zero `sha256` lines, so it neither caused nor can fix the drift. The
  gate was already red at dispatch time.
- **Phase 5** altered: `typst/generated/status.typ` was *not* byte-identical, contrary to the plan's
  stated hypothesis that it would be because the task adds no axiom, rule, `sorry` or version pin.
  The `typst-sync-check` pre-commit gate keys on the whole-tree line count, which any `.lean`
  addition moves, so the collision lands at the first `.lean` commit. Regenerated per the gate's own
  remedy (`typst-sync-check.sh --fix`) and staged alongside each `.lean` commit; no `--no-verify`.

## Verification

- Build: **Success** — `lake-build-guard.sh build --timeout 1800 -- build` over the whole project,
  detached with a bounded wait. Guard `STATUS: exit_status=0`, `Build completed successfully (2848
  jobs)`, zero `error:` lines, and `.olean` newer than source for all three touched modules
- Sorry count: **0** (`lean-sorry-census.sh` over all resolved source roots)
- Vacuous count: **0 attributable** (1 grep hit, pre-existing and honest — see Decisions)
- Axiom count: **14, unchanged** from the pre-task baseline
- Axiom profiles, all six confirmed with `lean_verify` against the implemented files:
  - `StateOccurs.of_isRegular` → `[propext, Classical.choice, Quot.sound]`
  - `plusTruthAt_iff_mem_satSet_of_isRegular` → `[propext, Classical.choice, Quot.sound]`
  - `determined_of_orderFlow_of_isRegular` → `[propext, Classical.choice, Quot.sound]`
  - `plusValidOn_iff_satSet_univ_of_isRegular` → `[propext, Classical.choice, Quot.sound]`
  - `plusTruthAt_iff_mem_satSet` → `[propext]` (unchanged)
  - `determined_of_orderFlow` → `[propext, Quot.sound]` (unchanged)
- Gates: `check-module-invariants.sh --no-build` exit 0 with zero `FAIL` lines;
  `--emit-inventory --check` exit 0; `typst-sync-check.sh` exit 0 (all 4 checks);
  `check-phantom-citations.sh` exit 0; `readme-lint.sh` exit 0;
  `export-lean-citations.py --check` exit 0; `verify-deploy.sh` exit 0 un-narrowed (15 checks, 0
  failures). `check-paper-definitions.sh` exit 1 on inherited drift only — see Plan Deviations
- C15 rose from 69 to 73 resolving paper-anchor citations; C34a, C34b, C9, C20, C33 all PASS
- `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` byte-identical to the pre-task
  baseline; both choice-free originals and the file's existing `variable` line byte-identical
- No new docstring line carries any of `Compositionality`, `Compositional`, `Seriality`, `Serial`,
  `Limit`, `Saturation`, `Saturated`; no new line cites a task number or a `file.lean:NNN` location
- Tests: N/A (no `Tests/BimodalTest/` axiom pin added; recorded as out of scope by the plan)
- Files verified: Yes

## Impacts

- The paper can now cite `lem:state-set` into the tree: `\leanproof{\texttt{Independence.…}}` on all
  three of its sentences, and the `% PORT:` comment under the lemma can be cleared. That is
  paper-side work in another repository, not done here.
- `def:flow`'s hypothesis set is available in the tree as `[LinearOrder F.WorldState]` with
  `OrderFlow F` and nothing further, so any later result stated over a frame satisfying Flow can
  reuse these three corollaries directly instead of re-deriving (H2).
- The nomic port inherits two recorded anchors (`lem:nomic-occurrence`, `prop:nomic-tense-free`) and
  a docstring pointer naming exactly which clause it must add to the recursion here.

## Follow-ups

- The `check-paper-definitions.sh` drift wave of 10 MANIFEST anchors is unabsorbed and will keep the
  gate red for any task that treats it as a precondition. Absorbing it is its own task.
- A `Tests/BimodalTest/` axiom pin on the four new declarations would mechanically defend the
  `Classical.choice` boundary the way the C14 heredoc pair defends `convexGlue`. The plan recorded
  this as a reasonable later addition and placed it out of scope.
- `prop:nomic-tense-free` and `lem:nomic-occurrence` remain unformalized; no nomic machinery exists
  in this tree.

## References

- `specs/792_pin_lem_state_set_flow_frames/plans/01_pin-lem-state-set-flow-frames.md`
- `specs/792_pin_lem_state_set_flow_frames/reports/01_pin-lem-state-set-flow-frames.md`
- `specs/792_pin_lem_state_set_flow_frames/issues.jsonl`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — `def:state-set`,
  `def:flow`, `lem:state-set`, `cor:occurrence`, `lem:nomic-occurrence`, `prop:nomic-tense-free`
