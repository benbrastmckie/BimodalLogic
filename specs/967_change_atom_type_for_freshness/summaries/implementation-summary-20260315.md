# Implementation Summary: Task #967

**Task**: 967 - Change atom type from String to freshness-supporting type
**Status**: BLOCKED (requires user review)
**Session**: sess_1773534243_c831c6
**Date**: 2026-03-15

## Critical Finding: Task Goal is Mathematically Impossible

During Phase 1 implementation, analysis revealed that the task's stated goal (eliminating `canonicalR_irreflexive` axiom by completing the Gabbay IRR proof) is **mathematically impossible in TM logic**.

### Research Contradiction

The implementation plan was based on `research-001.md` (task 967), which claimed:
> "The proof strategy is sound; the blocker was String atom freshness"

However, `research-006.md` and `research-007.md` (task 964) contain exhaustive team research proving:
1. **Fresh atoms are INSUFFICIENT** - They enable Steps 2-5 of the Gabbay IRR proof but NOT Step 6
2. **Step 6 requires T-axiom** (`H(phi) -> phi`), which is not in TM logic
3. **Semantic impossibility proof** - A one-world reflexive model satisfies all TM axioms, proving `canonicalR_irreflexive` cannot be a TM theorem
4. **The axiom is the correct resolution** - It documents a legitimate frame property assumption

### Key Reference: research-006.md Section 4

From the team research (task 964):

```
Step 6: Derive contradiction.
        NEED: both p in M' and neg(p) in M'.
        HAVE: p in M' (checkmark)
        NEED: neg(p) in M'
        <-- Standard path: H(neg(p)) in M' --[T-axiom: H(phi)->phi]--> neg(p) in M'. X NO T-AXIOM.
        <-- BLOCKED X
```

Fresh atoms (via `Atom.exists_fresh`) can provide a fresh `p` for the naming set construction, but **cannot bridge the T-axiom gap** in the final step.

## Work Completed

### Phase 1 (Partial): Type Fixes

Attempted to convert String -> Atom in CanonicalIrreflexivity.lean:
- atomFreeSubset, namingSet signatures
- Helper theorem signatures
- Deleted unused String freshness functions

**Reverted**: Changes were reverted because the underlying task is blocked.

### Pre-existing Technical Debt

The file `CanonicalIrreflexivity.lean` was **already broken** before this task:
- Formula.lean was updated to use Atom type
- CanonicalIrreflexivity.lean still uses `(p : String)`
- This causes `Formula.atom p` type errors (String vs Atom)

The file cannot build in its committed state.

## Recommendations

### Option 1: Keep Axiom, Archive Proof Attempt (Recommended)

Per research-006.md and research-007.md:
1. Keep `canonicalR_irreflexive` as documented axiom in `CanonicalIrreflexivityAxiom.lean`
2. Archive or delete `CanonicalIrreflexivity.lean` (failed proof attempt)
3. Update task 967 description to reflect mathematical reality
4. Mark axiom as "frame property assumption" in documentation

This matches the recommendation from task 964's exhaustive research.

### Option 2: Complete Type Fixes Only

1. Fix the String -> Atom type mismatches in CanonicalIrreflexivity.lean
2. Keep the 2 sorries (they remain blocked on T-axiom gap)
3. Update documentation to explain why proof is impossible
4. Keep the axiom

This preserves the proof structure but acknowledges it cannot complete.

### Option 3: Reflexive Semantics Refactor

Per research-007.md, switching G/H semantics from irreflexive to reflexive would enable the T-axiom and complete the proof. However:
- Estimated effort: 40-100 hours
- Requires complete restructuring of density proofs
- ROAD_MAP.md Dead End documents 3 months of prior failed effort

NOT recommended.

## Files Affected

| File | Status | Notes |
|------|--------|-------|
| `CanonicalIrreflexivity.lean` | Broken (pre-existing) | String/Atom type mismatch |
| `CanonicalIrreflexivityAxiom.lean` | Unchanged | Axiom should remain |
| `implementation-001.md` | Updated to [BLOCKED] | Plan blocked |
| `.return-meta.json` | Written | Blocker documented |

## Key References

- `specs/964_resolve_atom_type_freshness_debt/reports/research-006.md` - Team proof impossibility analysis
- `specs/964_resolve_atom_type_freshness_debt/reports/research-007.md` - Reflexive semantics feasibility analysis
- `ROAD_MAP.md` - Dead End: "Reflexive G/H Semantics Switch"

## Conclusion

Task 967's goal cannot be achieved. The `canonicalR_irreflexive` axiom represents a genuine frame property of strict temporal semantics that cannot be derived from TM logic axioms alone. This is proven by:
1. The semantic impossibility argument (one-world reflexive model)
2. The absence of T-axiom in TM logic
3. Prior 3-month effort documented in ROAD_MAP.md Dead End

User review required to decide between Options 1-3 above.
