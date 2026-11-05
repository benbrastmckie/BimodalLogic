import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

/-!
# The ONE-SIDED count move: the two projections of `⊡ = ▷◁`, measured against the countdown

`⊡φ ↔ ▷◁φ ↔ ◁▷φ` holds on every regular task frame (compiled, choice-free). `▷` fixes the past
and varies the future (`AgreeUpTo`); `◁` fixes the future and varies the past (`AgreeFrom`). This
prototype relaxes the refuted two-sided transport schema `AtomPreservingCountMove` along each of
those two projections and measures which refutation mechanism survives the relaxation.

* `PastAtomPreservingCountMove` — the `▷`-shaped relaxation: the atom row is preserved on the
  half-line `v ≤ z` only, the future is free.
* `FutAtomPreservingCountMove` — the `◁`-shaped relaxation: the atom row is preserved on the
  half-line `z ≤ v` only, the past is free.
* `futAtomPreservingCountMove_of_twoSided`, `pastAtomPreservingCountMove_of_twoSided` — both are
  genuine RELAXATIONS: the two-sided schema implies each, so refuting either is strictly stronger
  than the recorded refutation of the two-sided one.
* `cntAt_eq_of_pend_eq_fwd` — THE LOAD-BEARING NEW FACT. `cntAt_eq_of_pend_eq`'s proof reads its
  hypothesis only at positions AT OR ABOVE the compared one, so the countdown rigidity holds under
  a FORWARD-ONLY pend-profile agreement. The countdown is a forward-determined quantity; nothing
  about the past enters.
* `futAtomPreservingCountMove_refuted` — the `◁`-shaped relaxation is refuted by that sharpening,
  under exactly the hypotheses `atomPreservingCountMove_refuted` carries.

The `▷`-shaped relaxation is NOT refuted here, and is not refutable by this mechanism: freeing the
future frees the pend profile forward, hence frees the countdown. It is refuted elsewhere and
already: the landed splice `exists_spliced_ladderPath_of_pend_past` IS a `▷`-shaped count move (it
holds the object row at every `v ≤ a` by `spliceObj_eq_of_le` while raising the countdown by `l`
inside the region, `spliced_at_region`), and `Probe761S.splice_type_invariance_refuted` says it
does not preserve the realized stab-free type.

NON-VACUITY is inherited, not re-derived: the hypotheses `g`, `hg`, `z`, `c'`, `hadm`, `hne` of
`futAtomPreservingCountMove_refuted` are exactly those of the landed
`atomPreservingCountMove_refuted`, discharged on the two-state object of
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` (one pending state,
one idle, step complete, the pending bit carried as the atom `p`, so `PendFactorsLab` holds by
`pendFactorsLab_of_atom`).

No decidability consequence is claimed, no finite-fibre or finite-width assumption is made, no
recorded Challenge statement is weakened, and nothing here is a library declaration.

## Compile

```
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" lean specs/855_one_sided_open_modal_type_transport_probe/probes/01_one-sided-count-move.lean
```
-/

namespace Probe855

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability.RaySummary

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-! ## The two one-sided relaxations of the refuted schema -/

/-- **The `▷`-shaped relaxation**: past fixed, future free. The atom row is preserved only on the
half-line at or below the compared position. -/
def PastAtomPreservingCountMove (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) : Prop :=
  ∀ (g : ℤ → LadderState Q pend) (z : ℤ) (c' n' : ℕ), IsLadderPath step pend g →
    c' ∈ Adm pend (objAt g z) →
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = c' ∧ nxtAt g' z = n' ∧
      ∀ (v : ℤ), v ≤ z → ∀ p : Atom, lab (objAt g' v) p = lab (objAt g v) p

/-- **The `◁`-shaped relaxation**: future fixed, past free. The atom row is preserved only on the
half-line at or above the compared position. -/
def FutAtomPreservingCountMove (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) : Prop :=
  ∀ (g : ℤ → LadderState Q pend) (z : ℤ) (c' n' : ℕ), IsLadderPath step pend g →
    c' ∈ Adm pend (objAt g z) →
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = c' ∧ nxtAt g' z = n' ∧
      ∀ (v : ℤ), z ≤ v → ∀ p : Atom, lab (objAt g' v) p = lab (objAt g v) p

/-- Both one-sided forms are genuine relaxations: the two-sided schema implies the `◁`-shaped
one. -/
theorem futAtomPreservingCountMove_of_twoSided (lab : Q → Atom → Bool)
    (h : AtomPreservingCountMove step pend lab) :
    FutAtomPreservingCountMove step pend lab := by
  intro g z c' n' hg hadm
  obtain ⟨g', hg', hobj, hc, hn, hlab⟩ := h g z c' n' hg hadm
  exact ⟨g', hg', hobj, hc, hn, fun v _ p => hlab v p⟩

/-- …and the `▷`-shaped one. -/
theorem pastAtomPreservingCountMove_of_twoSided (lab : Q → Atom → Bool)
    (h : AtomPreservingCountMove step pend lab) :
    PastAtomPreservingCountMove step pend lab := by
  intro g z c' n' hg hadm
  obtain ⟨g', hg', hobj, hc, hn, hlab⟩ := h g z c' n' hg hadm
  exact ⟨g', hg', hobj, hc, hn, fun v _ p => hlab v p⟩

/-! ## The countdown rigidity is FORWARD-ONLY -/

/-- **THE COUNTDOWN IS A FUNCTION OF THE FORWARD PEND PROFILE ALONE.** The sharpening of
`cntAt_eq_of_pend_eq` that the one-sided measurement needs: two ladder paths whose objects agree
on the pending bit at every position AT OR ABOVE `u` carry the same countdown at `u`. Nothing
about the past of `u` enters, because `cntAt g u` is the distance from `u` to the last pending
position of `u`'s own region (`cntAt_sub_of_pend`, `not_pend_of_count`) and that is read entirely
forward.

This is `cntAt_eq_of_pend_eq`'s own proof at the hypothesis it actually consumes; the landed
theorem is left exactly as it stands. -/
theorem cntAt_eq_of_pend_eq_fwd (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (u : ℤ)
    (hpend : ∀ v : ℤ, u ≤ v → pend (objAt g v) = pend (objAt g' v)) :
    cntAt g u = cntAt g' u := by
  by_cases hu : pend (objAt g u) = true
  · have hu' : pend (objAt g' u) = true := by rw [← hpend u le_rfl]; exact hu
    by_contra hne
    rcases Nat.lt_or_ge (cntAt g u) (cntAt g' u) with hlt | hge
    · have h1 := not_pend_of_count g hg u hu
      have h2 := (cntAt_sub_of_pend g' hg' u hu' (cntAt g u + 1) (by omega)).1
      rw [show u + ((cntAt g u + 1 : ℕ) : ℤ) = u + (cntAt g u : ℤ) + 1 by push_cast; ring] at h2
      rw [hpend _ (by omega)] at h1
      rw [h1] at h2
      simp at h2
    · have hlt' : cntAt g' u < cntAt g u := by omega
      have h1 := not_pend_of_count g' hg' u hu'
      have h2 := (cntAt_sub_of_pend g hg u hu (cntAt g' u + 1) (by omega)).1
      rw [show u + ((cntAt g' u + 1 : ℕ) : ℤ) = u + (cntAt g' u : ℤ) + 1 by push_cast; ring] at h2
      rw [hpend _ (by omega)] at h2
      rw [h1] at h2
      simp at h2
  · rw [Bool.not_eq_true] at hu
    have hu' : pend (objAt g' u) = false := by rw [← hpend u le_rfl]; exact hu
    rw [cntAt_eq_zero_of_idle g hg u hu, cntAt_eq_zero_of_idle g' hg' u hu']

/-- **The forward atom-row transport is countdown-rigid.** The one-sided reading of
`cntAt_eq_of_lab_eq_of_pendFactorsLab`: agreement of the atom row on the half-line at or above
`u` already forces the countdown at `u`. -/
theorem cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (u : ℤ)
    (hlab : ∀ (v : ℤ), u ≤ v → ∀ p : Atom, lab (objAt g v) p = lab (objAt g' v) p) :
    cntAt g u = cntAt g' u :=
  cntAt_eq_of_pend_eq_fwd g g' hg hg' u (fun v hv => hfac _ _ (fun p => hlab v hv p))

/-! ## The `◁`-shaped relaxation is refuted -/

/-- **THE `◁`-SHAPED ONE-SIDED COUNT MOVE IS REFUTED**, whenever the pending bit factors through
the atom row, at every ladder path and every admissible target countdown differing from the path's
own — under exactly the hypotheses the landed `atomPreservingCountMove_refuted` carries. Freeing
the whole PAST buys nothing: the obstruction is entirely forward, so the mechanism bites the
`◁`-projected form unchanged. -/
theorem futAtomPreservingCountMove_refuted (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (c' : ℕ)
    (hadm : c' ∈ Adm pend (objAt g z)) (hne : cntAt g z ≠ c') :
    ¬ FutAtomPreservingCountMove step pend lab := by
  intro hmove
  obtain ⟨g', hg', _, hc, _, hlab⟩ := hmove g z c' 0 hg hadm
  have h := cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab lab hfac g' g hg' hg z hlab
  exact hne (h.symm.trans hc)

/-- **The two-sided refutation is a corollary of the one-sided one**, which is the precise sense in
which the `◁` projection removes nothing: the recorded `atomPreservingCountMove_refuted` follows
from `futAtomPreservingCountMove_refuted` through the relaxation. -/
theorem atomPreservingCountMove_refuted_via_fwd (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (c' : ℕ)
    (hadm : c' ∈ Adm pend (objAt g z)) (hne : cntAt g z ≠ c') :
    ¬ AtomPreservingCountMove step pend lab :=
  fun h => futAtomPreservingCountMove_refuted lab hfac g hg z c' hadm hne
    (futAtomPreservingCountMove_of_twoSided lab h)

end Probe855

#print axioms Probe855.cntAt_eq_of_pend_eq_fwd
#print axioms Probe855.cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab
#print axioms Probe855.futAtomPreservingCountMove_of_twoSided
#print axioms Probe855.pastAtomPreservingCountMove_of_twoSided
#print axioms Probe855.futAtomPreservingCountMove_refuted
#print axioms Probe855.atomPreservingCountMove_refuted_via_fwd
