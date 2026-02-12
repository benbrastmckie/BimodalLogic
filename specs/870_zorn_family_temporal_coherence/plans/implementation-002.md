# Implementation Plan: Task #870 (Revised)

- **Task**: 870 - Zorn-based family selection for temporal coherence
- **Version**: 002
- **Status**: [IMPLEMENTING]
- **Effort**: 12-16 hours (3-4 sessions)
- **Dependencies**: None (builds on existing ZornFamily.lean infrastructure)
- **Research Inputs**: research-002.md, research-003.md (diagnostic)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean

## Overview

This is a **restructured plan** based on diagnostic analysis (research-003.md) of the first implementation attempt. The original plan failed due to three fundamental issues:

1. **Base Family Impossibility**: Singleton domain `{0}` cannot satisfy F/P
2. **Zorn Type Mismatch**: Custom `le` function instead of `Preorder` instance
3. **4-Axiom Gap**: Seed consistency needs `G phi -> GG phi` propagation

### Key Design Change

**Remove F/P from CoherentPartialFamily structure entirely.**

The original structure required `forward_F` and `backward_P` to hold for partial families, which is impossible for singleton domains. The revised approach:

1. Partial families only require G/H coherence (universal properties)
2. F/P becomes a derived property for **total** (maximal) families only
3. F/P obligations are added to extension seeds during Zorn iteration

This change simplifies the entire construction and eliminates the base family impossibility.

## Goals & Non-Goals

**Goals**:
- Eliminate all 4 sorries in DovetailingChain.lean (lines 606, 617, 633, 640)
- Eliminate all 8 sorries in current ZornFamily.lean
- Provide `temporal_coherent_family_exists_zorn` with no sorry dependencies
- No new axioms introduced

**Non-Goals**:
- Preserving exact current ZornFamily.lean structure (will be refactored)
- Modifying IndexedMCSFamily interface

## Implementation Phases

### Phase 1: Restructure CoherentPartialFamily [COMPLETED]

**Goal**: Remove F/P fields from structure, add Preorder instance.

**Tasks**:
- [ ] Remove `forward_F` and `backward_P` fields from `CoherentPartialFamily`
- [ ] Rename to `GHCoherentPartialFamily` (clearer intent)
- [ ] Update all dependent lemmas (chain upper bound, etc.)
- [ ] Add `Preorder GHCoherentPartialFamily` instance using existing `le` proofs
- [ ] Verify chain upper bound still holds (should be simpler)

**Key Change**:
```lean
-- BEFORE (too strong for partial domains):
structure CoherentPartialFamily where
  ...
  forward_F : ∀ t, t ∈ domain → ∀ phi, F phi ∈ mcs t → ∃ s, s ∈ domain ∧ t < s ∧ phi ∈ mcs s
  backward_P : ∀ t, t ∈ domain → ∀ phi, P phi ∈ mcs t → ∃ s, s ∈ domain ∧ s < t ∧ phi ∈ mcs s

-- AFTER (only G/H coherence):
structure GHCoherentPartialFamily where
  domain : Set Int
  mcs : Int → Set Formula
  domain_nonempty : domain.Nonempty
  is_mcs : ∀ t, t ∈ domain → SetMaximalConsistent (mcs t)
  forward_G : ∀ t t', t ∈ domain → t' ∈ domain → t < t' → ∀ phi, G phi ∈ mcs t → phi ∈ mcs t'
  backward_H : ∀ t t', t' ∈ domain → t ∈ domain → t' < t → ∀ phi, H phi ∈ mcs t → phi ∈ mcs t'

instance : Preorder GHCoherentPartialFamily where
  le := GHCoherentPartialFamily.le
  le_refl := ...
  le_trans := ...
```

**Timing**: 2 hours

**Verification**:
- `lake build` succeeds
- No more `buildBaseFamily.forward_F` or `backward_P` sorries

---

### Phase 2: Simplify Base Family [COMPLETED]

**Goal**: Build base family with domain={0}, no F/P requirements.

**Tasks**:
- [ ] Simplify `buildBaseFamily` to only prove G/H coherence
- [ ] For singleton domain {0}, G/H coherence is vacuous (no t < t' pairs)
- [ ] Remove the 2 sorries at lines 606, 610

**Key Simplification**:
```lean
noncomputable def buildBaseFamily (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    GHCoherentPartialFamily where
  domain := {0}
  mcs := fun _ => lindenbaumMCS (contextAsSet Gamma) h_cons
  domain_nonempty := ⟨0, rfl⟩
  is_mcs := fun t ht => by simp at ht; subst ht; exact lindenbaumMCS_is_mcs
  forward_G := fun t t' ht ht' hlt => by
    simp at ht ht'  -- Both t = 0 and t' = 0, but hlt : t < t'
    omega  -- Contradiction: 0 < 0 is false
  backward_H := fun t t' ht ht' hlt => by
    simp at ht ht'
    omega  -- Same contradiction
```

**Timing**: 1 hour

**Verification**:
- `buildBaseFamily` compiles without sorry
- No F/P requirements to satisfy

---

### Phase 3: Extension Seed with F/P Obligations [PARTIAL]

**Goal**: Add F/P witness formulas to extension seed.

**Tasks**:
- [ ] Define `FObligations` and `PObligations` collectors
- [ ] Add to extension seed construction
- [ ] Prove extended seed consistency (G/H content + F/P witnesses)
- [ ] Use 4-axiom lemmas for GContent propagation proof

**Key Addition to Seed**:
```lean
-- F obligations: formulas that need witnesses at future times
def FObligations (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  { phi | ∃ s, s ∈ F.domain ∧ s < t ∧ Formula.some_future phi ∈ F.mcs s }

-- P obligations: formulas that need witnesses at past times
def PObligations (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  { phi | ∃ s, s ∈ F.domain ∧ t < s ∧ Formula.some_past phi ∈ F.mcs s }

-- Complete extension seed
def extensionSeed (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  GContent F t ∪ HContent F t ∪ FObligations F t ∪ PObligations F t
```

**Seed Consistency Proof Strategy**:

The key insight: F/P obligations are CONSISTENT with G/H content because:
- If `F phi ∈ mcs(s)` for s < t, then by temporal saturation of mcs(s), `phi` is consistent with mcs(s)
- G content from mcs(s) includes formulas consistent with phi (otherwise mcs(s) would be inconsistent)
- Therefore adding phi to the seed doesn't create inconsistency

**Use 4-axiom for GContent consistency**:
```lean
-- From Axiom.lean:
-- temp_4_future : G phi -> GG phi
-- temp_4_past : H phi -> HH phi

-- If G phi ∈ mcs(s) and s < s' < t, then:
-- GG phi ∈ mcs(s)  by temp_4_future
-- G phi ∈ mcs(s')  by forward_G
-- Therefore all G-content from past times is contained in largest past time's G-content
```

**Timing**: 3-4 hours

**Verification**:
- `extensionSeed_consistent` compiles without sorry
- All 3 original seed consistency sorries eliminated

---

### Phase 4: Zorn Application [COMPLETED]

**Goal**: Apply Mathlib's Zorn lemma to get maximal family.

**Tasks**:
- [ ] Use `zorn_le_nonempty` with Preorder instance
- [ ] Prove chain upper bound is in `CoherentExtensions`
- [ ] Extract maximal element and its properties

**Key Structure**:
```lean
def CoherentExtensions (base : GHCoherentPartialFamily) : Set GHCoherentPartialFamily :=
  { F | base ≤ F }

theorem zorn_gives_maximal (base : GHCoherentPartialFamily) :
    ∃ F, base ≤ F ∧ ∀ G, F ≤ G → G ≤ F :=
  zorn_le_nonempty (CoherentExtensions base) ⟨base, le_refl base⟩
    (fun C hC_chain hC_ne => ⟨chainUpperBound C, ..., ...⟩)
```

**Timing**: 2-3 hours

**Verification**:
- `maximalCoherentFamily` compiles without sorry
- All 3 Zorn-related sorries eliminated

---

### Phase 5: Maximality Implies Totality [PARTIAL]

**Goal**: Prove maximal family has domain = Set.univ.

**Tasks**:
- [ ] Assume maximal F with some t ∉ F.domain
- [ ] Construct extension seed for t
- [ ] Apply Lindenbaum to get MCS at t
- [ ] Build extended family F' with domain' = F.domain ∪ {t}
- [ ] Prove F < F' (strict)
- [ ] Contradiction with maximality

**Key Lemma**:
```lean
theorem maximal_implies_total (F : GHCoherentPartialFamily)
    (hmax : ∀ G, F ≤ G → G ≤ F) :
    F.domain = Set.univ := by
  by_contra h
  push_neg at h
  obtain ⟨t, ht⟩ := Set.not_univ_iff_exists_not_mem.mp h
  -- Build F' extending F to include t
  let seed := extensionSeed F t
  have h_cons : SetConsistent seed := extensionSeed_consistent F t
  let mcs_t := lindenbaumMCS seed h_cons
  let F' := extendFamily F t mcs_t ...
  -- F < F' contradicts maximality
  have hlt : F < F' := ...
  exact (hmax F' hlt.le).not_lt hlt
```

**Timing**: 3-4 hours

**Verification**:
- `maximal_implies_total` compiles without sorry

---

### Phase 6: F/P Recovery for Total Family [PARTIAL]

**Goal**: Prove that a total GH-coherent family also satisfies F/P.

**Tasks**:
- [ ] Define `TotalGHCoherentFamily` (domain = Set.univ)
- [ ] Prove `forward_F` for total family
- [ ] Prove `backward_P` for total family
- [ ] Build final `IndexedMCSFamily` from total family
- [ ] State and prove `temporal_coherent_family_exists_zorn`

**Key Insight for F/P Recovery**:

For a total family with domain = Set.univ:
- If `F phi ∈ mcs(t)`, then phi was included in the seed for time t+1 (as an F-obligation)
- Therefore `phi ∈ mcs(t+1)` by Lindenbaum (seed ⊆ MCS)
- So t+1 is the witness for F phi at t

```lean
theorem total_family_forward_F (F : GHCoherentPartialFamily)
    (htotal : F.domain = Set.univ) (t : Int) (phi : Formula)
    (hF : Formula.some_future phi ∈ F.mcs t) :
    ∃ s, t < s ∧ phi ∈ F.mcs s := by
  use t + 1
  constructor
  · omega
  · -- phi was in F-obligations for time t+1
    -- Therefore phi ∈ seed(t+1) ⊆ mcs(t+1)
    ...
```

**Timing**: 3-4 hours

**Verification**:
- `temporal_coherent_family_exists_zorn` compiles without sorry
- All 8 ZornFamily.lean sorries eliminated
- All 4 DovetailingChain.lean sorries can be replaced

---

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] No new `axiom` declarations introduced
- [ ] Sorry count in ZornFamily.lean: 0 (was 8)
- [ ] `temporal_coherent_family_exists_zorn` has no sorry dependencies
- [ ] Integration: DovetailingChain sorries can be replaced

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| F/P recovery proof harder than expected | Medium | High | F-obligation in seed ensures witness exists by construction |
| Seed consistency still complex | Low | Medium | Simplified by removing F/P from structure invariant |
| 4-axiom usage complications | Low | Low | Lemmas already exist in Axiom.lean |

## Rollback/Contingency

If full implementation proves infeasible:
1. Phases 1-5 provide a G/H-only coherent family (still useful)
2. F/P can remain as separate sorry (2 of original 4)
3. Cross-sign sorries (606, 617) are eliminated by G/H coherence

## Key Differences from v001

| Aspect | v001 | v002 |
|--------|------|------|
| F/P in structure | Required for partial families | Not required (derived for total) |
| Base family | Singleton with F/P sorries | Singleton with vacuous G/H |
| Zorn integration | Custom `le` function | `Preorder` instance |
| Complexity | 8 sorries, 3 root causes | Eliminates all root causes |
| Estimated effort | 18-22 hours | 12-16 hours |

## Summary

This revised plan addresses all three root causes identified in research-003.md:
1. **Base impossibility** → Removed by eliminating F/P from structure
2. **Zorn type mismatch** → Fixed by adding Preorder instance
3. **4-axiom gap** → Isolated to seed consistency, cleaner proof path

The key insight is that F/P are **existential** properties that only make sense for total families, while G/H are **universal** properties that work for partial families.
