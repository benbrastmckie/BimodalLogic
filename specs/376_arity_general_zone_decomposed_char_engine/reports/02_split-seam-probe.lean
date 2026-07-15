import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Split-seam certification probe — is UNGUARDED Block A refutation-safe on completeness?

Certifies (or refutes) the Phase-2 SPLIT-SEAM recommendation: guard ONLY Block B
(soundness, `hcharFibSoundP` → `hcharFibZoneSound`) and revert Block A (the completeness
`↔`, `hcharFib`) to its ORIGINAL, fully UNGUARDED form (`ExteriorGateAssembleK.lean:574-578`).

The Phase-1 probe (`SeamPairRefutationProbe.lean`) only refuted the SOUNDNESS transport. This
file asks the untested question: does an unguarded Block A admit a COMPLETENESS-side refutation?

## The abstract cross-render refutation (Theorem 1)

`hcharFib` (EGA:574-578) is `∀ w, nf_eval[w,x,t] qnf → ∀ σ u, truth(u, charFib σ) ↔
nf_eval[u,w,x,t] σ`. Its ONLY guard is the render premise on `w`. Because `charFib σ` is a
Formula whose truth at `u` is INDEPENDENT of `w`, firing the ↔ at two DISTINCT points `w0 ≠ w'`
that BOTH render `qnf` forces `nf_eval[u,w0,x,t] σ ↔ nf_eval[u,w',x,t] σ` for every `σ, u` —
which is false for the "diagonal" fiber `σ* := char[w',w0,x,t]` at `u := w'`. This is the exact
same cross-`w` transport mechanism the Phase-1 soundness refutation exploited, now re-entering
through completeness because Block A is unguarded.

The asymmetry with the soundness refutation: `hcharFibSoundP`'s `w` was render-FREE (so the old
probe used `w' = 3` freely); `hcharFib`'s `w` carries a render premise, so BOTH `w0` and `w'`
must render `qnf`. Theorem 1 takes both renders as hypotheses. Non-vacuity — whether two
distinct points CAN render one `qnf` — is discussed in the report (it holds in any
order-homogeneous structure, e.g. `(ℚ,<)`, which is a valid `OrderedMonadicStructure`).

Purely additive specs-side probe; no production file touched. Compiled via `lake env lean`. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **Theorem 1 — UNGUARDED Block A is refuted by cross-render transport.**
    The original unguarded completeness seam `hcharFib` (binder byte-faithful to
    `ExteriorGateAssembleK.lean:574-578`) is FALSE at any model with two DISTINCT points
    `w0 ≠ w'` that both render the SAME `qnf`. For EVERY `charFib` family and every `atomMap`.

    Mechanism: fire the ↔ at `(w0, σ*, w')` and at `(w', σ*, w')` with the diagonal fiber
    `σ* := char[w', w0, x, t]` and shared evaluation point `u := w'`. The `w`-independent LHS
    `truth(w', charFib σ*)` is forced TRUE by the first (its RHS is `σ*` at its own tuple) and
    FALSE by the second (`σ*`'s order bit `(w' ? w0)` cannot hold over `[w', w', x, t]`). -/
theorem unguardedBlockA_crossRender_refutation {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier) (hne : w' ≠ w0)
    (qnf : NormalForm sig (k + 2) 3)
    (hr0 : nf_eval_nf M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t))) qnf)
    (hr' : nf_eval_nf M (k + 2) 3 (Fin.cons w' (Fin.cons x (fun _ => t))) qnf)
    -- Block A, UNGUARDED (byte-faithful to EGA:574-578):
    (hcharFib : ∀ (w : M.carrier),
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    False := by
  -- σ* := the characteristic fiber of the diagonal tuple [w', w0, x, t].
  set σstar : NormalForm sig (k + 1) 4 :=
    nf_characteristic M (k + 1) 4 (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) with hσdef
  have hσsat : nf_eval_nf M (k + 1) 4
      (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) σstar :=
    nf_characteristic_satisfies M (k + 1) 4 _
  -- (A) Block A at w := w0, u := w', .mpr: charFib σ* is true at w' (RHS is σ* at its own tuple).
  have htruth : temporal_truth M atomMap w' (charFib (k + 1) σstar) :=
    (hcharFib w0 hr0 σstar w').mpr hσsat
  -- (B) Block A at w := w', u := w', .mp: σ* must be realized over [w', w', x, t].
  have hbad : nf_eval_nf M (k + 1) 4
      (Fin.cons w' (Fin.cons w' (Fin.cons x (fun _ => t)))) σstar :=
    (hcharFib w' hr' σstar w').mp htruth
  -- (C) Atom-layer contradiction: σ*'s (0<1)/(1<0) bits are (w'<w0)/(w0<w'); over [w',w',x,t]
  --     both evaluate to w' < w', impossible for the true one.
  have hatomsD : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons w' (Fin.cons w0 (Fin.cons x (fun _ => t)))) a ↔
        σstar.atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hσsat
  have hatomsB : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons w' (Fin.cons w' (Fin.cons x (fun _ => t)))) a ↔
        σstar.atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hbad
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · -- w' < w0: σ*'s (0<1) bit is true (w' < w0); over [w',w',x,t] it demands w' < w'.
    have hbit : σstar.atom_assgn (.order (0 : Fin 4) (1 : Fin 4) (by decide)) = true := by
      apply (hatomsD _).mp
      simpa [atom_eval, Fin.cons_zero, Fin.cons_one] using hlt
    have h0 := (hatomsB _).mpr hbit
    simp only [atom_eval, Fin.cons_zero, Fin.cons_one] at h0
    exact lt_irrefl w' h0
  · -- w0 < w': σ*'s (1<0) bit is true (w0 < w'); over [w',w',x,t] it demands w' < w'.
    have hbit : σstar.atom_assgn (.order (1 : Fin 4) (0 : Fin 4) (by decide)) = true := by
      apply (hatomsD _).mp
      simpa [atom_eval, Fin.cons_zero, Fin.cons_one] using hgt
    have h0 := (hatomsB _).mpr hbit
    simp only [atom_eval, Fin.cons_zero, Fin.cons_one] at h0
    exact lt_irrefl w' h0

/-- **Theorem 2 — the refutation reduced to its SOLE remaining assumption.**
    The unguarded Block A seam is False as soon as two DISTINCT points `w0 ≠ w'` share a
    depth-`(k+2)` characteristic 3-type relative to the SAME anchors `[x, t]`
    (`hchar_eq`). Everything else is compiled: the two renders are `nf_characteristic_satisfies`
    (directly at `w0`; transported along `hchar_eq` at `w'`), and Theorem 1 closes it.

    `hchar_eq` — "two interior points with equal characteristic type at fixed `[x,t]`" — is
    exactly Gap A / order-homogeneity (research report §Q2.2). It holds in any order-homogeneous
    `OrderedMonadicStructure` (e.g. `(ℚ,<)`: an automorphism fixing `(-∞,t]` and moving `w0↦w'`
    exists; `nf_characteristic` is automorphism-invariant). Since `correct_prior`/`step_complete`
    quantify `hcharFib` over ALL `M : OrderedMonadicStructure sig`, and homogeneous structures lie
    in that class, this hypothesis is genuinely satisfiable — Theorem 1 is NOT vacuous. -/
theorem unguardedBlockA_refuted_of_char_eq {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier) (hne : w' ≠ w0)
    (hchar_eq :
      nf_characteristic M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t))) =
        nf_characteristic M (k + 2) 3 (Fin.cons w' (Fin.cons x (fun _ => t))))
    (hcharFib : ∀ (w : M.carrier),
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf_characteristic M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t)))) →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    False := by
  -- Render at w0: directly by nf_characteristic_satisfies.
  have hr0 : nf_eval_nf M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t)))
      (nf_characteristic M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t)))) :=
    nf_characteristic_satisfies M (k + 2) 3 _
  -- Render at w': char[w',x,t] renders at w', and char[w',x,t] = char[w0,x,t] by hchar_eq.
  have hr' : nf_eval_nf M (k + 2) 3 (Fin.cons w' (Fin.cons x (fun _ => t)))
      (nf_characteristic M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t)))) := by
    rw [hchar_eq]; exact nf_characteristic_satisfies M (k + 2) 3 _
  exact unguardedBlockA_crossRender_refutation atomMap charFib M x t w0 w' hne
    (nf_characteristic M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t)))) hr0 hr' hcharFib

end Bimodal.Metalogic.WeakCanonical.Kamp
