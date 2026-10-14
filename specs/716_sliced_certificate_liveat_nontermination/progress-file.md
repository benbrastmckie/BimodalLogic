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

## Phase 7 -- BLOCKED, and the measurement that settles why

Phase 6's gate passed, so this phase was executed as the plan directs. The cache landed,
`lake build …PlusSlicedCertificate.Timed` went green (1218 jobs), and the **full** build then
broke five `rfl`-proved `withBx_*` transfer lemmas in `Complete.lean` -- a file this phase's
Scope Hypothesis asserted would not be touched.

The decisive measurement is not a timing but a defeq test:

| scratch goal, `(G.wB bx).X = G.X := rfl`, `wB` a one-field structure update | cap | result |
|---|---|---|
| `X = posTable` | 200000 | **holds** |
| `X = verts`, Shape B (table `let`-bound) | 2000000 (10x) | **FAILS**: `rfl has type ?m.9 = ?m.9` |
| `X = verts`, Shape A (plain `posAtC` per pair) | 100000 | times out |
| `X = verts`, Shape D (`winTimes.biUnion` over `posAt`, no table) | 100000 | **holds** |

Shape B's `rfl` does not time out at ten times the cap -- `isDefEq` returns **false**. **No
heartbeat bump can fix this**, which is why the `(deterministic) timeout` the build reports is a
symptom rather than the cause, and why a cap bump in `Complete.lean` is recorded as a prohibited
workaround rather than a candidate fix.

Shape D obtains the same 512-to-4 reduction in `posAt` calls with no table, no `let` and no
equality lemma, and it IS `rfl`-transferable. It is also a decomposition change: it drops
`posTable` / `posAtC` / `posAtC_eq`, three declarations the plan records under `- **Goals**:` and
pins in `## Lean Challenge Statements`. `.claude/rules/plan-compliance.md` requires that to be
raised rather than substituted, so it is raised. The full blocker record, with both candidate
routes and their costs, is on the Phase 7 heading in the plan.

`Timed.lean` is reverted to its Phase-5 committed state; the full guarded `lake build` is green
at 2844 jobs. The attempt is preserved verbatim at
`probes/20_phase7_shapeB_attempt.diff` and in `git stash@{0}`.

## Phase 7 (Shape D) -- probe 24 re-run, this round

The plan's Scope Hypothesis names the 15 ms / 1093 ms pair as CARRIED from
`probes/24_shapeD_measure.lean` — its three `#time #eval` lines, the only durable source for
them. Re-run verbatim against the currently built library before any edit,
`lake env lean probes/24_shapeD_measure.lean`, exit 0:

| measurement | carried | this round |
|---|---|---|
| `#eval (certA.verts).card` (landed filter shape) | 1093 ms | **1358 ms** |
| `#eval (certA.vertsD).card` (Shape D `biUnion`) | 15 ms | **21 ms** |
| card, both shapes | 16 | **16, both** |
| `#eval (certA.verts = certA.vertsD)` | agreement | **`true`**, 2123 ms |
| isolated factor | ~73x | **64.7x** |

The carried pair is discharged: same direction, same card, agreement confirmed, factor 64.7x
rather than ~73x. Per the phase's first task the route decision is **not** re-opened on a
smaller-but-still-better factor; the landing proceeds on this round's 64.7x.

## Phase 7 -- Shape D landed, and the propagated figures the evidence did not have

`verts` is now `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))` -- one `posAt`
call per window time rather than one per (position, time) pair -- and `succT` / `predT` bind
`verts`, the wrapped time and the `succP` / `predP` value once outside their filter lambdas.
`mem_verts` is re-proved from the new body through `Finset.mem_biUnion` / `Finset.mem_image` with
its statement byte-identical; `mem_succT` / `mem_predT` needed no repair, the `let`-hoists being
zeta-equal. No cache, no table, no equality lemma, and no new identifier.

### The `withBx` invariant, checked before the aggregate build

`probes/25_shapeD_landed_transfer.lean`, run by `lake env lean` against the edited module
(exit 0, explicit finite cap of 200000 deliberately NOT raised):

| scratch goal | result |
|---|---|
| `(G.withBx bx).verts = G.verts := rfl` | **holds** |
| `(G.withBx bx).succT v = G.succT v := rfl` | **holds** |
| `(G.withBx bx).predT v = G.predT v := rfl` | **holds** |
| `mem_verts`'s pre-phase statement, by `G.mem_verts v` | **accepted** |

`#print axioms` on `mem_verts`, `mem_succT`, `mem_predT`: all `[propext, Classical.choice,
Quot.sound]`, no `sorryAx`. Scoped guarded build of `…PlusSlicedCertificate.Complete`: **green,
1246 jobs, zero `error:` lines** -- the exact build the earlier table shape broke -- with
`grep -c 'withBx_'` on that file unchanged at **27** and its diff confined to docstring lines.

### The propagated factor, measured rather than assumed

The route evidence measured `verts` in isolation and said nothing about whether the gain reaches
`liveAt`. It does, and under `#eval` it reaches further than the isolated figure. Each row below
is against a figure measured the same way earlier in this round, not against a carried one:

| figure | earlier this round | Shape D | factor |
|---|---|---|---|
| `certA verts.card` (`#eval`) | 1105 ms (Phase 6 landed col.) | **24 ms** | **46x** |
| `certA` sum `predT` cards over `verts` (`#eval`) | 18446 ms (Phase 6) | **237 ms** | **78x** |
| `certA bwdLiveT.card` (`#eval`) | 57183 ms (Phase 6) | **564 ms** | **101x** |
| `certA.bwdLiveT.card = 16` kernel `decide` | 23.7 s (Phase 6 gate) | **3.1 / 4.1 s** | **~6.4x** |
| embedded `(liveAt (-1)).card` (`#eval`) | 2188 ms (Phase 5) | **200 ms** | **10.9x** |
| embedded `fwdLiveT.card` (`#eval`) | 860 ms (Phase 5) | **69 ms** | **12.5x** |
| embedded `bwdLiveT.card` (`#eval`) | 228 ms (Phase 5) | **17 ms** | **13.4x** |
| `certA_certifies` kernel `decide`, scratch wall clock | 24.6 s (Phase 5) | **8.4 s** median of 5 | **~2.9x** |

Every cardinality is unchanged (`verts` 16, `predT` sum 32, `bwdLiveT` 16, embedded 12/6/12/1).

**Stated plainly, as the phase requires.** The propagated factor is **not** the isolated one, and
it differs by surface. Under `#eval` it is *larger* than the isolated 64.7x -- 101x on
`bwdLiveT`, because the saving is paid once per `posAt` call and the fixpoint makes many. Under
the kernel it is **~6.4x**, which is the surface that matters for `decide`: the whnf cache was
already sharing `G.posAt t` across repeated `t`, so what Shape D removes there is the 512-fold
`v.1 ∈ G.posAt v.2` membership test, not the slice rebuild. That ~6.4x is within noise of the
Phase 6 gate's predicted 5.51x and *beats* the Shape B mirror it was measured against (4.3 s
against Shape D's 3.1-4.1 s) -- so the route rejected in D7 bought nothing the cache-free shape
does not.

The `certA_certifies` row is the weakest of the eight and is reported as measured: five scratch
runs gave 5026 / 8670 / 6080 / 8557 / 8439 ms gross, against an import-only control of 2854 /
2046 / 2364 / 1822 ms, so roughly 6.2 s net at the median. Phase 5's 24.6 s is a gross figure
from a differently-loaded machine, which is why the 2.9x on that row is cited as the floor of the
propagated range and the like-for-like `bwdLiveT` `decide` A/B above as its measurement.

## Phase 8 -- certB settled on the returning branch, and the cost guard pinned

### The Scope Hypothesis, measured before the `decide` rather than carried

The phase asserts that `certB` differs from `certA` only in carrying a larger closure, growing
`2^|closure|` "by roughly an order of magnitude" — a figure carried from
`reports/01_liveat-nontermination-profile.md`. Measured at `probes/19_certb.lean`:

| figure | `certA` | `certB` | ratio |
|---|---|---|---|
| closure card | 6 | **8** | 1.33x (`2^|closure|`: 64 → 256, **4x**) |
| `Fintype.card Pos` | 128 | **512** | **4x** |
| `winTimes.card` | 4 | **5** | 1.25x |
| `(posAt 0).card` | 4 | **4** | 1.0x |
| `verts.card` | 16 | **20** | 1.25x |

**The carried "order of magnitude" is CORRECTED to 4x** on both `2^|closure|` and the position
space. `certB` is the larger certificate and the one that exercises the liveness fixpoint
hardest, but not by the margin the report projected.

### The interest expression, evaluated before `Certifies`

`c36Sliced [c36Untl] certB` = **true** (8 ms), after the slab repair Phase 2 established: probe
15's `sliceB` labels `w = 1` with `{atom p}` alone, so no slab carried a formula of the claimed
`untl` kind and the row could not have been interesting however well `Certifies` went. The
landed `labSliceB` is `{atom p, U⊤p}`, with the subset obligation discharged through
`mem_closB`.

### `certB.Certifies` RETURNS -- the returning branch applies

| figure | value |
|---|---|
| `certB.Certifies` by kernel `decide`, bounded run | **12 s**, exit 0 |
| cap used | `maxHeartbeats 2000000`, `maxRecDepth 4000000` (explicit, finite) |
| waiter bound | `timeout 2400` on the writer, liveness by `kill -0` on the captured PID |
| axiom profile | `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |

The plan's risk table rated "certB's larger closure keeps its `decide` out of reach even after
all three fixes" at M/M, with a `#### Reasoned Exclusions` record as the contingency. **That
contingency is not taken**: the second row lands. `TotalEdge.certB` / `certB_certifies` are in
`Examples.lean` beside `certA`, with the inventory row (`untl` kind, `targetB`) and the matched
C2 pair.

Gates after the landing: **C2 PASS**, **C36a PASS** (7 closed-term witness rows), **C36b PASS**
with `C36 certB_certifies card=8 interesting=true`. The sliced class now carries **three**
witness rows — the self-loop embedded one at `untl`, `certA` at `snce` under `⊡`, and `certB` at
`untl` under `⊡` — so both temporal kinds are covered at width above `1`. One check group fails,
`INV`: two generated-inventory blocks are stale because `.lean` files changed. Phase 9 owns
regenerating them.

### The cost regression guard, and what its cap is worth

Landed in `Examples.lean` as a `maxHeartbeats 20000`-capped `decide` on
`((liveFamily.sliced (-1)).liveAt (-1)).card = 1`. The cap was set by bisection against the
built library, not guessed:

| cap | result |
|---|---|
| 1000 / 4000 / 5000 / 6000 | **FAIL** — `(deterministic) timeout at whnf` |
| 7000 / 8000 / 9000 / 10000 / 40000 | PASS |

So the fixpoint costs between 6000 and 7000 heartbeats today, and the landed `20000` is a little
over 3x that: a cost regression past 3x fails the build with a deterministic timeout rather than
slowing it. Heartbeat consumption is deterministic, so the threshold carries no machine-load
flakiness. The guard is an `example`, not a named theorem: it adds no identifier to pin and no
inventory row, and the cap is its entire content.

**One measurement worth recording, because it would mislead the next person to set such a cap.**
`#count_heartbeats in` reports only **11** heartbeats for `certA.bwdLiveT.card = 16` and **23**
for the guard goal — yet a cap of 20 on the first fails outright with
`(deterministic) timeout at whnf, maximum number of heartbeats (20)`, and the guard goal needs
between 6000 and 7000. `#count_heartbeats` does not see the consumption inside `decide`'s nested
whnf. **Set such a cap by bisecting the cap itself, never from `#count_heartbeats`.**

### Final measured figures for every landed fix

| figure | before (this round's own baseline) | after all three fixes | factor |
|---|---|---|---|
| embedded `(liveAt (-1)).card`, `#eval` | 20225 ms (Phase 1) | **200 ms** | **101x** |
| embedded `fwdLiveT.card`, `#eval` | 8521 ms (Phase 1) | **69 ms** | **124x** |
| embedded `bwdLiveT.card`, `#eval` | 1704 ms (Phase 1) | **17 ms** | **100x** |
| `certA verts.card`, `#eval` | 1114 ms (Phase 1) | **24 ms** | **46x** |
| `certA` sum `predT` cards, `#eval` | 18936 ms (Phase 1) | **237 ms** | **80x** |
| `certA bwdLiveT.card`, `#eval` | 319248 ms (Phase 4) | **564 ms** | **566x** |
| `certA.bwdLiveT.card = 16`, kernel `decide` | 23.7 s (Phase 6) | **3.1 / 4.1 s** | **~6.4x** |
| `certA_certifies`, scratch `decide` wall clock | 43.4 s (Phase 1) | **8.4 s** median of 5 | **~5.2x** |
| `PlusSlicedCertificate.Examples` module build | 36 s (Phase 2), one `decide` | **14 s**, now **three** `decide`s plus the guard | — |
| `certA.liveAt 0`, `#eval` | **did not return in 500 s** (Phase 4) | **2951 ms**, card 4 | **>169x** |
| `certB.liveAt 0`, `#eval` | **did not return in 300 s** (task description) | **22585 ms**, card 4 | **>13x** |

No figure in this table is carried; each "before" names the phase of this round that measured
it. The module-build row is the blunt end-to-end figure: the same module now elaborates `certA`,
`certB`, the embedded witness and the capped guard in 14 s, against 36 s for `certA` alone before
the three fixes.

**The originating symptom, re-run.** The task exists because `#eval (certA.liveAt 0).card` did
not return within 300 s compiled (task description) or 500 s (Phase 4's own measurement), on
only four positions and four window times. It now returns **4 in 2951 ms**, and `certB`'s —
strictly larger, over five window times and a 512-element position space — returns **4 in
22585 ms**. The lower bounds on the factors (169x and 13x) are bounds rather than ratios
because the "before" side never terminated; the true factors are larger by however long those
runs would have taken. Under the kernel, which is the surface the decision procedure is actually
used through, the same configurations are decided in ~8 s and 12 s.
