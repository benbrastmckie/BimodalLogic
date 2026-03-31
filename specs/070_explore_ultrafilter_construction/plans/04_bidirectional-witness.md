# Implementation Plan: Task #70 - Bidirectional Temporal Witness (v4)

- **Task**: 70 - Explore ultrafilter-based construction for temporal coherence
- **Status**: [NOT STARTED]
- **Effort**: 15-20 hours
- **Dependencies**: None (all infrastructure exists)
- **Research Inputs**:
  - reports/09_team-research.md (bidirectional witness mathematical analysis)
  - reports/08_team-research.md (seed consistency analysis)
  - summaries/04_final-implementation-summary.md (current state)
- **Artifacts**: plans/04_bidirectional-witness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the **mathematically correct** approach to temporal coherence: the **bidirectional temporal witness construction**. Previous approaches (CoherentZChain, bundle-level coherence) failed because:

1. **CoherentZChain** (6 unfixable sorries at lines 7377, 7380, 7392, 7394, 7453, 7469): The forward chain preserves G but not H; the backward chain preserves H but not G. Cross-direction coherence is impossible.

2. **Bundle-level coherence**: The truth lemma intrinsically requires same-family witnesses. G(phi) true at (tau, t) means phi true at (tau, s) for all s >= t along the **same history tau**. Bundle-level witnesses use different families, invalidating the semantic argument.

3. **`f_preserving_seed_consistent` sub-case A** (lines 3363-3369): Genuinely unprovable. When phi appears in L multiple times, the deduction approach breaks down.

The solution: Build a seed that preserves **both** G-theory and H-theory:
```
bidirectional_seed M phi := {phi} U {G(psi) | G(psi) in M} U {H(psi) | H(psi) in M} U box_theory(M)
```

This seed is consistent (subset of {phi} U M), and Lindenbaum extension preserves both G and H formulas because they're directly in the seed.

### Research Integration

From report 09:
- **Key Theorem**: `temporal_theory_witness_bidirectional` with G-preservation AND H-preservation
- **Consistency Proof**: bidirectional_seed subset {phi} U M, which is consistent when F(phi) in M
- **Critical Subtlety**: Include `H(psi)` formulas (not just `psi`) in seed to ensure H-preservation

## Goals & Non-Goals

**Goals**:
- Archive dead code (CoherentZChain, `f_preserving_seed_consistent` corner cases)
- Update ROADMAP.md with completeness gap resolution strategy
- Implement bidirectional temporal witness theorem
- Build bidirectional chain construction preserving G and H in both directions
- Achieve sorry-free temporal coherence for FMCS
- Complete integration with truth lemma

**Non-Goals**:
- Fixing `f_preserving_seed_consistent` corner cases (mathematically unprovable)
- Salvaging CoherentZChain architecture (fundamentally asymmetric)
- Bundle-level temporal coherence (wrong level of abstraction for truth lemma)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lindenbaum adds neg(H(psi)) | H | L | H(psi) directly in seed blocks this |
| Bidirectional seed too large for consistency | H | L | Seed is subset of {phi} U M, proven consistent |
| F-resolution and P-resolution need distinct witness | M | M | Single bidirectional witness handles both |
| Existing infrastructure refactoring breaks builds | M | M | Phase 0 archives rather than deletes |
| Effort underestimate | M | M | Research is thorough; approach is well-analyzed |

## Implementation Phases

### Phase 0: Archive Dead Code and Update ROADMAP [COMPLETED]

**Goal**: Clean up dead approaches and document the resolution strategy.

**Rationale**: CoherentZChain (6 unfixable sorries) and `f_preserving_seed_consistent` sub-case A (mathematically unprovable) should be archived, not left as confusing dead code. The ROADMAP needs updating with the bidirectional witness strategy.

**Tasks**:
- [ ] Add `-- ARCHIVED: fundamentally broken (asymmetric preservation)` comment block around CoherentZChain (lines ~7286-7496)
- [ ] Add `-- ARCHIVED: sub-case A unprovable (phi BEFORE psi ordering)` comment to `f_preserving_seed_consistent` (lines ~3363-3369)
- [ ] Add `-- ARCHIVED: superseded by bidirectional construction` to `omega_true_dovetailed_forward_F_resolution` (line ~7696)
- [ ] Update ROADMAP.md:
  - Mark "Class B: Genuinely Hard" section as resolved via bidirectional witness
  - Add new section "Temporal Coherence Resolution (March 2026)" documenting the findings
  - Update completeness gap description to reference bidirectional construction

**ROADMAP.md Update Content**:
```markdown
## Temporal Coherence Resolution (March 2026)

The completeness gap has been analyzed and resolved via the **bidirectional temporal witness** approach:

### Dead Ends (Archived)

1. **CoherentZChain** (UltrafilterChain.lean ~7286-7496): Fundamentally broken. Forward chain preserves G but not H; backward chain preserves H but not G. Cross-direction coherence requires preserving both, which this architecture cannot support. 6 unfixable sorries.

2. **`f_preserving_seed_consistent` sub-case A** (lines 3363-3369): Mathematically unprovable. The deduction argument produces G(phi) -> G(neg psi) in M, but G(phi) not in M means the implication is vacuously true, yielding no contradiction. The semantic reason: "eventually phi AND eventually psi" is consistent when psi holds BEFORE phi.

3. **Bundle-level temporal coherence**: Insufficient for truth lemma. G/H operators are intrinsically single-history; a witness in a different family uses a different history, invalidating the semantic argument for temporal_backward_G.

### Correct Approach: Bidirectional Temporal Witness

**Key insight**: Preserve BOTH G-theory and H-theory in witness construction.

Seed: {phi} U {G(psi) | G(psi) in M} U {H(psi) | H(psi) in M} U box_theory(M)

This seed is:
1. A subset of {phi} U M (all G(psi) and H(psi) formulas are in M)
2. Consistent when F(phi) in M (by standard temporal witness argument)
3. Extended via Lindenbaum while preserving G and H membership

The resulting MCS W satisfies:
- phi in W (witness property)
- G(psi) in M implies G(psi) in W (G-preservation)
- H(psi) in M implies H(psi) in W (H-preservation)
- box_class_agree M W (modal consistency)

A bidirectional chain using this witness preserves G in forward direction AND H in backward direction, enabling sorry-free cross-direction coherence.
```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (comments)
- `ROADMAP.md`

**Verification**:
- `lake build` still passes (comments don't affect compilation)
- ROADMAP.md has new section

---

### Phase 1: Define Bidirectional Seed [COMPLETED]

**Goal**: Define the bidirectional seed and prove membership lemmas.

**Definition**:
```lean
/--
Bidirectional temporal-modal seed: G-formulas, H-formulas, and box-formulas.
This seed preserves BOTH forward and backward temporal theories.
-/
def bidirectional_temporal_box_seed (M : Set Formula) : Set Formula :=
  {f | ∃ a, f = Formula.all_future a ∧ Formula.all_future a ∈ M} ∪
  {f | ∃ a, f = Formula.all_past a ∧ Formula.all_past a ∈ M} ∪
  box_theory M
```

**Lemmas to prove**:
```lean
theorem G_theory_subset_bidirectional_seed (M : Set Formula) :
    G_theory M ⊆ bidirectional_temporal_box_seed M

theorem H_theory_subset_bidirectional_seed (M : Set Formula) :
    H_theory M ⊆ bidirectional_temporal_box_seed M

theorem box_theory_subset_bidirectional_seed (M : Set Formula) :
    box_theory M ⊆ bidirectional_temporal_box_seed M

theorem bidirectional_seed_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    bidirectional_temporal_box_seed M ⊆ M
```

**Tasks**:
- [ ] Define `bidirectional_temporal_box_seed`
- [ ] Prove `G_theory_subset_bidirectional_seed`
- [ ] Prove `H_theory_subset_bidirectional_seed`
- [ ] Prove `box_theory_subset_bidirectional_seed`
- [ ] Prove `bidirectional_seed_subset_mcs`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- All membership lemmas compile without sorry

---

### Phase 2: Prove Bidirectional Seed Consistency [PARTIAL]

**Goal**: Prove {phi} U bidirectional_seed is consistent when F(phi) in M.

**Key Insight**: This is simpler than `f_preserving_seed_consistent` because:
- bidirectional_seed subset M (no F_unresolved_theory complications)
- {phi} U bidirectional_seed subset {phi} U M
- {phi} U M is consistent when F(phi) in M (standard temporal witness argument)

**Lemmas**:
```lean
/--
The bidirectional seed for F-witness: {phi} U bidirectional_temporal_box_seed.
Unlike f_preserving_seed, this does NOT include F_unresolved_theory.
-/
def bidirectional_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ bidirectional_temporal_box_seed M

theorem phi_in_bidirectional_seed (M : Set Formula) (phi : Formula) :
    phi ∈ bidirectional_seed M phi

theorem bidirectional_seed_subset_phi_union_M (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) :
    bidirectional_seed M phi ⊆ {phi} ∪ M

/--
If F(phi) in M (MCS), then {phi} U M is consistent, hence bidirectional_seed is consistent.
-/
theorem bidirectional_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (bidirectional_seed M phi)
```

**Proof Strategy for consistency**:
1. `bidirectional_seed M phi subset {phi} U M` (by `bidirectional_seed_subset_phi_union_M`)
2. `{phi} U M` is consistent when `F(phi) in M` (by `temporal_theory_witness_consistent`)
3. Subset of consistent set is consistent

**Tasks**:
- [ ] Define `bidirectional_seed`
- [ ] Prove `phi_in_bidirectional_seed`
- [ ] Prove `bidirectional_seed_subset_phi_union_M`
- [ ] Prove `bidirectional_seed_consistent`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- `#print axioms bidirectional_seed_consistent` shows no `sorryAx`

---

### Phase 3: Bidirectional Temporal Witness Theorem [NOT STARTED]

**Goal**: Prove the main witness theorem with both G and H preservation.

**Theorem**:
```lean
/--
Bidirectional temporal witness theorem:
If F(phi) in M (MCS), there exists MCS W with:
1. phi in W
2. G-preservation: G(a) in M -> G(a) in W
3. H-preservation: H(a) in M -> H(a) in W
4. box_class_agree M W
-/
theorem temporal_theory_witness_bidirectional (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      box_class_agree M W
```

**Proof Strategy**:
1. Apply `set_lindenbaum` to `bidirectional_seed M phi` (consistent by Phase 2)
2. Get `W` extending the seed
3. phi in W: phi in bidirectional_seed, extended to W
4. G-preservation: G(a) in M -> G(a) in G_theory M subset bidirectional_seed -> G(a) in W
5. H-preservation: H(a) in M -> H(a) in H_theory M subset bidirectional_seed -> H(a) in W
6. box_class_agree: box_theory in seed, standard argument

**Tasks**:
- [ ] Prove `temporal_theory_witness_bidirectional`
- [ ] Verify G-preservation via seed membership
- [ ] Verify H-preservation via seed membership
- [ ] Verify box_class_agree via standard argument

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- `#print axioms temporal_theory_witness_bidirectional` shows no `sorryAx`

---

### Phase 4: Symmetric P-direction Witness [NOT STARTED]

**Goal**: Prove symmetric theorem for P(phi) witnesses.

**Theorem**:
```lean
/--
Bidirectional past witness theorem:
If P(phi) in M (MCS), there exists MCS W with:
1. phi in W
2. G-preservation: G(a) in M -> G(a) in W
3. H-preservation: H(a) in M -> H(a) in W
4. box_class_agree M W
-/
theorem past_theory_witness_bidirectional (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      box_class_agree M W
```

**Proof Strategy**: Mirror Phase 3 using the existing `past_theory_witness_consistent` pattern.

**Tasks**:
- [ ] Define `bidirectional_past_seed M phi := {phi} U bidirectional_temporal_box_seed M`
- [ ] Prove `bidirectional_past_seed_consistent` (parallel to Phase 2)
- [ ] Prove `past_theory_witness_bidirectional`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- `#print axioms past_theory_witness_bidirectional` shows no `sorryAx`

---

### Phase 5: Bidirectional Omega Step [NOT STARTED]

**Goal**: Define single-step bidirectional chain construction preserving both G and H.

**Definition**:
```lean
/--
Bidirectional omega step: Given MCS M with F(phi) in M, produce witness W
preserving both G-theory and H-theory.
-/
def omega_step_bidirectional (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    { W : Set Formula // SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      box_class_agree M W }
```

**Proof**: Direct packaging of `temporal_theory_witness_bidirectional`.

**Tasks**:
- [ ] Define `omega_step_bidirectional`
- [ ] Define `omega_step_backward_bidirectional` (for P resolution)
- [ ] Prove step preserves both G and H theories

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes

---

### Phase 6: Bidirectional Omega Chain [NOT STARTED]

**Goal**: Build omega-indexed chain using bidirectional steps.

**Structure**:
```lean
/--
Bidirectional forward chain: omega-indexed MCS family with both G and H preservation.
-/
structure BidirectionalForwardChain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) where
  chain : Nat -> Set Formula
  chain_zero : chain 0 = M0
  chain_mcs : forall n, SetMaximalConsistent (chain n)
  chain_box_class : forall n m, box_class_agree (chain n) (chain m)
  /-- G-formulas propagate forward -/
  forward_G : forall n m, n <= m -> forall phi,
    Formula.all_future phi in chain n -> phi in chain m
  /-- H-formulas also propagate forward (bidirectional!) -/
  forward_H : forall n m, n <= m -> forall phi,
    Formula.all_past phi in chain n -> Formula.all_past phi in chain m
```

**Key insight**: The `forward_H` property is what CoherentZChain lacked. With bidirectional witnesses, each step preserves H-theory, so H propagates through the forward chain.

**Tasks**:
- [ ] Define `BidirectionalForwardChain`
- [ ] Define `mkBidirectionalForwardChain` using `omega_step_bidirectional`
- [ ] Prove `forward_G` (same as existing)
- [ ] Prove `forward_H` (NEW - H persists because bidirectional step preserves H-theory)
- [ ] Define `BidirectionalBackwardChain` (symmetric)
- [ ] Prove `backward_H` and `backward_G`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- `forward_G`, `forward_H`, `backward_G`, `backward_H` all sorry-free

---

### Phase 7: Bidirectional Z-Chain [NOT STARTED]

**Goal**: Combine bidirectional forward and backward chains into Int-indexed chain.

**Structure**:
```lean
/--
Bidirectional Z-chain: Int-indexed MCS family combining bidirectional forward and backward chains.
Unlike CoherentZChain, this preserves BOTH G and H in BOTH directions.
-/
def BidirectionalZChain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) : Set Formula :=
  if t >= 0 then
    (mkBidirectionalForwardChain M0 h_mcs0).chain t.toNat
  else
    (mkBidirectionalBackwardChain M0 h_mcs0).chain (-t).toNat
```

**Coherence Properties**:
```lean
theorem BidirectionalZChain_forward_G (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t <= t')
    (h_G : Formula.all_future phi in BidirectionalZChain M0 h_mcs0 t) :
    phi in BidirectionalZChain M0 h_mcs0 t'

theorem BidirectionalZChain_backward_H (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t' <= t)
    (h_H : Formula.all_past phi in BidirectionalZChain M0 h_mcs0 t) :
    phi in BidirectionalZChain M0 h_mcs0 t'
```

**Key Insight**: Cross-direction cases now work:
- `t < 0, t' >= 0` for forward_G: G propagates through backward chain (forward_G) to seed, then forward chain
- `t >= 0, t' < 0` for backward_H: H propagates through forward chain (forward_H) to seed, then backward chain

**Tasks**:
- [ ] Define `BidirectionalZChain`
- [ ] Prove `BidirectionalZChain_mcs`
- [ ] Prove `BidirectionalZChain_box_class`
- [ ] Prove `BidirectionalZChain_forward_G` (including cross-direction t<0, t'>=0)
- [ ] Prove `BidirectionalZChain_backward_H` (including cross-direction t>=0, t'<0)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- All cross-direction coherence cases sorry-free

---

### Phase 8: Bidirectional FMCS Construction [NOT STARTED]

**Goal**: Package BidirectionalZChain as a temporally coherent FMCS.

**Structure**:
```lean
/--
Bidirectional FMCS: The Z-chain packaged as FMCS with full temporal coherence.
-/
def BidirectionalZChain_to_FMCS (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : FMCS Int where
  mcs := BidirectionalZChain M0 h_mcs0
  mcs_property := BidirectionalZChain_mcs M0 h_mcs0
  box_class_agree := BidirectionalZChain_box_class M0 h_mcs0
  forward_G := BidirectionalZChain_forward_G M0 h_mcs0
  backward_H := BidirectionalZChain_backward_H M0 h_mcs0
```

**Tasks**:
- [ ] Define `BidirectionalZChain_to_FMCS`
- [ ] Prove `BidirectionalZChain_forward_F` (F resolution along the chain)
- [ ] Prove `BidirectionalZChain_backward_P` (P resolution along the chain)
- [ ] Prove `BidirectionalZChain_temporally_coherent`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- `#print axioms BidirectionalZChain_to_FMCS` shows no `sorryAx`

---

### Phase 9: Integration with Truth Lemma [NOT STARTED]

**Goal**: Wire bidirectional FMCS to the completeness theorem.

**Tasks**:
- [ ] Update `construct_bfmcs` to use `BidirectionalZChain_to_FMCS`
- [ ] Verify `parametric_canonical_truth_lemma` compatibility
- [ ] Prove `completeness_via_bidirectional`:
  ```lean
  theorem completeness_via_bidirectional (phi : Formula) :
      (forall (M : TaskFrame) (w : M.worlds) (t : M.timeline), truth_at M w t phi) ->
      [] ⊢ phi
  ```
- [ ] Update `FrameConditions/Completeness.lean` if needed

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `Theories/Bimodal/Metalogic/FrameConditions/Completeness.lean` (if needed)

**Verification**:
- `lake build` passes
- `#print axioms completeness_via_bidirectional` shows minimal axioms (no sorryAx)
- Full completeness theorem established

---

## Dependency Graph

```
[Phase 0: Archive/ROADMAP] ----+
                               |
                               v
                         [Phase 1: Seed]
                               |
                               v
                     [Phase 2: Consistency]
                               |
                               v
              +----------------+----------------+
              |                                 |
              v                                 v
   [Phase 3: F-Witness]            [Phase 4: P-Witness]
              |                                 |
              +----------------+----------------+
                               |
                               v
                    [Phase 5: Omega Step]
                               |
                               v
                    [Phase 6: Omega Chain]
                               |
                               v
                    [Phase 7: Z-Chain]
                               |
                               v
                    [Phase 8: FMCS]
                               |
                               v
                    [Phase 9: Truth Lemma]
                               |
                               v
                       [COMPLETENESS]
```

**Parallelization**: Phases 3 and 4 can run in parallel.

**Critical Path**: 0 -> 1 -> 2 -> 3 -> 5 -> 6 -> 7 -> 8 -> 9

## Testing & Validation

- [ ] `lake build` passes at each phase
- [ ] `#print axioms temporal_theory_witness_bidirectional` shows no `sorryAx`
- [ ] `#print axioms past_theory_witness_bidirectional` shows no `sorryAx`
- [ ] `#print axioms BidirectionalZChain_forward_G` shows no `sorryAx`
- [ ] `#print axioms BidirectionalZChain_backward_H` shows no `sorryAx`
- [ ] Cross-direction cases (t<0, t'>=0 and t>=0, t'<0) both sorry-free
- [ ] Final completeness theorem integrates with official semantics

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - All phases
- `ROADMAP.md` - Updated with resolution strategy (Phase 0)
- `specs/070_explore_ultrafilter_construction/summaries/05_bidirectional-completion-summary.md` - Final summary

## Rollback/Contingency

If bidirectional witness approach fails:

1. **Rollback archived code**: Remove ARCHIVED comments from CoherentZChain
2. **Investigate RestrictedTemporallyCoherentFamily**: The existing `DeferralRestrictedSerialMCS` in SuccChainFMCS.lean may provide an alternative path for specific formulas
3. **Revisit bundle-level**: For weaker completeness statements not requiring same-family witnesses

The research indicates high confidence in the bidirectional approach. The consistency proof is mathematically sound, and all ingredients exist in the codebase.
