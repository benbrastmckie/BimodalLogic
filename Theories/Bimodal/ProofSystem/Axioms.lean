import Bimodal.Syntax.Formula

/-!
# Axioms - Burgess-Xu (BX) Axiom Schemata for TM Logic

This module defines the axiom schemata for bimodal logic TM (Tense and Modality)
under the Burgess-Xu (BX) axiom system with irreflexive temporal semantics (A2 guard convention).

## Axiom System

The BX axiom system replaces the previous mixed-semantics axiom set. Under reflexive
semantics for all temporal operators (G/H use ≤/≥, U/S use ≤/≥ for witness), the
BX axioms provide a complete axiomatization for linear temporal orders without
requiring successor-chain constructions.

### Layers

1. **Propositional** (4): prop_k, prop_s, ex_falso, peirce
2. **S5 Modal** (5): modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
3. **BX Temporal** (26 = temp_k_dist + temp_4 + 12 schemas x 2 directions):
   - BX1/BX1': serial_future/past (seriality, replaces reflexivity)
   - BX2/BX2': left_mono_until/since (left monotonicity)
   - BX3/BX3': right_mono_until/since (right monotonicity)
   - BX4/BX4': connect_future/connect_past (temporal connectedness)
   - BX5/BX5': self_accum_until/since (self-accumulation)
   - BX6/BX6': absorb_until/since (absorption)
   - BX7/BX7': linear_until/since (linearity)
   - BX8/BX8': REMOVED (until_step/since_step not sound under half-open guard)
   - BX9/BX9': until_elim/since_elim (current-time elimination)
   - BX10/BX10': until_F/since_P (eventuality extraction)
   - BX11/BX11': temp_linearity/temp_linearity_past (future/past linearity)
   - BX12/BX12': F_until_equiv/P_since_equiv (F-Until/P-Since bridge)
4. **Modal-Temporal Interaction** (2): modal_future, temp_future

**Total**: 35 axiom constructors

### Key Properties

- All BX axioms are sound on all linear temporal orders (no frame conditions needed)
- The density axiom (GGφ → Gφ) is derivable from BX1 under reflexive G
- Discrete axioms (X/Y-based) are separate extension points, not included here
- BX5 + BX6 resolve Until-eventualities axiomatically (no forward_F needed)
- BX7 ensures linearity of temporal witnesses

## References

* Burgess 1982/84: Until-Since temporal logic axiomatization
* Xu 1988: Completeness for Until-Since on linear orders
* Venema 1993: Temporal logic survey
-/

namespace Bimodal.ProofSystem

open Bimodal.Syntax

/--
Axiom schemata for bimodal logic TM under the Burgess-Xu (BX) system.

35 constructors organized into four layers:
- **Propositional** (4): Classical propositional tautologies
- **S5 Modal** (5): S5 axioms for metaphysical necessity □
- **BX Temporal** (26): Burgess-Xu axioms for Until/Since on linear orders
- **Interaction** (2): Modal-temporal interaction axioms

All axioms are valid on all linear temporal orders (base frame class).
-/
inductive Axiom : Formula → Type where
  -- Layer 1: Propositional (4)

  /-- Propositional K: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` -/
  | prop_k (φ ψ χ : Formula) :
      Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))

  /-- Propositional S (weakening): `φ → (ψ → φ)` -/
  | prop_s (φ ψ : Formula) : Axiom (φ.imp (ψ.imp φ))

  /-- Ex Falso Quodlibet: `⊥ → φ` -/
  | ex_falso (φ : Formula) : Axiom (Formula.bot.imp φ)

  /-- Peirce's Law: `((φ → ψ) → φ) → φ` -/
  | peirce (φ ψ : Formula) : Axiom (((φ.imp ψ).imp φ).imp φ)

  -- Layer 2: S5 Modal (5)

  /-- Modal T: `□φ → φ` (reflexivity) -/
  | modal_t (φ : Formula) : Axiom (Formula.box φ |>.imp φ)

  /-- Modal 4: `□φ → □□φ` (transitivity) -/
  | modal_4 (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.box φ)))

  /-- Modal B: `φ → □◇φ` (symmetry) -/
  | modal_b (φ : Formula) : Axiom (φ.imp (Formula.box φ.diamond))

  /-- Modal 5 Collapse: `◇□φ → □φ` (S5 characteristic) -/
  | modal_5_collapse (φ : Formula) : Axiom (φ.box.diamond.imp φ.box)

  /-- Modal K Distribution: `□(φ → ψ) → (□φ → □ψ)` -/
  | modal_k_dist (φ ψ : Formula) :
      Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))

  -- Layer 3: BX Temporal (22 = 12 future + 10 past-mirrors derived via duality)
  -- Note: temp_k_dist and temp_4 are future-only axioms; their past versions
  -- (H-distribution, H-transitivity) are derived via temporal_duality.

  /-- Temporal K distribution (future): `G(φ → ψ) → (G(φ) → G(ψ))`.
  Standard Hilbert axiom for the G modality. Essential for generalized temporal necessitation. -/
  | temp_k_dist (φ ψ : Formula) :
      Axiom ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))

  /-- Temporal 4 (future transitivity): `G(φ) → G(G(φ))`.
  What always holds will always always hold. Valid on reflexive+transitive orders. -/
  | temp_4 (φ : Formula) :
      Axiom (φ.all_future.imp φ.all_future.all_future)

  /-- Serial future: `⊤ → F(⊤)` (future seriality).
  Under irreflexive semantics, every time point has a strict future. -/
  | serial_future :
    Axiom ((Formula.bot.imp Formula.bot).imp (Formula.some_future (Formula.bot.imp Formula.bot)))

  /-- Serial past: `⊤ → P(⊤)` (past seriality).
  Under irreflexive semantics, every time point has a strict past. -/
  | serial_past :
    Axiom ((Formula.bot.imp Formula.bot).imp (Formula.some_past (Formula.bot.imp Formula.bot)))

  /-- BX2: Left monotonicity of Until: `(φ→χ) ∧ G(φ→χ) → ((φ U ψ) → (χ U ψ))`.
  Under half-open guard [t,s): (φ→χ)(t) covers t, G(φ→χ) covers (t,s). Together cover [t,s). -/
  | left_mono_until (φ ψ χ : Formula) :
      Axiom (Formula.and (φ.imp χ) (φ.imp χ).all_future |>.imp
        ((Formula.untl φ ψ).imp (Formula.untl χ ψ)))

  /-- BX2': Left monotonicity of Since: `(φ→χ) ∧ H(φ→χ) → ((φ S ψ) → (χ S ψ))`.
  Under half-open guard (s,t]: (φ→χ)(t) covers t, H(φ→χ) covers (s,t). Together cover (s,t]. -/
  | left_mono_since (φ ψ χ : Formula) :
      Axiom (Formula.and (φ.imp χ) (φ.imp χ).all_past |>.imp
        ((Formula.snce φ ψ).imp (Formula.snce χ ψ)))

  /-- BX3: Right monotonicity of Until: `G(φ → ψ) → ((χ U φ) → (χ U ψ))`.
  If φ implies ψ at all times, then χ U φ implies χ U ψ. -/
  | right_mono_until (φ ψ χ : Formula) :
      Axiom ((φ.imp ψ).all_future.imp ((Formula.untl χ φ).imp (Formula.untl χ ψ)))

  /-- BX3': Right monotonicity of Since: `H(φ → ψ) → ((χ S φ) → (χ S ψ))`. -/
  | right_mono_since (φ ψ χ : Formula) :
      Axiom ((φ.imp ψ).all_past.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ)))

  /-- BX4: Temporal connectedness (future): `φ → G(P(φ))`.
  If φ holds now, then at all future times, P(φ) holds — the present is
  always in the past of the future. This replaces the Burgess-Xu Until-Since
  connectedness axiom, which is not valid under half-open guard semantics. -/
  | connect_future (φ : Formula) :
      Axiom (φ.imp (φ.some_past.all_future))

  /-- BX4': Temporal connectedness (past): `φ → H(F(φ))`.
  Mirror of BX4: the present is always in the future of the past. -/
  | connect_past (φ : Formula) :
      Axiom (φ.imp (φ.some_future.all_past))

  /-- BX5: Self-accumulation of Until: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`.
  The eventuality enriches its own guard: at intermediate points, both φ holds
  AND the eventuality φ U ψ persists. This is the key axiom for eventuality resolution. -/
  | self_accum_until (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp
        (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ))

  /-- BX5': Self-accumulation of Since: `(φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)`. -/
  | self_accum_since (φ ψ : Formula) :
      Axiom ((Formula.snce φ ψ).imp
        (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ))

  /-- BX6: Absorption of Until: `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)`.
  Prevents infinite deferral: if the eventuality is deferred to a point where it
  still holds as φ ∧ (φ U ψ), the two-step resolution collapses. -/
  | absorb_until (φ ψ : Formula) :
      Axiom ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ))

  /-- BX6': Absorption of Since: `(φ S (φ ∧ (φ S ψ))) → (φ S ψ)`. -/
  | absorb_since (φ ψ : Formula) :
      Axiom ((Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ))

  /-- BX7: Linearity of Until:
  `(φ U ψ) ∧ (χ U θ) → ((φ ∧ χ) U (ψ ∧ θ)) ∨ ((φ ∧ χ) U (ψ ∧ χ)) ∨ ((φ ∧ χ) U (φ ∧ θ))`.
  If two Until formulas hold simultaneously, their witnesses are linearly ordered.
  The three disjuncts correspond to: witnesses coincide, first comes first, second comes first. -/
  | linear_until (φ ψ χ θ : Formula) :
      Axiom (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))

  /-- BX7': Linearity of Since:
  `(φ S ψ) ∧ (χ S θ) → ((φ ∧ χ) S (ψ ∧ θ)) ∨ ((φ ∧ χ) S (ψ ∧ χ)) ∨ ((φ ∧ χ) S (φ ∧ θ))`. -/
  | linear_since (φ ψ χ θ : Formula) :
      Axiom (Formula.and (Formula.snce φ ψ) (Formula.snce χ θ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.snce (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.snce (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.snce (Formula.and φ χ) (Formula.and φ θ))))

  -- NOTE: BX8/BX8' (until_step/since_step) removed -- not sound under half-open guard.

  /-- BX9: Until elimination: `(φ U ψ) → (φ ∨ ψ)`.
  Under irreflexive Until semantics with A2 guard, `φ U ψ` at t has witness s > t
  with ψ(s) and guard φ on [t,s). Since t ∈ [t,s), φ(t) holds. So φ ∨ ψ at t. -/
  | until_elim (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp (Formula.or φ ψ))

  /-- BX9': Since elimination: `(φ S ψ) → (φ ∨ ψ)`.
  Under irreflexive Since, `φ S ψ` at t has witness s < t with ψ(s) and guard φ
  on (s,t]. Since t ∈ (s,t], φ(t) holds. So φ ∨ ψ at t. -/
  | since_elim (φ ψ : Formula) :
      Axiom ((Formula.snce φ ψ).imp (Formula.or φ ψ))

  /-- BX10: Until implies eventuality: `(φ U ψ) → F(ψ)`.
  Under reflexive Until semantics, `φ U ψ` at t has witness s ≥ t with ψ(s),
  so F(ψ) = ¬G(¬ψ) holds. This cannot be derived from BX1-BX9 alone because
  `(φ U ⊥) → (φ ∨ ⊥)` is only `¬¬φ`, not `⊥`. -/
  | until_F (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp (Formula.some_future ψ))

  /-- BX10': Since implies past eventuality: `(φ S ψ) → P(ψ)`.
  Mirror of BX10 for the past direction. -/
  | since_P (φ ψ : Formula) :
      Axiom ((Formula.snce φ ψ).imp (Formula.some_past ψ))

  -- Layer 3b: Additional BX Temporal (4 = 2 axioms x 2 directions)

  /-- BX11: Temporal linearity:
  `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`.
  Future witnesses are linearly ordered. Uses linearity of the underlying temporal order.
  This axiom is NOT derivable from BX1-BX10 (see LinearityDerivedFacts.lean counterexample). -/
  | temp_linearity (φ ψ : Formula) :
      Axiom (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
        (Formula.or (Formula.some_future (Formula.and φ ψ))
          (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
            (Formula.some_future (Formula.and (Formula.some_future φ) ψ)))))

  /-- BX11': Temporal linearity (past):
  `P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)`.
  Past dual of BX11. -/
  | temp_linearity_past (φ ψ : Formula) :
      Axiom (Formula.and (Formula.some_past φ) (Formula.some_past ψ) |>.imp
        (Formula.or (Formula.some_past (Formula.and φ ψ))
          (Formula.or (Formula.some_past (Formula.and φ (Formula.some_past ψ)))
            (Formula.some_past (Formula.and (Formula.some_past φ) ψ)))))

  /-- BX12: F-Until equivalence: `F(φ) → (⊤ U φ)`.
  Every future eventuality can be witnessed by an Until formula with vacuous guard.
  Here ⊤ = ¬⊥ = ⊥ → ⊥. Bridges F-formulas to Until-formulas. -/
  | F_until_equiv (φ : Formula) :
      Axiom ((Formula.some_future φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ))

  /-- BX12': P-Since equivalence: `P(φ) → (⊤ S φ)`.
  Past dual of BX12. -/
  | P_since_equiv (φ : Formula) :
      Axiom ((Formula.some_past φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ))

  -- Layer 4: Modal-Temporal Interaction (2)

  /-- Modal-Future: `□φ → □(Gφ)`. Necessary truths remain necessary in the future. -/
  | modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.all_future φ)))

  /-- Temporal-Future: `□φ → G(□φ)`. Necessary truths will always be necessary. -/
  | temp_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.all_future (Formula.box φ)))

  deriving Repr

/--
Frame class classification for axiom validity.
Under BX, all axioms are base (valid on all linear orders).
Dense and Discrete are retained as extension points.
-/
inductive FrameClass where
  | Base
  | Dense
  | Discrete
  deriving Repr, DecidableEq, Inhabited

/-- All BX axioms have frame class Base (valid on all linear orders). -/
def Axiom.frameClass {φ : Formula} : Axiom φ → FrameClass
  | _ => .Base

/-- All BX axioms are base axioms. -/
def Axiom.isBase {φ : Formula} : Axiom φ → Prop
  | _ => True

/-- All BX axioms are dense-compatible (no discrete-only axioms in the base system). -/
def Axiom.isDenseCompatible {φ : Formula} : Axiom φ → Prop
  | _ => True

/-- All BX axioms are discrete-compatible (no density axiom in the base system). -/
def Axiom.isDiscreteCompatible {φ : Formula} : Axiom φ → Prop
  | _ => True

/-- Minimal frame class. -/
abbrev Axiom.minimalFrameClass {φ : Formula} := @Axiom.frameClass φ

/-- Frame class is Base iff isBase. -/
theorem Axiom.frameClass_eq_base_iff_isBase {φ : Formula} (a : Axiom φ) :
    a.frameClass = .Base ↔ a.isBase := by
  simp [frameClass, isBase]

/-- Discrete-compatible iff not Dense. -/
theorem Axiom.isDiscreteCompatible_iff_frameClass {φ : Formula} (a : Axiom φ) :
    a.isDiscreteCompatible ↔ a.frameClass ≠ .Dense := by
  simp [isDiscreteCompatible, frameClass]

/-- Base axioms are both dense and discrete compatible. -/
theorem Axiom.isBase_implies_both_compatible {φ : Formula} (a : Axiom φ) :
    a.isBase → a.isDenseCompatible ∧ a.isDiscreteCompatible := by
  intro _; exact ⟨trivial, trivial⟩

/-- Discreteness_forward is not in the BX system (stub for backward compatibility). -/
theorem Axiom.discreteness_forward_not_dense_compatible :
    True := trivial

end Bimodal.ProofSystem
