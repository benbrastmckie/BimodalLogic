import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Mathlib.Data.Fin.VecNotation

/-!
# Lemma 3.2(2): the ≤2-free-variable arity cap (Rabinovich, PDF p.4)

This module builds toward **Lemma 3.2(2)** — the load-bearing arity bound of the whole
E[Σ] re-architecture: every `∃∀`-formula is equivalent to a conjunction of `∃∀`-formulas each
with **at most two free variables**. Capping the free-variable arity at 2 is precisely what lets
the completeness spine (Prop 4.3) induct over formula structure without ever forming the arity-4
joint type that obstructs the present architecture.

## The conjunctive target (dual of `VeeExistsForall`)

The disjunctive object `VeeExistsForall` (Def 3.3, p.4) is a `List (ExistsForallFormula sig F r)`
with existential satisfaction `veeSat`. Its **conjunctive dual** is the target of Lemma 3.2(2):
a finite conjunction whose every conjunct is a **2-free-variable** `∃∀`-formula, tagged with the
two free-variable indices `k, l ∈ Fin r` it constrains, and read against the *restricted*
environment `![env k, env l]`. This is `ConjExistsForall sig F r`, with satisfaction `conjSat`.

Because every conjunct lives in `ExistsForallFormula sig F 2`, the arity cap is **structural**:
no conjunct ever reads more than two coordinates of `env`.

## What this module proves

- The conjunctive dual `ConjExistsForall`/`conjSat` with its basic closure facts (nil, singleton,
  cons, append) — the ∧-analogue of `VeeExistsForall`'s `veeSat_append`.
- `pairProject ψ k l`: the 2-free-variable projection of an `∃∀`-formula onto the free-variable
  pair `(k, l)` — the same ordered point chain and unary point/interval types as `ψ`, but pinning
  only `z_k` and `z_l`.
- `pairwiseProjections ψ`: the conjunction of all pairwise projections.
- **Lemma 3.2(2), forward direction** (`lemma_32_2_forward`): every satisfied `∃∀`-formula
  satisfies its pairwise-projection conjunction. This is the "project the global witness chain to
  each free-variable pair" half of the proof; it is unconditional.

The backward direction (glue the pairwise witness chains into one global chain, using linearity
of the carrier order) is the substantial remaining content. Two things it requires that the
forward direction does not:

1. **Existence content.** The pure pairwise-projection conjunction `pairwiseProjections` is not a
   sound backward target on its own: over zero free variables it is the empty conjunction (`⟨⟩`
   vacuously holds), yet an `∃∀`-sentence need not be satisfiable, so `conjSat → efSat` would be
   false. The backward target must additionally carry the ordered-chain *existence* claim — in
   Rabinovich this is the singleton (one-free-variable) `∃∀`-formulas that pin one point and
   assert the surrounding chain. `pairwiseProjections` is complete only as the **forward** target.
2. **Piecewise chain gluing.** With the existence content in hand, one partitions the `n+1`
   ordered points into the maximal gaps between consecutive pinned positions; the free-variable
   pair spanning each gap supplies a chain segment (with the correct unary point/interval types on
   that gap), and the segments glue along the shared pinned endpoints by linearity of the carrier
   order. Interval types transfer verbatim because each glued open interval coincides with an
   interval of the spanning pair's chain (the point/interval type data is shared across all
   projections).

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Lemma 3.2 (p.4). Cited by PDF page; the
  companion markdown transcription is corrupt.
- `ExistsForallFormula.lean`: the Def 3.1 object `ExistsForallFormula` and its `efSat` semantics.
- `VeeExistsForall.lean`: the disjunctive dual and Lemma 3.4 disjunction closure.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

/-! ## 1. The conjunctive dual object (≤2-free-variable target of Lemma 3.2(2)) -/

/-- A conjunction of **2-free-variable** `∃∀`-formulas, each tagged with the pair of
free-variable indices `(k, l) ∈ Fin r × Fin r` it constrains. This is the conjunctive dual of
`VeeExistsForall` and the target normal form of Lemma 3.2(2): every conjunct is arity-2, so the
arity cap is structural. -/
abbrev ConjExistsForall (sig : MonadicSignature) (F : Finset Formula) (r : Nat) : Type :=
  List (Fin r × Fin r × ExistsForallFormula sig F 2)

/-- Satisfaction of a conjunctive-dual formula: **every** tagged conjunct `(k, l, χ)` is satisfied
by the restricted environment `![env k, env l]`. -/
def conjSat {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : ConjExistsForall sig F r) : Prop :=
  ∀ p ∈ Ψ, efSat N ![env p.1, env p.2.1] p.2.2

/-! ## 2. Basic satisfaction facts for the conjunctive dual -/

/-- The empty conjunction is vacuously satisfied. -/
@[simp] theorem conjSat_nil {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier) :
    conjSat N env ([] : ConjExistsForall sig F r) := by
  intro p hp
  exact absurd hp (List.not_mem_nil)

/-- Cons: a conjunction `p :: Ψ` holds iff the head conjunct holds and `Ψ` holds. -/
@[simp] theorem conjSat_cons {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (p : Fin r × Fin r × ExistsForallFormula sig F 2) (Ψ : ConjExistsForall sig F r) :
    conjSat N env (p :: Ψ) ↔
      efSat N ![env p.1, env p.2.1] p.2.2 ∧ conjSat N env Ψ := by
  constructor
  · intro h
    exact ⟨h p (List.mem_cons_self ..), fun q hq => h q (List.mem_cons_of_mem _ hq)⟩
  · rintro ⟨hhead, htail⟩ q hq
    rcases List.mem_cons.1 hq with rfl | hmem
    · exact hhead
    · exact htail q hmem

/-- **Conjunction closure (append).** The concatenation of two conjunctive-dual formulas is
satisfied iff both are: the conjunctive dual is closed under conjunction, directly by list
concatenation (the ∧-analogue of `veeSat_append`). -/
theorem conjSat_append {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ Φ : ConjExistsForall sig F r) :
    conjSat N env (Ψ ++ Φ) ↔ conjSat N env Ψ ∧ conjSat N env Φ := by
  constructor
  · intro h
    refine ⟨fun p hp => h p (List.mem_append.2 (Or.inl hp)),
            fun p hp => h p (List.mem_append.2 (Or.inr hp))⟩
  · rintro ⟨hΨ, hΦ⟩ p hp
    rcases List.mem_append.1 hp with h | h
    · exact hΨ p h
    · exact hΦ p h

/-! ## 3. The pairwise 2-free-variable projection (Lemma 3.2(2), p.4) -/

/-- The **2-free-variable projection** of an `∃∀`-formula `ψ` onto the free-variable pair
`(k, l)`: the identical ordered point chain (`n`), unary point types, and interval types, but
pinning only `z_k` (to `x_{ψ.pin k}`) and `z_l` (to `x_{ψ.pin l}`). Every other free variable of
`ψ` is dropped, so the projection is genuinely arity 2. -/
def pairProject {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (k l : Fin r) : ExistsForallFormula sig F 2 where
  n := ψ.n
  pin := ![ψ.pin k, ψ.pin l]
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- The conjunction of **all** pairwise projections of `ψ` — the candidate Lemma 3.2(2) normal
form. Indexed over every ordered pair `(k, l) ∈ Fin r × Fin r`. -/
def pairwiseProjections {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) : ConjExistsForall sig F r :=
  (List.finRange r).flatMap fun k =>
    (List.finRange r).map fun l => (k, l, pairProject ψ k l)

/-! ## 4. Lemma 3.2(2), forward direction -/

/--
**Lemma 3.2(2), forward direction (project the witness chain to each free-variable pair).**
Every satisfied `∃∀`-formula satisfies its pairwise-projection conjunction: the single global
ordered witness chain of `efSat N env ψ` witnesses every 2-free-variable projection
`pairProject ψ k l` against the restricted environment `![env k, env l]` simultaneously.

This half is unconditional. The backward direction — reconstructing one global chain from the
pairwise chains, using linearity of the carrier order — is the substantial remaining content.
-/
theorem lemma_32_2_forward {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (h : efSat N env ψ) :
    conjSat N env (pairwiseProjections ψ) := by
  obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
  intro p hp
  -- Extract the pair indices `k, l` from membership in the flatMap.
  rw [pairwiseProjections, List.mem_flatMap] at hp
  obtain ⟨k, _, hp⟩ := hp
  rw [List.mem_map] at hp
  obtain ⟨l, _, rfl⟩ := hp
  -- Goal: `efSat N ![env k, env l] (pairProject ψ k l)`. Reuse the same witness chain `x`.
  refine ⟨x, hmono, ?_, hpt, hbefore, hbetween, hafter⟩
  -- Pins: `![env k, env l] i = x (![ψ.pin k, ψ.pin l] i)` for both `i : Fin 2`.
  rw [Fin.forall_fin_two]
  exact ⟨hpin k, hpin l⟩

/-! ## 5. Lemma 3.2(3): existential quantification stays within `∃∀` (p.4) -/

/-- **Pin-drop.** Remove the pin on the existentially-bound free variable `z₀` of an
`(r+1)`-free-variable `∃∀`-formula, leaving the `r` remaining free variables (re-indexed by
`Fin.succ`) pinned as before. The ordered chain and unary types are unchanged. This is the
syntactic operation behind Lemma 3.2(3): binding `z₀` by an existential simply forgets that `z₀`
must sit at its pinned point (the point is still existentially posited by the chain). -/
def dropPin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F (r + 1)) : ExistsForallFormula sig F r where
  n := ψ.n
  pin := fun k => ψ.pin k.succ
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/--
**Lemma 3.2(3) (p.4).** Existentially quantifying the leading free variable `z₀` of an `∃∀`-formula
yields an `∃∀`-formula, namely `dropPin ψ`: the existential just sets `z₀` to its pinned ordered
point (already posited by the chain), so it is equivalent to dropping that pin. Closure of the
`∃∀` fragment under a single existential quantifier.
-/
theorem lemma_32_3 {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F (r + 1)) :
    (∃ a : N.carrier, efSat N (Fin.cons a env) ψ) ↔ efSat N env (dropPin ψ) := by
  constructor
  · rintro ⟨a, x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩
    refine ⟨x, hmono, ?_, hpt, hbefore, hbetween, hafter⟩
    intro k
    have := hpin k.succ
    rwa [Fin.cons_succ] at this
  · rintro ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩
    refine ⟨x (ψ.pin 0), x, hmono, ?_, hpt, hbefore, hbetween, hafter⟩
    intro k
    refine Fin.cases ?_ ?_ k
    · rw [Fin.cons_zero]
    · intro k'
      rw [Fin.cons_succ]
      exact hpin k'

/-- **Lemma 3.4, existential closure (p.5).** The `∨∃∀` fragment is closed under a single
existential quantifier: quantifying the leading free variable of a `∨∃∀`-formula is equivalent to
dropping the pin (`dropPin`) in each disjunct. Follows from Lemma 3.2(3) disjunct-wise. -/
theorem veeSat_exists {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : VeeExistsForall sig F (r + 1)) :
    (∃ a : N.carrier, veeSat N (Fin.cons a env) Ψ) ↔ veeSat N env (Ψ.map dropPin) := by
  constructor
  · rintro ⟨a, ψ, hmem, hsat⟩
    refine ⟨dropPin ψ, List.mem_map_of_mem hmem, ?_⟩
    exact (lemma_32_3 N env ψ).1 ⟨a, hsat⟩
  · rintro ⟨χ, hmem, hsat⟩
    rw [List.mem_map] at hmem
    obtain ⟨ψ, hψmem, rfl⟩ := hmem
    obtain ⟨a, ha⟩ := (lemma_32_3 N env ψ).2 hsat
    exact ⟨a, ψ, hψmem, ha⟩

end Bimodal.Metalogic.WeakCanonical
