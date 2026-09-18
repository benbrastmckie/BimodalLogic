# Implementation Plan: Task #621

- **Task**: 621 - Adopt uniform reflect naming for time reversal
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/621_adopt_uniform_reflect_naming_for_time_reversal/reports/01_uniform-reflect-naming.md
- **Artifacts**: plans/01_uniform-reflect-naming.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The paper renamed `lem:temporal-duality` to `lem:time-reflection`. That removes the justification
("the semantic lemma keeps its name") behind the carve-outs the 2026-09-17 time-reflection wave
left in place. This plan applies one principle throughout: `reflect` names every operation that
reverses time order on any object (formula, frame, history, truth lemma), and `swap` survives
only for exchanges that are not time reversal. The work has five steps. First, update the
paper-definitions record: retire the carve-out and add a `lem:time-reflection|LIVE-UNPINNED`
KNOWN-ANCHORS row, which must exist before any tree citation. Second, rename the 8 identifier
families atomically, with no statement changes and so no new proofs. Third and fourth, sweep Lean
prose and non-Lean prose. Fifth, run every gate.

### Research Integration

The report settles every open question:
- It confirms the paper change: `lem:time-reflection` is at l.4186, and `check-paper-definitions.sh`
  gives case (b), so no re-pin is needed.
- Its table B classifies the renames by the test "does it reverse time order?" (about 250
  occurrences in 15 Lean files). Section C gives the keep-list of exchange-sense `swap`s.
- It checks every proposed name for collisions with `grep -w`.
- It inventories the prose sites and names the C15 hazard: a new `lem:time-reflection` citation
  needs the KNOWN-ANCHORS row in the same commit as the citation, or an earlier one.

This plan takes the report's decisions as given:
- `Encoding.swap` becomes `Encoding.reflectTime`.
- `swap_norm` becomes `reflect_time_norm`.
- The `starValid_*_swap` names become `starValid_*_reflect_time`.
- `mirror`, `dual` and `AntiIso` names are deferred.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Not consulted (no roadmap_path in dispatch). This is a naming-hygiene task and advances no
roadmap item directly.

## Goals & Non-Goals

**Goals**:
- Retire the "semantic lemma keeps its name" carve-out in `docs/reference/paper-definitions-of-record.md`, record the label rename, and add the `lem:time-reflection` KNOWN-ANCHORS row
- Rename the table-B identifier families:

  | Current name | New name |
  |---|---|
  | `MinusFrame.swap` | `MinusFrame.reflect` |
  | `truth_swap` | `truth_reflectTime` |
  | `swapUS` (with `_involutive`) | `reflectTimeBoxOpaque` (with `_involutive`) |
  | `swap_norm` | `reflect_time_norm` |
  | `Encoding.swap` | `Encoding.reflectTime` |
  | `plusValidIn_swap_of_tm*` | `plusValidIn_reflect_time_of_tm*` |
  | the four `cValid` swap lemmas | `*reflect_time*` forms |
  | 10 `starValid_*_swap` | `starValid_*_reflect_time` |
  | `swap_next_all_future_eq` | `reflect_time_next_all_future_eq` |

- Reword the prose that cites the temporal duality lemma or uses "swap" for reflection: Lean docstrings, READMEs, docs, the typst chapter line and test comments
- Add a short naming rule to `docs/development/LEAN_STYLE_GUIDE.md` and fix its stale `φ.swap` example
- Keep every gate green: `lake build`, `check-paper-definitions.sh`, `check-module-invariants.sh`, `readme-lint.sh` and `typst-sync-check.sh`

**Non-Goals**:
- Do not rename the exchange-sense `swap`s:
  - Kamp/EF `Equiv.swap`/`aggOdSwap12`/`swapNF01`, `contraSwap`, `monoInv_swap`, `pairProject_swap_*`
  - the `trySwap*` mutators
- Do not change any serialized wire or mutation tag (`"modal_swap"`, `"temporal_swap"`, `"derived_swap"`, `"temporal_duality"`, `temporalDualityCount`, the `*SwapCount` fields). They stay byte-stable.
- Do not rename `mirror`/`dual`/`AntiIso` identifiers (`clockMirrorIso`, `truthAt_mirror`, `TruthAntiIso`, `DenseModelSurgery.dual`). These are recorded as a possible follow-up only.
- Do not re-pin the paper checksum (case (b); the dirty-pin convention forbids it)
- Do not rename the typst notation macro `#let swap` in `typst/notation/bimodal-notation.typ`
- Do not add or change any theorem statement, sorry or axiom

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `register_simp_attr` rename (`swap_norm`) breaks every `simp only [swap_norm]` user | H | M | Change `TruthNormAttr.lean` and all its users in the same atomic batch. Grep `swap_norm` to zero before building. |
| Word-boundary sed hits Mathlib `Prod.swap`/`Equiv.swap` | H | M | Run the `e.swap`/`F.swap`/`theEncoding.swap` edits only in `Atomization.lean`, `AxiomValidity.lean`, `CoarsenedModels.lean`, `SpCountermodel.lean`, `MinusFrame.lean` and `Semantics.lean`. Use `-w` and exact full identifiers elsewhere. |
| C15 goes red on a new `lem:time-reflection` citation | M | M | Phase 1 adds the KNOWN-ANCHORS row before Phases 3 and 4 add any citation |
| `MinusFrame.reflect` gets confused with `TaskFrame.reflect` (the reflection convention on relations) | L | M | The two live in different namespaces, so they do not clash. The new docstring states that it is the paper's `F⁻`. |
| A renamed substring leaks into a string literal | M | L | After the renames, grep `"[^"]*reflect_time[^"]*"` and diff the wire-tag lines, which must be unchanged |
| The dirty working tree (`state.json`, `.claude-extensions.json`, stray logs) gets staged | M | L | Stage explicit file lists only. Never use `git add -A` or directory pathspecs. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel. Phases 3 and 4 touch disjoint file sets:
Phase 3 covers `*.lean` comments and docstrings only, and Phase 4 covers `*.md`/`*.typ` and the
test-comment files listed there.

### Phase 1: Paper-definitions record update [COMPLETED]

**Goal**: Withdraw the carve-out, record the paper's label rename, and register
`lem:time-reflection` as a known anchor, so that later citations keep C15 green.

**Tasks**:
- [x] In `docs/reference/paper-definitions-of-record.md`, replace the "**The semantic lemma keeps its name.**" bullet (around l.108-110). The new note should say that the paper renamed `lem:temporal-duality` to `lem:time-reflection`, so the carve-out is withdrawn.
- [x] Flip the `swapUS` (kept) bullet (around l.128-131) and the `truth_swap` (kept) bullet (around l.132-135) to "renamed". Also record `MinusFrame.swap` → `MinusFrame.reflect`.
- [x] Replace the "Adjacent `swap`-named identifiers ... possible follow-up" paragraph (around l.138-141) with the full table-B old→new map and the section-C keep-list, including the rationale for keeping each wire tag
- [x] Add a "(since renamed `lem:time-reflection`)" parenthetical to the historical `lem:temporal-duality` note (around l.338), matching the `thm:TD-valid` style
- [x] Add a dated section: "Label rename absorption (2026-09-18): `lem:temporal-duality` → `lem:time-reflection`, prose only, no re-pin (case b)". Mention the lemma's added claims (that `F⁻` is a task frame, and that `τ ↦ τ⁻` is a bijection).
- [x] Add a KNOWN-ANCHORS row `lem:time-reflection|LIVE-UNPINNED|...`. Add a `lem:temporal-duality|DANGLING|...` row only if a tree site outside the record keeps the old label. By default none does, so omit it.
- [x] Record the deferred `mirror`/`dual`/`AntiIso` follow-up in one line

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - retire the carve-out, flip the kept bullets, add the rename table, the dated section and the KNOWN-ANCHORS row

**Verification**:
- `bash scripts/check-paper-definitions.sh` exits 0 (case b)
- `bash scripts/check-module-invariants.sh` exits 0 (C15 still passes)
- Commit: `task 621 phase 1: paper-definitions record update`

---

### Phase 2: Identifier renames (atomic batch) [COMPLETED]

**Goal**: Rename every table-B identifier family across `FormalSystem/`. Statements do not
change, and the build is green at the end of the batch.

**Tasks**:
- [x] Take a durable pre-batch checkpoint with `bash .claude/scripts/git-snapshot.sh 621 --no-revert` (not the reverting default)
- [x] `swap_norm` → `reflect_time_norm`: change `Automation/TruthNormAttr.lean:57` and every user in the same step: `Syntax/Formula.lean` (section header around l.706-715), `Metalogic/Soundness.lean`, `Metalogic/SoundnessLemmas/FrameClassVariants.lean` (13 uses), and the prose mention in `Semantics/TruthTransport.lean`
- [x] `Encoding.swap` → `Encoding.reflectTime`. The def is at `Metalogic/Conservativity/Plus/Atomization.lean:83`. Change the `e.swap`/`theEncoding.swap` uses, scoped to `Atomization.lean`, `Plus/AxiomValidity.lean` and `Independence/CoarsenedModels.lean`.
- [x] `plusValidIn_swap_of_tm{,_deriv}` → `plusValidIn_reflect_time_of_tm{,_deriv}` in `Atomization.lean`, `Plus/AxiomValidity.lean`, `Conservativity/Plus.lean` and `Metalogic/Soundness.lean` (prose)
- [x] `cValid_swap_of_tm{,_deriv}`, `naiveAxiom_cValid_swap` and `naive_cValid_and_swap` → the `reflect_time` forms, in `Independence/CoarsenedModels.lean`
- [x] Rename the 10 `starValid_*_swap` names to `starValid_*_reflect_time` in `Conservativity/Star/StarAxiomValidity.lean`, and update the prose in `Syntax/StarLanguage/Axioms.lean`
- [x] `swapUS`/`swapUS_involutive` → `reflectTimeBoxOpaque`/`reflectTimeBoxOpaque_involutive` in `DenseModelSurgery/{Dual,Lemma5,TruthTransfer,NoGaps}.lean`. The docstring should say that box subformulas are treated as atoms.
- [x] `MinusFrame.swap` → `MinusFrame.reflect` and `truth_swap` → `truth_reflectTime`. Edit `Semantics/MinusLanguage/MinusFrame.lean` and `Conservativity/SpCountermodel.lean` (`F.swap` and the use around l.204). Update the prose mentions in `Semantics.lean` and `Conservativity.lean`. The new `MinusFrame.reflect` docstring should say that it is the paper's `F⁻` and that it is distinct from `TaskFrame.reflect`.
- [x] `swap_next_all_future_eq` → `reflect_time_next_all_future_eq` in `Theorems/DiscreteUnfolding.lean`
- [x] Optional: rename local hypothesis names (`h_swap`, `tf_swap`, ...) only where this clears a whole file of time-reversal `swap`s. Otherwise leave them, since they are not API.
- [x] Run `lake build` (guarded/detached) and fix any residual breakage
- [x] Run the regression grep: `grep -rnwE 'swapUS|swapUS_involutive|truth_swap|swap_norm|MinusFrame\.swap|Encoding\.swap|plusValidIn_swap_of_tm[a-z_]*|cValid_swap_of_tm[a-z_]*|naiveAxiom_cValid_swap|naive_cValid_and_swap|starValid_[a-z0-9_]+_swap|swap_next_all_future_eq' FormalSystem Tests --exclude-dir=Boneyard`. It must return nothing.
- [x] Check byte stability: `git diff` shows no change to any line in `Automation/ContrastiveGeneratorMain.lean` or any other string literal that carries a wire tag

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch (the `register_simp_attr` rename and the cross-file lemma renames leave the build red between files)

**Scope Hypothesis**: 18 files in `FormalSystem/`, taken from the research grep: TruthNormAttr, Formula, Soundness, FrameClassVariants, TruthTransport, Atomization, AxiomValidity, Plus, Conservativity, CoarsenedModels, StarAxiomValidity, StarLanguage/Axioms, Dual, Lemma5, TruthTransfer, NoGaps, MinusFrame, SpCountermodel, Semantics and DiscreteUnfolding. That comes to about 250 occurrences. Before editing, the implementer confirms this list by rerunning the regression grep above without `-q`. A test file or typst file that references a renamed identifier would be a scope surprise. Research found none.

**Files to modify**:
- The files named in the Scope Hypothesis: identifier renames plus the docstring lines that name the renamed identifier

**Verification**:
- `lake build` succeeds with no new warnings, sorries or axioms
- The regression grep returns empty
- The wire-tag lines are unchanged
- Commit: `task 621 phase 2: rename time-reversal swap identifiers to reflect`

---

### Phase 3: Lean prose sweep [COMPLETED]

**Goal**: Reword the Lean docstrings and comments where "swap" or "temporal duality" names time
reflection. Leave exchange-sense uses alone.

**Tasks**:
- [x] `Semantics/MinusLanguage/MinusFrame.lean`:
  - Reword l.65-70.
  - Delete the justification at l.92-94 ("`swap` in its name is the frame operation").
  - At l.168 and l.292-299, cite `lem:time-reflection`. The KNOWN-ANCHORS row from Phase 1 is required for this.
  - Change "swap-strengthened" to "reflection-strengthened".
  - In "`no_max`/`no_min` swap roles", change "swap" to "exchange".
- [x] `Metalogic/SoundnessLemmas/FrameClassVariants.lean` (the densest file):
  - "swap-validity" becomes "reflection-validity".
  - "swapped axioms" becomes "reflected axioms".
  - "temporal-duality soundness" becomes "time-reflection soundness".
  - The `swap φ` notation in comments becomes `φ.reflectTime`.
- [x] Apply the same test to the remaining files in the inventory: `Syntax/Formula.lean`, `Metalogic/Soundness.lean` (l.71, l.202), `Syntax/MinusLanguage/Formula.lean:179-190`, `Syntax/StarLanguage/{Formula,Axioms}.lean`, `Conservativity/Plus/{Atomization,AxiomValidity,PlusSoundness}.lean`, `Conservativity/{Plus,Star}.lean`, `Conservativity/Star/{StarAxiomValidity,StarPasting}.lean`, `Conservativity/MinusLanguageSoundness.lean:417-438`, `Conservativity/SpCountermodel.lean:187`, `Deterministic/Soundness.lean:36-40`, `Semantics/Truth.lean:131`, `SoundnessLemmas.lean:25`, `Bundle/WitnessSeed.lean:168`, `Algebraic/LindenbaumQuotient.lean:336`, `Core/MCSProperties.lean:291-295`, `Theorems/Perpetuity.lean:54-55`, `Perpetuity/{Principles,Helpers}.lean`, `GeneralizedNecessitation.lean:116-124`, `ProofSystem/Derivation.lean:149`, `Syntax/PlusLanguage/Substitution.lean:40,124`, `Automation/FormulaEnumerator.lean:991`
- [x] Leave the exchange-sense files on the research keep-list untouched (Propositional/{Core,Connectives}, MixedSum, TemporalGate, Kamp/EFGames/MintBound, BXCanonical, and the others listed)
- [x] Test comment blocks: `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean:20-117`, `Integration/ProofSystemSemanticsTest.lean:25,265`, `ProofSystem/DerivationTest.lean:166-172`, `Automation/TacticsTest.lean:374`. Do not touch the `"Temporal duality"` benchmark label in `DerivationBenchmark.lean`.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: This phase covers about 30 Lean files, taken from the research prose inventory. Confirm the list with `grep -rniE 'swap|temporal[- ]duality' FormalSystem Tests --include=*.lean`, then classify each hit by the time-reversal test before editing. A hit that is neither in the inventory nor on the keep-list gets classified on the spot.

**Files to modify**:
- The Lean files listed above: comments and docstrings only, with no code changes

**Verification**:
- `grep -rniE 'temporal[- ]duality (lemma|soundness)|lem:temporal-duality' FormalSystem Tests` returns only deliberate carve-outs, such as the benchmark label
- `bash scripts/check-module-invariants.sh` exits 0 (C15 resolves every `lem:time-reflection` citation)
- `lake build` succeeds for the touched modules (a docstring-only edit, but confirm)
- Commit: `task 621 phase 3: reflect terminology in Lean prose`

---

### Phase 4: READMEs, docs, typst, and style-guide rule [COMPLETED]

**Goal**: Bring the non-Lean prose in line with the new names and the principle, and make the
naming rule durable in the style guide.

**Tasks**:
- [x] READMEs:
  - `FormalSystem/ProofSystem/README.md:72`: change `⊢ swap(φ)` to `⊢ φ.reflectTime`.
  - `Metalogic/SoundnessLemmas/README.md:6,16,23`: change "swap-validity".
  - `Metalogic/Bundle/README.md:47-63`.
  - `Syntax/PlusLanguage/README.md:73`.
  - `Semantics/MinusLanguage/README.md:17`: change `truth_swap` to `truth_reflectTime`.
  - `Automation/README.md:82`: change `swap_norm` to `reflect_time_norm`.
- [x] Docs:
  - `docs/development/LEAN_STYLE_GUIDE.md:923-942`: fix the stale `φ.swap`/`swap_past_future_involution` example, and add a "Time-reversal naming" rule. The rule says `reflect`/`reflectTime`/`reflect_time` covers every operation that reverses time order, and `swap` is only for exchanges.
  - `docs/development/PROPERTY_TESTING_GUIDE.md:639-642`.
  - `docs/user-guide/examples.md:424`.
  - `docs/user-guide/architecture.md:53`.
  - Leave `docs/project-info/performance-targets.md` (the benchmark labels) and `CONTRIBUTING.md:166` (an example branch name) as they are.
- [x] `Tests/BimodalTest/Integration/COVERAGE.md:23`: change "Temporal duality soundness" to the time-reflection wording
- [x] Typst:
  - `typst/chapters/04-metalogic.typ:38`: change "*Temporal duality*: Past-future swap preserves validity" to "*Time reflection*: reflecting past and future preserves validity".
  - `typst/FormalFoundations.typ:1247`: classify "the swap is not in the algebra". If it means time reflection, reword it to "reflection".
- [x] Check that no typst file cites a renamed Lean identifier: `grep -rnwE 'truth_swap|swapUS|swap_norm' typst` must be empty

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: The files are the 6 READMEs, 4 docs files, 1 COVERAGE.md and 2 typst files from the research inventory. Confirm them with `grep -rniE 'swap|temporal[- ]duality' --include=*.md --include=*.typ FormalSystem docs typst Tests README.md`.

**Files to modify**:
- The READMEs, docs files, `COVERAGE.md` and typst files listed above

**Verification**:
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/typst-sync-check.sh` exits 0
- `typst compile` of the main document succeeds if the sync check does not already cover it
- Commit: `task 621 phase 4: reflect terminology in READMEs, docs, typst`

---

### Phase 5: Final gates and regression sweep [COMPLETED]

**Goal**: Confirm that the whole task is green and the renames are complete.

**Tasks**:
- [x] Run `bash scripts/check-paper-definitions.sh`. Expected result: exit 0, case (b).
- [x] Run `bash scripts/check-module-invariants.sh`. Also run it with `--emit-inventory` and update the README inventories if any line counts moved.
- [x] Run `bash scripts/readme-lint.sh` and `bash scripts/typst-sync-check.sh`
- [x] Run a full `lake build` (guarded/detached) and require zero errors
- [x] Run the Phase 2 regression grep over `FormalSystem Tests docs typst README.md`, excluding the record. It must return empty.
- [x] Byte-stability check: `git diff <pre-task-sha> -- FormalSystem/Automation/ContrastiveGeneratorMain.lean` shows no wire-tag changes. Also run `grep -rn '"[^"]*reflect_time[^"]*"' FormalSystem`, which must return no new literals.
- [x] Check that no deliverable outside `specs/**` mentions a task number (`scripts/check-task-references.sh` or equivalent)

**Timing**: 0.5 hours

**Depends on**: 3, 4

**Verification Tier**: full

**Files to modify**:
- README inventories only, if `--emit-inventory` reports drift

**Verification**:
- All the gates above exit 0
- Commit: `task 621 phase 5: final gates` (skip it if nothing changed)

## Testing & Validation

- [ ] `lake build` green, with no new sorry or axiom
- [ ] `check-paper-definitions.sh` exits 0 (case b, no re-pin)
- [ ] `check-module-invariants.sh` exits 0, with C15 resolving `lem:time-reflection`
- [ ] `readme-lint.sh` and `typst-sync-check.sh` exit 0
- [ ] The regression grep for old identifiers is empty outside the record
- [ ] The wire tags and `*SwapCount` fields are byte-identical to the pre-task state

## Artifacts & Outputs

- Updated `docs/reference/paper-definitions-of-record.md` (carve-out retired, rename map, KNOWN-ANCHORS row)
- Renamed Lean identifiers across about 18 `FormalSystem/` files
- Reworded Lean prose, READMEs, docs, typst and test comments
- A time-reversal naming rule in `docs/development/LEAN_STYLE_GUIDE.md`
- `specs/621_adopt_uniform_reflect_naming_for_time_reversal/summaries/01_uniform-reflect-naming-summary.md`

## Rollback/Contingency

Each phase is its own commit. If Phase 2's batch cannot reach a green build, return to the
`--no-revert` checkpoint taken at its start. For a genuine rollback, use the reverting snapshot
per `context/contracts/recovery.md`. Then redo the batch one family at a time, starting with
`swap_norm` plus its users, and building after each family. Phases 1, 3 and 4 are prose-only, so
reverting one of them is a single `git revert` of that phase's commit. If C15 goes red because a
citation landed before the anchor row, add the row. Do not fall back to plain-prose wording
unless the row is rejected.
