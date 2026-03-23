# Research Report: Task #44

**Task**: Prove backward sorry and make irreflexivity derivable
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)

## Summary

Both teammates independently conclude that Task 44 as originally scoped is **semantically impossible** under the current reflexive semantics framework. The backward sorry is in the Boneyard (superseded code), the theorem is likely false in the canonical model, and Phase 7 (irreflexivity derivation) contradicts the proven `existsTask_reflexive` theorem. The task should be reframed as axiom deletion.

## Key Findings

### Primary Approach Analysis (Teammate A)

1. **Sorry location**: `Boneyard/Metalogic/StagedConstruction/CanonicalRecovery.lean:159` — in archived/superseded code, NOT on the publication path. Task 43 is archiving StagedConstruction to Boneyard.

2. **The backward sorry is likely unprovable**: `ExistsTask M N → ∃ n ≥ 1, CanonicalTask_forward M n N` requires constructing a Succ-chain reaching N *specifically*. But:
   - `ExistsTask M N` only says `g_content M ⊆ N`
   - The successor deferral seed construction produces SOME successor, not N specifically
   - Two distinct MCS can both extend `g_content(M)` without being Succ-chain-connected
   - There's no mechanism to "target" a specific MCS in the chain construction

3. **Phase 7 is impossible under reflexive semantics**: Task 29 introduced reflexive semantics where `ExistsTask M M` is provably TRUE (via T-axiom). The `existsTask_irreflexive_axiom` directly contradicts this — deriving irreflexivity from `canonicalTask_irreflexive` creates a logical impossibility.

4. **The forward direction is fully proven**: `canonicalTask_forward_pos_implies_canonicalR` proves `CanonicalTask M n M' → ExistsTask M M'` (for n ≥ 1) without axioms. Only the backward direction is problematic.

### Alternative Approaches (Teammate B)

1. **Active architecture doesn't need backward direction**: Both the all-MCS domain approach (`CanonicalFMCS.lean`) and the Succ-chain approach (`SuccChainFMCS.lean`) never require `ExistsTask → CanonicalTask` recovery. The publication path has zero sorries on this equivalence.

2. **Per-construction strictness already exists**: `strict_of_formula_in_g_content_not_in_source` provides local strictness proofs without universal irreflexivity — identify a distinguishing formula at each witness construction site.

3. **Phase 7 was already partially done**: `canonicalTask_irreflexive` was derived in Task 26 Phase 1 from the existing axiom. Making it axiom-free is the impossible part.

4. **Weaker form is trivially provable**: `ExistsTask M N → ∃ W, Succ M W` (some successor exists, not necessarily N) follows almost immediately from `successor_exists` given seriality.

5. **Key prior art from Task 26 research**: "The irreflexivity reformulation does NOT require the backward sorry. Using the forward direction alone: ¬CanonicalR M M → (∀ n > 0, CanonicalTask M n M → CanonicalR M M) → ∀ n > 0, ¬CanonicalTask M n M."

## Synthesis

### Conflicts Resolved

None — both teammates independently reached the same conclusions with high confidence. Their analyses are complementary: Teammate A focused on why the proof fails mathematically, Teammate B mapped the codebase architecture showing the proof isn't needed.

### Gaps Identified

1. **Layer 2 dependents audit**: Which files use `existsTask_irreflexive_axiom` beyond the deprecated theorems in CanonicalIrreflexivity.lean? Teammate B lists CantorApplication.lean, DovetailedTimelineQuot.lean, and DiscreteTimeline.lean but a full grep would confirm.

2. **Axiom count impact**: Deleting `existsTask_irreflexive_axiom` reduces the axiom count by 1 (from 9 remaining). The relationship to Task 42 (eliminate ALL axioms) should be considered.

### Recommendations

**Primary recommendation**: Reframe Task 44 as "Delete existsTask_irreflexive_axiom and Layer 2 dependents"

This would:
1. Delete `existsTask_irreflexive_axiom` from `CanonicalIrreflexivity.lean`
2. Delete all `@[deprecated]` theorems using it (`existsTask_irreflexive`, `canonicalTask_irreflexive_pos/neg/general`)
3. Move or delete Layer 2 dependents (CantorApplication.lean, DovetailedTimelineQuot.lean, DiscreteTimeline.lean) to Boneyard
4. Keep `strict_of_formula_in_g_content_not_in_source` for per-construction strictness
5. Reduce axiom count and resolve documented inconsistency

**Alternative**: If the task should be closed without code changes, document it as "semantically impossible under reflexive semantics" and mark as abandoned. The backward sorry in the Boneyard will be archived by Task 43.

**What NOT to do**: Do not attempt to prove the backward sorry or derive universal irreflexivity — both are mathematically impossible under the current semantic framework.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach analysis | completed | high |
| B | Alternative approaches and prior art | completed | high |

## References

- `Boneyard/Metalogic/StagedConstruction/CanonicalRecovery.lean:159` — the backward sorry
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` — two-layer architecture, inconsistent axiom
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` — ExistsTask definition
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — successor deferral seed construction
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — bounded_witness theorem
- `specs/026_remove_canonicalr_irreflexive_axiom/reports/18_team-research.md` — Task 26 Wave 6 synthesis on irreflexivity reformulation
