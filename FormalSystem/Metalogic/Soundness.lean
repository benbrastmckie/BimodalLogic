/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Derivable
import FormalSystem.Semantics.Validity
import FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants
import FormalSystem.Metalogic.SoundnessLemmas.Separability
import Mathlib.Data.Int.SuccPred

/-!
# Soundness - Soundness Theorem for TM Logic

This module proves the soundness theorem for bimodal logic TM.

## Paper Specification Reference

**Perpetuity Principles (`cor:perpetuity-valid`)**:
The JPL paper "The Construction of Possible Worlds" proves the perpetuity
principles valid over all task semantic models, using time-shift automorphisms.
Its own statement is "The perpetuity principles P1 -- P6 are all valid", derived
from `thm:TM-soundness` plus the derivations of P1 -- P6.

There is **no `app:valid` anchor**, and there never was: earlier revisions of this
module cited `app:valid` at "line 1984", which in the live paper is an unrelated
`Ddef` about operator interpretation. The citation and its line number were both
bogus; `cor:perpetuity-valid` is the live anchor that carries this content.

**Axiom Validity**:
All TM axioms (MT, M4, MB, T4, TA, TL, MF, TF) are proven valid over all
task semantic models. The MF and TF axioms use time-shift invariance
(following the JPL paper's approach) to establish unconditional validity.

## Main Results

- `prop_k_valid`, `prop_s_valid`: Propositional axioms are valid
- `modal_t_valid`: Modal T axiom is valid
- `modal_4_valid`: Modal 4 axiom is valid
- `modal_b_valid`: Modal B axiom is valid
- `modal_k_dist_valid`: Modal K distribution axiom is valid

- `temp_4_valid`: Temporal 4 axiom is valid
- `temp_a_valid`: Temporal A axiom is valid
- `temp_l_valid`: TL axiom is valid (uses always definition)
- `modal_future_valid`: MF axiom is valid (via time-shift invariance)
- `axiom_validIn`: every axiom is valid at any frame class its `minFrameClass` sits below
- `soundness_in`: **the** soundness theorem, parameterized by `FrameClass`
- `axiom_valid`, `axiom_dense_valid`, `axiom_discrete_valid`, `axiom_dedekind_valid`: the four
  per-class instances of `axiom_validIn`

## Implementation Notes

**Completed Proofs**:
- Base axiom validity lemmas: prop_k, prop_s, ex_falso, peirce, MT, M4, MB, M5_collapse,
  MK_dist, TK_dist, T4, TA, TL, MF, TF, linearity (universally valid)
- Frame-class axiom validity: density (ValidDense), discreteness_forward (ValidDiscrete)
- `axiom_validIn_min` (one arm per axiom constructor, each at that axiom's own
  `minFrameClass`), lifted by `ValidIn.mono` to `axiom_validIn` at an arbitrary class; the four
  `axiom_*_valid` names are one-line instances of it

**Key Techniques**:
- Time-shift invariance (MF, TF): Uses `WorldHistory.timeShift` and
  `TimeShift.time_shift_preserves_truth` to relate truth at different times
- Classical logic helpers for conjunction extraction (TL)
- Derivation-indexed induction for temporal duality soundness

**Totality Parameterization**:
Validity and semantic consequence quantify over the frame's **total** histories
(`τ.IsTotal`, the predicate form of `H_F` membership), matching `def:logical-consequence`.
There is no admissible-history parameter and no shift-closure side condition: totality is
preserved by `timeShift` (`WorldHistory.isTotal_timeShift`), so time-shift invariance carries
no hypothesis to quantify over. `TruthAt`'s remaining set argument is inert and is supplied
as `Set.univ`.

## Full Derivation Soundness

The induction over `DerivationTree` is written **once**, in `soundness_in`, at an arbitrary
`fc : FrameClass`. `DerivationTree` has exactly seven constructors
(`ProofSystem/Derivation.lean`). One case each:
1. **`axiom`**: `axiom_validIn`, at whatever `fc` the derivation is indexed by
2. **`assumption`**: the formula is in `Γ`, so the context hypothesis supplies it directly
3. **`modus_ponens`**: If `Γ ⊨ φ → ψ` and `Γ ⊨ φ` then `Γ ⊨ ψ` (semantic by definition)
4. **`necessitation`**: If `⊨ φ` then `⊨ □φ` (follows from S5 universal accessibility)
5. **`temporal_necessitation`**: If `⊨ φ` then `⊨ Gφ` (follows from temporal quantification)
6. **`temporal_duality`**: `derivable_valid_and_swap_validIn`, the companion recursion that
   proves validity and swap-validity simultaneously, again at an arbitrary `fc`
7. **`weakening`**: Monotonicity of semantic consequence

The `temporal_duality` case is where the four per-class proofs used to diverge, each reaching
for its own swap-validity recursion — one in `SoundnessLemmas/FrameClassVariants.lean` for
`.Base`, one there for `.Discrete`, a third for `.Dense` in a dense-specific module of its own,
and a fourth written out in this file for `.Dedekind`. Carrying the class as a parameter rather
than baking it into the statement collapses all four into the one arm above, and the four
superseded recursions have been removed.

There is no IRR rule in this proof system, and therefore no IRR case in this induction.
Reynolds' IRR rule is mentioned in `ProofSystem/Axioms.lean` only bibliographically, in the title
of his 1992 paper.

**Frame-Class Architecture**:
There is one soundness proof, `soundness_in`, indexed by `fc : FrameClass`. The named theorems
are its instances and keep their original statements exactly:
- `soundness`: derivations at `.Base`, on arbitrary frames
- `soundness_dense`: derivations at `.Dense`, on densely ordered frames
- `soundness_discrete`: derivations at `.Discrete`, on discrete frames
- `soundness_dedekind`: derivations at `.Dedekind`, on dense Dedekind-complete frames

Each supplies its class's `FrameClass.Sat` witness and nothing else: `trivial` at `.Base`, the
`DenselyOrdered` instance at `.Dense`, the four order instances at `.Discrete`, and the
density-plus-least-upper-bound pair at `.Dedekind`. All are sorry-free.

The class index is what keeps the axiom sets apart. Prior-UZ/SZ are excluded from dense
derivations by the `h.minFrameClass ≤ .Dense` gate on the axiom rule, their
`minFrameClass = .Discrete` being incomparable with `.Dense`; their validity on discrete frames
comes from `SoundnessLemmas`' well-founded descent on succ/pred chains, reached through
`axiom_validIn`.

## Soundness for the base language BL

The four theorems here are stated over `FormalSystem.Syntax.Formula`, the `untl`/`snce`-primitive
language BL⁺. Their counterparts for the tense-primitive base language BL live in
`FormalSystem/Metalogic/BaseLanguageSoundness.lean`: `bl_soundness`, `bl_soundness_dense`,
`bl_soundness_discrete` and `bl_soundness_dedekind`, each obtained by composing
`Metalogic/Conservativity.lean`'s `translate` with the theorem of the same frame class below,
then crossing the truth-transfer bridge `truthAt_tr` into the native BL semantics of
`Semantics/BLTruth.lean`. That module also carries the BL consistency corollaries
`bl_not_derivable_nil_bot` and `bl_not_derivable_nil_bot_discrete`, which mirror
`not_derivable_nil_bot` and `not_derivable_nil_bot_discrete` below — and inherit their
frame-class asymmetry, for the same reason: there is no dense or Dedekind-complete witness frame
in the tree.

## References

* [architecture.md](../../docs/user-guide/architecture.md) - Soundness specification
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
* [Validity.lean](../../Semantics/Validity.lean) - Semantic validity
* [SoundnessLemmas.lean](./SoundnessLemmas.lean) - Axiom validity and swap preservation
* JPL Paper `cor:perpetuity-valid` - Perpetuity principle validity proofs
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics

/-- Propositional K axiom is valid. -/
theorem prop_k_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt]
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/-- Propositional S axiom is valid. -/
theorem prop_s_valid (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt]
  intro h_phi _
  exact h_phi

/-- Modal T axiom is valid: `⊨ □φ → φ`. -/
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  refine valid.of_forall_total ?_
  intro F M τ hτ t
  simp only [TruthAt]
  intro h_box
  exact h_box τ hτ

/-- Modal 4 axiom is valid: `⊨ □φ → □□φ`. -/
theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt]
  intro h_box σ h_σ_mem ρ h_ρ_mem
  exact h_box ρ h_ρ_mem

/-- Modal B axiom is valid: `⊨ φ → □◇φ`. -/
theorem modal_b_valid (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := by
  refine valid.of_forall_total ?_
  intro F M τ hτ t
  simp only [Formula.diamond, Formula.neg]
  simp only [TruthAt]
  intro h_phi σ _h_σ_mem h_box_neg
  exact h_box_neg τ hτ h_phi

/-- Modal 5 Collapse axiom is valid: `⊨ ◇□φ → □φ`. -/
theorem modal_5_collapse_valid (φ : Formula) : ⊨ (φ.box.diamond.imp φ.box) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Formula.diamond, Formula.neg]
  simp only [TruthAt]
  intro h_diamond_box ρ h_ρ_mem
  by_contra h_not_phi
  apply h_diamond_box
  intro σ h_σ_mem h_box_at_sigma
  exact h_not_phi (h_box_at_sigma ρ h_ρ_mem)

/-- EFQ axiom is valid: `⊨ ⊥ → φ`. -/
theorem ex_falso_valid (φ : Formula) : ⊨ (Formula.bot.imp φ) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt]
  intro h_bot
  exfalso
  exact h_bot

/-- Peirce's Law is valid: `⊨ ((φ → ψ) → φ) → φ`. -/
theorem peirce_valid (φ ψ : Formula) : ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt]
  intro h_peirce
  by_cases h : TruthAt M τ t φ
  · exact h
  · have h_imp : TruthAt M τ t (φ.imp ψ) := by
      simp only [TruthAt]
      intro h_phi
      exfalso
      exact h h_phi
    exact h_peirce h_imp

/-- Modal K Distribution axiom is valid: `⊨ □(φ → ψ) → (□φ → □ψ)`. -/
theorem modal_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt]
  intro h_box_imp h_box_phi σ h_σ_mem
  exact h_box_imp σ h_σ_mem (h_box_phi σ h_σ_mem)

/-- Temporal K Distribution axiom is valid: `⊨ F(φ → ψ) → (Fφ → Fψ)`. -/
theorem temp_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff]
  intro h_future_imp h_future_phi s hts
  exact h_future_imp s hts (h_future_phi s hts)

/-- Temporal 4 axiom is valid: `⊨ Gφ → GGφ`.
Under strict semantics, uses transitivity of <. -/
theorem temp_4_valid (φ : Formula) : ⊨ ((φ.allFuture).imp (φ.allFuture.allFuture)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff]
  intro h_future s hts r hsr
  exact h_future r (lt_trans hts hsr)

/-- Serial future axiom is valid on nontrivial orders: `⊤ → F(⊤)`.
For any time t in a nontrivial ordered group, there exists s > t. -/
theorem serial_future_axiom_valid :
    ⊨ ((Formula.bot.imp Formula.bot).imp (Formula.someFuture (Formula.bot.imp Formula.bot))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_future_iff]
  intro _h_top
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, id⟩

/-- Serial past axiom is valid on nontrivial orders: `⊤ → P(⊤)`.
For any time t in a nontrivial ordered group, there exists s < t. -/
theorem serial_past_axiom_valid :
    ⊨ ((Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_past_iff]
  intro _h_top
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, id⟩

/-- Temporal A axiom is valid: `⊨ φ → G(Pφ)`.
Under strict semantics: if φ at t, then for all s > t, there exists r < s with φ(r) (namely, t). -/
theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.allFuture φ.somePast)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff, Truth.some_past_iff]
  intro h_phi s hts
  exact ⟨t, hts, h_phi⟩

/-- TL axiom validity: `△φ → G(Hφ)` is valid.
Under strict semantics, △φ = Hφ ∧ φ ∧ Gφ encodes: (∀ u < t, φ(u)) ∧ φ(t) ∧ (∀ v > t, φ(v)).
The goal G(Hφ) requires: ∀ s > t, ∀ r < s, φ(r).
This is implied by the △φ hypothesis which covers all times. -/
theorem temp_l_valid (φ : Formula) :
    ⊨ (φ.always.imp (Formula.allFuture (Formula.allPast φ))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.always_iff, Truth.future_iff, Truth.past_iff]
  exact fun h_always _ _ r _ => h_always r

/-- MF axiom validity: `□φ → □(Fφ)` is valid. Time-shift invariance carries no side condition:
totality of the shifted history is `WorldHistory.isTotal_timeShift`. -/
theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.allFuture).box)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff]
  intro h_box_phi σ h_σ_mem s hts
  have h_phi_at_shifted :=
    h_box_phi (WorldHistory.timeShift σ (s - t))
      (WorldHistory.isTotal_timeShift h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M σ t s φ).mp h_phi_at_shifted

/-- Temporal A Dual axiom is valid: `⊨ φ → H(Fφ)`.
Under strict semantics: if φ at t, then for all s < t, there exists r > s with φ(r) (namely, t). -/
theorem temp_a_dual_valid (φ : Formula) : ⊨ (φ.imp (Formula.allPast φ.someFuture)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.past_iff, Truth.some_future_iff]
  intro h_phi s hst
  exact ⟨t, hst, h_phi⟩

/-- Temporal linearity axiom validity:
`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)` is valid.

Uses linearity of D (LinearOrder instance).
Under strict semantics, F quantifies over s > t.
-/
theorem temp_linearity_valid (φ ψ : Formula) :
    ⊨ (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and φ ψ))
        (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
          (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.and_iff, Truth.or_iff, Truth.some_future_iff]
  rintro ⟨⟨s₁, hs₁t, hφ⟩, s₂, hs₂t, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inl ⟨s₁, hs₁t, hφ, s₂, h, hψ⟩)
  · exact .inl ⟨s₁, hs₁t, hφ, h ▸ hψ⟩
  · exact .inr (.inr ⟨s₂, hs₂t, ⟨s₁, h, hφ⟩, hψ⟩)

/-- Past temporal linearity axiom validity (BX11'):
`P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)` is valid.

Mirror of `temp_linearity_valid` for the past direction.
-/
theorem temp_linearity_past_valid (φ ψ : Formula) :
    ⊨ (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Formula.and, Formula.or, Formula.neg, TruthAt,
    Truth.some_past_iff]
  intro h_conj
  have h_P_phi : ∃ s, s < t ∧ TruthAt M τ s φ := by
    by_contra h_no
    exact h_conj (fun h1 _ => h_no h1)
  have h_P_psi : ∃ s, s < t ∧ TruthAt M τ s ψ := by
    by_contra h_no
    exact h_conj (fun _ h2 => h_no h2)
  obtain ⟨s1, hs1t, h_phi_s1⟩ := h_P_phi
  obtain ⟨s2, hs2t, h_psi_s2⟩ := h_P_psi
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: third disjunct P(P(φ) ∧ ψ)
    intro _; intro _
    exact ⟨s2, hs2t, fun h_imp => h_imp ⟨s1, h_lt, h_phi_s1⟩ h_psi_s2⟩
  · -- s1 = s2: first disjunct P(φ ∧ ψ)
    subst h_eq
    intro h_neg_first
    exfalso
    exact h_neg_first ⟨s1, hs1t, fun h_imp => h_imp h_phi_s1 h_psi_s2⟩
  · -- s2 < s1: second disjunct P(φ ∧ P(ψ))
    intro _
    intro h_neg_second
    exfalso
    exact h_neg_second ⟨s1, hs1t, fun h_imp => h_imp h_phi_s1 ⟨s2, h_gt, h_psi_s2⟩⟩

/-- F-Until equivalence axiom validity (BX12):
`F(φ) → (⊤ U φ)` is valid. Here ⊤ = ⊥ → ⊥.

If F(φ) holds at t, there exists s ≥ t with φ(s). Take this s as the Until witness.
The guard ⊤ is trivially satisfied on (t, s). -/
theorem F_until_equiv_valid (φ : Formula) :
    ⊨ ((Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, h_φs⟩
  exact ⟨s, hts, h_φs, fun _ _ _ => id⟩

/-- P-Since equivalence axiom validity (BX12'):
`P(φ) → S(φ, ⊤)` is valid. Past dual of F-Until equivalence. -/
theorem P_since_equiv_valid (φ : Formula) :
    ⊨ ((Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, h_φs⟩
  exact ⟨s, hst, h_φs, fun _ _ _ => id⟩

/-- Dense indicator axiom is valid on dense orders: `⊨_dense ¬U(⊤,⊥)`.
On a densely ordered frame, `U(⊤,⊥)` at t requires s > t with empty (t,s),
but `DenselyOrdered` provides r with t < r < s, contradiction. -/
theorem dense_indicator_valid :
    ValidDense (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg := by
  refine ValidIn.of_forall_total ?_
  intro F h_dense M τ _hτ t
  simp only [Formula.neg, TruthAt]
  intro ⟨s, hts, _h_top, h_guard⟩
  obtain ⟨r, htr, hrs⟩ := @DenselyOrdered.dense F.Duration _ h_dense t s hts
  exact h_guard r htr hrs

/-- Density axiom (DN) is valid on dense orders: `⊨_dense GGφ → Gφ`.
Under strict semantics: GGφ → Gφ requires DenselyOrdered. Given s > t,
find r with t < r < s by density, then h_GG(r)(s) gives φ(s). -/
theorem density_valid (φ : Formula) :
    ValidDense ((φ.allFuture.allFuture).imp φ.allFuture) := by
  refine ValidIn.of_forall_total ?_
  intro F h_dense M τ _hτ t
  simp only [TruthAt, Truth.future_iff]
  intro h_GG s hts
  -- h_GG : ∀ r > t, ∀ q > r, φ(q)
  -- hts : t < s
  -- By density, find r with t < r < s
  obtain ⟨r, htr, hrs⟩ := exists_between hts
  exact h_GG r htr s hrs

/-- Forward discreteness axiom (DF) is valid on discrete orders: `⊨_discrete (F⊤ ∧ φ ∧ Hφ) → F(Hφ)`.
Under strict semantics: if Hφ at t (∀r < t, φ(r)) and φ(t), then Hφ at succ(t),
since for all r < succ(t), either r < t (covered by Hφ) or r = t (covered by φ(t)).
So F(Hφ) at t is witnessed by succ(t). -/
theorem discreteness_forward_valid (φ : Formula) :
    ValidDiscrete (Formula.and (Formula.bot.neg.someFuture)
      (Formula.and φ (Formula.allPast φ)) |>.imp
      (Formula.allPast φ).someFuture) := by
  refine ValidIn.of_forall_total ?_
  intro F hF M τ _hτ t
  sat_intro hF
  simp only [Truth.imp_iff, Truth.and_iff, Truth.some_future_iff, Truth.past_iff]
  rintro ⟨-, h_phi, h_H⟩
  exact ⟨Order.succ t, Order.lt_succ_of_not_isMax (not_isMax t), fun r hr => by
    rcases lt_or_eq_of_le (Order.le_of_lt_succ hr) with h | h
    · exact h_H r h
    · exact h ▸ h_phi⟩

/-- Future seriality axiom validity: `⊨_discrete Gφ → Fφ`.
Under strict semantics: Gφ → Fφ requires NoMaxOrder. -/
theorem seriality_future_valid (φ : Formula) :
    ValidDiscrete (φ.allFuture.imp φ.someFuture) := by
  refine ValidIn.of_forall_total ?_
  intro F hF M τ _hτ t
  sat_intro hF
  simp only [TruthAt, Truth.future_iff, Truth.some_future_iff]
  intro h_G
  have : NoMaxOrder F.Duration := inferInstance
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, h_G s hts⟩

/-- Past seriality axiom validity: `⊨_discrete Hφ → Pφ`.
Under strict semantics: Hφ → Pφ requires NoMinOrder. -/
theorem seriality_past_valid (φ : Formula) :
    ValidDiscrete (φ.allPast.imp φ.somePast) := by
  refine ValidIn.of_forall_total ?_
  intro F hF M τ _hτ t
  sat_intro hF
  simp only [TruthAt, Truth.past_iff, Truth.some_past_iff]
  intro h_H
  have : NoMinOrder F.Duration := inferInstance
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, h_H s hst⟩

/-!
## BX2-BX7: Until/Since Axiom Validity

These lemmas prove validity of the Burgess-Xu axioms BX2-BX7 (and their Since mirrors)
on all linear temporal orders with reflexive Until/Since semantics.

**Note on BX4**: Our BX4 is temporal connectedness (`φ → G(P(φ))` and `φ → H(F(φ))`),
which is provably valid under open guard (t,s) semantics. The standard Burgess-Xu A3a
(`φ ∧ (χ U ψ) → χ U (ψ ∧ (χ S φ))`) IS also valid under open guard semantics --
the Until guard interval (t,s) provides the Since guard at the witness since both
intervals are identical. A3a is added separately as BX13 (enrichment_until/since).

Recall the reflexive semantics:
- `φ U ψ` at `t`: ∃ s ≥ t, ψ(s) ∧ ∀ r, t ≤ r < s → φ(r)
- `φ S ψ` at `t`: ∃ s ≤ t, ψ(s) ∧ ∀ r, s < r ≤ t → φ(r)
- `G(φ)` at `t`: ∀ s ≥ t, φ(s)
- `H(φ)` at `t`: ∀ s ≤ t, φ(s)
-/

/-- BX2G: Left monotonicity of Until under G: `G(φ→χ) → ((φ U ψ) → (χ U ψ))`.
Under open guard (t,s): G(φ→χ) gives (φ→χ) at all r > t, covering guard interval (t,s).
No pointwise condition at t needed since the guard is the open interval (t,s). -/
theorem left_mono_until_G_valid (φ χ ψ : Formula) :
    ⊨ ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff]
  intro h_G ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, h_event, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩

/-- BX2H: Left monotonicity of Since under H: `H(φ→χ) → ((φ S ψ) → (χ S ψ))`.
Under open guard (s,t): H(φ→χ) gives (φ→χ) at all r < t, covering guard interval (s,t).
No pointwise condition at t needed since the guard is the open interval (s,t). -/
theorem left_mono_since_H_valid (φ χ ψ : Formula) :
    ⊨ ((φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.past_iff]
  intro h_H ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, h_event, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩

/-- BX3: Right monotonicity of Until: `G(φ → ψ) → ((χ U φ) → (χ U ψ))`.
Same witness s; φ(s) and (φ → ψ)(s) give ψ(s). Guard is unchanged. -/
theorem right_mono_until_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp ψ).allFuture.imp ((Formula.untl χ φ).imp (Formula.untl χ ψ))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff]
  intro h_G ⟨s, hts, h_φs, h_guard⟩
  exact ⟨s, hts, h_G s hts h_φs, h_guard⟩

/-- BX3': Right monotonicity of Since: `H(φ → ψ) → ((χ S φ) → (χ S ψ))`. -/
theorem right_mono_since_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.past_iff]
  intro h_H ⟨s, hst, h_φs, h_guard⟩
  exact ⟨s, hst, h_H s hst h_φs, h_guard⟩

/-- BX4: Temporal connectedness (future): `φ → G(P(φ))`.
If φ holds now, then at all future times, P(φ) holds.
Proof: for any s ≥ t, P(φ)(s) = ¬H(¬φ)(s) = ¬∀w ≤ s.¬φ(w). Take w = t: t ≤ s, φ(t). -/
theorem connect_future_valid (φ : Formula) :
    ⊨ (φ.imp (φ.somePast.allFuture)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff, Truth.some_past_iff]
  intro h_φt s hts
  exact ⟨t, hts, h_φt⟩

/-- BX4': Temporal connectedness (past): `φ → H(F(φ))`.
If φ holds now, then at all past times, F(φ) holds.
Proof: for any s ≤ t, F(φ)(s) = ¬G(¬φ)(s) = ¬∀w ≥ s.¬φ(w). Take w = t: t ≥ s, φ(t). -/
theorem connect_past_valid (φ : Formula) :
    ⊨ (φ.imp (φ.someFuture.allPast)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.past_iff, Truth.some_future_iff]
  intro h_φt s hst
  exact ⟨t, hst, h_φt⟩

/-- BX13: Until-Since enrichment (Burgess A3a, Xu axiom (3)):
`p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))`.
Valid under open guard (t,s): given p(t) and untl(φ, ψ) at t with witness s > t,
ψ(s), and φ on (t,s). Take same witness s for the conclusion.
- ψ(s) holds (from hypothesis).
- snce(φ, p)(s): take u = t as Since witness. t < s, p(t), and φ on (t,s) = the Until guard.
- Guard φ on (t,s): same as the hypothesis guard. -/
theorem enrichment_until_valid (φ ψ p : Formula) :
    ⊨ (Formula.and p (Formula.untl φ ψ) |>.imp
      (Formula.untl φ (Formula.and ψ (Formula.snce φ p)))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.and_iff, Truth.untl_iff, Truth.snce_iff]
  rintro ⟨h_pt, s, hts, h_ψs, h_guard⟩
  exact ⟨s, hts, ⟨h_ψs, t, hts, h_pt, h_guard⟩, h_guard⟩

/-- BX13': Since-Until enrichment (Burgess A3b, Xu axiom (4)):
`p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))`.
Mirror of enrichment_until for the Since direction. -/
theorem enrichment_since_valid (φ ψ p : Formula) :
    ⊨ (Formula.and p (Formula.snce φ ψ) |>.imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.and_iff, Truth.untl_iff, Truth.snce_iff]
  rintro ⟨h_pt, s, hst, h_ψs, h_guard⟩
  exact ⟨s, hst, ⟨h_ψs, t, hst, h_pt, h_guard⟩, h_guard⟩

/-- BX5: Self-accumulation of Until: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`.
Given φ U ψ with witness s ≥ t: same witness s. Endpoint ψ(s) is unchanged.
Guard at r ∈ (t, s): need φ(r) ∧ (φ U ψ)(r).
φ(r) comes from original guard. (φ U ψ)(r) uses same witness s:
ψ(s), and guard ∀ q ∈ (r, s) is a subset of (t, s). -/
theorem self_accum_until_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl φ ψ).imp
      (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
  exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs⟩

/-- BX5': Self-accumulation of Since: `(φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)`. -/
theorem self_accum_since_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce φ ψ).imp
      (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
  exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩

theorem absorb_until_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.and_iff, Truth.untl_iff]
  rintro ⟨s₁, hts₁, ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  -- Witness s₂ for the result. Guard covers (t, s₂) via three zones.
  refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
  rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
  · exact h_guard₁ q htq h_lt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q h_gt hqs₂

/-- BX6': Absorption of Since: `(φ S (φ ∧ (φ S ψ))) → (φ S ψ)`. -/
theorem absorb_since_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.and_iff, Truth.snce_iff]
  rintro ⟨s₁, hs₁t, ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
  rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
  · exact h_guard₂ q hs₂q h_lt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₁ q h_gt hqt

/-- BX7: Linearity of Until:
`(φ U ψ) ∧ (χ U θ) → ((φ ∧ χ) U (ψ ∧ θ)) ∨ ((φ ∧ χ) U (ψ ∧ χ)) ∨ ((φ ∧ χ) U (φ ∧ θ))`.
Given witnesses s1 for φ U ψ and s2 for χ U θ, by linearity s1 ≤ s2 or s2 ≤ s1 or s1 = s2.
- s1 = s2: first disjunct with witness s1.
- s1 < s2: second disjunct with witness s1 (ψ(s1) ∧ χ(s1) where χ(s1) from χ U θ guard).
- s2 < s1: third disjunct with witness s2 (φ(s2) ∧ θ(s2) where φ(s2) from φ U ψ guard). -/
theorem linear_until_valid (φ ψ χ θ : Formula) :
    ⊨ (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.untl (Formula.and φ χ) (Formula.and φ θ)))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.and_iff, Truth.or_iff, Truth.untl_iff]
  rintro ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · -- s₁ < s₂: second disjunct with witness s₁ (ψ(s₁) ∧ χ(s₁))
    exact .inl (.inr ⟨s₁, hts₁, ⟨h_ψs₁, h_guard₂ s₁ hts₁ h_lt⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (lt_trans hrs h_lt)⟩⟩)
  · -- s₁ = s₂: first disjunct with witness s₁ (ψ(s₁) ∧ θ(s₁))
    exact .inl (.inl ⟨s₁, hts₁, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (h_eq ▸ hrs)⟩⟩)
  · -- s₂ < s₁: third disjunct with witness s₂ (φ(s₂) ∧ θ(s₂))
    exact .inr ⟨s₂, hts₂, ⟨h_guard₁ s₂ hts₂ h_gt, h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr (lt_trans hrs h_gt), h_guard₂ r htr hrs⟩⟩

theorem linear_since_valid (φ ψ χ θ : Formula) :
    ⊨ (Formula.and (Formula.snce φ ψ) (Formula.snce χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.snce (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.snce (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.snce (Formula.and φ χ) (Formula.and φ θ)))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [Truth.imp_iff, Truth.and_iff, Truth.or_iff, Truth.snce_iff]
  rintro ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · -- s₁ < s₂ < t: third disjunct (φ∧χ) S (φ∧θ) with witness s₂
    exact .inr ⟨s₂, hs₂t, ⟨h_guard₁ s₂ h_lt hs₂t, h_θs₂⟩,
      fun r hs₂r hrt => ⟨h_guard₁ r (lt_trans h_lt hs₂r) hrt, h_guard₂ r hs₂r hrt⟩⟩
  · -- s₁ = s₂: first disjunct (φ∧χ) S (ψ∧θ) with witness s₁
    exact .inl (.inl ⟨s₁, hs₁t, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (h_eq ▸ hs₁r) hrt⟩⟩)
  · -- s₂ < s₁ < t: second disjunct (φ∧χ) S (ψ∧χ) with witness s₁
    exact .inl (.inr ⟨s₁, hs₁t, ⟨h_ψs₁, h_guard₂ s₁ h_gt hs₁t⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (lt_trans h_gt hs₁r) hrt⟩⟩)

/-- BX10: Until implies eventuality: `(φ U ψ) → F(ψ)`.
F(ψ) = ¬G(¬ψ). Under reflexive Until, witness s ≥ t gives ψ(s), so ¬∀u≥t.¬ψ(u). -/
theorem until_F_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl φ ψ).imp (Formula.someFuture ψ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, h_ψs, _⟩
  exact ⟨s, hts, h_ψs⟩

/-- BX10': Since implies past eventuality: `(φ S ψ) → P(ψ)`.
P(ψ) = ¬H(¬ψ). Under reflexive Since, witness s ≤ t gives ψ(s), so ¬∀u≤t.¬ψ(u). -/
theorem since_P_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce φ ψ).imp (Formula.somePast ψ)) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, h_ψs, _⟩
  exact ⟨s, hst, h_ψs⟩

/-! ## Uniformity Axiom Validity

The following four axioms encode the uniformity of discreteness in ordered abelian groups.
They are valid over ALL `AddCommGroup D` with `IsOrderedAddMonoid D` because the
group's translation invariance ensures that gaps (empty open intervals) are uniform
across all time points.

Key semantic fact: `TruthAt M τ t (Formula.untl bot (bot.imp bot))` means
∃ s > t with (t,s) empty in D. The guard `bot` is always False, so no element can
lie in (t,s). The event `bot.imp bot` is `⊤` which is always True.
-/

/-- Discrete symmetry forward: U(⊤,⊥) → S(⊤,⊥).
If there is a gap (t, s) with s > t, then (t-(s-t), t) is also empty by translation. -/
theorem discrete_symm_fwd_valid :
    ⊨ ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.snce Formula.bot (Formula.bot.imp Formula.bot))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  exact fun h => (Truth.truthAt_gap_iff_cogap M τ t).mp h

/-- Discrete symmetry backward: S(⊤,⊥) → U(⊤,⊥).
If there is a gap (r, t) with r < t, then (t, t+(t-r)) is also empty by translation. -/
theorem discrete_symm_bwd_valid :
    ⊨ ((Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  exact fun h => (Truth.truthAt_gap_iff_cogap M τ t).mpr h

/-- Discrete propagation forward: U(⊤,⊥) → G(U(⊤,⊥)).
If there is a gap (t, s), then for any u > t, (u, u+(s-t)) is also empty. -/
theorem discrete_propagate_fwd_valid :
    ⊨ ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  exact fun h => (Truth.future_iff _).mpr fun u _ => Truth.truthAt_gap_shift M τ t u h

/-- Discrete propagation backward: U(⊤,⊥) → H(U(⊤,⊥)).
If there is a gap (t, s), then for any u < t, (u, u+(s-t)) is also empty. -/
theorem discrete_propagate_bwd_valid :
    ⊨ ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  exact fun h => (Truth.past_iff _).mpr fun u _ => Truth.truthAt_gap_shift M τ t u h

/-- Discrete box necessity: U(⊤,⊥) → □(U(⊤,⊥)).
If there is a gap (t, s) at history τ, then for any total history σ,
the same gap exists (truth of U(⊤,⊥) depends only on D's order, not on τ). -/
theorem discrete_box_necessity_valid :
    ⊨ ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.box (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  exact fun h σ _ => (Truth.truthAt_atomFree_history_indep M _ rfl τ σ t).mp h

/-! ### The three discrete Prior/Z1 validities, re-exported rather than re-wrapped

`prior_UZ_valid`, `prior_SZ_valid` and `z1_valid` are proved once, in
`SoundnessLemmas/FrameClassVariants.lean`. This module used to restate each as a one-line wrapper
theorem of the same name; after the axiom-validity name normalisation that would
put two identically-named theorems in sibling namespaces (`FormalSystem.Metalogic` and
`FormalSystem.Metalogic.SoundnessLemmas`), which is a resolution hazard at every site that opens
both. They are `export`ed instead, so `Metalogic.prior_UZ_valid` still resolves and there is
exactly one theorem behind the name. -/

export SoundnessLemmas (prior_UZ_valid prior_SZ_valid z1_valid)

/-! ## Validity-preserving forms of the two necessitation rules

Semantic counterparts of the `necessitation` and `temporal_necessitation` rules, stated at
`.Base`. `soundness_in` reaches those two constructors through its own induction hypothesis and
does not consume these; they are kept as the free-standing semantic facts they state.
-/

/--
Necessitation rule preserves validity: if φ is universally valid, then □φ is universally valid.

This is semantic: if φ holds at all (M, τ, hτ, t), then for any model at any time,
□φ holds because we quantify over all total histories, and φ holds at all of them.
-/
theorem necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨ (Formula.box φ) := by
  refine valid.of_forall_total ?_
  intro F M τ _hτ t
  simp only [TruthAt]
  intro σ h_σ_mem
  exact h |>.apply F M σ h_σ_mem t

/--
Temporal necessitation preserves validity: if φ is universally valid, then Gφ is universally valid.

This is semantic: if φ holds at all (M, τ, hτ, t), then at any time s ≥ t, φ holds at (τ, s).
-/
theorem temporal_necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨
    (Formula.allFuture φ) := by
  refine valid.of_forall_total ?_
  intro F M τ hτ t
  simp only [Truth.future_iff]
  intro s _hts
  exact h |>.apply F M τ hτ s

/-! ## Dedekind Frame Soundness Theorems

Soundness for `FrameClass.Dedekind`: Reynolds' axiomatization US/R for real flow.

**The target is `ValidDedekind`, NOT `ValidComplete`, and that is deliberate.** See the `ValidComplete` caveat in `Semantics/Validity.lean` — the one place the `ValidComplete` / `ValidDedekind` distinction is argued in full.
-/

/-! ### Semantic validity of the three Reynolds axioms

`prior_U_gap` and `prior_S_gap` are each other's temporal dual definitionally, so the two Prior
lemmas below cover both directions. Sep's dual is by contrast a genuinely separate semantic
fact and so carries its own `sep_swap_valid`; that pair is stated as two lemmas because they are
two obligations, consumed at different call sites.

The Dedekind soundness chain is sorry-free end to end: both Prior gap lemmas, both Sep lemmas,
and — since the collapse onto `soundness_in` — the single `axiom_validIn_min` /
`axiom_swap_validIn_min` pair below, whose arms cover all 45 axiom constructors once rather
than once per frame class.
-/

/-- **Prior-U gap axiom validity**: `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)` is valid on every
dense Dedekind-complete duration group.

Reynolds 1992 (printed p.168) asserts this without proof -- "It is clear that all these axioms
are valid over the reals" -- so the argument below is reconstructed rather than transcribed.

The construction: let `A` be the set of right endpoints of φ-intervals starting at `t`, i.e. the
`u > t` such that φ holds at every `r` strictly between `t` and `u`. The antecedent's `U(⊤,φ)`
conjunct makes `A` non-empty, and its `F(¬φ)` conjunct supplies a `¬φ` point bounding `A` above,
so the binder set's least-upper-bound hypothesis yields `s = sup A`. That `s` realizes as a
single point what Reynolds describes as a supremum-less non-empty proper initial segment of the
φ-region: φ holds throughout `(t, s)` because any `r < s` is undercut by some member of `A`
above it, and `s` witnesses the consequent because a `w > s` refuting the `¬φ ∨ K⁺(¬φ)` disjunct
at `s` would give φ on all of `(s, w)`, which together with φ at `s` and φ on `(t, s)` puts `w`
itself in `A` -- above its own supremum.

Note that the proof consumes only the least-upper-bound hypothesis and the linear order: it uses
no `DenselyOrdered`, `Nontrivial`, `AddCommGroup`, `IsOrderedAddMonoid`, or shift-closure
assumption, so both Prior gap axioms are in fact valid on every Dedekind-complete linear order.
The `DenselyOrdered` binder is present for consistency with the rest of the chain, not because
the mathematics needs it; see the `ValidDedekind` discussion above for why the weaker binder
set is required here and must not be relaxed. -/
theorem prior_U_gap_valid (φ : Formula) :
    ValidDedekind ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
      (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) := by
  refine ValidIn.of_forall_total ?_
  intro F h_lub M τ _hτ t h_ant
  sat_intro h_lub
  simp only [Truth.and_iff, Truth.untl_iff, Truth.top_true, Truth.some_future_iff,
    Truth.neg_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  obtain ⟨s0, hts0, -, hp0⟩ := h1
  obtain ⟨v, htv, hnpv⟩ := h2
  set A : Set F.Duration := {u : F.Duration | t < u ∧ ∀ r : F.Duration, t < r → r < u → TruthAt M τ r φ} with hA
  have hs0A : s0 ∈ A := ⟨hts0, hp0⟩
  have hAbdd : BddAbove A := by
    refine ⟨v, ?_⟩
    intro u hu
    by_contra hvu
    exact hnpv (hu.2 v htv (lt_of_not_ge hvu))
  obtain ⟨s, hs⟩ := h_lub A ⟨s0, hs0A⟩ hAbdd
  have hts : t < s := lt_of_lt_of_le hts0 (hs.1 hs0A)
  have hguard : ∀ r : F.Duration, t < r → r < s → TruthAt M τ r φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2 r htr hru
  simp only [Truth.untl_iff, Truth.or_iff, Truth.neg_iff, Truth.kPlus_iff]
  refine ⟨s, hts, ?_, hguard⟩
  -- The event is now a genuine disjunction, so the two cases split directly.
  by_cases hps : TruthAt M τ s φ
  · refine .inr fun w hsw => ?_
    by_contra hw
    push Not at hw
    have hwA : w ∈ A := by
      refine ⟨lt_trans hts hsw, ?_⟩
      intro r htr hrw
      rcases lt_trichotomy r s with h | h | h
      · exact hguard r htr h
      · exact h ▸ hps
      · exact hw r h hrw
    exact absurd (hs.1 hwA) (not_le_of_gt hsw)
  · exact .inl hps

/-- **Prior-S gap axiom validity**: `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)`, the past dual.

The infimum dual of `prior_U_gap_valid` (Reynolds 1992, printed p.168, likewise asserted without
proof). Here `B` is the set of left endpoints of φ-intervals ending at `t` -- the `u < t` such
that φ holds at every `r` strictly between `u` and `t` -- and the witness is `s = inf B`.

The binder set provides only a least-upper-bound hypothesis, so
`SoundnessLemmas.exists_isGLB_of_lub` is the bridge: it derives a greatest lower bound of `B` as
the least upper bound of `B`'s lower-bound set, via `isLUB_lowerBounds`. This costs nothing extra in hypotheses, whereas the alternative
negation route (`x ↦ -x` reverses the order) would drag in the additive group structure.

The trichotomy branches in the final step run in the mirror order to the Prior-U case: for `r`
between `w` and `t`, the case `r < s` is handled by the refuting witness and `s < r` by the
interval guard, because the `K⁻` interval now lies to the left of `s` rather than the right. -/
theorem prior_S_gap_valid (φ : Formula) :
    ValidDedekind ((Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg)))) := by
  refine ValidIn.of_forall_total ?_
  intro F h_lub M τ _hτ t h_ant
  sat_intro h_lub
  simp only [Truth.and_iff, Truth.snce_iff, Truth.top_true, Truth.some_past_iff,
    Truth.neg_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  obtain ⟨s0, hs0t, -, hp0⟩ := h1
  obtain ⟨v, hvt, hnpv⟩ := h2
  set B : Set F.Duration := {u : F.Duration | u < t ∧ ∀ r : F.Duration, u < r → r < t → TruthAt M τ r φ} with hB
  have hs0B : s0 ∈ B := ⟨hs0t, hp0⟩
  have hBbdd : BddBelow B := by
    refine ⟨v, ?_⟩
    intro u hu
    by_contra huv
    exact hnpv (hu.2 v (lt_of_not_ge huv) hvt)
  obtain ⟨s, hs⟩ := SoundnessLemmas.exists_isGLB_of_lub h_lub ⟨s0, hs0B⟩ hBbdd
  have hst : s < t := lt_of_le_of_lt (hs.1 hs0B) hs0t
  have hguard : ∀ r : F.Duration, s < r → r < t → TruthAt M τ r φ := by
    intro r hsr hrt
    obtain ⟨u, huB, -, hur⟩ := hs.exists_between hsr
    exact huB.2 r hur hrt
  simp only [Truth.snce_iff, Truth.or_iff, Truth.neg_iff, Truth.kMinus_iff]
  refine ⟨s, hst, ?_, hguard⟩
  by_cases hps : TruthAt M τ s φ
  · refine .inr fun w hws => ?_
    by_contra hw
    push Not at hw
    have hwB : w ∈ B := by
      refine ⟨lt_trans hws hst, ?_⟩
      intro r hwr hrt
      rcases lt_trichotomy r s with h | h | h
      · exact hw r hwr h
      · exact h ▸ hps
      · exact hguard r h hrt
    exact absurd (hs.1 hwB) (not_le_of_gt hws)
  · exact .inl hps

/-- **Sep axiom validity**: `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)` is valid on real flow.

Reynolds 1992 defers this at his printed p.168 -- "we investigate this axiom in more detail in
section 7 and defer proving its validity in ℝ until lemma 10 there" -- so the source for the
argument below is his §7 lemma 10.

**The separability input.** Sep is FALSE on an arbitrary densely ordered Dedekind-complete linear
order: the lexicographic square `[0,1] ×ₗₑₓ [0,1]` refutes it. The `ValidDedekind` algebraic
binders are therefore load-bearing here, in sharp contrast to the two Prior gap lemmas above,
which consume only the linear order and the least-upper-bound hypothesis. `AddCommGroup`,
`IsOrderedAddMonoid`, `DenselyOrdered` and `Nontrivial` together with the LUB hypothesis force
the flow to be Archimedean and hence separable; `SoundnessLemmas.exists_countable_order_dense`
extracts the countable order-dense `Q` that the argument runs on. Do not attempt to weaken the
binder set to `ValidComplete`.

**Shape of the proof.** Negating the implication gives, at `t`: (i) φ accumulates at `t` from the
right, (ii) no φ-point just above `t` begins a φ-free gap (Reynolds' relative-density condition),
and (iii) every point of some right-neighbourhood of `t` fails `K⁺φ ∧ K⁻φ`, i.e. carries a
φ-free interval on one side -- Reynolds' adjacent intervals `I_u`. `SoundnessLemmas.sep_order`
derives the contradiction: `S := φ-region ∩ (t, s)` is dense in itself by (ii), and (iii) assigns
each `u` a point of `Q` separating `S` below `u` from `S` above it, which is impossible.

**Fidelity note -- one deliberate, bounded deviation from the source.** Reynolds' own endgame
(his step 7) thins `S` to a countable subset, invokes Cantor's theorem that a countable dense
linear order without endpoints is isomorphic to ℚ, counts the uncountably many gaps of ℚ, and
concludes by cardinal comparison. That endgame is replaced here by an equivalent Baire-style
nested-interval construction over ℕ (`SoundnessLemmas.nested_core`). Everything through
Reynolds' step 6 is followed as written; only the final move is restructured. The substitution
uses the *same* essential input -- separability -- repackaged as "each `I_u` contains a point of
a fixed countable dense `Q`", which is precisely the standard proof of Reynolds' cardinality
step. It is adopted because the `≅ ℚ` route needs Cantor's back-and-forth theorem (a substantial
development absent from this tree) and would drag `Cardinal` into the soundness chain; Reynolds'
"no last point" condition is dropped with it, since it exists only to secure order type ℚ. A
reader comparing this proof against Reynolds §7 should expect no `S ≅ ℚ` step and find
`nested_core` in its place. -/
theorem sep_valid (φ : Formula) :
    ValidDedekind ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  refine ValidIn.of_forall_total ?_
  intro F h_lub M τ _hτ t h_ant
  sat_intro h_lub
  obtain ⟨Q, hQc, hQd⟩ := SoundnessLemmas.exists_countable_order_dense h_lub
  -- `Truth.and_iff` splits the antecedent before it is unfolded, which is what retires the
  -- private `and_of_not_imp_not` helper this proof used to call here.
  obtain ⟨h1, h2⟩ := (Truth.and_iff _ _).mp h_ant
  simp only [TruthAt, Formula.and, Formula.neg, Formula.kPlus, Formula.kMinus,
    Formula.top] at h1 h2 ⊢
  rintro ⟨s₂, hts₂, -, hno⟩
  have hK : ∀ v, t < v → ∃ u, t < u ∧ u < v ∧ TruthAt M τ u φ := by
    intro v htv
    by_contra hc
    refine h1 ⟨v, htv, fun hb => hb, ?_⟩
    intro r htr hrv hrφ
    exact hc ⟨r, htr, hrv, hrφ⟩
  have h2' : ∃ s₁, t < s₁ ∧ (True) ∧ ∀ u, t < u → u < s₁ →
      (TruthAt M τ u φ → TruthAt M τ u (Formula.untl φ.neg φ) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hts₁, -, hu⟩ := hbad
      exact ⟨s₁, hts₁, trivial, fun u htu hus => Classical.byContradiction (hu u htu hus)⟩)
  obtain ⟨s₁, hts₁, -, hstart⟩ := h2'
  refine SoundnessLemmas.sep_order h_lub Q hQc hQd {u | TruthAt M τ u φ} t s₁ s₂
    hts₁ hts₂ hK ?_ ?_
  · rintro u htu hus₁ huP ⟨v, huv, hvP, hfree⟩
    exact hstart u htu hus₁ huP ⟨v, huv, hvP, fun r hur hrv => hfree r hur hrv⟩
  · intro u htu hus₂
    have hAB : TruthAt M τ u (Formula.kPlus φ) →
        TruthAt M τ u (Formula.kMinus φ) → False := by
      intro ha hb
      exact hno u htu hus₂ (fun k => k ha hb)
    by_cases hR : ∃ v, u < v ∧ ∀ w, u < w → w < v → ¬ TruthAt M τ w φ
    · exact Or.inl hR
    · refine Or.inr ?_
      have ha : TruthAt M τ u (Formula.kPlus φ) := by
        simp only [TruthAt, Formula.kPlus, Formula.neg, Formula.top]
        rintro ⟨v, huv, -, hw⟩
        exact hR ⟨v, huv, fun w huw hwv => hw w huw hwv⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      simp only [TruthAt, Formula.kMinus, Formula.neg, Formula.top]
      rintro ⟨v, hvu, -, hw⟩
      exact hns ⟨v, hvu, fun w hvw hwu => hw w hvw hwu⟩

/-- **Sep⁻ validity**: the temporal dual of `sep_valid`, needed by `temporal_duality`.

Unlike the Prior pair -- where `Formula.swapTemporal` carries `prior_U_gap` onto `prior_S_gap`
definitionally (verified by `rfl`), so those two lemmas cover each other's swap -- Sep is not
self-covering under the swap: `(sep φ).swapTemporal` exchanges `K⁺`/`K⁻` and `U`/`S`, and the
result is NOT an instance of `Axiom.sep`. It is therefore a genuinely separate semantic fact and
gets its own lemma, matching the tree's `<axiom>_swap_valid` convention in
`SoundnessLemmas/FrameClassVariants.lean` (none bundled with its unswapped partner).

Stated separately from `sep_valid` rather than folded into a conjunction with it: the two are
consumed at different call sites (`axiom_validIn_min`'s `sep` arm and `axiom_swap_validIn_min`'s),
and a conjunction would misreport two independent obligations as one.

The proof reuses the forward order-theoretic core rather than mirroring it by hand:
`SoundnessLemmas.sep_order_mirror` is `SoundnessLemmas.sep_order` instantiated at `Dᵒᵈ`, so the
~130-line nested-interval argument is written once. (The Prior pair took the opposite route
because its dualised body is only ~25 lines.) `swapTemporal` distributes through `imp` and `bot`,
hence through `neg` and `and`, exchanges `U`/`S` and fixes `top`; so the swapped Sep is the exact
past mirror with `ψ := φ.swapTemporal`, and a single `simp only` performs the whole unfolding.
See `sep_valid` for the separability input and the recorded fidelity deviation from Reynolds. -/
theorem sep_swap_valid (φ : Formula) :
    ValidDedekind (((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))).swapTemporal) := by
  refine ValidIn.of_forall_total ?_
  intro F h_lub M τ _hτ t h_ant
  sat_intro h_lub
  obtain ⟨Q, hQc, hQd⟩ := SoundnessLemmas.exists_countable_order_dense h_lub
  -- Same split as `sep_valid`: `Truth.and_iff` in place of the private helper. `swapTemporal`
  -- distributes definitionally through `Formula.and`, so unification reaches the conjunction
  -- without an explicit rewrite.
  obtain ⟨h1, h2⟩ := (Truth.and_iff _ _).mp h_ant
  simp only [Formula.and, Formula.neg, Formula.kPlus, Formula.kMinus, Formula.top,
    Formula.swapTemporal, TruthAt] at h1 h2 ⊢
  rintro ⟨s₂, hs₂t, -, hno⟩
  have hK : ∀ v, v < t → ∃ u, v < u ∧ u < t ∧ TruthAt M τ u φ.swapTemporal := by
    intro v hvt
    by_contra hc
    refine h1 ⟨v, hvt, fun hb => hb, ?_⟩
    intro r hvr hrt hrφ
    exact hc ⟨r, hvr, hrt, hrφ⟩
  have h2' : ∃ s₁, s₁ < t ∧ (True) ∧ ∀ u, u < t → s₁ < u →
      (TruthAt M τ u φ.swapTemporal →
        TruthAt M τ u (Formula.snce φ.swapTemporal.neg φ.swapTemporal) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hs₁t, -, hu⟩ := hbad
      exact ⟨s₁, hs₁t, trivial, fun u hut hs₁u => Classical.byContradiction (hu u hs₁u hut)⟩)
  obtain ⟨s₁, hs₁t, -, hstart⟩ := h2'
  refine SoundnessLemmas.sep_order_mirror h_lub Q hQc hQd
    {u | TruthAt M τ u φ.swapTemporal} t s₁ s₂ hs₁t hs₂t hK ?_ ?_
  · rintro u hut hs₁u huP ⟨v, hvu, hvP, hfree⟩
    exact hstart u hut hs₁u huP ⟨v, hvu, hvP, fun r hvr hru => hfree r hvr hru⟩
  · intro u hut hs₂u
    have hAB : TruthAt M τ u (Formula.kMinus φ.swapTemporal) →
        TruthAt M τ u (Formula.kPlus φ.swapTemporal) → False := by
      intro ha hb
      exact hno u hs₂u hut (fun k => k ha hb)
    by_cases hL : ∃ v, v < u ∧ ∀ w, v < w → w < u → ¬ TruthAt M τ w φ.swapTemporal
    · exact Or.inl hL
    · refine Or.inr ?_
      have ha : TruthAt M τ u (Formula.kMinus φ.swapTemporal) := by
        simp only [TruthAt, Formula.kMinus, Formula.neg, Formula.top]
        rintro ⟨v, hvu, -, hw⟩
        exact hL ⟨v, hvu, fun w hvw hwu => hw w hvw hwu⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      simp only [TruthAt, Formula.kPlus, Formula.neg, Formula.top]
      rintro ⟨v, huv, -, hw⟩
      exact hns ⟨v, huv, fun w huw hwv => hw w huw hwv⟩

/-- **Density axiom swap-validity**: the swap of `GGφ → Gφ` is `HHφ → Hφ`, valid on every densely
ordered frame. Given a `¬φ` point `s < t`, density supplies `r` with `s < r < t`, and `r` then
witnesses `P(¬Hφ)`, which is what the swapped antecedent forbids. -/
theorem density_swap_valid (φ : Formula) :
    ValidDense ((φ.allFuture.allFuture.imp φ.allFuture).swapTemporal) := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swapTemporal, Formula.allFuture, Formula.someFuture,
    Formula.neg, TruthAt]
  intro h_HH ⟨s, hst, h_neg_phi_s, h_guard_s⟩
  apply h_HH
  obtain ⟨r, hrs, hrt⟩ := exists_between hst
  refine ⟨r, hrt, ?_, ?_⟩
  · -- Need: ¬¬P(¬φ) at r, i.e., ¬Hφ at r; witness `s < r` with `¬φ(s)`
    intro h_Hphi_r
    exact h_Hphi_r ⟨s, hrs, h_neg_phi_s, fun q hq1 hq2 => h_guard_s q hq1 (lt_trans hq2 hrt)⟩
  · -- Guard: all between r and t satisfy ⊤
    intro q hq1 hq2
    exact h_guard_s q (lt_trans hrs hq1) hq2

/-- **Dense-indicator axiom swap-validity**: the swap of `¬U(⊤,⊥)` is `¬S(⊤,⊥)`, the past density
indicator. `S(⊤,⊥)` at `t` needs an `s < t` with `(s,t)` empty, which density refutes. -/
theorem dense_indicator_swap_valid :
    ValidDense ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg.swapTemporal) := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swapTemporal, Formula.neg, TruthAt]
  intro ⟨s, hst, _h_top, h_guard⟩
  obtain ⟨r, hsr, hrt⟩ := exists_between hst
  exact h_guard r hsr hrt
/-! ## The `FrameClass`-parameterized soundness family

Everything below is indexed by an arbitrary `fc : FrameClass` rather than by one of the four
named classes. The per-class theorems further down are corollaries of `soundness_in`, obtained by
supplying the class's `FrameClass.Sat` witness; they keep their original statements, so no call
site changes.

The two `*_min` leaf lemmas below state each axiom's validity at *its own* `minFrameClass`, which
is where the per-axiom validity lemmas already live. `ValidIn.mono` then lifts them to any wider
`fc`, which is what replaces the four hand-written 45-arm dispatchers. -/

/-- Uniform per-axiom validity at the axiom's own minimum frame class. -/
theorem axiom_validIn_min {φ : Formula} (ax : Axiom φ) : ValidIn ax.minFrameClass φ := by
  cases ax with
  | prop_k a0 a1 a2 => exact prop_k_valid a0 a1 a2
  | prop_s a0 a1 => exact prop_s_valid a0 a1
  | modal_t a0 => exact modal_t_valid a0
  | modal_4 a0 => exact modal_4_valid a0
  | modal_b a0 => exact modal_b_valid a0
  | modal_5_collapse a0 => exact modal_5_collapse_valid a0
  | ex_falso a0 => exact ex_falso_valid a0
  | peirce a0 a1 => exact peirce_valid a0 a1
  | modal_k_dist a0 a1 => exact modal_k_dist_valid a0 a1
  | serial_future => exact serial_future_axiom_valid
  | serial_past => exact serial_past_axiom_valid
  | left_mono_until_G a0 a1 a2 => exact left_mono_until_G_valid a0 a1 a2
  | left_mono_since_H a0 a1 a2 => exact left_mono_since_H_valid a0 a1 a2
  | right_mono_until a0 a1 a2 => exact right_mono_until_valid a0 a1 a2
  | right_mono_since a0 a1 a2 => exact right_mono_since_valid a0 a1 a2
  | connect_future a0 => exact connect_future_valid a0
  | connect_past a0 => exact connect_past_valid a0
  | enrichment_until a0 a1 a2 => exact enrichment_until_valid a0 a1 a2
  | enrichment_since a0 a1 a2 => exact enrichment_since_valid a0 a1 a2
  | self_accum_until a0 a1 => exact self_accum_until_valid a0 a1
  | self_accum_since a0 a1 => exact self_accum_since_valid a0 a1
  | absorb_until a0 a1 => exact absorb_until_valid a0 a1
  | absorb_since a0 a1 => exact absorb_since_valid a0 a1
  | linear_until a0 a1 a2 a3 => exact linear_until_valid a0 a1 a2 a3
  | linear_since a0 a1 a2 a3 => exact linear_since_valid a0 a1 a2 a3
  | until_F a0 a1 => exact until_F_valid a0 a1
  | since_P a0 a1 => exact since_P_valid a0 a1
  | temp_linearity a0 a1 => exact temp_linearity_valid a0 a1
  | temp_linearity_past a0 a1 => exact temp_linearity_past_valid a0 a1
  | F_until_equiv a0 => exact F_until_equiv_valid a0
  | P_since_equiv a0 => exact P_since_equiv_valid a0
  | modal_future a0 => exact modal_future_valid a0
  | discrete_symm_fwd => exact discrete_symm_fwd_valid
  | discrete_symm_bwd => exact discrete_symm_bwd_valid
  | discrete_propagate_fwd => exact discrete_propagate_fwd_valid
  | discrete_propagate_bwd => exact discrete_propagate_bwd_valid
  | discrete_box_necessity => exact discrete_box_necessity_valid
  | density a0 => exact density_valid a0
  | dense_indicator => exact dense_indicator_valid
  | prior_UZ a0 => exact prior_UZ_valid a0
  | prior_SZ a0 => exact prior_SZ_valid a0
  | z1 a0 => exact z1_valid a0
  | prior_U_gap a0 => exact prior_U_gap_valid a0
  | prior_S_gap a0 => exact prior_S_gap_valid a0
  | sep a0 => exact sep_valid a0

/-- Uniform per-axiom swap-validity at the axiom's own minimum frame class. -/
theorem axiom_swap_validIn_min {φ : Formula} (ax : Axiom φ) :
    ValidIn ax.minFrameClass φ.swapTemporal := by
  by_cases hbase : ax.minFrameClass ≤ FrameClass.Base
  · have heq : ax.minFrameClass = FrameClass.Base :=
      le_antisymm hbase (FrameClass.base_le _)
    rw [heq]
    exact SoundnessLemmas.axiom_swap_valid_general φ ax hbase
  · cases ax with
    | density a0 => exact density_swap_valid a0
    | dense_indicator => exact dense_indicator_swap_valid
    | prior_UZ a0 => exact SoundnessLemmas.prior_SZ_valid a0.swapTemporal
    | prior_SZ a0 => exact SoundnessLemmas.prior_UZ_valid a0.swapTemporal
    | z1 a0 => exact SoundnessLemmas.z1_past_valid a0.swapTemporal
    | prior_U_gap a0 => exact prior_S_gap_valid a0.swapTemporal
    | prior_S_gap a0 => exact prior_U_gap_valid a0.swapTemporal
    | sep a0 => exact sep_swap_valid a0
    | _ => exact absurd trivial hbase

theorem axiom_validIn {φ : Formula} {fc : FrameClass} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ fc) : ValidIn fc φ :=
  ValidIn.mono h_fc (axiom_validIn_min ax)

theorem axiom_swap_validIn {φ : Formula} {fc : FrameClass} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ fc) : ValidIn fc φ.swapTemporal :=
  ValidIn.mono h_fc (axiom_swap_validIn_min ax)

/-- The uniform combined valid/swap-valid recursion at an arbitrary `fc`. -/
theorem derivable_valid_and_swap_validIn {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) : ValidIn fc φ ∧ ValidIn fc φ.swapTemporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨axiom_validIn h_ax h_fc, axiom_swap_validIn h_ax h_fc⟩
  | .assumption _ _ h_mem =>
    exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := derivable_valid_and_swap_validIn d1
    have h2 := derivable_valid_and_swap_validIn d2
    constructor
    · refine ValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      have h1' := h1.1.apply_total F hF M τ hτ t
      have h2' := h2.1.apply_total F hF M τ hτ t
      simp only [TruthAt] at h1'
      exact h1' h2'
    · refine ValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      have h1' := h1.2.apply_total F hF M τ hτ t
      have h2' := h2.2.apply_total F hF M τ hτ t
      simp only [Formula.swapTemporal, TruthAt] at h1' ⊢
      exact h1' h2'
  | .necessitation psi' d' =>
    have h := derivable_valid_and_swap_validIn d'
    constructor
    · refine ValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      simp only [TruthAt]
      intro sigma h_sigma_mem
      exact h.1.apply_total F hF M sigma h_sigma_mem t
    · refine ValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      simp only [Formula.swapTemporal, TruthAt]
      intro sigma h_sigma_mem
      exact h.2.apply_total F hF M sigma h_sigma_mem t
  | .temporal_necessitation psi' d' =>
    have h := derivable_valid_and_swap_validIn d'
    constructor
    · refine ValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      simp only [Truth.future_iff]
      intro s _hts
      exact h.1.apply_total F hF M τ hτ s
    · refine ValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      simp only [Formula.allFuture, Formula.someFuture, Formula.swapTemporal,
        Formula.neg, Formula.top] at *
      simp only [TruthAt] at *
      intro hcontra
      obtain ⟨s, hts, hs, _⟩ := hcontra
      exact hs (h.2.apply_total F hF M τ hτ s)
  | .temporal_duality psi' d' =>
    have h := derivable_valid_and_swap_validIn d'
    refine ⟨h.2, ?_⟩
    rw [Formula.swap_temporal_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_eq : Gamma' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Gamma' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_validIn (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/-- **The single parameterized soundness theorem.** -/
theorem soundness_in {fc : FrameClass} (Γ : Context) (φ : Formula)
    (d : DerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    exact (axiom_validIn h_ax h_fc).apply_total F hF M τ h_mem t
  | assumption Γ' φ' h_in => exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have h1 := ih1 τ h_mem t h_ctx
    have h2 := ih2 τ h_mem t h_ctx
    simp only [TruthAt] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [TruthAt]
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [Truth.future_iff]
    intro s _hts
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' _ih =>
    exact ((derivable_valid_and_swap_validIn d').2).apply_total F hF M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))


/-- Empty-context validity form, uniform. -/
theorem soundness_validIn {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) : ValidIn fc φ :=
  (derivable_valid_and_swap_validIn d).1

/-! ## Per-class corollaries of `soundness_in`

Every theorem below keeps the exact statement it had before the collapse; only its proof
changed, from a hand-written induction (or a 45-arm axiom dispatch) to a single application of
`soundness_in` / `soundness_validIn` / `axiom_validIn` at the class in question. The class
condition each one used to carry as a binder list is now supplied as that class's
`FrameClass.Sat` witness: `trivial` at `.Base`, the `DenselyOrdered` instance at `.Dense`, the
four order instances at `.Discrete`, and the density-plus-LUB pair at `.Dedekind`.

They are gathered here, after the parameterized family, because they now depend on it. The
per-axiom validity lemmas they used to dispatch over are unchanged and still live above.
-/

/-- All base TM axioms (excluding density, discreteness, and seriality) are universally valid.
With strict semantics, density requires DenselyOrdered, discreteness requires SuccOrder,
and seriality requires NoMaxOrder/NoMinOrder, so they are handled separately.

**Why `FrameClass.Base` is essential here**: the conclusion is unconditional validity `⊨ φ`,
which is exactly the class of axioms admissible at `Base`. Generalising `h_fc` to
`h.minFrameClass ≤ fc` would be false — a `Dense` or `Discrete` axiom is valid only on frames
satisfying that class's condition, which is what `axiom_dense_valid` /
`axiom_discrete_valid` state instead. -/
theorem axiom_valid {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Base) : ⊨
    φ := by
  exact axiom_validIn h h_fc

/-- All dense-compatible axioms are valid on densely ordered frames.
This covers all base axioms (universally valid, hence valid on dense frames) plus the density axiom.
Note: Under strict semantics, seriality axioms require NoMaxOrder/NoMinOrder (via Nontrivial). -/
theorem axiom_dense_valid {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Dense) :
    ValidDense φ := by
  exact axiom_validIn h h_fc

/-- All discrete-compatible axioms are valid on discrete frames.
This covers all base axioms (universally valid, hence valid on discrete frames) plus discreteness.
Under strict semantics, seriality requires NoMaxOrder/NoMinOrder (from SuccOrder/PredOrder +
Nontrivial). -/
theorem axiom_discrete_valid {φ : Formula} (h : Axiom φ) (h_fc :
      h.minFrameClass ≤ FrameClass.Discrete) :
    ValidDiscrete φ := by
  exact axiom_validIn h h_fc

/--
**Soundness Theorem (Base)**: Derivability in the base system implies semantic consequence.

If `Γ ⊢[Base] φ`, then `Γ ⊨ φ`.
The `FrameClass.Base` parameter on `DerivationTree` structurally excludes axioms with
`minFrameClass > Base` (density, Prior-UZ/SZ, z1) via the `h_fc` gate on the axiom rule.

This is `soundness_in` at `fc = .Base`. `Sat .Base` is `True`, so the only argument the
instance supplies beyond the shared ones is `trivial`; the induction over `DerivationTree` that
used to be written out here lives in `soundness_in` and is shared with the three other classes.

**Note**: Prior-UZ/SZ and z1 are excluded structurally — their `minFrameClass` is
`Discrete`, which is incomparable to `Base` in the partial order. Use
`soundness_discrete` for derivations containing these axioms.
-/
theorem soundness (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Base Γ φ)
    (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  exact soundness_in Γ φ d F trivial M τ h_mem t h_ctx

/-! ### Dense-frame instances

The frame condition each of these carries is the same one `FrameClass.Sat .Dense` names; it is
supplied to `soundness_in` as that witness rather than re-derived.
-/

/--
**Soundness Dense Valid**: Derivability from empty context implies dense validity.

This theorem proves `ValidDense phi` for dense-compatible derivations from empty context. The
empty context is what makes the statement universally quantified over frames, models, histories
and times, which is what the two necessitation cases need of their premise.

**Key Insight** (now discharged once, generically): the recursion at each step needs
`ValidDense` for the premises, the universally quantified form the `necessitation` and
`temporal_necessitation` cases consume — an empty-context `ValidDense` statement, unlike a
`TruthAt` statement at a fixed history and time, is already closed over all frames, models,
histories and times. That recursion is `derivable_valid_and_swap_validIn`, written once at an
arbitrary `fc`; this theorem is `soundness_validIn` at `.Dense`.

`ValidDense` quantifies over the frame's **total** histories, so no domain-membership side
condition arises and there is nothing here to case-split on. This theorem is sorry-free, as are
`soundness`, `soundness_dense` and `soundness_discrete`.
-/
theorem soundness_dense_valid {phi : Formula}
    (d : DerivationTree FrameClass.Dense [] phi) : ValidDense phi := by
  exact soundness_validIn d

/--
**Soundness for Dense Frames**: Derivability implies semantic consequence on dense frames.

If `Γ ⊢ φ` with a dense-compatible derivation, then `Γ ⊨_dense φ`.

**Frame Constraints**:
- `[DenselyOrdered D]`: Required for density axiom (GGφ → Gφ)
- `[Nontrivial D]`: Required for seriality axioms (provides NoMaxOrder/NoMinOrder)

**Frame Class Constraint** (`fc = .Dense`):
The `DerivationTree .Dense` parameterization structurally ensures no discrete-specific axioms
(prior_UZ, prior_SZ, z1) appear in the derivation, since their `minFrameClass = .Discrete`
is incomparable with `.Dense`.

**Constructor coverage**: this induction cases on all seven `DerivationTree` constructors and no
others. There is no IRR rule in the proof system, so no IRR case appears here.
-/
theorem soundness_dense (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Dense Γ φ)
    (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  exact soundness_in Γ φ d F ‹DenselyOrdered F.Duration› M τ h_mem t h_ctx

/-! ### Discrete-frame instances

Analogous to the dense pair above, at `FrameClass.Sat .Discrete` — the bundle of `SuccOrder`,
`PredOrder`, `IsSuccArchimedean` and `IsPredArchimedean` these theorems take as instances.
-/

/--
**Soundness Discrete Valid**: Derivability from empty context implies discrete validity.

For discrete-compatible derivations from empty context, the derived formula is
valid on all discrete frames.

**Note on temporal_duality**: this is `soundness_validIn` at `.Discrete`. The
`temporal_duality` case is handled inside `derivable_valid_and_swap_validIn`, which carries
validity and swap-validity together at an arbitrary `fc`; the discrete swap facts it needs
(Prior-SZ for Prior-UZ and vice versa, `z1_past` for `z1`) enter through
`axiom_swap_validIn_min`'s discrete arms.
-/
theorem soundness_discrete_valid {phi : Formula}
    (d : DerivationTree FrameClass.Discrete [] phi) : ValidDiscrete phi := by
  exact soundness_validIn d

/--
**Soundness for Discrete Frames**: Derivability implies semantic consequence on discrete frames.

This is the discrete analogue of `soundness_dense`. Given a discrete-compatible
derivation `Γ ⊢ φ`, if all formulas in `Γ` are true at some configuration on a
discrete frame, then `φ` is also true there.
-/
theorem soundness_discrete (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Discrete Γ φ)
    (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
    [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  exact soundness_in Γ φ d F
    ⟨‹SuccOrder F.Duration›, ‹PredOrder F.Duration›,
      ‹IsSuccArchimedean F.Duration›, ‹IsPredArchimedean F.Duration›⟩
    M τ h_mem t h_ctx

/-- All Dedekind-compatible axioms are valid on dense Dedekind-complete frames.

`axiom_validIn` at `.Dedekind`. The dispatch it used to write out by hand is now
`axiom_validIn_min` plus `ValidIn.mono`: each axiom is proved valid once, at its own
`minFrameClass`, and monotonicity carries it to `.Dedekind`. The 3 Discrete axioms are still
eliminated, now by `ValidIn.mono`'s `h_fc` hypothesis being unsatisfiable at
`Discrete ≰ Dedekind`, rather than by three explicit `absurd` arms.

This theorem is itself sorry-free. -/
theorem axiom_dedekind_valid {φ : Formula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ FrameClass.Dedekind) :
    ValidDedekind φ := by
  exact axiom_validIn h h_fc

/--
**Soundness Dedekind Valid**: Derivability from the empty context implies validity on dense
Dedekind-complete frames.
-/
theorem soundness_dedekind_valid {phi : Formula}
    (d : DerivationTree FrameClass.Dedekind [] phi) : ValidDedekind phi :=
  soundness_validIn d

/--
**Soundness for Dedekind Frames**: Derivability implies semantic consequence on dense
Dedekind-complete frames.

This is the Dedekind analogue of `soundness_dense` and `soundness_discrete`. Given a
Dedekind-compatible derivation `Γ ⊢ φ`, if all formulas in `Γ` are true at some configuration
on a dense Dedekind-complete frame, then `φ` is also true there.

**The conclusion is stated over the `ValidDedekind` binder set, NOT `ValidComplete`**; dropping
the `[DenselyOrdered D]` binder here would make this theorem refutable. See the `ValidComplete` caveat in `Semantics/Validity.lean` — the one place the `ValidComplete` / `ValidDedekind` distinction is argued in full.
-/
theorem soundness_dedekind (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Dedekind Γ φ)
    (F : TaskFrame) [DenselyOrdered F.Duration]
    (h_lub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  exact soundness_in Γ φ d F ⟨‹DenselyOrdered F.Duration›, h_lub⟩ M τ h_mem t h_ctx

/-! ## Consistency of the Base System

Soundness's most immediate corollary: `⊥` is not a theorem. Every "the logic is consistent" side
condition in the tree ultimately wants this, and until it was stated here each such site had to
route around it by carrying an underivability hypothesis instead.

Stated as `¬ Derivable …` rather than as `Metalogic.Core.Consistent []`, which is the same
proposition by definition (`Consistent Γ := ¬ Derivable fc Γ ⊥`), because this module sits below
`Metalogic/Core/` in the import graph. Downstream files spell it with `Consistent` freely.
-/

/--
**The base system is consistent**: `⊥` is not derivable from the empty context.

The witness is `trivialFrame` over `Int` at its single world state. `soundness` turns a
derivation of `⊥` from `[]` into `trivialFrame.ValidOn ⊥`, which
`Semantics/Validity.lean`'s `TaskFrame.not_validOn_bot` refutes — that refutation is itself
`cor:occurrence`'s closing clause (`H_F ≠ ∅`), so the frame axioms doing the work here are
`trivialFrame`'s own fields.

`Int` is chosen only because it is the smallest temporal type in the tree supplying
`[Nontrivial D]`, which `soundness` binds; nothing about the argument depends on the choice.

**Why `FrameClass.Base` is essential here**: consistency is a per-frame-class fact, read off a
soundness theorem for that class. This is the `Base` instance; `not_derivable_nil_bot_discrete`
below is the `FrameClass.Discrete` one. There is no `{fc}`-uniform statement, because `Dense`
and `Dedekind` have no corresponding consistency lemma in the tree yet.
-/
theorem not_derivable_nil_bot : ¬ Derivable FrameClass.Base ([] : Context) Formula.bot := by
  rintro ⟨d⟩
  refine TaskFrame.not_validOn_bot (FrameOver.trivialFrame (D := Int)) ?_
  intro M τ x
  exact soundness [] Formula.bot d (FrameOver.trivialFrame (D := Int)) M τ.val τ.property x
    (by simp)

/--
**The Discrete system is consistent**: `⊥` is not derivable from the empty context in the
system extended by the discreteness axioms DF/DP.

Stated as `¬ Derivable FrameClass.Discrete [] ⊥` rather than
`Consistent (fc := FrameClass.Discrete) []` for the same import-graph reason as
`not_derivable_nil_bot`: `Consistent` lives in `Metalogic/Core/`, which `Soundness.lean` does
not import, so phrasing the statement in terms of `Derivable` keeps the result available at
this layer.

The witness is again `trivialFrame` over `Int`, which is what this module's
`Mathlib.Data.Int.SuccPred` import is for: `ValidDiscrete` binds `SuccOrder D`, `PredOrder D`,
`IsSuccArchimedean D` and `IsPredArchimedean D`, and `Semantics/Validity.lean` imports those
*classes* without importing the `ℤ` *instances*. `soundness_discrete_valid` turns a
`FrameClass.Discrete` derivation of `⊥` from `[]` into `ValidDiscrete ⊥`; instantiating it at the
single total history supplied by `hF_nonempty_of_frameAxioms` contradicts `Truth.bot_false`.

Without this lemma every restricted-MCS result instantiated at `FrameClass.Discrete` would be
vacuous, since a `Discrete`-inconsistent system has no consistent sets at all.
-/
theorem not_derivable_nil_bot_discrete :
    ¬ Derivable FrameClass.Discrete ([] : Context) Formula.bot := by
  rintro ⟨d⟩
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (FrameOver.trivialFrame (D := ℤ))
  exact Truth.bot_false
    (Semantics.ValidIn.apply_total (FormalSystem.Metalogic.soundness_discrete_valid d)
      (FrameOver.trivialFrame (D := ℤ))
      (Semantics.TaskFrame.isSuccArchDiscrete_of_instances _)
      TaskModel.allFalse τ.val τ.property 0)

end FormalSystem.Metalogic
