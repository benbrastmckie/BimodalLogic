/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.TruthClauses
import FormalSystem.QuantLanguage.Formula

/-!
# `QuantTruthAt` — truth for the propositional-quantifier language

The native truth recursion for `QuantFormula` (`FormalSystem/QuantLanguage/Formula.lean`),
relative to a family `Adm` of **admissible propositions**. The six clauses of the base language
are those of `TruthAt` (`Semantics/Truth.lean`) verbatim, with `Adm` threaded through unchanged,
and the quantifier clause is:

```
M,τ,x ⊨_Adm ∀p φ   iff   M[p ↦ S],τ,x ⊨_Adm φ for all S ∈ Adm,
```

where `M[p ↦ S]` (`TaskModel.updateAtom`) re-interprets the letter `p` by the set `S` of world
states. A proposition is a **set of world states**, because that is what a sentence letter
denotes in a task model (`def:BL-semantics`: `τ(x) ∈ |p|`).

## The admissible family is the design

One recursion is evaluated at two arguments. `Adm = Set.univ` is the **standard** semantics: the
quantifier ranges over every set of world states. `Adm = pulledBack g`
(`QuantLanguage/QuantInvariance.lean`), the preimages of state sets along a history-lifting map,
is the **clock-independent** semantics: the quantifier ranges over the propositions that cannot
tell two preimages of one state apart. The contrast between the two is what the component
exists to state, and a family parameter lets it be stated about a single truth relation.

## Main Definitions

- `TaskModel.updateAtom M p S` — re-interpret the letter `p` by the state set `S`
- `QuantTruthAt M τ t Adm φ` — the seven-clause truth recursion

## Main Results

- `TaskModel.updateAtom_valuation_self`, `TaskModel.updateAtom_valuation_of_ne`
- The `QuantTruth.*_iff` clause lemmas, including `all_iff`, and `univ_iff` / `exist_iff`: `A φ`
  holds iff `φ` holds at **every** history and time, `E φ` iff at some
- `quantTruthAt_ofFormula` — **truth-level conservativity over L**: a formula of the base language
  embedded into the quantifier language is true exactly when it is true in L, whatever the
  admissible family

## References

* JPL paper `def:BL-semantics` — the base clauses; a sentence letter denotes a set of world states
* JPL paper `def:world-history` — world histories are total, which is what `univ_iff` uses
* `FormalSystem/Semantics/Truth.lean` — `TruthAt`, whose six clauses are copied
* `FormalSystem/Semantics/TruthClauses.lean` — the abstract clause layer instantiated here

## Tags

quant-language · truth · propositional-quantifier · admissible-family · conservativity
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/-- Replace the truth set of one sentence letter by a set of world states, leaving every other
letter alone. Housed with the quantifier language, its only consumer.

Paper: — (formalization-native; the paper's languages have no propositional quantifiers) -/
def TaskModel.updateAtom {F : TaskFrame} (M : TaskModel F) (p : Atom) (S : Set F.WorldState) :
    TaskModel F :=
  ⟨fun w q => if q = p then w ∈ S else M.valuation w q⟩

/-- The updated letter denotes the new set. -/
@[simp] theorem TaskModel.updateAtom_valuation_self {F : TaskFrame} (M : TaskModel F) (p : Atom)
    (S : Set F.WorldState) (w : F.WorldState) :
    (M.updateAtom p S).valuation w p ↔ w ∈ S := by
  simp [TaskModel.updateAtom]

/-- Every other letter keeps its denotation. -/
@[simp] theorem TaskModel.updateAtom_valuation_of_ne {F : TaskFrame} (M : TaskModel F)
    {p q : Atom} (h : q ≠ p) (S : Set F.WorldState) (w : F.WorldState) :
    (M.updateAtom p S).valuation w q ↔ M.valuation w q := by
  simp [TaskModel.updateAtom, h]

end FormalSystem.Semantics

namespace FormalSystem.QuantLanguage

open FormalSystem.Syntax
open FormalSystem.QuantLanguage.QuantFormula
open FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## The truth recursion -/

/--
Truth of a formula of the propositional-quantifier language at a model, world history and time,
relative to a family `Adm` of admissible propositions (sets of world states).

The six base clauses are `TruthAt`'s verbatim, the family inert. `all p φ` re-interprets the
letter `p` by each admissible set in turn.

Paper: — (formalization-native; the paper's languages have no propositional quantifiers)
-/
def QuantTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (Adm : Set (Set F.WorldState)) : QuantFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => QuantTruthAt M τ t Adm φ → QuantTruthAt M τ t Adm ψ
  | .box φ => ∀ σ : WorldHistory F, QuantTruthAt M σ t Adm φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧ QuantTruthAt M τ s Adm φ ∧
      ∀ u : F.Duration, t < u → u < s → QuantTruthAt M τ u Adm ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧ QuantTruthAt M τ s Adm φ ∧
      ∀ u : F.Duration, s < u → u < t → QuantTruthAt M τ u Adm ψ
  | .all p φ => ∀ S, S ∈ Adm → QuantTruthAt (M.updateAtom p S) τ t Adm φ

/-! ### The abstract clause layer, instantiated

The instances of `Semantics/TruthClauses.lean`. The language keeps the base language's five
primitive operators, so it instantiates the `untl` tier and inherits every derived-operator clause
lemma, with the admissible family as the inert environment. The quantifier has no abstract tier —
it is the one clause that changes the model — and gets its clause lemma directly below. -/

/-- The pointed truth relation of the quantifier language; the environment is the admissible
family. -/
instance : TruthEnv QuantFormula where
  Env F := Set (Set F.WorldState)
  T M τ t Adm φ := QuantTruthAt M τ t Adm φ

/-- The five inherited primitive operators and their clauses. -/
instance : UntlClauses QuantFormula where
  bot := QuantFormula.bot
  imp := QuantFormula.imp
  box := QuantFormula.box
  untl := QuantFormula.untl
  snce := QuantFormula.snce
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  untl_clause _ _ _ _ _ _ := Iff.rfl
  snce_clause _ _ _ _ _ _ := Iff.rfl

namespace QuantTruth

/-! ### Clause lemmas -/

variable (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (Adm : Set (Set F.WorldState))

theorem atom_iff (p : Atom) :
    QuantTruthAt M τ t Adm (.atom p) ↔ M.valuation (τ.state t) p := Iff.rfl

theorem imp_iff (φ ψ : QuantFormula) :
    QuantTruthAt M τ t Adm (.imp φ ψ) ↔
      (QuantTruthAt M τ t Adm φ → QuantTruthAt M τ t Adm ψ) := Iff.rfl

theorem box_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (.box φ) ↔ ∀ σ : WorldHistory F, QuantTruthAt M σ t Adm φ := Iff.rfl

/-- The quantifier clause: `∀p φ` re-interprets `p` by every admissible set. -/
theorem all_iff (p : Atom) (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (.all p φ) ↔
      ∀ S, S ∈ Adm → QuantTruthAt (M.updateAtom p S) τ t Adm φ := Iff.rfl

theorem neg_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (neg φ) ↔ ¬ QuantTruthAt M τ t Adm φ :=
  TruthClauses.neg_iff (L := QuantFormula) M τ t Adm φ

theorem and_iff (φ ψ : QuantFormula) :
    QuantTruthAt M τ t Adm (and φ ψ) ↔ QuantTruthAt M τ t Adm φ ∧ QuantTruthAt M τ t Adm ψ :=
  TruthClauses.and_iff (L := QuantFormula) M τ t Adm φ ψ

theorem or_iff (φ ψ : QuantFormula) :
    QuantTruthAt M τ t Adm (or φ ψ) ↔ QuantTruthAt M τ t Adm φ ∨ QuantTruthAt M τ t Adm ψ :=
  TruthClauses.or_iff (L := QuantFormula) M τ t Adm φ ψ

theorem someFuture_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (someFuture φ) ↔ ∃ s, t < s ∧ QuantTruthAt M τ s Adm φ :=
  TruthClauses.someFuture_iff (L := QuantFormula) M τ t Adm φ

theorem somePast_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (somePast φ) ↔ ∃ s, s < t ∧ QuantTruthAt M τ s Adm φ :=
  TruthClauses.somePast_iff (L := QuantFormula) M τ t Adm φ

theorem allFuture_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (allFuture φ) ↔ ∀ s, t < s → QuantTruthAt M τ s Adm φ :=
  TruthClauses.allFuture_iff (L := QuantFormula) M τ t Adm φ

theorem allPast_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (allPast φ) ↔ ∀ s, s < t → QuantTruthAt M τ s Adm φ :=
  TruthClauses.allPast_iff (L := QuantFormula) M τ t Adm φ

/-- Truth of `△φ` in three-conjunct form: past, present, future. -/
theorem always_iff_tri (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (always φ) ↔
      (∀ s : F.Duration, s < t → QuantTruthAt M τ s Adm φ) ∧ QuantTruthAt M τ t Adm φ ∧
        (∀ s : F.Duration, t < s → QuantTruthAt M τ s Adm φ) :=
  TruthClauses.always_iff_tri (L := QuantFormula) M τ t Adm φ

/-- **The universal modality**: `A φ := □△φ` holds iff `φ` holds at every history and every time.
`□` reaches every history at the present time and `△` every time of it; nothing is left out
because a world history is total. -/
theorem univ_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (univ φ) ↔
      ∀ (σ : WorldHistory F) (s : F.Duration), QuantTruthAt M σ s Adm φ := by
  rw [univ, box_iff]
  constructor
  · intro h σ s
    obtain ⟨hP, hφ, hF⟩ := (always_iff_tri M σ t Adm φ).mp (h σ)
    rcases lt_trichotomy s t with hlt | rfl | hgt
    · exact hP s hlt
    · exact hφ
    · exact hF s hgt
  · intro h σ
    exact (always_iff_tri M σ t Adm φ).mpr ⟨fun s _ => h σ s, h σ t, fun s _ => h σ s⟩

/-- `E φ := ¬A¬φ` holds iff `φ` holds at some history and time. -/
theorem exist_iff (φ : QuantFormula) :
    QuantTruthAt M τ t Adm (exist φ) ↔
      ∃ (σ : WorldHistory F) (s : F.Duration), QuantTruthAt M σ s Adm φ := by
  rw [exist, neg_iff, univ_iff]
  constructor
  · intro h
    by_contra hc
    exact h fun σ s => (neg_iff M σ s Adm φ).mpr fun hφ => hc ⟨σ, s, hφ⟩
  · rintro ⟨σ, s, hφ⟩ h
    exact (neg_iff M σ s Adm φ).mp (h σ s) hφ

end QuantTruth

open QuantTruth

/-! ## Truth-level conservativity over L -/

/--
**The truth-transfer bridge.** A formula of the base language embedded into the quantifier
language is true exactly when it is true in L, at the same model, history and time, whatever the
admissible family.

By induction on `φ`, generalizing the history and the time. Every case is congruence, because the
six base clauses of `QuantTruthAt` are `TruthAt`'s verbatim and `ofFormula` is
constructor-to-constructor; the image of `ofFormula` contains no `all`, so neither the admissible
family nor `updateAtom` is ever consulted.

Paper: — (formalization-native; the paper's languages have no propositional quantifiers)
-/
theorem quantTruthAt_ofFormula (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (Adm : Set (Set F.WorldState)) (φ : Formula) :
    QuantTruthAt M τ t Adm (QuantFormula.ofFormula φ) ↔ TruthAt M τ t φ := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun u => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ u)
  | snce ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun u => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ u)

end FormalSystem.QuantLanguage
