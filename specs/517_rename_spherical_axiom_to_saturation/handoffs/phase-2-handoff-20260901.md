# Task 517 — Phase 2 handoff (rename landed, all gates green)

**Next action**: Phase 3 — the prose coherence pass (dated absorption entry in
`specs/paper-definitions-of-record.md`, the `⊇`-directed qualifier in
`latex/subfiles/02-Semantics.tex`, the missing `Tests/BimodalTest/Semantics/README.md` rows),
then re-run `check-module-invariants.sh` for C12. No rebuild.

**What landed**: one atomic batch — 40 files substituted, `SphericalFiniteAxiomTest.lean` →
`SaturationFiniteAxiomTest.lean` via `git mv`, two MANIFEST rows, README interim note deleted,
homonym disambiguation added to the `TaskFrame.Saturation` docstring.

**Post-condition (Step 2.9)**: all six hold.
| Assertion | Value |
|---|---|
| `spherical` outside `specs/` | 3, all inside "spherically complete" |
| `SPHLYSENTINEL` outside `specs/` | 0 |
| `saturationity` outside `specs/` | 0 |
| `spherical` in `Tests/` | 0 |
| `cor:spherical-finite` / `def:frame#Spherical` outside `specs/` | 0 |

**Gates**:
| Gate | Result | vs. baseline |
|---|---|---|
| `lake build` (guarded, detached) | exit 0, 2521 jobs, **345 s** | same |
| `check-module-invariants.sh` | exit 0, ALL CHECKS PASSED | same |
| `typst-sync-check.sh` | exit 1, `TOTAL_VIOLATIONS=2` | same two aesop entries, no new |
| `check-paper-definitions.sh` | exit 1, 10 drifted, **0 unresolvable** | drifted set byte-identical; unresolvable 2 → 0 |

**Measured, against the plan's hypothesis**: the rebuild took 345 s, not the multi-thousand-second
re-elaboration the `--timeout 7200` figure anticipated. Detachment was still necessary (345 s is
past the 120 s default foreground cap), but the timeout figure was over-provisioned.

**Deviations**: two, annotated inline — Step 2.9's sentinel and `saturationity` assertions need
the `specs/` exclusion, and the build wall time disconfirms the 7200 hypothesis.
