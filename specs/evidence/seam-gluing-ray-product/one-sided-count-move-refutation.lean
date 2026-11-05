/-
# THE ONE-SIDED COUNT MOVE: NEGATIVE VERDICT

The question this probe answers is whether the ONE-SIDED factorization given by the open modals
`▷`/`◁` cracks the transport condition whose two-sided pointwise form is already refuted.  **It
does not.**  The verdict is negative, and it is a complete outcome rather than a gap: it closes
the last recorded idea for using the open modals on this front.

## The two projections, and what each one fixes

`⊡φ ↔ ▷◁φ ↔ ◁▷φ` holds on every regular task frame (compiled, choice-free; the biconditional is
`PlusLanguage.PlusRayFibre.plusStab_iff_rays`).  Read as quantifiers over a past ray and a future
ray agreeing at the seam state, the two projections are:

* `▷` — FIXES THE PAST, varies the future (`AgreeUpTo`);
* `◁` — FIXES THE FUTURE, varies the past (`AgreeFrom`).

Both quantifiers fix the FULL ladder state at the evaluation point, so neither admits a count
move at all when read literally.  What is measured here is therefore the ATOM-ROW RELAXATION ON A
HALF-LINE of the refuted two-sided schema `AtomPreservingCountMove`: the atom row is required to
agree only on the half-line the projection leaves fixed, and is free on the other.  That is the
strongest form of the condition either projection can honestly be read as giving; a literal
reading would have made the measurement vacuous rather than negative.

* `PastAtomPreservingCountMove` — the `▷`-shaped relaxation: the atom row is preserved on
  `v ≤ z` only, the future is free.
* `FutAtomPreservingCountMove` — the `◁`-shaped relaxation: the atom row is preserved on
  `z ≤ v` only, the past is free.
* `futAtomPreservingCountMove_of_twoSided`, `pastAtomPreservingCountMove_of_twoSided` — both are
  genuine RELAXATIONS, so refuting either is strictly STRONGER than the recorded refutation of
  the two-sided schema.

## What this probe compiles: the `◁` side, with the two-sided fact as its corollary

* `cntAt_eq_of_pend_eq_fwd` — THE LOAD-BEARING FACT.  `cntAt_eq_of_pend_eq`'s own proof reads its
  hypothesis only at positions AT OR ABOVE the compared one, so the countdown rigidity already
  holds under a FORWARD-ONLY pend-profile agreement.  The countdown is a forward-determined
  quantity and nothing about the past enters.  This is a strict sharpening of a landed theorem;
  the landed theorem is left exactly as it stands and nothing is weakened.
* `cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab` — the atom-row reading of it.
* `futAtomPreservingCountMove_refuted` — the `◁`-shaped relaxation is REFUTED, under exactly the
  hypotheses the landed `atomPreservingCountMove_refuted` carries.  Freeing the whole PAST buys
  nothing: the obstruction is entirely forward, so the mechanism bites the `◁`-projected form
  unchanged.
* `atomPreservingCountMove_refuted_via_fwd`, `atomPreservingCountMove_refutedO` — the recorded
  TWO-SIDED refutation recovered as a COROLLARY of the one-sided one.  That composition is the
  precise content of "the `◁` projection removes nothing", and it is why these are stated through
  the relaxation rather than re-derived directly (`Probe761C.atomPreservingCountMove_refutedC`
  already carries the direct form).
* `futAtomPreservingCountMove_refutedO` — THE HEADLINE, at the compiled object, with NO
  hypotheses left standing.

## The `▷` side is ATTRIBUTED, not re-proved

No new witness is derived here, because one exists and a second would add a probe and no
information.  The landed splice `exists_spliced_ladderPath_of_pend_past` IS a `▷`-shaped count
move: `spliceObj_eq_of_le` holds the object row at every `v ≤ a` while `spliced_at_region` moves
the countdown inside the region.  And `Probe761S.splice_type_invariance_refuted`
(`specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`) says that move does
NOT preserve the realized stab-free type: one splice duplicates the pumped block, so a nested
counting formula `F (p ∧ F p)` flips at every position below the splice point, however far.

## The pincer, in one sentence

The ladder's counter and the closure's eventualities are read from the SAME forward half-line, so
freezing the future leaves nothing to transport and freeing it loses the type.

## The half-line test, which is the reusable product

Any future proposal of this shape must answer two questions: which half-line is the COUNTER read
from, and which half-line is the FORMULA read from.  If both answers are "forward", the proposal
is already decided — `cntAt_eq_of_pend_eq_fwd` kills the frozen-future direction and
`Probe761S.splice_type_invariance_refuted` kills the freed-future direction.  Do not restate the
refuted shape in a half-line form and call it new.

## What this probe does NOT settle

**NO decidability consequence is claimed, in either direction.**  No finite-fibre and no
finite-width assumption is made; `not_finite_width_fmp` stands untouched.  No recorded Challenge
statement is weakened anywhere; `CellLEZeroConstOfKappaEq`'s status is unchanged and
`cellLE_zero_const_of_kappa_eq` remains claimed by nothing.  Where a genuine opening remains is
the route `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` already occupies —
the upward cell inclusion `cellAt_subset_of_shift_of_pend_past` and the path-level downward
inclusion `mem_cellAt_of_shift_of_hasForwardSlack_exact` under the forward-slack regime — whose
gap to `CellLEZeroConstOfKappaEq` is the tight (doubling) chain of pins.  That gap is **not** a
one-sidedness gap and is untouched here.  Nothing in this file is a library declaration, and the
owed model-level `tpOf` pumping-lemma record proceeds unchanged: this measurement does not change
the terms under which that lemma can be stated.

## The object

The two-state object (`pendC`, `stepC`, `pC`, `labC`, `wC`, `cC`, `gC`, …) is RE-DERIVED VERBATIM
from `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`, because a
probe is compiled with `lake env lean` outside the Lake module graph and so NO PROBE CAN IMPORT
ANOTHER.  That file is NOT edited and NOT re-signed; the source probe's seriality lemmas and
parameter apparatus are omitted because this file's refutation needs no frame.

NON-VACUITY IS DISCHARGED IN THIS FILE, not inherited.  `exists_one_sided_refuting_instance`
exhibits the hypotheses at the compiled object: the walk `gC 3 5`, comparison position `z = 0`
(where the state is PENDING), and target countdown `3 + 1` against the path's own `3`.  The
target is admissible because `Adm pend q = {c | pend q = false → c = 0}` has a false hypothesis at
a pending state, so EVERY countdown is admissible there (`admZeroC`).  The two headlines
`futAtomPreservingCountMove_refutedO` and `atomPreservingCountMove_refutedO` carry no hypotheses
at all, so the refutation is visibly non-vacuous without reading another file.

## Verification

`#print axioms` on every headline: `no axioms` on the two relaxation lemmas, and a subset of
`[propext, Classical.choice, Quot.sound]` on every other.  No `sorry`, no `sorryAx`, no custom
axiom, no `native_decide`, no placeholder body and no vacuous definition anywhere in this file.
No bound of any kind is asserted; every quantity named is a COUNT.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe855O

/-! ## The two one-sided relaxations of the refuted two-sided schema -/

section Schematic

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

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
one, so refuting the latter is strictly stronger than the recorded refutation. -/
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
theorem is left exactly as it stands and nothing is weakened. -/
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

end Schematic

/-! ## The object, re-derived verbatim from `ladder-cell-agreement-refutation.lean`

Probes are compiled with `lake env lean` outside the Lake module graph, so no probe can import
another; the two-state object is therefore transcribed here under this file's own namespace, and
`ladder-cell-agreement-refutation.lean` is neither edited nor re-signed.  The source probe's
seriality lemmas (`fwdC`, `bwdC`) and its parameter apparatus are omitted: they exist there to
build a model and establish cell membership, and nothing in this file's refutation needs a
frame. -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

def pC : Atom := ⟨"p", none⟩

def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem not_pendC_zero_false : ¬ ((true : Bool) = false) := by simp

/-- Admissibility of EVERY countdown at the pending state: the clause's hypothesis is false
there. -/
theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) not_pendC_zero_false

theorem labC_pC (q : Qc) : labC q pC = pendC q := by
  simp [labC, pendC]

/-- **The pending bit factors through the atom row at this object**, because it IS one of the
atoms of the labelling. -/
theorem pendFactorsLabC : PendFactorsLab pendC labC :=
  pendFactorsLab_of_atom labC pC (fun q => (labC_pC q).symm)

/-! ### The walk, pending at every past position, and its forced countdown -/

def wC (c₀ : ℕ) : ℤ → Qc := fun v => if v ≤ (c₀ : ℤ) then 0 else 1

def cC (c₀ : ℕ) : ℤ → ℕ := fun v => ((c₀ : ℤ) - v).toNat

theorem pendC_wC_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ (c₀ : ℤ)) : pendC (wC c₀ v) = true := by
  simp [wC, pendC, h]

theorem pendC_wC_of_gt (c₀ : ℕ) (v : ℤ) (h : ¬ (v ≤ (c₀ : ℤ))) : pendC (wC c₀ v) = false := by
  simp [wC, pendC, h]

theorem admC (c₀ : ℕ) (v : ℤ) : pendC (wC c₀ v) = false → cC c₀ v = 0 := by
  intro h
  by_cases hv : v ≤ (c₀ : ℤ)
  · exact absurd ((pendC_wC_of_le c₀ v hv).symm.trans h) not_pendC_zero_false
  · simp only [cC]; omega

/-- **The ladder path through `⟨(0, c₀, n₀), _⟩`**: pending at every position at or below `c₀`,
idle after, with the next-deadline register CONSTANT at `n₀`.  The walk has no region start, so
the register is free of every pin and the constant is admissible. -/
def gC (c₀ n₀ : ℕ) : ℤ → LadderState Qc pendC :=
  fun v => ⟨(wC c₀ v, cC c₀ v, n₀), admC c₀ v⟩

theorem gC_objAt (c₀ n₀ : ℕ) (v : ℤ) : objAt (gC c₀ n₀) v = wC c₀ v := rfl

theorem gC_cntAt (c₀ n₀ : ℕ) (v : ℤ) : cntAt (gC c₀ n₀) v = cC c₀ v := rfl

theorem gC_nxtAt (c₀ n₀ : ℕ) (v : ℤ) : nxtAt (gC c₀ n₀) v = n₀ := rfl

theorem gC_isPath (c₀ n₀ : ℕ) : IsLadderPath stepC pendC (gC c₀ n₀) := by
  intro u
  refine ⟨rfl, admC c₀ u, Or.inl rfl, ?_⟩
  by_cases h1 : u + 1 ≤ (c₀ : ℤ)
  · have h0 : u ≤ (c₀ : ℤ) := by omega
    rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl, show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
    simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_le c₀ (u + 1) h1, if_true]
    show cC c₀ (u + 1) + 1 = cC c₀ u
    simp only [cC]; omega
  · by_cases h0 : u ≤ (c₀ : ℤ)
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · show cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro _
        show cC c₀ u = 0
        simp only [cC]; omega
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_gt c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · show cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro h
        exact absurd h (by simp)

theorem gC_zero (c₀ n₀ : ℕ) : (gC c₀ n₀ 0).1 = ((0 : Qc), c₀, n₀) := by
  simp only [gC, wC, cC]
  norm_num

theorem gC_objAt_zero (c₀ n₀ : ℕ) : objAt (gC c₀ n₀) 0 = 0 := by
  have := gC_zero c₀ n₀
  simpa [objAt] using congrArg Prod.fst this

theorem gC_cntAt_zero (c₀ n₀ : ℕ) : cntAt (gC c₀ n₀) 0 = c₀ := by
  simp only [gC_cntAt, cC]
  norm_num

/-! ## Non-vacuity, discharged IN THIS FILE

The prototype inherited the discharge of its hypotheses from another probe, which leaves a reader
arriving at the file alone unable to tell a refutation from a vacuous one.  These five
declarations close that: the hypotheses are exhibited at the compiled object, and the two
headlines below carry NO hypotheses at all. -/

/-- A countdown different from the path's own is admissible at the comparison position, because
the position is PENDING and `Adm pend q = {c | pend q = false → c = 0}` has a false hypothesis
there — so EVERY countdown is admissible at it. -/
theorem admissible_shift_at_zero (c₀ n₀ : ℕ) :
    (c₀ + 1) ∈ Adm pendC (objAt (gC c₀ n₀) 0) := by
  rw [gC_objAt_zero]
  exact admZeroC (c₀ + 1) n₀

/-- …and it differs from the path's own countdown there, which is `c₀`. -/
theorem cntAt_ne_shift_at_zero (c₀ n₀ : ℕ) : cntAt (gC c₀ n₀) 0 ≠ c₀ + 1 := by
  rw [gC_cntAt_zero]
  omega

/-- **THE REFUTATION'S HYPOTHESES ARE INHABITED AT A COMPILED OBJECT**, so the two refutations
below are not vacuous: a ladder path, a position, and an admissible target countdown differing
from the path's own at that position. -/
theorem exists_one_sided_refuting_instance :
    ∃ (g : ℤ → LadderState Qc pendC) (z : ℤ) (c' : ℕ),
      IsLadderPath stepC pendC g ∧ c' ∈ Adm pendC (objAt g z) ∧ cntAt g z ≠ c' :=
  ⟨gC 3 5, 0, 3 + 1, gC_isPath 3 5, admissible_shift_at_zero 3 5, cntAt_ne_shift_at_zero 3 5⟩

/-- **THE HEADLINE: the `◁`-shaped one-sided count move is REFUTED at this object**, with no
hypotheses left standing.  Freeing the entire PAST buys nothing, because the countdown is read
entirely forward (`cntAt_eq_of_pend_eq_fwd`) and the pending bit is readable in the language
(`pendFactorsLabC`). -/
theorem futAtomPreservingCountMove_refutedO :
    ¬ FutAtomPreservingCountMove stepC pendC labC :=
  futAtomPreservingCountMove_refuted labC pendFactorsLabC (gC 3 5) (gC_isPath 3 5) 0 (3 + 1)
    (admissible_shift_at_zero 3 5) (cntAt_ne_shift_at_zero 3 5)

/-- **The recorded two-sided schema is refuted THROUGH the one-sided relaxation** at the same
object.  Stated this way on purpose: the two-sided fact arriving as a COROLLARY of the one-sided
one is the measurement, and a direct re-proof (which `Probe761C.atomPreservingCountMove_refutedC`
already carries) would lose it. -/
theorem atomPreservingCountMove_refutedO :
    ¬ AtomPreservingCountMove stepC pendC labC :=
  fun h => futAtomPreservingCountMove_refutedO (futAtomPreservingCountMove_of_twoSided labC h)

end Probe855O

#print axioms Probe855O.futAtomPreservingCountMove_of_twoSided
#print axioms Probe855O.pastAtomPreservingCountMove_of_twoSided
#print axioms Probe855O.cntAt_eq_of_pend_eq_fwd
#print axioms Probe855O.cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab
#print axioms Probe855O.futAtomPreservingCountMove_refuted
#print axioms Probe855O.atomPreservingCountMove_refuted_via_fwd
#print axioms Probe855O.labC_pC
#print axioms Probe855O.pendFactorsLabC
#print axioms Probe855O.admZeroC
#print axioms Probe855O.gC_isPath
#print axioms Probe855O.gC_objAt_zero
#print axioms Probe855O.gC_cntAt_zero
#print axioms Probe855O.admissible_shift_at_zero
#print axioms Probe855O.cntAt_ne_shift_at_zero
#print axioms Probe855O.exists_one_sided_refuting_instance
#print axioms Probe855O.futAtomPreservingCountMove_refutedO
#print axioms Probe855O.atomPreservingCountMove_refutedO
