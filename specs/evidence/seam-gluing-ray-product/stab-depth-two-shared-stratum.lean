/-
Probe 739 (E2, probe iii): **the shared-stratum falsifier** — on a fixture where two DISTINCT
states genuinely share a depth-1 stratum, is the `⊡`-value of a depth-2 formula a function of
that stratum? The real test the landed `stab-depth-two-probe.lean` names as its follow-up.

**The falsifier sentence this probe is defined from.** The ranking's falsifier for the
stratification route reads: *a `⊡`-depth-2 formula whose `⊡`-value at a class is not a function
of the class's summary state*. The landed probe answered it in the affirmative on a two-state
fixture, but there every stratum value has exactly one state, so no two distinct seams with equal
depth-1 strata exist to compare and `value_is_function_of_stratum` is vacuously easy. This probe
builds a fixture with two shared classes, computes FIVE depth-2 shapes — the landed two, the two
MIXED shapes `⊡(Fp → ⊡Pp)` / `⊡(Pp → ⊡Fp)` the landed header leaves out, and the past mirror
`⊡P(⊡Fp)` — twice each (directly, and through the strata), and asks the falsifier's question
non-vacuously on each class. The answer is MIXED, and the refutations are the headline.

**Fixture.** Four states `a | b | c | d`, time-independent one-step relation `Rg _ u v :=
edge u v = true` with the six edges `a→a, a→b, b→b, b→d, d→b, c→c`. Bi-serial — PROVED, not
assumed, as the named theorems `Rg_fwd` (successors `a→a, b→b, c→c, d→b`) and `Rg_bwd`
(predecessors `a←a, b←a, c←c, d←b`) passed to `FrameOver.ofSlicedStep`, so the frame is regular.
`p` holds exactly at `b`. The sub-fixture `{a, b}` is literally the landed fixture; `c` is an
isolated sink (both directions); `d` is a post-`b` state whose only predecessor is the `p`-state.

**What is established (machine-checked).**

1. *The two depth-1 strata, each with a genuinely shared class.* `⊡Fp` holds at a seam iff the
   state is `b` or `d` (`stab_will_iff`), so `{a, c}` share False and `{b, d}` share True;
   `⊡Pp` holds iff the state is `d` (`stab_past_iff`). The sharing is certified by exhibited
   seams: `shared_false_stratum` (`stayA` at `a` vs `stayC` at `c`) and `shared_true_stratum`
   (`fromA` at `b` vs `viaD` at `d`), two distinct states per class with equal `⊡Fp` values.
2. *The five depth-2 values, computed directly* (`depth2_S1_iff`, `depth2_S2_iff`,
   `depth2_M1_iff`, `depth2_M2_true`, `depth2_S1past_iff`), reproducing this table, `T`/`F` at
   `a b c d`:

   | shape                                   | a | b | c | d |
   |-----------------------------------------|---|---|---|---|
   | `⊡Fp` (depth-1 stratum)                 | F | T | F | T |
   | `⊡Pp`                                   | F | F | F | T |
   | S1  `⊡F(⊡Fp)`                           | F | T | F | T |
   | S2  `⊡(Fp → ⊡Fp)` (the landed shape)    | F | T | T | T |
   | M1  `⊡(Fp → ⊡Pp)` (mixed)               | F | F | T | T |
   | M2  `⊡(Pp → ⊡Fp)` (mixed)               | T | T | T | T |
   | S1' `⊡P(⊡Fp)` (past mirror of S1)       | F | F | F | T |
   | `⊡(Pp → ⊡Pp)` (extra, unpinned)         | T | F | T | T |
   | `⊡P(⊡Pp)` (extra, unpinned)             | F | F | F | F |

   Every refuting cell is witnessed by a constructed history: S2 at `a` by `jumpB` (`Fp` True,
   `⊡Fp` False) against the vacuous True at `c` (`not_Fp_at_c`, by the forward-closure induction
   `stays_fwd`); M1 at `b` by instantiating the outer `∀ σ` at the seam itself (`Fp` True,
   `⊡Pp` False along `fromA`) against True at `d`; S1' at `b` by `fromA` (only `a` behind it)
   against True at `d` (`prev_of_d`).
3. *The five values computed through the strata* (`depth2_via_strata_S1/_S2/_M1/_M2/_S1past`):
   each depth-2 value equals the value of the depth-1 formula obtained by replacing the inner
   `⊡Fp` / `⊡Pp` by the fresh atoms `qAtom e` / `rAtom e` and `p` by `pAtom e`, over the
   atomized model `Mg.atomModel e`, whose fresh-atom valuations ARE the depth-1 strata
   (`stab_fp_iff_fresh`, `stab_pp_iff_fresh`, through `stab_state_only`). The landed transfer
   lemma `plusTruthAt_iff_atomize` is cited at each shape (`strata_is_atomize_*`); as the landed
   header notes, it atomizes the OUTER `⊡`, reading the whole depth-2 formula through one
   depth-2 stratum atom, while the `via_strata` theorems read the INNER `⊡` through its
   depth-1 stratum. The two readings agree here exactly as on the landed fixture — both are
   biconditionals against the same direct value, and the `via_strata` proofs cite no fixture
   fact — so there is no divergence to record.
4. *The falsifier's question answered in the affirmative, NON-VACUOUSLY, where it holds.*
   `value_is_function_of_stratum_S1`: S1 is a function of the depth-1 stratum on both shared
   classes, with the landed hypothesis shape `⊡Fp ↔ ⊡Fp` and real content now (two distinct
   states per class). `value_is_function_of_stratum_M2`: M2 is constant. `value_is_function_of_
   stratum_S2_on_true_class`: the landed shape S2 is a function of the stratum on `{b, d}`.
   This is the non-vacuous upgrade of E2 the landed header asked for — for these shapes.
5. *The falsifier's question REFUTED, machine-checked, where it fails* — the headline.
   `not_function_of_stratum_S2`: two seams with equal `⊡Fp` (both False, at `a` and `c`) and
   DIFFERENT S2 values — the landed shape `⊡(Fp → ⊡Fp)` is NOT a function of the depth-1
   stratum on the shared-False class. `not_function_of_stratum_M1`: on `{b, d}` (both `⊡Fp`
   True) the mixed shape `⊡(Fp → ⊡Pp)` is False at `b`, True at `d`. `not_function_of_
   stratum_S1past`: on `{b, d}`, `⊡P(⊡Fp)` is False at `b`, True at `d`. The literal check of
   the landed probe (`Probe711DepthTwo.value_is_function_of_stratum`, transplanted) is refuted
   on a fixture with a genuinely shared `⊡Fp` class.

**What is NOT established.** The refutation kills exactly one reading: that a depth-2 `⊡`-value
is determined by the ONE BIT `⊡Fp` at the state — the reading the landed theorem's hypothesis
`⊡Fp ↔ ⊡Fp` encodes, and the one a summary that keeps one label per DEPTH would rely on. It does
NOT touch `stab_state_only` (every `⊡`-value is a function of the state), nor the
closure-indexed alphabet Probe 718 licenses (one label per `⊡`-subformula `χ` of the closure,
`stratum M χ w`): the depth-2 value of `⊡ψ` is the depth-1 value of `⊡(atomize ψ)` over the
atomized model, which IS a function of the state, and that is item 3 above. What the refutation
shows is what the per-state label must at least carry: on this fixture the labels `⊡Fp`, `⊡Pp`
and `⊡¬Fp` are pairwise independent (`a`: F F F; `b`: T F F; `c`: F F T; `d`: T T F) and all
three are needed to read the five shapes — S2 is `q ∨ ⊡¬Fp`, M1 is `r ∨ ⊡¬Fp`, S1' needs the
depth-1 label of the NEW formula `⊡P q` over the atomized model — including BACKWARD labels for
a forward-looking target (M1). Consequence for the finite per-time alphabet: it survives, but it
must be the closure-indexed alphabet, never one bit per depth; a summary that reads depth 2 off
the target's own inner `⊡`-subformula alone is dead. "Function of the FULL closure labelling" is
not proved here either — only these shapes on this one fixture are computed. The fixture is
time-independent (every time slice is the same four states), so nothing is said about width,
period, or per-time summaries over many states. No decidability, no complexity bound, nothing
about devices — the landed probe's three exclusions transfer unchanged. The landed probe remains
correct about its own two-state fixture; both results stand together.

**Axiom record.** Every pinned theorem (the 29 in the foot) is within `[propext,
Classical.choice, Quot.sound]`; no `sorryAx`. The two bi-seriality theorems `Rg_fwd`/`Rg_bwd`
use `[propext]` alone; the other 27 use all three. `Classical.choice` enters through
`FrameOver.worldHistoryOfStepPath` (the constructed histories) and the frame constructor.

**Compile line.**
`lake env lean specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean`
(wired into `scripts/check-evidence-probes.sh`).
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

/-! ## Depth-0 facts the sinks force: no `p` ahead of `c`, none behind `a` or `c` -/

/-- No history through `c` ever sees `p` later: `c` is a forward sink. -/
theorem not_Fp_at_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hc : (σ.state t).2 = .c) :
    ¬ PlusTruthAt Mg σ t Fp := by
  rintro ⟨s, hts, hp, -⟩
  have hp' : (σ.state s).2 = .b := hp
  rw [stays_fwd_c σ t hc s hts.le] at hp'
  exact S.noConfusion hp'

/-- No history through `a` ever saw `p` earlier: `a` is a backward sink. -/
theorem not_Pp_at_a (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (ha : (σ.state t).2 = .a) :
    ¬ PlusTruthAt Mg σ t Pp := by
  rintro ⟨s, hst, hp, -⟩
  have hp' : (σ.state s).2 = .b := hp
  rw [stays_bwd_a σ t ha s hst.le] at hp'
  exact S.noConfusion hp'

/-- No history through `c` ever saw `p` earlier: `c` is a backward sink. -/
theorem not_Pp_at_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hc : (σ.state t).2 = .c) :
    ¬ PlusTruthAt Mg σ t Pp := by
  rintro ⟨s, hst, hp, -⟩
  have hp' : (σ.state s).2 = .b := hp
  rw [stays_bwd_c σ t hc s hst.le] at hp'
  exact S.noConfusion hp'

/-! ## Depth 2, computed directly

Value table (`T`/`F` at `a b c d`): S1 `F T F T`, S2 `F T T T`, M1 `F F T T`, M2 `T T T T`,
S1' `F F F T`. -/

/-! ### S1: `⊡F(⊡Fp)` — `F T F T` -/

/-- S1 fails at `a`: along `stayA` every future state is `a`, where `⊡Fp` is False. -/
theorem not_S1_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (ha : (τ.state t).2 = .a) :
    ¬ PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayA (τ.state t).1 t).state t := by
    rw [stayA_state_t]
    exact Prod.ext rfl ha
  obtain ⟨s, -, hs, -⟩ := h _ hagree
  have hs' := (stab_will_iff _ s).mp hs
  rw [stayA_state] at hs'
  rcases hs' with h' | h' <;> exact S.noConfusion h'

/-- S1 fails at `c`: along `stayC` every future state is `c`, where `⊡Fp` is False. -/
theorem not_S1_at_c (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hc : (τ.state t).2 = .c) :
    ¬ PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayC (τ.state t).1 t).state t := by
    rw [stayC_state_t]
    exact Prod.ext rfl hc
  obtain ⟨s, -, hs, -⟩ := h _ hagree
  have hs' := (stab_will_iff _ s).mp hs
  rw [stayC_state] at hs'
  rcases hs' with h' | h' <;> exact S.noConfusion h'

/-- S1 holds at `b`: the next state is `b` or `d`, and `⊡Fp` holds at both. -/
theorem S1_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .b := by rw [← hagree]; exact hb
  rcases next_of_b σ t h1 with h2 | h2
  · exact ⟨t + 1, lt_add_one t, stab_will_at_b σ (t + 1) h2,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩
  · exact ⟨t + 1, lt_add_one t, stab_will_at_d σ (t + 1) h2,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- S1 holds at `d`: the next state is `b`, where `⊡Fp` holds. -/
theorem S1_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .d := by rw [← hagree]; exact hd
  exact ⟨t + 1, lt_add_one t, stab_will_at_b σ (t + 1) (next_of_d σ t h1),
    fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- **S1 `⊡F(⊡Fp)` holds at a seam iff the state is `b` or `d`** — the same partition as the
depth-1 stratum, on both shared classes. -/
theorem depth2_S1_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      ((τ.state t).2 = S.b ∨ (τ.state t).2 = S.d) := by
  constructor
  · intro h
    rcases hs : (τ.state t).2 with _ | _ | _ | _
    · exact absurd h (not_S1_at_a τ t hs)
    · exact Or.inl rfl
    · exact absurd h (not_S1_at_c τ t hs)
    · exact Or.inr rfl
  · rintro (hb | hd)
    · exact S1_at_b τ t hb
    · exact S1_at_d τ t hd

/-! ### S2: `⊡(Fp → ⊡Fp)`, the landed shape — `F T T T` -/

/-- S2 fails at `a`: along `jumpB`, `Fp` is True (`b` at `t + 1`) but `⊡Fp` at `a` is False. -/
theorem not_S2_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (ha : (τ.state t).2 = .a) :
    ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (jumpB (τ.state t).1 t).state t := by
    rw [jumpB_state_t]
    exact Prod.ext rfl ha
  have hFp : PlusTruthAt Mg (jumpB (τ.state t).1 t) t Fp :=
    ⟨t + 1, lt_add_one t, jumpB_state_succ _ t,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := jumpB (τ.state t).1 t) (t := r)⟩
  have hstab := (stab_will_iff _ t).mp (h _ hagree hFp)
  rw [jumpB_state_t] at hstab
  rcases hstab with h' | h' <;> exact S.noConfusion h'

/-- S2 holds at `b` outright: `⊡Fp` holds there. -/
theorem S2_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree _
  exact stab_will_at_b σ t (by rw [← hagree]; exact hb)

/-- S2 holds at `c` VACUOUSLY: no history through `c` ever sees `p`, so `Fp` is False. This is
the cell that separates `c` from `a` inside the shared-False class. -/
theorem S2_at_c (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hc : (τ.state t).2 = .c) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree hF
  exact absurd hF (not_Fp_at_c σ t (by rw [← hagree]; exact hc))

/-- S2 holds at `d` outright: `⊡Fp` holds there. -/
theorem S2_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree _
  exact stab_will_at_d σ t (by rw [← hagree]; exact hd)

/-- **S2 `⊡(Fp → ⊡Fp)` holds at a seam iff the state is not `a`.** On the shared-False class
`{a, c}` it is False at `a` and True at `c`: the landed shape is NOT a function of the depth-1
stratum here. -/
theorem depth2_S2_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔ (τ.state t).2 ≠ S.a := by
  constructor
  · intro h ha
    exact not_S2_at_a τ t ha h
  · intro hne
    rcases hs : (τ.state t).2 with _ | _ | _ | _
    · exact absurd hs hne
    · exact S2_at_b τ t hs
    · exact S2_at_c τ t hs
    · exact S2_at_d τ t hs

/-! ### M1: `⊡(Fp → ⊡Pp)`, mixed — `F F T T` -/

/-- M1 fails at `a`: along `jumpB`, `Fp` is True but `⊡Pp` at `a` is False. -/
theorem not_M1_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (ha : (τ.state t).2 = .a) :
    ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (jumpB (τ.state t).1 t).state t := by
    rw [jumpB_state_t]
    exact Prod.ext rfl ha
  have hFp : PlusTruthAt Mg (jumpB (τ.state t).1 t) t Fp :=
    ⟨t + 1, lt_add_one t, jumpB_state_succ _ t,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := jumpB (τ.state t).1 t) (t := r)⟩
  have hstab := (stab_past_iff _ t).mp (h _ hagree hFp)
  rw [jumpB_state_t] at hstab
  exact S.noConfusion hstab

/-- M1 fails at `b`: instantiate the outer `∀ σ` at `τ` itself — `Fp` holds there (every
history from `b` reaches `p`) but `⊡Pp` at `b` is False (`fromA` has no `p` behind it). -/
theorem not_M1_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hFp : PlusTruthAt Mg τ t Fp := (stab_will_at_b τ t hb) τ rfl
  exact not_stab_past_at_b τ t hb (h τ rfl hFp)

/-- M1 holds at `c` vacuously: `Fp` is False at `c`. -/
theorem M1_at_c (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hc : (τ.state t).2 = .c) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree hF
  exact absurd hF (not_Fp_at_c σ t (by rw [← hagree]; exact hc))

/-- M1 holds at `d` outright: `⊡Pp` holds there. -/
theorem M1_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree _
  exact stab_past_at_d σ t (by rw [← hagree]; exact hd)

/-- **M1 `⊡(Fp → ⊡Pp)` holds at a seam iff the state is `c` or `d`.** It splits BOTH shared
classes: `a` F vs `c` T, and `b` F vs `d` T. -/
theorem depth2_M1_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ↔
      ((τ.state t).2 = S.c ∨ (τ.state t).2 = S.d) := by
  constructor
  · intro h
    rcases hs : (τ.state t).2 with _ | _ | _ | _
    · exact absurd h (not_M1_at_a τ t hs)
    · exact absurd h (not_M1_at_b τ t hs)
    · exact Or.inl rfl
    · exact Or.inr rfl
  · rintro (hc | hd)
    · exact M1_at_c τ t hc
    · exact M1_at_d τ t hd

/-! ### M2: `⊡(Pp → ⊡Fp)`, mixed — `T T T T` -/

/-- **M2 `⊡(Pp → ⊡Fp)` holds at every seam**: at `b`, `d` because `⊡Fp` holds; at `a`, `c`
vacuously because no history through a backward sink has `p` in its past. -/
theorem depth2_M2_true (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro σ _ hP
  rcases hs : (σ.state t).2 with _ | _ | _ | _
  · exact absurd hP (not_Pp_at_a σ t hs)
  · exact stab_will_at_b σ t hs
  · exact absurd hP (not_Pp_at_c σ t hs)
  · exact stab_will_at_d σ t hs

/-! ### S1': `⊡P(⊡Fp)`, the past mirror of S1 — `F F F T` -/

/-- S1' fails at `a`: along `stayA` every past state is `a`, where `⊡Fp` is False. -/
theorem not_S1past_at_a (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (ha : (τ.state t).2 = .a) :
    ¬ PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayA (τ.state t).1 t).state t := by
    rw [stayA_state_t]
    exact Prod.ext rfl ha
  obtain ⟨s, -, hs, -⟩ := h _ hagree
  have hs' := (stab_will_iff _ s).mp hs
  rw [stayA_state] at hs'
  rcases hs' with h' | h' <;> exact S.noConfusion h'

/-- S1' fails at `b`: along `fromA` every past state is `a`, where `⊡Fp` is False. This is the
cell that separates `b` from `d` inside the shared-True class. -/
theorem not_S1past_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    ¬ PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (fromA (τ.state t).1 t).state t := by
    rw [fromA_state_t]
    exact Prod.ext rfl hb
  obtain ⟨s, hst, hs, -⟩ := h _ hagree
  have hs' := (stab_will_iff _ s).mp hs
  rw [fromA_state_lt _ t s hst] at hs'
  rcases hs' with h' | h' <;> exact S.noConfusion h'

/-- S1' fails at `c`: along `stayC` every past state is `c`, where `⊡Fp` is False. -/
theorem not_S1past_at_c (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hc : (τ.state t).2 = .c) :
    ¬ PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayC (τ.state t).1 t).state t := by
    rw [stayC_state_t]
    exact Prod.ext rfl hc
  obtain ⟨s, -, hs, -⟩ := h _ hagree
  have hs' := (stab_will_iff _ s).mp hs
  rw [stayC_state] at hs'
  rcases hs' with h' | h' <;> exact S.noConfusion h'

/-- S1' holds at `d`: the previous state is `b`, where `⊡Fp` holds. -/
theorem S1past_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .d := by rw [← hagree]; exact hd
  exact ⟨t - 1, sub_one_lt t, stab_will_at_b σ (t - 1) (prev_of_d σ t h1),
    fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- **S1' `⊡P(⊡Fp)` holds at a seam iff the state is `d`.** On the shared-True class `{b, d}`
it is False at `b` and True at `d`. -/
theorem depth2_S1past_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ↔ (τ.state t).2 = S.d := by
  constructor
  · intro h
    rcases hs : (τ.state t).2 with _ | _ | _ | _
    · exact absurd h (not_S1past_at_a τ t hs)
    · exact absurd h (not_S1past_at_b τ t hs)
    · exact absurd h (not_S1past_at_c τ t hs)
    · rfl
  · intro hd
    exact S1past_at_d τ t hd

/-! ### The two optional past rows (not pinned): `⊡(Pp → ⊡Pp)` — `T F T T`; `⊡P(⊡Pp)` — `F F F F` -/

/-- The history that stays at `b` forever. -/
noncomputable def stayB (c t : ℤ) : WorldHistory Fg.toTaskFrame := stay .b rfl c t

theorem stayB_state (c t z : ℤ) : (stayB c t).state z = (z + (c - t), .b) := rfl

theorem stayB_state_t (c t : ℤ) : (stayB c t).state t = (c, .b) := stay_state_t .b rfl c t

/-- Before `t`, `viaD` is never at `d`. -/
theorem viaD_state_lt (c t s : ℤ) (hs : s < t) : ((viaD c t).state s).2 ≠ .d := by
  rw [viaD_state]
  change viaDState t s ≠ S.d
  unfold viaDState
  split_ifs <;> first | decide | omega

/-- `⊡(Pp → ⊡Pp)` fails at `b`: along `stayB`, `Pp` holds (`b` at `t - 1`) but `⊡Pp` at `b` is
False. -/
theorem not_optPastImp_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ)
    (hb : (τ.state t).2 = .b) : ¬ PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (stayB (τ.state t).1 t).state t := by
    rw [stayB_state_t]
    exact Prod.ext rfl hb
  have hPp : PlusTruthAt Mg (stayB (τ.state t).1 t) t Pp :=
    ⟨t - 1, sub_one_lt t, rfl,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := stayB (τ.state t).1 t) (t := r)⟩
  have hstab := (stab_past_iff _ t).mp (h _ hagree hPp)
  rw [stayB_state_t] at hstab
  exact S.noConfusion hstab

/-- (Optional row) **`⊡(Pp → ⊡Pp)` holds at a seam iff the state is not `b`**: on the
shared-True class it is False at `b` and True at `d`. -/
theorem depth2_optPastImp_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Pp))) ↔ (τ.state t).2 ≠ S.b := by
  constructor
  · intro h hb
    exact not_optPastImp_at_b τ t hb h
  · intro hne
    rw [PlusTruth.stab_iff]
    intro σ hagree hP
    have hσ : (σ.state t).2 ≠ S.b := by rw [← hagree]; exact hne
    rcases hs : (σ.state t).2 with _ | _ | _ | _
    · exact absurd hP (not_Pp_at_a σ t hs)
    · exact absurd hs hσ
    · exact absurd hP (not_Pp_at_c σ t hs)
    · exact stab_past_at_d σ t hs

/-- (Optional row) **`⊡P(⊡Pp)` fails at every seam**: at `a`, `b`, `c` the constant histories
have no `d` in their past; at `d`, `viaD` has none either. -/
theorem depth2_optPastPast_false (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt Mg τ t (.stab (somePast (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  rcases hs : (τ.state t).2 with _ | _ | _ | _
  · have hagree : τ.state t = (stayA (τ.state t).1 t).state t := by
      rw [stayA_state_t]
      exact Prod.ext rfl hs
    obtain ⟨s, -, hs', -⟩ := h _ hagree
    have hd := (stab_past_iff _ s).mp hs'
    rw [stayA_state] at hd
    exact S.noConfusion hd
  · have hagree : τ.state t = (stayB (τ.state t).1 t).state t := by
      rw [stayB_state_t]
      exact Prod.ext rfl hs
    obtain ⟨s, -, hs', -⟩ := h _ hagree
    have hd := (stab_past_iff _ s).mp hs'
    rw [stayB_state] at hd
    exact S.noConfusion hd
  · have hagree : τ.state t = (stayC (τ.state t).1 t).state t := by
      rw [stayC_state_t]
      exact Prod.ext rfl hs
    obtain ⟨s, -, hs', -⟩ := h _ hagree
    have hd := (stab_past_iff _ s).mp hs'
    rw [stayC_state] at hd
    exact S.noConfusion hd
  · have hagree : τ.state t = (viaD (τ.state t).1 t).state t := by
      rw [viaD_state_t]
      exact Prod.ext rfl hs
    obtain ⟨s, hst, hs', -⟩ := h _ hagree
    exact viaD_state_lt _ t s hst ((stab_past_iff _ s).mp hs')

/-! ## Depth 2, computed through the strata -/

/-- The fresh atom naming `⊡Fp`. -/
abbrev qAtom (e : Encoding) : Atom := e.ι (.inr Fp)

/-- The fresh atom naming `⊡Pp`. -/
abbrev rAtom (e : Encoding) : Atom := e.ι (.inr Pp)

/-- The encoded copy of `p`. -/
abbrev pAtom (e : Encoding) : Atom := e.ι (.inl pa)

/-- **The fresh atom `q` reads the depth-1 stratum `⊡Fp`**: the `inr` clause of
`TaskModel.atomModel`, transported to the present seam by `stab_state_only`. -/
theorem stab_fp_iff_fresh (e : Encoding) (σ : WorldHistory Fg.toTaskFrame) (s : ℤ) :
    PlusTruthAt Mg σ s (.stab Fp) ↔ PlusTruthAt (Mg.atomModel e) σ s (.atom (qAtom e)) := by
  constructor
  · intro h
    exact Or.inr ⟨Fp, rfl, σ, s, rfl, h⟩
  · rintro (⟨p, hp, _⟩ | ⟨χ, hχ, τ', t', hτ', hστ⟩)
    · exact absurd (e.inj hp) Sum.inl_ne_inr
    · cases Sum.inr.inj (e.inj hχ)
      exact (stab_state_only Mg τ' σ t' s hτ' Fp).mp hστ

/-- **The fresh atom `r` reads the depth-1 stratum `⊡Pp`**: the twin of `stab_fp_iff_fresh`. -/
theorem stab_pp_iff_fresh (e : Encoding) (σ : WorldHistory Fg.toTaskFrame) (s : ℤ) :
    PlusTruthAt Mg σ s (.stab Pp) ↔ PlusTruthAt (Mg.atomModel e) σ s (.atom (rAtom e)) := by
  constructor
  · intro h
    exact Or.inr ⟨Pp, rfl, σ, s, rfl, h⟩
  · rintro (⟨p, hp, _⟩ | ⟨χ, hχ, τ', t', hτ', hστ⟩)
    · exact absurd (e.inj hp) Sum.inl_ne_inr
    · cases Sum.inr.inj (e.inj hχ)
      exact (stab_state_only Mg τ' σ t' s hτ' Pp).mp hστ

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

/-- **S1 through the strata**: `⊡F(⊡Fp)` is the depth-1 formula `⊡F q` over the atomized
model. -/
theorem depth2_via_strata_S1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
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

/-- **S2 through the strata**: `⊡(Fp → ⊡Fp)` is `⊡(F p' → q)` over the atomized model. -/
theorem depth2_via_strata_S2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
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

/-- **M1 through the strata**: `⊡(Fp → ⊡Pp)` is `⊡(F p' → r)` over the atomized model. -/
theorem depth2_via_strata_M1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t
        (.stab (.imp (someFuture (.atom (pAtom e))) (.atom (rAtom e)))) := by
  rw [PlusTruth.stab_iff, PlusTruth.stab_iff]
  constructor
  · intro h σ hσ hF
    obtain ⟨s, hts, hs, -⟩ := hF
    exact (stab_pp_iff_fresh e σ t).mp (h σ hσ ⟨s, hts, (atom_iff_fresh e σ s).mpr hs,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩)
  · intro h σ hσ hF
    obtain ⟨s, hts, hs, -⟩ := hF
    exact (stab_pp_iff_fresh e σ t).mpr (h σ hσ ⟨s, hts, (atom_iff_fresh e σ s).mp hs,
      fun r _ _ => PlusTruth.top_true (M := Mg.atomModel e) (τ := σ) (t := r)⟩)

/-- **M2 through the strata**: `⊡(Pp → ⊡Fp)` is `⊡(P p' → q)` over the atomized model. -/
theorem depth2_via_strata_M2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t
        (.stab (.imp (somePast (.atom (pAtom e))) (.atom (qAtom e)))) := by
  rw [PlusTruth.stab_iff, PlusTruth.stab_iff]
  constructor
  · intro h σ hσ hP
    obtain ⟨s, hst, hs, -⟩ := hP
    exact (stab_fp_iff_fresh e σ t).mp (h σ hσ ⟨s, hst, (atom_iff_fresh e σ s).mpr hs,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩)
  · intro h σ hσ hP
    obtain ⟨s, hst, hs, -⟩ := hP
    exact (stab_fp_iff_fresh e σ t).mpr (h σ hσ ⟨s, hst, (atom_iff_fresh e σ s).mp hs,
      fun r _ _ => PlusTruth.top_true (M := Mg.atomModel e) (τ := σ) (t := r)⟩)

/-- **S1' through the strata**: `⊡P(⊡Fp)` is `⊡P q` over the atomized model. -/
theorem depth2_via_strata_S1past (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t (.stab (somePast (.atom (qAtom e)))) := by
  rw [PlusTruth.stab_iff, PlusTruth.stab_iff]
  constructor
  · intro h σ hσ
    obtain ⟨s, hst, hs, -⟩ := h σ hσ
    exact ⟨s, hst, (stab_fp_iff_fresh e σ s).mp hs,
      fun r _ _ => PlusTruth.top_true (M := Mg.atomModel e) (τ := σ) (t := r)⟩
  · intro h σ hσ
    obtain ⟨s, hst, hs, -⟩ := h σ hσ
    exact ⟨s, hst, (stab_fp_iff_fresh e σ s).mpr hs,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

/-- The landed transfer lemma at S1: it atomizes the OUTER `⊡`, so the whole depth-2 value is
read through one depth-2 stratum atom. -/
theorem strata_is_atomize_S1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (someFuture (.stab Fp)))) :=
  plusTruthAt_iff_atomize Mg e _ τ t

/-- The landed transfer lemma at S2. -/
theorem strata_is_atomize_S2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (.imp Fp (.stab Fp)))) :=
  plusTruthAt_iff_atomize Mg e _ τ t

/-- The landed transfer lemma at M1. -/
theorem strata_is_atomize_M1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (.imp Fp (.stab Pp)))) :=
  plusTruthAt_iff_atomize Mg e _ τ t

/-- The landed transfer lemma at M2. -/
theorem strata_is_atomize_M2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (.imp Pp (.stab Fp)))) :=
  plusTruthAt_iff_atomize Mg e _ τ t

/-- The landed transfer lemma at S1'. -/
theorem strata_is_atomize_S1past (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (somePast (.stab Fp)))) :=
  plusTruthAt_iff_atomize Mg e _ τ t

/-! ## Non-vacuity certificates: two distinct seam states per shared class -/

/-- **The shared-False class is genuinely shared**: a seam at `a` and a seam at `c` with equal
depth-1 strata (both `⊡Fp` False). -/
theorem shared_false_stratum :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (τ.state t : ℤ × S).2 = S.a ∧ (τ'.state t' : ℤ × S).2 = S.c ∧
        (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) :=
  ⟨stayA 0 0, stayC 0 0, 0, 0, by rw [stayA_state_t], by rw [stayC_state_t],
    by rw [stab_will_iff, stab_will_iff, stayA_state_t, stayC_state_t]; decide⟩

/-- **The shared-True class is genuinely shared**: a seam at `b` and a seam at `d` with equal
depth-1 strata (both `⊡Fp` True). -/
theorem shared_true_stratum :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (τ.state t : ℤ × S).2 = S.b ∧ (τ'.state t' : ℤ × S).2 = S.d ∧
        (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) :=
  ⟨fromA 0 0, viaD 0 0, 0, 0, by rw [fromA_state_t], by rw [viaD_state_t],
    by rw [stab_will_iff, stab_will_iff, fromA_state_t, viaD_state_t]; decide⟩

/-! ## The falsifier check: where it holds, non-vacuously -/

/-- **S1 IS a function of the depth-1 stratum**, on both shared classes — with real content now,
since each class has two distinct states. -/
theorem value_is_function_of_stratum_S1 (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ)
    (h : PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      PlusTruthAt Mg τ' t' (.stab (someFuture (.stab Fp))) := by
  rw [stab_will_iff, stab_will_iff] at h
  rw [depth2_S1_iff, depth2_S1_iff]
  exact h

-- The hypothesis `h` is kept so the statement has the landed theorem's hypothesis shape; M2 is
-- constant, so the proof never consults it.
set_option linter.unusedVariables false in
/-- **M2 IS a function of the depth-1 stratum**: it is constant. -/
theorem value_is_function_of_stratum_M2 (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ)
    (h : PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) ↔
      PlusTruthAt Mg τ' t' (.stab (.imp Pp (.stab Fp))) :=
  iff_of_true (depth2_M2_true τ t) (depth2_M2_true τ' t')

theorem ne_a_of_bd {x : S} (h : x = S.b ∨ x = S.d) : x ≠ S.a := by
  rcases h with rfl | rfl <;> decide

/-- **S2 IS a function of the depth-1 stratum on the shared-True class**: at `b` and at `d` it
holds outright. -/
theorem value_is_function_of_stratum_S2_on_true_class (τ τ' : WorldHistory Fg.toTaskFrame)
    (t t' : ℤ) (hτ : PlusTruthAt Mg τ t (.stab Fp)) (hτ' : PlusTruthAt Mg τ' t' (.stab Fp)) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
      PlusTruthAt Mg τ' t' (.stab (.imp Fp (.stab Fp))) :=
  iff_of_true ((depth2_S2_iff τ t).mpr (ne_a_of_bd ((stab_will_iff τ t).mp hτ)))
    ((depth2_S2_iff τ' t').mpr (ne_a_of_bd ((stab_will_iff τ' t').mp hτ')))

/-! ## The falsifier check: where it fails, machine-checked -/

/-- **S2 — the landed shape — is NOT a function of the depth-1 stratum**: the seams at `a` and
`c` share `⊡Fp` False, yet `⊡(Fp → ⊡Fp)` is False at `a` and True at `c`. -/
theorem not_function_of_stratum_S2 :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) ∧
        ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ∧
          PlusTruthAt Mg τ' t' (.stab (.imp Fp (.stab Fp))) :=
  ⟨stayA 0 0, stayC 0 0, 0, 0,
    by rw [stab_will_iff, stab_will_iff, stayA_state_t, stayC_state_t]; decide,
    by rw [depth2_S2_iff, stayA_state_t]; decide,
    by rw [depth2_S2_iff, stayC_state_t]; decide⟩

/-- **M1 — the mixed shape — is NOT a function of the depth-1 stratum**: the seams at `b` and
`d` share `⊡Fp` True, yet `⊡(Fp → ⊡Pp)` is False at `b` and True at `d`. -/
theorem not_function_of_stratum_M1 :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) ∧
        ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ∧
          PlusTruthAt Mg τ' t' (.stab (.imp Fp (.stab Pp))) :=
  ⟨fromA 0 0, viaD 0 0, 0, 0,
    by rw [stab_will_iff, stab_will_iff, fromA_state_t, viaD_state_t]; decide,
    by rw [depth2_M1_iff, fromA_state_t]; decide,
    by rw [depth2_M1_iff, viaD_state_t]; decide⟩

/-- **S1' — the past mirror of S1 — is NOT a function of the depth-1 stratum**: the seams at `b`
and `d` share `⊡Fp` True, yet `⊡P(⊡Fp)` is False at `b` and True at `d`. -/
theorem not_function_of_stratum_S1past :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) ∧
        ¬ PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ∧
          PlusTruthAt Mg τ' t' (.stab (somePast (.stab Fp))) :=
  ⟨fromA 0 0, viaD 0 0, 0, 0,
    by rw [stab_will_iff, stab_will_iff, fromA_state_t, viaD_state_t]; decide,
    by rw [depth2_S1past_iff, fromA_state_t]; decide,
    by rw [depth2_S1past_iff, viaD_state_t]⟩

end Probe739SharedStratum

/-! ## Axiom record -/

#print axioms Probe739SharedStratum.Rg_fwd
#print axioms Probe739SharedStratum.Rg_bwd
#print axioms Probe739SharedStratum.stab_will_iff
#print axioms Probe739SharedStratum.stab_past_iff
#print axioms Probe739SharedStratum.depth2_S1_iff
#print axioms Probe739SharedStratum.depth2_S2_iff
#print axioms Probe739SharedStratum.depth2_M1_iff
#print axioms Probe739SharedStratum.depth2_M2_true
#print axioms Probe739SharedStratum.depth2_S1past_iff
#print axioms Probe739SharedStratum.stab_fp_iff_fresh
#print axioms Probe739SharedStratum.stab_pp_iff_fresh
#print axioms Probe739SharedStratum.depth2_via_strata_S1
#print axioms Probe739SharedStratum.depth2_via_strata_S2
#print axioms Probe739SharedStratum.depth2_via_strata_M1
#print axioms Probe739SharedStratum.depth2_via_strata_M2
#print axioms Probe739SharedStratum.depth2_via_strata_S1past
#print axioms Probe739SharedStratum.strata_is_atomize_S1
#print axioms Probe739SharedStratum.strata_is_atomize_S2
#print axioms Probe739SharedStratum.strata_is_atomize_M1
#print axioms Probe739SharedStratum.strata_is_atomize_M2
#print axioms Probe739SharedStratum.strata_is_atomize_S1past
#print axioms Probe739SharedStratum.shared_false_stratum
#print axioms Probe739SharedStratum.shared_true_stratum
#print axioms Probe739SharedStratum.value_is_function_of_stratum_S1
#print axioms Probe739SharedStratum.value_is_function_of_stratum_M2
#print axioms Probe739SharedStratum.value_is_function_of_stratum_S2_on_true_class
#print axioms Probe739SharedStratum.not_function_of_stratum_S2
#print axioms Probe739SharedStratum.not_function_of_stratum_M1
#print axioms Probe739SharedStratum.not_function_of_stratum_S1past
