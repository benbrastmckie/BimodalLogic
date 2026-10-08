/-
Probe 711 (E2, probe ii): **the depth-2 stratification probe** — on a fixture whose depth-1
`⊡`-value is STATE-DEPENDENT, is the `⊡`-value of a depth-2 formula at a state a function of
`(state, depth-1 stratum)`?

**The falsifier sentence this probe is defined from.** The ranking's falsifier for the
stratification route reads: *a `⊡`-depth-2 formula whose `⊡`-value at a class is not a function
of the class's summary state*. The shared Bool fixture of the earlier probes cannot host it,
because its depth-1 value `⊡(Fp)` is False at EVERY state (`Probe718FiniteGraph.decide_will`), so
there is nothing for a depth-2 value to be a non-function of. This probe builds the smallest
fixture on which the depth-1 value varies with the state, computes two depth-2 values twice —
directly, and through the stratification (`plusTruthAt_iff_atomize`, reading the inner `⊡Fp`
through its own stratum) — and asks the falsifier's question.

**Fixture.** Two states `a := false` and `b := true`, time-independent one-step relation
`Rg _ u v := (u = false ∨ v = true)`: edges `a→a`, `a→b`, `b→b` and no `b→a`. Bi-serial (`b` is a
successor of everything, `a` a predecessor of everything), so `FrameOver.ofSlicedStep` applies
and the frame is regular. `p` holds exactly at `b`.

**What is established (machine-checked).**

1. *Depth 1 is state-dependent* (`stab_will_iff`): `⊡(Fp)` holds at a seam state iff that state
   is `b` — at `a` the history that stays at `a` forever (`stayA`) never sees `p`
   (`stab_will_at_a`), at `b` every successor is `b` (`stab_will_at_b`).
2. *Depth 2, computed directly* (`depth2_1_iff`, `depth2_2_iff`): both `⊡F(⊡Fp)` and
   `⊡(Fp → ⊡Fp)` hold at a seam state iff it is `b`. At `a` the first fails along `stayA` and the
   second along the history `jumpB` that leaves `a` for `b` at the next instant (`Fp` true,
   `⊡Fp` false there). Confirmed, not assumed: `a` gives False twice, `b` gives True twice.
3. *Depth 2, computed through the strata* (`depth2_via_strata_1`, `depth2_via_strata_2`): each
   depth-2 value equals the value of the depth-1 formula obtained by replacing the inner `⊡Fp` by
   the fresh atom `e.ι (inr Fp)` and `p` by `e.ι (inl p)`, evaluated over the atomized model
   `Mg.atomModel e`, whose fresh-atom valuation IS the depth-1 stratum (`stab_fp_iff_fresh`,
   through `stab_state_only`). The landed transfer lemma `plusTruthAt_iff_atomize` is cited at
   each formula (`strata_is_atomize_1`, `_2`); note it atomizes the OUTER `⊡`, reading the whole
   depth-2 formula through one depth-2 stratum atom, while the `via_strata` theorems read the
   INNER `⊡` through the depth-1 stratum — the two readings agree on this fixture.
4. *The falsifier check* (`value_is_function_of_stratum`): on this fixture, each depth-2
   `⊡`-value at a seam IS a function of the depth-1 stratum — two seams with equal depth-1 values
   have equal depth-2 values, for both formulas. In fact the depth-2 values coincide with the
   depth-1 value (`depth2_1_iff`, `depth2_2_iff` against `stab_will_iff`).

**What is NOT established.** This is a POSITIVE result on ONE fixture, not a proof that the
falsifier cannot exist: what would kill stratification is a fixture with two states of EQUAL
depth-1 strata that differ at depth 2, and this probe exhibits none — a two-state fixture with a
state-dependent depth-1 value has one state per stratum value, so no two distinct states share a
stratum here, and the falsifier's question is answered trivially in the affirmative. A fixture
with three or more states, two of them sharing the depth-1 stratum, is the real test and is a
follow-up. Only the two depth-2 shapes named by the plan are probed; `⊡(Fp → ⊡Pp)`-shaped mixed
formulas are not. No decidability, no complexity bound, nothing about devices.

**Axiom record.** Every theorem below: `[propext, Classical.choice, Quot.sound]` (see the
`#print axioms` foot); no `sorryAx`. `Classical.choice` enters through
`FrameOver.worldHistoryOfStepPath` (the two constructed histories) and the frame constructor.

**Compile line.** `lake env lean specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`
(wired into `scripts/check-evidence-probes.sh`).
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.Conservativity

namespace Probe711DepthTwo

/-! ## The fixture -/

/-- One-step relation on `Bool`: `a := false` steps to `a` and to `b`, `b := true` steps to `b`
only. -/
def Rg : ℤ → Bool → Bool → Prop := fun _ u v => u = false ∨ v = true

theorem Rg_fwd : ∀ (t : ℤ) (w : Bool), ∃ u, Rg t w u := fun _ _ => ⟨true, Or.inr rfl⟩
theorem Rg_bwd : ∀ (t : ℤ) (w : Bool), ∃ v, Rg (t - 1) v w := fun _ _ => ⟨false, Or.inl rfl⟩

/-- The fixture frame, regular by construction. -/
def Fg : FrameOver intOrder := FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd

instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd

/-- The distinguished atom: `p` holds exactly at `b`. -/
def pa : Atom := ⟨"p", none⟩

/-- The fixture model. -/
def Mg : TaskModel Fg.toTaskFrame where
  valuation q _ := q.2 = true

/-- `Fp`, the depth-0 core. -/
abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- One step along any history: time advances by one and `Rg` relates the states. -/
theorem step_succ (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    (σ.path (t + 1)).1 = (σ.path t).1 + 1 ∧ Rg (σ.path t).1 (σ.path t).2 (σ.path (t + 1)).2 :=
  (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mp (σ.isStepPath t)

/-- From `b` the next state is `b`: there is no edge `b→a`. -/
theorem next_true (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = true) :
    (σ.state (t + 1)).2 = true := by
  rcases (step_succ σ t).2 with h1 | h1
  · have h' : (σ.path t).2 = true := h
    rw [h'] at h1
    exact Bool.noConfusion h1
  · exact h1

/-! ## Two constructed histories through a seam at `a` -/

/-- The history that stays at `a` forever, placed so that it passes through `(c, a)` at time
`t`. -/
noncomputable def stayA (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), false)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, Or.inl rfl⟩
    show z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem stayA_state (c t z : ℤ) : (stayA c t).state z = (z + (c - t), false) := rfl

theorem stayA_state_t (c t : ℤ) : (stayA c t).state t = (c, false) := by
  rw [stayA_state]
  congr 1
  ring

/-- The history that sits at `a` up to time `t` and jumps to `b` at `t + 1`, staying there. -/
noncomputable def jumpB (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), decide (t < z))) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, ?_⟩
    · show z + 1 + (c - t) = z + (c - t) + 1
      ring
    · show decide (t < z) = false ∨ decide (t < z + 1) = true
      by_cases h : t < z
      · right
        rw [decide_eq_true_eq]
        omega
      · left
        rw [decide_eq_false_iff_not]
        exact h)

theorem jumpB_state (c t z : ℤ) : (jumpB c t).state z = (z + (c - t), decide (t < z)) := rfl

theorem jumpB_state_t (c t : ℤ) : (jumpB c t).state t = (c, false) := by
  rw [jumpB_state, decide_eq_false (lt_irrefl t)]
  congr 1
  ring

theorem jumpB_state_succ (c t : ℤ) : ((jumpB c t).state (t + 1)).2 = true := by
  rw [jumpB_state]
  exact decide_eq_true (lt_add_one t)

/-! ## Depth 1: the state-dependent value -/

/-- **`⊡(Fp)` holds at a seam iff the seam state is `b`.** -/
theorem stab_will_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab Fp) ↔ (τ.state t).2 = true := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    by_contra hne
    have hfalse : (τ.state t).2 = false := Bool.eq_false_iff.mpr hne
    have hagree : τ.state t = (stayA (τ.state t).1 t).state t := by
      rw [stayA_state_t]
      exact Prod.ext rfl hfalse
    obtain ⟨s, -, hs, -⟩ := h _ hagree
    have hs' : ((stayA (τ.state t).1 t).state s).2 = true := hs
    rw [stayA_state] at hs'
    exact Bool.noConfusion hs'
  · intro hb σ hagree
    have h1 : (σ.state t).2 = true := by rw [← hagree]; exact hb
    exact ⟨t + 1, lt_add_one t, next_true σ t h1,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- At a seam state `a`, `⊡(Fp)` fails. -/
theorem stab_will_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (ha : (τ.state t).2 = false) :
    ¬ PlusTruthAt Mg τ t (.stab Fp) := by
  rw [stab_will_iff, ha]
  exact fun h => Bool.noConfusion h

/-- At a seam state `b`, `⊡(Fp)` holds. -/
theorem stab_will_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = true) :
    PlusTruthAt Mg τ t (.stab Fp) :=
  (stab_will_iff τ t).mpr hb

/-! ## Depth 2, computed directly -/

/-- **`⊡F(⊡Fp)` holds at a seam iff the seam state is `b`.** At `a`, `stayA` refutes it; at `b`,
the next state is `b`, where `⊡Fp` holds. -/
theorem depth2_1_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔ (τ.state t).2 = true := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    by_contra hne
    have hfalse : (τ.state t).2 = false := Bool.eq_false_iff.mpr hne
    have hagree : τ.state t = (stayA (τ.state t).1 t).state t := by
      rw [stayA_state_t]
      exact Prod.ext rfl hfalse
    obtain ⟨s, -, hs, -⟩ := h _ hagree
    have hs' := (stab_will_iff _ s).mp hs
    rw [stayA_state] at hs'
    exact Bool.noConfusion hs'
  · intro hb σ hagree
    have h1 : (σ.state t).2 = true := by rw [← hagree]; exact hb
    exact ⟨t + 1, lt_add_one t, (stab_will_iff σ (t + 1)).mpr (next_true σ t h1),
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- **`⊡(Fp → ⊡Fp)` holds at a seam iff the seam state is `b`.** At `a`, `jumpB` makes `Fp` true
and `⊡Fp` false; at `b`, `⊡Fp` holds outright. -/
theorem depth2_2_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔ (τ.state t).2 = true := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    by_contra hne
    have hfalse : (τ.state t).2 = false := Bool.eq_false_iff.mpr hne
    have hagree : τ.state t = (jumpB (τ.state t).1 t).state t := by
      rw [jumpB_state_t]
      exact Prod.ext rfl hfalse
    have hFp : PlusTruthAt Mg (jumpB (τ.state t).1 t) t Fp :=
      ⟨t + 1, lt_add_one t, jumpB_state_succ _ t,
        fun r _ _ => PlusTruth.top_true (M := Mg) (τ := jumpB (τ.state t).1 t) (t := r)⟩
    have hstab := (stab_will_iff _ t).mp (h _ hagree hFp)
    rw [jumpB_state_t] at hstab
    exact Bool.noConfusion hstab
  · intro hb σ hagree _
    exact (stab_will_iff σ t).mpr (by rw [← hagree]; exact hb)

/-- Both depth-2 values at a seam state `a`: False, False. -/
theorem depth2_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (ha : (τ.state t).2 = false) :
    ¬ PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ∧
      ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) := by
  rw [depth2_1_iff, depth2_2_iff, ha]
  exact ⟨fun h => Bool.noConfusion h, fun h => Bool.noConfusion h⟩

/-- Both depth-2 values at a seam state `b`: True, True. -/
theorem depth2_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = true) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ∧
      PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) :=
  ⟨(depth2_1_iff τ t).mpr hb, (depth2_2_iff τ t).mpr hb⟩

/-! ## Depth 2, computed through the strata -/

/-- The fresh atom naming `⊡Fp`. -/
abbrev qAtom (e : Encoding) : Atom := e.ι (.inr Fp)

/-- The encoded copy of `p`. -/
abbrev pAtom (e : Encoding) : Atom := e.ι (.inl pa)

/-- **The fresh atom reads the depth-1 stratum.** `⊡Fp` at `(σ, s)` iff the atomized model's
valuation of `qAtom e` at the state `σ.state s` — the `inr` clause of `TaskModel.atomModel`,
transported to the present seam by `stab_state_only`. -/
theorem stab_fp_iff_fresh (e : Encoding) (σ : WorldHistory Fg.toTaskFrame) (s : ℤ) :
    PlusTruthAt Mg σ s (.stab Fp) ↔ PlusTruthAt (Mg.atomModel e) σ s (.atom (qAtom e)) := by
  constructor
  · intro h
    exact Or.inr ⟨Fp, rfl, σ, s, rfl, h⟩
  · rintro (⟨p, hp, _⟩ | ⟨χ, hχ, τ', t', hτ', hστ⟩)
    · exact absurd (e.inj hp) Sum.inl_ne_inr
    · cases Sum.inr.inj (e.inj hχ)
      exact (stab_state_only Mg τ' σ t' s hτ' Fp).mp hστ

/-- The encoded `p` reads `p`: the `inl` clause of `TaskModel.atomModel`. -/
theorem atom_iff_fresh (e : Encoding) (σ : WorldHistory Fg.toTaskFrame) (s : ℤ) :
    PlusTruthAt Mg σ s (.atom pa) ↔ PlusTruthAt (Mg.atomModel e) σ s (.atom (pAtom e)) := by
  constructor
  · intro h
    exact Or.inl ⟨pa, rfl, h⟩
  · rintro (⟨p, hp, hv⟩ | ⟨χ, hχ, _⟩)
    · cases Sum.inl.inj (e.inj hp)
      exact hv
    · exact absurd (e.inj hχ) Sum.inr_ne_inl

/-- **`⊡F(⊡Fp)` through the strata**: its value is the value of the depth-1 formula `⊡F q` over
the atomized model, `q` the fresh atom for `⊡Fp`. -/
theorem depth2_via_strata_1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t (.stab (someFuture (.atom (qAtom e)))) := by
  rw [PlusTruth.stab_iff, PlusTruth.stab_iff]
  constructor
  · intro h σ hσ
    obtain ⟨s, hts, hs, -⟩ := h σ hσ
    exact ⟨s, hts, (stab_fp_iff_fresh e σ s).mp hs,
      fun r _ _ => PlusTruth.top_true (M := Mg.atomModel e) (τ := σ) (t := r)⟩
  · intro h σ hσ
    obtain ⟨s, hts, hs, -⟩ := h σ hσ
    exact ⟨s, hts, (stab_fp_iff_fresh e σ s).mpr hs,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- **`⊡(Fp → ⊡Fp)` through the strata**: its value is the value of the depth-1 formula
`⊡(F p' → q)` over the atomized model, `p'` the encoded `p` and `q` the fresh atom for `⊡Fp`. -/
theorem depth2_via_strata_2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t
        (.stab (.imp (someFuture (.atom (pAtom e))) (.atom (qAtom e)))) := by
  rw [PlusTruth.stab_iff, PlusTruth.stab_iff]
  constructor
  · intro h σ hσ hF
    obtain ⟨s, hts, hs, -⟩ := hF
    exact (stab_fp_iff_fresh e σ t).mp (h σ hσ ⟨s, hts, (atom_iff_fresh e σ s).mpr hs,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩)
  · intro h σ hσ hF
    obtain ⟨s, hts, hs, -⟩ := hF
    exact (stab_fp_iff_fresh e σ t).mpr (h σ hσ ⟨s, hts, (atom_iff_fresh e σ s).mp hs,
      fun r _ _ => PlusTruth.top_true (M := Mg.atomModel e) (τ := σ) (t := r)⟩)

/-- The landed transfer lemma at the first formula: it atomizes the OUTER `⊡`, so the whole
depth-2 value is read through one depth-2 stratum atom. -/
theorem strata_is_atomize_1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (someFuture (.stab Fp)))) :=
  plusTruthAt_iff_atomize Mg e _ τ t

/-- The landed transfer lemma at the second formula. -/
theorem strata_is_atomize_2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (.imp Fp (.stab Fp)))) :=
  plusTruthAt_iff_atomize Mg e _ τ t

/-! ## The falsifier check -/

/-- **On this fixture each depth-2 `⊡`-value is a function of the depth-1 stratum**: two seams
with equal depth-1 values have equal depth-2 values, for both formulas. (In fact each depth-2
value coincides with the depth-1 value here.) A POSITIVE result on one fixture — see the header
for what it does not show. -/
theorem value_is_function_of_stratum (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ)
    (h : PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) :
    (PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
        PlusTruthAt Mg τ' t' (.stab (someFuture (.stab Fp)))) ∧
      (PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
        PlusTruthAt Mg τ' t' (.stab (.imp Fp (.stab Fp)))) := by
  rw [stab_will_iff, stab_will_iff] at h
  exact ⟨by rw [depth2_1_iff, depth2_1_iff]; exact h,
    by rw [depth2_2_iff, depth2_2_iff]; exact h⟩

end Probe711DepthTwo

/-! ## Axiom record -/

#print axioms Probe711DepthTwo.stab_will_iff
#print axioms Probe711DepthTwo.stab_will_at_a
#print axioms Probe711DepthTwo.stab_will_at_b
#print axioms Probe711DepthTwo.depth2_1_iff
#print axioms Probe711DepthTwo.depth2_2_iff
#print axioms Probe711DepthTwo.depth2_via_strata_1
#print axioms Probe711DepthTwo.depth2_via_strata_2
#print axioms Probe711DepthTwo.strata_is_atomize_1
#print axioms Probe711DepthTwo.value_is_function_of_stratum
