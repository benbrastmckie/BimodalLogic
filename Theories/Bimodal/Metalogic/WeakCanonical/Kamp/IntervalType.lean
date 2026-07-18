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

/-! ## 1. The partial interval type and its satisfaction relation -/

/-- A **partial** (admissible-completion) interval type over the E[Σ] alphabet: the finite set of
complete 1-types (`UnaryType`) that satisfy the underlying quantifier-free interval formula `β`
(Rabinovich Def 3.1, p.4). A complete `UnaryType` is embedded as the singleton set via
`ofComplete`; the empty set is the unsatisfiable ⊥ (forced-empty slot). -/
abbrev IntervalType (sig : MonadicSignature) (F : Finset Formula) : Type :=
  Finset (UnaryType sig F)

/-- A point `y` **satisfies** the partial interval type `S`: its complete type is one of the
admissible completions in `S`, i.e. some `τ ∈ S` is realized at `y`. This is the partial
satisfaction relation the migration routes every interval clause through. The search `∃ τ ∈ S` is
a bounded (finite) existential over the `Finset` `S`. -/
def intervalHolds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (S : IntervalType sig F) (y : N.carrier) : Prop :=
  ∃ τ ∈ S, unaryHolds N τ y

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

/-! ## 4. The `efSat` interval-clause bridge (widen-last abstraction target)

Route `ExistsForallFormula.efSat`'s three interval clauses through `intervalHolds ∘ ofComplete`
without touching the stored complete-typed field. The stored `intervalType` field stays
`Fin (n+2) → UnaryType`; the derived `intervalSet` accessor lifts each slot to its singleton
admissible-completion set, and the bridge lemmas below let every downstream consumer rewrite a
landed `unaryHolds N (ψ.intervalType t) y` interval clause into the partial
`intervalHolds N (ψ.intervalSet t) y` form via a one-line rewrite. The field-type flip
(widen-last) then collapses `intervalSet` to the identity on a genuine `Finset` field with no
consumer proof change.

These declarations live here rather than in `ExistsForallFormula.lean` because `intervalHolds` /
`ofComplete` are defined in this module, which imports `ExistsForallFormula`; the reverse import
would be a cycle. This co-locates the `efSat`-level bridge with the point-level bridge
`intervalHolds_ofComplete_iff` it is built from.

Faithfulness: Rabinovich Def 3.1 (p.4) — the interval predicate `βⱼ` is a quantifier-free
1-formula, and a complete 1-type is the singleton admissible-completion set of the qf-formula it
satisfies (`ofComplete`). -/

/-- The derived partial interval accessor: interval slot `t`'s stored complete type, lifted to its
singleton admissible-completion set. Every `efSat` interval clause is routed through this accessor
(via the bridge lemmas below) so the stored field can be widened to a genuine `Finset` losslessly
in the widen-last field-flip. -/
def ExistsForallFormula.intervalSet {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) (t : Fin (ψ.n + 2)) : IntervalType sig F :=
  ofComplete (ψ.intervalType t)

/-- **Per-slot bridge.** Satisfying slot `t`'s derived singleton admissible set is exactly
realizing the stored complete type there. This is the one-line rewrite every consumer cluster
(the interval-clause migrations) uses to move a landed `unaryHolds` interval clause onto the
partial satisfaction relation. -/
theorem ExistsForallFormula.intervalSet_holds_iff {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat} (N : OrderedMonadicStructure (sigE sig F)) (ψ : ExistsForallFormula sig F r)
    (t : Fin (ψ.n + 2)) (y : N.carrier) :
    intervalHolds N (ψ.intervalSet t) y ↔ unaryHolds N (ψ.intervalType t) y := by
  simp only [ExistsForallFormula.intervalSet, intervalHolds_ofComplete_iff]

/-- Unfold accessor for the **before-`x₀`** interval clause (slot `0`): its partial form is the
landed complete-typed clause. -/
theorem ExistsForallFormula.intervalSet_below_iff {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat} (N : OrderedMonadicStructure (sigE sig F)) (ψ : ExistsForallFormula sig F r)
    (y : N.carrier) :
    intervalHolds N (ψ.intervalSet 0) y ↔ unaryHolds N (ψ.intervalType 0) y :=
  ψ.intervalSet_holds_iff N 0 y

/-- Unfold accessor for the **between-points** interval clause (slot `i.succ.castSucc`, the open
interval `(x_{i-1}, xᵢ)`): its partial form is the landed complete-typed clause. -/
theorem ExistsForallFormula.intervalSet_middle_iff {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat} (N : OrderedMonadicStructure (sigE sig F)) (ψ : ExistsForallFormula sig F r)
    (i : Fin ψ.n) (y : N.carrier) :
    intervalHolds N (ψ.intervalSet i.succ.castSucc) y ↔
      unaryHolds N (ψ.intervalType i.succ.castSucc) y :=
  ψ.intervalSet_holds_iff N i.succ.castSucc y

/-- Unfold accessor for the **after-`xₙ`** interval clause (slot `Fin.last (n+1)`): its partial
form is the landed complete-typed clause. -/
theorem ExistsForallFormula.intervalSet_above_iff {sig : MonadicSignature} {F : Finset Formula}
    {r : Nat} (N : OrderedMonadicStructure (sigE sig F)) (ψ : ExistsForallFormula sig F r)
    (y : N.carrier) :
    intervalHolds N (ψ.intervalSet (Fin.last (ψ.n + 1))) y ↔
      unaryHolds N (ψ.intervalType (Fin.last (ψ.n + 1))) y :=
  ψ.intervalSet_holds_iff N (Fin.last (ψ.n + 1)) y

/-- **Full `efSat` characterization through the partial satisfaction relation.** `efSat` is
propositionally equal to the same ordered-existential statement with each of its three interval
clauses expressed via `intervalHolds N (ψ.intervalSet ·)` instead of the landed
`unaryHolds N (ψ.intervalType ·)`. Because the bridge is per-slot propositional (not
definitional), a consumer rewrites through this lemma once and thereafter reasons entirely on the
partial relation; the widen-last field flip preserves this statement verbatim. -/
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
  simp only [efSat, ExistsForallFormula.intervalSet, intervalHolds_ofComplete_iff]

end Bimodal.Metalogic.WeakCanonical
