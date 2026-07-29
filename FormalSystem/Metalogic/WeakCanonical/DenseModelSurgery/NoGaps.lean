/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.TruthTransfer
import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation
import FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful

/-!
# Reynolds §6 Lemma 9 and Theorem 4: the classes do not end at gaps

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§6 *"No gaps between equivalence classes"*, printed **pp.182-183**.

This module closes §6. `TruthTransfer.lean` proved **Lemma 8** — a whole bad interval may be
replaced by one of its `∼`-classes without changing any temporal truth value at a surviving
point. **Lemma 9** turns that around into a *reductio*: the replacement produces a structure in
which `R` both must and cannot hold at the surviving class, so there was never a bad point to
begin with. **Theorem 4** is the resulting statement, and is the **D1** hypothesis of Doets'
theorem.

## Measured page range

The §6 page map is `printed = PDF page + 164`. Lemma 9 and Theorem 4 were the one §6 row the map
could only **extrapolate**; both pages were therefore read as **200 dpi images**
(`pdftoppm -f 18 -l 19 -r 200`), not from `pdftotext`:

* PDF p.18 carries the printed running header **182**, and holds the tail of Lemma 8's backward
  cases followed by the **whole of Lemma 9**, statement and proof.
* PDF p.19 carries the printed running header **183**, and opens with the **statement of
  Theorem 4**, immediately followed by §7 *"Separability"*.

So the measured range is **pp.182-183**, confirming the extrapolation. An earlier plan revision
carried `pp.180-181`; that figure was never measured and is **wrong**.

## The source, verbatim

Printed **p.182**:

> **LEMMA 9** *In fact there can't have been any bad points anyway.*
>
> **PROOF.** By lemma 8, `R` holds in `I` in `N`.
>
> But by lemma 2, `R` holds at a point in any Prior structure (not just `M`) if and only if the
> `∼`-class of the point ends in a gap (where `∼` is the appropraite equivalence relation for the
> structure). And `N` is a Prior structure: we still have all the instances of Prior-U/S
> continuing to hold as any counterexample point in `N` is also one in `M`.
>
> By the contemporaneity of `ε`, `I` as a subset of `N`, like `I` as a subset of `M`, is all in
> one `∼_N`-class. Could the class be bigger now?
>
> `R` is true of this class so that it is bounded above amongst other things. Thus `Q⁺` is
> non-empty and by lemma 6 begins with a point `q` say. Also by lemma 6 `¬R` holds at `q` in `M`
> and so in `N`. Clearly `q` is not in the class of `I` in `N`. Thus the class ends just before
> `q`.
>
> `R` can not have been true in this class after all.
>
> Thus we have proven...

Printed **p.183**:

> **THEOREM 4** *Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure
> `M`.*
>
> *Then the `∼`-classes do not end at gaps.*

**Measured corpus divergence.** The printed page image spells *"appropraite"* in Lemma 9's second
paragraph; the local corpus markdown silently normalizes it to *"appropriate"*. The block quote
above reproduces the **image**. This is a corpus-conversion artifact, not a defect in Reynolds'
argument, and it is recorded only because §6's corpus text is under a standing accuracy warning.
No *displayed* formula occurs anywhere in Lemma 9 or Theorem 4 — the whole of both is inline
prose, which is the half of the corpus the standing warning rates as clean.

## Proof-step → name map

| Printed step (pp.182-183) | Declaration |
|---|---|
| *"`N` is a Prior structure: we still have all the instances of Prior-U/S continuing to hold"* | `priorUFormula`, `priorSFormula`, `surgeredSemanticPriorU`, `surgeredSemanticPriorS` |
| *"as any counterexample point in `N` is also one in `M`"* | `reynolds_lemma8` applied to `priorUFormula p` |
| *"By lemma 8, `R` holds in `I` in `N`"* | `reynolds_lemma9_R_in_N` |
| *"by lemma 2, `R` holds at a point in any Prior structure (not just `M`)"* | `gapRightFormula_spec` at `surgeredStructure` |
| *"By the contemporaneity of `ε`, `I` … is all in one `∼_N`-class"* | `surgeredContempEquiv_of_base` |
| *"Thus `Q⁺` is non-empty"* | `reynolds_lemma9_exists_after`, `exists_not_isBadPoint_gt` |
| *"and by lemma 6 begins with a point `q`"*, *"`¬R` holds at `q`"* | `reynolds_lemma6_right_endpoint` |
| *"Clearly `q` is not in the class of `I` in `N`. Thus the class ends just before `q`"* | `reynolds_lemma9` (the closing `refine`, on `endsInGapOnRight_congr`) |
| **LEMMA 9** itself | `reynolds_lemma9` |
| **THEOREM 4** | `no_gaps_dense_prior` |

## Honest caveat on conditionality — what this module does and does not retire

**The standing §6 caveat is NOT retired by this module, and stays verbatim wherever it is
carried.** `## Conditionality after Theorem 4` at the foot of this file gives the
three-condition accounting: `HasBadIntervalSurgery` (introduced here, now discharged by
`StepD.hasBadIntervalSurgery`), the Prior pair (discharged at one named structure by
`ChronicleInstance.lean`), and `ε` (standing). Read that section before describing any §6 result
as discharged — none of them is.
-/

namespace FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

open FormalSystem.Syntax FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! ## *"`N` is a Prior structure"*

> And `N` is a Prior structure: we still have all the instances of Prior-U/S continuing to hold
> as any counterexample point in `N` is also one in `M`.

This is the one step of Lemma 9 that Reynolds disposes of in a subordinate clause and that needs
real work in Lean, and it is the step `TruthTransfer.lean` explicitly does **not** discharge.

The subordinate clause is the whole argument, and it is a *formula-level* argument: Prior-U is an
**axiom scheme**, so *"all the instances of Prior-U/S"* are temporal formulas, and Lemma 8 moves
temporal formulas between `M` and `N` at every surviving point. A counterexample point for an
instance in `N` is, by Lemma 8, a counterexample point for the same instance in `M`.

The landed `SemanticPriorU` (`PriorDefsDense.lean:119`) is stated with explicit carrier
quantifiers rather than as the truth of a formula, so the argument cannot be run on it directly:
a semantic transfer would have to produce, from *"`p` holds at every point of `N` in `(t,s)`"*,
the corresponding statement about every point of **`M`** in `(t,s)` — and the points of `Q₀ ∖ I`
are exactly the ones that fail. So the bridge below is not bureaucracy: it is what makes
Reynolds' one-clause justification available at all.

`priorUFormula p` is Reynolds' `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)` (printed p.168) written out as
a `Formula`, and `temporalTruth_priorUFormula` checks — rather than asserts — that its truth at
`t` is exactly the body of `SemanticPriorU` at `t`. -/

section PriorScheme

variable (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)

/-- **The Prior-U instance at `p`, as a temporal formula** — Reynolds 1992, printed p.168:

`U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)`.

`F ψ` is `U(ψ, ⊤)` and `K⁺` is `Formula.kPlus` (`Syntax/Formula.lean:180`), which is Reynolds'
`K⁺A = ¬U(⊤,¬A)` and **not** `Kamp/PriorINF.lean`'s differently-defined `kplusFormula` — see that
definition's name-collision warning.

This is the syntactic side of `SemanticPriorU`; `Axiom.prior_U_gap` (`ProofSystem/Axioms.lean:377`)
is the same scheme on the proof-theoretic side. -/
def priorUFormula (p : Formula) : Formula :=
  .imp (.and (.untl .top p) (.untl p.neg .top))
    (.untl (.or p.neg (Formula.kPlus p.neg)) p)

/-- **The Prior-S instance at `p`, as a temporal formula** — the past mirror,
`S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p), p)`, with `Formula.kMinus` for `K⁻`. -/
def priorSFormula (p : Formula) : Formula :=
  .imp (.and (.snce .top p) (.snce p.neg .top))
    (.snce (.or p.neg (Formula.kMinus p.neg)) p)

variable {M atomMap}

/-! ### The four readings the scheme is built from

Each is a single unfolding against a landed helper (`Kamp/Translation.lean`'s
`Kamp.temporal_truth_top` / `_and` / `_or` / `_neg`, and `Kamp/KPlusFaithful.lean`'s
`Kamp.kPlus_formula_correct`). Nothing here is new mathematics; they exist so that
`temporalTruth_priorUFormula` reads as the printed scheme rather than as a `simp` incantation. -/

/-- `U(⊤, p)` at `t`: *"`p` holds throughout some initial stretch above `t`"*. -/
theorem temporalTruth_untl_top (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (.untl .top p) ↔
      ∃ s : M.carrier, t < s ∧ ∀ r : M.carrier, t < r → r < s → TemporalTruth M atomMap r p :=
  ⟨fun ⟨s, hts, _, h⟩ => ⟨s, hts, h⟩,
    fun ⟨s, hts, h⟩ => ⟨s, hts, Kamp.temporal_truth_top M atomMap s, h⟩⟩

/-- `F ¬p` at `t`, i.e. `U(¬p, ⊤)`: *"`¬p` holds somewhere above `t`"*. -/
theorem temporalTruth_someFuture_neg (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (.untl p.neg .top) ↔
      ∃ u : M.carrier, t < u ∧ ¬ TemporalTruth M atomMap u p :=
  ⟨fun ⟨u, htu, hu, _⟩ => ⟨u, htu, (Kamp.temporal_truth_neg M atomMap u p).mp hu⟩,
    fun ⟨u, htu, hu⟩ => ⟨u, htu, (Kamp.temporal_truth_neg M atomMap u p).mpr hu,
      fun r _ _ => Kamp.temporal_truth_top M atomMap r⟩⟩

/-- `K⁺(¬p)` at `s`: *"`¬p` holds arbitrarily soon after `s`"*, through the landed
`Kamp.kPlus_formula_correct` and `kplusOpen`. -/
theorem temporalTruth_kPlus_neg (s : M.carrier) (p : Formula) :
    TemporalTruth M atomMap s (Formula.kPlus p.neg) ↔
      ∀ u : M.carrier, s < u → ∃ r : M.carrier, s < r ∧ r < u ∧ ¬ TemporalTruth M atomMap r p := by
  rw [Kamp.kPlus_formula_correct]
  exact forall_congr' fun u => forall_congr' fun _ =>
    exists_congr fun r => and_congr_right fun _ => and_congr_right fun _ =>
      Kamp.temporal_truth_neg M atomMap r p

/-- `U(¬p ∨ K⁺(¬p), p)` at `t`, in the form `SemanticPriorU`'s consequent is written.

The one classical step of the whole bridge lives here: the formula's disjunction is
`¬p(s) ∨ K⁺(¬p)(s)` while `SemanticPriorU` writes `¬p(s) ∨ (p(s) ∧ K⁺(¬p)(s))`, and
`A ∨ B ↔ A ∨ (¬A ∧ B)` needs excluded middle on `A`. -/
theorem temporalTruth_untl_stop (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (.untl (.or p.neg (Formula.kPlus p.neg)) p) ↔
      ∃ s : M.carrier, t < s ∧
        (∀ r : M.carrier, t < r → r < s → TemporalTruth M atomMap r p) ∧
        (¬ TemporalTruth M atomMap s p ∨
          (TemporalTruth M atomMap s p ∧
            ∀ u : M.carrier, s < u →
              ∃ r : M.carrier, s < r ∧ r < u ∧ ¬ TemporalTruth M atomMap r p)) := by
  classical
  constructor
  · rintro ⟨s, hts, hs, hbelow⟩
    refine ⟨s, hts, hbelow, ?_⟩
    rcases (Kamp.temporal_truth_or M atomMap s p.neg (Formula.kPlus p.neg)).mp hs with hns | hk
    · exact Or.inl ((Kamp.temporal_truth_neg M atomMap s p).mp hns)
    · by_cases hp : TemporalTruth M atomMap s p
      · exact Or.inr ⟨hp, (temporalTruth_kPlus_neg s p).mp hk⟩
      · exact Or.inl hp
  · rintro ⟨s, hts, hbelow, hcase⟩
    refine ⟨s, hts, ?_, hbelow⟩
    refine (Kamp.temporal_truth_or M atomMap s p.neg (Formula.kPlus p.neg)).mpr ?_
    rcases hcase with hns | ⟨_, hk⟩
    · exact Or.inl ((Kamp.temporal_truth_neg M atomMap s p).mpr hns)
    · exact Or.inr ((temporalTruth_kPlus_neg s p).mpr hk)

/-- **The `priorUFormula` transcription is correct**: its truth at `t` is exactly the body of
`SemanticPriorU` at `t` and `p`.

Checked rather than asserted, so that the `Formula` above is pinned to the semantic scheme it is
supposed to render. This is what makes *"all the instances of Prior-U continuing to hold"* a
statement Lemma 8 can act on. -/
theorem temporalTruth_priorUFormula (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (priorUFormula p) ↔
      ((∃ s : M.carrier, t < s ∧ ∀ r : M.carrier, t < r → r < s → TemporalTruth M atomMap r p) →
        (∃ u : M.carrier, t < u ∧ ¬ TemporalTruth M atomMap u p) →
        ∃ s : M.carrier, t < s ∧
          (∀ r : M.carrier, t < r → r < s → TemporalTruth M atomMap r p) ∧
          (¬ TemporalTruth M atomMap s p ∨
            (TemporalTruth M atomMap s p ∧
              ∀ u : M.carrier, s < u →
                ∃ r : M.carrier, s < r ∧ r < u ∧ ¬ TemporalTruth M atomMap r p))) := by
  show (TemporalTruth M atomMap t _ → TemporalTruth M atomMap t _) ↔ _
  rw [Kamp.temporal_truth_and, temporalTruth_untl_top, temporalTruth_someFuture_neg,
    temporalTruth_untl_stop]
  exact ⟨fun h h₁ h₂ => h ⟨h₁, h₂⟩, fun h ⟨h₁, h₂⟩ => h h₁ h₂⟩

/-- **Prior-U as a scheme of temporal formulas.** `SemanticPriorU` says exactly that every
instance of `priorUFormula` is true at every point — which is what makes it transportable by
Lemma 8. -/
theorem semanticPriorU_iff_forall :
    SemanticPriorU M atomMap ↔
      ∀ (t : M.carrier) (p : Formula), TemporalTruth M atomMap t (priorUFormula p) :=
  forall_congr' fun t => forall_congr' fun p => (temporalTruth_priorUFormula t p).symm

/-! ### The past mirror

Written out rather than obtained by instantiation at `dual M`. `Dual.lean`'s `swapUS` does give
`swapUS (priorUFormula p) = priorSFormula (swapUS p)`, but the transport it feeds
(`semanticPriorS_dual`) runs `SemanticPriorU M → SemanticPriorS (dual M)` and the direction
needed here is the other one, at `M` itself; supplying it would be more new work than the
transcription below.

The transcription is not a *mirror* in the sense `Dual.lean` exists to avoid, either: Reynolds
prints `S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p), p)` in his own abbreviation table on p.168, next to
Prior-U, so both schemes are quoted rather than one being invented from the other. Every step
below is a definitional unfolding against a landed helper. -/

/-- `S(⊤, p)` at `t`: *"`p` holds throughout some final stretch below `t`"*. -/
theorem temporalTruth_snce_top (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (.snce .top p) ↔
      ∃ s : M.carrier, s < t ∧ ∀ r : M.carrier, s < r → r < t → TemporalTruth M atomMap r p :=
  ⟨fun ⟨s, hst, _, h⟩ => ⟨s, hst, h⟩,
    fun ⟨s, hst, h⟩ => ⟨s, hst, Kamp.temporal_truth_top M atomMap s, h⟩⟩

/-- `P ¬p` at `t`, i.e. `S(¬p, ⊤)`: *"`¬p` held somewhere below `t`"*. -/
theorem temporalTruth_somePast_neg (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (.snce p.neg .top) ↔
      ∃ u : M.carrier, u < t ∧ ¬ TemporalTruth M atomMap u p :=
  ⟨fun ⟨u, hut, hu, _⟩ => ⟨u, hut, (Kamp.temporal_truth_neg M atomMap u p).mp hu⟩,
    fun ⟨u, hut, hu⟩ => ⟨u, hut, (Kamp.temporal_truth_neg M atomMap u p).mpr hu,
      fun r _ _ => Kamp.temporal_truth_top M atomMap r⟩⟩

/-- `K⁻(¬p)` at `s`, through the landed `kMinus_formula_correct` and `kminusOpen`. -/
theorem temporalTruth_kMinus_neg (s : M.carrier) (p : Formula) :
    TemporalTruth M atomMap s (Formula.kMinus p.neg) ↔
      ∀ u : M.carrier, u < s → ∃ r : M.carrier, u < r ∧ r < s ∧ ¬ TemporalTruth M atomMap r p := by
  rw [Kamp.kMinus_formula_correct]
  exact forall_congr' fun u => forall_congr' fun _ =>
    exists_congr fun r => and_congr_right fun _ => and_congr_right fun _ =>
      Kamp.temporal_truth_neg M atomMap r p

/-- `S(¬p ∨ K⁻(¬p), p)` at `t`, in the form `SemanticPriorS`'s consequent is written. -/
theorem temporalTruth_snce_stop (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (.snce (.or p.neg (Formula.kMinus p.neg)) p) ↔
      ∃ s : M.carrier, s < t ∧
        (∀ r : M.carrier, s < r → r < t → TemporalTruth M atomMap r p) ∧
        (¬ TemporalTruth M atomMap s p ∨
          (TemporalTruth M atomMap s p ∧
            ∀ u : M.carrier, u < s →
              ∃ r : M.carrier, u < r ∧ r < s ∧ ¬ TemporalTruth M atomMap r p)) := by
  classical
  constructor
  · rintro ⟨s, hst, hs, hbelow⟩
    refine ⟨s, hst, hbelow, ?_⟩
    rcases (Kamp.temporal_truth_or M atomMap s p.neg (Formula.kMinus p.neg)).mp hs with hns | hk
    · exact Or.inl ((Kamp.temporal_truth_neg M atomMap s p).mp hns)
    · by_cases hp : TemporalTruth M atomMap s p
      · exact Or.inr ⟨hp, (temporalTruth_kMinus_neg s p).mp hk⟩
      · exact Or.inl hp
  · rintro ⟨s, hst, hbelow, hcase⟩
    refine ⟨s, hst, ?_, hbelow⟩
    refine (Kamp.temporal_truth_or M atomMap s p.neg (Formula.kMinus p.neg)).mpr ?_
    rcases hcase with hns | ⟨_, hk⟩
    · exact Or.inl ((Kamp.temporal_truth_neg M atomMap s p).mpr hns)
    · exact Or.inr ((temporalTruth_kMinus_neg s p).mpr hk)

/-- **The `priorSFormula` transcription is correct** — the past mirror of
`temporalTruth_priorUFormula`. -/
theorem temporalTruth_priorSFormula (t : M.carrier) (p : Formula) :
    TemporalTruth M atomMap t (priorSFormula p) ↔
      ((∃ s : M.carrier, s < t ∧ ∀ r : M.carrier, s < r → r < t → TemporalTruth M atomMap r p) →
        (∃ u : M.carrier, u < t ∧ ¬ TemporalTruth M atomMap u p) →
        ∃ s : M.carrier, s < t ∧
          (∀ r : M.carrier, s < r → r < t → TemporalTruth M atomMap r p) ∧
          (¬ TemporalTruth M atomMap s p ∨
            (TemporalTruth M atomMap s p ∧
              ∀ u : M.carrier, u < s →
                ∃ r : M.carrier, u < r ∧ r < s ∧ ¬ TemporalTruth M atomMap r p))) := by
  show (TemporalTruth M atomMap t _ → TemporalTruth M atomMap t _) ↔ _
  rw [Kamp.temporal_truth_and, temporalTruth_snce_top, temporalTruth_somePast_neg,
    temporalTruth_snce_stop]
  exact ⟨fun h h₁ h₂ => h ⟨h₁, h₂⟩, fun h ⟨h₁, h₂⟩ => h h₁ h₂⟩

/-- **Prior-S as a scheme of temporal formulas** — the past mirror of
`semanticPriorU_iff_forall`. -/
theorem semanticPriorS_iff_forall :
    SemanticPriorS M atomMap ↔
      ∀ (t : M.carrier) (p : Formula), TemporalTruth M atomMap t (priorSFormula p) :=
  forall_congr' fun t => forall_congr' fun p => (temporalTruth_priorSFormula t p).symm

end PriorScheme

/-! ## *"`N` is a Prior structure"*, discharged

With the two schemes in formula form, Reynolds' subordinate clause is exactly one application of
Lemma 8 per instance. Note which way the implication runs: an instance holds at every point of
`N` **because** it holds at the corresponding point of `M`, which is his *"any counterexample
point in `N` is also one in `M`"* read contrapositively. -/

section PriorStructure

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}
  {Q : M.carrier → Prop} {t : M.carrier}

/-- **Prior-U survives the surgery.** -/
theorem surgeredSemanticPriorU (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hS : IsBadIntervalSurgery M ε Q t) :
    SemanticPriorU (surgeredStructure M ε Q t) atomMap := by
  refine semanticPriorU_iff_forall.mpr fun x p => ?_
  refine (reynolds_lemma8 atomMap h_surj hε h_prior_U h_prior_S hS (priorUFormula p) x).mp ?_
  exact semanticPriorU_iff_forall.mp h_prior_U x.val p

/-- **Prior-S survives the surgery.** -/
theorem surgeredSemanticPriorS (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hS : IsBadIntervalSurgery M ε Q t) :
    SemanticPriorS (surgeredStructure M ε Q t) atomMap := by
  refine semanticPriorS_iff_forall.mpr fun x p => ?_
  refine (reynolds_lemma8 atomMap h_surj hε h_prior_U h_prior_S hS (priorSFormula p) x).mp ?_
  exact semanticPriorS_iff_forall.mp h_prior_S x.val p

end PriorStructure

/-! ## *"By the contemporaneity of `ε`, `I` … is all in one `∼_N`-class"*

> By the contemporaneity of `ε`, `I` as a subset of `N`, like `I` as a subset of `M`, is all in
> one `∼_N`-class. Could the class be bigger now?

The named appeal is to clause (iii) of `IsContempEquivDense`: `M ⊨ ε(a,b)` iff `M|[a,b] ⊨ ε(a,b)`.
Two points of `I` have the whole `M`-interval between them inside `I`, by convexity of a class,
and `I` survives the surgery — so `M|[a,b]` and `N|[a,b]` have *the same points*, and clause (iii)
read at `M` and at `N` sandwiches the two readings of `ε` together.

The construction is `isContempEquivDense_dualize`'s `contemporary` clause with
`surgerySubintervalIso` in place of `subintervalDualIso`; the landed `contempEquivDense_iso` does
the crossing in both.

Reynolds' follow-up question, *"Could the class be bigger now?"*, is answered by Lemma 9 itself
rather than here: this direction (`I` stays together) is all his argument uses, and the
possibility that the `∼_N`-class properly contains `I` is exactly what the reductio goes on to
refute. -/

section Contemporaneity

variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}
  {Q : M.carrier → Prop} {t : M.carrier}

/-- `min` on a restricted carrier is computed pointwise. -/
theorem restrict_val_min {D : M.carrier → Prop} (x y : (restrictStructure M D).carrier) :
    (min x y).val = min x.val y.val := by
  rcases le_total x y with h | h
  · rw [min_eq_left h, min_eq_left (show x.val ≤ y.val from h)]
  · rw [min_eq_right h, min_eq_right (show y.val ≤ x.val from h)]

/-- `max` on a restricted carrier is computed pointwise. -/
theorem restrict_val_max {D : M.carrier → Prop} (x y : (restrictStructure M D).carrier) :
    (max x y).val = max x.val y.val := by
  rcases le_total x y with h | h
  · rw [max_eq_right h, max_eq_right (show x.val ≤ y.val from h)]
  · rw [max_eq_left h, max_eq_left (show y.val ≤ x.val from h)]

/-- **`M|[a,b]` and `N|[u,v]` have the same points** when the whole `M`-interval `[a,b]` survives
the surgery, `u` and `v` being `a` and `b` seen in `N`. -/
def surgerySubintervalEquiv (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier)
    {u v : (surgeredStructure M ε Q t).carrier} {a b : M.carrier}
    (hu : u.val = a) (hv : v.val = b)
    (hin : ∀ z : M.carrier, a ≤ z → z ≤ b → SurgeryDomain M ε Q t z) :
    (M.subinterval sig a b).carrier ≃
      ((surgeredStructure M ε Q t).subinterval sig u v).carrier where
  toFun x := ⟨⟨x.val, hin x.val x.property.1 x.property.2⟩,
    hu ▸ x.property.1, hv ▸ x.property.2⟩
  invFun y := ⟨y.val.val, hu ▸ y.property.1, hv ▸ y.property.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- **The same-points equivalence is a structure isomorphism.** Both the order and every
predicate reading are the inherited ones on `M.carrier`, so both clauses are definitional. -/
def surgerySubintervalIso (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier)
    {u v : (surgeredStructure M ε Q t).carrier} {a b : M.carrier}
    (hu : u.val = a) (hv : v.val = b)
    (hin : ∀ z : M.carrier, a ≤ z → z ≤ b → SurgeryDomain M ε Q t z) :
    StructIso (M.subinterval sig a b)
      ((surgeredStructure M ε Q t).subinterval sig u v) where
  toEquiv := surgerySubintervalEquiv M ε Q t hu hv hin
  map_lt _ _ := Iff.rfl
  map_interp _ _ := Iff.rfl

/-- **A class is convex, as a set of points**: anything between two members of `t`'s class is in
`t`'s class. Clause (ii) of `IsContempEquivDense` with the base point moved to `t`. -/
theorem contemp_of_mem_class_interval (hε : IsContempEquivDense ε) {x y z : M.carrier}
    (hx : ContempEquivDense M ε t x) (hy : ContempEquivDense M ε t y)
    (h₁ : min x y ≤ z) (h₂ : z ≤ max x y) : ContempEquivDense M ε t z := by
  have hequiv := hε.equiv M
  rcases le_total x y with hxy | hxy
  · rw [min_eq_left hxy] at h₁
    rw [max_eq_right hxy] at h₂
    exact hequiv.trans hx (hε.convex M x z y h₁ h₂ (hequiv.trans (hequiv.symm hx) hy))
  · rw [min_eq_right hxy] at h₁
    rw [max_eq_left hxy] at h₂
    exact hequiv.trans hy (hε.convex M y z x h₁ h₂ (hequiv.trans (hequiv.symm hy) hx))

/-- **`I` is all in one `∼_N`-class** — printed p.182.

Two survivors of the designated class `I` are `∼_N`-equivalent. -/
theorem surgeredContempEquiv_of_base (hε : IsContempEquivDense ε)
    {x y : (surgeredStructure M ε Q t).carrier}
    (hx : ContempEquivDense M ε t x.val) (hy : ContempEquivDense M ε t y.val) :
    ContempEquivDense (surgeredStructure M ε Q t) ε x y := by
  have hequiv := hε.equiv M
  have hin : ∀ z : M.carrier, min x.val y.val ≤ z → z ≤ max x.val y.val →
      SurgeryDomain M ε Q t z :=
    fun z h₁ h₂ => Or.inr (contemp_of_mem_class_interval hε hx hy h₁ h₂)
  have hiso := contempEquivDense_iso
    (surgerySubintervalIso M ε Q t (u := min x y) (v := max x y)
      (restrict_val_min x y) (restrict_val_max x y) hin) ε
    ⟨x.val, min_le_left x.val y.val, le_max_left x.val y.val⟩
    ⟨y.val, min_le_right x.val y.val, le_max_right x.val y.val⟩
  exact (hε.contemporary (surgeredStructure M ε Q t) x y).mpr
    (hiso.mpr ((hε.contemporary M x.val y.val).mp (hequiv.trans (hequiv.symm hx) hy)))

end Contemporaneity

/-! ## Lemma 9

> **LEMMA 9** *In fact there can't have been any bad points anyway.*

The proof is a reductio run on the surgery of Lemma 8, and it is transcribed step by step below.
Reynolds' six sentences become six named lemmas; the last of them closes the contradiction.

**The hypothesis Reynolds does not name.** His *"by lemma 6 begins with a point `q`"* is the third
clause of Lemma 6, which in this tree is `reynolds_lemma6_right_endpoint`
(`BadIntervals.lean:1281`). That declaration carries an explicit hypothesis `hbadR` — *"every bad
point at or above `t` is an `R`-point"* — because Reynolds' *"plainly impossible given `ρ`"* step
inside it needs Lemma 6's **first** clause (*"in any bad interval both `R` and `L` hold
throughout"*) at the boundary point, and the landed development declined to assume that silently.
`hbadR` is therefore carried here too, at the point where it is genuinely consumed, rather than
being smuggled into `IsBadIntervalSurgery`. Inside `Q₀` it is free — `endsInGapOnRight_of_mem`
below proves it from the interiority witnesses — but Reynolds' argument applies Lemma 6 at a point
of `Q⁺`, outside `Q₀`, and there it is a real assumption. See `## Conditionality after Theorem 4`
for what this costs. -/

section Lemma9

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}
  {Q : M.carrier → Prop} {t : M.carrier}

/-- **`t` itself survives its own surgery** — the designated point of `I`, seen in `N`. -/
def surgeryBase (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier) (h : ContempEquivDense M ε t t) :
    (surgeredStructure M ε Q t).carrier :=
  ⟨t, Or.inr h⟩

/-- **`R` holds throughout the bad interval in `M`** — Lemma 6's first clause, in the form the
interiority witnesses already carry. -/
theorem endsInGapOnRight_of_mem (hS : IsBadIntervalSurgery M ε Q t) {u : M.carrier} (hu : Q u) :
    EndsInGapOnRight M ε u := by
  obtain ⟨a, b, _, _, hint⟩ := hS.interior u u hu hu
  exact hint.toR.rThroughout u hint.toR.left_lt.le hint.toR.lt_right.le

/-- **A stretch of bad points above `t` lies inside `Q₀`** — maximality of the bad interval,
used twice below. -/
theorem mem_of_badStretch (hS : IsBadIntervalSurgery M ε Q t) {r : M.carrier} (htr : t < r)
    (hbad : ∀ z : M.carrier, t < z → z ≤ r → IsBadPoint M ε z) : Q r := by
  refine hS.isBad.saturated t r hS.mem fun z hz₁ hz₂ => ?_
  rw [min_eq_left htr.le] at hz₁
  rw [max_eq_right htr.le] at hz₂
  rcases eq_or_lt_of_le hz₁ with h | h
  · exact h ▸ hS.badPoint hS.mem
  · exact hbad z h hz₂

variable (atomMap : Formula → sig.preds)
  (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)

include h_surj

/-- **"By lemma 8, `R` holds in `I` in `N`"** — printed p.182.

Three moves: `R` holds at `t` in `M` because `t` is in the bad interval (Lemma 6's first clause);
Lemma 8 carries `R` to `t` in `N`; and Lemma 2 read **at `N`** — legitimate exactly because Lemma
2 quantifies `∃ R` before `∀ N`, and because `N` is a Prior structure — turns that back into a
statement about `∼_N`. -/
theorem reynolds_lemma9_R_in_N (hε : IsContempEquivDense ε)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (hS : IsBadIntervalSurgery M ε Q t) :
    EndsInGapOnRight (surgeredStructure M ε Q t) ε
      (surgeryBase M ε Q t ((hε.equiv M).refl t)) := by
  have hR : TemporalTruth M atomMap t (gapRightFormula atomMap h_surj ε) :=
    (gapRightFormula_spec atomMap h_surj ε M h_prior_U h_prior_S t).mpr
      (endsInGapOnRight_of_mem hS hS.mem)
  have hN := (reynolds_lemma8 atomMap h_surj hε h_prior_U h_prior_S hS
    (gapRightFormula atomMap h_surj ε) (surgeryBase M ε Q t ((hε.equiv M).refl t))).mp hR
  exact (gapRightFormula_spec atomMap h_surj ε (surgeredStructure M ε Q t)
    (surgeredSemanticPriorU atomMap h_surj hε h_prior_U h_prior_S hS)
    (surgeredSemanticPriorS atomMap h_surj hε h_prior_U h_prior_S hS)
    (surgeryBase M ε Q t ((hε.equiv M).refl t))).mp hN

/-- **"`R` is true of this class so that it is bounded above amongst other things. Thus `Q⁺` is
non-empty"** — printed p.182.

The first conjunct of `EndsInGapOnRight` in `N` is *"the class does not extend forever to the
right"*: some surviving point above `t` is outside the class. A surviving point outside the class
is outside `Q₀`, since the only points of `Q₀` that survive are those of `I`. -/
theorem reynolds_lemma9_exists_after (hε : IsContempEquivDense ε)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (hS : IsBadIntervalSurgery M ε Q t) :
    ∃ y : M.carrier, t < y ∧ ¬ Q y := by
  obtain ⟨y, hty, hny⟩ :=
    (reynolds_lemma9_R_in_N atomMap h_surj hε h_prior_U h_prior_S hS).1
  refine ⟨y.val, hty, fun hQ => hny ?_⟩
  exact surgeredContempEquiv_of_base hε ((hε.equiv M).refl t) (y.property.resolve_left (· hQ))

omit h_surj in
/-- **A non-bad point above `t`** — the input Lemma 6's third clause needs, extracted from
`Q⁺` being non-empty by maximality of `Q₀`. -/
theorem exists_not_isBadPoint_gt (hS : IsBadIntervalSurgery M ε Q t) {y : M.carrier}
    (hty : t < y) (hny : ¬ Q y) : ∃ u : M.carrier, t < u ∧ ¬ IsBadPoint M ε u := by
  by_contra hcon
  push_neg at hcon
  exact hny (mem_of_badStretch hS hty fun z hz _ => hcon z hz)

/-- **Reynolds 1992, §6 Lemma 9, printed p.182.**

> **LEMMA 9** *In fact there can't have been any bad points anyway.*

Stated as the reductio his proof actually runs: a bad interval carrying the surgery set-up of
Lemma 8, together with Lemma 6's first clause above `t`, is contradictory. *"There can't have been
any bad points"* is the informal reading of that — a bad point is what produces the interval.

The closing contradiction is the **third** conjunct of `EndsInGapOnRight` at `I` in `N`: that
conjunct says there is no first point after the class, and `q` is exactly one. Reynolds' *"Thus
the class ends just before `q`"* is that sentence, and his *"`R` can not have been true in this
class after all"* is the `False` this returns. -/
theorem reynolds_lemma9 (hε : IsContempEquivDense ε)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (hS : IsBadIntervalSurgery M ε Q t)
    (hbadR : ∀ q : M.carrier, t ≤ q → IsBadPoint M ε q → EndsInGapOnRight M ε q) :
    False := by
  have hgapN := reynolds_lemma9_R_in_N atomMap h_surj hε h_prior_U h_prior_S hS
  obtain ⟨y, hty, hny⟩ := reynolds_lemma9_exists_after atomMap h_surj hε h_prior_U h_prior_S hS
  -- *"Thus `Q⁺` is non-empty and by lemma 6 begins with a point `q` say."*
  obtain ⟨q, htq, hbelow, hqnb⟩ :=
    reynolds_lemma6_right_endpoint atomMap h_surj hε M h_prior_U h_prior_S
      (endsInGapOnRight_of_mem hS hS.mem) hbadR (exists_not_isBadPoint_gt hS hty hny)
  have hqQ : ¬ Q q := fun h => hqnb (hS.badPoint h)
  -- *"Also by lemma 6 `¬R` holds at `q` in `M` and so in `N`."*
  have hqnRN : ¬ EndsInGapOnRight (surgeredStructure M ε Q t) ε ⟨q, Or.inl hqQ⟩ := by
    intro hcon
    refine hqnb (IsBadPoint.of_right ?_)
    refine (gapRightFormula_spec atomMap h_surj ε M h_prior_U h_prior_S q).mp ?_
    refine (reynolds_lemma8 atomMap h_surj hε h_prior_U h_prior_S hS
      (gapRightFormula atomMap h_surj ε) ⟨q, Or.inl hqQ⟩).mpr ?_
    exact (gapRightFormula_spec atomMap h_surj ε (surgeredStructure M ε Q t)
      (surgeredSemanticPriorU atomMap h_surj hε h_prior_U h_prior_S hS)
      (surgeredSemanticPriorS atomMap h_surj hε h_prior_U h_prior_S hS)
      ⟨q, Or.inl hqQ⟩).mpr hcon
  -- *"Clearly `q` is not in the class of `I` in `N`."*
  refine hgapN.2.2 ⟨⟨q, Or.inl hqQ⟩, htq, fun hc => hqnRN ?_, ?_⟩
  · exact (endsInGapOnRight_congr hε (surgeredStructure M ε Q t) hc).mp hgapN
  -- *"Thus the class ends just before `q`"*: everything of `N` between is still in `I`.
  · intro z hz₁ hz₂
    have hzQ : Q z.val :=
      mem_of_badStretch hS hz₁ fun w hw₁ hw₂ => hbelow w hw₁ (lt_of_le_of_lt hw₂ hz₂)
    exact surgeredContempEquiv_of_base hε ((hε.equiv M).refl t)
      (z.property.resolve_left (· hzQ))

end Lemma9

/-! ## Theorem 4

> **THEOREM 4** *Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure
> `M`.*
>
> *Then the `∼`-classes do not end at gaps.*

Reynolds writes *"Thus we have proven…"* and states Theorem 4 with no further argument: Lemma 9
**is** Theorem 4, once one knows that a point whose class ends in a gap gives rise to the bad
interval Lemma 8's surgery is performed on.

**That last step is named rather than assumed away.** `HasBadIntervalSurgery` below packages it.
It was introduced as a hypothesis because the tree could not then supply it; it is **now a
theorem** — `StepD.hasBadIntervalSurgery`, below `end Theorem4` — so the analysis in the rest of
this header records why it was hard, not a standing gap. The obstruction the analysis names was
real and is now closed by `exists_classInteriorToRInterval` (`BadIntervals.lean`).

What `HasBadIntervalSurgery` asks for is not the whole of Lemma 6
but one clause: *"in any bad interval both `R` and `L` hold throughout"* (printed p.180, Lemma
6's first clause). Everything else assembles from landed material —
`reynolds_lemma4_no_last_class` supplies the upper interiority witness and
`reynolds_lemma4_no_first_class` the lower, and the bad-connected component of the point is the
maximal interval. The obstruction is exact and was measured, not guessed:

* `IsBadInterval.saturated` is stated over `IsBadPoint`, i.e. over `R ∨ L`, so the bad-connected
  component of a point is the only candidate that satisfies it;
* but `IsBadIntervalSurgery.interior` demands `ClassInteriorToBadInterval`, which carries `R`
  **and** `L` throughout its segment;
* closing that gap is the implication `L → R` at a point where only `L` is known. The landed
  `endsInGapOnRight_of_endsInGapOnLeft` (`BadIntervals.lean:1346`) proves it, but only from a
  `ClassInteriorToLInterval` witness, and producing that witness at a merely-`L` point was exactly
  what was missing.

The same clause is why `reynolds_lemma6_right_endpoint` carries its own `hbadR` hypothesis, and
why `reynolds_lemma9` above carries it too. So the gap was one gap, in one place, and it was the
same one in all three declarations.

**It is now closed.** `exists_classInteriorToRInterval` (`BadIntervals.lean`) produces the
witness, and `endsInGapOnRight_of_endsInGapOnLeft'` is the resulting hypothesis-free `L → R`. The
third bullet above is therefore a record of the obstruction, not a description of a live one. The
two remaining conditions on everything below Theorem 4 are the Prior pair and `ε`; no §6 result
may be described as discharged. See `## Conditionality after Theorem 4`. -/

section Theorem4

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}

/-- **The one input Theorem 4 still needs**: at every point whose class ends in a gap on the
right, the bad interval of Lemma 8's surgery together with Lemma 6's first clause above that
point.

This is a *hypothesis*, and naming it is the point: it is Lemma 6's first clause (*"in any bad
interval both `R` and `L` hold throughout"*, printed p.180) in the form Lemmas 6 and 9 consume,
and it is not proved anywhere in this tree. -/
structure HasBadIntervalSurgery (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) : Prop where
  /-- *"Let `Q₀` be the bad interval itself"*, at a point whose class ends in a gap. -/
  exists_surgery : ∀ t : M.carrier, EndsInGapOnRight M ε t →
    ∃ Q : M.carrier → Prop, IsBadIntervalSurgery M ε Q t ∧
      ∀ q : M.carrier, t ≤ q → IsBadPoint M ε q → EndsInGapOnRight M ε q

/-- **Reynolds 1992, §6 Theorem 4, printed p.183 — the right-hand end.**

> *Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure `M`.*
>
> *Then the `∼`-classes do not end at gaps.*

This is **D1**, the first hypothesis of Doets' theorem, in its **hypothesised** form: it takes
`HasBadIntervalSurgery` as an assumption. `no_gaps_dense_prior` below is the same statement with
that assumption discharged by `hasBadIntervalSurgery`; this form is retained unweakened for
callers that would rather supply their own surgery. -/
theorem no_gaps_dense_prior_of_hasBadIntervalSurgery (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hbi : HasBadIntervalSurgery M ε)
    (t : M.carrier) : ¬ EndsInGapOnRight M ε t := fun ht => by
  obtain ⟨Q, hS, hbadR⟩ := hbi.exists_surgery t ht
  exact reynolds_lemma9 atomMap h_surj hε h_prior_U h_prior_S hS hbadR

/-- **Theorem 4, the left-hand end** — *"the classes do not end at gaps"* covers both ends.

Obtained by instantiation at `(dual M, dualize ε)` through `Dual.lean`, not by a hand-written
mirror: `endsInGapOnRight_dual` exchanges the two gap predicates, `isContempEquivDense_dualize`
carries `ε`, and `semanticPriorU_dual` / `semanticPriorS_dual` carry the Prior pair. The
`HasBadIntervalSurgery` hypothesis is stated at the dual for the same reason — it is the one
input that does not transport for free.

The **hypothesised** form, retained unweakened; `no_gaps_dense_prior_left` below discharges it. -/
theorem no_gaps_dense_prior_left_of_hasBadIntervalSurgery (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap)
    (hbi : HasBadIntervalSurgery (dual M) (dualize ε))
    (t : M.carrier) : ¬ EndsInGapOnLeft M ε t := by
  intro ht
  exact no_gaps_dense_prior_of_hasBadIntervalSurgery (M := dual M) atomMap h_surj
    (isContempEquivDense_dualize hε)
    (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U) hbi (d t)
    ((endsInGapOnRight_dual ε t).mpr ht)

end Theorem4

/-! ## Discharging `HasBadIntervalSurgery`

`HasBadIntervalSurgery` was introduced above as a *named hypothesis* standing in for Lemma 6's
first clause. It is discharged here, outright, with no new assumption.

What made it a hypothesis was not a step Reynolds waved away — he proves Lemma 6's clause over
five paragraphs on printed p.180, and both halves have been landed in `BadIntervals.lean` since
Phases 20 and 20.4. What was missing was the *hypothesis discharge*: both landed halves consume an
interval witness, and nothing produced one. `exists_classInteriorToRInterval`
(`BadIntervals.lean`) is now that producer, and with it
`endsInGapOnLeft_of_endsInGapOnRight'` / `endsInGapOnRight_of_endsInGapOnLeft'` give Lemma 6's
first clause with no interval hypothesis at all. That, plus the observation that `Q` may be taken
to be the **bad-connected component** of `t`, is everything the surgery structure asks for.

`Btw t x q` says `q` lies weakly between `t` and `x`, in whichever order the two come; `badComp`
is the set of points `x` such that every point between `t` and `x` is bad. Convexity and
saturation of that set are immediate; the real work is `IsBadIntervalSurgery.interior`, which
needs a **single** segment straddling `p`'s class that also contains a second arbitrary component
point `u`. It is obtained by extending the `exists_classInteriorToRInterval` witness by
`min`/`max` against `u` and pulling the extension back into the component by convexity. -/

namespace StepD

section Component

variable {M : OrderedMonadicStructure sig}

/-- `q` lies weakly between `t` and `x`, in whichever order they come. -/
def Btw (t x q : M.carrier) : Prop :=
  (t ≤ q ∧ q ≤ x) ∨ (x ≤ q ∧ q ≤ t)

/-- `Btw` from the `min`/`max` bracketing that `IsBadInterval.saturated` speaks in. -/
theorem btw_of_minmax {t x q : M.carrier} (h₁ : min t x ≤ q) (h₂ : q ≤ max t x) : Btw t x q := by
  rcases le_total t x with h | h
  · rw [min_eq_left h] at h₁; rw [max_eq_right h] at h₂; exact Or.inl ⟨h₁, h₂⟩
  · rw [min_eq_right h] at h₁; rw [max_eq_left h] at h₂; exact Or.inr ⟨h₁, h₂⟩

/-- The converse bracketing. -/
theorem minmax_of_btw {t x q : M.carrier} (h : Btw t x q) : min t x ≤ q ∧ q ≤ max t x := by
  rcases h with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩
  · exact ⟨le_trans (min_le_left _ _) h₁, le_trans h₂ (le_max_right _ _)⟩
  · exact ⟨le_trans (min_le_right _ _) h₁, le_trans h₂ (le_max_left _ _)⟩

/-- Reflexivity at the far endpoint. Needs the `le_total` case split rather than `le_refl`. -/
theorem btw_self (t x : M.carrier) : Btw t x x := by
  rcases le_total t x with h | h
  · exact Or.inl ⟨h, le_refl _⟩
  · exact Or.inr ⟨le_refl _, h⟩

/-- **The bad-connected component of `t`**: the points reachable from `t` without leaving the bad
points. This is the `Q` the surgery is performed on. -/
def badComp (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2) (t x : M.carrier) : Prop :=
  ∀ q : M.carrier, Btw t x q → IsBadPoint M ε q

end Component

section Discharge

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- The bad-connected component is a bad interval: non-empty, bad throughout, convex, and
saturated. All four are read straight off `Btw`'s case structure. -/
theorem badComp_isBadInterval (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    IsBadInterval M ε (badComp M ε t) := by
  refine ⟨⟨t, fun q hq => ?_⟩, fun x hx => hx x (btw_self t x),
    fun a b c hab hbc ha hc q hq => ?_, fun a x ha hsat q hq => ?_⟩
  · rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩ <;>
      exact (le_antisymm h₂ h₁ ▸ IsBadPoint.of_right ht)
  · rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩
    · exact hc q (Or.inl ⟨h₁, le_trans h₂ hbc⟩)
    · exact ha q (Or.inr ⟨le_trans hab h₁, h₂⟩)
  · rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩
    · rcases le_total q a with h | h
      · exact ha q (Or.inl ⟨h₁, h⟩)
      · exact hsat q (minmax_of_btw (Or.inl ⟨h, h₂⟩)).1 (minmax_of_btw (Or.inl ⟨h, h₂⟩)).2
    · rcases le_total a q with h | h
      · exact ha q (Or.inr ⟨h, h₂⟩)
      · exact hsat q (minmax_of_btw (Or.inr ⟨h₁, h⟩)).1 (minmax_of_btw (Or.inr ⟨h₁, h⟩)).2

/-- **Every point of the component satisfies `R`** — *"in any bad interval both `R` and `L` hold
throughout"*, printed p.180. A component point is bad, so it satisfies `R` or `L`; in the `L` case
`endsInGapOnRight_of_endsInGapOnLeft'` supplies `R`. This is the implication that was missing, and
it is exactly Lemma 6's first clause in its hypothesis-free form. -/
theorem badComp_right (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t x : M.carrier} (hx : badComp M ε t x) :
    EndsInGapOnRight M ε x := by
  rcases hx x (btw_self t x) with h | h
  · exact h
  · exact endsInGapOnRight_of_endsInGapOnLeft' atomMap h_surj hε M h_prior_U h_prior_S h

/-- **`HasBadIntervalSurgery` holds outright**, with `Q` the bad-connected component of `t`.

The `interior` field is the only real work. Given a component point `p` and a second arbitrary
component point `u`, `exists_classInteriorToRInterval` supplies `a₀ < p < b₀` outside `p`'s class
with `R` throughout `[a₀, b₀]`; saturation puts `a₀` and `b₀` themselves in the component; and
`min a₀ u`, `max b₀ u` then straddle `p`'s class while bracketing `u`, with the whole segment
pulled back into the component by convexity.

Note that the `left_out` and `right_out` branches are **not** symmetric in this rendering: the
lower one needs the `contemp_trans` / `contemp_symm` wrapper and the upper one applies
`contemp_of_between` directly. -/
theorem hasBadIntervalSurgery (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) :
    HasBadIntervalSurgery M ε := by
  refine ⟨fun t ht => ⟨badComp M ε t, ⟨?_, ?_, ?_⟩, ?_⟩⟩
  · exact badComp_isBadInterval atomMap h_surj hε M h_prior_U h_prior_S ht
  · intro q hq
    rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩ <;> exact (le_antisymm h₂ h₁ ▸ IsBadPoint.of_right ht)
  · -- `interior`
    intro p u hp hu
    have hbi := badComp_isBadInterval atomMap h_surj hε M h_prior_U h_prior_S ht
    have hRp : EndsInGapOnRight M ε p :=
      badComp_right atomMap h_surj hε M h_prior_U h_prior_S hp
    obtain ⟨a₀, b₀, hint⟩ :=
      exists_classInteriorToRInterval atomMap h_surj hε M h_prior_U h_prior_S hRp
    -- the two `R`-interval endpoints are themselves in the component
    have ha₀ : badComp M ε t a₀ := by
      refine hbi.saturated p a₀ hp (fun q h₁ h₂ => ?_)
      rw [min_eq_right hint.left_lt.le] at h₁
      rw [max_eq_left hint.left_lt.le] at h₂
      exact IsBadPoint.of_right (hint.rThroughout q h₁ (le_trans h₂ hint.lt_right.le))
    have hb₀ : badComp M ε t b₀ := by
      refine hbi.saturated p b₀ hp (fun q h₁ h₂ => ?_)
      rw [min_eq_left hint.lt_right.le] at h₁
      rw [max_eq_right hint.lt_right.le] at h₂
      exact IsBadPoint.of_right (hint.rThroughout q (le_trans hint.left_lt.le h₁) h₂)
    refine ⟨min a₀ u, max b₀ u, min_le_right _ _, le_max_right _ _, ?_⟩
    have hamem : badComp M ε t (min a₀ u) := by
      rcases min_cases a₀ u with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h] <;> assumption
    have hbmem : badComp M ε t (max b₀ u) := by
      rcases max_cases b₀ u with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h] <;> assumption
    have hseg : ∀ q : M.carrier, min a₀ u ≤ q → q ≤ max b₀ u → badComp M ε t q :=
      fun q h₁ h₂ => hbi.convex _ _ _ h₁ h₂ hamem hbmem
    have hal : min a₀ u < p := lt_of_le_of_lt (min_le_left _ _) hint.left_lt
    have hbr : p < max b₀ u := lt_of_lt_of_le hint.lt_right (le_max_left _ _)
    refine ⟨⟨hal, hbr, ?_, ?_, fun q h₁ h₂ =>
        badComp_right atomMap h_surj hε M h_prior_U h_prior_S (hseg q h₁ h₂)⟩,
      fun q h₁ h₂ => endsInGapOnLeft_of_endsInGapOnRight' atomMap h_surj hε M h_prior_U h_prior_S
        (badComp_right atomMap h_surj hε M h_prior_U h_prior_S (hseg q h₁ h₂))⟩
    · intro hc
      exact hint.left_out (contemp_trans hε M hc
        (contemp_of_between hε M (min_le_left a₀ u) hint.left_lt.le (contemp_symm hε M hc)))
    · intro hc
      exact hint.right_out (contemp_of_between hε M hint.lt_right.le (le_max_left b₀ u) hc)
  · intro q _ hq
    rcases hq with h | h
    · exact h
    · exact endsInGapOnRight_of_endsInGapOnLeft' atomMap h_surj hε M h_prior_U h_prior_S h

end Discharge

end StepD

section Theorem4Unconditional

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}

/-- **Reynolds 1992, §6 Theorem 4, printed p.183 — the right-hand end.**

> *Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure `M`.*
>
> *Then the `∼`-classes do not end at gaps.*

This is **D1**, the first hypothesis of Doets' theorem, with `HasBadIntervalSurgery` discharged by
`StepD.hasBadIntervalSurgery`. `no_gaps_dense_prior_of_hasBadIntervalSurgery` above is the same
statement in its hypothesised form and is retained unweakened.

**Still conditional**, and not on nothing: `IsContempEquivDense ε` and Prior-U/Prior-S remain
hypotheses. See `## Conditionality after Theorem 4` below for exactly what that leaves standing. -/
theorem no_gaps_dense_prior (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) : ¬ EndsInGapOnRight M ε t :=
  no_gaps_dense_prior_of_hasBadIntervalSurgery atomMap h_surj hε h_prior_U h_prior_S
    (StepD.hasBadIntervalSurgery atomMap h_surj hε M h_prior_U h_prior_S) t

/-- **Theorem 4, the left-hand end**, with `HasBadIntervalSurgery` discharged — at the dual, by
`StepD.hasBadIntervalSurgery` instantiated at `(dual M, dualize ε)`. The one input that did not
transport for free now needs no transporting: it is a theorem at every structure.

`no_gaps_dense_prior_left_of_hasBadIntervalSurgery` above is retained unweakened. -/
theorem no_gaps_dense_prior_left (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) : ¬ EndsInGapOnLeft M ε t :=
  no_gaps_dense_prior_left_of_hasBadIntervalSurgery atomMap h_surj hε h_prior_U h_prior_S
    (StepD.hasBadIntervalSurgery atomMap h_surj (isContempEquivDense_dualize hε) (dual M)
      (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U)) t

end Theorem4Unconditional

/-! ## Conditionality after Theorem 4

Theorem 4 stood on **three** conditions. Their status is now different from one another, and the
accounting below is the whole of it. **The standing §6 caveat is not retired.**

**Condition one — `HasBadIntervalSurgery`: fully gone.** This was the third condition, introduced
by this module as a named hypothesis standing in for Lemma 6's first clause. It is now a theorem —
`StepD.hasBadIntervalSurgery`, above — holding at every structure with no extra assumption, so
`no_gaps_dense_prior` and `no_gaps_dense_prior_left` no longer carry it. The hypothesised forms
are retained unweakened as `no_gaps_dense_prior_of_hasBadIntervalSurgery` and
`no_gaps_dense_prior_left_of_hasBadIntervalSurgery`.

**Correcting the record about Reynolds.** An earlier version of this section said that his Lemma 6
*"states the clause and he takes it as established"*. **That is wrong**, and it mislocated the
gap. Reynolds gives a five-paragraph proof on printed p.180, with an explicit three-case analysis
and an explicit Prior-U contradiction, and **both halves of the clause have been landed in this
tree since Phases 20 and 20.4** (`endsInGapOnLeft_of_endsInGapOnRight` and
`endsInGapOnRight_of_endsInGapOnLeft`, `BadIntervals.lean`). What was actually missing was the
**hypothesis discharge**: both landed halves consume a `ClassInteriorToRInterval` /
`ClassInteriorToLInterval` witness and nothing in the tree produced one, on either side. That
producer is now `exists_classInteriorToRInterval`. It in turn needed the **repaired** reading of
Reynolds' Lemma 4 display — see the *"Lemma 4 at the boundary"* section of `Lemma34.lean` for the
one-symbol defect in the source, whose it is, and what the repair is.

**Condition two — the structure (Prior-U / Prior-S): gone at one named structure, standing in
general.** These remain hypotheses of every declaration in this file, as they must, since the file
is parametric in `M`. `ChronicleInstance.lean` discharges them at
`chronicleIsDensePriorSepStructure`, which is the structure the completeness route actually runs
on. Note that the reason that instantiation lives in a separate module is **layering, not
cyclicity**: the earlier claim in this section that *"`ChronicleMonadicBridge` imports
`WeakCanonical`, so a module under `WeakCanonical/DenseModelSurgery/` cannot import it back"* is
**refuted** against the actual transitive closure — the bridge imports zero `DenseModelSurgery`
modules and this file imports zero `BXCanonical` modules. The import would be legal; it is
declined because it would make a low-level parametric §6 module depend on a 280-module cone.

**Condition three — `ε`: standing, unchanged.** *"The only `ε` this tree can exhibit satisfying
`IsContempEquivDense` is `epsTop`, for which `EndsInGapOnRight` is empty"* (`Defs.lean`'s
`isContempEquivDense_epsTop` and `not_endsInGapOnRight_epsTop`). **Nothing above changes this.**
There is still **no live non-trivial instance** of anything in `Lemma5.lean`,
`BadIntervals.lean`, `Dual.lean`, `TruthTransfer.lean`, `ChronicleInstance.lean` or this file, and
an instantiation at `epsTop` is vacuous rather than an anti-vacuity witness. Reynolds' actual `ε`,
the one that defines `∼_M`, is §8 Lemma 12 and is not yet in this tree.

**What this module establishes, unconditionally in its own hypotheses.** `reynolds_lemma9` is
sorry-free and axiom-clean: given the surgery set-up and Lemma 6's first clause, a class ending in
a gap is contradictory. `StepD.hasBadIntervalSurgery` is sorry-free and axiom-clean and needs no
hypothesis beyond `IsContempEquivDense ε` and the Prior pair. `surgeredSemanticPriorU` /
`surgeredSemanticPriorS` are sorry-free with no extra hypothesis at all beyond Lemma 8's — *"`N`
is a Prior structure"*, the step `TruthTransfer` left open, is fully discharged.

**So: the §6 conditionality caveat stays, verbatim, in every module header that carries it** —
`Lemma5.lean`, `BadIntervals.lean`, `Dual.lean`, `TruthTransfer.lean` and this file. Halves one
and two of that caveat are unchanged text. Only the *third* condition is retired, and only the
*structure* half is retired at a single named structure. **No §6 result below Lemma 2 may be
described as discharged.** -/

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
