import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK
import Bimodal.Metalogic.WeakCanonical.StaviConnectives

/-! # Is the seam refutation the U/S expressive gap? — language-independence probe

Tests the orchestrator's reframing hypothesis: *"the (ℚ,<) obstruction that kills all three seam
designs is EXACTLY the classical setting where Since/Until is expressively incomplete without
Stavi operators; the honest fix is to add Stavi connectives."*

This probe **REFUTES** that hypothesis, by compilation.

## The argument, in one line

The reports/02+03 refutation never inspects the object language. It uses
`temporal_truth M atomMap u (charFib (k+1) σ)` as an OPAQUE proposition indexed by `(u, σ)`.
Generalize that opaque proposition to an arbitrary `truth : M.carrier → NormalForm sig (k+1) 4 →
Prop` and the SAME proof goes through (`crossRender_languageIndependent`). So the refutation is
independent of which temporal language `charFib` lands in — U/S, U/S+Stavi, or anything else.

An expressive-completeness gap is, by definition, a statement ABOUT a language (some property is
not expressible in {U,S} but is in {U,S,U',S'}). A refutation that never mentions the language
cannot be that gap. `staviSeam_refuted` makes this concrete: instantiating at the repo's OWN
Stavi semantics (`stavi_temporal_truth`, `StaviConnectives.lean:157`) with an ARBITRARY
Stavi-valued char engine `charStavi` kills the seam identically.

## Why: the obstruction is ARITY, not expressiveness

`truth : M.carrier → NormalForm → Prop` takes ONE point. `nf_eval_nf M _ 4 [u,w,x,t] σ` takes
FOUR. The seam demands the 1-ary object equal the 4-ary object's fiber at parameters `(w,x,t)`.
The type of `truth` has no `w` slot to vary in — that is the whole refutation, and it is visible
in the TYPE, before any semantics is chosen. `stavi_temporal_truth` has the same one-point type
(`... (t : M.carrier) : StaviFormula → Prop`), so Stavi changes nothing here.

Adding connectives enriches WHICH 1-ary sets are definable. It never adds a parameter slot. No
connective can make a parameter-free formula's truth-set track a parameter it does not mention.

Purely additive specs-side probe; no production file touched. Compiled via `lake env lean`. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **The refutation, with the object language removed entirely.**

    `truth` is an arbitrary point-indexed semantics for the char family: it stands for
    `temporal_truth M atomMap u (charFib (k+1) σ)`, but here it is OPAQUE — no constructor, no
    connective, no truth clause is available. The reports/02 diagonal collision still fires.

    Note the hypotheses: an arbitrary `M : OrderedMonadicStructure sig` (= `MonadicStructure` +
    `LinearOrder`, `MonadicFO.lean:103-104`) and two distinct points. **No density, no gaps, no
    Dedekind (in)completeness, no homogeneity** appears anywhere. Gappedness — the entire subject
    of the U/S insufficiency result (Gabbay-Hodkinson-Reynolds 1993, Lemma 3, p.97) — is not a
    hypothesis of this theorem and plays no role in its proof. -/
theorem crossRender_languageIndependent {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier) (hne : w' ≠ w0)
    (truth : M.carrier → NormalForm sig (k + 1) 4 → Prop)
    (iff_w0 : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      truth u σ ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ)
    (iff_w' : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      truth u σ ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w' (Fin.cons x (fun _ => t)))) σ) :
    False := by
  set σstar : NormalForm sig (k + 1) 4 :=
    nf_characteristic M (k + 1) 4 (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) with hσdef
  have hσsat : nf_eval_nf M (k + 1) 4
      (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) σstar :=
    nf_characteristic_satisfies M (k + 1) 4 _
  have htruth : truth w' σstar := (iff_w0 σstar w').mpr hσsat
  have hbad : nf_eval_nf M (k + 1) 4
      (Fin.cons w' (Fin.cons w' (Fin.cons x (fun _ => t)))) σstar :=
    (iff_w' σstar w').mp htruth
  have hatomsD : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) a ↔
        σstar.atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hσsat
  have hatomsB : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons w' (Fin.cons w' (Fin.cons x (fun _ => t)))) a ↔
        σstar.atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hbad
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · have hbit : σstar.atom_assgn (.order (0 : Fin 4) (1 : Fin 4) (by decide)) = true := by
      apply (hatomsD _).mp
      simpa [atom_eval, Fin.cons_zero, Fin.cons_one] using hlt
    have h0 := (hatomsB _).mpr hbit
    simp only [atom_eval, Fin.cons_zero, Fin.cons_one] at h0
    exact lt_irrefl w' h0
  · have hbit : σstar.atom_assgn (.order (1 : Fin 4) (0 : Fin 4) (by decide)) = true := by
      apply (hatomsD _).mp
      simpa [atom_eval, Fin.cons_zero, Fin.cons_one] using hgt
    have h0 := (hatomsB _).mpr hbit
    simp only [atom_eval, Fin.cons_zero, Fin.cons_one] at h0
    exact lt_irrefl w' h0

/-- **Faithfulness check.** The reports/03 `crossRender_from_two_iffs` is EXACTLY the
    `truth := fun u σ => temporal_truth M atomMap u (charFib (k+1) σ)` instance of the
    language-independent theorem. So the generalization above is not a weaker cousin of the
    refutation — it IS the refutation, with an unused parameter exposed. -/
theorem crossRender_plainUS {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier) (hne : w' ≠ w0)
    (iff_w0 : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      temporal_truth M atomMap u (charFib (k + 1) σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ)
    (iff_w' : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      temporal_truth M atomMap u (charFib (k + 1) σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w' (Fin.cons x (fun _ => t)))) σ) :
    False :=
  crossRender_languageIndependent M x t w0 w' hne
    (fun u σ => temporal_truth M atomMap u (charFib (k + 1) σ)) iff_w0 iff_w'

/-- **THE DELIVERABLE: adding Stavi connectives does NOT rescue the seam.**

    Suppose we grant the scope change the hypothesis proposes: re-target the char engine at the
    Stavi-extended object language, so `charStavi` produces a `StaviFormula` (`U'`/`S'` available,
    `StaviConnectives.lean:135`) and the seam's LHS is the repo's own Stavi semantics
    `stavi_temporal_truth` (`StaviConnectives.lean:157`). `charStavi` is ARBITRARY here — this
    covers every possible Stavi-valued char engine, including any not yet written.

    The seam dies at exactly the same diagonal, by the same proof.

    Reason, visible in the type: `stavi_temporal_truth M atomMap u : StaviFormula → Prop` is
    indexed by ONE point `u`, exactly like `temporal_truth`. The Stavi connectives add expressive
    power *within* the 1-ary fragment; they do not add the `w` slot the seam needs. -/
theorem staviSeam_refuted {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (charStavi : (j : Nat) → NormalForm sig j 4 → StaviFormula)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier) (hne : w' ≠ w0)
    (iff_w0 : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      stavi_temporal_truth M atomMap u (charStavi (k + 1) σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ)
    (iff_w' : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      stavi_temporal_truth M atomMap u (charStavi (k + 1) σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w' (Fin.cons x (fun _ => t)))) σ) :
    False :=
  crossRender_languageIndependent M x t w0 w' hne
    (fun u σ => stavi_temporal_truth M atomMap u (charStavi (k + 1) σ)) iff_w0 iff_w'

end Bimodal.Metalogic.WeakCanonical.Kamp
