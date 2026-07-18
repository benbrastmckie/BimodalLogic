import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Mathlib.Data.Fintype.Sigma
import Mathlib.Order.Fin.Basic

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

## The complete-type discipline and its interval-consistency limitation (design note)

A `UnaryType sig F = NormalForm (sigE sig F) 0 1` is a **complete** quantifier-free 1-type: by
`nf_eval_nf` at depth 0, `unaryHolds N τ p` says *every* E[Σ] atom at `p` matches `τ` exactly, and
`nf_eval_unique` says a point realizes at most one type. Hence there is no conjunction operation on
`UnaryType` producing a new realizable type.

Rabinovich's Def 3.1 (PDF p.4), by contrast, takes the point/interval types `αⱼ, βⱼ` to be
**quantifier-free FORMULAS** (partial types), which are freely conjoinable — including into a
*contradictory* conjunction that forces an interval to be empty (the paper's footnote 2, p.5,
`P·Until·Q` example relies on exactly this). The complete-type encoding cannot express a
contradictory interval type, so it cannot force an interval empty.

**Consequence for the merge.** At a merged *point* (always a real point of the model) the two
source contributions are complete types of the same point, hence equal by `nf_eval_unique`; the
merged point type is that common value, enforced by a decidable **point-consistency** filter. At a
merged *interval* the two source contributions need only agree when the interval is *nonempty*; an
**empty** merged interval (two order-adjacent merged points — normal in a discrete order) imposes
no constraint, yet the two source complete interval types may differ. A filter demanding interval
equality would then wrongly exclude a genuinely-satisfied configuration, making the forward
direction **false** (concrete two-point counterexample: sentences with adjacent points and mismatched
between-interval types). Therefore this module filters by **point-consistency only** and the merged
formula carries chain-1's interval types — sound and complete for the forward (`→`) direction proved
here. The **backward/iff** direction (Phase α part 2) genuinely requires representing the βⱼ as
partial (conjoinable, possibly-contradictory) types — a datatype refinement flagged for that phase,
not resolvable on the single-complete-`UnaryType`-per-slot `ExistsForallFormula` structure.

## Contents (this module — Phase α part 1)

1. `belowCount` / `intervalSlot` — for a strictly-monotone embedding `e : Fin (n+1) → Fin (k+1)`,
   the chain interval slot (`Fin (n+2)`) that a merged position occupies.
2. `chainPointType` / `chainIntervalType` — the point/interval contribution of a source chain at a
   merged point / merged interval slot.
3. `ChainMerge` — the order-preserving-merge datum: `k`, two strictly-monotone jointly-surjective
   pin-compatible embeddings, packaged as raw data over a `Fintype` for enumeration.
4. `ChainMerge.consistent` — the decidable type-consistency predicate (both source contributions
   agree at every merged point and interval slot).
5. `ChainMerge.toFormula` — the merged `ExistsForallFormula` (single `StrictMono` chain, unary
   types), and `conjInterleave` — the `∨∃∀`-formula enumerating all consistent merges.
6. `conjInterleave_forward` — **the forward direction**: `efSat ψ₁ ∧ efSat ψ₂ → veeSat
   (conjInterleave ψ₁ ψ₂)`. From two satisfying chains, the realized rank-merge is consistent and
   its merged chain (sorted union) satisfies the merged formula.

The backward direction of `conjInterleave_iff`, `veeConj`, and `veeConj_iff` are Phase α part 2
(sequel module), NOT built here.

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

/-- The point-type contribution of a source chain `ψ` at merged point `j`: `ψ`'s point type if `j`
is one of `ψ`'s existential points (`e i = j`), otherwise `ψ`'s interval type at the slot `j`
occupies. Decidable choice on whether `j` is in the image of `e`. -/
noncomputable def chainPointType {r : Nat} (ψ : ExistsForallFormula sig F r) {k : Nat}
    (e : Fin (ψ.n + 1) → Fin (k + 1)) (j : Fin (k + 1)) : UnaryType sig F :=
  open Classical in
  if h : ∃ i, e i = j then ψ.pointType h.choose
  else ψ.intervalType (intervalSlot e j)

/-- The interval-type contribution of a source chain `ψ` at merged interval slot `t : Fin (k+2)`.
The merged interval `t` sits inside exactly one of `ψ`'s intervals; that interval's slot is
`intervalSlot e` evaluated at the merged boundary, computed from `t` via the count of source points
strictly below `t`. -/
def chainIntervalType {r : Nat} (ψ : ExistsForallFormula sig F r) {k : Nat}
    (e : Fin (ψ.n + 1) → Fin (k + 1)) (t : Fin (k + 2)) : UnaryType sig F :=
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

/-- The merge is **point-consistent**: at every merged point the two source point-type
contributions agree. Since a merged point is always a real point of the model, its two complete
contributions coincide by `nf_eval_unique`, so the merged point type is well-defined as their
common value. Interval-type consistency is deliberately **not** required (see the module design
note: an empty merged interval imposes no constraint yet the two complete interval types may
differ; demanding their equality would make the forward direction false). Decidable via
`DecidableEq (UnaryType sig F)`. -/
noncomputable def MergePair.pointConsistent {r k : Nat} (ψ₁ : ExistsForallFormula sig F r)
    (ψ₂ : ExistsForallFormula sig F r) (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1))
    (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) : Prop :=
  ∀ j : Fin (k + 1), chainPointType ψ₁ e₁ j = chainPointType ψ₂ e₂ j

/-! ## 5. The merged formula and `conjInterleave` -/

/-- The merged `ExistsForallFormula` produced by a merge datum: `k+1` points, free variables pinned
through `e₁`, each point/interval slot carrying the (chain-1) contribution — which, for a consistent
merge used as a disjunct, equals the chain-2 contribution. A single `StrictMono` chain of unary
types: no arity growth. -/
noncomputable def mergedFormula {r n₁ k : Nat} (ψ₁ : ExistsForallFormula sig F r)
    (pin₁ : Fin r → Fin (n₁ + 1)) (e₁ : Fin (n₁ + 1) → Fin (k + 1))
    (hn₁ : ψ₁.n = n₁) : ExistsForallFormula sig F r where
  n := k
  pin := fun v => e₁ (pin₁ v)
  pointType := fun j => chainPointType ψ₁ (hn₁ ▸ e₁) j
  intervalType := fun t => chainIntervalType ψ₁ (hn₁ ▸ e₁) t

/-- **`conjInterleave` (Rabinovich Lemma 3.2(1), p.4).** The `∨∃∀`-formula whose disjuncts are the
merged formulas of all valid, type-consistent order-preserving merges of `ψ₁`'s and `ψ₂`'s chains,
over all merged sizes `k+1 ≤ (n₁+1)+(n₂+1)`. The conjunction `ψ₁ ∧ ψ₂` is witnessed by whichever
merge the two satisfying chains realize. -/
noncomputable def conjInterleave {r : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (pin₁ : Fin r → Fin (ψ₁.n + 1)) (pin₂ : Fin r → Fin (ψ₂.n + 1)) :
    VeeExistsForall sig F r :=
  open Classical in
  (List.range (ψ₁.n + ψ₂.n + 2)).flatMap fun k =>
    (Finset.univ.filter fun m : MergePair ψ₁.n ψ₂.n k =>
        m.valid pin₁ pin₂ ∧ MergePair.pointConsistent ψ₁ ψ₂ m.e₁ m.e₂).toList.map
      fun m => mergedFormula ψ₁ pin₁ m.e₁ rfl

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
    (h1 : ∀ j, unaryHolds N (chainPointType ψ₁ e₁ j) (w j))
    (h2 : ∀ j, unaryHolds N (chainPointType ψ₂ e₂ j) (w j)) :
    MergePair.pointConsistent ψ₁ ψ₂ e₁ e₂ := fun j =>
  nf_eval_unique N 0 1 (fun _ => w j) _ _ (h1 j) (h2 j)

/-! ## 7. Forward direction -/

/-- **Forward direction of Lemma 3.2(1) (Rabinovich, p.4).** If both `∃∀`-formulas are satisfied at
the same environment, their `conjInterleave` is satisfied: the two witnessing chains merge into a
single ordered chain (their sorted union `w = mergedSet.orderEmbOfFin`) whose rank maps `e₁, e₂`
form a valid, point-consistent merge, and `w` satisfies that merge's `mergedFormula`.

**Proof status (Phase α part 1 — this dispatch): documented strategic sorry.** The statement is
TRUE (established: point-consistency of the rank merge holds at every merged point via
`nf_eval_unique`; the merged chain `w` realizes chain-1's point/interval types by `h₁`, since every
merged point is a chain-1 point or lies in a chain-1 interval, and every merged sub-interval lies
inside a chain-1 interval). The remaining work is the sorted-union realization bookkeeping
(`orderEmbOfFin`/`orderIsoOfFin` rank identities: `w (eₖ i) = xₖ i`, monotonicity and joint
surjectivity of the rank maps, the `belowCount`↔position correspondence for the interval clauses,
and the `Finset.mem_filter`/`List.mem_map` membership assembly) — a large but mechanical build that
exceeds a single dispatch. Tracked in `sorry_inventory` with a Phase-2-continuation follow-up. Off
the live import path; no spine impact.

Proof plan (obligations, all TRUE):
- `S := mergedSet N x₁ x₂`, `hcard : S.card = k+1` (k := S.card - 1) via `mergedSet_card_succ`.
- `w := S.orderEmbOfFin hcard`; `eₖ i := (S.orderIsoOfFin hcard).symm ⟨xₖ i, _⟩` (rank maps).
- `valid`: `StrictMono e₁`, `StrictMono e₂` (rank of a strictly-mono chain), joint surjectivity
  (every rank is the rank of some `x₁ i` or `x₂ j`, as `S = image x₁ ∪ image x₂`), pin-compat
  (`e₁ (ψ₁.pin v) = e₂ (ψ₂.pin v)` since `x₁ (ψ₁.pin v) = env v = x₂ (ψ₂.pin v)`).
- `pointConsistent`: at merged point `j`, both `chainPointType`s are the complete type of `w j`
  (via `h₁`/`h₂` + `nf_eval_unique`), hence equal.
- `efSat (mergedFormula ψ₁ ψ₁.pin e₁ rfl)` with witness `w`: `StrictMono w` (orderEmbOfFin),
  `env v = w (e₁ (ψ₁.pin v))` (rank round-trip), point/interval types via `h₁`.
- assemble `veeSat` by `List.mem_flatMap` + `List.mem_map` on the `k`-range enumeration. -/
theorem conjInterleave_forward {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (h₁ : efSat N env ψ₁) (h₂ : efSat N env ψ₂) :
    veeSat N env (conjInterleave ψ₁ ψ₂ ψ₁.pin ψ₂.pin) := by
  -- Extract the two witnessing chains (structural part, discharged).
  obtain ⟨x₁, hx₁mono, hx₁pin, hx₁pt, hx₁before, hx₁betw, hx₁after⟩ := h₁
  obtain ⟨x₂, hx₂mono, hx₂pin, hx₂pt, hx₂before, hx₂betw, hx₂after⟩ := h₂
  -- Remaining: build the realized rank merge and prove membership + satisfaction.
  -- See the proof plan in the docstring; this is the tracked strategic sorry for Phase α part 1.
  sorry

end Bimodal.Metalogic.WeakCanonical
