import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.WorldHistory
import Bimodal.Syntax.Formula

/-!
# Truth - Truth Evaluation in Task Semantics

This module defines truth evaluation for TM formulas in task models.

**Irreflexive Temporal Semantics (A2 Guard Convention)**: Temporal operators G (all_future)
and H (all_past) use STRICT semantics (< instead of ≤), meaning "all strictly
future/past times" (excluding the present). Under irreflexive semantics, the
T-axioms (Gφ → φ, Hφ → φ) are NOT valid. Until uses strict witness (s > t) with
open guard (t, s). Since uses strict witness (s < t) with open guard (s, t).

This is the open guard convention: strict witness, open guard. The seriality
axioms (⊤ → F(⊤), ⊤ → P(⊤)) replace the T-axioms (BX1/BX1').

## Paper Specification Reference

**Bimodal Logic Semantics (app:TaskSemantics, def:BL-semantics, lines 1857-1872)**:
The JPL paper defines truth evaluation for TM formulas. Our implementation uses
strict temporal quantification (a refinement of the paper's reflexive convention):
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
✓ Box: `∀ (σ : WorldHistory F), σ ∈ Ω → truth_at M Ω σ t φ`
  matches paper's quantification over σ ∈ Ω (admissible histories)
✓ Past: `∀ (s : D), s ≤ t → truth_at M τ s φ`
  uses reflexive ordering (all past times, including now)
✓ Future: `∀ (s : D), t ≤ s → truth_at M τ s φ`
  uses reflexive ordering (all future times, including now)

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
See SoundnessLemmas.lean for details on the module hierarchy restructuring.

## Implementation Notes

- Truth is defined recursively on formula structure
- Modal box quantifies over all world histories at current time
- Temporal past/future quantify over ALL strictly past/future times in D excluding now (irreflexive)
- Until/Since use strict witness (s > t / s < t) with open guards (t,s) / (s,t)
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
- Box (□): true iff φ true at all world histories in Ω at time t
- Past (H): true iff φ true at all strictly past times in D (irreflexive, excludes now)
- Future (G): true iff φ true at all strictly future times in D (irreflexive, excludes now)

The `Omega` parameter restricts which histories the box modality quantifies over.
When `Omega = Set.univ`, this recovers the original universal quantification.

**Paper Reference**: def:BL-semantics (lines 1857-1872) specifies:
- Atoms check domain membership: M,τ,x ⊨ p iff x ∈ dom(τ) and τ(x) ∈ V(p)
- Box quantifies over σ ∈ Ω (admissible histories)
- Temporal operators quantify over ALL times in D, not just dom(τ)
-/
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s φ ∧
      ∀ r : D, t < r → r < s → truth_at M Omega τ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s φ ∧
      ∀ r : D, s < r → r < t → truth_at M Omega τ r ψ

-- Note: We avoid defining a notation for truth_at as it causes parsing conflicts
-- with the validity notation in Validity.lean. Use truth_at directly.

namespace Truth

/--
Bot (⊥) is false everywhere.
-/
theorem bot_false
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F)) :
    ¬(truth_at M Omega τ t Formula.bot) := by
  intro h
  exact h

/--
Truth of implication is material conditional.
-/
theorem imp_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (φ ψ : Formula) :
    (truth_at M Omega τ t (φ.imp ψ)) ↔
      ((truth_at M Omega τ t φ) → (truth_at M Omega τ t ψ)) := by
  rfl

/--
Truth of atom at a time in the domain: true iff valuation says so at current state.
For times outside domain, atoms are always false.
-/
theorem atom_iff_of_domain
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D} (ht : τ.domain t)
    (Omega : Set (WorldHistory F))
    (p : Atom) :
    (truth_at M Omega τ t (Formula.atom p)) ↔
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
    (Omega : Set (WorldHistory F))
    (p : Atom) :
    ¬(truth_at M Omega τ t (Formula.atom p)) := by
  simp only [truth_at]
  intro ⟨ht', _⟩
  exact ht ht'

/--
Truth of box: formula true at all histories in Omega at current time.
-/
theorem box_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (φ : Formula) :
    (truth_at M Omega τ t φ.box) ↔
      ∀ (σ : WorldHistory F), σ ∈ Omega → (truth_at M Omega σ t φ) := by
  rfl

/--
Truth of some_future: existential future operator.
F(φ) = U(φ, ⊤) is true iff there exists a strictly future time where φ holds.
-/
@[simp] theorem some_future_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (φ : Formula) :
    truth_at M Omega τ t (Formula.some_future φ) ↔
      ∃ s, t < s ∧ truth_at M Omega τ s φ := by
  simp only [Formula.some_future, Formula.top, truth_at]
  constructor
  · rintro ⟨s, hlt, hevent, _⟩
    exact ⟨s, hlt, hevent⟩
  · rintro ⟨s, hlt, hs⟩
    exact ⟨s, hlt, hs, fun _ _ _ => id⟩

/--
Truth of some_past: existential past operator.
P(φ) = S(φ, ⊤) is true iff there exists a strictly past time where φ held.
-/
@[simp] theorem some_past_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (φ : Formula) :
    truth_at M Omega τ t (Formula.some_past φ) ↔
      ∃ s, s < t ∧ truth_at M Omega τ s φ := by
  simp only [Formula.some_past, Formula.top, truth_at]
  constructor
  · rintro ⟨s, hlt, hevent, _⟩
    exact ⟨s, hlt, hevent⟩
  · rintro ⟨s, hlt, hs⟩
    exact ⟨s, hlt, hs, fun _ _ _ => id⟩

/--
Truth of all_future: universal future operator.
G(φ) = ¬F(¬φ) is true iff φ holds at all strictly future times.
-/
@[simp] theorem future_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (φ : Formula) :
    truth_at M Omega τ t φ.all_future ↔
      ∀ (s : D), t < s → truth_at M Omega τ s φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top, truth_at]
  constructor
  · intro h s hlt
    by_contra hns
    exact h ⟨s, hlt, fun hs => hns hs, fun _ _ _ => id⟩
  · intro h ⟨s, hlt, hevent, _⟩
    exact hevent (h s hlt)

/--
Truth of all_past: universal past operator.
H(φ) = ¬P(¬φ) is true iff φ holds at all strictly past times.
-/
@[simp] theorem past_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (φ : Formula) :
    truth_at M Omega τ t φ.all_past ↔
      ∀ (s : D), s < t → truth_at M Omega τ s φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, truth_at]
  constructor
  · intro h s hlt
    by_contra hns
    exact h ⟨s, hlt, fun hs => hns hs, fun _ _ _ => id⟩
  · intro h ⟨s, hlt, hevent, _⟩
    exact hevent (h s hlt)

end Truth

/--
A set of world histories is shift-closed if shifting any history by any amount
keeps it in the set. This is required for time_shift_preserves_truth to work
with the box modality, since we need shifted histories to remain in Omega.
-/
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  ∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.time_shift σ Δ ∈ Omega

/--
The universal set of world histories is trivially shift-closed.
-/
theorem Set.univ_shift_closed : ShiftClosed (Set.univ : Set (WorldHistory F)) := by
  intro σ _ Δ
  exact Set.mem_univ _

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
theorem truth_history_eq (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ₁ τ₂ : WorldHistory F) (t : D)
    (h_eq : τ₁ = τ₂) (φ : Formula) :
    truth_at M Omega τ₁ t φ ↔ truth_at M Omega τ₂ t φ := by
  cases h_eq
  rfl

/--
Truth at double time-shift with opposite amounts equals truth at original history.

This is the key transport lemma for the box case of time_shift_preserves_truth.
It allows us to transfer truth from (time_shift (time_shift σ Δ) (-Δ)) back to σ.
-/
theorem truth_double_shift_cancel (M : TaskModel F) (Omega : Set (WorldHistory F))
    (σ : WorldHistory F) (Δ : D) (t : D)
    (φ : Formula) :
    truth_at M Omega (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)) t φ ↔
    truth_at M Omega σ t φ := by
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
    -- Box quantifies over sigma in Omega at time t, independent of current history
    -- Both sides quantify over the same Omega, so definitionally equal
  | untl φ ψ ih_φ ih_ψ =>
    simp only [truth_at]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mp h_event, fun r hr1 hr2 => (ih_ψ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mpr h_event, fun r hr1 hr2 => (ih_ψ r).mpr (h_guard r hr1 hr2)⟩
  | snce φ ψ ih_φ ih_ψ =>
    simp only [truth_at]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mp h_event, fun r hr1 hr2 => (ih_ψ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mpr h_event, fun r hr1 hr2 => (ih_ψ r).mpr (h_guard r hr1 hr2)⟩

/--
Time-shift preserves truth of formulas.

If σ is a history and Δ = y - x, then truth at (σ, y) equals truth at (time_shift σ Δ, x).

**Paper Reference**: lem:history-time-shift-preservation establishes this property.

The proof proceeds by structural induction on formulas:
- **Atom**: States match because (time_shift σ Δ).states x = σ.states (x + Δ) = σ.states y
- **Bot**: Both sides are False
- **Imp**: By induction hypothesis on subformulas
- **Box**: Both quantify over histories in Omega; ShiftClosed ensures shifted histories
  remain in Omega, enabling the bijection argument
- **Past/Future**: Times shift together with the history

**Key Insight**: The box case requires ShiftClosed(Omega) to ensure that when we shift
a history ρ ∈ Omega by (y - x) or (x - y), the result stays in Omega. This is needed
to apply the box hypothesis to the shifted history.
-/
theorem time_shift_preserves_truth (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    truth_at M Omega (WorldHistory.time_shift σ (y - x)) x φ ↔ truth_at M Omega σ y φ := by
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
    -- For box, both quantify over histories in Omega at their times
    -- We use ShiftClosed to ensure shifted histories remain in Omega
    simp only [truth_at]
    constructor
    · intro h_box_x ρ h_rho_mem
      -- ρ ∈ Omega, need to show truth at (ρ, y)
      -- time_shift ρ (y - x) ∈ Omega by h_sc
      have h_shifted_mem : WorldHistory.time_shift ρ (y - x) ∈ Omega :=
        h_sc ρ h_rho_mem (y - x)
      have h1 := h_box_x (WorldHistory.time_shift ρ (y - x)) h_shifted_mem
      -- Apply IH with ρ instead of σ
      exact (ih ρ x y).mp h1
    · intro h_box_y ρ h_rho_mem
      -- ρ ∈ Omega, need to show truth at (ρ, x)
      -- time_shift ρ (x - y) ∈ Omega by h_sc
      have h_shifted_mem : WorldHistory.time_shift ρ (x - y) ∈ Omega :=
        h_sc ρ h_rho_mem (x - y)
      have h1 := h_box_y (WorldHistory.time_shift ρ (x - y)) h_shifted_mem
      -- Apply IH with time_shift ρ (x - y) instead of σ
      have h2 := (ih (WorldHistory.time_shift ρ (x - y)) x y).mpr h1
      -- h2 : truth_at M Omega (time_shift (time_shift ρ (x-y)) (y-x)) x ψ
      -- Need: truth_at M Omega ρ x ψ
      have h_cancel : y - x = -(x - y) := (neg_sub x y).symm
      have h_hist_eq :
        WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (y - x) =
        WorldHistory.time_shift (WorldHistory.time_shift ρ (x - y)) (-(x - y)) := by
        exact WorldHistory.time_shift_congr
          (WorldHistory.time_shift ρ (x - y)) (y - x) (-(x - y)) h_cancel
      have h2' := (truth_history_eq M Omega _ _ x h_hist_eq ψ).mp h2
      exact (truth_double_shift_cancel M Omega ρ (x - y) x ψ).mp h2'

  | untl φ ψ ih_φ ih_ψ =>
    -- Until (Burgess convention): untl(event=φ, guard=ψ)
    -- ∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ψ(r)
    -- Direction (→): shifted history at x → original history at y
    --   Witness s in shifted maps to s+(y-x) in original.
    -- Direction (←): original at y → shifted at x
    --   Witness s in original maps to s-(y-x) in shifted.
    simp only [truth_at]
    constructor
    · -- (→) shifted at x → original at y
      intro ⟨s, h_x_lt_s, h_event_s, h_guard⟩
      -- Witness in original: s + (y - x)
      refine ⟨s + (y - x), ?_, ?_, ?_⟩
      · -- y < s + (y - x)
        have h := add_lt_add_right h_x_lt_s (y - x)
        have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
        calc y = x + (y - x) := h_eq.symm
          _ = (y - x) + x := add_comm x (y - x)
          _ < (y - x) + s := h
          _ = s + (y - x) := add_comm (y - x) s
      · -- φ (event) at (σ, s + (y - x))
        have h_shift_eq2 : (s + (y - x)) - s = y - x :=
          add_sub_cancel_left s (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ ((s + (y - x)) - s) =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((s + (y - x)) - s) (y - x) h_shift_eq2
        have h_conv := (truth_history_eq M Omega _ _ s h_hist_eq.symm φ).mp h_event_s
        exact (ih_φ σ s (s + (y - x))).mp h_conv
      · -- guard: ∀ r, y < r → r < s + (y - x) → ψ(σ, r)
        intro r h_y_lt_r h_r_lt_s'
        have h_x_lt_r' : x < r - (y - x) := by
          have h := sub_lt_sub_right h_y_lt_r (y - x)
          simp only [sub_sub_cancel] at h
          exact h
        have h_r'_lt_s : r - (y - x) < s := by
          have h := sub_lt_sub_right h_r_lt_s' (y - x)
          simp only [add_sub_cancel_right] at h
          exact h
        have h_grd := h_guard (r - (y - x)) h_x_lt_r' h_r'_lt_s
        have h_shift_eq : r - (r - (y - x)) = y - x := sub_sub_cancel r (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ (r - (r - (y - x))) =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (r - (r - (y - x))) (y - x) h_shift_eq
        have h_conv := (truth_history_eq M Omega _ _ (r - (y - x)) h_hist_eq.symm ψ).mp h_grd
        exact (ih_ψ σ (r - (y - x)) r).mp h_conv
    · -- (←) original at y → shifted at x
      intro ⟨s, h_y_lt_s, h_event_s, h_guard⟩
      -- Witness in shifted: s - (y - x)
      refine ⟨s - (y - x), ?_, ?_, ?_⟩
      · -- x < s - (y - x)
        have h := sub_lt_sub_right h_y_lt_s (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      · -- φ (event) at (shifted σ, s - (y - x))
        have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ (s - (s - (y - x))) =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
        have h_conv := (ih_φ σ (s - (y - x)) s).mpr h_event_s
        exact (truth_history_eq M Omega _ _ (s - (y - x)) h_hist_eq φ).mp h_conv
      · -- guard: ∀ r', x < r' → r' < s - (y - x) → ψ(shifted σ, r')
        intro r' h_x_lt_r' h_r'_lt_s'
        have h_y_lt_r : y < r' + (y - x) := by
          have h := add_lt_add_right h_x_lt_r' (y - x)
          have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
          calc y = x + (y - x) := h_eq.symm
            _ = (y - x) + x := add_comm x (y - x)
            _ < (y - x) + r' := h
            _ = r' + (y - x) := add_comm (y - x) r'
        have h_r_lt_s : r' + (y - x) < s := by
          have h_eq : s - (y - x) + (y - x) = s := sub_add_cancel s (y - x)
          calc r' + (y - x) < s - (y - x) + (y - x) :=
                add_lt_add_left h_r'_lt_s' (y - x)
            _ = s := h_eq
        have h_grd := h_guard (r' + (y - x)) h_y_lt_r h_r_lt_s
        have h_shift_eq : (r' + (y - x)) - r' = y - x :=
          add_sub_cancel_left r' (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ ((r' + (y - x)) - r') =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((r' + (y - x)) - r')
            (y - x) h_shift_eq
        have h_conv := (ih_ψ σ r' (r' + (y - x))).mpr h_grd
        exact (truth_history_eq M Omega _ _ r' h_hist_eq ψ).mp h_conv

  | snce φ ψ ih_φ ih_ψ =>
    -- Since (Burgess convention): snce(event=φ, guard=ψ)
    -- ∃ s < t, φ(s) ∧ ∀ r ∈ (s,t), ψ(r)
    -- Mirror of Until with reversed inequalities.
    simp only [truth_at]
    constructor
    · -- (→) shifted at x → original at y
      intro ⟨s, h_s_lt_x, h_event_s, h_guard⟩
      -- Witness in original: s + (y - x)
      refine ⟨s + (y - x), ?_, ?_, ?_⟩
      · -- s + (y - x) < y
        have h := add_lt_add_right h_s_lt_x (y - x)
        calc s + (y - x) = (y - x) + s := add_comm s (y - x)
          _ < (y - x) + x := h
          _ = x + (y - x) := add_comm (y - x) x
          _ = y := by rw [add_sub, add_sub_cancel_left]
      · -- φ (event) at (σ, s + (y - x))
        have h_shift_eq : (s + (y - x)) - s = y - x :=
          add_sub_cancel_left s (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ ((s + (y - x)) - s) =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((s + (y - x)) - s)
            (y - x) h_shift_eq
        have h_conv := (truth_history_eq M Omega _ _ s h_hist_eq.symm φ).mp h_event_s
        exact (ih_φ σ s (s + (y - x))).mp h_conv
      · -- guard: ∀ r, s + (y - x) < r → r < y → ψ(σ, r)
        intro r h_s'_lt_r h_r_lt_y
        have h_s_lt_r' : s < r - (y - x) := by
          have h := sub_lt_sub_right h_s'_lt_r (y - x)
          simp only [add_sub_cancel_right] at h
          exact h
        have h_r'_lt_x : r - (y - x) < x := by
          have h := sub_lt_sub_right h_r_lt_y (y - x)
          simp only [sub_sub_cancel] at h
          exact h
        have h_grd := h_guard (r - (y - x)) h_s_lt_r' h_r'_lt_x
        have h_shift_eq : r - (r - (y - x)) = y - x := sub_sub_cancel r (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ (r - (r - (y - x))) =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (r - (r - (y - x))) (y - x) h_shift_eq
        have h_conv := (truth_history_eq M Omega _ _ (r - (y - x)) h_hist_eq.symm ψ).mp h_grd
        exact (ih_ψ σ (r - (y - x)) r).mp h_conv
    · -- (←) original at y → shifted at x
      intro ⟨s, h_s_lt_y, h_event_s, h_guard⟩
      -- Witness in shifted: s - (y - x)
      refine ⟨s - (y - x), ?_, ?_, ?_⟩
      · -- s - (y - x) < x
        have h := sub_lt_sub_right h_s_lt_y (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      · -- φ (event) at (shifted σ, s - (y - x))
        have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ (s - (s - (y - x))) =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
        have h_conv := (ih_φ σ (s - (y - x)) s).mpr h_event_s
        exact (truth_history_eq M Omega _ _ (s - (y - x)) h_hist_eq φ).mp h_conv
      · -- guard: ∀ r', s - (y - x) < r' → r' < x → ψ(shifted σ, r')
        intro r' h_s'_lt_r' h_r'_lt_x
        have h_s_lt_r : s < r' + (y - x) := by
          calc s = s - (y - x) + (y - x) := (sub_add_cancel s (y - x)).symm
            _ < r' + (y - x) := add_lt_add_left h_s'_lt_r' (y - x)
        have h_r_lt_y : r' + (y - x) < y := by
          have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
          calc r' + (y - x) < x + (y - x) := add_lt_add_left h_r'_lt_x (y - x)
            _ = y := h_eq
        have h_grd := h_guard (r' + (y - x)) h_s_lt_r h_r_lt_y
        have h_shift_eq : (r' + (y - x)) - r' = y - x :=
          add_sub_cancel_left r' (y - x)
        have h_hist_eq :
          WorldHistory.time_shift σ ((r' + (y - x)) - r') =
          WorldHistory.time_shift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((r' + (y - x)) - r')
            (y - x) h_shift_eq
        have h_conv := (ih_ψ σ r' (r' + (y - x))).mpr h_grd
        exact (truth_history_eq M Omega _ _ r' h_hist_eq ψ).mp h_conv

/--
Corollary: For any history σ at time y, there exists a history at time x
(namely, time_shift σ (y - x)) where the same formulas are true.

This is the key lemma for proving MF and TF axioms.
-/
theorem exists_shifted_history (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    truth_at M Omega σ y φ ↔
    truth_at M Omega (WorldHistory.time_shift σ (y - x)) x φ := by
  exact (time_shift_preserves_truth M Omega h_sc σ x y φ).symm

end TimeShift


end Bimodal.Semantics
