# Teammate D Findings: Case C-hard — Fundamental Analysis

**Task**: 142 — mixed_case_countermodel
**Date**: 2026-05-15
**Focus**: MCS-level analysis of Case C-hard

## Key Finding: □(U(T,⊥)) ∨ □(F'T) Is Semantically Valid but NOT BX-Derivable

### The Semantic Validity

On ANY TaskFrame model (D with AddCommGroup + LinearOrder + IsOrderedAddMonoid + Nontrivial, nonempty Omega):

- If D is discrete (has least positive element ε): U(T,⊥) is True at every (τ, t). So □(U(T,⊥)) = ∀ σ ∈ Omega, U(T,⊥) at σ = True. Hence □(U(T,⊥)) ∨ □(F'T) is True.
- If D is dense (no least positive element): F'T is True at every (τ, t). So □(F'T) is True.

The dichotomy is exhaustive for ordered abelian groups (translation invariance forces global density or global discreteness). So `□(U(T,⊥)) ∨ □(F'T)` is valid in ALL TaskFrame models.

The soundness proofs in Soundness.lean:764-843 confirm: U(T,⊥) truth depends only on D (via group translation invariance), not on the model, history, or valuation.

### The Non-Derivability

BX cannot derive □(U(T,⊥)) ∨ □(F'T). The derivability analysis:

1. **□(U(T,⊥) ∨ F'T)** IS derivable: U(T,⊥) ∨ F'T is a tautology → necessitation gives □(U(T,⊥) ∨ F'T).
2. **□(A ∨ B) → □A ∨ □B** is NOT valid in any normal modal logic.
3. The uniformity axioms (propagation) give U(T,⊥) → G(U(T,⊥)) ∧ H(U(T,⊥)), meaning U(T,⊥) is temporally uniform within each history. But temporal uniformity does NOT transfer across the modal dimension.
4. The interaction axiom MF (□φ → □(Gφ)) only preserves box formulas temporally — it doesn't help derive new box formulas from unboxed ones.
5. Specifically: ◇(U(T,⊥)) (U(T,⊥) holds in some world) does NOT imply □(U(T,⊥)) (U(T,⊥) in all worlds) — the S5 axioms only give ◇φ → □◇φ, not ◇φ → □φ.

### Implication: BX Is Incomplete for TaskFrame Semantics

The formula □(U(T,⊥)) ∨ □(F'T) is:
- **Semantically valid**: True in every TaskFrame model (by the ordered abelian group dichotomy)
- **NOT BX-derivable**: The proof system lacks the cross-world uniformity axiom

This means BX is **incomplete** for TaskFrame semantics — there exist valid formulas that BX cannot derive. The mixed case `¬□(F'T) ∧ ¬□(U(T,⊥)) ∈ A` is syntactically consistent (no BX contradiction derivable) but semantically unsatisfiable (no TaskFrame model exists where both conjuncts are true).

## Case C-hard Analysis

### Why Case C-hard is Impossible Within Current Architecture

When BOTH □(F'T) and □(U(T,⊥)) are in subformulaClosure(φ):

The restricted truth lemma needs truth_at(□(F'T)) ↔ □(F'T) ∈ fam.mcs(t) AND truth_at(□(U(T,⊥))) ↔ □(U(T,⊥)) ∈ fam.mcs(t).

In the mixed case: □(F'T) ∉ A and □(U(T,⊥)) ∉ A (by box stability, □(F'T) ∉ fam.mcs(t) and □(U(T,⊥)) ∉ fam.mcs(t)). So the truth lemma requires truth_at(□(F'T)) = False AND truth_at(□(U(T,⊥))) = False.

But on any D: truth_at(□(U(T,⊥))) ∨ truth_at(□(F'T)) = True (one density marker is True everywhere, so its box is True). Hence truth_at(□(F'T)) = False AND truth_at(□(U(T,⊥))) = False is **semantically impossible**.

### When Only ONE Boxed Density Marker Is Present

If □(F'T) ∈ subformulaClosure(φ) but □(U(T,⊥)) ∉ subformulaClosure(φ):
- Use D = ℤ (discrete)
- truth_at(□(F'T)) = ∀ σ ∈ Omega, truth_at(F'T, σ) = ∀ σ, False = False (nonempty Omega)
- □(F'T) ∉ fam.mcs(t): True (¬□(F'T) ∈ A)
- Truth lemma: False ↔ False = True ✓
- truth_at(□(U(T,⊥))) is never checked (□(U(T,⊥)) ∉ subformulaClosure(φ))
- With restricted_modal_backward scoped to subformulaClosure(φ): modal_backward for U(T,⊥) is NOT invoked (□(U(T,⊥)) ∉ closure). The contradiction from all-discrete families having U(T,⊥) doesn't arise ✓

Similarly for □(U(T,⊥)) ∈ subformulaClosure(φ) but □(F'T) ∉: use D = ℚ.

**So the only truly impossible case is when BOTH □(F'T) AND □(U(T,⊥)) appear as literal subformulas of φ.**

## The Resolution: The Mixed Case Is a Completeness Gap, Not a Sorry Bug

### Argument

If φ contains BOTH □(F'T) and □(U(T,⊥)) as subformulas, and the completeness proof enters the mixed case (¬□(F'T) ∧ ¬□(U(T,⊥)) ∈ A), then:

1. ¬□(F'T) ∈ A and ¬□(U(T,⊥)) ∈ A (mixed case)
2. □(U(T,⊥)) ∉ A and □(F'T) ∉ A (by MCS consistency)
3. But □(U(T,⊥)) ∨ □(F'T) is valid in ALL TaskFrame models
4. If BX were complete, □(U(T,⊥)) ∨ □(F'T) would be derivable → ¬(□(U(T,⊥)) ∨ □(F'T)) inconsistent → the mixed case could NOT arise for ANY φ
5. Since BX CANNOT derive □(U(T,⊥)) ∨ □(F'T), the mixed case is a syntactic possibility that corresponds to no semantic model

The sorry in `dd_countermodel_chronicle_mixed_sorry` asks to construct a countermodel for φ in the mixed case. But when both □(F'T) and □(U(T,⊥)) are in subformulaClosure(φ), no such countermodel exists ON TASKFRAME MODELS.

The completeness proof cannot provide a countermodel because the formula's negation, combined with the mixed-case hypotheses, creates a semantic configuration that's unsatisfiable on TaskFrame models.

### Three Options for Resolution

**Option A: Add the Axiom □(U(T,⊥)) ∨ □(F'T)**

Add this as a new BX axiom. It is SOUND (valid on all TaskFrame models). Adding it eliminates the mixed case entirely: in any MCS, either □(F'T) ∈ A or □(U(T,⊥)) ∈ A. The three-way case split reduces to two cases (both already solved).

Pros: Clean, eliminates the sorry completely, sound.
Cons: Changes the proof system BX. May affect other results.
Effort: 3-5 hours (add axiom constructor, prove soundness, update case split).

**Option B: Prove Completeness for a Weaker Semantics**

Instead of TaskFrame (which forces AddCommGroup), use a weaker semantic structure that allows mixed-density domains (e.g., arbitrary linear orders without group structure). Then the mixed case has models. But this changes the semantics, not just the proof system.

**Option C: Prove Completeness for BX+Axiom, Note the Gap**

Prove that BX + □(U(T,⊥)) ∨ □(F'T) is complete for TaskFrame semantics. Note that BX itself is incomplete for TaskFrame semantics (the gap formula is □(U(T,⊥)) ∨ □(F'T)).

## Recommended Approach

**Option A is strongly recommended.** The axiom □(U(T,⊥)) ∨ □(F'T) is:
1. Semantically valid on ALL TaskFrame models (proved by the ordered abelian group dichotomy)
2. Captures a genuine semantic property (domain uniformity) that BX's existing axioms miss
3. Eliminates the mixed case entirely, making the sorry trivially resolvable
4. The soundness proof is straightforward (~20 lines, following the pattern of existing uniformity axioms)
5. The completeness proof only needs the existing dense and discrete cases

The fact that this axiom is valid but underivable represents a genuine **incompleteness** of BX for TaskFrame semantics. The axiom fixes this gap.

## Confidence Level

**HIGH** for the semantic analysis (the validity of □(U(T,⊥)) ∨ □(F'T) is a direct consequence of the ordered abelian group structure).

**MEDIUM** for the non-derivability claim (based on modal logic reasoning about □ not distributing over ∨, but not formally verified in Lean).

## Open Questions

1. **Is the non-derivability of □(U(T,⊥)) ∨ □(F'T) provable?** This would require showing the formula is false in some Kripke model of BX (not a TaskFrame model). Such a model would have accessible worlds with different temporal structures — e.g., an Ockhamist frame where some branches are dense and others discrete.

2. **Are there OTHER valid-but-underivable formulas for TaskFrame semantics?** The uniform density axiom may not be the only gap. A systematic analysis of the completeness of BX+axiom for TaskFrame semantics would be valuable.

3. **Does adding the axiom break any existing proofs?** Since the axiom is sound, it can only derive MORE theorems. Existing derivations remain valid. But if any existing proof relied on the non-derivability of certain formulas (e.g., decision procedures), this needs checking.
