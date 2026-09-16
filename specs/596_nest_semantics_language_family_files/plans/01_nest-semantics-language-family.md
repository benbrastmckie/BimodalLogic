# Implementation Plan: Task #596

- **Task**: 596 - Nest the flat `Semantics/` language-family files into per-language subdirectories; write `FormalSystem/ForMathlib/README.md`
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (precedent: `Syntax/*Language/` nesting, commit `2acf1371c`)
- **Research Inputs**: specs/596_nest_semantics_language_family_files/reports/01_nest-semantics-language-family.md
- **Artifacts**: plans/01_nest-semantics-language-family.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Move the 15 L⁻/L⁺/L⋆ semantics files (`Minus*` x4, `Plus*` x6, `Star*` x5) from the flat
`FormalSystem/Semantics/` into `Semantics/MinusLanguage/`, `Semantics/PlusLanguage/`,
`Semantics/StarLanguage/`, mirroring the `Syntax/` layout exactly: same directory names, sibling
aggregators `Semantics/{X}Language.lean` imported from the root aggregator, one README per new
subdirectory, basenames and namespaces unchanged. Then extend the C8 aggregator invariant to walk
`FormalSystem/Semantics` (which surfaces 5 pre-existing violations that must be fixed in the same
change), repoint every path citation, and write the missing `FormalSystem/ForMathlib/README.md`.
Module-path-only change: no declaration, namespace, or proof is touched.

### Research Integration

The research report established: a fully green baseline (harness `--no-build` + `readme-lint.sh`);
the exact 55 import lines across 29 files; the full non-import citation list (~50 files, zero in
`typst/`); that adding `FormalSystem/Semantics` to C8's tuple exposes 5 existing violations
(`Correspondence/`, `Extension/`, `Frames/`, `Ultraproduct/` lack sibling aggregators;
`Extension/Extension.lean` trips the self-named rule); that `FormalSystem.Semantics.{MinusTruth,
MinusValidity,PlusTruth,StarTruth}` are also live namespaces, so rewrites must be anchored to
`^import` lines and path contexts; that prefixed basenames must be kept to avoid new basename
collisions (`Truth.lean`, `Validity.lean`); and that the `ForMathlib` dependency rule must be
stated precisely (nothing *under* `ForMathlib/` imports `FormalSystem.*`; the aggregator's
`import FormalSystem.Init` is the recorded C24 exception).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- 15 files live under `Semantics/{Minus,Plus,Star}Language/` with basenames unchanged (`git mv`).
- Sibling aggregators `Semantics/{Minus,Plus,Star}Language.lean`, imported by `FormalSystem/FormalSystem.lean`.
- C8 walks `FormalSystem/Semantics` and passes (4 new aggregators + 1 allowlist entry).
- Every import and path citation (docstrings, READMEs, `docs/`, `README.md`, `NOTATION.md`) repointed.
- `FormalSystem/ForMathlib/README.md` written; `FormalSystem/README.md` ForMathlib row updated.
- Acceptance: `lake build` green; `check-module-invariants.sh` passes (C4, C5, C6, C8, C12, C13, C15, INV, C20, C24); `readme-lint.sh` exit 0.

**Non-Goals**:
- Renaming any declaration or namespace, or stripping `Minus`/`Plus`/`Star` basename prefixes.
- Moving `DeterministicBridge.lean` or `StateLocalTransfer.lean` (cross-language bridges stay at `Semantics/` root).
- Renaming `Semantics/Extension/Extension.lean` (allowlisted instead).
- Basename-citation disambiguation and paper-vocabulary reconciliation (later tasks).
- Optional polish of basename-only citations (they remain valid with basenames kept).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Global dotted-name sed corrupts live namespaces (`namespace PlusTruth`) | H | M | Anchor `.lean` rewrites to `^import FormalSystem\.Semantics\.(Minus\|Plus\|Star)`; edit prose by hand from the enumerated list; never a bare dotted substitution |
| C8 extension fails on 5 pre-existing violations | M | H (known) | Phase 3 adds the 4 aggregators and allowlists `Extension/Extension.lean` in the same phase as the tuple change |
| New aggregators unreachable from root (C6) | M | M | Import the 3 language aggregators from `FormalSystem/FormalSystem.lean`; import the 4 structural aggregators from `Semantics.lean` |
| Territory wider than `file_scope` (Metalogic, Syntax, Tests, docs, README, NOTATION) | M | H | Declared explicitly per phase below; implementer commits touch only the enumerated files |
| Concurrent edit of `PlusDeterminism.lean` by the smoke-test-relocation task (594) | M | L | Check `git status`/`git log` on the 15 files before `git mv`; if dirty from another session, stop and report rather than moving |
| Long rebuild (Conservativity/Independence/Deterministic invalidated) | L | H | Use the guarded detached build per `.claude/context/project/lean4/operations/long-builds.md`, not inline `lake build` |
| Stale `.olean`s for old module paths mislead LSP | L | M | Restart the LSP after the move; trust `lake build` over LSP diagnostics |
| INV hand-maintained table in `Semantics/README.md` drifts | M | M | Rewrite rows in Phase 4 and verify with harness INV + `--emit-inventory --check` in Phase 6 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 5 | 2 |
| 3 | 4 | 1, 2, 3 |
| 4 | 6 | 4, 5 |

Phases within the same wave can execute in parallel. Territory: Phase 1 owns
`FormalSystem/ForMathlib/README.md` and the ForMathlib row of `FormalSystem/README.md`; Phase 2
owns all `.lean` import lines and the 15 moved files; Phase 4 owns `.lean` docstrings and READMEs
under `FormalSystem/` (except Phase 1's row); Phase 5 owns top-level `README.md`, `NOTATION.md`
and `docs/**`. Phases 4 and 5 are file-disjoint.

### Phase 1: ForMathlib README [NOT STARTED]

**Goal**: Write `FormalSystem/ForMathlib/README.md` and update the parent README's row.

**Tasks**:
- [ ] Confirm the dependency rule mechanically: `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returns nothing; read `FormalSystem/ForMathlib.lean` and `FormalSystem/Init.lean` for the exact wording of the rule and the C24 exception.
- [ ] Write `FormalSystem/ForMathlib/README.md` modeled on `FormalSystem/ForMathlib/Order/README.md` / `FormalSystem/Semantics/Frames/README.md`: title; purpose (Mathlib-shaped extensions in Mathlib's own namespaces, names one-for-one with dualised Mathlib declarations, deleted here on upstreaming); dependency rule `Mathlib -> ForMathlib -> FormalSystem.* -> downstream`, stated precisely (nothing under `ForMathlib/` imports `FormalSystem.*`; the sibling aggregator `ForMathlib.lean` carries `import FormalSystem.Init` as the documented C24 exception); Modules section with a `<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib -->` block (or a hand row for `Order/` linking `Order/README.md`, whichever the harness expects for a directory with no loose `.lean`); Related Documentation links (`../ForMathlib.lean`, `Order/README.md`, `../Metalogic/Algebraic/README.md`, `../README.md`); `*Last verified: 2026-09-16*`.
- [ ] Update `FormalSystem/README.md` (~line 310): replace "no README yet" with the linked form `[ForMathlib/](ForMathlib/README.md)`, matching the `Semantics/` row.
- [ ] No task-number references in the README (deliverable rule).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/ForMathlib/README.md` - new
- `FormalSystem/README.md` - ForMathlib row only

**Verification**:
- `bash scripts/readme-lint.sh` exit 0 (check 3 resolves the new relative links).
- If a generated inventory block was used: `bash scripts/check-module-invariants.sh --emit-inventory` then `--check` clean for `dir=FormalSystem/ForMathlib`.

---

### Phase 2: Move files, create language aggregators, rewrite imports [NOT STARTED]

**Goal**: Relocate the 15 files and make the tree build again, in one atomic batch.

**Tasks**:
- [ ] Pre-check: `git status --short FormalSystem/Semantics/` shows none of the 15 files dirty from another session; otherwise stop and report.
- [ ] `mkdir -p FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage}`; `git mv` each file, basename unchanged:
  - `MinusLanguage/`: `MinusFrame`, `MinusSchemaValidity`, `MinusTruth`, `MinusValidity`
  - `PlusLanguage/`: `PlusDeterminism`, `PlusNonValidities`, `PlusPasting`, `PlusStateLocal`, `PlusTruth`, `PlusValidity`
  - `StarLanguage/`: `StarDeterminism`, `StarNonValidities`, `StarStateLocal`, `StarTruth`, `StarValidity`
- [ ] Rewrite import lines with an anchored sed over `FormalSystem/**/*.lean` and `Tests/**/*.lean` only, three expressions of the form `s/^import FormalSystem\.Semantics\.(Minus[A-Za-z]+)$/import FormalSystem.Semantics.MinusLanguage.\1/` (same for `Plus`, `Star`). Restrict the capture to the 15 basenames if any other `Semantics.Minus*/Plus*/Star*` module could match (research found none).
- [ ] `FormalSystem/Semantics.lean`: delete the 15 now-rewritten language-family import lines (do not replace them).
- [ ] Create `FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage}.lean`, modeled on `FormalSystem/Syntax/PlusLanguage.lean`: copyright header, imports of every member module, `/-!` docstring with a Modules list. No declarations.
- [ ] `FormalSystem/FormalSystem.lean`: add `import FormalSystem.Semantics.MinusLanguage`, `...PlusLanguage`, `...StarLanguage` immediately after `import FormalSystem.Semantics`.
- [ ] Guarded detached `lake build` per `long-builds.md`; restart LSP afterwards.
- [ ] Fallback if a consumer of `FormalSystem.Semantics` breaks: have `Semantics.lean` import the three new aggregators (closure-preserving) and record the deviation.
- [ ] Commit once green (single atomic commit including renames, aggregators, imports).

**Timing**: 1.5 hours (build wall time dominates)

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 55 import lines across 29 files (15 in `Semantics.lean`); consumers outside `Semantics/` are in `Metalogic/Independence`, `Metalogic/Conservativity`, `Metalogic/Deterministic/Validity.lean` and `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`. Confirm before and after with `grep -rn "import FormalSystem.Semantics.\(Minus\|Plus\|Star\)" --include=*.lean FormalSystem Tests` (before: 55 hits; after: 0 hits of the old flat form, and every hit carries a `{Minus,Plus,Star}Language.` segment).

**Files to modify**:
- 15 moved files under `FormalSystem/Semantics/{Minus,Plus,Star}Language/` - path + import lines only
- `FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage}.lean` - new aggregators
- `FormalSystem/Semantics.lean` - remove 15 imports
- `FormalSystem/FormalSystem.lean` - add 3 imports
- `FormalSystem/Semantics/{DeterministicBridge,StateLocalTransfer}.lean` - imports
- `FormalSystem/Metalogic/**` (enumerated in research report) - imports
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` - imports

**Verification**:
- `lake build` green (guarded detached).
- `bash scripts/check-module-invariants.sh --no-build`: C4 (import resolution) and C6 (reachability) pass. Other checks (INV, C12, C15, C5) may be red here pending Phases 4-5; record which.
- `git diff -M --stat` shows the 15 files as renames with small diffs (import lines only).

---

### Phase 3: Extend C8 to `FormalSystem/Semantics` [NOT STARTED]

**Goal**: Add `Semantics` to C8's walked parents and resolve the 5 violations it surfaces.

**Tasks**:
- [ ] Re-run C8's logic (or the harness with `Semantics` temporarily added) to confirm the violation list is exactly: no sibling for `Correspondence/`, `Extension/`, `Frames/`, `Ultraproduct/`; self-named `Extension/Extension.lean`. The new `{Minus,Plus,Star}Language/` dirs must already pass.
- [ ] Create sibling aggregators `FormalSystem/Semantics/{Correspondence,Extension,Frames,Ultraproduct}.lean`, each importing exactly the modules of its subdirectory with a `/-!` Modules docstring.
- [ ] In `FormalSystem/Semantics.lean`, replace the per-module imports of those four subdirectories with imports of the new aggregators (closure-identical), keeping the aggregators C6-reachable. If `Semantics.lean` imports only a subset of a subdirectory today, import the aggregator only if closure grows harmlessly; otherwise import the aggregator in addition to confirm reachability and note it.
- [ ] `scripts/check-module-invariants.sh`: add `"FormalSystem/Semantics"` to the C8 parent tuple (line ~953); add `"FormalSystem/Semantics/Extension/Extension.lean"` to `C8_ALLOW_SELFNAMED` with a comment that it is the extension theorem's content module, not an aggregator; update the header comment (~line 17), the C8 PASS message, and the explanatory comment block, including one sentence that adding a parent re-scopes every existing subdirectory beneath it.
- [ ] Guarded detached `lake build` (new aggregator modules must compile).
- [ ] Commit.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: Exactly 5 C8 violations surface, fixed by 4 aggregators + 1 allowlist entry. Confirm by running C8 with the extended tuple before adding the fixes; if the list differs, fix whatever it reports and record the deviation.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C8 tuple, allowlist, comments, PASS text
- `FormalSystem/Semantics/{Correspondence,Extension,Frames,Ultraproduct}.lean` - new aggregators
- `FormalSystem/Semantics.lean` - swap subdirectory imports for aggregators

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh --no-build`: C8 PASS, C4/C6 still PASS.

---

### Phase 4: In-tree READMEs and Lean docstring citations [NOT STARTED]

**Goal**: New subdirectory READMEs and every path citation under `FormalSystem/` and `Tests/` repointed.

**Tasks**:
- [ ] Write `FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage}/README.md`, modeled on `FormalSystem/Syntax/PlusLanguage/README.md`: purpose, Modules section with `<!-- BEGIN GENERATED: inventory dir=... -->` block, pointer to the Syntax-side counterpart and back to `../README.md`, `*Last verified: 2026-09-16*`.
- [ ] `FormalSystem/Semantics/README.md` hand-maintained INV table: remove the 15 file rows; add directory rows `MinusLanguage/`, `PlusLanguage/`, `StarLanguage/` (linking their READMEs) and loose-file rows for the 7 new aggregators (`MinusLanguage.lean`, `PlusLanguage.lean`, `StarLanguage.lean`, `Correspondence.lean`, `Extension.lean`, `Frames.lean`, `Ultraproduct.lean`). No phantom rows.
- [ ] `FormalSystem/Semantics.lean` docstring: update the submodule list; state that language-family modules are aggregated at the root via `Semantics/{X}Language.lean` and that `Semantics.lean` still reaches much of L⁺/L⋆ transitively through `DeterministicBridge`/`StateLocalTransfer`.
- [ ] Repoint non-import citations (slash form `Semantics/PlusTruth.lean` -> `Semantics/PlusLanguage/PlusTruth.lean`; dotted module form `FormalSystem.Semantics.PlusTruth` -> `FormalSystem.Semantics.PlusLanguage.PlusTruth` only where it denotes a module, never a namespace) in the files enumerated by the research report: the 15 files' self-citations; `Semantics/{FrameProperty,TruthClauses,DeterministicBridge,StateLocalTransfer}.lean`; `Syntax/{Minus,Plus,Star}Language.lean` and their READMEs (StarLanguage README ~16 hits; `Syntax/MinusLanguage/README.md:58` C5 dotted mention; `Syntax/PlusLanguage/README.md:86` glob "`Plus*.lean` semantics modules" -> `Semantics/PlusLanguage/`); `Syntax/{PlusLanguage/Axioms,PlusLanguage/Formula,StarLanguage/Axioms,StarLanguage/Embedding,StarLanguage/Formula,MinusLanguage/Formula}.lean`; `Syntax/README.md`; `Metalogic.lean` (incl. `Semantics/Plus*.lean` glob at ~line 58), `Metalogic/README.md`, `Metalogic/Soundness.lean`; `Metalogic/Conservativity{.lean,/README.md}` and its `ChainBundleTruth`, `MinusLanguageSoundness`, `SpCountermodel`, `SpWitness`, `TMCompletenessReduction`, `Plus{.lean,/README.md,/Atomization,/AxiomValidity,/Corollaries}`, `Star{.lean,/README.md,/Forward,/StarAxiomValidity,/StarPasting,/StarSoundness}`; `Metalogic/Deterministic/{Completeness,Erasure,README.md,Soundness,System,Validity}`; `Metalogic/Independence{.lean,/README.md}` and its `CoarsenedModels`, `DeterminismUndefinable`, `DriftFrame`, `ForwardDeterministicFrame`, `OrderTransfer`, `PastingIndependence`, `RealTranslationFrame`, `StabUndefinable`, `StarDiscrimination`; `FormalSystem/README.md` (not the ForMathlib row).
- [ ] Relative link fix: `FormalSystem/Metalogic/Conservativity/Plus/README.md:85` `../../../Semantics/PlusTruth.lean` -> `../../../Semantics/PlusLanguage/PlusTruth.lean`.
- [ ] Add a one-line "Language family" pointer from `Syntax/README.md` to the Semantics-side directories.
- [ ] Edits in `.lean` files stay inside `/-! -/`, `/-- -/` or `--` comments; no code line changes.
- [ ] Commit (per logical group is fine; each commit green under `readme-lint.sh`).

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: prose

**Scope Hypothesis**: ~40 files under `FormalSystem/` carry non-import citations (list above, from the research report). Confirm with the residue grep below restricted to `FormalSystem Tests`; any extra hit is in scope.

**Files to modify**:
- New: `FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage}/README.md`
- `FormalSystem/Semantics/README.md`, `FormalSystem/Semantics.lean` (docstring), and the enumerated `FormalSystem/**` files above

**Verification**:
- Residue grep (restricted to `FormalSystem Tests`) returns only new-form paths: `grep -rnE 'Semantics[/.](Minus(Frame|SchemaValidity|Truth|Validity)|Plus(Determinism|NonValidities|Pasting|StateLocal|Truth|Validity)|Star(Determinism|NonValidities|StateLocal|Truth|Validity))\b' FormalSystem Tests` -> 0 hits (new forms contain `Language/` or `Language.` between and do not match). Remaining matches must be namespace uses only, each inspected.
- `git diff` read-through: every `.lean` hunk is inside a comment.
- `bash scripts/readme-lint.sh` exit 0.
- Harness `--no-build`: INV passes for `dir=FormalSystem/Semantics`.

---

### Phase 5: Top-level docs citations [NOT STARTED]

**Goal**: Repoint citations in `README.md`, `NOTATION.md` and `docs/**`.

**Tasks**:
- [ ] `README.md` ~lines 262-266 (including the `Semantics/Plus*.lean` glob -> `Semantics/PlusLanguage/`).
- [ ] `NOTATION.md:83`.
- [ ] `docs/theorem-index.md`: 5 File cells (~lines 155-158, 179: `StarStateLocal` x2, `PlusStateLocal` x2, `PlusValidity` x1) -> new paths (C15 half 2).
- [ ] `docs/development/MODULE_ORGANIZATION.md`: lines ~195, 199 (directory tree: add `Semantics/{Minus,Plus,Star}Language/`), ~335, 343, 345 (C5 dotted module names -> `FormalSystem.Semantics.MinusLanguage.MinusTruth` etc.); extend the module-vs-namespace paragraph (~lines 84-95) to cover the Semantics directories and note that `FormalSystem.Semantics.PlusTruth` now names only a namespace.
- [ ] `docs/reference/API_REFERENCE.md:816-817`, `docs/project-info/implementation-status.md:84`, `docs/project-info/known-limitations.md:295-296`.
- [ ] Commit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: ~7 files outside `FormalSystem/` with the line numbers above; zero hits in `typst/`. Confirm with the residue grep over `README.md NOTATION.md docs typst`.

**Files to modify**:
- `README.md`, `NOTATION.md`, `docs/theorem-index.md`, `docs/development/MODULE_ORGANIZATION.md`, `docs/reference/API_REFERENCE.md`, `docs/project-info/implementation-status.md`, `docs/project-info/known-limitations.md`

**Verification**:
- Residue grep over `README.md NOTATION.md docs typst` returns 0 old-form hits.
- Harness `--no-build`: C5, C12, C13, C15 pass.

---

### Phase 6: Inventory refresh and final gate [NOT STARTED]

**Goal**: Regenerate inventory blocks and run the complete acceptance gate.

**Tasks**:
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory` (refreshes generated blocks: new READMEs, `FormalSystem/README.md` `Semantics.lean` line count, etc.), then `--emit-inventory --check` clean.
- [ ] Full `bash scripts/check-module-invariants.sh` (with build) via the guarded detached pattern: every gated check passes, including C1, C2, C4, C5, C6, C8, C12, C13, C14, C15, C20, C24, C25, INV.
- [ ] `bash scripts/readme-lint.sh` exit 0.
- [ ] Repo-wide residue grep (research report's command, excluding `.lake,.git,specs,.claude,agent-system`, minus `:import `) returns no old-form paths.
- [ ] `bash .claude/scripts/check-task-references.sh` clean for new/edited deliverables.
- [ ] Commit; commit body notes that the 15 files left C20 tier-2 loose-file scope (harmless: zero `file.lean:NNN` citations).

**Timing**: 0.5 hours (plus build wall time)

**Depends on**: 4, 5

**Verification Tier**: full

**Files to modify**:
- Generated inventory blocks in READMEs (tool-written)

**Verification**:
- All three acceptance commands green as listed above.

## Testing & Validation

- [ ] `lake build` green (guarded detached build)
- [ ] `bash scripts/check-module-invariants.sh` passes all gated checks (C8 now walking `FormalSystem/Semantics`; C13/C15 citations)
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` clean
- [ ] `bash scripts/readme-lint.sh` exit 0
- [ ] Residue grep for old flat paths returns nothing outside `specs/`
- [ ] `git diff -M` shows the 15 files as renames; no declaration or namespace line changed (`git diff -M -- FormalSystem/Semantics/*Language/ | grep -E '^[-+](namespace|end|theorem|lemma|def)'` empty)

## Artifacts & Outputs

- `FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage}/` (15 moved files + 3 READMEs)
- `FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage,Correspondence,Extension,Frames,Ultraproduct}.lean` (7 new aggregators)
- `FormalSystem/ForMathlib/README.md`
- Updated `scripts/check-module-invariants.sh` (C8)
- Updated citations across `FormalSystem/`, `docs/`, `README.md`, `NOTATION.md`
- `specs/596_nest_semantics_language_family_files/summaries/01_nest-semantics-language-family-summary.md`

## Rollback/Contingency

Each phase is a separate commit, so rollback is `git revert` of the offending phase commit(s) in
reverse order (Phase 2's atomic commit reverts cleanly as renames). If Phase 2's build fails and
cannot be fixed within the phase, apply the closure-preserving fallback (`Semantics.lean` imports
the three language aggregators) before considering a revert. If Phase 3's C8 violation set differs
materially from the 5 expected, fix what is reported; if a fix would require renaming a content
module, allowlist it instead and record the choice in the C8 comment block.
