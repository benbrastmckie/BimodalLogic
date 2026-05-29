# BFMCS Proof Architecture

**Version**: 1.0
**Date**: 2026-02-20
**Related Tasks**: Task 914 (BFMCS rename), Task 915 (this documentation), Task 916 (F/P witness tracking)

## Executive Summary

The TM logic completeness proof uses a **two-level bundling architecture** to model both temporal and modal aspects of formulas:

1. **BFMCS (Bundled Family of MCS)**: A single "world history" - one maximal consistent set (MCS) per time point with temporal coherence conditions ensuring G/H formulas propagate correctly.

2. **BMCS (Bundle of MCS)**: A collection of world histories with modal coherence conditions ensuring Box/Diamond formulas relate correctly across histories.

**Key insight**: G-content propagates automatically through seeding (the 4_G axiom ensures G(phi) -> G(G(phi))), while F-obligations require explicit witness tracking because F(phi) -> G(F(phi)) is semantically invalid.

**Current status**: The proof has **4 remaining sorries** in `DovetailingChain.lean`:
- 2 cross-sign propagation sorries (simpler)
- 2 witness construction sorries (require dovetailing enumeration)

---

## Table of Contents

1. [Ontology Overview](#1-ontology-overview)
   - [BFMCS: Single World History](#11-bfmcs-single-world-history)
   - [BMCS: Bundle of World Histories](#12-bmcs-bundle-of-world-histories)
   - [Why Two Levels?](#13-why-two-levels)
2. [Propagation Mechanics](#2-propagation-mechanics)
   - [G-Content Automatic Propagation](#21-g-content-automatic-propagation)
   - [F-Obligations Require Tracking](#22-f-obligations-require-tracking)
   - [Propagation Summary Table](#23-propagation-summary-table)
3. [Consistency Theory](#3-consistency-theory)
   - [The temporal_witness_seed_consistent Theorem](#31-the-temporal_witness_seed_consistent-theorem)
   - [The Critical Subtlety](#32-the-critical-subtlety)
4. [Lacunae Inventory](#4-lacunae-inventory)
   - [Sorry 1: forward_G Cross-Sign (Line 606)](#41-sorry-1-forward_g-cross-sign-line-606)
   - [Sorry 2: backward_H Cross-Sign (Line 617)](#42-sorry-2-backward_h-cross-sign-line-617)
   - [Sorry 3: forward_F Witness (Line 633)](#43-sorry-3-forward_f-witness-line-633)
   - [Sorry 4: backward_P Witness (Line 640)](#44-sorry-4-backward_p-witness-line-640)
   - [Resolution Priority](#45-resolution-priority)
5. [Completeness Chain](#5-completeness-chain)
   - [Proof Architecture](#51-proof-architecture)
   - [Sorry Propagation](#52-sorry-propagation)
   - [Key Source Files](#53-key-source-files)

---

## 1. Ontology Overview

### 1.1 BFMCS: Single World History

A **BFMCS** (Bundled Family of Maximal Consistent Sets) represents a single complete "world history" - one MCS at each integer time point with temporal coherence.

**Definition** (from `BFMCS.lean`, lines 80-98):

```lean
structure BFMCS where
  mcs : Int -> Set Formula           -- MCS at each time point
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
  forward_F : forall t phi, Formula.some_future phi ∈ mcs t -> exists s, t < s /\ phi ∈ mcs s
  backward_P : forall t phi, Formula.some_past phi ∈ mcs t -> exists s, s < t /\ phi ∈ mcs s
```

**Semantic interpretation**:
- Each time point `t` has a maximal consistent set `mcs t` describing "what is true at time t"
- `forward_G`: If G(phi) holds at time t, then phi holds at all future times t' > t
- `backward_H`: If H(phi) holds at time t, then phi holds at all past times t' < t
- `forward_F`: If F(phi) holds at time t, then phi holds at some future time
- `backward_P`: If P(phi) holds at time t, then phi holds at some past time

**Visual representation**:
```
Time:    ... -2   -1    0    1    2    3 ...
              |    |    |    |    |    |
MCS:        M_{-2} M_{-1} M_0  M_1  M_2  M_3
              ^---------^---------^
              Temporal coherence constraints
```

### 1.2 BMCS: Bundle of World Histories

A **BMCS** (Bundle of MCS) is a collection of BFMCS structures (world histories) with modal coherence.

**Definition** (from `BMCS.lean`, lines 82-113):

```lean
structure BMCS where
  families : Set (BFMCS)             -- Collection of world histories
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    Formula.box phi ∈ fam.mcs t -> forall fam' in families, phi ∈ fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi ∈ fam'.mcs t) -> Formula.box phi ∈ fam.mcs t
  eval_family : BFMCS                -- Distinguished evaluation point
  eval_family_mem : eval_family ∈ families
```

**Semantic interpretation**:
- `families`: Set of possible world histories
- `modal_forward`: Box(phi) at time t in any history means phi at time t in ALL histories
- `modal_backward`: phi at time t in ALL histories means Box(phi) at time t in each history
- `eval_family`: The "actual" world history used for evaluation

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
| Modal | Box, Diamond | Across histories (at same time) | BMCS |
| Temporal | G, H, F, P | Within history (across times) | BFMCS |

**The key insight**: Modal operators relate different "possible worlds" at the same time instant, while temporal operators relate the same "possible world" across different time instants. The two-level structure cleanly separates these concerns.

---

## 2. Propagation Mechanics

### 2.1 G-Content Automatic Propagation

**Definition** (from `TemporalContent.lean`, lines 19-26):

```lean
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

def HContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}
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

**Proven lemmas** (from `DovetailingChain.lean`, lines 484-507):
```lean
lemma dovetailForwardChain_G_propagates  -- G(phi) in MCS_t implies G(phi) in MCS_{t+1}
lemma dovetailForwardChain_forward_G     -- G(phi) in MCS_t implies phi in MCS_{t'} for all t' > t
```

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
| G | all_future | Universal | Automatic | GContent seeding + 4_G axiom | **Proven** |
| H | all_past | Universal | Automatic | HContent seeding + 4_H axiom | **Proven** |
| F | some_future | Existential | Explicit tracking | Dovetailing enumeration | **Sorry** |
| P | some_past | Existential | Explicit tracking | Dovetailing enumeration | **Sorry** |

---

## 3. Consistency Theory

### 3.1 The temporal_witness_seed_consistent Theorem

This is the **key enabling lemma** for F/P witness construction.

**Location**: `TemporalCoherentConstruction.lean`, lines 461-522

**Statement**:
```lean
theorem temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (TemporalWitnessSeed M psi)
```

Where `TemporalWitnessSeed M psi = {psi} ∪ GContent(M)`.

**Proof sketch** (5 steps):
1. Suppose `{psi} ∪ GContent(M)` is inconsistent
2. Then there exists a derivation: `GContent(M) ⊢ ¬psi`
3. By generalized temporal K-distribution: `{G(chi) | G(chi) ∈ M} ⊢ G(¬psi)`
4. Since each `G(chi) ∈ M` and M is closed under derivation: `G(¬psi) ∈ M`
5. But `F(psi) = ¬G(¬psi) ∈ M` (by hypothesis), contradicting MCS consistency

**Symmetric lemma** (from `DovetailingChain.lean`, lines 301-353):
```lean
theorem past_temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    SetConsistent (PastTemporalWitnessSeed M psi)
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

Option (2) is simpler but creates potential conflicts when multiple F-obligations compete for resolution at the same time slot. The full dovetailing construction (Task 916) will need to handle this scheduling carefully.

---

## 4. Lacunae Inventory

All 4 remaining sorries are in the `buildDovetailingChainFamily` definition in `DovetailingChain.lean`, lines 588-640.

### 4.1 Sorry 1: forward_G Cross-Sign (Line 606)

**Location**: `buildDovetailingChainFamily.forward_G` branch when `t < 0`

**Goal**: When G(phi) is in MCS_t with t < 0 (backward chain), show phi appears in MCS_{t'} for any t' > t.

**Challenge**: The forward and backward chains are constructed separately but share MCS_0 as their common base. The proof needs to "cross" from the backward chain to the forward chain.

**Resolution path**:
1. Show G(phi) from MCS_{-k} propagates through the backward chain to MCS_0 via HContent preservation
2. Once G(phi) is in MCS_0, use the proven forward_G lemma to propagate to MCS_{t'}

**Complexity**: Medium - requires careful analysis of MCS_0 sharing semantics

### 4.2 Sorry 2: backward_H Cross-Sign (Line 617)

**Location**: `buildDovetailingChainFamily.backward_H` branch when `t >= 0`

**Goal**: When H(phi) is in MCS_t with t >= 0 (forward chain), show phi appears in MCS_{t'} for any t' < t.

**Challenge**: Symmetric to Sorry 1 - must cross from forward chain to backward chain.

**Resolution path**:
1. Show H(phi) from MCS_k propagates through the forward chain to MCS_0 via GContent preservation
2. Once H(phi) is in MCS_0, use the proven backward_H lemma to propagate to MCS_{t'}

**Complexity**: Medium - symmetric to Sorry 1

### 4.3 Sorry 3: forward_F Witness (Line 633)

**Location**: `buildDovetailingChainFamily_forward_F` lemma

**Goal**: When F(psi) is in MCS_t, prove there exists s > t with psi in MCS_s.

**Challenge**: Requires implementing the full dovetailing enumeration scheme:
1. Enumerate all (time, formula) pairs: (t, psi) where F(psi) ∈ MCS_t
2. Schedule each pair to a specific future time for resolution
3. At construction time, include the scheduled witness psi in the seed
4. Use `temporal_witness_seed_consistent` to prove the seed is consistent

**Resolution path** (see Task 916):
- Implement dovetailing using Cantor pairing (Nat.unpair)
- Handle infinitely many obligations from all times
- Process ONE witness per construction step
- Ensure ALL obligations eventually processed (completeness)

**Complexity**: High - requires significant new infrastructure

### 4.4 Sorry 4: backward_P Witness (Line 640)

**Location**: `buildDovetailingChainFamily_backward_P` lemma

**Goal**: When P(psi) is in MCS_t, prove there exists s < t with psi in MCS_s.

**Challenge**: Symmetric to Sorry 3 - requires dovetailing for the backward chain.

**Resolution path**: Same approach using `past_temporal_witness_seed_consistent`.

**Complexity**: High - symmetric to Sorry 3

### 4.5 Resolution Priority

| Sorry | Type | Complexity | Recommended Order |
|-------|------|------------|-------------------|
| 1-2 | Cross-sign | Medium | **First** - unblocks understanding of chain structure |
| 3-4 | Witnesses | High | **Second** - requires dovetailing infrastructure |

The cross-sign sorries (1-2) can likely be resolved with careful analysis of the existing code. The witness sorries (3-4) require implementing the full dovetailing enumeration (Task 916).

---

## 5. Completeness Chain

### 5.1 Proof Architecture

The completeness proof flows from the top-level theorem down through several layers:

```
bmcs_strong_completeness (Completeness.lean)
  |
  +-- bmcs_context_representation
        |
        +-- construct_saturated_bmcs_int
              |
              +-- fully_saturated_bmcs_exists_int
                    |
                    +-- temporal_coherent_family_exists_Int
                          |
                          +-- temporal_coherent_family_exists_theorem (DovetailingChain.lean)
                                |
                                +-- buildDovetailingChainFamily [4 SORRIES]
```

### 5.2 Sorry Propagation

| File | Component | Sorry Count |
|------|-----------|-------------|
| DovetailingChain.lean | buildDovetailingChainFamily | 4 |
| TemporalCoherentConstruction.lean | temporal + modal saturation | 1 |
| **Total** | | **5** |

The 4 sorries in DovetailingChain.lean propagate up through the entire chain. Once these are resolved, the completeness proof will be fully verified.

### 5.3 Key Source Files

| File | Lines | Content |
|------|-------|---------|
| `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` | 80-98 | BFMCS structure definition |
| `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` | 82-113 | BMCS structure definition |
| `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` | 588-666 | buildDovetailingChainFamily with 4 sorries |
| `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` | 461-522 | temporal_witness_seed_consistent proof |
| `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` | 19-26 | GContent/HContent definitions |
| `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | 100-113 | bmcs_representation theorem |

---

## Appendix: Historical Context

- **Task 843**: Original modal backward axiom removal
- **Task 857**: Temporal backward properties addition
- **Task 912**: Completeness proof review identifying these lacunae
- **Task 914**: BFMCS rename from IndexedMCSFamily
- **Task 916**: F/P witness obligation tracking (follow-up task for sorries 3-4)
