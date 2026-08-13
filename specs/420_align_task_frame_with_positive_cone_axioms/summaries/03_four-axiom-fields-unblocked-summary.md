# Implementation Summary: Task #420 (plan v3, Phases 10-13 + 14.0)

- **Task**: 420 - align_task_frame_with_positive_cone_axioms
- **Plan**: `plans/03_four-axiom-fields-unblocked.md`
- **Session**: sess_1786581174_a99518
- **Date**: 2026-08-12
- **Outcome**: Phases 10, 11, 12, 13 **[COMPLETED]** and Phase 14's prerequisite sub-step 14.0
  landed; Phase 14's atomic batch **not opened** (sizing finding, below); Phase 15 not reached.
- **Build**: `lake build` green, exit 0, 2331 jobs, at every one of the 10 commits.

## What landed

Every live `TaskFrame` construction in the library — all 14 of them — now has the four
`def:frame` axioms proved as standalone, sorry-free lemmas, stated **syntactically** as
`TaskFrame.Serial` / `TaskFrame.Interpolates` / `TaskFrame.Spherical` or as *Limit*'s literal
transcribed shape. That is the whole point of the sequencing: when the structure grows the axiom
fields, every site is discharged by *citing* an existing lemma, and no proof has to be discovered
inside a red window.

### Reusable machinery (Phase 10)

Three relation classes cover every non-shift frame in the library. Each helper takes class
membership as an `Iff` hypothesis, so a site discharges it with `fun _ _ _ => Iff.rfl` and no
defeq-unfolding risk.

- **Helper A**, total relation on a subsingleton carrier: `serial_of_total`,
  `interpolates_of_total`, `limit_of_subsingleton`, `spherical_of_subsingleton`
- **Helper B**, permissive `R w d u ↔ (d ≠ 0 ∨ w = u)`: `Fib_permissive_zero`,
  `Fib_permissive_ne`, `serial_of_permissive`, `interpolates_of_permissive`,
  `limit_of_permissive`, `univ_or_singleton_of_permissive`, `spherical_of_permissive`
- **Helper C**, equality `R w d u ↔ w = u`: `Fib_eq_singleton`, `serial_of_eq`,
  `interpolates_of_eq`, `limit_of_eq`, `spherical_of_eq`
- Shared: `exists_pos_of_nontrivial`, `sInter_nonempty_of_directed_of_univ_or_singleton`

### Per-site axiom lemmas

| Phase | Sites |
|---|---|
| 10 | `trivialFrame`, `staticFrame`, `natFrame`, `customFrame` |
| 11 | `intTimeFrame`, `intNatFrame`, `genericTimeFrame`, `genericNatFrame` |
| 12 | `multiFamTaskFrameGen` (and hence `bundleFlowFrame`), `zTaskFrameV2`, `multiFamTaskFrame` |
| 13 | `regionFrame`, `RefinedFilteredTaskFrame`, `FiniteFilteredTaskFrame` |

### Two structural moves, both green and both forced

1. **The axiom predicates moved to `TaskFrame.lean`** (10.0). `Spherical`, `Serial`, and
   `Interpolates` lived in `FrameAxioms.lean`, which *imports* `TaskFrame.lean`. A structure
   field's type may only mention declarations that precede it, so a predicate declared in a module
   importing `TaskFrame.lean` could never become a `TaskFrame` field — the definitional-equality
   invariant the whole plan rests on was unreachable as the tree stood. Both modules already open
   `namespace FormalSystem.Semantics / namespace TaskFrame`, so the fully qualified names,
   statements, and namespace are unchanged and **no consumer changed**.
2. **The apparatus and predicates hoisted above the structure** (14.0). Same reason, second half:
   they sat *after* `structure TaskFrame`. Pure relocation.

## The two open items the plan flagged

### Caveat (a) — resolved for all three flagged sites

- **`regionFrame`: flag REFUTED by the falsification test, not assumed away.** The test was run
  first, as the plan requires: prove all four axioms at polymorphic `D` under `[Nontrivial D]`
  alone, with no discreteness hypothesis. It elaborates. Root cause of the stale flag, now
  recorded in the file: the flag was accurate against the frame's *former* relation
  `TaskRel s d s' := d = 0 → s = s'`, which above zero related every pair and did collapse *Limit*
  over dense `D`. The relation is now the deterministic clock `s.1 = s'.1 ∧ s'.2 = s.2 + d`,
  structurally identical to `multiFamTaskFrameGen`. A `#### Reasoned Exclusions` record in the
  plan carries the definition text and the discharging lemma names.
- **The two filtration sites: option (a), restrict.** The consumer enumeration that decided it,
  run before any edit: `RefinedFilteredTaskFrame` → `FiniteFilteredTaskFrame` →
  `filteredFiniteFrame`, all polymorphic in `D`, and nothing outside `FMP/` refers to any of them
  — `filteredFiniteFrame` has zero consumers. No live consumer elaborates at a dense duration
  type, so `[SuccOrder D] [NoMaxOrder D]` breaks nothing, while re-carriering would rebuild a
  carrier `FilteredWorld.finite` depends on for no gain. The restriction is forced by the axiom,
  not adopted for convenience.

### Caveat (b) — untouched, as required

`nullity_identity` is unchanged. Re-checked at implementation time: `specs/decisions/` holds
`total-history-validity-decisions.md` and `untl-snce-argument-order.md`, neither mentioning
`nullity_identity`. The joint decision has not landed.

## Why Phase 14's batch was not opened

All four of the phase's own pre-batch gates pass: 14 live `where`-sites reconciling with the
plan's table, zero `.mk` sites, a citable lemma for every one of the 14, and the `Boneyard/`
exclusion intact. The batch stayed shut for a different, measured reason: the phase's task list
bundles the four axiom fields with two structural changes whose blast radius was never sized.

| Bundled item | Measured blast radius |
|---|---|
| `[Nontrivial D]` as a structure binder | 575 `TaskFrame` mentions across 49 files — and it is not needed to state any of the four fields |
| `Nonempty WorldState` | discharge needs new nonemptiness binders at `staticFrame`, `regionFrame`, `multiFamTaskFrameGen`, `bundleFlowFrame`, and a `FilteredWorld` nonemptiness proof that does not exist |
| Per-site binder propagation forced by the *Limit* field | ~225 mentions across ~20 files |

Together these are far more than one run can close in a window where `sorry` is forbidden and no
partial state may be committed. The recommended re-size, recorded in the plan for decision: split
into **14a** (the four fields + per-site binders + the 14 discharges — the core deliverable, and
the only part Phase 15 depends on) and **14b** (`[Nontrivial D]` and `Nonempty WorldState`, which
are independent of the four axioms and gate nothing in Phase 15).

## Verification

| Check | Result |
|---|---|
| `lake build` | GREEN, exit 0, 2331 jobs — at every commit |
| `sorry` in the 10 touched files | **0** in every one |
| Repo-wide `sorry` count vs. pre-work baseline | 1026 → 1026, **unchanged** |
| `axiom` declarations vs. baseline | 6 → 6, **unchanged** |
| `#print axioms` on all ~70 new declarations | `propext` / `Classical.choice` / `Quot.sound` only |
| `bash scripts/check-paper-definitions.sh` | exit 0, no anchor drift |
| `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/` | 0 hits |
| `grep -rn "Limit Nullity" FormalSystem/` | 0 hits |
| `bash .claude/scripts/check-task-references.sh` | PASS, 0 unexempted occurrences |
| `lake build BimodalTest` | failure set unchanged from baseline (`BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`; 11 errors) — pre-existing, unrelated |

## Plan Deviations

Each is recorded inline on the owning phase in the plan, with evidence.

- **Phase 10** — prerequisite relocation of the three predicates (added, forced; see above);
  `staticFrame_serial` restated in `Serial` form (altered — it had zero consumers, and its
  unfolded conjunction could not be cited for a `Serial` field); `import Mathlib.Data.Int.SuccPred`
  added to `TaskFrameTest.lean`; `natFrame`'s binder change deferred to the field batch (the
  plan's own sanctioned second branch); Scope Hypothesis (iii) resolved — `SemanticBenchmark.lean`
  is not in the default build and carries no field obligation.
- **Phase 11** — `genericNatFrame`'s binder change deferred likewise (it has zero consumers, so
  the change is free when taken); `import Mathlib.Data.Int.SuccPred` added;
  `genericTimeFrame` needs no restriction on `D` at all, its `Unit` carrier discharging *Limit*
  over dense duration types.
- **Phase 12** — the anticipated generalization had already landed in the tree, so no fallback was
  needed and only the *shape* was missing; the phase's caution that `bundleFlow_*` "are consumed
  elsewhere" is stale (zero external consumers today), but they were left untouched regardless.
- **Phase 13** — `regionFrame`'s *Spherical* routes through `TaskFrame.lean`'s directed-family
  helper rather than `FlowFrame.lean`'s, because `FlowFrame.lean` is not in the import closure of
  `RegionFrame.lean` or `Filtration.lean`; consequently **no edit to `TaskFrame.lean` was needed**
  and the phase's no-edit constraint on that file holds.
