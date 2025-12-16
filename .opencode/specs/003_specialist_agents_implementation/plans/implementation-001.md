# Implementation Plan: 14 Specialist Agents for LEAN 4 ProofChecker

**Project**: #003
**Version**: 001
**Date**: December 16, 2025
**Complexity**: Very Complex
**Status**: Ready for Implementation

---

## Executive Summary

This plan details the implementation of 14 specialist agents for the LEAN 4 ProofChecker project, organized into 5 phases over 20 weeks. The specialists will integrate with existing primary agents (researcher, proof-developer, refactorer, documenter, reviewer) and leverage external tools (LSP, Loogle, LeanSearch, Aesop, Lake). The implementation follows a foundational-first approach, building core infrastructure before advanced features.

**Total Estimated Effort**: 480-560 person-hours (12-14 person-weeks)
**Risk Level**: Medium-High
**Success Probability**: 85% with proper risk mitigation

---

## Table of Contents

1. [Complexity Assessment](#1-complexity-assessment)
2. [Dependency Analysis](#2-dependency-analysis)
3. [Phase-by-Phase Implementation](#3-phase-by-phase-implementation)
4. [Detailed Implementation Steps](#4-detailed-implementation-steps)
5. [Integration Plan](#5-integration-plan)
6. [Testing Strategy](#6-testing-strategy)
7. [Risk Management](#7-risk-management)
8. [Success Metrics](#8-success-metrics)
9. [Timeline and Milestones](#9-timeline-and-milestones)

---

## 1. Complexity Assessment

### 1.1 Overall Project Complexity

**Complexity Level**: Very Complex

**Rationale**:
- 14 distinct specialist agents with unique capabilities
- Integration with 5 external tools (LSP, Loogle, LeanSearch, Aesop, Lake)
- Coordination with 6 existing primary agents
- Complex error handling and graceful degradation requirements
- Multi-agent coordination patterns (hierarchical, pipeline, blackboard)
- Context management across distributed agents
- Performance optimization requirements

**Total Estimated Effort**: 480-560 person-hours
- Phase 1 (Foundation): 120-140 hours
- Phase 2 (Development Tools): 100-120 hours
- Phase 3 (Advanced Features): 80-100 hours
- Phase 4 (Analysis & Learning): 100-120 hours
- Phase 5 (Natural Language): 80-80 hours

### 1.2 Complexity Breakdown by Phase

#### Phase 1: Core Infrastructure (Priority 1)
**Complexity**: Moderate to Complex
**Effort**: 120-140 hours (3-3.5 weeks)

| Specialist | Complexity | Effort | Key Challenges |
|------------|------------|--------|----------------|
| Syntax Validator | Moderate | 30-35h | LSP stability, error recovery, caching |
| Library Navigator | Complex | 35-40h | Dual search integration, result ranking, caching |
| Error Diagnostics | Moderate | 25-30h | Pattern matching, fix generation, learning |
| Tactic Recommender | Complex | 30-35h | Goal analysis, success tracking, pattern recognition |

**Critical Success Factors**:
- Robust LSP connection management
- Effective caching strategies
- Graceful degradation when services unavailable

#### Phase 2: Development Tools (Priority 2)
**Complexity**: Moderate to Complex
**Effort**: 100-120 hours (2.5-3 weeks)

| Specialist | Complexity | Effort | Key Challenges |
|------------|------------|--------|----------------|
| Proof Optimizer | Complex | 35-40h | Redundancy detection, Aesop integration, validation |
| Test Generator | Moderate | 25-30h | Random generation, counterexample search |
| Code Review Agent | Complex | 25-30h | Multi-specialist coordination, prioritization |
| Documentation Generator | Moderate | 15-20h | Template generation, example extraction |

**Critical Success Factors**:
- Proof correctness preservation
- Accurate issue detection
- Useful suggestion generation

#### Phase 3: Advanced Features (Priority 3)
**Complexity**: Complex
**Effort**: 80-100 hours (2-2.5 weeks)

| Specialist | Complexity | Effort | Key Challenges |
|------------|------------|--------|----------------|
| Refactoring Assistant | Complex | 40-50h | Safety guarantees, reference tracking, validation |
| Dependency Analyzer | Moderate | 40-50h | Graph construction, cycle detection, optimization |

**Critical Success Factors**:
- 99%+ refactoring success rate
- Complete dependency graph accuracy
- No breaking changes

#### Phase 4: Analysis & Learning (Priority 4)
**Complexity**: Moderate to Complex
**Effort**: 100-120 hours (2.5-3 weeks)

| Specialist | Complexity | Effort | Key Challenges |
|------------|------------|--------|----------------|
| Performance Profiler | Moderate | 30-35h | Timing measurement, bottleneck identification |
| Learning Path Generator | Complex | 40-45h | Concept graph, personalization, exercise generation |
| Proof Strategy Advisor | Complex | 30-40h | Pattern recognition, strategy database, skeleton generation |

**Critical Success Factors**:
- Accurate performance measurement
- Coherent learning paths
- Relevant strategy suggestions

#### Phase 5: Natural Language (Priority 5)
**Complexity**: Complex
**Effort**: 80-80 hours (2 weeks)

| Specialist | Complexity | Effort | Key Challenges |
|------------|------------|--------|----------------|
| Concept Explainer | Complex | 80h | NLG integration, level adaptation, clarity |

**Critical Success Factors**:
- Clear, accurate explanations
- Appropriate level adaptation
- Useful examples

### 1.3 Required Knowledge Areas

**Essential Knowledge**:
1. **LEAN 4 Language**: Syntax, type system, tactics, metaprogramming
2. **LSP Protocol**: JSON-RPC, document synchronization, diagnostics
3. **Multi-Agent Systems**: Coordination patterns, context management
4. **Caching Strategies**: Invalidation, LRU eviction, performance
5. **Error Handling**: Graceful degradation, circuit breakers, fallbacks

**Desirable Knowledge**:
1. **Proof Theory**: Proof strategies, tactics, automation
2. **Type Theory**: Dependent types, type class resolution
3. **Graph Algorithms**: Dependency analysis, cycle detection
4. **Natural Language Generation**: Template-based, LLM integration
5. **Performance Profiling**: Timing, bottleneck analysis

### 1.4 Technical Challenges

**High-Priority Challenges**:
1. **LSP Stability**: LSP may crash or become unresponsive
   - *Impact*: Blocks syntax validation, type checking
   - *Mitigation*: Automatic reconnection, cached results, timeout handling

2. **Search Service Availability**: Loogle/LeanSearch may be down
   - *Impact*: Reduces library navigation effectiveness
   - *Mitigation*: Caching, fallback to local search, graceful degradation

3. **Performance**: Agents may be too slow for interactive use
   - *Impact*: Poor user experience, adoption resistance
   - *Mitigation*: Aggressive caching, incremental updates, async operations

4. **Accuracy**: Suggestions may be incorrect or irrelevant
   - *Impact*: User trust erosion, wasted time
   - *Mitigation*: Validation, user feedback, learning mechanisms

**Medium-Priority Challenges**:
1. **Agent Coordination Complexity**: Managing 14+ agents
2. **Context Management**: Preventing context explosion
3. **Tool Version Compatibility**: LEAN 4 and tools evolving
4. **Testing Coverage**: Comprehensive testing of all agents

### 1.5 Risk Factors

| Risk | Probability | Impact | Severity | Mitigation |
|------|-------------|--------|----------|------------|
| LSP crashes frequently | Medium | High | **High** | Robust error handling, auto-reconnect, caching |
| Search services unavailable | Medium | Medium | **Medium** | Fallback chains, local search, caching |
| Performance too slow | Medium | High | **High** | Profiling, optimization, async operations |
| Suggestions inaccurate | High | Medium | **Medium** | Validation, feedback loops, learning |
| Integration complexity | Medium | Medium | **Medium** | Clear interfaces, incremental integration |
| Scope creep | Medium | Medium | **Medium** | Strict phase boundaries, MVP focus |

---

## 2. Dependency Analysis

### 2.1 Specialist Dependencies

```
Foundational Specialists (No Dependencies):
├── Syntax Validator
│   └── Tools: LSP
│   └── Context: lean4/domain/lean4-syntax.md
│
├── Library Navigator
│   └── Tools: Loogle, LeanSearch, LSP
│   └── Context: lean4/domain/mathlib-overview.md
│
└── Dependency Analyzer
    └── Tools: Lake, LSP
    └── Context: lean4/standards/

Tier 1 Specialists (Depend on Foundational):
├── Error Diagnostics
│   └── Depends on: Syntax Validator, Library Navigator
│   └── Tools: LSP
│
├── Tactic Recommender
│   └── Depends on: Syntax Validator, Library Navigator
│   └── Tools: LSP, Loogle, LeanSearch, Aesop
│
└── Performance Profiler
    └── Depends on: Syntax Validator
    └── Tools: LSP, Lake

Tier 2 Specialists (Depend on Tier 1):
├── Proof Optimizer
│   └── Depends on: Syntax Validator, Library Navigator, Tactic Recommender
│   └── Tools: LSP, Aesop, Lake
│
├── Refactoring Assistant
│   └── Depends on: Syntax Validator, Library Navigator
│   └── Tools: LSP, Lake
│
├── Test Generator
│   └── Depends on: Syntax Validator, Library Navigator
│   └── Tools: LSP, Aesop
│
├── Documentation Generator
│   └── Depends on: Syntax Validator, Library Navigator, Test Generator
│   └── Tools: LSP, Lake
│
└── Proof Strategy Advisor
    └── Depends on: Syntax Validator, Library Navigator, Tactic Recommender
    └── Tools: LSP, Loogle, Aesop

Tier 3 Specialists (Depend on Tier 2):
├── Code Review Agent
│   └── Depends on: ALL other specialists
│   └── Tools: Lake, LSP
│
├── Learning Path Generator
│   └── Depends on: Library Navigator, Test Generator, Documentation Generator
│   └── Tools: LSP
│
└── Concept Explainer
    └── Depends on: Library Navigator, Documentation Generator
    └── Tools: LSP, LLM APIs
```

### 2.2 Tool Dependencies

| Tool | Specialists Using | Integration Complexity | Availability |
|------|-------------------|------------------------|--------------|
| **LSP** | All 14 specialists | High | Local (always available) |
| **Loogle** | Library Navigator, Tactic Recommender, Error Diagnostics, Proof Optimizer, Proof Strategy Advisor | Medium | Remote (may be unavailable) |
| **LeanSearch** | Library Navigator, Tactic Recommender, Concept Explainer | Medium | Remote (may be unavailable) |
| **Aesop** | Tactic Recommender, Proof Optimizer, Test Generator, Proof Strategy Advisor | Medium | Local (always available) |
| **Lake** | Code Review Agent, Documentation Generator, Refactoring Assistant, Dependency Analyzer, Performance Profiler | Low | Local (always available) |

### 2.3 Primary Agent Integration Points

#### researcher.md
**Current State**: Already uses specialists (lean-search, loogle, web-research)
**Add Specialists**:
- library-navigator (replace/enhance existing search specialists)

**Integration Points**:
- Stage 2 (DelegateToSpecialists): Route to library-navigator for comprehensive search

#### proof-developer.md
**Current State**: Coordinates tactic/term-mode/metaprogramming specialists
**Add Specialists**:
- syntax-validator (validation after each step)
- tactic-recommender (suggest tactics during proof development)
- library-navigator (find relevant lemmas)
- error-diagnostics (help debug errors)

**Integration Points**:
- Stage 1 (LoadImplementationPlan): Validate plan with syntax-validator
- Stage 2 (ImplementStepByStep): Use tactic-recommender for suggestions
- Stage 2 (Verification): Use syntax-validator for type checking
- Stage 2 (Error Handling): Use error-diagnostics for fix suggestions

#### refactorer.md
**Current State**: Coordinates style-checker and proof-simplifier
**Add Specialists**:
- syntax-validator (verify changes don't break code)
- refactoring-assistant (perform safe refactorings)
- code-reviewer (quality checks after refactoring)
- proof-optimizer (simplify proofs during refactoring)

**Integration Points**:
- Stage 1 (AnalyzeRefactoringScope): Use code-reviewer for analysis
- Stage 2 (PerformRefactoring): Use refactoring-assistant for safe changes
- Stage 2 (PerformRefactoring): Use proof-optimizer for proof simplification
- Stage 2 (PerformRefactoring): Use syntax-validator for verification

#### documenter.md
**Current State**: Coordinates doc-analyzer and doc-writer
**Add Specialists**:
- documentation-generator (auto-generate documentation)
- test-generator (create examples for documentation)
- concept-explainer (generate explanations)
- syntax-validator (verify documentation examples compile)

**Integration Points**:
- Stage 2 (UpdateDocumentation): Use documentation-generator for auto-docs
- Stage 2 (UpdateDocumentation): Use test-generator for examples
- Stage 2 (UpdateDocumentation): Use concept-explainer for explanations
- Stage 2 (UpdateDocumentation): Use syntax-validator to verify examples

#### reviewer.md
**Current State**: Uses verification-specialist
**Add Specialists**:
- code-reviewer (automated code review)
- dependency-analyzer (check module structure)
- performance-profiler (identify performance issues)
- proof-optimizer (suggest proof improvements)

**Integration Points**:
- Add stage: "CodeReview" using code-reviewer
- Add stage: "DependencyAnalysis" using dependency-analyzer
- Add stage: "PerformanceCheck" using performance-profiler
- Add stage: "ProofOptimization" using proof-optimizer

#### planner.md
**Current State**: Coordinates complexity-analyzer and dependency-mapper
**Add Specialists**:
- dependency-analyzer (map actual code dependencies)
- performance-profiler (estimate performance impact)

**Integration Points**:
- Stage 3 (RouteToDependencyMapper): Use dependency-analyzer for code-level dependencies
- Stage 4 (CreateImplementationPlan): Use performance-profiler for performance estimates

### 2.4 Implementation Order

**Phase 1 (Weeks 1-4)**: Foundational Specialists
1. Syntax Validator (Week 1)
2. Library Navigator (Week 2)
3. Error Diagnostics (Week 3)
4. Tactic Recommender (Week 3-4)

**Phase 2 (Weeks 5-8)**: Development Tools
5. Proof Optimizer (Week 5-6)
6. Test Generator (Week 6)
7. Documentation Generator (Week 7)
8. Code Review Agent (Week 8)

**Phase 3 (Weeks 9-12)**: Advanced Features
9. Refactoring Assistant (Week 9-10)
10. Dependency Analyzer (Week 11-12)

**Phase 4 (Weeks 13-16)**: Analysis & Learning
11. Performance Profiler (Week 13)
12. Proof Strategy Advisor (Week 14-15)
13. Learning Path Generator (Week 15-16)

**Phase 5 (Weeks 17-20)**: Natural Language
14. Concept Explainer (Week 17-18)
15. Integration & Polish (Week 19-20)

---

## 3. Phase-by-Phase Implementation

### Phase 1: Core Infrastructure (Weeks 1-4)

**Goal**: Establish foundational specialists that other agents depend on

**Specialists to Implement**:
1. Syntax Validator Agent
2. Library Navigator Agent
3. Error Diagnostics Specialist
4. Tactic Recommender Agent

**Effort Estimate**: 120-140 person-hours

**Dependencies**: None (foundational phase)

**Success Criteria**:
- ✅ Syntax Validator can validate LEAN files via LSP
- ✅ Library Navigator can search Loogle and LeanSearch
- ✅ Error Diagnostics can categorize errors and suggest fixes
- ✅ Tactic Recommender can suggest tactics for common goals
- ✅ All agents handle tool failures gracefully
- ✅ Caching reduces repeated queries by 60%+

**Deliverables**:
- `.opencode/agent/subagents/specialists/syntax-validator.md`
- `.opencode/agent/subagents/specialists/library-navigator.md`
- `.opencode/agent/subagents/specialists/error-diagnostics.md`
- `.opencode/agent/subagents/specialists/tactic-recommender.md`
- Integration tests for each specialist
- Performance benchmarks

**Risk Mitigation**:
- Start with LSP integration testing before full implementation
- Implement caching early to handle service unavailability
- Create mock services for testing without external dependencies

---

### Phase 2: Development Tools (Weeks 5-8)

**Goal**: Build tools that assist daily proof development

**Specialists to Implement**:
5. Proof Optimizer Agent
6. Test Generator Agent
7. Documentation Generator Agent
8. Code Review Agent

**Effort Estimate**: 100-120 person-hours

**Dependencies**: Phase 1 specialists (Syntax Validator, Library Navigator, Error Diagnostics, Tactic Recommender)

**Success Criteria**:
- ✅ Proof Optimizer finds improvements in 30%+ of proofs
- ✅ Test Generator creates useful tests for 70%+ of theorems
- ✅ Documentation Generator achieves 95%+ coverage
- ✅ Code Review Agent catches 80%+ of style issues
- ✅ False positive rate < 5% for all agents

**Deliverables**:
- `.opencode/agent/subagents/specialists/proof-optimizer.md`
- `.opencode/agent/subagents/specialists/test-generator.md`
- `.opencode/agent/subagents/specialists/documentation-generator.md`
- `.opencode/agent/subagents/specialists/code-reviewer.md`
- Integration with proof-developer.md
- Integration with documenter.md
- Integration with reviewer.md

**Risk Mitigation**:
- Validate all optimizations preserve proof correctness
- Start with conservative suggestions, increase aggressiveness gradually
- Implement user feedback mechanisms early

---

### Phase 3: Advanced Features (Weeks 9-12)

**Goal**: Implement sophisticated refactoring and analysis capabilities

**Specialists to Implement**:
9. Refactoring Assistant
10. Dependency Analyzer

**Effort Estimate**: 80-100 person-hours

**Dependencies**: Phase 1 and 2 specialists

**Success Criteria**:
- ✅ Refactoring Assistant achieves 99%+ success rate
- ✅ Dependency Analyzer detects all circular dependencies
- ✅ Refactorings preserve all proofs
- ✅ Dependency optimizations improve build time by 20%+

**Deliverables**:
- `.opencode/agent/subagents/specialists/refactoring-assistant.md`
- `.opencode/agent/subagents/specialists/dependency-analyzer.md`
- Integration with refactorer.md
- Integration with planner.md
- Comprehensive safety tests

**Risk Mitigation**:
- Implement atomic refactorings (all-or-nothing)
- Extensive testing on real codebase before production use
- Rollback mechanisms for failed refactorings

---

### Phase 4: Analysis & Learning (Weeks 13-16)

**Goal**: Add profiling, learning, and strategic guidance capabilities

**Specialists to Implement**:
11. Performance Profiler
12. Proof Strategy Advisor
13. Learning Path Generator

**Effort Estimate**: 100-120 person-hours

**Dependencies**: Phase 1, 2, and 3 specialists

**Success Criteria**:
- ✅ Performance Profiler identifies bottlenecks with 90%+ accuracy
- ✅ Proof Strategy Advisor provides relevant strategies 75%+ of time
- ✅ Learning Path Generator creates coherent learning paths
- ✅ User satisfaction > 4/5 for all agents

**Deliverables**:
- `.opencode/agent/subagents/specialists/performance-profiler.md`
- `.opencode/agent/subagents/specialists/proof-strategy-advisor.md`
- `.opencode/agent/subagents/specialists/learning-path-generator.md`
- Integration with reviewer.md
- Integration with proof-developer.md
- Performance optimization guide

**Risk Mitigation**:
- Validate profiling accuracy against manual measurements
- Test learning paths with real users
- Iterate on strategy suggestions based on feedback

---

### Phase 5: Natural Language & Polish (Weeks 17-20)

**Goal**: Add natural language explanations and polish entire system

**Specialists to Implement**:
14. Concept Explainer

**Additional Work**:
- System-wide integration testing
- Performance optimization
- Documentation completion
- User interface improvements

**Effort Estimate**: 80-80 person-hours

**Dependencies**: All previous phases

**Success Criteria**:
- ✅ Concept Explainer generates clear explanations (4+/5 rating)
- ✅ All 14 specialists work together seamlessly
- ✅ System performance meets targets
- ✅ Documentation is complete and accurate
- ✅ User satisfaction > 4/5 overall

**Deliverables**:
- `.opencode/agent/subagents/specialists/concept-explainer.md`
- Integration with documenter.md
- System integration tests
- Performance optimization report
- Complete user documentation
- Deployment guide

**Risk Mitigation**:
- LLM API integration may require fallbacks
- Extensive user testing before final release
- Performance profiling of entire system

---

## 4. Detailed Implementation Steps

### 4.1 Syntax Validator Agent

**Location**: `.opencode/agent/subagents/specialists/syntax-validator.md`

**Complexity**: Moderate
**Effort**: 30-35 hours
**Dependencies**: None (foundational)

#### Step 1: Create Agent File
**Action**: Create specialist agent file following subagent template
**Process**:
1. Copy subagent-template.md structure
2. Define agent metadata (description, mode, temperature, tools)
3. Specify context (system, domain, task)
4. Define role and task

**Template**:
```markdown
---
description: "Real-time syntax validation and error detection through LSP integration"
mode: subagent
temperature: 0.1
tools:
  read: true
  write: true
  edit: false
  bash: false
  task: false
  glob: true
  grep: false
---

# Syntax Validator Specialist

<context>
  <specialist_domain>LEAN 4 syntax validation and error detection</specialist_domain>
  <task_scope>Validate LEAN 4 files via LSP, detect errors, cache results</task_scope>
  <integration>Foundational specialist used by all proof development agents</integration>
</context>
```

**Verification**: File structure matches template, metadata is complete

#### Step 2: Define Tool Integration
**Action**: Specify LSP integration details
**Process**:
1. Define LSP connection management
2. Specify diagnostic message handling
3. Define caching strategy
4. Specify error recovery procedures

**LSP Integration**:
```markdown
<lsp_integration>
  <connection>
    - Persistent connection to LEAN LSP server
    - Automatic reconnection on failure
    - Timeout handling (5 seconds default)
    - Connection pooling for multiple files
  </connection>
  
  <diagnostics>
    - Subscribe to textDocument/publishDiagnostics
    - Parse error, warning, info messages
    - Extract location, severity, message
    - Categorize by type (syntax, type, elaboration)
  </diagnostics>
  
  <caching>
    - Cache diagnostics by file path + content hash
    - Invalidate on file change
    - LRU eviction (max 1000 entries)
    - TTL: 5 minutes
  </caching>
</lsp_integration>
```

**Verification**: LSP protocol correctly specified, caching strategy defined

#### Step 3: Implement Core Functionality
**Action**: Define validation workflow
**Process**:
1. Define input parameters (file path, content)
2. Specify validation process flow
3. Define output format (diagnostics array)
4. Specify error handling

**Process Flow**:
```markdown
<process_flow>
  <step_1>
    <action>Check cache for existing diagnostics</action>
    <process>
      1. Compute content hash of file
      2. Look up in cache (file_path + hash)
      3. If found and not expired, return cached diagnostics
      4. Otherwise, proceed to LSP validation
    </process>
    <output>Cached diagnostics or null</output>
  </step_1>
  
  <step_2>
    <action>Validate file via LSP</action>
    <process>
      1. Ensure LSP connection is active
      2. Send textDocument/didOpen or didChange
      3. Wait for publishDiagnostics response (timeout 5s)
      4. Parse diagnostic messages
      5. Categorize by severity and type
    </process>
    <conditions>
      <if test="lsp_unavailable">Use cached results or return error</if>
      <if test="timeout">Retry once, then use cache or error</if>
    </conditions>
    <output>Array of diagnostics</output>
  </step_2>
  
  <step_3>
    <action>Cache and return results</action>
    <process>
      1. Store diagnostics in cache
      2. Update cache statistics
      3. Return diagnostics to caller
    </process>
    <output>Validation result with diagnostics</output>
  </step_3>
</process_flow>
```

**Verification**: Process flow is complete, error handling is robust

#### Step 4: Add Validation
**Action**: Define pre/post execution checks
**Process**:
1. Specify input validation
2. Define output validation
3. Specify success metrics
4. Define quality checks

**Validation Checks**:
```markdown
<validation_checks>
  <pre_execution>
    - Verify file path is valid and exists
    - Check LSP connection is available (or can be established)
    - Validate cache is initialized
    - Ensure file is LEAN 4 (.lean extension)
  </pre_execution>
  
  <post_execution>
    - Verify diagnostics array is well-formed
    - Check all diagnostics have valid locations
    - Ensure severity levels are correct
    - Validate cache was updated
  </post_execution>
  
  <success_metrics>
    - Validation latency < 100ms for cached results
    - Validation latency < 2s for LSP validation
    - Cache hit rate > 60%
    - Error detection accuracy > 99%
    - False positive rate < 1%
  </success_metrics>
</validation_checks>
```

**Verification**: All validation checks are specified, metrics are measurable

#### Step 5: Integration Testing
**Action**: Test with primary agents and commands
**Process**:
1. Test standalone validation
2. Test integration with proof-developer
3. Test integration with refactorer
4. Test performance under load
5. Test error recovery

**Test Cases**:
- Valid LEAN file → no errors
- File with syntax errors → errors detected
- File with type errors → errors detected
- LSP unavailable → graceful degradation
- Rapid file changes → caching works correctly
- Large file (>1000 lines) → acceptable performance

**Verification**: All tests pass, performance meets targets

---

### 4.2 Library Navigator Agent

**Location**: `.opencode/agent/subagents/specialists/library-navigator.md`

**Complexity**: Complex
**Effort**: 35-40 hours
**Dependencies**: None (foundational)

#### Step 1: Create Agent File
**Action**: Create specialist agent file
**Process**: Same as Syntax Validator, adapted for library navigation

**Template**:
```markdown
---
description: "Search and navigate theorem libraries using Loogle and LeanSearch"
mode: subagent
temperature: 0.2
tools:
  read: true
  write: false
  edit: false
  bash: false
  task: false
  glob: false
  grep: false
---

# Library Navigator Specialist

<context>
  <specialist_domain>LEAN 4 library search and navigation</specialist_domain>
  <task_scope>Search Mathlib and other libraries via Loogle and LeanSearch</task_scope>
  <integration>Foundational specialist for finding relevant theorems and definitions</integration>
</context>
```

#### Step 2: Define Tool Integration
**Action**: Specify Loogle and LeanSearch integration
**Process**:
1. Define Loogle API integration
2. Define LeanSearch API integration
3. Specify result ranking algorithm
4. Define caching strategy

**Tool Integration**:
```markdown
<tool_integration>
  <loogle>
    <api>
      - Endpoint: https://loogle.lean-lang.org/api/search
      - Method: GET
      - Parameters: q (query string)
      - Timeout: 3 seconds
      - Retry: 1 time on failure
    </api>
    
    <query_types>
      - By constant: "Real.sin"
      - By name substring: "\"differ\""
      - By pattern: "_ * (_ ^ _)"
      - By conclusion: "|- tsum _ = _ * tsum _"
      - Combined: Multiple filters with AND logic
    </query_types>
    
    <caching>
      - Cache by query string
      - TTL: 24 hours
      - Invalidate on Mathlib update
      - LRU eviction (max 500 queries)
    </caching>
  </loogle>
  
  <lean_search>
    <api>
      - Endpoint: https://leansearch.net/api/search
      - Method: POST
      - Parameters: query (natural language), num_results (default 10)
      - Timeout: 5 seconds
      - Retry: 1 time on failure
    </api>
    
    <query_augmentation>
      - Enable query augmentation for better recall
      - Combine with Loogle for validation
    </query_augmentation>
    
    <caching>
      - Cache by query string
      - TTL: 1 hour (fresher data needed)
      - LRU eviction (max 200 queries)
    </caching>
  </lean_search>
  
  <fallback_chain>
    1. Try LeanSearch (semantic, broad)
    2. If fails, try Loogle (type-based, precise)
    3. If fails, use local cache
    4. If fails, return empty results with error
  </fallback_chain>
</tool_integration>
```

#### Step 3: Implement Core Functionality
**Action**: Define search workflow
**Process**:
1. Define search query types
2. Implement result ranking
3. Define result filtering
4. Specify output format

**Process Flow**:
```markdown
<process_flow>
  <step_1>
    <action>Determine search strategy</action>
    <process>
      1. Analyze query type (natural language vs type pattern)
      2. Select appropriate tool (LeanSearch vs Loogle)
      3. Check cache for existing results
      4. If cached and fresh, return cached results
    </process>
    <output>Search strategy and cached results (if any)</output>
  </step_1>
  
  <step_2>
    <action>Execute search</action>
    <process>
      1. For natural language: Use LeanSearch
      2. For type patterns: Use Loogle
      3. For comprehensive: Use both and merge results
      4. Handle timeouts and errors with fallback chain
      5. Parse and normalize results
    </process>
    <output>Raw search results from tools</output>
  </step_2>
  
  <step_3>
    <action>Rank and filter results</action>
    <process>
      1. Remove duplicates
      2. Rank by relevance (tool score + heuristics)
      3. Filter by context (available imports, goal type)
      4. Limit to top N results (default 20)
      5. Add metadata (source, confidence, usage examples)
    </process>
    <output>Ranked, filtered search results</output>
  </step_3>
  
  <step_4>
    <action>Cache and return</action>
    <process>
      1. Store results in cache
      2. Update cache statistics
      3. Return results with metadata
    </process>
    <output>Search results with metadata</output>
  </step_4>
</process_flow>
```

#### Step 4: Add Validation
**Action**: Define validation checks
**Process**: Similar to Syntax Validator, adapted for search

**Success Metrics**:
- Search precision (relevant results) > 70%
- Search recall (finding known theorems) > 90%
- Average search time < 2 seconds
- Cache hit rate > 60%

#### Step 5: Integration Testing
**Action**: Test search functionality
**Test Cases**:
- Natural language query → relevant results
- Type pattern query → matching theorems
- Combined query → merged results
- Service unavailable → fallback works
- Duplicate results → properly deduplicated

---

### 4.3 Error Diagnostics Specialist

**Location**: `.opencode/agent/subagents/specialists/error-diagnostics.md`

**Complexity**: Moderate
**Effort**: 25-30 hours
**Dependencies**: Syntax Validator, Library Navigator

#### Implementation Steps
Similar structure to above, with focus on:
1. Error categorization (type, elaboration, tactic, import)
2. Fix suggestion generation
3. Pattern matching for common errors
4. Learning from error resolution

---

### 4.4 Tactic Recommender Agent

**Location**: `.opencode/agent/subagents/specialists/tactic-recommender.md`

**Complexity**: Complex
**Effort**: 30-35 hours
**Dependencies**: Syntax Validator, Library Navigator

#### Implementation Steps
Focus on:
1. Goal state analysis
2. Pattern-based recommendations
3. Type-based search for similar goals
4. Success tracking and learning
5. Ranking algorithm

---

### 4.5-4.14 Remaining Specialists

Each specialist follows the same 5-step implementation process:
1. Create Agent File (using template)
2. Define Tool Integration (specify external tools)
3. Implement Core Functionality (process flow)
4. Add Validation (pre/post checks, metrics)
5. Integration Testing (with primary agents)

Detailed specifications for each are provided in the companion document:
`agent-specifications.md`

---

## 5. Integration Plan

### 5.1 Integration with proof-developer.md

**Current Workflow**:
```
Stage 1: LoadImplementationPlan
Stage 2: ImplementStepByStep
  - Route to tactic-specialist
  - Route to term-mode-specialist
  - Route to metaprogramming-specialist
Stage 3: CreateImplementationSummary
Stage 4: UpdateState
Stage 5: ReturnToOrchestrator
```

**Enhanced Workflow**:
```
Stage 1: LoadImplementationPlan
  + Validate plan with syntax-validator
  
Stage 2: ImplementStepByStep
  + Before implementation: Use tactic-recommender for suggestions
  + During implementation: Route to appropriate specialist
  + After implementation: Use syntax-validator for verification
  + On error: Use error-diagnostics for fix suggestions
  + Find lemmas: Use library-navigator
  
Stage 3: CreateImplementationSummary
  (unchanged)
  
Stage 4: UpdateState
  (unchanged)
  
Stage 5: ReturnToOrchestrator
  (unchanged)
```

**Integration Code**:
```markdown
<stage id="2" name="ImplementStepByStep">
  <action>Implement each step using appropriate specialist</action>
  <process>
    For each step in plan:
      1. Get tactic suggestions from tactic-recommender
      2. Find relevant lemmas from library-navigator
      3. Determine implementation approach
      4. Route to appropriate specialist (tactic/term-mode/metaprogramming)
      5. Receive implemented code
      6. Verify using syntax-validator
      7. If errors, use error-diagnostics for fixes
      8. Commit if substantial change
      9. Proceed to next step
  </process>
  
  <routing>
    <route to="@subagents/specialists/tactic-recommender" when="need_suggestions">
      <pass_data>
        - Current goal state
        - Available hypotheses
        - Recent tactics used
      </pass_data>
      <expected_return>
        - Ranked tactic suggestions
        - Rationale for each suggestion
      </expected_return>
    </route>
    
    <route to="@subagents/specialists/library-navigator" when="need_lemmas">
      <pass_data>
        - Goal type
        - Context
        - Search query
      </pass_data>
      <expected_return>
        - Relevant lemmas
        - Usage examples
      </expected_return>
    </route>
    
    <route to="@subagents/specialists/syntax-validator" when="verify_code">
      <pass_data>
        - File path
        - File content
      </pass_data>
      <expected_return>
        - Validation status
        - Diagnostics (if any)
      </expected_return>
    </route>
    
    <route to="@subagents/specialists/error-diagnostics" when="has_errors">
      <pass_data>
        - Error diagnostics
        - Code context
      </pass_data>
      <expected_return>
        - Error explanation
        - Fix suggestions
      </expected_return>
    </route>
  </routing>
</stage>
```

**Testing**:
- Test proof development with suggestions
- Test error recovery with diagnostics
- Test lemma finding with navigator
- Measure improvement in development speed

---

### 5.2 Integration with refactorer.md

**Enhanced Workflow**:
```
Stage 1: AnalyzeRefactoringScope
  + Use code-reviewer for initial analysis
  + Use proof-optimizer for optimization opportunities
  
Stage 2: PerformRefactoring
  + Use refactoring-assistant for safe refactorings
  + Use proof-optimizer for proof simplification
  + Use syntax-validator for verification after each change
  
Stage 3: CreateRefactoringReport
  (unchanged)
```

**Integration Code**: Similar pattern to proof-developer

---

### 5.3 Integration with documenter.md

**Enhanced Workflow**:
```
Stage 1: AnalyzeDocumentationScope
  + Use documentation-generator for gap analysis
  
Stage 2: UpdateDocumentation
  + Use documentation-generator for auto-docs
  + Use test-generator for examples
  + Use concept-explainer for explanations
  + Use syntax-validator to verify examples compile
  
Stage 3: CreateDocumentationSummary
  (unchanged)
```

---

### 5.4 Integration with reviewer.md

**Enhanced Workflow**:
```
Add new stages:
Stage X: CodeReview
  - Use code-reviewer for automated review
  
Stage Y: DependencyAnalysis
  - Use dependency-analyzer for module structure
  
Stage Z: PerformanceCheck
  - Use performance-profiler for performance issues
  
Stage W: ProofOptimization
  - Use proof-optimizer for proof improvements
```

---

### 5.5 Integration with researcher.md

**Enhanced Workflow**:
```
Stage 2: DelegateToSpecialists
  + Replace lean-search-specialist with library-navigator
  + Library-navigator provides unified search across Loogle and LeanSearch
```

---

### 5.6 Integration with planner.md

**Enhanced Workflow**:
```
Stage 3: RouteToDependencyMapper
  + Use dependency-analyzer for code-level dependencies
  
Stage 4: CreateImplementationPlan
  + Use performance-profiler for performance estimates
```

---

## 6. Testing Strategy

### 6.1 Unit Tests

**Purpose**: Test each specialist in isolation

**Test Structure**:
```
tests/specialists/
├── syntax_validator_test.lean
├── library_navigator_test.lean
├── error_diagnostics_test.lean
├── tactic_recommender_test.lean
├── proof_optimizer_test.lean
├── test_generator_test.lean
├── code_reviewer_test.lean
├── documentation_generator_test.lean
├── refactoring_assistant_test.lean
├── dependency_analyzer_test.lean
├── performance_profiler_test.lean
├── learning_path_generator_test.lean
├── proof_strategy_advisor_test.lean
└── concept_explainer_test.lean
```

**Test Cases per Specialist**:
1. **Happy Path**: Normal operation with valid inputs
2. **Error Handling**: Invalid inputs, tool failures
3. **Edge Cases**: Empty inputs, large inputs, boundary conditions
4. **Performance**: Response time, memory usage
5. **Caching**: Cache hits, cache misses, invalidation

**Example Test (Syntax Validator)**:
```lean
-- Test: Valid file with no errors
def test_syntax_validator_valid_file : IO Unit := do
  let validator ← SyntaxValidator.new
  let result ← validator.validate "test_files/valid.lean"
  assert (result.diagnostics.isEmpty)
  assert (result.status == .success)

-- Test: File with syntax errors
def test_syntax_validator_syntax_error : IO Unit := do
  let validator ← SyntaxValidator.new
  let result ← validator.validate "test_files/syntax_error.lean"
  assert (!result.diagnostics.isEmpty)
  assert (result.diagnostics.any (·.severity == .error))

-- Test: LSP unavailable
def test_syntax_validator_lsp_unavailable : IO Unit := do
  let validator ← SyntaxValidator.new
  validator.lsp.disconnect
  let result ← validator.validate "test_files/valid.lean"
  -- Should use cached results or return graceful error
  assert (result.status == .degraded || result.status == .cached)
```

### 6.2 Integration Tests

**Purpose**: Test specialists working with primary agents

**Test Structure**:
```
tests/integration/
├── proof_developer_integration_test.lean
├── refactorer_integration_test.lean
├── documenter_integration_test.lean
├── reviewer_integration_test.lean
├── researcher_integration_test.lean
└── planner_integration_test.lean
```

**Test Scenarios**:
1. **Proof Development**: proof-developer uses syntax-validator, tactic-recommender, library-navigator
2. **Refactoring**: refactorer uses refactoring-assistant, proof-optimizer, syntax-validator
3. **Documentation**: documenter uses documentation-generator, test-generator, concept-explainer
4. **Code Review**: reviewer uses code-reviewer, dependency-analyzer, performance-profiler

**Example Test (Proof Development)**:
```lean
-- Test: Develop proof with specialist assistance
def test_proof_development_with_specialists : IO Unit := do
  let developer ← ProofDeveloper.new
  let plan ← loadPlan "test_plans/simple_theorem.md"
  
  -- Should use syntax-validator for validation
  -- Should use tactic-recommender for suggestions
  -- Should use library-navigator for lemmas
  let result ← developer.implement plan
  
  assert (result.status == .completed)
  assert (result.files_modified.contains "Logos/Test/SimpleTheorem.lean")
  assert (result.verification_status == .passed)
```

### 6.3 End-to-End Tests

**Purpose**: Test complete workflows from user request to completion

**Test Scenarios**:
1. **Complete Proof Development**: Plan → Implement → Verify → Document
2. **Complete Refactoring**: Analyze → Refactor → Verify → Review
3. **Complete Research**: Research → Plan → Implement → Document

**Example Test**:
```lean
-- Test: Complete proof development workflow
def test_complete_proof_workflow : IO Unit := do
  -- 1. Research phase
  let researcher ← Researcher.new
  let research ← researcher.research "bimodal logic soundness"
  
  -- 2. Planning phase
  let planner ← Planner.new
  let plan ← planner.createPlan research
  
  -- 3. Implementation phase
  let developer ← ProofDeveloper.new
  let impl ← developer.implement plan
  
  -- 4. Review phase
  let reviewer ← Reviewer.new
  let review ← reviewer.review impl
  
  -- 5. Documentation phase
  let documenter ← Documenter.new
  let docs ← documenter.document impl
  
  -- Verify entire workflow succeeded
  assert (research.status == .completed)
  assert (plan.status == .completed)
  assert (impl.status == .completed)
  assert (review.status == .passed)
  assert (docs.status == .completed)
```

### 6.4 Performance Tests

**Purpose**: Ensure specialists meet performance targets

**Metrics to Measure**:
- Response time (p50, p95, p99)
- Memory usage
- Cache hit rate
- Throughput (requests per second)

**Performance Targets**:
| Specialist | Response Time (p95) | Memory Usage | Cache Hit Rate |
|------------|---------------------|--------------|----------------|
| Syntax Validator | < 2s | < 100MB | > 60% |
| Library Navigator | < 3s | < 200MB | > 60% |
| Error Diagnostics | < 500ms | < 50MB | > 70% |
| Tactic Recommender | < 1s | < 150MB | > 50% |
| Proof Optimizer | < 5s | < 200MB | N/A |
| Test Generator | < 5s | < 100MB | N/A |
| Code Review Agent | < 10s | < 300MB | N/A |
| Documentation Generator | < 30s | < 200MB | N/A |
| Refactoring Assistant | < 10s | < 150MB | N/A |
| Dependency Analyzer | < 5s | < 100MB | > 80% |
| Performance Profiler | < 10s | < 150MB | N/A |
| Learning Path Generator | < 10s | < 200MB | > 70% |
| Proof Strategy Advisor | < 2s | < 100MB | > 60% |
| Concept Explainer | < 10s | < 200MB | > 50% |

**Performance Test Example**:
```lean
-- Test: Syntax validator performance
def test_syntax_validator_performance : IO Unit := do
  let validator ← SyntaxValidator.new
  let files := ["file1.lean", "file2.lean", ..., "file100.lean"]
  
  let start ← IO.monoMsNow
  let results ← files.mapM validator.validate
  let end ← IO.monoMsNow
  
  let duration := end - start
  let avgTime := duration / files.length
  
  assert (avgTime < 2000) -- < 2s average
  assert (validator.cacheHitRate > 0.6) -- > 60% cache hits
```

### 6.5 Validation Tests

**Purpose**: Verify specialists meet success metrics from research report

**Validation Criteria**:
| Specialist | Success Metric | Target |
|------------|----------------|--------|
| Syntax Validator | Error detection accuracy | > 99% |
| Library Navigator | Search precision | > 70% |
| Error Diagnostics | Fix acceptance rate | > 60% |
| Tactic Recommender | Top-3 acceptance rate | > 40% |
| Proof Optimizer | Proof size reduction | 20% avg |
| Test Generator | Test usefulness rating | > 4/5 |
| Code Review Agent | True positive rate | > 90% |
| Documentation Generator | Documentation coverage | > 95% |
| Refactoring Assistant | Success rate | > 99% |
| Dependency Analyzer | Circular dep detection | 100% |
| Performance Profiler | Bottleneck detection accuracy | > 90% |
| Learning Path Generator | Learning goal achievement | > 70% |
| Proof Strategy Advisor | Strategy relevance | > 75% |
| Concept Explainer | Explanation clarity rating | > 4/5 |

---

## 7. Risk Management

### 7.1 High-Priority Risks

#### Risk 1: LSP Stability Issues
**Description**: LSP server may crash, hang, or become unresponsive
**Probability**: Medium (30-40%)
**Impact**: High (blocks syntax validation, type checking)
**Severity**: **HIGH**

**Mitigation Strategies**:
1. **Automatic Reconnection**:
   - Detect LSP crashes via heartbeat
   - Automatically reconnect with exponential backoff
   - Queue requests during reconnection

2. **Timeout Handling**:
   - Set aggressive timeouts (5s for validation)
   - Cancel hung requests
   - Fall back to cached results

3. **Caching**:
   - Cache all LSP responses
   - Use cached results when LSP unavailable
   - Invalidate cache on file changes

4. **Graceful Degradation**:
   - Provide degraded service without LSP
   - Use syntax-only validation as fallback
   - Clearly communicate degraded state to user

**Monitoring**:
- Track LSP uptime percentage
- Monitor reconnection frequency
- Alert on repeated failures

**Contingency Plan**:
- If LSP repeatedly fails, disable LSP-dependent features
- Provide manual validation option
- Document LSP troubleshooting steps

---

#### Risk 2: Search Service Availability
**Description**: Loogle or LeanSearch may be down or slow
**Probability**: Medium (20-30%)
**Impact**: Medium (reduces library navigation effectiveness)
**Severity**: **MEDIUM**

**Mitigation Strategies**:
1. **Fallback Chain**:
   - LeanSearch → Loogle → Local Cache → Empty Results
   - Each fallback has timeout
   - Track which fallback was used

2. **Aggressive Caching**:
   - Cache all search results
   - Long TTL (24h for Loogle, 1h for LeanSearch)
   - Serve stale results if services down

3. **Local Search Fallback**:
   - Implement basic local search
   - Index common Mathlib theorems
   - Use when remote services unavailable

4. **Circuit Breaker**:
   - Stop trying service after N failures
   - Periodically test if service recovered
   - Automatically resume when available

**Monitoring**:
- Track service availability percentage
- Monitor response times
- Alert on prolonged outages

**Contingency Plan**:
- Maintain local Mathlib index
- Provide offline search capability
- Document manual search procedures

---

#### Risk 3: Performance Too Slow
**Description**: Specialists may be too slow for interactive use
**Probability**: Medium (30-40%)
**Impact**: High (poor user experience, low adoption)
**Severity**: **HIGH**

**Mitigation Strategies**:
1. **Aggressive Caching**:
   - Cache everything possible
   - Optimize cache hit rate
   - Use fast cache storage (in-memory)

2. **Async Operations**:
   - Make all operations asynchronous
   - Don't block on slow operations
   - Provide progress indicators

3. **Incremental Updates**:
   - Only revalidate changed files
   - Use incremental compilation
   - Avoid full project scans

4. **Performance Profiling**:
   - Profile all operations
   - Identify bottlenecks early
   - Optimize hot paths

**Monitoring**:
- Track p95/p99 response times
- Monitor cache hit rates
- Alert on performance degradation

**Contingency Plan**:
- Disable slow features if needed
- Provide "fast mode" with reduced functionality
- Optimize critical paths first

---

#### Risk 4: Suggestion Accuracy
**Description**: Specialists may provide incorrect or irrelevant suggestions
**Probability**: High (40-50%)
**Impact**: Medium (user trust erosion, wasted time)
**Severity**: **MEDIUM**

**Mitigation Strategies**:
1. **Validation**:
   - Validate all suggestions before presenting
   - Use syntax-validator to check correctness
   - Filter out invalid suggestions

2. **User Feedback**:
   - Track which suggestions are accepted/rejected
   - Learn from feedback
   - Improve ranking over time

3. **Conservative Suggestions**:
   - Start with high-confidence suggestions only
   - Gradually increase aggressiveness
   - Clearly indicate confidence level

4. **Explanation**:
   - Explain why suggestion was made
   - Provide rationale
   - Help user understand suggestion

**Monitoring**:
- Track acceptance rates
- Monitor user feedback
- Alert on low acceptance rates

**Contingency Plan**:
- Reduce suggestion aggressiveness
- Focus on high-confidence suggestions
- Provide manual override option

---

### 7.2 Medium-Priority Risks

#### Risk 5: Agent Coordination Complexity
**Description**: Managing 14+ agents may be too complex
**Probability**: Medium (30%)
**Impact**: Medium (development slowdown, bugs)
**Severity**: **MEDIUM**

**Mitigation**:
- Clear interfaces between agents
- Comprehensive integration tests
- Incremental integration (phase by phase)
- Good documentation

---

#### Risk 6: Context Management
**Description**: Context may grow too large, causing performance issues
**Probability**: Medium (30%)
**Impact**: Medium (performance degradation)
**Severity**: **MEDIUM**

**Mitigation**:
- Strict context size limits
- Summarization when needed
- Context prioritization
- Regular context cleanup

---

#### Risk 7: Tool Version Compatibility
**Description**: LEAN 4 and tools may evolve, breaking compatibility
**Probability**: Low (20%)
**Impact**: Medium (features break)
**Severity**: **MEDIUM**

**Mitigation**:
- Version checking on startup
- Compatibility layers
- Graceful degradation
- Regular updates

---

### 7.3 Risk Monitoring Dashboard

**Metrics to Track**:
- LSP uptime percentage
- Search service availability
- Average response times (p50, p95, p99)
- Cache hit rates
- Suggestion acceptance rates
- Error rates
- User satisfaction scores

**Alerts**:
- LSP uptime < 95%
- Search service unavailable > 1 hour
- Response time p95 > 2x target
- Cache hit rate < 50%
- Acceptance rate < 30%
- Error rate > 5%

---

## 8. Success Metrics

### 8.1 Individual Specialist Metrics

| Specialist | Metric | Target | Measurement Method |
|------------|--------|--------|-------------------|
| **Syntax Validator** | Validation latency (cached) | < 100ms | Automated performance tests |
| | Validation latency (LSP) | < 2s | Automated performance tests |
| | Error detection accuracy | > 99% | Manual validation on test corpus |
| | False positive rate | < 1% | Manual validation on test corpus |
| | Cache hit rate | > 60% | Runtime statistics |
| **Library Navigator** | Search precision | > 70% | Manual relevance assessment |
| | Search recall | > 90% | Test with known theorems |
| | Average search time | < 2s | Automated performance tests |
| | Cache hit rate | > 60% | Runtime statistics |
| **Error Diagnostics** | Fix acceptance rate | > 60% | User feedback tracking |
| | Explanation clarity | > 4/5 | User surveys |
| | Diagnostic time | < 200ms | Automated performance tests |
| | Repeated error reduction | > 30% | Longitudinal analysis |
| **Tactic Recommender** | Top-3 acceptance rate | > 40% | User feedback tracking |
| | Average response time | < 500ms | Automated performance tests |
| | Goal pattern coverage | > 90% | Test on diverse goals |
| | User satisfaction | > 4/5 | User surveys |
| **Proof Optimizer** | Proof size reduction | 20% avg | Automated analysis |
| | Compilation time improvement | 15% avg | Build time comparison |
| | Redundancy detection rate | > 85% | Manual validation |
| | Suggestion acceptance rate | > 50% | User feedback tracking |
| **Test Generator** | Test coverage | > 80% | Coverage analysis |
| | Counterexample finding rate | > 70% | Test on false theorems |
| | Example usefulness | > 4/5 | User surveys |
| | Generation time | < 5s | Automated performance tests |
| **Code Review Agent** | False positive rate | < 5% | Manual validation |
| | True positive rate | > 90% | Manual validation |
| | Review time | < 2 min | Automated performance tests |
| | Developer satisfaction | > 4/5 | User surveys |
| **Documentation Generator** | Documentation coverage | > 95% | Automated coverage analysis |
| | Example compilation rate | 100% | Automated compilation tests |
| | User satisfaction | > 4/5 | User surveys |
| | Generation time | < 30s/module | Automated performance tests |
| **Refactoring Assistant** | Success rate | > 99% | Automated validation |
| | Rollback rate | < 1% | Runtime statistics |
| | Refactoring time | < 10s | Automated performance tests |
| | User confidence | > 4.5/5 | User surveys |
| **Dependency Analyzer** | Circular dep detection | 100% | Test on known cycles |
| | Import bloat detection | > 85% | Manual validation |
| | Build time improvement | > 20% | Build time comparison |
| | Suggestion acceptance | > 70% | User feedback tracking |
| **Performance Profiler** | Profiling overhead | < 10% | Automated measurement |
| | Bottleneck detection accuracy | > 90% | Manual validation |
| | Optimization improvement | > 25% avg | Performance comparison |
| | Suggested optimizations work | > 80% | Automated validation |
| **Learning Path Generator** | Goal achievement rate | > 70% | User progress tracking |
| | User satisfaction | > 4/5 | User surveys |
| | Exercise completion rate | > 80% | User progress tracking |
| | Time to competency reduction | -30% | Comparison study |
| **Proof Strategy Advisor** | Strategy relevance | > 75% | User feedback tracking |
| | Skeleton usefulness | > 60% | Code retention analysis |
| | Time to first proof reduction | -40% | Comparison study |
| | User satisfaction | > 4/5 | User surveys |
| **Concept Explainer** | Explanation clarity | > 4/5 | User surveys |
| | Comprehension improvement | > 50% | Quiz-based assessment |
| | Generation time | < 10s | Automated performance tests |
| | User preference | > 60% | Comparison study |

### 8.2 Integration Quality Metrics

**Metric**: How well specialists work together
**Targets**:
- No conflicts between specialists: 100%
- Coordination overhead < 10% of total time
- Context sharing works correctly: 100%
- Error propagation handled correctly: 100%

**Measurement**:
- Integration tests
- End-to-end workflow tests
- Performance profiling
- Error injection tests

### 8.3 Overall System Metrics

**Metric**: End-to-end workflow improvements
**Targets**:
- Proof development time reduction: 30-40%
- Code quality improvement: 25% (fewer issues)
- Documentation completeness: 95%+
- Build time reduction: 20%+
- User satisfaction: > 4/5

**Measurement**:
- Before/after comparison studies
- User surveys
- Automated quality metrics
- Build time tracking

### 8.4 User Satisfaction Metrics

**Metric**: Developer experience improvements
**Targets**:
- Overall satisfaction: > 4/5
- Would recommend to colleague: > 80%
- Daily active usage: > 70% of developers
- Feature adoption rate: > 60%

**Measurement**:
- Regular user surveys (monthly)
- Usage analytics
- Feature adoption tracking
- Net Promoter Score (NPS)

---

## 9. Timeline and Milestones

### 9.1 Phase 1: Core Infrastructure (Weeks 1-4)

**Week 1**: Syntax Validator
- Days 1-2: Create agent file, define LSP integration
- Days 3-4: Implement core functionality
- Day 5: Testing and validation

**Milestone 1.1**: Syntax Validator operational (End of Week 1)
- ✅ Can validate LEAN files via LSP
- ✅ Handles LSP failures gracefully
- ✅ Caching works correctly
- ✅ Performance meets targets

**Week 2**: Library Navigator
- Days 1-2: Create agent file, define Loogle/LeanSearch integration
- Days 3-4: Implement search and ranking
- Day 5: Testing and validation

**Milestone 1.2**: Library Navigator operational (End of Week 2)
- ✅ Can search Loogle and LeanSearch
- ✅ Result ranking works correctly
- ✅ Fallback chain works
- ✅ Performance meets targets

**Week 3**: Error Diagnostics
- Days 1-2: Create agent file, define error categorization
- Days 3-4: Implement fix suggestions
- Day 5: Testing and validation

**Milestone 1.3**: Error Diagnostics operational (End of Week 3)
- ✅ Can categorize errors correctly
- ✅ Generates useful fix suggestions
- ✅ Learning mechanism works
- ✅ Performance meets targets

**Week 4**: Tactic Recommender
- Days 1-3: Create agent file, implement pattern matching
- Days 4-5: Implement ranking and learning

**Milestone 1.4**: Phase 1 Complete (End of Week 4)
- ✅ All 4 foundational specialists operational
- ✅ Integration tests pass
- ✅ Performance benchmarks met
- ✅ Ready for Phase 2

---

### 9.2 Phase 2: Development Tools (Weeks 5-8)

**Week 5-6**: Proof Optimizer
- Week 5: Redundancy detection, library lemma search
- Week 6: Aesop integration, testing

**Milestone 2.1**: Proof Optimizer operational (End of Week 6)

**Week 6**: Test Generator
- Days 1-3: Random generation, edge cases
- Days 4-5: Counterexample search, testing

**Milestone 2.2**: Test Generator operational (End of Week 6)

**Week 7**: Documentation Generator
- Days 1-3: Template generation, example extraction
- Days 4-5: Integration with Test Generator, testing

**Milestone 2.3**: Documentation Generator operational (End of Week 7)

**Week 8**: Code Review Agent
- Days 1-3: Multi-specialist coordination
- Days 4-5: Prioritization, testing

**Milestone 2.4**: Phase 2 Complete (End of Week 8)
- ✅ All 4 development tool specialists operational
- ✅ Integration with proof-developer works
- ✅ Integration with documenter works
- ✅ Ready for Phase 3

---

### 9.3 Phase 3: Advanced Features (Weeks 9-12)

**Week 9-10**: Refactoring Assistant
- Week 9: Safe renames, extract lemma
- Week 10: Move operations, testing

**Milestone 3.1**: Refactoring Assistant operational (End of Week 10)

**Week 11-12**: Dependency Analyzer
- Week 11: Graph construction, cycle detection
- Week 12: Optimization suggestions, testing

**Milestone 3.2**: Phase 3 Complete (End of Week 12)
- ✅ Both advanced specialists operational
- ✅ Integration with refactorer works
- ✅ Integration with planner works
- ✅ Ready for Phase 4

---

### 9.4 Phase 4: Analysis & Learning (Weeks 13-16)

**Week 13**: Performance Profiler
- Days 1-3: Timing measurement, bottleneck identification
- Days 4-5: Suggestion generation, testing

**Milestone 4.1**: Performance Profiler operational (End of Week 13)

**Week 14-15**: Proof Strategy Advisor
- Week 14: Pattern recognition, strategy database
- Week 15: Skeleton generation, testing

**Milestone 4.2**: Proof Strategy Advisor operational (End of Week 15)

**Week 15-16**: Learning Path Generator
- Week 15: Concept graph construction
- Week 16: Path generation, exercise generation, testing

**Milestone 4.3**: Phase 4 Complete (End of Week 16)
- ✅ All 3 analysis/learning specialists operational
- ✅ Integration with reviewer works
- ✅ Integration with proof-developer works
- ✅ Ready for Phase 5

---

### 9.5 Phase 5: Natural Language & Polish (Weeks 17-20)

**Week 17-18**: Concept Explainer
- Week 17: NLG integration, explanation generation
- Week 18: Level adaptation, testing

**Milestone 5.1**: Concept Explainer operational (End of Week 18)

**Week 19**: System Integration
- Days 1-2: End-to-end integration testing
- Days 3-4: Performance optimization
- Day 5: Bug fixes

**Milestone 5.2**: System Integration Complete (End of Week 19)

**Week 20**: Final Polish
- Days 1-2: Documentation completion
- Days 3-4: User interface improvements
- Day 5: Final testing and release preparation

**Milestone 5.3**: Project Complete (End of Week 20)
- ✅ All 14 specialists operational
- ✅ All integrations working
- ✅ Performance targets met
- ✅ Documentation complete
- ✅ Ready for production use

---

## 10. Conclusion

This implementation plan provides a comprehensive roadmap for building 14 specialist agents for the LEAN 4 ProofChecker project. The plan is structured into 5 phases over 20 weeks, with clear dependencies, success criteria, and risk mitigation strategies.

**Key Success Factors**:
1. **Foundational-First Approach**: Build core infrastructure before advanced features
2. **Incremental Integration**: Integrate specialists phase by phase
3. **Robust Error Handling**: Handle tool failures gracefully
4. **Aggressive Caching**: Optimize performance through caching
5. **User Feedback**: Learn from user interactions
6. **Comprehensive Testing**: Test at unit, integration, and end-to-end levels

**Expected Outcomes**:
- 30-40% reduction in proof development time
- 25% improvement in code quality
- 95%+ documentation completeness
- 20%+ build time reduction
- > 4/5 user satisfaction

**Next Steps**:
1. Review and approve this implementation plan
2. Begin Phase 1 implementation (Syntax Validator)
3. Set up testing infrastructure
4. Establish monitoring and metrics collection
5. Create project tracking dashboard

---

**Plan Status**: Ready for Implementation
**Approval Required**: Yes
**Estimated Start Date**: Upon approval
**Estimated Completion Date**: 20 weeks from start

---

*This implementation plan is based on the comprehensive research report in `.opencode/specs/002_system_enhancements_research/reports/specialist-agents-web-research.md` and follows existing patterns in `.opencode/agent/`.*
