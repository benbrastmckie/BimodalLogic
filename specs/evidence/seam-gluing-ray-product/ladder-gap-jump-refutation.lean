/-
# THE ROW-LINK PATH FORTH, REFUTED THROUGH THE GAP COORDINATE

The row-link route to the ladder's cell agreement rests on ONE existence claim — that two
`Mrel`-related states always admit a row-linked pair of ladder paths — and this probe refutes that
claim at its own recorded signature.

## What the route names

`LnkRow a b g g' t t'` is the row-link relation between two ladder paths at a row budget `(a, b)`;
`Mrel P a b x y` is the state relation the route arrived at after `Zrel` and `Srel` were each
refuted in turn.  The path forth is the statement that `Mrel`-relatedness is enough: given a
ladder path `h` through `x` and a state `y` with `Mrel P a b (h t) y`, there is a ladder path `h'`
through `y` with `LnkRow a b h h' t t`.  The signature refuted here carries BOTH hypotheses the
route accumulated — the object half of `(K1)` (`∀ l ∈ objCycleLens step pend, l ∣ (P + 1)`) and
the forward/backward totality of `RladAdm` — and is reproduced verbatim from the record rather
than paraphrased.

## What this probe compiles

* `region_exit_zrel` — a row link with one forward jump at a pending position relates the two
  region EXITS, the first idle positions.  This is the route's own step, landed, not disputed.
* `region_exit_register` — the NECESSARY CONDITION that step forces, and it is
  OBJECT-INDEPENDENT: at the region exit one of the two registers must be at least `2 * a`.
  Nothing about the object can weaken it, which is why no object-side hypothesis repairs the
  claim.
* `no_rowLinked_path_gap` — on the two-state `ramp` fixture, a pair of `Mrel`-related states at
  EVERY modulus admits no row-linked pair of ladder paths.  The failing coordinate is the
  REGISTER, read through the gap: the ramp's register falls at every step, so the region exit
  cannot meet the necessary condition above.
* `exists_rowLinked_path_K1_refuted` — the headline.  The path forth at the two-hypothesis
  signature is FALSE, with the object half of `(K1)` discharged on the fixture by `hK1G` at every
  even modulus and both totality hypotheses discharged by `fwdG`/`bwdG`.
* `no_rowLinked_path_gap_any_room` — the same refutation with every magnitude hypothesis a repair
  could add: the countdowns are EQUAL and of ARBITRARY SIZE `N`, so no countdown-side hypothesis,
  threshold or room condition helps.

## What this probe does NOT settle

It refutes the path forth over `Mrel` at this signature and nothing else.  It is NOT a refutation
of `Mrel` as a relation — `Mrel` survived both attacks owed against it, and its five structural
lemmas in `LadderStepFrag.lean` stand — nor of `LnkRow`, nor of `LnkRow.of_closed`, which is
relation-agnostic and remains the round's durable asset.  It says nothing about the `untl`/`snce`
jump clauses at the `⊡`-carrying level, nothing about the construction direction, and nothing
about whether SOME other state relation admits a path forth; it closes this one.  Every quantity
named is a COUNT: no bound of any kind is asserted, and the equal-countdown family of
`no_rowLinked_path_gap_any_room` is exhibited at arbitrary size precisely so that no magnitude is
being claimed.

The fixture is PENDING AT EVERY PAST POSITION on the `ramp` side, the forward-only liveness regime
the wired probe `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` already
compiles for this frame scheme; it is used here because it isolates the register as the sole
obstruction.

## Verification

`#print axioms` on every headline theorem.  No `sorry`, no axiom, no `native_decide`, no
placeholder body and no vacuous definition anywhere in this file.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-gap-jump-refutation.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

namespace ProbeGapJump

/-- A row link with one forward jump relates the two region EXITS (first idle positions). -/
theorem region_exit_zrel {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool} {a b : ℕ}
    {g g' : ℤ → LadderState Q pend} {t t' : ℤ} (hg : IsLadderPath step pend g)
    (hg' : IsLadderPath step pend g') (h : LnkRow a (b + 1) g g' t t')
    (hp : pend (objAt g t) = true) :
    Zrel a b (g (t + (cntAt g t : ℤ) + 1)) (g' (t' + (cntAt g' t' : ℤ) + 1)) := by
  have hz := h.zero
  have hp' : pend (objAt g' t') = true := by
    have e : objAt g' t' = objAt g t := hz.1.symm
    rw [e]; exact hp
  rw [LnkRow] at h
  obtain ⟨h1, -⟩ := h.2.1 b rfl
  obtain ⟨s', hs', hR, hbt⟩ := h1 (t + (cntAt g t : ℤ) + 1) (by omega)
  have hidle := not_pend_of_count g hg t hp
  have hidle' := not_pend_of_count g' hg' t' hp'
  have hobj : objAt g' s' = objAt g (t + (cntAt g t : ℤ) + 1) := hR.zero.1.symm
  have hsub := cntAt_sub_of_pend g hg t hp
  have hsub' := cntAt_sub_of_pend g' hg' t' hp'
  have hs'eq : s' = t' + (cntAt g' t' : ℤ) + 1 := by
    rcases lt_trichotomy s' (t' + (cntAt g' t' : ℤ) + 1) with hlt | heq | hgt
    · have := (hsub' (s' - t').toNat (by omega)).1
      rw [show t' + (((s' - t').toNat : ℕ) : ℤ) = s' by omega, hobj, hidle] at this
      exact absurd this (by simp)
    · exact heq
    · obtain ⟨r, hr1, hr2, hRr⟩ := hbt _ (by omega) hgt
      have hq : objAt g' (t' + (cntAt g' t' : ℤ) + 1) = objAt g r := hRr.zero.1.symm
      have := (hsub (r - t).toNat (by omega)).1
      rw [show t + (((r - t).toNat : ℕ) : ℤ) = r by omega, ← hq, hidle'] at this
      exact absurd this (by simp)
  rw [← hs'eq]; exact hR.zero

/-- **NECESSARY CONDITION (object-independent).** A row link with one forward jump at a pending
position forces the registers at the two region exits to be equal or both `≥ 2 a`. -/
theorem region_exit_register {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool} {a b : ℕ}
    {g g' : ℤ → LadderState Q pend} {t t' : ℤ} (hg : IsLadderPath step pend g)
    (hg' : IsLadderPath step pend g') (h : LnkRow a (b + 1) g g' t t')
    (hp : pend (objAt g t) = true) :
    nxtAt g (t + (cntAt g t : ℤ) + 1) = nxtAt g' (t' + (cntAt g' t' : ℤ) + 1) ∨
      (2 * a ≤ nxtAt g (t + (cntAt g t : ℤ) + 1) ∧
        2 * a ≤ nxtAt g' (t' + (cntAt g' t' : ℤ) + 1)) := by
  have hz := h.zero
  have hp' : pend (objAt g' t') = true := by
    have e : objAt g' t' = objAt g t := hz.1.symm
    rw [e]; exact hp
  obtain ⟨-, -, -, h4⟩ := region_exit_zrel hg hg' h hp
  have c0 : (g (t + (cntAt g t : ℤ) + 1)).1.2.1 = 0 :=
    cntAt_eq_zero_of_idle g hg _ (not_pend_of_count g hg t hp)
  have c0' : (g' (t' + (cntAt g' t' : ℤ) + 1)).1.2.1 = 0 :=
    cntAt_eq_zero_of_idle g' hg' _ (not_pend_of_count g' hg' t' hp')
  show (g (t + (cntAt g t : ℤ) + 1)).1.2.2 = (g' (t' + (cntAt g' t' : ℤ) + 1)).1.2.2 ∨
    (2 * a ≤ (g (t + (cntAt g t : ℤ) + 1)).1.2.2 ∧
      2 * a ≤ (g' (t' + (cntAt g' t' : ℤ) + 1)).1.2.2)
  omega

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

/-! ### The fixture: the two-state object, everything steps to everything -/

def stp : Bool → Bool → Bool := fun _ _ => true
def pnd : Bool → Bool := id

theorem fwdG : ∀ (t : ℤ) (x : LadderState Bool pnd), ∃ y, RladAdm stp pnd t x y := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  cases q with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pnd]⟩
  | true =>
    cases c with
    | zero =>
      exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun h => absurd h (by simp [pnd]), Or.inl rfl,
        by simp [Count, pnd]⟩
    | succ k =>
      exact ⟨⟨(true, k, n), fun h => absurd h (by simp [pnd])⟩, rfl,
        fun h => absurd h (by simp [pnd]), Or.inl rfl, by simp [Count, pnd]⟩

theorem bwdG : ∀ (t : ℤ) (x : LadderState Bool pnd), ∃ y, RladAdm stp pnd (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  cases q with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pnd]⟩
  | true =>
    exact ⟨⟨(true, c + 1, n), fun h => absurd h (by simp [pnd])⟩, rfl,
      fun h => absurd h (by simp [pnd]), Or.inl rfl, by simp [Count, pnd]⟩

/-- The object half of `(K1)` holds on the fixture at every even modulus. -/
theorem hK1G (P : ℕ) (h2 : 2 ∣ P + 1) : ∀ l ∈ objCycleLens stp pnd, l ∣ (P + 1) := by
  rintro l ⟨h0, hle, -⟩
  have hcard : Fintype.card Bool = 2 := Fintype.card_bool
  rw [hcard] at hle
  have : l = 1 ∨ l = 2 := by omega
  rcases this with rfl | rfl
  · exact one_dvd _
  · exact h2

/-- The first path: pending forever in the past, the register falling at every step; the region
ends at position `c`, and the idle state after it carries the register `2 a - 1`. -/
def ramp (c a : ℕ) : ℤ → LadderState Bool pnd := fun u =>
  if u ≤ (c : ℤ) then
    ⟨(true, ((c : ℤ) - u).toNat, ((c : ℤ) + 2 * a - u).toNat), fun h => absurd h (by simp [pnd])⟩
  else ⟨(false, 0, 2 * a - 1), fun _ => rfl⟩

theorem ramp_isPath (c a : ℕ) (ha : 1 ≤ a) : IsLadderPath stp pnd (ramp c a) := by
  intro u
  show Rlad stp pnd u (ramp c a u).1 (ramp c a (u + 1)).1
  by_cases h1 : u + 1 ≤ (c : ℤ)
  · have h0 : u ≤ (c : ℤ) := by omega
    simp only [ramp, if_pos h0, if_pos h1]
    refine ⟨rfl, fun h => absurd h (by simp [pnd]), Or.inr (Or.inr ?_), ?_⟩
    · show ((c : ℤ) + 2 * a - (u + 1)).toNat + 1 = ((c : ℤ) + 2 * a - u).toNat
      omega
    · show Count (pnd true) (pnd true) _ _ _
      simp only [Count, pnd, id, if_true]
      omega
  · by_cases h0 : u ≤ (c : ℤ)
    · have hu : u = c := by omega
      subst hu
      simp only [ramp, if_pos h0, if_neg h1]
      refine ⟨rfl, fun h => absurd h (by simp [pnd]), Or.inr (Or.inr ?_), ?_⟩
      · show 2 * a - 1 + 1 = ((c : ℤ) + 2 * a - c).toNat
        omega
      · show Count (pnd true) (pnd false) _ _ _
        simp [Count, pnd]
    · simp only [ramp, if_neg h0, if_neg h1]
      exact ⟨rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pnd]⟩

/-- The second state: same object state, SAME countdown, register one higher. -/
def yG (c a : ℕ) : LadderState Bool pnd :=
  ⟨(true, c, c + 2 * a + 1), fun h => absurd h (by simp [pnd])⟩

theorem ramp_zero (c a : ℕ) :
    ramp c a 0 = ⟨(true, c, c + 2 * a), fun h => absurd h (by simp [pnd])⟩ := by
  have h0 : (0 : ℤ) ≤ (c : ℤ) := by omega
  simp only [ramp, if_pos h0]
  apply Subtype.ext
  show ((true, ((c : ℤ) - 0).toNat, ((c : ℤ) + 2 * a - 0).toNat) : Bool × ℕ × ℕ) = (true, c, c + 2 * a)
  have e1 : ((c : ℤ) - 0).toNat = c := by omega
  have e2 : ((c : ℤ) + 2 * a - 0).toNat = c + 2 * a := by omega
  rw [e1, e2]

/-- The two states are `Mrel`-related at EVERY modulus: equal countdowns, registers both above
the register threshold, gaps `2 a` and `2 a + 1` both at the gap threshold `2 a`. -/
theorem Mrel_ramp_yG (P a b c : ℕ) (hc : 2 * (b + 1) ≤ c) :
    Mrel P a (b + 1) (ramp c a 0) (yG c a) := by
  rw [ramp_zero]
  refine ⟨⟨⟨rfl, Or.inl rfl, Or.inr ⟨?_, ?_⟩, Or.inr (Or.inl ⟨?_, ?_⟩)⟩, Int.ModEq.refl _⟩,
    Or.inl rfl⟩
  · show 2 * (a + (b + 1)) ≤ c + 2 * a
    omega
  · show 2 * (a + (b + 1)) ≤ c + 2 * a + 1
    omega
  · show 2 * (a : ℤ) ≤ ((c + 2 * a : ℕ) : ℤ) - (c : ℤ)
    push_cast; omega
  · show 2 * (a : ℤ) ≤ ((c + 2 * a + 1 : ℕ) : ℤ) - (c : ℤ)
    push_cast; omega

/-- **NO ROW-LINKED PATH, THROUGH THE GAP COORDINATE.** -/
theorem no_rowLinked_path_gap (P a b c : ℕ) (ha : 1 ≤ a) (hc : 2 * (b + 1) ≤ c) :
    Mrel P a (b + 1) (ramp c a 0) (yG c a) ∧ cntAt (ramp c a) 0 = c ∧
      IsLadderPath stp pnd (ramp c a) ∧
      ¬ ∃ h' : ℤ → LadderState Bool pnd, IsLadderPath stp pnd h' ∧ h' 0 = yG c a ∧
        LnkRow a (b + 1) (ramp c a) h' 0 0 := by
  have hcnt : cntAt (ramp c a) 0 = c := by rw [cntAt, ramp_zero]
  refine ⟨Mrel_ramp_yG P a b c hc, hcnt, ramp_isPath c a ha, ?_⟩
  rintro ⟨h', hh', h0', hl⟩
  have hp : pnd (objAt (ramp c a) 0) = true := by rw [objAt, ramp_zero]; rfl
  have hreg := region_exit_register (ramp_isPath c a ha) hh' hl hp
  have hcnt' : cntAt h' 0 = c := by rw [cntAt, h0']; rfl
  have hnxt' : nxtAt h' 0 = c + 2 * a + 1 := by rw [nxtAt, h0']; rfl
  rw [hcnt, hcnt'] at hreg
  have hlow := nxt_ge_sub h' hh' 0 (c + 1)
  rw [show (0 : ℤ) + ((c + 1 : ℕ) : ℤ) = 0 + (c : ℤ) + 1 by push_cast; ring, hnxt'] at hlow
  have hexit : nxtAt (ramp c a) (0 + (c : ℤ) + 1) = 2 * a - 1 := by
    have hn : ¬ (0 + (c : ℤ) + 1 ≤ (c : ℤ)) := by omega
    simp only [nxtAt, ramp, if_neg hn]
  rw [hexit] at hreg
  omega

/-- **THE PATH FORTH AT THE PHASE 11.49 SIGNATURE IS FALSE.**  Verbatim the signature recorded in
`round-28-k1-admissible-refutation.md` section 11, object half of `(K1)` included. -/
theorem exists_rowLinked_path_K1_refuted :
    ¬ ∀ (Q : Type) [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool),
        (∀ (t : ℤ) (x : LadderState Q pend), ∃ y, RladAdm step pend t x y) →
        (∀ (t : ℤ) (x : LadderState Q pend), ∃ y, RladAdm step pend (t - 1) y x) →
        ∀ (P : ℕ), (∀ l ∈ objCycleLens step pend, l ∣ (P + 1)) →
        ∀ (a b : ℕ) (h : ℤ → LadderState Q pend), IsLadderPath step pend h →
          ∀ (t : ℤ) (y : LadderState Q pend), Mrel P a b (h t) y →
            ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧ h' t = y ∧
              LnkRow a b h h' t t := by
  intro hall
  obtain ⟨hM, -, hp, hno⟩ := no_rowLinked_path_gap 1 1 0 2 le_rfl (by norm_num)
  exact hno (hall Bool stp pnd fwdG bwdG 1 (hK1G 1 (by norm_num)) 1 (0 + 1) (ramp 2 1) hp 0
    (yG 2 1) hM)

/-- The same refutation with EVERY magnitude hypothesis a repair could add: the countdowns are
equal and as large as desired, so no countdown threshold, residue condition or pigeonhole room
(`Fintype.card Q ≤ cntAt`) excludes the pair. -/
theorem no_rowLinked_path_gap_any_room (P a b N : ℕ) (ha : 1 ≤ a) :
    ∃ (x y : LadderState Bool pnd) (h : ℤ → LadderState Bool pnd),
      IsLadderPath stp pnd h ∧ h 0 = x ∧ Mrel P a (b + 1) x y ∧
      x.1.2.1 = y.1.2.1 ∧ N ≤ x.1.2.1 ∧ N ≤ x.1.2.2 ∧ N ≤ y.1.2.2 ∧
      ¬ ∃ h' : ℤ → LadderState Bool pnd, IsLadderPath stp pnd h' ∧ h' 0 = y ∧
        LnkRow a (b + 1) h h' 0 0 := by
  obtain ⟨hM, hcnt, hp, hno⟩ :=
    no_rowLinked_path_gap P a b (N + 2 * (b + 1)) ha (by omega)
  refine ⟨ramp (N + 2 * (b + 1)) a 0, yG (N + 2 * (b + 1)) a, ramp (N + 2 * (b + 1)) a, hp, rfl,
    hM, ?_, ?_, ?_, ?_, hno⟩
  · rw [ramp_zero]; rfl
  · rw [ramp_zero]; show N ≤ N + 2 * (b + 1); omega
  · rw [ramp_zero]; show N ≤ N + 2 * (b + 1) + 2 * a; omega
  · show N ≤ N + 2 * (b + 1) + 2 * a + 1; omega

end ProbeGapJump

#print axioms ProbeGapJump.region_exit_register
#print axioms ProbeGapJump.no_rowLinked_path_gap
#print axioms ProbeGapJump.exists_rowLinked_path_K1_refuted
#print axioms ProbeGapJump.no_rowLinked_path_gap_any_room
