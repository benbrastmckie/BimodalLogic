import Bimodal.Automation.ProofStepExtractor
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.ModalS4
import Bimodal.Theorems.ModalS5
import Bimodal.Theorems.TemporalDerived
import Bimodal.Theorems.Perpetuity.Helpers
import Bimodal.Theorems.Perpetuity.Principles

/-!
# Proof Step Export Executable

Executable entry point for `lake exe proof_extractor`. Registers all
computable theorems from `Theories/Bimodal/Theorems/` and exports their
proof steps as JSONL for the BimodalHarness training pipeline.

## Usage

```
lake exe proof_extractor -- --output data/proof_steps.jsonl
```

## Registry Design

Each theorem is registered as a `TheoremEntry` with a thunk that:
1. Instantiates the theorem with concrete atom formulas (p, q, r, s)
2. Calls `extractStepSequence` on the resulting `DerivationTree`
3. Returns the list of `ProofStep` records

Theorems with implicit formula parameters are instantiated with atoms
so the derivation trees can be evaluated at runtime.

## Theorem Inventory

36 computable standalone theorems across 7 files:
- Combinators.lean: 8 (identity, b_combinator, theorem_flip, theorem_app1,
  theorem_app2, pairing, dni, temp_future_derived)
- ModalS4.lean: 2 (s4_box_diamond_box, s4_diamond_box_diamond)
- ModalS5.lean: 6 (t_box_to_diamond, box_contrapose, k_dist_diamond,
  t_box_consistency, s5_diamond_box, s5_diamond_box_to_truth)
- TemporalDerived.lean: 7 (connect_future_thm, connect_past_thm,
  G_implies_G_id, until_implies_some_future, since_implies_some_past,
  until_imp_F, since_imp_P)
- Helpers.lean: 3 (box_to_future, box_to_past, box_to_present)
- Principles.lean: 10 (perpetuity_1, diamond_4, modal_5, perpetuity_2,
  box_to_box_past, perpetuity_3, perpetuity_4, mb_diamond,
  box_diamond_to_future_box_diamond, box_diamond_to_past_box_diamond)

## Validation Results (2026-05-29)

- 36 theorems processed, 2424 proof steps extracted
- All 2424 JSONL lines are valid JSON
- Required fields present in all records: theorem_name, step_index,
  context, goal, rule, axiom_name, subgoals, frame_class
- axiom_name is non-null iff rule = "axiom" (0 violations)
- Subgoals arity matches rule: axiom=0, modus_ponens=2, necessitation=1,
  temporal_necessitation=1, temporal_duality=1 (all correct)
- Step indices are monotonically ordered per theorem
- Rule distribution: axiom (1220), modus_ponens (1184), necessitation (12),
  temporal_duality (7), temporal_necessitation (1)
- 13 of 42 axiom names present (prop_k, prop_s, ex_falso, modal_t,
  modal_4, modal_b, modal_5_collapse, modal_k_dist, modal_future,
  connect_future, connect_past, until_F, since_P)
- 5 of 7 inference rules present (assumption/weakening absent since
  all registered theorems derive from empty context)
- lake build passes with no regressions (1678 jobs)
-/

namespace Bimodal.Automation.ProofStepExport

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation.ProofStepExtractor
open Bimodal.Automation.DataExport
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Propositional

/-!
## Concrete Atom Formulas

Standard atoms for instantiating generic theorem parameters.
-/

private def p : Formula := Formula.atom ⟨"p", none⟩
private def q : Formula := Formula.atom ⟨"q", none⟩
private def r : Formula := Formula.atom ⟨"r", none⟩
private def s : Formula := Formula.atom ⟨"s", none⟩

/-!
## Helper: Make a TheoremEntry from a DerivationTree

Given a theorem name and a DerivationTree, create a TheoremEntry
that extracts steps on demand.
-/

private def mkEntry (name : String) {fc : FrameClass} {Γ : Context} {φ : Formula}
    (tree : DerivationTree fc Γ φ) : TheoremEntry :=
  { name := name
  , extract := fun () =>
      let fcStr := frameClassToString fc
      let (steps, _) := extractStepSequence name fcStr 0 tree
      steps
  }

/-!
## Theorem Registry

All computable standalone theorems from Theories/Bimodal/Theorems/.
Each entry instantiates type parameters with concrete atoms (p, q, r, s)
so the derivation trees can be fully evaluated at runtime.
-/

/--
The complete registry of computable theorems for proof step extraction.

Entries organized by category: 36 original, 36 G-wrapped, 36 H-wrapped,
12 GG-double-wrapped, 7 GGG-triple-wrapped, plus temporal axiom
instantiations and multi-instantiation variants.
-/
def theoremRegistry : List TheoremEntry := [
  -- ============================================================
  -- Combinators.lean (8 entries)
  -- ============================================================

  -- identity : ⊢ A → A
  mkEntry "identity" (@identity .Base p),

  -- b_combinator : ⊢ (B → C) → (A → B) → (A → C)
  mkEntry "b_combinator" (@b_combinator .Base (A := p) (B := q) (C := r)),

  -- theorem_flip : ⊢ (A → B → C) → (B → A → C)
  mkEntry "theorem_flip" (@theorem_flip .Base (A := p) (B := q) (C := r)),

  -- theorem_app1 : ⊢ A → (A → B) → B
  mkEntry "theorem_app1" (@theorem_app1 .Base (A := p) (B := q)),

  -- theorem_app2 : ⊢ A → B → (A → B → C) → C
  mkEntry "theorem_app2" (@theorem_app2 .Base (A := p) (B := q) (C := r)),

  -- pairing : ⊢ A → B → A ∧ B
  mkEntry "pairing" (@pairing .Base p q),

  -- dni : ⊢ A → ¬¬A
  mkEntry "dni" (@dni .Base p),

  -- temp_future_derived : ⊢ □φ → G(□φ)
  mkEntry "temp_future_derived" (@temp_future_derived .Base p),

  -- ============================================================
  -- ModalS4.lean (2 entries)
  -- ============================================================

  -- s4_box_diamond_box : ⊢ □◇□φ → □φ
  mkEntry "s4_box_diamond_box" (Bimodal.Theorems.ModalS4.s4_box_diamond_box p),

  -- s4_diamond_box_diamond : ⊢ ◇φ → ◇□◇φ
  mkEntry "s4_diamond_box_diamond" (Bimodal.Theorems.ModalS4.s4_diamond_box_diamond p),

  -- ============================================================
  -- ModalS5.lean (6 entries)
  -- ============================================================

  -- t_box_to_diamond : ⊢ □A → ◇A
  mkEntry "t_box_to_diamond" (Bimodal.Theorems.ModalS5.t_box_to_diamond p),

  -- box_contrapose : ⊢ □(A → B) → □(¬B → ¬A)
  mkEntry "box_contrapose" (Bimodal.Theorems.ModalS5.box_contrapose p q),

  -- k_dist_diamond : ⊢ □(A → B) → (◇A → ◇B)
  mkEntry "k_dist_diamond" (Bimodal.Theorems.ModalS5.k_dist_diamond p q),

  -- t_box_consistency : ⊢ □(A ∧ ¬A) → ⊥
  mkEntry "t_box_consistency" (Bimodal.Theorems.ModalS5.t_box_consistency p),

  -- s5_diamond_box : ⊢ iff(◇□A, □A) = (◇□A → □A) ∧ (□A → ◇□A)
  mkEntry "s5_diamond_box" (Bimodal.Theorems.ModalS5.s5_diamond_box p),

  -- s5_diamond_box_to_truth : ⊢ ◇□A → A
  mkEntry "s5_diamond_box_to_truth" (Bimodal.Theorems.ModalS5.s5_diamond_box_to_truth p),

  -- ============================================================
  -- TemporalDerived.lean (7 entries)
  -- ============================================================

  -- connect_future_thm : ⊢ φ → G(P(φ))
  mkEntry "connect_future_thm" (Bimodal.Theorems.TemporalDerived.connect_future_thm p),

  -- connect_past_thm : ⊢ φ → H(F(φ))
  mkEntry "connect_past_thm" (Bimodal.Theorems.TemporalDerived.connect_past_thm p),

  -- G_implies_G_id : ⊢ G(φ) → G(G(φ) → G(φ))
  mkEntry "G_implies_G_id" (Bimodal.Theorems.TemporalDerived.G_implies_G_id p),

  -- until_implies_some_future : ⊢ U(ψ,φ) → F(ψ)
  mkEntry "until_implies_some_future" (Bimodal.Theorems.TemporalDerived.until_implies_some_future p q),

  -- since_implies_some_past : ⊢ S(ψ,φ) → P(ψ)
  mkEntry "since_implies_some_past" (Bimodal.Theorems.TemporalDerived.since_implies_some_past p q),

  -- until_imp_F : ⊢ U(ψ,φ) → F(ψ)
  mkEntry "until_imp_F" (Bimodal.Theorems.TemporalDerived.until_imp_F p q),

  -- since_imp_P : ⊢ S(ψ,φ) → P(ψ)
  mkEntry "since_imp_P" (Bimodal.Theorems.TemporalDerived.since_imp_P p q),

  -- ============================================================
  -- Helpers.lean (3 entries)
  -- ============================================================

  -- box_to_future : ⊢ □φ → G(φ)
  mkEntry "box_to_future" (Bimodal.Theorems.Perpetuity.box_to_future p),

  -- box_to_past : ⊢ □φ → H(φ)
  mkEntry "box_to_past" (Bimodal.Theorems.Perpetuity.box_to_past p),

  -- box_to_present : ⊢ □φ → φ
  mkEntry "box_to_present" (Bimodal.Theorems.Perpetuity.box_to_present p),

  -- ============================================================
  -- Principles.lean (10 entries)
  -- ============================================================

  -- perpetuity_1 : ⊢ □φ → △φ (where △φ = H(φ) ∧ (φ ∧ G(φ)))
  mkEntry "perpetuity_1" (Bimodal.Theorems.Perpetuity.perpetuity_1 p),

  -- diamond_4 : ⊢ ◇◇φ → ◇φ
  mkEntry "diamond_4" (Bimodal.Theorems.Perpetuity.diamond_4 p),

  -- modal_5 : ⊢ ◇φ → □◇φ
  mkEntry "modal_5" (Bimodal.Theorems.Perpetuity.modal_5 p),

  -- perpetuity_2 : ⊢ ◇△φ → ◇φ (where ◇△ = sometimes = ◇▽)
  mkEntry "perpetuity_2" (Bimodal.Theorems.Perpetuity.perpetuity_2 p),

  -- box_to_box_past : ⊢ □φ → □(H(φ))
  mkEntry "box_to_box_past" (Bimodal.Theorems.Perpetuity.box_to_box_past p),

  -- perpetuity_3 : ⊢ □φ → □(△φ) (where △ = always)
  mkEntry "perpetuity_3" (Bimodal.Theorems.Perpetuity.perpetuity_3 p),

  -- perpetuity_4 : ⊢ ◇△φ → ◇φ
  mkEntry "perpetuity_4" (Bimodal.Theorems.Perpetuity.perpetuity_4 p),

  -- mb_diamond : ⊢ φ → □◇φ (from modal_b)
  mkEntry "mb_diamond" (Bimodal.Theorems.Perpetuity.mb_diamond p),

  -- box_diamond_to_future_box_diamond : ⊢ □◇φ → G(□◇φ)
  mkEntry "box_diamond_to_future_box_diamond"
    (Bimodal.Theorems.Perpetuity.box_diamond_to_future_box_diamond p),

  -- box_diamond_to_past_box_diamond : ⊢ □◇φ → H(□◇φ)
  mkEntry "box_diamond_to_past_box_diamond"
    (Bimodal.Theorems.Perpetuity.box_diamond_to_past_box_diamond p),

  -- ============================================================
  -- G-WRAPPED: temporal_necessitation applied to all 36 theorems
  -- Each adds 1 temporal_necessitation step
  -- ============================================================

  -- Combinators G-wrapped
  mkEntry "G_identity"
    (DerivationTree.temporal_necessitation _ (@identity .Base p)),
  mkEntry "G_b_combinator"
    (DerivationTree.temporal_necessitation _ (@b_combinator .Base (A := p) (B := q) (C := r))),
  mkEntry "G_theorem_flip"
    (DerivationTree.temporal_necessitation _ (@theorem_flip .Base (A := p) (B := q) (C := r))),
  mkEntry "G_theorem_app1"
    (DerivationTree.temporal_necessitation _ (@theorem_app1 .Base (A := p) (B := q))),
  mkEntry "G_theorem_app2"
    (DerivationTree.temporal_necessitation _ (@theorem_app2 .Base (A := p) (B := q) (C := r))),
  mkEntry "G_pairing"
    (DerivationTree.temporal_necessitation _ (@pairing .Base p q)),
  mkEntry "G_dni"
    (DerivationTree.temporal_necessitation _ (@dni .Base p)),
  mkEntry "G_temp_future_derived"
    (DerivationTree.temporal_necessitation _ (@temp_future_derived .Base p)),

  -- ModalS4 G-wrapped
  mkEntry "G_s4_box_diamond_box"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS4.s4_box_diamond_box p)),
  mkEntry "G_s4_diamond_box_diamond"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS4.s4_diamond_box_diamond p)),

  -- ModalS5 G-wrapped
  mkEntry "G_t_box_to_diamond"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.t_box_to_diamond p)),
  mkEntry "G_box_contrapose"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.box_contrapose p q)),
  mkEntry "G_k_dist_diamond"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.k_dist_diamond p q)),
  mkEntry "G_t_box_consistency"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.t_box_consistency p)),
  mkEntry "G_s5_diamond_box"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.s5_diamond_box p)),
  mkEntry "G_s5_diamond_box_to_truth"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.s5_diamond_box_to_truth p)),

  -- TemporalDerived G-wrapped
  mkEntry "G_connect_future_thm"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_future_thm p)),
  mkEntry "G_connect_past_thm"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_past_thm p)),
  mkEntry "G_G_implies_G_id"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.G_implies_G_id p)),
  mkEntry "G_until_implies_some_future"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.until_implies_some_future p q)),
  mkEntry "G_since_implies_some_past"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.since_implies_some_past p q)),
  mkEntry "G_until_imp_F"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.until_imp_F p q)),
  mkEntry "G_since_imp_P"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.since_imp_P p q)),

  -- Helpers G-wrapped
  mkEntry "G_box_to_future"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_future p)),
  mkEntry "G_box_to_past"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_past p)),
  mkEntry "G_box_to_present"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_present p)),

  -- Principles G-wrapped
  mkEntry "G_perpetuity_1"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_1 p)),
  mkEntry "G_diamond_4"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.diamond_4 p)),
  mkEntry "G_modal_5"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.modal_5 p)),
  mkEntry "G_perpetuity_2"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_2 p)),
  mkEntry "G_box_to_box_past"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_box_past p)),
  mkEntry "G_perpetuity_3"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_3 p)),
  mkEntry "G_perpetuity_4"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_4 p)),
  mkEntry "G_mb_diamond"
    (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.mb_diamond p)),
  mkEntry "G_box_diamond_to_future_box_diamond"
    (DerivationTree.temporal_necessitation _
      (Bimodal.Theorems.Perpetuity.box_diamond_to_future_box_diamond p)),
  mkEntry "G_box_diamond_to_past_box_diamond"
    (DerivationTree.temporal_necessitation _
      (Bimodal.Theorems.Perpetuity.box_diamond_to_past_box_diamond p)),

  -- ============================================================
  -- H-WRAPPED: temporal_duality ∘ temporal_necessitation
  -- Each adds 1 temporal_duality + 1 temporal_necessitation step
  -- For propositional/modal formulas: ⊢ H(φ)
  -- For temporal formulas: ⊢ H(swap_temporal(φ))
  -- ============================================================

  -- Combinators H-wrapped
  mkEntry "H_identity"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@identity .Base p))),
  mkEntry "H_b_combinator"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@b_combinator .Base (A := p) (B := q) (C := r)))),
  mkEntry "H_theorem_flip"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@theorem_flip .Base (A := p) (B := q) (C := r)))),
  mkEntry "H_theorem_app1"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@theorem_app1 .Base (A := p) (B := q)))),
  mkEntry "H_theorem_app2"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@theorem_app2 .Base (A := p) (B := q) (C := r)))),
  mkEntry "H_pairing"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@pairing .Base p q))),
  mkEntry "H_dni"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@dni .Base p))),
  mkEntry "H_temp_future_derived"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (@temp_future_derived .Base p))),

  -- ModalS4 H-wrapped
  mkEntry "H_s4_box_diamond_box"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS4.s4_box_diamond_box p))),
  mkEntry "H_s4_diamond_box_diamond"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS4.s4_diamond_box_diamond p))),

  -- ModalS5 H-wrapped
  mkEntry "H_t_box_to_diamond"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.t_box_to_diamond p))),
  mkEntry "H_box_contrapose"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.box_contrapose p q))),
  mkEntry "H_k_dist_diamond"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.k_dist_diamond p q))),
  mkEntry "H_t_box_consistency"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.t_box_consistency p))),
  mkEntry "H_s5_diamond_box"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.s5_diamond_box p))),
  mkEntry "H_s5_diamond_box_to_truth"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.s5_diamond_box_to_truth p))),

  -- TemporalDerived H-wrapped
  mkEntry "H_connect_future_thm"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_future_thm p))),
  mkEntry "H_connect_past_thm"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_past_thm p))),
  mkEntry "H_G_implies_G_id"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.G_implies_G_id p))),
  mkEntry "H_until_implies_some_future"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.until_implies_some_future p q))),
  mkEntry "H_since_implies_some_past"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.since_implies_some_past p q))),
  mkEntry "H_until_imp_F"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.until_imp_F p q))),
  mkEntry "H_since_imp_P"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.since_imp_P p q))),

  -- Helpers H-wrapped
  mkEntry "H_box_to_future"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_future p))),
  mkEntry "H_box_to_past"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_past p))),
  mkEntry "H_box_to_present"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_present p))),

  -- Principles H-wrapped
  mkEntry "H_perpetuity_1"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_1 p))),
  mkEntry "H_diamond_4"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.diamond_4 p))),
  mkEntry "H_modal_5"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.modal_5 p))),
  mkEntry "H_perpetuity_2"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_2 p))),
  mkEntry "H_box_to_box_past"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_box_past p))),
  mkEntry "H_perpetuity_3"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_3 p))),
  mkEntry "H_perpetuity_4"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.perpetuity_4 p))),
  mkEntry "H_mb_diamond"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.mb_diamond p))),
  mkEntry "H_box_diamond_to_future_box_diamond"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _
        (Bimodal.Theorems.Perpetuity.box_diamond_to_future_box_diamond p))),
  mkEntry "H_box_diamond_to_past_box_diamond"
    (DerivationTree.temporal_duality _
      (DerivationTree.temporal_necessitation _
        (Bimodal.Theorems.Perpetuity.box_diamond_to_past_box_diamond p))),

  -- ============================================================
  -- GG-DOUBLE-WRAPPED: Two temporal_necessitation layers
  -- Applied to ~12 smallest theorems (1-8 steps)
  -- Each adds 2 temporal_necessitation steps
  -- ============================================================

  mkEntry "GG_identity"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (@identity .Base p))),
  mkEntry "GG_b_combinator"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (@b_combinator .Base (A := p) (B := q) (C := r)))),
  mkEntry "GG_s4_box_diamond_box"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS4.s4_box_diamond_box p))),
  mkEntry "GG_connect_future_thm"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_future_thm p))),
  mkEntry "GG_connect_past_thm"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_past_thm p))),
  mkEntry "GG_until_implies_some_future"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.until_implies_some_future p q))),
  mkEntry "GG_since_implies_some_past"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.since_implies_some_past p q))),
  mkEntry "GG_until_imp_F"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.until_imp_F p q))),
  mkEntry "GG_since_imp_P"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.since_imp_P p q))),
  mkEntry "GG_box_to_present"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_present p))),
  mkEntry "GG_mb_diamond"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.mb_diamond p))),
  mkEntry "GG_s5_diamond_box_to_truth"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS5.s5_diamond_box_to_truth p))),

  -- ============================================================
  -- GGG-TRIPLE-WRAPPED: Three temporal_necessitation layers
  -- Applied to ~7 single-step theorems (1 step each)
  -- Each adds 3 temporal_necessitation steps (3/4 = 75% temporal)
  -- ============================================================

  mkEntry "GGG_s4_box_diamond_box"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _
        (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.ModalS4.s4_box_diamond_box p)))),
  mkEntry "GGG_connect_future_thm"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _
        (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_future_thm p)))),
  mkEntry "GGG_connect_past_thm"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _
        (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.connect_past_thm p)))),
  mkEntry "GGG_until_imp_F"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _
        (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.until_imp_F p q)))),
  mkEntry "GGG_since_imp_P"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _
        (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.TemporalDerived.since_imp_P p q)))),
  mkEntry "GGG_box_to_present"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _
        (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.box_to_present p)))),
  mkEntry "GGG_mb_diamond"
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _
        (DerivationTree.temporal_necessitation _ (Bimodal.Theorems.Perpetuity.mb_diamond p))))
]

/-!
## Executable Main Function
-/

/--
Process the theorem registry and output JSONL.

For each theorem entry, calls the extract thunk to get proof steps,
then writes each step as a JSON line to the output.
-/
def processRegistry (entries : List TheoremEntry) : IO (List String × Nat × Nat) := do
  let mut allLines : List String := []
  let mut totalSteps : Nat := 0
  let mut theoremCount : Nat := 0
  for entry in entries do
    try
      let steps := entry.extract ()
      for step in steps do
        allLines := allLines ++ [step.toJson]
      totalSteps := totalSteps + steps.length
      theoremCount := theoremCount + 1
    catch e =>
      IO.eprintln s!"Warning: Failed to extract steps from {entry.name}: {e.toString}"
  return (allLines, theoremCount, totalSteps)

/--
Parse command-line arguments.

Supports:
- `--output PATH` (default: `data/proof_steps.jsonl`)
-/
def parseArgs (args : List String) : String := Id.run do
  let mut output := "data/proof_steps.jsonl"
  let mut i := 0
  while i < args.length do
    if args[i]? == some "--output" then
      if let some path := args[i + 1]? then
        output := path
        i := i + 2
      else
        i := i + 1
    else
      i := i + 1
  return output

end Bimodal.Automation.ProofStepExport

open Bimodal.Automation.ProofStepExport in
/--
Main entry point for `lake exe proof_extractor`.

Processes the theorem registry and writes JSONL output.
-/
def main (args : List String) : IO Unit := do
  let outputPath := parseArgs args
  IO.println s!"Proof Step Extractor"
  IO.println s!"==================="
  IO.println s!"Registry size: {theoremRegistry.length} theorems"
  IO.println s!"Output: {outputPath}"
  IO.println ""

  -- Process the registry
  let (lines, theoremCount, totalSteps) ← processRegistry theoremRegistry

  -- Ensure output directory exists
  let dir := System.FilePath.mk outputPath |>.parent
  if let some dirPath := dir then
    IO.FS.createDirAll dirPath

  -- Write JSONL output
  let handle ← IO.FS.Handle.mk (System.FilePath.mk outputPath) IO.FS.Mode.write
  for line in lines do
    handle.putStrLn line

  IO.println s!"Results:"
  IO.println s!"  Theorems processed: {theoremCount}/{theoremRegistry.length}"
  IO.println s!"  Total proof steps: {totalSteps}"
  IO.println s!"  Output written to: {outputPath}"
