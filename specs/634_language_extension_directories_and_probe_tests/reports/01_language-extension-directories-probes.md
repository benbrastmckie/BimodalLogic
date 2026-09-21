# Research Report: Task #634

**Task**: 634 - Language-extension directories and probe tests
**Started**: 2026-09-20T00:00:00Z
**Completed**: 2026-09-20T00:00:00Z
**Effort**: Large (two independent workstreams; one carries an unbudgeted namespace rename)
**Dependencies**: 632 (completed), 633 (completed), 626 (completed) — all three verified landed at HEAD `a46f164e2`
**Sources/Inputs**:
- Codebase (live tree at HEAD `a46f164e2`)
- `docs/development/PUBLICATION_REFACTOR.md` §4 (target layout, namespace map) and Phase 5
- `scripts/measure-refactor-partitions.py`, `scripts/check-metalogic-cycles.sh`,
  `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`, `scripts/move-modules.py`
- `specs/state.json` (live task statuses)
- lean-lsp MCP: not required (no proof obligations in this task; see Tactic Survey Results)

**Artifacts**:
- `specs/634_language_extension_directories_and_probe_tests/reports/01_language-extension-directories-probes.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The Phase 5 acceptance criterion cannot be met under the programme's own stated plan.**
  `PUBLICATION_REFACTOR.md:92` ("Syntax/X + Semantics/X merged; namespaces unchanged"), the Phase 5
  heading ("paths only; FQNs unchanged for the 15 files") and the namespace-map row for the
  language family all assume the merge is a pure path move. It is not. Simulated against the live
  tree, a paths-only merge takes the `namespace-audit` unrelated bucket from **24 to 23**, not to
  the recorded-exception set: 15 files leave the bucket, but **14 files enter it**, and those 14
  are a *regression* — they are currently in the acceptable `ancestor` bucket.
- **Cause**: the 16 files under `Semantics/{Plus,Minus,Star}Language/` declare
  `namespace FormalSystem.Semantics`. Under `Semantics/…` that namespace is an *ancestor* of the
  directory module (acceptable). Under `FormalSystem/{X}Language/` it is *unrelated*. Only
  `PlusStateLocal.lean` and `StarStateLocal.lean` escape, because they already open with
  `namespace FormalSystem.{X}Language`.
- **Recommended resolution**: rename the first namespace of the 14 affected files (plus the moved
  `MinusLanguageSoundness.lean`) from `FormalSystem.Semantics` to `FormalSystem.{X}Language`, and
  correct `PUBLICATION_REFACTOR.md` in the same commit. Measured cost is small and bounded:
  **0 declaration collisions**, **0 short-name ambiguities**, **0 fully-qualified
  `FormalSystem.Semantics.<decl>` citations outside the moved set**, **25 direct importers**,
  **2 pinned `#print axioms` baselines**. The programme already set this precedent in the same
  table: its `MinusLanguageSoundness.lean` row targets `FormalSystem.MinusLanguage` and accepts the
  FQN churn as "small".
- **Task 429 does not block the probe move.** 429 is `not_started`, `Tests/` is clean in the
  working tree, and 429's own `file_scope` already names the post-move path
  `Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean`. All 9 test files move in
  this pass.
- **Operational note 3 is wrong and is corrected here**: none of readme-lint's 21 broken
  `../Boneyard/` links sit in a language-extension README. All 21 are in `Automation/`,
  `Metalogic/**` and `FormalSystem/README.md`. Merging the language READMEs is not an opportunity to
  fix them; that belongs to a different task.
- **`scripts/move-modules.py` cannot drive this merge unassisted** in two specific ways
  (aggregator collision via `resolve_move`'s directory preference; `--namespace-map` being a
  repo-wide string rewrite of `FormalSystem.Semantics`). Both are characterised below with a
  recipe that works.

## Context & Scope

Researched: what it takes to land `PUBLICATION_REFACTOR.md` Phase 5 — merging
`Syntax/{Plus,Minus,Star}Language/` and `Semantics/{Plus,Minus,Star}Language/` into
`FormalSystem/{Plus,Minus,Star}Language/`, relocating
`Metalogic/Conservativity/MinusLanguageSoundness.lean` to `MinusLanguage/Soundness.lean`, settling
three foreign-namespace Chronicle files, and moving 8 `*Probe.lean` files plus
`TableauConformance.lean` out of the `Tests/BimodalTest/` root — such that
`measure-refactor-partitions.py namespace-audit` shows only recorded exceptions in the `unrelated`
bucket and the gate harness stays green.

Every count below was re-measured against HEAD `a46f164e2`, never copied from a plan or from the
dispatch's operational notes.

### Baseline harness state at HEAD (measured, this session)

| Check | Exit | State |
|---|---|---|
| `check-evidence-probes.sh` | 0 | green (4 wired probes compile) |
| `check-copyright-headers.sh --strict` | 0 | green (508 conforming) |
| `check-metalogic-cycles.sh` | 0 | green (1 cycle; upward set == 7-line allowlist) |
| `check-module-invariants.sh --no-build` | 0 | green (ALL CHECKS PASSED) |
| `check-paper-definitions.sh` | 0 | green (43 definitions unchanged) |
| `readme-lint.sh` | 1 | **pre-existing red**: 21 broken references, plus 2 advisory STALE DATE |
| `typst-sync-check.sh` | 1 | **pre-existing red**: `sorry-total` committed=4 live=0, 2 mismatches |

The two reds are pre-existing and out of this task's scope (confirmed below). "Harness green" for
this task means: the five green checks stay green, and the two reds do not worsen.

## Findings

### Finding 1 (central): the namespace audit regresses under a paths-only merge

Live baseline:

```
equal-or-descendant 256 | ancestor 186 | unrelated 24 | none 42
```

Simulated post-move classification, applying `classify_namespace` from
`scripts/measure-refactor-partitions.py:417` to the proposed destinations:

| Transition | Files |
|---|---|
| `unrelated` → `equal-or-descendant` | **15** (the 13 `Syntax/{X}Language/*` files + `PlusStateLocal.lean` + `StarStateLocal.lean`) |
| `ancestor` → **`unrelated`** | **14** (every other `Semantics/{X}Language/*.lean`) |
| `unrelated` → `unrelated` | 1 (`MinusLanguageSoundness.lean`; namespace `FormalSystem.Semantics` travels with it) |

Net: `unrelated` goes 24 → 23. The Phase 5 acceptance list is `ForMathlib/Order/PFilter.lean`,
`Theorems/DeductionTheorem.lean`, `Tactic/Meta.lean`, and the three decided Chronicle files — six
entries. The post-move bucket would hold **17 unrecorded entries**:

1. The 14 `Semantics/{X}Language/*` files (newly unrelated — a regression).
2. `MinusLanguage/Soundness.lean` (namespace `FormalSystem.Semantics`).
3. `FormalSystem.Semantics.FrameClassValidity` → `FormalSystem.ProofSystem` (untouched by this task,
   never recorded).
4. `FormalSystem.Metalogic.Decidability.BiLasso.Periodic` → `…Decidability.Periodic` (untouched,
   never recorded).

Items 3 and 4 are outside this task's file scope. Their module docstrings explain the *duplication*
and the *split pair* respectively, but neither explains its namespace, so neither is a "recorded
exception" in the Phase-5 sense. **They must be added to the recorded-exception list (with a
docstring sentence each) or the acceptance command will still report them.** This is a scope
addition the plan must carry explicitly.

The root error is in the programme's own namespace map
(`docs/development/PUBLICATION_REFACTOR.md:164`), whose first row reads
`Syntax/{Plus,Minus,Star}Language/*, Semantics/{Plus,Minus,Star}Language/* (15 files)`. That "15"
is the size of the *unrelated bucket*, not the size of the file set being moved. The actual set is
**29 files** (13 syntax + 16 semantics), plus 6 sibling aggregators, plus
`MinusLanguageSoundness.lean`.

### Finding 2: the namespace rename is cheap, and is measured — not estimated

For the 16 `Semantics/{X}Language/*.lean` files plus `MinusLanguageSoundness.lean`:

| Measure | Value |
|---|---|
| Declarations sitting under `FormalSystem.Semantics` in those files | **241** |
| Declaration-name collisions against the syntax half after rename to `FormalSystem.{X}Language` | **0** (Plus 92 vs 117, Minus 87 vs 57, Star 90 vs 87) |
| Short names that would become ambiguous when both `FormalSystem.Semantics` and `FormalSystem.{X}Language` are open | **0** (227 leaving vs 558 remaining, empty intersection) |
| Fully-qualified `FormalSystem.Semantics.<moved decl>` citations outside the moved set | **0** |
| Files directly `import`ing one of the 17 modules | **25** |
| `#print axioms` baselines naming a moved declaration | **2** — `scripts/check-module-invariants.sh:1858` (`FormalSystem.Semantics.truthAt_tr`) and `:1884` (`FormalSystem.Semantics.plusValidIn_ofFormula_iff`) |

Because there are zero FQN citations, every downstream reference already reaches these
declarations through `open FormalSystem.Semantics` or from inside the namespace. The rename
therefore resolves to: edit 17 `namespace`/`end` pairs, add `open FormalSystem.{X}Language` where
the elaborator asks for it across at most 25 importers, and update the 2 axiom baselines. The
25 direct importers are:

```
FormalSystem/FormalSystem.lean
FormalSystem/Metalogic/Conservativity.lean
FormalSystem/Metalogic/Conservativity/{ChainBundleTruth,MinusLanguageSoundness,SpCountermodel,
  SpWitness,TMCompletenessReduction,Z1Countermodel}.lean
FormalSystem/Metalogic/Conservativity/Plus/{Atomization,AxiomValidity}.lean
FormalSystem/Metalogic/Conservativity/Star/{StarAxiomValidity,StarPasting}.lean
FormalSystem/Metalogic/Deterministic/Validity.lean
FormalSystem/Metalogic/Independence/{ForwardDeterministicFrame,LimitClosureCountermodel,
  OrderTransfer,RealTranslationFrame,StabUndefinable,StarDiscrimination}.lean
FormalSystem/Semantics/{DeterministicBridge,StateLocalTransfer}.lean
FormalSystem/Semantics/{MinusLanguage,PlusLanguage,StarLanguage}.lean
Tests/BimodalTest/Semantics/ValidityLayerTest.lean
```

The syntax half has a further 16 direct importers, unaffected by the namespace question.

### Finding 3: the target namespace should be flat `FormalSystem.{X}Language`

Three shapes were considered.

- **Flat `FormalSystem.{X}Language`** — matches the syntax half, matches
  `PlusStateLocal.lean`/`StarStateLocal.lean`'s existing first namespace, and matches the
  programme's own `MinusLanguageSoundness.lean` row, which already targets
  `FormalSystem.MinusLanguage`. Measured collision-free. **Recommended.**
- **Nested `FormalSystem.{X}Language.Semantics`** — also classifies as equal-or-descendant, but
  introduces a namespace level no other module in the family uses and splits the family's API in
  two for no measured benefit.
- **Leave `FormalSystem.Semantics` and record 15 new exceptions** — meets the letter of "at most
  the recorded exceptions" only by expanding the list until it is vacuous, and regresses 14 files
  from an acceptable bucket to an unacceptable one. Rejected.

The second namespace block inside `PlusStateLocal.lean` (lines 210–410,
`namespace FormalSystem.Semantics`) and `StarStateLocal.lean` should be renamed too; otherwise those
two files remain split across two namespaces for no reason once the directory is merged.

### Finding 4: aggregator collision — six files map onto three

`FormalSystem/Syntax/{X}Language.lean` and `FormalSystem/Semantics/{X}Language.lean` both resolve to
`FormalSystem/{X}Language.lean`. These must be merged by hand into three files, not moved. Content
to reconcile:

- `Syntax/PlusLanguage.lean:47-54` carries a **Module Invariant** that the merge falsifies by
  construction: *"Nothing under `FormalSystem/PlusLanguage/` imports anything from
  `FormalSystem/Semantics/`."* After the merge, `PlusTruth.lean` and its siblings live there and do
  import `FormalSystem.Semantics.*`. The same invariant text appears in the Minus and Star syntax
  aggregators. It is prose-only (no mechanical check enforces it — `check-module-invariants.sh` has
  no matching rule), but it must be rewritten, not left to rot.
- `Semantics/PlusLanguage.lean:20-21` states *"The declarations stay in the
  `FormalSystem.Semantics` namespace; only the module paths are grouped here."* — directly
  contradicted by Finding 3's recommendation, and must be rewritten.
- The syntax aggregators' "Where the L⁺ semantics and metatheory live" sections become internal
  cross-references within one directory.

`FormalSystem/Syntax.lean:28-29,48,89` and `FormalSystem/Semantics.lean:42-46,121-170` both describe
the subdirectory layout in prose and must be updated. `FormalSystem/FormalSystem.lean` imports both
aggregator families.

### Finding 5: `check-metalogic-cycles.sh` will fail on a shortfall, by design

`scripts/check-metalogic-cycles.sh:160-172` hard-codes a 7-pair allowlist keyed on the module name
`FormalSystem.Syntax.MinusLanguage.AxiomDischarge`. Moving that file to
`FormalSystem.MinusLanguage.AxiomDischarge` puts its top-level directory outside `LAYERS`
(`measure-refactor-partitions.py:100-104`), so `layer_of` returns `None`, the file contributes no
upward edge, and all 7 allowlisted pairs become a **shortfall**. Assertion B fails on shortfall as
loudly as on surplus (`:215-216`). The fix is to empty `ALLOWLIST` to `frozenset()` and rewrite the
header comment at `:156-159` plus the script's own docstring block. This is the "finding rather than
a silent pass" the programme designed in, and it lands in the *same commit* as the move.

**Secondary consequence worth flagging to the planner**: once the three language directories sit at
the library root, they are absent from `LAYERS` and every import into *and out of* them becomes
invisible to the upward-edge measurement. `Metalogic → MinusLanguage` and
`Semantics/StateLocalTransfer.lean → PlusLanguage.PlusStateLocal` both stop being measured. That is
not a regression the harness will catch, and `ORGANISATION.md`'s layer table should say explicitly
that the extension-language directories sit outside the core stack, rather than leaving their
omission to be read as an oversight.

### Finding 6: `scripts/move-modules.py` limitations for this specific merge

1. **`resolve_move` prefers the directory** (`move-modules.py:400-404`). A map row
   `FormalSystem.Syntax.PlusLanguage -> FormalSystem.PlusLanguage` resolves to the *directory*,
   moves it, and **leaves `FormalSystem/Syntax/PlusLanguage.lean` orphaned on disk** — with its
   citations already rewritten to the new paths. Silent, and green-looking.
2. **A second directory row targeting the same destination cannot run** —
   `FormalSystem/PlusLanguage/` already exists after the first `git mv`.
3. **`--namespace-map` is a repo-wide string rewrite.** A row
   `FormalSystem.Semantics -> FormalSystem.PlusLanguage` would rewrite every occurrence of
   `FormalSystem.Semantics` in the tree (558 remaining short names' home namespace, ~90 other
   files). It **must not** be used for Finding 3's rename. The rename is a hand edit of 17 files
   plus targeted `open` additions.
4. Carried over from the run's operational notes and not re-fixable here: the tool collapses
   "from X to Y" prose into "from Y to Y". Prose in `PUBLICATION_REFACTOR.md`, `ORGANISATION.md` and
   the merged READMEs that narrates *this* move must be written after the tool runs, or reviewed
   after it.

**Recipe that works**: give `move-modules.py` **file-granular rows** — one per `.lean` under the six
source directories (29 rows) plus one for `MinusLanguageSoundness.lean` plus three rows for the
*syntax* aggregators (`FormalSystem.Syntax.PlusLanguage -> FormalSystem.PlusLanguage`, whose
directory will already have been consumed by the file rows, so `resolve_move` falls through to the
`.lean` branch) — run with `--no-verify`, then hand-merge the three semantics aggregators into the
three moved syntax aggregators, `git rm` the three semantics aggregators, and run the harness once
at the end. Dry-run first: `--dry-run` reports every rewrite class without touching the tree.

### Finding 7: the README merge

Six READMEs collapse to three:

| Merged file | Sources | Lines |
|---|---|---|
| `FormalSystem/PlusLanguage/README.md` | `Syntax/PlusLanguage/README.md` (91) + `Semantics/PlusLanguage/README.md` (42) | 133 |
| `FormalSystem/MinusLanguage/README.md` | `Syntax/MinusLanguage/README.md` (74) + `Semantics/MinusLanguage/README.md` (34) | 108 |
| `FormalSystem/StarLanguage/README.md` | `Syntax/StarLanguage/README.md` (186) + `Semantics/StarLanguage/README.md` (36) | 222 |

`readme-lint.sh` scopes to `FormalSystem/` only (`readme-lint.sh:44`), so no README is needed for
`Tests/BimodalTest/Metalogic/Decidability/`. Its Check 4 compares each README's
`Last verified: YYYY-MM-DD` stamp against `git log -1 --format=%cs` for the directory, so each
merged README's stamp must be set to the merge commit's date — this is the five-of-47 date refresh
that task 614 depends on (614 is `not_started`; its remaining 42 files are untouched here).

`Syntax/StarLanguage/README.md` carries task 626's `## Paper-label correspondence` section at line
103; that content travels with the file. Task 626's label-citation edits are confirmed present at
HEAD: `def:BLstar-semantics` appears 4× in `Syntax/PlusLanguage/Axioms.lean`, 3× in
`Syntax/PlusLanguage/Formula.lean`, 4× in `Semantics/PlusLanguage/PlusTruth.lean`.

`FormalSystem/Syntax/README.md` and `FormalSystem/Semantics/README.md` list the subdirectories and
must lose those entries; `FormalSystem/README.md` gains three top-level directories.

### Finding 8 (correction): the 21 broken README links are not in scope

Operational note 3 asserted that several of readme-lint's 21 broken `../Boneyard/` links sit in the
language-extension READMEs this task merges. **Measured: none do.** The 21 break down as:

- `FormalSystem/README.md` — 4
- `FormalSystem/Metalogic/WeakCanonical/**/README.md` — 8
- `FormalSystem/Metalogic/README.md` — 2
- `FormalSystem/Metalogic/{Bundle,Core}/README.md` — 3
- `FormalSystem/Automation{,/Tactics}/README.md` — 2
- `FormalSystem/Metalogic/WeakCanonical/{EFGames,Expressiveness}/README.md` — 2

Fixing them is a one-line-each `../` depth correction, but it belongs to whichever task owns the
`Boneyard/` relocation follow-up, not here. Touching them from this task would blur the commit and
would not help the acceptance criterion. `typst-sync-check.sh`'s `sorry-total committed=4 live=0`
violation is likewise the archived `WeakCanonical/` row and is untouched by this task.

### Finding 9: the three Chronicle files

| File | Declarations | First namespace | Shape |
|---|---|---|---|
| `Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (1164 lines) | 21 | `FormalSystem.Metalogic.Bundle` (lines 299-818) | **Interleaved**: Bundle → BXCanonical.Chronicle (820-946) → Bundle (948-1164) |
| `Metalogic/WeakCanonical/DenseModelSurgery/ChronicleInstance.lean` (283 lines) | 15 | `FormalSystem.Metalogic.BXCanonical.Chronicle` | single namespace, foreign directory |
| `Metalogic/WeakCanonical/RealModel/ChronicleRealFlow.lean` (172 lines) | 7 | `FormalSystem.Metalogic.BXCanonical.Chronicle` | single namespace, foreign directory |

`ChronicleRealExtension.lean` has the cheapest genuine fix available anywhere in this task: it
*already* contains a `FormalSystem.Metalogic.BXCanonical.Chronicle` block matching its directory. If
the 820–946 block can be hoisted above the 299–818 Bundle block without breaking a dependency, the
file classifies as equal-or-descendant with **zero FQN churn**. Whether the Bundle material at
299–818 is a prerequisite of 820–946 must be checked at implementation time; if it is, record the
file as an exception with a docstring sentence instead.

The other two are wholly foreign to their directory. Note that both are edge sources in the one
sanctioned `WeakCanonical → BXCanonical` directory cycle that `check-metalogic-cycles.sh` asserts
(`ChronicleInstance.lean → …Chronicle.ChronicleMonadicBridge` is one of the 5 lines). **Physically
relocating either file into `Metalogic/BXCanonical/Chronicle/` would change the measured cycle set
and could break Assertion A's "exactly 1 cycle".** Recording them as exceptions is therefore the
low-risk choice, and it is what the programme's own map allows ("record, or move the declarations —
decide per file in Phase 5"). Recommendation: record both, with a docstring sentence each naming the
cycle-assertion reason. Neither is in `EXPRESSIVENESS_SET`, so Phase 6 does not pre-empt the
decision.

### Finding 10: the test-root move is unblocked and mechanically simple

Nine files move from `Tests/BimodalTest/` to `Tests/BimodalTest/Metalogic/Decidability/`:

```
BoxNegPreservationProbe.lean   BoxNegReachabilityProbe.lean  BoxSpreadProbe.lean
CrossWorldPropagationProbe.lean RayRegionProbe.lean          RegionGateProbe.lean
TemporalWitnessProbe.lean       UntlSnceCopyProbe.lean        TableauConformance.lean
```

Leaving `Property.lean` (the aggregator, sanctioned by the acceptance text), `WalkthroughAxioms.lean`
and `README.md` at the root. **`WalkthroughAxioms.lean` is a loose `.lean` at the test root that
Phase 5's acceptance text does not exempt** — the text exempts only `Property.lean`. The plan must
either move it too or amend the acceptance sentence; research cannot tell which from the programme
record, and the file is not in this task's declared `file_scope`. Recommendation: amend the
acceptance sentence to exempt both aggregator-shaped root files, since `WalkthroughAxioms.lean` is
not a Decidability probe and has no natural home in the target directory.

Dependencies: `Tests/BimodalTest.lean:31-39` imports all nine; the probe files cite each other by
path in their module docstrings (`TemporalWitnessProbe.lean:12,596`, `RayRegionProbe.lean:12`,
`BoxNegPreservationProbe.lean:20,76`, `BoxNegReachabilityProbe.lean:12`,
`CrossWorldPropagationProbe.lean:22,24`, `UntlSnceCopyProbe.lean:14`) — all handled by
`move-modules.py` rewrite class 3. No `.sh`, `.yml` or `.typ` file references them, and no C20
`file:line` citation outside `specs/` targets them.

Namespaces are `BimodalTest.{FileName}` and would become directory-unrelated, but
`measure_namespaces` filters to `m.startswith("FormalSystem.")`
(`measure-refactor-partitions.py:441`), so the test library is outside the audit. Renaming them to
`BimodalTest.Metalogic.Decidability.{FileName}` is optional tidiness, not acceptance work.

**Task 429 check (performed live, as the dispatch requires)**: `specs/state.json` reports 429 as
`not_started`. `git status --porcelain -- Tests/` is empty — no uncommitted work anywhere under
`Tests/`. The last commit touching `TemporalWitnessProbe.lean` is `fed5e1ac8` (task 597). 429's
declared `file_scope` already lists **both** `Tests/BimodalTest/TemporalWitnessProbe.lean` **and**
`Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean`, i.e. it anticipates this move.
**Conclusion: include `TemporalWitnessProbe.lean` in this pass. No follow-up task is needed.**

### Finding 11: `file_scope` gaps

Task 634's declared `file_scope` omits paths the work necessarily touches:

- `FormalSystem/Syntax/{Plus,Minus,Star}Language.lean` and
  `FormalSystem/Semantics/{Plus,Minus,Star}Language.lean` (the six aggregators)
- `FormalSystem/{Syntax,Semantics,FormalSystem}.lean`, `FormalSystem/README.md`,
  `FormalSystem/Syntax/README.md`, `FormalSystem/Semantics/README.md`
- `Tests/BimodalTest.lean` and the other 7 probe files (only `TemporalWitnessProbe.lean` and
  `TableauConformance.lean` are listed)
- `Tests/BimodalTest/Metalogic/Decidability/` (destination)
- `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh` (2 axiom baselines),
  `scripts/measure-refactor-partitions.py` (docstring counts),
  `scripts/module-invariants-allowlist.txt`
- `docs/development/PUBLICATION_REFACTOR.md`, `ORGANISATION.md`, and the ~10 other docs citing the
  old paths
- The 25 direct importers that may need an added `open`

`git-snapshot.sh` refuses a snapshot when tracked modifications fall outside a task's declared
`file_scope`, so the plan should widen `file_scope` before implementation starts rather than reach
for `--allow-out-of-scope` later.

### External Resources

No Mathlib search was needed: this task contains no proof obligations, no new declarations and no
`sorry`. `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_state_search` and
`lean_hammer_premise` were therefore not consulted, and no rate limit was touched. The relevant
"external" resources were all in-repo: `PUBLICATION_REFACTOR.md` §4 and Phase 5, and the five gate
scripts.

### Recommendations

A sorry-free path exists trivially (no proof content changes). Recommended phase decomposition, each
phase sized to one agent run and each ending green:

1. **Widen `file_scope`; correct the programme record.** Amend
   `docs/development/PUBLICATION_REFACTOR.md` — line 92's "namespaces unchanged", the Phase 5
   heading, namespace-map row 1 (29 files, not 15; target namespace `FormalSystem.{X}Language`), the
   Phase 5 acceptance list (add `Semantics/FrameClassValidity.lean` and
   `Decidability/BiLasso/Periodic.lean`; exempt `WalkthroughAxioms.lean` at the test root).
   No Lean change; harness unchanged.
2. **Test-root move.** All 9 files via `move-modules.py` file-granular rows. Update
   `Tests/BimodalTest.lean`. Independent of everything else — land it first as a cheap green
   milestone.
3. **Scripted path merge, Plus/Minus/Star.** File-granular rows + syntax-aggregator rows,
   `--no-verify`; hand-merge the three aggregators and three READMEs; `git rm` the six superseded
   files; refresh the three `Last verified` stamps. Empty `check-metalogic-cycles.sh`'s
   `ALLOWLIST` in **this same commit** — the harness is red between the move and that edit, which
   makes this an `atomic-batch` objective, not a sequence of green sub-steps.
4. **Namespace rename of the 16 semantics files + `Soundness.lean`.** Hand edit (never
   `--namespace-map`); add `open FormalSystem.{X}Language` wherever `lake build` asks across the 25
   importers; update the 2 `#print axioms` baselines. Rewrite the falsified Module Invariant prose
   in the three merged aggregators.
5. **Chronicle settlement.** Attempt the `ChronicleRealExtension.lean` block reorder; record the
   other two (and `FrameClassValidity`, `BiLasso/Periodic`) with docstring sentences.
6. **Docs, counts and acceptance.** Refresh `measure-refactor-partitions.py`'s docstring counts and
   `module-invariants-allowlist.txt`'s three now-resolving `FormalSystem.{X}Language` entries
   (C5 reports stale entries as INFO, not FAIL — pruning is tidiness). Update `ORGANISATION.md`'s
   layer table with an explicit note that the extension-language directories sit outside the core
   stack. Run the full harness plus `lake build`.

Target acceptance figure: `unrelated` = **5** — `ForMathlib/Order/PFilter`,
`Theorems/DeductionTheorem`, `Tactic/Meta`, `Semantics/FrameClassValidity`,
`Decidability/BiLasso/Periodic` — plus 0–2 Chronicle files depending on Finding 9's outcome.

## Decisions

1. **Namespace rename, not exception-recording** (Finding 3). The acceptance criterion is
   unmeetable otherwise, the programme already set the precedent in the same table for
   `MinusLanguageSoundness.lean`, and every cost measure came back at zero or near-zero. The
   programme record is corrected rather than the acceptance weakened. Recorded here rather than
   escalated: research resolved it against the codebase's own convention, so it is not a
   `user_decision`.
2. **Flat `FormalSystem.{X}Language`, not nested `.Semantics`** — matches the two files that already
   comply and the syntax half.
3. **`TemporalWitnessProbe.lean` moves in this pass** (Finding 10). 429 is `not_started` with a
   clean tree and a `file_scope` that already names the destination.
4. **Record, do not relocate, `ChronicleInstance.lean` and `ChronicleRealFlow.lean`** (Finding 9).
   Relocating them perturbs the asserted directory cycle for no acceptance gain.
5. **The 21 broken README links stay untouched** (Finding 8). They are not in the merged files, and
   the operational note that said otherwise is corrected in this report.
6. **No `--namespace-map`** (Finding 6.3). Repo-wide string rewrite of `FormalSystem.Semantics` is
   unsafe by construction.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Phase 3 leaves the harness red mid-phase (allowlist shortfall) | Declare `Commit Mode: atomic-batch` for phase 3; the allowlist edit ships in the same commit as the `git mv`. |
| `resolve_move` silently orphans an aggregator (Finding 6.1) | File-granular map rows only; `--dry-run` first; after the run, assert `ls FormalSystem/Syntax/*Language*` and `ls FormalSystem/Semantics/*Language*` are both empty. |
| `--namespace-map` catastrophe (Finding 6.3) | Prohibited in the plan text; the rename is a hand edit of 17 files. |
| Hidden `open`-scope breakage in one of the 25 importers | `lake build` is the oracle. Measured ambiguity is 0, so failures will be missing-`open` errors with an exact fix, not silent elaboration changes. |
| `ChronicleRealExtension.lean` block reorder breaks a dependency | Attempt it; on failure, fall back to recording it as an exception. Bounded, one file. |
| Moving a Chronicle file breaks `check-metalogic-cycles.sh` Assertion A | Decision 4: do not move them. |
| Stale prose after the tool's "from X to Y" collapse (Finding 6.4) | Write all narrative prose about this move *after* the tool runs, in phases 1 and 6. |
| `git-snapshot.sh` refuses on out-of-`file_scope` modifications | Phase 1 widens `file_scope` before any tree change. |
| `file:line` citation drift (C20) | Measured: zero non-`specs/` `file:line` citations target any moved file. No exposure. |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task relocates modules and renames namespaces;
  it introduces no proof obligation, no new declaration and no `sorry`. The Tactic Discovery Survey
  Protocol has no goal to survey. Verification is `lake build` plus the seven gate scripts, not a
  tactic portfolio.

## Context Extension Recommendations

- **Topic**: `move-modules.py` operational hazards.
  **Gap**: `resolve_move`'s directory-over-file preference silently orphans a sibling aggregator
  when a row names a stem that is both a directory and a `.lean` file, and `--namespace-map` is a
  repo-wide string rewrite with no scoping. Neither hazard is documented outside the source.
  **Recommendation**: add `context/project/lean4/tools/move-modules-hazards.md` recording both, with
  the file-granular-rows recipe from Finding 6.
- **Topic**: the namespace audit's bucket semantics.
  **Gap**: nothing records that `ancestor` is an *acceptable* bucket, so a move that pushes files
  from `ancestor` into `unrelated` reads as neutral in a diff while being a regression.
  **Recommendation**: a short note in `context/project/lean4/`, or a sentence in
  `PUBLICATION_REFACTOR.md` §6, stating that a relocation must be simulated against
  `classify_namespace` *before* it is planned.

## Appendix

### Commands run

```
python3 scripts/measure-refactor-partitions.py namespace-audit
python3 scripts/measure-refactor-partitions.py --help
bash scripts/{check-evidence-probes,check-copyright-headers,check-metalogic-cycles,
              readme-lint,typst-sync-check,check-paper-definitions}.sh
bash scripts/check-module-invariants.sh --no-build
python3 scripts/move-modules.py --help
git status --porcelain -- Tests/
git log --oneline -3 -- Tests/BimodalTest/TemporalWitnessProbe.lean
```

Plus five ad-hoc Python measurements driving `classify_namespace` and `first_namespace` from
`scripts/lib/import_graph.py` and `scripts/measure-refactor-partitions.py` directly, to simulate the
post-move audit, count declarations, test for collisions and short-name ambiguity, and enumerate
direct importers.

### Source references

- `docs/development/PUBLICATION_REFACTOR.md:92` (target layout), `:161-177` (namespace map),
  `:387-403` (Phase 5), `:531` (acceptance restatement)
- `scripts/measure-refactor-partitions.py:61-64` (the "24 unrelated / 15 language files" docstring
  count this task invalidates), `:100-110` (`LAYERS`), `:417-431` (`classify_namespace`),
  `:435-443` (`measure_namespaces`)
- `scripts/check-metalogic-cycles.sh:35-65` (assertion B contract), `:156-172` (the allowlist)
- `scripts/check-module-invariants.sh:988-1030` (C5), `:2135-2296` (C20), `:1858`, `:1884` (the two
  axiom baselines that change)
- `scripts/move-modules.py:383-404` (`resolve_move`), `:407-423` (`move_trees`)
- `scripts/readme-lint.sh:44` (scope), `:186-223` (Check 4, date staleness)
- `FormalSystem/Syntax/PlusLanguage.lean:47-54` (the Module Invariant the merge falsifies)
- `FormalSystem/Semantics/PlusLanguage.lean:20-21` (the "declarations stay in
  `FormalSystem.Semantics`" statement the merge overturns)
- `FormalSystem/Semantics/PlusLanguage/PlusStateLocal.lean:136,210` (the two-namespace pattern that
  already complies)

*Last verified: 2026-09-20*
