import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.WorldHistory
import Bimodal.Syntax.Formula

/-!
# Truth - Truth Evaluation in Task Semantics

This module defines truth evaluation for TM formulas in task models.

## Paper Specification Reference

**Bimodal Logic Semantics (app:TaskSemantics, def:BL-semantics, lines 1857-1866)**:
The JPL paper defines truth evaluation for TM formulas as follows:
- `M,τ,x ⊨ p` iff `τ(x) ∈ V(p)` (atom satisfaction)
- `M,τ,x ⊨ ⊥` is false (bottom)
- `M,τ,x ⊨ φ → ψ` iff `M,τ,x ⊨ φ` implies `M,τ,x ⊨ ψ` (implication)
- `M,τ,x ⊨ □φ` iff `M,σ,x ⊨ φ` for all σ ∈ Ω (box: necessity)
- `M,τ,x ⊨ Past φ` iff `M,τ,y ⊨ φ` for all y ∈ T where y < x (past)
- `M,τ,x ⊨ Future φ` iff `M,τ,y ⊨ φ` for all y ∈ T where x < y (future)

**ProofChecker Implementation Alignment**:
✓ Atom: `M.valuation (τ.states t ht) p` matches paper's `τ(x) ∈ V(p)`
✓ Bot: `False` matches paper's definition
✓ Imp: Standard material conditional matches paper
✓ Box: `∀ (σ : WorldHistory F) (hs : σ.domain t), truth_at M σ t hs φ`
  matches paper's quantification over all histories
✓ Past: `∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ`
  matches paper's quantification with domain restriction
✓ Future: `∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ`
  matches paper's quantification with domain restriction

**Semantic Verification (Task 3A.7)**:
Temporal operator implementations correctly restrict quantification to `s ∈ τ.domain`
(history's time domain), matching the paper's specification exactly. This is critical
for correct temporal semantics.

## Main Definitions

- `truth_at`: Truth of a formula at a model-history-time triple
- No notation defined (parsing conflicts with validity notation)

## Main Results

- Basic truth lemmas (e.g., `bot` is always false)
- Truth evaluation examples
- Time-shift preservation theorems for temporal operators

## Note on Bridge Theorems

Bridge theorems connecting the proof system to semantics (temporal duality infrastructure)
have been moved to `Metalogic/SoundnessLemmas.lean` to resolve circular dependencies.
See task 219 for details on the module hierarchy restructuring.

## Implementation Notes

- Truth is defined recursively on formula structure
- Modal box quantifies over all world histories at current time
- Temporal past/future quantify over earlier/later times in current history
- Times are Int for MVP simplicity

## References

* [ARCHITECTURE.md](../../../docs/UserGuide/ARCHITECTURE.md) - Truth evaluation
  specification
* [Formula.lean](../Syntax/Formula.lean) - Formula syntax
* [TaskModel.lean](TaskModel.lean) - Task model structure
* JPL Paper app:TaskSemantics (def:BL-semantics, lines 1857-1866) - Formal truth definition
-/

namespace Bimodal.Semantics

open Bimodal.Syntax

variable {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T] {F : TaskFrame T}

/--
Truth of a formula at a model-history-time triple.

Given:
- `M`: A task model (frame + valuation)
- `τ`: A world history (function from times to states)
- `t`: A time point
- `φ`: A formula

Returns whether `φ` is true at this semantic configuration.

The evaluation is defined recursively on formula structure:
- Atoms: true iff valuation says so at current state
- Bot (⊥): always false
- Implication: standard material conditional
- Box (□): true iff φ true at all world histories at time t
- Past (P): true iff φ true at all past times in current history
- Future (F): true iff φ true at all future times in current history
-/
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t) :
    Formula → Prop
  | Formula.atom p => M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t ht φ → truth_at M τ t ht ψ
  | Formula.box φ => ∀ (σ : WorldHistory F) (hs : σ.domain t), truth_at M σ t hs φ
  | Formula.all_past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ
  | Formula.all_future φ => ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ

-- Note: We avoid defining a notation for truth_at as it causes parsing conflicts
-- with the validity notation in Validity.lean. Use truth_at directly.

namespace Truth

/--
Bot (⊥) is false everywhere.
-/
theorem bot_false
    {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    {F : TaskFrame T} {M : TaskModel F} {τ : WorldHistory F}
    {t : T} {ht : τ.domain t} :
    ¬(truth_at M τ t ht Formula.bot) := by
  intro h
  exact h

/--
Truth of implication is material conditional.
-/
theorem imp_iff
    {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    {F : TaskFrame T} {M : TaskModel F} {τ : WorldHistory F}
    {t : T} {ht : τ.domain t}
    (φ ψ : Formula) :
    (truth_at M τ t ht (φ.imp ψ)) ↔
      ((truth_at M τ t ht φ) → (truth_at M τ t ht ψ)) := by
  rfl

/--
Truth of atom depends on valuation at current state.
-/
theorem atom_iff
    {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    {F : TaskFrame T} {M : TaskModel F} {τ : WorldHistory F}
    {t : T} {ht : τ.domain t}
    (p : String) :
    (truth_at M τ t ht (Formula.atom p)) ↔
      M.valuation (τ.states t ht) p := by
  rfl

/--
Truth of box: formula true at all histories at current time.
-/
theorem box_iff
    {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    {F : TaskFrame T} {M : TaskModel F} {τ : WorldHistory F}
    {t : T} {ht : τ.domain t}
    (φ : Formula) :
    (truth_at M τ t ht φ.box) ↔
      ∀ (σ : WorldHistory F) (hs : σ.domain t), (truth_at M σ t hs φ) := by
  rfl

/--
Truth of past: formula true at all earlier times in history.
-/
theorem past_iff
    {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    {F : TaskFrame T} {M : TaskModel F} {τ : WorldHistory F}
    {t : T} {ht : τ.domain t}
    (φ : Formula) :
    (truth_at M τ t ht φ.all_past) ↔
      ∀ (s : T) (hs : τ.domain s), s < t → (truth_at M τ s hs φ) := by
  rfl

/--
Truth of future: formula true at all later times in history.
-/
theorem future_iff
    {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    {F : TaskFrame T} {M : TaskModel F} {τ : WorldHistory F}
    {t : T} {ht : τ.domain t}
    (φ : Formula) :
    (truth_at M τ t ht φ.all_future) ↔
      ∀ (s : T) (hs : τ.domain s), t < s → (truth_at M τ s hs φ) := by
  rfl

end Truth

/-! ## Time-Shift Preservation

These lemmas establish that truth is preserved under time-shift transformations.
This is fundamental to proving the MF and TF axioms valid.

The key insight is that for a formula φ:
  `truth_at M σ y hy φ ↔ truth_at M (time_shift σ (y - x)) x hx φ`

This relates truth at (σ, y) to truth at (shifted_σ, x).
-/

namespace TimeShift

/--
Truth is independent of the domain membership proof (proof irrelevance for truth).

This auxiliary lemma is crucial for transporting truth between different domain membership proofs.
-/
theorem truth_proof_irrel (M : TaskModel F) (τ : WorldHistory F) (t : T)
    (ht₁ ht₂ : τ.domain t) (φ : Formula) :
    truth_at M τ t ht₁ φ ↔ truth_at M τ t ht₂ φ := by
  -- Proof by structural induction on φ
  induction φ generalizing t ht₁ ht₂ with
  | atom p =>
    -- τ.states t ht₁ = τ.states t ht₂ by proof irrelevance, so both sides are equal
    rfl
  | bot =>
    rfl
  | imp ψ χ ih_ψ ih_χ =>
    constructor
    · intro h h_ψ
      have := (ih_ψ t ht₁ ht₂).mpr h_ψ
      exact (ih_χ t ht₁ ht₂).mp (h this)
    · intro h h_ψ
      have := (ih_ψ t ht₁ ht₂).mp h_ψ
      exact (ih_χ t ht₁ ht₂).mpr (h this)
  | box ψ _ =>
    rfl
  | all_past ψ _ =>
    rfl
  | all_future ψ _ =>
    rfl

/--
Truth transport across equal histories.

When two histories are equal and both domain proofs are valid, truth is preserved.
-/
theorem truth_history_eq (M : TaskModel F) (τ₁ τ₂ : WorldHistory F) (t : T)
    (ht₁ : τ₁.domain t) (ht₂ : τ₂.domain t) (h_eq : τ₁ = τ₂) (φ : Formula) :
    truth_at M τ₁ t ht₁ φ ↔ truth_at M τ₂ t ht₂ φ := by
  cases h_eq
  exact truth_proof_irrel M τ₁ t ht₁ ht₂ φ

/--
Truth at double time-shift with opposite amounts equals truth at original history.

This is the key transport lemma for the box case of time_shift_preserves_truth.
It allows us to transfer truth from (time_shift (time_shift σ Δ) (-Δ)) back to σ.
-/
theorem truth_double_shift_cancel (M : TaskModel F) (σ : WorldHistory F) (Δ : T) (t : T)
    (ht : σ.domain t) (ht' : (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)).domain t)
    (φ : Formula) :
    truth_at M (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)) t ht' φ ↔
    truth_at M σ t ht φ := by
  induction φ generalizing t ht ht' with
  | atom p =>
    simp only [truth_at]
    have h_eq := WorldHistory.time_shift_time_shift_neg_states σ Δ t ht ht'
    rw [h_eq]
  | bot =>
    simp only [truth_at]
  | imp ψ χ ih_ψ ih_χ =>
    simp only [truth_at]
    constructor
    · intro h h_ψ
      have h_ψ' := (ih_ψ t ht ht').mpr h_ψ
      exact (ih_χ t ht ht').mp (h h_ψ')
    · intro h h_ψ'
      have h_ψ := (ih_ψ t ht ht').mp h_ψ'
      exact (ih_χ t ht ht').mpr (h h_ψ)
  | box ψ ih =>
    simp only [truth_at]
    -- Box quantifies over ALL histories at time t, independent of current history
    -- Both sides quantify over the same set of histories
  | all_past ψ ih =>
    simp only [truth_at]
    constructor
    · intro h s hs h_lt
      -- Need domain proof for s in double-shift
      have hs' : (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)).domain s := by
        exact (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ s).mpr hs
      exact (ih s hs hs').mp (h s hs' h_lt)
    · intro h s hs' h_lt
      -- Need domain proof for s in original
      have hs : σ.domain s := by
        exact (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ s).mp hs'
      exact (ih s hs hs').mpr (h s hs h_lt)
  | all_future ψ ih =>
    simp only [truth_at]
    constructor
    · intro h s hs h_lt
      have hs' : (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)).domain s := by
        exact (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ s).mpr hs
      exact (ih s hs hs').mp (h s hs' h_lt)
    · intro h s hs' h_lt
      have hs : σ.domain s := by
        exact (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ s).mp hs'
      exact (ih s hs hs').mpr (h s hs h_lt)

/--
Time-shift preserves truth of formulas.

If σ is a history and Δ = y - x, then truth at (σ, y) equals truth at (time_shift σ Δ, x).

**Paper Reference**: lem:history-time-shift-preservation establishes this property.

The proof proceeds by structural induction on formulas:
- **Atom**: States match because (time_shift σ Δ).states x = σ.states (x + Δ) = σ.states y
- **Bot**: Both sides are False
- **Imp**: By induction hypothesis on subformulas
- **Box**: Both quantify over ALL histories at their respective times; using a bijection
  between histories at x and histories at y via time-shift
- **Past/Future**: Times shift together with the history

**Key Insight**: The box case is the crucial one. For any history ρ at time x,
`time_shift ρ (-Δ)` gives a history at time y (since x + Δ = y means x = y - Δ).
This establishes a bijection between histories at the two times.
-/
theorem time_shift_preserves_truth (M : TaskModel F) (σ : WorldHistory F) (x y : T)
    (hx : (WorldHistory.time_shift σ (y - x)).domain x) (hy : σ.domain y) (φ : Formula) :
    truth_at M (WorldHistory.time_shift σ (y - x)) x hx φ ↔ truth_at M σ y hy φ := by
  -- Proof by structural induction on φ
  induction φ generalizing x y hx hy σ with
  | atom p =>
    -- For atoms, states must match
    -- (time_shift σ Δ).states x = σ.states (x + Δ) = σ.states y
    simp only [truth_at, WorldHistory.time_shift]
    -- Need to show: M.valuation (σ.states (x + (y - x)) hx) p ↔ M.valuation (σ.states y hy) p
    have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
    -- Use states_eq_of_time_eq to transport states from (x + (y - x)) to y
    rw [WorldHistory.states_eq_of_time_eq σ (x + (y - x)) y h_eq _ hy]

  | bot =>
    -- Both sides are False
    simp only [truth_at]

  | imp ψ χ ih_ψ ih_χ =>
    -- By IH on both subformulas
    simp only [truth_at]
    constructor
    · intro h h_psi
      have h_psi' := (ih_ψ σ x y hx hy).mpr h_psi
      exact (ih_χ σ x y hx hy).mp (h h_psi')
    · intro h h_psi'
      have h_psi := (ih_ψ σ x y hx hy).mp h_psi'
      exact (ih_χ σ x y hx hy).mpr (h h_psi)

  | box ψ ih =>
    -- For box, both quantify over ALL histories at their times
    -- We use the fact that time-shift gives a bijection between histories at x and y
    simp only [truth_at]
    constructor
    · intro h_box_x ρ hρ_y
      -- ρ is a history at time y
      -- time_shift ρ (y - x) is a history at time x
      -- (domain at x iff ρ domain at x + (y-x) = y)
      have hρ_x : (WorldHistory.time_shift ρ (y - x)).domain x := by
        simp only [WorldHistory.time_shift]
        have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
        rw [h_eq]
        exact hρ_y
      have h1 := h_box_x (WorldHistory.time_shift ρ (y - x)) hρ_x
      -- Apply IH with ρ instead of σ
      exact (ih ρ x y hρ_x hρ_y).mp h1
    · intro h_box_y ρ hρ_x
      -- ρ is a history at time x
      -- time_shift ρ (-(y - x)) = time_shift ρ (x - y) is a history at time y
      have hρ_y : (WorldHistory.time_shift ρ (x - y)).domain y := by
        simp only [WorldHistory.time_shift]
        have h_eq : y + (x - y) = x := by rw [add_sub, add_sub_cancel_left]
        rw [h_eq]
        exact hρ_x
      have h1 := h_box_y (WorldHistory.time_shift ρ (x - y)) hρ_y
      -- We need to relate back:
      -- time_shift (time_shift ρ (x-y)) (y-x) at x equals ρ at x
      -- The key insight: double shift cancels out
      -- (time_shift (time_shift ρ (x-y)) (y-x)).states x
      --   = ρ.states (x + (y-x) + (x-y)) = ρ.states x

      -- First, apply IH to get truth at double-shifted history
      have hρ_x' :
        (WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (y - x)).domain x := by
        simp only [WorldHistory.time_shift]
        have h_eq : x + (y - x) + (x - y) = x := by
          have h1 : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
          rw [h1]
          rw [add_sub, add_sub_cancel_left]
        rw [h_eq]
        exact hρ_x
      -- Apply IH with time_shift ρ (x - y) instead of σ
      have h2 :=
        (ih (WorldHistory.time_shift ρ (x - y)) x y hρ_x' hρ_y).mpr h1
      -- h2 : truth_at M (time_shift (time_shift ρ (x-y)) (y-x))
      --        x hρ_x' ψ
      -- Need: truth_at M ρ x hρ_x ψ

      -- Key insight: (y-x) = -(x-y), so double shift cancels
      have h_cancel : y - x = -(x - y) := (neg_sub x y).symm
      -- Use history extensionality to rewrite the double shift
      have h_hist_eq :
        WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (y - x) =
        WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (-(x - y)) := by
        exact WorldHistory.time_shift_congr
          (WorldHistory.time_shift ρ (x - y)) (y - x) (-(x - y)) h_cancel
      -- Transport domain proof using history equality
      have hρ_x'' :
        (WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (-(x - y))).domain x := by
        rw [← h_hist_eq]
        exact hρ_x'
      -- Transport truth using history equality
      have h2' :
        truth_at M
          (WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (-(x - y)))
          x hρ_x'' ψ := by
        exact (truth_history_eq M _ _ x hρ_x' hρ_x'' h_hist_eq ψ).mp h2
      -- Use truth_double_shift_cancel to transport from
      -- double-shifted history to original
      exact (truth_double_shift_cancel M ρ (x - y) x hρ_x hρ_x'' ψ).mp h2'

  | all_past ψ ih =>
    -- Past quantifies over earlier times in the same history
    -- Times shift together: r < y in σ corresponds to r-(y-x) < x in shifted history
    simp only [truth_at]
    constructor
    · intro h_past s hs h_s_lt_y
      -- s < y in σ, need to show truth at s in σ
      -- Use shifted time: s' = s - (y - x) < x
      have hs_shifted : (WorldHistory.time_shift σ (y - x)).domain (s - (y - x)) := by
        simp only [WorldHistory.time_shift]
        have : (s - (y - x)) + (y - x) = s := sub_add_cancel s (y - x)
        rw [this]
        exact hs
      have h_s_shifted_lt_x : s - (y - x) < x := by
        have h := sub_lt_sub_right h_s_lt_y (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      have h_truth_shifted := h_past (s - (y - x)) hs_shifted h_s_shifted_lt_x
      -- Apply IH: need to show (time_shift σ (y - x), s - (y - x)) ↔ (σ, s)
      -- The shift amount should be: s - (s - (y - x)) = y - x
      have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
      -- Use congruence to equate the histories
      have h_hist_eq :
        WorldHistory.time_shift σ (s - (s - (y - x))) =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
      -- Create domain proof for IH
      have hs_ih :
        (WorldHistory.time_shift σ (s - (s - (y - x)))).domain (s - (y - x)) := by
        rw [h_hist_eq]
        exact hs_shifted
      -- Transport truth using history equality
      have h_truth_ih :
        truth_at M (WorldHistory.time_shift σ (s - (s - (y - x))))
          (s - (y - x)) hs_ih ψ := by
        exact (truth_history_eq M _ _ (s - (y - x)) hs_shifted hs_ih
          h_hist_eq.symm ψ).mp h_truth_shifted
      -- Apply IH
      exact (ih σ (s - (y - x)) s hs_ih hs).mp h_truth_ih
    · intro h_past s' hs' h_s'_lt_x
      -- s' < x in shifted σ, need to show truth at s' in shifted σ
      -- s' corresponds to time s = s' + (y - x) in σ
      have hs : σ.domain (s' + (y - x)) := by
        simp only [WorldHistory.time_shift] at hs'
        exact hs'
      have h_s_lt_y : s' + (y - x) < y := by
        have h := add_lt_add_right h_s'_lt_x (y - x)
        -- Use group lemmas: s' < x implies s' + (y-x) < x + (y-x) = y
        -- Note: add_lt_add_right produces (y-x) + s' < (y-x) + x, so use commutativity
        calc s' + (y - x) = (y - x) + s' := add_comm s' (y - x)
          _ < (y - x) + x := h
          _ = x + (y - x) := add_comm (y - x) x
          _ = y := by rw [add_sub, add_sub_cancel_left]
      have h_truth_orig := h_past (s' + (y - x)) hs h_s_lt_y
      -- Apply IH: need shift amount = (s' + (y - x)) - s' = y - x
      have h_shift_eq : (s' + (y - x)) - s' = y - x :=
        add_sub_cancel_left s' (y - x)
      -- Use congruence to equate histories
      have h_hist_eq :
        WorldHistory.time_shift σ ((s' + (y - x)) - s') =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ ((s' + (y - x)) - s')
          (y - x) h_shift_eq
      -- Create domain proof for IH
      have hs'_ih :
        (WorldHistory.time_shift σ ((s' + (y - x)) - s')).domain s' := by
        rw [h_hist_eq]
        exact hs'
      -- Apply IH and transport
      have h_ih :=
        (ih σ s' (s' + (y - x)) hs'_ih hs).mpr h_truth_orig
      -- Transport using history equality
      exact (truth_history_eq M _ _ s' hs'_ih hs' h_hist_eq ψ).mp h_ih

  | all_future ψ ih =>
    -- Similar to past case: r > y in σ corresponds to r-(y-x) > x in shifted history
    simp only [truth_at]
    constructor
    · intro h_future s hs h_y_lt_s
      -- y < s in σ, need to show truth at s in σ
      -- Use shifted time: s' = s - (y - x) > x
      have hs_shifted : (WorldHistory.time_shift σ (y - x)).domain (s - (y - x)) := by
        simp only [WorldHistory.time_shift]
        have : (s - (y - x)) + (y - x) = s := sub_add_cancel s (y - x)
        rw [this]
        exact hs
      have h_x_lt_s_shifted : x < s - (y - x) := by
        have h := sub_lt_sub_right h_y_lt_s (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      have h_truth_shifted := h_future (s - (y - x)) hs_shifted h_x_lt_s_shifted
      -- Apply IH with shift amount s - (s - (y - x)) = y - x
      have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
      -- Use congruence to equate histories
      have h_hist_eq :
        WorldHistory.time_shift σ (s - (s - (y - x))) =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
      -- Create domain proof for IH
      have hs_ih :
        (WorldHistory.time_shift σ (s - (s - (y - x)))).domain (s - (y - x)) := by
        rw [h_hist_eq]
        exact hs_shifted
      -- Transport truth using history equality
      have h_truth_ih :
        truth_at M (WorldHistory.time_shift σ (s - (s - (y - x))))
          (s - (y - x)) hs_ih ψ := by
        exact (truth_history_eq M _ _ (s - (y - x)) hs_shifted hs_ih
          h_hist_eq.symm ψ).mp h_truth_shifted
      -- Apply IH
      exact (ih σ (s - (y - x)) s hs_ih hs).mp h_truth_ih
    · intro h_future s' hs' h_x_lt_s'
      -- x < s' in shifted σ, need to show truth at s' in shifted σ
      -- s' corresponds to time s = s' + (y - x) in σ
      have hs : σ.domain (s' + (y - x)) := by
        simp only [WorldHistory.time_shift] at hs'
        exact hs'
      have h_y_lt_s : y < s' + (y - x) := by
        have h := add_lt_add_right h_x_lt_s' (y - x)
        -- h : (y - x) + x < (y - x) + s'  (from add_lt_add_right)
        -- Need: y < s' + (y - x)
        -- Since x + (y - x) = y
        have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
        -- Use commutativity to match the argument order
        calc y = x + (y - x) := h_eq.symm
          _ = (y - x) + x := add_comm x (y - x)
          _ < (y - x) + s' := h
          _ = s' + (y - x) := add_comm (y - x) s'
      have h_truth_orig := h_future (s' + (y - x)) hs h_y_lt_s
      -- Apply IH with shift amount (s' + (y - x)) - s' = y - x
      have h_shift_eq : (s' + (y - x)) - s' = y - x :=
        add_sub_cancel_left s' (y - x)
      -- Use congruence to equate histories
      have h_hist_eq :
        WorldHistory.time_shift σ ((s' + (y - x)) - s') =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ ((s' + (y - x)) - s')
          (y - x) h_shift_eq
      -- Create domain proof for IH
      have hs'_ih :
        (WorldHistory.time_shift σ ((s' + (y - x)) - s')).domain s' := by
        rw [h_hist_eq]
        exact hs'
      -- Apply IH and transport
      have h_ih := (ih σ s' (s' + (y - x)) hs'_ih hs).mpr h_truth_orig
      -- Transport using history equality
      exact (truth_history_eq M _ _ s' hs'_ih hs' h_hist_eq ψ).mp h_ih

/--
Corollary: For any history σ at time y, there exists a history at time x
(namely, time_shift σ (y - x)) where the same formulas are true.

This is the key lemma for proving MF and TF axioms.
-/
theorem exists_shifted_history (M : TaskModel F) (σ : WorldHistory F) (x y : T)
    (hy : σ.domain y) (φ : Formula) :
    truth_at M σ y hy φ ↔
    truth_at M (WorldHistory.time_shift σ (y - x)) x
      (by
        simp only [WorldHistory.time_shift]
        have h : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
        rw [h]
        exact hy) φ := by
  have hx : (WorldHistory.time_shift σ (y - x)).domain x := by
    simp only [WorldHistory.time_shift]
    have h : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
    rw [h]
    exact hy
  exact (time_shift_preserves_truth M σ x y hx hy φ).symm

end TimeShift


end Bimodal.Semantics
