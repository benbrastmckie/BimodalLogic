/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.RealExtensionBundle

/-!
# The guard-accumulation invariant

**This construction has NO source in the corpus. It is original work.**

Every declaration in this module is stated and proved from first principles. No paper, textbook
or proof sketch in the literature contains this invariant, its payoff implication, or the
falsification check against the accumulating family. The only permitted citations are recorded
below, and each is an **ADAPTED-FROM** of a *neighbouring* discipline — never a transcription of
this argument:

* **ADAPTED-FROM: Burgess 1982 I §2.10, printed pp.372-373.** The fresh-point witness placement
  ("add a single point `y` lying after `x`", `y = x+1`, `z = (x+x')/2`) is the discipline whose
  *accumulation behaviour* this invariant constrains. Burgess places points; he never asks where
  the placements converge, and nothing in his §2.10 bounds it.
* **ADAPTED-FROM: Burgess 1984 §2.7, printed pp.109-110.** The A7a far-side witness placement
  runs the completion argument in the `F`/`G` fragment, where the gap witness is placed on the far
  side with no bound whatever and **no guard to carry**. The presence of a guard is exactly what
  makes the question below non-trivial, so this is an analogy and not a source.

The *statement being discharged*, `BFMCS.LimitGuardEventual`, does have a source and it is cited
where it lives: it is the failure of Reynolds' `γ⁺` at the guard, and Reynolds' definition of `γ⁺`
and of a left gap is Reynolds 1992, **printed p.175**. That citation covers the statement only.
Nothing about the *discharge* — that is, anything in this file — may be attributed to Reynolds or
to anyone else.

## The question

`BFMCS.LimitGuardEventual` says: whenever an `untl`/`snce` formula survives into the ultrafilter
limit at an **unselected** real `r`, its guard `ψ` is *eventually* true below `r`, not merely
cofinally. Its negation is exactly an accumulation phenomenon: the `¬ψ`-points of `ℚ` pile up at
`r` from below while the obligation stays live. This module names that phenomenon, forbids it, and
proves the prohibition sufficient.

## The chosen form, and why

The invariant is `NoGuardAccumulation D m G`:

> for every guard `ψ ∈ G` and every `φ`, no subset `S₀` of the `¬ψ`-points of `D` ascends to a gap
> of `D` while `untl φ ψ` (or `snce φ ψ`) remains cofinal in the approach to that gap.

Three choices are load-bearing and are recorded so that later work can be held to them.

**1. It is conditioned on the guard's own `untl`/`snce` obligation.** An unconditional invariant —
"every `ψ` in the closure is eventually true below every gap" — is **false**: formulas genuinely
oscillate, and a development that "proves" it has proved something wrong. The condition
`CofinalBelowGap` is the ℚ-level shadow of the antecedent of `BFMCS.LimitGuardEventual`, and it is
weak enough that the ultrafilter membership implies it (`cofinalBelowGap_of_mem_limitMCSBelow`),
which is what makes the payoff go through.

**2. It is stated with no reference to `ℝ`.** A gap is not "an irrational number" here; it is a
cut of the order, spelled out in the four order-theoretic clauses of `AscendsToGap`: nonempty, no
maximum, bounded above **in `D`**, and the upper bounds **in `D`** have no minimum. For `S ⊆ ℚ`,

> "`S` accumulates at some irrational `T` from below" **iff** "there is `S₀ ⊆ S` with no maximum,
> bounded above in `ℚ`, whose set of upper bounds in `ℚ` has no minimum"

((⇐) `T := sSup S₀` is approached from below since `S₀` has no maximum, and `T ∈ ℚ` would make `T`
the least upper bound; (⇒) take `S₀ := S ∩ (T-1, T)`, whose upper bounds are `{q > T}`, which has
no minimum because `T ∉ ℚ`). The right-hand side mentions only `<`, boundedness, maxima and
minima. Hence the invariant is **invariant under any order isomorphism**, which is what
`noGuardAccumulation_transport` cashes out: an invariant established on a countable dense
sub-order `D` pulls back along an order isomorphism `ℚ ≃o D` to the invariant on all of `ℚ`, which
is the form the payoff consumes. That transport is the reason the invariant is stated relative to
a domain `D` at all, and it is why no edit to the Cantor isomorphism is needed anywhere.

**3. The domain `D` is a parameter.** Finite domains satisfy the invariant outright
(`noGuardAccumulation_of_finite`), because a set with no maximum is infinite. A one-point domain
therefore satisfies it (`noGuardAccumulation_singleton`) — there is nothing to accumulate. This is
the cheap check, and it is landed rather than asserted: a formulation that a one-point domain
already failed would be the wrong formulation, and discovering that later would waste the whole
arc.

## Alternatives considered and rejected

* *Indexing by a `Finset` of guards rather than a `Set`.* Rejected: `BFMCS.LimitGuardEventual`
  quantifies over **all** guards with no closure hypothesis (deliberately — see its docstring), so
  the payoff needs `G = Set.univ`. A `Set` parameter serves both that use and the finitely-indexed
  use, and `noGuardAccumulation_mono_guards` moves between them.
* *Stating accumulation with a real `r` and `limitSetBelow`.* Rejected: correct, but not
  order-theoretic, so it does not transport, and it could not be maintained by a construction that
  only ever manipulates a finite rational domain.
* *Taking the guard-failure points to be `{q | ψ ∉ m q}`.* Rejected in favour of the literal
  `¬ψ`-points `{q | Formula.neg ψ ∈ m q}`. Under maximal consistency the two agree, and the bridge
  is `SetMaximalConsistent.negation_complete`; but the `¬ψ` form is the one a Hintikka-style state
  class can carry, and it is the one the phrase "the `¬ψ`-points" actually denotes.

## What is *not* claimed

`familyQ_violates_noGuardAccumulation` shows the invariant **excludes** the accumulating pattern:
one atom `P`, a gap `T`, guard `ψ := ¬P` failing cofinally below `T`, and `untl P (¬P)` true
throughout. It says **nothing** about whether that pattern is realizable by a family of
Dedekind-maximal-consistent sets. Settling that needs Ehrenfeucht-Fraïssé / modal-depth machinery
which is out of scope here and is not attempted. The exclusion is what makes the invariant
non-vacuous; realizability is a separate and open question.

## Main definitions and results

- `AscendsToGap` — the order-theoretic gap-approach predicate.
- `CofinalBelowGap` — the ℚ-level liveness condition on the obligation.
- `NoGuardAccumulation` — the invariant.
- `noGuardAccumulation_of_finite`, `noGuardAccumulation_singleton` — satisfiability (P2).
- `limitGuardEventual_of_noGuardAccumulation` — the payoff (P1).
- `not_noGuardAccumulation_of_cofinal_guard_failure`, `familyQ_violates_noGuardAccumulation` —
  the exclusion of the accumulating family (P3).
- `noGuardAccumulation_transport` — order-isomorphism transport.
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle

/-! ## The order-theoretic gap-approach predicate -/

/--
`S₀` **ascends to a gap of `D`**: purely order-theoretic, mentioning only `<`, boundedness,
maxima and minima, all relative to the domain `D`.

For `D = Set.univ` this says exactly that `S₀ ⊆ ℚ` accumulates from below at an irrational; the
equivalence is spelled out in the module docstring. Because the four clauses never mention `ℝ`,
the predicate is preserved and reflected by any order isomorphism, which is what
`noGuardAccumulation_transport` uses.

**No source.** Original work.
-/
structure AscendsToGap (D : Set Rat) (S₀ : Set Rat) : Prop where
  /-- The approaching set lives in the domain. -/
  subset : S₀ ⊆ D
  /-- The approach is not empty. -/
  nonempty : S₀.Nonempty
  /-- The approach has no last point — it genuinely ascends. -/
  no_max : ∀ a ∈ S₀, ∃ b ∈ S₀, a < b
  /-- The approach is bounded above **in the domain**. -/
  bdd_above : ∃ c ∈ D, ∀ a ∈ S₀, a < c
  /-- The upper bounds **in the domain** have no least element: the cut is a gap, not a point. -/
  ub_no_min : ∀ c ∈ D, (∀ a ∈ S₀, a < c) → ∃ c' ∈ D, (∀ a ∈ S₀, a < c') ∧ c' < c

/--
A set ascending to a gap is infinite: it is nonempty and has no maximum, and a finite nonempty
set in a linear order has a maximum.

**No source.** Original work.
-/
theorem AscendsToGap.infinite {D S₀ : Set Rat} (h : AscendsToGap D S₀) : S₀.Infinite := by
  by_contra hcon
  rw [Set.not_infinite] at hcon
  obtain ⟨a, hmax⟩ := Set.Finite.exists_maximal hcon h.nonempty
  obtain ⟨b, hbS, hab⟩ := h.no_max a hmax.1
  exact absurd (hmax.2 hbS hab.le) (not_le.mpr hab)

/-! ## The invariant -/

/--
The obligation `A` is **cofinal in the approach to the gap** determined by `S₀`: at every domain
point strictly below the gap there is a later domain point, still strictly below the gap, carrying
`A`.

"Strictly below the gap" is rendered order-theoretically as "strictly below some member of `S₀`",
which is correct precisely because `S₀` has no maximum.

**No source.** Original work.
-/
def CofinalBelowGap (D : Set Rat) (m : Rat → Set Formula) (S₀ : Set Rat) (A : Formula) : Prop :=
  ∀ a ∈ D, (∃ b ∈ S₀, a < b) → ∃ q ∈ D, a < q ∧ (∃ b ∈ S₀, q < b) ∧ A ∈ m q

/--
**The guard-accumulation invariant.**

For every guard `ψ ∈ G` and every event formula `φ`: no set of `¬ψ`-points of `D` ascends to a gap
of `D` while the obligation `untl φ ψ` — or its past mirror `snce φ ψ` — stays cofinal in the
approach to that gap.

The conditioning on the obligation is essential and is not a weakening for convenience: the
unconditional form ("every guard in the closure is eventually true below every gap") is false,
because formulas oscillate. See the module docstring.

**No source.** Original work. ADAPTED-FROM Burgess 1982 I §2.10, printed pp.372-373 (fresh-point
witness placement — the discipline whose accumulation behaviour is constrained here); ADAPTED-FROM
Burgess 1984 §2.7, printed pp.109-110 (the far-side placement, which carries no guard).
-/
def NoGuardAccumulation (D : Set Rat) (m : Rat → Set Formula) (G : Set Formula) : Prop :=
  ∀ ψ ∈ G, ∀ φ : Formula, ∀ S₀ : Set Rat, AscendsToGap D S₀ →
    (∀ q ∈ S₀, Formula.neg ψ ∈ m q) →
    ¬ (CofinalBelowGap D m S₀ (Formula.untl φ ψ) ∨ CofinalBelowGap D m S₀ (Formula.snce φ ψ))

/-- The invariant is antitone in the guard set: fewer guards is a weaker demand. -/
theorem noGuardAccumulation_mono_guards {D : Set Rat} {m : Rat → Set Formula}
    {G G' : Set Formula} (hGG : G ⊆ G') (h : NoGuardAccumulation D m G') :
    NoGuardAccumulation D m G :=
  fun ψ hψ => h ψ (hGG hψ)

/-! ## Satisfiability (P2) -/

/--
**Every finite domain satisfies the invariant**, vacuously: a set ascending to a gap is infinite,
so no such set fits inside a finite domain.

**No source.** Original work.
-/
theorem noGuardAccumulation_of_finite {D : Set Rat} (hD : D.Finite) (m : Rat → Set Formula)
    (G : Set Formula) : NoGuardAccumulation D m G := by
  intro _ _ _ S₀ hasc _ _
  exact hasc.infinite (hD.subset hasc.subset)

/--
**Stage 0 satisfies the invariant.** A one-point domain has nothing to accumulate.

This is the cheap check that a formulation must pass: the initial chronicle stage is a single
rational point, so the invariant it must carry has to hold there outright. It does, and for the
structural reason one wants — not because the guard set happens to be empty.

**No source.** Original work.
-/
theorem noGuardAccumulation_singleton (x : Rat) (m : Rat → Set Formula) (G : Set Formula) :
    NoGuardAccumulation {x} m G :=
  noGuardAccumulation_of_finite (Set.finite_singleton x) m G

/--
A second, **infinite-domain** satisfiability witness: if no guard in `G` ever fails, the invariant
holds on any domain whatever. Recorded so that satisfiability is not an artefact of finiteness.

**No source.** Original work.
-/
theorem noGuardAccumulation_of_guard_never_fails {D : Set Rat} {m : Rat → Set Formula}
    {G : Set Formula} (h : ∀ ψ ∈ G, ∀ q : Rat, Formula.neg ψ ∉ m q) :
    NoGuardAccumulation D m G := by
  intro ψ hψ _ S₀ hasc hfail _
  obtain ⟨a, ha⟩ := hasc.nonempty
  exact h ψ hψ a (hfail a ha)

/-! ## The bridge from a real gap to the order-theoretic form -/

/--
The order-theoretic form is **implied** by the analytic one: a set of rationals lying strictly
below an unselected real `r` and cofinal there ascends to a gap of `ℚ`.

This is the (⇒) half of the characterization in the module docstring, and it is the half the
payoff needs. Unselectedness of `r` is used exactly once, to rule out that a rational upper bound
sits *at* the cut.

**No source.** Original work.
-/
theorem ascendsToGap_univ_of_cofinal_below (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r)
    (S : Set Rat) (hlt : ∀ q ∈ S, (q : ℝ) < r)
    (hcof : ∀ z : ℝ, z < r → ∃ q ∈ S, z < (q : ℝ)) :
    AscendsToGap Set.univ S := by
  refine ⟨Set.subset_univ S, ?_, ?_, ?_, ?_⟩
  · obtain ⟨q, hq, -⟩ := hcof (r - 1) (by linarith)
    exact ⟨q, hq⟩
  · intro a ha
    obtain ⟨b, hb, hab⟩ := hcof (a : ℝ) (hlt a ha)
    exact ⟨b, hb, by exact_mod_cast hab⟩
  · obtain ⟨c, hc⟩ := exists_rat_gt r
    refine ⟨c, Set.mem_univ c, ?_⟩
    intro a ha
    have : (a : ℝ) < (c : ℝ) := lt_trans (hlt a ha) hc
    exact_mod_cast this
  · intro c _ hub
    have hrc : r < (c : ℝ) := by
      rcases lt_trichotomy ((c : ℝ)) r with hlt' | heq | hgt
      · obtain ⟨q, hq, hcq⟩ := hcof (c : ℝ) hlt'
        have : q < c := hub q hq
        have : (q : ℝ) < (c : ℝ) := by exact_mod_cast this
        linarith
      · exact absurd ⟨c, heq⟩ hr
      · exact hgt
    obtain ⟨c', hrc', hc'c⟩ := exists_rat_btwn hrc
    refine ⟨c', Set.mem_univ c', ?_, by exact_mod_cast hc'c⟩
    intro a ha
    have : (a : ℝ) < (c' : ℝ) := lt_trans (hlt a ha) hrc'
    exact_mod_cast this

/--
A formula surviving into the ultrafilter limit at `r` is cofinal in the approach to the gap that
`S` determines. This is the ℚ-level shadow of the antecedent of `BFMCS.LimitGuardEventual`,
obtained from the descent handle `limitMCSBelow_cofinal_below`; the ultrafilter is consumed as-is
and is not touched.

**No source.** Original work.
-/
theorem cofinalBelowGap_of_mem_limitMCSBelow (m : Rat → Set Formula) (r : ℝ)
    (S : Set Rat) (hlt : ∀ q ∈ S, (q : ℝ) < r)
    (hcof : ∀ z : ℝ, z < r → ∃ q ∈ S, z < (q : ℝ))
    {A : Formula} (hA : A ∈ limitMCSBelow m r) :
    CofinalBelowGap Set.univ m S A := by
  intro a _ ⟨b, hbS, hab⟩
  have habR : (a : ℝ) < (b : ℝ) := by exact_mod_cast hab
  have har : (a : ℝ) < r := lt_trans habR (hlt b hbS)
  obtain ⟨q, haq, hqr, hAq⟩ := limitMCSBelow_cofinal_below m r hA (a : ℝ) har
  obtain ⟨b', hb'S, hqb'⟩ := hcof (q : ℝ) hqr
  exact ⟨q, Set.mem_univ q, by exact_mod_cast haq, ⟨b', hb'S, by exact_mod_cast hqb'⟩, hAq⟩

/-! ## The payoff implication (P1) -/

/--
**The payoff: the invariant discharges `BFMCS.LimitGuardEventual`.**

If every family of the bundle satisfies the guard-accumulation invariant on all of `ℚ` and at
every guard, then the bundle satisfies the guard-eventuality obligation at unselected reals — the
single residual of forward Until/Since coherence at `ℝ`.

The argument is the contrapositive. Suppose the guard `ψ` is *not* eventually true below the
unselected real `r`. Then its failure set is cofinal below `r`; by
`SetMaximalConsistent.negation_complete` the failures are literal `¬ψ`-points; by
`ascendsToGap_univ_of_cofinal_below` they ascend to a gap of `ℚ`; and by
`cofinalBelowGap_of_mem_limitMCSBelow` the surviving `untl`/`snce` obligation is cofinal in that
approach. That is precisely the configuration the invariant forbids.

`BFMCS.LimitGuardEventual` carries no closure hypothesis, so the guard set here is `Set.univ`;
`noGuardAccumulation_mono_guards` relates this to any finitely-indexed form.

**No source.** Original work. The statement discharged is Reynolds' `γ⁺` failure at the guard
(Reynolds 1992, printed p.175); the discharge is not Reynolds' and is attributed to no one.
-/
theorem limitGuardEventual_of_noGuardAccumulation {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (h : ∀ fam ∈ B.families, NoGuardAccumulation Set.univ fam.mcs Set.univ) :
    B.LimitGuardEventual := by
  intro fam hfam r hr φ ψ hlive
  by_contra hψ
  -- The `¬ψ`-points below `r`.
  have hcofraw : ∀ z : ℝ, z < r → ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < r ∧ ψ ∉ fam.mcs q := by
    intro z hz
    by_contra hno
    push Not at hno
    exact hψ ⟨z, hz, fun q h1 h2 => hno q h1 h2⟩
  set S : Set Rat := {q : Rat | (q : ℝ) < r ∧ Formula.neg ψ ∈ fam.mcs q} with hS
  have hlt : ∀ q ∈ S, (q : ℝ) < r := fun q hq => hq.1
  have hcof : ∀ z : ℝ, z < r → ∃ q ∈ S, z < (q : ℝ) := by
    intro z hz
    obtain ⟨q, hzq, hqr, hqψ⟩ := hcofraw z hz
    refine ⟨q, ⟨hqr, ?_⟩, hzq⟩
    rcases (fam.is_mcs q).negation_complete ψ with hin | hneg
    · exact absurd hin hqψ
    · exact hneg
  have hasc : AscendsToGap Set.univ S := ascendsToGap_univ_of_cofinal_below r hr S hlt hcof
  refine h fam hfam ψ (Set.mem_univ ψ) φ S hasc (fun q hq => hq.2) ?_
  rcases hlive with hu | hs
  · exact Or.inl (cofinalBelowGap_of_mem_limitMCSBelow fam.mcs r S hlt hcof hu)
  · exact Or.inr (cofinalBelowGap_of_mem_limitMCSBelow fam.mcs r S hlt hcof hs)

/-! ## The exclusion of the accumulating family (P3) -/

/--
**The invariant excludes every accumulating guard-failure pattern.**

If the `¬ψ`-points are cofinal below an unselected real `r` while `untl φ ψ` is likewise cofinal
there, the invariant fails. This is what distinguishes a real invariant from a vacuous one: the
prohibited configuration is exhibited, in Lean, as an actual refutation of the predicate.

**No source.** Original work.
-/
theorem not_noGuardAccumulation_of_cofinal_guard_failure
    (m : Rat → Set Formula) (G : Set Formula) (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r)
    (φ ψ : Formula) (hψG : ψ ∈ G)
    (hfail : ∀ z : ℝ, z < r → ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < r ∧ Formula.neg ψ ∈ m q)
    (hlive : ∀ z : ℝ, z < r → ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < r ∧ Formula.untl φ ψ ∈ m q) :
    ¬ NoGuardAccumulation Set.univ m G := by
  intro hinv
  set S : Set Rat := {q : Rat | (q : ℝ) < r ∧ Formula.neg ψ ∈ m q} with hS
  have hlt : ∀ q ∈ S, (q : ℝ) < r := fun q hq => hq.1
  have hcof : ∀ z : ℝ, z < r → ∃ q ∈ S, z < (q : ℝ) := by
    intro z hz
    obtain ⟨q, hzq, hqr, hq⟩ := hfail z hz
    exact ⟨q, ⟨hqr, hq⟩, hzq⟩
  have hasc : AscendsToGap Set.univ S := ascendsToGap_univ_of_cofinal_below r hr S hlt hcof
  refine hinv ψ hψG φ S hasc (fun q hq => hq.2) (Or.inl ?_)
  intro a _ ⟨b, hbS, hab⟩
  have habR : (a : ℝ) < (b : ℝ) := by exact_mod_cast hab
  have har : (a : ℝ) < r := lt_trans habR (hlt b hbS)
  obtain ⟨q, haq, hqr, hAq⟩ := hlive (a : ℝ) har
  obtain ⟨b', hb'S, hqb'⟩ := hcof (q : ℝ) hqr
  exact ⟨q, Set.mem_univ q, by exact_mod_cast haq, ⟨b', hb'S, by exact_mod_cast hqb'⟩, hAq⟩

/--
**The shape of the accumulating family**, as a hypothesis package at the ℚ level.

One atom `P`; a gap `T` (an unselected real); the guard `ψ := ¬P` failing cofinally below `T`
along an ascending sequence of `P`-points; and the obligation `untl P (¬P)` true at every rational
below `T`. This is the ℚ-intrinsic pattern: it is stated over `ℚ` only, so no appeal to any real
model is involved.

**This is a shape, not an existence claim.** Nothing here asserts that such a family of
Dedekind-maximal-consistent sets exists. Whether it does is open and is not settled here.

**No source.** Original work.
-/
structure FamilyQShape (m : Rat → Set Formula) (P : Formula) (T : ℝ) : Prop where
  /-- The accumulation point is a gap: it is not a selected rational. -/
  gap : ¬ ∃ q : Rat, (q : ℝ) = T
  /-- The guard `¬P` fails cofinally below the gap — the `P`-points ascend to it. -/
  guard_fails_cofinally :
    ∀ z : ℝ, z < T → ∃ t : Rat, z < (t : ℝ) ∧ (t : ℝ) < T ∧ Formula.neg (Formula.neg P) ∈ m t
  /-- The obligation `U(P, ¬P)` holds at every rational below the gap. -/
  until_below : ∀ q : Rat, (q : ℝ) < T → Formula.untl P (Formula.neg P) ∈ m q

/--
**The accumulating family violates the invariant.**

The falsification target for the construction-side sub-phases: any family of this shape is
excluded by `NoGuardAccumulation`, so an insertion discipline that produced the shape would be
detected rather than silently tolerated.

Note what is and is not shown. The invariant *excludes the pattern* — that is the whole claim. It
is emphatically **not** shown that the pattern is unrealizable at `FrameClass.Dedekind`; that
question needs Ehrenfeucht-Fraïssé / modal-depth machinery, is out of scope, and remains open.

**No source.** Original work.
-/
theorem familyQ_violates_noGuardAccumulation (m : Rat → Set Formula) (P : Formula) (T : ℝ)
    (hQ : FamilyQShape m P T) (G : Set Formula) (hmem : Formula.neg P ∈ G) :
    ¬ NoGuardAccumulation Set.univ m G := by
  refine not_noGuardAccumulation_of_cofinal_guard_failure m G T hQ.gap P (Formula.neg P) hmem
    hQ.guard_fails_cofinally ?_
  intro z hz
  obtain ⟨t, h1, h2, -⟩ := hQ.guard_fails_cofinally z hz
  exact ⟨t, h1, h2, hQ.until_below t h2⟩

/-! ## Order-isomorphism transport -/

/--
**The invariant transports along an order isomorphism.**

Given a strictly monotone `e : ℚ → ℚ` whose image is exactly `D`, the invariant on `D` pulls back
to the invariant on all of `ℚ` for the reindexed family `m ∘ e`. Every clause of `AscendsToGap`
and of `CofinalBelowGap` mentions only `<` and domain membership, so each transports term by term.

This is the form the payoff `limitGuardEventual_of_noGuardAccumulation` consumes, and it is why
the invariant is stated relative to a domain: an invariant maintained on a countable dense
sub-order arrives at `Set.univ` without any modification to the isomorphism itself.

**No source.** Original work.
-/
theorem noGuardAccumulation_transport {D : Set Rat} (e : Rat → Rat) (hmono : StrictMono e)
    (hmaps : ∀ q : Rat, e q ∈ D) (hsurj : ∀ x ∈ D, ∃ q : Rat, e q = x)
    (m : Rat → Set Formula) (G : Set Formula) (h : NoGuardAccumulation D m G) :
    NoGuardAccumulation Set.univ (fun q => m (e q)) G := by
  intro ψ hψ φ S₀ hasc hfail hcof
  refine h ψ hψ φ (e '' S₀) ?_ ?_ ?_
  · refine ⟨?_, ?_, ?_, ?_, ?_⟩
    · rintro _ ⟨a, -, rfl⟩; exact hmaps a
    · obtain ⟨a, ha⟩ := hasc.nonempty; exact ⟨e a, a, ha, rfl⟩
    · rintro _ ⟨a, ha, rfl⟩
      obtain ⟨b, hb, hab⟩ := hasc.no_max a ha
      exact ⟨e b, ⟨b, hb, rfl⟩, hmono hab⟩
    · obtain ⟨c, -, hc⟩ := hasc.bdd_above
      refine ⟨e c, hmaps c, ?_⟩
      rintro _ ⟨a, ha, rfl⟩
      exact hmono (hc a ha)
    · rintro c hcD hub
      obtain ⟨c₀, rfl⟩ := hsurj c hcD
      have hub₀ : ∀ a ∈ S₀, a < c₀ := by
        intro a ha
        exact hmono.lt_iff_lt.mp (hub (e a) ⟨a, ha, rfl⟩)
      obtain ⟨c', -, hc'ub, hc'lt⟩ := hasc.ub_no_min c₀ (Set.mem_univ c₀) hub₀
      refine ⟨e c', hmaps c', ?_, hmono hc'lt⟩
      rintro _ ⟨a, ha, rfl⟩
      exact hmono (hc'ub a ha)
  · rintro _ ⟨a, ha, rfl⟩
    exact hfail a ha
  · -- Cofinality transports because every domain point is `e` of a rational.
    have key : ∀ A : Formula, CofinalBelowGap Set.univ (fun q => m (e q)) S₀ A →
        CofinalBelowGap D m (e '' S₀) A := by
      rintro A hA a haD ⟨_, ⟨b, hb, rfl⟩, hab⟩
      obtain ⟨a₀, rfl⟩ := hsurj a haD
      obtain ⟨q, -, haq, ⟨b', hb', hqb'⟩, hAq⟩ :=
        hA a₀ (Set.mem_univ a₀) ⟨b, hb, hmono.lt_iff_lt.mp hab⟩
      exact ⟨e q, hmaps q, hmono haq, ⟨e b', ⟨b', hb', rfl⟩, hmono hqb'⟩, hAq⟩
    exact hcof.imp (key _) (key _)

end FormalSystem.Metalogic.BXCanonical.Chronicle
