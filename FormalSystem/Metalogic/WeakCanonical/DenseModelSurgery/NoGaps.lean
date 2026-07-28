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
| *"Thus `Q⁺` is non-empty"* | `reynolds_lemma9_exists_after` |
| *"and by lemma 6 begins with a point `q`"*, *"`¬R` holds at `q`"* | `reynolds_lemma6_right_endpoint` |
| *"Clearly `q` is not in the class of `I` in `N`. Thus the class ends just before `q`"* | `reynolds_lemma9_first_after_not_gap` |
| **LEMMA 9** itself | `reynolds_lemma9` |
| **THEOREM 4** | `no_gaps_dense_prior` |

## Honest caveat on conditionality — what this module does and does not retire

See `## Conditionality after Theorem 4` at the foot of this file. The short form: this module
retires the **structure** half of the standing §6 caveat and does **not** retire the **`ε`**
half. Read that section before describing any §6 result as discharged.
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

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
