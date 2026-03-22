# Implementation Plan: Task #29 (v5 - IRR Removal Approach)

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours total
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/20_team-research.md (IRR removal analysis)
  - specs/029_switch_to_reflexive_gh_semantics/reports/20_teammate-a-findings.md (proof system impact)
  - specs/029_switch_to_reflexive_gh_semantics/reports/20_teammate-b-findings.md (codebase archaeology)
  - specs/029_switch_to_reflexive_gh_semantics/reports/20_teammate-c-findings.md (theoretical foundations)
- **Supersedes**: plans/04_substitution-lemma-approach.md (v4)
- **Artifacts**: plans/05_irr-removal-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

**Plan v5 corrects the fundamental misdirection of plan v4.** The v4 plan tried to build substitution infrastructure to *accommodate* the IRR case in `derivation_subst`. But IRR (Gabbay Irreflexivity Rule) is **unsound under reflexive semantics** and must be **removed from the proof system entirely**.

**Core insight from report 20**: The antecedent `p ∧ H(¬p)` of the IRR rule is unsatisfiable when H uses ≤ (reflexive). H(¬p) at t requires ¬p at all s ≤ t, including t itself, contradicting p at t. This makes IRR vacuously license deriving ⊥.

**Current system state**: INCONSISTENT. Both `canonicalR_reflexive` (proven theorem) and `canonicalR_irreflexive_axiom` (axiom) coexist, asserting `CanonicalR M M` and `¬CanonicalR M M` simultaneously.

### What This Plan Does

1. **Remove IRR from DerivationTree** — eliminates 5 sorries, restores soundness
2. **Delete IRR-specific files** — IRRSoundness.lean, CanonicalIrreflexivityAxiom.lean, DirectIrreflexivity.lean
3. **Complete per-witness strictness proofs** — replace universal irreflexivity with fresh G-atom construction
4. **Refactor call sites** — update ~28 code sites that use `canonicalR_irreflexive`
5. **Delete the deprecated axiom** — restore consistency
6. **Update documentation** — align comments with reflexive semantics

### What Changed from Plan v4

| v4 Approach | v5 Approach |
|-------------|-------------|
| Build substitution lemma to handle IRR case | Remove IRR entirely; IRR case disappears |
| Prove derivation_subst with IRR | Remove IRR constructor from DerivationTree |
| Keep IRRSoundness.lean (has sorry) | Delete IRRSoundness.lean |
| Work around the sorry in derivation_subst | Sorry eliminated when IRR match arm removed |

### Preserved Work

Phases 0-4 and 7-8 from earlier plans are COMPLETED and remain valid:
- Phase 1: Core semantic change (Truth.lean `<=` instead of `<`) ✓
- Phase 2: FMCS structure update ✓
- Phase 3: Soundness proof repairs ✓
- Phase 4: Truth lemma adjustment ✓
- Phase 7-8: Documentation ✓

The `Substitution.lean` file created in v4 partial implementation is **simplified** (remove IRR case) but the non-IRR infrastructure is retained.

## Goals & Non-Goals

**Goals**:
- Remove IRR constructor from `DerivationTree` and `ExtDerivationTree`
- Delete 3 obsolete files (IRRSoundness.lean, CanonicalIrreflexivityAxiom.lean, DirectIrreflexivity.lean)
- Eliminate 5 sorries caused by IRR unsoundness
- Complete per-witness strictness proofs (`exists_strict_fresh_atom`, `fresh_Gp_seed_consistent`)
- Prove `canonicalR_strict_successor` and `canonicalR_strict_predecessor`
- Replace ~28 `canonicalR_irreflexive` call sites with per-witness strictness
- Delete `canonicalR_irreflexive_axiom` to restore consistency
- Update ~20 files with outdated irreflexive-semantics comments

**Non-Goals**:
- Proving universal `canonicalR_antisymmetric` (still FALSE under reflexive semantics)
- Modifying Boneyard files (already archived)
- Task 25 work (deferred until this task completes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| IRR removal cascade | M | L | Compilation errors guide us to all sites; mechanical fix |
| Per-witness strictness proof complexity | M | M | Fresh G-atom approach already sketched in CanonicalIrreflexivity.lean:1226-1259 |
| Call site refactoring variety | M | M | Most follow same pattern; analyze each individually |
| Conservative extension module depth | M | L | Lifting.lean has ~12 IRR sites but all are pattern match arms |

## Implementation Phases

### Phase 1: Remove IRR from Proof System [COMPLETED]

**Goal**: Delete the IRR constructor and all pattern match arms. This is mechanical and eliminates 5 sorries.

**Effort**: 2-3 hours

**Tasks**:
- [ ] Remove `irr` constructor from `DerivationTree` in `Derivation.lean:149-154`
- [ ] Remove `.irr` arm from `height` function (line 200)
- [ ] Remove `.irr` arm from `isDenseCompatible` (line 291)
- [ ] Remove `.irr` arm from `isDiscreteCompatible` (line 308)
- [ ] Remove IRR case from `derivation_subst` in `Substitution.lean:366-386`
- [ ] Remove `.irr` cases from `Soundness.lean` (lines 604-606, 671-688, 796-801)
- [ ] Remove `.irr` case from `SoundnessLemmas.lean` (lines 961-963)
- [ ] Remove `.irr` arm from `DeductionTheorem.lean` (lines 259-262)
- [ ] Remove `.irr` arms from `MaximalConsistent.lean` (lines 150, 186-190)
- [ ] Remove IRR import from `Soundness.lean` (line 4)
- [ ] Run `lake build` — fix any remaining pattern match errors
- [ ] Verify sorry count decreased by at least 4

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Derivation.lean`
- `Theories/Bimodal/ProofSystem/Substitution.lean`
- `Theories/Bimodal/Metalogic/Soundness.lean`
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean`
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`

**Verification**:
- `lake build` passes
- `grep -r "\.irr" Theories/Bimodal/ProofSystem/` returns no code matches (only comments)
- Sorry count in Soundness.lean reduced

---

### Phase 2: Remove IRR from Conservative Extension [COMPLETED]

**Goal**: Remove IRR from the extended proof system used for conservative extension proofs.

**Effort**: 1-2 hours

**Tasks**:
- [ ] Remove `irr` constructor from `ExtDerivationTree` in `ExtDerivation.lean:100-105`
- [ ] Remove IRR embedding (lines 175-176)
- [ ] Remove IRR cases from `Lifting.lean` (~12 locations):
  - Lines 141-147 (`substDerivation` IRR cases)
  - Lines 341-382 (`collectDerivInl` IRR case + `collectDerivInl_sub_irr` lemma)
  - Lines 397-502 (IRR freshness preservation section)
  - Lines 563-580 (`unembedDerivation` IRR cases)
- [ ] Remove IRR embedding lemma from `ExtFormula.lean` (line 306)
- [ ] Run `lake build` — fix any remaining errors

**Files to modify**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean`
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean`
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean`

**Verification**:
- `lake build` passes
- `grep -r "\.irr" Theories/Bimodal/Metalogic/ConservativeExtension/` returns no code matches

---

### Phase 3: Delete Obsolete Files [PARTIAL]

**Goal**: Remove files that exist solely to support IRR.

**Effort**: 30 minutes

**Tasks**:
- [ ] Delete `Theories/Bimodal/Metalogic/IRRSoundness.lean`
- [ ] Delete `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`
- [ ] Delete `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean`
- [ ] Remove imports of deleted files from any dependent modules
- [ ] Update `Metalogic.lean` imports if needed
- [ ] Run `lake build`

**Files to delete**:
- `Theories/Bimodal/Metalogic/IRRSoundness.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean`

**Verification**:
- `lake build` passes
- Files no longer exist
- No dangling imports

---

### Phase 4: Complete Per-Witness Strictness [NOT STARTED]

**Goal**: Prove the fresh G-atom theorems that replace universal irreflexivity.

**Effort**: 3-4 hours

This phase completes the partially-implemented work in `CanonicalIrreflexivity.lean:1226-1259`.

**Tasks**:
- [ ] Prove `exists_strict_fresh_atom`:
  ```lean
  theorem exists_strict_fresh_atom (M : MCS) :
      ∃ q : Atom, ¬(Atom.toFormula q) ∈ M ∧ G (¬(Atom.toFormula q)) ∉ M
  ```
  - Use countability/cardinality argument: MCS is countable, atoms are countably infinite
  - Or use substitution lemma approach if simpler
- [ ] Prove `fresh_Gp_seed_consistent`:
  ```lean
  theorem fresh_Gp_seed_consistent (M : MCS) (p : Atom) (h_fresh : fresh_for p M.formulas) :
      Consistent (g_content M ∪ {G (Atom.toFormula p)})
  ```
  - Case 1: If G(p) ∉ L, then L ⊆ g_content(M) ⊆ M (T-axiom)
  - Case 2: If G(p) ∈ L, use freshness + derivability argument
- [ ] Prove `fresh_Hp_seed_consistent` (symmetric for H-content)
- [ ] Prove `canonicalR_strict_successor`:
  ```lean
  theorem canonicalR_strict_successor (M : MCS) :
      ∃ W : MCS, CanonicalR M W ∧ ¬CanonicalR W M
  ```
  - Extend g_content(M) ∪ {G(q)} to MCS W
  - Forward: g_content(M) ⊆ W implies CanonicalR M W
  - Backward: G(q) ∈ W implies q ∈ g_content(W), but q ∉ M, so ¬CanonicalR W M
- [ ] Prove `canonicalR_strict_predecessor` (symmetric using H)
- [ ] Run `lake build` — verify all sorries in this section closed

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- Possibly `Theories/Bimodal/Metalogic/Canonical/FreshAtom.lean` (if creating new file)

**Verification**:
- `lake build` passes
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` returns no matches in the fresh atom section
- `canonicalR_strict_successor` and `canonicalR_strict_predecessor` are proven theorems

---

### Phase 5: Refactor Call Sites [NOT STARTED]

**Goal**: Replace all uses of `canonicalR_irreflexive` with per-witness strictness arguments.

**Effort**: 4-6 hours

This is the bulk refactoring phase. Each call site needs individual analysis.

**Pattern**: Most sites use the pattern:
```lean
-- Old (universal irreflexivity):
have h : ¬CanonicalR M M := canonicalR_irreflexive M hM
-- Use h to derive contradiction from CanonicalR M M

-- New (per-witness strictness):
-- Use the specific construction's witness to show non-equality
-- Or use the constructed W from canonicalR_strict_successor
```

**Tasks by file**:

**StagedConstruction (~18 call sites)**:
- [ ] `DovetailedTimelineQuot.lean` (~12 calls) — quotient order strictness
- [ ] `CantorApplication.lean` (~3 calls) — NoMaxOrder, NoMinOrder, DenselyOrdered
- [ ] `ClosureSaturation.lean` (~2 calls) — saturation step strictness
- [ ] `TimelineQuotCanonical.lean` (~1 call) — quotient canonical
- [ ] `IncrementalTimeline.lean` (~1 call) — timeline construction

**Algebraic (~8 call sites)**:
- [ ] `SaturatedChain.lean` (~8 calls) — chain construction strictness

**Bundle (~4 call sites)**:
- [ ] `FMCSTransfer.lean` (~2 calls) — transfer lemma strictness
- [ ] `CanonicalIrreflexivity.lean` — remove deprecated axiom after call sites fixed

**Canonical (~2 call sites)**:
- [ ] `CanonicalSerialFrameInstance.lean` (~2 calls) — serial frame strictness

**Domain (~2 call sites)**:
- [ ] `DiscreteTimeline.lean` (~2 calls) — discrete successor strictness

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean`
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification**:
- `lake build` passes
- `grep -r "canonicalR_irreflexive" Theories/` returns only the deprecated axiom declaration (soon to be deleted)

---

### Phase 6: Delete Axiom and Restore Consistency [NOT STARTED]

**Goal**: Remove the deprecated axiom that introduces inconsistency.

**Effort**: 30 minutes

**Tasks**:
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from `CanonicalIrreflexivity.lean:1492-1498`
- [ ] Remove any re-exports or wrappers
- [ ] Run `lake build` — should pass (all call sites refactored in Phase 5)
- [ ] Verify `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no matches
- [ ] Consider renaming `CanonicalIrreflexivity.lean` to `CanonicalStrictness.lean` or similar

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- No references to `canonicalR_irreflexive_axiom` remain
- System is now CONSISTENT (only `canonicalR_reflexive` exists)

---

### Phase 7: Update Documentation [NOT STARTED]

**Goal**: Align comments and documentation with reflexive semantics.

**Effort**: 1-2 hours

**Tasks**:
- [ ] Update comments in `Syntax/Atom.lean` (IRR references)
- [ ] Update comments in `Syntax/Formula.lean` (IRR references)
- [ ] Update comments in `ProofSystem/Axioms.lean` (irreflexive semantics refs)
- [ ] Update comments in `Metalogic/Bundle/*.lean` (WitnessSeed, Construction, TemporalCoherence)
- [ ] Update comments in `Metalogic/StagedConstruction/*.lean` (multiple files)
- [ ] Update comments in `Metalogic/Representation.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean`
- [ ] Update `Semantics/Truth.lean` (lines 13, 17)
- [ ] Update `typst/chapters/06-notes.typ` (IRR discussion)
- [ ] Update `latex/subfiles/04-Metalogic.tex` (footnote about G/H)
- [ ] Update any README.md files in Metalogic subdirectories

**Files to modify** (~20 files):
- See report 20_teammate-b-findings.md for complete list

**Verification**:
- `grep -ri "irreflexive" Theories/` returns only:
  - Mathematical uses (e.g., `<` is irreflexive on naturals)
  - Boneyard files
  - Historical comments clearly marked as such

---

### Phase 8: DiscreteSuccSeed T-Axiom Proof [NOT STARTED]

**Goal**: Prove `discreteImmediateSuccSeed_consistent_axiom` using T-axiom (independent of IRR removal).

**Effort**: 2-3 hours

This phase is carried forward from plan v4 Phase 6.

**Tasks**:
- [ ] Analyze Case 2 in `discreteImmediateSuccSeed_consistent`:
  - Under reflexive semantics: `g_content(M) ⊆ M` holds (T-axiom)
  - Blocking formula `¬ψ ∨ ¬G(ψ)` is derivable from `¬G(ψ) ∈ M`
  - Show seed consistency using MCS closure properties
- [ ] Complete the proof in `discreteImmediateSuccSeed_consistent`
- [ ] Remove `axiom discreteImmediateSuccSeed_consistent_axiom`
- [ ] Assess `discreteImmediateSucc_covers_axiom`: attempt proof via T-axiom
- [ ] Assess `successor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Assess `predecessor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Document remaining axioms as semantics-independent

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (assessment/documentation)

**Verification**:
- `lake build` passes
- `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results (if successfully proven)
- Remaining axioms documented with clear justification

---

## Testing & Validation

- [ ] Full `lake build` passes after each phase
- [ ] Phase 1: `grep -r "DerivationTree.irr" Theories/` returns no code matches
- [ ] Phase 3: All 3 obsolete files deleted
- [ ] Phase 4: `canonicalR_strict_successor` is a proven theorem (no sorry)
- [ ] Phase 5: `grep -r "canonicalR_irreflexive[^_]" Theories/` returns no code matches
- [ ] Phase 6: `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no matches
- [ ] Final: `grep -r "sorry" Theories/Bimodal/` count reduced by at least 5 from baseline
- [ ] Final: Axiom count reduced by 1 (canonicalR_irreflexive_axiom removed)

## Artifacts & Outputs

- Updated `Theories/Bimodal/ProofSystem/Derivation.lean` (IRR-free)
- Updated `Theories/Bimodal/ProofSystem/Substitution.lean` (IRR case removed)
- Updated soundness modules (3 sorries eliminated)
- Deleted `IRRSoundness.lean`, `CanonicalIrreflexivityAxiom.lean`, `DirectIrreflexivity.lean`
- Proven `canonicalR_strict_successor` and `canonicalR_strict_predecessor`
- Refactored ~28 call sites
- Deleted `canonicalR_irreflexive_axiom`
- Updated ~20 files with reflexive-semantics documentation
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/05_irr-removal-summary.md`

## Cross-Task Dependencies

**Task 25 Dependency**:
- Task 25 (Rename CanonicalR to ExistsTask) Phases 1-2 overlap with this task's Phase 4-5
- Task 25 should wait for Task 29 completion
- After Task 29: Task 25 can proceed with Phases 3-4 (retire Gabbay reference, rename)

## Rollback/Contingency

If Phase 4 (per-witness strictness) proves unexpectedly difficult:

1. **Phase 1-3 are safe**: IRR removal is correct regardless of Phase 4 outcome
2. **Temporary fallback**: Keep `canonicalR_irreflexive_axiom` while working on strictness proofs
3. **Alternative approach**: If fresh G-atom fails, investigate cardinality-based proof
4. **Git revert**: All changes are incremental and can be reverted by phase

The core direction (removing IRR) is mathematically sound. Only the implementation details of Phase 4 have residual risk.
