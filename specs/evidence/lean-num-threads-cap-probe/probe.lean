-- Standalone LEAN_NUM_THREADS thread-pool-cap probe.
--
-- No Mathlib or FormalSystem imports: this measures Lean's own `Task` scheduler behavior on
-- the pinned toolchain, independent of this repository's library. It launches `2 x nproc`
-- CPU-bound (never sleep-bound, so wall-clock CPU percentage is an honest signal of how many
-- ran concurrently) tasks via `IO.asTask` and waits for every one of them before printing a
-- summary.
--
-- MECHANISM NOTE, recorded because it changed what this file does mid-investigation rather
-- than being assumed up front (see `probe-results.md`'s "Methodology note" for the full
-- measurement trail): a pure `Task.spawn (fun _ => ...)` closure on this toolchain never
-- observably runs on more than one worker thread regardless of `LEAN_NUM_THREADS` -- confirmed
-- by polling `/proc/<pid>/task/*/stat` while a compiled probe ran, both at the default priority
-- and at `Task.Priority.dedicated`. An `IO.asTask`-wrapped `IO` action, by contrast, DOES get
-- genuine multi-thread concurrency (confirmed the same way: 8 threads observed simultaneously
-- in the `R` (running) state for a compiled 8-task `IO.asTask` probe at `LEAN_NUM_THREADS=8`).
-- This file therefore uses `IO.asTask`, not `Task.spawn`, as the plan's own wording permits
-- either ("`IO.asTask` or `Task.spawn`").
--
-- Run with `/usr/bin/time -v lake env lean --run probe.lean` (on a host without `/usr/bin/time`,
-- substitute the `time` binary resolved by `command -v time`, invoked by its full resolved path
-- so bash's own `time` reserved word -- which does not accept `-v` -- is not what runs), once
-- with `LEAN_NUM_THREADS` unset and once with `LEAN_NUM_THREADS=1`, and compare the "Percent of
-- CPU this job got" line.

/-- A CPU-bound (never sleep-bound) busy loop, wrapped in `IO` (not pure) so that `IO.asTask`
dispatches it to the genuine multi-thread worker pool described in the mechanism note above. -/
def busyWorkIO (iters : Nat) : IO Nat := do
  let mut acc : Nat := 0
  for i in [0:iters] do
    acc := acc + (i * i + 1) % 1000003
  return acc

/-- Number of cores reported by the host's `nproc`, hard-coded rather than probed at runtime:
the probe's own measured host (see `probe-results.md`) has 24 logical cores, so 48 tasks is
already `>= 2 x nproc` for that host. Re-derive and edit this constant if run on a different
host. -/
def nproc : Nat := 24

def nTasks : Nat := 2 * nproc

/-- Iterations per task, tuned so each run completes in well under a minute while still giving
`/usr/bin/time -v` a stable CPU-percent figure to report. -/
def itersPerTask : Nat := 5_000_000

def main : IO Unit := do
  let tasks ← (Array.range nTasks).mapM (fun _ => IO.asTask (busyWorkIO itersPerTask))
  let mut total : Nat := 0
  for t in tasks do
    match ← IO.wait t with
    | .ok n => total := total + n
    | .error e => IO.eprintln s!"task error: {e}"
  IO.println s!"nTasks={nTasks} itersPerTask={itersPerTask} total={total}"
