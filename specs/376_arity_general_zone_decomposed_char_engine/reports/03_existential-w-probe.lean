import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Existential-`w` / single-witness completeness seam — certification probe

Certifies (or refutes) the reports/02 recommended successor: re-sign Block A (the completeness
`↔`, `hcharFib`) from its `∀ w, render(w) → iff_at(w)` form to a **single-witness / existential**
form so the biconditional is asserted only at the ONE render witness `w` that `step_complete`
actually destructures (`InteriorGateGeneralK.lean:1785,1799`), not at ALL `w`.

The hope (reports/02 §"Candidate re-research directions" #1): `step_complete` is internally
single-`w`, so the cross-render refutation of the `∀ w` form (`reports/02_split-seam-probe.lean`,
`unguardedBlockA_crossRender_refutation`) cannot fire — only one `w` is in scope, so the diagonal
collision `w0 ≠ w'` cannot be built.

## What this probe establishes

1. `crossRender_from_two_iffs` (sorry-free): the reports/02 diagonal refutation, restated with the
   iff supplied at TWO explicit render points (not a `∀ w` binder). This is the collision the
   single-`w` form supposedly blocks.

2. `existentialSeam_refuted_of_render_symmetry` (sorry-free): **the surviving refutation.** The
   single-`w` form supplies `iff_at(w0)` at ONE render `w0`. But the seam quantifies over ALL
   `M : OrderedMonadicStructure sig`, INCLUDING order-homogeneous ones. In a homogeneous `M` an
   order-automorphism `α` fixing the anchors `x,t` with `α(w0)=w'` (a SECOND render, `w'≠w0`)
   TRANSPORTS `iff_at(w0)` to `iff_at(w')` (`temporal_truth` of the fixed formula `charFib σ` and
   `nf_eval_nf` are both automorphism-invariant). The two transported iffs then collide via
   `crossRender_from_two_iffs`. The `∀→∃` weakening buys NOTHING: homogeneity's render-symmetry
   re-supplies the second iff for free, under the SAME residual assumption reports/02 already
   isolated (the `(ℚ,<)` automorphism-invariance leg).

3. `existentialSeam_form_refuted` (sorry-free): the packaged `∃ w, render(w) ∧ iff_at(w)` seam
   form is FALSE given a render-symmetry supplier — the direct refutation of the candidate.

4. `existentialW_step_complete_elaborates` (elaboration artifact, `sorry`-bodied by design): the
   exact re-signed `step_complete` signature with the existential seam folded into the antecedent.
   It ELABORATES in the production context — the artifact bar for "the exact re-signed statement".

The render-symmetry transport hypothesis (`htransport`) is the automorphism-invariance leg. Like
reports/02's `hchar_eq` non-vacuity, it is DISCLOSED as the single non-compiled assumption; it is
discharged by the `(ℚ,<)` order-automorphism fixing `(-∞,t]` and moving `w0↦w'`, exactly the
witness reports/02 §"Non-vacuity" already argued lives inside the seam's `∀ M` range.

Purely additive specs-side probe; no production file touched. Compiled via `lake env lean`. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **The cross-render collision, decoupled from the `∀ w` binder.** If the completeness iff holds
    at TWO distinct render points `w0 ≠ w'` (relative to the same anchors `x,t`), for the SAME
    `charFib` family, then `False`. Sorry-free re-statement of reports/02 `Theorem 1`, with the
    two iff instances supplied explicitly rather than extracted from a `∀ w, render → iff` binder.
    Mechanism verbatim: diagonal fiber `σ* := char[w',w0,x,t]`, shared point `u := w'`. -/
theorem crossRender_from_two_iffs {sig : MonadicSignature} {k : Nat}
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
    False := by
  set σstar : NormalForm sig (k + 1) 4 :=
    nf_characteristic M (k + 1) 4 (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) with hσdef
  have hσsat : nf_eval_nf M (k + 1) 4
      (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) σstar :=
    nf_characteristic_satisfies M (k + 1) 4 _
  -- iff at w0, .mpr at (σ*, u:=w'): RHS is σ* at its own tuple = TRUE ⟹ truth(w', charFib σ*).
  have htruth : temporal_truth M atomMap w' (charFib (k + 1) σstar) :=
    (iff_w0 σstar w').mpr hσsat
  -- iff at w', .mp at (σ*, u:=w'): truth ⟹ σ* realized over the diagonal [w',w',x,t].
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

/-- **The surviving refutation of the existential-`w` seam.** The single-witness form supplies the
    completeness iff at ONE render `w0` (`iff_w0`). In an order-homogeneous `M` inside the seam's
    `∀ M` range, an automorphism fixing `x,t` and moving `w0` to a DISTINCT render `w'` transports
    `iff_at(w0)` to `iff_at(w')` (`htransport`) — because `temporal_truth` of the fixed formula
    `charFib σ` and `nf_eval_nf` are automorphism-invariant. The two collide.

    `htransport` is the render-symmetry / automorphism-invariance leg: the SAME residual reports/02
    isolated (`(ℚ,<)` automorphism moving `w0↦w'` fixing `(-∞,t]`). No NEW assumption is required —
    the `∀→∃` weakening does not reduce the burden. -/
theorem existentialSeam_refuted_of_render_symmetry {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier) (hne : w' ≠ w0)
    (iff_w0 : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      temporal_truth M atomMap u (charFib (k + 1) σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ)
    (htransport :
      (∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ) →
      (∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w' (Fin.cons x (fun _ => t)))) σ)) :
    False :=
  crossRender_from_two_iffs atomMap charFib M x t w0 w' hne iff_w0 (htransport iff_w0)

/-- **The packaged existential seam form is FALSE under render-symmetry.** The candidate seam
    `∃ w, render(w) ∧ iff_at(w)` (with `render` the depth-`(k+2)` realizer of `qnf`), given a
    render-symmetry supplier `hSym` (for any render `w`, a DISTINCT render `w2` exists and the
    completeness iff transports from `w` to `w2`), reduces to `False`. This is the direct
    refutation of the reports/02 successor candidate. -/
theorem existentialSeam_form_refuted {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (qnf : NormalForm sig (k + 2) 3)
    -- the candidate existential seam: SOME render witness carries the completeness iff.
    (hExist : ∃ w : M.carrier,
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf ∧
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- render-symmetry (automorphism-invariance leg): every render has a distinct render partner
    -- to which the completeness iff transports. Discharged by the (ℚ,<) automorphism (reports/02).
    (hSym : ∀ w : M.carrier,
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∃ w2 : M.carrier, w2 ≠ w ∧
        ((∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
          temporal_truth M atomMap u (charFib (k + 1) σ) ↔
            nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
         (∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
          temporal_truth M atomMap u (charFib (k + 1) σ) ↔
            nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w2 (Fin.cons x (fun _ => t)))) σ))) :
    False := by
  obtain ⟨w0, hr0, iff_w0⟩ := hExist
  obtain ⟨w', hne, htr⟩ := hSym w0 hr0
  exact crossRender_from_two_iffs atomMap charFib M x t w0 w' hne iff_w0 (htr iff_w0)

/-- **Elaboration artifact (the exact re-signed Block A statement).** The existential-`w`
    `step_complete` folds the former `∃ w, render(w)` antecedent and the separate
    `hcharFib : ∀ w, render → iff` binder into a SINGLE existential antecedent carrying the iff at
    the witness. `step_complete`'s body destructures it (`rintro ⟨w, hw, hchar⟩`) and every one of
    the 14 downstream `hchar σ _` uses — including the 7 exclusion sites (IGGK:1932,1946,1968,1984,
    2009,2022,2046) — is verbatim, because the destructured `hchar` has the SAME type as the former
    `have hchar := hcharFib w hw` (IGGK:1799, the seam's ONLY use). Body is `sorry` HERE by design:
    this artifact certifies the signature ELABORATES in the production context (the stated bar);
    it is NOT part of the sorry-free refutation above. -/
example {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    -- existential-`w` seam: SINGLE combined antecedent (render ∧ iff at the witness `w`).
    (hSeam : ∃ w : M.carrier,
      nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf ∧
      ∀ (σ : NormalForm sig k 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib k σ) ↔
          nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
