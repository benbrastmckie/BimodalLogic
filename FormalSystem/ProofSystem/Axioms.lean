/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula

/-!
# Axioms - Burgess-Xu (BX) Axiom Schemata for TM Logic

This module defines the axiom schemata for bimodal logic TM (Tense and Modality)
under the Burgess-Xu (BX) axiom system with irreflexive temporal semantics (A2 guard convention).

## Notation for Until and Since in the docstrings below

Three renderings appear in this file and they do **not** all order the arguments the same way.

| Rendering | Order | Where it comes from |
|---|---|---|
| `untl(g, e)`, `snce(g, e)` | **guard** first, event second | the constructor's own argument order (`Syntax/Formula.lean`), matching `def:BLplus-semantics` |
| `φ U ψ`, `φ S ψ` (infix) | **guard** first, event second | the paper's and the Typst manual's infix notation |
| `U(e, g)`, `S(e, g)` (prefix) | **event** first, guard second | `Formula.prettyPrint`'s output and the `schema_string` field of `typst/generated/machine-appendix.jsonl` |

The prefix `U(·,·)` form is deliberately *not* the constructor order: it is keyed to what the
printer emits, so quoting it keeps these docstrings comparable line-for-line with the machine
appendix. Where a docstring quotes **Burgess** or **Reynolds** directly, the rendering is that
author's own and follows their convention rather than any of the three above.

## Axiom System

The BX axiom system replaces the previous mixed-semantics axiom set. Under reflexive
semantics for all temporal operators (G/H use ≤/≥, U/S use ≤/≥ for witness), the
BX axioms provide a complete axiomatization for linear temporal orders without
requiring successor-chain constructions.

### Layers

1. **Propositional** (4): prop_k, prop_s, ex_falso, peirce
2. **S5 Modal** (5): modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
3. **BX Temporal** (22 = 11 schemas x 2 directions):
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
   - BX13/BX13': enrichment_until/since (Until-Since enrichment; Burgess A3a, Xu axiom (3))
4. **Modal-Temporal Interaction** (1): modal_future
   Note: temp_future (□φ → G□φ) is now derived from MF + T + Modal 4.
5. **Uniformity** (5): discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity
6. **Prior** (2): prior_UZ, prior_SZ
7. **Z1** (1): z1
8. **Density** (2): density, dense_indicator
9. **Reynolds Dedekind** (3): prior_U_gap, prior_S_gap, sep

**Total**: 45 axiom constructors
(32 core + 5 uniformity + 2 prior + 1 Z1 + 2 density + 3 Reynolds Dedekind),
where "core" is layers 1-4 (4 + 5 + 22 + 1). By frame class that is
37 base (layers 1-5) + 3 discrete-only (layers 6-7) + 2 dense-only (layer 8)
+ 3 Dedekind-only (layer 9), matching `scripts/typst-status-counts.sh`.
Note: temp_k_dist and temp_4 are now derived theorems (`temporalKDistDerived`,
`temporal4Derived` in TemporalDerived.lean).

### Key Properties

- All BX axioms are sound on all linear temporal orders (no frame conditions needed)
- The density axiom (GGφ → Gφ) is derivable from seriality (BX1 = serial_future)
- Discrete axioms (X/Y-based) are separate extension points, not included here
- BX5 + BX6 resolve Until-eventualities axiomatically (no forward_F needed)
- BX7 ensures linearity of temporal witnesses

## References

* Burgess 1982/84: Until-Since temporal logic axiomatization
* Xu 1988: Completeness for Until-Since on linear orders
* Venema 1993: Temporal logic survey
-/

namespace FormalSystem.ProofSystem

open FormalSystem.Syntax

/--
Axiom schemata for bimodal logic TM under the Burgess-Xu (BX) system.

45 constructors organized into nine layers:
- **Propositional** (4): Classical propositional tautologies
- **S5 Modal** (5): S5 axioms for metaphysical necessity □
- **BX Temporal** (22): Burgess-Xu axioms for Until/Since on linear orders
- **Interaction** (1): Modal-temporal interaction axiom (MF; TF now derived)
- **Uniformity** (5): Discreteness uniformity axioms (valid on all ordered abelian groups)
- **Prior** (2): Prior-UZ/SZ for discrete well-ordering (valid on discrete orders only)
- **Z1** (1): IsSuccArchimedean characteristic axiom (discrete-only)
- **Density** (2): GGφ → Gφ and ¬U(⊤,⊥) (dense-only)
- **Reynolds Dedekind** (3): Prior-U/Prior-S gap axioms and Sep (Dedekind-only)

Base axioms (37) are valid on all linear temporal orders. Prior/Z1 axioms (3) are discrete-only.
The density axioms (2) are valid only on densely ordered frames, and the three Reynolds
definable-gap axioms (3) only on the Dedekind class.
Note: temp_k_dist and temp_4 are now derived theorems (`temporalKDistDerived`,
`temporal4Derived` in TemporalDerived.lean).
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
  -- Layer 3: BX Temporal (20 = 10 future + 10 past-mirrors derived via duality)
  -- Note: temp_k_dist and temp_4 are now derived theorems.
  -- See Theorems/TemporalDerived.lean for temporalKDistDerived and temporal4Derived.
  /-- Serial future: `⊤ → F(⊤)` (future seriality).
  Under irreflexive semantics, every time point has a strict future. -/
  | serial_future :
    Axiom ((Formula.bot.imp Formula.bot).imp (Formula.someFuture (Formula.bot.imp Formula.bot)))
  /-- Serial past: `⊤ → P(⊤)` (past seriality).
  Under irreflexive semantics, every time point has a strict past. -/
  | serial_past :
    Axiom ((Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot)))
  /-- BX2G: Guard monotonicity of Until under G (guard-first: untl(guard, event)):
  `G(φ→χ) → ((φ U ψ) → (χ U ψ))`.
  Under open guard (t,s): G(φ→χ) covers all r > t, which includes (t,s).
  Unlike BX2, the pointwise (φ→χ) at t is not needed since t ∉ (t,s). -/
  | left_mono_until_G (φ χ ψ : Formula) :
      Axiom ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ)))
  /-- BX2H: Guard monotonicity of Since under H (guard-first: snce(guard, event)):
  `H(φ→χ) → ((φ S ψ) → (χ S ψ))`.
  Under open guard (s,t): H(φ→χ) covers all r < t, which includes (s,t).
  Unlike BX2', the pointwise (φ→χ) at t is not needed since t ∉ (s,t). -/
  | left_mono_since_H (φ χ ψ : Formula) :
      Axiom ((φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ)))
  /-- BX3: Event monotonicity of Until (guard-first: untl(guard, event)):
  `G(φ → ψ) → ((χ U φ) → (χ U ψ))`.
  If φ implies ψ at all times, then U(φ,χ) implies U(ψ,χ). -/
  | right_mono_until (φ ψ χ : Formula) :
      Axiom ((φ.imp ψ).allFuture.imp ((Formula.untl χ φ).imp (Formula.untl χ ψ)))
  /-- BX3': Event monotonicity of Since (guard-first: snce(guard, event)):
  `H(φ → ψ) → ((χ S φ) → (χ S ψ))`. -/
  | right_mono_since (φ ψ χ : Formula) :
      Axiom ((φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ)))
  /-- BX4: Temporal connectedness (future): `φ → G(P(φ))`.
  If φ holds now, then at all future times, P(φ) holds — the present is
  always in the past of the future. -/
  | connect_future (φ : Formula) :
      Axiom (φ.imp (φ.somePast.allFuture))
  /-- BX4': Temporal connectedness (past): `φ → H(F(φ))`.
  Mirror of BX4: the present is always in the future of the past. -/
  | connect_past (φ : Formula) :
      Axiom (φ.imp (φ.someFuture.allPast))
  /-- BX13: Until-Since enrichment (Burgess A3a, Xu axiom (3)):
  Burgess: `p ∧ U(α, β) → U(α ∧ S(p, β), β)`.
  In this tree's guard-first order (untl(guard, event)):
  `p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))`.
  Enriches the Until event with Since information from the current point.
  Valid under open guard (t,s): the Until guard interval (t,s) provides
  the Since guard at the witness s, since both intervals are identical. -/
  | enrichment_until (φ ψ p : Formula) :
      Axiom (Formula.and p (Formula.untl φ ψ) |>.imp
        (Formula.untl φ (Formula.and ψ (Formula.snce φ p))))
  /-- BX13': Since-Until enrichment (Burgess A3b, Xu axiom (4)):
  Burgess: `p ∧ S(α, β) → S(α ∧ U(p, β), β)`.
  In this tree's guard-first order (snce(guard, event)):
  `p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))`.
  Mirror of enrichment_until for the Since direction. -/
  | enrichment_since (φ ψ p : Formula) :
      Axiom (Formula.and p (Formula.snce φ ψ) |>.imp
        (Formula.snce φ (Formula.and ψ (Formula.untl φ p))))
  -- REMOVED: BX14 (separation_until) and BX14' (separation_since) constructors.
  -- These axioms (Burgess A4a/A4b) are unnecessary for axiom minimality.
  -- The chronicle splitting construction now uses Xu 1988 Lemma 3.2.1/3.2.2 instead.
  /-- BX5: Self-accumulation of Until (guard-first: untl(guard, event)):
  `U(ψ, φ) → U(ψ, φ ∧ U(ψ, φ))`.
  The eventuality enriches its own guard: at intermediate points, both φ holds
  AND the eventuality U(ψ,φ) persists. This is the key axiom for eventuality resolution. -/
  | self_accum_until (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp
        (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ))
  /-- BX5': Self-accumulation of Since (guard-first: snce(guard, event)):
  `S(ψ, φ) → S(ψ, φ ∧ S(ψ, φ))`. -/
  | self_accum_since (φ ψ : Formula) :
      Axiom ((Formula.snce φ ψ).imp
        (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ))
  /-- BX6: Absorption of Until (guard-first: untl(guard, event)):
  `U(φ ∧ U(ψ, φ), φ) → U(ψ, φ)`.
  Prevents infinite deferral: if the eventuality is deferred to a point where it
  still holds as φ ∧ U(ψ,φ), the two-step resolution collapses. -/
  | absorb_until (φ ψ : Formula) :
      Axiom ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ))
  /-- BX6': Absorption of Since (guard-first: snce(guard, event)):
  `S(φ ∧ S(ψ, φ), φ) → S(ψ, φ)`. -/
  | absorb_since (φ ψ : Formula) :
      Axiom ((Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ))
  /-- BX7: Linearity of Until (guard-first: untl(guard, event)):
  `U(ψ,φ) ∧ U(θ,χ) → U(ψ∧θ, φ∧χ) ∨ U(ψ∧χ, φ∧χ) ∨ U(φ∧θ, φ∧χ)`.
  If two Until formulas hold simultaneously, their witnesses are linearly ordered.
  The three disjuncts correspond to: witnesses coincide, first comes first, second comes first. -/
  | linear_until (φ ψ χ θ : Formula) :
      Axiom (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))
  /-- BX7': Linearity of Since (guard-first: snce(guard, event)):
  `S(ψ,φ) ∧ S(θ,χ) → S(ψ∧θ, φ∧χ) ∨ S(ψ∧χ, φ∧χ) ∨ S(φ∧θ, φ∧χ)`. -/
  | linear_since (φ ψ χ θ : Formula) :
      Axiom (Formula.and (Formula.snce φ ψ) (Formula.snce χ θ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.snce (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.snce (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.snce (Formula.and φ χ) (Formula.and φ θ))))
  -- NOTE: BX7a/BX7a' (linear_until_a7a/linear_since_a7a) removed -- unsound under open guard.
  -- Burgess's A7a has fixed event (ψ∧θ) in all disjuncts, but with strict/open guard
  -- semantics (t < r < s), the two Until witnesses s₁, s₂ cannot both contribute their
  -- events at a single point when s₁ ≠ s₂. Countermodel: φ=χ=⊤, ψ true only at s₁,
  -- θ true only at s₂ with s₁≠s₂ -- no point satisfies ψ∧θ.
  -- A7a may be valid under Burgess's closed-guard semantics (t ≤ r ≤ s) but not here.

  -- NOTE: BX8/BX8' (until_step/since_step) removed -- not sound under open guard.

  -- NOTE: BX9/BX9' (until_elim/since_elim) removed -- unsound under open guard (t,s).
  -- Archived in Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean.
  /-- BX10: Until implies eventuality (guard-first: untl(guard, event)):
  `U(ψ, φ) → F(ψ)`.
  U(ψ,φ) at t has witness s > t with ψ(s), so F(ψ) holds. -/
  | until_F (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp (Formula.someFuture ψ))
  /-- BX10': Since implies past eventuality (guard-first: snce(guard, event)):
  `S(ψ, φ) → P(ψ)`.
  Mirror of BX10 for the past direction. -/
  | since_P (φ ψ : Formula) :
      Axiom ((Formula.snce φ ψ).imp (Formula.somePast ψ))
  -- Layer 3b: Additional BX Temporal (4 = 2 axioms x 2 directions)
  /-- BX11: Temporal linearity:
  `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`.
  Future witnesses are linearly ordered. Uses linearity of the underlying temporal order.
  This axiom is NOT derivable from BX1-BX10 (see LinearityDerivedFacts.lean counterexample). -/
  | temp_linearity (φ ψ : Formula) :
      Axiom (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
            (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ)))))
  /-- BX11': Temporal linearity (past):
  `P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)`.
  Past dual of BX11. -/
  | temp_linearity_past (φ ψ : Formula) :
      Axiom (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
        (Formula.or (Formula.somePast (Formula.and φ ψ))
          (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
            (Formula.somePast (Formula.and (Formula.somePast φ) ψ)))))
  /-- BX12: F-Until equivalence (guard-first: untl(guard, event)):
  `F(φ) → U(φ, ⊤)`.
  Every future eventuality can be witnessed by an Until formula with vacuous guard.
  Here ⊤ = ¬⊥ = ⊥ → ⊥. Bridges F-formulas to Until-formulas. -/
  | F_until_equiv (φ : Formula) :
      Axiom ((Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ))
  /-- BX12': P-Since equivalence (guard-first: snce(guard, event)):
  `P(φ) → S(φ, ⊤)`.
  Past dual of BX12. -/
  | P_since_equiv (φ : Formula) :
      Axiom ((Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ))
  -- NOTE: Layer 3c (until_guard/since_guard) removed -- unsound under open guard (t,s).
  -- Archived in Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean.

  -- Layer 4: Modal-Temporal Interaction (1)
  -- Note: TF (□φ → G□φ) is now derived from MF + T + Modal 4 in Theorems/Combinators.lean.
  /-- Modal-Future: `□φ → □(Gφ)`. Necessary truths remain necessary in the future. -/
  | modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.allFuture φ)))
  -- Layer 5: Uniformity Axioms (5)
  -- These encode the uniformity of discreteness in ordered abelian groups.
  -- U(⊤,⊥) = "next top" witnesses an immediate successor (gap of size d > 0).
  -- By translation invariance of the group, this gap is uniform across all time points.
  /-- Discrete symmetry forward: U(⊤,⊥) → S(⊤,⊥).
  If there is a gap of size d ahead (no points in (t, t+d)), then by translation
  invariance there is the same gap behind (no points in (t-d, t)). -/
  | discrete_symm_fwd :
      Axiom ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
        (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)))
  /-- Discrete symmetry backward: S(⊤,⊥) → U(⊤,⊥).
  Mirror of discrete_symm_fwd: a backward gap implies a forward gap. -/
  | discrete_symm_bwd :
      Axiom ((Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
        (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))
  /-- Discrete propagation forward: U(⊤,⊥) → G(U(⊤,⊥)).
  If there is a gap of size d at t, then by translation invariance the same gap
  exists at every future point s > t (translate by s-t). -/
  | discrete_propagate_fwd :
      Axiom ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
        (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))))
  /-- Discrete propagation backward: U(⊤,⊥) → H(U(⊤,⊥)).
  If there is a gap of size d at t, then by translation invariance the same gap
  exists at every past point s < t. -/
  | discrete_propagate_bwd :
      Axiom ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
        (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))))
  /-- Discrete box necessity: U(⊤,⊥) → □(U(⊤,⊥)).
  If there is a gap of size d at t (discreteness witness), then by translation
  invariance the same gap exists at every accessible world at time t. Since box
  quantifies over histories at the same time, the discreteness witness propagates
  to all box-accessible worlds. Valid on all ordered abelian groups. -/
  | discrete_box_necessity :
      Axiom ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
        (Formula.box (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))))
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
      Axiom (φ.someFuture.imp (Formula.untl φ.neg φ))
  /-- Prior-SZ: `P(φ) → S(φ, ¬φ)`.
  Past dual of Prior-UZ. If φ held at some past time, then there is a nearest past
  time where φ held, with ¬φ holding at all intermediate points. -/
  | prior_SZ (φ : Formula) :
      Axiom (φ.somePast.imp (Formula.snce φ.neg φ))
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
      Axiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))
  -- Layer 8: Density Axiom (1)
  -- Valid on densely ordered frames (DenselyOrdered). Not valid on discrete frames.
  -- GGφ → Gφ: if φ holds at all times strictly after all strict-future times,
  -- then φ holds at all strict-future times (because density fills the gap).
  /-- Density: `GGφ → Gφ`.
  On a densely ordered frame, if φ holds at all times strictly after every strict
  future time, then φ holds at all strict future times. This is because for any
  t' > t, density provides t'' with t < t'' < t', and GGφ at t gives Gφ at t'',
  which gives φ at t'. This axiom is NOT valid on discrete frames (ℤ has gaps). -/
  | density (φ : Formula) :
      Axiom (φ.allFuture.allFuture.imp φ.allFuture)
  /-- Dense indicator: `¬U(⊤,⊥)`.
  On a densely ordered frame, `U(⊤,⊥)` ("there exists an immediate successor") is
  false at every point, since for any s > t, density provides r with t < r < s,
  so the interval (t,s) is never empty. This is the Burgess 1982 Section 1.6
  density axiom for Until/Since tense logic.
  This axiom is added alongside `density` (GGφ → Gφ), not as a replacement.
  The density schema alone is provably insufficient to derive `¬U(⊤,⊥)`
  (conservativity argument: all atom-free instances of GGφ → Gφ are valid on ℤ,
  but U(⊤,⊥) is true on ℤ). -/
  | dense_indicator :
      Axiom (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg
  -- Layer 9: Reynolds Dedekind Axioms (3)
  -- Reynolds' definable-gap-freeness axioms for real flow, printed p.168 of
  -- "An axiomatization for Until and Since over the reals without the IRR rule" (1992).
  -- These use the abbreviations `Formula.kPlus` / `Formula.kMinus`
  -- (K⁺A = ¬U(⊤,¬A), K⁻A = ¬S(⊤,¬A)) defined in `Syntax/Formula.lean`.
  --
  -- These axioms do NOT characterize Dedekind completeness -- no temporal formula can.
  -- Reynolds (printed p.169) is explicit that they enforce only a *definably*
  -- Dedekind-complete model: "there may be gaps in the order but ... you wouldn't know
  -- that just looking at the behaviour of temporal formulas". They are the axiomatic proxy.
  --
  -- RELATIONSHIP TO THE PAPER'S CO AXIOM.
  -- The JPL paper's `def:TMplus-c` bases its complete-order extension BX_c on a single extra
  -- axiom, CO = `△(Hφ → F(Hφ)) → (Hφ → Gφ)` (`Formula.co`), rather than on this triple.
  -- This tree keeps the Reynolds triple as the OFFICIAL basis, and CO is a derived theorem
  -- over it: see `FormalSystem.Theorems.DedekindDerived.co_derived`, which proves
  -- `⊢[fc] Formula.co φ` for every `fc` with `Dedekind ≤ fc` using `prior_U_gap` and base
  -- axioms only -- neither `prior_S_gap` nor `sep` is needed. The semantic companion is
  -- `FormalSystem.Metalogic.SoundnessLemmas.co_valid`.
  --
  -- The CONVERSE FAILS, and this is now MACHINE-CHECKED. CO does not derive `prior_U_gap`
  -- over the dense base: see `FormalSystem.Metalogic.Independence.CoNotPriorU`, whose
  -- `co_not_derives_prior_U_gap` (contexts of CO instances) and
  -- `co_not_derives_prior_U_gap_schema` (a CO-closed system with modus ponens, modal and
  -- temporal necessitation, and temporal duality) are both sorry-free. The witness is the
  -- periodic clock model -- `D = ℚ`, `W = ℚ ⧸ ℤ`, `w ⇒_x u iff u = w + ⟦x⟧`, with the
  -- symmetric irrational arc valuation `|q| < √2/4` -- in which every CO instance is true and
  -- `prior_U_gap p` is false at time `0`.
  --
  -- An EARLIER SKETCH RECORDED HERE WAS REFUTED, not merely left unverified, and must not be
  -- re-attempted: it proposed a ℚ-flow with isolated `¬φ` points accumulating at an irrational
  -- from above, framed as "the classical Stavi US-vs-FO phenomenon". In that model
  -- `ξ := ¬U(¬p,p) ∧ F(U(¬p,p))` has truth set `{t : t < √2}`, so `ξ` DEFINES THE CUT and
  -- `CO(ξ)` is false at `0`. Hiding an accumulation point never works -- some U/S formula
  -- recovers the cut. What works is homogeneity: on the clock frame the time translation by
  -- `1` fixes every world state, so no formula can see a distinguished time.
  --
  -- The countermodel is a fixed MODEL, not a frame, and that is forced rather than incidental.
  -- `def:frame-validity` quantifies over all valuations, and under that quantifier
  -- frame-validity of CO on a dense flow forces gap-freeness and hence forces Prior-U valid.
  -- This matches Reynolds' own "definably Dedekind-complete" caveat quoted above.
  --
  -- CONSEQUENCE FOR THE PAPER (out of scope for this repository). Now that the independence is
  -- established, `def:TMplus-c` is deductively too weak for `cor:tm-completeness`, whose
  -- completeness claim
  -- is deferred to this repository with no independent citation. Correcting it means switching
  -- the paper's BX_c basis to the Reynolds axioms, which is an amendment to
  -- `/home/benjamin/Philosophy/Papers/PossibleWorlds/` routed through the fix.md C4 process.
  -- No file under `Philosophy/Papers/` is edited from here; this note records the finding.
  /-- Prior-U (gap form): `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)`.
  If φ holds throughout some initial future segment and ¬φ holds somewhere in the future,
  then the φ-region has a definable upper endpoint: reading forward, `¬φ ∨ K⁺(¬φ)` holds
  until φ. On a Dedekind-complete flow the supremum of the φ-region exists and witnesses
  this; on a gappy flow it can fail.

  **Source**: Reynolds 1992, printed p.168, axiom "Prior-U" of the system US/R.

  **THIS IS NOT `prior_UZ`.** `Axiom.prior_UZ` (above) is the *integer well-ordering* Prior
  axiom `F(φ) → U(φ,¬φ)` at `FrameClass.Discrete`. Different statement, different frame
  class, confusingly similar name. Do not reuse, rename, generalize, or "unify" them. -/
  | prior_U_gap (φ : Formula) :
      Axiom ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
        (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg))))
  /-- Prior-S (gap form): `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)`.
  Past dual of `prior_U_gap`; the φ-region has a definable lower endpoint (an infimum).

  **Source**: Reynolds 1992, printed p.168, axiom "Prior-S" of the system US/R.

  **THIS IS NOT `prior_SZ`**, which is the integer well-ordering axiom
  `P(φ) → S(φ,¬φ)` at `FrameClass.Discrete`. See the caveat on `prior_U_gap`. -/
  | prior_S_gap (φ : Formula) :
      Axiom ((Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
        (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg))))
  /-- Sep (separation): `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)`.
  Reynolds' separation axiom. Its semantic validity over ℝ turns on the separability of the
  reals (ℝ has a countable dense suborder), though Sep does not *characterize* separability —
  Reynolds notes the long line satisfies it too.

  **Source**: Reynolds 1992, printed p.168. Reynolds defers the validity proof there:
  "we investigate this axiom in more detail in section 7 and defer proving its validity in
  ℝ until lemma 10 there." -/
  | sep (φ : Formula) :
      Axiom ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ))))
  deriving Repr

/--
Frame class classification for axiom validity.

The four frame classes form a partial order:
```
              Dedekind
                 ↑
    Dense --------'      Discrete
      ↑                     ↑
       \___________________/
                |
               Base
```

- `Base` is the bottom element: all base axioms are valid on all linear orders.
- `Dense` extends Base with the density axiom (GGφ → Gφ) and `dense_indicator` (¬U(⊤,⊥)),
  valid on densely ordered frames.
- `Discrete` extends Base with Prior-UZ/SZ and Z1, valid on discrete (SuccArchimedean) frames.
- `Dedekind` extends **Dense** with Reynolds' definable-gap axioms Prior-U, Prior-S and Sep,
  valid on dense Dedekind-complete frames. By `Semantics.complete_duration_discrete_or_dense`
  (`Semantics/DurationClassification.lean`) that is not merely "ℝ-like": a Dedekind-complete
  duration group is either `≃+o ℤ` or densely ordered, so once the density binder is imposed
  the class contains, up to order-and-group isomorphism, only the real flow. `FrameClass.Dedekind`
  is therefore the paper's **TM⁺_dc** (dense complete / real flow), not TM⁺_c.
- Dense and Discrete are incomparable: density contradicts discreteness.
- Discrete and Dedekind are likewise incomparable, and `Dedekind ≰ Dense`.

**Why `Dedekind` sits strictly above `Dense` rather than being a fourth incomparable leaf.**
This is a primary-source placement, not an intuition. Reynolds 1992 (printed p.168) lists,
as part of the axiomatization US/R for real flow, "axioms for density and no end points:
`K⁺⊤`, `K⁻⊤`, `F⊤`, `P⊤`". Unfolding the abbreviation `K⁺A = ¬U(⊤,¬A)` gives
`K⁺⊤ = ¬U(⊤,¬⊤)`, and normalising `¬⊤` to `⊥` gives `¬U(⊤,⊥)` — this tree's
`dense_indicator` (see `Axiom.dense_indicator` above). (The two are equal after that
normalisation, not syntactically identical: `Formula.top.neg` is `(⊥ → ⊥) → ⊥`, not `⊥`.)
Likewise `F⊤` and `P⊤` are the tree's `serial_future` / `serial_past`. So Reynolds'
Dedekind/real axiom set genuinely contains
the tree's density axiom, and a Dedekind derivation must be allowed to use it. Making
`Dedekind` a fresh incomparable leaf would render `density` and `dense_indicator`
inadmissible in `DerivationTree .Dedekind` and so could not host Reynolds' system at all.

**Soundness caveat.** Because `density` and `dense_indicator` are admissible at `.Dedekind`
and both are FALSE on ℤ (which is nonetheless conditionally complete), the soundness theorem
for this class must target the *dense* Dedekind predicate `ValidDedekindDense`, not the
density-free `ValidDedekind`. See `FormalSystem/Semantics/Validity.lean`.

**The paper's TM⁺_c has no frame class here, and that is a real gap rather than an omission.**
TM⁺_c is completeness *simpliciter*: no density binder, so by
`Semantics.complete_duration_discrete_or_dense` its models are exactly `{ℤ, ℝ}` up to
order-and-group isomorphism, and its theory is `Th(ℤ) ∩ Th(ℝ)`. No element of `FrameClass`
picks that class out. The two branches are covered separately and exhaustively — the
complete-but-discrete branch is *exactly* `ℤ` by `Semantics.complete_not_dense_iso_int`, and is
handled by `FrameClass.Discrete` / `ValidDiscrete`; the dense branch is `FrameClass.Dedekind` /
`ValidDedekindDense` — but their intersection is not itself a frame class, and adding one would
require an axiom set for `Th(ℤ) ∩ Th(ℝ)` that this tree does not have. `ValidDedekind` exists as
a predicate matching the TM⁺_c binder set, but is deliberately not a soundness target; its own
docstring in `Semantics/Validity.lean` explains why.

The key invariant is `ax.minFrameClass ≤ fc`: an axiom `ax` can appear in a derivation
parameterized by frame class `fc` only when `ax`'s minimum frame class is at most `fc`.
This replaces the ad-hoc predicates `isBase`, `isDenseCompatible`, `isDiscreteCompatible`.
-/
inductive FrameClass where
  | Base
  | Dense
  | Discrete
  | Dedekind
  deriving Repr, DecidableEq, Inhabited, BEq, Hashable

instance : LE FrameClass where
  le a b := match a, b with
    | .Base, _ => True
    | .Dense, .Dense => True
    | .Dense, .Dedekind => True
    | .Dedekind, .Dedekind => True
    | .Discrete, .Discrete => True
    | _, _ => False

instance : DecidableRel (LE.le : FrameClass → FrameClass → Prop) :=
  fun a b => by cases a <;> cases b <;> simp only [LE.le] <;> infer_instance

instance : PartialOrder FrameClass where
  le := (· ≤ ·)
  le_refl := by intro a; cases a <;> simp [LE.le]
  -- 4 constructors ⇒ le_trans is a 64-case split and le_antisymm a 16-case split.
  -- `trivial` discharges every `le_trans` case (each is either `True` or an absurd
  -- `False` hypothesis); `le_antisymm` needs `simp_all [LE.le]` for the asymmetric
  -- `Dense`/`Dedekind` pair. `by decide` remains a total fallback for any closed
  -- order goal, since `FrameClass` is finite with `DecidableEq` and the `DecidableRel`
  -- instance above.
  le_trans := by
    intro a b c hab hbc
    cases a <;> cases b <;> cases c <;> trivial
  le_antisymm := by
    intro a b hab hba
    cases a <;> cases b <;> first | rfl | simp_all [LE.le]

/-! ### Order-shape regression checks

These `example`s pin the exact shape of the `FrameClass` order so that a future edit to the
`LE` instance cannot silently change which axioms are admissible in which derivations. -/

example : FrameClass.Base ≤ FrameClass.Dedekind := by decide
example : FrameClass.Dense ≤ FrameClass.Dedekind := by decide
example : FrameClass.Dedekind ≤ FrameClass.Dedekind := by decide
example : ¬(FrameClass.Dedekind ≤ FrameClass.Dense) := by decide
example : ¬(FrameClass.Dedekind ≤ FrameClass.Discrete) := by decide
example : ¬(FrameClass.Discrete ≤ FrameClass.Dedekind) := by decide
example : ¬(FrameClass.Dense ≤ FrameClass.Discrete) := by decide
example : ¬(FrameClass.Discrete ≤ FrameClass.Dense) := by decide

/--
Minimum frame class for each axiom constructor.

This is the single source of truth for axiom-frame-class compatibility:
- Base (37 axioms): valid on all linear temporal orders
- Dense (2 axioms: density, dense_indicator): valid on densely ordered frames
- Discrete (3 axioms: prior_UZ, prior_SZ, z1): valid on discrete frames
- Dedekind (3 axioms: prior_U_gap, prior_S_gap, sep): valid on dense
  Dedekind-complete frames

Total: 45 axiom constructors.

Since `Dense ≤ Dedekind`, a `DerivationTree FrameClass.Dedekind` admits the Base axioms,
the two Dense axioms, and the three Dedekind axioms — but not the Discrete ones
(`Discrete` and `Dedekind` are incomparable).

The constraint `ax.minFrameClass ≤ fc` in DerivationTree's axiom constructor
ensures that only axioms compatible with frame class `fc` can appear in a
derivation tree parameterized by `fc`.
-/
def Axiom.minFrameClass {φ : Formula} : Axiom φ → FrameClass
  | density _ => .Dense
  | dense_indicator => .Dense
  | prior_UZ _ => .Discrete
  | prior_SZ _ => .Discrete
  | z1 _ => .Discrete
  | prior_U_gap _ => .Dedekind
  | prior_S_gap _ => .Dedekind
  | sep _ => .Dedekind
  | _ => .Base

/-- Base is the minimum frame class: `FrameClass.Base ≤ fc` for all `fc`.

**Why `FrameClass.Base` is essential here**: `Base` is the *subject* of this statement, not a
pin on it — the theorem says precisely that `Base` is the order's bottom element. It is the
canonical `Base`-to-any-`fc` lift used throughout `Theorems/`: at a `DerivationTree.axiom` site
the `le` argument is `FrameClass.base_le fc`, and for a whole derivation it is
`d.lift (FrameClass.base_le fc)` (packaged as `Theorems.Combinators.baseThm`). -/
theorem FrameClass.base_le (fc : FrameClass) : FrameClass.Base ≤ fc := by
  cases fc <;> trivial

/-! ## Strong Release and Strong Trigger Interaction

Strong Release M(φ,ψ) = ψ U (ψ ∧ φ) and Strong Trigger ST(φ,ψ) = ψ S (ψ ∧ φ)
are derived operators. Their interaction with modal operators (□, ◇, G, F, H, P)
follows from existing BX axioms combined with their definitions:

- `□φ → G(M(φ,ψ))`: From modal_future + right_mono_until + definitions.
- `□φ → H(ST(φ,ψ))`: From modal_past (derived) + right_mono_since + definitions.
- Duality: `M(φ,ψ) ↔ ¬W(¬φ,¬ψ)` and `ST(φ,ψ) ↔ ¬WS(¬φ,¬ψ)` are semantic
  equivalences derivable via truth conditions.

No new `Axiom` constructors are needed since M/ST expand to primitive
`untl`/`snce` forms, and all interaction properties are theorems derivable
from the existing BX1-BX12 + modal_future axiom system.
-/

end FormalSystem.ProofSystem
