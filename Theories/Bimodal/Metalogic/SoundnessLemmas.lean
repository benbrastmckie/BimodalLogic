import Bimodal.Semantics.Truth
import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

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
   ^
Validity.lean (imports Truth.lean)
   ^
Soundness.lean (imports Validity.lean, wants to use bridge theorems)
   v (circular!)
```

**Solution**:
```
Soundness.lean -> SoundnessLemmas.lean -> Truth.lean (pure semantics)
```

No cycle! Truth.lean doesn't import Soundness or SoundnessLemmas.

## Main Results

- `axiom_swap_valid`: All TM axioms remain valid after swap
- `derivable_implies_swap_valid`: Main theorem for soundness of temporal_duality
- Individual `swap_axiom_*_valid` lemmas (8 lemmas for specific axioms)
- `*_preserves_swap_valid` lemmas (5 lemmas for inference rules)

## Implementation Notes

- Uses local `is_valid` definition to avoid circular dependency with Validity.lean
- Local `is_valid` quantifies over all shift-closed Omega sets, matching the global `valid`
- Employs derivation induction instead of formula induction
- MF and TF axioms use `time_shift_preserves_truth` for local time transport
- TL axiom uses classical logic for conjunction extraction from negation encoding

## Omega Parameterization

All local validity definitions and soundness lemmas quantify over shift-closed Omega.
This enables the temporal_duality case in Soundness.lean to use these lemmas at
arbitrary Omega (not just Set.univ), which is needed for the Omega-parameterized
soundness theorem to go through.

## References

* [Truth.lean](../Semantics/Truth.lean) - Pure semantic definitions
* [Soundness.lean](Soundness.lean) - Soundness theorem using these lemmas
-/

namespace Bimodal.Metalogic.SoundnessLemmas

open Bimodal.Syntax
open Bimodal.ProofSystem (Axiom DerivationTree FrameClass)
open Bimodal.Semantics

/--
Local definition of validity to avoid circular dependency with Validity.lean.
A formula is valid if it's true at all model-history-time triples within any shift-closed Omega.

This is a monomorphic definition (fixed to explicit type parameter D) to avoid
universe level mismatch errors.
Per research report Option A: Make D explicit to allow type inference at call sites.

**Note**: Validity quantifies over ALL times,
not just times in the history's domain.

**Omega Parameterization**: Quantifies over all shift-closed Omega sets
and histories in Omega, matching the global `valid` definition in Validity.lean.
-/
private def is_valid (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (_h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ

-- Section variable for theorem signatures
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Auxiliary lemma: If φ is valid, then for any specific tuple (M, Omega, h_sc, τ, h_mem, t),
φ is true at that tuple.

This is just the definition of validity, but stated as a lemma for clarity.
-/
theorem valid_at_triple {φ : Formula} (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (_h_mem : τ ∈ Omega) (t : D) (h_valid : is_valid D φ) :
    truth_at M Omega τ t φ := h_valid F M Omega _h_sc τ _h_mem t

/--
Helper lemma: truth_at is invariant under double swap.

This lemma proves that applying swap twice to a formula preserves truth evaluation.
Required because truth_at is defined by structural recursion, preventing direct use
of the involution property φ.swap.swap = φ via substitution.
-/
theorem truth_at_swap_swap {F : TaskFrame D} (M : TaskModel F)
    (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) (φ : Formula) :
    truth_at M Omega τ t φ.swap_temporal.swap_temporal ↔ truth_at M Omega τ t φ := by
  induction φ generalizing τ t with
  | atom p =>
    -- Atom case: swap doesn't change atoms
    simp only [Formula.swap_temporal, truth_at]

  | bot =>
    -- Bot case: swap doesn't change bot
    simp only [Formula.swap_temporal, truth_at]

  | imp φ ψ ih_φ ih_ψ =>
    -- Implication case: (φ.swap.swap -> ψ.swap.swap) <-> (φ -> ψ)
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h <;> intro h_φ
    · exact (ih_ψ τ t).mp (h ((ih_φ τ t).mpr h_φ))
    · exact (ih_ψ τ t).mpr (h ((ih_φ τ t).mp h_φ))

  | box φ ih =>
    -- Box case: box(φ.swap.swap) <-> box φ
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h σ h_σ_mem
    · exact (ih σ t).mp (h σ h_σ_mem)
    · exact (ih σ t).mpr (h σ h_σ_mem)

  | untl φ ψ ih_φ ih_ψ =>
    -- Until swaps to Since and back (Burgess: untl(event=φ, guard=ψ))
    simp only [Formula.swap_temporal, truth_at]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mp h_event, fun r hr1 hr2 => (ih_ψ τ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mpr h_event, fun r hr1 hr2 => (ih_ψ τ r).mpr (h_guard r hr1 hr2)⟩

  | snce φ ψ ih_φ ih_ψ =>
    -- Since swaps to Until and back (Burgess: snce(event=φ, guard=ψ))
    simp only [Formula.swap_temporal, truth_at]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mp h_event, fun r hr1 hr2 => (ih_ψ τ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mpr h_event, fun r hr1 hr2 => (ih_ψ τ r).mpr (h_guard r hr1 hr2)⟩

/-! ## Axiom Swap Validity (Approach D: Derivation-Indexed Proof)

This section proves validity of swapped axioms to enable temporal duality soundness
via derivation induction instead of formula induction.

The key insight: Instead of proving "valid φ -> valid φ.swap" for ALL valid formulas
(which is impossible for arbitrary imp, past, future cases), we prove that EACH axiom
schema remains valid after swap. This suffices for soundness of the temporal_duality
rule because we only need swap preservation for derivable formulas.

**Self-Dual Axioms**: MT, M4, MB have the property that swap preserves their schema form.
**Transformed Axioms**: T4, TA, TL, MF, TF transform to different but still valid formulas.
-/

/--
Modal T axiom (MT) is self-dual under swap: `box φ -> φ` swaps to `box(swap φ) -> swap φ`.

Since `box(swap φ) -> swap φ` is still an instance of MT (just with swapped subformula),
and MT is valid, this is immediate.

**Proof**: The swapped form is `(box φ.swap_temporal).imp φ.swap_temporal`.
At any triple (M, τ, t), if box φ.swap holds, then φ.swap holds at (M, τ, t) specifically.
-/
theorem swap_axiom_mt_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp φ).swap_temporal := by
  intro F M Omega _h_sc τ h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap_φ
  exact h_box_swap_φ τ h_mem

/--
Modal 4 axiom (M4) is self-dual under swap: `box φ -> box box φ` swaps to `box(swap φ) -> box box(swap φ)`.

This is still M4, just applied to swapped formula.

**Proof**: If φ.swap holds at all histories in Omega at t, then "φ.swap holds at all histories in Omega at t"
holds at all histories in Omega at t (trivially, as this is a global property).
-/
theorem swap_axiom_m4_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.box φ))).swap_temporal := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap_φ σ h_σ_mem ρ h_ρ_mem
  exact h_box_swap_φ ρ h_ρ_mem

/--
Modal B axiom (MB) is self-dual under swap: `φ -> box diamond φ` swaps to `swap φ -> box diamond(swap φ)`.

This is still MB, just applied to swapped formula.

**Proof**: If φ.swap holds at (M, τ, t), then for any history σ in Omega at t, diamond(φ.swap) holds at σ.
The diamond means "there exists some history in Omega where it holds". We have τ witnessing this.
-/
theorem swap_axiom_mb_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.box φ.diamond)).swap_temporal := by
  intro F M Omega _h_sc τ h_mem t
  simp only [Formula.swap_temporal, Formula.diamond, Formula.neg]
  simp only [truth_at]
  intro h_swap_φ σ _h_σ_mem h_all_not
  exact h_all_not τ h_mem h_swap_φ

/--
Temporal 4 axiom (T4) swaps to a valid formula: `Fφ -> FFφ` swaps to `P(swap φ) -> PP(swap φ)`.

The swapped form states: if swap φ held at all past times, then at all past times,
swap φ held at all past times. This is valid by transitivity of the past operator.
-/
theorem swap_axiom_t4_valid (φ : Formula) :
    is_valid D
      ((Formula.all_future φ).imp
       (Formula.all_future (Formula.all_future φ))).swap_temporal := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
  simp only [truth_at, Truth.past_iff]
  intro h_past_swap r h_r_lt_t u h_u_lt_r
  exact h_past_swap u (lt_trans h_u_lt_r h_r_lt_t)

/--
Temporal A axiom (TA) swaps to a valid formula: `φ -> F(some_past φ)` swaps to
`swap φ -> P(some_future (swap φ))`.

The swapped form states: if swap φ holds now, then at all past times, there existed
a future time when swap φ held. This is valid because "now" is in the future of all past times.
-/
theorem swap_axiom_ta_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.some_past)).swap_temporal := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal_all_future, Formula.swap_temporal_some_past,
    Formula.swap_temporal]
  simp only [truth_at, Truth.past_iff, Truth.some_future_iff]
  intro h_swap_φ s h_s_lt_t
  exact ⟨t, h_s_lt_t, h_swap_φ⟩

/--
Temporal L axiom (TL) swaps to a valid formula: `always φ -> FPφ` swaps to `always(swap φ) -> P(F(swap φ))`.

Note: always is self-dual: φ.always.swap_temporal = φ.swap_temporal.always
because always = Pφ & φ & Fφ, and swap exchanges P and F.

The swapped form states: if swap φ holds at all times, then at all past times s < t,
for all future times u > s, swap φ holds at u.

**Proof Strategy**: The `always` encoding via derived `and` uses nested negations.
We use case analysis on the time `u` relative to `t`:
- If u < t: extract from the "past" component of always
- If u = t: extract from the "present" component of always
- If u > t: extract from the "future" component of always

Each case uses classical logic (`Classical.byContradiction`) to extract truth from the
double-negation encoding of conjunction.
-/
theorem swap_axiom_tl_valid (φ : Formula) :
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))).swap_temporal := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal_all_future, Formula.swap_temporal_all_past,
    Formula.always, Formula.and, Formula.swap_temporal, Formula.neg]
  simp only [truth_at, Truth.past_iff, Truth.future_iff]
  intro h_always s h_s_lt_t u h_s_lt_u
  -- h_always encodes: ¬¬(Gφ' ∧ ¬¬(φ'(t) ∧ Hφ'))
  -- Extract the three components
  have h_future : ∀ r, t < r → truth_at M Omega τ r φ.swap_temporal := by
    by_contra h_not; push_neg at h_not
    obtain ⟨r, htr, h_neg⟩ := h_not
    exact h_always fun h_G => absurd (h_G r htr) h_neg
  have h_present : truth_at M Omega τ t φ.swap_temporal := by
    by_contra h_not
    exact h_always fun _ h_inner => h_inner (fun h_pres _ => h_not h_pres)
  have h_past : ∀ r, r < t → truth_at M Omega τ r φ.swap_temporal := by
    by_contra h_not; push_neg at h_not
    obtain ⟨r, hrt, h_neg⟩ := h_not
    exact h_always fun _ h_inner => h_inner (fun _ h_H => h_neg (h_H r hrt))
  rcases lt_trichotomy u t with h_lt | h_eq | h_gt
  · exact h_past u h_lt
  · exact h_eq ▸ h_present
  · exact h_future u h_gt

/--
Swap of F_until_equiv: `F(φ) → ⊤ U φ` swaps to `P(φ') → ⊤ S φ'`. -/
theorem swap_axiom_F_until_equiv_valid (φ : Formula) :
    is_valid D ((Formula.some_future φ).imp
      (Formula.untl φ (Formula.bot.imp Formula.bot))).swap_temporal := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at, Formula.some_past, Formula.some_future,
    Formula.neg, Formula.imp, Formula.untl, Formula.snce]
  intro ⟨s, hst, h_φs, _⟩
  exact ⟨s, hst, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/--
Swap of P_since_equiv: `P(φ) → ⊤ S φ` swaps to `F(φ') → ⊤ U φ'`. -/
theorem swap_axiom_P_since_equiv_valid (φ : Formula) :
    is_valid D ((Formula.some_past φ).imp
      (Formula.snce φ (Formula.bot.imp Formula.bot))).swap_temporal := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at, Formula.some_past, Formula.some_future,
    Formula.neg, Formula.imp, Formula.untl, Formula.snce]
  intro ⟨s, hts, h_φs, _⟩
  exact ⟨s, hts, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/--
Modal-Future axiom (MF) swaps to a valid formula: `box φ -> box Fφ` swaps to `box(swap φ) -> box P(swap φ)`.

The swapped form states: if swap φ holds at all histories in Omega at time t, then for all histories σ
in Omega at time t, P(swap φ) holds at σ (i.e., swap φ holds at all times s < t in σ).

**Proof Strategy**: Use `time_shift_preserves_truth` to bridge from time t to time s < t.
Uses `ShiftClosed Omega` to ensure shifted histories remain in Omega.
-/
theorem swap_axiom_mf_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.all_future φ))).swap_temporal := by
  intro F M Omega h_sc τ _h_mem t
  simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
  simp only [truth_at, Truth.past_iff]
  intro h_box_swap σ h_σ_mem s h_s_lt_t
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ.swap_temporal).mp h_at_shifted

/-! ## Rule Preservation (Phase 3)

This section proves that each inference rule of the TM proof system preserves swap validity.
If the premises have valid swapped forms, then the conclusion also has a valid swapped form.

These lemmas are used in Phase 4 to prove the main theorem `derivable_implies_swap_valid`
by induction on the derivation structure.
-/

/--
Modus ponens preserves swap validity.

If `(φ -> ψ).swap` and `φ.swap` are both valid, then `ψ.swap` is valid.

**Proof**: Since `(φ -> ψ).swap = φ.swap -> ψ.swap`, this is just standard modus ponens
applied to the swapped formulas.
-/
theorem mp_preserves_swap_valid (φ ψ : Formula)
    (h_imp : is_valid D (φ.imp ψ).swap_temporal)
    (h_phi : is_valid D φ.swap_temporal) :
    is_valid D ψ.swap_temporal := by
  intro F M Omega h_sc τ h_mem t
  simp only [Formula.swap_temporal] at h_imp h_phi ⊢
  exact h_imp F M Omega h_sc τ h_mem t (h_phi F M Omega h_sc τ h_mem t)

/--
Modal K rule preserves swap validity.

If `φ.swap` is valid, then `(box φ).swap = box(φ.swap)` is valid.

**Proof**: If `φ.swap` is true at all tuples, then for any (F, M, Omega, h_sc, τ, h_mem, t),
at all histories σ in Omega at time t, `φ.swap` is true at (M, σ, t). This is exactly `box(φ.swap)`.
-/
theorem modal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_temporal) :
    is_valid D (Formula.box φ).swap_temporal := by
  intro F M Omega h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro σ h_σ_mem
  exact h F M Omega h_sc σ h_σ_mem t

/--
Temporal K rule preserves swap validity.

If `φ.swap` is valid, then `(Fφ).swap = P(φ.swap)` is valid.

**Proof**: If `φ.swap` is true at all tuples, then for any (F, M, Omega, h_sc, τ, h_mem, t),
at all times s ≤ t, `φ.swap` is true at (M, τ, s). This is exactly `P(φ.swap)`.
-/
theorem temporal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_temporal) :
    is_valid D (Formula.all_future φ).swap_temporal := by
  intro F M Omega h_sc τ h_mem t
  simp only [Formula.swap_temporal_all_future]
  simp only [truth_at, Truth.past_iff]
  intro s _h_s_le_t
  exact h F M Omega h_sc τ h_mem s

/--
Weakening preserves swap validity (trivial for empty context).

For the temporal duality rule, we only consider derivations from empty context.
Weakening from [] to [] is trivial.
-/
theorem weakening_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_temporal) :
    is_valid D φ.swap_temporal := h

/-- Helper: extract conjunction from double-negation-of-implication encoding. -/
private theorem and_extract {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/-! ## Axiom Swap Validity Master Theorem (Phase 4 - Partial)

This section adds the master theorem that combines all individual axiom swap validity lemmas.

**Status**: COMPLETE - all axioms proven.

The proof handles each axiom case:
- **prop_k, prop_s**: Propositional tautologies, swap distributes over implication
- **modal_t, modal_4, modal_b**: Self-dual modal axioms (swap preserves schema form)
- **temp_4, temp_a**: Temporal axioms with straightforward swap semantics
- **temp_l (TL)**: Uses case analysis and classical logic for `always` encoding
- **modal_future (MF)**: Uses `time_shift_preserves_truth` to bridge times (TF now derived)
-/

theorem axiom_swap_valid (φ : Formula) (h : Axiom φ) [DenselyOrdered D] [Nontrivial D]
    (h_fc : h.minFrameClass ≤ FrameClass.Dense) : is_valid D φ.swap_temporal := by
  cases h with
  | prop_k ψ χ ρ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_a _
    exact h_a
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.diamond, Formula.neg]
    simp only [truth_at]
    intro h_diamond_box σ h_σ_mem
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ h_ρ_mem h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ h_σ_mem
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_peirce
    by_cases h : truth_at M Omega τ t ψ.swap_temporal
    · exact h
    · have h_imp : truth_at M Omega τ t (ψ.swap_temporal.imp χ.swap_temporal) := by
        unfold truth_at
        intro h_psi
        exfalso
        exact h h_psi
      exact h_peirce h_imp
  | modal_k_dist ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_box_imp h_box_psi σ h_σ_mem
    exact h_box_imp σ h_σ_mem (h_box_psi σ h_σ_mem)
  -- NOTE: temp_k_dist and temp_4 removed as axiom constructors (Task 116)
  | serial_future =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | serial_past =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Swap of left_mono_until_G: H(φ'→χ') → snce(φ',ψ') → snce(χ',ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | left_mono_since_H φ χ ψ =>
    -- Swap of left_mono_since_H: G(φ'→χ') → untl(φ',ψ') → untl(χ',ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | right_mono_until φ ψ χ =>
    -- swap: G(φ'→χ') → (φ' S ψ') → (χ' S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    -- swap: H(φ'→χ') → (φ' U ψ') → (χ' U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | connect_future φ =>
    -- Swap of connect_future: φ → G(P(φ)) swaps to swap(φ) → H(F(swap(φ)))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal_some_past,
      Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | connect_past φ =>
    -- Swap of connect_past: φ → H(F(φ)) swaps to swap(φ) → G(P(swap(φ)))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal_some_future,
      Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Swap of enrichment_until: p ∧ snce(φ', ψ') → snce(φ', ψ' ∧ untl(φ', p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p.swap_temporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_since : ∃ s, s < t ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ.swap_temporal := by
      by_contra h_neg; exact h_conj (fun _ h_s => h_neg h_s)
    obtain ⟨s, hst, h_ψs, h_guard⟩ := h_since
    refine ⟨s, hst, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hst, h_pt, fun r hsr hrt => h_guard r hsr hrt⟩
  | enrichment_since φ ψ p =>
    -- Swap of enrichment_since: p ∧ untl(φ', ψ') → untl(φ', ψ' ∧ snce(φ', p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p.swap_temporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_until : ∃ s, t < s ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ.swap_temporal := by
      by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
    obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
    refine ⟨s, hts, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩
  | self_accum_until φ ψ =>
    -- Swap: (φ' S ψ') → ((φ' ∧ (φ' S ψ')) S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩
  | self_accum_since φ ψ =>
    -- Swap: (φ' U ψ') → ((φ' ∧ (φ' U ψ')) U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs => h_guard q (lt_trans htr hrq) hqs⟩
  | absorb_until φ ψ =>
    -- Swap: (φ' S (φ' ∧ (φ' S ψ'))) → (φ' S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
    have h_φs₁_and_since : truth_at M Omega τ s₁ φ.swap_temporal ∧
        (∃ s₂, s₂ < s₁ ∧ truth_at M Omega τ s₂ ψ.swap_temporal ∧
          ∀ q, s₂ < q → q < s₁ → truth_at M Omega τ q φ.swap_temporal) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_since => h_neg h_since)
    obtain ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩ := h_φs₁_and_since
    refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₂ q hs₂q h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₁ q h_gt hqt
  | absorb_since φ ψ =>
    -- Swap: (φ' U (φ' ∧ (φ' U ψ'))) → (φ' U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
    have h_φs₁_and_until : truth_at M Omega τ s₁ φ.swap_temporal ∧
        (∃ s₂, s₁ < s₂ ∧ truth_at M Omega τ s₂ ψ.swap_temporal ∧
          ∀ q, s₁ < q → q < s₂ → truth_at M Omega τ q φ.swap_temporal) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_until => h_neg h_until)
    obtain ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩ := h_φs₁_and_until
    refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₁ q htq h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₂ q h_gt hqs₂
  | linear_until φ ψ χ θ =>
    -- Swap: Since-based linearity with swapped subformulas
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, s < t ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ.swap_temporal) ∧
      (∃ s, s < t ∧ truth_at M Omega τ s θ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r χ.swap_temporal) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂ < t: third disjunct (φ∧χ) S (φ∧θ) with witness s₂
      intro _
      refine ⟨s₂, hs₂t, ?_, fun r hs₂r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ h_lt hs₂t) h_θs₂
      · exact h_imp (h_guard₁ r (lt_trans h_lt hs₂r) hrt) (h_guard₂ r hs₂r hrt)
    · -- s₁ = s₂: first disjunct (φ∧χ) S (ψ∧θ) with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (h_eq ▸ hs₁r) hrt)
    · -- s₂ < s₁ < t: second disjunct (φ∧χ) S (ψ∧χ) with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ h_gt hs₁t)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (lt_trans h_gt hs₁r) hrt)
  | linear_since φ ψ χ θ =>
    -- Swap: Until-based linearity with swapped subformulas
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, t < s ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ.swap_temporal) ∧
      (∃ s, t < s ∧ truth_at M Omega τ s θ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r χ.swap_temporal) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: second disjunct (φ∧χ) U (ψ∧χ) with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ hts₁ h_lt)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (lt_trans hrs h_lt))
    · -- s₁ = s₂: first disjunct (φ∧χ) U (ψ∧θ) with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (h_eq ▸ hrs))
    · -- s₂ < s₁: third disjunct (φ∧χ) U (φ∧θ) with witness s₂
      intro _
      refine ⟨s₂, hts₂, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ hts₂ h_gt) h_θs₂
      · exact h_imp (h_guard₁ r htr (lt_trans hrs h_gt)) (h_guard₂ r htr hrs)
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted, task 113)
  | until_F φ ψ =>
    -- Swap of until_F: (ψ U φ) → F(ψ) swaps to (ψ' S φ') → P(ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal]
    simp only [truth_at, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _h_guard⟩
    exact ⟨s, hst, h_ψs⟩
  | since_P φ ψ =>
    -- Swap of since_P: (ψ S φ) → P(ψ) swaps to (ψ' U φ') → F(ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal]
    simp only [truth_at, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _h_guard⟩
    exact ⟨s, hts, h_ψs⟩
  | temp_linearity φ ψ =>
    -- swap of future linearity is past linearity with swapped subformulas
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal_some_past,
      Formula.swap_temporal, Formula.and, Formula.or, Formula.neg]
    simp only [truth_at, Truth.some_past_iff, Truth.some_future_iff]
    intro h_conj
    have ⟨s1, hs1t, h_φs1⟩ : ∃ s, s < t ∧ truth_at M Omega τ s φ.swap_temporal := by
      by_contra h_no; push_neg at h_no
      exact h_conj (fun ⟨s, hst, h_phi⟩ _ => absurd h_phi (h_no s hst))
    have ⟨s2, hs2t, h_ψs2⟩ : ∃ s, s < t ∧ truth_at M Omega τ s ψ.swap_temporal := by
      by_contra h_no; push_neg at h_no
      exact h_conj (fun _ ⟨s, hst, h_psi⟩ => absurd h_psi (h_no s hst))
    rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
    · -- s1 < s2: take r = s2, giving P(P(φ') ∧ ψ')
      intro _; intro _
      exact ⟨s2, hs2t, fun h_imp => h_imp ⟨s1, h_lt, h_φs1⟩ h_ψs2⟩
    · -- s1 = s2: giving P(φ' ∧ ψ')
      subst h_eq
      intro h_neg_first; exfalso; apply h_neg_first
      exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 h_ψs2⟩
    · -- s2 < s1: take r = s1, giving P(φ' ∧ P(ψ'))
      intro _; intro h_neg_second; exfalso; apply h_neg_second
      exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 ⟨s2, h_gt, h_ψs2⟩⟩
  | temp_linearity_past φ ψ =>
    -- swap of past linearity is future linearity with swapped subformulas
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal_some_past,
      Formula.swap_temporal, Formula.and, Formula.or, Formula.neg]
    simp only [truth_at, Truth.some_past_iff, Truth.some_future_iff]
    intro h_conj
    have ⟨s1, hts1, h_φs1⟩ : ∃ s, t < s ∧ truth_at M Omega τ s φ.swap_temporal := by
      by_contra h_no; push_neg at h_no
      exact h_conj (fun ⟨s, hts, h_phi⟩ _ => absurd h_phi (h_no s hts))
    have ⟨s2, hts2, h_ψs2⟩ : ∃ s, t < s ∧ truth_at M Omega τ s ψ.swap_temporal := by
      by_contra h_no; push_neg at h_no
      exact h_conj (fun _ ⟨s, hts, h_psi⟩ => absurd h_psi (h_no s hts))
    rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
    · -- s1 < s2: take r = s1, giving F(φ' ∧ F(ψ'))
      intro _; intro h_neg_second; exfalso; apply h_neg_second
      exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 ⟨s2, h_lt, h_ψs2⟩⟩
    · -- s1 = s2: giving F(φ' ∧ ψ')
      subst h_eq
      intro h_neg_first; exfalso; apply h_neg_first
      exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 h_ψs2⟩
    · -- s2 < s1: take r = s2, giving F(F(φ') ∧ ψ')
      intro _; intro _
      exact ⟨s2, hts2, fun h_imp => h_imp ⟨s1, h_gt, h_φs1⟩ h_ψs2⟩
  | F_until_equiv φ => exact swap_axiom_F_until_equiv_valid φ
  | P_since_equiv φ => exact swap_axiom_P_since_equiv_valid φ
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted, task 113)
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | discrete_symm_fwd =>
    -- swap(U(T,bot) -> S(T,bot)) = S(T,bot) -> U(T,bot)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun h => h, fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (t - r)) h1 h2
  | discrete_symm_bwd =>
    -- swap(S(T,bot) -> U(T,bot)) = U(T,bot) -> S(T,bot)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun h => h, fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact h_guard (c + (s - t)) h1 h2
  | discrete_propagate_fwd =>
    -- swap(U(T,bot) -> G(U(T,bot))) = S(T,bot) -> H(S(T,bot))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _hut
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs => rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_propagate_bwd =>
    -- swap(U(T,bot) -> H(U(T,bot))) = S(T,bot) -> G(S(T,bot))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _htu
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs => rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_box_necessity =>
    -- swap(U(T,bot) -> □(U(T,bot))) = S(T,bot) -> □(S(T,bot))
    -- S(T,bot) depends only on D's order structure, not the history
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ σ _h_σ_mem
    exact ⟨r, hrt, fun h => h, h_guard⟩
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | density _ =>
    -- density axiom: GGφ → Gφ, swap is HHφ → Hφ (past density)
    -- HHφ = ¬P(¬Hφ) = ¬P(¬(¬P(¬φ))) and Hφ = ¬P(¬φ)
    -- We prove: ¬P(¬φ ∧ guard) given ¬P(¬(¬P(¬φ ∧ guard)) ∧ guard)
    -- Contrapositive: if ∃ s < t with ¬φ(s), find r via density with s < r < t
    -- Then ∃ r < t with ¬Hφ(r) (witnessed by s < r), giving P(¬Hφ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.all_future, Formula.some_future,
      Formula.neg, truth_at]
    intro h_HH ⟨s, hst, h_neg_phi_s, h_guard_s⟩
    apply h_HH
    obtain ⟨r, hrs, hrt⟩ := exists_between hst
    refine ⟨r, hrt, ?_, ?_⟩
    · -- Need: ¬¬P(¬φ) at r, i.e., ¬Hφ at r
      -- Witness: s < r with ¬φ(s)
      intro h_Hphi_r
      exact h_Hphi_r ⟨s, hrs, h_neg_phi_s, fun q hq1 hq2 => h_guard_s q hq1 (lt_trans hq2 hrt)⟩
    · -- Guard: all between r and t satisfy ⊤
      intro q hq1 hq2
      exact h_guard_s q (lt_trans hrs hq1) hq2
/-! ## Axiom Validity (Local)

These lemmas prove validity of each axiom using the local `is_valid` definition.
This is needed to prove the combined soundness+swap theorem without importing Soundness.lean.
-/

/-- Propositional K axiom is locally valid. -/
private theorem axiom_prop_k_valid (φ ψ χ : Formula) :
    is_valid D ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/-- Propositional S axiom is locally valid. -/
private theorem axiom_prop_s_valid (φ ψ : Formula) :
    is_valid D (φ.imp (ψ.imp φ)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi _
  exact h_phi

/-- Modal T axiom is locally valid. -/
private theorem axiom_modal_t_valid (φ : Formula) :
    is_valid D (φ.box.imp φ) := by
  intro F M Omega _h_sc τ h_mem t
  simp only [truth_at]
  intro h_box
  exact h_box τ h_mem

/-- Modal 4 axiom is locally valid. -/
private theorem axiom_modal_4_valid (φ : Formula) :
    is_valid D ((φ.box).imp (φ.box.box)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box σ _h_σ_mem ρ h_ρ_mem
  exact h_box ρ h_ρ_mem

/-- Modal B axiom is locally valid. -/
private theorem axiom_modal_b_valid (φ : Formula) :
    is_valid D (φ.imp (φ.diamond.box)) := by
  intro F M Omega _h_sc τ h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at]
  intro h_phi σ _h_σ_mem h_box_neg
  exact h_box_neg τ h_mem h_phi

/-- Modal 5 collapse axiom is locally valid. -/
private theorem axiom_modal_5_collapse_valid (φ : Formula) :
    is_valid D (φ.box.diamond.imp φ.box) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at]
  intro h_diamond_box ρ h_ρ_mem
  by_contra h_not_phi
  apply h_diamond_box
  intro σ h_σ_mem h_box_at_sigma
  exact h_not_phi (h_box_at_sigma ρ h_ρ_mem)

/-- Ex falso axiom is locally valid. -/
private theorem axiom_ex_falso_valid (φ : Formula) :
    is_valid D (Formula.bot.imp φ) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_bot
  exfalso
  exact h_bot

/-- Peirce's law is locally valid. -/
private theorem axiom_peirce_valid (φ ψ : Formula) :
    is_valid D (((φ.imp ψ).imp φ).imp φ) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_peirce
  by_cases h : truth_at M Omega τ t φ
  · exact h
  · have h_imp : truth_at M Omega τ t (φ.imp ψ) := by
      simp only [truth_at]
      intro h_phi
      exfalso
      exact h h_phi
    exact h_peirce h_imp

/-- Modal K distribution axiom is locally valid. -/
private theorem axiom_modal_k_dist_valid (φ ψ : Formula) :
    is_valid D ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_imp h_box_phi σ h_σ_mem
  exact h_box_imp σ h_σ_mem (h_box_phi σ h_σ_mem)

/-- Temporal K distribution axiom is locally valid. -/
private theorem axiom_temp_k_dist_valid (φ ψ : Formula) :
    is_valid D ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Truth.future_iff]
  intro h_future_imp h_future_phi s hts
  exact h_future_imp s hts (h_future_phi s hts)

/-- Temporal 4 axiom is locally valid (strict semantics). -/
private theorem axiom_temp_4_valid (φ : Formula) :
    is_valid D ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Truth.future_iff]
  intro h_future s hts r hsr
  exact h_future r (lt_trans hts hsr)

/-- Helper for temporal A axiom (strict semantics). -/
private theorem axiom_temp_a_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.some_past)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Truth.future_iff, Truth.some_past_iff]
  intro h_phi s hts
  exact ⟨t, hts, h_phi⟩

/-- Helper lemma for extracting conjunction from negated implication encoding. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/-- Temporal L axiom is locally valid (strict semantics). -/
private theorem axiom_temp_l_valid (φ : Formula) :
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.always, Formula.and, Formula.neg, truth_at, Truth.future_iff, Truth.past_iff]
  intro h_always s hts u hus
  -- h_always encodes: ¬¬(Hφ ∧ ¬¬(φ(t) ∧ Gφ))
  -- Extract past component
  have h_past : ∀ r, r < t → truth_at M Omega τ r φ := by
    by_contra h_not; push_neg at h_not
    obtain ⟨r, hrt, h_neg⟩ := h_not
    exact h_always fun h_H => absurd (h_H r hrt) h_neg
  have h_present : truth_at M Omega τ t φ := by
    by_contra h_not
    exact h_always fun _ h_inner => h_inner (fun h_pres _ => h_not h_pres)
  have h_future : ∀ r, t < r → truth_at M Omega τ r φ := by
    by_contra h_not; push_neg at h_not
    obtain ⟨r, htr, h_neg⟩ := h_not
    exact h_always fun _ h_inner => h_inner (fun _ h_G => h_neg (h_G r htr))
  rcases lt_trichotomy u t with h_lt | h_eq | h_gt
  · exact h_past u h_lt
  · exact h_eq ▸ h_present
  · exact h_future u h_gt

/-- Modal-Future axiom is locally valid. -/
private theorem axiom_modal_future_valid (φ : Formula) :
    is_valid D ((φ.box).imp ((φ.all_future).box)) := by
  intro F M Omega h_sc τ _h_mem t
  simp only [truth_at, Truth.future_iff]
  intro h_box_phi σ h_σ_mem s hts
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ).mp h_phi_at_shifted

-- Note: axiom_temp_future_valid removed -- TF is now derived from MF + T + Modal 4.

/-- Temporal linearity axiom is locally valid (strict semantics).

`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`

The proof uses linearity of D (the `lt_trichotomy` from `LinearOrder`). Given witnesses
s1 > t for φ and s2 > t for ψ, either s1 < s2 (take r = s1, giving F(φ ∧ F(ψ))),
s1 = s2 (giving F(φ ∧ ψ)), or s2 < s1 (take r = s2, giving F(F(φ) ∧ ψ)).
-/
private theorem axiom_temp_linearity_valid (φ ψ : Formula) :
    is_valid D (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
      (Formula.or (Formula.some_future (Formula.and φ ψ))
        (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
          (Formula.some_future (Formula.and (Formula.some_future φ) ψ))))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, truth_at,
    Truth.some_future_iff, Truth.some_past_iff]
  intro h_conj
  -- Extract Fφ witness
  have ⟨s1, hts1, h_φs1⟩ : ∃ s, t < s ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no
    exact h_conj (fun ⟨s, hts, h_phi⟩ _ => absurd h_phi (h_no s hts))
  -- Extract Fψ witness
  have ⟨s2, hts2, h_ψs2⟩ : ∃ s, t < s ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_conj (fun _ ⟨s, hts, h_psi⟩ => absurd h_psi (h_no s hts))
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: take r = s1, giving F(φ ∧ F(ψ))
    intro _; intro h_neg_second; exfalso; apply h_neg_second
    exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 ⟨s2, h_lt, h_ψs2⟩⟩
  · -- s1 = s2: giving F(φ ∧ ψ)
    subst h_eq
    intro h_neg_first; exfalso; apply h_neg_first
    exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 h_ψs2⟩
  · -- s2 < s1: take r = s2, giving F(F(φ) ∧ ψ)
    intro _; intro _
    exact ⟨s2, hts2, fun h_imp => h_imp ⟨s1, h_gt, h_φs1⟩ h_ψs2⟩

/-- Past temporal linearity axiom validity (BX11'):
`P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)` is locally valid.
Mirror of `axiom_temp_linearity_valid` for the past direction. -/
private theorem axiom_temp_linearity_past_valid (φ ψ : Formula) :
    is_valid D (Formula.and (Formula.some_past φ) (Formula.some_past ψ) |>.imp
      (Formula.or (Formula.some_past (Formula.and φ ψ))
        (Formula.or (Formula.some_past (Formula.and φ (Formula.some_past ψ)))
          (Formula.some_past (Formula.and (Formula.some_past φ) ψ))))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, truth_at,
    Truth.some_future_iff, Truth.some_past_iff]
  intro h_conj
  -- Extract Pφ witness
  have ⟨s1, hs1t, h_φs1⟩ : ∃ s, s < t ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no
    exact h_conj (fun ⟨s, hst, h_phi⟩ _ => absurd h_phi (h_no s hst))
  -- Extract Pψ witness
  have ⟨s2, hs2t, h_ψs2⟩ : ∃ s, s < t ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_conj (fun _ ⟨s, hst, h_psi⟩ => absurd h_psi (h_no s hst))
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: take r = s2, giving P(P(φ) ∧ ψ)
    intro _; intro _
    exact ⟨s2, hs2t, fun h_imp => h_imp ⟨s1, h_lt, h_φs1⟩ h_ψs2⟩
  · -- s1 = s2: giving P(φ ∧ ψ)
    subst h_eq
    intro h_neg_first; exfalso; apply h_neg_first
    exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 h_ψs2⟩
  · -- s1 > s2: take r = s1, giving P(φ ∧ P(ψ))
    intro _; intro h_neg_second; exfalso; apply h_neg_second
    exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 ⟨s2, h_gt, h_ψs2⟩⟩

/-- F-Until equivalence axiom validity (BX12):
`F(φ) → (⊤ U φ)` is locally valid.
If there exists s ≥ t with φ(s), then ⊤ U φ holds at t (take witness s, guard ⊤ = ¬⊥ is trivially satisfied). -/
private theorem axiom_F_until_equiv_valid (φ : Formula) :
    is_valid D ((Formula.some_future φ).imp
      (Formula.untl φ (Formula.bot.imp Formula.bot))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Truth.some_future_iff]
  intro ⟨s, hts, h_φs⟩
  exact ⟨s, hts, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/-- P-Since equivalence axiom validity (BX12'):
`P(φ) → (⊤ S φ)` is locally valid. Past dual of F-Until equivalence. -/
private theorem axiom_P_since_equiv_valid (φ : Formula) :
    is_valid D ((Formula.some_past φ).imp
      (Formula.snce φ (Formula.bot.imp Formula.bot))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Truth.some_past_iff]
  intro ⟨s, hst, h_φs⟩
  exact ⟨s, hst, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/-- Density axiom (DN) is locally valid on dense orders: `GGφ → Gφ` (Sahlqvist form).
Under reflexive semantics, trivially valid via r = t. -/
private theorem axiom_density_valid [DenselyOrdered D] (φ : Formula) :
    is_valid D (φ.all_future.all_future.imp φ.all_future) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Truth.future_iff]
  intro h_GG s hts
  -- Under strict semantics, need r with t < r < s (density), then h_GG r _ s _
  obtain ⟨r, htr, hrs⟩ := exists_between hts
  exact h_GG r htr s hrs

/-- All dense-compatible axioms are locally valid on dense orders. -/
private theorem axiom_locally_valid [DenselyOrdered D] [Nontrivial D] {φ : Formula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ FrameClass.Dense) : is_valid D φ := by
  cases h with
  | prop_k φ ψ χ => exact axiom_prop_k_valid φ ψ χ
  | prop_s φ ψ => exact axiom_prop_s_valid φ ψ
  | modal_t ψ => exact axiom_modal_t_valid ψ
  | modal_4 ψ => exact axiom_modal_4_valid ψ
  | modal_b ψ => exact axiom_modal_b_valid ψ
  | modal_5_collapse ψ => exact axiom_modal_5_collapse_valid ψ
  | ex_falso ψ => exact axiom_ex_falso_valid ψ
  | peirce φ ψ => exact axiom_peirce_valid φ ψ
  | modal_k_dist φ ψ => exact axiom_modal_k_dist_valid φ ψ
  | serial_future =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.neg, truth_at, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | serial_past =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.neg, truth_at, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Direct: G(φ→χ) → untl(φ,ψ) → untl(χ,ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | left_mono_since_H φ χ ψ =>
    -- Direct: H(φ→χ) → snce(φ,ψ) → snce(χ,ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | right_mono_until φ ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | connect_future φ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | connect_past φ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Direct: p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_until : ∃ s, t < s ∧ truth_at M Omega τ s ψ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ := by
      by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
    obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
    refine ⟨s, hts, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩
  | enrichment_since φ ψ p =>
    -- Direct: p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_since : ∃ s, s < t ∧ truth_at M Omega τ s ψ ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ := by
      by_contra h_neg; exact h_conj (fun _ h_s => h_neg h_s)
    obtain ⟨s, hst, h_ψs, h_guard⟩ := h_since
    refine ⟨s, hst, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hst, h_pt, fun r hsr hrt => h_guard r hsr hrt⟩
  | self_accum_until φ ψ =>
    -- Direct: (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs => h_guard q (lt_trans htr hrq) hqs⟩
  | self_accum_since φ ψ =>
    -- Direct: (φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩
  | absorb_until φ ψ =>
    -- Direct: (φ U (φ ∧ (φ U ψ))) → (φ U ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
    have h_φs₁_and_until : truth_at M Omega τ s₁ φ ∧
        (∃ s₂, s₁ < s₂ ∧ truth_at M Omega τ s₂ ψ ∧
          ∀ q, s₁ < q → q < s₂ → truth_at M Omega τ q φ) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_until => h_neg h_until)
    obtain ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩ := h_φs₁_and_until
    refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₁ q htq h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₂ q h_gt hqs₂
  | absorb_since φ ψ =>
    -- Direct: (φ S (φ ∧ (φ S ψ))) → (φ S ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
    have h_φs₁_and_since : truth_at M Omega τ s₁ φ ∧
        (∃ s₂, s₂ < s₁ ∧ truth_at M Omega τ s₂ ψ ∧
          ∀ q, s₂ < q → q < s₁ → truth_at M Omega τ q φ) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_since => h_neg h_since)
    obtain ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩ := h_φs₁_and_since
    refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₂ q hs₂q h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₁ q h_gt hqt
  | linear_until φ ψ χ θ =>
    -- Direct: Until-based linearity
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, t < s ∧ truth_at M Omega τ s ψ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ) ∧
      (∃ s, t < s ∧ truth_at M Omega τ s θ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r χ) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: second disjunct with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ hts₁ h_lt)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (lt_trans hrs h_lt))
    · -- s₁ = s₂: first disjunct with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (h_eq ▸ hrs))
    · -- s₂ < s₁: third disjunct with witness s₂
      intro _
      refine ⟨s₂, hts₂, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ hts₂ h_gt) h_θs₂
      · exact h_imp (h_guard₁ r htr (lt_trans hrs h_gt)) (h_guard₂ r htr hrs)
  | linear_since φ ψ χ θ =>
    -- Direct: Since-based linearity
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, s < t ∧ truth_at M Omega τ s ψ ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ) ∧
      (∃ s, s < t ∧ truth_at M Omega τ s θ ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r χ) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: third disjunct with witness s₂
      intro _
      refine ⟨s₂, hs₂t, ?_, fun r hs₂r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ h_lt hs₂t) h_θs₂
      · exact h_imp (h_guard₁ r (lt_trans h_lt hs₂r) hrt) (h_guard₂ r hs₂r hrt)
    · -- s₁ = s₂: first disjunct with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (h_eq ▸ hs₁r) hrt)
    · -- s₁ > s₂: second disjunct with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ h_gt hs₁t)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (lt_trans h_gt hs₁r) hrt)
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted, task 113)
  | until_F φ ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _⟩
    exact ⟨s, hts, h_ψs⟩
  | since_P φ ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _⟩
    exact ⟨s, hst, h_ψs⟩
  | temp_linearity φ ψ => exact axiom_temp_linearity_valid φ ψ
  | temp_linearity_past φ ψ => exact axiom_temp_linearity_past_valid φ ψ
  | F_until_equiv φ => exact axiom_F_until_equiv_valid φ
  | P_since_equiv φ => exact axiom_P_since_equiv_valid φ
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted, task 113)
  | modal_future ψ => exact axiom_modal_future_valid ψ

  | discrete_symm_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun h => h, fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact h_guard (c + (s - t)) h1 h2
  | discrete_symm_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun h => h, fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (t - r)) h1 h2
  | discrete_propagate_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro ⟨s, hts, _h_top_s, h_guard⟩ u _htu
    refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
    have h1 : t < c - (u - t) := by
      conv_lhs => rw [(sub_sub_cancel u t).symm]
      exact sub_lt_sub_right huc _
    have h2 : c - (u - t) < s := by
      conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (u - t)) h1 h2
  | discrete_propagate_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro ⟨s, hts, _h_top_s, h_guard⟩ u _hut
    refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
    have h1 : t < c - (u - t) := by
      conv_lhs => rw [(sub_sub_cancel u t).symm]
      exact sub_lt_sub_right huc _
    have h2 : c - (u - t) < s := by
      conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (u - t)) h1 h2
  | discrete_box_necessity =>
    -- U(T,bot) -> □(U(T,bot)): discreteness depends only on D, not the history
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩ σ _h_σ_mem
    exact ⟨s, hts, fun h => h, h_guard⟩
  | density φ =>
    -- density axiom: GGφ → Gφ
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]
    intro h_GG s hts
    obtain ⟨r, htr, hrs⟩ := exists_between hts
    exact h_GG r htr s hrs
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
/-! ## Rule Preservation for Local Validity

Helper lemmas proving that inference rules preserve local validity.
These are needed for the combined soundness theorem.
-/

/-- Modus ponens preserves local validity.
If φ → ψ and φ are both locally valid, then ψ is locally valid. -/
private theorem mp_preserves_valid {φ ψ : Formula}
    (h_imp : is_valid D (φ.imp ψ))
    (h_phi : is_valid D φ) :
    is_valid D ψ := by
  intro F M Omega h_sc τ h_mem t
  exact h_imp F M Omega h_sc τ h_mem t (h_phi F M Omega h_sc τ h_mem t)

/-- Modal necessitation preserves local validity.
If φ is locally valid, then □φ is locally valid. -/
private theorem necessitation_preserves_local_valid {φ : Formula}
    (h : is_valid D φ) :
    is_valid D (Formula.box φ) := by
  intro F M Omega h_sc τ _h_mem t
  simp only [truth_at]
  intro σ h_σ_mem
  exact h F M Omega h_sc σ h_σ_mem t

/-- Temporal necessitation preserves local validity.
If φ is locally valid, then Gφ is locally valid. -/
private theorem temporal_necessitation_preserves_local_valid {φ : Formula}
    (h : is_valid D φ) :
    is_valid D (Formula.all_future φ) := by
  intro F M Omega h_sc τ h_mem t
  simp only [truth_at, Truth.future_iff]
  intro s _hts
  exact h F M Omega h_sc τ h_mem s

/-! ## Combined Soundness and Swap-Soundness

The main theorem proving both local validity AND swap validity simultaneously
for derivable formulas. Uses well-founded induction on derivation height to
resolve the mutual dependency between validity and swap-validity in the
temporal_duality case.
-/

/--
Combined soundness: derivability implies both validity and swap-validity.

For any formula φ derivable from the empty context with a dense-compatible
derivation, both φ and φ.swap are valid.

**Key Insight**: The temporal_duality case has the following structure:
- Derivation: `temporal_duality φ d` where d proves φ
- Goal for validity: φ.swap is valid (since the formula index is φ.swap)
- Goal for swap-validity: (φ.swap).swap = φ is valid

The induction hypothesis `ih` provides both `is_valid D φ` and `is_valid D φ.swap`
for the subderivation. We use:
- `ih.2` (swap validity of φ) for the validity goal
- `ih.1` (validity of φ) for the swap-validity goal, via the involution lemma

This resolves the mutual recursion by proving both goals in a single pass.
-/
theorem derivable_valid_and_swap_valid [DenselyOrdered D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Dense [] φ) :
    is_valid D φ ∧ is_valid D φ.swap_temporal := by
  match d with
  | .axiom _ _ h_ax h_fc => exact ⟨axiom_locally_valid h_ax h_fc, axiom_swap_valid _ h_ax h_fc⟩
  | .assumption _ _ h_mem => exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ ψ' _ d1 d2 =>
    obtain ⟨h1_valid, h1_swap⟩ := derivable_valid_and_swap_valid d1
    obtain ⟨h2_valid, h2_swap⟩ := derivable_valid_and_swap_valid d2
    exact ⟨mp_preserves_valid h1_valid h2_valid, mp_preserves_swap_valid ψ' _ h1_swap h2_swap⟩
  | .necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid d'
    exact ⟨necessitation_preserves_local_valid h_valid, modal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid d'
    exact ⟨temporal_necessitation_preserves_local_valid h_valid, temporal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_duality ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid d'
    constructor
    · exact h_swap
    · simp only [Formula.swap_temporal_involution]; exact h_valid
  | .weakening Γ' _ _ d' h_sub =>
    have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Γ' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_valid (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/-! ## Extracted Theorems

Individual theorems extracted from the combined result for convenience.
-/

/-- Derivability implies local validity (extracted from combined theorem). -/
theorem derivable_locally_valid [DenselyOrdered D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Dense [] φ) :
    is_valid D φ :=
  (derivable_valid_and_swap_valid d).1

/-- Derivability implies swap validity (extracted from combined theorem).
This is the theorem needed for the temporal_duality case in soundness_dense. -/
theorem derivable_implies_swap_valid [DenselyOrdered D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Dense [] φ) :
    is_valid D φ.swap_temporal :=
  (derivable_valid_and_swap_valid d).2

/-! ## General (Frame-Class-Free) Versions

All base axioms (those with `minFrameClass = .Base`) are valid on any linear order,
without requiring `[DenselyOrdered D]` or `[Nontrivial D]`. These general versions
remove frame constraints from the swap/locally-valid lemmas, enabling soundness proofs
for the base frame class without unnecessary hypotheses.

This resolves the 3 `temporal_duality` sorries in Soundness.lean:
- `soundness` (general, line ~877)
- `soundness_discrete_valid` (line ~1094)
- `soundness_discrete` (line ~1151)
-/

/-- All base axiom swaps are valid without DenselyOrdered constraints.
Base axioms (minFrameClass = .Base) don't need density or discreteness. -/
theorem axiom_swap_valid_general (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Base)
    [Nontrivial D] : is_valid D φ.swap_temporal := by
  cases h with
  | prop_k ψ χ ρ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_a _
    exact h_a
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.diamond, Formula.neg]
    simp only [truth_at]
    intro h_diamond_box σ h_σ_mem
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ h_ρ_mem h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ h_σ_mem
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_peirce
    by_cases h : truth_at M Omega τ t ψ.swap_temporal
    · exact h
    · have h_imp : truth_at M Omega τ t (ψ.swap_temporal.imp χ.swap_temporal) := by
        unfold truth_at
        intro h_psi
        exfalso
        exact h h_psi
      exact h_peirce h_imp
  | modal_k_dist ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_box_imp h_box_psi σ h_σ_mem
    exact h_box_imp σ h_σ_mem (h_box_psi σ h_σ_mem)
  | serial_future =>
    -- swap of serial_future (⊤ → F⊤) is (⊤ → P⊤), need exists_lt
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | serial_past =>
    -- swap of serial_past (⊤ → P⊤) is (⊤ → F⊤), need exists_gt
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Swap of left_mono_until_G: H(φ'→χ') → snce(φ',ψ') → snce(χ',ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | left_mono_since_H φ χ ψ =>
    -- Swap of left_mono_since_H: G(φ'→χ') → untl(φ',ψ') → untl(χ',ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | right_mono_until φ ψ χ =>
    -- swap: H(φ'→χ') → (φ' S ψ') → (χ' S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    -- swap: G(φ'→χ') → (φ' U ψ') → (χ' U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | connect_future φ =>
    -- connect_future: φ → G(P(φ)), swap: swap(φ) → H(F(swap(φ)))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal_all_future,
      Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | connect_past φ =>
    -- connect_past: φ → H(F(φ)), swap: swap(φ) → G(P(swap(φ)))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal_all_past,
      Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Swap of enrichment_until: p ∧ snce(φ', ψ') → snce(φ', ψ' ∧ untl(φ', p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p.swap_temporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_since : ∃ s, s < t ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ.swap_temporal := by
      by_contra h_neg; exact h_conj (fun _ h_s => h_neg h_s)
    obtain ⟨s, hst, h_ψs, h_guard⟩ := h_since
    refine ⟨s, hst, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hst, h_pt, fun r hsr hrt => h_guard r hsr hrt⟩
  | enrichment_since φ ψ p =>
    -- Swap of enrichment_since: p ∧ untl(φ', ψ') → untl(φ', ψ' ∧ snce(φ', p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p.swap_temporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_until : ∃ s, t < s ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ.swap_temporal := by
      by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
    obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
    refine ⟨s, hts, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩
  | self_accum_until φ ψ =>
    -- Swap: (φ' S ψ') → ((φ' ∧ (φ' S ψ')) S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩
  | self_accum_since φ ψ =>
    -- Swap: (φ' U ψ') → ((φ' ∧ (φ' U ψ')) U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs => h_guard q (lt_trans htr hrq) hqs⟩
  | absorb_until φ ψ =>
    -- Swap: (φ' S (φ' ∧ (φ' S ψ'))) → (φ' S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
    have h_φs₁_and_since : truth_at M Omega τ s₁ φ.swap_temporal ∧
        (∃ s₂, s₂ < s₁ ∧ truth_at M Omega τ s₂ ψ.swap_temporal ∧
          ∀ q, s₂ < q → q < s₁ → truth_at M Omega τ q φ.swap_temporal) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_since => h_neg h_since)
    obtain ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩ := h_φs₁_and_since
    refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₂ q hs₂q h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₁ q h_gt hqt
  | absorb_since φ ψ =>
    -- Swap: (φ' U (φ' ∧ (φ' U ψ'))) → (φ' U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
    have h_φs₁_and_until : truth_at M Omega τ s₁ φ.swap_temporal ∧
        (∃ s₂, s₁ < s₂ ∧ truth_at M Omega τ s₂ ψ.swap_temporal ∧
          ∀ q, s₁ < q → q < s₂ → truth_at M Omega τ q φ.swap_temporal) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_until => h_neg h_until)
    obtain ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩ := h_φs₁_and_until
    refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₁ q htq h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₂ q h_gt hqs₂
  | linear_until φ ψ χ θ =>
    -- Swap: Since-based linearity with swapped subformulas
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, s < t ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ.swap_temporal) ∧
      (∃ s, s < t ∧ truth_at M Omega τ s θ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r χ.swap_temporal) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂ < t: third disjunct (φ∧χ) S (φ∧θ) with witness s₂
      intro _
      refine ⟨s₂, hs₂t, ?_, fun r hs₂r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ h_lt hs₂t) h_θs₂
      · exact h_imp (h_guard₁ r (lt_trans h_lt hs₂r) hrt) (h_guard₂ r hs₂r hrt)
    · -- s₁ = s₂: first disjunct (φ∧χ) S (ψ∧θ) with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (h_eq ▸ hs₁r) hrt)
    · -- s₂ < s₁ < t: second disjunct (φ∧χ) S (ψ∧χ) with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ h_gt hs₁t)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (lt_trans h_gt hs₁r) hrt)
  | linear_since φ ψ χ θ =>
    -- Swap: Until-based linearity with swapped subformulas
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, t < s ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ.swap_temporal) ∧
      (∃ s, t < s ∧ truth_at M Omega τ s θ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r χ.swap_temporal) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: second disjunct (φ∧χ) U (ψ∧χ) with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ hts₁ h_lt)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (lt_trans hrs h_lt))
    · -- s₁ = s₂: first disjunct (φ∧χ) U (ψ∧θ) with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (h_eq ▸ hrs))
    · -- s₂ < s₁: third disjunct (φ∧χ) U (φ∧θ) with witness s₂
      intro _
      refine ⟨s₂, hts₂, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ hts₂ h_gt) h_θs₂
      · exact h_imp (h_guard₁ r htr (lt_trans hrs h_gt)) (h_guard₂ r htr hrs)
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted, task 113)
  | until_F φ ψ =>
    -- swap of ((φ U ψ) → F(ψ)) is ((φ' S ψ') → P(ψ'))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal]
    simp only [truth_at, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _h_guard⟩
    exact ⟨s, hst, h_ψs⟩
  | since_P φ ψ =>
    -- swap of ((φ S ψ) → P(ψ)) is ((φ' U ψ') → F(ψ'))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal]
    simp only [truth_at, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _h_guard⟩
    exact ⟨s, hts, h_ψs⟩
  | temp_linearity φ ψ =>
    exact axiom_temp_linearity_past_valid φ.swap_temporal ψ.swap_temporal
  | temp_linearity_past φ ψ =>
    exact axiom_temp_linearity_valid φ.swap_temporal ψ.swap_temporal
  | F_until_equiv φ =>
    exact axiom_P_since_equiv_valid φ.swap_temporal
  | P_since_equiv φ =>
    exact axiom_F_until_equiv_valid φ.swap_temporal
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted, task 113)
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | discrete_symm_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun h => h, fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (t - r)) h1 h2
  | discrete_symm_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun h => h, fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact h_guard (c + (s - t)) h1 h2
  | discrete_propagate_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _hut
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs => rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_propagate_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _htu
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs => rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_box_necessity =>
    -- swap(U(T,bot) -> □(U(T,bot))) = S(T,bot) -> □(S(T,bot))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ σ _h_σ_mem
    exact ⟨r, hrt, fun h => h, h_guard⟩
  | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-- All base axioms are locally valid without DenselyOrdered frame constraints. -/
private theorem axiom_locally_valid_general [Nontrivial D] {φ : Formula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ FrameClass.Base) : is_valid D φ := by
  cases h with
  | prop_k φ ψ χ => exact axiom_prop_k_valid φ ψ χ
  | prop_s φ ψ => exact axiom_prop_s_valid φ ψ
  | modal_t ψ => exact axiom_modal_t_valid ψ
  | modal_4 ψ => exact axiom_modal_4_valid ψ
  | modal_b ψ => exact axiom_modal_b_valid ψ
  | modal_5_collapse ψ => exact axiom_modal_5_collapse_valid ψ
  | ex_falso ψ => exact axiom_ex_falso_valid ψ
  | peirce φ ψ => exact axiom_peirce_valid φ ψ
  | modal_k_dist φ ψ => exact axiom_modal_k_dist_valid φ ψ
  | serial_future =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.neg, truth_at, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | serial_past =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.neg, truth_at, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Direct: G(φ→χ) → untl(φ,ψ) → untl(χ,ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | left_mono_since_H φ χ ψ =>
    -- Direct: H(φ→χ) → snce(φ,ψ) → snce(χ,ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | right_mono_until φ ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | connect_future φ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | connect_past φ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Direct: p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_until : ∃ s, t < s ∧ truth_at M Omega τ s ψ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ := by
      by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
    obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
    refine ⟨s, hts, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩
  | enrichment_since φ ψ p =>
    -- Direct: p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_since : ∃ s, s < t ∧ truth_at M Omega τ s ψ ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ := by
      by_contra h_neg; exact h_conj (fun _ h_s => h_neg h_s)
    obtain ⟨s, hst, h_ψs, h_guard⟩ := h_since
    refine ⟨s, hst, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hst, h_pt, fun r hsr hrt => h_guard r hsr hrt⟩
  | self_accum_until φ ψ =>
    -- Direct: (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs => h_guard q (lt_trans htr hrq) hqs⟩
  | self_accum_since φ ψ =>
    -- Direct: (φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩
  | absorb_until φ ψ =>
    -- Direct: (φ U (φ ∧ (φ U ψ))) → (φ U ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
    have h_φs₁_and_until : truth_at M Omega τ s₁ φ ∧
        (∃ s₂, s₁ < s₂ ∧ truth_at M Omega τ s₂ ψ ∧
          ∀ q, s₁ < q → q < s₂ → truth_at M Omega τ q φ) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_until => h_neg h_until)
    obtain ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩ := h_φs₁_and_until
    refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₁ q htq h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₂ q h_gt hqs₂
  | absorb_since φ ψ =>
    -- Direct: (φ S (φ ∧ (φ S ψ))) → (φ S ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
    have h_φs₁_and_since : truth_at M Omega τ s₁ φ ∧
        (∃ s₂, s₂ < s₁ ∧ truth_at M Omega τ s₂ ψ ∧
          ∀ q, s₂ < q → q < s₁ → truth_at M Omega τ q φ) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_since => h_neg h_since)
    obtain ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩ := h_φs₁_and_since
    refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₂ q hs₂q h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₁ q h_gt hqt
  | linear_until φ ψ χ θ =>
    -- Direct: Until-based linearity
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, t < s ∧ truth_at M Omega τ s ψ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ) ∧
      (∃ s, t < s ∧ truth_at M Omega τ s θ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r χ) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: second disjunct with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ hts₁ h_lt)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (lt_trans hrs h_lt))
    · -- s₁ = s₂: first disjunct with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (h_eq ▸ hrs))
    · -- s₂ < s₁: third disjunct with witness s₂
      intro _
      refine ⟨s₂, hts₂, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ hts₂ h_gt) h_θs₂
      · exact h_imp (h_guard₁ r htr (lt_trans hrs h_gt)) (h_guard₂ r htr hrs)
  | linear_since φ ψ χ θ =>
    -- Direct: Since-based linearity
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, s < t ∧ truth_at M Omega τ s ψ ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ) ∧
      (∃ s, s < t ∧ truth_at M Omega τ s θ ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r χ) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: third disjunct with witness s₂
      intro _
      refine ⟨s₂, hs₂t, ?_, fun r hs₂r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ h_lt hs₂t) h_θs₂
      · exact h_imp (h_guard₁ r (lt_trans h_lt hs₂r) hrt) (h_guard₂ r hs₂r hrt)
    · -- s₁ = s₂: first disjunct with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (h_eq ▸ hs₁r) hrt)
    · -- s₁ > s₂: second disjunct with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ h_gt hs₁t)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (lt_trans h_gt hs₁r) hrt)
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted, task 113)
  | until_F φ ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _⟩
    exact ⟨s, hts, h_ψs⟩
  | since_P φ ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _⟩
    exact ⟨s, hst, h_ψs⟩
  | temp_linearity φ ψ => exact axiom_temp_linearity_valid φ ψ
  | temp_linearity_past φ ψ => exact axiom_temp_linearity_past_valid φ ψ
  | F_until_equiv φ => exact axiom_F_until_equiv_valid φ
  | P_since_equiv φ => exact axiom_P_since_equiv_valid φ
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted, task 113)
  | modal_future ψ => exact axiom_modal_future_valid ψ

  | discrete_symm_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun h => h, fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact h_guard (c + (s - t)) h1 h2
  | discrete_symm_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun h => h, fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (t - r)) h1 h2
  | discrete_propagate_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro ⟨s, hts, _h_top_s, h_guard⟩ u _htu
    refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
    have h1 : t < c - (u - t) := by
      conv_lhs => rw [(sub_sub_cancel u t).symm]
      exact sub_lt_sub_right huc _
    have h2 : c - (u - t) < s := by
      conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (u - t)) h1 h2
  | discrete_propagate_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro ⟨s, hts, _h_top_s, h_guard⟩ u _hut
    refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
    have h1 : t < c - (u - t) := by
      conv_lhs => rw [(sub_sub_cancel u t).symm]
      exact sub_lt_sub_right huc _
    have h2 : c - (u - t) < s := by
      conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (u - t)) h1 h2
  | discrete_box_necessity =>
    -- U(T,bot) -> □(U(T,bot)): discreteness depends only on D, not the history
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩ σ _h_σ_mem
    exact ⟨s, hts, fun h => h, h_guard⟩
  | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-- Combined soundness for base derivations without frame-class constraints:
derivability implies both validity and swap-validity. Identical to
`derivable_valid_and_swap_valid` but without `[DenselyOrdered D] [Nontrivial D]`.

This is possible because the BX axiom system has no density or discreteness extension
axioms, so the proofs never actually use those constraints. -/
theorem derivable_valid_and_swap_valid_general [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Base [] φ) :
    is_valid D φ ∧ is_valid D φ.swap_temporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨axiom_locally_valid_general h_ax h_fc, axiom_swap_valid_general _ h_ax h_fc⟩
  | .assumption _ _ h_mem => exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ ψ' _ d1 d2 =>
    obtain ⟨h1_valid, h1_swap⟩ := derivable_valid_and_swap_valid_general d1
    obtain ⟨h2_valid, h2_swap⟩ := derivable_valid_and_swap_valid_general d2
    exact ⟨mp_preserves_valid h1_valid h2_valid, mp_preserves_swap_valid ψ' _ h1_swap h2_swap⟩
  | .necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_general d'
    exact ⟨necessitation_preserves_local_valid h_valid, modal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_general d'
    exact ⟨temporal_necessitation_preserves_local_valid h_valid, temporal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_duality ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_general d'
    constructor
    · exact h_swap
    · simp only [Formula.swap_temporal_involution]; exact h_valid
  | .weakening Γ' _ _ d' h_sub =>
    have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Γ' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_valid_general (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/-- Derivability implies swap validity for dense-compatible derivations.
This is the theorem needed for the temporal_duality case in dense soundness. -/
theorem derivable_implies_swap_valid_general [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Base [] φ) :
    is_valid D φ.swap_temporal :=
  (derivable_valid_and_swap_valid_general d).2

/-! ## Discrete Frame Versions

The following theorems provide validity and swap-validity for all axioms on discrete
frames. Prior-UZ/SZ have `minFrameClass = .Discrete` and are only valid on discrete orders,
so these theorems handle all axioms including Prior-UZ/SZ. The discrete frame class
constraint `h.minFrameClass ≤ .Discrete` structurally excludes the density axiom.
-/

/-- Prior-UZ is valid on discrete orders: F(φ) → U(φ, ¬φ).
The nearest future witness where φ holds satisfies Until with ¬φ as guard.
Uses Nat.find for well-founded descent on the succ chain. -/
theorem prior_UZ_is_valid
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D (φ.some_future.imp (Formula.untl φ φ.neg)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.some_future_iff]
  intro ⟨s, hts, hs⟩
  obtain ⟨n, hn⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hn1 : Order.succ^[n + 1] t = s := by
    simp; exact hn
  classical
  have h_ex : ∃ k, truth_at M Omega τ (Order.succ^[k + 1] t) φ := ⟨n, hn1 ▸ hs⟩
  let k₀ := Nat.find h_ex
  have hk₀ : truth_at M Omega τ (Order.succ^[k₀ + 1] t) φ := Nat.find_spec h_ex
  have hk₀_min : ∀ m < k₀, ¬truth_at M Omega τ (Order.succ^[m + 1] t) φ :=
    fun m hm => Nat.find_min h_ex hm
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts.not_isMax
  refine ⟨Order.succ^[k₀ + 1] t, ?_, hk₀, ?_⟩
  · -- t < succ^[k₀+1] t: from t < succ t ≤ succ^[k₀+1] t
    have h1 := h_iter_mono (Nat.one_le_iff_ne_zero.mpr (Nat.succ_ne_zero k₀))
    simp only at h1
    exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max) h1
  · -- ∀ r, t < r → r < succ^[k₀+1] t → ¬ truth_at r φ
    intro r htr hrs
    obtain ⟨j, hj⟩ := (Order.succ_le_of_lt htr).exists_succ_iterate
    have hj1 : Order.succ^[j + 1] t = r := by
      simp; exact hj
    have hj_lt : j < k₀ := by
      by_contra h_ge
      push_neg at h_ge
      have h_le := h_iter_mono (show k₀ + 1 ≤ j + 1 by omega)
      simp only at h_le
      rw [hj1] at h_le
      exact absurd hrs (not_lt.mpr h_le)
    rw [← hj1]
    exact hk₀_min j hj_lt

/-- Prior-SZ is valid on discrete orders: P(φ) → S(φ, ¬φ).
Mirror of prior_UZ_is_valid using pred chain and IsPredArchimedean. -/
theorem prior_SZ_is_valid
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D (φ.some_past.imp (Formula.snce φ φ.neg)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.some_past_iff]
  intro ⟨s, hst, hs⟩
  obtain ⟨n, hn⟩ := (Order.le_pred_of_lt hst).exists_pred_iterate
  have hn1 : Order.pred^[n + 1] t = s := by
    simp; exact hn
  classical
  have h_ex : ∃ k, truth_at M Omega τ (Order.pred^[k + 1] t) φ := ⟨n, hn1 ▸ hs⟩
  let k₀ := Nat.find h_ex
  have hk₀ : truth_at M Omega τ (Order.pred^[k₀ + 1] t) φ := Nat.find_spec h_ex
  have hk₀_min : ∀ m < k₀, ¬truth_at M Omega τ (Order.pred^[m + 1] t) φ :=
    fun m hm => Nat.find_min h_ex hm
  have h_iter_anti : Antitone (fun i => Order.pred^[i] t) :=
    Order.pred_mono.antitone_iterate_of_map_le (Order.pred_le t)
  have h_not_min : ¬IsMin t := hst.not_isMin
  refine ⟨Order.pred^[k₀ + 1] t, ?_, hk₀, ?_⟩
  · -- pred^[k₀+1] t < t: from pred^[k₀+1] t ≤ pred t < t
    have h1 := h_iter_anti (Nat.one_le_iff_ne_zero.mpr (Nat.succ_ne_zero k₀))
    simp only at h1
    exact lt_of_le_of_lt h1 (Order.pred_lt_of_not_isMin h_not_min)
  · intro r hrs hrt
    obtain ⟨j, hj⟩ := (Order.le_pred_of_lt hrt).exists_pred_iterate
    have hj1 : Order.pred^[j + 1] t = r := by
      simp; exact hj
    have hj_lt : j < k₀ := by
      by_contra h_ge
      push_neg at h_ge
      have h_le := h_iter_anti (show k₀ + 1 ≤ j + 1 by omega)
      simp only at h_le
      rw [hj1] at h_le
      exact absurd hrs (not_lt.mpr h_le)
    rw [← hj1]
    exact hk₀_min j hj_lt

/-- Z1 is valid on discrete orders: G(Gφ→φ) → (FGφ→Gφ).
Backward induction from the Gφ witness using IsSuccArchimedean. -/
theorem z1_is_valid
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D ((φ.all_future.imp φ).all_future.imp
        (φ.all_future.some_future.imp φ.all_future)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.future_iff, Truth.some_future_iff]
  intro h_GGpIp ⟨s₀, hts₀, hs₀⟩
  obtain ⟨n₀, hn₀⟩ := (Order.succ_le_of_lt hts₀).exists_succ_iterate
  have hn₀_eq : Order.succ^[n₀ + 1] t = s₀ := by
    show Order.succ^[n₀] (Order.succ t) = s₀; exact hn₀
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts₀.not_isMax
  -- Helper: truth_at s φ for any s > t (the main goal, proved assuming backward induction)
  -- We prove: ∀ s > t, truth_at s φ, using backward induction from s₀.
  -- Strategy: for any s > t, obtain n with succ^[n](succ(t)) = s, then dispatch:
  --   n ≤ n₀: backward induction (h_descend below)
  --   n > n₀: either s₀ is max (so s = s₀, use h_GGpIp), or s > s₀ (use hs₀)
  have h_above_s0 : ∀ s, s₀ ≤ s → truth_at M Omega τ s φ := by
    intro s hs
    rcases eq_or_lt_of_le hs with rfl | hlt
    · exact h_GGpIp s₀ hts₀ hs₀
    · exact hs₀ s hlt
  -- Backward induction: truth_at (succ^[k+1](t)) φ for all k, using Nat.strong_induction_on
  -- on the "distance from top" n₀ - k (= 0 when k ≥ n₀).
  have h_all_iterates : ∀ k, truth_at M Omega τ (Order.succ^[k + 1] t) φ := by
    -- Prove ∀ k ≤ n₀ by strong induction on n₀ - k
    suffices h_le : ∀ k, k ≤ n₀ → truth_at M Omega τ (Order.succ^[k + 1] t) φ by
      intro k
      by_cases hk : k ≤ n₀
      · exact h_le k hk
      · exact h_above_s0 _ (hn₀_eq ▸ h_iter_mono (by omega : n₀ + 1 ≤ k + 1))
    -- Strong induction: prove for k assuming it holds for all k' with k < k' ≤ n₀
    have : ∀ d, d ≤ n₀ → ∀ k, n₀ - k = d → k ≤ n₀ →
        truth_at M Omega τ (Order.succ^[k + 1] t) φ := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro hd k hk hkn
        apply h_GGpIp
        · exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max)
            (h_iter_mono (by omega : 1 ≤ k + 1))
        · -- Need: ∀ r > succ^[k+1](t), truth_at r φ
          intro r hr
          obtain ⟨j, hj⟩ := (Order.succ_le_of_lt hr).exists_succ_iterate
          have hj_eq : Order.succ^[j + 1] (Order.succ^[k + 1] t) = r := by
            show Order.succ^[j] (Order.succ (Order.succ^[k + 1] t)) = r; exact hj
          rw [← hj_eq, ← Function.iterate_add_apply,
              show j + 1 + (k + 1) = (k + j + 1) + 1 from by omega]
          by_cases h_le : k + j + 1 ≤ n₀
          · exact ih (n₀ - (k + j + 1)) (by omega) (by omega) (k + j + 1) rfl h_le
          · exact h_above_s0 _ (hn₀_eq ▸ h_iter_mono (by omega : n₀ + 1 ≤ (k + j + 1) + 1))
    intro k hk
    exact this (n₀ - k) (by omega) k rfl hk
  -- Main goal
  intro s hts
  obtain ⟨m, hm⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hm_eq : Order.succ^[m] (Order.succ t) = s := hm
  exact (show Order.succ^[m + 1] t = s from hm_eq) ▸ h_all_iterates m

/-- Z1 past dual is valid on discrete orders: H(Hφ→φ) → (PHφ→Hφ).
Backward induction using IsPredArchimedean. -/
theorem z1_past_is_valid
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D ((φ.all_past.imp φ).all_past.imp
        (φ.all_past.some_past.imp φ.all_past)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.past_iff, Truth.some_past_iff]
  intro h_HHpIp ⟨s₀, hs₀t, hs₀⟩
  obtain ⟨n₀, hn₀⟩ := (Order.le_pred_of_lt hs₀t).exists_pred_iterate
  have hn₀_eq : Order.pred^[n₀ + 1] t = s₀ := by
    show Order.pred^[n₀] (Order.pred t) = s₀; exact hn₀
  have h_iter_anti : Antitone (fun i => Order.pred^[i] t) :=
    Order.pred_mono.antitone_iterate_of_map_le (Order.pred_le t)
  have h_not_min : ¬IsMin t := hs₀t.not_isMin
  have h_below_s0 : ∀ u, u ≤ s₀ → truth_at M Omega τ u φ := by
    intro u hu
    rcases eq_or_lt_of_le hu with rfl | hlt
    · exact h_HHpIp _ hs₀t hs₀
    · exact hs₀ u hlt
  have h_all_iterates : ∀ k, truth_at M Omega τ (Order.pred^[k + 1] t) φ := by
    suffices h_le : ∀ k, k ≤ n₀ → truth_at M Omega τ (Order.pred^[k + 1] t) φ by
      intro k
      by_cases hk : k ≤ n₀
      · exact h_le k hk
      · exact h_below_s0 _ (hn₀_eq ▸ h_iter_anti (by omega : n₀ + 1 ≤ k + 1))
    have : ∀ d, d ≤ n₀ → ∀ k, n₀ - k = d → k ≤ n₀ →
        truth_at M Omega τ (Order.pred^[k + 1] t) φ := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro hd k hk hkn
        apply h_HHpIp
        · exact lt_of_le_of_lt (h_iter_anti (by omega : 1 ≤ k + 1))
            (Order.pred_lt_of_not_isMin h_not_min)
        · intro r hr
          obtain ⟨j, hj⟩ := (Order.le_pred_of_lt hr).exists_pred_iterate
          have hj_eq : Order.pred^[j + 1] (Order.pred^[k + 1] t) = r := by
            show Order.pred^[j] (Order.pred (Order.pred^[k + 1] t)) = r; exact hj
          rw [← hj_eq, ← Function.iterate_add_apply,
              show j + 1 + (k + 1) = (k + j + 1) + 1 from by omega]
          by_cases h_le : k + j + 1 ≤ n₀
          · exact ih (n₀ - (k + j + 1)) (by omega) (by omega) (k + j + 1) rfl h_le
          · exact h_below_s0 _ (hn₀_eq ▸ h_iter_anti (by omega : n₀ + 1 ≤ (k + j + 1) + 1))
    intro k hk
    exact this (n₀ - k) (by omega) k rfl hk
  intro s hst
  obtain ⟨m, hm⟩ := (Order.le_pred_of_lt hst).exists_pred_iterate
  have hm_eq : Order.pred^[m] (Order.pred t) = s := hm
  exact (show Order.pred^[m + 1] t = s from hm_eq) ▸ h_all_iterates m

/-- All axiom swaps are valid on discrete orders. For dense-compatible axioms,
delegates to `axiom_swap_valid_general`. For Prior-UZ/SZ, proves directly. -/
private theorem axiom_swap_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Discrete) :
    is_valid D φ.swap_temporal := by
  by_cases hbase : h.minFrameClass ≤ FrameClass.Base
  · exact axiom_swap_valid_general _ h hbase
  · cases h with
    | prior_UZ φ =>
      show is_valid D (φ.swap_temporal.some_past.imp (φ.swap_temporal.snce φ.swap_temporal.neg))
      exact prior_SZ_is_valid φ.swap_temporal
    | prior_SZ φ =>
      show is_valid D (φ.swap_temporal.some_future.imp (φ.swap_temporal.untl φ.swap_temporal.neg))
      exact prior_UZ_is_valid φ.swap_temporal
    | z1 φ =>
      show is_valid D ((φ.swap_temporal.all_past.imp φ.swap_temporal).all_past.imp
        (φ.swap_temporal.all_past.some_past.imp φ.swap_temporal.all_past))
      exact z1_past_is_valid φ.swap_temporal
    | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | _ => exact absurd trivial hbase

/-- All discrete-compatible axioms are locally valid on discrete orders. For base axioms,
delegates to `axiom_locally_valid_general`. For others, proves directly. -/
private theorem axiom_locally_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Discrete) :
    is_valid D φ := by
  by_cases hbase : h.minFrameClass ≤ FrameClass.Base
  · exact axiom_locally_valid_general h hbase
  · cases h with
    | prior_UZ φ => exact prior_UZ_is_valid φ
    | prior_SZ φ => exact prior_SZ_is_valid φ
    | z1 φ => exact z1_is_valid φ
    | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | _ => exact absurd trivial hbase

/-- Combined soundness on discrete frames: derivability implies both validity
and swap-validity on discrete orders. -/
theorem derivable_valid_and_swap_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Discrete [] φ) :
    is_valid D φ ∧ is_valid D φ.swap_temporal := by
  match d with
  | .axiom _ _ h_ax h_fc => exact ⟨axiom_locally_valid_discrete h_ax h_fc, axiom_swap_valid_discrete _ h_ax h_fc⟩
  | .assumption _ _ h_mem => exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ ψ' _ d1 d2 =>
    obtain ⟨h1_valid, h1_swap⟩ := derivable_valid_and_swap_valid_discrete d1
    obtain ⟨h2_valid, h2_swap⟩ := derivable_valid_and_swap_valid_discrete d2
    exact ⟨mp_preserves_valid h1_valid h2_valid, mp_preserves_swap_valid ψ' _ h1_swap h2_swap⟩
  | .necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_discrete d'
    exact ⟨necessitation_preserves_local_valid h_valid, modal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_discrete d'
    exact ⟨temporal_necessitation_preserves_local_valid h_valid, temporal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_duality ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_discrete d'
    constructor
    · exact h_swap
    · simp only [Formula.swap_temporal_involution]; exact h_valid
  | .weakening Γ' _ _ d' h_sub =>
    have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Γ' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_valid_discrete (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/-- Derivability implies swap validity on discrete frames.
Used in soundness_discrete_valid and soundness_discrete temporal_duality cases. -/
theorem derivable_implies_swap_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Discrete [] φ) :
    is_valid D φ.swap_temporal :=
  (derivable_valid_and_swap_valid_discrete d).2

end Bimodal.Metalogic.SoundnessLemmas
