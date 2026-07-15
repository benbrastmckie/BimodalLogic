import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Task 376 — Routes A/B viability probe

Answers the decisive question posed to this dispatch: **would `w`-indexing the char engine
(Route A) break the reports/03 pincer, or does the anchor-fixing automorphism simply re-run
against the `w`-indexed version?**

## What this probe establishes

1. `anchorMove_refutes_any_charEngine` (sorry-free): **the strengthened, engine-agnostic
   refutation.** Given an anchor-fixing automorphism `α` (fixes `x,t`, moves `w0 ↦ w'`), NO
   family `charEngine : NormalForm sig (k+1) 4 → Formula` — *whatever it is, however it was
   built, from whatever data* — can satisfy the completeness iff at `w0`. This needs only ONE
   iff (reports/02 `Theorem 1` needed TWO), because the automorphism moves the anchor on the
   SEMANTIC side and the engine never enters the argument.

2. `wIndexedSeam_refuted` (sorry-free): **the direct answer — Route A is futile.** The
   `w`-INDEXED seam `∀ w, render(w) → ∀ σ u, truth(u, charFibW w σ) ↔ nf_eval[u,w,x,t] σ`
   is FALSE, for an ARBITRARY `charFibW : M.carrier → NormalForm sig (k+1) 4 → Formula`. It is
   refuted by the SAME automorphism, under the SAME residual assumption. `w`-indexing changes
   WHICH formula the engine emits per render; the refutation never inspects the formula.

3. `wIndexedSeam_refuted_with_render_guard` (sorry-free): guarding the `w`-indexed seam behind
   `render(w)` does not help either — only `w0` need render; `w'` is never required to.

## Why `w`-indexing cannot work — the invariant the probe exposes

A formula is a syntactic object with no free variables and no constants naming points. Its
truth-set `{u | truth(u, φ)}` is therefore invariant under EVERY automorphism of `M`. The set
`{u | nf_eval[u,w,x,t] σ}` is the `w`-fiber, and `α` (fixing `x,t`) maps the `w0`-fiber onto
the `w'`-fiber. Asking a formula to define the `w0`-fiber asks an `α`-invariant set to equal an
`α`-non-invariant one.

Indexing the ENGINE by `w` supplies a different formula per render — but each individual
formula still has an `α`-invariant truth-set, and the seam demands that THAT formula's truth-set
be the `w0`-fiber. So the obstruction is untouched: it lives on the `nf_eval` side, not the
`charFib` side. Formally, `anchorMove_refutes_any_charEngine` quantifies over `charEngine`
UNIVERSALLY and never destructures it; `wIndexedSeam_refuted` is a one-line corollary,
instantiating `charEngine := charFibW w0`.

## Residual (disclosed, unchanged from reports/02 and reports/03)

`hα_truth` (automorphism-invariance of `temporal_truth`) and `hα_nf` (automorphism-preservation
of `nf_eval_nf`) are hypotheses, not compiled. They are the IDENTICAL residual leg reports/02
(`hchar_eq` non-vacuity) and reports/03 (`htransport`) already isolated and the user already
accepted: the `(ℚ,<)` order-automorphism fixing `(-∞,t]` pointwise and moving `w0 ↦ w'`, plus
the routine formula-induction that truth of a fixed formula is automorphism-invariant. This
probe introduces NO new assumption; it WEAKENS the prior ones (one iff instead of two).

Purely additive specs-side probe; no production file touched. Compiled via `lake env lean`. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **The collapse step, exposed: a fixed-anchor seam makes the anchor semantically INERT.**

    From ONE completeness iff at `w0` plus the two automorphism facts, the `w0`-fiber and the
    `w'`-fiber of `nf_eval` coincide at every point, for every `σ`. The char engine cancels out of
    the derivation entirely (it appears once on each side of a `trans` and is never inspected) —
    which is precisely why no redesign of the engine, `w`-indexed or otherwise, can help.

    This is the honest statement of what the seam asserts: that moving the bracket witness `w`
    changes nothing semantically. It is false as soon as `σ` records an order bit between slot 0
    (`u`) and slot 1 (`w`) — i.e. as soon as the arity is ≥ 2. -/
theorem anchorMove_collapses_the_fiber {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier)
    (α : M.carrier → M.carrier)
    (hα_surj : Function.Surjective α)
    (hαx : α x = x) (hαt : α t = t) (hαw : α w0 = w')
    (hα_truth : ∀ (u : M.carrier) (f : Formula),
      temporal_truth M atomMap u f ↔ temporal_truth M atomMap (α u) f)
    (hα_nf : ∀ (σ : NormalForm sig (k + 1) 4) (a b c d : M.carrier),
      nf_eval_nf M (k + 1) 4 (Fin.cons a (Fin.cons b (Fin.cons c (fun _ => d)))) σ ↔
        nf_eval_nf M (k + 1) 4
          (Fin.cons (α a) (Fin.cons (α b) (Fin.cons (α c) (fun _ => α d)))) σ)
    (charEngine : NormalForm sig (k + 1) 4 → Formula)
    (hiff : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      temporal_truth M atomMap u (charEngine σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ) :
    ∀ (σ : NormalForm sig (k + 1) 4) (z : M.carrier),
      nf_eval_nf M (k + 1) 4 (Fin.cons z (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons z (Fin.cons w' (Fin.cons x (fun _ => t)))) σ := by
  intro σ z
  obtain ⟨u, rfl⟩ := hα_surj z
  -- `α`-invariance of truth turns the iff at `u` into the iff at `α u`, SAME anchor `w0`.
  have hA : nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ ↔
      nf_eval_nf M (k + 1) 4 (Fin.cons (α u) (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ :=
    (hiff σ u).symm.trans ((hα_truth u (charEngine σ)).trans (hiff σ (α u)))
  -- `α`-preservation of `nf_eval` moves the ANCHOR: `w0 ↦ w'`, with `x,t` pinned.
  have hB : nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ ↔
      nf_eval_nf M (k + 1) 4 (Fin.cons (α u) (Fin.cons w' (Fin.cons x (fun _ => t)))) σ := by
    have h := hα_nf σ u w0 x t
    rw [hαx, hαt, hαw] at h
    exact h
  exact hA.symm.trans hB

/-- **THE CONTRAST — why the repo's DISCHARGED seams are safe and this one is not.**

    `interiorGate_hck` (`InteriorGateGeneralK.lean:128-145`) is a PROVED, sorry-free theorem:
    `temporal_truth M atomMap u (P.existF 0 χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ`. It is discharged
    from `ExistProviders.correct` (`PriorInterface.lean:41-45`), whose RHS
    `∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub` binds the non-evaluation slots
    EXISTENTIALLY.

    This lemma compiles the reason that shape is safe: an existentially-anchored RHS is
    automorphism-invariant, exactly like a formula's truth-set. So `hα_truth` transports it to
    ITSELF and no collision can ever be built. The fixed-anchor RHS
    `nf_eval[u,w0,x,t] σ` has no such invariance — `anchorMove_collapses_the_fiber` shows the
    seam is forced to pretend it does, and `anchorMove_refutes_any_charEngine` cashes that in
    for `False`.

    The dividing line is therefore NOT "arity 4 vs arity 1" per se, and NOT the engine's
    definition: it is **fixed anchors vs bound anchors**. A parameter-free formula can define only
    automorphism-invariant sets; anchors it must not name have to be existentially bound (or
    absent), never pinned. -/
theorem existAnchored_rhs_is_automorphism_invariant {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (α : M.carrier → M.carrier)
    (hα_surj : Function.Surjective α)
    (hαx : α x = x) (hαt : α t = t)
    (hα_nf : ∀ (σ : NormalForm sig (k + 1) 4) (a b c d : M.carrier),
      nf_eval_nf M (k + 1) 4 (Fin.cons a (Fin.cons b (Fin.cons c (fun _ => d)))) σ ↔
        nf_eval_nf M (k + 1) 4
          (Fin.cons (α a) (Fin.cons (α b) (Fin.cons (α c) (fun _ => α d)))) σ) :
    ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      (∃ w : M.carrier,
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ↔
      (∃ w : M.carrier,
        nf_eval_nf M (k + 1) 4 (Fin.cons (α u) (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  intro σ u
  constructor
  · rintro ⟨w, hw⟩
    refine ⟨α w, ?_⟩
    have h := hα_nf σ u w x t
    rw [hαx, hαt] at h
    exact h.mp hw
  · rintro ⟨w, hw⟩
    obtain ⟨w1, rfl⟩ := hα_surj w
    refine ⟨w1, ?_⟩
    have h := hα_nf σ u w1 x t
    rw [hαx, hαt] at h
    exact h.mpr hw

/-- **The engine-agnostic refutation: no char family can satisfy the seam at an anchor that an
    automorphism can move.**

    `charEngine` is an ARBITRARY `NormalForm sig (k+1) 4 → Formula`. It is quantified over, never
    inspected, and never destructured. The proof:

    * From `hiff` at `u`, `α`-invariance of `temporal_truth`, and `hiff` at `α u`:
      `nf_eval[u,w0,x,t] σ ↔ nf_eval[α u, w0, x, t] σ`. (The engine's formula cancels out.)
    * From `hα_nf` plus `α x = x`, `α t = t`, `α w0 = w'`:
      `nf_eval[u,w0,x,t] σ ↔ nf_eval[α u, w', x, t] σ`.
    * Composing and using surjectivity of `α`: the `w0`-fiber and the `w'`-fiber COINCIDE at
      every point, for every `σ`.
    * Instantiate at `σ* := char[v,w',x,t]` for a separating `v` with `w0 < v < w'`: `σ*` records
      the order bit `v < w'` as TRUE, so the collapsed fiber forces `v < w0` — contradicting
      `w0 < v`.

    Note the collapse step is where the seam dies: it says the anchor `w` is SEMANTICALLY INERT,
    which is false as soon as `σ` records any order bit between slot 0 (`u`) and slot 1 (`w`). -/
theorem anchorMove_refutes_any_charEngine {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier)
    -- the anchor-fixing automorphism, presented by its two invariance facts (disclosed residual)
    (α : M.carrier → M.carrier)
    (hα_surj : Function.Surjective α)
    (hαx : α x = x) (hαt : α t = t) (hαw : α w0 = w')
    (hα_truth : ∀ (u : M.carrier) (f : Formula),
      temporal_truth M atomMap u f ↔ temporal_truth M atomMap (α u) f)
    (hα_nf : ∀ (σ : NormalForm sig (k + 1) 4) (a b c d : M.carrier),
      nf_eval_nf M (k + 1) 4 (Fin.cons a (Fin.cons b (Fin.cons c (fun _ => d)))) σ ↔
        nf_eval_nf M (k + 1) 4
          (Fin.cons (α a) (Fin.cons (α b) (Fin.cons (α c) (fun _ => α d)))) σ)
    -- a point separating the two renders (density; e.g. any rational strictly between)
    (v : M.carrier) (hv0 : w0 < v) (hv' : v < w')
    -- THE ARBITRARY CHAR ENGINE — never inspected below.
    (charEngine : NormalForm sig (k + 1) 4 → Formula)
    (hiff : ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      temporal_truth M atomMap u (charEngine σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ) :
    False := by
  -- Step 1: the two anchor-fibers coincide everywhere. The engine cancels out.
  have key' := anchorMove_collapses_the_fiber atomMap M x t w0 w' α hα_surj hαx hαt hαw
    hα_truth hα_nf charEngine hiff
  -- Step 2: the collapse contradicts the order bit recorded by the separating point's own type.
  set σstar : NormalForm sig (k + 1) 4 :=
    nf_characteristic M (k + 1) 4 (Fin.cons v (Fin.cons w' (Fin.cons x (fun _ => t)))) with hσdef
  have hsat : nf_eval_nf M (k + 1) 4
      (Fin.cons v (Fin.cons w' (Fin.cons x (fun _ => t)))) σstar :=
    nf_characteristic_satisfies M (k + 1) 4 _
  have hbad : nf_eval_nf M (k + 1) 4
      (Fin.cons v (Fin.cons w0 (Fin.cons x (fun _ => t)))) σstar :=
    (key' σstar v).mpr hsat
  have hatoms' : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons v (Fin.cons w' (Fin.cons x (fun _ => t)))) a ↔
        σstar.atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hsat
  have hatoms0 : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons v (Fin.cons w0 (Fin.cons x (fun _ => t)))) a ↔
        σstar.atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hbad
  -- `σ*` records slot0 < slot1, i.e. `v < w'`, as TRUE.
  have hbit : σstar.atom_assgn (.order (0 : Fin 4) (1 : Fin 4) (by decide)) = true := by
    apply (hatoms' _).mp
    simpa [atom_eval, Fin.cons_zero, Fin.cons_one] using hv'
  -- The collapsed fiber replays that bit at anchor `w0`: forces `v < w0`.
  have h0 := (hatoms0 _).mpr hbit
  simp only [atom_eval, Fin.cons_zero, Fin.cons_one] at h0
  exact lt_asymm hv0 h0

/-- **ROUTE A IS FUTILE — the `w`-indexed char engine is refuted by the same automorphism.**

    `charFibW : M.carrier → NormalForm sig (k+1) 4 → Formula` is the Route A redesign: each render
    `w` gets its OWN char formula, so cross-render transport is supposed to become ill-typed by
    construction. It does not help. The refutation never transports a formula between renders: it
    fixes the ONE formula `charFibW w0 σ` emitted at `w0` and moves the ANCHOR underneath it.

    Instantiates `anchorMove_refutes_any_charEngine` at `charEngine := charFibW w0`. `charFibW` is
    arbitrary — in particular this covers every possible implementation of a `w`-indexed engine,
    including ones defined by classical choice with no orbit-invariance whatsoever. -/
theorem wIndexedSeam_refuted {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier)
    (α : M.carrier → M.carrier)
    (hα_surj : Function.Surjective α)
    (hαx : α x = x) (hαt : α t = t) (hαw : α w0 = w')
    (hα_truth : ∀ (u : M.carrier) (f : Formula),
      temporal_truth M atomMap u f ↔ temporal_truth M atomMap (α u) f)
    (hα_nf : ∀ (σ : NormalForm sig (k + 1) 4) (a b c d : M.carrier),
      nf_eval_nf M (k + 1) 4 (Fin.cons a (Fin.cons b (Fin.cons c (fun _ => d)))) σ ↔
        nf_eval_nf M (k + 1) 4
          (Fin.cons (α a) (Fin.cons (α b) (Fin.cons (α c) (fun _ => α d)))) σ)
    (v : M.carrier) (hv0 : w0 < v) (hv' : v < w')
    -- THE ROUTE A REDESIGN: a `w`-INDEXED char engine, arbitrary.
    (charFibW : M.carrier → NormalForm sig (k + 1) 4 → Formula)
    (hiffW : ∀ (w : M.carrier) (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
      temporal_truth M atomMap u (charFibW w σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    False :=
  anchorMove_refutes_any_charEngine atomMap M x t w0 w' α hα_surj hαx hαt hαw hα_truth hα_nf
    v hv0 hv' (charFibW w0) (hiffW w0)

/-- **Render-guarding the `w`-indexed seam does not rescue Route A either.** The seam in its
    production shape is guarded: the iff is promised only at points that RENDER `qnf`
    (`ExteriorGateAssembleK.lean:571-578`, `InteriorGateGeneralK.lean:1776`). Guarding is
    irrelevant to this refutation: only `w0` is ever required to render — `w'` (the automorphism
    image) is never fed to the seam, and `v` (the separating point) is not a render at all. So the
    refutation fires inside the guarded form unchanged.

    This also localizes what Route C would have to do: it must remove the AUTOMORPHISM (rigidity),
    not restrict the renders. Restricting renders leaves `hiffW w0 hr0` fully available, which is
    all the refutation consumes. -/
theorem wIndexedSeam_refuted_with_render_guard {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier)
    (qnf : NormalForm sig (k + 2) 3)
    (α : M.carrier → M.carrier)
    (hα_surj : Function.Surjective α)
    (hαx : α x = x) (hαt : α t = t) (hαw : α w0 = w')
    (hα_truth : ∀ (u : M.carrier) (f : Formula),
      temporal_truth M atomMap u f ↔ temporal_truth M atomMap (α u) f)
    (hα_nf : ∀ (σ : NormalForm sig (k + 1) 4) (a b c d : M.carrier),
      nf_eval_nf M (k + 1) 4 (Fin.cons a (Fin.cons b (Fin.cons c (fun _ => d)))) σ ↔
        nf_eval_nf M (k + 1) 4
          (Fin.cons (α a) (Fin.cons (α b) (Fin.cons (α c) (fun _ => α d)))) σ)
    (v : M.carrier) (hv0 : w0 < v) (hv' : v < w')
    (charFibW : M.carrier → NormalForm sig (k + 1) 4 → Formula)
    -- ONE render witness `w0` (exactly what `step_complete` destructures, IGGK:1785).
    (hr0 : nf_eval_nf M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t))) qnf)
    -- the RENDER-GUARDED `w`-indexed seam.
    (hiffW : ∀ (w : M.carrier),
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFibW w σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    False :=
  anchorMove_refutes_any_charEngine atomMap M x t w0 w' α hα_surj hαx hαt hαw hα_truth hα_nf
    v hv0 hv' (charFibW w0) (hiffW w0 hr0)

end Bimodal.Metalogic.WeakCanonical.Kamp
