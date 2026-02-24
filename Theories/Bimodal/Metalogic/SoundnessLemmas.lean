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

## Omega Parameterization (Task 912)

All local validity definitions and soundness lemmas quantify over shift-closed Omega.
This enables the temporal_duality case in Soundness.lean to use these lemmas at
arbitrary Omega (not just Set.univ), which is needed for the Omega-parameterized
soundness theorem to go through.

## References

* [Truth.lean](../Semantics/Truth.lean) - Pure semantic definitions
* [Soundness.lean](Soundness.lean) - Soundness theorem using these lemmas
* Task 213 research report - Circular dependency analysis
* Task 219 implementation plan - Module hierarchy restructuring
-/

namespace Bimodal.Metalogic.SoundnessLemmas

open Bimodal.Syntax
open Bimodal.ProofSystem (Axiom DerivationTree)
open Bimodal.Semantics

/--
Local definition of validity to avoid circular dependency with Validity.lean.
A formula is valid if it's true at all model-history-time triples within any shift-closed Omega.

This is a monomorphic definition (fixed to explicit type parameter D) to avoid
universe level mismatch errors.
Per research report Option A: Make D explicit to allow type inference at call sites.

**Note**: With the new semantics (Task #454), validity quantifies over ALL times,
not just times in the history's domain.

**Omega Parameterization (Task 912)**: Quantifies over all shift-closed Omega sets
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
    truth_at M Omega τ t φ.swap_past_future.swap_past_future ↔ truth_at M Omega τ t φ := by
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

  | all_past φ ih =>
    -- All_past case: all_past φ -> all_future φ.swap -> all_past φ.swap.swap
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h s h_ord
    · exact (ih τ s).mp (h s h_ord)
    · exact (ih τ s).mpr (h s h_ord)

  | all_future φ ih =>
    -- All_future case: all_future φ -> all_past φ.swap -> all_future φ.swap.swap
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h s h_ord
    · exact (ih τ s).mp (h s h_ord)
    · exact (ih τ s).mpr (h s h_ord)

/-!
## NOTE: Unprovable Theorem Removed

The theorem `is_valid_swap_involution` as originally stated is **UNPROVABLE**.

**Original claim**: `is_valid D φ.swap -> is_valid D φ`

**Why it's false**: The `swap_past_future` operation exchanges `all_past` <-> `all_future`,
which quantify over different time ranges (past s<t vs future s>t). These are not
equivalent in general temporal models.

**Counterexample**: Consider φ = all_past(atom "p") in a model where p is true at all
future times but false at all past times. Then φ.swap = all_future(atom "p") is valid,
but φ = all_past(atom "p") is not valid.

**Semantic analysis**: With the OLD strict semantics, swap created an asymmetry:
- `all_past φ` quantified over s < t (strict past times)
- `all_future φ` quantified over s > t (strict future times)
- Swapping exchanged these ranges, which were not equivalent in arbitrary models

**Note**: With the CURRENT reflexive semantics (Task #658), temporal operators use `<=`:
- `all_past φ` quantifies over s <= t (now and past)
- `all_future φ` quantifies over s <= t (now and future)
- The T-axioms (Gφ -> φ, Hφ -> φ) are now trivially valid via `le_refl`

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

**Proof**: The swapped form is `(box φ.swap_past_future).imp φ.swap_past_future`.
At any triple (M, τ, t), if box φ.swap holds, then φ.swap holds at (M, τ, t) specifically.
-/
theorem swap_axiom_mt_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp φ).swap_past_future := by
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
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.box φ))).swap_past_future := by
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
    is_valid D (φ.imp (Formula.box φ.diamond)).swap_past_future := by
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
       (Formula.all_future (Formula.all_future φ))).swap_past_future := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro h_past_swap r h_r_le_t u h_u_le_r
  have h_u_le_t : u ≤ t := le_trans h_u_le_r h_r_le_t
  exact h_past_swap u h_u_le_t

/--
Temporal A axiom (TA) swaps to a valid formula: `φ -> F(sometime_past φ)` swaps to
`swap φ -> P(sometime_future (swap φ))`.

The swapped form states: if swap φ holds now, then at all past times, there existed
a future time when swap φ held. This is valid because "now" is in the future of all past times.
-/
theorem swap_axiom_ta_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.sometime_past)).swap_past_future := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_past_future, Formula.sometime_past]
  intro h_swap_φ s h_s_le_t h_all_not_future
  exact h_all_not_future t h_s_le_t h_swap_φ

/--
Temporal L axiom (TL) swaps to a valid formula: `always φ -> FPφ` swaps to `always(swap φ) -> P(F(swap φ))`.

Note: always is self-dual: φ.always.swap_past_future = φ.swap_past_future.always
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
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))).swap_past_future := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro h_always s h_s_lt_t u h_s_lt_u
  by_cases h_ut : u ≤ t
  · -- Case: u <= t, use the "past" component
    apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro h_fut_all h_conj
    apply h_conj
    intro h_now h_past
    exact h_neg (h_past u h_ut)
  · -- Case: u > t, use the "future" component
    push_neg at h_ut
    have h_gt : t ≤ u := le_of_lt h_ut
    apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro h_fut_all h_conj
    exact h_neg (h_fut_all u h_gt)

/--
Modal-Future axiom (MF) swaps to a valid formula: `box φ -> box Fφ` swaps to `box(swap φ) -> box P(swap φ)`.

The swapped form states: if swap φ holds at all histories in Omega at time t, then for all histories σ
in Omega at time t, P(swap φ) holds at σ (i.e., swap φ holds at all times s < t in σ).

**Proof Strategy**: Use `time_shift_preserves_truth` to bridge from time t to time s < t.
Uses `ShiftClosed Omega` to ensure shifted histories remain in Omega.
-/
theorem swap_axiom_mf_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.all_future φ))).swap_past_future := by
  intro F M Omega h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap σ h_σ_mem s h_s_lt_t
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ.swap_past_future).mp h_at_shifted

/--
Temporal-Future axiom (TF) swaps to a valid formula: `box φ -> F box φ` swaps to `box(swap φ) -> P box(swap φ)`.

The swapped form states: if swap φ holds at all histories in Omega at time t, then at all times s < t,
swap φ holds at all histories in Omega at time s.

**Proof Strategy**: Same as MF - use `time_shift_preserves_truth` to bridge from time t to s < t.
Uses `ShiftClosed Omega` to ensure shifted histories remain in Omega.
-/
theorem swap_axiom_tf_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.all_future (Formula.box φ))).swap_past_future := by
  intro F M Omega h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap s h_s_lt_t σ h_σ_mem
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ.swap_past_future).mp h_at_shifted

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
    (h_imp : is_valid D (φ.imp ψ).swap_past_future)
    (h_phi : is_valid D φ.swap_past_future) :
    is_valid D ψ.swap_past_future := by
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
    (h : is_valid D φ.swap_past_future) :
    is_valid D (Formula.box φ).swap_past_future := by
  intro F M Omega h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro σ h_σ_mem
  exact h F M Omega h_sc σ h_σ_mem t

/--
Temporal K rule preserves swap validity.

If `φ.swap` is valid, then `(Fφ).swap = P(φ.swap)` is valid.

**Proof**: If `φ.swap` is true at all tuples, then for any (F, M, Omega, h_sc, τ, h_mem, t),
at all times s < t, `φ.swap` is true at (M, τ, s). This is exactly `P(φ.swap)`.
-/
theorem temporal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D (Formula.all_future φ).swap_past_future := by
  intro F M Omega h_sc τ h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro s _h_s_lt_t
  exact h F M Omega h_sc τ h_mem s

/--
Weakening preserves swap validity (trivial for empty context).

For the temporal duality rule, we only consider derivations from empty context.
Weakening from [] to [] is trivial.
-/
theorem weakening_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D φ.swap_past_future := h

/-! ## Axiom Swap Validity Master Theorem (Phase 4 - Partial)

This section adds the master theorem that combines all individual axiom swap validity lemmas.

**Status**: COMPLETE - all axioms proven.

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
    by_cases h : truth_at M Omega τ t ψ.swap_past_future
    · exact h
    · have h_imp : truth_at M Omega τ t (ψ.swap_past_future.imp χ.swap_past_future) := by
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
  | temp_k_dist ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_past_imp h_past_psi s hst
    exact h_past_imp s hst (h_past_psi s hst)
  | temp_4 ψ => exact swap_axiom_t4_valid ψ
  | temp_a ψ => exact swap_axiom_ta_valid ψ
  | temp_l ψ => exact swap_axiom_tl_valid ψ
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | temp_future ψ => exact swap_axiom_tf_valid ψ
  | temp_t_future ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_past
    exact h_past t (le_refl t)
  | temp_t_past ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_future
    exact h_future t (le_refl t)
  | temp_linearity ψ χ =>
    -- The swap of the future-linearity axiom is the past-linearity axiom
    -- P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)
    -- The proof is symmetric to the future version, using le_total on D
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.some_future,
               Formula.some_past, Formula.neg, truth_at]
    intro h_conj
    -- Extract P(phi) and P(psi) witnesses using classical logic
    have h_P_phi : (∀ s, s ≤ t → truth_at M Omega τ s ψ.swap_temporal → False) → False :=
      Classical.byContradiction (fun h_not =>
        h_conj (fun h1 _ => h_not (fun h_all => h1 (fun s hs h_phi => h_all s hs h_phi))))
    have h_P_psi : (∀ s, s ≤ t → truth_at M Omega τ s χ.swap_temporal → False) → False :=
      Classical.byContradiction (fun h_not =>
        h_conj (fun _ h2 => h_not (fun h_all => h2 (fun s hs h_psi => h_all s hs h_psi))))
    -- Extract existential witnesses
    have ⟨s1, hs1t, h_phi_s1⟩ : ∃ s, s ≤ t ∧ truth_at M Omega τ s ψ.swap_temporal := by
      by_contra h_no; push_neg at h_no
      exact h_P_phi (fun s hs h_phi => h_no s hs h_phi)
    have ⟨s2, hs2t, h_psi_s2⟩ : ∃ s, s ≤ t ∧ truth_at M Omega τ s χ.swap_temporal := by
      by_contra h_no; push_neg at h_no
      exact h_P_psi (fun s hs h_psi => h_no s hs h_psi)
    rcases le_total s1 s2 with h_le | h_le
    · -- s1 ≤ s2: psi.swap at s1, chi.swap at s2
      -- P(psi.swap ∧ P(chi.swap)) witness at s1: psi.swap at s1, P(chi.swap) at s1 via s2? NO: s2 ≥ s1
      -- Actually: P(P(psi.swap) ∧ chi.swap) witness at s2: P(psi.swap) at s2 via s1 (s1 ≤ s2), chi at s2
      -- So provide third disjunct
      intro _h_not_simul
      intro _h_not_middle
      intro h_not_last
      apply h_not_last s2 hs2t
      intro h_imp
      apply h_imp
      · intro h_no_past_phi
        exact h_no_past_phi s1 h_le h_phi_s1
      · exact h_psi_s2
    · -- s2 ≤ s1: chi.swap at s2, psi.swap at s1
      -- P(psi.swap ∧ P(chi.swap)) witness at s1: psi.swap at s1, P(chi.swap) at s1 via s2 (s2 ≤ s1)
      -- So provide second disjunct
      intro _h_not_simul
      intro h_not_middle
      exfalso
      apply h_not_middle
      intro h_all_neg_second
      exact h_all_neg_second s1 hs1t (fun h_imp => h_imp h_phi_s1 (fun h_neg_P_psi =>
        h_neg_P_psi s2 h_le h_psi_s2))

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
  simp only [truth_at]
  intro h_future_imp h_future_phi s hts
  exact h_future_imp s hts (h_future_phi s hts)

/-- Temporal 4 axiom is locally valid. -/
private theorem axiom_temp_4_valid (φ : Formula) :
    is_valid D ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future s hts r hsr
  have htr : t ≤ r := le_trans hts hsr
  exact h_future r htr

/-- Helper for temporal A axiom. -/
private theorem axiom_temp_a_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.sometime_past)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi s hts h_all_neg
  exact h_all_neg t hts h_phi

/-- Helper lemma for extracting conjunction from negated implication encoding. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/-- Temporal L axiom is locally valid. -/
private theorem axiom_temp_l_valid (φ : Formula) :
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.always, Formula.and, Formula.neg, truth_at]
  intro h_always s hts r hrs
  have h1 :
    (∀ (u : D), u ≤ t → truth_at M Omega τ u φ) ∧
    ((truth_at M Omega τ t φ →
      (∀ (v : D), t ≤ v → truth_at M Omega τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : truth_at M Omega τ t φ ∧ (∀ (v : D), t ≤ v → truth_at M Omega τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨_h_now, h_future⟩ := h2
  by_cases h : r ≤ t
  · exact h_past r h
  · push_neg at h
    exact h_future r (le_of_lt h)

/-- Modal-Future axiom is locally valid. -/
private theorem axiom_modal_future_valid (φ : Formula) :
    is_valid D ((φ.box).imp ((φ.all_future).box)) := by
  intro F M Omega h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_phi σ h_σ_mem s hts
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ).mp h_phi_at_shifted

/-- Temporal-Future axiom is locally valid. -/
private theorem axiom_temp_future_valid (φ : Formula) :
    is_valid D ((φ.box).imp ((φ.box).all_future)) := by
  intro F M Omega h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_phi s hts σ h_σ_mem
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ).mp h_phi_at_shifted

/-- Temporal T axiom for future is locally valid: `Gφ -> φ`.

With reflexive semantics (Task #658), `all_future` quantifies over `t <= s`,
meaning "now and all future times". The T-axiom `Gφ -> φ` is therefore trivially
valid: if φ holds at all s >= t, then in particular φ holds at t (via `le_refl t`).
-/
private theorem axiom_temp_t_future_valid (φ : Formula) :
    is_valid D ((Formula.all_future φ).imp φ) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future
  exact h_future t (le_refl t)

/-- Temporal T axiom for past is locally valid: `Hφ -> φ`.

With reflexive semantics (Task #658), `all_past` quantifies over `s <= t`,
meaning "now and all past times". The T-axiom `Hφ -> φ` is therefore trivially
valid: if φ holds at all s <= t, then in particular φ holds at t (via `le_refl t`).
-/
private theorem axiom_temp_t_past_valid (φ : Formula) :
    is_valid D ((Formula.all_past φ).imp φ) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_past
  exact h_past t (le_refl t)

/-- Temporal linearity axiom is locally valid.

`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`

The proof uses linearity of D (the `le_total` from `LinearOrder`). Given witnesses
s1 ≥ t for φ and s2 ≥ t for ψ, either s1 ≤ s2 (take r = s1, giving F(φ ∧ F(ψ)))
or s2 ≤ s1 (take r = s2, giving F(F(φ) ∧ ψ)).
-/
private theorem axiom_temp_linearity_valid (φ ψ : Formula) :
    is_valid D (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
      (Formula.or (Formula.some_future (Formula.and φ ψ))
        (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
          (Formula.some_future (Formula.and (Formula.some_future φ) ψ))))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.some_future, Formula.neg, truth_at]
  intro h_conj
  -- Extract both F-witnesses using classical logic
  have ⟨h_F_phi, h_F_psi⟩ := and_of_not_imp_not h_conj
  -- Extract existential witnesses
  have ⟨s1, hs1t, h_phi_s1⟩ : ∃ s, t ≤ s ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no
    exact h_F_phi (fun s hs h_phi => h_no s hs h_phi)
  have ⟨s2, hs2t, h_psi_s2⟩ : ∃ s, t ≤ s ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_F_psi (fun s hs h_psi => h_no s hs h_psi)
  -- Goal is: ¬F(φ∧ψ) → (¬F(φ∧F(ψ)) → F(F(φ)∧ψ))
  -- Which is: ¬first → ¬second → third (in ¬¬ encoding)
  -- By linearity, provide the appropriate disjunct
  rcases le_total s1 s2 with h_le | h_le
  · -- s1 ≤ s2: provide second disjunct F(φ ∧ F(ψ))
    -- The second disjunct is doubly negated: ((... → False) → False)
    intro _  -- discard ¬first
    intro h_neg_second  -- h_neg_second : (∀ s, ...) → False  (negated F(φ∧F(ψ)))
    -- We have h_neg_second is actually: ((∀ s, t ≤ s → ¬¬(φ at s ∧ F(ψ) at s)) → ⊥) → ⊥
    -- i.e., it says F(φ∧F(ψ)) is actually TRUE, so ¬F(φ∧F(ψ)) is False.
    -- Wait, the structure is (¬B → ⊥) i.e., ¬¬B. We need to show ⊥ from ¬¬B → C.
    -- Actually the goal after intro _ and intro h_neg_second is:
    -- (∀ s, t ≤ s → ¬¬(F(φ)∧ψ at s)) → ⊥
    -- So we need to prove the third disjunct. But we wanted the second!
    -- Let me reconsider the or encoding.
    -- A ∨ (B ∨ C) = (A→⊥) → ((B→⊥) → C)
    -- After intro _h_not_A, intro _h_not_B, goal is C.
    -- We wanted B, not C! So we should NOT intro _h_not_B; instead, we should prove B.
    -- But B itself is doubly negated...
    -- Actually: (¬A → ¬B → C) → ⊥ when we have ¬A and B.
    -- We need to show the FULL disjunction. We do that by providing B.
    -- The disjunction goal is: (¬A → (¬B → C)) and we intro ¬A, giving (¬B → C).
    -- If we have B, we can do: by_contra h_neg_B; apply B to get a value, then C, contradiction.
    -- Actually, ¬B → C means: "either B or C". If we have evidence for B, we need to derive ⊥.
    -- Hmm, let me think again...
    -- The goal after intro _h_not_A is: ((¬B → ⊥) → ⊥) → (∀s, ...) → ⊥
    -- which is: ¬¬B → ¬C → ⊥ = ¬¬B → ¬C → ⊥
    -- So we intro the ¬¬B part... no, we need to provide the function.
    -- Actually the or encoding is: (A → ⊥) → B, so A ∨ B = (A → ⊥) → B.
    -- And B ∨ C = (B → ⊥) → C.
    -- So the full goal A ∨ (B ∨ C) = (A → ⊥) → ((B → ⊥) → C).
    -- After intro h_not_A, goal is (B → ⊥) → C.
    -- To prove B, we need to show ⊥ from the assumption (B → ⊥).
    -- So we intro h_not_B and show ⊥ using B and h_not_B.
    -- But how do we show B? B = F(φ∧F(ψ)) = ¬∀s, ¬¬(¬(φ∧F(ψ)))
    -- This is getting very deep. Let me just introduce everything and derive ⊥ directly.
    -- After introducing all 3 negations, goal is ⊥, and we have witnesses.
    -- For s1 ≤ s2 case: F(φ∧F(ψ)) at t with witness s1 (phi at s1, F(psi) at s1 via s2)
    -- h_neg_second : F(φ∧F(ψ)) → ⊥ (where F(φ∧F(ψ)) is ¬∀s ≥ t, ¬(φ at s ∧ F(ψ) at s))
    -- Actually h_neg_second has type ((...) → False) → False which is ¬¬B.
    -- Hmm, I'm confusing myself. Let me just look at the actual goal type.
    -- From lean_goal output, after intro _h_not_simul, the goal should be the rest.
    -- Let me write a simpler proof using tauto or classical reasoning.
    -- Actually, let me try a completely different approach: use `by_contra` and work with negations.
    exfalso
    apply h_neg_second
    intro h_all_neg_second
    exact h_all_neg_second s1 hs1t (fun h_imp => h_imp h_phi_s1 (fun h_neg_F_psi =>
      h_neg_F_psi s2 h_le h_psi_s2))
  · -- s2 ≤ s1: provide third disjunct F(F(φ) ∧ ψ)
    intro _  -- discard ¬first
    intro _  -- discard ¬second
    intro h_all_neg_third
    exact h_all_neg_third s2 hs2t (fun h_imp => h_imp
      (fun h_neg_F_phi => h_neg_F_phi s1 h_le h_phi_s1) h_psi_s2)

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
  | temp_linearity φ ψ => exact axiom_temp_linearity_valid φ ψ

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
        intro F M Omega h_sc τ h_mem t
        have h1 := h_imp_valid F M Omega h_sc τ h_mem t
        have h2 := h_ψ_valid F M Omega h_sc τ h_mem t
        simp only [truth_at] at h1
        exact h1 h2
      · -- Swap validity of χ'
        exact mp_preserves_swap_valid ψ' χ' h_imp_swap h_ψ_swap

    | necessitation ψ' h_ψ' ih =>
      intro h_eq
      -- Necessitation: use IH for both properties
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · -- Validity of box ψ'
        intro F M Omega h_sc τ _h_mem t
        simp only [truth_at]
        intro σ h_σ_mem
        exact h_valid F M Omega h_sc σ h_σ_mem t
      · -- Swap validity of box ψ'
        exact modal_k_preserves_swap_valid ψ' h_swap

    | temporal_necessitation ψ' h_ψ' ih =>
      intro h_eq
      -- Temporal necessitation: use IH for both properties
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · -- Validity of Fψ'
        intro F M Omega h_sc τ h_mem t s hts
        exact h_valid F M Omega h_sc τ h_mem s
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
        intro F M Omega h_sc τ h_mem t
        have h_truth := h_valid F M Omega h_sc τ h_mem t
        -- Use truth_at_swap_swap to rewrite the goal
        exact (truth_at_swap_swap M Omega τ t ψ').mpr h_truth

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

end Bimodal.Metalogic.SoundnessLemmas
