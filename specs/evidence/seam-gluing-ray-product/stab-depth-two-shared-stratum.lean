/-
Probe 739 (E2, probe iii): **the shared-stratum falsifier** — PROVISIONAL HEADER, completed in
Phase 4.

**Fixture.** Four states `a | b | c | d`, time-independent one-step relation with edges
`a→a, a→b, b→b, b→d, d→b, c→c`; `p` holds exactly at `b`. Two distinct states share the depth-1
stratum `⊡Fp` in both directions: `{a, c}` share False, `{b, d}` share True.
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.Conservativity

namespace Probe739SharedStratum

/-! ## The fixture -/

/-- The four-state carrier. -/
inductive S where
  | a | b | c | d
  deriving DecidableEq

instance : Fintype S := ⟨{.a, .b, .c, .d}, fun x => by cases x <;> simp⟩
instance : Finite S := Finite.of_fintype S
instance : Nonempty S := ⟨.a⟩

/-- The one-step graph: `a→a, a→b, b→b, b→d, d→b, c→c`. -/
def edge : S → S → Bool
  | .a, .a => true | .a, .b => true
  | .b, .b => true | .b, .d => true
  | .d, .b => true
  | .c, .c => true
  | _, _ => false

/-- The time-independent one-step relation. -/
def Rg : ℤ → S → S → Prop := fun _ u v => edge u v = true

/-- Forward seriality: every state has a successor (`a→a`, `b→b`, `c→c`, `d→b`). -/
theorem Rg_fwd : ∀ (t : ℤ) (w : S), ∃ u, Rg t w u := by
  intro _ w; cases w
  · exact ⟨.a, rfl⟩
  · exact ⟨.b, rfl⟩
  · exact ⟨.c, rfl⟩
  · exact ⟨.b, rfl⟩

/-- Backward seriality: every state has a predecessor (`a←a`, `b←a`, `c←c`, `d←b`). -/
theorem Rg_bwd : ∀ (t : ℤ) (w : S), ∃ v, Rg (t - 1) v w := by
  intro _ w; cases w
  · exact ⟨.a, rfl⟩
  · exact ⟨.a, rfl⟩
  · exact ⟨.c, rfl⟩
  · exact ⟨.b, rfl⟩

/-- The fixture frame, regular by construction. -/
def Fg : FrameOver intOrder := FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd

instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd

/-- The distinguished atom: `p` holds exactly at `b`. -/
def pa : Atom := ⟨"p", none⟩

/-- The fixture model: `p` holds exactly at `b`. -/
def Mg : TaskModel Fg.toTaskFrame where
  valuation q _ := q.2 = .b

/-- `Fp`, the forward depth-0 core. -/
abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- `Pp`, the backward depth-0 core. -/
abbrev Pp : PlusFormula := somePast (.atom pa)

/-! ## One step along a history, and the neighbour tables -/

/-- One step along any history: time advances by one and `Rg` relates the states. -/
theorem step_succ (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    (σ.path (t + 1)).1 = (σ.path t).1 + 1 ∧ Rg (σ.path t).1 (σ.path t).2 (σ.path (t + 1)).2 :=
  (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mp (σ.isStepPath t)

theorem succ_of_a : ∀ v : S, edge .a v = true → v = .a ∨ v = .b := by decide
theorem succ_of_b : ∀ v : S, edge .b v = true → v = .b ∨ v = .d := by decide
theorem succ_of_c : ∀ v : S, edge .c v = true → v = .c := by decide
theorem succ_of_d : ∀ v : S, edge .d v = true → v = .b := by decide
theorem pred_of_a : ∀ u : S, edge u .a = true → u = .a := by decide
theorem pred_of_c : ∀ u : S, edge u .c = true → u = .c := by decide
theorem pred_of_d : ∀ u : S, edge u .d = true → u = .b := by decide

theorem next_of_a (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .a) :
    (σ.state (t + 1)).2 = .a ∨ (σ.state (t + 1)).2 = .b := by
  have h1 := (step_succ σ t).2
  have h' : (σ.path t).2 = .a := h
  rw [h'] at h1
  exact succ_of_a _ h1

theorem next_of_b (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .b) :
    (σ.state (t + 1)).2 = .b ∨ (σ.state (t + 1)).2 = .d := by
  have h1 := (step_succ σ t).2
  have h' : (σ.path t).2 = .b := h
  rw [h'] at h1
  exact succ_of_b _ h1

theorem next_of_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .c) :
    (σ.state (t + 1)).2 = .c := by
  have h1 := (step_succ σ t).2
  have h' : (σ.path t).2 = .c := h
  rw [h'] at h1
  exact succ_of_c _ h1

theorem next_of_d (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .d) :
    (σ.state (t + 1)).2 = .b := by
  have h1 := (step_succ σ t).2
  have h' : (σ.path t).2 = .d := h
  rw [h'] at h1
  exact succ_of_d _ h1

theorem prev_of_a (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .a) :
    (σ.state (t - 1)).2 = .a := by
  have h1 := (step_succ σ (t - 1)).2
  rw [show t - 1 + 1 = t by ring] at h1
  have h' : (σ.path t).2 = .a := h
  rw [h'] at h1
  exact pred_of_a _ h1

theorem prev_of_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .c) :
    (σ.state (t - 1)).2 = .c := by
  have h1 := (step_succ σ (t - 1)).2
  rw [show t - 1 + 1 = t by ring] at h1
  have h' : (σ.path t).2 = .c := h
  rw [h'] at h1
  exact pred_of_c _ h1

theorem prev_of_d (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .d) :
    (σ.state (t - 1)).2 = .b := by
  have h1 := (step_succ σ (t - 1)).2
  rw [show t - 1 + 1 = t by ring] at h1
  have h' : (σ.path t).2 = .d := h
  rw [h'] at h1
  exact pred_of_d _ h1

/-! ## Generic closure lemmas: a state whose only neighbour is itself is never left -/

/-- Forward closure: if `w`'s only successor is `w`, a history at `w` stays at `w` forever. -/
theorem stays_fwd (w : S) (hw : ∀ v, edge w v = true → v = w) (σ : WorldHistory Fg.toTaskFrame)
    (t : ℤ) (h : (σ.state t).2 = w) : ∀ s, t ≤ s → (σ.state s).2 = w := by
  intro s hs
  induction s, hs using Int.leInduction with
  | base => exact h
  | succ n _ ih =>
    have h1 := (step_succ σ n).2
    have h' : (σ.path n).2 = w := ih
    rw [h'] at h1
    exact hw _ h1

/-- Backward closure: if `w`'s only predecessor is `w`, a history at `w` was at `w` forever. -/
theorem stays_bwd (w : S) (hw : ∀ u, edge u w = true → u = w) (σ : WorldHistory Fg.toTaskFrame)
    (t : ℤ) (h : (σ.state t).2 = w) : ∀ s, s ≤ t → (σ.state s).2 = w := by
  intro s hs
  induction s, hs using Int.leInductionDown with
  | base => exact h
  | pred n _ ih =>
    have h1 := (step_succ σ (n - 1)).2
    rw [show n - 1 + 1 = n by ring] at h1
    have h' : (σ.path n).2 = w := ih
    rw [h'] at h1
    exact hw _ h1

/-- `c` is a forward sink: a history at `c` stays at `c`. -/
theorem stays_fwd_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .c) :
    ∀ s, t ≤ s → (σ.state s).2 = .c :=
  stays_fwd .c succ_of_c σ t h

/-- `c` is a backward sink: a history at `c` was always at `c`. -/
theorem stays_bwd_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .c) :
    ∀ s, s ≤ t → (σ.state s).2 = .c :=
  stays_bwd .c pred_of_c σ t h

/-- `a` is a backward sink: a history at `a` was always at `a`. -/
theorem stays_bwd_a (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .a) :
    ∀ s, s ≤ t → (σ.state s).2 = .a :=
  stays_bwd .a pred_of_a σ t h

/-! ## Constructed histories -/

/-- The history that stays at a self-looping state `w` forever, placed so that it passes
through `(c, w)` at time `t`. -/
noncomputable def stay (w : S) (hw : edge w w = true) (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), w)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, hw⟩
    change z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem stay_state (w : S) (hw : edge w w = true) (c t z : ℤ) :
    (stay w hw c t).state z = (z + (c - t), w) := rfl

theorem stay_state_t (w : S) (hw : edge w w = true) (c t : ℤ) :
    (stay w hw c t).state t = (c, w) := by
  rw [stay_state]
  congr 1
  ring

/-- The history that stays at `a` forever. -/
noncomputable def stayA (c t : ℤ) : WorldHistory Fg.toTaskFrame := stay .a rfl c t

theorem stayA_state (c t z : ℤ) : (stayA c t).state z = (z + (c - t), .a) := rfl

theorem stayA_state_t (c t : ℤ) : (stayA c t).state t = (c, .a) := stay_state_t .a rfl c t

/-- The history that stays at `c` forever. -/
noncomputable def stayC (c t : ℤ) : WorldHistory Fg.toTaskFrame := stay .c rfl c t

theorem stayC_state (c t z : ℤ) : (stayC c t).state z = (z + (c - t), .c) := rfl

theorem stayC_state_t (c t : ℤ) : (stayC c t).state t = (c, .c) := stay_state_t .c rfl c t

/-- State function of `jumpB`: `a` through `t`, `b` from `t + 1`. -/
def jumpBState (t z : ℤ) : S := if t < z then .b else .a

theorem jumpBState_edge (t z : ℤ) : edge (jumpBState t z) (jumpBState t (z + 1)) = true := by
  unfold jumpBState
  split_ifs <;> first | rfl | omega

/-- The history that sits at `a` up to time `t` and jumps to `b` at `t + 1`, staying there. -/
noncomputable def jumpB (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), jumpBState t z)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, jumpBState_edge t z⟩
    change z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem jumpB_state (c t z : ℤ) : (jumpB c t).state z = (z + (c - t), jumpBState t z) := rfl

theorem jumpB_state_t (c t : ℤ) : (jumpB c t).state t = (c, .a) := by
  rw [jumpB_state]
  simp only [jumpBState, lt_irrefl, if_false]
  congr 1
  ring

theorem jumpB_state_succ (c t : ℤ) : ((jumpB c t).state (t + 1)).2 = .b := by
  rw [jumpB_state]
  change jumpBState t (t + 1) = S.b
  unfold jumpBState
  rw [if_pos (lt_add_one t)]

/-- State function of `fromA`: `a` before `t`, `b` from `t`. -/
def fromAState (t z : ℤ) : S := if z < t then .a else .b

theorem fromAState_edge (t z : ℤ) : edge (fromAState t z) (fromAState t (z + 1)) = true := by
  unfold fromAState
  split_ifs <;> first | rfl | omega

/-- The history that sits at `a` before `t` and at `b` from `t` on. -/
noncomputable def fromA (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), fromAState t z)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, fromAState_edge t z⟩
    change z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem fromA_state (c t z : ℤ) : (fromA c t).state z = (z + (c - t), fromAState t z) := rfl

theorem fromA_state_t (c t : ℤ) : (fromA c t).state t = (c, .b) := by
  rw [fromA_state]
  simp only [fromAState, lt_irrefl, if_false]
  congr 1
  ring

/-- Before `t`, `fromA` is at `a`. -/
theorem fromA_state_lt (c t s : ℤ) (hs : s < t) : ((fromA c t).state s).2 = .a := by
  rw [fromA_state]
  change fromAState t s = S.a
  unfold fromAState
  rw [if_pos hs]

/-- State function of `viaD`: `a` before `t - 1`, `b` at `t - 1`, `d` at `t`, `b` after. -/
def viaDState (t z : ℤ) : S :=
  if z < t - 1 then .a else if z = t - 1 then .b else if z = t then .d else .b

theorem viaDState_edge (t z : ℤ) : edge (viaDState t z) (viaDState t (z + 1)) = true := by
  unfold viaDState
  split_ifs <;> first | rfl | omega

/-- The history that reaches `d` at time `t` through `b` at `t - 1`, from `a` before. -/
noncomputable def viaD (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), viaDState t z)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, viaDState_edge t z⟩
    change z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem viaD_state (c t z : ℤ) : (viaD c t).state z = (z + (c - t), viaDState t z) := rfl

theorem viaD_state_t (c t : ℤ) : (viaD c t).state t = (c, .d) := by
  rw [viaD_state]
  have h1 : ¬ t < t - 1 := by omega
  have h2 : ¬ t = t - 1 := by omega
  simp only [viaDState, h1, h2, if_false, if_true]
  congr 1
  ring

/-! ## Depth 1: the two strata, each with a genuinely shared class -/

/-- At a seam state `a`, `⊡(Fp)` fails: `stayA` never sees `p`. -/
theorem not_stab_will_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ)
    (ha : (τ.state t).2 = .a) : ¬ PlusTruthAt Mg τ t (.stab Fp) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayA (τ.state t).1 t).state t := by
    rw [stayA_state_t]
    exact Prod.ext rfl ha
  obtain ⟨s, -, hp, -⟩ := h _ hagree
  have hp' : ((stayA (τ.state t).1 t).state s).2 = .b := hp
  rw [stayA_state] at hp'
  exact S.noConfusion hp'

/-- At a seam state `c`, `⊡(Fp)` fails: `stayC` never sees `p`. -/
theorem not_stab_will_at_c (τ : WorldHistory Fg.toTaskFrame) (t : ℤ)
    (hc : (τ.state t).2 = .c) : ¬ PlusTruthAt Mg τ t (.stab Fp) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayC (τ.state t).1 t).state t := by
    rw [stayC_state_t]
    exact Prod.ext rfl hc
  obtain ⟨s, -, hp, -⟩ := h _ hagree
  have hp' : ((stayC (τ.state t).1 t).state s).2 = .b := hp
  rw [stayC_state] at hp'
  exact S.noConfusion hp'

/-- At a seam state `b`, `⊡(Fp)` holds: the next state is `b` or `d`, and `d`'s next is `b`. -/
theorem stab_will_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    PlusTruthAt Mg τ t (.stab Fp) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .b := by rw [← hagree]; exact hb
  rcases next_of_b σ t h1 with h2 | h2
  · exact ⟨t + 1, lt_add_one t, h2, fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩
  · exact ⟨t + 1 + 1, lt_trans (lt_add_one t) (lt_add_one _), next_of_d σ (t + 1) h2,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- At a seam state `d`, `⊡(Fp)` holds: the next state is `b`. -/
theorem stab_will_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab Fp) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .d := by rw [← hagree]; exact hd
  exact ⟨t + 1, lt_add_one t, next_of_d σ t h1,
    fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- **`⊡(Fp)` holds at a seam iff the seam state is `b` or `d`** — the shared classes are
`{a, c}` (False) and `{b, d}` (True). -/
theorem stab_will_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab Fp) ↔ ((τ.state t).2 = S.b ∨ (τ.state t).2 = S.d) := by
  constructor
  · intro h
    rcases hs : (τ.state t).2 with _ | _ | _ | _
    · exact absurd h (not_stab_will_at_a τ t hs)
    · exact Or.inl rfl
    · exact absurd h (not_stab_will_at_c τ t hs)
    · exact Or.inr rfl
  · rintro (hb | hd)
    · exact stab_will_at_b τ t hb
    · exact stab_will_at_d τ t hd

/-- At a seam state `d`, `⊡(Pp)` holds: the previous state is `b`. -/
theorem stab_past_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab Pp) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .d := by rw [← hagree]; exact hd
  exact ⟨t - 1, sub_one_lt t, prev_of_d σ t h1,
    fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- At a seam state `a`, `⊡(Pp)` fails: `stayA` never saw `p`. -/
theorem not_stab_past_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ)
    (ha : (τ.state t).2 = .a) : ¬ PlusTruthAt Mg τ t (.stab Pp) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayA (τ.state t).1 t).state t := by
    rw [stayA_state_t]
    exact Prod.ext rfl ha
  obtain ⟨s, -, hp, -⟩ := h _ hagree
  have hp' : ((stayA (τ.state t).1 t).state s).2 = .b := hp
  rw [stayA_state] at hp'
  exact S.noConfusion hp'

/-- At a seam state `c`, `⊡(Pp)` fails: `stayC` never saw `p`. -/
theorem not_stab_past_at_c (τ : WorldHistory Fg.toTaskFrame) (t : ℤ)
    (hc : (τ.state t).2 = .c) : ¬ PlusTruthAt Mg τ t (.stab Pp) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayC (τ.state t).1 t).state t := by
    rw [stayC_state_t]
    exact Prod.ext rfl hc
  obtain ⟨s, -, hp, -⟩ := h _ hagree
  have hp' : ((stayC (τ.state t).1 t).state s).2 = .b := hp
  rw [stayC_state] at hp'
  exact S.noConfusion hp'

/-- At a seam state `b`, `⊡(Pp)` fails: `fromA` was at `a` before `t`. -/
theorem not_stab_past_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ)
    (hb : (τ.state t).2 = .b) : ¬ PlusTruthAt Mg τ t (.stab Pp) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (fromA (τ.state t).1 t).state t := by
    rw [fromA_state_t]
    exact Prod.ext rfl hb
  obtain ⟨s, hs, hp, -⟩ := h _ hagree
  have hp' : ((fromA (τ.state t).1 t).state s).2 = .b := hp
  rw [fromA_state_lt _ t s hs] at hp'
  exact S.noConfusion hp'

/-- **`⊡(Pp)` holds at a seam iff the seam state is `d`.** -/
theorem stab_past_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab Pp) ↔ (τ.state t).2 = S.d := by
  constructor
  · intro h
    rcases hs : (τ.state t).2 with _ | _ | _ | _
    · exact absurd h (not_stab_past_at_a τ t hs)
    · exact absurd h (not_stab_past_at_b τ t hs)
    · exact absurd h (not_stab_past_at_c τ t hs)
    · rfl
  · intro hd
    exact stab_past_at_d τ t hd

end Probe739SharedStratum

-- temporary Phase 1 axiom check; the permanent foot is written in Phase 4
#print axioms Probe739SharedStratum.stab_will_iff
#print axioms Probe739SharedStratum.stab_past_iff
