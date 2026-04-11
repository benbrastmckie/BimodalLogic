# Research Summary: Quotient/Filtration Model for BX Completeness

- **Task**: 101 - research_quotient_filtration_model
- **Date**: 2026-04-11
- **Session**: sess_1775927038_f16dd9
- **Design Document**: `specs/101_research_quotient_filtration_model/reports/01_quotient-filtration-design.md`

## Key Findings

### 1. bx_le is Not Total, Even on Sigma-Equivalence Classes

The canonical ordering `bx_le := g_content ⊆` is a preorder (reflexive + transitive) but NOT total. BX11 (temporal linearity) constrains F-witnesses at a single point but cannot establish that g_content inclusion is total between two arbitrary BXPoints, even when they share a common ancestor and descendant. This confirms and strengthens the phase 5 blocker analysis from task 98.

### 2. Simple Quotient Does Not Resolve the Problem

A naive quotient of the canonical model by Sigma-agreement does NOT make the ordering total. The Sigma-restricted ordering `q_le` (g_content within Sigma) inherits the non-totality of `bx_le`. Neither BX7 (Until linearity) nor BX11 provides the bridge needed.

### 3. Defect-Discharge Chain is the Correct Approach

The viable approach uses well-founded recursion on the **defect count** -- the number of Until formulas in Sigma whose goal is absent at a BXPoint. The defect count is bounded by |Sigma| and decreases along the chain. This is the standard Burgess (1984) technique.

### 4. Frame.lean Sorries Need Modified Signatures

The current sorry signatures use `¬bx_le v u` as the guard condition, which requires strict ordering in the `bx_le` preorder. This is too strong. The guard should use `sigma_strict Sigma u v` -- a Sigma-formula witnesses that `u` and `v` are in different Sigma-equivalence classes with `u` strictly below `v` in the Sigma-restricted ordering. This weaker condition is both sufficient for the semantic truth lemma and provable via the filtration.

### 5. Guard Extension is the Critical Challenge

The hardest part of the implementation is proving the "guard extension" -- that the guard property holds not just at chain members, but at ALL intermediate BXPoints. The argument is: since `phi ∈ Sigma`, formula membership `phi ∈ u` is determined by the Sigma-equivalence class of `u`. Points with the same Sigma-signature as a chain member inherit the guard property; points with the same Sigma-signature as the endpoint `v` have `psi ∈ u` by Sigma-equivalence, and the modified guard condition (using `sigma_strict`) does not require `phi` at such points.

### 6. Existing Infrastructure is Heavily Reused

- `HintikkaPoint` = Sigma-equivalence classes (no new Quotient/Setoid needed)
- `sigma_signature` = projection function (already exists)
- `enrichedClosure` = the Fisher-Ladner Sigma (already exists, with G/H enrichment)
- `enriched_seed_consistent_until/since` = seed consistency (already proved)
- `bx_forward_witness`, `bx_backward_witness` = witness construction (already proved)

### 7. Realization.lean Sorries Delegate Through Frame.lean

The 6 Realization.lean sorries (`until_eventuality_resolution` x2, `until_backward` x1, `since_eventuality_resolution` x2, `since_backward` x1) are thin wrappers around the Frame.lean sorries via LocusControl.lean. Once Frame.lean's modified sorries are proved, Realization.lean and LocusControl.lean need signature updates to match, but the proofs become trivial delegation.

### 8. Mathlib API Choices

- **NOT using**: `Quotient`, `Setoid`, `Antisymmetrization` -- the existing `HintikkaPoint` already serves as the equivalence class type
- **Using**: `Finset` (for Sigma and defect counting), `List.Chain'` (for chain ordering), well-founded recursion (`WellFoundedRelation` or `Nat.lt_wfRel`)
- **Potentially using**: `Fintype (HintikkaPoint Sigma)` instance (for finiteness arguments in guard extension)

## Implementation Roadmap (Task 102)

| Phase | Description | Hours | Risk |
|-------|-------------|-------|------|
| 1 | Sigma ordering infrastructure | 8 | Low |
| 2 | Defect discharge chain | 12 | Medium |
| 3 | Guard extension (critical path) | 15 | High |
| 4 | Modified Frame.lean signatures | 5 | Low |
| 5 | TruthLemma and Completeness | 5 | Medium |
| **Total** | | **45** | **Medium-High** |

## Fallback Strategy

If the guard extension (Phase 3) fails because the enrichedClosure's G/H-enrichment is insufficient to determine `phi ∈ u` from the chain constraints:

**Fallback**: Replace `bx_le` with a chain-constructed linear ordering. This requires rewriting Frame.lean's infrastructure (reflexivity, transitivity, witness properties) but avoids the guard extension entirely. Estimated additional cost: 20h.

## Dependency on Task 98

Task 98 is the parent. This research supersedes the chain realization approach (plans v1-v5). The defect-discharge chain construction is conceptually related to the quasimodel construction (already partially built in Construction.lean) but operates at the MCS level with modified guard conditions, not at the Hintikka level.
