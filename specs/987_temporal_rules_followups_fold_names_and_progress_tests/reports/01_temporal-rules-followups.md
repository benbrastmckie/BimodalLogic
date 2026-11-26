# Research Report: Task #987

**Task**: 987 - Temporal rules follow-ups: fold names and progress tests
**Started**: 2026-11-24T00:00:00Z
**Completed**: 2026-11-25T00:00:00Z
**Effort**: medium (seven independent items, four of them mechanical; one behavioural fix already verified by compiled probe)
**Dependencies**: None blocking. `proof_mode_until_since_intro_unfold_induction` builds on the same modules and runs AFTER this record.
**Sources/Inputs**:
- Codebase: `FormalSystem/Automation/ProofMode/`, `FormalSystem/Theorems/ProofMode/TemporalComposition/`, `Tests/BimodalTest/Automation/`, `typst/generated/status.typ`, `records/proof-mode-architecture.md`
- lean-lsp MCP (`lean_run_code`, `lean_local_search`); index state `warming`/`consulted` as noted inline
- Compiled gates run live: `lake build`, `lake test`, `scripts/check-module-invariants.sh --emit-inventory --check`, `scripts/typst-sync-check.sh`, `scripts/typst-status-counts.sh --json`, `scripts/readme-lint.sh`
- Review provenance: `specs/reviews/pr-reviews-2026-11-21/pr8-review.md`, `pr8-comment.long.md`
**Artifacts**:
- `specs/987_temporal_rules_followups_fold_names_and_progress_tests/reports/01_temporal-rules-followups.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The contribution is merged and nothing has been done to it since.** `a7be7db65` ("Add
  compositional temporal rules and scope-aware carrying to the proof mode") is an ancestor of
  `HEAD` (`867264c55`), and `git log a7be7db65..HEAD` over `FormalSystem/Automation/ProofMode/`,
  `FormalSystem/Theorems/ProofMode/` and `Tests/BimodalTest/Automation/` is **empty**. All seven
  items stand; nothing can be dropped as already-done.
- **Item (3), the one behavioural item, is solved and the solution is measured.** Moving the
  instance-synthesis loop (`Basic.lean:79-85`) to sit immediately after the conclusion
  unification (`Basic.lean:94`) makes a goal that `lapply` rejects today compile, and the
  existing parameterless `ReviewInstance` `#guard_msgs` pin still matches byte-for-byte. Both
  halves were run, not reasoned about.
- **Item (5)'s narrowing is also measured, and the pinned message survives it.** The only
  frame-class failure `resolveRuleParameters` can raise for this gate is `"incompatible concrete
  frame classes in rewrite rule"`; matching on that substring and appending the original message
  otherwise keeps `integer-time reasoning requires FrameClass.ZTime ≤ FrameClass.Dense` exactly,
  so both existing pins stay green.
- **Item (7)'s premise is partly false and the correction matters.** The stamp commit
  `0c14ccb0e` DOES contain all nine new library files and four new test files — measured file
  counts at that commit are 808/113, exactly the recorded figures. The sole non-reproducing
  figure is `formalsystem-line-count`: recorded **422474**, measured **422468** at the stamp
  commit, a +6 delta owed to three LATER commits unrelated to this contribution.
- **Two hazards the implementer must not walk into.** `untilFold`/`sinceFold` also name an
  unrelated Rabinovich construction under `Metalogic/Expressiveness/Kamp/`, so a tree-wide sed
  breaks Kamp; and `readme-lint.sh` (a `verify-all.sh` step) is **already red** on this branch
  with 7 ungrandfathered stale stamps, 4 of them in directories this task edits.
- **A literal reading of item (2)'s DONE WHEN is unsatisfiable.** Of the 36 `throwError` lines the
  contribution added, 7 are structurally unreachable from parsed syntax; they cannot carry a
  `#guard_msgs` test. Research resolves this by scoping to reachable paths and documenting
  unreachability inline — see the triage table.

## Context & Scope

Seven follow-ups owed after the temporal-rules contribution merged. Items (1) and (2) come from
the posted review; (3)-(7) from the code review against `af0cde818`. This report establishes the
merged-tree baseline, measures each item's premise against the live tree, and verifies — by
compiled probe, before recommending — the two items whose fixes are not purely mechanical.

**Baseline gates measured on the current tree** (branch `dev/m7-ladder-continuation`, HEAD
`867264c55`):

| Gate | Result | Note |
|---|---|---|
| `lake build` | **PASS** (3027 jobs) | guarded, detached, bounded wait |
| `lake test` | **PASS** | zero `error` lines in log |
| `check-module-invariants.sh --emit-inventory --check` | **PASS** | passes *with* item (6)'s three wrong descriptions in place — confirms the gate cannot see them |
| `typst-sync-check.sh` | **PASS** (all 4 checks) | Check 2 reports `MISMATCH_COUNT=0` — confirms the gate cannot see item (7) either |
| `readme-lint.sh FormalSystem BimodalTools BimodalLib` | **FAIL** (7 new stale) | pre-existing, not caused by this task |

The working tree was dirty only in `specs/TODO.md` and `specs/state.json` at dispatch; no
`.lean` file was modified. Concurrent sibling 993 is scoped to `.claude-extensions.json` and does
not overlap.

## Findings

### Codebase Patterns

#### Item (1) — fold/unfold names: exact rename footprint

The settled vocabulary is fixed by `records/proof-mode-architecture.md`'s "Open decisions"
section, verbatim: *"The one-step Until and Since rules are `expand` and `contract`; `fold` and
`unfold` belong to the views tier alone."* Line 278 of the same record adds the direction:
`expand` is ZTime-gated, `contract` holds at Base. This matches the already-renamed keywords
(`luntil contract`, `luntil expand`).

The footprint is **exactly two Lean files**. Nothing in `docs/`, `typst/`, `Tests/` or
`docs/theorem-index.md` names any of these identifiers — the tests drive the tactics through
their keywords only, so no test needs repointing.

`FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean` — eight declarations,
each appearing **twice** (once in `FormalSystem.Theorems.ProofMode`, once mirrored in
`FormalSystem.PlusLanguage.ProofMode`):

| Current | Proposed | TM lines | TM⁺ lines |
|---|---|---|---|
| `untilFoldRule` | `untilContractRule` | 27, 37, 57 | 127, 157 |
| `sinceFoldRule` | `sinceContractRule` | 34, 63 | 133, 164 |
| `untilUnfoldRule` | `untilExpandRule` | 42, 72 | 139, 143, 173 |
| `sinceUnfoldRule` | `sinceExpandRule` | 48, 80 | 146, 150, 182 |
| `untilFold` | `untilContract` | 54 | 153 |
| `sinceFold` | `sinceContract` | 60 | 160 |
| `untilUnfoldCases` | `untilExpandCases` | 67 | 167 |
| `sinceUnfoldCases` | `sinceExpandCases` | 75 | 176 |

`FormalSystem/Automation/ProofMode/TemporalZTime.lean` — six identifiers plus four
backtick-quoted rule keys that must move in lockstep with the table above:

| Current | Proposed | Lines |
|---|---|---|
| `binaryFold` (private def) | `binaryContract` | 39, 87, 88 |
| `binaryUnfold` (private def) | `binaryExpand` | 49, 90, 92 |
| `luntilFold` (syntax node) | `luntilContract` | 73 |
| `luntilUnfold` (syntax node) | `luntilExpand` | 76 |
| `lsinceFold` (syntax node) | `lsinceContract` | 80 |
| `lsinceUnfold` (syntax node) | `lsinceExpand` | 83 |
| rule keys `` `untilFold ``, `` `sinceFold ``, `` `untilUnfoldCases ``, `` `sinceUnfoldCases `` | `` `untilContract ``, `` `sinceContract ``, `` `untilExpandCases ``, `` `sinceExpandCases `` | 18, 20, 22, 24 (and 45, 63 at the call sites) |

Prose that should move with the identifiers (not required by DONE WHEN, but it is the same
collision one level out): section headings `/-! ## One-step fold and unfold -/` (Theorems file
L24) and `/-! ### Fold and unfold -/` (L124), and six docstrings beginning "Unfold" (Theorems
L65, L74, L166, L175; Automation L75, L82).

**Collision hazard — do not sed the tree.** `untilFold` and `sinceFold` also name an entirely
unrelated construction, Rabinovich's bounded-fix `F_i`, in
`FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFix/BoundedFix.lean` (L197, L548 and ~30
use sites), with further references in `BoundedFixAnchored.lean` and
`EANegationFixFaithful/BoundedFixFaithful.lean`. Those are a different namespace, a different
type (`TemporalPred`, not `DerivationTree`), and must be left alone. Confine every edit to the
three `ProofMode` namespaces.

**All proposed names are free.** A tree-wide grep for `untilContract`, `sinceContract`,
`untilExpand`, `sinceExpand`, `binaryContract`, `binaryExpand`, `luntilContract`, `luntilExpand`,
`lsinceContract`, `lsinceExpand` returns nothing outside `specs/`.

**Gate interaction.** `Fold` → `Contract` is +4 characters. Both files sit under
`weak.linter.mathlibStandardSet = true` (100-column `linter.style.longLine`), so some lines will
need rewrapping, which changes line counts, which changes the `Lines` column of the generated
inventory in `FormalSystem/Automation/ProofMode/README.md` and
`FormalSystem/Theorems/ProofMode/TemporalComposition/README.md`. Re-run
`bash scripts/check-module-invariants.sh --emit-inventory` (write mode) after the rename.

#### Item (2) — `lprogress` coverage: measured matrix

A correction to the record: `lprogress` has **two** call sites tree-wide, not one. The progress
test file has exactly one (`cases`), as the record says, but
`Tests/BimodalTest/Automation/ProofModeTest.lean:102` also exercises `lprogress using [hAB, hBC]`.
The implementer should not re-add that cell.

`lprogress` has four forms (`TemporalBoolean.lean:148-159`). Coverage today:

| Form | future TM | past TM | future TM⁺ | past TM⁺ |
|---|---|---|---|---|
| `lprogress using [h₁, h₂]` | `ProofModeTest.lean:102` | — | — | — |
| `lprogress cases` | `...ProgressTest.lean:21` | — | — | — |
| `lprogress consequence using h` | — | — | — | — |
| `lprogress trans using h` | — | — | — | — |

14 of 16 cells are empty. Every rule the empty cells need already exists:
`FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalBoolean.lean` declares
`leadsToConsequence`, `leadsToTrans`, `progressConsequence`, `progressCases` and their four `past`
mirrors in BOTH `FormalSystem.Theorems.ProofMode` (L89-141) and
`FormalSystem.PlusLanguage.ProofMode` (L162-227); `progressTrans`/`pastProgressTrans` live in
`FormalSystem/Theorems/ProofMode/Temporal.lean:113,129` and `PlusTemporal.lean:101,110`. So no new
pure rule is needed — only test examples. TM⁺ examples can be modelled on
`ProofModeCarryingTest.lean:59-88`, which already writes `PlusDerivationTree fc [...] ...` goals.

#### Item (2) — `throwError` inventory and reachability triage

The contribution added **36** `throwError` lines across 7 modules (computed by diffing
`a7be7db65^..a7be7db65` and mapping each added line back to its current line number). They fall
into three classes.

**Already pinned (5 sites, no work owed):**

| Site | Message | Pinning test |
|---|---|---|
| `Basic.lean:85` | `lapply could not synthesize the required instance ...` | `ProofModeTemporalTest.lean:93-98` |
| `Carrying.lean:82` | `` `keeping` carries only ...-scoped facts ... `` | `ProofModeCarryingTest.lean:104,112,120` (3 variants) |
| `Temporal.lean:118` | `integer-time reasoning requires FrameClass.ZTime ≤ ...` | `ProofModeCarryingTest.lean:128`, `ProofModeTemporalZTimeTest.lean:59` |
| `Temporal.lean:380` | `ltime_reflect using expects a native derivation` | `ProofModeTemporalTest.lean:104` |
| `Modal.lean:90` | `selected guarantee must have the matching G scope` | `ProofModeTemporalTest.lean:119` |

**Structurally unreachable from parsed syntax (7 sites, no `#guard_msgs` test is constructible):**

| Site | Message | Why unreachable |
|---|---|---|
| `Temporal.lean:103` | `unregistered temporal composition rule {rule}` | `rule` is supplied by the elaborator, never by user syntax |
| `TemporalBoolean.lean:34` | `unregistered strict leads-to rule {rule}` | same |
| `TemporalZTime.lean:26` | `unregistered one-step temporal rule {rule}` | same |
| `Temporal.lean:445` | `` expected `guard` or `event` `` | fallback arm of a `&"guard"`/`&"event"` keyword match; the parser already rejects anything else |
| `Temporal.lean:451` | `` expected `future` or `past` `` | same |
| `Discrete.lean:118` | `` expected `future` or `past` `` | same |
| `Modal.lean:110` | `expected {formulas.size} body hypothesis names ...` | reachable, but only through `lmodal_intro`'s arity check — see note below |

(`Modal.lean:110` is in fact reachable and belongs in the next class; it is listed here only
because its `{formulas.size}` interpolation makes the pinned text depend on the example's context
length, so the test must fix that length explicitly.)

**Reachable and unpinned (24 sites, the real work of item (2)):** `Basic.lean:94`;
`Carrying.lean:77, 81, 87`; `Discrete.lean:81, 98`; `Meta.lean:75`; `Modal.lean:88, 101, 105, 110,
203, 210`; `Temporal.lean:115, 144, 289, 330, 359, 382, 384, 394`; `TemporalBoolean.lean:40, 53,
78, 93, 95, 110, 131, 133`. The nine in `TemporalBoolean.lean` are the `lprogress` family's own
and pair naturally with the coverage matrix above; `Temporal.lean:115` ("the frame class of the
goal is undetermined") pairs with item (5)'s module.

Message-text caution: `Carrying.lean:82`'s pinned variants show that an interpolated message is
pinnable, but `Basic.lean:85`'s instance message embeds a metavariable name (`?m.3`, measured)
when the class type is undetermined — see item (3). Never pin a message containing `?m.N`.

#### Item (3) — instance-synthesis ordering: verified fix

`Basic.lean:79-85` runs the instance loop before `adaptProof` (L86), before the premise chain
(L88-92) and before `isDefEq (← inferType proof) (← goal.getType)` (L93). The frame-class,
context and formula metavariables are assigned at L93, not before — the implication-chain loop
(L70-78) unifies only the *formula*. So an instance argument whose type mentions any of them
cannot be synthesized.

**Measured, pre-fix (current tree, via `lean_run_code`):**

```
class FrameTag (fc : FrameClass) : Prop where marker : True
instance : FrameTag FrameClass.ZTime := ⟨trivial⟩
private def requiresFrameTag [FrameTag fc] : ⊢[fc] A.imp A := by lintro h; lexact h

example : ⊢[FrameClass.ZTime] A.imp A := by
  lapply @requiresFrameTag _ A
-- error: lapply could not synthesize the required instance FrameTag ?m.3
```

**Measured, post-fix:** a byte-identical copy of `applyDerivationProof` with L79-85 moved to sit
immediately after L94 and before `goal.assign proof` (L95) closes the same goal. Run as one
snippet, the pre-fix call under `fail_if_success` and the post-fix call closing the goal — the
snippet compiles clean, so both halves hold simultaneously.

**Regression-test shape.** Write it as a POSITIVE example, not a `#guard_msgs` pin: the pre-fix
message embeds `?m.3`, a metavariable index that is not stable across edits to the file. A
positive example fails loudly against the pre-fix ordering (verified) and needs no pinned text.

`FrameClass` is the right parameter to key the class on, because it is the one a rule's
conclusion type always mentions and the chain loop never assigns.

#### Item (4) — the ordering contract in the docstring

`Basic.lean:57-59` currently says only *"Only holes created since `firstNewIndex` become new
goals."* The sole in-tree caller, `applyProof` (L111-116), reads `(← getMCtx).mvarCounter` BEFORE
`elaborateProof term`, which is the required order; nothing in the doc comment says so. The
consumer of `firstNewIndex` is the filter at L101 (`if (← id.getDecl).index < firstNewIndex then
continue`), so a counter read after elaboration filters out every parameter metavariable the rule
itself created. Documentation-only change; no behavioural risk.

#### Item (5) — the bare catch in `integerTimeGate`

`Temporal.lean:111-119`. `resolveRuleParameters` is defined at `Rewriting.lean:301` and, for the
single `#[gate]` parameter of type `LE.le FrameClass.ZTime fc`, can raise exactly three things:

1. `"rewrite premise has undetermined parameters; supply the rule arguments"` — **unreachable
   here**, because `integerTimeGate` already rejects an undetermined frame class at L114-115.
2. `"incompatible concrete frame classes in rewrite rule"` (`Rewriting.lean:328`) — the
   frame-class failure, raised when `mkDecide` evaluates the gate to `Bool.false`.
3. The original exception rethrown from the `mkDecide`/`whnf` catch (`Rewriting.lean:330-332`)
   when the type is fully concrete — a `Decidable`-synthesis failure, a `maxRecDepth`, or an
   interrupt. This is the class the bare catch currently mislabels.

**Measured:** `FormalSystem/ProofSystem/Axioms.lean:521` declares
`instance : DecidableRel (LE.le : FrameClass → FrameClass → Prop)`, and
`example : ¬(FrameClass.ZTime ≤ FrameClass.Dense) := by decide` compiles (run live). So the
`Dense` case that both existing tests pin takes path (2), not path (3) — which is why narrowing
on path (2) preserves the pinned text.

**Verified narrowing** (run as a snippet; the `#guard_msgs` pin matched):

```lean
let pending ← try resolveRuleParameters #[gate] catch error => do
  let original ← error.toMessageData.toString
  if (original.splitOn "incompatible concrete frame classes").length > 1 then
    throwError "integer-time reasoning requires FrameClass.ZTime ≤ {judgment.frame}"
  else
    throwError "integer-time reasoning requires FrameClass.ZTime ≤ {judgment.frame}\n{original}"
```

`String.containsSubstr` would read better but is **NOT in this module's import closure**
(measured: `#eval "...".containsSubstr "..."` after `import FormalSystem.Automation.ProofMode`
fails with "the environment does not contain `String.containsSubstr`"); it lives in Batteries and
would need a new import. `splitOn` is verified to compile as-is.

The record ties this to item (2): `Temporal.lean:115` ("the frame class of the goal is
undetermined") is the sibling `throwError` in the same function and is unpinned. Narrow the catch
and write both `#guard_msgs` tests (the undetermined-frame-class one, and a non-frame-class one if
a trigger can be constructed) as one piece of work in one module.

#### Item (6) — the three wrong module descriptions

`FormalSystem/Automation/ProofMode/README.md`:

| Line | Current | What the module now contains |
|---|---|---|
| 14 | `` `Carrying.lean` | 91 | <!-- TODO: add description --> `` | The carrying table: `CarryRule`, `carryRules`, `carryRule?`, `carriedFacts` — one rule per (source operator, target scope) pair, shared by the scope tactics' `keeping` clause |
| 22 | `` `Temporal.lean` | 476 | Future/past scopes, eventuality composition, progress, and Until/Since mapping `` | "progress" is wrong — it moved to `TemporalBoolean.lean`. What remains: future/past scopes, eventuality composition and advance, the integer-time gate, Until/Since mapping and monotonicity, whole-judgment time reflection |
| 15 | `` `Discrete.lean` | 129 | Next/Previous scopes and invariance with explicit ZTime certificates `` | The module gained `linduction` (L112, discrete backward induction Z1) beside `lstep` and `linvariant`, and the certificate is now reused-or-decided via `integerTimeGate`, not always explicit |

**Measured confirmation that the gate cannot see any of this:**
`scripts/check-module-invariants.sh --emit-inventory --check` **PASSES** on the current tree, with
the TODO placeholder and both wrong descriptions in place. The generator's own source says why
(L260-263, L479, L520): an existing description cell is carried across verbatim, keyed on the file
name, and only a file with no row at all gets the `TODO` placeholder. Hand edit is the only route.

#### Item (7) — the status stamp: corrected diagnosis

`typst/generated/status.typ` records `stamp-commit = "0c14ccb0e"`, `stamp-date = "2026-11-25"`.

The record's premise — *"a stamp commit whose tree does not contain the nine new library files and
four new test files its own counts include"* — **does not hold on the merged tree.** Measured:

| | recorded in `status.typ` | measured at `0c14ccb0e` | measured at `HEAD` |
|---|---|---|---|
| `formalsystem-file-count` | 808 | **808** | 808 |
| `tests-file-count` | 113 | **113** | 113 |
| `tools-file-count` | 44 | **44** | 44 |
| `formalsystem-line-count` | 422474 | **422468** | 422474 |
| `tests-line-count` | 32070 | **32070** | 32070 |
| `tools-line-count` | 20369 | **20369** | 20369 |
| every other scalar | — | matches | matches |

Method: `git worktree add --detach <scratch> 0c14ccb0e`, then
`bash <worktree>/scripts/typst-status-counts.sh --json` (the `--json` path reads no `.lake` and
takes no lock). The worktree was removed afterwards.

So `git ls-tree 0c14ccb0e -- FormalSystem/Automation/ProofMode/TemporalBoolean.lean
.../TemporalZTime.lean` returns both blobs, and `0c14ccb0e` is itself an ancestor of `HEAD`: the
stamp was already regenerated on the merged branch, as the dispatch anticipated. What remains is
narrower and real: **`formalsystem-line-count` is 6 lines ahead of the stamp commit's tree.** The
+6 is the net delta of the three commits between `0c14ccb0e` and `HEAD` —
`FormalSystem/Metalogic/AuxiliaryAtoms.lean`, `FormalSystem/NomicLanguage/NomicTruth.lean`,
`FormalSystem/SourceLanguage.lean` (15 insertions, 9 deletions), none of them part of the temporal
rules contribution. The file was regenerated while those edits sat in the working tree and `HEAD`
was still `0c14ccb0e`.

**The gate cannot catch this, by construction.** `typst-sync-check.sh` Check 2 compares
`status.typ` against a live regeneration of the *working tree*, and `stamp-commit`/`stamp-date` are
deliberately absent from both `scalar_fields` and `string_fields` (`typst-sync-check.sh:204-232`).
It reports `MISMATCH_COUNT=0` today. The DONE WHEN clause "the status stamp's commit reproduces
the status counts" therefore has **no mechanical gate** and must be verified by the detached-worktree
procedure above.

**Sequencing consequence — this is the item that constrains the whole task's commit order.** This
task changes `.lean` line counts (the rename rewraps lines; the new tests add files and lines). If
`status.typ` is regenerated before those changes are committed, the stamp will again name a commit
whose tree does not reproduce the counts. Regenerate it **last, in its own commit, after every
`.lean` change is committed.** The write path needs a built library (it reads `#print axioms`), so
run `lake build` first and route through the build guard.

### External Resources

- `records/proof-mode-architecture.md` is the authority for item (1)'s target vocabulary; its
  "Open decisions" section states the `expand`/`contract` vs `fold`/`unfold` split with no
  remaining ambiguity. Prose in the same record (L212: "one-step unfolding of Until and Since")
  still uses the old words; updating it is optional under the DONE WHEN, which speaks of
  identifiers.
- No Mathlib lemma search was needed: every rule the new tests require already exists in-tree
  (verified by name). `lean_local_search`'s `index` reported `warming` on the one lookup made
  (`String.containsSubstr`), so that result was corroborated by a compiled `#eval` probe rather
  than relied on as proof of absence.

### Recommendations

- **Item (3): move `Basic.lean:79-85` to sit immediately after `Basic.lean:94` and before
  `goal.assign proof`, keeping the `message` diagnostic verbatim.**
  [VERIFIED: PASS — a byte-identical reordered copy of `applyDerivationProof` run via
  `lean_run_code` against the live library: `fail_if_success lapply @requiresFrameTag _ A`
  succeeded (pre-fix ordering rejects it) and `lapply_fixed @requiresFrameTag _ A` closed the
  goal, in one clean-compiling snippet]
- **Item (3): the existing `ReviewInstance` `#guard_msgs` pin needs no change.**
  [VERIFIED: PASS — the pinned block (`failed to synthesize instance of type class / ReviewInstance
  / lapply could not synthesize the required instance ReviewInstance / Hint: ...`) matched
  byte-for-byte under the reordered elaborator via `lean_run_code`]
- **Item (3): write the regression test as a positive example keyed on a `FrameClass`-parameterized
  class, not as a `#guard_msgs` pin of the failure.**
  [VERIFIED: FAIL for the `#guard_msgs` variant — the measured pre-fix message is `lapply could
  not synthesize the required instance FrameTag ?m.3`, whose `?m.3` is an unstable metavariable
  index; revised to: a positive example, which fails against the pre-fix ordering (measured) and
  pins no text]
- **Item (5): narrow the catch by matching `"incompatible concrete frame classes"` in
  `(← error.toMessageData.toString)` via `(s.splitOn pat).length > 1`, re-throwing the ZTime
  message alone on a match and the ZTime message plus the original on anything else.**
  [VERIFIED: PASS — the narrowed `integerTimeGate` compiled via `lean_run_code` and a
  `#guard_msgs in example : ⊢[FrameClass.Dense] ...` pinning `integer-time reasoning requires
  FrameClass.ZTime ≤ FrameClass.Dense` matched, so both existing pins survive; the admissible
  `FrameClass.ZTime` case still resolved the gate]
- **Item (5): do not use `String.containsSubstr`.**
  [VERIFIED: FAIL — `#eval "...".containsSubstr "..."` after `import
  FormalSystem.Automation.ProofMode` errors with "the environment does not contain
  `String.containsSubstr`"; revised to: `(s.splitOn pat).length > 1`, which compiles in that
  import context]
- **Item (1): confine the rename to the three `ProofMode` namespaces; never sed `untilFold` or
  `sinceFold` tree-wide.** [No compiled gate applicable — a grep finding, corroborated by reading
  `BoundedFix.lean:197,548`]
- **Item (1): the ten proposed new identifiers are unused.** [VERIFIED: PASS — tree-wide grep for
  all ten returns nothing outside `specs/`]
- **Item (1): re-run `bash scripts/check-module-invariants.sh --emit-inventory` (write mode) after
  the rename, because rewrapping for the 100-column linter changes the `Lines` column of two
  generated inventories.** [VERIFIED: PASS at baseline — `--emit-inventory --check` passes today,
  so any post-rename failure is this task's own and is resolved by the write-mode run]
- **Item (6): hand-edit the three description cells; the gate will never flag them.**
  [VERIFIED: PASS — `--emit-inventory --check` passes on the current tree with all three defects
  present, confirming the description column survives regeneration]
- **Item (7): regenerate `typst/generated/status.typ` LAST, in its own commit, after every `.lean`
  change is committed, then verify by detached worktree at the new stamp commit.**
  [VERIFIED: FAIL for the current file — at stamp commit `0c14ccb0e`,
  `scripts/typst-status-counts.sh --json` yields `formalsystem_line_count: 422468` against the
  recorded 422474; revised to: regenerate on the final merged tree and confirm with
  `git worktree add --detach <scratch> <new-stamp> && bash <scratch>/scripts/typst-status-counts.sh --json`,
  which is the only check that sees this, since `typst-sync-check.sh` excludes the stamp fields]
- **Item (2): scope the negative tests to the 24 reachable unpinned `throwError` sites; for the 7
  structurally unreachable arms, add a one-line in-source note saying the arm is unreachable from
  parsed syntax rather than leaving a silent gap.** [No compiled gate applicable — a literal
  reading of "every `throwError` path" cannot be satisfied for an arm the parser forbids]
- **Item (2): do not re-add a `lprogress using [...]` future-TM example; `ProofModeTest.lean:102`
  already has one.** [No compiled gate applicable — a grep finding]

## Decisions

- **The merged tree is the baseline and nothing is dropped.** `a7be7db65` is an ancestor of HEAD
  and no later commit touches the three affected directories, so all seven items are live. The
  dispatch's invitation to "drop whatever the contributor already did" yields nothing — except a
  partial correction to item (7), recorded above.
- **Item (2)'s DONE WHEN is read as "every reachable `throwError` path".** A literal reading is
  unsatisfiable: 7 of the 36 added sites are fallback arms the parser cannot reach, or
  elaborator-internal `unregistered rule` guards whose argument no user can supply. Writing a
  `#guard_msgs` test for them would require a synthetic harness that tests nothing about the
  tactics. Research resolves the ambiguity rather than escalating it, because the resolution is
  determined by the code: the arms are provably unreachable.
- **Item (3)'s regression test is positive, not message-pinned.** Decided on measured evidence: the
  pre-fix message carries `?m.3`.
- **Item (7)'s finding is restated, not discarded.** The record's reason is wrong (the files ARE in
  the stamp commit's tree) but its conclusion is right (the stamp does not reproduce its counts)
  and its fix is right (regenerate on the merged tree). Only the verification method and the commit
  ordering change.
- **`readme-lint.sh`'s 3 out-of-territory stale stamps are left alone.** Bumping a `*Last
  verified:*` stamp on a directory this task does not touch would assert a verification that did
  not happen, and per the recorded baseline mechanics it also permanently un-grandfathers nothing
  (these 3 are already ungrandfathered) while claiming work not done. They are reported, not fixed.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| A tree-wide `untilFold`/`sinceFold` rename breaks `Metalogic/Expressiveness/Kamp/` | Edit only the two `ProofMode` files named in item (1)'s tables; after the rename, grep `EANegationFix` for the old names and confirm they are still there |
| Rewrapping for the 100-column linter silently stales the generated `Lines` column | Run `--emit-inventory` (write mode), then `--emit-inventory --check` to confirm |
| Item (5)'s narrowing breaks the two pinned `integer-time reasoning` tests | Already measured not to: the `Dense` case reaches the frame-class branch, which the narrowing matches. Re-run `lake test` after the edit regardless |
| Item (3)'s move changes which error surfaces first on an unrelated failure | The move places the loop after the `"the applied rule produced an incompatible judgment"` check, so that message now wins over the instance message when both apply. Measured: the `ReviewInstance` pin is unaffected, because its goal unifies cleanly |
| `status.typ` regenerated too early re-creates the exact defect being fixed | Regenerate in a final, separate commit after all `.lean` commits; verify by detached worktree, since `typst-sync-check.sh` is blind to the stamp |
| `readme-lint.sh` is already red, so a post-task run looks like a regression | 7 new stale rows at baseline, recorded here. 4 are in-territory (`Automation/ProofMode`, `Theorems/ProofMode`, `Theorems/ProofMode/TemporalComposition`, `Tactic`) and should end green; the other 3 (`Conservativity/Star`, `Expressiveness`, `WeakCanonical`) must still be red afterwards |
| 24 new negative tests is a large mechanical surface that could swamp a single phase | Partition by module: the 9 `TemporalBoolean.lean` sites travel with item (2)'s coverage matrix, `Temporal.lean:115` travels with item (5), and the rest group by file |
| Concurrent sibling 993 on the same working tree | Its declared scope is `.claude-extensions.json` only — no overlap with any path in this report. Re-read each file immediately before editing anyway |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task is metaprogramming, naming and test
  coverage work; it contains no open proof goal for which a tactic portfolio would be surveyed.
  The compiled probes run here exercised elaborators, not proof search.

## Context Extension Recommendations

- **Topic**: Verifying a generated status/stamp file reproduces its own counts
- **Gap**: `typst-sync-check.sh` compares a generated file against a regeneration of the *working
  tree* and deliberately excludes the stamp fields, so a stamp naming a commit whose tree yields
  different figures passes every gate. The detached-worktree procedure that does catch it is not
  written down anywhere.
- **Recommendation**: add `context/project/lean4/patterns/stamp-commit-reproduction.md` (or a
  section in an existing typst-tooling context file) recording the procedure —
  `git worktree add --detach <scratch> <stamp>`, run the generator's lock-free `--json` path there,
  diff against the committed file — plus the commit-ordering rule that a stamp must be regenerated
  after, and separately from, the content commits it counts.

- **Topic**: `#guard_msgs` pins over messages containing metavariable indices
- **Gap**: Nothing in the Lean context warns that a pinned error message embedding `?m.N` is
  unstable across unrelated edits to the same file.
- **Recommendation**: add a short subsection to `context/project/lean4/` on negative-test design:
  prefer a positive example where the fix makes a goal compile; pin text only when the message is
  metavariable-free.

## Appendix

### Compiled probes run (all via `lean_run_code` against the live built library)

1. `example : ¬(FrameClass.ZTime ≤ FrameClass.Dense) := by decide` and the positive `ZTime` case —
   establishes which `resolveRuleParameters` branch the pinned `Dense` test reaches.
2. `FrameTag`-parameterized `lapply` probe — measured the pre-fix failure
   `lapply could not synthesize the required instance FrameTag ?m.3`.
3. Reordered `applyDerivationProofFixed` + `lapply_fixed` tactic — measured `fail_if_success
   lapply` alongside a succeeding `lapply_fixed`, in one snippet.
4. Reordered elaborator against the existing `ReviewInstance` `#guard_msgs` block — matched.
5. `integerTimeGateNarrowed` + `lgate_probe` tactic, with a `#guard_msgs` pin of
   `integer-time reasoning requires FrameClass.ZTime ≤ FrameClass.Dense` — matched; the `ZTime`
   case resolved the gate.
6. `#eval "...".containsSubstr "..."` — failed, establishing the identifier is outside the import
   closure.

### Shell measurements

- `git merge-base --is-ancestor a7be7db65 HEAD` → true; `git log a7be7db65..HEAD -- <3 dirs>` → empty.
- `git show --stat a7be7db65` → 45 files, 2198 insertions.
- 36 added `throwError` lines, mapped to current line numbers by diffing `a7be7db65^..a7be7db65`
  per file.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` → PASS.
- `bash scripts/typst-sync-check.sh` → PASS, Check 2 `MISMATCH_COUNT=0`.
- `bash scripts/typst-status-counts.sh --json` at HEAD → all recorded figures match;
  `stamp_commit: 867264c55`.
- Same, in a detached worktree at `0c14ccb0e` → `formalsystem_line_count: 422468`, everything else
  matching.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` → FAIL, 7 new stale dates
  (listed against `scripts/readme-date-baseline.txt`).
- Guarded `lake build` → exit 0, 3027 jobs. Guarded `lake test` → exit 0.

### References

- `records/proof-mode-architecture.md` (vocabulary authority, "Open decisions")
- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` (items 1-2 provenance)
- `scripts/check-module-invariants.sh:260-263, 479, 520` (description-column survival)
- `scripts/typst-sync-check.sh:204-232` (stamp fields excluded from Check 2)
- `scripts/verify-all.sh:68-101` (gate battery membership)
