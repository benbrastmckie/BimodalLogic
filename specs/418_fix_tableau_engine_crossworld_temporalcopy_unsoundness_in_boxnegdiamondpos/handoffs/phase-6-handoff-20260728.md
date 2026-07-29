# Phase 6 Handoff / Continuation Pointer — Task 418

## State at dispatch end

| Phase | Status |
|---|---|
| 1 Build-reliability protocol | [COMPLETED] |
| 2 BEFORE baseline | [COMPLETED] |
| 3 The deletion | [COMPLETED] |
| 4 Library build + prose | [COMPLETED] |
| 5 `boxAnchoredCheck` finding | [COMPLETED] |
| 6 AFTER corpus measurement | **[PARTIAL]** — 6 of 8 probe modules measured |
| 7 Adjudicate and realign | [NOT STARTED] |
| 8 Acceptance gate | [NOT STARTED] |

The soundness fix is **done and green**: `lake build` (the `FormalSystem` library) exits 0 with
zero proof repairs. What remains is corpus realignment and the acceptance gate.

## Immediate next action

1. **Read `artifacts/after-corpus-raw.log`.** A `lake build BimodalTest` was left running in the
   background when this dispatch ended; the log is appended in place. Re-run it if the process
   is gone — **budget tens of minutes to hours, in the background, never a foreground timeout.**
   (A 10-minute foreground timeout already killed one attempt and dropped the olean count
   405 → 398; per the protocol that run was discarded as INCONCLUSIVE, not recorded.)
2. Extract the mismatch set for the **two** still-unmeasured modules — `TableauConformance`
   (27 rows) and `BoxNegReachabilityProbe` (12) — and append to `artifacts/after-verdicts.md` in
   the same table format as the 17 already there. Parser: each mismatch is
   `error: <file>:<line>:0: ❌️ Docstring on \`#guard_msgs\` does not match generated message:`
   followed by a `- info: <old>` / `+ info: <new>` pair. Note the preceding
   `info: <file>:<eval-line>: <actual>` line belongs to the *same* block, not the next one.
3. Then Phase 7 (adjudicate + edit the corpus), then Phase 8 (acceptance gate).

## Measurements already banked

- Corpus is **142** `#guard_msgs` directives across eight probe files, not the plan's 145.
  Per-file: `TemporalWitnessProbe` 71, `TableauConformance` 27, `BoxNegReachabilityProbe` 12,
  `RegionGateProbe` 10, `RayRegionProbe` 7, `CrossWorldPropagationProbe` 5, `BoxSpreadProbe` 5,
  `BoxNegPreservationProbe` 5. **Phase 7's `grep -c` invariant must match these, not the plan's.**
- Baseline was **fully green** — zero pre-existing failures, so every move is attributable.
- **17 moved rows measured** across 6 of 8 modules: 14 bucket (d), 3 bucket (b), **zero bucket
  (c)**. No verdict moved anywhere. Detail in `after-verdicts.md`.
- **The headline result is `BoxNegPreservationProbe` row 3**, which pinned the unsoundness
  directly (`RuleSound carrierBase .boxNeg` is false because `.boxNeg` emits a same-label
  opposite-sign pair) and now evaluates `false`. Rows 1 (`2 → 1`) and 4 (`true → false`) give the
  mechanism. This is fuel-independent evidence that the task achieved its goal.
- **`CrossWorldPropagationProbe` built green** (1363 s) — all five rows unchanged, including row B
  which is `isValid ((G p) → □(G p))`. Its *narrative* is nevertheless superseded and Phase 7 must
  rewrite it: the file's thesis is "the copy is suspect but harmless at the verdict level", and
  the copy no longer exists.
- Performance quantified: `CrossWorldPropagationProbe` 1.2 s → 1363 s (~1100×);
  `BoxNegPreservationProbe` 1048 s. The four low-fuel probe modules are 3-21 s and barely
  affected. The slow ones are exactly those calling `isValid`/`decide` on formulas that used to
  close.
- `boxAnchoredCheck` and `boxGridCheck` both `true → false`; so do `regionGate`,
  `regionLabelCheck`, `rayUpOk`/`rayDnOk`. Detail in `boxanchored-finding.md`.

## Two open risks the next dispatch must handle

### 1. Performance (the larger one)

`CrossWorldPropagationProbe` built in **1.2 s** at baseline; post-fix it, both `BoxNeg*Probe`
files and `TableauConformance` ran tens of minutes without completing. A scratch probe running
`buildTableau ((G p) → □(G p)) 1000` and `decide` on it ran **over an hour without returning**.

This is bucket (e) and it is expected in direction (fewer emitted formulas → branches stay open →
full fuel budget consumed) but it is large. If it makes the Phase 8 gate impractical, that is a
finding to record and escalate — **not** a reason to reinstate any deleted block. A legitimate
mitigation is lowering fuel in a probe row, but only with a written justification per the plan's
Phase 7 rules, and never by weakening the assertion itself.

### 2. The headline anchor row is DECIDED, and the criterion is NOT met

Measured:

```
decide: valid=false invalid=false fuelExhausted=true extractionFailed=false countermodel?=false
buildTableau 1000 = STALLED (none)
```

Plan required `.hasOpen` + `decide = .invalid` + a countermodel. **None of the three holds.**
Pre-fix was `.allClosed` / `.extractionFailed` — which by R7 semantics asserts the invalid
formula is *valid*. Post-fix is `none` / `.fuelExhausted` — honest ignorance. **A wrong answer
became no answer.** The soundness defect is gone; the positive refutation is not there.

Fuel 30, 60 and 1000 all give `none`, so the ceiling is **not bracketed from above**.

**Do not revert.** Reverting trades honest ignorance for a false claim of validity. Options, in
order of cost — full write-up in `artifacts/after-verdicts.md`:

1. Raise fuel and re-measure; establish whether `.hasOpen` is reachable at all.
2. If it never saturates, that is a **termination** question for `Verified/Termination/Fuel.lean`,
   not a budget question.
3. Accept `.fuelExhausted` as the correct current verdict and record the countermodel as owed.
   **This needs an explicit decision** — it leaves the task's stated headline goal unmet.

**Corpus gap**: `CrossWorldPropagationProbe` row B is `isValid ((G p) → □(G p))` and passes green,
but `isValid` is `true` only for `.valid`, so it reads `false` under `.invalid` and
`.fuelExhausted` alike. The corpus does not pin the distinction that matters. Adding a row that
pins the `decide` **constructor** on this formula is a justified Phase 7 addition.

## Commits

| SHA | Phase |
|---|---|
| `c2a25cfb5` | 3 — the engine fix |
| `6b2be0db8` | 4 — library green, simp pruning, bridge prose |
| `243a6cc89` | 5 — `boxAnchoredCheck` finding |
| (this dispatch's final) | 6 — partial corpus measurement, summary, handoff |

## Housekeeping

- Untracked scratch files at the repo root to delete if present: `scratch_418_probe.lean`,
  `scratch_418_anchor.lean`, `scratch_418_gp.lean`.
- Advisory lock at `.lake/.task-418-build.lock` — release it (`rm -f`) when the corpus build ends.

## Standing constraints (unchanged)

- Never run `lake clean`.
- An interrupted or olean-dropping build is INCONCLUSIVE — retry, never record.
- Do not edit `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`.
- Do not add any replacement propagation block to `applyRule`, in narrowed form or otherwise.
- Do not weaken, delete, or comment out a `#guard_msgs` row to make it pass.
- Do not attempt task 165's `RuleSound` proof.
