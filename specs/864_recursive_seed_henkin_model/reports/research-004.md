# Research Report: Task #864 - Path to Sorry-Free Proof

**Task**: 864 - Recursive seed construction for Henkin model completeness
**Date**: 2026-02-11
**Focus**: Analyzing the 4 remaining sorries and proposing concrete solutions
**Started**: 2026-02-11T12:00:00Z
**Completed**: 2026-02-11T13:30:00Z
**Effort**: 1.5 hours
**Dependencies**: research-002.md, research-003.md, implementation-002.md
**Sources/Inputs**:
  - Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean (current state)
  - specs/864_recursive_seed_henkin_model/plans/implementation-002.md
  - specs/864_recursive_seed_henkin_model/reports/research-003.md (meta-evaluation)
**Artifacts**: specs/864_recursive_seed_henkin_model/reports/research-004.md (this file)
**Standards**: proof-debt-policy.md, report-format.md

## Project Context

- **Upstream Dependencies**: `set_lindenbaum`, `SetConsistent`, `ProofSystem.DerivationTree`, `Formula.complexity`
- **Downstream Dependents**: `seedConsistent`, `buildSeedBMCS`, completeness theorems
- **Alternative Paths**: None identified - seed construction is the correct approach
- **Potential Extensions**: Task 865 canonical task frame construction

## Executive Summary

After 23 implementation sessions, 4 sorries remain in RecursiveSeed.lean. Through careful analysis of the proof structure and recursion pattern, this report identifies:

1. **Root Cause**: The sorries arise from a missing invariant - the single-path property that prevents conflicting formulas from coexisting in the seed
2. **Solution**: Prove that buildSeedAux follows a single path through the formula tree, ensuring all seed entries are mutually compatible
3. **Key Insight**: Families are only created by neg-Box processing, but Box psi processing (which calls addToAllFamilies) only occurs on the positive branch - these paths are mutually exclusive
4. **Concrete Fix**: Strengthen the induction hypothesis to track that famIdx is always on the "positive path" where no new families have been created

Estimated effort to resolve all 4 sorries: 3-5 sessions with the refined approach.

## Analysis of the 4 Remaining Sorries

### Sorry 1: Line 3138 - Box Case h_same_fam = false

**Context**: When processing Box psi, we add psi to ALL families at timeIdx via `addToAllFamilies`. For entries at (famIdx, timeIdx) we prove psi derivable from Box psi. But for entries at (otherFamIdx, timeIdx) where otherFamIdx != famIdx, we lack a proof.

**Current code structure**:
```lean
by_cases h_same_fam : entry.familyIdx = famIdx
· -- Entry is at (famIdx, timeIdx): has Box psi, so psi is derivable via T-axiom
  ... -- PROVEN
· -- Entry is at a different family: this case requires the single-path invariant
  sorry
```

**Why it is blocked**: The proof attempts to show that adding psi preserves consistency for entries at OTHER families. But `addToAllFamilies` iterates over ALL family indices in seed1, not just famIdx.

**Key observation**: When we reach the Box case during buildSeedAux, are there ANY other families in the seed?

Analysis of the recursion:
1. buildSeedAux starts with initial seed containing only family 0
2. New families are ONLY created by `createNewFamily` in the neg-Box case
3. The neg-Box case recurses on `(neg psi)` at the NEW family, not the original family
4. The Box case NEVER creates new families - it adds to existing ones

**Conclusion**: When buildSeedAux(Box psi, famIdx, timeIdx, seed) is called, and we follow the positive Box branch recursively, NO NEW FAMILIES have been created by this branch. The only way other families exist is if:
1. They were in the initial seed (but initial seed only has family 0)
2. They were created by a PREVIOUS recursive call on a different branch

But buildSeedAux is called ONCE on the initial formula and recurses. The recursion follows a SINGLE PATH through the formula tree.

**Solution approach**: Prove that when processing Box psi, `seed.familyIndices = {famIdx}` because the positive branch never creates families.

### Sorry 2: Line 3236 - G Case addToAllFutureTimes_preserves_consistent

**Context**: When processing G psi, we add psi to all future times in the family. Similar to the Box case, we need to show this preserves consistency.

**Current code**:
```lean
have h_seed3_cons : SeedConsistent seed3 := by
  -- BLOCKING: Requires addToAllFutureTimes_preserves_consistent lemma
  sorry
```

**Why it is blocked**: addToAllFutureTimes iterates over all time indices > currentTime in the family. For each such time, we add psi. We need to show the existing formulas at those times are compatible with psi.

**Key observation**: When we reach the G case, what times exist in the family?

Analysis:
1. Times are created by createNewTime in neg-G and neg-H cases
2. The G case itself adds to EXISTING times, never creates new ones
3. New times are created at `freshFutureTime` (for neg-G) or `freshPastTime` (for neg-H)
4. freshFutureTime returns max + 1, freshPastTime returns min - 1

**Insight**: When we add psi to future times, those times were created by PREVIOUS neg-G processing. But neg-G processing:
1. Creates a new time with a SINGLETON set containing neg(inner)
2. Recurses on neg(inner) at that new time
3. The recursion does NOT create the same time again

So future times contain formulas from their own recursive processing, which may include atoms, implications, or results of further Box/G/H processing.

**Solution approach**: Track that all formulas in the seed are subformulas of the root formula, and subformulas of a consistent formula are mutually compatible (with care about the subformula relation).

### Sorry 3: Line 3350 - H Case addToAllPastTimes_preserves_consistent

**Context**: Symmetric to the G case for past times.

**Solution approach**: Same as G case - track subformula relationships.

### Sorry 4: Line 3598 - Generic Imp Case h_eq

**Context**: The generic imp case needs to prove that buildSeedAux (p1.imp p2) reduces to addFormula when (p1, p2) don't match the special patterns (box/bot, all_future/bot, all_past/bot).

**Current code**:
```lean
have h_eq : buildSeedAux (p1.imp p2) famIdx timeIdx seed =
    seed.addFormula famIdx timeIdx (p1.imp p2) .universal_target := by
  -- BLOCKING: Need to show buildSeedAux reduces to addFormula for generic imp
  sorry
```

**Why it is blocked**: Lean's pattern matching doesn't provide "negative information" - when we enter the catch-all case, we don't get a proof that p1 is not box/all_future/all_past or that p2 is not bot.

**Solution approaches**:
1. **Exhaustive case analysis**: Split on all possible (p1, p2) combinations. This is tedious (~30 cases) but mechanical.
2. **Decidable predicate**: Define a decidable predicate `isSpecialImp` and use it in buildSeedAux instead of pattern matching. Then the catch-all provides `isSpecialImp p1 p2 = false`.
3. **Accept this sorry**: This sorry is not mathematically interesting - it's just Lean technical limitation. Could be marked as "Lean pattern matching limitation" and documented.

**Recommendation**: Option 1 or 3. Option 2 requires refactoring buildSeedAux which may break the termination proof.

## Proposed Solution: Single-Path Invariant

The key insight across all sorries is that buildSeedAux follows a SINGLE PATH through the formula tree. This means:

1. At any recursive call, we are processing exactly ONE subformula of the root
2. New families are only created on the NEGATIVE branch (neg-Box)
3. New times are only created on the NEGATIVE branch (neg-G, neg-H)
4. The POSITIVE branch (Box, G, H) only adds to existing entries

### Formal Statement

Define a predicate tracking the "branch type":

```lean
inductive BranchType where
  | positive : BranchType  -- Currently processing positive operator (Box, G, H)
  | negative : BranchType  -- Currently processing negative operator (neg-Box, neg-G, neg-H)
```

The single-path invariant states:
- When on the positive branch, `seed.familyIndices = {famIdx}` (no other families exist)
- When processing Box on the positive branch, addToAllFamilies only affects famIdx

### Alternative: Subformula Compatibility

Another approach is to prove:
```lean
theorem subformulas_set_consistent (phi : Formula) (h : FormulaConsistent phi) :
  ∀ psi1 ∈ phi.subformulas, ∀ psi2 ∈ phi.subformulas, SetConsistent {psi1, psi2}
```

However, this is FALSE in general. Counter-example:
- phi = Box p ∧ Diamond(neg p) is consistent
- But {p, neg p} is not consistent

The issue is that subformulas can appear in different MODAL CONTEXTS that isolate them.

### Correct Approach: Path-Based Formulas

The correct insight is that buildSeedAux follows a SINGLE PATH, not that it collects all subformulas. Specifically:

When buildSeedAux(phi, famIdx, timeIdx, seed) recurses on psi:
1. For Box psi: recurses on psi at SAME (famIdx, timeIdx)
2. For G psi: recurses on psi at SAME (famIdx, timeIdx)
3. For H psi: recurses on psi at SAME (famIdx, timeIdx)
4. For neg-Box psi: recurses on neg(psi) at NEW FAMILY
5. For neg-G psi: recurses on neg(psi) at NEW TIME
6. For neg-H psi: recurses on neg(psi) at NEW TIME

The formulas at any given (famIdx, timeIdx) come from:
1. The initial formula at that position
2. Subformulas added by positive operator unwrapping
3. Universal additions from Box/G/H operators

Key: Formulas at the SAME position all come from the SAME path through the formula tree, so they are mutually derivable/compatible.

### Concrete Proof Sketch for Sorry 1

When Box psi is processed at (famIdx, timeIdx):
1. seed1 = seed.addFormula famIdx timeIdx (Box psi) - adds Box psi
2. seed2 = seed1.addToAllFamilies timeIdx psi - adds psi to ALL families at timeIdx

Claim: At this point, seed1.familyIndices = {famIdx} (only one family exists).

Proof:
- By induction on the recursive structure of buildSeedAux
- The ONLY way to add a family is createNewFamily (neg-Box case)
- We are in the Box case (positive), not neg-Box
- By IH, no families were created by ancestor recursive calls on this path
- Therefore seed.familyIndices = {famIdx} (inherited from initial or previous positive calls)

With this claim, addToAllFamilies only modifies entries at famIdx, so h_same_fam is always true and the sorry is eliminated.

## Implementation Recommendations

### Priority 1: Prove the Single-Path Property (Sorries 1-3)

Add a new invariant to buildSeedAux_preserves_seedConsistent:

```lean
-- Track that we're on a "positive path" where no new families have been created
theorem buildSeedAux_preserves_seedConsistent_positive
    (phi : Formula) (famIdx : Nat) (timeIdx : Int) (seed : ModelSeed)
    (h_cons : SeedConsistent seed)
    (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : seed.familyIndices = [famIdx]) -- KEY ADDITION
    : SeedConsistent (buildSeedAux phi famIdx timeIdx seed) ∧
      (∀ other, other ∈ (buildSeedAux phi famIdx timeIdx seed).familyIndices →
        other = famIdx ∨ -- same family
        ∃ path_to_neg_box, ...) -- family was created by neg-Box on this path
```

### Priority 2: Handle Generic Imp Case (Sorry 4)

Choose one of:
1. **Explicit exhaustive cases** (recommended for completeness):
   ```lean
   match p1 with
   | Formula.atom _ => match p2 with | _ => ...
   | Formula.bot => match p2 with | _ => ...
   | Formula.box _ => match p2 with | Formula.bot => exact ... | _ => ...
   | Formula.all_future _ => match p2 with | Formula.bot => exact ... | _ => ...
   | Formula.all_past _ => match p2 with | Formula.bot => exact ... | _ => ...
   | Formula.imp _ _ => match p2 with | _ => ...
   ```

2. **Accept as technical debt** with clear documentation that this is a Lean limitation, not a mathematical gap.

### Priority 3: Strengthen SeedWellFormed

Add to SeedWellFormed:
```lean
-- Track creation history: each entry knows if it came from positive or negative branch
-- Track: familyIdx 0 is the initial family, others are neg-Box witnesses
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Single-path invariant is harder than expected | Medium | Low | The invariant follows directly from buildSeedAux structure |
| Generic imp case requires 30+ subcases | Low | Medium | Accept sorry or batch the cases with automation |
| Induction hypothesis changes break existing proofs | Medium | Medium | Carefully add new hypotheses without changing existing structure |

## Sorry Characterization

Following proof-debt-policy.md:

### Current State
- **4 sorries in RecursiveSeed.lean**: Development placeholders with clear resolution paths
- **Transitive impact**: seedConsistent theorem depends on these sorries
- **Publication status**: Blocks transitive sorry-freedom

### Remediation Path
- Path A (Proof Completion): Implement single-path invariant (sorries 1-3)
- Path A (Proof Completion): Explicit case analysis or accept technical debt (sorry 4)

### Expected Outcome
- 0 sorries for sorries 1-3 after single-path invariant
- 0-1 sorry for sorry 4 depending on approach chosen

## Recommendations

1. **Immediate action**: Add h_single_family hypothesis to buildSeedAux_preserves_seedConsistent
2. **Prove single-family preservation**: Show that Box/G/H cases preserve the single-family property
3. **Handle G/H cases**: Use the single-path property for addToAllFutureTimes/PastTimes
4. **Decide on generic imp**: Either exhaustive cases (complete) or document as Lean limitation

Estimated sessions to complete:
- Single-path invariant and sorries 1-3: 2-3 sessions
- Generic imp case: 1 session (exhaustive) or 0 (accept)
- Total: 3-4 sessions

## References

- RecursiveSeed.lean lines 3052-3138 (Box case)
- RecursiveSeed.lean lines 3145-3261 (G case)
- RecursiveSeed.lean lines 3262-3375 (H case)
- RecursiveSeed.lean lines 3571-3614 (generic imp case)
- research-002.md Section 3 (why seed construction works)
- research-003.md (meta-evaluation showing 17->4 sorry reduction)
