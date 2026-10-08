/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Seam

/-!
# The seam interface, corrected — the single-family bundle is seam decidedness, and the
hypothesis-free `⊡` bridge over the realized family triples

This module records what the hypothesis bundle `Presents` of `Seam.lean` actually says, and
states the shape in which the `⊡` bridge holds **without** a hypothesis bundle. Read the four
points in order; (b) is the one that bounds every claim made here.

**(a) What is established.**

1. *The characterization.* For every signature `sig` and depth `k`, the single-family bundle
   `Presents M τ t φ sig k T S` is inhabited for some `T` and `S` **iff** `φ` is `⊡`-decided at
   the seam — `⊡φ ∨ ⊡¬φ` at `(τ, t)` (`SeamDecided`, `exists_presents_iff`). Forward
   (`seamDecided_of_presents`) uses `colours`, `determined` and `verdict` through
   `family_saturation`; `realized` is not needed. Backward (`exists_presents_of_seamDecided`)
   is the constant target carrying the answer, with the seam's own history as the realizing
   pair. The parameters `sig` and `k` are inert. So `Presents.colours`, in the landed shape, is
   a **seam condition**, not the MSO-over-`⟨ℤ,<⟩` reduction its docstring once called it; the
   fixture-level consequence — a regular `ℤ`-frame seam at which no inhabitant exists for any
   parameters — is held in place by the wired evidence probe
   `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`.
2. *The two-letter interface.* Over the signature `twoLetter` (`true` the seam marker `now`,
   `false` the letter `φ`), the trace `seamTrace M φ t σ` of a history `σ` is the colouring
   "`now` exactly at `t`; `φ` where `φ` holds along `σ`", and the target `stabTarget` is the
   depth-1 sentence `nowPhi := ∃x (now x ∧ φ x)` evaluated on the block. `stabTarget` is
   `k`-type-determined for every `k ≥ 1` (`stabTarget_determined`, from
   `determinedByKType_eval`), and it reads `φ`'s truth at the seam off the trace
   (`stabTarget_seamTrace`).
3. *The hypothesis-free bridge.* `Hit M τ t φ k` is the set of family triples realized by some
   ray pair's trace through the seam; it is finite (`hit_finite`, from
   `finite_family_triples`), and `⊡φ` holds at the seam iff `stabTarget` holds on every block
   of every realized family (`plusStab_iff_forall_hit`). No hypothesis bundle: the statement is
   a theorem over `Hit`.
4. *The multi-family bundle is inhabited.* `PresentsMulti` is `Presents` with the summary's one
   triple replaced by a set of triples, same four fields; its bridge is
   `plusStab_iff_presentsMulti`, and `presentsMulti_seamTrace` inhabits it outright under the
   trace encoding, with `hit := Hit M τ t φ k` and `holds := decide (⊡φ)` under
   `open Classical`.

**(b) What is NOT established.** `Hit` is a semantic set — it is **not computed** anywhere in
this tree, and nothing here says how to compute it. `presentsMulti_seamTrace`'s `Bool` is
`decide` under `open Classical`: it carries the answer, it does not find it. No decision
procedure is built, no decidability result is proved, and no complexity bound is claimed, upper
or lower. The exhibited undecided seam in the evidence probe is forward-only (`⊡(Fp)`); there is
still no backward Bool-fixture bridge, and `pastStab_iff_allBwdPathsMeet` on the asymmetric
fixture remains the only backward fixture result. Every statement here is under `[F.IsRegular]`,
over the time axis, with a finite alphabet of per-time summaries; nothing reintroduces a
finite-fibre or finite-width assumption.

**(c) The residue, named.** The reduction's remaining content is exactly computing `Hit`: the
realizability direction — which family triples are reached by an actual ray pair through the
seam (Hodkinson–Wolter–Zakharyaschev, APAL 106 (2000), Definition 12 and Theorem 14, with the
one-sided-liveness repair point (d) of `Seam.lean` describes) — together with an effective
composition of `k`-types along the seam, and, before any of that, widening the two-letter
alphabet to a subformula-closure signature with local run conditions. Those are the successor
record's work; after them comes the quantification over models, which is the assembly record's
own frame. None is attempted here.

**(d) References.** Hodkinson–Wolter–Zakharyaschev 2000, Definitions 10–12, Theorem 14 (trace
of a history, realized types, universal-over-histories as a conjunction over realized types);
Gabbay–Kurucz–Wolter–Zakharyaschev 2003, Theorem 1.28, Lemma 11.23, Theorem 13.6 (the
quasimodel frame); Thomas 1997 §5.1 (the complementation step, `family_saturation`); Doets 1989
§1 (`k`-types determine depth-`≤ k` truth, `determinedByKType_eval`).

## Main definitions and results

* `SeamDecided` — `⊡φ ∨ ⊡¬φ` at the seam.
* `exists_presents_iff` — the single-family bundle is inhabited iff the seam is decided.
* `twoLetter`, `seamTrace`, `nowPhi`, `stabTarget` — the two-letter trace encoding and the
  depth-1 target.
* `Hit`, `hit_finite` — the realized family triples, finitely many.
* `plusStab_iff_forall_hit` — the hypothesis-free `⊡` bridge over `Hit`.
* `PresentsMulti`, `plusStab_iff_presentsMulti`, `presentsMulti_seamTrace` — the multi-family
  bundle, its bridge, and its inhabitant under the trace encoding.

## References

* [D. M. Gabbay, A. Kurucz, F. Wolter, M. Zakharyaschev, *Many-Dimensional Modal
  Logics*][gabbay2003manyvalued], Theorem 1.28, Lemma 11.23, Theorem 13.6 (the quasimodel frame).
* I. Hodkinson, F. Wolter, M. Zakharyaschev, *Decidable fragments of first-order temporal
  logics*, Annals of Pure and Applied Logic 106 (2000), Definitions 10–12, Theorem 14, Lemma 17.
* [K. Doets, *Monadic $\Pi^1_1$-Theories of $\Pi^1_1$-Properties*][doets1989], Section 1.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness FormalSystem.Semantics

/-! ## The characterization: the single-family bundle is seam decidedness -/

section Obstruction

variable {F : FrameOver intOrder} [F.IsRegular]

/-- **`φ` is `⊡`-decided at the seam `(τ, t)`**: every history through the seam state agrees
on `φ` there — `⊡φ` or `⊡¬φ`. -/
def SeamDecided (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) : Prop :=
  PlusTruthAt M τ t (.stab φ) ∨ PlusTruthAt M τ t (.stab φ.neg)

/-- **The obstruction.** An inhabitant of the single-family bundle decides the seam: if the
verdict is `true`, `⊡φ` by `plusStab_iff_seamSummary`; otherwise `verdict` puts the
representative block outside `T`, saturation (`family_saturation`, from `determined`) puts the
whole family outside `T`, and `colours` then refutes `φ` along every ray pair, i.e. `⊡¬φ` by
`plusStab_iff_omega`. The field `realized` is not used. -/
theorem seamDecided_of_presents {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : ℕ} {T : (sig.preds → ℤ → Prop) → Prop} {S : SeamSummary sig k}
    (h : Presents M τ t φ sig k T S) : SeamDecided M τ t φ := by
  by_cases hS : S.holds = true
  · exact Or.inl ((plusStab_iff_seamSummary h).mpr hS)
  · right
    rw [plusStab_iff_omega]
    intro bf
    rw [PlusTruth.neg_iff]
    intro hφ
    obtain ⟨c, hc, hbf⟩ := h.colours bf
    obtain ⟨c₀, hc₀, hv⟩ := h.verdict
    have hT₀ : ¬ T c₀ := fun hT => hS (hv.mpr hT)
    rcases family_saturation sig k h.determined S.τneg S.τzero S.τpos with hin | hout
    · exact hT₀ (hin c₀ hc₀)
    · exact hout c hc (hbf.mp hφ)

/-- **The trivial witness.** When the seam is decided, the constant target carrying the answer
inhabits the bundle for every `sig` and `k`: the family is `family_cover` of the everywhere-true
colouring, `T` is the constant `⊡φ`, the verdict is `decide (⊡φ)`, and the seam's own history
(`seamOmegaEquiv t (τ.state t) ⟨τ, rfl⟩`) is the realizing ray pair. -/
theorem exists_presents_of_seamDecided {M : TaskModel F.toTaskFrame}
    {τ : WorldHistory F.toTaskFrame} {t : ℤ} {φ : PlusFormula} (hdec : SeamDecided M τ t φ)
    (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) :
    ∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k),
      Presents M τ t φ sig k T S := by
  classical
  obtain ⟨τneg, τzero, τpos, hfam⟩ := family_cover sig k (fun _ _ => True)
  have hval : ∀ bf : SeqPair F (τ.state t),
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔
        PlusTruthAt M τ t (.stab φ)) := by
    intro bf
    rcases hdec with hall | hnone
    · exact ⟨fun _ => hall, fun h => (plusStab_iff_omega M τ t φ).mp h bf⟩
    · have hn := (plusStab_iff_omega M τ t φ.neg).mp hnone bf
      rw [PlusTruth.neg_iff] at hn
      exact ⟨fun h => absurd h hn, fun h => absurd ((plusStab_iff_omega M τ t φ).mp h bf) hn⟩
  refine ⟨fun _ => PlusTruthAt M τ t (.stab φ),
    ⟨τneg, τzero, τpos, decide (PlusTruthAt M τ t (.stab φ))⟩, ?_, ?_, ?_, ?_⟩
  · intro bf
    exact ⟨fun _ _ => True, hfam, hval bf⟩
  · intro c c' _
    exact Iff.rfl
  · intro c _
    exact ⟨seamOmegaEquiv t (τ.state t) ⟨τ, rfl⟩, hval _⟩
  · exact ⟨fun _ _ => True, hfam, decide_eq_true_iff⟩

/-- **The characterization.** The parameters are inert: for every `sig` and `k`, the
single-family bundle is inhabited iff the seam is decided. This is the machine-checked statement
that `Presents.colours`, in the landed shape, is a seam condition and not the MSO reduction. -/
theorem exists_presents_iff {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) :
    (∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k),
      Presents M τ t φ sig k T S) ↔ SeamDecided M τ t φ :=
  ⟨fun ⟨_, _, h⟩ => seamDecided_of_presents h, fun h => exists_presents_of_seamDecided h sig k⟩

end Obstruction

/-! ## The two-letter interface and the hypothesis-free bridge -/

section Trace

/-- Two letters: `true` is the seam marker `now`, `false` is `φ`. -/
abbrev twoLetter : MonadicSignature := ⟨Bool⟩

instance : Fintype twoLetter.preds := inferInstanceAs (Fintype Bool)
instance : DecidableEq twoLetter.preds := inferInstanceAs (DecidableEq Bool)

variable {F : FrameOver intOrder} [F.IsRegular]

/-- The spliced history of a ray pair through the seam. -/
abbrev spliced (τ : WorldHistory F.toTaskFrame) (t : ℤ) (bf : SeqPair F (τ.state t)) :
    WorldHistory F.toTaskFrame :=
  ((seamOmegaEquiv t (τ.state t)).symm bf).1

/-- **The trace of a history**: the marker `now` exactly at `t`, and `φ`'s truth along the
history (HWZ 2000, Theorem 14's trace, cut to two letters). -/
def seamTrace (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : twoLetter.preds → ℤ → Prop :=
  fun (p : Bool) z => bif p then z = t else PlusTruthAt M σ z φ

/-- The depth-1 sentence `∃x (now x ∧ φ x)`. -/
def nowPhi : MonadicFormula twoLetter 0 := .ex (.and (.atom true 0) (.atom false 0))

theorem nowPhi_depth : nowPhi.quantifierDepth = 1 := rfl

/-- **The target**: the block satisfies `nowPhi`. -/
def stabTarget : (twoLetter.preds → ℤ → Prop) → Prop :=
  fun c => eval (zFiber twoLetter c) Fin.elim0 nowPhi

/-- **Field `determined`, discharged** at every depth `k ≥ 1`, by `determinedByKType_eval`
(Doets 1989, Lemma 1.1) on the depth-1 sentence `nowPhi`. -/
theorem stabTarget_determined (k : ℕ) (hk : 1 ≤ k) : DeterminedByKType twoLetter k stabTarget :=
  determinedByKType_eval twoLetter k nowPhi (by rw [nowPhi_depth]; exact hk)

omit [F.IsRegular] in
/-- The target reads `φ`'s truth at the seam off the trace: `nowPhi` holds on the trace of `σ`
iff `φ` holds at `t` along `σ`. -/
theorem stabTarget_seamTrace (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) :
    stabTarget (seamTrace M φ t σ) ↔ PlusTruthAt M σ t φ := by
  simp only [stabTarget, nowPhi, eval, zFiber, seamTrace, Fin.cons_zero, cond_true, cond_false]
  constructor
  · rintro ⟨z, rfl, h⟩
    exact h
  · intro h
    exact ⟨t, rfl, h⟩

/-- **The realized family triples**: those reached by the trace of some ray pair through the
seam (HWZ 2000, Definition 12's realized types, at the seam). This set is semantic — nothing in
this tree computes it — and it is the entire residue of the reduction. -/
def Hit (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) :
    Set (KType twoLetter k × KType twoLetter k × KType twoLetter k) :=
  {tr | ∃ bf : SeqPair F (τ.state t),
    InFamily twoLetter k tr.1 tr.2.1 tr.2.2 (seamTrace M φ t (spliced τ t bf))}

/-- There are finitely many realized triples, because there are finitely many triples at all
(`finite_family_triples`, from `kType_finite`). -/
theorem hit_finite (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) : (Hit M τ t φ k).Finite := by
  haveI := finite_family_triples twoLetter k
  exact Set.toFinite _

/-- **The hypothesis-free `⊡` bridge.** `⊡φ` holds at the seam iff `stabTarget` holds on every
block of every realized family — a finite conjunction over `Hit`, with no hypothesis bundle.
Forward: `⊡φ` gives `φ` along every ray pair (`plusStab_iff_omega`), so the target holds on
every realized trace (`stabTarget_seamTrace`), and saturation (`family_saturation`, from
`stabTarget_determined`) spreads it over the whole family. Backward: every ray pair's trace lies
in some family (`family_cover`), which is realized by that very pair, so the target holds on it
and `φ` holds along the pair. `Hit` is not computed.

Paper: — (the formalization's own seam interface; the paper has no counterpart) -/
theorem plusStab_iff_forall_hit (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ tr ∈ Hit M τ t φ k, ∀ c, InFamily twoLetter k tr.1 tr.2.1 tr.2.2 c → stabTarget c := by
  rw [plusStab_iff_omega]
  constructor
  · rintro hall ⟨τneg, τzero, τpos⟩ ⟨bf, hbf⟩ c hc
    rcases family_saturation twoLetter k (stabTarget_determined k hk) τneg τzero τpos with
      hin | hout
    · exact hin c hc
    · exact absurd ((stabTarget_seamTrace M φ t _).mpr (hall bf)) (hout _ hbf)
  · intro hhit bf
    obtain ⟨τneg, τzero, τpos, hfam⟩ :=
      family_cover twoLetter k (seamTrace M φ t (spliced τ t bf))
    exact (stabTarget_seamTrace M φ t _).mp (hhit (τneg, τzero, τpos) ⟨bf, hfam⟩ _ hfam)

/-! ## The multi-family bundle -/

/-- **The multi-family bundle**: `Presents` with the summary's one triple replaced by a set of
triples `hit`. Same four fields, each named for the obligation it carries; `colours` now asks
only that every ray pair's block lie in *some* realized family. -/
structure PresentsMulti (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) (T : (sig.preds → ℤ → Prop) → Prop)
    (hit : Set (KType sig k × KType sig k × KType sig k)) (holds : Bool) : Prop where
  /-- Every ray pair is summarised by a block of some family in `hit` carrying `φ`'s truth
  along it as its `T`-value. -/
  colours : ∀ bf : SeqPair F (τ.state t), ∃ c : sig.preds → ℤ → Prop, ∃ tr ∈ hit,
    InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
  /-- The target is determined by the block's `k`-type. -/
  determined : DeterminedByKType sig k T
  /-- Joint realization: every family in `hit` has a block realized by some ray pair. -/
  realized : ∀ tr ∈ hit, ∃ c : sig.preds → ℤ → Prop, InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧
    ∃ bf : SeqPair F (τ.state t),
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
  /-- The verdict is `T` at a representative of every family in `hit`. -/
  verdict : holds = true ↔ ∀ tr ∈ hit, ∃ c, InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧ T c

/-- **The multi-family bridge.** Under `PresentsMulti`, `⊡φ` holds at the seam iff the verdict
is `true`: the same argument as `plusStab_iff_seamSummary`, with `realized` supplying a
representative per family and saturation (`family_saturation`, from `determined`) spreading `T`
over each. -/
theorem plusStab_iff_presentsMulti {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : ℕ} {T : (sig.preds → ℤ → Prop) → Prop}
    {hit : Set (KType sig k × KType sig k × KType sig k)} {holds : Bool}
    (h : PresentsMulti M τ t φ sig k T hit holds) :
    PlusTruthAt M τ t (.stab φ) ↔ holds = true := by
  rw [plusStab_iff_omega, h.verdict]
  constructor
  · intro hall tr htr
    obtain ⟨c, hc, bf, hbf⟩ := h.realized tr htr
    exact ⟨c, hc, hbf.mp (hall bf)⟩
  · intro hhit bf
    obtain ⟨c, tr, htr, hc, hbf⟩ := h.colours bf
    obtain ⟨c₀, hc₀, hT₀⟩ := hhit tr htr
    rcases family_saturation sig k h.determined tr.1 tr.2.1 tr.2.2 with hin | hout
    · exact hbf.mpr (hin c hc)
    · exact absurd hT₀ (hout c₀ hc₀)

open Classical in
/-- **The multi-family bundle is inhabited under the trace encoding**, with `hit` the realized
set `Hit` and the verdict `decide (⊡φ)`. All four fields discharge: `colours` and `realized` by
`family_cover` and `stabTarget_seamTrace`, `determined` by `stabTarget_determined`, `verdict` by
`plusStab_iff_forall_hit`. The `Bool` is classical — it carries the answer rather than
computing it; the residue is computing `Hit`. -/
theorem presentsMulti_seamTrace (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    PresentsMulti M τ t φ twoLetter k stabTarget (Hit M τ t φ k)
      (decide (PlusTruthAt M τ t (.stab φ))) where
  colours bf := by
    obtain ⟨τneg, τzero, τpos, hfam⟩ :=
      family_cover twoLetter k (seamTrace M φ t (spliced τ t bf))
    exact ⟨_, (τneg, τzero, τpos), ⟨bf, hfam⟩, hfam, (stabTarget_seamTrace M φ t _).symm⟩
  determined := stabTarget_determined k hk
  realized tr htr := by
    obtain ⟨bf, hbf⟩ := htr
    exact ⟨_, hbf, bf, (stabTarget_seamTrace M φ t _).symm⟩
  verdict := by
    rw [decide_eq_true_iff, plusStab_iff_forall_hit M τ t φ k hk]
    constructor
    · intro hall tr htr
      obtain ⟨bf, hbf⟩ := htr
      exact ⟨_, hbf, hall tr ⟨bf, hbf⟩ _ hbf⟩
    · intro hex tr htr c hc
      obtain ⟨c₀, hc₀, hT₀⟩ := hex tr htr
      rcases family_saturation twoLetter k (stabTarget_determined k hk) tr.1 tr.2.1 tr.2.2 with
        hin | hout
      · exact hin c hc
      · exact absurd hT₀ (hout c₀ hc₀)

end Trace

end FormalSystem.Metalogic.Decidability.RaySummary
