import Bimodal.Metalogic.WeakCanonical.Kamp.ConjInterleave
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas

/-!
# Arity lift of a low-arity `∃∀`-formula to the arity-`r` context (Rabinovich Lemma 3.2(1), p.4-5)

The Prop 4.3 negation case (PDF p.6) produces disjuncts with **at most two free variables**
(inherited from the Lemma 3.2(2) ≤2-free-variable conjuncts), whereas the homogeneous Lean object
`VeeExistsForall sig F r = List (ExistsForallFormula sig F r)` forces every disjunct to pin **all**
`r` free variables via a total `pin`. Reconciling a ≤2-free-variable disjunct with the arity-`r`
context is the **arity lift**: it inserts the `r-2` other (ordered) context points into the
disjunct's existential chain, over every order-preserving insertion — Rabinovich's own Lemma 3.2(1)
chain-merge, already landed both directions as `conjInterleave_iff` (`ConjInterleave.lean`).

## The complete-point-type subtlety (spike finding)

`UnaryType sig F = NormalForm (sigE sig F) 0 1` is a **complete** quantifier-free 1-type:
`unaryHolds N τ y` requires *every* E[Σ] atom at `y` to match `τ` exactly, and a point realizes at
most one such type (`nf_eval_unique`). Consequently there is **no ⊤ point type**: the report-12
sketch's `skelR : ExistsForallFormula sig F r` (`⊤ point types`, satisfied by every `StrictMono
env`) is not constructible as a single formula — a fixed complete point type at an inserted point
constrains the arbitrary context value there. The faithful universally-satisfiable skeleton is a
**`VeeExistsForall`**, disjoining over the finite set of point-type assignments (`skelR` below):
for any environment, the disjunct whose point types are the environment's *characteristic* types
(`charType`) is satisfied. Interval types, by contrast, are **partial** (`IntervalType = Finset
UnaryType`); the ⊤ interval `intervalTop = univ` is trivially satisfied at every point
(`intervalHolds_top`), because every point realizes *some* complete type.

This same disjoin-over-point-types device is what an arity lift needs at each inserted context
point: the inserted point's complete type is not statically known, so `liftPair` must range over
all completions — exactly as `skelR` demonstrates end to end here.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Lemma 3.2(1) (p.4), Lemma 3.4 (p.5), Def 3.1
  (p.4), Prop 4.3 ¬-case (p.6). Cited by PDF page; the companion markdown transcription is corrupt.
- `ConjInterleave.lean`: the landed both-directions merge `conjInterleave_iff` and its internal
  `MergePair` / `mergedFormula` / sorted-union rank machinery reused by the lift.
- `ExistsForallFormula.lean`: `ExistsForallFormula`, `efSat`, `UnaryType`, `unaryHolds`,
  `IntervalType`, `intervalHolds`.
- `NormalForm.lean`: `nf_characteristic` / `nf_characteristic_satisfies` (the characteristic type
  of a point).

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. Every point realizes a complete unary type; ⊤ intervals are trivially satisfied -/

/-- The **characteristic** complete unary type of a model point `y`: the unique complete 1-type
`y` realizes (`nf_characteristic` at depth 0, one variable). -/
noncomputable def charType (N : OrderedMonadicStructure (sigE sig F)) (y : N.carrier) :
    UnaryType sig F :=
  nf_characteristic N 0 1 (fun _ => y)

/-- Every point realizes its own characteristic type. -/
theorem unaryHolds_charType (N : OrderedMonadicStructure (sigE sig F)) (y : N.carrier) :
    unaryHolds N (charType N y) y :=
  nf_characteristic_satisfies N 0 1 (fun _ => y)

/-- Every point realizes **some** complete unary type. -/
theorem exists_unaryHolds (N : OrderedMonadicStructure (sigE sig F)) (y : N.carrier) :
    ∃ τ : UnaryType sig F, unaryHolds N τ y :=
  ⟨charType N y, unaryHolds_charType N y⟩

/-- The ⊤ interval type `intervalTop = univ` is satisfied at **every** point: some complete type
(the characteristic one) is admissible and realized. This is the interval-level ⊤ that inserted
context points carry between the fixed pinned points of an arity lift. -/
theorem intervalHolds_top (N : OrderedMonadicStructure (sigE sig F)) (y : N.carrier) :
    intervalHolds N (intervalTop sig F) y := by
  obtain ⟨τ, hτ⟩ := exists_unaryHolds N y
  refine ⟨τ, ?_, hτ⟩
  simp only [intervalTop, Finset.mem_univ]

/-! ## 2. The universally-satisfiable arity-`m+1` skeleton (`VeeExistsForall`) -/

/-- A single **skeleton disjunct** at arity `m+1`: `m+1` ordered points, identity-pinned
(`pin = id`), carrying the point-type assignment `σ` and ⊤ (`univ`) interval types everywhere. Its
`efSat` at an environment `env` says exactly that `env` is strictly increasing and realizes `σ` at
each point. -/
def skelDisjunct (m : Nat) (σ : Fin (m + 1) → UnaryType sig F) :
    ExistsForallFormula sig F (m + 1) where
  n := m
  pin := id
  pointType := σ
  intervalType := fun _ => intervalTop sig F

/-- The **skeleton ∨∃∀-formula** at arity `m+1`: the finite disjunction, over every point-type
assignment, of the identity-pinned ⊤-interval formula. It is satisfied by **every** `StrictMono`
environment — the disjunct whose point types are the environment's characteristic types
(`charType`) witnesses it (`skelR_sat`). This is the faithful universally-satisfiable skeleton the
report-12 `skelR` sketch intended; it is a `VeeExistsForall`, not a single `ExistsForallFormula`,
because complete point types admit no ⊤ (see the module docstring). -/
noncomputable def skelR (m : Nat) : VeeExistsForall sig F (m + 1) :=
  (Finset.univ : Finset (Fin (m + 1) → UnaryType sig F)).toList.map (skelDisjunct m)

/-- **Universal satisfiability of the skeleton.** Every strictly increasing environment satisfies
`skelR`: use the environment itself as the witness chain (identity pins), the characteristic type
at each point (point-type clauses), and the trivially-satisfied ⊤ interval type
(`intervalHolds_top`) on every open interval. -/
theorem skelR_sat {m : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin (m + 1) → N.carrier) (h : StrictMono env) :
    veeSat N env (skelR m) := by
  classical
  refine ⟨skelDisjunct m (fun v => charType N (env v)), ?_, ?_⟩
  · -- membership: the characteristic-type assignment is one of the enumerated disjuncts
    unfold skelR
    rw [List.mem_map]
    exact ⟨fun v => charType N (env v), Finset.mem_toList.mpr (Finset.mem_univ _), rfl⟩
  · -- efSat with witness chain `env`
    refine ⟨env, h, ?_, ?_, ?_, ?_, ?_⟩
    · intro k; rfl
    · intro j; exact unaryHolds_charType N (env j)
    · intro y _; exact intervalHolds_top N y
    · intro i y _ _; exact intervalHolds_top N y
    · intro y _; exact intervalHolds_top N y

/-! ## 3. The arity-lift merge datum

`liftPair` lifts a single arity-2 `∃∀`-formula `ξ` into the arity-`r` context by merging `ξ`'s
existential chain (`ξ.n+1` points) with the `r` ordered context points (the skeleton), over every
order-preserving insertion. Structurally this mirrors `ConjInterleave.MergePair`, but with three
differences forced by the lift (see `LiftPair` module docstring / spike findings):

- The two embedded objects have **different shapes**: `ξ`'s chain (`Fin (nξ+1)`) and the `r`
  skeleton points (`Fin r`), not two arity-`r` chains.
- Pin coincidence is required **only at `k, l`** (the two `ξ`-pinned context variables), not at all
  `r` variables — `LiftMergePair.valid` below.
- The skeleton carries no complete point type statically (there is no ⊤ point type). Inserted points
  range over a completion assignment `σ`, constrained to be `ξ`-interval-admissible by
  `LiftMergePair.crossConsistent`. -/

/-- Raw arity-lift merge data: an embedding of `ξ`'s `nξ+1` chain points and an embedding of the `r`
skeleton (context) points into a common merged chain of `K+1` points. Monotonicity, joint
surjectivity, and the `k,l` pin coincidence are imposed by the decidable `valid` predicate. -/
structure LiftMergePair (nξ r K : Nat) where
  /-- Embedding of `ξ`'s existential chain into the merged chain. -/
  eξ : Fin (nξ + 1) → Fin (K + 1)
  /-- Embedding of the `r` ordered skeleton (context) points into the merged chain. -/
  eS : Fin r → Fin (K + 1)
  deriving DecidableEq

/-- `LiftMergePair` is equivalent to the product of its two function spaces (for `Fintype`). -/
def LiftMergePair.equivProd (nξ r K : Nat) :
    LiftMergePair nξ r K ≃ (Fin (nξ + 1) → Fin (K + 1)) × (Fin r → Fin (K + 1)) where
  toFun m := (m.eξ, m.eS)
  invFun p := ⟨p.1, p.2⟩
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

instance (nξ r K : Nat) : Fintype (LiftMergePair nξ r K) :=
  Fintype.ofEquiv _ (LiftMergePair.equivProd nξ r K).symm

/-- The lift merge is **valid**: both embeddings strictly monotone, jointly surjective onto the
merged chain, and pin-coincident **only** at the two lifted variables `k, l` (their skeleton points
are exactly `ξ`'s two pinned chain points). This is the sole change from `MergePair.valid`, which
demands coincidence at all `r` variables. -/
def LiftMergePair.valid {nξ r K : Nat} (pinξ : Fin 2 → Fin (nξ + 1)) (k l : Fin r)
    (m : LiftMergePair nξ r K) : Prop :=
  StrictMono m.eξ ∧ StrictMono m.eS ∧
    (∀ j : Fin (K + 1), (∃ i, m.eξ i = j) ∨ (∃ i, m.eS i = j)) ∧
    m.eS k = m.eξ (pinξ 0) ∧ m.eS l = m.eξ (pinξ 1)

instance {nξ r K : Nat} (pinξ : Fin 2 → Fin (nξ + 1)) (k l : Fin r) (m : LiftMergePair nξ r K) :
    Decidable (m.valid pinξ k l) := by
  unfold LiftMergePair.valid
  infer_instance

/-- The lift merge is **cross-consistent** w.r.t. a completion assignment `σ`: at every merged point
`j` that is **not** one of `ξ`'s existential points (i.e. an inserted skeleton point interior to one
of `ξ`'s open intervals), the completion `σ j` assigned there is admissible to `ξ`'s interval type at
that slot. This is the arity-lift analogue of `MergePair.crossConsistent`; it is what keeps the
backward direction true (an inserted point interior to a `ξ`-interval must satisfy that interval),
while the forward direction discharges it automatically by choosing `σ` = the characteristic type,
which lies in the interval set by `nf_eval_unique`. -/
def LiftMergePair.crossConsistent {r K : Nat} (ξ : ExistsForallFormula sig F 2)
    (m : LiftMergePair ξ.n r K) (σ : Fin (K + 1) → UnaryType sig F) : Prop :=
  ∀ j : Fin (K + 1), (∀ i, m.eξ i ≠ j) → σ j ∈ ξ.intervalType (intervalSlot m.eξ j)

instance {r K : Nat} (ξ : ExistsForallFormula sig F 2) (m : LiftMergePair ξ.n r K)
    (σ : Fin (K + 1) → UnaryType sig F) : Decidable (LiftMergePair.crossConsistent ξ m σ) := by
  unfold LiftMergePair.crossConsistent
  infer_instance

/-! ## 4. The merged formula and `liftPair` -/

/-- The **merged point type** of the lift at merged point `j`: `ξ`'s complete point type when `j` is
one of `ξ`'s existential points `eξ i`, and the ranged-over completion `σ j` at an inserted skeleton
point. Unlike the conjunction merge there is no competition (the skeleton carries no static point
type), so `ξ` is simply preferred wherever it pins. -/
noncomputable def liftMergedPointType {K : Nat} (ξ : ExistsForallFormula sig F 2)
    (σ : Fin (K + 1) → UnaryType sig F) (eξ : Fin (ξ.n + 1) → Fin (K + 1)) (j : Fin (K + 1)) :
    UnaryType sig F :=
  open Classical in
  if h : ∃ i, eξ i = j then ξ.pointType h.choose else σ j

/-- At a merged point that is `ξ`'s existential point `eξ i`, the merged point type is exactly `ξ`'s
complete point type `ξ.pointType i` (`eξ` injective picks out `i`). -/
theorem liftMergedPointType_xi {K : Nat} (ξ : ExistsForallFormula sig F 2)
    (σ : Fin (K + 1) → UnaryType sig F) (eξ : Fin (ξ.n + 1) → Fin (K + 1)) (heξ : StrictMono eξ)
    (i : Fin (ξ.n + 1)) :
    liftMergedPointType ξ σ eξ (eξ i) = ξ.pointType i := by
  have hex : ∃ i', eξ i' = eξ i := ⟨i, rfl⟩
  simp only [liftMergedPointType, dif_pos hex]
  congr 1
  exact heξ.injective hex.choose_spec

/-- At a merged point that is **not** one of `ξ`'s existential points, the merged point type is the
ranged-over completion `σ j`. -/
theorem liftMergedPointType_skel {K : Nat} (ξ : ExistsForallFormula sig F 2)
    (σ : Fin (K + 1) → UnaryType sig F) (eξ : Fin (ξ.n + 1) → Fin (K + 1)) (j : Fin (K + 1))
    (hj : ∀ i, eξ i ≠ j) :
    liftMergedPointType ξ σ eξ j = σ j := by
  have hnex : ¬ ∃ i, eξ i = j := by rintro ⟨i, hi⟩; exact hj i hi
  simp only [liftMergedPointType, dif_neg hnex]

/-- The **merged `ExistsForallFormula`** for a lift merge datum `m` and completion assignment `σ`:
`K+1` points; each context variable `v` pinned to its skeleton point `eS v`; each point carrying the
`liftMergedPointType` (`ξ`'s type at `ξ`-points, `σ` at inserted points); each interval slot carrying
`ξ`'s interval set `chainIntervalType ξ eξ t` (the skeleton contributes ⊤ = `univ`, which drops out
of the intersection, so only `ξ`'s interval appears). A single `StrictMono` chain of unary types. -/
noncomputable def liftMergedFormula {r K : Nat} (ξ : ExistsForallFormula sig F 2)
    (σ : Fin (K + 1) → UnaryType sig F) (m : LiftMergePair ξ.n r K) :
    ExistsForallFormula sig F r where
  n := K
  pin := m.eS
  pointType := fun j => liftMergedPointType ξ σ m.eξ j
  intervalType := fun t => chainIntervalType ξ m.eξ t

/-- **`liftPair` (Rabinovich Lemma 3.2(1), p.4 — arity lift of a ≤2-free-variable disjunct).** The
`∨∃∀`-formula whose disjuncts are the merged formulas of all valid order-preserving insertions of the
`r` skeleton points into `ξ`'s chain, over all merged sizes `K+1 ≤ (ξ.n+1)+r`, all cross-consistent
completion assignments `σ`. Lifting `ξ` (pinned at context positions `k, l`) into the arity-`r`
context. -/
noncomputable def liftPair {r : Nat} (ξ : ExistsForallFormula sig F 2) (k l : Fin r) :
    VeeExistsForall sig F r :=
  open Classical in
  (List.range (ξ.n + r + 1)).flatMap fun K =>
    (Finset.univ.filter fun m : LiftMergePair ξ.n r K => m.valid ξ.pin k l).toList.flatMap fun m =>
      ((Finset.univ : Finset (Fin (K + 1) → UnaryType sig F)).filter fun σ =>
          LiftMergePair.crossConsistent ξ m σ).toList.map fun σ => liftMergedFormula ξ σ m

/-- **Membership assembly.** A valid, cross-consistent lift merge of size `K+1` (with `K` under the
enumeration bound) contributes its `liftMergedFormula` as a disjunct of `liftPair`. Discharges the
`flatMap`/`toList`/`map`/`filter` bookkeeping of the forward direction in one reusable step. -/
theorem liftMergedFormula_mem_liftPair {r : Nat} (ξ : ExistsForallFormula sig F 2) (k l : Fin r)
    {K : Nat} (hK : K < ξ.n + r + 1) (m : LiftMergePair ξ.n r K)
    (σ : Fin (K + 1) → UnaryType sig F)
    (hvalid : m.valid ξ.pin k l) (hcc : LiftMergePair.crossConsistent ξ m σ) :
    liftMergedFormula ξ σ m ∈ liftPair ξ k l := by
  unfold liftPair
  rw [List.mem_flatMap]
  refine ⟨K, List.mem_range.mpr hK, ?_⟩
  rw [List.mem_flatMap]
  refine ⟨m, ?_, ?_⟩
  · rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hvalid⟩
  · rw [List.mem_map]
    refine ⟨σ, ?_, rfl⟩
    rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hcc⟩

end Bimodal.Metalogic.WeakCanonical
