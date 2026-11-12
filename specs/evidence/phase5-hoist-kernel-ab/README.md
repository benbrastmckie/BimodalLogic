# Phase 5 inner-fixpoint hoist: kernel A/B

This directory holds the measurement that decides whether the inner-fixpoint hoist in
`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` stays. The hoist replaced
a per-vertex evaluation of the inner liveness fixpoint with a per-closure-member table
(`untlLiveOf`/`snceLiveOf`, `untlTable`/`snceTable`, `untlLiveAtTab`/`snceLiveAtTab`, and the two
unconditional equalities `untlLiveAtTab_eq`/`snceLiveAtTab_eq`).

Correctness is not what is being measured. The two `_eq` lemmas are unconditional, and every
consumer still reads the pre-hoist vocabulary `untlLiveAt`/`snceLiveAt` through the unchanged
characterizations `mem_fwdLiveStep`/`mem_bwdLiveStep`. Both clause shapes compute the same sets.
What is being measured is cost under the kernel.

## What the two files are

| file | arm | clause shape |
|------|-----|--------------|
| `ab-new.lean` | NEW | the library's own current table shape, used as-is |
| `ab-old.lean` | OLD | a local mirror of the pre-hoist per-vertex shape, built from the library's surviving `untlLiveAt`/`snceLiveAt` |

Each file states the same two closed obligations, each closed `by decide`:

- **Site `certA`** — `TotalEdge.certA`'s backward liveness fixpoint, `bwdLiveT.card = 16`. This is
  the site the original A/B measured. It is the hoist's own object: the fixpoint whose inner
  reachability test the table caches.
- **Site `witness`** — the small embedded witness,
  `((liveFamily.sliced (-1)).liveAt (-1)).card = 1`, mirroring the `maxHeartbeats`-guarded
  `example` in `Examples.lean`.

Neither file is wired into `scripts/check-evidence-probes.sh`. A wall-clock comparison is not a
compile-check invariant, and wiring it would oblige that gate to keep compiling the mirrored OLD
clause shape forever — which is precisely the maintenance cost this measurement exists to weigh.

## Why the certA site is the backward fixpoint and not `certA.Certifies`

`certA.Certifies` is the obligation the build actually pays, and it would be the more
decision-relevant number. It is not an available A/B site: mirroring it in the OLD arm would mean
re-deriving the whole `decidableCertifies` chain downstream of the contraction, not just the
contraction itself. The hoist is encapsulated inside the fixpoint, so the fixpoint is where the
two shapes can be compared against one unchanged build. The original A/B made the same choice for
the same reason.

For scale: at the measured commit, `certA.Certifies` costs about 2.3 s of kernel time and 2.2 s of
elaboration, and the backward fixpoint measured below is a part of that.

## Measurement conditions

- Commit: `e2c2662e0461024619ba2c628cc0610932f9421f`
- Toolchain: `leanprover/lean4:v4.33.0-rc1` (Mathlib pinned at tag `v4.33.0-rc1`)
- **Zero rebuild.** `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` was built to
  completion *before* any timing run, and every run is a `lake env lean` elaboration of one
  standalone scratch file against that one unchanged build. No `.olean` was written between the
  OLD and NEW runs at either site, so the comparison carries no rebuild confound.
- **Serialized.** The whole measurement ran holding an `flock` on `.lake/build-guard.lock` — the
  path `.claude/scripts/lake-build-guard.sh` publishes and `scripts/check-evidence-probes.sh`
  takes — acquired once and held to exit, so no concurrent guarded build could rewrite `.lake`
  mid-measurement. No run reported `object file '...' does not exist`; every run exited 0.
- **Arms interleaved.** Each pass runs OLD then NEW back to back, so a change in machine load
  moves both arms together rather than biasing one.
- **Per-site attribution.** Both files set `profiler true`, so Lean reports
  `tactic execution of ... decide took` and `type checking took` once per declaration in source
  order. "kernel" below is the `type checking` figure — the kernel's own evaluation — and "elab"
  is the `decide` tactic's elaboration-time whnf evaluation. D1 is read off the kernel column.
- `maxHeartbeats 0` is set in both files, identically. A heartbeat cap would convert a slow arm
  into a failure and destroy the measurement. This is correct in a timing probe and in nothing
  else; the library's own guarded `example`s keep their finite caps.

## Raw runs — primary batch (10 passes per arm)

### OLD arm

| run | wall (s) | certA kernel (ms) | certA elab (ms) | witness kernel (ms) | witness elab (ms) |
|-----|----------|-------------------|-----------------|---------------------|-------------------|
| 1 | 3.228 | 755 | 660 | 280 | 314 |
| 2 | 3.643 | 849 | 891 | 347 | 414 |
| 3 | 3.596 | 837 | 1060 | 340 | 403 |
| 4 | 3.657 | 885 | 911 | 345 | 423 |
| 5 | 3.769 | 896 | 1040 | 376 | 435 |
| 6 | 2.927 | 696 | 647 | 264 | 298 |
| 7 | 3.980 | 1020 | 890 | 415 | 494 |
| 8 | 3.640 | 876 | 804 | 332 | 380 |
| 9 | 4.337 | 1040 | 903 | 403 | 446 |
| 10 | 6.348 | 1430 | 1690 | 580 | 788 |

### NEW arm

| run | wall (s) | certA kernel (ms) | certA elab (ms) | witness kernel (ms) | witness elab (ms) |
|-----|----------|-------------------|-----------------|---------------------|-------------------|
| 1 | 3.606 | 900 | 1030 | 374 | 452 |
| 2 | 3.541 | 821 | 894 | 289 | 419 |
| 3 | 3.551 | 833 | 1060 | 356 | 418 |
| 4 | 3.102 | 787 | 686 | 293 | 332 |
| 5 | 3.054 | 717 | 648 | 273 | 309 |
| 6 | 3.296 | 761 | 715 | 268 | 317 |
| 7 | 4.332 | 1090 | 1090 | 454 | 552 |
| 8 | 3.883 | 999 | 853 | 414 | 423 |
| 9 | 6.315 | 1430 | 1640 | 612 | 909 |
| 10 | 5.792 | 1230 | 1510 | 483 | 703 |

Passes 9 and 10 are visibly slower in both arms: the machine picked up load. Because the arms are
interleaved, those passes inflate OLD and NEW together rather than either alone.

## Medians and ratios

`r = median(NEW) / median(OLD)`, per D1.

| site | metric | OLD median | NEW median | **r** |
|------|--------|-----------:|-----------:|------:|
| certA | kernel | 880.5 ms | 866.5 ms | **0.984** |
| certA | elab | 897.0 ms | 962.0 ms | 1.072 |
| witness | kernel | 346.0 ms | 365.0 ms | **1.055** |
| witness | elab | 418.5 ms | 421.0 ms | 1.006 |
| whole file | wall | 3.650 s | 3.579 s | 0.980 |

**The two ratios D1 reads:**

- `r_certA` = **0.984**
- `r_witness` = **1.055**

As a second estimator less sensitive to load, the minimum over the ten passes — the cleanest
observation each arm achieved — gives the same answer:

| site | metric | OLD min | NEW min | r_min |
|------|--------|--------:|--------:|------:|
| certA | kernel | 696 ms | 717 ms | 1.030 |
| witness | kernel | 264 ms | 268 ms | 1.015 |

## The 3-pass pilot, and why it is reported rather than discarded

A first batch of 3 passes per arm was taken under the same lock and the same build immediately
before the batch above. Its raw runs:

### OLD arm (pilot)

| run | wall (s) | certA kernel (ms) | certA elab (ms) | witness kernel (ms) | witness elab (ms) |
|-----|----------|-------------------|-----------------|---------------------|-------------------|
| 1 | 3.595 | 848 | 1030 | 356 | 411 |
| 2 | 3.940 | 845 | 912 | 331 | 401 |
| 3 | 2.940 | 698 | 634 | 275 | 306 |

### NEW arm (pilot)

| run | wall (s) | certA kernel (ms) | certA elab (ms) | witness kernel (ms) | witness elab (ms) |
|-----|----------|-------------------|-----------------|---------------------|-------------------|
| 1 | 3.117 | 706 | 652 | 268 | 282 |
| 2 | 3.564 | 854 | 1020 | 349 | 417 |
| 3 | 3.092 | 729 | 666 | 266 | 302 |

Its medians give `r_certA` = 0.863 and
`r_witness` = 0.810 — NEW apparently 14-19 %
*faster* at both sites. The ten-pass batch does not reproduce that margin. Three passes is simply
too few against a within-arm spread of roughly 20 %, and the pilot is recorded here so that a
future reader sees the sample-size effect rather than inheriting the more flattering number. Both
batches agree on the only thing D1 asks: neither ratio is anywhere near 1.15.

## What this does and does not reproduce

The original A/B measured 25.9 s OLD against 24.4 s NEW at the certA site and called it NEUTRAL
(1.06x, inside variance). This measurement reproduces the **verdict** and not the **absolute
cost**: the same site now costs under a second per arm. The tree has become roughly thirty times
faster at this fixpoint since that measurement was taken, through work that is not the hoist. D1
is a rule about the ratio, and the ratio is what carried over.

The gap the original evidence left — the small embedded witness was A/B'd only under `#eval`,
never under the kernel — is closed here. Under `#eval` the table was about 25 % *worse* at that
site. Under the kernel it is within a few per cent of the per-vertex shape in both directions.
The two measurements are consistent: the kernel's whnf cache already removes most of the
duplication the table was built to remove, so neither the table's win nor its eager-evaluation
cost shows up at kernel scale.

## Verdict: KEEP

**The rule applied.** `r = median(NEW) / median(OLD)` under the kernel at a given site. KEEP if
`r <= 1.15` at both `certA` and the small embedded witness; REVERT if `r > 1.15` at either. The
1.15 band sits deliberately above the 1.06x the original A/B had already characterized as inside
variance, so the rule cannot be tripped by that noise.

**The arithmetic.**

| site | OLD median (kernel) | NEW median (kernel) | r | `r <= 1.15`? |
|------|--------------------:|--------------------:|--:|:------------:|
| certA | 880.5 ms | 866.5 ms | 0.984 | yes |
| witness | 346.0 ms | 365.0 ms | 1.055 | yes |

`866.5 / 880.5 = 0.984`. `365.0 / 346.0 = 1.055`. Both are at or under 1.15, so D1's KEEP
condition is satisfied at both sites, and **the branch is KEEP**.

The margin is not marginal. For `r_witness` to reach 1.15 the NEW arm would have to be a further
9 % slower than measured; for `r_certA` it would have to be a further 17 % slower. The
minimum-over-ten-passes estimator, which is less sensitive to the load spike in passes 9 and 10,
gives 1.030 and 1.015 — further inside the band, not nearer its edge. No estimator applied to
this data selects REVERT.

**D5's fallback was not taken.** Both sites were measured, under the kernel, on one unchanged
build, with the shared `.lake` lock held throughout. The verdict rests on the complete evidence
D1 asks for, not on the certA site alone.

**The `#eval` figures this does not replace.** Under `#eval`, the original A/B measured the table
shape 5.4x *better* at the hard certificate and about 25 % *worse* at the small embedded witness.
Those remain the facts about the interactive path, and they are why the hoist was written. The
kernel numbers above neither confirm nor refute them: they are a different evaluator with a whnf
cache the `#eval` path does not share. The honest combined reading is that the hoist is a real
win where a developer feels it and a wash where the build pays, and that it costs nothing at
either.

## What this verdict does not claim

- **Nothing about correctness.** `untlLiveAtTab_eq` and `snceLiveAtTab_eq` are unconditional, so
  the table shape and the per-vertex shape compute the same sets, provably, with no side
  condition. That was never in question and no timing figure could settle it either way. KEEP
  here is a judgment about a recorded justification and an ongoing maintenance cost, nothing more.
- **Nothing about which shape is faster in general.** Two sites were measured, both inside one
  certificate class, at one commit, on one machine. The claim is that the table shape is not
  materially slower at the two kernel obligations this library actually pays, which is the
  question D1 asks and the only question this data can answer.
- **No endorsement of the justification the module currently records.** The module docstring
  argues for the table on a counting argument — eager cost `|closure|` against short-circuiting
  cost at worst `|X| · |closure|` — and predicts a net kernel win from it. That prediction is what
  the measurement refutes: the kernel's whnf cache had already removed most of the per-vertex
  duplication the argument assumes, which is why the ratio is 0.984 and not something near
  `|X|`. Correcting that claim is the substantive work KEEP implies; retaining the code is the
  cheap part.
- **Nothing about a third shape.** This record decides between two shapes that both exist. It
  does not propose or evaluate any further optimization of either.
