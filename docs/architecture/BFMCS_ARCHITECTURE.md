# BFMCS Proof Architecture

**Version**: 1.0
**Date**: 2026-02-20
**Related Tasks**: Task 914 (BFMCS rename), Task 915 (this documentation), Task 916 (F/P witness tracking)

## Executive Summary

The TM logic completeness proof uses a **two-level bundling architecture** to model both temporal and modal aspects of formulas:

1. **FMCS (Family of MCS)**: A single "world history" - one maximal consistent set (MCS) per time point with temporal coherence conditions ensuring G/H formulas propagate correctly.

2. **BFMCS (Bundle of FMCS)**: A collection of world histories with modal coherence conditions ensuring Box/Diamond formulas relate correctly across histories.

**Key insight**: G-content propagates automatically through seeding (the 4_G axiom ensures G(phi) -> G(G(phi))), while F-obligations require explicit witness tracking because F(phi) -> G(F(phi)) is semantically invalid.

**Current status**: Complete and sorry-free. The structural sorry inventory is **zero** across
all of `FormalSystem/` (`Boneyard/` excluded), asserted by content in check C3 of
`scripts/check-module-invariants.sh`. The four weak completeness theorems this architecture
supports -- `completeness`, `completeness_dense`, `completeness_discrete`,
`completeness_dedekind` -- are sorryAx-free at exactly `[propext, Classical.choice,
Quot.sound]`, asserted by check C2.

---

## Table of Contents

1. [Ontology Overview](#1-ontology-overview)
   - [FMCS: Single World History](#11-fmcs-single-world-history)
   - [BFMCS: Bundle of World Histories](#12-bfmcs-bundle-of-world-histories)
   - [Why Two Levels?](#13-why-two-levels)
2. [Propagation Mechanics](#2-propagation-mechanics)
   - [G-Content Automatic Propagation](#21-g-content-automatic-propagation)
   - [F-Obligations Require Tracking](#22-f-obligations-require-tracking)
   - [Propagation Summary Table](#23-propagation-summary-table)
3. [Consistency Theory](#3-consistency-theory)
   - [The witness-seed consistency theorems](#31-the-witness-seed-consistency-theorems)
   - [The Critical Subtlety](#32-the-critical-subtlety)
4. [Completeness Chain](#4-completeness-chain)
   - [Proof Architecture](#41-proof-architecture)
   - [Key Source Files](#42-key-source-files)

---

## 1. Ontology Overview

### 1.1 FMCS: Single World History

An **FMCS** (Family of Maximal Consistent Sets) represents a single complete "world history" --
one MCS at each time point, with temporal coherence. The carrier `D` is a `Preorder`, not
fixed to `Int`.

**Definition** (from `FormalSystem/Metalogic/Bundle/FMCSDef.lean`, line 103):

```lean
structure FMCS (fc : FrameClass := FrameClass.Base) where
  mcs : D -> Set Formula             -- MCS at each time point
  is_mcs : forall t, SetMaximalConsistent (fc := fc) (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.allFuture phi ∈ mcs t -> phi ∈ mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.allPast phi ∈ mcs t -> phi ∈ mcs t'
```

**Semantic interpretation**:
- Each time point `t` has a maximal consistent set `mcs t` describing "what is true at time t"
- `forward_G`: If G(phi) holds at time t, then phi holds at all future times t' > t
- `backward_H`: If H(phi) holds at time t, then phi holds at all past times t' < t

Note that the structure carries **only** the two universal (G/H) coherence fields. Existential
F/P witness obligations are *not* structure fields; they are discharged by the witness-seed
infrastructure (`WitnessSeed.lean`) at the point of construction. Earlier `forward_F` and
`backward_P` fields were removed -- see the design note at `FMCSDef.lean:58`.

**Visual representation**:
```
Time:    ... -2   -1    0    1    2    3 ...
              |    |    |    |    |    |
MCS:        M_{-2} M_{-1} M_0  M_1  M_2  M_3
              ^---------^---------^
              Temporal coherence constraints
```

### 1.2 BFMCS: Bundle of World Histories

A **BFMCS** (Bundle of Families of MCS) is a collection of FMCS structures (world histories)
with modal coherence.

**Definition** (from `FormalSystem/Metalogic/Bundle/BFMCS.lean`, line 91):

```lean
structure BFMCS (fc : FrameClass := FrameClass.Base) where
  families : Set (FMCS (fc := fc) D)   -- Collection of world histories
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    Formula.box phi ∈ fam.mcs t -> forall fam' in families, phi ∈ fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi ∈ fam'.mcs t) -> Formula.box phi ∈ fam.mcs t
  evalFamily : FMCS (fc := fc) D       -- Distinguished evaluation point
  eval_family_mem : evalFamily ∈ families
```

**Semantic interpretation**:
- `families`: Set of possible world histories
- `modal_forward`: Box(phi) at time t in any history means phi at time t in ALL histories
- `modal_backward`: phi at time t in ALL histories means Box(phi) at time t in each history
- `evalFamily`: The "actual" world history used for evaluation

**Visual representation**:
```
       History 1:   M^1_{-1} --- M^1_0 --- M^1_1 --- M^1_2
                        |           |         |         |
       History 2:   M^2_{-1} --- M^2_0 --- M^2_1 --- M^2_2
                        |           |         |         |
       History 3:   M^3_{-1} --- M^3_0 --- M^3_1 --- M^3_2
                        ^           ^         ^         ^
                     Modal coherence (Box/Diamond) at each time
```

### 1.3 Why Two Levels?

TM logic has both **modal operators** (Box, Diamond) and **temporal operators** (G, H, F, P). These require different structural constraints:

| Operator Type | Operators | Constraint Direction | Structure Level |
|---------------|-----------|---------------------|-----------------|
| Modal | Box, Diamond | Across histories (at same time) | BFMCS |
| Temporal | G, H, F, P | Within history (across times) | FMCS |

**The key insight**: Modal operators relate different "possible worlds" at the same time instant, while temporal operators relate the same "possible world" across different time instants. The two-level structure cleanly separates these concerns.

---

## 2. Propagation Mechanics

### 2.1 G-Content Automatic Propagation

**Definition** (from `TemporalContent.lean`, lines 19-26):

```lean
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.allFuture phi ∈ M}

def HContent (M : Set Formula) : Set Formula :=
  {phi | Formula.allPast phi ∈ M}
```

**Construction mechanism**:
When building `MCS_{t+1}`, the **seed** includes `GContent(MCS_t)`:
1. Extract all formulas phi where G(phi) is in MCS_t
2. Include these in the seed for MCS_{t+1}
3. Use Lindenbaum extension to complete the seed to a full MCS

**Why G propagates automatically** (the 4_G axiom):
```
Axiom 4_G:  G(phi) -> G(G(phi))
```

This axiom ensures that if G(phi) is in MCS_t:
1. G(G(phi)) is also in MCS_t (by MCS closure under the axiom)
2. Therefore G(phi) is in GContent(MCS_t)
3. Therefore G(phi) is in the seed for MCS_{t+1}
4. Therefore G(phi) is in MCS_{t+1}
5. The propagation continues inductively to all future times

**Proven anchors** (both archived with the rest of the canonical-frame half of `Bundle/`; see
`FormalSystem/Boneyard/BundleDeadHalf/README.md`):
```lean
-- FormalSystem/Boneyard/BundleDeadHalf/SuccRelation.lean:78 (archived)
theorem Succ.g_persistence {u v : Set Formula} (h : Succ u v) : GContent u ⊆ v

-- FormalSystem/Boneyard/BundleDeadHalf/CanonicalFrame.lean:77 (archived)
@[simp] lemma ExistsTask_def {M M' : Set Formula} : ExistsTask M M' = (GContent M ⊆ M')
```

Step (5) -- that the propagation continues to all future times, not just the next -- is the
`forward_G` field of `FMCS` itself (`FormalSystem/Metalogic/Bundle/FMCSDef.lean:103`), which any
constructed family must discharge.

### 2.2 F-Obligations Require Tracking

The formula `F(psi) -> G(F(psi))` is **NOT derivable** in TM logic. In fact, it is semantically invalid.

**Counter-example**:
Consider a world where psi holds at exactly time 5:
- At time 0: F(psi) is true (psi will hold at time 5)
- At time 6: F(psi) is false (psi held in the past, not the future)

Therefore F(psi) does not persist into the future - it can become false after the witness time passes.

**Consequence for construction**:
F-obligations cannot be propagated through GContent seeding. They must be:
1. **Tracked explicitly** as "promises" to be fulfilled
2. **Scheduled** for resolution at specific future times
3. **Placed in seeds** when their scheduled resolution time arrives

This is the core challenge addressed by the dovetailing construction.

### 2.3 Propagation Summary Table

| Operator | Name | Type | Propagation | Mechanism | Status |
|----------|------|------|-------------|-----------|--------|
| G | allFuture | Universal | Automatic | GContent seeding + 4_G axiom | **Proven** |
| H | allPast | Universal | Automatic | HContent seeding + 4_H axiom | **Proven** |
| F | someFuture | Existential | Explicit tracking | Witness-seed construction | **Proven** |
| P | somePast | Existential | Explicit tracking | Witness-seed construction | **Proven** |

---

## 3. Consistency Theory

### 3.1 The witness-seed consistency theorems

This is the **key enabling lemma** for F/P witness construction.

**Location**: `FormalSystem/Metalogic/Bundle/WitnessSeed.lean`, line 181
(`forward_temporal_witness_seed_consistent`) and line 290
(`past_temporal_witness_seed_consistent`)

**Statement**:
```lean
theorem forward_temporal_witness_seed_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (psi : Formula) (h_F : Formula.someFuture psi ∈ M) :
    SetConsistent (fc := fc) (ForwardTemporalWitnessSeed M psi)
```

Where `ForwardTemporalWitnessSeed M psi = {psi} ∪ GContent(M)`.

**Proof sketch** (5 steps):
1. Suppose `{psi} ∪ GContent(M)` is inconsistent
2. Then there exists a derivation: `GContent(M) ⊢ ¬psi`
3. By generalized temporal K-distribution: `{G(chi) | G(chi) ∈ M} ⊢ G(¬psi)`
4. Since each `G(chi) ∈ M` and M is closed under derivation: `G(¬psi) ∈ M`
5. But `F(psi) = ¬G(¬psi) ∈ M` (by hypothesis), contradicting MCS consistency

**Symmetric lemma** (from `FormalSystem/Metalogic/Bundle/WitnessSeed.lean:290`):
```lean
theorem past_temporal_witness_seed_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (psi : Formula) (h_P : Formula.somePast psi ∈ M) :
    SetConsistent (fc := fc) (PastTemporalWitnessSeed M psi)
```

Where `PastTemporalWitnessSeed M psi = {psi} ∪ HContent(M)`.

### 3.2 The Critical Subtlety

The consistency lemma requires `F(psi) ∈ M` for the **same** M whose GContent is being extended.

**Problem for dovetailing**: When resolving an F-obligation from time s at a later time t > s:
- We need `F(psi) ∈ MCS_{t-1}` to apply the lemma
- But we only know `F(psi) ∈ MCS_s` (where the obligation originated)
- Since `F(psi) → G(F(psi))` is not derivable, F(psi) doesn't automatically persist!

**Resolution options**:

1. **Include F(psi) in intermediate seeds**: At each step from s to t-1, explicitly include F(psi) in the seed to keep it alive until resolution time.

2. **Resolve immediately**: Resolve F(psi) at time s+1 (the very next step), avoiding the persistence issue entirely.

Option (1) is what the tree implements: `WitnessSeed.lean` keeps the F-obligation alive in the
seed until it is discharged, so the persistence gap never has to be bridged by an appeal to
`F(psi) -> G(F(psi))`. Both witness-seed consistency theorems are sorry-free.

---

## 4. Completeness Chain

### 4.1 Proof Architecture

The bundle infrastructure described above feeds the canonical-model construction in
`FormalSystem/Metalogic/BXCanonical/`, which terminates in the four weak completeness
theorems:

```
completeness              (BXCanonical/Completeness.lean:196)
completeness_dense        (BXCanonical/Completeness.lean:255)
completeness_discrete     (BXCanonical/Completeness.lean:296)
completeness_dedekind     (Metalogic/StrongCompleteness.lean:469)
  |
  +-- canonical model / countermodel engines (BXCanonical/CanonicalModel.lean)
        |
        +-- witness-seed consistency (Bundle/WitnessSeed.lean:181, :290)
              |
              +-- FMCS temporal coherence (Bundle/FMCSDef.lean:103)
              +-- BFMCS modal coherence   (Bundle/BFMCS.lean:91)
```

All four are sorryAx-free at exactly `[propext, Classical.choice, Quot.sound]`, asserted by
check C2 of `scripts/check-module-invariants.sh`.

### 4.2 Key Source Files

| File | Anchor | Content |
|------|--------|---------|
| `FormalSystem/Metalogic/Bundle/FMCSDef.lean` | 103 | FMCS structure definition |
| `FormalSystem/Metalogic/Bundle/BFMCS.lean` | 91 | BFMCS structure definition |
| `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` | 181, 290 | witness-seed consistency theorems |
| `FormalSystem/Metalogic/Bundle/TemporalContent.lean` | 59, 69 | GContent/HContent definitions |
| `FormalSystem/Boneyard/BundleDeadHalf/Construction.lean` | 112, 142 | Lindenbaum MCS construction (archived) |
| `FormalSystem/Metalogic/BXCanonical/Completeness.lean` | 196, 255, 296 | the three Base/Dense/Discrete completeness theorems |

---

## Appendix: Historical Context

The bundle layer reached its present shape through several rounds of simplification:

- The modal backward axiom was removed; `modal_backward` is now a structure field derived from
  MCS maximality rather than an added axiom.
- Temporal backward properties were added to the family structure.
- `FMCS` was renamed from `IndexedMCSFamily`; `BFMCS` names the bundle over it.
- The existential `forward_F`/`backward_P` structure fields were removed in favour of the
  witness-seed infrastructure -- see the design note at `FormalSystem/Metalogic/Bundle/FMCSDef.lean:58`.
