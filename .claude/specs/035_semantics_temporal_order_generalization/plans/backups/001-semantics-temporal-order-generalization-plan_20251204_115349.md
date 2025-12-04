# Semantics Temporal Order Generalization - Implementation Plan

## Metadata
- **Date**: 2025-12-04
- **Feature**: Generalize Logos temporal domain from `Int` to polymorphic `LinearOrderedAddCommGroup` typeclass matching JPL paper specification
- **Status**: [IN PROGRESS]
- **Estimated Hours**: 30-47 hours
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Research Reports**:
  - [Semantics Temporal Order Generalization Research](../reports/001-semantics-temporal-order-generalization-research.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/TaskFrame.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/Logos
- **Paper Reference**: /home/benjamin/Documents/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex (§app:TaskSemantics, lines 1835-1867)

---

## Executive Summary

This plan systematically generalizes Logos's temporal semantics from hardcoded `Int` to the polymorphic `LinearOrderedAddCommGroup` typeclass, achieving exact alignment with the JPL paper "The Perpetuity Calculus of Agency" (§app:TaskSemantics). The generalization enables support for rational/real time models, bounded temporal domains, and custom temporal structures while maintaining all existing proofs.

**Key Changes**:
1. **TaskFrame**: Add type parameter `T : Type*` with `[LinearOrderedAddCommGroup T]` constraint
2. **WorldHistory**: Add `convex` field enforcing domain convexity (paper requirement)
3. **Truth/Validity**: Update temporal quantification to use polymorphic type `T`
4. **Proofs**: Update arithmetic reasoning to use group lemmas instead of `omega`
5. **Documentation**: Update TODO.md with new Task 15 referencing paper

**Paper Alignment**:
- def:frame (line 1835): "A totally ordered abelian group T = ⟨T, +, ≤⟩"
- def:world-history (line 1849): Domain X ⊆ T must be convex
- def:BL-semantics (lines 1864-1865): Past/Future quantify over `y ∈ T`

**Breaking Changes**:
- All `TaskFrame` → `TaskFrame T` with explicit type parameter
- Convexity proofs required for all world histories
- Some arithmetic proofs may need Mathlib group lemmas

**Migration Strategy**: Provide type aliases `TaskFrameInt` and `WorldHistoryInt` for smooth backward compatibility during transition.

---

## Phase 0: Standards Validation and Type Alias Preparation [COMPLETE]
dependencies: []

**Objective**: Validate generalization against CLAUDE.md standards and prepare backward compatibility infrastructure.

**Complexity**: Low

**Tasks**:
- [x] Review LEAN Style Guide for typeclass parameter conventions
  - Goal: Confirm `(T : Type*)` vs `{T : Type*}` convention (explicit vs implicit)
  - Strategy: Check CLAUDE.md and Documentation/Development/LEAN_STYLE_GUIDE.md for typeclass guidelines
  - Complexity: Simple (documentation review)
  - Estimated: 0.5 hours

- [x] Validate Mathlib dependency for `LinearOrderedAddCommGroup`
  - Goal: Confirm `Mathlib.Algebra.Order.Group.Defs` is available in current Mathlib version
  - Strategy: Check lakefile.toml Mathlib version, verify typeclass exists via `#check`
  - Complexity: Simple (dependency verification)
  - Estimated: 0.5 hours

- [x] Design type alias compatibility layer
  - Goal: Define `abbrev TaskFrameInt := TaskFrame Int` and similar for smooth migration
  - Strategy: Create aliases in separate module for optional backward compatibility
  - Complexity: Simple (alias definitions)
  - Estimated: 1 hour

**Testing**:
```bash
# Verify Mathlib module exists
lake env lean --run <<EOF
import Mathlib.Algebra.Order.Group.Defs
#check LinearOrderedAddCommGroup
EOF

# Verify lakefile.toml Mathlib version
grep "mathlib" /home/benjamin/Documents/Philosophy/Projects/Logos/lakefile.toml
```

**Expected Duration**: 2 hours

**Success Criteria**:
- [ ] Typeclass parameter convention documented
- [ ] Mathlib `LinearOrderedAddCommGroup` verified available
- [ ] Type alias design documented (optional compatibility layer)

---

## Phase 1: TaskFrame Generalization [COMPLETE]
dependencies: [0]

**Objective**: Parameterize `TaskFrame` structure by temporal group type `T` with `LinearOrderedAddCommGroup` constraint.

**Complexity**: Medium

**File**: Logos/Semantics/TaskFrame.lean

**Theorems/Changes**:
- [x] Generalize `TaskFrame` structure definition
  - Goal: `structure TaskFrame (T : Type*) [LinearOrderedAddCommGroup T] where`
  - Strategy: Add type parameter and typeclass constraint, replace all `Int` with `T`
  - Complexity: Medium (structural change with downstream effects)
  - Estimated: 2 hours

- [x] Update `nullity` field type signature
  - Goal: `nullity : ∀ w, task_rel w 0 w` (0 is polymorphic zero from typeclass)
  - Strategy: Verify `0` resolves to typeclass zero via `OfNat` instance
  - Complexity: Simple (type signature update)
  - Estimated: 0.5 hours

- [x] Update `compositionality` field type signature
  - Goal: `compositionality : ∀ w u v (x y : T), task_rel w x u → task_rel u y v → task_rel w (x + y) v`
  - Strategy: Replace `Int` parameters with `T`, verify `+` resolves to group addition
  - Complexity: Simple (type signature update)
  - Estimated: 0.5 hours

- [x] Generalize `trivialFrame` example
  - Goal: `def trivialFrame {T : Type*} [LinearOrderedAddCommGroup T] : TaskFrame T`
  - Strategy: Make type parameter implicit, verify proofs still work
  - Complexity: Simple (add typeclass constraint)
  - Estimated: 1 hour

- [x] Generalize `identityFrame` example
  - Goal: `def identityFrame (W : Type) {T : Type*} [LinearOrderedAddCommGroup T] : TaskFrame T`
  - Strategy: Add typeclass constraint, update proofs using group lemmas
  - Complexity: Medium (proof may need group lemmas instead of `omega`)
  - Estimated: 2 hours

- [x] Generalize `natFrame` example
  - Goal: `def natFrame {T : Type*} [LinearOrderedAddCommGroup T] : TaskFrame T`
  - Strategy: Make type parameter implicit, verify proofs still work
  - Complexity: Simple (add typeclass constraint)
  - Estimated: 1 hour

- [x] Update module docstring to reference paper definition
  - Goal: Document exact correspondence with JPL paper def:frame (line 1835)
  - Strategy: Update docstring lines 3-48 to mention `LinearOrderedAddCommGroup` and paper alignment
  - Complexity: Simple (documentation update)
  - Estimated: 0.5 hours

**Testing**:
```bash
# Build TaskFrame module
lake build Logos.Semantics.TaskFrame

# Verify no errors
lake env lean Logos/Semantics/TaskFrame.lean

# Check example frames compile with Int
lake env lean --run <<EOF
import Logos.Semantics.TaskFrame
open Logos.Semantics
#check @TaskFrame.trivialFrame Int _
#check @TaskFrame.natFrame Int _
EOF
```

**Expected Duration**: 8 hours

**Success Criteria**:
- [ ] `TaskFrame` structure has type parameter `T` with `LinearOrderedAddCommGroup` constraint
- [ ] All `Int` occurrences replaced with `T`
- [ ] All example frames generalized and compile
- [ ] `lake build Logos.Semantics.TaskFrame` succeeds
- [ ] Docstring references JPL paper def:frame

---

## Phase 2: WorldHistory Generalization and Convexity [COMPLETE]
dependencies: [1]

**Objective**: Generalize `WorldHistory` structure and add convexity constraint matching paper definition.

**Complexity**: High

**File**: Logos/Semantics/WorldHistory.lean

**Theorems/Changes**:
- [x] Generalize `WorldHistory` structure definition
  - Goal: `structure WorldHistory {T : Type*} [LinearOrderedAddCommGroup T] (F : TaskFrame T) where`
  - Strategy: Add implicit type parameter, update `TaskFrame` reference to `TaskFrame T`
  - Complexity: Medium (structural change)
  - Estimated: 1 hour

- [x] Add `convex` field to `WorldHistory`
  - Goal: `convex : ∀ (x z : T), domain x → domain z → ∀ (y : T), x ≤ y → y ≤ z → domain y`
  - Strategy: Add field enforcing convexity constraint from paper (def:world-history, line 1849)
  - Complexity: Medium (new constraint with proof obligations)
  - Estimated: 2 hours

- [x] Update `respects_task` field type signature
  - Goal: Replace `Int` with `T` throughout, ensure `(t - s)` uses group subtraction
  - Strategy: Update parameter types, verify group subtraction via `LinearOrderedAddCommGroup`
  - Complexity: Simple (type signature update)
  - Estimated: 0.5 hours

- [x] Prove convexity for `trivial` history
  - Goal: `convex := fun x z _ _ y _ _ => True.intro` (full domain is trivially convex)
  - Strategy: Full domain satisfies convexity by definition
  - Complexity: Simple (trivial proof)
  - Estimated: 0.5 hours

- [x] Prove convexity for `universal_trivialFrame`
  - Goal: Add convexity proof to `universal_trivialFrame` constructor
  - Strategy: Full domain is convex (same as `trivial`)
  - Complexity: Simple (trivial proof)
  - Estimated: 0.5 hours

- [x] Prove convexity for `universal_natFrame`
  - Goal: Add convexity proof to `universal_natFrame` constructor
  - Strategy: Full domain is convex
  - Complexity: Simple (trivial proof)
  - Estimated: 0.5 hours

- [x] Update `universal` helper with convexity proof
  - Goal: Add convexity parameter to `universal` function signature
  - Strategy: Require caller to prove domain is convex
  - Complexity: Medium (API change)
  - Estimated: 1 hour

- [x] Prove convexity preservation for `time_shift`
  - Goal: `theorem time_shift_preserves_convex : σ.convex → (time_shift σ Δ).convex`
  - Strategy: Show that shifting preserves intervals (use order preservation of addition)
  - Complexity: Medium (non-trivial theorem using group properties)
  - Estimated: 3 hours

- [x] Update all time-shift lemmas to use polymorphic type
  - Goal: Replace `Int` with `T` in `time_shift_domain_iff`, `time_shift_inverse_domain`, etc.
  - Strategy: Mechanical replacement, verify proofs use group lemmas instead of `omega`
  - Complexity: Medium (10+ lemmas to update, some proofs need group lemmas)
  - Estimated: 4 hours

- [x] Update order reversal lemmas (neg_lt_neg_iff, etc.)
  - Goal: Generalize from `Int` negation to group inverse in `LinearOrderedAddCommGroup`
  - Strategy: Replace `Int.neg` with group inverse `-`, use Mathlib lemmas for order reversal
  - Complexity: Medium (order theory in abstract groups)
  - Estimated: 2 hours

- [x] Update module docstring to reference paper convexity requirement
  - Goal: Document that convexity constraint matches JPL paper def:world-history (line 1849)
  - Strategy: Update docstring lines 3-45 to emphasize convexity enforcement
  - Complexity: Simple (documentation update)
  - Estimated: 0.5 hours

**Testing**:
```bash
# Build WorldHistory module
lake build Logos.Semantics.WorldHistory

# Verify no errors
lake env lean Logos/Semantics/WorldHistory.lean

# Check time_shift preserves convexity
lake env lean --run <<EOF
import Logos.Semantics.WorldHistory
open Logos.Semantics
variable {T : Type*} [LinearOrderedAddCommGroup T] {F : TaskFrame T}
variable (σ : WorldHistory F) (Δ : T)
#check time_shift_preserves_convex σ Δ
EOF
```

**Expected Duration**: 15 hours

**Success Criteria**:
- [ ] `WorldHistory` has implicit type parameter `{T : Type*}` with typeclass constraint
- [ ] `convex` field added to structure
- [ ] All example histories have convexity proofs
- [ ] `time_shift_preserves_convex` theorem proven
- [ ] All time-shift lemmas use polymorphic type `T`
- [ ] Order reversal lemmas generalized to group inverse
- [ ] `lake build Logos.Semantics.WorldHistory` succeeds
- [ ] Docstring references paper convexity requirement

---

## Phase 3: Truth Evaluation Generalization [COMPLETE]
dependencies: [2]

**Objective**: Update truth evaluation to use polymorphic temporal type in Past/Future quantification.

**Complexity**: Medium-High

**File**: Logos/Semantics/Truth.lean

**Theorems/Changes**:
- [x] Generalize `truth_at` function signature
  - Goal: `def truth_at {T : Type*} [LinearOrderedAddCommGroup T] (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t) : Formula → Prop`
  - Strategy: Add implicit type parameter, update time parameter to `t : T`
  - Complexity: Medium (structural change)
  - Estimated: 1 hour

- [x] Update Past operator quantification
  - Goal: `| Formula.past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ`
  - Strategy: Replace `Int` with `T`, verify order `<` from `LinearOrder` parent
  - Complexity: Simple (type signature update)
  - Estimated: 0.5 hours

- [x] Update Future operator quantification
  - Goal: `| Formula.future φ => ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ`
  - Strategy: Replace `Int` with `T`, verify order `<` from `LinearOrder` parent
  - Complexity: Simple (type signature update)
  - Estimated: 0.5 hours

- [x] Update `time_shift_preserves_truth` theorem
  - Goal: Generalize theorem to work with polymorphic `T`
  - Strategy: Replace `omega` proofs with group lemmas from Mathlib (`add_le_add_right`, `add_sub_cancel`)
  - Complexity: High (complex proof using arithmetic, needs group lemmas)
  - Estimated: 4 hours

- [x] Update temporal duality infrastructure
  - Goal: Generalize `axiom_swap`, `formula_swap` to use polymorphic time
  - Strategy: Update time reversal to use group inverse instead of `Int.neg`
  - Complexity: Medium (order reversal with abstract groups)
  - Estimated: 2 hours

- [x] Update all truth preservation lemmas
  - Goal: Generalize helper lemmas (truth_at_monotone, etc.) to polymorphic time
  - Strategy: Mechanical replacement of `Int` with `T`, update proofs
  - Complexity: Medium (multiple lemmas to update)
  - Estimated: 2 hours

**Testing**:
```bash
# Build Truth module
lake build Logos.Semantics.Truth

# Verify no errors
lake env lean Logos/Semantics/Truth.lean

# Check truth_at compiles with different time types
lake env lean --run <<EOF
import Logos.Semantics.Truth
open Logos.Semantics
#check @truth_at Int _
#check @truth_at Rat _
#check @truth_at Real _
EOF

# Run existing tests with Int
lake test LogosTest.Semantics.TruthTest
```

**Expected Duration**: 10 hours

**Success Criteria**:
- [ ] `truth_at` has implicit type parameter `{T : Type*}` with typeclass constraint
- [ ] Past/Future quantification uses `∀ (s : T)`
- [ ] `time_shift_preserves_truth` proven with group lemmas
- [ ] Temporal duality uses group inverse for time reversal
- [ ] All helper lemmas generalized
- [ ] `lake build Logos.Semantics.Truth` succeeds
- [ ] All existing tests pass with `Int` instance

---

## Phase 4: Validity and Model Generalization [NOT STARTED]
dependencies: [3]

**Objective**: Update validity definitions and model structures to quantify over all temporal types.

**Complexity**: Low-Medium

**Files**:
- Logos/Semantics/Validity.lean
- Logos/Semantics/TaskModel.lean

**Theorems/Changes**:
- [ ] Generalize `valid` definition
  - Goal: `def valid (φ : Formula) : Prop := ∀ {T : Type*} [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t), truth_at M τ t ht φ`
  - Strategy: Add universal quantification over temporal types
  - Complexity: Simple (definition update)
  - Estimated: 0.5 hours

- [ ] Generalize `semantic_consequence` definition
  - Goal: Update to quantify over all temporal types
  - Strategy: Mirror `valid` generalization
  - Complexity: Simple (definition update)
  - Estimated: 0.5 hours

- [ ] Generalize `satisfiable` definition
  - Goal: Update to use polymorphic temporal type
  - Strategy: Replace `Int` with existentially quantified `T`
  - Complexity: Simple (definition update)
  - Estimated: 0.5 hours

- [ ] Update `TaskModel` structure (if needed)
  - Goal: Verify `TaskModel` inherits type parameter from `TaskFrame`
  - Strategy: Check if structural changes needed for polymorphism
  - Complexity: Simple (likely no changes needed)
  - Estimated: 0.5 hours

- [ ] Verify all validity lemmas still hold
  - Goal: Ensure existing validity theorems compile with generalized definitions
  - Strategy: Run `lake build` and fix any type inference issues
  - Complexity: Low-Medium (may need explicit type parameters)
  - Estimated: 2 hours

**Testing**:
```bash
# Build Validity module
lake build Logos.Semantics.Validity

# Build TaskModel module
lake build Logos.Semantics.TaskModel

# Verify polymorphic validity works
lake env lean --run <<EOF
import Logos.Semantics.Validity
open Logos.Semantics
-- Check validity definition is polymorphic
#check @valid
EOF

# Run existing validity tests
lake test LogosTest.Semantics.ValidityTest
```

**Expected Duration**: 4 hours

**Success Criteria**:
- [ ] `valid` quantifies over all temporal types `T`
- [ ] `semantic_consequence` quantifies over all temporal types
- [ ] `satisfiable` uses polymorphic temporal type
- [ ] All validity lemmas compile and type-check
- [ ] `lake build Logos.Semantics` succeeds
- [ ] All existing semantic tests pass

---

## Phase 5: Example Temporal Structures [NOT STARTED]
dependencies: [4]

**Objective**: Create examples demonstrating use of different temporal types (Rat, Real, custom bounded).

**Complexity**: Low

**Files**:
- Archive/TemporalStructures.lean (new file)

**Theorems/Changes**:
- [ ] Create rational time example frame
  - Goal: `def rationalTimeFrame : TaskFrame Rat`
  - Strategy: Instantiate frame with `Rat` (rational numbers) as temporal type
  - Complexity: Simple (example instantiation)
  - Estimated: 1 hour

- [ ] Create real time example frame
  - Goal: `def realTimeFrame : TaskFrame Real`
  - Strategy: Instantiate frame with `Real` (real numbers) as temporal type
  - Complexity: Simple (example instantiation)
  - Estimated: 1 hour

- [ ] Create bounded integer time example
  - Goal: Define custom bounded time structure with `LinearOrderedAddCommGroup` instance
  - Strategy: Use `Fin n` or subtype of `Int` with custom group instance
  - Complexity: Medium (custom typeclass instance)
  - Estimated: 3 hours

**Testing**:
```bash
# Build examples module
lake build Archive.TemporalStructures

# Verify examples type-check
lake env lean Archive/TemporalStructures.lean

# Test rational time frame
lake env lean --run <<EOF
import Archive.TemporalStructures
#check rationalTimeFrame
EOF
```

**Expected Duration**: 5 hours

**Success Criteria**:
- [ ] `rationalTimeFrame` example created and compiles
- [ ] `realTimeFrame` example created and compiles
- [ ] Bounded time example with custom group instance created
- [ ] All examples in Archive/TemporalStructures.lean compile
- [ ] Docstrings explain use cases for each temporal structure

---

## Phase 6: Test Suite Update [NOT STARTED]
dependencies: [4]

**Objective**: Update existing test suite to explicitly use `Int` instance and add tests for polymorphism.

**Complexity**: Low-Medium

**Files**:
- LogosTest/Semantics/TaskFrameTest.lean
- LogosTest/Semantics/WorldHistoryTest.lean
- LogosTest/Semantics/TruthTest.lean
- LogosTest/Semantics/ValidityTest.lean

**Theorems/Changes**:
- [ ] Update TaskFrame tests to use explicit `Int` instance
  - Goal: Add `@TaskFrame Int _` annotations where type inference needs help
  - Strategy: Fix any test compilation errors from generalization
  - Complexity: Simple (mechanical fixes)
  - Estimated: 1 hour

- [ ] Add convexity tests for WorldHistory
  - Goal: Test that non-convex domains are rejected (if validation added)
  - Strategy: Create test cases with gaps in domain, verify convexity constraint
  - Complexity: Medium (new test category)
  - Estimated: 2 hours

- [ ] Add polymorphic time tests
  - Goal: Test that semantic definitions work with `Rat` and `Real` time
  - Strategy: Create small examples with rational/real time, verify truth evaluation
  - Complexity: Medium (new test category)
  - Estimated: 2 hours

- [ ] Update time-shift tests
  - Goal: Verify time-shift lemmas work with polymorphic time
  - Strategy: Test with `Int`, `Rat`, `Real` instances
  - Complexity: Low (existing tests with type variations)
  - Estimated: 1 hour

**Testing**:
```bash
# Run all semantic tests
lake test LogosTest.Semantics

# Verify convexity tests
lake test LogosTest.Semantics.WorldHistoryTest

# Check polymorphic time tests
lake test LogosTest.Semantics.TruthTest
```

**Expected Duration**: 6 hours

**Success Criteria**:
- [ ] All existing tests compile and pass with `Int` instance
- [ ] Convexity tests added and passing
- [ ] Polymorphic time tests added (Rat, Real) and passing
- [ ] Time-shift tests work with different temporal types
- [ ] `lake test LogosTest.Semantics` succeeds with zero failures

---

## Phase 7: Documentation Update [NOT STARTED]
dependencies: [6]

**Objective**: Update all documentation to reflect generalized temporal semantics and paper alignment.

**Complexity**: Low

**Files**:
- CLAUDE.md
- Documentation/UserGuide/ARCHITECTURE.md
- Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
- Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
- TODO.md

**Tasks**:
- [ ] Update CLAUDE.md Semantics Package section
  - Goal: Document `LinearOrderedAddCommGroup` typeclass and paper alignment
  - Strategy: Update lines 59-69 to mention polymorphic temporal type
  - Complexity: Simple (documentation update)
  - Estimated: 0.5 hours

- [ ] Update ARCHITECTURE.md Task Semantics section
  - Goal: Explain polymorphic temporal order and typeclass hierarchy
  - Strategy: Add section on `LinearOrderedAddCommGroup` and standard instances
  - Complexity: Simple (documentation update)
  - Estimated: 1 hour

- [ ] Update IMPLEMENTATION_STATUS.md Semantics module status
  - Goal: Mark temporal generalization as complete, update completion percentages
  - Strategy: Update Semantics module section with generalization notes
  - Complexity: Simple (status update)
  - Estimated: 0.5 hours

- [ ] Remove temporal limitation from KNOWN_LIMITATIONS.md
  - Goal: Delete "Temporal Domain Limitation" section (issue resolved)
  - Strategy: Remove lines documenting Int hardcoding limitation
  - Complexity: Simple (remove obsolete limitation)
  - Estimated: 0.5 hours

- [ ] Update TODO.md Task 15 status
  - Goal: Mark Task 15 as COMPLETE with completion date
  - Strategy: Update task status, add to Completion Log, update progress percentages
  - Complexity: Simple (task tracking update)
  - Estimated: 0.5 hours

- [ ] Create migration guide in ARCHITECTURE.md
  - Goal: Document how to update existing code using `TaskFrame` → `TaskFrame T`
  - Strategy: Add "Temporal Generalization Migration" section with examples
  - Complexity: Simple (documentation with examples)
  - Estimated: 1 hour

**Testing**:
```bash
# Verify documentation links work
grep -r "TaskFrame.lean" Documentation/
grep -r "LinearOrderedAddCommGroup" Documentation/

# Check TODO.md format
grep "Task 15" TODO.md
```

**Expected Duration**: 4 hours

**Success Criteria**:
- [ ] CLAUDE.md updated to document polymorphic temporal type
- [ ] ARCHITECTURE.md explains `LinearOrderedAddCommGroup` and standard instances
- [ ] IMPLEMENTATION_STATUS.md marks Semantics generalization complete
- [ ] KNOWN_LIMITATIONS.md temporal limitation section removed
- [ ] TODO.md Task 15 marked COMPLETE
- [ ] Migration guide added to ARCHITECTURE.md
- [ ] All documentation cross-references updated

---

## Phase 8: TODO.md Task Creation [NOT STARTED]
dependencies: [7]

**Objective**: Update TODO.md to document completed Task 15 and ensure paper reference is included.

**Complexity**: Low

**File**: TODO.md

**Tasks**:
- [ ] Verify Task 15 entry exists and is properly formatted
  - Goal: Confirm Task 15 includes paper reference and correct metadata
  - Strategy: Check lines 133-204 of TODO.md for Task 15 specification
  - Complexity: Simple (verification)
  - Estimated: 0.25 hours

- [ ] Add completion entry to Completion Log
  - Goal: Add entry to table at line ~818 documenting Task 15 completion
  - Strategy: Add row with date, task name, and completion notes
  - Complexity: Simple (log entry)
  - Estimated: 0.25 hours

- [ ] Update Status Summary percentages
  - Goal: Update Low Priority task completion percentage (currently 0/5 = 0%)
  - Strategy: Change to 1/5 = 20% for Low Priority tasks
  - Complexity: Simple (percentage update)
  - Estimated: 0.25 hours

- [ ] Update Sorry Placeholder Registry if applicable
  - Goal: Remove any sorry entries resolved by generalization
  - Strategy: Check if any sorries in Semantics modules were resolved
  - Complexity: Simple (registry update)
  - Estimated: 0.25 hours

**Testing**:
```bash
# Verify TODO.md format
grep "Task 15" TODO.md
grep "Completion Log" TODO.md

# Check paper reference exists
grep "possible_worlds.tex" TODO.md
```

**Expected Duration**: 1 hour

**Success Criteria**:
- [ ] Task 15 entry verified with paper reference
- [ ] Completion Log entry added with date
- [ ] Status Summary percentages updated
- [ ] Sorry registry updated if applicable
- [ ] TODO.md format validated

---

## Rollback Strategy

If generalization causes unexpected issues, rollback in reverse phase order:

**Phase Rollback Order**:
1. **Phase 8**: Revert TODO.md changes (no code changes)
2. **Phase 7**: Revert documentation (no code changes)
3. **Phase 6**: Remove new tests (keep existing tests)
4. **Phase 5**: Delete Archive/TemporalStructures.lean (optional examples)
5. **Phase 4**: Revert Validity.lean and TaskModel.lean to `Int`
6. **Phase 3**: Revert Truth.lean to `Int`
7. **Phase 2**: Revert WorldHistory.lean to `Int`, remove convexity field
8. **Phase 1**: Revert TaskFrame.lean to `Int`

**Rollback Verification**:
```bash
# Verify original Int-based code compiles
git checkout HEAD~N Logos/Semantics/
lake build Logos.Semantics
lake test LogosTest.Semantics

# Confirm all tests pass
echo "Rollback successful if build and tests pass"
```

**Rollback Triggers**:
- Type inference failures preventing compilation
- Proof obligations become prohibitively complex
- Performance degradation in proof checking
- Breaking changes to existing proofs that cannot be easily fixed

---

## Wave Structure (Parallel Execution Opportunities)

**Wave 1** (Independent foundations):
- Phase 0: Standards Validation (2 hours)
- Phase 1: TaskFrame Generalization (8 hours)

**Wave 2** (Sequential dependency chain):
- Phase 2: WorldHistory Generalization (15 hours) [depends on Phase 1]
- Phase 3: Truth Evaluation (10 hours) [depends on Phase 2]
- Phase 4: Validity/Model (4 hours) [depends on Phase 3]

**Wave 3** (Parallel completion):
- Phase 5: Example Structures (5 hours) [depends on Phase 4]
- Phase 6: Test Suite Update (6 hours) [depends on Phase 4]

**Wave 4** (Documentation):
- Phase 7: Documentation Update (4 hours) [depends on Phases 5, 6]
- Phase 8: TODO.md Task Creation (1 hour) [depends on Phase 7]

**Total Sequential Time**: 55 hours
**Total Parallel Time**: 30-35 hours (with Wave 3 parallelization)
**Time Savings**: ~36-45% with parallelization

---

## Risk Analysis

**High Risk Areas**:
1. **Proof Complexity**: `time_shift_preserves_truth` may require deep group theory lemmas
   - Mitigation: Budget extra time for Mathlib lemma discovery
   - Fallback: Add axiom placeholders for complex proofs, resolve later

2. **Type Inference**: Polymorphic types may cause inference failures
   - Mitigation: Add explicit type annotations `@TaskFrame Int _` as needed
   - Fallback: Use type aliases for common cases

3. **Breaking Changes**: Downstream code may break unexpectedly
   - Mitigation: Phase-by-phase testing, rollback plan ready
   - Fallback: Pause at each phase if compilation fails

**Medium Risk Areas**:
1. **Convexity Proofs**: New constraint adds proof obligations
   - Mitigation: Start with trivial full-domain examples
   - Fallback: Make convexity optional with default `True` implementation

2. **Group Lemma Discovery**: Finding right Mathlib lemmas may take time
   - Mitigation: Use `#check`, `exact?`, and library_search
   - Fallback: Ask for Mathlib experts on Zulip

**Low Risk Areas**:
1. **Documentation**: No code dependencies, easy to update
2. **Examples**: Optional demonstrations, not critical path
3. **Tests**: Can be added incrementally after core generalization

---

## Success Metrics

**Quantitative**:
- [ ] Zero `sorry` placeholders in generalized modules
- [ ] 100% of existing Semantics tests pass with `Int` instance
- [ ] At least 3 new polymorphic time examples (Int, Rat, Real)
- [ ] At least 5 new convexity tests added
- [ ] `lake build` completes in <3 minutes (no performance degradation)

**Qualitative**:
- [ ] Code directly mirrors JPL paper mathematical definitions
- [ ] Type signatures are clear and self-documenting
- [ ] Migration path is straightforward for existing code
- [ ] Documentation explains typeclass hierarchy and paper alignment
- [ ] Examples demonstrate practical benefits of generalization

---

## References

**Paper**:
- JPL Paper "The Perpetuity Calculus of Agency" §app:TaskSemantics
  - def:frame (line 1835): Totally ordered abelian group T
  - def:world-history (line 1849): Convex domain X ⊆ T
  - def:BL-semantics (lines 1864-1865): Past/Future quantification over T

**Mathlib**:
- `Mathlib.Algebra.Order.Group.Defs`: `LinearOrderedAddCommGroup` typeclass
- Standard instances: `Int`, `Rat`, `Real` with `LinearOrderedAddCommGroup`

**Logos Documentation**:
- CLAUDE.md: Project standards and structure
- ARCHITECTURE.md: Task semantics specification
- KNOWN_LIMITATIONS.md: Current temporal domain limitation (to be removed)
- TODO.md: Task 15 tracking

**Research Reports**:
- [Semantics Temporal Order Generalization Research](../reports/001-semantics-temporal-order-generalization-research.md): Detailed discrepancy analysis and Mathlib typeclass verification
