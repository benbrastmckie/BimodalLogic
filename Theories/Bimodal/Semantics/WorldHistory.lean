import Bimodal.Semantics.TaskFrame

/-!
# WorldHistory - World Histories for Task Semantics

This module defines world histories, which are functions from time domains to world states.

## Paper Specification Reference

**World Histories (app:TaskSemantics, def:world-history, line 1849)**:
The JPL paper defines world histories (possible worlds) as functions `τ: X → W`
where `X ⊆ D` is a **convex** subset of the time group `D` and the function respects
the task relation: for all `x, y ∈ X` with `x ≤ y`, we have `τ(y) ∈ τ(x) · (y - x)`.

**ProofChecker Implementation**:
- `domain: D → Prop` represents the convex time subset `X ⊆ D`
- `convex` field enforces the paper's convexity requirement explicitly
- `states: (t: D) → domain t → F.WorldState` represents the function `τ: X → W`
- `respects_task` constraint matches the paper's requirement exactly

**Convexity Requirement**: A domain is convex if whenever `x, z ∈ domain` with `x ≤ z`,
then all times `y` with `x ≤ y ≤ z` are also in the domain. This ensures histories
have no "gaps" in time.

**Critical Semantic Points**:
1. Box operator quantifies over ALL histories at time x
2. Past/Future operators quantify over times in the SAME history
3. Times must be in history's domain for evaluation
4. Domains must be convex (no temporal gaps)

## Main Definitions

- `WorldHistory F`: World history structure with convex domain and task constraint

## Main Results

- Example world histories (constant, trivial, universal) with convexity proofs
- Time-shift construction preserving convexity

## Implementation Notes

- Type parameter `D` represents temporal durations with ordered additive group structure
- Domain is represented as a predicate `D → Prop`
- Convexity is now formally enforced (matching paper definition exactly)
- History must respect the task relation (compositionality)

## References

* [ARCHITECTURE.md](../../../docs/UserGuide/ARCHITECTURE.md) - World history specification
* [TaskFrame.lean](TaskFrame.lean) - Task frame structure
* JPL Paper app:TaskSemantics (def:world-history, line 1849) - Formal world history definition
-/

namespace Bimodal.Semantics

/--
World history for a task frame.

A world history assigns a world state to each time in its domain,
such that the history respects the task relation of the frame.

**Type Parameters**:
- `D`: Temporal duration type with totally ordered abelian group structure
- `F`: Task frame over temporal type `D`

**Paper Alignment**: Matches JPL paper def:world-history (line 1849) with
explicit convexity constraint on domain.
-/
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) where
  /-- Domain predicate (which times are in the history) -/
  domain : D → Prop
  /--
  Convexity constraint: domain has no temporal gaps.

  If times `x` and `z` are in the domain with `x ≤ z`, then every time `y`
  between them (`x ≤ y ≤ z`) must also be in the domain.

  **Paper Reference**: JPL paper def:world-history (line 1849) requires domain
  to be a convex subset of the time group.
  -/
  convex : ∀ (x z : D), domain x → domain z → ∀ (y : D), x ≤ y → y ≤ z → domain y
  /--
  State assignment function.

  For each time `t` in the domain, assigns a world state.
  -/
  states : (t : D) → domain t → F.WorldState
  /--
  Task relation respect constraint.

  For any times `s, t` in domain with `s ≤ t`, the states at `s` and `t`
  must be related by the task relation with duration `t - s`.

  This ensures the history is consistent with possible task executions.
  -/
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)

namespace WorldHistory

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}

/--
Universal world history over all time (requires explicit reflexivity proof).

This history has every time in its domain and assigns the same world state everywhere.

**Frame Constraint Required**: Reflexivity proof parameter

A frame is reflexive if for all world states `w` and durations `d`, the task relation
`task_rel w d w` holds. This is stronger than nullity (which only requires `task_rel w 0 w`).

**Examples of Reflexive Frames**:
- `trivialFrame`: task_rel is always True (reflexive)
- `natFrame`: task_rel is always True (reflexive)

**Non-Reflexive Frame Example**:
- `identityFrame`: task_rel only holds at duration 0 (not reflexive for d ≠ 0)

**Justification**: For a constant history to respect the task relation, we need
`task_rel w (t - s) w` for all times `s ≤ t`. Nullity only gives this when `s = t`.
Compositionality alone cannot build arbitrary-duration self-loops without additional
frame properties.

**Usage**: Call this function with a proof that `∀ d, F.task_rel w d w`. For common frames,
use the frame-specific constructors `universal_trivialFrame` or `universal_natFrame` instead.

**Parameters**:
- `F`: The task frame
- `w`: The constant world state for all times
- `h_refl`: Proof that the frame is reflexive at state `w` for all durations
-/
def universal (F : TaskFrame D) (w : F.WorldState)
    (h_refl : ∀ d : D, F.task_rel w d w) : WorldHistory F where
  domain := fun _ => True
  convex := by
    intros x z hx hz y hxy hyz
    -- Full domain is trivially convex
    exact True.intro
  states := fun _ _ => w
  respects_task := by
    intros s t hs ht hst
    -- Use the reflexivity proof for duration (t - s)
    exact h_refl (t - s)

/--
Trivial world history for the trivial frame.

Since trivial frame's task relation is always true, this always works.
The full domain is convex.
-/
def trivial {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    WorldHistory (TaskFrame.trivial_frame (D := D)) where
  domain := fun _ => True
  convex := by
    intros x z hx hz y hxy hyz
    exact True.intro
  states := fun _ _ => ()
  respects_task := by
    intros s t hs ht hst
    exact True.intro

/--
Universal world history for trivial frame with a specific constant state.

This is a variant of `trivial` that allows specifying the constant state
(though in trivialFrame, WorldState = Unit, so this is equivalent to `trivial`).

Since trivialFrame's task relation is always true, any constant history respects the task relation.
The full domain is convex.
-/
def universal_trivialFrame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (w : (TaskFrame.trivial_frame (D := D)).WorldState) :
    WorldHistory (TaskFrame.trivial_frame (D := D)) where
  domain := fun _ => True
  convex := by
    intros x z hx hz y hxy hyz
    exact True.intro
  states := fun _ _ => w
  respects_task := by
    intros s t hs ht hst
    exact True.intro

/--
Universal world history for nat frame with a specific constant Nat state.

Since natFrame's task relation is always true (for any states and duration),
any constant history respects the task relation.

This demonstrates that reflexive frames (where `task_rel w d w` for all `w, d`)
admit universal constant histories. The full domain is convex.
-/
def universal_natFrame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (n : Nat) :
    WorldHistory (TaskFrame.nat_frame (D := D)) where
  domain := fun _ => True
  convex := by
    intros x z hx hz y hxy hyz
    exact True.intro
  states := fun _ _ => n
  respects_task := by
    intros s t hs ht hst
    -- natFrame.task_rel is always True
    exact True.intro

/--
Get the state at a time (helper function that bundles membership proof).
-/
def state_at (τ : WorldHistory F) (t : D) (h : τ.domain t) : F.WorldState :=
  τ.states t h

/-! ## Time-Shift Construction

The time-shift construction is fundamental to proving MF and TF axioms.
Given a history σ and times x, y, we construct a shifted history where
σ'(z) = σ(z + (y - x)).

This corresponds to "viewing σ from time x instead of time y".
-/

/--
Time-shifted history construction.

Given history `σ` and shift offset `Δ = y - x`, construct history `τ` where:
- `τ.domain z ↔ σ.domain (z + Δ)`
- `τ.states z = σ.states (z + Δ)`

This allows us to relate truth at (σ, y) to truth at (τ, x).

**Paper Reference**: app:auto_existence (line ~2330) defines time-shift automorphisms.

**Key Property**: If σ respects the task relation and has convex domain,
so does the shifted history, because:
1. Task relation only depends on duration (t - s), preserved under translation
2. Convexity is preserved under translation by group structure
-/
def time_shift (σ : WorldHistory F) (Δ : D) : WorldHistory F where
  domain := fun z => σ.domain (z + Δ)
  convex := by
    intros x z hx hz y hxy hyz
    -- Need: σ.domain (y + Δ)
    -- Have: σ.domain (x + Δ) and σ.domain (z + Δ) with x ≤ y ≤ z
    -- By convexity of σ, need to show (x + Δ) ≤ (y + Δ) ≤ (z + Δ)
    have hxy' : x + Δ ≤ y + Δ := by rw [add_comm x, add_comm y]; exact add_le_add_right hxy Δ
    have hyz' : y + Δ ≤ z + Δ := by rw [add_comm y, add_comm z]; exact add_le_add_right hyz Δ
    exact σ.convex (x + Δ) (z + Δ) hx hz (y + Δ) hxy' hyz'
  states := fun z hz => σ.states (z + Δ) hz
  respects_task := by
    intros s t hs ht hst
    -- Need: task_rel (σ.states (s + Δ)) (t - s) (σ.states (t + Δ))
    -- We have: σ respects task, so
    -- task_rel (σ.states (s + Δ)) ((t + Δ) - (s + Δ)) (σ.states (t + Δ))
    -- Since (t + Δ) - (s + Δ) = t - s, this is exactly what we need
    have h_shifted : s + Δ ≤ t + Δ := by rw [add_comm s, add_comm t]; exact add_le_add_right hst Δ
    have h_duration : (t + Δ) - (s + Δ) = t - s := by
      -- (t + Δ) - (s + Δ) = t - s by group theory
      rw [add_sub_add_right_eq_sub]
    rw [← h_duration]
    exact σ.respects_task (s + Δ) (t + Δ) hs ht h_shifted

/--
Time-shift preserves domain membership (forward direction).
If z is in the shifted domain, then z + Δ is in the original domain.
-/
theorem time_shift_domain_iff (σ : WorldHistory F) (Δ z : D) :
    (time_shift σ Δ).domain z ↔ σ.domain (z + Δ) := by
  rfl

/--
Inverse time-shift: shifting by -Δ undoes shifting by Δ on the domain.
-/
theorem time_shift_inverse_domain (σ : WorldHistory F) (Δ : D) (z : D) :
    (time_shift (time_shift σ Δ) (-Δ)).domain z ↔ σ.domain z := by
  simp only [time_shift]
  constructor
  · intro h
    have : z + -Δ + Δ = z := by
      rw [add_assoc, neg_add_cancel, add_zero]
    rw [this] at h
    exact h
  · intro h
    have : z + -Δ + Δ = z := by
      rw [add_assoc, neg_add_cancel, add_zero]
    rw [this]
    exact h

/--
States are equal when times are provably equal (proof irrelevance).

This lemma allows us to transport states from one time to another when the times
are equal. This is essential for dependent type reasoning in time-shift proofs.
-/
theorem states_eq_of_time_eq (σ : WorldHistory F) (t₁ t₂ : D)
    (h : t₁ = t₂) (ht₁ : σ.domain t₁) (ht₂ : σ.domain t₂) :
    σ.states t₁ ht₁ = σ.states t₂ ht₂ := by
  subst h
  rfl

/--
Double time-shift cancels: states at (time_shift (time_shift σ Δ) (-Δ)) equal states at σ.

This is the key transport lemma for the box case of time_shift_preserves_truth.
It shows that shifting by Δ and then by -Δ returns to the original states.
-/
theorem time_shift_time_shift_states (σ : WorldHistory F) (Δ : D) (t : D)
    (ht : σ.domain t)
    (ht' : (time_shift (time_shift σ Δ) (-Δ)).domain t) :
    (time_shift (time_shift σ Δ) (-Δ)).states t ht' = σ.states t ht := by
  simp only [time_shift]
  have h_eq : t + -Δ + Δ = t := by
    rw [add_assoc, neg_add_cancel, add_zero]
  exact states_eq_of_time_eq σ (t + -Δ + Δ) t h_eq _ ht

/--
Extensionality lemma for time_shift: shifting by equal amounts gives equal histories.
-/
theorem time_shift_congr (σ : WorldHistory F) (Δ₁ Δ₂ : D) (h : Δ₁ = Δ₂) :
    time_shift σ Δ₁ = time_shift σ Δ₂ := by
  subst h
  rfl

/--
Domain membership for time_shift by zero is equivalent to original domain.
-/
theorem time_shift_zero_domain_iff (σ : WorldHistory F) (z : D) :
    (time_shift σ 0).domain z ↔ σ.domain z := by
  simp only [time_shift, add_zero]

/--
Domain membership for double time-shift with opposite amounts equals original.
-/
theorem time_shift_time_shift_neg_domain_iff (σ : WorldHistory F) (Δ : D) (z : D) :
    (time_shift (time_shift σ Δ) (-Δ)).domain z ↔ σ.domain z := by
  simp only [time_shift]
  have h : z + -Δ + Δ = z := by
    rw [add_assoc, neg_add_cancel, add_zero]
  constructor
  · intro hd; rw [h] at hd; exact hd
  · intro hd; rw [h]; exact hd

/--
States at double time-shift with opposite amounts equals original states.
-/
theorem time_shift_time_shift_neg_states (σ : WorldHistory F) (Δ : D) (t : D)
    (ht : σ.domain t) (ht' : (time_shift (time_shift σ Δ) (-Δ)).domain t) :
    (time_shift (time_shift σ Δ) (-Δ)).states t ht' = σ.states t ht := by
  simp only [time_shift]
  have h_eq : t + -Δ + Δ = t := by
    rw [add_assoc, neg_add_cancel, add_zero]
  exact states_eq_of_time_eq σ (t + -Δ + Δ) t h_eq _ ht

/-! ## Order Reversal Lemmas

These lemmas establish that group inverse (negation) provides an order-reversing
automorphism on any ordered additive group. This is crucial for proving
temporal duality soundness: swapping past and future corresponds to time reversal
via group inverse.

The key insight is that ordered additive group structure provides temporal
symmetry without requiring additional frame constraints.
-/

/--
Group inverse reverses strict order: s < t ↔ -t < -s

This order reversal is the algebraic foundation for temporal duality.
When we swap Past and Future operators, the time domain reverses under group inverse.
-/
theorem neg_lt_neg_iff (s t : D) : s < t ↔ -t < -s := by
  constructor
  · intro h
    -- s < t implies -t < -s
    exact neg_lt_neg h
  · intro h
    -- -t < -s implies s < t
    -- Rewrite s and t as double negatives
    have hs : s = -(-s) := by simp
    have ht : t = -(-t) := by simp
    rw [hs, ht]
    exact neg_lt_neg h

/--
Group inverse reverses non-strict order: s ≤ t ↔ -t ≤ -s
-/
theorem neg_le_neg_iff (s t : D) : s ≤ t ↔ -t ≤ -s := by
  constructor
  · intro h
    exact neg_le_neg h
  · intro h
    have hs : s = -(-s) := by simp
    have ht : t = -(-t) := by simp
    rw [hs, ht]
    exact neg_le_neg h

/--
Double negation is identity: -(-t) = t
-/
theorem neg_neg_eq (t : D) : -(-t) = t := by
  simp

/--
Group inverse is injective: -s = -t ↔ s = t
-/
theorem neg_injective (s t : D) : -s = -t ↔ s = t := by
  constructor
  · intro h
    have : -(-s) = -(-t) := by rw [h]
    simp at this
    exact this
  · intro h
    rw [h]

end WorldHistory

end Bimodal.Semantics
