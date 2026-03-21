# Research Report: Task #891

**Task**: Fix split-at tactic incompatibility in TemporalLindenbaum.lean
**Date**: 2026-02-17
**Focus**: Identify all split-at tactic patterns incompatible with Lean 4.27.0-rc1 and document required conversions

## Summary

The TemporalLindenbaum.lean file has 8 distinct build errors in Lean 4.27.0-rc1, with 4 categories of issues: (1) `split` cannot handle `have`-wrapped match expressions from `temporalWitnessChain`, (2) `split at h_mem ⊢` syntax for multiple targets is not supported, (3) `henkinStep` has an instance synthesis failure, and (4) `finite_list_in_henkinChain` has type errors. Additionally, there are multiple warnings where `split at` tactics "do nothing" after simplification produces `sorry` placeholders.

## Findings

### 1. Build Errors (8 Total)

The file `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` fails to build with the following errors:

| Line | Error Type | Message | Location |
|------|------------|---------|----------|
| 214 | split failure | Could not split an `if` or `match` expression in the goal | `temporalWitnessChain_head` |
| 223 | multi-target | Specifying multiple targets (the goal and hypothesis `h_mem`) is not supported | `forward_witness_in_chain` |
| 266 | multi-target | Specifying multiple targets (the goal and hypothesis `h_mem`) is not supported | `backward_witness_in_chain` |
| 324 | instance synthesis | failed to synthesize instance of type class | `henkinStep` definition |
| 346 | split failure | Could not split an `if` or `match` expression in the goal | `henkinChain_mono` |
| 373 | split failure | Could not split an `if` or `match` expression in the goal | `henkinStep_consistent` |
| 394 | type mismatch | Application type mismatch | `finite_list_in_henkinChain` |
| 398 | function expected | Function expected at | `finite_list_in_henkinChain` |

### 2. Root Cause Analysis

#### 2.1 `temporalWitnessChain` Unfolding Produces `have` Bindings

When `unfold temporalWitnessChain` is used, the resulting goal contains:

```lean
have φ := χ;
match h_bwd : extractForwardWitness φ with
| some ψ => φ :: temporalWitnessChain ψ
| none => ...
```

The `have φ := χ;` binding is introduced because `temporalWitnessChain` uses `termination_by` and `decreasing_by`. In Lean 4.22.0+, non-dependent `let` bindings are transformed to `have` bindings for performance (see release notes).

The `split` tactic cannot handle this `have`-wrapped match expression because it expects a direct `if` or `match` at the goal's head.

#### 2.2 `split at h ⊢` Multi-Target Syntax

Lines 223 and 266 use `split at h_mem ⊢` to split both a hypothesis and the goal. This syntax is NOT supported in Lean 4.27.0-rc1:

```lean
split at h_mem ⊢  -- ERROR: Specifying multiple targets not supported
```

The `split` tactic only allows splitting ONE location at a time.

#### 2.3 Warnings: `split at` Does Nothing

After `simp only [henkinStep] at h_in_chain`, the goal shows `h_in_chain : ψ.some_past ∈ sorry`. This `sorry` appears because the recursive `henkinChain` call is represented as a placeholder during elaboration. The `split at h_in_chain` then finds nothing to split.

### 3. Affected Code Locations

#### Category A: `split` fails on `have`-wrapped match (3 locations)

| Line | Lemma | Current Code |
|------|-------|--------------|
| 214 | `temporalWitnessChain_head` | `split <;> (try split) <;> simp` |
| 346 | `henkinChain_mono` | `split` (after `simp only [henkinChain]`) |
| 373 | `henkinStep_consistent` | `split` (after `simp only [henkinStep]`) |

**Recommended Fix**: Replace `unfold + split` pattern with explicit `cases` on the match discriminant:

```lean
-- BEFORE (line 214):
lemma temporalWitnessChain_head (φ : Formula) : φ ∈ temporalWitnessChain φ := by
  unfold temporalWitnessChain
  split <;> (try split) <;> simp

-- AFTER:
lemma temporalWitnessChain_head (φ : Formula) : φ ∈ temporalWitnessChain φ := by
  unfold temporalWitnessChain
  cases h_fwd : extractForwardWitness φ with
  | some ψ => simp
  | none =>
    cases h_bwd : extractBackwardWitness φ with
    | some ψ => simp
    | none => simp
```

#### Category B: `split at h ⊢` multi-target syntax (2 locations)

| Line | Lemma | Current Code |
|------|-------|--------------|
| 223 | `forward_witness_in_chain` | `split at h_mem ⊢` |
| 266 | `backward_witness_in_chain` | `split at h_mem ⊢` |

**Recommended Fix**: Split each target separately:

```lean
-- BEFORE (line 223):
unfold temporalWitnessChain at h_mem ⊢
split at h_mem ⊢

-- AFTER:
unfold temporalWitnessChain at h_mem ⊢
-- Split goal first
cases h_fwd_goal : extractForwardWitness χ with
| some ψ' =>
  -- Now split hypothesis - use rw or cases depending on structure
  ...
| none =>
  cases h_bwd_goal : extractBackwardWitness χ with
  | some ψ' => ...
  | none => ...
```

Alternative: Use `conv` or manual match_case tactics to handle the hypothesis and goal separately.

#### Category C: Instance Synthesis Failure (1 location)

| Line | Definition | Issue |
|------|------------|-------|
| 324 | `henkinStep` | `failed to synthesize instance of type class` |

This error at the `henkinStep` definition suggests a missing instance or import. Need to check what instance is missing.

#### Category D: Type Errors (2 locations)

| Line | Lemma | Issue |
|------|-------|-------|
| 394 | `finite_list_in_henkinChain` | Application type mismatch |
| 398 | `finite_list_in_henkinChain` | Function expected |

These are secondary errors likely caused by earlier failures cascading.

### 4. Split at Warnings (Does Nothing)

Lines 442 and 485 have `split at h_in_chain` that produces warnings because after `simp only [henkinStep]`, the hypothesis contains `sorry` placeholder:

```
h_in_chain : ψ.some_future ∈ sorry
```

This is likely an elaboration artifact from the recursive chain. The proof needs restructuring to avoid this pattern.

### 5. Existing Sorries (3 in file)

The file has existing sorries at lines 649, 656, and 603 (in `maximal_tcs_is_mcs`). These are separate mathematical issues documented in task 888's summary - the sorries are for temporal saturation preservation proofs that appear unprovable as currently structured.

## Recommendations

### Immediate Fixes (For Task 891)

1. **Replace `split` with `cases` patterns** for all 3 Category A locations
2. **Split multi-target `split at h ⊢`** into separate operations for Category B locations
3. **Debug instance synthesis failure** at line 324 - check imports and typeclass requirements
4. **Fix type errors** at lines 394/398 after resolving earlier issues

### Conversion Pattern Reference

For `temporalWitnessChain` match expressions:

```lean
-- Pattern 1: Simple case split on extractForwardWitness
cases h : extractForwardWitness φ with
| some ψ => ...  -- forward witness exists
| none =>
  cases h' : extractBackwardWitness φ with
  | some ψ => ...  -- backward witness exists
  | none => ...     -- no witnesses

-- Pattern 2: For hypothesis splitting, use simp to unfold then match
simp only [temporalWitnessChain] at h
-- Then use rcases or obtain to destructure
```

For `henkinStep` if-expression:

```lean
-- Pattern: Replace split with if_neg/if_pos or decide
by_cases h : SetConsistent (S ∪ temporalPackage φ) with
| true => simp [henkinStep, h]; ...
| false => simp [henkinStep, h]; ...
```

### Related Tasks

- **Task 888**: Mathematical blocker - `maximal_tcs_is_mcs` appears unprovable with current construction
- **Task 892**: Modify `henkinStep` to add negations when rejecting packages (prerequisite for 888)

## References

- [Lean 4.22.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.22.0/) - `have`/`let` binding changes
- [Lean 4.27.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.27.0/) - Match splitter optimizations
- Task 888 implementation summary: `specs/888_lindenbaum_temporal_saturation_preservation/summaries/implementation-summary-20260217.md`

## Next Steps

1. Create implementation plan addressing all 8 build errors systematically
2. Start with Category A fixes (simplest - direct `cases` replacements)
3. Test after each category to isolate issues
4. Verify build compiles (with warnings for existing sorries acceptable)
