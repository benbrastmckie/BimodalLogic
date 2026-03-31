# Implementation Plan: Task #70 - Separate-Direction Witnesses (v5)

- **Task**: 70 - Explore ultrafilter-based construction for temporal coherence
- **Status**: [COMPLETED]
- **Effort**: 8-12 hours
- **Dependencies**: None (infrastructure already exists)
- **Research Inputs**:
  - reports/10_blocker-analysis.md (G-liftability analysis)
  - reports/09_team-research.md (bidirectional witness analysis - blocked approach)
  - summaries/06_bidirectional-blocked-summary.md (Phase 2 blocker details)
- **Artifacts**: plans/05_separate-direction-witnesses.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the **separate-direction witnesses** approach to temporal coherence, following the recommendation from report 10. Plan v4 (bidirectional witness) is blocked because H_theory elements are not G-liftable (H(a) -> G(H(a)) is not derivable in TM).

**Key Insight**: Don't try to combine F-witness and P-witness at the seed level. Instead:
1. F-witnesses use `temporal_box_seed` (G_theory + box_theory) - already proven consistent
2. P-witnesses use `past_temporal_box_seed` (H_theory + box_theory) - already proven consistent
3. Cross-direction coherence achieved at **chain level** via Succ relation properties

**Why This Works**:
- The Succ relation already provides:
  - `g_content(M) ⊆ M'` (G-formulas persist forward)
  - `h_content(M') ⊆ M` (H-formulas persist backward)
- So even though individual witnesses don't preserve both directions, the **chain** does
- SuccChainFMCS already has sorry-free `forward_G` and `backward_H` propagation

## Goals & Non-Goals

**Goals**:
- Archive bidirectional_seed construction as blocked
- Implement chain-level cross-direction coherence proofs
- Connect existing SuccChainFMCS infrastructure to truth lemma requirements
- Achieve sorry-free temporal coherence sufficient for completeness

**Non-Goals**:
- Single-witness bidirectional preservation (proven impossible in report 10)
- Fixing f_nesting_is_bounded (separate concern, requires formula restriction)
- Adding H(a) -> G(H(a)) axiom (would change the logic)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Chain-level G/H not sufficient for truth lemma | H | L | Truth lemma requires G propagation which chain provides |
| forward_F/backward_P gaps remain | M | H | These are separate concerns; focus on G/H first |
| Succ relation properties incomplete | M | L | Properties already proven in codebase |
| Effort underestimate | L | M | Leveraging existing infrastructure reduces risk |

## Implementation Phases

### Phase 0: Archive Bidirectional Construction [COMPLETED]

**Goal**: Mark bidirectional_seed construction as blocked/experimental.

**Tasks**:
- [ ] Add `-- BLOCKED: H_theory not G-liftable (see report 10)` comment to `bidirectional_temporal_box_seed`
- [ ] Add `-- BLOCKED: requires H(a)->G(H(a)) which is not derivable` to `bidirectional_seed_consistent` sorries
- [ ] Update plan v4 status to [BLOCKED] (already done in previous session)

**Files**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 30 minutes

**Verification**: `lake build` passes

---

### Phase 1: Prove Succ Relation G-Propagation [COMPLETED]

**Goal**: Verify/strengthen the g_content subset property in Succ relation.

**Key Theorem**:
```lean
/-- If M Succ M', then G-formulas in M persist to M' -/
theorem Succ.g_content_subset (h : Succ M M') :
    g_content M ⊆ M'
```

Where `g_content M = {φ | G(φ) ∈ M}` (the "unboxed" G-formulas).

**Analysis**: This should already exist or be easily derivable from the Succ definition. The Succ relation includes `temporal_forward : ∀ φ, G(φ) ∈ M → φ ∈ M'`.

**Tasks**:
- [ ] Locate existing `g_content_subset` or equivalent in Succ definition
- [ ] If missing, prove from `temporal_forward` field
- [ ] Document the property clearly

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/Successor.lean`

**Timing**: 1 hour

**Verification**: `lake build` passes, theorem has no sorry

---

### Phase 2: Prove Succ Relation H-Propagation [COMPLETED]

**Goal**: Verify/strengthen the h_content subset property in Succ relation (backward direction).

**Key Theorem**:
```lean
/-- If M Succ M', then H-formulas in M' propagate back to M -/
theorem Succ.h_content_backward (h : Succ M M') :
    h_content M' ⊆ M
```

Where `h_content M' = {φ | H(φ) ∈ M'}` (the "unboxed" H-formulas).

**Analysis**: This follows from the Succ relation's `temporal_backward : ∀ φ, H(φ) ∈ M' → φ ∈ M`.

**Tasks**:
- [ ] Locate existing `h_content_backward` or equivalent
- [ ] If missing, prove from `temporal_backward` field
- [ ] Document the property clearly

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/Successor.lean`

**Timing**: 1 hour

**Verification**: `lake build` passes, theorem has no sorry

---

### Phase 3: Chain-Level G-Propagation (Forward) [COMPLETED]

**Goal**: Prove G-formulas propagate through the forward chain.

**Key Theorem**:
```lean
/-- G(φ) in chain(n) implies φ in chain(m) for all m ≥ n -/
theorem succ_chain_forward_G (M0 : SerialMCS) (n m : Int) (h : n ≤ m) (φ : Formula) :
    Formula.all_future φ ∈ succ_chain_fam M0 n → φ ∈ succ_chain_fam M0 m
```

**Analysis**: This is likely already proven or straightforward by induction using `Succ.g_content_subset`.

**Tasks**:
- [ ] Locate existing `succ_chain_forward_G` or equivalent
- [ ] If missing, prove by induction on m - n
- [ ] Verify sorry-free

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 1.5 hours

**Verification**: `lake build` passes, `#print axioms succ_chain_forward_G` shows no `sorryAx`

---

### Phase 4: Chain-Level H-Propagation (Backward) [COMPLETED]

**Goal**: Prove H-formulas propagate through the backward chain.

**Key Theorem**:
```lean
/-- H(φ) in chain(m) implies φ in chain(n) for all n ≤ m -/
theorem succ_chain_backward_H (M0 : SerialMCS) (n m : Int) (h : n ≤ m) (φ : Formula) :
    Formula.all_past φ ∈ succ_chain_fam M0 m → φ ∈ succ_chain_fam M0 n
```

**Analysis**: Symmetric to Phase 3, using `Succ.h_content_backward`.

**Tasks**:
- [ ] Locate existing `succ_chain_backward_H` or equivalent
- [ ] If missing, prove by induction on m - n
- [ ] Verify sorry-free

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 1.5 hours

**Verification**: `lake build` passes, `#print axioms succ_chain_backward_H` shows no `sorryAx`

---

### Phase 5: Package as TemporallyCoherent FMCS [COMPLETED]

**Goal**: Show SuccChainFMCS satisfies temporal coherence requirements.

**Definition**: An FMCS is temporally coherent if:
1. **Forward G**: `G(φ) ∈ fam(t) → ∀t' ≥ t, φ ∈ fam(t')`
2. **Backward H**: `H(φ) ∈ fam(t) → ∀t' ≤ t, φ ∈ fam(t')`
3. **Forward F** (weaker): `F(φ) ∈ fam(t) → ∃t' > t, φ ∈ fam(t')`
4. **Backward P** (weaker): `P(φ) ∈ fam(t) → ∃t' < t, φ ∈ fam(t')`

**Tasks**:
- [ ] Define `SuccChainFMCS_forward_G` wrapper using Phase 3
- [ ] Define `SuccChainFMCS_backward_H` wrapper using Phase 4
- [ ] Document forward_F/backward_P as separate concern (unbounded nesting issue)

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 1.5 hours

**Verification**: `lake build` passes

---

### Phase 6: Connect to Truth Lemma [COMPLETED]

**Goal**: Verify that chain-level coherence suffices for truth lemma.

**Truth Lemma Requirements**:
- `G(φ) true at (τ, t)` iff `∀t' ≥ t, φ true at (τ, t')`
- This requires `φ ∈ fam(t')` for all `t' ≥ t`, which follows from `G(φ) ∈ fam(t)` via `forward_G`

**Tasks**:
- [ ] Review `parametric_canonical_truth_lemma` in existing codebase
- [ ] Verify `forward_G` and `backward_H` are sufficient for G/H cases
- [ ] Identify what's needed for F/P cases (document as follow-up work)
- [ ] Create integration theorem or document existing

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 2 hours

**Verification**: `lake build` passes, G/H truth lemma cases are sorry-free

---

### Phase 7: Document F/P Gaps and Next Steps [COMPLETED]

**Goal**: Document remaining work for forward_F and backward_P.

**Analysis**: The F/P cases require existence witnesses, not universal propagation. The existing `succ_chain_forward_F` has sorries due to unbounded nesting. This is a separate concern from the G/H coherence this plan addresses.

**Tasks**:
- [ ] Document the F/P gap clearly in SuccChainFMCS.lean
- [ ] Create follow-up task if needed for formula-restricted completeness
- [ ] Update ROADMAP.md with progress on temporal coherence

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `ROADMAP.md`

**Timing**: 1 hour

**Verification**: Documentation complete

---

## Dependency Graph

```
[Phase 0: Archive] ─────────────────────────────────────+
                                                        |
                    +───────────────────+               |
                    |                   |               |
                    v                   v               v
             [Phase 1: G-prop]   [Phase 2: H-prop]   (parallel)
                    |                   |
                    v                   v
             [Phase 3: Chain G] [Phase 4: Chain H]
                    |                   |
                    +─────────+─────────+
                              |
                              v
                      [Phase 5: FMCS]
                              |
                              v
                    [Phase 6: Truth Lemma]
                              |
                              v
                     [Phase 7: Document]
```

**Parallelization**: Phases 1-2 can run in parallel. Phases 3-4 can run in parallel.

## Testing & Validation

- [ ] `lake build` passes at each phase
- [ ] `#print axioms succ_chain_forward_G` shows no `sorryAx`
- [ ] `#print axioms succ_chain_backward_H` shows no `sorryAx`
- [ ] G/H cases in truth lemma are sorry-free
- [ ] Bidirectional construction properly archived

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Phase 0 (archive)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Phases 1-6
- `ROADMAP.md` - Phase 7
- `specs/070_explore_ultrafilter_construction/summaries/07_separate-direction-summary.md` - Final summary

## Success Criteria

1. **Sorry-free G propagation**: `succ_chain_forward_G` compiles without sorry
2. **Sorry-free H propagation**: `succ_chain_backward_H` compiles without sorry
3. **Truth lemma G/H cases**: No new sorries in G(φ) and H(φ) truth lemma cases
4. **Clear documentation**: F/P gaps documented with follow-up path
5. **Bidirectional archived**: Plan v4 approach clearly marked as blocked

## Rollback/Contingency

If this approach fails:

1. **Revisit H(a) -> G(H(a)) axiom**: Create separate task to evaluate adding this axiom
2. **Formula-restricted completeness**: Limit completeness to formulas with bounded F/P nesting
3. **Bundle-level coherence**: Accept weaker semantics for temporal operators

The research indicates high confidence in the separate-direction approach since it leverages existing sorry-free infrastructure.
