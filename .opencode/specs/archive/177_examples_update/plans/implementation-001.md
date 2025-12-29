# Implementation Plan: Update Examples to Use Latest APIs and Add New Feature Demonstrations

- **Task**: 177 - Update examples to use latest APIs and add new feature demonstrations
- **Status**: [COMPLETED]
- **Started**: 2025-12-25
- **Completed**: 2025-12-25
- **Effort**: 8-12 hours
- **Priority**: Medium
- **Dependencies**: None (Tasks 126, 127, 129, 130 already completed)
- **Research Inputs**: 
  - `.opencode/specs/177_examples_update/reports/research-001.md`
  - `.opencode/specs/177_examples_update/summaries/research-summary.md`
- **Artifacts**: 
  - `plans/implementation-001.md` (this file)
  - `summaries/plan-summary.md`
- **Standards**:
  - `.opencode/context/common/standards/plan.md`
  - `.opencode/context/common/system/status-markers.md`
  - `.opencode/context/common/system/artifact-management.md`
  - `.opencode/context/common/standards/tasks.md`
  - `Documentation/Development/LEAN_STYLE_GUIDE.md`
  - `Documentation/UserGuide/EXAMPLES.md` (documentation patterns)
- **Language**: lean
- **Lean Intent**: true

---

## Overview

This plan implements enhancements to existing example files to demonstrate new automation capabilities added in Tasks 126-127 (ProofSearch and heuristics). Research confirms **zero breaking changes** - all existing examples compile successfully and require no migration. The implementation is **additive only**, adding ~160 lines of new examples across 3 files (`Archive/ModalProofs.lean`, `Archive/TemporalProofs.lean`, `Archive/BimodalProofs.lean`) plus documentation updates. The work is structured in 4 phases with incremental validation, targeting 8-12 hours total effort with 90% confidence.

**Definition of Done**: All existing examples compile unchanged, new automation examples added and tested, documentation updated with cross-references, all acceptance criteria met.

---

## Goals & Non-Goals

### Goals
- Add ~90 lines of automation examples to `Archive/ModalProofs.lean` demonstrating `bounded_search`, `search_with_heuristics`, `search_with_cache`
- Add ~40 lines of temporal automation examples to `Archive/TemporalProofs.lean`
- Add ~30 lines of perpetuity automation examples to `Archive/BimodalProofs.lean` for principles P1-P6
- Update `Documentation/UserGuide/EXAMPLES.md` with automation feature references
- Maintain 100% backward compatibility (no modifications to existing examples)
- Follow LEAN_STYLE_GUIDE.md patterns (module docstrings, section headers, example docstrings)
- Include performance benchmarks and search statistics demonstrations
- Provide clear explanations for each automation feature

### Non-Goals
- Modifying existing examples (all changes are additive)
- Refactoring example file structure
- Adding new test files (examples are self-documenting)
- Implementing new automation features (Tasks 126-127 already complete)
- Updating API_REFERENCE.md (out of scope for this task)
- Creating new example files (work within existing Archive/*.lean files)

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Understanding ProofSearch API return tuples** (5-tuple with cache/stats) | Medium | Study `ProofSearch.lean` lines 370-417; use destructuring patterns from research examples; allocate 1 hour for API familiarization |
| **Choosing appropriate search depth limits** for different goal complexities | Medium | Start with depth=3 for simple goals, depth=10 for complex; use research report examples (lines 204-325) as templates; document rationale in comments |
| **Search performance variability** across different formulas | Low | Add comments documenting expected performance; use `#eval` for smoke tests; include failure cases with insufficient depth |
| **Heuristic weight tuning** requires experimentation | Medium | Use default weights initially; add 2-3 examples with custom weights (axiom-first vs MP-first); document weight choices |
| **Compilation errors from import changes** | Low | Research confirms zero breaking changes; if errors occur, verify import statements match dependency map |
| **Documentation clarity** for automation features | Low | Follow EXAMPLES.md patterns; include both code and explanatory comments; cross-reference ProofSearch API |

---

## Complexity Assessment

**Complexity Level**: Moderate [WARN]

**Justification**:
- **Additive-only changes**: All modifications are new sections appended to existing files (no refactoring)
- **Zero breaking changes**: Research validates all existing examples compile without modification
- **Well-defined scope**: 160 lines across 3 files with clear phased approach
- **Moderate learning curve**: Requires understanding new automation APIs (ProofSearch, heuristics) but no deep metaprogramming
- **Standard testing**: Compilation + functional verification (no complex integration testing)

**Skill Level Required**: Mid-level developer (6-12 months Lean 4 experience)

**Estimated Effort**: 8-12 hours (validated by research, original 10-hour estimate accurate)

---

## Technology Stack

### Core Dependencies
- **Lean 4**: Version 4.14.0 (from lean-toolchain)
- **mathlib4**: v4.14.0 (for standard mathematical definitions)
- **Std**: Lean 4 standard library (HashMap, HashSet for ProofSearch)

### ProofChecker Modules
- **Logos.Core.Syntax**: Formula and Context types
- **Logos.Core.ProofSystem**: Axioms and Derivation rules
- **Logos.Core.Automation.ProofSearch**: `bounded_search`, `search_with_heuristics`, `search_with_cache`, `HeuristicWeights`, `SearchStats`
- **Logos.Core.Automation.Tactics**: `tm_auto`, `modal_search`, `temporal_search`
- **Logos.Core.Theorems.Perpetuity**: Perpetuity principles P1-P6

### Required Imports (New)
```lean
import Logos.Core.Automation.ProofSearch  -- For all automation examples
import Logos.Core.Automation.Tactics      -- For tactic demonstrations
```

---

## Dependencies

### Module Dependencies
1. **Logos.Core.Automation.ProofSearch** (Task 126)
   - Provides: `bounded_search`, `search_with_heuristics`, `search_with_cache`
   - Provides: `HeuristicWeights`, `heuristic_score`, `orderSubgoalsByScore`
   - Provides: `ProofCache`, `SearchStats`, `Visited`
   - Depends on: Std.Data.HashMap, Std.Data.HashSet, Logos.ProofSystem

2. **Logos.Core.Automation.Tactics** (Task 127)
   - Provides: `tm_auto`, `modal_search`, `temporal_search`
   - Depends on: Logos.Core.ProofSystem, Logos.Core.Automation.AesopRules

3. **Logos.Core.Theorems.Perpetuity** (Fully proven)
   - Provides: `perpetuity_1` through `perpetuity_6`
   - Depends on: Logos.Core.Theorems.Perpetuity.{Helpers, Principles, Bridge}

### API Prerequisites (Learning Order)
1. **First**: `bounded_search` - Understanding Context, Formula, depth-bounded search
2. **Second**: `search_with_heuristics` - HeuristicWeights configuration, heuristic_score
3. **Third**: `search_with_cache` - ProofCache type, SearchStats interpretation
4. **Parallel**: `tm_auto` tactic - Basic Lean 4 tactic knowledge, Aesop automation

### Build Order
1. Phase 1: Core types (Syntax, ProofSystem) - already built
2. Phase 2: Theorems (Perpetuity, GeneralizedNecessitation) - already built
3. Phase 3: Automation (ProofSearch, Tactics) - already built
4. Phase 4: Examples (ModalProofs, TemporalProofs, BimodalProofs) - **this task**

**No circular dependencies detected** [YES]

---

## Implementation Phases

### Phase 1: Modal Automation Examples [COMPLETED]

**Completed**: 2025-12-25
**Goal**: Add ~90 lines of automation examples to `Archive/ModalProofs.lean` demonstrating ProofSearch capabilities and heuristic strategies.

**Tasks**:
- [ ] Add import statement: `import Logos.Core.Automation.ProofSearch`
- [ ] Add section header: "Automated Proof Search" with module docstring
- [ ] Implement 4 subsections:
  - [ ] **Basic Automated Proof Discovery** (~20 lines)
    - Example: Automated proof of modal T axiom using `bounded_search`
    - Example: Compare manual vs automated proof approaches
    - Show return tuple destructuring: `let (found, cache, visited, stats, visits) := ...`
  - [ ] **Search Performance Analysis** (~25 lines)
    - Example: Demonstrate SearchStats collection and interpretation
    - Example: Compare search depths (depth=3 vs depth=5 vs depth=10)
    - Example: Show node count variations with `stats.visited`
    - Include comments explaining hits, misses, prunedByLimit fields
  - [ ] **Custom Heuristic Strategies** (~25 lines)
    - Example: Compare axiom-first vs MP-first strategies
    - Example: Show HeuristicWeights configuration
    - Example: Demonstrate `heuristic_score` function usage
    - Document weight choices and performance impact
  - [ ] **Context Transformation Utilities** (~20 lines)
    - Example: Demonstrate `box_context` for modal K
    - Example: Show `future_context` for temporal K
    - Example: Illustrate context transformation in search
- [ ] Add section comments following LEAN_STYLE_GUIDE.md patterns
- [ ] Test compilation: `lake build Logos.Examples.ModalProofs`
- [ ] Verify examples execute correctly with `#eval` smoke tests

**Timing**: 4-6 hours

**Dependencies**: None (ProofSearch.lean already implemented)

**Verification**:
- [ ] File compiles without errors
- [ ] All new examples have docstrings
- [ ] SearchStats examples show expected fields
- [ ] Heuristic examples demonstrate weight variations
- [ ] Context transformation examples produce correct output

---

### Phase 2: Temporal Automation Examples [COMPLETED]

**Completed**: 2025-12-25
**Goal**: Add ~40 lines of temporal automation examples to `Archive/TemporalProofs.lean` demonstrating temporal proof search.

**Tasks**:
- [ ] Add import statement: `import Logos.Core.Automation.ProofSearch`
- [ ] Add section header: "Temporal Automation Examples" with module docstring
- [ ] Implement 2 subsections:
  - [ ] **Automated Temporal Search** (~25 lines)
    - Example: Automated proof of temporal axioms using `bounded_search`
    - Example: Search for temporal duality properties
    - Example: Demonstrate `temporal_search` tactic usage
    - Show depth requirements for temporal formulas (typically higher than modal)
  - [ ] **Temporal Context Transformations** (~15 lines)
    - Example: Demonstrate `future_context` transformation
    - Example: Show temporal K axiom application with transformed context
    - Example: Illustrate search with temporal context
- [ ] Add section comments following LEAN_STYLE_GUIDE.md patterns
- [ ] Test compilation: `lake build Logos.Examples.TemporalProofs`
- [ ] Verify temporal search examples execute correctly

**Timing**: 2-3 hours

**Dependencies**: Phase 1 (for consistency in example patterns)

**Verification**:
- [ ] File compiles without errors
- [ ] Temporal search examples demonstrate higher depth requirements
- [ ] Context transformation examples show temporal operators
- [ ] Examples cross-reference modal examples where relevant

---

### Phase 3: Perpetuity Automation Examples [COMPLETED]

**Completed**: 2025-12-25
**Goal**: Add ~30 lines of perpetuity automation examples to `Archive/BimodalProofs.lean` demonstrating automated discovery of principles P1-P6.

**Tasks**:
- [ ] Add import statement: `import Logos.Core.Automation.ProofSearch`
- [ ] Add section header: "Perpetuity Automation Examples" with module docstring
- [ ] Implement 2 subsections:
  - [ ] **Automated Perpetuity Discovery** (~20 lines)
    - Example: Discover P1 via automated search (□φ → Gφ)
    - Example: Discover P2 via automated search (Fφ → ◇φ)
    - Example: Show search depth requirements for bimodal formulas
    - Document which principles are discoverable vs require manual proof
  - [ ] **Combined Modal-Temporal Search** (~10 lines)
    - Example: Search with both modal and temporal operators
    - Example: Demonstrate interaction between box_context and future_context
- [ ] Add section comments following LEAN_STYLE_GUIDE.md patterns
- [ ] Test compilation: `lake build Logos.Examples.BimodalProofs`
- [ ] Verify perpetuity examples execute correctly

**Timing**: 1-2 hours

**Dependencies**: Phases 1-2 (for consistency in example patterns)

**Verification**:
- [ ] File compiles without errors
- [ ] Perpetuity discovery examples demonstrate P1-P6 automation
- [ ] Bimodal search examples show interaction between modal and temporal
- [ ] Examples document search depth requirements for complex formulas

---

### Phase 4: Documentation Updates [COMPLETED]

**Completed**: 2025-12-25
**Goal**: Update `Documentation/UserGuide/EXAMPLES.md` with automation feature references and cross-links.

**Tasks**:
- [ ] Add new subsection to "Modal Logic Examples" section:
  - [ ] Reference new automation examples in ModalProofs.lean
  - [ ] Link to ProofSearch API documentation
  - [ ] Explain bounded_search, search_with_heuristics, search_with_cache
- [ ] Add new subsection to "Temporal Logic Examples" section:
  - [ ] Reference new temporal automation examples
  - [ ] Link to temporal_search tactic documentation
- [ ] Add new subsection to "Perpetuity Principles" section:
  - [ ] Reference new perpetuity automation examples
  - [ ] Explain automated discovery vs manual proof
- [ ] Update "Custom Tactic Usage" section:
  - [ ] Expand with new automation APIs
  - [ ] Add cross-references to PROOF_SEARCH_AUTOMATION.md research doc
- [ ] Add cross-references between related examples
- [ ] Verify all links are valid
- [ ] Test documentation builds correctly

**Timing**: 1-2 hours

**Dependencies**: Phases 1-3 (examples must exist before documenting)

**Verification**:
- [ ] All new sections added to EXAMPLES.md
- [ ] All cross-references are valid
- [ ] Documentation follows existing patterns
- [ ] Links to ProofSearch API are correct
- [ ] Examples are accurately described

---

## Testing & Validation

### Compilation Testing
```bash
# Test each file individually
lake build Logos.Examples.ModalProofs
lake build Logos.Examples.TemporalProofs
lake build Logos.Examples.BimodalProofs

# Test all examples
lake build Logos.Examples

# Verify no errors
echo $?  # Should be 0
```

### Functional Testing
- [ ] Verify `bounded_search` examples return expected Bool values
- [ ] Verify `SearchStats` examples show correct field values (hits, misses, visited, prunedByLimit)
- [ ] Verify heuristic weight variations produce different scores
- [ ] Verify context transformation examples produce correct contexts
- [ ] Verify temporal search examples handle temporal operators correctly
- [ ] Verify perpetuity discovery examples find P1-P6 principles

### Regression Testing
```bash
# Ensure existing examples still work
grep -rn "sorry" Archive/*Proofs.lean
# Should show only intentional placeholders (3 total, unchanged)

# Verify no new errors
lake build 2>&1 | grep -i "error"
# Should be empty

# Verify example count unchanged (existing examples preserved)
# ModalProofs.lean: existing examples + new sections
# TemporalProofs.lean: existing examples + new sections
# BimodalProofs.lean: existing examples + new sections
```

### Performance Testing
- [ ] Verify search depth=3 completes quickly for simple formulas
- [ ] Verify search depth=10 completes within reasonable time for complex formulas
- [ ] Verify cache reuse reduces search time for related goals
- [ ] Document performance characteristics in example comments

### Documentation Testing
- [ ] Verify all links in EXAMPLES.md are valid
- [ ] Verify cross-references between examples are correct
- [ ] Verify documentation accurately describes example behavior
- [ ] Verify code snippets in documentation match actual examples

---

## Artifacts & Outputs

### Implementation Artifacts
1. **Archive/ModalProofs.lean** (241 → 331 lines, +90 lines)
   - New sections: Automated Proof Search, Search Performance Analysis, Custom Heuristic Strategies, Context Transformation Utilities
   - New import: `Logos.Core.Automation.ProofSearch`

2. **Archive/TemporalProofs.lean** (301 → 341 lines, +40 lines)
   - New sections: Temporal Automation Examples, Temporal Context Transformations
   - New import: `Logos.Core.Automation.ProofSearch`

3. **Archive/BimodalProofs.lean** (216 → 246 lines, +30 lines)
   - New sections: Perpetuity Automation Examples, Combined Modal-Temporal Search
   - New import: `Logos.Core.Automation.ProofSearch`

4. **Documentation/UserGuide/EXAMPLES.md** (448 → ~500 lines, +~50 lines)
   - New subsections for automation features
   - Cross-references to ProofSearch API
   - Links to research documentation

### Planning Artifacts
1. **plans/implementation-001.md** (this file)
   - Comprehensive implementation plan with 4 phases
   - Complexity assessment and dependency mapping
   - Testing and validation strategy

2. **summaries/plan-summary.md**
   - Brief summary of implementation approach
   - Key steps and success criteria
   - Effort estimate and phase breakdown

### State Updates
1. **.opencode/specs/177_examples_update/state.json**
   - Updated with plan version and timestamps
   - Phase completion tracking

2. **.opencode/specs/state.json** (global)
   - Updated recent_activities with plan creation
   - Project status tracking

---

## Success Criteria

### From TODO.md Acceptance Criteria
- [x] All existing examples audited for correctness [PASS] (Research phase complete)
- [ ] Examples updated to use latest APIs (Phases 1-3)
- [ ] New examples for ProofSearch and heuristics added (Phases 1-3)
- [ ] New examples for perpetuity principles P1-P6 added (Phase 3)
- [ ] All examples compile and run successfully (Testing & Validation)
- [ ] Examples documented with clear explanations (Phases 1-4)

### Additional Success Criteria
- [ ] Zero breaking changes to existing examples (backward compatibility maintained)
- [ ] All new examples follow LEAN_STYLE_GUIDE.md patterns
- [ ] All new examples have docstrings and section headers
- [ ] SearchStats examples demonstrate performance analysis
- [ ] Heuristic examples show weight customization
- [ ] Context transformation examples illustrate utility functions
- [ ] Documentation cross-references are valid and helpful
- [ ] Total implementation time within 8-12 hour estimate

---

## Rollback/Contingency

### Rollback Strategy
If implementation encounters critical issues:

1. **Immediate Rollback** (if compilation fails):
   ```bash
   git checkout Archive/ModalProofs.lean
   git checkout Archive/TemporalProofs.lean
   git checkout Archive/BimodalProofs.lean
   git checkout Documentation/UserGuide/EXAMPLES.md
   lake build Logos.Examples  # Verify rollback successful
   ```

2. **Partial Rollback** (if specific phase fails):
   - Phase 1 failure: Rollback ModalProofs.lean only
   - Phase 2 failure: Rollback TemporalProofs.lean only
   - Phase 3 failure: Rollback BimodalProofs.lean only
   - Phase 4 failure: Rollback EXAMPLES.md only

3. **Incremental Recovery**:
   - Identify failing section (e.g., heuristic examples)
   - Remove only failing section
   - Keep working sections
   - Re-test compilation

### Contingency Plans

**If ProofSearch API is misunderstood**:
- Allocate +1 hour for deeper API study
- Consult ProofSearch.lean implementation (lines 344-417)
- Review ProofSearchTest.lean for usage patterns
- Simplify examples to basic bounded_search only

**If search depth requirements are unclear**:
- Start with conservative depths (depth=10 for all examples)
- Iteratively reduce depth until examples fail
- Document minimum depth requirements in comments
- Add failure case examples with insufficient depth

**If heuristic weight tuning is complex**:
- Use default weights for all examples initially
- Add only 1-2 custom weight examples (not 3-4)
- Document weight choices with rationale
- Defer advanced weight tuning to future task

**If documentation updates are time-consuming**:
- Prioritize code examples over documentation (Phases 1-3)
- Defer Phase 4 to separate task if needed
- Add minimal inline comments instead of full EXAMPLES.md updates
- Update documentation in follow-up task

### Risk Thresholds
- **Abort if**: Compilation fails after 2 hours of debugging
- **Defer if**: Total time exceeds 14 hours (>15% over estimate)
- **Escalate if**: Breaking changes discovered in ProofSearch API
- **Simplify if**: Heuristic examples require >3 hours (reduce scope)

---

## Notes

### Research Validation
- Research report confirms **zero breaking changes** (high confidence)
- All existing examples compile successfully (verified)
- New APIs are **additive only** (no migration needed)
- Effort estimate of 8-12 hours validated by research (90% confidence)

### Implementation Strategy
- **Incremental approach**: Add examples phase-by-phase with validation
- **Backward compatibility**: No modifications to existing examples
- **Documentation-driven**: Follow LEAN_STYLE_GUIDE.md and EXAMPLES.md patterns
- **Performance-aware**: Include SearchStats and depth comparisons

### Key Insights from Research
1. ProofSearch returns 5-tuple: `(Bool, ProofCache, Visited, SearchStats, Nat)`
2. HeuristicWeights has 8 configurable fields (axiomWeight, mpBase, etc.)
3. SearchStats has 4 fields: hits, misses, visited, prunedByLimit
4. Context transformations: `box_context` (modal K), `future_context` (temporal K)
5. Perpetuity principles P1-P6 are fully proven (no sorry placeholders)

### Related Documentation
- **Research Report**: `.opencode/specs/177_examples_update/reports/research-001.md` (698 lines)
- **Research Summary**: `.opencode/specs/177_examples_update/summaries/research-summary.md` (100 lines)
- **ProofSearch Implementation**: `Logos/Core/Automation/ProofSearch.lean` (461 lines)
- **Tactics Implementation**: `Logos/Core/Automation/Tactics.lean` (626 lines)
- **Style Guide**: `Documentation/Development/LEAN_STYLE_GUIDE.md`
- **Example Patterns**: `Documentation/UserGuide/EXAMPLES.md` (448 lines)

---

**Plan Version**: 001  
**Created**: 2025-12-25  
**Status**: [COMPLETED]  
**Completed**: 2025-12-25  
**Next Action**: None (all phases complete)
