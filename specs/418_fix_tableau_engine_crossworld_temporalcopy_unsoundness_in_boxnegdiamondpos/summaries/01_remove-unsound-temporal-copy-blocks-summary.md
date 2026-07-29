# Implementation Summary: Task 418 — Remove the Unsound Cross-World Temporal Copies

- **Task**: 418 — fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos
- **Plan**: `plans/01_remove-unsound-temporal-copy-blocks.md`
- **Status**: Phases 1-8 [COMPLETED]. Acceptance gate **GREEN** — `lake build` RC 0 and
  `lake build BimodalTest` RC 0 in one locked window, zero `#guard_msgs` mismatches across all
  143 directives. The soundness fix landed and the corpus is realigned; **the plan's headline
  acceptance criterion is measured and NOT met**, recorded as bucket (e) and triaged for an
  explicit human decision (see "The anchor result").
- **Session**: `sess_1785302672_d06f95`

## What was done

Six `let` blocks in each of `applyRule`'s `.boxNeg` and `.diamondPos` arms copied
temporal-universal and temporal-existential signed formulas verbatim from the current branch into
the freshly minted `□`/`◇`-witness world. `T(Gφ)` says φ holds along *this* history's future —
exactly what `□`/`◇` quantify over, and therefore exactly what may not be assumed of an
alternative world. All twelve blocks, both `temporalProps` assemblies, and both
`++ temporalProps` result-list suffixes are deleted. Each rule now emits
`.linear (witness :: boxProps ++ diaProps)`.

| Phase | Status | Outcome |
|---|---|---|
| 1 — build-reliability protocol | [COMPLETED] | Advisory lock convention established (none existed); environment snapshot; infra-vs-verdict triage checklist |
| 2 — BEFORE baseline | [COMPLETED] | Both builds green, RC 0; **corpus is 142 directives, not the plan's 145** |
| 3 — the deletion | [COMPLETED] | `Tableau.lean` edited; scoped build green |
| 4 — library build + prose | [COMPLETED] | `lake build` green with **zero** proof repairs needed |
| 5 — `boxAnchoredCheck` finding | [COMPLETED] | Measured, carrier list re-derived, handed to task 165 |
| 6 — AFTER corpus measurement | [COMPLETED] | All 8 modules measured; **22 of 142 rows moved** |
| 7 — adjudicate and realign | [COMPLETED] | All 22 rows realigned with per-row justification; 1 row added; 6 narratives rewritten |
| 8 — acceptance gate | [COMPLETED] | **`LIBRARY_RC=0`, `CORPUS_RC=0`, 0 mismatches**; oleans 399 → 405 (increase = completed build); zero infrastructure-class errors |

## The headline result

`Tests/BimodalTest/BoxNegPreservationProbe.lean` row 3 was written to measure the unsoundness
directly, at the `applyRule` level. Its docstring read:

> *"This is the measurement. A branch containing both is unsatisfiable outright, so the successor
> of a satisfiable branch is unsatisfiable and `RuleSound carrierBase .boxNeg` is false."*

It evaluated `true` before the fix. **It now evaluates `false`** — applying `.boxNeg` to that
branch no longer manufactures a same-formula/same-label/opposite-sign pair. Rows 1 and 4 give the
mechanism: `emitted.length` moved `2 → 1` and "the emitted set contains a `T(G p)` that was
standing at another world" moved `true → false`. The rule now emits the witness alone.

**And the same repair, measured independently from the reachability side**:
`BoxNegReachabilityProbe.lean` row 7 moved `(1, 0) → (1, 1)` — *the one branch the engine actually
reaches went from closed to open*. Row 8 moved `some (1, 1, 0) → none`, confirming that nothing
else closes it either, which rules out the reading that some other rule silently took over the
closure. The engine was closing a branch it had no grounds to close, and it no longer does.

Both results are independent of any fuel budget or search-depth question. That matters, because
the fuel-dependent result below is the one that fell short.

## Before/after verdict-change table

**Twenty-two rows moved, out of 142, across five of the eight probe files.** Every value is quoted
from Lean's own `- info:` / `+ info:` diff pairs. Per-row justification in
`artifacts/after-verdicts.md`.

| # | Probe row / formula | Old verdict | New verdict | Bucket |
|---|---|---|---|---|
| 1 | `RayRegionProbe` D — `(□p ∧ ◇q) → r` | `check=true rayUp=true rayDn=true rays=[(2,2),(5,5)]` | `check=false rayUp=false rayDn=false rays=[(2,2),(0,0)]` | (d) |
| 2 | `BoxSpreadProbe` A — `(□p ∧ ◇q) → r`, `.Base` | `anchor=true grid=true \|T\|=7` | `anchor=false grid=false \|T\|=7` | (d) |
| 3 | `BoxSpreadProbe` B — `(□p ∧ ◇(G q)) → r` | `anchor=true grid=true \|T\|=7` | `anchor=false grid=false \|T\|=7` | (d) |
| 4 | `BoxSpreadProbe` C — `(□p ∧ ◇q) → r`, `.Dense` | `anchor=true grid=true \|T\|=10` | `anchor=false grid=false \|T\|=8` | (d) |
| 5 | `RegionGateProbe` A | `gate=true check=true cands=[[3×8],[3×8]]` | `gate=false check=false cands=[[3×8],[0×8]]` | (d) |
| 6 | `RegionGateProbe` B | `gate=true check=true cands=[[3×8],[3,3,3,3,1,1,1,1]]` | `gate=false check=false cands=[[3×8],[0×8]]` | (d) |
| 7 | `RegionGateProbe` C (`.Dense`) | `\|T\|=10 gate=true check=true cands=[[3×11],[3×11]]` | `\|T\|=8 gate=true check=true cands=[[3×9],[1×9]]` | (d) |
| 8 | `RegionGateProbe` H (`.Dense`) | `gate=true check=true cands=[[3×11],[3,3,3,3,1×7]]` | `gate=false check=false cands=[[3×11],[0×11]]` | (d) |
| 9 | `TemporalWitnessProbe` D `:408` (`probe`) | `check=true … rP=true` (U and S) | `check=false … rP=false` (U and S) | (d) |
| 10 | `TemporalWitnessProbe` D `:521` (`probe2`) | `D check=true uNAR=true sNAR=true` | `D check=false uNAR=true sNAR=true` | (d) |
| 11 | `TemporalWitnessProbe` D `:629` (`probe3`) | `D gen=false check=true …` | `D gen=false check=false …` | (d) |
| 12 | `TemporalWitnessProbe` D `:775` (`probe4`) | `D gen=false check=true …` | `D gen=false check=false …` | (d) |
| 13 | `TemporalWitnessProbe` D `:927` (`probe5`) | `D gen=false check=true …` | `D gen=false check=false …` | (d) |
| 14 | `TemporalWitnessProbe` D `:1085` (`probe6`) | `D gen=false check=true uPR=true [self=true …]` | `D gen=false check=false uPR=false [self=false …]` | (d) |
| 15 | `BoxNegPreservationProbe` 1 — `emitted.length` | `2` | `1` | **(b)** |
| 16 | `BoxNegPreservationProbe` 3 — opposite-sign clash | `true` | `false` | **(b)** |
| 17 | `BoxNegPreservationProbe` 4 — copied `T(G p)` present | `true` | `false` | **(b)** |
| 18 | `BoxNegReachabilityProbe` 6 — clash at minted world | `true` | `false` | **(b)** |
| 19 | `BoxNegReachabilityProbe` 7 — `(reached.length, #open)` | `(1, 0)` | `(1, 1)` | **(b)** |
| 20 | `BoxNegReachabilityProbe` 8 — closure reason | `some (1, 1, 0)` | `none` | **(b)** |
| 21 | `BoxNegReachabilityProbe` 9 — `buildTableau … 1000` | `(1, 1)` = `.allClosed` | `(0, 0)` = fuel-exhausted | **(e)** |
| 22 | `BoxNegReachabilityProbe` 10 — `decide` 5-tuple | `(false,false,false,true,false)` | `(false,false,true,false,true)` | **(e)** |

**Rows that did not change, in aggregate: 120 of 142.** Per file — `TemporalWitnessProbe` 65/71,
`TableauConformance` **27/27**, `BoxNegReachabilityProbe` 7/12, `RegionGateProbe` 6/10,
`RayRegionProbe` 6/7, `CrossWorldPropagationProbe` 5/5, `BoxSpreadProbe` 2/5,
`BoxNegPreservationProbe` 2/5.

| Bucket | Count | Reading |
|---|---|---|
| (a) intended repair, fully landed | **0** | rows 21-22 move in this direction but land in (e) |
| (b) probe-pins-the-bug | **6** | rows that asserted the defect directly and now assert its absence |
| (c) under-closing regression | **0** | **none, corpus-wide** |
| (d) saturation-metric change | **14** | branch gates that were computing `true` *because of* the unsound copies |
| (e) fuel/resource change | **2** | the anchor row |

**No bucket-(c) regression exists anywhere in the corpus, and this is now a strong statement
rather than a provisional one.** `TableauConformance` is the only module that pins
`CLOSED`/`OPEN`/`STALLED` verdicts directly, across `.Base`/`.Dense`/`.Discrete`/`.Dedekind`, and
is therefore exactly where an under-closing regression on a *valid* formula would surface. All 27
of its rows are unmoved.

The fourteen bucket-(d) rows deserve one sentence of interpretation: every one was computing
`true` *because of* the unsound copies. **The corpus was measuring the bug and reporting it as
health.** That is the strongest available argument that these rows moved for the right reason.

## The anchor result — measured, and the plan's headline criterion is NOT met

| Criterion | Plan required | Measured | Met? |
|---|---|---|---|
| `buildTableau ((G p) → □(G p)) 1000 .Base` | `.hasOpen` | fuel-exhausted (`none`) | **NO** |
| `decide` constructor | `.invalid` | `.fuelExhausted` | **NO** |
| `getCountermodel?.isSome` | `true` | `false` | **NO** |

| | Pre-fix | Post-fix |
|---|---|---|
| `buildTableau … 1000` | `.allClosed` | fuel-exhausted |
| `decide` | `.extractionFailed` | `.fuelExhausted` |
| What the procedure claims | **"φ is valid"** — false; φ is invalid | **"undetermined"** |

**The soundness defect is gone.** By this codebase's own R7 semantics (`DecisionProcedure.lean`),
`extractionFailed` means *the tableau closed, so the formula is valid, we just could not rebuild
the proof term* — `isKnownValid` is true of it. That was a false assertion about an invalid
formula. `fuelExhausted` is the only constructor `isUndecided` recognises. The procedure moved
from **a wrong answer to no answer**, which is the direction that matters for soundness.

**But the intended repair did not land.** The plan wanted the engine to positively refute the
formula with an extracted countermodel. It does not reach saturation within fuel 1000 — fuel 30,
60, 400 and 1000 all agree, so the ceiling is **not bracketed from above**. This is bucket (e).

Per the plan's Rollback/Contingency section this is recorded and triaged, **not** repaired by
reinstating a deleted block: reverting would trade honest ignorance for a false claim of validity,
which is strictly worse. Three options, none performed here:

1. **Raise the fuel and re-measure.** Cheapest; establishes whether `.hasOpen` is reachable at all.
2. **Investigate why the branch does not saturate.** If a rule now fires unboundedly on this
   shape, that is a termination question for `Verified/Termination/Fuel.lean`'s bounds, not a
   budget question.
3. **Accept `.fuelExhausted` as the correct current verdict** and record the countermodel as owed.
   Defensible — the procedure is sound and honest — but it leaves the task's stated headline goal
   unmet, so **it needs an explicit decision rather than a default.**

**This choice is a human decision and is deliberately left open.**

## A corpus gap that was found and closed

`CrossWorldPropagationProbe`'s five rows all call `isValid`, which is `(decide φ).isValid` and so
`true` only for `.valid`. Every one reads `false` under `.invalid`, `.fuelExhausted` and
`.extractionFailed` alike. Row B is `isValid ((G p) → □(G p))` — the anchor formula — and it
**passed green across the entire fix without moving**, because its `false` meant
`extractionFailed` before and `fuelExhausted` now.

The corpus therefore could not detect the outcome that matters most to this task. **Row F was
added** to pin the `decide` constructor directly on that formula. It is an addition, not a
weakening: it strictly increases what the corpus detects, and what it pins is the task's *unmet*
criterion. The day this formula becomes `.invalid`-with-countermodel, row F fails loudly instead
of the change passing unnoticed.

## Performance — a material cost, now quantified

| Module | Baseline | Post-fix | Factor |
|---|---|---|---|
| `CrossWorldPropagationProbe` | **1.2 s** | **1363 s** | **~1100×** |
| `BoxNegReachabilityProbe` | cached at baseline | **3437 s** (~57 min) | — |
| `BoxNegPreservationProbe` | cached at baseline | **1048 s** (~17 min) | — |
| `RayRegionProbe` / `BoxSpreadProbe` / `RegionGateProbe` / `TemporalWitnessProbe` | cached | 3.3 s / 7.8 s / 12 s / 21 s | negligible |
| `TableauConformance` | — | unmoved, trace current | — |

The slow modules are exactly those whose rows run `isValid`/`decide` on formulas that used to
close and now do not. `BoxNegReachabilityProbe`'s 3437 s is four independent fuel-1000 searches on
`(G p) → □(G p)` (`decide`'s default `tableauFuel` is also 1000), ≈ 860 s each — consistent with
`BoxNegPreservationProbe`'s 1048 s for one and `CrossWorldPropagationProbe`'s 1363 s for three.
The four fast modules call `buildTableau` at explicit low fuel (200) and are barely affected.

This is the plan's risk-asymmetry argument surfacing as wall-clock: removing emitted formulas
shrinks a branch's contradiction surface, so branches that used to close now stay open and the
search runs the whole budget instead of terminating early. It is the expected direction and a
cost, not a soundness problem — but **a full corpus build must now be budgeted in hours, run
detached, and never in a foreground window that can time out.** Doing so once already destroyed a
run and dropped the olean count 405 → 398.

## The `boxAnchoredCheck` finding — handoff to task 165

Full write-up: `artifacts/boxanchored-finding.md`.

`boxAnchoredCheck` computed `true` on multi-world branches only because of the deleted blocks; it
now computes `false`. **`boxGridCheck` — the conclusion the truth lemma's `box` case actually
consumes — collapses too**, which the plan did not predict and which closes the "just prove the
grid directly" repair route. The corpus measurement shows the *whole family* of decidable branch
gates going false on minted worlds: `regionGate`, `regionLabelCheck`, `rayUpOk`/`rayDnOk` as well.
A repair aimed only at `BoxAnchored` would leave the region-label and ray families still false.

Nothing breaks at typecheck. All 14 carrier lemmas (4 in `BoxSaturation.lean`, 6 in
`IntTruth.lean`, 5 in `DenseTruth.lean` — one plan-listed line is not a carrier and one carrier
the plan missed) take the check as a hypothesis they never unfold, and the library build is green
with zero repairs. What is lost is *dischargeability by computation on real engine output*. Three
repair options are sketched with their soundness obligations; none is implemented, deliberately.

**The corpus now pins this gap rather than the bug**, so task 165 inherits a decision instrument:
options (a)/(b) would move the whole bucket-(d) family back in one commit and the corpus would say
so row by row; option (c) must instead justify each row individually.

## Constraints honored

- **`Verified/Decidable.lean` was not modified.** Confirmed absent from `git diff --name-only`.
- **The `RuleSound` proof was not attempted.**
- **No replacement propagation block was added.** `git diff c2a25cfb5 HEAD -- Tableau.lean` is
  empty at every later phase boundary, re-verified at the start and end of this dispatch.
- **No `sorry`, no vacuous definition, no new axiom.** The `Verified/` tree still has zero
  term-level `sorry`.
- **No `#guard_msgs` block was deleted, commented out, or weakened.** `git diff Tests/` shows
  **0** removed `#guard_msgs` directives and **0** altered `#eval` expressions — 22 expectations
  changed, 1 row added. No per-file directive count fell.
- **No fuel level was lowered in any probe row.**
- **`lake clean` was never run.**

## Corrections to the plan, recorded rather than suppressed

1. The corpus is **142** `#guard_msgs` directives, not 145. Three of the plan's grep hits are
   prose mentions (`TableauConformance` ×2, `RayRegionProbe` ×1). The Phase 7 invariant must be
   taken over `^#guard_msgs in`, not `#guard_msgs`.
2. Phase 4 predicted zero compile-time repairs. **Confirmed exactly** — 1983 jobs, zero errors.
3. `boxGridCheck` collapses alongside `boxAnchoredCheck`.
4. `TemporalWitnessProbe` row D moved at **six** sites, not the predicted five.
5. The plan's Phase 3 check `grep -n 'witness :: boxProps ++ diaProps'` "returns exactly two
   lines" now returns **three**; the third is a docstring mention added by this task. The precise
   invariant is `grep -cE '^\s*\(\.linear \(witness :: boxProps \+\+ diaProps\), timeOrd\)'` **= 2**.
6. The plan predicted `BoxNegReachabilityProbe` rows 6-12 would move. **Measured: rows 6-10 moved,
   rows 11-12 did not** — and their not moving is substantive, since they are the countermodel
   rows and the countermodel is exactly what is still owed.
7. `TableauConformance` was predicted to be a likely mover (27 rows, four frame classes).
   **Measured: zero moved.** Twenty-five of its rows contain no `□`/`◇` at all, so
   `boxNeg`/`diamondPos` never fire; the one modal row (`certProbe diaP`) fires `diamondPos` and
   still did not move.

## Plan Deviations

- Phase 4's prose rewrite of `sat_box_grid_of_anchored`'s docstring was performed during Phase 5
  *(deviation: altered — the stale sentence was only identified while re-deriving the carrier
  list in Phase 5; a scoped rebuild confirmed green before the Phase 5 commit)*.
- Phase 6's per-module builds were not run separately for the six modules the full-corpus build
  already surfaced *(deviation: skipped — `lake build BimodalTest` surfaced every failing module
  independently and every mismatching row within each module, so the masking insurance was
  demonstrably unnecessary; the final two modules WERE built scoped, as the plan prescribed)*.
- Phase 6's AFTER corpus run was split across two builds *(deviation: altered — a full-corpus run
  plus a scoped two-module run, each bracketed by olean counts (399/399) with zero
  infrastructure-class errors; both logs retained)*.
- Phase 6's anchor-row criterion *(deviation: altered — measured and **NOT met**; recorded as
  bucket (e) and triaged rather than repaired, per the plan's Rollback/Contingency section)*.
- Phase 7 added one `#guard_msgs` row *(deviation: altered — `CrossWorldPropagationProbe` row F,
  raising that file's count 5 → 6 and the corpus 142 → 143. The plan's "counts match the baseline
  exactly" criterion is an anti-weakening guard; the invariant that holds is that **no count
  fell**. Justified in `after-verdicts.md`.)*
- Phase 8's corpus build serves as both Phase 7's re-run-to-green and Phase 8's acceptance gate
  *(deviation: altered — no source edit occurs between the two, so a single build satisfies both;
  stated explicitly rather than claimed as two independent gates)*.

## Artifacts

| Path | Contents |
|---|---|
| `artifacts/build-environment.md` | lock protocol, environment snapshot, triage checklist |
| `artifacts/baseline-build.log`, `baseline-corpus.log` | BEFORE builds, both RC 0 |
| `artifacts/baseline-verdicts.md`, `baseline-rows-raw.md` | all 142 rows with expected values |
| `artifacts/boxanchored-finding.md` | measurement, mechanism, 14-carrier list, repair options, §7 corpus-side addendum |
| `artifacts/after-corpus-raw.log`, `after-corpus-2mod.log` | AFTER build output, both parts |
| `artifacts/after-corpus-bracket.txt`, `phase6b-bracket.txt`, `phase6b-olean-before.txt` | olean bracketing |
| `artifacts/after-verdicts.md` | per-row moved/unmoved record, bucket classification, Phase 7 adjudication |
| `artifacts/rescued/` | scratch measurements recovered from a stopped dispatch, now corroborated |
| `artifacts/acceptance-build.log` | the final gate |
| `handoffs/` | recovery points |

## Modified source files

- `FormalSystem/Metalogic/Decidability/Tableau.lean` — the fix
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` — pruned six
  inert accessor names from two `simp only` lists
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/BoxSaturation.lean` — prose
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` — the O3 status block
- `Tests/BimodalTest/{BoxNegPreservationProbe, BoxNegReachabilityProbe, BoxSpreadProbe,
  CrossWorldPropagationProbe, RayRegionProbe, RegionGateProbe, TemporalWitnessProbe}.lean` —
  22 expectations realigned, 1 row added, 6 narratives rewritten from present to past tense
- **NOT** `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`

## What task 165 inherits

Its blocker is cleared: `RuleSound carrierBase .boxNeg` is now a *true* statement, measured as
such at the rule level (`BoxNegPreservationProbe` row 3) and at the reachability level
(`BoxNegReachabilityProbe` rows 6-8). This task makes that statement true; it does not prove it.

Two open items travel with it: the `boxAnchoredCheck` gate family, and the owed countermodel for
`(G p) → □(G p)`.

## The acceptance gate

Run detached (`setsid nohup`), no wall-clock ceiling, in a single locked window with no source
edit between the two steps — so this one run serves as both Phase 7's re-run-to-green and Phase
8's gate, stated explicitly rather than claimed as two independent gates.

```
=== GATE STEP 1: lake build (FormalSystem library) ===   LIBRARY_RC=0
=== GATE STEP 2: lake build BimodalTest (full corpus) === CORPUS_RC=0
mismatch rows: 0
```

| Probe module | Gate result | Time |
|---|---|---|
| `RayRegionProbe` | ✔ built | 3.0 s |
| `BoxSpreadProbe` | ✔ built | 5.6 s |
| `RegionGateProbe` | ✔ built | 9.7 s |
| `TemporalWitnessProbe` | ✔ built | 17 s |
| `BoxNegPreservationProbe` | ✔ built | 980 s |
| `CrossWorldPropagationProbe` | ✔ built | 2185 s |
| `BoxNegReachabilityProbe` | ✔ built | 3649 s |
| `BimodalTest` (root) | ✔ built | 1.1 s |
| `TableauConformance` | trace current, unmoved | — |

**Conclusiveness**: oleans **399 → 405** — an *increase*, consistent with a build that ran to
completion (the six realigned modules plus the root emitted fresh `.olean`s). Zero
infrastructure-class errors in the log: no `could not resolve import`, no missing `.olean`, no
diagnostic-free abrupt exit. The gate is a pass, not an interrupted run recorded as one.

### Final verification census

| Check | Result |
|---|---|
| `#guard_msgs` mismatches | **0** across 143 directives |
| term-level `sorry` introduced | **0** — repo-wide count 1075 → 1075, unchanged; the one `Verified/` grep hit is the word `sorry` inside a docstring |
| axioms introduced | **0** — count 2 → 2, unchanged; both hits are prose lines in `Boneyard/` beginning with the word "axiom", not declarations |
| vacuous definitions introduced | **0** — the two `:= trivial` hits (`int_domain_universal`, `domainProof0`) are pre-existing, are genuine proofs of total-domain propositions, and sit in files this task never touched |
| `Verified/Decidable.lean` in diff | **absent** |
| `Tableau.lean` vs Phase 3 | **byte-identical** (`git diff c2a25cfb5 HEAD` empty) |
| emit-site invariant | exactly **2** `(.linear (witness :: boxProps ++ diaProps), timeOrd)` |
| `#guard_msgs` directives removed | **0**; `#eval` expressions altered | **0** |

Eleven files changed in total across the whole task: four under `FormalSystem/` and seven probe
modules under `Tests/`. No file outside the declared scope.
