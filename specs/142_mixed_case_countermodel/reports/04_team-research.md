# Research Report: Task #142 — Case C-hard Deep Dive

**Task**: 142 — mixed_case_countermodel
**Date**: 2026-05-15
**Mode**: Team Research (4 teammates)
**Session**: sess_1778874808_368bdb

## Summary

Four parallel investigators independently converged on a fundamental discovery: **the mixed case is not a construction problem but a completeness gap in the axiom system BX**.

The formula □(U(T,⊥)) ∨ □(F'T) is **semantically valid** on all TaskFrame models (because any ordered abelian group is either globally dense or globally discrete) but **not derivable in BX** (because box doesn't distribute over disjunction and BX lacks a cross-world uniformity axiom). This means the mixed case (¬□(F'T) ∧ ¬□(U(T,⊥)) ∈ A) is BX-consistent but TaskFrame-unsatisfiable — no countermodel can be built because none exists.

**Prior research error corrected**: Report 01 (Section 3.1) claimed the mixed case is satisfiable by constructing a model on ℚ with two histories having different temporal types. This argument was **wrong** — U(T,⊥) is a structural property of the domain D (existence of immediate successor), not controllable via atom valuations. On ℚ, U(T,⊥) is false at every point in every history, regardless of the valuation.

**Recommended resolution**: Add □(U(T,⊥)) ∨ □(F'T) (or equivalently U(T,⊥) → □(U(T,⊥))) as a new BX axiom. It is sound, captures a genuine semantic property of ordered abelian groups, eliminates the mixed case entirely, and resolves the sorry via `False.elim`. Estimated effort: 5-10 hours.

## Key Findings

### 1. □(U(T,⊥)) ∨ □(F'T) Is Valid on All TaskFrame Models (Teammates C, D)

**Proof**: On any D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`:
- `truth_at(U(T,⊥), M, Omega, τ, t)` = "t has an immediate successor in D" — depends ONLY on D's order structure, not on τ, Omega, or M
- By translation invariance of ordered abelian groups: either EVERY element has an immediate successor (discrete D → □(U(T,⊥)) true) or NO element does (dense D → □(F'T) true)
- The dichotomy is exhaustive, so □(U(T,⊥)) ∨ □(F'T) holds in every model

Confirmed by soundness infrastructure: Soundness.lean:764-843 uses the same translation-invariance argument for the uniformity axioms.

### 2. □(U(T,⊥)) ∨ □(F'T) Is Not BX-Derivable (Teammates C, D)

BX lacks any axiom connecting U(T,⊥) to □(U(T,⊥)):
- Uniformity axioms give U(T,⊥) → G(U(T,⊥)) (temporal propagation within ONE history)
- MF gives □φ → □(Gφ) (preserves boxed formulas temporally)
- But NO axiom of the form φ → □φ (even for structural formulas)
- □(A ∨ B) → □A ∨ □B is invalid in all normal modal logics
- S5 gives ◇φ → □◇φ, NOT ◇φ → □φ

BX was designed for completeness over ALL linear orders (including mixed-density ones). The TaskFrame requirement of an ordered abelian group is STRONGER — it forces temporal uniformity across the modal dimension. The missing axiom captures this additional constraint.

**Note**: The non-derivability claim has HIGH confidence (based on standard modal logic reasoning) but is not formally verified in Lean. A formal verification would require constructing a Kripke model of BX where the formula is false — e.g., an Ockhamist frame with dense and discrete branches.

### 3. The Box Case Itself Is Not the Blocker (Teammate A)

Contrary to initial expectations, the truth lemma's box case for □(F'T) actually has matching values in the mixed case:
- □(F'T) ∉ fam.mcs(t) (by box stability + ¬□(F'T) ∈ A)
- truth_at(□(F'T)) = False on ℤ (F'T false at every point → box false)
- Biconditional: False ↔ False = True ✓

**The real blocker** is the Until backward coherence at "wrong type" families, triggered when the box case's IH descends through imp → untl and encounters U(T,⊥) at every family. On ℤ at dense families: U(T,⊥) ∉ fam.mcs(t) but truth_at(U(T,⊥)) = True (every integer has successor). This mismatch is structural and unfixable.

### 4. Case C-hard Is Semantically Impossible (Teammates B, D)

When BOTH □(F'T) and □(U(T,⊥)) are in subformulaClosure(φ):
- The truth lemma requires truth_at(□(F'T)) = False AND truth_at(□(U(T,⊥))) = False
- But on any D: truth_at(□(U(T,⊥))) ∨ truth_at(□(F'T)) = True
- So both cannot be False simultaneously — the countermodel CANNOT EXIST

When only ONE boxed density marker is in subformulaClosure(φ):
- Use the matching D (ℤ for □(F'T), ℚ for □(U(T,⊥)))
- The other marker's truth lemma is never checked
- With restricted_modal_backward: solvable (see Report 03)

### 5. Prior Research Error (Teammate C)

Report 01 (Section 3.1) claimed: "Consider a TaskFrame model on ℚ with two histories: tau1 with U(T,⊥) satisfied, tau2 with F'T satisfied." This is **impossible** — U(T,⊥) at (tau1, t) requires t to have an immediate successor in D = ℚ, but no rational has an immediate successor. The claim confused MCS formula membership (syntactic) with semantic truth (determined by D's order structure).

## Synthesis

### Conflicts Resolved

All four teammates converged independently. No conflicts.

### The Complete Picture

The mixed case sorry has been misdiagnosed for the entire research history of this task:
- It was framed as "how to build a countermodel on a single domain D for mixed-type families"
- The real issue is that **no such countermodel exists** — the mixed case hypotheses are semantically unsatisfiable
- BX is genuinely incomplete for TaskFrame semantics — it's missing an axiom that captures the ordered abelian group's temporal uniformity

### Recommended Resolution: Add Structural Axiom

**Add □(U(T,⊥)) ∨ □(F'T) as a new BX axiom.** This is mathematically the correct solution because:

1. **It's sound**: Valid on all TaskFrame models (proved by ordered abelian group dichotomy)
2. **It captures a genuine semantic property**: The domain's density/discreteness is uniform across all histories
3. **It eliminates the mixed case**: Every MCS has □(F'T) or □(U(T,⊥)), so the three-way split becomes two-way
4. **The sorry becomes `False.elim`**: Mixed case hypotheses ¬□(F'T) ∧ ¬□(U(T,⊥)) contradict the new axiom
5. **It's not a hack**: The axiom is a theorem of ordered abelian group theory that was missing from the axiomatization

**Alternative formulations** (all equivalent in the presence of S5 + uniformity):
- `U(T,⊥) → □(U(T,⊥))` — "discreteness is necessary" (strongest individual axiom)
- `F'T → □(F'T)` — "density is necessary"
- `□(U(T,⊥)) ∨ □(F'T)` — direct disjunction
- `¬□(U(T,⊥)) → □(F'T)` — contrapositive form

**Implementation plan**:
1. Add axiom constructor to Axioms.lean (1h)
2. Prove soundness in Soundness.lean using translation-invariance (2-3h)
3. Modify Completeness.lean: eliminate the mixed case branch with `False.elim` (1-2h)
4. Remove the sorry `dd_countermodel_chronicle_mixed_sorry` from ChronicleToCountermodel.lean (0.5h)
5. Update axiom audit comments, frame class classification (1h)
6. Verify `lake build` passes, check `#print axioms bx_completeness` (0.5h)

**Total estimated effort: 6-8 hours**

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | Box truth lemma | completed | Box case itself is fine; real blocker is Until coherence at wrong-type families |
| B | Case C-hard trace | completed | Confirmed structural impossibility; specific line-by-line proof trace |
| C | Alternative approaches | completed | Validity proof; prior research error identified; substitution analysis |
| D | MCS analysis | completed | Completeness gap identification; axiom recommendation; implementation plan |

## Open Questions

1. **Formal verification of non-derivability**: Is □(U(T,⊥)) ∨ □(F'T) provably NOT a BX theorem? A countermodel on a non-group linear order (Ockhamist frame with mixed branches) would settle this. LOW priority — the resolution works regardless.

2. **Other completeness gaps**: Are there additional valid-but-underivable formulas for TaskFrame semantics? A systematic analysis would be valuable but is out of scope for task 142.

3. **Impact on decidability module**: The new axiom is sound, so existing derivations remain valid. The FMP/decidability module may need the axiom added to its axiom set. Needs checking.

4. **Frame class classification**: Should the new axiom be classified as `Base` (included in all frame classes) or as a separate `Group` class? Since it's only valid on ordered abelian groups (not all linear orders), a new classification may be appropriate.
