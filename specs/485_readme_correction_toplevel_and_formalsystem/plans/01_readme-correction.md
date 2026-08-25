# Implementation Plan: README Correction — Top-Level and `FormalSystem/**`

- **Task**: 485 - README CORRECTION: rewrite the top-level `README.md` and repair the `FormalSystem/**/README.md` layer
- **Status**: [IMPLEMENTING]
- **Effort**: 13.5 hours
- **Dependencies**: 484 (complete — its corrected `specs/ROADMAP.md` and `FormalSystem/Metalogic/README.md` are the ground-truth anchors this task realigns against)
- **Research Inputs**: specs/485_readme_correction_toplevel_and_formalsystem/reports/01_readme-correction-verification.md
- **Artifacts**: plans/01_readme-correction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two documentation layers fail in opposite directions and both must be repaired against Lean
source. The top-level `README.md` **under-claims** — it advertises sorry obligations in a tree
whose structural sorry inventory is zero, and marks two proven frame classes as pending or
absent. The `FormalSystem/**/README.md` layer **over-claims** — it calls decidability "fully
proven", marks a nonexistent file's completeness theorem "Sorry-free", and advertises seven
declarations and ten files that exist nowhere. Research confirmed all 26 asserted defects, found
nine of them materially larger than the task description states, corrected one attribution the
task description has backwards, and surfaced six unlisted defects sitting in the same lines.

The accurate replacement prose already exists in-tree. This is a **transcription** job: every
figure comes from `.lean` source, `#print axioms`, or a filesystem walk — never from another
markdown document. The work is prose and markdown only; no `.lean` declaration, signature,
import, or tactic changes, and the single `.lean` file in scope (`FormalSystem/Theorems.lean`)
may change only in its module docstring.

Definition of done: `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED, and
`bash scripts/readme-lint.sh`'s broken-reference count drops from 5 to 0 with its missing-README
count unchanged at 9.

### Research Integration

`reports/01_readme-correction-verification.md` is the sole source of replacement values. Findings
that reshape the task description's own account, and which every phase below is written against:

- **B4 is attributed to the wrong file.** `Axiom.minFrameClass` (`Axioms.lean:589-594`) gives
  **2 Dense** (`density`, `dense_indicator`) and **3 Discrete** (`prior_UZ`, `prior_SZ`, `z1`).
  That makes `FormalSystem/README.md:97` **already correct** and `ProofSystem/README.md:37` the
  wrong one. An implementer following the task description literally would "fix" the correct site
  (report §3.4). Phase 3 must leave `:97` alone.
- **A7 is already applied in the working tree, uncommitted.** `README.md:19-21` already reads
  539 / ~170,898 / ~96,290, matching `cloc` run exactly as the README prints it at `:23-26`. Only
  a formatting slip remains (`| Comment lines | ~96,290|` — missing space before the closing
  pipe). Carry the edit forward; do not revert it; record its non-task provenance (report §2.7).
- **B11 is one-third already fixed.** `BXCanonical/README.md:13` was repaired by the anchor task
  and is the **house pattern to copy verbatim** for the two remaining sites
  (`Algebraic/README.md:26`, `Core/README.md:21`) (report §3.11).
- **A3 carries a binder caveat the task omits.** `soundness_dedekind` and `completeness_dedekind`
  are both stated against `ValidDedekindDense`, not `ValidDedekind`, because `density` and
  `dense_indicator` are admissible in a Dedekind derivation and both are false on `Z`
  (`Axioms.lean:499-502`). One clause preserves this; dropping it makes the README claim a result
  at the density-free binder set (report §2.3).
- **Four phantom `truth_lemma` / declaration sites, not three.** `weak_completeness`,
  `truth_lemma`, `transfer_theorem`, `normal_form_reduction` all have **zero** live occurrences,
  and `truth_lemma` is advertised in *two* READMEs (report §3.3, §3.7).
- **B13 is nine stale line counts, not three**, and its first row names a file that does not
  exist (report §3.13). `readme-lint.sh` Check 2's output is a free mechanical checklist for the
  B3/B13 inventory work and should be re-run after each edit.
- **Six unlisted defects** sit inside the declared scope and would survive a pass that fixes only
  the enumerated items: a `lake build Bimodal` command with no such Lake target, a `../../`
  parent link that resolves above the repository root, ~11 stale `Bimodal.*` module references
  invisible to C5, a Submodule Navigation table missing two directories, a BX Temporal layer
  written as 22 when the source structure is 18 + 4, and a dangling "21 axiom schemata"
  cross-reference (report §4).

### Prior Plan Reference

No prior plan for this task. Task 484's plan
(`specs/484_documentation_anchor_roadmap_and_metalogic_readme/plans/01_anchor-doc-correction.md`)
is the nearest calibration point and is used here for effort sizing only: it spent 6.5 hours on
two documents with a comparable per-document defect density. This task's 17 files at roughly the
same density motivate the 13.5-hour estimate and the finer phase split. Its validated practices
are carried forward: a per-phase source-side verification command, disjoint file territories so
phases commit independently, and pre-declared gated deviations recorded in the summary rather
than taken silently.

### Roadmap Alignment

No `roadmap_flag` was passed, so no roadmap-review/roadmap-update wrapper phases are added and
`specs/ROADMAP.md` is **not** edited by this task. Read-only consultation confirms this work sits
under **Phase 5: Publication and Documentation** (`specs/ROADMAP.md:247-251`), which gates the
README/docs/module-docstring final polish on the documentation-correction pass this task is part
of. `specs/ROADMAP.md` is additionally a *ground-truth anchor* here, not a target: it and
`FormalSystem/Metalogic/README.md` were corrected by task 484 and everything below realigns
against them.

### Decisions taken

**D1 (resolves report §6.1) — list `BaseLanguage/` without a link.** Adding a row shaped like its
eight siblings, `| [BaseLanguage/](BaseLanguage/README.md) | ... |`, creates a *new* broken
reference: `FormalSystem/BaseLanguage/README.md` does not exist (it is one of Check 1's nine
missing READMEs, explicitly out of scope), and Check 3 scans every markdown link under
`FormalSystem/`. That would take the broken-reference count from the target 0 back to 1 and fail
the very gate B14 exists to satisfy. Adopting research option (a): list `BaseLanguage/` as a
plain unlinked row with the README column reading "No" — the table already carries that column,
so an honest "No" is the table's own idiom. Zero gate risk, and the layer is no longer silently
incomplete. `Boneyard/` is unaffected (`FormalSystem/Boneyard/README.md` exists) and is linked
normally, labelled as the archive.

**D2 (resolves report §6.2) — rename `Bimodal.*` to `FormalSystem.*` only inside this task's file
scope.** All 17 distinct names were test-resolved under the rewrite and every one resolves, so
the rename is safe today. The structural consequence is deliberate: these strings are currently
invisible to C5 (whose regex is anchored on `FormalSystem|BimodalTest`), and renaming makes them
permanently visible, so a future module relocation breaks C5 here where it would previously have
passed silently. That is the improvement C5 exists to deliver, and it is taken as a choice rather
than a side effect. Adopting research option (a): rewrite the ~11 in-scope lines
(`WeakCanonical/README.md:67-68`, `BXCanonical/README.md:50-51`, `Algebraic/README.md:173`,
`FrameConditions/README.md:37,39,40,41,42,55`); hand the ~30 out-of-scope occurrences to a
downstream sweep, recorded in the summary. The `FormalSystem/Bimodal.lean` **filename** at
`FrameConditions/README.md:42` is fixed regardless — it is a file path, not a module name, and
the file does not exist.

**D3 (resolves report §6.3) — do not edit the anchor; cite the fact without the numeral.**
`FormalSystem/Metalogic/README.md:44-45` gives "2 import lines" for both
`BXCanonical -> WeakCanonical` and `BXCanonical -> Algebraic`; re-derivation shows 9 and 4
respectively. The anchor's *substantive* claim — that `BXCanonical` imports from both, so all
three routes participate in the live proof — is correct and strengthened by the true counts; only
the numerals are stale. `Metalogic/README.md` is outside this task's file scope and is the
document everything else realigns against, so it is not edited here. When Phase 5 rewrites
`Algebraic/README.md`'s scope statements it cites the fact ("`BXCanonical` imports
`Algebraic.FlowFrame`") **without transcribing any import count**. The two stale numerals are
handed to a follow-up, recorded in the summary with the re-derived values (9 and 4) as its input.

**D4 (resolves report §7) — `file_scope` must be extended from 13 to 17 files.** B14's gate
("broken-reference count must drop from 5 to 0") is unsatisfiable without
`WeakCanonical/EFGames/README.md`, `WeakCanonical/Expressiveness/README.md`,
`WeakCanonical/Separation/README.md`, and `Theorems/Perpetuity/README.md`, none of which the
dispatch declares. Phase 9 owns all four; see its Tasks for the extension step.

**D5 (resolves report §3.14) — repoint the archived references rather than deleting them.**
Three of B14's five targets are now under `Boneyard/Kamp/KampWeakCanonical/`. Deleting the
bullets would also take the count to 0, but the anchor `Metalogic/README.md:38` already links to
`FormalSystem/Boneyard/README.md` from live documentation, so linking into the archive is
established house practice. Repoint each and label it as archived.

## Shared ground truth

Every phase transcribes from this table. It is reproduced here — rather than left in the research
report alone — because Phases 3 and 4 edit *different files* that must converge on the *same*
figures, and the observed failure mode in this layer is exactly two documents disagreeing. No
phase may re-derive these from another markdown document; each phase's Scope Hypothesis names the
source-side command that re-confirms its own subset at implementation time.

**Axiom partition** — `Axiom.minFrameClass`, `FormalSystem/ProofSystem/Axioms.lean:588-597`:

| Class | Own axioms | Cumulative (`Dense <= Dedekind`) |
|-------|-----------:|---------------------------------:|
| Base | 37 | 37 |
| Dense | 2 (`density`, `dense_indicator`) | 39 |
| Discrete | 3 (`prior_UZ`, `prior_SZ`, `z1`) | 40 |
| Dedekind | 3 (`prior_U_gap`, `prior_S_gap`, `sep`) | **42** (37 + 2 + 3) |
| **Total** | | **45 constructors in nine layers** |

BX Temporal is **18** plus a separate "Additional BX Temporal" layer of **4** — never a single
layer of 22.

**Frame classes.** `inductive FrameClass` (`Axioms.lean:519-524`) is `Base | Dense | Discrete |
Dedekind` — **four**, and there is no `Continuous`. `FrameClass.Dedekind` is the paper's TM+_dc
(`Axioms.lean:479-481`); the paper's TM+_c has **no** frame class in this tree
(`Axioms.lean:503-513`), which is a genuine gap that any rename must state explicitly or it hides
it.

**Flagship theorems** — all sorry-free at `[propext, Classical.choice, Quot.sound]`:

| Theorem | Site |
|---------|------|
| `completeness` (Base) | `Metalogic/BXCanonical/Completeness.lean:196` |
| `completeness_dense` | `Metalogic/BXCanonical/Completeness.lean` |
| `completeness_discrete` | `Metalogic/BXCanonical/Completeness.lean:296` |
| `soundness_dedekind` | `Metalogic/Soundness.lean:1927` (against `ValidDedekindDense`) |
| `completeness_dedekind` | `Metalogic/StrongCompleteness.lean:469` (against `ValidDedekindDense`) |
| `isValid_sound` | `Metalogic/Decidability/Correctness.lean:111` |
| `sound_of_isValid` | `Metalogic/Decidability/Correctness.lean:100` |
| `strongCompletenessDiscrete_refuted` | `Metalogic/DiscreteNonCompactness.lean:280` |
| `countermodel_discrete` | `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean:142` |
| `truth_transfer` | `Metalogic/WeakCanonical/Transfer.lean:359` |

**Open / refuted:**

| Statement | Status | Site |
|-----------|--------|------|
| `valid_iff_allClosed`, `isValid phi fc = true <-> models phi`, the four `Decidable` instances | **open** (zero occurrences) | `Correctness.lean:209-224` |
| `CompactBase`, `StrongCompletenessBase` | **open** | `SetConsequence.lean:219`, `:211` |
| `CompactDense`, `StrongCompletenessDense` | **open** | `SetConsequence.lean:263`, `:256` |
| `StrongCompletenessDiscrete` | **refuted** | `DiscreteNonCompactness.lean:280` |
| Strong completeness, Dedekind | **not stated** | `Metalogic.lean:98-101` |

**House phrasing** — verbatim from `FormalSystem/Metalogic.lean:48`, never "axiom-free":

> `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice, Quot.sound)`

**Phantom declarations** (zero live occurrences): `weak_completeness`, `truth_lemma`,
`transfer_theorem`, `normal_form_reduction`, `Formula.subst`, `perpetuity_5`, `perpetuity_6`.

**Phantom files/dirs** advertised in documentation: `FormalSystem/Bimodal/`,
`FormalSystem/Bimodal.lean`, `Metalogic/Algebraic/AlgebraicCompleteness.lean`,
`Metalogic/Algebraic/DovetailedChain.lean`, `ProofSystem/Substitution.lean`,
`Theorems/Perpetuity/Bridge.lean`, `Theorems/Propositional.lean` (is a directory),
`Metalogic/WeakCanonical/ExpressiveCompleteness/`, `.../Separation/DedekindZ/`,
`.../Separation/Hierarchy/`.

## Goals & Non-Goals

**Goals**:
- Delete every claim of a live sorry obligation from `README.md` and the `FormalSystem/**` layer;
  the structural sorry inventory is zero and C3 says so unconditionally.
- Remove every over-claim, chiefly "decidability is fully proven" and a "Sorry-free" completeness
  theorem in a file that does not exist.
- Replace all seven phantom declarations and ten phantom file references with the real termini.
- Converge the whole layer on 45 constructors in nine layers, four frame classes, and the
  per-class cumulative counts in the Shared ground truth table.
- Add the missing Dedekind and Decidability coverage that both layers omit entirely.
- Take `readme-lint.sh`'s broken-reference count from 5 to 0.
- Regenerate every inventory table and line count from the filesystem so the layer is
  copy-pasteable.

**Non-Goals**:
- Creating any of the nine missing READMEs Check 1 reports — explicitly out of scope, and D1 is
  shaped to avoid needing one.
- Editing `specs/ROADMAP.md`, `FormalSystem/Metalogic/README.md`, or any other DO-NOT-TOUCH
  source listed in report §5.
- Changing any `.lean` declaration, signature, import, or tactic. `FormalSystem/Theorems.lean` is
  the only `.lean` file in scope and only its module docstring may change.
- The repo-wide `Bimodal.* -> FormalSystem.*` rename beyond this task's file scope (D2), the two
  stale import numerals in the anchor (D3), or `docs/reference/axiom-reference.md`'s 42-to-45
  sweep — all handed to downstream passes.
- Re-deriving any figure from another markdown document.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer "fixes" `FormalSystem/README.md:97`, which is already correct, per the task description's ambiguous pairing | H | H | Phase 3 names `:97` as DO-NOT-TOUCH in its Tasks and its Verification asserts the line is unchanged in the diff. `ProofSystem/README.md:37` is the only site edited, in Phase 4. |
| Adding a `BaseLanguage/README.md` link regresses Check 3 from 0 back to 1, failing the gate | H | M | D1 pre-commits to an unlinked row with README column "No". Phase 3's Verification re-runs `readme-lint.sh` and compares the broken-reference count. |
| A figure is copied from another markdown document, propagating a stale value into the corrected layer | H | M | Every phase's Scope Hypothesis names a source-side command (`grep` against `.lean`, `wc -l`, `find`, or `lean_verify`). The Shared ground truth table is the only cross-phase transcription source and cites `.lean` sites for every row. |
| Phases 3 and 4 diverge on the shared counts, recreating the exact B4/B5/B6 contradiction being fixed | H | M | Both transcribe the Shared ground truth table above; Phase 10 cross-greps the two files for `\b42\b`, `three variants`, and the Dense/Discrete split. |
| A repointed archive link in Phase 9 is written relative to the wrong directory and stays broken | H | M | Each B14 target's full relative path is pre-computed in Phase 9's Tasks; the phase re-runs `readme-lint.sh` and requires the count to reach exactly 0. |
| The `Bimodal.* -> FormalSystem.*` rename makes a previously invisible name visible to C5 and it does not resolve | H | L | All 17 names were test-resolved under C5's own resolution rule and every one resolves. Phases 5-7 carry `full` tier and run `check-module-invariants.sh`. |
| A task-number citation leaks into a `FormalSystem/**` README, failing C9 | H | L | C9 currently passes. No phase writes a task number into any file outside `specs/`; Phase 10 confirms C9. |
| The uncommitted A7 metrics edit is reverted as "not mine" | M | M | D-list and Phase 2 both direct the implementer to carry it forward and fix only the missing space; the summary records its non-task provenance. |
| `FormalSystem/Theorems.lean`'s docstring edit strays into a declaration | H | L | Phase 8 carries `full` tier; Phase 10 requires `git diff` on that file to show hunks only inside the `/-! -/` module docstring, and no other `.lean` path in `git diff --name-only`. |
| Two phases collide on a shared file | M | L | Territories are disjoint by construction — see the Dependency Analysis note. Only `README.md` is touched by two phases (1 and 2), and they are sequenced. |
| `file_scope` still lists 13 files and blocks or warns on Phase 9's four additions | M | M | D4; Phase 9's first task extends it before editing. |

## Implementation Phases

**Verification tier rationale.** Every editing phase below carries `full`. This is not a refusal
to tier: for a markdown-and-docstring-only change the repository's complete gate set is
`bash scripts/check-module-invariants.sh` plus `bash scripts/readme-lint.sh` — two
seconds-cheap scripts, not a `lake build` — and *every* phase here changes cross-references,
module-shaped names, or inventory tables, which the `prose` tier's blind-spot column explicitly
does not cover. Applying `prose` would defer to the final gate precisely the failure class this
task exists to eliminate. Per the tie-break rule, the strictest applicable tier is taken.

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 4, 5, 6, 7, 8, 9 | -- |
| 2 | 2 | 1 |
| 3 | 10 | 1, 2, 3, 4, 5, 6, 7, 8, 9 |

Phases within the same wave can execute in parallel. Wave 1 is wide because every phase owns a
disjoint file territory:

| Phase | Territory |
|------:|-----------|
| 1, 2 | `README.md` (sequenced: same file) |
| 3 | `FormalSystem/README.md` |
| 4 | `FormalSystem/ProofSystem/README.md` |
| 5 | `FormalSystem/Metalogic/Algebraic/README.md`, `FormalSystem/Metalogic/BXCanonical/README.md` |
| 6 | `FormalSystem/Metalogic/WeakCanonical/README.md` |
| 7 | `FormalSystem/Metalogic/{Bundle,Decidability,Core}/README.md`, `FormalSystem/FrameConditions/README.md` |
| 8 | `FormalSystem/Semantics/README.md`, `FormalSystem/Theorems/README.md`, `FormalSystem/Theorems.lean` |
| 9 | `FormalSystem/Metalogic/WeakCanonical/{EFGames,Expressiveness,Separation}/README.md`, `FormalSystem/Theorems/Perpetuity/README.md` |

No file appears in two territories. If parallel dispatch is not used, run phases in numeric order.

---

### Phase 1: `README.md` — remove the false sorry claim and correct proof status [COMPLETED]

**Goal**: Delete the "Active sorry obligations" section, replace "axiom-free" with the house
phrasing, and rewrite the proof-status prose at `:127-152` so all four frame classes and the
three-way strong-completeness split are stated correctly.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` and record the C3 line verbatim as the
      evidence for the deletion below.
- [x] **A1**: delete `README.md:154-156` ("Active sorry obligations") entirely. It names
      `WeakCanonical/Transfer.lean` and `WeakCanonical/Separation/` as carrying sorries; neither
      does. This is the single most damaging line in the file.
- [x] **A10**: replace `:129`'s "sorry-free and axiom-free (no `sorryAx` dependency)" with the
      house phrasing transcribed verbatim from `FormalSystem/Metalogic.lean:48`. Never write
      "axiom-free".
- [x] **A2**: correct `:129` ("continuous and discrete completeness have remaining obligations")
      and the mermaid Discrete node at `:136` — `completeness_discrete` is proven and
      axiom-clean.
- [x] **A3**: mark Continuous/Dedekind soundness and completeness as proven at both the mermaid
      node (`:135`) and the axiom table (`:150`, currently `--` / `--`). Add the binder clause:
      both results are stated against `ValidDedekindDense`, not the density-free `ValidDedekind`,
      because `density` and `dense_indicator` are admissible in a Dedekind derivation and both
      are false on `Z` (`Axioms.lean:499-502`). One clause suffices; it must not be dropped.
- [x] **A5**: rewrite `:129-152` to adopt the repo's settled terminology
      (`StrongCompleteness.lean:25-41`: "strong completeness" is reserved for a possibly-infinite
      premise set; `Context` is `List Formula`, so every context here is finite). State the
      three-way status — weak plus finite-context consequence completeness PROVEN for all four
      classes; strong completeness OPEN for Base and Dense, REFUTED for Discrete, NOT STATED for
      Dedekind. **Transcribe from `FormalSystem/Metalogic.lean:83-101`**, which already states
      this split in house prose including "unavailable on the primary source's own terms" for
      Dedekind, rather than re-phrasing it.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts the sorry section is at `:154-156`, "axiom-free" at
`:129`, the mermaid nodes at `:135-136`, and the table row at `:150`. Line numbers in `README.md`
shift as soon as `:154-156` is deleted. Confirm each anchor at implementation time by content,
not position: `grep -n 'axiom-free\|Active sorry\|Complete (pending)\|Continuous' README.md`
before editing, and re-grep after each edit. Use the observed positions, not these.

**Files to modify**:
- `README.md` - delete `:154-156`; rewrite the status prose, mermaid nodes, and table rows in `:127-152`

**Verification**:
- `grep -c 'axiom-free' README.md` returns 0.
- `grep -n 'Active sorry' README.md` returns nothing.
- Every theorem named in the rewritten prose re-greps clean against its `.lean` site
  (`completeness_discrete`, `soundness_dedekind`, `completeness_dedekind`, `CompactBase`,
  `CompactDense`, `strongCompletenessDiscrete_refuted`).
- The rewritten text contains the `ValidDedekindDense` binder clause.
- `bash scripts/check-module-invariants.sh` still prints ALL CHECKS PASSED.

---

### Phase 2: `README.md` — counts, naming, structure, and the Decidability section [COMPLETED]

**Goal**: Rename Continuous to Dedekind with the TM+_c gap note, correct all constructor and
per-class counts, regenerate the Project Structure tree from the filesystem, expand the
`WeakCanonical/` one-liner, add the missing Decidability subsection, and repair the A7 formatting
slip.

**Tasks**:
- [x] **A4**: rename the class "Continuous" to "Dedekind" throughout (`:135-136`, `:148`, `:150`)
      and add a one-line note, transcribed from `Axioms.lean:503-513`, that the paper's TM+_c has
      **no** frame class in this tree — its models are exactly `{Z, R}` up to isomorphism and
      picking that class out would need an axiom set for `Th(Z) ∩ Th(R)` the tree does not have.
      Without the note the rename hides a genuine gap.
- [x] **A12**: correct the per-class cumulative counts from the Shared ground truth table —
      Dense 38 -> **39**, Continuous/Dedekind 39 -> **42**. Base 37 and Discrete 40 are already
      correct. The mermaid nodes at `:132-136` carry the same counts and must move together with
      the table or the two will disagree.
- [x] **A12 (cont.)**: `:152` gives "Burgess-Xu temporal (22)". The source structure is BX
      Temporal **18** plus a separate Additional BX Temporal layer of **4**. Write the two layers.
- [x] **A9**: `:92` "Axioms (44 constructors, 7 layers)" and `:164` "all 44 constructors" ->
      **45 constructors in nine layers**. The "7 layers" figure is also wrong.
- [x] **A6**: add a Decidability subsection. Model it on
      `FormalSystem/Metalogic/Decidability.lean:141-160`: the sound direction is landed
      (`sound_of_isValid`, `isValid_sound`); the completeness direction, `valid_iff_allClosed`,
      and the four `Decidable` instances are OPEN. Copy `Decidability.lean`'s discipline of
      citing **files without line numbers** — these are the citations most likely to drift.
- [x] **A8**: regenerate the Project Structure block (`:87-105`) from the filesystem. The current
      block has no copy-pasteable line: it is rooted `ProofChecker/` (repo is `BimodalLogic`,
      Lake lib root is `FormalSystem`, `lakefile.lean:17-19`), shows a nonexistent
      `FormalSystem/Bimodal/`, omits `BaseLanguage/` and `Boneyard/`, and writes `Tests/` where
      tests live at `Tests/BimodalTest/`. Label `Boneyard/` (156 archived files) as the archive so
      its presence is not read as live code.
- [x] **A11**: expand `:98`'s "`WeakCanonical/ # Reynolds/Doets discrete pipeline`". Measured
      live contents are 19 loose modules and 8 subdirectories, including `DenseModelSurgery/`
      (9 files) and `RealModel/` (7 files) — the Dedekind/real route — and `GroupModel/`
      (6 files), which hosts the discharged `countermodel_discrete`.
- [x] **A7**: restore the dropped space in `| Comment lines | ~96,290|` at `:21`. Carry the
      uncommitted 539 / ~170,898 / ~96,290 figures forward unchanged; do **not** revert them.
      Record in the summary that A7 arrived from the working tree, not this task's own edit.
- [x] Hand-check every relative link in `README.md`. `readme-lint.sh` takes
      `ROOT="${1:-FormalSystem}"` (`scripts/readme-lint.sh:17`), so the repository root is
      **outside its coverage entirely** — any link added by this phase must be checked by hand.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts 45 constructors in nine layers, the four cumulative
per-class counts (37/39/40/42), a 19-module/8-subdirectory `WeakCanonical/`, and a 10-entry
`FormalSystem/` top level. Confirm at implementation time with
`grep -n 'Total: 45' FormalSystem/ProofSystem/Axioms.lean`, a read of `Axiom.minFrameClass`
(`Axioms.lean:588-597`), and `find FormalSystem -maxdepth 1 -type d` /
`find FormalSystem/Metalogic/WeakCanonical -maxdepth 1`. Use the observed values, not these.

**Files to modify**:
- `README.md` - rename Continuous to Dedekind plus gap note; per-class and constructor counts; new Decidability subsection; regenerated Project Structure tree; `WeakCanonical/` description; `:21` formatting

**Verification**:
- Every directory named in the regenerated tree exists (`find FormalSystem -maxdepth 1 -type d`
  matches the block); the tree root is not `ProofChecker/` and no `Bimodal/` appears.
- `grep -n '44 constructors\|Continuous' README.md` returns nothing.
- Per-class counts in the table and the mermaid nodes agree with each other and with the Shared
  ground truth table.
- Every relative link resolves, checked by hand (readme-lint does not cover the repo root).
- The TM+_c gap note is present alongside the rename.
- `bash scripts/check-module-invariants.sh` still prints ALL CHECKS PASSED.

---

### Phase 3: `FormalSystem/README.md` [COMPLETED]

**Goal**: Remove the "decidability fully proven" over-claim, add the fourth variant, sweep 42 to
45 across six sites, rebuild the root-file table, and fix the two unlisted copy-paste defects.

**Tasks**:
- [x] **B1**: rewrite `:285` ("| 2 | Metalogic | **Complete** (Soundness, Completeness, Deduction,
      Decidability) |") and `:289-290` ("... decidability are all fully proven"). Read
      `FormalSystem/Metalogic/Decidability/Correctness.lean:183-224` ("Retired as vacuous")
      **before** rewriting: two declarations, `validity_decidable` and
      `validity_has_decision_procedure`, previously papered over exactly this gap and were
      retired because "their *names* claimed a decidability result their *proofs* did not
      contain". Reintroducing the claim in prose repeats the retired defect. Only the sound
      direction exists. Also correct "(Dense and Discrete variants)" — all four classes have weak
      completeness. Row `:284` (`| 1 | FrameConditions | Complete (Base, Dense, Discrete
      soundness) |`) carries the same three-of-four omission.
- [x] **B4 — DO NOT TOUCH `:97`.** "3 Discrete-only, 2 Dense-only" is **already correct** per
      `Axioms.lean:589-594`. The contradictory site is `ProofSystem/README.md:37`, owned by
      Phase 4. `:97` still needs the 3 Dedekind axioms added, which is why its total reads 42 —
      that part is B5 below.
- [x] **B5**: sweep 42 -> **45** at `:79`, `:92`, `:94`, `:200`, `:252`, `:282`, and "8 layers"
      -> **nine** at `:79`. Rebuild the layer table (`:81-90`, currently summing 4+5+22+1+5+2+1+2
      = 42) to nine layers summing to 45, splitting BX Temporal into 18 + 4 and adding the
      Dedekind row.
- [x] **B6**: `:138` says "TM logic has three variants based on frame conditions" with sections
      for Base/Dense/Discrete at `:140-165` and no Dedekind section. Add
      `### TM Dedekind (Base + 2 Dense + 3 Dedekind constructors)` modelled on the existing
      three, citing `soundness_dedekind` (`Metalogic/Soundness.lean`) and `completeness_dedekind`
      (`Metalogic/StrongCompleteness.lean`) against `ValidDedekindDense`, plus the TM+_c gap note.
      Extend `:167-169` ("Variant Incompatibility"), which is correct but incomplete —
      `Axioms.lean:481-483` adds that Discrete and Dedekind are likewise incomparable and
      `Dedekind </= Dense`.
- [x] **B13**: rebuild the root-file table at `:183-193`. All nine line counts are wrong and the
      first row names `Bimodal.lean`, which does not exist. The Lake roots are the pair
      `FormalSystem.lean` (repo root) and `FormalSystem/FormalSystem.lean`, described precisely at
      `scripts/check-module-invariants.sh:402-407` (C8's own comment) — reuse the wording the
      anchor task already transcribed into `Metalogic/README.md`. Add the missing
      `BaseLanguage.lean` row. Regenerate every count with `wc -l`.
- [x] **D1**: add `BaseLanguage/` to the Submodule Navigation table (`:233-243`) as a plain
      **unlinked** row with the README column reading "No". Add `Boneyard/` as a normal linked row
      labelled as the archive.
- [x] **Unlisted 1**: `:266-267` ships `lake build Bimodal`. `lakefile.lean` declares exactly two
      libs, `FormalSystem` and `BimodalTest`; there is no `Bimodal` target. Correct to
      `lake build FormalSystem`.
- [x] **Unlisted 2**: `:307` reads `**Parent**: [Project Root](../../)`. From `FormalSystem/`
      that resolves above the repository root; it should be `../`. Check 3 misses it because the
      path exists on disk.
- [x] **Unlisted 5**: `:152` gives BX Temporal as a single layer of 22; write 18 + 4. *(deviation: altered — the stale `22` lived in the layer table's BX Temporal row, not at `:152`; rebuilt as 18 + a 3b row of 4. Also fixed an unlisted defect in the same table and at the Dense variant section: `density` was printed as `Gφ → GGφ`, but `Axioms.lean` states it as `GGφ → Gφ`.)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts nine `42` sites in this file (six of them B5's), nine
stale root-file line counts, and a layer table summing to 42. Confirm at implementation time with
`grep -n '\b42\b\|8 layers\|three variants' FormalSystem/README.md` and
`wc -l FormalSystem/*.lean FormalSystem.lean` before writing any figure. Use the observed values,
not these.

**Files to modify**:
- `FormalSystem/README.md` - B1, B5, B6, B13 root-file table, D1 navigation rows, and the three unlisted fixes

**Verification**:
- `git diff FormalSystem/README.md` shows `:97` **unchanged** apart from the Dedekind-axiom
  addition required by B5; the "3 Discrete-only, 2 Dense-only" clause is byte-identical.
- The rebuilt layer table's per-layer counts sum to 45 across nine layers.
- `grep -n '\b42\b\|three variants\|fully proven' FormalSystem/README.md` returns nothing that
  restates a corrected claim.
- Every `wc -l` figure in the root-file table matches the filesystem.
- `bash scripts/readme-lint.sh` Check 2 is clean for this file and the broken-reference count has
  not increased above the 5 baseline.

---

### Phase 4: `FormalSystem/ProofSystem/README.md` [COMPLETED]

**Goal**: Fix the Dense/Discrete split (this is the wrong side of the B4 contradiction), sweep 42
to 45, add the fourth variant, and remove the phantom module and four stale line counts.

**Tasks**:
- [x] **B4**: `:37` reads "37 Base constructors, **2 Discrete-only, 3 Dense-only**". This is the
      **wrong** side of the contradiction: `Axioms.lean:589-594` gives 2 Dense (`density`,
      `dense_indicator`) and 3 Discrete (`prior_UZ`, `prior_SZ`, `z1`). Correct it here;
      `FormalSystem/README.md:97` is already right and is not touched.
- [x] **B5**: sweep 42 -> **45** at `:12`, `:22`, `:40`, and "8 layers" -> **nine** at `:22`.
      Rebuild the layer table (`:26-35`, currently summing to 42) to nine layers summing to 45,
      splitting BX Temporal 18 + 4 and adding the Dedekind row.
- [x] **B6**: `:5-6` says "all three TM logic variants (Base, Dense, Discrete)". There are four.
      Add Dedekind; `completeness_dedekind` currently appears nowhere in this file.
- [x] **B10**: delete the `Substitution.lean` row at `:15` — the file does not exist
      (`ProofSystem/` holds exactly `Axioms.lean`, `Derivable.lean`, `Derivation.lean`,
      `LinearityDerivedFacts.lean`). Delete the `Formula.subst` entry at `:64` — zero occurrences
      of `Formula.subst` or `def subst` anywhere in `Syntax/` or `ProofSystem/`.
- [x] **B10 (cont.)**: correct all four stale line counts, not just `Axioms.lean` as the task
      description states: `Axioms.lean` 468 -> **625** (`:12`), `Derivation.lean` 385 -> **386**
      (`:13`), `Derivable.lean` 221 -> **228** (`:14`), `LinearityDerivedFacts.lean` 82 -> **88**
      (`:16`).
- [x] Leave "Inference Rules (7 total)" alone — `inductive DerivationTree` has exactly 7
      constructors (`axiom`, `assumption`, `modus_ponens`, `necessitation`,
      `temporal_necessitation`, `temporal_duality`, `weakening`). Verified correct.
- [x] **Unlisted 6**: `:39-41` cross-references "The root README references '21 axiom schemata'".
      The top-level `README.md` no longer contains that string. Repoint or drop the
      cross-reference; do not leave it dangling.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts four stale line counts, a four-file `ProofSystem/`
directory, and a seven-constructor `DerivationTree`. Confirm at implementation time with
`wc -l FormalSystem/ProofSystem/*.lean`, `ls FormalSystem/ProofSystem/`, and
`grep -c '^  | ' FormalSystem/ProofSystem/Derivation.lean` scoped to `inductive DerivationTree`.
Use the observed values, not these.

**Files to modify**:
- `FormalSystem/ProofSystem/README.md` - B4 (`:37`), B5, B6, B10, and the dangling cross-reference

**Verification**:
- The layer table's per-layer counts sum to 45 across nine layers.
- `grep -n 'Substitution.lean\|Formula.subst\|\b42\b\|three TM logic variants' FormalSystem/ProofSystem/README.md`
  returns nothing.
- The Dense/Discrete split reads 2 Dense / 3 Discrete and matches `FormalSystem/README.md:97`.
- Every `wc -l` figure matches the filesystem.
- `bash scripts/readme-lint.sh` Check 2 is clean for this file.

---

### Phase 5: `Metalogic/Algebraic/README.md` and `Metalogic/BXCanonical/README.md` [COMPLETED]

**Goal**: Delete two phantom file rows and three contradictory scope statements from
`Algebraic/`; widen `BXCanonical/` from two classes to four, remove its phantom `truth_lemma`,
and refresh both module tables from the filesystem.

**Tasks**:
- [x] **B2**: delete `Algebraic/README.md:32` (`AlgebraicCompleteness.lean` | Main completeness
      theorem | **Sorry-free**) and `:55` (`DovetailedChain.lean`). **Neither file exists.** The
      directory holds exactly `BooleanStructure.lean` (441), `FlowFrame.lean` (806),
      `InteriorOperators.lean` (176), `LindenbaumQuotient.lean` (393), `UltrafilterMCS.lean`
      (1,071) — 5 files, 2,887 lines.
- [x] **B2 (cont.)**: reconcile the *three* mutually inconsistent scope statements — `:3` and `:8`
      ("primary completeness path via deterministic chains"), `:18-19` ("supplementary
      infrastructure, not required for the current proof architecture"), `:179` ("[Bundle README]
      - **Primary** BFMCS completeness approach"). All three are wrong against the corrected
      anchor (`Metalogic/README.md:36-45`): **`BXCanonical` is the wired entry point**, and
      `Algebraic/` is not optional — `BXCanonical` imports `Algebraic.FlowFrame`
      (`Completeness.lean:13`, `Chronicle/ChronicleToCountermodelBasic.lean:10`,
      `Chronicle/ChronicleMonadicBridge.lean:15`, `DiscreteCarrierProbe.lean:7`), so it
      participates in the live proof. Per **D3**, cite that fact **without any import count**.
      `:49-55` correctly records the deterministic-chain modules as archived, which is what makes
      `:3` and `:8` self-contradictory within the same file.
- [x] **B11**: repair `Algebraic/README.md:26` (lists the *sibling* aggregator
      `FormalSystem/Metalogic/Algebraic.lean`, 40 lines, as a file inside the directory). Copy the
      already-repaired `BXCanonical/README.md:13` row **verbatim** as the house pattern.
- [x] **D2**: rewrite `Algebraic/README.md:173` and `BXCanonical/README.md:50-51` from `Bimodal.*`
      to `FormalSystem.*`.
- [x] **B7**: widen `BXCanonical/README.md:3` and `:5` from "Dense and Discrete TM completeness"
      to all four classes. Add `completeness` (Base, `Completeness.lean:196`) — the theorem that
      closed last and the entire reason the tree is sorry-free — and the Dedekind route
      (`CompletenessDedekind.lean`, 607 lines) to Key Results at `:24-28`.
- [x] **B7 (cont.)**: remove `truth_lemma` from Key Results — **it does not exist in
      `BXCanonical/` either**. `TruthLemma.lean` holds `bot_not_in_mcs`, `imp_iff_mcs`,
      `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`, `F_from_witness`, `P_from_witness`,
      `until_forward_mcs`, `since_forward_mcs`. Name real declarations.
- [x] **B7 (cont.)**: refresh the Modules table (`:13-22`) from the filesystem —
      `CanonicalChain.lean` 110 -> 119, `CanonicalModel.lean` 794 -> 855, `Completeness.lean`
      439 -> 432, `Frame.lean` 710 -> 728, `OrderedSeedConsistency.lean` 254 -> 261,
      `TruthLemma.lean` 302 -> 312, add `CompletenessDedekind.lean` (607) and
      `DiscreteCarrierProbe.lean` (94), `Chronicle/` 7 -> 14 files, `Quasimodel/` 6 -> 5 files.
      Leave `:13` (the already-repaired sibling-aggregator row) unchanged.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts a 5-file `Algebraic/`, eleven changed rows in
`BXCanonical/`'s module table, and zero live occurrences of `truth_lemma`. Confirm at
implementation time with `ls FormalSystem/Metalogic/Algebraic/`,
`wc -l FormalSystem/Metalogic/BXCanonical/*.lean`,
`find FormalSystem/Metalogic/BXCanonical -mindepth 1 -maxdepth 1 -type d -exec sh -c 'echo -n "$1 "; ls "$1"/*.lean | wc -l' _ {} \;`,
and `grep -rn 'truth_lemma' --include=*.lean FormalSystem | grep -v Boneyard`. Use the observed
values, not these.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/README.md` - B2 (two phantom rows, three scope statements), B11, D2, D3
- `FormalSystem/Metalogic/BXCanonical/README.md` - B7 (scope, Key Results, phantom `truth_lemma`, module table), D2

**Verification**:
- `grep -n 'AlgebraicCompleteness\|DovetailedChain\|truth_lemma\|Bimodal\.' FormalSystem/Metalogic/Algebraic/README.md FormalSystem/Metalogic/BXCanonical/README.md`
  returns nothing.
- No import count appears in the rewritten `Algebraic/` scope statements (D3).
- `BXCanonical/README.md:13` is byte-identical to its pre-phase state.
- Every module-table figure matches `wc -l` / `ls`.
- `bash scripts/readme-lint.sh` Checks 2 and 3 are clean for both files and the broken-reference
  count has not increased.
- `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED (C5 now sees the renamed
  module names).

---

### Phase 6: `Metalogic/WeakCanonical/README.md` [NOT STARTED]

**Goal**: Replace four phantom Key Results with the real termini, add the two missing
subdirectories and five missing loose modules, and remove the archived
`ExpressiveCompleteness/` from the live architecture diagram.

**Tasks**:
- [ ] **B3**: `:44-47` advertises **four** results with zero live occurrences —
      `weak_completeness`, `truth_lemma`, `transfer_theorem`, `normal_form_reduction` (the task
      description lists only three; `truth_lemma` is the fourth). `TruthLemma.lean` contains only
      `bot_not_in_mcs`, `G_forward_mcs`, `G_backward_mcs`, `H_forward_mcs`, `H_backward_mcs`.
      Replace with the real termini: `countermodel_discrete`
      (`GroupModel/CountermodelBase.lean:142`) and `truth_transfer` (`Transfer.lean:359`).
- [ ] **B3 (cont.)**: rebuild the Modules table (`:12-33`). It lists 14 loose modules; there are
      **19**. Add `BackAndForth.lean` (265), `ColourOrders.lean` (328), `MixedSum.lean` (558),
      `PriorDefsDense.lean` (408), `PriorExpressivenessDense.lean` (412). Correct
      `OrderedSum.lean` 52 -> **57**.
- [ ] **B3 (cont.)**: rebuild the subdirectory table. It lists 6; there are **8**. Add
      `DenseModelSurgery/` (9 files, 7,568 lines) and `RealModel/` (7 files, 6,643 lines) — the
      Dedekind/real route. Correct `IntegerModel/` 5,503 -> **5,700** lines and `Kamp/` 99 files /
      71,246 lines -> **116** files / **77,619** lines. `EFGames/`, `Expressiveness/`,
      `GroupModel/`, `Separation/` are already correct.
- [ ] **B3 (cont.)**: remove `ExpressiveCompleteness/` from the Architecture block at `:51-63` —
      it was consolidated into `FormalSystem/Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness`
      and does not belong in a live architecture diagram.
- [ ] **D2**: rewrite `:67-68` from `Bimodal.*` to `FormalSystem.*`.
- [ ] Re-run `bash scripts/readme-lint.sh` after the inventory edits. Check 2 independently flags
      exactly the set above (`BackAndForth.lean`, `ColourOrders.lean`, `MixedSum.lean`,
      `PriorDefsDense.lean`, `PriorExpressivenessDense.lean`, `DenseModelSurgery/`,
      `RealModel/`), so its output is a free mechanical checklist for this phase.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts 19 loose modules, 8 subdirectories, and the specific
file/line counts above. Confirm at implementation time with
`find FormalSystem/Metalogic/WeakCanonical -maxdepth 1 -name '*.lean' | wc -l`,
`find FormalSystem/Metalogic/WeakCanonical -mindepth 1 -maxdepth 1 -type d`, and per-directory
`ls *.lean | wc -l` plus `cat *.lean | wc -l`. Use the observed values, not these.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/README.md` - B3 (Key Results, modules table, subdirectory table, architecture block), D2

**Verification**:
- `grep -n 'weak_completeness\|truth_lemma\|transfer_theorem\|normal_form_reduction\|ExpressiveCompleteness\|Bimodal\.' FormalSystem/Metalogic/WeakCanonical/README.md`
  returns nothing.
- `countermodel_discrete` and `truth_transfer` each re-grep clean against their `.lean` sites.
- `bash scripts/readme-lint.sh` Check 2 reports no missing module or subdirectory for this file.
- Broken-reference count has not increased above the 5 baseline.

---

### Phase 7: `Metalogic/{Bundle,Decidability,Core}/README.md` and `FrameConditions/README.md` [NOT STARTED]

**Goal**: Remove the Bundle hedges against sorries that do not exist, un-stale the Decidability
sound-direction claim, repair the last sibling-aggregator violation, and correct
`FrameConditions/`'s citation, class count, and line counts.

**Tasks**:
- [ ] **B8**: `Bundle/README.md:70` ("Active sorries in Bundle/: 0 in core completeness chain")
      and `:72-73` ("Any remaining sorries are in optional or experimental files") both assert
      live sorries via their qualifiers. C3 is directory-wide and unconditional: there are none.
      Remove both qualifiers. Delete the dead Future Work item at `:170` ("Eliminate temporal
      sorries"). **Preserve `:159`** ("Archived the previous 30-sorry Representation development
      to `Boneyard/Metalogic_v5/`") — that is a historical statement about the archive and is
      correct.
- [ ] **B9**: `Decidability/README.md:11` ("`decide_sound` ... is **the one direction** that is
      machine-checked") is stale since `sound_of_isValid` (`Correctness.lean:100`) and
      `isValid_sound` (`:111`) landed. Mirror `Decidability.lean:141-153`, which separates the two
      claims correctly: `decide_sound` is the corollary at the empty context, while the
      `isValid`-shaped sound direction is a separate landed result. **Preserve `:12-15`
      unchanged** — the biconditional-not-established statement with its pointer to the "Retired
      as vacuous" section is already correct. This is otherwise the most accurate README of the
      set; change only `:11`.
- [ ] **B11**: repair `Core/README.md:21`, which lists the sibling aggregator
      `FormalSystem/Metalogic/Core.lean` (37 lines) as a file inside the directory. Copy the
      already-repaired `BXCanonical/README.md:13` row verbatim as the house pattern. Fix the same
      error in ASCII form at `:39`, where the dependency flowchart draws `Core.lean (aggregator)`
      inside the directory.
- [ ] **B13 (Core)**: `Core/README.md:25` says `RestrictedMCS/` has 2 files; it holds exactly one
      `.lean` file (`Basic.lean`) plus its README.
- [ ] **B12**: `FrameConditions/README.md:22` cites `ProofSystem/Axioms.lean:378` for
      `inductive FrameClass`; the actual site is **`:519`**. `:3-4` says "Base, Dense, and
      Discrete variants" — four. `:4` "Four modules, 816 lines" -> 4 modules, **892** lines.
      Line counts: `FrameClass.lean` 220 -> **292**, `Validity.lean` 204 -> **209**,
      `Soundness.lean` 190 -> **204**, `Compatibility.lean` 176 -> **187**.
- [ ] **B12 (cont.)**: `:10` says "the four marker typeclasses"; there are **five**. The fifth is
      `DedekindTemporalFrame` (`FrameConditions/FrameClass.lean:182`). **Transcribe** its
      docstring (`:165-178`) rather than paraphrasing: it is "a side-car, not the load-bearing
      layer" — neither soundness nor completeness consumes it, exactly as neither consumes
      `DenseTemporalFrame` or `DiscreteTemporalFrame`; the load-bearing predicates are
      `ValidDedekind` / `ValidDedekindDense` in `Semantics/Validity.lean`.
- [ ] **B12 (cont.)**: `:42` names `FormalSystem/Bimodal.lean` as the single live importer. The
      **count 1 is correct**; only the filename is wrong — it is
      `FormalSystem/FormalSystem.lean:13`. **Preserve `:37-41` unchanged**: the measured
      dependency-direction claims there (0 files under `Metalogic/` import
      `FormalSystem.FrameConditions`; the module's only external importer is the library root)
      are correct.
- [ ] **D2**: rewrite `FrameConditions/README.md:37,39,40,41,42,55` from `Bimodal.*` to
      `FormalSystem.*`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts four stale `FrameConditions/` line counts, five marker
typeclasses, a one-file `RestrictedMCS/`, and a 37-line `Metalogic/Core.lean`. Confirm at
implementation time with `wc -l FormalSystem/FrameConditions/*.lean FormalSystem/Metalogic/Core.lean`,
`grep -n 'class .*TemporalFrame' FormalSystem/FrameConditions/FrameClass.lean`,
`ls FormalSystem/Metalogic/Core/RestrictedMCS/`, and
`grep -n 'inductive FrameClass' FormalSystem/ProofSystem/Axioms.lean`. Use the observed values,
not these.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/README.md` - B8 (`:70`, `:72-73`, `:170`)
- `FormalSystem/Metalogic/Decidability/README.md` - B9 (`:11` only)
- `FormalSystem/Metalogic/Core/README.md` - B11 (`:21`, `:39`), B13 (`:25`)
- `FormalSystem/FrameConditions/README.md` - B12, D2

**Verification**:
- `grep -n 'remaining sorries\|core completeness chain\|Eliminate temporal sorries' FormalSystem/Metalogic/Bundle/README.md`
  returns nothing; `:159` survives.
- `Decidability/README.md:12-15` is byte-identical to its pre-phase state; only `:11` changed.
- `grep -n 'Bimodal\.\|Bimodal.lean\|Axioms.lean:378\|four marker' FormalSystem/FrameConditions/README.md`
  returns nothing; `:37-41`'s dependency claims survive unchanged.
- Every line count matches `wc -l`.
- `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED, C8 included.

---

### Phase 8: `Semantics/README.md`, `Theorems/README.md`, `FormalSystem/Theorems.lean` [NOT STARTED]

**Goal**: Complete two module inventories and remove the PROVEN/SORRY-FREE conflation and a
directory-shaped link from the one `.lean` file in scope.

**Tasks**:
- [ ] **B13 (Semantics)**: `Semantics/README.md:6-15` lists 7 of 12 loose modules. Add
      `DurationClassification.lean` (259), `FrameAxioms.lean` (239), `IntTransfer.lean` (366),
      `PartialHistory.lean` (213), `PartialHistoryOrder.lean` (238), plus the `Extension/`
      subdirectory (5 files). The table has no Lines column, so no line-count work is needed here.
- [ ] **B13 (Theorems)**: `Theorems/README.md:10-21` omits `ContextualProofs.lean` (474) and
      `DiscreteUnfolding.lean` (476). Every listed line count is also stale:
      `Combinators.lean` 675 -> **747**, `DedekindDerived.lean` 400 -> **413**,
      `GeneralizedNecessitation.lean` 240 -> **241**, `ModalS4.lean` 468 -> **421**,
      `ModalS5.lean` 859 -> **781**, `Perpetuity.lean` 88 -> **95**, `TemporalDerived.lean`
      366 -> **801**. `Perpetuity/` holds 3 `.lean` files; `Propositional/` holds 3 (correct).
- [ ] **B13 (`Theorems.lean`)**: `:41`, `:42`, `:45`, `:46` use "COMPLETE (..., zero sorry)" as a
      single status token — the PROVEN/SORRY-FREE conflation. `:49-54` use the correct
      "PROVEN (zero sorry)" form and are the **in-file model to copy**. Rewrite the four lines to
      match.
- [ ] **B13 (`Theorems.lean`)**: `:84` links `[Propositional.lean](Theorems/Propositional.lean)`.
      `FormalSystem/Theorems/Propositional` is a **directory** (`Connectives.lean`, `Core.lean`,
      `Reasoning.lean`, `README.md`) with no `Propositional.lean`. Repoint to
      `Theorems/Propositional/README.md`. The other four links in that block resolve and are not
      touched.
- [ ] **Constraint**: only the module docstring of `FormalSystem/Theorems.lean` may change. No
      declaration, signature, import, or tactic. Confirm with `git diff` that every hunk lies
      inside the `/-! ... -/` block.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts 12 loose `Semantics/` modules, two missing
`Theorems/` modules, and seven stale `Theorems/` line counts. Confirm at implementation time with
`find FormalSystem/Semantics -maxdepth 1 -name '*.lean'`, `ls FormalSystem/Theorems/*.lean`, and
`wc -l FormalSystem/Theorems/*.lean`. Use the observed values, not these.

**Files to modify**:
- `FormalSystem/Semantics/README.md` - add 5 loose modules and the `Extension/` subdirectory
- `FormalSystem/Theorems/README.md` - add 2 modules; refresh 7 line counts
- `FormalSystem/Theorems.lean` - module docstring only: `:41,42,45,46` status tokens, `:84` link

**Verification**:
- `git diff FormalSystem/Theorems.lean` shows every hunk inside the module docstring; no
  declaration, signature, import, or tactic line appears in the diff.
- `grep -n 'COMPLETE (' FormalSystem/Theorems.lean` returns nothing.
- `grep -n 'Theorems/Propositional.lean' FormalSystem/Theorems.lean` returns nothing.
- Every `wc -l` figure in `Theorems/README.md` matches the filesystem.
- `bash scripts/readme-lint.sh` Check 2 is clean for both READMEs.
- `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED.

---

### Phase 9: B14 — take the broken-reference count from 5 to 0 [NOT STARTED]

**Goal**: Repoint all five broken references reported by `readme-lint.sh` Check 3 and correct the
Perpetuity declaration enumeration that the fifth one exposes.

**Tasks**:
- [ ] **D4 first**: `state.json`'s `file_scope` for this task lists 13 files; none of this
      phase's four are among them. Extend `file_scope` to 17 by adding
      `FormalSystem/Metalogic/WeakCanonical/EFGames/README.md`,
      `FormalSystem/Metalogic/WeakCanonical/Expressiveness/README.md`,
      `FormalSystem/Metalogic/WeakCanonical/Separation/README.md`, and
      `FormalSystem/Theorems/Perpetuity/README.md` before editing. Without them the gate is
      unsatisfiable.
- [ ] Run `bash scripts/readme-lint.sh` and record the 5 broken references as the phase's
      starting baseline.
- [ ] **B14 / D5**: repoint the four archived targets, labelling each as archived:
      - `WeakCanonical/EFGames/README.md:39` -> `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md`
      - `WeakCanonical/Expressiveness/README.md:34` -> `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md`
      - `WeakCanonical/Separation/README.md:42` -> `../../../Boneyard/Kamp/KampWeakCanonical/Separation/DedekindZ/README.md`
      - `WeakCanonical/Separation/README.md:43` -> `../../../Boneyard/Kamp/KampWeakCanonical/Separation/Hierarchy/README.md`
- [ ] **B14 (fifth)**: `Theorems/Perpetuity/README.md:46` links `Bridge.lean`, which does not
      exist — the directory holds `Helpers.lean`, `MonotonicityDuality.lean`, `Principles.lean`.
      Repoint to `MonotonicityDuality.lean`.
- [ ] The fifth needs more than a path swap. `Perpetuity/README.md:45` ("P1-P5: `perpetuity_1`
      through `perpetuity_5` in `Principles.lean`") is **also wrong**: the underscore appears only
      on P1 and P2, there is no `perpetuity_5`, and P6 lives in a different file. Enumerate the
      six exact names instead of writing a range — `perpetuity_1` (`Principles.lean:77`),
      `perpetuity_2` (`:308`), `perpetuity3` (`:443`), `perpetuity4` (`:512`), `perpetuity5`
      (`:811`), `perpetuity6` (`MonotonicityDuality.lean:560`).
- [ ] Add `MonotonicityDuality.lean` to `Perpetuity/README.md`'s inventory — Check 2 flags its
      absence.
- [ ] Re-run `bash scripts/readme-lint.sh` and confirm the broken-reference count is **exactly 0**.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts exactly 5 broken references, four archive target paths,
and six `perpetuity*` declaration sites. Confirm at implementation time by running
`bash scripts/readme-lint.sh` for the count, `ls` on each archive target before writing the link,
and `grep -n 'theorem perpetuity' FormalSystem/Theorems/Perpetuity/*.lean` for the six names and
their line numbers. Use the observed values, not these.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/EFGames/README.md` - repoint `:39`
- `FormalSystem/Metalogic/WeakCanonical/Expressiveness/README.md` - repoint `:34`
- `FormalSystem/Metalogic/WeakCanonical/Separation/README.md` - repoint `:42`, `:43`
- `FormalSystem/Theorems/Perpetuity/README.md` - repoint `:46`; re-enumerate `:45`; add `MonotonicityDuality.lean` to the inventory
- `specs/state.json` - extend this task's `file_scope` from 13 to 17 entries (D4)

**Verification**:
- `bash scripts/readme-lint.sh` reports **0 broken references** (down from 5) and its
  missing-README count is unchanged at 9.
- Each repointed target exists on disk (`ls` on each of the four archive paths).
- `grep -n 'perpetuity_5\|perpetuity_6\|Bridge.lean' FormalSystem/Theorems/Perpetuity/README.md`
  returns nothing.
- All six enumerated declaration names re-grep clean against their `.lean` sites.

---

### Phase 10: Verification gate [NOT STARTED]

**Goal**: Confirm the whole layer is internally consistent, both gate conditions are met, and no
`.lean` file changed outside the one permitted docstring.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh`; confirm **ALL CHECKS PASSED** (exit 0), with
      C3, C5, C8, and C9 individually PASS.
- [ ] Run `bash scripts/readme-lint.sh`; confirm **0 broken references** (down from 5) and 9
      missing READMEs (unchanged — explicitly out of scope; the script will still exit FAIL on
      that count and that is the recorded baseline).
- [ ] Cross-file consistency sweep — the failure mode this task exists to fix is two documents
      disagreeing:
      - `grep -rn '\b42\b' README.md FormalSystem/README.md FormalSystem/ProofSystem/README.md`
        returns no constructor-count claim.
      - `grep -rn 'three variants\|three TM logic' FormalSystem/` returns nothing.
      - `grep -rn 'axiom-free' README.md FormalSystem/` returns nothing.
      - `grep -rn 'Continuous' README.md` returns nothing.
      - The Dense/Discrete split reads identically (2 Dense / 3 Discrete) in
        `FormalSystem/README.md` and `FormalSystem/ProofSystem/README.md`.
      - Both layer tables sum to 45 across nine layers.
      - `grep -rn 'weak_completeness\|transfer_theorem\|normal_form_reduction\|truth_lemma\|Formula.subst\|perpetuity_5\|perpetuity_6' README.md FormalSystem/**/README.md`
        returns nothing.
- [ ] Confirm `git diff --name-only` contains exactly one `.lean` path,
      `FormalSystem/Theorems.lean`, and that its diff hunks lie entirely inside the module
      docstring.
- [ ] Confirm no file in report §5's DO-NOT-TOUCH list appears in `git diff --name-only`:
      `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/Decidability.lean`,
      `FormalSystem/Metalogic/WeakCanonical.lean`, `FormalSystem/Metalogic/StrongCompleteness.lean`,
      `FormalSystem/Metalogic/SoundnessLemmas/README.md`, `FormalSystem/ProofSystem/Axioms.lean`,
      `specs/ROADMAP.md`, `FormalSystem/Metalogic/README.md`.
- [ ] Confirm `FormalSystem/README.md:97`'s "3 Discrete-only, 2 Dense-only" clause is unchanged.
- [ ] Record in the summary: D1 through D5 as taken; the A7 metrics edit's working-tree
      provenance; the D2 handoff of the ~30 out-of-scope `Bimodal.*` occurrences to a downstream
      sweep; the D3 handoff of `Metalogic/README.md:44-45`'s two stale import numerals with the
      re-derived values (9 and 4); `docs/reference/axiom-reference.md`'s 42-to-45 sweep; the
      four-file `file_scope` extension; and any figure where implementation-time re-verification
      diverged from the research report.

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3, 4, 5, 6, 7, 8, 9

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts the gate baselines — `readme-lint.sh` at 5 broken
references / 9 missing READMEs before the task, and 0 / 9 after. Both halves are measured, not
assumed: record the script's output verbatim at the start of Phase 1 and again here, and compare.
If the pre-task baseline differs from 5/9 when first measured, use the observed baseline and note
the divergence in the summary rather than forcing these numbers.

**Files to modify**:
- None (gate only; the summary artifact is written by postflight)

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with ALL CHECKS PASSED.
- `bash scripts/readme-lint.sh` reports 0 broken references and 9 missing READMEs.
- `git diff --name-only` contains exactly one `.lean` path and no DO-NOT-TOUCH file.

---

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED (exit 0), C3/C5/C8/C9
      individually PASS.
- [ ] `bash scripts/readme-lint.sh` broken-reference count is **0** (baseline 5); missing-README
      count is unchanged at **9**.
- [ ] `grep -rn 'axiom-free' README.md FormalSystem/` returns nothing.
- [ ] `grep -rn 'Active sorry\|remaining sorries' README.md FormalSystem/` returns nothing.
- [ ] No phantom declaration name (`weak_completeness`, `truth_lemma`, `transfer_theorem`,
      `normal_form_reduction`, `Formula.subst`, `perpetuity_5`, `perpetuity_6`) survives in any
      edited README.
- [ ] No phantom file reference (`Bimodal/`, `Bimodal.lean`, `AlgebraicCompleteness.lean`,
      `DovetailedChain.lean`, `Substitution.lean`, `Bridge.lean`, `Theorems/Propositional.lean`,
      `ExpressiveCompleteness/`, `DedekindZ/`, `Hierarchy/`) survives in any edited README.
- [ ] Both layer tables (`FormalSystem/README.md`, `ProofSystem/README.md`) sum to 45 across nine
      layers and agree with each other.
- [ ] `README.md`'s Project Structure tree matches `find FormalSystem -maxdepth 1 -type d`, is
      rooted at the repository, and every path in it is copy-pasteable.
- [ ] `lake build FormalSystem` is the build command shipped in `FormalSystem/README.md`
      (a valid Lake target), not `lake build Bimodal`.
- [ ] `git diff --name-only` contains exactly one `.lean` path (`FormalSystem/Theorems.lean`,
      docstring-only) and no DO-NOT-TOUCH file.
- [ ] Every relative link in `README.md` resolves, hand-checked (readme-lint does not cover the
      repository root).

## Artifacts & Outputs

- `README.md` (corrected: A1-A12)
- `FormalSystem/README.md` (corrected: B1, B5, B6, B13, D1, plus 3 unlisted defects)
- `FormalSystem/ProofSystem/README.md` (corrected: B4, B5, B6, B10, plus 1 unlisted defect)
- `FormalSystem/Metalogic/Algebraic/README.md` (corrected: B2, B11, D2, D3)
- `FormalSystem/Metalogic/BXCanonical/README.md` (corrected: B7, D2)
- `FormalSystem/Metalogic/WeakCanonical/README.md` (corrected: B3, D2)
- `FormalSystem/Metalogic/Bundle/README.md` (corrected: B8)
- `FormalSystem/Metalogic/Decidability/README.md` (corrected: B9)
- `FormalSystem/Metalogic/Core/README.md` (corrected: B11, B13)
- `FormalSystem/FrameConditions/README.md` (corrected: B12, D2)
- `FormalSystem/Semantics/README.md` (corrected: B13)
- `FormalSystem/Theorems/README.md` (corrected: B13)
- `FormalSystem/Theorems.lean` (module docstring only: B13)
- `FormalSystem/Metalogic/WeakCanonical/EFGames/README.md` (corrected: B14)
- `FormalSystem/Metalogic/WeakCanonical/Expressiveness/README.md` (corrected: B14)
- `FormalSystem/Metalogic/WeakCanonical/Separation/README.md` (corrected: B14)
- `FormalSystem/Theorems/Perpetuity/README.md` (corrected: B14 plus the P1-P6 enumeration)
- `specs/state.json` (`file_scope` extended from 13 to 17 entries, D4)
- `specs/485_readme_correction_toplevel_and_formalsystem/summaries/01_readme-correction-summary.md`
- Three downstream handoffs recorded in the summary: the ~30 out-of-scope `Bimodal.*` occurrences
  (D2), `Metalogic/README.md:44-45`'s two stale import numerals with re-derived values 9 and 4
  (D3), and `docs/reference/axiom-reference.md`'s 42-to-45 sweep.

## Rollback/Contingency

All changes are confined to 17 markdown files plus one `.lean` module docstring, across nine
disjoint file territories. Each phase commits independently, so a single phase can be backed out
with `git revert` without disturbing any other. Because no file appears in two territories,
reverting one phase never invalidates another — the sole exception is `README.md`, where Phase 2
builds on Phase 1, so reverting Phase 1 requires reverting Phase 2 first.

If `readme-lint.sh`'s broken-reference count rises above 0 after Phase 9, the cause is almost
certainly a newly added link: `git diff -U0` the phase's file and check each added `](` target
with `ls`. If `check-module-invariants.sh` C5 fails after Phases 5-7, the cause is the D2 rename
making a previously invisible module name visible; revert the specific renamed line rather than
the whole phase, and record the non-resolving name for the downstream sweep.

If D1's unlinked-`BaseLanguage/` compromise is rejected on review, the fallback is research
option (b) — create `FormalSystem/BaseLanguage/README.md`, which additionally closes a Check 1
item (9 -> 8) but adds a file outside the declared scope and outside the "correct existing
documents" framing. That is a scope decision for the user, not the implementer.
