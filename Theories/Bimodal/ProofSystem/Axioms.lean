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
3. **BX Temporal** (24 = temp_k_dist + temp_4 + 11 schemas x 2 directions):
   - BX1/BX1': serial_future/past (seriality, replaces reflexivity)
   - BX2/BX2': REMOVED (left_mono_until/since subsumed by BX2G/BX2H under open guard)
   - BX2G/BX2H: left_mono_until_G/since_H (left monotonicity under G/H)
   - BX3/BX3': right_mono_until/since (right monotonicity)
   - BX4/BX4': connect_future/connect_past (temporal connectedness)
   - BX5/BX5': self_accum_until/since (self-accumulation)
   - BX6/BX6': absorb_until/since (absorption)
   - BX7/BX7': linear_until/since (linearity)
   - BX8/BX8': REMOVED (until_step/since_step not sound under open guard)
   - BX9/BX9': REMOVED (until_elim/since_elim unsound under open guard)
   - BX10/BX10': until_F/since_P (eventuality extraction)
   - BX11/BX11': temp_linearity/temp_linearity_past (future/past linearity)
   - BX12/BX12': F_until_equiv/P_since_equiv (F-Until/P-Since bridge)
4. **Modal-Temporal Interaction** (1): modal_future
   Note: temp_future (□φ → G□φ) is now derived from MF + T + Modal 4.

**Total**: 42 axiom constructors (34 base + 5 uniformity + 2 prior + 1 Z1)

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

44 constructors organized into six layers:
- **Propositional** (4): Classical propositional tautologies
- **S5 Modal** (5): S5 axioms for metaphysical necessity □
- **BX Temporal** (26): Burgess-Xu axioms for Until/Since on linear orders
- **Interaction** (1): Modal-temporal interaction axiom (MF; TF now derived)
- **Uniformity** (5): Discreteness uniformity axioms (valid on all ordered abelian groups)
- **Prior** (2): Prior-UZ/SZ for discrete well-ordering (valid on discrete orders only)

Base axioms (41) are valid on all linear temporal orders. Prior axioms (2) are discrete-only.
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

  /-- BX2G: Guard monotonicity of Until under G (Burgess convention: untl(event, guard)):
  `G(φ→χ) → ((ψ U φ) → (ψ U χ))`.
  Under open guard (t,s): G(φ→χ) covers all r > t, which includes (t,s).
  Unlike BX2, the pointwise (φ→χ) at t is not needed since t ∉ (t,s). -/
  | left_mono_until_G (φ χ ψ : Formula) :
      Axiom ((φ.imp χ).all_future.imp ((Formula.untl ψ φ).imp (Formula.untl ψ χ)))

  /-- BX2H: Guard monotonicity of Since under H (Burgess convention: snce(event, guard)):
  `H(φ→χ) → ((ψ S φ) → (ψ S χ))`.
  Under open guard (s,t): H(φ→χ) covers all r < t, which includes (s,t).
  Unlike BX2', the pointwise (φ→χ) at t is not needed since t ∉ (s,t). -/
  | left_mono_since_H (φ χ ψ : Formula) :
      Axiom ((φ.imp χ).all_past.imp ((Formula.snce ψ φ).imp (Formula.snce ψ χ)))

  /-- BX3: Event monotonicity of Until (Burgess convention: untl(event, guard)):
  `G(φ → ψ) → ((φ U χ) → (ψ U χ))`.
  If φ implies ψ at all times, then U(φ,χ) implies U(ψ,χ). -/
  | right_mono_until (φ ψ χ : Formula) :
      Axiom ((φ.imp ψ).all_future.imp ((Formula.untl φ χ).imp (Formula.untl ψ χ)))

  /-- BX3': Event monotonicity of Since (Burgess convention: snce(event, guard)):
  `H(φ → ψ) → ((φ S χ) → (ψ S χ))`. -/
  | right_mono_since (φ ψ χ : Formula) :
      Axiom ((φ.imp ψ).all_past.imp ((Formula.snce φ χ).imp (Formula.snce ψ χ)))

  /-- BX4: Temporal connectedness (future): `φ → G(P(φ))`.
  If φ holds now, then at all future times, P(φ) holds — the present is
  always in the past of the future. -/
  | connect_future (φ : Formula) :
      Axiom (φ.imp (φ.some_past.all_future))

  /-- BX4': Temporal connectedness (past): `φ → H(F(φ))`.
  Mirror of BX4: the present is always in the future of the past. -/
  | connect_past (φ : Formula) :
      Axiom (φ.imp (φ.some_future.all_past))

  /-- BX13: Until-Since enrichment (Burgess A3a, Xu axiom (3)):
  Burgess: `p ∧ U(α, β) → U(α ∧ S(p, β), β)`.
  In our Burgess convention (untl(event, guard)):
  `p ∧ untl(ψ, φ) → untl(ψ ∧ snce(p, φ), φ)`.
  Enriches the Until event with Since information from the current point.
  Valid under open guard (t,s): the Until guard interval (t,s) provides
  the Since guard at the witness s, since both intervals are identical. -/
  | enrichment_until (φ ψ p : Formula) :
      Axiom (Formula.and p (Formula.untl ψ φ) |>.imp
        (Formula.untl (Formula.and ψ (Formula.snce p φ)) φ))

  /-- BX13': Since-Until enrichment (Burgess A3b, Xu axiom (4)):
  Burgess: `p ∧ S(α, β) → S(α ∧ U(p, β), β)`.
  In our Burgess convention (snce(event, guard)):
  `p ∧ snce(ψ, φ) → snce(ψ ∧ untl(p, φ), φ)`.
  Mirror of enrichment_until for the Since direction. -/
  | enrichment_since (φ ψ p : Formula) :
      Axiom (Formula.and p (Formula.snce ψ φ) |>.imp
        (Formula.snce (Formula.and ψ (Formula.untl p φ)) φ))

  -- REMOVED (Task 115): BX14 (separation_until) and BX14' (separation_since) constructors.
  -- These axioms (Burgess A4a/A4b) are unnecessary for axiom minimality.
  -- The chronicle splitting construction now uses Xu 1988 Lemma 3.2.1/3.2.2 instead.

  /-- BX5: Self-accumulation of Until (Burgess convention: untl(event, guard)):
  `U(ψ, φ) → U(ψ, φ ∧ U(ψ, φ))`.
  The eventuality enriches its own guard: at intermediate points, both φ holds
  AND the eventuality U(ψ,φ) persists. This is the key axiom for eventuality resolution. -/
  | self_accum_until (φ ψ : Formula) :
      Axiom ((Formula.untl ψ φ).imp
        (Formula.untl ψ (Formula.and φ (Formula.untl ψ φ))))

  /-- BX5': Self-accumulation of Since (Burgess convention: snce(event, guard)):
  `S(ψ, φ) → S(ψ, φ ∧ S(ψ, φ))`. -/
  | self_accum_since (φ ψ : Formula) :
      Axiom ((Formula.snce ψ φ).imp
        (Formula.snce ψ (Formula.and φ (Formula.snce ψ φ))))

  /-- BX6: Absorption of Until (Burgess convention: untl(event, guard)):
  `U(φ ∧ U(ψ, φ), φ) → U(ψ, φ)`.
  Prevents infinite deferral: if the eventuality is deferred to a point where it
  still holds as φ ∧ U(ψ,φ), the two-step resolution collapses. -/
  | absorb_until (φ ψ : Formula) :
      Axiom ((Formula.untl (Formula.and φ (Formula.untl ψ φ)) φ).imp (Formula.untl ψ φ))

  /-- BX6': Absorption of Since (Burgess convention: snce(event, guard)):
  `S(φ ∧ S(ψ, φ), φ) → S(ψ, φ)`. -/
  | absorb_since (φ ψ : Formula) :
      Axiom ((Formula.snce (Formula.and φ (Formula.snce ψ φ)) φ).imp (Formula.snce ψ φ))

  /-- BX7: Linearity of Until (Burgess convention: untl(event, guard)):
  `U(ψ,φ) ∧ U(θ,χ) → U(ψ∧θ, φ∧χ) ∨ U(ψ∧χ, φ∧χ) ∨ U(φ∧θ, φ∧χ)`.
  If two Until formulas hold simultaneously, their witnesses are linearly ordered.
  The three disjuncts correspond to: witnesses coincide, first comes first, second comes first. -/
  | linear_until (φ ψ χ θ : Formula) :
      Axiom (Formula.and (Formula.untl ψ φ) (Formula.untl θ χ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.untl (Formula.and ψ θ) (Formula.and φ χ))
            (Formula.untl (Formula.and ψ χ) (Formula.and φ χ)))
          (Formula.untl (Formula.and φ θ) (Formula.and φ χ))))

  /-- BX7': Linearity of Since (Burgess convention: snce(event, guard)):
  `S(ψ,φ) ∧ S(θ,χ) → S(ψ∧θ, φ∧χ) ∨ S(ψ∧χ, φ∧χ) ∨ S(φ∧θ, φ∧χ)`. -/
  | linear_since (φ ψ χ θ : Formula) :
      Axiom (Formula.and (Formula.snce ψ φ) (Formula.snce θ χ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.snce (Formula.and ψ θ) (Formula.and φ χ))
            (Formula.snce (Formula.and ψ χ) (Formula.and φ χ)))
          (Formula.snce (Formula.and φ θ) (Formula.and φ χ))))

  -- NOTE: BX7a/BX7a' (linear_until_a7a/linear_since_a7a) removed -- unsound under open guard.
  -- Burgess's A7a has fixed event (ψ∧θ) in all disjuncts, but with strict/open guard
  -- semantics (t < r < s), the two Until witnesses s₁, s₂ cannot both contribute their
  -- events at a single point when s₁ ≠ s₂. Countermodel: φ=χ=⊤, ψ true only at s₁,
  -- θ true only at s₂ with s₁≠s₂ -- no point satisfies ψ∧θ.
  -- A7a may be valid under Burgess's closed-guard semantics (t ≤ r ≤ s) but not here.

  -- NOTE: BX8/BX8' (until_step/since_step) removed -- not sound under open guard.

  -- NOTE: BX9/BX9' (until_elim/since_elim) removed -- unsound under open guard (t,s).
  -- Archived in Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean.

  /-- BX10: Until implies eventuality (Burgess convention: untl(event, guard)):
  `U(ψ, φ) → F(ψ)`.
  U(ψ,φ) at t has witness s > t with ψ(s), so F(ψ) holds. -/
  | until_F (φ ψ : Formula) :
      Axiom ((Formula.untl ψ φ).imp (Formula.some_future ψ))

  /-- BX10': Since implies past eventuality (Burgess convention: snce(event, guard)):
  `S(ψ, φ) → P(ψ)`.
  Mirror of BX10 for the past direction. -/
  | since_P (φ ψ : Formula) :
      Axiom ((Formula.snce ψ φ).imp (Formula.some_past ψ))

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

  /-- BX12: F-Until equivalence (Burgess convention: untl(event, guard)):
  `F(φ) → U(φ, ⊤)`.
  Every future eventuality can be witnessed by an Until formula with vacuous guard.
  Here ⊤ = ¬⊥ = ⊥ → ⊥. Bridges F-formulas to Until-formulas. -/
  | F_until_equiv (φ : Formula) :
      Axiom ((Formula.some_future φ).imp (Formula.untl φ (Formula.bot.imp Formula.bot)))

  /-- BX12': P-Since equivalence (Burgess convention: snce(event, guard)):
  `P(φ) → S(φ, ⊤)`.
  Past dual of BX12. -/
  | P_since_equiv (φ : Formula) :
      Axiom ((Formula.some_past φ).imp (Formula.snce φ (Formula.bot.imp Formula.bot)))

  -- NOTE: Layer 3c (until_guard/since_guard) removed -- unsound under open guard (t,s).
  -- Archived in Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean.

  -- Layer 4: Modal-Temporal Interaction (1)
  -- Note: TF (□φ → G□φ) is now derived from MF + T + Modal 4 in Theorems/Combinators.lean.

  /-- Modal-Future: `□φ → □(Gφ)`. Necessary truths remain necessary in the future. -/
  | modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.all_future φ)))

  -- Layer 5: Uniformity Axioms (5)
  -- These encode the uniformity of discreteness in ordered abelian groups.
  -- U(⊤,⊥) = "next top" witnesses an immediate successor (gap of size d > 0).
  -- By translation invariance of the group, this gap is uniform across all time points.

  /-- Discrete symmetry forward: U(⊤,⊥) → S(⊤,⊥).
  If there is a gap of size d ahead (no points in (t, t+d)), then by translation
  invariance there is the same gap behind (no points in (t-d, t)). -/
  | discrete_symm_fwd :
      Axiom ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp
        (Formula.snce (Formula.bot.imp Formula.bot) Formula.bot))

  /-- Discrete symmetry backward: S(⊤,⊥) → U(⊤,⊥).
  Mirror of discrete_symm_fwd: a backward gap implies a forward gap. -/
  | discrete_symm_bwd :
      Axiom ((Formula.snce (Formula.bot.imp Formula.bot) Formula.bot).imp
        (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot))

  /-- Discrete propagation forward: U(⊤,⊥) → G(U(⊤,⊥)).
  If there is a gap of size d at t, then by translation invariance the same gap
  exists at every future point s > t (translate by s-t). -/
  | discrete_propagate_fwd :
      Axiom ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp
        (Formula.all_future (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot)))

  /-- Discrete propagation backward: U(⊤,⊥) → H(U(⊤,⊥)).
  If there is a gap of size d at t, then by translation invariance the same gap
  exists at every past point s < t. -/
  | discrete_propagate_bwd :
      Axiom ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp
        (Formula.all_past (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot)))

  /-- Discrete box necessity: U(⊤,⊥) → □(U(⊤,⊥)).
  If there is a gap of size d at t (discreteness witness), then by translation
  invariance the same gap exists at every accessible world at time t. Since box
  quantifies over histories at the same time, the discreteness witness propagates
  to all box-accessible worlds. Valid on all ordered abelian groups. -/
  | discrete_box_necessity :
      Axiom ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp
        (Formula.box (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot)))

  -- Layer 6: Prior Axioms for Integers (2)
  -- These axioms encode the well-ordering property for definable sets.
  -- Prior-UZ: Fp -> U(p, neg p). If p holds somewhere in the future,
  -- then p holds until not-p (i.e., the first future p-point is reachable).
  -- Valid on all discrete linear orders (IsSuccArchimedean).
  -- Reference: Reynolds 1992 Section 10, Venema 1993 axiom (W).

  /-- Prior-UZ: `F(φ) → U(φ, ¬φ)`.
  If φ holds at some future time, then there is a nearest future time where φ holds,
  with ¬φ holding at all intermediate points. This is the integer version of the
  Prior axiom, valid on all discrete well-founded-upward orders.
  Equivalent to Venema's axiom (W): every definable future set has a least element. -/
  | prior_UZ (φ : Formula) :
      Axiom (φ.some_future.imp (Formula.untl φ φ.neg))

  /-- Prior-SZ: `P(φ) → S(φ, ¬φ)`.
  Past dual of Prior-UZ. If φ held at some past time, then there is a nearest past
  time where φ held, with ¬φ holding at all intermediate points. -/
  | prior_SZ (φ : Formula) :
      Axiom (φ.some_past.imp (Formula.snce φ φ.neg))

  -- Layer 7: Z1 Axiom (IsSuccArchimedean characteristic axiom)
  -- Z1: G(Gφ→φ) → (FGφ→Gφ)
  -- Valid on all IsSuccArchimedean discrete linear orders (e.g. ℤ).
  -- Encodes the property that every definable bounded set has a maximum.
  -- Reference: Doets 1987 Claim 10, Reynolds 1994 Section 10.

  /-- Z1: `G(Gφ→φ) → (FGφ→Gφ)`.
  If Gφ→φ holds at all future times (induction step), and Gφ holds at some future
  time (base case), then Gφ holds at the current time (conclusion). This is the
  characteristic axiom of IsSuccArchimedean frames: backward induction from any
  reachable Gφ-witness yields Gφ everywhere. -/
  | z1 (φ : Formula) :
      Axiom ((φ.all_future.imp φ).all_future.imp (φ.all_future.some_future.imp φ.all_future))

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

/-- Frame class for each axiom. Prior-UZ/SZ and Z1 are discrete-only; all others are base. -/
def Axiom.frameClass {φ : Formula} : Axiom φ → FrameClass
  | prior_UZ _ => .Discrete
  | prior_SZ _ => .Discrete
  | z1 _ => .Discrete
  | _ => .Base

/-- Whether an axiom is a base axiom. Prior-UZ/SZ and Z1 are not base (discrete-only). -/
def Axiom.isBase {φ : Formula} : Axiom φ → Prop
  | prior_UZ _ => False
  | prior_SZ _ => False
  | z1 _ => False
  | _ => True

/-- Whether an axiom is dense-compatible. Prior-UZ/SZ and Z1 are not dense-compatible. -/
def Axiom.isDenseCompatible {φ : Formula} : Axiom φ → Prop
  | prior_UZ _ => False
  | prior_SZ _ => False
  | z1 _ => False
  | _ => True

/-- All BX axioms are discrete-compatible (no density axiom in the base system). -/
def Axiom.isDiscreteCompatible {φ : Formula} : Axiom φ → Prop
  | _ => True

/-- Minimal frame class. -/
abbrev Axiom.minimalFrameClass {φ : Formula} := @Axiom.frameClass φ

/-- Frame class is Base iff isBase. -/
theorem Axiom.frameClass_eq_base_iff_isBase {φ : Formula} (a : Axiom φ) :
    a.frameClass = .Base ↔ a.isBase := by
  cases a <;> simp [frameClass, isBase]

/-- Discrete-compatible iff not Dense. -/
theorem Axiom.isDiscreteCompatible_iff_frameClass {φ : Formula} (a : Axiom φ) :
    a.isDiscreteCompatible ↔ a.frameClass ≠ .Dense := by
  cases a <;> simp [isDiscreteCompatible, frameClass]

/-- Base axioms are both dense and discrete compatible. -/
theorem Axiom.isBase_implies_both_compatible {φ : Formula} (a : Axiom φ) :
    a.isBase → a.isDenseCompatible ∧ a.isDiscreteCompatible := by
  cases a <;> simp [isBase, isDenseCompatible, isDiscreteCompatible]

/-- Discreteness_forward is not in the BX system (stub for backward compatibility). -/
theorem Axiom.discreteness_forward_not_dense_compatible :
    True := trivial

end Bimodal.ProofSystem
