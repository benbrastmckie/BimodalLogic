# Implementation Summary: Task #658

- **Task**: 658 - Consolidate the state-space topology into a library-grade, citable collection for the manuscript appendix
- **Status**: [COMPLETED]
- **Started**: 2026-09-23T00:09:00Z
- **Completed**: 2026-09-23T01:55:00Z
- **Effort**: ~1.8 hours
- **Dependencies**: None blocking. Ran with no sibling task concurrent — `specs/state.json` showed this task as the only one `implementing`.
- **Artifacts**: plans/01_state-topology-collection-appendix.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The state-topology collection is now citable from outside the repository. The two-origin frame's
cone-topology side and the hedgehog's topology inequality were promoted from research probes into
the library; the four frame-level and formulation-bridge declarations the revised appendix needs
were added; `docs/theorem-index.md` was raised from five topology rows to forty-two; and the
headline deliverable — a durable appendix support table keyed by paper label and quotable phrase,
naming every statement the library does **not** certify — now lives at
`docs/reference/state-topology-appendix-support.md`.

Twenty new library declarations, all sorry-free with axiom profile
`[propext, Classical.choice, Quot.sound]`. Nothing in the manuscript was edited; that is the
user's own work, and this task's job was to make the collection it draws on complete and
lookup-able.

## What Changed

### `FormalSystem/Semantics/StateTopology.lean`

Six new declarations:

- `TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial` — `app:topology-t1` exactly as the
  revised appendix states it: the paper's **equality** form of *Limit* iff T1, under *Seriality*
  alone. Its docstring records that `t1Space_nbhdTopology_iff_limit` is sharper (it consumes no
  constraint at all), so the appendix can take the stronger theorem if it wants it.
- `TaskFrame.t1Space_iff_closure_singleton`, `TaskFrame.r0Space_iff_mem_closure_comm` — the two
  formulation bridges. The paper states *T1* and *R0* with closures (`cl{w} = {w}`,
  `w ∈ cl{u} ↔ u ∈ cl{w}`) while this development states them with Mathlib's `T1Space` and
  `R0Space`; these make the identification a checked fact rather than a reader's assumption, and
  they close the last of the research report's five uncertified items.
- `FrameOver.isOpen_iff` — the replacement `def:task-topology`'s one-clause Open Sets definition
  at the frame level.
- `FrameOver.r0Space_stateTopology` — `app:topology-r0` under the revised topology, **named**.
  This was the sharpest citability gap in the collection: R0 at a frame was certified only by an
  anonymous `example`, which no citation can reach.
- `FrameOver.iInter_cone_eq_singleton` — the paper's equality form of *Limit* at a regular frame.

The anonymous `example (F : FrameOver D) [F.IsRegular] : R0Space F.WorldState := inferInstance`
was removed and `instT1SpaceOfRegular`'s docstring re-pointed at the named theorem, so exactly one
live certification of that fact remains.

Module header gained three sections: the symbol correspondence (the revised `def:task-topology`
**reassigns** `𝒯_F` to the neighbourhood topology, which is Lean's `nbhdTopology` /
`FrameOver.stateTopology`; the footnote's superseded subbasis topology is `coneTopology` /
`FrameOver.coneTop`), Mathlib's `TopologicalSpace` order convention with
`coneTopology_le_nbhdTopology` as the worked example, and the deliberate namespace asymmetry in
the counterexample module. Both topology `def` docstrings mirror the correspondence.

### `FormalSystem/Semantics/StateTopology/Counterexamples.lean`

Fourteen new declarations.

`TwoOrigins` (ten) — `not_triangle`, the four cone-membership lemmas, `isOpen_nbhdTopology_cone`
with its explicit radii `min t (x - t)`, `x - |s - t|` and `x - t`, `coneTopology_eq_nbhdTopology`,
`not_t2Space_coneTopology`, and the two frame-level wrappers
`frame_coneTop_eq_stateTopology` / `frame_not_t2Space_coneTop`. Together these let the appendix
say the sentence it most needs: **non-Hausdorffness is a property of the frame, not an artefact of
which topology is chosen** — the two topologies coincide there and neither separates the origins.
`not_triangle` additionally makes this the library's only witness that *Triangle* is sufficient
but **not necessary** for cone-openness.

`Hedgehog` (four) — `p_mem_cone_c`, `not_isOpen_nbhdTopology_singleton_c`,
`coneTopology_ne_nbhdTopology` (the named inequality the task asked for) and
`coneTopology_lt_nbhdTopology` (the sharper strict-fineness form).

A recorded length ceiling `set_option linter.style.longFile 1700` was added with a justification
comment: the module crossed the package's 1500-line default, and research had already weighed and
rejected splitting it.

### `Tests/BimodalTest/Semantics/StateTopologyTest.lean` — created

The collection's two modules are deliberate leaves with **no in-tree consumer**, so a rename or a
weakened statement would silently break an out-of-tree citation. This module is that missing
consumer: seven theorems that use the headline declarations at their real statements, plus nine
`#guard_msgs`-gated `#print axioms` blocks that are build-breaking if a profile moves. Wired into
`Tests/BimodalTest.lean` and `Tests/BimodalTest/Semantics/README.md`; imported by nothing else.

### `docs/theorem-index.md`

Two rows added to the `## Notation and naming` table recording the `𝒯_F` symbol reassignment in
both directions, and **thirty-seven** ledger rows added — the topology section went from five
rows covering 1,849 lines to forty-two. Eleven pre-existing declarations gained `Paper:` lines so
their new rows satisfy C15's round trip. A cross-link to the support table heads the section.

### `docs/reference/state-topology-appendix-support.md` — created (the headline artifact)

Six sections, keyed by paper label or quotable phrase and **never** by line number: the
replacement `def:task-topology`; `app:topology-t1` as a biconditional; `app:topology-r0`; the new
history-continuity lemma; the footnote's superseded topology with the four-state funnel; and ten
further results the collection now makes worth stating. Every row carries its certifying
declaration and axiom profile. A closing section names the five statements the library does not
certify, of which two are `pending-sibling`, two are over-claims the library actively refutes, and
one is now closed by the formulation bridges — plus two "not defects" notes.

### Front-door surfaces

- `FormalSystem/README.md` — a `### The State Topology` section with a five-row highlights table
- `docs/ARCHITECTURE.md` — `## The state topology is a leaf, on purpose`, recording both prior
  `Preorder ℤ` diamonds as the reason
- `docs/reference/API_REFERENCE.md` — a `### State Topology` entry-point table
- `docs/reference/README.md` — the support table's index row
- `FormalSystem/Semantics/README.md` — both existing rows extended to cover the promotions
- `README.md` — regenerated inventory block (`--emit-inventory`)

## Decisions

- **Every `Paper:` line was made exactly `Paper: <anchor>` or `Paper: — (reason)`.** C15's second
  assertion compares the docstring value against the row label **byte for byte**; a trailing
  parenthetical after the anchor, or a value wrapped onto a second line, fails. Nine docstrings
  were rewritten to move the gloss into the body.
- **The notation rows went into the ledger's existing `## Notation and naming` table**, not into
  the six-column theorem table. The theorem table's schema requires a declaration name and a C15
  round trip; a symbol mapping is not a theorem.
- **The `Counterexamples.lean` length ceiling was raised rather than the module split.** Research
  weighed and rejected the split; splitting would cost three aggregator entries, three README rows
  and three import edges in a tree that keeps this collection out of `Semantics.lean` on purpose.
  The ceiling carries a justification comment saying to keep it tight.
- **The test module lives under `Tests/`, not under `FormalSystem/`.** It imports
  `StateTopology.Counterexamples`, which would otherwise widen the library's import surface; the
  test library is not reachable from the published library, so the import-weight lever is intact.

## Plan Deviations

- **Phase 4** altered: the anonymous R0 `example` was **removed outright** rather than demoted to
  a comment. Demoting it would have left a second, unchecked certification of the same fact;
  `instT1SpaceOfRegular`'s docstring now points at `r0Space_stateTopology` instead.
- **Phase 7** altered: the `docs/reference/API_REFERENCE.md` table runs to eight rows rather than
  the plan's "at most five". It is an API entry-point list (definitions, instances, the module
  boundary), not a results highlights table, and it states no theorem the ledger also states, so
  the ledger's single-authority rule is not weakened.
- **Phase 6** widened: the plan anticipated "roughly twenty" ledger rows; thirty-seven were added,
  because eleven general-layer declarations the support table cites (the `*_int*` results, the two
  real-frame bridges, the funnel's cone computation, the two formulation bridges) had no row
  either. The plan's own instruction was to target coverage rather than a count.
- **Phase 6** additionally required eleven `Paper:` lines on **pre-existing** declarations, which
  the plan scoped only to the new ones. Without them the new rows could not satisfy C15.

## Verification

- Build: **Success**. `lake build --wfail` — 2,722 jobs, exit 0, zero errors, zero warnings.
  `lake build BimodalTest --wfail` — 2,782 jobs, exit 0, zero errors, zero warnings (the test
  library is not in `defaultTargets`, so it needs its own invocation; the acceptance criterion
  names both).
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots: `sorry_count: 0`,
  empty inventory).
- Vacuous count: **1**, pre-existing and unchanged from the baseline commit — the single match is
  `Examples/TemporalStructures.lean`'s `int_domain_universal`, in an untouched file, where
  `intTimeHistory.domain t` genuinely reduces to `True`. No vacuous definition was introduced.
- Axiom count: **14**, identical to the baseline commit. No new `axiom` declaration.
- Axiom profiles: every one of the twenty new declarations reports exactly
  `[propext, Classical.choice, Quot.sound]`, read off a `#print axioms` run against the built
  modules rather than assumed. Nine of them are additionally pinned by `#guard_msgs` in the test
  module, so a drift is build-breaking.
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED** (C15's anchor resolution and
  its theorem-index round trip over all 156 rows, C5/C12/C13/C32 link resolution, C8 aggregators,
  C28's zero warning budget, C33 root byte-currency, C9/C9D task-number scans).
- `lake exe mk_all --lib FormalSystem --check` — exit **0**; `FormalSystem.lean` needed no change.
- C19 docstring coverage: 94.02% refined (floor 90%), up from 94.01% at baseline.
- Import-weight lever: `Counterexamples.lean` is still the only importer of `StateTopology.lean`
  under `FormalSystem/`, and `FormalSystem/Semantics.lean` imports neither. The new test module
  is under `Tests/`, outside the published library.
- Every Lean name cited in the support table (58 distinct) resolves in the tree, checked by grep
  rather than assumed.
- Tests: Passed (the test library builds green; its `#guard_msgs` blocks are the assertions).
- Files verified: Yes.

## Impacts

- The manuscript's task-semantics appendix can now cite a named, compiled, standard-axioms
  declaration for every element of its topology material, and knows exactly which five statements
  it must hedge.
- `FrameOver.r0Space_stateTopology`, `FrameOver.isOpen_iff` and
  `t1Space_nbhdTopology_iff_iInter_cone_of_serial` give the frame-level register the appendix
  writes in, so no citation lands on an anonymous `example` or a reader-assembled argument.
- The collection acquired its first in-tree consumer, so its declarations are no longer invisible
  to a refactor.
- Thirty-seven new ledger rows raise `docs/theorem-index.md` from 119 to 156 rows; as a side
  effect the promotions are absent from C17's dead-declaration census, whose occurrence corpus
  includes non-`specs/` markdown.

## Follow-ups

- **Sibling open-questions task** (out of scope here, by construction): *Saturation* for the
  two-origin and hedgehog witnesses, which is what would let the manuscript call either a **task
  frame** rather than "a structure satisfying three of the four constraints"; and R0 without
  *Limit*. Both are recorded `pending-sibling` in the support table with the dependency named.
- The support table flags two over-claims the manuscript should not make as written: "**the**
  topology that makes worlds continuous paths" (the hedgehog refutes the definite article) and
  "T1 is inherited by finer topologies" as the *reason* the old topology is T1 (the instance is
  certified; the inheritance principle is not stated in this library). Either add the general
  lemma or drop the reason.
- The manuscript's formalization claim ("the frame correspondence, determinism, and soundness
  results of the appendices are formalized in the Lean 4 repository") predates this round and
  could now enumerate the topology results too. Manuscript-side; not this task's to edit.

## References

- `specs/658_consolidate_state_topology_collection_for_appendix/plans/01_state-topology-collection-appendix.md`
- `specs/658_consolidate_state_topology_collection_for_appendix/reports/01_state-topology-collection-appendix.md`
- `specs/658_consolidate_state_topology_collection_for_appendix/SEED.md`
- `specs/658_consolidate_state_topology_collection_for_appendix/probes/` — the three transplant sources
- `docs/reference/state-topology-appendix-support.md` — the headline deliverable
- `docs/theorem-index.md` — the per-theorem ledger
