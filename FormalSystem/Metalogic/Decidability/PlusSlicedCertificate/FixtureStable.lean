/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable

/-!
# The Fixture Against Tail-Stability: No Re-Presentation Is Tail-Stable

This module lands sub-phase 16.2c's verdict, and the verdict is **not** what the plan asked for.

The plan asked for `exists_tailStable_repr`: for any `G` there is a `G'` with the pre-period
absorbed into `mid` and the period multiplied by the cycle length such that `G'.TailStable`, with
`G'.frame` isomorphic to `G.frame` — hence tail-stability would narrow the *presentations* a checker
accepts and not the *frames* a countermodel may have. `Fixture.cert` refutes it. That lemma is
therefore **not stated here**: it is false, and stating it in any weakened form would misrepresent
what is proved.

## What is proved

* `Fixture.not_tailStable_cert` — the fixture is not tail-stable as presented, and **both**
  conjuncts of `TailStable` fail, for two genuinely different reasons:
  - `Fixture.Φ_back_L₀_ne_cert`: `p₀` is live at `-cert.NB = -1` and has no `succP`-successor at all
    at `cert.winLo = -2`, so it is in `L₀` and not in `Φ_back L₀`. This failure is the pre-period
    showing through, and it is exactly the one the plan's recipe does address —
    `Fixture.not_mem_L₀_pR` records that the witness leaves `L₀` as soon as the pre-period is
    absorbed.
  - `Fixture.Φ_fwd_R₀_ne`: the label `{phi}` sits at the window's right endpoint, is reached from
    `R₀` in one period along the all-empty run, and is occupied by no run there at all. This
    failure is *not* the pre-period showing through.
* `Fixture.not_tailStable` — **no member of the re-presentation family is tail-stable.** For every
  pre-period `b` and every period multipliers `a`, `c`, `(Fixture.certRep a b c).TailStable` fails,
  by its forward conjunct. `Fixture.certRep_slice_shift` (in `Fixture.lean`) proves each member
  presents `cert`'s own slice sequence shifted right by `b`, so the family is exactly the plan's
  recipe applied to the certificate the plan named as its worked example.

## Why the forward failure is structural and not presentational

`Φ_fwd` is a **reachability** transfer: `q ∈ G.Φ_fwd X` asks only for a `predP`-chain of one
combined forward period from a member of `X` up to `q`, with every link in `posAt`. Now read
`Position.lean`'s `StepClause`: `untlClauseAt X Y` constrains `untl g e ∈ X` — the **earlier** label
— in terms of `Y`, and `snceClauseAt X Y` constrains `snce g e ∈ Y` in terms of `X`. So a step
*rightward* out of a live position leaves the arriving label's `untl`-membership completely
unconstrained, and `LabCoherent` does not constrain it either (it is `⊥`-freeness plus the
implication clause, and nothing else).

At this fixture the closure's only eventuality is `phi = untl gd ev`, its event atom `ev` is
labelled at exactly one time, and its guard atom `gd` is labelled nowhere. So `{phi}` is a perfectly
legitimate label at every far-right time (`Fixture.mem_posAt_pR`), is reached from the all-empty
live label in one step (`Fixture.stepClause_empty_phi`), and is occupied by no run there
(`Fixture.not_exists_labRun_pR`). Lengthening the period only lengthens the chain, and the chain is
available at every length; moving the window only moves where the chain is read. Absorbing a
pre-period cannot help either, because the obstruction is at the *right* end and a pre-period is
absorbed at the left.

The general shape of the obstruction, stated without reference to this fixture: `Φ_fwd R₀ = R₀`
demands that **every** position at the window's right endpoint reachable from a live position be
itself live, and reachability there is decided by the one-step clauses, which do not see forward
fulfilment of the arriving label. A presentation cannot change which labels are legitimate at a
slice, because `posAt` is fixed by the slice labelling and the closure, and a re-presentation
changes neither.

## What this costs the design, stated plainly rather than softened

`TailStable` as landed is a demand on the **frame together with its closure**, not on the
presentation: `cert`'s frame has no tail-stable presentation. Three consequences, none of which this
module resolves:

1. The harmlessness paragraph on `PlusSlicedCertificate.TailStable`'s own docstring is wrong. It has
   been corrected there to point here.
2. `exists_tailStable_repr` cannot be stated, so the plan's Phase 16 task bullet asking for it, and
   its Verification line asking that its statement mention no bound, are both moot. The record of
   that is at the plan's Phase 16 heading.
3. Whether `Certifies` should carry `Φ_fwd R₀ = R₀` at all is a **design question**, because a
   checker clause that is unsatisfiable at a frame whose closure carries a tail-dead eventuality
   would make Phase 19's and Phase 20's completeness statements unprovable rather than merely
   relativized. This module escalates that question; it does not settle it, and it does not weaken
   `TailStable` on its own authority.

## Tags

plus-language · certificate · time-sliced · fixture · tail-stability · counterexample
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

namespace Fixture

/-- **`pR` is not a computed live position anywhere but at `b - 1`**, by the bridge's soundness
direction against the previous lemma. -/
theorem not_mem_liveAt_pR (a b c : ℕ) {t : ℤ} (ht : t ≠ (b : ℤ) - 1) :
    pR a b c ∉ (certRep a b c).liveAt t := by
  intro h
  exact not_live_pR a b c ht
    ((certRep a b c).live_of_mem_liveT (certRep_boxLabelFaithful a b c)
      (((certRep a b c).mem_liveAt t _).mp h).2)

/-! ### The forward conjunct fails in every member of the family -/

/-- **The right reference time is past the mid time**, so nothing special happens at it. -/
theorem NM_add_NF_ne (a b c : ℕ) :
    (certRep a b c).NM + (certRep a b c).NF ≠ (b : ℤ) ∧
      (certRep a b c).NM + (certRep a b c).NF ≠ (b : ℤ) - 1 := by
  rw [certRep_NM, certRep_NF]
  have : (0 : ℤ) ≤ (c : ℤ) := Int.natCast_nonneg c
  exact ⟨by omega, by omega⟩

/-- **`eR` is in `R₀`.** -/
theorem mem_R₀_eR (a b c : ℕ) : eR a b c ∈ (certRep a b c).R₀ :=
  (certRep a b c).mem_liveAt_of_live (certRep a b c).NM_add_NF_mem_winTimes
    (live_eR a b c (NM_add_NF_ne a b c).2 (NM_add_NF_ne a b c).1)

/-- **`pR` is not in `R₀`.** -/
theorem not_mem_R₀_pR (a b c : ℕ) : pR a b c ∉ (certRep a b c).R₀ :=
  not_mem_liveAt_pR a b c (NM_add_NF_ne a b c).2

/-- **The all-empty position survives every partial rightward transfer.** The chain the failure
runs along: `eR` is live at the right reference time and steps to itself, period after period. -/
theorem mem_iterFwd_eR (a b c : ℕ) :
    ∀ j : ℕ, eR a b c ∈
      (certRep a b c).iterFwd ((certRep a b c).NM + (certRep a b c).NF)
        (certRep a b c).R₀ j := by
  have hc : (0 : ℤ) ≤ (c : ℤ) := Int.natCast_nonneg c
  intro j
  induction j with
  | zero => exact mem_R₀_eR a b c
  | succ j ih =>
      rw [iterFwd_succ, mem_stepFwd]
      have hne1 : (certRep a b c).NM + (certRep a b c).NF + (j : ℤ) + 1 ≠ (b : ℤ) := by
        rw [certRep_NM, certRep_NF]
        have : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg j
        omega
      have hne2 : (certRep a b c).NM + (certRep a b c).NF + (j : ℤ) ≠ (b : ℤ) := by
        rw [certRep_NM, certRep_NF]
        have : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg j
        omega
      refine ⟨mem_posAt_eR a b c hne1, eR a b c, ?_, ih⟩
      rw [mem_predP]
      refine ⟨?_, ?_, stepClause_empty_empty⟩
      · rw [show (certRep a b c).NM + (certRep a b c).NF + (j : ℤ) + 1 - 1
              = (certRep a b c).NM + (certRep a b c).NF + (j : ℤ) from by omega]
        exact mem_posAt_eR a b c hne2
      · exact certRep_edge_eq_true a b c _ _ _

/--
**The dead position is in `Φ_fwd R₀`.**

One period of rightward reachability out of `R₀` reaches the window's right endpoint carrying the
undischargeable eventuality: the all-empty chain of `mem_iterFwd_eR` for the first `c` steps, then
`stepClause_empty_phi` for the last.
-/
theorem mem_Φ_fwd_R₀_pR (a b c : ℕ) :
    pR a b c ∈ (certRep a b c).Φ_fwd (certRep a b c).R₀ := by
  have hc : (0 : ℤ) ≤ (c : ℤ) := Int.natCast_nonneg c
  rw [Φ_fwd, certRep_NFnat, iterFwd_succ, mem_stepFwd]
  have hne1 : (certRep a b c).NM + (certRep a b c).NF + (c : ℤ) + 1 ≠ (b : ℤ) := by
    rw [certRep_NM, certRep_NF]; omega
  have hne2 : (certRep a b c).NM + (certRep a b c).NF + (c : ℤ) ≠ (b : ℤ) := by
    rw [certRep_NM, certRep_NF]; omega
  refine ⟨mem_posAt_pR a b c hne1, eR a b c, ?_, mem_iterFwd_eR a b c c⟩
  rw [mem_predP]
  refine ⟨?_, ?_, ?_⟩
  · rw [show (certRep a b c).NM + (certRep a b c).NF + (c : ℤ) + 1 - 1
          = (certRep a b c).NM + (certRep a b c).NF + (c : ℤ) from by omega]
    exact mem_posAt_eR a b c hne2
  · exact certRep_edge_eq_true a b c _ _ _
  · exact stepClause_empty_phi

/--
**The forward conjunct of tail-stability fails in every member of the re-presentation family.**

No choice of pre-period `b` or of period multipliers `a`, `c` makes `Φ_fwd R₀ = R₀` hold. The
witness is the same in every member: the label `{phi}` at the window's right endpoint, reachable
from the live all-empty label and occupied by no run there.
-/
theorem Φ_fwd_R₀_ne (a b c : ℕ) :
    (certRep a b c).Φ_fwd (certRep a b c).R₀ ≠ (certRep a b c).R₀ := fun h =>
  not_mem_R₀_pR a b c (h ▸ mem_Φ_fwd_R₀_pR a b c)

/--
**No re-presentation of the fixture is tail-stable.**

This is sub-phase 16.2c's actual result, and it is the negation of what the plan's
`exists_tailStable_repr` asserts at the very certificate the plan named as that lemma's worked
example. Absorbing the pre-period into `mid` and multiplying either period changes nothing: the
forward conjunct fails in every member, by `Φ_fwd_R₀_ne`.
-/
theorem not_tailStable (a b c : ℕ) : ¬ (certRep a b c).TailStable := fun h => Φ_fwd_R₀_ne a b c h.2

/-! ### The fixture itself, and the one half re-presentation does repair -/

@[simp] theorem cert_L₀_eq : cert.L₀ = cert.liveAt (-1) := by rw [L₀, cert_NB]

/-- **`p₀` is in `L₀`.** -/
theorem mem_L₀_p₀ : p₀ ∈ cert.L₀ := by
  rw [cert_L₀_eq, cert.mem_liveAt]
  exact ⟨mem_posAt_p₀ (by omega), mem_liveT_neg_one⟩

/-- **One application of `Φ_back` on the fixture is one `stepBack` at `-1`.** -/
theorem cert_Φ_back_eq (X : Finset cert.Pos) : cert.Φ_back X = cert.stepBack (-1) X := by
  rw [Φ_back, cert_NBnat, cert_NB]
  change cert.stepBack (-1 - ((0 : ℕ) : ℤ)) X = cert.stepBack (-1) X
  norm_num

/-- **`p₀` is not in `Φ_back L₀`**: it has no successor at all at `-2`. -/
theorem not_mem_Φ_back_L₀_p₀ : p₀ ∉ cert.Φ_back cert.L₀ := by
  rw [cert_Φ_back_eq, mem_stepBack]
  rintro ⟨-, q, hq, -⟩
  rw [show (-1 : ℤ) - 1 = -2 from by norm_num, succP_eq_empty_of_le_neg_two le_rfl] at hq
  exact absurd hq (Finset.notMem_empty _)

/-- **The backward conjunct fails for the fixture as presented.** This is the pre-period showing
through, and it is the half the plan's recipe really does repair. -/
theorem Φ_back_L₀_ne_cert : cert.Φ_back cert.L₀ ≠ cert.L₀ := fun h =>
  not_mem_Φ_back_L₀_p₀ (h ▸ mem_L₀_p₀)

/--
**The fixture is not tail-stable, and BOTH conjuncts fail.**

The two failures are independent and have different characters, which is the whole point of
recording them separately: `Φ_back_L₀_ne_cert` is repaired by absorbing the pre-period, and
`Φ_fwd_R₀_ne` is not repaired by anything.
-/
theorem not_tailStable_cert :
    ¬ cert.TailStable ∧ cert.Φ_back cert.L₀ ≠ cert.L₀ ∧ cert.Φ_fwd cert.R₀ ≠ cert.R₀ := by
  refine ⟨?_, Φ_back_L₀_ne_cert, ?_⟩
  · rw [cert_eq_certRep]; exact not_tailStable 0 0 0
  · rw [cert_eq_certRep]; exact Φ_fwd_R₀_ne 0 0 0

/--
**What absorbing the pre-period does achieve**: the witness of the backward failure leaves `L₀`.

Once `1 ≤ b` the reference time `-(certRep a b c).NB` is strictly negative while the run's
eventuality sits at `b - 1 ≥ 0`, so `pR` is not live at the reference time and cannot witness a
backward failure there. Stated exactly that far and no further: this is **not** a proof that
`Φ_back L₀ = L₀` holds of `certRep a b c`, which is a separate claim this sub-phase does not make.
-/
theorem not_mem_L₀_pR (a b c : ℕ) (hb : 1 ≤ b) : pR a b c ∉ (certRep a b c).L₀ := by
  refine not_mem_liveAt_pR a b c ?_
  have h1 : (certRep a b c).NB = (a : ℤ) + 1 := certRep_NB a b c
  have h2 : (1 : ℤ) ≤ (b : ℤ) := by exact_mod_cast hb
  have h3 : (0 : ℤ) ≤ (a : ℤ) := Int.natCast_nonneg a
  rw [h1]
  omega

end Fixture

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
