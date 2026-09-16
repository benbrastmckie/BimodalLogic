/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Syntax.Formula
import FormalSystem.Automation.TruthNormAttr
import FormalSystem.Semantics.TruthClauses

-- Lower semantic layer: must not reach the proof system (G-15). `FrameClassValidity.lean`
-- is the one documented seam that imports `ProofSystem.Axioms`; nothing below it may.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass

/-!
# Truth - Truth Evaluation in Task Semantics

This module defines truth evaluation for TM formulas in task models.

**Irreflexive Temporal Semantics (A2 Guard Convention)**: Temporal operators G (allFuture)
and H (allPast) use STRICT semantics (< instead of ≤), meaning "all strictly
future/past times" (excluding the present). Under irreflexive semantics, the
T-axioms (Gφ → φ, Hφ → φ) are NOT valid. Until uses strict witness (s > t) with
open guard (t, s). Since uses strict witness (s < t) with open guard (s, t).

This is the open guard convention: strict witness, open guard. The seriality
axioms (⊤ → F(⊤), ⊤ → P(⊤)) replace the T-axioms (BX1/BX1').

## Paper Specification Reference

**Bimodal Logic Semantics (`app:TaskSemantics`, `def:BL-semantics`)**:
The JPL paper defines truth evaluation for TM formulas, and this module transcribes it. The
temporal clauses are **strict** on both sides: the pinned anchor `def:BL-semantics` quantifies H
over `y < x` and G over `x < y` on the nose, so this tree matches the paper exactly rather than
refining it. (Earlier revisions of this docstring described the paper's convention as reflexive
and this tree's reading as a refinement of it; both descriptions were stale and have been
corrected against the anchor of record.)
- `M,τ,x ⊨ p` iff `τ(x) ∈ |p|` (atom satisfaction — at a possible world `τ ∈ H_F`, which is the
  only place the paper evaluates truth; there is no domain conjunct in the paper's clause)
- `M,τ,x ⊨ ⊥` is false (bottom)
- `M,τ,x ⊨ φ → ψ` iff `M,τ,x ⊨ φ` implies `M,τ,x ⊨ ψ` (implication)
- `M,τ,x ⊨ □φ` iff `M,σ,x ⊨ φ` for all σ ∈ H_F, the total histories (box: necessity)
- `M,τ,x ⊨ Past φ` iff `M,τ,y ⊨ φ` for all y ∈ D where y < x (past, strict)
- `M,τ,x ⊨ Future φ` iff `M,τ,y ⊨ φ` for all y ∈ D where x < y (future, strict)

**Critical Semantic Design (this tree's encoding; Decision A of
`docs/architecture/total-history-validity-decisions.md`)**:
`def:BL-semantics` defines truth only at possible worlds `τ ∈ H_F`, whose domain is all of `D`,
and quantifies the temporal clauses over all `y ∈ D`. This tree evaluates `TruthAt` on
**arbitrary** `PartialHistory`s and reads the paper's clauses unchanged on them; the one place that
forces a choice is the atom clause, and the choice is:
- Atoms at times outside the domain are FALSE (not undefined). The domain conjunct is this
  tree's generalisation, not a paper clause; at a possible world it is trivially satisfied.
- Temporal operators still quantify over all of `D`, "beyond" the history's domain
- Validity (`Validity.lean`) quantifies only over total histories, so the paper's statements are
  unaffected; the generalisation matters only for finite histories used as intermediate objects
  (e.g., a chess game ending at move 31)

**ProofChecker Implementation Alignment**:
✓ Atom: `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`
  is the paper's `τ(x) ∈ |p|` plus the domain conjunct described above (atoms false outside
  the domain; trivially satisfied at a possible world)
✓ Bot: `False` matches paper's definition
✓ Imp: Standard material conditional matches paper
✓ Box: `∀ (σ : PartialHistory F), σ.IsTotal → TruthAt M σ t φ`
  matches paper's quantification over σ ∈ H_F (the frame's total histories)
✓ Past (H): via `@[simp] past_iff`: `∀ s, s < t → TruthAt M τ s φ`
  uses strict ordering (all past times, excluding now); derived via def + Until/Since
✓ Future (G): via `@[simp] future_iff`: `∀ s, t < s → TruthAt M τ s φ`
  uses strict ordering (all future times, excluding now); derived via def + Until/Since

## Main Definitions

- `TruthAt`: Truth of a formula at a model-history-time triple
- No notation defined (parsing conflicts with validity notation)

## Main Results

- Basic truth lemmas (e.g., `bot` is always false)
- Truth evaluation examples
- The A-17 corollaries: history-independence of atom-free formulas, and the gap formula

Truth *transport* between models — `TruthCorr`, the `TimeShift` family, `TruthIso`, `TruthAntiIso`, and `Truth.box_const` — is not here: it lives in `TruthTransport.lean`, which imports this module.

## Simp-normal form

The `Truth.*` characterization lemmas below are the truth layer's **simp normal form**: each
rewrites a `TruthAt`-headed goal about a compound formula into the corresponding meta-level
connective, so a proof never has to unfold the `Formula.and` / `Formula.or` / `Formula.neg`
definition chain by hand. The family is confluent and terminating; twelve alternative spellings
of the same formula were each checked to converge on the normal form under bare `simp`.

| Formula | Lemma | Normal form (RHS) |
|---|---|---|
| `¬φ` | `neg_iff` | `¬ TruthAt M τ t φ` |
| `⊤` | `top_true` | `True` (the lemma is the proof, not an `Iff`) |
| `⊥` | `bot_false` | `False` |
| `φ → ψ` | `imp_iff` | `TruthAt … φ → TruthAt … ψ` |
| `φ ∧ ψ` | `and_iff` | `TruthAt … φ ∧ TruthAt … ψ` |
| `φ ∨ ψ` | `or_iff` | `TruthAt … φ ∨ TruthAt … ψ` |
| `□φ` | `box_iff` | `∀ σ, σ.IsTotal → TruthAt M σ t φ` |
| `◇φ` | `diamond_iff` | `∃ σ, σ.IsTotal ∧ TruthAt M σ t φ` |
| `ψ U φ` | `untl_iff` | the `untl` clause |
| `ψ S φ` | `snce_iff` | the `snce` clause |
| `Fφ` | `some_future_iff` | `∃ s, t < s ∧ TruthAt M τ s φ` |
| `Pφ` | `some_past_iff` | `∃ s, s < t ∧ TruthAt M τ s φ` |
| `Gφ` | `future_iff` | `∀ s, t < s → TruthAt M τ s φ` |
| `Hφ` | `past_iff` | `∀ s, s < t → TruthAt M τ s φ` |
| `△φ` | `always_iff` | `∀ s, TruthAt M τ s φ` |
| `K⁺φ` | `kPlus_iff` | `∀ s, t < s → ∃ r, t < r ∧ r < s ∧ TruthAt M τ r φ` |
| `K⁻φ` | `kMinus_iff` | `∀ s, s < t → ∃ r, s < r ∧ r < t ∧ TruthAt M τ r φ` |
| `M(φ,ψ)` | `strong_release_iff` | the `untl` clause with a nested `and` |
| `ST(φ,ψ)` | `strong_trigger_iff` | the `snce` clause with a nested `and` |

All of the above are tagged into the `truth_norm` simp set declared in
`FormalSystem/Automation/TruthNormAttr.lean`, alongside `TruthAt`'s own defining equations, so
`simp only [truth_norm]` — or equivalently the `truth_simp` macro — opens the whole family at
once.

**`always` has two forms, and only one may carry the attribute.** `always_iff` (the collected
`∀ s` form) is the normal form and is the tagged one. `always_iff_tri` (the three-conjunct
past/present/future form, mirroring `MinusTruth.always_iff`) is the **introduction** form and is
deliberately left plain. The two are logically equivalent but syntactically distinct, so tagging
both makes `simp` apply whichever was declared first and silently strand every proof written
against the other; that failure was reproduced rather than merely anticipated. Build an `always`
with `always_iff_tri`, eliminate one with `always_iff`.

**A caveat when rewriting an existing `simp only` list.** Adding these names to a list that still
mentions `Formula.and` / `Formula.or` / `Formula.neg` is a no-op: simp rewrites bottom-up, so the
syntax-unfolding lemmas fire on the argument before the `TruthAt`-headed characterization lemma
can match. The syntax lemmas have to come **out** of the list as the characterization lemmas go
in.

## Note on Bridge Theorems

The bridge theorems connecting the proof system to semantics — the temporal-duality
infrastructure — live under `Metalogic/SoundnessLemmas/`, not here, so that this module depends
on no proof-system notion.

## Implementation Notes

- Truth is defined recursively on 6 formula constructors (atom, bot, imp, box, untl, snce)
- Modal box quantifies over all possible worlds at current time
- Until/Since use strict witness (s > t / s < t) with open guards (t,s) / (s,t)
- G/H/F/P are `def` abbreviations with `@[simp]` characterization theorems
- Atoms are false at times outside the history's domain

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - Truth evaluation
  specification
* [Formula.lean](../Syntax/Formula.lean) - Formula syntax
* [TaskModel.lean](TaskModel.lean) - Task model structure
* JPL Paper `app:TaskSemantics`, `def:BL-semantics` — formal truth definition, cited by
  `\label` (pinned verbatim in `docs/reference/paper-definitions-of-record.md`)
* `docs/architecture/total-history-validity-decisions.md` — Decision A, the arbitrary-history
  encoding of the atom clause

## Tags

truth · TruthAt · until · since · box · def:BL-semantics
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {F : TaskFrame}

/--
Truth of a formula at a model-history-time triple.

Given:
- `M`: A task model (frame + valuation)
- `τ`: A partial history (function from times to states); callers supply `τ.IsTotal`
- `t`: A time point
- `φ`: A formula

Returns whether `φ` is true at this semantic configuration.

The evaluation is defined recursively on formula structure (6 constructors):
- Atoms: true iff there exists a proof that t is in the history's domain
  AND valuation says so at current state (atoms are false at times outside domain)
- Bot (⊥): always false
- Implication: standard material conditional
- Box (□): true iff φ true at all **possible worlds** at time t
- Until `φ U ψ`: ∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r) (guard φ first, event ψ second)
- Since `φ S ψ`: ∃ s < t, ψ(s) ∧ ∀ r ∈ (s,t), φ(r) (guard φ first, event ψ second)

G (allFuture), H (allPast), F (someFuture), P (somePast) are `def` abbreviations
with `@[simp]` characterization theorems (see `future_iff`, `past_iff`, etc.).

**Paper Reference**: `def:BL-semantics`'s box clause, verbatim: "M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ
for all σ ∈ H_F". The quantifier ranges over `H_F` — the TOTAL histories — with no `Ω` and no
shift-closure side condition. `PartialHistory.IsTotal` is the predicate form of `H_F` membership
(Decision A of `docs/architecture/total-history-validity-decisions.md`); it is deliberately **not**
Mathlib's `IsMax` or any order-theoretic maximality predicate.

**There is no admissible-history parameter.** `TruthAt` takes the model, the history, the time
and the formula, and nothing else. The designated-carrier argument that earlier revisions
threaded through every clause has been deleted outright: the box clause reads its quantifier
range off `PartialHistory.IsTotal`, so no set-valued parameter can narrow, widen, or otherwise
influence the meaning of any connective.

**Atom clause** (Decision A, accepted gap): the `∃ (ht : τ.domain t)` conjunct is retained even
though `def:BL-semantics`'s atom clause has no domain conjunct. Under totality the conjunct is
vacuously satisfiable at every `t`, so the two readings agree on `H_F`; the conjunct is what keeps
`TruthAt` meaningful at the partial histories that the extension machinery still traffics in.

**Until / Since argument order**: `untl`/`snce` are **guard-first / event-second** — `untl ψ φ`
reads "ψ is the guard, φ is the event". The two clauses below transcribe
`def:BL-semantics`'s clause bodies directly:

- (since) "M,τ,x ⊨ φ since ψ *iff* M,τ,z ⊨ ψ for some time z < x where M,τ,y ⊨ φ for all y ∈ D
  with z < y < x."
- (until) "M,τ,x ⊨ φ until ψ *iff* M,τ,z ⊨ ψ for some time z > x where M,τ,y ⊨ φ for all y ∈ D
  with x < y < z."

In both, the existential witness is the **second** argument and the universally quantified
open-interval condition is the **first**. `def:BLplus-language` corroborates independently:
`past φ := ⊤ since φ`, `future φ := ⊤ until φ`, `Next φ := ⊥ until φ`, `Previous φ := ⊥ since φ`
— in each the operand is the event and sits second. `Formula.someFuture φ = untl ⊤ φ` and
`Formula.next φ = untl ⊥ φ` match character for character.

**Anchor provenance.** These clauses used to live under `def:BLplus-semantics`, a separate
definition for the separate language `BL^+`. The paper's 2026-09 wave collapsed `BL^+` into `BL`
and made the since/until clauses clauses of `def:BL-semantics` itself, deleting the old label —
which `docs/reference/paper-definitions-of-record.md` now records `DANGLING`. The clause bodies quoted
above are word-for-word what the live `def:BL-semantics` carries; only their home moved. The same
wave moved the defined operators into `def:BLplus-language`'s own block (that anchor id is
unchanged), retiring `def:BLplus-defined` likewise.

Earlier revisions of this docstring quoted an argument-order **footnote** of the then-`BL^+`
semantics anchor and asserted that the Lean tree was deliberately event-first. Both are
retired: the tracked anchor carries no footnote, and the tree was aligned
to the paper by a uniform argument swap of the definition and every call site. See
`docs/architecture/untl-snce-argument-order.md`. These clauses are τ-local and are untouched by the
box retarget.
-/
def TruthAt (M : TaskModel F)
    (τ : PartialHistory F) (t : F.Duration) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAt M τ t φ → TruthAt M τ t ψ
  | Formula.box φ => ∀ (σ : PartialHistory F), σ.IsTotal → TruthAt M σ t φ
  | Formula.untl ψ φ => ∃ s : F.Duration, t < s ∧ TruthAt M τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce ψ φ => ∃ s : F.Duration, s < t ∧ TruthAt M τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → TruthAt M τ r ψ

-- Note: We avoid defining a notation for TruthAt as it causes parsing conflicts
-- with the validity notation in Validity.lean. Use TruthAt directly.

/-! ### The abstract clause layer, instantiated

L's instances of `Semantics/TruthClauses.lean`. The environment is trivial (`PUnit`), since
`TruthAt` evaluates at `(M, τ, t)` alone; every clause field is `Iff.rfl` or `fun h => h`, which
is the compiler checking that `TruthAt`'s six clauses really do have the shared shapes. The
derived-operator lemmas below then delegate to the generic ones. -/

/-- L's pointed truth relation, with the trivial environment. -/
instance : TruthEnv Formula where
  Env _ := PUnit
  T M τ t _ φ := TruthAt M τ t φ

/-- L's five shared primitive operators and their clauses; `bot`/`imp`/`box` plus the strict
`untl`/`snce` pair. -/
instance : UntlClauses Formula where
  bot := Formula.bot
  imp := Formula.imp
  box := Formula.box
  untl := Formula.untl
  snce := Formula.snce
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  untl_clause _ _ _ _ _ _ := Iff.rfl
  snce_clause _ _ _ _ _ _ := Iff.rfl

namespace Truth

/--
Bot (⊥) is false everywhere.
-/
@[simp] theorem bot_false
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration} :
    ¬(TruthAt M τ t Formula.bot) := by
  intro h
  exact h

/--
Truth of implication is material conditional.
-/
@[simp] theorem imp_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ ψ : Formula) :
    (TruthAt M τ t (φ.imp ψ)) ↔
      ((TruthAt M τ t φ) → (TruthAt M τ t ψ)) := by
  rfl

/--
Truth of atom at a time in the domain: true iff valuation says so at current state.
For times outside domain, atoms are always false.
-/
theorem atom_iff_of_domain
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration} (ht : τ.domain t)
    (p : Atom) :
    (TruthAt M τ t (Formula.atom p)) ↔
      M.valuation (τ.states t ht) p := by
  simp only [TruthAt]
  constructor
  · intro ⟨ht', h⟩
    -- By proof irrelevance, τ.states t ht' = τ.states t ht
    exact h
  · intro h
    exact ⟨ht, h⟩

/--
Truth of atom at a time outside the domain is false.
-/
theorem atom_false_of_not_domain
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration} (ht : ¬τ.domain t)
    (p : Atom) :
    ¬(TruthAt M τ t (Formula.atom p)) := by
  simp only [TruthAt]
  intro ⟨ht', _⟩
  exact ht ht'

/--
Truth of box: formula true at every **total** history at the current time.

**Paper Reference**: `def:BL-semantics`'s box clause, "M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ for all
σ ∈ H_F". The quantifier's range is `PartialHistory.IsTotal`, taken directly from the frame; there
is no carrier parameter to supply.
-/
@[simp] theorem box_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ : Formula) :
    (TruthAt M τ t φ.box) ↔
      ∀ (σ : PartialHistory F), σ.IsTotal → (TruthAt M σ t φ) := by
  rfl

/--
Truth of someFuture: existential future operator.
F(φ) = U(φ, ⊤) is true iff there exists a strictly future time where φ holds.
-/
@[simp] theorem some_future_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t (Formula.someFuture φ) ↔
      ∃ s, t < s ∧ TruthAt M τ s φ :=
  TruthClauses.someFuture_iff (L := Formula) M τ t PUnit.unit φ

/--
Truth of somePast: existential past operator.
P(φ) = S(φ, ⊤) is true iff there exists a strictly past time where φ held.
-/
@[simp] theorem some_past_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t (Formula.somePast φ) ↔
      ∃ s, s < t ∧ TruthAt M τ s φ :=
  TruthClauses.somePast_iff (L := Formula) M τ t PUnit.unit φ

/--
Truth of allFuture: universal future operator.
G(φ) = ¬F(¬φ) is true iff φ holds at all strictly future times.
-/
@[simp] theorem future_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.allFuture ↔
      ∀ (s : F.Duration), t < s → TruthAt M τ s φ :=
  TruthClauses.allFuture_iff (L := Formula) M τ t PUnit.unit φ

/--
Truth of allPast: universal past operator.
H(φ) = ¬P(¬φ) is true iff φ holds at all strictly past times.
-/
@[simp] theorem past_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.allPast ↔
      ∀ (s : F.Duration), s < t → TruthAt M τ s φ :=
  TruthClauses.allPast_iff (L := Formula) M τ t PUnit.unit φ

/--
Truth of strongRelease: M(φ, ψ) = ψ U (ψ ∧ φ).
True iff there exists a strictly future time where ψ ∧ φ holds,
with ψ holding at all intermediate times.
-/
@[simp] theorem strong_release_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (Formula.strongRelease φ ψ) ↔
      ∃ s : F.Duration, t < s ∧ TruthAt M τ s (Formula.and ψ φ) ∧
        ∀ r : F.Duration, t < r → r < s → TruthAt M τ r ψ := by
  simp [Formula.strongRelease, Formula.and, TruthAt]

/--
Truth of strongTrigger: ST(φ, ψ) = ψ S (ψ ∧ φ).
True iff there exists a strictly past time where ψ ∧ φ held,
with ψ holding at all intermediate times.
-/
@[simp] theorem strong_trigger_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F}
    {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (Formula.strongTrigger φ ψ) ↔
      ∃ s : F.Duration, s < t ∧ TruthAt M τ s (Formula.and ψ φ) ∧
        ∀ r : F.Duration, s < r → r < t → TruthAt M τ r ψ := by
  simp [Formula.strongTrigger, Formula.and, TruthAt]


/-! ### The derived Boolean operators

`Formula.neg`, `top`, `and` and `or` are all `def` abbreviations over `imp`/`bot`, so without
these four the only way to reason about a conjunction is to unfold the definition chain by hand
with `simp only [Formula.and, Formula.neg, TruthAt]` and finish with `tauto`. That idiom is what
this family retires. -/

/-- Truth of `¬φ`. -/
@[simp, truth_norm] theorem neg_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ :=
  TruthClauses.neg_iff (L := Formula) M τ t PUnit.unit φ

/-- `⊤` is true everywhere. -/
@[simp, truth_norm] theorem top_true
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration} :
    TruthAt M τ t Formula.top :=
  TruthClauses.top_true (L := Formula) M τ t PUnit.unit

/-- Truth of `φ ∧ ψ`. Classical: `and` is the double-negated implication. -/
@[simp, truth_norm] theorem and_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (φ.and ψ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ) :=
  TruthClauses.and_iff (L := Formula) M τ t PUnit.unit φ ψ

/-- Truth of `φ ∨ ψ`. Classical: `or` is `¬φ → ψ`. -/
@[simp, truth_norm] theorem or_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (φ.or ψ) ↔ (TruthAt M τ t φ ∨ TruthAt M τ t ψ) :=
  TruthClauses.or_iff (L := Formula) M τ t PUnit.unit φ ψ

/-- Truth of `◇φ` (`¬□¬φ`): `φ` holds at *some* total history at the current time. The classical
`¬∀¬ ↔ ∃` step over `box_iff`. -/
@[simp, truth_norm] theorem diamond_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.diamond ↔ ∃ σ : PartialHistory F, σ.IsTotal ∧ TruthAt M σ t φ :=
  TruthClauses.diamond_iff (L := Formula) M τ t PUnit.unit φ

/-! ### The primitive temporal clauses

`untl_iff` and `snce_iff` restate `TruthAt`'s own `untl`/`snce` equations as biconditionals. They
look redundant next to `simp only [TruthAt]`, and they are not: once the characterization family
is the normal form, a proof no longer opens `TruthAt` at all, so a raw `untl`/`snce` head would
have nothing to reduce it. These two are what keep the family complete on the primitives. Both
are guard-first / event-second, matching `TruthAt`. -/

/-- Truth of `ψ U φ` (guard `ψ`, event `φ`): the `untl` clause of `TruthAt`, as a biconditional. -/
@[simp, truth_norm] theorem untl_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (ψ φ : Formula) :
    TruthAt M τ t (Formula.untl ψ φ) ↔
      ∃ s : F.Duration, t < s ∧ TruthAt M τ s φ ∧
        ∀ r : F.Duration, t < r → r < s → TruthAt M τ r ψ := Iff.rfl

/-- Truth of `ψ S φ` (guard `ψ`, event `φ`): the `snce` clause of `TruthAt`, as a biconditional. -/
@[simp, truth_norm] theorem snce_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (ψ φ : Formula) :
    TruthAt M τ t (Formula.snce ψ φ) ↔
      ∃ s : F.Duration, s < t ∧ TruthAt M τ s φ ∧
        ∀ r : F.Duration, s < r → r < t → TruthAt M τ r ψ := Iff.rfl

/-! ### Temporal `always`

**Only one of the two `always` characterizations may ever carry `@[simp]`.** They are logically
equivalent but syntactically distinct normal forms, so tagging both makes `simp` apply whichever
was declared first and silently strand every proof written against the other — a failure that was
reproduced, not hypothesised. The **collected `∀ s` form, `always_iff`, is the normal form** and
is the one that carries the attribute. `always_iff_tri` is the three-conjunct introduction form
that mirrors `MinusTruth.always_iff` and is the proof route to the collected form; it is deliberately
plain, and must stay untagged by both `@[simp]` and `@[truth_norm]`. -/

/-- Truth of `△φ` (`Hφ ∧ (φ ∧ Gφ)`) in three-conjunct form: past, present, future.

The **introduction** form — this is the shape you build an `always` from, and the association
mirrors `Formula.always` and `MinusTruth.always_iff`. It is **not** the simp normal form and must
never be tagged; see the section note above. Use `always_iff` for elimination. -/
theorem always_iff_tri
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.always ↔
      (∀ s : F.Duration, s < t → TruthAt M τ s φ) ∧ TruthAt M τ t φ ∧
        (∀ s : F.Duration, t < s → TruthAt M τ s φ) :=
  TruthClauses.always_iff_tri (L := Formula) M τ t PUnit.unit φ

/-- Truth of `△φ`, collected: `φ` holds at **every** time. The simp normal form for `always`.

Collapsing the three strict cases into one unrestricted `∀ s` is what removes the hand-rolled
`lt_trichotomy` case split that every `always` elimination otherwise has to perform. -/
@[simp, truth_norm] theorem always_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.always ↔ ∀ s : F.Duration, TruthAt M τ s φ := by
  rw [always_iff_tri]
  constructor
  · rintro ⟨hp, hn, hf⟩ s
    rcases lt_trichotomy s t with h | h | h
    · exact hp s h
    · exact h ▸ hn
    · exact hf s h
  · intro h
    exact ⟨fun s _ => h s, h t, fun s _ => h s⟩

/-! ### The density operators -/

/-- Truth of `K⁺φ` (`¬(¬φ U ⊤)`): between the present and every strictly future time there is an
intermediate time at which `φ` holds. -/
@[simp, truth_norm] theorem kPlus_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.kPlus ↔
      ∀ s : F.Duration, t < s → ∃ r : F.Duration, t < r ∧ r < s ∧ TruthAt M τ r φ := by
  simp only [Formula.kPlus, Formula.neg, Formula.top, TruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-- Truth of `K⁻φ` (`¬(¬φ S ⊤)`): the past dual of `kPlus_iff`. -/
@[simp, truth_norm] theorem kMinus_iff
    {F : TaskFrame} {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.kMinus ↔
      ∀ s : F.Duration, s < t → ∃ r : F.Duration, s < r ∧ r < t ∧ TruthAt M τ r φ := by
  simp only [Formula.kMinus, Formula.neg, Formula.top, TruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-! ### `truth_norm` membership for the pre-existing lemmas

`TruthAt`'s own defining equations together with the characterization lemmas declared above this
block. `always_iff_tri` is deliberately absent — see the `always` section note. -/

attribute [truth_norm] TruthAt bot_false imp_iff box_iff some_future_iff some_past_iff
  future_iff past_iff strong_release_iff strong_trigger_iff

/-! ## A-17: history-independence and the gap formula

The four uniformity axioms and the discrete box-necessity axiom all say the same thing twice
over: the formula they quantify is *atom-free*, so its truth cannot depend on the history at all,
and the particular atom-free formula they use — `⊥ U (⊥ → ⊥)` — says only that the temporal order
has a gap immediately above the point, which is a statement about `F.Duration` and nothing else.
Both facts are proved once here, so the soundness proofs that consume them collapse to one term
each instead of re-deriving the translation argument five times over. -/

/-- **Truth of an atom-free formula does not depend on the history.**

The `box` case is where this is not merely an induction bookkeeping step: `def:BL-semantics`'s box
clause quantifies over *all* total histories and does not mention `τ`, so the two sides are
definitionally equal there and the induction hypothesis is not needed. Every other case is
congruence. The atom case is vacuous — `(Formula.atom p).atoms = {p} ≠ ∅`. -/
theorem truthAt_atomFree_history_indep (M : TaskModel F) :
    ∀ (φ : Formula), φ.atoms = ∅ →
      ∀ (τ σ : PartialHistory F) (t : F.Duration), TruthAt M τ t φ ↔ TruthAt M σ t φ := by
  intro φ
  induction φ with
  | atom p => intro h; simp only [Formula.atoms, Finset.singleton_ne_empty] at h
  | bot => intro _ _ _ _; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
      intro h τ σ t
      simp only [Formula.atoms, Finset.union_eq_empty] at h
      exact imp_congr (ihφ h.1 τ σ t) (ihψ h.2 τ σ t)
  | box φ _ => intro _ _ _ _; exact Iff.rfl
  | untl ψ φ ihψ ihφ =>
      intro h τ σ t
      simp only [Formula.atoms, Finset.union_eq_empty] at h
      exact exists_congr fun s => and_congr_right fun _ =>
        and_congr (ihφ h.1 τ σ s)
          (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ h.2 τ σ r)
  | snce ψ φ ihψ ihφ =>
      intro h τ σ t
      simp only [Formula.atoms, Finset.union_eq_empty] at h
      exact exists_congr fun s => and_congr_right fun _ =>
        and_congr (ihφ h.1 τ σ s)
          (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ h.2 τ σ r)

/-- The **gap formula** `⊥ U (⊥ → ⊥)`, characterized: there is a point strictly above `t` with
nothing strictly between. The right-hand side mentions neither `M` nor `τ` — that is the entire
content of the uniformity block, isolated. -/
theorem truthAt_gap (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) :
    TruthAt M τ t (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) ↔
      ∃ s : F.Duration, t < s ∧ ∀ r : F.Duration, t < r → r < s → False := by
  simp only [TruthAt]
  constructor
  · rintro ⟨s, hts, -, hguard⟩; exact ⟨s, hts, hguard⟩
  · rintro ⟨s, hts, hguard⟩; exact ⟨s, hts, id, hguard⟩

/-- The past dual of `truthAt_gap`: `⊥ S (⊥ → ⊥)` says there is a point strictly below `t` with
nothing strictly between. -/
theorem truthAt_cogap (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) :
    TruthAt M τ t (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)) ↔
      ∃ s : F.Duration, s < t ∧ ∀ r : F.Duration, s < r → r < t → False := by
  simp only [TruthAt]
  constructor
  · rintro ⟨s, hst, -, hguard⟩; exact ⟨s, hst, hguard⟩
  · rintro ⟨s, hst, hguard⟩; exact ⟨s, hst, id, hguard⟩

/-- **Gaps translate.** A gap immediately above `t` is a gap immediately above every point: shift
the witness by `u - t` and shift any intruder back. Translation invariance of `<` on the duration
group is the whole argument, which is why the statement mentions no history and no model. -/
theorem truthAt_gap_shift (M : TaskModel F) (τ : PartialHistory F) (t u : F.Duration)
    (h : TruthAt M τ t (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) :
    TruthAt M τ u (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) := by
  rw [truthAt_gap] at h ⊢
  obtain ⟨s, hts, hguard⟩ := h
  refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun c huc hcs => ?_⟩
  have h1 : t < c - (u - t) := by
    conv_lhs => rw [(sub_sub_cancel u t).symm]
    exact sub_lt_sub_right huc _
  have h2 : c - (u - t) < s := by
    conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
    exact sub_lt_sub_right hcs _
  exact hguard (c - (u - t)) h1 h2

/-- **A gap above is a gap below.** The mirror of `truthAt_gap_shift`: reflect the witness through
`t`. Its two directions are what make the two `discrete_symm_*` axioms one term each. -/
theorem truthAt_gap_iff_cogap (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) :
    TruthAt M τ t (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) ↔
      TruthAt M τ t (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)) := by
  rw [truthAt_gap, truthAt_cogap]
  constructor
  · rintro ⟨s, hts, hguard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact hguard (c + (s - t)) h1 h2
  · rintro ⟨r, hrt, hguard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact hguard (c - (t - r)) h1 h2

end Truth

end FormalSystem.Semantics
