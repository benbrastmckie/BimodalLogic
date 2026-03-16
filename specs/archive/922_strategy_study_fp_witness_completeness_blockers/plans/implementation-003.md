# Implementation Plan: Task #922 - Canonical Quotient Completeness Proof (v3)

- **Task**: 922 - strategy_study_fp_witness_completeness_blockers
- **Version**: 003
- **Created**: 2026-02-24
- **Status**: [IMPLEMENTING]
- **Effort**: 17-28 hours total (Phases A-D)
- **Dependencies**: Task 923 (canonical_reachable_linear, COMPLETED)
- **Research Inputs**: research-001.md, research-002.md, research-003.md, research-004.md (team research)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**v2 -> v3**: Phase 3 blocker (CanonicalR antisymmetry) resolved by research-004 team findings. This revision:

1. **Adopts Antisymmetrization quotient approach** (from Mathlib) instead of attempting direct antisymmetry proof
2. **Restructures into 4 phases** (A-D) reflecting the new approach
3. **Addresses strict-future-witness problem** identified as the TRUE remaining blocker
4. **Integrates key insight**: Mutually CanonicalR-related MCSes agree on ALL F and G formulas

### Key Research Findings (research-004)

| Finding | Confidence | Impact |
|---------|------------|--------|
| Antisymmetry is unprovable from temp_linearity | HIGH (85-90%) | Abandon direct proof approach |
| Use Mathlib's `Antisymmetrization` quotient | HIGH (90%) | Automatic LinearOrder from total preorder |
| Mutually R-related MCSes share F/G formulas | HIGH | BFMCS construction simplifies |
| Strict-future-witness is TRUE blocker | HIGH | Requires dedicated resolution strategy |

## Overview

This plan implements the **Antisymmetrization Quotient** approach for obtaining a LinearOrder on the canonical reachable fragment, then constructing an OrderIso to Int for BFMCS.

**Strategy**: Instead of proving antisymmetry directly (which team research confirmed is impossible), we:
1. Define a `Preorder` on `CanonicalReachable` via CanonicalR (reflexive + transitive)
2. Prove `IsTotal` from `canonical_reachable_comparable`
3. Form `Antisymmetrization` quotient using Mathlib infrastructure
4. Obtain `LinearOrder` automatically
5. Satisfy remaining prerequisites for `orderIsoIntOfLinearSuccPredArch`
6. Address strict-future-witness problem for BFMCS forward_F

### Research Integration

**From research-004 (team research)**:
- Verified Mathlib declarations: `Antisymmetrization`, `AntisymmRel.setoid`, `instLinearOrderAntisymmetrizationLe...`, `orderIsoIntOfLinearSuccPredArch`
- Verified project lemmas: `canonicalR_reflexive`, `canonicalR_transitive`, `canonical_reachable_comparable`, `gcontent_eq_of_mutual_R`
- Strict-future-witness analysis: G(phi) case resolved, fleeting phi case needs investigation

## Goals & Non-Goals

**Goals**:
- Obtain `LinearOrder` on canonical fragment via Antisymmetrization quotient
- Prove all prerequisites for `orderIsoIntOfLinearSuccPredArch`
- Construct `BFMCS Int` with zero sorries in forward_F/backward_P
- Achieve publication-quality completeness theorem

**Non-Goals**:
- Prove CanonicalR antisymmetry directly (confirmed impossible)
- Modify TruthLemma, BMCSTruth, or core Completeness modules
- Remove DovetailingChain sorries (they become dead code)
- Prove modal saturation constructively (existing axiom remains)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| NoMaxOrder proof complexity | High | 30% | Use fleeting formula existence; fallback to prove temporally-saturated = max class |
| NoMinOrder proof complexity | High | 30% | Symmetric to NoMaxOrder using P-formulas |
| IsSuccArchimedean complexity | Medium | 25% | Follows from countability + LocallyFiniteOrder; fallback to direct enumeration |
| Strict-future-witness failure | High | 35% | Multiple strategies: G propagation, modified witness seed, temporal saturation analysis |
| Quotient lifting complexity | Medium | 20% | Mathlib provides `Quotient.lift` with well-formedness proofs |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `DovetailingChain.lean`: `forward_F`, `backward_P` (become dead code)
- 1 sorry in `TemporalCoherentConstruction.lean`: `fully_saturated_bmcs_exists_int` (target)

### Expected Resolution
- Phase D replaces `fully_saturated_bmcs_exists_int` sorry with constructive proof
- DovetailingChain sorries become unreferenced (not in active dependency chain)
- Final sorry count in completeness chain: 0 (temporal components)

### New Sorries
- None permitted. Zero-sorry constraint is absolute.

---

## Implementation Phases

### Phase A: Quotient Construction for LinearOrder [COMPLETED]

- **Dependencies:** None
- **Goal:** Obtain `LinearOrder` on quotient of `CanonicalReachable` via Antisymmetrization
- **Estimated Effort:** 3-5 hours

**Approach**: Define Preorder on CanonicalReachable, prove IsTotal, form Antisymmetrization quotient.

**Tasks**:
1. [ ] Define `Preorder (CanonicalReachable M₀ h_mcs₀)` instance:
   - `le := fun a b => CanonicalR a.world b.world`
   - `le_refl := canonicalR_reflexive` (via is_mcs)
   - `le_trans := canonicalR_transitive` (via is_mcs)
2. [ ] Prove `IsTotal (CanonicalReachable M₀ h_mcs₀) (· ≤ ·)`:
   - Use `canonical_reachable_comparable` which gives `CanonicalR a b ∨ CanonicalR b a ∨ a = b`
   - The third case gives `le_refl` either way
3. [ ] Add `DecidableRel` instance for `(· ≤ ·)` via Classical:
   ```lean
   instance : DecidableRel (α := CanonicalReachable M₀ h_mcs₀) (· ≤ ·) :=
     fun a b => Classical.propDecidable _
   ```
4. [ ] Define `CanonicalQuotient M₀ h_mcs₀ := Antisymmetrization (CanonicalReachable M₀ h_mcs₀) (· ≤ ·)`
5. [ ] Verify `LinearOrder (CanonicalQuotient M₀ h_mcs₀)` instance exists (automatic from Mathlib)
6. [ ] Prove `Nonempty (CanonicalQuotient M₀ h_mcs₀)`:
   - Lift from `Nonempty (CanonicalReachable M₀ h_mcs₀)`

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean` - add Preorder, IsTotal, Decidable instances
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` (new) - quotient definition

**Verification**:
- `LinearOrder (CanonicalQuotient M₀ h_mcs₀)` typeclass resolved
- `lake build` succeeds with zero sorries

**Progress:**

**Session: 2026-02-24, sess_1771971511_c8eb47**
- Added: `Preorder (CanonicalReachable M₀ h_mcs₀)` instance via CanonicalR
- Added: `IsTotal`, `DecidableRel`, `Std.Total` instances for total preorder
- Added: `CanonicalQuotient` as `Antisymmetrization` quotient with `LinearOrder`
- Added: `CanonicalQuotient.mk`, `CanonicalQuotient.repr` with ordering correspondence lemmas
- Added: `quotient_eq_of_mutual_R`, `quotient_gcontent_eq` for equivalence class properties
- Added: `canonicalR_successor_quotient_le/lt` for successor lifting
- Completed: Phase A - all 6 tasks done, `LinearOrder` verified on quotient
- Sorries: 0

---

### Phase B: OrderIso Prerequisites [BLOCKED]

- **Dependencies:** Phase A
- **Goal:** Prove all prerequisites for `orderIsoIntOfLinearSuccPredArch` on CanonicalQuotient
- **Estimated Effort:** 6-10 hours

**Prerequisites from Mathlib**:
```lean
orderIsoIntOfLinearSuccPredArch :
  (α : Type*) → [Nonempty α] → [LinearOrder α] → [SuccOrder α] → [PredOrder α] →
  [IsSuccArchimedean α] → [NoMaxOrder α] → [NoMinOrder α] → α ≃o ℤ
```

**Tasks**:
1. [ ] Prove `Countable (CanonicalQuotient M₀ h_mcs₀)`:
   - Formula is Countable
   - Set Formula with MCS property is Countable (determined by theory)
   - CanonicalReachable is Countable (subtype)
   - Quotient of Countable is Countable
2. [ ] Prove `NoMaxOrder (CanonicalQuotient M₀ h_mcs₀)`:
   - For any equivalence class [M], find a STRICTLY GREATER class [M']
   - Key strategy: Find fleeting formula phi such that F(phi) in M but phi NOT in M
   - Apply canonical_forward_F_strict to get distinct successor
   - Lift to quotient: need successor NOT in same equivalence class
   - Use: if M' mutually R-related to M, then gcontent_eq, hence same F-formulas
   - So if phi in M' and phi NOT in M, then NOT mutually R-related
3. [ ] Prove `NoMinOrder (CanonicalQuotient M₀ h_mcs₀)`:
   - Symmetric using P-formulas and canonical_backward_P_strict
4. [ ] Define `SuccOrder (CanonicalQuotient M₀ h_mcs₀)`:
   - Option A: Derive from Countable + LinearOrder + NoMaxOrder via LocallyFiniteOrder
   - Option B: Direct construction using well-founded minimum on {y | x < y}
5. [ ] Define `PredOrder (CanonicalQuotient M₀ h_mcs₀)`:
   - Symmetric to SuccOrder
6. [ ] Prove `IsSuccArchimedean (CanonicalQuotient M₀ h_mcs₀)`:
   - For any a < b, exists n such that succ^n(a) = b or succ^n(a) > b
   - Follows from: Countable + LinearOrder implies LocallyFiniteOrder
   - LocallyFiniteOrder + LinearOrder implies IsSuccArchimedean

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` - all prerequisites

**Verification**:
- All prerequisite typeclasses resolved
- `lake build` succeeds with zero sorries

---

### Phase C: OrderIso Construction and BFMCS Scaffolding [NOT STARTED]

- **Dependencies:** Phase B
- **Goal:** Construct OrderIso to Int and define BFMCS structure
- **Estimated Effort:** 4-6 hours

**Tasks**:
1. [ ] Apply `orderIsoIntOfLinearSuccPredArch` to obtain:
   ```lean
   canonicalOrderIso : CanonicalQuotient M₀ h_mcs₀ ≃o ℤ
   ```
2. [ ] Define quotient-to-MCS representative function:
   ```lean
   def quotientRepresentative : CanonicalQuotient M₀ h_mcs₀ → Set Formula :=
     fun q => (ofAntisymmetrization _ q).world
   ```
3. [ ] Define `canonicalMCS : ℤ → Set Formula`:
   ```lean
   def canonicalMCS : ℤ → Set Formula :=
     fun n => quotientRepresentative (canonicalOrderIso.symm n)
   ```
4. [ ] Prove `canonicalMCS n` is MCS for all n:
   - Lift from CanonicalReachable.is_mcs property
5. [ ] Prove ordering preservation:
   - `n < m ↔ CanonicalR (canonicalMCS n) (canonicalMCS m)` (up to equivalence class)
6. [ ] Define `canonicalBFMCS_mcs : BFMCS.MCSProperty canonicalMCS`:
   - Prove all positions are MCS

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` - OrderIso
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` (new) - BFMCS scaffolding

**Verification**:
- `canonicalOrderIso` constructed without sorry
- `canonicalMCS` function defined and proven to yield MCSes
- `lake build` succeeds with zero sorries

---

### Phase D: BFMCS Temporal Properties and Integration [NOT STARTED]

- **Dependencies:** Phase C
- **Goal:** Prove all BFMCS temporal properties and replace completeness sorry
- **Estimated Effort:** 4-7 hours

**BFMCS Requirements**:
```lean
structure BFMCS (T : Type*) [LinearOrder T] where
  mcs : T → Set Formula
  mcs_property : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ∀ t s phi, t < s → Formula.all_future phi ∈ mcs t → phi ∈ mcs s
  backward_H : ∀ t s phi, s < t → Formula.all_past phi ∈ mcs t → phi ∈ mcs s
  forward_F : ∀ t phi, Formula.some_future phi ∈ mcs t → ∃ s, t < s ∧ phi ∈ mcs s
  backward_P : ∀ t phi, Formula.some_past phi ∈ mcs t → ∃ s, s < t ∧ phi ∈ mcs s
```

**Tasks**:
1. [ ] Prove `forward_G` property:
   - If G(phi) in canonicalMCS(t) and t < s, then phi in canonicalMCS(s)
   - Use: t < s iff CanonicalR (canonicalMCS t) (canonicalMCS s)
   - Apply canonical_forward_G (trivial by GContent definition)
2. [ ] Prove `backward_H` property:
   - Symmetric using CanonicalR_past and canonical_backward_H
3. [ ] Prove `forward_F` property (**KEY - strict-future-witness**):

   **Case analysis for F(phi) in canonicalMCS(t)**:

   **Case A: G(phi) in canonicalMCS(t)**
   - phi propagates to ALL future positions via forward_G
   - Use s = t + 1 (exists by NoMaxOrder)
   - Done: phi in canonicalMCS(t+1) by forward_G

   **Case B: G(phi) NOT in canonicalMCS(t)** (fleeting phi)
   - Apply canonical_forward_F to get witness W with phi in W and CanonicalR(canonicalMCS(t), W)
   - W corresponds to some position s via OrderIso
   - Need to prove s > t (strict inequality)

   **Sub-case B1: W = canonicalMCS(t)** (same equivalence class)
   - Then phi in canonicalMCS(t)
   - Since G(phi) NOT in canonicalMCS(t), we have F(neg(phi)) in canonicalMCS(t)
   - Apply canonical_forward_F to get W' with neg(phi) in W' and CanonicalR(canonicalMCS(t), W')
   - W' corresponds to position s'
   - If W' in same class as canonicalMCS(t): neg(phi) in canonicalMCS(t), contradiction with phi in canonicalMCS(t)
   - So s' > t (strictly greater equivalence class)
   - Now use forward_G with G(phi)... wait, G(phi) NOT in canonicalMCS(t)
   - ALTERNATIVE: Since phi in canonicalMCS(t) and F(phi) in canonicalMCS(t):
     - Use successor s = t + 1 (exists by NoMaxOrder)
     - Need phi in canonicalMCS(t+1)
     - G(phi) NOT in canonicalMCS(t) means we cannot use forward_G
     - **KEY INSIGHT**: The representative at t+1 is CHOSEN from the equivalence class
     - If the equivalence class [M_{t+1}] contains an MCS with phi, we can choose that representative
     - Actually, ofAntisymmetrization gives SOME representative, not necessarily one with phi
     - **RESOLUTION STRATEGY**: Prove phi is in ALL members of the equivalence class:
       - Mutually R-related MCSes share GContent
       - F(phi) = neg(G(neg(phi))), so phi in GContent iff G(neg(phi)) NOT in GContent
       - If G(phi) NOT in M, need to check if phi still shared across equivalence class
       - Actually: gcontent_eq_of_mutual_R shows G-formulas shared, hence F-formulas shared (since F(x) = neg(G(neg(x))))
       - But phi itself may not be a G or F formula...
       - **DEEPER ANALYSIS NEEDED**: Is phi shared across equivalence classes?

   **Sub-case B2: W in different equivalence class**
   - Then [W] > [canonicalMCS(t)] or [W] < [canonicalMCS(t)]
   - CanonicalR(canonicalMCS(t), W) means CanonicalR holds
   - LinearOrder: either CanonicalR both ways (same class) or strict inequality
   - If NOT same class and CanonicalR(canonicalMCS(t), W), then [W] > [canonicalMCS(t)]
   - So s > t. Done: phi in canonicalMCS(s).

4. [ ] Prove `backward_P` property:
   - Symmetric using CanonicalR_past

5. [ ] Assemble `canonicalBFMCS : BFMCS Int`:
   ```lean
   def canonicalBFMCS : BFMCS ℤ where
     mcs := canonicalMCS
     mcs_property := canonicalMCS_is_mcs
     forward_G := canonicalBFMCS_forward_G
     backward_H := canonicalBFMCS_backward_H
     forward_F := canonicalBFMCS_forward_F
     backward_P := canonicalBFMCS_backward_P
   ```

6. [ ] Wire into `temporal_coherent_family_exists_Int`:
   - Replace sorry with `canonicalBFMCS` construction
   - Verify interface compatibility with TemporalCoherentConstruction.lean

7. [ ] Run `lake build` and verify no errors

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - temporal properties
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - replace sorry

**Verification**:
- `canonicalBFMCS` constructed without sorry
- `temporal_coherent_family_exists_Int` proven without sorry
- `lake build` succeeds with 0 errors
- Completeness theorem compiles

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase completion
- [ ] No sorries introduced in new files
- [ ] LinearOrder on CanonicalQuotient verified (Phase A)
- [ ] All OrderIso prerequisites satisfied (Phase B)
- [ ] OrderIso constructed (Phase C)
- [ ] BFMCS temporal properties proven (Phase D)
- [ ] `Completeness.lean` compiles with new BFMCS construction
- [ ] `lean_verify` on completeness theorem shows clean axiom dependencies

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean` (Phase A: add instances)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` (Phase A-B: new)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` (Phase C-D: new)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (Phase D: replace sorry)
- `specs/922_strategy_study_fp_witness_completeness_blockers/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

1. **Phase A quotient complexity**: If Antisymmetrization API is difficult, define equivalence relation manually:
   ```lean
   def CanonicalEquiv (a b : CanonicalReachable M₀ h_mcs₀) : Prop :=
     CanonicalR a.world b.world ∧ CanonicalR b.world a.world
   ```
   Then use Quotient directly.

2. **Phase B NoMaxOrder failure**: If fleeting formula strategy fails, prove temporally-saturated MCSes form the max equivalence class and are excluded by the quotient (no max element in quotient).

3. **Phase B IsSuccArchimedean failure**: Construct enumeration manually using countability (back-and-forth argument on intervals).

4. **Phase D strict-future-witness failure**: Multiple fallback strategies:
   - Strategy 1: Modify witness seed to include phi AND F(phi), forcing non-trivial successor
   - Strategy 2: Prove equivalence classes are singletons (phi shared across class)
   - Strategy 3: Use different representative selection with phi-preservation property

## Critical Success Factors

1. **Quotient construction must yield LinearOrder**: This is guaranteed by Mathlib's Antisymmetrization + IsTotal.

2. **NoMaxOrder/NoMinOrder proofs must succeed**: These are prerequisites for `orderIsoIntOfLinearSuccPredArch`. Phase B allocates dedicated time.

3. **Zero sorries in new code**: Absolute constraint. Every phase produces sorry-free Lean code.

4. **Strict-future-witness resolution**: The TRUE remaining blocker identified by research-004. Phase D addresses this with multiple strategies.

5. **Preserve existing interface**: TemporalCoherentFamily interface unchanged. Only internal construction changes.

## Technical Notes

### Why Antisymmetrization Works

The antisymmetrization quotient identifies elements a, b when both a ≤ b and b ≤ a. For CanonicalR:
- `AntisymmRel (· ≤ ·) a b ↔ CanonicalR a b ∧ CanonicalR b a`
- This is exactly "mutually CanonicalR-related"
- Research-004 confirmed: such MCSes share GContent (and F-formulas)
- The quotient collapses these into single points
- IsTotal on the preorder lifts to LinearOrder on the quotient

### Strict-Future-Witness Deep Analysis

The problem: F(phi) in M means "phi at some future time". In the canonical model, the witness might be M itself (reflexivity). For BFMCS Int, we need phi at a STRICTLY later integer position.

**Resolution insight from research-004**: The quotient handles this naturally!

- If the witness W is in the SAME equivalence class as M, then W and M share GContent
- F-formulas are negations of G-formulas: F(phi) = neg(G(neg(phi)))
- If F(phi) in M, and W is in same class, then F(phi) in W too
- The successor position (next equivalence class) exists by NoMaxOrder
- Need to show phi reaches the successor

**Alternative approach**: Prove that if phi is "fleeting" (F(phi) in M but G(phi) NOT in M), then the canonical_forward_F witness is NOT in the same equivalence class as M. This would give s > t directly.
