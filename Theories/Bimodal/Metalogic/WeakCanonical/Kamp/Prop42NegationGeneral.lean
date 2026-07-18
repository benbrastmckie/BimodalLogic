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
  two-free-variable `∃∀` (both pins at its own endpoints) realized as a bounded, cap-free
  `BracketFormula`/`VecEA2` (`middleBracket`). Its negation is realized directly by the Lemma 5.1
  engine `VVecEA2.negFix_iff` (INF/`K⁺` machinery, gated on Dedekind completeness), NOT via
  `efSat`/`EndpointPinnedCapTrivial`. This is the TL-level repair path: standalone `efSat` objects
  mandatorily carry two universal exterior caps that have no home in a general `N`, so the pieces
  are built at the TL-formula + bounded-`VecEA2` level, the encoding vehicle that faithfully
  expresses Rabinovich's cap-free / one-sided pieces.

The `¬ψ₀`, `¬ψ₁` end pieces are `TL`-formula negations lifted to `TemporalPred` endpoint clauses;
the middle `¬φ` is the `VVecEA2.negFix_iff` negation. The three combine by `VVecEA2.disj`. There is
no conjunction closure and no order-preserving interleaving anywhere on this path — the split is of a
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

/-! ## 2. TL-level piece constructors (below, above, cap-free middle)

Rabinovich's Section-5 three-piece chain split (PDF p.7): the general two-free-variable `∃∀`-object
`ψ(z₀,z₁)` with pins `z₀ = x_m`, `z₁ = x_k` (`m < k`) is equivalent to `ψ₀(z₀) ∧ φ(z₀,z₁) ∧ ψ₁(z₁)`.
Here we realize the three pieces at the TL-formula + bounded-`VecEA2` level (NOT as standalone `efSat`
objects, which mandatorily carry two universal exterior caps that have no home in a general `N`).

Faithfulness (per-piece PDF grounding):

* `belowFormula` = `α_m ∧ buildLeft(x_{m-1}..x₀, β₀)` is Rabinovich's `ψ₀(z₀)` (formula (1), PDF p.7):
  the below one-free-variable `∃∀` with the free variable at the RIGHT endpoint `x_m = z₀`, carrying
  the before-cap `β₀` **only** (no after-cap). By Prop 3.5 (PDF p.5) its translation is the pure
  **Since** chain terminating in `◫β₀ = H(β₀)` — exactly `buildLeft`'s `[]`-terminal. Constrains
  only `≤ z₀`.
* `aboveFormula` = `α_k ∧ buildRight(x_{k+1}..x_n, β_{n+1})` is Rabinovich's `ψ₁(z₁)` (formula (2),
  PDF p.7): the above one-free-variable `∃∀` with the free variable at the LEFT endpoint `x_k = z₁`,
  carrying the after-cap `β_{n+1}` **only** (no before-cap). By Prop 3.5 its translation is the pure
  **Until** chain terminating in `□β_{n+1} = G(β_{n+1})` — `buildRight`'s `[]`-terminal. Constrains
  only `≥ z₁`.
* `middleBracket` is Rabinovich's `φ(z₀,z₁)` (formula (3), PDF p.7 = Lemma 5.1's object, eq. 5.1):
  both pins at its own endpoints, endpoints `α_m`, `α_k`, interior point types `α_{m+1}..α_{k-1}` and
  interval types `β_{m+1}..β_k`, **cap-free by construction** (`BracketFormula`/`VecEA2` carry no
  exterior universal caps). Its negation is realized by `VVecEA2.negFix_iff` (the Lemma 5.1 engine),
  not via `efSat`/`EndpointPinnedCapTrivial`.

The reassembly `¬ψ = ¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` (PDF p.7, `¬(∧) = ∨(¬)`) is by `VVecEA2.disj`; no conjunction
closure and no order-preserving interleaving appears on this path.
-/

/-- Rabinovich's below piece `ψ₀(z₀) = α_m ∧ buildLeft(x_{m-1}..x₀, β₀)` (formula (1), PDF p.7),
realized as a raw one-sided (past-only) `TL(Since)` `Formula`. The free variable is pinned to the
RIGHT endpoint `x_m = z₀`; the chain runs left through `(α_{m-1}, β_m), …, (α_0, β_1)` and terminates
in the before-cap `β₀` (interval slot `0`) as `buildLeft`'s `H`-terminal. Constrains only `≤ z₀`. -/
noncomputable def belowFormula {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 2) : Formula :=
  Formula.and
    (efPointTP atomMap h_surj (ψ.pointType (ψ.pin 0))).formula
    (buildLeft
      ((List.finRange (ψ.pin 0).val).map (fun i =>
        (efPointTP atomMap h_surj (ψ.pointType ⟨(ψ.pin 0).val - 1 - i.val, by omega⟩),
         efIntervalTP atomMap h_surj (ψ.intervalType ⟨(ψ.pin 0).val - 1 - i.val + 1, by omega⟩))))
      (efIntervalTP atomMap h_surj (ψ.intervalType ⟨0, by omega⟩)))

/-- Rabinovich's above piece `ψ₁(z₁) = α_k ∧ buildRight(x_{k+1}..x_n, β_{n+1})` (formula (2), PDF
p.7), realized as a raw one-sided (future-only) `TL(Until)` `Formula`. The free variable is pinned to
the LEFT endpoint `x_k = z₁`; the chain runs right through `(α_{k+1}, β_{k+1}), …, (α_n, β_n)` and
terminates in the after-cap `β_{n+1}` (interval slot `n+1`) as `buildRight`'s `G`-terminal.
Constrains only `≥ z₁`. -/
noncomputable def aboveFormula {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 2) : Formula :=
  Formula.and
    (efPointTP atomMap h_surj (ψ.pointType (ψ.pin 1))).formula
    (buildRight
      ((List.finRange (ψ.n - (ψ.pin 1).val)).map (fun i =>
        (efPointTP atomMap h_surj (ψ.pointType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩),
         efIntervalTP atomMap h_surj (ψ.intervalType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩))))
      (efIntervalTP atomMap h_surj (ψ.intervalType ⟨ψ.n + 1, by omega⟩)))

/-- Rabinovich's cap-free middle `φ(z₀,z₁)` (formula (3), PDF p.7 = Lemma 5.1's object, eq. 5.1),
realized as a single-disjunct `VVecEA2`: endpoints `α_m` at `z₀` and `α_k` at `z₁`, interior point
types `α_{m+1}..α_{k-1}` and interval types `β_{m+1}..β_k`. Cap-free by construction — a
`BracketFormula` carries no exterior universal caps. -/
noncomputable def middleBracket {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 2) : VVecEA2 :=
  { disjuncts :=
      [⟨(ψ.pin 1).val - (ψ.pin 0).val - 1,
        { endpointLeft := efPointTP atomMap h_surj (ψ.pointType (ψ.pin 0))
          endpointRight := efPointTP atomMap h_surj (ψ.pointType (ψ.pin 1))
          bracket :=
            { pointTypes := fun i =>
                efPointTP atomMap h_surj (ψ.pointType ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩)
              segmentTypes := fun i =>
                efIntervalTP atomMap h_surj (ψ.intervalType ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩) } }⟩] }

/-! ## 3. Forward decomposition (Rabinovich Prop 4.2, `m < k` case, PDF p.7)

From `efSat N env ψ` (the single ordered witness chain `x₀ < … < xₙ`, pins `z₀ = x_m`, `z₁ = x_k`),
extract the three TL-level factors: the below one-sided `TL(Since)` formula holds at `z₀`, the
cap-free middle bracket holds on `(z₀, z₁)`, and the above one-sided `TL(Until)` formula holds at
`z₁`. This is the forward half of the TL-level restatement of Rabinovich's `ψ ≡ ψ₀ ∧ φ ∧ ψ₁`
(PDF p.7); the reindexing of the below/above pieces mirrors `translateProp35_correct`'s left/right
chain construction (`Prop35Assembly.lean`). -/

/-- Forward, below piece: from `efSat`, the below `TL(Since)` formula holds at `z₀ = env 0`. The
witness chain runs left `x_m, x_{m-1}, …, x_0` with the before-cap `β₀` as the `H`-terminal — exactly
Rabinovich's `ψ₀(z₀)` (formula (1), PDF p.7), no after-cap. Independent of `ψ.pin 1`. -/
theorem belowFormula_of_efSat {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2) (h : efSat N env ψ) :
    temporal_truth N atomMap (env 0) (belowFormula atomMap h_surj ψ) := by
  obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, _hafter⟩ := h
  simp only [belowFormula]
  set k : Fin (ψ.n + 1) := ψ.pin 0 with hk_def
  have hpin0 : env 0 = x k := hpin 0
  rw [temporal_truth_and]
  refine ⟨?_, ?_⟩
  · show (efPointTP atomMap h_surj (ψ.pointType k)).eval_at N atomMap (env 0)
    rw [efPointTP_eval, hpin0]
    exact hpt k
  · rw [buildLeft_correct]
    set alphaL : Nat → TemporalPred :=
      fun m => efPointTP atomMap h_surj (ψ.pointType ⟨k.val - 1 - m, by omega⟩) with halphaL_def
    set betaL : Nat → TemporalPred :=
      fun m => efIntervalTP atomMap h_surj (ψ.intervalType ⟨k.val - 1 - m + 1, by omega⟩)
      with hbetaL_def
    have hleft_eq :
        (List.finRange k.val).map (fun i =>
          (efPointTP atomMap h_surj (ψ.pointType ⟨k.val - 1 - i.val, by omega⟩),
           efIntervalTP atomMap h_surj (ψ.intervalType ⟨k.val - 1 - i.val + 1, by omega⟩))) =
        (List.finRange k.val).map (fun i => (alphaL i.val, betaL i.val)) := by
      apply List.map_congr_left; intro i _; simp only [halphaL_def, hbetaL_def]
    rw [hleft_eq, buildLeft_spec_iff_chain]
    refine ⟨fun m => x ⟨k.val - m, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
    · show x ⟨k.val - 0, by omega⟩ = env 0
      simp only [Nat.sub_zero]; exact hpin0.symm
    · intro i j hij hjd
      show x ⟨k.val - j, by omega⟩ < x ⟨k.val - i, by omega⟩
      exact hmono (show (⟨k.val - j, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val - i, by omega⟩ by
        simp only [Fin.lt_def]; omega)
    · intro i hi
      show TemporalPred.eval_at N atomMap (alphaL i) (x ⟨k.val - (i + 1), by omega⟩)
      simp only [halphaL_def]
      have e : k.val - (i + 1) = k.val - 1 - i := by omega
      simp only [e]; rw [efPointTP_eval]; exact hpt ⟨k.val - 1 - i, by omega⟩
    · intro i hi y hy1 hy2
      show TemporalPred.eval_at N atomMap (betaL i) y
      simp only [hbetaL_def]; rw [efIntervalTP_eval]
      have e : k.val - (i + 1) = k.val - 1 - i := by omega
      have e' : k.val - 1 - i + 1 = k.val - i := by omega
      have hy1' : x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).castSucc < y := by
        show x ⟨k.val - 1 - i, by omega⟩ < y
        rw [show (⟨k.val - 1 - i, by omega⟩ : Fin (ψ.n + 1)) = ⟨k.val - (i + 1), by omega⟩ from by
          simp only [e]]
        exact hy1
      have hy2' : y < x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).succ := by
        show y < x ⟨k.val - 1 - i + 1, by omega⟩
        rw [show (⟨k.val - 1 - i + 1, by omega⟩ : Fin (ψ.n + 1)) = ⟨k.val - i, by omega⟩ from by
          simp only [e']]
        exact hy2
      exact hbetween ⟨k.val - 1 - i, by omega⟩ y hy1' hy2'
    · intro y hy
      show TemporalPred.eval_at N atomMap
        (efIntervalTP atomMap h_surj (ψ.intervalType ⟨0, by omega⟩)) y
      rw [efIntervalTP_eval]
      have h0 : k.val - k.val = 0 := by omega
      have hy' : y < x (⟨0, by omega⟩ : Fin (ψ.n + 1)) := by
        rw [show (⟨0, by omega⟩ : Fin (ψ.n + 1)) = ⟨k.val - k.val, by omega⟩ from by
          simp only [h0]]
        exact hy
      exact hbefore y hy'

/-- Forward, above piece: from `efSat`, the above `TL(Until)` formula holds at `z₁ = env 1`. The
witness chain runs right `x_k, x_{k+1}, …, x_n` with the after-cap `β_{n+1}` as the `G`-terminal —
exactly Rabinovich's `ψ₁(z₁)` (formula (2), PDF p.7), no before-cap. Independent of `ψ.pin 0`. -/
theorem aboveFormula_of_efSat {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2) (h : efSat N env ψ) :
    temporal_truth N atomMap (env 1) (aboveFormula atomMap h_surj ψ) := by
  obtain ⟨x, hmono, hpin, hpt, _hbefore, hbetween, hafter⟩ := h
  simp only [aboveFormula]
  set k : Fin (ψ.n + 1) := ψ.pin 1 with hk_def
  have hpin1 : env 1 = x k := hpin 1
  rw [temporal_truth_and]
  refine ⟨?_, ?_⟩
  · show (efPointTP atomMap h_surj (ψ.pointType k)).eval_at N atomMap (env 1)
    rw [efPointTP_eval, hpin1]
    exact hpt k
  · rw [buildRight_correct]
    set alphaR : Nat → TemporalPred :=
      fun m => efPointTP atomMap h_surj (ψ.pointType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
      with halphaR_def
    set betaR : Nat → TemporalPred :=
      fun m => efIntervalTP atomMap h_surj (ψ.intervalType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
      with hbetaR_def
    have hright_eq :
        (List.finRange (ψ.n - k.val)).map (fun i =>
          (efPointTP atomMap h_surj (ψ.pointType ⟨k.val + 1 + i.val, by omega⟩),
           efIntervalTP atomMap h_surj (ψ.intervalType ⟨k.val + 1 + i.val, by omega⟩))) =
        (List.finRange (ψ.n - k.val)).map (fun i => (alphaR i.val, betaR i.val)) := by
      apply List.map_congr_left; intro i _
      simp only [halphaR_def, hbetaR_def]
      have e : min (k.val + 1 + i.val) ψ.n = k.val + 1 + i.val := by omega
      simp only [e]
    rw [hright_eq, buildRight_spec_iff_chain]
    refine ⟨fun m => x ⟨min (k.val + m) ψ.n, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
    · show x ⟨min (k.val + 0) ψ.n, by omega⟩ = env 1
      have e0 : min (k.val + 0) ψ.n = k.val := by omega
      simp only [e0]; exact hpin1.symm
    · intro i j hij hjd
      show x ⟨min (k.val + i) ψ.n, by omega⟩ < x ⟨min (k.val + j) ψ.n, by omega⟩
      have ei : min (k.val + i) ψ.n = k.val + i := by omega
      have ej : min (k.val + j) ψ.n = k.val + j := by omega
      simp only [ei, ej]
      exact hmono (show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val + j, by omega⟩ by
        simp only [Fin.lt_def]; omega)
    · intro i hi
      show TemporalPred.eval_at N atomMap (alphaR i) (x ⟨min (k.val + (i + 1)) ψ.n, by omega⟩)
      simp only [halphaR_def]
      have e1 : min (k.val + (i + 1)) ψ.n = k.val + 1 + i := by omega
      have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
      simp only [e1, e2]; rw [efPointTP_eval]; exact hpt ⟨k.val + 1 + i, by omega⟩
    · intro i hi y hy1 hy2
      show TemporalPred.eval_at N atomMap (betaR i) y
      simp only [hbetaR_def]
      have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
      simp only [e2]; rw [efIntervalTP_eval]
      have eidx : k.val + 1 + i = k.val + i + 1 := by omega
      simp only [eidx]
      have ei : min (k.val + i) ψ.n = k.val + i := by omega
      have ei1 : min (k.val + (i + 1)) ψ.n = k.val + i + 1 := by omega
      have hy1' : x (⟨k.val + i, by omega⟩ : Fin ψ.n).castSucc < y := by
        show x ⟨k.val + i, by omega⟩ < y
        rw [show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) = ⟨min (k.val + i) ψ.n, by omega⟩ from by
          simp only [ei]]
        exact hy1
      have hy2' : y < x (⟨k.val + i, by omega⟩ : Fin ψ.n).succ := by
        show y < x ⟨k.val + i + 1, by omega⟩
        rw [show (⟨k.val + i + 1, by omega⟩ : Fin (ψ.n + 1)) = ⟨min (k.val + (i + 1)) ψ.n, by omega⟩
          from by simp only [ei1]]
        exact hy2
      exact hbetween ⟨k.val + i, by omega⟩ y hy1' hy2'
    · intro y hy
      show TemporalPred.eval_at N atomMap
        (efIntervalTP atomMap h_surj (ψ.intervalType ⟨ψ.n + 1, by omega⟩)) y
      rw [efIntervalTP_eval]
      have ed : min (k.val + (ψ.n - k.val)) ψ.n = ψ.n := by omega
      have hy' : x (Fin.last ψ.n) < y := by
        rw [show (Fin.last ψ.n) = (⟨min (k.val + (ψ.n - k.val)) ψ.n, by omega⟩ : Fin (ψ.n + 1)) from by
          apply Fin.ext; simp only [ed, Fin.val_last]]
        exact hy
      exact hafter y hy'

end Bimodal.Metalogic.WeakCanonical.Kamp
