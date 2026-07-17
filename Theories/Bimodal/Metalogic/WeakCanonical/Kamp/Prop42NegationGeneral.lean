import Bimodal.Metalogic.WeakCanonical.Kamp.Prop42ExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import Bimodal.Metalogic.WeakCanonical.Kamp.Translation
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# Proposition 4.2 on an ARBITRARY-pin two-free-variable `∃∀`-object (Rabinovich 2014, PDF p.7)

`Prop42ExistsForall.lean` negates only the endpoint-pinned, trivial-cap canonical form
(`EndpointPinnedCapTrivial`). Rabinovich's Proposition 4.2 proof (Section 5, PDF p.7) negates a
*general* two-free-variable `∃∀`-object — arbitrary pins `z₀ = x_m`, `z₁ = x_k`, contentful caps
`β₀`, `β_{n+1}` — by **splitting its single ordered chain at the two pinned points into three
consecutive pieces** and negating each independently, reassembling by **disjunction**:

```
ψ(z₀,z₁)  ≡  ψ₀(z₀)  ∧  φ(z₀,z₁)  ∧  ψ₁(z₁)          (PDF p.7, m < k case)
¬ψ        ≡  ¬ψ₀     ∨  ¬φ         ∨  ¬ψ₁
```

* `ψ₀(z₀)` — the below piece `x₀ < … < x_m` with the before-cap `β₀`; a **one-free-variable**
  `∃∀` (free var pinned to the RIGHT endpoint `x_m`). Negated via Prop 3.5 (`translateProp35`):
  it is equivalent to a `TL(Until,Since)` formula, whose negation is realized directly as a
  single endpoint `TemporalPred` (this module's `negLeftClause`).
* `ψ₁(z₁)` — the above piece `x_k < … < x_n` with the after-cap `β_{n+1}`; a one-free-variable
  `∃∀` (free var pinned to the LEFT endpoint `x_k`). Symmetric (`negRightClause`).
* `φ(z₀,z₁)` — the middle chain `x_m < … < x_k` with **no caps**; an **endpoint-pinned**
  two-free-variable `∃∀` (both pins at its own endpoints), so `EndpointPinnedCapTrivial` holds and
  the existing engine `prop42_veeSat_negation` negates it.

The `¬ψ₀`, `¬ψ₁` end pieces are `TL`-formula negations lifted to `TemporalPred` endpoint clauses;
the middle `¬φ` is the legacy `VVecEA2` negation. The three combine by `VVecEA2.disj`. There is no
conjunction closure and no order-preserving interleaving anywhere on this path — the split is of a
single chain at two *known* points (fixed order `below < x_m < middle < x_k < above`), the same
"glue along shared pins" technique as `ExistsForallLemmas.gluedChain`.

Off the live import path (imported by nothing live) until it is wired into the Prop 4.3 negation
case, mirroring how `Prop42ExistsForall.lean` and `Prop43.lean` already sit off-path.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.2 statement (p.6), proof and the
  three-way chain split + Lemma 5.1 (p.7). Cited by PDF page; the companion markdown
  transcription is corrupt.
- `Prop42ExistsForall.lean`: `EndpointPinnedCapTrivial`, `prop42_veeSat_negation` (middle piece).
- `Prop35Assembly.lean`: `translateProp35`, `translateProp35_correct` (end pieces).
- `ExistsForallLemmas.lean`: `gluedChain` family (backward gluing template).
- `VecEAFormula.lean`: `VVecEA2`, `VecEA2`, `BracketFormula.trivial`, `VVecEA2.disj`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

/-! ## 1. Residual: realizing the negation of a one-free-variable `∃∀` end piece

Rabinovich (PDF p.7): the two end pieces `ψ₀`, `ψ₁` are one-free-variable `∃∀`-objects, hence (by
Prop 3.5) equivalent to `TL(Until,Since)` formulas, "and hence their negations are equivalent to
atomic (and hence to `∃∀`) formulas". In this development a `VecEA2` endpoint carries an arbitrary
`TemporalPred` (a wrapped `Formula`, evaluated by `temporal_truth`), so the negated temporal
formula `¬(translateProp35 …)` is realized *directly* as an endpoint predicate — no separate atom
of the signature is needed. -/

/-- The `VVecEA2` clause witnessing `¬ efSat N ![z₀] ψ` for a one-free-variable `∃∀`-object `ψ`,
placing the negated Prop 3.5 formula at the **left** endpoint `z₀`. The right endpoint and the
(witness-free) bracket are trivially `⊤`, so the clause ignores `z₁`. -/
noncomputable def negLeftClause {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 1) : VVecEA2 :=
  { disjuncts :=
      [⟨0, { endpointLeft := ⟨Formula.neg (translateProp35 atomMap h_surj ψ)⟩
             endpointRight := TemporalPred.top
             bracket := BracketFormula.trivial TemporalPred.top }⟩] }

/-- Correctness of `negLeftClause`: it holds at `(z₀, z₁)` iff the one-free-variable object fails
at `z₀`. -/
theorem negLeftClause_holds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 1) (z0 z1 : N.carrier) :
    (negLeftClause atomMap h_surj ψ).holds N atomMap z0 z1 ↔ ¬ efSat N ![z0] ψ := by
  simp only [negLeftClause, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  have hcorr := translateProp35_correct N atomMap h_surj ![z0] ψ
  simp only [Matrix.cons_val_zero] at hcorr
  constructor
  · rintro ⟨hL, _, _⟩
    rw [TemporalPred.eval_at, temporal_truth_neg] at hL
    exact fun hsat => hL (hcorr.mp hsat)
  · intro hneg
    refine ⟨?_, TemporalPred.eval_at_top N atomMap z1, ?_⟩
    · rw [TemporalPred.eval_at, temporal_truth_neg]
      exact fun htt => hneg (hcorr.mpr htt)
    · rw [BracketFormula.trivial_holds]
      exact fun y _ _ => TemporalPred.eval_at_top N atomMap y

/-- The `VVecEA2` clause witnessing `¬ efSat N ![z₁] ψ` for a one-free-variable `∃∀`-object `ψ`,
placing the negated Prop 3.5 formula at the **right** endpoint `z₁`. The left endpoint and the
(witness-free) bracket are trivially `⊤`, so the clause ignores `z₀`. -/
noncomputable def negRightClause {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 1) : VVecEA2 :=
  { disjuncts :=
      [⟨0, { endpointLeft := TemporalPred.top
             endpointRight := ⟨Formula.neg (translateProp35 atomMap h_surj ψ)⟩
             bracket := BracketFormula.trivial TemporalPred.top }⟩] }

/-- Correctness of `negRightClause`: it holds at `(z₀, z₁)` iff the one-free-variable object fails
at `z₁`. -/
theorem negRightClause_holds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 1) (z0 z1 : N.carrier) :
    (negRightClause atomMap h_surj ψ).holds N atomMap z0 z1 ↔ ¬ efSat N ![z1] ψ := by
  simp only [negRightClause, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  have hcorr := translateProp35_correct N atomMap h_surj ![z1] ψ
  simp only [Matrix.cons_val_zero] at hcorr
  constructor
  · rintro ⟨_, hR, _⟩
    rw [TemporalPred.eval_at, temporal_truth_neg] at hR
    exact fun hsat => hR (hcorr.mp hsat)
  · intro hneg
    refine ⟨TemporalPred.eval_at_top N atomMap z0, ?_, ?_⟩
    · rw [TemporalPred.eval_at, temporal_truth_neg]
      exact fun htt => hneg (hcorr.mpr htt)
    · rw [BracketFormula.trivial_holds]
      exact fun y _ _ => TemporalPred.eval_at_top N atomMap y

end Bimodal.Metalogic.WeakCanonical.Kamp
