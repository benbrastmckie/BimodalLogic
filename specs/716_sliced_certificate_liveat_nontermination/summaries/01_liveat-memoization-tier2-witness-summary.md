# Implementation Summary: Task #716

- **Task**: 716 - Profile and fix the PlusSlicedCertificate liveT/liveAt non-termination that blocks Tier-2 sliced certificate witnesses
- **Status**: [BLOCKED]
- **Started**: 2026-10-13T10:15:00Z
- **Completed**: 2026-10-13T16:05:00Z
- **Effort**: ~6 hours
- **Dependencies**: None
- **Artifacts**: plans/01_liveat-memoization-tier2-witness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-6 of nine are complete and committed; Phase 7 is [BLOCKED] on a defeq failure the plan
could not have anticipated, and Phases 8-9 are [NOT STARTED] behind it. What landed: the sliced
certificate class now carries a second interesting witness -- a width-2, total-edge certificate at
the `snce`/`⊡` target `Pp → ⊡Pp`, proved by kernel `decide`, with its C36 inventory row and its C2
axiom pin -- and two of the three recomputation faults in the shipped liveness decision procedure
are removed behind unconditional equality lemmas. The headline measured result is that the
embedded witness's `liveAt (-1)` went from 20225 ms to 1648 ms, a 12.3x improvement, with no
statement anywhere weakened, no `sorry`, and no new axiom.

The diagnosis the research report settled -- missing memoization, not an algorithmic defect and
not intrinsic cost -- is confirmed and sharpened by this round's measurements. The sharpening
matters: the report's `#eval` figures systematically overstate what transfers to the kernel, and
two of the three fixes were measured to behave quite differently on the two evaluators.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` — added
  `PlusSlicedCertificate.TotalEdge.{atomP, sliceA, pathA, certA}` and
  `certA_certifies : certA.Certifies := by decide` under an explicit finite
  `maxHeartbeats 2000000`; added the `PlusWitnessFamily.Examples` import, a module docstring
  section on what the total-edge witness adds over the self-loop one, and a Main Results entry.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` — twelve new
  declarations, purely additive (139 insertions, **zero deletions**): `Nu.{iter_succ_comm,
  iterTo, iterTo_eq_iter, gfp', gfp'_eq_gfp}` and `EUFix.{iterFrom, iterFrom_empty, iterFrom_succ,
  iterTo, iterTo_eq_iterFrom, lfp', lfp'_eq_lfp}`. The loop is top-down, so a fixed step stops the
  recursion; `iter` / `gfp` / `lfp` themselves are untouched and keep their `DecidableEq`-free
  statement.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` — `untlLive` /
  `snceLive` switched to `EUFix.lfp'` and `fwdLiveT` / `bwdLiveT` to `Nu.gfp'`, each bridged by
  `untlLive_eq_lfp` / `snceLive_eq_lfp` / `fwdLiveT_eq_gfp` / `bwdLiveT_eq_gfp`; and the inner
  fixpoint hoisted out of the per-vertex filter via `untlLiveOf`, `snceLiveOf`, `untlTable`,
  `snceTable`, `untlLiveAtTab`, `snceLiveAtTab`, `untlLiveAtTab_eq`, `snceLiveAtTab_eq`.
  `mem_fwdLiveStep` and `mem_bwdLiveStep` are byte-identical in statement.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean` — two `unfold untlLive`
  / `unfold snceLive` sites rewritten through the bridging lemmas.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean` — one
  `rw [untlLive]` rewritten to `rw [untlLive_eq_lfp]`.
- `scripts/certificate-witness-inventory.txt` — one new `witness` row for
  `PlusSlicedCertificate.TotalEdge.certA_certifies`, kinds `snce`.
- `scripts/check-module-invariants.sh` — one matched `#print axioms` / `AXIOM_BASELINE` pair at
  matched positions.
- `FormalSystem/Metalogic/README.md`, `README.md`, `typst/generated/status.typ` — regenerated
  derived surfaces (never hand-written).
- `specs/716_.../probes/{16_baseline,17_early_exit,18_cache_gate}.lean`,
  `probes/20_phase7_shapeB_attempt.diff`, `progress-file.md` — the measurement record.

## Decisions

- **The witness reuses `PlusSharingWitnessFamily.targetA`** rather than a fresh target, tying the
  new inventory row to the already-pinned genuine ℤ-time non-validity `not_plusValidZTime_stabSnce`.
- **The slice labelling carries `Pp`, not only the atom.** C36b's `c36Sliced` reads the *slice
  labelling*, so a certificate whose slices label only atoms carries no clause kind on its row
  however rich its closure is. Confirmed by compiled `#eval` before any library edit.
- **`decide`, not `#eval`, is the measurement surface of record.** At `certA` the kernel decides
  the whole `Certifies` -- which contains the `liveAt` clause -- in 34 s, while `#eval` cannot
  compute `liveAt 0` in 500 s and needs 319 s for `bwdLiveT` alone. Every `decide`-facing claim
  here is read off a `decide` measurement.
- **The three fixes were landed in increasing order of blast radius** so that a phase abandoned on
  a negative measurement leaves the earlier wins in place. That ordering is what makes the Phase 7
  block cheap: Phases 2-5 stand.

## Plan Deviations

- **Phase 2** contingency branch not triggered: `c36Sliced` evaluated true and `Certifies` proved,
  so the reasoned-exclusion fallback was not taken.
- **Phase 4** altered: the plan's grep named `Bridge.lean` as the single dependent needing repair;
  the build named **two** files, `Bridge.lean` and `FixtureStable.lean`. The latter is not a direct
  dependent of `LiveFix.lean` and so was invisible to `grep -rln 'PlusSlicedCertificate.LiveFix'`.
  Both were fixed forward through the bridging lemmas; no statement weakened. A repo-wide grep over
  all twelve definitional-unfold spellings established the repair set is complete rather than merely
  sufficient for one build.
- **Phase 7** BLOCKED rather than completed or excluded. The plan's declared exclusion branch is
  reachable only on a FAILED gate, and the gate PASSED; the block is on a different cause. See
  Follow-ups.
- **Phases 8 and 9** NOT STARTED: Phase 8 declares `depends on: 2, 7`, and its `certB` measurement
  taken without the cache would be a figure that has to be re-measured once Phase 7 is settled.

## Verification

- Build: **Success** — full guarded `lake build`, green at 2844 jobs, read through the guard's own
  `result` (`exit_status=0`), plus `check-module-invariants.sh`'s independent C1 `lake build exits 0`
- Sorry count: **0** (`lean-sorry-census.sh` over all eight resolved source roots)
- Vacuous count: **0 introduced**. The single grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, is present at the
  plan commit, untouched by this task, and is not a placeholder: `intTimeHistory.domain t` *is*
  `True`, so `trivial` is the honest proof of a real statement.
- Axiom count: **12, unchanged** from the plan commit (`grep -c '^axiom ' FormalSystem`)
- `#print axioms` on all 14 landed Goals declarations: every profile within
  `[propext, Classical.choice, Quot.sound]`, zero `sorryAx`. `Nu.iter_succ_comm` needs only
  `[propext, Quot.sound]`.
- `bash scripts/check-module-invariants.sh`: **ALL CHECKS PASSED** — C1, C2 (all fifty pinned
  axiom sets match, the new pair included), C9, C14, C36a, C36b (`C36 certA_certifies card=6
  interesting=true`), C37, INV
- `bash scripts/typst-sync-check.sh`: PASS, all 4 checks green
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: INV current
- `bash .claude/scripts/verify-deploy.sh`: PASS, 15 checks, 0 failures
- `bash .claude/scripts/check-task-references.sh`: PASS, 0 unexempted occurrences
- `lake exe lint-style` on all five touched Lean files: no finding
- No `sorry`, `sorryAx`, `:= True`, `:= trivial` or `maxHeartbeats 0` in any touched Lean file
- Files verified: Yes

### Measured before/after, all figures from this round

Baseline reproduced the research report's carried figures within 1.12x, so the report's diagnosis
stands on re-measured ground rather than carried numbers.

| Figure | before | after | factor |
|---|---|---|---|
| embedded witness `(liveAt (-1)).card` (`#eval`) | 20225 ms | **2188 ms** | **9.2x** |
| embedded witness `fwdLiveT.card` (`#eval`) | 8521 ms | 860 ms | 9.9x |
| embedded witness `bwdLiveT.card` (`#eval`) | 1704 ms | 228 ms | 7.5x |
| `certA` `bwdLiveT.card` (`#eval`) | 319248 ms (post-Phase-4) | 58656 ms | 5.4x |
| `certA` `Certifies` kernel `decide` (module build) | 36 s | 34-41 s | ~1.0x |

The early-exit switch (Phases 3-4) is where the whole `#eval` win comes from: it alone took
`liveAt (-1)` from 20225 ms to 1648 ms. The inner-fixpoint hoist (Phase 5) is a 5.4x win at
`certA` and a ~25% loss at the small embedded witness, and an A/B at one library state measured it
as **neutral under the kernel** (25.9 s vs 24.4 s). The kernel's own whnf cache was already
removing most of the duplication the hoist targets.

## Impacts

- The sliced certificate class's non-vacuity record now covers a `snce`-kind closure at width
  above 1 with a total edge relation, not only an `untl`-kind self-loop. C36's admission bar reads
  two interesting sliced witnesses where it read one.
- Four early-exit fixpoint forms and eight equality lemmas are available to any later work on this
  decision procedure, each unconditional, so a caller can rewrite freely between the primed and
  unprimed forms.
- A defect in shipped, gated code is substantially reduced rather than documented: the
  configuration on which `liveAt` appeared not to return now returns in under 2.2 s under `#eval`
  and is decided by the kernel inside a finite explicit heartbeat cap.
- `untlLiveAt` / `snceLiveAt` were deliberately left in place beside the new table-reading clauses.
  That is what made a zero-rebuild A/B possible and is worth preserving for future measurement.

## Follow-ups

- **Phase 7 needs a planning decision before any further edit to `Timed.lean`.** The leaf cache
  landed and built scoped-green, then broke five `rfl`-proved `withBx_*` transfer lemmas in
  `Complete.lean` -- a file the phase's Scope Hypothesis asserted untouched. A scratch test at ten
  times the heartbeat cap shows `rfl` **fails outright** (`isDefEq` returns false), so no cap bump
  can fix it. Two routes, with the evidence for each recorded on the Phase 7 heading in the plan:
  (i) re-express `verts` as `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))`,
  which is `rfl`-transferable and gets the same 512-to-4 reduction in `posAt` calls but drops
  `posTable` / `posAtC` / `posAtC_eq` from the Goals; or (ii) keep the cache and add roughly
  fourteen propositional transfer lemmas to `Complete.lean`. Route (i) is a decomposition change
  and route (ii) a scope change, so neither is an implementation agent's call.
- **Phase 8 remains open**: `certB`'s second inventory row is unsettled, and the heartbeat-capped
  cost regression guard on the embedded witness's `liveAt` is not yet in place. Both wait on
  Phase 7 only because Phase 8's figures should be taken in the final configuration.
- **The hoist's small-certificate regression is worth revisiting** once Phase 7 is settled: at a
  3-member closure it costs ~25%, and a size-sensitive form (table only above a closure-size
  threshold) would recover that without giving up the 5.4x at `certA`. Nothing measured here forces
  the choice.
- **The 16.7x early-exit factor in the research report does not reproduce as a single number**:
  12.8x on the backward operator but 3.5x on the forward one in isolation, with the in-library
  figure larger still because the inner and outer fixpoints compound. Any future citation should
  use the per-direction figures in `progress-file.md`.

## References

- `specs/716_sliced_certificate_liveat_nontermination/plans/01_liveat-memoization-tier2-witness.md`
- `specs/716_sliced_certificate_liveat_nontermination/reports/01_liveat-nontermination-profile.md`
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` — every figure cited above,
  with how it was measured
- `specs/716_sliced_certificate_liveat_nontermination/probes/16_baseline.lean`,
  `17_early_exit.lean`, `18_cache_gate.lean`, `20_phase7_shapeB_attempt.diff`
- `specs/704_certificate_non_vacuity_and_shape_gates/probes/03_tier2_sliced_certificates.lean` —
  the preserved reproducer this task started from
