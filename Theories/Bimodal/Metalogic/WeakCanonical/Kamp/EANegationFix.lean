import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegation
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure

/-!
# Fixed-Formula Negation Kit: Lemma 5.3 On-Builder (task 350 Phase 8)

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
`temporal_truth` interprets `.untl`/`.snce` natively — there is no expansion
machinery. The `F_i` predicates of Cor 5.4 will enter (Phase 9) as native
`.untl`/`.snce` formulas; nothing in this file restricts the predicates.

## Attained simplification

Rabinovich's inductive step (chunk_0014) has three disjuncts: never-P1, the
K+ limit disjunct, and the attained-inf pin. On Prior structures the INF is
always attained (`HasAttainedINF`, PriorINF.lean), so the K+ disjunct is
vacuous and the pin disjunct is the plain `[¬P-segment, P-point]` prepend
(`VBracketFormula.prependAll`).

## Base case

`negChainOn [] = ⟨[]⟩` (the empty disjunction, i.e. False): the empty chain
always exists — `orderedPointsExist_zero` — so its negation is False. (The
plan text said `trivialTrue` here; that is machine-refuted by the base case
of `neg_orderedPointsExist_is_vbracket` and by the stated iff, which forces
the empty disjunction. Rabinovich's own basis starts at n = 1 and is
recovered here: `negChainOn [P]` reduces to the single never-P disjunct plus
one pin disjunct whose tail is unsatisfiable-free — see `negChainOn_iff`.)

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.3 (chunk_0014 md:3-41)
- EANegation.lean: `neg_orderedPointsExist_is_vbracket` (existential form)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

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
    (Ps ⟨0, Nat.succ_pos n⟩).eval_at M atomMap r →
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
    · intro ⟨i, hi⟩; simp at hi; subst hi; exact hr_P
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
      · subst ha0; simp [show b ≠ 0 from by omega]
        calc r < w_tail ⟨0, by omega⟩ := (hrange_tail ⟨0, by omega⟩).1
           _ ≤ w_tail ⟨b - 1, by omega⟩ := by
              rcases Nat.eq_or_lt_of_le (show 1 ≤ b from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hmono_tail ⟨0, by omega⟩ ⟨b - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega))
      · simp [ha0, show b ≠ 0 from by omega]
        exact hmono_tail ⟨a - 1, by omega⟩ ⟨b - 1, by omega⟩
          (by simp [Fin.lt_def]; omega)
    · intro ⟨i, hi⟩; simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp; exact ⟨hr_above, hr_below⟩
      · simp [hi0]
        exact ⟨lt_trans hr_above (lt_of_lt_of_le (hrange_tail ⟨0, by omega⟩).1
          (by rcases Nat.eq_or_lt_of_le (show 1 ≤ i from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hmono_tail ⟨0, by omega⟩ ⟨i - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega)))),
               (hrange_tail ⟨i - 1, by omega⟩).2⟩
    · intro ⟨i, hi⟩; simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp; exact hr_P
      · simp [hi0]
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
        simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
          temporal_truth] at this
        exact this (hpoint ⟨0, by omega⟩)
      · -- Case B: pin disjunct → tail chain fails in (r0, z1) by IH
        have hm_eq := congr_arg Sigma.fst h_eq'
        simp at hm_eq; subst hm_eq
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
              simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
                temporal_truth] at this
              exact this)
            h_exists)
    · -- Backward: no chain → some disjunct holds
      intro h_neg
      by_cases h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
          P.eval_at M atomMap x
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
              simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
                temporal_truth]
              exact this)
            h_bf'_holds
      · -- Case A: P never occurs; the never-P disjunct holds
        push_neg at h_occ
        refine ⟨⟨0, BracketFormula.trivial P.neg⟩, ?_, ?_⟩
        · simp [negChainOn]
        · rw [BracketFormula.trivial_holds]
          intro y hy0 hy1
          simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
            temporal_truth]
          exact h_occ y hy0 hy1

/-! # Corollary 5.4 mirrors (task 350 Phase 9)

Fixed-formula negation of the endpoint-moved bracket existentials
(Rabinovich 2014, Cor 5.4, chunk_0014 md:49, chunk_0015 md:3-43):

- `negBoundedRightFix bf` ↔ `¬∃ z ∈ (z0, z1), bf.holds z0 z`  (Cor 5.4(1))
- `negBoundedLeftFix bf` ↔ `¬∃ z ∈ (z0, z1), bf.holds z z1`   (Cor 5.4(2))

The construction follows the paper: fold the bracket's point/segment data
into nested Until (resp. Since) predicates `F_i` — `F_i := α_i ∧ (β_{i+1}
Until F_{i+1})` — so that the endpoint-moved bracket existential becomes
"`F̂` at the fixed endpoint AND a pointwise increasing chain of the tail
folds exists" (the ⇐ direction is the chunk_0015 induction with the
Until-witness `y ≤ c / y > c` relink case split). The chain negation is
Lemma 5.3 (`negChainOn`); the endpoint conjunct `¬F̂(z0)` — not expressible
as an interval formula directly — becomes an attained first-occurrence pin
of `¬β_0` (mirror: attained last-occurrence pin of `¬β_n`, consuming
`HasAttainedSUP`), which is where the attained INF/SUP surrogates for
Dedekind completeness enter.

Encoding note (endpoint types): this codebase's brackets carry no point
types at the interval endpoints (those live in `VecEA2`), so Rabinovich's
`α_0(z_0)` / `α_n(z)` endpoint conjuncts are `⊤` here; his `¬F_0(z_0)`
output disjunct correspondingly becomes the pin disjunct below rather than
an endpoint predicate. -/

/-! ## Temporal-predicate Until/Since builders -/

/-- `goal` is reachable strictly to the right, with `seg` holding at all
    points strictly in between (native `Formula.untl` semantics). -/
def TemporalPred.untl (goal seg : TemporalPred) : TemporalPred :=
  ⟨Formula.untl goal.formula seg.formula⟩

/-- `goal` is reachable strictly to the left, with `seg` holding at all
    points strictly in between (native `Formula.snce` semantics). -/
def TemporalPred.snce (goal seg : TemporalPred) : TemporalPred :=
  ⟨Formula.snce goal.formula seg.formula⟩

/-- Semantics of `TemporalPred.untl`. -/
theorem TemporalPred.eval_at_untl {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (goal seg : TemporalPred) (t : M.carrier) :
    (TemporalPred.untl goal seg).eval_at M atomMap t ↔
    ∃ y : M.carrier, t < y ∧ goal.eval_at M atomMap y ∧
      ∀ w : M.carrier, t < w → w < y → seg.eval_at M atomMap w := by
  simp only [untl, eval_at, temporal_truth]

/-- Semantics of `TemporalPred.snce`. -/
theorem TemporalPred.eval_at_snce {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (goal seg : TemporalPred) (t : M.carrier) :
    (TemporalPred.snce goal seg).eval_at M atomMap t ↔
    ∃ y : M.carrier, y < t ∧ goal.eval_at M atomMap y ∧
      ∀ w : M.carrier, y < w → w < t → seg.eval_at M atomMap w := by
  simp only [snce, eval_at, temporal_truth]

/-- Last occurrence of a temporal predicate P in (z0, z1) on structures with
    attained suprema. Mirror of `HasAttainedINF.first_occ_tp`. -/
theorem HasAttainedSUP.last_occ_tp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_SUP : HasAttainedSUP M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      P.eval_at M atomMap r0 ∧
      (∀ y : M.carrier, r0 < y → y < z1 → ¬P.eval_at M atomMap y) := by
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  obtain ⟨r0, hr0_above, hr0_below, h_neg_after, hPr0⟩ :=
    h_SUP.last_occ P.formula z0 z1 h_lt ⟨x, hx0, hx1, hPx⟩
  exact ⟨r0, hr0_above, hr0_below, hPr0, fun y hy0 hy1 hPy =>
    h_neg_after y hy0 hy1 hPy⟩

/-! ## `chainAllTrue` structural lemmas -/

/-- The empty all-top chain always holds. -/
theorem chainAllTrue_nil_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    (chainAllTrue []).holds M atomMap z0 z1 := by
  intro y _ _
  exact TemporalPred.eval_at_top M atomMap y

/-- `chainAllTrue` of a cons is a prepend with top segment. -/
theorem chainAllTrue_cons (P : TemporalPred) (Ps : List TemporalPred) :
    chainAllTrue (P :: Ps) =
      BracketFormula.prepend TemporalPred.top P (chainAllTrue Ps) := by
  simp only [chainAllTrue, BracketFormula.allTrue, BracketFormula.prepend]
  congr 1
  · funext i
    obtain ⟨iv, hiv⟩ := i
    cases iv with
    | zero => rfl
    | succ k => rfl
  · funext i
    obtain ⟨iv, hiv⟩ := i
    cases iv with
    | zero => rfl
    | succ k => rfl

/-- First-point decomposition of an all-top chain. -/
theorem chainAllTrue_cons_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (Ps : List TemporalPred) (z0 z1 : M.carrier) :
    (chainAllTrue (P :: Ps)).holds M atomMap z0 z1 ↔
    ∃ c : M.carrier, z0 < c ∧ c < z1 ∧ P.eval_at M atomMap c ∧
      (chainAllTrue Ps).holds M atomMap c z1 := by
  rw [chainAllTrue_cons]
  constructor
  · intro h
    obtain ⟨r0, h1, h2, h3, _, h5⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ z0 z1 h
    exact ⟨r0, h1, h2, h3, h5⟩
  · rintro ⟨c, h1, h2, h3, h4⟩
    exact BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 c h1 h2 h3
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) h4

/-- Last-point decomposition of an all-top chain. -/
theorem chainAllTrue_snoc_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) (P : TemporalPred) :
    ∀ (z0 z1 : M.carrier),
    (chainAllTrue (Ps ++ [P])).holds M atomMap z0 z1 ↔
    ∃ c : M.carrier, z0 < c ∧ c < z1 ∧
      (chainAllTrue Ps).holds M atomMap z0 c ∧ P.eval_at M atomMap c := by
  induction Ps with
  | nil =>
    intro z0 z1
    rw [List.nil_append, chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨c, h1, h2, h3, _⟩
      exact ⟨c, h1, h2, chainAllTrue_nil_holds M atomMap z0 c, h3⟩
    · rintro ⟨c, h1, h2, _, h4⟩
      exact ⟨c, h1, h2, h4, chainAllTrue_nil_holds M atomMap c z1⟩
  | cons Q Ps' ih =>
    intro z0 z1
    rw [List.cons_append, chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨c, h1, h2, h3, h4⟩
      obtain ⟨d, hd1, hd2, hd3, hd4⟩ := (ih c z1).mp h4
      exact ⟨d, lt_trans h1 hd1, hd2,
        (chainAllTrue_cons_holds_iff M atomMap Q Ps' z0 d).mpr ⟨c, h1, hd1, h3, hd3⟩,
        hd4⟩
    · rintro ⟨d, hd1, hd2, hd3, hd4⟩
      obtain ⟨c, h1, h2, h3, h4⟩ :=
        (chainAllTrue_cons_holds_iff M atomMap Q Ps' z0 d).mp hd3
      exact ⟨c, h1, lt_trans h2 hd2, h3, (ih c z1).mpr ⟨d, h2, hd2, h4, hd4⟩⟩

/-- All-top chains are monotone in the left endpoint. -/
theorem chainAllTrue_holds_mono_left {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) {z0 z0' z1 : M.carrier} (h : z0' ≤ z0)
    (hch : (chainAllTrue Ps).holds M atomMap z0 z1) :
    (chainAllTrue Ps).holds M atomMap z0' z1 := by
  match Ps with
  | [] => exact chainAllTrue_nil_holds M atomMap z0' z1
  | P :: Ps' =>
    rw [chainAllTrue_cons_holds_iff] at hch ⊢
    obtain ⟨c, h1, h2, h3, h4⟩ := hch
    exact ⟨c, lt_of_le_of_lt h h1, h2, h3, h4⟩

/-- All-top chains are monotone in the right endpoint. -/
theorem chainAllTrue_holds_mono_right {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) : ∀ {z0 z1 z1' : M.carrier}, z1 ≤ z1' →
    (chainAllTrue Ps).holds M atomMap z0 z1 →
    (chainAllTrue Ps).holds M atomMap z0 z1' := by
  induction Ps with
  | nil =>
    intro z0 z1 z1' _ _
    exact chainAllTrue_nil_holds M atomMap z0 z1'
  | cons P Ps' ih =>
    intro z0 z1 z1' h hch
    rw [chainAllTrue_cons_holds_iff] at hch ⊢
    obtain ⟨c, h1, h2, h3, h4⟩ := hch
    exact ⟨c, h1, lt_of_lt_of_le h2 h, h3, ih le_rfl (ih h h4)⟩

/-! ## The Until fold (Cor 5.4(1)) -/

/-- Rabinovich's `F_i` fold: `untilFold [(α_0, β_1), …, (α_{n-1}, β_n)]` is
    `α_0 ∧ (β_1 Until (α_1 ∧ (β_2 Until … (α_{n-1} ∧ (β_n Until ⊤)))))`.
    Each pair is a bracket point type together with the segment type that
    follows it; the empty fold is `⊤` (the moved right endpoint carries no
    point type in this codebase's brackets). -/
def untilFold : List (TemporalPred × TemporalPred) → TemporalPred
  | [] => TemporalPred.top
  | (a, b) :: rest => a.conj (TemporalPred.untl (untilFold rest) b)

/-- The chain predicates `[F_1, …, F_{n+1}]` of Cor 5.4(1): the Until folds
    of all suffixes of the pair list (last entry `⊤`). -/
def untilChainPreds (ps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  ps.tails.map untilFold

theorem untilChainPreds_nil : untilChainPreds [] = [TemporalPred.top] := rfl

theorem untilChainPreds_cons (a b : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) :
    untilChainPreds ((a, b) :: ps) =
      untilFold ((a, b) :: ps) :: untilChainPreds ps := by
  simp [untilChainPreds]

/-! ## List-form brackets (prepend recursion) -/

/-- The bracket `[s, α_0, β_1, α_1, …, β_{n-1}, α_{n-1}, β_n]` built by
    repeated prepend from a leading segment type `s` and the pair list
    `[(α_0, β_1), …, (α_{n-1}, β_n)]` (each point type paired with the
    segment type after it). -/
def bracketOf (s : TemporalPred) :
    (ps : List (TemporalPred × TemporalPred)) → BracketFormula ps.length
  | [] => BracketFormula.trivial s
  | (a, b) :: rest => BracketFormula.prepend s a (bracketOf b rest)

theorem bracketOf_nil_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (z0 z1 : M.carrier) :
    (bracketOf s []).holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → s.eval_at M atomMap y :=
  BracketFormula.trivial_holds M atomMap s z0 z1

theorem bracketOf_cons_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s a b : TemporalPred) (ps : List (TemporalPred × TemporalPred))
    (z0 z1 : M.carrier) :
    (bracketOf s ((a, b) :: ps)).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r → s.eval_at M atomMap y) ∧
      a.eval_at M atomMap r ∧ (bracketOf b ps).holds M atomMap r z1 := by
  constructor
  · intro h
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ s a z0 z1 h
    exact ⟨r, h1, h2, h4, h3, h5⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact BracketFormula.prepend_holds M atomMap _ s a z0 z1 r h1 h2 h4 h3 h5

/-! ## Bridging arbitrary brackets to list form -/

/-- The fold pairs of a bracket: each point type with the segment type
    after it, in order. -/
def BracketFormula.foldPairs {n : Nat} (bf : BracketFormula n) :
    List (TemporalPred × TemporalPred) :=
  (List.finRange n).map fun i => (bf.pointTypes i, bf.segmentTypes i.succ)

/-- A bracket with `n + 1` points is the prepend of its head data onto its
    tail. -/
theorem BracketFormula.eq_prepend_tail {n : Nat} (bf : BracketFormula (n + 1)) :
    bf = BracketFormula.prepend (bf.segmentTypes ⟨0, Nat.succ_pos _⟩)
      (bf.pointTypes ⟨0, Nat.succ_pos _⟩) bf.tail := by
  cases bf with
  | mk pt st =>
    simp only [prepend, tail]
    congr 1
    · funext i
      obtain ⟨iv, hiv⟩ := i
      cases iv with
      | zero => rfl
      | succ k => rfl
    · funext i
      obtain ⟨iv, hiv⟩ := i
      cases iv with
      | zero => rfl
      | succ k => rfl

/-- Fold pairs of an `n + 1`-point bracket decompose as head pair plus the
    tail's fold pairs. -/
theorem BracketFormula.foldPairs_succ {n : Nat} (bf : BracketFormula (n + 1)) :
    bf.foldPairs =
      (bf.pointTypes ⟨0, Nat.succ_pos _⟩, bf.segmentTypes ⟨1, by omega⟩) ::
        bf.tail.foldPairs := by
  simp only [foldPairs, List.finRange_succ, List.map_cons, List.map_map, tail]
  refine congrArg₂ List.cons rfl ?_
  refine List.map_congr_left fun i _ => ?_
  refine congrArg₂ Prod.mk (congrArg bf.pointTypes (Fin.ext ?_))
    (congrArg bf.segmentTypes (Fin.ext ?_)) <;> simp [Fin.succ]

/-- **Bridge**: an arbitrary bracket holds iff its list form does. -/
theorem BracketFormula.holds_iff_bracketOf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    bf.holds M atomMap z0 z1 ↔
    (bracketOf (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) bf.foldPairs).holds
      M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf z0 z1
    have hfp : bf.foldPairs = [] := by simp [foldPairs]
    rw [hfp, bracketOf_nil_holds_iff]
    exact Iff.rfl
  | succ m ih =>
    intro bf z0 z1
    rw [foldPairs_succ, bracketOf_cons_holds_iff]
    conv_lhs => rw [eq_prepend_tail bf]
    constructor
    · intro h
      obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
        BracketFormula.prepend_holds_inv M atomMap _ _ _ z0 z1 h
      exact ⟨r, h1, h2, h4, h3, (ih bf.tail r z1).mp h5⟩
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 r h1 h2 h4 h3
        ((ih bf.tail r z1).mpr h5)

/-! ## Cor 5.4(1): the chain observation -/

/-- **Cor 5.4(1) chain observation** (Rabinovich chunk_0015 md:9-27,
    endpoint-free form): a bracket instance ending at some `z ∈ (z0, z1)`
    exists iff the head Until-fold `F̂ = s Until F_1` holds at `z0` and a
    pointwise increasing chain of the suffix folds exists in `(z0, z1)`.
    The ⇐ direction is the paper's induction with the Until-witness
    `y ≤ c / y > c` relink case split. -/
theorem exists_bracketOf_right_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧
        (bracketOf s ps).holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFold ps) s).eval_at M atomMap z0 ∧
       (chainAllTrue (untilChainPreds ps)).holds M atomMap z0 z1)) := by
  intro ps
  induction ps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [untilChainPreds_nil, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz0, TemporalPred.eval_at_top M atomMap z, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, TemporalPred.eval_at_top M atomMap z,
          chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy0, _, hyseg⟩, ⟨c, hc0, hc1, _, _⟩⟩
      rcases le_or_gt y c with h | h
      · exact ⟨y, hy0, lt_of_le_of_lt h hc1,
          (bracketOf_nil_holds_iff M atomMap s z0 y).mpr hyseg⟩
      · exact ⟨c, hc0, hc1,
          (bracketOf_nil_holds_iff M atomMap s z0 c).mpr
            (fun w h1 h2 => hyseg w h1 (lt_trans h2 h))⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [untilChainPreds_cons, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · -- bracket instance → F̂(z0) ∧ chain
      rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketOf_cons_holds_iff] at hz
      obtain ⟨r, hr0, hrz, hrseg, hra, hrtail⟩ := hz
      have h_rz1 : r < z1 := lt_trans hrz hz1
      obtain ⟨hFhat_r, hchain_rest⟩ :=
        (ih b r z1 h_rz1).mp ⟨z, hrz, hz1, hrtail⟩
      have hFr : (untilFold ((a, b) :: rest)).eval_at M atomMap r := by
        rw [show untilFold ((a, b) :: rest) =
              a.conj (TemporalPred.untl (untilFold rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hra, hFhat_r⟩
      exact ⟨⟨r, hr0, hFr, hrseg⟩,
        ⟨r, hr0, h_rz1, hFr, hchain_rest⟩⟩
    · -- F̂(z0) ∧ chain → bracket instance (the relink induction step)
      rintro ⟨⟨y, hy0, hyF, hyseg⟩, ⟨c, hc0, hc1, hcF, hcchain⟩⟩
      rw [show untilFold ((a, b) :: rest) =
            a.conj (TemporalPred.untl (untilFold rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyF hcF
      -- pick the first bracket witness r: y if y ≤ c, else c
      rcases le_or_gt y c with hyc | hcy
      · -- r := y (the Until witness is in bounds)
        have h_yz1 : y < z1 := lt_of_le_of_lt hyc hc1
        have hchain_y : (chainAllTrue (untilChainPreds rest)).holds M atomMap y z1 :=
          chainAllTrue_holds_mono_left M atomMap _ hyc hcchain
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b y z1 h_yz1).mpr ⟨hyF.2, hchain_y⟩
        exact ⟨z, lt_trans hy0 hz1, hz2,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨y, hy0, hz1, hyseg, hyF.1, hz3⟩⟩
      · -- r := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, z0 < w → w < c → s.eval_at M atomMap w :=
          fun w h1 h2 => hyseg w h1 (lt_trans h2 hcy)
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b c z1 hc1).mpr ⟨hcF.2, hcchain⟩
        exact ⟨z, lt_trans hc0 hz1, hz2,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨c, hc0, hz1, hcseg, hcF.1, hz3⟩⟩

/-! ## Cor 5.4(1): assembly -/

/-- Head decomposition of the chain-predicate list. -/
theorem untilChainPreds_head_cons (ps : List (TemporalPred × TemporalPred)) :
    ∃ L, untilChainPreds ps = untilFold ps :: L := by
  cases ps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨untilChainPreds rest, untilChainPreds_cons a b rest⟩

/-- The attained first-`¬s` pin disjunct of `negBoundedRightFix`: the bracket
    `[s ∧ ¬F₁, (¬s ∧ ¬F₁), ⊤]`. This is the interval form of Rabinovich's
    `¬F₀(z0)` endpoint disjunct: on attained-INF structures, `¬(s Until F₁)`
    at `z0` (with a chain point available) is witnessed by the attained first
    `¬s`-point, below and at which `F₁` fails. -/
def rightPinBracket (s F1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend (s.conj F1.neg) ((s.neg).conj F1.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Semantic characterization of the pin disjunct. -/
theorem rightPinBracket_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s F1 : TemporalPred) (z0 z1 : M.carrier) :
    (rightPinBracket s F1).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r →
        s.eval_at M atomMap y ∧ ¬F1.eval_at M atomMap y) ∧
      ¬s.eval_at M atomMap r ∧ ¬F1.eval_at M atomMap r := by
  unfold rightPinBracket
  constructor
  · intro h
    obtain ⟨r, h1, h2, h3, h4, _⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ z0 z1 h
    simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg'] at h3 h4
    exact ⟨r, h1, h2, fun y hy0 hy1 => h4 y hy0 hy1, h3.1, h3.2⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 r h1 h2 ?_ ?_ ?_
    · simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact ⟨h4, h5⟩
    · intro y hy0 hy1
      simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact h3 y hy0 hy1
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y

/-- **Cor 5.4(1), fixed formula** (Rabinovich 2014, chunk_0014 md:49): the
    V-bracket formula equivalent to `¬∃ z ∈ (z0, z1), bf.holds z0 z` on
    attained-INF structures. Disjuncts: the first-`¬β₀` pin plus the
    Lemma 5.3 chain negation `negChainOn [F₁, …, F_{n+1}]`. -/
def negBoundedRightFix {n : Nat} (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
        (untilFold bf.foldPairs)⟩ ::
    (negChainOn (untilChainPreds bf.foldPairs)).disjuncts⟩

/-- **Cor 5.4(1) iff**: on attained-INF structures, `negBoundedRightFix bf`
    holds on `(z0, z1)` iff no `z ∈ (z0, z1)` satisfies the bracket `bf` on
    `(z0, z)`. (Only attained infima are needed for this direction; the
    left mirror additionally consumes attained suprema.) -/
theorem negBoundedRightFix_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFix bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z := by
  -- Normalize the right side through the bridge and the chain observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFold bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).eval_at M atomMap z0 ∧
       (chainAllTrue (untilChainPreds bf.foldPairs)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, h3⟩
      exact (exists_bracketOf_right_iff M atomMap bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, h3⟩ := (exists_bracketOf_right_iff M atomMap bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mpr h3⟩
  constructor
  · -- some disjunct holds → no bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hFhat, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- pin disjunct
      subst heq
      obtain ⟨r, _h1, _h2, h3, h4, h5⟩ :=
        (rightPinBracket_holds_iff M atomMap _ _ z0 z1).mp hh
      rw [TemporalPred.eval_at_untl] at hFhat
      obtain ⟨y, hy0, hyF1, hyseg⟩ := hFhat
      rcases lt_trichotomy y r with hlt | heqq | hgt
      · exact (h3 y hy0 hlt).2 hyF1
      · exact h5 (heqq ▸ hyF1)
      · exact h4 (hyseg r _h1 hgt)
    · -- chain-negation disjunct
      exact (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (untilChainPreds bf.foldPairs)).holds M atomMap z0 z1
    · -- chain exists, so F̂ must fail at z0: build the pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      show (rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
          (untilFold bf.foldPairs)).holds M atomMap z0 z1
      rw [rightPinBracket_holds_iff]
      have hnFhat : ¬ (TemporalPred.untl (untilFold bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).eval_at M atomMap z0 :=
        fun hFhat => hnex (h_rhs.mpr ⟨hFhat, hchain⟩)
      have h_no : ∀ y : M.carrier, z0 < y →
          (untilFold bf.foldPairs).eval_at M atomMap y →
          ¬(∀ w : M.carrier, z0 < w → w < y →
            (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap w) :=
        fun y hy0 hyF hseg => hnFhat
          ((TemporalPred.eval_at_untl M atomMap _ _ z0).mpr ⟨y, hy0, hyF, hseg⟩)
      -- first chain point c carries F₁
      obtain ⟨L, hL⟩ := untilChainPreds_head_cons bf.foldPairs
      rw [hL, chainAllTrue_cons_holds_iff] at hchain
      obtain ⟨c, hc0, hc1, hcF1, -⟩ := hchain
      -- ¬β₀ occurs below c (else y := c would witness F̂)
      have h_fail : ∃ w : M.carrier, z0 < w ∧ w < c ∧
          ¬(bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap w := by
        by_contra hcon
        push_neg at hcon
        exact h_no c hc0 hcF1 hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0first⟩ :=
        h_INF.first_occ_tp (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).neg z0 z1 h_lt
          ⟨w0, hw1, lt_trans hw2 hc1,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_before : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap y := by
        intro y hy0 hy1
        have := hr0first y hy0 hy1
        rw [TemporalPred.eval_at_neg'] at this
        exact not_not.mp this
      refine ⟨r0, hr00, hr01, ?_, ?_, ?_⟩
      · intro y hy0 hy1
        refine ⟨hs_before y hy0 hy1, fun hF1y => ?_⟩
        exact h_no y hy0 hF1y (fun w h1 h2 => hs_before w h1 (lt_trans h2 hy1))
      · exact (TemporalPred.eval_at_neg' M atomMap _ r0).mp hr0neg
      · exact fun hF1r0 => h_no r0 hr00 hF1r0 hs_before
    · -- chain fails: the Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! ## The Since fold (Cor 5.4(2), the mirror) -/

/-- The Since mirror of `untilFold`: `sinceFold [(α_{n-1}, β_{n-1}), …,
    (α_0, β_0)]` is `α_{n-1} ∧ (β_{n-1} Since (α_{n-2} ∧ (… ∧ (β_0 Since
    ⊤))))`. Each pair is a bracket point type together with the segment type
    that precedes it, consumed right-to-left. -/
def sinceFold : List (TemporalPred × TemporalPred) → TemporalPred
  | [] => TemporalPred.top
  | (a, b) :: rest => a.conj (TemporalPred.snce (sinceFold rest) b)

/-- The chain predicates `[G_1, …, G_{n+1}]` of Cor 5.4(2): the Since folds
    of all suffixes of the reversed pair list, in increasing chain order
    (first entry `⊤`). -/
def sinceChainPreds (mps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  (mps.tails.map sinceFold).reverse

theorem sinceChainPreds_nil : sinceChainPreds [] = [TemporalPred.top] := rfl

theorem sinceChainPreds_cons (a b : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) :
    sinceChainPreds ((a, b) :: mps) =
      sinceChainPreds mps ++ [sinceFold ((a, b) :: mps)] := by
  simp [sinceChainPreds]

/-- Last-element decomposition of the mirror chain-predicate list. -/
theorem sinceChainPreds_last_snoc (mps : List (TemporalPred × TemporalPred)) :
    ∃ L, sinceChainPreds mps = L ++ [sinceFold mps] := by
  cases mps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨sinceChainPreds rest, sinceChainPreds_cons a b rest⟩

/-! ## List-form brackets (snoc recursion) -/

/-- The bracket `[β_0, α_0, β_1, …, α_{n-1}, s]` built by repeated snoc from
    a trailing segment type `s` and the reversed pair list
    `[(α_{n-1}, β_{n-1}), …, (α_0, β_0)]` (each point type paired with the
    segment type before it). -/
def bracketSnocOf (s : TemporalPred) :
    (mps : List (TemporalPred × TemporalPred)) → BracketFormula mps.length
  | [] => BracketFormula.trivial s
  | (a, b) :: rest => (bracketSnocOf b rest).snoc a s

theorem bracketSnocOf_nil_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (z0 z1 : M.carrier) :
    (bracketSnocOf s []).holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → s.eval_at M atomMap y :=
  BracketFormula.trivial_holds M atomMap s z0 z1

theorem bracketSnocOf_cons_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s a b : TemporalPred) (mps : List (TemporalPred × TemporalPred))
    (z0 z1 : M.carrier) :
    (bracketSnocOf s ((a, b) :: mps)).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
      (bracketSnocOf b mps).holds M atomMap z0 x ∧
      a.eval_at M atomMap x ∧
      ∀ y : M.carrier, x < y → y < z1 → s.eval_at M atomMap y :=
  BracketFormula.snoc_holds_iff M atomMap (bracketSnocOf b mps) a s z0 z1

/-! ## Bridging arbitrary brackets to snoc-list form -/

/-- The reversed fold pairs of a bracket: each point type with the segment
    type before it, from the last point down to the first. Defined by
    recursion through `front` so its cons unfolding is definitional. -/
def BracketFormula.foldPairsRev :
    {n : Nat} → BracketFormula n → List (TemporalPred × TemporalPred)
  | 0, _ => []
  | n + 1, bf =>
    (bf.pointTypes ⟨n, Nat.lt_succ_self n⟩, bf.segmentTypes ⟨n, by omega⟩) ::
      bf.front.foldPairsRev

/-- **Mirror bridge**: an arbitrary bracket holds iff its snoc-list form
    does. -/
theorem BracketFormula.holds_iff_bracketSnocOf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    bf.holds M atomMap z0 z1 ↔
    (bracketSnocOf (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
      bf.foldPairsRev).holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf z0 z1
    rw [show bf.foldPairsRev = [] from rfl, bracketSnocOf_nil_holds_iff]
    exact Iff.rfl
  | succ m ih =>
    intro bf z0 z1
    rw [show bf.foldPairsRev =
          (bf.pointTypes ⟨m, Nat.lt_succ_self m⟩,
           bf.segmentTypes ⟨m, by omega⟩) :: bf.front.foldPairsRev from rfl,
      bracketSnocOf_cons_holds_iff,
      BracketFormula.holds_succ_iff]
    constructor
    · rintro ⟨x, h1, h2, h3, h4, h5⟩
      exact ⟨x, h1, h2, (ih bf.front z0 x).mp h3, h4, h5⟩
    · rintro ⟨x, h1, h2, h3, h4, h5⟩
      exact ⟨x, h1, h2, (ih bf.front z0 x).mpr h3, h4, h5⟩

/-! ## Cor 5.4(2): the mirror chain observation -/

/-- **Cor 5.4(2) chain observation** (mirror of
    `exists_bracketOf_right_iff`): a bracket instance starting at some
    `z ∈ (z0, z1)` exists iff the trailing Since-fold `Ĝ = s Since G` holds
    at `z1` and a pointwise increasing chain of the mirror folds exists in
    `(z0, z1)`. The ⇐ direction is the mirrored relink induction with the
    Since-witness `c ≤ y / y < c` case split. -/
theorem exists_bracketSnocOf_left_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (mps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧
        (bracketSnocOf s mps).holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFold mps) s).eval_at M atomMap z1 ∧
       (chainAllTrue (sinceChainPreds mps)).holds M atomMap z0 z1)) := by
  intro mps
  induction mps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [sinceChainPreds_nil, TemporalPred.eval_at_snce,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketSnocOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz1, TemporalPred.eval_at_top M atomMap z, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, TemporalPred.eval_at_top M atomMap z,
          chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy1, _, hyseg⟩, ⟨c, hc0, hc1, _, _⟩⟩
      rcases le_or_gt c y with h | h
      · exact ⟨y, lt_of_lt_of_le hc0 h, hy1,
          (bracketSnocOf_nil_holds_iff M atomMap s y z1).mpr hyseg⟩
      · exact ⟨c, hc0, hc1,
          (bracketSnocOf_nil_holds_iff M atomMap s c z1).mpr
            (fun w h1 h2 => hyseg w (lt_trans h h1) h2)⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [TemporalPred.eval_at_snce, sinceChainPreds_cons]
    constructor
    · -- bracket instance → Ĝ(z1) ∧ chain
      rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketSnocOf_cons_holds_iff] at hz
      obtain ⟨x, hzx, hxz1, hxfront, hxa, hxseg⟩ := hz
      have h_z0x : z0 < x := lt_trans hz0 hzx
      obtain ⟨hGhat_x, hchain_rest⟩ :=
        (ih b z0 x h_z0x).mp ⟨z, hz0, hzx, hxfront⟩
      have hGx : (sinceFold ((a, b) :: rest)).eval_at M atomMap x := by
        rw [show sinceFold ((a, b) :: rest) =
              a.conj (TemporalPred.snce (sinceFold rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hxa, hGhat_x⟩
      exact ⟨⟨x, hxz1, hGx, hxseg⟩,
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mpr
          ⟨x, h_z0x, hxz1, hchain_rest, hGx⟩⟩
    · -- Ĝ(z1) ∧ chain → bracket instance (the mirrored relink step)
      rintro ⟨⟨y, hy1, hyG, hyseg⟩, hchain⟩
      obtain ⟨c, hc0, hc1, hcchain, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mp hchain
      rw [show sinceFold ((a, b) :: rest) =
            a.conj (TemporalPred.snce (sinceFold rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyG hcG
      rcases le_or_gt c y with hcy | hyc
      · -- x := y (the Since witness is in bounds)
        have h_z0y : z0 < y := lt_of_lt_of_le hc0 hcy
        have hchain_y : (chainAllTrue (sinceChainPreds rest)).holds M atomMap z0 y :=
          chainAllTrue_holds_mono_right M atomMap _ hcy hcchain
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b z0 y h_z0y).mpr ⟨hyG.2, hchain_y⟩
        exact ⟨z, hz1, lt_trans hz2 hy1,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨y, hz2, hy1, hz3, hyG.1, hyseg⟩⟩
      · -- x := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, c < w → w < z1 → s.eval_at M atomMap w :=
          fun w h1 h2 => hyseg w (lt_trans hyc h1) h2
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b z0 c hc0).mpr ⟨hcG.2, hcchain⟩
        exact ⟨z, hz1, lt_trans hz2 hc1,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨c, hz2, hc1, hz3, hcG.1, hcseg⟩⟩

/-! ## Cor 5.4(2): assembly -/

/-- The attained last-`¬s` pin disjunct of `negBoundedLeftFix`: the bracket
    `[⊤, (¬s ∧ ¬G), s ∧ ¬G]`. Mirror of `rightPinBracket`, witnessed by the
    attained last `¬s`-point (`HasAttainedSUP`), above and at which `G`
    fails. -/
def leftPinBracket (s G : TemporalPred) : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc
    ((s.neg).conj G.neg) (s.conj G.neg)

/-- Semantic characterization of the mirror pin disjunct. -/
theorem leftPinBracket_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s G : TemporalPred) (z0 z1 : M.carrier) :
    (leftPinBracket s G).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      ¬s.eval_at M atomMap r ∧ ¬G.eval_at M atomMap r ∧
      (∀ y : M.carrier, r < y → y < z1 →
        s.eval_at M atomMap y ∧ ¬G.eval_at M atomMap y) := by
  unfold leftPinBracket
  rw [BracketFormula.snoc_holds_iff]
  constructor
  · rintro ⟨r, h1, h2, _, h4, h5⟩
    simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg'] at h4 h5
    exact ⟨r, h1, h2, h4.1, h4.2, fun y hy0 hy1 => h5 y hy0 hy1⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    refine ⟨r, h1, h2, ?_, ?_, ?_⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
    · simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact ⟨h3, h4⟩
    · intro y hy0 hy1
      simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact h5 y hy0 hy1

/-- **Cor 5.4(2), fixed formula** (Rabinovich 2014, chunk_0015 md:43): the
    V-bracket formula equivalent to `¬∃ z ∈ (z0, z1), bf.holds z z1`.
    Mirror of `negBoundedRightFix`: last-`¬β_n` pin plus the Lemma 5.3
    chain negation over the Since folds. -/
def negBoundedLeftFix {n : Nat} (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
        (sinceFold bf.foldPairsRev)⟩ ::
    (negChainOn (sinceChainPreds bf.foldPairsRev)).disjuncts⟩

/-- **Cor 5.4(2) iff**: on structures with attained infima AND suprema,
    `negBoundedLeftFix bf` holds on `(z0, z1)` iff no `z ∈ (z0, z1)`
    satisfies the bracket `bf` on `(z, z1)`. The last-occurrence walk of the
    pin disjunct consumes `HasAttainedSUP` (task 350 Phase 8); the Lemma 5.3
    chain negation still consumes `HasAttainedINF`. -/
theorem negBoundedLeftFix_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFix bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1 := by
  -- Normalize the right side through the mirror bridge and chain observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFold bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).eval_at M atomMap z1 ∧
       (chainAllTrue (sinceChainPreds bf.foldPairsRev)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, h3⟩
      exact (exists_bracketSnocOf_left_iff M atomMap bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, h3⟩ := (exists_bracketSnocOf_left_iff M atomMap bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2,
        (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mpr h3⟩
  constructor
  · -- some disjunct holds → no bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hGhat, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- pin disjunct
      subst heq
      obtain ⟨r, _h1, _h2, h3, h4, h5⟩ :=
        (leftPinBracket_holds_iff M atomMap _ _ z0 z1).mp hh
      rw [TemporalPred.eval_at_snce] at hGhat
      obtain ⟨y, hy1, hyG, hyseg⟩ := hGhat
      rcases lt_trichotomy r y with hlt | heqq | hgt
      · exact (h5 y hlt hy1).2 hyG
      · exact h4 (heqq ▸ hyG)
      · exact h3 (hyseg r hgt _h2)
    · -- chain-negation disjunct
      exact (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (sinceChainPreds bf.foldPairsRev)).holds M atomMap z0 z1
    · -- chain exists, so Ĝ must fail at z1: build the mirror pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      show (leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
          (sinceFold bf.foldPairsRev)).holds M atomMap z0 z1
      rw [leftPinBracket_holds_iff]
      have hnGhat : ¬ (TemporalPred.snce (sinceFold bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).eval_at M atomMap z1 :=
        fun hGhat => hnex (h_rhs.mpr ⟨hGhat, hchain⟩)
      have h_no : ∀ y : M.carrier, y < z1 →
          (sinceFold bf.foldPairsRev).eval_at M atomMap y →
          ¬(∀ w : M.carrier, y < w → w < z1 →
            (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap w) :=
        fun y hy1 hyG hseg => hnGhat
          ((TemporalPred.eval_at_snce M atomMap _ _ z1).mpr ⟨y, hy1, hyG, hseg⟩)
      -- last chain point c carries G
      obtain ⟨L, hL⟩ := sinceChainPreds_last_snoc bf.foldPairsRev
      rw [hL] at hchain
      obtain ⟨c, hc0, hc1, -, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap L _ z0 z1).mp hchain
      -- ¬β_n occurs above c (else y := c would witness Ĝ)
      have h_fail : ∃ w : M.carrier, c < w ∧ w < z1 ∧
          ¬(bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap w := by
        by_contra hcon
        push_neg at hcon
        exact h_no c hc1 hcG hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0last⟩ :=
        h_SUP.last_occ_tp (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).neg z0 z1 h_lt
          ⟨w0, lt_trans hc0 hw1, hw2,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_after : ∀ y : M.carrier, r0 < y → y < z1 →
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap y := by
        intro y hy0 hy1
        have := hr0last y hy0 hy1
        rw [TemporalPred.eval_at_neg'] at this
        exact not_not.mp this
      refine ⟨r0, hr00, hr01, ?_, ?_, ?_⟩
      · exact (TemporalPred.eval_at_neg' M atomMap _ r0).mp hr0neg
      · exact fun hGr0 => h_no r0 hr01 hGr0 hs_after
      · intro y hy0 hy1
        refine ⟨hs_after y hy0 hy1, fun hGy => ?_⟩
        exact h_no y hy1 hGy (fun w h1 h2 => hs_after w (lt_trans hy0 h1) h2)
    · -- chain fails: the Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! # Anchored Corollary 5.4 mirrors (task 350 Phase 10b-i)

Case 2 of the fixed-formula negation recursion (`BracketFormula.negFix`,
Phase 10b) peels the outermost point type `α` of a bracket, leaving the shape
`¬∃ z ∈ (z0, z1), α(z) ∧ peeled.holds … z0 z` — the peeled point type sits AT
the moving endpoint, and no plain bracket expresses a point type at its own
endpoint (machine-refuted on discrete carriers; Phase 10a handoff, design
note 1). The fix is the ANCHORED generalization of the Phase 9 Cor 5.4
machinery: parametrize the innermost fold goal of `untilFold`/`sinceFold` by
the peeled point type `α` (the Phase 9 code is the `α := ⊤` instance), with
the suffix-fold chain predicates carrying `α` as their last entry. The
paper's relink case split (`y ≤ c / y > c`) survives unchanged with the
anchor. Base case: `∃ z ∈ (z0, z1), α(z) ∧ (β on (z0, z))  ⟺
(β Until α)(z0) ∧ ∃ c ∈ (z0, z1), α(c)`. -/

/-! ## The anchored Until fold -/

/-- Anchored `untilFold`: `untilFoldAnchored α [(α_0, β_1), …, (α_{n-1}, β_n)]`
    is `α_0 ∧ (β_1 Until (α_1 ∧ (… ∧ (β_n Until α))))` — the innermost goal
    is the anchor `α` instead of `⊤`, so the moved right endpoint carries the
    peeled point type. `untilFold` is the `α := ⊤` instance constructor by
    constructor. -/
def untilFoldAnchored (α : TemporalPred) :
    List (TemporalPred × TemporalPred) → TemporalPred
  | [] => α
  | (a, b) :: rest => a.conj (TemporalPred.untl (untilFoldAnchored α rest) b)

/-- Anchored chain predicates `[F_1, …, F_{n+1}]`: the anchored Until folds
    of all suffixes of the pair list (last entry the anchor `α`). -/
def untilChainPredsAnchored (α : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  ps.tails.map (untilFoldAnchored α)

theorem untilChainPredsAnchored_nil (α : TemporalPred) :
    untilChainPredsAnchored α [] = [α] := rfl

theorem untilChainPredsAnchored_cons (α a b : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) :
    untilChainPredsAnchored α ((a, b) :: ps) =
      untilFoldAnchored α ((a, b) :: ps) :: untilChainPredsAnchored α ps := by
  simp [untilChainPredsAnchored]

/-! ## Anchored Cor 5.4(1): the chain observation -/

/-- **Anchored Cor 5.4(1) chain observation**: a bracket instance ending at
    an `α`-point `z ∈ (z0, z1)` exists iff the head anchored Until-fold
    `F̂ = s Until F_1` holds at `z0` and a pointwise increasing chain of the
    anchored suffix folds exists in `(z0, z1)`. The `α := ⊤` instance is
    `exists_bracketOf_right_iff`; the relink `y ≤ c / y > c` case split is
    unchanged — the anchor rides in the fold goals and the chain entries. -/
theorem exists_bracketOf_right_anchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (α : TemporalPred) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
        (bracketOf s ps).holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFoldAnchored α ps) s).eval_at M atomMap z0 ∧
       (chainAllTrue (untilChainPredsAnchored α ps)).holds M atomMap z0 z1)) := by
  intro ps
  induction ps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [untilChainPredsAnchored_nil, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz0, hzα, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, hzα, chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy0, hyα, hyseg⟩, ⟨c, hc0, hc1, hcα, _⟩⟩
      rcases le_or_gt y c with h | h
      · exact ⟨y, hy0, lt_of_le_of_lt h hc1, hyα,
          (bracketOf_nil_holds_iff M atomMap s z0 y).mpr hyseg⟩
      · exact ⟨c, hc0, hc1, hcα,
          (bracketOf_nil_holds_iff M atomMap s z0 c).mpr
            (fun w h1 h2 => hyseg w h1 (lt_trans h2 h))⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [untilChainPredsAnchored_cons, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · -- α-anchored bracket instance → F̂(z0) ∧ chain
      rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketOf_cons_holds_iff] at hz
      obtain ⟨r, hr0, hrz, hrseg, hra, hrtail⟩ := hz
      have h_rz1 : r < z1 := lt_trans hrz hz1
      obtain ⟨hFhat_r, hchain_rest⟩ :=
        (ih b r z1 h_rz1).mp ⟨z, hrz, hz1, hzα, hrtail⟩
      have hFr : (untilFoldAnchored α ((a, b) :: rest)).eval_at M atomMap r := by
        rw [show untilFoldAnchored α ((a, b) :: rest) =
              a.conj (TemporalPred.untl (untilFoldAnchored α rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hra, hFhat_r⟩
      exact ⟨⟨r, hr0, hFr, hrseg⟩,
        ⟨r, hr0, h_rz1, hFr, hchain_rest⟩⟩
    · -- F̂(z0) ∧ chain → α-anchored bracket instance (the relink step)
      rintro ⟨⟨y, hy0, hyF, hyseg⟩, ⟨c, hc0, hc1, hcF, hcchain⟩⟩
      rw [show untilFoldAnchored α ((a, b) :: rest) =
            a.conj (TemporalPred.untl (untilFoldAnchored α rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyF hcF
      -- pick the first bracket witness r: y if y ≤ c, else c
      rcases le_or_gt y c with hyc | hcy
      · -- r := y (the Until witness is in bounds)
        have h_yz1 : y < z1 := lt_of_le_of_lt hyc hc1
        have hchain_y :
            (chainAllTrue (untilChainPredsAnchored α rest)).holds M atomMap y z1 :=
          chainAllTrue_holds_mono_left M atomMap _ hyc hcchain
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b y z1 h_yz1).mpr ⟨hyF.2, hchain_y⟩
        exact ⟨z, lt_trans hy0 hz1, hz2, hzα,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨y, hy0, hz1, hyseg, hyF.1, hz3⟩⟩
      · -- r := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, z0 < w → w < c → s.eval_at M atomMap w :=
          fun w h1 h2 => hyseg w h1 (lt_trans h2 hcy)
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b c z1 hc1).mpr ⟨hcF.2, hcchain⟩
        exact ⟨z, lt_trans hc0 hz1, hz2, hzα,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨c, hc0, hz1, hcseg, hcF.1, hz3⟩⟩

/-! ## Anchored Cor 5.4(1): assembly -/

/-- Head decomposition of the anchored chain-predicate list. -/
theorem untilChainPredsAnchored_head_cons (α : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) :
    ∃ L, untilChainPredsAnchored α ps = untilFoldAnchored α ps :: L := by
  cases ps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨untilChainPredsAnchored α rest, untilChainPredsAnchored_cons α a b rest⟩

/-- **Anchored Cor 5.4(1), fixed formula**: the V-bracket formula equivalent
    to `¬∃ z ∈ (z0, z1), α(z) ∧ bf.holds z0 z` on attained-INF structures.
    Same disjunct shape as `negBoundedRightFix` (= the `α := ⊤` instance):
    the first-`¬β₀` pin plus the Lemma 5.3 chain negation, both over the
    anchored folds. -/
def negBoundedRightFixAnchored (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
        (untilFoldAnchored α bf.foldPairs)⟩ ::
    (negChainOn (untilChainPredsAnchored α bf.foldPairs)).disjuncts⟩

/-- **Anchored Cor 5.4(1) iff**: on attained-INF structures,
    `negBoundedRightFixAnchored α bf` holds on `(z0, z1)` iff no `α`-point
    `z ∈ (z0, z1)` satisfies the bracket `bf` on `(z0, z)`. This is the
    Case 2 consumer shape for `BracketFormula.negFix` (Phase 10b-ii). -/
theorem negBoundedRightFixAnchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFixAnchored α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z0 z := by
  -- Normalize the right side through the bridge and the anchored chain
  -- observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFoldAnchored α bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).eval_at M atomMap z0 ∧
       (chainAllTrue (untilChainPredsAnchored α bf.foldPairs)).holds
          M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, hα, h3⟩
      exact (exists_bracketOf_right_anchored_iff M atomMap α bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, hα,
          (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, hα, h3⟩ :=
        (exists_bracketOf_right_anchored_iff M atomMap α bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, hα,
        (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mpr h3⟩
  constructor
  · -- some disjunct holds → no anchored bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hFhat, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- pin disjunct
      subst heq
      obtain ⟨r, _h1, _h2, h3, h4, h5⟩ :=
        (rightPinBracket_holds_iff M atomMap _ _ z0 z1).mp hh
      rw [TemporalPred.eval_at_untl] at hFhat
      obtain ⟨y, hy0, hyF1, hyseg⟩ := hFhat
      rcases lt_trichotomy y r with hlt | heqq | hgt
      · exact (h3 y hy0 hlt).2 hyF1
      · exact h5 (heqq ▸ hyF1)
      · exact h4 (hyseg r _h1 hgt)
    · -- chain-negation disjunct
      exact (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no anchored bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (untilChainPredsAnchored α bf.foldPairs)).holds M atomMap z0 z1
    · -- chain exists, so F̂ must fail at z0: build the pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      show (rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
          (untilFoldAnchored α bf.foldPairs)).holds M atomMap z0 z1
      rw [rightPinBracket_holds_iff]
      have hnFhat : ¬ (TemporalPred.untl (untilFoldAnchored α bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).eval_at M atomMap z0 :=
        fun hFhat => hnex (h_rhs.mpr ⟨hFhat, hchain⟩)
      have h_no : ∀ y : M.carrier, z0 < y →
          (untilFoldAnchored α bf.foldPairs).eval_at M atomMap y →
          ¬(∀ w : M.carrier, z0 < w → w < y →
            (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap w) :=
        fun y hy0 hyF hseg => hnFhat
          ((TemporalPred.eval_at_untl M atomMap _ _ z0).mpr ⟨y, hy0, hyF, hseg⟩)
      -- first chain point c carries F₁
      obtain ⟨L, hL⟩ := untilChainPredsAnchored_head_cons α bf.foldPairs
      rw [hL, chainAllTrue_cons_holds_iff] at hchain
      obtain ⟨c, hc0, hc1, hcF1, -⟩ := hchain
      -- ¬β₀ occurs below c (else y := c would witness F̂)
      have h_fail : ∃ w : M.carrier, z0 < w ∧ w < c ∧
          ¬(bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap w := by
        by_contra hcon
        push_neg at hcon
        exact h_no c hc0 hcF1 hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0first⟩ :=
        h_INF.first_occ_tp (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).neg z0 z1 h_lt
          ⟨w0, hw1, lt_trans hw2 hc1,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_before : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap y := by
        intro y hy0 hy1
        have := hr0first y hy0 hy1
        rw [TemporalPred.eval_at_neg'] at this
        exact not_not.mp this
      refine ⟨r0, hr00, hr01, ?_, ?_, ?_⟩
      · intro y hy0 hy1
        refine ⟨hs_before y hy0 hy1, fun hF1y => ?_⟩
        exact h_no y hy0 hF1y (fun w h1 h2 => hs_before w h1 (lt_trans h2 hy1))
      · exact (TemporalPred.eval_at_neg' M atomMap _ r0).mp hr0neg
      · exact fun hF1r0 => h_no r0 hr00 hF1r0 hs_before
    · -- chain fails: the Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! ## The anchored Since fold (the mirror) -/

/-- Anchored `sinceFold`: the innermost goal is the anchor `α` instead of
    `⊤`, so the moved left endpoint carries the peeled point type. -/
def sinceFoldAnchored (α : TemporalPred) :
    List (TemporalPred × TemporalPred) → TemporalPred
  | [] => α
  | (a, b) :: rest => a.conj (TemporalPred.snce (sinceFoldAnchored α rest) b)

/-- Anchored mirror chain predicates: the anchored Since folds of all
    suffixes of the reversed pair list, in increasing chain order (first
    entry the anchor `α`). -/
def sinceChainPredsAnchored (α : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  (mps.tails.map (sinceFoldAnchored α)).reverse

theorem sinceChainPredsAnchored_nil (α : TemporalPred) :
    sinceChainPredsAnchored α [] = [α] := rfl

theorem sinceChainPredsAnchored_cons (α a b : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) :
    sinceChainPredsAnchored α ((a, b) :: mps) =
      sinceChainPredsAnchored α mps ++ [sinceFoldAnchored α ((a, b) :: mps)] := by
  simp [sinceChainPredsAnchored]

/-- Last-element decomposition of the anchored mirror chain-predicate
    list. -/
theorem sinceChainPredsAnchored_last_snoc (α : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) :
    ∃ L, sinceChainPredsAnchored α mps = L ++ [sinceFoldAnchored α mps] := by
  cases mps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨sinceChainPredsAnchored α rest, sinceChainPredsAnchored_cons α a b rest⟩

/-! ## Anchored Cor 5.4(2): the mirror chain observation -/

/-- **Anchored Cor 5.4(2) chain observation**: a bracket instance starting
    at an `α`-point `z ∈ (z0, z1)` exists iff the trailing anchored
    Since-fold `Ĝ = s Since G` holds at `z1` and a pointwise increasing
    chain of the anchored mirror folds exists in `(z0, z1)`. The `α := ⊤`
    instance is `exists_bracketSnocOf_left_iff`. -/
theorem exists_bracketSnocOf_left_anchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (α : TemporalPred) :
    ∀ (mps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
        (bracketSnocOf s mps).holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFoldAnchored α mps) s).eval_at M atomMap z1 ∧
       (chainAllTrue (sinceChainPredsAnchored α mps)).holds M atomMap z0 z1)) := by
  intro mps
  induction mps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [sinceChainPredsAnchored_nil, TemporalPred.eval_at_snce,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketSnocOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz1, hzα, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, hzα, chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy1, hyα, hyseg⟩, ⟨c, hc0, hc1, hcα, _⟩⟩
      rcases le_or_gt c y with h | h
      · exact ⟨y, lt_of_lt_of_le hc0 h, hy1, hyα,
          (bracketSnocOf_nil_holds_iff M atomMap s y z1).mpr hyseg⟩
      · exact ⟨c, hc0, hc1, hcα,
          (bracketSnocOf_nil_holds_iff M atomMap s c z1).mpr
            (fun w h1 h2 => hyseg w (lt_trans h h1) h2)⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [TemporalPred.eval_at_snce, sinceChainPredsAnchored_cons]
    constructor
    · -- α-anchored bracket instance → Ĝ(z1) ∧ chain
      rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketSnocOf_cons_holds_iff] at hz
      obtain ⟨x, hzx, hxz1, hxfront, hxa, hxseg⟩ := hz
      have h_z0x : z0 < x := lt_trans hz0 hzx
      obtain ⟨hGhat_x, hchain_rest⟩ :=
        (ih b z0 x h_z0x).mp ⟨z, hz0, hzx, hzα, hxfront⟩
      have hGx : (sinceFoldAnchored α ((a, b) :: rest)).eval_at M atomMap x := by
        rw [show sinceFoldAnchored α ((a, b) :: rest) =
              a.conj (TemporalPred.snce (sinceFoldAnchored α rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hxa, hGhat_x⟩
      exact ⟨⟨x, hxz1, hGx, hxseg⟩,
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mpr
          ⟨x, h_z0x, hxz1, hchain_rest, hGx⟩⟩
    · -- Ĝ(z1) ∧ chain → α-anchored bracket instance (the mirrored relink)
      rintro ⟨⟨y, hy1, hyG, hyseg⟩, hchain⟩
      obtain ⟨c, hc0, hc1, hcchain, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mp hchain
      rw [show sinceFoldAnchored α ((a, b) :: rest) =
            a.conj (TemporalPred.snce (sinceFoldAnchored α rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyG hcG
      rcases le_or_gt c y with hcy | hyc
      · -- x := y (the Since witness is in bounds)
        have h_z0y : z0 < y := lt_of_lt_of_le hc0 hcy
        have hchain_y :
            (chainAllTrue (sinceChainPredsAnchored α rest)).holds M atomMap z0 y :=
          chainAllTrue_holds_mono_right M atomMap _ hcy hcchain
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b z0 y h_z0y).mpr ⟨hyG.2, hchain_y⟩
        exact ⟨z, hz1, lt_trans hz2 hy1, hzα,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨y, hz2, hy1, hz3, hyG.1, hyseg⟩⟩
      · -- x := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, c < w → w < z1 → s.eval_at M atomMap w :=
          fun w h1 h2 => hyseg w (lt_trans hyc h1) h2
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b z0 c hc0).mpr ⟨hcG.2, hcchain⟩
        exact ⟨z, hz1, lt_trans hz2 hc1, hzα,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨c, hz2, hc1, hz3, hcG.1, hcseg⟩⟩

/-! ## Anchored Cor 5.4(2): assembly -/

/-- **Anchored Cor 5.4(2), fixed formula**: the V-bracket formula equivalent
    to `¬∃ z ∈ (z0, z1), α(z) ∧ bf.holds z z1`. Mirror of
    `negBoundedRightFixAnchored`: last-`¬β_n` pin plus the Lemma 5.3 chain
    negation over the anchored Since folds. -/
def negBoundedLeftFixAnchored (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
        (sinceFoldAnchored α bf.foldPairsRev)⟩ ::
    (negChainOn (sinceChainPredsAnchored α bf.foldPairsRev)).disjuncts⟩

/-- **Anchored Cor 5.4(2) iff**: on structures with attained infima AND
    suprema, `negBoundedLeftFixAnchored α bf` holds on `(z0, z1)` iff no
    `α`-point `z ∈ (z0, z1)` satisfies the bracket `bf` on `(z, z1)`. This
    is the mirror Case 2 consumer shape for `BracketFormula.negFix`
    (Phase 10b-ii). -/
theorem negBoundedLeftFixAnchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFixAnchored α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z z1 := by
  -- Normalize the right side through the mirror bridge and the anchored
  -- mirror chain observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFoldAnchored α bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).eval_at M atomMap z1 ∧
       (chainAllTrue (sinceChainPredsAnchored α bf.foldPairsRev)).holds
          M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, hα, h3⟩
      exact (exists_bracketSnocOf_left_anchored_iff M atomMap α bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, hα,
          (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, hα, h3⟩ :=
        (exists_bracketSnocOf_left_anchored_iff M atomMap α bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, hα,
        (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mpr h3⟩
  constructor
  · -- some disjunct holds → no anchored bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hGhat, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- pin disjunct
      subst heq
      obtain ⟨r, _h1, _h2, h3, h4, h5⟩ :=
        (leftPinBracket_holds_iff M atomMap _ _ z0 z1).mp hh
      rw [TemporalPred.eval_at_snce] at hGhat
      obtain ⟨y, hy1, hyG, hyseg⟩ := hGhat
      rcases lt_trichotomy r y with hlt | heqq | hgt
      · exact (h5 y hlt hy1).2 hyG
      · exact h4 (heqq ▸ hyG)
      · exact h3 (hyseg r hgt _h2)
    · -- chain-negation disjunct
      exact (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no anchored bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (sinceChainPredsAnchored α bf.foldPairsRev)).holds
        M atomMap z0 z1
    · -- chain exists, so Ĝ must fail at z1: build the mirror pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      show (leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
          (sinceFoldAnchored α bf.foldPairsRev)).holds M atomMap z0 z1
      rw [leftPinBracket_holds_iff]
      have hnGhat : ¬ (TemporalPred.snce (sinceFoldAnchored α bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).eval_at M atomMap z1 :=
        fun hGhat => hnex (h_rhs.mpr ⟨hGhat, hchain⟩)
      have h_no : ∀ y : M.carrier, y < z1 →
          (sinceFoldAnchored α bf.foldPairsRev).eval_at M atomMap y →
          ¬(∀ w : M.carrier, y < w → w < z1 →
            (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap w) :=
        fun y hy1 hyG hseg => hnGhat
          ((TemporalPred.eval_at_snce M atomMap _ _ z1).mpr ⟨y, hy1, hyG, hseg⟩)
      -- last chain point c carries G
      obtain ⟨L, hL⟩ := sinceChainPredsAnchored_last_snoc α bf.foldPairsRev
      rw [hL] at hchain
      obtain ⟨c, hc0, hc1, -, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap L _ z0 z1).mp hchain
      -- ¬β_n occurs above c (else y := c would witness Ĝ)
      have h_fail : ∃ w : M.carrier, c < w ∧ w < z1 ∧
          ¬(bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap w := by
        by_contra hcon
        push_neg at hcon
        exact h_no c hc1 hcG hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0last⟩ :=
        h_SUP.last_occ_tp (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).neg z0 z1 h_lt
          ⟨w0, lt_trans hc0 hw1, hw2,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_after : ∀ y : M.carrier, r0 < y → y < z1 →
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap y := by
        intro y hy0 hy1
        have := hr0last y hy0 hy1
        rw [TemporalPred.eval_at_neg'] at this
        exact not_not.mp this
      refine ⟨r0, hr00, hr01, ?_, ?_, ?_⟩
      · exact (TemporalPred.eval_at_neg' M atomMap _ r0).mp hr0neg
      · exact fun hGr0 => h_no r0 hr01 hGr0 hs_after
      · intro y hy0 hy1
        refine ⟨hs_after y hy0 hy1, fun hGy => ?_⟩
        exact h_no y hy1 hGy (fun w h1 h2 => hs_after w (lt_trans hy0 h1) h2)
    · -- chain fails: the Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! # The pinned-concatenation builder (task 350 Phase 10b-ii, unit 1)

Case 3 of the fixed-formula negation recursion glues IH outputs across the
attained first-`¬β₀` pin `r0`: the negation of a bracket on `(z0, z1)` is
assembled from V-brackets on `(z0, r0)` and `(r0, z1)` joined at a pinned
point type (Rabinovich chunk_0017, the A_i/B_i split; Phase 10a handoff,
design note 2). The builder concatenates every pair of disjuncts around the
pin; the `∃ r` and the fixed pin distribute over both disjunction lists. -/

/-- Splitting a list-form bracket at a distinguished pin pair: the bracket
    `[s, …ps…, pin, b, …qs…]` holds iff some `r ∈ (z0, z1)` splits it into
    the `ps`-bracket on `(z0, r)`, the pin at `r`, and the `qs`-bracket on
    `(r, z1)`. -/
theorem bracketOf_append_pin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s a b : TemporalPred)
      (qs : List (TemporalPred × TemporalPred)) (z0 z1 : M.carrier),
    (bracketOf s (ps ++ (a, b) :: qs)).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (bracketOf s ps).holds M atomMap z0 r ∧
      a.eval_at M atomMap r ∧
      (bracketOf b qs).holds M atomMap r z1 := by
  intro ps
  induction ps with
  | nil =>
    intro s a b qs z0 z1
    rw [List.nil_append, bracketOf_cons_holds_iff]
    constructor
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact ⟨r, h1, h2, (bracketOf_nil_holds_iff M atomMap s z0 r).mpr h3, h4, h5⟩
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact ⟨r, h1, h2, (bracketOf_nil_holds_iff M atomMap s z0 r).mp h3, h4, h5⟩
  | cons ab' rest ih =>
    obtain ⟨a', b'⟩ := ab'
    intro s a b qs z0 z1
    rw [List.cons_append, bracketOf_cons_holds_iff]
    constructor
    · rintro ⟨r', h1, h2, h3, h4, h5⟩
      obtain ⟨r, hr1, hr2, hr3, hr4, hr5⟩ := (ih b' a b qs r' z1).mp h5
      exact ⟨r, lt_trans h1 hr1, hr2,
        (bracketOf_cons_holds_iff M atomMap s a' b' rest z0 r).mpr
          ⟨r', h1, hr1, h3, h4, hr3⟩, hr4, hr5⟩
    · rintro ⟨r, hr1, hr2, hr3, hr4, hr5⟩
      obtain ⟨r', h1, h2, h3, h4, h5⟩ :=
        (bracketOf_cons_holds_iff M atomMap s a' b' rest z0 r).mp hr3
      exact ⟨r', h1, lt_trans h2 hr2, h3, h4,
        (ih b' a b qs r' z1).mpr ⟨r, h2, hr2, h5, hr4, hr5⟩⟩

/-- Pinned concatenation of two brackets: `[bfL…, pin, bfR…]`. The witness
    count is the list length of the combined fold pairs (definitionally
    `nL + 1 + nR`, kept in list form to avoid `Fin` casts — the V-level
    consumer stores it under a `Σ`). -/
def BracketFormula.concatPin {nL nR : Nat} (bfL : BracketFormula nL)
    (pin : TemporalPred) (bfR : BracketFormula nR) :
    BracketFormula (bfL.foldPairs ++
      (pin, bfR.segmentTypes ⟨0, Nat.succ_pos nR⟩) :: bfR.foldPairs).length :=
  bracketOf (bfL.segmentTypes ⟨0, Nat.succ_pos nL⟩)
    (bfL.foldPairs ++ (pin, bfR.segmentTypes ⟨0, Nat.succ_pos nR⟩) :: bfR.foldPairs)

/-- Semantics of the pinned concatenation: some `r ∈ (z0, z1)` carries the
    pin, with `bfL` on `(z0, r)` and `bfR` on `(r, z1)`. -/
theorem BracketFormula.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {nL nR : Nat} (bfL : BracketFormula nL) (pin : TemporalPred)
    (bfR : BracketFormula nR) (z0 z1 : M.carrier) :
    (bfL.concatPin pin bfR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      bfL.holds M atomMap z0 r ∧ pin.eval_at M atomMap r ∧
      bfR.holds M atomMap r z1 := by
  unfold concatPin
  rw [bracketOf_append_pin_holds_iff]
  constructor
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact ⟨r, h1, h2,
      (BracketFormula.holds_iff_bracketOf M atomMap nL bfL z0 r).mpr h3, h4,
      (BracketFormula.holds_iff_bracketOf M atomMap nR bfR r z1).mpr h5⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact ⟨r, h1, h2,
      (BracketFormula.holds_iff_bracketOf M atomMap nL bfL z0 r).mp h3, h4,
      (BracketFormula.holds_iff_bracketOf M atomMap nR bfR r z1).mp h5⟩

/-- Pinned concatenation of two V-brackets: every pair of disjuncts joined
    around the pin. -/
def VBracketFormula.concatPin (VL : VBracketFormula) (pin : TemporalPred)
    (VR : VBracketFormula) : VBracketFormula :=
  ⟨VL.disjuncts.flatMap fun dL =>
    VR.disjuncts.map fun dR => ⟨_, dL.2.concatPin pin dR.2⟩⟩

/-- Semantics of the V-level pinned concatenation: the `∃ r` and the fixed
    pin distribute over both disjunction lists. -/
theorem VBracketFormula.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (VL : VBracketFormula) (pin : TemporalPred) (VR : VBracketFormula)
    (z0 z1 : M.carrier) :
    (VL.concatPin pin VR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      VL.holds M atomMap z0 r ∧ pin.eval_at M atomMap r ∧
      VR.holds M atomMap r z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [concatPin, List.mem_flatMap, List.mem_map] at hmem
    obtain ⟨dL, hdL, dR, hdR, rfl⟩ := hmem
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      (BracketFormula.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mp hh
    exact ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
  · rintro ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
    refine ⟨⟨_, dL.2.concatPin pin dR.2⟩, ?_, ?_⟩
    · simp only [concatPin, List.mem_flatMap, List.mem_map]
      exact ⟨dL, hdL, dR, hdR, rfl⟩
    · exact (BracketFormula.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mpr
        ⟨r, h1, h2, h3, h4, h5⟩

/-! # Lemma 5.1 fixed-formula negation: the n = 1 gated instance
(task 350 Phase 10)

Rabinovich's Lemma 5.1 (chunk_0016) outputs `∨_i (Cond_i ∧ Form_i)` — the case
gates ride IN the disjuncts. For the one-witness bracket `[s0, p, s1]` on
attained structures the gate-complete disjunct list is `{A, B1, B2, B3, B4,
B4′}`:

- `A  = [¬p]` — `p` never occurs in `(z0, z1)`;
- `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]` — `s0` fails strictly before the first `p`-point;
- `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]` — `s1` fails strictly after the last `p`-point;
- `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]` — a `¬s0`-point strictly before a `¬s1`-point;
- `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` — the last `¬s1`-point, a `¬p`
  corridor, then the first `¬s0`-point;
- `B4′ = [⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]` — the coincidence case of `B4`.

Each disjunct individually implies `¬[s0, p, s1]` (no attainment needed); the
cover direction pins the first `¬s0`-point and the last `¬s1`-point via
`HasAttainedINF`/`HasAttainedSUP`. The ℤ counterexample below (`NegFixGateProbe`)
machine-checks that the two-point gated shapes `B4`/`B4′` are unavoidable. -/

/-- The one-witness bracket `[s0, p, s1]`. -/
def bracketOne (s0 p s1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend s0 p (BracketFormula.trivial s1)

/-- Unfolded semantics of `[s0, p, s1]`. -/
theorem bracketOne_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) :
    (bracketOne s0 p s1).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ p.eval_at M atomMap x ∧
      (∀ y : M.carrier, z0 < y → y < x → s0.eval_at M atomMap y) ∧
      (∀ y : M.carrier, x < y → y < z1 → s1.eval_at M atomMap y) := by
  constructor
  · intro h
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
    rw [BracketFormula.trivial_holds] at h5
    exact ⟨r, h1, h2, h3, h4, h5⟩
  · rintro ⟨x, h1, h2, h3, h4, h5⟩
    exact BracketFormula.prepend_holds M atomMap _ _ _ _ _ x h1 h2 h3 h4
      ((BracketFormula.trivial_holds M atomMap s1 x z1).mpr h5)

/-- Disjunct `A = [¬p]`. -/
def negFix1A (p : TemporalPred) : BracketFormula 0 :=
  BracketFormula.trivial p.neg

/-- Disjunct `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def negFix1B1 (s0 p : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend p.neg ((s0.neg).conj p.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Disjunct `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]`. -/
def negFix1B2 (p s1 : TemporalPred) : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc ((s1.neg).conj p.neg) p.neg

/-- Disjunct `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]`. -/
def negFix1B3 (s0 s1 : TemporalPred) : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top s0.neg
    (BracketFormula.prepend TemporalPred.top s1.neg
      (BracketFormula.trivial TemporalPred.top))

/-- Disjunct `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def negFix1B4 (s0 p s1 : TemporalPred) : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top ((s1.neg).conj p.neg)
    (BracketFormula.prepend p.neg ((s0.neg).conj p.neg)
      (BracketFormula.trivial TemporalPred.top))

/-- Disjunct `B4′ = [⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]`. -/
def negFix1B4c (s0 p s1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend TemporalPred.top
    ((s0.neg).conj ((s1.neg).conj p.neg))
    (BracketFormula.trivial TemporalPred.top)

/-- The fixed n = 1 negation formula: the six-disjunct gate-complete list. -/
def negFixOne (s0 p s1 : TemporalPred) : VBracketFormula :=
  ⟨[⟨0, negFix1A p⟩, ⟨1, negFix1B1 s0 p⟩, ⟨1, negFix1B2 p s1⟩,
    ⟨2, negFix1B3 s0 s1⟩, ⟨2, negFix1B4 s0 p s1⟩, ⟨1, negFix1B4c s0 p s1⟩]⟩

/-! ## Backward lemmas: each gated disjunct refutes the bracket -/

private theorem negFix1A_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1A p).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  rw [negFix1A, BracketFormula.trivial_holds] at h
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, -, -⟩
  have hnp := h x hx0 hx1
  rw [TemporalPred.eval_at_neg'] at hnp
  exact hnp hxp

private theorem negFix1B1_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B1 s0 p).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w, hw0, hw1, hwpt, hwseg, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, -⟩
  rcases lt_trichotomy x w with hlt | heq | hgt
  · have hnp := hwseg x hx0 hlt
    rw [TemporalPred.eval_at_neg'] at hnp
    exact hnp hxp
  · exact hwpt.2 (heq ▸ hxp)
  · exact hwpt.1 (hxs0 w hw0 hgt)

private theorem negFix1B2_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B2 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  rw [negFix1B2, BracketFormula.snoc_holds_iff] at h
  obtain ⟨w, hw0, hw1, -, hwpt, hwseg⟩ := h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, -, hxs1⟩
  rcases lt_trichotomy x w with hlt | heq | hgt
  · exact hwpt.1 (hxs1 w hlt hw1)
  · exact hwpt.2 (heq ▸ hxp)
  · have hnp := hwseg x hgt hx1
    rw [TemporalPred.eval_at_neg'] at hnp
    exact hnp hxp

private theorem negFix1B3_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B3 s0 s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w0, hw00, hw01, hw0pt, -, htail⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  obtain ⟨w1, hw10, hw11, hw1pt, -, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ htail
  rw [TemporalPred.eval_at_neg'] at hw0pt hw1pt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_or_le w0 x with h1 | h1
  · exact hw0pt (hxs0 w0 hw00 h1)
  · rcases lt_or_le x w1 with h2 | h2
    · exact hw1pt (hxs1 w1 h2 hw11)
    · exact absurd (lt_of_le_of_lt (le_trans h2 h1) hw10) (lt_irrefl w1)

private theorem negFix1B4_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B4 s0 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w1, hw10, hw11, hw1pt, -, htail⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  obtain ⟨w2, hw21, hw22, hw2pt, hcorr, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ htail
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hw1pt hw2pt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_trichotomy x w1 with h1 | h1 | h1
  · exact hw1pt.1 (hxs1 w1 h1 hw11)
  · exact hw1pt.2 (h1 ▸ hxp)
  · rcases lt_trichotomy x w2 with h2 | h2 | h2
    · have hnp := hcorr x h1 h2
      rw [TemporalPred.eval_at_neg'] at hnp
      exact hnp hxp
    · exact hw2pt.2 (h2 ▸ hxp)
    · exact hw2pt.1 (hxs0 w2 (lt_trans hw10 hw21) h2)

private theorem negFix1B4c_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B4c s0 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w, hw0, hw1, hwpt, -, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj,
    TemporalPred.eval_at_neg', TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_trichotomy x w with h1 | h1 | h1
  · exact hwpt.2.1 (hxs1 w h1 hw1)
  · exact hwpt.2.2 (h1 ▸ hxp)
  · exact hwpt.1 (hxs0 w hw0 h1)

/-! ## The n = 1 cover (consumes attained INF and SUP) -/

/-- **Cover** (Rabinovich Lemma 5.1, n = 1, gated): if `[s0, p, s1]` fails on
    `(z0, z1)`, one of the six gated disjuncts holds. The `B3/B4/B4′` cases pin
    the first `¬s0`-point and the last `¬s1`-point (attained INF/SUP). -/
theorem negFixOne_cover {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_neg : ¬ (bracketOne s0 p s1).holds M atomMap z0 z1) :
    (negFixOne s0 p s1).holds M atomMap z0 z1 := by
  rw [bracketOne_holds_iff] at h_neg
  by_cases hp_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ p.eval_at M atomMap x
  case neg =>
    -- Disjunct A
    push_neg at hp_occ
    refine ⟨⟨0, negFix1A p⟩, by simp [negFixOne], ?_⟩
    rw [negFix1A, BracketFormula.trivial_holds]
    intro y hy0 hy1
    rw [TemporalPred.eval_at_neg']
    exact hp_occ y hy0 hy1
  case pos =>
  obtain ⟨r0, hr00, hr01, hp_r0, hnb0⟩ := h_INF.first_occ_tp p z0 z1 h_lt hp_occ
  by_cases hs0_pre : ∀ y : M.carrier, z0 < y → y < r0 → s0.eval_at M atomMap y
  case neg =>
    -- Disjunct B1: s0 fails strictly before the first p-point
    push_neg at hs0_pre
    obtain ⟨w, hw0, hw1, hws0⟩ := hs0_pre
    refine ⟨⟨1, negFix1B1 s0 p⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 w hw0
      (lt_trans hw1 hr01) ?_ ?_ ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hws0, hnb0 w hw0 hw1⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg']
      exact hnb0 y hy0 (lt_trans hy1 hw1)
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
  case pos =>
  obtain ⟨rN, hrN0, hrN1, hp_rN, hna1⟩ := h_SUP.last_occ_tp p z0 z1 h_lt hp_occ
  by_cases hs1_post : ∀ y : M.carrier, rN < y → y < z1 → s1.eval_at M atomMap y
  case neg =>
    -- Disjunct B2: s1 fails strictly after the last p-point
    push_neg at hs1_post
    obtain ⟨w, hw0, hw1, hws1⟩ := hs1_post
    refine ⟨⟨1, negFix1B2 p s1⟩, by simp [negFixOne], ?_⟩
    rw [negFix1B2, BracketFormula.snoc_holds_iff]
    refine ⟨w, lt_trans hrN0 hw0, hw1, ?_, ?_, ?_⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hws1, hna1 w hw0 hw1⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg']
      exact hna1 y (lt_trans hw0 hy0) hy1
  case pos =>
  -- Both boundary gates hold: pin the last ¬s1-point and the first ¬s0-point.
  have h1fail : ¬ ∀ y : M.carrier, r0 < y → y < z1 → s1.eval_at M atomMap y :=
    fun hpost => h_neg ⟨r0, hr00, hr01, hp_r0, hs0_pre, hpost⟩
  push_neg at h1fail
  obtain ⟨v1, hv10, hv11, hv1s1⟩ := h1fail
  have h0fail : ¬ ∀ y : M.carrier, z0 < y → y < rN → s0.eval_at M atomMap y :=
    fun hpre => h_neg ⟨rN, hrN0, hrN1, hp_rN, hpre, hs1_post⟩
  push_neg at h0fail
  obtain ⟨v0, hv00, hv01, hv0s0⟩ := h0fail
  obtain ⟨y1, hy10, hy11, hy1s1, hy1last⟩ :=
    h_SUP.last_occ_tp s1.neg z0 z1 h_lt
      ⟨v1, lt_trans hr00 hv10, hv11,
        (TemporalPred.eval_at_neg' M atomMap s1 v1).mpr hv1s1⟩
  obtain ⟨y0, hy00, hy01, hy0s0, hy0first⟩ :=
    h_INF.first_occ_tp s0.neg z0 z1 h_lt
      ⟨v0, hv00, lt_trans hv01 hrN1,
        (TemporalPred.eval_at_neg' M atomMap s0 v0).mpr hv0s0⟩
  -- s1 holds strictly after y1; s0 holds strictly before y0.
  have hs1_after : ∀ y : M.carrier, y1 < y → y < z1 → s1.eval_at M atomMap y := by
    intro y hy hyz
    have := hy1last y hy hyz
    rw [TemporalPred.eval_at_neg'] at this
    exact not_not.mp this
  have hs0_before : ∀ y : M.carrier, z0 < y → y < y0 → s0.eval_at M atomMap y := by
    intro y hy hyy
    have := hy0first y hy hyy
    rw [TemporalPred.eval_at_neg'] at this
    exact not_not.mp this
  rw [TemporalPred.eval_at_neg'] at hy1s1 hy0s0
  rcases lt_trichotomy y0 y1 with hlt | heq | hgt
  · -- Disjunct B3: the first ¬s0-point sits strictly before the last ¬s1-point
    refine ⟨⟨2, negFix1B3 s0 s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y0 hy00 hy01
      ((TemporalPred.eval_at_neg' M atomMap s0 y0).mpr hy0s0)
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    refine BracketFormula.prepend_holds M atomMap _ _ _ y0 z1 y1 hlt hy11
      ((TemporalPred.eval_at_neg' M atomMap s1 y1).mpr hy1s1)
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    rw [BracketFormula.trivial_holds]
    intro y _ _
    exact TemporalPred.eval_at_top M atomMap y
  · -- Disjunct B4′: the pins coincide; the point is also a ¬p-point
    have hnp : ¬ p.eval_at M atomMap y0 := by
      intro hp_y0
      have hfail : ¬ ∀ y : M.carrier, y0 < y → y < z1 → s1.eval_at M atomMap y :=
        fun hpost => h_neg ⟨y0, hy00, hy01, hp_y0, hs0_before, hpost⟩
      push_neg at hfail
      obtain ⟨w, hwa, hwb, hws1⟩ := hfail
      exact hws1 (hs1_after w (heq ▸ hwa) hwb)
    refine ⟨⟨1, negFix1B4c s0 p s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y0 hy00 hy01 ?_
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj,
        TemporalPred.eval_at_neg', TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hy0s0, heq ▸ hy1s1, hnp⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
  · -- Disjunct B4: last ¬s1-point, ¬p corridor, first ¬s0-point
    have hnp : ∀ x : M.carrier, y1 ≤ x → x ≤ y0 → ¬ p.eval_at M atomMap x := by
      intro x hx1 hx0 hpx
      have hx_in0 : z0 < x := lt_of_lt_of_le hy10 hx1
      have hx_in1 : x < z1 := lt_of_le_of_lt hx0 hy01
      have hpre : ∀ y : M.carrier, z0 < y → y < x → s0.eval_at M atomMap y :=
        fun y hy0 hyx => hs0_before y hy0 (lt_of_lt_of_le hyx hx0)
      have hfail : ¬ ∀ y : M.carrier, x < y → y < z1 → s1.eval_at M atomMap y :=
        fun hpost => h_neg ⟨x, hx_in0, hx_in1, hpx, hpre, hpost⟩
      push_neg at hfail
      obtain ⟨w, hwx, hwz, hws1⟩ := hfail
      exact hws1 (hs1_after w (lt_of_le_of_lt hx1 hwx) hwz)
    refine ⟨⟨2, negFix1B4 s0 p s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y1 hy10 hy11 ?_
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hy1s1, hnp y1 le_rfl (le_of_lt hgt)⟩
    · refine BracketFormula.prepend_holds M atomMap _ _ _ y1 z1 y0 hgt hy01 ?_ ?_ ?_
      · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
          TemporalPred.eval_at_neg']
        exact ⟨hy0s0, hnp y0 (le_of_lt hgt) le_rfl⟩
      · intro y hy0 hy1'
        rw [TemporalPred.eval_at_neg']
        exact hnp y (le_of_lt hy0) (le_of_lt hy1')
      · rw [BracketFormula.trivial_holds]
        intro y _ _
        exact TemporalPred.eval_at_top M atomMap y

/-- **Lemma 5.1, n = 1, fixed formula** (Rabinovich 2014, gated): on attained
    structures, `negFixOne s0 p s1` holds on `(z0, z1)` iff the bracket
    `[s0, p, s1]` fails on `(z0, z1)`. -/
theorem negFixOne_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negFixOne s0 p s1).holds M atomMap z0 z1 ↔
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  constructor
  · rintro ⟨d, hmem, hd⟩
    simp only [negFixOne, List.mem_cons, List.not_mem_nil, or_false] at hmem
    rcases hmem with rfl | rfl | rfl | rfl | rfl | rfl
    · exact negFix1A_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B1_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B2_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B3_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B4_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B4c_backward M atomMap s0 p s1 z0 z1 hd
  · exact negFixOne_cover M atomMap h_INF h_SUP s0 p s1 z0 z1 h_lt

/-! # Lemma 5.1 fixed-formula negation: the gate probes (task 350 Phase 10)

## R2 gate: the ℤ counterexample

Rabinovich's Lemma 5.1 output is `∨_i (Cond_i ∧ Form_i)` — the case gates RIDE
IN the disjuncts (chunk_0016 md:5). The report's Medium-High-confidence claim
(plan R2) is that the gates are load-bearing: a gate-free disjunct list cannot
be a biconditional cover. The following ℤ instance machine-checks this.

Take carrier ℤ, interval `(0, 10)`, and `bf = [s0, p, s1]` (one witness point
of type `p`, segment `s0` before it, `s1` after it) with
- `p` true exactly at `{2, 8}`,
- `¬s0` true exactly at `{7}` (i.e. `s0 = (· ≠ 7)`),
- `¬s1` true exactly at `{3}` (i.e. `s1 = (· ≠ 3)`).

Then `¬bf.holds 0 10` (witness 2 fails at `s1 3`; witness 8 fails at `s0 7`),
yet the four single-pin negation disjuncts all FAIL:
- `A = [¬p]` — refuted by `p 2`;
- `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]` — the only `¬s0` point is 7, but `p 2` breaks
  the `¬p` prefix;
- `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]` — the only `¬s1` point is 3, but `p 8` breaks
  the `¬p` suffix;
- `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]` — needs a `¬s0` point BEFORE a `¬s1` point,
  i.e. `7 < 3`.

Only the two-point gated disjunct
`B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` holds (witnesses 3 < 7): the
last-`¬s1` point, then a `¬p` corridor, then the first-`¬s0` point. Hence any
biconditional negation cover MUST contain the B4/B4′ gated shapes; the
Boneyard's 3-disjunct list (A/B1-prepend/B2-INF) is forward-only. -/

namespace NegFixGateProbe

/-- Three predicate symbols: `p`, `s0`, `s1`. -/
abbrev sigZ : MonadicSignature := { preds := Fin 3 }

/-- The ℤ structure of the counterexample: `p` exactly at `{2, 8}`, `¬s0`
    exactly at `{7}`, `¬s1` exactly at `{3}`. -/
abbrev MZ : OrderedMonadicStructure sigZ where
  carrier := ℤ
  interp k t :=
    match k with
    | ⟨0, _⟩ => t = 2 ∨ t = 8
    | ⟨1, _⟩ => t ≠ 7
    | ⟨2, _⟩ => t ≠ 3
  carrier_order := inferInstance

/-- Atom map: fresh atoms with indices 0, 1, 2 name the three predicates. -/
def atomMapZ : Formula → sigZ.preds
  | .atom ⟨_, some 1⟩ => 1
  | .atom ⟨_, some 2⟩ => 2
  | _ => 0

/-- The point predicate `p` (true exactly at `{2, 8}`). -/
def pZ : TemporalPred := ⟨.atom ⟨"", some 0⟩⟩

/-- The left segment predicate `s0` (false exactly at `7`). -/
def s0Z : TemporalPred := ⟨.atom ⟨"", some 1⟩⟩

/-- The right segment predicate `s1` (false exactly at `3`). -/
def s1Z : TemporalPred := ⟨.atom ⟨"", some 2⟩⟩

theorem pZ_eval (t : ℤ) : pZ.eval_at MZ atomMapZ t ↔ t = 2 ∨ t = 8 := Iff.rfl

theorem s0Z_eval (t : ℤ) : s0Z.eval_at MZ atomMapZ t ↔ t ≠ 7 := Iff.rfl

theorem s1Z_eval (t : ℤ) : s1Z.eval_at MZ atomMapZ t ↔ t ≠ 3 := Iff.rfl

/-- The bracket `[s0, p, s1]`: one interior `p`-point, `s0` before, `s1`
    after. -/
def bfZ : BracketFormula 1 :=
  BracketFormula.prepend s0Z pZ (BracketFormula.trivial s1Z)

/-- Gate-free disjunct `A = [¬p]`. -/
def caseA_Z : BracketFormula 0 := BracketFormula.trivial pZ.neg

/-- Gated disjunct `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def caseB1_Z : BracketFormula 1 :=
  BracketFormula.prepend pZ.neg ((s0Z.neg).conj pZ.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Gated disjunct `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]`. -/
def caseB2_Z : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc ((s1Z.neg).conj pZ.neg) pZ.neg

/-- Gate-free disjunct `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]`. -/
def caseB3_Z : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top s0Z.neg
    (BracketFormula.prepend TemporalPred.top s1Z.neg
      (BracketFormula.trivial TemporalPred.top))

/-- The gated two-point disjunct
    `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def caseB4_Z : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top ((s1Z.neg).conj pZ.neg)
    (BracketFormula.prepend pZ.neg ((s0Z.neg).conj pZ.neg)
      (BracketFormula.trivial TemporalPred.top))

/-- The bracket `[s0, p, s1]` FAILS on `(0, 10)`: witness 2 is broken by
    `¬s1 3`, witness 8 by `¬s0 7`. -/
theorem bfZ_not_holds : ¬ bfZ.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r, hr0, hr1, hp, hseg, htail⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  rw [BracketFormula.trivial_holds] at htail
  rcases (pZ_eval r).mp hp with h2 | h8
  · have h3 := htail (3 : ℤ) (show (r : ℤ) < 3 by rw [h2]; decide) (by decide)
    rw [s1Z_eval] at h3
    exact h3 rfl
  · have h7 := hseg (7 : ℤ) (by decide) (show (7 : ℤ) < r by rw [h8]; decide)
    rw [s0Z_eval] at h7
    exact h7 rfl

/-- Disjunct `A` fails: `p 2`. -/
theorem caseA_not_holds : ¬ caseA_Z.holds MZ atomMapZ 0 10 := by
  rw [caseA_Z, BracketFormula.trivial_holds]
  intro h
  have h2 := h (2 : ℤ) (by decide) (by decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h2
  exact h2 (Or.inl rfl)

/-- Disjunct `B1` fails: the only `¬s0` point is 7, but `p 2` breaks the
    `¬p` prefix on `(0, 7)`. -/
theorem caseB1_not_holds : ¬ caseB1_Z.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r, hr0, hr1, hpt, hseg, -⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg', s0Z_eval, pZ_eval] at hpt
  have hr7 : (r : ℤ) = 7 := not_not.mp hpt.1
  have h2 := hseg (2 : ℤ) (by decide) (show (2 : ℤ) < r by rw [hr7]; decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h2
  exact h2 (Or.inl rfl)

/-- Disjunct `B2` fails: the only `¬s1` point is 3, but `p 8` breaks the
    `¬p` suffix on `(3, 10)`. -/
theorem caseB2_not_holds : ¬ caseB2_Z.holds MZ atomMapZ 0 10 := by
  intro h
  rw [caseB2_Z, BracketFormula.snoc_holds_iff] at h
  obtain ⟨x, hx0, hx1, -, hpt, hseg⟩ := h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg', s1Z_eval, pZ_eval] at hpt
  have hx3 : (x : ℤ) = 3 := not_not.mp hpt.1
  have h8 := hseg (8 : ℤ) (show (x : ℤ) < 8 by rw [hx3]; decide) (by decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h8
  exact h8 (Or.inr rfl)

/-- Disjunct `B3` fails: it needs a `¬s0` point strictly before a `¬s1`
    point, i.e. `7 < 3`. -/
theorem caseB3_not_holds : ¬ caseB3_Z.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r1, hr10, hr11, hpt1, -, htail⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  obtain ⟨r2, hr21, hr22, hpt2, -, -⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ htail
  rw [TemporalPred.eval_at_neg', s0Z_eval] at hpt1
  rw [TemporalPred.eval_at_neg', s1Z_eval] at hpt2
  have h12 : (r1 : ℤ) < r2 := hr21
  rw [not_not.mp hpt1, not_not.mp hpt2] at h12
  exact absurd h12 (by decide)

/-- The gated two-point disjunct `B4` HOLDS with witnesses `3 < 7`: the
    last-`¬s1` point, a `¬p` corridor, the first-`¬s0` point. -/
theorem caseB4_holds : caseB4_Z.holds MZ atomMapZ 0 10 := by
  refine BracketFormula.prepend_holds MZ atomMapZ _ _ _ 0 10 (3 : ℤ)
    (by decide) (by decide) ?_ ?_ ?_
  · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg', s1Z_eval, pZ_eval]
    exact ⟨fun hne => hne rfl, by omega⟩
  · intro y _ _
    exact TemporalPred.eval_at_top MZ atomMapZ y
  · refine BracketFormula.prepend_holds MZ atomMapZ _ _ _ (3 : ℤ) 10 (7 : ℤ)
      (by decide) (by decide) ?_ ?_ ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg', s0Z_eval, pZ_eval]
      exact ⟨fun hne => hne rfl, by omega⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg', pZ_eval]
      have h0 : (3 : ℤ) < y := hy0
      have h1 : (y : ℤ) < 7 := hy1
      rintro (h | h)
      · rw [h] at h0
        exact absurd h0 (by decide)
      · rw [h] at h1
        exact absurd h1 (by decide)
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top MZ atomMapZ y

end NegFixGateProbe

end Bimodal.Metalogic.WeakCanonical.Kamp
