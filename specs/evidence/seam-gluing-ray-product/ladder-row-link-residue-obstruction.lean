/-
# THE ROW LINK READS A RESIDUE OF THE COUNTDOWN: NO `Zrel`-SHAPED PATH FORTH

The library module `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` carries a
row link `LnkRow a b g g' t t'` (the relation the `untl`/`snce` clauses of `PlusTruthAt` read), a
truth lemma over it at the `⊡`-free level (`truth_iff_of_lnkRow`), and leaves OWED the path forth
with a whole-row correspondence:

```
exists_rowLinked_path :
  IsLadderPath step pend h → S a b (h t) y →
    ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a b h h' t t
```

for a state relation `S a b` it does not fix.  This probe settles one question about `S`: can it
be the step system's relation `Zrel` at SOME pair of budgets?  It cannot.

## What this probe compiles

* `C3`, `stepC`, `pendC` — a three-state object: a pending `2`-cycle `p0 ⇄ p1`, either of which
  may exit to an idle sink.  `fwdC`, `bwdC` — the ladder over it is serial in both directions.
* `objAt_flip` — inside a pending region of a ladder path over this object the object walk is
  forced: it alternates.
* `Zrel_xC_yC` — the states `(p0, 2 m, 2 m)` and `(p0, 2 m + 1, 2 m + 1)` are `Zrel A B`-related
  whenever `A + B ≤ m`: one object state, both countdowns and both registers above the
  thresholds, equal gaps.
* `not_lnkRow_xC_yC` — no ladder path through the first is row-linked to a ladder path through
  the second at a budget `(a, b + 1)` with `1 ≤ a + b`: by the library's
  `LnkRow.region_end_obj` the two current regions would end at one object state, and they end at
  `p0` and `p1`.
* `no_rowLinked_path_of_Zrel` — THE HEADLINE: for every `(A, B)` and every row budget
  `(a, b + 1)` with `1 ≤ a + b` there are `Zrel A B`-related states, a ladder path through the
  first, and no row-linked ladder path through the second.

## What it holds in place

The state relation of the path forth must carry a condition that depends on the object — here
the parity of the countdown, in general a residue modulo a quantity the object determines.  A
relation of `Zrel`'s shape (countdowns equal or both above a threshold), at any thresholds, must
not be proposed as the hypothesis of a path forth that delivers `LnkRow`.

## What this probe does NOT settle

It does not say WHICH relation works: that a residue conjunct added to `Zrel` suffices is not
proved here or anywhere.  It does not address the row budgets `(a, 1)` with `a = 0`, where
`LnkRow.region_end_obj` does not apply.  It refutes a hypothesis shape of an OWED lemma; it does
not refute the row link, the truth lemma over it, or any agreement of cells, and it bears on
neither `cellAt_const_of_kappa_eq_schema_refuted` nor `no_fibre_equation_over_kappa`.  The object
is one fixture; nothing is claimed about objects whose pending part is aperiodic.  Every quantity
named is a COUNT; no complexity bound is claimed.

## Verification

`#print axioms` on the headline.  No `sorry`, no axiom, no `native_decide`, no placeholder body
and no vacuous definition.  No finite-width or finite-fibre assumption, no trace-level
hypothesis, no parameter condition.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace ProbeRowResidue

/-- A three-state object: a pending `2`-cycle `p0 ⇄ p1`, either of which may exit to the idle
sink. -/
inductive C3 : Type
  | p0 | p1 | idle
  deriving DecidableEq

instance : Fintype C3 := ⟨{C3.p0, C3.p1, C3.idle}, fun x => by cases x <;> simp⟩

def stepC : C3 → C3 → Bool
  | .p0, .p1 => true
  | .p1, .p0 => true
  | .p0, .idle => true
  | .p1, .idle => true
  | .idle, .idle => true
  | _, _ => false

def pendC : C3 → Bool
  | .idle => false
  | _ => true

/-- The other pending state. -/
def flipC : C3 → C3
  | .p0 => .p1
  | .p1 => .p0
  | .idle => .idle

theorem stepC_pend {q q' : C3} (hq : pendC q = true) (hq' : pendC q' = true)
    (hs : stepC q q' = true) : q' = flipC q := by
  cases q <;> cases q' <;> simp_all [stepC, pendC, flipC]

/-- Forward seriality of the ladder over the object. -/
theorem fwdC : ∀ (t : ℤ) (x : LadderState C3 pendC), ∃ y, RladAdm stepC pendC t x y := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  have hx' : pendC q = false → c = 0 := hx
  cases q with
  | idle =>
    have hc : c = 0 := hx' rfl
    subst hc
    exact ⟨⟨(C3.idle, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendC]⟩
  | p0 =>
    cases c with
    | zero =>
      exact ⟨⟨(C3.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendC] at h, Or.inl rfl,
        by simp [Count, pendC]⟩
    | succ c =>
      exact ⟨⟨(C3.p1, c, n), fun h => by simp [pendC] at h⟩, rfl, fun h => by simp [pendC] at h,
        Or.inl rfl, by simp [Count, pendC]⟩
  | p1 =>
    cases c with
    | zero =>
      exact ⟨⟨(C3.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendC] at h, Or.inl rfl,
        by simp [Count, pendC]⟩
    | succ c =>
      exact ⟨⟨(C3.p0, c, n), fun h => by simp [pendC] at h⟩, rfl, fun h => by simp [pendC] at h,
        Or.inl rfl, by simp [Count, pendC]⟩

/-- Backward seriality of the ladder over the object. -/
theorem bwdC : ∀ (t : ℤ) (x : LadderState C3 pendC), ∃ y, RladAdm stepC pendC (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  have hx' : pendC q = false → c = 0 := hx
  cases q with
  | idle =>
    have hc : c = 0 := hx' rfl
    subst hc
    exact ⟨⟨(C3.idle, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendC]⟩
  | p0 =>
    exact ⟨⟨(C3.p1, c + 1, n), fun h => by simp [pendC] at h⟩, rfl, fun h => by simp [pendC] at h,
      Or.inl rfl, by simp [Count, pendC]⟩
  | p1 =>
    exact ⟨⟨(C3.p0, c + 1, n), fun h => by simp [pendC] at h⟩, rfl, fun h => by simp [pendC] at h,
      Or.inl rfl, by simp [Count, pendC]⟩

/-- **THE OBJECT WALK INSIDE A PENDING REGION IS FORCED**: it alternates. -/
theorem objAt_flip (g : ℤ → LadderState C3 pendC) (hg : IsLadderPath stepC pendC g) (u : ℤ)
    (hu : pendC (objAt g u) = true) :
    ∀ j : ℕ, j ≤ cntAt g u → objAt g (u + (j : ℤ)) = flipC^[j] (objAt g u) := by
  intro j
  induction j with
  | zero => intro _; simp
  | succ j ih =>
    intro hj
    have h1 := (cntAt_sub_of_pend g hg u hu j (by omega)).1
    have h2 := (cntAt_sub_of_pend g hg u hu (j + 1) hj).1
    have hcast : u + ((j + 1 : ℕ) : ℤ) = u + (j : ℤ) + 1 := by push_cast; ring
    rw [hcast] at h2 ⊢
    rw [stepC_pend h1 h2 (objAt_step g hg _), ih (by omega), Function.iterate_succ_apply']

theorem flipC_iterate_even (m : ℕ) : flipC^[2 * m] C3.p0 = C3.p0 := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rw [show 2 * (m + 1) = 2 * m + 1 + 1 by ring, Function.iterate_succ_apply',
      Function.iterate_succ_apply', ih]
    rfl

theorem flipC_iterate_odd (m : ℕ) : flipC^[2 * m + 1] C3.p0 = C3.p1 := by
  rw [Function.iterate_succ_apply', flipC_iterate_even]
  rfl

/-- The two states: one object state, countdowns and registers `2 m` and `2 m + 1`, equal gaps. -/
def xC (m : ℕ) : LadderState C3 pendC := ⟨(C3.p0, 2 * m, 2 * m), fun h => by simp [pendC] at h⟩

def yC (m : ℕ) : LadderState C3 pendC :=
  ⟨(C3.p0, 2 * m + 1, 2 * m + 1), fun h => by simp [pendC] at h⟩

/-- The two states are related by `Zrel` at EVERY pair of budgets below `m`. -/
theorem Zrel_xC_yC (A B m : ℕ) (hm : A + B ≤ m) : Zrel A B (xC m) (yC m) := by
  refine ⟨rfl, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩
  · change 2 * (A + B) ≤ 2 * m; omega
  · change 2 * (A + B) ≤ 2 * m + 1; omega
  · change 2 * (A + B) ≤ 2 * m; omega
  · change 2 * (A + B) ≤ 2 * m + 1; omega
  · change ((2 * m : ℕ) : ℤ) - ((2 * m : ℕ) : ℤ) = ((2 * m + 1 : ℕ) : ℤ) - ((2 * m + 1 : ℕ) : ℤ)
    omega

/-- **NO TWO LADDER PATHS THROUGH THE TWO STATES ARE ROW-LINKED** once the budget allows one
forward jump and one further unit: the current regions end at different object states. -/
theorem not_lnkRow_xC_yC (m : ℕ) (hm : 1 ≤ m) (a b : ℕ) (hab : 1 ≤ a + b)
    (h h' : ℤ → LadderState C3 pendC) (hh : IsLadderPath stepC pendC h)
    (hh' : IsLadderPath stepC pendC h') (t : ℤ) (ht : h t = xC m) (ht' : h' t = yC m) :
    ¬ LnkRow a (b + 1) h h' t t := by
  intro hl
  have hc : cntAt h t = 2 * m := by unfold cntAt; rw [ht]; rfl
  have hc' : cntAt h' t = 2 * m + 1 := by unfold cntAt; rw [ht']; rfl
  have ho : objAt h t = C3.p0 := by unfold objAt; rw [ht]; rfl
  have ho' : objAt h' t = C3.p0 := by unfold objAt; rw [ht']; rfl
  have key := LnkRow.region_end_obj hh hh' hab hl (by omega)
  rw [hc, hc'] at key
  have e1 := objAt_flip h hh t (by rw [ho]; rfl) (2 * m) (by omega)
  have e2 := objAt_flip h' hh' t (by rw [ho']; rfl) (2 * m + 1) (by omega)
  rw [e1, e2, ho, ho', flipC_iterate_even, flipC_iterate_odd] at key
  cases key

/-- **THE PATH FORTH WITH A WHOLE-ROW CORRESPONDENCE FAILS FROM EVERY `Zrel`-SHAPED HYPOTHESIS.**
For every pair of budgets `(A, B)` of the state relation there are two `Zrel A B`-related states
of this object, a ladder path through the first, and NO ladder path through the second that is
row-linked to it — at every budget `(a, b + 1)` of the row link with `1 ≤ a + b`.  The countdown
thresholds of `Zrel` do not see the residue of the countdown modulo the object's cycle length,
which the row link reads at the end of the current region. -/
theorem no_rowLinked_path_of_Zrel (A B a b : ℕ) (hab : 1 ≤ a + b) :
    ∃ x y : LadderState C3 pendC, Zrel A B x y ∧
      ∃ h : ℤ → LadderState C3 pendC, IsLadderPath stepC pendC h ∧ h 0 = x ∧
        ¬ ∃ h' : ℤ → LadderState C3 pendC, IsLadderPath stepC pendC h' ∧ h' 0 = y ∧
          LnkRow a (b + 1) h h' 0 0 := by
  obtain ⟨h, hh, h0⟩ := exists_path_through fwdC bwdC (xC (A + B + 1)) 0
  refine ⟨xC (A + B + 1), yC (A + B + 1), Zrel_xC_yC A B _ (by omega), h, hh, h0, ?_⟩
  rintro ⟨h', hh', h0', hl⟩
  exact not_lnkRow_xC_yC (A + B + 1) (by omega) a b hab h h' hh hh' 0 h0 h0' hl

end ProbeRowResidue

/-- info: 'ProbeRowResidue.no_rowLinked_path_of_Zrel' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.no_rowLinked_path_of_Zrel

/-!
# THE RESIDUE CONJUNCT ON THE STATES IS NOT THE MISSING COORDINATE EITHER

The library's `Srel P a b` is `Zrel a b` with the two countdowns congruent modulo `P + 1`, the
modulus `paramsOkK1` constrains.  This part attacks the path forth from `Srel` before any attempt
to prove it, on two objects.

## The first object, `C3` (a pending `2`-cycle): the attack does not break it

* `two_mem_objCycleLens_C3` — `2` is a pending cycle length of `C3`, so `(K1)` gives `2 ∣ P + 1`.
* `not_Srel_xC_yC` — the pair that defeats `Zrel` is NOT `Srel`-related once `2 ∣ P + 1`: its
  countdowns differ in parity.  The residue conjunct excludes exactly that pair.
* `Srel_xT_yT` — the TIGHT pair `(p0, 2 (a + b) + 2, ·)`, `(p0, 2 (a + b) + 2 + (P + 1), ·)` is
  `Srel P a (b + 1)`-related at every `P`.
* `Zrel_tight_answer_C3` — the challenge that breaks the second object is ANSWERED here at the
  level of states: two steps into both regions the object state is `p0` again and the shorter
  region's countdown `2 (a + b)` still meets the threshold left after one jump.  A `2`-cycle has
  two residues and the shorter region has two positions above the threshold.  This is a statement
  about two states; no row-linked pair of paths is constructed on `C3`, and none is refuted.

## The second object, `R4` (a pending `3`-cycle): REFUTED

* `R4`, `stepR`, `pendR`, `fwdR`, `bwdR`, `objAt_rot` — a pending `3`-cycle `r0 → r1 → r2 → r0`,
  each state of which may exit to an idle sink; the ladder over it is serial both ways and the
  object walk inside a pending region is forced.  `three_mem_objCycleLens_R4`.
* `Srel_xR_yR` — the tight pair `xR a b = (r0, 2 (a + b) + 2, ·)`,
  `yR P a b = (r0, 2 (a + b) + 2 + (P + 1), ·)` is `Srel P a (b + 1)`-related, at EVERY `P`.
* `not_lnkRow_xR_yR` — no ladder path through the first is row-linked at `(a, b + 1)`,
  `1 ≤ a + b`, to a ladder path through the second.  Position `t + 3` of the second path carries
  `r0` with a countdown above every threshold; an answer inside the first path's current region
  must sit at `t + 1` or `t + 2` (the only positions whose countdown is still `≥ 2 (a + b)`, or
  equal to the challenger's), which carry `r1` and `r2`; an answer beyond the region passes the
  region's last position, whose countdown `0` nothing in `(t, t + 3)` on the second path matches.
* `no_rowLinked_path_of_Srel` — THE HEADLINE of this part.

## The failing coordinate

Of the three coordinates a failure could sit on — the residue, the register offset after the
lengthened region, the past row — it is THE RESIDUE, and neither of the other two: the registers
and gaps of the refuting pair are matched and never read, and no backward jump is used.  More
exactly it is the residue of the INTERMEDIATE positions: the conjunct fixes the residue of the two
countdowns at the linked pair, while the row link asks every position of the longer region to be
answered at its own residue by a position of the shorter region whose countdown is above `Zrel`'s
threshold, and that threshold's margin (`2` per forward unit of budget) does not depend on the
object's cycle length.

## What this part does NOT settle

It does not say which relation works.  That a countdown threshold raised by a margin the object
determines would survive is NOT proved here or anywhere; the refuting pair sits exactly at the
threshold, and nothing is claimed about pairs above it.  It does not refute the row link, the
truth lemma over it, or any agreement of cells, and it bears on neither
`cellAt_const_of_kappa_eq_schema_refuted` nor `no_fibre_equation_over_kappa`, nor on any gap clip.
Every quantity named is a COUNT; no complexity bound is claimed.
-/

namespace ProbeRowResidue

/-! ### The first object: the residue excludes the old pair, and the tight attack is answered -/

/-- `2` is a pending cycle length of `C3`. -/
theorem two_mem_objCycleLens_C3 : (2 : ℕ) ∈ objCycleLens stepC pendC := by
  refine ⟨by omega, by decide, fun i => if i % 2 = 0 then C3.p0 else C3.p1, ?_, ?_, ?_⟩
  · intro i
    rcases Nat.mod_two_eq_zero_or_one i with h0 | h1
    · have h : (i + 1) % 2 = 1 := by omega
      simp [h0, h, stepC]
    · have h : (i + 1) % 2 = 0 := by omega
      simp [h1, h, stepC]
  · intro i
    rcases Nat.mod_two_eq_zero_or_one i with h0 | h1 <;> simp [*, pendC]
  · simp

/-- **THE RESIDUE CONJUNCT EXCLUDES THE PAIR THAT DEFEATS `Zrel`.** -/
theorem not_Srel_xC_yC (P A B m : ℕ) (h2 : 2 ∣ P + 1) : ¬ Srel P A B (xC m) (yC m) := by
  intro h
  have h1 : ((2 * m : ℕ) : ℤ) ≡ ((2 * m + 1 : ℕ) : ℤ) [ZMOD ((P : ℤ) + 1)] := h.2
  have h3 := h1.dvd
  obtain ⟨k, hk⟩ := h2
  have h4 : (2 : ℤ) ∣ (P : ℤ) + 1 := ⟨k, by exact_mod_cast hk⟩
  have h5 := dvd_trans h4 h3
  push_cast at h5
  omega

/-- The tight pair on `C3`. -/
def xT (a b : ℕ) : LadderState C3 pendC :=
  ⟨(C3.p0, 2 * (a + b) + 2, 2 * (a + b) + 2), fun h => by simp [pendC] at h⟩

def yT (P a b : ℕ) : LadderState C3 pendC :=
  ⟨(C3.p0, 2 * (a + b) + 2 + (P + 1), 2 * (a + b) + 2 + (P + 1)), fun h => by simp [pendC] at h⟩

theorem Srel_xT_yT (P a b : ℕ) : Srel P a (b + 1) (xT a b) (yT P a b) := by
  refine ⟨⟨rfl, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩, ?_⟩
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2; omega
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2 + (P + 1); omega
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2; omega
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2 + (P + 1); omega
  · change ((2 * (a + b) + 2 : ℕ) : ℤ) - ((2 * (a + b) + 2 : ℕ) : ℤ) =
      ((2 * (a + b) + 2 + (P + 1) : ℕ) : ℤ) - ((2 * (a + b) + 2 + (P + 1) : ℕ) : ℤ)
    omega
  · change ((2 * (a + b) + 2 : ℕ) : ℤ) ≡ ((2 * (a + b) + 2 + (P + 1) : ℕ) : ℤ) [ZMOD ((P : ℤ) + 1)]
    exact Int.modEq_iff_dvd.mpr ⟨1, by push_cast; ring⟩

/-- **THE TIGHT ATTACK IS ANSWERED ON THE `2`-CYCLE, AT THE LEVEL OF STATES.** Two steps into the
two regions of the tight pair the object state is `p0` again, and the two states — countdowns
`2 (a + b)` and `2 (a + b) + (P + 1)` — are related at the budget `(a, b)` left after one forward
jump, whatever registers they carry above the threshold with equal gaps. -/
theorem Zrel_tight_answer_C3 (P a b : ℕ) :
    Zrel a b
      (⟨(C3.p0, 2 * (a + b), 2 * (a + b)), fun h => by simp [pendC] at h⟩ : LadderState C3 pendC)
      (⟨(C3.p0, 2 * (a + b) + (P + 1), 2 * (a + b) + (P + 1)), fun h => by simp [pendC] at h⟩ :
        LadderState C3 pendC) := by
  refine ⟨rfl, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩
  · change 2 * (a + b) ≤ 2 * (a + b); omega
  · change 2 * (a + b) ≤ 2 * (a + b) + (P + 1); omega
  · change 2 * (a + b) ≤ 2 * (a + b); omega
  · change 2 * (a + b) ≤ 2 * (a + b) + (P + 1); omega
  · change ((2 * (a + b) : ℕ) : ℤ) - ((2 * (a + b) : ℕ) : ℤ) =
      ((2 * (a + b) + (P + 1) : ℕ) : ℤ) - ((2 * (a + b) + (P + 1) : ℕ) : ℤ)
    omega

/-! ### The second object: a pending `3`-cycle -/

/-- A four-state object: a pending `3`-cycle `r0 → r1 → r2 → r0`, each state of which may exit to
the idle sink. -/
inductive R4 : Type
  | r0 | r1 | r2 | idle
  deriving DecidableEq

instance : Fintype R4 := ⟨{R4.r0, R4.r1, R4.r2, R4.idle}, fun x => by cases x <;> simp⟩

def stepR : R4 → R4 → Bool
  | .r0, .r1 => true
  | .r1, .r2 => true
  | .r2, .r0 => true
  | .r0, .idle => true
  | .r1, .idle => true
  | .r2, .idle => true
  | .idle, .idle => true
  | _, _ => false

def pendR : R4 → Bool
  | .idle => false
  | _ => true

/-- The next pending state. -/
def rotR : R4 → R4
  | .r0 => .r1
  | .r1 => .r2
  | .r2 => .r0
  | .idle => .idle

theorem stepR_pend {q q' : R4} (hq : pendR q = true) (hq' : pendR q' = true)
    (hs : stepR q q' = true) : q' = rotR q := by
  cases q <;> cases q' <;> simp_all [stepR, pendR, rotR]

/-- `3` is a pending cycle length of `R4`. -/
theorem three_mem_objCycleLens_R4 : (3 : ℕ) ∈ objCycleLens stepR pendR := by
  refine ⟨by omega, by decide, fun i => rotR^[i] R4.r0, ?_, ?_, ?_⟩
  · intro i
    show stepR (rotR^[i] R4.r0) (rotR^[i + 1] R4.r0) = true
    rw [Function.iterate_succ_apply']
    generalize rotR^[i] R4.r0 = q
    cases q <;> simp [stepR, rotR]
  · intro i
    induction i with
    | zero => rfl
    | succ i ih =>
      have ih' : pendR (rotR^[i] R4.r0) = true := ih
      show pendR (rotR^[i + 1] R4.r0) = true
      rw [Function.iterate_succ_apply']
      revert ih'
      generalize rotR^[i] R4.r0 = q
      cases q <;> simp [pendR, rotR]
  · rfl

/-- Forward seriality of the ladder over the object. -/
theorem fwdR : ∀ (t : ℤ) (x : LadderState R4 pendR), ∃ y, RladAdm stepR pendR t x y := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  have hx' : pendR q = false → c = 0 := hx
  cases q with
  | idle =>
    have hc : c = 0 := hx' rfl
    subst hc
    exact ⟨⟨(R4.idle, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendR]⟩
  | r0 =>
    cases c with
    | zero =>
      exact ⟨⟨(R4.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendR] at h, Or.inl rfl,
        by simp [Count, pendR]⟩
    | succ c =>
      exact ⟨⟨(R4.r1, c, n), fun h => by simp [pendR] at h⟩, rfl, fun h => by simp [pendR] at h,
        Or.inl rfl, by simp [Count, pendR]⟩
  | r1 =>
    cases c with
    | zero =>
      exact ⟨⟨(R4.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendR] at h, Or.inl rfl,
        by simp [Count, pendR]⟩
    | succ c =>
      exact ⟨⟨(R4.r2, c, n), fun h => by simp [pendR] at h⟩, rfl, fun h => by simp [pendR] at h,
        Or.inl rfl, by simp [Count, pendR]⟩
  | r2 =>
    cases c with
    | zero =>
      exact ⟨⟨(R4.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendR] at h, Or.inl rfl,
        by simp [Count, pendR]⟩
    | succ c =>
      exact ⟨⟨(R4.r0, c, n), fun h => by simp [pendR] at h⟩, rfl, fun h => by simp [pendR] at h,
        Or.inl rfl, by simp [Count, pendR]⟩

/-- Backward seriality of the ladder over the object. -/
theorem bwdR : ∀ (t : ℤ) (x : LadderState R4 pendR), ∃ y, RladAdm stepR pendR (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  have hx' : pendR q = false → c = 0 := hx
  cases q with
  | idle =>
    have hc : c = 0 := hx' rfl
    subst hc
    exact ⟨⟨(R4.idle, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendR]⟩
  | r0 =>
    exact ⟨⟨(R4.r2, c + 1, n), fun h => by simp [pendR] at h⟩, rfl, fun h => by simp [pendR] at h,
      Or.inl rfl, by simp [Count, pendR]⟩
  | r1 =>
    exact ⟨⟨(R4.r0, c + 1, n), fun h => by simp [pendR] at h⟩, rfl, fun h => by simp [pendR] at h,
      Or.inl rfl, by simp [Count, pendR]⟩
  | r2 =>
    exact ⟨⟨(R4.r1, c + 1, n), fun h => by simp [pendR] at h⟩, rfl, fun h => by simp [pendR] at h,
      Or.inl rfl, by simp [Count, pendR]⟩

/-- **THE OBJECT WALK INSIDE A PENDING REGION IS FORCED**: it rotates. -/
theorem objAt_rot (g : ℤ → LadderState R4 pendR) (hg : IsLadderPath stepR pendR g) (u : ℤ)
    (hu : pendR (objAt g u) = true) :
    ∀ j : ℕ, j ≤ cntAt g u → objAt g (u + (j : ℤ)) = rotR^[j] (objAt g u) := by
  intro j
  induction j with
  | zero => intro _; simp
  | succ j ih =>
    intro hj
    have h1 := (cntAt_sub_of_pend g hg u hu j (by omega)).1
    have h2 := (cntAt_sub_of_pend g hg u hu (j + 1) hj).1
    have hcast : u + ((j + 1 : ℕ) : ℤ) = u + (j : ℤ) + 1 := by push_cast; ring
    rw [hcast] at h2 ⊢
    rw [stepR_pend h1 h2 (objAt_step g hg _), ih (by omega), Function.iterate_succ_apply']

/-- The tight pair: one object state, the shorter countdown exactly at the threshold of the budget
`(a, b + 1)`, the longer one modulus above it, registers equal to the countdowns. -/
def xR (a b : ℕ) : LadderState R4 pendR :=
  ⟨(R4.r0, 2 * (a + b) + 2, 2 * (a + b) + 2), fun h => by simp [pendR] at h⟩

def yR (P a b : ℕ) : LadderState R4 pendR :=
  ⟨(R4.r0, 2 * (a + b) + 2 + (P + 1), 2 * (a + b) + 2 + (P + 1)), fun h => by simp [pendR] at h⟩

/-- The tight pair is related by the residue-carrying relation, at EVERY modulus. -/
theorem Srel_xR_yR (P a b : ℕ) : Srel P a (b + 1) (xR a b) (yR P a b) := by
  refine ⟨⟨rfl, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩, ?_⟩
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2; omega
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2 + (P + 1); omega
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2; omega
  · change 2 * (a + (b + 1)) ≤ 2 * (a + b) + 2 + (P + 1); omega
  · change ((2 * (a + b) + 2 : ℕ) : ℤ) - ((2 * (a + b) + 2 : ℕ) : ℤ) =
      ((2 * (a + b) + 2 + (P + 1) : ℕ) : ℤ) - ((2 * (a + b) + 2 + (P + 1) : ℕ) : ℤ)
    omega
  · change ((2 * (a + b) + 2 : ℕ) : ℤ) ≡ ((2 * (a + b) + 2 + (P + 1) : ℕ) : ℤ) [ZMOD ((P : ℤ) + 1)]
    exact Int.modEq_iff_dvd.mpr ⟨1, by push_cast; ring⟩

/-- **NO TWO LADDER PATHS THROUGH THE TIGHT PAIR ARE ROW-LINKED** once the budget allows one
forward jump and one further unit.  Position `t + 3` of the longer region carries `r0` with a
large countdown; inside the shorter region only `t + 1` and `t + 2` can answer it on the
countdown, and they carry `r1` and `r2`; beyond the shorter region an answer passes a position of
countdown `0`, which nothing before `t + 3` on the longer region matches. -/
theorem not_lnkRow_xR_yR (P a b : ℕ) (hab : 1 ≤ a + b)
    (h h' : ℤ → LadderState R4 pendR) (hh : IsLadderPath stepR pendR h)
    (hh' : IsLadderPath stepR pendR h') (t : ℤ) (ht : h t = xR a b) (ht' : h' t = yR P a b) :
    ¬ LnkRow a (b + 1) h h' t t := by
  intro hl
  have hc : cntAt h t = 2 * (a + b) + 2 := by unfold cntAt; rw [ht]; rfl
  have hc' : cntAt h' t = 2 * (a + b) + 2 + (P + 1) := by unfold cntAt; rw [ht']; rfl
  have ho : objAt h t = R4.r0 := by unfold objAt; rw [ht]; rfl
  have ho' : objAt h' t = R4.r0 := by unfold objAt; rw [ht']; rfl
  have hp : pendR (objAt h t) = true := by rw [ho]; rfl
  have hp' : pendR (objAt h' t) = true := by rw [ho']; rfl
  have hsub := cntAt_sub_of_pend h hh t hp
  have hsub' := cntAt_sub_of_pend h' hh' t hp'
  rw [LnkRow] at hl
  obtain ⟨-, hj⟩ := hl.2.1 b rfl
  obtain ⟨s, hs, hR, hbt⟩ := hj (t + 3) (by omega)
  -- the challenger: position `t + 3` of the longer region
  have e3 : objAt h' (t + 3) = R4.r0 := by
    have := objAt_rot h' hh' t hp' 3 (by omega)
    rw [ho'] at this
    simpa [rotR] using this
  have c3 : cntAt h' (t + 3) = 2 * (a + b) + 2 + (P + 1) - 3 := by
    have := (hsub' 3 (by omega)).2
    rw [hc'] at this
    simpa using this
  obtain ⟨hq, hcnt, -, -⟩ := hR.zero
  have hq' : objAt h s = objAt h' (t + 3) := hq
  have hcnt' : cntAt h s = cntAt h' (t + 3) ∨
      (2 * (a + b) ≤ cntAt h s ∧ 2 * (a + b) ≤ cntAt h' (t + 3)) := hcnt
  by_cases hin : s ≤ t + (cntAt h t : ℤ)
  · -- the answer sits inside the shorter region
    have hsj := (hsub (s - t).toNat (by omega)).2
    rw [show t + (((s - t).toNat : ℕ) : ℤ) = s by omega] at hsj
    have hs12 : s = t + 1 ∨ s = t + 2 := by omega
    rcases hs12 with rfl | rfl
    · have := objAt_rot h hh t hp 1 (by omega)
      rw [ho] at this
      have e1 : objAt h (t + 1) = R4.r1 := by simpa [rotR] using this
      rw [e1, e3] at hq'
      cases hq'
    · have := objAt_rot h hh t hp 2 (by omega)
      rw [ho] at this
      have e2 : objAt h (t + 2) = R4.r2 := by simpa [rotR] using this
      rw [e2, e3] at hq'
      cases hq'
  · -- the answer sits beyond the shorter region, and passes its last position
    obtain ⟨r', hr1, hr2, hRr⟩ := hbt (t + (cntAt h t : ℤ)) (by omega) (by omega)
    obtain ⟨-, hcr, -, -⟩ := hRr.zero
    have hcr' : cntAt h (t + (cntAt h t : ℤ)) = cntAt h' r' ∨
        (2 * (a + b) ≤ cntAt h (t + (cntAt h t : ℤ)) ∧ 2 * (a + b) ≤ cntAt h' r') := hcr
    have h0 := (hsub (cntAt h t) le_rfl).2
    have hr := (hsub' (r' - t).toNat (by omega)).2
    rw [show t + (((r' - t).toNat : ℕ) : ℤ) = r' by omega] at hr
    omega

/-- **THE PATH FORTH WITH A WHOLE-ROW CORRESPONDENCE FAILS FROM THE RESIDUE-CARRYING RELATION.**
At every modulus `P + 1` and every row budget `(a, b + 1)` with `1 ≤ a + b` there are two
`Srel P a (b + 1)`-related states of the `3`-cycle object, a ladder path through the first, and NO
ladder path through the second that is row-linked to it.  The modulus is arbitrary, so the
statement covers every `P` the parameter condition `(K1)` admits for this object (those with
`3 ∣ P + 1`, by `three_mem_objCycleLens_R4`). -/
theorem no_rowLinked_path_of_Srel (P a b : ℕ) (hab : 1 ≤ a + b) :
    ∃ x y : LadderState R4 pendR, Srel P a (b + 1) x y ∧
      ∃ h : ℤ → LadderState R4 pendR, IsLadderPath stepR pendR h ∧ h 0 = x ∧
        ¬ ∃ h' : ℤ → LadderState R4 pendR, IsLadderPath stepR pendR h' ∧ h' 0 = y ∧
          LnkRow a (b + 1) h h' 0 0 := by
  obtain ⟨h, hh, h0⟩ := exists_path_through fwdR bwdR (xR a b) 0
  refine ⟨xR a b, yR P a b, Srel_xR_yR P a b, h, hh, h0, ?_⟩
  rintro ⟨h', hh', h0', hl⟩
  exact not_lnkRow_xR_yR P a b hab h h' hh hh' 0 h0 h0' hl

end ProbeRowResidue

/-- info: 'ProbeRowResidue.no_rowLinked_path_of_Srel' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.no_rowLinked_path_of_Srel

/-!
# The third object: a BRANCHING pending part

`C3`'s pending part is a forced `2`-cycle and `R4`'s a forced `3`-cycle: inside a pending region
the object walk over either is determined by the countdown (`objAt_flip`, `objAt_rot`).  The
object below is the first one of this file whose pending part BRANCHES: the pending state `b0` has
two distinct pending successors, `b1` and `b2`, the first closing a pending cycle of length `2`
(`b0 → b1 → b0`) and the second one of length `3` (`b0 → b2 → b3 → b0`).

## What this section compiles

* `B5`, `stepB`, `pendB` — the five-state object: `b0`-`b3` pending, each of which may exit to an
  idle sink.
* `branching_pendB` — THE DEFINING PROPERTY: `b0` is pending and steps to two distinct pending
  states.
* `two_mem_objCycleLens_B5`, `three_mem_objCycleLens_B5` — both `2` and `3` are pending cycle
  lengths, so a modulus `P + 1` admitted by `(K1)` for this object is divisible by both.
* `fwdB`, `bwdB` — the ladder over it is serial in both directions.
* `gB`, `gB_isLadderPath` — NON-VACUITY: an explicit ladder path, pending at every position `≤ 0`
  and idle after, whose object walk has period `5` and takes each branch in turn
  (`gB_takes_both_branches`).

## What this section does NOT settle

It states no relation between ladder states and attempts no refutation and no path forth.  It
does not say that the object walk inside a pending region is free in any stronger sense than
`branching_pendB` and `gB_takes_both_branches` record.  The divisibility of `P + 1` is a
consequence of `(K1)` read at this object, not a parameter condition added anywhere.
-/

namespace ProbeRowResidue

/-- A five-state object whose pending part branches: from `b0` the walk may take the `2`-cycle
`b0 → b1 → b0` or the `3`-cycle `b0 → b2 → b3 → b0`; each pending state may exit to the idle
sink. -/
inductive B5 : Type
  | b0 | b1 | b2 | b3 | idle
  deriving DecidableEq

instance : Fintype B5 := ⟨{B5.b0, B5.b1, B5.b2, B5.b3, B5.idle}, fun x => by cases x <;> simp⟩

def stepB : B5 → B5 → Bool
  | .b0, .b1 => true
  | .b0, .b2 => true
  | .b1, .b0 => true
  | .b2, .b3 => true
  | .b3, .b0 => true
  | .b0, .idle => true
  | .b1, .idle => true
  | .b2, .idle => true
  | .b3, .idle => true
  | .idle, .idle => true
  | _, _ => false

def pendB : B5 → Bool
  | .idle => false
  | _ => true

/-- **THE PENDING PART BRANCHES**: the pending state `b0` has two DISTINCT pending successors. -/
theorem branching_pendB :
    pendB B5.b0 = true ∧ stepB B5.b0 B5.b1 = true ∧ stepB B5.b0 B5.b2 = true ∧
      B5.b1 ≠ B5.b2 ∧ pendB B5.b1 = true ∧ pendB B5.b2 = true := by
  decide

/-- `2` is a pending cycle length of `B5`: `b0 → b1 → b0`. -/
theorem two_mem_objCycleLens_B5 : (2 : ℕ) ∈ objCycleLens stepB pendB := by
  refine ⟨by omega, by decide, fun i => if i % 2 = 0 then B5.b0 else B5.b1, ?_, ?_, ?_⟩
  · intro i
    rcases Nat.mod_two_eq_zero_or_one i with h0 | h1
    · have h : (i + 1) % 2 = 1 := by omega
      simp [h0, h, stepB]
    · have h : (i + 1) % 2 = 0 := by omega
      simp [h1, h, stepB]
  · intro i
    rcases Nat.mod_two_eq_zero_or_one i with h0 | h1 <;> simp [*, pendB]
  · simp

/-- The walk of the `3`-cycle `b0 → b2 → b3 → b0`, by residue. -/
def cyc3B (r : ℕ) : B5 :=
  match r with
  | 0 => .b0
  | 1 => .b2
  | _ => .b3

/-- `3` is a pending cycle length of `B5`: `b0 → b2 → b3 → b0`. -/
theorem three_mem_objCycleLens_B5 : (3 : ℕ) ∈ objCycleLens stepB pendB := by
  refine ⟨by omega, by decide, fun i => cyc3B (i % 3), ?_, ?_, ?_⟩
  · intro i
    show stepB (cyc3B (i % 3)) (cyc3B ((i + 1) % 3)) = true
    have h : i % 3 = 0 ∨ i % 3 = 1 ∨ i % 3 = 2 := by omega
    rcases h with h | h | h
    · rw [h, show (i + 1) % 3 = 1 by omega]; rfl
    · rw [h, show (i + 1) % 3 = 2 by omega]; rfl
    · rw [h, show (i + 1) % 3 = 0 by omega]; rfl
  · intro i
    show pendB (cyc3B (i % 3)) = true
    have h : i % 3 = 0 ∨ i % 3 = 1 ∨ i % 3 = 2 := by omega
    rcases h with h | h | h <;> rw [h] <;> rfl
  · rfl

/-- Forward seriality of the ladder over the object. -/
theorem fwdB : ∀ (t : ℤ) (x : LadderState B5 pendB), ∃ y, RladAdm stepB pendB t x y := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  have hx' : pendB q = false → c = 0 := hx
  cases q with
  | idle =>
    have hc : c = 0 := hx' rfl
    subst hc
    exact ⟨⟨(B5.idle, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendB]⟩
  | b0 =>
    cases c with
    | zero =>
      exact ⟨⟨(B5.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendB] at h, Or.inl rfl,
        by simp [Count, pendB]⟩
    | succ c =>
      exact ⟨⟨(B5.b1, c, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
        Or.inl rfl, by simp [Count, pendB]⟩
  | b1 =>
    cases c with
    | zero =>
      exact ⟨⟨(B5.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendB] at h, Or.inl rfl,
        by simp [Count, pendB]⟩
    | succ c =>
      exact ⟨⟨(B5.b0, c, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
        Or.inl rfl, by simp [Count, pendB]⟩
  | b2 =>
    cases c with
    | zero =>
      exact ⟨⟨(B5.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendB] at h, Or.inl rfl,
        by simp [Count, pendB]⟩
    | succ c =>
      exact ⟨⟨(B5.b3, c, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
        Or.inl rfl, by simp [Count, pendB]⟩
  | b3 =>
    cases c with
    | zero =>
      exact ⟨⟨(B5.idle, 0, n), fun _ => rfl⟩, rfl, fun h => by simp [pendB] at h, Or.inl rfl,
        by simp [Count, pendB]⟩
    | succ c =>
      exact ⟨⟨(B5.b0, c, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
        Or.inl rfl, by simp [Count, pendB]⟩

/-- Backward seriality of the ladder over the object. -/
theorem bwdB : ∀ (t : ℤ) (x : LadderState B5 pendB), ∃ y, RladAdm stepB pendB (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  have hx' : pendB q = false → c = 0 := hx
  cases q with
  | idle =>
    have hc : c = 0 := hx' rfl
    subst hc
    exact ⟨⟨(B5.idle, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendB]⟩
  | b0 =>
    exact ⟨⟨(B5.b1, c + 1, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
      Or.inl rfl, by simp [Count, pendB]⟩
  | b1 =>
    exact ⟨⟨(B5.b0, c + 1, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
      Or.inl rfl, by simp [Count, pendB]⟩
  | b2 =>
    exact ⟨⟨(B5.b0, c + 1, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
      Or.inl rfl, by simp [Count, pendB]⟩
  | b3 =>
    exact ⟨⟨(B5.b2, c + 1, n), fun h => by simp [pendB] at h⟩, rfl, fun h => by simp [pendB] at h,
      Or.inl rfl, by simp [Count, pendB]⟩

/-- The object walk of the witness path, by residue modulo `5`: the `2`-cycle then the `3`-cycle,
`b0 → b1 → b0 → b2 → b3 → b0`. -/
def walkB (r : ℤ) : B5 :=
  if r = 0 then .b0 else if r = 1 then .b1 else if r = 2 then .b0 else if r = 3 then .b2 else .b3

theorem pendB_walkB (r : ℤ) : pendB (walkB r) = true := by
  unfold walkB; split_ifs <;> rfl

/-- The non-vacuity witness: pending with countdown `-u` at every position `u ≤ 0`, the object
walking with period `5` through both branches; idle at every position `u > 0`. -/
def gB (u : ℤ) : LadderState B5 pendB :=
  if u ≤ 0 then ⟨(walkB (u % 5), (-u).toNat, 0), fun h => by simp [pendB_walkB] at h⟩
  else ⟨(B5.idle, 0, 0), fun _ => rfl⟩

/-- **NON-VACUITY**: `gB` is a ladder path over the branching object, at every position. -/
theorem gB_isLadderPath : IsLadderPath stepB pendB gB := by
  intro u
  show Rlad stepB pendB u (gB u).1 (gB (u + 1)).1
  by_cases h0 : u + 1 ≤ 0
  · -- both positions pending
    have hu : u ≤ 0 := by omega
    have e1 : (gB u).1 = (walkB (u % 5), (-u).toNat, 0) := by unfold gB; rw [if_pos hu]
    have e2 : (gB (u + 1)).1 = (walkB ((u + 1) % 5), (-(u + 1)).toNat, 0) := by
      unfold gB; rw [if_pos h0]
    rw [e1, e2]
    refine ⟨?_, fun h => by simp [pendB_walkB] at h, Or.inl rfl, ?_⟩
    · show stepB (walkB (u % 5)) (walkB ((u + 1) % 5)) = true
      have h : u % 5 = 0 ∨ u % 5 = 1 ∨ u % 5 = 2 ∨ u % 5 = 3 ∨ u % 5 = 4 := by omega
      rcases h with h | h | h | h | h
      · rw [h, show (u + 1) % 5 = 1 by omega]; decide
      · rw [h, show (u + 1) % 5 = 2 by omega]; decide
      · rw [h, show (u + 1) % 5 = 3 by omega]; decide
      · rw [h, show (u + 1) % 5 = 4 by omega]; decide
      · rw [h, show (u + 1) % 5 = 0 by omega]; decide
    · show Count (pendB (walkB (u % 5))) (pendB (walkB ((u + 1) % 5))) (-u).toNat 0
        (-(u + 1)).toNat
      rw [pendB_walkB, pendB_walkB]
      show (-(u + 1)).toNat + 1 = (-u).toNat
      omega
  · by_cases h1 : u ≤ 0
    · -- the region ends: `u = 0`
      have hu : u = 0 := by omega
      subst hu
      exact ⟨by decide, fun h => by simp [gB, walkB, pendB] at h, Or.inl rfl, by decide⟩
    · -- both positions idle
      have e1 : (gB u).1 = (B5.idle, 0, 0) := by unfold gB; rw [if_neg h1]
      have e2 : (gB (u + 1)).1 = (B5.idle, 0, 0) := by unfold gB; rw [if_neg h0]
      rw [e1, e2]
      exact ⟨rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendB]⟩

/-- **THE WITNESS WALKS THE BRANCH**: `gB` leaves `b0` to `b1` at one position and to `b2` at
another, so both successors named by `branching_pendB` are taken on one ladder path. -/
theorem gB_takes_both_branches :
    objAt gB (-5) = B5.b0 ∧ objAt gB (-4) = B5.b1 ∧ objAt gB (-3) = B5.b0 ∧
      objAt gB (-2) = B5.b2 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rfl

/-- The witness is pending with a positive countdown before `0`, so it is not an idle path. -/
theorem cntAt_gB_neg (k : ℕ) : cntAt gB (-(k : ℤ)) = k := by
  have h : -(k : ℤ) ≤ 0 := by omega
  unfold cntAt gB
  rw [if_pos h]
  show (- -(k : ℤ)).toNat = k
  omega

end ProbeRowResidue

/-- info: 'ProbeRowResidue.branching_pendB' depends on axioms: [propext] -/
#guard_msgs in
#print axioms ProbeRowResidue.branching_pendB

/-- info: 'ProbeRowResidue.two_mem_objCycleLens_B5' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.two_mem_objCycleLens_B5

/-- info: 'ProbeRowResidue.three_mem_objCycleLens_B5' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.three_mem_objCycleLens_B5

/-- info: 'ProbeRowResidue.fwdB' depends on axioms: [propext] -/
#guard_msgs in
#print axioms ProbeRowResidue.fwdB

/-- info: 'ProbeRowResidue.bwdB' depends on axioms: [propext] -/
#guard_msgs in
#print axioms ProbeRowResidue.bwdB

/-- info: 'ProbeRowResidue.gB_isLadderPath' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.gB_isLadderPath

/-- info: 'ProbeRowResidue.gB_takes_both_branches' depends on axioms: [propext] -/
#guard_msgs in
#print axioms ProbeRowResidue.gB_takes_both_branches

/-!
# The object-dependent THRESHOLD relation, and the two attacks on it

The library module now carries `Mrel P a b` — `Srel P a b` with one conjunct added, the two
countdowns equal or both at least `(P + 1) * (a + b)`.  Its countdown threshold has the margin
`P + 1` per unit of budget, where `Zrel`'s own has the object-independent margin `2`, so the
margin grows with the object's pending cycle lengths through the modulus `(K1)` constrains.

This section records the round that attacked it, on BOTH fixtures and in the order the attacks
were owed.  **It lands NO refutation and NO path forth.**  What it compiles is why each of the two
attacks cannot break the relation — statements about the attacks, not about `Mrel`.

## Attack 1, on the forced pending `3`-cycle `R4`, aimed at the residue count

* `not_Mrel_xR_yR` — the pair that refutes `Srel` is NOT `Mrel`-related at any modulus `(K1)`
  admits for this object.  At the budget `(a, b + 1)` the raised threshold is
  `(P + 1) * (a + b + 1)` while that pair's shorter countdown is exactly `2 * (a + b) + 2`, and
  `3 ∣ P + 1` forces `3 * (a + b + 1) ≤ 2 * (a + b) + 2`, which is false for every `a` and `b`.
  So `not_lnkRow_xR_yR` does not transfer and the attack must be re-aimed upward.
* `xM`, `yM`, `Mrel_xM_yM` — the re-aimed pair, both countdowns at or above the raised threshold
  and a modulus apart, with registers equal to the countdowns so both gaps are `0`.
* `rotR_iterate_dvd_three`, `region_end_agrees_R4` — at the re-aimed pair the necessary condition
  `LnkRow.region_end_obj` is SATISFIED rather than broken: the two regions, of lengths differing
  by `P + 1`, end at one object state, because the forced walk has period `3` and `3 ∣ P + 1`.
  This is the residue count the raised threshold was designed to survive, and it survives it.

## Attack 2, on the BRANCHING object `B5`, aimed at the choice of walk

* `region_end_matchable_B5` — raising a countdown threshold indeed says nothing about a choice of
  walk, but on this object the branching cuts the OTHER way for a refutation: it enlarges the
  second path's option set.  For EVERY pending object walk of length `L` from `b0` there is a
  pending object walk of length `L + (P + 1)` from `b0` ending at the same state, whenever
  `2 ∣ P + 1` — the second walk spends the difference in the `2`-cycle `b0 → b1 → b0` and then
  copies the first.  So the object coordinate of `LnkRow.region_end_obj` is satisfiable here too,
  and the branching does not supply the obstruction the attack was aimed at.

## What this section does NOT settle

It does not refute the path forth from `Mrel` and it does not prove one.  Both results above are
about the two NECESSARY conditions `LnkRow.first_zero` and `LnkRow.region_end_obj`; satisfying a
necessary condition is not a row link, and `region_end_matchable_B5` is a statement about object
walks that constructs no ladder path and asserts no `LnkRow`.  The coordinate left unmeasured is
what an INTERMEDIATE position of the longer region must be answered on beyond its countdown and
its object state: `Zrel` at the budget left also reads the gap `n - c`, and neither `Mrel` nor
either obstruction lemma constrains the register at an intermediate position.  Nothing here bears
on the clip, on `ladderLift`, or on `cellAt_const_of_kappa_eq`.
-/

namespace ProbeRowResidue

/-! ### Attack 1: the landed pair does not transfer, and the re-aimed pair is not broken -/

/-- **THE LANDED TIGHT PAIR IS NOT `Mrel`-RELATED.**  Ruling 18's arithmetic, against the live
fixture: at every modulus `(K1)` admits for `R4` the raised threshold already exceeds the shorter
countdown of the pair that refutes `Srel`. -/
theorem not_Mrel_xR_yR (P a b : ℕ) (h3 : 3 ∣ P + 1) :
    ¬ Mrel P a (b + 1) (xR a b) (yR P a b) := by
  rintro ⟨-, h⟩
  have hx : (xR a b).1.2.1 = 2 * (a + b) + 2 := rfl
  have hy : (yR P a b).1.2.1 = 2 * (a + b) + 2 + (P + 1) := rfl
  have h3' : 3 ≤ P + 1 := Nat.le_of_dvd (by omega) h3
  have hmul : 3 * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1)) :=
    Nat.mul_le_mul_right _ h3'
  rw [hx, hy] at h
  omega

/-- The re-aimed pair: the shorter countdown exactly AT the raised threshold, the longer one a
modulus above it, registers equal to the countdowns. -/
def xM (P a b : ℕ) : LadderState R4 pendR :=
  ⟨(R4.r0, (P + 1) * (a + (b + 1)), (P + 1) * (a + (b + 1))), fun h => by simp [pendR] at h⟩

def yM (P a b : ℕ) : LadderState R4 pendR :=
  ⟨(R4.r0, (P + 1) * (a + (b + 1)) + (P + 1), (P + 1) * (a + (b + 1)) + (P + 1)),
    fun h => by simp [pendR] at h⟩

/-- The re-aimed pair IS `Mrel`-related at the budget `(a, b + 1)`, so the attack has a target. -/
theorem Mrel_xM_yM (P a b : ℕ) (h3 : 3 ∣ P + 1) :
    Mrel P a (b + 1) (xM P a b) (yM P a b) := by
  have h3' : 3 ≤ P + 1 := Nat.le_of_dvd (by omega) h3
  have hmul : 2 * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1)) := by
    calc 2 * (a + (b + 1)) ≤ 3 * (a + (b + 1)) := by omega
      _ ≤ (P + 1) * (a + (b + 1)) := Nat.mul_le_mul_right _ h3'
  refine ⟨⟨⟨rfl, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩, ?_⟩, Or.inr ⟨?_, ?_⟩⟩
  · show 2 * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1))
    exact hmul
  · show 2 * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1)) + (P + 1)
    omega
  · show 2 * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1))
    exact hmul
  · show 2 * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1)) + (P + 1)
    omega
  · change (((P + 1) * (a + (b + 1)) : ℕ) : ℤ) - (((P + 1) * (a + (b + 1)) : ℕ) : ℤ) =
      (((P + 1) * (a + (b + 1)) + (P + 1) : ℕ) : ℤ) -
        (((P + 1) * (a + (b + 1)) + (P + 1) : ℕ) : ℤ)
    omega
  · change (((P + 1) * (a + (b + 1)) : ℕ) : ℤ) ≡
      (((P + 1) * (a + (b + 1)) + (P + 1) : ℕ) : ℤ) [ZMOD ((P : ℤ) + 1)]
    exact Int.modEq_iff_dvd.mpr ⟨1, by push_cast; ring⟩
  · show (P + 1) * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1))
    exact le_rfl
  · show (P + 1) * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1)) + (P + 1)
    omega

/-- The forced walk of `R4` has period `3`. -/
theorem rotR_iterate_three (q : R4) : rotR^[3] q = q := by cases q <;> rfl

/-- Every multiple of `3` is a period of the forced walk. -/
theorem rotR_iterate_dvd_three {m : ℕ} (h : 3 ∣ m) (q : R4) : rotR^[m] q = q := by
  obtain ⟨k, rfl⟩ := h
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [show 3 * (k + 1) = 3 * k + 3 by ring, Function.iterate_add_apply, rotR_iterate_three, ih]

/-- **ATTACK 1 DOES NOT BREAK THE RELATION.**  At the re-aimed pair the necessary condition
`LnkRow.region_end_obj` is satisfied: the two current regions, whose lengths differ by exactly the
modulus, end at ONE object state.  The forced walk of `R4` has period `3` and `(K1)` forces
`3 ∣ P + 1`, so the extra `P + 1` positions of the longer region return the walk to where it
started.  This is the residue count the raised threshold was designed to survive. -/
theorem region_end_agrees_R4 (P a b : ℕ) (h3 : 3 ∣ P + 1)
    (h h' : ℤ → LadderState R4 pendR) (hh : IsLadderPath stepR pendR h)
    (hh' : IsLadderPath stepR pendR h') (t : ℤ)
    (ht : h t = xM P a b) (ht' : h' t = yM P a b) :
    objAt h' (t + (cntAt h' t : ℤ)) = objAt h (t + (cntAt h t : ℤ)) := by
  have hc : cntAt h t = (P + 1) * (a + (b + 1)) := by unfold cntAt; rw [ht]; rfl
  have hc' : cntAt h' t = (P + 1) * (a + (b + 1)) + (P + 1) := by unfold cntAt; rw [ht']; rfl
  have ho : objAt h t = R4.r0 := by unfold objAt; rw [ht]; rfl
  have ho' : objAt h' t = R4.r0 := by unfold objAt; rw [ht']; rfl
  have hp : pendR (objAt h t) = true := by rw [ho]; rfl
  have hp' : pendR (objAt h' t) = true := by rw [ho']; rfl
  rw [hc, hc']
  rw [objAt_rot h hh t hp _ (by omega), objAt_rot h' hh' t hp' _ (by omega), ho, ho',
    show (P + 1) * (a + (b + 1)) + (P + 1) = (P + 1) * (a + (b + 1)) + (P + 1) from rfl,
    Function.iterate_add_apply, rotR_iterate_dvd_three h3]

/-! ### Attack 2: the branching object enlarges the second walk's options -/

/-- The `2`-cycle walk `b0 → b1 → b0`, by residue. -/
def cyc2B (r : ℕ) : B5 := if r % 2 = 0 then B5.b0 else B5.b1

theorem cyc2B_pend (i : ℕ) : pendB (cyc2B i) = true := by
  unfold cyc2B
  rcases Nat.mod_two_eq_zero_or_one i with h | h
  · rw [if_pos h]; rfl
  · rw [if_neg (by omega)]; rfl

theorem cyc2B_step (i : ℕ) : stepB (cyc2B i) (cyc2B (i + 1)) = true := by
  unfold cyc2B
  rcases Nat.mod_two_eq_zero_or_one i with h | h
  · rw [if_pos h, if_neg (by omega)]; rfl
  · rw [if_neg (by omega), if_pos (by omega)]; rfl

theorem cyc2B_odd {i : ℕ} (h : i % 2 = 1) : cyc2B i = B5.b1 := by
  unfold cyc2B; rw [if_neg (by omega)]

/-- The second walk: spend the extra `P + 1` positions in the `2`-cycle, then copy the first. -/
def spliceB (P : ℕ) (w : ℕ → B5) (i : ℕ) : B5 :=
  if i ≤ P then cyc2B i else w (i - (P + 1))

/-- **ATTACK 2 DOES NOT BREAK THE RELATION EITHER.**  On the branching object, for EVERY pending
object walk of length `L` from `b0` there is a pending object walk of length `L + (P + 1)` from
`b0` ending at the same state, whenever `2 ∣ P + 1` — which `(K1)` forces here, `2` being a
pending cycle length of `B5` (`two_mem_objCycleLens_B5`).  The second walk spends the extra
`P + 1` positions in the `2`-cycle and then copies the first.  So the object coordinate of
`LnkRow.region_end_obj` is satisfiable at the longer length, and the branching — which enlarges
the second path's option set rather than shrinking it — supplies no obstruction.

This constructs an object WALK, not a ladder path, and asserts no row link. -/
theorem region_end_matchable_B5 {P : ℕ} (h2 : 2 ∣ P + 1) (L : ℕ)
    (w : ℕ → B5) (hw0 : w 0 = B5.b0)
    (hstep : ∀ i, i < L → stepB (w i) (w (i + 1)) = true)
    (hpend : ∀ i, i ≤ L → pendB (w i) = true) :
    ∃ v : ℕ → B5, v 0 = B5.b0 ∧
      (∀ i, i < L + (P + 1) → stepB (v i) (v (i + 1)) = true) ∧
      (∀ i, i ≤ L + (P + 1) → pendB (v i) = true) ∧
      v (L + (P + 1)) = w L := by
  have hPodd : P % 2 = 1 := by omega
  refine ⟨spliceB P w, ?_, ?_, ?_, ?_⟩
  · unfold spliceB
    rw [if_pos (Nat.zero_le P)]
    unfold cyc2B
    rw [if_pos rfl]
  · intro i hi
    unfold spliceB
    by_cases h1 : i ≤ P
    · by_cases h2' : i + 1 ≤ P
      · rw [if_pos h1, if_pos h2']
        exact cyc2B_step i
      · have hiP : i = P := by omega
        rw [if_pos h1, if_neg (by omega), cyc2B_odd (show i % 2 = 1 by omega),
          show i + 1 - (P + 1) = 0 by omega, hw0]
        rfl
    · rw [if_neg h1, if_neg (by omega),
        show i + 1 - (P + 1) = (i - (P + 1)) + 1 by omega]
      exact hstep (i - (P + 1)) (by omega)
  · intro i hi
    unfold spliceB
    by_cases h1 : i ≤ P
    · rw [if_pos h1]
      exact cyc2B_pend i
    · rw [if_neg h1]
      exact hpend _ (by omega)
  · unfold spliceB
    rw [if_neg (by omega), show L + (P + 1) - (P + 1) = L by omega]

end ProbeRowResidue

/-- info: 'ProbeRowResidue.not_Mrel_xR_yR' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.not_Mrel_xR_yR

/-- info: 'ProbeRowResidue.Mrel_xM_yM' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.Mrel_xM_yM

/-- info: 'ProbeRowResidue.region_end_agrees_R4' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.region_end_agrees_R4

/-- info: 'ProbeRowResidue.region_end_matchable_B5' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.region_end_matchable_B5

/-!
# THE REGISTER COORDINATE AT THE `Mrel` PAIR, MEASURED

This section is appended by the round that measures the ONE coordinate the threshold round left
unmeasured.  Nothing above it is edited.

**THE REGISTER'S LOCAL LAW, RE-DERIVED FROM `RladAdm` ALONE.**  `RladAdm step pend t x y` is
`Rlad step pend t x.1 y.1`, whose four conjuncts are `step x.1 y.1`, `pend x.1 = false → x.2.1 = 0`,
`Drift x.2.2 y.2.2` and `Count (pend x.1) (pend y.1) x.2.1 x.2.2 y.2.1`.  The register `n = x.2.2`
occurs in exactly two of them:

* in `Drift n n'`, which is `n' = n ∨ n' = n + 1 ∨ n' + 1 = n` — a free `±1`/`0` walk;
* inside `Count`, and there ONLY at an idle-to-pending transition, where `c' = n` seeds the new
  countdown.  Inside a pending region (`px = py = true`) `Count` is `c' + 1 = c` and does not
  mention the register at all.  `Adm pend q = {c | pend q = false → c = 0}` constrains the
  COUNTDOWN, never the register.

So inside a pending region the register is an unconstrained `Drift` walk, and the only forced
consequences are the two recorded here: it falls by at most one per step (`nxt_ge_sub`), and
since the countdown inside a region falls by EXACTLY one per step, the gap `n - c` is
non-decreasing along a region and rises by at most two per step (`gap_mono_of_pend`).

**WHAT `Zrel a b` DEMANDS OF AN ANSWERING PAIR** (`LadderStepFrag.lean:201`, read verbatim): one
object state; countdowns equal or both `≥ 2 (a + b)`; registers equal or both `≥ 2 (a + b)`; and
gaps `n - c` equal, or both `≥ 2 a`, or both `≤ -(2 b + 2)`.

**WHAT IS MEASURED AND WHAT IS NOT.**  Both statements below are POINTWISE: each position of the
longer region is given an answering position of the shorter one and the four `Zrel` clauses are
checked there.  Neither is a row link: `LnkRow` additionally demands the recursive jump structure
and the back-matching condition at every budget, and nothing here supplies either.  No `def`
relating two ladder states is added, `Mrel` is not edited, and no path forth is landed.
-/

namespace ProbeRowResidue

/-! ### The register's forced law, in the ladder conditions' own terms -/

/-- **THE REGISTER FALLS BY AT MOST ONE PER STEP.**  The only law `RladAdm` places on the register
is `Drift`, so over `i` steps it can fall by at most `i`.  Nothing bounds its rise. -/
theorem nxt_ge_sub {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ) :
    ∀ i : ℕ, nxtAt g u ≤ nxtAt g (u + (i : ℤ)) + i := by
  intro i
  induction i with
  | zero => simp
  | succ i ih =>
    have hd : Drift (nxtAt g (u + (i : ℤ))) (nxtAt g (u + (i : ℤ) + 1)) :=
      (isLadderPath_components g hg (u + (i : ℤ))).2.2.1
    unfold Drift at hd
    have hcast : u + ((i + 1 : ℕ) : ℤ) = u + (i : ℤ) + 1 := by push_cast; ring
    rw [hcast]
    omega

/-- **THE GAP IS NON-DECREASING INSIDE A PENDING REGION, AND RISES BY AT MOST TWO PER STEP.**  The
countdown falls by exactly one per step inside a region while the register drifts, so the two
laws compose into a one-sided bound on the gap.  This is the whole of what the ladder conditions
force about the register at an intermediate position. -/
theorem gap_mono_of_pend {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ)
    (hu : pend (objAt g u) = true) (hc : 1 ≤ cntAt g u) :
    (nxtAt g u : ℤ) - cntAt g u ≤ (nxtAt g (u + 1) : ℤ) - cntAt g (u + 1) ∧
      (nxtAt g (u + 1) : ℤ) - cntAt g (u + 1) ≤ (nxtAt g u : ℤ) - cntAt g u + 2 := by
  obtain ⟨-, -, hd, hcnt⟩ := isLadderPath_components g hg u
  have h1 := (cntAt_sub_of_pend g hg u hu 1 (by omega)).1
  rw [show u + ((1 : ℕ) : ℤ) = u + 1 by push_cast; ring] at h1
  rw [hu, h1] at hcnt
  unfold Count at hcnt
  rw [if_pos rfl, if_pos rfl] at hcnt
  unfold Drift at hd
  omega

end ProbeRowResidue

namespace ProbeRowResidue

/-! ### The measurement on `R4`, at the landed pair `xM`/`yM` -/

/-- The length of the SHORTER region of the landed pair: the countdown `xM` carries. -/
def cM (P a b : ℕ) : ℕ := (P + 1) * (a + (b + 1))

/-- **THE EXHIBITED ANSWERING POSITION.**  Offset `j` of the longer region is answered at offset
`j` of the shorter one while `j ≤ P` — there is no countdown-matching partner for the longer
region's first `P + 1` positions, and the threshold escape carries them — and at offset
`j - (P + 1)` afterwards, where every clause holds by equality. -/
def ansM (P : ℕ) (t : ℤ) (j : ℕ) : ℤ :=
  if j ≤ P then t + (j : ℤ) else t + ((j - (P + 1) : ℕ) : ℤ)

/-- **THE EXHIBITED REGISTER**, as a function of the offset: the shorter path's own register,
raised by exactly the modulus over the first `P + 1` positions and copied unshifted afterwards. -/
def regM (P : ℕ) (h : ℤ → LadderState R4 pendR) (t : ℤ) (j : ℕ) : ℕ :=
  if j ≤ P then nxtAt h (t + (j : ℤ)) + (P + 1) else nxtAt h (t + ((j - (P + 1) : ℕ) : ℤ))

/-- The forced walk never leaves the pending part. -/
theorem pendR_rotR_iterate (j : ℕ) : pendR (rotR^[j] R4.r0) = true := by
  induction j with
  | zero => rfl
  | succ j ih =>
    rw [Function.iterate_succ_apply']
    revert ih
    generalize rotR^[j] R4.r0 = q
    cases q <;> simp [pendR, rotR]

/-- The exhibited state at offset `j` of the LONGER region: the object and the countdown as the
ladder conditions force them at every ladder path through `yM` (`longer_region_forced`), and the
register as `regM` exhibits it. -/
def stM (P a b : ℕ) (h : ℤ → LadderState R4 pendR) (t : ℤ) (j : ℕ) : LadderState R4 pendR :=
  ⟨(rotR^[j] R4.r0, cM P a b + (P + 1) - j, regM P h t j),
    fun hq => by rw [pendR_rotR_iterate] at hq; exact absurd hq (by simp)⟩

/-- The exhibited family starts AT the landed pair's second state. -/
theorem stM_zero (P a b : ℕ) (h : ℤ → LadderState R4 pendR) (t : ℤ)
    (ht : h t = xM P a b) : stM P a b h t 0 = yM P a b := by
  have hn : nxtAt h t = cM P a b := by unfold nxtAt cM; rw [ht]; rfl
  apply Subtype.ext
  show (rotR^[0] R4.r0, cM P a b + (P + 1) - 0, regM P h t 0) = _
  have hr : regM P h t 0 = cM P a b + (P + 1) := by
    unfold regM
    rw [if_pos (Nat.zero_le P)]
    simpa using hn
  rw [hr]
  show (R4.r0, cM P a b + (P + 1) - 0, cM P a b + (P + 1)) = _
  simp [yM, cM]

/-- **THE LONGER REGION'S OBJECT AND COUNTDOWN ARE FORCED**, at every ladder path through `yM`:
only the register is free.  This is what makes `stM` a measurement of the register rather than a
choice of three coordinates. -/
theorem longer_region_forced (P a b : ℕ) (h' : ℤ → LadderState R4 pendR)
    (hh' : IsLadderPath stepR pendR h') (t : ℤ) (ht' : h' t = yM P a b) (j : ℕ)
    (hj : j ≤ cM P a b + (P + 1)) :
    objAt h' (t + (j : ℤ)) = rotR^[j] R4.r0 ∧
      cntAt h' (t + (j : ℤ)) = cM P a b + (P + 1) - j := by
  have ho : objAt h' t = R4.r0 := by unfold objAt; rw [ht']; rfl
  have hc : cntAt h' t = cM P a b + (P + 1) := by unfold cntAt cM; rw [ht']; rfl
  have hp : pendR (objAt h' t) = true := by rw [ho]; rfl
  refine ⟨?_, ?_⟩
  · rw [objAt_rot h' hh' t hp j (by omega), ho]
  · have := (cntAt_sub_of_pend h' hh' t hp j (by omega)).2
    omega

/-- **THE MEASUREMENT ON `R4`.**  At the landed `Mrel` pair `xM`/`yM`, EVERY position of the
longer region admits an answering position of the shorter one — `ansM`, exhibited — at which all
four clauses of `Zrel` at the budget left hold, with the longer region's register EXHIBITED by
`regM` and its object and countdown the forced ones.

The two branches are different in kind and the difference is the measurement's content.  Past the
modulus every clause holds by EQUALITY: the countdowns agree because the regions differ by exactly
`P + 1`, the objects because `3 ∣ P + 1` returns the forced walk to where it started, and the
register and gap because `regM` copies the shorter path's own register.  Over the first `P + 1`
positions no countdown-matching partner exists, and what carries them is the register's one-sided
law: `nxt_ge_sub` forces the shorter path's register to stay at least `cM - j` there, which the
`(K1)`-admissible modulus keeps above `2 (a + b)`, so the countdown and register clauses pass on
their thresholds while the gap clause passes by equality, `regM` being the shorter register raised
by exactly `P + 1`.

This is POINTWISE.  It is not a row link and does not become one: `LnkRow` demands the recursive
jump structure and the back-matching condition at every budget, and `regM`'s two branches are each
a `Drift` walk but are not shown to join into one at the switch. -/
theorem register_answerable_R4 (P a b : ℕ) (h3 : 3 ∣ P + 1)
    (h : ℤ → LadderState R4 pendR) (hh : IsLadderPath stepR pendR h) (t : ℤ)
    (ht : h t = xM P a b) (j : ℕ) (hj : j ≤ cM P a b + (P + 1)) :
    Zrel a b (stM P a b h t j) (h (ansM P t j)) := by
  have h3' : 3 ≤ P + 1 := Nat.le_of_dvd (by omega) h3
  have hC : cM P a b = (P + 1) * (a + b) + (P + 1) := by
    unfold cM; ring
  have hCge : 3 * (a + b) ≤ (P + 1) * (a + b) := Nat.mul_le_mul_right _ h3'
  have ho : objAt h t = R4.r0 := by unfold objAt; rw [ht]; rfl
  have hc : cntAt h t = cM P a b := by unfold cntAt cM; rw [ht]; rfl
  have hn : nxtAt h t = cM P a b := by unfold nxtAt cM; rw [ht]; rfl
  have hp : pendR (objAt h t) = true := by rw [ho]; rfl
  by_cases hjP : j ≤ P
  · -- the longer region's extra prefix: the threshold escape, carried by `nxt_ge_sub`
    have hjC : j ≤ cM P a b := by omega
    have hcj : cntAt h (t + (j : ℤ)) = cM P a b - j :=
      by have := (cntAt_sub_of_pend h hh t hp j (by omega)).2; omega
    have hoj : objAt h (t + (j : ℤ)) = rotR^[j] R4.r0 := by
      rw [objAt_rot h hh t hp j (by omega), ho]
    have hnj : cM P a b ≤ nxtAt h (t + (j : ℤ)) + j := by
      have := nxt_ge_sub h hh t j; omega
    have hbig : 2 * (a + b) ≤ nxtAt h (t + (j : ℤ)) := by omega
    have hans : ansM P t j = t + (j : ℤ) := by unfold ansM; rw [if_pos hjP]
    have hreg : regM P h t j = nxtAt h (t + (j : ℤ)) + (P + 1) := by
      unfold regM; rw [if_pos hjP]
    rw [hans]
    refine ⟨?_, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩
    · show rotR^[j] R4.r0 = (h (t + (j : ℤ))).1.1
      rw [← hoj]; rfl
    · show 2 * (a + b) ≤ cM P a b + (P + 1) - j; omega
    · show 2 * (a + b) ≤ (h (t + (j : ℤ))).1.2.1
      change 2 * (a + b) ≤ cntAt h (t + (j : ℤ)); omega
    · show 2 * (a + b) ≤ regM P h t j; omega
    · show 2 * (a + b) ≤ (h (t + (j : ℤ))).1.2.2
      change 2 * (a + b) ≤ nxtAt h (t + (j : ℤ)); omega
    · show ((regM P h t j : ℤ) - ((cM P a b + (P + 1) - j : ℕ) : ℤ)) =
        (((h (t + (j : ℤ))).1.2.2 : ℕ) : ℤ) - (((h (t + (j : ℤ))).1.2.1 : ℕ) : ℤ)
      change (regM P h t j : ℤ) - ((cM P a b + (P + 1) - j : ℕ) : ℤ) =
        ((nxtAt h (t + (j : ℤ)) : ℕ) : ℤ) - ((cntAt h (t + (j : ℤ)) : ℕ) : ℤ)
      rw [hreg, hcj]
      have h1 : (((cM P a b + (P + 1) - j : ℕ)) : ℤ) = (cM P a b : ℤ) + (P + 1) - j := by
        have : j ≤ cM P a b + (P + 1) := by omega
        push_cast [Nat.cast_sub this]; ring
      have h2 : (((cM P a b - j : ℕ)) : ℤ) = (cM P a b : ℤ) - j := by
        push_cast [Nat.cast_sub hjC]; ring
      rw [h1, h2]; push_cast; ring
  · -- past the modulus: every clause by equality
    have hjP' : P + 1 ≤ j := by omega
    set i : ℕ := j - (P + 1) with hi
    have hiC : i ≤ cM P a b := by omega
    have hji : j = i + (P + 1) := by omega
    have hcj : cntAt h (t + (i : ℤ)) = cM P a b - i :=
      by have := (cntAt_sub_of_pend h hh t hp i (by omega)).2; omega
    have hoj : objAt h (t + (i : ℤ)) = rotR^[i] R4.r0 := by
      rw [objAt_rot h hh t hp i (by omega), ho]
    have hrot : rotR^[j] R4.r0 = rotR^[i] R4.r0 := by
      rw [hji, Function.iterate_add_apply, rotR_iterate_dvd_three h3]
    have hans : ansM P t j = t + (i : ℤ) := by unfold ansM; rw [if_neg hjP]
    have hreg : regM P h t j = nxtAt h (t + (i : ℤ)) := by
      unfold regM; rw [if_neg hjP]
    rw [hans]
    refine ⟨?_, Or.inl ?_, Or.inl ?_, Or.inl ?_⟩
    · show rotR^[j] R4.r0 = (h (t + (i : ℤ))).1.1
      rw [hrot, ← hoj]; rfl
    · show cM P a b + (P + 1) - j = (h (t + (i : ℤ))).1.2.1
      change _ = cntAt h (t + (i : ℤ))
      omega
    · show regM P h t j = (h (t + (i : ℤ))).1.2.2
      change _ = nxtAt h (t + (i : ℤ))
      exact hreg
    · show ((regM P h t j : ℕ) : ℤ) - ((cM P a b + (P + 1) - j : ℕ) : ℤ) =
        (((h (t + (i : ℤ))).1.2.2 : ℕ) : ℤ) - (((h (t + (i : ℤ))).1.2.1 : ℕ) : ℤ)
      change ((regM P h t j : ℕ) : ℤ) - ((cM P a b + (P + 1) - j : ℕ) : ℤ) =
        ((nxtAt h (t + (i : ℤ)) : ℕ) : ℤ) - ((cntAt h (t + (i : ℤ)) : ℕ) : ℤ)
      rw [hreg, hcj]
      have h1 : ((cM P a b + (P + 1) - j : ℕ) : ℤ) = ((cM P a b - i : ℕ) : ℤ) := by
        congr 1; omega
      rw [h1]

/-- **NON-VACUITY**: ladder paths through `xM` exist at every position, so the measurement is a
statement about something. -/
theorem exists_path_through_xM (P a b : ℕ) (t : ℤ) :
    ∃ h : ℤ → LadderState R4 pendR, IsLadderPath stepR pendR h ∧ h t = xM P a b :=
  exists_path_through fwdR bwdR (xM P a b) t

end ProbeRowResidue

namespace ProbeRowResidue

/-! ### The measurement on `B5`, over the walk `region_end_matchable_B5` supplies -/

/-- The `2`-cycle walk of the branching object, read on `ℤ`.  This is the walk
`region_end_matchable_B5` spends the extra `P + 1` positions in; with `2 ∣ P + 1` the walk
`spliceB P` builds from it is the same walk again, so the longer region here IS the `2`-cycle. -/
def cyc2Bz (u : ℤ) : B5 := if u % 2 = 0 then B5.b0 else B5.b1

theorem cyc2Bz_pend (u : ℤ) : pendB (cyc2Bz u) = true := by
  unfold cyc2Bz; split_ifs <;> rfl

theorem cyc2Bz_step (u : ℤ) : stepB (cyc2Bz u) (cyc2Bz (u + 1)) = true := by
  unfold cyc2Bz
  by_cases h : u % 2 = 0
  · rw [if_pos h, if_neg (by omega)]; rfl
  · rw [if_neg h, if_pos (by omega)]; rfl

theorem cyc2Bz_idle (u : ℤ) : stepB (cyc2Bz u) B5.idle = true := by
  unfold cyc2Bz; split_ifs <;> rfl

/-- **A CONCRETE LADDER PATH ON THE BRANCHING OBJECT**: a pending region ending at `t + c₀`, the
object walking the `2`-cycle, the register descending in lockstep with the countdown, idle after.
The region extends infinitely into the past because `idle` is a sink in `B5` — a pending state has
no idle predecessor — which is the ladder conditions' own doing and not a choice made here. -/
def gLad (c₀ : ℕ) (t : ℤ) (u : ℤ) : LadderState B5 pendB :=
  if u ≤ t + (c₀ : ℤ) then
    ⟨(cyc2Bz (u - t), ((c₀ : ℤ) + t - u).toNat, ((c₀ : ℤ) + t - u).toNat),
      fun hq => by simp [cyc2Bz_pend] at hq⟩
  else ⟨(B5.idle, 0, 0), fun _ => rfl⟩

/-- **NON-VACUITY ON `B5`**: `gLad` is a ladder path at every region length and every position. -/
theorem gLad_isLadderPath (c₀ : ℕ) (t : ℤ) : IsLadderPath stepB pendB (gLad c₀ t) := by
  intro u
  show Rlad stepB pendB u (gLad c₀ t u).1 (gLad c₀ t (u + 1)).1
  by_cases h1 : u + 1 ≤ t + (c₀ : ℤ)
  · have h0 : u ≤ t + (c₀ : ℤ) := by omega
    have e1 : (gLad c₀ t u).1 =
        (cyc2Bz (u - t), ((c₀ : ℤ) + t - u).toNat, ((c₀ : ℤ) + t - u).toNat) := by
      unfold gLad; rw [if_pos h0]
    have e2 : (gLad c₀ t (u + 1)).1 =
        (cyc2Bz (u + 1 - t), ((c₀ : ℤ) + t - (u + 1)).toNat,
          ((c₀ : ℤ) + t - (u + 1)).toNat) := by
      unfold gLad; rw [if_pos h1]
    rw [e1, e2]
    refine ⟨?_, fun hq => by simp [cyc2Bz_pend] at hq,
      Or.inr (Or.inr ?_), ?_⟩
    · show stepB (cyc2Bz (u - t)) (cyc2Bz (u + 1 - t)) = true
      rw [show u + 1 - t = (u - t) + 1 by ring]
      exact cyc2Bz_step _
    · show ((c₀ : ℤ) + t - (u + 1)).toNat + 1 = ((c₀ : ℤ) + t - u).toNat
      omega
    · show Count (pendB (cyc2Bz (u - t))) (pendB (cyc2Bz (u + 1 - t)))
        ((c₀ : ℤ) + t - u).toNat ((c₀ : ℤ) + t - u).toNat ((c₀ : ℤ) + t - (u + 1)).toNat
      rw [cyc2Bz_pend, cyc2Bz_pend]
      show ((c₀ : ℤ) + t - (u + 1)).toNat + 1 = ((c₀ : ℤ) + t - u).toNat
      omega
  · by_cases h0 : u ≤ t + (c₀ : ℤ)
    · have e1 : (gLad c₀ t u).1 = (cyc2Bz (u - t), 0, 0) := by
        unfold gLad
        rw [if_pos h0]
        show (cyc2Bz (u - t), ((c₀ : ℤ) + t - u).toNat, ((c₀ : ℤ) + t - u).toNat) =
          (cyc2Bz (u - t), 0, 0)
        rw [show ((c₀ : ℤ) + t - u).toNat = 0 by omega]
      have e2 : (gLad c₀ t (u + 1)).1 = (B5.idle, 0, 0) := by
        unfold gLad; rw [if_neg h1]
      rw [e1, e2]
      refine ⟨cyc2Bz_idle _, fun hq => by simp [cyc2Bz_pend] at hq,
        Or.inl rfl, ?_⟩
      show Count (pendB (cyc2Bz (u - t))) (pendB B5.idle) 0 0 0
      rw [cyc2Bz_pend]
      simp [Count, pendB]
    · have e1 : (gLad c₀ t u).1 = (B5.idle, 0, 0) := by unfold gLad; rw [if_neg h0]
      have e2 : (gLad c₀ t (u + 1)).1 = (B5.idle, 0, 0) := by unfold gLad; rw [if_neg h1]
      rw [e1, e2]
      exact ⟨rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendB]⟩

/-- The three coordinates of `gLad` inside its region. -/
theorem gLad_at (c₀ : ℕ) (t : ℤ) (j : ℕ) (hj : j ≤ c₀) :
    (gLad c₀ t (t + (j : ℤ))).1 = (cyc2Bz (j : ℤ), c₀ - j, c₀ - j) := by
  unfold gLad
  rw [if_pos (by omega)]
  show (cyc2Bz (t + (j : ℤ) - t), ((c₀ : ℤ) + t - (t + (j : ℤ))).toNat,
      ((c₀ : ℤ) + t - (t + (j : ℤ))).toNat) = (cyc2Bz (j : ℤ), c₀ - j, c₀ - j)
  rw [show t + (j : ℤ) - t = (j : ℤ) by ring,
    show ((c₀ : ℤ) + t - (t + (j : ℤ))).toNat = c₀ - j by omega]

/-- **THE `Mrel` PAIR ON THE BRANCHING OBJECT**, at the same arithmetic as `Mrel_xM_yM`: one
object state, countdowns `cM` and `cM + (P + 1)`, registers equal to the countdowns. -/
theorem Mrel_gLad (P a b : ℕ) (h3 : 3 ∣ P + 1) (t : ℤ) :
    Mrel P a (b + 1) (gLad (cM P a b) t t) (gLad (cM P a b + (P + 1)) t t) := by
  have h3' : 3 ≤ P + 1 := Nat.le_of_dvd (by omega) h3
  have hmul : 2 * (a + (b + 1)) ≤ (P + 1) * (a + (b + 1)) := by
    calc 2 * (a + (b + 1)) ≤ 3 * (a + (b + 1)) := by omega
      _ ≤ (P + 1) * (a + (b + 1)) := Nat.mul_le_mul_right _ h3'
  have e1 : (gLad (cM P a b) t t).1 = (cyc2Bz 0, cM P a b, cM P a b) := by
    have := gLad_at (cM P a b) t 0 (Nat.zero_le _)
    simpa using this
  have e2 : (gLad (cM P a b + (P + 1)) t t).1 =
      (cyc2Bz 0, cM P a b + (P + 1), cM P a b + (P + 1)) := by
    have := gLad_at (cM P a b + (P + 1)) t 0 (Nat.zero_le _)
    simpa using this
  have hc : cM P a b = (P + 1) * (a + (b + 1)) := rfl
  refine ⟨⟨⟨?_, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩, ?_⟩, Or.inr ⟨?_, ?_⟩⟩
  · rw [e1, e2]
  · rw [e1]; show 2 * (a + (b + 1)) ≤ cM P a b; omega
  · rw [e2]; show 2 * (a + (b + 1)) ≤ cM P a b + (P + 1); omega
  · rw [e1]; show 2 * (a + (b + 1)) ≤ cM P a b; omega
  · rw [e2]; show 2 * (a + (b + 1)) ≤ cM P a b + (P + 1); omega
  · rw [e1, e2]
    show ((cM P a b : ℕ) : ℤ) - ((cM P a b : ℕ) : ℤ) =
      ((cM P a b + (P + 1) : ℕ) : ℤ) - ((cM P a b + (P + 1) : ℕ) : ℤ)
    omega
  · rw [e1, e2]
    show ((cM P a b : ℕ) : ℤ) ≡ ((cM P a b + (P + 1) : ℕ) : ℤ) [ZMOD ((P : ℤ) + 1)]
    exact Int.modEq_iff_dvd.mpr ⟨1, by push_cast; ring⟩
  · rw [e1]; show (P + 1) * (a + (b + 1)) ≤ cM P a b; omega
  · rw [e2]; show (P + 1) * (a + (b + 1)) ≤ cM P a b + (P + 1); omega

/-- **THE MEASUREMENT ON `B5`.**  At the `Mrel` pair of `Mrel_gLad`, every position of the longer
region is answered by a position of the shorter one — the SAME exhibited map `ansM` — at which all
four `Zrel` clauses at the budget left hold.

Here the exhibited register is the longer path's OWN register, so on this fixture the exhibition
is realized by an actual ladder path (`gLad_isLadderPath`) rather than only pointwise: the register
descends in lockstep with the countdown, which is the `Drift` walk `C + (P + 1) - j`, and the gap is
`0` on both sides at every position.  `6 ∣ P + 1` carries the object coordinate: `2 ∣ P + 1` makes
the `2`-cycle agree across the shift of the modulus, which is exactly the walk
`region_end_matchable_B5` supplies when its extra `P + 1` positions are spent in that cycle.

**RULING 23.**  `B5` is used here as a SATISFIABILITY fixture, not as a refutation carrier: the
branching enlarges the answering path's option set, so nothing is refuted on it and nothing is
claimed to be.  The `3`-cycle branch `b0 → b2 → b3 → b0` is not exercised by this measurement; what
is measured is that the `2`-cycle route `region_end_matchable_B5` itself constructs carries every
`Zrel` clause, and the measurement says nothing about walks that take the other branch.

This is not a row link either, for the same reason as on `R4`. -/
theorem register_answerable_B5 (P a b : ℕ) (h6 : 6 ∣ P + 1) (t : ℤ) (j : ℕ)
    (hj : j ≤ cM P a b + (P + 1)) :
    Zrel a b (gLad (cM P a b + (P + 1)) t (t + (j : ℤ))) (gLad (cM P a b) t (ansM P t j)) := by
  obtain ⟨k, hk⟩ := h6
  have h3' : 6 ≤ P + 1 := by omega
  have hC : cM P a b = (P + 1) * (a + b) + (P + 1) := by unfold cM; ring
  have hCge : 6 * (a + b) ≤ (P + 1) * (a + b) := Nat.mul_le_mul_right _ h3'
  have eL : (gLad (cM P a b + (P + 1)) t (t + (j : ℤ))).1 =
      (cyc2Bz (j : ℤ), cM P a b + (P + 1) - j, cM P a b + (P + 1) - j) :=
    gLad_at _ t j hj
  by_cases hjP : j ≤ P
  · have hjC : j ≤ cM P a b := by omega
    have hans : ansM P t j = t + (j : ℤ) := by unfold ansM; rw [if_pos hjP]
    have eR : (gLad (cM P a b) t (ansM P t j)).1 =
        (cyc2Bz (j : ℤ), cM P a b - j, cM P a b - j) := by
      rw [hans]; exact gLad_at _ t j hjC
    refine ⟨?_, Or.inr ⟨?_, ?_⟩, Or.inr ⟨?_, ?_⟩, Or.inl ?_⟩
    · rw [eL, eR]
    · rw [eL]; show 2 * (a + b) ≤ cM P a b + (P + 1) - j; omega
    · rw [eR]; show 2 * (a + b) ≤ cM P a b - j; omega
    · rw [eL]; show 2 * (a + b) ≤ cM P a b + (P + 1) - j; omega
    · rw [eR]; show 2 * (a + b) ≤ cM P a b - j; omega
    · rw [eL, eR]
      show ((cM P a b + (P + 1) - j : ℕ) : ℤ) - ((cM P a b + (P + 1) - j : ℕ) : ℤ) =
        ((cM P a b - j : ℕ) : ℤ) - ((cM P a b - j : ℕ) : ℤ)
      omega
  · have hjP' : P + 1 ≤ j := by omega
    set i : ℕ := j - (P + 1) with hi
    have hiC : i ≤ cM P a b := by omega
    have hans : ansM P t j = t + (i : ℤ) := by unfold ansM; rw [if_neg hjP]
    have eR : (gLad (cM P a b) t (ansM P t j)).1 =
        (cyc2Bz (i : ℤ), cM P a b - i, cM P a b - i) := by
      rw [hans]; exact gLad_at _ t i hiC
    have hpar : cyc2Bz (j : ℤ) = cyc2Bz (i : ℤ) := by
      unfold cyc2Bz
      have : (j : ℤ) % 2 = (i : ℤ) % 2 := by omega
      rw [this]
    have hcnt : cM P a b + (P + 1) - j = cM P a b - i := by omega
    refine ⟨?_, Or.inl ?_, Or.inl ?_, Or.inl ?_⟩
    · rw [eL, eR]; exact hpar
    · rw [eL, eR]; exact hcnt
    · rw [eL, eR]; exact hcnt
    · rw [eL, eR]
      show ((cM P a b + (P + 1) - j : ℕ) : ℤ) - ((cM P a b + (P + 1) - j : ℕ) : ℤ) =
        ((cM P a b - i : ℕ) : ℤ) - ((cM P a b - i : ℕ) : ℤ)
      omega

end ProbeRowResidue

/-- info: 'ProbeRowResidue.nxt_ge_sub' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.nxt_ge_sub

/-- info: 'ProbeRowResidue.gap_mono_of_pend' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.gap_mono_of_pend

/-- info: 'ProbeRowResidue.stM_zero' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.stM_zero

/-- info: 'ProbeRowResidue.longer_region_forced' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.longer_region_forced

/-- info: 'ProbeRowResidue.register_answerable_R4' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.register_answerable_R4

/-- info: 'ProbeRowResidue.exists_path_through_xM' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.exists_path_through_xM

/-- info: 'ProbeRowResidue.gLad_isLadderPath' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.gLad_isLadderPath

/-- info: 'ProbeRowResidue.Mrel_gLad' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.Mrel_gLad

/-- info: 'ProbeRowResidue.register_answerable_B5' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms ProbeRowResidue.register_answerable_B5
