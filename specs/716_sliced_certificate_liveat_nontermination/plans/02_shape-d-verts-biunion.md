# Implementation Plan: Task #716

- **Task**: 716 - Profile and fix the PlusSlicedCertificate liveT/liveAt non-termination that blocks Tier-2 sliced certificate witnesses
- **Status**: [COMPLETED] (Phases 1-6 landed and committed; Phase 7 re-planned onto Shape D)
- **Effort**: 14 hours total -- 9.5 h landed in Phases 1-6, 4.5 h remaining in Phases 7-9
- **Dependencies**: None. The Shape D decision this plan records was established by task 782's
  blocker research, which is complete; no edge remains.
- **Research Inputs**:
  - specs/716_sliced_certificate_liveat_nontermination/reports/01_liveat-nontermination-profile.md
  - specs/716_sliced_certificate_liveat_nontermination/probes/21_shapeD_transfer.lean
  - specs/716_sliced_certificate_liveat_nontermination/probes/22_lethoist_transfer.lean
  - specs/716_sliced_certificate_liveat_nontermination/probes/23_table_defeq_failure.lean
  - specs/716_sliced_certificate_liveat_nontermination/probes/24_shapeD_measure.lean
  - specs/716_sliced_certificate_liveat_nontermination/progress-file.md
- **Reports Integrated**: probes/21_shapeD_transfer.lean,
  probes/22_lethoist_transfer.lean, probes/23_table_defeq_failure.lean,
  probes/24_shapeD_measure.lean
- **Provenance note**: the blocker research that selected Shape D was delivered through the
  orchestrator's one-shot `.blocker-research.json` channel, which is consumed and cleared once
  read, so it is **not** on disk and is not citable as a Research Input. Its findings are
  reproduced inline in the Research Integration subsection below, and every figure and transfer
  claim it carried is independently re-derivable from the four probe files named above — which are
  the durable record. An implementer who needs a source for a carried figure goes to
  `probes/24_shapeD_measure.lean`, never to a `.blocker-research.json` path.
- **Artifacts**: plans/02_shape-d-verts-biunion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Phases 1-6 are landed, committed and verified: the width-2 total-edge Tier-2 witness with its C36
row and C2 pin, the early-exit iterations, the four switched liveness fixpoints, the hoisted inner
fixpoint, and the leaf-cache decision gate. What remains is Phase 7 — the position-space leaf —
and the two phases that were blocked only behind it. Phase 7 now lands **Shape D**: `verts`
re-expressed as a `biUnion` over the window times, which calls `posAt` once per window time
instead of once per (position, time) pair, keeps `mem_verts` byte-identical, and needs no cache,
no table and no equality lemma because there is nothing to be equal to. Definition of done is
unchanged from the original plan — `certA` a pinned, C36-interesting Tier-2 inventory row; no
`sorry`, no new axiom, no landed statement weakened; `lake build` and
`scripts/check-module-invariants.sh` green; every performance claim in the summary a figure
measured in this round — with one addition: Phase 7's own measurement must state whether Shape D's
isolated `verts` gain propagates to `liveAt`, because the evidence that selected it does not say.

### Research Integration

Four probes and one structured blocker record, all postdating the original plan, are integrated
here. They do not revisit the diagnosis; they settle the Phase 7 route.

- **The route choice is not a trade-off.** `probes/21_shapeD_transfer.lean` establishes, with no
  `sorryAx` and inside `[propext, Classical.choice, Quot.sound]`, that
  `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))` is `rfl`-transferable across
  `withBx` (`withBx_vertsD := rfl`), admits a characterization whose statement is byte-identical to
  `mem_verts`, and is unconditionally equal to the landed `verts` (`vertsD_eq_verts`). It therefore
  plays the exact role `posAtC_eq` was built for — no use site can observe a difference — without a
  cache. `probes/24_shapeD_measure.lean` measures it at `certA`: **15 ms against the landed
  `verts`'s 1093 ms, identical card 16, agreement checked by `#eval`**. Route (ii) of the recorded
  blocker (Shape B plus roughly fourteen propositional transfer lemmas in `Complete.lean`) would
  buy the gate's 5.5x `decide` / 63x `#eval` figures at the price of that scope widening, and is
  therefore rejected on **merit** — it buys a slower `verts` — not merely on cost. See D7.
- **The cause is narrower than first recorded.** `probes/23_table_defeq_failure.lean` is the
  standing reproduction: `withBx_posTable := rfl` **succeeds**, so the position table is innocent;
  `probes/22_lethoist_transfer.lean` shows the `succT`/`predT` `let`-hoists are zeta-equal to the
  landed bodies (`succTH_eq`/`predTH_eq` are `rfl`) and `rfl`-transferable, so they carry no proof
  obligation and land independently of the `verts` decision. The poison is specifically a
  **`match`-on-lookup inside `Finset.filter`'s `DecidablePred` instance argument**, whose scrutinee
  is a `List.find?` over a range built from `G.winLo`/`G.winHi` — projections of the variable `G`,
  so the matcher cannot iota-reduce and `isDefEq` returns **false**, not slow. See D9.
- **Carried-figure status.** The 15 ms / 1093 ms pair, the card-16 agreement, and the 512-to-4
  reduction in `posAt` calls are **CARRIED**, and their single durable source is
  `probes/24_shapeD_measure.lean` — specifically its three `#time #eval` lines
  (`(certA.verts).card`, `(certA.vertsD).card`, `certA.verts = certA.vertsD`) under
  `set_option maxHeartbeats 2000000`. Phase 7's first task re-runs probe 24 against the current
  built library before any edit, and its Scope Hypothesis names both the figures and that source.
  Every figure from Phases 1-6 is already a this-round measurement recorded in
  `progress-file.md`.
- **Probe status, stated so a non-zero exit is not misread.** Probes 21, 22 and 24 compile and
  exit 0. Probe 23 is the **intended reproduction** and exits non-zero by design: its
  `withBx_vertsB` is the failure, while `withBx_posTable` in the same file succeeds. A build
  sweep that reports probe 23 as failing has reported it working. Every declaration across all
  four probes sits within `[propext, Classical.choice, Quot.sound]` with no `sorryAx`, so nothing
  Phase 7 adapts from them carries an axiom debt.
- **The evidence's own scope caveat is preserved, not overstated.** The ~73x factor measures
  `verts` **in isolation**, not the propagated `liveAt` figure: confirming that would have required
  editing `Timed.lean`, outside an aux research dispatch's remit. Phase 7's verification step
  directs the propagated re-measurement and requires the answer to be stated either way.

### Decomposition Change (raised, not substituted)

Shape D **drops three declarations from the Goals and from `## Lean Challenge Statements`**:
`posTable`, `posAtC`, `posAtC_eq`. Nothing replaces them — Shape D re-expresses `verts`'s body
directly and adds no named declaration, because there is no cache for an equality lemma to be
about. `.claude/rules/plan-compliance.md` requires a decomposition change on a `.lean` file to be
raised rather than silently substituted; this subsection and D8 are that record. The pinned
identifier count goes from 31 to 28, and the change is purely subtractive.

### Open Question Carried Forward (not re-planned here)

Phase 5's inner-fixpoint hoist measured **kernel-neutral**: 25.9 s against 24.4 s on `certA`'s
backward fixpoint under `decide` (1.06x, inside run-to-run variance), and roughly 25% *worse* at
the small embedded witness, against 5.4x better at `certA` under `#eval`. It is landed and
proved-equal, so correctness is not at issue and `mem_fwdLiveStep`/`mem_bwdLiveStep` are unchanged;
what rests on a single hard certificate is its *justification*. **Task 781 owns the
stay-or-revert decision** and is already at `[RESEARCHED]`. No phase below reverts the hoist,
re-measures it, or re-plans it — the question is recorded so a reader of this plan is not misled
into reading the hoist as an established win. See D10.

### Prior Plan Reference

`plans/01_liveat-memoization-tier2-witness.md`. Phases 1-6 are reproduced here unchanged, with
their landed task checkmarks and execution-time deviation annotations intact. Phase 7 is replaced;
Phases 8-9 are carried with the Phase 7 dependency now pointing at the Shape D landing.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only and is not written by any phase here. 716 sits in the
roadmap's **Stage 1** line `/orchestrate 716,714 --hard` as "the sliced-certificate sub-front",
where it is characterised as a defect in shipped, gated code: the `liveT`/`liveAt` fixpoint not
returning in 300 s on a 4-position total-edge certificate while being instant on self-loop ones.
Phase 7 is the last of the three recomputation fixes that defect reduces to, so this plan advances
that line and nothing else. The roadmap's guardrail "do not file a fourth certificate class" is
respected: no phase here adds a certificate class, and Phase 8 settles a second *witness* within
the existing sliced class.

## Goals & Non-Goals

**Goals**:

Lean declarations, in the namespaces fixed by the Lean Challenge Statements section below:
PlusSlicedCertificate.TotalEdge for the witness, Nu and EUFix for the early-exit forms, and
PlusSlicedCertificate for the rest.

- `atomP`, `sliceA`, `pathA`, `certA`, `certA_certifies`
- `iter_succ_comm`, `iterTo`, `iterTo_eq_iter`, `gfp'`, `gfp'_eq_gfp`
- `iterFrom`, `iterFrom_empty`, `iterFrom_succ`, `iterTo_eq_iterFrom`, `lfp'`, `lfp'_eq_lfp`
- `untlLive_eq_lfp`, `snceLive_eq_lfp`, `fwdLiveT_eq_gfp`, `bwdLiveT_eq_gfp`
- `untlLiveOf`, `snceLiveOf`, `untlTable`, `snceTable`, `untlLiveAtTab`, `snceLiveAtTab`,
  `untlLiveAtTab_eq`, `snceLiveAtTab_eq`

Phase 7 adds **no** identifier: it re-expresses the bodies of `verts`, `succT` and `predT` and
re-proves `mem_verts` with its statement unchanged. See the Decomposition Change subsection above
for the three identifiers this plan drops.

Non-Lean outputs:

- One witness row for the total-edge certificate in `scripts/certificate-witness-inventory.txt`
  whose interest expression evaluates true at a non-empty closure under C36b, with its matched
  `#print axioms` / baseline pair in `scripts/check-module-invariants.sh` (C2)
- A heartbeat-capped cost regression guard on the pinned self-loop embedded witness's liveness
  computation, so a return of the blowup fails the build rather than slowing it
- One prose line in `Complete.lean`'s "What a changed box guess does and does not move" section
  recording the third instance of the stuck-matcher pattern, so the next optimisation attempt does
  not rediscover it
- Every performance figure in the implementation summary measured in this round, with the
  before-and-after pair stated for each of the three fixes that lands, and with the isolated and
  propagated figures for Shape D distinguished rather than conflated

**Non-Goals**:

- No change to the soundness or completeness theorems above the liveness fixpoints, and no
  change to any landed *statement* anywhere: every refactor below is additive or
  body-only-with-preserved-characterization.
- **No new field on `PlusSlicedCertificate`.** A field would change every certificate author's
  obligations and reopen the demanded-field question `not_exists_plusCertifies_pumpTarget`
  settled.
- **No position table, no `posAtC`, and no lookup inside any `Finset.filter` predicate anywhere in
  `Timed.lean`.** This is the shape probe 23 reproduces as breaking the `withBx` invariant; it is
  ruled out, not deferred.
- **No propositional `withBx_*` transfer lemma in `Complete.lean`, and no declaration there added,
  removed or re-proved.** The only edit that file receives is one prose line in a docstring.
- **No `maxHeartbeats` bump in `Complete.lean`.** Reproduction at ten times the cap shows `isDefEq`
  returns false rather than timing out, so a bump masks nothing — it would be a mask rather than a
  fix even if the lookup shape returned.
- No `sorry`, no new axiom, no vacuous placeholder (`:= True`, `:= trivial`), and no
  `maxHeartbeats 0` in landed source — only explicit finite caps.
- No revert, re-measurement or re-planning of Phase 5's hoist; task 781 owns that decision.
- No re-derivation of the diagnosis, and no re-litigation of the Phase 6 gate. A phase that
  measures a *worse* figure than a carried one reports the discrepancy and proceeds on its own
  measurement.
- No claim of a complexity bound, and no claim that the fixed procedure is fast in general. Every
  figure below is at two named certificates.
- No edit to the refuted sliced finite-model-property work, the TailStable junk-position
  evaluation, or the finite-carrier refutations.

## Decisions

- **D1**: `certA` lands in
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean`, which the default
  build elaborates (it is imported by `PlusSlicedCertificate.lean` and so by `FormalSystem.lean`).
  The ~90 s `decide` is accepted as a default-build cost rather than moved out of the build graph,
  because C2's axiom pin and C36b's interest expression are both compiled against
  `import FormalSystem` and a declaration outside that graph is invisible to both.
- **D2**: The witness reuses `PlusSharingWitnessFamily.targetA` (`Pp → ⊡Pp`) rather than a fresh
  target, which ties the new row to the already-pinned genuine ℤ-time non-validity
  `not_plusValidZTime_stabSnce` and gives the sliced class a row at a `snce`-kind closure beside
  its existing `untl`-kind one.
- **D3**: The three performance fixes land in increasing order of blast radius — early exit
  (Fixpoint.lean, additive), inner-fixpoint hoist (LiveFix.lean, body-only), position-space leaf
  (Timed.lean, body-only) — so that a phase abandoned on a negative measurement leaves the
  earlier, cheaper wins in place.
- **D4**: The position-space leaf was a **measured decision gate** (Phase 6) before it was a
  landing (Phase 7). The gate passed, and it is what caught that a naive "filter against a cache"
  shape is 6.2x *worse* than no cache at all. Its verdict stands; what changed is the shape the
  landing takes.
- **D5**: The early-exit iteration is expressed as a **top-down loop** (`iterTo F X n` recursing
  on `F X` when it differs from `X`, stopping when it does not), not as a bottom-up `iter` with a
  stability test at each level. The bottom-up form applies `F` once per level regardless and
  therefore saves nothing; this is a correctness condition on the fix, not a style preference.
- **D6**: `DecidableEq α` is taken as an instance argument on the new `Nu` definitions only.
  `Nu.iter` / `Nu.gfp` are left untouched, so that module header's claim that no `DecidableEq` is
  needed at that level stays true of the existing development. `EUFix` already carries the
  instance at namespace level and needs nothing new.
- **D7**: **Phase 7 lands Shape D, and does so on merit.** `verts` becomes
  `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))`: `posAt` once per window
  time (4 calls, not 512), no table, no cache, no `let`, no equality lemma. It is
  `rfl`-transferable across `withBx`, so `Complete.lean`'s five `rfl`-proved `withBx_*` transfers
  stay intact and Phase 7's Scope Hypothesis holds as originally written. The alternative — the
  table-shaped body plus roughly fourteen propositional transfer lemmas in `Complete.lean` — is
  rejected because it buys a **slower** `verts` (1093 ms shape, against Shape D's 15 ms at
  `certA`) at the price of a scope widening into a file this task never scoped. The gate's 5.5x
  `decide` / 63x `#eval` figures were figures that route needed to *preserve*; Shape D exceeds
  them on the measurement available without paying for them.
- **D8**: `posTable`, `posAtC` and `posAtC_eq` are **dropped** from the Goals and from
  `## Lean Challenge Statements`. See the Decomposition Change subsection above; raised here
  explicitly as `plan-compliance.md` requires, and visible in this plan rather than absorbed into
  Phase 7's prose.
- **D9**: The cause of the earlier failure is recorded in one place, in its narrowed form, because
  the next optimisation attempt will meet it: a **lookup whose `match` sits inside
  `Finset.filter`'s `DecidablePred` instance argument** cannot transfer across `withBx`.
  `Finset.filter` takes that instance as an explicit argument, so `isDefEq` must compare the two
  synthesized instance terms; their matcher's scrutinee is a `List.find?` over a range built from
  `G.winLo`/`G.winHi`, which are projections of the variable `G`, so it is neutral, cannot
  iota-reduce, and `isDefEq` bails to **false** rather than falling back to congruence. This is a
  third instance of the pattern `Complete.lean`'s own docstring names as its two known exceptions
  (`iterBack`/`iterFwd` and `canAt`, each recursing on an argument that is a variable at the point
  of use). The table itself is innocent and the `let`-hoists are innocent; Phase 7 records the
  pattern in that docstring so the invariant's statement there is complete.
  **The failure's signature, so Phase 7's scratch transfer check is recognizable when it fires.**
  `probes/23_table_defeq_failure.lean` carries the succeeding and the failing transfer side by
  side: `withBx_posTable … := rfl` is accepted, and `withBx_vertsB … := rfl` is rejected with

  ```
  rfl has type ?m.9 = ?m.9 but is expected to have type (G.withBx bx).vertsB = G.vertsB
  ```

  Two things about that message matter at implementation time. It is an elaboration *failure*, not
  a timeout — reproduced at ten times the heartbeat cap with the same text — so a
  `maxHeartbeats` bump cannot convert it into a success, which is why that bump is a Non-Goal
  rather than a fallback. And the metavariable form `?m.9 = ?m.9` is what `isDefEq` returning
  false looks like here, as distinct from the congruence-fallback error a genuinely mismatched
  shape would produce. If Phase 7's `probes/25_shapeD_landed_transfer.lean` check reports this
  same shape of message against the edited `verts`, `succT` or `predT`, the phase is `[BLOCKED]`
  on the same cause and is raised, not retried with a larger cap.
- **D10**: Phase 5's hoist **stays landed through this plan**, unexamined. It is proved equal and
  kernel-neutral; whether its `certA`-only justification is enough is task 781's decision, not a
  phase here. No phase re-measures it, and the summary states the open question rather than
  claiming the hoist as a measured win.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Shape D's `rfl` transfer across `withBx` holds in the probe but not in the landed module (the probe defines `vertsD` beside `verts`; the landing replaces `verts`'s body) | H | L | Phase 7 runs the scratch `example (G) (bx) : (G.withBx bx).verts = G.verts := rfl` against the edited `Timed.lean` **before** the aggregate build, so a transfer failure costs one scratch compile rather than a full build; a failure marks the phase `[BLOCKED]` and is raised, never papered over with a heartbeat bump |
| Shape D's isolated 73x does not propagate to `liveAt` / the `certA` `decide` clock, so the plan's headline figure overstates the deliverable | M | M | The caveat is recorded in Research Integration rather than suppressed; Phase 7's verification requires `(liveAt (-1)).card` and the `certA` `decide` clock to be re-measured against their Phase 5 values and the propagated factor stated plainly, including when it is 1.0x |
| The `succT` / `predT` `let`-hoists are zeta-equal in the probe's standalone form but break a `Finset.mem_filter`-shaped proof in the landed module | M | L | `mem_succT` / `mem_predT` are literally `Finset.mem_filter` today, and zeta-equality preserves that; Phase 7 re-reads both and the scoped build is what establishes it. The hoists are independent of the `verts` change, so either half can land alone |
| A body-only change to `verts` / `succT` / `predT` breaks a downstream proof that unfolded the old body (`rfl`, `decide`, `simp [verts]`) across Bridge, Stable, Sound, Complete, EmbedComplete, Tail, Check | H | M | `mem_verts` / `mem_succT` / `mem_predT` are preserved byte-identically as the interface and repaired from the new bodies first; the scoped build of `Timed.lean` plus `Bridge.lean` and `Complete.lean` runs before the aggregate; a break is fixed forward in the named file, never by weakening a statement |
| The one-line `Complete.lean` docstring edit is read by a future reader as a code change to that file, or drags the file into a wider repair | L | M | Phase 7's Files to modify names it as prose-only and its Non-Goals forbid any declaration there being added, removed or re-proved; `git diff -- …/Complete.lean` showing only comment lines is a phase-close check |
| `Complete.lean` is not in 716's declared `file_scope` in `state.json`, so the orchestrator's overlap gate cannot see the new territory | M | M | The widening is declared here in Phase 7's Files to modify, which is what `plan-file-scope-harvest.sh` reads at plan postflight; the edit is one comment line, so a collision would be textual and trivially resolvable rather than semantic |
| `certB`'s larger closure keeps its `decide` out of reach even after all three fixes | M | M | Phase 8 runs it under a bounded waiter (`context/patterns/bounded-build-waiter.md`), and on non-return closes the second row as a reasoned exclusion citing its own measurement rather than leaving the phase open |
| A raised heartbeat cap hides a future regression as build time | M | M | No `maxHeartbeats 0` in landed source (Non-Goals); the cap is explicit and finite, and Phase 8 adds a separate heartbeat-capped guard on the embedded witness so a cost regression fails rather than crawls |
| C2's baseline is a strict string equality over ordered output, so a mis-placed `#print axioms` line fails the gate for a purely positional reason | L | M | Phase 8 inserts any new `#print axioms` line and its baseline line at matched positions and runs the gate before committing; the gate's own diff names the divergence |
| Phase 5's open question is read as settled because the hoist is landed | M | M | D10 and the Open Question subsection state it as open; Phase 9's summary records it as open with task 781 named, and no figure in the summary attributes a win to the hoist |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 2, 7 |
| 8 | 9 | 8 |

Phases within the same wave can execute in parallel.

### Phase 1: Rerunnable harness and the pre-change baseline [COMPLETED]

**Goal**: Every figure the later phases compare against is measured in this round, by a harness
that cannot report 0 ms for an unfinished computation, and the two plan-time verdicts the
deliverable rests on are re-confirmed before any library file is touched.

**Tasks**:
- [x] Write `specs/716_sliced_certificate_liveat_nontermination/probes/16_baseline.lean` carrying
      the corrected harness shape only (emit the value through an `IO` write, read the clock
      after; never bind the measured value to a pure `let` between two `IO.monoMsNow` reads).
      Header: which figures it measures, and that probes 01-09 of this task carry the broken
      harness and are not citable.
- [x] Measure, at the pinned self-loop embedded witness `WitnessFamily.Embedded.liveFamily.sliced
      (-1)`: `verts.card`, `fwdLiveT.card`, `bwdLiveT.card`, `(liveAt (-1)).card`. These are the
      numbers the regression guard and every "after" figure are read against.
- [x] Measure, at the slab-carrying width-2 total-edge certificate (the Phase 2 construction,
      written here as a scratch copy): the structural sizes (`Fintype.card Pos`, `verts.card`,
      `winTimes.card`, `(posAt 0).card`) and the `verts` / `predT` stage times.
- [x] Re-confirm the two plan-time verdicts in a scratch file compiled by
      `lake env lean`: `c36Sliced [c36Snce]` evaluates `true` at the slab-carrying certificate,
      and `Certifies` proves by `decide` under `set_option maxHeartbeats 2000000`. Record the wall
      clock.
- [x] Write `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` with one row per
      measured figure: name, value, how measured, and whether it confirms or contradicts the
      report's carried figure. Contradictions are recorded, not reconciled.
- [x] Record via `issue-record.sh` (`kind: win` or `issue`) whether any carried figure failed to
      reproduce, and attest explicitly if nothing arose.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The report's carried figures named under Research Integration
(20.7 s embedded `liveAt (-1)`; `verts` 9 ms / `fwdLiveT` 7636 ms / `bwdLiveT` 1614 ms at the
embedded witness; 1101 ms `verts` and 19119 ms for 16 `predT` at `certA`) are hypotheses carried
from `reports/01_liveat-nontermination-profile.md`, not facts. This phase's own measurement is
what the later phases cite; where it disagrees with the report, the report is recorded as
superseded in `progress-file.md`.

**Tier Justification**: Every file written is a `specs/**` probe or progress file compiled
standalone by `lake env lean`, whose exit status and emitted figures are the covering check; no
module under `FormalSystem/` is edited, so no library build surface is touched.

**Files to modify**:
- `specs/716_sliced_certificate_liveat_nontermination/probes/16_baseline.lean` - new; the
  corrected-harness baseline probe
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - new; the measured
  figure table

**Verification**:
- `lake env lean` on the probe exits 0 and every stage prints a non-zero millisecond figure (a
  `0 ms` stage is the broken-harness symptom and fails the phase)
- The two re-confirmation goals both succeed: `c36Sliced [c36Snce] … = true` printed, and the
  `decide` goal elaborates with no error under the finite heartbeat cap
- `progress-file.md` carries a row for each figure the later phases will cite, with no row
  reading "carried from the report"

---

### Phase 2: Land the total-edge Tier-2 witness, its C36 row and its C2 pin [COMPLETED]

**Goal**: The sliced class carries a second interesting witness — a width-2 total-edge
certificate at the `snce`/`⊡` target `Pp → ⊡Pp` — as a named closed-term theorem in the library,
with the C36 inventory row and the C2 axiom pin that the inventory's own admission bar requires.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean`
      immediately before editing (concurrent-sibling discipline), then add
      `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples` and confirm the
      module still builds — this re-confirms D2's cycle-freedom with the build rather than with
      the plan's grep.
- [x] Add, in a new `PlusSlicedCertificate.TotalEdge` namespace inside that module and in the
      signatures fixed by `## Lean Challenge Statements` below: `sliceA` (width 2, total edge,
      labelling `{atom p, snceP p}` at `w = 1` and `∅` at `w = 0`), `pathA`, `certA`, and
      `certA_certifies : certA.Certifies := by decide` under
      `set_option maxHeartbeats 2000000 in`. A module docstring paragraph states what this witness
      adds over `liveFamily_sliced_certifies`: a `snce`-kind closure, a width above 1, and a
      total edge relation rather than a self-loop.
- [x] Extend the module's `## Main Results` list with the new theorem, in the existing style.
- [x] Add the `witness` row to `scripts/certificate-witness-inventory.txt` directly after the
      existing `PlusSlicedCertificate.Certifies` row, declaration names relative to
      `FormalSystem.Metalogic.Decidability`, kinds field `snce`, closure term
      `plusClosureOf (([] : PlusContext) ++ [targetA c36P])`, interest expression
      `c36Sliced [c36Snce] PlusSlicedCertificate.TotalEdge.certA`.
- [x] Add the matched C2 pair in `scripts/check-module-invariants.sh`: one `#print axioms` line in
      the `AX_SRC` heredoc and one baseline line in `AXIOM_BASELINE`, at **matched positions**
      (the comparison is a strict string equality over ordered output), directly after the
      `liveFamily_sliced_certifies` pair, expecting `[propext, Classical.choice, Quot.sound]`.
- [x] Run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` detached, then
      `bash scripts/check-module-invariants.sh` and read the C2, C36a and C36b lines.
- [x] Record the measured `decide` wall clock for the landed declaration in `progress-file.md`,
      as the "before" figure the performance phases are read against.
- [ ] **Contingency, declared here rather than discovered** *(deviation: not triggered — `c36Sliced` evaluated true and `Certifies` proved, so the contingency branch was not taken)*: if `c36Sliced` evaluates `false` or
      `Certifies` fails at the landed construction despite Phase 1's confirmation, land the
      theorem and the C2 pin anyway and close the inventory-row sub-step as a
      `#### Reasoned Exclusions` record citing the failing C36b output verbatim; do **not** widen
      the construction further without re-measuring `Certifies`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the edit is confined to exactly three files
(`Examples.lean`, `certificate-witness-inventory.txt`, `check-module-invariants.sh`) and that
`targetA` / `closA` / `snceP` become reachable from `Examples.lean` through one added import.
Confirm by `git status --short` naming only those three files at phase close, and by the scoped
build succeeding with no further import added.

**Tier Justification**: `bash scripts/check-module-invariants.sh` (C2's axiom-pin string equality
and C36a/C36b's non-vacuity evaluation) is the covering check for both non-Lean edits, and the one
Lean module edited is the leaf `Examples.lean`, whose sole dependent `PlusSlicedCertificate.lean`
is built in the same scoped guarded build.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` - the added import,
  the `TotalEdge` namespace, and the Main Results entry
- `scripts/certificate-witness-inventory.txt` - one new `witness` row
- `scripts/check-module-invariants.sh` - one matched `#print axioms` / `AXIOM_BASELINE` pair
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the measured figure

**Verification**:
- The guarded scoped build reports green through the guard's own `result`
- `bash scripts/check-module-invariants.sh`: C2 PASS, C36a PASS, C36b PASS with the new row's
  `#eval` line reading `card=6 interesting=true`
- `grep -c 'sorry\|:= True\|:= trivial' Examples.lean` outside docstring prose returns 0, and the
  landed `set_option maxHeartbeats` value is finite (not `0`)
- `git status --short` names only the four files enumerated above

---

### Phase 3: Early-exit iteration, additive in Fixpoint.lean [COMPLETED]

**Goal**: `Fixpoint.lean` carries an early-exit form of both iterations — one that stops applying
the operator once it is fixed — proved unconditionally equal to the existing fixed-count form, with
`iter` / `gfp` / `lfp` themselves untouched.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean`
      immediately before editing.
- [x] In `namespace Nu`, add in the signatures fixed below: `iter_succ_comm` (the shift lemma
      `iter V F (n + 1) = iter (F V) F n`), `iterTo` (the top-down loop of D5, with
      `[DecidableEq α]` as an instance argument on the new definition only), `iterTo_eq_iter`,
      `gfp'`, `gfp'_eq_gfp`. A section docstring states why the loop is top-down and not a
      bottom-up stability test (D5), and that `iter` / `gfp` deliberately keep no `DecidableEq`
      requirement (D6).
- [x] In `namespace EUFix`, add: `iterFrom` (the start-parameterized iteration), `iterFrom_empty`
      (it agrees with `iter` at the empty start), `iterFrom_succ` (the shift lemma), `iterTo`,
      `iterTo_eq_iterFrom`, `lfp'`, `lfp'_eq_lfp`. `EUFix` already carries `[DecidableEq α]` at
      namespace level, so no instance argument is added.
- [x] `exists_stab` / `iter_stab` are **cited, not re-proved**: the report records that they
      already supply the termination argument an early-exit form needs, so the equality proofs are
      congruence inductions and introduce no new termination obligation. Confirm no new
      `termination_by` or `decreasing_by` clause is needed.
- [x] Measure the early-exit saving in
      `specs/716_sliced_certificate_liveat_nontermination/probes/17_early_exit.lean`: at the
      embedded witness, hand-wire `Nu.gfp' G.verts G.bwdLiveStep` and `Nu.gfp G.verts
      G.bwdLiveStep` side by side under the Phase 1 harness and record both wall clocks. No landed
      definition is switched yet, so this is a measurement of the new code, not of the library.
- [x] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixpoint` detached; record the
      measured factor in `progress-file.md`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the change is purely additive — twelve new declarations
and no edit to any existing one in `Fixpoint.lean`. Confirm with
`git diff -- FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` showing only
insertions, and with `git diff --stat` reporting zero deletions in that file.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixpoint` is the covering check, because
the change is additive-only (Scope Hypothesis) and so no existing declaration's statement or body,
and therefore no dependent module's elaboration, is affected.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` - additive: the `Nu`
  and `EUFix` early-exit forms and their equality lemmas
- `specs/716_sliced_certificate_liveat_nontermination/probes/17_early_exit.lean` - new; the
  side-by-side measurement
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the measured factor

**Verification**:
- The guarded scoped build reports green; `lake exe lint-style` reports no new finding on the file
- `#print axioms` on `Nu.gfp'_eq_gfp` and `EUFix.lfp'_eq_lfp` in a scratch file: no `sorryAx`,
  profile within `[propext, Classical.choice, Quot.sound]`
- The probe prints two wall clocks, both non-zero, and `progress-file.md` records their ratio
- `git diff --stat` shows zero deleted lines in `Fixpoint.lean`

---

### Phase 4: Switch the four liveness fixpoints onto the early-exit forms [COMPLETED]

**Goal**: `untlLive`, `snceLive`, `fwdLiveT` and `bwdLiveT` compute through the early-exit forms,
with every landed theorem about them unchanged in statement and repaired through a bridging `_eq`
lemma rather than re-proved.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean`
      immediately before editing.
- [x] Switch the four bodies: `untlLive` / `snceLive` to `EUFix.lfp'`, `fwdLiveT` / `bwdLiveT` to
      `Nu.gfp'`.
- [x] Add the four bridging lemmas in the signatures fixed below — `untlLive_eq_lfp`,
      `snceLive_eq_lfp`, `fwdLiveT_eq_gfp`, `bwdLiveT_eq_gfp` — each stating equality with the
      unprimed form and each proved by `Nu.gfp'_eq_gfp` / `EUFix.lfp'_eq_lfp`.
- [x] Repair the immediate consequences in the same module by rewriting through those four
      lemmas, never by weakening a statement: `untlLive_mono`, `snceLive_mono`, `fwdLiveT_subset`,
      `bwdLiveT_subset`, `liveT_subset`, `fwdLiveT_fixed`, `bwdLiveT_fixed`, `fwdLiveT_greatest`,
      `bwdLiveT_greatest`, and anything below them in the file that the build names.
- [x] Build the changed module plus its one direct dependent, `Bridge.lean`, then the whole *(deviation: altered — the build named TWO files needing repair, not one: `Bridge.lean` (two `unfold untlLive`/`unfold snceLive` sites) and `FixtureStable.lean` (one `rw [untlLive]` that hit a whnf heartbeat timeout). `FixtureStable.lean` is not a direct dependent of `LiveFix.lean` and so was invisible to the plan-time grep; both were fixed forward through the bridging lemmas, no statement weakened)*
      `PlusSlicedCertificate` aggregate, detached through the guard. A failure in
      `Stable.lean` / `Sound.lean` / `Complete.lean` / `EmbedComplete.lean` / `Tail.lean` /
      `Check.lean` is fixed forward in the file the build names.
- [x] Re-measure under the Phase 1 harness: `(liveAt (-1)).card` at the embedded witness, and the
      `decide` wall clock of `TotalEdge.certA_certifies`. Record both against Phase 1's and Phase
      2's figures in `progress-file.md`.
- [x] Record via `issue-record.sh` whether any downstream proof broke, and in which file.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts the blast radius is `LiveFix.lean` plus its single direct
dependent `Bridge.lean` (established at plan time by `grep -rln 'PlusSlicedCertificate.LiveFix'
FormalSystem/`, which named only `Bridge.lean` and the aggregator) and that no statement anywhere
changes. Confirm by re-running that grep before editing and by `git diff` showing no edit to any
theorem's statement line — only to bodies and to the four new declarations.

**Tier Justification**: The four definition bodies are consumed by proofs in `Bridge.lean` and
transitively below it, so a single-module build cannot observe a break; the build of `LiveFix.lean`
plus its enumerated one-hop dependent `Bridge.lean`, followed by the guarded
`PlusSlicedCertificate` aggregate build, is the covering check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` - the four switched
  bodies, the four bridging lemmas, and the in-module proof repairs
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean` - *(widened during
  execution)* two `unfold` sites rewritten through the bridging lemmas
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean` - *(widened
  during execution)* one `rw [untlLive]` rewritten through `untlLive_eq_lfp`
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the before/after pair

**Verification**:
- Guarded build of `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Bridge` and of
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` both report green through the
  guard's own `result`
- `#print axioms` on `PlusSlicedCertificate.fwdLiveT_eq_gfp`, `bwdLiveT_eq_gfp` and on
  `TotalEdge.certA_certifies`: no `sorryAx`, profiles unchanged from Phase 2
- `progress-file.md` records a measured `liveAt (-1)` figure and a measured `certA` `decide`
  figure, each beside its pre-phase value
- `git diff -- …/LiveFix.lean` shows no change to any `theorem` signature line

---

### Phase 5: Hoist the vertex-independent inner fixpoint out of the per-vertex filter [COMPLETED]

**Goal**: `untlLive X g e` / `snceLive X g e` are computed once per contracted set and per
eventuality-shaped closure member rather than once per vertex, with `mem_fwdLiveStep` /
`mem_bwdLiveStep` preserved exactly, so nothing below the module can observe the change.

**Tasks**:
- [x] Re-read `LiveFix.lean` immediately before editing.
- [x] Add, in the signatures fixed below: `untlLiveOf` / `snceLiveOf` (the inner fixpoint as a
      total function of the formula, `∅` off shape), `untlTable` / `snceTable` (the closure paired
      with that function's value, as a `Finset.image` — **not** via `Finset.toList`, which is
      noncomputable and would make the whole `decide`-facing stack noncomputable),
      `untlLiveAtTab` / `snceLiveAtTab` (the per-formula clause read against the table, with the
      existential bounded by the table so the clause stays decidable by a bounded quantifier), and
      `untlLiveAtTab_eq` / `snceLiveAtTab_eq` (pointwise equality with `untlLiveAt` /
      `snceLiveAt`, proved from `Finset.mem_image`).
- [x] Re-express the `fwdLiveStep` / `bwdLiveStep` bodies as a filter against the precomputed
      table, with the table bound once outside the filter lambda. The equality with the old body
      is a `Finset.filter_congr` on a pointwise-equal predicate, discharged by the two `_eq`
      lemmas.
- [x] Re-prove `mem_fwdLiveStep` / `mem_bwdLiveStep` from the new bodies, with their statements
      byte-identical to the current ones. These two theorems are the module's interface; if either
      cannot be restated unchanged, mark the phase `[BLOCKED]` and raise it rather than adjusting
      the statement.
- [x] Confirm the short-circuit the report measured is preserved: the clause's `decide (… ∈
      v.1.2.1 → v ∈ …)` form must still avoid evaluating the inner fixpoint at a vertex whose
      label carries no eventuality. State in the docstring whether the table form evaluates the
      fixpoint eagerly for every table member (it does) and why that is still a net win (the
      count drops from per-vertex to per-closure-member).
- [x] Guarded build of `LiveFix.lean`, `Bridge.lean` and the `PlusSlicedCertificate` aggregate;
      then re-measure `(liveAt (-1)).card` and the `certA` `decide` clock and record both.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts that the only eventuality-shaped closure members are the
`untl` and `snce` constructors (so the two tables cover the whole clause set), and that
`mem_fwdLiveStep` / `mem_bwdLiveStep` are the complete downstream interface of the two
contractions. Confirm the first by reading `untlLiveAt` / `snceLiveAt`'s own `match` arms, and the
second by `grep -rn 'fwdLiveStep\|bwdLiveStep' FormalSystem/` and checking every hit outside
`LiveFix.lean` routes through one of those two theorems or through `_mono` / `_subset`.

**Tier Justification**: Same surface as Phase 4 — two definition bodies consumed through
`Bridge.lean` and transitively below it — so the covering check is the build of `LiveFix.lean`
plus its enumerated one-hop dependent `Bridge.lean`, followed by the guarded
`PlusSlicedCertificate` aggregate build.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` - the two tables, the
  two table-read clauses, the two equality lemmas, the two re-expressed contraction bodies, and
  the two re-proved characterizations
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the before/after pair

**Verification**:
- Guarded builds of `…PlusSlicedCertificate.Bridge` and `…PlusSlicedCertificate` report green
- `mem_fwdLiveStep` and `mem_bwdLiveStep` statements are byte-identical to their pre-phase form
  (`git diff` shows no change on those two signature lines)
- `#print axioms` on `untlLiveAtTab_eq`, `snceLiveAtTab_eq`: no `sorryAx`
- `progress-file.md` records the measured `liveAt (-1)` and `certA` `decide` figures beside their
  Phase 4 values

---

### Phase 6: DECISION GATE -- measure a hand-wired leaf cache before landing it [COMPLETED]

**Goal**: Decide, on a measurement rather than on the report's `#eval` figures, whether the leaf
cache is worth its blast radius — and under which evaluator it pays.

**Tasks**:
- [x] Write `specs/716_sliced_certificate_liveat_nontermination/probes/18_cache_gate.lean`: a
      hand-wired mirror of `posTable` / `posAtC` / `vertsC` / `predTC` / `succTC` at the Phase 2
      certificate, in the shape Phase 7 would land (the `G`-parameterized table with the
      `posAt` off-range fallback), **not** the hardcoded-time-list shape probe 11 used.
- [x] Measure under `#eval`, with the Phase 1 harness: `vertsC`, the sum of `predTC` cardinalities
      over `vertsC`, one `bwdLiveStep` through the mirror, and the full `bwdLiveT`.
- [x] Measure under `decide`, in a separate scratch file: the `Certifies`-shaped goal through the
      mirror, against the Phase 5 figure for the same goal through the library.
- [x] **Gate criterion, fixed here**: Phase 7 lands the cache iff the mirror beats the post-Phase-5
      library figure by at least 2x on the `decide` measurement, or by at least 2x on the `#eval`
      `bwdLiveT` measurement with no `decide` regression. Record the verdict, the two numbers it
      rests on, and the arithmetic, in `progress-file.md`.
- [x] Record explicitly whether the `G`-parameterized form loses the interpreter-level sharing D4
      anticipates (`G.posTable` re-run per `posAtC` call). If it does, state whether a
      `let`-bound entry point recovers it, since that determines Phase 7's shape.
- [x] Record via `issue-record.sh` the gate's verdict, `kind: win` on a pass and `kind: issue` on
      a fail.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the cache's reach is the three definitions reachable from
one module (`verts`, `succT`, `predT` in `Timed.lean`) and that `succP` / `predP` are **not**
reachable, because they live in `Position.lean`, which does not import `Window.lean` and so cannot
see `winTimes`. Confirm by reading both modules' import headers before writing the mirror; if
`Position.lean` can in fact see `winTimes`, the mirror and Phase 7 widen to `succP` / `predP` too
and the gate is re-measured.

**Tier Justification**: Every file written is a `specs/**` probe compiled standalone by
`lake env lean`, whose exit status and emitted figures are the covering check; no module under
`FormalSystem/` is edited in this phase.

**Files to modify**:
- `specs/716_sliced_certificate_liveat_nontermination/probes/18_cache_gate.lean` - new; the
  hand-wired mirror and its two measurements
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the gate verdict and the
  numbers it rests on

**Verification**:
- `lake env lean` on both files exits 0; every `#eval` stage prints a non-zero millisecond figure
- `progress-file.md` carries the gate verdict with both numbers and the ratio written out, and a
  one-line statement of whether interpreter-level sharing was lost
- The verdict is stated as PASS or FAIL, never as "promising" or "inconclusive"; an inconclusive
  measurement is a FAIL for the purposes of Phase 7

---

### Phase 7: Shape D -- the posAt-hoisted verts and the succT/predT let-hoists [COMPLETED]

**Goal**: `verts` calls `posAt` once per window time instead of once per (position, time) pair, by
`biUnion`-ing the position space over `winTimes` rather than filtering the product against it; and
`succT` / `predT` bind `verts` and the `succP` / `predP` value once outside their filter lambdas
rather than once per element. `mem_verts`, `mem_succT` and `mem_predT` keep their statements
byte-identical, `Complete.lean` keeps all five of its `rfl`-proved `withBx_*` transfers, and no
cache, table or equality lemma is introduced.

**Established before this phase runs** (probes 21-24; see Research Integration and D7/D9 — this is
not re-derived here): the `biUnion` shape transfers across `withBx` by `rfl`, admits the
`mem_verts` statement unchanged, equals the landed `verts` unconditionally, and measures 15 ms
against 1093 ms at `certA`. The `succT`/`predT` `let`-hoists are zeta-equal to the landed bodies
and transfer by `rfl`. The table shape is what fails, and specifically its `match` sitting inside
`Finset.filter`'s `DecidablePred` instance argument.

**Tasks**:
- [x] Re-run `probes/24_shapeD_measure.lean` against the currently built library and record its
      three figures in `progress-file.md` as this-round measurements. This discharges the carried
      15 ms / 1093 ms pair named in the Scope Hypothesis below. If the factor has moved, record the
      new figure and proceed on it; do not re-open the route decision on a smaller-but-still-better
      factor.
- [x] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` immediately
      before editing (concurrent-sibling discipline).
- [x] Replace `verts`'s body with
      `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))`. Add no `posTable`, no
      `posAtC`, no `let`-bound table and no lookup inside any `Finset.filter` predicate — Non-Goals
      rules those out and `probes/23_table_defeq_failure.lean` is the standing reproduction of why.
- [x] Re-prove `mem_verts` from the new body with its statement **byte-identical** to
      `v ∈ G.verts ↔ v.2 ∈ G.winTimes ∧ v.1 ∈ G.posAt v.2`, through `Finset.mem_biUnion` and
      `Finset.mem_image`. `probes/21_shapeD_transfer.lean`'s `mem_vertsD` is the proof script
      modulo the rename; adapt it rather than re-deriving one. If the statement cannot be restated
      unchanged, mark the phase `[BLOCKED]` and raise it rather than adjusting the statement.
- [x] Land the `succT` / `predT` `let`-hoists in the shape `probes/22_lethoist_transfer.lean`
      pins (`let V := G.verts; let u := G.nextTime v.2; let S := G.succP v.2 v.1;
      V.filter (fun w => w.2 = u ∧ w.1 ∈ S)`, and its backward mirror). These are zeta-equal to the
      landed bodies, so `mem_succT` / `mem_predT` — today literally `Finset.mem_filter` — should
      need no repair; confirm rather than assume, and repair through the same lemma if the build
      names them.
- [x] **Confirm the `withBx` invariant survives, before the aggregate build.** In
      `specs/716_sliced_certificate_liveat_nontermination/probes/25_shapeD_landed_transfer.lean`,
      compiled standalone by `lake env lean` against the edited module: `example (G) (bx) :
      (G.withBx bx).verts = G.verts := rfl`, and the same for `succT` and `predT`. This is the
      exact check the earlier table shape failed; running it here costs one scratch compile instead
      of a full build. A failure marks the phase `[BLOCKED]`; it is **not** addressed by raising
      `maxHeartbeats` in `Complete.lean` (Non-Goals, D9).
- [x] Add one prose line to `Complete.lean`'s `### What a changed box guess does and does not move`
      docstring section, beside its two named exceptions, recording the third instance of the same
      pattern: a lookup whose `match` sits inside `Finset.filter`'s `DecidablePred` instance
      argument does not transfer, because the scrutinee is a `List.find?` over a range built from
      `G.winLo` / `G.winHi` — projections of the variable `G` — so the matcher cannot iota-reduce
      and `isDefEq` returns false rather than falling back to congruence. Prose only: no
      declaration in that file is added, removed, re-proved or re-stated.
- [x] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Timed` detached, then
      `…PlusSlicedCertificate.Complete`, then the `…PlusSlicedCertificate` aggregate. A break is
      fixed forward in the file the build names; a statement is never weakened to accommodate one.
- [x] **Re-measure the propagated figures, not only the isolated one.** The factor that selected
      Shape D measures `verts` alone; whether it propagates is unmeasured. Record
      `(liveAt (-1)).card` at the pinned embedded witness and the `certA_certifies` `decide` wall
      clock against their Phase 5 values in `progress-file.md`, and state the propagated factor
      plainly — including when it is 1.0x. A phase that lands a 73x isolated gain and a neutral
      propagated one has still landed correctly; the summary must say so.
- [x] Record via `issue-record.sh` (`kind: win` or `issue`) whether the propagated factor matched
      the isolated one, and attest explicitly if nothing arose.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Two hypotheses, both confirmable at implementation time. (1) The edit is
confined to `Timed.lean` plus **one prose line** in `Complete.lean`, and `mem_verts` /
`mem_succT` / `mem_predT` are the complete downstream interface of the three re-expressed
definitions — confirm by `grep -rn 'G.verts\|succT\|predT' FormalSystem/` and checking every hit
outside `Timed.lean` routes through one of those three or through `_subset` / `fst_mem_*` /
`snd_of_mem_*`; any hit that unfolds a body directly widens this phase's file list and must be
recorded before it is edited. (2) The figures **15 ms (Shape D) against 1093 ms (landed `verts`)
at `certA`, identical card 16** are CARRIED from `probes/24_shapeD_measure.lean` — its three
`#time #eval` lines, which are the only durable source for them — not facts of this round; the
phase's first task re-runs probe 24 to discharge them.

**Tier Justification**: `verts`, `succT` and `predT` are cited across `Bridge.lean`, `Stable.lean`,
`Sound.lean`, `Complete.lean`, `EmbedComplete.lean`, `Tail.lean` and `Check.lean`, so a
single-module build cannot observe a break; the build of `Timed.lean` plus its enumerated
dependents `Complete.lean` and `Bridge.lean`, followed by the guarded `PlusSlicedCertificate`
aggregate build, is the covering check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` - the `biUnion`-shaped
  `verts` body, the two `let`-hoisted `succT` / `predT` bodies, and the re-proved `mem_verts`
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean` - **prose only**: one
  line in the `### What a changed box guess does and does not move` docstring section recording the
  third instance of the stuck-matcher pattern. No declaration in this file is touched
- `specs/716_sliced_certificate_liveat_nontermination/probes/25_shapeD_landed_transfer.lean` - new;
  the three `withBx` `rfl` transfer checks against the edited module
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the re-derived probe-24
  figures and the isolated/propagated pair

**Verification**:
- `lake env lean` on `probes/25_shapeD_landed_transfer.lean` exits 0, with all three `rfl` transfer
  checks accepted — run before the aggregate build, not after
- Guarded builds of `…PlusSlicedCertificate.Timed`, `…PlusSlicedCertificate.Complete` and
  `…PlusSlicedCertificate` all report green through the guard's own `result`
- `mem_verts`, `mem_succT`, `mem_predT` statements byte-identical to their pre-phase form
  (`git diff` shows no change on those three signature lines)
- `git diff -- …/Complete.lean` shows only comment/docstring lines changed, and
  `grep -c 'withBx_' …/Complete.lean` is unchanged from its pre-phase value
- `grep -n 'posTable\|posAtC\|find?' …/Timed.lean` returns nothing
- `#print axioms` on `PlusSlicedCertificate.mem_verts` in a scratch file: no `sorryAx`, profile
  within `[propext, Classical.choice, Quot.sound]`
- `progress-file.md` records the re-derived probe-24 figures, and the measured `liveAt (-1)` and
  `certA` `decide` figures beside their Phase 5 values, with the propagated factor stated

---

### Phase 8: Settle certB, and pin a heartbeat-capped cost regression guard [COMPLETED]

**Goal**: The second Tier-2 inventory row is resolved one way or the other on a measurement, and
the blowup cannot return unnoticed.

**Tasks**:
- [x] Reconstruct `certB` from
      `specs/716_sliced_certificate_liveat_nontermination/probes/15_kernel_certB.lean`, apply the
      same slab repair Phase 2 established (so `c36Sliced` can be satisfied at all), and evaluate
      the interest expression **before** attempting `Certifies` — a row that cannot be interesting
      is not worth a multi-hour `decide`.
- [x] Run `certB.Certifies` by `decide` under an explicit finite `maxHeartbeats`, detached, with a
      hard timeout and writer liveness via `kill -0` on the captured PID per
      `context/patterns/bounded-build-waiter.md`. One waiter per log; never `ps | grep`.
- [x] **If it returns**: land `TotalEdge.certB` and `certB_certifies` beside `certA` in
      `Examples.lean`, add its inventory row and its matched C2 pair, and re-run
      `check-module-invariants.sh`.
- [ ] **If it does not return within the bound** *(deviation: not triggered — the `decide` returned in 12 s, so the returning branch above applies and no Reasoned Exclusions record is written)*: close the second-row sub-step as a
      `#### Reasoned Exclusions` record whose Evidence column carries the bound, the elapsed time
      and the heartbeat cap used. Do not raise the cap and retry indefinitely, and do not state
      certB as unreachable in general — state only what was measured.
- [x] Add the cost regression guard in `Examples.lean`: a heartbeat-capped `decide` goal on the
      pinned self-loop embedded witness's `liveAt`, with the cap set from Phase 1's and the
      post-fix measurements (tight enough that the pre-fix cost would exceed it, loose enough not
      to be flaky), and a docstring stating exactly that — the cap is the guard, and a regression
      fails the build rather than slowing it.
- [x] Record the final measured figures for every landed fix in `progress-file.md`.

**Timing**: 1.5 hours

**Depends on**: 2, 7

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts `certB` differs from `certA` only in carrying a larger
closure (its target adds an implication, a negation and the inner conditional, growing
`2^|closure|` by roughly an order of magnitude) — a figure carried from
`reports/01_liveat-nontermination-profile.md`. Confirm by evaluating
`(plusClosureOf (Γ ++ Del)).card` and `Fintype.card certB.Pos` before running the `decide`, and
record both; the carried "order of magnitude" is a hypothesis, not a fact.

**Tier Justification**: The guard and any `certB` landing edit the default-build module
`Examples.lean`, whose sole direct dependent is `PlusSlicedCertificate.lean`; the build of both,
plus `bash scripts/check-module-invariants.sh` for the C2/C36 baseline edits, is the covering
check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` - the regression
  guard, and `certB` plus `certB_certifies` on the returning branch only
- `scripts/certificate-witness-inventory.txt` - one further `witness` row, on the returning
  branch only
- `scripts/check-module-invariants.sh` - one further matched C2 pair, on the returning branch only
- `specs/716_sliced_certificate_liveat_nontermination/probes/19_certb.lean` - new; the `certB`
  reconstruction, its interest evaluation and its bounded `decide` run
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the final figures

**Verification**:
- Guarded build of `…PlusSlicedCertificate` reports green, and the regression guard's goal
  elaborates within its declared finite cap
- `bash scripts/check-module-invariants.sh`: C2, C36a, C36b all PASS
- On the returning branch: the new C36b `#eval` line reads `interesting=true`; on the
  non-returning branch: a `#### Reasoned Exclusions` record is present with the bound, the elapsed
  time and the cap
- `progress-file.md` carries a measured figure for every landed fix, with no figure marked carried

---

### Phase 9: Full verification, axiom pins, and the record [COMPLETED]

**Goal**: Everything landed is verified by the complete gate set, every Goals declaration is axiom
pinned, and the summary states the measured before/after figures, what was excluded and why, and
what remains open.

**Tasks**:
- [x] **Regenerate the derived surfaces every `.lean` edit forces**, before running the gates that
      check them: `bash scripts/check-module-invariants.sh --emit-inventory` (rewrites each
      `<!-- BEGIN GENERATED: inventory -->` block on the edited files' ancestor-directory chain —
      `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md`) and
      `bash scripts/typst-sync-check.sh --fix` (regenerates `typst/generated/status.typ`, whose
      counts cover `FormalSystem/` recursively). Neither script stages anything; stage the
      regenerated files explicitly with this phase's commit. Omitting this step blocks on the
      pre-commit `typst-sync-check.sh` gate or fails `check-module-invariants.sh`'s INV check.
- [x] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project),
      detached; read the verdict through the guard's own `result`, never from a pipe exit code
- [x] `bash scripts/check-module-invariants.sh` (full mode, including C1/C2/C36b and INV)
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` and
      `bash scripts/typst-sync-check.sh`: both report the derived surfaces current
- [x] `lake exe lint-style` — no new finding on any file this task touched
- [x] `bash .claude/scripts/verify-deploy.sh` — the complete aggregator gate set
- [x] `bash .claude/scripts/check-task-references.sh` over every non-`specs/**` file touched (no
      task-number citation may appear in `FormalSystem/**` or `scripts/**` — in particular not in
      Phase 7's `Complete.lean` docstring line, which states the pattern and names no task)
- [x] `#print axioms` in a scratch file on every declaration named under `- **Goals**:` that
      landed: no `sorryAx`, every profile within `[propext, Classical.choice, Quot.sound]`.
      `posTable` / `posAtC` / `posAtC_eq` are **not** in that list and their absence is expected,
      not a gap — see the Decomposition Change subsection
- [x] `grep -n 'sorry\|sorryAx\|:= True\|:= trivial\|maxHeartbeats 0'` over every Lean file this
      task touched: nothing outside docstring prose
- [x] Write the summary artifact per `summary-format.md`, stating plainly: what landed (the
      witness row, the three fixes that passed their gates, the regression guard), what did not
      and why (each gate that failed, with its own measurement), the measured before/after figure
      for each landed fix, and the plan-time correction to the research report's recommendation 1
      that the C36 slab finding forced
- [x] The summary additionally records three things this round settled or left open, each in one
      short paragraph: (a) **the Phase 7 route** — the position-space leaf landed as Shape D rather
      than as a cache, what the rejected table shape fails on (D9's stuck matcher inside
      `Finset.filter`'s instance argument), and that three planned identifiers were dropped as a
      raised decomposition change; (b) **Shape D's isolated versus propagated figures**, stated
      separately and never conflated; (c) **Phase 5's hoist as an open question** — proved equal
      and kernel-neutral, justified by `certA` alone, with task 781 named as owning the
      stay-or-revert decision. No figure in the summary attributes a win to that hoist.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: full

**Files to modify**:
- `specs/716_sliced_certificate_liveat_nontermination/summaries/01_liveat-memoization-tier2-witness-summary.md` -
  the implementation summary, superseding the blocked-state version written at the Phase 7 block
- `typst/generated/status.typ` - regenerated by `typst-sync-check.sh --fix`; forced by any `.lean`
  edit, never hand-written
- `FormalSystem/Metalogic/README.md` - generated-inventory block, rewritten by
  `check-module-invariants.sh --emit-inventory`
- `FormalSystem/README.md` - same generated-inventory block, same generator
- `README.md` - same generated-inventory block, same generator
- No other file is edited by this phase. If a gate fails, the fix is forward
  (`context/contracts/recovery.md`) in the file the gate names, and the phase that owns that file
  is re-verified.

**Verification**:
- Every command above exits 0; the full guarded build reports green through the guard's own
  `result`
- `bash .claude/scripts/verify-deploy.sh` exit 0
- No `sorry`, `sorryAx`, vacuous placeholder, or `maxHeartbeats 0` in any touched Lean file
- The summary's three closing records are present and each names its evidence
- `git status --short` shows only files enumerated in Phases 1-8 plus this phase's outputs

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Examples
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

/-! ### Phase 3: the early-exit iterations -/

namespace Nu

variable {α : Type*}

/-- The shift lemma: one application of the operator can be moved into the start. -/
theorem iter_succ_comm (V : Finset α) (F : Finset α → Finset α) (n : ℕ) :
    iter V F (n + 1) = iter (F V) F n := sorry

/-- **The early-exit iteration.** Top-down, so that a stable step stops the recursion instead of
merely reporting stability at a level the bottom-up form would still pay for. -/
def iterTo [DecidableEq α] (F : Finset α → Finset α) (X : Finset α) : ℕ → Finset α
  | 0 => X
  | n + 1 => let Y := F X; if Y = X then X else iterTo F Y n

theorem iterTo_eq_iter [DecidableEq α] (F : Finset α → Finset α) (X : Finset α) (n : ℕ) :
    iterTo F X n = iter X F n := sorry

/-- **The greatest fixpoint, computed with early exit.** -/
def gfp' [DecidableEq α] (V : Finset α) (F : Finset α → Finset α) : Finset α :=
  iterTo F V (V.card + 1)

theorem gfp'_eq_gfp [DecidableEq α] (V : Finset α) (F : Finset α → Finset α) :
    gfp' V F = gfp V F := sorry

end Nu

namespace EUFix

variable {α : Type*} [DecidableEq α]

/-- The iteration from an arbitrary start, which the early-exit form needs in order to shift. -/
def iterFrom (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    ℕ → Finset α
  | 0 => X
  | n + 1 => step V succ isE isG (iterFrom V succ isE isG X n)

theorem iterFrom_empty (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (n : ℕ) :
    iterFrom V succ isE isG ∅ n = iter V succ isE isG n := sorry

theorem iterFrom_succ (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (X : Finset α) (n : ℕ) :
    iterFrom V succ isE isG X (n + 1)
      = iterFrom V succ isE isG (step V succ isE isG X) n := sorry

/-- **The early-exit iteration**, the `EUFix` mirror of `Nu.iterTo`. -/
def iterTo (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    ℕ → Finset α
  | 0 => X
  | n + 1 => let Y := step V succ isE isG X; if Y = X then X else iterTo V succ isE isG Y n

theorem iterTo_eq_iterFrom (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (X : Finset α) (n : ℕ) :
    iterTo V succ isE isG X n = iterFrom V succ isE isG X n := sorry

/-- **The `E[g U e]` fixpoint, computed with early exit.** -/
def lfp' (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : Finset α :=
  iterTo V succ isE isG ∅ (V.card + 1)

theorem lfp'_eq_lfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    lfp' V succ isE isG = lfp V succ isE isG := sorry

end EUFix

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ### Phase 4: the four switched liveness fixpoints, bridged to the unprimed forms -/

theorem untlLive_eq_lfp (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos)
    (g e : PlusFormula) :
    G.untlLive X g e = EUFix.lfp X G.succT (Fair.inSet X (G.atPosT e)) (G.atPosT g) := sorry

theorem snceLive_eq_lfp (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos)
    (g e : PlusFormula) :
    G.snceLive X g e = EUFix.lfp X G.predT (Fair.inSet X (G.atPosT e)) (G.atPosT g) := sorry

theorem fwdLiveT_eq_gfp (G : PlusSlicedCertificate Γ Del) :
    G.fwdLiveT = Nu.gfp G.verts G.fwdLiveStep := sorry

theorem bwdLiveT_eq_gfp (G : PlusSlicedCertificate Γ Del) :
    G.bwdLiveT = Nu.gfp G.verts G.bwdLiveStep := sorry

/-! ### Phase 5: the hoisted inner fixpoint -/

/-- The inner forward fixpoint as a total function of the formula, `∅` off the `untl` shape. The
total form is what lets the table be a `Finset.image`, which is computable where
`Finset.toList` is not. -/
def untlLiveOf (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) :
    PlusFormula → Finset G.TPos
  | .untl g e => G.untlLive X g e
  | _ => ∅

/-- The backward mirror. -/
def snceLiveOf (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) :
    PlusFormula → Finset G.TPos
  | .snce g e => G.snceLive X g e
  | _ => ∅

/-- The closure members paired with their inner forward fixpoint at the contracted set, built
once per `X` instead of once per vertex of `X`. -/
def untlTable (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) :
    Finset (PlusFormula × Finset G.TPos) :=
  (plusClosureOf (Γ ++ Del)).image fun ψ => (ψ, G.untlLiveOf X ψ)

/-- The backward mirror. -/
def snceTable (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) :
    Finset (PlusFormula × Finset G.TPos) :=
  (plusClosureOf (Γ ++ Del)).image fun ψ => (ψ, G.snceLiveOf X ψ)

/-- The forward liveness clause read against a precomputed table. The existential is bounded by
`tbl`, so the clause stays decidable by a bounded quantifier exactly as `untlLiveAt` is. -/
def untlLiveAtTab (G : PlusSlicedCertificate Γ Del)
    (tbl : Finset (PlusFormula × Finset G.TPos)) (v : G.TPos) : PlusFormula → Bool
  | .untl g e =>
      decide (PlusFormula.untl g e ∈ v.1.2.1 →
        ∃ q ∈ tbl, q.1 = PlusFormula.untl g e ∧ v ∈ q.2)
  | _ => true

/-- The backward mirror. -/
def snceLiveAtTab (G : PlusSlicedCertificate Γ Del)
    (tbl : Finset (PlusFormula × Finset G.TPos)) (v : G.TPos) : PlusFormula → Bool
  | .snce g e =>
      decide (PlusFormula.snce g e ∈ v.1.2.1 →
        ∃ q ∈ tbl, q.1 = PlusFormula.snce g e ∧ v ∈ q.2)
  | _ => true

theorem untlLiveAtTab_eq (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (v : G.TPos)
    {ψ : PlusFormula} (hψ : ψ ∈ plusClosureOf (Γ ++ Del)) :
    G.untlLiveAtTab (G.untlTable X) v ψ = G.untlLiveAt X v ψ := sorry

theorem snceLiveAtTab_eq (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (v : G.TPos)
    {ψ : PlusFormula} (hψ : ψ ∈ plusClosureOf (Γ ++ Del)) :
    G.snceLiveAtTab (G.snceTable X) v ψ = G.snceLiveAt X v ψ := sorry

/-! ### Phase 2: the width-2 total-edge Tier-2 witness -/

namespace TotalEdge

/-- The witness's atom. Every declaration below is a CLOSED term — a parameterized `certA` could
not be proved by `decide` and could not appear in the inventory's interest expression. -/
def atomP : Atom := Atom.mkBase "p"

/-- The one slice, repeated: width 2, total edge relation, and a labelling that carries `Pp` so
that the C36 interest expression's slab-occupancy conjunct is satisfied. -/
def sliceA : PlusSlice 2 (closA atomP) where
  edge := fun _ _ => true
  lab := fun w => if w = 1 then {PlusFormula.atom atomP, snceP atomP} else ∅
  lab_sub := sorry

/-- The target path: one backward and one forward labelled step. -/
def pathA : PlusGraphPath 2 (closA atomP) where
  back := [({PlusFormula.atom atomP, PlusFormula.top, snceP atomP}, 1)]
  mid := []
  fwd := [({PlusFormula.top, snceP atomP}, 0)]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  label_sub := sorry

/-- **The width-2 total-edge certificate** at the target `Pp → ⊡Pp`. -/
def certA : PlusSlicedCertificate ([] : PlusContext) [targetA atomP] where
  n := 2
  n_pos := sorry
  back := [sliceA]
  mid := []
  fwd := [sliceA]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  bx := fun _ => false
  target := pathA
  targetTime := 0

/-- **The sliced class's second interesting witness**: a total-edge certificate of width above 1,
at a `snce`-kind closure, carrying the `⊡` modality. -/
theorem certA_certifies : certA.Certifies := sorry

end TotalEdge

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project),
      detached, reports green through the guard's own `result`
- [ ] `bash scripts/check-module-invariants.sh` in full mode: C2 PASS (the axiom baseline matches
      exactly, including the new pairs), C36a PASS, C36b PASS with every row's interest expression
      reading `interesting=true` at a non-empty closure
- [ ] `lake exe lint-style`: no new finding on any file this task touched
- [ ] `bash .claude/scripts/verify-deploy.sh`: exit 0
- [ ] `bash .claude/scripts/check-task-references.sh`: no task-number citation in any
      `FormalSystem/**` or `scripts/**` file this task touched
- [ ] `#print axioms` on every landed Goals declaration: no `sorryAx`, every profile within
      `[propext, Classical.choice, Quot.sound]`
- [ ] No `sorry`, `sorryAx`, `:= True`, `:= trivial`, or `maxHeartbeats 0` in any touched Lean
      file, outside docstring prose
- [ ] Every `mem_*` characterization theorem this plan touches (`mem_fwdLiveStep`,
      `mem_bwdLiveStep`, `mem_verts`, `mem_succT`, `mem_predT`) is byte-identical in statement to
      its pre-task form
- [ ] The three `withBx` transfer checks of Phase 7 (`verts`, `succT`, `predT`, each by `rfl`
      against the edited `Timed.lean`) are accepted, and `Complete.lean`'s five `rfl`-proved
      `withBx_*` transfer declarations are unchanged
- [ ] `Timed.lean` contains no `posTable`, no `posAtC`, and no lookup inside a `Finset.filter`
      predicate
- [ ] The cost regression guard's heartbeat cap is finite and the embedded witness's `liveAt` goal
      elaborates within it
- [ ] Every performance figure in the summary is a this-round measurement recorded in
      `progress-file.md`, no figure is marked carried, and Shape D's isolated `verts` factor and
      its propagated `liveAt` / `decide` factor are stated as two separate figures

## Artifacts & Outputs

- `specs/716_sliced_certificate_liveat_nontermination/plans/02_shape-d-verts-biunion.md` (this file)
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` — the measured-figure table
- `specs/716_sliced_certificate_liveat_nontermination/probes/16_baseline.lean`,
  `17_early_exit.lean`, `18_cache_gate.lean`, `19_certb.lean`,
  `25_shapeD_landed_transfer.lean`
- `specs/716_sliced_certificate_liveat_nontermination/summaries/01_liveat-memoization-tier2-witness-summary.md`
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` — the Tier-2 witness
  and the regression guard
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` — the early-exit forms
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` — the switched fixpoints
  and the hoisted inner fixpoint
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` — the `biUnion`-shaped
  `verts` and the two `let`-hoisted neighbour functions
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean` — one docstring line
  recording the third stuck-matcher exception; no declaration changed
- `scripts/certificate-witness-inventory.txt` — the new `witness` row(s)
- `scripts/check-module-invariants.sh` — the new matched C2 pair(s)

## Rollback/Contingency

Each phase is one commit, so the ordinary rollback is `git revert` of the phase commit — the
phases are ordered by increasing blast radius (D3) precisely so that reverting a late one leaves
the earlier wins in place. The three performance phases are independently revertible: Phase 7
touches `Timed.lean` plus one comment line in `Complete.lean`, Phase 5 and Phase 4 only
`LiveFix.lean`, and Phase 3 is additive, so reverting any of them restores the previous measured
behaviour without touching the Tier-2 witness of Phase 2.

Phase 7's own contingency is declared rather than improvised. The phase's `rfl` transfer check runs
against the edited module **before** the aggregate build; if any of the three checks fails, the
phase is marked `[BLOCKED]` and raised with the failing goal quoted. It is not addressed by a
`maxHeartbeats` bump in `Complete.lean` (the failure mode is `isDefEq` returning false, not a
timeout), and not by adding propositional `withBx_*` transfer lemmas — that is the route D7
rejects, and re-opening it is a planning decision rather than an implementation one. Phase 8's
bounded `certB` run keeps its own contingency: a non-returning `decide` closes the second
inventory row as a `#### Reasoned Exclusions` record citing its own measurement.

The rejected table shape is preserved as the record of that route, at
`specs/716_sliced_certificate_liveat_nontermination/probes/20_phase7_shapeB_attempt.diff` and in
`git stash@{0}`. **No phase here drops that stash**: `git stash drop` is a forbidden destructive
operation under `.claude/rules/git-workflow.md`, and the diff is the durable artifact anyway.

If uncommitted work must be discarded to reach a passing build, do not: fix forward in the file
the build names, per `context/contracts/recovery.md`'s ladder. Only a genuine rollback decision
takes the snapshot-then-rollback rung, and then the invocation shape — including its
out-of-scope override flag — is the one `context/contracts/recovery.md` specifies, never a bare
precautionary `git-snapshot.sh` as a start-of-phase checkpoint. For an ordinary defensive
checkpoint before the Phase 7 body edits, use `bash .claude/scripts/git-snapshot.sh 716
--no-revert`, which is durable without reverting the working tree.
