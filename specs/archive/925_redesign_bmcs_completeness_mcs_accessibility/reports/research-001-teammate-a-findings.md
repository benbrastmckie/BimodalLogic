# Research Findings: Teammate A - Accessibility Relation Analysis

**Task**: 925 - Redesign BMCS completeness construction using MCS accessibility
**Date**: 2026-02-25
**Focus**: Four-constraint accessibility relation, mathematical properties, closure requirements

## Key Findings

### 1. The "Four Constraints" of the Proposed Accessibility Relation

The task description mentions "four-constraint accessibility". Based on the existing axiom system and canonical frame infrastructure, the four constraints should be:

**Constraint 1: Modal Forward** (Box -> inner formula)
- `Box phi in MCS1` implies `phi in MCS2`
- This is the standard S5 modal accessibility constraint
- Already captured by `BoxContent` in `CoherentConstruction.lean`

**Constraint 2: Temporal Future Forward** (G -> inner formula)
- `G phi in MCS1` implies `phi in MCS2`
- Already formalized as `CanonicalR` in `CanonicalFrame.lean`: `GContent M subset M'`
- This is the "future accessibility" relation

**Constraint 3: Temporal Past Forward** (H -> operator constraint)
- `H phi in MCS2` implies `phi in MCS1`
- Already formalized as `CanonicalR_past` in `CanonicalFrame.lean`: `HContent M subset M'`
- Direction note: when MCS1 R MCS2 (MCS1 "sees" MCS2 in the future), if H phi is in MCS2 (meaning phi holds at all past times from MCS2's perspective), then phi must hold at MCS1 (which is in MCS2's past)

**Constraint 4: Modal Past** (Box with temporal interaction)
- The fourth constraint likely involves `Box G phi` (the task description's example) OR the interaction axioms
- The existing axiom `modal_future: Box phi -> Box(G phi)` and `temp_future: Box phi -> G(Box phi)` govern Box-G interaction
- If MCS1 R MCS2 and `Box G phi in MCS1`, the cascading derivation is:
  - By Constraint 1 (Box forward): `G phi in MCS2`
  - By Constraint 2 (G forward): `phi in MCS3` for any MCS3 accessible from MCS2
- This suggests the "four-constraint" might actually be: {Box, G, H, Box-G interaction}

**Assessment**: The codebase already has the two temporal constraints (CanonicalR, CanonicalR_past) and the modal constraint (BoxContent/BoxContentAt). What is missing is a UNIFIED relation that combines all three/four into a single accessibility predicate for building families.

### 2. Relationship to Existing Infrastructure

**CanonicalR (CanonicalFrame.lean)**:
- Definition: `CanonicalR M M' := GContent M subset M'`
- Already has: reflexivity, transitivity, forward_F, backward_P, forward_G, backward_H
- Key properties are ALL PROVEN (sorry-free)
- Limitation: Only addresses temporal G/H direction, not modal Box

**BoxContent (CoherentConstruction.lean)**:
- Definition: `BoxContent fam := {chi | exists t, Box chi in fam.mcs t}`
- For constant families: `BoxContent fam = BoxContentAt fam t` for any t
- Key theorem: `diamond_boxcontent_consistent_constant` is PROVEN
- Limitation: Only addresses modal Box direction, not temporal G/H

**GContent (TemporalContent.lean)**:
- Definition: `GContent M := {phi | G phi in M}`
- Simple, well-defined, used extensively
- HContent analogous for the past direction

**The Gap**: No existing structure combines all three types of content (BoxContent, GContent, HContent) into a single accessibility relation. This is precisely what task 925 proposes.

### 3. Mathematical Properties of the Proposed Unified Relation

**Proposed definition**: MCS1 R MCS2 iff:
- `GContent(MCS1) subset MCS2` (Constraint 2: temporal future)
- `HContent(MCS2) subset MCS1` (Constraint 3: temporal past, reversed)
- `BoxContentAt(MCS1, t) subset MCS2` for relevant t (Constraint 1: modal)
- Possibly: `BoxContentAt(MCS2, t) subset MCS1` (Constraint 4: modal backward for S5 symmetry)

**Well-definedness analysis**:

The key question is whether there exist MCS pairs satisfying all constraints simultaneously. Consider:
- CanonicalR is already proven satisfiable (canonical_forward_F gives witnesses)
- BoxContent subset relationships are satisfiable (diamond_boxcontent_consistent gives witnesses)
- But combining BOTH temporal and modal constraints on the SAME pair is the open question

**Critical Issue**: The constraint `BoxContentAt(MCS1, t) subset MCS2` is time-dependent. If we want `MCS1 R MCS2` where MCS1 is at time t and MCS2 at time t+1, we need `BoxContentAt(MCS1, t) subset MCS2`. But the current BFMCS structure has a DIFFERENT MCS at each time, so BoxContent varies with time.

**For constant families** (same MCS at every time):
- BoxContent is time-independent, so the constraint simplifies
- This is the case handled by `CoherentConstruction.lean`
- Constant families are temporally trivial (G phi -> phi, H phi -> phi via T-axioms)

**For non-constant families** (the general case needed for completeness):
- BoxContent varies across times
- The unified accessibility must handle time-varying Box obligations
- This is the core challenge that tasks 916, 922, 924 failed on

### 4. Direction of the Accessibility Relation

**Time flow direction**: If MCS1 is at time t and MCS2 is at time t+1:
- `MCS1 R_future MCS2`: GContent(MCS1) subset MCS2 (time flows forward)
- `MCS2 R_past MCS1`: HContent(MCS2) subset MCS1 (MCS1 is in MCS2's past)

**Modal direction**: In S5, accessibility is an equivalence relation (symmetric):
- `MCS1 R_modal MCS2`: BoxContent(MCS1) subset MCS2 AND BoxContent(MCS2) subset MCS1
- S5 symmetry means: if MCS1 sees MCS2, then MCS2 sees MCS1

**Truth lemma compatibility**: The truth lemma requires:
- **Box case**: `Box phi in fam.mcs t` iff `phi in fam'.mcs t` for all fam' in bundle
  - Currently handled by modal_forward and modal_backward in BMCS
  - The universal quantification over families makes this S5-like

- **G case**: `G phi in fam.mcs t` iff `phi in fam.mcs s` for all s >= t
  - Currently handled by forward_G (forward) and temporal_backward_G (backward)
  - The backward direction uses F-witness + contradiction

- **H case**: `H phi in fam.mcs t` iff `phi in fam.mcs s` for all s <= t
  - Symmetric to G case

**Key insight**: The truth lemma's box case quantifies over ALL families at the SAME time, while the G/H cases quantify over ALL times within the SAME family. These are ORTHOGONAL dimensions. The accessibility relation must respect both.

### 5. Closure/Saturation Properties Required

**Standard MCS properties** (already proven):
- Maximal: for all phi, either phi in M or neg(phi) in M
- Consistent: cannot derive bot from formulas in M
- Deductively closed: if M derives phi, then phi in M

**Temporal saturation** (partially implemented):
- Forward: F(phi) in M implies exists witness s > t with phi in mcs(s)
- Backward: P(phi) in M implies exists witness s < t with phi in mcs(s)
- Status: These are the 2 remaining sorries in DovetailingChain.lean
- `temporal_witness_seed_consistent` is PROVEN (consistency of seed {phi} union GContent(M))

**Modal saturation** (implemented in CoherentConstruction.lean):
- Diamond(phi) in M implies exists witness family with phi in its MCS
- Status: `diamond_boxcontent_consistent_constant` is PROVEN for constant families
- `saturated_modal_backward` is PROVEN (ModalSaturation.lean)
- The gap: extending from constant to non-constant witness families

**Cross-dimension saturation** (the core challenge):
- When constructing a witness family for Diamond(phi), the witness must be both:
  - Modally coherent (contains the right BoxContent)
  - Temporally coherent (satisfies forward_F and backward_P)
- This is the "combination problem" identified in TemporalCoherentConstruction.lean lines 785-797

### 6. Comparison with Literature

**Henkin-style canonical models**:
- The approach is standard Henkin: build MCSs, define accessibility, prove truth lemma
- What makes TM logic harder: BIMODAL interaction requires accessibility to handle BOTH modal and temporal constraints
- In pure modal S5: single accessibility relation (BoxContent), well-understood
- In pure temporal logic: single chain (GContent/HContent), well-understood
- In bimodal TM: both must coexist and interact via axioms `modal_future` and `temp_future`

**Kripke accessibility for S5**:
- Standard S5 has universal accessibility (all worlds see all worlds)
- The BMCS construction already uses this (modal_forward/backward quantify over all families)
- The challenge is that "all families" must also satisfy temporal coherence

**Prior's tense logic completeness**:
- Standard approach: build chain of MCSs, each step extends via GContent seed
- Works for pure tense logic (this is what DovetailingChain does)
- Fails when modal formulas must be handled simultaneously (the "combination problem")

**Multi-modal completeness (Goldblatt, Blackburn-de Rijke-Venema)**:
- The standard technique for combining modalities: "product" or "fibred" frames
- For TM: worlds are (family, time) pairs
- Accessibility must respect BOTH the modal dimension (family) and temporal dimension (time)
- This is essentially what the BMCS + BFMCS architecture implements

### 7. Critical Sorries in Current Architecture

The sorry chain from the top-level completeness theorem:

```
bmcs_strong_completeness (SORRY-FREE)
  -> bmcs_representation (SORRY-FREE)
    -> construct_saturated_bmcs_int (SORRY-FREE wrapper)
      -> fully_saturated_bmcs_exists_int (1 SORRY - the key blocker)
        Needs: temporal coherence AND modal saturation simultaneously

temporal_coherent_family_exists_Int (delegates to DovetailingChain)
  -> temporal_coherent_family_exists_theorem
    -> forward_F (1 SORRY - non-linear BFMCS needed)
    -> backward_P (1 SORRY - non-linear BFMCS needed)

temporal_coherent_family_exists (generic D)
  -> 1 SORRY (only Int is needed downstream)

singleFamilyBMCS.modal_backward (1 SORRY - not used in main chain)
```

**Total critical sorries**: 3 (fully_saturated_bmcs_exists_int, forward_F, backward_P)
**Non-critical sorries**: 2 (generic D version, singleFamily not in main chain)

## Recommended Approach

### The Unified MCS Accessibility Relation

Define a new relation `MCS_Accessible` combining all constraints:

```lean
def MCS_Accessible (M1 M2 : Set Formula) : Prop :=
  GContent M1 subset M2 /\    -- Temporal future: G phi in M1 -> phi in M2
  HContent M2 subset M1 /\    -- Temporal past: H phi in M2 -> phi in M1
  BoxContentSet M1 subset M2  -- Modal: Box phi in M1 -> phi in M2
```

Where `BoxContentSet M := {phi | Box phi in M}` (set-level, not family-level).

### Family Construction via Accessibility Chains

1. Start with root MCS M0 (extending the consistent context Gamma)
2. For each integer n >= 0: build M_{n+1} from M_n using `{all forward obligations} union GContent(M_n)` as seed
3. For each integer n <= 0: build M_{n-1} from M_n using `{all backward obligations} union HContent(M_n)` as seed
4. The "all forward obligations" include BOTH temporal (F-witness formulas) AND modal (Diamond-witness formulas)
5. Each step must guarantee `MCS_Accessible(M_n, M_{n+1})`

### Key Difference from Previous Approaches

**Previous approaches** separated modal and temporal construction:
- Build a single temporal chain (DovetailingChain)
- Add modal witness families separately (CoherentConstruction)
- Fail because the witness families lack temporal coherence

**New approach** integrates them:
- At each chain step, include BOTH temporal AND modal obligations in the seed
- Each chain step creates an MCS satisfying all four constraints
- Modal witnesses are built into the temporal chain, not added separately
- The proof of `fully_saturated_bmcs_exists_int` becomes a single unified construction

### Proving Forward_F and Backward_P

The key insight: if the seed at step n+1 includes ALL F-formula witnesses from M_n (not just GContent), then forward_F follows by construction.

Specifically: when building M_{n+1} from M_n:
- Seed = {psi | F(psi) in M_n} union GContent(M_n) union BoxContentSet(M_n)
- Consistency of this seed follows from:
  - `temporal_witness_seed_consistent` (PROVEN) for the F-witness part
  - GContent inclusion is always consistent with F-witnesses (by MCS properties)
  - BoxContentSet inclusion is consistent because Box phi -> phi (T-axiom)

The difficulty: the seed includes formulas from THREE different sources, and showing the UNION is consistent requires showing no contradiction arises between them.

## Evidence: Verified Lemma Names

| Lemma | File | Status |
|-------|------|--------|
| `CanonicalR` | CanonicalFrame.lean | Defined, proven properties |
| `CanonicalR_past` | CanonicalFrame.lean | Defined, proven properties |
| `canonical_forward_F` | CanonicalFrame.lean | PROVEN |
| `canonical_backward_P` | CanonicalFrame.lean | PROVEN |
| `canonicalR_reflexive` | CanonicalFrame.lean | PROVEN |
| `canonicalR_transitive` | CanonicalFrame.lean | PROVEN |
| `GContent` | TemporalContent.lean | Defined |
| `HContent` | TemporalContent.lean | Defined |
| `BoxContent` | CoherentConstruction.lean | Defined |
| `BoxContentAt` | CoherentConstruction.lean | Defined |
| `WitnessSeed` | CoherentConstruction.lean | Defined |
| `diamond_boxcontent_consistent_constant` | CoherentConstruction.lean | PROVEN |
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | PROVEN |
| `forward_temporal_witness_seed_consistent` | DovetailingChain.lean | PROVEN |
| `saturated_modal_backward` | ModalSaturation.lean | PROVEN |
| `is_modally_saturated` | ModalSaturation.lean | Defined |
| `bmcs_truth_lemma` | TruthLemma.lean | PROVEN (sorry-free) |
| `temporal_backward_G` | TemporalCoherentConstruction.lean | PROVEN |
| `temporal_backward_H` | TemporalCoherentConstruction.lean | PROVEN |
| `fully_saturated_bmcs_exists_int` | TemporalCoherentConstruction.lean | SORRY |
| `dovetailing_chain_forward_F` | DovetailingChain.lean | SORRY |
| `dovetailing_chain_backward_P` | DovetailingChain.lean | SORRY |

## Confidence Level

**Moderate-High (70%)** that the unified accessibility approach is correct in principle.

**Reasoning**:
- The individual components (CanonicalR, BoxContent, GContent) are all well-defined and proven
- The truth lemma is already sorry-free, so the BMCS structure is correct
- The challenge is entirely in CONSTRUCTION (building the BMCS), not in verification
- The proposed approach addresses the exact failure mode of previous attempts (separation of modal and temporal construction)

**Risk factors**:
- Consistency of the unified seed (GContent union F-witnesses union BoxContentSet) is unproven
- The seed may be too large, introducing contradictions between modal and temporal obligations
- The `modal_future` and `temp_future` axioms create cross-dependencies that may cause circular obligations

**Mitigation**: The proof of seed consistency should be attempted early. If `{psi | F(psi) in M} union GContent(M) union BoxContentSet(M)` is consistent whenever M is an MCS, the approach will work. This is the single most important mathematical question.

## Next Steps

1. Formalize `MCS_Accessible` as a unified relation
2. Prove that the unified seed `GContent(M) union F_witnesses(M) union BoxContentSet(M)` is consistent
3. Build the chain construction using the unified seed
4. Prove forward_F and backward_P follow from the construction
5. Prove modal saturation follows from including Diamond-witness obligations
6. Assemble into `fully_saturated_bmcs_exists_int` proof
