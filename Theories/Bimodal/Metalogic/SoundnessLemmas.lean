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
open Bimodal.ProofSystem (Axiom DerivationTree)
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

**Why it's false**: The `swap_temporal` operation exchanges `all_past` <-> `all_future`,
which quantify over different time ranges (past s<t vs future s>t). These are not
equivalent in general temporal models.

**Counterexample**: Consider φ = all_past(atom "p") in a model where p is true at all
future times but false at all past times. Then φ.swap = all_future(atom "p") is valid,
but φ = all_past(atom "p") is not valid.

**Semantic analysis**: With the OLD strict semantics, swap created an asymmetry:
- `all_past φ` quantified over s < t (strict past times)
- `all_future φ` quantified over s > t (strict future times)
- Swapping exchanged these ranges, which were not equivalent in arbitrary models

**Note**: With the CURRENT reflexive semantics, temporal operators use `<=`:
- `all_past φ` quantifies over s <= t (now and past)
- `all_future φ` quantifies over s <= t (now and future)
- The T-axioms (Gφ -> φ, Hφ -> φ) are now trivially valid via `le_refl`

**The theorem IS true for derivable formulas** (see `derivable_valid_swap_involution` at end of file),
because the temporal_duality inference rule guarantees swap preservation for provable formulas.

**Research**: See research report for detailed semantic analysis and proof of
unprovability.

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
  simp only [Formula.swap_temporal, truth_at]
  intro h_past_swap r h_r_le_t u h_u_le_r
  have h_u_le_t : u ≤ t := le_trans h_u_le_r h_r_le_t
  exact h_past_swap u h_u_le_t

/--
Temporal A axiom (TA) swaps to a valid formula: `φ -> F(some_past φ)` swaps to
`swap φ -> P(some_future (swap φ))`.

The swapped form states: if swap φ holds now, then at all past times, there existed
a future time when swap φ held. This is valid because "now" is in the future of all past times.
-/
theorem swap_axiom_ta_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.some_past)).swap_temporal := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.swap_temporal, Formula.some_past]
  intro h_swap_φ s h_s_le_t h_all_not_future
  exact h_all_not_future t h_s_le_t h_swap_φ

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
  simp only [Formula.swap_temporal, truth_at]
  intro h_always s h_s_le_t u h_s_le_u
  -- h_always encodes (swap) always: G(X) ∧ (X ∧ H(X)) where X = swap φ
  -- Under reflexive semantics: h_past : ∀ s ≤ t, X s, h_now : X t, h_fut : ∀ s ≥ t, X s
  -- We need X at u where s ≤ t and s ≤ u.
  -- Under reflexive semantics, always gives φ at ALL times, so any u works.
  -- We just need to extract from the always structure.
  rcases le_or_lt u t with h_le | h_gt
  · -- Case: u ≤ t, use H(X) (past component, includes present)
    apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro _h_fut h_conj
    apply h_conj
    intro _h_now h_past
    exact h_neg (h_past u h_le)
  · -- Case: u > t, use G(X) (future component)
    apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro h_fut _h_conj
    exact h_neg (h_fut u (le_of_lt h_gt))

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
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap σ h_σ_mem s h_s_le_t
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ.swap_temporal).mp h_at_shifted

/--
Temporal-Future axiom (TF) swaps to a valid formula: `box φ -> F box φ` swaps to `box(swap φ) -> P box(swap φ)`.

The swapped form states: if swap φ holds at all histories in Omega at time t, then at all times s < t,
swap φ holds at all histories in Omega at time s.

**Proof Strategy**: Same as MF - use `time_shift_preserves_truth` to bridge from time t to s < t.
Uses `ShiftClosed Omega` to ensure shifted histories remain in Omega.
-/
theorem swap_axiom_tf_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.all_future (Formula.box φ))).swap_temporal := by
  intro F M Omega h_sc τ _h_mem t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap s h_s_le_t σ h_σ_mem
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
  simp only [Formula.swap_temporal, truth_at]
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

theorem axiom_swap_valid (φ : Formula) (h : Axiom φ) [DenselyOrdered D] [Nontrivial D]
    (h_dc : h.isDenseCompatible) : is_valid D φ.swap_temporal := by
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
  | temp_linearity ψ χ =>
    -- The swap of the future-linearity axiom is the past-linearity axiom
    -- P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)
    -- With reflexive ≤, use trichotomy on witnesses
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.some_future,
               Formula.some_past, Formula.neg, truth_at]
    intro h_conj
    -- Extract P(phi) and P(psi) witnesses using classical logic (reflexive semantics)
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
    rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
    · -- s1 < s2: P(P(ψ.swap) ∧ χ.swap) witness at s2
      intro _h_not_simul
      intro _h_not_middle
      intro h_not_last
      apply h_not_last s2 hs2t
      intro h_imp
      apply h_imp
      · intro h_no_past_phi
        exact h_no_past_phi s1 (le_of_lt h_lt) h_phi_s1
      · exact h_psi_s2
    · -- s1 = s2: P(ψ.swap ∧ χ.swap) witness at s1
      subst h_eq
      intro h_not_first
      exfalso
      apply h_not_first
      intro h_all_neg_first
      exact h_all_neg_first s1 hs1t (fun h_imp => h_imp h_phi_s1 h_psi_s2)
    · -- s2 < s1: P(ψ.swap ∧ P(χ.swap)) witness at s1
      intro _h_not_simul
      intro h_not_middle
      exfalso
      apply h_not_middle
      intro h_all_neg_second
      exact h_all_neg_second s1 hs1t (fun h_imp => h_imp h_phi_s1 (fun h_neg_P_psi =>
        h_neg_P_psi s2 (le_of_lt h_gt) h_psi_s2))
  | density ψ =>
    -- swap(GGφ → Gφ) = HHφ → Hφ (trivially valid under reflexive semantics)
    -- Proof: If HHφ at t (∀r ≤ t, ∀s ≤ r, φ(s)), then Hφ at t (∀s ≤ t, φ(s)).
    -- For any s ≤ t, take r = s in HHφ to get ∀u ≤ s, φ(u). Since s ≤ s, φ(s).
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_HH s hst
    -- h_HH : ∀ r ≤ t, ∀ u ≤ r, φ.swap(u)
    -- hst : s ≤ t
    -- Need: φ.swap(s)
    -- Take r = s: from h_HH at s, ∀ u ≤ s, φ.swap(u). Since s ≤ s, φ.swap(s).
    exact h_HH s hst s le_rfl
  | discreteness_forward _ =>
    -- discreteness_forward is not dense-compatible, eliminated by h_dc
    exact absurd h_dc id
  | seriality_future ψ =>
    -- swap(Gψ → Fψ) = Hψ → Pψ (trivially valid under reflexive semantics via T-axiom)
    -- Proof: If Hψ at t (∀s ≤ t, ψ(s)), then Pψ at t (∃s ≤ t, ψ(s)).
    -- Take s = t: ψ(t) from Hψ via T-axiom, and t ≤ t by reflexivity.
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.some_past, Formula.neg, truth_at]
    intro h_H h_all_neg
    -- h_H : ∀ s ≤ t, ψ.swap(s)
    -- h_all_neg : ∀ s ≤ t, ¬ψ.swap(s)
    -- Use t itself as witness: t ≤ t by reflexivity
    exact h_all_neg t le_rfl (h_H t le_rfl)
  | seriality_past ψ =>
    -- swap(Hψ → Pψ) = Gψ → Fψ (trivially valid under reflexive semantics via T-axiom)
    -- Proof: If Gψ at t (∀s ≥ t, ψ(s)), then Fψ at t (∃s ≥ t, ψ(s)).
    -- Take s = t: ψ(t) from Gψ via T-axiom, and t ≥ t by reflexivity.
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.some_future, Formula.neg, truth_at]
    intro h_G h_all_neg
    -- h_G : ∀ s ≥ t, ψ.swap(s)
    -- h_all_neg : ∀ s ≥ t, ¬ψ.swap(s)
    -- Use t itself as witness: t ≥ t by reflexivity
    exact h_all_neg t le_rfl (h_G t le_rfl)
  | temp_t_future ψ =>
    -- swap(Gψ → ψ) = Hψ → ψ (T-axiom for past, trivially valid)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_H
    -- h_H : ∀ s ≤ t, ψ.swap(s)
    -- Need: ψ.swap(t). By reflexivity t ≤ t, h_H gives ψ.swap(t).
    exact h_H t le_rfl
  | temp_t_past ψ =>
    -- swap(Hψ → ψ) = Gψ → ψ (T-axiom for future, trivially valid)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_G
    -- h_G : ∀ s ≥ t, ψ.swap(s)
    -- Need: ψ.swap(t). By reflexivity t ≥ t, h_G gives ψ.swap(t).
    exact h_G t le_rfl

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

/-- Temporal 4 axiom is locally valid (reflexive semantics). -/
private theorem axiom_temp_4_valid (φ : Formula) :
    is_valid D ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future s hts r hsr
  have htr : t ≤ r := le_trans hts hsr
  exact h_future r htr

/-- Helper for temporal A axiom (reflexive semantics). -/
private theorem axiom_temp_a_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.some_past)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi s hts h_all_neg
  exact h_all_neg t hts h_phi

/-- Helper lemma for extracting conjunction from negated implication encoding. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/-- Temporal L axiom is locally valid (reflexive semantics). -/
private theorem axiom_temp_l_valid (φ : Formula) :
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.always, Formula.and, Formula.neg, truth_at]
  intro h_always s _hts r hrs
  -- Under reflexive semantics, always encodes: (∀ u ≤ t, φ(u)) ∧ ((φ(t) → (∀ v ≥ t, φ(v)) → ⊥) → ⊥)
  -- This simplifies to: φ holds at all times
  have h1 :
    (∀ (u : D), u ≤ t → truth_at M Omega τ u φ) ∧
    ((truth_at M Omega τ t φ →
      (∀ (v : D), t ≤ v → truth_at M Omega τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : truth_at M Omega τ t φ ∧ (∀ (v : D), t ≤ v → truth_at M Omega τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2
  -- With reflexive semantics, we have φ at all times (past including now, future including now)
  -- r ≤ s and s ≥ t. Either r ≤ t (use past) or r > t (use future)
  rcases le_or_lt r t with h_le | h_gt
  · exact h_past r h_le
  · exact h_future r (le_of_lt h_gt)

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

/-- Temporal linearity axiom is locally valid (reflexive semantics).

`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`

The proof uses linearity of D (the `lt_trichotomy` from `LinearOrder`). Given witnesses
s1 ≥ t for φ and s2 ≥ t for ψ, either s1 < s2 (take r = s1, giving F(φ ∧ F(ψ))),
s1 = s2 (giving F(φ ∧ ψ)), or s2 < s1 (take r = s2, giving F(F(φ) ∧ ψ)).
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
  -- Extract existential witnesses (using ≤ due to reflexive semantics)
  have ⟨s1, hs1t, h_phi_s1⟩ : ∃ s, t ≤ s ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no
    exact h_F_phi (fun s hs h_phi => h_no s hs h_phi)
  have ⟨s2, hs2t, h_psi_s2⟩ : ∃ s, t ≤ s ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_F_psi (fun s hs h_psi => h_no s hs h_psi)
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: provide second disjunct F(φ ∧ F(ψ))
    intro _
    intro h_neg_second
    exfalso
    apply h_neg_second
    intro h_all_neg_second
    exact h_all_neg_second s1 hs1t (fun h_imp => h_imp h_phi_s1 (fun h_neg_F_psi =>
      h_neg_F_psi s2 (le_of_lt h_lt) h_psi_s2))
  · -- s1 = s2: provide first disjunct F(φ ∧ ψ)
    subst h_eq
    intro h_neg_first
    exfalso
    apply h_neg_first
    intro h_all_neg_first
    exact h_all_neg_first s1 hs1t (fun h_imp => h_imp h_phi_s1 h_psi_s2)
  · -- s2 < s1: provide third disjunct F(F(φ) ∧ ψ)
    intro _
    intro _
    intro h_all_neg_third
    exact h_all_neg_third s2 hs2t (fun h_imp => h_imp
      (fun h_neg_F_phi => h_neg_F_phi s1 (le_of_lt h_gt) h_phi_s1) h_psi_s2)

/-- Density axiom (DN) is locally valid on dense orders: `GGφ → Gφ` (Sahlqvist form).
Under reflexive semantics, trivially valid by taking r = s. -/
private theorem axiom_density_valid [DenselyOrdered D] (φ : Formula) :
    is_valid D (φ.all_future.all_future.imp φ.all_future) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_GG s hts
  -- h_GG : ∀ r ≥ t, ∀ u ≥ r, φ(u)
  -- hts : t ≤ s
  -- Goal: φ(s)
  -- Take r = s: from h_GG at s, ∀ u ≥ s, φ(u). Since s ≥ s, φ(s).
  exact h_GG s hts s le_rfl

/-- All dense-compatible axioms are locally valid on dense orders. -/
private theorem axiom_locally_valid [DenselyOrdered D] [Nontrivial D] {φ : Formula} (h : Axiom φ)
    (h_dc : h.isDenseCompatible) : is_valid D φ := by
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
  | temp_k_dist φ ψ => exact axiom_temp_k_dist_valid φ ψ
  | temp_4 ψ => exact axiom_temp_4_valid ψ
  | temp_a ψ => exact axiom_temp_a_valid ψ
  | temp_l ψ => exact axiom_temp_l_valid ψ
  | modal_future ψ => exact axiom_modal_future_valid ψ
  | temp_future ψ => exact axiom_temp_future_valid ψ
  | temp_linearity φ ψ => exact axiom_temp_linearity_valid φ ψ
  | density ψ => exact axiom_density_valid ψ
  | discreteness_forward _ => exact absurd h_dc id
  | seriality_future ψ =>
    -- Under reflexive semantics, Gψ → Fψ is trivially valid via T-axiom
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_future, Formula.neg, truth_at]
    intro h_G h_all_neg
    -- h_G : ∀ s ≥ t, ψ(s)
    -- h_all_neg : ∀ s ≥ t, ¬ψ(s)
    -- Use t itself as witness: t ≥ t by reflexivity
    exact h_all_neg t le_rfl (h_G t le_rfl)
  | seriality_past ψ =>
    -- Under reflexive semantics, Hψ → Pψ is trivially valid via T-axiom
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_past, Formula.neg, truth_at]
    intro h_H h_all_neg
    -- h_H : ∀ s ≤ t, ψ(s)
    -- h_all_neg : ∀ s ≤ t, ¬ψ(s)
    -- Use t itself as witness: t ≤ t by reflexivity
    exact h_all_neg t le_rfl (h_H t le_rfl)
  | temp_t_future ψ =>
    -- T-axiom future: Gψ → ψ (trivially valid by reflexivity)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro h_G
    exact h_G t le_rfl
  | temp_t_past ψ =>
    -- T-axiom past: Hψ → ψ (trivially valid by reflexivity)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro h_H
    exact h_H t le_rfl

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
  simp only [truth_at]
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
    {φ : Formula} (d : DerivationTree [] φ) (h_dc : d.isDenseCompatible) :
    is_valid D φ ∧ is_valid D φ.swap_temporal := by
  match d with
  | .axiom _ _ h_ax => exact ⟨axiom_locally_valid h_ax h_dc, axiom_swap_valid _ h_ax h_dc⟩
  | .assumption _ _ h_mem => exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ ψ' _ d1 d2 =>
    obtain ⟨h_dc1, h_dc2⟩ := h_dc
    obtain ⟨h1_valid, h1_swap⟩ := derivable_valid_and_swap_valid d1 h_dc1
    obtain ⟨h2_valid, h2_swap⟩ := derivable_valid_and_swap_valid d2 h_dc2
    exact ⟨mp_preserves_valid h1_valid h2_valid, mp_preserves_swap_valid ψ' _ h1_swap h2_swap⟩
  | .necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid d' h_dc
    exact ⟨necessitation_preserves_local_valid h_valid, modal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid d' h_dc
    exact ⟨temporal_necessitation_preserves_local_valid h_valid, temporal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_duality ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid d' h_dc
    constructor
    · exact h_swap
    · simp only [Formula.swap_temporal_involution]; exact h_valid
  | .weakening Γ' _ _ d' h_sub =>
    -- Since d : DerivationTree [] φ, and weakening gives Δ = [], we have Γ' ⊆ []
    -- Therefore Γ' = [] and d' : DerivationTree Γ' φ where Γ' = []
    have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
    -- For termination: (h_eq ▸ d').height = d'.height < (weakening ...).height
    have h_dc_sub : (h_eq ▸ d').isDenseCompatible := by
      simp only [DerivationTree.isDenseCompatible] at h_dc
      subst h_eq
      exact h_dc
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Γ' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_valid (h_eq ▸ d') h_dc_sub
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
    {φ : Formula} (d : DerivationTree [] φ) (h_dc : d.isDenseCompatible) :
    is_valid D φ :=
  (derivable_valid_and_swap_valid d h_dc).1

/-- Derivability implies swap validity (extracted from combined theorem).
This is the theorem needed for the temporal_duality case in soundness_dense. -/
theorem derivable_implies_swap_valid [DenselyOrdered D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree [] φ) (h_dc : d.isDenseCompatible) :
    is_valid D φ.swap_temporal :=
  (derivable_valid_and_swap_valid d h_dc).2

end Bimodal.Metalogic.SoundnessLemmas
