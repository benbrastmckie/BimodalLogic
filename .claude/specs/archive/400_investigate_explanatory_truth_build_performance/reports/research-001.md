# Research Report: Task #400

**Task**: Investigate Explanatory/Truth.lean build performance
**Date**: 2026-01-11
**Focus**: Identify performance bottlenecks and optimization opportunities

## Summary

Investigation reveals multiple likely causes for slow builds: (1) extensive type class hierarchy from `LinearOrderedAddCommGroup T` causing exponential instance search, (2) a `mutual` block with `verifies`/`falsifies` in Foundation/Semantics.lean, (3) large recursive definition with 17+ pattern cases in `truthAt`, and (4) complex dependent types with proof terms (`ht : t ∈ τ.domain`). The file currently has a namespace error preventing builds, but these structural issues will cause performance problems once fixed.

## Findings

### 1. Type Class Hierarchy Issues

**Location**: Truth.lean:36, Frame.lean:36, Frame.lean:42

The file uses `LinearOrderedAddCommGroup T` which is a deep type class hierarchy in Mathlib:
```lean
variable {T : Type*} [LinearOrderedAddCommGroup T]
```

This hierarchy includes:
- `LinearOrderedAddCommGroup` → `OrderedAddCommGroup` → `AddCommGroup` → `AddGroup` → `AddMonoid` → ...
- Multiple inheritance paths to `Preorder`, `PartialOrder`, `Zero`, etc.

**Performance Impact**: According to [Lean 4 Issue #2055](https://github.com/leanprover/lean4/issues/2055), diamond inheritance patterns cause exponential instance synthesis attempts. Each failed instance synthesis takes ~0.001 seconds but multiplied by 500+ attempts creates 0.5+ second delays per typeclass query.

### 2. Mutual Recursion in Foundation

**Location**: Foundation/Semantics.lean:47-139

The `verifies` and `falsifies` functions are defined in a `mutual` block with 9 cases each:
```lean
mutual
def verifies (M : ConstitutiveModel) ... : ConstitutiveFormula → Prop
def falsifies (M : ConstitutiveModel) ... : ConstitutiveFormula → Prop
end
```

**Performance Impact**: Per [Lean 4 mutual recursion documentation](https://lean-lang.org/blog/2024-1-11-recursive-definitions-in-lean/), mutual recursion elaborates into well-founded recursion which:
- Has poor definitional equality
- Can be expensive with many inductives
- Generates large proof terms that are slow to reduce

### 3. Large Match Expression in truthAt

**Location**: Truth.lean:99-182

The `truthAt` function has 17 pattern match cases, each involving:
- Recursive calls to `truthAt`
- Complex type expressions with dependent proofs
- Quantifiers over `WorldHistory`, time domains, and states

**Performance Impact**: According to [Lean 4.23.0 release notes](https://lean-lang.org/doc/reference/latest/releases/v4.23.0/), match expressions with many cases (especially those generating equation lemmas) can cause significant slowdowns.

### 4. Dependent Types with Proof Carrying

**Location**: Truth.lean:99-101

The function signature requires proof terms:
```lean
def truthAt ... (t : T) (ht : t ∈ τ.domain) ... : Formula → Prop
```

Every recursive call must construct or thread these proof terms, which:
- Increases elaboration complexity
- Makes definitional reduction expensive
- Creates larger proof terms in the kernel

### 5. CompleteLattice Instances

**Location**: Frame.lean:51-54

```lean
structure ConstitutiveFrame where
  State : Type*
  [lattice : CompleteLattice State]

attribute [instance] ConstitutiveFrame.lattice
```

`CompleteLattice` is another deep hierarchy in Mathlib that can cause instance search delays.

### 6. Current Build Blocker (Secondary Issue)

**Location**: Syntax.lean:34

```lean
open Logos.Foundation  -- Should be: open Logos.SubTheories.Foundation
```

This namespace error prevents the file from building at all. However, this is unrelated to performance and is a simple bug fix.

## Recommendations

### Immediate Fixes

1. **Fix namespace error** in Syntax.lean:34 - change `Logos.Foundation` to `Logos.SubTheories.Foundation`

### Performance Optimizations

1. **Add `@[irreducible]` to `truthAt`**: Mark the definition as irreducible to prevent expensive unfolding:
   ```lean
   @[irreducible]
   def truthAt ...
   ```

2. **Consider `partial` or structural recursion**: If well-founded recursion is being inferred, consider restructuring to use structural recursion on Formula:
   ```lean
   partial def truthAt ...  -- If proofs about it aren't needed
   ```

3. **Split type class constraints**: Use more specific constraints where possible instead of full `LinearOrderedAddCommGroup`:
   ```lean
   variable {T : Type*} [AddGroup T] [LinearOrder T] [CovariantClass T T (·+·) (·≤·)]
   ```

4. **Cache type class instances**: Add explicit instance arguments where type class inference is slow:
   ```lean
   def truthAt (M : CoreModel T) (τ : WorldHistory M.frame)
       (inst : CompleteLattice M.frame.State := inferInstance) ...
   ```

5. **Increase heartbeat limits** for files that need it:
   ```lean
   set_option synthInstance.maxHeartbeats 100000
   ```

6. **Refactor mutual recursion**: Consider restructuring `verifies`/`falsifies` to avoid mutual recursion:
   - Use a single function with a `Bool` flag for verify/falsify mode
   - Or use an indexed inductive family

### Build Configuration

7. **Check Mathlib version**: The project uses Mathlib v4.14.0; newer versions (4.22+) include significant compiler and instance caching improvements

8. **Use lake clean selectively**: Build artifacts may be stale; try `lake clean` followed by rebuild

## References

- [Typeclass inference performance issue #2055](https://github.com/leanprover/lean4/issues/2055)
- [Recursive definitions in Lean](https://lean-lang.org/blog/2024-1-11-recursive-definitions-in-lean/)
- [Lean 4.23.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.23.0/)
- [Lean 4.24.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.24.0/) - 21 performance improvements
- [Mutual recursion elaboration](https://pixel-druid.com/articles/mutual-recursion-elaboration-in-lean)

## Next Steps

1. Fix the namespace bug in Syntax.lean first (prerequisite for any performance testing)
2. Run actual timing measurements with `set_option profiler true`
3. Add `@[irreducible]` to `truthAt` and `verifies`/`falsifies`
4. Consider upgrading Mathlib to benefit from recent performance improvements
5. If still slow, profile with `set_option trace.profiler true` to identify specific bottlenecks
