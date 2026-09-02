# Wave 0 Hotfix — Claim Verification Report

**Task type**: lean4 · **Session**: `sess_1788324209_de679d_518` · **Dispatch**: 1

Every one of the seven claims in the task description was checked against the working tree at
`HEAD` (`92b154ab2`). Line numbers below are the **current** ones; where the description's numbers
had drifted, the drift is called out. Three claims needed correction; four were confirmed verbatim.

**Baseline established (all measured, not assumed):**

| Probe | Command | Result |
|---|---|---|
| Build green at HEAD | `lake build` | exit 0 |
| Simp loop reproduces | `lake env lean` on a probe importing `Automation.Normalization` | **`maximum recursion depth has been reached`** |
| `register_simp_attr` viability | two-module probe | works, **but only across a module boundary** (see §1.3) |
| Removing all 31 `@[simp]` tags | `lake build` + `lake build BimodalTest` | **exit 0, zero errors, zero downstream breakage** |
| Four unbuilt modules compile | `lake build` of each by name | exit 0 (2 `push_neg` deprecation warnings) |
| `completeness` axioms | `lean_verify` | `[propext, Classical.choice, Quot.sound]` — **no `sorryAx`** |

---

## 1. D-01 — the global simp loop · **CONFIRMED, with two corrections**

### 1.1 The counts and line ranges are exact

`FormalSystem/Automation/Normalization.lean`:

- **21 `@[simp]` unfold lemmas** at lines 69, 72, 75, 78, 83, 87, 91, 95, 99, 105, 109, 115, 120,
  127, 133, 139, 143, 149, 153, 157, 161 (section `UnfoldLemmas`, `:67`–`:164`).
- **10 `@[simp]` fold lemmas** at lines 800, 803, 806, 810, 814, 818, 822, 826, 830, 834
  (section `FoldLemmas`, `:798`–`:837`).
- A 32nd `@[simp]`, `normalizeFormula_id` at `:1218`, is **not** part of the loop and must be
  left alone.

The pairs are exact `rfl` inverses. e.g. `neg_unfold : φ.neg = φ.imp bot := rfl` (`:69`) against
`neg_fold : φ.imp bot = neg φ := rfl` (`:800`).

### 1.2 The failure reproduces exactly as described

```
$ cat probe.lean
import FormalSystem.Automation.Normalization
open FormalSystem.Syntax
example (a : Formula) : a.neg = a.neg := by simp

$ lake env lean probe.lean
probe.lean:3:44: error: Tactic `simp` failed with a nested error:
maximum recursion depth has been reached
```

Note `open FormalSystem.Syntax` — the description's `open FormalSystem` does not bring `Formula`
into scope (`Formula` is declared in `namespace FormalSystem.Syntax`, `Formula.lean:55`/`:127`).
The regression test must use the right `open`.

Blast radius: `Normalization.lean` has 5 live importers — `FormalSystem/Automation.lean:15`,
`Metalogic/Decidability/DecisionProcedure.lean`, `Automation/DatasetExport.lean`,
`Automation/ProofStepExtractor.lean`, `Tests/BimodalTest/Automation/NormalizationTest.lean` — and
`Automation.lean` is reached from `FormalSystem/FormalSystem.lean:14`, so every
`import FormalSystem` consumer inherits it. The description's "43 modules" figure was not
re-measured (it is not load-bearing for the fix).

### 1.3 CORRECTION — `register_simp_attr` cannot live in `Normalization.lean`

`register_simp_attr` **parses** in `Normalization.lean`, but the attribute it declares is not
usable in the same compilation unit. A single-file probe fails:

```
error: Unknown attribute `[formula_unfold]`
error(lean.unknownIdentifier): Unknown identifier `formula_unfold`
```

A two-module probe (`Probe/Attr.lean` declaring the attrs, `Probe/Use.lean` importing it and
tagging lemmas) compiles clean and both `simp only [formula_unfold]` and `simp only [formula_fold]`
work, with plain `simp` no longer looping. **The plan must create a new module** — e.g.
`FormalSystem/Automation/NormalizationAttr.lean` containing only `import Lean` plus the two
`register_simp_attr` lines — and have `Normalization.lean` import it. `register_simp_attr` appears
nowhere in this repo or in the pinned Mathlib, so there is no in-tree precedent to copy.

### 1.4 The fix is provably non-breaking

I stripped all 31 `@[simp]` tags (lines 69–161 and 800–834 only) and ran a full build:

```
lake build          -> exit 0, 0 errors
lake build BimodalTest -> exit 0, 0 errors
```

**Nothing in the tree or the test suite depends on these lemmas being in the global simp set.**
The file was restored byte-for-byte afterwards (`git diff` clean). This removes the principal risk
from the hotfix: the retag is safe, and the only remaining work is wiring the four macros to the
new attribute names.

### 1.5 Macro rewrite detail

The four macros do **not** currently reference the fold lemmas at all:

- `modalNorm` (`:178`), `modalNormAt` (`:206`), `modalNormAll` (`:220`) each enumerate the same
  21 unfold lemmas by name -> replace the whole list with `[formula_unfold]`.
- `modalFold` (`:845`) uses `← *_unfold` (reverse rewriting), **not** the `*_fold` lemmas ->
  replacing it with `simp only [formula_fold]` is a genuine behavioural change, because the
  `*_fold` family is a strict subset (10 lemmas; `weak_future`/`weak_past`/`always`/`sometimes`/
  `strong_release`/`strong_trigger` have `← _unfold` entries in `modalFold` but no `_fold` lemma).
  Two safe options: (a) keep `modalFold` on the `←`-form and tag the `*_fold` family
  `@[formula_fold]` purely to get it out of the global set; or (b) add the six missing `_fold`
  lemmas. **Recommend (a)** — smallest diff, no behaviour change, and it still fixes the loop.
- Three further macros — `propNorm` (`:188`), `modalOpNorm` (`:192`), `temporalNorm` (`:198`) —
  use explicit sub-lists and are **unaffected**; they must keep naming lemmas individually.

### 1.6 Regression test placement

`Tests/BimodalTest/Automation/NormalizationTest.lean` (255 lines) already imports
`FormalSystem.Automation.Normalization` and is wired into `Tests/BimodalTest.lean`. Add the
regression `example` there rather than creating a new file.

---

## 2. B-08 / C-19 — unbuilt modules and C6 · **CONFIRMED, with one correction**

### 2.1 Verified import graph

| Module | Importers |
|---|---|
| `Metalogic/SpWitness.lean` | **none** |
| `Metalogic/Z1Countermodel.lean` | **none** |
| `Metalogic/TMCompletenessReduction.lean` | `Z1Countermodel.lean:8` only |
| `Semantics/LexCarrier.lean` | `Z1Countermodel.lean:10` only |

`FormalSystem/Metalogic.lean:8-19` names none of them; `lakefile.lean` declares
`lean_lib FormalSystem` with `roots := #[\`FormalSystem]` and no globs, so nothing else can reach
them. `scripts/module-invariants-manifest.txt` does not list them, which is precisely why C6 fails
(`check-module-invariants.sh:357`: `bad("C6", f"{len(unmanifested)} unreachable live module(s)
absent from …")`).

### 2.2 CORRECTION — `BLSchemaValidity` is already reachable; do not treat it as part of the C6 fix

`FormalSystem/Semantics/BLSchemaValidity.lean` is imported by
`Metalogic/BaseLanguageSoundness.lean:10`, which `Metalogic.lean` imports. It is **in** the build
graph today and is not among C6's four failures. Adding it to `FormalSystem/Semantics.lean` is
optional *layering hygiene* (a `Semantics/` module currently reached only through `Metalogic/`,
per the review's C-frames §898-901), not part of the acceptance criterion. Keep it separable so a
build regression there cannot block the C6 fix.

### 2.3 The two imports suffice — `LexCarrier` needs no separate wiring

Adding `import FormalSystem.Metalogic.Z1Countermodel` and `import FormalSystem.Metalogic.SpWitness`
to `Metalogic.lean` pulls `TMCompletenessReduction` and `LexCarrier` in **transitively**, clearing
all four C6 entries with a two-line diff and zero manifest edits. Adding `LexCarrier` to
`Semantics.lean` as well is again hygiene, and carries a real risk worth weighing: `LexCarrier`
declares `SuccOrder`/`PredOrder` instances on `ℚ ×ₗ ℤ` and pulls four Mathlib order/algebra
imports; putting them into the aggregator that essentially every module imports widens instance
search tree-wide. **Recommend: do the two `Metalogic.lean` imports for C6; treat the two
`Semantics.lean` additions as an independent, separately-verified step.**

### 2.4 All four already compile

```
lake build FormalSystem.Metalogic.Z1Countermodel FormalSystem.Metalogic.SpWitness \
           FormalSystem.Semantics.LexCarrier FormalSystem.Metalogic.TMCompletenessReduction
-> Build completed successfully (2291 jobs). EXIT=0
```

Two non-fatal `push_neg` deprecation warnings at `Z1Countermodel.lean:101` and `:148` will become
visible in the main `lake build` once wired in. Optional cleanup; not a blocker.

### 2.5 The cited result exists

`Z1Countermodel.tmCompleteDiscrete_refuted` is at `Z1Countermodel.lean:199` (with
`not_bl_derivable_z1` at `:175`), and `Metalogic/Conservativity.lean:158-162` cites both by name as
"**Both are now landed** … the refutation is machine-checked, not merely documented". Today that
prose describes code `lake build` never compiles.

---

## 3. E-01 — README Dedekind strong completeness · **CONFIRMED (two sites, not one)**

- `README.md:167` reads: "**Dedekind** — **not stated** … this tree contains no `CompactDedekind`
  definition and no refuting theorem, so the class is *unproved* rather than refuted."
- Ground truth: `Metalogic/SetConsequence.lean` defines `StrongCompletenessDedekind` (`:601`) and
  `CompactDedekind` (`:609`) — **both docstrings already say "This statement is false"** and name
  their refutations. `Metalogic/DedekindNonCompactness.lean` proves
  `dedekind_consequence_not_compact` (`:431`) and `strongCompletenessDedekind_refuted` (`:459`),
  each documented sorry-free at `[propext, Classical.choice, Quot.sound]`.
- `FormalSystem/Metalogic.lean:116-120` is the correct version: "`FrameClass.Dedekind` —
  **refuted**, like Discrete."

**Second drifted site the description did not name**: `README.md:239-240` — "a different property
from Dedekind strong completeness (**open** — see the strong-completeness discussion above…)". It
is refuted, not open, and it forward-references the very paragraph being fixed. Correct both.

---

## 4. E-02 — typst `sorryAx` claims · **CONFIRMED (six regions, not five)**

`lean_verify` on `FormalSystem.Metalogic.BXCanonical.completeness`:

```json
{"axioms":["propext","Classical.choice","Quot.sound"]}
```

No `sorryAx`. `scripts/check-module-invariants.sh:145,155` already pins this baseline under C14
and C14 passes. `countermodel_discrete` is a **live** theorem at
`WeakCanonical/GroupModel/CountermodelBase.lean:143` — **not** in `Transfer.lean` — and it is
called by `BXCanonical/Completeness.lean:228`. `Transfer.lean:27-28` itself says
"(`countermodel_discrete`, the Base-frame branch of `completeness`, is a separate theorem and is
likewise `sorryAx`-free.)". A tree-wide scan finds no live structural `sorry` outside
`FormalSystem/Boneyard/`, consistent with C3.

Sites in `typst/FormalFoundations.typ` requiring correction:

| Line(s) | Wrong claim |
|---|---|
| `:697` (footnote) | "The `sorryAx` traces to a single dependency, `countermodel_discrete`, which is dead code" |
| `:699-703` | `#theorem("Base-class completeness (outstanding)")` — "with one proof obligation outstanding. Its axiom report contains `sorryAx`. It is not an established theorem and is not used below." |
| `:993` | table row: `[`completeness`], …, [same, plus `sorryAx`], [*yes*]` |
| `:999-1005` | "exactly one structural `sorry` … `countermodel_discrete` in `WeakCanonical/Transfer.lean`. It is dead code." — wrong on the count, wrong on the file, wrong on "dead" |
| `:1007-1010` | **not in the description** — "what carries the base class's `sorryAx` is the model-existence step of the Representation theorem's proof, via `completeness` alone" |
| `:1543` | summary table: `[Model existence (base class)], [`completeness`, one `sorryAx`]` |

`:704-705`'s `#leansrc` references are correct and need no change.

---

## 5. E-03 — Formula constructor tables · **CONFIRMED, and worse than described**

Ground truth, `FormalSystem/Syntax/Formula.lean:76-105`: `atom`, `bot`, `imp`, `box`, `untl`,
`snce`. Six constructors.

- `FormalSystem/README.md:49-58` — "Primitive Operators" table lists `atom`, `bot`, `imp`, `box`
  and then `Hφ | all_past φ` (`:57`) and `Gφ | all_future φ` (`:58`). Both are derived, not
  primitive; `untl`/`snce` are absent entirely.
- `FormalSystem/README.md:60-72` — "Derived Operators" table compounds the error with
  `some_past φ` (`:68`) and `some_future φ` (`:69`). The **actual Lean names are camelCase** —
  `allPast`, `allFuture`, `somePast`, `someFuture` (see `Normalization.lean:99-111`) — so every
  snake_case name in both tables is a dead identifier, not merely mis-classified.
- `FormalSystem/Syntax/README.md:19` — "Primitives: `atom`, `bot`, `imp`, `box`, `all_past`,
  `all_future`". Same defect.

A repo-wide `grep` outside `specs/` finds `all_past`/`all_future`/`some_past`/`some_future` in
**exactly these two files**, so the E-03 scope is closed.

**Caveat on the prescribed fix.** The description says to replace both tables with a link to
`README.md:33-69`. That version is correct on `untl`/`snce` and on the derived operators, but
`README.md:32` says "The logic uses **5 primitive connectives**" and its table omits `atom` — a
defensible reading (`atom` is not a connective) that nevertheless conflicts with the six-constructor
list `Syntax/README.md:19` is supposed to state. Recommend: link from `FormalSystem/README.md`, and
in `Syntax/README.md:19` **write the corrected six-constructor list inline** rather than link,
since that bullet is specifically about `Formula`'s constructors.

---

## 6. F-03 — `Bundle ↔ Algebraic` cycle · **CONFIRMED; the README fix is the opposite of described**

The cycle is real and live in the build graph:

- `FormalSystem/Metalogic/Bundle/LimitMCS.lean:8` -> `import FormalSystem.Metalogic.Algebraic.FlowFrame`
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean:9` -> `import FormalSystem.Metalogic.Bundle.TemporalCoherence`

`LimitMCS` is reachable (`BXCanonical/Chronicle/Chronicle{LimitGuardWitness,LimitGuardAbove,
LimitGapWitness,GuardAccumulation}.lean` -> `Bundle/RealExtensionBundle.lean` ->
`Bundle/RealExtension.lean` -> `Bundle/LimitMCSCoherence.lean` -> `Bundle/LimitMCS.lean`), so this
is not a dead edge.

`fc_theorem_true_in_bundle_flow_model` is at `LimitMCS.lean:461-473` with **zero consumers** —
`grep` for the name across all `*.lean` returns only its own declaration site. It is the *only*
declaration in the file touching `FlowFrame` (`bundleFlow*` occurs only at `:452`, `:470`, `:471`,
all inside that declaration and its docstring). Deleting declaration + import is a clean two-hunk
change.

**CORRECTION.** `FormalSystem/Metalogic/README.md:70` (the description said `:88` — drifted) reads
"There are exactly **two** directory-level cycles in `Metalogic/`", enumerating
`BXCanonical ↔ WeakCanonical` (`:74`) and `Bundle ↔ Core` (`:93`) — both independently verified.
The description offers "correct README.md:88 to 'three cycles' or, after deletion, 'two'". Since
the deletion *is* the fix, the count returns to two and **the README needs no edit at all**. The
layering diagram (`Algebraic/` below `Bundle/`) likewise becomes accurate again. If the plan wants
a durable guard, F-03's own recommendation — a `check-module-invariants.sh` check that enumerates
directory cycles from the import graph instead of asserting a hand-counted number — is the right
follow-up, but it is out of hotfix scope.

---

## 7. D-13 — Aesop rule set · **CONFIRMED, with a count correction**

`FormalSystem/Automation/AesopRules.lean` (285 lines) carries **21** attributes, not 18:
`@[aesop safe apply]` ×10 (`:78, 84, 90, 96, 102, 108, 115, 222, 232, 242`),
`@[aesop safe forward]` ×7 (`:132, 144, 156, 168, 181, 192, 204`),
`@[aesop norm unfold]` ×4 (`:258, 266, 274, 282`).

The file's own module docstring already documents the defect at `:50-53`: "the rules below are
registered in Aesop's DEFAULT rule set via `@[aesop safe apply]`; there is no separate `TMLogic`
rule set declared (`declare_aesop_rule_sets [TMLogic]` is absent), so plain `aesop` picks them up."
The deprecation notice is at `:16-22`. `AesopRules` is reachable
(`FormalSystem/Automation.lean:12`, `Automation/Tactics/Helpers.lean:8`), so these rules are in the
default set for every consumer.

`declare_aesop_rule_sets` is used in the pinned Mathlib
(`Mathlib/CategoryTheory/Category/Init.lean:21`, `Mathlib/Tactic/SetLike.lean:22`) so the syntax is
available. **Note**: the same import-boundary caveat as `register_simp_attr` may apply — Mathlib
puts `declare_aesop_rule_sets` in a dedicated `Init.lean`-style module. The plan should either
place the declaration in a separate small module or verify in-file usage empirically before
committing to the layout. The `:50-53` docstring paragraph must be rewritten in the same change.

---

## Recommended phase decomposition

Seven genuinely independent edits; nothing here needs `sorry`, and no approach considered risks
one. Suggested ordering, smallest-risk first:

| Phase | Scope | Files | Verification |
|---|---|---|---|
| 1 | E-01 README Dedekind (2 sites) | `README.md` | `grep` |
| 2 | E-03 constructor tables | `FormalSystem/README.md`, `FormalSystem/Syntax/README.md` | `grep`; `check-module-invariants.sh` C12/C13 (markdown links) |
| 3 | E-02 typst (6 regions) | `typst/FormalFoundations.typ` | `grep`; typst compile if wired |
| 4 | F-03 orphan + import | `Metalogic/Bundle/LimitMCS.lean` | `lake build` |
| 5 | B-08 wire in 4 modules | `FormalSystem/Metalogic.lean` (+ optionally `FormalSystem/Semantics.lean`) | `lake build`; **`check-module-invariants.sh` C6 must flip to PASS** |
| 6 | D-01 simp attrs | new `Automation/NormalizationAttr.lean`, `Automation/Normalization.lean`, `Tests/BimodalTest/Automation/NormalizationTest.lean` | `lake build` + `lake build BimodalTest` + regression `example` |
| 7 | D-13 aesop rule set | `Automation/AesopRules.lean` | `lake build` |

Phases 1–3 touch no Lean source and can run in parallel with 4–7. Phases 4, 5, 6, 7 touch disjoint
Lean files and have no ordering dependency among themselves, but each needs its own `lake build`.

**Acceptance, restated against measured facts**: `lake build` exit 0 and `lake build BimodalTest`
exit 0 (both green at HEAD, so any failure is attributable); `bash scripts/check-module-invariants.sh`
with **C6 flipped from FAIL to PASS** and no other check regressing from the current all-pass-except-C6
baseline; the `simp` regression `example` compiling with `open FormalSystem.Syntax`; and `grep`
confirming the six typst regions, the two `README.md` sites, and the three constructor-table sites.

## Sources consulted

- `specs/reviews/2026-09-01-lean-engineering/{B-completeness,C-frames,F-canonical}.md` (findings
  B-08, C-16, C-19, F-03) — each re-verified against source rather than taken on report authority.
- `scripts/check-module-invariants.sh` (`:339-402` C6 implementation; `:145,155` C14 axiom baseline)
  and `scripts/module-invariants-manifest.txt`.
