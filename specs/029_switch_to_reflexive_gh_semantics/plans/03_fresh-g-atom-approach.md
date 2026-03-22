# Implementation Plan: Task #29 (v3 - Fresh G-Atom Approach)

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [IN PROGRESS]
- **Effort**: 8-12 hours (remaining work for Phases 5-6)
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/01_team-research.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/05_team-research.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/06_theoretical-analysis.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/07_team-research.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/08_team-research.md (CanonicalTask-centric blocker resolution)
- **Supersedes**: plans/02_reflexive-semantics-revised.md (v2)
- **Artifacts**: plans/03_fresh-g-atom-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

This is plan v3, incorporating the **CanonicalTask-centric paradigm shift** from research report 08. The key insight: the Phase 5 blocker was misframed. Proving `canonicalR_antisymmetric` universally is the wrong question (and FALSE). The correct approach is **per-witness distinctness via fresh G-atoms**: for each seriality/density witness W constructed from source M, prove `¬CanonicalR(W, M)` locally using a fresh atom mechanism.

Phases 0-4 and 7-8 are already COMPLETED from prior implementation runs. This plan focuses on completing Phases 5-6 using the fresh G-atom approach.

### Research Integration (v3 Key Finding)

From report 08_team-research.md:

| Prior Framing | Corrected Framing |
|---------------|-------------------|
| "Prove canonicalR_antisymmetric" (FALSE, impossible) | "Prove per-witness ¬CanonicalR(W, M)" (TRUE, tractable) |
| CanonicalR is the primary object | CanonicalTask is primary; CanonicalR is derived |
| Universal relation property needed | Local witness construction needed |
| Antisymmetry theorem | Strict successor/predecessor existence |

The fresh G-atom mechanism:
1. Choose atom p fresh for M (p is not in atoms(M))
2. Construct seed: g_content(M) union {G(p)}
3. Prove seed is consistent (fresh atom argument)
4. Extend to MCS W via Lindenbaum
5. CanonicalR(M, W): g_content(M) subset W (from seed)
6. G(p) in W (from seed), so p in g_content(W)
7. p is not in M (freshness), so g_content(W) is not a subset of M
8. Therefore ¬CanonicalR(W, M) — strict ordering

## Goals & Non-Goals

**Goals**:
- Complete Phase 5 using fresh G-atom approach (not universal antisymmetry)
- Prove `canonicalR_strict_successor` and `canonicalR_strict_predecessor`
- Update all ~20 remaining call sites to use fresh-atom-based strictness
- Remove `canonicalR_irreflexive_axiom`
- Complete Phase 6: prove `discreteImmediateSuccSeed_consistent_axiom` via T-axiom

**Non-Goals**:
- Proving universal `canonicalR_antisymmetric` (research confirms this is FALSE)
- Modifying already-completed phases (0-4, 7-8)
- Proving `discrete_Icc_finite_axiom` (semantics-independent)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fresh atom consistency proof complexity | H | M | Standard argument: fresh atom adds no derivable constraints; modular proof |
| DenselyOrdered witness construction | M | M | Adapt fresh atom for intermediate witness; may need two fresh atoms |
| Remaining call sites have unexpected patterns | M | L | Phase 0 enumeration already complete; patterns documented |
| NoMinOrder requires dual H-atom approach | M | L | Symmetric to G-atom; use h_content(M) union {H(p)} |

## Implementation Phases

### Phase 0: Enumeration and Pattern Catalog [COMPLETED]

**Goal**: Complete enumeration before any code changes

**Completed**: 2026-03-XX

**Tasks**:
- [x] Enumerate all ~35 `canonicalR_irreflexive` call sites with grep
- [x] Categorize each site: NoMaxOrder, NoMinOrder, DenselyOrdered, strict antisymmetry, other
- [x] For each DovetailedTimelineQuot.lean proof (~12 sites), draft replacement argument
- [x] Assess `lt_of_canonicalR` in FMCSTransfer.lean — determine redesign approach
- [x] List all 10 axioms; categorize: removed, provable via T-axiom, semantics-independent
- [x] Create enumeration report at `specs/029_switch_to_reflexive_gh_semantics/reports/07_enumeration.md`

**Timing**: 2 hours (completed)

---

### Phase 1: Core Semantic Change [COMPLETED]

**Goal**: Change temporal operator truth definition from strict to reflexive

**Completed**: 2026-03-XX

**Tasks**:
- [x] Update `Truth.lean` lines 121-122: change `s < t` to `s <= t` and `t < s` to `t <= s`
- [x] Update Truth.lean header docstring: remove "STRICT Temporal Semantics (Task #991)" label
- [x] Add `temp_t_future` axiom constructor to `ProofSystem/Axioms.lean`
- [x] Add `temp_t_past` axiom constructor to `ProofSystem/Axioms.lean`
- [x] Update Axioms.lean docstring explaining T-axioms are now valid
- [x] Classify T-axioms with `FrameClass.Base` (valid on all linear orders)
- [x] Run `lake build Bimodal.Semantics.Truth Bimodal.ProofSystem.Axioms` to verify syntax

**Timing**: 1.5 hours (completed)

---

### Phase 2: FMCS Structure Update [COMPLETED]

**Goal**: Update FMCS coherence fields for reflexive semantics

**Completed**: 2026-03-XX

**Tasks**:
- [x] Update `FMCSDef.lean` line 119: change `t < t'` to `t <= t'` in `forward_G`
- [x] Update `FMCSDef.lean` line 127: change `t' < t` to `t' <= t` in `backward_H`
- [x] Update FMCSDef.lean docstrings: remove "irreflexive semantics" references
- [x] Update `TemporalCoherence.lean` signatures if needed
- [x] Run `lake build Bimodal.Metalogic.Bundle.FMCSDef` to verify

**Timing**: 1 hour (completed)

---

### Phase 3: Soundness Proof Repairs [COMPLETED]

**Goal**: Fix all soundness proofs for reflexive temporal semantics

**Completed**: 2026-03-XX

**Tasks**:
- [x] Add `temp_t_valid_future` proof using `le_refl`
- [x] Add `temp_t_valid_past` proof using `le_refl`
- [x] Fix `temp_4_valid`: change `lt_trans` to `le_trans`
- [x] Fix `temp_a_valid`: add `s = t` case using `le_refl`
- [x] Fix `temp_l_valid`: handle reflexive case in trichotomy
- [x] Simplify `density_valid`: `s = t` case trivially satisfied
- [x] Simplify `seriality_future_valid` / `seriality_past_valid`: trivially true via T-axiom
- [x] Simplify `discreteness_forward_valid`: adjust for reflexive H semantics
- [x] Update `axiom_base_valid` to include T-axiom cases
- [x] Run `lake build Bimodal.Metalogic.Soundness` to verify

**Timing**: 2 hours (completed)

---

### Phase 4: Truth Lemma Adjustment [COMPLETED]

**Goal**: Update truth lemma for reflexive G/H semantics

**Completed**: 2026-03-XX

**Tasks**:
- [x] Update `ParametricTruthLemma.lean` `all_future` forward case
- [x] Handle `s = t` case in G forward: use T-axiom membership
- [x] Update `all_past` forward case similarly
- [x] Verify backward cases (`temporal_backward_G/H`): unchanged (strict F/P witnesses)
- [x] Check `DenseInstantiation.lean` for any strict-`<` logic
- [x] Run `lake build Bimodal.Metalogic.Algebraic.ParametricTruthLemma` to verify

**Timing**: 1.5 hours (completed)

---

### Phase 5: Fresh G-Atom Strictness Proofs [NOT STARTED]

**Goal**: Replace universal antisymmetry with per-witness fresh G-atom strictness

This phase implements the CanonicalTask-centric approach from report 08. Instead of proving the FALSE `canonicalR_antisymmetric`, we prove that each constructed witness W has `¬CanonicalR(W, M)` via a fresh atom that persists through g_content.

#### Step 5.1: Fresh Atom Infrastructure (2-3h)

**Tasks**:
- [ ] Define `atoms : Formula → Finset Atom` (recursive enumeration of propositional atoms)
- [ ] Define `fresh_for : Atom → MCS → Prop` as `p ∉ atoms(⋃ φ ∈ M, atoms(φ))`
- [ ] Prove `fresh_atom_exists`: for any MCS M, there exists an atom p fresh for M
- [ ] Prove `fresh_atom_Gp_seed_consistent`: `g_content(M) ∪ {G(p)}` is consistent for fresh p
  - Key argument: fresh p is not mentioned in any formula in g_content(M)
  - G(p) adds no constraints derivable from g_content(M)
  - Use finite inconsistency lemma
- [ ] Prove `fresh_atom_Hp_seed_consistent`: `h_content(M) ∪ {H(p)}` is consistent for fresh p
  - Symmetric to G-atom case

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Canonical/FreshAtom.lean` (new file)

**Verification**:
- `lake build Bimodal.Metalogic.Canonical.FreshAtom` succeeds

#### Step 5.2: Strict Witness Theorems (1-2h)

**Tasks**:
- [ ] Prove `canonicalR_strict_successor`:
  ```lean
  theorem canonicalR_strict_successor (M : MCS) :
    ∃ W : MCS, CanonicalR M W ∧ ¬CanonicalR W M
  ```
  - Choose p fresh for M
  - Extend `g_content(M) ∪ {G(p)}` to MCS W
  - G(p) ∈ W implies p ∈ g_content(W)
  - p ∉ M (freshness) implies g_content(W) ⊄ M
- [ ] Prove `canonicalR_strict_predecessor`:
  ```lean
  theorem canonicalR_strict_predecessor (M : MCS) :
    ∃ W : MCS, CanonicalR W M ∧ ¬CanonicalR M W
  ```
  - Symmetric using H(p) and h_content
- [ ] Prove `canonicalR_reflexive`: `CanonicalR M M` (trivial from T-axiom)
- [ ] Add wrapper `canonicalR_strict_of_successor`: given W from strict_successor, `¬CanonicalR W M`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Add new theorems

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` succeeds

#### Step 5.3: Update CantorApplication.lean (3-4h)

**Tasks**:
- [ ] Replace `NoMaxOrder` proof:
  - Old: used `canonicalR_irreflexive` for contradiction
  - New: use `canonicalR_strict_successor` to get W with `CanonicalR M W ∧ ¬CanonicalR W M`
  - The strict witness provides the required `<` via antisymmetry wrapper
- [ ] Replace `NoMinOrder` proof:
  - Use `canonicalR_strict_predecessor` symmetrically
- [ ] Replace `DenselyOrdered` proof:
  - Given M < N (i.e., CanonicalR M N ∧ M ≠ N)
  - Construct intermediate W using fresh atom between M and N
  - May need: `g_content(M) ∪ {G(p)} ⊆ seed`, seed consistent, extend to W
  - Prove M < W < N

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.CantorApplication` succeeds

#### Step 5.4: Update Remaining Call Sites (3-4h)

**Tasks**:
- [ ] Fix `FMCSTransfer.lean`:
  - `lt_of_canonicalR` needs redesign: require `a ≠ b` hypothesis
  - OR handle `a = b` case separately in callers
- [ ] Fix `DovetailedTimelineQuot.lean` (~12 sites):
  - Pattern: replace `canonicalR_irreflexive M hM h_R` with fresh-atom-based contradiction
  - For `inl` (MCS equality) cases: use per-construction distinctness
- [ ] Fix `SaturatedChain.lean` (~6 sites):
  - Use `canonicalR_strict_successor/predecessor` where applicable
- [ ] Fix remaining files:
  - `ClosureSaturation.lean` (2 sites)
  - `IncrementalTimeline.lean` (1 site)
  - `TimelineQuotCanonical.lean` (1 site)
  - `DiscreteTimeline.lean` (2 sites)
  - `CanonicalSerialFrameInstance.lean` (2 sites)
- [ ] Run `lake build` to find and fix any remaining breakages

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`

**Verification**:
- `grep -r "canonicalR_irreflexive" Theories/` returns no results (except comments)
- `lake build` succeeds

#### Step 5.5: Remove Axiom (30min)

**Tasks**:
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from CanonicalIrreflexivity.lean
- [ ] Update `CanonicalIrreflexivityAxiom.lean` wrapper to export new theorems
- [ ] Verify `lake build` passes
- [ ] Grep to confirm no remaining references

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

**Verification**:
- `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no results
- `lake build` succeeds

**Timing**: 8-12 hours total for Phase 5

---

### Phase 6: T-Axiom Simplification for discreteImmediateSuccSeed [NOT STARTED]

**Goal**: Prove `discreteImmediateSuccSeed_consistent_axiom` using T-axiom

This phase is independent of Phase 5 and can be attempted in parallel.

**Tasks**:
- [ ] Analyze Case 2 in `discreteImmediateSuccSeed_consistent`:
  - Under reflexive semantics: `g_content(M) ⊆ M` holds (T-axiom)
  - Blocking formula `¬ψ ∨ ¬G(ψ)` is derivable from `¬G(ψ) ∈ M`
  - Show seed consistency using MCS closure properties
- [ ] Remove `axiom discreteImmediateSuccSeed_consistent_axiom` from DiscreteSuccSeed.lean
- [ ] Complete the proof in `discreteImmediateSuccSeed_consistent`
- [ ] Assess `discreteImmediateSucc_covers_axiom`: attempt proof via T-axiom
- [ ] Assess `successor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Assess `predecessor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Document remaining axioms as semantics-independent in code comments
- [ ] Run `lake build Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed` to verify

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (assessment/documentation)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (documentation)

**Verification**:
- `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results
- `discreteImmediateSuccSeed_consistent` is a proven theorem
- All assessed axioms documented with reflexive semantics status

---

### Phase 7: Frame Class Documentation [COMPLETED]

**Goal**: Update frame class documentation for reflexive semantics collapse

**Completed**: 2026-03-XX

**Tasks**:
- [x] Update `FrameClass` enum documentation to note all axioms are now Base
- [x] Update `isDenseCompatible` predicate documentation
- [x] Update `isDiscreteCompatible` predicate documentation
- [x] Update `LogicVariants.lean`: note three-variant structure is now degenerate
- [x] Add comments noting DN/DF/SF/SP trivially valid under reflexive semantics
- [x] Run `lake build` on affected files

**Timing**: 1.5 hours (completed)

---

### Phase 8: Documentation and Final Verification [COMPLETED]

**Goal**: Update documentation, resolve conflicts, verify full build

**Completed**: 2026-03-XX

**Tasks**:
- [x] Update ROAD_MAP.md: confirm reflexive semantics is current
- [x] Update Truth.lean header docstring to describe reflexive semantics
- [x] Update CanonicalIrreflexivity.lean docstring to describe antisymmetry approach
- [x] Run full `lake build` to verify no regressions
- [x] Grep for remaining `axiom` declarations
- [x] Create implementation summary

**Timing**: 1 hour (completed)

---

## Testing & Validation

- [ ] Full `lake build` passes after each Phase 5 step
- [ ] Phase 5.5: `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no results
- [ ] Phase 6: `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results
- [ ] `canonicalR_strict_successor` and `canonicalR_strict_predecessor` are proven theorems
- [ ] `canonicalR_reflexive` is a proven theorem
- [ ] No new `sorry` introduced (verify via `grep -r "sorry" Theories/`)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Canonical/FreshAtom.lean` (new file)
- Updated `CanonicalIrreflexivity.lean` with fresh-atom theorems
- Updated `CantorApplication.lean` with fresh-atom proofs
- Updated all downstream files using fresh-atom pattern
- Proven `discreteImmediateSuccSeed_consistent` theorem
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/01_reflexive-semantics-summary.md`

## Rollback/Contingency

If fresh G-atom approach encounters unexpected complexity:

1. **Fresh atom consistency proof fails**: The mathematical argument is standard; if Lean formalization is difficult, consider:
   - Using existing Gabbay infrastructure (1170 lines) for naming set arguments
   - Axiomatizing the fresh atom consistency lemma temporarily

2. **DenselyOrdered intermediate witness is complex**: May need two fresh atoms (one for M-W relation, one for W-N relation); budget additional 1-2 hours

3. **Git revert fallback**: If Phase 5 exceeds 15 hours total, revert and consider:
   - Keeping `canonicalR_irreflexive_axiom` as permanent axiom
   - Documenting the reflexivity exception in comments

The core semantic change (Phases 1-4) is stable and completed. Phase 5 failures would not affect the already-working reflexive semantics foundation.
