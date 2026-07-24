# Implementation Plan: Orphan Triage — Metalogic Import Closure Execution
- **Task**: 385 - orphan_triage_metalogic_import_closure
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours (4 phases, ~1 hour each)
- **Dependencies**: None (task 359 depends on THIS task, not the reverse)
- **Research Inputs**: specs/385_orphan_triage_metalogic_import_closure/reports/01_orphan-triage-verdicts.md
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4

## Overview

Execute the settled per-file verdicts from the research report (01_orphan-triage-verdicts.md):
of 21 non-Boneyard Metalogic files outside the Bimodal import closure, 1 is KEEP (TraceExport —
no action), 1 is DELETE with a mandatory 6-file test-import re-point (the dead aggregator
`Theories/Bimodal/Metalogic.lean`), 10 are ARCHIVE to `Kamp/Boneyard/`, and 9 are ARCHIVE to
top-level `Theories/Bimodal/Boneyard/` (plus 1 adjacent bit-rotted dependency,
`ProofSystem/Substitution.lean`, archived with its sole importer per the report's Adjacent
Finding 1). The Boneyard build policy is settled as **never-built archives**: the broken
`BoneyardArchive` lean_lib is deleted from `lakefile.lean` and liveness-by-reachability is
documented in both Boneyard READMEs. Definition of done: all moves/deletes/doc-edits landed,
`lake build && lake build BimodalTest` green after every phase, no live file imports any moved
module.

**This is a repo-hygiene task with zero proof construction.** No `sorry` is added or removed
anywhere; no theorem statement changes. All Lean work is `git mv`, import-line rewrites, one
file deletion, and one lakefile block deletion.

### Research Integration

- `reports/01_orphan-triage-verdicts.md` (Tier 3, adversarially verified) — the per-file verdict
  table (report §Findings, rows 1-21) is the SETTLED design. Do not re-litigate any verdict.
  The report independently recomputed the import closure over all 423 modules from the lib root
  + all 12 exe roots + the test driver, and empirically verified buildability of every
  archive-candidate.

### Preserved Assets

No prior implementation phases exist for this task. The following pre-existing work must not
regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Live trace exporter path (KEEP verdict, report row 10) | Theories/Bimodal/Metalogic/Decidability/TraceExport.lean | [LIVE — DO NOT TOUCH] | 2026-07-24 |
| Live Metalogic aggregator | Theories/Bimodal/Metalogic/Metalogic.lean | [LIVE — comment-only edits allowed in Phase 4] | 2026-07-24 |
| Landed Dedekind-INF asset (378 charter) | Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/DedekindINF.lean | [LIVE — DO NOT TOUCH] | 2026-07-24 |
| 37 live NfMultiAnchorBridge files (all except the 4 in report rows 18-21) | Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ | [LIVE — DO NOT TOUCH] | 2026-07-24 |
| Green default build + test suite | `lake build` / `lake build BimodalTest` | [GREEN] | 2026-07-24 |

### Source-to-Implementation Mapping (Tier 3)

| Report section | Plan phase |
|---|---|
| Verdict row 1 (DELETE aggregator + 6 test re-points) + §Boneyard Build Policy lakefile block | Phase 1 |
| Verdict rows 12-21 (10 Kamp files → KB) + row-21 import-line patches | Phase 2 |
| Verdict rows 2-9, 11 (9 files → TB) + Adjacent Finding 1 (ProofSystem/Substitution.lean) | Phase 3 |
| §Boneyard Build Policy "Accompanying doc changes" 1-3 + per-row doc fixes | Phase 4 |

## Goals & Non-Goals

- **Goals**: land all 20 file moves, 1 file delete, 6 test-import re-points, 1 lakefile block
  deletion, ~11 import-line patches, and all README/doc edits from the report; keep the default
  build and test suite green after every phase; preserve git history via `git mv`.
- **Non-Goals** (fenced to the sibling cleanup task — see Postmortem Constraints):
  decl-level archival inside live files; `#exit` header normalization across Boneyard files;
  Fin/non-Fin twin consolidation; repairing the bit-rot inside `ProofSystem/Substitution.lean`
  (it is archived as-is); Boneyard README inventory tidying beyond the entries this task adds.

## Risks & Mitigations

- **Risk**: test files fail to resolve declarations after re-pointing `import Bimodal.Metalogic`
  → `import Bimodal.Metalogic.Metalogic` (the dead aggregator also pulled `SoundnessLemmas.*`).
  **Mitigation**: report row 1 pre-authorizes adding `import Bimodal.Metalogic.Completeness`
  (and if still needed `import Bimodal.Metalogic.Soundness`) to the failing test file;
  `lake build BimodalTest` is the phase gate.
- **Risk**: moving files into `Theories/Bimodal/Boneyard/` while the `BoneyardArchive` glob lib
  still exists would enlarge a broken build target. **Mitigation**: wave ordering — the lakefile
  block is deleted in Phase 1, before any Phase 3 move.
- **Risk**: stale import lines among moved files leave incoherent (though never-compiled) text.
  **Mitigation**: each move phase includes the exact import-line rewrites the report mandates;
  all other stale references are cosmetic and out of scope by the never-built policy.
- **Risk**: accidental history loss or over-staging. **Mitigation**: `git mv` only (never
  rm+add for moves); never `git add -A`; commit per green phase.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the research report's adversarial
verification, the 378-charter PRESERVE constraints, and the division-of-labor agreement with the
follow-on Metalogic cleanup task (359).

**Do NOT**:
- Re-litigate any verdict in the report's 21-row table. Every row was adversarially verified
  against primary evidence (git pickaxe, executed builds, closure recomputation). In particular:
  do NOT archive `TraceExport.lean` (row 10 flipped to KEEP — it is compiled by the
  `trace_exporter` exe root and 2 test files), and do NOT "rescue"/re-import any archived file.
- Perform decl-level archival inside live files (EANegation declarations, `endIntervalStep`,
  intra-file dead-decl sweeps) or `#exit` header normalization across Boneyard files — both are
  the follow-on cleanup task's territory (report §Division of Labor). This task moves whole
  files only.
- Attempt to repair the bit-rot in `ProofSystem/Substitution.lean` (10+ errors, stale `Formula`
  constructor cases). It is archived broken, as-is. Under the never-built policy this is
  acceptable and intended.
- Delete any file other than `Theories/Bimodal/Metalogic.lean`. Everything else is a `git mv`
  (satisfies the 378 charter's "never file deletion" rule for the bridge files).
- Touch `DedekindINF.lean`, any of the 37 live `NfMultiAnchorBridge` files, or any declaration
  matching `hasDefinableINF_excludes_kplus` / `lemma53` / `Basis` / `EANegationFix` (378
  PRESERVE surfaces; report verified the 4 archived bridge files contain none of these).
- Add, keep, or extend ANY lake target covering Boneyard code. `BoneyardArchive` is deleted in
  Phase 1 and nothing replaces it (never-built policy, settled empirically: the target is
  broken today, not vacuous).
- Write task-number references ("task N") into any `Theories/**/*.lean` file or any Boneyard
  README text — use durable anchors only (module names, section headings, commit subjects
  without numbers). Task numbers are permitted only in `specs/**` artifacts and git commit
  messages (`.claude/rules/no-task-references-in-deliverables.md`).
- Use `git add -A`, `git commit -am`, or plain `rm` for moves.

**MUST preserve**:
- `lake build` (default target) AND `lake build BimodalTest` green at the end of every phase.
- All assets in the Preserved Assets table above, byte-identical except where a phase names an
  explicit edit (live `Metalogic/Metalogic.lean` tree-comment lines in Phase 4).
- Git history continuity for every moved file (use `git mv`).

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- Boneyard build policy = never-built archives; liveness = reachability from
  `Theories/Bimodal.lean` or a lakefile `lean_exe`/test root. The alternative (repairing and
  extending `BoneyardArchive`) was rejected on measured breakage + maintenance cost.
- Destination layout: report-specified subdirectories (`SoundnessVariants/`, `FMPVariants/`,
  `ConservativeExtension/`, `DeadCanonicalModel/` under TB; `ZetaProbes/`,
  `NfMultiAnchorBridgeRetired/`, flat `Prop43.lean` under KB).
- `ProofSystem/Substitution.lean` moves with its sole importer `CanonicalIrreflexivity.lean`
  (report Adjacent Finding 1; the alternative — leaving a broken orphan invisible to CI — is
  rejected).
- Test re-point target is `Bimodal.Metalogic.Metalogic` (the live aggregator the lib root
  already imports), not a per-file import list.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 have disjoint file
territories (Phase 2: `Metalogic/WeakCanonical/Kamp/**` only; Phase 3: everything else) and can
be dispatched concurrently under a territory contract, or sequentially — either is safe. Phase 3
MUST NOT start before Phase 1 lands (the `BoneyardArchive` glob would otherwise pick up files
moved into `Theories/Bimodal/Boneyard/`).

### Phase 1: Test-import re-point, dead-aggregator delete, lakefile never-built policy [COMPLETED]

- **Goal:** `Theories/Bimodal/Metalogic.lean` deleted, all 6 Integration tests importing the
  live aggregator instead, `BoneyardArchive` lean_lib removed — build and tests green.
- **Estimated output:** ~70 changed lines (6 one-line edits, 1×55-line file deletion, 1×7-line
  lakefile block deletion). One bounded, verifiable unit: "aggregator gone, everything green".
- **Tasks:**
  - [x] Re-point 6 test imports. In each of the following files replace the exact line
    `import Bimodal.Metalogic` with `import Bimodal.Metalogic.Metalogic`:
    - `Tests/BimodalTest/Integration/Helpers.lean` (line 4)
    - `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` (line 3)
    - `Tests/BimodalTest/Integration/TemporalIntegrationTest.lean` (line 3)
    - `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean` (line 3)
    - `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` (line 3)
    - `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean` (line 4)
  - [x] Verify no other importer remains: `grep -rn "^import Bimodal.Metalogic$" Theories/ Tests/ --include=*.lean` must return nothing after the edits.
  - [x] Delete the dead aggregator: `git rm Theories/Bimodal/Metalogic.lean`
  - [x] Delete the entire `BoneyardArchive` block from `lakefile.lean` (lines 24-29: the
    doc-comment `/-- Archived dead code. ... -/` through `leanOptions := theoryLeanOptions`).
    No other lakefile change.
  - [x] If `lake build BimodalTest` reports unresolved declarations in an Integration test, add
    `import Bimodal.Metalogic.Completeness` (then, only if still failing,
    `import Bimodal.Metalogic.Soundness`) to that file — pre-authorized by report row 1. *(deviation: not needed — BimodalTest built green with no extra imports)*
- **Verification:**
  - [x] `lake build` green
  - [x] `lake build BimodalTest` green
  - [x] `grep -n "BoneyardArchive" lakefile.lean` returns nothing
- **Timing:** ~45 min (dominated by the two builds)
- **Depends on:** none

### Phase 2: Archive batch 1 — 10 Kamp-era files to Kamp/Boneyard [COMPLETED]

- **Goal:** report rows 12-21 moved under
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` with the 3 mandated import-line
  rewrites; build green.
- **Estimated output:** 10 file moves + 3 one-line import edits. One bounded unit: "Kamp batch
  moved, green".
- **Tasks:**
  - [x] Create destination dirs and move (all paths relative to repo root; KAMP =
    `Theories/Bimodal/Metalogic/WeakCanonical/Kamp`): *(deviation: altered — destination
    `$KAMP/Boneyard/Prop43.lean` already existed (older depth-char infrastructure file archived
    in a prior boneyard pass, different content from the live Rabinovich Prop 4.3 file). Neither
    module has any importer. Fix-forward: pre-existing archived file renamed via git mv to
    `$KAMP/Boneyard/Prop43DepthCharInfra.lean` (name matches its "Depth-(k+1) NF
    Characterization Infrastructure" header), then live `Prop43.lean` moved to
    `$KAMP/Boneyard/Prop43.lean` exactly as planned)*
    ```bash
    mkdir -p Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/ZetaProbes
    mkdir -p Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired
    git mv $KAMP/HCaptureDischarge.lean        $KAMP/Boneyard/ZetaProbes/
    git mv $KAMP/InfAlphabetProbe.lean         $KAMP/Boneyard/ZetaProbes/
    git mv $KAMP/OptionBLocalityProbe.lean     $KAMP/Boneyard/ZetaProbes/
    git mv $KAMP/PerFormulaRenderProbe.lean    $KAMP/Boneyard/ZetaProbes/
    git mv $KAMP/ZetaAtomMapReconcile.lean     $KAMP/Boneyard/ZetaProbes/
    git mv $KAMP/Prop43.lean                   $KAMP/Boneyard/
    git mv $KAMP/NfMultiAnchorBridge/NavigatedEndChar.lean         $KAMP/Boneyard/NfMultiAnchorBridgeRetired/
    git mv $KAMP/NfMultiAnchorBridge/ExteriorDeepExclSupplyK.lean  $KAMP/Boneyard/NfMultiAnchorBridgeRetired/
    git mv $KAMP/NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean $KAMP/Boneyard/NfMultiAnchorBridgeRetired/
    git mv $KAMP/NfMultiAnchorBridge/Lemma32Reduction.lean         $KAMP/Boneyard/NfMultiAnchorBridgeRetired/
    ```
  - [x] Import-line rewrites (report rows 18-21; coherence among archived files — they are
    never compiled, but the module paths must match the new locations):
    - `$KAMP/Boneyard/NfMultiAnchorBridgeRetired/NavigatedEndChar.lean` line 2:
      `import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Lemma32Reduction` →
      `import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.NfMultiAnchorBridgeRetired.Lemma32Reduction`
    - `$KAMP/Boneyard/NfMultiAnchorBridgeRetired/ExteriorDeepExclSupplyK.lean` line 2:
      `...Kamp.NfMultiAnchorBridge.ExteriorDeepSliceSupplyK` →
      `...Kamp.Boneyard.NfMultiAnchorBridgeRetired.ExteriorDeepSliceSupplyK`
    - `$KAMP/Boneyard/NavigatedEndCharSinglePoint.lean` line 2:
      `...Kamp.NfMultiAnchorBridge.Lemma32Reduction` →
      `...Kamp.Boneyard.NfMultiAnchorBridgeRetired.Lemma32Reduction`
    - `Prop43.lean`'s existing `Kamp.Boneyard.*` import lines remain valid unchanged (report
      row 17). All other stale import lines inside moved files are cosmetic under the
      never-built policy — leave them.
- **Verification:**
  - [x] `lake build` green (moved files were outside the closure; nothing live changes) —
    1789 jobs, only pre-existing DatasetGenerator unused-variable warning
  - [x] No live file references the moved modules:
    `grep -rn "Kamp.NfMultiAnchorBridge.Lemma32Reduction\|Kamp.Prop43\|Kamp.HCaptureDischarge\|Kamp.InfAlphabetProbe\|Kamp.OptionBLocalityProbe\|Kamp.PerFormulaRenderProbe\|Kamp.ZetaAtomMapReconcile" Theories/ --include=*.lean` hits only files under a `Boneyard/` path
    *(sole hit is a prefix false-positive: `Kamp.Prop43Translate`, a distinct live module not
    among the moved files — zero true hits outside Boneyard)*
  - [x] All 10 files exist at their new paths; old paths gone
- **Timing:** ~45 min
- **Depends on:** 1

### Phase 3: Archive batch 2 — 10 files to top-level Boneyard [COMPLETED]

- **Goal:** report rows 2-9 and 11, plus `ProofSystem/Substitution.lean` (Adjacent Finding 1),
  moved under `Theories/Bimodal/Boneyard/` with mandated import-line rewrites; build green.
- **Estimated output:** 10 file moves (incl. the 4-file + README `ConservativeExtension/`
  directory as a unit) + 8 one-line import edits. One bounded unit: "top-level batch moved,
  green".
- **Tasks:**
  - [x] Create destinations and move (TB = `Theories/Bimodal/Boneyard`, ML =
    `Theories/Bimodal/Metalogic`):
    ```bash
    mkdir -p Theories/Bimodal/Boneyard/SoundnessVariants
    mkdir -p Theories/Bimodal/Boneyard/FMPVariants
    git mv $ML/DenseSoundness.lean                    $TB/SoundnessVariants/
    git mv $ML/DiscreteSoundness.lean                 $TB/SoundnessVariants/
    git mv $ML/ConservativeExtension                  $TB/ConservativeExtension
    git mv $ML/Decidability/FMP/DenseFMP.lean         $TB/FMPVariants/
    git mv $ML/Decidability/FMP/DiscreteFMP.lean      $TB/FMPVariants/
    git mv $ML/Bundle/CanonicalIrreflexivity.lean     $TB/DeadCanonicalModel/
    git mv Theories/Bimodal/ProofSystem/Substitution.lean $TB/DeadCanonicalModel/
    ```
    (`$ML/ConservativeExtension` moves as a directory unit — 4 .lean files + its README.md,
    report rows 4-7. `$TB/DeadCanonicalModel/` already exists with only a README.md — no name
    collision.)
  - [x] Import-line rewrites (report rows 3, 4, 11 + Adjacent Finding 1):
    - `$TB/ConservativeExtension/ExtDerivation.lean` line 1,
      `$TB/ConservativeExtension/Substitution.lean` lines 1-2,
      `$TB/ConservativeExtension/Lifting.lean` line 1: rewrite prefix
      `import Bimodal.Metalogic.ConservativeExtension.` →
      `import Bimodal.Boneyard.ConservativeExtension.` (4 lines total)
    - `$TB/StrictSemanticsLegacy/DiscreteCompleteness.lean` line 3:
      `import Bimodal.Metalogic.DiscreteSoundness` →
      `import Bimodal.Boneyard.SoundnessVariants.DiscreteSoundness`
    - `$TB/DeadCanonicalModel/CanonicalIrreflexivity.lean` line 10:
      `import Bimodal.ProofSystem.Substitution` →
      `import Bimodal.Boneyard.DeadCanonicalModel.Substitution`
  - [x] Do NOT edit the interior of `Substitution.lean` (archived broken, as-is) or any other
    moved file beyond the import lines above.
- **Verification:**
  - [x] `lake build` green (1789 jobs)
  - [x] No live file references the moved modules:
    `grep -rn "Bimodal.Metalogic.DenseSoundness\|Bimodal.Metalogic.DiscreteSoundness\|Bimodal.Metalogic.ConservativeExtension\|FMP.DenseFMP\|FMP.DiscreteFMP\|Bundle.CanonicalIrreflexivity\|Bimodal.ProofSystem.Substitution" Theories/ --include=*.lean` hits only files under `Theories/Bimodal/Boneyard/`
  - [x] All 10 files (+ ConservativeExtension README) exist at new paths; old paths gone;
    `Theories/Bimodal/Metalogic/Decidability/FMP/` and `.../Bundle/` still contain their live
    files
- **Timing:** ~45 min
- **Depends on:** 1

### Phase 4: Boneyard policy READMEs, doc-reference fixes, final verification [COMPLETED]

- **Goal:** never-built policy documented in both Boneyard READMEs; all doc references to moved
  files corrected; full final verification.
- **Estimated output:** ~120 lines across 7 docs (1 new README, 6 edits). One bounded unit:
  "docs consistent, final gate green".
- **Tasks:**
  - [x] `Theories/Bimodal/Boneyard/README.md` (§"How to Verify Compilation", ~lines 300-315):
    remove the `lake build BoneyardArchive` instructions and the `BoneyardArchive` target
    description; state the policy: "Boneyard code is never compiled. Liveness = reachability
    from `Theories/Bimodal.lean` or a lakefile root. `lake build` (default target) must stay
    green after any Boneyard change." Add Directory Inventory rows for `SoundnessVariants/`,
    `FMPVariants/`, `ConservativeExtension/`, and the new `DeadCanonicalModel/` entries.
    *(deviation: altered — additionally rephrased 12 pre-existing lowercase "task N" prose
    mentions to durable anchors so the phase's no-task-references grep gate passes; the
    Directory Inventory "Task" column and Task Cross-References table (bare numbers, no
    "task N" literal) left as-is)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` (none
    exists): same never-built policy statement + inventory of `ZetaProbes/` (5 files),
    `NfMultiAnchorBridgeRetired/` (4 files), `Prop43.lean`, and the pre-existing contents.
    Explain provenance with durable anchors (e.g. "superseded by the landed ζ wire",
    "retired k≥2 per-depth escalation path") — NO task numbers anywhere in README text.
    (Reflects the Phase 2 deviation: pre-existing occupant renamed to
    `Prop43DepthCharInfra.lean`, documented as unrelated to the Rabinovich Prop 4.3 file.)
  - [x] `Theories/Bimodal/Boneyard/MergedBracketQuarantine/README.md` line ~18: rewrite
    "inert even inside the `BoneyardArchive` lib" — the target no longer exists (e.g. "inert
    under the never-built Boneyard policy").
  - [x] `Theories/Bimodal/Metalogic/README.md`: remove/annotate moved entries — tree lines 46-47
    (DenseSoundness/DiscreteSoundness), line 73 (CanonicalIrreflexivity), line 116
    (ConservativeExtension tree entry), line ~299 (ConservativeExtension table row, currently
    "Active"). *(table row replaced with an archival note pointing at
    `Boneyard/ConservativeExtension/` and `Boneyard/SoundnessVariants/`)*
  - [x] `Theories/Bimodal/Metalogic/Decidability/FMP/README.md` lines 14-15: remove
    DenseFMP/DiscreteFMP rows (or move to an "archived" note). *(deviation: altered — also
    updated the intro sentence and Key Results list, which referenced the archived
    `fmp_dense`/`fmp_discrete` declarations; folded into the archived note)*
  - [x] `Theories/Bimodal/Metalogic/Metalogic.lean` tree-comment lines 74-76: drop the
    `ConservativeExtension/` line from the directory-tree comment (comment-only edit to a live
    file; no import/decl changes). *(deviation: altered — also dropped the stale
    `DenseSoundness.lean`/`DiscreteSoundness.lean` lines from the same tree comment, folding
    the variants into the `Soundness.lean` line; comment-only, same class of stale reference)*
  - [x] `Theories/Bimodal/typst/SYNC-MAP.md` lines 176 and 180: update the two mentions of
    `DenseSoundness`/`DiscreteSoundness` to reflect archival (files no longer top-level
    Metalogic modules; mapped-lines count stays 0).
- **Verification (final gate for the whole task):**
  - [x] `lake build` green (1789 jobs) AND `lake build BimodalTest` green (1824 jobs)
  - [x] `grep -n "BoneyardArchive" lakefile.lean Theories/Bimodal/Boneyard/README.md Theories/Bimodal/Boneyard/MergedBracketQuarantine/README.md` returns nothing
  - [x] `grep -rn "task [0-9]" Theories/Bimodal/Boneyard/README.md "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/README.md"` returns nothing (no-task-references rule)
  - [x] Re-run both Phase 2 and Phase 3 no-live-importer greps — still clean (zero hits
    outside Boneyard paths)
  - [x] `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` untouched
    (`git diff --name-only` does not list it); zero added `sorry` tokens in the Phase 4 diff
    (the two `+` lines containing "sorry" are prose: "sorries removed" / "sorry-free")
- **Timing:** ~60 min
- **Depends on:** 2, 3

## Testing & Validation

- Per-phase gate: `lake build` (default target) must be green at the end of every phase;
  `lake build BimodalTest` additionally at Phases 1 and 4 (recommended verification gate,
  report Adjacent Finding 3).
- No-live-importer greps as specified per phase (moved modules referenced only from
  `Boneyard/` paths).
- Negative checks: no `BoneyardArchive` anywhere outside git history; no task-number strings in
  any `Theories/**` file touched.
- No new `sorry`s: `git diff` across the task must show zero added `sorry` tokens (moves only).

## Artifacts & Outputs

- plans/01_orphan-triage-execution.md (this file)
- summaries/01_orphan-triage-execution-summary.md (at implementation completion)
- Repo changes: 20 `git mv` moves (10 → KB, 10 → TB incl. ConservativeExtension README),
  1 deletion (`Theories/Bimodal/Metalogic.lean`), lakefile `BoneyardArchive` block removal,
  6 test-import re-points, ~11 import-line patches, 1 new README
  (`Kamp/Boneyard/README.md`), 6 doc edits.

## Rollback/Contingency

- Every phase ends in a green commit (`task 385 phase P: {name}` per git-workflow.md); rollback
  = `git revert` of the phase commit(s). No destructive git on uncommitted work; snapshot via
  `git-snapshot.sh` before any intentional rollback.
- If a Phase 1 test re-point cannot be made green with the pre-authorized extra imports, STOP,
  keep the aggregator deletion uncommitted-reverted (restore via git), and report the exact
  unresolved declarations — do not improvise a different import surface.
- Phases 2/3 have zero live-build risk (closure-verified); a failure there indicates an
  execution error (wrong path, missed `git mv`) — fix forward within the phase.
