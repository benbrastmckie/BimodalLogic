# Phase 1 Baseline Pin and Measured Figures — Task 972

Captured at dispatch 6 (session `sess_1795489185_6c2ae6`), commit `638908e37`, on Lean
v4.33.0-rc1 with Mathlib tag `v4.33.0-rc1`.

Every figure below is labelled either **exhaustive** or **sampled**, and every timing figure is
labelled **contended**. See "Timing figures are contended, not clean" for why no wall-clock
number on this page may be read as the uncontended measurement Phase 1 asked for.

---

## 1. Gate baseline — the pre-task state of every gate this plan is judged against

| Gate | Command | Exit | Finding set at baseline |
|---|---|---|---|
| Module invariants | `bash scripts/check-module-invariants.sh --no-build` | **1** (2 check groups failed) | `C12` FAIL, `C20` FAIL — enumerated below |
| README lint | `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` | **1** | 4 new stale dates — enumerated below |
| Typst line counts | `bash scripts/typst-sync-check.sh --counts-only` | **0** | `MISMATCH_COUNT=0`; all fields match a live regeneration |
| Library index | `bash scripts/library-index.sh --no-build --check` | **0** | `BimodalLib/INDEX.md is current` |

**Both `check-module-invariants.sh` and `readme-lint.sh` are RED before this task touches
anything.** Every phase whose verification criterion reads "no NEW finding against the Phase 1
baseline" is therefore satisfied by reproducing exactly the finding set below, not by a green
exit code.

### `C12` FAIL — 2 unresolved slash-shaped source paths

```
docs/development/stability-operator-family.md:369: FormalSystem/Theorems/ProofMode/Stability.lean
docs/development/stability-operator-family.md:369: FormalSystem/Automation/ProofMode/Stability.lean
```

Both name proof-mode files. Editing `FormalSystem/Automation/ProofMode/` or
`FormalSystem/Theorems/ProofMode/` is an explicit Non-Goal of this plan, so this finding is
outside the task's file scope and is a recorded PASS for every phase.

### `C20` FAIL — 9 (path, category) pairs over their pinned ceiling

All nine are `unverifiable-file` rows under trees this task does not touch:

| Path | Live | Baseline |
|---|---|---|
| `FormalSystem/Metalogic/Expressiveness/Kamp/KMinusFaithfulRendering.lean` | 2 | 0 |
| `FormalSystem/Metalogic/Expressiveness/Kamp/KPlusFaithful.lean` | 2 | 0 |
| `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge.lean` | 1 | 0 |
| `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean` | 5 | 0 |
| `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/Base.lean` | 17 | 4 |
| `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/OuterGate.lean` | 2 | 1 |
| `FormalSystem/Metalogic/Expressiveness/PriorDefsDense.lean` | 1 | 0 |
| `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean` | 2 | 0 |
| `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/TruthTransfer.lean` | 1 | 0 |

`C35` is **PASS** at baseline (`scripts/lean-citation-manifest.json` byte-current, all 86 seeded
declarations resolve), which is what the plan's `C35` risk row needs: Phase 2 adds a new file
rather than inserting into a seeded one.

### `readme-lint.sh` — 4 new stale dates, none in this task's scope

Live stale findings: 66. Baselined in `scripts/readme-date-baseline.txt`: 63. The 4 live
findings with no baseline row are:

```
FormalSystem/Automation/ProofMode/README.md
FormalSystem/Metalogic/Conservativity/Star/README.md
FormalSystem/Tactic/README.md
FormalSystem/Theorems/ProofMode/README.md
```

Two are proof-mode trees this plan may not edit. All four are recorded PASSes.

The baseline also reports one prunable row: `PRUNE: stale
FormalSystem/Metalogic/Conservativity/README.md 2026-09-22 (no longer a live stale finding)`.
This task does not prune it.

### The grandfathering asymmetry, confirmed live

| README | Baseline row | Consequence for this plan |
|---|---|---|
| `BimodalTools/README.md` | `stale … 2026-09-27` (line 21) | stamp MUST be left byte-identical |
| `FormalSystem/ProofSystem/README.md` | `stale … 2026-09-21` (line 68) | stamp MUST be left byte-identical |
| `FormalSystem/README.md` | `stale … 2026-10-02` (line 70) | stamp MUST be left byte-identical |
| `BimodalLib/README.md` | **no row** | a commit under `BimodalLib/**` makes it stale; MUST be refreshed |
| `BimodalLib/Theorems/README.md` | **no row** | same |

`grep -n "BimodalLib" scripts/readme-date-baseline.txt` returns nothing, which is the direct
confirmation that the asymmetry the plan's risk table asserts is real.

### The `BimodalLib/Diagnostics` staleness pin — MATCH

```
git log -1 --format=%H -- BimodalLib/Diagnostics
  9dedc3977ec454a6c67d9f169df462ad414b3b74
docs/development/proof-mode-cost-baseline.md:14
  - **Measured surface commit**: `9dedc3977ec454a6c67d9f169df462ad414b3b74`
```

**MATCH.** The cost baseline is not stale at the start of this task, so Phase 5's siting
decision (emitters in `BimodalTools/`, not `BimodalLib/Diagnostics/`) has a clean pin to
preserve.

---

## 2. The four carried figures, re-confirmed live

Re-checked at this dispatch rather than taken from the plan on trust.

| Carried claim | Live check | Verdict |
|---|---|---|
| "at complexity 4 over Base it is 17 valid, 669 invalid, 120 undetermined of 806, `data/bmlogic-c4_metadata.json`" | `jq` over that file: `total_records=806`, `valid_count=17`, `invalid_count=669`, `timeout_count=120`, `frame_class=Base` | **CONFIRMED, unchanged** |
| the same figure read as the *admissible* theorem yield | same file: `decision_method_distribution.structural_prefilter = 15`, so 17 − 15 = **2** valid formulas carry a derivation | **MATERIALLY QUALIFIED, confirmed.** M19 admits only a valid formula *with* an extracted derivation. The admissible theorem yield at c4 is 2, not 17. |
| `not_valid_of_hasOpen_int` in `…/Bridge/IntTruth.lean` | present; `grep` locates `theorem not_valid_of_hasOpen_int (hV : branchOrderValid b ord = true)` at **`IntTruth.lean:1045`** | **CONFIRMED** |
| "one command … at each frame class the tableau accepts" | `ProofExtraction.lean:238` reads `| success (proof : DerivationTree .Base [] phi)` — the frame class is hard-coded | **QUALIFIED**: the theorem half cannot move off `Base`; the frame-class axis is countermodel-only |

A fifth figure the description does **not** carry: `data/exhaustive_c4_metadata.json` is a
*different* complexity-4 run reporting 13/673/120. Every figure quoted anywhere in this task
names its artifact.

### Scope Hypothesis checks for later phases, confirmed live

- `FormalSystem/ProofSystem/Axioms.lean`'s `inductive Axiom` has **20** constructors, of which
  three (`serial_future`, `discrete_box_necessity`, `dense_indicator`) are parameter-free.
  Phase 2's `Axiom.ofSubst` and Phase 4's `axiomSource` each need exactly 20 arms.
- `FormalSystem/ProofSystem/Derivation.lean`'s `inductive DerivationTree` has **7**
  constructors. Phase 2's `DerivationTree.subst` and Phase 4's `derivationSource` each need
  exactly 7 arms.
- Three of those seven rules (`necessitation`, `temporal_necessitation`, `time_reflection`)
  are stated **only at the empty context**, so the transfer needs no context coercion in those
  arms: `substCtxF σ [] = []` reduces.

Both counts match the plan's Scope Hypotheses.

---

## 3. The enumeration yield at the ruled bound

The ruled bound (`.decisions.json`, cycle 4): `Boolean` and `ModalBoolean` at complexity 5,
`TemporalBoolean` and `ModalTemporalBoolean` at complexity 4. **"Complexity N" is N
pattern-aware operator layers in `enumerateUpToDepth`'s `maxSize` measure, not N primitive
nodes.**

Probe: `specs/972_theorem_library_tableau_pipeline/probes/gate-yield-probe.lean`, atom pool
`[p, q]` (2 atoms). The fragment filter is `(BimodalLib.profileF φ).fragment = frag`
(Decision 10); `passesFilter` is never called.

| Fragment | Bound | Raw | After `deduplicateCanonical` | Surviving the `profileF` filter | Status |
|---|---|---|---|---|---|
| `Boolean` | 5 | 27 | 14 | **14** | exhaustive |
| `ModalBoolean` | 5 | 266 | 147 | **133** | exhaustive |
| `TemporalBoolean` | 4 | — | — | **not measured** | see Exclusions |
| `ModalTemporalBoolean` | 4 | — | — | **not measured** | see Exclusions |

**Divergence from the plan's Scope Hypothesis, recorded as a finding, not acted on.** The plan
expected counts "of the order of" c5 Boolean 902 and c5 ModalBoolean 751, taken from the
report's tabulation over `data/bmlogic-c{4,5}.jsonl`. The live counts are 14 and 133. The
cause is the **atom pool**, not the filter: this probe runs at 2 atoms while the dataset
tabulation ran at a wider pool, and the enumeration is superexponential in pool size. Per the
plan, a divergence here "is a finding about the filter, not a reason to change the bound", and
the bound is unchanged. Phase 6 must make the atom pool an explicit, recorded parameter of the
command, because the yield figure is meaningless without it.

---

## 4. The four-way DECIDE split at `Base`

`decideAuto φ .Base` over the surviving set. Both fragments below fit the 150-formula cap, so
these are **exhaustive over the cell at a 2-atom pool**, not sampled.

| Fragment | Sample | `valid` | `invalid` | `fuelExhausted` | `extractionFailed` |
|---|---|---|---|---|---|
| `Boolean` | 14 of 14 (exhaustive) | 1 | 11 | 2 | 0 |
| `ModalBoolean` | 133 of 133 (exhaustive) | 10 | 71 | 26 | 26 |

**These counts reproduced exactly across two independent runs** of the probe (the timings did
not: 35 ms vs 41 ms for `Boolean`, 38252 ms vs 36071 ms for `ModalBoolean`). That is direct
evidence for Phase 6's determinism criterion — the verdicts are a pure function of the input,
and only the timing fields need zeroing to make two `--json` runs byte-identical.

**`extractionFailed` is a first-class outcome, not a rounding error.** At `ModalBoolean` c5 it
is 26 of 133 — as large as `fuelExhausted`, and larger than `valid`. Of the 10 `valid`
verdicts, all 10 carry a derivation; the 26 `extractionFailed` formulas are valid (the tableau
closed) but have no `⊢ φ` witness and so are **never admissible**. This is the live,
fragment-level confirmation of the 2-of-17 correction in section 2: the admissible theorem
yield is the `valid` count alone, and `valid + extractionFailed` is what a naive reading of a
dataset's "valid" column would give. Decision 7's insistence that the records keep
`DecisionResult`'s own four names rather than `FormulaLabel`'s three is load-bearing precisely
here.

---

## 5. The eight-gate pass rate, per (fragment, frame class)

`evalBranchGates φ fc` over the `invalid` verdicts. Columns are per-gate counts of `true`:
`tot`=`timeOrderTotal`, `box`=`boxAnchored`, `rgn`=`regionLabel`, `twit`=`temporalWitness`,
`ordV`=`branchOrderValid`, `sat`=`saturated`, `noCl`=`noClosure`, `root`=`rootDenied`,
`GATED`=the conjunction.

### `Boolean`, complexity 5 — gate sub-sample 11 of 11 invalid (EXHAUSTIVE)

| fc | eval | none | tot | box | rgn | twit | ordV | sat | noCl | root | **GATED** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `Base` | 11 | 0 | 11 | 11 | 11 | 11 | 11 | 11 | 11 | 11 | **11** |
| `Dense` | 11 | 0 | 11 | 11 | 11 | 11 | 11 | 11 | 11 | 11 | **11** |
| `ZTime` | 11 | 0 | 11 | 11 | **0** | **0** | 11 | 11 | 11 | 11 | **0** |
| `RTime` | 11 | 0 | 11 | 11 | 11 | 11 | 11 | 11 | 11 | 11 | **11** |

### `ModalBoolean`, complexity 5 — gate sub-sample 25 of 71 invalid (SAMPLED, fixed stride)

| fc | eval | none | tot | box | rgn | twit | ordV | sat | noCl | root | **GATED** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `Base` | 25 | 0 | 25 | 15 | 10 | 10 | 25 | 25 | 25 | 25 | **7** |
| `Dense` | — | — | — | — | — | — | — | — | — | — | **not measured** |
| `ZTime` | — | — | — | — | — | — | — | — | — | — | **not measured** |
| `RTime` | — | — | — | — | — | — | — | — | — | — | **not measured** |

A first run of the probe evaluated all 71 `ModalBoolean` invalid verdicts at `Base` and is a
cross-check on the stride sample's representativeness:

| Source | eval | box | rgn/twit | GATED | GATED rate |
|---|---|---|---|---|---|
| run 1, all 71 | 71 | 44 | 30 | 24 | 0.34 |
| run 2, stride 25 | 25 | 15 | 10 | 7 | 0.28 |

The sub-sample tracks the full cell within a few points on every column, so the stride sample
is representative and the `25`-formula gate rows may be read as estimates of the cell.

### The `ZTime` disagreement check — AGREES

The plan requires the `ZTime` row to be checked against `TableauBridge.lean`'s own recorded
measurement that `regionLabel` and `temporalWitness` come back `false` there, and any
disagreement recorded as a finding. **There is no disagreement**: at `ZTime` both gates are 0
of 11 and `GATED` is consequently 0 of 11, while every other gate passes 11 of 11.

**This is the single most consequential figure on this page.** The eight-gate route to a
certified refutation is **unavailable at `ZTime`**, not merely rare — it fails on every
formula, for a structural reason, in the fragment where the gates are otherwise unanimous. The
task description's two-route admission rule is therefore not two parallel routes with a
preference: at `ZTime` the witness-family certificate accepted by `decidableCertifies` is the
**only** route, and Phase 6 must not treat a `ZTime` `gated = false` as a surprise to be
retried.

---

## 6. The marginal cost of gating

| Fragment | DECIDE alone | Per formula | Gating, 4 frame classes | Per (formula, class) |
|---|---|---|---|---|
| `Boolean` (14 formulas, 11 invalid) | 41 ms | 2 ms | 0 ms | 0 ms |
| `ModalBoolean` (133 formulas, 71 invalid) | 36071 ms | 271 ms | `Base` 0 ms; `Dense`/`ZTime`/`RTime` not measured | — |

### Timing figures are contended, not clean

The plan's mitigation for timing contamination was to take the measurement once under the
shared `.lake/build-guard.lock`. **That mitigation is insufficient, and this dispatch measured
why.** The lock serializes `lake` invocations only. The contention during both runs came from
a sibling dispatch's `run-all.sh --jobs auto` shell test sweep over ~120 suites (pid 2935696)
plus several concurrent `claude` processes — none of which take the `lake` lock. Load average
was 6.45 and then 5.32 on 24 cores.

The direct evidence that this contaminates timings: two runs of the *same* probe on the *same*
commit gave `ModalBoolean` DECIDE as 38252 ms and 36071 ms, while every count reproduced
exactly. **No wall-clock figure on this page may be presented as uncontended.** Counts may.

A correction worth recording against a wrong first diagnosis: the `0 ms` gate figures were
initially read as a lazy-accumulation artifact. They are not. The DECIDE stage uses the
identical `List.foldl`-over-a-`Nat`-structure shape and reports nonzero times, so the fold is
strict and the timed window does capture the tableau rebuilds. `Base` gating on these formulas
is genuinely sub-millisecond. The real shape of the cost is an **asymmetry across frame
classes**, not a measurement bug.

### What the cost asymmetry means for Phase 6's defaults

Gating is free at `Base` and free at every frame class on `Boolean`. It becomes the dominant
cost at `Dense` on a modal fragment: run 1 did not finish the four `ModalBoolean` gate rows in
nine minutes of wall clock, and run 2's `lean` process reached **2.8 GB RSS** at 100% CPU with
`earlyoom` on this machine configured `--prefer ^(lean|lake|claude|node|npm|opencode)$` — i.e.
preferentially killing `lean` under memory pressure. Phase 6 must therefore:

1. make the frame-class list an explicit flag with `Base` as the only default, not gate all
   four classes by default;
2. make the atom pool an explicit, recorded parameter (section 3);
3. carry a `--deadline-s` and `--checkpoint` as real requirements rather than conveniences,
   because a `Dense` gate pass over a modal fragment is a plausible OOM, not just a slow run.

---

## 7. Provenance

- Probe run **twice**, each time as a single launch with the PID recorded to a file *before*
  any wait, one waiter per log, blocked on with a bounded `kill -0` loop. No run was ever
  double-launched.
- Run 1 was stopped deliberately after its `ModalBoolean` `Base` gate row: its `gate_ms` column
  was under a wrong diagnosis at the time, and it gated all 71 invalid verdicts, which does not
  finish. Its log is retained as the representativeness cross-check in section 5.
- Run 2 added the `gateCap = 25` sub-sample and was stopped after its `ModalBoolean` `Base`
  row for the cost reason in section 6.
- Reproduce with:
  ```
  flock .lake/build-guard.lock lake env lean --run \
    specs/972_theorem_library_tableau_pipeline/probes/gate-yield-probe.lean
  ```

## 8. Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `ModalBoolean` gate rows at `Dense`, `ZTime`, `RTime` | Gate evaluation at `Dense` on a modal fragment is the dominant cost of the whole pipeline and does not complete under batch contention; the run reached 2.8 GB RSS at 100% CPU with `earlyoom` set to prefer killing `lean` | run 1 did not finish these four rows in 9 min; section 6 |
| `TemporalBoolean` and `ModalTemporalBoolean` entirely (enumerate, decide, gates) | Same cost wall, reached before these fragments were started | sections 3–6 |
| An uncontended timing figure | The `.lake/build-guard.lock` mitigation does not serialize the non-`lake` sibling sweep that caused the contention | 38252 ms vs 36071 ms for identical input; section 6 |

None of these exclusions blocks a later phase. Phase 6's three defaults are decided by the
figures that *were* measured — the `ZTime` gate collapse, the `Base`-vs-`Dense` cost asymmetry,
and the atom-pool sensitivity of the yield — and each excluded row would refine a default
already chosen, not change it.
