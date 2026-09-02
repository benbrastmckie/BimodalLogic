# Bundle Retirement and Core/Bundle Cycle Breaking — Research Report

**Task**: 520 (WAVE 1, deletion)
**Date**: 2026-09-02
**Tree state at measurement**: `f35c16401`, `FormalSystem/` clean (only `specs/` artifacts
modified by concurrent agents; task 519 works in `Metalogic/SoundnessLemmas/`, outside this
task's file scope)
**Gate pre-state**: `bash scripts/check-module-invariants.sh --no-build` → **ALL CHECKS PASSED**

---

## Executive Summary

Every structural claim in the task description was re-measured. The description is **directionally
correct but materially under-scoped**, and following its WORK list literally would **fail its own
acceptance criterion**.

Three headline findings:

1. **The dead set is 5 files / 2,214 lines, not 3 files / 611 lines.** Breaking the Core→Bundle
   edge removes `CanonicalTaskRelation.lean`'s *only* live importer, which orphans it (1,050
   lines); that in turn orphans `SuccRelation.lean` (553 lines), which in turn orphans
   `CanonicalFrame.lean`. The cascade is structural, not heuristic — it follows from the import
   graph alone.
2. **The block to extract is 29 declarations, not 24**, and it sits in *three* source ranges, not
   two (`iter_F_succ_eq` at `:560` is an F-side lemma stranded in the middle of the
   `CanonicalTask` machinery).
3. **`negBoxToBoxNegBox` is not a live shared helper.** It is declared twice; every live call site
   resolves to the `BXCanonical` copy in `Frame.lean:578`, verified by LSP hover. The fifth live
   helper the description was reaching for is `dneTheorem`, which it omits.

Additionally, `Theorems/ModalDerived.lean` **cannot host the two `SetMaximalConsistent.*` lemmas**
without widening the existing `Theorems ↔ Metalogic` top-level cycle; they belong in
`Metalogic/Core/`.

---

## 1. Verification of the Measured State

| Description claim | Measured | Verdict |
|---|---|---|
| `CanonicalFrame.lean` 312 lines, 11 declarations | 312 lines, **12** declarations | line count ✓, decl count off by one |
| `Construction.lean` 253 lines, 11 declarations | 253 lines, **10** declarations | line count ✓, decl count off by one |
| `UntilSinceCoherence.lean` 46 lines, declares nothing | 46 lines, 0 declarations | ✓ |
| `UntilSinceCoherence` forwards **two** imports | forwards **three** (`TemporalCoherence`, `SuccRelation`, `Theorems.TemporalDerived`) | ✗ — see §4 |
| `BXCanonical/Frame.lean:11` imports `CanonicalFrame`, references nothing from it | ✓ exactly | ✓ |
| `Frame.lean:223-244` re-proves as `bx_forward_witness`/`bx_backward_witness` | `:223` and `:235` | ✓ (ranges approximate) |
| `Bundle/README.md` lists three files that do not exist | `FMCS.lean:46`, `CanonicalIrreflexivity.lean:54`, `SuccExistence.lean:56` | ✓ — **and omits four that do** (§7) |
| `SuccRelation.lean:432-543` is 85 lines of proof diary | diary is **`:434`–`:541` = 108 lines**; `:432-433` are real code | ✗ range and count |
| diary cites `SuccExistence.lean` five times across three files | 5 citations: `SuccRelation.lean:32,444,455`; `TemporalContent.lean:40,76`; plus `Bundle/README.md:56` | ✓ |
| `ModalSaturation` imported by **nine route modules** | **4** live direct importers; **9** live *consumer* modules | ✗ — conflates import with use (§5) |
| the five helpers at `:262,:422,:502,:281,:511` | all five line numbers exact | line numbers ✓, membership ✗ (§5) |
| Core→Bundle edge exists only for four theorems at `:469,488,573,593` | `:469, :488, :573, :593` — exact | ✓ |
| `iterF/iterP/closureFBound/closurePBound` at `:74-194`, `:707-849` | ✓, **plus `:560`** | incomplete (§3) |
| **24** pure-syntax declarations | **29** | ✗ |
| `NestingDepth.lean:23,106` names them in docstrings | `:23, :83, :106, :167` (four mentions) | ✓ and then some |
| `Bundle.lean:12` duplicate import | `FMCSDef` imported at both `:11` and `:12` | ✓ exact |
| `Metalogic/README.md:115-119` records "touches 9 files" | ✓ at `:115-118` | ✓ |

### Additional discrepancies found

- **`Metalogic/README.md`'s Cycle 1 edge list is stale.** It records "BXCanonical → WeakCanonical
  (2 import lines)" and "WeakCanonical → BXCanonical (4 import lines)". Current tree: **9 and 6**.
  `Chronicle/ChronicleMonadicBridge.lean` alone contributes 6 forward edges the README never
  mentions.
- **`Metalogic/README.md:183`** records `Bundle/` as 15 files / **6,106** lines; actual **6,073**.
- **`CanonicalTaskRelation.lean:8` imports `CanonicalFrame` and uses nothing from it** — a second
  unused import, beyond the one the description names at `Frame.lean:11`.
- **`Construction.lean:20` advertises `constantBFMCS`**, which the file does not declare
  (`:71` is a `## REMOVED: constantBFMCS` tombstone and `:246` repeats the claim). Its `## History`
  heading at `:22` is empty.

---

## 2. Dead-Code Confirmation (Priority 2)

Method: import-graph reachability from the two Lake roots (`FormalSystem.FormalSystem`,
`Tests.BimodalTest`), plus per-declaration reference search across all 491 live `.lean` files
(`Boneyard/` excluded), with dot-notation suffix matching so that `B.TemporallyCoherent`-style
uses are not missed.

### The three files the task names — all confirmed dead

| File | Live cross-file consumers |
|---|---|
| `Construction.lean` | **0 of 10** declarations referenced anywhere live. Zero live importers today — it is already in `scripts/module-invariants-manifest.txt` for C6. |
| `UntilSinceCoherence.lean` | Declares nothing. Sole live importer `ChronicleToCountermodelBasic.lean:9`. |
| `CanonicalFrame.lean` | **1 of 12** declarations used: `ExistsTask`, by `SuccRelation.lean:97` inside `Succ_implies_CanonicalR` — which is itself referenced nowhere live, and whose body (`h.1`) is **identical to `Succ.g_persistence` at `SuccRelation.lean:78`**. `ExistsTaskPast` and `ExistsTask_past_def` have zero uses of any kind. |

**Recommendation on `ExistsTask`**: do **not** relocate it to `TemporalContent.lean`. Retire
`Succ_implies_CanonicalR` alongside `CanonicalFrame.lean` (it is a duplicate of
`Succ.g_persistence`) and drop `SuccRelation.lean:8`. This is strictly simpler than the
description's conditional and leaves no orphan alias behind.

### The saturation layer — confirmed dead

`needs_modal_witness`, `IsModallySaturated`, `is_modally_saturated_iff_no_needs_witness`,
`diamond_eq`, `diamond_excludes_box_neg`, `diamond_and_not_psi_implies_neg`,
`diamond_implies_psi_consistent`, `saturated_modal_backward`, `SaturatedBFMCS.modal_backward`:
**zero live cross-file references**, with one exception — `SaturatedBFMCS` (the structure at
`:377`) **is** referenced by `Metalogic/Algebraic/FlowFrame.lean`. Verify that consumer before
Boneyarding the structure; the rest of the layer is clean.

`dniTheorem` (`:238`) and `modal5CollapseTheorem` (`:404`): `dniTheorem` has **zero** references
anywhere, internal or external — it is dead. `modal5CollapseTheorem` is used only internally at
`:426`.

### The cascade the task does not account for

```
Core/RestrictedMCS/Basic.lean drops its Bundle import
   └─> CanonicalTaskRelation.lean  loses its ONLY live importer  → orphan (1,050 lines, 61 decls)
         └─> SuccRelation.lean     importers were {CanonicalTaskRelation, UntilSinceCoherence}
                                   → both gone → orphan (553 lines, 11 decls)
               └─> CanonicalFrame.lean  importers were {Frame.lean (unused), CanonicalTaskRelation,
                                        SuccRelation} → all gone → orphan (312 lines, 12 decls)
```

Confirmed independently of any regex: these are import-edge facts. After the 29 pure-syntax
declarations are extracted, **`CanonicalTaskRelation.lean`'s remaining 32 declarations have zero
live consumers** — the only surviving mentions are three docstring references
(`SuccRelation.lean:284`, `CanonicalFrame.lean:69-70`), and `CanonicalFrame.lean` is itself being
retired.

**Full fixpoint dead set:**

| File | Lines | Decls | Retired in round |
|---|---:|---:|---|
| `UntilSinceCoherence.lean` | 46 | 0 | 1 |
| `Construction.lean` | 253 | 10 | 1 |
| `CanonicalTaskRelation.lean` | 1,050 | 61 | 1 (post-extraction) |
| `SuccRelation.lean` | 553 | 11 | 2 |
| `CanonicalFrame.lean` | 312 | 12 | 3 |
| **Total** | **2,214** | **94** | |

**Survivors** (all with real live consumers): `BFMCS`, `FMCSDef`, `LimitMCS`, `LimitMCSCoherence`,
`ModalSaturation`, `RealExtension`, `RealExtensionBundle`, `TemporalCoherence`, `TemporalContent`,
`WitnessSeed`.

> **Scope decision required.** The acceptance criterion "Bundle/ has zero modules with no live
> consumer" is **unsatisfiable** under the description's literal WORK list, which retires 3 of the
> 5 dead files and explicitly instructs "point both Basic.lean and CanonicalTaskRelation.lean at
> [IteratedTemporal.lean] (3 Lean files, no renames)" — leaving a 1,050-line orphan. Either
> (a) extend the retirement to `CanonicalTaskRelation.lean` and `SuccRelation.lean`, or (b) relax
> the criterion and add both to `scripts/module-invariants-manifest.txt`. Recommendation: **(a)** —
> it is the same "retire the dead half" logic the task is built on, and (b) leaves 1,603 lines of
> compiled-but-unused code behind a manifest entry.

---

## 3. Import-Graph Surgery: Breaking the Core→Bundle Edge (Priority 3)

### What `IteratedTemporal.lean` must contain — 29 declarations, three ranges

| Range in `CanonicalTaskRelation.lean` | Declarations |
|---|---|
| `:59`–`:196` (section header through `iter_F_leaves_closure`) | `iterF`, `iter_F_zero`, `iter_F_succ`, `some_future_complexity`, `iter_F_complexity`, `iter_F_complexity_strictly_increasing`, `iter_F_injective`, `iter_F_one_eq_some_future`, `iter_F_f_nesting_depth`, `closureFBound`, `iter_F_exceeds_max_depth`, `iter_F_not_mem_closureWithNeg`, `iter_F_leaves_closure` (13) |
| `:557`–`:561` | `iter_F_succ_eq` (1) — **stranded between `CanonicalTask_converse` and `CanonicalTask_forward_MCS`; the description's ranges miss it** |
| `:699`–`:844` | `iterP`, `iter_P_zero`, `iter_P_succ`, `iter_P_some_past`, `iter_P_succ_eq`, `some_past_complexity`, `iter_P_complexity`, `iter_P_complexity_strictly_increasing`, `iter_P_injective`, `iter_P_one_eq_some_past`, `iter_P_p_nesting_depth`, `closurePBound`, `iter_P_exceeds_max_depth`, `iter_P_not_mem_closureWithNeg`, `iter_P_leaves_closure` (15) |

**Purity verified.** The extracted 289-line block contains **zero** occurrences of
`SetMaximalConsistent`, `MaximalConsistent`, `Succ`, `GContent`, `FContent`, `HContent`,
`PContent`, `FrameClass`, `Derivable`, `Consistent` or `Provable`. Its entire external surface is:

```
Formula.complexity, Formula.someFuture, Formula.somePast,
FormalSystem.Syntax.{closureWithNeg, fNestingDepth, pNestingDepth,
                     maxFDepthInClosure, maxPDepthInClosure,
                     f_depth_le_max, p_depth_le_max,
                     f_nesting_depth_some_future, p_nesting_depth_some_past}
```

All of these are declared in `Syntax/SubformulaClosure/Closure.lean` and
`Syntax/SubformulaClosure/NestingDepth.lean`. Therefore:

```lean
-- FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean
import FormalSystem.Syntax.SubformulaClosure.NestingDepth   -- sole import required
namespace FormalSystem.Syntax
```

This places the new module *below* `TemporalFormulas.lean` in the graph — no cycle risk in either
direction.

### What breaks if the 29 declarations move

- **Namespace change is load-bearing.** They currently live in `namespace
  FormalSystem.Metalogic.Bundle`; they move to `namespace FormalSystem.Syntax`.
  - `Core/RestrictedMCS/Basic.lean:51` already has `open FormalSystem.Syntax`, so unqualified
    references keep resolving. **`Basic.lean:459`'s `open FormalSystem.Metalogic.Bundle` must be
    deleted** — it exists solely for these names.
  - `CanonicalTaskRelation.lean:55` already has `open FormalSystem.Syntax`. (Moot if the file is
    retired.)
- **`Basic.lean` uses exactly 10 of the 29** — `closureFBound`, `closurePBound`, `iterF`, `iterP`,
  `iter_F_leaves_closure`, `iter_F_not_mem_closureWithNeg`, `iter_F_one_eq_some_future`,
  `iter_P_leaves_closure`, `iter_P_not_mem_closureWithNeg`, `iter_P_one_eq_some_past` — and
  **nothing else** from `CanonicalTaskRelation.lean`. The cut is clean.
- **One fully-qualified reference exists and will go stale**:
  `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:2990` calls
  `FormalSystem.Metalogic.Bundle.iter_F_f_nesting_depth`. Archived and uncompiled, and C11 checks
  only *imports*, not identifiers — so no gate fails. Worth a line in the Boneyard README.
- **Name-collision risk: checked and cleared.** `Tests/BimodalTest/TableauConformance.lean:201`
  declares its own `private def iterF` while doing `open FormalSystem.Syntax` at `:180`, and
  `FormalSystem.Syntax` *is* in that test's import closure. Lean 4 resolves the current-namespace
  declaration in preference to an `open`ed one without ambiguity — verified by running a minimal
  reproduction through `lean_run_code` (compiled clean, zero diagnostics). Safe either way.
- **`FormalSystem/Syntax.lean` must gain the import.** It enumerates all three
  `SubformulaClosure/` files explicitly; add `IteratedTemporal` for consistency. C8 only checks
  directories directly under `FormalSystem/` and `FormalSystem/Metalogic/`, so the aggregator-less
  `SubformulaClosure/` directory needs no sibling `SubformulaClosure.lean`.

### Resulting edit set

| File | Edit |
|---|---|
| `Syntax/SubformulaClosure/IteratedTemporal.lean` | **new**, 1 import, 29 declarations verbatim |
| `Syntax.lean` | +1 import line |
| `Core/RestrictedMCS/Basic.lean` | `:12` delete `import ...Bundle.CanonicalTaskRelation`; add `import ...SubformulaClosure.IteratedTemporal`; `:459` delete `open FormalSystem.Metalogic.Bundle` |
| `Bundle/CanonicalTaskRelation.lean` | delete the three ranges; add the import (or retire the file entirely — §2) |

---

## 4. `UntilSinceCoherence` Removal (Priority 3, cont.)

`ChronicleToCountermodelBasic.lean:9` is the sole live importer. Computed import-closure delta:
deleting that line loses exactly **one** substantive module, `Bundle.SuccRelation` —
`Bundle.TemporalCoherence` and `Theorems.TemporalDerived` are already reachable via
`ChronicleConstruction`/`CanonicalModel`.

`ChronicleToCountermodelBasic.lean` uses **nothing** from `SuccRelation`: the file's only match on
`Succ` is `:1139`, a docstring sentence about `Order.SuccPred` iteration, not `Bundle.Succ`.

**Therefore the description's instruction ("import TemporalCoherence and SuccRelation directly")
over-corrects on both counts** — `TemporalCoherence` is redundant, and `SuccRelation` is very
likely unnecessary too. Recommended sequence: delete line 9 outright and let `lake build` adjudicate;
if it reddens, add `import FormalSystem.Metalogic.Bundle.SuccRelation` as the minimal fallback.
Under the §2 recommendation (retiring `SuccRelation.lean`), deleting outright is the only option
consistent with the end state.

---

## 5. The `ModalSaturation` Consumers (Priority 4)

**"Nine route modules" is a consumer count, not an importer count.** There are **4** live direct
importers (`Bundle.TemporalCoherence`, `Bundle.Construction`, `BXCanonical.Chronicle.ChronicleTypes`,
plus the unreachable `Bundle.lean` aggregator). There are **9** live modules that *reference* a
helper, reaching it transitively.

### Exact consumer × helper matrix (verified)

| Consumer module | `dneTheorem` | `boxDneTheorem` | `SMC.contrapositive` | `axiom5NegIntro` | `SMC.neg_box_…` | Reference form |
|---|:-:|:-:|:-:|:-:|:-:|---|
| `Bundle/TemporalCoherence.lean` | ✔ `:68,84,108,126,138` | | | | | unqualified |
| `BXCanonical/CanonicalModel.lean` | | ✔ `:840` | ✔ `:839` | | | unqualified |
| `BXCanonical/CompletenessDedekind.lean` | | ✔ `:478` | ✔ `:477` | | | mixed |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | | ✔ `:1160` | ✔ `:1159` | | | fully qualified |
| `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | | ✔ `:588` | ✔ `:587` | | | fully qualified |
| `WeakCanonical/GroupModel/CountermodelBase.lean` | | ✔ `:299` | ✔ `:298` | | | fully qualified |
| `WeakCanonical/IntegerModel/ReynoldsBridge.lean` | | ✔ `:1119` | ✔ `:1118` | | | fully qualified |
| `BXCanonical/Chronicle/ChronicleTypes.lean` | | | | ✔ `:224` | | fully qualified |
| `BXCanonical/Chronicle/MCSMixedCase.lean` | | | | | ✔ `:58` | unqualified |

Nine distinct modules. **Seven references are written as
`FormalSystem.Metalogic.Bundle.<name>` and must be rewritten by hand**, not merely re-imported.

### Correction: the fifth helper is `dneTheorem`, not `negBoxToBoxNegBox`

`negBoxToBoxNegBox` is **declared twice** in the live tree:

- `Bundle/ModalSaturation.lean:502` — a one-line alias for `axiom5NegativeIntrospection`
- `BXCanonical/Frame.lean:578` — an independent proof from `modal_5_collapse`

Every live call site (`Frame.lean:627`, `CanonicalModel.lean:372`, `:751`) sits inside `namespace
FormalSystem.Metalogic.BXCanonical`, so the current-namespace declaration wins over the `open
FormalSystem.Metalogic.Bundle`. Confirmed by LSP hover at `CanonicalModel.lean:372:29`:

```
FormalSystem.Metalogic.BXCanonical.negBoxToBoxNegBox (φ : Formula) : ⊢ φ.box.neg.imp φ.box.neg.box
*import FormalSystem.Metalogic.BXCanonical.Frame*
```

**`Bundle.negBoxToBoxNegBox` has zero live cross-file consumers.** It still has to move, but as an
internal dependency of `SetMaximalConsistent.neg_box_implies_box_neg_box`, not as a public helper.

### Transitive closure of what must move

`boxDneTheorem` → `dneTheorem`; `axiom5NegativeIntrospection` → `modal5CollapseTheorem`;
`neg_box_implies_box_neg_box` → `negBoxToBoxNegBox` → `axiom5NegativeIntrospection`. So the move
set is **7** declarations, not 5: `dneTheorem`, `boxDneTheorem`, `modal5CollapseTheorem`,
`axiom5NegativeIntrospection`, `negBoxToBoxNegBox`, `SetMaximalConsistent.contrapositive`,
`SetMaximalConsistent.neg_box_implies_box_neg_box`. (`dniTheorem` is dead — Boneyard it rather
than move it.)

### Placement hazard: `Theorems/ModalDerived.lean` cannot hold the MCS lemmas

`Theorems/` already imports `Metalogic/` — four edges, all to `Metalogic.Core.DeductionTheorem`
(`Theorems/{GeneralizedNecessitation,DiscreteUnfolding,DedekindDerived,Propositional/Core}.lean`).
So `Theorems ↔ Metalogic` is *already* a top-level directory cycle. It is not inside `Metalogic/`,
so it does not violate this task's acceptance criterion — but widening it should be a deliberate
choice, not a side effect.

- The **derivation-tree helpers** (`dneTheorem`, `dniTheorem`, `boxDneTheorem`,
  `modal5CollapseTheorem`, `axiom5NegativeIntrospection`, `negBoxToBoxNegBox`, and the
  description's `gDneTheorem`, `hDneTheorem`, `pastTempA`) need only
  `Theorems.Propositional.Connectives` (`doubleNegation`, `contraposition`) plus `Syntax`/
  `ProofSystem`. **No `Metalogic` import.** Clean fit for `Theorems/ModalDerived.lean`.
- The **two `SetMaximalConsistent.*` lemmas** need `theorem_in_mcs`
  (`Core/MaximalConsistent.lean:491`) and `SetMaximalConsistent.implication_property`
  (`Core/MCSProperties.lean:157`). **Recommended home: `Metalogic/Core/MCSProperties.lean`**, not
  `Theorems/`.

Note also that unqualified `SetMaximalConsistent.contrapositive` call sites
(`CanonicalModel.lean:839`, `CompletenessDedekind.lean:477`) will need either a matching `open` or
requalification, since neither file currently opens the destination namespace. No call site uses
generalized field notation (`h.contrapositive`), so no dot-notation resolution is at risk.

`gDneTheorem`/`hDneTheorem` (`TemporalCoherence.lean:66,82`) and `pastTempA`
(`WitnessSeed.lean:567`) have **zero cross-file consumers** — they are file-local. Moving them is
consolidation, not de-duplication. Both host files already import `Theorems.*`, so adding
`import FormalSystem.Theorems.ModalDerived` introduces no new directory edge.

---

## 6. Cycle Accounting

Measured with aggregator modules excluded as sources (a sibling aggregator importing its own
directory is a convention artifact, not a design cycle):

| Cycle | Forward | Reverse | Status after this task |
|---|---:|---:|---|
| `Bundle ↔ Core` | 18 lines / 10 files | 1 line (`Core/RestrictedMCS/Basic.lean:12`) | **eliminated** |
| `BXCanonical ↔ WeakCanonical` | 9 lines | 6 lines | retained (the documented one) |
| `BXCanonical ↔ Metalogic(root)` | `BXCanonical/Completeness.lean → Metalogic.WeakCanonical` | `StrongCompleteness.lean → BXCanonical.CompletenessDedekind` | retained |

The third is an aggregator-mediated expression of the second; `Metalogic/README.md` already folds
it into "Cycle 1", so the README's own counting method yields **2 → 1**, consistent with the
acceptance criterion. **Recommendation**: the plan should commit the counting method to a small
checked-in script so "cycles = 1" is mechanically verifiable rather than argued.

Post-retirement, `Bundle → Core` drops from 18 lines / 10 files to **11 lines / 6 files**
(losing `CanonicalFrame`×2, `CanonicalTaskRelation`×1, `Construction`×3, `SuccRelation`×1).

`Metalogic/README.md` edits required: the ASCII diagram at `:50,54`, the stale Cycle 1 edge list at
`:74-91`, deletion of the Cycle 2 section at `:93-99`, the declined-regroup paragraph at
`:115-118`, the `Bundle.lean | 52` aggregator row at `:128`, and the `Bundle/ | 15 | 6,106`
inventory row at `:183`.

---

## 7. Documentation and Gate Obligations

### `Bundle/README.md`

- Architecture block `:44-60`: three phantom files (`FMCS.lean`, `CanonicalIrreflexivity.lean`,
  `SuccExistence.lean`) **and four missing real ones** (`LimitMCS.lean`, `LimitMCSCoherence.lean`,
  `RealExtension.lean`, `RealExtensionBundle.lean`).
- Main Theorems table `:66-68`: two of three rows point at retired files.
- **Usage blocks `:142-143` and `:151-153` are C5-load-bearing.** They contain module-shaped paths
  `FormalSystem.Metalogic.Bundle.Construction` and `...CanonicalFrame`. C5 asserts every
  module-shaped `FormalSystem.*` path in non-specs markdown resolves — **these become C5 failures
  the moment the files move.** Not cosmetic.
- `:18` and `:171` also reference retired material.

### Gate obligations

| Gate | Obligation |
|---|---|
| **C6 (phantom)** | `scripts/module-invariants-manifest.txt` lists `FormalSystem.Metalogic.Bundle.Construction`. C6 fails on manifest entries naming a nonexistent module — **this line must be deleted** in the same phase the file moves. If `CanonicalTaskRelation`/`SuccRelation` are kept instead of retired, they must be *added*. |
| **C11** | **12 archived import lines across 12 Boneyard files** must be repointed, or C11 fails: `BundleSuccessorSeed/SuccExistence.lean:9`, `ChainCompleteness/Algebraic/DeterministicFMCS.lean:6`, `ChainCompleteness/Bundle/TargetedChain.lean:2`, `ChainCompleteness/Completeness/SuccChainCompleteness.lean:2`, `DeadCanonicalModel/CanonicalIrreflexivity.lean:1`, `DefectDirectedChain/RootScopedChain.lean:3`, `QuasimodelOracle/OracleCoherence.lean:4`, `ScheduleBasedBFMCS/RootScopedChain.lean:2`, `SorriedDeclExcisions/BundleUntilSinceStep.lean:8`, `SorriedDeclExcisions/SingletonSorriedDecls.lean:6`, `StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean:2`, `StrictSemanticsLegacy/FrameConditions/Completeness.lean:5`. Retiring `CanonicalTaskRelation.lean` adds **4 more** (`RoundRobinChain/DRMChain`, `DeadCanonicalModel/CanonicalIrreflexivity`, `ChainCompleteness/Bundle/ResolvingChain`, `StrictSemanticsLegacy/Bundle/SuccChainFMCS`); retiring `SuccRelation.lean` adds **6 more**. The waiver file is explicitly *not* the escape hatch — "if there is [a unique target file], fix the import instead". |
| **C5** | `Bundle/README.md:142-143,151-153` (above). |
| **C2** | Baseline is four `BXCanonical` theorems, each `[propext, Classical.choice, Quot.sound]`. Relocation changes namespaces, not axiom sets. Safe **provided nothing is re-proved**. |
| **C8** | Unaffected — `SubformulaClosure/` is depth-2 and outside C8's scan. |
| **C3** | Unaffected — zero structural sorries today; nothing here introduces one. |
| `Boneyard/README.md` counts table | 156 files / 88,275 lines / 35 top-level dirs → **+3 files, +611 lines** (or **+5 / +2,214** under the §2 recommendation), **+1 subdirectory**. |

---

## 8. F-21 Docstring Defects — Verified

1. **`SuccRelation.lean:135-148`** (docstring of `neg_FF_implies_GG_neg_in_mcs`; description said
   `:131-143`) asserts `F(phi) = neg(G(neg(phi)))  [def someFuture]`. Directly contradicted by
   **`WitnessSeed.lean:50-53`** (description said `:47-49`): *"Since `someFuture`/`somePast` are no
   longer definitionally `neg(allFuture/allPast(neg _))`…"*.
2. **`Algebraic/UltrafilterMCS.lean:26`**: *"Contains sorries pending MCS helper lemmas."* The file
   has **zero** `sorry` occurrences and C3 asserts zero tree-wide. C14 passes because it scans
   numeric counts, not this phrasing — so the claim is genuinely ungated. **Scope conflict**: the
   task's WORK list names this file but `Metalogic/Algebraic/` is not in the stated file scope. The
   planner must decide whether to include it.
3. **`Construction.lean`**: empty `## History` heading at `:22`; `constantBFMCS` advertised at `:20`
   and `:246` but not declared; `## REMOVED:` tombstone at `:71`. All vanish with the relocation —
   worth one line in the Boneyard README instead of an in-place fix.
4. **"But wait" prose**: only one occurrence in scope, `CanonicalFrame.lean:264` — also vanishes
   with relocation. The other two (`Theorems/Propositional/Connectives.lean:471`,
   `WeakCanonical/EFGames/GapDetection.lean:4381`) are out of scope.
5. **`pastTempA` (`WitnessSeed.lean:567`)** — description is correct and understated. The body is
   `DerivationTree.axiom [] _ (Axiom.connect_past psi) trivial`, a direct axiom application, not a
   derivation; the docstring claims "Derived from temp_a via temporal duality". `temp_a` is **not**
   an `Axiom` constructor (`ProofSystem/Axioms.lean:174` has `connect_past`); it survives only as a
   tactic-facing string in `Automation/` and tests. The nonexistent name appears **three** times in
   `WitnessSeed.lean` (`:561`, `:565-566`, `:573`), not once.

### The `SuccRelation` diary

Deletable range is **`:434`–`:541` (108 lines)**, not `:432-543`. `:432-433` are legitimate step-6
code (`have h_phi_in_p_content_v : phi ∈ PContent v := h_P`); the real conclusion is `:542-550`.
The diary contains three first-person deliberation markers ("Hmm, this may need additional
infrastructure. Let me check." at `:465`; "Let me try a different approach" at `:461`; "Let's use a
semantic argument" at `:484`) and repeatedly defers to `SuccExistence.lean`, which exists only at
`Boneyard/BundleSuccessorSeed/SuccExistence.lean`.

Replacement note should state: `h_p_step` is a **hypothesis** because `Succ` supplies the F-step
(`FContent u ⊆ v ∪ FContent v`) but not its P-dual; callers that construct predecessors discharge
it. — **Moot if `SuccRelation.lean` is retired per §2**; the planner should sequence this item
*after* the retirement decision to avoid editing a file that is about to move.

---

## 9. Recommended Phase Ordering (Priority 5)

Each phase leaves the tree green and independently buildable.

**Phase 1 — Cycle break (self-contained, highest value).**
Create `Syntax/SubformulaClosure/IteratedTemporal.lean` with the 29 declarations; add it to
`Syntax.lean`; repoint `Core/RestrictedMCS/Basic.lean` (`:12` import swap, `:459` `open` deletion);
add the import to `CanonicalTaskRelation.lean` and delete the three ranges.
*Green check*: `lake build` + `check-module-invariants.sh`. Cycle count 2 → 1.
*Note*: this phase alone makes `CanonicalTaskRelation` unreachable — C6 will demand either a
manifest entry (temporary) or Phase 3. Add the manifest entry here and remove it in Phase 3.

**Phase 2 — `ModalDerived` extraction and re-pointing.**
Create `Theorems/ModalDerived.lean` (7 derivation-tree helpers incl. `gDneTheorem`, `hDneTheorem`,
`pastTempA`); move the two `SetMaximalConsistent.*` lemmas to `Metalogic/Core/MCSProperties.lean`;
add `Theorems.lean` import; re-point the 9 consumers, rewriting the 7 fully-qualified references;
add `open` or requalify at `CanonicalModel.lean:839` / `CompletenessDedekind.lean:477`; fix the
`pastTempA` docstring and the two other `temp_a` mentions.
*Green check*: `lake build` + C2 (axiom sets must be byte-identical).

**Phase 3 — Retirement.**
Move `CanonicalFrame.lean`, `Construction.lean`, `UntilSinceCoherence.lean` — **and, per §2,
`CanonicalTaskRelation.lean` and `SuccRelation.lean`** — to a new `Boneyard/<name>/` with a README;
Boneyard the saturation layer (verify `SaturatedBFMCS`'s `FlowFrame.lean` consumer first); delete
`ChronicleToCountermodelBasic.lean:9`; delete `Frame.lean:11`; delete `Bundle.lean:12` plus the
retired imports; delete the `Construction` line from `module-invariants-manifest.txt` and the
Phase-1 temporary entry; **repoint all 12 (or 22) Boneyard import lines**.
*Green check*: `lake build` + full gate, C11 and C6 especially.

**Phase 4 — Documentation coherence.**
Regenerate `Bundle/README.md` (architecture block, Main Theorems table, C5-bearing usage blocks);
correct `Metalogic/README.md` (diagram, stale Cycle 1 edge list, delete Cycle 2, aggregator row,
inventory row); update `Boneyard/README.md` counts; fix `SuccRelation`'s F-21 docstring (if the
file survives) and the `UltrafilterMCS.lean:26` claim (if in scope); delete the diary (if the file
survives).
*Green check*: full gate, C5/C12/C13/C14.

**Ordering rationale**: Phase 1 before Phase 3 because the retirement's justification *depends* on
the cycle break having orphaned the files. Phase 2 is independent of both and could run in
parallel, but is sequenced second so Phase 3 sees a settled `ModalSaturation`. Phase 4 last because
every earlier phase changes the numbers it documents.

---

## 10. Open Decisions for the Planner

1. **Scope of retirement** — 3 files (description) vs. 5 files (measurement). The acceptance
   criterion requires 5. **Recommend 5.**
2. **`UltrafilterMCS.lean:26`** — named in WORK, outside the stated file scope. Recommend
   including it; it is a one-line docstring fix.
3. **`SetMaximalConsistent.*` placement** — `Theorems/ModalDerived.lean` (widens the existing
   `Theorems ↔ Metalogic` edge) vs. `Metalogic/Core/MCSProperties.lean`. **Recommend Core.**
4. **`dniTheorem`** — fully dead. Boneyard rather than move.
5. **Cycle-count verification** — commit a script so the acceptance criterion is mechanical.
6. **`ChronicleToCountermodelBasic.lean:9`** — delete outright (recommended) vs. replace with a
   `SuccRelation` import. Incompatible with retiring `SuccRelation.lean`; resolve with decision 1.

---

## Appendix: Verification Methods

- Import graph: 2,248 edges extracted from all 592 `.lean` files; reachability from Lake roots
  `FormalSystem.FormalSystem` and `Tests.BimodalTest`.
- Declaration liveness: regex declaration extraction + comment-stripped reference search across
  491 live files, with dot-notation suffix matching (the naive form falsely reported
  `TemporalCoherence.lean` dead; corrected).
- Name resolution: `lean_hover_info` at `CanonicalModel.lean:372:29` (settled the
  `negBoxToBoxNegBox` duplication); `lean_run_code` minimal reproduction (settled the
  `TableauConformance` shadowing question).
- Gate pre-state: `check-module-invariants.sh --no-build` — ALL CHECKS PASSED. Baselines recorded:
  C4 1,504 import lines; C7 491 live files (474 reachable, 17 unreachable); C11 497 archived import
  lines across 156 files (7 waived).
- No build was started and no source file was modified during this research.
