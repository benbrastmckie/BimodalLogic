/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Plus.AxiomValidity
import FormalSystem.Metalogic.Independence.NaiveSystem

/-!
# Coarsened-state models: a non-standard semantics for `⊡`

A **coarsened-state model** interprets the stability modal over a *quotient* of the world states:

```
M, τ, t ⊨ ⊡φ   iff   M, σ, t ⊨ φ for every world history σ with π(σ(t)) = π(τ(t)),
```

for a map `π` on world states whose fibres the valuation cannot see. Taking `π` the identity
recovers the standard semantics of `Semantics/PlusLanguage/PlusTruth.lean`; taking it strictly coarser makes
`⟨τ⟩_t` a *union* of exact-state classes.

## Why a non-standard semantics is unavoidable here

The two pasting axioms `paste` (PS) and `untl_paste` (US) are valid on **every** task frame
(`Semantics/PlusLanguage/PlusPasting.lean`), because the splice of two world histories through a common state
is again a world history — that is exactly what *Compositionality* buys. So no ordinary task
model can witness their underivability, and the independence argument has to move to a semantics
in which the splice is unavailable. Coarsening does precisely that: two histories in the same
`π`-class at `t` may pass through *different* states there, and there is then no single state for
a splice to pass through.

## What survives the coarsening, and what does not

| Schema | Coarsened status | Why |
|---|---|---|
| every TM schema | valid | atomization: `⊡_π χ` is still a state formula, so `Atomization.lean`'s route applies verbatim |
| SK `⊡(φ→ψ) → (⊡φ→⊡ψ)` | valid | universal-quantifier shape |
| ST `⊡φ → φ` | valid | `π`-agreement is reflexive |
| S4, S5 | valid | `π`-agreement is an equivalence |
| MS `□φ → ⊡φ` | valid | the `π`-class is a subset of all world histories |
| AS `p → ⊡p` | valid | the valuation is `π`-invariant by fiat (`atom_inv`) |
| **PS, US** | **refutable** | `Metalogic/Independence/PastingIndependence.lean` |

That table *is* the independence argument: the naive system's every axiom and every rule
preserves coarsened validity, and the two pasting schemata do not.

## Design

The recursion `CTruthAt` differs from `PlusTruthAt` in the `stab` clause alone; the six L clauses
are copied verbatim, which is what lets the atomization transfer and the `truth_congr_ext` /
time-shift ports go through as near-literal copies with the state equation `τ(t) = σ(t)` replaced
by its `π`-image `SameUnder`.

## Main Definitions

- `CoarseModel` — a task model together with the coarsening `π` and its atom-invariance
- `SameUnder` — `σ ∈ ⟨τ⟩^π_t`
- `CTruthAt`, `CValid`

## Main Results

- `c_truth_congr_ext`, `cTruthAt_timeShift`, `c_stab_state_only` — the three structural ports
- `cTruthAt_iff_atomize` — the atomization transfer, whence `cValid_of_tm` /
  `cValid_swap_of_tm`
- `naiveAxiom_cValid`, `naiveAxiom_cValid_swap` — every naive schema is coarsely valid at
  `.Base`, one arm per constructor
- `naive_cValid` — **naive soundness**: `NaiveDerivable .Base [] φ → CValid φ`

## References

* `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` — the standard recursion being varied
* `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean` — the transfer being mirrored

## Tags

independence · semantics · plus-language · stability-modal · pasting
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open FormalSystem.Metalogic
open FormalSystem.Metalogic.Conservativity

variable {F : TaskFrame}

/-! ## Coarsened models -/

/--
A **coarsened-state model**: a task model on `F`, a map `π` from world states to a class type,
and the requirement that the valuation cannot separate states in the same `π`-fibre.

`atom_inv` is stated as an implication rather than a biconditional; the biconditional follows by
applying it in both directions (`atom_inv_iff`).
-/
structure CoarseModel (F : TaskFrame) where
  /-- The underlying task model. -/
  toModel : TaskModel F
  /-- The type of coarsening classes. -/
  Cls : Type
  /-- The coarsening map. -/
  π : F.WorldState → Cls
  /-- The valuation cannot separate states in the same fibre. -/
  atom_inv : ∀ {w u : F.WorldState}, π w = π u → ∀ p, toModel.valuation w p →
    toModel.valuation u p

/-- The biconditional form of `atom_inv`. -/
theorem CoarseModel.atom_inv_iff (K : CoarseModel F) {w u : F.WorldState} (h : K.π w = K.π u)
    (p : Atom) : K.toModel.valuation w p ↔ K.toModel.valuation u p :=
  ⟨K.atom_inv h p, K.atom_inv h.symm p⟩

/-- `σ ∈ ⟨τ⟩^π_t`: the two histories' world states at `t` lie in the same `π`-fibre. The
coarsened analogue of the state equation `τ.state t = σ.state t`, and literally that equation when
`π` is injective. -/
def SameUnder (K : CoarseModel F) (τ σ : WorldHistory F) (t : F.Duration) : Prop :=
  K.π (τ.state t) = K.π (σ.state t)

theorem SameUnder.refl (K : CoarseModel F) (τ : WorldHistory F) (t : F.Duration) :
    SameUnder K τ τ t := rfl

theorem SameUnder.symm {K : CoarseModel F} {τ σ : WorldHistory F} {t : F.Duration}
    (h : SameUnder K τ σ t) : SameUnder K σ τ t := Eq.symm h

theorem SameUnder.trans {K : CoarseModel F} {τ σ ρ : WorldHistory F} {t : F.Duration}
    (h₁ : SameUnder K τ σ t) (h₂ : SameUnder K σ ρ t) : SameUnder K τ ρ t :=
  Eq.trans h₁ h₂

/-- `⟨·⟩^π` commutes with time shift; `Iff.rfl`, exactly as for the state equation. -/
theorem sameUnder_timeShift (K : CoarseModel F) (τ σ : WorldHistory F) (t Δ : F.Duration) :
    SameUnder K (τ.timeShift Δ) (σ.timeShift Δ) t ↔ SameUnder K τ σ (t + Δ) := Iff.rfl

/-! ## The coarsened truth recursion -/

/--
Truth of an L⁺ formula in a coarsened-state model. The six L clauses are `PlusTruthAt`'s
verbatim; the `stab` clause quantifies over the world histories in the current `π`-class rather
than the current exact-state class.
-/
def CTruthAt (K : CoarseModel F) (τ : WorldHistory F) (t : F.Duration) : PlusFormula → Prop
  | .atom p => K.toModel.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => CTruthAt K τ t φ → CTruthAt K τ t ψ
  | .box φ => ∀ σ : WorldHistory F, CTruthAt K σ t φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧ CTruthAt K τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → CTruthAt K τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧ CTruthAt K τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → CTruthAt K τ r ψ
  | .stab φ => ∀ σ : WorldHistory F, SameUnder K τ σ t → CTruthAt K σ t φ

namespace CTruth

variable (K : CoarseModel F) (τ : WorldHistory F) (t : F.Duration)

theorem atom_iff (p : Atom) :
    CTruthAt K τ t (.atom p) ↔ K.toModel.valuation (τ.state t) p :=
  Iff.rfl

@[simp] theorem bot_false : ¬ CTruthAt K τ t .bot := fun h => h

theorem imp_iff (φ ψ : PlusFormula) :
    CTruthAt K τ t (.imp φ ψ) ↔ (CTruthAt K τ t φ → CTruthAt K τ t ψ) := Iff.rfl

theorem box_iff (φ : PlusFormula) :
    CTruthAt K τ t (.box φ) ↔ ∀ σ : WorldHistory F, CTruthAt K σ t φ := Iff.rfl

theorem stab_iff (φ : PlusFormula) :
    CTruthAt K τ t (.stab φ) ↔
      ∀ σ : WorldHistory F, SameUnder K τ σ t → CTruthAt K σ t φ := Iff.rfl

theorem top_true : CTruthAt K τ t top := fun h => h

theorem neg_iff (φ : PlusFormula) : CTruthAt K τ t (neg φ) ↔ ¬ CTruthAt K τ t φ := Iff.rfl

theorem and_iff (φ ψ : PlusFormula) :
    CTruthAt K τ t (φ.and ψ) ↔ CTruthAt K τ t φ ∧ CTruthAt K τ t ψ := by
  simp [PlusFormula.and, neg, CTruthAt]

/-- `⟐φ` in a coarsened model: some world history of the current `π`-class satisfies `φ`. -/
theorem dstab_iff (φ : PlusFormula) :
    CTruthAt K τ t (dstab φ) ↔
      ∃ σ : WorldHistory F, SameUnder K τ σ t ∧ CTruthAt K σ t φ := by
  simp [dstab, neg, CTruthAt]

theorem someFuture_iff (φ : PlusFormula) :
    CTruthAt K τ t (someFuture φ) ↔ ∃ s, t < s ∧ CTruthAt K τ s φ := by
  simp [someFuture, top, CTruthAt]

theorem somePast_iff (φ : PlusFormula) :
    CTruthAt K τ t (somePast φ) ↔ ∃ s, s < t ∧ CTruthAt K τ s φ := by
  simp [somePast, top, CTruthAt]

theorem allFuture_iff (φ : PlusFormula) :
    CTruthAt K τ t (allFuture φ) ↔ ∀ s, t < s → CTruthAt K τ s φ := by
  simp [allFuture, someFuture, neg, top, CTruthAt]

theorem allPast_iff (φ : PlusFormula) :
    CTruthAt K τ t (allPast φ) ↔ ∀ s, s < t → CTruthAt K τ s φ := by
  simp [allPast, somePast, neg, top, CTruthAt]

end CTruth

open CTruth

/-! ## The three structural ports

Each is the corresponding lemma of `Semantics/PlusLanguage/PlusTruth.lean` with the state equation
replaced by `SameUnder`; only the `stab` case differs, and there only by an application of `K.π`
to both sides of the state equation. -/

/-- Pointwise-equal histories satisfy the same L⁺ formulas in a coarsened model. Port of
`Semantics.truth_congr_ext`. -/
theorem c_truth_congr_ext (K : CoarseModel F) (φ : PlusFormula) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), (∀ s, τ.state s = σ.state s) →
      (CTruthAt K τ t φ ↔ CTruthAt K σ t φ) := by
  induction φ with
  | atom p =>
    intro τ σ t hs
    show K.toModel.valuation _ p ↔ K.toModel.valuation _ p
    rw [hs t]
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
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (congrArg K.π (hs t)).symm.trans h, fun h => (congrArg K.π (hs t)).trans h⟩

/-- Coarsened L⁺ truth commutes with time shift. Port of `Semantics.plusTruthAt_timeShift`. -/
theorem cTruthAt_timeShift (K : CoarseModel F) (φ : PlusFormula) :
    ∀ (σ : WorldHistory F) (t Δ : F.Duration),
      CTruthAt K (σ.timeShift Δ) t φ ↔ CTruthAt K σ (t + Δ) φ := by
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
      exact (c_truth_congr_ext K φ _ ρ t
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
      have hs' : SameUnder K σ (ρ.timeShift (-Δ)) (t + Δ) :=
        Eq.trans (hs : K.π (σ.state (t + Δ)) = K.π (ρ.state t))
          (congrArg K.π (congrArg ρ.state (add_neg_cancel_right t Δ).symm :
            ρ.state t = ρ.state (t + Δ + -Δ)))
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ).mpr (h (ρ.timeShift (-Δ)) hs')
      exact (c_truth_congr_ext K φ _ ρ t
        (fun s => (congrArg ρ.state (add_neg_cancel_right s Δ) :
          ρ.state (s + Δ + -Δ) = ρ.state s))).mp h1

/-- The truth of `⊡φ` at `(τ, t)` depends only on the `⟨·⟩^π_t`-class of `τ`. Port of
`Semantics.stab_congr_state`. -/
theorem c_stab_congr_sameUnder (K : CoarseModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (h : SameUnder K τ σ t) (φ : PlusFormula) :
    CTruthAt K τ t (.stab φ) ↔ CTruthAt K σ t (.stab φ) :=
  ⟨fun hτs ρ hρ => hτs ρ (Eq.trans h hρ), fun hσs ρ hρ => hσs ρ (Eq.trans h.symm hρ)⟩

/-- **`⊡φ` depends on the world state alone**, in a coarsened model too: this is the lemma the
atomization transfer needs, and it is stated at *state equality* (which implies `π`-agreement),
so it has exactly the shape `Atomization.lean` consumes. Port of `Semantics.stab_state_only`. -/
theorem c_stab_state_only (K : CoarseModel F) (τ σ : WorldHistory F) (t s : F.Duration)
    (h : τ.state t = σ.state s) (φ : PlusFormula) :
    CTruthAt K τ t (.stab φ) ↔ CTruthAt K σ s (.stab φ) := by
  have hsame : SameUnder K τ (σ.timeShift (s - t)) t :=
    congrArg K.π (h.trans (congrArg σ.state (add_sub_cancel t s).symm))
  rw [c_stab_congr_sameUnder K τ (σ.timeShift (s - t)) t hsame φ,
    cTruthAt_timeShift, add_sub_cancel]


/-! ## The atomization transfer

The coarsened `⊡` is still a *state* formula (`c_stab_state_only`), which is the only property
`Conservativity/Plus/Atomization.lean`'s route uses. So the same construction applies verbatim:
replace each maximal `⊡χ` by a fresh atom, read it back in an L model on the same frame, and cite
the landed L schema validity. -/

/-- The L model on `K`'s frame reading the encoded atoms back, with `e.ι (inr χ)` interpreted by
the **coarsened** `⊡χ`. Well defined as a state property by `c_stab_state_only`. -/
def CoarseModel.atomModel (K : CoarseModel F) (e : Encoding) : TaskModel F where
  valuation w a :=
    (∃ p, e.ι (.inl p) = a ∧ K.toModel.valuation w p) ∨
    (∃ χ, e.ι (.inr χ) = a ∧ ∃ (τ : WorldHistory F) (t : F.Duration),
      τ.state t = w ∧ CTruthAt K τ t (.stab χ))

/-- **The transfer lemma for coarsened models.** Port of
`Conservativity.plusTruthAt_iff_atomize`; the `stab` case is `c_stab_state_only`. -/
theorem cTruthAt_iff_atomize (K : CoarseModel F) (e : Encoding) (φ : PlusFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      CTruthAt K τ t φ ↔ TruthAt (K.atomModel e) τ t (atomize e φ) := by
  induction φ with
  | atom p =>
    intro τ t
    constructor
    · intro hv
      exact Or.inl ⟨p, rfl, hv⟩
    · intro hv
      rcases hv with ⟨p', hp, hv⟩ | ⟨χ, hχ, _⟩
      · cases Sum.inl.inj (e.inj hp)
        exact hv
      · exact absurd (e.inj hχ) Sum.inr_ne_inl
  | bot => intro τ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ t; exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih =>
    intro τ t
    exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab χ _ =>
    intro τ t
    constructor
    · intro h
      exact Or.inr ⟨χ, rfl, τ, t, rfl, h⟩
    · intro hv
      rcases hv with ⟨p, hp, _⟩ | ⟨χ', hχ, σ, s, hst, hs⟩
      · exact absurd (e.inj hp) Sum.inl_ne_inr
      · cases Sum.inr.inj (e.inj hχ)
        exact (c_stab_state_only K σ τ s t hst χ).mp hs

/-! ## Coarsened validity -/

/-- Validity over **every** coarsened-state model, on every task frame: the notion the naive
system is sound for. There is no frame-class parameter — the argument is run at `.Base`, which is
where the two pasting schemata sit. -/
def CValid (φ : PlusFormula) : Prop :=
  ∀ (F : TaskFrame) (K : CoarseModel F) (τ : WorldHistory F) (t : F.Duration), CTruthAt K τ t φ

/-- **TM schema soundness over coarsened models**: the atomization of `φ` being a `.Base`-admissible
TM axiom instance makes `φ` coarsely valid. -/
theorem cValid_of_tm (e : Encoding) (φ : PlusFormula) (ax : Axiom (atomize e φ))
    (h : ax.minFrameClass ≤ FrameClass.Base) : CValid φ :=
  fun F K τ t => (cTruthAt_iff_atomize K e φ τ t).mpr
    (axiom_validIn ax h F trivial (K.atomModel e) τ t)

/-- The swap form, via `atomize_swapTemporal` at the conjugated encoding. -/
theorem cValid_swap_of_tm (e : Encoding) (φ : PlusFormula) (ax : Axiom (atomize e.swap φ))
    (h : ax.minFrameClass ≤ FrameClass.Base) : CValid φ.swapTemporal :=
  fun F K τ t => (cTruthAt_iff_atomize K e φ.swapTemporal τ t).mpr
    (by
      rw [atomize_swapTemporal]
      exact axiom_swap_validIn ax h F trivial (K.atomModel e) τ t)

/-! ## The six naive `⊡` schemata are coarsely valid

Each is the corresponding definitional validity of `Semantics/PlusLanguage/PlusTruth.lean`, re-run against
`SameUnder` in place of the state equation. AS is the one that consumes `atom_inv`. -/

/-- SK: the universal-quantifier shape of the coarsened `stab` clause. -/
theorem cValid_stab_k (φ ψ : PlusFormula) :
    CValid ((PlusFormula.stab (φ.imp ψ)).imp ((PlusFormula.stab φ).imp (PlusFormula.stab ψ))) :=
  fun _ _ _ _ h1 h2 σ hs => h1 σ hs (h2 σ hs)

/-- ST: reflexivity of `π`-agreement. -/
theorem cValid_stab_t (φ : PlusFormula) : CValid ((PlusFormula.stab φ).imp φ) :=
  fun _ K τ t h => h τ (SameUnder.refl K τ t)

/-- S4: transitivity of `π`-agreement. -/
theorem cValid_stab_4 (φ : PlusFormula) :
    CValid ((PlusFormula.stab φ).imp (PlusFormula.stab (PlusFormula.stab φ))) := by
  intro F K τ t h σ hσsame ρ hρsame
  exact h ρ (hσsame.trans hρsame)

/-- S5: symmetry together with transitivity of `π`-agreement. -/
theorem cValid_stab_5 (φ : PlusFormula) :
    CValid ((dstab φ).imp (PlusFormula.stab (dstab φ))) := by
  intro F K τ t h σ hσsame hstab
  apply h
  intro ρ hρsame
  exact hstab ρ (hσsame.symm.trans hρsame)

/-- MS: the `π`-class is a subset of all world histories. -/
theorem cValid_box_stab (φ : PlusFormula) :
    CValid ((PlusFormula.box φ).imp (PlusFormula.stab φ)) :=
  fun _ _ _ _ h σ _ => h σ

/-- AS: `atom_inv` — the valuation cannot separate states in the same `π`-fibre. -/
theorem cValid_atom_stab (p : Atom) :
    CValid ((PlusFormula.atom p).imp (PlusFormula.stab (PlusFormula.atom p))) := by
  intro F K τ t h σ hs
  exact K.atom_inv hs p h

/-! ## The dispatch

One arm per `PlusAxiom` constructor, with no wildcard: a constructor added to `PlusAxiom` fails
the build here until its arm is supplied. The eight non-`.Base` TM arms are eliminated by the
frame-class hypothesis (`hb : ax.minFrameClass ≤ .Base` is `False` for them), and the two pasting
arms by the naivety hypothesis — which is the whole content of the independence argument. -/

/-- **Every naive TM⁺ schema admissible at `.Base` is coarsely valid.** -/
theorem naiveAxiom_cValid {φ : PlusFormula} (ax : PlusAxiom φ) (hn : PlusAxiom.IsNaive ax)
    (hb : ax.minFrameClass ≤ FrameClass.Base) : CValid φ := by
  cases ax with
  | prop_k a0 a1 a2 =>
    exact cValid_of_tm theEncoding _ (Axiom.prop_k (A a0) (A a1) (A a2)) (by trivial)
  | prop_s a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.prop_s (A a0) (A a1)) (by trivial)
  | ex_falso a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.ex_falso (A a0)) (by trivial)
  | peirce a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.peirce (A a0) (A a1)) (by trivial)
  | modal_t a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.modal_t (A a0)) (by trivial)
  | modal_4 a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.modal_4 (A a0)) (by trivial)
  | modal_b a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.modal_b (A a0)) (by trivial)
  | modal_5_collapse a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.modal_5_collapse (A a0)) (by trivial)
  | modal_k_dist a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.modal_k_dist (A a0) (A a1)) (by trivial)
  | serial_future =>
    exact cValid_of_tm theEncoding _ (Axiom.serial_future) (by trivial)
  | serial_past =>
    exact cValid_of_tm theEncoding _ (Axiom.serial_past) (by trivial)
  | left_mono_until_G a0 a1 a2 =>
    exact cValid_of_tm theEncoding _ (Axiom.left_mono_until_G (A a0) (A a1) (A a2)) (by trivial)
  | left_mono_since_H a0 a1 a2 =>
    exact cValid_of_tm theEncoding _ (Axiom.left_mono_since_H (A a0) (A a1) (A a2)) (by trivial)
  | right_mono_until a0 a1 a2 =>
    exact cValid_of_tm theEncoding _ (Axiom.right_mono_until (A a0) (A a1) (A a2)) (by trivial)
  | right_mono_since a0 a1 a2 =>
    exact cValid_of_tm theEncoding _ (Axiom.right_mono_since (A a0) (A a1) (A a2)) (by trivial)
  | connect_future a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.connect_future (A a0)) (by trivial)
  | connect_past a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.connect_past (A a0)) (by trivial)
  | enrichment_until a0 a1 a2 =>
    exact cValid_of_tm theEncoding _ (Axiom.enrichment_until (A a0) (A a1) (A a2)) (by trivial)
  | enrichment_since a0 a1 a2 =>
    exact cValid_of_tm theEncoding _ (Axiom.enrichment_since (A a0) (A a1) (A a2)) (by trivial)
  | self_accum_until a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.self_accum_until (A a0) (A a1)) (by trivial)
  | self_accum_since a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.self_accum_since (A a0) (A a1)) (by trivial)
  | absorb_until a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.absorb_until (A a0) (A a1)) (by trivial)
  | absorb_since a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.absorb_since (A a0) (A a1)) (by trivial)
  | linear_until a0 a1 a2 a3 =>
    exact cValid_of_tm theEncoding _ (Axiom.linear_until (A a0) (A a1) (A a2) (A a3)) (by trivial)
  | linear_since a0 a1 a2 a3 =>
    exact cValid_of_tm theEncoding _ (Axiom.linear_since (A a0) (A a1) (A a2) (A a3)) (by trivial)
  | until_F a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.until_F (A a0) (A a1)) (by trivial)
  | since_P a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.since_P (A a0) (A a1)) (by trivial)
  | temp_linearity a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.temp_linearity (A a0) (A a1)) (by trivial)
  | temp_linearity_past a0 a1 =>
    exact cValid_of_tm theEncoding _ (Axiom.temp_linearity_past (A a0) (A a1)) (by trivial)
  | F_until_equiv a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.F_until_equiv (A a0)) (by trivial)
  | P_since_equiv a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.P_since_equiv (A a0)) (by trivial)
  | modal_future a0 =>
    exact cValid_of_tm theEncoding _ (Axiom.modal_future (A a0)) (by trivial)
  | discrete_symm_fwd =>
    exact cValid_of_tm theEncoding _ (Axiom.discrete_symm_fwd) (by trivial)
  | discrete_symm_bwd =>
    exact cValid_of_tm theEncoding _ (Axiom.discrete_symm_bwd) (by trivial)
  | discrete_propagate_fwd =>
    exact cValid_of_tm theEncoding _ (Axiom.discrete_propagate_fwd) (by trivial)
  | discrete_propagate_bwd =>
    exact cValid_of_tm theEncoding _ (Axiom.discrete_propagate_bwd) (by trivial)
  | discrete_box_necessity =>
    exact cValid_of_tm theEncoding _ (Axiom.discrete_box_necessity) (by trivial)
  | prior_UZ a0 => exact hb.elim
  | prior_SZ a0 => exact hb.elim
  | z1 a0 => exact hb.elim
  | density a0 => exact hb.elim
  | dense_indicator => exact hb.elim
  | prior_U_gap a0 => exact hb.elim
  | prior_S_gap a0 => exact hb.elim
  | sep a0 => exact hb.elim
  | stab_k a0 a1 => exact cValid_stab_k a0 a1
  | stab_t a0 => exact cValid_stab_t a0
  | stab_4 a0 => exact cValid_stab_4 a0
  | stab_5 a0 => exact cValid_stab_5 a0
  | box_stab a0 => exact cValid_box_stab a0
  | atom_stab p => exact cValid_atom_stab p
  | paste a0 a1 h0 h1 => exact hn.elim
  | untl_paste a0 a1 h0 h1 => exact hn.elim

/-- **The temporal dual of every naive TM⁺ schema admissible at `.Base` is coarsely valid.** The
six `⊡` arms need no separate argument: `swapTemporal` fixes `⊡`, so each of their duals is an
instance of the same schema at swapped parameters. -/
theorem naiveAxiom_cValid_swap {φ : PlusFormula} (ax : PlusAxiom φ) (hn : PlusAxiom.IsNaive ax)
    (hb : ax.minFrameClass ≤ FrameClass.Base) : CValid φ.swapTemporal := by
  cases ax with
  | prop_k a0 a1 a2 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.prop_k (A' a0) (A' a1) (A' a2)) (by trivial)
  | prop_s a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.prop_s (A' a0) (A' a1)) (by trivial)
  | ex_falso a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.ex_falso (A' a0)) (by trivial)
  | peirce a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.peirce (A' a0) (A' a1)) (by trivial)
  | modal_t a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.modal_t (A' a0)) (by trivial)
  | modal_4 a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.modal_4 (A' a0)) (by trivial)
  | modal_b a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.modal_b (A' a0)) (by trivial)
  | modal_5_collapse a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.modal_5_collapse (A' a0)) (by trivial)
  | modal_k_dist a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.modal_k_dist (A' a0) (A' a1)) (by trivial)
  | serial_future =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.serial_future) (by trivial)
  | serial_past =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.serial_past) (by trivial)
  | left_mono_until_G a0 a1 a2 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.left_mono_until_G (A' a0) (A' a1) (A' a2)) (by trivial)
  | left_mono_since_H a0 a1 a2 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.left_mono_since_H (A' a0) (A' a1) (A' a2)) (by trivial)
  | right_mono_until a0 a1 a2 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.right_mono_until (A' a0) (A' a1) (A' a2)) (by trivial)
  | right_mono_since a0 a1 a2 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.right_mono_since (A' a0) (A' a1) (A' a2)) (by trivial)
  | connect_future a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.connect_future (A' a0)) (by trivial)
  | connect_past a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.connect_past (A' a0)) (by trivial)
  | enrichment_until a0 a1 a2 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.enrichment_until (A' a0) (A' a1) (A' a2)) (by trivial)
  | enrichment_since a0 a1 a2 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.enrichment_since (A' a0) (A' a1) (A' a2)) (by trivial)
  | self_accum_until a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.self_accum_until (A' a0) (A' a1)) (by trivial)
  | self_accum_since a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.self_accum_since (A' a0) (A' a1)) (by trivial)
  | absorb_until a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.absorb_until (A' a0) (A' a1)) (by trivial)
  | absorb_since a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.absorb_since (A' a0) (A' a1)) (by trivial)
  | linear_until a0 a1 a2 a3 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.linear_until (A' a0) (A' a1) (A' a2) (A' a3)) (by trivial)
  | linear_since a0 a1 a2 a3 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.linear_since (A' a0) (A' a1) (A' a2) (A' a3)) (by trivial)
  | until_F a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.until_F (A' a0) (A' a1)) (by trivial)
  | since_P a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.since_P (A' a0) (A' a1)) (by trivial)
  | temp_linearity a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.temp_linearity (A' a0) (A' a1)) (by trivial)
  | temp_linearity_past a0 a1 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.temp_linearity_past (A' a0) (A' a1)) (by trivial)
  | F_until_equiv a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.F_until_equiv (A' a0)) (by trivial)
  | P_since_equiv a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.P_since_equiv (A' a0)) (by trivial)
  | modal_future a0 =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.modal_future (A' a0)) (by trivial)
  | discrete_symm_fwd =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.discrete_symm_fwd) (by trivial)
  | discrete_symm_bwd =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.discrete_symm_bwd) (by trivial)
  | discrete_propagate_fwd =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.discrete_propagate_fwd) (by trivial)
  | discrete_propagate_bwd =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.discrete_propagate_bwd) (by trivial)
  | discrete_box_necessity =>
    exact cValid_swap_of_tm theEncoding _ (Axiom.discrete_box_necessity) (by trivial)
  | prior_UZ a0 => exact hb.elim
  | prior_SZ a0 => exact hb.elim
  | z1 a0 => exact hb.elim
  | density a0 => exact hb.elim
  | dense_indicator => exact hb.elim
  | prior_U_gap a0 => exact hb.elim
  | prior_S_gap a0 => exact hb.elim
  | sep a0 => exact hb.elim
  | stab_k a0 a1 => exact cValid_stab_k a0.swapTemporal a1.swapTemporal
  | stab_t a0 => exact cValid_stab_t a0.swapTemporal
  | stab_4 a0 => exact cValid_stab_4 a0.swapTemporal
  | stab_5 a0 => exact cValid_stab_5 a0.swapTemporal
  | box_stab a0 => exact cValid_box_stab a0.swapTemporal
  | atom_stab p => exact cValid_atom_stab p
  | paste a0 a1 h0 h1 => exact hn.elim
  | untl_paste a0 a1 h0 h1 => exact hn.elim

/-! ## Naive soundness -/

/-- `ofWeakeningNil` preserves naivety: it only transports along an equality of contexts. -/
theorem naiveOnly_ofWeakeningNil {fc : FrameClass} {Γ' : PlusContext} {φ : PlusFormula}
    (d : PlusDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : PlusContext))
    (hn : d.NaiveOnly) : (d.ofWeakeningNil h_sub).NaiveOnly := by
  have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
  subst h_eq
  exact hn

/--
**The companion recursion for naive soundness.** A naive-only theorem of TM⁺ at `.Base` is
coarsely valid, and so is its temporal dual. Mirror of
`Conservativity.plus_derivable_valid_and_swap_validIn`, arm for arm; well-founded on the
derivation's height for the same reason.
-/
theorem naive_cValid_and_swap {φ : PlusFormula} (d : PlusDerivationTree FrameClass.Base [] φ)
    (hn : d.NaiveOnly) : CValid φ ∧ CValid φ.swapTemporal := by
  match d, hn with
  | .axiom _ _ h_ax h_fc, hn =>
    exact ⟨naiveAxiom_cValid h_ax hn h_fc, naiveAxiom_cValid_swap h_ax hn h_fc⟩
  | .assumption _ _ h_mem, _ =>
    exact absurd h_mem List.not_mem_nil
  | .modus_ponens _ psi' _ d1 d2, hn =>
    have h1 := naive_cValid_and_swap d1 hn.1
    have h2 := naive_cValid_and_swap d2 hn.2
    exact ⟨fun F K τ t => (h1.1 F K τ t) (h2.1 F K τ t),
      fun F K τ t => (h1.2 F K τ t) (h2.2 F K τ t)⟩
  | .necessitation psi' d', hn =>
    have h := naive_cValid_and_swap d' hn
    exact ⟨fun F K _ t σ => h.1 F K σ t, fun F K _ t σ => h.2 F K σ t⟩
  | .temporal_necessitation psi' d', hn =>
    have h := naive_cValid_and_swap d' hn
    constructor
    · intro F K τ t
      rw [CTruth.allFuture_iff]
      intro s _
      exact h.1 F K τ s
    · intro F K τ t
      rw [swap_temporal_all_future, CTruth.allPast_iff]
      intro s _
      exact h.2 F K τ s
  | .temporal_duality psi' d', hn =>
    have h := naive_cValid_and_swap d' hn
    refine ⟨h.2, ?_⟩
    rw [swap_temporal_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub, hn =>
    have h_term := PlusDerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact naive_cValid_and_swap (d'.ofWeakeningNil h_sub)
      (naiveOnly_ofWeakeningNil d' h_sub hn)
termination_by d.height
decreasing_by
  all_goals first
    | exact PlusDerivationTree.mp_height_gt_left _ _
    | exact PlusDerivationTree.mp_height_gt_right _ _
    | omega
    | simp only [PlusDerivationTree.height]; omega

/--
**Naive soundness.** Every theorem of TM⁺ with the two pasting axioms withheld is valid in every
coarsened-state model.

This is the tool the independence result uses: exhibit one coarsened model refuting a pasting
instance, and that instance cannot be naively derivable.

Paper: — (formalization-native; the naive `⊡`-set and the coarsened semantics are this tree's
own, with no paper counterpart)
-/
theorem naive_cValid {φ : PlusFormula} (h : NaiveDerivable FrameClass.Base [] φ) : CValid φ :=
  h.elim fun d hn => (naive_cValid_and_swap d hn).1

/-- The contrapositive, in the shape a refutation consumes. -/
theorem not_naiveDerivable_of_cRefuted {φ : PlusFormula} (F : TaskFrame) (K : CoarseModel F)
    (τ : WorldHistory F) (t : F.Duration) (h : ¬ CTruthAt K τ t φ) :
    ¬ NaiveDerivable FrameClass.Base [] φ :=
  fun hd => h (naive_cValid hd F K τ t)

end FormalSystem.Metalogic.Independence
