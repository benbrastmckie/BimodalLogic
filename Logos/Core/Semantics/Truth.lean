import Logos.Core.Semantics.TaskModel
import Logos.Core.Semantics.WorldHistory
import Logos.Core.Syntax.Formula
import Logos.Core.ProofSystem.Axioms
import Logos.Core.ProofSystem.Derivation

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
- **Temporal Duality Infrastructure** (2025-12-23, Branch B):
  - `axiom_swap_valid`: All 10 TM axioms remain valid after swap
  - `derivable_implies_swap_valid`: Main theorem for soundness of `temporal_duality`
  - Local time-shift transport lemmas power MF/TF without global time-reversal axioms

## Temporal Duality Approach (Approach D, Branch B)

The temporal duality soundness proof uses **derivation induction** rather than formula
induction. The key insight is that we only need swap validity for DERIVABLE formulas, not
all valid formulas. This avoids the impossible cases that arise when trying to prove
`is_valid φ → is_valid φ.swap` for arbitrary valid formulas via formula induction and
keeps the proof within the current model class (no new frame/domain axioms).

**Key Theorems**:
1. `swap_axiom_*_valid`: Each axiom schema remains valid after swap
2. `*_preserves_swap_valid`: Each inference rule preserves swap validity
3. `axiom_swap_valid`: Master theorem for all 10 axioms
4. `derivable_implies_swap_valid`: `Derivable [] φ → is_valid φ.swap_past_future`

## Implementation Notes

- Truth is defined recursively on formula structure
- Modal box quantifies over all world histories at current time
- Temporal past/future quantify over earlier/later times in current history
- Times are Int for MVP simplicity

## References

* [ARCHITECTURE.md](../../../Documentation/UserGuide/ARCHITECTURE.md) - Truth evaluation
  specification
* [Formula.lean](../Syntax/Formula.lean) - Formula syntax
* [TaskModel.lean](TaskModel.lean) - Task model structure
* JPL Paper app:TaskSemantics (def:BL-semantics, lines 1857-1866) - Formal truth definition
-/

namespace Logos.Core.Semantics

open Logos.Core.Syntax
open Logos.Core.ProofSystem (Axiom DerivationTree)

variable {T : Type*} [LinearOrderedAddCommGroup T] {F : TaskFrame T}

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
    {T : Type*} [LinearOrderedAddCommGroup T]
    {F : TaskFrame T} {M : TaskModel F} {τ : WorldHistory F}
    {t : T} {ht : τ.domain t} :
    ¬(truth_at M τ t ht Formula.bot) := by
  intro h
  exact h

/--
Truth of implication is material conditional.
-/
theorem imp_iff
    {T : Type*} [LinearOrderedAddCommGroup T]
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
    {T : Type*} [LinearOrderedAddCommGroup T]
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
    {T : Type*} [LinearOrderedAddCommGroup T]
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
    {T : Type*} [LinearOrderedAddCommGroup T]
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
    {T : Type*} [LinearOrderedAddCommGroup T]
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
        calc s' + (y - x) < x + (y - x) := h
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
        -- h : x + (y - x) < s' + (y - x)
        -- Need: y < s' + (y - x)
        -- Since x + (y - x) = y
        have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
        calc y = x + (y - x) := h_eq.symm
          _ < s' + (y - x) := h
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

/-! ## Temporal Duality

This section proves that swap validity is preserved for derivable formulas using
only derivation induction and local transport lemmas (no global time-reversal axioms).
-/

namespace TemporalDuality

/--
Local definition of validity to avoid circular dependency with Validity.lean.
A formula is valid if it's true at all model-history-time triples.

This is a monomorphic definition (fixed to explicit type parameter T) to avoid
universe level mismatch errors.
Per research report Option A: Make T explicit to allow type inference at call sites.
-/
private def is_valid (T : Type*) [LinearOrderedAddCommGroup T] (φ : Formula) : Prop :=
  ∀ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    truth_at M τ t ht φ

-- Section variable for theorem signatures
variable {T : Type*} [LinearOrderedAddCommGroup T]

/--
Auxiliary lemma: If φ is valid, then for any specific triple (M, τ, t),
φ is true at that triple.

This is just the definition of validity, but stated as a lemma for clarity.
-/
theorem valid_at_triple {φ : Formula} (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t) (h_valid : is_valid T φ) :
    truth_at M τ t ht φ := h_valid F M τ t ht

/--
Helper lemma: truth_at is invariant under double swap.

This lemma proves that applying swap twice to a formula preserves truth evaluation.
Required because truth_at is defined by structural recursion, preventing direct use
of the involution property φ.swap.swap = φ via substitution.
-/
theorem truth_at_swap_swap {F : TaskFrame T} (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t) (φ : Formula) :
    truth_at M τ t ht φ.swap_past_future.swap_past_future ↔ truth_at M τ t ht φ := by
  induction φ generalizing τ t ht with
  | atom p => 
    -- Atom case: swap doesn't change atoms
    simp only [Formula.swap_past_future, truth_at]
    
  | bot => 
    -- Bot case: swap doesn't change bot
    simp only [Formula.swap_past_future, truth_at]
    
  | imp φ ψ ih_φ ih_ψ => 
    -- Implication case: (φ.swap.swap → ψ.swap.swap) ↔ (φ → ψ)
    simp only [Formula.swap_past_future, truth_at]
    constructor <;> intro h <;> intro h_φ
    · exact (ih_ψ τ t ht).mp (h ((ih_φ τ t ht).mpr h_φ))
    · exact (ih_ψ τ t ht).mpr (h ((ih_φ τ t ht).mp h_φ))
    
  | box φ ih => 
    -- Box case: □(φ.swap.swap) ↔ □φ
    simp only [Formula.swap_past_future, truth_at]
    constructor <;> intro h σ hs
    · exact (ih σ t hs).mp (h σ hs)
    · exact (ih σ t hs).mpr (h σ hs)
    
  | all_past φ ih => 
    -- All_past case: all_past φ → all_future φ.swap → all_past φ.swap.swap
    simp only [Formula.swap_past_future, truth_at]
    constructor <;> intro h s hs h_ord
    · exact (ih τ s hs).mp (h s hs h_ord)
    · exact (ih τ s hs).mpr (h s hs h_ord)
    
  | all_future φ ih => 
    -- All_future case: all_future φ → all_past φ.swap → all_future φ.swap.swap
    simp only [Formula.swap_past_future, truth_at]
    constructor <;> intro h s hs h_ord
    · exact (ih τ s hs).mp (h s hs h_ord)
    · exact (ih τ s hs).mpr (h s hs h_ord)

/--
Validity is invariant under the temporal swap involution.
If `φ.swap` is valid, then so is `φ` (since swap is involutive).
-/
theorem is_valid_swap_involution (φ : Formula) (h : is_valid T φ.swap_past_future) :
    is_valid T φ := by
  intro F M τ t ht
  exact (truth_at_swap_swap M τ t ht φ).mp (by simpa using h F M τ t ht)

/-! ## Axiom Swap Validity (Approach D: Derivation-Indexed Proof)

This section proves validity of swapped axioms to enable temporal duality soundness
via derivation induction instead of formula induction.

The key insight: Instead of proving "valid φ → valid φ.swap" for ALL valid formulas
(which is impossible for arbitrary imp, past, future cases), we prove that EACH axiom
schema remains valid after swap. This suffices for soundness of the temporal_duality
rule because we only need swap preservation for derivable formulas.

**Self-Dual Axioms**: MT, M4, MB have the property that swap preserves their schema form.
**Transformed Axioms**: T4, TA, TL, MF, TF transform to different but still valid formulas.
-/

/--
Modal T axiom (MT) is self-dual under swap: `□φ → φ` swaps to `□(swap φ) → swap φ`.

Since `□(swap φ) → swap φ` is still an instance of MT (just with swapped subformula),
and MT is valid, this is immediate.

**Proof**: The swapped form is `(box φ.swap_past_future).imp φ.swap_past_future`.
At any triple (M, τ, t), if box φ.swap holds, then φ.swap holds at (M, τ, t) specifically.
-/
theorem swap_axiom_mt_valid (φ : Formula) :
    is_valid T ((Formula.box φ).imp φ).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at]
  intro h_box_swap_φ
  -- h_box_swap_φ : ∀ (σ : WorldHistory F) (hs : σ.domain t), truth_at M σ t hs φ.swap_past_future
  -- Goal: truth_at M τ t ht φ.swap_past_future
  -- Choose σ = τ
  exact h_box_swap_φ τ ht

/--
Modal 4 axiom (M4) is self-dual under swap: `□φ → □□φ` swaps to `□(swap φ) → □□(swap φ)`.

This is still M4, just applied to swapped formula.

**Proof**: If φ.swap holds at all histories at t, then "φ.swap holds at all histories at t"
holds at all histories at t (trivially, as this is a global property).
-/
theorem swap_axiom_m4_valid (φ : Formula) :
    is_valid T ((Formula.box φ).imp (Formula.box (Formula.box φ))).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at]
  intro h_box_swap_φ σ hs
  -- Goal: ∀ (ρ : WorldHistory F) (hρ : ρ.domain t), truth_at M ρ t hρ φ.swap_past_future
  intro ρ hρ
  -- h_box_swap_φ says φ.swap holds at ALL histories at time t
  exact h_box_swap_φ ρ hρ

/--
Modal B axiom (MB) is self-dual under swap: `φ → □◇φ` swaps to `swap φ → □◇(swap φ)`.

This is still MB, just applied to swapped formula.

**Proof**: If φ.swap holds at (M, τ, t), then for any history σ at t, ◇(φ.swap) holds at σ.
The diamond ◇ψ means "there exists some history where ψ holds". We have τ witnessing this.
-/
theorem swap_axiom_mb_valid (φ : Formula) :
    is_valid T (φ.imp (Formula.box φ.diamond)).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, Formula.diamond, truth_at]
  intro h_swap_φ σ hs
  -- Goal: ¬ ∀ (σ' : WorldHistory F) (hs' : σ'.domain t), ¬ truth_at M σ' t hs' φ.swap_past_future
  -- Equivalently: ∃ σ' hs', truth_at M σ' t hs' φ.swap_past_future
  intro h_all_not
  -- h_all_not says: φ.swap is false at ALL histories at t
  -- But h_swap_φ says: φ.swap is true at (M, τ, t)
  -- Contradiction when we instantiate h_all_not with τ
  exact h_all_not τ ht h_swap_φ

/--
Temporal 4 axiom (T4) swaps to a valid formula: `Fφ → FFφ` swaps to `P(swap φ) → PP(swap φ)`.

The swapped form states: if swap φ held at all past times, then at all past times,
swap φ held at all past times. This is valid by transitivity of the past operator.

**Proof**: Given P(swap φ) at (M, τ, t), we have swap φ at all s < t.
To show PP(swap φ), for any r < t, we need P(swap φ) at r.
For any u < r, we need swap φ at u. Since u < r < t, swap φ at u follows from P(swap φ) at t.
-/
theorem swap_axiom_t4_valid (φ : Formula) :
    is_valid T
      ((Formula.all_future φ).imp
       (Formula.all_future (Formula.all_future φ))).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at]
  intro h_past_swap r hr h_r_lt_t u hu h_u_lt_r
  -- h_past_swap : ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ.swap_past_future
  -- Need: truth_at M τ u hu φ.swap_past_future
  -- Since u < r < t, we have u < t, so apply h_past_swap
  have h_u_lt_t : u < t := lt_trans h_u_lt_r h_r_lt_t
  exact h_past_swap u hu h_u_lt_t

/--
Temporal A axiom (TA) swaps to a valid formula: `φ → F(sometime_past φ)` swaps to
`swap φ → P(sometime_future (swap φ))`.

The swapped form states: if swap φ holds now, then at all past times, there existed
a future time when swap φ held. This is valid because "now" is in the future of all past times.

**Proof**: Given swap φ at (M, τ, t), for any s < t, we need "∃ u > s : swap φ at u".
We can choose u = t, since t > s and swap φ holds at t.

Note: sometime_future φ = ¬(past (¬φ))
-/
theorem swap_axiom_ta_valid (φ : Formula) :
    is_valid T (φ.imp (Formula.all_future φ.sometime_past)).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, Formula.sometime_past, Formula.sometime_future, truth_at]
  intro h_swap_φ s hs h_s_lt_t
  -- Goal: ¬ ∀ (u : T) (hu : τ.domain u), u > s → ¬ truth_at M τ u hu φ.swap_past_future
  -- Equivalently: ∃ u > s : swap φ at u
  intro h_all_not_future
  -- We can choose u = t, since t > s (from h_s_lt_t)
  have h_t_gt_s : s < t := h_s_lt_t
  exact h_all_not_future t ht h_t_gt_s h_swap_φ

/--
Temporal L axiom (TL) swaps to a valid formula: `△φ → FPφ` swaps to `△(swap φ) → P(F(swap φ))`.

Note: always (△) is self-dual: φ.always.swap_past_future = φ.swap_past_future.always
because always = Pφ ∧ φ ∧ Fφ, and swap exchanges P and F.

The swapped form states: if swap φ holds at all times, then at all past times s < t,
for all future times u > s, swap φ holds at u.

**Proof Strategy**: The `always` encoding via derived `and` uses nested negations.
We use case analysis on the time `u` relative to `t`:
- If u < t: extract from the "past" component of always
- If u = t: extract from the "present" component of always
- If u > t: extract from the "future" component of always

Each case uses classical logic (`Classical.byContradiction`) to extract truth from the
double-negation encoding of conjunction.

**Proof Status**: COMPLETE
-/
theorem swap_axiom_tl_valid (φ : Formula) :
    is_valid T (φ.always.imp (Formula.all_future (Formula.all_past φ))).swap_past_future := by
  intro F M τ t ht
  -- Swapped form: (always φ).swap → (future (past φ)).swap
  --             = always (swap φ) → past (future (swap φ))
  -- In semantics: if swap φ holds at all times, then at all s < t,
  --               there exists u > s where swap φ holds
  -- This is trivially valid: if swap φ holds everywhere, pick any u > s
  simp only [Formula.swap_past_future, truth_at]
  intro h_always s hs h_s_lt_t u hu h_s_lt_u
  -- h_always encodes: ¬(future(swap φ) → ¬(swap φ ∧ past(swap φ)))
  -- which is classically equivalent to: future(swap φ) ∧ swap φ ∧ past(swap φ)
  -- meaning swap φ holds at all times in τ's domain
  --
  -- We need: truth_at M τ u hu φ.swap_past_future where s < u and s < t
  -- Consider cases on u relative to t:
  by_cases h_ut : u < t
  · -- Case: u < t, use the "past" component
    -- From h_always, we can extract that swap φ holds at all s' < t
    apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro h_fut_all
    intro h_conj
    apply h_conj
    intro h_now
    intro h_past
    -- h_past : ∀ s' < t, swap φ holds at s'
    -- Since u < t, swap φ holds at u
    exact h_neg (h_past u hu h_ut)
  · -- Case: u ≥ t
    by_cases h_eq : u = t
    · -- Case: u = t, use the "present" component
      subst h_eq
      apply Classical.byContradiction
      intro h_neg
      apply h_always
      intro h_fut_all
      intro h_conj
      apply h_conj
      intro h_now
      intro h_past
      -- h_now : swap φ holds at t
      -- But we need to transport from ht to hu
      have h_eq_proof : ht = hu := rfl  -- both are proofs of τ.domain t
      exact h_neg h_now
    · -- Case: u > t, use the "future" component
      have h_gt : t < u := lt_of_le_of_ne (le_of_not_lt h_ut) (Ne.symm h_eq)
      apply Classical.byContradiction
      intro h_neg
      apply h_always
      intro h_fut_all
      intro h_conj
      -- h_fut_all : ∀ r > t, swap φ holds at r
      -- Since u > t, swap φ holds at u
      exact h_neg (h_fut_all u hu h_gt)

/--
Modal-Future axiom (MF) swaps to a valid formula: `□φ → □Fφ` swaps to `□(swap φ) → □P(swap φ)`.

The swapped form states: if swap φ holds at all histories at time t, then for all histories σ
at time t, P(swap φ) holds at σ (i.e., swap φ holds at all times s < t in σ).

**Proof Strategy**: Use `time_shift_preserves_truth` to bridge from time t to time s < t.
1. For any history σ with domain at s, consider the shifted history `time_shift σ (s - t)`
2. The shifted history has domain at t (since σ has domain at s and s = t + (s - t))
3. By premise, swap φ holds at the shifted history at time t
4. By `time_shift_preserves_truth`, truth at (shifted, t) ↔ truth at (σ, s)
5. Therefore swap φ holds at (σ, s)

**Proof Status**: COMPLETE
-/
theorem swap_axiom_mf_valid (φ : Formula) :
    is_valid T ((Formula.box φ).imp (Formula.box (Formula.all_future φ))).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at]
  intro h_box_swap σ hs s hs_s h_s_lt_t
  -- h_box_swap : ∀ (ρ : WorldHistory F) (hρ : ρ.domain t), truth_at M ρ t hρ φ.swap_past_future
  -- Goal: truth_at M σ s hs_s φ.swap_past_future
  --
  -- Strategy: Use time_shift_preserves_truth to bridge from time t to time s.
  -- 1. Consider the shifted history ρ = time_shift σ (s - t)
  -- 2. ρ has domain at t (since σ has domain at s and s + (t-s) = t... wait, that's wrong)
  --
  -- Let me reconsider: time_shift σ Δ has domain s iff σ has domain (s + Δ)
  -- We want a history with domain at t, so we shift by (t - s): time_shift σ (t - s)
  -- Then time_shift σ (t - s) has domain at s iff σ has domain at s + (t-s) = t
  -- But we have σ.domain s (from hs_s), not σ.domain t.
  --
  -- Actually the approach should be:
  -- We want truth at (σ, s). Consider ρ = time_shift σ (s - t).
  -- time_shift σ (s - t) has domain at t iff σ has domain at t + (s - t) = s ✓
  -- So ρ has domain at t.
  -- By time_shift_preserves_truth with x = t, y = s:
  --   truth_at M (time_shift σ (s - t)) t _ φ ↔ truth_at M σ s _ φ
  -- Wait, that's not quite right. Let me check the lemma signature again.
  --
  -- time_shift_preserves_truth M σ x y hx hy φ:
  --   truth_at M (σ.time_shift (y - x)) x hx φ ↔ truth_at M σ y hy φ
  -- Here shifted = time_shift σ (y - x), and we relate (shifted, x) to (σ, y).
  --
  -- If we want to relate (σ, s) to something at time t, let's set:
  -- - We want the RHS to be truth at (σ, s), so y = s, σ = σ
  -- - Then x can be anything, shifted = time_shift σ (s - x)
  -- - If x = t, shifted = time_shift σ (s - t)
  --
  -- So the lemma says:
  --   truth_at M (time_shift σ (s - t)) t hx φ ↔ truth_at M σ s hs_s φ
  --
  -- We need to construct hx : (time_shift σ (s - t)).domain t
  -- time_shift σ (s - t) has domain at r iff σ has domain at r + (s - t)
  -- So domain at t iff σ has domain at t + (s - t) = s ✓ (we have hs_s : σ.domain s)
  --
  -- Now h_box_swap gives truth at ALL histories at time t, including time_shift σ (s - t).
  -- Applying the iff gives truth at (σ, s).
  have h_shifted_domain : (WorldHistory.time_shift σ (s - t)).domain t := by
    simp only [WorldHistory.time_shift]
    have h_eq : t + (s - t) = s := by rw [add_sub, add_sub_cancel_left]
    rw [h_eq]
    exact hs_s
  -- Get truth at shifted history at time t
  have h_at_shifted :=
    h_box_swap (WorldHistory.time_shift σ (s - t)) h_shifted_domain
  -- Use time_shift_preserves_truth to transport to (σ, s)
  exact (TimeShift.time_shift_preserves_truth M σ t s h_shifted_domain hs_s
    φ.swap_past_future).mp h_at_shifted

/--
Temporal-Future axiom (TF) swaps to a valid formula: `□φ → F□φ` swaps to `□(swap φ) → P□(swap φ)`.

The swapped form states: if swap φ holds at all histories at time t, then at all times s < t,
swap φ holds at all histories at time s.

**Proof Strategy**: Same as MF - use `time_shift_preserves_truth` to bridge from time t to s < t.
For any history σ at time s, the shifted history `time_shift σ (s - t)` has domain at t,
and truth preservation establishes the result.

**Proof Status**: COMPLETE
-/
theorem swap_axiom_tf_valid (φ : Formula) :
    is_valid T ((Formula.box φ).imp (Formula.all_future (Formula.box φ))).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at]
  intro h_box_swap s hs h_s_lt_t σ hs_σ
  -- h_box_swap : ∀ (ρ : WorldHistory F) (hρ : ρ.domain t), truth_at M ρ t hρ φ.swap_past_future
  -- Goal: truth_at M σ s hs_σ φ.swap_past_future
  -- The premise says swap φ holds at ALL histories at time t
  -- We need swap φ at history σ at time s < t
  -- Same strategy as MF: use time_shift_preserves_truth
  have h_shifted_domain : (WorldHistory.time_shift σ (s - t)).domain t := by
    simp only [WorldHistory.time_shift]
    have h_eq : t + (s - t) = s := by rw [add_sub, add_sub_cancel_left]
    rw [h_eq]
    exact hs_σ
  have h_at_shifted :=
    h_box_swap (WorldHistory.time_shift σ (s - t)) h_shifted_domain
  exact (TimeShift.time_shift_preserves_truth M σ t s h_shifted_domain hs_σ
    φ.swap_past_future).mp h_at_shifted

/-! ## Rule Preservation (Phase 3)

This section proves that each inference rule of the TM proof system preserves swap validity.
If the premises have valid swapped forms, then the conclusion also has a valid swapped form.

These lemmas are used in Phase 4 to prove the main theorem `derivable_implies_swap_valid`
by induction on the derivation structure.
-/

/--
Modus ponens preserves swap validity.

If `(φ → ψ).swap` and `φ.swap` are both valid, then `ψ.swap` is valid.

**Proof**: Since `(φ → ψ).swap = φ.swap → ψ.swap`, this is just standard modus ponens
applied to the swapped formulas.
-/
theorem mp_preserves_swap_valid (φ ψ : Formula)
    (h_imp : is_valid T (φ.imp ψ).swap_past_future)
    (h_phi : is_valid T φ.swap_past_future) :
    is_valid T ψ.swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at] at h_imp h_phi ⊢
  exact h_imp F M τ t ht (h_phi F M τ t ht)

/--
Modal K rule preserves swap validity.

If `φ.swap` is valid, then `(□φ).swap = □(φ.swap)` is valid.

**Proof**: If `φ.swap` is true at all triples, then for any (F, M, τ, t),
at all histories σ at time t, `φ.swap` is true at (M, σ, t). This is exactly `□(φ.swap)`.
-/
theorem modal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid T φ.swap_past_future) :
    is_valid T (Formula.box φ).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at]
  intro σ hs
  exact h F M σ t hs

/--
Temporal K rule preserves swap validity.

If `φ.swap` is valid, then `(Fφ).swap = P(φ.swap)` is valid.

**Proof**: If `φ.swap` is true at all triples, then for any (F, M, τ, t),
at all times s < t in τ's domain, `φ.swap` is true at (M, τ, s). This is exactly `P(φ.swap)`.
-/
theorem temporal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid T φ.swap_past_future) :
    is_valid T (Formula.all_future φ).swap_past_future := by
  intro F M τ t ht
  simp only [Formula.swap_past_future, truth_at]
  intro s hs h_s_lt_t
  exact h F M τ s hs

/--
Weakening preserves swap validity (trivial for empty context).

For the temporal duality rule, we only consider derivations from empty context.
Weakening from [] to [] is trivial.

**Note**: A general version would need to handle non-empty contexts, but temporal duality
only applies to theorems (empty context derivations).
-/
theorem weakening_preserves_swap_valid (φ : Formula)
    (h : is_valid T φ.swap_past_future) :
    is_valid T φ.swap_past_future := h

/-! ## Axiom Swap Validity Master Theorem (Phase 4 - Partial)

This section adds the master theorem that combines all individual axiom swap validity lemmas.

**Status**: COMPLETE - all 10 axioms proven.

The proof handles each axiom case:
- **prop_k, prop_s**: Propositional tautologies, swap distributes over implication
- **modal_t, modal_4, modal_b**: Self-dual modal axioms (swap preserves schema form)
- **temp_4, temp_a**: Temporal axioms with straightforward swap semantics
- **temp_l (TL)**: Uses case analysis and classical logic for `always` encoding
- **modal_future (MF), temp_future (TF)**: Use `time_shift_preserves_truth` to bridge times
-/

theorem axiom_swap_valid (φ : Formula) (h : Axiom φ) : is_valid T φ.swap_past_future := by
  cases h with
  | prop_k ψ χ ρ =>
    -- prop_k is (ψ → (χ → ρ)) → ((ψ → χ) → (ψ → ρ))
    -- After swap: (ψ.swap → (χ.swap → ρ.swap)) → ((ψ.swap → χ.swap) → (ψ.swap → ρ.swap))
    -- This is still prop_k applied to swapped subformulas
    intro F M τ t ht
    simp only [Formula.swap_past_future, truth_at]
    -- Goal is a propositional tautology: ((A → (B → C)) → ((A → B) → (A → C)))
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    -- prop_s is ψ → (χ → ψ)
    -- After swap: ψ.swap → (χ.swap → ψ.swap)
    -- This is still prop_s applied to swapped subformulas
    intro F M τ t ht
    simp only [Formula.swap_past_future, truth_at]
    -- Goal is a propositional tautology: A → (B → A)
    intro h_a _
    exact h_a
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ =>
    -- modal_5_collapse is ◇□ψ → □ψ
    -- After swap: ◇□ψ.swap → □ψ.swap
    -- This is still modal_5_collapse applied to swapped subformula (modal operators unchanged)
    intro F M τ t ht
    simp only [Formula.swap_past_future, Formula.diamond, Formula.neg, truth_at]
    -- Goal: ((∀ σ hs, (∀ ρ hr, truth_at ... ψ.swap) → False) → False)
    --       → (∀ σ hs, truth_at ... ψ.swap)
    intro h_diamond_box σ hs
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ hr
    intro h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ hs
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    -- ex_falso is ⊥ → ψ
    -- After swap: ⊥ → ψ.swap
    -- This is still ex_falso applied to swapped subformula (bot unchanged)
    intro F M τ t ht
    simp only [Formula.swap_past_future, truth_at]
    -- Goal: False → truth_at ... ψ.swap
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    -- peirce is ((ψ → χ) → ψ) → ψ
    -- After swap: ((ψ.swap → χ.swap) → ψ.swap) → ψ.swap
    -- This is still peirce applied to swapped subformulas
    intro F M τ t ht
    simp only [Formula.swap_past_future, truth_at]
    -- Goal: ((truth_at ... ψ.swap → truth_at ... χ.swap)
    --        → truth_at ... ψ.swap) → truth_at ... ψ.swap
    intro h_peirce
    by_cases h : truth_at M τ t ht ψ.swap_past_future
    · exact h
    · have h_imp : truth_at M τ t ht (ψ.swap_past_future.imp χ.swap_past_future) := by
        unfold truth_at
        intro h_psi
        exfalso
        exact h h_psi
      exact h_peirce h_imp
  | modal_k_dist ψ χ =>
    -- modal_k_dist is □(ψ → χ) → (□ψ → □χ)
    -- After swap: □(ψ.swap → χ.swap) → (□ψ.swap → □χ.swap)
    -- This is still modal_k_dist applied to swapped subformulas (modal operators unchanged)
    intro F M τ t ht
    simp only [Formula.swap_past_future, truth_at]
    -- Goal: (∀ σ hs, truth_at ... ψ.swap → truth_at ... χ.swap) →
    --       (∀ σ hs, truth_at ... ψ.swap) → (∀ σ hs, truth_at ... χ.swap)
    intro h_box_imp h_box_psi σ hs
    exact h_box_imp σ hs (h_box_psi σ hs)
  | temp_k_dist ψ χ =>
    -- temp_k_dist is F(ψ → χ) → (Fψ → Fχ)
    -- After swap: P(ψ.swap → χ.swap) → (Pψ.swap → Pχ.swap)
    -- This is the past version of temp_k_dist (swap exchanges F and P)
    intro F M τ t ht
    simp only [Formula.swap_past_future, truth_at]
    -- Goal: (∀ s hs, s < t → truth_at ... ψ.swap → truth_at ... χ.swap) →
    --       (∀ s hs, s < t → truth_at ... ψ.swap) → (∀ s hs, s < t → truth_at ... χ.swap)
    intro h_past_imp h_past_psi s hs hst
    exact h_past_imp s hs hst (h_past_psi s hs hst)
  | temp_4 ψ => exact swap_axiom_t4_valid ψ
  | temp_a ψ => exact swap_axiom_ta_valid ψ
  | temp_l ψ => exact swap_axiom_tl_valid ψ
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | temp_future ψ => exact swap_axiom_tf_valid ψ

/-! ## Main Theorem: Derivable Implies Swap Valid

This is the culminating theorem of the derivation-indexed approach to temporal duality soundness.
It proves that if a formula is derivable from the empty context, then its swapped version is valid.

This theorem is used in `Soundness.lean` to complete the temporal_duality case of the
soundness proof.
-/

/--
Main theorem: If a formula is derivable from empty context, then its swap is valid.

This theorem proves temporal duality soundness via derivation induction rather than
formula induction.
The key insight is that we only need swap validity for derivable formulas, not all valid formulas.
-/
theorem derivable_implies_swap_valid :
    ∀ {φ : Formula}, DerivationTree [] φ → is_valid T φ.swap_past_future := by
  intro φ h_deriv
  -- Proof by induction on the derivation structure
  -- Note: We generalize to arbitrary contexts but only use the [] case
  have h_general : ∀ (Γ : List Formula) (ψ : Formula),
      DerivationTree Γ ψ → Γ = [] → is_valid T ψ.swap_past_future := by
    intro Γ ψ h
    induction h with
    | «axiom» Γ' ψ' h_axiom =>
      intro h_eq
      -- Γ' = [], axiom case doesn't depend on context
      exact axiom_swap_valid ψ' h_axiom

    | «assumption» Γ' ψ' h_mem =>
      intro h_eq
      -- Γ' = [], so h_mem : ψ' ∈ [] is impossible
      rw [h_eq] at h_mem
      exact False.elim (List.not_mem_nil ψ' h_mem)

    | modus_ponens Γ' ψ' χ' h_imp h_ψ' ih_imp ih_ψ' =>
      intro h_eq
      -- Γ' = [], both premises are from []
      exact mp_preserves_swap_valid ψ' χ' (ih_imp h_eq) (ih_ψ' h_eq)

    | necessitation ψ' h_ψ' ih =>
      intro h_eq
      -- Necessitation: [] ⊢ ψ' implies [] ⊢ □ψ'
      -- Need to show: is_valid (□ψ').swap = is_valid □(ψ'.swap)
      -- By IH: is_valid ψ'.swap
      -- Need: is_valid □(ψ'.swap)
      exact modal_k_preserves_swap_valid ψ' (ih rfl)

    | temporal_necessitation ψ' h_ψ' ih =>
      intro h_eq
      -- Temporal necessitation: [] ⊢ ψ' implies [] ⊢ Fψ'
      -- Need to show: is_valid (Fψ').swap = is_valid P(ψ'.swap)
      -- By IH: is_valid ψ'.swap
      -- Need: is_valid P(ψ'.swap)
      exact temporal_k_preserves_swap_valid ψ' (ih rfl)

    | temporal_duality ψ' h_ψ' ih =>
      intro h_eq
      -- Temporal duality: from Derivable [] ψ', conclude Derivable [] ψ'.swap
      -- Goal: is_valid (ψ'.swap).swap
      -- By involution: (ψ'.swap).swap = ψ', so goal is: is_valid ψ'
      -- IH gives: is_valid ψ'.swap
      have h_swap_valid := ih h_eq
      have h_original : is_valid T ψ' := is_valid_swap_involution ψ' h_swap_valid
      -- Rewrite using involution to close the goal
      simpa [Formula.swap_past_future_involution ψ'] using h_original

    | weakening Γ' Δ' ψ' h_ψ' h_subset ih =>
      intro h_eq
      -- h_eq says Δ' = [] (the conclusion context)
      -- From weakening rule: Derivable Γ' ψ' with Γ' ⊆ Δ'
      -- Since Δ' = [] and Γ' ⊆ Δ', we have Γ' = []
      have h_gamma_empty : Γ' = [] := by
        cases Γ' with
        | nil => rfl
        | cons head tail =>
          -- Γ' = head :: tail, so Γ' ⊆ [] means head ∈ []
          have : head ∈ Δ' := h_subset (List.mem_cons_self head tail)
          rw [h_eq] at this
          exact False.elim (List.not_mem_nil head this)
      exact ih h_gamma_empty

  exact h_general [] φ h_deriv rfl

end TemporalDuality

end Logos.Core.Semantics
