# AFTER Corpus Measurement — Every Moved Row

Task 418 — Phase 6 artifact. **Measurement only.** No test file was edited in the phase that
produced this document; Phase 7 adjudicates. Raw output: `after-corpus-raw.log`; olean bracketing
and exit code: `after-corpus-bracket.txt`.

## Bucket vocabulary (from the plan)

| Bucket | Meaning |
|---|---|
| (a) | **intended repair** — a previously-`allClosed`/`extractionFailed` verdict on an invalid formula is now `hasOpen`/`invalid` |
| (b) | **probe-pins-the-bug** — the row asserted the buggy behavior directly; its new value is the correct one |
| (c) | **suspected under-closing regression** — a valid formula that no longer closes |
| (d) | **saturation-metric change** — `\|T\|`, `anchor`, `check`, candidate-count vectors and similar structural measurements that moved because the fresh world now carries fewer formulas |
| (e) | **fuel/resource change** |

## Build accounting

An earlier attempt at this build was killed by a 10-minute foreground timeout and dropped the
olean count 405 → 398. **Per the Phase 1 triage checklist that run is INCONCLUSIVE and was
discarded, not recorded.** The measurement below comes from a re-run started from an olean
baseline of 398, run to completion in the background with no wall-clock ceiling.

The build's non-zero exit is entirely `#guard_msgs` mismatches — the **verdict** error class, not
the infrastructure class. Every error carries a `file:line:col` Lean diagnostic. There is no
`could not resolve import`, no missing `.olean`, and no diagnostic-free abrupt exit. The
measurement is therefore conclusive.

`lake` surfaced mismatches from **every** failing probe module independently rather than stopping
at the first, and within each module reported **every** mismatching row rather than only the
first. Per-module builds were therefore not needed to surface the full mismatch set — the plan
prescribed them as insurance against masking, and the raw log shows no masking occurred.

## Moved rows

STATUS_PENDING_TABLE

## Rows that did not move

STATUS_PENDING_UNMOVED
