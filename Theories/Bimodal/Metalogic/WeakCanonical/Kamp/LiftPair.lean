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

end Bimodal.Metalogic.WeakCanonical
