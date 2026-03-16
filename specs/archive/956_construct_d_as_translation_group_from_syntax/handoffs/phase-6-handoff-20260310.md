# Handoff: Task 956 Phase 6 - Cantor Isomorphism Application

## Immediate Next Action
Prove CanonicalR irreflexivity using the IRR derivation rule (`DerivationTree.irr`). This is needed for NoMaxOrder on the antisymmetrized quotient `TimelineQuot`. Without it, Phase 6 is blocked.

## Current State
- **Phase 5**: COMPLETED with zero sorries. File: `DenseTimeline.lean`
  - Dense timeline construction with density-enriched staged build
  - All Cantor prerequisites proven EXCEPT NoMaxOrder/NoMinOrder on the quotient
  - Key theorems: `dense_timeline_has_intermediate`, `dense_timeline_has_future`, `dense_timeline_has_past`, `dense_timeline_countable`, `dense_timeline_nonempty`, linearity
- **Phase 6**: IN PROGRESS, blocked on NoMaxOrder
  - File started: `CantorApplication.lean` (has sorries for NoMaxOrder, NoMinOrder, DenselyOrdered)
  - Approach: `Antisymmetrization` from Mathlib gives LinearOrder on quotient
  - `Order.iso_of_countable_dense` requires: LinearOrder, Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty

## Blocker Analysis
The antisymmetrized quotient `TimelineQuot` = `Antisymmetrization DenseTimelineElem (le)` has:
- LinearOrder (from Antisymmetrization + total preorder) -- DONE
- Countable (from countability of dense timeline union) -- DONE
- Nonempty (from nonemptiness of dense timeline) -- DONE

Missing:
- **NoMaxOrder**: Requires that no quotient class is maximal. Blocked because:
  - A reflexive MCS (with CanonicalR(M, M)) may be maximal in the quotient
  - dense_timeline_has_future gives CanonicalR(p, q) but possibly also CanonicalR(q, p)
  - In that case [p] = [q] in the quotient, so q is not a strict successor
  - The Boneyard (`RestrictedFragment.lean:434-444`) documents this EXACT blocker

- **NoMinOrder**: Same issue, symmetric (reflexive MCS may be minimal)

- **DenselyOrdered**: Requires lifting density from dense timeline to quotient.
  dense_timeline_has_intermediate gives c with CanonicalR(a, c) and CanonicalR(c, b).
  But need [a] < [c] < [b] in the quotient, which requires strictness:
  NOT CanonicalR(c, a) and NOT CanonicalR(b, c). This is the same strictness gap.

## Resolution Strategy
The standard approach: prove CanonicalR irreflexivity using the Gabbay IRR rule.

**Theorem to prove**:
```lean
theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M
```

**Proof sketch**: Suppose CanonicalR(M, M), i.e., GContent(M) ⊆ M. Choose a fresh atom p. By IRR rule: from ⊢ (p ∧ H(¬p)) → φ (with p fresh in φ), conclude ⊢ φ.

Instantiate with appropriate φ to derive a contradiction within M.

**Key reference**: The IRR rule is at `Theories/Bimodal/ProofSystem/Derivation.lean:149`. Its signature:
```lean
| irr (p : String) (φ : Formula)
    (h_fresh : p ∉ φ.atoms)
    (d : DerivationTree [] ((Formula.and (Formula.atom p) (Formula.all_past (Formula.neg (Formula.atom p)))).imp φ)) :
    DerivationTree [] φ
```

The `atoms` function is at `Theories/Bimodal/Syntax/Formula.lean:502`.

**Alternative**: If CanonicalR irreflexivity is too hard to prove directly, the "bulldozing" approach (product domain T x Q where Q indexes copies) eliminates reflexive points. This was the v007 plan approach.

## Key Decisions Made
1. Phase 5 uses a "density-enriched" build (DenseTimeline.lean) that augments the base staged build with density_frame_condition intermediates at each stage
2. For Phase 6, Mathlib's `Antisymmetrization` type is used to get LinearOrder from the total preorder
3. Mathlib's `Order.iso_of_countable_dense` provides the Cantor isomorphism

## What NOT to Try
- Proving density at the base timeline level without modifying the construction (the base timeline's forward witnesses are not guaranteed to be in the right encoding order for the density argument)
- Using density_frame_condition's W directly without ensuring it's in the timeline (W from density_frame_condition is a specific Lindenbaum extension that may not match the staged construction's witnesses)

## Critical Context
1. `DenseTimeline.lean` has ALL Cantor prerequisites except those requiring strictness
2. The strictness gap is identical to the one documented in the Boneyard at `RestrictedFragment.lean:434-444`
3. The density_frame_condition from task 957 works at the non-strict level (CanonicalR intermediates) but strictness requires irreflexivity
4. The IRR rule (`DerivationTree.irr`) is available in the proof system but has not been used for canonical model irreflexivity
5. `Formula.atoms` function exists for checking freshness of atoms

## References
- Plan: `specs/956_.../plans/implementation-015.md`
- Research: `specs/956_.../reports/research-036.md`
- DenseTimeline: `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`
- CantorApplication (partial): `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- Boneyard blocker: `Theories/Bimodal/Boneyard/Task956_IntRat/RestrictedFragment.lean:414-463`
- IRR rule: `Theories/Bimodal/ProofSystem/Derivation.lean:149`
