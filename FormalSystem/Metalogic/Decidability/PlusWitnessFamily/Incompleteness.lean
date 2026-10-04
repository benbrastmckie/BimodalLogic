/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples
import FormalSystem.PlusLanguage.PlusNonValidities

/-!
# The Two Stability Targets, and Their Genuine ℤ-Time Non-Validity

This module records the two schema instances that drove the substrate redesign, and the fact
that each is a real ℤ-time non-validity. It no longer records **the** obstruction it once
recorded — the `share`-congruence collapse, which the `trans` substrate removed. It is not that
there is no obstruction left to record: there is, at a different target and for a different
reason, and it lives in `Limits/` —
`Limits.NoCertificate.not_exists_plusCertifies_pumpTarget` (no family of the class certifies
`pumpTarget`) and `Limits.HopFree.not_exists_hopFree_plusCertifies_hopTarget` (no hop-free family
certifies `hopTarget`). What follows is about the retired congruences, and is accurate.

## What this module used to say, and why it no longer says it

Until the `trans` substrate landed, (C1') `PlusLocalCoherentShare`'s `snce` clause quantified
its predecessor universally over the `share`-class at the **same** time `t`. Reading the one
clause twice — once at `i` with `k := j`, once at `j` with `k := j` by reflexivity of `share` —
forced any two indices naming one world state at `t` to agree on every `snce` formula of the
closure. Past-tense truth was therefore a function of the world state alone, which is exactly
what `⊡` quantifies over, so no six-condition family could certify any instance of
`(g S e) → ⊡(g S e)`. The `untl` side carried the same defect displaced by one step.

Five declarations recorded that: `snce_share_congr`, `untl_shift_share_congr`,
`not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise` and
`not_plusCertifies_stabUntl`. All five are **retired**, and their retirement is the evidence the
redesign worked rather than an unexplained deletion. The two clauses now quantify over
`trans`, the arrival-pruned succession relation, which is strictly finer than state-identity at
a time: two indices naming one state at `t` need not have a common predecessor, so the doubled
reading that produced the congruence no longer type-checks. `Sharing/Agreement.lean`'s
`snce_pred_congr` and `untl_succ_congr` state exactly how much agreement the clauses still
force **at the unfolding**, and why that residue is semantically forced rather than a relapse.
This module's own "The residual the succession substrate still carries" section states the
**label-level** counterpart — agreement forced by `trans_refl` itself (`untl_trans_congr`,
`snce_trans_congr`) and the reflexivity-free residual that survives without it
(`untl_common_succ_congr`, `snce_common_pred_congr`) — which the Plus side previously recorded
nowhere.

The corresponding rows were removed from `scripts/check-module-invariants.sh`'s C2 baseline and
from `docs/theorem-index.md` in the same edit, so the tree and the baselines never disagreed.

## What survives, and why it is still worth stating

The three target schemas and the two non-validity theorems. `not_plusValidZTime_stabSnce` and
`not_plusValidZTime_stabUntl` were never consequences of the defect — they are facts about
ℤ-time frames — and they are what made the old empty certificate class a *completeness* failure
rather than a vacuity. They now serve the opposite role: they are the targets the certificates
of `PlusWitnessFamily/Examples.lean` must actually refute, and so they are the specification the
redesign is measured against.

## Soundness was never at issue

`plusTruth_iff_mem` and `plusRefutes_of_certifies` are unchanged in statement, across the whole
redesign. A family meeting the six conditions always presented a genuine countermodel; what
failed was completeness of the certificate class on these two targets.

## Main Definitions

- `PlusSharingWitnessFamily.stabSnceTarget` — the schema `(g S e) → ⊡(g S e)`
- `PlusSharingWitnessFamily.notStabSnceTarget` — its negation, for the premise placement
- `PlusSharingWitnessFamily.stabUntlTarget` — the `untl`-side target `Fp → (¬p → ⊡Fp)`

## Main Results

- `PlusSharingWitnessFamily.not_snce_share_congr` — the redesigned (C1') does not entail the
  retired `snce` congruence, refuted by `Examples.lean`'s Family A rather than merely unproved
- `PlusSharingWitnessFamily.not_untl_shift_share_congr` — nor the retired `untl` congruence,
  refuted by Family B
- `PlusSharingWitnessFamily.not_plusValidZTime_stabSnce` — `Pp → ⊡Pp` is a genuine ℤ-time
  non-validity
- `PlusSharingWitnessFamily.not_plusValidZTime_stabUntl` — and so is `Fp → (¬p → ⊡Fp)`
- `PlusSharingWitnessFamily.untl_trans_congr`, `PlusSharingWitnessFamily.snce_trans_congr` —
  the label-level agreement `trans_refl` forces, by itself
- `PlusSharingWitnessFamily.untl_common_succ_congr`,
  `PlusSharingWitnessFamily.snce_common_pred_congr` — the reflexivity-free residual that survives
  if `trans_refl` is ever dropped, and no more
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.ProofSystem
open PlusTruth

namespace PlusSharingWitnessFamily

/-! ## The three targets -/

/-- The schema `(g S e) → ⊡(g S e)`, the `snce`-side target of the redesign. -/
def stabSnceTarget (g e : PlusFormula) : PlusFormula :=
  .imp (PlusFormula.snce g e) (.stab (PlusFormula.snce g e))

/-- `¬((g S e) → ⊡(g S e))`, for the premise placement. -/
def notStabSnceTarget (g e : PlusFormula) : PlusFormula :=
  PlusFormula.imp (stabSnceTarget g e) PlusFormula.bot

/-- The `untl`-side target `Fp → (¬p → ⊡Fp)`. -/
def stabUntlTarget (p : Atom) : PlusFormula :=
  .imp (PlusFormula.untl PlusFormula.top (.atom p))
    (.imp (.imp (.atom p) .bot) (.stab (PlusFormula.untl PlusFormula.top (.atom p))))

/-! ## The retired congruence is refuted, not merely unproved

The check a redesign can otherwise pass by type-checking alone. That the old congruence no longer
*elaborates* is weak evidence: a redesign can reproduce a defect in a differently-spelled clause
and still break the old proof term. What settles it is a family that satisfies the redesigned
(C1') at every position and violates the congruence's conclusion — which is what
`Examples.lean`'s Family A is for.
-/

/--
**The redesigned (C1') does not entail `share`-class agreement on past-tense labels.**

The statement the retired `snce_share_congr` made, refuted. Family A satisfies (C1') everywhere,
yet indices `0` and `1` name one world state at the origin and exactly one of them carries `Pp`
there. Succession into the origin is a singleton at each index, so the doubled clause reading
that produced the old congruence has nothing to read twice.

Paper: — (a formalization-native result; the paper states no such result)
-/
theorem not_snce_share_congr (p : Atom) :
    ¬ ∀ (Γ Del : PlusContext) (S : PlusSharingWitnessFamily Γ Del),
        S.PlusLocalCoherentShare → ∀ (t : ℤ) (i j : Fin S.lassos.length), S.share t i j →
          ∀ g e : PlusFormula, PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) →
            (PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L j t) := by
  intro h
  obtain ⟨hshare, hin, hout⟩ := famA_separates_snce p
  have hcl : PlusFormula.snce PlusFormula.top (.atom p) ∈
      plusClosureOf (([] : PlusContext) ++ [targetA p]) :=
    plusClosureOf_imp_left (plusConclusion_mem_closure (List.mem_singleton_self _))
  exact hout ((h _ _ (famA p) (famA_plusLocalCoherentShare p) 0 _ _ hshare _ _ hcl).mp hin)

/--
**Family A's target is the `snce`-side schema instance**, on the nose.
-/
theorem targetA_eq (p : Atom) : targetA p = stabSnceTarget PlusFormula.top (.atom p) := rfl

/--
**Family B's target is the `untl`-side schema instance**, on the nose.
-/
theorem targetB_eq (p : Atom) : targetB p = stabUntlTarget p := rfl

/--
**The redesigned (C1') does not entail `share`-class agreement on the one-step `untl`
unfolding.**

The statement the retired `untl_shift_share_congr` made, refuted. That congruence read the `untl`
clause at `t - 1`, where `share t i j` *is* `share ((t-1)+1) i j`, and so recovered the `snce`
side's collapse one step displaced — which is why re-timing one clause to match the other was
never a repair. Family B satisfies (C1') everywhere, yet indices `0` and `1` name one world state
at the origin and disagree on the unfolding `p ∨ (⊤ ∧ Fp)` there.

Paper: — (a formalization-native result; the paper states no such result)
-/
theorem not_untl_shift_share_congr (p : Atom) :
    ¬ ∀ (Γ Del : PlusContext) (S : PlusSharingWitnessFamily Γ Del),
        S.PlusLocalCoherentShare → ∀ (t : ℤ) (i j : Fin S.lassos.length), S.share t i j →
          ∀ g e : PlusFormula, PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) →
            ((e ∈ S.L i t ∨ (g ∈ S.L i t ∧ PlusFormula.untl g e ∈ S.L i t)) ↔
              (e ∈ S.L j t ∨ (g ∈ S.L j t ∧ PlusFormula.untl g e ∈ S.L j t))) := by
  intro h
  obtain ⟨hshare, ⟨htop, hF⟩, hpj, hFj⟩ := famB_separates_untl p
  have hcl : PlusFormula.untl PlusFormula.top (.atom p) ∈
      plusClosureOf (([] : PlusContext) ++ [targetB p]) :=
    plusClosureOf_imp_left (plusConclusion_mem_closure (List.mem_singleton_self _))
  rcases (h _ _ (famB p) (famB_plusLocalCoherentShare p) 0 _ _ hshare _ _ hcl).mp
      (Or.inr ⟨htop, hF⟩) with hp | ⟨-, hf⟩
  · exact hpj hp
  · exact hFj hf

/-! ## The residual the succession substrate still carries

`trans_refl` — reflexivity of `trans`, retained on `SharingSkeleton` per the audit this module's
record now serves — forces agreement at the label level, not only at the unfolding level that
`Sharing/Agreement.lean`'s `untl_succ_congr` and `snce_pred_congr` already state. The four
theorems below are that record, in two pairs:

1. `untl_trans_congr` and `snce_trans_congr` are `clause_shape_collapse` read at `R := S.trans t`
   (resp. `S.trans (t - 1)`): one clause instantiated at the successor (or predecessor) itself,
   and once more at the reflexive self-step `trans_refl'` supplies, composed by `Iff.trans` and
   `Iff.symm`. They are forced by `trans_refl` **alone** — drop that field and neither proof term
   elaborates, because the second instantiation has no witness to the diagonal relation it reads.
2. `untl_common_succ_congr` and `snce_common_pred_congr` need no reflexivity at all: two distinct
   indices sharing one common successor (resp. predecessor) agree on the label there, by the same
   two-instantiation-and-compose idiom read at two genuinely different indices instead of at one
   index and its reflexive copy. These are **exactly** what survives if `trans_refl` is ever
   dropped, and no more.

Both pairs are vacuous on every landed producer: `Examples.lean`'s families all supply
`transFullOf` or `transIdOf` as their succession bundle, and both make `trans t` either the
complete relation or the diagonal, so the antecedent collapses the conclusion's two sides onto
the same index before any work is done. Within the class's own frames, both pairs are
**truth-level facts, not spurious constraints** — unlike the retired `share`-congruences this
module used to record, an index at a time names a *history type* here, and two indices related
by `trans` at `t` genuinely do name the same successor history from `t + 1` onward, so agreeing on
its labels is not an over-constraint.

The time-sliced certificate class carries no analogue: `PlusSlicedCertificate` has no `trans`
field by construction, and its `edge` relation is bi-serial without being reflexive, so this
residual is confined to the retained sharing class and is not inherited by the programme's
completeness route.

Both pairs are also strictly weaker than the landed class-level incompleteness theorem
`Limits.NoCertificate.not_exists_plusCertifies_pumpTarget`, which needs no hypothesis on `trans`
at all. They are recorded here, rather than built into a named incompleteness theorem of their
own, so that the relocation of this residual from `share`-classes (the defect this module used to
record) to `trans`-classes is seen as deliberate and bounded, not overlooked.

**Naming, against the name collision.** `Sharing/Agreement.lean`'s `untl_succ_congr` and
`snce_pred_congr` state agreement on the **unfolding** — the disjunction `e ∈ L j (t+1) ∨ (g ∈
L j (t+1) ∧ untl g e ∈ L j (t+1))` — at a **common successor** `j`, for two predecessors sharing
it. The four theorems below state agreement on the **label itself** — `untl g e ∈ L i t ↔ untl g e
∈ L j t` — either at a successor/predecessor pair related by `trans` (`*_trans_congr`, reflexivity-
forced) or at two indices sharing one common successor/predecessor (`*_common_succ_congr` /
`*_common_pred_congr`, reflexivity-free). The two pairs are not restatements of each other: one is
about the unfolding one step away, the other is about the label at the position itself.
-/

/--
**`trans`-related indices agree on every `untl` label — forced by `trans_refl` alone.**

Two instantiations of (C1')'s `untl` conjunct, composed: one at `(i, j)` via the hypothesis
`hij`, one at `(j, j)` via `trans_refl'`, `Iff.trans`-ed together. Drop `trans_refl` and the
second instantiation has no witness — this is exactly the residual retaining `trans_refl` costs.

Paper: — (a formalization-native result; the paper states no such result)
-/
theorem untl_trans_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i j : Fin S.lassos.length} {t : ℤ} (hij : S.trans t i j)
    {g e : PlusFormula} (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.untl g e ∈ S.L i t ↔ PlusFormula.untl g e ∈ S.L j t :=
  ((h i t).2.2.2.1 j hij g e hc).trans ((h j t).2.2.2.1 j (S.trans_refl' t j) g e hc).symm

/--
**`trans`-related indices agree on every `snce` label — forced by `trans_refl` alone.**

The `snce`-side mirror of `untl_trans_congr`: two instantiations of (C1')'s `snce` conjunct, one
at `(k, i)` via `hki`, one at `(k, k)` via `trans_refl'`, composed the same way.

Paper: — (a formalization-native result; the paper states no such result)
-/
theorem snce_trans_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i k : Fin S.lassos.length} {t : ℤ}
    (hki : S.trans (t - 1) k i)
    {g e : PlusFormula} (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L k t :=
  ((h i t).2.2.2.2 k hki g e hc).trans
    ((h k t).2.2.2.2 k (S.trans_refl' (t - 1) k) g e hc).symm

/--
**Two indices sharing one common `untl`-successor agree on the label — reflexivity-free.**

The exact residual that survives if `trans_refl` is ever dropped, and no more: two
instantiations of (C1')'s `untl` conjunct at two genuinely distinct indices `i` and `i'`, both
related to the same `j` by `trans`, composed. No reflexive self-step is used.

Paper: — (a formalization-native result; the paper states no such result)
-/
theorem untl_common_succ_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i i' j : Fin S.lassos.length} {t : ℤ}
    (hij : S.trans t i j) (hi'j : S.trans t i' j)
    {g e : PlusFormula} (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.untl g e ∈ S.L i t ↔ PlusFormula.untl g e ∈ S.L i' t :=
  ((h i t).2.2.2.1 j hij g e hc).trans ((h i' t).2.2.2.1 j hi'j g e hc).symm

/--
**Two indices sharing one common `snce`-predecessor agree on the label — reflexivity-free.**

The `snce`-side mirror of `untl_common_succ_congr`, at a common predecessor `k` rather than a
common successor.

Paper: — (a formalization-native result; the paper states no such result)
-/
theorem snce_common_pred_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i i' k : Fin S.lassos.length} {t : ℤ}
    (hki : S.trans (t - 1) k i) (hki' : S.trans (t - 1) k i')
    {g e : PlusFormula} (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L i' t :=
  ((h i t).2.2.2.2 k hki g e hc).trans ((h i' t).2.2.2.2 k hki' g e hc).symm

/-! ## The schema is a genuine ℤ-time non-validity -/

/--
**`Pp → ⊡Pp` is not ℤ-time valid.**

The `stabSnceTarget` instance at `g := ⊤`, `e := p`, refuted on the permissive ℤ-frame `NF` with
the two histories of `PlusNonValidities.refute_somePast_stab`: one that was at state `0`
throughout, and one that was at state `1` at every negative time. They agree at `0`, so `⊡`
quantifies over both, and only the first has a past `p`.

This is the target the `snce`-side certificate must refute. Before the substrate redesign it
served the opposite purpose: together with the retired `not_plusCertifies_stabSnce` it made the
then-empty certificate class a *completeness* failure rather than a vacuity.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem not_plusValidZTime_stabSnce (p : Atom) :
    ¬ PlusValidZTime (stabSnceTarget PlusFormula.top (PlusFormula.atom p)) := by
  intro h
  have hsat : FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  have hv := h FormalSystem.PlusLanguage.NF hsat natModel (natHist fun _ => 0) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (somePast (PlusFormula.atom p)) := by
    rw [somePast_iff]
    exact ⟨(-1 : ℤ), (by decide : (-1 : ℤ) < 0), (rfl : (0 : ℕ) = 0)⟩
  have hB := hv hA (natHist fun s => if s < 0 then 1 else 0)
    (by change (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
  rw [show PlusFormula.snce PlusFormula.top (PlusFormula.atom p)
      = somePast (PlusFormula.atom p) from rfl, somePast_iff] at hB
  obtain ⟨s, hs, hat⟩ := hB
  rw [atom_iff] at hat
  have hs' : (s : ℤ) < 0 := hs
  have v' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = 0 := hat
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

/--
**`Fp → (¬p → ⊡Fp)` is not ℤ-time valid.**

The `untl`-side twin of `not_plusValidZTime_stabSnce`, on the same permissive ℤ-frame `NF`. The
history that sits at state `1` up to time `0` and at state `0` from time `1` on has a future `p`
and no present `p` at time `0`; the constant-`1` history agrees with it at `0` and has no future
`p` at all. This is the target the `untl`-side certificate must refute; before the substrate
redesign it made the then-empty certificate class a completeness failure on this side too.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem not_plusValidZTime_stabUntl (p : Atom) : ¬ PlusValidZTime (stabUntlTarget p) := by
  intro h
  have hsat : FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  -- One history is at state 1 at times ≤ 0 and at state 0 from time 1 on: `Fp` holds at 0,
  -- and `p` fails at 0.  The constant-1 history agrees with it at 0 and has no future `p`.
  have hv := h FormalSystem.PlusLanguage.NF hsat natModel
    (natHist fun s => if s ≤ 0 then 1 else 0) 0
  have hA : PlusTruthAt natModel (natHist fun s => if s ≤ 0 then 1 else 0) 0
      (someFuture (PlusFormula.atom p)) := by
    rw [someFuture_iff]
    refine ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_⟩
    change (if (1 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 0
    simp
  have hnp : PlusTruthAt natModel (natHist fun s => if s ≤ 0 then 1 else 0) 0
      (PlusFormula.imp (.atom p) .bot) := by
    intro hp
    change (if (0 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 0 at hp
    simp at hp
  have hB := hv hA hnp (natHist fun _ => 1)
    (by change (if (0 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 1; simp)
  rw [show PlusFormula.untl PlusFormula.top (PlusFormula.atom p)
      = someFuture (PlusFormula.atom p) from rfl, someFuture_iff] at hB
  obtain ⟨s, _, hat⟩ := hB
  change (1 : ℕ) = 0 at hat
  exact one_ne_zero hat

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
