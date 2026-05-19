# Research Report: Task #157 — Post-Task-116 Team Assessment

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1779177638_d9bad6

## Summary

The Separation module (12 files, ~8000 LOC) is completely broken after task 116's removal of `all_past`/`all_future` as Formula constructors. It is not in the main build path (WeakCanonical.lean excludes it), so `lake build` passes without compiling it. Repair requires 248 match-arm fixes across 10 files plus ~52 simp lemmas to restore semantic correctness. The structural hierarchy circularity IS resolved at the type level (only 6 constructors remain), but the semantic layer (predicates, measures, proofs) needs careful repair. A critical strategic finding: task 155 (Reynolds pipeline) may not require axiom elimination at all, since the 9 axioms are Lean `axiom` declarations (not `sorry`) and the separation theorem exists as a callable black-box.

## Key Findings

### 1. Mechanical Repair Scope (Teammate A)

- **248 repair sites** across 10 files: 68 function-definition match arms (Type A), 180 induction case arms (Type B)
- **~52 simp lemmas needed** to restore intended behavior for functions like `is_U_free`, `is_S_free`, `is_syntactically_separated`, `junction_depth`, `int_truth`
- **Critical semantic issue**: Simply removing the `all_past`/`all_future` match arms causes functions to fall through to the `imp` arm, giving WRONG results. Example: `is_S_free (all_past φ)` should return `is_S_free φ`, but without a simp lemma it returns `false` (because the expansion contains `snce`)
- **Repair order**: Defs.lean first (foundation), then dependency-ordered: FormulaOps → Eliminations → NormalForm → SeparationThm → TemporalClosure → DedekindZ → Hierarchy → Duality → ExpressiveCompleteness
- **Files with zero repair sites**: IntHelpers.lean, NegationEquiv.lean, DualEliminations.lean

### 2. GHR94 Hierarchy Proof (Teammate B)

- **Proof chain confirmed**: GHR94 10.2.3 → 10.2.4 → 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8, culminating in junction-depth induction
- **All 8 primary elimination cases already proved** in Eliminations.lean
- **Circularity resolution mechanism**: With 6-constructor Formula type, the substitution callback in `subst_in_separated_separable` never encounters `all_past`/`all_future` nodes. The `has_no_allpast_allfuture` precondition becomes vacuously true
- **Recommended well-founded measures**: Lexicographic `(count_U_subformulas φ, Formula.sizeOf φ)` for inner induction, `junction_depth φ` via `Nat.strongRecOn` for outer
- **Axiom count drops from 9 to ~2**: After repair, temporal closure axioms for H/G become unnecessary (only 6 constructor cases in `all_separable`). Only `untl_separable` and `snce_separable` need proof from hierarchy

### 3. Critical Risks and Gaps (Teammate C)

- **Predicate inconsistency**: `is_U_free`, `is_S_free`, `is_syntactically_separated` will compute wrong results if match arms are dead code. Whether alive or dead, the predicates must be redefined consistently with the 6-constructor type
- **Hierarchy still calls `all_separable`**: Lines 1692 and 1698 of Hierarchy.lean delegate `.untl` and `.snce` cases to `all_separable`, which uses all 9 axioms. Nothing is eliminated without restructuring this
- **`subst_in_separated_separable` callback problem**: When substituting U(A,B) into a separated formula, the result may contain unseparated subexpressions requiring the full hierarchy to prove separable. This is the core of the circularity and is NOT trivially a "30 LOC" fix
- **DualEliminations.lean has 8 sorries** that block any "sorry-free Separation module" claim
- **Effort underestimation risk**: Prior attempts had 0% completion on core theorems across multiple sessions. Realistic estimate: 20-36 hours minimum

### 4. Strategic Assessment (Teammate D)

- **The 9 axioms are `axiom` declarations, NOT `sorry`**: They will NOT show `sorryAx` in `#print axioms bx_completeness`. This is a critical distinction
- **Task 155 does not need zero axioms**: Phase 3B needs the separation theorem as a callable black-box, which already exists. The axioms are invisible at the call site
- **TemporalClosure.lean (~813 lines) is mostly dead code** after task 116 — can be substantially trimmed
- **Code quality is high** where it compiles (Eliminations.lean is exemplary)
- **Recommended approach**: "Flat Hierarchy" — single well-founded induction on `junction_depth`, proving `no_S_nested_separable` without temporal closure axioms

## Synthesis

### Conflicts Resolved

| Conflict | Teammate B | Teammate C | Resolution |
|----------|-----------|-----------|------------|
| Is circularity resolved? | Yes, structurally | No, semantically | **Both right**: The type-level circularity IS resolved (6 constructors), but the semantic layer (predicates, measures) needs repair to be consistent. The structural resolution unblocks the hierarchy proof; the semantic repair is a prerequisite for that proof to type-check |
| Effort estimate | 20-28 hours | 20-36 hours | **Converge on 25-35 hours**: Both agree the prior "6 hour" estimate was too low. The mechanical repair (8-12h) + hierarchy proof (10-15h) + testing (5-8h) = 23-35h |
| Is axiom elimination needed? | Yes, reduce 9→2 | Notes hierarchy still calls all_separable | **Strategic question**: Teammate D's finding that task 155 doesn't need zero axioms may mean full axiom elimination is optional. The mandatory work is: (1) mechanical repair to make module compile, (2) close 8 DualEliminations sorries. Axiom elimination is mathematically desirable but not blocking |

### Gaps Identified

1. **No concrete verification of predicate behavior**: Nobody ran `#eval` or `#check` to verify what `is_U_free (all_past φ)` actually computes after task 116. This is the FIRST thing to check
2. **Build path integration**: The Separation module should be added to the main build path (or at least tested via `lake build Bimodal.Metalogic.Separation.Defs`) to get real compiler feedback
3. **DualEliminations 8 sorries**: These are pre-existing debt but their resolution path depends on the hierarchy theorem. They should be in scope for task 157
4. **ExpressiveCompleteness.lean status**: Not fully assessed by any teammate — needs separate examination after repair

### Recommendations

**Phase 1: Mechanical Repair (8-12 hours)**
- Fix Defs.lean with simp lemmas (highest priority, unblocks everything)
- Propagate fixes through dependency chain
- Trim TemporalClosure.lean dead code
- Goal: `lake build Bimodal.Metalogic.Separation.Defs` succeeds

**Phase 2: Hierarchy Proof (10-15 hours)**
- Implement "Flat Hierarchy" approach with junction_depth induction
- Use lexicographic measure for inner induction
- Prove `no_S_nested_separable` → `junction_depth_separable` → `all_separable` (without axioms)
- This is the hard mathematical work

**Phase 3: DualEliminations + Axiom Elimination (5-8 hours)**
- Close 8 sorry sites using hierarchy theorem results
- Eliminate axioms as corollaries of hierarchy theorem
- Verify module compiles sorry-free and axiom-free

**Phase 4: Integration + Validation (2-3 hours)**
- Add Separation module to main build path
- Verify `lake build` passes with Separation included
- Run `#print axioms` on key theorems

**Critical strategic decision**: If the goal is sorry-free `bx_completeness` (task 155), and the 9 axioms don't show as `sorryAx`, then Phases 2-3 may be deferrable. The mandatory work is Phase 1 (make module compile) + verifying that task 155 can use the separation theorem as-is. Axiom elimination is mathematically clean but potentially not on the critical path.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Mechanical Repairs | completed | high | 248 repair sites cataloged file-by-file, ~52 simp lemmas identified |
| B | GHR94 Hierarchy | completed | high | Confirmed circularity resolution, axiom reduction 9→2, well-founded measures |
| C | Critic | completed | high | Predicate inconsistency risk, effort underestimation, callback problem depth |
| D | Horizons | completed | high | Axiom vs sorry distinction, task 155 independence, dead code identification |

## References

- GHR94 Ch 10.2 (Separation Theorem, Theorem 10.2.9-10.2.10)
- Prior reports: 08 (Case 7, circularity diagnosis), 09 (root cause), 10 (task 116 dependency)
- Report 11 (post-task-116 single-agent assessment)
- Teammate findings: 12_teammate-{a,b,c,d}-findings.md
