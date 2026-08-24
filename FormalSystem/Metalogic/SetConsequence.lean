/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.ProofSystem.Derivable
import FormalSystem.Metalogic.Core.MaximalConsistent

/-!
# The Set-Based Consequence Layer

This module supplies the **vocabulary** for consequence from a possibly-infinite premise set
`Γ : Set Formula`: the finitary derivability relation `SetDerivable`, the four per-class
set-based semantic consequence predicates, the basic lemmas relating them to the finite-context
(`Γ : Context`) layer, and the statements — not the proofs — of strong completeness,
compactness, satisfiability and model existence for `FrameClass.Dense`.

It is vocabulary only. **No compactness result is proved here**, and no existing proof gap
anywhere in the tree is closed by this module. `CompactDense` and `ModelExistenceDense` are
`Prop`-valued definitions that name obligations; discharging them is future work.

## Design

* `SetDerivable` is deliberately shaped to match `Core.SetConsistent`
  (`Core/MaximalConsistent.lean:96`) so that the two compose without an adapter: a derivation is
  a finite object and can cite only finitely many premises, so finitary set-derivability is the
  only derivability notion a finitary proof system can support over `Set Formula`.
* Each `SetSemanticConsequence*` predicate is the corresponding validity predicate's binder list
  taken verbatim from `FormalSystem/Semantics/Validity.lean`, with the premise hypothesis
  `(∀ ψ ∈ Γ, TruthAt M τ t ψ)` inserted before the conclusion — the same surgery that
  `SemanticConsequenceDedekindDense` (`StrongCompleteness.lean:129`) performs on
  `ValidDedekindDense`. `Γ : Set Formula` rather than `Γ : Context` is the only difference from
  those finite-context forms; `∀ ψ ∈ Γ` elaborates identically for `Set` and `List`.
* Nothing here imports `FormalSystem/Metalogic/BXCanonical/`. The set layer is vocabulary; the
  chronicle machinery is a countermodel engine, and the two are deliberately kept unentangled.

## Downstream

`FormalSystem/Metalogic/StrongCompleteness.lean` imports this module. Because that module owns
`derivable_foldr_imp_iff`, the one *theorem* of the strong-completeness group —
`strongCompletenessDense_of_compact` — lives there rather than here; placing it in this module
would be an import cycle.
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/-! ## Finitary set-derivability -/

/--
Finitary derivability from a possibly-infinite premise set. A derivation is a finite object
and can cite only finitely many premises, so this is the only derivability notion a finitary
proof system can support over `Set Formula`.
-/
def SetDerivable (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop :=
  ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ

/-! ## Per-class set-based semantic consequence -/

/-- Set-based semantic consequence over `FrameClass.Base`. Binder list: `valid`
    (`Validity.lean:94`). -/
def SetSemanticConsequenceBase (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- Set-based semantic consequence over `FrameClass.Dense`. Binder list: `ValidDense`
    (`Validity.lean:206`). -/
def SetSemanticConsequenceDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- Set-based semantic consequence over `FrameClass.Discrete`. Binder list: `ValidDiscrete`
    (`Validity.lean:222`). Stated for completeness of the layer; strong completeness at this
    class is refuted by non-compactness. -/
def SetSemanticConsequenceDiscrete (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- Set-based semantic consequence over dense Dedekind-complete carriers. Binder list:
    `ValidDedekindDense` (`Validity.lean:310`) — the `soundness_dedekind` target. Non-compact. -/
def SetSemanticConsequenceDedekindDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-! ## Monotonicity -/

/-- Set-derivability is monotone in the premise set: a derivation citing finitely many
    premises from `Γ` cites those same premises from any superset. -/
theorem setDerivable_mono {fc : FrameClass} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetDerivable fc Γ φ) : SetDerivable fc Δ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact ⟨L, fun ψ hψ => h_sub (hL ψ hψ), hd⟩

/-- Base set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceBase_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceBase Γ φ) : SetSemanticConsequenceBase Δ φ := by
  intro D _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-- Dense set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDense Γ φ) : SetSemanticConsequenceDense Δ φ := by
  intro D _ _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-- Discrete set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceDiscrete_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDiscrete Γ φ) :
    SetSemanticConsequenceDiscrete Δ φ := by
  intro D _ _ _ _ _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-- Dense Dedekind-complete set-consequence is monotone in the premise set. The
    least-upper-bound hypothesis is an explicit binder, so it is threaded to `h` by name. -/
theorem setSemanticConsequenceDedekindDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDedekindDense Γ φ) :
    SetSemanticConsequenceDedekindDense Δ φ := by
  intro D _ _ _ _ _ hlub F M τ hτ t h_all
  exact h D hlub F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-! ## Finite restriction and agreement with the finite-context layer -/

/-- Every set-derivation restricts to a finite context. Definitional, but worth naming: it is
    the statement the compactness argument consumes. -/
theorem setDerivable_iff_exists_finite {fc : FrameClass} (Γ : Set Formula) (φ : Formula) :
    SetDerivable fc Γ φ ↔ ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ :=
  Iff.rfl

/-- A finite context is set-derivable from its own carrier set. -/
theorem setDerivable_of_derivable {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : Derivable fc Γ φ) : SetDerivable fc (Core.contextToSet Γ) φ :=
  ⟨Γ, fun _ hψ => hψ, h⟩

/-- …and conversely, so the set layer is a conservative extension of the finite layer.

    `Derivable.weaken` (`ProofSystem/Derivable.lean:147`) wants a `Context` subset relation
    `L ⊆ Γ`, whereas the set-derivation supplies `∀ ψ ∈ L, ψ ∈ Core.contextToSet Γ`. Since
    `Core.contextToSet Γ = {φ | φ ∈ Γ}` (`Core/MaximalConsistent.lean:123`) these are
    definitionally the same statement, and the eta-expansion below is all that is needed. -/
theorem derivable_of_setDerivable_contextToSet {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : SetDerivable fc (Core.contextToSet Γ) φ) : Derivable fc Γ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact hd.weaken (fun _ hx => hL _ hx)

/-- Membership gives derivability: the singleton context `[φ]` derives `φ` by the assumption
    rule (`ProofSystem/Derivation.lean:105`), and `Derivable` is `Nonempty (DerivationTree …)`
    (`ProofSystem/Derivable.lean:69`), so the outer anonymous constructor is `Nonempty.intro`. -/
theorem setDerivable_of_mem {fc : FrameClass} {Γ : Set Formula} {φ : Formula} (h : φ ∈ Γ) :
    SetDerivable fc Γ φ :=
  ⟨[φ], by simpa using h, ⟨DerivationTree.assumption _ _ (by simp)⟩⟩

/-! ## The bridge to `Core.SetConsistent` -/

/-- Deriving `⊥` from a set refutes its consistency. `Core.SetConsistent`
    (`Core/MaximalConsistent.lean:96`) unfolds to `∀ L, (∀ φ ∈ L, φ ∈ S) → Consistent L` and
    `Consistent` (`:67`) to `¬Derivable fc Γ Formula.bot`, both definitionally, so the finite
    witness of the set-derivation applies directly. -/
theorem not_setConsistent_of_setDerivable_bot {fc : FrameClass} {Γ : Set Formula}
    (h : SetDerivable fc Γ Formula.bot) : ¬ Core.SetConsistent (fc := fc) Γ := by
  obtain ⟨L, hL, hd⟩ := h
  exact fun hcons => hcons L hL hd

end FormalSystem.Metalogic
