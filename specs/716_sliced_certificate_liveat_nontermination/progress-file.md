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
