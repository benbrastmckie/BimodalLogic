# Implementation Plan: Task #716

- **Task**: 716 - Profile and fix the PlusSlicedCertificate liveT/liveAt non-termination that blocks Tier-2 sliced certificate witnesses
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours
- **Dependencies**: None
- **Research Inputs**: specs/716_sliced_certificate_liveat_nontermination/reports/01_liveat-nontermination-profile.md
- **Artifacts**: plans/01_liveat-memoization-tier2-witness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The diagnosis is settled by research and is not re-litigated here: `liveT` / `liveAt` neither
diverge nor cost anything intrinsic to the total-edge case — the cause is missing memoization,
and the reproducer's apparent unreachability was in large part an `#eval` measurement artifact.
This plan therefore does two separable things. First it lands the Tier-2 sliced witness, which no
longer waits on the performance work: a width-2 total-edge certificate at the `snce`/`⊡` target
`Pp → ⊡Pp`, its `Certifies` proof by kernel `decide`, its C36 inventory row and its C2 axiom pin.
Second it removes the three compounding recomputation faults in the shipped decision procedure —
an iteration with no early exit, a vertex-independent inner fixpoint evaluated per vertex, and an
uncached position-space leaf — each as an additive, equality-preserving refactor behind an `_eq`
lemma, each gated on its own measurement, and the last two behind an explicit contingency branch
because the `#eval` gains the research measured need not transfer to the kernel. Definition of
done: `certA` is a pinned, C36-interesting Tier-2 inventory row; no `sorry`, no new axiom, and no
landed statement anywhere in the development is weakened; `lake build` and
`scripts/check-module-invariants.sh` are green; and every performance claim in the summary is a
figure measured in this implementation round, with the `certB` second row either landed or closed
as a reasoned exclusion citing its own measurement.

### Research Integration

The research report is complete on the diagnosis and this plan re-derives none of it. What is
carried, and under what status:

- **The classification** (missing memoization; not an algorithmic defect, not intrinsic cost) is
  adopted as settled. The three faults named in Findings — `Nu.gfp` / `EUFix.lfp` running a fixed
  `V.card + 1` iterations with no early exit; `untlLive X g e` / `snceLive X g e` evaluated inside
  a filter over every `v ∈ X` although their value depends only on `(X, g, e)`; and
  `posAt` / `verts` recomputed at the innermost level of a four-deep nest — are Phases 3-4, 5 and
  6-7 respectively, in that order.
- **Recommendations 1, 2, 4, 5, 6, 7 and 8** are each executed by a named phase below.
  Recommendation 3 (settle `certB`) is Phase 8. The report's "add **no field** to
  `PlusSlicedCertificate`" constraint is adopted verbatim: nothing below changes the structure's
  field set or any certificate author's obligations.
- **One plan-time correction, mechanically established.** Recommendation 1 as written is not
  executable: the C36 interest expression `c36Sliced` requires a formula of the claimed clause
  kind to occur in `G.slab t w`, and `certA` as preserved in the reproducer labels only
  `atom p` on its slices, so a compiled `#eval` against the built library returns
  `snce=false stab=false imp=false` for it. A bare "add the row" step would have failed C36b. The
  minimal repair, also established at plan time, is to carry `snceP p` on the labelled slice;
  with that one change `c36Sliced [c36Snce] certA = true` **and** `certA.Certifies` still proves
  by `decide` in **87 s** total wall clock under an explicit finite `maxHeartbeats 2000000`. Both
  figures are this-round measurements, and the finite cap simultaneously discharges the report's
  "prefer an explicit large finite cap over `0`" mitigation.
- **Carried-figure status.** The 87 s `Certifies` figure and the `c36Sliced` verdict above are
  re-derived at plan time, as just stated. Every other figure the report supplies — the 20.7 s
  embedded-witness `liveAt (-1)`, the 7.17 s hoisted-mirror `bwdLiveT`, the 16.7x early-exit
  factor, the 370x-6400x leaf-cache range, the `verts` / `predT` / `EUFix.step` stage times, and
  the `decide` table's per-goal wall clocks — is **CARRIED-UNVERIFIED** from
  `reports/01_liveat-nontermination-profile.md` and is re-derived by Phase 1 before any phase
  acts on it. No phase below is permitted to assert a carried figure as its own result.
- **The report's measurement hazard is adopted as a harness constraint.** A pure `let` bound
  between two `IO.monoMsNow` reads is floated past the second read, so every stage reports 0 ms
  while the run never finishes; probes 01-09 carry that broken harness and their figures are not
  citable. Phase 1's harness forces the value through an `IO` write before the second clock read,
  as probes 10-15 do.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so no roadmap-review / roadmap-update phase pair
is generated and `specs/ROADMAP.md` is neither read as a dependency nor written by any phase here.

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
- `posTable`, `posAtC`, `posAtC_eq`

Non-Lean outputs:

- One witness row for the total-edge certificate in `scripts/certificate-witness-inventory.txt`
  whose interest expression evaluates true at a non-empty closure under C36b, with its matched
  `#print axioms` / baseline pair in `scripts/check-module-invariants.sh` (C2)
- A heartbeat-capped cost regression guard on the pinned self-loop embedded witness's liveness
  computation, so a return of the blowup fails the build rather than slowing it
- Every performance figure in the implementation summary measured in this round, with the
  before-and-after pair stated for each of the three fixes that lands

**Non-Goals**:

- No change to the soundness or completeness theorems above the liveness fixpoints, and no
  change to any landed *statement* anywhere: every refactor below is additive or
  body-only-with-preserved-characterization, behind an unconditional equality lemma.
- **No new field on `PlusSlicedCertificate`.** A field would change every certificate author's
  obligations and reopen the demanded-field question `not_exists_plusCertifies_pumpTarget`
  settled.
- No `sorry`, no new axiom, no vacuous placeholder (`:= True`, `:= trivial`), and no
  `maxHeartbeats 0` in landed source — only explicit finite caps.
- No re-derivation of the diagnosis. The report's classification is not re-opened; a phase that
  measures a *worse* figure than the report reports the discrepancy and proceeds on its own
  measurement, it does not re-run the diagnosis.
- No change to the width-2 total-edge *construction* beyond the slab repair C36 requires.
  Nothing measured implicates the constructions themselves.
- No claim of a complexity bound, and no claim that the fixed procedure is fast in general.
  Every figure below is at two named certificates.
- No edit to the refuted sliced finite-model-property work, the TailStable junk-position
  evaluation, or the finite-carrier refutations.

## Decisions

- **D1**: `certA` lands in
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean`, which the default
  build elaborates (it is imported by `PlusSlicedCertificate.lean` and so by `FormalSystem.lean`).
  The ~90 s `decide` is accepted as a default-build cost rather than moved out of the build graph,
  because C2's axiom pin and C36b's interest expression are both compiled against
  `import FormalSystem` and a declaration outside that graph is invisible to both. This is the
  report's recommendation 2 decided, not deferred; the performance work is what reduces the cost
  afterwards.
- **D2**: The witness reuses `PlusSharingWitnessFamily.targetA` (`Pp → ⊡Pp`) rather than a fresh
  target, which ties the new row to the already-pinned genuine ℤ-time non-validity
  `not_plusValidZTime_stabSnce` and gives the sliced class a row at a `snce`-kind closure beside
  its existing `untl`-kind one. This requires adding
  `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples` to
  `PlusSlicedCertificate/Examples.lean`; that direction is cycle-free (nothing under
  `PlusWitnessFamily/` imports `PlusSlicedCertificate`, confirmed at plan time by grep — only
  prose mentions it), and Phase 2 re-confirms it with the build rather than trusting this note.
- **D3**: The three performance fixes land in increasing order of blast radius — early exit
  (Fixpoint.lean, additive), inner-fixpoint hoist (LiveFix.lean, body-only), leaf cache
  (Timed.lean, body-only) — so that a phase abandoned on a negative measurement leaves the
  earlier, cheaper wins in place. The reverse order would make a late revert expensive.
- **D4**: The leaf cache is a **measured decision gate** (Phase 6) before it is a landing
  (Phase 7), because the report's own risk register records that the hoisting figures are `#eval`
  measurements and the gated proofs run `decide`, where whnf caching already recovers part of the
  same win. A `G`-parameterized cache additionally has no interpreter-level sharing — `G.posTable`
  is a function application the interpreter re-runs per call — so the `#eval` win is specifically
  the one at risk of not transferring. The gate measures before the switch lands.
- **D5**: The early-exit iteration is expressed as a **top-down loop** (`iterTo F X n` recursing
  on `F X` when it differs from `X`, stopping when it does not), not as a bottom-up `iter` with a
  stability test at each level. The bottom-up form applies `F` once per level regardless and
  therefore saves nothing; this is a correctness condition on the fix, not a style preference.
- **D6**: `DecidableEq α` is taken as an instance argument on the new `Nu` definitions only.
  `Nu.iter` / `Nu.gfp` are left untouched, so that module header's claim that no `DecidableEq` is
  needed at that level stays true of the existing development. `EUFix` already carries the
  instance at namespace level and needs nothing new.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A body-only change to `verts` / `succT` / `predT` / `fwdLiveStep` breaks a downstream proof that unfolded the old body (`rfl`, `decide`, `simp [verts]`) across Bridge, Stable, Sound, Complete, EmbedComplete, Tail, Check | H | M | Each phase preserves the module's own `mem_*` characterization theorem as the interface and repairs it from the new body first; the scoped build of the changed module plus `Bridge.lean` runs before the phase closes; a break is fixed forward in the named file, never by weakening a statement |
| The `#eval` gains do not transfer to `decide`, so a landed refactor costs blast radius for nothing | M | M | D4: Phase 6 measures a hand-wired mirror under BOTH `#eval` and `decide` before Phase 7 touches the library, and Phase 7 is explicitly conditional with a reasoned-exclusion close |
| A cache disagreeing with its definition would be unsound | H | L | `posAtC_eq` is unconditional (every table entry is literally `(s, G.posAt s)`, with `posAt` itself as the off-range fallback), so no use site can observe a difference and nothing is accepted on the cache's authority |
| The slab repair C36 needs turns out to break a `Certifies` conjunct other than the ones measured | H | L | Already refuted at plan time: the slab-carrying variant's `Certifies` proves by `decide` in 87 s. Phase 1 re-confirms before Phase 2 edits the library |
| `certB`'s larger closure keeps its `decide` out of reach even after all three fixes | M | M | Phase 8 runs it under a bounded waiter (`context/patterns/bounded-build-waiter.md`), and on non-return closes the second row as a reasoned exclusion citing its own measurement rather than leaving the phase open |
| A raised heartbeat cap hides a future regression as build time | M | M | No `maxHeartbeats 0` in landed source (Non-Goals); the cap is explicit and finite, and Phase 8 adds a separate heartbeat-capped guard on the embedded witness so a cost regression fails rather than crawls |
| C2's baseline is a strict string equality over ordered output, so a mis-placed `#print axioms` line fails the gate for a purely positional reason | L | M | Phase 2 inserts the new `#print axioms` line and its baseline line at matched positions and runs the gate before committing; the gate's own diff names the divergence |
| A concurrent sibling dispatch (task 778, `RaySummary/LadderModel.lean`) collides on the shared tree | M | L | No file in this plan's `Files to modify` appears in 778's declared `file_scope`; every phase re-reads a file immediately before editing it, stages only its own named files, and never runs `git-snapshot.sh` in its reverting default mode |

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

### Phase 3: Early-exit iteration, additive in Fixpoint.lean [NOT STARTED]

**Goal**: `Fixpoint.lean` carries an early-exit form of both iterations — one that stops applying
the operator once it is fixed — proved unconditionally equal to the existing fixed-count form, with
`iter` / `gfp` / `lfp` themselves untouched.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean`
      immediately before editing.
- [ ] In `namespace Nu`, add in the signatures fixed below: `iter_succ_comm` (the shift lemma
      `iter V F (n + 1) = iter (F V) F n`), `iterTo` (the top-down loop of D5, with
      `[DecidableEq α]` as an instance argument on the new definition only), `iterTo_eq_iter`,
      `gfp'`, `gfp'_eq_gfp`. A section docstring states why the loop is top-down and not a
      bottom-up stability test (D5), and that `iter` / `gfp` deliberately keep no `DecidableEq`
      requirement (D6).
- [ ] In `namespace EUFix`, add: `iterFrom` (the start-parameterized iteration), `iterFrom_empty`
      (it agrees with `iter` at the empty start), `iterFrom_succ` (the shift lemma), `iterTo`,
      `iterTo_eq_iterFrom`, `lfp'`, `lfp'_eq_lfp`. `EUFix` already carries `[DecidableEq α]` at
      namespace level, so no instance argument is added.
- [ ] `exists_stab` / `iter_stab` are **cited, not re-proved**: the report records that they
      already supply the termination argument an early-exit form needs, so the equality proofs are
      congruence inductions and introduce no new termination obligation. Confirm no new
      `termination_by` or `decreasing_by` clause is needed.
- [ ] Measure the early-exit saving in
      `specs/716_sliced_certificate_liveat_nontermination/probes/17_early_exit.lean`: at the
      embedded witness, hand-wire `Nu.gfp' G.verts G.bwdLiveStep` and `Nu.gfp G.verts
      G.bwdLiveStep` side by side under the Phase 1 harness and record both wall clocks. No landed
      definition is switched yet, so this is a measurement of the new code, not of the library.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
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

### Phase 4: Switch the four liveness fixpoints onto the early-exit forms [NOT STARTED]

**Goal**: `untlLive`, `snceLive`, `fwdLiveT` and `bwdLiveT` compute through the early-exit forms,
with every landed theorem about them unchanged in statement and repaired through a bridging `_eq`
lemma rather than re-proved.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean`
      immediately before editing.
- [ ] Switch the four bodies: `untlLive` / `snceLive` to `EUFix.lfp'`, `fwdLiveT` / `bwdLiveT` to
      `Nu.gfp'`.
- [ ] Add the four bridging lemmas in the signatures fixed below — `untlLive_eq_lfp`,
      `snceLive_eq_lfp`, `fwdLiveT_eq_gfp`, `bwdLiveT_eq_gfp` — each stating equality with the
      unprimed form and each proved by `Nu.gfp'_eq_gfp` / `EUFix.lfp'_eq_lfp`.
- [ ] Repair the immediate consequences in the same module by rewriting through those four
      lemmas, never by weakening a statement: `untlLive_mono`, `snceLive_mono`, `fwdLiveT_subset`,
      `bwdLiveT_subset`, `liveT_subset`, `fwdLiveT_fixed`, `bwdLiveT_fixed`, `fwdLiveT_greatest`,
      `bwdLiveT_greatest`, and anything below them in the file that the build names.
- [ ] Build the changed module plus its one direct dependent, `Bridge.lean`, then the whole
      `PlusSlicedCertificate` aggregate, detached through the guard. A failure in
      `Stable.lean` / `Sound.lean` / `Complete.lean` / `EmbedComplete.lean` / `Tail.lean` /
      `Check.lean` is fixed forward in the file the build names.
- [ ] Re-measure under the Phase 1 harness: `(liveAt (-1)).card` at the embedded witness, and the
      `decide` wall clock of `TotalEdge.certA_certifies`. Record both against Phase 1's and Phase
      2's figures in `progress-file.md`.
- [ ] Record via `issue-record.sh` whether any downstream proof broke, and in which file.

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

### Phase 5: Hoist the vertex-independent inner fixpoint out of the per-vertex filter [NOT STARTED]

**Goal**: `untlLive X g e` / `snceLive X g e` are computed once per contracted set and per
eventuality-shaped closure member rather than once per vertex, with `mem_fwdLiveStep` /
`mem_bwdLiveStep` preserved exactly, so nothing below the module can observe the change.

**Tasks**:
- [ ] Re-read `LiveFix.lean` immediately before editing.
- [ ] Add, in the signatures fixed below: `untlLiveOf` / `snceLiveOf` (the inner fixpoint as a
      total function of the formula, `∅` off shape), `untlTable` / `snceTable` (the closure paired
      with that function's value, as a `Finset.image` — **not** via `Finset.toList`, which is
      noncomputable and would make the whole `decide`-facing stack noncomputable),
      `untlLiveAtTab` / `snceLiveAtTab` (the per-formula clause read against the table, with the
      existential bounded by the table so the clause stays decidable by a bounded quantifier), and
      `untlLiveAtTab_eq` / `snceLiveAtTab_eq` (pointwise equality with `untlLiveAt` /
      `snceLiveAt`, proved from `Finset.mem_image`).
- [ ] Re-express the `fwdLiveStep` / `bwdLiveStep` bodies as a filter against the precomputed
      table, with the table bound once outside the filter lambda. The equality with the old body
      is a `Finset.filter_congr` on a pointwise-equal predicate, discharged by the two `_eq`
      lemmas.
- [ ] Re-prove `mem_fwdLiveStep` / `mem_bwdLiveStep` from the new bodies, with their statements
      byte-identical to the current ones. These two theorems are the module's interface; if either
      cannot be restated unchanged, mark the phase `[BLOCKED]` and raise it rather than adjusting
      the statement.
- [ ] Confirm the short-circuit the report measured is preserved: the clause's `decide (… ∈
      v.1.2.1 → v ∈ …)` form must still avoid evaluating the inner fixpoint at a vertex whose
      label carries no eventuality. State in the docstring whether the table form evaluates the
      fixpoint eagerly for every table member (it does) and why that is still a net win (the
      count drops from per-vertex to per-closure-member).
- [ ] Guarded build of `LiveFix.lean`, `Bridge.lean` and the `PlusSlicedCertificate` aggregate;
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

### Phase 6: DECISION GATE -- measure a hand-wired leaf cache before landing it [NOT STARTED]

**Goal**: Decide, on a measurement rather than on the report's `#eval` figures, whether the leaf
cache is worth its blast radius — and under which evaluator it pays.

**Tasks**:
- [ ] Write `specs/716_sliced_certificate_liveat_nontermination/probes/18_cache_gate.lean`: a
      hand-wired mirror of `posTable` / `posAtC` / `vertsC` / `predTC` / `succTC` at the Phase 2
      certificate, in the shape Phase 7 would land (the `G`-parameterized table with the
      `posAt` off-range fallback), **not** the hardcoded-time-list shape probe 11 used.
- [ ] Measure under `#eval`, with the Phase 1 harness: `vertsC`, the sum of `predTC` cardinalities
      over `vertsC`, one `bwdLiveStep` through the mirror, and the full `bwdLiveT`.
- [ ] Measure under `decide`, in a separate scratch file: the `Certifies`-shaped goal through the
      mirror, against the Phase 5 figure for the same goal through the library.
- [ ] **Gate criterion, fixed here**: Phase 7 lands the cache iff the mirror beats the post-Phase-5
      library figure by at least 2x on the `decide` measurement, or by at least 2x on the `#eval`
      `bwdLiveT` measurement with no `decide` regression. Record the verdict, the two numbers it
      rests on, and the arithmetic, in `progress-file.md`.
- [ ] Record explicitly whether the `G`-parameterized form loses the interpreter-level sharing D4
      anticipates (`G.posTable` re-run per `posAtC` call). If it does, state whether a
      `let`-bound entry point recovers it, since that determines Phase 7's shape.
- [ ] Record via `issue-record.sh` the gate's verdict, `kind: win` on a pass and `kind: issue` on
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

### Phase 7: CONDITIONAL -- land the leaf cache in Timed.lean [NOT STARTED]

**Goal**: If and only if Phase 6's gate passed, the position-space leaf is tabulated once over the
window and its one-step neighbours, and `verts` / `succT` / `predT` read the table instead of
recomputing `posAt` at the innermost level of the nest.

**Tasks**:
- [ ] Read Phase 6's verdict in `progress-file.md` first. **If the gate FAILED**, do not edit
      `Timed.lean`: close this phase `[COMPLETED WITH EXCLUSIONS]` with a
      `#### Reasoned Exclusions` record whose Evidence column cites Phase 6's own failing
      measurement verbatim, and proceed to Phase 8. The two earlier fixes stay landed.
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` immediately
      before editing.
- [ ] Add, in the signatures fixed below: `posTable` (the window times extended one step each way,
      paired with `posAt` at each), `posAtC` (the table lookup with `posAt` itself as the
      off-range fallback), and `posAtC_eq` (unconditional: `G.posAtC t = G.posAt t`). The
      unconditional fallback is what makes the lemma side-condition-free, which is the whole point
      — no use site can observe a difference.
- [ ] Re-express the `verts` body to filter against `posAtC`, and the `succT` / `predT` bodies to
      bind `verts` and the `succP` / `predP` value **once outside** the filter lambda rather than
      once per element. Re-prove `mem_verts`, `mem_succT`, `mem_predT` with statements
      byte-identical to their current form, through `posAtC_eq`.
- [ ] Confirm nothing below the module observes the change: `verts_eq`-style bridging is not
      needed because `posAtC_eq` makes the bodies equal, but the build of `Bridge.lean`,
      `Stable.lean` and the aggregate is what establishes it. A break is fixed forward in the file
      the build names; a statement is never weakened to accommodate one.
- [ ] Guarded build of `Timed.lean`, then of `…PlusSlicedCertificate`, then re-measure
      `(liveAt (-1)).card` and the `certA` `decide` clock; record both.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts the edit is confined to `Timed.lean` and that the three
characterization theorems `mem_verts` / `mem_succT` / `mem_predT` are the complete downstream
interface of the three re-expressed definitions. Confirm by `grep -rn 'G.verts\|succT\|predT'
FormalSystem/` and checking every hit outside `Timed.lean` routes through one of those three or
through `_subset` / `fst_mem_*` / `snd_of_mem_*`; any hit that unfolds a body directly widens this
phase's file list and must be recorded before it is edited.

**Tier Justification**: `verts`, `succT` and `predT` are cited across `Bridge.lean`,
`Stable.lean`, `Sound.lean`, `Complete.lean`, `EmbedComplete.lean`, `Tail.lean` and `Check.lean`,
so a single-module build cannot observe a break; the build of `Timed.lean` plus its enumerated
direct dependents, followed by the guarded `PlusSlicedCertificate` aggregate build, is the
covering check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` - `posTable`, `posAtC`,
  `posAtC_eq`, the three re-expressed bodies, and the three re-proved characterizations
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` - the before/after pair

**Verification**:
- Guarded builds of `…PlusSlicedCertificate.Timed` and `…PlusSlicedCertificate` report green
  through the guard's own `result`
- `mem_verts`, `mem_succT`, `mem_predT` statements byte-identical to their pre-phase form
- `#print axioms` on `PlusSlicedCertificate.posAtC_eq`: no `sorryAx`, profile within
  `[propext, Classical.choice, Quot.sound]`
- `progress-file.md` records the measured figures beside their Phase 5 values
- On the FAILED-gate branch: the phase heading carries `[COMPLETED WITH EXCLUSIONS]`, a
  `#### Reasoned Exclusions` record is present, and `git status --short` shows no change to
  `Timed.lean`

---

### Phase 8: Settle certB, and pin a heartbeat-capped cost regression guard [NOT STARTED]

**Goal**: The second Tier-2 inventory row is resolved one way or the other on a measurement, and
the blowup cannot return unnoticed.

**Tasks**:
- [ ] Reconstruct `certB` from
      `specs/716_sliced_certificate_liveat_nontermination/probes/15_kernel_certB.lean`, apply the
      same slab repair Phase 2 established (so `c36Sliced` can be satisfied at all), and evaluate
      the interest expression **before** attempting `Certifies` — a row that cannot be interesting
      is not worth a multi-hour `decide`.
- [ ] Run `certB.Certifies` by `decide` under an explicit finite `maxHeartbeats`, detached, with a
      hard timeout and writer liveness via `kill -0` on the captured PID per
      `context/patterns/bounded-build-waiter.md`. One waiter per log; never `ps | grep`.
- [ ] **If it returns**: land `TotalEdge.certB` and `certB_certifies` beside `certA` in
      `Examples.lean`, add its inventory row and its matched C2 pair, and re-run
      `check-module-invariants.sh`.
- [ ] **If it does not return within the bound**: close the second-row sub-step as a
      `#### Reasoned Exclusions` record whose Evidence column carries the bound, the elapsed time
      and the heartbeat cap used. Do not raise the cap and retry indefinitely, and do not state
      certB as unreachable in general — state only what was measured.
- [ ] Add the cost regression guard in `Examples.lean`: a heartbeat-capped `decide` goal on the
      pinned self-loop embedded witness's `liveAt`, with the cap set from Phase 1's and the
      post-fix measurements (tight enough that the pre-fix cost would exceed it, loose enough not
      to be flaky), and a docstring stating exactly that — the cap is the guard, and a regression
      fails the build rather than slowing it.
- [ ] Record the final measured figures for every landed fix in `progress-file.md`.

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

### Phase 9: Full verification, axiom pins, and the record [NOT STARTED]

**Goal**: Everything landed is verified by the complete gate set, every Goals declaration is axiom
pinned, and the summary states the measured before/after figures and what was excluded and why.

**Tasks**:
- [ ] **Regenerate the derived surfaces every `.lean` edit forces**, before running the gates that
      check them: `bash scripts/check-module-invariants.sh --emit-inventory` (rewrites each
      `<!-- BEGIN GENERATED: inventory -->` block on the edited files' ancestor-directory chain —
      `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md`) and
      `bash scripts/typst-sync-check.sh --fix` (regenerates `typst/generated/status.typ`, whose
      counts cover `FormalSystem/` recursively). Neither script stages anything; stage the
      regenerated files explicitly with this phase's commit. Omitting this step blocks on the
      pre-commit `typst-sync-check.sh` gate or fails `check-module-invariants.sh`'s INV check.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project),
      detached; read the verdict through the guard's own `result`, never from a pipe exit code
- [ ] `bash scripts/check-module-invariants.sh` (full mode, including C1/C2/C36b and INV)
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` and
      `bash scripts/typst-sync-check.sh`: both report the derived surfaces current
- [ ] `lake exe lint-style` — no new finding on any file this task touched
- [ ] `bash .claude/scripts/verify-deploy.sh` — the complete aggregator gate set
- [ ] `bash .claude/scripts/check-task-references.sh` over every non-`specs/**` file touched (no
      task-number citation may appear in `FormalSystem/**` or `scripts/**`)
- [ ] `#print axioms` in a scratch file on every declaration named under `- **Goals**:` that
      landed: no `sorryAx`, every profile within `[propext, Classical.choice, Quot.sound]`
- [ ] `grep -n 'sorry\|sorryAx\|:= True\|:= trivial\|maxHeartbeats 0'` over every Lean file this
      task touched: nothing outside docstring prose
- [ ] Write the summary artifact per `summary-format.md`, stating plainly: what landed (the
      witness row, the three fixes that passed their gates, the regression guard), what did not
      and why (each gate that failed, with its own measurement), the measured before/after figure
      for each landed fix, and the plan-time correction to the research report's recommendation 1
      that the C36 slab finding forced

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: full

**Files to modify**:
- `specs/716_sliced_certificate_liveat_nontermination/summaries/01_liveat-memoization-tier2-witness-summary.md` -
  new; the implementation summary
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
- `git status --short` shows only files enumerated in Phases 1-8 plus this phase's summary

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

/-! ### Phase 7 (conditional): the position-space leaf cache -/

/-- `posAt` tabulated over the window times extended one step each way. -/
def posTable (G : PlusSlicedCertificate Γ Del) : List (ℤ × Finset G.Pos) :=
  (List.range (G.winHi - G.winLo + 2).toNat).map fun i =>
    (G.winLo - 1 + (i : ℤ), G.posAt (G.winLo - 1 + (i : ℤ)))

/-- The cached position space, with `posAt` itself as the off-range fallback — which is what makes
`posAtC_eq` unconditional and so unobservable at every use site. -/
def posAtC (G : PlusSlicedCertificate Γ Del) (t : ℤ) : Finset G.Pos :=
  match G.posTable.find? (fun p => decide (p.1 = t)) with
  | some p => p.2
  | none => G.posAt t

theorem posAtC_eq (G : PlusSlicedCertificate Γ Del) (t : ℤ) : G.posAtC t = G.posAt t := sorry

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
- [ ] The cost regression guard's heartbeat cap is finite and the embedded witness's `liveAt` goal
      elaborates within it
- [ ] Every performance figure in the summary is a this-round measurement recorded in
      `progress-file.md`, and no figure is marked carried

## Artifacts & Outputs

- `specs/716_sliced_certificate_liveat_nontermination/plans/01_liveat-memoization-tier2-witness.md` (this file)
- `specs/716_sliced_certificate_liveat_nontermination/progress-file.md` — the measured-figure table
- `specs/716_sliced_certificate_liveat_nontermination/probes/16_baseline.lean`,
  `17_early_exit.lean`, `18_cache_gate.lean`, `19_certb.lean`
- `specs/716_sliced_certificate_liveat_nontermination/summaries/01_liveat-memoization-tier2-witness-summary.md`
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` — the Tier-2 witness
  and the regression guard
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` — the early-exit forms
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` — the switched fixpoints
  and the hoisted inner fixpoint
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` — the leaf cache
  (conditional on Phase 6's gate)
- `scripts/certificate-witness-inventory.txt` — the new `witness` row(s)
- `scripts/check-module-invariants.sh` — the new matched C2 pair(s)

## Rollback/Contingency

Each phase is one commit, so the ordinary rollback is `git revert` of the phase commit — the
phases are ordered by increasing blast radius (D3) precisely so that reverting a late one leaves
the earlier wins in place. The three performance phases are independently revertible: Phase 7
touches only `Timed.lean`, Phase 5 and Phase 4 only `LiveFix.lean`, and Phase 3 is additive, so
reverting any of them restores the previous measured behaviour without touching the Tier-2 witness
of Phase 2.

Two contingencies are declared in the plan rather than improvised: Phase 6's gate decides whether
Phase 7 lands at all (a failed gate closes Phase 7 `[COMPLETED WITH EXCLUSIONS]` with the gate's
own measurement as Evidence), and Phase 8's bounded `certB` run decides whether the second
inventory row lands or closes the same way.

If uncommitted work must be discarded to reach a passing build, do not: fix forward in the file
the build names, per `context/contracts/recovery.md`'s ladder. Only a genuine rollback decision
takes the snapshot-then-rollback rung, and then the invocation shape — including its
out-of-scope override flag — is the one `context/contracts/recovery.md` specifies, never a bare
precautionary `git-snapshot.sh` as a start-of-phase checkpoint. For an ordinary defensive
checkpoint before the Phase 7 body edits, use `bash .claude/scripts/git-snapshot.sh 716
--no-revert`, which is durable without reverting the working tree.
