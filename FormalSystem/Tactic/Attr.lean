/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Lean

/-!
# Attribute and simp-set declarations for the whole library

Declares every attribute and named simp set the library uses: the two truth-layer normalization
sets (`truth_norm`, `reflect_time_norm`), the two derived-operator normalization sets
(`formula_unfold`, `formula_fold`), and the `@[tmLemma]` label attribute the `modal_search` tactic
family reads.

**Why these declarations live in one layer-0 module.** `register_simp_attr` expands to an
`initialize` block plus a `syntax` declaration (`Lean/Meta/Tactic/Simp/RegisterCommand.lean`), and
neither the attribute nor the simp-set identifier it introduces is usable in the compilation unit
that declares it — tagging a lemma `@[truth_norm]` in the same file fails with `Unknown attribute
[truth_norm]`, and `simp only [truth_norm]` with `Unknown identifier truth_norm`. The declarations
therefore have to live strictly upstream of every use site. `FormalSystem/Init.lean` imports this
module, and check C24 asserts that every module in the library's closure reaches `Init`, so every
tag site and every `simp only` call site inherits these declarations transitively. That is why no
module needs to import this one directly.

**This module must import `Lean` only.** `FormalSystem.Init` imports it, so an
`import FormalSystem.Init` here would be a cycle. `register_simp_attr` and `register_label_attr`
are both core Lean commands and elaborate under a bare `import Lean`; they need nothing from
Mathlib or from this library.

**This module must not acquire any other content.** Attribute and simp-set declarations only — no
lemmas, no definitions, no instances. `Init.lean` imports it, so anything heavier would be forced
upstream of the entire library and would be recompiled by every module in it.

**History.** These five declarations were three separate modules under `FormalSystem/Automation/`
(`TruthNormAttr.lean`, `NormalizationAttr.lean`, `LemmaDB.lean`). Because `Syntax/`, `Semantics/`,
`ProofSystem/` and `Theorems/` all needed the attributes, each of those layers carried an upward
`import FormalSystem.Automation.*` line — eleven such lines in total. Relocating the declarations
to layer 0 and routing them through `Init` deleted all eleven outright.

**There is no wrapper tactic, deliberately.** A `truth_simp` macro expanding to
`simp only [truth_norm]` lived beside these declarations and was retired to
`Boneyard/RetiredTactics/` on the same measurement that retired the seven normalization wrappers:
zero invocations anywhere in the library or the test suite, its only occurrences being its own
docstring. Write the `simp only` out; it is the same length and says what it does.
-/

/-- Simp set for the truth-layer characterization lemmas of
`FormalSystem/Semantics/Truth.lean`: the `TruthAt` defining equations together with every
`Truth.*_iff` lemma (`neg_iff`, `and_iff`, `or_iff`, `imp_iff`, `box_iff`, `diamond_iff`,
`untl_iff`, `snce_iff`, `always_iff`, `future_iff`, `past_iff`, …). Rewrites a `TruthAt`-headed
goal about a compound formula into the corresponding meta-level connective. Use as
`simp only [truth_norm]`. -/
register_simp_attr truth_norm

/-- Simp set for the eleven `Formula.reflect_time_*` lemmas of
`FormalSystem/Syntax/Formula.lean`, which push `Formula.reflectTime` through the connectives.
Four of the eleven also carry `@[simp]`; this set makes the whole family reachable at once. Use
as `simp only [reflect_time_norm]`. -/
register_simp_attr reflect_time_norm

/-- Simp set for the derived-operator **unfold** lemmas of
`FormalSystem/Automation/Normalization.lean`: rewrites a derived operator (`neg`, `top`, `and`,
`diamond`, `someFuture`, …) to its primitive expansion in terms of `atom`, `bot`, `imp`, `box`,
`untl`, `snce`. Use as `simp only [formula_unfold]`.

**Why the lemmas are not in the default simp set.** The unfold and fold families are exact `rfl`
inverses of each other (`neg_unfold : φ.neg = φ.imp bot` against `neg_fold : φ.imp bot = neg φ`).
With both families tagged `@[simp]`, plain `simp` rewrote in a cycle and any `Formula` goal died
with `maximum recursion depth has been reached`. Moving them into these two named sets ends the
cycle without losing the lemmas: `simp only [formula_unfold]` and `simp only [formula_fold]` each
reach one family on demand. -/
register_simp_attr formula_unfold

/-- Simp set for the derived-operator **fold** lemmas of
`FormalSystem/Automation/Normalization.lean`, the `rfl` inverses of the `formula_unfold` family.
Use as `simp only [formula_fold]`. Note this family is a strict subset of the unfold family: six
operators (`weakFuture`, `weakPast`, `always`, `sometimes`, `strongRelease`, `strongTrigger`)
have an unfold lemma but no fold lemma, which is why a fold pass reverses the unfold lemmas
rather than using this set. -/
register_simp_attr formula_fold

/--
Label attribute for the derived-theorem database the `modal_search` family of tactics enumerates
for backward chaining (see `FormalSystem.Automation.Tactics.Search.tryLemmaMatch`, which reads it
via ``Lean.labelled `tmLemma``).

## Tagging Policy

Tag ONLY:
- fc-polymorphic (`⊢[fc] φ`) or Base-stated (`⊢ φ`) EMPTY-CONTEXT theorems,
  and inference-rule lemmas whose premises are themselves empty-context
  derivability statements (e.g. `impTrans`).

Never tag:
- Context-specific theorems (`ContextualProofs.lean`) — context-subset
  unification is out of scope for this database.
- fc-pinned theorems (stated at a specific non-Base frame class), which
  fail silently under `apply` for other frame classes.
- Generalized necessitation rules already special-cased by
  `tryModalK`/`tryTemporalK` (duplicative search branches).
-/
register_label_attr tmLemma
