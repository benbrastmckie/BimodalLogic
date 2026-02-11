# Implementation Plan: Task #870

- **Task**: 870 - Zorn-based family selection for temporal coherence
- **Status**: [IMPLEMENTING]
- **Effort**: 18-22 hours (5-6 sessions)
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: specs/870_zorn_family_temporal_coherence/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace the sorry-dependent `buildDovetailingChainFamily` with a Zorn-based construction that builds the entire `IndexedMCSFamily` globally rather than sequentially. The current approach fails at cross-sign boundaries (G phi at t<0 reaching t'>0) because chains extend away from time 0 and cannot retroactively propagate formulas. The Zorn approach defines a partial order on coherent partial families and applies Zorn's lemma to obtain a maximal (hence total) element with all four temporal properties proven.

### Research Integration

Key findings from research-002.md integrated into this plan:
1. Four sorries in DovetailingChain.lean: lines 606, 617 (cross-sign), 633, 640 (witness)
2. Two orthogonal problems: cross-sign propagation (universal G/H) and witness enumeration (existential F/P)
3. TemporalLindenbaum.lean provides a Zorn template for single-MCS construction that can be adapted
4. Existing lemmas `temporal_witness_seed_consistent` and `temporal_witness_seed_consistent_past` enable F/P witness construction
5. Alternative formulation without dependent types in MCS field simplifies proofs

## Goals & Non-Goals

**Goals**:
- Eliminate all 4 sorries in DovetailingChain.lean (lines 606, 617, 633, 640)
- Provide a theorem `temporal_coherent_family_exists_zorn` with no sorry dependencies
- Maintain compatibility with existing `IndexedMCSFamily` interface
- No new axioms introduced

**Non-Goals**:
- Modifying the `IndexedMCSFamily` structure itself
- Addressing modal saturation (separate concern handled by `fully_saturated_bmcs_exists`)
- Proving coherent family existence for generic `D` (only Int needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency proof more complex than expected | High | Medium | Start with simpler G/H-only seed (Phase 3A), add F/P incrementally |
| Chain upper bound loses F/P witnesses | Medium | Medium | Carefully track witness times in domain, prove they persist |
| Maximality proof requires novel techniques | High | Low | Follow TemporalLindenbaum.lean pattern closely |
| Type-level complications with dependent MCS | Medium | Medium | Use non-dependent formulation (research Appendix suggestion) |

## Implementation Phases

### Phase 1: CoherentPartialFamily Structure [COMPLETED]

**Goal**: Define the core structure and basic infrastructure in a new file.

**Tasks**:
- [x] Create new file `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- [x] Define `CoherentPartialFamily` structure with non-dependent MCS field
- [x] Define GContent and HContent extractors for partial families
- [x] Define the partial order `CoherentPartialFamily.le`
- [x] Prove reflexivity, antisymmetry, and transitivity
- [x] Add basic accessor lemmas

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` (new file)
- `Theories/Bimodal.lean` (add import)

**Key Structure** (from research):
```lean
structure CoherentPartialFamily where
  domain : Set Int
  mcs : Int -> Set Formula
  domain_nonempty : domain.Nonempty  -- needed for Zorn base case
  is_mcs : forall t, t ∈ domain -> SetMaximalConsistent (mcs t)
  forward_G : forall t t', t ∈ domain -> t' ∈ domain -> t < t' ->
    forall phi, Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  backward_H : forall t t' , t' ∈ domain -> t ∈ domain -> t' < t ->
    forall phi, Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
  forward_F : forall t, t ∈ domain -> forall phi,
    Formula.some_future phi ∈ mcs t -> exists s, s ∈ domain ∧ t < s ∧ phi ∈ mcs s
  backward_P : forall t, t ∈ domain -> forall phi,
    Formula.some_past phi ∈ mcs t -> exists s, s ∈ domain ∧ s < t ∧ phi ∈ mcs s
```

**Verification**:
- `lake build` succeeds
- Structure compiles with all fields
- Partial order instance compiles

---

### Phase 2: Chain Upper Bound Lemma [COMPLETED]

**Goal**: Prove that chains of coherent partial families have upper bounds.

**Tasks**:
- [x] Define chain union operation for CoherentPartialFamily
- [x] Prove domain of upper bound is union of domains
- [x] Prove MCS agreement: chain property forces unique MCS at each time
- [x] Prove forward_G inherited from chain
- [x] Prove backward_H inherited from chain
- [x] Prove forward_F inherited (witness time also in union)
- [x] Prove backward_P inherited (witness time also in union)
- [x] State and prove `coherent_chain_has_upper_bound`

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`

**Key Insight**: For F/P inheritance, if F phi in mcs(t) for family F1 in chain, then F1.forward_F gives witness s in F1.domain. Since F1.domain subset of upper bound domain, witness s is in upper bound.

**Verification**:
- `lake build` succeeds
- `coherent_chain_has_upper_bound` compiles without sorry

---

### Phase 3: Extension Seed Consistency [PARTIAL]

**Goal**: Prove that extending a partial family to a new time preserves consistency.

**Tasks**:
- [x] Define `extensionSeed` combining G-content from past and H-content from future
- [x] Define helper lemmas for seed membership
- [x] Prove `GContent_consistent` and `HContent_consistent`
- [ ] Prove `extensionSeed_consistent` (has 3 sorries - technical debt)

**Technical Debt Status**:
The `extensionSeed_consistent` theorem has 3 sorries:
1. Cross-sign consistency (both past and future times exist)
2. Pure G-content case (requires picking supremum of past times)
3. Pure H-content case (requires picking infimum of future times)

These require 4-axiom propagation (G phi -> GG phi, H phi -> HH phi) to resolve.
The proof structure is in place but the detailed propagation arguments are pending.

**Files modified**:
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`

**Verification**:
- `lake build` succeeds (with sorry warnings)

---

### Phase 4: Zorn Application [PARTIAL]

**Goal**: Apply Zorn's lemma to obtain a maximal coherent partial family.

**Tasks**:
- [x] Define `CoherentExtensions` as the set of coherent partial families extending base
- [x] Construct base family infrastructure (buildBaseFamily)
- [x] Structure for Zorn application (maximalCoherentFamily)
- [ ] Complete Zorn lemma application (3 sorries)

**Technical Debt Status**:
The Zorn application has 3 sorries:
1. `maximalCoherentFamily` definition (Classical.choice placeholder)
2. `maximalCoherentFamily_extends` (base extension property)
3. `maximalCoherentFamily_maximal` (maximality property)

The base family construction also has 2 sorries for forward_F/backward_P since
a singleton domain cannot satisfy these without temporal saturation.

**Files modified**:
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`

**Verification**:
- `lake build` succeeds (with sorry warnings)

---

### Phase 5: Maximality Implies Totality [BLOCKED]

**Goal**: Prove that a maximal coherent partial family has domain = Set.univ.

**Tasks**:
- [ ] Assume maximal F with some t not in domain
- [ ] Construct extension seed for t
- [ ] Apply Lindenbaum to get MCS at t
- [ ] Build extended family F' with domain' = F.domain ∪ {t}
- [ ] Prove F' is coherent partial family
- [ ] Prove F < F' (strict extension)
- [ ] Contradiction with maximality

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`

**Key Theorem**:
```lean
lemma maximal_coherent_family_total (F : CoherentPartialFamily)
    (hmax : ∀ G : CoherentPartialFamily, F.le G → G.le F) :
    F.domain = Set.univ
```

**Verification**:
- `lake build` succeeds
- Totality lemma compiles without sorry

---

### Phase 6: Final Construction and Integration [BLOCKED]

**Goal**: Extract IndexedMCSFamily and prove all properties, replacing DovetailingChain sorries.

**Tasks**:
- [ ] Define `buildZornFamily` that constructs IndexedMCSFamily from maximal partial family
- [ ] Prove context preservation at time 0
- [ ] Prove forward_G (from CoherentPartialFamily.forward_G + totality)
- [ ] Prove backward_H (from CoherentPartialFamily.backward_H + totality)
- [ ] Prove forward_F (from CoherentPartialFamily.forward_F + totality)
- [ ] Prove backward_P (from CoherentPartialFamily.backward_P + totality)
- [ ] State `temporal_coherent_family_exists_zorn` theorem
- [ ] Update DovetailingChain.lean to use new construction (or mark old as deprecated)
- [ ] Verify sorry count reduced by 4

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (integration)

**Key Theorem**:
```lean
theorem temporal_coherent_family_exists_zorn
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : IndexedMCSFamily Int),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t →
        ∃ s : Int, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t →
        ∃ s : Int, s < t ∧ φ ∈ fam.mcs s)
```

**Verification**:
- `lake build` succeeds
- All 4 sorries eliminated
- Run `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` shows 0 matches
- Run `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` shows 0 matches

---

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] No new `axiom` declarations introduced
- [ ] Sorry count in DovetailingChain.lean: 0 (was 4)
- [ ] `temporal_coherent_family_exists_zorn` has no sorry dependencies
- [ ] Existing completeness proofs still compile (no interface changes)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - New file with Zorn construction
- Updated `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Integration/deprecation
- Implementation summary at completion

## Rollback/Contingency

If implementation proves infeasible:
1. ZornFamily.lean can remain as work-in-progress with sorries
2. DovetailingChain.lean continues unchanged
3. Fallback: Implement cross-sign fix only (Phases 1-5 without F/P witnesses)
   - This eliminates 2 of 4 sorries (lines 606, 617)
   - Leave witness sorries (lines 633, 640) for separate task
