import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAFormula
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEATranslation

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Generalized Vec-EA Formulas with m Free Variables

Defines `VecEA_m` and `VVecEA_m`: generalizations of `VecEA2` and `VVecEA2`
from 2 free variables to an arbitrary number m of free variables. These support
the existential closure operation needed for the NF-based strong induction
approach to Kamp's theorem.

## Design

A `VecEA_m m` formula has `m` free variables z_0 < z_1 < ... < z_{m-1}.
Between each consecutive pair (z_i, z_{i+1}), there is a bracket formula
describing what must hold in that interval: existentially quantified witnesses
with point types and segment types. Each free variable also has an endpoint
predicate.

This design supports existential closure cleanly: absorbing z_{m-1} replaces
the rightmost interval bracket with a temporal condition via `bracketBuildRight`,
which gets folded into the endpoint predicate at z_{m-2}.

## Main Definitions

- `VecEA_m m`: An exists-forall formula with `m` free variables and per-interval
  bracket formulas between consecutive free variables.

- `VVecEA_m m`: A disjunction of `VecEA_m` formulas.

- `VecEA_m.existClosure`: Absorbs the rightmost free variable by converting
  the rightmost interval bracket to a temporal condition.

- `VecEA_m.toVecEA2`: Specializes the m=2 case back to `VecEA2`.

## References

- Rabinovich 2014, Definition 3.1, Lemma 3.2.3, Lemma 3.4
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Helper: Extend an environment by appending a point -/

/-- Extend a `Fin m → X` environment by appending one more value,
    producing `Fin (m + 1) → X`. -/
def extendEnv {α : Type*} {m : Nat} (env : Fin m → α) (z : α) :
    Fin (m + 1) → α :=
  fun i => if h : i.val < m then env ⟨i.val, h⟩ else z

theorem extendEnv_init {α : Type*} {m : Nat} (env : Fin m → α) (z : α)
    (i : Fin m) : extendEnv env z ⟨i.val, by omega⟩ = env i := by
  simp [extendEnv, i.isLt]

theorem extendEnv_last {α : Type*} {m : Nat} (env : Fin m → α) (z : α) :
    extendEnv env z ⟨m, by omega⟩ = z := by
  simp [extendEnv]

/-- A 2-element environment from two values. -/
def env2 {α : Type*} (a b : α) : Fin 2 → α :=
  fun i => if i.val = 0 then a else b

theorem env2_zero {α : Type*} (a b : α) : env2 a b ⟨0, by omega⟩ = a := by
  simp [env2]

theorem env2_one {α : Type*} (a b : α) : env2 a b ⟨1, by omega⟩ = b := by
  simp [env2]

/-! ## VecEA_m: Generalized Vec-EA Formula with m Free Variables

A `VecEA_m m` formula has:
- `m` free variables z_0 < z_1 < ... < z_{m-1} (the "environment")
- Endpoint predicates at each free variable position
- For each consecutive pair (z_i, z_{i+1}), a bracket formula specifying
  the interval decomposition

At m = 2, there is one interval bracket (between z_0 and z_1),
corresponding exactly to `VecEA2`.
At m = 1, there are no interval brackets (just an endpoint predicate).
At m = 0, the structure is trivially empty.
-/

/-- A vec-EA formula with `m` free variables. Generalizes `VecEA2` (m=2 case).
    The environment consists of m strictly increasing points z_0 < ... < z_{m-1},
    with endpoint predicates at each and bracket formulas between consecutive
    pairs of free variables. -/
structure VecEA_m (m : Nat) where
  /-- Endpoint type at each free variable z_i -/
  endpointTypes : Fin m → TemporalPred
  /-- Bracket formula between z_i and z_{i+1} for each i = 0, ..., m-2.
      When m <= 1, this is Fin 0 → ... (no brackets needed). -/
  intervalBrackets : (i : Fin (m - 1)) → Σ k, BracketFormula k

/-! ## Semantics -/

/-- Semantics of a VecEA_m formula: all endpoint predicates hold at their
    respective environment points, and each interval bracket formula holds on
    the interval between consecutive free variables.
    Requires the environment to be strictly increasing. -/
noncomputable def VecEA_m.holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m m) (env : Fin m → M.carrier) : Prop :=
  -- All endpoint predicates hold
  (∀ i : Fin m, (vea.endpointTypes i).eval_at M atomMap (env i)) ∧
  -- All interval brackets hold between consecutive free variables
  (∀ i : Fin (m - 1),
    (vea.intervalBrackets i).2.holds M atomMap
      (env ⟨i.val, by omega⟩) (env ⟨i.val + 1, by omega⟩))

/-! ## VVecEA_m: Disjunction of VecEA_m Formulas -/

/-- A V-vec-EA-m formula: disjunction of `VecEA_m` formulas with the same
    number of free variables. -/
structure VVecEA_m (m : Nat) where
  /-- The disjuncts -/
  disjuncts : List (VecEA_m m)

/-- Semantics of a VVecEA_m formula: some disjunct holds. -/
noncomputable def VVecEA_m.holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA_m m) (env : Fin m → M.carrier) : Prop :=
  ∃ vea ∈ v.disjuncts, vea.holds M atomMap env

/-! ## Disjunction Closure (Trivial) -/

/-- V-vec-EA-m is closed under disjunction (list concatenation). -/
def VVecEA_m.disj {m : Nat} (v1 v2 : VVecEA_m m) : VVecEA_m m :=
  { disjuncts := v1.disjuncts ++ v2.disjuncts }

/-- Disjunction semantics for VVecEA_m. -/
theorem VVecEA_m.disj_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VVecEA_m m) (env : Fin m → M.carrier) :
    (v1.disj v2).holds M atomMap env ↔
    v1.holds M atomMap env ∨ v2.holds M atomMap env := by
  simp only [holds, disj, List.mem_append]
  constructor
  · rintro ⟨vea, h_mem, h_holds⟩
    rcases h_mem with h1 | h2
    · exact Or.inl ⟨vea, h1, h_holds⟩
    · exact Or.inr ⟨vea, h2, h_holds⟩
  · rintro (⟨vea, h_mem, h_holds⟩ | ⟨vea, h_mem, h_holds⟩)
    · exact ⟨vea, Or.inl h_mem, h_holds⟩
    · exact ⟨vea, Or.inr h_mem, h_holds⟩

/-! ## Conjunction Closure -/

/-- Structural conjunction of two VecEA_m formulas. Conjoins endpoint predicates
    and bracket formulas. -/
def VecEA_m.conjStruct {m : Nat}
    (vea1 vea2 : VecEA_m m) : VecEA_m m :=
  { endpointTypes := fun i => (vea1.endpointTypes i).conj (vea2.endpointTypes i)
    intervalBrackets := fun i =>
      (vea1.intervalBrackets i).2.conjStruct (vea2.intervalBrackets i).2 }

/-- Structural conjunction of two VVecEA_m formulas via Cartesian product. -/
def VVecEA_m.conj {m : Nat} (v1 v2 : VVecEA_m m) : VVecEA_m m :=
  { disjuncts := v1.disjuncts.flatMap fun vea1 =>
      v2.disjuncts.map fun vea2 =>
        vea1.conjStruct vea2 }

/-- If both VVecEA_m formulas hold, their conjunction holds. -/
theorem VVecEA_m.conj_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VVecEA_m m) (env : Fin m → M.carrier)
    (h1 : v1.holds M atomMap env) (h2 : v2.holds M atomMap env) :
    (v1.conj v2).holds M atomMap env := by
  obtain ⟨vea1, hm1, hep1, hbr1⟩ := h1
  obtain ⟨vea2, hm2, hep2, hbr2⟩ := h2
  refine ⟨vea1.conjStruct vea2, ?_, ?_, ?_⟩
  · simp only [conj]
    exact List.mem_flatMap.mpr ⟨vea1, hm1, List.mem_map.mpr ⟨vea2, hm2, rfl⟩⟩
  · intro i
    simp only [VecEA_m.conjStruct]
    exact (TemporalPred.eval_at_conj M atomMap _ _ (env i)).mpr ⟨hep1 i, hep2 i⟩
  · intro i
    simp only [VecEA_m.conjStruct]
    exact BracketFormula.conjStruct_holds M atomMap _ _ _ _ (hbr1 i) (hbr2 i)

/-! ## Existential Closure (Lemma 3.2.3)

The key operation: absorb the rightmost free variable z_m by existential
quantification. This produces a VecEA_m m formula (from VecEA_m (m+1)).

Given VecEA_m (m+1) with intervals (z_0,z_1), ..., (z_{m-1}, z_m):
- After absorbing z_m, the intervals become (z_0,z_1), ..., (z_{m-2}, z_{m-1})
- The rightmost interval (z_{m-1}, z_m) and endpointType at z_m are converted
  to a temporal condition via `bracketBuildRight`, then conjoined with the
  endpoint predicate at z_{m-1}.

This uses the `bracketBuildRight` translation from VecEATranslation.lean:
  bracketBuildRight(bracket, endpointType) : Formula
produces a temporal formula expressing "exists z_m > here with bracket and endpoint."
-/

/-- Existential closure: absorb the rightmost free variable z_m via
    existential quantification. The rightmost interval bracket and z_m's
    endpoint predicate are converted to a temporal condition at z_{m-1}
    via `bracketBuildRight`.

    For m = 0 (source has 1 variable): produces VecEA_m 0 (trivially empty).
    For m >= 1: the result has m free variables with the rightmost interval
    absorbed into z_{m-1}'s endpoint predicate. -/
noncomputable def VecEA_m.existClosure {m : Nat}
    (vea : VecEA_m (m + 1)) : VecEA_m m :=
  match m with
  | 0 =>
    -- Source has 1 variable, result has 0 variables (trivially empty)
    { endpointTypes := Fin.elim0
      intervalBrackets := fun i => absurd i.isLt (by omega) }
  | m' + 1 =>
    -- Source has m'+2 variables (indices 0 to m'+1)
    -- Absorb z_{m'+1}: its endpoint predicate and the rightmost interval
    -- bracket (between z_{m'} and z_{m'+1}) become a temporal condition.
    let rightBracket := vea.intervalBrackets ⟨m', by omega⟩
    let absorbedEndpoint := vea.endpointTypes ⟨m' + 1, by omega⟩
    -- The temporal formula: bracketBuildRight(rightBracket, absorbedEndpoint)
    -- This holds at z_{m'} iff exists z_{m'+1} > z_{m'} with the bracket
    -- and endpoint conditions satisfied.
    let temporalCond := bracketBuildRight rightBracket.2 absorbedEndpoint
    { endpointTypes := fun i =>
        if h : i.val < m' then
          vea.endpointTypes ⟨i.val, by omega⟩
        else
          -- i.val = m': conjoin original endpoint with temporal condition
          (vea.endpointTypes ⟨m', by omega⟩).conj ⟨temporalCond⟩
      intervalBrackets := fun i =>
        vea.intervalBrackets ⟨i.val, by omega⟩ }

/-! ## Existential Closure Correctness

The correctness proof relates `existClosure` semantics to the existential
quantification over the absorbed variable. -/

/-- Forward direction: if existClosure holds on env, then there exists z
    extending env such that the original formula holds.

    Note: This requires `bracketBuildRight_correct` (chain correctness)
    from VecEATranslation.lean. The proof extracts the existential witness
    from the temporal condition at z_{m-1}. -/
theorem VecEA_m.existClosure_correct {sig : MonadicSignature} {m : Nat}
    (hm : m ≥ 1)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m (m + 1))
    (env : Fin m → M.carrier)
    (henv_mono : StrictMono env) :
    vea.existClosure.holds M atomMap env →
    ∃ z : M.carrier, env ⟨m - 1, by omega⟩ < z ∧
      vea.holds M atomMap (extendEnv env z) := by
  obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
  -- Now m = m' + 1, vea : VecEA_m (m' + 2), env : Fin (m' + 1) → M.carrier
  intro ⟨hep_cl, hbr_cl⟩
  -- existClosure unfolds to the m' + 1 branch
  simp only [existClosure] at hep_cl hbr_cl
  -- The endpoint at position m' has the conjoined temporal condition
  have hep_last := hep_cl ⟨m', by omega⟩
  simp [show ¬(m' < m') from by omega] at hep_last
  rw [TemporalPred.eval_at_conj] at hep_last
  obtain ⟨hep_orig_last, htemp⟩ := hep_last
  -- Extract the existential from bracketBuildRight_correct
  simp only [TemporalPred.eval_at] at htemp
  rw [bracketBuildRight_correct] at htemp
  obtain ⟨z, hz_gt, hz_ep, hz_br⟩ := htemp
  -- z is the absorbed variable. env ⟨m', ...⟩ < z
  refine ⟨z, ?_, ?_, ?_⟩
  · -- env ⟨m' + 1 - 1, ...⟩ < z  i.e.  env ⟨m', ...⟩ < z
    convert hz_gt using 2
  · -- All endpoint predicates of vea hold on extendEnv env z
    intro i
    by_cases hi : i.val < m' + 1
    · -- For i < m' + 1: endpoint from env
      rw [extendEnv_init env z ⟨i.val, hi⟩]
      by_cases hi' : i.val < m'
      · have h := hep_cl ⟨i.val, by omega⟩
        simp [hi'] at h
        convert h using 1
      · have him : i.val = m' := by omega
        convert hep_orig_last using 1
        · congr 1; ext; exact him
        · congr 1; ext; omega
    · -- For i = m' + 1: the absorbed variable, at z
      have him : i.val = m' + 1 := by omega
      have : extendEnv env z i = z := by simp [extendEnv, show ¬(i.val < m' + 1) from hi]
      rw [this]
      convert hz_ep using 1
      congr 1; ext; exact him
  · -- All interval brackets of vea hold on extendEnv env z
    intro i
    by_cases hi : i.val < m'
    · -- For intervals 0 to m'-1: between env points
      have h_br := hbr_cl ⟨i.val, by omega⟩
      have h1 : extendEnv env z ⟨i.val, by omega⟩ = env ⟨i.val, by omega⟩ :=
        by simp [extendEnv, show i.val < m' + 1 from by omega]
      have h2 : extendEnv env z ⟨i.val + 1, by omega⟩ = env ⟨i.val + 1, by omega⟩ :=
        by simp [extendEnv, show i.val + 1 < m' + 1 from by omega]
      rw [h1, h2]; exact h_br
    · -- For interval m': between env(m') and z
      have him : i.val = m' := by omega
      have h1 : extendEnv env z ⟨i.val, by omega⟩ = env ⟨i.val, by omega⟩ :=
        by simp [extendEnv, show i.val < m' + 1 from by omega]
      have h2 : extendEnv env z ⟨i.val + 1, by omega⟩ = z :=
        by simp [extendEnv, show ¬(i.val + 1 < m' + 1) from by omega]
      rw [h1, h2]
      have : vea.intervalBrackets i = vea.intervalBrackets ⟨m', by omega⟩ := by
        congr 1; exact Fin.ext him
      rw [this]; convert hz_br using 2; ext; exact him

/-- Reverse direction: if there exists z extending env such that vea holds,
    then existClosure holds on env. -/
theorem VecEA_m.existClosure_correct_rev {sig : MonadicSignature} {m : Nat}
    (hm : m ≥ 1)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m (m + 1))
    (env : Fin m → M.carrier)
    (henv_mono : StrictMono env)
    (z : M.carrier)
    (hz : env ⟨m - 1, by omega⟩ < z)
    (hvea : vea.holds M atomMap (extendEnv env z)) :
    vea.existClosure.holds M atomMap env := by
  obtain ⟨hep_ext, hbr_ext⟩ := hvea
  obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
  -- Now m = m' + 1, vea : VecEA_m (m' + 2), env : Fin (m' + 1) → M.carrier
  -- existClosure unfolds to the m' + 1 branch
  simp only [existClosure, holds]
  constructor
  · -- Endpoint predicates for the result
    intro i
    by_cases hi : i.val < m'
    · -- For i < m': same endpoint as original
      simp [hi]
      have h1 : extendEnv env z ⟨i.val, by omega⟩ = env ⟨i.val, by omega⟩ :=
        extendEnv_init env z ⟨i.val, by omega⟩
      have h_ep := hep_ext ⟨i.val, by omega⟩
      rw [h1] at h_ep
      convert h_ep using 1
    · -- For i = m': conjoined endpoint
      have him : i.val = m' := by omega
      simp [hi]
      rw [TemporalPred.eval_at_conj]
      constructor
      · -- Original endpoint at z_{m'}
        have h_ep := hep_ext ⟨m', by omega⟩
        rw [extendEnv_init env z ⟨m', by omega⟩] at h_ep
        convert h_ep using 1
        congr 1; ext; omega
      · -- Temporal condition: bracketBuildRight holds at z_{m'}
        simp only [TemporalPred.eval_at]
        rw [bracketBuildRight_correct]
        have henv_i : env i = env ⟨m', by omega⟩ := by congr 1; ext; exact him
        refine ⟨z, ?_, ?_, ?_⟩
        · -- env i < z
          rw [henv_i]
          convert hz using 2
        · -- absorbedEndpoint holds at z
          have h_ep := hep_ext ⟨m' + 1, by omega⟩
          rw [extendEnv_last env z] at h_ep
          exact h_ep
        · -- rightBracket holds on (env i, z)
          rw [henv_i]
          have h_br := hbr_ext ⟨m', by omega⟩
          convert h_br using 2
          · exact (extendEnv_init env z ⟨m', by omega⟩).symm
          · exact (extendEnv_last env z).symm
  · -- Interval brackets for the result (all from original)
    intro i
    have h_br := hbr_ext ⟨i.val, by omega⟩
    convert h_br using 2
    · exact (extendEnv_init env z ⟨i.val, by omega⟩).symm
    · have : i.val + 1 < m' + 1 := by omega
      exact (extendEnv_init env z ⟨i.val + 1, by omega⟩).symm

/-! ## Leftward Existential Closure (Lemma 3.4, leftmost absorption)

The Since-mirror of `existClosure`: absorb the *leftmost* free variable `z_0` by
existential quantification. The leftmost interval bracket and `z_0`'s endpoint
predicate are converted to a temporal condition at `z_1` via `bracketBuildLeft`. -/

/-- Prepend a value `z` at index 0 of a `Fin m → X` environment, shifting the
    rest up, producing `Fin (m + 1) → X`. Mirror of `extendEnv`. -/
def prependEnv {α : Type*} {m : Nat} (z : α) (env : Fin m → α) :
    Fin (m + 1) → α :=
  fun i => if h : 0 < i.val then env ⟨i.val - 1, by omega⟩ else z

@[simp] theorem prependEnv_zero {α : Type*} {m : Nat} (z : α) (env : Fin m → α) :
    prependEnv z env ⟨0, by omega⟩ = z := by
  simp [prependEnv]

@[simp] theorem prependEnv_succ {α : Type*} {m : Nat} (z : α) (env : Fin m → α) (j : Fin m) :
    prependEnv z env ⟨j.val + 1, by omega⟩ = env j := by
  simp only [prependEnv, dif_pos (Nat.succ_pos j.val), Nat.add_sub_cancel, Fin.eta]

/-- Leftward existential closure: absorb the leftmost free variable `z_0` via
    existential quantification. The leftmost interval bracket (between `z_0` and
    `z_1`) and `z_0`'s endpoint predicate become a temporal condition at `z_1`
    via `bracketBuildLeft`, folded into `z_1`'s endpoint predicate. Remaining
    free variables reindex down by one.

    For m = 0: produces VecEA_m 0 (trivially empty).
    For m >= 1: the result has m free variables with the leftmost interval
    absorbed into `z_1`'s endpoint predicate. -/
noncomputable def VecEA_m.existClosureLeft {m : Nat}
    (vea : VecEA_m (m + 1)) : VecEA_m m :=
  match m with
  | 0 =>
    { endpointTypes := Fin.elim0
      intervalBrackets := fun i => absurd i.isLt (by omega) }
  | m' + 1 =>
    let leftBracket := vea.intervalBrackets ⟨0, by omega⟩
    let absorbedEndpoint := vea.endpointTypes ⟨0, by omega⟩
    let temporalCond := bracketBuildLeft leftBracket.2 absorbedEndpoint
    { endpointTypes := fun i =>
        if i.val = 0 then
          -- new z_0 = old z_1: conjoin original endpoint with temporal condition
          (vea.endpointTypes ⟨1, by omega⟩).conj ⟨temporalCond⟩
        else
          vea.endpointTypes ⟨i.val + 1, by omega⟩
      intervalBrackets := fun i =>
        vea.intervalBrackets ⟨i.val + 1, by omega⟩ }

/-- Forward direction of leftward absorption: if `existClosureLeft` holds on env,
    there exists z < env 0 extending env on the left such that vea holds. -/
theorem VecEA_m.existClosureLeft_correct {sig : MonadicSignature} {m : Nat}
    (hm : m ≥ 1)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m (m + 1))
    (env : Fin m → M.carrier)
    (henv_mono : StrictMono env) :
    vea.existClosureLeft.holds M atomMap env →
    ∃ z : M.carrier, z < env ⟨0, by omega⟩ ∧
      vea.holds M atomMap (prependEnv z env) := by
  obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
  intro ⟨hep_cl, hbr_cl⟩
  simp only [existClosureLeft] at hep_cl hbr_cl
  -- The endpoint at new position 0 has the conjoined temporal condition
  have hep_first := hep_cl ⟨0, by omega⟩
  simp only [if_pos] at hep_first
  rw [TemporalPred.eval_at_conj] at hep_first
  obtain ⟨hep_orig_first, htemp⟩ := hep_first
  simp only [TemporalPred.eval_at] at htemp
  rw [bracketBuildLeft_correct] at htemp
  obtain ⟨z, hz_lt, hz_ep, hz_br⟩ := htemp
  refine ⟨z, ?_, ?_, ?_⟩
  · -- z < env ⟨0, _⟩
    convert hz_lt using 2
  · -- All endpoint predicates of vea hold on prependEnv z env
    intro i
    by_cases hi : i.val = 0
    · -- i = 0: the absorbed variable, at z
      have hi0 : i = ⟨0, by omega⟩ := Fin.ext hi
      rw [hi0]
      simp only [prependEnv_zero]
      exact hz_ep
    · -- i = j + 1: from env
      obtain ⟨j, rfl⟩ : ∃ j : Fin (m' + 1), i = ⟨j.val + 1, by omega⟩ :=
        (by
        have hipos : 0 < i.val := Nat.pos_of_ne_zero hi
        have hlt := i.isLt
        exact ⟨⟨i.val - 1, by omega⟩, Fin.ext (show i.val = i.val - 1 + 1 from by omega)⟩)
      simp only [prependEnv_succ]
      by_cases hj : j.val = 0
      · -- j = 0: old z_1's endpoint at env 0
        have hj0 : j = ⟨0, by omega⟩ := Fin.ext hj
        rw [hj0]
        exact hep_orig_first
      · -- j >= 1: from existClosureLeft endpoint (else branch)
        have h := hep_cl j
        rw [if_neg hj] at h
        exact h
  · -- All interval brackets of vea hold on prependEnv z env
    intro i
    by_cases hi : i.val = 0
    · -- i = 0: interval (z, env 0) = leftBracket
      have hi0 : i = ⟨0, by omega⟩ := Fin.ext hi
      rw [hi0]
      simp only [prependEnv_zero, prependEnv_succ]
      convert hz_br using 2
    · -- i = j + 1: interval (env j, env (j+1)) = intervalBrackets (j+1)
      obtain ⟨j, rfl⟩ : ∃ j : Fin m', i = ⟨j.val + 1, by omega⟩ :=
        (by
        have hipos : 0 < i.val := Nat.pos_of_ne_zero hi
        have hlt := i.isLt
        exact ⟨⟨i.val - 1, by omega⟩, Fin.ext (show i.val = i.val - 1 + 1 from by omega)⟩)
      simp only [prependEnv_succ]
      convert hbr_cl j using 2

/-- Reverse direction of leftward absorption: if there exists z < env 0 such that
    vea holds on prependEnv z env, then existClosureLeft holds on env. -/
theorem VecEA_m.existClosureLeft_correct_rev {sig : MonadicSignature} {m : Nat}
    (hm : m ≥ 1)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m (m + 1))
    (env : Fin m → M.carrier)
    (henv_mono : StrictMono env)
    (z : M.carrier)
    (hz : z < env ⟨0, by omega⟩)
    (hvea : vea.holds M atomMap (prependEnv z env)) :
    vea.existClosureLeft.holds M atomMap env := by
  obtain ⟨hep_ext, hbr_ext⟩ := hvea
  obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
  simp only [existClosureLeft, holds]
  constructor
  · -- Endpoint predicates for the result
    intro i
    by_cases hi : i.val = 0
    · -- i = 0: conjoined endpoint
      have hi0 : i = ⟨0, by omega⟩ := Fin.ext hi
      rw [if_pos hi, TemporalPred.eval_at_conj, hi0]
      constructor
      · -- Original endpoint at env 0 = old z_1
        have h := hep_ext ⟨0 + 1, by omega⟩
        simp only [prependEnv_succ] at h
        exact h
      · -- Temporal condition at env 0
        simp only [TemporalPred.eval_at]
        rw [bracketBuildLeft_correct]
        refine ⟨z, hz, ?_, ?_⟩
        · -- absorbedEndpoint at z
          have h := hep_ext ⟨0, by omega⟩
          simp only [prependEnv_zero] at h
          exact h
        · -- leftBracket holds on (z, env 0)
          have h := hbr_ext ⟨0, by omega⟩
          simp only [prependEnv_zero, prependEnv_succ] at h
          convert h using 2
    · -- i = j + 1: original endpoint from env
      rw [if_neg hi]
      obtain ⟨j, rfl⟩ : ∃ j : Fin m', i = ⟨j.val + 1, by omega⟩ :=
        (by
        have hipos : 0 < i.val := Nat.pos_of_ne_zero hi
        have hlt := i.isLt
        exact ⟨⟨i.val - 1, by omega⟩, Fin.ext (show i.val = i.val - 1 + 1 from by omega)⟩)
      have h := hep_ext ⟨j.val + 1 + 1, by omega⟩
      simp only [prependEnv_succ] at h
      exact h
  · -- Interval brackets for the result
    intro i
    have h := hbr_ext ⟨i.val + 1, by omega⟩
    simp only [prependEnv_succ] at h
    convert h using 2

/-! ## VVecEA_m Existential Closure -/

/-- Existential closure for VVecEA_m: apply existClosure to each disjunct. -/
noncomputable def VVecEA_m.existClosure {m : Nat}
    (v : VVecEA_m (m + 1)) : VVecEA_m m :=
  { disjuncts := v.disjuncts.map fun vea => vea.existClosure }

/-! ## Specialization to m = 2: Bridge to VecEA2 -/

/-- Specialize a VecEA_m with m = 2 to VecEA2. -/
def VecEA_m.toVecEA2 (vea : VecEA_m 2) : Σ n, VecEA2 n :=
  let bracket := vea.intervalBrackets ⟨0, by omega⟩
  ⟨bracket.1,
    { endpointLeft := vea.endpointTypes ⟨0, by omega⟩
      endpointRight := vea.endpointTypes ⟨1, by omega⟩
      bracket := bracket.2 }⟩

/-- Semantics preservation: VecEA_m.toVecEA2 preserves holds. -/
theorem VecEA_m.toVecEA2_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m 2) (z0 z1 : M.carrier) :
    (vea.toVecEA2).2.holds M atomMap z0 z1 ↔
    vea.holds M atomMap (env2 z0 z1) := by
  simp only [toVecEA2, VecEA2.holds, VecEA_m.holds]
  constructor
  · rintro ⟨hel, her, hbr⟩
    constructor
    · intro i
      match i with
      | ⟨0, _⟩ => rw [env2_zero]; exact hel
      | ⟨1, _⟩ => rw [env2_one]; exact her
    · intro i
      match i with
      | ⟨0, _⟩ => rw [env2_zero, env2_one]; exact hbr
  · rintro ⟨hep, hbr⟩
    refine ⟨?_, ?_, ?_⟩
    · have := hep ⟨0, by omega⟩; rw [env2_zero] at this; exact this
    · have := hep ⟨1, by omega⟩; rw [env2_one] at this; exact this
    · have := hbr ⟨0, by omega⟩; rw [env2_zero, env2_one] at this; exact this

/-- Specialize a VVecEA_m with m = 2 to VVecEA2. -/
def VVecEA_m.toVVecEA2 (v : VVecEA_m 2) : VVecEA2 :=
  { disjuncts := v.disjuncts.map fun vea => vea.toVecEA2 }

/-- Semantics preservation: VVecEA_m.toVVecEA2 preserves holds. -/
theorem VVecEA_m.toVVecEA2_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA_m 2) (z0 z1 : M.carrier) :
    (v.toVVecEA2).holds M atomMap z0 z1 ↔
    v.holds M atomMap (env2 z0 z1) := by
  simp only [VVecEA2.holds, VVecEA_m.holds, toVVecEA2]
  constructor
  · rintro ⟨svea, hmem, hh⟩
    rw [List.mem_map] at hmem
    obtain ⟨vea_m, hmem', heq⟩ := hmem
    refine ⟨vea_m, hmem', (VecEA_m.toVecEA2_correct M atomMap vea_m z0 z1).mp ?_⟩
    subst heq; exact hh
  · rintro ⟨vea_m, hmem, hh⟩
    exact ⟨vea_m.toVecEA2, List.mem_map.mpr ⟨vea_m, hmem, rfl⟩,
      (VecEA_m.toVecEA2_correct M atomMap vea_m z0 z1).mpr hh⟩

/-! ## Singleton Constructors -/

/-- Wrap a single VecEA_m into a VVecEA_m. -/
def VecEA_m.toVVecEA_m {m : Nat} (vea : VecEA_m m) : VVecEA_m m :=
  { disjuncts := [vea] }

/-- A singleton VVecEA_m holds iff its single disjunct holds. -/
theorem VecEA_m.toVVecEA_m_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m m) (env : Fin m → M.carrier) :
    vea.toVVecEA_m.holds M atomMap env ↔ vea.holds M atomMap env := by
  simp only [toVVecEA_m, VVecEA_m.holds, List.mem_singleton]
  constructor
  · rintro ⟨vea', heq, hh⟩; rw [heq] at hh; exact hh
  · intro hh; exact ⟨vea, rfl, hh⟩

/-! ## Construction from VecEA2

Lift a VecEA2 to VecEA_m 2 for integration with the generalized framework. -/

/-- Lift a VecEA2 to VecEA_m 2. -/
def VecEA2.toVecEA_m {n : Nat} (vea : VecEA2 n) : VecEA_m 2 :=
  { endpointTypes := fun i =>
      if i.val = 0 then vea.endpointLeft else vea.endpointRight
    intervalBrackets := fun _ => ⟨n, vea.bracket⟩ }

/-- Lift a VVecEA2 to VVecEA_m 2. -/
def VVecEA2.toVVecEA_m (v : VVecEA2) : VVecEA_m 2 :=
  { disjuncts := v.disjuncts.map fun ⟨_, vea⟩ => vea.toVecEA_m }

/-- Roundtrip: VecEA2 -> VecEA_m 2 -> VecEA2 preserves semantics. -/
theorem VecEA2.toVecEA_m_toVecEA2_correct {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA2 n) (z0 z1 : M.carrier) :
    vea.holds M atomMap z0 z1 ↔
    vea.toVecEA_m.holds M atomMap (env2 z0 z1) := by
  simp only [VecEA2.holds, VecEA_m.holds, VecEA2.toVecEA_m]
  constructor
  · rintro ⟨hel, her, hbr⟩
    constructor
    · intro i
      match i with
      | ⟨0, _⟩ => simp [env2_zero]; exact hel
      | ⟨1, _⟩ => simp [env2_one]; exact her
    · intro i
      match i with
      | ⟨0, _⟩ => simp [env2_zero, env2_one]; exact hbr
  · rintro ⟨hep, hbr⟩
    refine ⟨?_, ?_, ?_⟩
    · have := hep ⟨0, by omega⟩; simp [env2_zero] at this; exact this
    · have := hep ⟨1, by omega⟩; simp [env2_one] at this; exact this
    · have := hbr ⟨0, by omega⟩; simp [env2_zero, env2_one] at this; exact this

end Bimodal.Metalogic.WeakCanonical.Kamp
