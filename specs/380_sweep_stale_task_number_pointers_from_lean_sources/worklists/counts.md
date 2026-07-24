# Sweep Counts and Calibration (Phase 1 dry-run, 2026-07-24)

Generated from `rewrite_task_refs.py --dry-run` / `--worklist` over `Theories/` on the
clean tree (HEAD `2b315b64a`). Full machine report: `dryrun-report.txt`; per-line
before/after preview: `phase2-autodrop.diff`.

## Headline reconciliation vs research inventory

| Metric | Research (report §1) | Phase 1 dry-run | Status |
|---|---|---|---|
| Sweep-pattern lines | 1,549 | 1,549 | reconciled |
| Files with matches | 192 | 192 | reconciled |
| Build | EXIT 0, 1789 jobs, 1 warning | EXIT 0, 1789 jobs, 1 warning | reconciled |
| Census | 906 / 820 / 26 | 906 / 820 / 26 | reconciled |

## Category-(a) auto-drop calibration

- **Calibrated auto-drop: 597 matches in 130 files** (vs the report's 469 estimate).
  The production whitelist regex is a superset of the report's estimator variant: it
  additionally matches multi-number lists (`(tasks 154-155)`-style `/,+&` joins) and
  the `Phase …` / `Part …` / `vN` suffix shapes. Direction of drift is safe: every
  match is still a whitelisted parenthetical, comment-span-asserted, sorry-guarded,
  protected-span-skipped. Phase 2's expected recount decrease is calibrated from the
  arithmetic below, not from the 469 estimate.
- Diff preview: 193 file sections, 527 removed / 593 added lines (some hunk context
  lines repeat across nearby hunks; per-line pairs are the before/after preview).

## Line-level arithmetic (basis for the Phase 2 gate)

| Bucket | Lines |
|---|---|
| Sweep-matching lines pre-sweep | 1,549 |
| Fully cleared by auto-drop (virtual) | 590 |
| Residual sweep-matching lines → hand-edit worklists | 945 |
| Sorry-line DEFERRED residual (never edited, never worklisted) | 14 |
| **Expected recount immediately after Phase 2** | **1,549 − 590 = 959** |

(597 matches clear 590 lines: several lines carry two parentheticals or retain a
second, non-parenthetical reference and stay on a worklist.)

Additional worklist lines outside the 1,549 headline: **22** `specs/NNN_…` path-citation
lines that do not themselves match the sweep pattern (category c, Settled decision 3).
Total worklist entries: 945 + 22 = **967**.

## Worklist category tallies (heuristic; reclassify while editing)

| Category | Lines |
|---|---|
| b — durable-equivalent substitution | 723 |
| c — state-the-fact (incl. specs-path citations, hyphenated task-N) | 186 |
| d — VERIFY truth before rewriting | 58 |

## Per-phase grouping (plan Phases 3-7 territories)

| Phase | Territory | Worklist entries |
|---|---|---|
| 3 | SharedWitness.lean | 162 |
| 4 | NfMultiAnchorBridge Base/InteriorGateGeneralK/SubBracket2V/EndIntervalConsumerK/OuterGate | 173 |
| 5 | NfMultiAnchorBridge remainder + aggregator + KampPrior.lean | 222 |
| 6 | Metalogic remainder (non-Boneyard) | 144 |
| 7 | Non-Metalogic live + ALL Boneyard paths | 266 |
| | **Total** | **967** |

## Exclusion buckets (loud, tracked)

1. **Sorry-line DEFERRED: 14 lines** (report §5 estimated ~0 — actual is 14). Binding
   Postmortem rule: never modify a line containing `sorry`. These 14 keep matching the
   sweep pattern, so the achievable recount floor after Phases 2-7 is **14, not 0**,
   unless a supervised decision amends the rule for prose-only sorry mentions. Full
   list in `dryrun-report.txt` ("sorry-line DEFERRED residual"). Flagged for the
   orchestrator/Phase 8 — do NOT resolve unilaterally in an edit phase.
2. **NON-COMMENT match lines: 6** — task numbers inside *string literals* (4×
   `return "INFO: … task 237"` in Metalogic/Decidability (phase 6), 2× `IO.println`
   banners in Automation (phase 7)). The comment-span assertion excludes them from
   auto-drop; they appear in worklists with a **NON-COMMENT** marker. Editing them is
   NOT comment-only (changes runtime output strings, though never proofs); the owning
   phase must decide with the orchestrator. Discovered exactly as the plan's
   Rollback/Contingency anticipated (excluded shapes move to worklists; phase
   boundaries unchanged).
3. **Protected-span exclusions: 0** — no sweep matches inside the four protected decl
   spans (`nf_nvar_exist_all_depths`, `neg_bracket_zero_is_vbracket`,
   `neg_bracket_is_vbracket`, `neg_partialBracketExist_is_vbracket`). Protection is
   active and verified but currently vacuous for edits.

## Post-phase recount log

| After phase | Recount (lines) | Notes |
|---|---|---|
| baseline | 1,549 | this document |
| 2 | (fill in: expect 959) | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | expect floor 14 + 6 NON-COMMENT decisions |
| 8 | | target 0 or documented deferred remainder |
