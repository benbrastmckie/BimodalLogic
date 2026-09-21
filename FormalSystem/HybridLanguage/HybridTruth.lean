/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TruthClauses
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.HybridLanguage.Formula

/-!
# `HybridTruthAt` — truth for the hybrid state language

The native truth recursion for `HybridFormula` (`FormalSystem/HybridLanguage/Formula.lean`),
relative to a **register vector** `r : ℕ → WorldState`. The seven L⁺ clauses are those of
`PlusTruthAt` (`PlusLanguage/PlusTruth.lean`) verbatim, with `r` threaded through unchanged, and
the three new ones are:

```
M,τ,x,r ⊨ [≡]φ   iff   M,σ,y,r ⊨ φ for all σ ∈ H_F and y ∈ D with σ(y) = τ(x),
M,τ,x,r ⊨ i      iff   τ(x) = r(i),
M,τ,x,r ⊨ ↓ᵢ φ   iff   M,τ,x,r[i ↦ τ(x)] ⊨ φ.
```

`[≡]` is `⊡` with the time freed: `⊡` ranges over the histories through the present state **at the
present time**, `[≡]` over the (history, time) pairs through it at any time. The register clause
is the only clause of the language that compares two world states for identity, and with the tense
operators it compares the states a single history occupies at two times.

## Main Definitions

- `HybridTruthAt M τ t r φ` — the ten-clause truth recursion

## Main Results

- The `HybridTruth.*_iff` clause lemmas, including `same_iff`, `reg_iff`, `bind_iff`, and
  `univ_iff` / `exist_iff`: `A φ` holds iff `φ` holds at **every** history and time, `E φ` iff at
  some
- `hybridTruthAt_ofPlus` — **truth-level conservativity over L⁺**: an L⁺ formula embedded into
  the hybrid state language is true exactly when it is true in L⁺, at the same model, history and
  time and at every register vector

## References

* JPL paper `def:BLstar-semantics` — `⟨τ⟩_x` and the `⊡` clause
* JPL paper `def:world-history` — world histories are total, which is what `univ_iff` uses
* `FormalSystem/PlusLanguage/PlusTruth.lean` — `PlusTruthAt`, whose seven clauses are copied
* `FormalSystem/Semantics/TruthClauses.lean` — the abstract clause layer instantiated here
* `FormalSystem/StarLanguage/StarTruth.lean` — the sibling recursion with a stored-time vector

## Tags

hybrid-language · truth · state-register · universal-modality · conservativity
-/

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.HybridLanguage.HybridFormula
open FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## The truth recursion -/

/--
Truth of a formula of the hybrid state language at a model, world history, time and register
vector.

The seven L⁺ clauses are `PlusTruthAt`'s verbatim, the register vector inert. `same` quantifies
over every (history, time) pair occupying the present world state; `reg i` tests the present world
state against the `i`-th stored one; `bind i` stores the present world state in register `i`.

Paper: — (formalization-native; the paper's registers of `sub:Extension` store times and worlds,
not world states)
-/
def HybridTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (r : ℕ → F.WorldState) : HybridFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => HybridTruthAt M τ t r φ → HybridTruthAt M τ t r ψ
  | .box φ => ∀ σ : WorldHistory F, HybridTruthAt M σ t r φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧ HybridTruthAt M τ s r φ ∧
      ∀ u : F.Duration, t < u → u < s → HybridTruthAt M τ u r ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧ HybridTruthAt M τ s r φ ∧
      ∀ u : F.Duration, s < u → u < t → HybridTruthAt M τ u r ψ
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → HybridTruthAt M σ t r φ
  | .same φ => ∀ (σ : WorldHistory F) (s : F.Duration), σ.state s = τ.state t →
      HybridTruthAt M σ s r φ
  | .reg i => τ.state t = r i
  | .bind i φ => HybridTruthAt M τ t (Function.update r i (τ.state t)) φ

/-! ### The abstract clause layer, instantiated

The instances of `Semantics/TruthClauses.lean`. The language keeps L⁺'s six primitive operators,
so it instantiates the `stab` tier and inherits every derived-operator clause lemma, with the
register vector as the inert environment. The three new operators have no abstract tier — `bind`
is the one clause that changes the environment — and get their clause lemmas directly below. -/

/-- The pointed truth relation of the hybrid state language; the environment is the register
vector. -/
instance : TruthEnv HybridFormula where
  Env F := ℕ → F.WorldState
  T M τ t r φ := HybridTruthAt M τ t r φ

/-- The six inherited primitive operators and their clauses. -/
instance : StabClauses HybridFormula where
  bot := HybridFormula.bot
  imp := HybridFormula.imp
  box := HybridFormula.box
  untl := HybridFormula.untl
  snce := HybridFormula.snce
  stab := HybridFormula.stab
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  untl_clause _ _ _ _ _ _ := Iff.rfl
  snce_clause _ _ _ _ _ _ := Iff.rfl
  stab_clause _ _ _ _ _ := Iff.rfl

namespace HybridTruth

/-! ### Clause lemmas -/

variable (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (r : ℕ → F.WorldState)

theorem atom_iff (p : Atom) :
    HybridTruthAt M τ t r (.atom p) ↔ M.valuation (τ.state t) p := Iff.rfl

theorem imp_iff (φ ψ : HybridFormula) :
    HybridTruthAt M τ t r (.imp φ ψ) ↔ (HybridTruthAt M τ t r φ → HybridTruthAt M τ t r ψ) :=
  Iff.rfl

theorem box_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (.box φ) ↔ ∀ σ : WorldHistory F, HybridTruthAt M σ t r φ := Iff.rfl

theorem stab_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (.stab φ) ↔
      ∀ σ : WorldHistory F, τ.state t = σ.state t → HybridTruthAt M σ t r φ := Iff.rfl

/-- The same-state clause: `[≡]φ` quantifies over every (history, time) pair occupying the
present world state. -/
theorem same_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (.same φ) ↔
      ∀ (σ : WorldHistory F) (s : F.Duration), σ.state s = τ.state t →
        HybridTruthAt M σ s r φ := Iff.rfl

/-- The register clause: the present world state is the `i`-th stored state. -/
theorem reg_iff (i : ℕ) : HybridTruthAt M τ t r (.reg i) ↔ τ.state t = r i := Iff.rfl

/-- The binder clause: store the present world state in register `i`. -/
theorem bind_iff (i : ℕ) (φ : HybridFormula) :
    HybridTruthAt M τ t r (.bind i φ) ↔
      HybridTruthAt M τ t (Function.update r i (τ.state t)) φ := Iff.rfl

theorem neg_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (neg φ) ↔ ¬ HybridTruthAt M τ t r φ :=
  TruthClauses.neg_iff (L := HybridFormula) M τ t r φ

theorem and_iff (φ ψ : HybridFormula) :
    HybridTruthAt M τ t r (and φ ψ) ↔ HybridTruthAt M τ t r φ ∧ HybridTruthAt M τ t r ψ :=
  TruthClauses.and_iff (L := HybridFormula) M τ t r φ ψ

theorem or_iff (φ ψ : HybridFormula) :
    HybridTruthAt M τ t r (or φ ψ) ↔ HybridTruthAt M τ t r φ ∨ HybridTruthAt M τ t r ψ :=
  TruthClauses.or_iff (L := HybridFormula) M τ t r φ ψ

theorem someFuture_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (someFuture φ) ↔ ∃ s, t < s ∧ HybridTruthAt M τ s r φ :=
  TruthClauses.someFuture_iff (L := HybridFormula) M τ t r φ

theorem somePast_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (somePast φ) ↔ ∃ s, s < t ∧ HybridTruthAt M τ s r φ :=
  TruthClauses.somePast_iff (L := HybridFormula) M τ t r φ

theorem allFuture_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (allFuture φ) ↔ ∀ s, t < s → HybridTruthAt M τ s r φ :=
  TruthClauses.allFuture_iff (L := HybridFormula) M τ t r φ

theorem allPast_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (allPast φ) ↔ ∀ s, s < t → HybridTruthAt M τ s r φ :=
  TruthClauses.allPast_iff (L := HybridFormula) M τ t r φ

/-- Truth of `△φ` in three-conjunct form: past, present, future. -/
theorem always_iff_tri (φ : HybridFormula) :
    HybridTruthAt M τ t r (always φ) ↔
      (∀ s : F.Duration, s < t → HybridTruthAt M τ s r φ) ∧ HybridTruthAt M τ t r φ ∧
        (∀ s : F.Duration, t < s → HybridTruthAt M τ s r φ) :=
  TruthClauses.always_iff_tri (L := HybridFormula) M τ t r φ

/-- `⟐φ`: some world through the present state at the present time satisfies `φ`. -/
theorem dstab_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (dstab φ) ↔
      ∃ σ : WorldHistory F, τ.state t = σ.state t ∧ HybridTruthAt M σ t r φ :=
  TruthClauses.dstab_iff (L := HybridFormula) M τ t r φ

/-- **The universal modality**: `A φ := □△φ` holds iff `φ` holds at every history and every time.
`□` reaches every history at the present time and `△` every time of it; nothing is left out
because a world history is total. -/
theorem univ_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (univ φ) ↔
      ∀ (σ : WorldHistory F) (s : F.Duration), HybridTruthAt M σ s r φ := by
  rw [univ, box_iff]
  constructor
  · intro h σ s
    obtain ⟨hP, hφ, hF⟩ := (always_iff_tri M σ t r φ).mp (h σ)
    rcases lt_trichotomy s t with hlt | rfl | hgt
    · exact hP s hlt
    · exact hφ
    · exact hF s hgt
  · intro h σ
    exact (always_iff_tri M σ t r φ).mpr ⟨fun s _ => h σ s, h σ t, fun s _ => h σ s⟩

/-- `E φ := ¬A¬φ` holds iff `φ` holds at some history and time. -/
theorem exist_iff (φ : HybridFormula) :
    HybridTruthAt M τ t r (exist φ) ↔
      ∃ (σ : WorldHistory F) (s : F.Duration), HybridTruthAt M σ s r φ := by
  rw [exist, neg_iff, univ_iff]
  constructor
  · intro h
    by_contra hc
    exact h fun σ s => (neg_iff M σ s r φ).mpr fun hφ => hc ⟨σ, s, hφ⟩
  · rintro ⟨σ, s, hφ⟩ h
    exact (neg_iff M σ s r φ).mp (h σ s) hφ

end HybridTruth

open HybridTruth

/-! ## Truth-level conservativity over L⁺ -/

/--
**The truth-transfer bridge.** An L⁺ formula embedded into the hybrid state language is true
exactly when it is true in L⁺, at the same model, history and time, whatever the register vector.

By induction on `φ`, generalizing the history and the time. Every case is congruence, because the
seven L⁺ clauses of `HybridTruthAt` are `PlusTruthAt`'s verbatim and `ofPlus` is
constructor-to-constructor; the register vector is inert because the image of `ofPlus` contains no
`reg`, `bind` or `same`.

Paper: — (formalization-native; the paper has no state registers)
-/
theorem hybridTruthAt_ofPlus (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (r : ℕ → F.WorldState) (φ : PlusFormula) :
    HybridTruthAt M τ t r (HybridFormula.ofPlus φ) ↔ PlusTruthAt M τ t φ := by
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
  | stab φ ih => exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t

end FormalSystem.HybridLanguage
