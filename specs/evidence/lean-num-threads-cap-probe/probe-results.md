# `LEAN_NUM_THREADS` thread-pool-cap probe results

Closes the research report's Risk 3 ("no source consulted measured this variable's actual
effect"). Measured on the toolchain this repository's CI pins (`v4.33.0-rc1`), on this host.

## Host and toolchain

- `nproc`: `24`
- `lake env lean --version`: `Lean (version 4.33.0-rc1, x86_64-unknown-linux-gnu, commit 62eed1db4d67327ec8120be05f1a1b0847d74561, Release)`
- `time` binary used: GNU Time 1.10, resolved via `command -v time` (this NixOS host has no
  `/usr/bin/time`; bash's own `time` reserved word does not accept `-v` and was explicitly
  avoided by invoking the resolved binary's path directly).

## Methodology note (read before the verdict below)

The probe committed alongside this file (`probe.lean`) is not the first design tried. A pure
`Task.spawn (fun _ => ...)` closure — the simpler of the two mechanisms the plan names — was
tried first and found to never observably use more than one worker thread on this toolchain,
**regardless of `LEAN_NUM_THREADS`**, including at `Task.Priority.dedicated` (which the Lean
reference documents as always getting its own OS thread, independent of the pool). This was
confirmed by polling `/proc/<pid>/task/*/stat` once per second across a compiled (not
interpreted) build of the same probe logic: exactly one thread ever showed `R` (running) state,
at `LEAN_NUM_THREADS` unset, `=1`, and `=8` alike.

Switching the spawn mechanism to `IO.asTask` wrapping a CPU-bound `IO` action (the plan's other
named mechanism) produced genuine, confirmed multi-thread concurrency: the same `/proc` polling
against a compiled 8-task `IO.asTask` probe showed **8 threads simultaneously in the `R` state**
at `LEAN_NUM_THREADS=8`. `probe.lean` therefore uses `IO.asTask`, not `Task.spawn`.

This matters for reading the verdict below honestly: the two official runs that follow measure
`IO.asTask`-driven concurrency under `lake env lean --run` (the interpreter), which is a
different code path from Lake's own build-job scheduler (a compiled program). A Lean maintainer
statement located during this investigation is relevant to that gap: Mac Malone, in the
leanprover-community Zulip thread ["number of threads for lake
build"](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/number.20of.20threads.20for.20lake.20build.html),
states that Lean "does not provide a way for user programs (like Lake) to limit the number of
threads in its `Task` thread pool" and that "`LEAN_NUM_THREADS` serves a good-enough fix for the
few places this has been an issue" — i.e. Lake does not read or interpret this variable itself;
it relies entirely on the generic runtime mechanism this probe measures, and a maintainer
directly vouches for that mechanism's practical effectiveness for exactly this class of problem.
The Lean reference documentation also states the pool's configured size "is not a hard limit; in
certain situations it may be exceeded to avoid deadlocks" — a documented soft-limit escape this
probe's own measurements are consistent with (see verdict).

## Official measurements

**Command 1** (`LEAN_NUM_THREADS` unset):
```
env -u LEAN_NUM_THREADS time -v lake env lean --run specs/evidence/lean-num-threads-cap-probe/probe.lean
```
Output:
```
nTasks=48 itersPerTask=5000000 total=119975639865600
Percent of CPU this job got: 1433%
Elapsed (wall clock) time (h:mm:ss or m:ss): 0:16.70
User time (seconds): 237.84
System time (seconds): 1.52
```

**Command 2** (`LEAN_NUM_THREADS=1`):
```
env LEAN_NUM_THREADS=1 time -v lake env lean --run specs/evidence/lean-num-threads-cap-probe/probe.lean
```
Output:
```
nTasks=48 itersPerTask=5000000 total=119975639865600
Percent of CPU this job got: 1669%
Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.20
User time (seconds): 236.44
System time (seconds): 0.76
```

(Both runs report the identical `total`, confirming both executed the same work; the small
`Elapsed`/`User time` differences between the two runs are ordinary run-to-run noise, not a
systematic effect — the `LEAN_NUM_THREADS=1` run was if anything slightly faster.)

## Verdict: **inconclusive**

Reading the numbers plainly: the `LEAN_NUM_THREADS=1` run's CPU percent (1669%) does not
collapse toward ~100% (ruling out **confirmed**), and it is not lower than the unset run's
1433% — if read as "the capped run shows the same multi-core utilization as uncapped," the raw
numbers alone would support **refuted**.

This is recorded as **inconclusive** rather than **refuted** because the numbers do not cleanly
support either of the other two labels on their own merits, for a reason specific to this
probe's task-shape rather than to the underlying mechanism: `probe.lean` launches 48
simultaneously-ready, mutually-independent tasks from a single non-task caller and waits on them
in a flat loop. The Lean reference's own documented escape valve ("not a hard limit; in certain
situations it may be exceeded to avoid deadlocks") is exactly the kind of behavior a sudden
48-way fan-out could trigger, independent of whether `LEAN_NUM_THREADS` is honored under
ordinary, gradual load — and Lake's real `docgen` job scheduler does not present work this way;
it releases jobs as their dependencies resolve across a build graph, a materially different
shape from this probe's instantaneous flat fan-out. No measurement taken here can distinguish
"the variable doesn't cap anything on this toolchain" from "this probe's own fan-out shape defeats
whatever cap is in effect" — hence: no interpretable signal, not a verdict about the underlying
mechanism either way.

Per the plan's own contingency, an **inconclusive** verdict is not a blocker: Phase 2 proceeds on
the strength of the upstream precedent (the Lake maintainer statement quoted above, plus
`leanprover/lean-action`'s README and `opencompl/veir`'s production `docs.yml`, both already
named in the plan), with this probe serving as attempted corroboration rather than as the basis
for the fix.
