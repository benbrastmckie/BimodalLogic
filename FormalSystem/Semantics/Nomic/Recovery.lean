/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Nomic.Frame

/-!
# `lem:nomic-recovery`: the law-histories recover the relativized relation

Two world states of a nomic frame determine the same law-histories exactly when they determine
the same relativized task relation: `H_F^w = H_F^u` iff `⇒ʷ = ⇒ᵘ`. The easy direction is
definitional — `H_F^w` is defined purely in terms of `⇒ʷ` — and the substantive one runs the
paper's own argument: given `p ⇒ʷ_d q` with `d > 0`, the **two-point partial history**
`{⟨0, p⟩, ⟨d, q⟩}` extends to a possible world of `F^w` by `thm:extension`, that world is a
law-history at `w`, hence at `u`, and reading its task-respect obligation at the pair `⟨0, d⟩`
gives `p ⇒ᵘ_d q`. The duration-zero case is `lem:nullity` at both members; the negative case is
the reflection convention of `def:task-relation` reducing to the positive one.

## Why the two-point history is a general lemma over `TaskFrame`

`exists_worldHistory_two_point` is stated for an arbitrary `F : TaskFrame` with
`p q : F.WorldState`, not inline at `F.at w`. This is not stylistic. An inline construction at
`F.at w` elaborates the `if`-terms at `(F.at w).WorldState` while the surrounding `have`s state
them at `F.World`; the two are definitionally equal but not syntactically so, and all four
`respects_task` branches then fail on `rw` with an application type mismatch. Factoring the
construction out as a lemma over `TaskFrame` removes the mismatch, because the carrier is then a
single opaque type throughout the proof.

Its proper home is beside `PartialHistory.point` and `PartialHistory.occurrence` in
`Semantics/Extension/Extension.lean`; it is declared here, in
`namespace FormalSystem.Semantics.PartialHistory`, so that promoting it there later is a pure file
move with no rename. `Semantics/DeterministicBridge.lean` carries the same construction inline
and can be rewritten as one call to this lemma whenever that file is free; that refactor is not
done here.

## Main Results

- `PartialHistory.exists_worldHistory_two_point` — the two-point partial history, extended to a
  possible world by `thm:extension`
- `NomicFrame.taskRel_imp_of_lawHist_eq` — the one-directional helper `lem:nomic-recovery`'s
  forward direction applies twice, once in each orientation
- `NomicFrame.lawHist_eq_iff_taskRel_eq` — `lem:nomic-recovery` itself

## Choice dependence, recorded honestly

Both recovery results are theorems of **ZFC**, not of ZF: they consume `thm:extension`, whose
proof appeals to Zorn's lemma. `rmk:choice` lists the paper's choice-free results and these are
not among them. Nothing here advertises them as choice-free.
-/

namespace FormalSystem.Semantics

namespace PartialHistory

/--
**The two-point partial history.** In a regular frame, a single task fact `p ⇒_d q` at a nonzero
duration is realized by a possible world passing through `p` at `0` and `q` at `d`.

The partial history is `{⟨0, p⟩, ⟨d, q⟩}`, whose four `respects_task` branches are discharged by
`lem:nullity` at `⟨0,0⟩`, the hypothesis at `⟨0,d⟩`, the derived reflection law at `⟨d,0⟩` — "the
pair `⟨d,0⟩` is the same fact under the reflection convention", in the paper's words — and
`lem:nullity` again at `⟨d,d⟩`. `thm:extension` then supplies the possible world. Decidability of
the `if` is free: `F.Duration` is a `LinearOrder`, so no `Classical` instance is needed to form
the state function.

Stated with `p q : F.WorldState` over an arbitrary `F : TaskFrame` deliberately — see this
module's docstring for the type mismatch that an inline construction at a relativized member
provokes, and for the note that this lemma belongs beside `PartialHistory.point` and
`PartialHistory.occurrence` once `Semantics/Extension/Extension.lean` is free to receive it.

**Choice dependence, recorded honestly.** A theorem of ZFC through `thm:extension`'s Zorn appeal,
not of ZF; `rmk:choice` does not list it among the paper's choice-free results.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem exists_worldHistory_two_point (F : TaskFrame) [F.IsRegular]
    (p q : F.WorldState) {d : F.Duration} (hd : (0 : F.Duration) ≠ d)
    (hpq : F.TaskRel p d q) :
    ∃ σ : WorldHistory F, σ.state 0 = p ∧ σ.state d = q := by
  have h0d : (if (0 : F.Duration) = d then q else p) = p := if_neg hd
  have hdd : (if d = d then q else p) = q := if_pos rfl
  have hresp : ∀ (s t : F.Duration), (s = 0 ∨ s = d) → (t = 0 ∨ t = d) →
      F.TaskRel (if s = d then q else p) (t - s) (if t = d then q else p) := by
    intro s t hs ht
    rcases hs with hs | hs <;> rcases ht with ht | ht <;> rw [hs, ht]
    · rw [h0d, sub_zero]; exact (F.nullity_identity p p).mpr rfl
    · rw [h0d, hdd, sub_zero]; exact hpq
    · rw [h0d, hdd, zero_sub]; exact (F.reflection p d q).mp hpq
    · rw [hdd, sub_self]; exact (F.nullity_identity q q).mpr rfl
  obtain ⟨σ, hext⟩ := PartialHistory.extension F
    { domain := fun t => t = 0 ∨ t = d
      nonempty_domain := ⟨0, Or.inl rfl⟩
      states := fun t _ => if t = d then q else p
      respects_task := fun s t hs ht => hresp s t hs ht }
  exact ⟨σ, (hext.agree 0 (Or.inl rfl)).trans h0d, (hext.agree d (Or.inr rfl)).trans hdd⟩

end PartialHistory

namespace NomicFrame

variable {D : TemporalOrder}

/--
`lem:nomic-recovery`'s working half, in the one-directional form the biconditional applies twice:
if `w` and `u` determine the same law-histories then every `⇒ʷ`-fact is a `⇒ᵘ`-fact.

The paper's case split, in the paper's order of content. At `d = 0` both relations collapse to
identity by `lem:nullity` (`FrameOver.nullity_identity`) at `F^w` and at `F^u`. At `d > 0` the
two-point history `{⟨0,p⟩,⟨d,q⟩}` extends to a possible world of `F^w` by `thm:extension`; that
world is a law-history at `w`, so by hypothesis at `u`, and its task-respect obligation at the
pair `⟨0,d⟩` *is* `p ⇒ᵘ_d q`. At `d < 0` the reflection convention turns the fact into a positive
one, which the previous case settles, and reflection at `F^u` turns it back.

The symmetric inclusion the paper gets "by symmetry" is this same lemma at `h.symm`, which is
why it is named rather than inlined.

**Choice dependence, recorded honestly.** A theorem of ZFC through `thm:extension`'s Zorn appeal.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem taskRel_imp_of_lawHist_eq (F : NomicFrame D) [F.IsRegular] {w u : F.World}
    (h : F.lawHist w = F.lawHist u) {p q : F.World} {d : ↑D}
    (hpq : F.TaskRel w p d q) : F.TaskRel u p d q := by
  have pos : ∀ (p q : F.World) (d : ↑D), 0 < d → F.TaskRel w p d q → F.TaskRel u p d q := by
    intro p q d hd hpq
    obtain ⟨σ, h0, hdq⟩ :=
      PartialHistory.exists_worldHistory_two_point (F.at w).toTaskFrame p q (ne_of_lt hd) hpq
    have hmem : σ.state ∈ F.lawHist u := h ▸ (F.mem_lawHist_iff w σ.state).mpr ⟨σ, rfl⟩
    have hres := hmem 0 d
    rwa [h0, hdq, sub_zero] at hres
  rcases lt_trichotomy d 0 with hlt | heq | hgt
  · have hrefl : F.TaskRel w q (-d) p := ((F.at w).reflection p d q).mp hpq
    have hpos := pos q p (-d) (by simpa using hlt) hrefl
    exact ((F.at u).reflection p d q).mpr hpos
  · subst heq
    have hpq' : p = q := ((F.at w).nullity_identity p q).mp hpq
    exact ((F.at u).nullity_identity p q).mpr hpq'
  · exact pos p q d hgt hpq

/--
`lem:nomic-recovery`: `H_F^w = H_F^u` if and only if `⇒ʷ = ⇒ᵘ`. The law-histories recover the
relativized relation, so a nomic frame's *Static* and *Uniform* properties can be read off the
relation as well as off the histories.

The `⇐` direction is immediate from `def:nomic-frame`, since `H_F^w` is defined purely in terms
of `⇒ʷ`; `simp only [lawHist, h]` is literally that observation. The `⇒` direction is
`taskRel_imp_of_lawHist_eq` in both orientations, `h` and `h.symm`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `thm:extension`'s Zorn appeal,
inherited from the helper above; `rmk:choice` does not list it among the paper's choice-free
results.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem lawHist_eq_iff_taskRel_eq (F : NomicFrame D) [F.IsRegular] (w u : F.World) :
    F.lawHist w = F.lawHist u ↔ F.TaskRel w = F.TaskRel u := by
  constructor
  · intro h
    funext p d q
    exact propext ⟨fun hpq => F.taskRel_imp_of_lawHist_eq h hpq,
      fun hpq => F.taskRel_imp_of_lawHist_eq h.symm hpq⟩
  · intro h
    simp only [lawHist, h]

end NomicFrame

end FormalSystem.Semantics
