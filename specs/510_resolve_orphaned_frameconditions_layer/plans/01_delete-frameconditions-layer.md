# Implementation Plan: Delete the orphaned `FormalSystem/FrameConditions/` layer

- **Task**: 510 - Resolve orphaned FrameConditions layer
- **Status**: [COMPLETED]
- **Effort**: 5.5 hours
- **Dependencies**: 507 (satisfied — `[COMPLETED]` at `b7ccf6702`)
- **Research Inputs**: `specs/510_resolve_orphaned_frameconditions_layer/reports/01_frameconditions-deletion.md`
- **Artifacts**: plans/01_delete-frameconditions-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Execute the DELETE verdict on `FormalSystem/FrameConditions/`: remove 853 `.lean` lines across
five modules plus the directory README, drop the single live aggregator import, and repair every
documentation, book, and gate consequence in the same change. The layer is a carrier-typeclass
re-encoding of frame classes with no paper counterpart, zero live consumers outside its own
directory, and a recorded soundness-leaning defect; its replacement (`FrameClass.Sat`, `ValidIn`,
`TaskFrame.IsDense`/`IsSuccArchDiscrete`/`IsDedekind`, `Axiom.minFrameClass`) is complete and
already in the tree. Done means: the six paths are gone, `lake build` is green, all three gate
scripts pass — including `typst-sync-check.sh`, which is currently RED at HEAD — and the corrected
form of the archived-completeness finding is recorded in a durable location.

### Research Integration

The research report is the authoritative input and corrected five premises of the original brief.
The plan is written against the report, not the brief:

- **Size**: 853 `.lean` lines, not 906 (report C1).
- **Brief item (b) is already done** (report C2). Commit `e5a9ba40f` deleted
  `ValidOver`/`ValidLinear`/`ValidDenseFc`/`ValidDiscreteFc`/`ValidOverInt`. `Validity.lean` is
  81 lines holding exactly two `FrameOver D` fibration bridges with zero consumers. **No phase
  below re-plans that deletion.**
- **Brief item (c) is 14 `instance` declarations**, not ~40 (report C3): 2 monotonicity + 12
  per-axiom `AxiomLinearCompatible`.
- **The brief's C6 acceptance criterion does not apply** (report C4). `FormalSystem.FrameConditions`
  is *reachable* from `FormalSystem/FormalSystem.lean:13`, so it is correctly absent from
  `scripts/module-invariants-manifest.txt`; C6 counts *unreachable* modules and stays at 17 before
  and after. **Adding a manifest entry would FAIL C6.** The criterion is restated as A3 below.
- **The silent regression is a relocation, not a deletion** (report C5). `completeness_over_Int`
  and `discrete_completeness_fc` survive in
  `FormalSystem/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean`;
  only `dovetailed_bundle` is gone tree-wide.

Each of the report's four execution blockers gets an explicit phase: B1 (C11 waiver) → Phase 4,
B2 (already-red `typst-sync-check.sh` plus its three-name trap) → Phase 2, B3 (11 dangling
`#leansrc` pointers) → Phase 3, B4 (`readme-lint.sh` check 3) → Phase 5.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but no `roadmap_path` was supplied in the delegation context and no
`roadmap_flag` was set, so no roadmap-review/roadmap-update phases are included. A grep of
`specs/ROADMAP.md` finds no `FrameConditions` item, so this task advances no tracked roadmap
entry directly; it is debt removal downstream of the completed frame-class-indexed-validity work.

## Goals & Non-Goals

**Goals**:
- Delete all six `FrameConditions` paths (5 `.lean` files totalling 853 lines + `README.md`),
  together with the sibling aggregator, so C8 ("every `FormalSystem/` subdirectory has exactly one
  sibling aggregator") continues to hold.
- Keep every gate green at the end of the task, including clearing the 2 pre-existing
  `typst-sync-check.sh` violations that are inherited debt from the `e5a9ba40f` trim.
- Repoint the compiled book's frame-property and soundness source citations at the live
  replacements, so no dangling `#leansrc` targets remain.
- Record the corrected form of the archived-completeness finding in a durable, non-`specs/`
  location.

**Non-Goals**:
- Promotion of the marker typeclasses. Ruled out on measured evidence (report §1.4): task 511 is
  `[EXPANDED]`, its successor 513 targets `Semantics/Correspondence/Galois.lean`, and even 511
  never proposed consuming the marker typeclasses.
- Deleting `FormalSystem/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean`. It is
  the archived record on which report finding C5 rests and MUST be retained.
- Any edit to `scripts/module-invariants-manifest.txt` (report C4 — such an edit fails C6).
- Reviving `dovetailed_bundle` or any archived completeness wiring.
- Re-deleting the `ValidOver`/`ValidLinear`/… vocabulary (already gone, report C2).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A post-deletion `lake build` failure cannot be attributed because no green baseline exists | H | H | Phase 1 is a hard prerequisite for every other phase and captures the baseline via a detached, guarded build. Do not begin Phase 4 without it |
| Deletion silently converts 3 currently-passing backticked names into `typst-sync-check.sh` violations (the report's B2 trap: `ValidLinear`/`ValidDenseFc`/`ValidDiscreteFc` pass only because retirement *prose* in the deleted files mentions them, and the checker is a text grep) | M | H | Phase 2 rewrites the typst frame-class section **before** Phase 4 deletes anything, and the Phase 2 exit criterion is `typst-sync-check.sh` reaching 0 violations at pre-deletion HEAD |
| Deleting the directory dangles `Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean:1`'s import and fails C11 | H | H | Phase 4 appends the C11 waiver in the *same* commit as the deletion (atomic-batch), matching the existing `ParametricCanonical` block's format and its "deleted outright" category |
| The 11 `#leansrc` pointers fail silently — no gate catches them, so the compiled book renders dangling citations | M | H | Phase 3 is a dedicated phase with per-pointer target verification against the live `.lean` files |
| Implementer adds a `module-invariants-manifest.txt` entry "to be safe", failing C6 | H | M | Stated as an explicit Non-Goal and as a MUST NOT in Phase 4's task list; Phase 7 asserts C6 is still 17 with an unchanged manifest |
| `soundness_dense`/`soundness_discrete` homonyms in `Metalogic/Soundness.lean` make naive greps overcount external references | L | M | Measure by *import*, not by symbol name (report §3 B2). The live non-Boneyard importer count is exactly one |
| A phase-4 partial state (files deleted, import still present) is committed and leaves the tree red | M | M | Phase 4 declares `Commit Mode: atomic-batch`; intermediate per-file states are expected red and MUST NOT be committed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 2 |
| 4 | 5, 6 | 4 |
| 5 | 7 | 3, 5, 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Capture green baselines [COMPLETED]

**Goal**: Establish the pre-change measurements the rest of the task is attributed against —
above all a green `lake build`, which the research cycle could not capture because its guarded
build queued behind another session's in-flight build.

**Tasks**:
- [x] Record the starting commit SHA (`git rev-parse HEAD`) into a baseline scratch file under
      the task directory. *(29e8d5713; written to `baselines.txt`)*
- [x] Run a **detached, guarded** whole-project build and wait for it to complete:
      `Bash(run_in_background: true)` with
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
      Per `context/project/lean4/operations/long-builds.md`, both obligations (detach AND guard)
      are mandatory; a foreground `lake build` will livelock. If the guard reports an in-flight
      build held by another session, wait and retry rather than bypassing the guard.
- [x] Confirm the build is **green**. If it is not green at HEAD, STOP and mark the phase
      `[BLOCKED]` — deleting into a red tree destroys attribution.
      *(GREEN: "Build completed successfully (2509 jobs)", exit 0. Hard gate satisfied.)*
- [x] Run and record `bash scripts/check-module-invariants.sh --no-build`, capturing the C4, C6,
      C7, and C11 lines verbatim. *(deviation: C6 FAILS at baseline — 3 unmanifested unreachable
      modules, all of them foreign untracked/uncommitted files owned by concurrent sessions
      (tasks 493/495/513), not FrameConditions. Recorded, not repaired.)*
- [x] Run and record `bash scripts/typst-sync-check.sh`, capturing `TOTAL_VIOLATIONS` and the
      identity of each violation. *(TOTAL_VIOLATIONS=2, exactly as hypothesised)*
- [x] Run and record `bash scripts/readme-lint.sh`, capturing its check-1 and check-3 results
      (the two exit-code-affecting checks). *(deviation: check 1 FAILS at baseline with 1 missing
      README at `FormalSystem/Semantics/Ultraproduct/`, inherited from committed foreign work.
      Check 3 is at 0 broken references — green — and is the check this task puts at risk.)*

**Timing**: 0.75 hours (mostly build wait; passive progress checks per `long-builds.md` are fine
while waiting).

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: The report asserts the following baselines at `b7ccf6702`, all of which are
hypotheses to confirm by running the commands above, not facts to assume: C4 = 1472 import lines
resolve; C6 = 17 unreachable live modules, all manifested; C7 = 479 live `.lean` (424
`FormalSystem` / 54 `BimodalTest`), 462 reachable / 17 unreachable; C11 = 497 archived import
lines in 156 files resolve, 6 waived; `typst-sync-check.sh` FAILs with `TOTAL_VIOLATIONS=2`
(`ValidOver`, `ValidOverInt`, both in `typst/chapters/p2-frame-classes.typ`); `lake build` green
(**never measured — this phase measures it for the first time**). Any divergence is recorded in
the baseline file and reconciled in Phase 7's comparison rather than silently absorbed.

**Files to modify**:
- `specs/510_resolve_orphaned_frameconditions_layer/baselines.txt` (new) — verbatim gate output
  and the HEAD SHA.

**Verification**:
- The baseline file exists and contains a green `lake build` result plus the four gate captures.
- No source file has been modified in this phase.

---

### Phase 2: Rewrite the typst frame-class section and clear inherited sync debt [COMPLETED]

**Goal**: Rewrite `typst/chapters/p2-frame-classes.typ`'s frame-condition prose onto the live
`FrameClass.Sat` / `ValidIn` / `TaskFrame.Is*` vocabulary, taking `typst-sync-check.sh` from its
current RED state to 0 violations **before** any deletion happens — which also pre-empts the
B2 trap in which deletion would convert three currently-passing names into new violations.

**Tasks**:
- [x] Delete or rewrite the `== Semantic Frame-Condition Typeclasses` section
      (`typst/chapters/p2-frame-classes.typ`, around `:91-99`). Its four bullets name
      `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`, and
      its closing paragraphs name `ValidOver`, `ValidLinear`, `ValidDenseFc`, `ValidDiscreteFc`,
      `ValidOverInt`, `soundness_linear`, `AxiomLinearCompatible`, `AxiomDenseCompatible`,
      `AxiomDiscreteCompatible` — every one of which either already fails check 1 or will after
      Phase 4. Replace with prose grounded on `FrameClass.Sat` (`Semantics/FrameClassValidity.lean`),
      `ValidIn` (`Semantics/Validity.lean`), and `TaskFrame.IsDense` / `TaskFrame.IsSuccArchDiscrete`
      / `TaskFrame.IsDedekind` (`Semantics/FrameProperty.lean`).
      *(rewritten as `== Interpreting the Frame-Class Tags Semantically`)*
- [x] Fix the *Monotonicity* paragraph (around `:151-153`): drop the bridge-level
      `soundness_linear` / `FrameConditions/Soundness.lean` clause; keep the
      `Metalogic/Soundness.lean` sentence, which is already correct.
      *(altered: the dropped clause is replaced by `ValidIn.mono`, the live carrier of the same
      claim, rather than left with no semantic witness at all)*
- [x] Delete the `// CONFIRM(lean): FrameConditions/Soundness.lean carries a Dedekind-class bridge
      theorem…` comment — it asks a question about a file that will not exist.
- [x] Fix the *Frame Properties* paragraph (around `:160`) that says the properties "correspond to
      the `DiscreteTemporalFrame`/`DenseTemporalFrame` typeclasses above": repoint at
      `TaskFrame.IsSuccArchDiscrete` / `TaskFrame.IsDense`.
- [x] Verify each replacement backticked identifier actually resolves — check 1 requires the name
      to occur in some live `.lean` file, so confirm with `grep -rn` before relying on it.
- [x] Run `bash scripts/typst-sync-check.sh` and confirm `TOTAL_VIOLATIONS=0` and overall PASS.
      *(PASS, all 3 checks green, 574 candidates)*
- [x] *(added, not in plan)* Two further stale names outside the plan's enumerated line ranges
      would have become violations after deletion and were repaired in the same pass: the
      `SerialFrame` bundle reference at `:109` (repointed at `TemporalOrder`) and the file's
      own `Lean name ground truth:` header comment at `:4-5`.
- [x] *(added)* `typst compile typst/BimodalReference.typ` exits 0 — the rewrite does not break
      the book build.

**Timing**: 1.0 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: The report projects that a naive deletion would take `typst-sync-check.sh`
from 2 to ~13 violations, of which 3 (`ValidLinear`, `ValidDenseFc`, `ValidDiscreteFc`) are the
trap — passing today only because retirement prose in `FormalSystem/FrameConditions.lean` and
`FrameConditions/Validity.lean` mentions them. Confirm the trap empirically: after this phase and
before Phase 4, `TOTAL_VIOLATIONS` must be 0; Phase 7 re-runs it post-deletion and it must still
be 0. If it is not, the section rewrite missed a name.

**Files to modify**:
- `typst/chapters/p2-frame-classes.typ` — `:91-99` section rewrite, `:107` bridge sentence,
  `:151-153` monotonicity clause + CONFIRM comment, `:160` frame-properties sentence.

**Verification**:
- `bash scripts/typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0`, `MISMATCH_COUNT=0`,
  `MA_COUNT_MISMATCHES=0`.
- `grep -n 'FrameConditions\|TemporalFrame\|ValidOver\|AxiomLinearCompatible' typst/chapters/p2-frame-classes.typ`
  returns nothing.

---

### Phase 3: Repoint the 11 dangling `#leansrc` book pointers [COMPLETED]

**Goal**: Repoint every `#leansrc` citation in `typst/FormalFoundations.typ` that names a
`FrameConditions` module or symbol at its live replacement. No gate catches these — `#leansrc`
takes string arguments, so `typst-sync-check.sh` check 1 (which scans backticked spans) does not
validate them and they fail silently in the compiled book.

**Tasks**:
- [x] Repoint `:420-422`: `#leansrc("FrameConditions", "DenseTemporalFrame")` →
      `#leansrc("Semantics.FrameProperty", "TaskFrame.IsDense")`;
      `"DiscreteTemporalFrame"` → `"TaskFrame.IsSuccArchDiscrete"`;
      `"DedekindTemporalFrame"` → `"TaskFrame.IsDedekind"`.
- [x] Repoint `:621-624`: `#leansrc("FrameConditions", "soundness_linear")` →
      `#leansrc("Metalogic.Soundness", "soundness")`; `"soundness_dense"` and
      `"soundness_discrete"` → the `Metalogic.Soundness` homonyms (`Metalogic/Soundness.lean:1329`
      and `:1477`); `"soundness_Int"` → `#leansrc("Metalogic.Soundness", "soundness_dedekind")`.
      *(verified at the exact predicted lines 1329 / 1477)*
- [x] Repoint `:1252` and `:1255`: `#leansrc("FrameConditions.Soundness", "soundness_linear")` and
      `…"soundness_Int"` → the corresponding `Metalogic.Soundness` targets.
      *(deviation: altered — repointed at `Metalogic.BaseLanguageSoundness` /
      `bl_soundness` and `bl_soundness_dedekind` instead of `Metalogic.Soundness`. Reason: this
      block cites an *Algebraic soundness* proposition about TM⁺-algebras, i.e. the **base
      language**, and its two sibling pointers at `:1253-1254` already name
      `Metalogic.BaseLanguageSoundness`. Pointing half the quad at the full-language module would
      have left the citation block incoherent. Both chosen symbols verified present at
      `BaseLanguageSoundness.lean:200` and `:248`.)*
- [x] For each repointed pair, verify the symbol exists in the named module by
      `grep -n '<symbol>' FormalSystem/<Module path>.lean` before accepting the edit. A repoint
      that does not resolve is the same defect, relocated.
      *(all 11 verified by line number against the live `.lean` files)*
- [x] Confirm `grep -n 'leansrc("FrameConditions' typst/FormalFoundations.typ` returns nothing.
      *(0 occurrences of the string `FrameConditions` anywhere in the file)*
- [x] *(added, not in plan)* Repaired the two adjacent pre-existing broken pointers at
      `:1253-1254`, which named `Metalogic.BaseLanguageSoundness` with the full-language symbol
      names `soundness_dense`/`soundness_discrete`; that module declares `bl_soundness_dense` /
      `bl_soundness_discrete`. Fixing them was required for the quad to be coherent after the
      `:1252`/`:1255` repoint above. 11 pointer rewrites in total.
- [x] *(added)* `typst compile typst/BimodalReference.typ` exits 0 and `typst-sync-check.sh`
      still PASSes at `TOTAL_VIOLATIONS=0` — this phase moved no counter, as predicted.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: The report enumerates 11 pointers across 9 lines
(`:420-422`, `:621-624`, `:1252`, `:1255`). Confirm the count at implementation time with
`grep -c 'FrameConditions' typst/FormalFoundations.typ` before editing and expect 0 after; if the
before-count is not 9 lines' worth, enumerate the full set rather than editing only the listed
lines.

**Measured**: the before-count was **9 lines carrying 9 pointers**, one per line — not 11
pointers. The 9 lines are exactly the ones the report enumerated, so the line-level scope was
correct and only the pointer tally was overstated. Total rewrites in this phase came to 11 anyway,
because two adjacent already-broken non-`FrameConditions` pointers at `:1253-1254` had to be
repaired for the citation quad to be coherent. After-count: 0.

**Files to modify**:
- `typst/FormalFoundations.typ` — `:420-422`, `:621-624`, `:1252`, `:1255`.

**Verification**:
- Zero `FrameConditions` occurrences remain in `typst/FormalFoundations.typ`.
- Every repointed `(module, name)` pair verified present in the live tree by grep.
- `bash scripts/typst-sync-check.sh` still passes (this phase should not move its counters).

---

### Phase 4: Delete the layer, drop the aggregator import, waive the C11 import [COMPLETED]

**Goal**: Remove all six `FrameConditions` paths, drop the single live import from
`FormalSystem/FormalSystem.lean`, and waive the resulting dangling Boneyard import — as one
atomic change, since every intermediate ordering of these edits leaves the tree or a gate red.

**Tasks**:
- [x] Delete the six paths (via `git rm`):
      `FormalSystem/FrameConditions.lean` (74),
      `FormalSystem/FrameConditions/FrameClass.lean` (292),
      `FormalSystem/FrameConditions/Validity.lean` (81),
      `FormalSystem/FrameConditions/Soundness.lean` (207),
      `FormalSystem/FrameConditions/Compatibility.lean` (199),
      `FormalSystem/FrameConditions/README.md` (98).
      The directory and its sibling aggregator MUST go together or C8 fails.
      *(all six line counts confirmed exactly; 853 `.lean` lines + 98 README = 951 total)*
- [x] Edit `FormalSystem/FormalSystem.lean`: remove the `import FormalSystem.FrameConditions` at
      `:13`; remove the `:45-48` docstring entry ("Typeclass-based frame condition architecture
      (4 modules)" and its "Sits strictly above `Metalogic`" sub-bullet referencing
      `FrameConditions/README.md`); remove the `:96` module-index link line.
      *(all three removed; zero `FrameConditions` occurrences remain in the file)*
- [x] Append to `scripts/boneyard-import-waivers.txt` a new commented block naming the deletion
      commit, following the existing `ParametricCanonical` block's shape, with the single entry
      `FormalSystem.FrameConditions.Compatibility`. The comment must state that the module was
      deleted outright and that reviving it is an explicit non-goal — this is that file's
      documented category, and its guard ("prove there is no unique target file on disk") is
      satisfied because after this deletion no such file exists.
      *(deviation: altered — the block names the deletion by *description* rather than by SHA,
      because the waiver has to be committed in the same atomic batch as the deletion and the
      batch's own SHA does not exist until after the file is written. The guard was discharged
      explicitly: no file of that name exists anywhere on disk after the deletion.)*
- [x] **MUST NOT** delete `FormalSystem/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean`.
      It is retained as the archived record of `completeness_over_Int` (`:530`) and
      `discrete_completeness_fc` (`:549`). *(retained and verified present)*
- [x] **MUST NOT** add any entry to `scripts/module-invariants-manifest.txt`. C6 counts
      unreachable modules; `FrameConditions` is reachable, so C6 is unaffected and a manifest
      entry naming a now-nonexistent module would fail C6.
      *(`git diff --stat` on that path is empty — untouched)*
- [x] Run the detached, guarded whole-project build
      (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
      `run_in_background: true`) and confirm green.
      *(deviation: NOT green, and not attributable to this change. The build produced 9 errors, all
      of them in `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — a file with zero
      `FrameConditions` references whose failing lines lay inside an UNCOMMITTED +132-line block
      added by a concurrent session (`git diff` hunk `@@ -278,0 +284,132 @@`). The first error was
      ``Unknown identifier `swapBL_involution` `` at `:357:26`; the cause was that the in-flight
      block referenced the theorem **unqualified** while it is declared inside the `BLFormula`
      namespace at `FormalSystem/BaseLanguage/Formula.lean:151` — a declaration that was present
      all along, including at this task's own Phase 4 commit. Every other module in the tree built.
      The Phase 1 baseline build was green before that block appeared. That session landed the
      qualified call in `1c75e7101`, and Phase 7's re-run against the fixed tree is green.)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C8 and C11 pass; C11's
      waived count should rise from 6 to 7. *(C8 PASS; C11 PASS at 497 archived import lines,
      156 files, **7 waived** — exactly the predicted rise. C5 PASS. C4 1477 → 1469.)*
- [x] Commit once, with the whole batch staged together.

**Timing**: 1.0 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 6 paths, 853 `.lean` lines, and exactly one live non-Boneyard importer
(`FormalSystem/FormalSystem.lean:13`). Confirm before deleting with
`grep -rn "import FormalSystem.FrameConditions" --include=*.lean .` — the expected result is the
four intra-aggregator imports, the three intra-directory imports, `FormalSystem.lean:13`, and the
single Boneyard line. Any additional live importer invalidates the atomic-batch scope and the
phase must stop and re-plan rather than widen the batch mid-flight.

**Measured**: CONFIRMED exactly. 10 import lines total — 4 intra-aggregator, 3 intra-directory,
1 self-import inside the aggregator's own docstring example, `FormalSystem/FormalSystem.lean:13`,
and the single Boneyard line. **No additional live importer.** One unplanned non-import mention
was found, a docstring cross-reference at `FormalSystem/Semantics/FrameProperty.lean:105`; it is
repaired in Phase 5 with the other stale references.

**Files to modify**:
- `FormalSystem/FrameConditions.lean` — delete
- `FormalSystem/FrameConditions/{FrameClass,Validity,Soundness,Compatibility}.lean` — delete
- `FormalSystem/FrameConditions/README.md` — delete
- `FormalSystem/FormalSystem.lean` — `:13`, `:45-48`, `:96`
- `scripts/boneyard-import-waivers.txt` — append one commented waiver block

**Verification**:
- `lake build` green via the guarded detached invocation.
- `check-module-invariants.sh --no-build`: C8 passes; C11 passes with 7 waived; C6 still reports
  17 unreachable modules with an unmodified manifest.
- `git status` shows the Boneyard `Completeness.lean` untouched.

---

### Phase 5: Repair documentation references and broken relative links [COMPLETED]

**Goal**: Remove every stale `FrameConditions` reference from README and docs trees and restore
`readme-lint.sh` check 3 to green.

**Tasks**:
- [x] `FormalSystem/README.md`: remove the four inventory rows at `:228` (file table),
      `:247` (module table), `:280` (subdirectory table — this row also carries a relative link
      to `FrameConditions/README.md`), and `:329` (completeness status table).
      *(all four removed)*
- [x] `FormalSystem/Metalogic/README.md`: delete the whole `## Position of FrameConditions/`
      section (`:288-295`), which includes the broken `../FrameConditions/README.md` link at
      `:295` and a dead `Bimodal.` namespace prefix at `:292` (the project namespace is
      `FormalSystem.`). *(section deleted entire)*
- [x] `FormalSystem/Metalogic/SoundnessLemmas/README.md`: fix `:27` — the "Imports from …
      `Bimodal.FrameConditions`" claim is **false** (no file under `SoundnessLemmas/` imports it,
      verified against all five files' import lines) and the `Bimodal.` prefix is dead; and
      remove the broken `../../FrameConditions/README.md` link at `:33`.
      *(re-verified independently: the six import lines across the five files name only
      `SoundnessLemmas.Core`, `SoundnessLemmas.DenseValidity`, `Semantics.Truth`,
      `Semantics.Validity`, `ProofSystem.Derivation`, `ProofSystem.Axioms` and Mathlib
      order/Archimedean modules. The Dependencies block was rewritten to that actual list under
      the live `FormalSystem.` prefix, rather than merely deleting the false clause.)*
- [x] `README.md:113`: remove the `FrameConditions/` tree-diagram row.
- [x] `docs/development/MODULE_ORGANIZATION.md`: remove the `:20` aggregator row and the `:29`
      directory row.
- [x] `docs/user-guide/architecture.md:1105`: remove the tree row. *(actual line `:1113`)*
- [x] `typst/SYNC-MAP.md`: fix `:195` (frame-condition semantics location) and `:358-359`
      (claim-verification entry 1, which is about a file that will no longer exist).
      *(`:195` repointed at `FrameClass.Sat` / `TaskFrame.Is*` / `ValidIn`; the claim-verification
      entry rewritten to preserve the historical finding — that the `FrameClass` inductive was
      never in the deleted directory — while stating the layer is now gone.)*
- [x] `typst/chapters/00-introduction.typ:158`: remove the `FrameConditions/` directory-listing
      bullet.
- [x] `typst/chapters/04-metalogic.typ:41`: rewrite the clause claiming frame-condition semantics
      "is developed in the top-level `FrameConditions/` directory" to point at
      `Semantics/FrameProperty.lean` and `Semantics/FrameClassValidity.lean`.
- [x] *(added, not in plan)* `FormalSystem/Semantics/FrameProperty.lean:105`: the docstring
      recording the widening defect said "the same defect the `FrameConditions/` marker-typeclass
      layer **carries**", present tense, pointing at a directory this task deletes. Rewritten to
      past tense with the directory name dropped. This is the only `.lean` file outside the
      deleted directory that mentioned the layer, and it is a docstring-only change.
- [x] Run `bash scripts/readme-lint.sh` and confirm checks 1 and 3 (the exit-code-affecting ones)
      pass. *(deviation: check 3 **restored to 0 broken references** — the phase's stated goal —
      but check 1 still fails on a **missing `FormalSystem/Semantics/Ultraproduct/README.md`**.
      That directory was created by committed foreign work (`0f1e50fd4`, `9eb879519`,
      `dbad125e6`) and shipped without a README; the failure is present in the Phase 1 baseline,
      has no FrameConditions involvement, and is another task's territory, so it is recorded
      rather than absorbed. See the summary's Reasoned Exclusions.)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C5 (module-shaped
      markdown paths) passes. *(C5 PASS; C12 and C13 also PASS)*
- [x] Run `bash scripts/typst-sync-check.sh` and confirm it is still at 0 violations.
      *(PASS, `TOTAL_VIOLATIONS=0`; `typst compile` of the book also still exits 0)*

**Timing**: 1.0 hours

**Depends on**: 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: The report identifies **two** broken relative links for `readme-lint.sh`
check 3 (`Metalogic/README.md:295`, `SoundnessLemmas/README.md:33`). A pre-implementation grep
found a likely **third** at `FormalSystem/README.md:280`
(`[FrameConditions/](FrameConditions/README.md)`). Confirm the actual count by running
`bash scripts/readme-lint.sh` immediately after Phase 4 and reading check 3's output, then repair
exactly the set it names — do not assume either 2 or 3.

**Measured**: **3**, and the plan's suspicion was correct. Immediately after Phase 4, check 3
named exactly `FormalSystem/Metalogic/README.md -> ../FrameConditions/README.md`,
`FormalSystem/Metalogic/SoundnessLemmas/README.md -> ../../FrameConditions/README.md`, and
`FormalSystem/README.md -> FrameConditions/README.md`. All three repaired; check 3 is back to 0.

**Files to modify**:
- `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/SoundnessLemmas/README.md`, `README.md`,
  `docs/development/MODULE_ORGANIZATION.md`, `docs/user-guide/architecture.md`,
  `typst/SYNC-MAP.md`, `typst/chapters/00-introduction.typ`, `typst/chapters/04-metalogic.typ`

**Verification**:
- `readme-lint.sh` exits 0.
- `check-module-invariants.sh --no-build` C5 passes.
- Tree-wide `grep -rn "FrameConditions" --include=*.md --include=*.typ .` (excluding `specs/`,
  `.git/`, and `FormalSystem/Boneyard/`) returns only `scripts/boneyard-import-waivers.txt`'s
  waiver-block comment.

---

### Phase 6: Record the corrected archived-completeness finding [COMPLETED]

**Goal**: Satisfy acceptance criterion A6 by recording the *corrected* form of the silent
regression (report C5) in a durable location, replacing the brief's inaccurate "all three
identifiers are ABSENT" framing.

**Tasks**:
- [x] Add a short note to `FormalSystem/Boneyard/StrictSemanticsLegacy/README.md`, beside its
      existing `FrameConditions/Completeness.lean` entry, stating: the completeness wiring was
      **archived, not removed**; `completeness_over_Int` and `discrete_completeness_fc` survive in
      that archived file and are unreachable from every Lake target root, so no build compiles
      them and any live "wiring is DONE" claim is false of the live tree; `dovetailed_bundle` is
      absent tree-wide. Also note that the file's `FormalSystem.FrameConditions.Compatibility`
      import is permanently waived in `scripts/boneyard-import-waivers.txt` because the target was
      deleted.
      *(deviation: altered — the `dovetailed_bundle` clause was sharpened after independent
      re-measurement. No declaration of that **exact** name exists anywhere, which is what the
      report meant; but the archived file does declare `dovetailed_bundle_to_bfmcs` (`:433`) and
      `dovetailed_bundle_validity_implies_provability` (`:474`), so a flat "absent tree-wide"
      would have been falsified by the first grep a reader ran. The note states the bare name is
      gone and the prefix is not.)*
- [x] Write the same corrected finding into the task's implementation summary under
      `specs/510_resolve_orphaned_frameconditions_layer/summaries/`.
- [x] **MUST NOT** cite task numbers in `FormalSystem/Boneyard/StrictSemanticsLegacy/README.md`
      or any other non-`specs/` file (see `.claude/rules/no-task-references-in-deliverables.md`);
      cite the file path and the identifiers instead.
      *(`check-task-references.sh` PASSes: 0 unexempted occurrences across 4 trees)*

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Boneyard/StrictSemanticsLegacy/README.md`
- `specs/510_resolve_orphaned_frameconditions_layer/summaries/01_delete-frameconditions-layer-summary.md`

**Verification**:
- The Boneyard README states the archived-not-deleted correction and names all three identifiers
  with their correct status.
- `bash .claude/scripts/check-task-references.sh` (or equivalent repo lint) reports no
  task-number reference introduced outside `specs/`.
- `readme-lint.sh` still exits 0.

---

### Phase 7: Full gate sweep and acceptance verification [COMPLETED WITH EXCLUSIONS]

**Goal**: Run the complete gate set against the finished tree, compare every result against the
Phase 1 baseline, and confirm each restated acceptance criterion.

**Tasks**:
- [x] Run the detached, guarded whole-project build and confirm green
      (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
      `run_in_background: true`).
      *(**GREEN**: exit 0, "Build completed successfully (2505 jobs)", zero error lines. The
      concurrent session whose uncommitted work reddened the Phase 4 build had landed a compiling
      state by this point.)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and confirm ALL CHECKS PASSED.
      Assert specifically: **C6 still reports 17 unreachable live modules with
      `scripts/module-invariants-manifest.txt` unmodified** (`git diff --stat` on that path must
      be empty); C11 passes with the waived count at 7; C5 and C8 pass.
      *(deviation: ALL CHECKS did **not** pass. The three assertions this task is responsible for
      all hold — **C11 PASS at 7 waived**, **C5 PASS**, **C8 PASS**, the manifested-unreachable
      count is still **17**, and `git diff --stat 032a4f1da..HEAD -- scripts/module-invariants-manifest.txt`
      is **empty**. The C6 *check* nonetheless fails, on 4 unreachable modules that are all files
      created by other in-flight tasks: `Metalogic.SpWitness`, `Metalogic.TMCompletenessReduction`,
      `Metalogic.Z1Countermodel`, `Semantics.LexCarrier`. The failure predates this task (3 such
      modules at the Phase 1 baseline) and its membership churned between every run, which is the
      signature of concurrent sessions rather than a stable defect. Recorded, not absorbed.)*
- [x] Record the C7 informational shift against the Phase 1 baseline. The report predicts live
      `.lean` 479 → 474, `FormalSystem` 424 → 419, `(loose)` 10 → 9, and the `FrameConditions`
      row removed. C7 is never asserted as a gate — record the actual numbers and note any
      divergence rather than treating the prediction as a pass criterion.
      *(actual: 482 → 479 live, 427 → 424 `FormalSystem`, `(loose)` 10 → 9, `FrameConditions` row
      removed. Only `(loose)` matched the prediction exactly; the others diverge because the
      report's *baseline* was 3 files stale, not because its arithmetic was wrong. This task's own
      contribution is exactly -5 `.lean` files. Full table in the summary.)*
- [x] Run `bash scripts/typst-sync-check.sh` and confirm PASS with `TOTAL_VIOLATIONS=0` — an
      improvement over the RED baseline, not merely a no-regression.
      *(**PASS**, all 3 checks green: `TOTAL_VIOLATIONS=0`, `MISMATCH_COUNT=0`,
      `MA_COUNT_MISMATCHES=0`. Repaired from `TOTAL_VIOLATIONS=2`.)*
- [x] Run `bash scripts/readme-lint.sh` and confirm exit 0.
      *(deviation: exit 1. **Check 3 — the check this task put at risk — is at 0 broken
      references**, all three breaks repaired. Check 1 still fails on the single inherited missing
      `FormalSystem/Semantics/Ultraproduct/README.md`, present at the Phase 1 baseline and owned by
      another task. Recorded, not absorbed.)*
- [x] Confirm the deleted paths are absent and the Boneyard file is present:
      `test ! -e FormalSystem/FrameConditions.lean && test ! -d FormalSystem/FrameConditions && test -f FormalSystem/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean`.
      *(PASS)*
- [x] Write the baseline-vs-final comparison table into the implementation summary.
- [x] *(added)* Sorry/axiom/vacuous-definition census: 0 sorries and 0 vacuous definitions in the
      files this task modified; live non-Boneyard `axiom` count unchanged at 6.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `check-module-invariants.sh` C6 left failing on 4 unmanifested unreachable modules | All four are `.lean` files created by other in-flight tasks. Manifesting another task's module would claim its work and pre-empt its own accounting. The plan additionally forbids any edit to this manifest as a Non-Goal | Baseline set was `TMCompletenessReduction`, `BLSchemaValidity`, `LexCarrier`; final set is `SpWitness`, `TMCompletenessReduction`, `Z1Countermodel`, `LexCarrier` — the membership churned across all three runs. `git diff 032a4f1da..HEAD -- scripts/module-invariants-manifest.txt` is empty and the manifested-unreachable count is 17 at both ends |
| `readme-lint.sh` check 1 left failing on a missing `FormalSystem/Semantics/Ultraproduct/README.md` | The directory was created by *committed* foreign work that shipped without a README; it is not a `FrameConditions` consequence, and it is under active concurrent edit. Writing that README would author another task's deliverable | `git log -- FormalSystem/Semantics/Ultraproduct/` → `0f1e50fd4`, `9eb879519`, `dbad125e6`. The failure is recorded verbatim in `baselines.txt` before this task modified anything. Check 3, the check the deletion actually endangered, is repaired to 0 |

**Timing**: 0.75 hours

**Depends on**: 3, 5, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The C7 deltas above (479→474, 424→419, 10→9) are report predictions, not
facts. Confirm by direct comparison of the Phase 1 and Phase 7 C7 lines; a divergence is a
finding to record in the summary, not a gate failure, because C7 is informational.

**Measured**: 482 → 479 live `.lean`, 427 → 424 `FormalSystem`, 54 → 54 Tests, `(loose)` 10 → 9,
`FrameConditions` row (4) removed. Only the `(loose)` prediction landed. The divergence is a stale
report *baseline*, not bad arithmetic: the tree already held 482/427 at Phase 1. Recorded in the
summary as a finding.

**Files to modify**:
- `specs/510_resolve_orphaned_frameconditions_layer/summaries/01_delete-frameconditions-layer-summary.md`

**Verification**:
- All four gates green simultaneously at the final commit.
- The comparison table in the summary shows every baseline-to-final transition with an
  explanation for each change.

---

## Testing & Validation

- [x] **A1** — No orphaned validity vocabulary remains. Largely pre-satisfied by `e5a9ba40f`
      (report C2); this task finishes it by deleting the two remaining `FrameOver D` fibration
      bridges along with their file. Verify: zero `ValidOver`/`ValidLinear`/`ValidDenseFc`/
      `ValidDiscreteFc`/`ValidOverInt` occurrences tree-wide outside `specs/` and `Boneyard/`.
- [x] **A2** — `lake build` green, measured via a detached guarded build both at Phase 1
      (baseline) and Phase 7 (final).
- [~] **A3 (restated per report C4)** — `check-module-invariants.sh` green with
      **C6 still passing at 17 unreachable modules and no manifest edit**. The brief's original
      "C6 unreachable-module count updated and manifested" criterion **does not apply and would
      fail if attempted**; `FrameConditions` is reachable, so deleting it cannot change the
      unreachable count. C7's informational inventory is the thing that shifts, and it is never
      asserted. Live risks are C11 (Phase 4 waiver), C5, and C8.
- [x] **A4 (restated per report B2)** — `typst-sync-check.sh` PASS with `TOTAL_VIOLATIONS=0`.
      This is a *repair*, not a hold: the gate is already RED at HEAD with 2 violations inherited
      from the `e5a9ba40f` trim, and a naive deletion would take it to ~13.
- [~] **A5** — `readme-lint.sh` exits 0 with every broken relative link repaired.
- [x] **A6 (restated per report C5)** — The silent regression is recorded in its corrected form:
      archived, not deleted; `completeness_over_Int` and `discrete_completeness_fc` survive in the
      Boneyard; only `dovetailed_bundle` is gone outright.
- [x] **A7** — No `#leansrc` pointer in `typst/FormalFoundations.typ` names a `FrameConditions`
      module or symbol, and every repointed target verified present in the live tree.

**Acceptance verdicts** (`[x]` met, `[~]` met in substance with a recorded exclusion): A1, A2,
A4, A6, A7 PASS. **A3 PARTIAL** — the 17-unreachable count and the untouched manifest both hold
and C5/C8/C11 pass, but the C6 *check* fails on 4 foreign modules. **A5 PARTIAL** — all three
broken relative links repaired and check 3 back to 0, but check 1 still fails on an inherited
missing README. Both exclusions are evidenced in Phase 7's `#### Reasoned Exclusions` table.

## Artifacts & Outputs

- `specs/510_resolve_orphaned_frameconditions_layer/plans/01_delete-frameconditions-layer.md` (this file)
- `specs/510_resolve_orphaned_frameconditions_layer/baselines.txt` (Phase 1)
- `specs/510_resolve_orphaned_frameconditions_layer/summaries/01_delete-frameconditions-layer-summary.md` (Phases 6-7)
- Deleted: 6 paths under `FormalSystem/FrameConditions*` (853 `.lean` lines + 98-line README)
- Modified: `FormalSystem/FormalSystem.lean`, `scripts/boneyard-import-waivers.txt`, 4 README
  files, 2 `docs/` files, 4 `typst/` files, `FormalSystem/Boneyard/StrictSemanticsLegacy/README.md`

## Rollback/Contingency

- The work is a pure deletion plus reference repair, and every phase commits separately except
  Phase 4's declared atomic batch. Reverting is `git revert` of the phase commits in reverse
  order; nothing here has runtime state or migration.
- Take `bash .claude/scripts/git-snapshot.sh 510` before any intentional rollback that would
  discard uncommitted work — the destructive-git hook blocks `git reset --hard` on a dirty tree
  otherwise.
- If Phase 1's build baseline is **not** green, mark Phase 1 `[BLOCKED]` and stop. Do not proceed
  into deletion: a red baseline makes every subsequent failure unattributable, which is precisely
  the gap the research cycle left open.
- If Phase 4's build fails after deletion, the diagnostic order is: (1) confirm no live importer
  was missed (`grep -rn "import FormalSystem.FrameConditions" --include=*.lean .`), (2) confirm
  `FormalSystem/FormalSystem.lean` has no residual reference, (3) confirm the failure is not
  pre-existing by diffing against the Phase 1 baseline output.
- If a consumer of the deleted layer is discovered mid-execution (contradicting the measured
  one-importer finding), stop, restore the batch, and re-plan — the deletion verdict itself would
  need re-examination, and widening the atomic batch mid-flight is explicitly disallowed.
