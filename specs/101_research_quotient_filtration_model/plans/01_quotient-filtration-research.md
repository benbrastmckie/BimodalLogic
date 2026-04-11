# Implementation Plan: Quotient/Filtration Model Research

- **Task**: 101 - research_quotient_filtration_model
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (task 98 is the parent but does not block research)
- **Research Inputs**: specs/098_research_filtration_quasimodel_pivot/reports/11_spawn-analysis.md
- **Artifacts**: plans/01_quotient-filtration-research.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan covers systematic research into the quotient/filtration model construction (Goldblatt 1992, Blackburn et al. 2001) as the path to closing the 4 Frame.lean and 6 Realization.lean Until/Since sorries. The canonical ordering `bx_le` (g_content inclusion) is a preorder, not total, which blocks the guard proof in the Until truth lemma. The quotient construction defines equivalence classes of BXPoints by Sigma-agreement, producing a finite model where the ordering IS total. Research will produce a design document mapping the mathematical construction to concrete Lean 4 definitions and lemma statements.

### Research Integration

From the spawn analysis (report 11) and phase 5 blocker resolution (report 09):

- The direct BX7 approach (plan v5) is blocked by a fundamental circularity: proving the Until truth lemma's guard requires the Until truth lemma itself.
- Both chain-based (plans v1-v4) and direct MCS-level (plan v5) approaches are exhausted after 5 plan versions and 10+ research reports.
- The quotient/filtration approach has 85% confidence from literature analysis but has NOT been analyzed for compatibility with the existing Lean 4 codebase.
- Key proven artifacts available: `G_phi_F_psi_implies_until` and `enriched_seed_with_G_phi_inconsistent` lemmas.
- The 4 Frame.lean sorries control all 10 Until/Since sorries (Realization.lean delegates through LocusControl.lean).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the following roadmap items:
- **Task 90**: Research Option A vs Option B for Until/Since closure -- this task supersedes task 90 by introducing the quotient/filtration as a third option (Option C) that avoids the `bx_le` non-totality entirely.
- **Task 92**: Implement chosen Until/Since approach -- this research will provide the design that task 102 (the implementation companion) follows.
- **Active-path sorry inventory**: Directly targets the 4 Until/Since sorries in Frame.lean (lines 653, 675, 690, 704) and the downstream 6 Realization.lean sorries.

## Goals & Non-Goals

**Goals**:
- Determine the precise Sigma-agreement equivalence relation and how it interacts with BXPoint/MCS infrastructure
- Identify the correct Mathlib Quotient/Setoid/Fintype APIs for the construction
- Design the quotient ordering and determine the totality proof strategy from BX7/BX11
- Assess whether existing Frame.lean sorry signatures can be filled by the quotient approach or need restructuring
- Determine how the 6 Realization.lean sorries delegate to the quotient truth lemma
- Design the lifting mechanism from quotient model back to canonical model
- Produce a comprehensive design document with concrete Lean 4 type signatures

**Non-Goals**:
- Actually implementing any Lean 4 code (that is task 102)
- Proving any lemmas or closing any sorries
- Modifying any existing source files
- Researching alternative approaches (BX7 direct and chain-based are already exhausted)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sigma-agreement may not be well-defined on BXPoints due to infinite formula sets | H | L | BXPoints are MCSs over a countable language; Sigma is finite by definition in the quasimodel construction |
| Mathlib Quotient API may not support the needed operations cleanly | M | M | Survey Quotient, Setoid, Fintype, and Finset.sort; fall back to manual equivalence classes via Finset if needed |
| Totality of quotient ordering may require axioms beyond BX7/BX11 | H | L | The literature (Goldblatt 1992) confirms totality follows from BX7/BX11 on finite equivalence classes; verify the exact argument |
| Lifting from quotient back to canonical model may not preserve the guard property | H | M | Design the lifting carefully; the truth lemma in the quotient model should transfer directly because Sigma-formulas are well-defined on equivalence classes |
| Existing Frame.lean sorry signatures may be incompatible with quotient approach | M | M | Phase 4 specifically analyzes signature compatibility and proposes restructuring if needed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4, 5 | 3 |
| 4 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Literature and Mathematical Foundation [NOT STARTED]

**Goal**: Establish the precise mathematical construction from the literature (Goldblatt 1992, Blackburn et al. 2001, Burgess 1982/84) and translate it to the BX axiom system used in this codebase.

**Tasks**:
- [ ] Search for Goldblatt 1992 "Logics of Time and Computation" filtration construction for Until/Since completeness
- [ ] Search for Blackburn, de Rijke, Venema 2001 "Modal Logic" Chapter 4 filtration and Chapter 11 temporal logic completeness
- [ ] Search for Burgess 1982/84 original completeness proof for Since/Until tense logic
- [ ] Extract the precise equivalence relation definition used in the literature
- [ ] Identify how the literature proves totality of the quotient ordering
- [ ] Identify how the literature proves the Until truth lemma in the quotient model
- [ ] Map the literature construction to the BX1-BX12 axiom system (noting which axioms are used for which steps)
- [ ] Document any differences between the literature's axiom system and BX1-BX12

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**: None (research output only)

**Verification**:
- Clear mathematical description of the equivalence relation
- Identified proof strategy for totality
- Mapping from literature axioms to BX1-BX12

---

### Phase 2: Mathlib API Survey [NOT STARTED]

**Goal**: Identify the Mathlib APIs needed for the quotient construction in Lean 4, including Quotient/Setoid/Fintype/LinearOrder.

**Tasks**:
- [ ] Survey `Mathlib.Order.Quotient` and `Mathlib.GroupTheory.Quotient` for quotient ordering patterns
- [ ] Survey `Mathlib.Init.Quotient` / `Quotient` type and `Setoid` instances
- [ ] Survey `Mathlib.Data.Fintype.Basic` for finite type operations on equivalence classes
- [ ] Survey `Mathlib.Data.Finset.Sort` for producing sorted finite lists (potential alternative to Quotient)
- [ ] Survey `Mathlib.Order.LinearOrder` for how to establish `LinearOrder` on a quotient type
- [ ] Investigate `Mathlib.Data.Quot` vs `Quotient` vs manual `Finset` of representatives -- determine which API is cleanest
- [ ] Search for existing Mathlib filtration or canonical model constructions as patterns
- [ ] Use lean_loogle and lean_leansearch to find relevant lemmas for Setoid + Fintype + LinearOrder combinations

**Timing**: 2 hours

**Depends on**: none

**Files to modify**: None (research output only)

**Verification**:
- Recommended API choice (Quotient vs Finset-based) with justification
- List of key Mathlib lemmas needed
- Assessment of API ergonomics for the specific construction

---

### Phase 3: Equivalence Relation and Quotient Ordering Design [NOT STARTED]

**Goal**: Design the concrete Lean 4 definitions for the Sigma-agreement equivalence relation, the quotient type, and the quotient ordering, informed by Phases 1 and 2.

**Tasks**:
- [ ] Define the equivalence relation: `w ~ v iff forall f in Sigma, f in w.formulas <-> f in v.formulas`
- [ ] Determine what `Sigma` is concretely in the BXCanonical context (the Fischer-Ladner closure of the target formula)
- [ ] Design the `Setoid BXPoint` instance (or manual equivalence)
- [ ] Design the quotient type (using chosen Mathlib API from Phase 2)
- [ ] Design well-definedness: formula membership in equivalence classes for Sigma-formulas
- [ ] Design the quotient ordering: `[w] <= [v] iff g_content_sigma(w) subseteq v.formulas` (restricted to Sigma)
- [ ] Sketch the totality proof: how BX7/BX11 applied to the finite set of equivalence classes yields a linear order
- [ ] Determine whether `DecidableEq` on equivalence classes is needed and how to derive it
- [ ] Write proposed Lean 4 type signatures for all definitions

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**: None (design document only)

**Verification**:
- Complete set of Lean 4 type signatures for the quotient construction
- Sketch proof of totality with identified axiom usage
- Clear statement of what Sigma is and how it relates to existing codebase types

---

### Phase 4: Frame.lean Sorry Compatibility Analysis [NOT STARTED]

**Goal**: Determine whether the existing 4 Frame.lean sorry signatures can be filled by the quotient approach, or whether they need restructuring.

**Tasks**:
- [ ] Read Frame.lean sorry signatures in detail (lines 625-704): `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`
- [ ] Analyze each signature's type: does it quantify over BXPoints or can it accept quotient-level arguments?
- [ ] Determine the lifting strategy: prove the truth lemma in the quotient model, then lift back to BXPoints
- [ ] Assess whether the sorry signatures need wrapper lemmas or can be filled directly
- [ ] Check if `bx_le` (g_content inclusion) is compatible with the quotient ordering or needs bridging
- [ ] Identify any new intermediate lemmas needed between the quotient truth lemma and the existing sorry signatures
- [ ] Document the exact proof obligation for each sorry under the quotient approach

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**: None (analysis only)

**Verification**:
- For each of the 4 Frame.lean sorries: clear statement of whether it can be filled directly or needs restructuring
- If restructuring needed: proposed new signatures
- Identified intermediate lemmas

---

### Phase 5: Realization.lean Delegation Analysis [NOT STARTED]

**Goal**: Determine how the 6 Realization.lean sorries delegate to the quotient truth lemma through Frame.lean infrastructure.

**Tasks**:
- [ ] Read Realization.lean sorry sites (lines 497-622) and trace their delegation paths
- [ ] Determine whether Realization.lean sorries can be closed by simply invoking the filled Frame.lean lemmas
- [ ] Check if LocusControl.lean (the intermediary) needs changes
- [ ] Assess the gap between Realization.lean's Hintikka-level types and Frame.lean's MCS-level types
- [ ] Determine if the quotient construction makes Realization.lean sorries trivially closable or if they need independent work
- [ ] Document the delegation chain: Realization.lean -> LocusControl.lean -> Frame.lean -> quotient lemmas

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**: None (analysis only)

**Verification**:
- Clear delegation chain from each Realization.lean sorry to its ultimate proof obligation
- Assessment: trivially closable vs needs independent work
- List of any LocusControl.lean changes needed

---

### Phase 6: Design Document Synthesis [NOT STARTED]

**Goal**: Synthesize all research into a comprehensive design document that can directly guide implementation in task 102.

**Tasks**:
- [ ] Write the design document with sections: Mathematical Background, Equivalence Relation, Quotient Type, Quotient Ordering, Totality Proof, Truth Lemma, Lifting Mechanism, Sorry Resolution Strategy
- [ ] Include concrete Lean 4 type signatures for every definition and lemma
- [ ] Include the axiom-by-axiom mapping (which BX axiom is used where)
- [ ] Include effort estimates for each component of the implementation
- [ ] Include risk assessment and fallback strategies
- [ ] Include a dependency graph showing the order of implementation
- [ ] Review the design for internal consistency and completeness
- [ ] Write the research report artifact

**Timing**: 1 hour

**Depends on**: 4, 5

**Files to modify**:
- `specs/101_research_quotient_filtration_model/reports/01_quotient-filtration-design.md` - Main design document/research report

**Verification**:
- Design document contains all required sections
- Every Frame.lean sorry has a concrete proof strategy
- Every Realization.lean sorry has a delegation path
- Lean 4 type signatures are complete and self-consistent
- Effort estimate for implementation task is well-calibrated

## Testing & Validation

- [ ] Design document covers all 4 Frame.lean sorry signatures with concrete proof strategies
- [ ] Design document covers all 6 Realization.lean sorry signatures with delegation paths
- [ ] Mathlib API choices are validated by searching for the proposed lemmas via lean_loogle/lean_leansearch
- [ ] Totality proof sketch identifies the exact BX axioms used (BX7, BX11, or both)
- [ ] Equivalence relation definition is concrete and well-typed for the existing BXPoint structure
- [ ] Lifting mechanism from quotient back to canonical model is well-defined

## Artifacts & Outputs

- `specs/101_research_quotient_filtration_model/reports/01_quotient-filtration-design.md` - Design document mapping quotient/filtration construction to Lean 4
- `specs/101_research_quotient_filtration_model/plans/01_quotient-filtration-research.md` - This plan file

## Rollback/Contingency

This is a pure research task with no code modifications. If the quotient/filtration approach turns out to be infeasible during research:
- Document the specific obstacle that makes it infeasible
- Reassess Option C (add Until-induction as a new axiom) from the phase 5 blocker analysis
- Consider whether the quotient approach can be modified to work around the obstacle
- Update the parent task 98 with findings
