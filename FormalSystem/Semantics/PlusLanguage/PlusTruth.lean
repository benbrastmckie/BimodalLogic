/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Syntax.PlusLanguage.Formula
import FormalSystem.Semantics.TruthClauses

/-!
# `PlusTruthAt` — truth for the language L⁺ (L plus the stability modal `⊡`)

The native truth recursion for `PlusFormula` (`FormalSystem/PlusLanguage/Formula.lean`): the six
L clauses are those of `TruthAt` (`Semantics/Truth.lean`) verbatim, and the seventh is the
paper's `($\Stability$)` clause, `def:BLstar-semantics`:

```
M,τ,x ⊨ ⊡φ   iff   M,σ,x ⊨ φ for all σ ∈ ⟨τ⟩_x,
```

where `⟨τ⟩_x := {σ ∈ H_F | σ(x) = τ(x)}` (line 1108) is the set of possible worlds that share
`τ`'s world state at `x`. Here `⟨τ⟩_x` is rendered on the nose: `σ : WorldHistory F` with the
state equation `τ.state x = σ.state x`.

## Main Definitions

- `PlusTruthAt M τ t φ` — the seven-clause truth recursion

## Main Results

- The `PlusTruth.*_iff` clause lemmas, mirroring `MinusTruth.*`
- The definitional validities of `⊡` (paper footnote, line 1118: "the monomodal logic of `⊡`
  is S5"; line 1119: `φ → ⊡φ` for non-temporal `φ`): `stab_of_box` (`□φ → ⊡φ`), `of_stab`
  (T), `stab_four` (4), `stab_five` (5). The atom-level `p → ⊡p` of the same footnote is **not**
  stated here: it is the `stateLocal_atom` instance of `stab_of_stateLocal`
  (`Semantics/PlusLanguage/PlusStateLocal.lean`), which proves `φ → ⊡φ` for every formula of the
  state-locality fragment
- `stab_congr_state`: `⊡φ` is a state formula at each time; `box_stab_iff` (`□⊡φ ↔ □φ`),
  `stab_box_of_box` (`□φ → ⊡□φ`)
- `plusTruthAt_timeShift`: L⁺ truth commutes with time shift (the `PlusFormula` twin of
  `timeShift_preserves_truth`, proved directly because `TruthCorr` is `Formula`-only)
- `stab_state_only`: `⊡φ` depends on the world state **alone**, at any two times — the fact that
  licenses treating each `⊡χ` as a fresh state-valued atom
  (`Metalogic/Conservativity/Plus/Atomization.lean`)

## Provenance

Every result here is a transcription into repository style of the compiled stability-modal
probes recorded with the research on the `⊡` axiomatization (Parts A, B and E of that probes
file); proofs are unchanged.

## References

* JPL paper `possible_worlds.tex` lines 1108, 1114, 1118-1119, 1121
* `FormalSystem/Semantics/Truth.lean` — the six L clauses being mirrored
* `FormalSystem/Semantics/MinusLanguage/MinusTruth.lean` — the sibling native recursion for the base language

## Tags

truth · plus-language · stability-modal
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open scoped Classical

variable {F : TaskFrame}

/-! ## The truth recursion -/

/--
Truth of an L⁺ formula at a model, world history and time.

The six L clauses are `TruthAt`'s verbatim (`Semantics/Truth.lean`). The `stab` clause is the
paper's `($\Stability$)` clause of `def:BLstar-semantics`: `⊡φ` holds at `(τ, t)` iff `φ` holds at
`(σ, t)` for every world history `σ` with `τ.state t = σ.state t` — i.e. every `σ ∈ ⟨τ⟩_t`
(paper line 1108).
-/
def PlusTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : PlusFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => PlusTruthAt M τ t φ → PlusTruthAt M τ t ψ
  | .box φ => ∀ σ : WorldHistory F, PlusTruthAt M σ t φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧ PlusTruthAt M τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → PlusTruthAt M τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧ PlusTruthAt M τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → PlusTruthAt M τ r ψ
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ

/-! ### The abstract clause layer, instantiated

L⁺'s instances of `Semantics/TruthClauses.lean`. L⁺ adds the stability modal to L's six clauses,
so it instantiates the `stab` tier and inherits `dstab_iff` on top of everything L gets. -/

/-- L⁺'s pointed truth relation, with the trivial environment. -/
instance : TruthEnv PlusFormula where
  Env _ := PUnit
  T M τ t _ φ := PlusTruthAt M τ t φ

/-- L⁺'s six primitive operators and their clauses: L's five plus the stability modal. -/
instance : StabClauses PlusFormula where
  bot := PlusFormula.bot
  imp := PlusFormula.imp
  box := PlusFormula.box
  untl := PlusFormula.untl
  snce := PlusFormula.snce
  stab := PlusFormula.stab
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  untl_clause _ _ _ _ _ _ := Iff.rfl
  snce_clause _ _ _ _ _ _ := Iff.rfl
  stab_clause _ _ _ _ _ := Iff.rfl

namespace PlusTruth

/-! ### Clause lemmas, mirroring `MinusTruth.*` -/

variable (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)

theorem atom_iff (p : Atom) :
    PlusTruthAt M τ t (.atom p) ↔ M.valuation (τ.state t) p := Iff.rfl

@[simp] theorem bot_false : ¬ PlusTruthAt M τ t .bot := fun h => h

theorem imp_iff (φ ψ : PlusFormula) :
    PlusTruthAt M τ t (.imp φ ψ) ↔ (PlusTruthAt M τ t φ → PlusTruthAt M τ t ψ) := Iff.rfl

theorem box_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (.box φ) ↔ ∀ σ : WorldHistory F, PlusTruthAt M σ t φ := Iff.rfl

theorem untl_iff (ψ φ : PlusFormula) :
    PlusTruthAt M τ t (.untl ψ φ) ↔ ∃ s, t < s ∧ PlusTruthAt M τ s φ ∧
      ∀ r, t < r → r < s → PlusTruthAt M τ r ψ := Iff.rfl

theorem snce_iff (ψ φ : PlusFormula) :
    PlusTruthAt M τ t (.snce ψ φ) ↔ ∃ s, s < t ∧ PlusTruthAt M τ s φ ∧
      ∀ r, s < r → r < t → PlusTruthAt M τ r ψ := Iff.rfl

theorem stab_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ := Iff.rfl

theorem top_true : PlusTruthAt M τ t top :=
  TruthClauses.top_true (L := PlusFormula) M τ t PUnit.unit

theorem neg_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (neg φ) ↔ ¬ PlusTruthAt M τ t φ :=
  TruthClauses.neg_iff (L := PlusFormula) M τ t PUnit.unit φ

theorem and_iff (φ ψ : PlusFormula) :
    PlusTruthAt M τ t (φ.and ψ) ↔ PlusTruthAt M τ t φ ∧ PlusTruthAt M τ t ψ :=
  TruthClauses.and_iff (L := PlusFormula) M τ t PUnit.unit φ ψ

theorem or_iff (φ ψ : PlusFormula) :
    PlusTruthAt M τ t (φ.or ψ) ↔ PlusTruthAt M τ t φ ∨ PlusTruthAt M τ t ψ :=
  TruthClauses.or_iff (L := PlusFormula) M τ t PUnit.unit φ ψ

/-- `⟐φ` (paper line 1121): some world history in `⟨τ⟩_t` satisfies `φ`. -/
theorem dstab_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (dstab φ) ↔
      ∃ σ : WorldHistory F, τ.state t = σ.state t ∧ PlusTruthAt M σ t φ :=
  TruthClauses.dstab_iff (L := PlusFormula) M τ t PUnit.unit φ

theorem someFuture_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (someFuture φ) ↔ ∃ s, t < s ∧ PlusTruthAt M τ s φ :=
  TruthClauses.someFuture_iff (L := PlusFormula) M τ t PUnit.unit φ

theorem allFuture_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (allFuture φ) ↔ ∀ s, t < s → PlusTruthAt M τ s φ :=
  TruthClauses.allFuture_iff (L := PlusFormula) M τ t PUnit.unit φ

theorem somePast_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (somePast φ) ↔ ∃ s, s < t ∧ PlusTruthAt M τ s φ :=
  TruthClauses.somePast_iff (L := PlusFormula) M τ t PUnit.unit φ

theorem allPast_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (allPast φ) ↔ ∀ s, s < t → PlusTruthAt M τ s φ :=
  TruthClauses.allPast_iff (L := PlusFormula) M τ t PUnit.unit φ

theorem diamond_iff (φ : PlusFormula) :
    PlusTruthAt M τ t (diamond φ) ↔ ∃ σ : WorldHistory F, PlusTruthAt M σ t φ :=
  TruthClauses.diamond_iff (L := PlusFormula) M τ t PUnit.unit φ

end PlusTruth

open PlusTruth

/-! ## The definitional validities of `⊡` (paper lines 1118-1119) -/

/-- **`□φ → ⊡φ`**: `⟨τ⟩_x ⊆ H_F` (paper line 1108). -/
theorem stab_of_box (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula)
    (h : PlusTruthAt M τ t (.box φ)) : PlusTruthAt M τ t (.stab φ) :=
  fun σ _ => h σ

/-- **T for `⊡`**: `⊡φ → φ` (`τ ∈ ⟨τ⟩_t`). -/
theorem of_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) (h : PlusTruthAt M τ t (.stab φ)) : PlusTruthAt M τ t φ :=
  h τ rfl

/-- **4 for `⊡`**: `⊡φ → ⊡⊡φ`, by transitivity of the state equation. -/
theorem stab_four (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) (h : PlusTruthAt M τ t (.stab φ)) :
    PlusTruthAt M τ t (.stab (.stab φ)) :=
  fun _ hσ ρ hρ => h ρ (hσ.trans hρ)

/-- **5 for `⊡`**: `¬⊡φ → ⊡¬⊡φ`, by symmetry and transitivity of the state equation. -/
theorem stab_five (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) (h : ¬ PlusTruthAt M τ t (.stab φ)) :
    PlusTruthAt M τ t (.stab (.imp (.stab φ) .bot)) :=
  fun _ hσ hstab => h fun ρ hρ => hstab ρ (hσ.symm.trans hρ)

/-! ## `⊡φ` is a state formula at each time; `□⊡ ↔ □`; `□ → ⊡□` -/

/-- The truth of `⊡φ` at `(τ, t)` depends only on the state of `τ` at `t`. -/
theorem stab_congr_state (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (h : τ.state t = σ.state t) (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔ PlusTruthAt M σ t (.stab φ) :=
  ⟨fun hτs ρ hρ => hτs ρ (h.trans hρ), fun hσs ρ hρ => hσs ρ (h.symm.trans hρ)⟩

/-- `□⊡φ ↔ □φ` semantically (derivable from K, T for `⊡`, 4 for `□`, and `□φ → ⊡φ`). -/
theorem box_stab_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    PlusTruthAt M τ t (.box (.stab φ)) ↔ PlusTruthAt M τ t (.box φ) :=
  ⟨fun h σ => h σ σ rfl, fun h _ ρ _ => h ρ⟩

/-- `□φ → ⊡□φ` (derivable from 4 for `□` and `□φ → ⊡φ`). -/
theorem stab_box_of_box (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula)
    (h : PlusTruthAt M τ t (.box φ)) : PlusTruthAt M τ t (.stab (.box φ)) :=
  fun _ _ => h

/-! ## Time-shift invariance: `⊡φ` depends on the world state alone -/

/-- World histories with the same state at every time satisfy the same L⁺ formulas. -/
theorem truth_congr_ext (M : TaskModel F) (φ : PlusFormula) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), (∀ s, τ.state s = σ.state s) →
      (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ) := by
  induction φ with
  | atom p => intro τ σ t hs; show M.valuation _ p ↔ M.valuation _ p; rw [hs t]
  | bot => intros; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ σ t hs; exact Iff.imp (ihφ τ σ t hs) (ihψ τ σ t hs)
  | box φ _ => intros; exact Iff.rfl
  | untl ψ φ ihψ ihφ =>
    intro τ σ t hs
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ τ σ s hs)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ σ r hs)
  | snce ψ φ ihψ ihφ =>
    intro τ σ t hs
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ τ σ s hs)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ σ r hs)
  | stab φ _ =>
    intro τ σ t hs
    exact forall_congr' fun ρ => imp_congr_left ⟨fun h => (hs t).symm.trans h,
      fun h => (hs t).trans h⟩

/-- **L⁺ truth commutes with time shift.** The `PlusFormula` twin of
`timeShift_preserves_truth`, proved directly because `TruthCorr` is `Formula`-only; the `box`
and `stab` cases need the inverse shift and `truth_congr_ext`, since `timeShift` is not
definitionally involutive. -/
theorem plusTruthAt_timeShift (M : TaskModel F) (φ : PlusFormula) :
    ∀ (σ : WorldHistory F) (t Δ : F.Duration),
      PlusTruthAt M (σ.timeShift Δ) t φ ↔ PlusTruthAt M σ (t + Δ) φ := by
  induction φ with
  | atom p => intros; exact Iff.rfl
  | bot => intros; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro σ t Δ; exact Iff.imp (ihφ σ t Δ) (ihψ σ t Δ)
  | box φ ih =>
    intro σ t Δ
    constructor
    · intro h ρ
      exact (ih ρ t Δ).mp (h (ρ.timeShift Δ))
    · intro h ρ
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ).mpr (h (ρ.timeShift (-Δ)))
      exact (truth_congr_ext M φ _ ρ t
        (fun s => (congrArg ρ.state (add_neg_cancel_right s Δ) :
          ρ.state (s + Δ + -Δ) = ρ.state s))).mp h1
  | untl ψ φ ihψ ihφ =>
    intro σ t Δ
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨s + Δ, (add_lt_add_iff_right Δ).mpr hts, (ihφ σ s Δ).mp hφ, ?_⟩
      intro r' h1 h2
      have := ihψ σ (r' - Δ) Δ
      rw [sub_add_cancel] at this
      exact this.mp (hψ (r' - Δ) (lt_sub_iff_add_lt.mpr h1) (sub_lt_iff_lt_add.mpr h2))
    · rintro ⟨s', h, hφ, hψ⟩
      refine ⟨s' - Δ, lt_sub_iff_add_lt.mpr h, ?_, ?_⟩
      · have := ihφ σ (s' - Δ) Δ
        rw [sub_add_cancel] at this
        exact this.mpr hφ
      · intro r htr hrs
        exact (ihψ σ r Δ).mpr
          (hψ (r + Δ) ((add_lt_add_iff_right Δ).mpr htr) (lt_sub_iff_add_lt.mp hrs))
  | snce ψ φ ihψ ihφ =>
    intro σ t Δ
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨s + Δ, (add_lt_add_iff_right Δ).mpr hst, (ihφ σ s Δ).mp hφ, ?_⟩
      intro r' h1 h2
      have := ihψ σ (r' - Δ) Δ
      rw [sub_add_cancel] at this
      exact this.mp (hψ (r' - Δ) (lt_sub_iff_add_lt.mpr h1) (sub_lt_iff_lt_add.mpr h2))
    · rintro ⟨s', h, hφ, hψ⟩
      refine ⟨s' - Δ, sub_lt_iff_lt_add.mpr h, ?_, ?_⟩
      · have := ihφ σ (s' - Δ) Δ
        rw [sub_add_cancel] at this
        exact this.mpr hφ
      · intro r hsr hrt
        exact (ihψ σ r Δ).mpr
          (hψ (r + Δ) (sub_lt_iff_lt_add.mp hsr) ((add_lt_add_iff_right Δ).mpr hrt))
  | stab φ ih =>
    intro σ t Δ
    constructor
    · intro h ρ hs
      exact (ih ρ t Δ).mp (h (ρ.timeShift Δ) hs)
    · intro h ρ hs
      have hs' : σ.state (t + Δ) = (ρ.timeShift (-Δ)).state (t + Δ) :=
        hs.trans (congrArg ρ.state (add_neg_cancel_right t Δ).symm)
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ).mpr (h (ρ.timeShift (-Δ)) hs')
      exact (truth_congr_ext M φ _ ρ t
        (fun s => (congrArg ρ.state (add_neg_cancel_right s Δ) :
          ρ.state (s + Δ + -Δ) = ρ.state s))).mp h1

/-- **`⊡φ` depends on the world state alone.** If `τ(t) = σ(s)` — at possibly different times —
then `⊡φ` has the same truth value at `(τ, t)` and `(σ, s)`. This is what licenses treating each
`⊡φ` as a fresh state-valued atom: the atomization route to TM-schema soundness over L⁺
(`Metalogic/Conservativity/Plus/Atomization.lean`). -/
theorem stab_state_only (M : TaskModel F) (τ σ : WorldHistory F) (t s : F.Duration)
    (h : τ.state t = σ.state s) (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔ PlusTruthAt M σ s (.stab φ) := by
  have hsame : τ.state t = (σ.timeShift (s - t)).state t :=
    h.trans (congrArg σ.state (add_sub_cancel t s).symm)
  rw [stab_congr_state M τ (σ.timeShift (s - t)) t hsame φ, plusTruthAt_timeShift,
    add_sub_cancel]

end FormalSystem.Semantics
