# Implementation Summary: Task #719

- **Task**: 719 - ray_layer_seam_gluing_and_stab_fibre
- **Status**: [COMPLETED]
- **Started**: 2026-10-03T15:00:00Z
- **Completed**: 2026-10-03T16:20:00Z
- **Effort**: ~1.3 hours wall clock across 6 phases (build wall time dominated)
- **Dependencies**: None remaining — 563 `[COMPLETED]`, 564 `[COMPLETED]`, 718 `[COMPLETED]`
- **Artifacts**: plans/01_ray-layer-seam-gluing-stab-fibre.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Promoted four already-machine-checked probe results into `FormalSystem/` as two new modules, with
the choice leak the research round located actually repaired rather than merely recorded, and
added the E1 backward-dual probe on a time-asymmetric fixture. The ray layer, the ray-layer
gluing operator and `seamFibreEquiv` land in `FormalSystem/Semantics/Presheaf/Ray.lean`; the three
`PlusTruthAt`-mentioning keystones land in `FormalSystem/PlusLanguage/PlusRayFibre.lean`, a split
forced by the Presheaf cluster's documented layering below `Semantics/Truth.lean`. Deliverable 4's
subsumption limit and Deliverable 5's requirement hand-off are recorded **in the library**, not
only in artifacts under `specs/`.

## What Changed

- `FormalSystem/Semantics/Presheaf/Ray.lean` — **new**, 438 lines. Deliverable 1: `PastRay`,
  `FutRay` (the probe's subtype-of-dependent-function presentation, verbatim), `PastRay.seam`,
  `FutRay.seam`, `pastOf`, `futOf`, the half-line `PartialHistory` bridges `PastRay.toPH` /
  `FutRay.toPH` with their reading equations, and the ray-to-`Beh` bridge `FutRay.toBeh`.
  Deliverable 2: `Ray.seamGlueFun`, `Ray.seamGlue_rel_le_lt` (delegated to the landed
  `PartialHistory.rel_across_seam`), `Ray.seamGlue_rel`, `Ray.seamGlue`, the two reading
  equations `Ray.seamGlue_states_le` / `Ray.seamGlue_states_not_le`, totality
  `Ray.seamGlue_isTotal`, the two restriction identities `Ray.pastOf_seamGlue` /
  `Ray.futOf_seamGlue`, uniqueness `Ray.seamGlue_unique`, and the `∃!` packaging
  `Ray.seamGlue_clause`. Deliverable 3 (part): `StabFibre`, `RayPair`, **`seamFibreEquiv`**.
  Deliverable 4: the mirrored verdict as a module `/-! … -/` block.
- `FormalSystem/PlusLanguage/PlusRayFibre.lean` — **new**, 306 lines. Deliverable 3 (rest):
  **`plusStab_iff_rays`**; `BwdSeq`, `FwdSeq`, `SeqPair`, `ZPathFibre`, `pathFibreEquiv`,
  `splice`, `splice_isStepPath`, `omegaSplitEquiv`, **`seamOmegaEquiv`**, and
  **`plusStab_iff_omega`**.
- `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` — **new**,
  619 lines. Experiment E1: Probe710's time-asymmetric fixture transcribed (carrier, `Step`, the
  three predecessor inverses, finite fibres, the regular `FrameOver` built by
  `FrameOver.ofReflectiveRegular` with *Saturation* from `TaskFrame.saturation_of_fib_finite`, the
  model, and the canonicity argument), then `IsBwdPath`, `AllBwdPathsMeet`, `bwd_reaches_x`,
  `bwdFromX` / `bwdFromPre` and their step lemmas, `allBwdPathsMeet_iff`, `stabPast_iff_post`,
  **`pastStab_iff_allBwdPathsMeet`**, the three-row table (`past_stab_at_post`,
  `not_past_stab_at_x`, `not_past_stab_at_pre`), `decide_past_stab` and the instance
  `decidable_past_stab`.
- `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` — the reflection reroute
  applied so probe and library stay byte-comparable, plus an axiom-record paragraph recording the
  split the footer now shows.
- `scripts/check-evidence-probes.sh` — exactly one new `WIRED` entry plus its table row.
- `scripts/check-module-invariants.sh` — the four measured keystone rows pinned into C2
  (`AXIOM_BASELINE`, `AX_SRC` in the identical order, and the count).
- `FormalSystem/Semantics/Presheaf/README.md` — the ray-layer prose, Key Definitions/Results, and
  the **Two recorded verdicts** section (Deliverables 4 and 5).
- `FormalSystem/PlusLanguage/README.md` — a section on `⊡` as a quantifier over a product of two
  path spaces, and the inventory row.
- Regenerated: `FormalSystem.lean`, `FormalSystem/Semantics/Presheaf.lean`,
  `FormalSystem/PlusLanguage.lean`, `README.md`, `FormalSystem/README.md`,
  `typst/generated/status.typ`, `scripts/lean-citation-manifest.json`.

### Theorems and definitions delivered, by deliverable

| Deliverable | Status | Where |
|---|---|---|
| 1 — the one-sided ray layer | landed in full | `Presheaf/Ray.lean` |
| 2 — the ray-layer seam-gluing operator | landed in full, **choice-free** | `Presheaf/Ray.lean`, `namespace Ray` |
| 3 — the stab-fibre characterisation | all four acceptance-named declarations landed, `[F.IsRegular]` verbatim, axiom sets pinned | `Presheaf/Ray.lean` + `PlusLanguage/PlusRayFibre.lean` |
| 4 — the effective extension theorem | closed **affirmatively with an explicit gap statement**, verdict in the library | `Presheaf/README.md` + `Presheaf/Ray.lean` |
| 5 — the decidable-check connection | requirement stated and handed over; E1 landed and wired, **POSITIVE** | `Presheaf/README.md` + the new probe |

## Decisions

- **The two-module split is forced, not chosen.** `plusStab_iff_rays` and `plusStab_iff_omega`
  mention `PlusTruthAt`, so their module must import `PlusLanguage/PlusTruth.lean`, which imports
  `Semantics/Truth.lean`. The Presheaf cluster is locked strictly below that by
  `assert_not_exists` on all of its modules. Acceptance's "under the categorical-structure topic"
  is read as the task's `state.json` topic, which both modules satisfy, not as a directory. Both
  of the Presheaf README's load-bearing prose claims were re-read after the split and both are
  still true verbatim: the layering claim (amended "all three" → "all four modules", with all
  four verified to carry `assert_not_exists`), and "no `Classical.choice` on any declaration in
  the cluster" — verified by measuring **all 25** of `Ray.lean`'s declarations, every one
  `[propext]` or `[propext, Quot.sound]`.
- **The reflection reroute was mandatory and it worked.** The dispatch's "choice-free as probed"
  claim was false as the probe stood. Replacing the unguarded `F.reflection` with the off-zero
  `F.reflection_of_ne` plus a `≠ 0` side condition in `seamGlue_rel`'s mixed-orientation case —
  that case being strict — clears `Classical.choice` from the whole ray-layer path. Without it the
  claim the task is required to record would have been false.
- **The choice record splits, and the split is recorded as the honest form.** The ray layer is
  choice-free; the ℤ/ω presentation is not. `pathFibreEquiv` is the **sole** entry point, measured
  individually: `omegaSplitEquiv` and `splice_isStepPath` are both clean, and the cause is the
  landed `FrameOver.worldHistoryOfStepPath`. Rerouting that is out of scope (a core
  `Semantics/IntNormalForm.lean` declaration with consumers on several fronts).
- **An `[F.IsRegular]` asymmetry with the cluster's other clauses is stated rather than hidden.**
  *Germs* and *Sheaf* take *Compositionality* as an explicit hypothesis; the keystone carries the
  bundle because acceptance requires the probe's statements hypothesis for hypothesis. The
  binder-free form of what it actually uses is `PartialHistory.rel_across_seam`'s own signature,
  which the seam step delegates to. Recorded in `Presheaf/README.md`.
- **E1's result is POSITIVE and state-dependent, and its limit is recorded in its own header.**
  The backward operator at a seam state is exactly "every backward root path from that state meets
  the `p`-set", decided True at the `post` states and False at the `x` and `pre` states — strictly
  more informative than the forward probe's uniformly-False `Probe718FiniteGraph.decide_will`. The
  honest limit, in the probe's words: Probe710's fixture is backward *deterministic*, so its
  backward factor is a singleton and E1 tests the dual at its easiest instance; the genuinely hard
  test is a mirror fixture (backward-branching, forward-deterministic), filed as a follow-up. The
  `reflectTime` trap was not used, and why is recorded.
- **Nothing was built or selected for the substrate.** Deliverable 5 states a requirement — a
  summary device universal over both factors, hence complementation-shaped, whose backward factor
  is summarised on its own terms — and asserts nothing about which candidate supplies it. No
  automata, no determinization, no universal-summary device under any name; no width, tail-period
  or complexity bound.

## Plan Deviations

Three deviations, all naming- or tactic-level, none touching a statement. Each is annotated inline
on the corresponding plan checklist item.

- **Phase 2 altered — the `Presheaf.Ray` sub-namespace is not sufficient separation.** Gate `C23`
  forbids outer-shadows-inner *base*-name pairs regardless of namespace, and fired on all four of
  `glue`, `glue_states_le`, `glue_states_not_le`, `glue_unique` against 564's `Sheaf.lean` (the
  dead-declaration census keys on the last dot-segment, so two declarations sharing a base name
  mask each other). The operator family is landed as `Ray.seamGlue`, `Ray.seamGlue_states_le`,
  `Ray.seamGlue_states_not_le`, `Ray.seamGlue_unique`, with `seamGlueFun`, `seamGlue_rel`,
  `seamGlue_rel_le_lt`, `seamGlue_isTotal`, `pastOf_seamGlue`, `futOf_seamGlue` and
  `seamGlue_clause` renamed consistently. None is an acceptance-named declaration, and the plan's
  own acceptance clause requires the gate green, so the gate is the binding constraint. The
  rationale is recorded in the module docstring so the next reader does not re-litigate it.
- **Phases 2 and 3 altered — gate `C28` rejects the `show` tactic** (`linter.style.show`, whose
  budget entry reads "use `change` where the goal changes"). Every transcribed tactic-position
  `show` is landed as `change`, which is the convention `Sheaf.lean` already follows. Term-level
  `rw [show … from …]` is unaffected and kept verbatim. One `change` the unused-tactic linter
  reported as a no-op was dropped.
- **Phase 3 altered — `ring` is unavailable in `PlusRayFibre.lean`'s import closure**, the same
  constraint `Sheaf.lean` documents for the Presheaf cluster. The probe's four
  `by push_cast; ring` side goals are discharged by `by push_cast; omega`. The statements are
  unchanged.
- **Phase 5 altered — the two negative rows of E1's decision table are proved from named backward
  chains** (`bwdFromX`, `bwdFromPre`, with step lemmas) rather than from inline `if`-expressions.
  Inline lambdas left the step goals beta-unreduced and `rw`-resistant; the named chains make each
  step proof a bare constructor application. Same content, three extra declarations. Relatedly,
  `stabPast_iff_post` and its corollaries are proved in term mode rather than by `rw`, because the
  frame's `WorldState` is `Node` only definitionally and `rw` fails on that at `implicit`
  transparency.
- **Phase 6 altered — the three path-category paper anchors are described but deliberately not
  named.** The plan instructed citing `def:path-category`, `def:conduche` and `cor:path-fibration`
  as DANGLING rows. They are not DANGLING rows: `docs/reference/paper-definitions-of-record.md`
  records them among nine appendix anchors **deliberately not pinned**, with "if any of them
  becomes load-bearing, add it then" as the documented procedure. Citing them from a README
  therefore failed `C15` with "3 paper-anchor citation(s) resolve to nothing", and the only ways
  to satisfy it were to widen that record for a region the tree does not depend on — exactly what
  its own decision exists to prevent — or not to name them. The verdict now describes the
  free-category reading of `Path(F)`, states that no such presentation exists anywhere under
  `FormalSystem/`, states that it must never be cited as landed, and says in so many words that
  the paper's labels for it are deliberately not named because naming them is what would make them
  load-bearing. The content the plan wanted recorded is recorded; only the three label strings are
  absent.

- **Phase 4 scope-hypothesis overrun, recorded as the plan asks.** The plan estimated ~350 lines
  for the fixture; the probe file is 619 lines in total, the excess being the substantive header
  (scope, result, limit, the `reflectTime` trap, citation hygiene, axiom record) and the Phase 5
  summary rather than the fixture transcription itself.

## Verification

- **Build**: Success. Final full-project `lake build` through the guard: guard exit 0,
  "Build completed successfully (2814 jobs)", zero `error:` across both captured streams, and
  both new modules' `.olean` newer than their sources. Every phase also ended at a green guarded `lake build FormalSystem`
  (Phase 1: 2813 jobs; Phase 2: 2813 jobs; Phase 3: 2814 jobs), each read from the guard's own
  exit status plus the success line plus an `.olean`-newer-than-source check on every module
  touched, with zero `error:` in either captured stream.
- **Sorry count**: 0. `grep -rn 'sorry'` returns nothing in either new library module or the new
  probe; the structural sorry inventory check (`C3`) is green.
- **Vacuous count**: 0. No `def X := True`/`Unit`/`trivial` pattern anywhere in the diff.
- **Axiom count**: unchanged. No `axiom` declaration was added. C2's pinned set grew from thirty
  to thirty-four by **pinning measured rows for new declarations**, which is the sanctioned way to
  extend it, and `C21` still passes (all 33 `MainResults.lean` declarations pinned by C2 or C14).
- **Tests**: Passed. `lake build BimodalTest` through the guard: exit 0,
  "Build completed successfully (2875 jobs)", zero `error:`.
- **Files verified**: Yes.

### Measured axiom sets, recorded verbatim

The four acceptance-named keystones, as pinned into C2:

```
'FormalSystem.Semantics.Presheaf.seamFibreEquiv' depends on axioms: [propext, Quot.sound]
'FormalSystem.PlusLanguage.plusStab_iff_rays' depends on axioms: [propext, Quot.sound]
'FormalSystem.PlusLanguage.seamOmegaEquiv' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.PlusLanguage.plusStab_iff_omega' depends on axioms: [propext, Classical.choice, Quot.sound]
```

All 25 declarations of `Presheaf/Ray.lean`, measured individually:

```
'PastRay' / 'FutRay' / 'PastRay.seam' / 'FutRay.seam' / 'pastOf' / 'futOf'
'PastRay.toPH' / 'FutRay.toPH' / 'FutRay.toBeh' / 'Ray.seamGlueFun'
'StabFibre' / 'RayPair'                                         → [propext]
'Ray.seamGlue_rel_le_lt' / 'Ray.seamGlue_rel' / 'Ray.seamGlue'
'Ray.seamGlue_states_le' / 'Ray.seamGlue_states_not_le'
'Ray.seamGlue_isTotal' / 'Ray.pastOf_seamGlue' / 'Ray.futOf_seamGlue'
'Ray.seamGlue_unique' / 'Ray.seamGlue_clause' / 'seamFibreEquiv'  → [propext, Quot.sound]
```

The supporting ω declarations, which localize the choice to one declaration:

```
'FormalSystem.PlusLanguage.BwdSeq' / 'FwdSeq' / 'SeqPair' / 'ZPathFibre' / 'splice' → [propext]
'FormalSystem.PlusLanguage.splice_isStepPath' → [propext, Quot.sound]
'FormalSystem.PlusLanguage.omegaSplitEquiv'   → [propext, Quot.sound]
'FormalSystem.PlusLanguage.pathFibreEquiv'    → [propext, Classical.choice, Quot.sound]
```

The E1 probe:

```
'Probe719Backward.allBwdPathsMeet_iff'            → [propext, Quot.sound]
'Probe719Backward.stabPast_iff_post'              → [propext, Classical.choice, Quot.sound]
'Probe719Backward.pastStab_iff_allBwdPathsMeet'   → [propext, Classical.choice, Quot.sound]
'Probe719Backward.decide_past_stab'               → [propext, Classical.choice, Quot.sound]
```

The backward-reachability argument itself is choice-free; the three carrying `Classical.choice` do
so through `hist_canon` → `FrameOver.mem_HF_iff_adjacent` → `FrameOver.worldHistoryOfStepPath`,
the same upstream declaration as the keystone's ω half, and the same one Probe710 carries it for.

The reroute's effect on the probe, before and after, measured both times:

```
before: 'Probe718.seamFibreEquiv'    [propext, Classical.choice, Quot.sound]
after:  'Probe718.seamFibreEquiv'    [propext, Quot.sound]
before: 'Probe718.plusStab_iff_rays' [propext, Classical.choice, Quot.sound]
after:  'Probe718.plusStab_iff_rays' [propext, Quot.sound]
```

### The measured pre-edit baseline, recorded so the task is not judged red for it

Taken before the first edit, and **not** fixed by this task — both are another task's territory:

| Gate | Pre-edit baseline | After this task |
|---|---|---|
| `lake build FormalSystem` | exit 0, 2812 jobs | exit 0, 2814 jobs |
| `check-module-invariants.sh --no-build` | exit **1**: `FAIL C15 1 of 240 theorem-index row(s) are not anchored at their declaration` | exit 1, the **same single** failure |
| `check-paper-definitions.sh` | exit **1**: the `def:BX` drift | exit 1, same drift, no new drift |

### Gate results

| Gate | Result |
|---|---|
| `check-module-invariants.sh` (full, **with** build) | exit 1, **only** the pre-existing C15 row. `C2 PASS` — "all thirty-four pinned axiom sets match baseline". `C21 PASS`, `C33 PASS` byte-exact (648 imports), `C35 PASS` (86 seeded declarations), `C23 PASS`, `C28 PASS`, `C34a`/`C34b PASS`, `INV` green |
| `check-evidence-probes.sh` | exit 0 — **all 15** wired probes compile, including the new entry; every pre-existing entry still reproduces and no outside citation is broken |
| `check-copyright-headers.sh --strict FormalSystem` | exit 0 |
| `readme-lint.sh FormalSystem` | exit 0 |
| `check-module-invariants.sh --emit-inventory --check` | exit 0 — no byte would change |
| `typst-sync-check.sh --fix` | PASS — status.typ, module map and machine appendix all in sync |
| grep self-check | no `file.lean:NNN` citation and no task number in any text this task wrote under `FormalSystem/`; every `decide_will` mention qualified apart from the one sentence whose subject is the ambiguity itself |

## Impacts

- The keystone is now library API rather than an out-of-build-graph probe: `seamFibreEquiv`,
  `plusStab_iff_rays`, `seamOmegaEquiv` and `plusStab_iff_omega` are importable, and their axiom
  sets are pinned, so a future change that silently reintroduced `Classical.choice` into the ray
  layer would be a **hard stop** at C2 rather than an unnoticed regression.
- The ray layer gives the directed/colimit task (565) and the limit-presentation task (566) a
  landed half-line vocabulary to build on, and `FutRay.toBeh` is the bridge to the bounded
  sections 563 landed.
- 564's `PartialHistory.rel_across_seam` now has its third consumer, which is the
  de-duplication that lemma was created for.
- The substrate record (711) has a stated requirement to consume: universal over both factors,
  complementation-shaped, with its backward factor summarised on its own terms. It stays
  `[BLOCKED]` on device selection; nothing here funds, builds or selects a device.
- `Presheaf/README.md`'s cluster-wide choice-freedom claim is now backed by a per-declaration
  measurement rather than a spot check.

## Follow-ups

- **The mirror fixture.** E1's backward factor is a singleton because Probe710's fixture is
  backward-deterministic. The genuinely hard dual test is a backward-branching,
  forward-deterministic fixture. Recorded in the probe header and deliberately not absorbed here.
- **`FrameOver.worldHistoryOfStepPath`'s choice reroute.** It is the single cause of every
  `Classical.choice` in the ω half and in the E1 probe. Out of scope here (core
  `Semantics/IntNormalForm.lean`, consumers on several fronts), but it is now a precisely located
  one-declaration target rather than a diffuse concern.
- **Two pre-existing gate failures, both another task's territory**: the unanchored C15
  `theorem-index.md` row, and `check-paper-definitions.sh`'s `def:BX` drift.
- **A paper-side note for the author, not this task's to write**: the paper's own `⌢_z` passage is
  commented out in `JPL/possible_worlds.tex` while the ray-layer operator it defines is now
  formalized here; `app:gluing`'s binary seam case is likewise formalized while the general
  directed case remains open. Restoration in the paper is an author decision.
- **`Sheaf.lean`'s inventory description is still `<!-- TODO: add description -->`**, pre-existing
  and untouched.

## References

- `specs/719_ray_layer_seam_gluing_and_stab_fibre/plans/01_ray-layer-seam-gluing-stab-fibre.md` —
  the plan executed
- `specs/719_ray_layer_seam_gluing_and_stab_fibre/reports/01_ray-layer-seam-gluing-stab-fibre.md` —
  the compiled research report whose probes P2, P3 and P4 this task landed
- `specs/719_ray_layer_seam_gluing_and_stab_fibre/.dispatch/3.md` — the dispatch context
- `specs/719_ray_layer_seam_gluing_and_stab_fibre/handoffs/` — the four per-phase handoffs
- `specs/evidence/seam-gluing-ray-product/` — the probe collection, now six files
- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` §1, and
  `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` §E — the two scope
  revisions this task carries
