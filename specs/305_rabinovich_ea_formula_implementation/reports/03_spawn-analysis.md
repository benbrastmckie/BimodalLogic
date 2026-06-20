# Blocker Analysis: Task #305

**Parent Task**: #305 - Rabinovich EA-formula implementation
**Generated**: 2026-06-20
**Blocker**: The VecEA2 three-case negation closure proof (Phase 4) cannot produce a structurally fixed VVecEA2 from conjunctions of case results without a combinatorial BracketFormula conjunction that operates model-independently on witness counts.

## Root Cause

Phase 4 of task 305 is blocked at `neg_bracket_is_vbracket` (the inductive step). The research and design reports (01, 02) have identified the correct proof strategy: prove `neg_vecEA2_is_vvecEA2` by induction on n using the paper's three-case decomposition (Case 1: endpoint failure; Case 2: first segment universal; Case 3: first segment failure + interval split), then derive `neg_bracket_is_vbracket` as a corollary via `VecEA2.fromBracket`.

The specific missing piece is that the three-case proof produces VVecEA2 disjunct collections from each case, and these must be combined by conjunction into a single VVecEA2. The existing `VVecEA2.conj_holds_vvecEA2` and `BracketFormula.conj_to_bracket_exists` only prove existence (`∃ n, ∃ bf, ...`) -- they do not return a structurally fixed, model-independent BracketFormula that can be used inside the inductive hypothesis.

What is needed: a **combinatorial BracketFormula conjunction** that takes `bf1 : BracketFormula n1` and `bf2 : BracketFormula n2` and returns a concrete `bf_conj : BracketFormula (n1 + n2)` (or similar fixed structure) such that `bf1.holds ∧ bf2.holds → bf_conj.holds` holds uniformly across models. The existing `conj_to_bracket_exists` is sufficient for the forward direction of closure lemmas but not for the inductive construction where the "existential bracket" must be fixed syntactically to appear in the VVecEA2 returned by the induction.

The user's blocker description confirms this: "Add combinatorial BracketFormula conjunction to VecEAClosure.lean to create a prerequisite task for the missing infrastructure."

This is a distinct and separable subtask: implementing the combinatorial conjunction as a new definition + theorem in VecEAClosure.lean, before the VecEA2 negation closure induction can proceed in EANegation.lean.

## Proposed New Tasks

### New Task 1: Add Combinatorial BracketFormula Conjunction to VecEAClosure.lean
- **Effort**: 1-2 hours
- **Task Type**: lean4
- **Rationale**: The three-case VecEA2 negation induction in Phase 4 requires a model-independent, structurally fixed conjunction of BracketFormulas. The existing `conj_to_bracket_exists` only provides existence. This task adds `BracketFormula.conjStruct : BracketFormula n1 → BracketFormula n2 → BracketFormula (n1 + n2)` (or equivalent fixed-n form) and proves the forward semantic direction: if both factors hold on (z0, z1) with their respective witnesses, then conjStruct holds on (z0, z1). The construction interleaves the n1 and n2 witnesses with trivially-satisfied segment types from the other factor, following the same approach sketched in the existing `conj_to_bracket_exists` n1+1/n2+1 case. Also add the corresponding `VBracketFormula.conj_vbracket_struct` and `VVecEA2.conj_vvecEA2_struct` structural variants that return fixed disjunct lists (rather than existential witnesses), so the inductive proof can quote a specific VVecEA2.
- **Depends on**: None

## Dependency Reasoning

- **New Task 1 is the only task**: The blocker is a single self-contained gap in VecEAClosure.lean. Once the combinatorial conjunction infrastructure exists, the next `/implement 305` dispatch can directly proceed with the `neg_vecEA2_is_vvecEA2` inductive proof in EANegation.lean (Phase 4).

- **No dependency on other new tasks**: This task only modifies VecEAClosure.lean, which is already fully imported by EANegation.lean. Adding definitions here does not require changes to any other file.

## After Completion

Once the spawned task is complete, resume the parent task #305 with `/implement 305`.

The blocker will be resolved because: the combinatorial conjunction infrastructure in VecEAClosure.lean will supply the missing `BracketFormula.conjStruct` and associated theorems, allowing the `neg_vecEA2_is_vvecEA2` inductive step to produce a fixed VVecEA2 combining the three case contributions without resorting to existential witnesses that break the inductive structure.
