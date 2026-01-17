# Implementation Plan: Add Property-Based Testing Framework and Metalogic Tests

**Project**: #174  
**Version**: 001  
**Date**: 2025-12-24  
**Complexity**: Moderate  
**Language**: lean  
**Status**: [COMPLETED]  
**Started**: 2025-12-24  
**Completed**: 2025-12-25

---

## Task Description

Integrate Plausible property-based testing framework and implement comprehensive property tests for:
1. Metalogic properties (soundness, consistency)
2. Derivation properties (weakening, cut, substitution)
3. Semantic properties (frame properties, truth conditions)
4. Formula transformation properties (NNF, CNF idempotence)

This task enhances the existing test infrastructure with property-based testing to automatically generate test cases and find edge cases across a wide range of inputs.

---

## Research Inputs

This implementation plan is based on comprehensive research completed on 2025-12-24:

### Primary Research Artifacts

1. **Main Research Report**: `specs/174_property_based_testing/reports/research-001.md`
   - Comprehensive analysis of Plausible framework
   - Integration strategies and best practices
   - Generator patterns and property test patterns
   - 374 lines of detailed findings

2. **Research Summary**: `specs/174_property_based_testing/summaries/research-summary.md`
   - Key findings and recommendations
   - Quick reference for implementation

3. **Detailed Findings**: `docs/research/property-based-testing-lean4.md`
   - 986 lines of comprehensive documentation
   - Complete API reference and examples
   - Integration guide and best practices

### Key Research Findings

1. **Plausible is the only mature framework**: Active maintenance (74 stars, 16 forks), production-ready
2. **Excellent Lean integration**: Tactic (`plausible`) and command (`#test`) interfaces
3. **Automatic derivation**: `deriving Arbitrary` for custom types with automatic shrinking
4. **No external dependencies**: Pure Lean implementation
5. **Integration effort**: 6-10 hours for basic setup + core tests (research estimate)

### Technology Stack (from Research)

- **Framework**: Plausible (https://github.com/leanprover-community/plausible)
- **Integration**: Already in lakefile.lean
- **Type Classes**: Arbitrary, Shrinkable, SampleableExt, Testable
- **Configuration**: numInst, maxSize, numRetries, traceShrink, randomSeed

---

## Complexity Assessment

**Level**: Moderate  
**Estimated Effort**: 18-23 hours (validated by complexity analysis)

### Breakdown
- [PASS] Basic infrastructure setup: 2-3 hours (COMPLETED - Plausible integrated, generators exist)
- TaskModel generator implementation: 4-6 hours
- Property test enhancement: 8-10 hours (4 test files)
- Documentation updates: 2-3 hours
- CI/CD integration: 2-3 hours
- Testing and debugging: 2-3 hours

### Required Knowledge Areas

1. **Lean 4 Property-Based Testing** (Critical)
   - Plausible framework API and type classes
   - Generator combinators and size control
   - Testable properties and decidability

2. **Dependent Type Generators** (High)
   - Generating values with invariants
   - Proxy type patterns for complex structures

3. **Modal/Temporal Logic** (High)
   - TM logic semantics
   - Metalogic properties
   - Derivation system properties

4. **Lean 4 Metaprogramming** (Medium)
   - Type class resolution
   - Decidability instances

5. **Testing Theory** (Medium)
   - Property selection strategies
   - Shrinking strategies

### Potential Challenges

1. **TaskModel Generator Complexity** [WARN] HIGH RISK
   - Dependent types (valuation depends on WorldState)
   - Mitigation: Use SampleableExt with proxy pattern
   - Estimated effort: 3-4 hours

2. **Decidability Requirements** [WARN] MEDIUM RISK
   - Properties must be decidable (e.g., `Derivable Γ φ` is not)
   - Mitigation: Test specific axiom instances
   - Estimated effort: 2-3 hours

3. **Generator Performance** [WARN] MEDIUM RISK
   - Recursive generation can be slow
   - Mitigation: Size control and tuning
   - Estimated effort: 1-2 hours

4. **Shrinking Strategy** [WARN] LOW-MEDIUM RISK
   - Complex formulas may not shrink well
   - Mitigation: Formula shrinking already implemented
   - Estimated effort: 2-3 hours

---

## Technology Stack

### Languages
- Lean 4 (lean-toolchain: leanprover/lean4:v4.14.0)

### Frameworks
- **Plausible**: Property-based testing framework (main branch)
  - Repository: https://github.com/leanprover-community/plausible
  - Status: Already in lakefile.lean
  - License: Apache 2.0

### Tools
- Lake: Lean build system
- doc-gen4: Documentation generation (for examples)

### Dependencies

**External:**
- Plausible (already in lakefile.lean)
- Mathlib4 v4.14.0 (already in lakefile.lean)

**Internal:**
- Logos.Core.Syntax (Formula, Context)
- Logos.Core.ProofSystem (Derivation, Axioms)
- Logos.Core.Semantics (TaskFrame, TaskModel, Truth, Validity)
- Logos.Core.Metalogic (Soundness, DeductionTheorem)
- LogosTest.Core.Property.Generators (existing generators)

---

## Dependencies

### Required Modules

**Core Logos Modules:**
- [PASS] `Logos.Core.Syntax.Formula` - Formula type with 6 constructors
- [PASS] `Logos.Core.Syntax.Context` - Context (List Formula)
- [PASS] `Logos.Core.ProofSystem.Derivation` - Derivation rules
- [PASS] `Logos.Core.ProofSystem.Axioms` - Axiom schemas
- [PASS] `Logos.Core.Semantics.TaskFrame` - Frame structure
- [PASS] `Logos.Core.Semantics.TaskModel` - Model structure
- [PASS] `Logos.Core.Semantics.Truth` - Truth conditions
- [PASS] `Logos.Core.Semantics.Validity` - Validity definitions
- [PASS] `Logos.Core.Metalogic.Soundness` - Soundness theorem
- [PASS] `Logos.Core.Metalogic.DeductionTheorem` - Deduction theorem

**Test Infrastructure:**
- [PASS] `LogosTest.Core.Property.Generators` - Existing generators
- [PASS] `LogosTest.Core.Property.README` - Testing patterns

**External Libraries:**
- [PASS] Plausible framework (type classes: Arbitrary, Shrinkable, SampleableExt, Testable)
- [PASS] Mathlib4 (supporting utilities)

### Prerequisites

**Completed:**
- [PASS] Plausible dependency added to lakefile.lean
- [PASS] Basic generators for Formula, Context, TaskFrame
- [PASS] Property test directory structure
- [PASS] README.md with testing patterns

**To Implement:**
- TaskModel generator (main work item)
- Enhanced property tests (4 files)
- CI/CD integration

### Library Functions

**Plausible Type Classes:**
- `Arbitrary α` - Random value generation
- `Shrinkable α` - Shrinking counterexamples
- `SampleableExt α` - Complex generators with proxy types
- `Testable p` - Testable properties

**Plausible Generators:**
- `Gen.sized` - Size-controlled generation
- `Gen.oneOf` - Choose from list of generators
- `Gen.resize` - Resize for subterms
- `Gen.choose` - Choose natural number in range

**Plausible Commands:**
- `#test` - Run property test
- `Testable.check` - Run with configuration
- `Configuration` - Test parameters (numInst, maxSize, etc.)

---

## Implementation Steps

### Phase 1: Infrastructure Validation and Setup
**Effort**: 1-2 hours  
**Status**: [COMPLETED]

**Action**: Validate existing infrastructure and set up CI/CD foundation

**Files**:
- `lakefile.lean` (verify Plausible dependency)
- `LogosTest/Core/Property/Generators.lean` (review existing generators)
- `.github/workflows/property-tests.yml` (create CI workflow)

**Approach**:
1. Verify Plausible integration in lakefile.lean
2. Review existing generators (Formula, Context, TaskFrame)
3. Test existing property test files compile and run
4. Create basic CI/CD workflow for property tests
5. Document current test coverage baseline

**Verification**:
- [ ] `lake build LogosTest` succeeds
- [ ] Existing property tests run successfully
- [ ] CI workflow executes property tests
- [ ] Baseline coverage documented

**Estimated Time**: 1-2 hours

---

### Phase 2: TaskModel Generator Implementation
**Effort**: 4-6 hours  
**Status**: [COMPLETED]

**Action**: Implement generator for TaskModel with dependent types

**File**: `LogosTest/Core/Property/Generators.lean`

**Approach**:
1. **Analyze TaskModel structure**:
   ```lean
   structure TaskModel (τ : Type) where
     frame : TaskFrame τ
     valuation : frame.WorldState → String → Prop
   ```

2. **Design proxy type pattern**:
   ```lean
   -- Proxy: Generate frame first, then valuation
   structure TaskModelProxy where
     frameProxy : Unit  -- TaskFrame proxy
     valuationSeed : Nat  -- Seed for valuation
   ```

3. **Implement SampleableExt instance**:
   ```lean
   instance : SampleableExt (TaskModel Int) where
     proxy := TaskModelProxy
     interp p := {
       frame := SampleableExt.interp p.frameProxy
       valuation := fun w s => 
         -- Deterministic valuation based on seed, world, atom
         (hash (p.valuationSeed, w, s)) % 2 = 0
     }
     sample := do
       let fp ← SampleableExt.sample (α := TaskFrame Int)
       let seed ← Gen.choose 0 1000
       return ⟨fp, seed⟩
   ```

4. **Add helper generators**:
   ```lean
   -- Generate TaskModel with specific frame
   def genTaskModelWithFrame (F : TaskFrame τ) : Gen (TaskModel τ) := ...
   
   -- Generate TaskModel with specific valuation pattern
   def genTaskModelWithPattern (pattern : String → Bool) : Gen (TaskModel Int) := ...
   ```

5. **Test generator**:
   ```lean
   #test ∀ (M : TaskModel Int), M.frame.nullity M.frame.WorldState.default
   ```

**Verification**:
- [ ] TaskModel generator compiles
- [ ] Generated models satisfy frame constraints
- [ ] Valuation function is well-defined
- [ ] Helper generators work correctly
- [ ] Basic property tests pass

**Estimated Time**: 4-6 hours

---

### Phase 3: Metalogic Property Tests
**Effort**: 2-3 hours  
**Status**: [COMPLETED]

**Action**: Enhance metalogic property tests for soundness and consistency

**File**: `LogosTest/Core/Metalogic/SoundnessPropertyTest.lean`

**Approach**:
1. **Review existing tests** (axiom validity tests already exist)

2. **Add comprehensive axiom validity tests**:
   ```lean
   -- Test all axiom schemas are valid
   #test ∀ (φ ψ χ : Formula), 
     axiom_valid (Axiom.prop_k φ ψ)
   
   #test ∀ (φ ψ χ : Formula),
     axiom_valid (Axiom.prop_s φ ψ χ)
   
   #test ∀ (φ : Formula),
     axiom_valid (Axiom.modal_t φ)
   
   -- Continue for all 14 axiom schemas
   ```

3. **Add derivation soundness tests** (where decidable):
   ```lean
   -- Test specific derivable formulas are valid
   #test ∀ (φ : Formula),
     axiom_valid (Axiom.modal_t φ) → 
     valid [] (Axiom.modal_t φ)
   ```

4. **Add consistency tests** (indirect):
   ```lean
   -- Test that axioms don't derive contradiction
   #test ∀ (ax : Axiom),
     ¬(ax.formula = Formula.bot)
   ```

5. **Configure test parameters**:
   ```lean
   -- Use larger test counts for critical properties
   #eval Testable.check (∀ φ, axiom_valid (Axiom.modal_t φ)) {
     numInst := 500,
     maxSize := 30,
     traceShrink := false
   }
   ```

**Verification**:
- [ ] All axiom validity tests pass
- [ ] Soundness tests pass (where decidable)
- [ ] Consistency tests pass
- [ ] Test coverage ≥ 100 cases per property
- [ ] No false positives/negatives

**Estimated Time**: 2-3 hours

---

### Phase 4: Derivation Property Tests
**Effort**: 2-3 hours  
**Status**: [COMPLETED]

**Action**: Enhance derivation property tests for structural properties

**File**: `LogosTest/Core/ProofSystem/DerivationPropertyTest.lean`

**Approach**:
1. **Review existing tests** (reflexivity, weakening, height properties already exist)

2. **Add comprehensive structural properties**:
   ```lean
   -- Reflexivity
   #test ∀ (Γ : Context) (φ : Formula),
     φ ∈ Γ → Derivable Γ φ
   
   -- Weakening
   #test ∀ (Γ Δ : Context) (φ : Formula),
     Derivable Γ φ → Γ ⊆ Δ → Derivable Δ φ
   
   -- Height properties
   #test ∀ (d : DerivationTree),
     d.height ≥ 0
   
   #test ∀ (d1 d2 : DerivationTree),
     (modus_ponens d1 d2).height > d1.height
   ```

3. **Add axiom derivability tests**:
   ```lean
   -- All axioms are derivable
   #test ∀ (ax : Axiom),
     Derivable [] ax.formula
   ```

4. **Add context subset properties**:
   ```lean
   -- Context operations preserve derivability
   #test ∀ (Γ : Context) (φ ψ : Formula),
     Derivable (φ :: Γ) ψ → 
     Derivable (φ :: φ :: Γ) ψ  -- Contraction
   ```

5. **Configure for performance**:
   ```lean
   -- Smaller test counts for expensive properties
   #eval Testable.check (∀ Γ Δ φ, weakening_property Γ Δ φ) {
     numInst := 100,
     maxSize := 20,
     numRetries := 30
   }
   ```

**Verification**:
- [ ] All structural properties pass
- [ ] Axiom derivability tests pass
- [ ] Context properties pass
- [ ] Tests run in <5 seconds each
- [ ] No performance regressions

**Estimated Time**: 2-3 hours

---

### Phase 5: Semantic Property Tests
**Effort**: 2-3 hours  
**Status**: [COMPLETED]

**Action**: Enhance semantic property tests for frame and truth properties

**File**: `LogosTest/Core/Semantics/SemanticPropertyTest.lean`

**Approach**:
1. **Review existing tests** (frame nullity, compositionality already exist)

2. **Add comprehensive frame properties**:
   ```lean
   -- Nullity constraint
   #test ∀ (F : TaskFrame Int) (w : F.WorldState),
     F.task_rel w w 0
   
   -- Compositionality constraint
   #test ∀ (F : TaskFrame Int) (w1 w2 w3 : F.WorldState) (t1 t2 : Int),
     F.task_rel w1 w2 t1 → F.task_rel w2 w3 t2 →
     F.task_rel w1 w3 (t1 + t2)
   
   -- Time properties
   #test ∀ (F : TaskFrame Int) (w1 w2 : F.WorldState) (t : Int),
     F.task_rel w1 w2 t → t ≥ 0
   ```

3. **Add truth condition properties** (using TaskModel generator):
   ```lean
   -- Truth at world is well-defined
   #test ∀ (M : TaskModel Int) (w : M.frame.WorldState) (φ : Formula),
     truth_at M w φ ∨ ¬truth_at M w φ  -- Decidable
   
   -- Implication truth condition
   #test ∀ (M : TaskModel Int) (w : M.frame.WorldState) (φ ψ : Formula),
     truth_at M w (φ.imp ψ) ↔ 
     (truth_at M w φ → truth_at M w ψ)
   ```

4. **Add validity properties**:
   ```lean
   -- Valid formulas are true at all worlds
   #test ∀ (φ : Formula),
     valid [] φ → 
     ∀ (M : TaskModel Int) (w : M.frame.WorldState),
       truth_at M w φ
   ```

5. **Configure for complex properties**:
   ```lean
   -- Use moderate test counts for semantic properties
   #eval Testable.check (∀ M w φ, truth_property M w φ) {
     numInst := 200,
     maxSize := 25,
     traceShrink := true  -- Debug if failures occur
   }
   ```

**Verification**:
- [ ] Frame property tests pass
- [ ] Truth condition tests pass
- [ ] Validity property tests pass
- [ ] TaskModel generator works correctly
- [ ] Tests complete in reasonable time

**Estimated Time**: 2-3 hours

---

### Phase 6: Formula Transformation Tests
**Effort**: 2-3 hours  
**Status**: [COMPLETED]

**Action**: Enhance formula transformation property tests

**File**: `LogosTest/Core/Syntax/FormulaPropertyTest.lean`

**Approach**:
1. **Review existing tests** (complexity, swap_temporal, diamond-box duality already exist)

2. **Add comprehensive transformation properties**:
   ```lean
   -- Complexity properties
   #test ∀ (φ : Formula), φ.complexity ≥ 1
   
   #test ∀ (φ ψ : Formula),
     (φ.imp ψ).complexity = 1 + φ.complexity + ψ.complexity
   
   -- Swap temporal involution
   #test ∀ (φ : Formula),
     φ.swap_temporal.swap_temporal = φ
   
   -- Swap temporal distribution
   #test ∀ (φ : Formula),
     φ.diamond.swap_temporal = φ.swap_temporal.diamond
   
   #test ∀ (φ : Formula),
     φ.neg.swap_temporal = φ.swap_temporal.neg
   ```

3. **Add derived operator properties**:
   ```lean
   -- Diamond-box duality
   #test ∀ (φ : Formula),
     φ.diamond = φ.neg.box.neg
   
   -- Conjunction-implication relation
   #test ∀ (φ ψ : Formula),
     φ.and ψ = (φ.imp ψ.neg).neg
   
   -- Disjunction-implication relation
   #test ∀ (φ ψ : Formula),
     φ.or ψ = φ.neg.imp ψ
   ```

4. **Add idempotence properties** (if NNF/CNF exist):
   ```lean
   -- NNF idempotence
   #test ∀ (φ : Formula),
     φ.nnf.nnf = φ.nnf
   
   -- CNF idempotence
   #test ∀ (φ : Formula),
     φ.cnf.cnf = φ.cnf
   ```

5. **Add operator injectivity tests**:
   ```lean
   -- Box is injective
   #test ∀ (φ ψ : Formula),
     φ.box = ψ.box → φ = ψ
   
   -- Implication is injective in both arguments
   #test ∀ (φ1 φ2 ψ1 ψ2 : Formula),
     φ1.imp ψ1 = φ2.imp ψ2 → φ1 = φ2 ∧ ψ1 = ψ2
   ```

**Verification**:
- [ ] Complexity tests pass
- [ ] Transformation tests pass
- [ ] Derived operator tests pass
- [ ] Idempotence tests pass (if applicable)
- [ ] Injectivity tests pass

**Estimated Time**: 2-3 hours

---

### Phase 7: Documentation and CI Integration
**Effort**: 2-3 hours  
**Status**: [COMPLETED]

**Action**: Update documentation and integrate with CI/CD

**Files**:
- `LogosTest/Core/Property/README.md`
- `docs/development/PROPERTY_TESTING_GUIDE.md` (create)
- `.github/workflows/property-tests.yml`
- `docs/project-info/IMPLEMENTATION_STATUS.md`

**Approach**:
1. **Update README.md** with TaskModel generator examples:
   ```markdown
   ### TaskModel Generator
   
   ```lean
   instance : SampleableExt (TaskModel Int) where
     proxy := TaskModelProxy
     interp p := { frame := ..., valuation := ... }
     sample := ...
   ```
   
   Usage:
   ```lean
   #test ∀ (M : TaskModel Int), M.frame.nullity ...
   ```
   ```

2. **Create PROPERTY_TESTING_GUIDE.md**:
   - Overview of property-based testing
   - Plausible framework introduction
   - Generator patterns and examples
   - Property selection strategies
   - Shrinking strategies
   - Configuration and tuning
   - CI/CD integration
   - Troubleshooting guide

3. **Enhance CI workflow**:
   ```yaml
   name: Property Tests
   
   on: [push, pull_request]
   
   jobs:
     property-tests:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Install Lean
           uses: leanprover/lean-action@v1
         - name: Build LogosTest
           run: lake build LogosTest
         - name: Run Property Tests
           run: |
             lake env lean LogosTest/Core/Syntax/FormulaPropertyTest.lean
             lake env lean LogosTest/Core/ProofSystem/DerivationPropertyTest.lean
             lake env lean LogosTest/Core/Semantics/SemanticPropertyTest.lean
             lake env lean LogosTest/Core/Metalogic/SoundnessPropertyTest.lean
   ```

4. **Update IMPLEMENTATION_STATUS.md**:
   - Mark property-based testing as COMPLETE
   - Document test coverage metrics
   - List all property test files
   - Note any limitations or future work

5. **Add examples to documentation**:
   - Add property test examples to EXAMPLES.md
   - Reference property tests in TUTORIAL.md
   - Update TESTING_STANDARDS.md with property testing section

**Verification**:
- [ ] README.md updated with TaskModel examples
- [ ] PROPERTY_TESTING_GUIDE.md created
- [ ] CI workflow runs property tests
- [ ] IMPLEMENTATION_STATUS.md updated
- [ ] Examples added to documentation

**Estimated Time**: 2-3 hours

---

## File Structure

```
LogosTest/
  Core/
    Property/
      Generators.lean           # Enhanced with TaskModel generator
      README.md                 # Updated with examples
    Syntax/
      FormulaPropertyTest.lean  # Enhanced transformation tests
    ProofSystem/
      DerivationPropertyTest.lean  # Enhanced structural tests
    Semantics/
      SemanticPropertyTest.lean    # Enhanced frame/truth tests
    Metalogic/
      SoundnessPropertyTest.lean   # Enhanced axiom validity tests

docs/
  Development/
    PROPERTY_TESTING_GUIDE.md  # New comprehensive guide
  ProjectInfo/
    IMPLEMENTATION_STATUS.md   # Updated with property testing status

.github/
  workflows/
    property-tests.yml         # CI workflow for property tests

.opencode/
  specs/
    174_property_based_testing/
      plans/
        implementation-001.md  # This file
      reports/
        research-001.md        # Research report
      summaries/
        research-summary.md    # Research summary
        plan-summary.md        # Plan summary (to be created)
```

---

## Testing Strategy

### Unit Tests
- **Generator Tests**: Verify generators produce valid values
  - TaskModel generator produces valid models
  - Frame constraints satisfied
  - Valuation function well-defined

- **Property Tests**: Verify properties hold
  - 100+ test cases per property
  - Size control for recursive types
  - Shrinking for minimal counterexamples

### Integration Tests
- **Cross-Module Tests**: Verify interactions
  - Derivation + Semantics (soundness)
  - Syntax + ProofSystem (derivability)
  - Semantics + Metalogic (validity)

### Performance Tests
- **Execution Time**: Property tests should complete quickly
  - Target: <5 seconds per property with 100 test cases
  - Tune numInst and maxSize if needed
  - Profile slow tests with traceShrink

### Coverage Goals
- **Property Coverage**: Test all major properties
  - Metalogic: Axiom validity, soundness
  - Derivation: Reflexivity, weakening, height
  - Semantics: Frame constraints, truth conditions
  - Syntax: Transformations, derived operators

- **Test Case Coverage**: 100+ cases per property
  - Use numInst := 100 as baseline
  - Increase to 500 for critical properties
  - Decrease to 50 for expensive properties

---

## Verification Checkpoints

### Phase 1: Infrastructure
- [ ] Plausible dependency verified in lakefile.lean
- [ ] Existing generators reviewed and tested
- [ ] Existing property tests compile and run
- [ ] CI workflow created and tested
- [ ] Baseline coverage documented

### Phase 2: TaskModel Generator
- [ ] TaskModel generator implemented
- [ ] Generated models satisfy frame constraints
- [ ] Valuation function well-defined
- [ ] Helper generators work correctly
- [ ] Basic property tests pass

### Phase 3: Metalogic Tests
- [ ] All axiom validity tests pass (14 axioms)
- [ ] Soundness tests pass (where decidable)
- [ ] Consistency tests pass
- [ ] Test coverage ≥ 100 cases per property
- [ ] No false positives/negatives

### Phase 4: Derivation Tests
- [ ] Structural property tests pass
- [ ] Axiom derivability tests pass
- [ ] Context property tests pass
- [ ] Tests run in <5 seconds each
- [ ] No performance regressions

### Phase 5: Semantic Tests
- [ ] Frame property tests pass
- [ ] Truth condition tests pass
- [ ] Validity property tests pass
- [ ] TaskModel generator works correctly
- [ ] Tests complete in reasonable time

### Phase 6: Formula Tests
- [ ] Complexity tests pass
- [ ] Transformation tests pass
- [ ] Derived operator tests pass
- [ ] Idempotence tests pass (if applicable)
- [ ] Injectivity tests pass

### Phase 7: Documentation
- [ ] README.md updated with examples
- [ ] PROPERTY_TESTING_GUIDE.md created
- [ ] CI workflow runs property tests
- [ ] IMPLEMENTATION_STATUS.md updated
- [ ] Examples added to documentation

---

## Documentation Requirements

### Code Documentation
- **Docstrings**: All generators have comprehensive docstrings
  - Purpose and usage
  - Parameter descriptions
  - Examples
  - Performance notes

- **Property Comments**: All properties have explanatory comments
  - What property is being tested
  - Why it should hold
  - Any limitations or caveats

### User Documentation
- **PROPERTY_TESTING_GUIDE.md**: Comprehensive guide
  - Introduction to property-based testing
  - Plausible framework overview
  - Generator patterns and examples
  - Property selection strategies
  - Configuration and tuning
  - Troubleshooting

- **README.md Updates**: Enhanced with examples
  - TaskModel generator example
  - Property test examples
  - Configuration examples
  - Best practices

### Developer Documentation
- **IMPLEMENTATION_STATUS.md**: Updated status
  - Property-based testing marked COMPLETE
  - Test coverage metrics
  - List of property test files
  - Future work notes

- **TESTING_STANDARDS.md**: Property testing section
  - Standards for writing property tests
  - Generator implementation guidelines
  - Performance requirements
  - CI/CD integration

---

## Success Criteria

### Functional Requirements
- [ ] Property-based testing framework integrated (Plausible)
- [ ] TaskModel generator implemented and tested
- [ ] Property tests for soundness implemented (axiom validity)
- [ ] Property tests for derivation properties implemented (reflexivity, weakening)
- [ ] Property tests for semantic properties implemented (frame constraints, truth)
- [ ] Property tests for formula transformations implemented (swap_temporal, derived ops)
- [ ] All property tests passing with sufficient coverage (100+ cases)

### Quality Requirements
- [ ] Test coverage ≥ 100 cases per property
- [ ] Tests run in <5 seconds each
- [ ] No false positives/negatives
- [ ] Shrinking produces minimal counterexamples
- [ ] Generators produce valid values

### Documentation Requirements
- [ ] PROPERTY_TESTING_GUIDE.md created
- [ ] README.md updated with examples
- [ ] Code has comprehensive docstrings
- [ ] IMPLEMENTATION_STATUS.md updated

### CI/CD Requirements
- [ ] CI workflow runs property tests
- [ ] Tests run on push and pull request
- [ ] Test failures block merges
- [ ] Performance regressions detected

---

## Related Research

### Research Reports
- [Main Research Report](specs/174_property_based_testing/reports/research-001.md)
  - Comprehensive analysis of Plausible framework
  - Integration strategies and best practices
  - 374 lines of detailed findings

- [Research Summary](specs/174_property_based_testing/summaries/research-summary.md)
  - Key findings and recommendations
  - Quick reference for implementation

- [Detailed Findings](docs/research/property-based-testing-lean4.md)
  - 986 lines of comprehensive documentation
  - Complete API reference and examples

### External Resources
- [Plausible Repository](https://github.com/leanprover-community/plausible)
- [Plausible Documentation](https://leanprover-community.github.io/mathlib4_docs/Plausible.html)
- [QuickCheck Paper](https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf)

---

## Notes

### Implementation Notes

1. **Decidability Workaround**: Cannot directly test "if derivable then valid" with random formulas because `Derivable Γ φ` is not decidable. Instead, test specific axiom instances where validity is decidable.

2. **Generator Performance**: Recursive formula generation can be slow for large sizes. Use size control (already implemented) and tune `maxSize` parameter for performance.

3. **TaskModel Complexity**: TaskModel has dependent types (valuation depends on WorldState from TaskFrame). Use `SampleableExt` with proxy pattern to handle this complexity.

4. **Shrinking Strategy**: Formula shrinking is already implemented and works well. TaskFrame is simple enough that default shrinking suffices.

5. **CI/CD Integration**: No existing CI/CD workflow, so we can set up fresh without compatibility concerns.

### Risk Mitigation

1. **TaskModel Generator Risk**: Mitigated by using well-documented proxy pattern from research
2. **Decidability Risk**: Mitigated by testing specific axiom instances instead of general derivability
3. **Performance Risk**: Mitigated by size control and tuning test parameters
4. **Shrinking Risk**: Mitigated by existing Formula shrinking implementation

### Future Work

1. **Coverage-Guided Generation**: Use coverage metrics to guide test generation
2. **Mutation Testing**: Generate mutants to test test quality
3. **Proof Synthesis**: Generate proofs from successful tests
4. **Example Database**: Cache and reuse interesting test cases
5. **Parallel Testing**: Run tests in parallel for better performance

### Lessons Learned (to be filled during implementation)

- TBD

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 001 | 2025-12-24 | Implementation Planner | Initial plan based on research |

---

**Plan Status**: [COMPLETED]  
**Completion Date**: 2025-12-25  
**Total Time**: 18-20 hours
