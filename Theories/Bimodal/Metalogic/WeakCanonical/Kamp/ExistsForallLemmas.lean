import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType
import Mathlib.Data.Fin.VecNotation
import Mathlib.Data.Finset.Max
import Mathlib.Order.Fin.Basic

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

/-! ## 6. Lemma 3.2(2), backward direction — infrastructure

The backward direction reconstructs a single global witness chain from the pairwise-projection
conjunction. The lemmas below are the reusable building blocks: extraction of an individual
projection's satisfaction, the fact that the environment respects the pin order (order
reflection), realization of point types at pinned environment values, and the intrinsic
sub-interval monotonicity of unary interval types (a unary type holds on any sub-interval of an
interval on which it holds, because `unaryHolds N τ y` depends only on the carrier point `y`).
-/

/-- **Projection extraction.** Every ordered pair `(k, l)` of free-variable indices has its
2-free-variable projection satisfied by the restricted environment, whenever the full
pairwise-projection conjunction is satisfied. -/
theorem pairwiseProjections_sat {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r)
    (hconj : conjSat N env (pairwiseProjections ψ)) (k l : Fin r) :
    efSat N ![env k, env l] (pairProject ψ k l) := by
  have hmem : (k, l, pairProject ψ k l) ∈ pairwiseProjections ψ := by
    rw [pairwiseProjections, List.mem_flatMap]
    exact ⟨k, List.mem_finRange k, List.mem_map.2 ⟨l, List.mem_finRange l, rfl⟩⟩
  exact hconj (k, l, pairProject ψ k l) hmem

/-- Convenience: unfold the pins of a projection's witness chain. From the projection
`pairProject ψ k l` satisfied, its witness chain `x` places `env k` at `x (ψ.pin k)` and `env l`
at `x (ψ.pin l)`. -/
theorem pairProject_pins {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (k l : Fin r)
    (h : efSat N ![env k, env l] (pairProject ψ k l)) :
    ∃ x : Fin (ψ.n + 1) → N.carrier, StrictMono x ∧
      env k = x (ψ.pin k) ∧ env l = x (ψ.pin l) ∧
      (∀ j : Fin (ψ.n + 1), unaryHolds N (ψ.pointType j) (x j)) ∧
      (∀ y : N.carrier, y < x 0 → intervalHolds N (ψ.intervalSet 0) y) ∧
      (∀ (i : Fin ψ.n) (y : N.carrier),
          x i.castSucc < y → y < x i.succ → intervalHolds N (ψ.intervalSet i.succ.castSucc) y) ∧
      (∀ y : N.carrier, x (Fin.last ψ.n) < y →
          intervalHolds N (ψ.intervalSet (Fin.last (ψ.n + 1))) y) := by
  rw [efSat_interval_iff] at h
  obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
  refine ⟨x, hmono, ?_, ?_, hpt, hbefore, hbetween, hafter⟩
  · have := hpin 0; simpa using this
  · have := hpin 1; simpa using this

/-- **Order reflection (strict).** The environment respects the strict order of the pin map: if
`ψ.pin k < ψ.pin l` then `env k < env l`. The `(k, l)` projection supplies a strictly monotone
chain placing `env k` and `env l` at those pins. -/
theorem env_lt_of_pin_lt {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r)
    (hconj : conjSat N env (pairwiseProjections ψ))
    (k l : Fin r) (hpin : ψ.pin k < ψ.pin l) : env k < env l := by
  obtain ⟨x, hmono, hk, hl, _⟩ := pairProject_pins N env ψ k l (pairwiseProjections_sat N env ψ hconj k l)
  rw [hk, hl]; exact hmono hpin

/-- **Order reflection (equality).** If two free variables share a pinned point then their
environment values agree. -/
theorem env_eq_of_pin_eq {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r)
    (hconj : conjSat N env (pairwiseProjections ψ))
    (k l : Fin r) (hpin : ψ.pin k = ψ.pin l) : env k = env l := by
  obtain ⟨x, _, hk, hl, _⟩ := pairProject_pins N env ψ k l (pairwiseProjections_sat N env ψ hconj k l)
  rw [hk, hl, hpin]

/-- **Point type at a pinned value.** The point type of a pinned position holds at the
environment value pinned there. Extracted from the diagonal projection `(k, k)`. -/
theorem pointType_holds_at_env {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r)
    (hconj : conjSat N env (pairwiseProjections ψ)) (k : Fin r) :
    unaryHolds N (ψ.pointType (ψ.pin k)) (env k) := by
  obtain ⟨x, _, hk, _, hpt, _⟩ := pairProject_pins N env ψ k k (pairwiseProjections_sat N env ψ hconj k k)
  rw [hk]; exact hpt (ψ.pin k)

/-- **Intrinsic sub-interval monotonicity.** Because `unaryHolds N τ y` depends only on the
carrier point `y`, a unary type holding on an open interval `(a, b)` also holds on any narrower
open interval `(a', b')` with `a ≤ a'` and `b' ≤ b`. -/
theorem unaryHolds_subinterval {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (τ : UnaryType sig F)
    {a b a' b' : N.carrier} (hab : ∀ y : N.carrier, a < y → y < b → unaryHolds N τ y)
    (ha : a ≤ a') (hb : b' ≤ b) :
    ∀ y : N.carrier, a' < y → y < b' → unaryHolds N τ y := by
  intro y hy1 hy2
  exact hab y (lt_of_le_of_lt ha hy1) (lt_of_lt_of_le hy2 hb)

/-! ## 7. The augmented backward target (existence content + pairwise projections)

The pure pairwise-projection conjunction is not a sound backward target: over `r = 0` free
variables it is the empty conjunction (vacuously true) while an `∃∀`-*sentence* need not be
satisfiable. The backward target therefore carries, in addition to the pairwise projections, an
explicit **existence sentence** — the `0`-free-variable `∃∀`-formula asserting the ordered chain
with all point/interval types exists. Both components have at most two free variables (the
existence sentence has zero), so the arity cap is preserved.
-/

/-- The **existence sentence** of an `∃∀`-formula: the same ordered chain, point types, and
interval types, but with **no** free variables (every pin forgotten). Its satisfaction is exactly
the chain-existence content of `ψ`. -/
def existenceSentence {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) : ExistsForallFormula sig F 0 where
  n := ψ.n
  pin := Fin.elim0
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- The **augmented backward target** of Lemma 3.2(2): the pairwise-projection conjunction
together with the existence sentence. -/
structure AugConjExistsForall (sig : MonadicSignature) (F : Finset Formula) (r : Nat) where
  /-- The conjunction of 2-free-variable pairwise projections. -/
  pairwise : ConjExistsForall sig F r
  /-- The 0-free-variable existence sentence carrying the chain-existence content. -/
  existence : ExistsForallFormula sig F 0

/-- Satisfaction of the augmented target: every pairwise projection holds **and** the existence
sentence holds. -/
def augConjSat {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : AugConjExistsForall sig F r) : Prop :=
  conjSat N env Ψ.pairwise ∧ efSat N ![] Ψ.existence

/-- The augmented backward target built from `ψ`: its pairwise projections plus its existence
sentence. -/
def augTarget {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) : AugConjExistsForall sig F r :=
  ⟨pairwiseProjections ψ, existenceSentence ψ⟩

/-- The existence sentence is satisfied whenever `ψ` is: drop all pins from the witness chain. -/
theorem existenceSentence_of_efSat {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (h : efSat N env ψ) :
    efSat N ![] (existenceSentence ψ) := by
  obtain ⟨x, hmono, _, hpt, hbefore, hbetween, hafter⟩ := h
  exact ⟨x, hmono, fun k => k.elim0, hpt, hbefore, hbetween, hafter⟩

/--
**Lemma 3.2(2), forward direction into the augmented target.** Every satisfied `∃∀`-formula
satisfies its augmented backward target: the pairwise projections (`lemma_32_2_forward`) and the
existence sentence both hold on the single global witness chain.
-/
theorem augTarget_forward {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (h : efSat N env ψ) :
    augConjSat N env (augTarget ψ) :=
  ⟨lemma_32_2_forward N env ψ h, existenceSentence_of_efSat N env ψ h⟩

/--
**Lemma 3.2(2), backward direction at arity 0.** For a sentence (`r = 0`) the augmented target's
existence sentence directly witnesses `ψ`: there are no pins to reconcile, so the chain given by
the existence content is already a witness. This is the base case that the pure pairwise
conjunction could not supply.
-/
theorem augTarget_backward_zero {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin 0 → N.carrier)
    (ψ : ExistsForallFormula sig F 0)
    (h : augConjSat N env (augTarget ψ)) : efSat N env ψ := by
  obtain ⟨x, hmono, _, hpt, hbefore, hbetween, hafter⟩ := h.2
  exact ⟨x, hmono, fun k => k.elim0, hpt, hbefore, hbetween, hafter⟩

/-! ## 8. Lemma 3.2(2), backward direction — the piecewise chain gluing (general `r`)

The general-`r` backward direction glues the pairwise witness chains into one global chain.
For each existential position `p`, the value `x p` is read from the pairwise-projection chain of
the **bracketing pins** of `p` — the nearest pinned free variable at-or-below `p` (`loPos`) and
at-or-above `p` (`hiPos`). At a pinned position the two brackets coincide with the position itself,
so `x p = env k`; on a gap the bracket chain interpolates strictly between the two pinned
endpoints. Consecutive positions always share a single bracket chain (or straddle a pinned point
whose value is the shared bracket-chain value), so strict monotonicity and the interval types
transfer directly from that one chain — no cross-chain reconciliation is ever needed.
-/

/-- Congruence for a `max'`-with-fallback `dite` under Finset equality. -/
private theorem dite_max'_congr {α : Type*} [LinearOrder α] {s t : Finset α} (h : s = t) (c : α) :
    (if hs : s.Nonempty then s.max' hs else c)
      = (if ht : t.Nonempty then t.max' ht else c) := by
  subst h; rfl

/-- Congruence for a `min'`-with-fallback `dite` under Finset equality. -/
private theorem dite_min'_congr {α : Type*} [LinearOrder α] {s t : Finset α} (h : s = t) (c : α) :
    (if hs : s.Nonempty then s.min' hs else c)
      = (if ht : t.Nonempty then t.min' ht else c) := by
  subst h; rfl

/-- The set of existential positions pinned by some free variable. -/
private def pinnedPositions {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) : Finset (Fin (ψ.n + 1)) :=
  Finset.univ.image ψ.pin

private theorem mem_pinnedPositions {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormula sig F r} {s : Fin (ψ.n + 1)} :
    s ∈ pinnedPositions ψ ↔ ∃ k, ψ.pin k = s := by
  simp [pinnedPositions]

private theorem pinnedPositions_nonempty {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (hr : 0 < r) : (pinnedPositions ψ).Nonempty :=
  ⟨ψ.pin ⟨0, hr⟩, mem_pinnedPositions.2 ⟨⟨0, hr⟩, rfl⟩⟩

/-- A free-variable index pinning a pinned position (junk `⟨0,hr⟩` off the pinned set). -/
private noncomputable def idxOf {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (hr : 0 < r) (s : Fin (ψ.n + 1)) : Fin r :=
  if h : ∃ k, ψ.pin k = s then h.choose else ⟨0, hr⟩

private theorem pin_idxOf {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormula sig F r} (hr : 0 < r) {s : Fin (ψ.n + 1)}
    (hs : s ∈ pinnedPositions ψ) : ψ.pin (idxOf ψ hr s) = s := by
  have h : ∃ k, ψ.pin k = s := mem_pinnedPositions.1 hs
  rw [idxOf, dif_pos h]
  exact h.choose_spec

/-- Nearest pinned position `≤ j` (falling back to the least pinned position when none is `≤ j`). -/
private noncomputable def loPos {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) : Fin (ψ.n + 1) :=
  if h : ((pinnedPositions ψ).filter (· ≤ j)).Nonempty then
    ((pinnedPositions ψ).filter (· ≤ j)).max' h
  else (pinnedPositions ψ).min' (pinnedPositions_nonempty ψ hr)

/-- Nearest pinned position `≥ j` (falling back to the greatest pinned position when none is `≥ j`). -/
private noncomputable def hiPos {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) : Fin (ψ.n + 1) :=
  if h : ((pinnedPositions ψ).filter (j ≤ ·)).Nonempty then
    ((pinnedPositions ψ).filter (j ≤ ·)).min' h
  else (pinnedPositions ψ).max' (pinnedPositions_nonempty ψ hr)

private theorem loPos_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) :
    loPos ψ hr j ∈ pinnedPositions ψ := by
  unfold loPos
  split
  · exact Finset.mem_of_mem_filter _ (Finset.max'_mem _ _)
  · exact Finset.min'_mem _ _

private theorem hiPos_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) :
    hiPos ψ hr j ∈ pinnedPositions ψ := by
  unfold hiPos
  split
  · exact Finset.mem_of_mem_filter _ (Finset.min'_mem _ _)
  · exact Finset.max'_mem _ _

private theorem loPos_of_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormula sig F r} (hr : 0 < r) {j : Fin (ψ.n + 1)}
    (hj : j ∈ pinnedPositions ψ) : loPos ψ hr j = j := by
  have hmemf : j ∈ (pinnedPositions ψ).filter (· ≤ j) := Finset.mem_filter.2 ⟨hj, le_refl j⟩
  have hne : ((pinnedPositions ψ).filter (· ≤ j)).Nonempty := ⟨j, hmemf⟩
  unfold loPos
  rw [dif_pos hne]
  apply le_antisymm
  · exact Finset.max'_le _ _ _ (fun y hy => (Finset.mem_filter.1 hy).2)
  · exact Finset.le_max' ((pinnedPositions ψ).filter (· ≤ j)) j hmemf

private theorem hiPos_of_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormula sig F r} (hr : 0 < r) {j : Fin (ψ.n + 1)}
    (hj : j ∈ pinnedPositions ψ) : hiPos ψ hr j = j := by
  have hmemf : j ∈ (pinnedPositions ψ).filter (j ≤ ·) := Finset.mem_filter.2 ⟨hj, le_refl j⟩
  have hne : ((pinnedPositions ψ).filter (j ≤ ·)).Nonempty := ⟨j, hmemf⟩
  unfold hiPos
  rw [dif_pos hne]
  apply le_antisymm
  · exact Finset.min'_le ((pinnedPositions ψ).filter (j ≤ ·)) j hmemf
  · exact Finset.le_min' _ _ _ (fun y hy => (Finset.mem_filter.1 hy).2)

/-- On a gap, the nearest pin `≤` is unchanged when stepping from `i.succ` down to `i.castSucc`. -/
private theorem loPos_succ_eq_castSucc {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormula sig F r} (hr : 0 < r) {i : Fin ψ.n}
    (hns : i.succ ∉ pinnedPositions ψ) :
    loPos ψ hr i.succ = loPos ψ hr i.castSucc := by
  have hfilter : (pinnedPositions ψ).filter (· ≤ i.succ)
      = (pinnedPositions ψ).filter (· ≤ i.castSucc) := by
    apply Finset.filter_congr
    intro s hs
    constructor
    · intro hsle
      have hne : s ≠ i.succ := fun he => hns (he ▸ hs)
      have hlt : s < i.succ := lt_of_le_of_ne hsle hne
      have e1 : (i.succ : Fin (ψ.n + 1)).val = i.val + 1 := Fin.val_succ i
      have e2 : (i.castSucc : Fin (ψ.n + 1)).val = i.val := Fin.val_castSucc i
      rw [Fin.lt_def] at hlt
      rw [Fin.le_def]
      omega
    · intro hsle
      exact le_trans hsle (le_of_lt Fin.castSucc_lt_succ)
  unfold loPos
  exact dite_max'_congr hfilter _

/-- On a gap, the nearest pin `≥` is unchanged when stepping from `i.castSucc` up to `i.succ`. -/
private theorem hiPos_castSucc_eq_succ {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormula sig F r} (hr : 0 < r) {i : Fin ψ.n}
    (hns : i.castSucc ∉ pinnedPositions ψ) :
    hiPos ψ hr i.castSucc = hiPos ψ hr i.succ := by
  have hfilter : (pinnedPositions ψ).filter (i.castSucc ≤ ·)
      = (pinnedPositions ψ).filter (i.succ ≤ ·) := by
    apply Finset.filter_congr
    intro s hs
    constructor
    · intro hsge
      have hne : s ≠ i.castSucc := fun he => hns (he ▸ hs)
      have hlt : i.castSucc < s := lt_of_le_of_ne hsge (Ne.symm hne)
      have e1 : (i.succ : Fin (ψ.n + 1)).val = i.val + 1 := Fin.val_succ i
      have e2 : (i.castSucc : Fin (ψ.n + 1)).val = i.val := Fin.val_castSucc i
      rw [Fin.lt_def] at hlt
      rw [Fin.le_def]
      omega
    · intro hsge
      exact le_trans (le_of_lt Fin.castSucc_lt_succ) hsge
  unfold hiPos
  exact dite_min'_congr hfilter _

/-- The pairwise-projection witness chain for the free-variable pair `(k, l)`. -/
private noncomputable def chainOf {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (k l : Fin r) : Fin (ψ.n + 1) → N.carrier :=
  (pairProject_pins N env ψ k l (pairwiseProjections_sat N env ψ hconj k l)).choose

private theorem chainOf_spec {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (k l : Fin r) :
    StrictMono (chainOf N env ψ hconj k l) ∧
      env k = chainOf N env ψ hconj k l (ψ.pin k) ∧
      env l = chainOf N env ψ hconj k l (ψ.pin l) ∧
      (∀ j : Fin (ψ.n + 1), unaryHolds N (ψ.pointType j) (chainOf N env ψ hconj k l j)) ∧
      (∀ y : N.carrier, y < chainOf N env ψ hconj k l 0 →
        intervalHolds N (ψ.intervalSet 0) y) ∧
      (∀ (i : Fin ψ.n) (y : N.carrier),
        chainOf N env ψ hconj k l i.castSucc < y → y < chainOf N env ψ hconj k l i.succ →
          intervalHolds N (ψ.intervalSet i.succ.castSucc) y) ∧
      (∀ y : N.carrier, chainOf N env ψ hconj k l (Fin.last ψ.n) < y →
        intervalHolds N (ψ.intervalSet (Fin.last (ψ.n + 1))) y) :=
  (pairProject_pins N env ψ k l (pairwiseProjections_sat N env ψ hconj k l)).choose_spec

/-- Reading a bracket chain at a pinned position it pins on the left slot gives the env value. -/
private theorem chainOf_at_pin_left {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) {s : Fin (ψ.n + 1)} (hs : s ∈ pinnedPositions ψ) (l : Fin r) :
    chainOf N env ψ hconj (idxOf ψ hr s) l s = env (idxOf ψ hr s) := by
  have hpin := pin_idxOf hr hs
  have hb := (chainOf_spec N env ψ hconj (idxOf ψ hr s) l).2.1
  rw [hpin] at hb
  exact hb.symm

/-- Reading a bracket chain at a pinned position it pins on the right slot gives the env value. -/
private theorem chainOf_at_pin_right {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) {s : Fin (ψ.n + 1)} (hs : s ∈ pinnedPositions ψ) (k : Fin r) :
    chainOf N env ψ hconj k (idxOf ψ hr s) s = env (idxOf ψ hr s) := by
  have hpin := pin_idxOf hr hs
  have hc := (chainOf_spec N env ψ hconj k (idxOf ψ hr s)).2.2.1
  rw [hpin] at hc
  exact hc.symm

/-- The glued global witness chain: at each position, read the bracket chain of its nearest pins. -/
private noncomputable def gluedChain {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) (j : Fin (ψ.n + 1)) : N.carrier :=
  chainOf N env ψ hconj (idxOf ψ hr (loPos ψ hr j)) (idxOf ψ hr (hiPos ψ hr j)) j

/-- At a pinned position the glued chain reads the env value of the pinning free variable. -/
private theorem gluedChain_pin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) (k : Fin r) :
    gluedChain N env ψ hconj hr (ψ.pin k) = env k := by
  have hjmem : ψ.pin k ∈ pinnedPositions ψ := mem_pinnedPositions.2 ⟨k, rfl⟩
  unfold gluedChain
  rw [loPos_of_mem hr hjmem, chainOf_at_pin_left N env ψ hconj hr hjmem]
  exact env_eq_of_pin_eq N env ψ hconj (idxOf ψ hr (ψ.pin k)) k (pin_idxOf hr hjmem)

/-- For each edge, a single bracket chain computes the glued chain at both endpoints. -/
private theorem consecChain {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) (i : Fin ψ.n) :
    ∃ k l : Fin r,
      gluedChain N env ψ hconj hr i.castSucc = chainOf N env ψ hconj k l i.castSucc ∧
      gluedChain N env ψ hconj hr i.succ = chainOf N env ψ hconj k l i.succ := by
  refine ⟨idxOf ψ hr (loPos ψ hr i.castSucc), idxOf ψ hr (hiPos ψ hr i.succ), ?_, ?_⟩
  · unfold gluedChain
    by_cases hq : i.castSucc ∈ pinnedPositions ψ
    · rw [loPos_of_mem hr hq,
        chainOf_at_pin_left N env ψ hconj hr hq (idxOf ψ hr (hiPos ψ hr i.castSucc)),
        chainOf_at_pin_left N env ψ hconj hr hq (idxOf ψ hr (hiPos ψ hr i.succ))]
    · rw [hiPos_castSucc_eq_succ hr hq]
  · unfold gluedChain
    by_cases hq' : i.succ ∈ pinnedPositions ψ
    · rw [hiPos_of_mem hr hq',
        chainOf_at_pin_right N env ψ hconj hr hq' (idxOf ψ hr (loPos ψ hr i.succ)),
        chainOf_at_pin_right N env ψ hconj hr hq' (idxOf ψ hr (loPos ψ hr i.castSucc))]
    · rw [loPos_succ_eq_castSucc hr hq']

private theorem gluedChain_strictMono {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) : StrictMono (gluedChain N env ψ hconj hr) := by
  rw [Fin.strictMono_iff_lt_succ]
  intro i
  obtain ⟨k, l, hq, hq'⟩ := consecChain N env ψ hconj hr i
  rw [hq, hq']
  exact (chainOf_spec N env ψ hconj k l).1 Fin.castSucc_lt_succ

private theorem gluedChain_between {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) (i : Fin ψ.n) (y : N.carrier)
    (h1 : gluedChain N env ψ hconj hr i.castSucc < y)
    (h2 : y < gluedChain N env ψ hconj hr i.succ) :
    intervalHolds N (ψ.intervalSet i.succ.castSucc) y := by
  obtain ⟨k, l, hq, hq'⟩ := consecChain N env ψ hconj hr i
  rw [hq] at h1
  rw [hq'] at h2
  exact (chainOf_spec N env ψ hconj k l).2.2.2.2.2.1 i y h1 h2

private theorem gluedChain_pointType {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) (j : Fin (ψ.n + 1)) :
    unaryHolds N (ψ.pointType j) (gluedChain N env ψ hconj hr j) := by
  unfold gluedChain
  exact (chainOf_spec N env ψ hconj _ _).2.2.2.1 j

private theorem gluedChain_before {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) (y : N.carrier) (hy : y < gluedChain N env ψ hconj hr 0) :
    intervalHolds N (ψ.intervalSet 0) y := by
  unfold gluedChain at hy
  exact (chainOf_spec N env ψ hconj _ _).2.2.2.2.1 y hy

private theorem gluedChain_after {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (hconj : conjSat N env (pairwiseProjections ψ))
    (hr : 0 < r) (y : N.carrier) (hy : gluedChain N env ψ hconj hr (Fin.last ψ.n) < y) :
    intervalHolds N (ψ.intervalSet (Fin.last (ψ.n + 1))) y := by
  unfold gluedChain at hy
  exact (chainOf_spec N env ψ hconj _ _).2.2.2.2.2.2 y hy

/--
**Lemma 3.2(2), backward direction (general `r`).** The augmented backward target implies the
`∃∀`-formula: glue the pairwise-projection chains into one global witness chain along the pinned
positions. For `r = 0` this is `augTarget_backward_zero`; for `r ≥ 1` the glued chain
`gluedChain` discharges all six `efSat` clauses (strict monotonicity and the between-interval
types from the shared per-edge bracket chain; pins, point types, and the before/after intervals
directly from the responsible bracket chain).
-/
theorem augTarget_backward {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r)
    (h : augConjSat N env (augTarget ψ)) : efSat N env ψ := by
  rcases Nat.eq_zero_or_pos r with hr0 | hr
  · subst hr0
    exact augTarget_backward_zero N env ψ h
  · obtain ⟨hconj, _hex⟩ := h
    have hconj' : conjSat N env (pairwiseProjections ψ) := hconj
    rw [efSat_interval_iff]
    refine ⟨gluedChain N env ψ hconj' hr, gluedChain_strictMono N env ψ hconj' hr, ?_,
      fun j => gluedChain_pointType N env ψ hconj' hr j,
      fun y hy => gluedChain_before N env ψ hconj' hr y hy,
      fun i y h1 h2 => gluedChain_between N env ψ hconj' hr i y h1 h2,
      fun y hy => gluedChain_after N env ψ hconj' hr y hy⟩
    intro k
    exact (gluedChain_pin N env ψ hconj' hr k).symm

/--
**Lemma 3.2(2) (p.4), full biconditional.** An `∃∀`-formula is satisfied iff its augmented
backward target (the pairwise 2-free-variable projections together with the 0-free-variable
existence sentence) is satisfied. Combines `augTarget_forward` and `augTarget_backward`. This is
the load-bearing ≤2-free-variable arity cap; Phase 7's Negation case consumes the biconditional.
-/
theorem augTarget_iff {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) :
    efSat N env ψ ↔ augConjSat N env (augTarget ψ) :=
  ⟨augTarget_forward N env ψ, augTarget_backward N env ψ⟩

end Bimodal.Metalogic.WeakCanonical
