# Task 440 — handoff after Phase 3

## Immediate next action

Await/absorb the Phase 4 result (`FormalSystem/Semantics/Extension/Extension.lean` docstring
repairs + cost note), then run Phase 5's final gate and write
`summaries/01_finite-spherical-discharge-summary.md`.

## State

| Phase | Status | Commit |
|---|---|---|
| 1 Baseline + scaffold | COMPLETED | `14c621382` |
| 2 `wlem_of_spherical` | COMPLETED | `919bf7386` |
| 3 Axiom-profile guards | COMPLETED | `c42d37191` |
| 4 `Extension.lean` docstrings | delegated, in flight | — |
| 5 Final gate + summary | NOT STARTED | — |

## Key facts established (do not re-derive)

- `TaskFrame.sInter_nonempty_of_directed_of_minimal` and `TaskFrame.spherical_of_finite` were
  **already landed** before this dispatch, with both imports and both docstring notes. Confirmed,
  not re-landed. Same for the `cor:spherical-finite` record entry.
- Measured axiom baselines (Phase 1, verbatim, now pinned as guards where noted):
  - `sInter_nonempty_of_directed_of_minimal` — `does not depend on any axioms` *(guarded)*
  - `spherical_of_finite` — `[propext, Classical.choice, Quot.sound]` *(guarded)*
  - `spherical_of_subsingleton` — `[propext]` *(guarded — the tripwire)*
  - `wlem_of_spherical` — `[propext, Quot.sound]` *(guarded)*
  - `spherical_of_permissive` — `[propext, Classical.choice, Quot.sound]` *(not guarded; already
    classical at baseline)*
  - `spherical_of_eq` — `[propext, Classical.choice, Quot.sound]` *(not guarded; same reason)*
- `#guard_msgs in #print axioms` **works** in this toolchain. Gating was verified positively by
  deliberately corrupting an expectation and confirming a red build, then restoring.

## Two open deviations to carry into the summary and GATE OUT

1. **`check-paper-definitions.sh` reports case (c)** — four drifted anchors (`def:TMplus`,
   `cor:tm-completeness`, `def:id`, `def:strongest`). `cor:spherical-finite`, the only anchor
   this task depends on, is **not** among them. Drift is in the external read-only paper and
   predates the dispatch; the record file is clean against HEAD. Proceeded deliberately; needs
   referral to whoever owns those four anchors.
2. **`lake build BimodalTest` is red at dispatch**, in exactly three pre-existing modules
   (`BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`), all `#guard_msgs` mismatches, all
   unmodified against HEAD, none importing this task's new module. Substituted gate:
   `lake build BimodalTest.Semantics.SphericalFiniteAxiomTest`.

## Decisions worth preserving

- Two `/-- -/` doc comments cannot stack; guard explanatory prose lives in `/-! -/` blocks with
  `/-- info: … -/` reserved for the expectation.
- The no-Zorn claim is recorded as an **import-graph** argument, not an axiom test:
  `TaskFrame.lean` imports no `FormalSystem.*` module at all, and Zorn enters at
  `PartialHistoryOrder.lean`, which is downstream. A dependency would need an import cycle.
