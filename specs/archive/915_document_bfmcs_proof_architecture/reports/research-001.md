# Research Report: Task #915

**Task**: Document BFMCS proof architecture and remaining lacunae
**Started**: 2026-02-20
**Completed**: 2026-02-20
**Effort**: 2 hours
**Dependencies**: Task 914 (BFMCS rename) - completed
**Sources/Inputs**: Codebase analysis of `Theories/Bimodal/Metalogic/Bundle/` files
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The completeness proof uses a **two-level bundling architecture**: BFMCS (temporal family at one time index) and BMCS (modal bundle of temporal families)
- Propagation requirements are **construction constraints**, not post-hoc verifications: G-content propagates automatically through GContent seeding, while F-obligations require explicit witness tracking
- The **consistency argument** via `temporal_witness_seed_consistent` proves that {psi} union GContent(M) is consistent when F(psi) is in MCS M
- **4 remaining sorries** in DovetailingChain.lean: 2 cross-sign propagation (lines 606, 617) and 2 witness construction (lines 633, 640)
- Recommended documentation structure: ontology overview, propagation mechanics, consistency theory, lacunae inventory with resolution paths

## Context and Scope

This research examines the BFMCS/BMCS proof architecture for modal-temporal (TM) logic completeness. The goal is to document:

1. The two-level bundling ontology
2. Propagation requirements as construction constraints
3. The G-content vs F-obligations asymmetry
4. The consistency argument via `temporal_witness_seed_consistent`
5. The 4 remaining sorries in DovetailingChain.lean and what closes them

## Findings

### 1. Two-Level Bundling Ontology

The completeness proof has two distinct bundling levels that serve different semantic purposes:

#### Level 1: BFMCS (Bundled Family of Maximal Consistent Sets)

**Definition** (from BFMCS.lean lines 80-98):
```lean
structure BFMCS where
  mcs : D -> Set Formula           -- MCS at each time point
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
```

**Semantic role**: A single "world history" - one MCS per time point with temporal coherence. This represents a complete possible history of the world, where each time slice is a maximal consistent set.

**Key insight**: The temporal operators G (all future) and H (all past) constrain **relationships within a single history**. The coherence conditions ensure:
- `forward_G`: What is always-future-true (G phi) at time t means phi holds at all future times
- `backward_H`: What is always-past-true (H phi) at time t means phi holds at all past times

#### Level 2: BMCS (Bundle of MCS)

**Definition** (from BMCS.lean lines 82-113):
```lean
structure BMCS where
  families : Set (BFMCS D)         -- Collection of world histories
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t →
    ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t,
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
  eval_family : BFMCS D            -- Distinguished evaluation point
  eval_family_mem : eval_family ∈ families
```

**Semantic role**: A collection of world histories with modal coherence. This enables the box/diamond operators to quantify over histories within the bundle.

**Key insight**: The modal operators box and diamond constrain **relationships between histories** at the same time:
- `modal_forward`: box(phi) in any history at time t means phi holds in ALL histories at time t
- `modal_backward`: phi in ALL histories at time t means box(phi) in each history at time t

**Why two levels?**: TM logic has both modal (box/diamond) and temporal (G/H/F/P) operators. The two-level structure provides:
- Temporal coherence within each history (BFMCS level)
- Modal coherence across histories (BMCS level)

### 2. Propagation Requirements as Construction Constraints

The coherence conditions are NOT verified after construction - they are **constraints baked into the construction** of successive MCSes.

#### GContent Seeding (Automatic Propagation)

**Definition** (from TemporalContent.lean):
```lean
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}
```

**How it works**:
1. When building MCS_{t+1}, the seed includes GContent(MCS_t)
2. Lindenbaum extends this seed to a full MCS
3. This ensures: if G(phi) in MCS_t, then phi in MCS_{t+1}

**Why G propagates automatically**: The 4_G axiom (G phi -> G(G phi)) ensures that when G(phi) is in MCS_t:
- G(G phi) is also in MCS_t (by MCS closure)
- Therefore G(phi) is in GContent(MCS_t)
- Therefore G(phi) is in the seed for MCS_{t+1}
- Therefore G(phi) is in MCS_{t+1}
- And the propagation continues inductively

**Proven in DovetailingChain.lean** (lines 484-507):
```lean
lemma dovetailForwardChain_G_propagates -- G phi propagates forward
lemma dovetailForwardChain_forward_G   -- At t' > t, phi is in MCS_{t'}
```

#### F-Obligations (Require Explicit Tracking)

The formula `F(psi) -> G(F(psi))` is NOT derivable (semantically invalid). Example: if psi holds at exactly one future time, after which F(psi) fails.

**Consequence**: F-obligations do not automatically persist through GContent seeding. They must be:
1. **Tracked explicitly** as obligations to be fulfilled
2. **Scheduled** for resolution at specific future times
3. **Placed in seeds** when their scheduled time arrives

**Not yet implemented**: The witness construction for forward_F and backward_P is where 2 of the 4 sorries remain.

#### Summary of Propagation Types

| Operator | Type | Mechanism | Status |
|----------|------|-----------|--------|
| G (all_future) | Box-like | GContent seeding | Automatic (proven) |
| H (all_past) | Box-like | HContent seeding | Automatic (proven) |
| F (some_future) | Diamond-like | Witness obligation | Requires tracking (sorry) |
| P (some_past) | Diamond-like | Witness obligation | Requires tracking (sorry) |

### 3. The Consistency Argument

#### temporal_witness_seed_consistent (TemporalCoherentConstruction.lean, lines 461-522)

This is the **key enabling lemma** for F/P witness construction:

```lean
theorem temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (TemporalWitnessSeed M psi)
```

Where `TemporalWitnessSeed M psi = {psi} ∪ GContent(M)`.

**Proof sketch**:
1. Suppose `{psi} ∪ GContent(M)` is inconsistent
2. Then there exists a derivation: `GContent(M) ⊢ ¬psi`
3. By generalized temporal K-distribution: `{G(chi) | G(chi) ∈ M} ⊢ G(¬psi)`
4. Since each `G(chi) ∈ M` and M is closed under derivation: `G(¬psi) ∈ M`
5. But `F(psi) = ¬G(¬psi) ∈ M` (by hypothesis)
6. Contradiction: M contains both G(¬psi) and ¬G(¬psi)

#### past_temporal_witness_seed_consistent (DovetailingChain.lean, lines 301-353)

The symmetric lemma for P(psi):

```lean
theorem past_temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    SetConsistent (PastTemporalWitnessSeed M psi)
```

Where `PastTemporalWitnessSeed M psi = {psi} ∪ HContent(M)`.

#### Critical Subtlety

The consistency lemma requires `F(psi) ∈ M` for the SAME M whose GContent is being extended. For the dovetailing chain, when resolving an F-obligation from time s at time t > s:

- **Problem**: We need `F(psi) ∈ MCS_{t-1}` (not just `F(psi) ∈ MCS_s`)
- **Issue**: `F(psi) → G(F(psi))` is not derivable, so F(psi) doesn't automatically persist

**Resolution options**:
1. Include F(psi) in the seed at each intermediate step (keeps it alive until resolution)
2. Resolve F(psi) at the very next time step s+1 (avoids persistence issue)

Option (2) is simpler but creates potential conflicts when multiple F-obligations compete for the same time slot.

### 4. The 4 Remaining Sorries in DovetailingChain.lean

All 4 sorries are in the `buildDovetailingChainFamily` definition (lines 588-640):

#### Sorry 1: forward_G when t < 0 (Line 606)

**Location**: `buildDovetailingChainFamily.forward_G` branch when `t < 0`

**What's needed**: Cross-sign propagation. When G(phi) is in MCS_t with t < 0 (backward chain), show phi appears in MCS_{t'} for any t' > t.

**Challenge**: The forward and backward chains share MCS_0 (the base), but are otherwise independent. The proof needs:
1. Show G(phi) from MCS_{-k} propagates to MCS_0 via backward_H coherence
2. Then use forward_G to propagate from MCS_0 to MCS_{t'}

**Resolution path**: Requires proving that the sharing of MCS_0 enables cross-sign propagation. The HContent seeding backward should place G-content at MCS_0.

#### Sorry 2: backward_H when t >= 0 (Line 617)

**Location**: `buildDovetailingChainFamily.backward_H` branch when `t >= 0`

**What's needed**: Symmetric to Sorry 1. When H(phi) is in MCS_t with t >= 0 (forward chain), show phi appears in MCS_{t'} for any t' < t.

**Resolution path**: Same as above, using GContent propagation to MCS_0, then backward_H from MCS_0.

#### Sorry 3: forward_F (Line 633)

**Location**: `buildDovetailingChainFamily_forward_F` lemma

**What's needed**: Witness construction. When F(psi) is in MCS_t, prove there exists s > t with psi in MCS_s.

**Challenge**: Requires a dovetailing enumeration scheme:
1. Enumerate all (time, formula) pairs: (t, psi) where F(psi) ∈ MCS_t
2. Schedule each pair to a specific future time for resolution
3. At construction, include the scheduled witness psi in the seed
4. Use `temporal_witness_seed_consistent` to prove the seed is consistent

**Resolution path**: Implement dovetailing enumeration using Cantor pairing (Nat.unpair). The construction must:
- Handle infinitely many obligations (from all times)
- Process ONE witness per construction step (to use consistency lemma)
- Eventually process ALL obligations (completeness)

#### Sorry 4: backward_P (Line 640)

**Location**: `buildDovetailingChainFamily_backward_P` lemma

**What's needed**: Symmetric to Sorry 3. When P(psi) is in MCS_t, prove there exists s < t with psi in MCS_s.

**Resolution path**: Same dovetailing approach using `past_temporal_witness_seed_consistent`.

### 5. Current Proof Chain Status

The completeness proof chain (Completeness.lean) is **sorry-free at the top level**, but inherits sorries from dependencies:

```
bmcs_strong_completeness (SORRY-FREE)
  └─ bmcs_context_representation (SORRY-FREE)
      └─ construct_saturated_bmcs_int
          └─ fully_saturated_bmcs_exists_int (1 sorry)
              └─ temporal_coherent_family_exists_Int
                  └─ temporal_coherent_family_exists_theorem (DovetailingChain.lean)
                      └─ buildDovetailingChainFamily (4 sorries)
```

The **total sorry count** for the completeness proof: 4 (in DovetailingChain.lean) + 1 (in TemporalCoherentConstruction.lean for combining temporal + modal saturation).

## Recommendations

### 1. Documentation Structure

Create `docs/bfmcs-architecture.md` or `Theories/Bimodal/Metalogic/Bundle/README.md` with:

1. **Ontology Overview**: Two-level bundling (BFMCS temporal, BMCS modal)
2. **Propagation Mechanics**: GContent/HContent seeding for boxes, witness tracking for diamonds
3. **Consistency Theory**: The temporal_witness_seed_consistent argument
4. **Lacunae Inventory**: The 4 sorries with resolution requirements
5. **Completeness Chain**: How bmcs_truth_lemma and bmcs_strong_completeness fit together

### 2. Enhanced Doc Comments

Update module headers in:
- `BFMCS.lean`: Explain single-history temporal coherence
- `BMCS.lean`: Explain multi-history modal coherence
- `DovetailingChain.lean`: Document the 4 sorries and resolution strategy
- `TemporalCoherentConstruction.lean`: Document temporal_witness_seed_consistent

### 3. Resolution Priority

For closing the sorries:
1. **Cross-sign (Sorries 1-2)**: Simpler - just needs careful analysis of shared MCS_0
2. **Witnesses (Sorries 3-4)**: More complex - requires full dovetailing enumeration implementation

### 4. Diagram Recommendations

Visual aids would help explain:
- BFMCS as a timeline with MCS at each point
- BMCS as a bundle of parallel timelines
- GContent seeding flow (forward chain)
- F-obligation tracking and resolution

## Decisions

1. **Documentation format**: Recommend dedicated architecture document rather than only doc comments (architecture is cross-module)
2. **Terminology**: Use BFMCS/BMCS consistently (after Task 914 rename)
3. **Sorry documentation style**: Inline comments at sorry site + comprehensive lacunae section in architecture doc

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Sorries 3-4 require complex enumeration | `temporal_witness_seed_consistent` is already proven - main remaining work is bookkeeping |
| Cross-sign propagation harder than expected | The shared MCS_0 design was intentional for this purpose |
| Documentation becomes outdated | Include version reference to source files |

## Appendix

### Search Queries Used

- Glob patterns: `**/*BFMCS*.lean`, `**/*BMCS*.lean`, `**/Construction/*.lean`, `**/Bundle/*.lean`
- Grep patterns: `sorry`, `temporal_witness_seed_consistent`

### Key Source File Locations

| File | Lines | Content |
|------|-------|---------|
| BFMCS.lean | 80-98 | BFMCS structure definition |
| BMCS.lean | 82-113 | BMCS structure definition |
| DovetailingChain.lean | 588-666 | buildDovetailingChainFamily with 4 sorries |
| TemporalCoherentConstruction.lean | 461-522 | temporal_witness_seed_consistent proof |
| TemporalContent.lean | 17-26 | GContent/HContent definitions |
| Completeness.lean | 100-113 | bmcs_representation theorem |

### References

- Task 843: Original modal backward axiom removal
- Task 857: Temporal backward properties addition
- Task 912: Completeness proof review
- Task 914: BFMCS rename from IndexedMCSFamily
- Task 916: F/P witness obligation tracking (follow-up task)
