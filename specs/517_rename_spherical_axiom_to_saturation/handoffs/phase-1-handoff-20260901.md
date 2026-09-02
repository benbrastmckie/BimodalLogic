# Task 517 — Phase 1 handoff (baseline captured)

**Next action**: Phase 2, Step 2.1 — `sed -i 's/[Ss]phericality/saturation/g' FormalSystem/Semantics/TaskFrame.lean`, then the sentinel/global/restore passes.

**Working HEAD**: `34d512e8d` (not the plan's `92b154ab2` — task 518's implementation `9cd17f308`
and task 517's own research/plan commits landed in between). All eight baseline figures still
match the plan's expectations, so no post-condition re-derivation was needed.

**Measured baseline**:
| Measurement | Value |
|---|---|
| `spherical` outside `specs/` | 444 |
| `spherically` outside `specs/` | 3 (`TaskFrame.lean:393`, `:394`, `README.md:80`) |
| files outside `specs/` | 40 (frozen to `/tmp/517-files.txt`) |
| `saturationity` outside `specs/` | 0 |
| `lake-build-guard.sh build --timeout 1800 -- build` | exit 0, 2521 jobs |
| `check-module-invariants.sh` | exit 0, ALL CHECKS PASSED |
| `typst-sync-check.sh` | exit 1, `TOTAL_VIOLATIONS=2` (both aesop, `p4-proof-automation.typ`) |
| `check-paper-definitions.sh` | exit 1, 10 drifted, 2 unresolvable (`def:frame#Spherical`, `cor:spherical-finite`) |

The 10 drifted anchor names are saved at `/tmp/517-baseline-drifted.txt`; full gate output at
`/tmp/517-baseline-{build,typst,invariants,paperdefs}.log`.

**Sentinel** `SPHLYSENTINEL` confirmed absent from all 40 target files.

**Snapshot**: `git-snapshot-1788327852` (stash@{0}).

**Deviations**: two, both annotated inline on the Phase 1 checklist — the `saturationity` census
command needs the `specs/` exclusion, and `git-snapshot.sh` reverted the working tree (restored
via `git stash apply`).
