import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallFormula

/-!
# Partial interval types — `IntervalType := Finset UnaryType` (Rabinovich Definition 3.1, PDF p.4)

A quantifier-free 1-formula over the E[Σ] alphabet IS its finite set of satisfying complete
1-types (`UnaryType`). Rabinovich Definition 3.1 (PDF p.4) makes the interval predicates `βⱼ`
*quantifier-free formulas with one free variable*; the faithful representation of such a formula
is the **set of complete 1-types that satisfy it** — an admissible-completion set. This module
introduces that partial representation as ADDITIVE new declarations:

- `IntervalType sig F := Finset (UnaryType sig F)` — the admissible-completion set.
- `intervalHolds N S y` — the partial satisfaction relation `∃ τ ∈ S, unaryHolds N τ y`
  (a point `y` satisfies the qf-formula iff its complete type lies in `S`).
- `intervalConj = ∩` (conjunction of qf-formulas = intersection of admissible completions,
  Lemma 3.2(1)/3.4 (∧), p.4-5), `intervalBot = ∅` (the unsatisfiable formula ⊥, forcing the slot
  empty — vacuously satisfied), `intervalTop = univ` (the trivially-true formula ⊤).
- `ofComplete τ := {τ}` — the embedding of a complete 1-type as the singleton admissible set,
  with `intervalHolds N {τ} y ↔ unaryHolds N τ y`, the compatibility bridge every migration phase
  routes through.
- The downstream algebra: monotonicity in `S`, the `∩` split, and the `∅`/forced-empty vacuity
  lever `intervalHolds N ∅ y ↔ False`.

This module touches no existing field or consumer, so the build stays green trivially; it is
imported by nothing yet. The stored `ExistsForallFormula.intervalType` field remains complete
`UnaryType` (widened to `IntervalType` only in the widen-last field-flip phase). Point types stay
complete `UnaryType`; only interval types become partial `Finset UnaryType`.

Feasibility rests on the landed `Fintype`/`DecidableEq (NormalForm sig k n)` instances
(`NormalForm.lean`): they give `Finset (UnaryType sig F)`, its `∩`, `univ`, and a decidable
bounded search `∃ τ ∈ S` at each point.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 3.1 (p.4), Lemma 3.2(1)/3.4 (p.4-5),
  Proposition 3.5 (p.5). Cited by PDF page; the companion markdown transcription is corrupt.
- `ExistsForallFormula.lean`: `UnaryType`, `unaryHolds`, `unaryHolds_iff`.
- `NormalForm.lean`: the `Fintype`/`DecidableEq` instances on `NormalForm`.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

/-! ## 1. The partial interval type and its satisfaction relation

`IntervalType` (the finite admissible-completion set `Finset (UnaryType sig F)`) and its partial
satisfaction relation `intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y` are defined in
`ExistsForallFormula.lean` (the `ExistsForallFormula.intervalType` field and `efSat` reference
them, and this module imports that one). This module builds the interval-type algebra
(`∩`, `∅`, `univ`, `ofComplete`) and the compatibility bridge on top of them. -/

/-! ## 2. The interval-type algebra: `∩`, `∅`, `univ`, and the singleton embedding -/

/-- Conjunction of interval formulas = intersection of their admissible-completion sets
(Lemma 3.2(1)/3.4 (∧), p.4-5). A point satisfies `S₁ ∩ S₂` iff a single completion admissible to
both is realized there. -/
def intervalConj {sig : MonadicSignature} {F : Finset Formula}
    (S₁ S₂ : IntervalType sig F) : IntervalType sig F :=
  S₁ ∩ S₂

/-- The unsatisfiable interval formula ⊥ = the empty admissible set. A slot carrying `intervalBot`
is **forced empty**: no point satisfies it (`intervalHolds N ∅ y ↔ False`), so the slot is
vacuously satisfied precisely when the open interval it labels contains no points. -/
def intervalBot (sig : MonadicSignature) (F : Finset Formula) : IntervalType sig F :=
  (∅ : Finset (UnaryType sig F))

/-- The trivially-true interval formula ⊤ = every complete type is admissible = `univ`. -/
def intervalTop (sig : MonadicSignature) (F : Finset Formula) : IntervalType sig F :=
  (Finset.univ : Finset (UnaryType sig F))

/-- Embed a complete 1-type as the singleton admissible-completion set. This is the compatibility
map: `intervalHolds N (ofComplete τ) y ↔ unaryHolds N τ y` (proved below), so a complete-typed
clause and its partial-typed image are propositionally equal. -/
def ofComplete {sig : MonadicSignature} {F : Finset Formula}
    (τ : UnaryType sig F) : IntervalType sig F :=
  {τ}

/-! ## 3. The compatibility bridge and the basic algebra used downstream -/

/-- **Compatibility bridge.** Satisfying the singleton image `ofComplete τ` is exactly realizing
the complete type `τ`. Every migration phase rewrites a landed `unaryHolds N (ψ.intervalType t) y`
clause to `intervalHolds N (ofComplete (ψ.intervalType t)) y` through this equivalence. -/
theorem intervalHolds_ofComplete_iff {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (τ : UnaryType sig F) (y : N.carrier) :
    intervalHolds N (ofComplete τ) y ↔ unaryHolds N τ y := by
  simp only [intervalHolds, ofComplete, Finset.mem_singleton, exists_eq_left]

/-- **Forced-empty / vacuity lever.** No point satisfies the empty admissible set: the ⊥ interval
formula is unsatisfiable. This is the lever a mismatched merged slot uses — an empty `S₁ ∩ S₂` is
satisfied only vacuously (when its open interval has no points). -/
theorem intervalHolds_bot {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (y : N.carrier) :
    intervalHolds N (intervalBot sig F) y ↔ False := by
  simp only [intervalHolds, intervalBot, Finset.notMem_empty, false_and, exists_false]

/-- Satisfaction is **monotone** in the admissible set: enlarging the set of admissible completions
can only make satisfaction easier. -/
theorem intervalHolds_mono {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) {S₁ S₂ : IntervalType sig F} (h : S₁ ⊆ S₂)
    {y : N.carrier} (hS : intervalHolds N S₁ y) : intervalHolds N S₂ y := by
  obtain ⟨τ, hτ, hy⟩ := hS
  exact ⟨τ, h hτ, hy⟩

/-- Unfolding the intersection: satisfying `S₁ ∩ S₂` at `y` is realizing a single completion
admissible to **both** sets. -/
theorem intervalHolds_inter_iff {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (S₁ S₂ : IntervalType sig F) (y : N.carrier) :
    intervalHolds N (intervalConj S₁ S₂) y ↔ ∃ τ, (τ ∈ S₁ ∧ τ ∈ S₂) ∧ unaryHolds N τ y := by
  simp only [intervalHolds, intervalConj, Finset.mem_inter]

/-- The intersection projects to its left factor: `intervalHolds (S₁ ∩ S₂) → intervalHolds S₁`.
Used in the backward direction of `conjInterleave_iff` to recover a single chain's interval
clause from the merged one. -/
theorem intervalHolds_inter_left {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) {S₁ S₂ : IntervalType sig F} {y : N.carrier}
    (h : intervalHolds N (intervalConj S₁ S₂) y) : intervalHolds N S₁ y :=
  intervalHolds_mono N Finset.inter_subset_left h

/-- The intersection projects to its right factor: `intervalHolds (S₁ ∩ S₂) → intervalHolds S₂`. -/
theorem intervalHolds_inter_right {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) {S₁ S₂ : IntervalType sig F} {y : N.carrier}
    (h : intervalHolds N (intervalConj S₁ S₂) y) : intervalHolds N S₂ y :=
  intervalHolds_mono N Finset.inter_subset_right h

/-! ## 4. The `efSat` interval-clause accessor (widen-last: identity on the genuine field)

After the widen-last field flip, `ExistsForallFormula.intervalType` is genuinely
`Fin (n+2) → IntervalType`, so the `intervalSet` accessor is the identity on the field and
`efSat`'s three interval clauses are already stated on the partial satisfaction relation
`intervalHolds`. The accessor and `efSat_interval_iff` are retained (as an identity / reflexivity)
so the Phase 4-7 consumer migrations keep compiling verbatim.

Faithfulness: Rabinovich Def 3.1 (p.4) — the interval predicate `βⱼ` is a quantifier-free
1-formula whose admissible-completion set is the genuine partial interval type stored in the
field. -/

/-- The partial interval accessor: after the widen-last flip this is the identity on the stored
genuine `IntervalType` field. Retained so the Phase 4-7 consumer migrations (which route every
`efSat` interval clause through `ψ.intervalSet`) keep compiling verbatim. -/
def ExistsForallFormula.intervalSet {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (t : Fin (ψ.n + 2)) : IntervalType sig F :=
  ψ.intervalType t

/-- **Full `efSat` characterization through the partial satisfaction relation.** With the genuine
partial field, `efSat`'s three interval clauses are already `intervalHolds N (ψ.intervalSet ·)`
(the accessor is the identity), so this is reflexivity; it is retained verbatim so the Phase 4-7
consumer migrations keep compiling. -/
theorem efSat_interval_iff {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) :
    efSat N env ψ ↔
      ∃ x : Fin (ψ.n + 1) → N.carrier,
        StrictMono x ∧
        (∀ k : Fin r, env k = x (ψ.pin k)) ∧
        (∀ j : Fin (ψ.n + 1), unaryHolds N (ψ.pointType j) (x j)) ∧
        (∀ y : N.carrier, y < x 0 → intervalHolds N (ψ.intervalSet 0) y) ∧
        (∀ (i : Fin ψ.n) (y : N.carrier),
            x i.castSucc < y → y < x i.succ →
              intervalHolds N (ψ.intervalSet i.succ.castSucc) y) ∧
        (∀ y : N.carrier, x (Fin.last ψ.n) < y →
            intervalHolds N (ψ.intervalSet (Fin.last (ψ.n + 1))) y) := by
  simp only [efSat, ExistsForallFormula.intervalSet]

end Bimodal.Metalogic.WeakCanonical
