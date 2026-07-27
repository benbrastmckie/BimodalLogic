/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import FormalSystem.Metalogic.WeakCanonical.Kamp.IntervalType
import FormalSystem.Metalogic.WeakCanonical.Kamp.PerFormulaExistsForall
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

/-! ## 9. Fin-variants: the lemma layer on the per-formula ∃∀-object

Mirrors of sections 1-8 on the production per-formula object `ExistsForallFormulaFin`
(`PerFormulaExistsForall.lean`), whose point/interval types are partial types over the
formula's own bundled mentioned-atom set `M` (Def 3.1, PDF p.4): the conjunctive dual and its
closure facts, the pairwise 2-free-variable projection and Lemma 3.2(2) forward, `dropPin` and
Lemma 3.2(3) with the ∨∃∀ existential closure, the backward-direction gluing infrastructure,
and the augmented-target biconditional. Every statement is the literal partial-relation
reading — `partialHolds`/`intervalHoldsFin` replace `unaryHolds`/`intervalHolds` — and NO
declaration in this section consumes any alphabet finiteness (`Fintype sig.preds` never
appears), so the layer survives the infinite E[Σ] of Def 4.1 (p.5). The proofs are verbatim
transcriptions of the total layer's: the constructions are representation-independent, all
satisfaction clauses having the same seven-component shape. The total-type lemmas above are
left untouched until the switchover deletes them.
-/

namespace Kamp

/-! ### 9.1 The conjunctive dual (Fin) -/

/-- Fin-variant of `ConjExistsForall`: a conjunction of 2-free-variable per-formula
`∃∀`-formulas, each tagged with the pair of free-variable indices it constrains. -/
abbrev ConjExistsForallFin (sig : MonadicSignature) (F : Finset Formula) (r : Nat) : Type :=
  List (Fin r × Fin r × ExistsForallFormulaFin sig F 2)

/-- Fin-variant of `conjSat`: every tagged conjunct `(k, l, χ)` is satisfied by the
restricted environment `![env k, env l]`. -/
def conjSatFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : ConjExistsForallFin sig F r) : Prop :=
  ∀ p ∈ Ψ, efSatFin N ![env p.1, env p.2.1] p.2.2

/-- The empty conjunction is vacuously satisfied (Fin). -/
@[simp] theorem conjSatFin_nil {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier) :
    conjSatFin N env ([] : ConjExistsForallFin sig F r) := by
  intro p hp
  exact absurd hp (List.not_mem_nil)

/-- Cons: `p :: Ψ` holds iff the head conjunct holds and `Ψ` holds (Fin). -/
@[simp] theorem conjSatFin_cons {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (p : Fin r × Fin r × ExistsForallFormulaFin sig F 2) (Ψ : ConjExistsForallFin sig F r) :
    conjSatFin N env (p :: Ψ) ↔
      efSatFin N ![env p.1, env p.2.1] p.2.2 ∧ conjSatFin N env Ψ := by
  constructor
  · intro h
    exact ⟨h p (List.mem_cons_self ..), fun q hq => h q (List.mem_cons_of_mem _ hq)⟩
  · rintro ⟨hhead, htail⟩ q hq
    rcases List.mem_cons.1 hq with rfl | hmem
    · exact hhead
    · exact htail q hmem

/-- Conjunction closure (append), Fin-variant of `conjSat_append`. -/
theorem conjSatFin_append {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ Φ : ConjExistsForallFin sig F r) :
    conjSatFin N env (Ψ ++ Φ) ↔ conjSatFin N env Ψ ∧ conjSatFin N env Φ := by
  constructor
  · intro h
    refine ⟨fun p hp => h p (List.mem_append.2 (Or.inl hp)),
            fun p hp => h p (List.mem_append.2 (Or.inr hp))⟩
  · rintro ⟨hΨ, hΦ⟩ p hp
    rcases List.mem_append.1 hp with h | h
    · exact hΨ p h
    · exact hΦ p h

/-! ### 9.2 The pairwise projection and Lemma 3.2(2) forward (Fin) -/

/-- Fin-variant of `pairProject`: the 2-free-variable projection of a per-formula
`∃∀`-formula onto the pair `(k, l)` — identical chain, mentioned-atom set `M`, and partial
point/interval types, pinning only `z_k` and `z_l`. -/
def pairProjectFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) (k l : Fin r) : ExistsForallFormulaFin sig F 2 where
  n := ψ.n
  M := ψ.M
  pin := ![ψ.pin k, ψ.pin l]
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- Fin-variant of `pairwiseProjections`: the conjunction of all pairwise projections. -/
def pairwiseProjectionsFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) : ConjExistsForallFin sig F r :=
  (List.finRange r).flatMap fun k =>
    (List.finRange r).map fun l => (k, l, pairProjectFin ψ k l)

/-- Lemma 3.2(2), forward direction, Fin-variant of `lemma_32_2_forward`: the single global
witness chain witnesses every 2-free-variable projection simultaneously. -/
theorem lemma_32_2_forwardFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (h : efSatFin N env ψ) :
    conjSatFin N env (pairwiseProjectionsFin ψ) := by
  obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
  intro p hp
  rw [pairwiseProjectionsFin, List.mem_flatMap] at hp
  obtain ⟨k, _, hp⟩ := hp
  rw [List.mem_map] at hp
  obtain ⟨l, _, rfl⟩ := hp
  refine ⟨x, hmono, ?_, hpt, hbefore, hbetween, hafter⟩
  rw [Fin.forall_fin_two]
  exact ⟨hpin k, hpin l⟩

/-! ### 9.3 Lemma 3.2(3) and the ∨∃∀ existential closure (Fin) -/

/-- Fin-variant of `dropPin`: remove the pin on the leading free variable, re-indexing the
remaining pins by `Fin.succ`. Chain, `M`, and partial types unchanged. -/
def dropPinFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F (r + 1)) : ExistsForallFormulaFin sig F r where
  n := ψ.n
  M := ψ.M
  pin := fun k => ψ.pin k.succ
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- Lemma 3.2(3) (p.4), Fin-variant of `lemma_32_3`: existentially quantifying the leading
free variable of a per-formula `∃∀`-formula is equivalent to dropping its pin. -/
theorem lemma_32_3Fin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F (r + 1)) :
    (∃ a : N.carrier, efSatFin N (Fin.cons a env) ψ) ↔ efSatFin N env (dropPinFin ψ) := by
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

/-- Fin-variant of `VeeExistsForall` (Def 3.3, p.4): a disjunction of per-formula
`∃∀`-formulas. Each disjunct carries its own mentioned-atom set `M`. -/
abbrev VeeExistsForallFin (sig : MonadicSignature) (F : Finset Formula) (r : Nat) : Type :=
  List (ExistsForallFormulaFin sig F r)

/-- Fin-variant of `veeSat`: some disjunct per-formula `∃∀`-formula is satisfied. -/
def veeSatFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : VeeExistsForallFin sig F r) : Prop :=
  ∃ ψ ∈ Ψ, efSatFin N env ψ

/-- Lemma 3.4, existential closure (p.5), Fin-variant of `veeSat_exists`: the per-formula
∨∃∀ fragment is closed under a single existential quantifier, disjunct-wise by
`lemma_32_3Fin`. -/
theorem veeSatFin_exists {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : VeeExistsForallFin sig F (r + 1)) :
    (∃ a : N.carrier, veeSatFin N (Fin.cons a env) Ψ) ↔ veeSatFin N env (Ψ.map dropPinFin) := by
  constructor
  · rintro ⟨a, ψ, hmem, hsat⟩
    refine ⟨dropPinFin ψ, List.mem_map_of_mem hmem, ?_⟩
    exact (lemma_32_3Fin N env ψ).1 ⟨a, hsat⟩
  · rintro ⟨χ, hmem, hsat⟩
    rw [List.mem_map] at hmem
    obtain ⟨ψ, hψmem, rfl⟩ := hmem
    obtain ⟨a, ha⟩ := (lemma_32_3Fin N env ψ).2 hsat
    exact ⟨a, ψ, hψmem, ha⟩

/-- Fin-variant of `veeSat_append` (Lemma 3.4, ∨-part, p.5): the concatenation of two
per-formula ∨∃∀-formulas is satisfied iff one of them is. Proved directly by list
concatenation. -/
theorem veeSatFin_append {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ Φ : VeeExistsForallFin sig F r) :
    veeSatFin N env (Ψ ++ Φ) ↔ veeSatFin N env Ψ ∨ veeSatFin N env Φ := by
  simp only [veeSatFin, List.mem_append]
  constructor
  · rintro ⟨ψ, hmem, hsat⟩
    rcases hmem with h | h
    · exact Or.inl ⟨ψ, h, hsat⟩
    · exact Or.inr ⟨ψ, h, hsat⟩
  · rintro (⟨ψ, h, hsat⟩ | ⟨ψ, h, hsat⟩)
    · exact ⟨ψ, Or.inl h, hsat⟩
    · exact ⟨ψ, Or.inr h, hsat⟩

/-! ### 9.4 Backward-direction infrastructure (Fin) -/

/-- Fin-variant of `pairwiseProjections_sat`: extraction of an individual projection's
satisfaction from the full pairwise conjunction. -/
theorem pairwiseProjectionsFin_sat {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r)
    (hconj : conjSatFin N env (pairwiseProjectionsFin ψ)) (k l : Fin r) :
    efSatFin N ![env k, env l] (pairProjectFin ψ k l) := by
  have hmem : (k, l, pairProjectFin ψ k l) ∈ pairwiseProjectionsFin ψ := by
    rw [pairwiseProjectionsFin, List.mem_flatMap]
    exact ⟨k, List.mem_finRange k, List.mem_map.2 ⟨l, List.mem_finRange l, rfl⟩⟩
  exact hconj (k, l, pairProjectFin ψ k l) hmem

/-- Fin-variant of `pairProject_pins`: unfold the pins of a projection's witness chain. -/
theorem pairProjectFin_pins {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (k l : Fin r)
    (h : efSatFin N ![env k, env l] (pairProjectFin ψ k l)) :
    ∃ x : Fin (ψ.n + 1) → N.carrier, StrictMono x ∧
      env k = x (ψ.pin k) ∧ env l = x (ψ.pin l) ∧
      (∀ j : Fin (ψ.n + 1), partialHolds N (ψ.pointType j) (x j)) ∧
      (∀ y : N.carrier, y < x 0 → intervalHoldsFin N (ψ.intervalType 0) y) ∧
      (∀ (i : Fin ψ.n) (y : N.carrier),
          x i.castSucc < y → y < x i.succ →
            intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y) ∧
      (∀ y : N.carrier, x (Fin.last ψ.n) < y →
          intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y) := by
  rw [efSatFin_interval_iff] at h
  obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
  refine ⟨x, hmono, ?_, ?_, hpt, hbefore, hbetween, hafter⟩
  · have := hpin 0; simpa [pairProjectFin] using this
  · have := hpin 1; simpa [pairProjectFin] using this

/-- Order reflection (strict), Fin-variant of `env_lt_of_pin_lt`. -/
theorem env_lt_of_pin_lt_fin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r)
    (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (k l : Fin r) (hpin : ψ.pin k < ψ.pin l) : env k < env l := by
  obtain ⟨x, hmono, hk, hl, _⟩ :=
    pairProjectFin_pins N env ψ k l (pairwiseProjectionsFin_sat N env ψ hconj k l)
  rw [hk, hl]; exact hmono hpin

/-- Order reflection (equality), Fin-variant of `env_eq_of_pin_eq`. -/
theorem env_eq_of_pin_eq_fin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r)
    (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (k l : Fin r) (hpin : ψ.pin k = ψ.pin l) : env k = env l := by
  obtain ⟨x, _, hk, hl, _⟩ :=
    pairProjectFin_pins N env ψ k l (pairwiseProjectionsFin_sat N env ψ hconj k l)
  rw [hk, hl, hpin]

/-- Point type at a pinned value, Fin-variant of `pointType_holds_at_env`. -/
theorem pointType_holds_at_env_fin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r)
    (hconj : conjSatFin N env (pairwiseProjectionsFin ψ)) (k : Fin r) :
    partialHolds N (ψ.pointType (ψ.pin k)) (env k) := by
  obtain ⟨x, _, hk, _, hpt, _⟩ :=
    pairProjectFin_pins N env ψ k k (pairwiseProjectionsFin_sat N env ψ hconj k k)
  rw [hk]; exact hpt (ψ.pin k)

/-- Intrinsic sub-interval monotonicity, Fin-variant of `unaryHolds_subinterval`:
`partialHolds N τ y` depends only on the carrier point `y`. -/
theorem partialHolds_subinterval {sig : MonadicSignature} {F : Finset Formula}
    {M : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F)) (τ : UnaryTypeFin sig F M)
    {a b a' b' : N.carrier} (hab : ∀ y : N.carrier, a < y → y < b → partialHolds N τ y)
    (ha : a ≤ a') (hb : b' ≤ b) :
    ∀ y : N.carrier, a' < y → y < b' → partialHolds N τ y := by
  intro y hy1 hy2
  exact hab y (lt_of_le_of_lt ha hy1) (lt_of_lt_of_le hy2 hb)

/-! ### 9.5 The augmented backward target (Fin) -/

/-- Fin-variant of `existenceSentence`: same chain, `M`, and partial types, no free
variables. -/
def existenceSentenceFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) : ExistsForallFormulaFin sig F 0 where
  n := ψ.n
  M := ψ.M
  pin := Fin.elim0
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- Fin-variant of `AugConjExistsForall`: pairwise projections plus the existence sentence. -/
structure AugConjExistsForallFin (sig : MonadicSignature) (F : Finset Formula) (r : Nat) where
  /-- The conjunction of 2-free-variable pairwise projections. -/
  pairwise : ConjExistsForallFin sig F r
  /-- The 0-free-variable existence sentence carrying the chain-existence content. -/
  existence : ExistsForallFormulaFin sig F 0

/-- Fin-variant of `augConjSat`. -/
def augConjSatFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : AugConjExistsForallFin sig F r) : Prop :=
  conjSatFin N env Ψ.pairwise ∧ efSatFin N ![] Ψ.existence

/-- Fin-variant of `augTarget`. -/
def augTargetFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) : AugConjExistsForallFin sig F r :=
  ⟨pairwiseProjectionsFin ψ, existenceSentenceFin ψ⟩

/-- Fin-variant of `existenceSentence_of_efSat`. -/
theorem existenceSentenceFin_of_efSatFin {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (h : efSatFin N env ψ) :
    efSatFin N ![] (existenceSentenceFin ψ) := by
  obtain ⟨x, hmono, _, hpt, hbefore, hbetween, hafter⟩ := h
  exact ⟨x, hmono, fun k => k.elim0, hpt, hbefore, hbetween, hafter⟩

/-- Lemma 3.2(2), forward direction into the augmented target, Fin-variant of
`augTarget_forward`. -/
theorem augTargetFin_forward {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (h : efSatFin N env ψ) :
    augConjSatFin N env (augTargetFin ψ) :=
  ⟨lemma_32_2_forwardFin N env ψ h, existenceSentenceFin_of_efSatFin N env ψ h⟩

/-- Lemma 3.2(2), backward direction at arity 0, Fin-variant of `augTarget_backward_zero`. -/
theorem augTargetFin_backward_zero {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin 0 → N.carrier)
    (ψ : ExistsForallFormulaFin sig F 0)
    (h : augConjSatFin N env (augTargetFin ψ)) : efSatFin N env ψ := by
  obtain ⟨x, hmono, _, hpt, hbefore, hbetween, hafter⟩ := h.2
  exact ⟨x, hmono, fun k => k.elim0, hpt, hbefore, hbetween, hafter⟩

/-! ### 9.6 Lemma 3.2(2), backward direction — the piecewise chain gluing (Fin)

The Fin mirror of section 8: glue the pairwise witness chains into one global chain along the
pinned positions. All position bookkeeping (`pinnedPositions`/`loPos`/`hiPos`) depends only on
the pin map and is transcribed unchanged; the chain data transports on the partial relations.
-/

/-- The set of existential positions pinned by some free variable (Fin). The `Finset.univ`
here is over the free-variable index type `Fin r` — never over the alphabet. -/
private def pinnedPositionsFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) : Finset (Fin (ψ.n + 1)) :=
  Finset.univ.image ψ.pin

private theorem mem_pinnedPositionsFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormulaFin sig F r} {s : Fin (ψ.n + 1)} :
    s ∈ pinnedPositionsFin ψ ↔ ∃ k, ψ.pin k = s := by
  simp [pinnedPositionsFin]

private theorem pinnedPositionsFin_nonempty {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) (hr : 0 < r) : (pinnedPositionsFin ψ).Nonempty :=
  ⟨ψ.pin ⟨0, hr⟩, mem_pinnedPositionsFin.2 ⟨⟨0, hr⟩, rfl⟩⟩

/-- A free-variable index pinning a pinned position (junk `⟨0,hr⟩` off the pinned set). -/
private noncomputable def idxOfFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) (hr : 0 < r) (s : Fin (ψ.n + 1)) : Fin r :=
  if h : ∃ k, ψ.pin k = s then h.choose else ⟨0, hr⟩

private theorem pin_idxOfFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormulaFin sig F r} (hr : 0 < r) {s : Fin (ψ.n + 1)}
    (hs : s ∈ pinnedPositionsFin ψ) : ψ.pin (idxOfFin ψ hr s) = s := by
  have h : ∃ k, ψ.pin k = s := mem_pinnedPositionsFin.1 hs
  rw [idxOfFin, dif_pos h]
  exact h.choose_spec

/-- Nearest pinned position `≤ j` (Fin). -/
private noncomputable def loPosFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) : Fin (ψ.n + 1) :=
  if h : ((pinnedPositionsFin ψ).filter (· ≤ j)).Nonempty then
    ((pinnedPositionsFin ψ).filter (· ≤ j)).max' h
  else (pinnedPositionsFin ψ).min' (pinnedPositionsFin_nonempty ψ hr)

/-- Nearest pinned position `≥ j` (Fin). -/
private noncomputable def hiPosFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) : Fin (ψ.n + 1) :=
  if h : ((pinnedPositionsFin ψ).filter (j ≤ ·)).Nonempty then
    ((pinnedPositionsFin ψ).filter (j ≤ ·)).min' h
  else (pinnedPositionsFin ψ).max' (pinnedPositionsFin_nonempty ψ hr)

private theorem loPosFin_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) :
    loPosFin ψ hr j ∈ pinnedPositionsFin ψ := by
  unfold loPosFin
  split
  · exact Finset.mem_of_mem_filter _ (Finset.max'_mem _ _)
  · exact Finset.min'_mem _ _

private theorem hiPosFin_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormulaFin sig F r) (hr : 0 < r) (j : Fin (ψ.n + 1)) :
    hiPosFin ψ hr j ∈ pinnedPositionsFin ψ := by
  unfold hiPosFin
  split
  · exact Finset.mem_of_mem_filter _ (Finset.min'_mem _ _)
  · exact Finset.max'_mem _ _

private theorem loPosFin_of_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormulaFin sig F r} (hr : 0 < r) {j : Fin (ψ.n + 1)}
    (hj : j ∈ pinnedPositionsFin ψ) : loPosFin ψ hr j = j := by
  have hmemf : j ∈ (pinnedPositionsFin ψ).filter (· ≤ j) := Finset.mem_filter.2 ⟨hj, le_refl j⟩
  have hne : ((pinnedPositionsFin ψ).filter (· ≤ j)).Nonempty := ⟨j, hmemf⟩
  unfold loPosFin
  rw [dif_pos hne]
  apply le_antisymm
  · exact Finset.max'_le _ _ _ (fun y hy => (Finset.mem_filter.1 hy).2)
  · exact Finset.le_max' ((pinnedPositionsFin ψ).filter (· ≤ j)) j hmemf

private theorem hiPosFin_of_mem {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    {ψ : ExistsForallFormulaFin sig F r} (hr : 0 < r) {j : Fin (ψ.n + 1)}
    (hj : j ∈ pinnedPositionsFin ψ) : hiPosFin ψ hr j = j := by
  have hmemf : j ∈ (pinnedPositionsFin ψ).filter (j ≤ ·) := Finset.mem_filter.2 ⟨hj, le_refl j⟩
  have hne : ((pinnedPositionsFin ψ).filter (j ≤ ·)).Nonempty := ⟨j, hmemf⟩
  unfold hiPosFin
  rw [dif_pos hne]
  apply le_antisymm
  · exact Finset.min'_le ((pinnedPositionsFin ψ).filter (j ≤ ·)) j hmemf
  · exact Finset.le_min' _ _ _ (fun y hy => (Finset.mem_filter.1 hy).2)

/-- On a gap, the nearest pin `≤` is unchanged stepping from `i.succ` down to `i.castSucc`
(Fin). -/
private theorem loPosFin_succ_eq_castSucc {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat}
    {ψ : ExistsForallFormulaFin sig F r} (hr : 0 < r) {i : Fin ψ.n}
    (hns : i.succ ∉ pinnedPositionsFin ψ) :
    loPosFin ψ hr i.succ = loPosFin ψ hr i.castSucc := by
  have hfilter : (pinnedPositionsFin ψ).filter (· ≤ i.succ)
      = (pinnedPositionsFin ψ).filter (· ≤ i.castSucc) := by
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
  unfold loPosFin
  exact dite_max'_congr hfilter _

/-- On a gap, the nearest pin `≥` is unchanged stepping from `i.castSucc` up to `i.succ`
(Fin). -/
private theorem hiPosFin_castSucc_eq_succ {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat}
    {ψ : ExistsForallFormulaFin sig F r} (hr : 0 < r) {i : Fin ψ.n}
    (hns : i.castSucc ∉ pinnedPositionsFin ψ) :
    hiPosFin ψ hr i.castSucc = hiPosFin ψ hr i.succ := by
  have hfilter : (pinnedPositionsFin ψ).filter (i.castSucc ≤ ·)
      = (pinnedPositionsFin ψ).filter (i.succ ≤ ·) := by
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
  unfold hiPosFin
  exact dite_min'_congr hfilter _

/-- The pairwise-projection witness chain for the pair `(k, l)` (Fin). -/
private noncomputable def chainOfFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (k l : Fin r) : Fin (ψ.n + 1) → N.carrier :=
  (pairProjectFin_pins N env ψ k l (pairwiseProjectionsFin_sat N env ψ hconj k l)).choose

private theorem chainOfFin_spec {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (k l : Fin r) :
    StrictMono (chainOfFin N env ψ hconj k l) ∧
      env k = chainOfFin N env ψ hconj k l (ψ.pin k) ∧
      env l = chainOfFin N env ψ hconj k l (ψ.pin l) ∧
      (∀ j : Fin (ψ.n + 1), partialHolds N (ψ.pointType j) (chainOfFin N env ψ hconj k l j)) ∧
      (∀ y : N.carrier, y < chainOfFin N env ψ hconj k l 0 →
        intervalHoldsFin N (ψ.intervalType 0) y) ∧
      (∀ (i : Fin ψ.n) (y : N.carrier),
        chainOfFin N env ψ hconj k l i.castSucc < y → y < chainOfFin N env ψ hconj k l i.succ →
          intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y) ∧
      (∀ y : N.carrier, chainOfFin N env ψ hconj k l (Fin.last ψ.n) < y →
        intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y) :=
  (pairProjectFin_pins N env ψ k l (pairwiseProjectionsFin_sat N env ψ hconj k l)).choose_spec

/-- Reading a bracket chain at a pinned position it pins on the left slot (Fin). -/
private theorem chainOfFin_at_pin_left {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) {s : Fin (ψ.n + 1)} (hs : s ∈ pinnedPositionsFin ψ) (l : Fin r) :
    chainOfFin N env ψ hconj (idxOfFin ψ hr s) l s = env (idxOfFin ψ hr s) := by
  have hpin := pin_idxOfFin hr hs
  have hb := (chainOfFin_spec N env ψ hconj (idxOfFin ψ hr s) l).2.1
  rw [hpin] at hb
  exact hb.symm

/-- Reading a bracket chain at a pinned position it pins on the right slot (Fin). -/
private theorem chainOfFin_at_pin_right {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) {s : Fin (ψ.n + 1)} (hs : s ∈ pinnedPositionsFin ψ) (k : Fin r) :
    chainOfFin N env ψ hconj k (idxOfFin ψ hr s) s = env (idxOfFin ψ hr s) := by
  have hpin := pin_idxOfFin hr hs
  have hc := (chainOfFin_spec N env ψ hconj k (idxOfFin ψ hr s)).2.2.1
  rw [hpin] at hc
  exact hc.symm

/-- The glued global witness chain (Fin). -/
private noncomputable def gluedChainFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) (j : Fin (ψ.n + 1)) : N.carrier :=
  chainOfFin N env ψ hconj (idxOfFin ψ hr (loPosFin ψ hr j)) (idxOfFin ψ hr (hiPosFin ψ hr j)) j

/-- At a pinned position the glued chain reads the env value (Fin). -/
private theorem gluedChainFin_pin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) (k : Fin r) :
    gluedChainFin N env ψ hconj hr (ψ.pin k) = env k := by
  have hjmem : ψ.pin k ∈ pinnedPositionsFin ψ := mem_pinnedPositionsFin.2 ⟨k, rfl⟩
  unfold gluedChainFin
  rw [loPosFin_of_mem hr hjmem, chainOfFin_at_pin_left N env ψ hconj hr hjmem]
  exact env_eq_of_pin_eq_fin N env ψ hconj (idxOfFin ψ hr (ψ.pin k)) k (pin_idxOfFin hr hjmem)

/-- For each edge, a single bracket chain computes the glued chain at both endpoints (Fin). -/
private theorem consecChainFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) (i : Fin ψ.n) :
    ∃ k l : Fin r,
      gluedChainFin N env ψ hconj hr i.castSucc = chainOfFin N env ψ hconj k l i.castSucc ∧
      gluedChainFin N env ψ hconj hr i.succ = chainOfFin N env ψ hconj k l i.succ := by
  refine ⟨idxOfFin ψ hr (loPosFin ψ hr i.castSucc), idxOfFin ψ hr (hiPosFin ψ hr i.succ), ?_, ?_⟩
  · unfold gluedChainFin
    by_cases hq : i.castSucc ∈ pinnedPositionsFin ψ
    · rw [loPosFin_of_mem hr hq,
        chainOfFin_at_pin_left N env ψ hconj hr hq (idxOfFin ψ hr (hiPosFin ψ hr i.castSucc)),
        chainOfFin_at_pin_left N env ψ hconj hr hq (idxOfFin ψ hr (hiPosFin ψ hr i.succ))]
    · rw [hiPosFin_castSucc_eq_succ hr hq]
  · unfold gluedChainFin
    by_cases hq' : i.succ ∈ pinnedPositionsFin ψ
    · rw [hiPosFin_of_mem hr hq',
        chainOfFin_at_pin_right N env ψ hconj hr hq' (idxOfFin ψ hr (loPosFin ψ hr i.succ)),
        chainOfFin_at_pin_right N env ψ hconj hr hq' (idxOfFin ψ hr (loPosFin ψ hr i.castSucc))]
    · rw [loPosFin_succ_eq_castSucc hr hq']

private theorem gluedChainFin_strictMono {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) : StrictMono (gluedChainFin N env ψ hconj hr) := by
  rw [Fin.strictMono_iff_lt_succ]
  intro i
  obtain ⟨k, l, hq, hq'⟩ := consecChainFin N env ψ hconj hr i
  rw [hq, hq']
  exact (chainOfFin_spec N env ψ hconj k l).1 Fin.castSucc_lt_succ

private theorem gluedChainFin_between {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) (i : Fin ψ.n) (y : N.carrier)
    (h1 : gluedChainFin N env ψ hconj hr i.castSucc < y)
    (h2 : y < gluedChainFin N env ψ hconj hr i.succ) :
    intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y := by
  obtain ⟨k, l, hq, hq'⟩ := consecChainFin N env ψ hconj hr i
  rw [hq] at h1
  rw [hq'] at h2
  exact (chainOfFin_spec N env ψ hconj k l).2.2.2.2.2.1 i y h1 h2

private theorem gluedChainFin_pointType {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) (j : Fin (ψ.n + 1)) :
    partialHolds N (ψ.pointType j) (gluedChainFin N env ψ hconj hr j) := by
  unfold gluedChainFin
  exact (chainOfFin_spec N env ψ hconj _ _).2.2.2.1 j

private theorem gluedChainFin_before {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) (y : N.carrier) (hy : y < gluedChainFin N env ψ hconj hr 0) :
    intervalHoldsFin N (ψ.intervalType 0) y := by
  unfold gluedChainFin at hy
  exact (chainOfFin_spec N env ψ hconj _ _).2.2.2.2.1 y hy

private theorem gluedChainFin_after {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (hconj : conjSatFin N env (pairwiseProjectionsFin ψ))
    (hr : 0 < r) (y : N.carrier) (hy : gluedChainFin N env ψ hconj hr (Fin.last ψ.n) < y) :
    intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y := by
  unfold gluedChainFin at hy
  exact (chainOfFin_spec N env ψ hconj _ _).2.2.2.2.2.2 y hy

/-- Lemma 3.2(2), backward direction (general `r`), Fin-variant of `augTarget_backward`:
glue the pairwise-projection chains into one global witness chain along the pinned
positions. -/
theorem augTargetFin_backward {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r)
    (h : augConjSatFin N env (augTargetFin ψ)) : efSatFin N env ψ := by
  rcases Nat.eq_zero_or_pos r with hr0 | hr
  · subst hr0
    exact augTargetFin_backward_zero N env ψ h
  · obtain ⟨hconj, _hex⟩ := h
    have hconj' : conjSatFin N env (pairwiseProjectionsFin ψ) := hconj
    rw [efSatFin_interval_iff]
    refine ⟨gluedChainFin N env ψ hconj' hr, gluedChainFin_strictMono N env ψ hconj' hr, ?_,
      fun j => gluedChainFin_pointType N env ψ hconj' hr j,
      fun y hy => gluedChainFin_before N env ψ hconj' hr y hy,
      fun i y h1 h2 => gluedChainFin_between N env ψ hconj' hr i y h1 h2,
      fun y hy => gluedChainFin_after N env ψ hconj' hr y hy⟩
    intro k
    exact (gluedChainFin_pin N env ψ hconj' hr k).symm

/-- Lemma 3.2(2) (p.4), full biconditional, Fin-variant of `augTarget_iff`: the load-bearing
≤2-free-variable arity cap on the per-formula representation. -/
theorem augTargetFin_iff {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) :
    efSatFin N env ψ ↔ augConjSatFin N env (augTargetFin ψ) :=
  ⟨augTargetFin_forward N env ψ, augTargetFin_backward N env ψ⟩

end Kamp

end Bimodal.Metalogic.WeakCanonical
