/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Archimedean.Real.Basic
import FormalSystem.Metalogic.WeakCanonical.PriorDefs

/-!
# Dense Prior Structure Semantic Hypotheses

Defines `SemanticPriorU` and `SemanticPriorS` — the semantic reading of Reynolds' **Prior-U** and
**Prior-S** axioms — together with the witnesses that separate them from the *integer* hypotheses
`SemanticPriorUZ` / `SemanticPriorSZ` of the sibling module `PriorDefs.lean`.

## The axioms, verbatim

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
printed p.168 (PDF page 4; the printed page was re-verified against the PDF while this module was
written):

```
Prior-U:   U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p),p)
Prior-S:   S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p),p)
```

and, printed p.176: *"Call a linear temporal structure a Prior structure if it satisfies all
substitution instances of Prior-U and Prior-S. It is easy to see that then there are no definable
gaps. Note that this result does not hold for the original Prior axioms in the language of `F` and
`P`."*

The object-level axioms already exist in this tree as `Axiom.prior_U_gap`
(`ProofSystem/Axioms.lean:377`) and `Axiom.prior_S_gap` (`:387`), each of which carries an explicit
"THIS IS NOT `prior_UZ`/`prior_SZ`" caveat. `SemanticPriorU` / `SemanticPriorS` below are the
semantic side of exactly those two axioms, read at an `OrderedMonadicStructure` in the same idiom
`PriorDefs.lean` uses for the integer pair.

Unfolding the temporal operators with this tree's `TemporalTruth` (`Table.lean:188`):

* `U(A,B)(t)` is `∃ s > t, A(s) ∧ ∀ r ∈ (t,s), B(r)` (Burgess convention: first argument is the
  event, second the guard);
* `U(⊤,p)(t)` is therefore *"`p` holds throughout some initial stretch above `t`"*;
* `F¬p(t)` is *"`¬p` somewhere above `t`"*;
* `K⁺(A)(s)` is `kplus` (`Kamp/PriorINF.lean:86`): `¬A(s) ∧ ∀ u > s, ∃ r ∈ (s,u), A(r)`, so
  `K⁺(¬p)(s)` is `p(s) ∧ ∀ u > s, ∃ r ∈ (s,u), ¬p(r)`.

The definitions below carry that unfolding literally, with the object-level negation read as
metalevel negation (`TemporalTruth` interprets `Formula.neg` classically, so the two agree —
`temporal_truth_neg`, `Kamp/Translation.lean:47`). Reading the negations metalevel keeps this
module's imports at `PriorDefs.lean` and avoids an edge into the `Kamp/` subtree.

## What this carrier EXCLUDES (Rule 6)

`SemanticPriorU` does **not** imply `SemanticPriorUZ`, and on a densely ordered flow it cannot:

* `semanticPriorUZ_fails_of_interval_witness` proves that on **any** densely ordered flow,
  `SemanticPriorUZ` fails as soon as a single formula holds throughout one nonempty open interval.
  `SemanticPriorUZ` demands a *first* occurrence of `ψ` above `t`, and a first occurrence is
  incompatible with `ψ` holding on an open right-neighbourhood — the generic situation on a dense
  flow. This is the machine-checked form of the vacuity finding that makes the integer hypotheses
  the wrong ones here.
* `semanticPriorU_not_implies_semanticPriorUZ` exhibits one structure — the real line with a single
  predicate true exactly on the open right-ray `(0,∞)` — satisfying `SemanticPriorU` **and**
  `SemanticPriorS` while refuting `SemanticPriorUZ`.

Consequently every declaration pinned at `SemanticPriorUZ` / `SemanticPriorSZ` (among them
`uSExpressivelyCompleteOverPrior`, `prior_hasAttainedINF`, `prior_hasDedekindINF`) is unavailable
at a dense flow, and the dense siblings must be built beside them rather than by reuse.

## Non-vacuity

* `semanticPriorU_of_flowGLB` / `semanticPriorS_of_flowLUB`: **every** Dedekind-complete flow is a
  Prior structure in this sense, for every interpretation and every formula. Reynolds asserts this
  much at printed p.168 (*"It is clear that all these axioms are valid over the reals"*) and p.169
  (*"The axioms are valid in structures over the reals because there are no gaps at all so no
  definable ones"*); he gives no argument, so the greatest-lower-bound derivation here is original
  glue rather than a transcription.
* `realFlowStructure` instantiates that at `ℝ` with an arbitrary predicate, and
  `denseRayFlow` / `denseWindowFlow` are the two concrete witnesses: a predicate that is neither
  empty nor the whole carrier in each case, densely ordered carrier, and — for the window — the
  Prior-U antecedent actually satisfied (`densePriorU_antecedent_reachable`), so the implication is
  not discharged vacuously.

Dedekind completeness of the flow is threaded as an explicit `Prop` (`FlowGLB` / `FlowLUB`) rather
than as a typeclass, matching the treatment of the least-upper-bound property in
`Semantics/Validity.lean`'s `ValidDedekindDense` and `real_lub_of_bddAbove`
(`BXCanonical/CompletenessDedekind.lean:127`).

Completeness of the flow is a *sufficient* condition here, not a necessary one: the countable dense
Prior structures this development ultimately consumes are Prior structures because the axioms are
valid in the canonical model (Reynolds §4 Corollary 1), not because their flow is complete.

## References

- Reynolds 1992, Prior-U / Prior-S, printed p.168; the Prior-structure definition, printed p.176
- Sibling integer hypotheses: `PriorDefs.lean` (`SemanticPriorUZ`, `SemanticPriorSZ`)
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax

/-! ## The dense Prior hypotheses -/

/-- **Semantic Prior-U** — Reynolds 1992, printed p.168: `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p),p)`, at
every point and every formula.

Read out: if `p` holds throughout some initial stretch above `t`, and `¬p` holds somewhere above
`t`, then there is `s > t` with `p` throughout `(t,s)` such that at `s` either `¬p` holds, or `p`
holds and `¬p` holds arbitrarily soon after `s` (the second disjunct is `K⁺(¬p)(s)`, i.e. `kplus`
of `¬p`, `Kamp/PriorINF.lean:86`).

This is the semantic side of `Axiom.prior_U_gap` (`ProofSystem/Axioms.lean:377`). It is **not**
`SemanticPriorUZ` (`PriorDefs.lean:28`) and does not imply it — see
`semanticPriorU_not_implies_semanticPriorUZ`. `SemanticPriorUZ` asks for a *first* occurrence;
Prior-U asks only for a point at which `p` stops holding **or** at which `¬p` accumulates from
above, which is precisely the weakening that survives a dense flow. -/
abbrev SemanticPriorU {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (p : Formula),
    (∃ s : M.carrier, t < s ∧ ∀ r : M.carrier, t < r → r < s → TemporalTruth M atomMap r p) →
    (∃ u : M.carrier, t < u ∧ ¬ TemporalTruth M atomMap u p) →
    ∃ s : M.carrier, t < s ∧
      (∀ r : M.carrier, t < r → r < s → TemporalTruth M atomMap r p) ∧
      (¬ TemporalTruth M atomMap s p ∨
        (TemporalTruth M atomMap s p ∧
          ∀ u : M.carrier, s < u →
            ∃ r : M.carrier, s < r ∧ r < u ∧ ¬ TemporalTruth M atomMap r p))

/-- **Semantic Prior-S** — Reynolds 1992, printed p.168: `S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p),p)`, the
mirror of `SemanticPriorU` in the past direction, with `K⁻` (`kminus`, `Kamp/PriorINF.lean:98`) in
place of `K⁺`.

This is the semantic side of `Axiom.prior_S_gap` (`ProofSystem/Axioms.lean:387`), and stands to
`SemanticPriorSZ` (`PriorDefs.lean:39`) exactly as `SemanticPriorU` stands to `SemanticPriorUZ`. -/
abbrev SemanticPriorS {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (p : Formula),
    (∃ s : M.carrier, s < t ∧ ∀ r : M.carrier, s < r → r < t → TemporalTruth M atomMap r p) →
    (∃ u : M.carrier, u < t ∧ ¬ TemporalTruth M atomMap u p) →
    ∃ s : M.carrier, s < t ∧
      (∀ r : M.carrier, s < r → r < t → TemporalTruth M atomMap r p) ∧
      (¬ TemporalTruth M atomMap s p ∨
        (TemporalTruth M atomMap s p ∧
          ∀ u : M.carrier, u < s →
            ∃ r : M.carrier, u < r ∧ r < s ∧ ¬ TemporalTruth M atomMap r p))

/-! ## Flow completeness as an explicit hypothesis

Stated as a `Prop` on the structure's own order, in the idiom of `ValidDedekindDense`
(`Semantics/Validity.lean:255`) and `real_lub_of_bddAbove`
(`BXCanonical/CompletenessDedekind.lean:127`), so that no typeclass has to be transported along
`OrderedMonadicStructure.carrierOrder`. -/

/-- The flow of `M` has greatest lower bounds for nonempty bounded-below sets. -/
abbrev FlowGLB {sig : MonadicSignature} (M : OrderedMonadicStructure sig) : Prop :=
  ∀ A : Set M.carrier, A.Nonempty → BddBelow A → ∃ r : M.carrier, IsGLB A r

/-- The flow of `M` has least upper bounds for nonempty bounded-above sets. -/
abbrev FlowLUB {sig : MonadicSignature} (M : OrderedMonadicStructure sig) : Prop :=
  ∀ A : Set M.carrier, A.Nonempty → BddAbove A → ∃ r : M.carrier, IsLUB A r

/-! ## Every Dedekind-complete flow is a Prior structure

Reynolds, printed p.168: *"It is clear that all these axioms are valid over the reals"*, and
p.169: *"The axioms are valid in structures over the reals because there are no gaps at all so no
definable ones."* He gives no proof; the two theorems below supply one, and they are therefore
original glue on a sourced statement rather than transcriptions. -/

/-- On a flow with greatest lower bounds, `SemanticPriorU` holds for every interpretation and every
formula.

Proof: the infimum `r` of the set `A = {x > t | ¬p(x)}` is the required point. `A` is nonempty by
the `F¬p` conjunct and bounded below by `t`; the `U(⊤,p)` conjunct makes the stretch's right
endpoint a lower bound of `A`, so `r > t`. Every point of `(t,r)` is below the infimum, hence
outside `A`, hence satisfies `p`. At `r` itself either `¬p` holds — the left disjunct — or `p`
holds, in which case no point above `r` can bound `A` below, which is exactly `K⁺(¬p)(r)`.

No density, discreteness or attainment is used. -/
theorem semanticPriorU_of_flowGLB {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hglb : FlowGLB M) : SemanticPriorU M atomMap := by
  classical
  rintro t p ⟨s₀, hts₀, hstretch⟩ ⟨u, htu, hnu⟩
  set A : Set M.carrier := {x : M.carrier | t < x ∧ ¬ TemporalTruth M atomMap x p} with hAdef
  have hne : A.Nonempty := ⟨u, htu, hnu⟩
  have hbdd : BddBelow A := ⟨t, fun x hx => le_of_lt hx.1⟩
  obtain ⟨r, hlb, hgreatest⟩ := hglb A hne hbdd
  -- The stretch's right endpoint is a lower bound of `A`, so `t < s₀ ≤ r`.
  have hs₀lb : s₀ ∈ lowerBounds A := by
    intro x hx
    by_contra hlt
    replace hlt := not_le.mp hlt
    exact hx.2 (hstretch x hx.1 hlt)
  have htr : t < r := lt_of_lt_of_le hts₀ (hgreatest hs₀lb)
  refine ⟨r, htr, ?_, ?_⟩
  · -- `p` holds throughout `(t,r)`: such points are strictly below the greatest lower bound.
    intro y hty hyr
    by_contra hy
    exact absurd (hlb (show y ∈ A from ⟨hty, hy⟩)) (not_le.mpr hyr)
  · by_cases hpr : TemporalTruth M atomMap r p
    · -- `p` holds at `r`, so `r ∉ A` and `A` accumulates at `r` from above: this is `K⁺(¬p)(r)`.
      refine Or.inr ⟨hpr, ?_⟩
      intro v hrv
      by_contra hno
      push Not at hno
      have hvlb : v ∈ lowerBounds A := by
        intro x hx
        by_contra hxv
        replace hxv := not_le.mp hxv
        have hrx : r ≤ x := hlb hx
        have hrx' : r < x := lt_of_le_of_ne hrx (by rintro rfl; exact hx.2 hpr)
        exact absurd hx.2 (not_not.mpr (hno x hrx' hxv))
      exact absurd (hgreatest hvlb) (not_le.mpr hrv)
    · exact Or.inl hpr

/-- On a flow with least upper bounds, `SemanticPriorS` holds for every interpretation and every
formula: the past-directed mirror of `semanticPriorU_of_flowGLB`, with the supremum of
`{x < t | ¬p(x)}` in place of the infimum of `{x > t | ¬p(x)}` and `K⁻` in place of `K⁺`. -/
theorem semanticPriorS_of_flowLUB {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hlub : FlowLUB M) : SemanticPriorS M atomMap := by
  classical
  rintro t p ⟨s₀, hs₀t, hstretch⟩ ⟨u, hut, hnu⟩
  set A : Set M.carrier := {x : M.carrier | x < t ∧ ¬ TemporalTruth M atomMap x p} with hAdef
  have hne : A.Nonempty := ⟨u, hut, hnu⟩
  have hbdd : BddAbove A := ⟨t, fun x hx => le_of_lt hx.1⟩
  obtain ⟨r, hub, hleast⟩ := hlub A hne hbdd
  have hs₀ub : s₀ ∈ upperBounds A := by
    intro x hx
    by_contra hlt
    replace hlt := not_le.mp hlt
    exact hx.2 (hstretch x hlt hx.1)
  have hrt : r < t := lt_of_le_of_lt (hleast hs₀ub) hs₀t
  refine ⟨r, hrt, ?_, ?_⟩
  · intro y hry hyt
    by_contra hy
    exact absurd (hub (show y ∈ A from ⟨hyt, hy⟩)) (not_le.mpr hry)
  · by_cases hpr : TemporalTruth M atomMap r p
    · refine Or.inr ⟨hpr, ?_⟩
      intro v hvr
      by_contra hno
      push Not at hno
      have hvub : v ∈ upperBounds A := by
        intro x hx
        by_contra hxv
        replace hxv := not_le.mp hxv
        have hxr : x ≤ r := hub hx
        have hxr' : x < r := lt_of_le_of_ne hxr (by rintro rfl; exact hx.2 hpr)
        exact absurd hx.2 (not_not.mpr (hno x hxv hxr'))
      exact absurd (hleast hvub) (not_le.mpr hvr)
    · exact Or.inl hpr

/-! ## The exclusion lemma: `SemanticPriorUZ` cannot hold on a dense flow -/

/-- **On a densely ordered flow, `SemanticPriorUZ` fails as soon as any formula holds throughout a
nonempty open interval.**

`SemanticPriorUZ` (`PriorDefs.lean:28`) demands a *first* occurrence of `ψ` above `t`, with `ψ`
false everywhere strictly between. If `ψ` holds throughout `(t,s₁)` then density produces a point
of `(t,s)` below any candidate first occurrence `s` at which `ψ` holds anyway, and the demand is
contradictory.

This is the exclusion lemma required of a new hypothesis by the anti-vacuity discipline: it names
exactly which structures the *integer* hypothesis admits (those in which no formula holds on an
open interval — in particular the discrete ones, where the interval below the successor is empty)
and which it forbids. -/
theorem semanticPriorUZ_fails_of_interval_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hdense : ∀ x y : M.carrier, x < y → ∃ z : M.carrier, x < z ∧ z < y)
    (t s₁ : M.carrier) (ψ : Formula) (hts₁ : t < s₁)
    (hψ : ∀ r : M.carrier, t < r → r < s₁ → TemporalTruth M atomMap r ψ) :
    ¬ SemanticPriorUZ M atomMap := by
  intro hUZ
  obtain ⟨m, htm, hms₁⟩ := hdense t s₁ hts₁
  obtain ⟨s, hts, _hψs, hnone⟩ := hUZ t ψ ⟨m, htm, hψ m htm hms₁⟩
  -- Any point of `(t, min s s₁)` both satisfies `ψ` (by `hψ`) and refutes it (by `hnone`).
  rcases le_total s s₁ with hss₁ | hs₁s
  · obtain ⟨z, htz, hzs⟩ := hdense t s hts
    exact (hnone z htz hzs) (hψ z htz (lt_of_lt_of_le hzs hss₁))
  · obtain ⟨z, htz, hzs₁⟩ := hdense t s₁ hts₁
    exact (hnone z htz (lt_of_lt_of_le hzs₁ hs₁s)) (hψ z htz hzs₁)

/-! ## The witnesses

A one-predicate signature over the real line. The carrier is densely ordered and Dedekind
complete, so `semanticPriorU_of_flowGLB` and `semanticPriorS_of_flowLUB` apply to every choice of
predicate. -/

/-- A signature with exactly one unary predicate symbol. -/
def densePriorSig : MonadicSignature := ⟨Unit⟩

/-- The real line carrying a single predicate `S`, as an `OrderedMonadicStructure`. -/
noncomputable abbrev realFlowStructure (S : ℝ → Prop) :
    OrderedMonadicStructure densePriorSig where
  carrier := ℝ
  interp := fun _ x => S x
  carrierOrder := inferInstance

/-- The only available atom map into `densePriorSig`: every formula's atomic and box constituents
are interpreted by the single predicate. -/
def densePriorAtomMap : Formula → densePriorSig.preds := fun _ => ()

/-- The real flow has greatest lower bounds (Mathlib's `ConditionallyCompleteLinearOrder ℝ`). -/
theorem realFlowStructure_flowGLB (S : ℝ → Prop) : FlowGLB (realFlowStructure S) :=
  fun _ hne hbdd => ⟨_, isGLB_csInf hne hbdd⟩

/-- The real flow has least upper bounds (Mathlib's `ConditionallyCompleteLinearOrder ℝ`);
the same fact as `real_lub_of_bddAbove` (`BXCanonical/CompletenessDedekind.lean:127`). -/
theorem realFlowStructure_flowLUB (S : ℝ → Prop) : FlowLUB (realFlowStructure S) :=
  fun _ hne hbdd => ⟨_, isLUB_csSup hne hbdd⟩

/-- The real flow is densely ordered. -/
theorem realFlowStructure_dense (S : ℝ → Prop) :
    ∀ x y : (realFlowStructure S).carrier, x < y → ∃ z : (realFlowStructure S).carrier,
      x < z ∧ z < y :=
  fun x y h => ⟨(x + y) / 2, by constructor <;> linarith⟩

/-- Truth of an atom in `realFlowStructure S` is membership in `S`. -/
@[simp] theorem temporalTruth_realFlowStructure_atom (S : ℝ → Prop) (a : Atom)
    (x : (realFlowStructure S).carrier) :
    TemporalTruth (realFlowStructure S) densePriorAtomMap x (Formula.atom a) ↔ S x := Iff.rfl

/-- **The negative witness**: the real line with one predicate true exactly on the open right-ray
`(0,∞)`. Densely ordered, Dedekind complete, and the predicate is neither empty nor the whole
carrier. -/
noncomputable abbrev denseRayFlow : OrderedMonadicStructure densePriorSig :=
  realFlowStructure (fun x => 0 < x)

/-- **The contentful witness**: the real line with one predicate true exactly on the open interval
`(0,1)`. Used to show the Prior-U antecedent is satisfiable, so that `SemanticPriorU` is not
discharged vacuously on these structures. -/
noncomputable abbrev denseWindowFlow : OrderedMonadicStructure densePriorSig :=
  realFlowStructure (fun x => 0 < x ∧ x < 1)

/-- The ray predicate is neither empty nor the whole carrier. -/
theorem denseRayFlow_pred_nontrivial :
    (∃ x : denseRayFlow.carrier,
        TemporalTruth denseRayFlow densePriorAtomMap x (Formula.atom (Atom.mkBase "p"))) ∧
      (∃ x : denseRayFlow.carrier,
        ¬ TemporalTruth denseRayFlow densePriorAtomMap x (Formula.atom (Atom.mkBase "p"))) :=
  ⟨⟨1, by norm_num⟩, ⟨-1, by norm_num⟩⟩

/-- **Anti-vacuity gate, part 2 (positive witness)** — the dense ray satisfies `SemanticPriorU`. -/
theorem semanticPriorU_of_dense_ray : SemanticPriorU denseRayFlow densePriorAtomMap :=
  semanticPriorU_of_flowGLB _ _ (realFlowStructure_flowGLB _)

/-- **Anti-vacuity gate, part 2 (positive witness)** — the dense ray satisfies `SemanticPriorS`. -/
theorem semanticPriorS_of_dense_ray : SemanticPriorS denseRayFlow densePriorAtomMap :=
  semanticPriorS_of_flowLUB _ _ (realFlowStructure_flowLUB _)

/-- **Anti-vacuity gate, part 1 (negative witness)** — `SemanticPriorUZ` is refuted on the dense
ray. The predicate holds throughout the open interval `(0,1)`, so the integer hypothesis' demand
for a first occurrence above `0` is contradictory: every occurrence above `0` has a further
occurrence strictly below it, so none is first. -/
theorem semanticPriorUZ_fails_on_dense :
    ¬ SemanticPriorUZ denseRayFlow densePriorAtomMap :=
  semanticPriorUZ_fails_of_interval_witness denseRayFlow densePriorAtomMap
    (realFlowStructure_dense _) 0 1 (Formula.atom (Atom.mkBase "p")) (by norm_num)
    (fun _ h _ => by simpa using h)

/-- **Rule 6, machine-checked**: `SemanticPriorU` together with `SemanticPriorS` does **not** imply
`SemanticPriorUZ`. The dense ray satisfies both dense hypotheses and refutes the integer one.

Consequence for this development: every declaration pinned at `SemanticPriorUZ` /
`SemanticPriorSZ` — `uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean:357`),
`prior_hasAttainedINF` (`Kamp/PriorINF.lean:230`), `prior_hasDedekindINF`
(`Kamp/DedekindINF.lean:232`) and their consumers — has no dense instance obtained by reuse. -/
theorem semanticPriorU_not_implies_semanticPriorUZ :
    ∃ (M : OrderedMonadicStructure densePriorSig) (atomMap : Formula → densePriorSig.preds),
      SemanticPriorU M atomMap ∧ SemanticPriorS M atomMap ∧ ¬ SemanticPriorUZ M atomMap :=
  ⟨denseRayFlow, densePriorAtomMap, semanticPriorU_of_dense_ray, semanticPriorS_of_dense_ray,
    semanticPriorUZ_fails_on_dense⟩

/-- The window flow satisfies `SemanticPriorU`. -/
theorem semanticPriorU_of_dense_window : SemanticPriorU denseWindowFlow densePriorAtomMap :=
  semanticPriorU_of_flowGLB _ _ (realFlowStructure_flowGLB _)

/-- The window flow satisfies `SemanticPriorS`. -/
theorem semanticPriorS_of_dense_window : SemanticPriorS denseWindowFlow densePriorAtomMap :=
  semanticPriorS_of_flowLUB _ _ (realFlowStructure_flowLUB _)

/-- **The Prior-U antecedent is reachable**, so `SemanticPriorU` is not satisfied vacuously: on the
window flow, at the point `1/2` and the atom, `p` holds throughout `(1/2,1)` and `¬p` holds at `2`.

The conclusion `SemanticPriorU` supplies there is genuinely the `K⁺`-free left disjunct at the
right endpoint `1`: `p` holds on `(1/2,1)` and fails at `1`. -/
theorem densePriorU_antecedent_reachable :
    ∃ (t : denseWindowFlow.carrier) (p : Formula),
      (∃ s : denseWindowFlow.carrier, t < s ∧
        ∀ r : denseWindowFlow.carrier, t < r → r < s →
          TemporalTruth denseWindowFlow densePriorAtomMap r p) ∧
      (∃ u : denseWindowFlow.carrier, t < u ∧
        ¬ TemporalTruth denseWindowFlow densePriorAtomMap u p) := by
  refine ⟨1/2, Formula.atom (Atom.mkBase "p"), ⟨1, by norm_num, ?_⟩, ⟨2, by norm_num, ?_⟩⟩
  · intro r hr hr1
    simp only [temporalTruth_realFlowStructure_atom]
    constructor <;> [linarith; linarith]
  · simp only [temporalTruth_realFlowStructure_atom]
    push Not
    intro _
    norm_num

end FormalSystem.Metalogic.WeakCanonical
