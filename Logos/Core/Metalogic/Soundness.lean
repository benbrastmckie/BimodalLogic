import Logos.Core.ProofSystem.Derivation
import Logos.Core.Semantics.Validity

/-!
# Soundness - Soundness Theorem for TM Logic

This module proves the soundness theorem for bimodal logic TM.

## Paper Specification Reference

**Perpetuity Principles (app:valid, line 1984)**:
The JPL paper "The Perpetuity Calculus of Agency" proves perpetuity principles
P1 (□φ → △φ) and P2 (▽φ → ◇φ) are valid over all task semantic models using
time-shift automorphisms.

**Axiom Validity**:
All TM axioms (MT, M4, MB, T4, TA, TL, MF, TF) are proven valid over all
task semantic models. The MF and TF axioms use time-shift invariance
(following the JPL paper's approach) to establish unconditional validity.

## Main Results

- `prop_k_valid`, `prop_s_valid`: Propositional axioms are valid
- `modal_t_valid`: Modal T axiom is valid
- `modal_4_valid`: Modal 4 axiom is valid
- `modal_b_valid`: Modal B axiom is valid
- `modal_k_dist_valid`: Modal K distribution axiom is valid
- `double_negation_valid`: Double negation elimination axiom is valid
- `temp_4_valid`: Temporal 4 axiom is valid
- `temp_a_valid`: Temporal A axiom is valid
- `temp_l_valid`: TL axiom is valid (uses always definition)
- `modal_future_valid`: MF axiom is valid (via time-shift invariance)
- `temp_future_valid`: TF axiom is valid (via time-shift invariance)
- `soundness`: Derivability implies semantic validity (`Γ ⊢ φ → Γ ⊨ φ`)

## Implementation Notes

**Completed Proofs**:
- 12/12 axiom validity lemmas: prop_k, prop_s, MT, M4, MB, MK_dist, DNE, T4, TA, TL, MF, TF
- 8/8 soundness cases: axiom, assumption, modus_ponens, necessitation, modal_k, temporal_k,
  temporal_duality, weakening

**Key Techniques**:
- Time-shift invariance (MF, TF): Uses `WorldHistory.time_shift` and
  `TimeShift.time_shift_preserves_truth` to relate truth at different times
- Classical logic helpers for conjunction extraction (TL)
- Derivation-indexed induction for temporal duality soundness

## References

* [ARCHITECTURE.md](../../../Documentation/UserGuide/ARCHITECTURE.md) - Soundness specification
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
* [Validity.lean](../../Semantics/Validity.lean) - Semantic validity
* JPL Paper app:valid (line 1984) - Perpetuity principle validity proofs
-/

namespace Logos.Core.Metalogic

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Semantics

/-! ## Classical Logic Helper -/

/-- Helper lemma for extracting conjunction from negated implication encoding.

In our formula encoding, `φ ∧ ψ` is represented as `¬(φ → ¬ψ)`, which is
`(φ → (ψ → False)) → False`. This lemma uses classical logic to extract the
proper conjunction.
-/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/--
Propositional K axiom is valid: `⊨ (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`.

This is a propositional tautology (distribution of implication).

Proof: Classical propositional reasoning. Assume (φ → (ψ → χ)) and (φ → ψ),
show (φ → χ). Given φ, we get ψ from second premise, then χ from first premise.
-/

theorem prop_k_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/--
Propositional S axiom is valid: `⊨ φ → (ψ → φ)`.

This is a propositional tautology (weakening/constant function).

Proof: Assume φ and ψ, show φ. This is immediate from the first assumption.
-/

theorem prop_s_valid (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_phi _
  exact h_phi

/--
Modal T axiom is valid: `⊨ □φ → φ`.

For any formula `φ`, the formula `□φ → φ` is valid (true in all models).

Proof: If `□φ` is true at `(M, τ, t)`, then `φ` is true at all histories at time `t`.
Since `τ` is a history containing `t`, we have `φ` true at `(M, τ, t)`.
-/

theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_box
  -- h_box : ∀ σ, t ∈ σ.domain → truth_at M σ t φ
  -- Goal: truth_at M τ t φ
  exact h_box τ ht

/--
Modal 4 axiom is valid: `⊨ □φ → □□φ`.

For any formula `φ`, the formula `□φ → □□φ` is valid.

Proof: Assume `□φ` is true at `(M, τ, t)`, i.e., for all histories `σ` at time `t`, `φ` holds.
We need to show `□□φ` is true, i.e., for all histories `σ` at time `t`, `□φ` holds at `σ`.
But `□φ` at `(M, σ, t)` means for all histories `ρ` at time `t`, `φ` holds at `ρ`.
Since `□φ` was already true (for ALL histories including `ρ`), this follows immediately.
-/

theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_box
  -- h_box : ∀ σ hs, truth_at M σ t hs φ
  -- Goal: ∀ σ hs, ∀ ρ hr, truth_at M ρ t hr φ
  intro σ hs ρ hr
  -- The key insight: h_box gives truth at ALL histories at time t
  -- ρ is just another history at time t, so h_box applies directly
  exact h_box ρ hr

/--
Modal B axiom is valid: `⊨ φ → □◇φ`.

For any formula `φ`, the formula `φ → □◇φ` is valid.

Proof: Assume `φ` is true at `(M, τ, t)`.
We need to show `□◇φ` is true, i.e., for all histories `σ` at time `t`, `◇φ` holds at `σ`.
`◇φ` is defined as `¬□¬φ`, so we need: ¬(∀ ρ hr, ¬(truth_at M ρ t hr φ)).
This is equivalent to: ∃ ρ hr, truth_at M ρ t hr φ.
We witness with `τ` and `ht`, where we assumed `φ` is true.
-/

theorem modal_b_valid (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_phi
  -- h_phi : truth_at M τ t ht φ
  -- Goal: truth_at M τ t ht (φ.diamond.box)
  -- Unfolding: ∀ σ hs, truth_at M σ t hs φ.diamond
  intro σ hs
  -- Goal: truth_at M σ t hs φ.diamond
  -- φ.diamond = φ.neg.box.neg = ((φ.imp bot).box).imp bot
  unfold Formula.diamond truth_at
  -- Goal: truth_at M σ t hs (φ.neg.box) → truth_at M σ t hs bot
  -- which is: (∀ ρ hr, truth_at M ρ t hr φ.neg) → False
  intro h_box_neg
  -- h_box_neg : ∀ ρ hr, truth_at M ρ t hr φ.neg
  -- where φ.neg = φ.imp bot
  -- So h_box_neg : ∀ ρ hr, truth_at M ρ t hr (φ.imp bot)
  -- which means: ∀ ρ hr, truth_at M ρ t hr φ → False
  have h_neg_at_tau := h_box_neg τ ht
  -- h_neg_at_tau : truth_at M τ t ht (φ.imp bot)
  -- which is: truth_at M τ t ht φ → False
  unfold Formula.neg truth_at at h_neg_at_tau
  exact h_neg_at_tau h_phi

/--
Modal K Distribution axiom is valid: `⊨ □(φ → ψ) → (□φ → □ψ)`.

This is the fundamental distribution axiom of normal modal logics.

Proof: Assume □(φ → ψ) at (M, τ, t), i.e., (φ → ψ) holds at all histories at time t.
Also assume □φ, i.e., φ holds at all histories at time t.
Goal: □ψ, i.e., ψ holds at all histories at time t.
For any history σ at time t, φ holds (by □φ), and (φ → ψ) holds (by □(φ → ψ)).
By modus ponens, ψ holds at σ.
-/
theorem modal_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_box_imp h_box_phi σ hs
  -- h_box_imp : ∀ ρ hr, truth_at M ρ t hr (φ.imp ψ)
  -- h_box_phi : ∀ ρ hr, truth_at M ρ t hr φ
  have h_imp_at_σ := h_box_imp σ hs
  have h_phi_at_σ := h_box_phi σ hs
  unfold truth_at at h_imp_at_σ
  exact h_imp_at_σ h_phi_at_σ

/--
Double Negation Elimination axiom is valid: `⊨ ¬¬φ → φ`.

This is the classical logic principle.

Proof: ¬¬φ = (φ → ⊥) → ⊥ = ((truth_at φ → False) → False)
By classical logic, ((P → False) → False) → P is valid.
-/
theorem double_negation_valid (φ : Formula) : ⊨ (φ.neg.neg.imp φ) := by
  intro T _ F M τ t ht
  unfold truth_at Formula.neg
  -- Goal: ((truth_at M τ t ht φ → False) → False) → truth_at M τ t ht φ
  intro h_not_not
  -- Classical logic: from ¬¬P, derive P
  exact Classical.byContradiction (fun h => h_not_not h)

/--
Temporal 4 axiom is valid: `⊨ Fφ → FFφ`.

For any formula `φ`, the formula `Fφ → FFφ` is valid.

Proof: Assume `Fφ` is true at `(M, τ, t)`, i.e., for all s > t in τ's domain, `φ` holds at s.
We need to show `FFφ` is true, i.e., for all s > t, for all r > s, `φ` holds at r.
Since r > s > t implies r > t, and Fφ says φ holds at all times > t, φ holds at r.
-/

theorem temp_4_valid (φ : Formula) : ⊨ ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_future
  -- h_future : ∀ s hs, t < s → truth_at M τ s hs φ
  -- Goal: ∀ s hs, t < s → (∀ r hr, s < r → truth_at M τ r hr φ)
  intro s hs hts r hr hsr
  -- Need to show: truth_at M τ r hr φ
  -- We have: t < s and s < r, so t < r
  have htr : t < r := lt_trans hts hsr
  exact h_future r hr htr

/--
Temporal A axiom is valid: `⊨ φ → F(sometime_past φ)`.

For any formula `φ`, the formula `φ → F(sometime_past φ)` is valid.

Proof: Assume `φ` is true at `(M, τ, t)`.
We need to show `F(sometime_past φ)` at `(M, τ, t)`.
This means: for all s > t in domain, `sometime_past φ` at `(M, τ, s)`.
`sometime_past φ = ¬P¬φ` means: NOT (for all r < s in domain, ¬φ at r).
Equivalently: there EXISTS r < s in domain where φ is true.
Since t < s and t is in domain (we're evaluating there), t is such an r.
-/

theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_future φ.sometime_past)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_phi
  -- h_phi : truth_at M τ t ht φ
  -- Goal: ∀ s hs, t < s → truth_at M τ s hs φ.sometime_past
  intro s hs hts
  -- Goal: truth_at M τ s hs φ.sometime_past
  -- With corrected definition: sometime_past φ = φ.neg.past.neg
  -- = (φ.neg).all_past.neg
  -- = ((φ.imp bot).all_past).imp bot

  -- truth_at ... φ.sometime_past
  -- = truth_at ... (φ.neg.past.neg)
  -- = truth_at ... ((φ.imp bot).all_past.imp bot)
  -- = (truth_at ... (φ.imp bot).all_past) → False
  -- = (∀ r hr, r < s → (truth_at ... φ → False)) → False

  -- We need to prove: (∀ r hr, r < s → (truth_at M τ r hr φ → False)) → False
  -- We have: h_phi : truth_at M τ t ht φ, and hts : t < s

  -- Assuming h : ∀ r hr, r < s → (truth_at M τ r hr φ → False)
  -- Then h t ht hts : truth_at M τ t ht φ → False
  -- And h t ht hts h_phi : False

  unfold Formula.sometime_past Formula.some_past Formula.neg truth_at
  -- Goal: (∀ r hr, r < s → truth_at M τ r hr (φ.imp bot)) → False
  intro h_all_neg
  -- h_all_neg : ∀ r hr, r < s → truth_at M τ r hr (φ.imp bot)
  -- This says: for all r < s, ¬φ at r
  have h_neg_at_t := h_all_neg t ht hts
  -- h_neg_at_t : truth_at M τ t ht (φ.imp bot)
  -- = truth_at M τ t ht φ → truth_at M τ t ht bot
  -- = truth_at M τ t ht φ → False
  unfold truth_at at h_neg_at_t
  exact h_neg_at_t h_phi

/--
TL axiom validity: `△φ → F(Pφ)` is valid in all task semantic models.

Following JPL paper §sec:Appendix (thm:temporal-axioms-valid, line 2334):

**Paper Proof**:
Suppose M,τ,x ⊨ always φ. Then M,τ,y ⊨ φ for all y ∈ T (by definition of always).
To show M,τ,x ⊨ Future Past φ, consider any z > x.
We must show M,τ,z ⊨ Past φ, i.e., M,τ,w ⊨ φ for all w < z.
But this holds by our assumption that φ holds at all times in τ.

This axiom is trivially valid because the premise `always φ` (φ at ALL times:
past, present, and future) immediately implies the conclusion: at any future
time z, φ holds at all past times w < z (since "all times" includes such w).

**Note**: After aligning with the paper's definition of `always`, this axiom
no longer requires frame constraints. The key is that `always φ = Pφ ∧ φ ∧ Fφ`
gives information about ALL times, not just future times.
-/

theorem temp_l_valid (φ : Formula) : ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_always
  -- h_always : truth_at M τ t ht φ.always
  -- Since always φ = past φ ∧ (φ ∧ future φ), we need to unfold
  -- The premise gives us: φ at all past times, φ now, φ at all future times
  -- Goal: ∀ s hs, t < s → ∀ r hr, r < s → truth_at M τ r hr φ
  intro s hs hts r hr hrs
  -- We need: truth_at M τ r hr φ
  -- We know φ holds at ALL times from h_always
  -- Case split: either r < t (use past), r = t (use present), or r > t (use future)
  -- Since always φ = (past φ) ∧ φ ∧ (future φ), and h_always : truth_at for this conjunction
  -- We need to extract the conjunction parts

  -- Simplify h_always using conjunction encoding
  -- always φ = φ.all_past ∧ (φ ∧ φ.all_future) encoded as negated implications
  simp only [Formula.always, Formula.and, Formula.neg, truth_at] at h_always

  -- Extract using classical logic (conjunction encoded as ¬(P → ¬Q))
  have h1 : (∀ (u : T) (hu : τ.domain u), u < t → truth_at M τ u hu φ) ∧
            ((truth_at M τ t ht φ → (∀ (v : T) (hv : τ.domain v), t < v → truth_at M τ v hv φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1

  have h2 : truth_at M τ t ht φ ∧ (∀ (v : T) (hv : τ.domain v), t < v → truth_at M τ v hv φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2

  -- Case split on whether r is before, at, or after t
  rcases lt_trichotomy r t with h_lt | h_eq | h_gt
  · -- r < t: use h_past
    exact h_past r hr h_lt
  · -- r = t: use h_now
    subst h_eq; exact h_now
  · -- t < r: use h_future
    exact h_future r hr h_gt

/--
MF axiom validity: `□φ → □(Fφ)` is valid in all task semantic models.

**JPL Paper Proof (thm:bimodal-axioms-valid, line 2352)**:
The paper proves MF is valid using the observation that □φ at time x means
φ holds at ALL histories at time x. The key insight is that for any σ at
any time y, we can use time-shift invariance to relate (σ, y) to some (ρ, x).

**Proof Strategy**:
Uses `WorldHistory.time_shift` and `TimeShift.time_shift_preserves_truth` to
relate truth at (σ, s) to truth at (time_shift σ (s-t), t), then applies the
□φ assumption to obtain φ at the time-shifted history.
-/

theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.all_future).box)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_box_phi
  -- h_box_phi : ∀ σ hs, truth_at M σ t hs φ
  -- Goal: ∀ σ hs, ∀ s hs', t < s → truth_at M σ s hs' φ
  intro σ hs s hs' hts
  -- We need: truth_at M σ s hs' φ
  -- From h_box_phi: φ at all histories at time t

  -- Strategy: Use time-shift to relate (σ, s) to a history at time t
  -- time_shift σ (s - t) gives a history at time t (where t + (s - t) = s)
  have h_shifted_domain : (WorldHistory.time_shift σ (s - t)).domain t := by
    simp only [WorldHistory.time_shift]
    have : t + (s - t) = s := add_sub_cancel t s
    rw [this]
    exact hs'

  -- Apply h_box_phi to the time-shifted history
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) h_shifted_domain

  -- Use time-shift preservation to relate truth at (shifted, t) to truth at (σ, s)
  have h_preserve := TimeShift.time_shift_preserves_truth M σ t s h_shifted_domain hs' φ
  exact h_preserve.mp h_phi_at_shifted

/--
TF axiom validity: `□φ → F(□φ)` is valid in all task semantic models.

**JPL Paper Proof (thm:bimodal-axioms-valid, lines 2354-2356)**:
The paper proves TF is valid using time-shift invariance:
1. Premise: □φ at time x (φ at all histories at x)
2. Goal: F□φ at x (for all y > x, □φ at y)
3. For any y > x and any σ at time y, need φ at (σ, y)
4. By time-shift: relate (σ, y) to a history at time x
5. By time-shift preservation: φ at (σ, y) ↔ φ at (shifted, x)
6. Since □φ at x, φ at (shifted, x), hence φ at (σ, y)

**Proof Strategy**:
Uses `WorldHistory.time_shift` and `TimeShift.time_shift_preserves_truth` to
relate truth at (σ, s) to truth at (time_shift σ (s-t), t), then applies the
□φ assumption to obtain φ at the time-shifted history.
-/

theorem temp_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.box).all_future)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_box_phi
  -- h_box_phi : ∀ σ hs, truth_at M σ t hs φ
  -- Goal: ∀ s hs, t < s → ∀ σ hs', truth_at M σ s hs' φ
  intro s hs hts σ hs'
  -- We need: truth_at M σ s hs' φ
  -- From h_box_phi: φ at all histories at time t

  -- Strategy: Use time-shift to relate (σ, s) to a history at time t
  -- time_shift σ (s - t) gives a history at time t
  have h_shifted_domain : (WorldHistory.time_shift σ (s - t)).domain t := by
    simp only [WorldHistory.time_shift]
    have : t + (s - t) = s := add_sub_cancel t s
    rw [this]
    exact hs'

  -- Apply h_box_phi to the time-shifted history
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) h_shifted_domain

  -- Use time-shift preservation to relate truth at (shifted, t) to truth at (σ, s)
  have h_preserve := TimeShift.time_shift_preserves_truth M σ t s h_shifted_domain hs' φ
  exact h_preserve.mp h_phi_at_shifted

/--
All TM axioms are valid.

This helper lemma shows that every axiom instance is a valid formula.
-/
theorem axiom_valid {φ : Formula} : Axiom φ → ⊨ φ := by
  intro h_axiom
  cases h_axiom with
  | prop_k φ ψ χ => exact prop_k_valid φ ψ χ
  | prop_s φ ψ => exact prop_s_valid φ ψ
  | modal_t ψ => exact modal_t_valid ψ
  | modal_4 ψ => exact modal_4_valid ψ
  | modal_b ψ => exact modal_b_valid ψ
  | modal_k_dist φ ψ => exact modal_k_dist_valid φ ψ
  | double_negation ψ => exact double_negation_valid ψ
  | temp_4 ψ => exact temp_4_valid ψ
  | temp_a ψ => exact temp_a_valid ψ
  | temp_l ψ => exact temp_l_valid ψ
  | modal_future ψ => exact modal_future_valid ψ
  | temp_future ψ => exact temp_future_valid ψ

/--
Soundness theorem: Derivability implies semantic validity.

If `Γ ⊢ φ` (φ is derivable from context Γ), then `Γ ⊨ φ` (φ is a semantic consequence of Γ).

Proof by induction on the derivation structure:
- Axioms: All axioms are valid (proven above)
- Assumptions: Assumed formulas are true by hypothesis
- Modus Ponens: If `φ → ψ` and `φ` both valid, then `ψ` valid
- Modal K: If `φ` derivable from boxed context, then `□φ` derivable
- Temporal K: If `φ` derivable from future context, then `Fφ` derivable
- Temporal Duality: Swapping past/future preserves validity
- Weakening: Adding premises preserves semantic consequence
-/
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro h_deriv
  induction h_deriv with
  | «axiom» Γ' φ' h_ax =>
    -- Case: φ' is an axiom
    -- All axioms are valid, hence semantic consequences of any context
    intro T _ F M τ t ht _
    exact axiom_valid h_ax T F M τ t ht

  | @assumption Γ' φ' h_mem =>
    -- Case: φ' ∈ Γ' (assumption)
    -- If all of Γ' true, then φ' (member of Γ') is true
    intro T _ F M τ t ht h_all
    exact h_all φ' h_mem

  | @modus_ponens Γ' φ' ψ' _ _ ih_imp ih_phi =>
    -- Case: From Γ' ⊢ φ' → ψ' and Γ' ⊢ φ', derive Γ' ⊢ ψ'
    -- By IH: Γ' ⊨ φ' → ψ' and Γ' ⊨ φ'
    -- Goal: Γ' ⊨ ψ'
    intro T _ F M τ t ht h_all
    have h_imp := ih_imp T F M τ t ht h_all
    have h_phi := ih_phi T F M τ t ht h_all
    unfold truth_at at h_imp
    exact h_imp h_phi

  | @modal_k Γ' φ' _ ih =>
    -- Case: From Γ' ⊢ φ', derive □Γ' ⊢ □φ'
    -- IH: Γ' ⊨ φ'
    -- Goal: (□Γ') ⊨ □φ', i.e., (Γ'.map box) ⊨ □φ'
    --
    -- At (M, τ, t) where all formulas in □Γ' are true, we need □φ' true.
    -- □φ' at (M, τ, t) means: ∀ σ, t ∈ σ.domain → φ' at (M, σ, t)
    --
    -- For any σ with t in domain:
    -- - Each ψ ∈ Γ' has ψ.box ∈ □Γ'
    -- - ψ.box true at (M, τ, t) means: ∀ ρ, t ∈ ρ.domain → ψ at (M, ρ, t)
    -- - So ψ true at (M, σ, t) for all ψ ∈ Γ'
    -- - By IH: Γ' ⊨ φ' means if all ψ ∈ Γ' true, then φ' true
    -- - Therefore φ' true at (M, σ, t)
    intro T _ F M τ t ht h_all_box_gamma
    -- Goal: truth_at M τ t ht φ'.box
    unfold truth_at
    -- Goal: ∀ σ hs, truth_at M σ t hs φ'
    intro σ hs
    -- Need: truth_at M σ t hs φ'
    -- Use IH: Γ' ⊨ φ'
    apply ih T F M σ t hs
    -- Need: ∀ ψ, ψ ∈ Γ' → truth_at M σ t hs ψ
    intro ψ h_psi_in_gamma
    -- ψ.box ∈ Γ'.map box, so ψ.box true at (M, τ, t)
    have h_box_psi_in := Context.mem_map_of_mem (f := Formula.box) h_psi_in_gamma
    have h_box_psi_true := h_all_box_gamma (ψ.box) h_box_psi_in
    -- h_box_psi_true : truth_at M τ t ht ψ.box
    -- Unfold to get: ∀ ρ hr, truth_at M ρ t hr ψ
    unfold truth_at at h_box_psi_true
    exact h_box_psi_true σ hs

  | @temporal_k Γ' φ' _ ih =>
    -- Case: From Γ' ⊢ φ', derive FΓ' ⊢ Fφ'
    -- IH: Γ' ⊨ φ'
    -- Goal: (FΓ') ⊨ Fφ', i.e., (Γ'.map future) ⊨ Fφ'
    --
    -- At (M, τ, t) where all formulas in FΓ' are true, we need Fφ' true.
    -- Fφ' at (M, τ, t) means: ∀ s > t, s ∈ τ.domain → φ' at (M, τ, s)
    --
    -- For any s > t with s in domain:
    -- - Each ψ ∈ Γ' has ψ.all_future ∈ FΓ'
    -- - ψ.all_future true at (M, τ, t) means: ∀ r > t, r ∈ τ.domain → ψ at (M, τ, r)
    -- - So ψ true at (M, τ, s) for all ψ ∈ Γ' (since s > t)
    -- - By IH: Γ' ⊨ φ' means if all ψ ∈ Γ' true, then φ' true
    -- - Therefore φ' true at (M, τ, s)
    intro T _ F M τ t ht h_all_future_gamma
    -- Goal: truth_at M τ t ht φ'.future
    unfold truth_at
    -- Goal: ∀ s hs, t < s → truth_at M τ s hs φ'
    intro s hs hts
    -- Need: truth_at M τ s hs φ'
    -- Use IH: Γ' ⊨ φ'
    apply ih T F M τ s hs
    -- Need: ∀ ψ, ψ ∈ Γ' → truth_at M τ s hs ψ
    intro ψ h_psi_in_gamma
    -- ψ.all_future ∈ Γ'.map future, so ψ.all_future true at (M, τ, t)
    have h_future_psi_in := Context.mem_map_of_mem (f := Formula.all_future) h_psi_in_gamma
    have h_future_psi_true := h_all_future_gamma (ψ.all_future) h_future_psi_in
    -- h_future_psi_true : truth_at M τ t ht ψ.all_future
    -- Unfold to get: ∀ r > t, r ∈ τ.domain → truth_at M τ r ψ
    unfold truth_at at h_future_psi_true
    exact h_future_psi_true s hs hts

  | @temporal_duality φ' h_deriv_phi _ =>
    -- Case: From [] ⊢ φ', derive [] ⊢ swap_past_future φ'
    -- h_deriv_phi: Derivable [] φ' (we have a derivation of φ')
    -- Goal: [] ⊨ swap_past_future φ' (i.e., swap_past_future φ' is valid)
    --
    -- **Temporal Duality Soundness Strategy (Approach D: Derivation-Indexed)**
    --
    -- Instead of using formula induction (which fails on impossible cases),
    -- we use the fact that we have a DERIVATION of φ'. The theorem
    -- `derivable_implies_swap_valid` proves swap validity by induction on
    -- derivations, avoiding the impossible formula-induction cases.
    --
    -- **Proof Strategy**:
    -- 1. We have: h_deriv_phi : Derivable [] φ'
    -- 2. Apply derivable_implies_swap_valid to get: is_valid φ'.swap_past_future
    -- 3. Unpack the local is_valid definition to get: ⊨ φ'.swap_past_future
    --
    -- **Key Insight**: We don't need to prove "valid φ → valid φ.swap" for ALL
    -- valid formulas. We only need it for DERIVABLE formulas, and derivation
    -- induction avoids the impossible cases.
    intro T _ F M τ t ht _
    -- Goal: truth_at M τ t ht (swap_past_future φ')
    -- Use derivable_implies_swap_valid which proves: Derivable [] φ' → is_valid φ'.swap
    have h_swap_valid := @Semantics.TemporalDuality.derivable_implies_swap_valid T _ _ h_deriv_phi
    -- h_swap_valid : is_valid T φ'.swap_past_future
    -- Unpack the local is_valid definition
    exact h_swap_valid F M τ t ht

  | @weakening Γ' Δ' φ' _ h_sub ih =>
    -- Case: From Γ' ⊢ φ' and Γ' ⊆ Δ', derive Δ' ⊢ φ'
    -- By IH: Γ' ⊨ φ'
    -- Goal: Δ' ⊨ φ'
    intro T _ F M τ t ht h_all
    apply ih T F M τ t ht
    intro ψ h_mem
    exact h_all ψ (h_sub h_mem)

end Logos.Core.Metalogic
