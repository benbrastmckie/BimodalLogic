/-
THE DECISION GATE: does lengthening the idle gap buy the missing slack type-respectingly?

Prototype, compiled standalone with `lake env lean` through the build guard; NOT a wired probe.

ONE question. The anchor clause of the re-anchored deletion is short by exactly `l` in its upper
direction `nxtAt g s₀ ≤ n + cntAt g z + I − l`, where `I` is the length of the idle run between
`z`'s region and the first region start above it. Raising `I` by `l` raises that bound by exactly
`l` and so supplies the missing amount, and `pinCompat_of_ladderPath` does not forbid it: moving a
region start FARTHER from `z` while holding its countdown makes the pin demand strictly looser.
Does a lengthened path exist — admissible, with the register at `z` held, and realizing the SAME
stab-free type at `z`?

**VERDICT: FAIL, on sub-question (i), ADMISSIBILITY.** The schema is REFUTED by a compiled object,
`idleGapLengthening_refuted`.

**The mechanism.** The idle run's length is not a free parameter of the path: it is bounded by
what the OBJECT's own step graph admits between two pending regions. `pinCompat_of_ladderPath` is
indeed not the obstruction — the obstruction is one level below it, in `step`. A ladder path's
object walk must satisfy `step (objAt g v) (objAt g (v + 1)) = true` at every position, so an idle
run of length two requires an idle-to-idle edge in `step`. An object may simply not have one:
`no_consecutive_idle_of_no_idle_step` below is the generic reading, and the two-state object `Qo`
(one pending state, one idle state, `stepO false false = false`) is the witness. On that object
EVERY ladder path has idle runs of length exactly one, so no path whatever realizes an idle run of
length `I + l` for `l ≥ 1` — the lengthened path is denied before any pin or type question is
reached. The parameters are the periodicity fixpoint's own outputs for a stab-free atomic closure,
discharged by the landed `paramsOk_params`, so the refutation sits at a tuple the parameter
conditions genuinely admit and not at a vacuous hypothesis.

**What this settles.** The lengthening is NOT a theorem of the schema, so it cannot be promoted to
the slack-normalization lemma the downward cell inclusion would consume. The gate's consumer takes
its FAIL branch: the obligation is landed in a forward-slack-restricted form under a NEW name, and
the unrestricted reserved name stays reserved.

**What this does NOT settle.** Three things, named rather than implied.

* Sub-question (ii), TYPE PRESERVATION, is UNTOUCHED. The refutation closes from `step` alone and
  never reaches the type clause, so nothing here says whether a lengthened path, where one exists,
  holds the realized stab-free type at `z`. The type clause is carried in the schema's conclusion
  for faithfulness, and refuting a conjunction refutes it at the first conjunct that fails.
* It does not say the lengthening fails on EVERY object. An object whose idle states carry a cycle
  — in particular any object with an idle-to-idle edge — admits longer idle runs, and `tIdle`'s own
  shape (`#idle states + 1`) is the bound under which a run must repeat an idle state and so
  become duplicable. The sharpening is: the lengthening is available exactly where the object's
  idle states carry a reachable cycle, which is an object hypothesis and not a consequence of
  `ParamsOk`. That hypothesis is not assumed anywhere in the ladder layer, and assuming it is a
  restriction of the obligation, not a proof of it.
* It does not refute the depth-`0` cell obligation. The obligation is about cells; the schema here
  is about one path-construction device.

The object below is declared fresh rather than reused from the sibling prototypes: those use
`stepC = fun _ _ => true`, which admits every idle run and so cannot carry this refutation.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe838C

/-! ## The gate's schema

The lengthening tuple is exactly what the slack-normalization lemma would consume: a ladder path
pending forever into the past at `z`, with the gap at `z` and the countdown at least `T_c`, and the
idle run of length `I` immediately above `z`'s region followed by a region start. The schema
asserts the existence of a path that agrees with it at `z` in all three components, carries an idle
run of length `I + l` in the same place, hands the displaced region start the SAME countdown, and
realizes the same stab-free type at `z`. It is stated as a named `def` so that the verdict is a
theorem about a named object either way, on the precedent of `SpanningBlockBwd` and
`SpanningBlockLengthDvd`. -/

def IdleGapLengthening {Q : Type} [Fintype Q] [Nonempty Q] (step : Q → Q → Bool)
    (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ (z : ℤ) (I l : ℕ),
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) →
      nxtAt g z + 2 ≤ cntAt g z →
      Tc ≤ cntAt g z →
      0 < I → 0 < l →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
        objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
        (∀ i : ℕ, i < I + l →
          pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + (i : ℤ))) = false) ∧
        pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + l : ℕ) : ℤ))) = true ∧
        cntAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + l : ℕ) : ℤ))
          = cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) ∧
        ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
          (∀ t : ℤ, σ.state t = (t, g t)) →
          (∀ t : ℤ, σ'.state t = (t, g' t)) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' z
            = tpOf (ladderModel step pend fwd bwd lab) φ σ z

/-! ## The generic mechanism: an idle run of length two needs an idle-to-idle edge

This is the whole content of the gate's FAIL, stated once and generically: the object walk of a
ladder path steps along `step` at every position (`objAt_step`), so an object with no idle-to-idle
edge forces every idle position to be followed by a pending one. The idle run's length is therefore
a datum of the object's step graph, not a parameter the construction may raise. -/

theorem no_consecutive_idle_of_no_idle_step {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (hstep : ∀ x y : Q, pend x = false → pend y = false → step x y = false)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (v : ℤ)
    (h0 : pend (objAt g v) = false) : pend (objAt g (v + 1)) = true := by
  by_contra h
  rw [Bool.not_eq_true] at h
  have hs := objAt_step g hg v
  rw [hstep _ _ h0 h] at hs
  exact Bool.false_ne_true hs

/-! ## The refuting object: one pending state, one idle state, and no idle-to-idle edge

`Qo := Bool` with `pendO = id`: `true` is the pending state and `false` the idle one. `stepO x y`
is `x || y`, so every edge is admitted except the idle-to-idle one. The object is serial in both
directions (`fwdO`, `bwdO`), and its atomic closure `aO` is stab-free with a type that reads the
label at the position's own object state. -/

abbrev Qo : Type := Bool

def pendO : Qo → Bool := fun q => q

def stepO : Qo → Qo → Bool := fun x y => x || y

def pO : Atom := ⟨"p", none⟩

def labO : Qo → Atom → Bool := fun q at_ => decide (at_ = pO ∧ q = true)

theorem stepO_eq_true_iff (x y : Qo) : stepO x y = true ↔ x = true ∨ y = true := by
  simp [stepO]

theorem no_idle_idle_step : ∀ x y : Qo, pendO x = false → pendO y = false → stepO x y = false := by
  decide

theorem labO_pO (q : Qo) : labO q pO = pendO q := by
  cases q <;> simp [labO, pendO]

theorem admTrueO (c n : ℕ) : ((true : Qo), c, n).2.1 ∈ Adm pendO ((true : Qo), c, n).1 :=
  fun h => by simp [pendO] at h

theorem fwdO : ∀ (t : ℤ) (x : LadderState Qo pendO), ∃ y, RladAdm stepO pendO t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  cases q with
  | false =>
      have hc : c = 0 := hx rfl
      subst hc
      exact ⟨⟨(true, n, n), admTrueO n n⟩, rfl, hx, Or.inl rfl, by simp [Count, pendO]⟩
  | true =>
      cases c with
      | zero =>
          exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, by simp [Count, pendO]⟩
      | succ d =>
          exact ⟨⟨(true, d, n), admTrueO d n⟩, rfl, hx, Or.inl rfl, by simp [Count, pendO]⟩

theorem bwdO : ∀ (t : ℤ) (x : LadderState Qo pendO), ∃ y, RladAdm stepO pendO (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  cases q with
  | false =>
      have hc : c = 0 := hx rfl
      subst hc
      exact ⟨⟨(true, 0, n), admTrueO 0 n⟩, rfl, admTrueO 0 n, Or.inl rfl,
        by simp [Count, pendO]⟩
  | true =>
      exact ⟨⟨(true, c + 1, n), admTrueO (c + 1) n⟩, rfl, admTrueO (c + 1) n, Or.inl rfl,
        by simp [Count, pendO]⟩

/-! ## The witnessing path: one long region through `0`, then idle runs of length exactly one

`wO C` is pending at every position at or below `C` and alternates idle/pending above it, the idle
positions being `C + 1, C + 3, C + 5, …`. The countdown `cO C` is the distance up to `C`, clipped
at `0`, which is the countdown the region through `0` forces; the register is constantly `0`, which
the pins allow because every pin hands the region start the countdown `0`. -/

def wO (C : ℕ) : ℤ → Qo := fun v => if (C : ℤ) + 1 ≤ v ∧ (v - (C : ℤ)) % 2 = 1 then false else true

def cO (C : ℕ) : ℤ → ℕ := fun v => ((C : ℤ) - v).toNat

theorem pendO_wO_false_iff (C : ℕ) (v : ℤ) :
    pendO (wO C v) = false ↔ ((C : ℤ) + 1 ≤ v ∧ (v - (C : ℤ)) % 2 = 1) := by
  unfold pendO wO
  split_ifs with h
  · simp [h]
  · simp only [false_iff]
    exact h

theorem pendO_wO_true_iff (C : ℕ) (v : ℤ) :
    pendO (wO C v) = true ↔ ¬((C : ℤ) + 1 ≤ v ∧ (v - (C : ℤ)) % 2 = 1) := by
  rw [← Bool.not_eq_false, pendO_wO_false_iff]

/-- The witnessing walk with its forced countdown lifts to a ladder path whose register at `0`
is `0`. -/
theorem exists_gO (C : ℕ) : ∃ g : ℤ → LadderState Qo pendO, IsLadderPath stepO pendO g ∧
    (∀ v, objAt g v = wO C v) ∧ (∀ v, cntAt g v = cO C v) ∧ nxtAt g 0 = 0 := by
  refine exists_ladderPath_of_walk_nxt_at (wO C) (cO C) 0 0 ?_ ?_ ?_ ?_ ?_ ?_
  · intro v
    rw [stepO_eq_true_iff]
    by_cases h : (C : ℤ) + 1 ≤ v ∧ (v - (C : ℤ)) % 2 = 1
    · obtain ⟨h1, h2⟩ := h
      refine Or.inr ?_
      unfold wO
      rw [if_neg]
      rintro ⟨-, h3⟩
      omega
    · refine Or.inl ?_
      unfold wO
      rw [if_neg h]
  · intro v hv
    rw [pendO_wO_false_iff] at hv
    unfold cO
    omega
  · intro v h0 h1
    rw [pendO_wO_true_iff] at h0
    rw [pendO_wO_true_iff] at h1
    unfold cO
    have hvC : v + 1 ≤ (C : ℤ) := by
      by_contra hcon
      rcases lt_or_ge v (C : ℤ) with hlt | hge
      · omega
      · rcases eq_or_lt_of_le hge with heq | hgt
        · exact h1 ⟨by omega, by omega⟩
        · rcases Int.even_or_odd (v - (C : ℤ)) with ⟨k, hk⟩ | ⟨k, hk⟩
          · exact h1 ⟨by omega, by omega⟩
          · exact h0 ⟨by omega, by omega⟩
    omega
  · intro v _ h1
    rw [pendO_wO_false_iff] at h1
    unfold cO
    omega
  · intro s v hs0 _ hv0 _
    rw [pendO_wO_false_iff] at hs0
    rw [pendO_wO_false_iff] at hv0
    unfold cO
    have hs : ((C : ℤ) - (s + 1)).toNat = 0 := by omega
    have hv : ((C : ℤ) - (v + 1)).toNat = 0 := by omega
    rw [hs, hv]
    simp
  · intro v hv0 _
    rw [pendO_wO_false_iff] at hv0
    unfold cO
    have hv : ((C : ℤ) - (v + 1)).toNat = 0 := by omega
    rw [hv]
    simp

/-! ## The stab-free atomic closure and the parameter tuple -/

def aO : PlusFormula := .atom pO

theorem closure_aO : plusSubformulaClosure aO = {aO} := by
  simp [plusSubformulaClosure, aO, PlusFormula.subformulas]

theorem no_stab_in_closure_aO :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure aO := by
  intro χ h
  rw [closure_aO, Finset.mem_singleton] at h
  exact PlusFormula.noConfusion h

noncomputable def TcO : ℕ := Tcof stepO pendO labO aO
noncomputable def TnO : ℕ := Tnof stepO pendO labO aO
noncomputable def PO : ℕ := Pof stepO pendO labO aO
noncomputable def BO : ℕ := Bof stepO pendO labO aO

theorem paramsOkO : ParamsOk stepO pendO labO aO TcO TnO PO BO :=
  paramsOk_params stepO pendO labO aO

/-- `(K3)` bounds `T_c` from below by `2 T_short + T_idle + 2`, so the witnessing region's
countdown `T_c` already exceeds the gap the schema's hypothesis `nxtAt g z + 2 ≤ cntAt g z`
demands of it at the register value `0`. -/
theorem two_le_TcO : 2 ≤ TcO := by
  have h := paramsOkO.2.2.1.2
  omega

/-! ## The verdict -/

/-- **THE GATE IS FAIL, ON ADMISSIBILITY.** On the two-state object with no idle-to-idle edge,
the witnessing path satisfies every hypothesis of the schema at `z = 0`, `I = 1`, `l = 1` — pending
forever into its past, register `0` against a countdown `T_c ≥ 2`, and the idle run `{C + 1}`
followed by the region start at `C + 2`. The conclusion asks for a ladder path with idle positions
at both `C + 1` and `C + 2`, which `no_consecutive_idle_of_no_idle_step` forbids on this object for
every ladder path whatever. The schema therefore fails, and it fails before the pin clause or the
type clause is reached. -/
theorem idleGapLengthening_refuted :
    ¬ IdleGapLengthening stepO pendO fwdO bwdO labO aO TcO TnO PO BO := by
  intro h
  obtain ⟨g, hg, hobj, hcnt, hnxt⟩ := exists_gO TcO
  have hC : cntAt g 0 = TcO := by rw [hcnt]; unfold cO; omega
  -- the hypotheses, at `z = 0`, `I = 1`, `l = 1`
  have hpast : ∀ p : ℤ, p ≤ 0 → pendO (objAt g p) = true := by
    intro p hp
    rw [hobj, pendO_wO_true_iff]
    rintro ⟨h1, -⟩
    have := two_le_TcO
    omega
  have hgap : nxtAt g 0 + 2 ≤ cntAt g 0 := by
    rw [hnxt, hC]
    exact two_le_TcO
  have hTc : TcO ≤ cntAt g 0 := by rw [hC]
  have hidle : ∀ i : ℕ, i < 1 →
      pendO (objAt g (0 + (cntAt g 0 : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    have hi0 : i = 0 := by omega
    subst hi0
    rw [hC, hobj, pendO_wO_false_iff]
    exact ⟨by omega, by omega⟩
  have hstart : pendO (objAt g (0 + (cntAt g 0 : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
    rw [hC, hobj, pendO_wO_true_iff]
    rintro ⟨-, h2⟩
    omega
  obtain ⟨g', hg', -, hcnt', -, hrun, -, -, -⟩ :=
    h paramsOkO no_stab_in_closure_aO g hg 0 1 1 hpast hgap hTc (by omega) (by omega)
      hidle hstart
  -- the two positions the lengthened run asks to be idle are consecutive
  have hi0 : pendO (objAt g' (0 + (cntAt g' 0 : ℤ) + 1 + ((0 : ℕ) : ℤ))) = false :=
    hrun 0 (by omega)
  have hi1 : pendO (objAt g' (0 + (cntAt g' 0 : ℤ) + 1 + ((1 : ℕ) : ℤ))) = false :=
    hrun 1 (by omega)
  have hnext := no_consecutive_idle_of_no_idle_step no_idle_idle_step g' hg'
    (0 + (cntAt g' 0 : ℤ) + 1 + ((0 : ℕ) : ℤ)) hi0
  rw [show (0 : ℤ) + (cntAt g' 0 : ℤ) + 1 + ((0 : ℕ) : ℤ) + 1
      = 0 + (cntAt g' 0 : ℤ) + 1 + ((1 : ℕ) : ℤ) by push_cast; ring] at hnext
  exact Bool.false_ne_true (hi1.symm.trans hnext)

end Probe838C

#print axioms Probe838C.no_consecutive_idle_of_no_idle_step
#print axioms Probe838C.idleGapLengthening_refuted
