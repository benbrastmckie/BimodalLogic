/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Closure

/-!
# The trace is an anchored local run (HWZ 2000, Theorem 14 ⇒, the soundness half)

`Closure.lean` fixed the closure alphabet `clSig φ`, the local run conditions `LocalRun`, the
anchors `Anchored`, and the trace `clTrace M φ t σ` of a history over that alphabet. This module
proves the first half of Hodkinson–Wolter–Zakharyaschev 2000, Theorem 14, in the direction that
reads types *off* a model: **the trace of a history satisfies every run condition and every
anchor**. Nothing is constructed; every clause of `LocalRun` and `Anchored` is the matching clause
of `PlusTruthAt` after unfolding `clTrace`, so each field is `Iff.rfl`.

**Where the rest of Theorem 14 lives.**
- *Uniqueness* (an anchored local run over `clSig φ` is the trace of its history,
  `eq_clTrace_of_localRun_anchored`) is the next module in this cluster, by structural induction
  on the closure formula.
- *Theorem 14 ⇐* — building a model from a colouring that satisfies the run conditions — is
  **B2b and is absent from this tree**. It is not a one-line mirror of this module, for a reason
  that is a property of the semantics rather than of the proof: the `⊡` fibre is a **product**
  (`seamOmegaEquiv`: histories through `(t, s)` are exactly pairs of a backward and a forward
  ω-step-sequence out of `s`), so the set of traces realized at a state is closed under splicing
  the backward half of one history with the forward half of another. A per-state summary that
  claims a set of types `S` therefore realizes the mixed set, not `S` — the "realized type the
  model lacked" of HWZ's Lemma 17 — and a sound presentation must carry a *product*
  `BwdSummary × FwdSummary` of the two one-sided atom-sequence languages, with types derived by
  the trace map rather than taken as primitive. `Anchored` already carries exactly those atoms
  (atoms at states, `box`-values at times, `stab`-values at states); the construction that
  realizes a product summary by an infinite committed-state slice is a successor record.

**The realized set over the closure alphabet.** `HitCl M τ t φ k` is `HitSig` at the closure
instance: the family triples realized by the closure trace on the splices of the seam's ray
pairs. It is finite (`hitCl_finite`), and the `⊡` bridge holds over it with the two anchor
hypotheses of `plusStab_iff_forall_hitSig` discharged by `clTrace_anchored`
(`plusStab_iff_forall_hitCl`). `hitCl_eq_iUnion` restates it as the union, over the seam's ray
pairs, of the family-triple sets of their closure traces — reading (R1) of the research: **a
theorem, explicitly not a computation**, because `SeqPair F s` is not finite. The computable
`hitOf` on a finite labelled presentation, and the realization hypothesis `Presented` tying the
two together, are later modules.

**What is NOT here.** No `Bool`; no quantification over models (B4); no backward fixture bridge —
the `⊡(Pp)` side is fixed only by `Probe719Backward.pastStab_iff_allBwdPathsMeet`, and the `snce`
clause of `clTrace_localRun` is a run condition on the trace, not a bridge. Everything stays under
`[F.IsRegular]` where the seam's fibre is used (`spliced`), over the time axis with a finite
alphabet of per-time letters; no finite-fibre or finite-width assumption; no complexity bound.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness FormalSystem.Semantics

/-! ## The trace satisfies the run conditions and the anchors -/

section Soundness

variable {F : FrameOver intOrder}

/-- **The trace satisfies the run conditions** (HWZ 2000, Theorem 14 ⇒, the local half). Each
field is the matching `PlusTruthAt` clause: `bot` is `False`, `imp` is implication, `untl`/`snce`
are the strict clauses with the guard on the open interval — the run conditions of `LocalRun`
were stated to be these clauses verbatim, so every field is `Iff.rfl` after unfolding `clTrace`
through `clTrace_letter`.

Paper: HWZ 2000, Theorem 14 (⇒), the U/S clauses of Definition 11 read off `t_a`. -/
theorem clTrace_localRun (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : LocalRun φ (clTrace M φ t σ) where
  bot _ _ h := h
  imp _ _ _ _ := Iff.rfl
  untl _ _ _ _ := Iff.rfl
  snce _ _ _ _ := Iff.rfl

/-- **The trace is anchored to its history** (HWZ 2000, Theorem 14 ⇒, the anchor half). `now` is
`z = t` by `clTrace_now`; the `atom`, `box` and `stab` anchors are the corresponding
`PlusTruthAt` clauses, so every field is `Iff.rfl`.

Paper: HWZ 2000, Theorem 14 (⇒); the atom/`box`/`stab` anchors are the atomization licence of
`Seam.lean` point (e). -/
theorem clTrace_anchored (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : Anchored M φ t (clTrace M φ t σ) σ where
  now _ := Iff.rfl
  atom _ _ _ := Iff.rfl
  box _ _ _ := Iff.rfl
  stab _ _ _ := Iff.rfl

/-- The `phi` anchor of the generic bridge, at the closure instance: the letter of `φ` itself
reads `φ` along the history. -/
theorem clTrace_clPhi (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) :
    clTrace M φ t σ (clPhi φ) z ↔ PlusTruthAt M σ z φ :=
  clTrace_letter M φ t σ (self_mem_plusSubformulaClosure φ) z

end Soundness

/-! ## The realized set over the closure alphabet -/

section HitCl

/-- **The family triples of a coloured block**: the triples `(τneg, τzero, τpos)` whose family
contains `c` (`InFamily`). A `Set`; the family-triple read-out is finite by
`finite_family_triples` but nothing here computes it. -/
def familyTriples (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ)
    (c : sig.preds → ℤ → Prop) : Set (KType sig k × KType sig k × KType sig k) :=
  {x | InFamily sig k x.1 x.2.1 x.2.2 c}

theorem mem_familyTriples (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) (c : sig.preds → ℤ → Prop) (x : KType sig k × KType sig k × KType sig k) :
    x ∈ familyTriples sig k c ↔ InFamily sig k x.1 x.2.1 x.2.2 c := Iff.rfl

variable {F : FrameOver intOrder} [F.IsRegular]

/-- `HitSig` is the union, over the seam's ray pairs, of the family-triple sets of their traces —
a set-theoretic restatement, not a computation: the index type `SeqPair F s` is not finite. -/
theorem hitSig_eq_iUnion (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (tr : WorldHistory F.toTaskFrame → sig.preds → ℤ → Prop) (k : ℕ) :
    HitSig sig M τ t tr k =
      ⋃ bf : SeqPair F (τ.state t), familyTriples sig k (tr (spliced τ t bf)) :=
  Set.ext fun _ => by simp only [HitSig, familyTriples, Set.mem_setOf_eq, Set.mem_iUnion]

/-- **The realized family triples of the closure trace**: `HitSig` at the closure instance. A
`Set`, exactly as `Hit` is. -/
def HitCl (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) :
    Set (KType (clSig φ) k × KType (clSig φ) k × KType (clSig φ) k) :=
  HitSig (clSig φ) M τ t (clTrace M φ t) k

theorem hitCl_finite (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) : (HitCl M τ t φ k).Finite :=
  hitSig_finite (clSig φ) M τ t (clTrace M φ t) k

/-- **The `⊡` bridge over the closure alphabet**: `plusStab_iff_forall_hitSig` at
`sig := clSig φ`, `now := clNow φ`, `phi := clPhi φ`, `tr := clTrace M φ t`, with the two anchor
hypotheses discharged by `clTrace_anchored` (the `now` field) and `clTrace_clPhi`. Hypothesis-free
on the model; `HitCl` is not computed.

Paper: — (the formalization's own seam interface; the paper has no counterpart) -/
theorem plusStab_iff_forall_hitCl (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ x ∈ HitCl M τ t φ k,
        ∀ c, InFamily (clSig φ) k x.1 x.2.1 x.2.2 c →
          stabTargetSig (clSig φ) (clNow φ) (clPhi φ) c :=
  plusStab_iff_forall_hitSig (clSig φ) (clNow φ) (clPhi φ) M τ t φ (clTrace M φ t)
    (fun σ z => (clTrace_anchored M φ t σ).now z) (clTrace_clPhi M φ t) k hk

/-- **Reading (R1): `HitCl` is the union over the seam's ray pairs of the family triples of
their closure traces.** A theorem and explicitly NOT a computation — `SeqPair F (τ.state t)` is
not finite, and nothing here enumerates it. The computable counterpart on a finite labelled
presentation (`hitOf`) and the realization hypothesis that equates the two (`Presented`) are
later modules. -/
theorem hitCl_eq_iUnion (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) :
    HitCl M τ t φ k =
      ⋃ bf : SeqPair F (τ.state t), familyTriples (clSig φ) k (clTrace M φ t (spliced τ t bf)) :=
  hitSig_eq_iUnion (clSig φ) M τ t (clTrace M φ t) k

end HitCl

end FormalSystem.Metalogic.Decidability.RaySummary
