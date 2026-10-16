/-
A MODULUS MUST COVER THE PERIOD OF THE OBJECT-CLOSURE PRODUCT, NOT THE PERIOD OF THE OBJECT'S
GRAPH: the two periods are INDEPENDENT -- an object whose full-graph reach set is constant from
step 4 (period 1) carries a product whose minimal period is 3 -- and the closure-indexed carrier
on which the strengthened condition is stated is FINITE, so both countdown operators over it are
eventually periodic. That is the whole of the CHEAP half of the first standing obligation; the
expensive half, the ADEQUACY of any product construction with respect to the truth definition,
is untouched and OPEN, and nothing here is a coherence relation, a modulus, a cell index, or any
part of one.

## What was asked

The sixteenth probe
(`specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`) refuted the
six-coordinate index at rule-derived parameters by exhibiting a sub-object a formula carves out
by forbidding a PATTERN rather than a letter, and left standing a strictly stronger necessary
condition: a modulus must cover the period of every sub-object the formula's CLOSURE carves out,
not merely the letter-definable ones.  That condition promoted the first of the four standing
proof obligations -- eventual periodicity of the realizable types in the countdown over the
product of the object with the closure -- from a proof step into a necessary condition on the
index's own parameter, which is why it is attacked first and on its own.  A letter-restricted
variant of `reachN_eventually_periodic` is NOT sufficient: the restriction must be
closure-indexed, not letter-indexed.  Supply exactly the generic facts the strengthened
condition needs before it can be used, generically in the object and the formula.

## What is settled

  1. `iterate_eventually_periodic` -- iteration of an endofunction of a finite type is eventually
     periodic (ported from `specs/archive/773_ladder_cell_index_factorization/prototype/
     reach-eventual-periodicity.lean`, which is untouched).
  2. The CLOSURE-INDEXED carrier is finite: `ClType φ`, the subsets of `plusSubformulaClosure φ`,
     is a `Fintype` with decidable equality, so `Q × ClType φ` is finite whenever the object is,
     and `Finset (Q × ClType φ)` is finite in turn.  Hence both the forward reach operator
     (`prodReachStep`) and the BACKWARD operator the countdown actually iterates (`prodPreStep`:
     the states from which the given set is reachable in one step) are eventually periodic in the
     number of steps -- `prodReachN_eventually_periodic`, `prodPreN_eventually_periodic`.
  3. The replacement is a REFINEMENT and the refinement is STRICT.  `prodReach_fst_subset` says
     the object states the product can reach in `k` steps are among those the object alone can
     reach in `k` steps, for every product step relation lying over the object's; and
     `strict_object_period_one`/`strict_product_period_three`/`strict_product_not_period_one`
     exhibit an object whose full-graph reach set is constant from step `4` (period `1`) while a
     product over it has minimal period `3` -- gate 6's separation in miniature, with the context
     component standing in for the closure component that tracks the forbidden pattern.

## What this does NOT say

**This is not a factorization lemma, a cell index, or any part of one, and it claims no
sufficiency.**  No declaration here mentions `cellAt`, `ladderRealized` or `LadderCons`, in those
names or any others, and nothing here is a weakened substitute for any of them.  Specifically:

  - **The product step relation is a PARAMETER here, not a construction.**  Nothing in this file
    builds the coherence relation that would make `Q × ClType φ` the product of the object with
    the closure in the semantic sense -- no clause of `PlusTruthAt` is unfolded, no `untl`/`snce`
    fixpoint equation appears, and no theorem relates any set computed here to `tpOf`.  What is
    established is that WHATEVER that relation turns out to be, its reach and pre operators are
    eventually periodic, because the carrier it lives on is finite.  The adequacy of a product
    construction with respect to the truth definition is untouched and open.  The eighteenth
    probe, `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean`, constructs
    the LOCAL coherence relation on one fixture and leaves adequacy open there too.
  - **No modulus is computed, and no modulus is claimed computable.**  `iterate_eventually_periodic`
    is an existence statement proved by pigeonhole; it exhibits a threshold and a positive period
    and bounds neither.  Every quantity named is a count.
  - **The strictness witness is a witness, not a classification.**  It shows the product period
    need not divide the object period.  It does not say by how much, does not say the product
    period is reached by any formula's closure, and says nothing about the coprime-cycle fixture
    of the sixteenth probe, which it does not import or reconstruct.
  - **The three remaining standing obligations are untouched**: a region-length pumping lemma for
    `untl`/`snce`-depth-bounded formulas; the next deadline's coupling through `Drift`; and the
    `box`/`stab` letters through `box_mem_tpOf_iff` and `stab_mem_tpOf_iff`.

Compile:
`lake env lean specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.PlusLanguage

namespace ClosureIndexedPeriodicity

/-! ## The generic fact: iteration on a finite type is eventually periodic

Ported byte-for-byte from the fourteenth round's prototype
`specs/archive/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`,
which is untouched; it is restated here so this file stands alone. -/

/-- **Iteration of an endofunction of a finite type is eventually periodic**, with a threshold
`T` and a GENUINELY POSITIVE period `P`. -/
theorem iterate_eventually_periodic {A : Type} [Finite A] (f : A → A) (a : A) :
    ∃ T P : ℕ, 1 ≤ P ∧ ∀ k, T ≤ k → f^[k + P] a = f^[k] a := by
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] a)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨i, j - i, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = i + m := ⟨k - i, by omega⟩
    have hkey : i + m + (j - i) = m + j := by omega
    rw [hkey, Function.iterate_add_apply, ← hfe, ← Function.iterate_add_apply]
    congr 1
    omega
  · refine ⟨j, i - j, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = j + m := ⟨k - j, by omega⟩
    have hkey : j + m + (i - j) = m + i := by omega
    rw [hkey, Function.iterate_add_apply, hfe, ← Function.iterate_add_apply]
    congr 1
    omega

/-! ## The closure-indexed carrier is finite -/

/-- The closure component: a subset of `plusSubformulaClosure φ`.  This is the component a
letter-indexed restriction does not have, and the one gate 6 showed is needed: a formula can
forbid a pattern its letters cannot name, and a pattern is tracked by the closure. -/
abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}

/-- The product carrier: the object paired with the closure component. -/
abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ

/-- **The product carrier is finite whenever the object is.**  `plusSubformulaClosure φ` is a
`Finset`, so its powerset is one, and the coercion of a `Finset` to a type is a `Fintype`. -/
instance instFintypeProdState (Q : Type) [Fintype Q] (φ : PlusFormula) :
    Fintype (ProdState Q φ) := inferInstance

instance instDecEqProdState (Q : Type) [DecidableEq Q] (φ : PlusFormula) :
    DecidableEq (ProdState Q φ) := inferInstance

/-! ## The two operators the countdown iterates -/

variable {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}

/-- One step of FORWARD reachability in the product: the product states reachable in one
`pstep` from somewhere in `S`. -/
def prodReachStep (pstep : ProdState Q φ → ProdState Q φ → Bool)
    (S : Finset (ProdState Q φ)) : Finset (ProdState Q φ) :=
  S.biUnion (fun x => Finset.univ.filter (fun y => pstep x y = true))

/-- One step of BACKWARD reachability in the product: the product states from which some member
of `S` is reachable in one `pstep`.  This is the operator the COUNTDOWN iterates -- `Count true
true` forces `c' + 1 = c`, so the countdown measures distance to a fixed region-end set, and
"which product states are still live at countdown `c`" is the `c`-th iterate of this operator
applied to that set. -/
def prodPreStep (pstep : ProdState Q φ → ProdState Q φ → Bool)
    (S : Finset (ProdState Q φ)) : Finset (ProdState Q φ) :=
  Finset.univ.filter (fun x => ∃ y ∈ S, pstep x y = true)

/-- **The product's forward reach set is eventually periodic in the number of steps.**  The
closure-indexed replacement for the object-only `reachN_eventually_periodic`: the carrier is
`Finset (ProdState Q φ)`, which is finite because the closure is a `Finset`. -/
theorem prodReachN_eventually_periodic (pstep : ProdState Q φ → ProdState Q φ → Bool)
    (S : Finset (ProdState Q φ)) :
    ∃ T P : ℕ, 1 ≤ P ∧
      ∀ k, T ≤ k → (prodReachStep pstep)^[k + P] S = (prodReachStep pstep)^[k] S :=
  iterate_eventually_periodic (prodReachStep pstep) S

omit [DecidableEq Q] in
/-- **The product's backward (countdown) reach set is eventually periodic in the number of
steps.**  Same carrier, the other operator. -/
theorem prodPreN_eventually_periodic (pstep : ProdState Q φ → ProdState Q φ → Bool)
    (S : Finset (ProdState Q φ)) :
    ∃ T P : ℕ, 1 ≤ P ∧
      ∀ k, T ≤ k → (prodPreStep pstep)^[k + P] S = (prodPreStep pstep)^[k] S :=
  iterate_eventually_periodic (prodPreStep pstep) S

/-! ## The product refines the object -/

/-- The object-only reach operator, ported byte-for-byte from the fourteenth round's prototype
and from the fifteenth and sixteenth probes, which are untouched. -/
def reachStep (step : Q → Q → Bool) (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

/-- A product step relation LIES OVER the object's step relation when every product step
projects to an object step.  Every coherence relation of the intended shape does. -/
def LiesOver (pstep : ProdState Q φ → ProdState Q φ → Bool) (step : Q → Q → Bool) : Prop :=
  ∀ x y : ProdState Q φ, pstep x y = true → step x.1 y.1 = true

/-- **The product never over-approximates the object.**  The object states the product reaches in
`k` steps are among those the object alone reaches in `k` steps.  The inclusion can be STRICT
(below), which is the whole content of the strengthened modulus condition: a period read off the
object's own graph can miss a period the product exhibits. -/
theorem prodReach_fst_subset {pstep : ProdState Q φ → ProdState Q φ → Bool}
    {step : Q → Q → Bool} (h : LiesOver pstep step) :
    ∀ (k : ℕ) (S : Finset (ProdState Q φ)) (A : Finset Q), S.image Prod.fst ⊆ A →
      ((prodReachStep pstep)^[k] S).image Prod.fst ⊆ (reachStep step)^[k] A := by
  intro k
  induction k with
  | zero => intro S A hSA; simpa using hSA
  | succ k ih =>
    intro S A hSA
    rw [Function.iterate_succ_apply, Function.iterate_succ_apply]
    refine ih (prodReachStep pstep S) (reachStep step A) ?_
    intro q hq
    simp only [Finset.mem_image, prodReachStep, Finset.mem_biUnion, Finset.mem_filter,
      Finset.mem_univ, true_and] at hq
    obtain ⟨y, ⟨x, hx, hxy⟩, rfl⟩ := hq
    simp only [reachStep, Finset.mem_biUnion, Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨x.1, hSA (Finset.mem_image_of_mem Prod.fst hx), h x y hxy⟩

end ClosureIndexedPeriodicity

/-! ## The refinement is STRICT: gate 6's separation in miniature

An object on which the full graph's reach set is CONSTANT from step `3` -- period `1`, exactly
the shape the sixteenth probe's `reach5_eventually_constant` records -- carrying a product whose
minimal period is `3`.  The context component here is a bare `Bool` standing in for the closure
component; no closure, no formula and no coherence relation is constructed, so this exhibits the
SHAPE of the gap and not an instance of it.  What it settles is that the two periods are
independent: a modulus covering the object's period need not cover the product's. -/

namespace StrictnessWitness

/-- Four object states: `0, 1, 2` a 3-cycle and `0 ↔ 3` a 2-cycle beside it. -/
def step4 : Fin 4 → Fin 4 → Bool := fun q q' =>
  (q = 0 && q' = 1) || (q = 1 && q' = 2) || (q = 2 && q' = 0) ||
  (q = 0 && q' = 3) || (q = 3 && q' = 0)

/-- The object-only reach operator at this fixture. -/
def reach4 (S : Finset (Fin 4)) : Finset (Fin 4) :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step4 q q' = true))

/-- The product step: the same object steps, with the context component forbidding state `3` --
the role the closure component plays when a formula forbids a PATTERN that only the 2-cycle
exhibits. -/
def pstep4 : (Fin 4 × Bool) → (Fin 4 × Bool) → Bool := fun x y =>
  step4 x.1 y.1 && !(decide (x.1 = 3)) && !(decide (y.1 = 3))

def preach4 (S : Finset (Fin 4 × Bool)) : Finset (Fin 4 × Bool) :=
  S.biUnion (fun x => Finset.univ.filter (fun y => pstep4 x y = true))

/-- The product fibre over the object state `0`. -/
def fib0 : Finset (Fin 4 × Bool) := {(0, true), (0, false)}

/-- **The full graph's reach set is constant from step `4`**: period `1`. -/
theorem strict_object_period_one :
    ∀ k, 4 ≤ k → k ≤ 7 → reach4^[k + 1] {0} = reach4^[k] {0} := by decide

/-- **The product's reach set has period `3` from step `0`.** -/
theorem strict_product_period_three :
    ∀ k, k ≤ 4 → preach4^[k + 3] fib0 = preach4^[k] fib0 := by decide

/-- **And period `1` fails for the product at every one of those steps**, so the object's
exhibited period does not cover the product's: the two are independent. -/
theorem strict_product_not_period_one :
    ∀ k, k ≤ 4 → preach4^[k + 1] fib0 ≠ preach4^[k] fib0 := by decide

end StrictnessWitness

/-! ## Axiom check -/

#print axioms ClosureIndexedPeriodicity.iterate_eventually_periodic
#print axioms ClosureIndexedPeriodicity.prodReachN_eventually_periodic
#print axioms ClosureIndexedPeriodicity.prodPreN_eventually_periodic
#print axioms ClosureIndexedPeriodicity.prodReach_fst_subset
#print axioms StrictnessWitness.strict_object_period_one
#print axioms StrictnessWitness.strict_product_period_three
#print axioms StrictnessWitness.strict_product_not_period_one
