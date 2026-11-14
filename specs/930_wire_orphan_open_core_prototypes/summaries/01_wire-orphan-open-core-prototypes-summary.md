# Implementation Summary: Task #930

- **Task**: 930 - Promote and wire the two orphan open-core prototypes into the evidence gate
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T17:54:00Z
- **Completed**: 2026-11-13T20:00:00Z
- **Effort**: ~2.5 hours across four dispatched phases
- **Dependencies**: None
- **Artifacts**: plans/01_wire-orphan-open-core-prototypes.md, reports/01_wire-orphan-open-core-prototypes.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Two compiled prototypes that `RaySummary/README.md` cited as the sole authority for two
load-bearing refutations about the depth-`0` open core sat in gitignored `specs/archive/`, where the
evidence gate could not hold them and a fresh clone would not have them. Both are now promoted
verbatim to tracked paths under `specs/evidence/seam-gluing-ray-product/`, wired into
`scripts/check-evidence-probes.sh`, and cited by the README at their new wired paths. Neither
README authority claim turned out to be stale: both prototypes compile clean against the live tree,
so the more serious outcome the task description flagged did not materialize.

## What Changed

- `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean` — new, tracked; verbatim
  promotion of the archived 836B prototype, one header line rewritten. Holds
  `tightChain_isLadderPath`, `tightChain_pin`, `tightChain_slack_zero`, `tightChain_pins`,
  `spanningBlockBwd_refuted`, `spanningBlockFwd_refuted` — the two-directional refutation of the
  spanning-block device on a tight chain of pins.
- `specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean` — new, tracked; verbatim
  promotion of the archived 838B prototype, one header line rewritten. Holds
  `spanning_walk_not_pending` and `spanningBlockLengthDvd_refuted` — the alternating-path refutation
  that (K1) constrains a spanning block length.
- `scripts/check-evidence-probes.sh` — two comment-table blocks and two `WIRED` array entries
  (`seam-gluing-ray-product/ladder-tight-chain-regime-b`,
  `seam-gluing-ray-product/ladder-spanning-divisibility`); neither in `WIRED_REPO`.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — both citation parentheticals rewritten
  to name the wired probe by backticked path; "not a wired probe" and "in the task record" dropped.

## Decisions

- Both entries went in `WIRED`, not `WIRED_REPO`: `WIRED_REPO` exists only for a probe with a named
  promotion blocker, and neither has one.
- The promotion is verbatim apart from one header line each. The chain lemmas
  `ladder-tight-chain-regime-b.lean` shares with the already-wired
  `ladder-tight-chain-nonliftability.lean` were deliberately not pruned: that would edit a compiled
  record to save about two seconds of gate time, against the gate's own no-weakening rule.
- Paths are cited with backticks, never a `[text](path)` markdown link, because readme-lint Check 3
  and invariant C13 parse only markdown links.
- Phase 4's scoped discharge of the deferred full gate set was
  `verify-deploy.sh --only-gate 14` (runtime-file tracking — the gate that reaches `specs/**`
  tracked-ness). The five repository-specific criteria unmappable to any `--only`/`--only-gate`
  narrowing were each run directly and in full.

## Plan Deviations

- **Phase 2 Scope Hypothesis** altered: it asserted a live gate baseline of 58; the measured live
  baseline was 59, because a sibling task wired `seam-gluing-ray-product/one-sided-count-move-refutation`
  after this task's research run. The plan's own instruction (assert the delta against the number
  captured in this phase, never against the literal 58) absorbed this, so the target was 61, not 60.
  Cited line numbers had moved for the same reason and were relocated by content.

## Verification

- Build: Success — full `lake build` through the build guard, exit 0, 0 `error:`, 2975 jobs.
- Evidence gate: `bash scripts/check-evidence-probes.sh` exit 0, `PASS  all 61 wired probe(s) compile`
  — the live 59-probe baseline raised by exactly two, both new rows PASS, no other probe row changed.
- Sorry count: 0.
- Vacuous count: 1 (pre-existing, not attributable to this task: `int_domain_universal ... := trivial`
  in `FormalSystem/Examples/TemporalStructures.lean`, a real proof the census grep matches
  structurally; this task modified no file under the Lean source roots).
- Axiom count: 14 grep hits, all pre-existing and all false positives — wrapped prose lines in
  comments and READMEs beginning with the word "axiom"; no `axiom` declaration exists under the roots.
  No axiom was introduced.
- `#print axioms` on all 8 headline theorems of the two promoted files: subsets of
  `[propext, Classical.choice, Quot.sound]` only — no `sorryAx`, no custom axiom, no `native_decide`.
- `bash scripts/readme-lint.sh` exit 0 (`RESULT: PASS`, 0 broken file references).
- `bash .claude/scripts/check-task-references.sh --quiet` exit 0.
- `bash scripts/check-module-invariants.sh --no-build` exit 0, `ALL CHECKS PASSED`, no finding naming
  a touched file.
- `bash scripts/typst-sync-check.sh --counts-only` exit 0, `MISMATCH_COUNT=0`.
- `bash .claude/scripts/verify-deploy.sh --only-gate 14` exit 0, `PASS -- 1 check(s), 0 failure(s)`.
- Tests: N/A (no test suite ranges over the touched content).
- Files verified: Yes. Neither archived original was modified or force-tracked.

## Impacts

- The two refutations the README calls load-bearing are now held by the evidence gate itself: a
  future change that breaks either compiled record fails `check-evidence-probes.sh` instead of
  passing silently, and a fresh clone carries both records.
- The defect class the task names — a compiled record cited as authority but living where git does
  not track it — is cleared for these two citations.

## Follow-ups

- `generate-decidability-inventory.sh --strict --diff` exits 1 with 49 `+ REFUTED` and 2 `- REFUTED`
  rows. Exactly two are this task's, for a future baseline refresh:
  `seam-gluing-ray-product/ladder-tight-chain-regime-b` and
  `seam-gluing-ray-product/ladder-spanning-divisibility`. The other 47 predate this task; that
  baseline is stale independently of this work and was deliberately not refreshed here.
- Three further orphan prototypes of the same defect class remain unpromoted
  (`pin-free-side.lean`, `idle-gap-lengthening.lean`, `cell-obligation-refutation.lean` under the
  same two archived prototype directories). No live-library file cites them, so they were outside
  this task's defect, but the gap stays visible.
- A third "not a wired probe" qualifier remains in `RaySummary/README.md` naming a different
  prototype; it was outside this task's two citation sites.
- The deployed `.claude/` tree is stale for the `core`, `lean` and `sapience` extensions.
  Pre-existing; remedy is `bash .claude/scripts/deploy-headless.sh`, not a hand-patch.

## References

- `specs/930_wire_orphan_open_core_prototypes/plans/01_wire-orphan-open-core-prototypes.md`
- `specs/930_wire_orphan_open_core_prototypes/reports/01_wire-orphan-open-core-prototypes.md`
- `specs/930_wire_orphan_open_core_prototypes/handoffs/phase-1-handoff-20261113-191856.md`
- `specs/930_wire_orphan_open_core_prototypes/handoffs/phase-2-handoff-20261113-193851.md`
- `specs/930_wire_orphan_open_core_prototypes/handoffs/phase-3-handoff-20261113-194604.md`
- `specs/930_wire_orphan_open_core_prototypes/handoffs/phase-4-handoff-20261113-200024.md`
