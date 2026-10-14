# Implementation Summary: Task #716

- **Task**: 716 - Profile and fix the PlusSlicedCertificate liveT/liveAt non-termination that blocks Tier-2 sliced certificate witnesses
- **Status**: [COMPLETED]
- **Started**: 2026-10-13T10:15:00Z
- **Completed**: 2026-10-13T18:05:00Z
- **Effort**: ~9 hours
- **Dependencies**: None
- **Artifacts**: plans/02_shape-d-verts-biunion.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All nine phases are complete. The defect is fixed: `#eval (certA.liveAt 0).card` — the
computation that did not return within 300 s compiled on four positions and four window times,
which is why this task exists — now returns `4` in **2951 ms**, and the strictly larger `certB`'s
returns `4` in 22585 ms. The sliced certificate class carries **two** new interesting witnesses
(`certA` at a `snce`-kind closure, `certB` at an `untl`-kind one, both width 2 with a total edge
relation), each a kernel-`decide` closed-term theorem with its C36 inventory row and matched C2
axiom pin. Three recomputation faults in the shipped liveness decision procedure are removed
behind unconditional equality lemmas, and a heartbeat-capped guard now fails the build if the
cost returns. No statement anywhere was weakened, no `sorry`, no new axiom.

The diagnosis the research report settled — missing memoization, not an algorithmic defect and
not intrinsic cost — is confirmed and sharpened. Two sharpenings matter beyond this task. First,
`#eval` figures systematically overstate what transfers to the kernel, and the three fixes behave
quite differently on the two evaluators. Second, the *shape* of a memoization matters more than
whether one is present at all: a cache behind a `Finset.filter` predicate was measured 6.2x
**worse** than no cache, and separately broke a definitional-equality invariant outright.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` — `verts` re-expressed
  as `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))`, calling `posAt` once per
  window time rather than once per (position, time) pair; `succT` / `predT` `let`-bind `verts`,
  the wrapped time and the `succP` / `predP` value once outside their filter lambdas. `mem_verts`
  re-proved from the new body through `Finset.mem_biUnion` / `Finset.mem_image` with its statement
  **byte-identical**; `mem_succT` / `mem_predT` needed no repair, the hoists being zeta-equal. No
  new identifier, no cache, no table, no equality lemma.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` — added
  `PlusSlicedCertificate.TotalEdge.{atomP, sliceA, pathA, certA}` with
  `certA_certifies : certA.Certifies := by decide`, and
  `TotalEdge.{labSliceB, labSliceB_sub, sliceB, labBb, labBf, labBb_sub, labBf_sub, pathB, certB}`
  with `certB_certifies : certB.Certifies := by decide`, each under an explicit finite
  `maxHeartbeats 2000000`; added the liveness **cost regression guard** (a `maxHeartbeats
  20000`-capped `decide` on `((liveFamily.sliced (-1)).liveAt (-1)).card = 1`); added the
  `PlusWitnessFamily.Examples` import, two module docstring sections and two Main Results entries.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` — twelve new
  declarations, purely additive (139 insertions, **zero deletions**): `Nu.{iter_succ_comm,
  iterTo, iterTo_eq_iter, gfp', gfp'_eq_gfp}` and `EUFix.{iterFrom, iterFrom_empty, iterFrom_succ,
  iterTo, iterTo_eq_iterFrom, lfp', lfp'_eq_lfp}`. The loop is top-down, so a fixed step stops the
  recursion; `iter` / `gfp` / `lfp` are untouched and keep their `DecidableEq`-free statement.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` — `untlLive` /
  `snceLive` switched to `EUFix.lfp'` and `fwdLiveT` / `bwdLiveT` to `Nu.gfp'`, each bridged by
  `untlLive_eq_lfp` / `snceLive_eq_lfp` / `fwdLiveT_eq_gfp` / `bwdLiveT_eq_gfp`; and the inner
  fixpoint hoisted out of the per-vertex filter via `untlLiveOf`, `snceLiveOf`, `untlTable`,
  `snceTable`, `untlLiveAtTab`, `snceLiveAtTab`, `untlLiveAtTab_eq`, `snceLiveAtTab_eq`.
  `mem_fwdLiveStep` and `mem_bwdLiveStep` are byte-identical in statement.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean` — **prose only**: one
  docstring paragraph in `### What a changed box guess does and does not move` recording the third
  instance of the stuck-matcher pattern. All 27 `withBx_` references and every declaration are
  untouched.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean` — two `unfold untlLive`
  / `unfold snceLive` sites rewritten through the bridging lemmas.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean` — one
  `rw [untlLive]` rewritten to `rw [untlLive_eq_lfp]`.
- `scripts/certificate-witness-inventory.txt` — two new `witness` rows, for `certA_certifies`
  (kinds `snce`) and `certB_certifies` (kinds `untl`).
- `scripts/check-module-invariants.sh` — two matched `#print axioms` / `AXIOM_BASELINE` pairs at
  matched positions.
- `FormalSystem/Metalogic/README.md`, `README.md`, `typst/generated/status.typ` — regenerated
  derived surfaces (never hand-written).
- `specs/716_.../probes/{16_baseline,17_early_exit,18_cache_gate,19_certb,25_shapeD_landed_transfer}.lean`,
  `probes/20_phase7_shapeB_attempt.diff`, `progress-file.md` — the measurement record.

## Decisions

- **The position-space leaf landed as a `biUnion`, not as a cache.** This is the one decision that
  changed during execution, and it was raised through `/revise` rather than substituted. See
  "The Phase 7 route" below.
- **The witnesses reuse `PlusSharingWitnessFamily.targetA` / `targetB`** rather than fresh
  targets, tying the two new inventory rows to already-pinned genuine ℤ-time non-validities and
  giving the sliced class a row at each temporal kind under the `⊡` modality.
- **The slice labelling carries the claimed kind's own formula, not only the atom.** C36b's
  `c36Sliced` reads the *slice labelling*, so a certificate whose slices label only atoms carries
  no clause kind on its row however rich its closure is. This "slab repair" was established at
  `certA` and is what made `certB`'s row interesting too; confirmed by compiled `#eval` before any
  library edit, at both witnesses.
- **`decide`, not `#eval`, is the measurement surface of record.** At `certA` the kernel decides
  the whole `Certifies` — which contains the `liveAt` clause — in ~8 s, where `#eval` needs 2951 ms
  for `liveAt 0` alone and needed 319 s for `bwdLiveT` before the position-space fix. Every
  `decide`-facing claim here is read off a `decide` measurement.
- **The three fixes landed in increasing order of blast radius** (additive `Fixpoint.lean`,
  body-only `LiveFix.lean`, body-only `Timed.lean`) so that a phase abandoned on a negative
  measurement leaves the earlier wins in place. That ordering is what made the Phase 7 block
  cheap when it happened: Phases 2-6 stood through it.
- **The cost guard's cap was set by bisecting the cap**, not by reading `#count_heartbeats`. See
  Verification.

## Plan Deviations

- **Phase 2** contingency branch not triggered: `c36Sliced` evaluated true and `Certifies` proved,
  so the reasoned-exclusion fallback was not taken.
- **Phase 4** altered: the plan's grep named `Bridge.lean` as the single dependent needing repair;
  the build named **two** files, `Bridge.lean` and `FixtureStable.lean`. The latter is not a direct
  dependent of `LiveFix.lean` and so was invisible to `grep -rln 'PlusSlicedCertificate.LiveFix'`.
  Both were fixed forward through the bridging lemmas; no statement weakened. A repo-wide grep over
  all twelve definitional-unfold spellings established the repair set is complete rather than
  merely sufficient for one build.
- **Phase 7 was blocked once, re-planned, and then executed without deviation.** The first attempt
  landed the planned cache, built scoped-green, and broke five `rfl`-proved `withBx_*` transfer
  lemmas in `Complete.lean` — a file the phase's own Scope Hypothesis asserted untouched. Rather
  than adjust the statement or raise a cap, the phase was marked `[BLOCKED]` and the route decision
  raised; the re-planned Shape D then landed on its first attempt, with `mem_verts` restated
  byte-identically and all three `withBx` transfers holding.
- **Phase 7's decomposition changed, subtractively, and was raised rather than substituted.**
  `posTable`, `posAtC` and `posAtC_eq` were dropped from the Goals and from the plan's
  `## Lean Challenge Statements`; nothing replaced them, because Shape D needs no cache for an
  equality lemma to be about. The pinned identifier count went from 31 to 28.
- **Phase 8's non-returning branch not triggered**: `certB.Certifies` returned in 12 s, so the
  second inventory row landed and no `#### Reasoned Exclusions` record was written.

## Verification

- Build: **Success** — full guarded `lake build`, green at **2844 jobs**, zero `error:` lines over
  both captured streams, read through the guard's own un-piped exit status (`exit_status=0`), with
  `.olean`-newer-than-source confirmed for every touched module; plus
  `check-module-invariants.sh`'s independent C1 `lake build exits 0`
- Sorry count: **0** (`lean-sorry-census.sh` over all eight resolved source roots)
- Vacuous count: **0 introduced**. The single grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, is present at the
  plan commit, untouched by this task, and is not a placeholder: `intTimeHistory.domain t` *is*
  `True`, so `trivial` is the honest proof of a real statement.
- Axiom count: **unchanged**. `git diff <plan commit>..HEAD -- '*.lean'` contains no `axiom` line
  added or removed; every `^axiom ` grep hit in the tree is docstring prose, not a declaration.
- `#print axioms` on all **36** landed Goals declarations (the seven `TotalEdge` names, the five
  `Nu` and six `EUFix` early-exit forms, the four bridging lemmas, the eight hoist declarations,
  and Phase 7's six preserved-interface names): every profile within
  `[propext, Classical.choice, Quot.sound]`, **zero `sorryAx`**, every name resolved.
  `posTable` / `posAtC` / `posAtC_eq` are absent by design (see Plan Deviations), not missing.
- `bash scripts/check-module-invariants.sh`: **ALL CHECKS PASSED** — C1, C2 (every pinned axiom
  set matches baseline, both new pairs included), C9, C14, C36a (7 closed-term witness rows),
  C36b (all 7 interest expressions true; `C36 certA_certifies card=6 interesting=true`,
  `C36 certB_certifies card=8 interesting=true`), C37, INV
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: INV current
- `bash scripts/typst-sync-check.sh`: PASS, all 4 checks green
- `bash .claude/scripts/verify-deploy.sh`: **PASS, 15 checks, 0 failures**
- `bash .claude/scripts/check-task-references.sh`: PASS, 0 unexempted occurrences
- `lake exe lint-style` (full project): no finding
- `lake env lean` on `probes/25_shapeD_landed_transfer.lean`: exit 0, all three `withBx` `rfl`
  transfer checks accepted against the edited module, at an explicit finite cap of 200000
- No `sorry`, `sorryAx`, `:= True`, `:= trivial` or `maxHeartbeats 0` in any touched Lean file.
  The single `maxHeartbeats 0` string in the tree's touched files is docstring prose saying it is
  never the answer.
- Files verified: Yes

### Measured before/after, every figure from this round

Baseline reproduced the research report's carried figures within 1.12x, so the diagnosis stands
on re-measured ground rather than carried numbers. Each "before" names the phase of this round
that measured it.

| Figure | before | after | factor |
|---|---|---|---|
| `certA.liveAt 0`, `#eval` — **the originating symptom** | did not return in 500 s | **2951 ms**, card 4 | **>169x** |
| `certB.liveAt 0`, `#eval` | did not return in 300 s | **22585 ms**, card 4 | **>13x** |
| embedded `(liveAt (-1)).card`, `#eval` | 20225 ms | **200 ms** | **101x** |
| embedded `fwdLiveT.card`, `#eval` | 8521 ms | **69 ms** | **124x** |
| embedded `bwdLiveT.card`, `#eval` | 1704 ms | **17 ms** | **100x** |
| `certA verts.card`, `#eval` | 1114 ms | **24 ms** | **46x** |
| `certA` sum `predT` cards over `verts`, `#eval` | 18936 ms | **237 ms** | **80x** |
| `certA bwdLiveT.card`, `#eval` | 319248 ms | **564 ms** | **566x** |
| `certA.bwdLiveT.card = 16`, kernel `decide` | 23.7 s | **3.1 / 4.1 s** | **~6.4x** |
| `certA_certifies`, scratch `decide` wall clock | 43.4 s | **8.4 s** median of 5 | **~5.2x** |
| `PlusSlicedCertificate.Examples` module build | 36 s, one `decide` | **14 s**, three `decide`s plus the guard | — |

Per-fix attribution, since the table above is cumulative:

- **Early exit** (Fixpoint.lean + LiveFix.lean) is where the first `#eval` win came from: it alone
  took embedded `liveAt (-1)` from 20225 ms to 1648 ms (12.3x), measured 12.8x on the backward
  operator and 3.5x on the forward one in isolation.
- **The inner-fixpoint hoist** is a 5.4x `#eval` win at `certA`, a ~25% `#eval` **loss** at the
  small embedded witness, and **kernel-neutral** (25.9 s against 24.4 s, 1.06x) in a zero-rebuild
  A/B. See "Phase 5's hoist" below.
- **The position-space leaf (Shape D)** supplies the rest: 64.7x on `verts` in isolation, and the
  propagated figures in the two rows measured against their Phase 6 gate baselines.

### What the cost regression guard is worth, and one trap

The guard is a `maxHeartbeats 20000`-capped `decide` on
`((liveFamily.sliced (-1)).liveAt (-1)).card = 1`. Its cap was set by bisecting the cap itself
against the built library: 6000 FAILS with `(deterministic) timeout at whnf`, 7000 PASSES, so the
fixpoint costs 6000-7000 heartbeats today and `20000` is a little over 3x that. A regression past
3x therefore fails the build outright rather than slowing it, and heartbeat consumption is
deterministic, so the threshold carries no machine-load flakiness.

**`#count_heartbeats` cannot be used to set such a cap.** It reports **11** heartbeats for
`certA.bwdLiveT.card = 16` and **23** for the guard goal, yet a cap of 20 on the first fails
outright and the guard goal needs 6000-7000: it does not see the consumption inside `decide`'s
nested `whnf`. Bisect the cap; do not trust that command's number.

## Impacts

- A defect in shipped, gated code is **fixed**, not documented. The configuration on which
  `liveAt` did not return now returns in under 3 s under `#eval` and is decided by the kernel in
  ~8 s inside an explicit finite heartbeat cap. The cost cannot silently return: the guard fails
  the build.
- The sliced certificate class's non-vacuity record covers **both** temporal kinds at width above
  1 with a total edge relation, where it previously covered one kind at a self-loop. C36's
  admission bar reads three interesting sliced witnesses where it read one.
- Four early-exit fixpoint forms and eight equality lemmas are available to any later work on this
  decision procedure, each unconditional, so a caller can rewrite freely between the primed and
  unprimed forms.
- `mem_verts` / `mem_succT` / `mem_predT` are confirmed as the complete downstream interface of
  the three re-expressed definitions: every use across `Bridge`, `Stable`, `Sound`, `Complete`,
  `EmbedComplete`, `Tail`, `Check`, `Computed` and `FixtureStable` routes through one of them or
  through `_subset` / `fst_mem_*` / `snd_of_mem_*`. A future shape change to those bodies is
  correspondingly cheap.
- `Complete.lean`'s invariant docstring now names all three instances of the stuck-matcher
  pattern, so the next optimisation attempt on this subtree does not rediscover the second one by
  breaking the build.
- `untlLiveAt` / `snceLiveAt` were deliberately left in place beside the table-reading clauses.
  That is what made a zero-rebuild A/B possible and is worth preserving for future measurement.

## Three records this round settled or left open

### (a) The Phase 7 route

The position-space leaf landed as **Shape D** — `verts` re-expressed as a `biUnion` over the
window times — rather than as the planned cache. The rejected table shape fails on a specific,
reproducible defeq defect: a lookup whose `match` sits inside `Finset.filter`'s `DecidablePred`
instance argument cannot transfer across `withBx`. `Finset.filter` takes that instance as an
*explicit* argument, so `isDefEq` must compare the two synthesized instance terms; the matcher's
scrutinee is a `List.find?` over a range built from `G.winLo` / `G.winHi`, projections of the
variable `G`, so it is neutral, cannot iota-reduce, and the comparison returns **false** rather
than succeeding slowly. Measured at ten times the heartbeat cap, `rfl` still fails outright — no
cap bump reaches it. The position *table* is innocent (`withBx_posTable := rfl` succeeds) and the
`succT` / `predT` `let`-hoists are innocent (zeta-equal, `rfl`-transferable); the filter-predicate
lookup is the whole of it. Shape D also **wins on merit** rather than merely on scope: it measures
15-21 ms against the table shape's ~1100-1358 ms at `certA`, and its kernel `decide` (3.1-4.1 s)
beats the rejected cache mirror's 4.3 s. Three planned identifiers — `posTable`, `posAtC`,
`posAtC_eq` — were dropped as a raised, purely subtractive decomposition change.

### (b) Shape D's isolated versus propagated figures, stated separately

The evidence that selected Shape D measured `verts` **in isolation**: 21 ms against the landed
filter shape's 1358 ms this round, **64.7x**, identical card 16, agreement checked by `#eval`.
Whether that propagated to `liveAt` was unmeasured at selection time. It does propagate, by a
**different factor on each surface**, and the two are not interchangeable:

- Under `#eval`, propagation is *larger* than the isolated factor — **101x** on
  `certA bwdLiveT.card` (57183 → 564 ms) — because the saving is paid once per `posAt` call and
  the fixpoint makes many.
- Under the **kernel**, which is the surface `decide` actually runs on, it is **~6.4x**
  (23.7 s → 3.1/4.1 s on `certA.bwdLiveT.card = 16`). The whnf cache was already sharing
  `G.posAt t` across repeated `t`; what Shape D removes there is the 512-fold
  `v.1 ∈ G.posAt v.2` membership test, not the slice rebuild. This figure is within noise of the
  Phase 6 gate's predicted 5.51x.

No claim here is a complexity bound, and none says the fixed procedure is fast in general. Every
figure is at one of two named certificates.

### (c) Phase 5's hoist remains an open question

The inner-fixpoint hoist is **landed, proved equal, and unexamined by this round's later phases**.
It is correct — `mem_fwdLiveStep` / `mem_bwdLiveStep` are byte-identical in statement and
re-proved through `untlLiveAtTab_eq` / `snceLiveAtTab_eq` — so correctness is not at issue. What
rests on a single hard certificate is its *justification*: a zero-rebuild kernel A/B measured it
**neutral** (25.9 s against 24.4 s, 1.06x, inside run-to-run variance), roughly 25% **worse** at
the small embedded witness under `#eval`, and 5.4x better at `certA` under `#eval`. **Task 781
owns the stay-or-revert decision** and is at `[RESEARCHED]`. No figure in this summary attributes
a win to the hoist, and no phase of this round reverted, re-measured or re-planned it.

## Follow-ups

- **Task 781 decides whether the inner-fixpoint hoist stays.** See record (c) above. Nothing in
  this round forces the choice, and a size-sensitive form (table only above a closure-size
  threshold) is one candidate that would recover the small-certificate regression without giving
  up the `certA` `#eval` win.
- **The research report's single 16.7x early-exit factor does not reproduce as one number**:
  12.8x on the backward operator, 3.5x on the forward one, with the in-library figure larger still
  because the inner and outer fixpoints compound. Any future citation should use the per-direction
  figures in `progress-file.md`.
- **`certB.liveAt 0` under `#eval` is 22585 ms**, against `certA`'s 2951 ms, on a position space
  4x larger over a five-time window. The remaining `#eval`-side cost scales steeply, so a third,
  larger witness would want a measurement before a `decide` rather than after.
- **The `certA_certifies` `decide` row is the weakest figure in the table** and is reported as
  measured: five scratch runs gave 5026 / 8670 / 6080 / 8557 / 8439 ms gross against an
  import-only control of 1822-2854 ms. The like-for-like `bwdLiveT` `decide` A/B is the figure to
  cite for the kernel-side gain.

## References

- `specs/716_sliced_certificate_liveat_nontermination/plans/02_shape-d-verts-biunion.md` — the
  executed plan; `plans/01_liveat-memoization-tier2-witness.md` is the prior approach it revises
- `specs/716_sliced_certificate_liveat_nontermination/reports/01_liveat-nontermination-profile.md`
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` — every figure cited
  above, with how it was measured
- `specs/716_sliced_certificate_liveat_nontermination/probes/16_baseline.lean`,
  `17_early_exit.lean`, `18_cache_gate.lean`, `19_certb.lean`,
  `21_shapeD_transfer.lean`, `22_lethoist_transfer.lean`, `23_table_defeq_failure.lean`,
  `24_shapeD_measure.lean`, `25_shapeD_landed_transfer.lean`,
  `20_phase7_shapeB_attempt.diff` — the preserved cache attempt
- `specs/704_certificate_non_vacuity_and_shape_gates/probes/03_tier2_sliced_certificates.lean` —
  the preserved reproducer this task started from
