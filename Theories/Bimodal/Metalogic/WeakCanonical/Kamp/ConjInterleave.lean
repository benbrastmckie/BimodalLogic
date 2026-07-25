import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas
import Mathlib.Data.Fintype.Sigma
import Mathlib.Order.Fin.Basic
import Mathlib.Data.Finset.Sort
import Mathlib.Order.Interval.Finset.Fin

/-!
# Lemma 3.2(1) — `conjInterleave`: the ∃∀×∃∀ → ∨∃∀ order-preserving merge (Rabinovich, PDF p.4-5)

This module builds the definition and the **forward (`→`) direction** of the one genuinely-unbuilt
combinatorial core of the E[Σ] re-architecture: the closure of `∃∀`-formulas under conjunction as a
disjunction of order-preserving **chain interleavings** (Rabinovich, *A Proof of Kamp's Theorem*
(2014), Lemma 3.2(1), PDF p.4; Lemma 3.4 conjunction case, p.5). It is faithful to Rabinovich's
proof: two ∃∀-formulas each describe an ordered existential chain, and their conjunction is
witnessed by a single ordered chain that **merges** the two — a PATH merge of `Fin (n₁+1)` and
`Fin (n₂+1)` into one linear order, NOT a joint type over a tuple. No arity growth, no K₄: the
merged object is again a single `StrictMono` chain of **unary** point/interval types.

## Partial interval types: points complete, intervals partial (design note)

A `UnaryType sig F = NormalForm (sigE sig F) 0 1` is a **complete** quantifier-free 1-type: by
`nf_eval_nf` at depth 0, `unaryHolds N τ p` says *every* E[Σ] atom at `p` matches `τ` exactly, and
`nf_eval_unique` says a point realizes at most one type.

Rabinovich's Def 3.1 (PDF p.4) takes the point/interval predicates `αⱼ, βⱼ` to be **quantifier-free
1-FORMULAS**. Faithful to this, the `ExistsForallFormula` interval field is a **partial**
`IntervalType := Finset UnaryType` — the admissible-completion set of the qf-interval-formula
(Def 3.1, p.4) — while the point field stays complete (`αⱼ` constrains a real point). Conjunction of
interval formulas is **intersection** of admissible sets (Lemma 3.2(1)/3.4 (∧), p.4-5); the empty set
is the forced-empty (⊥) interval, vacuously satisfied when its open interval has no points. Point
types stay complete `UnaryType`.

**Consequence for the merge.** At a merged *point* (always a real point of the model) the complete
point type is contributed by whichever chain pins it as an existential point (`mergedPointType`), and
where both chains pin the same merged point their two complete types coincide by `nf_eval_unique`,
enforced by the decidable **point-consistency** filter. At a merged *interval slot* the merged
formula carries `intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t) = S₁ ∩ S₂`
(the intersection of the two chains' admissible-completion sets at that slot): interval slots are
**not** filtered on mismatch — an empty `S₁ ∩ S₂` is simply forced-empty and vacuously satisfied on
an empty open interval. This is the partial-type merge on which the **full** `conjInterleave_iff`
biconditional is provable (audit: attainable only on partial types).

## Contents (this module)

1. `belowCount` / `intervalSlot` — for a strictly-monotone embedding `e : Fin (n+1) → Fin (k+1)`,
   the chain interval slot (`Fin (n+2)`) that a merged position occupies.
2. `chainPointType` (optional complete type; `none` at interior points) / `mergedPointType` (the
   merged complete point type) / `chainIntervalType` (the source chain's partial interval set at a
   merged interval slot).
3. `MergePair` — the order-preserving-merge datum: two strictly-monotone jointly-surjective
   pin-compatible embeddings, packaged as raw data over a `Fintype` for enumeration.
4. `MergePair.valid` / `MergePair.pointConsistent` — the decidable validity and point-consistency
   predicates.
5. `mergedFormula` — the merged `ExistsForallFormula` (single `StrictMono` chain; complete points,
   `S₁ ∩ S₂` interval slots), and `conjInterleave` — the `∨∃∀`-formula enumerating all valid,
   point-consistent merges.
6. `mergedPointType_left`/`_right`, `pointConsistent_of_holds` — point-type readback / consistency
   from realized types.
7. `conjInterleave_forward` — **the forward direction** (LANDED sorry-free via the sorted-union
   rank realization and the §6c slot-correspondence crux). The backward direction,
   `conjInterleave_iff`, `veeConj`, and `veeConj_iff` follow.

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Lemma 3.2(1) (p.4), Lemma 3.4 (p.5), Definition
  3.1 (p.4). Cited by PDF page; the companion markdown transcription is corrupt.
- `ExistsForallFormula.lean`: the Def 3.1 object `ExistsForallFormula`, `efSat`, `UnaryType`,
  `unaryHolds`.
- `VeeExistsForall.lean`: the Def 3.3 object `VeeExistsForall`, `veeSat`, `veeSat_append`.
- `NormalForm.lean`: `nf_eval_unique` (a point realizes at most one complete type).
- `VecEAConjFull.lean`: `BracketFormula.conjFull` — the type-merge bookkeeping template.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. Interval slots of a strictly-monotone embedding -/

/-- The number of source points of the embedding `e : Fin (n+1) → Fin (k+1)` that sit strictly
below the merged position `j`. When `j` is not in the image of `e`, this is the source interval
slot (`0 = before x₀`, `i = (x_{i-1}, xᵢ)`, `n+1 = after xₙ`) containing `j`. -/
def belowCount {n k : Nat} (e : Fin (n + 1) → Fin (k + 1)) (j : Fin (k + 1)) : Nat :=
  (Finset.univ.filter (fun i => e i < j)).card

/-- `belowCount` never exceeds `n+1` (there are only `n+1` source points). -/
theorem belowCount_le {n k : Nat} (e : Fin (n + 1) → Fin (k + 1)) (j : Fin (k + 1)) :
    belowCount e j ≤ n + 1 := by
  unfold belowCount
  calc (Finset.univ.filter (fun i => e i < j)).card
      ≤ (Finset.univ : Finset (Fin (n + 1))).card := Finset.card_filter_le _ _
    _ = n + 1 := by simp

/-- The interval slot (`Fin (n+2)`) of a merged position `j` relative to embedding `e`. -/
def intervalSlot {n k : Nat} (e : Fin (n + 1) → Fin (k + 1)) (j : Fin (k + 1)) : Fin (n + 2) :=
  ⟨belowCount e j, Nat.lt_succ_of_le (belowCount_le e j)⟩

/-! ## 3. The order-preserving-merge datum -/

/-- Raw merge data for merging a chain of `n₁+1` points with a chain of `n₂+1` points into a chain
of `k+1` points: two embeddings, packaged for `Fintype` enumeration. Monotonicity, surjectivity,
and pin-compatibility are imposed by the decidable `valid` predicate rather than as fields, so the
carrier is a plain `Fintype`. -/
structure MergePair (n₁ n₂ k : Nat) where
  e₁ : Fin (n₁ + 1) → Fin (k + 1)
  e₂ : Fin (n₂ + 1) → Fin (k + 1)
  deriving DecidableEq

/-- `MergePair` is equivalent to the product of its two function spaces. -/
def MergePair.equivProd (n₁ n₂ k : Nat) :
    MergePair n₁ n₂ k ≃ (Fin (n₁ + 1) → Fin (k + 1)) × (Fin (n₂ + 1) → Fin (k + 1)) where
  toFun m := (m.e₁, m.e₂)
  invFun p := ⟨p.1, p.2⟩
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

instance (n₁ n₂ k : Nat) : Fintype (MergePair n₁ n₂ k) :=
  Fintype.ofEquiv _ (MergePair.equivProd n₁ n₂ k).symm

/-- The merge is **valid**: both embeddings strictly monotone, jointly surjective onto the merged
chain, and pin-compatible (each free variable's two pinned points coincide in the merge). -/
def MergePair.valid {r n₁ n₂ k : Nat} (pin₁ : Fin r → Fin (n₁ + 1)) (pin₂ : Fin r → Fin (n₂ + 1))
    (m : MergePair n₁ n₂ k) : Prop :=
  StrictMono m.e₁ ∧ StrictMono m.e₂ ∧
    (∀ j : Fin (k + 1), (∃ i, m.e₁ i = j) ∨ (∃ i, m.e₂ i = j)) ∧
    (∀ v : Fin r, m.e₁ (pin₁ v) = m.e₂ (pin₂ v))

instance {r n₁ n₂ k : Nat} (pin₁ : Fin r → Fin (n₁ + 1)) (pin₂ : Fin r → Fin (n₂ + 1))
    (m : MergePair n₁ n₂ k) : Decidable (m.valid pin₁ pin₂) := by
  unfold MergePair.valid
  infer_instance

/-! ## 6. Realized merge from two satisfying chains -/

/-- The sorted-union carrier of two witness chains: the finite set of all points used by either
chain, as a `Finset` of the model. Its sorted enumeration is the merged chain. -/
noncomputable def mergedSet {n₁ n₂ : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (x₁ : Fin (n₁ + 1) → N.carrier) (x₂ : Fin (n₂ + 1) → N.carrier) : Finset N.carrier :=
  open Classical in
  Finset.univ.image x₁ ∪ Finset.univ.image x₂

/-- The merged carrier is nonempty (it contains `x₁ 0`), so its cardinality is a successor. -/
theorem mergedSet_card_succ {n₁ n₂ : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (x₁ : Fin (n₁ + 1) → N.carrier) (x₂ : Fin (n₂ + 1) → N.carrier) :
    (mergedSet N x₁ x₂).card = ((mergedSet N x₁ x₂).card - 1) + 1 := by
  have hne : (mergedSet N x₁ x₂).Nonempty := by
    classical
    refine ⟨x₁ 0, ?_⟩
    simp only [mergedSet, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inl ⟨0, rfl⟩
  exact (Nat.succ_pred_eq_of_pos (Finset.card_pos.mpr hne)).symm

/-! ## 6b. Rank round-trip for the sorted-union enumeration -/

/-- **Rank round-trip.** The sorted enumeration `S.orderEmbOfFin` composed with the inverse rank map
`(S.orderIsoOfFin).symm` recovers the original value: at the rank of `p ∈ S`, the sorted chain reads
back `p`. This is the identity `w (eₖ i) = xₖ i` that anchors the forward-direction realized merge. -/
theorem orderEmbOfFin_symm_apply {α : Type*} [LinearOrder α] (S : Finset α) {k : Nat}
    (hcard : S.card = k) (p : α) (hp : p ∈ S) :
    S.orderEmbOfFin hcard ((S.orderIsoOfFin hcard).symm ⟨p, hp⟩) = p := by
  have h1 : (S.orderIsoOfFin hcard) ((S.orderIsoOfFin hcard).symm ⟨p, hp⟩) = ⟨p, hp⟩ :=
    OrderIso.apply_symm_apply _ _
  have h2 : S.orderEmbOfFin hcard ((S.orderIsoOfFin hcard).symm ⟨p, hp⟩)
      = ((S.orderIsoOfFin hcard) ((S.orderIsoOfFin hcard).symm ⟨p, hp⟩) : α) := rfl
  rw [h2, h1]

/-- The inverse rank map of a strictly-monotone chain landing in `S` is strictly monotone: sorting
by value preserves the chain's order. -/
theorem strictMono_rank {α : Type*} [LinearOrder α] (S : Finset α) {k m : Nat}
    (hcard : S.card = k) (x : Fin m → α) (hx : StrictMono x) (hmem : ∀ i, x i ∈ S) :
    StrictMono (fun i => (S.orderIsoOfFin hcard).symm ⟨x i, hmem i⟩) := by
  intro a b hab
  apply (S.orderIsoOfFin hcard).symm.strictMono
  exact hx hab

/-- **Reverse rank identity.** The inverse rank map recovers the merged position from the value the
sorted chain reads there: `rank⁻¹(w j) = j`. Together with `orderEmbOfFin_symm_apply` this is the
value/rank bijection underlying joint surjectivity of the rank maps. -/
theorem rank_orderEmbOfFin {α : Type*} [LinearOrder α] (S : Finset α) {k : Nat}
    (hcard : S.card = k) (j : Fin k) (hj : S.orderEmbOfFin hcard j ∈ S) :
    (S.orderIsoOfFin hcard).symm ⟨S.orderEmbOfFin hcard j, hj⟩ = j := by
  have hval : (⟨S.orderEmbOfFin hcard j, hj⟩ : {x // x ∈ S}) = S.orderIsoOfFin hcard j :=
    Subtype.ext rfl
  rw [hval, OrderIso.symm_apply_apply]

/-! ## 6c. Strict-monotone filter-card correspondence (the order-theoretic crux) -/

/-- **The rank↔slot correspondence.** For a strictly-monotone chain `x : Fin m → α` into a linear
order and any threshold `y`, the chain point `x a` lies below `y` exactly when `a`'s position is
below the number of chain points below `y`. This is the one genuinely order-theoretic fact
underlying the `belowCount`↔interval-slot correspondence of the forward direction (Rabinovich
Lemma 3.2(1), p.4): the down-set `{i | x i < y}` of a strictly-monotone chain is an initial segment,
so its cardinality is the threshold position. Loogle confirms no one-shot Mathlib lemma. -/
theorem strictMono_lt_iff_val_lt_filterCard {α : Type*} [LinearOrder α] {m : Nat}
    (x : Fin m → α) (hx : StrictMono x) (y : α) (a : Fin m) :
    x a < y ↔ a.val < (Finset.univ.filter (fun i => x i < y)).card := by
  constructor
  · intro hlt
    have hsub : Finset.Iic a ⊆ Finset.univ.filter (fun i => x i < y) := by
      intro i hi
      simp only [Finset.mem_Iic] at hi
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact lt_of_le_of_lt (hx.monotone hi) hlt
    have hcard := Finset.card_le_card hsub
    rw [Fin.card_Iic] at hcard
    omega
  · intro hcard
    by_contra hnlt
    push_neg at hnlt
    have hsub : Finset.univ.filter (fun i => x i < y) ⊆ Finset.Iio a := by
      intro i hi
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi
      simp only [Finset.mem_Iio]
      exact hx.lt_iff_lt.mp (lt_of_lt_of_le hi hnlt)
    have hc := Finset.card_le_card hsub
    rw [Fin.card_Iio] at hc
    omega

/-! ## 10. Per-formula (Fin) layer: Lemma 3.2(1) on partial types over the merged atom set

The `M`-relative mirror of §§1-9 on `ExistsForallFormulaFin`/`efSatFin`
(`PerFormulaExistsForall.lean`). Unlike the efSat lemma layer (`ExistsForallLemmas.lean` §9),
this is NOT a verbatim transcription: the total `mergedPointType` hands every merged point a
COMPLETE type contributed by whichever chain pins it, and total cross-consistency is a membership
of that complete type in the other chain's admissible set. On partial types, a single
`UnaryTypeFin (ψ₁.M ∪ ψ₂.M)` at a point pinned by chain 1 only is NOT determined by chain 1's
`UnaryTypeFin ψ₁.M`: the atoms of `ψ₂.M \ ψ₁.M` are constrained only DISJUNCTIVELY, by ψ₂'s
interval formula at the enclosing slot.

**Design (faithful to Rabinovich Lemma 3.2(1), PDF p.4).** The Fin disjunction additionally
ranges over **`M`-relative completions**: each disjunct is a merge datum `m : MergePair` TOGETHER
WITH a choice `pt` of one partial type over the merged atom set `ψ₁.M ∪ ψ₂.M` per merged point,
filtered by `choiceCompatible` — `pt` must restrict on each chain's own atoms to that chain's
point type (`weaken`), and at a point pinned by only one chain its other-chain restriction must
lie in the other chain's admissible interval set at the enclosing slot. This is licensed by the
paper: Def 3.1 (p.4) takes the point predicates `αⱼ` to be arbitrary quantifier-free one-variable
formulas, so the conjoined constraint at a cross point — `α₁ ∧ (ψ₂'s interval formula)` — is
equivalent to the finite disjunction of its complete types over the mentioned atoms, and Lemma
3.2(1)'s conclusion is precisely a DISJUNCTION of ∃∀-formulas, absorbing that expansion. The
extra disjuncts range over functions into partial types over `ψ₁.M ∪ ψ₂.M` — finite from the
mentioned atoms ALONE, never alphabet-sized (Def 4.1, p.5: E[Σ] is infinite; no
`Fintype sig.preds` appears anywhere below; the only `Finset.univ`s are over `Fin` index types
and over `UnaryTypeFin _ _ M`, both `M`-finite). -/

namespace Kamp

/-! ### 10.0 Partial-type leaf lemmas: weakening and characteristic readback -/

/-- Weakening preserves realization: a point realizing `c` over `M'` realizes the restriction of
`c` to any `M ⊆ M'` (the mentioned-atom agreement is inherited atom-wise). -/
theorem partialHolds_weaken {M M' : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F)) (h : M ⊆ M')
    {c : UnaryTypeFin sig F M'} {y : N.carrier} (hc : partialHolds N c y) :
    partialHolds N (weaken h c) y :=
  fun a => hc ⟨a.1, h a.2⟩

/-- **Partial-type uniqueness readback (the Fin analog of `nf_eval_unique`).** A realized partial
type over `M` is exactly the characteristic completion of its point: `partialHolds` pins every
mentioned atom's truth value. -/
theorem partialHolds_eq_charTypeFin {M : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F))
    {c : UnaryTypeFin sig F M} {y : N.carrier} (h : partialHolds N c y) :
    c = charTypeFin N M y := by
  classical
  funext a
  have ha := h a
  simp only [charTypeFin]
  cases hb : c a with
  | false =>
    rw [hb] at ha
    simp only [Bool.false_eq_true, iff_false] at ha
    exact (decide_eq_false ha).symm
  | true =>
    rw [hb] at ha
    simp only [iff_true] at ha
    exact (decide_eq_true ha).symm

/-- The characteristic completion commutes with weakening (both read the same atom values). -/
theorem weaken_charTypeFin {M M' : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F)) (h : M ⊆ M') (y : N.carrier) :
    weaken h (charTypeFin N M' y) = charTypeFin N M y :=
  rfl

/-! ### 10.1 The merged atom set and the glued interval set -/

open Classical in
/-- The **merged mentioned-atom set** `ψ₁.M ∪ ψ₂.M` of two per-formula `∃∀`-formulas. The
`Finset` union needs `DecidableEq (AtomKind (sigE sig F) 1)`, whose only global instance
(`atomKind_decEq`) consumes the PROHIBITED alphabet instance `DecidableEq sig.preds`; this one
definition confines the classical route instead, and everything below speaks of `mergedM`. -/
noncomputable def mergedM {r : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r) :
    Finset (AtomKind (sigE sig F) 1) :=
  ψ₁.M ∪ ψ₂.M

/-- Chain 1's atoms sit inside the merged atom set. -/
theorem subset_mergedM_left {r : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r) :
    ψ₁.M ⊆ mergedM ψ₁ ψ₂ := by
  classical
  exact Finset.subset_union_left

/-- Chain 2's atoms sit inside the merged atom set. -/
theorem subset_mergedM_right {r : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r) :
    ψ₂.M ⊆ mergedM ψ₁ ψ₂ := by
  classical
  exact Finset.subset_union_right

open Classical in
/-- **Glued interval set (the cross-`M` conjunction of interval formulas).** The admissible
partial completions over an ambient mentioned set `M` whose restrictions land in `S₁` (over
`M₁ ⊆ M`) and `S₂` (over `M₂ ⊆ M`) respectively. This is the `M`-relative form of the total
`intervalConj = ∩` (Lemma 3.2(1)/3.4 (∧), p.4-5) when the two conjoined interval formulas
mention DIFFERENT atom sets: conjunction of quantifier-free interval formulas = the completions
(over the ambient mentioned atoms) admissible for both. `Finset.univ` here ranges over
`UnaryTypeFin sig F M` — functions from the finite mentioned subtype to `Bool` — never over any
whole-alphabet type. -/
noncomputable def intervalGlueFin {M₁ M₂ M : Finset (AtomKind (sigE sig F) 1)}
    (h₁ : M₁ ⊆ M) (h₂ : M₂ ⊆ M)
    (S₁ : IntervalTypeFin sig F M₁) (S₂ : IntervalTypeFin sig F M₂) :
    IntervalTypeFin sig F M :=
  Finset.univ.filter fun c => weaken h₁ c ∈ S₁ ∧ weaken h₂ c ∈ S₂

/-- Membership in the glued interval set: both restrictions are admissible. -/
theorem mem_intervalGlueFin {M₁ M₂ M : Finset (AtomKind (sigE sig F) 1)}
    (h₁ : M₁ ⊆ M) (h₂ : M₂ ⊆ M)
    (S₁ : IntervalTypeFin sig F M₁) (S₂ : IntervalTypeFin sig F M₂)
    (c : UnaryTypeFin sig F M) :
    c ∈ intervalGlueFin h₁ h₂ S₁ S₂ ↔ weaken h₁ c ∈ S₁ ∧ weaken h₂ c ∈ S₂ := by
  classical
  simp only [intervalGlueFin, Finset.mem_filter, Finset.mem_univ, true_and]

/-- **Glued-set satisfaction (the Fin analog of `intervalHolds_conj_of_both` + its converse, in
one biconditional).** A point satisfies the glued interval set iff it satisfies both factors.
Forward: restrict the realized completion (`partialHolds_weaken`). Backward: the point's
characteristic completion over the ambient `M` restricts to each factor's realized completion by
uniqueness (`partialHolds_eq_charTypeFin`), so it lies in the glue. -/
theorem intervalHoldsFin_glue_iff {M₁ M₂ M : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F)) (h₁ : M₁ ⊆ M) (h₂ : M₂ ⊆ M)
    (S₁ : IntervalTypeFin sig F M₁) (S₂ : IntervalTypeFin sig F M₂) (y : N.carrier) :
    intervalHoldsFin N (intervalGlueFin h₁ h₂ S₁ S₂) y ↔
      intervalHoldsFin N S₁ y ∧ intervalHoldsFin N S₂ y := by
  constructor
  · rintro ⟨c, hcmem, hcy⟩
    rw [mem_intervalGlueFin] at hcmem
    exact ⟨⟨_, hcmem.1, partialHolds_weaken N h₁ hcy⟩,
           ⟨_, hcmem.2, partialHolds_weaken N h₂ hcy⟩⟩
  · rintro ⟨⟨c₁, hc₁S, hc₁y⟩, ⟨c₂, hc₂S, hc₂y⟩⟩
    refine ⟨charTypeFin N M y, ?_, partialHolds_charTypeFin N _ y⟩
    rw [mem_intervalGlueFin, weaken_charTypeFin, weaken_charTypeFin,
        ← partialHolds_eq_charTypeFin N hc₁y, ← partialHolds_eq_charTypeFin N hc₂y]
    exact ⟨hc₁S, hc₂S⟩

/-! ### 10.2 Merged-slot contributions and the choice-compatibility filter -/

/-- The interval-type contribution of a source Fin chain `ψ` at merged interval slot
`t : Fin (k+2)` (the Fin mirror of `chainIntervalType`): `ψ`'s partial admissible set at the
source slot containing `t`, computed by counting source points strictly below `t`. -/
def chainIntervalTypeFin {r : Nat} (ψ : ExistsForallFormulaFin sig F r) {k : Nat}
    (e : Fin (ψ.n + 1) → Fin (k + 1)) (t : Fin (k + 2)) : IntervalTypeFin sig F ψ.M :=
  ψ.intervalType ⟨(Finset.univ.filter (fun i => (e i).castSucc < t)).card,
    Nat.lt_succ_of_le (le_trans (Finset.card_filter_le _ _) (by simp))⟩

/-- **Choice compatibility (the per-point `M`-relative-completions filter).** The Fin replacement
for the total `pointConsistent` + `crossConsistent` pair: the chosen merged point types `pt` must
(1)/(2) restrict on each chain's own atoms to that chain's point type — at a shared merged point
this subsumes point-consistency, since both restrictions are then determined by the one chosen
completion — and (3)/(4) at a merged point pinned by only one chain, restrict on the OTHER
chain's atoms to one of that chain's admissible interval completions at the enclosing slot (the
point-vs-interval axis of Lemma 3.2(1), p.4, exactly as in the total `crossConsistent`, with the
membership now `M₂`-relative). -/
def choiceCompatible {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (m : MergePair ψ₁.n ψ₂.n k)
    (pt : Fin (k + 1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂)) : Prop :=
  (∀ i₁ : Fin (ψ₁.n + 1),
      weaken (subset_mergedM_left ψ₁ ψ₂) (pt (m.e₁ i₁)) = ψ₁.pointType i₁) ∧
  (∀ i₂ : Fin (ψ₂.n + 1),
      weaken (subset_mergedM_right ψ₁ ψ₂) (pt (m.e₂ i₂)) = ψ₂.pointType i₂) ∧
  (∀ i₁ : Fin (ψ₁.n + 1), (∀ i₂, m.e₂ i₂ ≠ m.e₁ i₁) →
      weaken (subset_mergedM_right ψ₁ ψ₂) (pt (m.e₁ i₁))
        ∈ ψ₂.intervalType (intervalSlot m.e₂ (m.e₁ i₁))) ∧
  (∀ i₂ : Fin (ψ₂.n + 1), (∀ i₁, m.e₁ i₁ ≠ m.e₂ i₂) →
      weaken (subset_mergedM_left ψ₁ ψ₂) (pt (m.e₂ i₂))
        ∈ ψ₁.intervalType (intervalSlot m.e₁ (m.e₂ i₂)))

/-! ### 10.3 The merged Fin formula and `conjInterleaveFin` -/

/-- The merged `ExistsForallFormulaFin` of a merge datum and a compatible point-type choice:
`k+1` points over the merged atom set `ψ₁.M ∪ ψ₂.M`, free variables pinned through `e₁`, point
types given by the chosen `M`-relative completions `pt`, and each interval slot carrying the
glued set of both chains' contributions (`intervalGlueFin`). A single `StrictMono` chain of unary
partial types: no arity growth, no alphabet enumeration. -/
noncomputable def mergedFormulaFin {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (m : MergePair ψ₁.n ψ₂.n k)
    (pt : Fin (k + 1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂)) :
    ExistsForallFormulaFin sig F r where
  n := k
  M := mergedM ψ₁ ψ₂
  pin := fun v => m.e₁ (pin₁ v)
  pointType := pt
  intervalType := fun t =>
    intervalGlueFin (subset_mergedM_left ψ₁ ψ₂) (subset_mergedM_right ψ₁ ψ₂)
      (chainIntervalTypeFin ψ₁ m.e₁ t) (chainIntervalTypeFin ψ₂ m.e₂ t)

open Classical in
/-- **`conjInterleaveFin` (Rabinovich Lemma 3.2(1), p.4, per-formula representation).** The
`∨∃∀`-formula whose disjuncts are the merged Fin formulas of all valid merges TOGETHER WITH all
compatible `M`-relative point-type choices, over all merged sizes `k+1 ≤ (n₁+1)+(n₂+1)`. The
enumeration is `Finset.univ` over `MergePair × (merged points → UnaryTypeFin (ψ₁.M ∪ ψ₂.M))` —
finite from the two chain lengths and the merged mentioned-atom set alone. -/
noncomputable def conjInterleaveFin {r : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1)) :
    VeeExistsForallFin sig F r :=
  (List.range (ψ₁.n + ψ₂.n + 2)).flatMap fun k =>
    (Finset.univ.filter fun p :
          MergePair ψ₁.n ψ₂.n k × (Fin (k + 1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂)) =>
        p.1.valid pin₁ pin₂ ∧ choiceCompatible ψ₁ ψ₂ p.1 p.2).toList.map
      fun p => mergedFormulaFin ψ₁ ψ₂ pin₁ p.1 p.2

/-- Membership assembly (the Fin mirror of `mergedFormula_mem_conjInterleave`): a valid merge
with a compatible choice, of size under the enumeration bound, contributes its merged Fin formula
as a disjunct. -/
theorem mergedFormulaFin_mem_conjInterleaveFin {r : Nat}
    (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1))
    {k : Nat} (hk : k < ψ₁.n + ψ₂.n + 2) (m : MergePair ψ₁.n ψ₂.n k)
    (pt : Fin (k + 1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂))
    (hvalid : m.valid pin₁ pin₂) (hcompat : choiceCompatible ψ₁ ψ₂ m pt) :
    mergedFormulaFin ψ₁ ψ₂ pin₁ m pt ∈ conjInterleaveFin ψ₁ ψ₂ pin₁ pin₂ := by
  classical
  unfold conjInterleaveFin
  rw [List.mem_flatMap]
  refine ⟨k, List.mem_range.mpr hk, ?_⟩
  rw [List.mem_map]
  refine ⟨(m, pt), ?_, rfl⟩
  rw [Finset.mem_toList, Finset.mem_filter]
  exact ⟨Finset.mem_univ _, hvalid, hcompat⟩

/-- Reverse membership extraction (the Fin mirror of `exists_mergePair_of_mem`): every disjunct
of `conjInterleaveFin` is the merged Fin formula of some valid merge with a compatible choice. -/
theorem exists_mergeChoice_of_mem {r : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1))
    (φ : ExistsForallFormulaFin sig F r) (hφ : φ ∈ conjInterleaveFin ψ₁ ψ₂ pin₁ pin₂) :
    ∃ (k : Nat) (m : MergePair ψ₁.n ψ₂.n k)
      (pt : Fin (k + 1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂)),
      m.valid pin₁ pin₂ ∧ choiceCompatible ψ₁ ψ₂ m pt ∧
        mergedFormulaFin ψ₁ ψ₂ pin₁ m pt = φ := by
  classical
  unfold conjInterleaveFin at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨k, _, hφk⟩ := hφ
  rw [List.mem_map] at hφk
  obtain ⟨p, hmem, hmf⟩ := hφk
  rw [Finset.mem_toList, Finset.mem_filter] at hmem
  obtain ⟨_, hvalid, hcompat⟩ := hmem
  exact ⟨k, p.1, p.2, hvalid, hcompat, hmf⟩

/-! ### 10.4 Slot-placement lemmas (Fin mirrors of §6c/§8's order-theoretic layer)

Verbatim transcriptions of `chain_interval_clause`, `chainIntervalType_eq_pointSlot`,
`intervalSlot_eq_pointSlot`, and `regions_of_pointSlot` onto the partial relations: their proof
bodies never unfold the satisfaction relation — everything routes through the shared crux
`strictMono_lt_iff_val_lt_filterCard` — so the clause shapes transcribe unchanged. -/

/-- Fin mirror of `chain_interval_clause`: the three `efSatFin` region clauses force, at any
non-chain point `y`, the partial interval type at `y`'s point slot. -/
theorem chain_interval_clauseFin {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormulaFin sig F r) (x : Fin (ψ.n + 1) → N.carrier) (hmono : StrictMono x)
    (hbefore : ∀ y, y < x 0 → intervalHoldsFin N (ψ.intervalType 0) y)
    (hbetw : ∀ (i : Fin ψ.n) (y : N.carrier), x i.castSucc < y → y < x i.succ →
        intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y)
    (hafter : ∀ y : N.carrier, x (Fin.last ψ.n) < y →
        intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y)
    (y : N.carrier) (hy : ∀ j, y ≠ x j)
    (hlt : (Finset.univ.filter (fun i => x i < y)).card < ψ.n + 2) :
    intervalHoldsFin N (ψ.intervalType ⟨(Finset.univ.filter (fun i => x i < y)).card, hlt⟩) y := by
  have hkey : ∀ a : Fin (ψ.n + 1),
      x a < y ↔ a.val < (Finset.univ.filter (fun i => x i < y)).card :=
    fun a => strictMono_lt_iff_val_lt_filterCard x hmono y a
  set c := (Finset.univ.filter (fun i => x i < y)).card with hc
  rcases Nat.lt_or_ge c 1 with hc0 | hc1
  · -- c = 0: y lies before x 0
    have hce : c = 0 := Nat.lt_one_iff.mp hc0
    have hnx0 : ¬ x 0 < y := by rw [hkey 0]; simp [hce]
    have hy0 : y < x 0 := lt_of_le_of_ne (le_of_not_gt hnx0) (hy 0)
    have hidx : (⟨c, hlt⟩ : Fin (ψ.n + 2)) = 0 := by apply Fin.ext; simp [hce]
    rw [hidx]; exact hbefore y hy0
  · rcases Nat.lt_or_ge c (ψ.n + 1) with hcn | hcfull
    · -- 1 ≤ c ≤ n: y lies in the open interval (x_{c-1}, x_c)
      have hc'lt : c - 1 < ψ.n := by omega
      let i : Fin ψ.n := ⟨c - 1, hc'lt⟩
      have hcsval : (i.castSucc).val = c - 1 := rfl
      have hsval : (i.succ).val = c := by simp [i, Fin.succ]; omega
      have hlo : x i.castSucc < y := by rw [hkey i.castSucc, hcsval]; omega
      have hhi : y < x i.succ := by
        have : ¬ x i.succ < y := by rw [hkey i.succ, hsval]; omega
        exact lt_of_le_of_ne (le_of_not_gt this) (hy i.succ)
      have hidx : (⟨c, hlt⟩ : Fin (ψ.n + 2)) = i.succ.castSucc := by
        apply Fin.ext; simp only [Fin.coe_castSucc]; omega
      rw [hidx]; exact hbetw i y hlo hhi
    · -- c = n+1: y lies after x (last)
      have hce : c = ψ.n + 1 := by omega
      have hla : x (Fin.last ψ.n) < y := by
        rw [hkey (Fin.last ψ.n)]; simp [Fin.val_last, hce]
      have hidx : (⟨c, hlt⟩ : Fin (ψ.n + 2)) = Fin.last (ψ.n + 1) := by
        apply Fin.ext; simp [Fin.val_last, hce]
      rw [hidx]; exact hafter y hla

/-- Fin mirror of `chainIntervalType_eq_pointSlot`: under a realized rank merge, the source
chain's merged interval-slot set equals `ψ`'s partial interval type at the point slot of `y`. -/
theorem chainIntervalTypeFin_eq_pointSlot {r k : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormulaFin sig F r) (e : Fin (ψ.n + 1) → Fin (k + 1))
    (x : Fin (ψ.n + 1) → N.carrier) (w : Fin (k + 1) → N.carrier) (hw : StrictMono w)
    (hrt : ∀ i, w (e i) = x i) (y : N.carrier)
    (t : Fin (k + 2)) (ht : t.val = (Finset.univ.filter (fun j => w j < y)).card)
    (hlt : (Finset.univ.filter (fun i => x i < y)).card < ψ.n + 2) :
    chainIntervalTypeFin ψ e t
      = ψ.intervalType ⟨(Finset.univ.filter (fun i => x i < y)).card, hlt⟩ := by
  have hfe : (Finset.univ.filter (fun i => (e i).castSucc < t))
      = (Finset.univ.filter (fun i => x i < y)) := by
    apply Finset.filter_congr
    intro i _
    rw [Fin.lt_def, Fin.coe_castSucc, ht, ← hrt i]
    exact (strictMono_lt_iff_val_lt_filterCard w hw y (e i)).symm
  unfold chainIntervalTypeFin
  congr 1
  apply Fin.ext
  simp only [Fin.val_mk, hfe]

/-- Fin mirror of `intervalSlot_eq_pointSlot`: under a realized rank merge, the `ψ`-interval
slot of a merged position `j` equals `ψ`'s partial interval type at the point slot of
`p = w j`. -/
theorem intervalSlot_eq_pointSlotFin {r k : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormulaFin sig F r) (e : Fin (ψ.n + 1) → Fin (k + 1))
    (x : Fin (ψ.n + 1) → N.carrier) (w : Fin (k + 1) → N.carrier) (hw : StrictMono w)
    (hrt : ∀ i, w (e i) = x i) (j : Fin (k + 1)) (p : N.carrier) (hp : w j = p)
    (hlt : (Finset.univ.filter (fun i => x i < p)).card < ψ.n + 2) :
    ψ.intervalType (intervalSlot e j)
      = ψ.intervalType ⟨(Finset.univ.filter (fun i => x i < p)).card, hlt⟩ := by
  have hfe : (Finset.univ.filter (fun i => e i < j))
      = (Finset.univ.filter (fun i => x i < p)) := by
    apply Finset.filter_congr
    intro i _
    rw [← hrt i, ← hp, hw.lt_iff_lt]
  congr 1
  apply Fin.ext
  show belowCount e j = (Finset.univ.filter (fun i => x i < p)).card
  unfold belowCount
  exact congrArg Finset.card hfe

/-- Fin mirror of `regions_of_pointSlot`: from a single point-slot clause recover the three
`efSatFin` region clauses. -/
theorem regions_of_pointSlotFin {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormulaFin sig F r) (x : Fin (ψ.n + 1) → N.carrier) (hmono : StrictMono x)
    (hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => x i < y)).card < ψ.n + 2)
    (hpts : ∀ (y : N.carrier), (∀ j, y ≠ x j) →
        intervalHoldsFin N (ψ.intervalType
          ⟨(Finset.univ.filter (fun i => x i < y)).card, hlt_bound y⟩) y) :
    (∀ y, y < x 0 → intervalHoldsFin N (ψ.intervalType 0) y) ∧
    (∀ (i : Fin ψ.n) y, x i.castSucc < y → y < x i.succ →
        intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y) ∧
    (∀ y, x (Fin.last ψ.n) < y →
        intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y) := by
  refine ⟨?_, ?_, ?_⟩
  · -- before x₀: count = 0
    intro y hy0
    have hyne : ∀ j, y ≠ x j :=
      fun j => ne_of_lt (lt_of_lt_of_le hy0 (hmono.monotone (Fin.zero_le j)))
    have hcnt : (Finset.univ.filter (fun i => x i < y)).card = 0 := by
      have h := (strictMono_lt_iff_val_lt_filterCard x hmono y 0).not.mp
        (not_lt.mpr (le_of_lt hy0))
      rw [Fin.val_zero] at h; omega
    have hidx : (⟨_, hlt_bound y⟩ : Fin (ψ.n + 2)) = 0 := Fin.ext (by simp [hcnt])
    have h := hpts y hyne
    rwa [hidx] at h
  · -- open interval (x_{i₀}, x_{i₀+1}): count = i₀+1
    intro i₀ y hlo hhi
    have hyne : ∀ j, y ≠ x j := by
      intro j heq
      subst heq
      have ha := hmono.lt_iff_lt.mp hlo
      have hb := hmono.lt_iff_lt.mp hhi
      rw [Fin.lt_def, Fin.coe_castSucc] at ha
      rw [Fin.lt_def, Fin.val_succ] at hb
      omega
    have hcnt : (Finset.univ.filter (fun i => x i < y)).card = i₀.val + 1 := by
      have hlo' := (strictMono_lt_iff_val_lt_filterCard x hmono y i₀.castSucc).mp hlo
      rw [Fin.coe_castSucc] at hlo'
      have hhi' := (strictMono_lt_iff_val_lt_filterCard x hmono y i₀.succ).not.mp
        (not_lt.mpr (le_of_lt hhi))
      rw [Fin.val_succ] at hhi'; omega
    have hidx : (⟨_, hlt_bound y⟩ : Fin (ψ.n + 2)) = i₀.succ.castSucc := by
      apply Fin.ext; simp only [Fin.coe_castSucc, Fin.val_succ]; omega
    have h := hpts y hyne
    rwa [hidx] at h
  · -- after xₙ: count = n+1
    intro y hlast
    have hyne : ∀ j, y ≠ x j := by
      intro j heq
      subst heq
      exact absurd hlast (not_lt.mpr (hmono.monotone (Fin.le_last j)))
    have hcnt : (Finset.univ.filter (fun i => x i < y)).card = ψ.n + 1 := by
      have hla := (strictMono_lt_iff_val_lt_filterCard x hmono y (Fin.last ψ.n)).mp hlast
      rw [Fin.val_last] at hla
      have hle := hlt_bound y
      omega
    have hidx : (⟨_, hlt_bound y⟩ : Fin (ψ.n + 2)) = Fin.last (ψ.n + 1) := by
      apply Fin.ext; simp [Fin.val_last, hcnt]
    have h := hpts y hyne
    rwa [hidx] at h

/-! ### 10.5 Forward direction -/

/-- **Forward direction of Lemma 3.2(1) (Rabinovich, p.4), per-formula representation.** If both
per-formula `∃∀`-formulas are satisfied at the same environment, their `conjInterleaveFin` is
satisfied. The realized merge is the same sorted-union rank construction as the total
`conjInterleave_forward`; the choice of merged point types is CANONICAL — the characteristic
completion of each merged point over the merged atom set (`charTypeFin`) — and its compatibility
constraints discharge by partial-type uniqueness (`partialHolds_eq_charTypeFin`, the Fin engine
replacing `nf_eval_unique`) against the witnesses' point clauses (restrictions) and the other
chain's interval clauses (cross memberships, placed by `intervalSlot_eq_pointSlotFin` +
`chain_interval_clauseFin`). -/
theorem conjInterleaveFin_forward {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (h₁ : efSatFin N env ψ₁) (h₂ : efSatFin N env ψ₂) :
    veeSatFin N env (conjInterleaveFin ψ₁ ψ₂ ψ₁.pin ψ₂.pin) := by
  classical
  -- Extract the two witnessing chains.
  obtain ⟨x₁, hx₁mono, hx₁pin, hx₁pt, hx₁before, hx₁betw, hx₁after⟩ := h₁
  obtain ⟨x₂, hx₂mono, hx₂pin, hx₂pt, hx₂before, hx₂betw, hx₂after⟩ := h₂
  -- The sorted-union carrier and its cardinality.
  set S := mergedSet N x₁ x₂ with hSdef
  have hmem₁ : ∀ i, x₁ i ∈ S := by
    intro i
    simp only [hSdef, mergedSet, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inl ⟨i, rfl⟩
  have hmem₂ : ∀ i, x₂ i ∈ S := by
    intro i
    simp only [hSdef, mergedSet, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inr ⟨i, rfl⟩
  have hcard : S.card = (S.card - 1) + 1 := mergedSet_card_succ N x₁ x₂
  set k := S.card - 1 with hkdef
  -- The merged chain, the two rank maps, and the canonical point-type choice.
  let w : Fin (k + 1) → N.carrier := fun j => S.orderEmbOfFin hcard j
  let e₁ : Fin (ψ₁.n + 1) → Fin (k + 1) := fun i => (S.orderIsoOfFin hcard).symm ⟨x₁ i, hmem₁ i⟩
  let e₂ : Fin (ψ₂.n + 1) → Fin (k + 1) := fun i => (S.orderIsoOfFin hcard).symm ⟨x₂ i, hmem₂ i⟩
  let pt : Fin (k + 1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂) :=
    fun j => charTypeFin N (mergedM ψ₁ ψ₂) (w j)
  have hw : StrictMono w := (S.orderEmbOfFin hcard).strictMono
  have he₁ : StrictMono e₁ := strictMono_rank S hcard x₁ hx₁mono hmem₁
  have he₂ : StrictMono e₂ := strictMono_rank S hcard x₂ hx₂mono hmem₂
  have hrt₁ : ∀ i, w (e₁ i) = x₁ i := fun i => orderEmbOfFin_symm_apply S hcard (x₁ i) (hmem₁ i)
  have hrt₂ : ∀ i, w (e₂ i) = x₂ i := fun i => orderEmbOfFin_symm_apply S hcard (x₂ i) (hmem₂ i)
  -- Joint surjectivity of the rank maps.
  have hsurj : ∀ j : Fin (k + 1), (∃ i, e₁ i = j) ∨ (∃ i, e₂ i = j) := by
    intro j
    have hmemj : S.orderEmbOfFin hcard j ∈ S := Finset.orderEmbOfFin_mem S hcard j
    have hmemj' := hmemj
    simp only [hSdef, mergedSet, Finset.mem_union, Finset.mem_image, Finset.mem_univ,
      true_and] at hmemj'
    rcases hmemj' with ⟨i, hi⟩ | ⟨i, hi⟩
    · refine Or.inl ⟨i, ?_⟩
      show (S.orderIsoOfFin hcard).symm ⟨x₁ i, hmem₁ i⟩ = j
      rw [show (⟨x₁ i, hmem₁ i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
    · refine Or.inr ⟨i, ?_⟩
      show (S.orderIsoOfFin hcard).symm ⟨x₂ i, hmem₂ i⟩ = j
      rw [show (⟨x₂ i, hmem₂ i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
  -- Pin compatibility.
  have hpin_comp : ∀ v, e₁ (ψ₁.pin v) = e₂ (ψ₂.pin v) := by
    intro v
    have hval : x₁ (ψ₁.pin v) = x₂ (ψ₂.pin v) := by rw [← hx₁pin v, ← hx₂pin v]
    show (S.orderIsoOfFin hcard).symm ⟨x₁ (ψ₁.pin v), hmem₁ (ψ₁.pin v)⟩
       = (S.orderIsoOfFin hcard).symm ⟨x₂ (ψ₂.pin v), hmem₂ (ψ₂.pin v)⟩
    congr 1
    exact Subtype.ext hval
  -- Interval-slot cardinality bounds (each chain has `n+1` points).
  have hlt_bound₁ : ∀ y : N.carrier,
      (Finset.univ.filter (fun i => x₁ i < y)).card < ψ₁.n + 2 := by
    intro y
    have h := Finset.card_filter_le (Finset.univ : Finset (Fin (ψ₁.n + 1))) (fun i => x₁ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at h; omega
  have hlt_bound₂ : ∀ y : N.carrier,
      (Finset.univ.filter (fun i => x₂ i < y)).card < ψ₂.n + 2 := by
    intro y
    have h := Finset.card_filter_le (Finset.univ : Finset (Fin (ψ₂.n + 1))) (fun i => x₂ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at h; omega
  -- Compatibility of the canonical choice: restrictions read back the chains' point types...
  have hcompat₁ : ∀ i₁ : Fin (ψ₁.n + 1),
      weaken (subset_mergedM_left ψ₁ ψ₂) (pt (e₁ i₁)) = ψ₁.pointType i₁ := by
    intro i₁
    show weaken (subset_mergedM_left ψ₁ ψ₂) (charTypeFin N (mergedM ψ₁ ψ₂) (w (e₁ i₁)))
        = ψ₁.pointType i₁
    rw [weaken_charTypeFin, hrt₁ i₁]
    exact (partialHolds_eq_charTypeFin N (hx₁pt i₁)).symm
  have hcompat₂ : ∀ i₂ : Fin (ψ₂.n + 1),
      weaken (subset_mergedM_right ψ₁ ψ₂) (pt (e₂ i₂)) = ψ₂.pointType i₂ := by
    intro i₂
    show weaken (subset_mergedM_right ψ₁ ψ₂) (charTypeFin N (mergedM ψ₁ ψ₂) (w (e₂ i₂)))
        = ψ₂.pointType i₂
    rw [weaken_charTypeFin, hrt₂ i₂]
    exact (partialHolds_eq_charTypeFin N (hx₂pt i₂)).symm
  -- ... and cross restrictions land in the other chain's interval set (uniqueness readback).
  have hcross₁ : ∀ i₁ : Fin (ψ₁.n + 1), (∀ i₂, e₂ i₂ ≠ e₁ i₁) →
      weaken (subset_mergedM_right ψ₁ ψ₂) (pt (e₁ i₁))
        ∈ ψ₂.intervalType (intervalSlot e₂ (e₁ i₁)) := by
    intro i₁ hint
    have hy₂p : ∀ i₂, w (e₁ i₁) ≠ x₂ i₂ := by
      intro i₂ heq
      exact hint i₂ (hw.injective (by rw [hrt₂ i₂]; exact heq.symm))
    rw [intervalSlot_eq_pointSlotFin N ψ₂ e₂ x₂ w hw hrt₂ (e₁ i₁) (w (e₁ i₁)) rfl
          (hlt_bound₂ (w (e₁ i₁)))]
    obtain ⟨c₂, hc₂S, hc₂y⟩ := chain_interval_clauseFin N ψ₂ x₂ hx₂mono hx₂before hx₂betw
      hx₂after (w (e₁ i₁)) hy₂p (hlt_bound₂ (w (e₁ i₁)))
    show weaken (subset_mergedM_right ψ₁ ψ₂) (charTypeFin N (mergedM ψ₁ ψ₂) (w (e₁ i₁))) ∈ _
    rw [weaken_charTypeFin, ← partialHolds_eq_charTypeFin N hc₂y]
    exact hc₂S
  have hcross₂ : ∀ i₂ : Fin (ψ₂.n + 1), (∀ i₁, e₁ i₁ ≠ e₂ i₂) →
      weaken (subset_mergedM_left ψ₁ ψ₂) (pt (e₂ i₂))
        ∈ ψ₁.intervalType (intervalSlot e₁ (e₂ i₂)) := by
    intro i₂ hint
    have hy₁p : ∀ i₁, w (e₂ i₂) ≠ x₁ i₁ := by
      intro i₁ heq
      exact hint i₁ (hw.injective (by rw [hrt₁ i₁]; exact heq.symm))
    rw [intervalSlot_eq_pointSlotFin N ψ₁ e₁ x₁ w hw hrt₁ (e₂ i₂) (w (e₂ i₂)) rfl
          (hlt_bound₁ (w (e₂ i₂)))]
    obtain ⟨c₁, hc₁S, hc₁y⟩ := chain_interval_clauseFin N ψ₁ x₁ hx₁mono hx₁before hx₁betw
      hx₁after (w (e₂ i₂)) hy₁p (hlt_bound₁ (w (e₂ i₂)))
    show weaken (subset_mergedM_left ψ₁ ψ₂) (charTypeFin N (mergedM ψ₁ ψ₂) (w (e₂ i₂))) ∈ _
    rw [weaken_charTypeFin, ← partialHolds_eq_charTypeFin N hc₁y]
    exact hc₁S
  -- Merged interval clause: at any merged interior point `y` in slot `t`, both chains' partial
  -- interval sets are satisfied, hence the glued set is (`intervalHoldsFin_glue_iff`).
  have merged_clause : ∀ (y : N.carrier) (t : Fin (k + 2)),
      (∀ j, y ≠ w j) → t.val = (Finset.univ.filter (fun j => w j < y)).card →
      intervalHoldsFin N
        (intervalGlueFin (subset_mergedM_left ψ₁ ψ₂) (subset_mergedM_right ψ₁ ψ₂)
          (chainIntervalTypeFin ψ₁ e₁ t) (chainIntervalTypeFin ψ₂ e₂ t)) y := by
    intro y t hyne ht
    have hy₁ : ∀ i, y ≠ x₁ i := fun i => by rw [← hrt₁ i]; exact hyne (e₁ i)
    have hy₂ : ∀ i, y ≠ x₂ i := fun i => by rw [← hrt₂ i]; exact hyne (e₂ i)
    rw [intervalHoldsFin_glue_iff,
        chainIntervalTypeFin_eq_pointSlot N ψ₁ e₁ x₁ w hw hrt₁ y t ht (hlt_bound₁ y),
        chainIntervalTypeFin_eq_pointSlot N ψ₂ e₂ x₂ w hw hrt₂ y t ht (hlt_bound₂ y)]
    exact ⟨chain_interval_clauseFin N ψ₁ x₁ hx₁mono hx₁before hx₁betw hx₁after y hy₁
        (hlt_bound₁ y),
      chain_interval_clauseFin N ψ₂ x₂ hx₂mono hx₂before hx₂betw hx₂after y hy₂
        (hlt_bound₂ y)⟩
  -- Enumeration bound: `k+1 = S.card ≤ (n₁+1)+(n₂+1)`.
  have hk_bound : k < ψ₁.n + ψ₂.n + 2 := by
    have hcu : S.card ≤ (Finset.univ.image x₁).card + (Finset.univ.image x₂).card := by
      rw [hSdef]; exact Finset.card_union_le _ _
    have h1 : (Finset.univ.image x₁).card ≤ ψ₁.n + 1 := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin (ψ₁.n + 1)))) (f := x₁)
      simpa using this
    have h2 : (Finset.univ.image x₂).card ≤ ψ₂.n + 1 := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin (ψ₂.n + 1)))) (f := x₂)
      simpa using this
    omega
  -- Assemble the disjunct and its satisfaction.
  refine ⟨mergedFormulaFin ψ₁ ψ₂ ψ₁.pin ⟨e₁, e₂⟩ pt, ?_, ?_⟩
  · exact mergedFormulaFin_mem_conjInterleaveFin ψ₁ ψ₂ ψ₁.pin ψ₂.pin hk_bound ⟨e₁, e₂⟩ pt
      ⟨he₁, he₂, hsurj, hpin_comp⟩ ⟨hcompat₁, hcompat₂, hcross₁, hcross₂⟩
  · refine ⟨w, hw, ?_, ?_, ?_, ?_, ?_⟩
    · -- pinning
      intro v
      show env v = w (e₁ (ψ₁.pin v))
      rw [hrt₁ (ψ₁.pin v)]; exact hx₁pin v
    · -- point types: the canonical choice is realized by construction
      intro j
      show partialHolds N (charTypeFin N (mergedM ψ₁ ψ₂) (w j)) (w j)
      exact partialHolds_charTypeFin N _ _
    · -- before x₀
      intro y hy0
      have hyne : ∀ j, y ≠ w j :=
        fun j => ne_of_lt (lt_of_lt_of_le hy0 (hw.monotone (Fin.zero_le j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = 0 := by
        have hlt0 := (strictMono_lt_iff_val_lt_filterCard w hw y 0).not.mp
          (not_lt.mpr (le_of_lt hy0))
        rw [Fin.val_zero] at hlt0; omega
      exact merged_clause y 0 hyne (by rw [hcnt]; rfl)
    · -- between x_{i₀} and x_{i₀+1}
      intro i₀ y hlo hhi
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        have ha := hw.lt_iff_lt.mp hlo
        have hb := hw.lt_iff_lt.mp hhi
        -- `rw [Fin.lt_def]` no longer matches: the goal carries `Fin.instLinearOrder.toLT`
        -- while the lemma's pattern carries `instLTFin`. Restate at the `.val` level instead.
        have ha' : i₀.castSucc.val < j.val := ha
        have hb' : j.val < i₀.succ.val := hb
        simp only [Fin.coe_castSucc, Fin.val_succ] at ha' hb'
        omega
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = i₀.val + 1 := by
        have hlo' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.castSucc).mp hlo
        rw [Fin.coe_castSucc] at hlo'
        have hhi' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.succ).not.mp
          (not_lt.mpr (le_of_lt hhi))
        rw [Fin.val_succ] at hhi'; omega
      exact merged_clause y i₀.succ.castSucc hyne (by rw [Fin.coe_castSucc, Fin.val_succ]; omega)
    · -- after xₙ
      intro y hlast
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        exact absurd hlast (not_lt.mpr (hw.monotone (Fin.le_last j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = k + 1 := by
        have hla := (strictMono_lt_iff_val_lt_filterCard w hw y (Fin.last k)).mp hlast
        rw [Fin.val_last] at hla
        have hle : (Finset.univ.filter (fun j => w j < y)).card ≤ k + 1 := by
          have h := Finset.card_filter_le (Finset.univ : Finset (Fin (k + 1))) (fun j => w j < y)
          simp only [Finset.card_univ, Fintype.card_fin] at h; omega
        omega
      exact merged_clause y (Fin.last (k + 1)) hyne (by rw [Fin.val_last]; omega)

/-! ### 10.6 Backward direction and the biconditional -/

/-- **Backward direction of Lemma 3.2(1) (Rabinovich, p.4), per-formula representation.** From a
satisfied disjunct `mergedFormulaFin ψ₁ ψ₂ ψ₁.pin m pt` with witness chain `w`, project each
source chain `xₗ i := w (m.eₗ i)`. Point types read back through the `choiceCompatible`
restriction equations (1)/(2) + `partialHolds_weaken`; each source-chain interval region is
recovered as a point-slot clause by the same two-case split as the total backward direction —
at a non-merged point the glued slot projects to each factor (`intervalHoldsFin_glue_iff`), and
at a merged point pinned only by the other chain the cross constraints (3)/(4) supply the
admissible restriction realized there. `regions_of_pointSlotFin` reassembles the three `efSatFin`
region clauses. -/
theorem conjInterleaveFin_backward {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (h : veeSatFin N env (conjInterleaveFin ψ₁ ψ₂ ψ₁.pin ψ₂.pin)) :
    efSatFin N env ψ₁ ∧ efSatFin N env ψ₂ := by
  classical
  obtain ⟨φ, hφmem, hef⟩ := h
  obtain ⟨k, m, pt, hvalid, hcompat, hmf⟩ :=
    exists_mergeChoice_of_mem ψ₁ ψ₂ ψ₁.pin ψ₂.pin φ hφmem
  rw [← hmf] at hef
  obtain ⟨he₁, he₂, hsurj, hpin_comp⟩ := hvalid
  obtain ⟨hcompat₁, hcompat₂, hcross₁, hcross₂⟩ := hcompat
  set e₁ := m.e₁ with he₁def
  set e₂ := m.e₂ with he₂def
  obtain ⟨w, hw, hwpin, hwpt, hwbefore, hwbetw, hwafter⟩ := hef
  -- Projected source chains.
  let x₁ : Fin (ψ₁.n + 1) → N.carrier := fun i => w (e₁ i)
  let x₂ : Fin (ψ₂.n + 1) → N.carrier := fun i => w (e₂ i)
  have hx₁mono : StrictMono x₁ := hw.comp he₁
  have hx₂mono : StrictMono x₂ := hw.comp he₂
  -- Interval-slot cardinality bounds.
  have hlt_bound₁ : ∀ y : N.carrier, (Finset.univ.filter (fun i => x₁ i < y)).card < ψ₁.n + 2 := by
    intro y
    have h := Finset.card_filter_le (Finset.univ : Finset (Fin (ψ₁.n + 1))) (fun i => x₁ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at h; omega
  have hlt_bound₂ : ∀ y : N.carrier, (Finset.univ.filter (fun i => x₂ i < y)).card < ψ₂.n + 2 := by
    intro y
    have h := Finset.card_filter_le (Finset.univ : Finset (Fin (ψ₂.n + 1))) (fun i => x₂ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at h; omega
  have hlt_bound_w : ∀ y : N.carrier, (Finset.univ.filter (fun j => w j < y)).card < k + 2 := by
    intro y
    have h := Finset.card_filter_le (Finset.univ) (fun j => w j < y)
    rw [Finset.card_univ, Fintype.card_fin] at h
    exact Nat.lt_succ_of_le h
  -- Point-slot clause for chain 1.
  have hpts₁ : ∀ (y : N.carrier), (∀ j, y ≠ x₁ j) →
      intervalHoldsFin N (ψ₁.intervalType
        ⟨(Finset.univ.filter (fun i => x₁ i < y)).card, hlt_bound₁ y⟩) y := by
    intro y hyne
    by_cases hmerged : ∀ j, y ≠ w j
    · -- y not a merged point: merged glued clause, projected left, placed at the point slot.
      have hclause := chain_interval_clauseFin N (mergedFormulaFin ψ₁ ψ₂ ψ₁.pin m pt) w hw
        hwbefore hwbetw hwafter y hmerged (hlt_bound_w y)
      have hclause' : intervalHoldsFin N
          (intervalGlueFin (subset_mergedM_left ψ₁ ψ₂) (subset_mergedM_right ψ₁ ψ₂)
            (chainIntervalTypeFin ψ₁ e₁
              ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩)
            (chainIntervalTypeFin ψ₂ e₂
              ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩)) y := hclause
      have hleft := ((intervalHoldsFin_glue_iff N _ _ _ _ y).mp hclause').1
      rwa [chainIntervalTypeFin_eq_pointSlot N ψ₁ e₁ x₁ w hw (fun i => rfl) y
          ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩ rfl
          (hlt_bound₁ y)] at hleft
    · -- y = w j is chain 2's interior existential point.
      push_neg at hmerged
      obtain ⟨j, hj⟩ := hmerged
      have hjne1 : ∀ i, e₁ i ≠ j := by
        intro i heq
        exact hyne i (by show y = w (e₁ i); rw [hj, heq])
      obtain ⟨i', hi'⟩ : ∃ i', e₂ i' = j := by
        rcases hsurj j with ⟨i, hi⟩ | hh
        · exact absurd hi (hjne1 i)
        · exact hh
      have hmem : weaken (subset_mergedM_left ψ₁ ψ₂) (pt (e₂ i'))
          ∈ ψ₁.intervalType (intervalSlot e₁ (e₂ i')) :=
        hcross₂ i' (fun i₁ => by rw [hi']; exact hjne1 i₁)
      have hptj : partialHolds N (pt (e₂ i')) y := by
        have h0 : partialHolds N (pt j) (w j) := hwpt j
        rw [← hj] at h0
        rw [hi']
        exact h0
      have hih : intervalHoldsFin N (ψ₁.intervalType (intervalSlot e₁ (e₂ i'))) y :=
        ⟨_, hmem, partialHolds_weaken N _ hptj⟩
      rwa [intervalSlot_eq_pointSlotFin N ψ₁ e₁ x₁ w hw (fun i => rfl) (e₂ i') y
          (by rw [hi']; exact hj.symm) (hlt_bound₁ y)] at hih
  -- Point-slot clause for chain 2 (symmetric).
  have hpts₂ : ∀ (y : N.carrier), (∀ j, y ≠ x₂ j) →
      intervalHoldsFin N (ψ₂.intervalType
        ⟨(Finset.univ.filter (fun i => x₂ i < y)).card, hlt_bound₂ y⟩) y := by
    intro y hyne
    by_cases hmerged : ∀ j, y ≠ w j
    · have hclause := chain_interval_clauseFin N (mergedFormulaFin ψ₁ ψ₂ ψ₁.pin m pt) w hw
        hwbefore hwbetw hwafter y hmerged (hlt_bound_w y)
      have hclause' : intervalHoldsFin N
          (intervalGlueFin (subset_mergedM_left ψ₁ ψ₂) (subset_mergedM_right ψ₁ ψ₂)
            (chainIntervalTypeFin ψ₁ e₁
              ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩)
            (chainIntervalTypeFin ψ₂ e₂
              ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩)) y := hclause
      have hright := ((intervalHoldsFin_glue_iff N _ _ _ _ y).mp hclause').2
      rwa [chainIntervalTypeFin_eq_pointSlot N ψ₂ e₂ x₂ w hw (fun i => rfl) y
          ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩ rfl
          (hlt_bound₂ y)] at hright
    · push_neg at hmerged
      obtain ⟨j, hj⟩ := hmerged
      have hjne2 : ∀ i, e₂ i ≠ j := by
        intro i heq
        exact hyne i (by show y = w (e₂ i); rw [hj, heq])
      obtain ⟨i', hi'⟩ : ∃ i', e₁ i' = j := by
        rcases hsurj j with hh | ⟨i, hi⟩
        · exact hh
        · exact absurd hi (hjne2 i)
      have hmem : weaken (subset_mergedM_right ψ₁ ψ₂) (pt (e₁ i'))
          ∈ ψ₂.intervalType (intervalSlot e₂ (e₁ i')) :=
        hcross₁ i' (fun i₂ => by rw [hi']; exact hjne2 i₂)
      have hptj : partialHolds N (pt (e₁ i')) y := by
        have h0 : partialHolds N (pt j) (w j) := hwpt j
        rw [← hj] at h0
        rw [hi']
        exact h0
      have hih : intervalHoldsFin N (ψ₂.intervalType (intervalSlot e₂ (e₁ i'))) y :=
        ⟨_, hmem, partialHolds_weaken N _ hptj⟩
      rwa [intervalSlot_eq_pointSlotFin N ψ₂ e₂ x₂ w hw (fun i => rfl) (e₁ i') y
          (by rw [hi']; exact hj.symm) (hlt_bound₂ y)] at hih
  -- Assemble both `efSatFin`s.
  refine ⟨?_, ?_⟩
  · refine ⟨x₁, hx₁mono, ?_, ?_, ?_, ?_, ?_⟩
    · intro v; show env v = w (e₁ (ψ₁.pin v)); exact hwpin v
    · intro j
      show partialHolds N (ψ₁.pointType j) (w (e₁ j))
      rw [← hcompat₁ j]
      exact partialHolds_weaken N _ (hwpt (e₁ j))
    · exact (regions_of_pointSlotFin N ψ₁ x₁ hx₁mono hlt_bound₁ hpts₁).1
    · exact (regions_of_pointSlotFin N ψ₁ x₁ hx₁mono hlt_bound₁ hpts₁).2.1
    · exact (regions_of_pointSlotFin N ψ₁ x₁ hx₁mono hlt_bound₁ hpts₁).2.2
  · refine ⟨x₂, hx₂mono, ?_, ?_, ?_, ?_, ?_⟩
    · intro v
      show env v = w (e₂ (ψ₂.pin v))
      rw [← hpin_comp v]; exact hwpin v
    · intro j
      show partialHolds N (ψ₂.pointType j) (w (e₂ j))
      rw [← hcompat₂ j]
      exact partialHolds_weaken N _ (hwpt (e₂ j))
    · exact (regions_of_pointSlotFin N ψ₂ x₂ hx₂mono hlt_bound₂ hpts₂).1
    · exact (regions_of_pointSlotFin N ψ₂ x₂ hx₂mono hlt_bound₂ hpts₂).2.1
    · exact (regions_of_pointSlotFin N ψ₂ x₂ hx₂mono hlt_bound₂ hpts₂).2.2

/-- **`conjInterleaveFin` characterization (Rabinovich Lemma 3.2(1), p.4, per-formula
representation).** The per-formula `∨∃∀`-formula `conjInterleaveFin ψ₁ ψ₂ ψ₁.pin ψ₂.pin` is
satisfied at `env` exactly when both per-formula `∃∀` conjuncts are. The `∧`-closure step
feeding `veeConjFin` (Lemma 3.4-∧, p.5). -/
theorem conjInterleaveFin_iff {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r) :
    veeSatFin N env (conjInterleaveFin ψ₁ ψ₂ ψ₁.pin ψ₂.pin) ↔
      efSatFin N env ψ₁ ∧ efSatFin N env ψ₂ := by
  constructor
  · exact conjInterleaveFin_backward N env ψ₁ ψ₂
  · rintro ⟨h₁, h₂⟩
    exact conjInterleaveFin_forward N env ψ₁ ψ₂ h₁ h₂

/-! ### 10.7 `veeConjFin` — conjunction closure of per-formula ∨∃∀-formulas (Lemma 3.4-∧, p.5) -/

/-- Fin mirror of `veeSat_flatMap`: `veeSatFin` through a `flatMap`. -/
theorem veeSatFin_flatMap {r : Nat} {α : Type*} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (l : List α) (f : α → VeeExistsForallFin sig F r) :
    veeSatFin N env (l.flatMap f) ↔ ∃ a ∈ l, veeSatFin N env (f a) := by
  simp only [veeSatFin, List.mem_flatMap]
  constructor
  · rintro ⟨χ, ⟨a, ha, hχ⟩, hsat⟩
    exact ⟨a, ha, χ, hχ, hsat⟩
  · rintro ⟨a, ha, χ, hχ, hsat⟩
    exact ⟨χ, ⟨a, ha, hχ⟩, hsat⟩

/-- **`veeConjFin` (Rabinovich Lemma 3.4, ∧-part, p.5, per-formula representation).** The
conjunction of two per-formula `∨∃∀`-formulas, built by distributing ∧ over both disjunctions
and realizing each pairwise conjunct as `conjInterleaveFin`. -/
noncomputable def veeConjFin {r : Nat} (Ψ₁ Ψ₂ : VeeExistsForallFin sig F r) :
    VeeExistsForallFin sig F r :=
  Ψ₁.flatMap fun ψ => Ψ₂.flatMap fun φ => conjInterleaveFin ψ φ ψ.pin φ.pin

/-- **Conjunction closure (Lemma 3.4, ∧-part, p.5, per-formula representation).**
`veeConjFin Ψ₁ Ψ₂` is satisfied at `env` exactly when both `Ψ₁` and `Ψ₂` are. -/
theorem veeConjFin_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (Ψ₁ Ψ₂ : VeeExistsForallFin sig F r) :
    veeSatFin N env (veeConjFin Ψ₁ Ψ₂) ↔ veeSatFin N env Ψ₁ ∧ veeSatFin N env Ψ₂ := by
  unfold veeConjFin
  rw [veeSatFin_flatMap]
  constructor
  · rintro ⟨ψ, hψ, hrest⟩
    rw [veeSatFin_flatMap] at hrest
    obtain ⟨φ, hφ, hpair⟩ := hrest
    rw [conjInterleaveFin_iff] at hpair
    obtain ⟨e1, e2⟩ := hpair
    exact ⟨⟨ψ, hψ, e1⟩, ⟨φ, hφ, e2⟩⟩
  · rintro ⟨⟨ψ, hψ, e1⟩, ⟨φ, hφ, e2⟩⟩
    refine ⟨ψ, hψ, ?_⟩
    rw [veeSatFin_flatMap]
    refine ⟨φ, hφ, ?_⟩
    rw [conjInterleaveFin_iff]
    exact ⟨e1, e2⟩

/-- Fin mirror of `conjInterleave_pin_strictMono`: every disjunct of `conjInterleaveFin` has pin
`= m.e₁ ∘ pin₁`, strictly monotone when `pin₁` is. -/
theorem conjInterleaveFin_pin_strictMono {r : Nat} (ψ₁ ψ₂ : ExistsForallFormulaFin sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1)) (hpin₁ : StrictMono pin₁)
    (χ : ExistsForallFormulaFin sig F r) (hχ : χ ∈ conjInterleaveFin ψ₁ ψ₂ pin₁ pin₂) :
    StrictMono χ.pin := by
  obtain ⟨k, m, pt, hvalid, _, rfl⟩ :=
    exists_mergeChoice_of_mem ψ₁ ψ₂ pin₁ pin₂ χ hχ
  exact hvalid.1.comp hpin₁

/-- Fin mirror of `veeConj_pin_strictMono`: every disjunct of `veeConjFin Ψ₁ Ψ₂` has a strictly
monotone pin, given `Ψ₁`'s disjuncts do. -/
theorem veeConjFin_pin_strictMono {r : Nat} (Ψ₁ Ψ₂ : VeeExistsForallFin sig F r)
    (h₁ : ∀ ψ ∈ Ψ₁, StrictMono ψ.pin)
    (χ : ExistsForallFormulaFin sig F r) (hχ : χ ∈ veeConjFin Ψ₁ Ψ₂) : StrictMono χ.pin := by
  unfold veeConjFin at hχ
  rw [List.mem_flatMap] at hχ
  obtain ⟨ψ, hψmem, hχψ⟩ := hχ
  rw [List.mem_flatMap] at hχψ
  obtain ⟨φ, _, hχφ⟩ := hχψ
  exact conjInterleaveFin_pin_strictMono ψ φ ψ.pin φ.pin (h₁ ψ hψmem) χ hχφ

end Kamp

end Bimodal.Metalogic.WeakCanonical
