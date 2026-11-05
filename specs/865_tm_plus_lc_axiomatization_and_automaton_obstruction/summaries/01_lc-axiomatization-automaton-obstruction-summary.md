# Implementation Summary: Task #865

- **Task**: 865 - tm_plus_lc_axiomatization_and_automaton_obstruction
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T16:29:23Z
- **Completed**: 2026-11-05T16:39:59Z
- **Effort**: ~0.3 hours (close-out plan; the task's substantive deliverable was the research
  report, written in the prior research dispatch)
- **Dependencies**: 864 (`[COMPLETED]`), 866 (`[COMPLETED]`)
- **Artifacts**: plans/01_lc-axiomatization-automaton-obstruction.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task's substantive deliverable — the research report at
`specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md` —
was already written before this implementation dispatch began. What this implementation
discharged is exactly what the task description's close-out mandate requires: amend report 03's
§1.3 ZTime reading, audit and file the two follow-ons the report recommends, and close with a
summary and the full gate. No library change and no completeness claim lands from this task.

**The report's verdict, in two sentences.** A doubled (two one-sided, clock-anchored) automaton
pair is sufficient in shape — no bi-infinite ℤ-automaton is needed — conditional on
`SeparationOver TaskFrame.IsZTime`; but Reynolds' one-sidedness mismatch is NOT the binding
obstruction. The binding obstruction is the Auxiliary-Atoms carrier, proved intrinsic (unique-
predecessor + `TwoWayBounded` + surjectivity forces a past-deterministic base), so `coneR`'s
two-layer shape and its *Saturation* obligation are forced; a layer-split route to that
obligation is given, whose one missing ingredient — oriented-forest *Saturation* — is also the
MSO cover step's prerequisite (now filed as project 870).

## What Changed

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` —
  appended a second, dated amendment blockquote to §1.3, withdrawing the closing sentence "the
  open question is only a *natural* system". The ZTime axiomatizability question is now recorded
  as open at the level of **existence**, not only naturalness, for three independent reasons
  (G1 is live inside step 1 of the very argument; §1.3 rests on a recalled, not held, theorem;
  the landed `decidableValidZTime`/`decidableDerivableZTime` are a different, narrower result).
  The original sentence itself is left byte-identical (confirmed by `grep` before and after); no
  positive claim is added and the finite model property remains unestablished.
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals.json` — new; the
  two-element follow-on proposal set (R1, R2) in `audit-task-proposals.sh`'s set-mode shape.
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals-audit.ndjson` —
  new; the full backlog-reconciliation audit evidence, one NDJSON line per proposal.
- `specs/state.json` / `specs/TODO.md` — two new `not_started` tasks filed via `state-write.sh`
  under the shared mutex (see Component 7 table below).

## Decisions

- **R1's `file_scope` narrowed mid-audit.** The initial audit of R1 (oriented-forest
  *Saturation*) returned a `duplicate-of-open` verdict against task 869
  (`open_modal_invariance_ray_agreement_lifting`), mechanical_class `overlap`, on the single
  shared path `FormalSystem/Semantics/README.md`. Task 869 is actually about open-future/open-
  past modal invariance along ray agreement — unrelated content; the overlap was a shared,
  low-specificity catch-all README file, not real scope duplication. Dropped
  `FormalSystem/Semantics/README.md` from R1's declared `file_scope` (keeping only
  `FormalSystem/Semantics/TaskFrame.lean`) and re-ran the audit; no remaining open-side verdict.
  Final disposition for both R1 and R2: `genuinely-new`.
- **`state-write.sh --audit-verdict` could not take the full audit NDJSON directly.** Each of
  its two lines is ~151KB (dominated by `scope-blind` verdicts against the ~450-490 open backlog
  entries that declare no `file_scope`), and the script passes that parsed JSON to `jq` as a
  single `--argjson` shell argument — over Linux's 128KB per-argv `MAX_ARG_STRLEN`, which failed
  with exit 126 "Argument list too long". Worked around with a condensed audit-verdict file
  (kept every non-scope-blind verdict verbatim; collapsed the scope-blind entries into a
  `scope_blind_count` integer — the compact rendering the plan's own Phase 2 step already asked
  for). The full, uncondensed `task-proposals-audit.ndjson` remains the committed durable
  evidence; the condensed file was only `state-write.sh`'s input and is recorded verbatim into
  each new entry's own `audit_verdict` field. Recorded as an issue
  (class `tooling-limitation`, severity `costly`) for `state-write.sh`'s maintainers.

### Component 7 Confirmation Table

The task description's own "file the implementation as its own task" instruction is this task's
pre-authorization for these two filings (Multi-Task Creation Standard Component 7's mandatory
foreground confirmation is bypassed on that stated basis — see the plan's Risks table); this
table is the record of that confirmation.

| # | Title | Task Type | Effort | Dependencies | Backlog Check |
|---|-------|-----------|--------|---------------|----------------|
| 870 | Oriented-forest Saturation lemma for TaskFrame | lean4 | ~1 hour | None | `genuinely-new` after narrowing `file_scope` to drop `FormalSystem/Semantics/README.md` |
| 871 | Correct LCU docstring and restore omega_chain segment-property parameter | lean4 | ~0.5 hours | None | `genuinely-new`; no open-side overlap at any audit pass |

### Why R3 and R4 Are Deliberately Not Filed

- **R3 (the doubled AA⊡ rule, forward plus mirror at the clock zero) is gated, not filed.** It
  is gated on R1 (project 870), because the Auxiliary-Atoms carrier's *Saturation* obligation —
  the thing R1 supplies — is exactly what stops it today, and it is informed by task 867
  (`SeparationOver`), because the doubled architecture consumes separation. Filing R3 now would
  reproduce the blocker `NamingRules.lean` already records (lines 57-82: `FrameOver.ofReflectiveRegular`
  demands *Saturation*, and none of this tree's three existing routes to it applies at the
  forward-cone unravelled carrier). Neither reads as an oversight: both gating facts are already
  on record and R3 is the natural next task once 870 lands.
- **R4 (the MSO decidability result) is refused outright, not deferred.** Mathlib has no
  ω-automata, no MSO syntax, no determinization, and no Rabin tree theorem — the same reason
  task 866's own R2 refuses the matching formalization attempt on the open-modal side. On top of
  that, gap G1 (the induction-scope gap the §1.3 amendment above now flags explicitly) should be
  repaired on paper before any formalization of §1.3 is even attempted; that paper repair is
  866's R4 and is the right next step for anyone pursuing the decidability reading, not this
  task's R4.

## Plan Deviations

- **R1's filed `file_scope`** is `["FormalSystem/Semantics/TaskFrame.lean"]` rather than the
  plan's originally specified two-path scope (`TaskFrame.lean` + `Semantics/README.md`), per the
  audit finding recorded under Decisions above.

## Verification

- Build: N/A (no library change; `FormalSystem/` and `Tests/` confirmed byte-identical via
  `git status --short -- FormalSystem/ Tests/` and `git diff --stat HEAD -- FormalSystem/ Tests/`,
  both empty).
- Tests: N/A (same reason).
- Files verified: Yes — `validate-artifact.sh` on the amended report (exit 0), `jq -e .` on both
  written JSON/NDJSON files, `validate-state.sh` (exit 0, PASSED WITH WARNINGS; 18 pre-existing
  warnings unrelated to this write, 0 failures), and `validate-artifact.sh` on this summary.
- Full gate: deferred to this multi-task `/orchestrate` batch's own once-per-invocation
  verification stage per this dispatch's Batch Gate Deferral directive (see dispatch 7, and
  `context/formats/plan-format.md`'s Batch-aware deferral subsection); not independently run at
  full depth inside this dispatch. This task's own changes are confined to `specs/**`, so the
  scoped narrowing this directive names reduces to the data/prose checks already listed above.

## Impacts

- The TM-plus-plus-LC completeness programme, previously unowned (narrowed out of task 559's
  scope), now has two concrete, audited follow-on tasks (870, 871) with declared scope, plus a
  corrected docs/report record of what is and is not settled at ZTime.
- `docs/theorem-index.md` needed no change (confirmed by the report and left untouched; it is
  also inside a concurrent sibling's declared `file_scope` this cycle).

## Follow-ups

- Project 870 — oriented-forest *Saturation* lemma (unblocks both the AA carrier layer-split
  route and the MSO cover step).
- Project 871 — the corrective LCU docstring and `omega_chain` parameter repair.
- R3 (doubled AA⊡ rule) remains gated on 870 and informed by 867; not filed.
- R4 (MSO formalization) remains refused; the right next step for that reading is 866's R4
  (the G1 paper repair), not a new task here.
- The `state-write.sh --audit-verdict` per-argv size ceiling (recorded as an issue this session)
  is a latent limitation for any future backlog audit against a large corpus; not fixed here.

## References

- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md`
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/plans/01_lc-axiomatization-automaton-obstruction.md`
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals.json`
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals-audit.ndjson`
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`
