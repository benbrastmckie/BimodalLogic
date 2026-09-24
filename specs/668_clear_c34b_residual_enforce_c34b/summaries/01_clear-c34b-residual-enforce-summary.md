# Implementation Summary: Task #668

- **Task**: 668 - Clear the 8-row C34b residual in the hypothesis-honesty gate, then flip
  `ENFORCE_C34B=1` so the trigger half of invariant C34 is enforced alongside C34a
- **Status**: [COMPLETED]
- **Started**: 2026-09-24T14:25:19Z
- **Completed**: 2026-09-24T15:16:00Z
- **Effort**: ~50 minutes
- **Dependencies**: None (direct follow-up to the completed hypothesis-honesty-lint work)
- **Artifacts**: plans/01_clear-c34b-residual-enforce.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Invariant C34 in `scripts/check-module-invariants.sh` gates hypothesis honesty over the bundling
`FrameOver.IsRegular` class. Its structural half (C34a) was enforced; its trigger half (C34b)
shipped soft at `ENFORCE_C34B=0` because eight binder-carrying declarations whose docstrings read
as constraint claims carried no marker, and each needed more than a marker line. All eight rows
are cleared, both halves of C34 are now enforced, and the two documents that described the soft
window now describe what the gate actually does. All eight phases completed; nothing was
descoped.

## What Changed

- `scripts/check-module-invariants.sh` — four changes. (1) The C34 declaration-span scan now
  truncates at `example` and `omit` as well: an `example` is anonymous, opens no span of its own,
  and would otherwise put its `[F.IsRegular]` binder inside the preceding declaration's body,
  which is exactly what would have defeated the new rule on `FrameOver.saturation`. Verified
  verdict-neutral — every census figure and both verdicts byte-identical before and after.
  (2) A field-to-constraint table (`BUNDLER_FIELDS`) beside `BUNDLERS`, keyed by name rather than
  by positional index, with an exit-2 anti-drift check that it spells the vocabulary exactly.
  (3) A second C34a discharge, the **field re-export** rule: `reexport_field` recognizes a
  declaration whose whole proof term is one field projection off its own bound instance, and
  `reexports` discharges it when the marker names exactly that field's constraint;
  `c34a_violation` now consults both discharges through a new `discharge()`, and `PASS C34a`
  reports the two separately. (4) `ENFORCE_C34B` defaults to 1 in both the shell and the python,
  the now-false "set `ENFORCE_C34B=1` once the list is clear" line is replaced by a softened-mode
  notice, and the flag is retained. Ten new `_FIXTURES` entries (12 → 22).
- `FormalSystem/Semantics/TaskFrame.lean` — new binder-free
  `FrameOver.nullity_identity_of_serial_limit`, with `FrameOver.nullity_identity` demoted to a
  one-line corollary of it; eight marker lines (`FrameOver.saturation` and `TaskFrame.saturation`
  at *Saturation* as field re-exports; `FrameOver.nullity` and `TaskFrame.nullity_of_serial_limit`
  at *Seriality, Limit*; `FrameOver.reflection` and `FrameOver.reflection_of_limit` at *Limit*;
  and both halves of the new restatement pair).
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` — new binder-free
  `FrameOver.static_of_uniformDwell_of_compositional_serial_limit`;
  `FrameOver.static_of_uniformDwell` demoted to a one-line corollary;
  `FrameOver.static_iff_uniformDwell` re-routed through the twin rather than through the
  corollary (the corollary mentions `IsRegular` in its span, so it cannot be delegated to).
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean` — new binder-free
  `FrameOver.levels_closed_of_limit`, which clears both rows in this file:
  `FrameOver.levels_closed` becomes a one-line corollary and
  `FrameOver.constant_of_countable_range` is routed through the twin directly.
- `docs/development/MODULE_INVARIANTS.md` — the C34 row retitled `C34a / C34b (both enforced)`,
  both discharges named with measured live surfaces, and the soft-window sentences replaced by
  what was actually done.
- `docs/development/REFERENCE_NORMAL_FORM.md` — section 3's C34a bullet corrected and replaced by
  an enumerated list of the three discharges with measured surfaces, plus the broad projection
  rule recorded as considered-and-deferred with both measurements and the blind spot that decided
  it, plus the six-unmarked-re-exports follow-up.
- `README.md` — the generated inventory block regenerated (the three new declarations made its
  committed line counts stale; INV named the remedy).

### Route selection

The research report's finding held under implementation: a second discharge rule was *required*,
not merely cheaper. `FrameOver.saturation` and `TaskFrame.saturation` are field re-exports whose
whole proof term is `h.saturation` / `F.toFibre.saturation`. Delegation requires a twin mentioning
no bundling class anywhere in its span, and any restatement of "the class supplies this field"
must name `IsRegular` — so route (a) cannot reach them even in principle. The rule shipped in its
narrow form (surface 8) rather than the broad projection form (surface 46 as measured here).

## Decisions

- **The two re-exports are marked at one field, not at all four.** An all-four marker would have
  been a two-line change needing no gate work, because a marker omitting nothing is C34a-exempt.
  It was rejected: the marker's defined meaning is that the listed constraints are the whole of
  what the elaborated term reaches, `h.saturation` reaches one field, so an all-four marker there
  would be a false statement destroying exactly the audit value the form exists for.
- **The re-export rule fails closed at five independent points** — one bundling class, one `:=`,
  a full match of the projection shape (so a body applying a further lemma is not a re-export), no
  other field of the class in the projection chain, and exact marker identity. Four mutation tests
  confirmed each point is pinned by at least one fixture: removing the rule misjudges the two
  must-pass fixtures, dropping marker identity misjudges two must-fail ones, `search` in place of
  `fullmatch` misjudges two more, and dropping the chain check misjudges the eighth.
- **`static_iff_uniformDwell` is routed through the twin, not through the corollary beside it.**
  The corollary mentions `IsRegular`, so delegating to it would not discharge.
- **The existing `PASS C34a` second line was imprecise and is corrected.** It reported all 18
  binder-carrying markers as "discharging by delegation"; measured, 11 delegated and 7 omitted
  nothing. The documentation records the measured split, not the old figure.
- **Six field re-exports left unmarked** (`FrameOver.comp`/`serial`/`limit` and the `TaskFrame`
  counterparts). None triggers C34b, none is required by DONE, and the hard constraints say to
  leave them alone. Recorded as a follow-up, not filed as a task.

## Plan Deviations

- **Phase 2** altered: eight new `_FIXTURES` entries rather than the seven the plan listed. A
  sixth must-fail case pins the projection-chain field check, which no other fixture reached (a
  mutation test confirmed the gap before the fixture was added).
- **Phase 8** altered: `README.md` was modified although it is not in the plan's declared file
  list. The three new declarations made the INV check's committed line counts stale and the gate
  failed on it; regenerating via `--emit-inventory` is the remedy INV itself names.
- **Phase 1** altered: two truncation fixtures rather than one — the plan asked for the `example`
  case, and the `omit` case is added alongside since the code change covers both keywords.

## Verification

- Build: Success — full `lake build`, 2726 jobs, exit 0, zero errors, zero warnings. Run detached
  under the build guard with a bounded PID-liveness waiter at every phase boundary from Phase 5
  onward, and once more at close.
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots)
- Vacuous count: 0
- Axiom count: 14 — unchanged from the base commit. C2's four flagship axiom baselines are
  unmoved (`[propext, Classical.choice, Quot.sound]` on each), and C14's pinned declarations all
  match.
- Tests: N/A (no test changes; `Tests/` builds as part of the full build)
- Files verified: Yes
- **`bash scripts/check-module-invariants.sh`: ALL CHECKS PASSED**, with `PASS C34a` and
  `PASS C34b`, `ENFORCE_C34B` defaulting to 1.
- **The flag was retained, not deleted**: probed against a synthetic C34b hit, the default path
  exits 1 and `ENFORCE_C34B=0` exits 0 with a softened-mode notice.
- **Signature identity**: all five rewritten declarations keep byte-identical signature lines —
  both the keyword line and its continuation — checked mechanically against the base blob
  `c40ddd51c299eaabb2c0664a5b7b4038f666c65c` with `git show <base>:<file> | sed -n '<line>p'`,
  never by eye.
- **Out of scope, confirmed pre-existing in a detached worktree at the base commit**:
  `check-paper-definitions.sh` exits 1 identically (its 54-line output differs from the base
  commit's only in the absolute path prefix, with the same verified pinned sha256), and
  `typst-sync-check.sh` Check 2 exits 1 with the same four violations — three counters
  bit-identical, and `formalsystem-line-count` moving from `live=299035` to `live=299143` against a
  pre-existing staleness of 13,427 lines and 23 files. Neither is a regression from this task and
  neither was absorbed.

### Measured census, re-measured at close

No figure from the plan, the research report or the task description was carried forward as an
acceptance value. Every number below is from the gate's own ungated census on this tree.

| | Phase 1 baseline | At close |
|---|---|---|
| binder-carrying declarations / files | 212 / 46 | 212 / 46 |
| `Constraints consumed:` markers | 29 | 43 |
| markers omitting *Saturation* | 22 | 34 |
| binder-carrying, unmarked | 194 | 185 |
| live `.lean` files / declaration spans | 630 / 11988 | 630 / 11991 |
| C34a discharges: omit nothing / delegation / re-export | 7 / 11 / 0 | 7 / 18 / 2 |
| **C34b residual** | **8** | **0** |
| C34 fixtures | 12 | 22 |

Residual trajectory, each step measured from the gate's own hit list rather than by subtraction:
8 → 6 (Phase 3) → 4 (Phase 4) → 3 (Phase 5) → 2 (Phase 6) → 0 (Phase 7).

Rule surfaces measured on this tree: the narrow field re-export rule recognizes 8 declarations;
the broad "names exactly the class fields its marker lists" rule would reach 46 of the 212
binder-carrying declarations.

## Impacts

- The anti-silence property of the marker convention is complete. Before this, an opt-in marker
  with only a structural half was bypassable by simply not marking a declaration; C34b is now
  exit-code-affecting, so a new binder-carrying declaration whose docstring reads as a constraint
  claim fails CI until it carries a marker.
- Three new binder-free theorems are available to any consumer that satisfies fewer than all four
  constraints: `FrameOver.nullity_identity_of_serial_limit`,
  `FrameOver.static_of_uniformDwell_of_compositional_serial_limit`, and
  `FrameOver.levels_closed_of_limit`. No call site moved: every original survives with an
  unchanged signature.
- The gate's discharge vocabulary is wider by exactly one narrow rule, and its `PASS C34a` line
  now reports the live surface of each discharge, so a future widening has a measured baseline
  rather than a prose one.

## Follow-ups

- The six unmarked field re-exports (`FrameOver.comp`/`serial`/`limit` and the `TaskFrame`
  counterparts) would exercise the new rule across its whole surface. None triggers C34b, so none
  is required; recorded in `REFERENCE_NORMAL_FORM.md` section 3.
- The broad projection rule stays deferred, with both measurements (46 of 212 against 8) and the
  deciding blind spot recorded: transitive consumption through a callee carrying its own
  `[F.IsRegular]` binder is invisible to any projection scan. Delegation shares that blind spot
  and is documented as doing so.
- `check-paper-definitions.sh` (a `def:id` drift in the paper's LaTeX sources) and
  `typst-sync-check.sh` Check 2 (`generated/status.typ` counts stale by 23 files and ~13,400
  lines) both fail on the base commit and belong to separate work.

## References

- `specs/668_clear_c34b_residual_enforce_c34b/plans/01_clear-c34b-residual-enforce.md`
- `specs/668_clear_c34b_residual_enforce_c34b/reports/01_clear-c34b-residual-enforce.md`
- `docs/development/REFERENCE_NORMAL_FORM.md` section 3 — the constraint-consumption form and its
  three discharges
- `docs/development/MODULE_INVARIANTS.md` — the `C34a / C34b (both enforced)` row
