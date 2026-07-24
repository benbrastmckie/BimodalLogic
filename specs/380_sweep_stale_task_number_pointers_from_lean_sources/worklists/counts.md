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
| 2 | 959 | exact match to arithmetic (1,549 − 590); 143 files still matching; build EXIT 0; census 906/820/26 |
| 3 | 797 | exact match to arithmetic (959 − 162); SharedWitness.lean file recount 0; --check-diff 1 file / 0 failures; build EXIT 0 (1789 jobs); census 906/820/26; changed-line sorry grep 0 |
| 4 | 626 | five NfMultiAnchorBridge large files; per-file NON-sorry recount 0; 7 sorry-line DEFERRED residuals recorded; --check-diff 5 files / 0 failures; build EXIT 0 (1789 jobs); census 906/820/26; changed-line sorry grep 0 |
| 5 | 408 | NfMultiAnchorBridge remainder + aggregator + KampPrior; 222 worklist entries + 4 specs-path-only siblings = 29 changed files; territory LIVE recount 0 (8 sorry-line DEFERRED residuals: the 7 from Phase 4 + `CarrierK1V.lean:79`); protected span `nf_nvar_exist_all_depths` (KampPrior 350..535, resolved by name) has zero changed lines; --check-diff 29 files / 0 failures; build EXIT 0 (1789 jobs, DatasetGenerator:2174 warning present); census 906/820/26; changed-line sorry grep 0; axioms 2 = baseline |
| 6 | 273 | Metalogic remainder (non-Boneyard); all 144 worklist entries dispositioned = 140 edited + 4 DEFERRED NON-COMMENT string literals (`Saturation.lean:855/856/865/866`); 48 changed files; territory LIVE recount 0; non-Boneyard `Metalogic/` residual is exactly 14 = 10 sorry-line DEFERRED (8 carried from Phases 4-5 + NEW `Transfer.lean:1179`/`:1274`) + the 4 string literals; --check-diff 48 files / 0 failures; build EXIT 0 (1789 jobs); census 906/820/26; changed-line sorry grep 0; axioms 2 = baseline; vacuous count 1 = pre-existing baseline (`Examples/TemporalStructures.lean:269`, outside territory) |
| 7 | 16 | non-Metalogic live (`Automation/`, `Syntax/`, `Theorems/`, `ProofSystem/`) + ALL Boneyard remainder; 266 worklist entries dispositioned = 264 edited + 2 DEFERRED NON-COMMENT `IO.println` literals (`EnumBenchmark.lean:175/:200`); 175 additional Boneyard lines cleared across 43 files; 69 changed files; territory LIVE recount 0; residual 16 = 14 sorry-line DEFERRED (Phase 1's floor, now fully identified — `Theorems/TemporalDerived.lean:81` was the last) + the 2 string literals; `--check-diff` 1 failure = the user-authorized `Saturation.lean` literals; build EXIT 0 (1789 jobs); census 906/820/26; axioms 2 |
| **8 (final)** | **14** | **Floor reached.** The 2 `EnumBenchmark.lean` literals edited under the user's individually-judged authorization (`:175` → `, task 204` dropped; `:200` → parenthetical dropped whole). Two plan-sanctioned comment stragglers cleaned in Phase-3 territory: `SharedWitness.lean:9-10` (loose-`specs/` paths → design-route descriptors) and `SharedWitness.lean:11516` (see the case-sensitivity finding below). Final gates: build EXIT 0 / 1789 jobs / 0 errors; census 906/820/26 exact; axioms 2; vacuous 1; declaration lines 7,316 = baseline; 430 files = baseline; `--check-diff --base c12eab1d6` = 196 files / **2** failures (the 2 authorized string-literal files, `Saturation.lean` + `EnumBenchmark.lean`); comment-stripped code identity 428/430 files byte-identical (the 2 exceptions are exactly the 6 authorized literal payloads); changed-line `sorry` grep 0; strict `specs/[0-9]{3}_[A-Za-z0-9_]+` 0; loose `specs/[0-9]{3}_` 2 (the deferred `MergedBracketQuarantine.lean:712/:713` pair, blocked by the sorry-line at `:713`) |

## Phase 8 finding: the sweep pattern is CASE-SENSITIVE and missed one reference for 7 phases

`SWEEP_RE = \b[Tt]asks?[ #-]?[0-9]{1,4}\b` matches `Task`/`task`/`Tasks`/`tasks` but **not
all-caps `TASK`**. Phase 8 ran the pattern case-insensitively (`grep -riE`) and found exactly one
line that had been invisible to every phase-1-7 worklist, `--count` run, and recount gate:

```
SharedWitness.lean:11516: -- TASK 344 dispatch 11 (R2): RIGHT pin-anchored fragment gate producer + fold.
```

It is a `--` banner comment, contains no `sorry`, and sits in Phase-3 territory, so it was
cleaned under the plan's straggler provision (→ `-- R2: RIGHT pin-anchored fragment gate producer
+ fold.`, keeping the file-local route designator per the Phase-3/4/5/6/7 convention and dropping
both the task number and the ephemeral dispatch number). Verified exhaustive: `\bTASKS?\b`
(all-caps, no digit requirement) now returns only two `WHOLE-TASK NO-GO` hits in
`MergedBracketQuarantine.lean`, which are ordinary English, not references.

Two consequences worth carrying forward:
1. **Any future de-referencing sweep must run its gate pattern case-insensitively.** A
   case-sensitive gate reporting "0" is not a proof of absence.
2. **The hook's own regex uses `grep -qiE` and would have caught this line.** That is direct
   evidence for the hook recommendation: the general-purpose advisory hook was *stricter* than
   this task's bespoke tooling on exactly the axis that mattered.

## Final pattern census (Phase 8, final tree)

| Pattern | Matches | Note |
|---|---|---|
| `\b[Tt]asks?[ #-]?[0-9]{1,4}\b` (the sweep pattern) | **14** | all 14 are sorry-lines |
| `\btasks?[ #-]?[0-9]{1,4}\b` case-insensitive | **14** | equal, post-fix — the all-caps line is gone |
| `\b[Tt]asks?[[:space:]]+[0-9]+(-[0-9]+)?\b` (current hook regex) | 13 | misses the hyphenated `task-355` at `InteriorGateGeneralK.lean:1044` |
| `\btasks?([[:space:]]+|-)[0-9]+(-[0-9]+)?\b` -i (recommended hook regex) | **14** | hyphen-aware; matches exactly the 14 sorry-lines — hence the mandatory sorry-line exemption |
| `specs/[0-9]{3}_[A-Za-z0-9_]+` (script's strict path pattern) | **0** | cleared |
| `specs/[0-9]{3}_` (loose path pattern) | **2** | `MergedBracketQuarantine.lean:712/:713`, permanently deferred |
