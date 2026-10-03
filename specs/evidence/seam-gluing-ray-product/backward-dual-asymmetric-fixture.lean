/-
Probe 719 (experiment E1): **the backward dual of the finite-graph `⊡` summary, on a
TIME-ASYMMETRIC fixture** — decide the backward stability operator `⊡(P p)` at a seam state by
**backward reachability** alone, with no automata and no determinization.

**Why a time-asymmetric fixture is required.** The forward factor of the finite-graph route is
already proved, by `Probe718FiniteGraph.will_iff_allPathsMeet` /
`Probe718FiniteGraph.decide_will` in `finite-graph-stab-summary.lean`. That probe records its
own exclusion of the backward dual, in its own words: "The backward dual is NOT separately
proved. The fixture's relation is symmetric under time reversal (`Rf` ignores both its time and
direction arguments)". That justification is exactly what makes the exclusion load-bearing,
because the finite-width obstruction is located in the **backward** factor: Probe710's
contradiction pigeonholes backward post-chains at unboundedly early times, the forward
post-chains out of the `p` states at times `a - n - 1` arriving at time `a` as backward
post-chains of every length `n` against only finitely many states at time `a`. A time-symmetric
fixture is therefore precisely the one that cannot see the obstruction, and a backward result on
one carries no information the forward result did not already carry.

**The fixture.** This file therefore transcribes Probe710's time-asymmetric step graph — carrier
`pre k` / `x k` / `post k j`, steps `pre (k+1) → pre k`, `pre k → x k`, `x k → post k 0`,
`post k j → post k (j+1)` — which is finitely branching, has **exactly one predecessor at every
node**, and whose every bi-infinite step path is canonical. *Saturation* is discharged from
finite fibres rather than a finite carrier, through `TaskFrame.saturation_of_fib_finite`: the
carrier is infinite, so `FrameOver.ofSlicedStep_isRegular` is unavailable here and the frame is
built by `FrameOver.ofReflectiveRegular`. Transcription rather than import is this collection's
standing constraint — every probe here imports only `FormalSystem` and never another probe (see
`scripts/check-evidence-probes.sh`'s header).

**Outcome: POSITIVE, and state-dependent.** `pastStab_iff_allBwdPathsMeet` establishes that the
backward stability operator at a seam state is exactly "every backward root path from that state
meets the `p`-set" — the clause-for-clause dual of `Probe718FiniteGraph.will_iff_allPathsMeet`.
`decide_past_stab` and the instance `decidable_past_stab` supply the computational content, and
unlike the forward probe's uniformly-False `Probe718FiniteGraph.decide_will` the decision here is
**state-dependent**: the operator is True at exactly the `post` states and False at the `x` and
`pre` states (`past_stab_at_post`, `not_past_stab_at_x`, `not_past_stab_at_pre`). The two-factor
ray-product presentation therefore survives at the backward factor on a fixture that is not
time-symmetric: it is not falsified, and the obstruction's own direction admits a
reachability-only summary on this graph.

**The honest limit, which this result does not escape.** Probe710's fixture is backward
*deterministic* — `step_inv_pre`, `step_inv_x` and `step_inv_post` give every node exactly one
predecessor — so the backward factor here is a **singleton** and E1 tests the backward dual at
its easiest instance. What it does exercise, and what the forward probe never touched, is exactly
that unique-predecessor machinery and the canonicity argument built on it. The genuinely hard
dual test is a **mirror** fixture, backward-branching and forward-deterministic; that is filed as
a follow-up and deliberately not absorbed here. Nothing in this file should be read as deciding
the backward factor in general.

**The `reflectTime` trap, and why it was not used.** There is no semantic transport theorem for
the plus language — no declaration under `FormalSystem/` relates `PlusTruthAt` to
`PlusFormula.reflectTime` — and a time reflection reverses the **frame** as well as the formula,
so any such transport would have proved a statement about the mirror fixture, which is the very
thing the time-asymmetry requirement exists to prevent. The argument below is direct backward
reachability.

**Citation hygiene.** `decide_will` is ambiguous in this probe collection, naming a declaration
in both `Probe718FiniteGraph` (`finite-graph-stab-summary.lean`) and `Probe718PathQuantifier`
(`path-quantifier-alternation.lean`). Every citation above and below is qualified.

What this does NOT do: it bounds no width, no tail-period, commits to no complexity claim, builds
and selects no determinization or universal-summary device under any name, and decides nothing
beyond this one fixture and this one formula shape (`⊡(Pp)`, a single temporal operator, no
nesting). `not_finite_width_fmp` stands untouched.

**Axiom record.** `allBwdPathsMeet_iff` — the backward-reachability half, which is the whole of
the graph argument — is choice-free at `[propext, Quot.sound]`. `stabPast_iff_post`,
`pastStab_iff_allBwdPathsMeet` and `decide_past_stab` measure `Classical.choice`, and the cause is
upstream and named: `hist_canon` routes through `FrameOver.mem_HF_iff_adjacent`, hence through
`FrameOver.worldHistoryOfStepPath`, the same declaration that carries the ω half of the promoted
keystone. Probe710 carries it for the same reason. Nothing in the backward argument itself
appeals to choice.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace Probe719Backward

/-! ## The formulas: the backward dual of the forward probe's `⊡(Fp)` -/

def pa : Atom := ⟨"p", none⟩
def p : PlusFormula := PlusFormula.atom pa

/-- `P p := ⊤ S p`, the exact dual of the forward probe's `someFuture p := ⊤ U p`. -/
def Pp : PlusFormula := PlusFormula.somePast p

/-- The backward stability operator: `⊡(P p)`. -/
def stabPast : PlusFormula := PlusFormula.stab Pp

/-! ## The time-asymmetric fixture, transcribed from Probe710 -/

/-- States: `pre k` (`k + 1` steps to go), `x k` (the `p` state of thread `k`), `post k j`
(`j + 1` steps after `x k`). -/
inductive Node : Type
  | pre : ℕ → Node
  | x : ℕ → Node
  | post : ℕ → ℕ → Node
  deriving DecidableEq

instance : Nonempty Node := ⟨.x 0⟩

/-- The one-step relation. Every state has one or two successors and **exactly one
predecessor** — this is the time asymmetry the experiment turns on. -/
inductive Step : Node → Node → Prop
  | preDown (k : ℕ) : Step (.pre (k + 1)) (.pre k)
  | preX (k : ℕ) : Step (.pre k) (.x k)
  | xPost (k : ℕ) : Step (.x k) (.post k 0)
  | postNext (k j : ℕ) : Step (.post k j) (.post k (j + 1))

theorem step_pre_inv {k : ℕ} {u : Node} (h : Step (.pre k) u) :
    u = .x k ∨ ∃ k', k = k' + 1 ∧ u = .pre k' := by
  cases h with
  | preDown k' => exact Or.inr ⟨k', rfl, rfl⟩
  | preX _ => exact Or.inl rfl

theorem step_x_inv {k : ℕ} {u : Node} (h : Step (.x k) u) : u = .post k 0 := by
  cases h; rfl

theorem step_post_inv {k j : ℕ} {u : Node} (h : Step (.post k j) u) : u = .post k (j + 1) := by
  cases h; rfl

/-! ### The three predecessor inverses: backward determinism -/

theorem step_inv_pre {v : Node} {k : ℕ} (h : Step v (.pre k)) : v = .pre (k + 1) := by
  cases h; rfl

theorem step_inv_x {v : Node} {k : ℕ} (h : Step v (.x k)) : v = .pre k := by
  cases h; rfl

theorem step_inv_post {v : Node} {k j : ℕ} (h : Step v (.post k j)) :
    (j = 0 ∧ v = .x k) ∨ ∃ j', j = j' + 1 ∧ v = .post k j' := by
  cases h with
  | xPost _ => exact Or.inl ⟨rfl, rfl⟩
  | postNext _ j' => exact Or.inr ⟨j', rfl, rfl⟩

theorem step_fwd (w : Node) : ∃ u, Step w u := by
  cases w with
  | pre k => exact ⟨_, Step.preX k⟩
  | x k => exact ⟨_, Step.xPost k⟩
  | post k j => exact ⟨_, Step.postNext k j⟩

theorem step_bwd (w : Node) : ∃ v, Step v w := by
  cases w with
  | pre k => exact ⟨_, Step.preDown k⟩
  | x k => exact ⟨_, Step.preX k⟩
  | post k j =>
    cases j with
    | zero => exact ⟨_, Step.xPost k⟩
    | succ j => exact ⟨_, Step.postNext k j⟩

/-! ### Finite fibres: the carrier is infinite, so *Saturation* comes from finite fibres -/

/-- Successors, as a list: the forward fibres are finite. -/
def fwdList : Node → List Node
  | .pre 0 => [.x 0]
  | .pre (k + 1) => [.pre k, .x (k + 1)]
  | .x k => [.post k 0]
  | .post k j => [.post k (j + 1)]

theorem mem_fwdList {w u : Node} (h : Step w u) : u ∈ fwdList w := by
  cases h with
  | preDown k => simp [fwdList]
  | preX k => cases k <;> simp [fwdList]
  | xPost k => simp [fwdList]
  | postNext k j => simp [fwdList]

/-- Predecessors, as a list — a **singleton** at every node. -/
def bwdList : Node → List Node
  | .pre k => [.pre (k + 1)]
  | .x k => [.pre k]
  | .post k 0 => [.x k]
  | .post k (j + 1) => [.post k j]

theorem mem_bwdList {v w : Node} (h : Step v w) : v ∈ bwdList w := by
  cases h with
  | preDown k => simp [bwdList]
  | preX k => simp [bwdList]
  | xPost k => simp [bwdList]
  | postNext k j => simp [bwdList]

theorem fwd_finite (w : Node) : {u | Step w u}.Finite :=
  (List.finite_toSet (fwdList w)).subset fun _ hu => mem_fwdList hu

theorem bwd_finite (w : Node) : {v | Step v w}.Finite :=
  (List.finite_toSet (bwdList w)).subset fun _ hv => mem_bwdList hv

theorem iter_fwd_finite (n : ℕ) (w : Node) : {u | iter Step n w u}.Finite := by
  induction n with
  | zero =>
    refine (Set.finite_singleton w).subset fun u hu => ?_
    have : w = u := hu
    simp [this]
  | succ n ih =>
    refine (ih.biUnion fun v _ => fwd_finite v).subset fun u hu => ?_
    obtain ⟨v, hv, hvu⟩ := hu
    exact Set.mem_biUnion (x := v) hv hvu

theorem iter_bwd_finite (n : ℕ) (w : Node) : {v | iter Step n v w}.Finite := by
  induction n generalizing w with
  | zero =>
    refine (Set.finite_singleton w).subset fun v hv => ?_
    have : v = w := hv
    simp [this]
  | succ n ih =>
    refine ((bwd_finite w).biUnion fun v' _ => ih v').subset fun v hv => ?_
    obtain ⟨v', hv', hv'w⟩ := hv
    exact Set.mem_biUnion (x := v') hv'w hv'

/-- The fibres of the two-sided relation generated by `Step` are finite, although the carrier is
not: this is what `TaskFrame.saturation_of_fib_finite` consumes. -/
theorem fib_finite (w : Node) (d : ℤ) : (TaskFrame.Fib (ofStepRel Step) w d).Finite := by
  rcases le_or_gt 0 d with hd | hd
  · refine (iter_fwd_finite d.natAbs w).subset fun u hu => ?_
    exact (ofStepRel_of_nonneg hd w u).mp hu
  · refine (iter_bwd_finite d.natAbs w).subset fun u hu => ?_
    exact (ofStepRel_of_nonpos hd.le w u).mp hu

/-- The frame: `FrameOver.ofReflectiveRegular`, with *Saturation* discharged from finite fibres
instead of a finite carrier. `FrameOver.ofSlicedStep_isRegular` — the route the forward probe's
`Bool` fixture takes — is **unavailable** here, because it needs `[Finite W]` and `Node` is
infinite. -/
def F : FrameOver intOrder :=
  FrameOver.ofReflectiveRegular Node (ofStepRel Step)
    (fun w d u => by
      constructor
      · rintro ⟨h1, h2⟩
        exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
               fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩
      · rintro ⟨h1, h2⟩
        exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
               fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩)
    (fun w v x y hx hy => by
      change (0 : ℤ) ≤ x at hx
      change (0 : ℤ) ≤ y at hy
      rw [ofStepRel_of_nonneg (add_nonneg hx hy)]
      have hnat : (x + y).natAbs = x.natAbs + y.natAbs := by omega
      rw [hnat, iter_add]
      exact exists_congr fun u => by
        rw [ofStepRel_of_nonneg hx, ofStepRel_of_nonneg hy])
    (fun w x hx => by
      constructor
      · obtain ⟨u, hu⟩ := exists_iter_fwd step_fwd x.natAbs w
        exact ⟨u, (ofStepRel_of_nonneg hx w u).mpr hu⟩
      · obtain ⟨v, hv⟩ := exists_iter_bwd step_bwd x.natAbs w
        exact ⟨v, (ofStepRel_of_nonneg hx v w).mpr hv⟩)
    (TaskFrame.limit_of_succOrder fun w u h => by
      rw [ofStepRel_of_nonneg (le_refl (0 : ℤ))] at h
      simpa [eq_comm] using h)
    (TaskFrame.saturation_of_fib_finite fib_finite)

instance F_isRegular : F.IsRegular := FrameOver.instIsRegularOfReflective _ _ _ _ _ _ _

theorem F_taskRel : F.TaskRel = ofStepRel Step := FrameOver.ofReflectiveRegular_taskRel_eq

theorem F_step (w u : Node) : F.step w u ↔ Step w u := by
  change F.TaskRel w 1 u ↔ _
  rw [F_taskRel, ofStepRel_of_nonneg (zero_le_one : (0 : ℤ) ≤ 1)]
  exact iter_one Step w u

/-- The model: `p` holds exactly at the `x` states. -/
def M : TaskModel F.toTaskFrame := ⟨fun w _ => ∃ k, w = Node.x k⟩

/-! ### Every step path is canonical -/

/-- The bi-infinite step path of thread `k` with `x k` at time `t`. -/
def canon (k : ℕ) (t : ℤ) (s : ℤ) : Node :=
  if s < t then .pre (k + (t - 1 - s).toNat)
  else if s = t then .x k
  else .post k (s - t - 1).toNat

theorem canon_of_lt {k : ℕ} {t s : ℤ} (h : s < t) :
    canon k t s = .pre (k + (t - 1 - s).toNat) := by
  simp [canon, h]

theorem canon_self (k : ℕ) (t : ℤ) : canon k t t = .x k := by
  simp [canon]

theorem canon_of_gt {k : ℕ} {t s : ℤ} (h : t < s) : canon k t s = .post k (s - t - 1).toNat := by
  simp [canon, not_lt.mpr h.le, h.ne']

theorem canon_step (k : ℕ) (t s : ℤ) : Step (canon k t s) (canon k t (s + 1)) := by
  rcases lt_trichotomy (s + 1) t with h1 | h1 | h1
  · rw [canon_of_lt (by omega), canon_of_lt h1]
    have e : (t - 1 - s).toNat = (t - 1 - (s + 1)).toNat + 1 := by omega
    rw [e]
    exact Step.preDown _
  · rw [canon_of_lt (by omega), h1, canon_self]
    have e : (t - 1 - s).toNat = 0 := by omega
    rw [e, Nat.add_zero]
    exact Step.preX k
  · rcases lt_trichotomy s t with h2 | h2 | h2
    · omega
    · subst h2
      rw [canon_self, canon_of_gt (by omega)]
      have e : (s + 1 - s - 1).toNat = 0 := by omega
      rw [e]
      exact Step.xPost k
    · rw [canon_of_gt h2, canon_of_gt (by omega)]
      have e : (s + 1 - t - 1).toNat = (s - t - 1).toNat + 1 := by omega
      rw [e]
      exact Step.postNext k _

/-- `canon k t s` is an `x` state exactly at `s = t`. -/
theorem canon_eq_x_iff {k k' : ℕ} {t s : ℤ} : canon k t s = .x k' ↔ s = t ∧ k = k' := by
  rcases lt_trichotomy s t with h | h | h
  · rw [canon_of_lt h]; simp; omega
  · subst h; rw [canon_self]; simp
  · rw [canon_of_gt h]; simp; omega

section Struct

variable {g : ℤ → Node} (hg : ∀ s, Step (g s) (g (s + 1)))
include hg

theorem fwd_from_x {t : ℤ} {k : ℕ} (ht : g t = .x k) (i : ℕ) : g (t + i + 1) = .post k i := by
  induction i with
  | zero =>
    have h := hg t
    rw [ht] at h
    simpa using step_x_inv h
  | succ i ih =>
    have h := hg (t + i + 1)
    rw [ih] at h
    have e : t + ((i + 1 : ℕ) : ℤ) + 1 = t + i + 1 + 1 := by push_cast; ring
    rw [e]
    exact step_post_inv h

theorem bwd_from_x {t : ℤ} {k : ℕ} (ht : g t = .x k) (i : ℕ) : g (t - i - 1) = .pre (k + i) := by
  induction i with
  | zero =>
    have h := hg (t - 1)
    rw [show t - 1 + 1 = t by ring, ht] at h
    simpa using step_inv_x h
  | succ i ih =>
    have h := hg (t - i - 1 - 1)
    rw [show t - i - 1 - 1 + 1 = t - i - 1 by ring, ih] at h
    have e : t - ((i + 1 : ℕ) : ℤ) - 1 = t - i - 1 - 1 := by push_cast; ring
    rw [e]
    exact step_inv_pre h

theorem post_back {k : ℕ} (j : ℕ) : ∀ s, g s = .post k j → g (s - j - 1) = .x k := by
  induction j with
  | zero =>
    intro s hs
    have h := hg (s - 1)
    rw [show s - 1 + 1 = s by ring, hs] at h
    rcases step_inv_post h with ⟨-, hv⟩ | ⟨j', hj', -⟩
    · simpa using hv
    · omega
  | succ j ih =>
    intro s hs
    have h := hg (s - 1)
    rw [show s - 1 + 1 = s by ring, hs] at h
    rcases step_inv_post h with ⟨hj, -⟩ | ⟨j', hj', hv⟩
    · omega
    · have hj'' : j' = j := by omega
      rw [hj''] at hv
      have := ih (s - 1) hv
      have e : s - ((j + 1 : ℕ) : ℤ) - 1 = s - 1 - j - 1 := by push_cast; ring
      rw [e]
      exact this

theorem pre_fwd (k : ℕ) : ∀ s, g s = .pre k → ∃ (i : ℕ) (k' : ℕ), g (s + i) = .x k' := by
  induction k with
  | zero =>
    intro s hs
    have h := hg s
    rw [hs] at h
    rcases step_pre_inv h with hv | ⟨k', hk', -⟩
    · exact ⟨1, 0, by simpa using hv⟩
    · omega
  | succ k ih =>
    intro s hs
    have h := hg s
    rw [hs] at h
    rcases step_pre_inv h with hv | ⟨k', hk', hv⟩
    · exact ⟨1, k + 1, by simpa using hv⟩
    · have hk'' : k' = k := by omega
      rw [hk''] at hv
      obtain ⟨i, k'', hi⟩ := ih (s + 1) hv
      refine ⟨i + 1, k'', ?_⟩
      rw [show s + ((i + 1 : ℕ) : ℤ) = s + 1 + i by push_cast; ring]
      exact hi

theorem exists_x : ∃ (t : ℤ) (k : ℕ), g t = .x k := by
  cases hx : g 0 with
  | pre k =>
    obtain ⟨i, k', hi⟩ := pre_fwd hg k 0 hx
    exact ⟨0 + i, k', hi⟩
  | x k => exact ⟨0, k, hx⟩
  | post k j => exact ⟨0 - j - 1, k, post_back hg j 0 hx⟩

/-- **Every step path is canonical.** -/
theorem path_eq_canon : ∃ (k : ℕ) (t : ℤ), ∀ s, g s = canon k t s := by
  obtain ⟨t, k, ht⟩ := exists_x hg
  refine ⟨k, t, fun s => ?_⟩
  rcases lt_trichotomy s t with h | h | h
  · rw [canon_of_lt h]
    have := bwd_from_x hg ht (t - 1 - s).toNat
    rw [show t - ((t - 1 - s).toNat : ℤ) - 1 = s by omega] at this
    exact this
  · subst h; rw [canon_self]; exact ht
  · rw [canon_of_gt h]
    have := fwd_from_x hg ht (s - t - 1).toNat
    rw [show t + ((s - t - 1).toNat : ℤ) + 1 = s by omega] at this
    exact this

end Struct

/-- Every possible world of `F` is a canonical path. -/
theorem hist_canon (σ : WorldHistory F.toTaskFrame) :
    ∃ (k : ℕ) (t : ℤ), ∀ s, σ.state s = canon k t s := by
  have hstep : IsStepPath F σ.path := (FrameOver.mem_HF_iff_adjacent F σ.path).mp ⟨σ, rfl⟩
  exact path_eq_canon fun s => (F_step _ _).mp (hstep s)

/-- The history of the canonical path: every `(k, t)` is realized, so the `⊡` quantification
domain is exactly the canonical paths through the seam state. -/
def histOf (k : ℕ) (t : ℤ) : WorldHistory F.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath F (canon k t) (fun s => (F_step _ _).mpr (canon_step k t s))

theorem histOf_state (k : ℕ) (t s : ℤ) : (histOf k t).state s = canon k t s :=
  congrFun (FrameOver.worldHistoryOfStepPath.path F (canon k t) _) s

/-! ### Truth of `p` and of `P p` along a canonical history -/

section Truth

variable {σ : WorldHistory F.toTaskFrame} {k : ℕ} {t : ℤ} (hσ : ∀ s, σ.state s = canon k t s)
include hσ

theorem truth_p (s : ℤ) : PlusTruthAt M σ s p ↔ s = t := by
  change (∃ k', σ.state s = Node.x k') ↔ s = t
  rw [hσ s]
  constructor
  · rintro ⟨k', hk'⟩; exact (canon_eq_x_iff.mp hk').1
  · intro h; exact ⟨k, canon_eq_x_iff.mpr ⟨h, rfl⟩⟩

omit hσ in
theorem truth_top (s : ℤ) : PlusTruthAt M σ s PlusFormula.top := fun h => h

/-- `P p` at `(σ, s)` holds exactly when `σ`'s `x` position is strictly before `s`. -/
theorem truth_Pp (s : ℤ) : PlusTruthAt M σ s Pp ↔ t < s := by
  constructor
  · rintro ⟨(s' : ℤ), hs', hp, -⟩
    rw [truth_p hσ] at hp
    exact hp ▸ hs'
  · intro h
    exact ⟨t, h, (truth_p hσ t).mpr rfl, fun r _ _ => truth_top r⟩

end Truth

/-! ## Backward reachability on the fixture graph -/

/-- A **backward root path** from `w₀`: a sequence starting at `w₀` each of whose members is
stepped *to* by the next — the dual of `Probe718FiniteGraph.IsFwdPath`. On this fixture the
`Step`-hypothesis is not vacuous: it is what the predecessor inverses consume. -/
def IsBwdPath (w₀ : Node) (g : ℕ → Node) : Prop := g 0 = w₀ ∧ ∀ n, Step (g (n + 1)) (g n)

/-- The **backward AF-shaped reachability condition**: every backward root path from `w₀` meets
the `p`-set at some strictly earlier position. The dual of
`Probe718FiniteGraph.AllPathsMeet`. -/
def AllBwdPathsMeet (w₀ : Node) : Prop :=
  ∀ g : ℕ → Node, IsBwdPath w₀ g → ∃ n, 0 < n ∧ ∃ k, g n = .x k

/-- Backward determinism in action: from a `post k j` state the unique backward chain reaches
`x k` after exactly `j + 1` steps. -/
theorem bwd_reaches_x (j : ℕ) : ∀ (k : ℕ) (g : ℕ → Node), g 0 = .post k j →
    (∀ n, Step (g (n + 1)) (g n)) → g (j + 1) = .x k := by
  induction j with
  | zero =>
    intro k g h0 hstep
    have h := hstep 0
    rw [h0] at h
    rcases step_inv_post h with ⟨-, hv⟩ | ⟨j', hj', -⟩
    · exact hv
    · omega
  | succ j ih =>
    intro k g h0 hstep
    have h := hstep 0
    rw [h0] at h
    rcases step_inv_post h with ⟨hj, -⟩ | ⟨j', hj', hv⟩
    · omega
    · have hj'' : j' = j := by omega
      rw [hj''] at hv
      have := ih k (fun n => g (n + 1)) hv (fun n => hstep (n + 1))
      exact this

theorem allBwdPathsMeet_post (k j : ℕ) : AllBwdPathsMeet (.post k j) := by
  intro g hg
  exact ⟨j + 1, by omega, k, bwd_reaches_x j k g hg.1 hg.2⟩

/-- The unique backward chain out of `x k`: `x k`, then `pre k`, `pre (k+1)`, … . Named rather
than inlined, so the step proof is a constructor application and not an `if`-rewriting exercise.
-/
def bwdFromX (k : ℕ) : ℕ → Node
  | 0 => .x k
  | n + 1 => .pre (k + n)

theorem bwdFromX_step (k n : ℕ) : Step (bwdFromX k (n + 1)) (bwdFromX k n) := by
  cases n with
  | zero => exact Step.preX k
  | succ n => exact Step.preDown _

theorem bwdFromX_ne_x {k n k' : ℕ} (hn : 0 < n) : bwdFromX k n ≠ .x k' := by
  cases n with
  | zero => omega
  | succ n => intro h; cases h

/-- The unique backward chain out of `pre m`: `pre (m+1)`, `pre (m+2)`, … . -/
def bwdFromPre (m : ℕ) : ℕ → Node := fun n => .pre (m + n)

theorem bwdFromPre_step (m n : ℕ) : Step (bwdFromPre m (n + 1)) (bwdFromPre m n) :=
  Step.preDown _

/-- The backward chain out of an `x` state runs back through `pre` states forever and never
meets the `p`-set. -/
theorem not_allBwdPathsMeet_x (k : ℕ) : ¬ AllBwdPathsMeet (.x k) := by
  intro h
  obtain ⟨n, hn, k', hk'⟩ := h (bwdFromX k) ⟨rfl, bwdFromX_step k⟩
  exact bwdFromX_ne_x hn hk'

/-- The backward chain out of a `pre` state likewise never meets the `p`-set. -/
theorem not_allBwdPathsMeet_pre (m : ℕ) : ¬ AllBwdPathsMeet (.pre m) := by
  intro h
  obtain ⟨n, hn, k', hk'⟩ := h (bwdFromPre m) ⟨rfl, bwdFromPre_step m⟩
  cases hk'

/-- `AllBwdPathsMeet` holds exactly at the `post` states. This is where backward determinism is
cashed in: the backward factor at any node is a singleton, so the universal quantifier over
backward paths collapses to a single chain. -/
theorem allBwdPathsMeet_iff (w : Node) : AllBwdPathsMeet w ↔ ∃ k j, w = .post k j := by
  constructor
  · intro h
    cases w with
    | pre m => exact absurd h (not_allBwdPathsMeet_pre m)
    | x k => exact absurd h (not_allBwdPathsMeet_x k)
    | post k j => exact ⟨k, j, rfl⟩
  · rintro ⟨k, j, rfl⟩
    exact allBwdPathsMeet_post k j

/-! ## The backward summary theorem -/

/-- The seam states at which the backward stability operator can hold are exactly the `post`
states — read off the canonical structure of the `⊡` quantification domain. -/
theorem stabPast_iff_post (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    PlusTruthAt M τ t stabPast ↔ ∃ k j, τ.state t = .post k j := by
  obtain ⟨k₀, t₀, hτ⟩ := hist_canon τ
  constructor
  · intro (h : ∀ σ : WorldHistory F.toTaskFrame, τ.state t = σ.state t →
      PlusTruthAt M σ t Pp)
    have hPp : PlusTruthAt M τ t Pp := h τ rfl
    have ht₀ : t₀ < t := (truth_Pp hτ t).mp hPp
    refine ⟨k₀, (t - t₀ - 1).toNat, ?_⟩
    rw [hτ t, canon_of_gt ht₀]
  · rintro ⟨k, j, hpost⟩
    intro σ hagree
    obtain ⟨k', t', hσ⟩ := hist_canon σ
    have hst : σ.state t = .post k j := by rw [← hagree]; exact hpost
    have hcan : canon k' t' t = .post k j := by rw [← hσ t]; exact hst
    have ht' : t' < t := by
      rcases lt_trichotomy t t' with h | h | h
      · rw [canon_of_lt h] at hcan; cases hcan
      · subst h; rw [canon_self] at hcan; cases hcan
      · exact h
    exact (truth_Pp hσ t).mpr ht'

/--
**The backward dual of the finite-graph summary.** The backward stability operator `⊡(P p)` at a
seam state is exactly "every backward root path from that state meets the `p`-set" — the
clause-for-clause dual of `Probe718FiniteGraph.will_iff_allPathsMeet`, now on a fixture that is
**not** symmetric under time reversal.
-/
theorem pastStab_iff_allBwdPathsMeet (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    PlusTruthAt M τ t stabPast ↔ AllBwdPathsMeet (τ.state t) :=
  (stabPast_iff_post τ t).trans (allBwdPathsMeet_iff (τ.state t)).symm

/-! ## Computational content: a STATE-DEPENDENT decision, by backward reachability alone -/

theorem past_stab_at_post (τ : WorldHistory F.toTaskFrame) (t : ℤ) {k j : ℕ}
    (h : τ.state t = .post k j) : PlusTruthAt M τ t stabPast :=
  (pastStab_iff_allBwdPathsMeet τ t).mpr (h ▸ allBwdPathsMeet_post k j)

theorem not_past_stab_at_x (τ : WorldHistory F.toTaskFrame) (t : ℤ) {k : ℕ}
    (h : τ.state t = .x k) : ¬ PlusTruthAt M τ t stabPast :=
  fun hst => not_allBwdPathsMeet_x k (h ▸ (pastStab_iff_allBwdPathsMeet τ t).mp hst)

theorem not_past_stab_at_pre (τ : WorldHistory F.toTaskFrame) (t : ℤ) {m : ℕ}
    (h : τ.state t = .pre m) : ¬ PlusTruthAt M τ t stabPast :=
  fun hst => not_allBwdPathsMeet_pre m (h ▸ (pastStab_iff_allBwdPathsMeet τ t).mp hst)

/-- **The decision, by backward reachability on the step graph.** The three-row table: `⊡(P p)`
is **True** at every `post` state and **False** at every `x` and `pre` state. This is strictly
more informative than the forward probe's uniformly-False `Probe718FiniteGraph.decide_will`,
which has no state dependence to exhibit. -/
theorem decide_past_stab (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    (PlusTruthAt M τ t stabPast ↔ ∃ k j, τ.state t = .post k j) :=
  stabPast_iff_post τ t

/-- Decidability, on the model of `Probe718FiniteGraph.decidable_will` but with a genuine case
split: the `DecidableEq` on `Node` plus the three-row table. -/
instance decidable_past_stab (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    Decidable (PlusTruthAt M τ t stabPast) :=
  match hw : (τ.state t : Node) with
  | .pre _ => Decidable.isFalse (not_past_stab_at_pre τ t hw)
  | .x _ => Decidable.isFalse (not_past_stab_at_x τ t hw)
  | .post _ _ => Decidable.isTrue (past_stab_at_post τ t hw)

end Probe719Backward

/-! ## Axiom record -/

#print axioms Probe719Backward.allBwdPathsMeet_iff
#print axioms Probe719Backward.stabPast_iff_post
#print axioms Probe719Backward.pastStab_iff_allBwdPathsMeet
#print axioms Probe719Backward.decide_past_stab
