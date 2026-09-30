/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Limits.Targets
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.TransId

/-!
# Hop-Free Families Are Incomplete

`TransId.lean` records that a family whose succession relation never leaves the index it is read
at — the *hop-free* condition `∀ u i j, S.trans u i j → i = j` — collapses (C1') to its
one-position form and (C2') to its per-lasso form. That collapse is a genuine simplification, and
it is what the hop-free producer is for. This module records its price: hop-freedom is
**incomplete**. There is a ℤ-time non-validity of `PlusFormula`, namely `hopTarget p`, that no
hop-free family certifies — at any time, for any lasso count, and for any labelling whatsoever.

## The argument

Let `S` be hop-free and suppose `S.PlusCertifies t`. Then:

1. (C4) puts `hopTarget p` outside the main label at `t`, and (C1')'s `imp` clause unwinds that
   into `□⟐Xp ∈ S.main t` and `□⟐X¬p ∈ S.main t`.
2. (C3) turns both box labels into `S.bx`-truths and hence into `⟐Xp ∈ S.L i u` and
   `⟐X¬p ∈ S.L i u` at **every** index and **every** time.
3. (C5) reads each `⟐` as the failure of a `⊡`, i.e. as the existence of a share-class member
   omitting the negated `X`-formula; (C1')'s `imp` and `bot` clauses turn that omission into
   membership of the `X`-formula itself, and the reflexive instance of the `untl` clause then puts
   `p` (resp. `p → ⊥`) in a label one step later. So at every index and time there is a
   share-class member branching to `p` and one branching to `¬p`.
4. (C0) makes atom-membership a function of the world state, so the two branches cannot both share
   the main index's own state at the next time: at every time `u` the main index's state has a
   successor state **distinct from its own**.
5. Each such deviation is a state path of the frame, so `lift` tracks it by a succession path. Under
   hop-freedom a succession path is constant. A path that agrees with the main index up to `m` and
   deviates at `m + 1` is therefore tracked by an index that cannot also track the path that
   deviates at any later time, so the `lassos.length + 1` deviation times `0, 1, …, lassos.length`
   receive pairwise distinct tracking indices — `lassos.length + 1` of them in a type of
   cardinality `lassos.length`.

Step 5 is where hop-freedom is spent: a family with `n` indices presents at most `n` constant
succession paths, while the target forces unboundedly many genuinely distinct state paths.

## What this does **not** say

* It does not say `TransId.lean` is wrong. `plusLocalCoherentShare_of_transId`,
  `transId_forces_const_thread`, `thread_eq_const_of_transId` and `plusThreadFulfilling_of_transId`
  remain true, remain proved, and remain in the tree. This module bounds a *strategy* for producing
  certificates, not the substrate those four theorems are about.
* It does not say the six-condition certificate class is incomplete. That is a strictly stronger
  claim about families with no hypothesis on `trans` at all, and it is `Limits/NoCertificate.lean`'s
  business, against a different target.
* It does not say `hopTarget p` is unrefutable. It *is* refutable —
  `not_plusValidZTime_hopTarget` is a theorem — just not by a hop-free certificate.

The hypothesis is spelled exactly as `TransId.lean`'s `hid`, so the theorem below and that
module's four collapse theorems are demonstrably about the same class of families.

## Provenance

Transcription of the compiled hop-freedom probe recorded with the second research round on L⁺
compression. The argument is unchanged; what changes is that the target, its non-validity and its
thirteen-step closure chain are now the library declarations of `Limits/Targets.lean` rather than
probe-local definitions, and the theorem is parametric in the atom.

## Main Results

- `PlusSharingWitnessFamily.not_plusCertifies_hopTarget_of_hopFree` — no hop-free family
  certifies `hopTarget p`, universally quantified
- `PlusSharingWitnessFamily.not_exists_hopFree_plusCertifies_hopTarget` — the same, in the
  existential shape the plan's Lean Challenge Statement pins
- `PlusSharingWitnessFamily.hopFree_branchesTrue`, `.hopFree_branchesFalse` — the forced
  successors, stated separately because both limit arguments read them
- `PlusSharingWitnessFamily.hopFree_deviates` — the state-level deviation at every time

## Tags

plus-language · certificate · incompleteness · hop-free · stability-modal
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.ProofSystem

namespace PlusSharingWitnessFamily

variable {p : Atom}

/-! ## The forced successors

Steps 1–3 of the header's argument, stated for an arbitrary family: no hop-freedom hypothesis
appears until the counting step, so these three lemmas are about the whole certificate class.
-/

/--
**Every position has a share-class member branching to `p`.**

The `⟐Xp` conjunct of the target, read through (C5), (C1') and the reflexive `untl` clause.
-/
theorem hopFree_branchesTrue {S : PlusSharingWitnessFamily ([] : PlusContext) (hopDelta p)}
    {t : ℤ} (hc : S.PlusCertifies t) (i : Fin S.lassos.length) (u : ℤ) :
    ∃ j, S.share u i j ∧ PlusFormula.atom p ∈ S.L j (u + 1) := by
  classical
  obtain ⟨-, ⟨hloc, -⟩, hbox, htgt, hstab⟩ := hc
  have hbot : ∀ (i : Fin S.lassos.length) (u : ℤ), PlusFormula.bot ∉ S.L i u :=
    fun i u => (hloc i u).1
  have himp : ∀ (i : Fin S.lassos.length) (u : ℤ) (a b : PlusFormula),
      PlusFormula.imp a b ∈ hopClosure p →
      (PlusFormula.imp a b ∈ S.L i u ↔ (a ∈ S.L i u → b ∈ S.L i u)) :=
    fun i u a b h => (hloc i u).2.1 a b h
  have hbx : ∀ (i : Fin S.lassos.length) (u : ℤ) (χ : PlusFormula),
      PlusFormula.box χ ∈ hopClosure p →
      (PlusFormula.box χ ∈ S.L i u ↔ S.bx χ = true) :=
    fun i u χ h => (hloc i u).2.2.1 χ h
  have huntl : ∀ (i : Fin S.lassos.length) (u : ℤ) (j : Fin S.lassos.length), S.trans u i j →
      ∀ g e : PlusFormula, PlusFormula.untl g e ∈ hopClosure p →
      (PlusFormula.untl g e ∈ S.L i u ↔
        (e ∈ S.L j (u + 1) ∨ (g ∈ S.L j (u + 1) ∧ PlusFormula.untl g e ∈ S.L j (u + 1)))) :=
    fun i u j h => (hloc i u).2.2.2.1 j h
  have hphi : hopTarget p ∉ S.L S.mainIdx t := htgt.2 (hopTarget p) (List.mem_singleton_self _)
  have h1 : PlusFormula.box (someNextTrue p) ∈ S.L S.mainIdx t := by
    by_contra h
    exact hphi ((himp _ _ _ _ (hopTarget_mem_hopClosure p)).mpr (fun h' => absurd h' h))
  have hall1 : ∀ (i : Fin S.lassos.length) (u : ℤ), someNextTrue p ∈ S.L i u :=
    (hbox (someNextTrue p) (boxSomeNextTrue_mem_hopClosure p)).mp
      ((hbx _ _ (someNextTrue p) (boxSomeNextTrue_mem_hopClosure p)).mp h1)
  have hns : PlusFormula.stab (PlusFormula.imp (nextTrue p) PlusFormula.bot) ∉ S.L i u :=
    fun hs => hbot i u ((himp i u _ _ (someNextTrue_mem_hopClosure p)).mp (hall1 i u) hs)
  have hex : ¬ ∀ j, S.share u i j →
      PlusFormula.imp (nextTrue p) PlusFormula.bot ∈ S.L j u :=
    fun hh => hns ((hstab i u _ (stabNotNextTrue_mem_hopClosure p)).mpr hh)
  push Not at hex
  obtain ⟨j, hsh, hj⟩ := hex
  refine ⟨j, hsh, ?_⟩
  have hX : nextTrue p ∈ S.L j u := by
    by_contra h
    exact hj ((himp j u _ _ (notNextTrue_mem_hopClosure p)).mpr (fun h' => absurd h' h))
  rcases (huntl j u j (S.trans_refl' u j) _ _ (nextTrue_mem_hopClosure p)).mp hX with h | ⟨h, -⟩
  · exact h
  · exact absurd h (hbot j (u + 1))

/--
**Every position has a share-class member branching to `¬p`.**

The `⟐X¬p` conjunct, by the same route, with one extra step: the `untl` clause delivers `p → ⊥`,
and (C1')'s `imp` clause together with the `bot` clause turn that into non-membership of `p`.
-/
theorem hopFree_branchesFalse {S : PlusSharingWitnessFamily ([] : PlusContext) (hopDelta p)}
    {t : ℤ} (hc : S.PlusCertifies t) (i : Fin S.lassos.length) (u : ℤ) :
    ∃ j, S.share u i j ∧ PlusFormula.atom p ∉ S.L j (u + 1) := by
  classical
  obtain ⟨-, ⟨hloc, -⟩, hbox, htgt, hstab⟩ := hc
  have hbot : ∀ (i : Fin S.lassos.length) (u : ℤ), PlusFormula.bot ∉ S.L i u :=
    fun i u => (hloc i u).1
  have himp : ∀ (i : Fin S.lassos.length) (u : ℤ) (a b : PlusFormula),
      PlusFormula.imp a b ∈ hopClosure p →
      (PlusFormula.imp a b ∈ S.L i u ↔ (a ∈ S.L i u → b ∈ S.L i u)) :=
    fun i u a b h => (hloc i u).2.1 a b h
  have hbx : ∀ (i : Fin S.lassos.length) (u : ℤ) (χ : PlusFormula),
      PlusFormula.box χ ∈ hopClosure p →
      (PlusFormula.box χ ∈ S.L i u ↔ S.bx χ = true) :=
    fun i u χ h => (hloc i u).2.2.1 χ h
  have huntl : ∀ (i : Fin S.lassos.length) (u : ℤ) (j : Fin S.lassos.length), S.trans u i j →
      ∀ g e : PlusFormula, PlusFormula.untl g e ∈ hopClosure p →
      (PlusFormula.untl g e ∈ S.L i u ↔
        (e ∈ S.L j (u + 1) ∨ (g ∈ S.L j (u + 1) ∧ PlusFormula.untl g e ∈ S.L j (u + 1)))) :=
    fun i u j h => (hloc i u).2.2.2.1 j h
  have hphi : hopTarget p ∉ S.L S.mainIdx t := htgt.2 (hopTarget p) (List.mem_singleton_self _)
  have hrest : PlusFormula.imp (PlusFormula.box (someNextFalse p)) PlusFormula.bot
      ∉ S.L S.mainIdx t :=
    fun h => hphi ((himp _ _ _ _ (hopTarget_mem_hopClosure p)).mpr (fun _ => h))
  have h2 : PlusFormula.box (someNextFalse p) ∈ S.L S.mainIdx t := by
    by_contra h
    exact hrest ((himp _ _ _ _ (impBoxSomeNextFalse_mem_hopClosure p)).mpr
      (fun h' => absurd h' h))
  have hall2 : ∀ (i : Fin S.lassos.length) (u : ℤ), someNextFalse p ∈ S.L i u :=
    (hbox (someNextFalse p) (boxSomeNextFalse_mem_hopClosure p)).mp
      ((hbx _ _ (someNextFalse p) (boxSomeNextFalse_mem_hopClosure p)).mp h2)
  have hns : PlusFormula.stab (PlusFormula.imp (nextFalse p) PlusFormula.bot) ∉ S.L i u :=
    fun hs => hbot i u ((himp i u _ _ (someNextFalse_mem_hopClosure p)).mp (hall2 i u) hs)
  have hex : ¬ ∀ j, S.share u i j →
      PlusFormula.imp (nextFalse p) PlusFormula.bot ∈ S.L j u :=
    fun hh => hns ((hstab i u _ (stabNotNextFalse_mem_hopClosure p)).mpr hh)
  push Not at hex
  obtain ⟨j, hsh, hj⟩ := hex
  refine ⟨j, hsh, ?_⟩
  have hX : nextFalse p ∈ S.L j u := by
    by_contra h
    exact hj ((himp j u _ _ (notNextFalse_mem_hopClosure p)).mpr (fun h' => absurd h' h))
  have hnp : PlusFormula.imp (PlusFormula.atom p) PlusFormula.bot ∈ S.L j (u + 1) := by
    rcases (huntl j u j (S.trans_refl' u j) _ _ (nextFalse_mem_hopClosure p)).mp hX with
      h | ⟨h, -⟩
    · exact h
    · exact absurd h (hbot j (u + 1))
  exact fun hp => hbot j (u + 1)
    ((himp j (u + 1) _ _ (notAtom_mem_hopClosure p)).mp hnp hp)

/--
**At every time the main index's state has a successor state other than its own.**

Step 4: whichever of `p ∈ S.L S.mainIdx (u + 1)` holds, one of the two forced branches contradicts
it, and (C0) is what turns that label disagreement into state distinctness.
-/
theorem hopFree_deviates {S : PlusSharingWitnessFamily ([] : PlusContext) (hopDelta p)}
    {t : ℤ} (hc : S.PlusCertifies t) (u : ℤ) :
    ∃ d, S.share u S.mainIdx d ∧ ¬ S.share (u + 1) S.mainIdx d := by
  classical
  have hat := hc.1
  obtain ⟨jP, hP1, hP2⟩ := hopFree_branchesTrue hc S.mainIdx u
  obtain ⟨jN, hN1, hN2⟩ := hopFree_branchesFalse hc S.mainIdx u
  by_cases hm : PlusFormula.atom p ∈ S.L S.mainIdx (u + 1)
  · exact ⟨jN, hN1, fun hs => hN2 ((hat (u + 1) _ _ hs p).mp hm)⟩
  · exact ⟨jP, hP1, fun hs => hm ((hat (u + 1) _ _ hs p).mpr hP2)⟩

/-! ## The counting step

Hop-freedom enters here and nowhere else.
-/

/--
**No hop-free family certifies `hopTarget p`.**

The hypothesis is spelled exactly as `TransId.lean`'s `hid`, so this theorem and that module's
four collapse theorems quantify over the same class of families. What is bounded is the hop-free
*strategy*; `hopTarget p` is refutable, by `not_plusValidZTime_hopTarget`, just not this way.

The universally-quantified workhorse; `not_exists_hopFree_plusCertifies_hopTarget` below is the
existential form the plan pins, and is a one-line consequence.

Paper: — (a formalization-native limit; the paper states no such result)
-/
theorem not_plusCertifies_hopTarget_of_hopFree
    (S : PlusSharingWitnessFamily ([] : PlusContext) (hopDelta p)) (t : ℤ)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j) :
    ¬ S.PlusCertifies t := by
  intro hc
  classical
  choose d hd1 hd2 using fun u => hopFree_deviates hc u
  -- One deviating state path per time, each tracked by a constant succession index.
  have track : ∀ m : ℤ, ∃ k : Fin S.lassos.length,
      (∀ u, u ≤ m → S.share u S.mainIdx k) ∧ ¬ S.share (m + 1) S.mainIdx k := by
    intro m
    set σ : ℤ → Fin S.lassos.length := fun u => if u ≤ m then S.mainIdx else d m with hσ
    have hσstep : ∀ u : ℤ,
        stepOf S.lassos.length S.repBack S.repMid S.repFwd u (σ u) (σ (u + 1)) := by
      intro u
      by_cases h1 : u + 1 ≤ m
      · have e1 : σ u = S.mainIdx := by simp only [hσ, if_pos (show u ≤ m by omega)]
        have e2 : σ (u + 1) = S.mainIdx := by simp only [hσ, if_pos h1]
        rw [e1, e2]; exact ⟨_, rfl, rfl⟩
      · by_cases h2 : u ≤ m
        · have hum : u = m := by omega
          have e1 : σ u = S.mainIdx := by simp only [hσ, if_pos h2]
          have e2 : σ (u + 1) = d m := by simp only [hσ, if_neg h1]
          rw [e1, e2, hum]
          exact ⟨d m, hd1 m, rfl⟩
        · have e1 : σ u = d m := by simp only [hσ, if_neg h2]
          have e2 : σ (u + 1) = d m := by simp only [hσ, if_neg h1]
          rw [e1, e2]; exact ⟨_, rfl, rfl⟩
    obtain ⟨τ, hτ, hτσ⟩ := S.lift σ hσstep
    have hτstep : ∀ u : ℤ, S.trans u (τ u) (τ (u + 1)) := hτ
    have hτshare : ∀ u : ℤ, S.share u (σ u) (τ u) := hτσ
    have hsucc : ∀ u : ℤ, τ (u + 1) = τ u := fun u => (hid u _ _ (hτstep u)).symm
    -- A constant succession path: `hsucc` shifts by one, and every integer is reachable from
    -- `0` or reaches `0` by finitely many shifts. Stated through a `ℕ`-shift lemma rather than
    -- `Int.induction_on`, so that no goal ever mentions `-↑i - 1`.
    have key : ∀ (n : ℕ) (u : ℤ), τ (u + n) = τ u := by
      intro n
      induction n with
      | zero => intro u; simp
      | succ n ih =>
        intro u
        have e : u + ((n + 1 : ℕ) : ℤ) = (u + (n : ℕ)) + 1 := by omega
        rw [e, hsucc, ih]
    have hconst : ∀ u : ℤ, τ u = τ 0 := by
      intro u
      by_cases hu : (0 : ℤ) ≤ u
      · have e : (0 : ℤ) + ((u.toNat : ℕ) : ℤ) = u := by omega
        have := key u.toNat 0
        rw [e] at this
        exact this
      · have e : u + (((-u).toNat : ℕ) : ℤ) = 0 := by omega
        have := key (-u).toNat u
        rw [e] at this
        exact this.symm
    refine ⟨τ 0, fun u hu => ?_, fun hs => ?_⟩
    · have := hτshare u
      rw [hconst u] at this
      simpa only [hσ, if_pos hu] using this
    · have := hτshare (m + 1)
      rw [hconst (m + 1)] at this
      have e : σ (m + 1) = d m := by simp only [hσ, if_neg (show ¬ m + 1 ≤ m by omega)]
      rw [e] at this
      exact hd2 m (share_trans hs (share_symm this))
  choose k hk1 hk2 using track
  -- The tracking indices are pairwise distinct, so there are more of them than indices.
  have hinj : Function.Injective (fun m : Fin (S.lassos.length + 1) => k ((m : ℕ) : ℤ)) := by
    intro x y hxy
    simp only at hxy
    by_contra hne
    rcases lt_or_gt_of_ne (fun h => hne (Fin.ext h)) with hlt | hlt
    · exact hk2 ((x : ℕ) : ℤ) (by rw [hxy]; exact hk1 _ _ (by omega))
    · exact hk2 ((y : ℕ) : ℤ) (by rw [← hxy]; exact hk1 _ _ (by omega))
  have := Fintype.card_le_of_injective _ hinj
  simp at this

/--
**Hop-free families are incomplete**, existentially.

The pinned statement shape: no family of the class is *both* hop-free and certifying, at any time.
Logically the same content as `not_plusCertifies_hopTarget_of_hopFree`, stated in the form the
plan's Lean Challenge Statement fixes so that the flagship does not drift.

Paper: — (a formalization-native limit; the paper states no such result)
-/
theorem not_exists_hopFree_plusCertifies_hopTarget (p : Atom) :
    ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) (hopDelta p)) (t : ℤ),
        (∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j) ∧ S.PlusCertifies t :=
  fun ⟨S, t, hid, hc⟩ => not_plusCertifies_hopTarget_of_hopFree S t hid hc

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
