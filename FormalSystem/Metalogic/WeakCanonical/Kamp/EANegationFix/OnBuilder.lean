/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegation
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationClosure

/-!
# Fixed-Formula Negation Kit: Lemma 5.3 On-Builder

Fixed-formula (model-independent) version of Rabinovich 2014 Lemma 5.3:
`negChainOn Ps` is a `VBracketFormula` built purely from the list `Ps` of
temporal predicates, whose semantics on any structure with attained infima
(`HasAttainedINF`) is `¬∃` increasing witnesses in `(z0, z1)` satisfying `Ps`
pointwise.

This refactors the existential form `neg_orderedPointsExist_is_vbracket`
(EANegation.lean) into an explicit named builder: downstream fixed-formula
constructions (negBoundedRightFix / negBoundedLeftFix, Cor 5.4; negFix,
Lemma 5.1) need to name the On-builder and recurse through it, which the
existential form does not permit.

## Architectural note (Rabinovich Def 4.1)

In this codebase `TemporalPred` is an arbitrary `Formula` wrapper and
`TemporalTruth` interprets `.untl`/`.snce` natively — there is no expansion
machinery. The `F_i` predicates of Cor 5.4 will enter (Phase 9) as native
`.untl`/`.snce` formulas; nothing in this file restricts the predicates.

## Correspondence guard

`negChainOn_iff` below **is** Rabinovich's Lemma 5.3 (PDF p.8). The full Section 5
correspondence table — which in-tree name transcribes which numbered result, with page cites —
is `Kamp/Section5Correspondence.lean`, which is reachable from `FormalSystem.lean` and so
CI-protected. **Consult it before planning any Section 5 work**: this transcription was
discoverable by grep for thirteen months and was nonetheless re-planned from scratch more than
once, because nothing here names Rabinovich, a section, or a lemma number.

**Carrier delta**: this file assumes `HasAttainedINF`, which is strictly stronger than the
Dedekind completeness Rabinovich's Lemma 5.3 assumes — stronger even than `HasDefinableINF`,
which `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`) machine-refutes as already too
strong. See the "Attained simplification" note directly below, and
`Section5Correspondence.lean`'s docstring for the full exclusion.

## Attained simplification

Rabinovich's inductive step (PDF p.8) has three disjuncts: never-P1, the
K+ limit disjunct, and the attained-inf pin. On Prior structures the INF is
always attained (`HasAttainedINF`, PriorINF.lean), so the K+ disjunct is
vacuous and the pin disjunct is the plain `[¬P-segment, P-point]` prepend
(`VBracketFormula.prependAll`).

**This is a deviation from the paper, admitted here rather than hidden**: dropping the K+
disjunct is exactly what makes the carrier too strong. It is sound on Prior structures
(`prior_hasAttainedINF`, `PriorINF.lean:224`) and is the right thing at the live-path boundary,
but a result proved here is Lemma 5.3 *restricted to attained structures*, not Lemma 5.3.

## Base case

`negChainOn [] = ⟨[]⟩` (the empty disjunction, i.e. False): the empty chain
always exists — `orderedPointsExist_zero` — so its negation is False. (The
plan text said `trivialTrue` here; that is machine-refuted by the base case
of `neg_orderedPointsExist_is_vbracket` and by the stated iff, which forces
the empty disjunction. Rabinovich's own basis starts at n = 1 and is
recovered here: `negChainOn [P]` reduces to the single never-P disjunct plus
one pin disjunct whose tail is unsatisfiable-free — see `negChainOn_iff`.)

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.3, **PDF p.8**. Cite by page only: the
  companion `.md` conversion is corrupt (it drops displayed equations — and Lemma 5.3 *is*
  displayed equations — and inverts `k ≠ m` to `k = m`). The former `chunk_0014 md:3-41`
  citation here pointed into that corrupt conversion and has been re-cited by page.
- EANegation.lean: `neg_orderedPointsExist_is_vbracket` (existential form)
- `Kamp/Section5Correspondence.lean`: the CI-protected Section 5 correspondence table
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Witness combination (extracted from `neg_orderedPointsExist_is_vbracket`)

If `r ∈ (z0, z1)` satisfies `Ps 0` and an increasing chain for the shifted
predicates exists in `(r, z1)`, then prepending `r` gives a full chain in
`(z0, z1)`. This was inline (`h_combine_witnesses`) in the existential proof;
the fixed-formula iff needs it as a standalone lemma. -/

/-- Combine a first witness with a tail chain: if `Ps 0` holds at `r ∈ (z0, z1)`
    and the shifted chain exists on `(r, z1)`, the full chain exists on `(z0, z1)`. -/
theorem orderedPointsExist_combine {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 r : M.carrier),
    z0 < r → r < z1 →
    (Ps ⟨0, Nat.succ_pos n⟩).EvalAt M atomMap r →
    orderedPointsExist M atomMap n (fun i => Ps i.succ) r z1 →
    orderedPointsExist M atomMap (n + 1) Ps z0 z1 := by
  intro n
  match n with
  | 0 =>
    intro Ps z0 z1 r hr_above hr_below hr_P _
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
    refine ⟨fun _ => r, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab; exact absurd hab (by omega)
    · intro _; exact ⟨hr_above, hr_below⟩
    · intro ⟨i, hi⟩; simp only [zero_add, Order.lt_one_iff] at hi; subst hi; exact hr_P
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro j; exact Fin.elim0 j
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
  | n' + 1 =>
    intro Ps z0 z1 r hr_above hr_below hr_P hr_tail
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
      at hr_tail ⊢
    obtain ⟨w_tail, hmono_tail, hrange_tail, hpoint_tail, _, _, _⟩ := hr_tail
    let w' : Fin (n' + 2) → M.carrier := fun ⟨i, _⟩ =>
      if i = 0 then r else w_tail ⟨i - 1, by omega⟩
    refine ⟨w', ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨a, ha⟩ ⟨b, hb⟩ hab
      simp only [Fin.lt_def] at hab; simp only [w']
      by_cases ha0 : a = 0
      · subst ha0; simp only [↓reduceIte, show b ≠ 0 from by omega]
        calc r < w_tail ⟨0, by omega⟩ := (hrange_tail ⟨0, by omega⟩).1
           _ ≤ w_tail ⟨b - 1, by omega⟩ := by
              rcases Nat.eq_or_lt_of_le (show 1 ≤ b from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hmono_tail ⟨0, by omega⟩ ⟨b - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega))
      · simp only [ha0, ↓reduceIte, show b ≠ 0 from by omega]
        exact hmono_tail ⟨a - 1, by omega⟩ ⟨b - 1, by omega⟩
          (by simp [Fin.lt_def]; omega)
    · intro ⟨i, hi⟩; simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp only [↓reduceIte]; exact ⟨hr_above, hr_below⟩
      · simp only [hi0, ↓reduceIte]
        exact ⟨lt_trans hr_above (lt_of_lt_of_le (hrange_tail ⟨0, by omega⟩).1
          (by rcases Nat.eq_or_lt_of_le (show 1 ≤ i from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hmono_tail ⟨0, by omega⟩ ⟨i - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega)))),
               (hrange_tail ⟨i - 1, by omega⟩).2⟩
    · intro ⟨i, hi⟩; simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp only [Fin.zero_eta, ↓reduceIte]; exact hr_P
      · simp only [hi0, ↓reduceIte]
        convert hpoint_tail ⟨i - 1, by omega⟩ using 2
        ext; simp; omega
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro _ y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-! ## The fixed On-builder -/

/-- The all-top-segment bracket built from a list of point predicates: the
    chain `[⊤, P_1, ⊤, P_2, ⊤, ..., P_n, ⊤](z0, z1)`. Its `holds` is exactly
    "there exist increasing witnesses in `(z0, z1)` satisfying `Ps` pointwise". -/
def chainAllTrue (Ps : List TemporalPred) : BracketFormula Ps.length :=
  BracketFormula.allTrue Ps.length (fun i => Ps.get i)

/-- `chainAllTrue` semantics is `orderedPointsExist` (definitional). -/
theorem chainAllTrue_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) (z0 z1 : M.carrier) :
    (chainAllTrue Ps).holds M atomMap z0 z1 ↔
    orderedPointsExist M atomMap Ps.length (fun i => Ps.get i) z0 z1 :=
  Iff.rfl

/-- **Lemma 5.3 On-builder** (Rabinovich 2014, fixed-formula form): the
    V-bracket formula equivalent to "no increasing chain in `(z0, z1)`
    satisfies `Ps` pointwise", on any structure with attained infima.

    - `[] ↦ ⟨[]⟩` (empty disjunction = False; the empty chain always exists)
    - `P :: rest ↦` never-P 0-bracket `[¬P]` OR the attained-first-occurrence
      pin `[¬P, P, ...]` prepended to every disjunct of `negChainOn rest`
      (the K+ disjunct is vacuous on attained structures). -/
def negChainOn : List TemporalPred → VBracketFormula
  | [] => ⟨[]⟩
  | P :: rest =>
    ⟨⟨0, BracketFormula.trivial P.neg⟩ ::
      (VBracketFormula.prependAll P.neg P (negChainOn rest)).disjuncts⟩

/-- **Lemma 5.3** (fixed-formula iff): on any structure with attained infima,
    `negChainOn Ps` holds on `(z0, z1)` iff there is no increasing chain of
    witnesses in `(z0, z1)` satisfying `Ps` pointwise (phrased against
    `BracketFormula.holds` of the all-top-segment bracket built from `Ps`). -/
theorem negChainOn_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (Ps : List TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negChainOn Ps).holds M atomMap z0 z1 ↔
    ¬ (chainAllTrue Ps).holds M atomMap z0 z1 := by
  induction Ps generalizing z0 z1 h_lt with
  | nil =>
    rw [chainAllTrue_holds_iff]
    simp only [negChainOn, VBracketFormula.holds, List.not_mem_nil, false_and, exists_false]
    exact Iff.intro False.elim
      (fun h => absurd (orderedPointsExist_zero M atomMap _ z0 z1) h)
  | cons P rest ih =>
    rw [chainAllTrue_holds_iff]
    constructor
    · -- Forward: some disjunct holds → no chain
      rintro ⟨⟨m, bf⟩, h_mem, h_holds⟩
      simp only [negChainOn, VBracketFormula.prependAll, List.mem_cons,
        List.mem_map] at h_mem
      rcases h_mem with h_eq | ⟨⟨m', bf'⟩, h_mem', h_eq'⟩
      · -- Case A: ¬P everywhere → no first witness possible
        obtain rfl := congr_arg Sigma.fst h_eq
        have hbf_eq : bf = BracketFormula.trivial P.neg :=
          eq_of_heq (Sigma.mk.inj h_eq).2
        subst hbf_eq
        rw [BracketFormula.trivial_holds] at h_holds
        rintro ⟨w, _, hrange, hpoint, _, _, _⟩
        have := h_holds (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1
          (hrange ⟨0, by omega⟩).2
        simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg,
          TemporalTruth] at this
        exact this (hpoint ⟨0, by omega⟩)
      · -- Case B: pin disjunct → tail chain fails in (r0, z1) by IH
        have hm_eq := congr_arg Sigma.fst h_eq'
        simp only at hm_eq; subst hm_eq
        have hbf_eq : BracketFormula.prepend P.neg P bf' = bf :=
          eq_of_heq (Sigma.mk.inj h_eq').2
        subst hbf_eq
        obtain ⟨r0, hr0_above, hr0_below, _, hSeg_r0, h_bf'_holds⟩ :=
          BracketFormula.prepend_holds_inv M atomMap bf' P.neg P z0 z1 h_holds
        have h_tail_neg : ¬ orderedPointsExist M atomMap rest.length
            (fun i => rest.get i) r0 z1 := by
          rw [← chainAllTrue_holds_iff]
          exact (ih r0 z1 hr0_below).mp ⟨⟨m', bf'⟩, h_mem', h_bf'_holds⟩
        intro h_exists
        exact h_tail_neg
          (orderedPointsExist_decompose M atomMap rest.length
            (fun i => (P :: rest).get i) z0 z1 r0
            (fun y hy0 hy1 => by
              have := hSeg_r0 y hy0 hy1
              simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg,
                TemporalTruth] at this
              exact this)
            h_exists)
    · -- Backward: no chain → some disjunct holds
      intro h_neg
      by_cases h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
          P.EvalAt M atomMap x
      · -- Case B: P occurs; pin the attained first occurrence
        obtain ⟨r0, hr0_above, hr0_below, h_no_before, h_P_r0⟩ :=
          h_INF.first_occ P.formula z0 z1 h_lt (by
            obtain ⟨x, hx1, hx2, hx3⟩ := h_occ; exact ⟨x, hx1, hx2, hx3⟩)
        have h_tail_neg : ¬ orderedPointsExist M atomMap rest.length
            (fun i => rest.get i) r0 z1 := by
          intro h_tail
          exact h_neg
            (orderedPointsExist_combine M atomMap rest.length
              (fun i => (P :: rest).get i) z0 z1 r0
              hr0_above hr0_below h_P_r0 h_tail)
        have h_IH_holds : (negChainOn rest).holds M atomMap r0 z1 :=
          (ih r0 z1 hr0_below).mpr (by
            rw [chainAllTrue_holds_iff]; exact h_tail_neg)
        obtain ⟨⟨m', bf'⟩, h_mem', h_bf'_holds⟩ := h_IH_holds
        refine ⟨⟨m' + 1, bf'.prepend P.neg P⟩, ?_, ?_⟩
        · simp only [negChainOn, VBracketFormula.prependAll, List.mem_cons,
            List.mem_map]
          right; exact ⟨⟨m', bf'⟩, h_mem', rfl⟩
        · exact BracketFormula.prepend_holds M atomMap bf' P.neg P z0 z1 r0
            hr0_above hr0_below h_P_r0
            (fun y hy0 hy1 => by
              have := h_no_before y hy0 hy1
              simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg,
                TemporalTruth]
              exact this)
            h_bf'_holds
      · -- Case A: P never occurs; the never-P disjunct holds
        push Not at h_occ
        refine ⟨⟨0, BracketFormula.trivial P.neg⟩, ?_, ?_⟩
        · simp [negChainOn]
        · rw [BracketFormula.trivial_holds]
          intro y hy0 hy1
          simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg,
            TemporalTruth]
          exact h_occ y hy0 hy1


end FormalSystem.Metalogic.WeakCanonical.Kamp
