/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti
import FormalSystem.PlusLanguage.Subformulas

/-!
# The closure alphabet, the local run conditions, the anchors, and the signature-generic
`⊡` bridge

`SeamMulti.lean` states the hypothesis-free `⊡` bridge `plusStab_iff_forall_hit` over the
two-letter alphabet `twoLetter` — `now` and `φ` — and its entire residue is the realized set
`Hit`, which is finite and computed nowhere. Two letters cannot be computed from: the trace of a
history records only where `φ` is true, and nothing in a two-letter colouring says whether it
*is* the trace of some history. This module widens the alphabet to the one on which that
question can be asked at all, and restates the bridge so that the widening costs nothing.

**(a) The alphabet** (Hodkinson–Wolter–Zakharyaschev 2000, Definition 6, `sub_x φ`, plus a
marker). `clSig φ` has one letter per subformula of `φ` (`PlusFormula.subformulas`, as a
`Finset`-membership subtype) and one marker letter `now` (`clNow`); `clPhi` is `φ`'s own letter
and `clLetter` the letter of any subformula from its membership proof. The alphabet is finite
with decidable equality by `inferInstanceAs` on the `Subtype ⊕ Unit` form.

**(b) The local run conditions** (HWZ 2000, Definition 11, the U/S clauses, stated here on
colourings of `ℤ` rather than on state functions). `LocalRun φ c` asks, for every closure
formula of the relevant shape, that the colouring respect it pointwise: the `bot` letter is
nowhere, the `imp` letter is the pointwise implication of its parts, the `untl` letter at `z`
is "the event at some `s > z` with the guard on the open interval `(z, s)`", and `snce` is its
mirror with `s < z`. These are **exactly** the `untl`/`snce` clauses of `PlusTruthAt`
(`PlusTruth.lean`), strict and with the guard on the open interval, so the trace of a history
satisfies them by the clause itself (Phase 3's `clTrace_localRun`). The `atom`, `box` and `stab`
letters impose **no** run condition: `box` is a per-time datum and `stab` a per-state datum, and
a colouring of the time axis cannot see either. They are fixed by the anchors instead.

**(c) The anchors.** `Anchored M φ t c σ` fixes what a run condition cannot: `now` exactly at
`t`; atoms by the valuation at `σ`'s state; `box`-letters by truth along every history at that
time; `stab`-letters by truth along every history sharing `σ`'s state at that time. These are
the atomization licence of `Seam.lean` point (e) and `plusTruthAt_iff_atomize`, stated as
anchors rather than as run conditions — they are where the colouring meets the model.

**(d) The trace and the generic bridge.** `clTrace M φ t σ` is the full labelling of the time
axis by `σ` (HWZ 2000, Theorem 14's `t_a`): subformula letters by `PlusTruthAt`, the marker by
`z = t`. Its two-letter projection is `seamTrace` definitionally (`clTrace_proj`). The bridge is
then restated over an **arbitrary** finite signature with distinguished letters `now` and `phi`
and an arbitrary trace map `tr` satisfying the two anchor hypotheses — `now` exactly at `t`,
`phi` exactly where `φ` is true (`plusStab_iff_forall_hitSig`, the same proof as
`plusStab_iff_forall_hit`: forward `plusStab_iff_omega` + `family_saturation`, backward
`family_cover`). The two-letter theorem is its instance at `sig := twoLetter`, `now := true`,
`phi := false`, `tr := seamTrace M φ t`, and `HitSig` at that instance is `Hit` by `rfl`
(`hitSig_twoLetter`).

**What is NOT here.** No realizability: nothing says which colourings over `clSig φ` are traces
(that is `clTrace_localRun`, `clTrace_anchored` and `eq_clTrace_of_localRun_anchored`, Phases 3
and 5), and nothing constructs a model from a colouring (B2b, a successor record). No `Bool`:
`HitSig` is a `Set`, exactly as `Hit` is; the computable `hitOf` on a finite presentation is
Phases 6–7. No quantification over models (B4). And the forward-only limit of the fixture
results is carried unchanged: the backward `⊡(Pp)` side is fixed only by
`Probe719Backward.pastStab_iff_allBwdPathsMeet`, and nothing here adds a backward fixture
bridge — the `snce` clause of `LocalRun` is a run condition, not a bridge.

Everything stays under `[F.IsRegular]` where the seam's fibre is used (`spliced`), over the time
axis with a finite alphabet of per-time letters; no finite-fibre or finite-width assumption is
introduced; no complexity bound is claimed.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness FormalSystem.Semantics

/-! ## The closure alphabet -/

section Alphabet

/-- **The closure alphabet**: one letter per subformula of `φ` (HWZ 2000, Definition 6's
`sub_x φ`, as the membership subtype of `PlusFormula.subformulas φ`), plus the marker `now`. -/
def clSig (φ : PlusFormula) : MonadicSignature :=
  ⟨{ψ : PlusFormula // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩

instance (φ : PlusFormula) : Fintype (clSig φ).preds :=
  inferInstanceAs (Fintype ({ψ : PlusFormula // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit))

instance (φ : PlusFormula) : DecidableEq (clSig φ).preds :=
  inferInstanceAs
    (DecidableEq ({ψ : PlusFormula // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit))

/-- The marker letter `now`. -/
def clNow (φ : PlusFormula) : (clSig φ).preds := Sum.inr ()

/-- The letter of a subformula, from its membership in the closure (`plusSubformulaClosure φ`
is `(PlusFormula.subformulas φ).toFinset` by definition). -/
def clLetter (φ : PlusFormula) {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ) :
    (clSig φ).preds :=
  Sum.inl ⟨ψ, h⟩

/-- The letter of `φ` itself. -/
def clPhi (φ : PlusFormula) : (clSig φ).preds :=
  clLetter φ (self_mem_plusSubformulaClosure φ)

theorem clPhi_eq (φ : PlusFormula) :
    clPhi φ = Sum.inl ⟨φ, List.mem_toFinset.mpr (PlusFormula.self_mem_subformulas φ)⟩ := rfl

/-- The marker is never a subformula letter. -/
theorem clNow_ne_clLetter (φ : PlusFormula) {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ) :
    clNow φ ≠ clLetter φ h := by
  intro h
  cases h

/-- Subformula letters are injective in the formula. -/
theorem clLetter_inj (φ : PlusFormula) {ψ χ : PlusFormula} (hψ : ψ ∈ plusSubformulaClosure φ)
    (hχ : χ ∈ plusSubformulaClosure φ) : clLetter φ hψ = clLetter φ hχ ↔ ψ = χ :=
  ⟨fun h => by cases h; rfl, fun h => by subst h; rfl⟩

end Alphabet

/-! ## The local run conditions -/

/-- **The local run conditions** (HWZ 2000, Definition 11, on a colouring of `ℤ` over the closure
alphabet). For every closure formula of the relevant shape, the colouring respects it pointwise;
the `untl`/`snce` clauses are those of `PlusTruthAt` verbatim — strict, with the guard on the
open interval. `atom`, `box` and `stab` impose no run condition (see the module header; they are
fixed by `Anchored`). -/
structure LocalRun (φ : PlusFormula) (c : (clSig φ).preds → ℤ → Prop) : Prop where
  /-- The `⊥` letter holds nowhere. -/
  bot : ∀ (h : PlusFormula.bot ∈ plusSubformulaClosure φ) (z : ℤ), ¬ c (clLetter φ h) z
  /-- The `imp` letter is the pointwise implication of its parts. -/
  imp : ∀ (ψ χ : PlusFormula) (h : PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ) (z : ℤ),
    c (clLetter φ h) z ↔
      (c (clLetter φ (plusClosure_imp_left φ ψ χ h)) z →
        c (clLetter φ (plusClosure_imp_right φ ψ χ h)) z)
  /-- The `untl` letter (`ψ U χ`, guard `ψ`, event `χ`): the event at some later `s`, the guard
  on the open interval `(z, s)`. -/
  untl : ∀ (ψ χ : PlusFormula) (h : PlusFormula.untl ψ χ ∈ plusSubformulaClosure φ) (z : ℤ),
    c (clLetter φ h) z ↔
      ∃ s : ℤ, z < s ∧ c (clLetter φ (plusClosure_untl_left φ χ ψ h)) s ∧
        ∀ r : ℤ, z < r → r < s → c (clLetter φ (plusClosure_untl_right φ χ ψ h)) r
  /-- The `snce` letter (`ψ S χ`): the mirror, with `s < z` and the guard on `(s, z)`. -/
  snce : ∀ (ψ χ : PlusFormula) (h : PlusFormula.snce ψ χ ∈ plusSubformulaClosure φ) (z : ℤ),
    c (clLetter φ h) z ↔
      ∃ s : ℤ, s < z ∧ c (clLetter φ (plusClosure_snce_left φ χ ψ h)) s ∧
        ∀ r : ℤ, s < r → r < z → c (clLetter φ (plusClosure_snce_right φ χ ψ h)) r

/-! ## The anchors and the trace -/

section Runs

variable {F : FrameOver intOrder}

/-- **The anchors of a colouring to a history**: `now` exactly at `t`; atoms by the valuation
at `σ`'s state; `box`-letters per time (truth along every history); `stab`-letters per state
(truth along every history sharing `σ`'s state at that time). These are the atomization licence
of `Seam.lean` point (e) and `plusTruthAt_iff_atomize`, stated as anchors rather than as run
conditions. -/
structure Anchored (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (c : (clSig φ).preds → ℤ → Prop) (σ : WorldHistory F.toTaskFrame) : Prop where
  /-- The marker is exactly at `t`. -/
  now : ∀ z : ℤ, c (clNow φ) z ↔ z = t
  /-- Atoms read the valuation at `σ`'s state. -/
  atom : ∀ (p : Atom) (h : PlusFormula.atom p ∈ plusSubformulaClosure φ) (z : ℤ),
    c (clLetter φ h) z ↔ M.valuation (σ.state z) p
  /-- `box`-letters are a per-time datum. -/
  box : ∀ (ψ : PlusFormula) (h : PlusFormula.box ψ ∈ plusSubformulaClosure φ) (z : ℤ),
    c (clLetter φ h) z ↔ ∀ σ' : WorldHistory F.toTaskFrame, PlusTruthAt M σ' z ψ
  /-- `stab`-letters are a per-state datum. -/
  stab : ∀ (ψ : PlusFormula) (h : PlusFormula.stab ψ ∈ plusSubformulaClosure φ) (z : ℤ),
    c (clLetter φ h) z ↔
      ∀ σ' : WorldHistory F.toTaskFrame, σ.state z = σ'.state z → PlusTruthAt M σ' z ψ

/-- **The trace of a history over the closure alphabet** (HWZ 2000, Theorem 14's `t_a`): every
subformula letter by `PlusTruthAt` along `σ`, the marker by `z = t`. -/
def clTrace (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : (clSig φ).preds → ℤ → Prop :=
  fun p z =>
    match p with
    | .inl ψ => PlusTruthAt M σ z ψ.1
    | .inr () => z = t

theorem clTrace_now (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) : clTrace M φ t σ (clNow φ) z ↔ z = t := Iff.rfl

theorem clTrace_letter (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ)
    (z : ℤ) : clTrace M φ t σ (clLetter φ h) z ↔ PlusTruthAt M σ z ψ := Iff.rfl

/-- The two-letter trace is the projection of the closure trace to `now` and `φ`,
definitionally. -/
theorem clTrace_proj (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) :
    seamTrace M φ t σ =
      fun b z => bif b then clTrace M φ t σ (clNow φ) z else clTrace M φ t σ (clPhi φ) z := rfl

end Runs

/-! ## The signature-generic bridge -/

section Bridge

/-- The depth-1 sentence `∃x (now x ∧ phi x)` over an arbitrary signature. -/
def nowPhiSig (sig : MonadicSignature) (now phi : sig.preds) : MonadicFormula sig 0 :=
  .ex (.and (.atom now 0) (.atom phi 0))

theorem nowPhiSig_depth (sig : MonadicSignature) (now phi : sig.preds) :
    (nowPhiSig sig now phi).quantifierDepth = 1 := rfl

/-- **The generic target**: the block satisfies `nowPhiSig`. -/
def stabTargetSig (sig : MonadicSignature) (now phi : sig.preds) :
    (sig.preds → ℤ → Prop) → Prop :=
  fun c => eval (zFiber sig c) Fin.elim0 (nowPhiSig sig now phi)

/-- The generic target is determined by the block's `k`-type at every depth `k ≥ 1`
(`determinedByKType_eval` on the depth-1 sentence). -/
theorem stabTargetSig_determined (sig : MonadicSignature) (now phi : sig.preds) (k : ℕ)
    (hk : 1 ≤ k) : DeterminedByKType sig k (stabTargetSig sig now phi) :=
  determinedByKType_eval sig k (nowPhiSig sig now phi) (by rw [nowPhiSig_depth]; exact hk)

/-- The generic target reads `P` at `t` off any colouring with `now` exactly at `t` and `phi`
exactly where `P` holds — the analogue of `stabTarget_seamTrace` under the two anchor
hypotheses. -/
theorem stabTargetSig_of_trace (sig : MonadicSignature) (now phi : sig.preds)
    (c : sig.preds → ℤ → Prop) (t : ℤ) (P : ℤ → Prop) (hnow : ∀ z, c now z ↔ z = t)
    (hphi : ∀ z, c phi z ↔ P z) : stabTargetSig sig now phi c ↔ P t := by
  simp only [stabTargetSig, nowPhiSig, eval, zFiber, Fin.cons_zero]
  constructor
  · rintro ⟨z, hz, h⟩
    rw [hnow] at hz
    subst hz
    exact (hphi _).mp h
  · intro h
    exact ⟨t, (hnow t).mpr rfl, (hphi t).mpr h⟩

/-- At the two-letter instance the generic sentence and target are the landed ones. -/
theorem nowPhiSig_twoLetter : nowPhiSig twoLetter true false = nowPhi := rfl

theorem stabTargetSig_twoLetter : stabTargetSig twoLetter true false = stabTarget := rfl

variable {F : FrameOver intOrder} [F.IsRegular]

/-- **The realized family triples of an arbitrary trace map over an arbitrary signature**: those
reached by `tr` on the splice of some ray pair through the seam. A `Set`, exactly as `Hit` is;
nothing here computes it. No model appears: the trace map `tr` is the only interface, and the
bridge's anchor hypotheses (`plusStab_iff_forall_hitSig`) are what tie `tr` to a model. -/
def HitSig (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (tr : WorldHistory F.toTaskFrame → sig.preds → ℤ → Prop) (k : ℕ) :
    Set (KType sig k × KType sig k × KType sig k) :=
  {x | ∃ bf : SeqPair F (τ.state t), InFamily sig k x.1 x.2.1 x.2.2 (tr (spliced τ t bf))}

/-- `Hit` is `HitSig` at the two-letter instance, definitionally. -/
theorem hitSig_twoLetter (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) :
    HitSig twoLetter τ t (seamTrace M φ t) k = Hit M τ t φ k := rfl

/-- There are finitely many realized triples, because there are finitely many triples at all
(`finite_family_triples`). -/
theorem hitSig_finite (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (tr : WorldHistory F.toTaskFrame → sig.preds → ℤ → Prop) (k : ℕ) :
    (HitSig sig τ t tr k).Finite := by
  haveI := finite_family_triples sig k
  exact Set.toFinite _

/-- **The hypothesis-free `⊡` bridge over an arbitrary signature** with distinguished letters
`now` and `phi` and any trace map anchored by them (`now` exactly at `t`, `phi` exactly where
`φ` is true). Same proof as `plusStab_iff_forall_hit`: forward, `⊡φ` gives `φ` along every ray
pair (`plusStab_iff_omega`), so the target holds on every realized trace
(`stabTargetSig_of_trace`), and saturation (`family_saturation`, from
`stabTargetSig_determined`) spreads it over the whole family; backward, every ray pair's trace
lies in some family (`family_cover`), realized by that very pair. `plusStab_iff_forall_hit` is
the instance `sig := twoLetter`, `now := true`, `phi := false`, `tr := seamTrace M φ t`
(`hitSig_twoLetter`, `stabTargetSig_twoLetter`). `HitSig` is not computed.

Paper: — (the formalization's own seam interface; the paper has no counterpart) -/
theorem plusStab_iff_forall_hitSig (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (now phi : sig.preds) (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (tr : WorldHistory F.toTaskFrame → sig.preds → ℤ → Prop)
    (hnow : ∀ σ z, tr σ now z ↔ z = t)
    (hphi : ∀ σ z, tr σ phi z ↔ PlusTruthAt M σ z φ) (k : ℕ) (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ x ∈ HitSig sig τ t tr k,
        ∀ c, InFamily sig k x.1 x.2.1 x.2.2 c → stabTargetSig sig now phi c := by
  rw [plusStab_iff_omega]
  constructor
  · rintro hall ⟨τneg, τzero, τpos⟩ ⟨bf, hbf⟩ c hc
    rcases family_saturation sig k (stabTargetSig_determined sig now phi k hk) τneg τzero τpos
      with hin | hout
    · exact hin c hc
    · exact absurd
        ((stabTargetSig_of_trace sig now phi _ t _ (hnow _) (hphi _)).mpr (hall bf)) (hout _ hbf)
  · intro hhit bf
    obtain ⟨τneg, τzero, τpos, hfam⟩ := family_cover sig k (tr (spliced τ t bf))
    exact (stabTargetSig_of_trace sig now phi _ t _ (hnow _) (hphi _)).mp
      (hhit (τneg, τzero, τpos) ⟨bf, hfam⟩ _ hfam)

/-- The two-letter bridge, recovered from the generic one at its instance — a consistency check
that the generalisation lost nothing. -/
theorem plusStab_iff_forall_hit' (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ tr ∈ Hit M τ t φ k, ∀ c, InFamily twoLetter k tr.1 tr.2.1 tr.2.2 c → stabTarget c :=
  plusStab_iff_forall_hitSig twoLetter true false M τ t φ (seamTrace M φ t)
    (fun _ _ => Iff.rfl) (fun _ _ => Iff.rfl) k hk

end Bridge

end FormalSystem.Metalogic.Decidability.RaySummary
