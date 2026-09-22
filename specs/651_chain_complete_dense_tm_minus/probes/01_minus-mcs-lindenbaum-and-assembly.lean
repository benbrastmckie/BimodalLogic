/-
Research probe for the ChainComplete .Dense ∅ route. NOT a library module.

Compile record: `lake env lean <this file>` against the prebuilt oleans, exit 0, no errors, no
`sorry` warnings (2026-09-22). The `#check` lines below print the pinned-Mathlib signatures.

What it checks, all sorry-free:
1. A MinusFormula-side MCS layer (consistency, set-consistency, Zorn/Lindenbaum) transfers from
   `Metalogic/Core/MaximalConsistent.lean` by a near-verbatim mirror, with the generic Zorn step
   stated polymorphically.
2. The canonical G-relation and box-relation definitions typecheck over `MinusFormula` MCSs.
3. The final assembly shape: a single ℚ-chain-bundle refutation of `φ` refutes
   `ChainValidIn FrameClass.Dense φ` (the `TemporalOrder.of ℚ` instantiation elaborates with the
   `.Dense` side condition by `inferInstance`), and `¬ Derivable → {¬φ} consistent` mirrors.
4. The Mathlib names the step-by-step construction over ℚ would consume exist at the pinned
   Mathlib: `exists_surjective_nat`, `Nat.unpair`/`Nat.surjective_unpair`, `exists_between`,
   `Finset.max'`/`min'`, `NoMaxOrder`/`NoMinOrder`/`DenselyOrdered ℚ`.
-/
import FormalSystem.Metalogic.Conservativity.MinusDeduction
import FormalSystem.Metalogic.Conservativity.FragmentAxiomatization
import Mathlib.Order.Zorn
import Mathlib.Data.Countable.Defs
import Mathlib.Data.Nat.Pairing
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Data.Finset.Max

namespace Probe651

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.MinusLanguage
open FormalSystem.Metalogic
open FormalSystem.Metalogic.Conservativity

/-! ## 1. MCS layer over `MinusFormula` -/

/-- Mirror of `Core.Consistent` over L⁻. -/
def MinusConsistent (fc : FrameClass) (Γ : FormalSystem.MinusLanguage.Context) : Prop :=
  ¬ Derivable fc Γ MinusFormula.bot

/-- Mirror of `Core.SetConsistent`. -/
def MinusSetConsistent (fc : FrameClass) (S : Set MinusFormula) : Prop :=
  ∀ L : FormalSystem.MinusLanguage.Context, (∀ φ ∈ L, φ ∈ S) → MinusConsistent fc L

/-- Mirror of `Core.SetMaximalConsistent`. -/
def MinusSetMaximalConsistent (fc : FrameClass) (S : Set MinusFormula) : Prop :=
  MinusSetConsistent fc S ∧ ∀ φ : MinusFormula, φ ∉ S → ¬ MinusSetConsistent fc (insert φ S)

/-- `Core.exists_maximal_of_chainClosed`, stated for an arbitrary carrier: the L side's copy is
pinned to `Set Formula` only by its binder, and the proof is unchanged. -/
theorem exists_maximal_of_chainClosed {α : Type} {P : Set α → Prop}
    (hchain : ∀ C : Set (Set α), (∀ T ∈ C, P T) → IsChain (· ⊆ ·) C → C.Nonempty → P (⋃₀ C))
    {S : Set α} (hS : P S) :
    ∃ M : Set α, S ⊆ M ∧ P M ∧ ∀ ψ : α, ψ ∉ M → ¬ P (insert ψ M) := by
  let CS : Set (Set α) := {T | S ⊆ T ∧ P T}
  have hch : ∀ C ⊆ CS, IsChain (· ⊆ ·) C → C.Nonempty → ∃ ub ∈ CS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    refine ⟨⋃₀ C, ⟨?_, ?_⟩, fun T hT => Set.subset_sUnion_of_mem hT⟩
    · obtain ⟨T, hT⟩ := hCne
      exact Set.Subset.trans (hCsub hT).1 (Set.subset_sUnion_of_mem hT)
    · exact hchain C (fun T hT => (hCsub hT).2) hCchain hCne
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty CS hch S ⟨Set.Subset.refl S, hS⟩
  refine ⟨M, hSM, hmax.prop.2, ?_⟩
  intro ψ hψ hP
  exact hψ (hmax.le_of_ge ⟨Set.Subset.trans hSM (Set.subset_insert ψ M), hP⟩
    (Set.subset_insert ψ M) (Set.mem_insert ψ M))

/-- Mirror of `Core.finite_list_in_chain_member`, generic carrier. -/
theorem finite_list_in_chain_member {α : Type} {C : Set (Set α)}
    (hchain : IsChain (· ⊆ ·) C) (L : List α) (hL : ∀ φ ∈ L, φ ∈ ⋃₀ C) :
    C.Nonempty → ∃ S ∈ C, ∀ φ ∈ L, φ ∈ S := by
  intro hCne
  induction L with
  | nil =>
    obtain ⟨S, hS⟩ := hCne
    exact ⟨S, hS, fun _ h => (List.not_mem_nil h).elim⟩
  | cons ψ L' ih =>
    have hψ : ψ ∈ ⋃₀ C := hL ψ List.mem_cons_self
    have hL' : ∀ φ ∈ L', φ ∈ ⋃₀ C := fun φ h => hL φ (List.mem_cons_of_mem _ h)
    obtain ⟨S₁, hS₁mem, hψS₁⟩ := Set.mem_sUnion.mp hψ
    obtain ⟨S₂, hS₂mem, hL'S₂⟩ := ih hL'
    rcases hchain.total hS₁mem hS₂mem with h | h
    · exact ⟨S₂, hS₂mem, fun φ hφ =>
        match List.mem_cons.mp hφ with
        | .inl heq => heq ▸ h hψS₁
        | .inr hmem => hL'S₂ φ hmem⟩
    · exact ⟨S₁, hS₁mem, fun φ hφ =>
        match List.mem_cons.mp hφ with
        | .inl heq => heq ▸ hψS₁
        | .inr hmem => h (hL'S₂ φ hmem)⟩

/-- Mirror of `Core.consistent_chain_union`. -/
theorem minus_consistent_chain_union {fc : FrameClass} {C : Set (Set MinusFormula)}
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, MinusSetConsistent fc S) : MinusSetConsistent fc (⋃₀ C) := by
  intro L hL
  obtain ⟨S, hSmem, hLS⟩ := finite_list_in_chain_member hchain L hL hCne
  exact hcons S hSmem L hLS

/-- **Lindenbaum over L⁻**: mirror of `Core.set_lindenbaum`. -/
theorem minus_set_lindenbaum {fc : FrameClass} (S : Set MinusFormula)
    (hS : MinusSetConsistent fc S) :
    ∃ M : Set MinusFormula, S ⊆ M ∧ MinusSetMaximalConsistent fc M := by
  obtain ⟨M, hSM, hM, hmax⟩ :=
    exists_maximal_of_chainClosed (P := MinusSetConsistent fc)
      (fun _C hc hchain hne => minus_consistent_chain_union hchain hne hc) hS
  exact ⟨M, hSM, hM, hmax⟩

/-- Mirror of `BXCanonical.neg_consistent_of_not_derivable`, through the L⁻ deduction theorem
and `minusDne`. Simplified: every element of a list drawn from `{¬φ}` is `¬φ`, so the
derivation weakens to context `[¬φ]`. -/
theorem neg_consistent_of_not_minus_derivable {fc : FrameClass} (φ : MinusFormula)
    (h : ¬ Derivable fc [] φ) :
    MinusSetConsistent fc ({φ.neg} : Set MinusFormula) := by
  intro L hL ⟨d⟩
  have hsub : L ⊆ [φ.neg] := fun ψ hψ => by
    have := hL ψ hψ
    simp only [Set.mem_singleton_iff] at this
    simp [this]
  have d1 : DerivationTree fc [φ.neg] MinusFormula.bot := .weakening L _ _ d hsub
  have d2 : DerivationTree fc [] φ.neg.neg := minusDeductionTheorem [] φ.neg .bot d1
  exact h ⟨.modus_ponens [] _ _ (minusDne φ) d2⟩

/-! ## 2. Canonical relations, definitions only -/

/-- The canonical `G`-relation on L⁻ MCSs: `Γ R Δ` iff every `Gχ ∈ Γ` has `χ ∈ Δ`. -/
def canR (Γ Δ : Set MinusFormula) : Prop :=
  ∀ χ : MinusFormula, χ.allFuture ∈ Γ → χ ∈ Δ

/-- The canonical `□`-relation: `Γ ~ Δ` iff every `□χ ∈ Γ` has `χ ∈ Δ`. -/
def canBox (Γ Δ : Set MinusFormula) : Prop :=
  ∀ χ : MinusFormula, χ.box ∈ Γ → χ ∈ Δ

/-- A ℚ-chronicle: coherent (`q < q' → c q R c q'`) and F/P-witnessing. The chain the truth
lemma runs along; the bundle index `FamIdx` is the subtype of these lying in one `canBox`-class. -/
structure Chronicle (fc : FrameClass) where
  c : ℚ → Set MinusFormula
  mcs : ∀ q, MinusSetMaximalConsistent fc (c q)
  coh : ∀ q q', q < q' → canR (c q) (c q')
  witF : ∀ q ψ, ψ.someFuture ∈ c q → ∃ q', q < q' ∧ ψ ∈ c q'
  witP : ∀ q ψ, ψ.somePast ∈ c q → ∃ q', q' < q ∧ ψ ∈ c q'

/-! ## 3. Final assembly shape -/

/-- A single refutation on a ℚ-chain bundle refutes `ChainValidIn .Dense`. The `.Dense` side
condition for `multiFamTaskFrameGen (TemporalOrder.of ℚ) FamIdx` is `inferInstance`, exactly as
in `not_minusValidDense_of_not_chainSat`. -/
theorem not_chainValidIn_dense_of_rat_refutation (φ : MinusFormula) (FamIdx : Type)
    [Nonempty FamIdx]
    (v : FamIdx × ((FormalSystem.Semantics.TemporalOrder.of ℚ) : Type) → Atom → Prop)
    (q : FamIdx × ((FormalSystem.Semantics.TemporalOrder.of ℚ) : Type))
    (h : ¬ chainSat v q φ) : ¬ ChainValidIn FrameClass.Dense φ :=
  fun hv => h (hv (FormalSystem.Semantics.TemporalOrder.of ℚ) FamIdx inferInstance v q)

/-- The contrapositive skeleton of `chainComplete_dense`: given a refutation engine, the
`ChainComplete` target follows through `minusExt_empty_iff`. Only the engine's existence is
hypothesised here (as a binder, never a `sorry`). -/
theorem chainComplete_dense_of_engine
    (engine : ∀ φ : MinusFormula, ¬ Derivable FrameClass.Dense [] φ →
      ∃ (FamIdx : Type) (_ : Nonempty FamIdx)
        (v : FamIdx × ((FormalSystem.Semantics.TemporalOrder.of ℚ) : Type) → Atom → Prop)
        (q : FamIdx × ((FormalSystem.Semantics.TemporalOrder.of ℚ) : Type)),
        ¬ chainSat v q φ) :
    ChainComplete FrameClass.Dense ∅ := by
  intro φ hv
  by_contra hn
  have hnd : ¬ Derivable FrameClass.Dense [] φ :=
    fun hd => hn (minusExt_empty_iff.mpr hd)
  obtain ⟨FamIdx, hne, v, q, hq⟩ := engine φ hnd
  exact not_chainValidIn_dense_of_rat_refutation φ FamIdx v q hq hv

/-! ## 4. Mathlib names for the ℚ step-by-step construction -/

#check @exists_surjective_nat
#check @Nat.unpair
#check @Nat.surjective_unpair
#check @exists_between
#check @Finset.max'
#check @Finset.min'
#check @Order.iso_of_countable_dense
example : DenselyOrdered ℚ := inferInstance
example : NoMaxOrder ℚ := inferInstance
example : NoMinOrder ℚ := inferInstance
example : Countable (ℚ × MinusFormula × Bool) := inferInstance
example : Nonempty (ℚ × MinusFormula × Bool) := ⟨(0, .bot, true)⟩

/-- Enumeration in which every requirement recurs infinitely often: compose a surjection
`ℕ → Req` with `Nat.unpair`'s first projection. -/
theorem exists_enum_infinitely_often {Req : Type} [Countable Req] [Nonempty Req] :
    ∃ e : ℕ → Req, ∀ r : Req, ∀ m : ℕ, ∃ n, m ≤ n ∧ e n = r := by
  obtain ⟨f, hf⟩ := exists_surjective_nat Req
  refine ⟨fun n => f (Nat.unpair n).1, fun r m => ?_⟩
  obtain ⟨k, hk⟩ := hf r
  refine ⟨Nat.pair k m, ?_, ?_⟩
  · exact Nat.right_le_pair k m
  · show f (Nat.unpair (Nat.pair k m)).1 = r
    rw [Nat.unpair_pair]
    exact hk

end Probe651
