import Bimodal.Semantics.Truth
import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms

/-!
# Soundness Lemmas - Bridge Theorems for Temporal Duality

This module contains bridge theorems that connect the proof system (DerivationTree)
to semantic validity (is_valid). These theorems were extracted from Truth.lean to
resolve a circular dependency between Truth.lean and Soundness.lean.

## Module Purpose

The theorems in this module prove that swap validity is preserved for derivable formulas
using derivation induction rather than formula induction. This enables the temporal_duality
soundness proof in Soundness.lean.

## Circular Dependency Resolution

**Original Problem**:
```
Truth.lean (imports Derivation.lean for bridge theorems)
   ↑
Validity.lean (imports Truth.lean)
   ↑
Soundness.lean (imports Validity.lean, wants to use bridge theorems)
   ↓ (circular!)
```

**Solution**:
```
Soundness.lean → SoundnessLemmas.lean → Truth.lean (pure semantics)
```

No cycle! Truth.lean doesn't import Soundness or SoundnessLemmas.

## Main Results

- `axiom_swap_valid`: All 10 TM axioms remain valid after swap
- `derivable_implies_swap_valid`: Main theorem for soundness of temporal_duality
- Individual `swap_axiom_*_valid` lemmas (8 lemmas for specific axioms)
- `*_preserves_swap_valid` lemmas (5 lemmas for inference rules)

## Implementation Notes

- Uses local `is_valid` definition to avoid circular dependency with Validity.lean
- Employs derivation induction instead of formula induction
- MF and TF axioms use `time_shift_preserves_truth` for local time transport
- TL axiom uses classical logic for conjunction extraction from negation encoding

## References

* [Truth.lean](../Semantics/Truth.lean) - Pure semantic definitions
* [Soundness.lean](Soundness.lean) - Soundness theorem using these lemmas
* Task 213 research report - Circular dependency analysis
* Task 219 implementation plan - Module hierarchy restructuring
-/

namespace Bimodal.Boneyard.Metalogic.Soundness.SoundnessLemmas

open Bimodal.Syntax
open Bimodal.ProofSystem (Axiom DerivationTree)
open Bimodal.Semantics

/--
Local definition of validity to avoid circular dependency with Validity.lean.
A formula is valid if it's true at all model-history-time triples.

This is a monomorphic definition (fixed to explicit type parameter D) to avoid
universe level mismatch errors.
Per research report Option A: Make D explicit to allow type inference at call sites.

**Note**: With the new semantics (Task #454), validity quantifies over ALL times,
not just times in the history's domain.
-/
private def is_valid (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    truth_at M τ t φ

-- Section variable for theorem signatures
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Auxiliary lemma: If φ is valid, then for any specific triple (M, τ, t),
φ is true at that triple.

This is just the definition of validity, but stated as a lemma for clarity.
-/
theorem valid_at_triple {φ : Formula} (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (t : D) (h_valid : is_valid D φ) :
    truth_at M τ t φ := h_valid F M τ t

/--
Helper lemma: truth_at is invariant under double swap.

This lemma proves that applying swap twice to a formula preserves truth evaluation.
Required because truth_at is defined by structural recursion, preventing direct use
of the involution property φ.swap.swap = φ via substitution.
-/
theorem truth_at_swap_swap {F : TaskFrame D} (M : TaskModel F)
    (τ : WorldHistory F) (t : D) (φ : Formula) :
    truth_at M τ t φ.swap_past_future.swap_past_future ↔ truth_at M τ t φ := by
  induction φ generalizing τ t with
  | atom p =>
    -- Atom case: swap doesn't change atoms
    simp only [Formula.swap_temporal, truth_at]

  | bot =>
    -- Bot case: swap doesn't change bot
    simp only [Formula.swap_temporal, truth_at]

  | imp φ ψ ih_φ ih_ψ =>
    -- Implication case: (φ.swap.swap → ψ.swap.swap) ↔ (φ → ψ)
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h <;> intro h_φ
    · exact (ih_ψ τ t).mp (h ((ih_φ τ t).mpr h_φ))
    · exact (ih_ψ τ t).mpr (h ((ih_φ τ t).mp h_φ))

  | box φ ih =>
    -- Box case: □(φ.swap.swap) ↔ □φ
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h σ
    · exact (ih σ t).mp (h σ)
    · exact (ih σ t).mpr (h σ)

  | all_past φ ih =>
    -- All_past case: all_past φ → all_future φ.swap → all_past φ.swap.swap
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h s h_ord
    · exact (ih τ s).mp (h s h_ord)
    · exact (ih τ s).mpr (h s h_ord)

  | all_future φ ih =>
    -- All_future case: all_future φ → all_past φ.swap → all_future φ.swap.swap
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h s h_ord
    · exact (ih τ s).mp (h s h_ord)
    · exact (ih τ s).mpr (h s h_ord)

/-!
## NOTE: Unprovable Theorem Removed

The theorem `is_valid_swap_involution` as originally stated is **UNPROVABLE**.

**Original claim**: `is_valid D φ.swap → is_valid D φ`

**Why it's false**: The `swap_past_future` operation exchanges `all_past` ↔ `all_future`,
which quantify over different time ranges (past s<t vs future s>t). These are not
equivalent in general temporal models.

**Counterexample**: Consider φ = all_past(atom "p") in a model where p is true at all
future times but false at all past times. Then φ.swap = all_future(atom "p") is valid,
but φ = all_past(atom "p") is not valid.

**Semantic analysis**: The swap operation creates an asymmetry:
- `all_past φ` quantifies over s < t (past times)
- `all_future φ` quantifies over s > t (future times)
- Swapping exchanges these ranges, which are not equivalent in arbitrary models

**The theorem IS true for derivable formulas** (see `derivable_valid_swap_involution` at end of file),
because the temporal_duality inference rule guarantees swap preservation for provable formulas.

**Research**: See task 213 research report for detailed semantic analysis and proof of
unprovability. This finding resolves 10.7 hours of blocked work across tasks 184, 193, 209, 213.

**Lesson learned**: Always verify semantic validity before attempting formal proof.
Syntactic properties (derivations) and semantic properties (validity) have different
characteristics - involution applies to syntax but not necessarily to semantics.
-/

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
    is_valid D ((Formula.box φ).imp φ).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap_φ
  -- h_box_swap_φ : ∀ (σ : WorldHistory F), truth_at M σ t φ.swap_past_future
  -- Goal: truth_at M τ t φ.swap_past_future
  -- Choose σ = τ
  exact h_box_swap_φ τ

/--
Modal 4 axiom (M4) is self-dual under swap: `□φ → □□φ` swaps to `□(swap φ) → □□(swap φ)`.

This is still M4, just applied to swapped formula.

**Proof**: If φ.swap holds at all histories at t, then "φ.swap holds at all histories at t"
holds at all histories at t (trivially, as this is a global property).
-/
theorem swap_axiom_m4_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.box φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap_φ σ
  -- Goal: ∀ (ρ : WorldHistory F), truth_at M ρ t φ.swap_past_future
  intro ρ
  -- h_box_swap_φ says φ.swap holds at ALL histories at time t
  exact h_box_swap_φ ρ

/--
Modal B axiom (MB) is self-dual under swap: `φ → □◇φ` swaps to `swap φ → □◇(swap φ)`.

This is still MB, just applied to swapped formula.

**Proof**: If φ.swap holds at (M, τ, t), then for any history σ at t, ◇(φ.swap) holds at σ.
The diamond ◇ψ means "there exists some history where ψ holds". We have τ witnessing this.
-/
theorem swap_axiom_mb_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.box φ.diamond)).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_past_future, Formula.diamond, truth_at]
  intro h_swap_φ σ
  -- Goal: ¬ ∀ (σ' : WorldHistory F), ¬ truth_at M σ' t φ.swap_past_future
  -- Equivalently: ∃ σ', truth_at M σ' t φ.swap_past_future
  intro h_all_not
  -- h_all_not says: φ.swap is false at ALL histories at t
  -- But h_swap_φ says: φ.swap is true at (M, τ, t)
  -- Contradiction when we instantiate h_all_not with τ
  exact h_all_not τ h_swap_φ

/--
Temporal 4 axiom (T4) swaps to a valid formula: `Fφ → FFφ` swaps to `P(swap φ) → PP(swap φ)`.

The swapped form states: if swap φ held at all past times, then at all past times,
swap φ held at all past times. This is valid by transitivity of the past operator.

**Proof**: Given P(swap φ) at (M, τ, t), we have swap φ at all s < t.
To show PP(swap φ), for any r < t, we need P(swap φ) at r.
For any u < r, we need swap φ at u. Since u < r < t, swap φ at u follows from P(swap φ) at t.
-/
theorem swap_axiom_t4_valid (φ : Formula) :
    is_valid D
      ((Formula.all_future φ).imp
       (Formula.all_future (Formula.all_future φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_past_swap r h_r_le_t u h_u_le_r
  -- h_past_swap : ∀ (s : D), s ≤ t → truth_at M τ s φ.swap_past_future
  -- Need: truth_at M τ u φ.swap_past_future
  -- Since u ≤ r ≤ t, we have u ≤ t, so apply h_past_swap
  have h_u_le_t : u ≤ t := le_trans h_u_le_r h_r_le_t
  exact h_past_swap u h_u_le_t

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
    is_valid D (φ.imp (Formula.all_future φ.sometime_past)).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_past_future, Formula.sometime_past, Formula.sometime_future, truth_at]
  intro h_swap_φ s h_s_le_t
  -- Goal: ¬ ∀ (u : D), u ≥ s → ¬ truth_at M τ u φ.swap_past_future
  -- Equivalently: ∃ u ≥ s : swap φ at u
  intro h_all_not_future
  -- We can choose u = t, since s ≤ t (from h_s_le_t)
  exact h_all_not_future t h_s_le_t h_swap_φ

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
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))).swap_past_future := by
  intro F M τ t
  -- Swapped form: (always φ).swap → (future (past φ)).swap
  --             = always (swap φ) → past (future (swap φ))
  -- In semantics: if swap φ holds at all times, then at all s < t,
  --               there exists u > s where swap φ holds
  -- This is trivially valid: if swap φ holds everywhere, pick any u > s
  simp only [Formula.swap_temporal, truth_at]
  intro h_always s h_s_le_t u h_s_le_u
  -- h_always encodes: ¬(future(swap φ) → ¬(swap φ ∧ past(swap φ)))
  -- which is classically equivalent to: future(swap φ) ∧ swap φ ∧ past(swap φ)
  -- meaning swap φ holds at all times
  --
  -- We need: truth_at M τ u φ.swap_past_future where s ≤ u and s ≤ t
  -- Consider cases on u relative to t:
  by_cases h_ut : u < t
  · -- Case: u < t, use the "past" component
    -- From h_always, we can extract that swap φ holds at all s' ≤ t
    apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro h_fut_all
    intro h_conj
    apply h_conj
    intro h_now
    intro h_past
    -- h_past : ∀ s' ≤ t, swap φ holds at s'
    -- Since u < t, we have u ≤ t, swap φ holds at u
    exact h_neg (h_past u (le_of_lt h_ut))
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
      exact h_neg h_now
    · -- Case: u > t, use the "future" component
      have h_gt : t < u := lt_of_le_of_ne (le_of_not_lt h_ut) (Ne.symm h_eq)
      apply Classical.byContradiction
      intro h_neg
      apply h_always
      intro h_fut_all
      intro h_conj
      -- h_fut_all : ∀ r ≥ t, swap φ holds at r
      -- Since u > t, we have t ≤ u, swap φ holds at u
      exact h_neg (h_fut_all u (le_of_lt h_gt))

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
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.all_future φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap σ s h_s_lt_t
  -- h_box_swap : ∀ (ρ : WorldHistory F), truth_at M ρ t φ.swap_past_future
  -- Goal: truth_at M σ s φ.swap_past_future
  --
  -- Strategy: Use time_shift_preserves_truth to bridge from time t to time s.
  -- Get truth at shifted history at time t
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t))
  -- Use time_shift_preserves_truth to transport to (σ, s)
  exact (TimeShift.time_shift_preserves_truth M σ t s φ.swap_past_future).mp h_at_shifted

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
    is_valid D ((Formula.box φ).imp (Formula.all_future (Formula.box φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap s h_s_lt_t σ
  -- h_box_swap : ∀ (ρ : WorldHistory F), truth_at M ρ t φ.swap_past_future
  -- Goal: truth_at M σ s φ.swap_past_future
  -- The premise says swap φ holds at ALL histories at time t
  -- We need swap φ at history σ at time s < t
  -- Same strategy as MF: use time_shift_preserves_truth
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t))
  exact (TimeShift.time_shift_preserves_truth M σ t s φ.swap_past_future).mp h_at_shifted

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
    (h_imp : is_valid D (φ.imp ψ).swap_past_future)
    (h_phi : is_valid D φ.swap_past_future) :
    is_valid D ψ.swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at] at h_imp h_phi ⊢
  exact h_imp F M τ t (h_phi F M τ t)

/--
Modal K rule preserves swap validity.

If `φ.swap` is valid, then `(□φ).swap = □(φ.swap)` is valid.

**Proof**: If `φ.swap` is true at all triples, then for any (F, M, τ, t),
at all histories σ at time t, `φ.swap` is true at (M, σ, t). This is exactly `□(φ.swap)`.
-/
theorem modal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D (Formula.box φ).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro σ
  exact h F M σ t

/--
Temporal K rule preserves swap validity.

If `φ.swap` is valid, then `(Fφ).swap = P(φ.swap)` is valid.

**Proof**: If `φ.swap` is true at all triples, then for any (F, M, τ, t),
at all times s < t, `φ.swap` is true at (M, τ, s). This is exactly `P(φ.swap)`.
-/
theorem temporal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D (Formula.all_future φ).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro s h_s_lt_t
  exact h F M τ s

/--
Weakening preserves swap validity (trivial for empty context).

For the temporal duality rule, we only consider derivations from empty context.
Weakening from [] to [] is trivial.

**Note**: A general version would need to handle non-empty contexts, but temporal duality
only applies to theorems (empty context derivations).
-/
theorem weakening_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D φ.swap_past_future := h

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

theorem axiom_swap_valid (φ : Formula) (h : Axiom φ) : is_valid D φ.swap_past_future := by
  cases h with
  | prop_k ψ χ ρ =>
    -- prop_k is (ψ → (χ → ρ)) → ((ψ → χ) → (ψ → ρ))
    -- After swap: (ψ.swap → (χ.swap → ρ.swap)) → ((ψ.swap → χ.swap) → (ψ.swap → ρ.swap))
    -- This is still prop_k applied to swapped subformulas
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    -- Goal is a propositional tautology: ((A → (B → C)) → ((A → B) → (A → C)))
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    -- prop_s is ψ → (χ → ψ)
    -- After swap: ψ.swap → (χ.swap → ψ.swap)
    -- This is still prop_s applied to swapped subformulas
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
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
    intro F M τ t
    simp only [Formula.swap_past_future, Formula.diamond, Formula.neg, truth_at]
    -- Goal: ((∀ σ, (∀ ρ, truth_at ... ψ.swap) → False) → False)
    --       → (∀ σ, truth_at ... ψ.swap)
    intro h_diamond_box σ
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    -- ex_falso is ⊥ → ψ
    -- After swap: ⊥ → ψ.swap
    -- This is still ex_falso applied to swapped subformula (bot unchanged)
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    -- Goal: False → truth_at ... ψ.swap
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    -- peirce is ((ψ → χ) → ψ) → ψ
    -- After swap: ((ψ.swap → χ.swap) → ψ.swap) → ψ.swap
    -- This is still peirce applied to swapped subformulas
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    -- Goal: ((truth_at ... ψ.swap → truth_at ... χ.swap)
    --        → truth_at ... ψ.swap) → truth_at ... ψ.swap
    intro h_peirce
    by_cases h : truth_at M τ t ψ.swap_past_future
    · exact h
    · have h_imp : truth_at M τ t (ψ.swap_past_future.imp χ.swap_past_future) := by
        unfold truth_at
        intro h_psi
        exfalso
        exact h h_psi
      exact h_peirce h_imp
  | modal_k_dist ψ χ =>
    -- modal_k_dist is □(ψ → χ) → (□ψ → □χ)
    -- After swap: □(ψ.swap → χ.swap) → (□ψ.swap → □χ.swap)
    -- This is still modal_k_dist applied to swapped subformulas (modal operators unchanged)
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    -- Goal: (∀ σ, truth_at ... ψ.swap → truth_at ... χ.swap) →
    --       (∀ σ, truth_at ... ψ.swap) → (∀ σ, truth_at ... χ.swap)
    intro h_box_imp h_box_psi σ
    exact h_box_imp σ (h_box_psi σ)
  | temp_k_dist ψ χ =>
    -- temp_k_dist is F(ψ → χ) → (Fψ → Fχ)
    -- After swap: P(ψ.swap → χ.swap) → (Pψ.swap → Pχ.swap)
    -- This is the past version of temp_k_dist (swap exchanges F and P)
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    -- Goal: (∀ s, s < t → truth_at ... ψ.swap → truth_at ... χ.swap) →
    --       (∀ s, s < t → truth_at ... ψ.swap) → (∀ s, s < t → truth_at ... χ.swap)
    intro h_past_imp h_past_psi s hst
    exact h_past_imp s hst (h_past_psi s hst)
  | temp_4 ψ => exact swap_axiom_t4_valid ψ
  | temp_a ψ => exact swap_axiom_ta_valid ψ
  | temp_l ψ => exact swap_axiom_tl_valid ψ
  | temp_t_future ψ =>
    -- temp_t_future is Gψ → ψ, after swap: Hψ.swap → ψ.swap
    -- With reflexive semantics: (∀ s ≤ t, ψ.swap(s)) → ψ.swap(t)
    -- Valid by instantiating s = t using le_refl
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_past
    exact h_past t (le_refl t)
  | temp_t_past ψ =>
    -- temp_t_past is Hψ → ψ, after swap: Gψ.swap → ψ.swap
    -- With reflexive semantics: (∀ s ≥ t, ψ.swap(s)) → ψ.swap(t)
    -- Valid by instantiating s = t using le_refl
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_future
    exact h_future t (le_refl t)
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | temp_future ψ => exact swap_axiom_tf_valid ψ

/-! ## Axiom Validity (Local)

These lemmas prove validity of each axiom using the local `is_valid` definition.
This is needed to prove the combined soundness+swap theorem without importing Soundness.lean.
-/

/-- Propositional K axiom is locally valid. -/
private theorem axiom_prop_k_valid (φ ψ χ : Formula) :
    is_valid D ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro F M τ t
  simp only [truth_at]
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/-- Propositional S axiom is locally valid. -/
private theorem axiom_prop_s_valid (φ ψ : Formula) :
    is_valid D (φ.imp (ψ.imp φ)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_phi _
  exact h_phi

/-- Modal T axiom is locally valid. -/
private theorem axiom_modal_t_valid (φ : Formula) :
    is_valid D (φ.box.imp φ) := by
  intro F M τ t
  simp only [truth_at]
  intro h_box
  exact h_box τ

/-- Modal 4 axiom is locally valid. -/
private theorem axiom_modal_4_valid (φ : Formula) :
    is_valid D ((φ.box).imp (φ.box.box)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_box σ ρ
  exact h_box ρ

/-- Modal B axiom is locally valid. -/
private theorem axiom_modal_b_valid (φ : Formula) :
    is_valid D (φ.imp (φ.diamond.box)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_phi σ h_box_neg
  have h_neg_at_tau := h_box_neg τ
  simp only [truth_at] at h_neg_at_tau
  exact h_neg_at_tau h_phi

/-- Modal 5 collapse axiom is locally valid. -/
private theorem axiom_modal_5_collapse_valid (φ : Formula) :
    is_valid D (φ.box.diamond.imp φ.box) := by
  intro F M τ t
  simp only [truth_at]
  intro h_diamond_box ρ
  by_contra h_not_phi
  apply h_diamond_box
  intro σ h_box_at_sigma
  have h_phi_at_rho := h_box_at_sigma ρ
  exact h_not_phi h_phi_at_rho

/-- Ex falso axiom is locally valid. -/
private theorem axiom_ex_falso_valid (φ : Formula) :
    is_valid D (Formula.bot.imp φ) := by
  intro F M τ t
  simp only [truth_at]
  intro h_bot
  exfalso
  exact h_bot

/-- Peirce's law is locally valid. -/
private theorem axiom_peirce_valid (φ ψ : Formula) :
    is_valid D (((φ.imp ψ).imp φ).imp φ) := by
  intro F M τ t
  simp only [truth_at]
  intro h_peirce
  by_cases h : truth_at M τ t φ
  · exact h
  · have h_imp : truth_at M τ t (φ.imp ψ) := by
      simp only [truth_at]
      intro h_phi
      exfalso
      exact h h_phi
    exact h_peirce h_imp

/-- Modal K distribution axiom is locally valid. -/
private theorem axiom_modal_k_dist_valid (φ ψ : Formula) :
    is_valid D ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_box_imp h_box_phi σ
  have h_imp_at_σ := h_box_imp σ
  have h_phi_at_σ := h_box_phi σ
  simp only [truth_at] at h_imp_at_σ
  exact h_imp_at_σ h_phi_at_σ

/-- Temporal K distribution axiom is locally valid. -/
private theorem axiom_temp_k_dist_valid (φ ψ : Formula) :
    is_valid D ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_future_imp h_future_phi s hts
  have h_imp_at_s := h_future_imp s hts
  have h_phi_at_s := h_future_phi s hts
  simp only [truth_at] at h_imp_at_s
  exact h_imp_at_s h_phi_at_s

/-- Temporal 4 axiom is locally valid. -/
private theorem axiom_temp_4_valid (φ : Formula) :
    is_valid D ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_future s hts r hsr
  -- hts : t ≤ s, hsr : s ≤ r, so t ≤ r by transitivity
  have htr : t ≤ r := le_trans hts hsr
  exact h_future r htr

/-- Helper for temporal A axiom. -/
private theorem axiom_temp_a_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.sometime_past)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_phi s hts h_all_neg
  have h_neg_at_t := h_all_neg t hts
  simp only [truth_at] at h_neg_at_t
  exact h_neg_at_t h_phi

/-- Helper lemma for extracting conjunction from negated implication encoding. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/-- Temporal L axiom is locally valid. -/
private theorem axiom_temp_l_valid (φ : Formula) :
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro F M τ t
  simp only [truth_at]
  intro h_always s hts r hrs
  -- h_always encodes: ¬(past(φ) → ¬(φ ∧ future(φ)))
  -- which is classically equivalent to: past(φ) ∧ φ ∧ future(φ)
  -- meaning φ holds at all times (with reflexive semantics using ≤)
  have h1 :
    (∀ (u : D), u ≤ t → truth_at M τ u φ) ∧
    ((truth_at M τ t φ →
      (∀ (v : D), t ≤ v → truth_at M τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : truth_at M τ t φ ∧ (∀ (v : D), t ≤ v → truth_at M τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2
  -- With reflexive semantics, r is in past of s which is in future of t
  -- hrs : r ≤ s, hts : t ≤ s
  -- Case analysis: r ≤ t or t ≤ r
  rcases le_or_lt r t with h_le | h_gt
  · exact h_past r h_le
  · exact h_future r (le_of_lt h_gt)

/-- Temporal T axiom (future) is locally valid: Gφ → φ.
With reflexive semantics, Gφ at t means ∀ s ≥ t, φ(s).
Taking s = t gives φ(t) by le_refl. -/
private theorem axiom_temp_t_future_valid (φ : Formula) :
    is_valid D ((φ.all_future).imp φ) := by
  intro F M τ t
  simp only [truth_at]
  intro h_future
  exact h_future t (le_refl t)

/-- Temporal T axiom (past) is locally valid: Hφ → φ.
With reflexive semantics, Hφ at t means ∀ s ≤ t, φ(s).
Taking s = t gives φ(t) by le_refl. -/
private theorem axiom_temp_t_past_valid (φ : Formula) :
    is_valid D ((φ.all_past).imp φ) := by
  intro F M τ t
  simp only [truth_at]
  intro h_past
  exact h_past t (le_refl t)

/-- Modal-Future axiom is locally valid. -/
private theorem axiom_modal_future_valid (φ : Formula) :
    is_valid D ((φ.box).imp ((φ.all_future).box)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_box_phi σ s hts
  -- h_box_phi : ∀ σ, truth_at M σ t φ
  -- Goal: truth_at M σ s φ where t < s
  -- Strategy: Use time_shift_preserves_truth to bridge from time t to time s
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t))
  have h_preserve := TimeShift.time_shift_preserves_truth M σ t s φ
  exact h_preserve.mp h_phi_at_shifted

/-- Temporal-Future axiom is locally valid. -/
private theorem axiom_temp_future_valid (φ : Formula) :
    is_valid D ((φ.box).imp ((φ.box).all_future)) := by
  intro F M τ t
  simp only [truth_at]
  intro h_box_phi s hts σ
  -- h_box_phi : ∀ σ, truth_at M σ t φ
  -- Goal: truth_at M σ s φ where t < s
  -- Strategy: Use time_shift_preserves_truth to bridge from time t to time s
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t))
  have h_preserve := TimeShift.time_shift_preserves_truth M σ t s φ
  exact h_preserve.mp h_phi_at_shifted

/-- All axioms are locally valid. -/
private theorem axiom_locally_valid {φ : Formula} : Axiom φ → is_valid D φ := by
  intro h_axiom
  cases h_axiom with
  | prop_k φ ψ χ => exact axiom_prop_k_valid φ ψ χ
  | prop_s φ ψ => exact axiom_prop_s_valid φ ψ
  | modal_t ψ => exact axiom_modal_t_valid ψ
  | modal_4 ψ => exact axiom_modal_4_valid ψ
  | modal_b ψ => exact axiom_modal_b_valid ψ
  | modal_5_collapse ψ => exact axiom_modal_5_collapse_valid ψ
  | ex_falso ψ => exact axiom_ex_falso_valid ψ
  | peirce φ ψ => exact axiom_peirce_valid φ ψ
  | modal_k_dist φ ψ => exact axiom_modal_k_dist_valid φ ψ
  | temp_k_dist φ ψ => exact axiom_temp_k_dist_valid φ ψ
  | temp_4 ψ => exact axiom_temp_4_valid ψ
  | temp_a ψ => exact axiom_temp_a_valid ψ
  | temp_l ψ => exact axiom_temp_l_valid ψ
  | temp_t_future ψ => exact axiom_temp_t_future_valid ψ
  | temp_t_past ψ => exact axiom_temp_t_past_valid ψ
  | modal_future ψ => exact axiom_modal_future_valid ψ
  | temp_future ψ => exact axiom_temp_future_valid ψ

/-! ## Combined Theorem: Derivable Implies Valid AND Swap Valid

This is the key theorem that resolves the circular dependency. By proving BOTH soundness
and swap validity simultaneously via a single derivation induction, we can use the soundness
part of the IH to complete the temporal_duality case for swap validity.

**The temporal_duality case resolution**:
- We have: `h_ψ' : DerivationTree [] ψ'`
- IH gives: `is_valid D ψ' ∧ is_valid D ψ'.swap`
- Goal: `is_valid D ψ'.swap ∧ is_valid D ψ'.swap.swap`
- Part 1 (`is_valid D ψ'.swap`): directly from IH.2
- Part 2 (`is_valid D ψ'.swap.swap`): by involution = `is_valid D ψ'`, from IH.1
-/

/--
Combined theorem: Derivability from empty context implies both validity and swap validity.

This theorem proves both properties together to resolve the circular dependency that
prevented proving the temporal_duality case. The key insight is that the IH provides
BOTH validity and swap validity, so we can use validity (IH.1) to complete the swap
validity proof for temporal_duality.
-/
theorem derivable_implies_valid_and_swap_valid :
    ∀ {φ : Formula}, DerivationTree [] φ →
      (is_valid D φ ∧ is_valid D φ.swap_past_future) := by
  intro φ h_deriv
  -- Proof by induction on the derivation structure
  -- We generalize to arbitrary contexts but only use the [] case
  have h_general : ∀ (Γ : List Formula) (ψ : Formula),
      DerivationTree Γ ψ → Γ = [] →
        (is_valid D ψ ∧ is_valid D ψ.swap_past_future) := by
    intro Γ ψ h
    induction h with
    | «axiom» Γ' ψ' h_axiom =>
      intro h_eq
      -- Axiom case: both validity and swap validity hold
      constructor
      · exact axiom_locally_valid h_axiom
      · exact axiom_swap_valid ψ' h_axiom

    | «assumption» Γ' ψ' h_mem =>
      intro h_eq
      -- Γ' = [], so h_mem : ψ' ∈ [] is impossible
      rw [h_eq] at h_mem
      exact False.elim (List.not_mem_nil h_mem)

    | modus_ponens Γ' ψ' χ' h_imp h_ψ' ih_imp ih_ψ' =>
      intro h_eq
      -- Modus ponens: use IH for both properties
      obtain ⟨h_imp_valid, h_imp_swap⟩ := ih_imp h_eq
      obtain ⟨h_ψ_valid, h_ψ_swap⟩ := ih_ψ' h_eq
      constructor
      · -- Validity of χ'
        intro F M τ t
        have h1 := h_imp_valid F M τ t
        have h2 := h_ψ_valid F M τ t
        simp only [truth_at] at h1
        exact h1 h2
      · -- Swap validity of χ'
        exact mp_preserves_swap_valid ψ' χ' h_imp_swap h_ψ_swap

    | necessitation ψ' h_ψ' ih =>
      intro h_eq
      -- Necessitation: use IH for both properties
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · -- Validity of □ψ'
        intro F M τ t σ
        exact h_valid F M σ t
      · -- Swap validity of □ψ'
        exact modal_k_preserves_swap_valid ψ' h_swap

    | temporal_necessitation ψ' h_ψ' ih =>
      intro h_eq
      -- Temporal necessitation: use IH for both properties
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · -- Validity of Fψ'
        intro F M τ t s hts
        exact h_valid F M τ s
      · -- Swap validity of Fψ'
        exact temporal_k_preserves_swap_valid ψ' h_swap

    | temporal_duality ψ' h_ψ' ih =>
      intro h_eq
      -- KEY CASE: This is where the combined theorem approach pays off!
      -- We have: h_ψ' : DerivationTree [] ψ'
      -- IH gives: is_valid D ψ' ∧ is_valid D ψ'.swap
      -- Goal: is_valid D ψ'.swap ∧ is_valid D ψ'.swap.swap
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · -- Validity of ψ'.swap: directly from IH.2
        exact h_swap
      · -- Swap validity of ψ'.swap, i.e., validity of ψ'.swap.swap
        -- By involution: ψ'.swap.swap = ψ', so we need is_valid D ψ'
        -- This comes from IH.1!
        intro F M τ t
        have h_truth := h_valid F M τ t
        -- Use truth_at_swap_swap to rewrite the goal
        exact (truth_at_swap_swap M τ t ψ').mpr h_truth

    | weakening Γ' Δ' ψ' h_ψ' h_subset ih =>
      intro h_eq
      -- h_eq says Δ' = [] (the conclusion context)
      -- From weakening rule: Derivable Γ' ψ' with Γ' ⊆ Δ'
      -- Since Δ' = [] and Γ' ⊆ Δ', we have Γ' = []
      have h_gamma_empty : Γ' = [] := by
        cases Γ' with
        | nil => rfl
        | cons head tail =>
          have : head ∈ Δ' := h_subset List.mem_cons_self
          rw [h_eq] at this
          exact False.elim (List.not_mem_nil this)
      exact ih h_gamma_empty

  exact h_general [] φ h_deriv rfl

/-! ## Derived Theorems

These theorems extract the individual properties from the combined theorem.
-/

/--
Soundness from empty context: derivability implies validity.
Derived from the combined theorem.
-/
theorem soundness_from_empty :
    ∀ {φ : Formula}, DerivationTree [] φ → is_valid D φ :=
  fun h => (derivable_implies_valid_and_swap_valid h).1

/--
Main theorem: If a formula is derivable from empty context, then its swap is valid.
Derived from the combined theorem.

This replaces the previous sorry-containing version.
-/
theorem derivable_implies_swap_valid :
    ∀ {φ : Formula}, DerivationTree [] φ → is_valid D φ.swap_past_future :=
  fun h => (derivable_implies_valid_and_swap_valid h).2

end Bimodal.Boneyard.Metalogic.Soundness.SoundnessLemmas
