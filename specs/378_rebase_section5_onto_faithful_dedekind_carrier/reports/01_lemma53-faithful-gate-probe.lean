/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.DedekindINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# GO/NO-GO probe: the faithful three-disjunct `Oₙ₊₁` over `HasDedekindINF`

Research probe only. Nothing here is imported by the library; it is compiled standalone with
`lake env lean` to answer one question on machine-checked evidence:

> Can Rabinovich's **printed** inductive step (PDF p.8) — all THREE disjuncts, including
> `(2) K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` — be transcribed over `HasDedekindINF` in `VVecEA2`,
> sorry-free, without a hypothesis absent from p.8?

The landed `negChainOn` (`EANegationFix/OnBuilder.lean:179`) truncates to TWO disjuncts and
assumes `HasAttainedINF`. This probe restores disjunct (2) and weakens the carrier.

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
Everything below cites **PDF p.8**.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Missing primitive 1: `K⁺(P)` as a `TemporalPred` -/

/-- `K⁺(P)` as a point type. `kplusFormula` (`PriorINF.lean:93`) is the object-language
    spelling; `kplus_formula_correct` (`Lemma53.lean:162`) is its correctness lemma.

    Source correspondence: PDF p.8, *"K⁺(P₁)(z₀) is an atomic ... formula in the canonical
    expansion"*. The tree needs no canonical expansion: `K⁺` is outright TL-definable here. -/
noncomputable def kplusPred (P : TemporalPred) : TemporalPred := ⟨kplusFormula P.formula⟩

theorem kplusPred_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    (kplusPred P).EvalAt M atomMap t ↔ kplus M atomMap P.formula t :=
  kplus_formula_correct M atomMap P.formula t

/-! ## Missing primitive 2: the `VVecEA2`-level prepend

`VBracketFormula.prependAll` (`EANegation.lean:312`) cannot be reused: the recursive `Oₙ` is now
a `VVecEA2` carrying its own `endpointLeft` **at `r₀`**, which must be absorbed into the point
type at `r₀`. That absorption is the only new construction disjunct (3) needs. -/

/-- Prepend a `¬P₁` segment and a point type at `r₀` to every disjunct of a `VVecEA2`,
    absorbing that disjunct's left-endpoint predicate (which lives at `r₀`) into the point type.

    Source correspondence: PDF p.8, disjunct (3)
    `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁))`. -/
def VVecEA2.prependAllVec (segLeft ptType : TemporalPred) (v : VVecEA2) : VVecEA2 :=
  ⟨v.disjuncts.map fun d =>
    ⟨d.1 + 1,
      { endpointLeft := TemporalPred.top
        endpointRight := d.2.endpointRight
        bracket := d.2.bracket.prepend segLeft (ptType.conj d.2.endpointLeft) }⟩⟩

theorem VVecEA2.prependAllVec_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (segLeft ptType : TemporalPred) (v : VVecEA2) (z0 z1 : M.carrier) :
    (v.prependAllVec segLeft ptType).holds M atomMap z0 z1 ↔
      ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        ptType.EvalAt M atomMap r0 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → segLeft.EvalAt M atomMap y) ∧
        v.holds M atomMap r0 z1 := by
  simp only [prependAllVec, VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨_, ⟨⟨m, vea⟩, hmem, rfl⟩, hEL, hER, hbr⟩
    obtain ⟨r0, ha, hb, hPt, hSeg, htail⟩ :=
      BracketFormula.prepend_holds_inv M atomMap vea.bracket segLeft
        (ptType.conj vea.endpointLeft) z0 z1 hbr
    rw [TemporalPred.eval_at_conj] at hPt
    exact ⟨r0, ha, hb, hPt.1, hSeg, ⟨m, vea⟩, hmem, hPt.2, hER, htail⟩
  · rintro ⟨r0, ha, hb, hPt, hSeg, ⟨m, vea⟩, hmem, hEL, hER, hbr⟩
    refine ⟨_, ⟨⟨m, vea⟩, hmem, rfl⟩, TemporalPred.top_eval_at M atomMap z0, hER, ?_⟩
    exact BracketFormula.prepend_holds M atomMap vea.bracket segLeft
      (ptType.conj vea.endpointLeft) z0 z1 r0 ha hb
      ((TemporalPred.eval_at_conj M atomMap _ _ r0).mpr ⟨hPt, hEL⟩) hSeg hbr

/-! ## Missing primitive 3: disjunct (2)'s backward half

The paper's `Subcase r₀ = z₀`. `K⁺(P₁)(z₀)` says `P₁` occurs in *every* interval above `z₀`, so
a tail chain on `(z₀,z₁)` can always be extended downward by one `P₁`-point. -/

/-- **Disjunct (2), backward half** (PDF p.8): given `K⁺(P₁)(z₀)`, a chain for the tail on
    `(z₀,z₁)` extends to a chain for `P₁ :: tail` on the *same* interval. This is precisely why
    the paper's `Subcase r₀ = z₀` recurses on `(z₀,z₁)` rather than on a shrunken interval. -/
theorem orderedPointsExist_combine_kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier) (hlt : z0 < z1)
    (hk : kplus M atomMap (Ps ⟨0, Nat.succ_pos n⟩).formula z0)
    (h_tail : orderedPointsExist M atomMap n (fun i => Ps i.succ) z0 z1) :
    orderedPointsExist M atomMap (n + 1) Ps z0 z1 := by
  obtain ⟨-, hdense⟩ := hk
  match n with
  | 0 =>
    obtain ⟨r, hr1, hr2, hPr⟩ := hdense z1 hlt
    exact orderedPointsExist_combine M atomMap 0 Ps z0 z1 r hr1 hr2 hPr
      (orderedPointsExist_zero M atomMap _ r z1)
  | n' + 1 =>
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds] at h_tail
    obtain ⟨w, hmono, hrange, hpoint, -, -, -⟩ := h_tail
    obtain ⟨r, hr1, hr2, hPr⟩ := hdense (w ⟨0, Nat.succ_pos n'⟩) (hrange ⟨0, Nat.succ_pos n'⟩).1
    refine orderedPointsExist_combine M atomMap (n' + 1) Ps z0 z1 r hr1
      (lt_trans hr2 (hrange ⟨0, Nat.succ_pos n'⟩).2) hPr ?_
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
    refine ⟨w, hmono, ?_, hpoint, ?_, ?_, ?_⟩
    · intro j
      refine ⟨lt_of_lt_of_le hr2 ?_, (hrange j).2⟩
      rcases Nat.eq_zero_or_pos j.val with hj | hj
      · exact le_of_eq (congrArg w (Fin.ext hj.symm))
      · exact le_of_lt (hmono ⟨0, Nat.succ_pos n'⟩ j (Fin.mk_lt_mk.mpr hj))
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro _ y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-- Widening the left endpoint is free: a chain on `(r₀,z₁)` is a chain on `(z₀,z₁)` whenever
    `z₀ < r₀`. Needed by eq (5.2)'s `K⁺(P₁)(r₀)` alternative, where the witness produced at `r₀`
    must be reported back on the outer interval. -/
theorem orderedPointsExist_widen_left {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin n → TemporalPred) (z0 r0 z1 : M.carrier) (h : z0 < r0)
    (hc : orderedPointsExist M atomMap n Ps r0 z1) :
    orderedPointsExist M atomMap n Ps z0 z1 := by
  match n with
  | 0 => exact orderedPointsExist_zero M atomMap _ z0 z1
  | n' + 1 =>
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds] at hc ⊢
    obtain ⟨w, hmono, hrange, hpoint, -, -, -⟩ := hc
    exact ⟨w, hmono, fun j => ⟨lt_trans h (hrange j).1, (hrange j).2⟩, hpoint,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun _ y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-! ## The faithful three-disjunct `Oₙ₊₁` (PDF p.8) -/

/-- Disjunct (2)'s endpoint block, alone: `K⁺(P₁)(z₀)` with a trivial interval and right
    endpoint. Conjoined with `Oₙ(rest)` via `VVecEA2.conjFull` (`VecEAConjFull.lean:498`),
    which conjoins `endpointLeft` pairwise — exactly what disjunct (2) needs. -/
noncomputable def kplusLeftBlock (P : TemporalPred) : VVecEA2 :=
  ⟨[⟨0, { endpointLeft := kplusPred P
          endpointRight := TemporalPred.top
          bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩

theorem kplusLeftBlock_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    (kplusLeftBlock P).holds M atomMap z0 z1 ↔ kplus M atomMap P.formula z0 := by
  simp only [kplusLeftBlock, VVecEA2.holds, List.mem_singleton, exists_eq_left, VecEA2.holds]
  rw [BracketFormula.trivial_holds]
  constructor
  · rintro ⟨h, -, -⟩; exact (kplusPred_eval M atomMap P z0).mp h
  · intro h
    exact ⟨(kplusPred_eval M atomMap P z0).mpr h, TemporalPred.top_eval_at M atomMap z1,
      fun y _ _ => TemporalPred.top_eval_at M atomMap y⟩

/-- **The faithful `Oₙ` (PDF p.8), all three printed disjuncts.**

    * `[] ↦ ⊥` (the empty chain always exists, so its negation is `False`)
    * `P :: rest ↦`
      1. `(∀y)^{<z₁}_{>z₀}¬P(y)`                              — `oOne P`
      2. `K⁺(P)(z₀) ∧ Oₙ(rest, z₀, z₁)`                        — **RESTORED HERE**
      3. `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P) ∧ Oₙ(rest, r₀, z₁))`

    Disjunct (3)'s point type at `r₀` is `P ∨ K⁺(P)` — eq (5.2)'s third conjunct, needing
    `TemporalPred.disj` (`ExistsForallNF.lean:87`). Result type is `VVecEA2`, not
    `VBracketFormula`: disjunct (2) conjoins an endpoint predicate at `z₀`. -/
noncomputable def negChainOnFaithful : List TemporalPred → VVecEA2
  | [] => ⟨[]⟩
  | P :: rest =>
    ((oOne P).disj
      ((kplusLeftBlock P).conjFull (negChainOnFaithful rest))).disj
        ((negChainOnFaithful rest).prependAllVec P.neg (P.disj (kplusPred P)))

/-- **Lemma 5.3, faithful form (PDF p.8), over `HasDedekindINF`.**

    The GO/NO-GO gate. Compare `negChainOn_iff` (`EANegationFix/OnBuilder.lean:189`), which
    proves the same shape with TWO disjuncts under the strictly stronger `HasAttainedINF`. -/
theorem negChainOnFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    (Ps : List TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negChainOnFaithful Ps).holds M atomMap z0 z1 ↔
      ¬ (chainAllTrue Ps).holds M atomMap z0 z1 := by
  induction Ps generalizing z0 z1 with
  | nil =>
    rw [chainAllTrue_holds_iff]
    simp only [negChainOnFaithful, VVecEA2.holds, List.not_mem_nil, false_and, exists_false]
    exact Iff.intro False.elim
      (fun h => absurd (orderedPointsExist_zero M atomMap _ z0 z1) h)
  | cons P rest ih =>
    rw [chainAllTrue_holds_iff]
    rw [negChainOnFaithful, VVecEA2.disj_holds, VVecEA2.disj_holds,
      VVecEA2.conjFull_iff, kplusLeftBlock_holds, VVecEA2.prependAllVec_holds]
    constructor
    · rintro ((h1 | ⟨hk, hOn⟩) | ⟨r0, hr0a, hr0b, hPt, hSeg, hOn⟩)
      · -- Disjunct (1): `¬P` throughout `(z₀,z₁)` — no first witness can be placed.
        simp only [oOne, VVecEA2.holds, List.mem_singleton, exists_eq_left] at h1
        rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds] at h1
        rintro ⟨w, -, hrange, hpoint, -, -, -⟩
        have := h1 (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1 (hrange ⟨0, by omega⟩).2
        simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth] at this
        exact this (hpoint ⟨0, by omega⟩)
      · -- Disjunct (2): drop the first witness; the tail chain lands on the SAME interval.
        intro h_exists
        refine ((ih z0 z1 h_lt).mp hOn) ?_
        rw [chainAllTrue_holds_iff]
        exact orderedPointsExist_decompose M atomMap rest.length
          (fun i => (P :: rest).get i) z0 z1 z0
          (fun y hy0 hy1 => absurd (lt_trans hy0 hy1) (lt_irrefl z0)) h_exists
      · -- Disjunct (3): the eq (5.2) pin; the tail chain fails on `(r₀,z₁)` by IH.
        intro h_exists
        refine ((ih r0 z1 hr0b).mp hOn) ?_
        rw [chainAllTrue_holds_iff]
        exact orderedPointsExist_decompose M atomMap rest.length
          (fun i => (P :: rest).get i) z0 z1 r0
          (fun y hy0 hy1 => by
            have := hSeg y hy0 hy1
            simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth] at this
            exact this)
          h_exists
    · intro h_neg
      by_cases h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x
      · -- `P` occurs: the faithful carrier fires, and its LEFT disjunct is disjunct (2).
        rcases h_INF.first_occ P.formula z0 z1 h_lt
          (by obtain ⟨x, h1, h2, h3⟩ := h_occ; exact ⟨x, h1, h2, h3⟩) with
          hk | ⟨r0, hr0a, hr0b, hnone, hPr0⟩
        · -- **Subcase `r₀ = z₀`** (p.8) — the branch the attained carrier DELETES.
          refine Or.inl (Or.inr ⟨hk, (ih z0 z1 h_lt).mpr ?_⟩)
          rw [chainAllTrue_holds_iff]
          intro h_tail
          exact h_neg (orderedPointsExist_combine_kplus M atomMap rest.length
            (fun i => (P :: rest).get i) z0 z1 h_lt hk h_tail)
        · -- **Subcase `r₀ ∈ (z₀,z₁)`** — eq (5.2), disjunct (3).
          refine Or.inr ⟨r0, hr0a, hr0b, ?_, ?_, (ih r0 z1 hr0b).mpr ?_⟩
          · rw [TemporalPred.eval_at_disj]
            rcases hPr0 with h | h
            · exact Or.inl h
            · exact Or.inr ((kplusPred_eval M atomMap P r0).mpr h)
          · intro y hy0 hy1
            simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth]
            exact hnone y hy0 hy1
          · rw [chainAllTrue_holds_iff]
            intro h_tail
            refine h_neg ?_
            rcases hPr0 with h | h
            · -- `P₁(r₀)` attained: pin `r₀` directly.
              exact orderedPointsExist_combine M atomMap rest.length
                (fun i => (P :: rest).get i) z0 z1 r0 hr0a hr0b h h_tail
            · -- `K⁺(P₁)(r₀)`: `P₁` is not at `r₀`, so pin a point just above it, then widen.
              exact orderedPointsExist_widen_left M atomMap _ _ z0 r0 z1 hr0a
                (orderedPointsExist_combine_kplus M atomMap rest.length
                  (fun i => (P :: rest).get i) r0 z1 hr0b h h_tail)
      · -- `P` never occurs: disjunct (1).
        push Not at h_occ
        refine Or.inl (Or.inl ?_)
        simp only [oOne, VVecEA2.holds, List.mem_singleton, exists_eq_left]
        rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
        intro y hy0 hy1
        simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth]
        exact h_occ y hy0 hy1

/-! ## The Phase 7 deliverable shape: `lemma53` with `HasAttainedINF` weakened to `HasDedekindINF`

This is `lemma53` (`Lemma53.lean:432`) verbatim except for the carrier. `O` is hoisted out of
`M`, `atomMap`, `z₀`, `z₁`, so it is a function of `P` alone — which is what "is equivalent to a
`∨∃⃗∀` formula" means, and the whole content of the claim. -/

theorem lemma53Faithful {sig : MonadicSignature} {n : Nat} (P : Fin n → TemporalPred) :
    ∃ O : VVecEA2, ∀ (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds),
      HasDedekindINF M atomMap →
      ∀ z0 z1 : M.carrier,
        O.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1 := by
  refine ⟨negChainOnFaithful (List.ofFn P), fun M atomMap h_INF z0 z1 => ?_⟩
  by_cases hlt : z0 < z1
  · rw [negChainOnFaithful_iff M atomMap h_INF _ z0 z1 hlt]
    exact not_congr (chainAllTrue_ofFn_iff_allTopBracket M atomMap P z0 z1)
  · match n, P with
    | 0, P =>
      -- `n = 0`: the bracket holds on every interval, so `Oₙ` must hold nowhere.
      simp only [negChainOnFaithful, List.ofFn_zero, VVecEA2.holds, List.not_mem_nil,
        false_and, exists_false]
      exact Iff.intro False.elim (fun h => absurd (allTopBracket_zero_holds M atomMap P z0 z1) h)
    | k + 1, P =>
      -- Empty interval: no witness fits, and disjunct (1) is vacuously satisfied.
      constructor
      · intro _ hb; exact hlt (allTopBracket_succ_lt M atomMap P z0 z1 hb)
      · intro _
        rw [show List.ofFn P = P 0 :: List.ofFn (fun i : Fin k => P i.succ) from by
          simp [List.ofFn_succ]]
        rw [negChainOnFaithful, VVecEA2.disj_holds, VVecEA2.disj_holds]
        refine Or.inl (Or.inl ?_)
        simp only [oOne, VVecEA2.holds, List.mem_singleton, exists_eq_left]
        rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
        intro y hy0 hy1
        exact absurd (lt_trans hy0 hy1) hlt

/-! ## Failed-vacuity control (mandatory)

The **per-point** ordering below quantifies `∃ O` *inside* `∀ z₀ z₁`. It is provable with **no
carrier hypothesis at all** — one picks the all-`⊤` block when the RHS is true and `oZero` when
it is false. That it compiles is exactly what makes it worthless, and is the control showing the
hoisted `lemma53Faithful` above is not the same statement. -/

theorem lemma53Faithful_perPoint_is_VACUOUS {sig : MonadicSignature} {n : Nat}
    (P : Fin n → TemporalPred) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (z0 z1 : M.carrier) :
    ∃ O : VVecEA2, O.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1 := by
  by_cases h : (allTopBracket P).holds M atomMap z0 z1
  · refine ⟨oZero, ?_⟩
    simp only [oZero, VVecEA2.holds, List.not_mem_nil, false_and, exists_false]
    exact Iff.intro False.elim (fun hn => absurd h hn)
  · refine ⟨⟨[⟨0, VecEA2.fromBracket (BracketFormula.trivial TemporalPred.top)⟩]⟩, ?_⟩
    simp only [VVecEA2.holds, List.mem_singleton, exists_eq_left]
    rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
    exact Iff.intro (fun _ => h) (fun _ y _ _ => TemporalPred.top_eval_at M atomMap y)

/-! ## Extended non-vacuity: what the faithful carrier buys, and where it is OBSERVABLE

Disjunct (2) is restored above and is genuinely exercised by the proof — but on **Prior
structures** it is provably dead. This is the exclusion statement the extended non-vacuity rule
demands, stated as a theorem rather than as prose. -/

/-- **On Prior structures, disjunct (2) is unreachable.** `SemanticPriorUZ` gives
    `HasAttainedINF` (`PriorINF.lean:230`), hence `HasDefinableINF` (`:221`), and
    `hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`) then makes `K⁺(P)(z₀)` impossible
    whenever `P` occurs in `(z₀,z₁)`.

    Consequence: `negChainOnFaithful`'s disjunct (2) can only ever fire on a structure that is
    **not** a Prior structure. No such structure is constructed anywhere in this tree, so the
    faithful re-base is not observable by any current consumer — it becomes observable only once
    a genuinely non-attained Dedekind-complete frame class is built. -/
theorem prior_makes_disjunct2_unreachable {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : SemanticPriorUZ M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) :
    ¬kplus M atomMap P z0 :=
  hasDefinableINF_excludes_kplus M atomMap
    ((prior_hasAttainedINF M atomMap h_UZ).toHasDefinableINF) P z0 z1 h_lt h_occ

/-! ## Verification gates -/

#print axioms negChainOnFaithful_iff
#print axioms lemma53Faithful
#print axioms VVecEA2.prependAllVec_holds
#print axioms orderedPointsExist_combine_kplus
#print axioms prior_makes_disjunct2_unreachable
#print axioms lemma53Faithful_perPoint_is_VACUOUS

end FormalSystem.Metalogic.WeakCanonical.Kamp
