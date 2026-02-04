# Implementation Plan: Axiom-Free Bimodal/Metalogic Completeness

- **Task**: 843 - remove_singleFamily_modal_backward_axiom
- **Version**: 004
- **Status**: [NOT STARTED]
- **Effort**: 20-30 hours
- **Dependencies**: Task 856 (COMPLETED), Task 857 (COMPLETED)
- **Research Inputs**: research-008.md (post-857 assessment)
- **Artifacts**: plans/implementation-004.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan focuses on the hard mathematical work: making `Bimodal/Metalogic/` sorry-free and axiom-free, producing a publication-ready completeness theorem. The scope is narrowed from v003 to exclude Boneyard moves and Logos/Automation cleanup (which are trivial/mechanical work that can be done separately).

### What Changed from v003

| Aspect | v003 | v004 |
|--------|------|------|
| Scope | ALL axioms/sorries across entire codebase | Bimodal/Metalogic/ only |
| Dropped | Boneyard moves (Phase 1), Logos/Automation sorries (Phase 2), final documentation (Phase 7) | |
| Focus | Broad cleanup + hard math | Hard math only |
| Phases | 7 | 5 |
| Estimated hours | 28-42 | 20-30 |
| Rationale | User requested focus on "completing the remaining hard work" | |

### Completeness Dependency Graph (Current)

```
bmcs_strong_completeness (sorry-free)
  → bmcs_context_representation (sorry-free)
    → construct_temporal_bmcs
      → singleFamilyBMCS
        → singleFamily_modal_backward_axiom  ← AXIOM 1
      → temporal_eval_saturated_bundle_exists
        → temporally_saturated_mcs_exists     ← AXIOM 2
    → bmcs_truth_lemma (sorry-free)
```

### Target Dependency Graph

```
bmcs_strong_completeness (sorry-free, axiom-free)
  → bmcs_context_representation (sorry-free, axiom-free)
    → construct_axiomfree_bmcs
      → temporalLindenbaumMCS (proven)        ← REPLACES AXIOM 2
      → multi-family saturation (proven)       ← REPLACES AXIOM 1
    → bmcs_truth_lemma (sorry-free, unchanged)
```

## Goals & Non-Goals

**Goals**:
- Zero axioms in `Theories/Bimodal/Metalogic/Bundle/` (active code)
- Zero sorries in `Theories/Bimodal/Metalogic/Bundle/` (active code)
- Completeness theorem chain with no transitive axiom or sorry dependencies
- `#check @bmcs_strong_completeness` shows no axiom dependencies

**Non-Goals**:
- Boneyard moves (SaturatedConstruction.lean, PreCoherentBundle.lean, WeakCoherentBundle.lean)
- Logos/Automation sorry removal
- Examples cleanup
- Module hierarchy restructuring

## Axiom Characterization

### Axioms to Eliminate

| # | Axiom | File | Used By |
|---|-------|------|---------|
| 1 | `singleFamily_modal_backward_axiom` | Construction.lean:228 | `singleFamilyBMCS` → completeness |
| 2 | `temporally_saturated_mcs_exists` | TemporalCoherentConstruction.lean:575 | `temporal_eval_saturated_bundle_exists` → completeness |

### Axioms NOT Targeted (Dead Code)

| Axiom | File | Reason |
|-------|------|--------|
| `saturated_extension_exists` | CoherentConstruction.lean:871 | Not imported by completeness chain |
| `weak_saturated_extension_exists` | WeakCoherentBundle.lean:826 | Not imported by completeness chain |

### New Axioms

None.

## Sorry Characterization

### Sorries to Eliminate

| # | File | Lines | Count | Strategy |
|---|------|-------|-------|----------|
| 1 | TruthLemma.lean | 604, 611, 625, 639 | 4 | Delete legacy `eval_bmcs_truth_lemma` — not used by completeness, structurally unfixable |

### Sorries NOT Targeted

SaturatedConstruction.lean (3), PreCoherentBundle.lean (2), WeakCoherentBundle.lean (3) — all dead code, not imported by completeness.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-family `{psi} ∪ UnionBoxContent(B)` consistency proof fails | High | Medium | Incremental: phases 1-2 alone eliminate AXIOM 2; fall back to 1-axiom completeness |
| Omega-step Lindenbaum construction is complex | Medium | Medium | Use existing `set_lindenbaum` (Zorn-based) as template; proven `temporal_witness_seed_consistent` handles the key step |
| Formula enumeration requires new infrastructure | Medium | Low | Standard countable inductive type; Lean handles this well |
| Rewiring completeness breaks downstream | Medium | Low | Keep original `construct_temporal_bmcs` until replacement is verified |

## Implementation Phases

### Phase 1: Implement `temporalLindenbaumMCS` [NOT STARTED]

**Goal**: Build a modified Lindenbaum construction producing temporally saturated MCS, proving the existence statement that `temporally_saturated_mcs_exists` currently asserts as an axiom.

**Mathematical approach**: The standard Lindenbaum lemma uses Zorn's lemma to get a maximal consistent set. For temporal saturation, we need that F(psi) ∈ M implies psi ∈ M (and similarly for P). Two approaches exist:

1. **Modified Zorn**: Define `TemporallySaturatedSupersets` — consistent supersets where F(psi) ∈ S implies psi ∈ S — and show chains have upper bounds. This leverages the existing Zorn-based `set_lindenbaum` pattern.

2. **Henkin enumeration**: Enumerate formulas, building the set step-by-step, inserting temporal witnesses at each step. This is more constructive but requires formula enumeration infrastructure.

**Recommended approach**: Modified Zorn (approach 1). Reason: the existing `set_lindenbaum` already uses Zorn's lemma via `zorn_subset_nonempty` from Mathlib. We just need to restrict to temporally saturated supersets and show chains preserve temporal saturation. The key consistency argument is `temporal_witness_seed_consistent` (already proven at TemporalCoherentConstruction.lean:477).

**Key insight**: If M is maximal among temporally-saturated consistent sets and F(psi) ∈ M, we need psi ∈ M. Suppose psi ∉ M. By temporal saturation closure (F(psi) ∈ M requires considering psi), M ∪ {psi} is not in the saturated supersets — but `temporal_witness_seed_consistent` shows `{psi} ∪ GContent(M)` is consistent, so M ∪ {psi} should be consistent. The subtlety is ensuring M ∪ {psi} is still temporally saturated (or that we can close it). The Zorn maximal approach handles this: M is maximal consistent AND temporally saturated, so if F(psi) ∈ M, then the "temporal closure" of M ∪ {psi} is consistent (by the witness seed lemma), contradicting maximality of M.

**Alternative**: If the Zorn approach proves difficult with temporal saturation, fall back to Henkin enumeration. The `Formula` type is countable (finite recursive grammar), so enumeration is straightforward.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (new file)
- [ ] Define `TemporalConsistentSuperset` predicate: set S extends Gamma, is consistent, and is temporally forward-saturated and backward-saturated
- [ ] Prove chains of temporal consistent supersets have upper bounds (union of chain is temporal consistent superset)
- [ ] Key lemma: if S is a temporal consistent superset and phi ∈ S, then for any formula we can extend while preserving temporal saturation
- [ ] Apply Zorn's lemma to get maximal temporal consistent superset
- [ ] Prove maximality implies set-maximal consistency (standard argument: if phi and ¬phi both not in M, extend by one — but must verify temporal saturation is preserved)
- [ ] Prove the result satisfies `TemporalForwardSaturated` and `TemporalBackwardSaturated`
- [ ] Prove the result extends the original context
- [ ] Package as `temporalLindenbaumMCS` matching the signature of `temporally_saturated_mcs_exists`
- [ ] Run `lake build` to verify

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` — new file

**Verification**:
- `lake build` passes
- New file compiles without sorry or axiom
- `#check @temporalLindenbaumMCS` shows no axiom dependencies

---

### Phase 2: Eliminate `temporally_saturated_mcs_exists` Axiom [NOT STARTED]

**Goal**: Replace the axiom in TemporalCoherentConstruction.lean with the proven `temporalLindenbaumMCS` from Phase 1. This eliminates AXIOM 2 from the completeness chain.

**Tasks**:
- [ ] Import TemporalLindenbaum.lean in TemporalCoherentConstruction.lean
- [ ] Replace the usage of `temporally_saturated_mcs_exists` in `temporal_eval_saturated_bundle_exists` with `temporalLindenbaumMCS`
- [ ] Verify that `construct_temporal_bmcs` still compiles (it depends on `temporal_eval_saturated_bundle_exists`)
- [ ] Delete or comment out the `temporally_saturated_mcs_exists` axiom declaration
- [ ] Update the documentation docstring to reflect that this is now proven
- [ ] Run `lake build`
- [ ] Verify: `#check @construct_temporal_bmcs` should show only `singleFamily_modal_backward_axiom` (not both axioms)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` — replace axiom with proven theorem

**Verification**:
- `lake build` passes
- `grep -rn "temporally_saturated_mcs_exists" Theories/Bimodal/Metalogic/Bundle/` returns only comments
- Completeness chain depends on only 1 axiom (`singleFamily_modal_backward_axiom`)

---

### Phase 3: Multi-Family Saturated BMCS Construction [NOT STARTED]

**Goal**: Build a BMCS where every Diamond formula has a witness family, eliminating the need for `singleFamily_modal_backward_axiom`. This is the hardest phase and the original goal of task 843.

**Mathematical approach**: The standard canonical model construction for normal modal logics builds a model from ALL maximal consistent sets. For a BMCS, we need:

1. A set of families (each a constant indexed MCS family)
2. For every ◇ψ in any family, there exists a witness family containing ψ
3. `modal_forward`: □φ ∈ fam.mcs t → φ ∈ fam'.mcs t (for all fam') — follows from mutual coherence + T-axiom
4. `modal_backward`: (∀ fam', φ ∈ fam'.mcs t) → □φ ∈ fam.mcs t — follows from saturation by contraposition

**The contraposition argument for modal_backward**:
Suppose φ is in ALL families at t but □φ ∉ fam.mcs t. Since fam is MCS, ¬□φ ∈ fam.mcs t, i.e., ◇¬φ ∈ fam.mcs t. By saturation, there exists a witness family w with ¬φ ∈ w.mcs t. But φ is in ALL families, including w. Contradiction (MCS cannot contain both φ and ¬φ).

**Key mathematical challenge**: Proving `{ψ} ∪ UnionBoxContent(B)` is consistent when ◇ψ is in some family of B. The singleton case is proven (`diamond_boxcontent_consistent_constant`). The multi-family case requires:

For multi-family B, `UnionBoxContent(B) = ⋃_{fam ∈ B} BoxContent(fam)`. If ◇ψ ∈ base.mcs t, we need `{ψ} ∪ ⋃ BoxContent(fam_i)` consistent.

**Key insight for multi-family**: If all families in B are `MutuallyCoherent` (each contains `UnionBoxContent(B)`), then for any fam ∈ B, `BoxContent(fam) ⊇ UnionBoxContent(B)` at the MCS level. Wait — that's backwards. `UnionBoxContent ⊇ BoxContent(fam)`. But MutuallyCoherent means each fam.mcs t ⊇ UnionBoxContent. So `UnionBoxContent(B) ⊆ fam.mcs t` for all fam, t. Since □χ ∈ fam.mcs t for all χ ∈ UnionBoxContent means χ is boxed somewhere. Actually, by mutual coherence, χ ∈ fam.mcs t for all fam, t. So `UnionBoxContent(B) ⊆ ⋂ fam.mcs t`. Then:

`{ψ} ∪ UnionBoxContent(B) ⊆ {ψ} ∪ base.mcs t` (since UnionBoxContent ⊆ base.mcs t by mutual coherence).

And `{ψ} ∪ BoxContent(base)` is consistent by `diamond_boxcontent_consistent_constant`. Since `UnionBoxContent(B) ⊆ base.mcs t ⊇ BoxContent(base)`, hmm, that's not quite right.

**Alternative approach**: Instead of growing a CoherentBundle iteratively, use the standard canonical model construction:
- Take ALL MCS (or all temporally-saturated MCS)
- Define families = one constant family per MCS
- The BMCS has ALL of them
- Modal saturation is automatic: if ◇ψ ∈ M, then ¬□¬ψ ∈ M, so {ψ} ∪ BoxContent(M) is consistent (by K-distribution), extend to MCS → witness family exists
- Mutual coherence: for □χ ∈ some M at some t, χ must be in ALL families. This is exactly what MutuallyCoherent says.

Wait — this is the standard approach but may not give MutuallyCoherent. If □χ ∈ M but χ ∉ M', then M' doesn't contain BoxContent(M). This is expected: the standard canonical model doesn't have mutual coherence across ALL MCS.

**Revised approach**: The correct construction is:
1. Start with an eval MCS (from the consistent context)
2. For each ◇ψ in eval, construct a witness MCS containing ψ ∪ BoxContent(eval) — this IS proven (`diamond_boxcontent_consistent_constant`)
3. For each ◇ψ' in a witness, construct a second-level witness containing ψ' ∪ BoxContent(witness) — but this might introduce NEW box formulas
4. Iterate until saturation

The key issue is: new witnesses may have new BoxContent, which other families don't contain. The EvalCoherent approach avoided this by only requiring BoxContent(eval) in all families.

**For full mutual coherence**, we need all families to contain the BoxContent of ALL other families. This is achievable if we construct the bundle as a FIXED POINT:
- Start with initial bundle B₀ = {eval}
- At each step, for each unsatisfied ◇ψ in some family, add a witness containing ψ ∪ UnionBoxContent(current bundle)
- The witness's BoxContent may add new obligations
- Continue until no new obligations arise

The question is whether this terminates and whether UnionBoxContent stabilizes.

**For constant MCS families with the same underlying MCS content at all times**, BoxContent(fam) only depends on the formulas in fam.mcs (which is constant). So adding a witness with more formulas may have MORE BoxContent. But the formula language is countable, and BoxContent is bounded by the set of all subformulas of Box formulas. Actually BoxContent grows monotonically with the MCS, and is bounded by all formulas, so by cardinality arguments (or well-foundedness), the process must stabilize.

**Practical approach**: Use ordinal-indexed iteration or Zorn's lemma on CoherentBundles ordered by inclusion.

**Tasks**:
- [ ] Study the existing `CoherentBundle` infrastructure in CoherentConstruction.lean
- [ ] Research whether the multi-family consistency can be proven via the `EvalCoherent` + `eval_saturated_bundle_exists` approach by showing EvalCoherent bundles already have modal_backward
- [ ] If EvalCoherent approach works: prove `modal_backward` for EvalCoherentBundles (the missing piece)
- [ ] If not: implement iterative saturation or Zorn-based full saturation
- [ ] Prove `modal_backward` via contraposition argument
- [ ] Prove `modal_forward` via T-axiom (same as current `singleFamilyBMCS`)
- [ ] Combine with temporal saturation from Phase 1 for temporally coherent families
- [ ] Produce `axiomFree_bmcs`: a BMCS construction with no axiom dependencies

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` — extend with multi-family modal_backward proof
- Or new file `Theories/Bimodal/Metalogic/Bundle/SaturatedBMCS.lean`

**Verification**:
- `lake build` passes
- New construction compiles without sorry or axiom
- `#check @axiomFree_bmcs` shows no axiom dependencies
- Modal forward/backward proven for ALL families

---

### Phase 4: Rewire Completeness to Axiom-Free Construction [NOT STARTED]

**Goal**: Replace `construct_temporal_bmcs` in the completeness chain with the axiom-free construction from Phases 1-3.

**Tasks**:
- [ ] Create `construct_axiomfree_bmcs` that combines temporal saturation (Phase 1) with multi-family modal saturation (Phase 3)
- [ ] Prove `construct_axiomfree_bmcs_contains_context`: the construction preserves the original context
- [ ] Prove `construct_axiomfree_bmcs_temporally_coherent`: the construction produces temporally coherent BMCS
- [ ] Update `bmcs_representation` in Completeness.lean to use `construct_axiomfree_bmcs`
- [ ] Update `bmcs_context_representation` similarly
- [ ] Verify `bmcs_truth_lemma` still applies (it needs `temporally_coherent`)
- [ ] Delete `singleFamily_modal_backward_axiom` from Construction.lean
- [ ] Delete `singleFamilyBMCS` (no longer needed)
- [ ] Delete `temporally_saturated_mcs_exists` if not already done in Phase 2
- [ ] Delete legacy `eval_bmcs_truth_lemma` from TruthLemma.lean (4 sorries, structurally unfixable, not used by completeness)
- [ ] Run `lake build`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` — rewire to axiom-free construction
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` — delete axiom and singleFamilyBMCS
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` — clean up axiom remnants
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` — delete legacy eval_bmcs_truth_lemma

**Verification**:
- `lake build` passes
- `grep -rn "^axiom " Theories/Bimodal/Metalogic/Bundle/` returns no results
- `grep -rn "sorry" Theories/Bimodal/Metalogic/Bundle/` returns no results
- `#check @bmcs_strong_completeness` shows no axiom dependencies
- `#check @bmcs_weak_completeness` shows no axiom dependencies

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that `Bimodal/Metalogic/` is publication-ready.

**Tasks**:
- [ ] Run `grep -rn "^axiom " Theories/Bimodal/Metalogic/Bundle/` — expect no results
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/Bundle/` — expect no results (exclude Boneyard)
- [ ] Run `lake build` — expect clean build
- [ ] Verify `#check @bmcs_strong_completeness` has no axiom dependencies
- [ ] Verify `#check @bmcs_weak_completeness` has no axiom dependencies
- [ ] Verify `#check @bmcs_representation` has no axiom dependencies
- [ ] Update state.json with completion data
- [ ] Create implementation summary

**Files to modify**:
- `specs/state.json` — update repository_health and task status
- `specs/TODO.md` — update task status

**Verification**:
- All checks pass
- Implementation summary created

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Zero axioms in `Theories/Bimodal/Metalogic/Bundle/` after Phase 4
- [ ] Zero sorries in `Theories/Bimodal/Metalogic/Bundle/` after Phase 4
- [ ] `#check @bmcs_strong_completeness` shows no axiom dependencies
- [ ] `#check @bmcs_weak_completeness` shows no axiom dependencies
- [ ] `#check @bmcs_representation` shows no axiom dependencies

## Incremental Value

| After Phase | Axioms Left | Sorries Left | Value |
|-------------|------------|-------------|-------|
| Phase 1 | 2 | 4 | Temporal Lindenbaum infrastructure (proven) |
| Phase 2 | 1 | 4 | Completeness chain down to 1 axiom |
| Phase 3 | 1 | 4 | Multi-family BMCS infrastructure (proven) |
| Phase 4 | 0 | 0 | ZERO axioms, ZERO sorries in active Metalogic/ |
| Phase 5 | 0 | 0 | Verified publication-ready state |

**If Phase 3 fails**: Phases 1-2 alone reduce the completeness chain from 2 axioms to 1. This is independently publishable with axiom disclosure.

## Rollback/Contingency

**Phase 1-2 rollback**: New `TemporalLindenbaum.lean` can be deleted; axiom remains unchanged.

**Phase 3 rollback**: New multi-family construction is additive; original `construct_temporal_bmcs` remains until replacement is verified.

**Phase 4 rollback**: Axioms/sorries are only deleted after replacement is confirmed working.

**If Phase 3 fails entirely**: Create a follow-up task for multi-family consistency research. The 1-axiom completeness from Phases 1-2 is still a major improvement.

## Comparison with Previous Versions

| Aspect | v001 | v002 | v003 | v004 |
|--------|------|------|------|------|
| Scope | 1 axiom | 1 axiom | All axioms + all sorries | Bimodal/Metalogic/ only |
| Phases | 4 | 2 | 7 | 5 |
| Hours | 9 | 4-6 | 28-42 | 20-30 |
| Focus | EvalBMCS | Eval-only forward | Broad cleanup + math | Hard math only |
| Approach | EvalBMCS truth lemma | Eval-only forward | Temporal Lindenbaum + multi-family | Temporal Lindenbaum + multi-family |
| Key change from prev | — | — | Added Boneyard + Logos phases | Dropped Boneyard + Logos phases |
