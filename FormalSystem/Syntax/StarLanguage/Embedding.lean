/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.StarLanguage.Derivation
import FormalSystem.Syntax.PlusLanguage.Derivation

/-!
# Every TM⁺ theorem is a TM⋆ theorem at its embedded formula

The backward half of the L⁺ ⊂ L⋆ conservativity pair:

```
TM⁺ ⊢⁺[fc] φ  ⟹  TM⋆ ⊢⋆[fc] ofPlus φ,   at every frame class and every context.
```

Unlike the base-language bridge (`Metalogic/Conservativity/Backward.lean`) no axiom-discharge
table is needed: `StarAxiom.ofPlusAxiom` sends each TM⁺ schema to its TM⋆ **mirror constructor**
at `ofPlus`-instantiated arguments, exactly as `PlusAxiom.ofTM` does one level down.

**`ofPlusAxiom` is a derived function, not a constructor.** TM⋆ used to carry the TM⁺ block as a
single primitive arm of shape `PlusAxiom φ → StarAxiom (ofPlus φ)`, which made this recursion's
`axiom` case one line but confined every inherited schema to `ofPlus` instances. That arm is
gone: the schemata are declared directly over `StarFormula` (`StarLanguage/Axioms.lean`), and the
embedding is *recovered* here as a theorem about them. It adds nothing to TM⋆ — every arm is a
constructor application at embedded arguments — while the schemata themselves reach
register-carrying formulas.

Three arms consume a side condition, and each gets it from a transfer lemma in
`StarLanguage/Formula.lean`: `modal_future` from `recallFree_ofPlus`, and `paste`/`untl_paste`
from `starIsPureFuture_ofPlus` / `starIsPurePast_ofPlus`. Nothing in `ofPlus`'s image mentions a
register, so all three discharge unconditionally.

Six of the seven derivation cases are structural. The seventh, `temporal_duality`, transports
along `ofPlus_swapTemporal` (`StarLanguage/Formula.lean`) — the one commutation in the family
that is an induction rather than a `rfl`.

## Main Results

- `StarAxiom.ofPlusAxiom` — every TM⁺ schema as its TM⋆ mirror at the embedded formula
- `StarAxiom.minFrameClass_ofPlusAxiom` — the embedding preserves the minimum frame class,
  proved as **one** named `cases` lemma rather than 53 inline `rfl`s, so a routing mismatch
  between `PlusAxiom.minFrameClass` and `StarAxiom.minFrameClass` is a named failure at a single
  site
- `StarDerivationTree.ofPlusTree` — the seven-case structural recursion on derivations
- `starDerivable_of_plusDerivable` — its `Prop`-level form
- `starDerivable_of_derivable` — composed with `plusDerivable_of_derivable`, the L ⊂ L⋆
  backward direction, and the backward half of `starDerivable_ofFormula_iff`
  (`Metalogic/Conservativity/Star/Forward.lean`)

## The forward direction is elsewhere, and is not symmetric

`TM⋆ ⊢⋆ ofPlus φ ⟹ TM⁺ ⊢⁺ φ` is **not** proved here and is not proved by any syntactic route:
register erasure is refuted as a translation (`Semantics/StarNonValidities.lean`,
`storeG_recall_valid` with `refute_erasure`). It is treated semantically, and only conditionally,
in `Metalogic/Conservativity/Star/Forward.lean`. The forward direction over the *base* language
`TM⋆ ⊢⋆ ofPlus (ofFormula φ) ⟹ TM ⊢ φ` is unconditional, because TM has completeness engines and
TM⁺ does not.

## References

* `FormalSystem/PlusLanguage/Derivation.lean` — `PlusDerivationTree.ofTM`, the shape mirrored here
* `FormalSystem/StarLanguage/Axioms.lean` — `StarAxiom`'s 53 mirror constructors

## Tags

conservativity · star-language · embedding · proof-system
-/

namespace FormalSystem.StarLanguage

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage

/--
**Every TM⁺ schema as its TM⋆ mirror, at the embedded formula.** A 53-arm dispatch, one arm per
`PlusAxiom` constructor, each sending it to the `StarAxiom` constructor of the same name at
`ofPlus`-instantiated arguments. `ofPlus` commutes with every formula constructor and with every
derived operator definitionally (`StarLanguage/Formula.lean`'s `rfl` pins), so each arm is a bare
constructor application.

**Derived, not primitive.** This was a *constructor* of `StarAxiom` until the schema block was
re-declared over `StarFormula`; it is now a function provable from those constructors, and it
adds nothing whatever to TM⋆. That is what makes the retirement real rather than a rename: the
embedding survives as a theorem, and the schemata it embeds are no longer confined to its
image.

Three arms discharge a side condition the `PlusAxiom` mirror does not carry, or carries in its
L⁺ form: `modal_future` supplies `recallFree_ofPlus` (no embedded formula contains a `↓ⁱ`), and
`paste`/`untl_paste` supply `starIsPureFuture_ofPlus` / `starIsPurePast_ofPlus`.

Mirror of `PlusAxiom.ofTM` (`PlusLanguage/Derivation.lean`) one level down.
-/
def StarAxiom.ofPlusAxiom {φ : PlusFormula} : PlusAxiom φ → StarAxiom (ofPlus φ)
  | .prop_k a b c => .prop_k (ofPlus a) (ofPlus b) (ofPlus c)
  | .prop_s a b => .prop_s (ofPlus a) (ofPlus b)
  | .ex_falso a => .ex_falso (ofPlus a)
  | .peirce a b => .peirce (ofPlus a) (ofPlus b)
  | .modal_t a => .modal_t (ofPlus a)
  | .modal_4 a => .modal_4 (ofPlus a)
  | .modal_b a => .modal_b (ofPlus a)
  | .modal_5_collapse a => .modal_5_collapse (ofPlus a)
  | .modal_k_dist a b => .modal_k_dist (ofPlus a) (ofPlus b)
  | .serial_future => .serial_future
  | .serial_past => .serial_past
  | .left_mono_until_G a b c => .left_mono_until_G (ofPlus a) (ofPlus b) (ofPlus c)
  | .left_mono_since_H a b c => .left_mono_since_H (ofPlus a) (ofPlus b) (ofPlus c)
  | .right_mono_until a b c => .right_mono_until (ofPlus a) (ofPlus b) (ofPlus c)
  | .right_mono_since a b c => .right_mono_since (ofPlus a) (ofPlus b) (ofPlus c)
  | .connect_future a => .connect_future (ofPlus a)
  | .connect_past a => .connect_past (ofPlus a)
  | .enrichment_until a b c => .enrichment_until (ofPlus a) (ofPlus b) (ofPlus c)
  | .enrichment_since a b c => .enrichment_since (ofPlus a) (ofPlus b) (ofPlus c)
  | .self_accum_until a b => .self_accum_until (ofPlus a) (ofPlus b)
  | .self_accum_since a b => .self_accum_since (ofPlus a) (ofPlus b)
  | .absorb_until a b => .absorb_until (ofPlus a) (ofPlus b)
  | .absorb_since a b => .absorb_since (ofPlus a) (ofPlus b)
  | .linear_until a b c d => .linear_until (ofPlus a) (ofPlus b) (ofPlus c) (ofPlus d)
  | .linear_since a b c d => .linear_since (ofPlus a) (ofPlus b) (ofPlus c) (ofPlus d)
  | .until_F a b => .until_F (ofPlus a) (ofPlus b)
  | .since_P a b => .since_P (ofPlus a) (ofPlus b)
  | .temp_linearity a b => .temp_linearity (ofPlus a) (ofPlus b)
  | .temp_linearity_past a b => .temp_linearity_past (ofPlus a) (ofPlus b)
  | .F_until_equiv a => .F_until_equiv (ofPlus a)
  | .P_since_equiv a => .P_since_equiv (ofPlus a)
  | .modal_future a => .modal_future (ofPlus a) (recallFree_ofPlus a)
  | .discrete_symm_fwd => .discrete_symm_fwd
  | .discrete_symm_bwd => .discrete_symm_bwd
  | .discrete_propagate_fwd => .discrete_propagate_fwd
  | .discrete_propagate_bwd => .discrete_propagate_bwd
  | .discrete_box_necessity => .discrete_box_necessity
  | .prior_UZ a => .prior_UZ (ofPlus a)
  | .prior_SZ a => .prior_SZ (ofPlus a)
  | .z1 a => .z1 (ofPlus a)
  | .density a => .density (ofPlus a)
  | .dense_indicator => .dense_indicator
  | .prior_U_gap a => .prior_U_gap (ofPlus a)
  | .prior_S_gap a => .prior_S_gap (ofPlus a)
  | .sep a => .sep (ofPlus a)
  | .stab_k a b => .stab_k (ofPlus a) (ofPlus b)
  | .stab_t a => .stab_t (ofPlus a)
  | .stab_4 a => .stab_4 (ofPlus a)
  | .stab_5 a => .stab_5 (ofPlus a)
  | .box_stab a => .box_stab (ofPlus a)
  | .atom_stab p => .atom_stab p
  | .paste a b ha hb => .paste (ofPlus a) (ofPlus b)
      (starIsPureFuture_ofPlus ha) (starIsPurePast_ofPlus hb)
  | .untl_paste a b ha hb => .untl_paste (ofPlus a) (ofPlus b)
      (starIsPurePast_ofPlus ha) (starIsPureFuture_ofPlus hb)

/-- **The embedding of axioms preserves the minimum frame class.** One named `cases` lemma over
`PlusAxiom` rather than 53 inline `rfl`s at the use sites: if `StarAxiom.minFrameClass` ever
disagreed with `PlusAxiom.minFrameClass` on some schema — which would silently break backward
conservativity — the failure would surface here, at a single named site, instead of at whichever
consumer happened to need that arm. Mirror of `PlusAxiom.minFrameClass_ofTM`. -/
theorem StarAxiom.minFrameClass_ofPlusAxiom {φ : PlusFormula} (ax : PlusAxiom φ) :
    (StarAxiom.ofPlusAxiom ax).minFrameClass = ax.minFrameClass := by
  cases ax <;> rfl

/--
**The backward conservativity bridge for L⁺ ⊂ L⋆.** Every TM⁺ derivation becomes a TM⋆
derivation of its embedding, at the same frame class and over the embedded context. Seven cases,
one per rule; the `axiom` case goes through `StarAxiom.ofPlusAxiom` and is gated by
`StarAxiom.minFrameClass_ofPlusAxiom`, the `temporal_duality` case transports along
`ofPlus_swapTemporal`, and the rest are structural.
-/
def StarDerivationTree.ofPlusTree {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula} :
    PlusDerivationTree fc Γ φ → StarDerivationTree fc (ofStarCtx Γ) (ofPlus φ)
  | .axiom _ _ h h_fc =>
      .axiom _ _ (StarAxiom.ofPlusAxiom h)
        (by rw [StarAxiom.minFrameClass_ofPlusAxiom]; exact h_fc)
  | .assumption _ _ h => .assumption _ _ (mem_ofStarCtx h)
  | .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (ofPlus φ) (ofPlus ψ) (ofPlusTree d1) (ofPlusTree d2)
  | .necessitation φ d => .necessitation (ofPlus φ) (ofPlusTree d)
  | .temporal_necessitation φ d => .temporal_necessitation (ofPlus φ) (ofPlusTree d)
  | .temporal_duality φ d =>
      (ofPlus_swapTemporal φ).symm ▸
        StarDerivationTree.temporal_duality (ofPlus φ) (ofPlusTree d)
  | .weakening _ _ _ d h =>
      .weakening _ _ _ (ofPlusTree d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/-- **Backward conservativity, `Prop`-level**: `TM⁺ ⊢⁺[fc] φ ⟹ TM⋆ ⊢⋆[fc] ofPlus φ`, at every
frame class and context. -/
theorem starDerivable_of_plusDerivable {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula}
    (h : PlusDerivable fc Γ φ) : StarDerivable fc (ofStarCtx Γ) (ofPlus φ) :=
  h.elim fun d => ⟨StarDerivationTree.ofPlusTree d⟩

/-- **L ⊂ L⋆, backward**: a TM theorem is a TM⋆ theorem at its doubly-embedded formula, by
composing with `plusDerivable_of_derivable`. This is the backward half of the unconditional
conservativity biconditional `starDerivable_ofFormula_iff`. -/
theorem starDerivable_of_derivable {fc : FrameClass} {φ : Formula}
    (h : ProofSystem.Derivable fc [] φ) : StarDerivable fc [] (ofPlus (ofFormula φ)) :=
  starDerivable_of_plusDerivable (plusDerivable_of_derivable h)

/-! ### Acceptance checks -/

/-- MF at a `⊡`-formula crosses the embedding — now through the native `StarAxiom.modal_future`
constructor rather than through a monolithic embedding arm, its `RecallFree` side condition
discharged by `recallFree_ofPlus` inside `ofPlusAxiom`. -/
example (p : Atom) :
    ⊢⋆[FrameClass.Base] ofPlus ((PlusFormula.box (PlusFormula.stab (PlusFormula.atom p))).imp
      (PlusFormula.box (PlusFormula.allFuture (PlusFormula.stab (PlusFormula.atom p))))) :=
  StarDerivationTree.ofPlusTree
    (.axiom [] _ (PlusAxiom.modal_future _) (FrameClass.base_le _))

/-- A TM⁺ theorem obtained by the `temporal_duality` rule crosses too — the case that consumes
`ofPlus_swapTemporal`. -/
example (fc : FrameClass) (φ : PlusFormula) :
    StarDerivable fc [] (ofPlus ((PlusFormula.stab φ).imp φ).swapTemporal) :=
  starDerivable_of_plusDerivable
    ⟨.temporal_duality _ (.axiom [] _ (PlusAxiom.stab_t φ) (FrameClass.base_le fc))⟩

end FormalSystem.StarLanguage
