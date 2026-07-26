# Mathlib Naming-Convention Compliance — Decision Evidence

**Task**: 394 `resolve_mathlib_naming_convention_compliance`
**Session**: `sess_1785074764_351b3f_394`
**Date**: 2026-07-26
**Toolchain**: `leanprover/lean4:v4.33.0-rc1`, Mathlib tag `v4.33.0-rc1`
**Scope**: research-and-recommend. No file under `Theories/` or `Tests/` was mutated.
All empirical work ran in a scratch clone (`Theories`/`Tests`/`lakefile.lean` real-copied,
`.lake/build` real-copied, `.lake/packages` symlinked). A canary MD5 on a Mathlib olean was
identical before and after all clone builds; `git status` shows no change outside `specs/`.

---

## 0. Verified baselines (re-derived, not inherited)

| Fact | Measured | Note |
|---|---|---|
| `lake build` | **1874 jobs, exit 0** | matches corrected baseline |
| `lake build BimodalTest` | **1909 jobs, exit 0** | Tests build green |
| `lake build` warnings | **70** | 38 `defProp`, 2 `classDefReducibility`, 30 other |
| Live `sorry` | **1**, `Metalogic/WeakCanonical/Transfer.lean:1242` (`countermodel_discrete`) | located by content |
| `.lean` files | 432 under `Theories/` (278 non-Boneyard), 42 under `Tests/` | the "429 files" figure is stale |
| Built modules with `.ilean` | 300 (260 `Bimodal.*` + 40 `BimodalTest.*`) | Boneyard is unbuilt |

**`lake exe runLinter Bimodal` (fresh):**

```
  888  defsWithUnderscore
  122  unusedArguments
  115  LINTER FAILED
   39  docBlame
    4  tacticDocs
    1  structureInType
```

---

## 1. Re-derived counts and deltas against the task description

| Metric | Stated | **Measured** | Delta |
|---|---|---|---|
| `defsWithUnderscore` project-wide | 902 | **888** | **−14** |
| `defsWithUnderscore` in recommended porting scope | 239 | **208** | **−31** |
| &nbsp;&nbsp;— tier-1 (Syntax, Semantics, ProofSystem, Theorems, FrameConditions) | 189 | **189** | 0 |
| &nbsp;&nbsp;— tier-2 (Metalogic Core/Decidability/SoundnessLemmas) | 50 | **19** | **−31** |
| `linter.defProp` | 39 | **38** | **−1** |

The whole in-scope delta is tier-2. There is no `Metalogic/Completeness/` or
`Metalogic/Separation/` directory — `Completeness.lean`, `Decidability.lean` and `Soundness.lean`
are single files at the `Metalogic` root and contribute **0** flagged declarations. Tier-2 is
`Core` (9) + `Decidability` (9) + `SoundnessLemmas` (1) = 19.

**`ProofSystem/` contributes 0 flagged declarations** — the module that defines `DerivationTree`
is itself already conformant.

Project-wide distribution:

| Scope | flagged |
|---|---|
| `Metalogic/WeakCanonical` | 459 |
| `Theorems` | 135 |
| `Metalogic/BXCanonical` | 97 |
| `Automation` | 77 |
| `Metalogic/Bundle` | 34 |
| `Syntax` | 31 |
| `Semantics` | 17 |
| `Metalogic/Algebraic` | 13 |
| `Metalogic/Core` | 9 |
| `Metalogic/Decidability` | 9 |
| `FrameConditions` | 6 |
| `Metalogic/SoundnessLemmas` | 1 |

### 1a. The linter is invisible to the build and to CI

`defsWithUnderscore` is a **Batteries env-linter**, run only by `lake exe runLinter`. It emits
**nothing** during `lake build` (confirmed: 0 occurrences in the 615-line full build log). And
`.github/workflows/ci.yml` runs `leanprover/lean-action@v1` with `build: true, test: false,
lint: false`.

**Today, all 888 findings have zero effect on any green gate in this repository.** They matter
only for a prospective port into a downstream library that runs the env-linters.

---

## 2. The `defProp` subset — precise characterization and empirical safety proof

### 2.1 Why converting removes them from `defsWithUnderscore` automatically

`Mathlib/Tactic/Linter/Style.lean:557` gates on
`((← getEnv).find? declName).get!.isDefinition`. A `theorem` produces `ConstantInfo.thmInfo`,
for which `isDefinition` is `false`. Conversion therefore removes the declaration from the
linter's domain by construction, not by coincidence.

### 2.2 The exact list — 38 declarations

All are `def`s whose **type is a `Prop`** (verified independently with `Meta.isProp` over the
compiled environment, not by trusting the warning text).

| # | File | Line | Declaration | `noncomputable`? | in `defsWithUnderscore`? |
|---|---|---|---|---|---|
| 1 | `FrameConditions/FrameClass.lean` | 211 | `DenseTemporalFrame.mk'` | no | no (no underscore) |
| 2 | `FrameConditions/FrameClass.lean` | 219 | `DiscreteTemporalFrame.mk'` | no | no (no underscore) |
| 3 | `FrameConditions/Soundness.lean` | 52 | `soundness_over` | no | **yes** |
| 4 | `Metalogic/BXCanonical/Frame.lean` | 80 | `g_content_closed_derivation` | yes | **yes** |
| 5 | `Metalogic/BXCanonical/Frame.lean` | 104 | `h_content_closed_derivation` | yes | **yes** |
| 6 | `Metalogic/BXCanonical/Frame.lean` | 220 | `bx_forward_witness` | yes | **yes** |
| 7 | `Metalogic/BXCanonical/Frame.lean` | 232 | `bx_backward_witness` | yes | **yes** |
| 8 | `Metalogic/BXCanonical/Frame.lean` | 256 | `bx_G_backward` | yes | **yes** |
| 9 | `Metalogic/BXCanonical/Frame.lean` | 333 | `bx_H_backward` | yes | **yes** |
| 10 | `Metalogic/BXCanonical/Frame.lean` | 403 | `bx_modal_witness` | yes | **yes** |
| 11 | `Metalogic/BXCanonical/Frame.lean` | 685 | `bx_until_eventuality_resolution` | yes | **yes** |
| 12 | `Metalogic/BXCanonical/Frame.lean` | 708 | `bx_since_eventuality_resolution` | yes | **yes** |
| 13 | `…/Chronicle/ChronicleTypes.lean` | 110 | `bx_modal_witness_fc` | yes | **yes** |
| 14 | `…/Chronicle/ChronicleToCountermodelBasic.lean` | 216 | `limitDomSubtype_denselyOrdered_from_F'T` | no | **yes** |
| 15 | `…/Chronicle/CounterexampleElimination.lean` | 341 | `eliminate_C5_counterexample` | yes | **yes** |
| 16 | `…/Chronicle/CounterexampleElimination.lean` | 392 | `eliminate_C5'_counterexample` | yes | **yes** |
| 17 | `…/Chronicle/CounterexampleElimination.lean` | 447 | `eliminate_g_prop_counterexample` | yes | **yes** |
| 18 | `…/Chronicle/CounterexampleElimination.lean` | 488 | `eliminate_h_prop_counterexample` | yes | **yes** |
| 19 | `…/Chronicle/PointInsertion.lean` | 154 | `lemma_2_4` | yes | **yes** |
| 20 | `…/Chronicle/PointInsertion.lean` | 316 | `lemma_2_6` | yes | **yes** |
| 21 | `…/Chronicle/PointInsertion.lean` | 441 | `g_propagation_witness` | yes | **yes** |
| 22 | `…/Chronicle/PointInsertion.lean` | 3443 | `lemma_2_4_with_guard` | yes | **yes** |
| 23 | `…/Chronicle/PointInsertion.lean` | 3603 | `lemma_2_4_since_with_guard` | yes | **yes** |
| 24 | `…/Quasimodel/LocusControl.lean` | 37 | `bx_until_eventuality_resolution'` | yes | **yes** |
| 25 | `…/Quasimodel/LocusControl.lean` | 46 | `bx_since_eventuality_resolution'` | yes | **yes** |
| 26 | `…/Quasimodel/Realization.lean` | 285 | `until_eventuality_resolution` | yes | **yes** |
| 27 | `…/Quasimodel/Realization.lean` | 297 | `since_eventuality_resolution` | yes | **yes** |
| 28 | `…/WeakCanonical/EFGames/CustomGame.lean` | 824 | `extendPoint_lt_gap` | yes | no* |
| 29 | `…/WeakCanonical/EFGames/CustomGame.lean` | 832 | `lt_gap_mem_cut` | yes | no* |
| 30 | `…/WeakCanonical/Kamp/KampPrior.lean` | 350 | `nf_nvar_exist_all_depths` | yes | **yes** |
| 31 | `…/WeakCanonical/NEquivalence.lean` | 505 | `build_bicompat` | yes | no* |
| 32 | `…/WeakCanonical/NEquivalence.lean` | 817 | `sum_nf_lift_gen` | yes | no* |
| 33 | `…/WeakCanonical/NEquivalence.lean` | 885 | `sum_lift_one_var` | yes | no* |
| 34 | `…/WeakCanonical/NEquivalence.lean` | 988 | `sum_nf_agree_sentence` | yes | no* |
| 35 | `…/WeakCanonical/NEquivalence.lean` | 1134 | `sum_preservation_proof` | yes | no* |
| 36 | `…/WeakCanonical/ReflexiveCanonical.lean` | 52 | `mcs` | no | no (no underscore) |
| 37 | `…/WeakCanonical/ReflexiveCanonical.lean` | 569 | `g_content_closed_derivation` | yes | **yes** |
| 38 | `…/WeakCanonical/ReflexiveCanonical.lean` | 631 | `h_content_closed_derivation` | yes | **yes** |

\* excluded from `defsWithUnderscore` by `isBadNameWithUnderscore`'s namespace rule
(`declName.components.any (·.toString.endsWith '_')`) — they live under a namespace component
ending in `_`. They are still genuine `defProp` violations.

Line numbers are the **start of the command including its doc comment**, which is what the
linter reports; the `def` keyword is 1–14 lines below. Any implementation must locate the
`def` keyword by forward scan from that anchor, not assume the reported line.

### 2.3 The two non-mechanical members

- **31 of 38 carry `noncomputable`**, which is rejected on a `theorem`. It must be dropped in
  the same edit. (`noncomputable theorem` fails to elaborate — confirmed by a first pass that
  did not drop it.)
- **`limitDomSubtype_denselyOrdered_from_F'T` additionally carries `@[instance_reducible]`**,
  which fails with `failed to set reducibility status, … is not a definition`. The attribute
  must be removed. Its only consumer is a `letI` 22 lines below it in the same file; removal
  is build-verified below. This is the **only** member of the 38 that is not a one-token edit.

### 2.4 Empirical safety proof

Applied all 38 conversions (plus the two adjustments above) in the scratch clone:

| Check | Result |
|---|---|
| `lake build` | **1874 jobs, exit 0** |
| `lake build BimodalTest` | **1909 jobs, exit 0** |
| `defProp` warnings | 38 → **0** |
| Total build warnings | 70 → **30** |
| Warnings *added* | **0** (line-by-line diff of the warning census) |
| `defsWithUnderscore` (runLinter) | 888 → **860** (−28) |
| `unusedArguments` / `LINTER FAILED` / `docBlame` / `tacticDocs` / `structureInType` | **unchanged** (122/115/39/4/1) |

**Bonus:** the 2 `warn.classDefReducibility` warnings on `DenseTemporalFrame.mk'` /
`DiscreteTemporalFrame.mk'` also disappear, since that linter likewise only inspects
definitions.

The exact 28 names removed from `defsWithUnderscore` were computed by set difference, not
estimated. The remaining 10 of the 38 were never in that list (3 have no underscore, 7 are
namespace-excluded).

### 2.5 Why this is safe in principle, not just in this build

Every one of the 38 has a `Prop`-typed *type*, so **proof irrelevance** makes any two
inhabitants definitionally equal. Nothing can depend on the computational content of a
`Prop`-typed constant: no `DerivationTree` value can be projected out of it, and no `def`
producing data can distinguish `theorem foo` from `def foo`. The only real failure modes are
syntactic — `unfold`/`simp [foo]`/`delta foo` reaching for equation lemmas a theorem does not
get, and the modifier/attribute clashes above. All three are compile-time failures, and the
build is green.

### 2.6 A near-miss worth flagging (not part of the safe subset)

`Bimodal.Metalogic.Bundle.canonicalR_transitive`
(`Metalogic/Bundle/CanonicalFrame.lean:286`) is `abbrev canonicalR_transitive :=
@existsTask_transitive` — its type **is** a `Prop`, but `defProp` skips `abbrev`
(`info.hints.isAbbrev`) while `defsWithUnderscore` does not. It is the 29th `Prop`-typed
flagged declaration and would also convert cleanly, but it is **outside** the
`defProp`-defined subset and would lose `abbrev` reducibility, so it should not ride along
without sign-off. (For a `Prop` this reducibility loss is inert by proof irrelevance, but that
is an argument for a follow-up, not for silently widening a pre-approved scope.)

---

## 3. The architectural root cause, engaged

### 3.1 The claim is true for tier-1 `Theorems/` and false project-wide

Classification of all 888 flagged declarations by the actual elaborated type of each constant
(`Meta.isProp` plus `forallTelescopeReducing` on the conclusion):

| Scope | Prop-typed proof | `→ Prop` predicate | **`DerivationTree`-valued** | other data | total |
|---|---|---|---|---|---|
| `Metalogic/WeakCanonical` | 3 | 68 | 1 | 387 | 459 |
| **`Theorems`** | 0 | 0 | **135** | 0 | **135** |
| `Metalogic/BXCanonical` | 24 | 20 | 8 | 45 | 97 |
| `Automation` | 0 | 0 | 17 | 60 | 77 |
| `Metalogic/Bundle` | 1 | 19 | 9 | 5 | 34 |
| `Syntax` | 0 | 0 | 0 | 31 | 31 |
| `Semantics` | 0 | 7 | 0 | 10 | 17 |
| `Metalogic/Algebraic` | 0 | 1 | 0 | 12 | 13 |
| `Metalogic/Core` | 0 | 0 | 9 | 0 | 9 |
| `Metalogic/Decidability` | 0 | 0 | 5 | 4 | 9 |
| `FrameConditions` | 1 | 5 | 0 | 0 | 6 |
| `Metalogic/SoundnessLemmas` | 0 | 1 | 0 | 0 | 1 |
| **TOTAL** | **29** | **121** | **184** | **554** | **888** |

- **Project-wide, only 184/888 (20.7 %)** are `DerivationTree`-valued. The dominant bucket is
  554 ordinary data definitions (`Formula`, `Bool`, `List`, `Nat`, `Prod`, `ParserDescr`, …)
  whose snake_case names are a stylistic choice with no architectural cause at all.
- **In tier-1, 135/189 (71 %)** are `DerivationTree`-valued — and *all 135 live in
  `Theorems/`*. Within `Theorems/` the figure is 135/135 = 100 %.
- 121 declarations are `→ Prop` **predicates**. These must stay `def`s under any architecture.
  Mathlib's convention for a `Prop`-valued definition is **UpperCamelCase** (`IsCompact`), not
  lowerCamelCase, so route (b) would rename these differently from the rest — an extra rule
  the "rename everything to lowerCamelCase" framing does not capture.
- 44 of the 888 are `abbrev`s.

**Verdict on the framing:** "Every derived theorem must be a `def`" is accurate and load-bearing
*for `Theorems/`*, which is exactly the layer whose names read as mathematics
(`box_conj_iff`, `perpetuity_5`, `s4_box_diamond_box`). It is not an explanation for the other
753 findings.

### 3.2 The `Prop`-valued wrapper the task asks about **already exists**

`Theories/Bimodal/ProofSystem/Derivable.lean` (228 lines) defines

```lean
def Derivable (fc : FrameClass) (G : Context) (p : Formula) : Prop :=
  Nonempty (DerivationTree fc G p)
```

with notation `G |-! p` / `G |-![fc] p`, `Derivable.ofTree`, `Derivable.lift`, and a full set
of constructor-mirroring lemmas (`ax`, `assume`, `mp`, `nec`, `temp_nec`, `temp_dual`,
`weaken`). `Metalogic/Core/DeductionTheorem.lean` already carries a `Prop`-level
`Derivable.deduction`. The module's own design note states the intent explicitly: use
`DerivationTree` when you need the tree, `Derivable` when you only need the assertion.

So the "fourth route" the task hypothesises is not blocked by missing infrastructure. Its cost
is elsewhere.

### 3.3 Costing the `Derivable`-restatement route

Restating the 135 `Theorems/` combinators as `theorem foo : Derivable fc Γ φ` would make them
`theorem`s naturally and remove 135 findings (15 % of 888, 71 % of tier-1). But:

- **Type-valuedness is genuinely load-bearing.** `DerivationTree.height`
  (`ProofSystem/Derivation.lean:223`) is a computable `Nat`-valued recursor over the tree, with
  68 references across the library. `Nonempty` is a `Prop`; you cannot recover a tree from it to
  produce data. Eliminating `Type → Prop` is fine (that is why soundness-style proofs work), but
  `Prop → Type` is not.
- **The combinators are consumed to *build* trees.** The 135 names have **994** resolved
  usages across **59** modules. Consumers include `Automation/ProofStepExport.lean` (144
  textual hits) and `Automation/FormulaEnumerator.lean` (48) — the dataset/proof-search layer,
  which is computational by construction and needs real trees, not `Nonempty` witnesses.
- Consequently the migration is **not local**: every consumer that composes these combinators
  into a larger `DerivationTree` must also move to `Derivable`, and the cascade terminates only
  where a genuine tree is required — i.e. at the `Automation` boundary, which cannot move.
  A partial cascade means maintaining both a tree-valued and a `Derivable`-valued copy of each
  combinator: 135 declarations become ~270.

**Cost estimate: comparable to route (b) restricted to `Theorems/`, plus a permanent doubling
of the combinator API, in exchange for 135 of 888 findings.** It does not dominate the other
options. It is worth recording as a *design* possibility for a future cslib port that only ever
consumes derivability at `Prop` level — not as this task's remedy.

---

## 4. Route (b) costed: the rename

### 4.1 Churn, measured exactly (not grepped)

Usage counts come from the `references` blocks of the 300 compiled `.ilean` files — these are
resolved, elaborator-authoritative references, not textual matches.

| Metric | Value |
|---|---|
| Declarations to rename | **888** (873 distinct final name components) |
| **Resolved usages** | **24,364** |
| **Modules containing ≥1 usage** | **258 of 300 (86 %)** |
| Textual word-boundary occurrences (non-Boneyard) | 25,649 across 270 `.lean` files |
| Textual occurrences incl. Boneyard | 36,462 across 417 files |
| Tier-1 usages | 6,922 |
| Tier-2 usages | 235 |

Concentration is extreme and *inverted* relative to the architectural story:

| File | flagged decls | resolved usages |
|---|---|---|
| `Syntax/Formula.lean` | 12 | **4,929** |
| `Semantics/Truth.lean` | 1 | 515 |
| `Theorems/Propositional/Core.lean` | 6 | 257 |
| `Theorems/Combinators.lean` | 8 | 333 |
| all 135 `Theorems/` decls combined | 135 | 994 |

Twelve `Formula` constructor-ish names (`all_future` alone: **1,647** usages; `atom_s` 1,058;
`all_past` 627; `some_future` 586; `some_past` 491) account for **more churn than the entire
`Theorems/` layer by a factor of five** — and none of them is `DerivationTree`-valued. Renaming
them is pure data-definition churn touching the most-referenced identifiers in the codebase.

### 4.2 Identifier-prefix collision hazard — assessed directly

This is the hazard that corrupted `List.take_succ_cons` in a sibling task, and it is materially
worse here.

| Measure | Value |
|---|---|
| Flagged names that are a **proper prefix of another project identifier** | **398 of 873 (45.6 %)** |
| Flagged names that are a proper prefix of *another flagged* name | 91 (10.4 %) |
| Worst offenders | `kvE2_sepS` (prefix of 125 identifiers), `bracketEndChar_kv` (38), `kvE_subBracket` (29), `kvE_subBracket2` (25), `kvE_fiber` (24), `omega_chain` (22), `rank_embed` (20) |
| Naive substring replacement would touch | **68,076** sites |
| Of which correct (word-boundary) | 25,649 |
| **Of which wrong** | **31,614 (46.4 %)** |

A naive `sed`-style pass would corrupt roughly **one edit in two**. Word-boundary-anchored
replacement is mandatory and still leaves residual risk where a flagged short name coincides
with a local hypothesis name or a same-named declaration in a different namespace (15 short
names are already duplicated across namespaces within the flagged set alone).

### 4.3 The one piece of good news for route (b)

The target name space is essentially clean. Mechanically camel-casing all 873 distinct short
names yields **873 distinct targets**: **0** collisions inside the renamed set, and exactly
**1** collision with a pre-existing declaration —
`Bimodal.Automation.apply_modus_ponens → applyModusPonens`, which already exists. So the
obstacle is purely the mechanical edit, not semantic name capture.

### 4.4 Deprecation shims do not help — measured

A common mitigation is `@[deprecated] alias old_name := newName`. **Empirically tested:**
adding one such alias in the clone raised `defsWithUnderscore` from 860 to **861**, and
`box_interior_legacy` appears in the linter output. The alias is itself a `def` with an
underscore. A shim-based migration therefore leaves the count **unchanged or worse** until
every shim is deleted — i.e. it converts one breaking change into two.

### 4.5 Is the churn mechanically verifiable?

Partly. `lake build` + `lake build BimodalTest` catch every *renamed-away* reference (unknown
identifier). What they do **not** catch is a wrong-target replacement that happens to elaborate
— precisely the `List.take_succ` → `List.take_succ_cons` failure mode, and precisely what 398
prefix-overlapping names make likely. Detecting those requires a per-name, position-anchored
diff review over ~24 k sites.

---

## 5. Do the suppression mechanisms work on this toolchain? — verified empirically

Both were tested end-to-end in the clone. **Both work.**

| Mechanism | Test | Result |
|---|---|---|
| `scripts/nolints.json` | 2 `defsWithUnderscore` entries added | 860 → **858**; named decls absent from output |
| `@[nolint defsWithUnderscore]` attribute | applied to `Metalogic/Algebraic/InteriorOperators.box_interior` | builds clean (1874 jobs); 860 → **859**; `box_interior` absent from output |
| `lake exe runLinter Bimodal --update` | ran once | wrote 1,140-entry `scripts/nolints.json`; re-run prints **"Linting passed for Bimodal."**, exit **0** |
| **Filtered** `nolints.json` (859 `defsWithUnderscore` entries only) | re-ran linter | `defsWithUnderscore` → **0**; `unusedArguments` 122, `LINTER FAILED` 115, `docBlame` 39, `tacticDocs` 4, `structureInType` 1 all **intact** |

Mechanics (from `.lake/packages/batteries/scripts/runLinter.lean`):
`nolintsFile := "scripts/nolints.json"`, read relative to the invocation CWD, schema
`Array (Name × Name)` = `[[linterName, declName], …]`. Entries are subtracted from results
*after* `lintCore`, per-linter. `--update` rewrites the file from the current findings, sorted.

**Two cautions.**
1. `--update` is indiscriminate: it would also silence the 122 `unusedArguments`, 115
   `LINTER FAILED`, 39 `docBlame`, 4 `tacticDocs` and 1 `structureInType` that belong to sibling
   tasks. Any implementation must generate, then **filter to `defsWithUnderscore` only**, exactly
   as verified in the last row above.
2. The repository has **no `scripts/nolints.json` today**, so this file would be new.

### 5.1 Precedent: Mathlib does exactly this

`.lake/packages/mathlib/scripts/nolints.json` contains **719 entries**, of which **493 are
`defsWithUnderscore`** (the remaining 226 are `docBlame`). Mathlib carries **zero** inline
`@[nolint defsWithUnderscore]` attributes. Upstream Mathlib treats this linter as a curated
suppression list, not a hard gate — and this repository's 860 is ~1.7× Mathlib's own volume in
a codebase 1/50th the size, which is itself informative about how the two projects name things.

---

## 6. Recommendation

**Adopt route (c), refined — call it (c′): convert the `defProp` subset, then suppress the
remainder via a filtered `scripts/nolints.json`. Reject route (b).**

### 6.1 Step 1 — the pre-approved subset (no further sign-off required)

Convert the 38 `defProp` declarations `def → theorem`, dropping `noncomputable` on 31 of them
and `@[instance_reducible]` on `limitDomSubtype_denselyOrdered_from_F'T`.

- Correct on its own merits (a `Prop`-typed `def` should be a `theorem`).
- **Already build-verified**: 1874 + 1909 jobs green, 0 new warnings, all sibling linter
  categories frozen.
- Yields: `defProp` 38 → 0, `classDefReducibility` 2 → 0, `defsWithUnderscore` 888 → **860**
  (in-scope 208 → **207**; only `soundness_over` is in tier-1).
- Effort: 38 position-anchored one-line edits in 13 files + 1 attribute deletion.

### 6.2 Step 2 — the decision put to the user

Add `scripts/nolints.json` containing **only** the residual `defsWithUnderscore` entries (860
after step 1), generated by `lake exe runLinter Bimodal --update` and then filtered, plus a
short `docs/` note recording the deviation and its rationale.

- **Call sites affected: 0. Files touched: 1 (new). Regression risk: nil.**
- Verifiable in one command: `lake exe runLinter Bimodal` → `defsWithUnderscore` 0, all sibling
  categories unchanged. Already demonstrated.
- Keeps the mathematical readability of `box_conj_iff`, `perpetuity_5`, `s4_box_diamond_box`.
- Matches upstream Mathlib's own practice (§5.1).
- Cost: a documented, machine-readable deviation that a downstream port must consciously accept.

### 6.3 Why not route (b)

| Dimension | Route (b) |
|---|---|
| Declarations renamed | 888 |
| Resolved call sites | **24,364** |
| Modules touched | **258 of 300 (86 %)** |
| Names that are prefixes of other identifiers | **398 (45.6 %)** |
| Naive-replace error rate | **46.4 %** |
| Mechanically verifiable? | Only the *missing*-reference half; wrong-target edits need manual review of ~24 k sites |
| Mitigable by deprecation shims? | **No** — measured to *increase* the count |
| Buys | Conformance with a linter that runs in neither `lake build` nor this repo's CI |

The cost/benefit is not close. Route (b) risks the repository's one genuinely valuable asset —
a 1874-job green build with a single tracked `sorry` — against a linter category that is
currently invisible to every gate the project runs.

### 6.4 Optional narrow rename, if partial conformance is wanted

If the user wants *some* real conformance rather than pure suppression, the cheapest
high-signal subset is **not** `Theorems/` (which is where the architectural justification and
the mathematical readability both live). It is the **121 `→ Prop` predicates**, which Mathlib
would name **UpperCamelCase** (`IsCompact`-style) and which are genuinely non-conformant for a
reason unrelated to `DerivationTree`. Within tier-1 that is 12 declarations
(`Semantics` 7, `FrameConditions` 5) with modest usage. This can be costed separately if
desired; it is **not** part of the pre-approved subset.

Explicitly **not** recommended for renaming under any partial option: `Syntax/Formula.lean`'s
12 names (4,929 usages, 20 % of all churn in 1.4 % of the declarations).

---

## 7. Reproduction

All artifacts are in the session scratchpad
(`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/d076aad2-.../scratchpad/`):
`runlinter-fresh.json` (baseline), `runlinter-clone.json` (post-`defProp`),
`runlinter-nolints.json` / `runlinter-attr.json` / `runlinter-filtered.json` (suppression
tests), `runlinter-alias.json` (shim test), `census2.txt` (type classification of all 888),
`usage-counts.json` (per-declaration resolved usages), `defprop-edits.json` (the 38 edits),
`build-full.log` / `clone-build-defprop2.log` / `clone-build-tests.log`.

Tooling reused unchanged from `specs/400_clear_lean_v433_deprecation_warnings/tools/`:
`runlinter.py` (parse/counts/diff). `lintlib.py`'s `run_lint` was not needed — `defProp` is a
*syntactic* linter enabled by default in v4.33.0-rc1 (`register_builtin_option linter.defProp`,
`defValue := true`), so it surfaces directly in `lake build` output and was read from there via
the `severity: PATH:L:C: msg` lake shape.

## 8. Zero-debt statement

No step in this recommendation introduces a `sorry`, an axiom, or a deferred obligation. The
repository's single live `sorry` (`Transfer.lean:1242`, `countermodel_discrete`) is untouched
and out of scope. Step 1 is fully verified. Step 2 is a policy artifact with no proof content.
