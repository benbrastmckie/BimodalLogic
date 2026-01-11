import Bimodal.Syntax
import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic

/-!
# Integration Test Helpers

Reusable helper functions and utilities for integration testing.

## Main Components

* Formula builders - Construct test formulas
* Derivation builders - Construct test derivations
* Verification helpers - Verify soundness and validity
* Test assertions - Common test patterns

## Usage

```lean
import LogosTest.Core.Integration.Helpers

open LogosTest.Core.Integration.Helpers

-- Build test formula
let φ := mk_atom "p"
let ψ := mk_box φ

-- Build derivation
let deriv := mk_axiom_deriv (ψ.imp φ) (Axiom.modal_t φ)

-- Verify soundness
have valid := verify_validity (ψ.imp φ) deriv
```
-/

namespace LogosTest.Core.Integration.Helpers

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic

-- ============================================================
-- Formula Builders
-- ============================================================

/-- Build simple atomic formula -/
def mk_atom (name : String) : Formula := Formula.atom name

/-- Build implication -/
def mk_imp (φ ψ : Formula) : Formula := φ.imp ψ

/-- Build box formula -/
def mk_box (φ : Formula) : Formula := φ.box

/-- Build diamond formula -/
def mk_diamond (φ : Formula) : Formula := φ.diamond

/-- Build future formula -/
def mk_future (φ : Formula) : Formula := φ.all_future

/-- Build past formula -/
def mk_past (φ : Formula) : Formula := φ.all_past

/-- Build complex nested modal formula with given depth -/
def mk_nested_modal (φ : Formula) (depth : Nat) : Formula :=
  match depth with
  | 0 => φ
  | n+1 => (mk_nested_modal φ n).box

/-- Build complex nested temporal formula with given depth -/
def mk_nested_temporal (φ : Formula) (depth : Nat) : Formula :=
  match depth with
  | 0 => φ
  | n+1 => (mk_nested_temporal φ n).all_future

/-- Build bimodal formula (box + future) -/
def mk_bimodal (φ : Formula) : Formula := φ.box.all_future

-- ============================================================
-- Derivation Builders
-- ============================================================

/-- Build axiom derivation -/
def mk_axiom_deriv (φ : Formula) (h : Axiom φ) : DerivationTree [] φ :=
  DerivationTree.axiom [] φ h

/-- Build assumption derivation -/
def mk_assumption_deriv (Γ : Context) (φ : Formula) (h : φ ∈ Γ) :
    DerivationTree Γ φ :=
  DerivationTree.assumption Γ φ h

/-- Build modus ponens derivation -/
def mk_mp_deriv (Γ : Context) (φ ψ : Formula)
    (d1 : DerivationTree Γ (φ.imp ψ))
    (d2 : DerivationTree Γ φ) : DerivationTree Γ ψ :=
  DerivationTree.modus_ponens Γ φ ψ d1 d2

/-- Build modal necessitation derivation -/
def mk_necessitation_deriv (φ : Formula)
    (d : DerivationTree [] φ) : DerivationTree [] (φ.box) :=
  DerivationTree.necessitation φ d

/-- Build temporal necessitation derivation -/
def mk_temporal_necessitation_deriv (φ : Formula)
    (d : DerivationTree [] φ) : DerivationTree [] (φ.all_future) :=
  DerivationTree.temporal_necessitation φ d

/-- Build weakening derivation -/
def mk_weakening_deriv (Γ Δ : Context) (φ : Formula)
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) : DerivationTree Δ φ :=
  DerivationTree.weakening Γ Δ φ d h

-- ============================================================
-- Verification Helpers
-- ============================================================

/-- Verify soundness of derivation -/
def verify_soundness (Γ : Context) (φ : Formula) (d : DerivationTree Γ φ) :
    Γ ⊨ φ :=
  soundness Γ φ d

/-- Verify validity of theorem -/
def verify_validity (φ : Formula) (d : DerivationTree [] φ) : ⊨ φ :=
  Validity.valid_iff_empty_consequence φ |>.mpr (soundness [] φ d)

/-- Verify workflow: derivation → soundness → validity -/
def verify_workflow (φ : Formula) (d : DerivationTree [] φ) : True := by
  have _valid : ⊨ φ := verify_validity φ d
  trivial

-- ============================================================
-- Test Assertions
-- ============================================================

/-- Assert derivation exists -/
def assert_derivable (Γ : Context) (φ : Formula) : Prop :=
  Nonempty (DerivationTree Γ φ)

/-- Assert formula is valid -/
def assert_valid (φ : Formula) : Prop :=
  valid φ

/-- Assert soundness holds -/
def assert_sound (Γ : Context) (φ : Formula) (d : DerivationTree Γ φ) : Prop :=
  Γ ⊨ φ

end LogosTest.Core.Integration.Helpers
