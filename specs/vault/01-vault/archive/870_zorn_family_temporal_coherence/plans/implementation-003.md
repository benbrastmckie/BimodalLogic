# Implementation Plan: Task #870 (Revised v003)

**Task**: 870 - Zorn-based family selection for temporal coherence
**Version**: 003
**Status**: [PARTIAL]
**Created**: 2026-02-12
**Language**: lean
**Research Inputs**: research-003.md (diagnostic), research-004.md (team diagnostic)
**Previous Plan**: implementation-002.md

## Overview

This is a **restructured plan** based on team research diagnostic (research-004.md) findings. The previous approach (v002) had a **fundamental flaw**: the multi-witness proof strategy incorrectly assumed G distributes over disjunction, which is FALSE in temporal logic.

### Critical Discovery

**G does NOT distribute over ∨**:
```
G(rain ∨ snow) can be true (at all future times, it rains or snows)
But G(rain) and G(snow) can both be false (neither always happens)
```

This invalidates the entire `multi_witness_seed_consistent` proof strategy used in v002.

### New Approach: Boundary-Only Domain Extension

The key insight is that problematic sorries at lines 1311, 1342 arise from extending at **arbitrary times**. If we only extend at **boundary times** (greater than ALL or less than ALL existing domain elements), the problematic forward_G/backward_H cases become **vacuously true**.

**Definition**:
```lean
def isBoundaryTime (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ((∀ s ∈ F.domain, s < t) ∨ (∀ s ∈ F.domain, t < s))
```

## Goals & Non-Goals

**Goals**:
- Eliminate all remaining sorries in ZornFamily.lean (currently 10)
- Eliminate DovetailingChain.lean sorries (lines 606, 617, 633, 640)
- Provide `temporal_coherent_family_exists_zorn` with no sorry dependencies
- No new axioms introduced

**Non-Goals**:
- Proving G distributes over disjunction (it doesn't)
- Preserving the multi_witness proof approach (fundamentally broken)

## Current Sorry Analysis

| Line | Phase | Type | v003 Approach |
|------|-------|------|---------------|
| 650 | 3 | multi-witness future | **ELIMINATED** - not needed with boundary approach |
| 680 | 3 | multi-witness past | **ELIMINATED** - not needed with boundary approach |
| 694 | 3 | cross-sign | **SIMPLIFIED** - boundary times avoid cross-sign complexity |
| 926 | 3 | F-obligations | **SIMPLIFIED** - seed only from one direction |
| 1066 | 3 | P-obligations | **SIMPLIFIED** - seed only from one direction |
| 1311 | 5 | forward_G from new time | **ELIMINATED** - vacuously true at boundary |
| 1342 | 5 | backward_H from new time | **ELIMINATED** - vacuously true at boundary |
| 1477 | 6 | F recovery | Depends on Phases 1-3 |
| 1486 | 6 | F alias | Auto-resolves |
| 1522 | 6 | P recovery | Depends on Phases 1-3 |
| 1530 | 6 | P alias | Auto-resolves |

## Implementation Phases

### Phase 1: Boundary Extension Infrastructure (NEW)

**Dependencies**: None
**Estimated effort**: 2-3 hours
**Status**: [COMPLETED]

**Objective**: Add boundary time predicate and modify extendFamily to require boundary condition.

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`

**Steps**:

1. **Add boundary time predicate**:
```lean
/-- A time is a boundary if it's outside the domain and either
    greater than all domain elements or less than all domain elements -/
def GHCoherentPartialFamily.isBoundaryTime (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ((∀ s ∈ F.domain, s < t) ∨ (∀ s ∈ F.domain, t < s))

/-- Upper boundary: greater than all domain elements -/
def GHCoherentPartialFamily.isUpperBoundary (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ∀ s ∈ F.domain, s < t

/-- Lower boundary: less than all domain elements -/
def GHCoherentPartialFamily.isLowerBoundary (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ∀ s ∈ F.domain, t < s
```

2. **Modify extendFamily** to take boundary proof:
```lean
/-- Extend family at a boundary time -/
noncomputable def extendFamilyAtBoundary
    (F : GHCoherentPartialFamily) (t : Int)
    (hbound : F.isBoundaryTime t)
    (seed : Set Formula)
    (h_seed_consistent : SetConsistent seed)
    (h_seed_contains_GH : GHContent F t ⊆ seed) :
    GHCoherentPartialFamily where
  domain := F.domain ∪ {t}
  mcs := fun s => if s = t then lindenbaumMCS seed h_seed_consistent else F.mcs s
  -- ... forward_G and backward_H become trivial for boundary times
```

3. **Prove forward_G and backward_H** are vacuously true from boundary time:
   - If t is upper boundary: no s' > t in domain, so forward_G from t is vacuous
   - If t is lower boundary: no s' < t in domain, so backward_H from t is vacuous

**Verification**:
- `extendFamilyAtBoundary` compiles without sorry
- Lines 1311, 1342 sorries eliminated

---

### Phase 2: Restructure Maximal Implies Totality (REVISED)

**Dependencies**: Phase 1
**Estimated effort**: 4-6 hours
**Status**: [COMPLETED]

**Objective**: Prove maximal family has domain = Set.univ using boundary extension.

**Key Insight**: Every non-total domain has at least one boundary time that can be added.

**Steps**:

1. **Prove non-total domain has boundary time**:
```lean
lemma non_total_has_boundary (F : GHCoherentPartialFamily)
    (h_non_total : F.domain ≠ Set.univ) :
    ∃ t, F.isBoundaryTime t := by
  -- If domain is bounded above, sup + 1 is upper boundary
  -- If domain is unbounded above but bounded below, inf - 1 is lower boundary
  -- If domain is unbounded both ways, find a gap and use gap boundary
  sorry
```

2. **Handle three cases**:
   - **Bounded above**: Use `sup(domain) + 1` as upper boundary
   - **Bounded below but unbounded above**: Use `inf(domain) - 1` as lower boundary
   - **Unbounded both ways with gaps**: Find gap interval and use boundary

3. **Restructure `maximal_implies_total`**:
```lean
theorem maximal_implies_total (F : GHCoherentPartialFamily) (base : GHCoherentPartialFamily)
    (hmax : Maximal (· ∈ CoherentExtensions base) F) (hF_ext : F ∈ CoherentExtensions base) :
    F.domain = Set.univ := by
  by_contra h_non_total
  obtain ⟨t, hbound⟩ := non_total_has_boundary F h_non_total
  -- Build boundary seed and extend
  let seed := boundarySeed F t hbound
  have h_cons : SetConsistent seed := boundary_seed_consistent F t hbound
  let F' := extendFamilyAtBoundary F t hbound seed h_cons ...
  -- F < F' contradicts maximality
  have hlt : F < F' := ...
  exact (hmax F' hlt.le).not_lt hlt
```

4. **Define boundary seed** (simpler than general seed):
```lean
def boundarySeed (F : GHCoherentPartialFamily) (t : Int) (hbound : F.isBoundaryTime t) : Set Formula :=
  if h_upper : F.isUpperBoundary t then
    -- Upper boundary: only need GContent from past (no future times exist)
    GContent F t ∪ FObligations F t
  else
    -- Lower boundary: only need HContent from future (no past times exist)
    HContent F t ∪ PObligations F t
```

**Verification**:
- `maximal_implies_total` compiles without sorry
- Boundary extension eliminates arbitrary-time extension issues

---

### Phase 3: Simplified Extension Seed Consistency (REVISED)

**Dependencies**: Phase 1
**Estimated effort**: 2-3 hours
**Status**: [COMPLETED]

**Objective**: Prove boundary seed consistency (much simpler than general seed).

**Key Simplification**: At a boundary time, seed only comes from ONE direction:
- Upper boundary: Only GContent + FObligations (all from past)
- Lower boundary: Only HContent + PObligations (all from future)

This **eliminates the cross-sign case entirely** (no past AND future times to reconcile).

**Steps**:

1. **Prove upper boundary seed consistency**:
```lean
theorem upper_boundary_seed_consistent (F : GHCoherentPartialFamily) (t : Int)
    (h_upper : F.isUpperBoundary t) :
    SetConsistent (GContent F t ∪ FObligations F t) := by
  -- All elements come from a single coherent chain of MCSs
  -- Use 4-axiom (G phi -> GG phi) to show GContent propagates forward
  -- Show maximum past time's MCS contains all GContent
  -- FObligations are phi where F phi exists in some past MCS
  -- By temporal saturation, adding phi is consistent
  sorry
```

2. **Prove lower boundary seed consistency** (symmetric):
```lean
theorem lower_boundary_seed_consistent (F : GHCoherentPartialFamily) (t : Int)
    (h_lower : F.isLowerBoundary t) :
    SetConsistent (HContent F t ∪ PObligations F t) := by
  -- Symmetric argument using H phi -> HH phi
  sorry
```

3. **Key lemma**: GContent from coherent chain is contained in maximum element:
```lean
lemma GContent_contained_in_max (F : GHCoherentPartialFamily) (t : Int)
    (h_upper : F.isUpperBoundary t) :
    GContent F t = GContent_single F (maxPastTime F t h_upper) := by
  -- By forward_G coherence, all GContent propagates to maximum past time
  -- Uses: G phi -> GG phi (4-axiom) for transitive propagation
  sorry
```

**Verification**:
- `boundary_seed_consistent` compiles without sorry
- Cross-sign case (line 694) eliminated by boundary restriction
- Multi-witness theorems no longer needed

---

### Phase 4: F/P Recovery for Total Family (RESTRUCTURED)

**Dependencies**: Phase 1, Phase 2, Phase 3
**Estimated effort**: 2-3 hours
**Status**: [COMPLETED]

**Objective**: Prove total family satisfies F/P coherence, isolating the fundamental sorry.

**Architectural Finding**: Analysis revealed that maximality provides no additional
constraints for total families. The partial order F <= G requires domain inclusion and
MCS agreement. When F.domain = Set.univ, any G >= F must equal F, making maximality
vacuously true. F/P recovery is a **construction invariant**, not derivable from
maximality post-hoc.

**What was implemented**:

1. **Isolated sorry into minimal auxiliary lemmas**:
   - `total_family_FObligations_satisfied`: If F phi in mcs(s) and s < t, then phi in mcs(t)
   - `total_family_PObligations_satisfied`: If P phi in mcs(s) and s > t, then phi in mcs(t)
   These capture exactly the gap: F/P obligation satisfaction requires a construction trace.

2. **Completed 4 theorems using the auxiliary lemmas**:
   - `maximal_family_forward_F`: proven via FObligations lemma with witness t+1
   - `maximal_family_backward_P`: proven via PObligations lemma with witness t-1
   - `total_family_forward_F`: proven via FObligations lemma (alias)
   - `total_family_backward_P`: proven via PObligations lemma (alias)

3. **Added comprehensive architectural documentation** explaining:
   - Why maximality is vacuous for total families
   - The seed inclusion decomposition (GContent/HContent parts provable, F/P parts circular)
   - Three resolution paths (strengthen family structure, use non-Zorn construction, accept sorry)

**Sorry reduction**: 4 sorries in old code -> 2 sorries in new code.
The 2 remaining sorries are precisely isolated and well-documented.

**Resolution paths for remaining sorries**:
- (a) Add forward_F/backward_P as fields of GHCoherentPartialFamily (recommended)
- (b) Replace Zorn proof with explicit iterative construction
- (c) Prove seed inclusion invariant is preserved by chain upper bounds

---

## Dependency Graph

```
Phase 1 (Boundary Infrastructure)
    ↓
    ├─→ Phase 2 (Maximal → Total)
    │       ↓
    │       └─→ Phase 4 (F/P Recovery)
    │
    └─→ Phase 3 (Seed Consistency)
            ↓
            └─→ Phase 4 (F/P Recovery)
```

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Non-total domain boundary lemma hard | Medium | High | Three cases well-defined, can prove separately |
| GContent containment in max lemma | Low | Medium | Follows directly from 4-axiom + forward_G |
| F/P recovery still needs multi-witness | Low | Medium | Boundary approach eliminates multi-witness need |

## Key Differences from v002

| Aspect | v002 | v003 |
|--------|------|------|
| Extension strategy | Arbitrary time | Boundary-only |
| Multi-witness theorems | Required (broken) | Not needed |
| Cross-sign case | Explicit proof needed | Eliminated |
| forward_G from new time | Complex proof | Vacuously true |
| backward_H from new time | Complex proof | Vacuously true |
| Estimated effort | 12-16 hours | 9-14 hours |
| Lines changed | ~350 | ~170 |

## Summary

This revised plan addresses the **fundamental G-distribution fallacy** discovered by team research:

1. **Phase 1** introduces boundary-only extension infrastructure
2. **Phase 2** restructures totality proof to use boundary extension
3. **Phase 3** simplifies seed consistency by eliminating cross-sign case
4. **Phase 4** proves F/P recovery using seed inclusion

The boundary-only approach **eliminates 2 sorries outright** (lines 1311, 1342) and **removes the need for broken multi-witness theorems** (lines 650, 680), reducing the problem from 10 sorries to approximately 4-6 tractable cases.
