/-
# THE TIGHT DOUBLING CHAIN AND ITS DELETION-DERIVATIVES

The decision gate of the ladder realization record's depth-`0` core. The live library
(`FormalSystem/Metalogic/Decidability/RaySummary/README.md`) records ONE claim as ARGUED rather
than compiled: no finite deletion-derivative of the tight (doubling) chain lifts. This probe
compiles that claim, in the strongest form the object admits, and reports precisely what the
compiled claim does and does not settle.

## The object and the chain

The object is the two-state object of `ladder-cell-agreement-refutation.lean` and of the archived
regime-B prototype: `Fin 2`, state `0` pending, state `1` idle, `step` total, and a labelling that
carries the pending bit as an atom.

The chain is the tight DOUBLING chain, with its pins UNBOUNDED ABOVE: idle at every `v ≤ 0`, idle
exactly at the pins `2^j - 2` for `j ≥ 1`, pending everywhere else. Region `j` then spans the
pending positions `2^j - 1` through `2^(j+1) - 3`, of length `2^j - 1`, and the countdown at a
region start's successor is the pin's own position:

```
cT (2^j - 2 + 1) = 2^j - 2.
```

So the next-deadline register equals the POSITION at every pin, every gap between consecutive pins
has Lipschitz slack exactly `0`, and the chain is the sharpest object the counter-lift mathematics
has: there is no slack anywhere to absorb a surgery.

**Why the pin set is unbounded above, and not the archived prototype's finite `1 ≤ j ≤ J`.** On a
finite-`J` chain the LAST region is followed by the idle-forever tail, so it carries no pin above
it, and deleting a block from it moves no later pin: the register demand at the last pin drops by
the deleted amount while every earlier pin keeps its own, which the `1`-Lipschitz pin condition
admits. A finite-`J` chain therefore HAS a lifting deletion-derivative, and the claim the record
makes is false at that object. The claim is about the chain whose pins are unbounded above, and
that is the object declared here. The archived finite-`J` chain is unmodified and is not restated.

## What this probe compiles

`tightChain_positive_deletion_does_not_lift`: for every `a ≥ 4` and every `L > 0`, NO ladder path
whatsoever has the object walk of the chain with the block `[a, a + L)` deleted. Not "the deleted
walk with some chosen register is not a ladder path" — no ladder path has that object walk at all,
and the countdown and the register are existentially quantified away.

The mechanism is the chain's own tightness, read through two pins of the DELETED walk that lie on
opposite sides of the deletion:

* the pin at `0`, whose region is the single position `1` and lies entirely below the deletion, so
  the deleted walk still carries it with countdown `0`;
* a pin `2^j - 2 - L` with `2^j - 2` far above `a + L`, whose region lies entirely above the
  deletion, so the deleted walk carries it with the chain's own countdown `2^j - 2`.

The distance between the two pins has fallen by exactly `L` while the countdown difference has not
moved at all, and `pinCompat_of_ladderPath` (`LadderAgree.lean`) proves pairwise compatibility of
region-start countdowns NECESSARY for any ladder path whatsoever. So the deleted walk's pins are
incompatible by exactly `L`, and the deletion-derivative does not lift.

Nothing in the argument looks at the register, at a type, at a parameter condition, or at a
certificate object: it is the carrier's own arithmetic.

## What this probe does NOT compile, and the verdict

The gate's own decision asks for more than this: it asks whether the depth-`0` cell-level schema
`CellLEZeroConstOfKappaEq` is REFUTED under `ParamsOk`. That step is not taken here and is not
claimed. Going from "no deletion-derivative of the chain lifts" to "the cells at two
`kappa`-colliding ladder states differ" needs the realized-type layer over the chain — a closure
formula separating the two cells, and the argument that a cell equality would FORCE a lifting
deletion-derivative. Neither is compiled here, so the gate's verdict is INCONCLUSIVE and the
reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing.

Two statement-level findings about the gate's own recorded statements are reported with the
verdict rather than worked around:

1. The recorded `tightChain_deletion_derivative_not_ladderPath` quantifies `(m l : Nat)` with
   `0 < l` and no constraint on `m`. At `m = 0` the deletion-derivative deletes nothing and IS the
   chain, which is a ladder path, so the recorded statement is false as written; it needs `0 < m`.
   The theorem below therefore carries an honest name of its own and the recorded statement is
   left exactly as recorded, to be repaired by a revision rather than re-signed here.
2. The recorded statement concludes `¬ IsLadderPath step pend (delIterWalk …)`, which constrains
   the deleted walk's own register and so is weaker than the record's claim that the derivative
   does not LIFT. The theorem below states the lifting form, with the countdown and the register
   both existentially quantified, which is the claim the record makes.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

set_option autoImplicit false

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761T

/-! ### The object -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) (by simp)

/-! ### The tight doubling chain, with its pins unbounded above -/

open Classical

theorem two_pow_mono {m n : ℕ} (h : m ≤ n) : (2 : ℤ) ^ m ≤ (2 : ℤ) ^ n :=
  pow_le_pow_right₀ (by norm_num) h

theorem two_pow_lt_iff {m n : ℕ} : (2 : ℤ) ^ m < (2 : ℤ) ^ n ↔ m < n :=
  pow_lt_pow_iff_right₀ (by norm_num)

theorem two_le_two_pow {j : ℕ} (hj : 1 ≤ j) : (2 : ℤ) ≤ (2 : ℤ) ^ j := by
  calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
    _ ≤ (2 : ℤ) ^ j := two_pow_mono hj

/-- The idle positions of the chain: everything at or before `0`, and the pins `2^j - 2` for
every `j ≥ 1`. The pin set is UNBOUNDED ABOVE; there is no idle-forever tail. -/
def idleT (v : ℤ) : Prop :=
  v ≤ 0 ∨ ∃ j : ℕ, 1 ≤ j ∧ v = (2 : ℤ) ^ j - 2

noncomputable def wT (v : ℤ) : Qc := if idleT v then 1 else 0

theorem pendC_wT_iff (v : ℤ) : pendC (wT v) = false ↔ idleT v := by
  unfold wT
  split_ifs with h <;> simp [pendC, h]

theorem pendC_wT_true_iff (v : ℤ) : pendC (wT v) = true ↔ ¬ idleT v := by
  rw [← Bool.not_eq_false, pendC_wT_iff]

/-- Some power of two overshoots any integer. -/
theorem exists_pow_gt (v : ℤ) : ∃ j : ℕ, 1 ≤ j ∧ v < (2 : ℤ) ^ j - 2 := by
  refine ⟨(v + 3).toNat + 1, by omega, ?_⟩
  have h : ((v + 3).toNat : ℤ) < (2 : ℤ) ^ ((v + 3).toNat) := by
    exact_mod_cast Nat.lt_two_pow_self (n := (v + 3).toNat)
  have h2 : (2 : ℤ) ^ ((v + 3).toNat) ≤ (2 : ℤ) ^ ((v + 3).toNat + 1) :=
    two_pow_mono (by omega)
  have h3 : (2 : ℤ) ^ ((v + 3).toNat + 1) = 2 * (2 : ℤ) ^ ((v + 3).toNat) := by
    rw [pow_succ]; ring
  omega

/-- There is an idle position after every position. -/
theorem exists_idle_after (v : ℤ) : ∃ k : ℕ, idleT (v + (k : ℤ) + 1) := by
  obtain ⟨j, hj1, hj⟩ := exists_pow_gt v
  refine ⟨((2 : ℤ) ^ j - 2 - v - 1).toNat, Or.inr ⟨j, hj1, ?_⟩⟩
  omega

/-- The countdown of the chain: `0` at an idle position, the distance to the next idle position
minus one at a pending one. -/
noncomputable def cT (v : ℤ) : ℕ :=
  if idleT v then 0 else Nat.find (exists_idle_after v)

theorem cT_of_idle (v : ℤ) (h : idleT v) : cT v = 0 := by
  unfold cT; rw [if_pos h]

theorem cT_of_pend (v : ℤ) (h : ¬ idleT v) : cT v = Nat.find (exists_idle_after v) := by
  unfold cT; rw [if_neg h]

/-- A pin — an idle position followed by a pending one — is one of the `2^j - 2`. -/
theorem pin_eq (v : ℤ) (h0 : idleT v) (h1 : ¬ idleT (v + 1)) :
    ∃ j : ℕ, 1 ≤ j ∧ v = (2 : ℤ) ^ j - 2 := by
  rcases h0 with h | h
  · have hv : v = 0 := by
      by_contra hne
      exact h1 (Or.inl (by omega))
    exact ⟨1, le_rfl, by omega⟩
  · exact h

/-- No idle position lies strictly between two consecutive pins. -/
theorem no_idle_between (j : ℕ) (hj1 : 1 ≤ j) (v : ℤ)
    (hlo : (2 : ℤ) ^ j - 2 < v) (hhi : v < (2 : ℤ) ^ (j + 1) - 2) : ¬ idleT v := by
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
  rintro (h | ⟨i, hi1, rfl⟩)
  · omega
  · have hlt1 : (2 : ℤ) ^ j < (2 : ℤ) ^ i := by omega
    have hlt2 : (2 : ℤ) ^ i < (2 : ℤ) ^ (j + 1) := by omega
    have := two_pow_lt_iff.mp hlt1
    have := two_pow_lt_iff.mp hlt2
    omega

/-- The position `2^(j+1) - 2` after a pin is idle. -/
theorem idle_next_pin (j : ℕ) (hj1 : 1 ≤ j) : idleT ((2 : ℤ) ^ (j + 1) - 2) :=
  Or.inr ⟨j + 1, by omega, rfl⟩

/-- **THE COUNTDOWN AT A REGION START IS THE PIN'S OWN POSITION.** -/
theorem cT_pin_succ (j : ℕ) (hj1 : 1 ≤ j) :
    cT ((2 : ℤ) ^ j - 2 + 1) = ((2 : ℤ) ^ j - 2).toNat := by
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
  have hpend : ¬ idleT ((2 : ℤ) ^ j - 2 + 1) :=
    no_idle_between j hj1 _ (by omega) (by rw [pow_succ]; omega)
  rw [cT_of_pend _ hpend, Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have hcast : (2 : ℤ) ^ j - 2 + 1 + ((((2 : ℤ) ^ j - 2).toNat : ℕ) : ℤ) + 1
        = (2 : ℤ) ^ (j + 1) - 2 := by
      rw [pow_succ]; omega
    rw [hcast]
    exact idle_next_pin j hj1
  · intro n hn
    apply no_idle_between j hj1
    · omega
    · rw [pow_succ]; omega

/-- Inside a region the countdown counts down. -/
theorem cT_pend_pend (v : ℤ) (h0 : ¬ idleT v) (h1 : ¬ idleT (v + 1)) :
    cT (v + 1) + 1 = cT v := by
  rw [cT_of_pend v h0, cT_of_pend (v + 1) h1]
  symm
  rw [Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have hspec := Nat.find_spec (exists_idle_after (v + 1))
    rw [show v + ((Nat.find (exists_idle_after (v + 1)) + 1 : ℕ) : ℤ) + 1
        = v + 1 + ((Nat.find (exists_idle_after (v + 1)) : ℕ) : ℤ) + 1 by push_cast; ring]
    exact hspec
  · intro n hn
    cases n with
    | zero => simpa using h1
    | succ m =>
        have hm : m < Nat.find (exists_idle_after (v + 1)) := by omega
        have hmin := Nat.find_min (exists_idle_after (v + 1)) hm
        rwa [show v + ((m + 1 : ℕ) : ℤ) + 1 = v + 1 + (m : ℤ) + 1 by push_cast; ring]

/-- At a region's last pending position the countdown is `0`. -/
theorem cT_pend_idle (v : ℤ) (h0 : ¬ idleT v) (h1 : idleT (v + 1)) : cT v = 0 := by
  rw [cT_of_pend v h0, Nat.find_eq_zero]
  simpa using h1

/-- **THE TIGHT DOUBLING CHAIN IS A LADDER PATH**, through the landed lift of a walk with its
forced countdown, with the register's base value `0`. -/
theorem tightChain_exists :
    ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
      (∀ v, objAt g v = wT v) ∧ (∀ v, cntAt g v = cT v) := by
  have hpin : ∀ s : ℤ, pendC (wT s) = false → pendC (wT (s + 1)) = true →
      (cT (s + 1) : ℤ) = s := by
    intro s h0 h1
    rw [pendC_wT_iff] at h0
    rw [pendC_wT_true_iff] at h1
    obtain ⟨j, hj1, rfl⟩ := pin_eq s h0 h1
    rw [cT_pin_succ j hj1]
    have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
    omega
  refine exists_ladderPath_of_walk wT cT 0 (fun _ => rfl) ?_ ?_ ?_ ?_ ?_
  · intro v h
    exact cT_of_idle v ((pendC_wT_iff v).mp h)
  · intro v h0 h1
    exact cT_pend_pend v ((pendC_wT_true_iff v).mp h0) ((pendC_wT_true_iff (v + 1)).mp h1)
  · intro v h0 h1
    exact cT_pend_idle v ((pendC_wT_true_iff v).mp h0) ((pendC_wT_iff (v + 1)).mp h1)
  · intro s v hs0 hs1 hv0 hv1
    rw [hpin s hs0 hs1, hpin v hv0 hv1]
  · intro v h0 h1
    rw [hpin v h0 h1]
    simp

/-- The chain itself, as a function. -/
noncomputable def tightChain : ℤ → LadderState Qc pendC := tightChain_exists.choose

theorem tightChain_isLadderPath : IsLadderPath stepC pendC tightChain :=
  tightChain_exists.choose_spec.1

theorem tightChain_objAt (v : ℤ) : objAt tightChain v = wT v :=
  tightChain_exists.choose_spec.2.1 v

theorem tightChain_cntAt (v : ℤ) : cntAt tightChain v = cT v :=
  tightChain_exists.choose_spec.2.2 v


/-! ### The deletion-derivative, and the claim

A deletion-derivative of the chain removes a block of positions and closes the gap. `m` blocks of
length `l` removed at the chain's own spacing just above a position `z` compose to the single
removal of `m * l` positions at `z + 1`, which is the form stated below: the iteration is the
composition, and nothing is gained by unfolding it.

Note what is NOT carried: the deleted walk's countdown and register are not defined here at all.
They are existentially quantified away by the statements, which ask whether ANY ladder path has
the deleted OBJECT walk. That is the record's own claim — the derivative does not LIFT — and it
is strictly stronger than the failure of one chosen register. -/

/-- The chain's object walk with the block `[a, a + L)` deleted and the gap closed. -/
noncomputable def delObj (a : ℤ) (L : ℕ) : ℤ → Qc :=
  fun v => if v < a then wT v else wT (v + (L : ℤ))

theorem delObj_of_lt (a : ℤ) (L : ℕ) (v : ℤ) (h : v < a) : delObj a L v = wT v := by
  unfold delObj; rw [if_pos h]

theorem delObj_of_ge (a : ℤ) (L : ℕ) (v : ℤ) (h : a ≤ v) :
    delObj a L v = wT (v + (L : ℤ)) := by
  unfold delObj; rw [if_neg (by omega)]

/-- The iterated deletion-derivative's object walk: `m` blocks of length `l` deleted at the
chain's own spacing just above `z`, which composes to the single deletion of `m * l` positions
at `z + 1`. -/
noncomputable def delIterObj (z : ℤ) (m l : ℕ) : ℤ → Qc := delObj (z + 1) (m * l)

/-- Position `1` is pending: it is the whole of the chain's first region. -/
theorem not_idleT_one : ¬ idleT 1 := by
  refine no_idle_between 1 le_rfl 1 (by norm_num) ?_
  norm_num

theorem idleT_two : idleT 2 := Or.inr ⟨2, by omega, by norm_num⟩

/-- **THE CLAIM: NO POSITIVE DELETION-DERIVATIVE OF THE TIGHT CHAIN LIFTS.** For every deletion
point `a ≥ 4` and every positive deletion length `L`, no ladder path whatsoever has the deleted
object walk — the countdown and the register are both quantified away.

The mechanism is the chain's tightness, read at two pins of the DELETED walk on opposite sides of
the deletion: the pin at `0`, whose region is the single position `1` and lies entirely below the
deletion, so it survives with countdown `0`; and a pin `2^j - 2 - L` whose region lies entirely
above the deletion, so it survives with the chain's own countdown `2^j - 2`. The distance between
the two has fallen by exactly `L` while their countdown difference has not moved, and
`pinCompat_of_ladderPath` proves pairwise compatibility of region-start countdowns NECESSARY for
any ladder path. -/
theorem tightChain_positive_deletion_does_not_lift (a : ℤ) (ha : 4 ≤ a) (L : ℕ) (hL : 0 < L) :
    ¬ ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        (∀ v, objAt g v = delObj a L v) := by
  rintro ⟨g, hg, hobj⟩
  -- the low pin: `0` is idle, `1` is pending, `2` is idle, all below the deletion
  have h00 : pendC (objAt g 0) = false := by
    rw [hobj 0, delObj_of_lt a L 0 (by omega), pendC_wT_iff]
    exact Or.inl le_rfl
  have h01 : pendC (objAt g 1) = true := by
    rw [hobj 1, delObj_of_lt a L 1 (by omega), pendC_wT_true_iff]
    exact not_idleT_one
  have h02 : pendC (objAt g 2) = false := by
    rw [hobj 2, delObj_of_lt a L 2 (by omega), pendC_wT_iff]
    exact idleT_two
  have hlow : cntAt g 1 = 0 :=
    (cntAt_eq_zero_of_pend_idle g hg 1 h01 (by simpa using h02)).1
  -- the high pin: a power of two far above the deletion
  obtain ⟨j, hj1, hj⟩ := exists_pow_gt (a + (L : ℤ) + 1)
  set p : ℤ := (2 : ℤ) ^ j - 2 with hp
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
  have hsucc : (2 : ℤ) ^ (j + 1) = 2 * (2 : ℤ) ^ j := by rw [pow_succ]; ring
  set s : ℤ := p - (L : ℤ) with hs
  have hsa : a ≤ s := by omega
  -- the high pin is idle, its successor pending
  have hs0 : pendC (objAt g s) = false := by
    rw [hobj s, delObj_of_ge a L s hsa, pendC_wT_iff,
      show s + (L : ℤ) = p by omega]
    exact Or.inr ⟨j, hj1, hp⟩
  have hs1 : pendC (objAt g (s + 1)) = true := by
    rw [hobj (s + 1), delObj_of_ge a L (s + 1) (by omega), pendC_wT_true_iff,
      show s + 1 + (L : ℤ) = p + 1 by omega]
    exact no_idle_between j hj1 (p + 1) (by omega) (by omega)
  -- the pending run above the high pin is the chain's own region, of length `p + 1`
  have hrun : ∀ i : ℕ, (i : ℤ) ≤ p → pendC (objAt g (s + 1 + (i : ℤ))) = true := by
    intro i hi
    rw [hobj _, delObj_of_ge a L _ (by omega), pendC_wT_true_iff,
      show s + 1 + (i : ℤ) + (L : ℤ) = p + 1 + (i : ℤ) by omega]
    exact no_idle_between j hj1 _ (by omega) (by omega)
  have hend : pendC (objAt g (s + 1 + (p + 1))) = false := by
    rw [hobj _, delObj_of_ge a L _ (by omega), pendC_wT_iff,
      show s + 1 + (p + 1) + (L : ℤ) = (2 : ℤ) ^ (j + 1) - 2 by omega]
    exact idle_next_pin j hj1
  -- so the countdown at the high pin's successor is `p`
  have hhigh : (cntAt g (s + 1) : ℤ) = p := by
    rcases lt_trichotomy ((cntAt g (s + 1) : ℤ)) p with hlt | heq | hgt
    · exfalso
      have hnp := not_pend_of_count g hg (s + 1) hs1
      have hcast : s + 1 + ((cntAt g (s + 1) : ℕ) : ℤ) + 1
          = s + 1 + (((cntAt g (s + 1) + 1 : ℕ)) : ℤ) := by push_cast; ring
      rw [hcast] at hnp
      have := hrun (cntAt g (s + 1) + 1) (by push_cast; omega)
      exact Bool.false_ne_true (hnp.symm.trans this)
    · exact heq
    · exfalso
      have hple : (p + 1).toNat ≤ cntAt g (s + 1) := by omega
      have hmem := (cntAt_sub_of_pend g hg (s + 1) hs1 (p + 1).toNat hple).1
      rw [show s + 1 + (((p + 1).toNat : ℕ) : ℤ) = s + 1 + (p + 1) by omega] at hmem
      exact Bool.false_ne_true (hend.symm.trans hmem)
  -- and the two pins are incompatible by exactly `L`
  have hpc := pinCompat_of_ladderPath g hg 0 s h00 h01 hs0 hs1
  rw [show (0 : ℤ) + 1 = 1 by ring, hlow] at hpc
  omega

/-- The same claim at the iterated shape. -/
theorem tightChain_iter_deletion_does_not_lift (z : ℤ) (hz : 3 ≤ z) (m l : ℕ)
    (hm : 0 < m) (hl : 0 < l) :
    ¬ ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        (∀ v, objAt g v = delIterObj z m l v) := by
  unfold delIterObj
  exact tightChain_positive_deletion_does_not_lift (z + 1) (by omega) (m * l)
    (Nat.mul_pos hm hl)


/-! ### The claim at the gate's own hypothesis, and the parameter conditions

The gate's recorded statement places `z` by `Tcof step pend lab chi ≤ cntAt tightChain z` rather
than by an inequality on `z` itself. That hypothesis DOES place `z` where the claim needs it, and
the derivation is recorded here rather than left to a reader: `Tcof` is at least `2` because its
third source `2 * T_short + T_idle + 2` is, and the chain's countdown is `0` at every position
at or below `2` — the positions `v ≤ 0` and the pin `2` are idle, and the position `1` is the
whole of the chain's first region, so its countdown is `0` as well. -/

def pC : Atom := ⟨"p", none⟩

def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

/-- The separating closure formula: stab-free, and `box`-free. -/
def chiT : PlusFormula := PlusFormula.atom pC

theorem stabFree_chiT : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiT := by
  intro χ hχ
  simp [chiT, plusSubformulaClosure, PlusFormula.subformulas] at hχ

/-- **`T_c` is at least `2` at every object and every formula**: its third source is. -/
theorem two_le_Tcof : 2 ≤ Tcof stepC pendC labC chiT := by
  unfold Tcof
  omega

/-- The chain's countdown is `0` at every position at or below `2`. -/
theorem three_le_of_two_le_cT (z : ℤ) (h : 2 ≤ cT z) : 3 ≤ z := by
  by_contra hc
  rcases lt_trichotomy z 1 with h1 | h1 | h1
  · rw [cT_of_idle z (Or.inl (by omega))] at h; omega
  · subst h1
    rw [show (1 : ℤ) = (2 : ℤ) ^ 1 - 2 + 1 by norm_num, cT_pin_succ 1 le_rfl] at h
    norm_num at h
  · have hz2 : z = 2 := by omega
    subst hz2
    rw [cT_of_idle 2 idleT_two] at h
    omega

/-- **THE CLAIM AT THE GATE'S OWN HYPOTHESIS.** No iterated deletion-derivative of the tight
chain lifts, for `z` placed as the gate places it and for any positive block count and block
length. The register and the countdown of the deleted walk are quantified away. -/
theorem tightChain_deletion_derivative_does_not_lift (m l : ℕ) (hm : 0 < m) (hl : 0 < l)
    (z : ℤ) (hz : Tcof stepC pendC labC chiT ≤ cntAt tightChain z) :
    ¬ ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        (∀ v, objAt g v = delIterObj z m l v) := by
  refine tightChain_iter_deletion_does_not_lift z ?_ m l hm hl
  refine three_le_of_two_le_cT z ?_
  rw [← tightChain_cntAt z]
  have := two_le_Tcof
  omega

/-- **The parameter conditions hold at the fixpoint's own outputs for this object and formula**,
so nothing above is vacuous for want of a dischargeable `ParamsOk`. -/
theorem paramsOk_chain :
    ParamsOk stepC pendC labC chiT (Tcof stepC pendC labC chiT) (Tnof stepC pendC labC chiT)
      (Pof stepC pendC labC chiT) (Bof stepC pendC labC chiT) :=
  paramsOk_params stepC pendC labC chiT

/-- The chain is not the degenerate all-idle walk: it carries a pin at every `2^j - 2`. -/
theorem tightChain_pins (j : ℕ) (hj : 1 ≤ j) :
    pendC (objAt tightChain ((2 : ℤ) ^ j - 2)) = false ∧
      pendC (objAt tightChain ((2 : ℤ) ^ j - 2 + 1)) = true := by
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj
  refine ⟨?_, ?_⟩
  · rw [tightChain_objAt, pendC_wT_iff]
    exact Or.inr ⟨j, hj, rfl⟩
  · rw [tightChain_objAt, pendC_wT_true_iff]
    exact no_idle_between j hj _ (by omega) (by rw [pow_succ]; omega)

/-- **EVERY GAP BETWEEN PINS OF THE CHAIN HAS LIPSCHITZ SLACK `0`**: the register equals the
position at every pin, so the register climbs by exactly the distance between any two pins and
there is no slack anywhere to absorb a surgery. -/
theorem tightChain_slack_zero (s s' : ℤ)
    (hs0 : pendC (objAt tightChain s) = false) (hs1 : pendC (objAt tightChain (s + 1)) = true)
    (hs0' : pendC (objAt tightChain s') = false)
    (hs1' : pendC (objAt tightChain (s' + 1)) = true) :
    (nxtAt tightChain s : ℤ) = s ∧ (nxtAt tightChain s' : ℤ) = s' := by
  have key : ∀ u : ℤ, pendC (objAt tightChain u) = false →
      pendC (objAt tightChain (u + 1)) = true → (nxtAt tightChain u : ℤ) = u := by
    intro u h0 h1
    rw [← cntAt_eq_nxtAt_of_idle_pend tightChain tightChain_isLadderPath u h0 h1,
      tightChain_cntAt]
    rw [tightChain_objAt, pendC_wT_iff] at h0
    rw [tightChain_objAt, pendC_wT_true_iff] at h1
    obtain ⟨j, hj1, rfl⟩ := pin_eq u h0 h1
    rw [cT_pin_succ j hj1]
    have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
    omega
  exact ⟨key s hs0 hs1, key s' hs0' hs1'⟩

end Probe761T
