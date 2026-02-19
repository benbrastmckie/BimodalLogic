import Bimodal.ProofSystem.Derivation
import Bimodal.Semantics.Validity
import Bimodal.Metalogic.SoundnessLemmas

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

- `temp_4_valid`: Temporal 4 axiom is valid
- `temp_a_valid`: Temporal A axiom is valid
- `temp_l_valid`: TL axiom is valid (uses always definition)
- `modal_future_valid`: MF axiom is valid (via time-shift invariance)
- `temp_future_valid`: TF axiom is valid (via time-shift invariance)
- `soundness`: Derivability implies semantic validity (`Γ ⊢ φ → Γ ⊨ φ`)

## Implementation Notes

**Completed Proofs**:
- 14/14 axiom validity lemmas: prop_k, prop_s, ex_falso, peirce, MT, M4, MB, M5_collapse,
  MK_dist, TK_dist, T4, TA, TL, MF, TF
- 7/7 soundness cases: axiom, assumption, modus_ponens, necessitation, temporal_necessitation,
  temporal_duality, weakening

**Key Techniques**:
- Time-shift invariance (MF, TF): Uses `WorldHistory.time_shift` and
  `TimeShift.time_shift_preserves_truth` to relate truth at different times
- Classical logic helpers for conjunction extraction (TL)
- Derivation-indexed induction for temporal duality soundness

## References

* [ARCHITECTURE.md](../../../docs/UserGuide/ARCHITECTURE.md) - Soundness specification
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
* [Validity.lean](../../Semantics/Validity.lean) - Semantic validity
* JPL Paper app:valid (line 1984) - Perpetuity principle validity proofs
-/

namespace Bimodal.Metalogic

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

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
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/--
Propositional S axiom is valid: `⊨ φ → (ψ → φ)`.

This is a propositional tautology (weakening/constant function).

Proof: Assume φ and ψ, show φ. This is immediate from the first assumption.
-/

theorem prop_s_valid (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_phi _
  exact h_phi

/--
Modal T axiom is valid: `⊨ □φ → φ`.

For any formula `φ`, the formula `□φ → φ` is valid (true in all models).

Proof: If `□φ` is true at `(M, τ, t)`, then `φ` is true at all histories at time `t`.
Since `τ` is a history containing `t`, we have `φ` true at `(M, τ, t)`.
-/

theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ _ _ F M τ t
  simp only [truth_at, Set.mem_univ, true_implies]
  intro h_box
  -- h_box : ∀ σ, truth_at M Set.univ σ t φ
  -- Goal: truth_at M Set.univ τ t φ
  exact h_box τ

/--
Modal 4 axiom is valid: `⊨ □φ → □□φ`.

For any formula `φ`, the formula `□φ → □□φ` is valid.

Proof: Assume `□φ` is true at `(M, τ, t)`, i.e., for all histories `σ` at time `t`, `φ` holds.
We need to show `□□φ` is true, i.e., for all histories `σ` at time `t`, `□φ` holds at `σ`.
But `□φ` at `(M, σ, t)` means for all histories `ρ` at time `t`, `φ` holds at `ρ`.
Since `□φ` was already true (for ALL histories including `ρ`), this follows immediately.
-/

theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  intro T _ _ _ F M τ t
  simp only [truth_at, Set.mem_univ, true_implies]
  intro h_box
  -- h_box : ∀ σ, truth_at M Set.univ σ t φ
  -- Goal: ∀ σ, ∀ ρ, truth_at M Set.univ ρ t φ
  intro σ ρ
  -- The key insight: h_box gives truth at ALL histories at time t
  -- ρ is just another history at time t, so h_box applies directly
  exact h_box ρ

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
  intro T _ _ _ F M τ t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at, Set.mem_univ, true_implies]
  intro h_phi σ h_box_neg
  have h_neg_at_tau := h_box_neg τ
  exact h_neg_at_tau h_phi

/--
Modal 5 Collapse axiom is valid: `⊨ ◇□φ → □φ`.

This is the characteristic S5 collapse axiom. It is valid because in S5 semantics
(equivalence relation accessibility), if there exists an accessible world where
□φ holds, then φ holds at all worlds from that world, which by equivalence
includes all worlds from the actual world.

Proof: Assume ◇□φ at (M, τ, t), i.e., ¬□¬□φ.
This means: not all histories have ¬□φ.
So there exists some history σ where □φ holds, i.e., φ at all histories from σ.
In S5 (equivalence relation), all histories at t are mutually accessible.
So φ holds at ALL histories at t, including ρ for any ρ.
Hence □φ at (M, τ, t).
-/
theorem modal_5_collapse_valid (φ : Formula) : ⊨ (φ.box.diamond.imp φ.box) := by
  intro T _ _ _ F M τ t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at, Set.mem_univ, true_implies]
  intro h_diamond_box ρ
  by_contra h_not_phi
  apply h_diamond_box
  intro σ h_box_at_sigma
  have h_phi_at_rho := h_box_at_sigma ρ
  exact h_not_phi h_phi_at_rho

/--
EFQ axiom is valid: `⊨ ⊥ → φ`.

For any formula `φ`, the formula `⊥ → φ` is valid (true in all models).

Proof: Assume `⊥` is true at `(M, τ, t)`. But by definition, `truth_at M τ t ht bot = False`,
so we have `False`, which is a contradiction. By the `exfalso` tactic (classical logic),
from `False` we can derive any goal, including `truth_at M τ t ht φ`.

Since `⊥` can never be true, the implication `⊥ → φ` is vacuously valid.
-/
theorem ex_falso_valid (φ : Formula) : ⊨ (Formula.bot.imp φ) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_bot
  -- h_bot : truth_at M τ t Formula.bot
  -- But truth_at ... bot = False (by definition in Truth.lean)
  -- So h_bot : False
  exfalso
  exact h_bot

/--
Peirce's Law is valid: `⊨ ((φ → ψ) → φ) → φ`.

For any formulas `φ` and `ψ`, Peirce's Law `((φ → ψ) → φ) → φ` is valid.

Proof: Assume `(φ → ψ) → φ` is true at `(M, τ, t)`.
By classical logic (LEM), either φ is true or φ is false at `(M, τ, t)`.
- Case 1: If `truth_at M τ t ht φ` holds, we're done.
- Case 2: If `¬(truth_at M τ t ht φ)`, then `φ → ψ` is vacuously true
  (false antecedent makes implication true).
  From `(φ → ψ) → φ` and `φ → ψ`, we derive φ by modus ponens.
  But this contradicts our assumption that φ is false.

Therefore φ must be true, so the implication is valid.

This uses classical reasoning (`by_cases` on φ) and is valid in the classical
two-valued task semantics used by Logos.
-/
theorem peirce_valid (φ ψ : Formula) : ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_peirce
  -- Use classical reasoning: either φ is true or false
  by_cases h : truth_at M Set.univ τ t φ
  · -- Case 1: φ is true
    exact h
  · -- Case 2: φ is false, derive contradiction
    -- If φ is false, then φ → ψ is true (false antecedent)
    have h_imp : truth_at M Set.univ τ t (φ.imp ψ) := by
      simp only [truth_at]
      intro h_phi
      exfalso
      exact h h_phi
    -- Apply h_peirce: from (φ → ψ) → φ and (φ → ψ), get φ
    exact h_peirce h_imp

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
  intro T _ _ _ F M τ t
  simp only [truth_at, Set.mem_univ, true_implies]
  intro h_box_imp h_box_phi σ
  have h_imp_at_σ := h_box_imp σ
  have h_phi_at_σ := h_box_phi σ
  exact h_imp_at_σ h_phi_at_σ

/--
Temporal K Distribution axiom is valid: `⊨ F(φ → ψ) → (Fφ → Fψ)`.

This is the temporal analog of modal K distribution.

Proof: Assume F(φ → ψ) at (M, τ, t), i.e., (φ → ψ) holds at all future times.
Also assume Fφ, i.e., φ holds at all future times.
Goal: Fψ, i.e., ψ holds at all future times.
For any time s > t, φ holds (by Fφ), and (φ → ψ) holds (by F(φ → ψ)).
By modus ponens, ψ holds at s.
-/
theorem temp_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_future_imp h_future_phi s hts
  -- h_future_imp : ∀ r, t < r → truth_at M τ r (φ.imp ψ)
  -- h_future_phi : ∀ r, t < r → truth_at M τ r φ
  have h_imp_at_s := h_future_imp s hts
  have h_phi_at_s := h_future_phi s hts
  exact h_imp_at_s h_phi_at_s

/--
Temporal 4 axiom is valid: `⊨ Fφ → FFφ`.

For any formula `φ`, the formula `Fφ → FFφ` is valid.

Proof: Assume `Fφ` is true at `(M, τ, t)`, i.e., for all s > t in τ's domain, `φ` holds at s.
We need to show `FFφ` is true, i.e., for all s > t, for all r > s, `φ` holds at r.
Since r > s > t implies r > t, and Fφ says φ holds at all times > t, φ holds at r.
-/

theorem temp_4_valid (φ : Formula) : ⊨ ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_future
  -- h_future : ∀ s, t ≤ s → truth_at M τ s φ
  -- Goal: ∀ s, t ≤ s → (∀ r, s ≤ r → truth_at M τ r φ)
  intro s hts r hsr
  -- Need to show: truth_at M τ r φ
  -- We have: t ≤ s and s ≤ r, so t ≤ r
  have htr : t ≤ r := le_trans hts hsr
  exact h_future r htr

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
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_phi
  -- h_phi : truth_at M τ t φ
  -- Goal: ∀ s, t < s → truth_at M τ s φ.sometime_past
  intro s hts
  -- Goal: truth_at M τ s φ.sometime_past
  -- With corrected definition: sometime_past φ = φ.neg.past.neg
  -- = (φ.neg).all_past.neg
  -- = ((φ.imp bot).all_past).imp bot

  -- truth_at ... φ.sometime_past
  -- = truth_at ... (φ.neg.past.neg)
  -- = truth_at ... ((φ.imp bot).all_past.imp bot)
  -- = (truth_at ... (φ.imp bot).all_past) → False
  -- = (∀ r, r < s → (truth_at ... φ → False)) → False

  -- We need to prove: (∀ r, r < s → (truth_at M τ r φ → False)) → False
  -- We have: h_phi : truth_at M τ t φ, and hts : t < s

  -- Assuming h : ∀ r, r < s → (truth_at M τ r φ → False)
  -- Then h t hts : truth_at M τ t φ → False
  -- And h t hts h_phi : False

  simp only [Formula.sometime_past, Formula.some_past, Formula.neg, truth_at]
  -- Goal: (∀ r, r < s → truth_at M τ r (φ.imp bot)) → False
  intro h_all_neg
  -- h_all_neg : ∀ r, r < s → truth_at M τ r (φ.imp bot)
  -- This says: for all r < s, ¬φ at r
  have h_neg_at_t := h_all_neg t hts
  -- h_neg_at_t : truth_at M τ t (φ.imp bot)
  -- = truth_at M τ t φ → truth_at M τ t bot
  -- = truth_at M τ t φ → False
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

theorem temp_l_valid (φ : Formula) :
    ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_always
  -- h_always : truth_at M τ t φ.always
  -- Since always φ = past φ ∧ (φ ∧ future φ), we need to unfold
  -- The premise gives us: φ at all past times, φ now, φ at all future times
  -- Goal: ∀ s, t < s → ∀ r, r < s → truth_at M τ r φ
  intro s hts r hrs
  -- We need: truth_at M τ r φ
  -- We know φ holds at ALL times from h_always
  -- Case split: either r < t (use past), r = t (use present), or r > t (use future)
  -- Since always φ = (past φ) ∧ φ ∧ (future φ), and h_always : truth_at for this conjunction
  -- We need to extract the conjunction parts

  -- Simplify h_always using conjunction encoding
  -- always φ = φ.all_past ∧ (φ ∧ φ.all_future) encoded as negated implications
  simp only [Formula.always, Formula.and, Formula.neg, truth_at] at h_always

  -- Extract using classical logic (conjunction encoded as ¬(P → ¬Q))
  have h1 :
    (∀ (u : T), u ≤ t → truth_at M Set.univ τ u φ) ∧
    ((truth_at M Set.univ τ t φ →
      (∀ (v : T), t ≤ v → truth_at M Set.univ τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1

  have h2 : truth_at M Set.univ τ t φ ∧ (∀ (v : T), t ≤ v → truth_at M Set.univ τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2

  -- Case split on whether r ≤ t or r > t
  by_cases h_le : r ≤ t
  · -- r ≤ t: use h_past
    exact h_past r h_le
  · -- r > t: use h_future
    push_neg at h_le
    exact h_future r (le_of_lt h_le)

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
  intro T _ _ _ F M τ t
  simp only [truth_at, Set.mem_univ, true_implies]
  intro h_box_phi
  -- h_box_phi : ∀ σ, truth_at M σ t φ
  -- Goal: ∀ σ, ∀ s, t < s → truth_at M σ s φ
  intro σ s hts
  -- We need: truth_at M σ s φ
  -- From h_box_phi: φ at all histories at time t

  -- Strategy: Use time-shift to relate (σ, s) to a history at time t
  -- time_shift σ (s - t) gives a history at time t (where t + (s - t) = s)

  -- Apply h_box_phi to the time-shifted history
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t))

  -- Use time-shift preservation to relate truth at (shifted, t) to truth at (σ, s)
  have h_preserve := TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed σ t s φ
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
  intro T _ _ _ F M τ t
  simp only [truth_at, Set.mem_univ, true_implies]
  intro h_box_phi
  -- h_box_phi : ∀ σ, truth_at M σ t φ
  -- Goal: ∀ s, t < s → ∀ σ, truth_at M σ s φ
  intro s hts σ
  -- We need: truth_at M σ s φ
  -- From h_box_phi: φ at all histories at time t

  -- Strategy: Use time-shift to relate (σ, s) to a history at time t
  -- time_shift σ (s - t) gives a history at time t

  -- Apply h_box_phi to the time-shifted history
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t))

  -- Use time-shift preservation to relate truth at (shifted, t) to truth at (σ, s)
  have h_preserve := TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed σ t s φ
  exact h_preserve.mp h_phi_at_shifted

/--
Temporal T axiom for future: `Gφ → φ` is valid in all task semantic models.

With reflexive semantics (Task #658), `all_future` quantifies over `t ≤ s`,
meaning "now and all future times". The T-axiom `Gφ → φ` is therefore trivially
valid: if φ holds at all s ≥ t, then in particular φ holds at t (via `le_refl t`).

**Paper Reference**: The JPL paper uses reflexive temporal operators (lines 1857-1872)
where Future quantifies over "y ∈ D where x ≤ y" (inclusive of present).
-/
theorem temp_t_future_valid (φ : Formula) : ⊨ ((Formula.all_future φ).imp φ) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_future
  -- h_future : ∀ s, t ≤ s → truth_at M τ s φ
  -- Goal: truth_at M τ t φ
  -- With reflexive semantics, we can apply h_future at s = t using le_refl
  exact h_future t (le_refl t)

/--
Temporal T axiom for past: `Hφ → φ` is valid in all task semantic models.

With reflexive semantics (Task #658), `all_past` quantifies over `s ≤ t`,
meaning "now and all past times". The T-axiom `Hφ → φ` is therefore trivially
valid: if φ holds at all s ≤ t, then in particular φ holds at t (via `le_refl t`).

**Paper Reference**: The JPL paper uses reflexive temporal operators (lines 1857-1872)
where Past quantifies over "y ∈ D where y ≤ x" (inclusive of present).
-/
theorem temp_t_past_valid (φ : Formula) : ⊨ ((Formula.all_past φ).imp φ) := by
  intro T _ _ _ F M τ t
  simp only [truth_at]
  intro h_past
  -- h_past : ∀ s, s ≤ t → truth_at M τ s φ
  -- Goal: truth_at M τ t φ
  -- With reflexive semantics, we can apply h_past at s = t using le_refl
  exact h_past t (le_refl t)

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
  | modal_5_collapse ψ => exact modal_5_collapse_valid ψ
  | ex_falso ψ => exact ex_falso_valid ψ
  | peirce φ ψ => exact peirce_valid φ ψ
  | modal_k_dist φ ψ => exact modal_k_dist_valid φ ψ
  | temp_k_dist φ ψ => exact temp_k_dist_valid φ ψ
  | temp_4 ψ => exact temp_4_valid ψ
  | temp_a ψ => exact temp_a_valid ψ
  | temp_l ψ => exact temp_l_valid ψ
  | temp_t_future ψ => exact temp_t_future_valid ψ
  | temp_t_past ψ => exact temp_t_past_valid ψ
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
    intro T _ _ _ F M τ t _
    exact axiom_valid h_ax T F M τ t

  | @assumption Γ' φ' h_mem =>
    -- Case: φ' ∈ Γ' (assumption)
    -- If all of Γ' true, then φ' (member of Γ') is true
    intro T _ _ _ F M τ t h_all
    exact h_all φ' h_mem

  | @modus_ponens Γ' φ' ψ' _ _ ih_imp ih_phi =>
    -- Case: From Γ' ⊢ φ' → ψ' and Γ' ⊢ φ', derive Γ' ⊢ ψ'
    -- By IH: Γ' ⊨ φ' → ψ' and Γ' ⊨ φ'
    -- Goal: Γ' ⊨ ψ'
    intro T _ _ _ F M τ t h_all
    have h_imp := ih_imp T F M τ t h_all
    have h_phi := ih_phi T F M τ t h_all
    simp only [truth_at] at h_imp
    exact h_imp h_phi

  | @necessitation φ' h_deriv ih =>
    -- Case: From [] ⊢ φ', derive [] ⊢ □φ'
    -- IH: [] ⊨ φ' (φ' is valid)
    -- Goal: [] ⊨ □φ' (□φ' is valid)
    intro T _ _ _ F M τ t _
    simp only [truth_at, Set.mem_univ, true_implies]
    -- Goal: ∀ σ, truth_at M σ t φ'
    intro σ
    -- Use IH: φ' is valid, so true at all models
    exact ih T F M σ t (fun _ h => False.elim (List.not_mem_nil h))

  | @temporal_necessitation φ' h_deriv ih =>
    -- Case: From [] ⊢ φ', derive [] ⊢ Fφ'
    -- IH: [] ⊨ φ' (φ' is valid)
    -- Goal: [] ⊨ Fφ' (Fφ' is valid)
    intro T _ _ _ F M τ t _
    simp only [truth_at]
    -- Goal: ∀ s, t < s → truth_at M τ s φ'
    intro s hts
    -- Use IH: φ' is valid, so true at all models
    exact ih T F M τ s (fun _ h => False.elim (List.not_mem_nil h))

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
    intro T _ _ _ F M τ t _
    -- Goal: truth_at M τ t (swap_past_future φ')
    -- Use derivable_implies_swap_valid which proves: Derivable [] φ' → is_valid φ'.swap
    have h_swap_valid := @SoundnessLemmas.derivable_implies_swap_valid T _ _ _ _ h_deriv_phi
    -- h_swap_valid : is_valid T φ'.swap_past_future
    -- Unpack the local is_valid definition
    exact h_swap_valid F M τ t

  | @weakening Γ' Δ' φ' _ h_sub ih =>
    -- Case: From Γ' ⊢ φ' and Γ' ⊆ Δ', derive Δ' ⊢ φ'
    -- By IH: Γ' ⊨ φ'
    -- Goal: Δ' ⊨ φ'
    intro T _ _ _ F M τ t h_all
    apply ih T F M τ t
    intro ψ h_mem
    exact h_all ψ (h_sub h_mem)

end Bimodal.Metalogic
