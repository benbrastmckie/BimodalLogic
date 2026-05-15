# Teammate A Findings: Box Truth Lemma Deep Analysis

**Task**: 142 — mixed_case_countermodel (Case C-hard)
**Focus**: How the Box case works in the restricted truth lemma
**Date**: 2026-05-15

## 1. Truth Lemma Architecture

### 1.1 Induction Structure
The `fully_restricted_parametric_shifted_truth_lemma` (RestrictedParametricTruthLemma.lean:302-452) is proved by structural induction on formula `φ` (`induction φ generalizing fam t`). The cases are: atom, bot, imp, box, all_future, all_past, untl, snce.

The theorem proves: `φ ∈ fam.mcs t ↔ truth_at ... (parametric_to_history fam) t φ`
for ALL `fam ∈ B.families` and ALL `t : D`, provided `φ ∈ subformulaClosure root`.

### 1.2 Hypotheses Required
- `B : BFMCS D` — with full `modal_forward` and `modal_backward` (unrestricted over ALL φ)
- `h_rtc : B.restricted_temporally_coherent root` — forward_F/backward_P for deferralClosure only
- `h_buc : B.restricted_backward_until_since_coherent root` — backward Until/Since for subformulaClosure only
- `h_fuc : B.restricted_forward_until_since_coherent root` — forward Until/Since for subformulaClosure only

### 1.3 Omega Construction
- `ShiftClosedParametricCanonicalOmega B` (ParametricHistory.lean:115-118): the set of ALL time-shifts of `parametric_to_history fam` for every `fam ∈ B.families`
- Box semantics: `truth_at(□φ) = ∀ σ ∈ Omega, truth_at(φ, σ, t)` (Truth.lean:124) — quantifies over ALL of Omega, NOT task_rel-restricted

## 2. Box Case Analysis (Lines 365-388)

### 2.1 Forward Direction (□ψ ∈ mcs → truth_at)
```lean
· intro h_box σ h_σ_mem
  obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
  have h_box_shifted : Formula.box ψ ∈ fam.mcs (t + delta) := ...
  have h_ψ_fam' : ψ ∈ fam'.mcs (t + delta) := B.modal_forward ...
  have h_truth_canon := (ih h_ψ_sub fam' hfam' (t + delta)).mp h_ψ_fam'
  ...
```
Uses: `modal_forward` (unrestricted) + IH at fam' (which must be in subformulaClosure since ψ ∈ subformulaClosure from □ψ)

### 2.2 Backward Direction (truth_at → □ψ ∈ mcs)
```lean
· intro h_all_σ
  have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
    intro fam' hfam'
    have h_mem := parametricCanonicalOmega_subset_shiftClosed B ⟨fam', hfam', rfl⟩
    exact (ih h_ψ_sub fam' hfam' t).mpr (h_all_σ (parametric_to_history fam') h_mem)
  exact B.modal_backward fam hfam ψ t h_all_fam
```
Uses: IH.mpr at EVERY `fam' ∈ B.families` + `modal_backward` (unrestricted)

## 3. Key Question 1: Box Quantifies Over ALL of Omega

**Answer**: Yes, box quantifies over ALL σ ∈ Omega (Truth.lean:124). Omega = ShiftClosedParametricCanonicalOmega, which contains all time-shifts of all families. There is no task_rel restriction — the S5 modality has universal accessibility within the bundle.

## 4. Key Question 2: Heterogeneous Omega

**Answer**: Omega is parametric in D — all histories share the same domain type D. On ℤ, all histories map ℤ → MCS. On ℚ, all histories map ℚ → MCS. There's no way to have some histories on ℚ and others on ℤ within a single Omega.

## 5. Key Question 3: Vacuity Analysis for Case C-hard — THE BREAKTHROUGH

### 5.1 Setup
In the mixed case: ¬□(F'T) ∈ A and ¬□(U(T,⊥)) ∈ A. By box stability, □(F'T) ∉ fam.mcs(t) and □(U(T,⊥)) ∉ fam.mcs(t) for ALL families at ALL times.

### 5.2 Box Case for □(F'T) on ℤ with Discrete-Only Families

**Forward**: □(F'T) ∈ fam.mcs(t) → ... Premise is False (□(F'T) ∉ any fam.mcs(t)). Vacuously true. ✓

**Backward**: (∀ σ ∈ Omega, truth_at(F'T, σ, t)) → □(F'T) ∈ fam.mcs(t). On ℤ, truth_at(F'T) = truth_at(¬U(T,⊥)) = ¬True = False for any σ. Since Omega is nonempty, the universal quantifier gives False. Premise is False. Vacuously true. ✓

**Biconditional**: □(F'T) ∈ fam.mcs(t) [= False] ↔ truth_at(□(F'T)) [= False]. TRUE ✓

### 5.3 Box Case for □(U(T,⊥)) on ℤ with Discrete-Only Families

**Forward**: □(U(T,⊥)) ∈ fam.mcs(t) → ... Premise is False. Vacuously true. ✓

**Backward**: (∀ σ ∈ Omega, truth_at(U(T,⊥), σ, t)) → □(U(T,⊥)) ∈ fam.mcs(t). On ℤ, truth_at(U(T,⊥)) = True for all σ. Premise is True. Conclusion: □(U(T,⊥)) ∈ fam.mcs(t). But □(U(T,⊥)) ∉ fam.mcs(t) (mixed case). **The backward direction produces a false conclusion from a true premise!**

**Biconditional**: False ↔ True = **FALSE — FAILS** ✗

### 5.4 The Real Problem: Not the Boxed Markers, but the Un-Boxed Ones at Wrong-Type Families

The box case for boxed density markers works via vacuity when both directions have matching truth values. The failure occurs at the NON-boxed level:

**U(T,⊥) at a dense family on ℤ** (untl case, lines 420-436):
- Forward (restricted_forward): U(T,⊥) ∈ fam'.mcs(t) → witness. But U(T,⊥) ∉ dense fam'.mcs(t). Premise false → vacuously true ✓
- **Backward (restricted_backward)**: (∃ s > t, ⊤ at s ∧ ⊥ on guard(t,s)) → U(T,⊥) ∈ fam'.mcs(t). On ℤ, s = t+1 is a valid witness (empty guard). Premise TRUE. Conclusion U(T,⊥) ∈ fam'.mcs(t) is FALSE. **FAILS** ✗

**F'T at a discrete family on ℚ** (imp case):
- F'T = imp(U(T,⊥), bot). The imp case calls IH for U(T,⊥) and bot.
- At discrete families on ℚ: U(T,⊥) ∈ fam'.mcs(t) = True. truth_at(U(T,⊥)) on ℚ = False (no immediate successors). IH: True ↔ False = **FALSE — FAILS** ✗

### 5.5 But the Backward Until Coherence Is RESTRICTED

The `restricted_backward_until_since_coherent` (TemporalCoherence.lean:565-574) only triggers for `untl φ ψ ∈ subformulaClosure root`. If U(T,⊥) ∉ subformulaClosure(root), the backward direction for U(T,⊥) is never tested, and the truth lemma's untl case never fires for U(T,⊥).

**But in Case C-hard**, U(T,⊥) IS in subformulaClosure(φ). So the backward untl case DOES fire.

### 5.6 Can We Use ℤ with a Mixed BFMCS?

With BOTH dense and discrete families on ℤ:
- □(F'T) truth: ∀ σ, truth_at(F'T, σ, t). Discrete σ gives False → □(F'T) False. Matches ¬□(F'T) ∈ A ✓
- □(U(T,⊥)) truth: ∀ σ, truth_at(U(T,⊥), σ, t) = True for all σ on ℤ. But with dense families also on ℤ, truth_at(U(T,⊥)) is STILL True (ℤ has immediate successors regardless of the family's MCS content). So □(U(T,⊥)) = True. But ¬□(U(T,⊥)) ∈ A. **Mismatch**. ✗

The problem: on ℤ, truth_at(U(T,⊥)) is determined by the DOMAIN's successor structure, not by the family's MCS. All families on ℤ give truth_at(U(T,⊥)) = True, making □(U(T,⊥)) = True, contradicting the mixed case.

Similarly on ℚ: truth_at(F'T) = True for ALL families, making □(F'T) = True, contradicting the mixed case.

## 6. The Fundamental Impossibility

**On any single ordered abelian group D**:
- Either U(T,⊥) is always semantically true (discrete D) → □(U(T,⊥)) = True → contradicts ¬□(U(T,⊥)) ∈ A
- Or U(T,⊥) is always semantically false (dense D) → the IH for U(T,⊥) at discrete families fails

**This means: no BFMCS on any single ordered abelian group D can satisfy the truth lemma for φ containing BOTH U(T,⊥) and □(U(T,⊥)) or □(F'T) as subformulas in the mixed case.**

The issue is that truth_at for Until formulas depends on the DOMAIN's order structure, not just the MCS assignment. On any fixed D, the truth value of U(T,⊥) is uniform across all histories — it's a property of D itself, not of the specific history.

## 7. Implications for Case C-hard

Case C-hard (□(F'T) or □(U(T,⊥)) ∈ subformulaClosure(φ)) is **fundamentally blocked within the current TaskFrame/BFMCS architecture**. The problem is not the BFMCS construction — it's the semantics of truth_at, which ties Until truth to the domain's order structure.

Possible resolutions:
1. **Show Case C-hard formulas have special derivability properties** in the mixed case (e.g., ¬φ is derivable when φ contains □(F'T) and the mixed case hypotheses hold)
2. **Change the semantics** so that truth_at(U(T,⊥)) depends on the history rather than the domain
3. **Use a non-standard domain** (not an ordered abelian group) that has mixed density
4. **Accept as a known limitation** — Case C-hard is a very narrow class (φ must literally contain □(F'T) or □(U(T,⊥)))

## 8. Confidence Level

**High** for the impossibility result. The analysis traces through the actual Lean code line by line and identifies the precise failure point: the backward direction of restricted_backward_until_since_coherent for U(T,⊥) at wrong-type families, and the uniformity of truth_at(U(T,⊥)) across all histories on a fixed domain.
