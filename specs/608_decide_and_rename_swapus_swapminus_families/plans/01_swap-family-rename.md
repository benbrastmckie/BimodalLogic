# Implementation Plan: Task #608

- **Task**: 608 - Decide and rename the swapUS / swapMinus / *_swap_valid* families
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None (the TD -> TR rename it extends is archived and landed)
- **Research Inputs**: specs/608_decide_and_rename_swapus_swapminus_families/reports/01_swap-family-rename-decision.md
- **Artifacts**: plans/01_swap-family-rename.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research report settles the decision with one test: does the identifier denote the paper's
time reflection `φ⟨S|U⟩` (rule TR, `thm:TR-valid`)? That gives a split verdict. `swapMinus` becomes
`reflectTime` (on `MinusFormula`), and the `_swap_valid` component becomes `_reflect_time_valid`.
`swapUS` (box-opaque, not `reflectTime`) and `truth_swap` (the L⁻ analogue of
`lem:temporal-duality`, named for `MinusFrame.swap`) are kept. The work has three parts. First, a
map-file-driven whole-token rename in one atomic Lean batch. Second, a classified prose pass, so the
text never says "TR uses `reflectTime`, not `reflectTime`". Third, a record update and the final
gate. No serialized string contains either renamed substring, so dataset strings stay byte-stable
by construction. A residual literal check confirms this.

### Research Integration

From report 01:
- Inventory: `swapMinus` has 84 occurrences in 9 files, `_swap_valid` has 197 occurrences in 21
  files, and Boneyard and `Tests/` have none. Re-confirmed at plan time: 27 tracked non-specs,
  non-Boneyard files match `swapMinus|_swap_valid`, 26 of them under `FormalSystem/` plus the
  record.
- There are no collisions: none of the new names exists today.
- The only `"…swap…"` string literals are the contrastive mutation tags (`"modal_swap"`,
  `"temporal_swap"`, `"derived_swap"`). Neither renamed substring appears in them.
- These prose sites need rewording, not a token replace: `Syntax/MinusLanguage/Derivation.lean`
  (~24-28, 85), `Syntax/MinusLanguage/Translation.lean` (~26, 136-145),
  `Metalogic/Conservativity/Backward.lean` (~64-65), `Semantics/MinusLanguage/MinusFrame.lean`
  (~92, 295-300, the `truth_swap` docstring) and `Semantics/MinusLanguage/MinusSchemaValidity.lean`
  (~35, 146).
- Adjacent `swap`-named identifiers (`swap_norm`, `*_swap_of_tm*`, the `cValid` swaps,
  `starValid_*_swap`) are out of scope and recorded as a follow-up.

### Prior Plan Reference

No prior plan for this task. The archived plan
`specs/archive/584_reconcile_lean_tree_with_paper_vocabulary/plans/02_paper-vocabulary-reconciliation.md`
and its `rename-map.tsv` / `prose-ledger.md` set the procedure followed here: map TSV, whole-token
substitution, a string-literal skip, an atomic Lean batch, then a classified prose pass, then a
record update.

### Roadmap Alignment

No ROADMAP.md consulted (no roadmap_path in this dispatch).

### Decisions

- **Split verdict (agent-decided, no `user_decision`).** Rename `swapMinus -> reflectTime` and
  `_swap_valid -> _reflect_time_valid`. Keep `swapUS`, `truth_swap`, `MinusFrame.swap` and the wire
  tags. This applies the same test the TD -> TR wave used.
- **Compound spelling is a pure substring rule.** `swapMinus_neg` becomes `reflectTime_neg` and
  `tr_swapMinus` becomes `tr_reflectTime`, in camelCase as before, the same as
  `swapTemporal_injective -> reflectTime_injective`.
- **No deprecation aliases.** The prior rename landed without aliases, and these lemmas are
  internal to the repo. Adding aliases would bring the old vocabulary back.

## Goals & Non-Goals

**Goals**:
- Record the per-family verdict and the exclusions in a map file.
- Rename every `swapMinus` and `_swap_valid` identifier token in `FormalSystem/` (excluding
  Boneyard) and in READMEs.
- Reword the contrast prose so it distinguishes `MinusFormula.reflectTime` (L⁻) from
  `Formula.reflectTime` (L).
- Replace the "Not in the decided set" bullet in `docs/reference/paper-definitions-of-record.md`
  with the verdict and the reasons.
- Keep every serialized dataset string and wire tag byte-identical.

**Non-Goals**:
- Renaming `swapUS`, `truth_swap`, `MinusFrame.swap`, `swap_norm`, `*_swap_of_tm*`, the `cValid`
  swaps or `starValid_*_swap`.
- Any proof change. This is a pure rename.
- Editing `FormalSystem/Boneyard/**`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Blind replace yields self-contradictory prose ("TR uses `reflectTime`, not `reflectTime`") | M | H | Phase 2 is a classified prose pass. Phase 1 sweeps prose tokens, and Phase 2 fixes every flagged contrast site. |
| `MinusFormula.reflectTime` vs `Formula.reflectTime` elaboration ambiguity | M | L | Code sites use dot notation or qualified names, and no file opens both namespaces. `lake build` is the gate. |
| Longer names push lines past 100 chars | L | M | Run a line-length check over touched files after Phase 1 and rewrap. |
| Concurrent tasks' edits swept into commits | M | M | Stage by explicit file list only. Never use a directory pathspec or `git add -A`. |
| A string literal accidentally matches | H | L | The substitution script skips `"…"` literals. The Phase 1 gate diffs the set of string literals before and after the rename. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Map file and atomic identifier rename [NOT STARTED]

**Goal**: Write the rename map, then apply both rename rows as whole-token substitutions across
every affected file in one batch, so the build goes from green to green.

**Tasks**:
- [ ] Write `specs/608_decide_and_rename_swapus_swapminus_families/rename-map.tsv` exactly as
      recommended in report 01, with both rename rows and the full EXCLUSIONS block (`swapUS`,
      `truth_swap`, `MinusFrame.swap`, wire tags, adjacent families, Boneyard), each with its reason.
- [ ] Snapshot the set of string literals in the affected files, using a grep of `"[^"]*"` into the
      scratchpad, for the byte-stability check.
- [ ] Write a small substitution script in the scratchpad. For each token matching
      `[A-Za-z0-9_.']+` that contains a map substring, outside string literals, it replaces the
      substring and prints a per-file count. Run it over `git ls-files` results that match
      `swapMinus|_swap_valid`, excluding `specs/`, `FormalSystem/Boneyard/` and
      `docs/reference/paper-definitions-of-record.md`. The record is handled in Phase 3.
- [ ] Residual grep: `git grep -nE "swapMinus|_swap_valid" -- FormalSystem Tests ':!FormalSystem/Boneyard'`
      returns empty.
- [ ] Collision/sanity check: `MinusFormula.reflectTime` has exactly one definition, and
      `tr_reflectTime` and `reflectTime_involution` (MinusFormula) resolve.
- [ ] Re-diff the string-literal snapshot: no change.
- [ ] Line-length check (>100 chars) over touched files, then rewrap any offenders.
- [ ] `lake build`, the `lean_exe` roots, and BimodalTest (`lake test`) are all green. Commit with
      an explicit file list.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: about 26 files under `FormalSystem/` (Lean files plus 5 READMEs), with 84
`swapMinus` occurrences and 197 `_swap_valid` occurrences. Confirm by running the pre-rename
`git grep -c` and comparing it with the script's per-file counts. A mismatch means a token was
missed or over-matched. Investigate before building.

**Files to modify**:
- `specs/608_decide_and_rename_swapus_swapminus_families/rename-map.tsv` - new map file
- `FormalSystem/Syntax/MinusLanguage/{Formula,Translation,Derivation}.lean`, `FormalSystem/Syntax/MinusLanguage.lean` - `swapMinus` family
- `FormalSystem/Semantics/MinusLanguage/{MinusFrame,MinusSchemaValidity}.lean` - `swapMinus` uses, `swapMinus_df_valid_of_predOrder`
- `FormalSystem/Metalogic/Soundness.lean`, `Metalogic/SoundnessLemmas/FrameClassVariants.lean`, `Metalogic/Deterministic/Soundness.lean`, `Metalogic/Independence/CoarsenedModels.lean` - `_swap_valid` family
- `FormalSystem/Metalogic/Conservativity/{Backward,MinusLanguageSoundness,Plus,Star}.lean`, `Conservativity/Plus/{Atomization,AxiomValidity,PlusSoundness}.lean`, `Conservativity/Star/{StarAxiomValidity,StarPasting,StarSoundness}.lean` - both families
- `FormalSystem/Syntax/{PlusLanguage,StarLanguage}/Axioms.lean` - `_swap_valid` mentions
- READMEs: `Metalogic/README.md`, `Metalogic/SoundnessLemmas/README.md`, `Metalogic/Conservativity/Star/README.md`, `Syntax/PlusLanguage/README.md`, `Syntax/StarLanguage/README.md`, `Semantics/MinusLanguage/README.md` (if it matches)

**Verification**:
- Residual grep is empty, the string-literal set is unchanged, and `lake build`, the exe roots and
  `lake test` are green.

---

### Phase 2: Classified prose pass [NOT STARTED]

**Goal**: Reword every docstring or comment where the token substitution produced a wrong or
self-contradictory contrast, so that L⁻ time reflection and L time reflection are distinguished by
namespace.

**Tasks**:
- [ ] Write a short ledger (`specs/608_decide_and_rename_swapus_swapminus_families/prose-ledger.md`)
      that classifies each site as reworded or kept, in the style of the prior rename's ledger.
- [ ] `Syntax/MinusLanguage/Derivation.lean` (~24-28, 85): "TR uses `MinusFormula.reflectTime`, not
      `Formula.reflectTime`. The latter acts on L's `untl`/`snce`...".
- [ ] `Syntax/MinusLanguage/Translation.lean` (~26, 136-145): the `tr_reflectTime` docstring states
      `tr φ.reflectTime = (tr φ).reflectTime`, with each side's namespace named.
- [ ] `Metalogic/Conservativity/Backward.lean` (~64-65), `Semantics/MinusLanguage/MinusFrame.lean`
      (~92, 295-300; the `truth_swap` docstring keeps its name and says the `swap` refers to
      `MinusFrame.swap`, the paper's F⁻), and `Semantics/MinusLanguage/MinusSchemaValidity.lean`
      (~35, 146).
- [ ] `Syntax/MinusLanguage/Formula.lean`: the definition docstring calls it "the L⁻ time
      reflection `φ⟨S|U⟩`, the analogue of `Formula.reflectTime`".
- [ ] Optional: within renamed `_reflect_time_valid` lemma docstrings, change "swap-validity" to
      "reflection validity". Leave it unchanged anywhere outside the renamed lemmas.
- [ ] Search `git grep -n "reflectTime\`, not\|not \`reflectTime\`"` and similar, and check that no
      self-contradictions remain.
- [ ] `lake build` of the touched modules is green, then commit with an explicit file list.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: about 5-7 Lean files need rewording, as listed in report 01. Confirm with
`git grep -n "reflectTime" -- FormalSystem/Syntax/MinusLanguage FormalSystem/Semantics/MinusLanguage FormalSystem/Metalogic/Conservativity/Backward.lean`
and read each prose hit.

**Files to modify**:
- `FormalSystem/Syntax/MinusLanguage/{Derivation,Translation,Formula}.lean` - docstrings
- `FormalSystem/Metalogic/Conservativity/Backward.lean` - comment
- `FormalSystem/Semantics/MinusLanguage/{MinusFrame,MinusSchemaValidity}.lean` - docstrings
- `specs/608_decide_and_rename_swapus_swapminus_families/prose-ledger.md` - new ledger

**Verification**:
- The ledger covers every flagged site, no self-contradictory contrast remains, and the touched
  modules build.

---

### Phase 3: Record update, swapUS pointer, final gate [NOT STARTED]

**Goal**: Record the verdict in the record of paper definitions, mark `swapUS` as deliberately not
`reflectTime`, and run the full gate set.

**Tasks**:
- [ ] `docs/reference/paper-definitions-of-record.md` (~line 117): replace the "Not in the decided
      set" bullet with the verdict. `swapMinus -> reflectTime` and `_swap_valid ->
      _reflect_time_valid` are renamed. `swapUS` is kept because it is box-opaque and not `φ⟨S|U⟩`
      on boxes. `truth_swap` is kept because it is the analogue of `lem:temporal-duality` and names
      `MinusFrame.swap`. Adjacent `swap` families are listed as a possible follow-up. Update any
      `swapMinus`/`_swap_valid` token elsewhere in the record. Do not cite task numbers.
- [ ] `Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean`: add a sentence to the `swapUS`
      docstring saying it is deliberately distinct from `Formula.reflectTime`, which recurses into
      `box`.
- [ ] Final gates: `lake build`, all `lean_exe` roots, `lake test`,
      `bash scripts/check-module-invariants.sh` (no axiom-baseline movement),
      `bash scripts/check-paper-definitions.sh` (expected case (a) or a neutral SKIP),
      `bash scripts/readme-lint.sh` and `bash scripts/typst-sync-check.sh`.
- [ ] Final residual grep over the whole tracked tree, excluding `specs/` and Boneyard, for
      `swapMinus|_swap_valid`. Expect empty.
- [ ] Commit with an explicit file list.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - verdict section
- `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean` - docstring pointer

**Verification**:
- All gates pass. Known pre-existing failures, such as the `check-evidence-probes.sh` drift noted
  in the prior rename's summary, are recorded as pre-existing and are not attributed to this task.

## Testing & Validation

- [ ] `lake build` is green, and all `lean_exe` roots and `lake test` pass.
- [ ] A residual grep for `swapMinus|_swap_valid` outside `specs/` and Boneyard is empty.
- [ ] The string-literal set in the touched files is unchanged (dataset strings are byte-stable).
- [ ] `check-module-invariants.sh` passes with unchanged baselines.
- [ ] `readme-lint.sh`, `typst-sync-check.sh` and `check-paper-definitions.sh` are clean.
- [ ] `swapUS` and `truth_swap` are still present and unchanged in name.

## Artifacts & Outputs

- `specs/608_decide_and_rename_swapus_swapminus_families/rename-map.tsv`
- `specs/608_decide_and_rename_swapus_swapminus_families/prose-ledger.md`
- Renamed Lean and README files under `FormalSystem/`
- Updated `docs/reference/paper-definitions-of-record.md`
- `specs/608_decide_and_rename_swapus_swapminus_families/summaries/01_swap-family-rename-summary.md`

## Rollback/Contingency

Each phase is a separate commit, so `git revert` of the phase commit restores the prior names. The
Phase 1 batch is atomic, which means reverting its single commit undoes the entire identifier
rename. If the build fails mid-batch with an ambiguity between `MinusFormula.reflectTime` and
`Formula.reflectTime`, qualify the offending call site rather than abandoning the rename.
