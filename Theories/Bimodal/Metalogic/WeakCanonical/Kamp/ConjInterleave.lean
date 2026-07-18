import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType
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

/-! ## 2. Source-chain contributions at a merged slot -/

variable {sig : MonadicSignature} {F : Finset Formula}

/-- The **point-type** contribution of a source chain `ψ` at merged point `j`, as an *optional*
complete type: `some (ψ.pointType i)` when `j = e i` is one of `ψ`'s existential points, and `none`
when `j` is interior to one of `ψ`'s open intervals. Points stay complete `UnaryType` (Def 3.1,
p.4: the `αⱼ` are complete 1-types of real points), so at an existential point the contribution is a
genuine complete type; at an interior point `ψ` imposes only a *partial* interval constraint (a set)
and hence no single complete point type — recorded as `none`. Decidable choice on image membership. -/
noncomputable def chainPointType {r : Nat} (ψ : ExistsForallFormula sig F r) {k : Nat}
    (e : Fin (ψ.n + 1) → Fin (k + 1)) (j : Fin (k + 1)) : Option (UnaryType sig F) :=
  open Classical in
  if h : ∃ i, e i = j then some (ψ.pointType h.choose) else none

/-- The **merged point type** at merged point `j`: the complete point type contributed by whichever
chain pins `j` as an existential point (chain 1 preferred; the two agree when both pin `j`, enforced
by `pointConsistent`). The final fall-through (`ψ₁.pointType 0`) is unreachable for a **valid**
(jointly-surjective) merge, where every merged point is an existential point of chain 1 or chain 2. -/
noncomputable def mergedPointType {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1)) (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1))
    (j : Fin (k + 1)) : UnaryType sig F :=
  open Classical in
  if h : ∃ i, e₁ i = j then ψ₁.pointType h.choose
  else if h2 : ∃ i, e₂ i = j then ψ₂.pointType h2.choose
  else ψ₁.pointType 0

/-- The **interval-type** contribution of a source chain `ψ` at merged interval slot `t : Fin (k+2)`,
now a genuine **partial** `IntervalType` (admissible-completion set, Def 3.1, p.4). The merged
interval `t` sits inside exactly one of `ψ`'s intervals; that interval's slot is computed from `t`
via the count of source points strictly below `t`. -/
def chainIntervalType {r : Nat} (ψ : ExistsForallFormula sig F r) {k : Nat}
    (e : Fin (ψ.n + 1) → Fin (k + 1)) (t : Fin (k + 2)) : IntervalType sig F :=
  ψ.intervalType ⟨(Finset.univ.filter (fun i => (e i).castSucc < t)).card,
    Nat.lt_succ_of_le (le_trans (Finset.card_filter_le _ _) (by simp))⟩

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

/-! ## 4. Point-consistency of a merge -/

/-- The merge is **point-consistent**: whenever both chains pin the *same* merged point
(`e₁ i₁ = e₂ i₂`), their complete point types agree. Since a shared merged point is one real point
of the model, its two complete point contributions coincide by `nf_eval_unique` (see
`pointConsistent_of_holds`). Interval-type consistency is deliberately **not** required (Def 3.1,
p.4 / Lemma 3.2(1), p.4-5: interval predicates are partial, freely conjoinable — an empty merged
slot `S₁ ∩ S₂` is vacuously satisfied when its open interval has no points, so demanding interval
equality would wrongly exclude satisfied configurations). Decidable via `DecidableEq (UnaryType)`
over the two point `Fintype`s. -/
def MergePair.pointConsistent {r k : Nat} (ψ₁ : ExistsForallFormula sig F r)
    (ψ₂ : ExistsForallFormula sig F r) (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1))
    (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) : Prop :=
  ∀ (i₁ : Fin (ψ₁.n + 1)) (i₂ : Fin (ψ₂.n + 1)),
    e₁ i₁ = e₂ i₂ → ψ₁.pointType i₁ = ψ₂.pointType i₂

instance {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r) (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1))
    (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) : Decidable (MergePair.pointConsistent ψ₁ ψ₂ e₁ e₂) := by
  unfold MergePair.pointConsistent
  infer_instance

/-! ## 4a. Point-vs-interval cross-consistency of a merge -/

/-- **Point-vs-interval cross-consistency** (Rabinovich Lemma 3.2(1), p.4 — the point-vs-interval
case of the per-position conjunction). At a merged point pinned by one chain and *interior* to the
other chain's interval, the conjoined constraint is (that chain's complete point type) ∧ (the other
chain's qf interval formula); it is satisfiable iff the complete point type is an admissible
completion of the interval formula, i.e. lies in the other chain's interval admissible set at that
slot. This is the third orthogonal axis of the single Lemma-3.2(1) merge principle: point-vs-point is
`pointConsistent` (equality via `nf_eval_unique`), interval-vs-interval is `intervalConj = ∩`
(already in `mergedFormula`), and point-vs-interval is this membership. Membership `∈` (not equality)
keeps the forward direction true — it constrains only real existential POINTS (always witnessed),
never possibly-empty open intervals. -/
def MergePair.crossConsistent {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1)) (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) : Prop :=
  (∀ i₁ : Fin (ψ₁.n + 1), (∀ i₂, e₂ i₂ ≠ e₁ i₁) →
      ψ₁.pointType i₁ ∈ ψ₂.intervalType (intervalSlot e₂ (e₁ i₁)))
  ∧
  (∀ i₂ : Fin (ψ₂.n + 1), (∀ i₁, e₁ i₁ ≠ e₂ i₂) →
      ψ₂.pointType i₂ ∈ ψ₁.intervalType (intervalSlot e₁ (e₂ i₂)))

instance {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r) (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1))
    (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) : Decidable (MergePair.crossConsistent ψ₁ ψ₂ e₁ e₂) := by
  unfold MergePair.crossConsistent
  infer_instance

/-! ## 5. The merged formula and `conjInterleave` -/

/-- The merged `ExistsForallFormula` produced by a merge datum over both chains: `k+1` points, free
variables pinned through `e₁`, each point carrying the `mergedPointType` (the complete type of
whichever chain pins it), and each interval slot carrying `intervalConj (chainIntervalType ψ₁ e₁ t)
(chainIntervalType ψ₂ e₂ t) = S₁ ∩ S₂` — the intersection of the two chains' admissible-completion
sets (Lemma 3.2(1)/3.4 (∧), p.4-5; empty ⇒ forced-empty slot, vacuously satisfied). A single
`StrictMono` chain of unary types: no arity growth. -/
noncomputable def mergedFormula {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1))
    (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) : ExistsForallFormula sig F r where
  n := k
  pin := fun v => e₁ (pin₁ v)
  pointType := fun j => mergedPointType ψ₁ ψ₂ e₁ e₂ j
  intervalType := fun t => intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t)

/-- **`conjInterleave` (Rabinovich Lemma 3.2(1), p.4).** The `∨∃∀`-formula whose disjuncts are the
merged formulas of all valid, point-consistent order-preserving merges of `ψ₁`'s and `ψ₂`'s chains,
over all merged sizes `k+1 ≤ (n₁+1)+(n₂+1)`. The conjunction `ψ₁ ∧ ψ₂` is witnessed by whichever
merge the two satisfying chains realize; each merged interval slot carries `S₁ ∩ S₂`. -/
noncomputable def conjInterleave {r : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1)) :
    VeeExistsForall sig F r :=
  open Classical in
  (List.range (ψ₁.n + ψ₂.n + 2)).flatMap fun k =>
    (Finset.univ.filter fun m : MergePair ψ₁.n ψ₂.n k =>
        m.valid pin₁ pin₂ ∧ MergePair.pointConsistent ψ₁ ψ₂ m.e₁ m.e₂
        ∧ MergePair.crossConsistent ψ₁ ψ₂ m.e₁ m.e₂).toList.map
      fun m => mergedFormula ψ₁ ψ₂ pin₁ m.e₁ m.e₂

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

/-- **Point-consistency from realized types (the crux of the complete-type merge).** If a merged
chain `w` realizes chain-1's point-type contributions AND chain-2's at every merged point, then the
merge is point-consistent: the two complete contributions coincide, because a point realizes at
most one complete type (`nf_eval_unique`). This is the lemma that makes the point-consistency filter
automatically satisfied by any realized merge, and is the reason interval-consistency (which lacks a
witness at empty intervals) is the genuinely-harder part deferred to Phase α part 2. -/
theorem pointConsistent_of_holds {r k : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (ψ₁ ψ₂ : ExistsForallFormula sig F r) (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1))
    (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) (w : Fin (k + 1) → N.carrier)
    (h1 : ∀ i, unaryHolds N (ψ₁.pointType i) (w (e₁ i)))
    (h2 : ∀ i, unaryHolds N (ψ₂.pointType i) (w (e₂ i))) :
    MergePair.pointConsistent ψ₁ ψ₂ e₁ e₂ := by
  intro i₁ i₂ hEq
  have hb : unaryHolds N (ψ₂.pointType i₂) (w (e₁ i₁)) := by rw [hEq]; exact h2 i₂
  exact nf_eval_unique N 0 1 (fun _ => w (e₁ i₁)) _ _ (h1 i₁) hb

/-- **Cross-consistency from realized types (forward-preservation, the critical invariant).** If a
merged chain `w` realizes both chains' point types, and moreover at every merged existential point of
one chain *interior* to the other chain's interval slot `w` satisfies that other chain's interval
admissible set there, then the merge is cross-consistent. The engine is again `nf_eval_unique`: the
admissible completion `τ` realized at the interior point `w (e₁ i₁)` and the complete point type
`ψ₁.pointType i₁` realized at the SAME point must coincide, forcing `ψ₁.pointType i₁ ∈` that set.
This is why the cross-consistency filter cannot break the forward direction — a genuine witness pair
supplies exactly these `hiv₁`/`hiv₂` clauses from its `efSat` interval clauses. -/
theorem crossConsistent_of_holds {r k : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (ψ₁ ψ₂ : ExistsForallFormula sig F r) (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1))
    (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) (w : Fin (k + 1) → N.carrier)
    (h1 : ∀ i, unaryHolds N (ψ₁.pointType i) (w (e₁ i)))
    (h2 : ∀ i, unaryHolds N (ψ₂.pointType i) (w (e₂ i)))
    (hiv₁ : ∀ i₁ : Fin (ψ₁.n + 1), (∀ i₂, e₂ i₂ ≠ e₁ i₁) →
        intervalHolds N (ψ₂.intervalType (intervalSlot e₂ (e₁ i₁))) (w (e₁ i₁)))
    (hiv₂ : ∀ i₂ : Fin (ψ₂.n + 1), (∀ i₁, e₁ i₁ ≠ e₂ i₂) →
        intervalHolds N (ψ₁.intervalType (intervalSlot e₁ (e₂ i₂))) (w (e₂ i₂))) :
    MergePair.crossConsistent ψ₁ ψ₂ e₁ e₂ := by
  refine ⟨?_, ?_⟩
  · intro i₁ hint
    obtain ⟨τ, hτS, hτhold⟩ := hiv₁ i₁ hint
    have hτeq : τ = ψ₁.pointType i₁ :=
      nf_eval_unique N 0 1 (fun _ => w (e₁ i₁)) _ _ hτhold (h1 i₁)
    rwa [hτeq] at hτS
  · intro i₂ hint
    obtain ⟨τ, hτS, hτhold⟩ := hiv₂ i₂ hint
    have hτeq : τ = ψ₂.pointType i₂ :=
      nf_eval_unique N 0 1 (fun _ => w (e₂ i₂)) _ _ hτhold (h2 i₂)
    rwa [hτeq] at hτS

/-! ## 6a. Point-type readback at merged points -/

/-- At a merged point that is chain 1's existential point `e₁ i`, the merged point type is exactly
chain 1's complete point type `ψ₁.pointType i` (chain 1 is preferred in `mergedPointType`). -/
theorem mergedPointType_left {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1)) (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1))
    (he₁ : StrictMono e₁) (i : Fin (ψ₁.n + 1)) :
    mergedPointType ψ₁ ψ₂ e₁ e₂ (e₁ i) = ψ₁.pointType i := by
  have hex : ∃ i', e₁ i' = e₁ i := ⟨i, rfl⟩
  simp only [mergedPointType, dif_pos hex]
  congr 1
  exact he₁.injective hex.choose_spec

/-- At a merged point that is chain 2's existential point `e₂ i`, the merged point type equals
chain 2's complete point type `ψ₂.pointType i` — either directly (when chain 1 does not pin it) or,
when both chains pin it, via `pointConsistent` (the two complete types agree). -/
theorem mergedPointType_right {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1)) (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1))
    (he₂ : StrictMono e₂) (hpc : MergePair.pointConsistent ψ₁ ψ₂ e₁ e₂) (i : Fin (ψ₂.n + 1)) :
    mergedPointType ψ₁ ψ₂ e₁ e₂ (e₂ i) = ψ₂.pointType i := by
  simp only [mergedPointType]
  by_cases h1 : ∃ i', e₁ i' = e₂ i
  · rw [dif_pos h1]
    exact hpc h1.choose i h1.choose_spec
  · rw [dif_neg h1]
    have h2 : ∃ i', e₂ i' = e₂ i := ⟨i, rfl⟩
    rw [dif_pos h2]
    congr 1
    exact he₂.injective h2.choose_spec

/-! ## 6aa. Membership assembly for `conjInterleave` -/

/-- **Membership assembly.** A valid, point-consistent, cross-consistent merge of size `k+1`
(with `k` under the enumeration bound) contributes its `mergedFormula` as a disjunct of
`conjInterleave`. This discharges the `List.mem_flatMap`/`Finset.mem_toList`/`List.mem_map`
bookkeeping of the forward direction in one reusable step. -/
theorem mergedFormula_mem_conjInterleave {r : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1))
    {k : Nat} (hk : k < ψ₁.n + ψ₂.n + 2) (m : MergePair ψ₁.n ψ₂.n k)
    (hvalid : m.valid pin₁ pin₂)
    (hpc : MergePair.pointConsistent ψ₁ ψ₂ m.e₁ m.e₂)
    (hcc : MergePair.crossConsistent ψ₁ ψ₂ m.e₁ m.e₂) :
    mergedFormula ψ₁ ψ₂ pin₁ m.e₁ m.e₂ ∈ conjInterleave ψ₁ ψ₂ pin₁ pin₂ := by
  unfold conjInterleave
  rw [List.mem_flatMap]
  refine ⟨k, List.mem_range.mpr hk, ?_⟩
  rw [List.mem_map]
  refine ⟨m, ?_, rfl⟩
  rw [Finset.mem_toList, Finset.mem_filter]
  exact ⟨Finset.mem_univ _, hvalid, hpc, hcc⟩

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

/-- **Uniform interval clause (from the three `efSat` region clauses).** A strictly-monotone chain
`x` satisfying the before/between/after interval clauses forces, at any point `y` that is *not* one of
the chain points, the interval type at `y`'s **point slot** `⟨#{i | x i < y}, _⟩` — the `ψ`-slot into
which `y` falls. The three region cases (before `x₀`, an open `(x_{i-1}, xᵢ)`, after `xₙ`) are unified
by the count of chain points below `y`, placed via `strictMono_lt_iff_val_lt_filterCard`. -/
theorem chain_interval_clause {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormula sig F r) (x : Fin (ψ.n + 1) → N.carrier) (hmono : StrictMono x)
    (hbefore : ∀ y, y < x 0 → intervalHolds N (ψ.intervalType 0) y)
    (hbetw : ∀ (i : Fin ψ.n) (y : N.carrier), x i.castSucc < y → y < x i.succ →
        intervalHolds N (ψ.intervalType i.succ.castSucc) y)
    (hafter : ∀ y : N.carrier, x (Fin.last ψ.n) < y →
        intervalHolds N (ψ.intervalType (Fin.last (ψ.n + 1))) y)
    (y : N.carrier) (hy : ∀ j, y ≠ x j)
    (hlt : (Finset.univ.filter (fun i => x i < y)).card < ψ.n + 2) :
    intervalHolds N (ψ.intervalType ⟨(Finset.univ.filter (fun i => x i < y)).card, hlt⟩) y := by
  have hkey : ∀ a : Fin (ψ.n + 1),
      x a < y ↔ a.val < (Finset.univ.filter (fun i => x i < y)).card :=
    fun a => strictMono_lt_iff_val_lt_filterCard x hmono y a
  set c := (Finset.univ.filter (fun i => x i < y)).card with hc
  rcases Nat.lt_or_ge c 1 with hc0 | hc1
  · -- c = 0: y lies before x 0
    have hce : c = 0 := Nat.lt_one_iff.mp hc0
    have hnx0 : ¬ x 0 < y := by rw [hkey 0]; simp [hce]
    have hy0 : y < x 0 := lt_of_le_of_ne (le_of_not_lt hnx0) (hy 0)
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
        exact lt_of_le_of_ne (le_of_not_lt this) (hy i.succ)
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

/-- **Conjoined interval clause from both factors at a real point.** If a genuine model point `y`
satisfies BOTH admissible sets `S₁` and `S₂`, it satisfies their intersection `intervalConj S₁ S₂`:
the two admissible completions realized at `y` coincide by `nf_eval_unique`, so one common completion
lies in `S₁ ∩ S₂`. This is the engine collapsing both chains' interval completions at a merged
interior point to a single witness in `S₁ ∩ S₂`. -/
theorem intervalHolds_conj_of_both (N : OrderedMonadicStructure (sigE sig F))
    (S₁ S₂ : IntervalType sig F) (y : N.carrier)
    (h1 : intervalHolds N S₁ y) (h2 : intervalHolds N S₂ y) :
    intervalHolds N (intervalConj S₁ S₂) y := by
  obtain ⟨τ₁, hτ₁S, hτ₁y⟩ := h1
  obtain ⟨τ₂, hτ₂S, hτ₂y⟩ := h2
  have hτ : τ₁ = τ₂ := nf_eval_unique N 0 1 (fun _ => y) τ₁ τ₂ hτ₁y hτ₂y
  rw [intervalHolds_inter_iff]
  exact ⟨τ₁, ⟨hτ₁S, hτ ▸ hτ₂S⟩, hτ₁y⟩

/-- **`chainIntervalType`↔point-slot bridge.** Under a realized rank merge (`w (e i) = x i`, `w`
strict mono), the source chain's merged interval-slot set `chainIntervalType ψ e t` equals `ψ`'s
interval type at the *point slot* of `y` — provided the merged slot value `t.val` counts exactly the
merged points below `y`. The two slot indices count the same set because `(e i).castSucc < t ↔
x i < y` pointwise (via `strictMono_lt_iff_val_lt_filterCard` for `w` and the round-trip). -/
theorem chainIntervalType_eq_pointSlot {r k : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormula sig F r) (e : Fin (ψ.n + 1) → Fin (k + 1))
    (x : Fin (ψ.n + 1) → N.carrier) (w : Fin (k + 1) → N.carrier) (hw : StrictMono w)
    (hrt : ∀ i, w (e i) = x i) (y : N.carrier)
    (t : Fin (k + 2)) (ht : t.val = (Finset.univ.filter (fun j => w j < y)).card)
    (hlt : (Finset.univ.filter (fun i => x i < y)).card < ψ.n + 2) :
    chainIntervalType ψ e t
      = ψ.intervalType ⟨(Finset.univ.filter (fun i => x i < y)).card, hlt⟩ := by
  have hfe : (Finset.univ.filter (fun i => (e i).castSucc < t))
      = (Finset.univ.filter (fun i => x i < y)) := by
    apply Finset.filter_congr
    intro i _
    rw [Fin.lt_def, Fin.coe_castSucc, ht, ← hrt i]
    exact (strictMono_lt_iff_val_lt_filterCard w hw y (e i)).symm
  unfold chainIntervalType
  congr 1
  apply Fin.ext
  simp only [Fin.val_mk, hfe]

/-- **`intervalSlot`↔point-slot bridge (interior-point case).** Under a realized rank merge, the
`ψ`-interval slot of a merged *position* `j` (a point pinned by the other chain) equals `ψ`'s
interval type at the point slot of `p = w j`. The two counts agree because `e i < j ↔ x i < p`
pointwise (`w` strict mono + round-trip). This supplies the interval hypotheses `hiv₁`/`hiv₂` that
`crossConsistent_of_holds` consumes. -/
theorem intervalSlot_eq_pointSlot {r k : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormula sig F r) (e : Fin (ψ.n + 1) → Fin (k + 1))
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

/-! ## 7. Forward direction -/

/-- **Forward direction of Lemma 3.2(1) (Rabinovich, p.4), on partial intervals.** If both
`∃∀`-formulas are satisfied at the same environment, their `conjInterleave` is satisfied: the two
witnessing chains merge into a single ordered chain (their sorted union `w = mergedSet.orderEmbOfFin`)
whose rank maps `e₁, e₂` form a valid, point-consistent merge, and `w` satisfies that merge's
`mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂` — including the `S₁ ∩ S₂` interval slots, since at each merged
interior point `w` realizes both chains' interval sets, hence a common completion (∈ `S₁ ∩ S₂`).

**Proof status: LANDED sorry-free.** The construction: `S := mergedSet N x₁ x₂` (sorted union of
the two witness chains), `hcard : S.card = k+1` via `mergedSet_card_succ`; `w := S.orderEmbOfFin hcard`
(the merged chain); `eₖ i := (S.orderIsoOfFin hcard).symm ⟨xₖ i, _⟩` (the rank maps). The obligations
discharge through the §6aa/§6b/§6c helpers:
- round-trip `orderEmbOfFin_symm_apply` (`w (eₖ i) = xₖ i`); `hw : StrictMono w`.
- `valid`: `StrictMono eₖ` (`strictMono_rank`), joint surjectivity (`rank_orderEmbOfFin` +
  `S = image x₁ ∪ image x₂`), pin-compat (`x₁ (ψ₁.pin v) = env v = x₂ (ψ₂.pin v)`).
- `pointConsistent`: `pointConsistent_of_holds`; `crossConsistent`: `crossConsistent_of_holds`, whose
  interior-point interval hypotheses are supplied by `intervalSlot_eq_pointSlot` + `chain_interval_clause`.
- `efSat (mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂)` with witness `w`: point types via
  `mergedPointType_left`/`_right`; the three `S₁ ∩ S₂` interval regions via the local `merged_clause`
  (`chainIntervalType_eq_pointSlot` places each chain's slot, `chain_interval_clause` routes the matching
  `efSat` region clause, `intervalHolds_conj_of_both` collapses both completions to a common witness in
  `S₁ ∩ S₂` by `nf_eval_unique`). The slot placements all rest on the crux
  `strictMono_lt_iff_val_lt_filterCard`.
- assemble `veeSat` by `mergedFormula_mem_conjInterleave` on the `k`-range enumeration.

Off the live import path; no spine impact. -/
theorem conjInterleave_forward {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (h₁ : efSat N env ψ₁) (h₂ : efSat N env ψ₂) :
    veeSat N env (conjInterleave ψ₁ ψ₂ ψ₁.pin ψ₂.pin) := by
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
  -- The merged chain and the two rank maps.
  let w : Fin (k + 1) → N.carrier := fun j => S.orderEmbOfFin hcard j
  let e₁ : Fin (ψ₁.n + 1) → Fin (k + 1) := fun i => (S.orderIsoOfFin hcard).symm ⟨x₁ i, hmem₁ i⟩
  let e₂ : Fin (ψ₂.n + 1) → Fin (k + 1) := fun i => (S.orderIsoOfFin hcard).symm ⟨x₂ i, hmem₂ i⟩
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
  -- Point-type realization at merged points.
  have hpt1 : ∀ i, unaryHolds N (ψ₁.pointType i) (w (e₁ i)) := by
    intro i; rw [hrt₁ i]; exact hx₁pt i
  have hpt2 : ∀ i, unaryHolds N (ψ₂.pointType i) (w (e₂ i)) := by
    intro i; rw [hrt₂ i]; exact hx₂pt i
  have hpc : MergePair.pointConsistent ψ₁ ψ₂ e₁ e₂ :=
    pointConsistent_of_holds N ψ₁ ψ₂ e₁ e₂ w hpt1 hpt2
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
  -- Merged interval clause: at any merged interior point `y` in slot `t`, both chains' interval
  -- completions collapse (via `nf_eval_unique`) to a common witness in `S₁ ∩ S₂`.
  have merged_clause : ∀ (y : N.carrier) (t : Fin (k + 2)),
      (∀ j, y ≠ w j) → t.val = (Finset.univ.filter (fun j => w j < y)).card →
      intervalHolds N (intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t)) y := by
    intro y t hyne ht
    have hy₁ : ∀ i, y ≠ x₁ i := fun i => by rw [← hrt₁ i]; exact hyne (e₁ i)
    have hy₂ : ∀ i, y ≠ x₂ i := fun i => by rw [← hrt₂ i]; exact hyne (e₂ i)
    rw [chainIntervalType_eq_pointSlot N ψ₁ e₁ x₁ w hw hrt₁ y t ht (hlt_bound₁ y),
        chainIntervalType_eq_pointSlot N ψ₂ e₂ x₂ w hw hrt₂ y t ht (hlt_bound₂ y)]
    exact intervalHolds_conj_of_both N _ _ y
      (chain_interval_clause N ψ₁ x₁ hx₁mono hx₁before hx₁betw hx₁after y hy₁ (hlt_bound₁ y))
      (chain_interval_clause N ψ₂ x₂ hx₂mono hx₂before hx₂betw hx₂after y hy₂ (hlt_bound₂ y))
  -- Cross-consistency: interior existential points route through the interval clauses.
  have hcc : MergePair.crossConsistent ψ₁ ψ₂ e₁ e₂ := by
    apply crossConsistent_of_holds N ψ₁ ψ₂ e₁ e₂ w hpt1 hpt2
    · intro i₁ hint
      have hy₂p : ∀ i₂, w (e₁ i₁) ≠ x₂ i₂ := by
        intro i₂ heq
        exact hint i₂ (hw.injective (by rw [hrt₂ i₂]; exact heq.symm))
      rw [intervalSlot_eq_pointSlot N ψ₂ e₂ x₂ w hw hrt₂ (e₁ i₁) (w (e₁ i₁)) rfl
            (hlt_bound₂ (w (e₁ i₁)))]
      exact chain_interval_clause N ψ₂ x₂ hx₂mono hx₂before hx₂betw hx₂after
        (w (e₁ i₁)) hy₂p (hlt_bound₂ (w (e₁ i₁)))
    · intro i₂ hint
      have hy₁p : ∀ i₁, w (e₂ i₂) ≠ x₁ i₁ := by
        intro i₁ heq
        exact hint i₁ (hw.injective (by rw [hrt₁ i₁]; exact heq.symm))
      rw [intervalSlot_eq_pointSlot N ψ₁ e₁ x₁ w hw hrt₁ (e₂ i₂) (w (e₂ i₂)) rfl
            (hlt_bound₁ (w (e₂ i₂)))]
      exact chain_interval_clause N ψ₁ x₁ hx₁mono hx₁before hx₁betw hx₁after
        (w (e₂ i₂)) hy₁p (hlt_bound₁ (w (e₂ i₂)))
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
  refine ⟨mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂, ?_, ?_⟩
  · exact mergedFormula_mem_conjInterleave ψ₁ ψ₂ ψ₁.pin ψ₂.pin hk_bound ⟨e₁, e₂⟩
      ⟨he₁, he₂, hsurj, hpin_comp⟩ hpc hcc
  · refine ⟨w, hw, ?_, ?_, ?_, ?_, ?_⟩
    · -- pinning
      intro v
      show env v = w (e₁ (ψ₁.pin v))
      rw [hrt₁ (ψ₁.pin v)]; exact hx₁pin v
    · -- point types
      intro j
      rcases hsurj j with ⟨i, hij⟩ | ⟨i, hij⟩
      · show unaryHolds N (mergedPointType ψ₁ ψ₂ e₁ e₂ j) (w j)
        rw [← hij, mergedPointType_left ψ₁ ψ₂ e₁ e₂ he₁ i, hrt₁ i]; exact hx₁pt i
      · show unaryHolds N (mergedPointType ψ₁ ψ₂ e₁ e₂ j) (w j)
        rw [← hij, mergedPointType_right ψ₁ ψ₂ e₁ e₂ he₂ hpc i, hrt₂ i]; exact hx₂pt i
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
        rw [Fin.lt_def, Fin.coe_castSucc] at ha
        rw [Fin.lt_def, Fin.val_succ] at hb
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

/-! ## 8. Backward direction -/

/-- **Reverse membership extraction.** Every disjunct of `conjInterleave` is the `mergedFormula` of
some valid, point-consistent, cross-consistent merge. Inverts `mergedFormula_mem_conjInterleave`:
unfolds the `flatMap`/`toList.map`/`filter` bookkeeping to recover the merge datum and its three
filter conjuncts. This is the entry point of the backward direction, supplying `valid` (⇒
`StrictMono e₁`, `StrictMono e₂`, joint surjectivity, pin-compat), `pointConsistent`, and
`crossConsistent` from a bare `φ ∈ conjInterleave`. -/
theorem exists_mergePair_of_mem {r : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1))
    (φ : ExistsForallFormula sig F r) (hφ : φ ∈ conjInterleave ψ₁ ψ₂ pin₁ pin₂) :
    ∃ (k : Nat) (m : MergePair ψ₁.n ψ₂.n k),
      m.valid pin₁ pin₂ ∧ MergePair.pointConsistent ψ₁ ψ₂ m.e₁ m.e₂
        ∧ MergePair.crossConsistent ψ₁ ψ₂ m.e₁ m.e₂
        ∧ mergedFormula ψ₁ ψ₂ pin₁ m.e₁ m.e₂ = φ := by
  classical
  unfold conjInterleave at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨k, _, hφk⟩ := hφ
  rw [List.mem_map] at hφk
  obtain ⟨m, hmem, hmf⟩ := hφk
  rw [Finset.mem_toList, Finset.mem_filter] at hmem
  obtain ⟨_, hvalid, hpc, hcc⟩ := hmem
  exact ⟨k, m, hvalid, hpc, hcc, hmf⟩

/-- **Reverse region splitter.** The mirror of `chain_interval_clause`: from a single *point-slot
clause* (at every non-chain point `y`, the interval type at `y`'s point slot `⟨#{i | x i < y}, _⟩`
holds) recover the three `efSat` region clauses (before `x₀` / open `(x_{i-1}, xᵢ)` / after `xₙ`).
Each region computes the count of chain points below `y` via
`strictMono_lt_iff_val_lt_filterCard` and matches it to the region's slot index by `Fin.ext`. Used
for both projected chains in the backward direction. -/
theorem regions_of_pointSlot {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (ψ : ExistsForallFormula sig F r) (x : Fin (ψ.n + 1) → N.carrier) (hmono : StrictMono x)
    (hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => x i < y)).card < ψ.n + 2)
    (hpts : ∀ (y : N.carrier), (∀ j, y ≠ x j) →
        intervalHolds N (ψ.intervalType
          ⟨(Finset.univ.filter (fun i => x i < y)).card, hlt_bound y⟩) y) :
    (∀ y, y < x 0 → intervalHolds N (ψ.intervalType 0) y) ∧
    (∀ (i : Fin ψ.n) y, x i.castSucc < y → y < x i.succ →
        intervalHolds N (ψ.intervalType i.succ.castSucc) y) ∧
    (∀ y, x (Fin.last ψ.n) < y →
        intervalHolds N (ψ.intervalType (Fin.last (ψ.n + 1))) y) := by
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

/-- **Backward direction of Lemma 3.2(1) (Rabinovich, p.4), on partial intervals.** If the
`conjInterleave` disjunction is satisfied, both conjuncts `ψ₁` and `ψ₂` are satisfied. From a
satisfied disjunct `mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂` with witness chain `w`, project each source
chain `xₖ i := w (eₖ i)`. Point types read back through `mergedPointType_left`/`_right`; pinning
through the merge's pin field (and pin-compat for chain 2). Each source-chain interval region is
recovered as a *point-slot clause* by a two-case split at a point `y` in a `ψₖ`-open interval:
- **`y` not a merged point** — `y` lies in a merged open slot; the merged interval clause gives
  `intervalHolds (S₁ ∩ S₂) y`, projected to `Sₖ` by `intervalHolds_inter_left`/`_right` and placed
  by `chainIntervalType_eq_pointSlot`.
- **`y = w j` a merged interior point** — `j` is the *other* chain's existential point `e_{3-k} i'`
  (joint surjectivity + `y` not a `ψₖ`-point); `crossConsistent` gives
  `ψ_{3-k}.pointType i' ∈ ψₖ.intervalType slot`, and `mergedPointType_{left/right}` gives
  `unaryHolds (ψ_{3-k}.pointType i') y`, so `intervalHolds (ψₖ.intervalType slot) y`; the slot is
  placed by `intervalSlot_eq_pointSlot`.
`regions_of_pointSlot` then reassembles the three `efSat` region clauses. -/
theorem conjInterleave_backward {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (h : veeSat N env (conjInterleave ψ₁ ψ₂ ψ₁.pin ψ₂.pin)) :
    efSat N env ψ₁ ∧ efSat N env ψ₂ := by
  classical
  obtain ⟨φ, hφmem, hef⟩ := h
  obtain ⟨k, m, hvalid, hpc, hcc, hmf⟩ :=
    exists_mergePair_of_mem ψ₁ ψ₂ ψ₁.pin ψ₂.pin φ hφmem
  rw [← hmf] at hef
  obtain ⟨he₁, he₂, hsurj, hpin_comp⟩ := hvalid
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
      intervalHolds N (ψ₁.intervalType
        ⟨(Finset.univ.filter (fun i => x₁ i < y)).card, hlt_bound₁ y⟩) y := by
    intro y hyne
    by_cases hmerged : ∀ j, y ≠ w j
    · -- y not a merged point: merged interval clause + inter_left + point-slot bridge.
      have hclause := chain_interval_clause N (mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂) w hw
        hwbefore hwbetw hwafter y hmerged (hlt_bound_w y)
      have hleft := intervalHolds_inter_left N hclause
      rw [chainIntervalType_eq_pointSlot N ψ₁ e₁ x₁ w hw (fun i => rfl) y
          ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩ rfl (hlt_bound₁ y)] at hleft
      exact hleft
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
      have hmem : ψ₂.pointType i' ∈ ψ₁.intervalType (intervalSlot e₁ (e₂ i')) :=
        hcc.2 i' (fun i₁ => by rw [hi']; exact hjne1 i₁)
      have hu : unaryHolds N (ψ₂.pointType i') y := by
        have hpt : unaryHolds N (mergedPointType ψ₁ ψ₂ e₁ e₂ j) (w j) := hwpt j
        rw [← hi', mergedPointType_right ψ₁ ψ₂ e₁ e₂ he₂ hpc i'] at hpt
        rw [hi', ← hj] at hpt
        exact hpt
      have hih : intervalHolds N (ψ₁.intervalType (intervalSlot e₁ (e₂ i'))) y := ⟨_, hmem, hu⟩
      rw [intervalSlot_eq_pointSlot N ψ₁ e₁ x₁ w hw (fun i => rfl) (e₂ i') y
          (by rw [hi']; exact hj.symm) (hlt_bound₁ y)] at hih
      exact hih
  -- Point-slot clause for chain 2 (symmetric).
  have hpts₂ : ∀ (y : N.carrier), (∀ j, y ≠ x₂ j) →
      intervalHolds N (ψ₂.intervalType
        ⟨(Finset.univ.filter (fun i => x₂ i < y)).card, hlt_bound₂ y⟩) y := by
    intro y hyne
    by_cases hmerged : ∀ j, y ≠ w j
    · have hclause := chain_interval_clause N (mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂) w hw
        hwbefore hwbetw hwafter y hmerged (hlt_bound_w y)
      have hright := intervalHolds_inter_right N hclause
      rw [chainIntervalType_eq_pointSlot N ψ₂ e₂ x₂ w hw (fun i => rfl) y
          ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩ rfl (hlt_bound₂ y)] at hright
      exact hright
    · push_neg at hmerged
      obtain ⟨j, hj⟩ := hmerged
      have hjne2 : ∀ i, e₂ i ≠ j := by
        intro i heq
        exact hyne i (by show y = w (e₂ i); rw [hj, heq])
      obtain ⟨i', hi'⟩ : ∃ i', e₁ i' = j := by
        rcases hsurj j with hh | ⟨i, hi⟩
        · exact hh
        · exact absurd hi (hjne2 i)
      have hmem : ψ₁.pointType i' ∈ ψ₂.intervalType (intervalSlot e₂ (e₁ i')) :=
        hcc.1 i' (fun i₂ => by rw [hi']; exact hjne2 i₂)
      have hu : unaryHolds N (ψ₁.pointType i') y := by
        have hpt : unaryHolds N (mergedPointType ψ₁ ψ₂ e₁ e₂ j) (w j) := hwpt j
        rw [← hi', mergedPointType_left ψ₁ ψ₂ e₁ e₂ he₁ i'] at hpt
        rw [hi', ← hj] at hpt
        exact hpt
      have hih : intervalHolds N (ψ₂.intervalType (intervalSlot e₂ (e₁ i'))) y := ⟨_, hmem, hu⟩
      rw [intervalSlot_eq_pointSlot N ψ₂ e₂ x₂ w hw (fun i => rfl) (e₁ i') y
          (by rw [hi']; exact hj.symm) (hlt_bound₂ y)] at hih
      exact hih
  -- Assemble both `efSat`s.
  refine ⟨?_, ?_⟩
  · refine ⟨x₁, hx₁mono, ?_, ?_, ?_, ?_, ?_⟩
    · intro v; show env v = w (e₁ (ψ₁.pin v)); exact hwpin v
    · intro j
      show unaryHolds N (ψ₁.pointType j) (w (e₁ j))
      have hpt : unaryHolds N (mergedPointType ψ₁ ψ₂ e₁ e₂ (e₁ j)) (w (e₁ j)) := hwpt (e₁ j)
      rw [mergedPointType_left ψ₁ ψ₂ e₁ e₂ he₁ j] at hpt
      exact hpt
    · exact (regions_of_pointSlot N ψ₁ x₁ hx₁mono hlt_bound₁ hpts₁).1
    · exact (regions_of_pointSlot N ψ₁ x₁ hx₁mono hlt_bound₁ hpts₁).2.1
    · exact (regions_of_pointSlot N ψ₁ x₁ hx₁mono hlt_bound₁ hpts₁).2.2
  · refine ⟨x₂, hx₂mono, ?_, ?_, ?_, ?_, ?_⟩
    · intro v
      show env v = w (e₂ (ψ₂.pin v))
      rw [← hpin_comp v]; exact hwpin v
    · intro j
      show unaryHolds N (ψ₂.pointType j) (w (e₂ j))
      have hpt : unaryHolds N (mergedPointType ψ₁ ψ₂ e₁ e₂ (e₂ j)) (w (e₂ j)) := hwpt (e₂ j)
      rw [mergedPointType_right ψ₁ ψ₂ e₁ e₂ he₂ hpc j] at hpt
      exact hpt
    · exact (regions_of_pointSlot N ψ₂ x₂ hx₂mono hlt_bound₂ hpts₂).1
    · exact (regions_of_pointSlot N ψ₂ x₂ hx₂mono hlt_bound₂ hpts₂).2.1
    · exact (regions_of_pointSlot N ψ₂ x₂ hx₂mono hlt_bound₂ hpts₂).2.2

end Bimodal.Metalogic.WeakCanonical
