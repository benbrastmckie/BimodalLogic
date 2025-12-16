# Integration Guide: Specialist Agents with Primary Agents

**Project**: #003
**Version**: 001
**Date**: December 16, 2025

---

## Table of Contents

1. [Integration Overview](#1-integration-overview)
2. [Integration Patterns](#2-integration-patterns)
3. [Context Passing Strategies](#3-context-passing-strategies)
4. [Error Handling](#4-error-handling)
5. [Primary Agent Integrations](#5-primary-agent-integrations)
6. [Examples](#6-examples)

---

## 1. Integration Overview

### 1.1 Purpose

This guide explains how to integrate the 14 specialist agents into existing primary agents (researcher, proof-developer, refactorer, documenter, reviewer, planner).

### 1.2 Integration Principles

**Single Responsibility**: Each specialist does one thing well
**Loose Coupling**: Specialists communicate through well-defined interfaces
**Context Protection**: Pass only necessary context to specialists
**Error Isolation**: Specialist failures don't crash primary agents
**Graceful Degradation**: System works even if specialists unavailable

### 1.3 Integration Architecture

```
Primary Agent (Orchestrator)
├── Calls Specialist 1 with specific context
│   └── Receives structured result
├── Calls Specialist 2 with specific context
│   └── Receives structured result
└── Synthesizes results and continues workflow
```

**Key Points**:
- Primary agents orchestrate specialists
- Specialists are stateless (no conversation history)
- Each call includes ALL necessary information
- Results are structured (YAML/JSON)
- Errors are handled gracefully

---

## 2. Integration Patterns

### 2.1 Request-Response Pattern

**Use Case**: Simple, synchronous specialist calls

**Pattern**:
```yaml
primary_agent:
  action: "Call specialist"
  process:
    - "Prepare specialist input"
    - "Call specialist with input"
    - "Wait for response"
    - "Process response"
    - "Continue workflow"
```

**Example**:
```markdown
<route to="@subagents/specialists/syntax-validator">
  <pass_data>
    - file_path: "Logos/Core/Syntax.lean"
    - content: "theorem example : 1 + 1 = 2 := rfl"
    - validation_level: "full"
  </pass_data>
  <expected_return>
    - status: "success" | "error"
    - diagnostics: array
    - metadata: object
  </expected_return>
</route>
```

### 2.2 Pipeline Pattern

**Use Case**: Sequential specialist calls where output of one feeds into next

**Pattern**:
```yaml
primary_agent:
  action: "Pipeline specialists"
  process:
    - "Call Specialist A"
    - "Pass A's output to Specialist B"
    - "Pass B's output to Specialist C"
    - "Return final result"
```

**Example**:
```markdown
<!-- Proof development pipeline -->
<pipeline>
  <step_1>
    <specialist>tactic-recommender</specialist>
    <input>goal_state</input>
    <output>tactic_suggestions</output>
  </step_1>
  
  <step_2>
    <specialist>library-navigator</specialist>
    <input>tactic_suggestions.required_lemmas</input>
    <output>relevant_lemmas</output>
  </step_2>
  
  <step_3>
    <specialist>syntax-validator</specialist>
    <input>implemented_proof</input>
    <output>validation_result</output>
  </step_3>
</pipeline>
```

### 2.3 Parallel Pattern

**Use Case**: Multiple specialists can run concurrently

**Pattern**:
```yaml
primary_agent:
  action: "Call specialists in parallel"
  process:
    - "Launch Specialist A (async)"
    - "Launch Specialist B (async)"
    - "Launch Specialist C (async)"
    - "Wait for all to complete"
    - "Combine results"
```

**Example**:
```markdown
<!-- Code review with multiple specialists -->
<parallel>
  <specialist_1>
    <name>code-reviewer</name>
    <input>changeset</input>
  </specialist_1>
  
  <specialist_2>
    <name>dependency-analyzer</name>
    <input>changeset</input>
  </specialist_2>
  
  <specialist_3>
    <name>performance-profiler</name>
    <input>changeset</input>
  </specialist_3>
  
  <combine>
    <action>Merge all reports into comprehensive review</action>
  </combine>
</parallel>
```

### 2.4 Conditional Pattern

**Use Case**: Call specialist only if certain conditions met

**Pattern**:
```yaml
primary_agent:
  action: "Conditionally call specialist"
  process:
    - "Check condition"
    - "If condition true, call specialist"
    - "Otherwise, skip or use default"
```

**Example**:
```markdown
<conditional>
  <condition>has_errors</condition>
  <if_true>
    <route to="@subagents/specialists/error-diagnostics">
      <pass_data>
        - diagnostic: error_object
        - code_context: context_object
      </pass_data>
    </route>
  </if_true>
  <if_false>
    <action>Continue without error diagnostics</action>
  </if_false>
</conditional>
```

### 2.5 Retry Pattern

**Use Case**: Retry specialist call on failure

**Pattern**:
```yaml
primary_agent:
  action: "Call specialist with retry"
  process:
    - "Try calling specialist"
    - "If fails, wait and retry"
    - "If still fails, use fallback or error"
```

**Example**:
```markdown
<retry>
  <specialist>library-navigator</specialist>
  <max_attempts>3</max_attempts>
  <backoff>exponential</backoff>
  <fallback>
    <action>Use cached results or return empty</action>
  </fallback>
</retry>
```

---

## 3. Context Passing Strategies

### 3.1 Minimal Context Principle

**Rule**: Pass only what the specialist needs, nothing more

**Why**: 
- Reduces context size
- Improves performance
- Prevents information overload
- Maintains specialist focus

**Example**:
```yaml
# BAD: Passing entire project state
pass_data:
  - entire_project_state
  - all_files
  - complete_history

# GOOD: Passing only what's needed
pass_data:
  - file_path: "specific/file.lean"
  - goal_state: current_goal
  - available_imports: ["Import1", "Import2"]
```

### 3.2 Structured Context

**Rule**: Pass context as structured data (YAML/JSON), not prose

**Why**:
- Specialists can parse reliably
- No ambiguity
- Easy to validate
- Efficient processing

**Example**:
```yaml
# BAD: Prose description
pass_data:
  - "Please validate the file at Logos/Core/Syntax.lean which contains a theorem about addition"

# GOOD: Structured data
pass_data:
  file_path: "Logos/Core/Syntax.lean"
  validation_level: "full"
  use_cache: true
```

### 3.3 Context Levels

**Level 1 (Minimal)**: Only task-specific data
- Use for: Simple, focused specialists
- Example: Syntax Validator (just file path)

**Level 2 (Standard)**: Task data + relevant standards/patterns
- Use for: Most specialists
- Example: Tactic Recommender (goal + patterns)

**Level 3 (Extended)**: Task data + standards + domain knowledge
- Use for: Complex specialists needing broader context
- Example: Concept Explainer (concept + domain + user level)

**Example**:
```yaml
# Level 1: Minimal
syntax_validator_input:
  file_path: "file.lean"
  content: "theorem ..."

# Level 2: Standard
tactic_recommender_input:
  goal: "∀ x, P x"
  context:
    recent_tactics: ["intro", "cases"]
    available_lemmas: ["lemma1", "lemma2"]
  patterns: "lean4/patterns/tactic-patterns.md"

# Level 3: Extended
concept_explainer_input:
  concept: "Ring Homomorphism"
  domain_knowledge: "lean4/domain/algebra.md"
  user_level: "intermediate"
  related_concepts: ["Ring", "Homomorphism", "Group"]
```

### 3.4 Context Validation

**Rule**: Validate context before passing to specialist

**Validation Checks**:
- Required fields present
- Types correct
- Values in valid range
- References exist (files, imports, etc.)

**Example**:
```markdown
<pre_specialist_call>
  <validate>
    - Check file_path exists
    - Check validation_level is valid enum
    - Check use_cache is boolean
    - Check content is string (if provided)
  </validate>
  
  <on_validation_failure>
    - Log error
    - Return error to caller
    - Do not call specialist
  </on_validation_failure>
</pre_specialist_call>
```

---

## 4. Error Handling

### 4.1 Error Types

**Specialist Errors**:
- Specialist unavailable
- Specialist timeout
- Specialist returns error
- Invalid specialist response

**Tool Errors**:
- LSP unavailable
- Loogle/LeanSearch down
- Aesop fails
- Lake build fails

**Data Errors**:
- Invalid input
- Missing required data
- Malformed response

### 4.2 Error Handling Strategy

**Graceful Degradation**:
```yaml
error_handling:
  specialist_unavailable:
    action: "Use cached results or continue without specialist"
    log: "Warning: Specialist X unavailable, using fallback"
  
  specialist_timeout:
    action: "Cancel request, use cached results or continue"
    log: "Warning: Specialist X timed out after Ns"
  
  specialist_error:
    action: "Log error, use fallback or continue"
    log: "Error: Specialist X returned error: {message}"
  
  invalid_response:
    action: "Log error, treat as specialist error"
    log: "Error: Specialist X returned invalid response"
```

**Example**:
```markdown
<error_handling>
  <try>
    <route to="@subagents/specialists/library-navigator">
      <pass_data>query, search_mode, max_results</pass_data>
      <timeout>5s</timeout>
    </route>
  </try>
  
  <catch error="timeout">
    <action>Use cached search results if available</action>
    <log>Library Navigator timed out, using cache</log>
  </catch>
  
  <catch error="unavailable">
    <action>Continue without library search</action>
    <log>Library Navigator unavailable, skipping search</log>
  </catch>
  
  <catch error="invalid_response">
    <action>Treat as empty results</action>
    <log>Library Navigator returned invalid response</log>
  </catch>
</error_handling>
```

### 4.3 Fallback Chains

**Pattern**: Try primary → fallback 1 → fallback 2 → default

**Example**:
```yaml
fallback_chain:
  primary:
    action: "Call Library Navigator (LeanSearch + Loogle)"
  
  fallback_1:
    condition: "primary fails"
    action: "Use cached search results"
  
  fallback_2:
    condition: "fallback_1 fails (no cache)"
    action: "Use local Mathlib index"
  
  default:
    condition: "all fallbacks fail"
    action: "Return empty results with error message"
```

### 4.4 Error Reporting

**To User**:
- Clear, actionable error messages
- Suggest remediation steps
- Indicate degraded functionality

**To Logs**:
- Detailed error information
- Stack traces
- Context at time of error
- Specialist input/output

**Example**:
```yaml
error_report:
  user_message: "Library search unavailable. Continuing without search results."
  
  log_entry:
    timestamp: "2025-12-16T10:30:45Z"
    level: "WARNING"
    specialist: "library-navigator"
    error: "Connection timeout to LeanSearch API"
    input:
      query: "ring homomorphisms"
      search_mode: "semantic"
    attempted_fallbacks:
      - "Loogle API (also timed out)"
      - "Cache (no cached results)"
    resolution: "Returned empty results"
```

---

## 5. Primary Agent Integrations

### 5.1 proof-developer.md Integration

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
```markdown
<stage id="1" name="LoadImplementationPlan">
  <action>Load and parse implementation plan</action>
  <process>
    1. Read implementation plan
    2. Parse implementation steps
    3. **NEW: Validate plan with syntax-validator**
    4. Prepare lean-lsp-mcp configuration
    5. Create implementation tracking
  </process>
  
  <validation>
    <route to="@subagents/specialists/syntax-validator">
      <pass_data>
        file_path: plan_file_path
        validation_level: "syntax_only"
      </pass_data>
      <expected_return>
        status: "success" | "error"
        diagnostics: array
      </expected_return>
    </route>
  </validation>
</stage>

<stage id="2" name="ImplementStepByStep">
  <action>Implement each step using appropriate specialist</action>
  <process>
    For each step in plan:
      **NEW: 1. Get tactic suggestions**
      <route to="@subagents/specialists/tactic-recommender">
        <pass_data>
          goal: current_goal_state
          context:
            recent_tactics: recent_tactics_used
            available_lemmas: available_lemmas
        </pass_data>
        <expected_return>
          suggestions: array[tactic_suggestion]
        </expected_return>
      </route>
      
      **NEW: 2. Find relevant lemmas**
      <route to="@subagents/specialists/library-navigator">
        <pass_data>
          query: goal_description
          search_mode: "auto"
          max_results: 10
        </pass_data>
        <expected_return>
          results: array[search_result]
        </expected_return>
      </route>
      
      3. Determine implementation approach
      4. Route to appropriate specialist (tactic/term-mode/metaprogramming)
      5. Receive implemented code
      
      **NEW: 6. Verify using syntax-validator**
      <route to="@subagents/specialists/syntax-validator">
        <pass_data>
          file_path: implemented_file
          validation_level: "full"
        </pass_data>
        <expected_return>
          status: "success" | "error"
          diagnostics: array
        </expected_return>
      </route>
      
      **NEW: 7. If errors, use error-diagnostics**
      <conditional>
        <condition>has_errors</condition>
        <if_true>
          <route to="@subagents/specialists/error-diagnostics">
            <pass_data>
              diagnostic: error_diagnostic
              code_context: code_context
            </pass_data>
            <expected_return>
              explanation: string
              fix_suggestions: array
            </expected_return>
          </route>
        </if_true>
      </conditional>
      
      8. Commit if substantial change
      9. Proceed to next step
  </process>
</stage>
```

**Integration Points Summary**:
| Stage | Specialist | Purpose | When |
|-------|-----------|---------|------|
| 1 | syntax-validator | Validate plan file | Always |
| 2 | tactic-recommender | Suggest tactics | Before implementation |
| 2 | library-navigator | Find lemmas | Before implementation |
| 2 | syntax-validator | Verify code | After implementation |
| 2 | error-diagnostics | Fix errors | If errors occur |

---

### 5.2 refactorer.md Integration

**Current Workflow**:
```
Stage 1: AnalyzeRefactoringScope
Stage 2: PerformRefactoring
Stage 3: CreateRefactoringReport
Stage 4: ReturnToOrchestrator
```

**Enhanced Workflow**:
```markdown
<stage id="1" name="AnalyzeRefactoringScope">
  <action>Determine what needs refactoring</action>
  <process>
    1. Identify files to refactor
    2. Create project directory
    
    **NEW: 3. Use code-reviewer for initial analysis**
    <route to="@subagents/specialists/code-reviewer">
      <pass_data>
        changeset: files_to_refactor
        review_level: "style_and_quality"
      </pass_data>
      <expected_return>
        issues: array[issue]
        suggestions: array[suggestion]
      </expected_return>
    </route>
    
    **NEW: 4. Use proof-optimizer for opportunities**
    <route to="@subagents/specialists/proof-optimizer">
      <pass_data>
        proofs: proofs_in_files
        optimization_level: "moderate"
      </pass_data>
      <expected_return>
        improvements: array[improvement]
      </expected_return>
    </route>
  </process>
</stage>

<stage id="2" name="PerformRefactoring">
  <action>Apply refactoring improvements</action>
  <process>
    **NEW: 1. Use refactoring-assistant for safe refactorings**
    <route to="@subagents/specialists/refactoring-assistant">
      <pass_data>
        refactoring_type: "rename" | "extract" | "inline" | "move"
        target: refactoring_target
        parameters: refactoring_params
      </pass_data>
      <expected_return>
        status: "success" | "error"
        changes: array[change]
      </expected_return>
    </route>
    
    **NEW: 2. Use proof-optimizer for proof simplification**
    <route to="@subagents/specialists/proof-optimizer">
      <pass_data>
        proof: proof_to_optimize
        optimization_level: "moderate"
      </pass_data>
      <expected_return>
        optimized_proof: string
        improvements: array
      </expected_return>
    </route>
    
    **NEW: 3. Verify changes with syntax-validator**
    <route to="@subagents/specialists/syntax-validator">
      <pass_data>
        file_path: refactored_file
        validation_level: "full"
      </pass_data>
      <expected_return>
        status: "success" | "error"
        diagnostics: array
      </expected_return>
    </route>
    
    4. Git commit
  </process>
</stage>
```

**Integration Points Summary**:
| Stage | Specialist | Purpose | When |
|-------|-----------|---------|------|
| 1 | code-reviewer | Analyze issues | Always |
| 1 | proof-optimizer | Find optimization opportunities | Always |
| 2 | refactoring-assistant | Perform safe refactorings | For each refactoring |
| 2 | proof-optimizer | Simplify proofs | For each proof |
| 2 | syntax-validator | Verify changes | After each change |

---

### 5.3 documenter.md Integration

**Enhanced Workflow**:
```markdown
<stage id="2" name="UpdateDocumentation">
  <action>Update documentation</action>
  <process>
    **NEW: 1. Use documentation-generator for auto-docs**
    <route to="@subagents/specialists/documentation-generator">
      <pass_data>
        module: module_to_document
        include_examples: true
      </pass_data>
      <expected_return>
        documentation: string
        coverage: float
      </expected_return>
    </route>
    
    **NEW: 2. Use test-generator for examples**
    <route to="@subagents/specialists/test-generator">
      <pass_data>
        theorem: theorem_to_exemplify
        example_count: 3
      </pass_data>
      <expected_return>
        examples: array[example]
      </expected_return>
    </route>
    
    **NEW: 3. Use concept-explainer for explanations**
    <route to="@subagents/specialists/concept-explainer">
      <pass_data>
        concept: concept_to_explain
        level: "intermediate"
      </pass_data>
      <expected_return>
        explanation: string
        examples: array
      </expected_return>
    </route>
    
    **NEW: 4. Verify examples compile with syntax-validator**
    <route to="@subagents/specialists/syntax-validator">
      <pass_data>
        file_path: documentation_file
        validation_level: "full"
      </pass_data>
      <expected_return>
        status: "success" | "error"
        diagnostics: array
      </expected_return>
    </route>
  </process>
</stage>
```

---

### 5.4 reviewer.md Integration

**Enhanced Workflow**:
```markdown
**NEW: Add stages for comprehensive review**

<stage id="X" name="CodeReview">
  <action>Automated code review</action>
  <route to="@subagents/specialists/code-reviewer">
    <pass_data>
      changeset: files_changed
      review_level: "comprehensive"
    </pass_data>
    <expected_return>
      issues: array[issue]
      suggestions: array[suggestion]
    </expected_return>
  </route>
</stage>

<stage id="Y" name="DependencyAnalysis">
  <action>Analyze module dependencies</action>
  <route to="@subagents/specialists/dependency-analyzer">
    <pass_data>
      project: project_root
      analyze_type: "circular_deps"
    </pass_data>
    <expected_return>
      circular_deps: array
      import_bloat: array
      suggestions: array
    </expected_return>
  </route>
</stage>

<stage id="Z" name="PerformanceCheck">
  <action>Check for performance issues</action>
  <route to="@subagents/specialists/performance-profiler">
    <pass_data>
      files: files_changed
      profile_level: "moderate"
    </pass_data>
    <expected_return>
      bottlenecks: array
      suggestions: array
    </expected_return>
  </route>
</stage>

<stage id="W" name="ProofOptimization">
  <action>Suggest proof improvements</action>
  <route to="@subagents/specialists/proof-optimizer">
    <pass_data>
      proofs: proofs_in_changeset
      optimization_level: "conservative"
    </pass_data>
    <expected_return>
      improvements: array
    </expected_return>
  </route>
</stage>
```

---

### 5.5 researcher.md Integration

**Enhanced Workflow**:
```markdown
<stage id="2" name="DelegateToSpecialists">
  <action>Route research tasks to appropriate specialist subagents</action>
  <routing>
    **REPLACE: lean-search-specialist and loogle-specialist**
    **WITH: library-navigator (unified search)**
    
    <route to="@subagents/specialists/library-navigator" when="library_search_needed">
      <context_level>Level 1</context_level>
      <pass_data>
        - Research topic
        - Search mode: "combined" (uses both LeanSearch and Loogle)
        - Max results: 50
      </pass_data>
      <expected_return>
        - Search results from both Loogle and LeanSearch
        - Ranked and deduplicated
        - Brief summary
      </expected_return>
    </route>
  </routing>
</stage>
```

---

### 5.6 planner.md Integration

**Enhanced Workflow**:
```markdown
<stage id="3" name="RouteToDependencyMapper">
  <action>Delegate dependency mapping to dependency-mapper subagent</action>
  <routing>
    **ENHANCE: Use dependency-analyzer for code-level dependencies**
    
    <route to="@subagents/specialists/dependency-analyzer">
      <pass_data>
        - Project root
        - Files to analyze
        - Analysis type: "full"
      </pass_data>
      <expected_return>
        - Dependency graph
        - Circular dependencies
        - Import bloat
        - Optimization suggestions
      </expected_return>
    </route>
  </routing>
</stage>

<stage id="4" name="CreateImplementationPlan">
  <action>Create detailed implementation plan</action>
  <process>
    **ENHANCE: Use performance-profiler for estimates**
    
    <route to="@subagents/specialists/performance-profiler">
      <pass_data>
        - Similar past implementations
        - Complexity assessment
      </pass_data>
      <expected_return>
        - Estimated compilation time
        - Performance considerations
        - Optimization recommendations
      </expected_return>
    </route>
  </process>
</stage>
```

---

## 6. Examples

### 6.1 Complete Proof Development Example

```markdown
## Scenario: Develop proof for new theorem

<workflow>
  <step_1>
    <agent>proof-developer</agent>
    <action>Load implementation plan</action>
    <specialist_calls>
      <call>
        <specialist>syntax-validator</specialist>
        <input>
          file_path: "plan.md"
          validation_level: "syntax_only"
        </input>
        <output>
          status: "success"
          diagnostics: []
        </output>
      </call>
    </specialist_calls>
  </step_1>
  
  <step_2>
    <agent>proof-developer</agent>
    <action>Implement theorem</action>
    <specialist_calls>
      <call_1>
        <specialist>tactic-recommender</specialist>
        <input>
          goal: "∀ (R S : Type*) [Ring R] [Ring S] (f : R →+* S) (x y : R), f (x * y) = f x * f y"
          context:
            recent_tactics: []
            available_lemmas: []
        </input>
        <output>
          suggestions:
            - tactic: "intro R S _ _ f x y"
              confidence: 0.95
              rationale: "Goal is universal quantification"
            - tactic: "apply RingHom.map_mul"
              confidence: 0.85
              rationale: "Direct application of ring homomorphism property"
        </output>
      </call_1>
      
      <call_2>
        <specialist>library-navigator</specialist>
        <input>
          query: "ring homomorphism multiplication"
          search_mode: "auto"
          max_results: 10
        </input>
        <output>
          results:
            - name: "RingHom.map_mul"
              type: "∀ {R S : Type*} [Ring R] [Ring S] (f : R →+* S) (x y : R), f (x * y) = f x * f y"
              module: "Mathlib.Algebra.Ring.Hom.Defs"
              relevance_score: 0.98
        </output>
      </call_2>
      
      <implementation>
        theorem ring_hom_preserves_mul : 
          ∀ (R S : Type*) [Ring R] [Ring S] (f : R →+* S) (x y : R), 
          f (x * y) = f x * f y := 
        by
          intro R S _ _ f x y
          apply RingHom.map_mul
      </implementation>
      
      <call_3>
        <specialist>syntax-validator</specialist>
        <input>
          file_path: "Logos/Core/RingTheory.lean"
          validation_level: "full"
        </input>
        <output>
          status: "success"
          diagnostics: []
          metadata:
            validation_time_ms: 120
            cache_hit: false
        </output>
      </call_3>
    </specialist_calls>
  </step_2>
  
  <step_3>
    <agent>proof-developer</agent>
    <action>Optimize proof</action>
    <specialist_calls>
      <call>
        <specialist>proof-optimizer</specialist>
        <input>
          proof:
            theorem_name: "ring_hom_preserves_mul"
            proof_term: "by intro R S _ _ f x y; apply RingHom.map_mul"
          optimization_level: "moderate"
        </input>
        <output>
          status: "success"
          improvements:
            - type: "library_lemma"
              description: "Proof already uses library lemma optimally"
              impact: "none"
          optimized_proof: "by intro R S _ _ f x y; apply RingHom.map_mul"
          metrics:
            size_reduction_percent: 0
            time_reduction_percent: 0
        </output>
      </call>
    </specialist_calls>
  </step_3>
</workflow>
```

### 6.2 Complete Refactoring Example

```markdown
## Scenario: Refactor module for better style and performance

<workflow>
  <step_1>
    <agent>refactorer</agent>
    <action>Analyze refactoring scope</action>
    <specialist_calls>
      <call_1>
        <specialist>code-reviewer</specialist>
        <input>
          changeset:
            files: ["Logos/Core/Syntax.lean"]
          review_level: "comprehensive"
        </input>
        <output>
          issues:
            - type: "style"
              description: "Function name should be snake_case"
              location: "line 45"
              severity: "warning"
            - type: "performance"
              description: "Repeated simp calls can be combined"
              location: "line 120-125"
              severity: "info"
        </output>
      </call_1>
      
      <call_2>
        <specialist>proof-optimizer</specialist>
        <input>
          proofs: proofs_in_file
          optimization_level: "moderate"
        </input>
        <output>
          improvements:
            - type: "redundancy"
              description: "Remove repeated simp calls"
              impact: "medium"
              before: "simp; simp; simp"
              after: "simp"
        </output>
      </call_2>
    </specialist_calls>
  </step_1>
  
  <step_2>
    <agent>refactorer</agent>
    <action>Perform refactoring</action>
    <specialist_calls>
      <call_1>
        <specialist>refactoring-assistant</specialist>
        <input>
          refactoring_type: "rename"
          target: "functionName"
          new_name: "function_name"
        </input>
        <output>
          status: "success"
          changes:
            - file: "Logos/Core/Syntax.lean"
              line: 45
              old: "functionName"
              new: "function_name"
        </output>
      </call_1>
      
      <call_2>
        <specialist>proof-optimizer</specialist>
        <input>
          proof: proof_with_repeated_simp
          optimization_level: "moderate"
        </input>
        <output>
          optimized_proof: "simp [lemma1, lemma2, lemma3]"
          metrics:
            size_reduction_percent: 60
            time_reduction_percent: 40
        </output>
      </call_2>
      
      <call_3>
        <specialist>syntax-validator</specialist>
        <input>
          file_path: "Logos/Core/Syntax.lean"
          validation_level: "full"
        </input>
        <output>
          status: "success"
          diagnostics: []
        </output>
      </call_3>
    </specialist_calls>
  </step_2>
</workflow>
```

---

## Conclusion

This integration guide provides:

1. **Integration Patterns**: Request-response, pipeline, parallel, conditional, retry
2. **Context Passing**: Minimal context, structured data, validation
3. **Error Handling**: Graceful degradation, fallback chains, error reporting
4. **Primary Agent Integrations**: Detailed integration for all 6 primary agents
5. **Examples**: Complete workflows showing specialist coordination

**Key Takeaways**:
- Pass minimal, structured context to specialists
- Handle errors gracefully with fallbacks
- Use appropriate integration patterns for each use case
- Validate inputs and outputs
- Maintain specialist statelessness

---

*For implementation details, see `implementation-001.md` and `agent-specifications.md`.*
