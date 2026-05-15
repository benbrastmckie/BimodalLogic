# Teammate C Findings: Case C-hard — Fundamental Discovery

**Task**: 142 — mixed_case_countermodel
**Date**: 2026-05-15
**Role**: Alternative approaches for Case C-hard

## Executive Summary

**The mixed case sorry may be fundamentally unfillable as a countermodel construction.** The formula □(U(T,⊥)) ∨ □(F'T) is VALID in all TaskFrame models (on any ordered abelian group D, the domain is either dense or discrete) but appears to be NOT DERIVABLE in BX. If this is correct, the `bx_completeness` theorem as stated is TRUE but the current proof architecture (build countermodel in each branch) cannot work for the mixed case.

## Key Discovery: □(U(T,⊥)) ∨ □(F'T) Is Valid but Potentially Not a BX Theorem

### Validity Argument

On any `D : Type` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`:

**Fact**: In any ordered abelian group, either every element has an immediate successor (discrete) or no element does (dense). This follows from translation invariance: if d has immediate successor d + ε, then d' has immediate successor d' + ε for any d'.

**Consequence for truth_at**:
- `truth_at(U(T,⊥), M, Omega, τ, t)` = `∃ s > t, ∀ r ∈ (t,s), truth_at(⊥, ..., r)` = `∃ s > t, (t,s) is empty` = "t has an immediate successor in D"
- This is INDEPENDENT of τ, Omega, and M — it depends only on D's ordered structure
- On discrete D: `truth_at(U(T,⊥))` = True at all (τ, t). So `truth_at(□(U(T,⊥)))` = True.
- On dense D: `truth_at(U(T,⊥))` = False at all (τ, t). So `truth_at(□(F'T))` = True (since F'T = ¬U(T,⊥), always true on dense D).
- In both cases: `truth_at(□(U(T,⊥)) ∨ □(F'T))` = True.

Therefore `□(U(T,⊥)) ∨ □(F'T)` is valid in all TaskFrame models (confirmed at Validity.lean:73 definition).

### Non-Derivability Argument

The BX axiom system lacks any axiom connecting U(T,⊥) membership to □(U(T,⊥)):
- The uniformity axioms (discrete_propagate_fwd/bwd) give U(T,⊥) → G(U(T,⊥)) (temporal propagation within one history)
- MF gives □φ → □(Gφ) (box-future interaction)
- But there is NO axiom of the form φ → □φ (even for structural formulas)
- In S5: φ → □φ is NOT derivable (it's the "necessitation of contingent truths" — invalid)
- The formula U(T,⊥) → □(U(T,⊥)) IS valid on TaskFrame models (because U(T,⊥) is a structural property of D), but this validity comes from the ordered abelian group structure, not from general modal-temporal principles

The BX system is designed for completeness over ALL linear orders (not just ordered abelian groups). On a non-group linear order (e.g., a mixed-density countable order), the mixed case IS satisfiable — some histories can be dense while others are discrete. This is the model class that BX captures. The TaskFrame requirement of an ordered abelian group is STRONGER than what BX axiomatizes.

### Implications

If □(U(T,⊥)) ∨ □(F'T) is valid but not a BX theorem, then:
1. `¬□(U(T,⊥)) ∧ ¬□(F'T)` is BX-consistent (an MCS containing it exists)
2. `¬□(U(T,⊥)) ∧ ¬□(F'T)` is TaskFrame-unsatisfiable (no model on any ordered abelian group)
3. The `bx_completeness` proof cannot construct a countermodel in the mixed case
4. The theorem `valid φ → derivable` may still be TRUE but requires a different proof strategy

Specifically: if φ is valid (true in all TaskFrame models), is φ derivable in BX? This is TRUE if and only if BX proves everything valid on ordered abelian groups. The potential gap is formulas like □(U(T,⊥)) ∨ □(F'T) that are valid on groups but not on general linear orders.

## Prior Report Error

Report 01 (Section 3.1) claims the mixed case IS satisfiable by constructing a model on ℚ with two histories — one satisfying U(T,⊥) and another satisfying F'T. **This argument is WRONG**: U(T,⊥) is a structural property of D (existence of immediate successor), not dependent on history or atom valuation. On ℚ, U(T,⊥) is FALSE at every point in every history. You cannot make U(T,⊥) true on ℚ by choosing atoms differently.

The mixed case IS BX-consistent (provably, since □ doesn't distribute over ∨). But it is NOT TaskFrame-satisfiable.

## Approach Analysis

### Approach 1: FMP/Decidability Bridge
Not investigated per user constraint.

### Approach 2: Restructure Completeness Statement

**Option A**: Change `valid` to quantify over general linear orders instead of ordered abelian groups. Then the mixed case IS satisfiable and the countermodel construction would work. But this changes the mathematical content of the theorem.

**Option B**: Add □(U(T,⊥)) ∨ □(F'T) as an axiom (a "structural axiom" encoding the ordered abelian group property). Then the mixed case MCS is inconsistent and the sorry is trivially resolved. This axiom IS sound on all ordered abelian groups.

**Option C**: Prove completeness relative to frame class: valid-on-dense → derivable-with-density-axiom, valid-on-discrete → derivable-with-discreteness-axiom. This avoids the mixed case entirely.

### Approach 3: MCS Reduction (Substitution)

If φ contains □(F'T) as a subformula and ¬□(F'T) ∈ A: within the MCS A, □(F'T) is "false." We could try to simplify φ by replacing □(F'T) with ⊥.

**Analysis**: For specific cases this works:
- φ = p → □(F'T). Then ¬φ = p ∧ ¬□(F'T). The ¬□(F'T) is "already satisfied" by the mixed case. A countermodel for ¬p would suffice.
- φ = □(F'T) ∧ q. Then ¬φ = ¬□(F'T) ∨ ¬q. Since ¬□(F'T) ∈ A, ¬φ is satisfied.

But this approach requires a general theory of "substituting known truth values in MCS formulas" which is complex. And it still requires building a countermodel for the simplified formula.

### Approach 4: Burgess Construction Adaptation

Burgess's J0 completeness has no Box operator, so the mixed case doesn't arise. The BX extension adds Box (S5 modality). The mixed case is an artifact of combining S5 with ordered abelian group domains.

No adaptation of Burgess's construction can resolve the mixed case because the issue is not with the chronicle construction — it's with the SEMANTIC MISMATCH between BX (complete for all linear orders) and TaskFrame validity (restricted to ordered abelian groups).

## Recommended Resolution

### Option B (Add Structural Axiom) — Simplest and Most Direct

Add `□(U(T,⊥)) ∨ □(F'T)` (or equivalently `U(T,⊥) → □(U(T,⊥))`) as an axiom to the BX system. This:
1. Is sound on all ordered abelian group TaskFrame models (proved above)
2. Makes the mixed case MCS inconsistent (since it contains ¬□(U(T,⊥)) ∧ ¬□(F'T))
3. Eliminates the sorry ENTIRELY — the mixed case branch becomes `False.elim`
4. Doesn't change the completeness result's mathematical content (the axiom was already valid)
5. Requires: (a) adding the axiom constructor, (b) proving soundness, (c) showing the mixed case is impossible

**Effort**: ~5-10 hours
- Add axiom: 1 hour
- Prove soundness: 2-3 hours (straightforward from translation-invariance)
- Modify completeness proof: 2-3 hours
- Testing/cleanup: 1-2 hours

### Why This Is Correct

The BX system was designed for completeness over all linear orders. Our theorem claims completeness over TaskFrame models (ordered abelian groups). The gap between these model classes is exactly the mixed case. Adding the structural axiom closes this gap. The axiom is a THEOREM of ordered abelian group theory, not an arbitrary assumption.

## Confidence Level

**HIGH** for the validity argument (□(U(T,⊥)) ∨ □(F'T) is valid on all ordered abelian groups).

**MEDIUM-HIGH** for the non-derivability claim (□(U(T,⊥)) ∨ □(F'T) is not a BX theorem). This needs formal verification — it's based on the observation that BX lacks any axiom connecting U(T,⊥) to □(U(T,⊥)), but a subtle interaction between multiple axioms could potentially derive it.

**HIGH** for the recommended resolution (adding the structural axiom).

## Open Questions

1. **Is □(U(T,⊥)) ∨ □(F'T) actually derivable in BX?** I believe not, but this needs formal verification. A Lean proof attempt (try to derive it) or a countermodel on a non-group linear order would settle this.

2. **What is the minimal axiom needed?** Options: `U(T,⊥) → □(U(T,⊥))` (discreteness is necessary), or the full disjunction `□(U(T,⊥)) ∨ □(F'T)`, or `¬□(U(T,⊥)) → □(F'T)` (if not all-discrete, then all-dense).

3. **Does adding this axiom affect other parts of the codebase?** The axiom is sound, so soundness proofs remain valid. The decidability/FMP module might need updating. Derivation trees that use the new axiom would need the axiom constructor.

4. **Is there a more elegant formulation?** Perhaps the axiom should be `□(U(T,⊥) ∨ F'T) → □(U(T,⊥)) ∨ □(F'T)` (box distributes over this specific disjunction) which is derivable from `U(T,⊥) → □(U(T,⊥))` but looks more like a modal principle.
