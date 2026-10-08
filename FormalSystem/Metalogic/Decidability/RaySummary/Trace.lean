/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Closure
import FormalSystem.Metalogic.Decidability.RaySummary.HitOf

/-!
# The trace is the unique anchored local run (HWZ 2000, Theorem 14 ⇒, soundness and uniqueness)

`Closure.lean` fixed the closure alphabet `clSig φ`, the local run conditions `LocalRun`, the
anchors `Anchored`, and the trace `clTrace M φ t σ` of a history over that alphabet. This module
proves Hodkinson–Wolter–Zakharyaschev 2000, Theorem 14, in the direction that reads types *off*
a model, in both of its halves:

- *Soundness* — **the trace of a history satisfies every run condition and every anchor**
  (`clTrace_localRun`, `clTrace_anchored`). Nothing is constructed; every clause of `LocalRun`
  and `Anchored` is the matching clause of `PlusTruthAt` after unfolding `clTrace`, so each
  field is `Iff.rfl`.
- *Uniqueness* — **an anchored local run over `clSig φ` is the trace of its history**
  (`eq_clTrace_of_localRun_anchored`, packaged as `clTrace_unique`), by structural induction on
  the closure formula: the `atom`/`box`/`stab` letters are fixed by the anchors, `bot` by its
  run condition, and `imp`/`untl`/`snce` by their run conditions rewritten through the induction
  hypotheses, after which the right-hand side is the `PlusTruthAt` clause verbatim. No
  well-founded argument on time is needed: the run conditions quantify over `ℤ` exactly as the
  truth clauses do, so the temporal cases are rewrites, not inductions on a distance.

**Where the rest of Theorem 14 lives.**
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
`hitOf` on a finite labelled presentation lives in `HitOf.lean`; the realization hypothesis
`Presented` tying the two together is the last section of this module.

**The per-model bridge under an explicit realization hypothesis.** `Presented M τ t φ lab step`
says that the closure traces of the seam's splices are EXACTLY the traces of the anchored runs
of the finite presentation `(lab, step)` over the closure alphabet. Under it, `HitCl` IS the
computable `hitOf` (`hit_eq_hitOf_of_presented`) and the `⊡` bridge restates over `hitOf`
(`plusStab_iff_forall_hitOf_of_presented`). The hypothesis is **not discharged in this tree for
any non-trivial model**: discharging it for a model constructed from a presentation is B2b, the
successor record, and the wired probe `quasistate_does_not_determine_hit` is the reason it must
carry joint realization through the seam (a trace-set equality) rather than per-time quasistate
data. What the hypothesis buys is exactly the division of labour: `hitOf` is computed once and
for all on the presentation, and every model-side question is pushed into one equality of sets.

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

/-! ## An anchored local run is the trace -/

section Uniqueness

variable {F : FrameOver intOrder}

/-- **Every closure letter of an anchored local run reads `PlusTruthAt` along its history** —
the inductive core of uniqueness, by structural induction on the closure formula `ψ` with the
membership proof `hψ` generalised. The `atom`, `box` and `stab` letters are fixed by the anchors
(`Anchored.atom/box/stab`); `bot` by `LocalRun.bot`; `imp`, `untl` and `snce` by their run
conditions, rewritten through the induction hypotheses for the parts (which are in the closure
by `plusClosure_imp_left/right`, `plusClosure_untl_left/right`, `plusClosure_snce_left/right`),
after which the clause is `PlusTruthAt`'s verbatim.

The one subtlety is `box` (research "Potential Formalization Challenges", step 4): its anchor
`∀ σ', PlusTruthAt M σ' z ψ` is independent of `σ`, so the induction threads it as a per-time
datum read off the anchor directly — it never passes through a run condition and never recurses
into `ψ`, which is why the `box` and `stab` cases discard their induction hypotheses. -/
theorem letter_iff_of_localRun_anchored (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (t : ℤ) (σ : WorldHistory F.toTaskFrame) {c : (clSig φ).preds → ℤ → Prop}
    (hr : LocalRun φ c) (ha : Anchored M φ t c σ) :
    ∀ (ψ : PlusFormula) (hψ : ψ ∈ plusSubformulaClosure φ) (z : ℤ),
      c (clLetter φ hψ) z ↔ PlusTruthAt M σ z ψ := by
  intro ψ
  induction ψ with
  | atom p =>
    intro hψ z
    exact ha.atom p hψ z
  | bot =>
    intro hψ z
    exact ⟨fun h => hr.bot hψ z h, fun h => h.elim⟩
  | imp ψ χ ihψ ihχ =>
    intro hψ z
    rw [hr.imp ψ χ hψ z, ihψ, ihχ]
    exact Iff.rfl
  | box ψ _ =>
    intro hψ z
    exact ha.box ψ hψ z
  | untl ψ χ ihψ ihχ =>
    intro hψ z
    rw [hr.untl ψ χ hψ z]
    simp only [ihψ, ihχ]
    exact Iff.rfl
  | snce ψ χ ihψ ihχ =>
    intro hψ z
    rw [hr.snce ψ χ hψ z]
    simp only [ihψ, ihχ]
    exact Iff.rfl
  | stab ψ _ =>
    intro hψ z
    exact ha.stab ψ hψ z

/-- **An anchored local run is the trace** (HWZ 2000, Theorem 14 ⇒, the uniqueness half): a
colouring over the closure alphabet that satisfies the run conditions and the anchors for `σ`
IS `clTrace M φ t σ`. Pointwise by `funext`: the marker letter from the `now` anchor, every
subformula letter from `letter_iff_of_localRun_anchored`.

Paper: HWZ 2000, Theorem 14 (⇒), uniqueness of the run `t_a` given the state function. -/
theorem eq_clTrace_of_localRun_anchored (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (t : ℤ) (σ : WorldHistory F.toTaskFrame) {c : (clSig φ).preds → ℤ → Prop}
    (hr : LocalRun φ c) (ha : Anchored M φ t c σ) : c = clTrace M φ t σ := by
  funext p z
  apply propext
  rcases p with ⟨ψ, hψ⟩ | ⟨⟩
  · exact letter_iff_of_localRun_anchored M φ t σ hr ha ψ hψ z
  · exact ha.now z

/-- **The trace is the unique anchored local run** — the `∃!` packaging of
`clTrace_localRun`, `clTrace_anchored` and `eq_clTrace_of_localRun_anchored`. -/
theorem clTrace_unique (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) :
    ∃! c : (clSig φ).preds → ℤ → Prop, LocalRun φ c ∧ Anchored M φ t c σ :=
  ⟨clTrace M φ t σ, ⟨clTrace_localRun M φ t σ, clTrace_anchored M φ t σ⟩,
    fun _ ⟨hr, ha⟩ => eq_clTrace_of_localRun_anchored M φ t σ hr ha⟩

end Uniqueness

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
    (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (tr : WorldHistory F.toTaskFrame → sig.preds → ℤ → Prop) (k : ℕ) :
    HitSig sig τ t tr k =
      ⋃ bf : SeqPair F (τ.state t), familyTriples sig k (tr (spliced τ t bf)) :=
  Set.ext fun _ => by simp only [HitSig, familyTriples, Set.mem_setOf_eq, Set.mem_iUnion]

/-- **The realized family triples of the closure trace**: `HitSig` at the closure instance. A
`Set`, exactly as `Hit` is. -/
def HitCl (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) :
    Set (KType (clSig φ) k × KType (clSig φ) k × KType (clSig φ) k) :=
  HitSig (clSig φ) τ t (clTrace M φ t) k

theorem hitCl_finite (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) : (HitCl M τ t φ k).Finite :=
  hitSig_finite (clSig φ) τ t (clTrace M φ t) k

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
  hitSig_eq_iUnion (clSig φ) τ t (clTrace M φ t) k

end HitCl

/-! ## The per-model bridge under an explicit realization hypothesis -/

section Presented

variable {F : FrameOver intOrder} [F.IsRegular] {Q : Type}

/-- **The realization hypothesis**: the closure traces of the seam's splices at `(t, τ.state t)`
are exactly the traces of the runs of the finite presentation `(lab, step)` over the closure
alphabet, anchored at `t`.

This hypothesis is NOT discharged in this tree for any non-trivial model. Discharging it for a
model CONSTRUCTED from a presentation is B2b, the successor record; the wired probe
`quasistate_does_not_determine_hit` shows that per-time quasistate data cannot replace it, which
is why it is stated as an equality of trace sets — joint realization through the seam — and not
as a per-time condition. `presented_localRun` shows the run conditions are inherited by every
run of a presented model, which is why `pathTypes` needs no discharge bookkeeping: a run that is
a trace already satisfies `LocalRun` by `clTrace_localRun`. -/
def Presented (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) : Prop :=
  ∀ c : (clSig φ).preds → ℤ → Prop,
    (∃ bf : SeqPair F (τ.state t), c = clTrace M φ t (spliced τ t bf)) ↔
      (∃ ρ : ℤ → Q, IsRun lab step (clNow φ) t ρ ∧ c = runTrace lab ρ)

/-- Under `Presented`, every anchored run of the presentation satisfies the run conditions: its
trace is a closure trace, and closure traces are local runs (`clTrace_localRun`). -/
theorem presented_localRun (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hP : Presented M τ t φ lab step) :
    ∀ ρ : ℤ → Q, IsRun lab step (clNow φ) t ρ → LocalRun φ (runTrace lab ρ) := by
  intro ρ hρ
  obtain ⟨bf, hc⟩ := (hP (runTrace lab ρ)).mpr ⟨ρ, hρ, rfl⟩
  rw [hc]
  exact clTrace_localRun M φ t _

/-- **Under `Presented`, the realized set IS the computable one**: `HitCl M τ t φ k` equals
`hitOf lab step (clNow φ) k` as sets, at every depth `k ≥ 1`. Both sides are "some run/ray pair
whose trace realizes the triple": `mem_hitOf_iff` on the right, `Presented` to move between the
seam's traces and the presentation's runs.

Paper: — (the formalization's own realizability device; the paper has no counterpart) -/
theorem hit_eq_hitOf_of_presented [Fintype Q] [DecidableEq Q] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula) (lab : Q → (clSig φ).preds → Bool)
    (step : Q → Q → Bool) (k : ℕ) (hk : 1 ≤ k) (hP : Presented M τ t φ lab step) :
    HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k) := by
  ext x
  rw [Finset.mem_coe, mem_hitOf_iff lab step (clNow φ) k t hk]
  constructor
  · rintro ⟨bf, hx⟩
    obtain ⟨ρ, hρ, hc⟩ := (hP _).mp ⟨bf, rfl⟩
    exact ⟨ρ, hρ, hc ▸ hx⟩
  · rintro ⟨ρ, hρ, hx⟩
    obtain ⟨bf, hc⟩ := (hP _).mpr ⟨ρ, hρ, rfl⟩
    exact ⟨bf, hc ▸ hx⟩

/-- **The `⊡` bridge over the computable `hitOf`, under `Presented`**: the one-line corollary of
`plusStab_iff_forall_hitCl` and `hit_eq_hitOf_of_presented`.

This decides nothing. `hitOf` is a computable finite set, but the per-triple condition
`∀ c, InFamily … → stabTargetSig …` quantifies over all colourings in a family, and making it
effective — through `kTypeOf_zFiber_eq_of_inFamily` and a middle-segment representative, so
that one representative colouring per triple suffices — is the frame of the successor record
that assembles `Decidable (PlusValidZTime φ)`; it is not done here. -/
theorem plusStab_iff_forall_hitOf_of_presented [Fintype Q] [DecidableEq Q]
    (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) (k : ℕ) (hk : 1 ≤ k)
    (hP : Presented M τ t φ lab step) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ x ∈ hitOf lab step (clNow φ) k,
        ∀ c, InFamily (clSig φ) k x.1 x.2.1 x.2.2 c →
          stabTargetSig (clSig φ) (clNow φ) (clPhi φ) c := by
  rw [plusStab_iff_forall_hitCl M τ t φ k hk, hit_eq_hitOf_of_presented M τ t φ lab step k hk hP]
  exact Iff.rfl

end Presented

end FormalSystem.Metalogic.Decidability.RaySummary
