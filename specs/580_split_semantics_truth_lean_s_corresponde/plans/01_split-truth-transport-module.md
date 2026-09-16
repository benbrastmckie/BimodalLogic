# Implementation Plan: Split Semantics/Truth.lean's truth-transport machinery

- **Task**: 580 - Split Semantics/Truth.lean's correspondence machinery out of Truth.lean
- **Status**: [IMPLEMENTING]
- **Effort**: 3.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/580_split_semantics_truth_lean_s_corresponde/reports/01_split-truth-correspondence-machinery.md
- **Artifacts**: plans/01_split-truth-transport-module.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`FormalSystem/Semantics/Truth.lean` (1,193 lines) conflates two subjects: the `TruthAt` recursion
for `Formula` with its clause and corollary lemmas, and a model-to-model truth-transport layer
(`TruthCorr`, `TimeShift`, `TruthIso`, `TruthAntiIso`). This plan relocates the transport layer
verbatim into a new sibling module `FormalSystem/Semantics/TruthTransport.lean`, repairs the four
gateway import lines that carry it to its 21 consumers, and updates the three documentation sites
that describe the old layout. No proof is re-authored, no declaration renamed, no attribute
membership changed. Definition of done: `lake build` exits 0 and
`scripts/check-module-invariants.sh` passes, with every moved body byte-identical to its original.

### Research Integration

The research report supplies the split geometry and the import-graph analysis this plan is built
on, and corrects the task description's own boundary in one material respect:

- The seam is **three blocks, not one**. Lines 893-996 (`truthAt_atomFree_history_indep`,
  `truthAt_gap`, `truthAt_cogap`, `truthAt_gap_shift`, `truthAt_gap_iff_cogap`) sit inside the
  region the review said to move, but are genuine `TruthAt` corollaries that touch nothing in the
  transport layer. They stay in `Truth.lean` and are relocated *upward* within it.
- `Truth.box_const` / `Truth.box_time_const` (841-891) must **leave** with the transport block even
  though they are `Truth`-namespace truth lemmas: their proofs consume
  `TimeShift.timeShift_preserves_truth`. Leaving them behind would make `Truth.lean` import its own
  downstream module — a cycle Lean rejects.
- Only **4** import lines are needed, not 21: `Semantics/Validity.lean` gateways 13 transitive
  consumers, `Metalogic/Decidability/BiLasso/Unfold.lean` gateways the 7 `BiLasso/` consumers, and
  `Semantics/ShiftSet.lean` + `Semantics/PlusTruth.lean` are the two direct importers of
  `Semantics.Truth` that use moved names.
- Gate analysis: C4 (imports resolve), C5/C12/C13 (markdown paths), C20 tier 2 (publication scope
  includes `FormalSystem/Semantics/*.lean`), and C24 (`checkInitImports`) are the only checks a
  pure split can trip. C2/C3/C14/C15/C21 are structurally immune — no proof or anchor changes.
- Baseline `lake build` was verified green (exit 0) before any edit, so any build failure during
  implementation is attributable to this task.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied for this dispatch; ROADMAP.md was not consulted.

## Goals & Non-Goals

**Goals**:
- `Truth.lean` reads as one subject: the `TruthAt` recursion, its clause lemmas, and its immediate
  corollaries (expected ~683 lines).
- A new `FormalSystem/Semantics/TruthTransport.lean` (expected ~537 lines) holds the truth-transport
  layer, with every relocated declaration keeping its fully-qualified name unchanged.
- The build and the module-invariant harness both pass, with no consumer source change beyond
  import lines.
- The three stale documentation sites that advertise the transport layer as `Truth.lean` content
  are corrected.

**Non-Goals**:
- Renaming any declaration, or changing any `simp` / `truth_norm` attribute membership.
- Re-proving, golfing, or restructuring any moved body — relocation is byte-for-byte.
- Touching the existing `Semantics/Correspondence/` modules or their README dependency contract.
- Introducing the 21-file explicit-import variant described in the research report; the 4-file
  gateway repair is the chosen approach (see Decisions below).

### Decisions carried into this plan

- **Destination is `FormalSystem/Semantics/TruthTransport.lean`**, a sibling of `Truth.lean`, not
  the `Semantics/Correspondence/TruthShift.lean` the review named. This was settled in a prior
  cycle (`.decisions.json`, cycle 1) on the agent's recommendation: `Correspondence/` is documented
  as the frame-class Galois layer whose members all import `Semantics.Validity`, while four of the
  moved module's consumers sit *below* `Validity`. Placing it there would invert the directory's
  own stated import contract. The review's wording was `(e.g. …)` — advisory, not mandated.
- **4-file gateway import repair**, not the 21-file explicit-import variant. Keeps the diff
  proportional to a pure relocation, which is what the task's "update import lines in whatever
  currently reaches the moved declarations via Semantics.Truth" describes. The 21-file variant
  remains available as a fallback if the build reveals a consumer this analysis missed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Duplicate declarations if the new file is written before `Truth.lean` is cut | H | H | Phase 1 is `atomic-batch`: create, cut, register and repair imports are one objective; the intermediate red state is expected and MUST NOT be committed |
| `variable {F : TaskFrame}` omitted from the new preamble | M | M | Named in the Phase 1 preamble checklist; ~8 declarations take `F` implicitly and fail immediately with `unknown identifier F` |
| `open FormalSystem.Syntax` omitted | M | M | Same checklist; `Formula`, `Atom`, `Formula.swapTemporal` would go unresolved |
| `box_const`/`box_time_const` accidentally left behind | H | L | Lean reports this as an invalid/cyclic import, not a missing lemma — Phase 1 verification note calls out the expected symptom |
| A consumer reaches a moved name by a path the transitive-closure analysis missed | M | L | `lake build` fails loudly on the unresolved name; fallback is to add the import at that specific consumer (or adopt the 21-file variant) |
| A `file.lean:NNN` citation introduced into the new module docstring | M | L | C20 tier 2 is enforced and `FormalSystem/Semantics/` is publication scope; cite declaration names only |
| Build livelock on a long `lake build` | M | M | Every build runs detached via `Bash(run_in_background: true)` wrapping `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …` per `context/project/lean4/operations/long-builds.md` |
| Relocating 893-996 upward silently drops or duplicates a `namespace Truth` / `end Truth` pair | M | M | Phase 1 explicitly accounts for the orphaned `namespace Truth` (841) and `end Truth` (998); an unbalanced namespace fails the build |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential.

### Phase 1: Relocate the transport layer and repair imports [COMPLETED WITH EXCLUSIONS]

**Goal**: `TruthTransport.lean` exists with the transport layer verbatim, `Truth.lean` is cut down
to the `TruthAt` subject, and `lake build` is green again.

**Tasks**:
- [x] Re-confirm the block boundaries against the current file before cutting (they were read at
      research time and are load-bearing): `end Truth` at 577; transport block A = 579-891
      (`TruthCorr` + `truthAt_of_truthCorr`, `namespace TimeShift` … `end TimeShift`,
      `namespace Truth` opened at 841 with `box_const`/`box_time_const`); keep-block = 893-996;
      `end Truth` at 998; transport block B = 1000-1191 (`TruthIso`, `TruthIso.toCorr`,
      `truthAt_of_truthIso`, `TruthAntiIso`, `truthAt_of_truthAntiIso`); `end FormalSystem.Semantics`
      at 1193.
- [x] Create `FormalSystem/Semantics/TruthTransport.lean` with this preamble, in order:
      the 5-line Apache copyright header (matching `Truth.lean` lines 1-5);
      `import FormalSystem.Semantics.Truth` (sufficient alone — it transitively supplies `TaskModel`,
      `ConvexHistory`, `Syntax.Formula` and the Mathlib order lemmas the moved bodies use);
      the G-15 guard `assert_not_exists FormalSystem.ProofSystem.Axiom
      FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.Derivable
      FormalSystem.ProofSystem.FrameClass` with its explanatory comment;
      a module docstring (declaration-name citations only, no `file.lean:NNN`);
      `namespace FormalSystem.Semantics`; `open FormalSystem.Syntax`; `variable {F : TaskFrame}`.
- [x] Append block A verbatim (579-891), closing the `namespace Truth` it opens at 841 with
      `end Truth`, then block B verbatim (1000-1191), then `end FormalSystem.Semantics`.
- [x] Delete 1000-1191 and 579-891 from `Truth.lean` (delete the higher range first so the lower
      line numbers stay valid).
- [x] Move the keep-block (893-996, including its `/-! ## A-17: history-independence and the gap
      formula` section comment) upward so it sits immediately before the `end Truth` at 577;
      drop the now-orphaned `namespace Truth` (841) and its matching `end Truth` (998).
- [x] Add `import FormalSystem.Semantics.TruthTransport` to `FormalSystem/Semantics.lean`,
      immediately after the `FormalSystem.Semantics.Truth` line (currently line 25).
- [x] Add `import FormalSystem.Semantics.TruthTransport` to exactly four consumer gateways:
      `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/ShiftSet.lean`,
      `FormalSystem/Semantics/PlusTruth.lean`,
      `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean`. *(deviation: altered — three of
      the four applied; `PlusTruth.lean` excluded on pre-edit-probe evidence, see Reasoned
      Exclusions below)*
- [x] Run the detached guarded build and drive it to exit 0.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `FormalSystem/Semantics/PlusTruth.lean` — add `import FormalSystem.Semantics.TruthTransport` | The plan's gateway hypothesis listed this file as one of four needed import sites. The probe contradicts it: `PlusTruth.lean` reaches no moved declaration in elaborated code, and it gateways no consumer that needs one, so the import would be dead weight widening the module's import surface for nothing. Decided, not deferred — there is nothing for a later dispatch to revisit. | (1) Definition lookup: the file's only two matches for any of the seventeen moved names are docstring prose — `PlusTruth.lean:43` and `PlusTruth.lean:338`, both reading "`timeShift_preserves_truth`, proved directly because `TruthCorr` is `Formula`-only". Zero matches in elaborated code. (2) Reference count / gateway-minimality probe over the whole `FormalSystem` import graph, dropping one gateway at a time: `without FormalSystem.Semantics.PlusTruth -> missing: []`, against `without …Validity -> missing: [6 modules]`, `without …ShiftSet -> missing: [ShiftSet]`, `without …BiLasso.Unfold -> missing: [BoxOracle, SmallModel, TruthLemma]`. (3) `lake build` green at 2653/2653 jobs with the import absent. |

The remaining three gateways plus the `FormalSystem/Semantics.lean` aggregator line were applied
and are load-bearing, as the same probe's other three rows show.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts (a) the seven-file edit set above — one new file, plus
`Truth.lean`, `Semantics.lean`, `Validity.lean`, `ShiftSet.lean`, `PlusTruth.lean`,
`BiLasso/Unfold.lean` — and (b) the exact line boundaries 577/579/891/893/996/998/1000/1191/1193.
Confirm (b) by re-reading those lines before cutting (first task above); confirm (a) by the build:
any additional file needing an import line will surface as an unresolved-name error, and that file
is then added to the batch rather than the batch being declared complete.

**Files to modify**:
- `FormalSystem/Semantics/TruthTransport.lean` - new; preamble + transport blocks A and B verbatim
- `FormalSystem/Semantics/Truth.lean` - delete blocks A and B; relocate the A-17 keep-block upward
- `FormalSystem/Semantics.lean` - register the new module
- `FormalSystem/Semantics/Validity.lean` - new import line (gateways 13 transitive consumers)
- `FormalSystem/Semantics/ShiftSet.lean` - new import line
- `FormalSystem/Semantics/PlusTruth.lean` - new import line
- `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean` - new import line (gateways 7 consumers)

**Verification**:
- `Bash(run_in_background: true)`:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --` exits 0.
- `git diff` on the moved regions shows pure relocation: every deleted line from `Truth.lean`
  reappears byte-identical in `TruthTransport.lean` (no whitespace or term reflow).
- No `sorry` and no new `axiom` introduced: `grep -n 'sorry\|^axiom' FormalSystem/Semantics/TruthTransport.lean`
  returns nothing.
- Expected sizes as a sanity check, not a gate: `Truth.lean` ~683 lines, `TruthTransport.lean`
  ~537 lines.
- Symptom note: an "invalid import"/cycle error means `box_const` or `box_time_const` was left in
  `Truth.lean`; `unknown identifier F` means the `variable {F : TaskFrame}` binder is missing.
- Single commit only after the build is green (atomic-batch: the intermediate duplicate-declaration
  state is expected red and is not committed).

---

### Phase 2: Update the documentation that describes the old layout [COMPLETED]

**Goal**: No prose in the tree still advertises the transport layer as `Truth.lean` content.

**Tasks**:
- [x] `FormalSystem/Semantics/README.md`: rewrite the `Truth.lean` table row so it describes only
      `TruthAt`, its `truth_norm` simp-normal form, the clause lemmas, and the A-17 /
      history-independence corollaries; strip the `TruthCorr` / `truthAt_of_truthCorr` /
      `timeShift_preserves_truth` / `TruthIso` / `TruthAntiIso` claims from it.
- [x] `FormalSystem/Semantics/README.md`: add a `TruthTransport.lean` row carrying the stripped
      material, and add the corresponding bullet to the prose module list in the same file.
      *(deviation: altered — the row was added; there is no separate prose module list in this
      README, the `## Contents` table IS the module list, so there was no second site to edit)*
- [x] `FormalSystem/Semantics/Truth.lean`: edit the module docstring — the bullet at the old line 84
      ("Time-shift preservation theorems for temporal operators") now describes the other file;
      replace it with a pointer to `TruthTransport.lean`.
- [x] `FormalSystem/Semantics/ConvexHistory.lean` (~line 323): the comment says
      `TimeShift.ShiftRel` is "in `Truth.lean`" — change the text to name `TruthTransport.lean`.
      Comment text only: this file sits *below* `Truth.lean` and MUST NOT gain an import.
- [x] Drive-by, optional: the docstring of `truthAt_gap_iff_cogap` (old `Truth.lean:972`, now inside
      the relocated keep-block) refers to a nonexistent `truthAt_cogap_iff_gap`; the theorem it
      means is itself. Pre-existing, affects no gate — correct it or leave it, but do not let it
      expand this phase's scope.
- [x] Beyond the plan's three sites, the Scope-Hypothesis re-grep found five more stale location
      claims, all fixed here: `FormalSystem/Semantics/ShiftSet.lean` (~364),
      `FormalSystem/Metalogic/Soundness.lean` (~84 and ~104),
      `FormalSystem/Metalogic/Independence/StabUndefinable.lean` (~39), and
      `FormalSystem/Metalogic/Decidability/BiLasso/Extraction.lean` (~30). Each names
      `Semantics/Truth.lean` as the home of a moved declaration; each edit is one prose line
      inside a docstring, with zero elaborated code touched.
- [x] `FormalSystem/Semantics/README.md`: refresh the `*Last verified:*` stamp to 2026-09-15.
      `scripts/readme-lint.sh` flagged it STALE because this task added a file to the directory;
      it now reports clean for that README. (The `Correspondence/` and `Ultraproduct/` stale
      stamps it also reports predate this task and were left alone.)

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts exactly three stale-prose sites (`Semantics/README.md`,
`Truth.lean`'s module docstring, `ConvexHistory.lean`'s comment) plus one optional drive-by typo.
Confirm by `grep -rn 'TruthCorr\|TruthIso\|TruthAntiIso\|ShiftRel\|timeShift_preserves_truth' --include='*.md' FormalSystem/`
and by re-grepping `Truth.lean` for transport-layer names in comments after the Phase 1 cut; any
further site found is added here.

**Files to modify**:
- `FormalSystem/Semantics/README.md` - split the `Truth.lean` row; add a `TruthTransport.lean` row and prose bullet
- `FormalSystem/Semantics/Truth.lean` - module docstring only (no code)
- `FormalSystem/Semantics/ConvexHistory.lean` - one comment line (no import, no code)

**Verification**:
- Diff read-through confirming every changed hunk in the two `.lean` files lies inside a comment or
  module-docstring region — zero lines of elaborated code touched.
- `grep -n 'Truth\.lean' FormalSystem/Semantics/ConvexHistory.lean` no longer names `Truth.lean` as
  `ShiftRel`'s home.
- `bash scripts/readme-lint.sh` (reported, not gated) shows `TruthTransport.lean` listed in its
  directory README.
- Commit per green sub-step (default mode) once the read-through is clean.

---

### Phase 3: Full gate run [NOT STARTED]

**Goal**: The task's stated verification bar is met and recorded.

**Tasks**:
- [ ] Run the detached guarded `lake build` one final time on the tree as committed.
- [ ] Run `bash scripts/check-module-invariants.sh` and read the result for each check the research
      flagged as reachable by a split: C4 (imports resolve), C5/C12/C13 (markdown path resolution),
      C16 (env_linter / `nolints.json` — re-check, none expected), C19 (docstring coverage,
      reported), C20 tier 2 (enforced; `FormalSystem/Semantics/` is publication scope), C24
      (`checkInitImports` — the new module inherits `Init` through `Truth.lean`).
- [ ] If C16 or C19 report a new finding attributable to the new module, fix it here rather than
      deferring; any other failure is diagnosed against the research report's gate-impact table
      before any code is changed.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- None expected; only remediation of a gate finding would touch a file, and that touch is
  attributed to the gate that demanded it.

**Verification**:
- `lake build` exits 0 (detached, guarded, as in Phase 1).
- `bash scripts/check-module-invariants.sh` passes.
- Axiom baselines (C2/C14/C21) unchanged from the pre-task baseline — expected by construction,
  since no proof was re-authored.

## Lean Challenge Statements

None. This plan is a pure relocation: it introduces no new theorem or definition, and every moved
body is preserved verbatim, so there is no statement for a Challenge module to pin. The identifier
set named under **Goals** is correspondingly empty.

## Testing & Validation

- [ ] `lake build` exits 0 after Phase 1 and again after Phase 3.
- [ ] `bash scripts/check-module-invariants.sh` passes.
- [ ] Every moved declaration and proof is byte-identical to its original — verified by reading the
      Phase 1 diff, not merely by the build succeeding.
- [ ] Zero `sorry` and zero new `axiom` in the tree.
- [ ] No consumer source change anywhere beyond the four added import lines and the aggregator line.
- [ ] `Truth.lean` contains no reference to `TruthCorr`, `TruthIso`, `TruthAntiIso`, `ShiftRel`,
      `shiftCorr`, `TimeShift` or `box_const` in either code or prose.

## Artifacts & Outputs

- `FormalSystem/Semantics/TruthTransport.lean` (new, ~537 lines)
- `FormalSystem/Semantics/Truth.lean` (reduced, ~683 lines)
- `FormalSystem/Semantics.lean`, `Semantics/Validity.lean`, `Semantics/ShiftSet.lean`,
  `Semantics/PlusTruth.lean`, `Metalogic/Decidability/BiLasso/Unfold.lean` (one import line each)
- `FormalSystem/Semantics/README.md`, `FormalSystem/Semantics/ConvexHistory.lean` (prose only)
- `specs/580_split_semantics_truth_lean_s_corresponde/summaries/01_*-summary.md` at completion

## Rollback/Contingency

- The whole task is three commits at most and touches no proof, so `git revert` of the Phase 1
  commit restores the pre-task tree exactly; the baseline was verified green before any edit.
- If Phase 1's build reveals a consumer the import analysis missed, add that file's import inside
  the same atomic batch. If several appear, fall back to the research report's documented 21-file
  explicit-import variant (every one of the 21 genuinely uses a moved name, so no unused-import
  finding results) rather than hunting gateways one at a time.
- If the destination choice proves wrong at build time (an import-direction problem this analysis
  did not foresee), the content is location-independent: `git mv` the new module and rewrite the
  five import lines. No proof content is affected either way.
