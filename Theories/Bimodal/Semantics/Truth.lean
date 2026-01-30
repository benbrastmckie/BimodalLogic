import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.WorldHistory
import Bimodal.Syntax.Formula

/-!
# Truth - Truth Evaluation in Task Semantics

This module defines truth evaluation for TM formulas in task models.

**Reflexive Temporal Semantics**: As of Task #658, temporal operators G (all_future)
and H (all_past) use REFLEXIVE semantics (≤ instead of <), meaning "now and future/past"
rather than "strictly future/past". This change enables coherence proofs via T-axioms.

## Paper Specification Reference

**Bimodal Logic Semantics (app:TaskSemantics, def:BL-semantics, lines 1857-1872)**:
The JPL paper defines truth evaluation for TM formulas as follows:
- `M,τ,x ⊨ p` iff `x ∈ dom(τ)` AND `τ(x) ∈ V(p)` (atom satisfaction, line 892)
- `M,τ,x ⊨ ⊥` is false (bottom)
- `M,τ,x ⊨ φ → ψ` iff `M,τ,x ⊨ φ` implies `M,τ,x ⊨ ψ` (implication)
- `M,τ,x ⊨ □φ` iff `M,σ,x ⊨ φ` for all σ ∈ Ω (box: necessity)
- `M,τ,x ⊨ Past φ` iff `M,τ,y ⊨ φ` for all y ∈ D where y ≤ x (past, reflexive)
- `M,τ,x ⊨ Future φ` iff `M,τ,y ⊨ φ` for all y ∈ D where x ≤ y (future, reflexive)

**Critical Semantic Design (lines 899-919)**:
The paper explicitly quantifies temporal operators over ALL times `y ∈ D` (the entire
temporal order), NOT just times in `dom(τ)`. This is a deliberate design choice:
- Atoms at times outside domain are FALSE (not undefined)
- Temporal operators see "beyond" the history's domain
- This matters for finite histories (e.g., chess game ending at move 31)

**ProofChecker Implementation Alignment**:
✓ Atom: `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`
  matches paper's domain check at line 892 (atoms false outside domain)
✓ Bot: `False` matches paper's definition
✓ Imp: Standard material conditional matches paper
✓ Box: `∀ (σ : WorldHistory F), truth_at M σ t φ`
  matches paper's quantification over all histories
✓ Past: `∀ (s : D), s ≤ t → truth_at M τ s φ`
  uses reflexive ordering (includes present) for coherence
✓ Future: `∀ (s : D), t ≤ s → truth_at M τ s φ`
  uses reflexive ordering (includes present) for coherence

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
- Temporal past/future quantify over ALL times in D (not just domain)
- Atoms are false at times outside the history's domain

## References

* [ARCHITECTURE.md](../../../docs/UserGuide/ARCHITECTURE.md) - Truth evaluation
  specification
* [Formula.lean](../Syntax/Formula.lean) - Formula syntax
* [TaskModel.lean](TaskModel.lean) - Task model structure
* JPL Paper app:TaskSemantics (def:BL-semantics, lines 1857-1872) - Formal truth definition
* JPL Paper lines 892-919 - Semantic design rationale
-/

namespace Bimodal.Semantics

open Bimodal.Syntax

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}

/--
Truth of a formula at a model-history-time triple.

Given:
- `M`: A task model (frame + valuation)
- `τ`: A world history (function from times to states)
- `t`: A time point
- `φ`: A formula

Returns whether `φ` is true at this semantic configuration.

The evaluation is defined recursively on formula structure:
- Atoms: true iff there exists a proof that t is in the history's domain
  AND valuation says so at current state (atoms are false at times outside domain)
- Bot (⊥): always false
- Implication: standard material conditional
- Box (□): true iff φ true at all world histories at time t
- Past (P): true iff φ true at all past times in D (not just domain)
- Future (F): true iff φ true at all future times in D (not just domain)

**Paper Reference**: def:BL-semantics (lines 1857-1872) specifies:
- Atoms check domain membership: M,τ,x ⊨ p iff x ∈ dom(τ) and τ(x) ∈ V(p)
- Temporal operators quantify over ALL times in D, not just dom(τ)
-/
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t φ → truth_at M τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), truth_at M σ t φ
  | Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M τ s φ
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M τ s φ

-- Note: We avoid defining a notation for truth_at as it causes parsing conflicts
-- with the validity notation in Validity.lean. Use truth_at directly.

namespace Truth

/--
Bot (⊥) is false everywhere.
-/
theorem bot_false
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D} :
    ¬(truth_at M τ t Formula.bot) := by
  intro h
  exact h

/--
Truth of implication is material conditional.
-/
theorem imp_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ ψ : Formula) :
    (truth_at M τ t (φ.imp ψ)) ↔
      ((truth_at M τ t φ) → (truth_at M τ t ψ)) := by
  rfl

/--
Truth of atom at a time in the domain: true iff valuation says so at current state.
For times outside domain, atoms are always false.
-/
theorem atom_iff_of_domain
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D} (ht : τ.domain t)
    (p : String) :
    (truth_at M τ t (Formula.atom p)) ↔
      M.valuation (τ.states t ht) p := by
  simp only [truth_at]
  constructor
  · intro ⟨ht', h⟩
    -- By proof irrelevance, τ.states t ht' = τ.states t ht
    exact h
  · intro h
    exact ⟨ht, h⟩

/--
Truth of atom at a time outside the domain is false.
-/
theorem atom_false_of_not_domain
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D} (ht : ¬τ.domain t)
    (p : String) :
    ¬(truth_at M τ t (Formula.atom p)) := by
  simp only [truth_at]
  intro ⟨ht', _⟩
  exact ht ht'

/--
Truth of box: formula true at all histories at current time.
-/
theorem box_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    (truth_at M τ t φ.box) ↔
      ∀ (σ : WorldHistory F), (truth_at M σ t φ) := by
  rfl

/--
Truth of past: formula true at all times up to and including now (reflexive).
-/
theorem past_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    (truth_at M τ t φ.all_past) ↔
      ∀ (s : D), s ≤ t → (truth_at M τ s φ) := by
  rfl

/--
Truth of future: formula true at all times from now onward (reflexive).
-/
theorem future_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    (truth_at M τ t φ.all_future) ↔
      ∀ (s : D), t ≤ s → (truth_at M τ s φ) := by
  rfl

end Truth

/-! ## Time-Shift Preservation

These lemmas establish that truth is preserved under time-shift transformations.
This is fundamental to proving the MF and TF axioms valid.

The key insight is that for a formula φ:
  `truth_at M σ y φ ↔ truth_at M (time_shift σ (y - x)) x φ`

This relates truth at (σ, y) to truth at (shifted_σ, x).

Note: With the new semantics where temporal operators quantify over ALL times (not just
domain times), these proofs become simpler since we don't need to thread domain proofs.
-/

namespace TimeShift

/--
Truth transport across equal histories.

When two histories are equal, truth is preserved.
-/
theorem truth_history_eq (M : TaskModel F) (τ₁ τ₂ : WorldHistory F) (t : D)
    (h_eq : τ₁ = τ₂) (φ : Formula) :
    truth_at M τ₁ t φ ↔ truth_at M τ₂ t φ := by
  cases h_eq
  rfl

/--
Truth at double time-shift with opposite amounts equals truth at original history.

This is the key transport lemma for the box case of time_shift_preserves_truth.
It allows us to transfer truth from (time_shift (time_shift σ Δ) (-Δ)) back to σ.
-/
theorem truth_double_shift_cancel (M : TaskModel F) (σ : WorldHistory F) (Δ : D) (t : D)
    (φ : Formula) :
    truth_at M (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)) t φ ↔
    truth_at M σ t φ := by
  induction φ generalizing t with
  | atom p =>
    simp only [truth_at]
    -- Both sides check domain membership and get the same state
    -- Domain equivalence: double-shift domain at t iff σ.domain t
    constructor
    · intro ⟨ht', h⟩
      have ht : σ.domain t := (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ t).mp ht'
      have h_eq := WorldHistory.time_shift_time_shift_neg_states σ Δ t ht ht'
      exact ⟨ht, by rw [← h_eq]; exact h⟩
    · intro ⟨ht, h⟩
      have ht' : (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)).domain t :=
        (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ t).mpr ht
      have h_eq := WorldHistory.time_shift_time_shift_neg_states σ Δ t ht ht'
      exact ⟨ht', by rw [h_eq]; exact h⟩
  | bot =>
    simp only [truth_at]
  | imp ψ χ ih_ψ ih_χ =>
    simp only [truth_at]
    constructor
    · intro h h_ψ
      have h_ψ' := (ih_ψ t).mpr h_ψ
      exact (ih_χ t).mp (h h_ψ')
    · intro h h_ψ'
      have h_ψ := (ih_ψ t).mp h_ψ'
      exact (ih_χ t).mpr (h h_ψ)
  | box ψ ih =>
    simp only [truth_at]
    -- Box quantifies over ALL histories at time t, independent of current history
    -- Both sides quantify over the same set of histories
  | all_past ψ ih =>
    simp only [truth_at]
    constructor
    · intro h s h_lt
      exact (ih s).mp (h s h_lt)
    · intro h s h_lt
      exact (ih s).mpr (h s h_lt)
  | all_future ψ ih =>
    simp only [truth_at]
    constructor
    · intro h s h_lt
      exact (ih s).mp (h s h_lt)
    · intro h s h_lt
      exact (ih s).mpr (h s h_lt)

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
theorem time_shift_preserves_truth (M : TaskModel F) (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    truth_at M (WorldHistory.time_shift σ (y - x)) x φ ↔ truth_at M σ y φ := by
  -- Proof by structural induction on φ
  induction φ generalizing x y σ with
  | atom p =>
    -- For atoms, we need to check domain membership in both cases
    -- (time_shift σ Δ).domain x iff σ.domain (x + Δ) = σ.domain y
    simp only [truth_at, WorldHistory.time_shift]
    have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
    -- Domain at x in shifted history iff domain at y in original
    constructor
    · intro ⟨hx, h⟩
      have hy : σ.domain y := by rw [← h_eq]; exact hx
      -- States match: use states_eq_of_time_eq
      have h_states := WorldHistory.states_eq_of_time_eq σ (x + (y - x)) y h_eq hx hy
      exact ⟨hy, by rw [← h_states]; exact h⟩
    · intro ⟨hy, h⟩
      have hx : σ.domain (x + (y - x)) := by rw [h_eq]; exact hy
      have h_states := WorldHistory.states_eq_of_time_eq σ (x + (y - x)) y h_eq hx hy
      exact ⟨hx, by rw [h_states]; exact h⟩

  | bot =>
    -- Both sides are False
    simp only [truth_at]

  | imp ψ χ ih_ψ ih_χ =>
    -- By IH on both subformulas
    simp only [truth_at]
    constructor
    · intro h h_psi
      have h_psi' := (ih_ψ σ x y).mpr h_psi
      exact (ih_χ σ x y).mp (h h_psi')
    · intro h h_psi'
      have h_psi := (ih_ψ σ x y).mp h_psi'
      exact (ih_χ σ x y).mpr (h h_psi)

  | box ψ ih =>
    -- For box, both quantify over ALL histories at their times
    -- We use the fact that time-shift gives a bijection between histories
    simp only [truth_at]
    constructor
    · intro h_box_x ρ
      -- ρ is any history, need to show truth at (ρ, y)
      -- Consider time_shift ρ (y - x) which relates (ρ, y) to (shifted_ρ, x)
      have h1 := h_box_x (WorldHistory.time_shift ρ (y - x))
      -- Apply IH with ρ instead of σ
      exact (ih ρ x y).mp h1
    · intro h_box_y ρ
      -- ρ is any history, need to show truth at (ρ, x)
      -- Consider time_shift ρ (x - y) which relates (ρ, x) to (shifted_ρ, y)
      have h1 := h_box_y (WorldHistory.time_shift ρ (x - y))
      -- We need to relate back: time_shift (time_shift ρ (x-y)) (y-x) to ρ
      -- Key insight: (y-x) = -(x-y), so double shift cancels

      -- Apply IH with time_shift ρ (x - y) instead of σ
      have h2 := (ih (WorldHistory.time_shift ρ (x - y)) x y).mpr h1
      -- h2 : truth_at M (time_shift (time_shift ρ (x-y)) (y-x)) x ψ
      -- Need: truth_at M ρ x ψ

      have h_cancel : y - x = -(x - y) := (neg_sub x y).symm
      have h_hist_eq :
        WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (y - x) =
        WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (-(x - y)) := by
        exact WorldHistory.time_shift_congr
          (WorldHistory.time_shift ρ (x - y)) (y - x) (-(x - y)) h_cancel
      have h2' := (truth_history_eq M _ _ x h_hist_eq ψ).mp h2
      exact (truth_double_shift_cancel M ρ (x - y) x ψ).mp h2'

  | all_past ψ ih =>
    -- Past quantifies over times up to and including now (reflexive)
    -- Times shift together: s ≤ y in σ corresponds to s-(y-x) ≤ x in shifted history
    simp only [truth_at]
    constructor
    · intro h_past s h_s_le_y
      -- s ≤ y in σ, need to show truth at s in σ
      -- Use shifted time: s' = s - (y - x) ≤ x
      have h_s_shifted_le_x : s - (y - x) ≤ x := by
        have h := sub_le_sub_right h_s_le_y (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      have h_truth_shifted := h_past (s - (y - x)) h_s_shifted_le_x
      -- Apply IH: need to show (time_shift σ (y - x), s - (y - x)) ↔ (σ, s)
      -- The shift amount should be: s - (s - (y - x)) = y - x
      have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
      have h_hist_eq :
        WorldHistory.time_shift σ (s - (s - (y - x))) =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
      have h_truth_ih := (truth_history_eq M _ _ (s - (y - x)) h_hist_eq.symm ψ).mp h_truth_shifted
      exact (ih σ (s - (y - x)) s).mp h_truth_ih
    · intro h_past s' h_s'_le_x
      -- s' ≤ x in shifted σ, need to show truth at s' in shifted σ
      -- s' corresponds to time s = s' + (y - x) in σ
      have h_s_le_y : s' + (y - x) ≤ y := by
        have h := add_le_add_right h_s'_le_x (y - x)
        calc s' + (y - x) = (y - x) + s' := add_comm s' (y - x)
          _ ≤ (y - x) + x := h
          _ = x + (y - x) := add_comm (y - x) x
          _ = y := by rw [add_sub, add_sub_cancel_left]
      have h_truth_orig := h_past (s' + (y - x)) h_s_le_y
      -- Apply IH: need shift amount = (s' + (y - x)) - s' = y - x
      have h_shift_eq : (s' + (y - x)) - s' = y - x :=
        add_sub_cancel_left s' (y - x)
      have h_hist_eq :
        WorldHistory.time_shift σ ((s' + (y - x)) - s') =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ ((s' + (y - x)) - s')
          (y - x) h_shift_eq
      have h_ih := (ih σ s' (s' + (y - x))).mpr h_truth_orig
      exact (truth_history_eq M _ _ s' h_hist_eq ψ).mp h_ih

  | all_future ψ ih =>
    -- Similar to past case: s ≥ y (i.e., y ≤ s) in σ corresponds to s-(y-x) ≥ x in shifted history
    simp only [truth_at]
    constructor
    · intro h_future s h_y_le_s
      -- y ≤ s in σ, need to show truth at s in σ
      -- Use shifted time: s' = s - (y - x) and x ≤ s'
      have h_x_le_s_shifted : x ≤ s - (y - x) := by
        have h := sub_le_sub_right h_y_le_s (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      have h_truth_shifted := h_future (s - (y - x)) h_x_le_s_shifted
      -- Apply IH with shift amount s - (s - (y - x)) = y - x
      have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
      have h_hist_eq :
        WorldHistory.time_shift σ (s - (s - (y - x))) =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
      have h_truth_ih := (truth_history_eq M _ _ (s - (y - x)) h_hist_eq.symm ψ).mp h_truth_shifted
      exact (ih σ (s - (y - x)) s).mp h_truth_ih
    · intro h_future s' h_x_le_s'
      -- x ≤ s' in shifted σ, need to show truth at s' in shifted σ
      -- s' corresponds to time s = s' + (y - x) in σ
      have h_y_le_s : y ≤ s' + (y - x) := by
        have h := add_le_add_right h_x_le_s' (y - x)
        have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
        calc y = x + (y - x) := h_eq.symm
          _ = (y - x) + x := add_comm x (y - x)
          _ ≤ (y - x) + s' := h
          _ = s' + (y - x) := add_comm (y - x) s'
      have h_truth_orig := h_future (s' + (y - x)) h_y_le_s
      -- Apply IH with shift amount (s' + (y - x)) - s' = y - x
      have h_shift_eq : (s' + (y - x)) - s' = y - x :=
        add_sub_cancel_left s' (y - x)
      have h_hist_eq :
        WorldHistory.time_shift σ ((s' + (y - x)) - s') =
        WorldHistory.time_shift σ (y - x) := by
        exact WorldHistory.time_shift_congr σ ((s' + (y - x)) - s')
          (y - x) h_shift_eq
      have h_ih := (ih σ s' (s' + (y - x))).mpr h_truth_orig
      exact (truth_history_eq M _ _ s' h_hist_eq ψ).mp h_ih

/--
Corollary: For any history σ at time y, there exists a history at time x
(namely, time_shift σ (y - x)) where the same formulas are true.

This is the key lemma for proving MF and TF axioms.
-/
theorem exists_shifted_history (M : TaskModel F) (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    truth_at M σ y φ ↔
    truth_at M (WorldHistory.time_shift σ (y - x)) x φ := by
  exact (time_shift_preserves_truth M σ x y φ).symm

end TimeShift


end Bimodal.Semantics
