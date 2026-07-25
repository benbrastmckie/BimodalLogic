# Research Report: Lean Toolchain Upgrade (v4.27 -> cslib pin) and Mathlib Update

**Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
**Task type**: lean4
**Date**: 2026-07-24
**Session**: sess_1784959849_77d9d9

---

## Executive Summary

1. **The task title is stale.** cslib is no longer on Lean 4.31. Upstream `leanprover/cslib`
   `main` pinned `leanprover/lean4:v4.33.0-rc1` on 2026-07-16 (PR #723), having passed through
   4.31.0 (2026-06-15) and 4.32.0 (2026-07-13). Targeting v4.31.0 would land BimodalLogic two
   minor releases behind cslib and would not unblock porting.
2. **All 59 Mathlib module paths this repo imports still exist at Mathlib `v4.33.0-rc1`** —
   verified by diffing the repo's import set against Mathlib's own `Mathlib.lean` index at that
   tag. **Zero import-path breakage.** This is the single most reassuring finding.
3. **The real risk is not lemma renames — it is definitional-equality and transparency
   semantics.** Lean 4.29 and 4.31 each shipped changes the Lean team themselves label
   "very disruptive" to `isDefEq` transparency handling. This repo is unusually exposed:
   88 files already run at elevated `maxHeartbeats` (up to 64x default), ~1,546 `decide` sites,
   398 `simpa` sites, and hand-written `MetaM` tactics that call `isDefEq` directly.
4. **`skill-lean-version` must not be used for this upgrade.** It requires `AskUserQuestion`
   (unavailable under `orchestrator_mode: true`), its backup step does not actually back up
   `lake-manifest.json` despite its own documentation claiming so, and git provides strictly
   better rollback here. Details in §7.
5. **No blockers.** The upgrade is feasible. It is, however, substantially larger than the
   task description's "~50–200 lines of fixes" estimate implies — see §6 for why.

---

## 1. Exact Current Pin

Verified by direct file read.

| Artifact | Value | Source |
|---|---|---|
| Toolchain | `leanprover/lean4:v4.27.0-rc1` | `lean-toolchain` (single line, no trailing newline) |
| Mathlib inputRev | `v4.27.0-rc1` | `lakefile.lean:8-9` |
| Mathlib resolved rev | `32d24245c7a12ded17325299fd41d412022cd3fe` | `lake-manifest.json` |
| plausible inputRev | `main` | `lakefile.lean:11-12` (direct require, `inherited: false`) |
| plausible resolved rev | `b3dd6c3ebc0a71685e86bea9223be39ea4c299fb` | `lake-manifest.json` |
| Active toolchain | v4.27.0-rc1 (overridden by `lean-toolchain`) | `elan show` |

Transitive (mathlib-inherited) packages in the manifest: LeanSearchClient, importGraph,
proofwidgets (`v0.0.84`), aesop, Qq, batteries, Cli (`v4.27.0-rc1`).

Build config (`lakefile.lean`): package `Logos`, `testDriver := "BimodalTest"`, two
`lean_lib`s (`Bimodal` rooted at `Theories/Bimodal.lean`, `BimodalTest` rooted at
`Tests/BimodalTest.lean`), and **13 `lean_exe` targets** all rooted in
`Theories/Bimodal/Automation/` with `supportInterpreter := true`. The executables matter: they
are the most `do`-notation-heavy, `IO`-heavy code in the repo and are exactly what Lean 4.29 and
4.32 changed (§5).

---

## 2. Correct Target Pin (Verified, Not Assumed)

### cslib's actual toolchain

`https://raw.githubusercontent.com/leanprover/cslib/main/lean-toolchain` returns verbatim:

```
leanprover/lean4:v4.33.0-rc1
```

Commit history for that file (GitHub API, `path=lean-toolchain`):

| Date | Commit subject |
|---|---|
| 2026-07-16 | chore: bump toolchain to v4.33.0-rc1 (#723) |
| 2026-07-13 | chore: bump toolchain to v4.32.0 (#717) |
| 2026-06-19 | chore: bump toolchain to v4.32.0-rc1 (#664) |
| 2026-06-15 | chore: bump toolchain to v4.31.0 (#651) |
| 2026-06-08 | chore: bump toolchain to v4.31.0-rc2 (#623) |
| 2026-05-29 | chore: bump toolchain to v4.31.0-rc1 (#609) |

cslib bumps roughly monthly and tracks release candidates aggressively. **Matching cslib exactly
is a moving target**; any pin chosen here will be behind cslib within ~4 weeks.

### cslib's Mathlib pin

cslib's `lakefile.toml` requires mathlib by **commit rev**, not tag:
`rev = "169c26b52a38b704fad2c009372d76844a059bdf"`. That commit's `lean-toolchain` is
`leanprover/lean4:v4.33.0-rc1`, confirming internal consistency.

### Mathlib releases that exist

From the mathlib4 tags API, relevant tags confirmed present:
`v4.33.0-rc1`, `v4.32.1`, `v4.32.0`, `v4.31.0`, `v4.31.0-rc2`, `v4.31.0-rc1`, `v4.30.0`,
`v4.29.1`, `v4.29.0`, `v4.28.1`, `v4.28.0`, `v4.27.0` (and our current `v4.27.0-rc1`).

So all three candidate targets have a matching Mathlib tag.

### Recommendation

**Target `leanprover/lean4:v4.33.0-rc1` with Mathlib tag `v4.33.0-rc1`.**

Concrete strings to write:

- `lean-toolchain` (whole file, no trailing newline to match current style):
  ```
  leanprover/lean4:v4.33.0-rc1
  ```
- `lakefile.lean:8-9`:
  ```lean
  require mathlib from git
    "https://github.com/leanprover-community/mathlib4.git" @ "v4.33.0-rc1"
  ```

Rationale and the alternative:

| Option | Pro | Con |
|---|---|---|
| **v4.33.0-rc1** (recommended) | Byte-identical toolchain to cslib HEAD; porting tasks compile against the same elaborator; Mathlib tag `v4.33.0-rc1` exists and is a supported release artifact | It is a release candidate; toolchain not yet installed locally (elan will fetch); reference release notes for 4.33 are thin |
| v4.32.1 | Latest *stable* Lean; Mathlib tag `v4.32.1` exists; toolchain v4.32.0 already installed locally | One minor behind cslib. Porting tasks would still hit a version skew, only smaller. Does not fully satisfy "same pin as cslib" |
| v4.31.0 (task's literal text) | Toolchain already installed locally | **Rejected.** Three releases behind cslib. Does not unblock porting, which is this task's entire purpose |

Using Mathlib's **tag** `v4.33.0-rc1` rather than cslib's raw commit rev `169c26b5…` is
deliberate: tags have `lake exe cache get` coverage and are stable references. cslib's rev is a
master commit that happens to sit on the same toolchain; there is no compatibility reason to
match it exactly.

### plausible: remove the direct require

`lakefile.lean:11-12` requires plausible directly at `@ "main"`. **Mathlib already requires
plausible** — confirmed in Mathlib's own `lake-manifest.json` at `v4.33.0-rc1`, where plausible
resolves to `b1c4a69a7e247ab7df20460212001673d74f08c0`. Our direct require at a floating `main`
lets `lake update` pull a plausible HEAD *newer* than the one Mathlib was built against, which
is a classic source of "works locally, breaks in CI" manifest skew.

Recommended: **delete the direct `require plausible` block** and let it be inherited from
Mathlib. `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean:3` (`import Plausible`) continues to
work because inherited packages are importable. If for some reason the direct require must be
kept, pin it to Mathlib's rev rather than `main`.

This is not speculative churn: `FormulaPropertyTest.lean` already carries ~18 quarantined test
blocks with the comment *"Plausible now requires `NamedBinder` decoration"* (lines 45, 67, 86,
105, 126, 145, 166, 185, 206, 223, 244, 262, 285, 304, 323, 347, 369). This repo has already
been bitten once by a floating plausible.

---

## 3. Verified: Zero Mathlib Import-Path Breakage

Method: extracted every distinct `import Mathlib.*` line across `Theories/` and `Tests/`
(59 unique modules), downloaded `Mathlib.lean` from mathlib4 at tag `v4.33.0-rc1` (8,274 lines,
8,268 module entries), and computed the set difference.

**Result: empty. All 59 modules exist at v4.33.0-rc1.**

This includes the ones most likely to have moved during Mathlib's 2025–2026 file-splitting work:
`Mathlib.Data.Finset.Basic`, `Mathlib.Data.Finset.Max`, `Mathlib.Data.Finset.Union`,
`Mathlib.Data.Finset.Lattice.Fold`, `Mathlib.Order.SuccPred.LinearLocallyFinite`,
`Mathlib.Order.BooleanAlgebra.Defs`, `Mathlib.Order.Preorder.Chain`,
`Mathlib.Data.Fintype.Pigeonhole`, `Mathlib.Data.Fintype.EquivFin`,
`Mathlib.Topology.Instances.Real.Lemmas`. The repo's imports are already
post-split — no `import Mathlib.Data.Finset.Basic`-catches-everything assumptions remain.

Spot-check of a specific API this repo depends on structurally: `SuccOrder.ofSuccLeIff`
(used at `ChronicleToCountermodelBasic.lean:924`) still exists in current Mathlib with an
unchanged signature `(succ : α → α) (hsucc_le_iff : ∀ {a b : α}, succ a ≤ b ↔ a < b) : SuccOrder α`,
still in `Mathlib.Order.SuccPred.Basic` (verified via loogle).

### Non-issue: the module system

Mathlib migrated to Lean's module system (`module` header + `public import`) **before** our
current pin. Confirmed by first-line inspection of `Mathlib.lean` at each tag:

| Mathlib tag | First line | `public import` count |
|---|---|---|
| v4.27.0-rc1 (current) | `module` | 7,380 |
| v4.28.0 | `module  -- shake: keep-all` | 7,650 |
| v4.30.0 | `module  -- shake: keep-all` | 8,096 |
| v4.31.0 | `module  -- shake: keep-all --deprecated_module: ignore` | 8,171 |
| v4.33.0-rc1 | same as above | 8,268 |

Our own files use **no** module-system syntax (zero files contain `module` / `public import` /
`@[expose]`). Legacy non-module files importing module-based Mathlib is the status quo that
already works at 4.27, and it continues to work at 4.33. **This upgrade does not cross the
module-system boundary.** I flag this explicitly because it is the obvious thing to fear and it
turns out to be a false alarm.

---

## 4. Repo Surface Inventory (baseline for scoping)

| Metric | Value | Method |
|---|---|---|
| `.lean` files (Theories + Tests) | 472 | `find` |
| Total lines | 278,093 | `wc -l` |
| Non-Boneyard Theories files / lines | 279 / 182,752 | `find -not -path '*Boneyard*'` |
| Boneyard files / lines | 89 / 56,173 | `find Theories/Bimodal/Boneyard` |
| Boneyard files actually in the build graph | 46 of 89 | `find .lake/build -path '*Boneyard*' -name '*.olean'` |
| Built oleans | 464 | `.lake/build` |
| `.lake/` on disk | 5.7 GB (mathlib 2.2 GB, build 2.5 GB) | `du -sh` |
| Free disk | 63 GB of 457 GB (86% used) | `df -h` |

Roughly half of `Boneyard/` is reachable from the root target and will be rebuilt and must
compile. It cannot simply be ignored.

**Baseline `sorry` count**: a text grep is unreliable here (the repo discusses `sorry` heavily in
docstrings; naive grep returns 764 hits, ~260 outside Boneyard). The implementer **must** capture
the authoritative baseline from `lake build` warning output *before* touching the toolchain, and
diff against it afterwards. Do not use grep for the gate.

---

## 5. Predicted Breakage, Grounded in This Repo

Upgrading 4.27 -> 4.33 crosses **six** minor releases (4.28, 4.29, 4.30, 4.31, 4.32, 4.33).
Below, each item is a documented upstream change paired with the concrete site(s) in this repo
that it lands on.

### 5.1 HIGH — `isDefEq` transparency semantics (Lean 4.29, compounded by 4.31)

Upstream (v4.29.0 release notes): *"The `isDefEq` algorithm no longer bumps transparency to
`.default` when comparing implicit arguments."* The notes call this **"a very disruptive
change."** Escape hatch: `set_option backward.isDefEq.respectTransparency false`.

Upstream (v4.31.0 release notes): definitional equality *"now strictly respects transparency
levels"*; plain `def` unfolds at `.default` but **not** at `.reducible` (which is what
`simp`/`dsimp` use). Escape hatches: `@[reducible]` on the constant,
`set_option backward.defeqAttrib.useBackward true in`, or `simpa using` -> `simpa using!`.

Why this repo is unusually exposed:

- **Hand-written tactics call `isDefEq` directly**:
  - `Theories/Bimodal/Automation/Tactics/Helpers.lean:162` — `if ← isDefEq decl.type goalType`
    (the `assumption_search` tactic, iterating the local context)
  - `Theories/Bimodal/Automation/Tactics/Helpers.lean:416` — `isDefEq innerFormula innerFormula2`
    (`modal_4_tactic`)
  - `Theories/Bimodal/Automation/Tactics/Helpers.lean:467` — `isDefEq lhs diamondPart`
    (`modal_b_tactic`)
- **Proofs rely on definitional equality of Mathlib-derived instances**:
  `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:989` and
  `:1000` state that `@Order.succ`/`@Order.pred` under a `letI`-registered instance are
  *definitionally* equal to the local `limitDomSubtype_succ`/`_pred`. The docstring at `:983`
  explicitly justifies this by how `SuccOrder.ofSuccLeIff` unfolds. This is exactly the pattern
  the 4.31 change targets.
- **107 `abbrev` declarations but only 1 `@[reducible]`** — the codebase leans on `abbrev` for
  reducibility. `abbrev` is still reducible, so this is mostly fine, but any place relying on a
  plain `def` unfolding inside `simp`/`dsimp` will now fail.
- **398 `simpa` sites** — the documented migration for a subset of these is `simpa using!`.
- **18 `inferInstanceAs` sites** — Lean 4.30 made `inferInstanceAs` require an *exact* expected
  type match and removed its use as an `inferInstance` synonym.

Mathlib ships migration tooling for precisely this: `scripts/add_set_option.py` (bulk-wraps
failing declarations in the backward-compat option), `scripts/rm_set_option.py` (finds
workarounds that are no longer needed), and the `#defeq_abuse` command. **The implementation plan
should budget for using these**, and should treat leftover `backward.*` options as technical debt
to be removed in a follow-up sweep, not as the finished state.

### 5.2 HIGH — elaboration cost increase vs. already-exhausted heartbeat budgets

The v4.31.0 notes state that level-metavariable index recording caused *"Tests required 20–50%
`maxHeartbeats` increases."*

This repo is already running near the ceiling. Current `set_option maxHeartbeats` inventory
(88 sites; Lean default is 200,000):

| Value | Sites | Multiple of default |
|---|---|---|
| 1,600,000 | 29 | 8x |
| 3,200,000 | 21 | 16x |
| 800,000 | 19 | 4x |
| 400,000 | 12 | 2x |
| 1,200,000 | 3 | 6x |
| 2,000,000 | 1 | 10x |
| 4,000,000 | 1 | 20x |
| 8,000,000 | 1 | 40x |
| 12,800,000 | 1 | 64x |

A 20–50% cost increase against files already at 16–64x default is a realistic source of
`(deterministic) timeout` failures — and unlike a rename, these fail slowly and expensively.
Heaviest files (most at risk):
`Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (12,800 lines),
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` (6,147),
`Metalogic/WeakCanonical/EFGames/GapDetection.lean` (5,056),
`Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` (4,693).

Note also the 4.31 app-elaborator change (arguments are now beta-reduced during substitution),
which makes previously-necessary `dsimp only` steps **useless** — 33 `dsimp only` sites may
start erroring with "dsimp made no progress".

### 5.3 MEDIUM-HIGH — `do` elaborator becomes the default (Lean 4.32), nested-action `return`

Upstream (v4.32.0, #13305): the new `do` elaborator is now default. `do` requires a `Pure`
instance, not just `Bind`; `do match` arms are **non-dependent by default**
(`do match (dependent := true)` restores old behavior); `try`/`catch` no longer accepts bodies
whose result type matches only via coercion; `let pat := rhs | otherwise` now scopes over the
following `doSeq`; unreachable code warns instead of erroring.

Upstream (v4.32.0, #13912) — **the dangerous one**: `return e` inside `(← do …)` or
`(← try … catch …)` now early-returns from the **enclosing** `do` block, not the nested one.
This is a **silent semantic change**, not a compile error. Migration: use `pure e`, or wrap as
`(← (do …))`.

Repo exposure: 13 `lean_exe` targets, all in `Automation/`, all `IO`-heavy. Counts: 241
`let mut` sites, 15 `catch` sites, 10 `try` sites. The `do`-heavy modules are
`Automation/DatasetGenerator.lean`, `Automation/TableauProofStepPipeline.lean`,
`Automation/FormulaEnumerator.lean`, `Automation/ForwardProofGenerator.lean`,
`Automation/BenchmarkOracle.lean`, `Automation/TableauBridge.lean`, and siblings.

**Because #13912 can change behavior without failing the build, `lake build` alone is not a
sufficient gate for the executables.** The plan must include running the dataset/benchmark
executables and comparing output against pre-upgrade output. This is the one place where a green
build could hide a real regression.

### 5.4 MEDIUM — `simp`/`dsimp` no longer process instances by default (Lean 4.29)

Upstream: instance processing is disabled by default; restore with `simp +instances` or
`set_option backward.dsimp.instances true`. Instance parameters are now detected by type rather
than binder syntax.

Repo exposure: this codebase is instance-dense — `SuccOrder`/`PredOrder`/`IsSuccArchimedean`/
`IsPredArchimedean` instance arguments appear in top-level statements at
`Metalogic/Soundness.lean:1341` and
`Metalogic/SoundnessLemmas/FrameClassVariants.lean:700`, and instances are registered via `letI`
in `ChronicleToCountermodelBasic.lean:923/976`. Expect `simp` calls that previously closed goals
by unfolding through an instance to stop doing so.

### 5.5 MEDIUM — `native_decide` axiom accounting changed (Lean 4.29)

Upstream: native computation (`native_decide`, `bv_decide`) now generates **one axiom per
computation** instead of using `Lean.trustCompiler`; `#print axioms` output changes accordingly.

This repo maintains a deliberate **axiom audit** and has been actively eliminating
`native_decide`:
- `Theories/Bimodal/Metalogic/Metalogic.lean:57` — describes swapping Syntax-layer
  `native_decide` sites to `rfl`/`decide`, referencing an "Axiom Audit"
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:386` and `:390` — records that 7
  in-cone sites were swapped and 4 remain in a named module
- Remaining live sites: `Metalogic/Decidability/SignedFormula.lean:126, 132, 133, 138`
  and `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:410`

**Any `#print axioms`-based audit assertions in this repo will report different axiom names
after the upgrade** and need updating. Also relevant: `PropDecide.lean:21` and `:80` assert the
tactic "never emits `native_decide`" — worth re-verifying post-upgrade rather than trusting the
comment.

### 5.6 MEDIUM — subgoal tag renaming (Lean 4.31)

Upstream: single remaining goals now inherit the input goal's tag after `apply`/`rewrite`;
assigned metavariables are filtered before computing subgoal tags. *"Scripts relying on previous
tag names (e.g. `case h => …` after `funext`) may need updating."*

Repo exposure: **173 `case` sites** and **240 `funext` sites**. The overlap is where this bites.
These fail loudly (unknown tag), so they are annoying rather than dangerous.

### 5.7 MEDIUM — noncomputable semantics tightened (Lean 4.29)

Upstream: more declarations now require explicit `noncomputable`; the new rule only ignores uses
in proofs, types, type formers, constructor parameters, and
`@[extern]`/`@[implemented_by]`/`@[csimp]` functions.

Repo exposure: 1,127 `noncomputable` occurrences already. The pattern is documented in
`Automation/Tactics/Deduction.lean` (the `deduction` tactic's docstring warns that `def`s closed
via it must be `noncomputable` because `deduction_theorem` is noncomputable). Expect **more**
sites to newly require the annotation. Low-effort fixes, potentially many of them.

### 5.8 LOW-MEDIUM — Lean 4.30 metaprogramming API renames

Upstream renames: `isStructureLike` -> `isNonRecStructure`, `matchConstStructLike` ->
`matchConstNonRecStructure`, `getStructureLikeCtor?` -> `getNonRecStructureCtor?`,
`getStructureLikeNumFields` -> `getNonRecStructureNumFields`; `compileDecl` now requires
`markMeta`; inductive constructors with typeless binders need explicit annotations
(`(x)` -> `(x : _)`).

Repo exposure: **zero hits** for `addAndCompile`, `compileDecl`, `isStructureLike`. The repo's
metaprogramming sticks to the stable surface — `getMainGoal`, `withContext`, `getLCtx`,
`instantiateMVars`, `mkAppM`, `mkConst`, `mkListLit`, `goal.assign`, `goal.apply`,
`replaceMainGoal`, `throwError` — across
`Automation/Tactics/{Helpers,PropDecide,Deduction,Commands}.lean`,
`Automation/{Normalization,EFGameTactics}.lean`. **This is lower risk than expected for a repo
with this much metaprogramming.**

### 5.9 LOW — Std.Range / `[a:b]` range syntax deprecation (Lean 4.28)

Upstream: `Std.Range` renamed to `Std.Legacy.Range`; migrate to `Std.Rco` and `a...b` notation
instead of `[a:b]`.

Repo exposure: **5 sites**, all mechanical:
- `Theories/Bimodal/Automation/Tactics/Deduction.lean:103` — `for _ in [0:count] do`
- `Theories/Bimodal/Automation/DatasetGenerator.lean:1722` — `for i in [:numChunks] do`
- `Theories/Bimodal/Automation/DatasetGenerator.lean:1740` — `for i in [:numChunks] do`
- `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:105` — `for _ in [:iterations] do`
- `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean:67` — `for _ in [:iterations] do`

Zero hits for `Std.Iterators`, `Subarray.`, `Lean.RBMap`, `Lean.RBTree` — so the 4.28 iterator
reorganization and the 4.32 RBMap deprecation do not touch this repo.

### 5.10 LOW — `Std.HashMap` / `Std.HashSet`

No breaking changes to these are documented in the 4.28–4.33 notes. Method surface actually used
across the repo is small and stable: `insert` (37), `contains` (8), `size` (5), `fold` (5),
`toList` (2), `isEmpty` (2), `toArray` (1), `getD` (1), `erase` (1). Main sites:
`Automation/ProofSearch/Core.lean:237,240`, `Metalogic/Decidability/Tableau.lean:989`,
`Automation/FormulaEnumerator.lean:110`, `Automation/AtomCanonicalization.lean:66-97`,
`Metalogic/Decidability/TraceCertificate.lean:123,240`. **Assessed low risk.**

### 5.11 LOW — Lean 4.33-specific

Documented changes: `TransparencyMode.instances` / `ReducibilityStatus.implicitReducible` split
(`@[implicit_reducible]` no longer grants type-class-search visibility); internal namespace moves
(e.g. `Int.Linear` -> `Int.Internal.Linear`); `bv_decide` now needs `@[ext]` on structures;
`mvcgen'` renamed to `vcgen`. Repo has zero hits for `@[implicit_reducible]`, `Int.Linear`,
`bv_decide`, `mvcgen`. **4.33-specific risk is negligible** — which is a point in favor of going
all the way to 4.33 rather than stopping at 4.32.

### 5.12 LOW — unused fragile import

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:4`
imports `Batteries.Tactic.OpenPrivate`, but neither `open_private` nor `export_private` appears
anywhere in the repo. `open_private` depends on internal Mathlib/Batteries name mangling and is a
classic upgrade landmine — but here it is simply an **unused import and should be deleted**.
(This also helps the separate linter-compliance work, which flags unused imports.)

### 5.13 Risk summary

| # | Area | Severity | Fails how | Repo sites |
|---|---|---|---|---|
| 5.1 | `isDefEq` transparency (4.29 + 4.31) | HIGH | Loud (defeq failure) | 3 direct `isDefEq`; 398 `simpa`; 18 `inferInstanceAs`; defeq-dependent `Order.succ` lemmas |
| 5.2 | Elaboration cost vs. heartbeats | HIGH | Slow + loud (timeout) | 88 `maxHeartbeats` sites, up to 64x default |
| 5.3 | `do` elaborator + nested `return` (4.32) | MED-HIGH | **Partly silent** | 13 `lean_exe`; 241 `let mut`; 15 `catch` |
| 5.4 | `simp`/`dsimp` instances off (4.29) | MEDIUM | Loud | Instance-dense Metalogic/ |
| 5.5 | `native_decide` axiom accounting (4.29) | MEDIUM | Loud (audit mismatch) | 5 live sites + axiom-audit prose |
| 5.6 | Subgoal tag renaming (4.31) | MEDIUM | Loud | 173 `case`, 240 `funext` |
| 5.7 | noncomputable tightening (4.29) | MEDIUM | Loud | 1,127 existing annotations |
| 5.8 | Meta API renames (4.30) | LOW-MED | Loud | 0 hits on renamed APIs |
| 5.9 | `[a:b]` range syntax (4.28) | LOW | Loud | 5 sites (listed above) |
| 5.10 | Std.HashMap/HashSet | LOW | — | 60 call sites, stable API |
| 5.11 | 4.33-specific | LOW | — | 0 hits |
| 5.12 | Unused `OpenPrivate` import | LOW | — | 1 site |

---

## 6. Why "~50–200 lines of fixes" Is Likely an Underestimate

The task description's estimate assumes the failure mode is renamed lemmas. It is not — §3 shows
zero import breakage and the spot-checked APIs are unchanged. The failure mode is **semantic**:
defeq/transparency (5.1), elaboration budget (5.2), and `simp` instance handling (5.4). Those
produce failures spread thinly across a 182k-line (non-Boneyard) proof corpus rather than
concentrated in a few files, and each one needs a judgement call (add `@[reducible]`? bump
heartbeats? restructure the proof? apply a `backward.*` option?).

A more honest framing for the planner: this is a **multi-phase, build-driven repair task** whose
size is unknown until the first full build under the new toolchain completes. The plan should
make "run the first build and produce a categorized error inventory" its own phase, and size
subsequent phases from that inventory rather than from a guess.

**Zero-debt note**: none of the above justifies introducing `sorry`. Every category here has a
structural fix (annotation, option, proof restructuring, or Mathlib's own migration scripts). If
a specific proof genuinely cannot be repaired under the new elaborator, the correct move is to
mark the task `[BLOCKED]` for user review — not to `sorry` the goal and defer.

---

## 7. Upgrade / Rollback Mechanics

### `skill-lean-version` — do not use it for this task

`.claude/skills/skill-lean-version/SKILL.md` (146 lines) provides `check` / `upgrade` /
`rollback` modes. Three reasons it is the wrong tool here:

1. **It cannot run autonomously.** Line 146: *"Upgrade mode requires explicit confirmation via
   AskUserQuestion."* This task runs with `orchestrator_mode: true`, where `AskUserQuestion`
   cannot prompt a human.
2. **Its backup is incomplete and contradicts its own documentation.** Line 138 claims
   *"Backup includes: `lean-toolchain`, `lakefile.lean`, `lake-manifest.json`"*, but the actual
   Create Backup snippet (lines 91-96) copies only `lean-toolchain` and `lakefile.lean`.
   `lake-manifest.json` — the file that records every resolved dependency rev, and the single
   most important thing to be able to restore — **is not backed up.** Trusting this skill's
   rollback would lose the exact dependency graph.
3. **Git is strictly better here.** The working tree is clean apart from an untracked
   `specs/events.jsonl`; HEAD is `e0158da5e`. `lean-toolchain`, `lakefile.lean`, and
   `lake-manifest.json` are all tracked. Rollback is `git checkout e0158da5e -- lean-toolchain
   lakefile.lean lake-manifest.json && lake exe cache get`.

The skill's `check` mode is harmless and its `sed` upgrade expression happens to be safe against
our `lakefile.lean` (only the mathlib require has a version-shaped rev; plausible's `main` will
not match). But there is no reason to route through it.

**Recommendation: perform the edits directly (Edit tool on `lean-toolchain` and
`lakefile.lean`), and rely on git for rollback.** Commit the pin change as its own commit before
starting repairs, so the repair diff is cleanly separable from the pin diff.

Optionally worth flagging to the user separately: `skill-lean-version`'s backup/documentation
mismatch is a real defect in the agent system and deserves its own meta task. It is out of scope
here.

### Environment readiness

`elan 4.2.1`. Installed toolchains: v4.14.0, v4.22.0, v4.26.0, **v4.27.0-rc1 (default)**,
v4.31.0, v4.31.0-rc1, v4.31.0-rc2, v4.32.0, v4.32.0-rc1.

**v4.33.0-rc1 is not installed.** elan will fetch it automatically on the first `lake` invocation
after `lean-toolchain` changes. Requires network. If offline, v4.32.0 is the best already-local
fallback.

Disk: 63 GB free. A second Mathlib cache is roughly 2–3 GB, plus a full rebuild of this project
(~2.5 GB of oleans). Sufficient, but the implementer should run
`lake clean` or remove the stale `.lake/build` rather than accumulating both.

### Command sequence

```bash
# 0. Baseline — capture BEFORE touching anything
git rev-parse HEAD
lake build 2>&1 | tee /tmp/baseline-build.log      # authoritative sorry/warning baseline
lake exe dataset_validator > /tmp/baseline-validator.txt   # executable-behavior baseline (see 5.3)

# 1. Change the pin (Edit tool, not sed)
#    lean-toolchain      -> leanprover/lean4:v4.33.0-rc1
#    lakefile.lean:8-9   -> mathlib @ "v4.33.0-rc1"
#    lakefile.lean:11-12 -> delete the direct `require plausible` block

# 2. Resolve dependencies and fetch prebuilt Mathlib
lake update           # rewrites lake-manifest.json; elan fetches v4.33.0-rc1 toolchain
lake exe cache get    # MUST succeed — otherwise Mathlib builds from source (hours)

# 3. First build — expect failures; this IS the error inventory
lake clean
lake build 2>&1 | tee /tmp/upgrade-build-01.log

# 4. Categorize failures against the taxonomy in section 5 before fixing anything

# 5. Gates
lake build                    # zero errors
lake test                     # testDriver := "BimodalTest"
lake exe dataset_validator    # diff against /tmp/baseline-validator.txt (see 5.3)
```

Rollback:

```bash
git checkout e0158da5e -- lean-toolchain lakefile.lean lake-manifest.json
lake clean && lake exe cache get && lake build
```

**Verify `lake exe cache get` succeeds before proceeding.** Building Mathlib from source at this
scale would dominate the task's entire time budget. If it fails, that is a hard stop worth
reporting rather than working around.

### Single jump vs. staged

Both are viable. The trade-off:

- **Single jump 4.27 -> 4.33** (recommended): one Mathlib download, one full rebuild, one error
  inventory. Downside: all six releases' breaking changes arrive at once and attributing a given
  error to a given release requires consulting the taxonomy in §5 — which is exactly what §5 is
  for.
- **Staged 4.27 -> 4.29 -> 4.31 -> 4.33**: errors are attributable to a specific release, and
  Mathlib's `add_set_option.py` / `rm_set_option.py` migration scripts are designed for the 4.29
  and 4.31 steps specifically. Downside: 3x the Mathlib downloads and 3x full rebuilds of a
  278k-line corpus — likely many hours of pure compute, plus 3x the disk churn.

Recommend the single jump, with staging held in reserve: if the first full build produces an
error inventory that is unmanageably large or where errors cannot be attributed to a cause, fall
back to staging. The planner should name that fallback explicitly as a decision point rather than
committing to one path blindly.

---

## 8. Blockers and Open Questions

**No hard blockers.** The upgrade can proceed.

Risks the planner should carry forward:

1. **Task title vs. reality.** The task says "v4.31 and Mathlib to the same pin as cslib"; those
   two clauses now contradict each other. This report resolves it in favor of cslib's actual pin
   (v4.33.0-rc1). If the user specifically wants 4.31 for a reason not stated in the task, that
   should be confirmed — but 4.31 does not achieve the task's stated purpose of unblocking
   porting.
2. **cslib will move again.** It has bumped roughly monthly. Whatever is pinned here will drift.
   The downstream porting tasks should not assume a permanently-matching pin, and it may be worth
   a follow-up task to establish a recurring pin-sync check rather than treating this as one-shot.
3. **Silent behavior change in executables (5.3, Lean #13912).** `lake build` will not catch it.
   The plan must include an executable-output diff, or the "no regressions" gate is not actually
   met.
4. **Axiom audit invalidation (5.5).** Any `#print axioms` assertions and the prose audit in
   `Metalogic/Metalogic.lean` / `BXCanonical/Completeness.lean` need re-verification.
5. **Unknown repair volume.** Genuinely not knowable before the first build. The plan should be
   structured to discover it rather than to assume it.
6. **Network dependency.** v4.33.0-rc1 toolchain and the Mathlib cache both require downloads.

---

## 9. Recommended Phase Decomposition (input to planning)

| Phase | Content | Gate |
|---|---|---|
| 1 | Capture baselines: `lake build` log, executable outputs, `git rev-parse HEAD` | Baseline artifacts exist and are non-empty |
| 2 | Edit `lean-toolchain` + `lakefile.lean` (mathlib tag, drop plausible require); `lake update`; `lake exe cache get` | Cache fetch succeeds; manifest shows mathlib `v4.33.0-rc1` |
| 3 | First full `lake build`; produce categorized error inventory against §5 taxonomy | Inventory written; **no fixes attempted yet** |
| 4..N | Repair, one §5 category at a time, sized from the phase-3 inventory | `lake build` error count strictly decreasing; zero new `sorry` |
| N+1 | `lake test`; executable-output diff vs. phase-1 baseline | Tests pass; executable output matches |
| N+2 | Remove any `backward.*` compatibility options added during repair that are no longer needed (Mathlib's `rm_set_option.py`) | `lake build` still green |

Phase 3 producing *only* an inventory is deliberate: sizing the repair before starting it is what
keeps phases bounded, and it is the only honest way to plan work whose volume is unknown.

---

## 10. Sources

All version facts verified during this research on 2026-07-24:

- `leanprover/cslib` `main` `lean-toolchain` (raw.githubusercontent.com) -> `v4.33.0-rc1`
- `leanprover/cslib` `main` `lakefile.toml` -> mathlib `rev = "169c26b52a38b704fad2c009372d76844a059bdf"`
- cslib `lean-toolchain` commit history (GitHub API, `path=lean-toolchain`, 15 entries)
- mathlib4 `lean-toolchain` at rev `169c26b5…` -> `v4.33.0-rc1` (confirms cslib self-consistency)
- mathlib4 tags API (30 most recent)
- mathlib4 `lake-manifest.json` at `v4.33.0-rc1` (plausible + 7 others)
- mathlib4 `Mathlib.lean` at tags `v4.27.0-rc1`, `v4.28.0`, `v4.29.0`, `v4.30.0`, `v4.31.0`,
  `v4.32.1`, `v4.33.0-rc1` (module-system status + full module index)
- Lean releases API (`leanprover/lean4`, 12 most recent) — v4.32.1 published 2026-07-22
- Lean language reference release notes: v4.28.0, v4.29.0, v4.30.0, v4.31.0, v4.32.0, v4.33.0
- loogle (`"ofSuccLeIff"`) — `SuccOrder.ofSuccLeIff` signature unchanged in current Mathlib
- Local: `elan show`, `lean --version`, `lake --version`, `df -h`, `du -sh .lake`,
  `git log`, `git status`, and greps over `Theories/` + `Tests/` as cited inline
