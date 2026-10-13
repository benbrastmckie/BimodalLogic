# Progress: measured figures

Every figure below is measured in THIS implementation round. No row is carried from
`reports/01_liveat-nontermination-profile.md`; where a measurement disagrees with the report,
the disagreement is recorded in the Note column and the report's figure is superseded, not
reconciled.

Harness: `probes/16_baseline.lean`'s `timeIt`, which forces the measured value through an `IO`
write BEFORE the second `IO.monoMsNow` read. Probes 01-09 of this task bind the value to a pure
`let` between the two reads, Lean floats it past the second one, and their figures are therefore
NOT citable.

## Phase 1 -- the pre-change baseline

### A. the pinned self-loop embedded witness, `WitnessFamily.Embedded.liveFamily.sliced (-1)`

| Figure | Value | How measured | vs. the report |
|---|---|---|---|
| closure card | 3 | probe 16 `#eval` | not carried; new |
| `Fintype.card Pos` | 8 | probe 16 `#eval` | not carried; new |
| `winTimes.card` | 6 | probe 16 `#eval` | agrees (six window times) |
| `verts.card` | 12 | probe 16 `#eval` | not carried; new |
| `verts` wall clock | 9 ms | probe 16 `#eval` | CONFIRMS the report's 9 ms |
| `fwdLiveT.card` | 6 | probe 16 `#eval` | not carried; new |
| `fwdLiveT` wall clock | 8521 ms | probe 16 `#eval` | report says 7636 ms -- same order, 1.12x slower here; this round's 8521 ms is what later phases are read against |
| `bwdLiveT.card` | 12 | probe 16 `#eval` | not carried; new |
| `bwdLiveT` wall clock | 1704 ms | probe 16 `#eval` | CONFIRMS the report's 1614 ms (1.06x) |
| `(liveAt (-1)).card` | 1 | probe 16 `#eval` | not carried; new |
| `liveAt (-1)` wall clock | 20225 ms | probe 16 `#eval` | CONFIRMS the report's 20.7 s |

### B. the slab-carrying width-2 total-edge certificate (`certA`)

| Figure | Value | How measured | vs. the report |
|---|---|---|---|
| closure card | 6 | probe 16 `#eval` | not carried; new |
| `Fintype.card Pos` | 128 | probe 16 `#eval` | not carried; new |
| `winTimes.card` | 4 | probe 16 `#eval` | agrees (four window times) |
| `(posAt 0).card` | 4 | probe 16 `#eval` | agrees (four positions) |
| `verts.card` | 16 | probe 16 `#eval` | not carried; new |
| `verts` wall clock | 1114 ms | probe 16 `#eval` | CONFIRMS the report's 1101 ms |
| sum of `predT` cards over `verts` | 32 | probe 16 `#eval` | not carried; new |
| 16 `predT` wall clock | 18936 ms | probe 16 `#eval` | CONFIRMS the report's 19119 ms |

### C. the two plan-time verdicts, re-confirmed before any library file was touched

| Verdict | Result | How measured |
|---|---|---|
| `c36Sliced [c36Snce] certA` | **true** (1 ms) | probe 16 `#eval`, with the C36 vocabulary copied verbatim from `scripts/check-module-invariants.sh` |
| `certA.Certifies` by kernel `decide` | **proves**, 43.4 s total file wall clock, under `set_option maxHeartbeats 2000000` | `lake env lean` on a scratch copy; `#print axioms` reports `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |

The 43.4 s figure SUPERSEDES the plan's 87 s plan-time measurement (same construction, same
finite cap; the plan-time run paid elaboration the scratch run reuses from the built library).
43.4 s is the "before" `decide` figure the performance phases are read against.

**Harness-criterion note.** Phase 1's verification text reads "every stage prints a non-zero
millisecond figure (a `0 ms` stage is the broken-harness symptom)". Five stages here print
`0 ms` -- `closure.card`, `Fintype.card Pos`, `winTimes.card` at both certificates. Those are
genuinely sub-millisecond computations that COMPLETED and printed their correct values, which is
the opposite of the broken-harness symptom (that symptom is every stage reading 0 ms while the
run never finishes). The criterion is met in substance: the run completed, and every
non-trivial stage reports a non-zero figure.

## Phase 2 -- the landed total-edge witness

| Figure | Value | How measured |
|---|---|---|
| `TotalEdge.certA_certifies` elaboration, in the default build | **36 s** | the guarded scoped build's own per-module timing line for `PlusSlicedCertificate.Examples` |
| `certA.Certifies` `decide`, standalone scratch file | 43.4 s (Phase 1) | `lake env lean`, `time` |
| heartbeat cap landed | `maxHeartbeats 2000000` (finite, explicit) | source |
| `maxRecDepth` landed | `4000000` | source |

The 36 s module figure is the **"before" `decide` cost** the three performance phases are read
against. It is smaller than the 43.4 s standalone figure because the module build pays no
separate `import FormalSystem` elaboration.

Gates at Phase 2 close: **C2 PASS** (all fifty pinned axiom sets match baseline, the new
`TotalEdge.certA_certifies` pair included), **C36a PASS** (6 closed-term witness rows, all
pinned), **C36b PASS** with the new row reading `C36 certA_certifies card=6 interesting=true`.

`check-module-invariants.sh` reports one unrelated failing group at this point: `INV` -- two
generated-inventory blocks (`FormalSystem/Metalogic/README.md`, `README.md`) are stale because a
`.lean` file under `FormalSystem/` changed. Phase 9 owns regenerating those surfaces
(`--emit-inventory`); it is a derived-surface staleness, not a defect in anything this phase
landed.

## Phase 3 -- the early-exit iteration, measured against the fixed-count form

Probe `probes/17_early_exit.lean`, at the pinned self-loop embedded witness. The new code is
measured against the old code side by side; no landed definition is switched at this point.

| Fixpoint | OLD (`Nu.gfp`) | NEW (`Nu.gfp'`) | factor | cardinality |
|---|---|---|---|---|
| `bwdLiveStep` over `verts` | 1563 ms | **122 ms** | **12.8x** | 12 both |
| `fwdLiveStep` over `verts` | 7606 ms | **2177 ms** | **3.5x** | 6 both |

Both pairs agree on the cardinality, which is `gfp'_eq_gfp` confirmed behaviourally beside
being proved.

**Discrepancy with the report, recorded not reconciled.** The report's carried figure is a
16.7x early-exit factor. Measured here: 12.8x on the backward fixpoint and 3.5x on the forward
one. The report's single figure is therefore optimistic for the forward direction, which is the
expensive one (7606 ms of the baseline's 8521 ms `fwdLiveT`). This round's figures are what
later phases cite.

Scope Hypothesis CONFIRMED: `git diff --numstat` reports `139 0` on `Fixpoint.lean` -- 139
insertions, **zero deletions** -- and exactly 12 new `def`/`theorem` declarations
(`Nu.{iter_succ_comm, iterTo, iterTo_eq_iter, gfp', gfp'_eq_gfp}`,
`EUFix.{iterFrom, iterFrom_empty, iterFrom_succ, iterTo, iterTo_eq_iterFrom, lfp', lfp'_eq_lfp}`).

Axiom profiles: `Nu.gfp'_eq_gfp`, `EUFix.lfp'_eq_lfp`, `Nu.iterTo_eq_iter`,
`EUFix.iterTo_eq_iterFrom`, `EUFix.iterFrom_empty`, `EUFix.iterFrom_succ` all
`[propext, Classical.choice, Quot.sound]`; `Nu.iter_succ_comm` is `[propext, Quot.sound]`.
No `sorryAx` anywhere. `lake exe lint-style` on the file: no finding. Full guarded
`lake build`: green, 2844 jobs.

No new `termination_by` or `decreasing_by` clause was needed: `iterTo` recurses structurally on
its `ℕ` argument, so the existing `exists_stab` / `iter_stab` termination argument is cited and
not re-proved, exactly as the plan anticipated.

## Phase 4 -- the four liveness fixpoints switched onto the early-exit forms

`untlLive` / `snceLive` now compute through `EUFix.lfp'`, `fwdLiveT` / `bwdLiveT` through
`Nu.gfp'`, each bridged by an unconditional `_eq` lemma.

### At the pinned self-loop embedded witness (`#eval`, probe-16 harness)

| Figure | Phase 1 (before) | Phase 4 (after) | factor |
|---|---|---|---|
| `verts.card` | 9 ms | 9 ms | 1.0x (unaffected, as expected) |
| `fwdLiveT.card` | 8521 ms | **727 ms** | **11.7x** |
| `bwdLiveT.card` | 1704 ms | **183 ms** | **9.3x** |
| `(liveAt (-1)).card` | 20225 ms | **1648 ms** | **12.3x** |

Every cardinality is unchanged (12, 6, 12, 1), which is the four `_eq` lemmas confirmed
behaviourally beside being proved.

The in-library factor (11.7x on the forward fixpoint) is **larger** than probe 17's
side-by-side figure for the same operator (3.5x), and this is not a contradiction: probe 17
switched only the outer `Nu.gfp`, whereas the landed change also switches the *inner*
`untlLive` / `snceLive` fixpoint that the step evaluates per vertex, so the two savings compound.

### At `certA`

| Figure | Phase 2 (before) | Phase 4 (after) | factor |
|---|---|---|---|
| `certA_certifies` kernel `decide`, as a module build | 36 s | **34 s** | 1.06x |
| `verts.card` (`#eval`) | 1114 ms | 1256 ms | 0.89x (noise) |
| `bwdLiveT.card` (`#eval`) | not measured at Phase 1 | 319248 ms (card 16) | -- |
| `(liveAt 0).card` (`#eval`) | -- | **did not return within 500 s** | -- |

**This pair is the report's `#eval`-measurement diagnosis made unmistakable.** The same
certificate whose `Certifies` -- which *contains* the clause
`targetPos targetTime ∈ liveAt targetTime` -- the kernel decides in 34 s cannot have its
`liveAt 0` computed by `#eval` in 500 s, and its `bwdLiveT` alone costs 319 s there. The
interpreter is the wrong measurement surface for this computation; the kernel's own whnf caching
is doing work `#eval` does not. Every `decide`-facing claim below is therefore read off a
`decide` measurement, never off an `#eval` one.

### Blast radius, and what the Scope Hypothesis got right and wrong

CONFIRMED: no statement anywhere changed. The only edits on a signature-bearing line are the
`:=` -> `:= by` proof-delimiter change on eight in-module consequences; every proposition is
byte-identical. `mem_fwdLiveStep` / `mem_bwdLiveStep` are untouched.

WIDENED: the Scope Hypothesis named `Bridge.lean` as the one direct dependent, and that was
right as far as it went, but the build named **two** files needing repair, not one:

- `Bridge.lean` (2 lines): two `unfold untlLive` / `unfold snceLive` sites fed a `hkey` of
  `EUFix.lfp` shape into a goal that had become `EUFix.lfp'`. Repaired to
  `rw [G.untlLive_eq_lfp]` / `rw [G.snceLive_eq_lfp]` -- forward, through the bridging lemma.
- `FixtureStable.lean` (1 line): `rw [untlLive]` inside `not_mem_R₀fwd_pR` unfolded to `lfp'`
  and then made `EUFix.lfp_induction` unify through `lfp'`, which hit the 200000-heartbeat whnf
  timeout. Repaired to `rw [untlLive_eq_lfp]`. `FixtureStable.lean` is NOT a direct dependent of
  `LiveFix.lean`, which is why the plan-time `grep -rln 'PlusSlicedCertificate.LiveFix'` did not
  find it: it reaches these definitions transitively through the aggregate.

A repo-wide `grep` for every definitional-unfold site of the four switched definitions
(`rw [untlLive]`, `unfold snceLive`, `simp only [fwdLiveT]`, and the other ten spellings) found
exactly these three, so the repair set is complete rather than merely sufficient for one build.

Axiom profiles: `fwdLiveT_eq_gfp`, `bwdLiveT_eq_gfp`, `untlLive_eq_lfp`, `snceLive_eq_lfp` and
`TotalEdge.certA_certifies` all `[propext, Classical.choice, Quot.sound]`, unchanged from
Phase 2. Guarded build of `…PlusSlicedCertificate`: green, 1523 jobs.

## Phase 5 -- the inner fixpoint hoisted out of the per-vertex filter

`fwdLiveStep` / `bwdLiveStep` now bind a closure-indexed table once outside the filter lambda
and read the liveness clause against it. `mem_fwdLiveStep` / `mem_bwdLiveStep` are stated in
`untlLiveAt` / `snceLiveAt` exactly as before -- byte-identical propositions, re-proved through
`untlLiveAtTab_eq` / `snceLiveAtTab_eq`.

### The decisive measurement: an A/B at one library state, under the kernel

`untlLiveAt` / `snceLiveAt` are left in the library untouched, so both clause shapes can be
run side by side against the SAME built library, with no rebuild and no machine-variance
confound. Two scratch files, each a `decide` on
`(Nu.gfp' certA.verts (bwdStep? certA)).card = 16`, run serially:

| clause shape | kernel `decide` wall clock |
|---|---|
| OLD, per-vertex (`snceLiveAt X v ψ`) | 25.9 s |
| NEW, table (`snceLiveAtTab tbl v ψ`) | **24.4 s** |

**The hoist is neutral under the kernel** -- 1.06x, which is inside run-to-run variance. The
kernel's own whnf cache was already removing most of the per-vertex duplication the hoist
targets, so there was less there to win than the `#eval` figures suggested. This is the same
hazard D4 anticipated for the leaf cache, observed one phase early.

### Under `#eval`, the hoist is a large win at the hard certificate and a small loss at the easy one

| Figure | Phase 4 | Phase 5 | factor |
|---|---|---|---|
| `certA` `bwdLiveT.card` | 319248 ms | **58656 ms** | **5.4x better** |
| `certA` `verts.card` | 1256 ms | 1241 ms | 1.0x |
| embedded `(liveAt (-1)).card` | 1648 ms | 2188 ms | 0.75x -- **worse** |
| embedded `fwdLiveT.card` | 727 ms | 860 ms | 0.85x -- worse |
| embedded `bwdLiveT.card` | 183 ms | 228 ms | 0.80x -- worse |

The split is coherent and is the counting argument in the module docstring made visible: the
table pays a fixed cost of `|closure|` eager inner-fixpoint evaluations plus one bounded
existential lookup per (vertex x closure member), and recovers `|X|`-fold duplication. At the
embedded witness the inner fixpoint is cheap and the closure has 3 members, so the fixed cost
dominates and the hoist costs ~25%. At `certA` the inner fixpoint is expensive and there are 16
vertices, so the saving dominates and the hoist wins 5.4x. `certA` is the hard case this task
exists for.

### The module-build figure, stated honestly

`PlusSlicedCertificate.Examples` built in 36 s (Phase 2), 34 s (Phase 4) and 41 s (Phase 5).
That figure is **not** attributable to the hoist: the A/B above shows the hoist is neutral at
`certA` under the kernel, and the module conflates two `decide` goals, which measured
separately after this phase are `certA_certifies` 24.6 s and `liveFamily_sliced_certifies`
5.6 s. Module-build wall clocks on a shared machine carry variance of this size. The A/B is the
figure to cite; the module figure is recorded because it was observed, not because it isolates
anything.

Scope Hypothesis CONFIRMED on both halves: `untlLiveAt` / `snceLiveAt`'s own `match` arms give
a non-`true` result at `.untl` and `.snce` only, so the two tables cover the whole clause set;
and `grep -rn 'fwdLiveStep\|bwdLiveStep' FormalSystem/ Tests/` finds exactly one hit outside
`LiveFix.lean` (`FixtureStable.lean:184`, 187), which routes through `mem_fwdLiveStep`.

Axiom profiles: `untlLiveAtTab_eq`, `snceLiveAtTab_eq`, `mem_fwdLiveStep`, `mem_bwdLiveStep` all
`[propext, Classical.choice, Quot.sound]`, no `sorryAx`. `lake exe lint-style` on `LiveFix.lean`:
no finding. Guarded builds of `…PlusSlicedCertificate.LiveFix` (1221 jobs) and
`…PlusSlicedCertificate` (1523 jobs): both green.

## Phase 6 -- the leaf-cache DECISION GATE

Probe `probes/18_cache_gate.lean` carries a hand-wired mirror of the Phase-7 shape at `certA`,
in **two** variants rather than one, because D4 anticipated that the `G`-parameterized form
loses interpreter-level sharing:

- **Shape A** -- `vertsCP`, which calls `posAtCP t` once per `(position, time)` pair. `posAtCP`
  reads `G.posTable`, which is a function application, so the interpreter rebuilds the whole
  table on every call.
- **Shape B** -- `vertsLP`, which binds the table ONCE in a `let` outside the filter lambda, and
  `predTCP`, which likewise binds `verts`, the `predP` value and `prevTime v.2` once outside its
  own filter.

### The `#eval` arm

| Figure | LANDED (post-Phase-5) | SHAPE A | SHAPE B | B vs landed |
|---|---|---|---|---|
| `verts.card` | 1105 ms | 6834 ms | **15 ms** | **74x better** |
| sum of `predT` cards over `verts` | 18446 ms | -- | **288 ms** | **64x better** |
| one `bwdLiveStep` at `verts` | 57591 ms | -- | **972 ms** | **59x better** |
| `bwdLiveT.card` | 57183 ms | -- | **906 ms** | **63x better** |

Every cardinality agrees (16, 32, 16, 16).

**D4's hazard is confirmed exactly, and quantified.** Shape A is **6.2x WORSE than no cache at
all** (6834 ms against 1105 ms), because the interpreter re-runs `G.posTable` per `posAtCP` call
and so rebuilds a 6-entry table of 128-element `Finset`s 512 times. The `let`-bound entry point
recovers the sharing and more: 15 ms against 1105 ms. **Phase 7 must land Shape B.** A naive
"filter against `posAtC`" would have shipped a 6x regression, and this gate is what caught it.

### The `decide` arm

Two scratch files, each a kernel `decide` on `… .bwdLiveT.card = 16` / `… .bwdLiveTCP.card = 16`,
run serially against the same built library:

| path | kernel `decide` wall clock |
|---|---|
| LANDED library `bwdLiveT` | 23.7 s |
| MIRROR (Shape B) `bwdLiveTCP` | **4.3 s** |

**5.5x better under the kernel.** Unlike Phase 5's hoist, this win does transfer: the kernel's
whnf cache shares `G.posAt t` across repeated identical `t`, but it does not collapse the 512
`v.1 ∈ G.posAt v.2` membership tests into 6, and that is where the cost was.

### GATE VERDICT: **PASS**

The criterion fixed at plan time is "at least 2x on the `decide` measurement, **or** at least 2x
on the `#eval` `bwdLiveT` measurement with no `decide` regression". Both arms are satisfied, not
one:

- `decide`: 23.7 s / 4.3 s = **5.51x** >= 2x. PASS.
- `#eval` `bwdLiveT`: 57183 ms / 906 ms = **63.1x** >= 2x, and the `decide` arm improves rather
  than regresses. PASS.

Phase 7 therefore lands, in Shape B.

### Scope Hypothesis, confirmed

`Position.lean` imports only `…PlusSlicedCertificate.Frame` and
`…PlusWitnessFamily.Compression.Types`; `winTimes` is defined in `Window.lean`, which
`Position.lean` does not import. So `succP` / `predP` cannot see the window and the cache's reach
is the three definitions in `Timed.lean` (`verts`, `succT`, `predT`), exactly as hypothesized.
The mirror and Phase 7 do not widen to `succP` / `predP`.

### One mechanical correction to the recorded Challenge statement

`posAtC`'s recorded body reads `G.posTable.find? (fun p => decide (p.1 = t))`. That is not
executable as written inside `FormalSystem.Metalogic.Decidability`: `DecisionProcedure.lean`
defines `decide (φ : Formula)` in that namespace, which shadows the core `Decidable.decide`, and
`_root_.decide` is not an identifier either. The probe uses `p.1 == t` (`BEq` on `ℤ`) instead --
the same Boolean test, no statement changed, and cheaper than going through a `Decidable`
instance. Phase 7 lands the same spelling.
