# Blocker Analysis: Task #98

**Parent Task**: #98 - research_filtration_quasimodel_pivot
**Generated**: 2026-04-11
**Blocker**: Plan v5 Phase 5 is fundamentally blocked by a circularity in the guard proof -- proving the Until truth lemma's guard requires the Until truth lemma itself. The canonical ordering `bx_le` (g_content inclusion) is a preorder, not a total order, and BX7/BX11 cannot bridge this gap.

## Root Cause

The root cause is a structural mismatch between the canonical model's ordering and what the Until/Since truth lemma requires. Specifically:

1. **Ordering non-totality**: `bx_le w v := g_content(w) subseteq v.formulas` defines a preorder on BXPoints, but the Until truth lemma's guard proof requires reasoning about intervals `[w, v)` which presupposes a total (or at least linear) ordering. Two MCSs can have `bx_le u v` and `bx_le v u` simultaneously while differing on non-modal formulas like `phi U psi`.

2. **Circularity**: To prove `phi in u` for intermediate points u (the guard property), one needs the forward direction of the Until truth lemma -- the very theorem being proved. BX5 (self-accumulation) gives `(phi and (phi U psi)) U psi in w`, but extracting `phi in u` from this requires knowing that the Until formula's guard holds at u, which is the forward direction.

3. **BX7/BX11 insufficiency**: BX7 constrains the ordering of Until-witnesses and BX11 constrains F-witnesses, but these operate on formula membership, not on g_content inclusion between BXPoints. There is no axiom-derivable bridge between "F-witnesses are ordered" and "g_content inclusion is total on intervals."

4. **Chain realization failure**: The earlier chain-based approach (plans v1-v4) also failed due to the Hintikka/MCS abstraction gap: projecting MCSs to a finite Sigma loses G-content information that cannot be recovered.

This has been investigated across 5 plan versions, 10+ research reports, and multiple implementation attempts. Both the direct MCS-level approach (v5) and the chain realization approach (v1-v4) are exhausted.

The recommended resolution is the **quotient/filtration model construction** (Goldblatt 1992, Blackburn et al. 2001), where:
- BXPoints are quotiented by Sigma-agreement: `w ~ v iff forall f in Sigma, f in w.formulas <-> f in v.formulas`
- The quotient ordering IS total (from BX7/BX11 applied to the finite set of equivalence classes)
- The Until truth lemma follows from totality of the ordering
- The construction is well-understood in the literature with 85% confidence

## Proposed New Tasks

### New Task 1: Research quotient/filtration model construction for BX completeness
- **Effort**: 8-12 hours
- **Language**: lean4
- **Rationale**: The quotient/filtration approach is well-described in the literature but has not been analyzed for compatibility with the existing Lean 4 codebase. Research is needed to: (a) determine the precise equivalence relation and how it interacts with existing BXPoint/MCS infrastructure, (b) identify which Mathlib Quotient/Setoid/Fintype APIs to use, (c) design the quotient ordering and prove it is total (from BX7/BX11), (d) determine whether the existing Frame.lean sorry signatures can be filled by the quotient approach or need restructuring, (e) assess whether the 6 Realization.lean sorries can delegate to the quotient truth lemma. This research will produce a detailed design document that maps the mathematical construction to concrete Lean 4 definitions and lemma statements, enabling a focused implementation.
- **Depends on**: None

### New Task 2: Implement quotient/filtration model and close Until/Since sorries
- **Effort**: 30-45 hours
- **Language**: lean4
- **Rationale**: Implement the quotient/filtration model construction designed in Task 1 and use it to close the 4 Frame.lean sorries and 6 Realization.lean sorries. This involves: (a) defining the Sigma-agreement equivalence relation on BXPoints, (b) constructing the quotient model with Mathlib's Quotient/Setoid, (c) proving totality of the quotient ordering from BX7/BX11, (d) proving the Until/Since truth lemma in the quotient model (where totality makes the guard proof straightforward), (e) lifting results back to the canonical model to close Frame.lean sorries, (f) closing Realization.lean sorries by delegation. The implementation depends on the specific design choices made in the research task -- particularly the equivalence relation definition, the quotient API choices, and the proof strategy for totality.
- **Depends on**: New Task 1, because the implementation needs the specific equivalence relation definition, the chosen Mathlib APIs (Quotient vs Fintype.sort vs manual construction), the totality proof strategy, and the lifting mechanism from quotient back to canonical model. These design decisions from the research directly determine how the Lean 4 code is structured.

## Dependency Reasoning

- **Task 2 depends on Task 1**: The quotient/filtration construction has multiple design degrees of freedom: the precise equivalence relation (full Sigma-agreement vs restricted to temporal formulas), the Lean 4 representation (Mathlib Quotient type vs manual equivalence classes via Finset), the totality proof strategy (BX7-based vs BX11-based vs combined), and the lifting mechanism (direct sorry substitution vs new intermediate lemmas). Task 1's research will make these design decisions based on analysis of the existing codebase and Mathlib API surface. Task 2's implementation must follow whatever design Task 1 produces -- different design choices lead to fundamentally different Lean 4 code.

## After Completion

Once all spawned tasks are complete, resume the parent task #98 with `/implement 98`.

The blocker will be resolved because: the quotient/filtration model provides a finite structure where the temporal ordering is total by construction, eliminating the g_content-inclusion non-totality that blocks the guard proof. In a totally ordered structure, the Until truth lemma's guard property becomes straightforward: for `phi U psi in [w]` with witness `[v]`, any intermediate `[u]` in the interval `([w], [v])` must have `phi in [u]` because the total ordering makes interval reasoning well-defined. This avoids the circularity in the current approach where proving the guard requires the truth lemma being proved.
