# Implementation Summary: Task #630

- **Task**: 630 - Move tool and Boneyard relocation
- **Status**: [COMPLETED]
- **Started**: 2026-09-20T19:03:00-07:00
- **Completed**: 2026-09-20T20:45:00-07:00
- **Effort**: ~1.7 hours wall clock (11 hours estimated)
- **Dependencies**: None blocking. No edge to task 631 in either direction; tasks 632 and 633 depend on this one.
- **Artifacts**: plans/01_move-tool-boneyard-relocation.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Built `scripts/move-modules.py`, a reusable module-relocation tool driven by one auditable
`old.module -> new.module` mapping, with seven separately-counted rewrite classes, a dry-run mode
and a closing invariant-harness run. Then used it for its first production relocation: the 225-file
archive moved from `FormalSystem/Boneyard/` to a root-level `Boneyard/`, with module names
`FormalSystem.Boneyard.*` becoming `Boneyard.*`, every gate re-rooted and widened in the same
commit, two new invariants added, and ADR-010 moved to Accepted. No declaration, proof, axiom
baseline or `sorry` was touched — the archive is never compiled, so this is a change of module
*name* only.

## What Changed

- `scripts/move-modules.py` — new. Classes: 1 import lines, 2 dotted citations, 3 slash paths,
  4 namespace/`open`/FQN, 5 the C2/C14 axiom baselines and `MainResults.lean`'s `#print axioms`
  lines, 6 the `git mv`, 7 relative-link re-basing by resolve-map-recompute. Every rule anchored
  on the *full* old prefix, with a sentinel-based audit asserting pre-existing bare-form citations
  come through byte-identical.
- `Boneyard/**` — 225 tracked files relocated from `FormalSystem/Boneyard/**` as renames
  (115 pure, 110 rename-with-modification), zero delete+add.
- `scripts/check-module-invariants.sh` — B1 and B2 added beside B0; six re-rooting/widening hand
  edits (B0's search root, B0's inverted load-bearing half, C11's scan root, C17's archive walk,
  `archive_dir_count()`'s root, and the C12/C5/C11 patterns). C11 was given its **own** import
  regex admitting `Boneyard`; C4's was deliberately left alone.
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` — **Accepted** 2026-09-20; figures
  corrected; six historical statements restored.
- `docs/architecture/ADR-009-Boneyard-Retention.md` — status pointer repointed; five stale
  figures corrected.
- `docs/development/MODULE_INVARIANTS.md` — B1/B2 rows added; B0 and C11 descriptions re-rooted.
- `docs/development/PUBLICATION_REFACTOR.md` — Phases 0 and 2 marked DONE, with corrected figures.
- `.github/workflows/ci.yml` — dropped the now-no-op `--exclude '*/Boneyard/*'`.
- `README.md` — tree diagram restructured (the archive is a root-level sibling now); inventory
  block regenerated.
- 41 citer files across `docs/`, `FormalSystem/`, `scripts/`, `typst/` and `ORGANISATION.md` —
  tool-rewritten. Two allowlist entries added for the deliberately-unresolvable historical paths.

## Decisions

- **Prefix mapping, not enumeration.** One `FormalSystem.Boneyard -> Boneyard` line, matched as a
  module prefix, rather than a generated 169-row map nobody could audit.
- **The tool rewrites citations; the harness is hand-edited.** B0's inversion and C11's re-rooting
  are semantic changes to what is *asserted*. Letting the tool touch them would let it "fix" a gate
  to agree with whatever it had just produced.
- **Widening and moving are one commit.** Widened first, the pre-existing bare `Boneyard/…`
  citations enter C12 scope while the archive is still under `FormalSystem/`, where they do not
  resolve; moved first, 46 citations silently leave scope with a green board. Neither ordering is
  green, so they are atomic.
- **The bare-form audit re-runs the same rewrite with an opaque replacement.** A naive before/after
  count of bare citations is confounded, because the rewrite *creates* bare forms; the sentinel
  pass separates "preserved" from "created".
- **The tool excludes its own source**, added after it rewrote its own worked examples into
  self-contradictions.

## Plan Deviations

- **Phase 6**: `--emit-inventory` was folded into the move batch rather than deferred to Phase 7.
  Phase 6's acceptance criterion is an exit-0 closing harness run, and `INV` is red until the
  archive README regenerates; deferring would have meant committing a knowingly-red batch.
- **Phase 6**: the tool rewrote its own docstring, collapsing three worked examples into
  self-contradictions. Restored, and `scripts/move-modules.py` added to the tool's exclusion set.
- **Phase 6**: a missing trailing newline in the generated commit-path list concatenated two paths,
  dropping the typst citer and the plan file from the batch; both landed in an immediate follow-up
  commit.
- **Phase 7**: the plan asserted all 46 previously-gated C12+C5 citations would remain in scope.
  Measured against the pre-move tree, the pre-move figure is exactly 40 + 6 = 46, but only **26**
  remain gated. All 20 that left cited *the archive root itself*; neither a path-shaped nor a
  module-shaped pattern gates a bare top-level name, exactly as C12 has never gated `docs/`. This
  is structural to the archive becoming top-level, not a widening failure, and B0 now asserts the
  archive root's existence and location directly.
- **Phase 8**: three of the seven asserted "stale figures" were themselves wrong. ADR-010's "48
  live docstrings" is correct as a file count and was relabelled; "43 markdown files" measures 45;
  "5 typst files" is correct under the `.typ`-only definition. Every corrected figure now carries
  its counting definition inline.
- **Phase 8**: the tool collapsed six historical "old -> new" statements in ADR-010 and one in
  `PUBLICATION_REFACTOR.md` into tautologies. All restored by hand.

## Verification

- Build: **Success** — `lake build` exit 0 (2667 jobs); `lake build BimodalTest` exit 0.
- Harness: **`ALL CHECKS PASSED`**, exit 0, zero gate failures (full build-inclusive run).
- Sorry count: **0** (C3: structural sorry inventory is ZERO across the live tree; zero `sorry`
  lines added by this task).
- Vacuous count: **0** (no `:= True`/`Unit`/`trivial` definition introduced).
- Axiom count: **unchanged** — zero `axiom` declarations added; C2, C14, C21 and C22 all pass, so
  every pinned axiom set still matches its baseline.
- **C11 denominator intact: 539 archived import lines across 169 files, 8 waived** — the carried
  pre-move figure, which is what distinguishes a real pass from a PASS on a shrunken denominator.
- `INV` green; the archive README regenerates "Archive directories in the repository | 1".
- Zero `.olean` under any `Boneyard` path; exactly one `Boneyard` directory and it is `./Boneyard`.
- `git log --follow` on an archived file crosses the rename, reaching 10 commits back to its
  original archiving.
- All 5 non-trivial re-based links resolve on disk, including both `FormalSystem/`-insertion cases
  a `../`-counting heuristic would have broken.
- 53 of 54 bare-form-only citer files are byte-identical; the 54th is `README.md`, whose one
  changed bare-form line is the deliberate tree-diagram restructure.
- Files verified: Yes.

Twelve `FAIL: temp_4 / temp_l / temp_k / temp_future` lines appear in the build output. They are
`Tests/BimodalTest/Automation/ProofSearchTest.lean`'s own axiom-completeness summary (14 axioms ×
3 variants), not harness gates, and the set is byte-identical to the pre-move green capture.

## Impacts

- `lake exe mk_all --check` becomes adoptable: every `.lean` under `FormalSystem/` is now a live
  module the aggregator must import. This was the programme blocker the move existed to clear.
- Generated API documentation and the library module namespace no longer carry 169 never-built
  modules.
- Tasks 632 and 633, which depend on this relocation, are unblocked.
- `scripts/move-modules.py` is available for the programme's later relocations (the `BimodalTools`
  split, ADR-011's extraction), with classes 4 and 5 already exercised against synthetic namespace
  maps rather than shipped unrun.

## Follow-ups

- **The move tool cannot distinguish a current-location citation from a historical statement.**
  It collapsed seven "from X to Y" statements into "from Y to Y" across two documents. Any future
  use on a documented tree must hand-audit the diff of its architectural records. Worth encoding
  as a `--no-rewrite` path list, or at minimum a warning when a rewrite makes both sides of a
  sentence identical.
- The research report recommends a `context/project/lean4/patterns/module-relocation.md` recording
  the seven rewrite classes, the bare-form trap, the resolve-map-recompute algorithm and the
  assert-the-denominator rule. This run adds two more findings worth including: the historical-
  statement blind spot, and that re-rooting a gate to a top-level directory silently narrows what
  a path-shaped pattern can gate.
- `docs/development/PUBLICATION_REFACTOR.md` Phase 8's `mk_all --check` adoption is now unblocked
  but not performed.

## References

- `specs/630_move_tool_and_boneyard_relocation/plans/01_move-tool-boneyard-relocation.md`
- `specs/630_move_tool_and_boneyard_relocation/reports/01_move-tool-boneyard-relocation.md`
- `specs/630_move_tool_and_boneyard_relocation/handoffs/phase-4-dryrun.txt` (recorded dry run)
- `specs/630_move_tool_and_boneyard_relocation/handoffs/phase-6-applied.txt` (realized move)
- `specs/630_move_tool_and_boneyard_relocation/handoffs/phase-7-harness.txt` (acceptance run)
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md`, `ADR-009-Boneyard-Retention.md`
