# Implementation Plan: Task #1008

- **Task**: 1008 - Establish genuine truth_at completeness theorems for TM logic
- **Status**: [NOT STARTED]
- **Version**: 3 (revised — corrects D = CanonicalMCS confusion in v2)
- **Effort**: 10–14 hours
- **Dependencies**: Task #1007 (completed)
- **Research Inputs**: specs/1008_genuine_truth_at_completeness/reports/01_completeness-architecture.md
- **Artifacts**: plans/03_revised-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

### Key Clarification: D vs CanonicalMCS

**D is the duration domain** (time type) in `TaskFrame D`. It requires `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. Valid choices: `Int`, `Rat`, `Real`.

**CanonicalMCS is the world state type** — maximal consistent sets. It has `Preorder` only (via reflexive closure of CanonicalR). It **cannot** be used as D.

The v2 plan incorrectly proposed D = CanonicalMCS throughout. This revision corrects that error.

### Current Architecture

The completeness pipeline is:

```
algebraic_base_completeness (AlgebraicBaseCompleteness.lean)
  └─ construct_bfmcs_from_mcs_Int (IntFMCSTransfer.lean)  ← 3 sorries here
       ├─ intTemporalCoherentFamily  ← uses intFMCS_forward_F/backward_P (2 sorries)
       └─ singleFamilyBFMCS_Int      ← modal_backward (1 sorry)
```

The proof structure is correct: `algebraic_base_completeness` has no direct sorry. It calls `construct_bfmcs_from_mcs_Int` which has 3 sorries:

1. **`intFMCS_forward_F`** (IntBFMCS.lean:1199) — F(phi) at t implies witness at some s > t
2. **`intFMCS_backward_P`** (IntBFMCS.lean:1213) — P(phi) at t implies witness at some s < t
3. **`modal_backward`** (IntFMCSTransfer.lean:134) — single-family BFMCS limitation

### Sorry-Free Infrastructure

| Module | Status | Notes |
|--------|--------|-------|
| ParametricCanonicalTaskFrame D | Sorry-free | D-parametric TaskFrame, WorldState = MCS pairs |
| parametric_to_history | Sorry-free | FMCS → WorldHistory with domain = True (trivially convex) |
| parametric_shifted_truth_lemma | Sorry-free | MCS membership ↔ truth_at |
| parametric_representation_from_neg_membership | Sorry-free | neg(phi) in MCS → phi false at model |
| canonicalMCSBFMCS / CanonicalFMCS | Sorry-free | FMCS over CanonicalMCS, trivial F/P |
| saturated_modal_backward | Sorry-free | modal_backward for modally saturated BFMCS |
| algebraic_base_completeness | Complete modulo construct_bfmcs | Proof structure finished |

### Strategy

Resolve the 3 sorries in two independent tracks:
- **Modal track**: Replace single-family BFMCS with modally-saturated multi-family BFMCS (ModalSaturation.lean already provides the key theorem)
- **Temporal track**: Replace simple Lindenbaum chain with witness-preserving construction

## Goals & Non-Goals

**Goals**:
- Eliminate `modal_backward` sorry by constructing modally-saturated multi-family BFMCS Int
- Eliminate `intFMCS_forward_F` and `intFMCS_backward_P` sorries
- Wire completeness theorem to use the improved BFMCS construction
- Extend to dense completeness (D = Rat) via existing Cantor infrastructure
- Scaffold discrete completeness (blocked by Task 974)

**Non-Goals**:
- Using D = CanonicalMCS (incorrect — CanonicalMCS lacks AddCommGroup/LinearOrder)
- Constructing CanonicalMCS-to-Int bijection (impossible — different cardinalities)
- Full discrete completeness (requires SuccOrder/PredOrder from Task 974)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Omega-squared F/P construction is technically intractable | H | M | Accept sorries with clear documentation; completeness modulo F/P is still valuable |
| Multi-family BFMCS with temporal coherence simultaneously is hard | H | M | Solve modal and temporal independently first, then combine |
| CanonicalEmbedding Rat sorries (5 sorries) resist resolution | M | H | Focus on base (Int) first; dense is a separate milestone |
| F-witnesses placed by omega-squared break G-coherence | M | L | canonical_forward_F guarantees CanonicalR relationship, so G-content containment holds |

## Implementation Phases

### Phase 1: Multi-Family Modally Saturated BFMCS Int [NOT STARTED]

**Goal**: Replace `singleFamilyBFMCS_Int` with a modally-saturated multi-family BFMCS that eliminates the `modal_backward` sorry.

**Background**: `ModalSaturation.lean` already proves `saturated_modal_backward` — given a modally saturated BFMCS, modal_backward holds. The missing piece is *constructing* a modally saturated BFMCS Int from a given MCS.

**Tasks**:
- [ ] Read ModalSaturation.lean fully to understand `is_modally_saturated` and `saturated_modal_backward`
- [ ] Read MultiFamilyBFMCS.lean to understand existing multi-family construction attempts
- [ ] Design construction: given seed MCS M, build multi-family BFMCS Int where:
  - For each Diamond(psi) in M: include a family containing an MCS where psi holds
  - Use Box-equivalence classes of MCSs to generate families
  - Each family is an Int-indexed chain (same intChainMCS construction)
- [ ] Implement `construct_saturated_bfmcs_Int : (M : Set Formula) → SetMaximalConsistent M → Σ' (B : BFMCS Int) ...`
- [ ] Prove `is_modally_saturated` for the constructed BFMCS
- [ ] Verify `saturated_modal_backward` applies, eliminating the sorry

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` — replace `singleFamilyBFMCS_Int`
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` — extend if needed

**Verification**:
- `modal_backward` no longer has sorry in the BFMCS construction used by completeness
- `lake build Bimodal.Metalogic.Bundle.IntFMCSTransfer`

---

### Phase 2: Witness-Preserving Chain for Forward_F / Backward_P [NOT STARTED]

**Goal**: Eliminate the `intFMCS_forward_F` and `intFMCS_backward_P` sorries by constructing Int-indexed chains that preserve temporal witnesses.

**Background**: The current `intChainMCS` uses generic Lindenbaum extension at each step, which can introduce G(~phi), killing F(phi). The fundamental limitation is documented in IntBFMCS.lean:1160-1174.

**Approach — Omega-Squared Construction**:
Instead of generic Lindenbaum at each step:
1. Start with seed MCS M₀ at position 0
2. At step n, enumerate all F/P obligations in positions ≤ n
3. For each F(phi) obligation at position t: obtain witness W via `canonical_forward_F` (which guarantees CanonicalR M_t W and phi ∈ W — so G-coherence is automatic)
4. Place witness W at the next available position
5. Only do Lindenbaum extension for unfilled positions AFTER all witnesses are placed

Key insight: `canonical_forward_F` provides W with `g_content(M_t) ⊆ W` (= CanonicalR), so placing this witness preserves forward_G coherence.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/OmegaSquaredChain.lean`
- [ ] Define the omega-squared chain construction with witness scheduling
- [ ] Prove `forward_G` and `backward_H` for the new chain (should follow from CanonicalR of placed witnesses)
- [ ] Prove `forward_F`: by construction, every F-obligation gets a witness placed in the chain
- [ ] Prove `backward_P`: symmetric construction for past witnesses
- [ ] Define `omegaSquaredFMCS_Int : FMCS Int` wrapping the chain
- [ ] Prove `omegaSquaredFMCS_temporallyCoherent`
- [ ] Update `IntFMCSTransfer.lean` to use omega-squared chain instead of `intFMCS_basic`
- [ ] `lake build` to verify

**Timing**: 4 hours (this is the hardest phase)

**Contingency**: If the omega-squared construction proves intractable within the time budget:
- Document the limitation clearly
- Keep the forward_F/backward_P sorries with detailed explanation
- The completeness theorem remains valid modulo these two infrastructure sorries
- The modal sorry (Phase 1) should still be eliminated independently

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/OmegaSquaredChain.lean`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` — use new chain

**Verification**:
- `intFMCS_forward_F` and `intFMCS_backward_P` proven (no sorry)
- `lake build Bimodal.Metalogic.Bundle.IntFMCSTransfer`
- Grep confirms sorry reduction in IntBFMCS pipeline

---

### Phase 3: Wire Updated BFMCS to Completeness Theorem [NOT STARTED]

**Goal**: Connect the improved BFMCS construction (multi-family, temporally coherent) to `algebraic_base_completeness`.

**Tasks**:
- [ ] Update `construct_bfmcs_from_mcs_Int` to use:
  - Multi-family saturated BFMCS from Phase 1
  - Omega-squared temporal coherence from Phase 2
- [ ] Verify `algebraic_base_completeness` still compiles with updated construction
- [ ] Clean up deprecated code in AlgebraicBaseCompleteness.lean (singleFamilyBFMCS, construct_bfmcs_from_mcs)
- [ ] Update module docstring to reflect sorry-free status (if achieved)
- [ ] `lake build Bimodal.Metalogic.Algebraic.AlgebraicBaseCompleteness`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` — update `construct_bfmcs_from_mcs_Int`
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` — clean deprecated code

**Verification**:
- `algebraic_base_completeness` compiles
- Sorry count in completeness pipeline reduced (ideally to 0)
- `lake build` succeeds

---

### Phase 4: Dense Completeness (D = Rat) [NOT STARTED]

**Goal**: Extend completeness to dense TM logic using D = Rat via existing Cantor infrastructure.

**Background**: CanonicalEmbedding.lean provides `ratFMCS` (FMCS over Rat transferred from TimelineQuot via Cantor isomorphism) but has 5 sorries for F/P coherence and modal_backward.

**Tasks**:
- [ ] Read CanonicalEmbedding.lean to understand current state (5 sorries)
- [ ] Apply modal saturation approach (same as Phase 1) for Rat BFMCS
- [ ] Investigate whether omega-squared approach transfers to Rat (or if TimelineQuot already handles F/P)
- [ ] Complete `ratFMCS_forward_F` and `ratFMCS_backward_P`
- [ ] Wire to `construct_bfmcs_rat` for dense completeness export
- [ ] `lake build Bimodal.Metalogic.Algebraic.CanonicalEmbedding`

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` (if wiring needed)

**Verification**:
- `ratFMCS_forward_F` and `ratFMCS_backward_P` proven (or sorry count reduced)
- Dense completeness theorem exported
- `lake build` passes

---

### Phase 5: Discrete Completeness Scaffold [NOT STARTED]

**Goal**: Scaffold discrete completeness with clear documentation of Task 974 dependency.

**Tasks**:
- [ ] Check current state of `DiscreteInstantiation.lean`
- [ ] Document dependency on `SuccOrder Int` and `PredOrder Int` (Task 974)
- [ ] If scaffolding file doesn't exist, create `AlgebraicDiscreteCompleteness.lean` with:
  - Conditional completeness assuming DF axiom witness existence
  - Clear sorry documentation linking to Task 974
- [ ] `lake build` to verify scaffold compiles

**Timing**: 1 hour

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicDiscreteCompleteness.lean` (create if needed)
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean`

**Verification**:
- Scaffold compiles
- Sorries documented with Task 974 dependency

---

### Phase 6: Final Verification and Summary [NOT STARTED]

**Goal**: Full build verification, sorry audit, and implementation summary.

**Tasks**:
- [ ] Run `lake build` for full project
- [ ] Grep for sorry in modified/created files — document each
- [ ] Verify axiom count unchanged (3 expected)
- [ ] Create implementation summary at specs/1008_genuine_truth_at_completeness/summaries/04_completeness-summary.md
- [ ] Update file docstrings as needed

**Timing**: 1 hour

**Verification**:
- `lake build` exit code 0
- Sorry count documented
- Summary file complete

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `algebraic_base_completeness` compiles (Phase 3)
- [ ] `modal_backward` sorry eliminated (Phase 1)
- [ ] `forward_F` / `backward_P` sorries eliminated or clearly documented (Phase 2)
- [ ] No FlagBFMCS or satisfies_at references in active Theories/ (confirmed by Task 1007)
- [ ] All completeness uses `truth_at`, not `satisfies_at`

## Artifacts & Outputs

- `specs/1008_genuine_truth_at_completeness/plans/03_revised-completeness-plan.md` (this file)
- `specs/1008_genuine_truth_at_completeness/summaries/04_completeness-summary.md` (post-implementation)
- `Theories/Bimodal/Metalogic/Algebraic/OmegaSquaredChain.lean` (new — Phase 2)
- Updated `IntFMCSTransfer.lean`, `AlgebraicBaseCompleteness.lean`, `CanonicalEmbedding.lean`

## Rollback/Contingency

If omega-squared construction (Phase 2) proves intractable:
1. Skip Phase 2, accept forward_F/backward_P sorries
2. Phase 1 (modal saturation) is independent and should proceed
3. Phase 3 wires whatever improvements exist
4. The completeness theorem structure is already correct; sorries are infrastructure-only
5. Document the exact gap clearly for future work

The most likely partial outcome is: modal sorry eliminated (Phase 1), temporal sorries remain (Phase 2 contingency), dense progress (Phase 4). This still represents significant progress over current state.
