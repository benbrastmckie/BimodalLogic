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
| `untl(g, e)`, `snce(g, e)` | **guard** first, event second | the constructor's own argument order (`Syntax/Formula.lean`), matching `def:BL-semantics` |
| `φ U ψ`, `φ S ψ` (infix) | **guard** first, event second | the paper's and the Typst manual's infix notation |
| `U(e, g)`, `S(e, g)` (prefix) | **event** first, guard second | `Formula.prettyPrint`'s output and the `schema_string` field of `typst/generated/machine-appendix.jsonl` |

The prefix `U(·,·)` form is deliberately *not* the constructor order: it is keyed to what the
printer emits, so quoting it keeps these docstrings comparable line-for-line with the machine
appendix. Where a docstring quotes **Burgess** or **Reynolds** directly, the rendering is that
author's own and follows their convention rather than any of the three above.

## Axiom System

The BX axiom system replaces the previous mixed-semantics axiom set. Under irreflexive
semantics for all temporal operators (G/H quantify over strictly later/earlier times, and U/S
take a strictly later/earlier witness with the guard required only on the open interval
between), the BX axioms provide a complete axiomatization for linear temporal orders without
requiring successor-chain constructions.

### Layers

The primitive axioms are exactly the paper's axiom schemata (`def:S5`, `def:BX`, `def:BX-z`,
`def:BX-d`, `def:BX-r`; see `docs/reference/paper-definitions-of-record.md`). Every
past-directed mirror, and the S5 schemata 4 and B, are derived theorems in
`FormalSystem.ProofSystem.DerivedAxioms` (mirrors by the time-reflection rule TR,
`DerivationTree.time_reflection`; 4 and B from MK, MT and M5).

1. **Propositional** (4): prop_k, prop_s, ex_falso, peirce (CPL)
2. **S5 Modal** (3): modal_t (MT), modal_5_collapse (M5), modal_k_dist (MK)
3. **BX Temporal** (11, future direction only; the past mirrors are TR-derived):
   - TS: serial_future
   - UG: left_mono_until_G
   - UC: right_mono_until
   - TC: connect_future
   - SU: enrichment_until
   - UF: self_accum_until
   - UI: absorb_until
   - CN: linear_until
   - UE: until_F
   - TL: temp_linearity
   - UT: F_until_equiv
4. **Modal-Temporal Interaction** (1): modal_future (MF)
   Note: temp_future (□φ → G□φ) is derived from MF + T + Modal 4.
5. **Uniformity** (4): discrete_symm_fwd (NP), discrete_propagate_fwd (NF),
   discrete_propagate_bwd (NA; this is the paper's NA itself, `X⊤ → H X⊤`, not a mirror of
   NF), discrete_box_necessity (NB)
6. **Prior** (1): prior_UZ (UZ)
7. **Z1** (1): z1 (Z1)
8. **Density** (2): density (DN), dense_indicator (NN)
9. **Reynolds Dedekind** (2): prior_U_gap (PU), sep (SEP)

**Total**: 29 axiom constructors
(19 core + 4 uniformity + 1 prior + 1 Z1 + 2 density + 2 Reynolds Dedekind),
where "core" is layers 1-4 (4 + 3 + 11 + 1). By frame
class that is 23 base (layers 1-5) + 2 discrete-only (layers 6-7) + 2 dense-only (layer 8)
+ 2 RTime-only (layer 9), matching `scripts/typst-status-counts.sh`.
Note: temp_k_dist and temp_4 are derived theorems (`temporalKDistDerived`,
`temporal4Derived` in TemporalDerived.lean).

### Key Properties

- All BX axioms are sound on all linear temporal orders (no frame conditions needed)
- The density axiom (GGφ → Gφ) is derivable from seriality (BX1 = serial_future)
- Discrete axioms (X/Y-based) are separate extension points, not included here
- BX5 + BX6 resolve Until-eventualities axiomatically (no forward_F needed)
- BX7 ensures linearity of temporal witnesses

## Axiom Sources

The paper's `def:BX` footnote attributes most of the BX temporal schemata to Burgess and Xu.
The reconciled map is below. "B82" is Burgess 1982 ("Axioms for tense logic I: Since and
Until", §1.3 unless noted), "B84" is Burgess 1984 ("Basic Tense Logic"), and "Xu" gives the
formula numbers of Xu 1988 ("On some U,S-tense logics"). Burgess numbers his axioms `A1a`-`A7a`
with mirror images `A1b`-`A7b`, and B82 and B84 each have their own, unrelated, `A7a`. Burgess
writes `U(event, guard)`, so each `Burgess:` line in a docstring below is quoted in that order.

| Paper key | Lean constructor / derived mirror (`DerivedAxioms`) | Burgess | Xu 1988 |
|---|---|---|---|
| TN | `DerivationTree.temporal_necessitation` (rule) | B82 rule TG, its G half | — |
| TS | `serial_future` / `serial_past` | B82 §1.6, "No Last Element" `F⊤` (and mirror) | — |
| UC | `right_mono_until` / `right_mono_since` | B82 A1a / A1b | (1) / (2) |
| UG | `left_mono_until_G` / `left_mono_since_H` | B82 A2a / A2b | (1) / (2) |
| SU | `enrichment_until` / `enrichment_since` | B82 A3a / A3b | (3) / (4) |
| UF | `self_accum_until` / `self_accum_since` | B82 A5a / A5b | (7) / (8) |
| UI | `absorb_until` / `absorb_since` | B82 A6a / A6b | (9) / — |
| CN | `linear_until` / `linear_since` | B82 A7a / A7b | (10) / (11) |
| UE | `until_F` / `since_P` | not in B82: follows from UG with new guard `⊤`, plus TN | — |
| TL | `temp_linearity` / `temp_linearity_past` | B84 §0.3 A2a / A2b, verbatim | (13) nearest |

B82's A4a/A4b is the one Burgess 1982 pair the system omits (see the `BX14` note below). TC, UT,
NP, NF, NA and NB are original to the paper, and TR is a metarule with no listed source. Xu
places (10) in his axiom set Σ₄, which is complete for the class 𝒞₄ of linear frames. On its
own, (10) defines a first-order condition on intervals, his (10)*, not linearity itself.

## References

* [burgess1982], [burgess1984]: Until-Since temporal logic axiomatization
* [xu1988]: Completeness for Until-Since on linear orders
* [venema1993]: Temporal logic survey
-/

namespace FormalSystem.ProofSystem

open FormalSystem.Syntax

/--
Axiom schemata for bimodal logic TM under the Burgess-Xu (BX) system: exactly the paper's
primitive schemata.

29 constructors organized into nine layers:
- **Propositional** (4): Classical propositional tautologies
- **S5 Modal** (3): MT, M5 and MK (4 and B are derived, `DerivedAxioms.modal_4`/`modal_b`)
- **BX Temporal** (11): Burgess-Xu axioms for Until/Since on linear orders, future direction;
  the past mirrors are derived by TR (`DerivedAxioms`)
- **Interaction** (1): Modal-temporal interaction axiom (MF; TF derived)
- **Uniformity** (4): Discreteness uniformity axioms NP, NF, NA, NB (valid on all ordered
  abelian groups)
- **Prior** (1): Prior-UZ for discrete well-ordering (valid on discrete orders only)
- **Z1** (1): IsSuccArchimedean characteristic axiom (discrete-only)
- **Density** (2): GGφ → Gφ and ¬U(⊤,⊥) (dense-only)
- **Reynolds Dedekind** (2): Prior-U gap axiom and Sep (RTime-only)

Base axioms (23) are valid on all linear temporal orders. Prior/Z1 axioms (2) are discrete-only.
The density axioms (2) are valid only on densely ordered frames, and the two Reynolds
definable-gap axioms (2) only on the RTime class.
Note: temp_k_dist and temp_4 are derived theorems (`temporalKDistDerived`,
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
  -- Layer 2: S5 Modal (3; modal 4 and B are derived, see `DerivedAxioms`)
  /-- Modal T: `□φ → φ` (reflexivity) -/
  | modal_t (φ : Formula) : Axiom (Formula.box φ |>.imp φ)
  /-- Modal 5 Collapse: `◇□φ → □φ` (S5 characteristic) -/
  | modal_5_collapse (φ : Formula) : Axiom (φ.box.diamond.imp φ.box)
  /-- Modal K Distribution: `□(φ → ψ) → (□φ → □ψ)` -/
  | modal_k_dist (φ ψ : Formula) :
      Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
  -- Layer 3: BX Temporal (future direction; every past mirror is derived by the time-reflection
  -- rule TR, see `FormalSystem.ProofSystem.DerivedAxioms`)
  -- Note: temp_k_dist and temp_4 are now derived theorems.
  -- See Theorems/TemporalDerived.lean for temporalKDistDerived and temporal4Derived.
  /-- Serial future: `⊤ → F(⊤)` (future seriality; Burgess 1982 §1.6, No Last Element).
  Under irreflexive semantics, every time point has a strict future. -/
  | serial_future :
    Axiom ((Formula.bot.imp Formula.bot).imp (Formula.someFuture (Formula.bot.imp Formula.bot)))
  /-- BX2G: Guard monotonicity of Until under G (Burgess A2a, Xu axiom (1)):
  Burgess: `G(p ⊃ q) ⊃ (U(r, p) ⊃ U(r, q))`.
  In this tree's guard-first order (untl(guard, event)):
  `G(φ→χ) → ((φ U ψ) → (χ U ψ))`.
  Under open guard (t,s): G(φ→χ) covers all r > t, which includes (t,s).
  Unlike BX2, the pointwise (φ→χ) at t is not needed since t ∉ (t,s). -/
  | left_mono_until_G (φ χ ψ : Formula) :
      Axiom ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ)))
  /-- BX3: Event monotonicity of Until (Burgess A1a, Xu axiom (1)):
  Burgess: `G(p ⊃ q) ⊃ (U(p, r) ⊃ U(q, r))`.
  In this tree's guard-first order (untl(guard, event)):
  `G(φ → ψ) → ((χ U φ) → (χ U ψ))`.
  If φ implies ψ at all times, then U(φ,χ) implies U(ψ,χ). -/
  | right_mono_until (φ ψ χ : Formula) :
      Axiom ((φ.imp ψ).allFuture.imp ((Formula.untl χ φ).imp (Formula.untl χ ψ)))
  /-- BX4: Temporal connectedness (future): `φ → G(P(φ))`.
  If φ holds now, then at all future times, P(φ) holds — the present is
  always in the past of the future. -/
  | connect_future (φ : Formula) :
      Axiom (φ.imp (φ.somePast.allFuture))
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
  -- REMOVED: BX14 (separation_until) and BX14' (separation_since) constructors.
  -- These axioms (Burgess A4a/A4b) are unnecessary for axiom minimality.
  -- The chronicle splitting construction now uses Xu 1988 Lemma 3.2.1/3.2.2 instead.
  /-- BX5: Self-accumulation of Until (Burgess A5a, Xu axiom (7)):
  Burgess: `U(p, q) ⊃ U(p, q ∧ U(p, q))`.
  Printer order (event first; the constructor itself is guard-first untl(guard, event)):
  `U(ψ, φ) → U(ψ, φ ∧ U(ψ, φ))`.
  The eventuality enriches its own guard: at intermediate points, both φ holds
  AND the eventuality U(ψ,φ) persists. This is the key axiom for eventuality resolution. -/
  | self_accum_until (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp
        (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ))
  /-- BX6: Absorption of Until (Burgess A6a, Xu axiom (9)):
  Burgess: `U(q ∧ U(p, q), q) ⊃ U(p, q)`.
  Printer order (event first; the constructor itself is guard-first untl(guard, event)):
  `U(φ ∧ U(ψ, φ), φ) → U(ψ, φ)`.
  Prevents infinite deferral: if the eventuality is deferred to a point where it
  still holds as φ ∧ U(ψ,φ), the two-step resolution collapses. -/
  | absorb_until (φ ψ : Formula) :
      Axiom ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ))
  /-- BX7: Linearity of Until (Burgess 1982 A7a, Xu 1988 axiom (10)):
  Burgess: `U(p, q) ∧ U(r, s) ⊃ U(p ∧ r, q ∧ s) ∨ U(p ∧ s, q ∧ s) ∨ U(q ∧ r, q ∧ s)`.
  With p = ψ, q = φ, r = θ, s = χ, in printer order (event first; the constructor itself is
  guard-first untl(guard, event)):
  `U(ψ,φ) ∧ U(θ,χ) → U(ψ∧θ, φ∧χ) ∨ U(ψ∧χ, φ∧χ) ∨ U(φ∧θ, φ∧χ)`.
  All three disjuncts share the fixed guard `φ∧χ` (Burgess's `q ∧ s`); only the events vary.
  If two Until formulas hold simultaneously, their witnesses are linearly ordered.
  The three disjuncts correspond to: witnesses coincide, first comes first, second comes first.
  Sound under this tree's strict/open-guard semantics: see `linear_until_valid`. -/
  | linear_until (φ ψ χ θ : Formula) :
      Axiom (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))
  -- NOTE (provenance): `linear_until`/`linear_since` ARE Burgess 1982 A7a/A7b
  -- (Xu 1988 (10)/(11)). Burgess writes U(event, guard), and A7a's three disjuncts share
  -- the fixed GUARD q∧s while the events vary. A former constructor pair
  -- `linear_until_a7a`/`linear_since_a7a` copied A7a's argument positions into the
  -- guard-first `untl`/`snce` without swapping them, so Burgess's fixed guard landed in the
  -- event slot and every disjunct had the fixed EVENT ψ∧θ. That fixed-event variant is
  -- unsound (countermodel: φ=χ=⊤, ψ true only at s₁, θ true only at s₂, s₁≠s₂, so no
  -- point satisfies ψ∧θ) and was removed. The defect was in the transcription, not in A7a:
  -- Burgess's own semantics (1982 §1.2) is the same strict/open-guard semantics used here
  -- (the guard holds on x < z < y), under which A7a is valid (`linear_until_valid`).

  -- NOTE: BX8/BX8' (until_step/since_step) removed -- not sound under open guard.

  -- NOTE: BX9/BX9' (until_elim/since_elim) removed -- unsound under open guard (t,s).
  -- Archived in Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean.
  /-- BX10: Until implies eventuality (the paper's UE; not a Burgess axiom, since it follows
  from UG = `left_mono_until_G` with the new guard `⊤`, plus TN for `G(φ → ⊤)`;
  guard-first: untl(guard, event)):
  `U(ψ, φ) → F(ψ)`.
  U(ψ,φ) at t has witness s > t with ψ(s), so F(ψ) holds. -/
  | until_F (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp (Formula.someFuture ψ))
  -- Layer 3b: Additional BX Temporal (TL, UT; their past mirrors are TR-derived)
  /-- BX11: Temporal linearity (Burgess 1984 §0.3 axiom A2a; nearest Xu 1988 formula is (13)):
  `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`.
  Future witnesses are linearly ordered. Uses linearity of the underlying temporal order.
  This axiom is NOT derivable from BX1-BX10 (see LinearityDerivedFacts.lean counterexample). -/
  | temp_linearity (φ ψ : Formula) :
      Axiom (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
            (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ)))))
  /-- BX12: F-Until equivalence (guard-first: untl(guard, event)):
  `F(φ) → U(φ, ⊤)`.
  Every future eventuality can be witnessed by an Until formula with vacuous guard.
  Here ⊤ = ¬⊥ = ⊥ → ⊥. Bridges F-formulas to Until-formulas. -/
  | F_until_equiv (φ : Formula) :
      Axiom ((Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ))
  -- NOTE: Layer 3c (until_guard/since_guard) removed -- unsound under open guard (t,s).
  -- Archived in Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean.

  -- Layer 4: Modal-Temporal Interaction (1)
  -- Note: TF (□φ → G□φ) is now derived from MF + T + Modal 4 in Theorems/Combinators.lean.
  /-- Modal-Future: `□φ → □(Gφ)`. Necessary truths remain necessary in the future. -/
  | modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.allFuture φ)))
  -- Layer 5: Uniformity Axioms (4: NP, NF, NA, NB; the NP mirror is TR-derived)
  -- These encode the uniformity of discreteness in ordered abelian groups.
  -- U(⊤,⊥) = "next top" witnesses an immediate successor (gap of size d > 0).
  -- By translation invariance of the group, this gap is uniform across all time points.
  /-- Discrete symmetry forward: U(⊤,⊥) → S(⊤,⊥).
  If there is a gap of size d ahead (no points in (t, t+d)), then by translation
  invariance there is the same gap behind (no points in (t-d, t)). -/
  | discrete_symm_fwd :
      Axiom ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
        (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)))
  /-- Discrete propagation forward: U(⊤,⊥) → G(U(⊤,⊥)).
  If there is a gap of size d at t, then by translation invariance the same gap
  exists at every future point s > t (translate by s-t). -/
  | discrete_propagate_fwd :
      Axiom ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
        (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))))
  /-- Discrete propagation backward: U(⊤,⊥) → H(U(⊤,⊥)). This is the paper's NA
  (`X⊤ → H X⊤`) itself, a primitive axiom: despite the name it is **not** the time-reflection
  mirror of NF (`discrete_propagate_fwd`), which would be `Y⊤ → H Y⊤`.
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
  -- Layer 6: Prior Axiom for Integers (1: UZ; its past mirror is TR-derived)
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
  -- Layer 9: Reynolds Dedekind Axioms (2: PU, SEP; the PU mirror is TR-derived)
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
  -- The JPL paper's `def:BX-r` bases its complete-order extension BX_r on the dense logic
  -- BX_d extended by PU and SEP, with CO = `△(Hφ → F(Hφ)) → (Hφ → Gφ)` (`Formula.co`) a
  -- DERIVED THEOREM rather than a further axiom. That is this tree's own arrangement: the
  -- repository keeps the Reynolds triple as the OFFICIAL basis, and CO is derived
  -- over it: see `FormalSystem.Theorems.DedekindDerived.coDerived`, which proves
  -- `⊢[fc] Formula.co φ` for every `fc` with `RTime ≤ fc` using `prior_U_gap` and base
  -- axioms only -- neither `prior_S_gap` nor `sep` is needed. The semantic companion is
  -- `FormalSystem.Metalogic.SoundnessLemmas.co_valid`.
  --
  -- The CONVERSE FAILS, and this is now MACHINE-CHECKED. CO does not derive `prior_U_gap`
  -- over the dense base: see `FormalSystem.Metalogic.Independence.CoNotPriorU`, whose
  -- `co_not_derives_prior_U_gap` (contexts of CO instances) and
  -- `co_not_derives_prior_U_gap_schema` (a CO-closed system with modus ponens, modal and
  -- temporal necessitation, and time reflection) are both sorry-free. The witness is the
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
  -- CONSEQUENCE FOR THE PAPER -- DISCHARGED. An earlier revision of this note recorded that
  -- `def:BX-r` was deductively too weak for `cor:tm-completeness`, and that correcting it
  -- meant switching the paper's basis for the complete-order extension to the Reynolds axioms,
  -- as an amendment routed through the fix.md C4 process. The paper has since made exactly that
  -- switch: BX_r is now BX_d plus PU and SEP, with CO derived. Repository and paper agree, and
  -- nothing here is outstanding.
  -- What remains asymmetric is the STRENGTH of the claim on each side. The paper's own note on
  -- the converse direction -- whether CO alone axiomatizes the same logic as the full triple --
  -- is commented out, conjectures failure rather than asserting it, and sketches the route by a
  -- ℚ-flow with isolated `¬φ` points accumulating at an irrational from above. That sketch is
  -- the route REFUTED immediately above; the independence itself is established outright here by
  -- the machine-checked `FormalSystem.Metalogic.Independence.CoNotPriorU`, on the periodic clock
  -- model instead. No file under `Philosophy/Papers/` is edited from here; this note records the
  -- finding.
  /-- Prior-U (gap form): `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)`.
  If φ holds throughout some initial future segment and ¬φ holds somewhere in the future,
  then the φ-region has a definable upper endpoint: reading forward, `¬φ ∨ K⁺(¬φ)` holds
  until φ. On a Dedekind-complete flow the supremum of the φ-region exists and witnesses
  this; on a gappy flow it can fail.

  **Source**: Reynolds 1992, printed p.168, axiom "Prior-U" of the system US/R.

  **THIS IS NOT `prior_UZ`.** `Axiom.prior_UZ` (above) is the *integer well-ordering* Prior
  axiom `F(φ) → U(φ,¬φ)` at `FrameClass.ZTime`. Different statement, different frame
  class, confusingly similar name. Do not reuse, rename, generalize, or "unify" them. -/
  | prior_U_gap (φ : Formula) :
      Axiom ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
        (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg))))
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
               RTime
                 ↑
    Dense --------'      ZTime
      ↑                     ↑
       \___________________/
                |
               Base
```

- `Base` is the bottom element: all base axioms are valid on all linear orders.
- `Dense` extends Base with the density axiom (GGφ → Gφ) and `dense_indicator` (¬U(⊤,⊥)),
  valid on densely ordered frames.
- `ZTime` extends Base with Prior-UZ/SZ and Z1, valid on discrete (SuccArchimedean) frames.
- `RTime` extends **Dense** with Reynolds' definable-gap axioms Prior-U, Prior-S and Sep,
  valid on dense Dedekind-complete frames. By `Semantics.complete_duration_discrete_or_dense`
  (`Semantics/DurationClassification.lean`) that is not merely "ℝ-like": a Dedekind-complete
  duration group is either `≃+o ℤ` or densely ordered, so once the density binder is imposed
  the class contains, up to order-and-group isomorphism, only the real flow. `FrameClass.RTime`
  is therefore the paper's **TM_r** — the `ℝ`-time row of `cor:tm-completeness`.
- Dense and ZTime are incomparable: density contradicts discreteness.
- ZTime and RTime are likewise incomparable, and `RTime ≰ Dense`.

**Why `RTime` sits strictly above `Dense` rather than being a fourth incomparable leaf.**
This is a primary-source placement, not an intuition. Reynolds 1992 (printed p.168) lists,
as part of the axiomatization US/R for real flow, "axioms for density and no end points:
`K⁺⊤`, `K⁻⊤`, `F⊤`, `P⊤`". Unfolding the abbreviation `K⁺A = ¬U(⊤,¬A)` gives
`K⁺⊤ = ¬U(⊤,¬⊤)`, and normalising `¬⊤` to `⊥` gives `¬U(⊤,⊥)` — this tree's
`dense_indicator` (see `Axiom.dense_indicator` above). (The two are equal after that
normalisation, not syntactically identical: `Formula.top.neg` is `(⊥ → ⊥) → ⊥`, not `⊥`.)
Likewise `F⊤` and `P⊤` are the tree's `serial_future` / `serial_past`. So Reynolds'
Dedekind/real axiom set genuinely contains
the tree's density axiom, and an `RTime` derivation must be allowed to use it. Making
`RTime` a fresh incomparable leaf would render `density` and `dense_indicator`
inadmissible in `DerivationTree .RTime` and so could not host Reynolds' system at all.

**Soundness caveat.** The soundness theorem for this class must target `ValidRTime`, not the
density-free `ValidComplete`. See the `ValidComplete` caveat in `Semantics/Validity.lean` — the one place the `ValidComplete` / `ValidRTime` distinction is argued in full.

**`ValidComplete` is a repository-only predicate, and answers to no paper system.** It is the
density-free completeness binder: by `Semantics.complete_duration_discrete_or_dense` its models
are exactly `{ℤ, ℝ}` up to order-and-group isomorphism, and its theory is `Th(ℤ) ∩ Th(ℝ)`. No
element of `FrameClass` picks that class out, and none needs to — every row of
`cor:tm-completeness` is covered here: the `ℤ`-time row is `FrameClass.ZTime` / `ValidZTime`
(the complete-but-discrete branch being *exactly* `ℤ`, by
`Semantics.complete_not_dense_iso_int`), and the `ℝ`-time row is `FrameClass.RTime` /
`ValidRTime`. Their intersection is not itself a frame class, and adding one would require an
axiom set for `Th(ℤ) ∩ Th(ℝ)` that this tree does not have — but nothing in the paper asks for
one. `ValidComplete` survives for two internal purposes only: it is the target of the forgetful
bridge, and it is what the Hölder-style dichotomy above is stated over. It is deliberately not a
soundness target; its own docstring in `Semantics/Validity.lean` explains why.

The key invariant is `ax.minFrameClass ≤ fc`: an axiom `ax` can appear in a derivation
parameterized by frame class `fc` only when `ax`'s minimum frame class is at most `fc`.
This replaces the ad-hoc predicates `isBase`, `isDenseCompatible`, `isDiscreteCompatible`.
-/
inductive FrameClass where
  | Base
  | Dense
  | ZTime
  | RTime
  deriving Repr, DecidableEq, Inhabited, BEq, Hashable

instance : LE FrameClass where
  le a b := match a, b with
    | .Base, _ => True
    | .Dense, .Dense => True
    | .Dense, .RTime => True
    | .RTime, .RTime => True
    | .ZTime, .ZTime => True
    | _, _ => False

instance : DecidableRel (LE.le : FrameClass → FrameClass → Prop) :=
  fun a b => by cases a <;> cases b <;> simp only [LE.le] <;> infer_instance

instance : PartialOrder FrameClass where
  le := (· ≤ ·)
  le_refl := by intro a; cases a <;> simp [LE.le]
  -- 4 constructors ⇒ le_trans is a 64-case split and le_antisymm a 16-case split.
  -- `trivial` discharges every `le_trans` case (each is either `True` or an absurd
  -- `False` hypothesis); `le_antisymm` needs `simp_all [LE.le]` for the asymmetric
  -- `Dense`/`RTime` pair. `by decide` remains a total fallback for any closed
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

example : FrameClass.Base ≤ FrameClass.RTime := by decide
example : FrameClass.Dense ≤ FrameClass.RTime := by decide
example : FrameClass.RTime ≤ FrameClass.RTime := by decide
example : ¬(FrameClass.RTime ≤ FrameClass.Dense) := by decide
example : ¬(FrameClass.RTime ≤ FrameClass.ZTime) := by decide
example : ¬(FrameClass.ZTime ≤ FrameClass.RTime) := by decide
example : ¬(FrameClass.Dense ≤ FrameClass.ZTime) := by decide
example : ¬(FrameClass.ZTime ≤ FrameClass.Dense) := by decide

/--
Minimum frame class for each axiom constructor.

This is the single source of truth for axiom-frame-class compatibility:
- Base (37 axioms): valid on all linear temporal orders
- Dense (2 axioms: density, dense_indicator): valid on densely ordered frames
- ZTime (3 axioms: prior_UZ, prior_SZ, z1): valid on discrete frames
- RTime (3 axioms: prior_U_gap, prior_S_gap, sep): valid on dense
  Dedekind-complete frames

Total: 45 axiom constructors.

Since `Dense ≤ RTime`, a `DerivationTree FrameClass.RTime` admits the Base axioms,
the two Dense axioms, and the three Reynolds axioms — but not the ZTime ones
(`ZTime` and `RTime` are incomparable).

The constraint `ax.minFrameClass ≤ fc` in DerivationTree's axiom constructor
ensures that only axioms compatible with frame class `fc` can appear in a
derivation tree parameterized by `fc`.
-/
def Axiom.minFrameClass {φ : Formula} : Axiom φ → FrameClass
  | density _ => .Dense
  | dense_indicator => .Dense
  | prior_UZ _ => .ZTime
  | z1 _ => .ZTime
  | prior_U_gap _ => .RTime
  | sep _ => .RTime
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
