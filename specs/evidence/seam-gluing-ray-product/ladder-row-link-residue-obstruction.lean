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
