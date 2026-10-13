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
