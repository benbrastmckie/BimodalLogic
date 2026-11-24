# Proof-mode cost baseline: measurement conditions

This directory holds the probe that produces every figure in
[docs/development/proof-mode-cost-baseline.md](../../../docs/development/proof-mode-cost-baseline.md).
It measures how expensive the derivation proof mode's scripts are — not whether they are correct,
which the acceptance fixtures and
[Tests/BimodalTest/Automation/ProofModeAxioms.lean](../../../Tests/BimodalTest/Automation/ProofModeAxioms.lean)
already settle.

## What the file is

| file | role |
|------|------|
| `cost-probe.lean` | 73 `#reprove_record` invocations: 48 acceptance-script mirrors, the `lintro` ladder at depth 1–16, the nested logical rewrite at 0–4 scopes, two simplifier rows and two views rows |

The probe is driven by `scripts/proof-mode-cost-baseline.sh`, which is the one command the
baseline document names as its reproduction route.

## It is deliberately not wired into `scripts/check-evidence-probes.sh`

A wall-clock elaboration-time measurement is not a compile-check invariant. Wiring the probe would
oblige that gate to keep compiling 48 mirrored acceptance scripts forever — for an assertion the
acceptance fixtures already make, in the library where they belong. The probe's own run under
`scripts/proof-mode-cost-baseline.sh` is what exercises it, and that script's first action is a
staleness re-probe against the commit the baseline document pins, so a moved head reports a stale
baseline rather than a wrong figure.

That gate reads an explicit `WIRED` allowlist rather than globbing, so leaving the probe out is an
omission by decision, not by accident. This paragraph is the record of that decision; a reader
should not have to infer it from the absence of an entry.

## 48, not 52

`grep -c '^example' Tests/BimodalTest/Automation/ProofMode*Test.lean` reports 52, and that is the
figure the task's planning carried. The count is not the number of acceptance scripts. Four of the
52 are `#guard_msgs`-guarded **negative** fixtures in `ProofModeBooleanTest.lean`, whose `example`
also begins at column 0 and so is counted by that grep. Measured breakdown, positive against
guarded:

| module | positive | guarded |
|--------|---------:|--------:|
| `ProofModeTest.lean` | 31 | 0 |
| `ProofModeBooleanTest.lean` | 2 | 4 |
| `ProofModeModalBooleanTest.lean` | 4 | 0 |
| `ProofModeTemporalBooleanTest.lean` | 5 | 0 |
| `ProofModeModalTemporalBooleanTest.lean` | 6 | 0 |
| **total** | **48** | **4** |

The 48 are mirrored. The 4 are not: a script asserted to fail has no cost worth recording, and
mirroring one would put a deliberately-failing declaration into a probe that is supposed to
elaborate clean.

## Measurement discipline

- **Commit and toolchain pinned.** The probe records the commit through the
  `diagnostics.commit` option, stamped from outside by
  `lake env lean -Ddiagnostics.commit=<sha>`, so the tracked file stays stamp-free and no figure
  can be attributed to the wrong tree. Toolchain: the `lean-toolchain` pin, Mathlib tag
  `v4.33.0-rc1`.
- **Zero rebuild.** The library is built to completion before any timing run. Every run is one
  `lake env lean` elaboration against one unchanged build, so no figure includes compilation of
  anything the probe imports.
- **Serialized.** The driving script takes the shared `.lake/build-guard.lock` once and holds it
  to exit, so no concurrent build competes for cores while a wall-clock figure is being taken.
- **Arms interleaved.** The rows of a ladder are elaborated in one file in source order, so
  machine load moves them together rather than biasing one depth against another.
- **Per-site attribution.** `set_option profiler true` makes Lean report
  `tactic execution of ... took` and `type checking took` per declaration, in source order. That
  output is the cross-check on each record's own `elab_ms`, which the emitter measures directly
  around the declaration it wraps.
- **`maxHeartbeats 0` is correct here and nowhere in the library.** A heartbeat cap would convert
  a slow script into a failure and destroy the measurement. It is set at file scope in the probe
  rather than inside `#reprove_record`, so that the measurement's conditions are visible in the
  file a reader is looking at.
- **`profiler true` and `maxHeartbeats 0` are both out of `check-module-invariants.sh` C30's
  scope.** C30 scans `FormalSystem/`, `Tests/` and `scripts/`. The probe is sited under
  `specs/evidence/`, which is where the identical pattern already lives in
  `../phase5-hoist-kernel-ab/ab-new.lean` with the same header note.

## The two timing figures, and which to quote

Each record carries both `heartbeats` and `elab_ms`.

`heartbeats` is deterministic for a fixed toolchain and library, so it is the figure a gate can
quote and a check can compare. It is **not** comparable across instruments: a figure taken by
`#reprove_record` includes the wrapper's own record assembly, and is consistently larger than the
same script measured by Mathlib's `#count_heartbeats in`. What is instrument-independent is the
*shape* — linear, quadratic — and that is what the baseline document states.

`elab_ms` is wall clock, which is what "elaboration time" literally asks for, and is
machine-dependent. It is reported so the figures are legible to a human, never so that two
machines' numbers are compared.

Neither figure is pinned by a `#guard_msgs` anywhere. Only axiom sets are, in the test library.

## Mirrors are a second copy, by necessity

`Tests/BimodalTest/Automation/ProofModeAxioms.lean` already holds named mirrors of a
representative script per tactic family. The probe's mirrors duplicate that idea, and the
duplication is forced by the instrument: a heartbeat count can only be taken of an elaboration the
counter performs itself, so the probe cannot read already-elaborated declarations out of an
import. It must re-elaborate. Each file's header says so.

Each mirror is mechanically derived from its fixture — the `example` keyword replaced by
`def m<NN>`, nothing else in the body touched — so the figure measured is the acceptance script's
own cost. No fixture is edited; `git diff --stat <base> -- Tests/BimodalTest/Automation/ProofMode*Test.lean`
is empty at every commit of this work.

---

*Last verified: 2026-11-23*
