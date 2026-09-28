# Implementation Summary: Task #684

- **Task**: 684 - agreement_lemma_over_all_walks
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-28T18:20:00Z
- **Completed**: 2026-09-28T18:52:00Z
- **Effort**: ~35 minutes
- **Dependencies**: 683 (state-sharing witness structure, completed)
- **Artifacts**: plans/01_stability-quantifier-collapse.md, handoff-c5-statement.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed the stability-quantifier collapse for the branching witness frame as a new module,
`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean`, carrying four
sorry-free, axiom-clean declarations, and wired it into the `WitnessFamily` aggregator. The
literal deliverable named in the task description — the agreement lemma over all walks, box case
included — was already landed by the predecessor as `SharingWitnessFamily.truth_iff_mem`; per the
user's recorded re-scoping decision this round proves the stability case instead and hands the
resulting (C5) `StabFaithful` statement downstream.

Three of four phases closed. Phase 2's second half is blocked: the root aggregator
`FormalSystem.lean` is under a concurrent sibling's uncommitted modification, and the plan's
territory contract directs stop-and-report rather than regenerating over it.

## What Changed

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` — new module, 174
  lines, four declarations:
  - `StabQuant` — the stability clause's quantifier shape, stated at `Formula` (legitimate
    because the clause never inspects the formula, only the world state)
  - `stabQuant_iff_share_class` — **the collapse**: at a thread's trace the history quantifier
    does not range over walks, it collapses to a finite quantifier over the `share`-class of the
    present index, with the right-hand side ranging over `Fin S.lassos.length`
  - `stabQuant_iff_self_of_share_eq` — the deterministic cross-check: when `share u` is equality
    the class is a singleton and the collapse reads `⊡ψ ↔ ψ`, matching
    `PlusLanguage.stab_iff_of_deterministic`
  - `frame_recurrenceFree` — no world history of this frame visits a world state twice
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — one added import line.
- `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md` — new; the (C5) statement,
  its soundness argument, its decidability route and the deterministic cross-check, written to be
  cited rather than re-derived.
- `specs/state.json` — this task's `file_scope` corrected from the deterministic modules (three of
  which it must not touch) to the three files it actually works in.

## Decisions

- The two probes' proof scripts were transcribed verbatim, including the two steps the research
  round flagged as fragile, now carried as source comments so a later reader does not "simplify"
  them away: `rwa [show s + t = s' + t from by omega]` (naive `subst` on `s' = s` eliminates the
  wrong variable) and `have h : (s + a : ℤ) = (s + b : ℤ) := htime` (`Duration` is not
  syntactically `ℤ` at that goal).
- One deliberate departure from verbatim: the probe's `show` tactic became `change`. It tripped
  `linter.style.show`, whose disposition in `scripts/warning-budget.txt` is **blocking** with the
  recorded remedy "use `change` where the goal changes", against a zero-warning baseline.
- The two probes' standalone preambles were merged into one module docstring rather than kept
  alongside it, which is why the module came in at 174 lines against a 200-280 estimate. Nothing
  was omitted.
- `FormalSystem.lean` was left untouched. See Follow-ups.

## Plan Deviations

- **Phase 1** altered: 174 lines against the plan's 200-280 Scope Hypothesis; declaration set held
  exactly at four. Recorded as "Scope Hypothesis Outcome" in the plan.
- **Phase 2** blocked on its second half: the `mk_all` regeneration of `FormalSystem.lean` was
  skipped after the plan's own mandated territory check found a foreign uncommitted modification.
  Full `**BLOCKER**` record in the plan.
- **Phase 3** altered: the gate run is not green and could not be made green. One failing gate was
  this task's and was fixed in-phase (C28, `linter.style.show`); the other eight failing groups are
  pre-existing predecessor debt or concurrent siblings' in-flight edits, itemized with attribution
  in the plan's Phase 3 record.
- **Phase 3** correction to the plan's premise: C33 was **already failing before this dispatch**.
  `git show d139659eb:FormalSystem.lean | grep -c Sharing` returns 0 — the root aggregator listed
  none of the nine predecessor `Sharing.*` modules. A corrective `mk_all` is an 11-line repair of
  pre-existing drift, not the one-line addition the plan budgeted.

## Verification

- Build: **Success** at commit `b3955b837`, before the sibling edits landed — full `lake build`
  through `lake-build-guard.sh build --timeout 1800`, guard exit 0, "Build completed successfully
  (2753 jobs)", zero `error:` lines, zero `warning:` lines. The new module's `.olean` is newer than
  its source. The tree is red **now**, at `Sharing/Basic.lean:203` under a concurrent sibling's
  uncommitted refactor, in a file outside this task's scope.
- Sorry count: 0 (in the new module and in every file this task touched)
- Vacuous count: 0
- Axiom count: 0 new axioms
- Axiom audits, all `{propext, Classical.choice, Quot.sound}` with no warnings:
  `stabQuant_iff_share_class`, `stabQuant_iff_self_of_share_eq`, `frame_recurrenceFree`, and the
  regression re-audit of `truth_iff_mem`
- `bash scripts/check-copyright-headers.sh --strict FormalSystem`: exit 0
- `bash scripts/check-module-invariants.sh`: exit 1, 8 failing groups, none caused by this
  module's content. C1, C3, C4, C9, C26, C9D all pass.
- Tests: N/A (no test-library change)
- Files verified: Yes

## Impacts

- The stability modal's history quantifier is now settled for the branching witness frame: it does
  not range over walks. The certificate condition (C5) it fixes is decidable by
  `Sharing/Decide.lean`'s existing one-time window reduction, with no analogue of the
  relative-decidability gap governing the other conditions.
- `frame_recurrenceFree` closes off the "recurrence-freedom is a restriction" objection in advance,
  via `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree`.
- The downstream stability-condition work can cite `handoff-c5-statement.md` rather than re-derive
  the statement, its soundness argument or its decidability route.

## Follow-ups

- **Blocked, cross-territory**: `FormalSystem.lean` needs
  `import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability` for gate C33.
  The module is nevertheless in the build graph today — `FormalSystem.lean` already imports
  `FormalSystem.Metalogic.Decidability.WitnessFamily`, which now imports it — so only C33's
  byte-for-byte assertion is outstanding, not reachability.
- **Larger than this task**: C33 needs an 11-line `mk_all` repair covering nine predecessor
  `Sharing.*` modules that were never added to the root. Worth its own task; it is pre-existing
  drift, not this round's regression.
- **Deferred by territory**: the `Stability` entry in
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`'s submodule list.
- **Observed, not resolved**: a concurrent sibling is mid-refactor of `Sharing/Basic.lean`
  (extracting a `SharingSkeleton` into a new `Sharing/Skeleton.lean`) and that file does not
  currently compile. Reported rather than touched.

## References

- `specs/684_agreement_lemma_over_all_walks/plans/01_stability-quantifier-collapse.md`
- `specs/684_agreement_lemma_over_all_walks/reports/01_agreement-lemma-over-all-walks.md`
- `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md`
- `specs/684_agreement_lemma_over_all_walks/handoffs/phase-1-handoff-20260928T182304Z.md`
- `specs/684_agreement_lemma_over_all_walks/handoffs/phase-2-handoff-20260928T182622Z.md`
- `specs/684_agreement_lemma_over_all_walks/probes/01_stab_quantifier_collapse.lean`
- `specs/684_agreement_lemma_over_all_walks/probes/02_recurrence_free_frame.lean`
