# Implementation Summary: Module Organization Refactor

- **Task**: 131 - refactor_module_organization
- **Status**: [COMPLETED]
- **Plan**: specs/131_refactor_module_organization/plans/01_module-reorganization.md
- **Research**: specs/131_refactor_module_organization/reports/01_module-reorganization-research.md
- **Phases**: 13 of 13 completed
- **Type**: lean4
- **Session**: sess_1785109682_231902

## Outcome

All 13 phases completed, each committed separately and each gated on
`scripts/check-module-invariants.sh` exiting 0. No declaration was renamed; every
structural operation was `git mv` plus an import rewrite.

**Preservation invariants, verified at the final gate:**

| Invariant | Baseline | Final |
|-----------|----------|-------|
| `lake build` | green | green |
| `lake build BimodalTest` | green | green |
| Sole structural `sorry` | `theorem countermodel_discrete`, `WeakCanonical/Transfer.lean` | unchanged (located by content, never by line number) |
| Four flagship `#print axioms` sets | recorded | **byte-identical** |
| New axioms introduced | 0 | 0 |

Final-vs-baseline diff of the invariant output contains only intended changes:
import lines 1052 -> 1078, live `.lean` under `Theories/` 288 -> 290, unreachable
modules 11 -> 9, allowlist 14 -> 4, and C8/C9/C10 moving from unenforced to passing.

## What Was Built

`scripts/check-module-invariants.sh` (checks B0, C1-C10) plus two companion files, run
at every phase boundary. It is documented at `docs/development/MODULE_INVARIANTS.md`.
It caught real breakage at four separate gates that a `.lean`-only review would have
missed — see [What the Gate Caught](#what-the-gate-caught).

## Decisions

These are recorded so the follow-on systematic naming work does not re-litigate them.

### Declined: physical regroup of the three completeness routes

`BXCanonical` (chronicle), `WeakCanonical` (Kamp/Reynolds) and `Algebraic` (parametric)
stay as siblings. Two reasons, both measured:

1. **Directory nesting cannot express the dependency.** Exactly two directory-level
   cycles exist: `BXCanonical <-> WeakCanonical` (2 lines out, 4 back) and
   `Bundle <-> Core` (18 out, 1 back). Any nesting produces a directory whose contents
   import upward out of it. Lean tolerates these because they exist only at directory
   granularity — the module graph is acyclic.
2. **`WeakCanonical` is the largest partial-move risk in the tree**: 339 import lines
   across 137 live files, roughly five times the next-largest subtree.

Deliverable instead: a correct architecture map (`Theories/Bimodal/Metalogic/README.md`)
plus one aggregator convention. Full edge table in `edge-table-post-structural.txt`.

A finding the research did not surface: **`BXCanonical` imports from both other routes**
(2 lines each). The three are not independent alternatives — all three are live.

### Declined: breaking the `Core <-> Bundle` cycle

Relocating the sole `Core -> Bundle` edge (`Core/RestrictedMCS/Basic.lean`) needs 2
import-line edits but touches 9 files, 5 of them markdown. The agreed abort threshold
(>10 import lines **or** >6 files) fired on the file count. Skipped and recorded.

Note for any future attempt: the planning-time figure of "exactly 1 importer" is now 2 —
the new `Metalogic/Core.lean` aggregator imports it by design. Re-measure.

### Settled: `FrameConditions/` stays separate from `Metalogic/`

Resolved on evidence, not preference. Files under `Metalogic/` importing
`Bimodal.FrameConditions`: **0**. `FrameConditions/` imports `Bimodal.Metalogic.Soundness`,
`Bimodal.ProofSystem.Axioms`, `Bimodal.Semantics.Validity`. Sole live importer of
`Bimodal.FrameConditions`: the library root `Bimodal.lean`. It is a 4-module / 816-line
typeclass API layer sitting strictly *above* Metalogic; merging would invert the
dependency direction and create a third cycle.

Its own README had asserted this **backwards** ("imported by `Bimodal.Metalogic.Soundness`").
Now corrected, with a re-derivation command.

### Settled: `docs/`, `latex/`, `typst/` move to the project root

`srcDir := "Theories"` means Lake treats that tree as source, yet it held ~2.6M of
non-Lean assets. All three now sit at the project root, with `Theories/Bimodal/docs/`
**merged into** the existing root `docs/` rather than parked beside it — the repository
previously carried two parallel `docs/` trees that cross-linked into each other, and
that incoherence was the actual defect.

30 source files, 47 root files, 5 collisions (all index READMEs). Resolved explicitly:
25 files `git mv`'d, and for the 5 the incoming content was appended under a labelled
heading rather than overwriting either side.

### Deferred: renaming the Lean source root

`Theories/` keeps its name. That rename belongs to the systematic naming work per the
charter.

### Aggregator convention

Sibling `X.lean` beside `X/`; no `X/X.lean`. Applied across `Metalogic/`, enforced by C8.
`Core.lean`, `Bundle.lean`, `Algebraic.lean` and `SoundnessLemmas.lean` were created and
deliberately have **no importer** — an aggregator imported by a file its own contents
already reach is how a real module-level cycle appears. Being unreachable, they are
manifested so C6 compile-checks them.

Documented exception: the Lake root pair `Theories/Bimodal.lean` +
`Theories/Bimodal/Bimodal.lean`, allowlisted by name in the check.

### Fate of each dead and orphaned module

| Module | Compiles? | Outcome |
|--------|-----------|---------|
| `Metalogic/Completeness.lean` | yes | **Archived** to `Boneyard/SupersededCompleteness/`. Unreferenced, not broken — that fact is recorded in the Boneyard README because nothing re-checks an inert file |
| `ProofSystem/LinearityDerivedFacts.lean` | yes | **Wired in** to `ProofSystem.lean`; its `Axioms.lean` non-derivability citation is now backed by compiled code |
| `Automation/ProofFirstBenchmark.lean` | yes | Stays unreachable — its only importer is a quarantined test. Manifested |
| `BimodalTest.Automation.InterestingnessTest` | yes | **Wired in** |
| `BimodalTest.TraceCertificateTest` | yes | **Wired in** |
| `BimodalTest.TraceExportTest` | yes | **Wired in** |
| `BimodalTest.TraceExporterE2ETest` | yes | **Wired in** |
| `BimodalTest.Automation.FormulaMutatorTest` | yes, in isolation | **Quarantined** — importing it into the test root yields "environment already contains 'main'"; it pulls in an executable root |
| `BimodalTest.Automation.ProofFirstTests` | yes, in isolation | **Quarantined** — same duplicate-`main` collision |
| `BimodalTest.ProofSystem.DerivationBenchmark` | **no** | Quarantined `broken:` — passes `String` where `Atom` is required |
| `BimodalTest.Semantics.SemanticBenchmark` | **no** | Quarantined `broken:` — same |

Unreachable live modules: 11 -> 9. All are manifested and compile-checked.

## What the Gate Caught

Each of these was invisible to `lake build` and to a `.lean`-only review:

1. **Phase 3** — `typst/SYNC-MAP.md` named `Bimodal.Metalogic.BXCanonical.BXCanonical`, and
   `typst/chapters/04-metalogic.typ` cited the path `Metalogic/Metalogic.lean`.
2. **Phase 5** — four markdown references to the archived `Bimodal.Metalogic.Completeness`,
   in two subdirectory READMEs and two root `docs/` files.
3. **Phase 11** — a **regression this task itself introduced in Phase 4**:
   `scripts/typst-status-counts.sh` called `strip_and_count_sorries` on
   `Metalogic/Relational`, which Phase 4 deleted. Under `set -e` the missing path aborted
   the script, which made `typst-sync-check.sh` Check 2 die on empty JSON. The invariant
   script could not catch this — it never runs the typst toolchain — which is exactly why
   the plan required *executing* those scripts rather than grepping for stale strings.
4. **Phase 11** — two stale path claims inside the book (`Relational/` and
   `Metalogic/Completeness.lean`), also caused by this task's Phases 4 and 5.

## Corrections to Plan and Research Assumptions

Recorded because each was stated as fact and measured otherwise:

- **`Claim1.lean` was not the only `Metalogic -> Automation` edge.** Four more exist and
  remain, all in `Metalogic/Decidability/`. The phase criterion "zero files under
  `Metalogic/` import `Bimodal.Automation.*`" was unreachable; the move still removed one
  genuine inversion and fixed the namespace/path mismatch. The four are documented as a
  named layering wrinkle in the architecture map.
- **Module-doc coverage was already 100%, not 99%.**
  `Kamp/NfMultiAnchorBridge.lean` does carry a `/-!` module doc — it sits at line 180,
  after ~160 lines of import-rationale comments. Zero of 290 live files lack one.
- **Task-number citations: 82, not 79; planted notes: 26, not 14.**
- **`FrameClass` references: 96, not 97.**
- **`WeakCanonical/README.md` was wrong well beyond the moved file** — it listed a
  non-existent `ExpressiveCompleteness/` and `Separation.lean`, omitted `Kamp/` (99 files
  / 71,246 lines) and `PriorDefs.lean` entirely, and gave `Separation/` as "11+ files"
  against an actual 3.

## Plan Deviations

Every deviation is annotated inline on its checklist item in the plan file. Summary:

- **Phase 1 (altered)** — C8/C9/C10 authored up front behind `ENFORCE_*` flags defaulting
  to 0, reported as `TODO`. Phases 6/10/12 flip their flag rather than authoring the check.
  A check that fails at every gate is not a gate.
- **Phase 2 (altered ×2)** — used `lake build <Module>` instead of `lake env lean <path>`
  (the latter reports spurious missing-`.olean` errors that read as rot). Only 4 of 6
  compiling modules could be wired; 2 hit a duplicate-`main` collision.
- **Phase 3 (altered)** — the `Bimodal.lean` broken-link fix needed no edit; the move
  made the existing link resolve. Verified, not edited.
- **Phase 4 (altered ×2)** — the layering measurement contradicted the plan's premise
  (above); `WeakCanonical/README.md` scope widened because the table was materially wrong.
- **Phase 5 (altered)** — two root-`docs/` files nominally belonging to Phase 13 were
  corrected early, because C5 fails the phase that creates a dangling path.
- **Phase 6 (altered)** — C8 enabled rather than authored.
- **Phase 8 (skipped)** — the "missing module docstring" does not exist.
- **Phase 9 (altered)** — `FrameClass` count re-measured as 96.
- **Phase 10 (altered ×2)** — counts differ from the plan's estimates; C9 enabled rather
  than authored.
- **Phase 11 (skipped)** — `status.typ` not regenerated: its 6 count mismatches are
  pre-existing book-content drift unrelated to the relocation, and the phase criterion is
  "no new violations relative to pre-move behaviour", which is met.
- **Phase 12 (altered + skipped)** — C10 enabled rather than authored; the criterion
  "every relative markdown link in `docs/` resolves" is not met and was not achievable.
  Of 104 broken links, exactly 5 were caused by the move (all fixed, identified by
  differential check: broken from the new location and resolvable from the old). The
  remaining ~96 are pre-existing rot pointing at a `Development/` directory and a `Logos/`
  tree that no longer exist. Fixing them is a documentation-rot task; doing it silently
  here would hide its size.

## Follow-On Work Identified

Not in scope here, recorded so it is not lost:

1. **~96 pre-existing broken relative links** under `docs/` (`Development/`, `Logos/`,
   `../../TODO.md`, and similar).
2. **18 pre-existing `typst-sync-check.sh` Check 1 violations** — book content citing
   long-archived modules (`ConservativeExtension/`, `DenseSoundness.lean`,
   `FMP/DenseFMP.lean`, `lift_derivation_qfree`, ...).
3. **`status.typ` count drift** — committed sorry counts (Algebraic 3, BXCanonical 4,
   Bundle 12, WeakCanonical 24) against live 0/0/0/5.
4. **Two broken test modules** (`DerivationBenchmark`, `SemanticBenchmark`) — `String`
   vs `Atom`.
5. **Two test modules blocked by duplicate `main`** — needs the executable roots
   restructured so `main` does not live in an importable module.
6. **Four `Decidability -> Automation` upward edges** — needs the proof-search /
   decision-procedure boundary relocated.

## Artifacts

- `scripts/check-module-invariants.sh`, `scripts/module-invariants-manifest.txt`,
  `scripts/module-invariants-allowlist.txt`
- `docs/development/MODULE_INVARIANTS.md`
- `specs/131_refactor_module_organization/baseline-invariants.txt`,
  `final-invariants.txt`, `edge-table-post-structural.txt`
- `Theories/Bimodal/Metalogic/README.md` (rewritten architecture map — goal 1 deliverable)
- `Theories/Bimodal/Metalogic/{Core,Bundle,Algebraic,SoundnessLemmas}.lean` (new aggregators);
  `Metalogic.lean`, `Metalogic/BXCanonical.lean`, `Metalogic/WeakCanonical.lean` (relocated)
- 5 new subdirectory READMEs; rewritten `FrameConditions/README.md`; both Boneyard READMEs
- Root-level `latex/` and `typst/`; merged root `docs/`
