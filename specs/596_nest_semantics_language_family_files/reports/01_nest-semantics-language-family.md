# Research Report: Task #596

**Task**: 596 - Nest the flat `Semantics/` language-family files into per-language subdirectories; write `FormalSystem/ForMathlib/README.md`
**Started**: 2026-09-16T00:00:00Z
**Completed**: 2026-09-16T00:40:00Z
**Effort**: ~2-3 hours implementation (mechanical; one full guarded `lake build` + harness run dominates wall time)
**Dependencies**: None (precedent: the `Syntax/*Language/` nesting, commit `2acf1371c`)
**Sources/Inputs**: - Codebase (grep/ls over `FormalSystem/`, `Tests/`, `docs/`, `typst/`, `scripts/`), `scripts/check-module-invariants.sh` (C5, C8, C12, C13, C15, C20, INV), `scripts/readme-lint.sh`, `specs/reviews/review-2026-09-15.md` (M1, M2, M3), baseline harness run `--no-build`
**Artifacts**: - specs/596_nest_semantics_language_family_files/reports/01_nest-semantics-language-family.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Baseline is fully green: `check-module-invariants.sh --no-build` passes every gated check
  (C8, C13, C15 both halves, INV, C5, C12, C20), and `readme-lint.sh` exits 0. Anything red
  after the move was caused by the move.
- **Blast radius**: 55 `import` lines across 29 files (15 in `Semantics.lean` alone), plus
  non-import path citations in ~50 further files (docstrings, READMEs, `docs/`, `NOTATION.md`,
  `README.md`). **Zero hits in `typst/`**, `lakefile.lean`, `scripts/*.txt`, `nolints.json`,
  `Boneyard/`, `.claude/` or `agent-system/`. Nothing under `Tests/` besides
  `ValidityLayerTest.lean` (2 imports).
- **Recommended layout**: `Semantics/MinusLanguage/`, `Semantics/PlusLanguage/`,
  `Semantics/StarLanguage/` (same names as `Syntax/`), each with a sibling aggregator
  `Semantics/{X}Language.lean` and a `README.md`. **Keep the prefixed basenames**
  (`Semantics/PlusLanguage/PlusTruth.lean`, not `.../Truth.lean`): stripping prefixes would
  create new basename collisions (`Truth.lean`, `Validity.lean`) that break C20's basename
  resolution and pre-empt the later basename-disambiguation task.
- **Hidden cost of the C8 tuple change**: adding `FormalSystem/Semantics` to C8's walked
  parents exposes **5 pre-existing violations**, not 0: `Correspondence/`, `Extension/`,
  `Frames/`, `Ultraproduct/` have no sibling aggregator, and `Semantics/Extension/Extension.lean`
  trips the self-named-aggregator rule. The plan must add 4 aggregators and allowlist (or
  rename) `Extension/Extension.lean`.
- **Sed hazard**: `FormalSystem.Semantics.{MinusTruth,MinusValidity,PlusTruth,StarTruth}` are
  also live *namespaces* (`namespace MinusValidity`, `end PlusTruth`, ...). Rewrites must be
  anchored to `^import ` lines in `.lean` and to path/module contexts in prose, never a global
  dotted-name substitution. Today there are no dotted declaration-name uses in text, but a
  blind rewrite would still be wrong in principle and would silently corrupt any added later.
- A sorry-free/zero-debt path is trivial: no declaration, namespace, or proof changes.

## Context & Scope

Researched: the 15 files' import graph, every consumer, every textual citation, the precedent
commit for `Syntax/` nesting, the invariant harness checks the acceptance names (C8, C13, C15)
plus the ones a path move actually touches (C4, C5, C12, C20, INV), `readme-lint.sh` checks 1
and 3, and the ForMathlib dependency rule. Not researched: Mathlib (no lemma discovery is
involved), proof content.

Constraint from the task: module-path-only change; no declaration renamed or restated.
`file_scope` in `state.json` lists only `FormalSystem/Semantics`, `FormalSystem/ForMathlib/README.md`
and `scripts/check-module-invariants.sh`; the real edit territory is wider (see Risks).

## Findings

### Codebase Patterns

**Precedent (`2acf1371c`, Syntax nesting)**: `git mv` preserving history; namespaces left flat
(`FormalSystem.MinusLanguage`, not `...Syntax.MinusLanguage`); sibling aggregators
`Syntax/{X}Language.lean`; `Syntax.lean` deliberately does **not** import the nested
aggregators; the root aggregator `FormalSystem/FormalSystem.lean` imports them directly
(lines 11-13). Each subdirectory carries a `README.md`.

**Namespaces of the 15 files**: all declare `namespace FormalSystem.Semantics` (StarTruth also
opens `FormalSystem.StarLanguage` locally), with nested sub-namespaces `MinusTruth`,
`MinusValidity`, `MinusFrameTruth`, `PlusTruth`, `StarTruth`. These stay unchanged.

**Intra-family import graph** (current module names, `S.` = `FormalSystem.Semantics.`):

| File | Imports |
|------|---------|
| MinusFrame | `Syntax.MinusLanguage.Formula`, Mathlib tactics |
| MinusTruth | `S.Truth`, `Syntax.MinusLanguage.Formula`, `S.TruthClauses` |
| MinusValidity | `S.MinusTruth`, `S.ValidityLayer`, `S.Validity` |
| MinusSchemaValidity | `S.MinusTruth`, `S.DurationClassification` |
| PlusTruth | `S.Truth`, `Syntax.PlusLanguage.Formula`, `S.TruthClauses` |
| PlusValidity | `S.PlusTruth`, `S.ValidityLayer`, `S.Validity` |
| PlusPasting | `S.PlusValidity` |
| PlusNonValidities | `S.PlusValidity`, Mathlib |
| PlusDeterminism | `S.FrameProperty`, `S.PlusValidity` |
| PlusStateLocal | `S.PlusNonValidities` |
| StarTruth | `S.PlusTruth`, `Syntax.StarLanguage.Formula`, `S.TruthClauses` |
| StarValidity | `S.StarTruth`, `S.ValidityLayer`, `S.PlusValidity` |
| StarDeterminism | `S.StarValidity`, **`S.DeterministicBridge`** |
| StarNonValidities | `S.PlusNonValidities`, `S.StarValidity` |
| StarStateLocal | `S.StarValidity`, `S.PlusNonValidities` |

Two root-level Semantics files that are **not** in the 15 but depend on them:
`DeterministicBridge.lean` (imports `PlusDeterminism`; is itself imported by `StarDeterminism`)
and `StateLocalTransfer.lean` (imports `PlusStateLocal` + `StarStateLocal`). Both are
cross-language bridges; leave them at `Semantics/` root, as the task's measured list does. No
module-level cycle results: `Semantics/StarLanguage/StarDeterminism -> Semantics/DeterministicBridge
-> Semantics/PlusLanguage/PlusDeterminism` is a DAG.

**All 55 import lines to rewrite** (file: count):

```
FormalSystem/Semantics.lean                                   15
FormalSystem/Metalogic/Independence/ForwardDeterministicFrame  3
Tests/BimodalTest/Semantics/ValidityLayerTest.lean             2
FormalSystem/Semantics/StateLocalTransfer.lean                 2
FormalSystem/Semantics/StarValidity.lean                       2
FormalSystem/Semantics/StarStateLocal.lean                     2
FormalSystem/Semantics/StarNonValidities.lean                  2
FormalSystem/Metalogic/Independence/StarDiscrimination.lean    2
FormalSystem/Metalogic/Independence/StabUndefinable.lean       2
FormalSystem/Metalogic/Conservativity/Star/StarPasting.lean    2
FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean  2
FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness   2
(1 each) Semantics/{StarTruth,StarDeterminism,PlusValidity,PlusStateLocal,PlusPasting,
  PlusNonValidities,PlusDeterminism,MinusValidity,MinusSchemaValidity,DeterministicBridge},
  Metalogic/Independence/{RealTranslationFrame,OrderTransfer},
  Metalogic/Deterministic/Validity, Metalogic/Conservativity/Star/StarAxiomValidity,
  Metalogic/Conservativity/{SpWitness,SpCountermodel}, Metalogic/Conservativity/Plus/Atomization
```

Reproduce with:
`grep -rn "import FormalSystem.Semantics.\(Minus\|Plus\|Star\)" --include=*.lean FormalSystem Tests`

**Consumers of the `FormalSystem.Semantics` aggregator** (MainResults, Metalogic/Core/MaximalConsistent,
Automation/ProofSearch/Core, Decidability/CountermodelExtraction, 6 Integration tests): none uses
an L⁻/L⁺/L⋆ declaration (grep for `MinusTruthAt|PlusValid*|StarTruthAt|SameStateAt|...` = 0 in
code). Every file that does use them imports the specific module directly. So dropping the 15
lines from `Semantics.lean` cannot silently break a consumer; `lake build` would catch it anyway.

**Non-import path citations** (pattern `Semantics[/.](Minus|Plus|Star)...`, excluding imports).
Files needing prose edits: `Semantics.lean` (docstring submodule list), `Semantics/README.md`
(hand-maintained table), the 15 files' own docstrings where they self-cite, `Semantics/{FrameProperty,
TruthClauses,DeterministicBridge,StateLocalTransfer}.lean`, `Syntax/{Minus,Plus,Star}Language.lean`,
`Syntax/{Minus,Plus,Star}Language/README.md` (StarLanguage README has 16 hits),
`Syntax/{PlusLanguage/Axioms,PlusLanguage/Formula,StarLanguage/Axioms,StarLanguage/Embedding,
StarLanguage/Formula,MinusLanguage/Formula}.lean`, `Syntax/README.md`, `Metalogic.lean`,
`Metalogic/README.md`, `Metalogic/Soundness.lean`, `Metalogic/Conservativity.lean` + its README,
`Conservativity/{ChainBundleTruth,MinusLanguageSoundness,SpCountermodel,SpWitness,
TMCompletenessReduction}.lean`, `Conservativity/Plus{.lean,/README.md,/Atomization,/AxiomValidity,
/Corollaries}`, `Conservativity/Star{.lean,/README.md,/Forward,/StarAxiomValidity,/StarPasting,
/StarSoundness}`, `Metalogic/Deterministic/{Completeness,Erasure,README.md,Soundness,System,Validity}`,
`Metalogic/Independence{.lean,/README.md,/CoarsenedModels,/DeterminismUndefinable,/DriftFrame,
/ForwardDeterministicFrame,/OrderTransfer,/PastingIndependence,/RealTranslationFrame,
/StabUndefinable,/StarDiscrimination}`, `FormalSystem/README.md`, `README.md` (lines 262-266),
`NOTATION.md:83`, `docs/theorem-index.md` (5 File cells, lines 155-158, 179),
`docs/development/MODULE_ORGANIZATION.md` (lines 195, 199, 335, 343, 345),
`docs/reference/API_REFERENCE.md:816-817`, `docs/project-info/implementation-status.md:84`,
`docs/project-info/known-limitations.md:295-296`.
Reproduce with:
`grep -rnE 'Semantics[/.](Minus(Frame|SchemaValidity|Truth|Validity)|Plus(Determinism|NonValidities|Pasting|StateLocal|Truth|Validity)|Star(Determinism|NonValidities|StateLocal|Truth|Validity))\b' --exclude-dir={.lake,.git,specs,.claude,agent-system} . | grep -v ':import '`

Also two glob-style citations: `README.md:262` and `FormalSystem/Metalogic.lean:58`
(`Semantics/Plus*.lean`) and `Syntax/PlusLanguage/README.md:86` ("`Plus*.lean` semantics
modules") — repoint to `Semantics/PlusLanguage/`.

**Relative markdown link** (readme-lint check 3 / C13-adjacent):
`FormalSystem/Metalogic/Conservativity/Plus/README.md:85` ->
`../../../Semantics/PlusTruth.lean` becomes `../../../Semantics/PlusLanguage/PlusTruth.lean`.
No `](...)` links exist inside the 15 `.lean` files.

**Basename-only citations** (no `Semantics/` prefix): `ValidityLayer.lean:45`,
`TruthClauses.lean:53,108`, `DeterministicBridge.lean:52`, `Syntax/PlusLanguage.lean:42`,
`docs/user-guide/architecture.md:1093-1095`, `MODULE_ORGANIZATION.md:209`,
`implementation-status.md:48-50`. With basenames kept, these remain unambiguous and need no
edit (optional polish only; basename disambiguation is a later task).

**No `file.lean:NNN` citations** to any of the 15 files exist, so C20 tier 1 is unaffected.

### Invariant harness and lint mechanics (what the move touches)

- **C4** import resolution: covered by the 55-line rewrite.
- **C5** module-shaped dotted paths in markdown: `MODULE_ORGANIZATION.md:335,343,345` and
  `Syntax/MinusLanguage/README.md:58` cite `FormalSystem.Semantics.MinusTruth`/`MinusValidity`
  as modules; must become `FormalSystem.Semantics.MinusLanguage.MinusTruth` etc.
- **C8** (`check-module-invariants.sh` ~line 951-976): parent tuple
  `("FormalSystem", "FormalSystem/Metalogic", "FormalSystem/Syntax")`. Adding
  `"FormalSystem/Semantics"` currently yields (verified by running C8's own logic):
  ```
  no sibling FormalSystem/Semantics/Correspondence
  no sibling FormalSystem/Semantics/Extension
  selfnamed  FormalSystem/Semantics/Extension/Extension.lean
  no sibling FormalSystem/Semantics/Frames
  no sibling FormalSystem/Semantics/Ultraproduct
  ```
  C8 is enforced (`ENFORCE_C8=1`), so these are hard failures. Also update the header comment
  (line 17), the PASS message ("every FormalSystem/, Metalogic/ and Syntax/ subdirectory"),
  and the explanatory comment block above `C8_ALLOW_SELFNAMED`.
- **C12** slash-shaped source paths in `docs/` + `README.md`: the docs/README edits above.
- **C13** relative markdown links in `docs/` + `README.md`: no link to the 15 files there
  today; any new link written must resolve.
- **C15 half 2**: `docs/theorem-index.md` File cells must name existing paths — 5 rows
  (`StarStateLocal` x2, `PlusStateLocal` x2, `PlusValidity` x1). Anchors at declarations are
  unaffected (file content unchanged).
- **INV**: `Semantics/README.md` table is hand-maintained (`<!-- INVENTORY: hand-maintained
  (dir=FormalSystem/Semantics) -->`); it must have a row for **every** live loose `.lean` and
  lean-bearing subdirectory and no phantom rows. After the move: delete 15 file rows, add
  `MinusLanguage/`, `PlusLanguage/`, `StarLanguage/` directory rows and a row for each new
  loose aggregator (`MinusLanguage.lean`, `PlusLanguage.lean`, `StarLanguage.lean`, and
  `Correspondence.lean`, `Extension.lean`, `Frames.lean`, `Ultraproduct.lean` if added). Generated
  blocks elsewhere (`FormalSystem/README.md:240` shows `Semantics.lean | 300`) are refreshed with
  `bash scripts/check-module-invariants.sh --emit-inventory` then verified with `--check`.
- **C20 tier 2 scope** includes loose `.lean` files directly in `FormalSystem/Semantics`; moving
  the 15 into subdirectories removes them from that scope. Harmless (there are zero file:line
  citations in them), but worth one sentence in the commit.
- **readme-lint.sh**: check 1 (gated) requires a `README.md` in every directory holding `.lean`
  files -> the 3 new subdirectories each need one. Check 3 (gated) resolves every `](path)` in
  every `README.md` relative to its directory. `ForMathlib/` holds no loose `.lean` (only
  `Order/`), so check 1 never demanded its README; writing it is the review's M2 ask.

### ForMathlib README facts

- `FormalSystem/ForMathlib/` contains `Order/PFilter.lean` + `Order/README.md` only.
- Sibling aggregator `FormalSystem/ForMathlib.lean` states the dependency rule
  `Mathlib -> ForMathlib -> FormalSystem.* -> downstream` and imports
  `FormalSystem.ForMathlib.Order.PFilter` **and `FormalSystem.Init`**. So the precise rule is
  "nothing *under* `ForMathlib/` imports `FormalSystem.*`"; the aggregator carries the `Init`
  import on consumers' behalf (documented in `FormalSystem/Init.lean` as the sole recorded C24
  exception). The README should state it that precisely, or a reader will see the aggregator's
  `import FormalSystem.Init` and think the rule is violated.
- `FormalSystem/README.md:310` says `ForMathlib/` has "no README yet" -> update that row
  (Yes, with link `[ForMathlib/](ForMathlib/README.md)`, matching the `Semantics/` row at 305).
- Template: `Semantics/Frames/README.md` / `ForMathlib/Order/README.md` (title, purpose, Modules
  with `<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib -->` block, Key facts,
  Related Documentation with relative links, `*Last verified: 2026-09-16*`). Content: purpose
  (Mathlib-shaped extensions in Mathlib's own namespaces, names one-for-one with dualised Mathlib
  declarations, deleted here on upstreaming), the dependency rule, `Order/` row linking
  `Order/README.md`, precedent (`PFR/ForMathlib/`, `LeanLTL`), links to `../ForMathlib.lean`,
  `Order/README.md`, `../Metalogic/Algebraic/README.md` (consumer), `../README.md`. A mechanical
  check: `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returns nothing today.

### External Resources

- No Mathlib lookup needed: this is a module-path refactor. Lean module names are file-path
  derived; moving `Semantics/PlusTruth.lean` to `Semantics/PlusLanguage/PlusTruth.lean` changes
  the module to `FormalSystem.Semantics.PlusLanguage.PlusTruth` with no effect on declaration
  names, which come from `namespace` blocks.
- `FormalSystem.Semantics.PlusLanguage` (new module) vs `FormalSystem.PlusLanguage` (Syntax-side
  namespace) vs `FormalSystem.Syntax.PlusLanguage` (Syntax-side module): all distinct, no clash.
  `MODULE_ORGANIZATION.md` lines 84-95 already document the module-vs-namespace distinction;
  add the Semantics directories to that paragraph.

### Recommendations

Suggested phase decomposition (each phase ends green or is an explicit atomic batch):

1. **Move + imports (atomic batch)**. `git mv` the 15 files into
   `Semantics/{Minus,Plus,Star}Language/`, basenames unchanged. Create
   `Semantics/{Minus,Plus,Star}Language.lean` sibling aggregators (copyright header, imports of
   their members, `/-!` docstring with Modules list — model on `Syntax/PlusLanguage.lean`).
   Rewrite the 55 import lines with a sed anchored to `^import FormalSystem\.Semantics\.(Minus|Plus|Star)`
   (e.g. `s/^import FormalSystem\.Semantics\.(Minus[A-Za-z]+)$/import FormalSystem.Semantics.MinusLanguage.\1/`,
   same for Plus/Star). In `Semantics.lean` remove the 15 lines. Root aggregator: add
   `import FormalSystem.Semantics.{Minus,Plus,Star}Language` to `FormalSystem/FormalSystem.lean`
   after `import FormalSystem.Semantics` (mirrors Syntax). Note: `Semantics.lean` still reaches most
   of L⁺/L⋆ transitively via `DeterministicBridge`/`StateLocalTransfer`; that is fine and should be
   stated in its docstring rather than claimed otherwise. Verify: guarded detached `lake build`,
   then `check-module-invariants.sh --no-build` for C4.
   *Fallback if any downstream break appears*: have `Semantics.lean` import the three new
   aggregators instead (closure-preserving).
2. **C8 extension**. Add `"FormalSystem/Semantics"` to the tuple; add sibling aggregators
   `Semantics/{Correspondence,Extension,Frames,Ultraproduct}.lean` (and optionally replace the
   corresponding direct lines in `Semantics.lean` with them — closure-identical); add
   `"FormalSystem/Semantics/Extension/Extension.lean"` to `C8_ALLOW_SELFNAMED` with a comment that
   it is `thm:extension`'s content module, not an aggregator (renaming it is the alternative:
   4 importers, but it widens the module-path churn for no organizational gain). Update C8's
   header/comment/PASS text. New aggregators are reachable from the root via `Semantics.lean` or
   become C6-unreachable; import them from `Semantics.lean` to avoid a manifest entry.
3. **READMEs + docs + citations**. Three new subdirectory READMEs (generated inventory blocks);
   rewrite `Semantics/README.md` hand-maintained table and add a "Language family" pointer to
   `Syntax/README.md`'s section; `Semantics.lean` docstring submodule list; all non-import path
   citations listed above; `theorem-index.md` File cells; C5 dotted module mentions;
   Conservativity/Plus/README link; `--emit-inventory`; `FormalSystem/README.md:310`;
   `MODULE_ORGANIZATION.md` directory tree and module-vs-namespace paragraph.
4. **ForMathlib README** (independent; can be first or parallel).
5. **Gate**: full `bash scripts/check-module-invariants.sh` (build included; C1, C2, C14, C24, C25
   must stay green), `bash scripts/check-module-invariants.sh --emit-inventory --check`,
   `bash scripts/readme-lint.sh` exit 0, plus a residue grep: the non-import pattern above must
   return only the intended new-form paths.

## Decisions

- Directory names `MinusLanguage/`, `PlusLanguage/`, `StarLanguage/` (identical to `Syntax/`),
  not the review's suggested `Minus/`, `Plus/`, `Star/` — the task asks for names consistent
  with `Syntax/`, and `Metalogic/Conservativity/{Plus,Star}/` already uses the short form for a
  different purpose.
- Keep prefixed basenames (`PlusTruth.lean`). The stutter is cosmetic; the collision risk is not
  (`Truth.lean`, `Validity.lean` exist at `Semantics/` root and `Validity.lean` again in
  `Metalogic/Deterministic/`), and prefixed basenames keep every existing basename-only citation
  valid.
- `DeterministicBridge.lean` and `StateLocalTransfer.lean` stay at `Semantics/` root (they bridge
  languages / L⁺-to-L⋆; the task's measured list excludes them).
- Namespaces unchanged (`FormalSystem.Semantics`), matching the Syntax precedent.
- Mirror Syntax's aggregator policy (root imports the language aggregators; `Semantics.lean`
  does not), with the closure-preserving fallback noted.
- No `user_decision` needed: every choice above is inferable from precedent and the harness.

## Risks & Mitigations

- **C8 surprise failures** (5 pre-existing) -> Phase 2 above; verify with the harness before
  touching docs.
- **Namespace/module textual collision** (`FormalSystem.Semantics.PlusTruth` is both an old module
  and a live namespace) -> anchor sed to `^import` for `.lean` and edit prose by hand from the
  enumerated list; after the move, C5 may treat a future namespace mention as an unresolved
  module — note in `MODULE_ORGANIZATION.md`'s existing ambiguity paragraph.
- **Territory**: `file_scope` covers only `FormalSystem/Semantics`, the ForMathlib README and the
  harness script, but imports and citations live in `Metalogic/`, `Syntax/`, `Tests/`, `docs/`,
  `README.md`, `NOTATION.md`, `FormalSystem/FormalSystem.lean`. The plan should declare the
  wider territory explicitly (the Syntax move needed a recorded exemption for exactly this).
- **Concurrency**: task 594 (smoke-test relocation, researching) targets `#check`/`example` lines
  in live library files; `PlusDeterminism.lean` has 4 such lines. If 594 edits it concurrently, a
  `git mv` + edit conflict follows. Sequence 596's move before 594's edit, or re-measure. Task 591
  (Automation exports) does not overlap. The later tasks 584 (paper vocabulary) and 589 (basename
  disambiguation) should run after this one, per the ordering note.
- **Build cost**: moving `PlusTruth`/`MinusTruth` invalidates much of `Metalogic/Conservativity`,
  `Independence`, `Deterministic` — use the guarded detached build (`long-builds.md`), not an
  inline `lake build`.
- **Stale `.olean`s** of old module paths in `.lake/build` are harmless to `lake build` but can
  mislead the LSP; restart the LSP after the move.

## Tactic Survey Results

- Not applicable (no tactic survey performed): the task changes module paths only; no proof goal
  is involved.

## Context Extension Recommendations

- **Topic**: extending C8's walked parents
- **Gap**: the harness comment documents why `Syntax` joined the tuple but not that adding a
  parent re-scopes every existing subdirectory (including self-named content modules like
  `Extension/Extension.lean`).
- **Recommendation**: add one sentence to the C8 comment block when `Semantics` joins the tuple.

## Appendix

Commands run (all read-only):
- `bash scripts/check-module-invariants.sh --no-build` -> all gated checks PASS (baseline)
- `bash scripts/readme-lint.sh` -> `RESULT: PASS`, exit 0, 56 READMEs, 0 missing, 0 broken
- C8 logic re-run in Python against `FormalSystem/Semantics` -> the 5 violations listed
- `grep` sweeps for import lines, dotted and slash paths, basenames, `](` links,
  `file.lean:NNN` citations, `typst/`, `scripts/*.txt`, `.claude/`, `agent-system/`, `Boneyard/`
- `git show --stat 2acf1371c` (Syntax nesting precedent)
- `specs/reviews/review-2026-09-15.md` M1-M3
