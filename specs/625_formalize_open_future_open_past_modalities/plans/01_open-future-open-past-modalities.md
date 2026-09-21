# Implementation Plan: Task #625

- **Task**: 625 - Formalize the manuscript's open-future and open-past modalities and machine-check that the stability modal is NOT Ockhamist historical necessity while the open-future modality is
- **Status**: [IMPLEMENTING]
- **Effort**: 12.5 hours
- **Dependencies**: 638 (completed; its module split and the earlier language-extension merge are the tree this plan targets). Related, not blocking: 559, 624
- **Research Inputs**: specs/625_formalize_open_future_open_past_modalities/reports/01_open-future-open-past-modalities.md; probes `probes/01_sink-frame-hn-refutation.lean` and `probes/02_frame-reversal.lean` (both re-compiled green at plan time against the relocated tree, see Research Integration)
- **Artifacts**: plans/01_open-future-open-past-modalities.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The manuscript's subsection *Restricted Modalities* defines three restricted modals over the
constructed possible worlds: stability over `⟨τ⟩_x`, the open-future operator over `|τ⟩_x`, and the
open-past operator over `⟨τ|_x`. Only stability is formalized. This plan lands a fifth object
language, **L^▷ = L⁺ + `ofut` + `opast`**, as a self-contained component at
`FormalSystem/OpenLanguage/`, and proves in the library that the Ockhamist principle
`Pα → ▷P▷̂α` is valid for the open-future operator over every task frame while its stability
transposition `Pp → ⊡P⟐p` is refuted on a concrete three-state integer-time frame that satisfies
every field of the live `FrameOver` structure. Definition of done: the 31 theorems of
`## Lean Challenge Statements` proved sorry-free, `lake build FormalSystem` green at the end of
every phase, the headline theorems axiom-pinned in both C14 lists, and the full invariant gate
(`scripts/check-module-invariants.sh`, `scripts/check-metalogic-cycles.sh`) green.

### Research Integration

- **The relations already exist**: `AgreeUpTo` / `AgreeFrom` / `paste` with their monotonicity and
  paste lemmas live in `FormalSystem/PlusLanguage/PlusPasting.lean`. They are reused, never
  redefined. **Post-relocation correction to the report**: they are now in namespace
  `FormalSystem.PlusLanguage` (the report says `FormalSystem.Semantics.AgreeUpTo`), and every
  `FormalSystem.Semantics.PlusLanguage.*` import path in the report and probes is now
  `FormalSystem.PlusLanguage.*`.
- **The refutation frame is one call**: `FrameOver.ofStep` (`Semantics/IntNormalForm.lean`)
  discharges `comp`, `serial`, `limit` and `saturation` (the last through `saturation_of_finite`)
  from a bi-serial one-step relation on a finite nonempty carrier. The frame **must be an
  `abbrev`**; `deriving Fintype` is unavailable, a hand instance works.
- **The time reversal is cheap and compiled**: probe 02's `rev : FrameOver D → FrameOver D` with all
  four axiom fields, `rev (rev F) = F` by `rfl`, `revHist`, and
  `AgreeUpTo τ σ t ↔ AgreeFrom (revHist τ) (revHist σ) (-t)`. `TruthAntiIso` cannot serve a
  `stab`-like clause (atom-level agreement only).
- **Plan-time re-verification**: both probes were re-compiled with `lake env lean` after rewriting
  the import paths. Probe 01 is green unchanged. Probe 02 is green once
  `open FormalSystem.PlusLanguage` is added (without it `AgreeUpTo` is auto-bound as an implicit
  variable and the file fails at the `intro` in `agreeUpTo_rev`). The whole
  `## Lean Challenge Statements` block below was also type-checked standalone against the live
  tree (exit 0, only `sorry` warnings).
- **Extension contracts**: `Semantics/TruthClauses.lean` (`TruthEnv`, `StabClauses`) and
  `Semantics/ValidityLayer.lean` (`PointTruth`) buy every derived-operator clause lemma and all
  validity notions from three instances whose fields are `Iff.rfl` / `fun h => h`.

### Decisions (argued, recorded here as the dispatch requires)

**D1 — extension language, not semantic operators.** Adopted from the report's argued
recommendation. Semantic operators on truth sets are roughly 150 lines cheaper, but under them
deliverable (3) is a meta-level schema over `M` and `φ` rather than a validity of a formula and a
`¬ Valid` refutation, the Ockhamist consequent `P▷̂α` needs the tense clauses rebuilt as set
operators, and deliverable (4) still needs a reversal transport induction that the tree does not
have. The extension language is the cheaper option *that still lets (3) be stated as a validity and
a refutation*, which is the dispatch's selection criterion. No constructor is added to
`PlusFormula`, `PlusAxiom` or `PlusDerivationTree`.

**D2 — the component follows the post-merge layout convention: `FormalSystem/OpenLanguage/`,
sibling aggregator `FormalSystem/OpenLanguage.lean`, flat namespace `FormalSystem.OpenLanguage`.**
This departs from the task's original siting line and from its `file_scope`, both written before
the language-extension merge. Reasons:

1. After the merge no object language lives under `Semantics/`. Siting a new formula inductive at
   `Semantics/OpenLanguage/` would recreate, for one language, exactly the split layout the merge
   abolished, and `Semantics` is layer 1 by directory, so the syntax file could not be layer 0.
2. Every *property* the original siting line asks for holds at the library root: the component
   imports `Semantics/Truth.lean` and sits strictly downstream of it, so the `assert_not_exists`
   guards upstream are untouched; C8 walks `FormalSystem/` as a parent, so "one directory with one
   sibling aggregator" is enforced there; the generated root `FormalSystem.lean` (C33) puts every
   module in the root closure (C24).
3. The component's real dependencies are language-to-language (`PlusLanguage.PlusPasting`,
   `PlusLanguage.PlusNonValidities`), the same shape as `StarLanguage → PlusLanguage`.
4. File naming follows the siblings: the syntax file is the unprefixed `Formula.lean`, the semantic
   files carry the `Open` prefix.

Costs, all planned below: a `LANGUAGE_FILE_LAYERS["OpenLanguage"]` table in
`scripts/measure-refactor-partitions.py` (without it `layer_of` raises and assertion B of
`scripts/check-metalogic-cycles.sh` fails), a one-sentence extension of that table's layering rule
for files born after the merge (they have no pre-merge origin directory: a syntax file takes 0, a
semantic file takes 1, which is what assertion C already enforces), and prose listings that name
"the three language directories". L^▷ has no proof system; that is recorded, not hidden — the
repository README already describes a language as "semantic only; no proof system".

**`file_scope` is stale under D2.** The task's `file_scope` in `specs/state.json` names
`FormalSystem/Semantics/OpenLanguage*` paths. The planner cannot amend it
(`proposed_file_scope` is a research-only field). The live scope is the per-phase **Files to
modify** lists below; the implementer should stage explicit file lists only, and a snapshot-guarded
rollback would need the out-of-scope override described in `context/contracts/recovery.md`.

**D3 — the frame reversal stays inside the component** as `OpenLanguage/OpenReversal.lean`, although
`FrameOver.rev` itself is language-independent. The task asks for one directory; the module
docstring records that the frame-level half may be promoted to `Semantics/` by a later task.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and the roadmap flag is unset, so no roadmap
phases are added. A read-only scan of `specs/ROADMAP.md` finds one adjacent row, the TM⋆
completeness programme (537, 559, 560, 561); this task feeds it by fixing, as library theorems, the
distinction two of its research rounds got wrong.

## Goals & Non-Goals

**Goals**:
- Deliverable (1), the three history classes, each the class of an explicit equivalence:
  `sameState_equivalence`, `agreeUpTo_equivalence`, `agreeFrom_equivalence`,
  `openFutureClass_subset_stabClass`, `openPastClass_subset_stabClass`,
  `openFutureClass_inter_openPastClass`, `openFutureClass_anti`, `openPastClass_mono`.
- Deliverable (2), the truth clauses and conservativity over the stability language:
  `openTruthAt_ofPlus`, `openValid_ofPlus_iff`.
- Deliverable (3), the separating pair: `hnOpen_openValid`, `hnOpenMixed_openValid`,
  `hnStab_refuted_sinkFrame`, `not_openValid_hnStab`.
- Deliverable (4), the time-reversal mirror: `openValid_reflectTime`, `hnOpenMirror_openValid`,
  `not_openValid_hnStabMirror`.
- Deliverable (5), S5 for each operator: `openValid_ofut_t`, `openValid_ofut_four`,
  `openValid_ofut_five`, `openValid_opast_t`, `openValid_opast_four`, `openValid_opast_five`.
- Deliverable (5), the strength ordering and the failure of each converse:
  `openValid_stab_of_box`, `openValid_ofut_of_stab`, `openValid_opast_of_stab`,
  `not_openValid_box_of_stab`, `not_openValid_stab_of_ofut`, `not_openValid_stab_of_opast`,
  `not_openValid_opast_of_ofut`, `not_openValid_ofut_of_opast`.

**Supporting declarations (delivered, but not challenge identifiers)**:
- Carriers, written out in full in the challenge preamble: the inductive `OpenFormula` with
  `ofPlus`, `reflectTime` and the derived operators; `stabClass`, `openFutureClass`,
  `openPastClass`; `OpenTruthAt`; `TaskFrame.OpenValidOn`, `OpenValidOnFrames`, `OpenValidIn`,
  `OpenValid`; `hnOpen`, `hnOpenMixed`, `hnStab`, `hnOpenMirror`, `hnStabMirror`; `SinkState`,
  `sinkFrame`.
- Machinery: `reflect_time_involution`, `ofPlus_reflectTime`; the instances `TruthEnv`,
  `StabClauses`, `PointTruth` for `OpenFormula`; the `OpenTruth.*` clause lemmas (`ofut_iff`,
  `opast_iff`, `dofut_iff`, `dopast_iff`) and the pointwise S5 / ordering lemmas including K;
  `FrameOver.rev`, `TaskFrame.rev`, `TaskModel.rev`, `WorldHistory.rev`, `openTruthAt_rev`,
  `openValidOn_rev_iff`; `sinkHistA`, `sinkHistB`, `sinkModel`.
- Registration: layer-table rows, generated root, READMEs, C14 axiom pins, `rfl` coincidence pins
  and an axiom-profile test.

**Non-Goals**:
- Any axiomatization, soundness or completeness claim for `▷` / `◁`.
- The nomic operator and the world registers. Both, together with the axiomatization, are recorded
  in the aggregator's module docstring as manuscript operators without a formalization, quoting the
  manuscript's "I will omit further consideration of the restricted modals".
- Any new constructor in `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`, and any edit to an
  existing Lean module other than the generated root.
- Reversal-invariance of validity over the restricted frame classes (`Dense`, `ZTime`, `RTime`);
  `openValid_reflectTime` is stated at the unconstrained class only.
- Promoting `FrameOver.rev` to `Semantics/` (D3).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `rev`-level bookkeeping in `openValid_reflectTime`: `F.rev.rev = F` and `M.rev.rev = M` are `rfl`, `τ.rev.rev = τ` is propositional | M | M | Prove `openValidOn_rev_iff` first via `(openTruthAt_rev ..).mp (h M.rev τ.rev (-t))` then `rwa [rev_rev_hist, neg_neg]` with a `show` to align the frame. Fallback (Phase 7): hand-mirror each open-past theorem, 3-8 lines apiece, the `PlusSoundness` pattern |
| Report and probes cite pre-merge module paths and the wrong namespace for `AgreeUpTo` | M | H (certain) | Corrected in Research Integration; every phase lists post-merge imports. Probe 02 needs `open FormalSystem.PlusLanguage` |
| `sinkFrame` declared with `def` leaves `sinkFrame.WorldState` unreduced; numerals on `NF` need `(0 : ℕ)` annotations | M | M | `abbrev`, as probed; copy probe 01's annotations |
| New directory invisible to, or rejected by, the layer check | H | H if skipped | Phase 1 adds the `LANGUAGE_FILE_LAYERS["OpenLanguage"]` table and every later phase adds its own row in the same commit as the file; `bash scripts/check-metalogic-cycles.sh` is a per-phase gate |
| Generated root drift (C33) | M | M | Run `lake exe mk_all --lib FormalSystem` in every phase that adds a module; never hand-edit `FormalSystem.lean` |
| Warning budget (C28) under the Mathlib standard linter set; dead-declaration scan (C17); naming gates C23 (no `lemma`, no `Uppercase_x`) and C26 (no non-trailing underscore in a `def`/`abbrev` name) | M | M | New files compile warning-free; every declaration is named in the component README; definitions use camelCase, theorems snake_case |
| C15 anchor resolution and C9 task-number ban in docstrings | M | L | Cite only recorded anchors (`lem:time-reflection`, `def:frame`, `def:world-history`, `app:gluing`, `def:BLstar-semantics`); `sub:RestrictedModalities` is ungated (C15 scans `def|thm|lem|cor|app|rmk` only). Never a line number, never a task number. `## References` in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md` |
| Concurrent sessions editing shared registration files (`scripts/measure-refactor-partitions.py`, `ORGANISATION.md`, `FormalSystem/README.md`, `scripts/check-module-invariants.sh`) | M | M | Re-read each shared file immediately before editing; stage explicit file lists only (never a directory pathspec); registration edits are additive single rows |
| The snapshot tool compares a locale-sorted Goals list with a codepoint-sorted declaration list; names that the two orders rank differently (an uppercase letter against an underscore, e.g. `fooPast_x` beside `foo_x`) produce a spurious identifier-set mismatch (exit 71) under `en_US.UTF-8` | M | L | The 31 challenge names were chosen so `LC_ALL=C sort` and `LC_ALL=en_US.UTF-8 sort` agree (hence `hnOpenMirror`, `hnStabMirror`, `hnStab_refuted_sinkFrame`); `lean-challenge-snapshot.sh 625 . --dry-run` exits 0 in the default locale at plan time. Do not rename a challenge identifier without re-running that dry run |
| Challenge-module fidelity: the snapshot tool forces every `def`/`theorem` body to `sorry` and drops all text between a declaration's `:=` and the next declaration | L | L | The challenge block keeps every carrier in the preamble as `inductive`/`abbrev` (neither is matched), uses no dotted declaration names and no namespace switch after the first theorem; see the note in that section |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. The plan is fully sequential on purpose:
Phases 5 and 6 are logically independent of each other, but every module-adding phase edits the
same three registration files (the aggregator, the per-file layer table, the generated root), so
running two of them in one working tree at once would collide.

**Gate that closes every phase** (tiering below governs in-phase granularity only):

```bash
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem   # *(deviation: altered — the guard requires a lake subcommand as its first lake argument; the original `-- FormalSystem` exits 77 before any build is attempted, and piping it through `tail` masks that as exit 0)*
grep -rn "sorry" FormalSystem/OpenLanguage FormalSystem/OpenLanguage.lean          # must print nothing
lake exe mk_all --lib FormalSystem --check                                          # C33
bash scripts/check-metalogic-cycles.sh                                              # assertions A, B, C
```

then one commit, `task 625 phase {P}: {name}`, staging an explicit file list.

### Phase 1: Component scaffold and the three history classes [COMPLETED]

**Goal**: Create the `OpenLanguage` component so that it is layered, aggregated and in the root
closure from its first commit, and land deliverable (1).

**Tasks**:
- [x] Create `FormalSystem/OpenLanguage/OpenClasses.lean`, first `namespace FormalSystem.OpenLanguage`,
  importing `FormalSystem.PlusLanguage.PlusPasting`, opening `FormalSystem.Semantics` and
  `FormalSystem.PlusLanguage`. Declare `stabClass`, `openFutureClass`, `openPastClass` as
  `def … : Set (WorldHistory F)` with the bodies fixed in the challenge preamble, and
  `mem_stabClass_iff` / `mem_openFutureClass_iff` / `mem_openPastClass_iff` by `Iff.rfl`.
- [x] Prove the three `Equivalence` theorems (`sameState_equivalence`, `agreeUpTo_equivalence`,
  `agreeFrom_equivalence`); these are what make each class "an equivalence class of an explicit
  relation".
- [x] Prove the inclusions `openFutureClass_subset_stabClass` (`hag x le_rfl`),
  `openPastClass_subset_stabClass`, and `stabClass_subset_univ` (the type `WorldHistory F` is
  `H_F`); the intersection `openFutureClass_inter_openPastClass` (`WorldHistory.ext_state` plus
  `le_total`); `openFutureClass_anti` and `openPastClass_mono` from `agreeUpTo_mono` /
  `agreeFrom_mono` — the manuscript's "moving forward in time narrows the open futures and widens
  the open pasts".
- [x] Optional, if under 15 lines: `paste_mem_openFutureClass_inter_openPastClass`, the two-way
  pasting of `app:gluing` (`paste τ σ x h ∈ openFutureClass τ x ∩ openPastClass σ x`). *(deviation: altered — `app:gluing` had no row in `docs/reference/paper-definitions-of-record.md`, so a `LIVE-UNPINNED` KNOWN-ANCHORS row was added in this phase, before the citation, as C15 requires; that file was planned for Phase 8 only)*
- [x] Create the aggregator `FormalSystem/OpenLanguage.lean` with the component's module docstring:
  the grammar of L^▷, the module list, decisions D1-D3 in durable wording (no task numbers), the
  three manuscript operators without a formalization (nomic operator, world registers, any
  axiomatization or completeness claim), and a `## References` block in normal form.
- [x] Create `FormalSystem/OpenLanguage/README.md` modelled on `FormalSystem/StarLanguage/README.md`,
  with a `<!-- BEGIN GENERATED: inventory dir=FormalSystem/OpenLanguage -->` block and a
  "Paper-label correspondence" table started with the class rows.
- [x] Add `"OpenLanguage": {"OpenClasses": 1}` to `LANGUAGE_FILE_LAYERS` in
  `scripts/measure-refactor-partitions.py` and extend the rule comment above the table with one
  sentence: a file created after the merge has no origin directory and takes the layer of the
  directory it would have occupied (`Syntax/<Lang>/` → 0, `Semantics/<Lang>/` → 1).
- [x] Regenerate the root with `lake exe mk_all --lib FormalSystem`; run
  `bash scripts/check-module-invariants.sh --emit-inventory` and replace the
  `<!-- TODO: add description -->` cells it creates for the new rows. *(deviation: altered — the emitter also rewrote the totals block of the repository-root `README.md`, which carries another session's uncommitted hunks; it is left unstaged here, under-staging rather than sweeping foreign edits into this commit)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: The only mechanical consumers of the language-directory list are
`LANGUAGE_FILE_LAYERS` (read by `layer_of`, `stale_language_rows` and assertions B and C) and C8's
parent walk, which already covers `FormalSystem/`. Confirm with
`grep -n "LANGUAGE_FILE_LAYERS\|StarLanguage" scripts/*.sh scripts/*.py scripts/lib/*.py`; any
other hard-coded tuple of the three directory names found there is added to this phase.

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenClasses.lean` - new; deliverable (1)
- `FormalSystem/OpenLanguage.lean` - new; sibling aggregator and component docstring
- `FormalSystem/OpenLanguage/README.md` - new; inventory block and correspondence table
- `scripts/measure-refactor-partitions.py` - per-file layer table and rule comment
- `FormalSystem.lean` - regenerated, never hand-edited
- `FormalSystem/README.md` - generated inventory rows, descriptions filled in

**Verification**:
- `lake build FormalSystem.OpenLanguage` green and warning-free
- `bash scripts/check-metalogic-cycles.sh` exits 0 (no `UnlayeredModuleError`, no stale row)
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- The phase-closing gate above

---

### Phase 2: The syntax of L^▷ [COMPLETED]

**Goal**: `OpenFormula` as a layer-0 syntax file with the embedding of L⁺ and the time reflection.

**Tasks**:
- [x] Create `FormalSystem/OpenLanguage/Formula.lean`, importing **only**
  `FormalSystem.PlusLanguage.Formula` (nothing under `FormalSystem/Semantics/`, no `Open*` file —
  assertion C). Nine constructors in the challenge preamble's order, with docstrings;
  `deriving Repr, DecidableEq, Countable` as `PlusFormula` does.
- [x] Inside `namespace OpenFormula`, the derived operators **character for character** with
  `PlusFormula`'s right-hand sides (`top`, `neg`, `someFuture`, `somePast`, `allFuture`, `allPast`,
  `and`, `or`, `iff`, `diamond`, `always`, `sometimes`, `dstab`), so that the `TruthClauses` lemmas
  are inherited without `show`; plus `dofut φ := neg (.ofut (neg φ))` and `dopast`.
- [x] `ofPlus : PlusFormula → OpenFormula`, constructor to constructor; `ofPlus_injective`; the `rfl`
  commutation pins of `ofPlus` with each derived operator.
- [x] `reflectTime` (swap `untl`/`snce` and `ofut`/`opast`; fix `atom`, `bot`, `stab`; distribute
  through `imp`, `box`), `reflect_time_involution` (the tree's spelling), `ofPlus_reflectTime`, and
  `rfl`-level simp lemmas `reflect_time_somePast`, `reflect_time_someFuture`, `reflect_time_dofut`,
  `reflect_time_dopast`, `reflect_time_dstab`.
- [x] Add `"Formula": 0` to the `OpenLanguage` layer table, the import to the aggregator, the README
  row; regenerate the root.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/OpenLanguage/Formula.lean` - new
- `FormalSystem/OpenLanguage.lean`, `FormalSystem/OpenLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean` - registration

**Verification**:
- `lake build FormalSystem.OpenLanguage.Formula` green and warning-free
- `grep -n "^import" FormalSystem/OpenLanguage/Formula.lean` shows one line
- The phase-closing gate

---

### Phase 3: The truth recursion [COMPLETED]

**Goal**: Deliverable (2)'s truth clauses, the clause-layer instances, truth-level conservativity
over L⁺, and the pointwise S5 and ordering facts.

**Tasks**:
- [x] Create `FormalSystem/OpenLanguage/OpenTruth.lean` importing `FormalSystem.Semantics.Truth`,
  `FormalSystem.Semantics.TruthClauses`, `FormalSystem.OpenLanguage.Formula`,
  `FormalSystem.OpenLanguage.OpenClasses` (which brings `PlusLanguage.PlusPasting`). Define `OpenTruthAt` with the nine clauses of the
  challenge preamble: seven verbatim from `PlusTruthAt`, plus
  `.ofut φ => ∀ σ, AgreeUpTo τ σ t → OpenTruthAt M σ t φ` and
  `.opast φ => ∀ σ, AgreeFrom τ σ t → OpenTruthAt M σ t φ`. The docstring quotes the manuscript's
  two clauses by phrase and names `|τ⟩_x` / `⟨τ|_x`.
- [x] `instance : TruthEnv OpenFormula` and `instance : StabClauses OpenFormula`, every clause field
  `Iff.rfl` or `fun h => h`, mirroring `PlusTruth.lean`.
- [x] `namespace OpenTruth`: `atom_iff`, `ofut_iff`, `opast_iff` (`Iff.rfl`), `dofut_iff`,
  `dopast_iff` (the `dstab_iff` argument), and one-line re-exports of the inherited lemmas the later
  phases use (`somePast_iff`, `someFuture_iff`, `dstab_iff`, `stab_iff`).
- [x] `openTruthAt_ofPlus` by `induction φ generalizing τ t`, seven `Iff.rfl`-shaped cases, the
  `plusTruthAt_ofFormula` pattern.
- [x] Pointwise modal facts: `of_ofut`, `ofut_four`, `ofut_five`, `ofut_k`, the four `opast`
  mirrors, and the ordering `stab_of_box`, `ofut_of_stab`, `opast_of_stab`. Each is two to four
  lines from the `refl` / `symm` / `trans` fields of `agreeUpTo_equivalence` and
  `agreeFrom_equivalence`, which is why this module imports `OpenClasses`.
- [x] Add `"OpenTruth": 1`, the aggregator import, the README row; regenerate the root.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenTruth.lean` - new
- `FormalSystem/OpenLanguage.lean`, `FormalSystem/OpenLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean` - registration

**Verification**:
- `lake build FormalSystem.OpenLanguage.OpenTruth` green and warning-free
- Every field of the two instances is `Iff.rfl` or `fun h => h` (a `show` there means a derived
  operator was not encoded character for character — fix the encoding, not the proof)
- The phase-closing gate

---

### Phase 4: Validity, conservativity, S5 and the strength ordering [COMPLETED]

**Goal**: The validity layer for L^▷, conservativity over L⁺ at every validity notion, and the
positive half of deliverable (5).

**Tasks**:
- [x] Create `FormalSystem/OpenLanguage/OpenValidity.lean` on the `PlusValidity.lean` template:
  `instance : PointTruth OpenFormula`; then, in a `namespace FormalSystem.Semantics` block,
  `def TaskFrame.OpenValidOn`; back in `FormalSystem.OpenLanguage`, `OpenValidOnFrames`,
  `OpenValidIn`, `OpenValid`. **Own `def`s, never `abbrev`, bodies never delegating to
  `Generic*`** — only theorem bodies delegate. The file's *first* `namespace` must be
  `FormalSystem.OpenLanguage`.
- [x] `OpenValidOnFrames.mono`, `OpenValidIn.mono`, `OpenValid.of_forall`, `OpenValid.apply`,
  `OpenValid.of_not`, delegating to the generic layer.
- [x] Conservativity: `openValidOn_ofPlus_iff`, `openValidOnFrames_ofPlus_iff`,
  `openValidIn_ofPlus_iff`, `openValid_ofPlus_iff`, from `openTruthAt_ofPlus`.
- [x] S5 as validities: `openValid_ofut_k`, `openValid_ofut_t`, `openValid_ofut_four`,
  `openValid_ofut_five` and the four `opast` mirrors, each `OpenValid.of_forall` over the Phase 3
  pointwise lemma.
- [x] Ordering as validities: `openValid_stab_of_box`, `openValid_ofut_of_stab`,
  `openValid_opast_of_stab`.
- [x] Add `"OpenValidity": 1`, the aggregator import, the README row; regenerate the root.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenValidity.lean` - new
- `FormalSystem/OpenLanguage.lean`, `FormalSystem/OpenLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean` - registration

**Verification**:
- `lake build FormalSystem.OpenLanguage.OpenValidity` green and warning-free
- `example : TaskFrame.OpenValidOn F φ = TaskFrame.GenericValidOn F φ := rfl` elaborates in a
  scratch file (the pin itself lands in Phase 8)
- The phase-closing gate

---

### Phase 5: Time reversal of frames, histories and truth [COMPLETED]

**Goal**: Deliverable (4)'s machinery: the manuscript's converse frame of `lem:time-reflection`,
built semantically, and the one transport theorem that turns every open-future validity into an
open-past validity.

**Tasks**:
- [x] Create `FormalSystem/OpenLanguage/OpenReversal.lean` importing `OpenValidity`. First
  `namespace FormalSystem.OpenLanguage`; declare the dot-notation targets either with a
  `_root_.FormalSystem.Semantics.` prefix or in a later `namespace FormalSystem.Semantics` block (the
  `PlusValidity.lean` precedent).
- [x] Port probe 02: `FrameOver.rev` (`PosRel w x u := F.PosRel u x w`; `comp` via
  `F.comp v w y x` + `add_comm` with `show … reflect F.PosRel …` **before** `rw`; `serial` swaps the
  conjuncts; `limit` is `(F.limit u w h).symm`; `saturation` maps fibres and segments through
  `FrameOver.reflection` and reuses `F.saturation` on the same family). `rev_taskRel`
  (`Iff.rfl`), `rev_taskRel_neg` (the manuscript's `w ⇒⁻_x u := w ⇒_{-x} u`, by
  `FrameOver.reflection`), `rev_rev : F.rev.rev = F := rfl`.
- [x] `TaskFrame.rev F := ⟨F.Duration, F.toFibre.rev⟩` with `rev_rev` by `rfl`; `TaskModel.rev` (same
  valuation) with `rev_rev` by `rfl`; `WorldHistory.rev` via `WorldHistory.ofTotal` on
  `fun t => τ.state (-t)` (task obligation from `τ.respects_task (-t) (-s)` and `abel`);
  `rev_state`; `rev_rev_hist` by `WorldHistory.ext_state` + `neg_neg` (propositional, not `rfl`). If
  cheap, package `τ ↦ τ.rev` as an `Equiv` — the manuscript's bijection `H_F → H_{F⁻}`. *(deviation: altered — the optional `Equiv` packaging was not built; the bijection is carried by `WorldHistory.rev_rev_hist` together with `WorldHistory.rev_surjective`, which is the form every case of `openTruthAt_rev` consumes)*
- [x] Class swaps: `sameState_rev_iff`, `agreeUpTo_rev_iff : AgreeUpTo τ σ t ↔ AgreeFrom τ.rev σ.rev (-t)`,
  `agreeFrom_rev_iff` (`neg_le.mp`, `neg_le_neg`; `simpa` does **not** close `-t ≤ s ↔ -s ≤ t`;
  equalities under `rev F` need a `change` before `rwa [neg_neg]`).
- [x] `openTruthAt_rev : OpenTruthAt M τ t φ ↔ OpenTruthAt M.rev τ.rev (-t) φ.reflectTime`, nine
  cases: `box` uses surjectivity of `rev` on histories (`rev_rev_hist`), `untl`/`snce` negate the
  bounds as in `truthAt_of_truthAntiIso`, `stab` is `sameState_rev_iff`, `ofut`/`opast` are the
  agreement swaps.
- [x] `openValidOn_rev_iff : F.rev.OpenValidOn φ.reflectTime ↔ F.OpenValidOn φ`, then
  `openValid_reflectTime : OpenValid φ → OpenValid φ.reflectTime` (every `TaskFrame` is `G.rev` for
  `G := F.rev`, by `rev_rev`).
- [x] Add `"OpenReversal": 1`, the aggregator import, the README row (citing `lem:time-reflection`);
  regenerate the root.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenReversal.lean` - new
- `FormalSystem/OpenLanguage.lean`, `FormalSystem/OpenLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean` - registration

**Verification**:
- `lake build FormalSystem.OpenLanguage.OpenReversal` green and warning-free
- `example (F : FrameOver D) : F.rev.rev = F := rfl` elaborates
- If `openValid_reflectTime` is not closed inside the time box, the phase still closes green with
  `openTruthAt_rev` and `openValidOn_rev_iff` landed and **no `sorry`**: omit the theorem, record it
  in the phase notes, and Phase 7 takes the hand-mirror fallback
- The phase-closing gate

---

### Phase 6: The Ockhamist separating pair [COMPLETED]

**Goal**: Deliverable (3): the principle valid for `▷` over every task frame, its stability
transposition refuted on a frame with every `FrameOver` field discharged.

**Tasks**:
- [x] Create `FormalSystem/OpenLanguage/OpenOckhamist.lean` importing `OpenReversal`,
  `FormalSystem.Semantics.IntNormalForm`, `FormalSystem.PlusLanguage.PlusNonValidities`. Module
  docstring: on a tree "same moment" and "same past" coincide, on a task frame the present state
  fixes the alternatives and histories through a state share neither past nor future; the principle
  is Reynolds's interaction axiom and, given S5, equivalent to Thomason's AK12 — cite through
  existing `references.bib` keys only (C31), never an invented entry.
- [x] Formulas: `hnOpen`, `hnOpenMixed`, `hnStab`, with the bodies of the challenge preamble, and
  `hnStab_eq_ofPlus : hnStab p = ofPlus (…)` by `rfl`, so the refutation is visibly about an L⁺
  formula.
- [x] Validity: `hnOpen_openValid` (probe 01's `hn_open_pure`: the witness history is the original
  `σ`, agreement by `le_trans`), and `hnOpenMixed_openValid` either directly (probe 01's
  `hn_open_mixed`) or from `hnOpen_openValid` through `dofut → dstab`.
- [x] The frame: `SinkState` (`a | b | c`, hand `Fintype`, `Nonempty`), `abbrev sinkFrame :
  FrameOver intOrder := FrameOver.ofStep (fun x y => x = y ∨ y = SinkState.c) …`; step paths and
  `sinkHistA`, `sinkHistB` through `worldHistoryOfStepPath` (`a` resp. `b` before time 0, `c` from 0
  on); `sinkModel` with `p` true at `a` only.
- [x] Refutation: `hnStab_refuted_sinkFrame : ¬ sinkFrame.toTaskFrame.OpenValidOn (hnStab p)` (port
  probe 01's `hn_stab_refuted`, closing with `simp` on the constructor disequality);
  `not_openValid_hnStab`; and the L⁺-level `not_plusValid_hnStab` through `openValid_ofPlus_iff`.
- [x] Add `"OpenOckhamist": 1`, the aggregator import, the README rows; register `sinkFrame` in the
  linked census of `FormalSystem/Semantics/Frames/README.md`; regenerate the root. *(deviation: altered — the linked census is in the module docstring of `Semantics/Frames/Standard.lean`, not in that README; editing an existing Lean module is a plan non-goal and would invalidate its importers' oleans, so the row landed in the README under a new subsection "Frames built in other components" that points at the census)*

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenOckhamist.lean` - new
- `FormalSystem/Semantics/Frames/README.md` - census row for `sinkFrame`
- `FormalSystem/OpenLanguage.lean`, `FormalSystem/OpenLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean` - registration

**Verification**:
- `lake build FormalSystem.OpenLanguage.OpenOckhamist` green and warning-free
- **Measured profiles (phase note)**: `hnOpen_openValid`, `hnOpenMixed_openValid`, `hnStab_refuted_sinkFrame`, `not_openValid_hnStab`, `openValid_reflectTime`, `openTruthAt_rev` are all `[propext, Classical.choice, Quot.sound]`; `openValid_ofPlus_iff` is `[propext]`. The expectation below that `hnOpen_openValid` would be `[propext]`-class was wrong: `dofut_iff` uses `by_contra`, as the inherited `dstab_iff` does. Pin the MEASURED values in Phase 8.
- `#print axioms` on `hnOpen_openValid` and `hnStab_refuted_sinkFrame` recorded in the phase notes for
  Phase 8 (expected `[propext]`-class and `[propext, Classical.choice, Quot.sound]` respectively —
  the `ofStep` route inherits `Classical.choice` from `saturation_of_finite`)
- The phase-closing gate

---

### Phase 7: The open-past mirror and the converse failures [COMPLETED]

**Goal**: Finish deliverables (4) and (5): the mirrored pair, and a countermodel for every converse
of the strength ordering, including the incomparability of `▷` and `◁`.

**Tasks**:
- [x] In `OpenOckhamist.lean`: `hnOpenMirror α := (hnOpen α).reflectTime`, `hnStabMirror p :=
  (hnStab p).reflectTime`, with `rfl` unfoldings showing them as `Fα → ◁F◁̂α` and `Fp → ⊡F⟐p`. *(deviation: altered — `hnOpenMirror α` unfolds by `rfl` to `Fα' → ◁F◁̂α'` at `α' := α.reflectTime`, not at `α` itself; the instance at an arbitrary `α` is the added one-line corollary `openValid_hnOpenPast`, by `reflect_time_involution`. Additive: no planned declaration was dropped or restated)*
- [x] `hnOpenMirror_openValid := openValid_reflectTime _ (hnOpen_openValid α)`;
  `not_openValid_hnStabMirror` by contraposition through `openValid_reflectTime` and
  `reflect_time_involution`. **Fallback** if Phase 5 did not land `openValid_reflectTime`: prove
  `hnOpenMirror_openValid` directly (mirror of `hn_open_pure` with `AgreeFrom`) and refute
  `hnStabMirror` on `sinkFrame.rev` directly or through `openValidOn_rev_iff`; then
  `openValid_reflectTime` moves to a recorded exclusion, which requires re-planning rather than a
  silent drop.
- [x] Converse failures on `NF` / `natModel` (valuation `n = 0`), each by `h.apply NF natModel
  (natHist fun _ => 0) 0` in the house style of `PlusNonValidities.lean`:
  `not_openValid_box_of_stab` (witness history constantly `1`);
  `not_openValid_stab_of_ofut` (probe 01's `open_not_stab`, witness `if s < 0 then 1 else 0`);
  `not_openValid_stab_of_opast` (time mirror, witness `if 0 < s then 1 else 0`);
  `not_openValid_opast_of_ofut` and `not_openValid_ofut_of_opast` (the same two witnesses: they
  agree with the constant history on one side of `0` only).
- [x] Transfer the five existing L⁺ refutations in one line each through `openValid_ofPlus_iff`
  (e.g. `refute_stab_box` yields `¬ OpenValid (ofPlus …)`), as a closing section.
- [x] Complete the component README's correspondence table: classes, clauses, inclusion /
  intersection / monotonicity sentences, `lem:time-reflection`, and the three excluded operators.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenOckhamist.lean` - mirror section and converse-failure section
- `FormalSystem/OpenLanguage/README.md` - correspondence table

**Verification**:
- `lake build FormalSystem.OpenLanguage` green and warning-free
- All 31 identifiers of `## Lean Challenge Statements` resolve — this prints nothing:

  ```bash
  PLAN=specs/625_formalize_open_future_open_past_modalities/plans/01_open-future-open-past-modalities.md
  for n in $(sed -n '/^\*\*Goals\*\*:/,/^\*\*[^G]/p' "$PLAN" | grep -oP '`[a-zA-Z_][a-zA-Z0-9_]*`' | tr -d '`' | sort -u); do
    grep -rqE "^theorem ${n}\b" FormalSystem/OpenLanguage || echo "MISSING $n"
  done
  ```
- The phase-closing gate

---

### Phase 8: Pins, tests, documentation sweep and the full gate [NOT STARTED]

**Goal**: Make the results durable: axiom pins, `rfl` coincidence pins, the listings that name the
language components, and one full run of every repository gate.

**Tasks**:
- [ ] C14: append `hnOpen_openValid`, `hnStab_refuted_sinkFrame`, `hnOpenMirror_openValid`,
  `openValid_reflectTime` (fully qualified) to **both** parallel lists in
  `scripts/check-module-invariants.sh` — the `#print axioms` block and the `C14_BASELINE` heredoc —
  in the same order, with the profiles measured in Phase 6. A declaration reporting no axioms
  cannot be pinned this way; pin it in the test file instead.
- [ ] `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`: a `section LOpen` with the four
  `… = Generic… := rfl` validity pins and an `LOpenOperators` section with the derived-operator
  pins (`OpenFormula.neg φ = TruthClauses.neg φ := rfl`, … `dstab`), following `LPlus` /
  `LPlusOperators`.
- [ ] New `Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean` with `#guard_msgs in
  #print axioms` blocks for the headline theorems (the `SaturationFiniteAxiomTest.lean` pattern);
  import it from `Tests/BimodalTest.lean`; add the row to `Tests/BimodalTest/Semantics/README.md`.
- [ ] `FormalSystem/StarLanguage/README.md`: rewrite the `sub:RestrictedModalities` correspondence
  row — open future and open past are formalized in `FormalSystem/OpenLanguage/`, the nomic operator
  stays excluded.
- [ ] `docs/reference/paper-definitions-of-record.md`: a `KNOWN-ANCHORS` row for
  `sub:RestrictedModalities` as `LIVE-UNPINNED`, pointing at the component.
- [ ] Listing sweep: every prose listing of the language components gains the fourth —
  `ORGANISATION.md` (layer-table row, the per-file section and its "13 files at layer 0, 16 at
  layer 1" figures), the module docstring of `scripts/measure-refactor-partitions.py` (same
  figures), `docs/development/MODULE_INVARIANTS.md` (assertions B and C prose),
  `docs/development/MODULE_ORGANIZATION.md`, `docs/ARCHITECTURE.md`, `README.md` (tree and language
  table), `FormalSystem/README.md` (component tables), `FormalSystem/Semantics/README.md` (the
  pointer line to the language components), `docs/theorem-index.md` if it indexes per language.
- [ ] Full gates: `bash scripts/check-module-invariants.sh` (with build),
  `bash scripts/check-metalogic-cycles.sh`, `lake build BimodalTest`,
  `lake exe mk_all --lib FormalSystem --check`.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: The listing sweep touches the nine documents named above. Confirm with
`grep -rln "StarLanguage" --include="*.md" --include="*.py" --include="*.sh" . | grep -v "^./specs/\|^./.lake\|^./.claude\|^./agent-system"`;
a hit that lists the language components and is not named above is added, a hit that merely cites
one Star module is left alone. The layer figures after this task are hypothesized as 14 files at
layer 0, 21 at layer 1, 1 at layer 3; confirm against the final `LANGUAGE_FILE_LAYERS`.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C14 pins, both lists
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`, `Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean` (new), `Tests/BimodalTest.lean`, `Tests/BimodalTest/Semantics/README.md`
- `FormalSystem/StarLanguage/README.md`, `docs/reference/paper-definitions-of-record.md`
- `ORGANISATION.md`, `scripts/measure-refactor-partitions.py` (docstring only),
  `docs/development/MODULE_INVARIANTS.md`, `docs/development/MODULE_ORGANIZATION.md`,
  `docs/ARCHITECTURE.md`, `README.md`, `FormalSystem/README.md`, `FormalSystem/Semantics/README.md`

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 (C5/C13 links, C14, C15, C17 report reviewed,
  C23, C26, C28, C31, C33, INV)
- `lake build BimodalTest` green
- `grep -rn "task 625\|Task 625\|#625" FormalSystem Tests docs scripts README.md ORGANISATION.md`
  prints nothing
- The phase-closing gate

## Lean Challenge Statements

**Authoring note.** The snapshot tool's declaration matcher recognizes `theorem|lemma|def|instance`
followed by a *simple* name, forces that declaration's body to `sorry`, and discards everything
between the `:=` and the next matched declaration. The block is therefore shaped so that nothing is
lost: every carrier sits in the preamble as `inductive` or `abbrev` (neither is matched, so the
bodies survive verbatim and stay out of the identifier set), no declaration name is dotted, and no
`namespace` / `end` follows the first theorem. Two consequences for the implementer: **the library
declares the carriers with `def`** (the validity notions *must* be `def`, and `sinkFrame` *must* be
`abbrev`), and the library's frame-level validity is `TaskFrame.OpenValidOn` in
`FormalSystem.Semantics` for dot notation, where the challenge writes the undotted `OpenValidOn`.
The block was type-checked standalone against the live tree at plan time.

```lean
import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.IntNormalForm

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

/-- L^▷ = L⁺ plus the open-future and open-past modals. -/
inductive OpenFormula : Type where
  | atom : Atom → OpenFormula
  | bot : OpenFormula
  | imp : OpenFormula → OpenFormula → OpenFormula
  | box : OpenFormula → OpenFormula
  | untl : OpenFormula → OpenFormula → OpenFormula
  | snce : OpenFormula → OpenFormula → OpenFormula
  | stab : OpenFormula → OpenFormula
  | ofut : OpenFormula → OpenFormula
  | opast : OpenFormula → OpenFormula

namespace OpenFormula

abbrev top : OpenFormula := OpenFormula.bot.imp OpenFormula.bot
abbrev neg (φ : OpenFormula) : OpenFormula := φ.imp bot
abbrev someFuture (φ : OpenFormula) : OpenFormula := OpenFormula.untl OpenFormula.top φ
abbrev somePast (φ : OpenFormula) : OpenFormula := OpenFormula.snce OpenFormula.top φ
abbrev dstab (φ : OpenFormula) : OpenFormula := neg (.stab (neg φ))
abbrev dofut (φ : OpenFormula) : OpenFormula := neg (.ofut (neg φ))
abbrev dopast (φ : OpenFormula) : OpenFormula := neg (.opast (neg φ))

abbrev ofPlus : PlusFormula → OpenFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (ofPlus φ) (ofPlus ψ)
  | .box φ => .box (ofPlus φ)
  | .untl ψ φ => .untl (ofPlus ψ) (ofPlus φ)
  | .snce ψ φ => .snce (ofPlus ψ) (ofPlus φ)
  | .stab φ => .stab (ofPlus φ)

abbrev reflectTime : OpenFormula → OpenFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (reflectTime φ) (reflectTime ψ)
  | .box φ => .box (reflectTime φ)
  | .untl ψ φ => .snce (reflectTime ψ) (reflectTime φ)
  | .snce ψ φ => .untl (reflectTime ψ) (reflectTime φ)
  | .stab φ => .stab (reflectTime φ)
  | .ofut φ => .opast (reflectTime φ)
  | .opast φ => .ofut (reflectTime φ)

end OpenFormula

open OpenFormula

variable {F : TaskFrame}

abbrev stabClass (τ : WorldHistory F) (x : F.Duration) : Set (WorldHistory F) :=
  {σ | τ.state x = σ.state x}
abbrev openFutureClass (τ : WorldHistory F) (x : F.Duration) : Set (WorldHistory F) :=
  {σ | AgreeUpTo τ σ x}
abbrev openPastClass (τ : WorldHistory F) (x : F.Duration) : Set (WorldHistory F) :=
  {σ | AgreeFrom τ σ x}

abbrev OpenTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : OpenFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => OpenTruthAt M τ t φ → OpenTruthAt M τ t ψ
  | .box φ => ∀ σ : WorldHistory F, OpenTruthAt M σ t φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧ OpenTruthAt M τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → OpenTruthAt M τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧ OpenTruthAt M τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → OpenTruthAt M τ r ψ
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → OpenTruthAt M σ t φ
  | .ofut φ => ∀ σ : WorldHistory F, AgreeUpTo τ σ t → OpenTruthAt M σ t φ
  | .opast φ => ∀ σ : WorldHistory F, AgreeFrom τ σ t → OpenTruthAt M σ t φ

abbrev OpenValidOn (F : TaskFrame) (φ : OpenFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration), OpenTruthAt M τ x φ
abbrev OpenValidOnFrames (P : TaskFrame → Prop) (φ : OpenFormula) : Prop :=
  ∀ F : TaskFrame, P F → OpenValidOn F φ
abbrev OpenValidIn (fc : ProofSystem.FrameClass) (φ : OpenFormula) : Prop :=
  OpenValidOnFrames fc.Sat φ
abbrev OpenValid (φ : OpenFormula) : Prop := OpenValidIn ProofSystem.FrameClass.Base φ

abbrev hnOpen (α : OpenFormula) : OpenFormula := imp (somePast α) (ofut (somePast (dofut α)))
abbrev hnOpenMixed (α : OpenFormula) : OpenFormula := imp (somePast α) (ofut (somePast (dstab α)))
abbrev hnStab (p : Atom) : OpenFormula :=
  imp (somePast (atom p)) (stab (somePast (dstab (atom p))))
abbrev hnOpenMirror (α : OpenFormula) : OpenFormula := (hnOpen α).reflectTime
abbrev hnStabMirror (p : Atom) : OpenFormula := (hnStab p).reflectTime

inductive SinkState : Type where
  | a | b | c
  deriving DecidableEq

instance : Nonempty SinkState := ⟨SinkState.a⟩

instance : Fintype SinkState where
  elems := {SinkState.a, SinkState.b, SinkState.c}
  complete := by intro x; cases x <;> simp

abbrev sinkFrame : FrameOver intOrder :=
  FrameOver.ofStep (fun x y : SinkState => x = y ∨ y = SinkState.c)
    (fun w => ⟨w, Or.inl rfl⟩) (fun w => ⟨w, Or.inl rfl⟩)

/-! Deliverable (1): the three classes. -/

theorem sameState_equivalence (x : F.Duration) :
    Equivalence (fun τ σ : WorldHistory F => τ.state x = σ.state x) := sorry

theorem agreeUpTo_equivalence (x : F.Duration) :
    Equivalence (fun τ σ : WorldHistory F => AgreeUpTo τ σ x) := sorry

theorem agreeFrom_equivalence (x : F.Duration) :
    Equivalence (fun τ σ : WorldHistory F => AgreeFrom τ σ x) := sorry

theorem openFutureClass_subset_stabClass (τ : WorldHistory F) (x : F.Duration) :
    openFutureClass τ x ⊆ stabClass τ x := sorry

theorem openPastClass_subset_stabClass (τ : WorldHistory F) (x : F.Duration) :
    openPastClass τ x ⊆ stabClass τ x := sorry

theorem openFutureClass_inter_openPastClass (τ : WorldHistory F) (x : F.Duration) :
    openFutureClass τ x ∩ openPastClass τ x = {τ} := sorry

theorem openFutureClass_anti (τ : WorldHistory F) {x y : F.Duration} (h : x ≤ y) :
    openFutureClass τ y ⊆ openFutureClass τ x := sorry

theorem openPastClass_mono (τ : WorldHistory F) {x y : F.Duration} (h : x ≤ y) :
    openPastClass τ x ⊆ openPastClass τ y := sorry

/-! Deliverable (2): conservativity over L⁺. -/

theorem openTruthAt_ofPlus (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) : OpenTruthAt M τ t (ofPlus φ) ↔ PlusTruthAt M τ t φ := sorry

theorem openValid_ofPlus_iff (φ : PlusFormula) : OpenValid (ofPlus φ) ↔ PlusValid φ := sorry

/-! Deliverable (3): the separating pair. -/

theorem hnOpen_openValid (α : OpenFormula) : OpenValid (hnOpen α) := sorry

theorem hnOpenMixed_openValid (α : OpenFormula) : OpenValid (hnOpenMixed α) := sorry

theorem hnStab_refuted_sinkFrame (p : Atom) :
    ¬ OpenValidOn sinkFrame.toTaskFrame (hnStab p) := sorry

theorem not_openValid_hnStab (p : Atom) : ¬ OpenValid (hnStab p) := sorry

/-! Deliverable (4): the time-reversal mirror. -/

theorem openValid_reflectTime (φ : OpenFormula) : OpenValid φ → OpenValid φ.reflectTime := sorry

theorem hnOpenMirror_openValid (α : OpenFormula) : OpenValid (hnOpenMirror α) := sorry

theorem not_openValid_hnStabMirror (p : Atom) : ¬ OpenValid (hnStabMirror p) := sorry

/-! Deliverable (5): S5 for each operator. -/

theorem openValid_ofut_t (φ : OpenFormula) : OpenValid (imp (ofut φ) φ) := sorry

theorem openValid_ofut_four (φ : OpenFormula) : OpenValid (imp (ofut φ) (ofut (ofut φ))) := sorry

theorem openValid_ofut_five (φ : OpenFormula) :
    OpenValid (imp (dofut φ) (ofut (dofut φ))) := sorry

theorem openValid_opast_t (φ : OpenFormula) : OpenValid (imp (opast φ) φ) := sorry

theorem openValid_opast_four (φ : OpenFormula) :
    OpenValid (imp (opast φ) (opast (opast φ))) := sorry

theorem openValid_opast_five (φ : OpenFormula) :
    OpenValid (imp (dopast φ) (opast (dopast φ))) := sorry

/-! Deliverable (5): the strength ordering and the failure of each converse. -/

theorem openValid_stab_of_box (φ : OpenFormula) : OpenValid (imp (box φ) (stab φ)) := sorry

theorem openValid_ofut_of_stab (φ : OpenFormula) : OpenValid (imp (stab φ) (ofut φ)) := sorry

theorem openValid_opast_of_stab (φ : OpenFormula) : OpenValid (imp (stab φ) (opast φ)) := sorry

theorem not_openValid_box_of_stab (p : Atom) :
    ¬ OpenValid (imp (stab (atom p)) (box (atom p))) := sorry

theorem not_openValid_stab_of_ofut (p : Atom) :
    ¬ OpenValid (imp (ofut (somePast (atom p))) (stab (somePast (atom p)))) := sorry

theorem not_openValid_stab_of_opast (p : Atom) :
    ¬ OpenValid (imp (opast (someFuture (atom p))) (stab (someFuture (atom p)))) := sorry

theorem not_openValid_opast_of_ofut (p : Atom) :
    ¬ OpenValid (imp (ofut (somePast (atom p))) (opast (somePast (atom p)))) := sorry

theorem not_openValid_ofut_of_opast (p : Atom) :
    ¬ OpenValid (imp (opast (someFuture (atom p))) (ofut (someFuture (atom p)))) := sorry
```

## Testing & Validation

- [ ] `lake build FormalSystem` green and zero `sorry` under `FormalSystem/OpenLanguage` at the end
  of **every** phase
- [ ] All 31 challenge identifiers exist with the pinned statements (modulo the `abbrev`/`def` and
  `OpenValidOn`/`TaskFrame.OpenValidOn` differences the authoring note records)
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0: one Metalogic cycle, the 7-line upward
  allowlist unchanged, assertion C holds with `OpenLanguage/Formula.lean` at layer 0
- [ ] `lake exe mk_all --lib FormalSystem --check` exits 0
- [ ] `bash scripts/check-module-invariants.sh` exits 0, including the four new C14 pins
- [ ] `lake build BimodalTest` green, including the `LOpen` `rfl` pins and
  `OpenLanguageAxiomTest.lean`
- [ ] No task number and no manuscript line number in any file outside `specs/`
- [ ] `git diff --stat` over the task shows no edit to `FormalSystem/PlusLanguage/**` or any other
  pre-existing Lean module except the generated `FormalSystem.lean`

## Artifacts & Outputs

- `FormalSystem/OpenLanguage.lean` and `FormalSystem/OpenLanguage/{Formula,OpenClasses,OpenTruth,OpenValidity,OpenReversal,OpenOckhamist}.lean`, `FormalSystem/OpenLanguage/README.md`
- `Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean`; additions to `ValidityLayerTest.lean`
- Registration and documentation edits listed per phase
- `specs/625_formalize_open_future_open_past_modalities/summaries/01_open-future-open-past-modalities-summary.md`

## Rollback/Contingency

Every phase is one commit that adds new files plus additive single-row registration edits, so a
phase is reverted with `git revert <sha>`; reverting Phase 1 last removes the component entirely
(the layer table, the generated root and the inventories all return to their prior bytes). No
existing Lean module is edited, so nothing downstream can break from a revert. On a build error,
fix forward; never discard uncommitted work to reach a green build. If uncommitted work must
genuinely be rolled back, follow the rollback rung of `context/contracts/recovery.md` — note that
the task's declared `file_scope` predates decision D2, so that rung's out-of-scope override applies.
Contingencies inside the plan: Phase 5's fallback (land the transport without
`openValid_reflectTime`) and Phase 7's hand-mirror route; the `NF` refutation of `hnStab`
(probe 01's `hn_stab_refuted_NF`) is a zero-cost substitute witness for `not_openValid_hnStab` but
**not** for `hnStab_refuted_sinkFrame`, whose point is the fully axiomatized finite frame.
