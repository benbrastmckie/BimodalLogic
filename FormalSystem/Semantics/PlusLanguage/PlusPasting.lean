/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusValidity

/-!
# History pasting and the pasting validities of `⊡`

The one structural fact about `⟨τ⟩_x` that the S5 axioms of `⊡` miss: the total histories
through a world state are the **product of its possible pasts and its possible futures**. If two
total histories `ρ` and `σ` share a state at `t`, then `ρ|(-∞,t] ⌢ σ|(t,∞)` is again a total
history (`paste`), using only *Compositionality* (`TaskFrame.comp`) across `t` and the converse
convention (`TaskFrame.reflection`) for the reverse orientation — no *Saturation*, no extension
theorem, no frame-class assumption.

Pure-future formulas (`IsPureFuture`, `PlusLanguage/Formula.lean`) see only the history from
`t` onward (`truth_congr_agreeFrom`) and pure-past ones only the history up to `t`
(`truth_congr_agreeUpTo`); `□ψ` and `⊡ψ` are admitted as leaves of both because `□ψ` is
history-independent and `⊡ψ` depends on the present state alone. Four validities follow, all
with the purity side conditions:

| Name | Schema | Lean |
|------|--------|------|
| **PS** (same-time pasting) | `⟐φ⁺ ∧ ⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻)` | `paste_valid` |
| **US** (future pasting) | `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)` | `untl_dstab_valid` |
| **FS** | `F⟐φ⁺ → ⟐Fφ⁺` | `future_dstab_valid` (= US at `α⁻ := ⊤`) |
| **GS** | `⊡Gφ⁺ → G⊡φ⁺` | `stab_allFuture_valid` (the contrapositive reading of FS) |

together with the two **past mirrors** that temporal duality needs (`swapTemporal` exchanges
`IsPureFuture` and `IsPurePast`):

| Name | Schema | Lean |
|------|--------|------|
| PS, conjuncts exchanged | `⟐ψ⁻ ∧ ⟐φ⁺ → ⟐(ψ⁻ ∧ φ⁺)` | `paste_valid'` |
| **SS** (past pasting) | `(α⁺ S ⟐φ⁻) → ⟐(α⁺ S φ⁻)` | `snce_dstab_valid` |

PS and US are the two pasting **axioms** of TM⁺ (`PlusLanguage/Axioms.lean`); FS, GS and the
mirrors are derived (the mirrors by TD). The purity restrictions are **necessary**: the
refutations in `Semantics/PlusLanguage/PlusNonValidities.lean` show that `G⊡p → ⊡Gp` fails even for atoms
and that `⊡GPp → G⊡Pp` fails once a past operator enters the scope.

The `*_plusValid` packagings at the end state each validity as a `PlusValid`, the shape the
axiom-validity dispatch (`Metalogic/Conservativity/Plus/AxiomValidity.lean`) consumes.

## Provenance

`pasteFun` through `untl_dstab_valid` are transcriptions of Part C of the compiled
stability-modal probes recorded with the research on the `⊡` axiomatization; `paste_valid'` and
`snce_dstab_valid` are the mirrored arguments, new here.

## References

* JPL paper `def:frame` — *Compositionality* and the reflection convention
  (`Semantics/TaskFrame.lean`)
* `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` — `PlusTruthAt`

## Tags

plus-language · pasting · stability-modal
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open PlusTruth

variable {F : TaskFrame}

/-! ## Pasting two world histories at a shared state -/

/-- `ρ`'s states up to and including `t`, `σ`'s states after `t`. -/
def pasteFun (ρ σ : WorldHistory F) (t : F.Duration) : F.Duration → F.WorldState :=
  fun s => if s ≤ t then ρ.state s else σ.state s

/-- The task relation across the seam: from a `ρ`-state at `s ≤ t` to a `σ`-state at `s' > t`,
by *Compositionality* through the shared state at `t`. -/
theorem paste_rel_le_lt (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) {s s' : F.Duration} (hs : s ≤ t) (hs' : ¬ s' ≤ t) :
    F.TaskRel (ρ.state s) (s' - s) (σ.state s') := by
  have h1 : F.TaskRel (ρ.state s) (t - s) (ρ.state t) := ρ.val.respects_task s t _ _
  have h2 : F.TaskRel (σ.state t) (s' - t) (σ.state s') := σ.val.respects_task t s' _ _
  rw [hsame] at h1
  have heq : s' - s = (t - s) + (s' - t) := by
    rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm
  rw [heq]
  exact (F.comp _ _ _ _ (sub_nonneg.mpr hs) (sub_nonneg.mpr (le_of_lt (not_le.mp hs')))).mpr
    ⟨_, h1, h2⟩

/-- The pasted state function respects the task relation: composition across `t`
(`TaskFrame.comp`), the reflection convention for the reverse orientation. -/
theorem paste_rel (ρ σ : WorldHistory F) (t : F.Duration) (hsame : ρ.state t = σ.state t) :
    ∀ s s' : F.Duration, F.TaskRel (pasteFun ρ σ t s) (s' - s) (pasteFun ρ σ t s') := by
  intro s s'
  unfold pasteFun
  by_cases hs : s ≤ t <;> by_cases hs' : s' ≤ t
  · rw [if_pos hs, if_pos hs']; exact ρ.val.respects_task s s' _ _
  · rw [if_pos hs, if_neg hs']; exact paste_rel_le_lt ρ σ t hsame hs hs'
  · rw [if_neg hs, if_pos hs', F.reflection, neg_sub]; exact paste_rel_le_lt ρ σ t hsame hs' hs
  · rw [if_neg hs, if_neg hs']; exact σ.val.respects_task s s' _ _

/-- **Pasting.** If `ρ(t) = σ(t)` then `ρ|(-∞,t] ⌢ σ|(t,∞)` is a world history. -/
def paste (ρ σ : WorldHistory F) (t : F.Duration) (hsame : ρ.state t = σ.state t) :
    WorldHistory F :=
  WorldHistory.ofTotal F (pasteFun ρ σ t) (paste_rel ρ σ t hsame)

/-! ## Agreement of histories on a half-line -/

/-- `τ` and `σ` agree at every time `≥ t`. -/
def AgreeFrom (τ σ : WorldHistory F) (t : F.Duration) : Prop :=
  ∀ s, t ≤ s → τ.state s = σ.state s

/-- `τ` and `σ` agree at every time `≤ t`. -/
def AgreeUpTo (τ σ : WorldHistory F) (t : F.Duration) : Prop :=
  ∀ s, s ≤ t → τ.state s = σ.state s

theorem agreeFrom_mono {τ σ : WorldHistory F} {t s : F.Duration} (hts : t ≤ s)
    (h : AgreeFrom τ σ t) : AgreeFrom τ σ s :=
  fun r hsr => h r (le_trans hts hsr)

theorem agreeUpTo_mono {τ σ : WorldHistory F} {t s : F.Duration} (hst : s ≤ t)
    (h : AgreeUpTo τ σ t) : AgreeUpTo τ σ s :=
  fun r hrs => h r (le_trans hrs hst)

/-- The pasted history agrees with `σ` from `t` onward (at `t` itself by the shared state). -/
theorem paste_agreeFrom (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) : AgreeFrom (paste ρ σ t hsame) σ t := by
  intro s hts
  show pasteFun ρ σ t s = σ.state s
  unfold pasteFun
  by_cases h : s ≤ t
  · have : s = t := le_antisymm h hts
    subst this
    rw [if_pos le_rfl]; exact hsame
  · rw [if_neg h]

/-- The pasted history agrees with `ρ` up to `t`. -/
theorem paste_agreeUpTo (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) : AgreeUpTo (paste ρ σ t hsame) ρ t := by
  intro s hst
  show pasteFun ρ σ t s = ρ.state s
  unfold pasteFun
  rw [if_pos hst]

/-! ## Purity congruences -/

/-- A pure-future formula sees only the history from `t` onward. -/
theorem truth_congr_agreeFrom (M : TaskModel F) {φ : PlusFormula} (hφ : IsPureFuture φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), AgreeFrom τ σ t →
      (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ) := by
  induction hφ with
  | atom p =>
    intro τ σ t hag
    show M.valuation _ p ↔ M.valuation _ p
    rw [hag t le_rfl]
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    intro τ σ t hag
    exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | untl _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hts =>
      and_congr (ihφ τ σ s (agreeFrom_mono hts.le hag))
        (forall_congr' fun r => imp_congr_right fun htr => imp_congr_right fun _ =>
          ihψ τ σ r (agreeFrom_mono htr.le hag))

/-- A pure-past formula sees only the history up to `t`. -/
theorem truth_congr_agreeUpTo (M : TaskModel F) {φ : PlusFormula} (hφ : IsPurePast φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), AgreeUpTo τ σ t →
      (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ) := by
  induction hφ with
  | atom p =>
    intro τ σ t hag
    show M.valuation _ p ↔ M.valuation _ p
    rw [hag t le_rfl]
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    intro τ σ t hag
    exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | snce _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hst =>
      and_congr (ihφ τ σ s (agreeUpTo_mono hst.le hag))
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hrt =>
          ihψ τ σ r (agreeUpTo_mono hrt.le hag))

/-! ## The pasting validities -/

/-- **PS (same-time pasting)**: `⟐φ⁺ ∧ ⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻)` for pure-future `φ⁺` and pure-past
`ψ⁻`: the `ψ⁻`-witness up to `t` pasted with the `φ⁺`-witness after `t` satisfies both. -/
theorem paste_valid (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {φ ψ : PlusFormula} (hφ : IsPureFuture φ) (hψ : IsPurePast ψ) :
    PlusTruthAt M τ t (.imp (dstab φ) (.imp (dstab ψ) (dstab (φ.and ψ)))) := by
  intro h1 h2
  rw [dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hτρ, hψρ⟩ := h2
  have hsame : ρ.state t = σ.state t := hτρ.symm.trans hτσ
  refine ⟨paste ρ σ t hsame, hτρ.trans (paste_agreeUpTo ρ σ t hsame t le_rfl).symm, ?_⟩
  rw [and_iff]
  exact ⟨(truth_congr_agreeFrom M hφ _ _ t (paste_agreeFrom ρ σ t hsame)).mpr hφσ,
    (truth_congr_agreeUpTo M hψ _ _ t (paste_agreeUpTo ρ σ t hsame)).mpr hψρ⟩

/-- **PS with the conjuncts exchanged**: `⟐ψ⁻ ∧ ⟐φ⁺ → ⟐(ψ⁻ ∧ φ⁺)` for pure-past `ψ⁻` and
pure-future `φ⁺`. This is exactly the temporal dual of `paste_valid` (the `paste` axiom's
`swapTemporal` instance), proved by the same pasting argument. -/
theorem paste_valid' (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {ψ φ : PlusFormula} (hψ : IsPurePast ψ) (hφ : IsPureFuture φ) :
    PlusTruthAt M τ t (.imp (dstab ψ) (.imp (dstab φ) (dstab (ψ.and φ)))) := by
  intro h2 h1
  rw [dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hτρ, hψρ⟩ := h2
  have hsame : ρ.state t = σ.state t := hτρ.symm.trans hτσ
  refine ⟨paste ρ σ t hsame, hτρ.trans (paste_agreeUpTo ρ σ t hsame t le_rfl).symm, ?_⟩
  rw [and_iff]
  exact ⟨(truth_congr_agreeUpTo M hψ _ _ t (paste_agreeUpTo ρ σ t hsame)).mpr hψρ,
    (truth_congr_agreeFrom M hφ _ _ t (paste_agreeFrom ρ σ t hsame)).mpr hφσ⟩

/-- **FS**: `F⟐φ⁺ → ⟐Fφ⁺` for pure-future `φ⁺`: paste `τ` up to the witnessing future time with
the `φ⁺`-witness after it. -/
theorem future_dstab_valid (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) {φ : PlusFormula} (hφ : IsPureFuture φ) :
    PlusTruthAt M τ t (.imp (someFuture (dstab φ)) (dstab (someFuture φ))) := by
  intro h
  rw [someFuture_iff] at h
  obtain ⟨y, hty, hy⟩ := h
  rw [dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  rw [dstab_iff]
  refine ⟨paste τ ρ y hτρ, (paste_agreeUpTo τ ρ y hτρ t hty.le).symm, ?_⟩
  rw [someFuture_iff]
  exact ⟨y, hty, (truth_congr_agreeFrom M hφ _ _ y (paste_agreeFrom τ ρ y hτρ)).mpr hφρ⟩

/-- **GS**: `⊡Gφ⁺ → G⊡φ⁺` for pure-future `φ⁺` — the contrapositive reading of FS. Needs the
purity restriction: `⊡GPp → G⊡Pp` is refuted (`Semantics/PlusLanguage/PlusNonValidities.lean`). -/
theorem stab_allFuture_valid (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) {φ : PlusFormula} (hφ : IsPureFuture φ) :
    PlusTruthAt M τ t (.imp (.stab (allFuture φ)) (allFuture (.stab φ))) := by
  intro h
  rw [allFuture_iff]
  intro y hty ρ hτρ
  have hπ := h (paste τ ρ y hτρ) (paste_agreeUpTo τ ρ y hτρ t hty.le).symm
  rw [allFuture_iff] at hπ
  exact (truth_congr_agreeFrom M hφ _ _ y (paste_agreeFrom τ ρ y hτρ)).mp (hπ y hty)

/-- **US (future pasting)**: `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)` for pure-past `α⁻` and pure-future
`φ⁺`. FS is the instance `α⁻ := ⊤`. The pasted history keeps `τ`'s past, so the pure-past guard
on `(t, y)` is untouched, and the `φ⁺`-witness after `y` supplies the event. -/
theorem untl_dstab_valid (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) {α φ : PlusFormula} (hα : IsPurePast α) (hφ : IsPureFuture φ) :
    PlusTruthAt M τ t (.imp (.untl α (dstab φ)) (dstab (.untl α φ))) := by
  intro h
  rw [untl_iff] at h
  obtain ⟨y, hty, hy, hguard⟩ := h
  rw [dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  rw [dstab_iff]
  refine ⟨paste τ ρ y hτρ, (paste_agreeUpTo τ ρ y hτρ t hty.le).symm, ?_⟩
  rw [untl_iff]
  refine ⟨y, hty, (truth_congr_agreeFrom M hφ _ _ y (paste_agreeFrom τ ρ y hτρ)).mpr hφρ, ?_⟩
  intro r htr hry
  exact (truth_congr_agreeUpTo M hα _ τ r
    (agreeUpTo_mono hry.le (paste_agreeUpTo τ ρ y hτρ))).mpr (hguard r htr hry)

/-- **SS (past pasting)**: `(α⁺ S ⟐φ⁻) → ⟐(α⁺ S φ⁻)` for pure-future `α⁺` and pure-past `φ⁻` —
the `snce` mirror of US, and the temporal dual of the `untl_paste` axiom. The witness `ρ` at a
past time `y < t` is pasted up to `y` with `τ` after `y`: the pasted history keeps `τ`'s future
(so it shares `τ`'s state at `t` and the pure-future guard on `(y, t)` sees `τ`), and its past
up to `y` is `ρ`'s, where the pure-past event holds. -/
theorem snce_dstab_valid (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) {α φ : PlusFormula} (hα : IsPureFuture α) (hφ : IsPurePast φ) :
    PlusTruthAt M τ t (.imp (.snce α (dstab φ)) (dstab (.snce α φ))) := by
  intro h
  rw [snce_iff] at h
  obtain ⟨y, hyt, hy, hguard⟩ := h
  rw [dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  have hsame : ρ.state y = τ.state y := hτρ.symm
  rw [dstab_iff]
  refine ⟨paste ρ τ y hsame, (paste_agreeFrom ρ τ y hsame t hyt.le).symm, ?_⟩
  rw [snce_iff]
  refine ⟨y, hyt, (truth_congr_agreeUpTo M hφ _ _ y (paste_agreeUpTo ρ τ y hsame)).mpr hφρ, ?_⟩
  intro r hyr hrt
  exact (truth_congr_agreeFrom M hα _ τ r
    (agreeFrom_mono hyr.le (paste_agreeFrom ρ τ y hsame))).mpr (hguard r hyr hrt)

/-! ## Class-level packagings

Each validity as a `PlusValid`, the shape the axiom-validity dispatch consumes. All four are
class-free (valid over every task frame), so `PlusValid` — validity at `.Base` — is the
strongest statement and lifts to any class by `PlusValidIn.mono`. -/

/-- PS as a `PlusValid`. -/
theorem paste_plusValid {φ ψ : PlusFormula} (hφ : IsPureFuture φ) (hψ : IsPurePast ψ) :
    PlusValid (.imp (dstab φ) (.imp (dstab ψ) (dstab (φ.and ψ)))) :=
  PlusValid.of_forall fun _ M τ t => paste_valid M τ t hφ hψ

/-- PS with the conjuncts exchanged, as a `PlusValid`. -/
theorem paste'_plusValid {ψ φ : PlusFormula} (hψ : IsPurePast ψ) (hφ : IsPureFuture φ) :
    PlusValid (.imp (dstab ψ) (.imp (dstab φ) (dstab (ψ.and φ)))) :=
  PlusValid.of_forall fun _ M τ t => paste_valid' M τ t hψ hφ

/-- US as a `PlusValid`. -/
theorem untl_paste_starValid {α φ : PlusFormula} (hα : IsPurePast α) (hφ : IsPureFuture φ) :
    PlusValid (.imp (.untl α (dstab φ)) (dstab (.untl α φ))) :=
  PlusValid.of_forall fun _ M τ t => untl_dstab_valid M τ t hα hφ

/-- SS as a `PlusValid`. -/
theorem snce_paste_plusValid {α φ : PlusFormula} (hα : IsPureFuture α) (hφ : IsPurePast φ) :
    PlusValid (.imp (.snce α (dstab φ)) (dstab (.snce α φ))) :=
  PlusValid.of_forall fun _ M τ t => snce_dstab_valid M τ t hα hφ

/-- FS as a `PlusValid`. -/
theorem future_dstab_plusValid {φ : PlusFormula} (hφ : IsPureFuture φ) :
    PlusValid (.imp (someFuture (dstab φ)) (dstab (someFuture φ))) :=
  PlusValid.of_forall fun _ M τ t => future_dstab_valid M τ t hφ

/-- GS as a `PlusValid`. -/
theorem stab_allFuture_plusValid {φ : PlusFormula} (hφ : IsPureFuture φ) :
    PlusValid (.imp (.stab (allFuture φ)) (allFuture (.stab φ))) :=
  PlusValid.of_forall fun _ M τ t => stab_allFuture_valid M τ t hφ

end FormalSystem.Semantics
