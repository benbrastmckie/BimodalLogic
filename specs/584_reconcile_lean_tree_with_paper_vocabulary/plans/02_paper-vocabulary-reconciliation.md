# Implementation Plan: Task #584

- **Task**: 584 - Reconcile the Lean tree with the paper's renamed vocabulary and re-pin the record
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: 595 (records home, done: record lives at `docs/reference/paper-definitions-of-record.md`), 583 (CI wiring convention, done), 601 (reflection convention, done). Coordinate with 589 (owns the `specs/archive/` citation fix in `MinusLanguage/Axioms.lean`), 600 (planned Lean rename, overlapping files), 586/590/578 (planning; touch typst and docs)
- **Research Inputs**: specs/584_reconcile_lean_tree_with_paper_vocabulary/reports/02_paper-vocabulary-decisions.md (supersedes reports/01_paper-vocabulary-drift.md)
- **Artifacts**: plans/02_paper-vocabulary-reconciliation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`check-paper-definitions.sh` reports case (c): 14 drifted anchors plus the dangling
`thm:M5-valid` (re-confirmed live at plan time, 2026-09-17). Of the three substantive renames,
rename 1 (reflection convention) is already done, rename 3 (Some/All Past/Future labels) already
matches the Lean names apart from a few doc labels, and rename 2 (metarule TD -> TR) was settled by
the user as **option A: full rename**. The rule abbreviation changes in prose, and the
`swapTemporal`/`temporal_duality`/`TemporalDuality` identifier families are renamed too. This plan
re-quotes and re-hashes the record, carries out the full TR rename as one atomic Lean batch plus a
classified prose pass, closes the constructor naming audit, records every decision and carve-out,
re-pins, and wires the check into CI. It is done when the script exits 0, C15 resolves, `lake build`
and every `lean_exe` root compile, the module invariants pass with no axiom-baseline movement,
and CI carries the skip-neutral step.

### Research Integration

Integrated from report 02: the live drift table (14 anchors + `thm:M5-valid` commented out ->
retire), the evidence that rename 1 is closed, rename 3's tree-already-matches finding and its 3
label sites, the full paper-key -> constructor -> mirror table that closes the naming audit, the 8
"smallest extension" stale sites, the stale `Formula.swapTemporal` docstring, the Burgess/Xu A7a
caution, and the CI skip-neutral design (`scripts/check-paper-definitions.sh` paper-absent branch,
`docs/development/CI_CD_PROCESS.md` § Wiring a New Check Script). The report recommended option B.
The user chose A, so this plan replaces the report's prose-only rename scope with a full
identifier rename.

### Prior Plan Reference

No prior plan for this task. The completed plan for the reflection-convention alignment
(`specs/601_align_task_frame_reflection_convention/plans/01_reflection-convention-frame.md`) sets the
precedent followed here: an atomic Lean batch, then a scoped prose rename that excludes
same-spelled but different senses, then a record re-pin and final gates.

### Roadmap Alignment

No ROADMAP.md consulted (no roadmap_path in this dispatch).

### Decisions

- **Rename 1**: closed. Only a regression gate remains.
- **Rename 2 (user, option A)**: full rename. Proposed identifier map, applied by the planner as
  the default (see the non-blocking naming confirmation relayed with this plan):

  | Current family | New family | Notes |
  |---|---|---|
  | `swapTemporal` (on `Formula`, `PlusFormula`, `StarFormula`, all dotted uses) | `reflectTime` | lowerCamelCase data, per `docs/development/NAMING_CONVENTION_DEVIATION.md` |
  | `swap_temporal_*` lemma prefix (e.g. `swap_temporal_involution`, `provEquiv_swap_temporal_congr`) | `reflect_time_*` | snake_case theorem component |
  | `*_swapTemporal` / `swapTemporal_*` in lemma names (e.g. `ofPlus_swapTemporal`, `swapTemporal_injective`) | `*_reflectTime` / `reflectTime_*` | |
  | `temporal_duality` constructor (every `DerivationTree` variant: TM, Minus, Plus, Star, Det/Co) and `temporal_duality_height_succ` | `time_reflection`, `time_reflection_height_succ` | the paper's "time reflection metarule" |
  | `TemporalDuality` (`applyTemporalDuality`, `mkTemporalDuality`, `section TemporalDuality`, `TemporalDualityIntegration`) | `TimeReflection` | |
  | `temporalDuality` (`MutationType.temporalDuality`, `temporalDualityCount`) | `timeReflection`, `timeReflectionCount` | |
  | prose "TD" (the rule abbreviation) / "temporal duality" in the rule sense | "TR" / "time reflection" | classified per site, Phase 3 |

- **Carve-outs (not renamed, recorded as deliberate divergences in the record)**:
  1. `temporalDualityNeg`, `temporalDualityNegRev`, and "temporal duality" prose that means the
     ▽/△ **operator duality** (`Theorems/Perpetuity/MonotonicityDuality.lean` and its README). This
     is a different concept that happens to share the spelling.
  2. "temporal duality" prose that names the **semantic lemma**. The paper itself keeps
     `lem:temporal-duality`.
  3. Serialized **wire tags**: the `"temporal_duality"` string literals in dataset/JSON output
     (`Automation/DataExport.lean`, `DatasetGenerator.lean`, `ProofStepExtractor.lean`,
     `ContrastiveGeneratorMain.lean`, `ProofExtractorMain.lean`). These stay byte-stable, following
     the precedent that `scripts/swap_untl_snce.py` states for tag strings. Exception:
     `MachineAppendixMain.lean`'s `name := "temporal_duality"` and its `conclusion` string follow the
     rename, because `typst-sync-check.sh` recounts live constructor names against the appendix.
  4. `swapUS`, `swapMinus`, `truth_swap`, and the `*_swap_valid*` soundness-lemma families were not
     in the decided set. They are left as-is and listed in the record as a possible follow-up.
  5. `FormalSystem/Boneyard/**` (archive, not built; 9 files mention the old names).
- **Rename 3**: adopt (Some Past / Some Future / All Past / All Future labels).
- **`thm:M5-valid`**: retire (DANGLING row, manifest row removed), following the 2026-09-07 precedent.
- **Constructor naming audit**: closed as "same system, explicit mirrors" (textual correspondence
  plus 5 Lean spot checks). A formal `derivable_iff` equivalence and Burgess/Xu provenance folding
  are follow-ups. They are recorded in the summary, not done here.
- **TM⁻'s rule** (`MinusLanguage/Derivation.lean`): it follows the rename (TD -> TR, constructor ->
  `time_reflection`), for uniformity. Its docstring cites TM⁻ as the tree's own transposition, not
  a paper system.

## Goals & Non-Goals

**Goals**:
- `bash scripts/check-paper-definitions.sh` exits 0 (case a or b). The 14 anchors are re-quoted and
  re-hashed from live text, and `thm:M5-valid` is retired.
- Every `swapTemporal`/`swap_temporal`/`temporal_duality`/`TemporalDuality`/`temporalDuality`
  identifier in `FormalSystem/` and `Tests/` is renamed per the Decisions map, except the enumerated
  carve-outs. Prove the challenge-pinned theorems `Formula.reflect_time_involution`,
  `PlusFormula.reflect_time_involution` and `StarFormula.reflect_time_involution` (renames of the
  existing involution lemmas).
- Rule-sense "TD"/"temporal duality" prose becomes "TR"/"time reflection" across Lean docstrings,
  READMEs, `docs/`, `typst/` and `latex/`. Operator-duality and lemma-sense prose is kept.
- Rename 3's label sites are updated: `docs/user-guide/quickstart.md:32` (plus its nonexistent
  `φ.past`/`φ.future`), `FormalSystem/Syntax/Formula.lean:177`, `docs/reference/operators.md:180`.
- The stale `Formula.reflectTime` docstring is fixed: it swaps `untl`/`snce`, not `allPast`/`allFuture`.
- `FormalSystem/Syntax/MinusLanguage/Axioms.lean` is corrected: TM⁻ is described as the tree's own
  transposition (lines ~13-15, ~146), and the open audit note (~73) is replaced by the closed
  mapping table.
- The record gains a 2026-09-17 correction section with every decision and carve-out, and is
  re-pinned per the dirty-pin convention.
- `check-paper-definitions.sh` skips neutrally (`SKIP (neutral): ...`, exit 0) when the paper is
  absent, and is wired into `.github/workflows/ci.yml` per the 583 convention. The Runtime Budget
  row is added, and the "Known non-conforming script" paragraph is removed.

**Non-Goals**:
- Editing the paper.
- Renaming the carve-outs listed under Decisions.
- A full resync of `typst/FormalFoundations.typ`. Only the TD/identifier tokens, the
  "smallest extension" sites and the two claims the closed audit refutes (lines ~1034-1041) are
  touched.
- Folding Burgess/Xu axiom provenance into `ProofSystem/Axioms.lean`, and a machine-checked
  paper-vs-Lean `derivable_iff`. Both are follow-ups.
- The `specs/archive/` citation fix in `MinusLanguage/Axioms.lean` (owned by 589).
- Renaming the automation identifiers `trySwapPastHistorically`/`pastToHistoricallyAtOccurrence`.
- Adding `@[deprecated]` aliases. The library has no external consumers, and aliases would keep the
  old names alive in search results.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Blind token replace hits a carve-out (`temporalDualityNeg`, wire-tag strings, `graph TD` mermaid at `README.md:175`, `TMP-` keys in quoted paper text) | H | M | Rename by an exact identifier-token map with explicit exclusion list. The script skips string literals and comments for identifier families, and the Phase 3 prose pass works from a classified site ledger, never a global sed |
| `lake build` misses `lean_exe` roots (the Automation `*Main.lean` files) | H | H | Phase 2 gate runs the CI "Compile lean_exe roots" loop verbatim, plus `check-evidence-probes.sh` (probes under `specs/evidence/` currently contain none of the names, re-grep anyway) |
| Paper moves again mid-implementation (it did between reports 01 and 02) | M | M | Re-run the script at the start of Phases 1 and 5 and immediately before the re-pin. Quote live text only |
| Merge conflicts with concurrently-planned tasks touching the same files (600 Lean rename; 586/590/578 typst/docs) | M | M | Land Phase 2 as one commit early. Re-grep counts at each phase start, and treat plan counts as hypotheses |
| `typst-sync-check.sh` name resolution or machine-appendix recount breaks | M | H | Phase 2 includes typst backticked identifier updates and regenerates `typst/generated/machine-appendix.{jsonl,typ}` via `scripts/typst-machine-appendix.sh` in the same batch |
| Axiom baseline (C2/C14) or sorry-count movement | H | L | Renames only. Run full `check-module-invariants.sh` (not `--no-build`) in Phases 2 and 5. Any divergence is a hard stop |
| C15 citation breakage from retiring `thm:M5-valid` | M | L | Research found no live citation. Re-grep before retiring, and run `check-module-invariants.sh --no-build` after the record edit |
| Skip path masks real failures | M | L | Skip fires only when the paper file is absent and neither `--against` nor `--resolve` was given. A missing record stays exit 2. Test both paths |
| User later prefers different identifier names | M | L | The rename is scripted from a single map file kept in the task dir, so a re-run with a different map is cheap. Naming confirmation relayed non-blocking |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Re-quote drifted anchors and retire thm:M5-valid [NOT STARTED]

**Goal**: Bring the record's quoted text and manifest hashes in line with the live paper. The
sentinel is not re-pinned yet (Phase 5 does that).

**Tasks**:
- [ ] Run `bash scripts/check-paper-definitions.sh` and capture the live drift set. Confirm it matches
      the 14 anchors in report 02 (`def:BL-semantics`, `def:BLplus-language`, `def:S5`, `def:BX`,
      `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus`, `def:frame-properties`, `app:discrete`,
      `app:dense`, `app:complete`, `cor:tm-completeness`, `def:id`) plus the dangling `thm:M5-valid`.
- [ ] For each drifted anchor, run `--resolve "ID|env|-|-"` to get the live text and sha256. Replace the
      quoted block under its `### \`ID\`` entry and the manifest hash.
- [ ] Retire `thm:M5-valid`: mark its heading **DANGLING as of the 2026-09-17 re-pin (removed from
      manifest)**, delete its manifest row, add a `thm:M5-valid|DANGLING|fully COMMENTED OUT in
      the paper ...` row to KNOWN-ANCHORS. First grep live scope to confirm there are no citations.
- [ ] Re-run the script and confirm case (b): the pinned checksum still differs, but all recorded blocks match.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 14 drifted anchors + 1 dangling, confirmed at plan time. Confirm by the
Phase-start script run. If the set differs, re-quote whatever the live run reports.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - quoted blocks, manifest hashes, DANGLING entry

**Verification**:
- `bash scripts/check-paper-definitions.sh` exits 0 (case b)
- `bash scripts/check-module-invariants.sh --no-build` passes C15

---

### Phase 2: Atomic Lean identifier rename (TD -> TR families) [NOT STARTED]

**Goal**: Rename every in-scope identifier across `FormalSystem/`, `Tests/` and the name-bearing
generated/typst artifacts in one green commit.

**Tasks**:
- [ ] Re-grep counts (exclude `.lake`, `.git`, `specs`, `.claude`, `agent-system`, `Boneyard`) and write
      the rename map to `specs/584_reconcile_lean_tree_with_paper_vocabulary/rename-map.tsv`
      (old token -> new token, one per line, including every compound such as `ofPlus_swapTemporal`,
      `atomize_swapTemporal`, `substPlus_swapTemporal`, `erasePlus_swapTemporal`, `truthAt_swapTemporal`,
      `swapTemporal_injective`, `StarIsPureFuture.swapTemporal`, `temporal_duality_height_succ`,
      `temporalDualityCount`) plus an exclusion list (`temporalDualityNeg`, `temporalDualityNegRev`).
- [ ] Write a scratch rename script (python, in the scratchpad, not committed) that rewrites identifier
      tokens by whole-token match (identifier chars `[A-Za-z0-9_'.]` as boundaries, each dotted
      component matched). It skips string literals, except `MachineAppendixMain.lean`'s
      `name`/`conclusion` strings. It rewrites backticked identifiers inside comments and docstrings,
      and leaves bare-prose words alone.
- [ ] Apply it to `FormalSystem/**/*.lean` (excluding `Boneyard/`) and `Tests/**/*.lean`. Also update
      `swapTemporal` mentions in `scripts/swap_untl_snce.py` doc text only if they name the Lean
      function.
- [ ] Update backticked identifier references in `typst/**/*.typ` and `typst/SYNC-MAP.md` (row 119, the
      rules list at ~170). Regenerate `typst/generated/machine-appendix.{jsonl,typ}` and
      `typst/generated/status.typ` via their generator scripts.
- [ ] Add a one-line comment at each kept wire-tag string saying the tag is byte-stable across the
      rename (no task numbers).
- [ ] Gates: `lake build`; `lake build BimodalTest` (or `lake test`); the CI lean_exe loop
      (`for root in $(grep -oP 'root\s*:=\s*`\K[A-Za-z0-9_.]+' lakefile.lean); do lake build "$root"; done`);
      `bash scripts/check-evidence-probes.sh`; `bash scripts/typst-sync-check.sh`; full
      `bash scripts/check-module-invariants.sh` (C2/C14 unchanged).
- [ ] Residual grep: zero hits for `swapTemporal|swap_temporal|temporal_duality|TemporalDuality` and for
      `temporalDuality` other than `temporalDualityNeg*`, in `FormalSystem/` (non-Boneyard) and
      `Tests/` code, except the enumerated wire-tag string literals.

**Timing**: 2 hours (mechanical script plus build time)

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch (the rename leaves the tree red until every file in the declared
set — `FormalSystem/**/*.lean` minus Boneyard, `Tests/**/*.lean`, `typst/**`, `typst/generated/*` —
is rewritten)

**Scope Hypothesis**: about 82 Lean files / about 1,142 matching lines; `swapTemporal` family 1,032
hits in 80 files; `temporal_duality` 255 in 78 files; `TemporalDuality` 8 in 4 files; camelCase
`temporalDuality*` about 56 hits, of which `temporalDualityNeg`/`NegRev` (18) are excluded. Confirm
by re-grep at phase start, and treat build errors as the authoritative residual list.

**Files to modify**:
- `FormalSystem/Syntax/{Formula,PlusLanguage/Formula,StarLanguage/Formula,MinusLanguage/*}.lean` - definitions
- `FormalSystem/ProofSystem/Derivation.lean` and the Minus/Plus/Star/Det/Co derivation modules - constructor
- All other consumers in `FormalSystem/` and `Tests/` (per residual grep)
- `FormalSystem/Automation/{ForwardProofGenerator,ContrastiveGeneratorMain,MachineAppendixMain,...}.lean`
- `typst/**/*.typ`, `typst/SYNC-MAP.md`, `typst/generated/*`

**Verification**:
- All gates listed above green, and the residual grep is clean

---

### Phase 3: Prose rename TD -> TR and rule-sense "temporal duality" [NOT STARTED]

**Goal**: Change the rule's prose name everywhere it means the metarule, and keep the carve-out senses.

**Tasks**:
- [ ] Build a site ledger (scratch file in the task dir) for every bare `\bTD\b` and every
      `[Tt]emporal [Dd]uality` hit outside `specs/`, `.lake`, `.git`, `.claude`, `agent-system`,
      `Boneyard`, and the record. Classify each hit as **rule** (rename), **lemma**
      (`lem:temporal-duality` sense, keep), **operator duality** (▽/△ or modal/temporal dual pairs,
      keep), or **other** (e.g. mermaid `graph TD`, keep).
- [ ] Apply the rule-sense edits. Use "TR" for the abbreviation, and "time reflection" /
      "the time reflection rule (TR)" for the prose name. Do not attribute "time reflection" to
      `lem:temporal-duality`.
- [ ] Cover Lean docstrings/comments (`MinusLanguage/*`, `Theorems/Perpetuity/*`,
      `Metalogic/Conservativity/**`, `Formula.lean` variants, etc.), READMEs, `docs/**`, `typst/**`
      (including `typst/FormalFoundations.typ` TD tokens), and `latex/subfiles/*.tex`.
- [ ] Gates: `lake build` (docstrings compile); `bash scripts/readme-lint.sh`;
      `bash scripts/typst-sync-check.sh`; `bash scripts/check-module-invariants.sh --no-build`
      (C14 content scan, C15).

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep (commit per directory group: Lean docstrings, docs/READMEs, typst, latex)

**Scope Hypothesis**: bare `TD` 60 hits / 29 files; "temporal duality" 130 hits / about 50 files, of
which the `MonotonicityDuality.lean` operator-duality hits (at least 10) and lemma-sense hits are kept.
Confirm with the ledger. The final count of renamed vs kept sites goes into the Phase 5 record section.

**Files to modify**:
- Lean docstrings across `FormalSystem/` and `Tests/` (per ledger)
- `README.md`, `FormalSystem/**/README.md`, `docs/**`, `typst/**`, `latex/subfiles/*.tex`

**Verification**:
- Every ledger row resolved. Post-pass grep shows only the ledger's kept rows
- Gates above green

---

### Phase 4: Rename 3 labels, stale docstrings, and naming-audit closure [NOT STARTED]

**Goal**: Adopt the Some/All Past/Future labels, fix the known-stale docstrings, and close the
constructor naming audit in-tree.

**Tasks**:
- [ ] Labels: `docs/user-guide/quickstart.md:28-33` (the label "Historical" -> "All Past", and replace the
      nonexistent `φ.past`/`φ.future` with `somePast`/`someFuture`/`allPast`/`allFuture`);
      `FormalSystem/Syntax/Formula.lean:~177` ("DSL Notation: `H φ` for Historically" -> All Past);
      `docs/reference/operators.md:~180`. Grep for other operator-label uses of
      Past/Future/Historical/Henceforth and fix the label senses only.
- [ ] Fix the `Formula.reflectTime` docstring (`Syntax/Formula.lean` ~599-607) so it says the operation
      interchanges `untl` and `snce` (the paper's φ⟨S|U⟩) and cites TR. Check the Plus/Star variants
      for the same error.
- [ ] `FormalSystem/Syntax/MinusLanguage/Axioms.lean`: rewrite lines ~13-15 and ~146 so TM⁻ is the
      tree's own transposition with no paper attribution (no "smallest extension ... closed under"
      paper quote). Replace the open audit note at ~73-76 with the closed paper-key -> constructor ->
      mirror table from report 02 (or a pointer to it in `docs/reference/axiom-reference.md`, adding
      the table there), including the `temp_linearity` disjunct-order note and the NA =
      `discrete_propagate_bwd` note. Leave the `specs/archive/` citation for 589.
- [ ] "smallest extension ... closed under" phrasing: update the 7 typst sites
      (`typst/FormalFoundations.typ` ~446, 490, 498, 527, 541, 577; `typst/chapters/03-proof-theory.typ`
      ~360) to "extends ... to include". Correct the `FormalFoundations.typ` remark (~1034-1041)
      whose "no TD rule" and "uniformity layer does not even match in count" claims the audit
      refutes. Confirm `DerivationTree` docstrings need no change.
- [ ] Gates: `lake build`; `bash scripts/typst-sync-check.sh`; `bash scripts/readme-lint.sh`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 3 label sites + quickstart's `φ.past`/`φ.future`; 1-3 swap docstrings; 3
regions in `MinusLanguage/Axioms.lean`; 7 typst phrasing sites + 1 remark. Confirm by grep at phase
start (line numbers are indicative only).

**Files to modify**:
- `docs/user-guide/quickstart.md`, `docs/reference/operators.md`, `docs/reference/axiom-reference.md`
- `FormalSystem/Syntax/Formula.lean` (+ Plus/Star `Formula.lean` if affected)
- `FormalSystem/Syntax/MinusLanguage/Axioms.lean`
- `typst/FormalFoundations.typ`, `typst/chapters/03-proof-theory.typ`

**Verification**:
- Gates green. `grep -n 'smallest extension' typst FormalSystem` returns no paper-attributed hits

---

### Phase 5: Record the decisions, re-pin, and run the full gate set [NOT STARTED]

**Goal**: Make the record the durable home of every decision, re-pin the sentinel, and prove the
task's acceptance bar.

**Tasks**:
- [ ] Add a section "Drift correction and rename absorption (2026-09-17)" to
      `docs/reference/paper-definitions-of-record.md`:
      - the 14 re-hashed anchors and the `thm:M5-valid` retirement;
      - rename 1 adopted earlier (pointer to the existing reflection-convention entry);
      - rename 2 adopted in full, with the identifier map and each carve-out and its reason
        (operator duality, `lem:temporal-duality` sense, wire tags, `swapUS`/`swapMinus`/`*_swap_valid*`
        families, Boneyard);
      - rename 3 adopted;
      - the naming-audit closure;
      - the `def:BX` Burgess/Xu footnote as an open provenance opportunity, with the A7a-vs-CN
        caution;
      - the `cor:tm-completeness` Determined sentence backed by `Metalogic/Deterministic/`.
- [ ] Update the record's own TD mentions (narrative line ~184 `thm:TD-valid` -> note the paper's
      `thm:TR-valid`; do not edit quoted historical text).
- [ ] Re-run `bash scripts/check-paper-definitions.sh` **immediately** before pinning. Then set
      `PINNED_COMMIT` (paper repo `git HEAD` now), `FILE_CHECKSUM` (sha256 of the live file) and
      `LINE_COUNT`, and add provenance-table rows (base commit, checksum, line count, UTC) per the
      dirty-pin convention.
- [ ] Final gates:
      - `bash scripts/check-paper-definitions.sh` exits 0 (case a);
      - full `bash scripts/check-module-invariants.sh` (C2/C14 baseline unchanged, C15 resolves all
        paper-anchor citations, expected 58, confirm the count it prints);
      - `lake build` + the lean_exe roots loop + `lake test`;
      - `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`,
        `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`;
      - regression greps: `converse convention` = 1 archive hit in the record; no
        `swapTemporal|temporal_duality` identifiers outside carve-outs; no site attributes a
        carved-out term (e.g. `temporal_duality` wire tag, "temporal duality" lemma name) to
        `def:BX`/`\aref{TR}`.

**Timing**: 1.5 hours

**Depends on**: 1, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md`

**Verification**:
- Every final gate above green, with outputs captured in the implementation summary

---

### Phase 6: Skip-neutral mode and CI wiring [NOT STARTED]

**Goal**: Make the drift check CI-safe and gate it in CI.

**Tasks**:
- [ ] In `scripts/check-paper-definitions.sh`'s paper-absent branch (`if [ ! -f "$PAPER" ]`, the non
      `--against` path): when neither `--against` nor `--resolve` was given, print
      `SKIP (neutral): paper not found at $PAPER` and exit 0. Keep exit 2 for a missing record, for
      `--against`, and for `--resolve`. Update the header's exit-code documentation.
- [ ] Test all four paths: `--paper /nonexistent` -> SKIP, exit 0; `--record /nonexistent` -> exit 2;
      `--resolve ... --paper /nonexistent` -> exit 2; live run -> exit 0.
- [ ] Add a step directly before "Report results" in `.github/workflows/ci.yml`, named
      `Check paper definitions (scripts/check-paper-definitions.sh)`, with the
      `set -euo pipefail` + `::group::` body.
- [ ] `docs/development/CI_CD_PROCESS.md`: add the Runtime Budget row (measure locally with the paper
      present and with the paper absent under a minimal env using the extracted step body), and
      delete the "Known non-conforming script" paragraph.
- [ ] Gates: `bash scripts/check-module-invariants.sh --no-build`; `bash scripts/readme-lint.sh`; YAML
      sanity (`python3 -c 'import yaml,sys; yaml.safe_load(open(".github/workflows/ci.yml"))'`).

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `scripts/check-paper-definitions.sh`
- `.github/workflows/ci.yml`
- `docs/development/CI_CD_PROCESS.md`

**Verification**:
- All four exit-path tests behave as specified. The live run exits 0. The CI step body extracted
  from the YAML runs green locally without the paper (SKIP line printed)

## Lean Challenge Statements

Statement pins against the post-implementation modules: the three renamed involution lemmas.

```lean
import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.PlusLanguage.Formula
import FormalSystem.Syntax.StarLanguage.Formula

namespace FormalSystem.Syntax

theorem Formula.reflect_time_involution (φ : Formula) :
    φ.reflectTime.reflectTime = φ := sorry

end FormalSystem.Syntax

namespace FormalSystem.PlusLanguage

theorem PlusFormula.reflect_time_involution (φ : PlusFormula) :
    φ.reflectTime.reflectTime = φ := sorry

end FormalSystem.PlusLanguage

namespace FormalSystem.StarLanguage

theorem StarFormula.reflect_time_involution (φ : StarFormula) :
    φ.reflectTime.reflectTime = φ := sorry

end FormalSystem.StarLanguage
```

## Testing & Validation

- [ ] `bash scripts/check-paper-definitions.sh` exits 0 (case a after the re-pin)
- [ ] Full `bash scripts/check-module-invariants.sh`: C2/C14 axiom baselines unchanged, C15 resolves
      all paper-anchor citations (expected 58)
- [ ] `lake build`, `lake test`, and every `lean_exe` root builds
- [ ] `bash scripts/check-evidence-probes.sh`, `bash scripts/typst-sync-check.sh`,
      `bash scripts/readme-lint.sh`, copyright-header check green
- [ ] Residual identifier grep clean outside the enumerated carve-outs
- [ ] No site attributes a carved-out term to the paper's `def:BX`/TR
- [ ] Skip-neutral exit-path tests pass. The CI step is present and ordered before "Report results"

## Artifacts & Outputs

- `specs/584_reconcile_lean_tree_with_paper_vocabulary/plans/02_paper-vocabulary-reconciliation.md` (this plan)
- `specs/584_reconcile_lean_tree_with_paper_vocabulary/rename-map.tsv` (rename map, Phase 2)
- `specs/584_reconcile_lean_tree_with_paper_vocabulary/prose-ledger.md` (site ledger, Phase 3)
- Updated `docs/reference/paper-definitions-of-record.md`, renamed Lean tree, updated docs/typst/latex,
  `scripts/check-paper-definitions.sh`, `.github/workflows/ci.yml`, `docs/development/CI_CD_PROCESS.md`
- `specs/584_reconcile_lean_tree_with_paper_vocabulary/summaries/02_paper-vocabulary-reconciliation-summary.md`,
  listing the follow-ups: Burgess/Xu provenance folding, `derivable_iff` equivalence,
  `FormalFoundations.typ` resync, and the optional `swapUS`/`swapMinus`/`*_swap_valid*` rename

## Rollback/Contingency

- Each phase lands as its own commit(s), so a failed phase is reverted with `git revert` of its
  commits, never a destructive reset.
- Phase 2 (atomic batch): if the rename cannot be made green, fix forward from the build error list.
  The map is data-driven, so a missed compound gets added to `rename-map.tsv` and the script is
  re-run. If the working tree must be abandoned mid-batch, follow the snapshot-then-rollback rung in
  `.claude/context/contracts/recovery.md` (including its out-of-scope override flag for a deliberate
  whole-tree rollback). Do not use a bare precautionary snapshot.
- If the user revises the identifier names after Phase 2 lands, re-run the script with an updated map
  (old-new pairs from the current names) as a new atomic batch.
- If the paper moves again before Phase 5's re-pin, re-run Phase 1's re-quote step for the newly
  drifted anchors before pinning.
