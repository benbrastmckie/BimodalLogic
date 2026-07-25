# Mathlib Linter Compliance — Empirical Baseline

**Task**: 293 — Audit and fix Mathlib linter compliance across sorry-free modules scheduled for
porting to cslib
**Session**: sess_1784999032_8d6f8f_293
**Status**: research complete

Every number in this report comes from a command that was actually run. Reproduction commands are
given inline. Nothing here is inferred from what Mathlib's linters "would probably" say.

---

## 1. Toolchain correction (blocks everything downstream)

`CLAUDE.md` and the task dispatch both state **Lean v4.27.0-rc1 / Mathlib v4.27.0-rc1**. That is
stale. Actual:

```
$ cat lean-toolchain
leanprover/lean4:v4.33.0-rc1
$ git -C .lake/packages/mathlib log -1 --format='%H %d'
79d0395a1825a6264ad5d269e35e60537518955e  (HEAD, tag: v4.33.0-rc1)
$ grep 'require mathlib' -A1 lakefile.lean
require mathlib from git "…/mathlib4.git" @ "v4.33.0-rc1"
```

This matters because the linter mechanism that works on v4.33 (`linter.mathlibStandardSet`,
registered in `Mathlib/Init.lean:81`) did not exist in the same form on v4.27. `CLAUDE.md`'s
"Lean Version" section should be corrected to v4.33.0-rc1.

---

## 2. The working linter invocations

The task description proposes `set_option linter.all true` or `#check_lint`. **Neither exists in
this toolchain.** There is no `linter.all` option and no `#check_lint` command. There are exactly
two working mechanisms, and they cover disjoint linter families — both are required.

### Mechanism A — syntax/style linters (`linter.mathlibStandardSet`)

```bash
lake env lean -Dlinter.mathlibStandardSet=true <file.lean>
```

`linter.mathlibStandardSet` is a linter *set* registered at
`.lake/packages/mathlib/Mathlib/Init.lean:81`, holding 26 linters (`linter.style.longLine`,
`linter.style.emptyLine`, `linter.flexible`, `linter.style.show`, …). It is enabled per-file via
`-D` on the command line, or project-wide by adding `⟨`weak.linter.mathlibStandardSet, true⟩` to
`theoryLeanOptions` in `lakefile.lean` (this is what Mathlib's own lakefile does at line 29).

Verified over all 277 buildable modules in ~4 min wall (`xargs -P 8`). Two caveats found:

- `Theories/Bimodal/Automation/AxiomNames.lean` and `Automation/LemmaDB.lean` fail with
  `invalid -D parameter, unknown configuration option 'linter.mathlibStandardSet'` — they do not
  transitively import Mathlib, so the option is unregistered in their environment. Both are
  **outside** the task's file_scope, so this does not block the task.
- `lake env lean` does not apply the lakefile's `leanOptions`. I checked that this changes nothing:
  adding `-DautoImplicit=false -Dpp.unicode.fun=true -DmaxSynthPendingDepth=3` produced **identical**
  warning counts on `Syntax/Formula.lean` (11), `Theorems/ModalS5.lean` (89),
  `Semantics/Truth.lean` (5), `ProofSystem/Axioms.lean` (61).

### Mechanism B — declaration/environment linters (`runLinter`)

```bash
lake exe runLinter Bimodal
```

Works out of the box (the `runLinter` exe comes from the batteries dependency). Output:

```
-- Found 1328 errors in 6520 declarations (plus 13047 automatically generated ones)
   in Bimodal with 14 linters
```

This is the family that carries the **naming** and **docstring** checks the task asks about
(`defsWithUnderscore`, `docBlame`) — Mechanism A cannot see them. Note `docBlameThm` (docstrings on
*theorems*) is `@[env_linter disabled]` by default and Mathlib does not enable it, so theorem
docstrings are not audited.

`runLinter` reads a suppression file from `scripts/nolints.json` relative to cwd
(`.lake/packages/batteries/scripts/runLinter.lean:133`). No such file exists in this repo; `--update`
would generate one. Whether cslib accepts nolints entries is a policy question for the maintainers,
not something research can settle.

### What a plain `lake build` already shows

The dispatch intel states a full `lake build` emits only the sorry warnings plus "~21
unusedSimpArgs". **That is incorrect** — it is an artifact of reading only the tail of the build log.
A warm `lake build` replays every cached diagnostic:

```
$ lake build 2>&1 | grep -c "warning:"          → 1657 lines
$ lake build 2>&1 | grep -c "declaration uses"  → 12
$ lake build 2>&1 | grep -c linter.unusedSimpArgs → 525
$ lake build 2>&1 | grep -c "has been deprecated" → 554
```

These match my per-file sweep exactly. The real split is:

| | distinct diagnostics |
|---|---|
| Already visible in `lake build` today | **1,491** |
| Added only by `linter.mathlibStandardSet` | **5,679** |
| Added only by `runLinter` | **1,291** |
| **Total gap to Mathlib-clean** | **8,461** |

---

## 3. Scope resolution: which modules are actually in scope

The declared `file_scope` includes `Theories/Bimodal/Metalogic/` — 199 buildable modules, and where
all sorry debt lives. Resolving that tension explicitly, as instructed:

**Sorry inventory (authoritative).** `lake build` reports exactly 12 sorried declarations, matching
the dispatch intel precisely:

| File | Lines |
|---|---|
| `Metalogic/Bundle/SuccRelation.lean` | 553, 562, 585, 609, 623, 636, 646 |
| `Metalogic/Bundle/SuccExistence.lean` | 436, 742, 816 |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 194 |
| `Metalogic/WeakCanonical/Transfer.lean` | 1277 |

Plus `Bimodal.Metalogic.BXCanonical.completeness` depends on `sorryAx`.

Note `Theories/Bimodal/Boneyard/` (153 files, hundreds of raw `sorry` tokens) is **not built at
all** — `find .lake/build/lib/lean/Bimodal/Boneyard -name '*.olean' | wc -l` → 0, and no non-boneyard
file imports it. It is out of scope by construction. Also `ProofSystem/LinearityDerivedFacts.lean`
is an orphan: it has no olean, i.e. nothing imports it.

**Recommended scope, three tiers:**

| Tier | Contents | Files | Sorry-free | Style diags | runLinter |
|---|---|---|---|---|---|
| **T1 core** | Syntax, Semantics, ProofSystem, Theorems, FrameConditions | 34 | yes | 625 | 215 |
| **T2 named Metalogic** | Soundness+SoundnessLemmas, Core (MCS/Deduction), Completeness, Decidability, WeakCanonical/Separation, Metalogic.lean | 33 | yes | 536 | 85 |
| **T3 Metalogic remainder** | Bundle, BXCanonical, Algebraic, WeakCanonical (rest) | 166 | **no** | 5,297 | 839 |

**T1 + T2 = 67 files, all sorry-free, 1,461 total diagnostics.** This is exactly the set the task
title describes ("all sorry-free modules scheduled for porting"), and it maps 1:1 onto the named
subsystems. T3 holds 84% of the debt and all the sorries, and is not sorry-free, so it falls outside
the task's own stated predicate. I recommend the plan target T1+T2 and explicitly defer T3.

**Two named targets do not exist as claimed:**

- **`ConservativeExtension`** exists only at `Theories/Bimodal/Boneyard/ConservativeExtension/` —
  dead, unbuilt code. There is nothing to lint.
- **`Separation`** exists at `Metalogic/WeakCanonical/Separation/` (3 files: `Defs.lean`,
  `KampTranslation.lean`, `SemanticBridge.lean`). The larger `Kamp/Boneyard/Separation/` tree is
  dead. Only the 3 live files are in scope.

---

## 4. Per-category work quantification

### T1 core (34 files) — Mechanism A

| Category | Count | Files |
|---|---|---|
| `linter.style.emptyLine` | 489 | 10 |
| `linter.style.longLine` | 89 | 16 |
| `linter.flexible` | 24 | 5 |
| `linter.unusedSimpArgs` | 9 | 3 |
| `linter.unusedVariables` | 4 | 1 |
| `linter.defProp` | 3 | 3 |
| `linter.style.docString` | 3 | 2 |
| `linter.style.whitespace`, `linter.style.show` | 1 each | 2 |

Per-file, T1, worst first:

| File | empty | long | flex | simpArg | other | TOT |
|---|---|---|---|---|---|---|
| `Theorems/ModalS5.lean` | 87 | 2 | | | | 89 |
| `Theorems/Propositional/Core.lean` | 75 | 2 | | | | 77 |
| `Theorems/Combinators.lean` | 48 | 18 | | | | 66 |
| `Theorems/Perpetuity/Bridge.lean` | 57 | 6 | | 3 | | 66 |
| `ProofSystem/Axioms.lean` | 52 | | 9 | | | 61 |
| `Theorems/Propositional/Connectives.lean` | 53 | | 6 | | | 59 |
| `Theorems/ModalS4.lean` | 50 | 2 | | | | 52 |
| `Theorems/Perpetuity/Principles.lean` | 41 | 4 | 1 | 5 | | 51 |
| `Theorems/Propositional/Reasoning.lean` | 15 | 4 | 4 | | | 23 |
| `Syntax/Formula.lean` | | 7 | | | 4 uVar | 11 |
| `Syntax/SubformulaClosure/TemporalFormulas.lean` | | 11 | | | | 11 |
| `Theorems/ContextualProofs.lean` | | 11 | | | | 11 |
| `Semantics/TaskFrame.lean` | | 3 | 1 | | 2 docStr, 1 ws | 7 |
| `ProofSystem/Derivation.lean` | 6 | 1 | | | | 7 |
| (14 more files) | ≤5 | ≤3 | ≤1 | ≤1 | | ≤5 |

### T2 named Metalogic (33 files) — Mechanism A

Concentrated in three files; 20 of 33 files have ≤9 diagnostics and 6 have zero.

| File | long | simpArg | flex | empty | show | TOT |
|---|---|---|---|---|---|---|
| `Metalogic/Soundness.lean` | 40 | 162 | | 2 | | 208 |
| `Metalogic/SoundnessLemmas/DenseValidity.lean` | 19 | 29 | | | | 68 |
| `Metalogic/Decidability/Saturation.lean` | 23 | | 21 | | | 52 |
| `Metalogic/WeakCanonical/Separation/Defs.lean` | 2 | | | | | 52 (mostly runLinter) |
| `Metalogic/Decidability/CountermodelExtraction.lean` | 20 | 5 | 4 | | | 39 |
| `Metalogic/Core/DeductionTheorem.lean` | | 6 | 12 | 8 | | 37 |
| `Metalogic/SoundnessLemmas/FrameClassVariants.lean` | 12 | 8 | 4 | | 7 | 37 |
| (26 more) | ≤13 | ≤3 | ≤6 | ≤4 | ≤1 | ≤14 |

### Mechanism B (runLinter), T1+T2

| Linter | T1 | T2 | Notes |
|---|---|---|---|
| `defsWithUnderscore` | 189 | 50 | see §5 — the real naming problem |
| `simpNF` | 18 | 24 | 17 of the 18 T1 hits are `LINTER FAILED`, i.e. the linter itself errored |
| `unusedArguments` | 6 | 5 | all 6 T1 hits in `FrameConditions/Soundness.lean` (:63,:78,:94,:113,:124,:136) |
| `docBlame` | **2** | 6 | see §6 |

---

## 5. Naming: the task's premise is wrong, and the real problem is much larger

The task names `bfmcs` and `drm` as the naming violations. Both are misdiagnoses:

- **`drm` / `DRM`**: zero occurrences outside `Boneyard/`. It is already dead code. Nothing to do.
- **`BFMCS` / `bfmcs`**: 209 occurrences across 22 files, 41 declaration names — **all inside
  `Metalogic/` (T3)**, none in T1 and none in the T2 files (the single hit in
  `Syntax/SubformulaClosure/Closure.lean` is a comment). Renaming it does not touch the core
  porting scope at all. It is a self-contained T3 concern.

The actual naming violation Mathlib's linter reports is **`defsWithUnderscore`: 902 errors**, 189 of
them in T1 and 50 in T2. Message form:

```
Theories/Bimodal/Theorems/TemporalDerived.lean:771:1: error:
  Bimodal.Theorems.TemporalDerived.always_imp_all_future
  The definition `…always_imp_all_future` contains an underscore. This almost surely violates
  mathlib's naming convention; use lowerCamelCase or UpperCamelCase instead.
```

**Root cause, and why this is architectural rather than cosmetic.** `DerivationTree` is
`Type`-valued, not `Prop`-valued:

`Theories/Bimodal/ProofSystem/Derivation.lean:85`
```lean
inductive DerivationTree (fc : FrameClass) : Context → Formula → Type where
```

So every derived theorem in `Theorems/` is necessarily a `def` returning data, e.g.
`Theorems/Perpetuity/Bridge.lean:61`:
```lean
def dne (A : Formula) : ⊢ A.neg.neg.imp A :=
```
Mathlib's convention is snake_case for `theorem`, lowerCamelCase for `def`. Because these are
`def`s, the linter demands `alwaysImpAllFuture`, `boxDisjIntro`, etc. — which reads as gibberish for
a theorem library. `Derivable` *is* a `Prop` (`ProofSystem/Derivable.lean:62`), so a
`Prop`-valued re-statement layer is conceivable, but that is a library redesign, not linter
compliance.

There are three mutually exclusive options and the choice is the user's, not the planner's:

1. **Rename 239 T1+T2 declarations to lowerCamelCase.** Breaking API change; the blast radius is
   every call site across 429 `.lean` files plus `Tests/`. Destroys the readability of a proof
   library.
2. **`@[nolint defsWithUnderscore]` / `scripts/nolints.json`.** The linter's own documented escape
   hatch (`This linter can be disabled with @[nolint defsWithUnderscore]`), and what Mathlib does
   for its own exceptions. Cheap, reversible, honest. Whether cslib accepts it is a maintainer
   question.
3. **Convert the 39 `linter.defProp` cases to `theorem`** (3 in T1: `FrameConditions/FrameClass.lean:204`,
   `:212`, `FrameConditions/Soundness.lean`). These are genuine `Prop`-valued `def`s that *should*
   be theorems — fixing them is unambiguously correct and removes them from `defsWithUnderscore`
   automatically. This is a real subset of option 1 that is safe.

**Recommendation**: do option 3 (39 declarations, mechanically correct) in this task; put option 1
behind an explicit user decision as its own task; do not silently pick option 2.

I could not find a Mathlib linter for "opaque abbreviations" at all — no linter flags `dne`, `efq`,
`raa`, `mp`, `lce`, `ldi`, `rcp`, `rdi`, `rce`, `ni`, `lem`, `ecq` (all real declarations in
`Theorems/Propositional/Core.lean` and `Theorems/Combinators.lean`). Renaming those is a
human-taste judgment with no linter backing it, so it should not be sold as "linter compliance".
(A grep hit on `theorem foo` in `FrameConditions/Compatibility.lean:64` is a false positive — it is
inside a docstring code block, not a declaration.)

---

## 6. Docstrings: near-non-issue in scope

`docBlame` reports **99** project-wide but only **2 in T1**:

- `Syntax/SubformulaClosure/TemporalFormulas.lean:262` — `Bimodal.Syntax.deferralClosure`
- `Theorems/Propositional/Core.lean:61` — `Bimodal.Theorems.Propositional.efq_axiom`

and 6 in T2 (`Decidability/FMP/FMP.lean` ×2, `Decidability/Tableau.lean` ×1,
`WeakCanonical/Separation/Defs.lean` ×3). The remaining 91 are in T3 (52) and `Automation/` (39,
out of scope). The task item "missing docstrings on public declarations" is **8 declarations** of
work in the recommended scope. `linter.style.docString` adds 3 malformed-docstring errors in T1:
`Semantics/TaskFrame.lean:271`, `:293`, `Semantics/TaskModel.lean:86` (all "doc-strings should start
with a single space or newline").

**Stale docstring content is the real docstring problem, and no linter catches it.** Confirmed
instance, as flagged in the dispatch: `Theorems/ModalS5.lean:54-62` documents `classical_merge` as
blocked on a "Complex deduction theorem dependency … Marked as infrastructure gap" with a
"Workaround" paragraph, but `ModalS5.lean:64` is fully proven by
`exact Propositional.classical_merge P Q`. This needs a human read of every T1 docstring; it cannot
be automated and it should be budgeted as judgment work, not mechanical.

---

## 7. Universe polymorphism: no findings

The task lists "universe polymorphism issues" as category 3. **There are none.** No universe linter
exists in this toolchain (no `checkUnivs` in either Mathlib's or batteries' linter directories), and
the one universe-adjacent linter that does exist, `structureInType`, fires exactly once — in
`Automation/`, outside scope. `Semantics/` already uses `(D : Type*)` consistently
(`TaskFrame.lean:93`, `WorldHistory.lean:69`, `TaskModel.lean:43`).

The one substantive observation: `Semantics/Validity.lean:71` documents a deliberate
monomorphization — "Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs" — and
`def valid` at :73 quantifies over `∀ (D : Type)`. So `valid` is *not* universe-polymorphic, by
design and with a stated reason. Making it polymorphic is a semantics change with proof fallout, not
a linter fix. **Recommend dropping category 3 from the task** rather than manufacturing work.

---

## 8. Mechanical vs. judgment split

This is the part that should drive phase sizing.

### Genuinely mechanical (tool-assisted, verifiable by rebuild)

| Category | T1+T2 | Tool | Notes |
|---|---|---|---|
| `linter.style.longLine` | 257 | `.lake/packages/mathlib/scripts/fix_long_lines.py <path>:<line> …` | **Measured hit rate 7/11 = 64%** on `Syntax/SubformulaClosure/TemporalFormulas.lean`. Breaks at the last comma before col 100; lines with no comma need manual attention. Processes in reverse line order so offsets stay valid (`fix_long_lines.py:51`). Iterate to catch tails still >100. Caution: it will happily break inside a string literal. |
| `linter.style.emptyLine` | 508 | none shipped | Delete the blank line. These are visual separators between proof steps inside tactic blocks (e.g. `Theorems/ModalS5.lean:110,116,120` — blank lines between `have` steps that already carry `--` comments). Trivially scriptable but a 508-line deletion diff that measurably hurts proof readability. Worth flagging to the user before doing it. |
| `linter.unusedSimpArgs` | 223 | `scripts/fix_unused_simp_args.py` | Consumes `lake build 2>&1`. In T1 all 9 are one lemma: `Formula.swap_temporal_all_past` ×8 (`Perpetuity/Bridge.lean:191,604,706`; `Perpetuity/Principles.lean:402,669,746,812,848`) and `Formula.swap_temporal` ×1 (`GeneralizedNecessitation.lean:96`). **Corrects the dispatch's "~21 in Theorems/" to 9.** T2's 214 are dominated by `Metalogic/Soundness.lean` (162). |
| `linter.defProp` → `theorem` | 3 (T1) | none | `FrameConditions/FrameClass.lean:204`, `:212`; `FrameConditions/Soundness.lean`. |
| `linter.style.docString` | 3 (T1) | none | Whitespace at docstring boundaries. |
| `linter.style.whitespace` | 1 (T1) | none | `Semantics/TaskFrame.lean:284` "remove line break in the source". |

### Requires judgment (no tool, per-site reasoning, can break proofs)

| Category | T1+T2 | Why |
|---|---|---|
| `linter.flexible` | 78 | "`simp [h]` is a flexible tactic modifying `⊢`. Try `simp?` and use the suggested `simp only [...]`." Each site needs `simp?` run, the suggestion transcribed, and the proof re-verified. Non-mechanical and failure-prone. Concentrated: `ProofSystem/Axioms.lean` (9), `Decidability/Saturation.lean` (21), `Core/DeductionTheorem.lean` (12). |
| `defsWithUnderscore` | 239 | §5 — needs a user decision before any work. |
| Stale docstring content | unknown | §6 — requires reading every T1 docstring against its proof. |
| `simpNF` | 42 | 17 of T1's 18 are `LINTER FAILED`, meaning the linter crashed rather than reported — these need individual investigation, not a fix recipe. The one real hit is `ProofSystem/Derivable.lean:110` (`Derivable.ax` LHS does not simplify). |
| `unusedArguments` | 11 | Removing an argument is a signature change; blast radius per site. |
| `linter.unusedVariables` | 14 | `scripts/fix_unused.py` exists but is **stale**: its regex expects ``unused variable `x` `` while Lean v4.33 emits "Variable name \`x\` is not explicitly referenced." Do not assume it works. |

### Explicitly not this task

- **Copyright headers.** `linter.style.header` is in `mathlibStandardSet` but reports **zero** hits
  here. Mechanistic reason: `isInLibraryRoot` (`Mathlib/Tactic/Linter/Header.lean:259`) looks for
  `<Root>.lean` relative to cwd, i.e. `./Bimodal.lean`. Because `lakefile.lean` sets
  `srcDir := "Theories"`, the root lives at `Theories/Bimodal.lean` and the check returns false, so
  the linter silently no-ops. Headers are **task 292**'s job (which depends on 293). Worth telling
  292 that the linter will not verify its work until the srcDir mismatch is addressed.
- **Deprecation warnings (554).** All 553 in `Metalogic/` (T3) + 1 in `Automation/`; **zero in
  T1+T2**. 506 are `push_neg` → `push Not`, concentrated in
  `WeakCanonical/EFGames/GapDetection.lean` (201) and `WeakCanonical/Expressiveness/SplitPoint.lean`
  (65). These are fallout from the v4.31→v4.33 Mathlib bump, i.e. the toolchain-upgrade task's
  residue, not linter compliance. They do not touch the recommended scope.
- **T3 Metalogic** (5,297 style + 839 runLinter). Not sorry-free; out of the task's own predicate.

---

## 9. Recommended attack order

Sized so each phase is one agent run with a `lake build` gate at the end.

| Phase | Work | Volume | Risk |
|---|---|---|---|
| 1 | T1 `unusedSimpArgs` (9) + `defProp`→`theorem` (3) + `docString` (3) + `whitespace` (1) + 2 missing docstrings | 18 sites | very low |
| 2 | T1 `longLine` (89) via `fix_long_lines.py` + manual residue | 89 sites, 16 files | low |
| 3 | T1 `emptyLine` (489) — **gate on user confirmation first**, this is a readability tradeoff | 489 deletions, 10 files | low mechanically, high on reviewability |
| 4 | T1 stale-docstring audit, starting from the confirmed `ModalS5.lean:54-62` case | judgment | medium |
| 5 | T1 `flexible` (24) via `simp?` transcription | 24 sites, 5 files | medium — can break proofs |
| 6 | T2 mechanical: `Soundness.lean` (162 simpArg + 40 long), `DenseValidity.lean`, `Saturation.lean`, `CountermodelExtraction.lean` | ~450 sites | low |
| 7 | T2 remainder: `flexible` (54), `docBlame` (6), `unusedArguments` (5), `simpNF` (24) | ~90 sites | medium |
| — | `defsWithUnderscore` (239) | **blocked on user decision**, see §5 | breaking |
| — | T3 Metalogic, deprecations, headers | deferred to separate tasks | — |

Phases 1–2 and 6 are safely parallelizable by file (disjoint territory). Phase 3 should be one
commit so it can be reverted wholesale.

**Verification gate for every phase:**
```bash
lake build                                              # must stay at 0 errors, 1877 jobs
lake env lean -Dlinter.mathlibStandardSet=true <file>    # per touched file
lake exe runLinter Bimodal                              # for phases touching declarations
```

## 10. Open questions for the user

1. **`defsWithUnderscore` (239 in scope)**: rename to lowerCamelCase, suppress via nolint, or leave
   and document? This is a breaking API decision and the single largest item in the audit.
2. **`emptyLine` (489 in T1)**: accept deleting 489 proof-step separator blank lines?
3. Should T3 `Metalogic/` (166 files, 6,136 diagnostics, 12 sorries) be a separate task, as this
   report recommends, or is it expected inside 293?
