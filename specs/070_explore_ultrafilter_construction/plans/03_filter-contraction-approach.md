# Implementation Plan: Task #70 - Ultrafilter-Based Temporal Coherence (Revised v3)

- **Task**: 70 - Explore ultrafilter-based construction for temporal coherence
- **Status**: [IN PROGRESS]
- **Effort**: 6-10 hours (remaining)
- **Dependencies**: None (all infrastructure exists)
- **Research Inputs**:
  - reports/08_team-research.md (filter-deduction-contraction approach)
  - reports/05_team-research.md (synthesized team findings)
  - summaries/01_ultrafilter-summary.md (Phases 1-3, 4A, 4B, 5 completion)
- **Artifacts**: plans/03_filter-contraction-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan completes the ultrafilter-based construction by fixing the corner case sorries in Phases 4C/4D using the **filter-deduction-contraction approach** from team research report 08. The issue is that when `phi in L` but appears multiple times, removing only the first occurrence leaves phi-copies in `L_no_phi`, breaking the `L_no_phi subset G_seed` claim.

### What Changed from v2

The v2 plan's Phase 4C/4D proof structure was flawed:
- **Problem**: Used `L_no_phi = L.erase phi` (removes first occurrence only)
- **Consequence**: If `L = [phi, phi]`, then `L_no_phi = [phi]`, but phi is NOT in `G_seed`
- **Impact**: Line 1113 (F) and 1322 (P) sorries for this edge case

**Solution** (from report 08): Replace `L_no_phi` with `L_filt = L_no_phi.filter (!=phi)` removing ALL phi-occurrences, then use exchange + deduction + contraction to derive `neg_phi`.

### Completed Phases (v2)

- **Phase 4A**: `G_preimage_inf` [COMPLETED]
- **Phase 4B**: `H_preimage_inf` [COMPLETED]
- **Phase 5**: `UltrafilterChain_to_FMCS` [COMPLETED]

### Remaining Work

- **Phase 4C**: Fix corner case in `ultrafilter_F_resolution`
- **Phase 4D**: Fix corner case in `ultrafilter_P_resolution`
- **Phases 6A/6B**: FMCS temporal coherence (blocked by 4C/4D)
- **Phases 7A/7B**: Integration with truth lemma

## Goals and Non-Goals

**Goals**:
- Fix the 2 corner case sorries using filter-deduction-contraction
- Complete Phases 6-7 for full temporal coherence
- Achieve sorry-free path to completeness theorem

**Non-Goals**:
- Using strong induction (more complex, filter approach is cleaner)
- Modifying the truth lemma (Path B approach)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `derivation_exchange` type mismatch | M | L | Use exact types from MCSProperties.lean:61 |
| Contraction combinator chain fails | M | L | Fallback: prove `contraction` as standalone lemma |
| Filter disrupts existing fold argument | M | M | Preserve fold structure, only change input list |

## Implementation Phases

### Phase 4C-fix: Filter-Deduction-Contraction for F_resolution [COMPLETED]

**Goal**: Fix the corner case sorry at UltrafilterChain.lean line 1113.

**The Problem** (from report 08):
```
L = [phi, phi] subset seed = G_seed union {phi}
After L_no_phi = L.erase phi: L_no_phi = [phi]
But phi not_in G_seed, so L_no_phi not subset G_seed
```

**The Fix**:

1. **Define filtered list**:
   ```lean
   let L_filt := L_no_phi.filter (fun y => decide (y != phi))
   ```

2. **Prove `L_filt subset G_seed`**:
   Every element of L_filt is in seed (from L subset seed) and is not phi, so must be in G_seed.

3. **Prove `L_filt derives neg_phi`** via chain:
   - From `L derives bot` and `phi in L`, by `deduction_theorem`: `L_no_phi derives phi.imp bot`
   - From `L_no_phi derives phi -> bot` and `phi in L_no_phi`, by `deduction_theorem`: `L_filt derives phi -> phi -> bot`
   - By contraction: `L_filt derives phi -> bot` (i.e., `L_filt derives neg_phi`)

4. **Contraction proof** (using existing combinators):
   ```lean
   -- derives (phi -> phi -> bot) -> (phi -> bot)
   Combinators.mp
     (Combinators.identity phi)
     (Combinators.theorem_flip
       (DerivationTree.axiom [] _ (Axiom.prop_k phi phi Formula.bot)))
   ```

5. **Continue existing fold argument** with `L_filt` instead of `L_no_phi`:
   - `fold L_filt <= [neg_phi]` via `fold_le_of_derives`
   - All elements of L_filt are in G_seed
   - `G (fold L_filt) in U` via `G_preimage_inf`
   - `G neg_phi in U` via upward closure
   - Contradicts `h_F : F phi in U`

**Tasks**:
- [ ] Replace sorry at line 1113 with filter construction
- [ ] Prove `L_filt_subset_G_seed : forall y in L_filt, y in G_seed`
- [ ] Chain deduction theorems to get `L_filt derives neg_phi`
- [ ] Build contraction combinator inline
- [ ] Verify fold argument still works with L_filt

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines ~1080-1155)

**Verification**:
- `lake build` passes
- Sorry at line 1113 is removed
- `#print axioms ultrafilter_F_resolution` shows no `sorryAx`

**Key Infrastructure** (from report 08):
| Tool | Location | Purpose |
|------|----------|---------|
| `cons_filter_neq_perm` | MCSProperties.lean:37 | Filter membership preservation |
| `derivation_exchange` | MCSProperties.lean:61 | Convert derivation contexts |
| `deduction_theorem` | DeductionTheorem.lean:336 | Remove hypothesis |
| `Combinators.identity` | Combinators.lean:108 | `derives A -> A` |
| `Combinators.theorem_flip` | Combinators.lean:148 | Flip arguments |
| `Axiom.prop_k` | Axioms.lean:103 | S combinator |
| `fold_le_of_derives` | UltrafilterMCS.lean:551 | Derivation to lattice |

---

### Phase 4D-fix: Symmetric Fix for P_resolution [COMPLETED]

**Goal**: Fix the corner case sorry at UltrafilterChain.lean line 1322.

**Tasks**:
- [ ] Mirror Phase 4C-fix structure with H replacing G
- [ ] Define `L_filt` removing all phi occurrences
- [ ] Prove `L_filt subset H_seed`
- [ ] Chain deduction + contraction for `L_filt derives neg_phi`
- [ ] Complete fold argument with H_preimage_inf

**Timing**: 1.5 hours (faster due to symmetry)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines ~1290-1365)

**Verification**:
- `lake build` passes
- Sorry at line 1322 is removed
- `#print axioms ultrafilter_P_resolution` shows no `sorryAx`

**Dependencies**: None (can run in parallel with Phase 4C-fix)

---

### Phase 6A: Ultrafilter FMCS Forward F Coherence [COMPLETED]

**Goal**: Prove ultrafilter-based FMCS have family-level forward F coherence.

**Tasks**:
- [ ] Given F(phi) in mcs t, translate to `(G(neg phi))^c in uc.chain t`
- [ ] Apply `ultrafilter_F_resolution` to get V with `R_G(chain t, V)` and `phi in V`
- [ ] Return witness s >= t with phi in mcs s

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Dependencies**: Phase 4C-fix

**Type Signature**:
```lean
theorem ultrafilter_FMCS_forward_F (uf : UltrafilterFMCS)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ uf.mcs t) :
    ∃ s : Int, t ≤ s ∧ phi ∈ uf.mcs s
```

---

### Phase 6B: Ultrafilter FMCS Backward P Coherence [PARTIAL]

**Goal**: Prove ultrafilter-based FMCS have family-level backward P coherence.

**Tasks**:
- [ ] Given P(phi) in mcs t, translate to `(H(neg phi))^c in uc.chain t`
- [ ] Apply `ultrafilter_P_resolution` to get V with `R_H(chain t, V)` and `phi in V`
- [ ] Return witness s <= t with phi in mcs s

**Timing**: 1 hour (symmetric to 6A)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Dependencies**: Phase 4D-fix

---

### Phase 7A: Construct Ultrafilter-Based BFMCS [PARTIAL]

**Goal**: Build BFMCS from ultrafilter chains with `temporally_coherent` property.

**Tasks**:
- [ ] Define `construct_ultrafilter_bfmcs` taking seed MCS M0
- [ ] Convert M0 to ultrafilter, build chain, convert to FMCS
- [ ] Prove `temporally_coherent` using Phases 6A/6B
- [ ] Return `BFMCS Int` with coherence proof

**Timing**: 2 hours

**Dependencies**: Phases 6A, 6B

---

### Phase 7B: Integration with Truth Lemma [BLOCKED]

**Goal**: Complete integration with `parametric_canonical_truth_lemma`.

**Tasks**:
- [ ] Verify `construct_ultrafilter_bfmcs` output matches truth lemma input
- [ ] Apply truth lemma for canonical model membership
- [ ] Complete completeness theorem (sorry-free)

**Timing**: 1.5 hours

**Dependencies**: Phase 7A

---

## Dependency Graph

```
[Phase 4C-fix] ----------+
                         |
                         v
                   [Phase 6A] ----+
                                  |
[Phase 4D-fix] ----------+        |
                         |        |
                         v        |
                   [Phase 6B] ----+
                                  |
                                  v
                            [Phase 7A]
                                  |
                                  v
                            [Phase 7B]
                                  |
                                  v
                          [COMPLETENESS]
```

**Parallelization**: Phases 4C-fix and 4D-fix can run in parallel.

**Critical Path**: 4C-fix -> 6A -> 7A -> 7B

## Testing and Validation

- [ ] `lake build` passes at each phase
- [ ] Corner case sorries (lines 1113, 1322) resolved
- [ ] `#print axioms ultrafilter_F_resolution` shows no `sorryAx`
- [ ] `#print axioms ultrafilter_P_resolution` shows no `sorryAx`
- [ ] Final completeness theorem integrates with official semantics

## Artifacts

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Phases 4C-fix, 4D-fix, 6, 7
- `specs/070_explore_ultrafilter_construction/summaries/02_completion-summary.md` - Final summary
