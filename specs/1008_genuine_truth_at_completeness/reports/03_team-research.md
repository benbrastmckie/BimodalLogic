# Research Report: Resolution Paths for TM Logic Completeness

**Task**: 1008 - Establish genuine truth_at completeness theorems for TM logic
**Date**: 2026-03-20
**Mode**: Team Research (2 teammates)
**Session**: sess_1774054508_f9e852

## Summary

Two research agents investigated four resolution paths for the 3 fundamental sorries blocking TM logic completeness. The investigation reveals two complementary strategies that together form a clear path forward: (1) **Complete the existing FMP pipeline** to obtain finite models where witnesses exist a priori, and (2) **Generalize TaskFrame** to relax the `AddCommGroup` constraint, enabling the sorry-free `CanonicalMCS` construction to serve as the completeness domain. The omega-squared construction is viable but unnecessary if FMP succeeds. The quotient group approach on MCS is infeasible.

## Key Findings

### 1. Modal Saturation (from Teammate A)

**Viability**: Medium | **Confidence**: Medium

The multi-family bundle approach is mathematically sound. `ModalSaturation.lean` already proves `saturated_modal_backward` (line 328) via contraposition: if phi holds in ALL families but Box(phi) fails, then Diamond(~phi) holds, so by saturation a witness family has ~phi, contradicting the universal assumption.

**Current State**:
- `is_modally_saturated` predicate exists (line 73)
- `saturated_modal_backward` theorem is proven (line 328)
- `SaturatedBFMCS` structure defined (line 380)
- **Missing**: Actual construction of a saturated BFMCS (removed, lines 193-209)

**Blocker**: Transfinite iteration via `Ordinal.nfpFamily` could produce 2^aleph_0 families. Each witness family must also be temporally coherent, compounding the construction difficulty.

### 2. Omega-Squared Construction (from Teammate B)

**Viability**: Medium | **Confidence**: Medium

Codebase has Cantor pairing infrastructure in `Dovetailing.lean` with `forall_obligation_eventually_processed` (line 147). However, the current implementation still applies Lindenbaum extension AFTER obligation processing, so G(~phi) can still kill F(phi) witnesses.

**True fix**: Process F-obligations BEFORE Lindenbaum by pre-seeding phi at target position. This requires two-phase construction (obligation collection then seed construction) and significant restructuring of the chain builder.

**Assessment**: Viable but high implementation cost, and unnecessary if FMP approach succeeds.

### 3. Finite Model Property (from Teammate B) -- RECOMMENDED

**Viability**: High | **Confidence**: High

TM logic has the finite model property. The codebase already has ~80% of the FMP infrastructure:

| File | Status | Content |
|------|--------|---------|
| `FMP.lean` | Working | Main FMP theorem via MCS filtration |
| `Filtration.lean` | Working | MCS-based filtration equivalence |
| `FiniteModel.lean` | Working | Finiteness bound 2^|closure(phi)| |
| `ClosureMCS.lean` | Working | Restricted Lindenbaum for closure MCS |
| `DenseFMP.lean` | Working | Dense frame FMP |
| `TruthPreservation.lean` | **Partial** | Truth preservation under filtration |

**Why FMP sidesteps ALL three blockers**:
1. **modal_backward**: In filtered models, families come from ALL closure-equivalent MCS classes. The universal quantification over finite families is non-degenerate.
2. **forward_F**: Witnesses exist a priori in the quotient -- no construction can "kill" them because all MCS are present before any extension step.
3. **backward_P**: Same reasoning as forward_F.

**Missing piece**: `TruthPreservation.lean` needs completion to establish `phi in MCS <-> model |= phi` for the filtered model.

### 4. Alternative Domain / Generalized TaskFrame (from Teammate A) -- RECOMMENDED

**Viability**: High | **Confidence**: High

The existing `canonicalMCSBFMCS` construction is **completely sorry-free**:
- `canonicalMCS_forward_F` (CanonicalFMCS.lean:222-228)
- `canonicalMCS_backward_P` (CanonicalFMCS.lean:240-251)
- `temporal_coherent_family_exists_CanonicalMCS` (CanonicalFMCS.lean:293-311)

The only reason it can't be used is that `TaskFrame D` requires `[AddCommGroup D]`, but `CanonicalMCS` has no group structure. Analysis of TaskFrame axioms shows the group structure is used for:
- Zero element (identity duration)
- Addition (composition)
- Negation (converse)

**Proposed solution**: Define `PreorderTaskFrame D` with `[Preorder D] [Zero D]` that weakens the algebraic requirement while preserving semantic meaning.

**Key insight**: The TruthLemma doesn't actually use group operations -- only ordering.

## Synthesis

### Conflicts Found: 1

**Conflict**: Primary approach selection
- Teammate A recommends generalizing TaskFrame as primary, FMP as secondary consideration
- Teammate B recommends completing FMP pipeline as primary

**Resolution**: These approaches are **complementary, not competing**:
1. FMP provides the mathematical machinery (finite models with a priori witnesses)
2. Generalized TaskFrame provides the type-theoretic bridge (allowing non-Int domains)
3. Together: FMP + generalized semantics = completeness without any of the 3 blockers

The recommended strategy uses BOTH: generalize TaskFrame to accept the domain that FMP/CanonicalMCS naturally produces.

### Gaps Identified: 3

1. **TruthPreservation.lean completion**: What specifically is missing? Need to audit current sorries.
2. **Filtered model frame conditions**: Does the filtered model satisfy TM-specific frame conditions (density, linearity)?
3. **Integration path**: How to connect `FilteredWorld phi` or `CanonicalMCS` to the (generalized) TaskFrame to get the completeness statement?

### Approach Rankings

| Approach | Viability | Effort | Risk | Recommendation |
|----------|-----------|--------|------|----------------|
| FMP pipeline completion | High | Medium | Low | **Primary** |
| Generalize TaskFrame | High | Low | Low | **Primary** (complementary) |
| Modal saturation | Medium | High | Medium | Defer |
| Omega-squared | Medium | High | High | Defer |
| Quotient group on MCS | Low | -- | -- | **Rejected** (no natural group structure) |

### Recommended Strategy

**Phase 1**: Generalize `TaskFrame` to `PreorderTaskFrame` (low effort, unblocks everything)
**Phase 2**: Complete `TruthPreservation.lean` for FMP pipeline
**Phase 3**: Connect FMP filtered model to generalized TaskFrame
**Phase 4**: State and prove completeness theorem using the combined approach

This avoids the 3 fundamental blockers entirely:
- No single-family BFMCS (modal_backward resolved by using all MCS)
- No linear chain construction (forward_F/backward_P resolved by FMP a priori witnesses)
- No Int domain requirement (generalized TaskFrame accepts CanonicalMCS or FilteredWorld)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Modal saturation + Alternative domain | Completed | High | Generalize TaskFrame to PreorderTaskFrame |
| B | Omega-squared + FMP | Completed | High | Complete FMP pipeline (80% infrastructure exists) |

## References

### Codebase
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` -- Sorry-free construction
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` -- Saturation infrastructure
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` -- Linear chain blockers
- `Theories/Bimodal/Metalogic/Decidability/FMP/` -- FMP pipeline (80% complete)
- `Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean` -- Cantor pairing
- `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame definition

### Literature
- [Completeness in Modal Logic](https://math.uchicago.edu/~may/REU2020/REUPapers/Hebert.pdf) -- Canonical model construction
- [Henkin-Style Completeness for S5](https://arxiv.org/abs/1910.01697) -- Witness pre-scheduling
- [FMP in Weakly Transitive Tense Logics](https://link.springer.com/article/10.1007/s11225-022-10027-0) -- Filtration technique
- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) -- FMP confirmation
- [Completeness by Construction for Tense Logics](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) -- Construction techniques
