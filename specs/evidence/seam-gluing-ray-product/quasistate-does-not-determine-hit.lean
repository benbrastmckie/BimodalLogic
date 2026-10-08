/-
Probe 742 (the B2b verdict): **the HWZ-verbatim quasistate shape does not determine `Hit`.** Two
regular `ℤ`-frame models whose per-time quasistates — the realized closure types, as bare sets of
closure formulas — and whose consecutive-type relations agree at every time, but whose realized
family-triple sets `FormalSystem.Metalogic.Decidability.RaySummary.Hit` differ. So a B2b that
transcribes Hodkinson–Wolter–Zakharyaschev (2000) Definitions 10–12 (state function, run,
quasimodel) over `⟨ℤ,<⟩` as a per-time set of types plus a consecutive-pair relation, without the
product repair (joint realization through the seam), is refuted before it is attempted: the data
it keeps cannot see the seam's `⊡`-value.

**The fixture.** Three states `a`, `b`, `d` (`Fin 3`), `p` at `b` only, closure `cl = {p, Fp}`
with `Fp := someFuture (.atom pa)` transcribed from `presents-is-seam-decidedness.lean`, never
imported from it. Model A steps `a→a, a→b, b→b, d→d, d→b`; model B steps `a→a, b→b, d→d, d→b` —
the same graph with the edge `a→b` removed. Both are bi-serial and built by
`FrameOver.ofSlicedStep`, regular through `ofSlicedStep_isRegular`. `[Finite W]` on the
*slice* `Fin 3` is the counterexample's licence (a finite per-time alphabet, which is exactly the
shape `not_finite_width_fmp` leaves standing); the carrier `ℤ × Fin 3` is infinite.

**What is established (machine-checked).**

1. *Equal quasistates.* `quasiState M z := {S | ∃ σ, S = {ψ ∈ cl | ψ true on σ at z}}` is, in
   both models and at every `z`, the three-element set `{∅, {Fp}, {p, Fp}}` (`quasiState_eq`,
   generic over the shared witnesses `stayA`, `jump d z`, `stayB`); the fourth type `{p}` is
   realized in neither, because `b` is a sink in both (`sink`), so `p` now forces `p` next and
   hence `Fp`. Hence `quasiState_A_eq_B : ∀ z, quasiState MA z = quasiState MB z`.
2. *Equal consecutive-type relations.* `pairRel M z := {(type_z σ, type_{z+1} σ)}` is, in both
   models and at every `z`, the four-element set `{(∅,∅), ({Fp},{p,Fp}), ({Fp},{Fp}),
   ({p,Fp},{p,Fp})}` (`pairRel_eq`, witnesses `stayA`, `jump d z`, `jump d (z+1)`, `stayB`).
   Hence `pairRel_A_eq_B : ∀ z, pairRel MA z = pairRel MB z`.
3. *Different `⊡¬Fp` values at the same seam.* Through `(t, a)` at `t`: in A the jump `a→b`
   refutes `¬Fp` on a history through the seam state (`stab_notFp_A`); in B every history
   through `a` stays at `a` forever (`stays_a`, by induction through `ofSlicedStep_step`), so
   `⊡¬Fp` holds (`stab_notFp_B`).
4. *Different `Hit`.* `hit_ne : Hit MA stayA t Fp.neg 1 ≠ Hit MB stayA t Fp.neg 1`, from the
   library's hypothesis-free bridge `plusStab_iff_forall_hit` at both seams (same `stabTarget`,
   same `k = 1`): equal `Hit` would force equal `⊡¬Fp` values, contradicting (3). No `k`-type is
   evaluated. Headline: `quasistate_does_not_determine_hit`.

**What is NOT established.** Nothing about `⊡(Pp)`: the seam is forward-only and there is still
no backward Bool-fixture bridge. No claim about what data *does* determine `Hit` (that is the
product repair, task 742's Phase 9 under an explicit realization hypothesis). No decidability of
anything and no complexity bound. `plusStab_iff_forall_hit` is the library's, cited and not
re-proved; this file declares only the fixture and its theorems.

**Axiom record.** Every theorem below: `[propext, Classical.choice, Quot.sound]` (see the
`#print axioms` foot); no `sorryAx`. `Classical.choice` is inherited from
`FrameOver.worldHistoryOfStepPath` and the library's seam machinery, as in every probe of this
collection.

**Compile line.** `lake env lean specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean`
(wired into `scripts/check-evidence-probes.sh`).
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe742

/-! ## The shared vocabulary: three states, one atom, the two-formula closure -/

abbrev St := Fin 3

def a : St := 0
def b : St := 1
def d : St := 2

theorem a_ne_b : a ≠ b := by decide
theorem d_ne_b : d ≠ b := by decide

def pa : Atom := ⟨"p", none⟩

abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- The closure `{p, Fp}`. -/
def cl : Set PlusFormula := {.atom pa, Fp}

/-- The closure type carved out by two truth values: `{p | P} ∪ {Fp | Q}`. -/
def tpOf (P Q : Prop) : Set PlusFormula := {ψ | (ψ = .atom pa ∧ P) ∨ (ψ = Fp ∧ Q)}

theorem tpOf_congr {P P' Q Q' : Prop} (hP : P ↔ P') (hQ : Q ↔ Q') : tpOf P Q = tpOf P' Q' := by
  rw [iff_iff_eq] at hP hQ
  subst hP hQ
  rfl

/-! ## The generic fixture: any step relation on `St` in which `b` is a sink -/

section Generic

variable (R : ℤ → St → St → Prop) (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)

/-- The frame synthesized from the step relation. -/
def Fr : FrameOver intOrder := FrameOver.ofSlicedStep R fwd bwd

instance instFrRegular : (Fr R fwd bwd).IsRegular := FrameOver.ofSlicedStep_isRegular R fwd bwd

/-- `p` holds exactly at `b`. -/
def Md : TaskModel (Fr R fwd bwd).toTaskFrame where
  valuation q _ := q.2 = b

/-- Any history steps along `R` between consecutive times. -/
theorem state_step (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ) :
    R (σ.state z).1 (σ.state z).2 (σ.state (z + 1)).2 := by
  have h := ((FrameOver.ofSlicedStep_step R fwd bwd _ _).mp (σ.isStepPath z)).2
  exact h

/-- A state that only steps to itself is never left. -/
theorem sink (s : St) (hs : ∀ t u, R t s u → u = s) (σ : WorldHistory (Fr R fwd bwd).toTaskFrame)
    (z : ℤ) (hz : (σ.state z).2 = s) : ∀ n : ℕ, (σ.state (z + n)).2 = s := by
  intro n
  induction n with
  | zero => simpa using hz
  | succ n ih =>
    have h := state_step R fwd bwd σ (z + n)
    rw [ih] at h
    have := hs _ _ h
    rwa [show z + ((n + 1 : ℕ) : ℤ) = z + n + 1 by push_cast; ring]

theorem sink_of_le (s : St) (hs : ∀ t u, R t s u → u = s)
    (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ) (hz : (σ.state z).2 = s) (w : ℤ)
    (hw : z ≤ w) : (σ.state w).2 = s := by
  have h := sink R fwd bwd s hs σ z hz (w - z).toNat
  rwa [show z + (((w - z).toNat : ℕ) : ℤ) = w by omega] at h

/-- The truth clauses, read on the fixture. -/
theorem p_iff (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ) :
    PlusTruthAt (Md R fwd bwd) σ z (.atom pa) ↔ (σ.state z).2 = b := Iff.rfl

theorem Fp_iff (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ) :
    PlusTruthAt (Md R fwd bwd) σ z Fp ↔ ∃ s, z < s ∧ (σ.state s).2 = b :=
  PlusTruth.someFuture_iff _ _ _ _

/-- The constant history at `s`, through `(z, s)` at every `z`. -/
noncomputable def stay (s : St) (hs : ∀ t, R t s s) : WorldHistory (Fr R fwd bwd).toTaskFrame :=
  FrameOver.worldHistoryOfStepPath (Fr R fwd bwd) (fun z => (z, s)) (by
    intro z
    exact (FrameOver.ofSlicedStep_step R fwd bwd _ _).mpr ⟨rfl, hs z⟩)

theorem stay_state (s : St) (hs : ∀ t, R t s s) (z : ℤ) :
    (stay R fwd bwd s hs).state z = (z, s) := rfl

/-- The history at `s` up to `w` and at `b` from `w + 1`. -/
noncomputable def jump (s : St) (hs : ∀ t, R t s s) (hsb : ∀ t, R t s b) (hbb : ∀ t, R t b b)
    (w : ℤ) : WorldHistory (Fr R fwd bwd).toTaskFrame :=
  FrameOver.worldHistoryOfStepPath (Fr R fwd bwd) (fun z => (z, if w < z then b else s)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step R fwd bwd _ _).mpr ⟨rfl, ?_⟩
    show R z (if w < z then b else s) (if w < z + 1 then b else s)
    by_cases h : w < z
    · rw [if_pos h, if_pos (by omega)]
      exact hbb z
    · rw [if_neg h]
      by_cases h' : w < z + 1
      · rw [if_pos h']
        exact hsb z
      · rw [if_neg h']
        exact hs z)

theorem jump_state (s : St) (hs : ∀ t, R t s s) (hsb : ∀ t, R t s b) (hbb : ∀ t, R t b b)
    (w z : ℤ) : (jump R fwd bwd s hs hsb hbb w).state z = (z, if w < z then b else s) := rfl

/-! ### Truth on the witnesses -/

theorem stay_not_p (s : St) (hs : ∀ t, R t s s) (hsb : s ≠ b) (z : ℤ) :
    ¬ PlusTruthAt (Md R fwd bwd) (stay R fwd bwd s hs) z (.atom pa) := by
  rw [p_iff, stay_state]
  exact hsb

theorem stay_not_Fp (s : St) (hs : ∀ t, R t s s) (hsb : s ≠ b) (z : ℤ) :
    ¬ PlusTruthAt (Md R fwd bwd) (stay R fwd bwd s hs) z Fp := by
  rw [Fp_iff]
  rintro ⟨r, -, hr⟩
  rw [stay_state] at hr
  exact hsb hr

theorem stayB_p (hbb : ∀ t, R t b b) (z : ℤ) :
    PlusTruthAt (Md R fwd bwd) (stay R fwd bwd b hbb) z (.atom pa) := by
  rw [p_iff, stay_state]

theorem stayB_Fp (hbb : ∀ t, R t b b) (z : ℤ) :
    PlusTruthAt (Md R fwd bwd) (stay R fwd bwd b hbb) z Fp := by
  rw [Fp_iff]
  exact ⟨z + 1, lt_add_one z, by rw [stay_state]⟩

theorem jump_p_iff (s : St) (hs : ∀ t, R t s s) (hsb : ∀ t, R t s b) (hbb : ∀ t, R t b b)
    (hs_ne : s ≠ b) (w z : ℤ) :
    PlusTruthAt (Md R fwd bwd) (jump R fwd bwd s hs hsb hbb w) z (.atom pa) ↔ w < z := by
  rw [p_iff, jump_state]
  by_cases h : w < z
  · simp [h]
  · simp [h, hs_ne]

/-- A switch history always sees `b` ahead. -/
theorem jump_Fp (s : St) (hs : ∀ t, R t s s) (hsb : ∀ t, R t s b) (hbb : ∀ t, R t b b)
    (w z : ℤ) : PlusTruthAt (Md R fwd bwd) (jump R fwd bwd s hs hsb hbb w) z Fp := by
  rw [Fp_iff]
  refine ⟨max w z + 1, by omega, ?_⟩
  rw [jump_state]
  show (if w < max w z + 1 then b else s) = b
  rw [if_pos (by omega)]

/-! ### The HWZ-shaped data: per-time types, quasistates, consecutive-type relation -/

/-- The closure type of `σ` at `z`: the closure formulas true there. -/
def tp (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ) : Set PlusFormula :=
  {ψ | ψ ∈ cl ∧ PlusTruthAt (Md R fwd bwd) σ z ψ}

theorem tp_eq (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ) :
    tp R fwd bwd σ z =
      tpOf (PlusTruthAt (Md R fwd bwd) σ z (.atom pa)) (PlusTruthAt (Md R fwd bwd) σ z Fp) := by
  ext ψ
  simp only [tp, tpOf, cl, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨h | h, hψ⟩ <;> subst h
    · exact Or.inl ⟨rfl, hψ⟩
    · exact Or.inr ⟨rfl, hψ⟩
  · rintro (⟨h, hψ⟩ | ⟨h, hψ⟩) <;> subst h
    · exact ⟨Or.inl rfl, hψ⟩
    · exact ⟨Or.inr rfl, hψ⟩

/-- The quasistate at `z`: the realized closure types, as bare sets (HWZ Def. 10's state
candidate, read off the model). -/
def quasiState (z : ℤ) : Set (Set PlusFormula) :=
  {S | ∃ σ : WorldHistory (Fr R fwd bwd).toTaskFrame, S = tp R fwd bwd σ z}

/-- The consecutive-type relation at `z`: the realized pairs `(type_z σ, type_{z+1} σ)`. -/
def pairRel (z : ℤ) : Set (Set PlusFormula × Set PlusFormula) :=
  {pr | ∃ σ : WorldHistory (Fr R fwd bwd).toTaskFrame, pr = (tp R fwd bwd σ z, tp R fwd bwd σ (z + 1))}

end Generic

/-- The three realized types, in both models at every time: `∅`, `{Fp}`, `{p, Fp}`. -/
def threeTypes : Set (Set PlusFormula) := {tpOf False False, tpOf False True, tpOf True True}

/-- The four realized consecutive pairs, in both models at every time. -/
def fourPairs : Set (Set PlusFormula × Set PlusFormula) :=
  {(tpOf False False, tpOf False False), (tpOf False True, tpOf True True),
    (tpOf False True, tpOf False True), (tpOf True True, tpOf True True)}

/-! ## The quasistate and the pair relation, computed once for every sink-`b` fixture -/

section Computed

variable (R : ℤ → St → St → Prop) (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)

/-- `p` now forces `Fp`: `b` is a sink. -/
theorem Fp_of_p (hb : ∀ t u, R t b u → u = b) (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ)
    (h : PlusTruthAt (Md R fwd bwd) σ z (.atom pa)) : PlusTruthAt (Md R fwd bwd) σ z Fp := by
  rw [Fp_iff]
  exact ⟨z + 1, lt_add_one z, sink_of_le R fwd bwd b hb σ z h (z + 1) (by omega)⟩

/-- `Fp` next gives `Fp` now. -/
theorem Fp_of_Fp_succ (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ)
    (h : PlusTruthAt (Md R fwd bwd) σ (z + 1) Fp) : PlusTruthAt (Md R fwd bwd) σ z Fp := by
  rw [Fp_iff] at h ⊢
  obtain ⟨s, hs, hsb⟩ := h
  exact ⟨s, by omega, hsb⟩

/-- `Fp` now, not `p` next, gives `Fp` next. -/
theorem Fp_succ_of_Fp (σ : WorldHistory (Fr R fwd bwd).toTaskFrame) (z : ℤ)
    (h : PlusTruthAt (Md R fwd bwd) σ z Fp) (hn : ¬ PlusTruthAt (Md R fwd bwd) σ (z + 1) (.atom pa)) :
    PlusTruthAt (Md R fwd bwd) σ (z + 1) Fp := by
  rw [Fp_iff] at h ⊢
  rw [p_iff] at hn
  obtain ⟨s, hs, hsb⟩ := h
  refine ⟨s, ?_, hsb⟩
  rcases lt_or_eq_of_le (show z + 1 ≤ s by omega) with h | h
  · exact h
  · exact absurd (h ▸ hsb) hn

theorem quasiState_eq (hb : ∀ t u, R t b u → u = b) (haa : ∀ t, R t a a) (hbb : ∀ t, R t b b)
    (hdd : ∀ t, R t d d) (hdb : ∀ t, R t d b) (z : ℤ) : quasiState R fwd bwd z = threeTypes := by
  ext S
  simp only [quasiState, threeTypes, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨σ, rfl⟩
    rw [tp_eq]
    by_cases hp : PlusTruthAt (Md R fwd bwd) σ z (.atom pa)
    · exact Or.inr (Or.inr (tpOf_congr (iff_true_intro hp)
        (iff_true_intro (Fp_of_p R fwd bwd hb σ z hp))))
    · by_cases hF : PlusTruthAt (Md R fwd bwd) σ z Fp
      · exact Or.inr (Or.inl (tpOf_congr (iff_false_intro hp) (iff_true_intro hF)))
      · exact Or.inl (tpOf_congr (iff_false_intro hp) (iff_false_intro hF))
  · rintro (rfl | rfl | rfl)
    · exact ⟨stay R fwd bwd a haa, by
        rw [tp_eq]
        exact tpOf_congr (iff_false_intro (stay_not_p R fwd bwd a haa a_ne_b z)).symm
          (iff_false_intro (stay_not_Fp R fwd bwd a haa a_ne_b z)).symm⟩
    · exact ⟨jump R fwd bwd d hdd hdb hbb z, by
        rw [tp_eq]
        exact tpOf_congr
          (iff_false_intro (by rw [jump_p_iff R fwd bwd d hdd hdb hbb d_ne_b]; exact lt_irrefl z)).symm
          (iff_true_intro (jump_Fp R fwd bwd d hdd hdb hbb z z)).symm⟩
    · exact ⟨stay R fwd bwd b hbb, by
        rw [tp_eq]
        exact tpOf_congr (iff_true_intro (stayB_p R fwd bwd hbb z)).symm
          (iff_true_intro (stayB_Fp R fwd bwd hbb z)).symm⟩

theorem pairRel_eq (hb : ∀ t u, R t b u → u = b) (haa : ∀ t, R t a a) (hbb : ∀ t, R t b b)
    (hdd : ∀ t, R t d d) (hdb : ∀ t, R t d b) (z : ℤ) : pairRel R fwd bwd z = fourPairs := by
  ext pr
  simp only [pairRel, fourPairs, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨σ, rfl⟩
    rw [tp_eq, tp_eq]
    by_cases hp : PlusTruthAt (Md R fwd bwd) σ z (.atom pa)
    · -- at `b` now, hence at `b` next: `({p, Fp}, {p, Fp})`
      have hp' : PlusTruthAt (Md R fwd bwd) σ (z + 1) (.atom pa) :=
        sink_of_le R fwd bwd b hb σ z hp (z + 1) (by omega)
      refine Or.inr (Or.inr (Or.inr ?_))
      rw [tpOf_congr (iff_true_intro hp) (iff_true_intro (Fp_of_p R fwd bwd hb σ z hp)),
        tpOf_congr (iff_true_intro hp') (iff_true_intro (Fp_of_p R fwd bwd hb σ (z + 1) hp'))]
    · by_cases hp' : PlusTruthAt (Md R fwd bwd) σ (z + 1) (.atom pa)
      · -- not `b` now, `b` next: `({Fp}, {p, Fp})`
        have hF : PlusTruthAt (Md R fwd bwd) σ z Fp :=
          Fp_of_Fp_succ R fwd bwd σ z (Fp_of_p R fwd bwd hb σ (z + 1) hp')
        refine Or.inr (Or.inl ?_)
        rw [tpOf_congr (iff_false_intro hp) (iff_true_intro hF),
          tpOf_congr (iff_true_intro hp') (iff_true_intro (Fp_of_p R fwd bwd hb σ (z + 1) hp'))]
      · by_cases hF' : PlusTruthAt (Md R fwd bwd) σ (z + 1) Fp
        · -- `b` neither now nor next, but ahead: `({Fp}, {Fp})`
          refine Or.inr (Or.inr (Or.inl ?_))
          rw [tpOf_congr (iff_false_intro hp) (iff_true_intro (Fp_of_Fp_succ R fwd bwd σ z hF')),
            tpOf_congr (iff_false_intro hp') (iff_true_intro hF')]
        · -- `b` never ahead: `(∅, ∅)`
          have hF : ¬ PlusTruthAt (Md R fwd bwd) σ z Fp :=
            fun h => hF' (Fp_succ_of_Fp R fwd bwd σ z h hp')
          refine Or.inl ?_
          rw [tpOf_congr (iff_false_intro hp) (iff_false_intro hF),
            tpOf_congr (iff_false_intro hp') (iff_false_intro hF')]
  · rintro (rfl | rfl | rfl | rfl)
    · exact ⟨stay R fwd bwd a haa, by
        rw [tp_eq, tp_eq,
          tpOf_congr (iff_false_intro (stay_not_p R fwd bwd a haa a_ne_b z))
            (iff_false_intro (stay_not_Fp R fwd bwd a haa a_ne_b z)),
          tpOf_congr (iff_false_intro (stay_not_p R fwd bwd a haa a_ne_b (z + 1)))
            (iff_false_intro (stay_not_Fp R fwd bwd a haa a_ne_b (z + 1)))]⟩
    · exact ⟨jump R fwd bwd d hdd hdb hbb z, by
        rw [tp_eq, tp_eq,
          tpOf_congr
            (iff_false_intro (by rw [jump_p_iff R fwd bwd d hdd hdb hbb d_ne_b]; exact lt_irrefl z))
            (iff_true_intro (jump_Fp R fwd bwd d hdd hdb hbb z z)),
          tpOf_congr
            (iff_true_intro ((jump_p_iff R fwd bwd d hdd hdb hbb d_ne_b z (z + 1)).mpr (lt_add_one z)))
            (iff_true_intro (jump_Fp R fwd bwd d hdd hdb hbb z (z + 1)))]⟩
    · exact ⟨jump R fwd bwd d hdd hdb hbb (z + 1), by
        rw [tp_eq, tp_eq,
          tpOf_congr
            (iff_false_intro (by rw [jump_p_iff R fwd bwd d hdd hdb hbb d_ne_b]; omega))
            (iff_true_intro (jump_Fp R fwd bwd d hdd hdb hbb (z + 1) z)),
          tpOf_congr
            (iff_false_intro (by rw [jump_p_iff R fwd bwd d hdd hdb hbb d_ne_b]; exact lt_irrefl _))
            (iff_true_intro (jump_Fp R fwd bwd d hdd hdb hbb (z + 1) (z + 1)))]⟩
    · exact ⟨stay R fwd bwd b hbb, by
        rw [tp_eq, tp_eq,
          tpOf_congr (iff_true_intro (stayB_p R fwd bwd hbb z))
            (iff_true_intro (stayB_Fp R fwd bwd hbb z)),
          tpOf_congr (iff_true_intro (stayB_p R fwd bwd hbb (z + 1)))
            (iff_true_intro (stayB_Fp R fwd bwd hbb (z + 1)))]⟩

end Computed

/-! ## Model A: `a→a, a→b, b→b, d→d, d→b` -/

/-- `a` steps to `a` and `b`; `b` to `b`; `d` to `d` and `b`. -/
def RA : ℤ → St → St → Prop := fun _ u v => v = u ∨ v = b

theorem RA_fwd : ∀ (t : ℤ) (w : St), ∃ u, RA t w u := fun _ w => ⟨w, Or.inl rfl⟩
theorem RA_bwd : ∀ (t : ℤ) (w : St), ∃ v, RA (t - 1) v w := fun _ w => ⟨w, Or.inl rfl⟩

theorem RA_b : ∀ t u, RA t b u → u = b := fun _ _ h => h.elim id id
theorem RA_aa : ∀ t, RA t a a := fun _ => Or.inl rfl
theorem RA_ab : ∀ t, RA t a b := fun _ => Or.inr rfl
theorem RA_bb : ∀ t, RA t b b := fun _ => Or.inl rfl
theorem RA_dd : ∀ t, RA t d d := fun _ => Or.inl rfl
theorem RA_db : ∀ t, RA t d b := fun _ => Or.inr rfl

abbrev FA : FrameOver intOrder := Fr RA RA_fwd RA_bwd
abbrev MA : TaskModel FA.toTaskFrame := Md RA RA_fwd RA_bwd

/-- The history of A that stays at `a`. -/
noncomputable abbrev stayA_A : WorldHistory FA.toTaskFrame := stay RA RA_fwd RA_bwd a RA_aa

/-! ## Model B: `a→a, b→b, d→d, d→b` (no `a→b`) -/

/-- `a` steps to `a` only; `b` to `b`; `d` to `d` and `b`. -/
def RB : ℤ → St → St → Prop := fun _ u v => v = u ∨ (u = d ∧ v = b)

theorem RB_fwd : ∀ (t : ℤ) (w : St), ∃ u, RB t w u := fun _ w => ⟨w, Or.inl rfl⟩
theorem RB_bwd : ∀ (t : ℤ) (w : St), ∃ v, RB (t - 1) v w := fun _ w => ⟨w, Or.inl rfl⟩

theorem RB_b : ∀ t u, RB t b u → u = b := fun _ _ h => h.elim id (fun h => h.2)
theorem RB_a : ∀ t u, RB t a u → u = a := fun _ _ h => h.elim id (fun h => absurd h.1 (by decide))
theorem RB_aa : ∀ t, RB t a a := fun _ => Or.inl rfl
theorem RB_bb : ∀ t, RB t b b := fun _ => Or.inl rfl
theorem RB_dd : ∀ t, RB t d d := fun _ => Or.inl rfl
theorem RB_db : ∀ t, RB t d b := fun _ => Or.inr ⟨rfl, rfl⟩

abbrev FB : FrameOver intOrder := Fr RB RB_fwd RB_bwd
abbrev MB : TaskModel FB.toTaskFrame := Md RB RB_fwd RB_bwd

/-- The history of B that stays at `a`. -/
noncomputable abbrev stayA_B : WorldHistory FB.toTaskFrame := stay RB RB_fwd RB_bwd a RB_aa

/-! ## The DECISION GATE: equal quasistates and equal pair relations -/

theorem quasiState_A_eq_B : ∀ z, quasiState RA RA_fwd RA_bwd z = quasiState RB RB_fwd RB_bwd z := by
  intro z
  rw [quasiState_eq RA RA_fwd RA_bwd RA_b RA_aa RA_bb RA_dd RA_db,
    quasiState_eq RB RB_fwd RB_bwd RB_b RB_aa RB_bb RB_dd RB_db]

theorem pairRel_A_eq_B : ∀ z, pairRel RA RA_fwd RA_bwd z = pairRel RB RB_fwd RB_bwd z := by
  intro z
  rw [pairRel_eq RA RA_fwd RA_bwd RA_b RA_aa RA_bb RA_dd RA_db,
    pairRel_eq RB RB_fwd RB_bwd RB_b RB_aa RB_bb RB_dd RB_db]

/-! ## The seam `(stayA, t)` has different `⊡¬Fp` values in the two models -/

/-- In A the jump `a→b` at `t` passes through the seam state `(t, a)` and satisfies `Fp`. -/
theorem stab_notFp_A (t : ℤ) : ¬ PlusTruthAt MA stayA_A t (.stab Fp.neg) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hj := h (jump RA RA_fwd RA_bwd a RA_aa RA_ab RA_bb t) (by
    rw [stay_state, jump_state, if_neg (lt_irrefl t)])
  exact (PlusTruth.neg_iff _ _ _ _).mp hj (jump_Fp RA RA_fwd RA_bwd a RA_aa RA_ab RA_bb t t)

/-- In B every history through `a` at `t` is at `a` at every later time. -/
theorem stays_a (σ : WorldHistory FB.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = a) :
    ∀ z, t ≤ z → (σ.state z).2 = a :=
  fun z hz => sink_of_le RB RB_fwd RB_bwd a RB_a σ t h z hz

/-- In B the seam `(stayA, t)` satisfies `⊡¬Fp`: no history through `(t, a)` ever reaches `b`. -/
theorem stab_notFp_B (t : ℤ) : PlusTruthAt MB stayA_B t (.stab Fp.neg) := by
  rw [PlusTruth.stab_iff]
  intro σ hσ
  rw [PlusTruth.neg_iff, Fp_iff]
  rintro ⟨s, hs, hsb⟩
  have ha : (σ.state t).2 = a := by
    rw [← hσ, stay_state]
  have := stays_a σ t ha s (le_of_lt hs)
  rw [hsb] at this
  exact a_ne_b this.symm

/-! ## The obstruction -/

/-- **The realized family-triple sets differ**, by the library's hypothesis-free bridge at
`k = 1`: equal `Hit` would give equal `⊡¬Fp` values at the two seams. -/
theorem hit_ne (t : ℤ) : Hit MA stayA_A t Fp.neg 1 ≠ Hit MB stayA_B t Fp.neg 1 := by
  intro heq
  have hA := (plusStab_iff_forall_hit MA stayA_A t Fp.neg 1 le_rfl)
  have hB := (plusStab_iff_forall_hit MB stayA_B t Fp.neg 1 le_rfl)
  rw [heq] at hA
  exact stab_notFp_A t (hA.mpr (hB.mp (stab_notFp_B t)))

/-- **The headline.** Equal quasistates at every time, equal consecutive-type relations at every
time, different `Hit` at a common seam: the HWZ-verbatim quasistate data does not determine the
realized family triples, so no B2b transcribed in that shape can feed `plusStab_iff_forall_hit`. -/
theorem quasistate_does_not_determine_hit (t : ℤ) :
    (∀ z, quasiState RA RA_fwd RA_bwd z = quasiState RB RB_fwd RB_bwd z) ∧
    (∀ z, pairRel RA RA_fwd RA_bwd z = pairRel RB RB_fwd RB_bwd z) ∧
    Hit MA stayA_A t Fp.neg 1 ≠ Hit MB stayA_B t Fp.neg 1 :=
  ⟨quasiState_A_eq_B, pairRel_A_eq_B, hit_ne t⟩

end Probe742

/-! ## Citations: the library results this probe rests on and points at (cited, not re-proved) -/

#check @FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hit
#check @FormalSystem.Metalogic.Decidability.RaySummary.Hit
#check @FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp

#print axioms Probe742.quasiState_A_eq_B
#print axioms Probe742.pairRel_A_eq_B
#print axioms Probe742.stab_notFp_A
#print axioms Probe742.stab_notFp_B
#print axioms Probe742.hit_ne
#print axioms Probe742.quasistate_does_not_determine_hit
