/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenAxioms
import FormalSystem.PlusLanguage.Derivation
import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Derivable

/-!
# `OpenDerivationTree` — the L^▷ proof system, and backward conservativity over TM⁺

A constructor-for-constructor mirror of `FormalSystem.PlusLanguage.PlusDerivationTree` over
`OpenFormula`, with `OpenAxiom` in the `axiom` rule. The mirror is deliberate: it is what makes
the embedding `OpenDerivationTree.ofPlus` a seven-case structural recursion with one case per rule,
and what lets the soundness companion recursion
(`Metalogic/Conservativity/Open/OpenSoundness.lean`) transcribe TM⁺'s arm for arm.

## No completeness is claimed

Nothing in this module, or in the system it defines, is a completeness claim for L^▷ at any frame
class. The system is sound and conservative over TM⁺ in both directions; that is all. See
`OpenLanguage/OpenAxioms.lean`'s module docstring for the standing statement.

## Inference rules (7, matching TM⁺ exactly)

1. `axiom` — an `OpenAxiom` instance, gated by `ax.minFrameClass ≤ fc`
2. `assumption`
3. `modus_ponens`
4. `necessitation` — `⊢ φ ⟹ ⊢ □φ`, empty context only
5. `temporal_necessitation` — `⊢ φ ⟹ ⊢ Gφ`, empty context only
6. `time_reflection` — `⊢ φ ⟹ ⊢ reflectTime φ`, empty context only
7. `weakening`

**There is no `⊡`-, `▷`- or `◁`-necessitation rule, and none is needed.** All three are *derived*:
`necessitation` reaches `⊢ □φ`, `stab_of_box` turns that into `⊢ ⊡φ`, and `ofut_of_stab` /
`opast_of_stab` turn *that* into `⊢ ▷φ` / `⊢ ◁φ`. The three derived rules are
`stabNecessitation`, `ofutNecessitation` and `opastNecessitation` below. Adding a primitive rule
for any of them would add an eighth case to every recursion over this tree — the soundness
recursion, the erasure of `OpenLanguage/OpenErasure.lean`, `lift` and `height` — for a rule the
axioms already supply.

## Where `OpenContext` is declared

`abbrev OpenContext := List OpenFormula` sits **here**, not beside `OpenFormula`, which diverges
from `PlusContext`'s placement beside `PlusFormula` (`PlusLanguage/Formula.lean`). The divergence
is deliberate: `OpenLanguage/Formula.lean` carries module invariants of its own and nothing in this
component needs a context type before the proof system exists, so the file is left untouched.

## Main Definitions

- `OpenContext` — `List OpenFormula`
- `OpenDerivationTree` — the seven-rule `Type`-valued derivation tree
- `OpenDerivable` — `Prop`-valued derivability, with the notations `Γ ⊢▷[fc] φ` and `⊢▷[fc] φ`
- `OpenAxiom.ofPlus`, `OpenDerivationTree.ofPlus` — the constructor and rule embeddings of TM⁺

## Main Results

- `stabNecessitation`, `ofutNecessitation`, `opastNecessitation` — the three derived rules
- `isPureFutureOpen_ofPlus`, `isPurePastOpen_ofPlus` — the purity side conditions transport along
  the embedding
- `OpenAxiom.minFrameClass_ofPlus` — the embedding preserves the frame-class floor
- `openDerivable_of_plusDerivable` — **backward conservativity over TM⁺**, with the four class
  rows `open_backward_base`, `_dense`, `_ztime`, `_rtime`

## References

* `FormalSystem/PlusLanguage/Derivation.lean` — the TM⁺ counterpart being mirrored
* `FormalSystem/OpenLanguage/OpenAxioms.lean` — the axiom type in the `axiom` rule

## Tags

open-language · proof-system · derivation · conservativity
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage (PlusFormula PlusContext PlusAxiom PlusDerivationTree PlusDerivable)

/-- Contexts of the L^▷ proof system. Declared here rather than beside `OpenFormula`; see the
module docstring. -/
abbrev OpenContext := List OpenFormula

/--
Derivation tree for the L^▷ proof system, parameterized by frame class. `Type`-valued, like its
TM⁺ counterpart, so that the soundness recursion can match on it and `height` is computable.

Paper: — (formalization-native; the manuscript supplies no proof system over the restricted
modals)
-/
inductive OpenDerivationTree (fc : FrameClass) : OpenContext → OpenFormula → Type where
  /-- Axiom rule, gated by `h.minFrameClass ≤ fc`. -/
  | axiom (Γ : OpenContext) (φ : OpenFormula) (h : OpenAxiom φ)
      (h_fc : h.minFrameClass ≤ fc) : OpenDerivationTree fc Γ φ
  /-- Assumption rule: formulas in the context are derivable. -/
  | assumption (Γ : OpenContext) (φ : OpenFormula) (h : φ ∈ Γ) : OpenDerivationTree fc Γ φ
  /-- Modus ponens. -/
  | modus_ponens (Γ : OpenContext) (φ ψ : OpenFormula)
      (d1 : OpenDerivationTree fc Γ (φ.imp ψ))
      (d2 : OpenDerivationTree fc Γ φ) : OpenDerivationTree fc Γ ψ
  /-- Necessitation: from `⊢ φ`, conclude `⊢ □φ`. Theorems only. -/
  | necessitation (φ : OpenFormula)
      (d : OpenDerivationTree fc [] φ) : OpenDerivationTree fc [] (OpenFormula.box φ)
  /-- Temporal necessitation: from `⊢ φ`, conclude `⊢ Gφ`. Theorems only. -/
  | temporal_necessitation (φ : OpenFormula)
      (d : OpenDerivationTree fc [] φ) : OpenDerivationTree fc [] (OpenFormula.allFuture φ)
  /-- Time reflection: from `⊢ φ`, conclude `⊢ reflectTime φ`. Theorems only. -/
  | time_reflection (φ : OpenFormula)
      (d : OpenDerivationTree fc [] φ) : OpenDerivationTree fc [] φ.reflectTime
  /-- Weakening: from `Γ ⊢ φ` and `Γ ⊆ Δ`, conclude `Δ ⊢ φ`. -/
  | weakening (Γ Δ : OpenContext) (φ : OpenFormula)
      (d : OpenDerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : OpenDerivationTree fc Δ φ

namespace OpenDerivationTree

/-- Lift a derivation from `fc₁` to `fc₂` when `fc₁ ≤ fc₂`. Mirrors `PlusDerivationTree.lift`. -/
def lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {Γ : OpenContext} {φ : OpenFormula} : OpenDerivationTree fc₁ Γ φ → OpenDerivationTree fc₂ Γ φ
  | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
  | .assumption Γ φ h => .assumption Γ φ h
  | .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
  | .necessitation φ d => .necessitation φ (d.lift h_le)
  | .temporal_necessitation φ d => .temporal_necessitation φ (d.lift h_le)
  | .time_reflection φ d => .time_reflection φ (d.lift h_le)
  | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h

/-- Height of a derivation, mirroring `PlusDerivationTree.height`. -/
def height {fc : FrameClass} {Γ : OpenContext} {φ : OpenFormula} :
    OpenDerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .time_reflection _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

/-- Re-target a derivation whose context is a subset of the empty context. Mirror of
`PlusDerivationTree.ofWeakeningNil`. -/
def ofWeakeningNil {fc : FrameClass} {Γ' : OpenContext} {φ : OpenFormula}
    (d : OpenDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : OpenContext)) :
    OpenDerivationTree fc [] φ :=
  (List.eq_nil_of_subset_nil h_sub) ▸ d

/-- `ofWeakeningNil` preserves height exactly. -/
@[simp] theorem height_ofWeakeningNil {fc : FrameClass} {Γ' : OpenContext} {φ : OpenFormula}
    (d : OpenDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : OpenContext)) :
    (d.ofWeakeningNil h_sub).height = d.height := by
  have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
  subst h_eq
  rfl

/-- Transporting to the empty context is strictly cheaper than the `weakening` node. -/
theorem height_ofWeakeningNil_lt {fc : FrameClass} {Γ' : OpenContext} {φ : OpenFormula}
    (d : OpenDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : OpenContext)) :
    (d.ofWeakeningNil h_sub).height <
      (OpenDerivationTree.weakening Γ' ([] : OpenContext) φ d h_sub).height := by
  simp only [OpenDerivationTree.height_ofWeakeningNil, OpenDerivationTree.height]
  omega

/-- Modus ponens height is strictly greater than the left subderivation. -/
theorem mp_height_gt_left {fc : FrameClass} {Γ : OpenContext} {φ ψ : OpenFormula}
    (d1 : OpenDerivationTree fc Γ (φ.imp ψ)) (d2 : OpenDerivationTree fc Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/-- Modus ponens height is strictly greater than the right subderivation. -/
theorem mp_height_gt_right {fc : FrameClass} {Γ : OpenContext} {φ ψ : OpenFormula}
    (d1 : OpenDerivationTree fc Γ (φ.imp ψ)) (d2 : OpenDerivationTree fc Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

end OpenDerivationTree

/-- Prop-valued derivability in the L^▷ system, mirroring `PlusDerivable`. -/
def OpenDerivable (fc : FrameClass) (Γ : OpenContext) (φ : OpenFormula) : Prop :=
  Nonempty (OpenDerivationTree fc Γ φ)

/-- Derivability in the L^▷ system from context `Γ` at frame class `fc`. -/
notation:50 Γ " ⊢▷[" fc "] " φ => OpenDerivationTree fc Γ φ

/-- Theoremhood in the L^▷ system at frame class `fc`. -/
notation:50 "⊢▷[" fc "] " φ => OpenDerivationTree fc [] φ

/-- `OpenDerivable` is monotone in the frame class. -/
theorem OpenDerivable.mono {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {Γ : OpenContext}
    {φ : OpenFormula} (hd : OpenDerivable fc₁ Γ φ) : OpenDerivable fc₂ Γ φ :=
  hd.elim fun d => ⟨d.lift h⟩

/-! ## The three derived necessitation rules

None of `⊡`, `▷` and `◁` has a primitive rule; each is reached from `necessitation` through the
bridge axioms. This is the whole reason the tree has seven rules rather than ten. -/

/-- **`⊡`-necessitation is derived**: `⊢ φ ⟹ ⊢ ⊡φ`, by `necessitation` to `⊢ □φ` and then
`stab_of_box` (`□φ → ⊡φ`). -/
def stabNecessitation {fc : FrameClass} {φ : OpenFormula}
    (d : ⊢▷[fc] φ) : ⊢▷[fc] OpenFormula.stab φ :=
  .modus_ponens [] _ _
    (.axiom [] _ (OpenAxiom.stab_of_box φ) (FrameClass.base_le fc))
    (.necessitation φ d)

/-- **`▷`-necessitation is derived**: `⊢ φ ⟹ ⊢ ▷φ`, by `stabNecessitation` and then
`ofut_of_stab` (`⊡φ → ▷φ`). -/
def ofutNecessitation {fc : FrameClass} {φ : OpenFormula}
    (d : ⊢▷[fc] φ) : ⊢▷[fc] OpenFormula.ofut φ :=
  .modus_ponens [] _ _
    (.axiom [] _ (OpenAxiom.ofut_of_stab φ) (FrameClass.base_le fc))
    (stabNecessitation d)

/-- **`◁`-necessitation is derived**: `⊢ φ ⟹ ⊢ ◁φ`, by `stabNecessitation` and then
`opast_of_stab` (`⊡φ → ◁φ`). -/
def opastNecessitation {fc : FrameClass} {φ : OpenFormula}
    (d : ⊢▷[fc] φ) : ⊢▷[fc] OpenFormula.opast φ :=
  .modus_ponens [] _ _
    (.axiom [] _ (OpenAxiom.opast_of_stab φ) (FrameClass.base_le fc))
    (stabNecessitation d)

/-! ## Backward conservativity: TM⁺ derivations embed into the L^▷ system -/

/-- The formula-level embedding of L⁺ into L^▷, under a name that `OpenAxiom.ofPlus`'s and
`OpenDerivationTree.ofPlus`'s own short names cannot shadow inside their bodies. Reducible, so
`OpenAxiom (embPlus φ)` and `OpenAxiom (ofPlus φ)` are the same type to the elaborator. -/
abbrev embPlus : PlusFormula → OpenFormula := ofPlus

/-- The pure-future side condition transports along the embedding. The `box` and `stab` arms are
leaves on both sides, and no `IsPureFuture` derivation produces an `ofut`/`opast` node, so the two
crossed clauses of `IsPureFutureOpen` are unreached here. -/
theorem isPureFutureOpen_ofPlus {φ : PlusFormula} (h : PlusFormula.IsPureFuture φ) :
    IsPureFutureOpen (ofPlus φ) := by
  induction h with
  | atom p => exact IsPureFutureOpen.atom p
  | bot => exact IsPureFutureOpen.bot
  | imp _ _ ih1 ih2 => exact IsPureFutureOpen.imp ih1 ih2
  | box φ => exact IsPureFutureOpen.box (ofPlus φ)
  | stab φ => exact IsPureFutureOpen.stab (ofPlus φ)
  | untl _ _ ih1 ih2 => exact IsPureFutureOpen.untl ih1 ih2

/-- The pure-past side condition transports along the embedding. -/
theorem isPurePastOpen_ofPlus {φ : PlusFormula} (h : PlusFormula.IsPurePast φ) :
    IsPurePastOpen (ofPlus φ) := by
  induction h with
  | atom p => exact IsPurePastOpen.atom p
  | bot => exact IsPurePastOpen.bot
  | imp _ _ ih1 ih2 => exact IsPurePastOpen.imp ih1 ih2
  | box φ => exact IsPurePastOpen.box (ofPlus φ)
  | stab φ => exact IsPurePastOpen.stab (ofPlus φ)
  | snce _ _ ih1 ih2 => exact IsPurePastOpen.snce ih1 ih2

/--
Every TM⁺ axiom instance is an L^▷ axiom instance under the embedding. Each arm is `rfl`-shaped:
`ofPlus` commutes definitionally with every derived operator, so the embedded schema instance **is**
the re-declared constructor at the embedded parameters. Any drift between `PlusAxiom` and the TM⁺
mirror block of `OpenAxiom` fails to typecheck here.

The restricted-modal constructors of `OpenAxiom` have no arm, as they must not: no `PlusAxiom`
instance mentions `▷` or `◁`.
-/
def OpenAxiom.ofPlus : {φ : PlusFormula} → PlusAxiom φ → OpenAxiom (embPlus φ)
  | _, .prop_k φ ψ χ => .prop_k (embPlus φ) (embPlus ψ) (embPlus χ)
  | _, .prop_s φ ψ => .prop_s (embPlus φ) (embPlus ψ)
  | _, .ex_falso φ => .ex_falso (embPlus φ)
  | _, .peirce φ ψ => .peirce (embPlus φ) (embPlus ψ)
  | _, .modal_t φ => .modal_t (embPlus φ)
  | _, .modal_4 φ => .modal_4 (embPlus φ)
  | _, .modal_b φ => .modal_b (embPlus φ)
  | _, .modal_5_collapse φ => .modal_5_collapse (embPlus φ)
  | _, .modal_k_dist φ ψ => .modal_k_dist (embPlus φ) (embPlus ψ)
  | _, .serial_future => .serial_future
  | _, .serial_past => .serial_past
  | _, .left_mono_until_G φ χ ψ => .left_mono_until_G (embPlus φ) (embPlus χ) (embPlus ψ)
  | _, .left_mono_since_H φ χ ψ => .left_mono_since_H (embPlus φ) (embPlus χ) (embPlus ψ)
  | _, .right_mono_until φ ψ χ => .right_mono_until (embPlus φ) (embPlus ψ) (embPlus χ)
  | _, .right_mono_since φ ψ χ => .right_mono_since (embPlus φ) (embPlus ψ) (embPlus χ)
  | _, .connect_future φ => .connect_future (embPlus φ)
  | _, .connect_past φ => .connect_past (embPlus φ)
  | _, .enrichment_until φ ψ p => .enrichment_until (embPlus φ) (embPlus ψ) (embPlus p)
  | _, .enrichment_since φ ψ p => .enrichment_since (embPlus φ) (embPlus ψ) (embPlus p)
  | _, .self_accum_until φ ψ => .self_accum_until (embPlus φ) (embPlus ψ)
  | _, .self_accum_since φ ψ => .self_accum_since (embPlus φ) (embPlus ψ)
  | _, .absorb_until φ ψ => .absorb_until (embPlus φ) (embPlus ψ)
  | _, .absorb_since φ ψ => .absorb_since (embPlus φ) (embPlus ψ)
  | _, .linear_until φ ψ χ θ => .linear_until (embPlus φ) (embPlus ψ) (embPlus χ) (embPlus θ)
  | _, .linear_since φ ψ χ θ => .linear_since (embPlus φ) (embPlus ψ) (embPlus χ) (embPlus θ)
  | _, .until_F φ ψ => .until_F (embPlus φ) (embPlus ψ)
  | _, .since_P φ ψ => .since_P (embPlus φ) (embPlus ψ)
  | _, .temp_linearity φ ψ => .temp_linearity (embPlus φ) (embPlus ψ)
  | _, .temp_linearity_past φ ψ => .temp_linearity_past (embPlus φ) (embPlus ψ)
  | _, .F_until_equiv φ => .F_until_equiv (embPlus φ)
  | _, .P_since_equiv φ => .P_since_equiv (embPlus φ)
  | _, .modal_future φ => .modal_future (embPlus φ)
  | _, .discrete_symm_fwd => .discrete_symm_fwd
  | _, .discrete_symm_bwd => .discrete_symm_bwd
  | _, .discrete_propagate_fwd => .discrete_propagate_fwd
  | _, .discrete_propagate_bwd => .discrete_propagate_bwd
  | _, .discrete_box_necessity => .discrete_box_necessity
  | _, .prior_UZ φ => .prior_UZ (embPlus φ)
  | _, .prior_SZ φ => .prior_SZ (embPlus φ)
  | _, .z1 φ => .z1 (embPlus φ)
  | _, .density φ => .density (embPlus φ)
  | _, .dense_indicator => .dense_indicator
  | _, .prior_U_gap φ => .prior_U_gap (embPlus φ)
  | _, .prior_S_gap φ => .prior_S_gap (embPlus φ)
  | _, .sep φ => .sep (embPlus φ)
  | _, .stab_k φ ψ => .stab_k (embPlus φ) (embPlus ψ)
  | _, .stab_t φ => .stab_t (embPlus φ)
  | _, .stab_4 φ => .stab_4 (embPlus φ)
  | _, .stab_5 φ => .stab_5 (embPlus φ)
  | _, .box_stab φ => .box_stab (embPlus φ)
  | _, .atom_stab p => .atom_stab p
  | _, .paste φ ψ hφ hψ =>
      .paste (embPlus φ) (embPlus ψ) (isPureFutureOpen_ofPlus hφ) (isPurePastOpen_ofPlus hψ)
  | _, .untl_paste α φ hα hφ =>
      .untl_paste (embPlus α) (embPlus φ) (isPurePastOpen_ofPlus hα) (isPureFutureOpen_ofPlus hφ)

/-- The embedding preserves the minimum frame class. -/
theorem OpenAxiom.minFrameClass_ofPlus {φ : PlusFormula} (ax : PlusAxiom φ) :
    (OpenAxiom.ofPlus ax).minFrameClass = ax.minFrameClass := by
  cases ax <;> rfl

/--
**The backward conservativity bridge.** Every TM⁺ derivation becomes an L^▷ derivation of its
embedding, at the same frame class and over the embedded context. Seven cases, one per rule; the
`axiom` case is `OpenAxiom.ofPlus`, the `time_reflection` case transports along
`ofPlus_reflectTime`, and the rest are structural.
-/
def OpenDerivationTree.ofPlus {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula} :
    PlusDerivationTree fc Γ φ → OpenDerivationTree fc (Γ.map embPlus) (embPlus φ)
  | .axiom _ _ h h_fc =>
      .axiom _ _ (OpenAxiom.ofPlus h) (by rw [OpenAxiom.minFrameClass_ofPlus]; exact h_fc)
  | .assumption _ _ h => .assumption _ _ (List.mem_map_of_mem h)
  | .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (embPlus φ) (embPlus ψ) (ofPlus d1) (ofPlus d2)
  | .necessitation φ d => .necessitation (embPlus φ) (ofPlus d)
  | .temporal_necessitation φ d => .temporal_necessitation (embPlus φ) (ofPlus d)
  | .time_reflection φ d =>
      have h : embPlus φ.reflectTime = (embPlus φ).reflectTime := ofPlus_reflectTime φ
      h ▸ OpenDerivationTree.time_reflection (embPlus φ) (ofPlus d)
  | .weakening _ _ _ d h =>
      .weakening _ _ _ (ofPlus d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/-- **Backward conservativity over TM⁺, `Prop`-level**: `TM⁺ ⊢[fc] φ ⟹ L^▷ ⊢[fc] ofPlus φ`, at
every frame class and context. It is free: the constructor embedding does all the work.

Paper: — (formalization-native; the manuscript supplies no proof system over the restricted
modals, so neither conservativity direction has a manuscript statement)
-/
theorem openDerivable_of_plusDerivable {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula}
    (h : PlusDerivable fc Γ φ) : OpenDerivable fc (Γ.map ofPlus) (ofPlus φ) :=
  h.elim fun d => ⟨OpenDerivationTree.ofPlus d⟩

/-! ### The four rows at the empty context -/

/-- Backward conservativity over TM⁺ at `.Base`. -/
theorem open_backward_base {φ : PlusFormula} (h : PlusDerivable FrameClass.Base [] φ) :
    OpenDerivable FrameClass.Base [] (ofPlus φ) :=
  openDerivable_of_plusDerivable h

/-- Backward conservativity over TM⁺ at `.Dense`. -/
theorem open_backward_dense {φ : PlusFormula} (h : PlusDerivable FrameClass.Dense [] φ) :
    OpenDerivable FrameClass.Dense [] (ofPlus φ) :=
  openDerivable_of_plusDerivable h

/-- Backward conservativity over TM⁺ at `.ZTime`. -/
theorem open_backward_ztime {φ : PlusFormula} (h : PlusDerivable FrameClass.ZTime [] φ) :
    OpenDerivable FrameClass.ZTime [] (ofPlus φ) :=
  openDerivable_of_plusDerivable h

/-- Backward conservativity over TM⁺ at `.RTime`. -/
theorem open_backward_rtime {φ : PlusFormula} (h : PlusDerivable FrameClass.RTime [] φ) :
    OpenDerivable FrameClass.RTime [] (ofPlus φ) :=
  openDerivable_of_plusDerivable h

end FormalSystem.OpenLanguage
