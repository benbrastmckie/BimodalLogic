# Research Report: Task #580

**Task**: 580 - Split Semantics/Truth.lean's correspondence machinery into Correspondence/
**Started**: 2026-09-15T00:00:00Z
**Completed**: 2026-09-15T00:00:00Z
**Effort**: Medium (pure file split; ~830 lines relocated, ~4 import lines added, 3 docs updated)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/Truth.lean`, `FormalSystem/Semantics/Correspondence/`, `FormalSystem/Semantics.lean`
- `specs/reviews/review-2026-09-15.md` Finding H2 (the originating review)
- `scripts/check-module-invariants.sh` (C1-C25 gate definitions), `scripts/readme-lint.sh`
- lean-lsp MCP: not required (no proof authoring; see Tactic Survey Results)
**Artifacts**:
- `specs/580_split_semantics_truth_lean_s_corresponde/reports/01_split-truth-correspondence-machinery.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The seam the review names is real but is not a single cut.** Lines 623-end are not uniformly
  correspondence machinery: lines 893-996 hold `truthAt_atomFree_history_indep`, `truthAt_gap`,
  `truthAt_cogap`, `truthAt_gap_shift` and `truthAt_gap_iff_cogap` — genuine `TruthAt` corollaries
  about `Formula` that depend on nothing in the correspondence layer. A verbatim "move everything
  from 623 down" would exile on-topic truth lemmas into a correspondence file. The correct split
  is **three blocks, two of which move**.
- **`box_const`/`box_time_const` must move with the correspondence block, not stay.** They are
  `Truth`-namespace truth lemmas, but their proof consumes `TimeShift.timeShift_preserves_truth`.
  Keeping them in `Truth.lean` while the `TimeShift` namespace moves out would require
  `Truth.lean` to import its own downstream module — a cycle. Their docstring already records
  exactly this ordering constraint, and it travels with them.
- **Recommended destination is `FormalSystem/Semantics/TruthTransport.lean`, not
  `Semantics/Correspondence/TruthShift.lean`.** `Correspondence/` is documented in its own README
  as "the frame-class Galois layer" whose dependency contract is *"Imports from:
  `FormalSystem.Semantics.Validity`"*. The moved material is model-to-model truth transport, not
  frame correspondence, and four modules that sit *below* `Validity` in the import order
  (`ShiftSet`, `PlusTruth`, plus `IntTransfer` and every `Metalogic` consumer) would have to
  import it — inverting that contract. The review's own wording is `(e.g. …)`, so the location is
  advisory. See Decisions and `user_decision` on `.return-meta.json`.
- **Import churn is small and enumerable**: 4 files need a new explicit import line
  (`Semantics/Validity.lean`, `Semantics/ShiftSet.lean`, `Semantics/PlusTruth.lean`,
  `Metalogic/Decidability/BiLasso/Unfold.lean`), because every other consumer reaches the moved
  declarations transitively through one of those four. An explicit-import-at-every-consumer
  variant (21 files) is also viable and is described below.
- **Zero proof content changes, zero sorries, zero axiom-baseline movement.** Baseline
  `lake build` verified green before any edit (exit 0). All paper anchors in the moved region are
  name-based, so C15 is unaffected; no `file.lean:NNN` citations exist in the moved region, so
  C20 is unaffected.

## Context & Scope

Researched: how to split `FormalSystem/Semantics/Truth.lean` (1,193 lines) so that `TruthAt` and
its clause lemmas are the file's whole subject, without changing any proof, breaking any import,
or failing `scripts/check-module-invariants.sh`.

Constraints taken as binding:
- Pure relocation. Every moved declaration and proof preserved **verbatim**; only file location,
  import lines and surrounding section docstrings change.
- Zero-debt: no `sorry`, no new axiom. (Trivially satisfied — no proof is re-authored.)
- Verification bar from the task: `lake build` succeeds; `scripts/check-module-invariants.sh`
  passes.

Out of scope: any renaming of declarations, any change to `simp`/`truth_norm` attribute
membership, any change to the `Correspondence/` modules that already exist.

## Findings

### Codebase Patterns

**Current structure of `Truth.lean` (1,193 lines), by exact line number:**

| Lines | Content | Verdict |
|-------|---------|---------|
| 1-16 | Copyright, 5 imports, `assert_not_exists` (G-15 lower-layer guard) | preamble |
| 18-163 | Module docstring | keep, edit |
| 165-169 | `namespace FormalSystem.Semantics`, `open FormalSystem.Syntax`, `variable {F : TaskFrame}` | preamble |
| 241-252 | `def TruthAt` | **KEEP** |
| 263-279 | `instance : TruthEnv Formula`, `instance : UntlClauses Formula` | **KEEP** |
| 281-577 | `namespace Truth` … `end Truth`: the clause/derived-operator lemma family and the `attribute [truth_norm]` block | **KEEP** |
| 579-703 | `TruthCorr` structure + `Truth.truthAt_of_truthCorr` (the single `induction φ`) | **MOVE (block A)** |
| 705-839 | `namespace TimeShift`: `truth_history_eq`, `ShiftRel`, `shiftRel_timeShift`, `shiftRel_timeShift_neg`, `shiftCorr`, `timeShift_preserves_truth`, `timeShift_preserves_truth_total`, `exists_shifted_history` | **MOVE (block A)** |
| 841-891 | `namespace Truth`: `box_const`, `box_time_const` | **MOVE (block A)** — see below |
| 893-996 | `truthAt_atomFree_history_indep`, `truthAt_gap`, `truthAt_cogap`, `truthAt_gap_shift`, `truthAt_gap_iff_cogap` (still inside the `namespace Truth` opened at 841, closed at 998) | **KEEP** — relocate upward inside `Truth.lean` |
| 1000-1084 | `TruthIso`, `TruthIso.toCorr`, `Truth.truthAt_of_truthIso` | **MOVE (block B)** |
| 1086-1191 | `TruthAntiIso`, `Truth.truthAt_of_truthAntiIso` | **MOVE (block B)** |
| 1193 | `end FormalSystem.Semantics` | preamble |

**Why 893-996 must stay.** `truthAt_atomFree_history_indep` is a six-case induction on `Formula`
using only `Formula.atoms` and the clause lemmas. `truthAt_gap`/`truthAt_cogap` unfold `TruthAt`
directly. `truthAt_gap_shift` and `truthAt_gap_iff_cogap` rewrite with `truthAt_gap`/`truthAt_cogap`
and then do duration-group arithmetic. None of the five touches `TruthCorr`, `TimeShift`,
`TruthIso` or `TruthAntiIso`. They are exactly what the task description calls "`TruthAt` and its
immediate corollaries".

**Why 841-891 must go.** `box_const`'s body is two applications of
`TimeShift.timeShift_preserves_truth`. Its own section docstring says so verbatim: *"This block is
placed after `TimeShift` rather than beside the other `Truth` clause lemmas because its proof
consumes `TimeShift.timeShift_preserves_truth`, which is declared there."* If `TimeShift` moves and
`box_const` stays, `Truth.lean` must import the new module, which imports `Truth.lean` — a module
cycle Lean rejects. `box_time_const` is a one-line specialization of `box_const`.

**Namespaces are preserved by the move.** Every moved declaration's fully-qualified name is
unchanged provided the new file reopens `namespace FormalSystem.Semantics` and, for the
`Truth.*`/`TimeShift.*` members, the inner namespaces. Consumers that write
`TimeShift.timeShift_preserves_truth`, `Truth.box_const`, `truthAt_of_truthCorr` etc. need **no
source change beyond the import line**.

**Preamble the new file needs** (mirroring `Truth.lean`'s own):
- the 5-line Apache copyright header (gated by `scripts/check-copyright-headers.sh`)
- `import FormalSystem.Semantics.Truth` — sufficient on its own; it transitively supplies
  `TaskModel`, `ConvexHistory`, `Syntax.Formula` (for `Formula.swapTemporal`, used by
  `truthAt_of_truthAntiIso`) and the Mathlib order lemmas (`OrderIso.addRight`, `add_sub_cancel`,
  `sub_lt_sub_right`, …) the moved bodies use
- the same `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass` guard — the moved
  material is lower-semantic-layer and G-15 applies to it exactly as it applies to `Truth.lean`
  (6 of the `Semantics/` modules carry this guard today)
- `namespace FormalSystem.Semantics`, `open FormalSystem.Syntax`, `variable {F : TaskFrame}` —
  the `variable` binder is **load-bearing**: `TimeShift.truth_history_eq`, `ShiftRel`,
  `shiftCorr`, `timeShift_preserves_truth`, `box_const` and friends all take `F` implicitly from
  it and will not elaborate without it.

**Consumers of the moved declarations** (21 live files, `Boneyard` excluded). None is in `Tests/`;
`Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` only has a `section
TimeShiftPreservation` name, not a usage.

| File | Moved names used |
|------|------------------|
| `Semantics/ShiftSet.lean` | `TimeShift.timeShift_preserves_truth` |
| `Semantics/PlusTruth.lean` | `TruthCorr` |
| `Semantics/IntTransfer.lean` | `TruthCorr`, `truthAt_of_truthCorr` |
| `Semantics/Correspondence/FwdRecPeriodicity.lean` | `TruthCorr`, `TruthIso`, `truthAt_of_truthCorr`, `box_time_const`, `TimeShift.timeShift_preserves_truth` |
| `Metalogic/Soundness.lean` | `box_const`, `TimeShift.timeShift_preserves_truth` |
| `Metalogic/SoundnessLemmas/FrameClassVariants.lean` | `TimeShift.timeShift_preserves_truth` |
| `Metalogic/Conservativity/ChainBundleTruth.lean` | `box_const` |
| `Metalogic/Conservativity/MinusLanguageSoundness.lean` | `box_const`, `ShiftRel`, `TimeShift.timeShift_preserves_truth` |
| `Metalogic/Decidability/BiLasso/{Agreement,Annotation,BoxOracle,Check,Extraction,SmallModel,TruthLemma}.lean` | `box_const`, `box_time_const`, `TimeShift.timeShift_preserves_truth` |
| `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` | `TimeShift.timeShift_preserves_truth` |
| `Metalogic/Decidability/Verified/Decidable.lean` | `TimeShift.timeShift_preserves_truth` |
| `Metalogic/Independence/CoNotPriorU.lean` | `TruthIso`, `TruthAntiIso`, `truthAt_of_truthAntiIso` |
| `Metalogic/Independence/LoopingDuration.lean` | `TruthIso`, `truthAt_of_truthIso` |
| `Metalogic/Independence/StabUndefinable.lean` | `TruthCorr`, `truthAt_of_truthCorr` |
| `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | `ShiftRel` |
| `Semantics/ConvexHistory.lean` | **prose only** — a comment at line 323 naming `TimeShift.ShiftRel` "in `Truth.lean`". Must NOT import (it sits below `Truth.lean`); update the comment text only. |

Only two of these (`ShiftSet.lean`, `PlusTruth.lean`) import `FormalSystem.Semantics.Truth`
directly; the other 19 reach it transitively.

**Import-graph facts established by transitive-closure analysis:**
- 13 of the 19 transitive consumers have `FormalSystem.Semantics.Validity` in their closure.
- The 7 `BiLasso/` consumers do **not** reach `Validity`; they reach `Truth` through
  `Metalogic/Decidability/BiLasso/Unfold.lean`, which imports `FormalSystem.Semantics.Truth`
  directly.
- `Semantics/Correspondence/Galois.lean` imports `FormalSystem.Semantics.Validity`, so the whole
  existing `Correspondence/` directory sits **above** `Validity`, which sits above `Truth`.

### External Resources

- No Mathlib search was required. The moved bodies use only Mathlib order/group lemmas already in
  scope through `Truth.lean`'s existing import set (`OrderIso.addRight`, `OrderIso.lt_iff_lt`,
  `add_sub_cancel`, `add_neg_cancel_right`, `sub_lt_self`, `sub_lt_sub_right`, `lt_add_of_pos_right`,
  `sub_pos`). Relocation cannot change their availability, because the new file imports
  `Truth.lean`.
- `scripts/check-module-invariants.sh` gate analysis (read in full for the checks a file split can
  trip):

| Check | Relevance to this split | Action required |
|-------|-------------------------|-----------------|
| C1 `lake build` | Primary gate | Detached, guarded build after each phase |
| C2/C14/C21 axiom baselines | No proof changes → axiom sets unchanged | none |
| C3 zero `sorry` | No new proofs | none |
| C4 imports resolve | New module + 4 new import lines | new file must exist before imports are added |
| C5/C12/C13 markdown path resolution | Docs naming `Semantics/Truth.lean` stay valid (file still exists); new file should be added to READMEs | update `Semantics/README.md` row 26 and, if placed there, `Correspondence/README.md` |
| C8 aggregator convention (`X.lean` beside `X/`, no `X/X.lean`) | Satisfied by either candidate location | none |
| C15 paper anchors | `lem:history-time-shift-preservation`, `def:time-shift-histories`, `app:auto_existence` are **name-based**, not path-based, in `specs/paper-definitions-of-record.md` | none |
| C16 env_linter / `nolints.json` | Relocation does not create new linter findings; no `@[simp]` in the moved set | none expected; re-check after build |
| C19 docstring coverage (reported) | New file inherits all docstrings verbatim; give it a module docstring | write module docstring |
| C20 tier 1 (gated, repo-wide) | **No `file.lean:NNN` citation exists anywhere in lines 579-1193**, and every `Truth.lean:NNN` citation in the repo lives under `specs/`, which C20's walker excludes | none |
| C20 tier 2 (**enforced**, `ENFORCE_C20` defaults to `1`) | Publication scope includes `.lean` files whose directory is exactly `FormalSystem/Semantics` — i.e. a file placed at `Semantics/TruthTransport.lean` is in scope and must carry zero `file.lean:NNN` citations. The moved region carries none. | keep it that way |
| C24 `checkInitImports` | Every module in the root closure must transitively import `FormalSystem.Init` | add the new module to `FormalSystem/Semantics.lean`; it inherits `Init` through `Truth.lean` |
| INV generated inventory blocks | `Semantics/` and `Correspondence/` have **no** `<!-- BEGIN GENERATED: inventory -->` block (only `Semantics/Frames/` and `Semantics/Ultraproduct/` do) | none |
| `scripts/readme-lint.sh` check 2 ("every `.lean` listed in its README") | **reported, not gated** | still update READMEs for quality |

### Recommendations

**Destination file.** `FormalSystem/Semantics/TruthTransport.lean`, a sibling of `Truth.lean`.
Rationale in Decisions below. If the user prefers the review's literal wording, the same content
goes to `FormalSystem/Semantics/Correspondence/TruthShift.lean` with no other change to the plan
except the import paths and the `Correspondence/README.md` "Imports from / Imported by" contract,
which would have to be rewritten.

**Phase shape** (each phase independently green and committable):

1. **Create the new module, content-complete, and register it.**
   - Write `FormalSystem/Semantics/TruthTransport.lean`: copyright header, `import
     FormalSystem.Semantics.Truth`, the `assert_not_exists` guard, module docstring, `namespace
     FormalSystem.Semantics` / `open FormalSystem.Syntax` / `variable {F : TaskFrame}`, then
     **block A verbatim** (`Truth.lean` lines 579-891, which already contains its own `namespace
     Truth` at 841 — close it with `end Truth`), then **block B verbatim** (lines 1000-1191),
     then `end FormalSystem.Semantics`.
   - Add `import FormalSystem.Semantics.TruthTransport` to `FormalSystem/Semantics.lean`,
     immediately after the `FormalSystem.Semantics.Truth` line.
   - At this point the declarations exist **twice** (once in each file) and the build will fail on
     duplicates — so phase 1 and phase 2 are a single atomic commit, or phase 1 deletes as it
     writes. Recommended: do the cut-and-paste as one edit pair inside one phase.
2. **Cut `Truth.lean` down.**
   - Delete lines 579-891 and 1000-1191.
   - Move the block at 893-996 upward so it sits immediately before the `end Truth` at line 577
     (dropping the now-orphaned `namespace Truth` at 841 and its matching `end Truth` at 998).
     The `/-! ## A-17: history-independence and the gap formula` section comment travels with it
     unchanged.
   - Edit the module docstring: the bullet at line 84 ("Time-shift preservation theorems for
     temporal operators") now describes the other file; replace it with a pointer to
     `TruthTransport.lean`.
   - Expected result: `Truth.lean` ≈ 683 lines, `TruthTransport.lean` ≈ 537 lines.
3. **Repair imports.** Add `import FormalSystem.Semantics.TruthTransport` to exactly four files:
   - `FormalSystem/Semantics/Validity.lean` (covers 13 transitive consumers, including all of
     `Metalogic/Independence/`, `Metalogic/Soundness.lean`, `Metalogic/Conservativity/`,
     `Metalogic/Decidability/Verified/`, `Semantics/IntTransfer.lean` and
     `Semantics/Correspondence/FwdRecPeriodicity.lean`)
   - `FormalSystem/Semantics/ShiftSet.lean`
   - `FormalSystem/Semantics/PlusTruth.lean`
   - `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean` (covers the 7 `BiLasso/` consumers)

   **Variant, if explicit-import style is preferred over relying on re-export:** add the import to
   all 21 consumer files from the table above instead. Strictly more churn, strictly more robust
   to future import-graph edits, and every one of the 21 genuinely uses a moved name so no
   unused-import finding results. Both variants are correct; the 4-file version is what the task's
   "update import lines in whatever currently reaches the moved declarations via Semantics.Truth"
   most directly describes.
4. **Docs.** Update `FormalSystem/Semantics/README.md` line 26 (split the `Truth.lean` row: it
   currently advertises `TruthCorr`, `truthAt_of_truthCorr`, `timeShift_preserves_truth`,
   `TruthIso`/`TruthAntiIso` as `Truth.lean` contents) and add a `TruthTransport.lean` row. Fix
   `Semantics/ConvexHistory.lean:323`, which names `TimeShift.ShiftRel` as living "in
   `Truth.lean`".
5. **Verify.** Detached, guarded `lake build`, then `bash scripts/check-module-invariants.sh`.

**Sorry-free path exists trivially** — this task authors no proof. The zero-debt gate is satisfied
by construction as long as every moved body is copied byte-for-byte.

## Decisions

- **D1: Split into three blocks, not one.** The review's "line 623 to the end" boundary is
  approximately right but crosses a block of genuine `TruthAt` corollaries (893-996). Those stay.
  Recorded because it is a deliberate departure from the literal recommended fix, made on
  evidence from reading the proofs.
- **D2: `box_const`/`box_time_const` move with `TimeShift`.** Forced by the dependency, not a
  preference. Their presence in the new file is what makes the file "truth transport *and its
  immediate consequences*" rather than only transport.
- **D3: Destination is `Semantics/TruthTransport.lean` rather than
  `Semantics/Correspondence/TruthShift.lean`.** Two independent reasons, both from repo
  documentation rather than taste:
  1. *Subject.* `Correspondence/README.md` opens "Correspondence — the frame-class Galois layer"
     and describes its contents as the `Th`/`Mod` adjunction, the indicator mechanism, and the
     duration-level correspondence theorems `app:discrete`/`app:dense`/`app:complete`. That is
     **frame** correspondence (formula ↔ frame property). `TruthCorr`/`TruthIso`/`TruthAntiIso`/
     `TimeShift` are **model-to-model truth transport**. Filing the latter under the former trades
     one conflation for another.
  2. *Layering.* `Correspondence/README.md` states its dependency contract as *"Imports from:
     `FormalSystem.Semantics.Validity` …"*, and every existing member reaches `Validity` (via
     `Galois.lean`). The moved material must be importable by `Validity.lean`, `ShiftSet.lean` and
     `PlusTruth.lean`, all of which sit *below* `Validity`. Placing it in `Correspondence/` makes
     that directory simultaneously the top and the bottom of the `Semantics/` import order.

  The review's own phrasing is `(e.g. Semantics/Correspondence/TruthShift.lean)` — advisory, not
  mandated — which is what makes this a research decision rather than a contradiction of the task.
  It is nonetheless surfaced as a non-blocking `user_decision` because it visibly differs from the
  location the review named.
- **D4: Name `TruthTransport.lean`, not `TruthShift.lean`.** The file holds `TruthCorr`,
  `TruthIso` and `TruthAntiIso` as well as the time-shift instance; "shift" names only one of the
  four. `Semantics/README.md` already uses the phrase "the relational truth transport" for this
  material.
- **D5: 4-file import repair as the default, 21-file as a documented variant.** Chosen to keep the
  diff proportional to a pure relocation.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Duplicate-declaration build failure if the new file is created before `Truth.lean` is cut | Treat create + cut as one atomic edit pair within a single phase; do not commit an intermediate state where both files declare `TruthCorr` |
| Missing `variable {F : TaskFrame}` in the new file → `unknown identifier F` on ~8 declarations | Named explicitly in the preamble checklist above; the first `lake build` catches it immediately |
| Missing `open FormalSystem.Syntax` → `Formula`, `Atom`, `Formula.swapTemporal` unresolved | Same |
| `box_const` accidentally left in `Truth.lean` → import cycle, reported by Lean as "invalid import" rather than as a missing lemma | D2 is called out explicitly; the cycle is detected on the first build |
| A consumer reached the moved names through an import path this analysis did not enumerate | The transitive-closure analysis was computed mechanically over all `FormalSystem/**` imports; residual risk is covered by C1 (`lake build`), which fails loudly on any unresolved name |
| `Semantics/ConvexHistory.lean:323` prose left stale | Listed as an explicit phase-4 item; `readme-lint` will not catch it (it is a `.lean` comment) |
| C20 tier 2 is **enforced** and `Semantics/*.lean` is publication scope | The moved region contains zero `file.lean:NNN` citations; the implementer must not introduce any in the new module docstring — cite declaration names instead |
| Long build livelock | Every `lake build` runs detached via `Bash(run_in_background: true)` through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …`, per `context/project/lean4/operations/long-builds.md` |

**Pre-existing defect noticed, not caused by this task** (optional drive-by fix): the docstring of
`truthAt_gap_iff_cogap` at `Truth.lean:972` refers to `truthAt_cogap_iff_gap`, which does not
exist anywhere in the tree — the theorem it means is `truthAt_gap_iff_cogap` itself. This block
stays in `Truth.lean`, so the typo can be corrected in passing or left alone; it affects no gate.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task authors no proof: every moved body is
  relocated verbatim, so there is no goal to close and no tactic to select. The only verification
  instrument is `lake build` plus `scripts/check-module-invariants.sh`.

## Context Extension Recommendations

- **Topic**: Lean module-split mechanics under this repo's invariant harness
- **Gap**: There is no context file describing which of `check-module-invariants.sh`'s 25 checks a
  pure file split can trip (C4, C5, C20 tier 2, C24, INV) versus which are structurally immune
  (C2, C3, C14, C15, C21). This analysis had to be re-derived by reading the 2,000-line script.
- **Recommendation**: Add `context/project/lean4/patterns/module-split-checklist.md` capturing the
  preamble checklist (copyright header, `assert_not_exists`, `namespace`/`open`/`variable`
  replication, aggregator registration) and the gate-impact table from the External Resources
  section above.

- **Topic**: `Semantics/` directory layering contract
- **Gap**: The `Correspondence/` README states an "Imports from / Imported by" contract that no
  script enforces, so a future split can silently invert it (as this one nearly did).
- **Recommendation**: Either note the contract in `FormalSystem/Semantics/README.md` as a
  tree-wide layering statement, or add a directory-level import-direction assertion to
  `check-module-invariants.sh`.

## Appendix

**Searches and analyses performed**
- `grep -rln '^import FormalSystem.Semantics.Truth$'` — 17 direct importers
- `grep -rn 'TruthCorr|TruthIso|TruthAntiIso|ShiftRel|shiftCorr|TimeShift\.|truthAt_of_truth*|box_const|box_time_const'` over `FormalSystem/` + `Tests/`, `Boneyard` excluded — 21 live consumers + 1 prose-only
- Python transitive-import-closure computation over all `FormalSystem/**/*.lean` — established the
  `Validity` / `BiLasso.Unfold` gateway split (13 + 7)
- `grep -n 'Truth\.lean:[0-9]'` repo-wide — all hits under `specs/`, which C20's walker excludes
- `sed -n '579,1193p' … | grep '\.lean:[0-9]'` — zero `file:line` citations in the moved region
- Read in full: `scripts/check-module-invariants.sh` header (C1-C25 definitions) and the C20 body;
  `FormalSystem/Semantics/Correspondence/README.md`; `FormalSystem/Semantics.lean`
- Baseline `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --` — exit code 0
  (tree green before any edit)

**Lean MCP tools**: not used. The task requires no goal inspection, lemma search or tactic
selection; every question was a file-structure or import-graph question answered by direct reading.

**References**
- `specs/reviews/review-2026-09-15.md` — Finding H2, the originating review
- `FormalSystem/Semantics/Correspondence/README.md` — the Galois-layer charter and dependency
  contract that motivates D3
- `.claude/context/project/lean4/operations/long-builds.md` — detached + guarded build contract
