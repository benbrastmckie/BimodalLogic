/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Compose
import FormalSystem.Metalogic.Decidability.RaySummary.Trace
import FormalSystem.Metalogic.WeakCanonical.Transfer

/-!
# Transport of a family triple along the deletion of a constant run

`Compose.lean` makes the `k`-type of a constant block `ℓ^m` eventually periodic in `m`, with
the threshold and the period together bounded by the count `Nat.card (KType sig k)`
(`kTypeOf_listSeg_replicate_eventually_periodic_bounded`). That is a statement about ONE finite
block. A family triple of a bi-infinite colouring `c` (`InFamily`, `KTypeSummary/Family.lean`)
is a statement about a `SegmentFactorization` of `c` — a monotone covering cutting sequence
`W : ℤ → ℤ` whose segments carry the three types `(τneg, τzero, τpos)`. This module is the
bridge between the two: it says when the periodicity of a block lets a factorization of `c` be
re-cut into a factorization of the colouring `deleteRun c s p` obtained from `c` by deleting
the `p` positions `[s, s + p)`, with the same triple.

## The keystone

`segZ_const_of_kTypeOf_eq_replicate`: at depth `k ≥ 1`, a segment of the time axis whose
`k`-type is that of a NONEMPTY constant block `ℓ^j` is itself nonempty and reads `ℓ` at every
position. Two depth-`1` sentences transfer along the `k`-equivalence (`k_equiv_monotone` to depth
`1`, then `k_equiv_preserves_sentence`): `∃ x, ¬ x < x` carries nonemptiness, and for each
predicate `P` the sentence `∀ x, P x` (or `∀ x, ¬ P x`, as the letter dictates) carries
constancy. At depth `0` nothing of the sort holds — depth-`0` sentences cannot see a point — so
every statement that uses the keystone carries `(hk : 1 ≤ k)`.

## The surgery, and what it does NOT claim

`inFamily_of_shrink_run`: if a factorization `F` of `c` has a segment `[W z₀, W (z₀ + 1))`
containing a constant run `[s, s + j)` of letter `ℓ`, and `m₀ + p ≤ j` where `(m₀, p)` is a
threshold/period pair for `ℓ` (an explicit HYPOTHESIS `hper`, so the surgery is independent of
how the pair arises — `Compose.lean`'s theorem is plugged in only at the use site), then
`deleteRun c s p` has a factorization with the SAME triple: the cutting sequence is `W` up to
`z₀` and `W - p` beyond, the segments below `s` keep their letters, the segments above `s + p`
are translated, and the one segment holding the run loses `p` of its `ℓ`-positions — which the
periodicity and the congruence `kTypeOf_listSeg_append_congr` make invisible to its `k`-type.

The single-segment containment is a hypothesis, not a theorem: the "re-cut" case — a run met by
several short segments, none of which can absorb the `p` positions — is NOT handled here. The
honest general threshold for an unconditioned statement is `3 · (m₀ + p)` (at most three
segments meet a maximal run, so a run of that length has a piece of length `≥ m₀ + p` inside one
of them); it is not claimed, and no statement here reads `InFamily c ↔ InFamily c'`. Only the
shrink direction is landed. On fixture model A of the wired probe
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` the containment is a
theorem of the fixture, discharged there, and the corollary `familyTriples_subset_deleteRun`
is what that probe consumes.

## Decidability

`labels` (`Compose.lean`) needs a `DecidablePred` instance on the colouring, so every statement
about `labels` below carries `[∀ P, DecidablePred (c P)]`, and `deleteRun` inherits its instance
from `c`'s (`deleteRunDecidablePred`). Every statement whose conclusion mentions only `kTypeOf`,
`InFamily` or `familyTriples` is instance-free and discharges the instance by `classical` in its
proof, so a `Prop`-valued colouring such as a closure trace needs no instance to use the surgery.

## No complexity bound

None is claimed, upper or lower. `m₀ + p ≤ Nat.card (KType sig k)` is a COUNT of depth-`k`
types and nothing else — see `Compose.lean`'s "Eventual periodicity of constant blocks" section
for the disclaimer, quoted from `AnchorLayer.lean`.

## Main definitions and results

* `segZ_const_of_kTypeOf_eq_replicate` — the keystone: a segment with the `k`-type of a nonempty
  constant block is a nonempty constant block (`k ≥ 1`).

## References

* [W. Thomas, *Ehrenfeucht-Fraïssé games, the composition method, and the monadic theory of
  ordinal words*, 1997] for the composition method the congruence instantiates.
* [K. Doets, *Monadic Π¹₁-theories of Π¹₁-properties*, 1989] for Lemma 1.1, the `k`-type /
  sentence transfer the keystone runs on (`k_equiv_preserves_sentence`).
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature}

/-! ## Two depth-`1` sentences -/

/-- The depth-`1` sentence `∃ x, ¬ x < x`: true exactly on a nonempty carrier. -/
def exTop : MonadicSentence sig := .ex (.not (.lt 0 0))

/-- `exTop` reads nonemptiness. -/
theorem eval_exTop (M : OrderedMonadicStructure sig) :
    eval M Fin.elim0 (exTop (sig := sig)) ↔ Nonempty M.carrier := by
  simp only [exTop, eval, Fin.cons_zero, lt_self_iff_false, not_false_eq_true]
  exact exists_true_iff_nonempty

@[simp] theorem quantifierDepth_exTop : (exTop (sig := sig)).quantifierDepth = 1 := by
  simp [exTop, MonadicFormula.quantifierDepth]

/-- The depth-`1` sentence "every point reads `b` at `P`": `∀ x, P x` when `b = true`,
`∀ x, ¬ P x` when `b = false`. -/
def allAtom (P : sig.preds) (b : Bool) : MonadicSentence sig :=
  .all (bif b then .atom P 0 else .not (.atom P 0))

/-- `allAtom P b` reads constancy of `P` at the value `b`. -/
theorem eval_allAtom (M : OrderedMonadicStructure sig) (P : sig.preds) (b : Bool) :
    eval M Fin.elim0 (allAtom P b) ↔ ∀ x, (M.interp P x ↔ b = true) := by
  cases b <;> simp [allAtom, eval]

@[simp] theorem quantifierDepth_allAtom (P : sig.preds) (b : Bool) :
    (allAtom P b).quantifierDepth = 1 := by
  cases b <;> simp [allAtom, MonadicFormula.quantifierDepth]

/-! ## The keystone -/

/-- **A segment with the `k`-type of a nonempty constant block is a nonempty constant block**
(`k ≥ 1`). The `k`-equivalence is weakened to depth `1` (`k_equiv_monotone`), and the two
depth-`1` sentences `exTop` and `allAtom P (ℓ P)` are transferred from the block to the segment
(`k_equiv_preserves_sentence`): the block is nonempty, so the segment is (`a < b`); the block
reads `ℓ P` at every point for every `P`, so the segment does.

Paper: — (the formalization's own transfer device, Doets 1989 Lemma 1.1 applied to two fixed
depth-`1` sentences; the manuscript carries no counterpart) -/
theorem segZ_const_of_kTypeOf_eq_replicate [Finite sig.preds] {k : ℕ} (hk : 1 ≤ k)
    (c : sig.preds → ℤ → Prop) (a b : ℤ) (ℓ : sig.preds → Bool) {j : ℕ} (hj : 0 < j)
    (h : kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (listSeg (List.replicate j ℓ))) :
    a < b ∧ ∀ s, a ≤ s → s < b → ∀ P, (c P s ↔ ℓ P = true) := by
  have h1 : KEquiv sig 1 (segZ sig c a b) (listSeg (List.replicate j ℓ)) :=
    k_equiv_monotone sig hk h
  constructor
  · have := (k_equiv_preserves_sentence h1 exTop (by simp)).2
    rw [eval_exTop, eval_exTop] at this
    obtain ⟨⟨t, ht⟩⟩ := this ⟨⟨0, by simp; omega⟩⟩
    omega
  · intro s hs hsb P
    have := (k_equiv_preserves_sentence h1 (allAtom P (ℓ P)) (by simp)).2
    rw [eval_allAtom, eval_allAtom] at this
    have hall := this (by
      intro x
      obtain ⟨i, hi⟩ := x
      simp)
    exact hall ⟨s, hs, hsb⟩

end FormalSystem.Metalogic.WeakCanonical
