# Teammate B Findings: Case C-hard Analysis

**Task**: 142 — mixed_case_countermodel
**Date**: 2026-05-15
**Focus**: Tracing the truth lemma for □(F'T) and □(U(T,⊥)) in the mixed case

## Key Finding: Case C-hard IS Fundamentally Blocked

After carefully tracing through the truth lemma code, Case C-hard is confirmed as a genuine, fundamental obstacle. Below is the detailed analysis.

## 1. Truth Lemma Structure for Box (lines 365-388)

The box case of `fully_restricted_parametric_shifted_truth_lemma` works as follows:

```
| box ψ ih =>
  -- h_sub : □ψ ∈ subformulaClosure(root)
  -- h_ψ_sub : ψ ∈ subformulaClosure(root) (by closure_box)
  
  Forward (mp): □ψ ∈ fam.mcs(t) → truth_at(□ψ)
    For each σ ∈ Omega, obtain fam' from σ's definition
    Use modal_forward: □ψ ∈ fam.mcs(t+delta) → ψ ∈ fam'.mcs(t+delta)
    Apply IH: ψ ∈ fam'.mcs(t+delta) → truth_at(ψ, fam', t+delta)
    Time-shift to get truth_at(ψ, σ, t)
    
  Backward (mpr): truth_at(□ψ) → □ψ ∈ fam.mcs(t)
    Build h_all_fam: ∀ fam' ∈ families, ψ ∈ fam'.mcs(t)
      For each fam': use parametricCanonicalOmega_subset_shiftClosed
      Then IH.mpr: truth_at(ψ, fam', t) → ψ ∈ fam'.mcs(t)
    Call B.modal_backward fam hfam ψ t h_all_fam
```

**Critical observation**: The backward direction constructs `h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t` by applying the IH at EVERY family `fam'` in the BFMCS. This means the truth lemma biconditional `ψ ∈ fam'.mcs(t) ↔ truth_at(ψ, fam', t)` must hold at every family, not just the eval family.

## 2. Tracing □(F'T) with a Mixed BFMCS on ℤ

Consider sub-case C2: U(T,⊥) ∈ A, D = ℤ, with a mixed BFMCS containing both dense and discrete families.

**Setup**: □(F'T) ∈ subformulaClosure(φ), so F'T ∈ subformulaClosure(φ), so U(T,⊥) ∈ subformulaClosure(φ).

The truth lemma is invoked for all formulas in subformulaClosure(root) at all families. Consider the chain:

### Step 1: Truth lemma for U(T,⊥) at a dense family

For a dense family fam_dense (root N with F'T ∈ N):
- U(T,⊥) ∈ subformulaClosure(root)
- The `untl` case (line 421) fires
- Forward direction: U(T,⊥) ∈ fam_dense.mcs(t) → truth_at(U(T,⊥))
  - But U(T,⊥) ∉ fam_dense.mcs(t) (F'T ∈ N means ¬U(T,⊥) ∈ N, uniformity propagates)
  - Premise is false → vacuously true ✓
- Backward direction: truth_at(U(T,⊥)) → U(T,⊥) ∈ fam_dense.mcs(t)
  - On ℤ: truth_at(U(T,⊥), fam_dense, t) = ∃ s > t, ⊤ at s ∧ ⊥ on (t,s)
  - On ℤ: (t, t+1) is empty, so s = t+1, ⊤ ∈ fam_dense.mcs(t+1) ✓, guard vacuous ✓
  - So truth_at(U(T,⊥)) = True on ℤ
  - But U(T,⊥) ∉ fam_dense.mcs(t) → need True → False. **BICONDITIONAL FAILS** ✗

**Wait** — let me re-check. The restricted_forward_until_since_coherent at line 429 says:
```
h_fwd_U t phi psi h_sub h_U
```
where `h_U : Formula.untl phi psi ∈ fam.mcs t`. For the forward direction, we need `U(T,⊥) ∈ fam_dense.mcs(t)` as a PREMISE. Since U(T,⊥) ∉ fam_dense.mcs(t), the forward direction is vacuously true.

For the backward direction: `truth_at(U(T,⊥), fam_dense, t) → U(T,⊥) ∈ fam_dense.mcs(t)`. The proof (line 433-436) calls `h_bwd_U t phi psi h_sub ⟨s, ...⟩` which is `restricted_backward_until_since_coherent`. This says: if there exists a witness s > t with phi at s and psi on guard, then U(T,⊥) ∈ fam.mcs(t).

On ℤ for fam_dense: truth_at(U(T,⊥)) = True (witness s = t+1 works). The backward proof gets a semantic witness s and converts it to MCS membership via IH:
- phi = top → top ∈ fam_dense.mcs(s) ✓ (top is in every MCS)  
- psi = bot → bot ∈ fam_dense.mcs(r) for all r ∈ (t, s). On ℤ, (t, t+1) = ∅, so vacuously true.

So the backward coherence provides: U(T,⊥) ∈ fam_dense.mcs(t). But we know U(T,⊥) ∉ fam_dense.mcs(t) (dense family has F'T = ¬U(T,⊥)). **This is a contradiction in the proof itself** — the backward coherence condition FORCES U(T,⊥) into the MCS, but the MCS doesn't contain it.

**This means**: `restricted_backward_until_since_coherent` CANNOT hold for the mixed BFMCS on ℤ at dense families for U(T,⊥). The backward coherence would force U(T,⊥) ∈ fam_dense.mcs(t), contradicting F'T ∈ fam_dense.mcs(t).

### Step 2: What about discrete-only BFMCS on ℤ?

With only discrete families on ℤ:
- U(T,⊥) ∈ fam.mcs(t) for all families, truth_at(U(T,⊥)) = True on ℤ ✓
- F'T ∉ fam.mcs(t) for all families, truth_at(F'T) = False on ℤ ✓

But now the box case for □(F'T):
- □(F'T) ∉ any family's MCS (mixed case: ¬□(F'T) ∈ A, box stability propagates)
- truth_at(□(F'T), fam, t) = ∀ σ ∈ Omega, truth_at(F'T, σ, t)
- truth_at(F'T) = False for all σ (discrete domain, F'T always false on ℤ)
- So truth_at(□(F'T)) = ∀ σ ∈ Omega, False

**CRITICAL**: Is Omega nonempty? Yes — by `B.nonempty`, there's at least one family, so at least one history in Omega. So `∀ σ ∈ Omega, False` = False.

- □(F'T) ∈ fam.mcs(t) ↔ truth_at(□(F'T)) becomes: False ↔ False. **This holds!** ✓

So the box case for □(F'T) with discrete-only BFMCS on ℤ is actually fine! The biconditional is False ↔ False.

### Step 3: But modal_backward breaks

The BFMCS modal_backward (line 105): ∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → □φ ∈ fam.mcs t.

For φ = U(T,⊥) with discrete-only families: ALL families have U(T,⊥) ∈ fam'.mcs(t). So the premise is True. Modal_backward gives □(U(T,⊥)) ∈ fam.mcs(t). But ¬□(U(T,⊥)) ∈ A (mixed case hypothesis), and box stability means □(U(T,⊥)) ∉ fam.mcs(t). **Contradiction** — the discrete-only BFMCS cannot satisfy modal_backward.

### Step 4: The restricted_modal_backward approach

As identified in the Case C deep-dive report: if we restrict modal_backward to subformulaClosure(root), the truth lemma proof still goes through (line 388 only calls modal_backward for ψ ∈ subformulaClosure(root)). 

**But for Case C-hard**: □(U(T,⊥)) ∈ subformulaClosure(φ) (or □(F'T) ∈ subformulaClosure(φ)). So the restricted modal_backward IS invoked for U(T,⊥) (or F'T). The discrete-only BFMCS fails restricted_modal_backward for U(T,⊥) because all families have U(T,⊥), making the premise True but □(U(T,⊥)) ∉ fam.mcs(t).

## 3. BX Interaction Axioms

The BX axiom system (Axioms.lean) has exactly ONE modal-temporal interaction axiom:

- `modal_future (φ)`: □φ → □(Gφ) (line 302)

This gives: □(F'T) → □(G(F'T)) and □(U(T,⊥)) → □(G(U(T,⊥))).

In the mixed case, ¬□(F'T) ∈ A and ¬□(U(T,⊥)) ∈ A. The interaction axiom's contrapositive:
- ¬□(G(F'T)) → ¬□(F'T) — but we already have ¬□(F'T), so this gives nothing new
- ◇(H(U(T,⊥))) → ◇(U(T,⊥)) — already have ◇(U(T,⊥))

No useful derivability shortcuts from the interaction axioms.

## 4. Analysis: Is Case C-hard Actually Empty?

Consider when □(F'T) ∈ subformulaClosure(φ). This means φ contains a subformula of the form `box(imp(untl(top, bot), bot))`. This is a very specific syntactic pattern.

Now, ¬φ ∈ A with ¬□(F'T) ∈ A (mixed case). Consider: does ¬□(F'T) interact with φ's structure?

If φ = □(F'T) ∧ p, then ¬φ = ¬□(F'T) ∨ ¬p. This is consistent with ¬□(F'T) ∈ A. The mixed case is reachable.

If φ = □(F'T), then ¬φ = ¬□(F'T). This is exactly the mixed case hypothesis. So ¬φ ∈ A is immediate. But we need to FALSIFY φ, i.e., build a model where truth_at(□(F'T)) = False. On ℤ: truth_at(F'T) = False at every history, so truth_at(□(F'T)) = ∀ σ, False = False (if Omega nonempty). So truth_at(φ) = False. **The countermodel works on ℤ with ANY nonempty BFMCS!**

Wait — we don't need the truth lemma for this specific φ = □(F'T). We just need to show ¬truth_at(□(F'T), τ, t) in the countermodel. On ℤ, this is immediate: truth_at(F'T) = False for any history, so truth_at(□(F'T)) = False for any nonempty Omega.

But the general case is: φ is an arbitrary formula containing □(F'T) as a subformula. We need truth_at(φ) to match the MCS at the eval family. The truth lemma must hold for ALL subformulas of φ, including □(F'T).

## 5. The Fundamental Obstruction

For Case C-hard with a MIXED BFMCS (containing both dense and discrete families):

**On ℤ**: The backward Until/Since coherence at dense families forces U(T,⊥) into dense MCS's (because on ℤ, the Until witness s = t+1 always exists with vacuous guard). But dense MCS's don't have U(T,⊥). **Contradiction.**

**On ℚ**: The backward Until/Since coherence at discrete families would need a witness for U(T,⊥), but ℚ is dense — no immediate successor. The coherence condition can't be satisfied. **Failure.**

Both require the Until coherence to be correct at the "wrong type" families, which is impossible.

For SINGLE-TYPE BFMCS: modal_backward (even restricted) fails for the density markers because all families agree on them, contradicting the mixed-case hypothesis ¬□(marker) ∈ A.

## 6. Possible Resolution Paths for Case C-hard

### Path A: Semantic argument bypassing BFMCS

For φ containing □(F'T) as a subformula: build the countermodel DIRECTLY without the BFMCS truth lemma. On ℤ, truth_at(F'T) = False everywhere, so truth_at(□(F'T)) = False. The truth of the surrounding formula context determines whether truth_at(φ) = False overall. This requires formula-structural analysis rather than the generic truth lemma.

### Path B: Show restricted_backward_until_since_coherent can be weakened further

The backward Until coherence (line 433-436) converts semantic witnesses to MCS membership. What if we DON'T need the backward direction? The truth lemma uses both directions. But the backward direction for U(T,⊥) says: if truth_at(U(T,⊥)) then U(T,⊥) ∈ fam.mcs(t). On ℤ, truth_at(U(T,⊥)) = True at ALL families. For dense families, U(T,⊥) ∉ fam.mcs(t). So the backward truth lemma for U(T,⊥) FAILS at dense families.

The forward truth lemma for U(T,⊥) at dense families is fine (vacuously true — U(T,⊥) ∉ fam.mcs(t) makes the premise false).

So the biconditional `U(T,⊥) ∈ fam_dense.mcs(t) ↔ truth_at(U(T,⊥))` is `False ↔ True` = **False**. The truth lemma fails.

### Path C: Accept that "wrong type" families have incorrect truth for density markers

The truth lemma fails for U(T,⊥) at dense families on ℤ. But do we actually NEED the truth lemma for U(T,⊥) at dense families? Only if the box case for some □ψ forces evaluation of U(T,⊥) at dense families.

The box case calls IH at ALL families. If □ψ ∈ subformulaClosure(φ) and ψ's subtree includes U(T,⊥), the IH for ψ at dense families eventually reaches the `untl` case for U(T,⊥). The backward direction of this `untl` case fails at dense families on ℤ.

The question is: does any □ψ ∈ subformulaClosure(φ) have ψ's subtree include U(T,⊥)?

If □(F'T) ∈ subformulaClosure(φ): ψ = F'T = imp(U(T,⊥), bot). So ψ's subtree includes U(T,⊥). The imp case (line 330) calls IH for U(T,⊥) at ALL families. At dense families on ℤ, the untl case for U(T,⊥) backward fails. **Confirmed blocked.**

## 7. Summary

| Scenario | Domain | Families | Obstacle | Status |
|----------|--------|----------|----------|--------|
| Mixed BFMCS on ℤ | ℤ | Both | backward_until_since_coherent for U(T,⊥) at dense families | ❌ |
| Mixed BFMCS on ℚ | ℚ | Both | forward_until_since_coherent for U(T,⊥) at discrete families | ❌ |
| Discrete-only on ℤ | ℤ | Discrete | modal_backward for U(T,⊥) (all agree → □(U(T,⊥)) derived, contradicts ¬□(U(T,⊥))) | ❌ |
| Dense-only on ℚ | ℚ | Dense | modal_backward for F'T (all agree → □(F'T) derived, contradicts ¬□(F'T)) | ❌ |
| Restricted modal_backward | Either | Single | Restricted modal_backward invoked for U(T,⊥) or F'T when □(marker) ∈ subformulaClosure(φ) | ❌ |

**Case C-hard is genuinely blocked** within the current BFMCS + restricted truth lemma architecture. No choice of D, family composition, or modal_backward restriction resolves it when □(F'T) or □(U(T,⊥)) is literally a subformula of φ.

## Confidence Level

**High** — the analysis traces the exact proof lines and identifies specific points where the biconditional fails. The obstruction is structural, not a matter of missing infrastructure.
