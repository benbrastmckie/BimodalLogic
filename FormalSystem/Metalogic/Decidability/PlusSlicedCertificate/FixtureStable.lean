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

* `Fixture.Φ_back_L₀_inter_ne_cert` — the **filtered** backward conjunct fails at the fixture, a `⊇`
  failure that no filter repairs
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

## STANDING RULE: a probe of a `TailStable`-like demand must carry BOTH an `untl` AND a `snce`

Binding on every future fixture in this module and on every evaluation of a `TailStable`-like demand
anywhere in this subtree. `TailStable` has two conjuncts, each with its own obligation direction and
its own liveness filter, and a closure carrying only one of the two eventuality operators exercises
only one conjunct while the `decide` reports on their conjunction. That is not a hypothetical
hazard: two dispatches returned a favourable verdict for the whole demand from two `untl`-only
certificates, and the `snce`-direction obstruction they concealed is the one
`EmbedComplete.lean`'s `snceProbeFamily_not_tailStableBackRaw` eventually found. The two smallest
witnesses of each direction are kept as a permanent regression pair in
`EmbedComplete.lean`'s `BotTargets` namespace (`⊥ U ⊥` and `⊥ S ⊥`).

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
3. Whether `Certifies` should carry `Φ_fwd R₀ = R₀` at all was a **design question**, because a
   checker clause that is unsatisfiable at a frame whose closure carries a tail-dead eventuality
   would make Phase 19's and Phase 20's completeness statements unprovable rather than merely
   relativized. This module escalated that question rather than settling it. **It has since been
   settled, by the user ruling of 2026-09-30, in favour of the liveness-filtered transfer**: the raw
   demand `Φ_fwd R₀ = R₀` is kept under the name `TailStableRaw` and every theorem of this module is
   stated from it, while `TailStable` itself now carries
   `Φ_fwd R₀ ∩ R₀fwd = R₀` — see `PlusSlicedCertificate.TailStable`'s own docstring for the repaired
   definition and for what it still buys. Nothing proved in this module is weakened by that change:
   the raw forward conjunct still fails in every member of the family, and that failure is exactly
   why the filter is there.

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

/-! ### What the liveness filter removes: the witness is forward-dead at the reference time

The three lemmas below are the evidence that the repaired forward conjunct of `TailStable` addresses
this module's refutation rather than merely sidestepping it. The raw conjunct's refuting witness is
`pR`, reachable from `R₀` in one period (`mem_Φ_fwd_R₀_pR`) and live nowhere but at `b - 1`
(`not_live_pR`). What is proved here is the **computed** counterpart of that deadness at the right
reference time: `pR ∉ R₀fwd`. So `mem_Φ_fwd_R₀_pR` no longer contradicts tail-stability's forward
conjunct, and the position the filter removes is exactly the one the refutation produced.

The argument is the module header's, read on the computed side. A forward walk out of the right
reference time stays in the right periodic region (`nextTime_ge_right`); the event atom `ev` is
labelled at the mid time `b` alone and the guard atom `gd` nowhere; and `NM + NF = b + c + 2` is
past the mid time. So the fixpoint's own `untl` clause at `phi` cannot be met: a delivering vertex
would have to carry `ev` at a time past `b`, and a longer walk would need `gd` at its first vertex.
-/

/-- **No position of any slice carries the guard atom.** Every position agrees with the slice
labelling on the state formulas, and the guard is labelled nowhere. -/
theorem not_mem_lab_gd (a b c : ℕ) {t : ℤ} {p : (certRep a b c).Pos}
    (hp : p ∈ (certRep a b c).posAt t) : gd ∉ p.2.1 := fun h =>
  certRep_slab_not_mem_gd a b c t p.1
    (((((certRep a b c).mem_posAt t p).mp hp).2 gd mem_Cl_gd rfl).mp h)

/-- **No position away from the mid time carries the event atom.** -/
theorem not_mem_lab_ev (a b c : ℕ) {t : ℤ} (ht : t ≠ (b : ℤ)) {p : (certRep a b c).Pos}
    (hp : p ∈ (certRep a b c).posAt t) : ev ∉ p.2.1 := fun h =>
  ht ((certRep_slab_mem_ev_iff a b c t p.1).mp
    (((((certRep a b c).mem_posAt t p).mp hp).2 ev mem_Cl_ev rfl).mp h))

/--
**The dead position is not computed-forward-live at the right reference time**, in every member of
the family.

This is what makes the liveness filter the right repair and not a dodge: the witness that refutes
`Φ_fwd R₀ = R₀` is removed by the filter, because it is forward-dead where the filter reads.
-/
theorem not_mem_R₀fwd_pR (a b c : ℕ) : pR a b c ∉ (certRep a b c).R₀fwd := by
  intro hmem
  have hfl : (pR a b c, (certRep a b c).NM + (certRep a b c).NF) ∈ (certRep a b c).fwdLiveT :=
    (((certRep a b c).mem_fwdLiveAt _ _).mp hmem).2
  have hstep : (pR a b c, (certRep a b c).NM + (certRep a b c).NF) ∈
      (certRep a b c).fwdLiveStep (certRep a b c).fwdLiveT := by
    rw [(certRep a b c).fwdLiveT_fixed]
    exact hfl
  have hclause := (((certRep a b c).mem_fwdLiveStep (certRep a b c).fwdLiveT _).mp hstep).2.2
    phi mem_Cl_phi
  simp only [phi, untlLiveAt, decide_eq_true_eq] at hclause
  have hin : PlusFormula.untl gd ev ∈
      (pR a b c, (certRep a b c).NM + (certRep a b c).NF).1.2.1 := by
    rw [pR_snd]
    exact Finset.mem_singleton_self phi
  have hlive := hclause hin
  have hbc : (certRep a b c).NM + (certRep a b c).NF = (b : ℤ) + (c : ℤ) + 2 := by
    rw [certRep_NM, certRep_NF]
    omega
  have key : ∀ v ∈ (certRep a b c).untlLive (certRep a b c).fwdLiveT gd ev,
      ¬ ((certRep a b c).NM + (certRep a b c).NF ≤ v.2) := by
    rw [untlLive]
    refine EUFix.lfp_induction (certRep a b c).fwdLiveT (certRep a b c).succT
      (Fair.inSet (certRep a b c).fwdLiveT ((certRep a b c).atPosT ev))
      ((certRep a b c).atPosT gd) ?_
    intro v hv hex hge
    obtain ⟨w, hw, hcase⟩ := hex
    have hwv : w ∈ (certRep a b c).verts := (certRep a b c).succT_subset v hw
    have hwt : w.2 = (certRep a b c).nextTime v.2 := (certRep a b c).snd_of_mem_succT hw
    have hvw : v.2 ∈ (certRep a b c).winTimes :=
      (certRep a b c).snd_mem_winTimes_of_mem_verts ((certRep a b c).fwdLiveT_subset hv)
    have hwge : (certRep a b c).NM + (certRep a b c).NF ≤ w.2 := by
      rw [hwt]
      exact (certRep a b c).nextTime_ge_right hvw hge
    have hwpos : w.1 ∈ (certRep a b c).posAt w.2 :=
      (certRep a b c).fst_mem_posAt_of_mem_verts hwv
    have hbne : w.2 ≠ (b : ℤ) := by
      have hc : (0 : ℤ) ≤ (c : ℤ) := Int.natCast_nonneg c
      omega
    rcases hcase with he | ⟨hg, -⟩
    · rw [Fair.inSet_iff] at he
      exact not_mem_lab_ev a b c hbne hwpos (((certRep a b c).atPosT_iff ev w).mp he.1)
    · exact not_mem_lab_gd a b c hwpos (((certRep a b c).atPosT_iff gd w).mp hg)
  exact key _ hlive le_rfl

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
**No re-presentation of the fixture satisfies the RAW tail-stability demand.**

This is sub-phase 16.2c's actual result, and it is the negation of what the plan's
`exists_tailStable_repr` asserts at the very certificate the plan named as that lemma's worked
example. Absorbing the pre-period into `mid` and multiplying either period changes nothing: the raw
forward conjunct fails in every member, by `Φ_fwd_R₀_ne`.

**Renamed from `not_tailStable` when the forward conjunct was repaired.** The statement is the one
that is true and provable: it is about `TailStableRaw`, the pre-repair demand, which `Stable.lean`
keeps under that name for exactly this record. It is **not** about the repaired `TailStable`, whose
forward conjunct this family's witness `pR` does not refute — `pR` is reachable but forward-dead, so
the liveness filter removes it, which is the whole point of the repair. No claim is made here either
way about `(certRep a b c).TailStable`; see this module's header.
-/
theorem not_tailStableRaw (a b c : ℕ) : ¬ (certRep a b c).TailStableRaw :=
  fun h => Φ_fwd_R₀_ne a b c ((certRep a b c).tailStableRaw_fwd h)

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

/-- **The raw backward conjunct fails for the fixture as presented.** This is the pre-period showing
through, and it is the half the plan's recipe really does repair. -/
theorem Φ_back_L₀_ne_cert : cert.Φ_back cert.L₀ ≠ cert.L₀ := fun h =>
  not_mem_Φ_back_L₀_p₀ (h ▸ mem_L₀_p₀)

/--
**The FILTERED backward conjunct fails too**, and that is the point: `p₀` is genuinely live at the
reference time, hence in `L₀bwd`, so the backward liveness filter does not remove it. This is a `⊇`
failure — the demanded set is too small, not too large — and **no filter repairs a `⊇` failure**. It
is repaired only by absorbing the pre-period into `mid`. See `Position.lean`'s header for the
`⊆`/`⊇` dichotomy, and sub-phase 20.4's own record of it: the both-filtered demand is a
per-certificate demand and not a theorem, and this declaration is the witness that it is not
vacuous either. -/
theorem Φ_back_L₀_inter_ne_cert : cert.Φ_back cert.L₀ ∩ cert.L₀bwd ≠ cert.L₀ := by
  intro h
  have hp : p₀ ∈ cert.L₀ := mem_L₀_p₀
  rw [← h] at hp
  exact not_mem_Φ_back_L₀_p₀ (Finset.mem_inter.mp hp).1

/--
**The fixture is not tail-stable, and BOTH conjuncts fail.**

The two failures are independent and have different characters, which is the whole point of
recording them separately: `Φ_back_L₀_inter_ne_cert` is repaired by absorbing the pre-period, and
`Φ_fwd_R₀_ne` is not repaired by anything.

**The first component is stated against the FILTERED backward conjunct**, as sub-phase 20.4 requires
once the backward filter lands: the unfiltered inequality would no longer refute `TailStable`. The
raw inequality survives beside it as `Φ_back_L₀_ne_cert`.
-/
theorem not_tailStable_cert :
    ¬ cert.TailStable ∧ cert.Φ_back cert.L₀ ∩ cert.L₀bwd ≠ cert.L₀
      ∧ cert.Φ_fwd cert.R₀ ≠ cert.R₀ := by
  refine ⟨fun h => Φ_back_L₀_inter_ne_cert (cert.tailStable_back h),
    Φ_back_L₀_inter_ne_cert, ?_⟩
  rw [cert_eq_certRep]
  exact Φ_fwd_R₀_ne 0 0 0

/-- **The fixture also fails the raw demand**, and by its forward conjunct as well as its backward
one. Kept separate from `not_tailStable_cert` because the two statements now say different things:
this one is about the pre-repair demand, that one about the repaired `TailStable`, which the fixture
fails only at its backward conjunct. -/
theorem not_tailStableRaw_cert : ¬ cert.TailStableRaw := by
  rw [cert_eq_certRep]
  exact not_tailStableRaw 0 0 0

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
