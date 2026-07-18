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

/-- Forward, middle piece: from `efSat` with `m < k`, the cap-free middle bracket holds on
`(z₀, z₁) = (env 0, env 1)`. The interior witnesses are `x_{m+1}, …, x_{k-1}` and the segment types
`β_{m+1}, …, β_k` come from `efSat`'s interior-interval conjunct — exactly Rabinovich's `φ(z₀,z₁)`
(formula (3), PDF p.7 = Lemma 5.1's object). Case-split on whether there are interior points. -/
theorem middleBracket_of_efSat {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val) (h : efSat N env ψ) :
    (middleBracket atomMap h_surj ψ).holds N atomMap (env 0) (env 1) := by
  obtain ⟨x, hmono, hpin, hpt, _hbefore, hbetween, _hafter⟩ := h
  have hpin0 : env 0 = x (ψ.pin 0) := hpin 0
  have hpin1 : env 1 = x (ψ.pin 1) := hpin 1
  -- `env 0 = x ⟨m⟩`, `env 1 = x ⟨k⟩` in explicit-index form.
  have he0 : env 0 = x ⟨(ψ.pin 0).val, (ψ.pin 0).isLt⟩ := by rw [hpin0]
  have he1 : env 1 = x ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ := by rw [hpin1]
  simp only [middleBracket, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  refine ⟨?_, ?_, ?_⟩
  · show (efPointTP atomMap h_surj (ψ.pointType (ψ.pin 0))).eval_at N atomMap (env 0)
    rw [efPointTP_eval, hpin0]; exact hpt (ψ.pin 0)
  · show (efPointTP atomMap h_surj (ψ.pointType (ψ.pin 1))).eval_at N atomMap (env 1)
    rw [efPointTP_eval, hpin1]; exact hpt (ψ.pin 1)
  · simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
    by_cases hp0 : (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0
    · -- No interior points: k = m + 1. The single segment `β_{m+1}` on (x_m, x_{m+1}).
      rw [IntervalPattern.holds_eq_zero N atomMap _ _ (env 0) (env 1) hp0]
      intro y hy1 hy2
      show TemporalPred.eval_at N atomMap
        (efIntervalTP atomMap h_surj
          (ψ.intervalType ⟨(ψ.pin 0).val + 1 + (0 : Fin 1).val, by omega⟩)) y
      rw [efIntervalTP_eval]
      have hmn : (ψ.pin 0).val < ψ.n := by omega
      have hy1' : x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).castSucc < y := by
        show x ⟨(ψ.pin 0).val, by omega⟩ < y; rw [← he0]; exact hy1
      have hy2' : y < x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ := by
        show y < x ⟨(ψ.pin 0).val + 1, by omega⟩
        rw [show (⟨(ψ.pin 0).val + 1, by omega⟩ : Fin (ψ.n + 1)) =
            ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ from by apply Fin.ext; simp only; omega, ← he1]
        exact hy2
      have hb := hbetween ⟨(ψ.pin 0).val, hmn⟩ y hy1' hy2'
      rw [show ((⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ.castSucc) =
          (⟨(ψ.pin 0).val + 1 + (0 : Fin 1).val, by omega⟩ : Fin (ψ.n + 2)) from by
        apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]; omega] at hb
      exact hb
    · -- Interior points x_{m+1}, …, x_{k-1}.
      have hk' : (ψ.pin 1).val - (ψ.pin 0).val - 1 = ((ψ.pin 1).val - (ψ.pin 0).val - 2) + 1 := by
        omega
      rw [IntervalPattern.holds_eq_succ N atomMap _ _ (env 0) (env 1) hk']
      refine ⟨fun i => x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro i j hij
        show x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ < x ⟨(ψ.pin 0).val + 1 + j.val, by omega⟩
        exact hmono (show (⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ : Fin (ψ.n + 1)) <
          ⟨(ψ.pin 0).val + 1 + j.val, by omega⟩ by simp only [Fin.lt_def]; simp only [Fin.lt_def] at hij; omega)
      · intro i
        refine ⟨?_, ?_⟩
        · show env 0 < x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩
          rw [he0]
          exact hmono (show (⟨(ψ.pin 0).val, (ψ.pin 0).isLt⟩ : Fin (ψ.n + 1)) <
            ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ by simp only [Fin.lt_def]; omega)
        · show x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ < env 1
          rw [he1]
          exact hmono (show (⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ : Fin (ψ.n + 1)) <
            ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ by simp only [Fin.lt_def]; omega)
      · intro i
        show TemporalPred.eval_at N atomMap
          (efPointTP atomMap h_surj (ψ.pointType ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩))
          (x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩)
        rw [efPointTP_eval]; exact hpt ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩
      · intro y hy1 hy2
        show TemporalPred.eval_at N atomMap
          (efIntervalTP atomMap h_surj
            (ψ.intervalType ⟨(ψ.pin 0).val + 1 + 0, by omega⟩)) y
        rw [efIntervalTP_eval]
        have hmn : (ψ.pin 0).val < ψ.n := by omega
        have hy1' : x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).castSucc < y := by
          show x ⟨(ψ.pin 0).val, by omega⟩ < y; rw [← he0]; exact hy1
        have hy2' : y < x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ := by
          show y < x ⟨(ψ.pin 0).val + 1, by omega⟩
          simpa using hy2
        have hb := hbetween ⟨(ψ.pin 0).val, hmn⟩ y hy1' hy2'
        rw [show ((⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ.castSucc) =
            (⟨(ψ.pin 0).val + 1 + 0, by omega⟩ : Fin (ψ.n + 2)) from by
          apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]] at hb
        exact hb
      · intro i y hy1 hy2
        show TemporalPred.eval_at N atomMap
          (efIntervalTP atomMap h_surj
            (ψ.intervalType ⟨(ψ.pin 0).val + 1 + (i.val + 1), by omega⟩)) y
        rw [efIntervalTP_eval]
        have hmn : (ψ.pin 0).val + 1 + i.val < ψ.n := by omega
        have hy1' : x (⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ : Fin ψ.n).castSucc < y := by
          show x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ < y; simpa using hy1
        have hy2' : y < x (⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ : Fin ψ.n).succ := by
          show y < x ⟨(ψ.pin 0).val + 1 + i.val + 1, by omega⟩; simpa using hy2
        have hb := hbetween ⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ y hy1' hy2'
        rw [show ((⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ : Fin ψ.n).succ.castSucc) =
            (⟨(ψ.pin 0).val + 1 + (i.val + 1), by omega⟩ : Fin (ψ.n + 2)) from by
          apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]; omega] at hb
        exact hb
      · intro y hy1 hy2
        show TemporalPred.eval_at N atomMap
          (efIntervalTP atomMap h_surj
            (ψ.intervalType ⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2 + 1), by omega⟩)) y
        rw [efIntervalTP_eval]
        have hkm1 : (ψ.pin 1).val - 1 < ψ.n := by omega
        have hidxeq : (ψ.pin 1).val - 1 + 1 = (ψ.pin 1).val := by omega
        have hy1' : x (⟨(ψ.pin 1).val - 1, hkm1⟩ : Fin ψ.n).castSucc < y := by
          show x ⟨(ψ.pin 1).val - 1, by omega⟩ < y
          rw [show (⟨(ψ.pin 1).val - 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2), by omega⟩ from by
            apply Fin.ext; simp only; omega]
          exact hy1
        have hy2' : y < x (⟨(ψ.pin 1).val - 1, hkm1⟩ : Fin ψ.n).succ := by
          show y < x ⟨(ψ.pin 1).val - 1 + 1, by omega⟩
          rw [show (⟨(ψ.pin 1).val - 1 + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ from by apply Fin.ext; simp only; omega, ← he1]
          exact hy2
        have hb := hbetween ⟨(ψ.pin 1).val - 1, hkm1⟩ y hy1' hy2'
        rw [show ((⟨(ψ.pin 1).val - 1, hkm1⟩ : Fin ψ.n).succ.castSucc) =
            (⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2 + 1), by omega⟩ : Fin (ψ.n + 2))
            from by apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]; omega] at hb
        exact hb

/-- Forward decomposition (`m < k`): from `efSat` derive all three TL-level factors. -/
theorem efSat_decompose_tl_forward {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val) (h : efSat N env ψ) :
    temporal_truth N atomMap (env 0) (belowFormula atomMap h_surj ψ) ∧
    (middleBracket atomMap h_surj ψ).holds N atomMap (env 0) (env 1) ∧
    temporal_truth N atomMap (env 1) (aboveFormula atomMap h_surj ψ) :=
  ⟨belowFormula_of_efSat N atomMap h_surj env ψ h,
   middleBracket_of_efSat N atomMap h_surj env ψ hlt h,
   aboveFormula_of_efSat N atomMap h_surj env ψ h⟩

/-! ## 4. Backward decomposition (Rabinovich Prop 4.2, `m < k` case, PDF p.7)

The gluing direction: from the below one-sided `TL(Since)` chain at `z₀`, the cap-free middle
bracket on `(z₀, z₁)`, and the above one-sided `TL(Until)` chain at `z₁`, reassemble the single
ordered `efSat` witness chain by concatenating the three pieces at the shared pinned endpoints
`x_m = z₀`, `x_k = z₁` in fixed order (`below < x_m < middle < x_k < above`, no interleaving) — the
three-piece analogue of `translateProp35_correct`'s two-way glue. Rabinovich's split is stated for
`z₀ < z₁`; the `env 0 < env 1` hypothesis carries that ordering (the degenerate `z₀ = z₁` is
Rabinovich's separate `k = m` branch). -/

/-- Backward decomposition (`m < k`, `z₀ < z₁`): glue the three TL-level factors into one `efSat`
witness. -/
theorem efSat_of_decompose_tl {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val) (henv : env 0 < env 1)
    (hb : temporal_truth N atomMap (env 0) (belowFormula atomMap h_surj ψ))
    (hm : (middleBracket atomMap h_surj ψ).holds N atomMap (env 0) (env 1))
    (ha : temporal_truth N atomMap (env 1) (aboveFormula atomMap h_surj ψ)) :
    efSat N env ψ := by
  have hkn : (ψ.pin 1).val ≤ ψ.n := by have := (ψ.pin 1).isLt; omega
  -- Below chain xb (antitone, pinned at env 0 = x_m).
  simp only [belowFormula] at hb
  rw [temporal_truth_and] at hb
  obtain ⟨hb_pt, hb_chain⟩ := hb
  rw [buildLeft_correct] at hb_chain
  set alphaL : Nat → TemporalPred :=
    fun i => efPointTP atomMap h_surj (ψ.pointType ⟨(ψ.pin 0).val - 1 - i, by omega⟩)
    with halphaL_def
  set betaL : Nat → TemporalPred :=
    fun i => efIntervalTP atomMap h_surj (ψ.intervalType ⟨(ψ.pin 0).val - 1 - i + 1, by omega⟩)
    with hbetaL_def
  have hleft_eq :
      (List.finRange (ψ.pin 0).val).map (fun i =>
        (efPointTP atomMap h_surj (ψ.pointType ⟨(ψ.pin 0).val - 1 - i.val, by omega⟩),
         efIntervalTP atomMap h_surj (ψ.intervalType ⟨(ψ.pin 0).val - 1 - i.val + 1, by omega⟩))) =
      (List.finRange (ψ.pin 0).val).map (fun i => (alphaL i.val, betaL i.val)) := by
    apply List.map_congr_left; intro i _; simp only [halphaL_def, hbetaL_def]
  rw [hleft_eq, buildLeft_spec_iff_chain] at hb_chain
  obtain ⟨xb, hxb0, hxb_anti, hxb_alpha, hxb_beta, hxb_cap⟩ := hb_chain
  -- Above chain xa (monotone, pinned at env 1 = x_k).
  simp only [aboveFormula] at ha
  rw [temporal_truth_and] at ha
  obtain ⟨ha_pt, ha_chain⟩ := ha
  rw [buildRight_correct] at ha_chain
  set alphaR : Nat → TemporalPred :=
    fun i => efPointTP atomMap h_surj (ψ.pointType ⟨min ((ψ.pin 1).val + 1 + i) ψ.n, by omega⟩)
    with halphaR_def
  set betaR : Nat → TemporalPred :=
    fun i => efIntervalTP atomMap h_surj (ψ.intervalType ⟨min ((ψ.pin 1).val + 1 + i) ψ.n, by omega⟩)
    with hbetaR_def
  have hright_eq :
      (List.finRange (ψ.n - (ψ.pin 1).val)).map (fun i =>
        (efPointTP atomMap h_surj (ψ.pointType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩),
         efIntervalTP atomMap h_surj (ψ.intervalType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩))) =
      (List.finRange (ψ.n - (ψ.pin 1).val)).map (fun i => (alphaR i.val, betaR i.val)) := by
    apply List.map_congr_left; intro i _
    simp only [halphaR_def, hbetaR_def]
    have e : min ((ψ.pin 1).val + 1 + i.val) ψ.n = (ψ.pin 1).val + 1 + i.val := by omega
    simp only [e]
  rw [hright_eq, buildRight_spec_iff_chain] at ha_chain
  obtain ⟨xa, hxa0, hxa_mono, hxa_alpha, hxa_beta, hxa_cap⟩ := ha_chain
  -- Middle interior witnesses wN (from the cap-free bracket), packaged uniformly over the interior
  -- count `c`; the two boundary segments use the `if c = 0` collapse.
  simp only [middleBracket, VVecEA2.holds, List.mem_singleton, exists_eq_left] at hm
  rw [VecEA2.holds] at hm
  obtain ⟨_hm_left, _hm_right, hm_br⟩ := hm
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at hm_br
  obtain ⟨wN, hwN_mono, hwN_bound, hwN_pt, hwN_first, hwN_mid, hwN_last⟩ :
      ∃ wN : Nat → N.carrier,
        (∀ i j, i < j → j < (ψ.pin 1).val - (ψ.pin 0).val - 1 → wN i < wN j) ∧
        (∀ i, i < (ψ.pin 1).val - (ψ.pin 0).val - 1 → env 0 < wN i ∧ wN i < env 1) ∧
        (∀ i, i < (ψ.pin 1).val - (ψ.pin 0).val - 1 →
          (efPointTP atomMap h_surj
            (ψ.pointType ⟨min ((ψ.pin 0).val + 1 + i) ψ.n, by omega⟩)).eval_at N atomMap (wN i)) ∧
        (∀ y, env 0 < y →
          y < (if (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0 then env 1 else wN 0) →
          (efIntervalTP atomMap h_surj
            (ψ.intervalType ⟨(ψ.pin 0).val + 1, by omega⟩)).eval_at N atomMap y) ∧
        (∀ ii, ii + 1 < (ψ.pin 1).val - (ψ.pin 0).val - 1 → ∀ y, wN ii < y → y < wN (ii + 1) →
          (efIntervalTP atomMap h_surj
            (ψ.intervalType ⟨min ((ψ.pin 0).val + 2 + ii) (ψ.n + 1), by omega⟩)).eval_at N atomMap y) ∧
        (∀ y, (if (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0 then env 0
                else wN ((ψ.pin 1).val - (ψ.pin 0).val - 1 - 1)) < y → y < env 1 →
          (efIntervalTP atomMap h_surj
            (ψ.intervalType ⟨(ψ.pin 1).val, by omega⟩)).eval_at N atomMap y) := by
    by_cases hp0 : (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0
    · rw [IntervalPattern.holds_eq_zero N atomMap _ _ (env 0) (env 1) hp0] at hm_br
      refine ⟨fun _ => env 1, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro i j hij hjc; omega
      · intro i hi; omega
      · intro i hi; omega
      · intro y hy1 hy2
        rw [if_pos hp0] at hy2
        exact hm_br y hy1 hy2
      · intro ii hii; omega
      · intro y hy1 hy2
        rw [if_pos hp0] at hy1
        have hz := hm_br y hy1 hy2
        rw [efIntervalTP_eval] at hz ⊢
        rw [show (⟨(ψ.pin 1).val, by omega⟩ : Fin (ψ.n + 2)) =
            ⟨(ψ.pin 0).val + 1 + (0 : Fin 1).val, by omega⟩ from Fin.ext (by simp; omega)]
        exact hz
    · have hc' : (ψ.pin 1).val - (ψ.pin 0).val - 1 =
          ((ψ.pin 1).val - (ψ.pin 0).val - 2) + 1 := by omega
      rw [IntervalPattern.holds_eq_succ N atomMap _ _ (env 0) (env 1) hc'] at hm_br
      obtain ⟨wit, hwit_mono, hwit_bound, hwit_alpha, hwit_first, hwit_mid, hwit_last⟩ := hm_br
      refine ⟨fun i => wit ⟨min i ((ψ.pin 1).val - (ψ.pin 0).val - 2), by omega⟩,
        ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro i j hij hjc
        have ei : min i ((ψ.pin 1).val - (ψ.pin 0).val - 2) = i := by omega
        have ej : min j ((ψ.pin 1).val - (ψ.pin 0).val - 2) = j := by omega
        simp only [ei, ej]
        exact hwit_mono ⟨i, by omega⟩ ⟨j, by omega⟩ (Fin.mk_lt_mk.mpr hij)
      · intro i hi
        have ei : min i ((ψ.pin 1).val - (ψ.pin 0).val - 2) = i := by omega
        simp only [ei]
        exact hwit_bound ⟨i, by omega⟩
      · intro i hi
        have ei : min i ((ψ.pin 1).val - (ψ.pin 0).val - 2) = i := by omega
        have emin : min ((ψ.pin 0).val + 1 + i) ψ.n = (ψ.pin 0).val + 1 + i := by omega
        simp only [ei, emin]
        exact hwit_alpha ⟨i, by omega⟩
      · intro y hy1 hy2
        rw [if_neg hp0] at hy2
        have e0 : min 0 ((ψ.pin 1).val - (ψ.pin 0).val - 2) = 0 := by omega
        simp only [e0] at hy2
        exact hwit_first y hy1 hy2
      · intro ii hii y hy1 hy2
        have eii : min ii ((ψ.pin 1).val - (ψ.pin 0).val - 2) = ii := by omega
        have eii1 : min (ii + 1) ((ψ.pin 1).val - (ψ.pin 0).val - 2) = ii + 1 := by omega
        simp only [eii] at hy1
        simp only [eii1] at hy2
        have hmid := hwit_mid ⟨ii, by omega⟩ y hy1 hy2
        have emin : min ((ψ.pin 0).val + 2 + ii) (ψ.n + 1) = (ψ.pin 0).val + 2 + ii := by omega
        simp only [emin]
        rw [efIntervalTP_eval] at hmid ⊢
        rw [show (⟨(ψ.pin 0).val + 2 + ii, by omega⟩ : Fin (ψ.n + 2)) =
            ⟨(ψ.pin 0).val + 1 + (ii + 1), by omega⟩ from Fin.ext (by simp; omega)]
        exact hmid
      · intro y hy1 hy2
        rw [if_neg hp0] at hy1
        have ecm : min ((ψ.pin 1).val - (ψ.pin 0).val - 1 - 1)
            ((ψ.pin 1).val - (ψ.pin 0).val - 2) = (ψ.pin 1).val - (ψ.pin 0).val - 2 := by omega
        simp only [ecm] at hy1
        have hl := hwit_last y hy1 hy2
        rw [efIntervalTP_eval] at hl ⊢
        rw [show (⟨(ψ.pin 1).val, by omega⟩ : Fin (ψ.n + 2)) =
            ⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2 + 1), by omega⟩
            from Fin.ext (by simp; omega)]
        exact hl
  -- The glued chain.
  set x : Fin (ψ.n + 1) → N.carrier :=
    fun j => if j.val ≤ (ψ.pin 0).val then xb ((ψ.pin 0).val - j.val)
             else if j.val < (ψ.pin 1).val then wN (j.val - (ψ.pin 0).val - 1)
             else xa (j.val - (ψ.pin 1).val) with hx_def
  have hx_below : ∀ j : Fin (ψ.n + 1), j.val ≤ (ψ.pin 0).val →
      x j = xb ((ψ.pin 0).val - j.val) := by
    intro j hj; simp only [hx_def, if_pos hj]
  have hx_mid : ∀ j : Fin (ψ.n + 1), (ψ.pin 0).val < j.val → j.val < (ψ.pin 1).val →
      x j = wN (j.val - (ψ.pin 0).val - 1) := by
    intro j hj1 hj2
    simp only [hx_def, if_neg (by omega : ¬ j.val ≤ (ψ.pin 0).val), if_pos hj2]
  have hx_above : ∀ j : Fin (ψ.n + 1), (ψ.pin 1).val ≤ j.val →
      x j = xa (j.val - (ψ.pin 1).val) := by
    intro j hj
    simp only [hx_def, if_neg (by omega : ¬ j.val ≤ (ψ.pin 0).val),
      if_neg (by omega : ¬ j.val < (ψ.pin 1).val)]
  have hxm : x (ψ.pin 0) = env 0 := by
    rw [hx_below (ψ.pin 0) (le_refl _), Nat.sub_self, hxb0]
  have hxk : x (ψ.pin 1) = env 1 := by
    rw [hx_above (ψ.pin 1) (le_refl _), Nat.sub_self, hxa0]
  -- Region anchor inequalities.
  have below_le : ∀ a : Fin (ψ.n + 1), a.val ≤ (ψ.pin 0).val → x a ≤ env 0 := by
    intro a ha
    rw [hx_below a ha]
    by_cases h : a.val = (ψ.pin 0).val
    · rw [show (ψ.pin 0).val - a.val = 0 from by omega, hxb0]
    · have := hxb_anti 0 ((ψ.pin 0).val - a.val) (by omega) (by omega)
      rw [hxb0] at this; exact le_of_lt this
  have above_ge : ∀ b : Fin (ψ.n + 1), (ψ.pin 1).val ≤ b.val → env 1 ≤ x b := by
    intro b hb
    rw [hx_above b hb]
    by_cases h : b.val = (ψ.pin 1).val
    · rw [show b.val - (ψ.pin 1).val = 0 from by omega, hxa0]
    · have := hxa_mono 0 (b.val - (ψ.pin 1).val) (by omega) (by omega)
      rw [hxa0] at this; exact le_of_lt this
  have hmid_lo : ∀ a : Fin (ψ.n + 1), (ψ.pin 0).val < a.val → a.val < (ψ.pin 1).val →
      env 0 < x a := by
    intro a h1 h2
    rw [hx_mid a h1 h2]
    exact (hwN_bound (a.val - (ψ.pin 0).val - 1) (by omega)).1
  have hmid_hi : ∀ a : Fin (ψ.n + 1), (ψ.pin 0).val < a.val → a.val < (ψ.pin 1).val →
      x a < env 1 := by
    intro a h1 h2
    rw [hx_mid a h1 h2]
    exact (hwN_bound (a.val - (ψ.pin 0).val - 1) (by omega)).2
  refine ⟨x, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- StrictMono x
    intro a b hab
    rw [Fin.lt_def] at hab
    rcases le_or_gt (ψ.pin 1).val b.val with hbk | hbk
    · rcases le_or_gt a.val (ψ.pin 0).val with ham | ham
      · exact lt_of_le_of_lt (below_le a ham) (lt_of_lt_of_le henv (above_ge b hbk))
      · rcases lt_or_ge a.val (ψ.pin 1).val with hak | hak
        · exact lt_of_lt_of_le (hmid_hi a ham hak) (above_ge b hbk)
        · rw [hx_above a hak, hx_above b hbk]
          exact hxa_mono (a.val - (ψ.pin 1).val) (b.val - (ψ.pin 1).val) (by omega) (by omega)
    · rcases le_or_gt b.val (ψ.pin 0).val with hbm | hbm
      · rw [hx_below a (by omega), hx_below b hbm]
        exact hxb_anti ((ψ.pin 0).val - b.val) ((ψ.pin 0).val - a.val) (by omega) (by omega)
      · rcases le_or_gt a.val (ψ.pin 0).val with ham | ham
        · exact lt_of_le_of_lt (below_le a ham) (hmid_lo b hbm hbk)
        · rw [hx_mid a ham (by omega), hx_mid b hbm hbk]
          exact hwN_mono (a.val - (ψ.pin 0).val - 1) (b.val - (ψ.pin 0).val - 1)
            (by omega) (by omega)
  · -- pin condition
    rw [Fin.forall_fin_two]
    exact ⟨hxm.symm, hxk.symm⟩
  · -- pointType
    intro j
    rcases le_or_gt j.val (ψ.pin 0).val with hjm | hjm
    · by_cases hjeq : j.val = (ψ.pin 0).val
      · have hjp : j = ψ.pin 0 := Fin.ext hjeq
        rw [hjp, hxm]
        exact (efPointTP_eval N atomMap h_surj (ψ.pointType (ψ.pin 0)) (env 0)).mp hb_pt
      · rw [hx_below j hjm]
        have halph := hxb_alpha ((ψ.pin 0).val - j.val - 1) (by omega)
        simp only [halphaL_def] at halph
        have e1 : (ψ.pin 0).val - 1 - ((ψ.pin 0).val - j.val - 1) = j.val := by omega
        have e2 : (ψ.pin 0).val - j.val - 1 + 1 = (ψ.pin 0).val - j.val := by omega
        simp only [e1, e2] at halph
        rw [efPointTP_eval] at halph
        exact halph
    · rcases le_or_gt (ψ.pin 1).val j.val with hjk | hjk
      · by_cases hjeq : j.val = (ψ.pin 1).val
        · have hjp : j = ψ.pin 1 := Fin.ext hjeq
          rw [hjp, hxk]
          exact (efPointTP_eval N atomMap h_surj (ψ.pointType (ψ.pin 1)) (env 1)).mp ha_pt
        · rw [hx_above j hjk]
          have halph := hxa_alpha (j.val - (ψ.pin 1).val - 1) (by omega)
          simp only [halphaR_def] at halph
          have e1 : min ((ψ.pin 1).val + 1 + (j.val - (ψ.pin 1).val - 1)) ψ.n = j.val := by omega
          have e2 : j.val - (ψ.pin 1).val - 1 + 1 = j.val - (ψ.pin 1).val := by omega
          simp only [e1, e2] at halph
          rw [efPointTP_eval] at halph
          exact halph
      · rw [hx_mid j hjm hjk]
        have hpt := hwN_pt (j.val - (ψ.pin 0).val - 1) (by omega)
        have emin : min ((ψ.pin 0).val + 1 + (j.val - (ψ.pin 0).val - 1)) ψ.n = j.val := by omega
        simp only [emin] at hpt
        rw [efPointTP_eval] at hpt
        exact hpt
  · -- before-cap
    intro y hy
    have hval0 : (0 : Fin (ψ.n + 1)).val = 0 := rfl
    rw [hx_below 0 (by rw [hval0]; omega), hval0, Nat.sub_zero] at hy
    have hbef := hxb_cap y hy
    rw [efIntervalTP_eval] at hbef
    exact hbef
  · -- between
    intro i y hy1 hy2
    have hcs : (Fin.castSucc i).val = i.val := Fin.val_castSucc i
    have hsc : (Fin.succ i).val = i.val + 1 := Fin.val_succ i
    rcases lt_trichotomy i.val (ψ.pin 0).val with hreg | hreg | hreg
    · -- both below
      rw [hx_below i.castSucc (by rw [hcs]; omega), hcs] at hy1
      rw [hx_below i.succ (by rw [hsc]; omega), hsc] at hy2
      have e1 : (ψ.pin 0).val - i.val - 1 + 1 = (ψ.pin 0).val - i.val := by omega
      have e2 : (ψ.pin 0).val - (i.val + 1) = (ψ.pin 0).val - i.val - 1 := by omega
      have hbeta := hxb_beta ((ψ.pin 0).val - i.val - 1) (by omega) y
        (by rw [e1]; exact hy1) (by rw [e2] at hy2; exact hy2)
      simp only [hbetaL_def] at hbeta
      have e3 : (ψ.pin 0).val - 1 - ((ψ.pin 0).val - i.val - 1) + 1 = i.val + 1 := by omega
      simp only [e3] at hbeta
      rw [efIntervalTP_eval] at hbeta
      rw [show i.succ.castSucc = (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) from
        Fin.ext (by rw [Fin.val_castSucc, Fin.val_succ])]
      exact hbeta
    · -- boundary below/middle at i.val = m
      have hcast_pin : i.castSucc = ψ.pin 0 := Fin.ext (by rw [hcs]; omega)
      rw [hcast_pin, hxm] at hy1
      rw [show i.succ.castSucc = (⟨(ψ.pin 0).val + 1, by omega⟩ : Fin (ψ.n + 2)) from
        Fin.ext (by simp; omega)]
      by_cases hp0 : (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0
      · have hsucc_pin : i.succ = ψ.pin 1 := Fin.ext (by rw [hsc]; omega)
        rw [hsucc_pin, hxk] at hy2
        have := hwN_first y hy1 (by rw [if_pos hp0]; exact hy2)
        rw [efIntervalTP_eval] at this
        exact this
      · have hsucc_mid : x i.succ = wN 0 := by
          rw [hx_mid i.succ (by rw [hsc]; omega) (by rw [hsc]; omega)]
          congr 1; rw [hsc]; omega
        rw [hsucc_mid] at hy2
        have := hwN_first y hy1 (by rw [if_neg hp0]; exact hy2)
        rw [efIntervalTP_eval] at this
        exact this
    · -- i.val > m
      rcases lt_trichotomy (i.val + 1) (ψ.pin 1).val with hreg2 | hreg2 | hreg2
      · -- interior middle
        rw [hx_mid i.castSucc (by rw [hcs]; omega) (by rw [hcs]; omega), hcs] at hy1
        rw [hx_mid i.succ (by rw [hsc]; omega) (by rw [hsc]; omega), hsc] at hy2
        have e1 : i.val - (ψ.pin 0).val - 1 + 1 = i.val + 1 - (ψ.pin 0).val - 1 := by omega
        have hmid := hwN_mid (i.val - (ψ.pin 0).val - 1) (by omega) y hy1
          (by rw [e1]; exact hy2)
        have emin : min ((ψ.pin 0).val + 2 + (i.val - (ψ.pin 0).val - 1)) (ψ.n + 1) = i.val + 1 := by
          omega
        simp only [emin] at hmid
        rw [efIntervalTP_eval] at hmid
        rw [show i.succ.castSucc = (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) from
          Fin.ext (by rw [Fin.val_castSucc, Fin.val_succ])]
        exact hmid
      · -- boundary middle/above at i.val = k - 1
        have hp0 : ¬ (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0 := by omega
        rw [hx_mid i.castSucc (by rw [hcs]; omega) (by rw [hcs]; omega), hcs] at hy1
        have hsucc_pin : i.succ = ψ.pin 1 := Fin.ext (by rw [hsc]; omega)
        rw [hsucc_pin, hxk] at hy2
        have ecm : i.val - (ψ.pin 0).val - 1 = (ψ.pin 1).val - (ψ.pin 0).val - 1 - 1 := by omega
        rw [ecm] at hy1
        have hl := hwN_last y (by rw [if_neg hp0]; exact hy1) hy2
        rw [efIntervalTP_eval] at hl
        rw [show i.succ.castSucc = (⟨(ψ.pin 1).val, by omega⟩ : Fin (ψ.n + 2)) from
          Fin.ext (by simp; omega)]
        exact hl
      · -- both above
        rw [hx_above i.castSucc (by rw [hcs]; omega), hcs] at hy1
        rw [hx_above i.succ (by rw [hsc]; omega), hsc] at hy2
        have e1 : i.val - (ψ.pin 1).val + 1 = i.val + 1 - (ψ.pin 1).val := by omega
        have hbeta := hxa_beta (i.val - (ψ.pin 1).val) (by omega) y hy1
          (by rw [e1]; exact hy2)
        simp only [hbetaR_def] at hbeta
        have emin : min ((ψ.pin 1).val + 1 + (i.val - (ψ.pin 1).val)) ψ.n = i.val + 1 := by omega
        simp only [emin] at hbeta
        rw [efIntervalTP_eval] at hbeta
        rw [show i.succ.castSucc = (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) from
          Fin.ext (by rw [Fin.val_castSucc, Fin.val_succ])]
        exact hbeta
  · -- after-cap
    intro y hy
    rw [hx_above (Fin.last ψ.n) (by rw [Fin.val_last]; omega), Fin.val_last] at hy
    have haf := hxa_cap y hy
    rw [efIntervalTP_eval] at haf
    exact haf

end Bimodal.Metalogic.WeakCanonical.Kamp
