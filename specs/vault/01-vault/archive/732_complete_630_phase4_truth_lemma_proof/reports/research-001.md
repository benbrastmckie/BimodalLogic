# Research Report: Task #732

**Task**: 732 - Complete phase 4 of task 630: Truth Lemma proof
**Started**: 2026-01-29T07:23:00Z
**Completed**: 2026-01-29T07:45:00Z
**Effort**: 1-2 hours (estimated)
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Mathlib, lean_leansearch, lean_loogle, lean_leanfinder, codebase analysis
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The `mem_extractTrueAtomSet_iff` lemma requires proving membership in a `List.foldl` result over `Finset.insert`
- Proof strategy: Generalize with an accumulator auxiliary lemma, then induct on the branch list
- Key Mathlib lemmas: `List.foldl_nil`, `List.foldl_cons`, `Finset.mem_insert`, `Finset.notMem_empty`
- Case splits needed on `SignedFormula.sign` (2 cases) and `Formula` constructors (6 cases)

## Context & Scope

The lemma establishes the correspondence between:
- `p ∈ extractTrueAtomSet b` (membership in extracted atom set)
- `SignedFormula.pos (.atom p) ∈ b` (positive atom formula in branch)

### Definition Analysis

```lean
def extractTrueAtomSet (b : Branch) : Finset String :=
  b.foldl (fun acc sf =>
    match sf.sign, sf.formula with
    | .pos, .atom p => insert p acc
    | _, _ => acc
  ) ∅
```

The function folds over a `Branch` (which is `List SignedFormula`), inserting atom names into a `Finset String` accumulator only when the signed formula has positive sign and is an atom.

### Type Structure

- `Branch = List SignedFormula`
- `SignedFormula = { sign : Sign, formula : Formula }`
- `Sign = pos | neg` (2 constructors)
- `Formula = atom String | bot | imp Formula Formula | box Formula | all_past Formula | all_future Formula` (6 constructors)

## Findings

### Relevant Mathlib Theorems

1. **`List.foldl_nil`**: `List.foldl f b [] = b`
   - Module: `Init.Data.List.Basic`
   - Base case for induction

2. **`List.foldl_cons`**: `List.foldl f b (a :: l) = List.foldl f (f b a) l`
   - Module: `Init.Data.List.Basic`
   - Inductive step transformation

3. **`Finset.mem_insert`**: `a ∈ insert b s ↔ a = b ∨ a ∈ s`
   - Module: `Mathlib.Data.Finset.Insert`
   - Core membership characterization after insert

4. **`Finset.notMem_empty`**: `a ∉ ∅`
   - Module: `Mathlib.Data.Finset.Empty`
   - Base case: nothing in empty set

5. **`Finset.mem_insert_self`**: `a ∈ insert a s`
   - Module: `Mathlib.Data.Finset.Insert`
   - When inserting the element we're looking for

6. **`Finset.mem_insert_of_mem`**: `a ∈ s → a ∈ insert b s`
   - Module: `Mathlib.Data.Finset.Insert`
   - Membership preserved through insert

### Proof Strategies

#### Strategy 1: Suffices with Generalized Accumulator (Recommended)

The comment in the code suggests this approach:
```lean
suffices h : ∀ acc, p ∈ b.foldl (...) acc ↔ p ∈ acc ∨ SignedFormula.pos (.atom p) ∈ b
then use h ∅ with Finset.notMem_empty to eliminate p ∈ ∅
```

**Proof Outline**:
1. State suffices with generalized accumulator
2. Induct on branch `b`
3. Base case: `b = []`, use `List.foldl_nil`, reduces to `p ∈ acc ↔ p ∈ acc ∨ False`
4. Inductive case: `b = sf :: rest`, use `List.foldl_cons`
   - Case split on `sf.sign` and `sf.formula`
   - For `(.pos, .atom q)`: use `Finset.mem_insert`
   - For other cases: accumulator unchanged, IH applies directly
5. Apply suffices to `∅`, use `Finset.notMem_empty` to simplify

#### Strategy 2: Direct Induction with Witness

Alternative approach using `List.mem_cons`:
```lean
induction b with
| nil => simp [extractTrueAtomSet, List.foldl_nil, Finset.not_mem_empty]
| cons sf rest ih =>
    simp only [extractTrueAtomSet, List.foldl_cons, List.mem_cons]
    -- case split on sf
```

### Case Split Structure

For the inductive step, match on `(sf.sign, sf.formula)`:

| Sign | Formula | Accumulator Update | Membership |
|------|---------|-------------------|------------|
| pos | atom q | `insert q acc` | `p = q ∨ p ∈ acc` |
| pos | bot | `acc` | `p ∈ acc` |
| pos | imp _ _ | `acc` | `p ∈ acc` |
| pos | box _ | `acc` | `p ∈ acc` |
| pos | all_past _ | `acc` | `p ∈ acc` |
| pos | all_future _ | `acc` | `p ∈ acc` |
| neg | atom q | `acc` | `p ∈ acc` |
| neg | bot | `acc` | `p ∈ acc` |
| neg | imp _ _ | `acc` | `p ∈ acc` |
| neg | box _ | `acc` | `p ∈ acc` |
| neg | all_past _ | `acc` | `p ∈ acc` |
| neg | all_future _ | `acc` | `p ∈ acc` |

Only the first case (`pos`, `atom q`) modifies the accumulator. The proof needs to show:
- If `q = p`: `p ∈ insert q acc` is true by `Finset.mem_insert_self`
- If `q ≠ p`: reduces to `p ∈ acc` via `Finset.mem_insert`

### Dependencies

Required imports (already present in the file):
- `Mathlib.Data.Finset.Basic` (provides `Finset.mem_insert`, etc.)

No additional imports needed.

## Decisions

1. **Use suffices pattern**: The generalized accumulator approach is cleaner and matches the existing comment
2. **Unfold extractTrueAtomSet**: Don't use `simp` on the definition directly; unfold manually for clarity
3. **Case split order**: Split on sign first, then formula (matches the match expression structure)

## Recommendations

1. **Primary approach**: Use the suffices pattern with generalized accumulator as outlined in Strategy 1
2. **Automation**: Consider using `decide` or `omega` where appropriate for trivial goals
3. **Simp lemmas**: The key simp lemmas are `List.foldl_nil`, `List.foldl_cons`, `Finset.mem_insert`
4. **List membership**: Use `List.mem_cons` for the RHS: `sf ∈ sf :: rest ↔ sf = sf ∨ sf ∈ rest`

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Case explosion | Medium | Use `rcases` or `obtain` for structured matching |
| Verbose proof | Low | Extract repeated patterns into have statements |
| Tactic state complexity | Low | Use `show` to clarify expected types |

## Implementation Estimate

- **Estimated lines**: 40-60 lines of proof
- **Complexity**: Mechanical but verbose due to 12 case splits
- **Difficulty**: Low to Medium

## Appendix

### Search Queries Used

1. `lean_leansearch`: "membership in finset after foldl with insert"
2. `lean_loogle`: `_ ∈ List.foldl _ _ _`, `List.foldl _ _ [] = _`, `List.foldl _ _ (_ :: _) = _`
3. `lean_leanfinder`: "generalized foldl membership characterization for finset insert"
4. `lean_local_search`: `foldl_mem`, `Finset.mem_insert`, `mem_foldl`

### File Location

- File: `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/BranchTaskModel.lean`
- Line: 269-277
- Sorry location: Line 277

### Next Steps

Proceed to `/plan 732` to create implementation plan with exact tactic sequence.
