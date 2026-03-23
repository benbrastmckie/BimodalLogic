# Implementation Plan: Task #988 - Dense Algebraic Completeness v12

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [PARTIAL] (Phase 1 complete, Phase 2 blocked)
- **Effort**: 6-8 hours
- **Dependencies**: None (task 1000 analysis shows its pattern is not applicable here)
- **Research Inputs**: specs/988_dense_algebraic_completeness/reports/15_blocker-resolution.md
- **Artifacts**: plans/12_multi-family-bfmcs-bundle.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan implements dense algebraic completeness for bimodal logic using D = Rat (rationals) via a multi-family BFMCS bundle approach. The previous plan v11 blocked at phases 3-4 because Lindenbaum witnesses constructed for F/P obligations may land outside the current Flag. This revision abandons the single-saturated-flag approach and instead builds a BFMCS bundle where each Flag in CanonicalMCS becomes a separate FMCS family, with modal coherence tying them together.

### Research Integration

Integrated from reports/15_blocker-resolution.md:
- Task 1000's mutual recursion pattern (combined well-founded induction) does NOT apply here - no involution for witness-in-flag problem
- Multi-family BFMCS bundle is the mathematically correct path forward
- ChainFMCS infrastructure provides sorry-free witnesses: `chainFMCS_forward_F_in_CanonicalMCS`, `chainFMCS_backward_P_in_CanonicalMCS`
- Modal coherence via S5 axioms and BoxContent propagation theorems

### Previous Progress (Phases 1-2 from Plan v11)

Already complete (0 sorries):
- SaturatedChain.lean: Saturation predicates (`ChainFSaturated`, `ChainPSaturated`, `ChainSaturated`, `FlagSaturated`)
- Zorn infrastructure: `ChainSaturated_sUnion`, `ChainSaturated_empty`, `exists_flag_containing`
- Order properties: `canonicalMCS_has_future`, `canonicalMCS_has_past`, `canonicalMCS_has_intermediate`
- Density/order constraints: `saturatedFlag_noMaxOrder`, `saturatedFlag_noMinOrder`

## Goals and Non-Goals

**Goals**:
- Construct a multi-family BFMCS over Rat domain
- Prove modal coherence (`modal_forward`, `modal_backward`) for the bundle
- Wire to `dense_representation_conditional` for completeness
- Maintain zero-sorry policy

**Non-Goals**:
- Single-saturated-flag approach (mathematically incorrect)
- Transfinite ordinal induction (architecturally complex)
- Any sorries in production code

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Modal coherence proof difficulty | High | Medium | Use existing BoxContent propagation lemmas, S5 axioms |
| Cantor isomorphism per-family complexity | Medium | Low | Apply standard Mathlib CountableDenseLinearOrder isomorphism |
| Wire-up to dense_representation_conditional | Medium | Medium | Follow existing BFMCS.lean patterns |
| Universe or cardinality issues | Low | Low | All types are countable (CanonicalMCS, Rat) |

## Implementation Phases

### Phase 1: Multi-Family BFMCS Domain Definition [COMPLETED]

**Goal**: Define the multi-family BFMCS structure where each Flag becomes an FMCS family.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`
- [ ] Define `FlagFamily : Flag CanonicalMCS -> FMCS (ChainFMCSDomain flag)` using existing `chainFMCS`
- [ ] Define bundle type: `AllFlagFamilies : Set (FMCS ?)` collecting all Flag-based families
- [ ] Handle domain heterogeneity: each Flag has different `ChainFMCSDomain flag` type
- [ ] Alternative: Use common domain via Sigma type `(Sigma (flag : Flag CanonicalMCS) (ChainFMCSDomain flag))`

**Timing**: 2 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`

**Verification**:
- Compiles without errors
- `FlagFamily` construction uses `chainFMCS`

---

### Phase 2: Modal Coherence Proofs [BLOCKED]

**Goal**: Prove `modal_forward` and `modal_backward` conditions for the multi-family bundle.

**Tasks**:
- [ ] Prove `modal_forward`: If Box(phi) in any family's MCS at time t, then phi in ALL families' MCSes at time t
  - Use S5 T-axiom: Box phi -> phi
  - Use `MCSBoxContent_subset_of_CanonicalR` for propagation
- [ ] Prove `modal_backward`: If phi in ALL families' MCSes at time t, then Box(phi) in each family's MCS
  - Use MCS maximality: if neg(Box phi) not in MCS, then Box phi in MCS
  - Use contrapositive via `diamond_witness` pattern from BFMCS.lean
- [ ] Verify coherence holds across different Flags via BoxContent propagation

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`

**Verification**:
- `modal_forward` and `modal_backward` compile without sorry
- Coherence does not require witnesses to be in same Flag

---

### Phase 3: Cantor Isomorphism and Rat Domain [NOT STARTED]

**Goal**: Transfer each Flag's FMCS to a Rat-indexed family via Cantor's theorem.

**Tasks**:
- [ ] Apply Mathlib's `Order.iso_of_countable_dense_without_endpoints` per Flag
- [ ] Prove each `ChainFMCSDomain flag` satisfies:
  - `Countable`: CanonicalMCS is countable, subtype inherits
  - `DenselyOrdered`: From `canonicalMCS_has_intermediate` if Flag is saturated, or work at CanonicalMCS level
  - `NoMinOrder`, `NoMaxOrder`: From `saturatedFlag_noMinOrder`, `saturatedFlag_noMaxOrder`
- [ ] Define `RatFamilyFromFlag : Flag CanonicalMCS -> FMCS Rat`
- [ ] Preserve temporal coherence through isomorphism

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`

**Verification**:
- Each `RatFamilyFromFlag flag` compiles
- Order properties verified at Lean level

---

### Phase 4: Wire to dense_representation_conditional [NOT STARTED]

**Goal**: Connect the multi-family BFMCS to `dense_representation_conditional` for completeness.

**Tasks**:
- [ ] Construct `DenseBFMCS : BFMCS Rat` from `AllRatFamilies`
- [ ] Identify `eval_family` as the Flag containing the root MCS M0
- [ ] Prove root MCS appears at time 0 in eval_family
- [ ] Wire truth lemma through BFMCS modal coherence
- [ ] Connect to `dense_representation_conditional` for final completeness statement

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`
- Possibly `Theories/Bimodal/Metalogic/Algebraic/DenseCompleteness.lean` (if exists)

**Verification**:
- `dense_algebraic_completeness` theorem compiles
- Zero sorries in proof
- Clean `lake build` on affected modules

---

## Testing and Validation

- [ ] `lake build Bimodal.Metalogic.Algebraic.MultiFamilyBFMCS` succeeds
- [ ] All new theorems compile without `sorry`
- [ ] Modal coherence proofs (`modal_forward`, `modal_backward`) are complete
- [ ] Cantor isomorphism applies correctly to each Flag domain
- [ ] Final `dense_algebraic_completeness` or `dense_representation_conditional` wire-up succeeds
- [ ] Full `lake build` succeeds

## Artifacts and Outputs

- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` (new file)
- Updated plan with phase completion markers
- Implementation summary (upon completion)

## Rollback/Contingency

If multi-family approach encounters unforeseen obstacles:
1. Preserve SaturatedChain.lean infrastructure (phases 1-2 from v11)
2. Consider alternative: single-family with explicit modal witness tracking
3. Document blocking issue for future research approach

If Cantor isomorphism fails for non-saturated Flags:
1. Work with CanonicalMCS domain directly (dense by DN axiom)
2. Apply isomorphism at CanonicalMCS level rather than per-Flag
3. Adjust BFMCS bundle to use common CanonicalMCS domain with Flag membership predicates
