# Agent Specifications: 14 Specialist Agents for LEAN 4

**Project**: #003
**Version**: 001
**Date**: December 16, 2025

---

## Table of Contents

1. [Syntax Validator Agent](#1-syntax-validator-agent)
2. [Library Navigator Agent](#2-library-navigator-agent)
3. [Error Diagnostics Specialist](#3-error-diagnostics-specialist)
4. [Tactic Recommender Agent](#4-tactic-recommender-agent)
5. [Proof Optimizer Agent](#5-proof-optimizer-agent)
6. [Test Generator Agent](#6-test-generator-agent)
7. [Code Review Agent](#7-code-review-agent)
8. [Documentation Generator Agent](#8-documentation-generator-agent)
9. [Refactoring Assistant](#9-refactoring-assistant)
10. [Dependency Analyzer](#10-dependency-analyzer)
11. [Performance Profiler](#11-performance-profiler)
12. [Learning Path Generator](#12-learning-path-generator)
13. [Proof Strategy Advisor](#13-proof-strategy-advisor)
14. [Concept Explainer](#14-concept-explainer)

---

## 1. Syntax Validator Agent

### 1.1 Overview

**Purpose**: Real-time syntax validation and error detection through LSP integration

**Complexity**: Moderate
**Effort**: 30-35 hours
**Phase**: 1 (Core Infrastructure)
**Dependencies**: None (foundational)

### 1.2 Input Parameters

```yaml
inputs:
  file_path:
    type: string
    description: "Absolute path to LEAN file to validate"
    required: true
    example: "/path/to/Logos/Core/Syntax.lean"
  
  content:
    type: string
    description: "File content (optional, reads from file if not provided)"
    required: false
    example: "theorem example : 1 + 1 = 2 := rfl"
  
  validation_level:
    type: enum
    values: ["syntax_only", "type_check", "full"]
    description: "Level of validation to perform"
    required: false
    default: "full"
  
  use_cache:
    type: boolean
    description: "Whether to use cached results"
    required: false
    default: true
```

### 1.3 Process Flow

```yaml
process:
  step_1_check_cache:
    action: "Check cache for existing diagnostics"
    process:
      - "Compute content hash of file"
      - "Look up in cache (file_path + hash)"
      - "If found and not expired, return cached diagnostics"
      - "Otherwise, proceed to LSP validation"
    output: "Cached diagnostics or null"
  
  step_2_validate_lsp:
    action: "Validate file via LSP"
    process:
      - "Ensure LSP connection is active (reconnect if needed)"
      - "Send textDocument/didOpen or didChange notification"
      - "Wait for publishDiagnostics response (timeout 5s)"
      - "Parse diagnostic messages"
      - "Categorize by severity (error, warning, info) and type (syntax, type, elaboration)"
    error_handling:
      lsp_unavailable: "Use cached results or return degraded status"
      timeout: "Retry once, then use cache or return error"
      parse_error: "Log error and return empty diagnostics"
    output: "Array of diagnostics"
  
  step_3_cache_return:
    action: "Cache and return results"
    process:
      - "Store diagnostics in cache with TTL"
      - "Update cache statistics (hits, misses)"
      - "Return diagnostics to caller"
    output: "Validation result with diagnostics"
```

### 1.4 Output Format

```yaml
output:
  status:
    type: enum
    values: ["success", "degraded", "cached", "error"]
    description: "Validation status"
  
  diagnostics:
    type: array
    items:
      location:
        file: string
        line: integer
        column: integer
        end_line: integer
        end_column: integer
      severity:
        type: enum
        values: ["error", "warning", "info", "hint"]
      message: string
      code: string (optional)
      category:
        type: enum
        values: ["syntax", "type", "elaboration", "tactic", "import"]
  
  metadata:
    validation_time_ms: integer
    cache_hit: boolean
    lsp_status: enum ["connected", "disconnected", "degraded"]
  
  example:
    status: "success"
    diagnostics:
      - location:
          file: "/path/to/file.lean"
          line: 10
          column: 5
          end_line: 10
          end_column: 15
        severity: "error"
        message: "type mismatch: expected Nat, got Int"
        code: "type_mismatch"
        category: "type"
    metadata:
      validation_time_ms: 150
      cache_hit: false
      lsp_status: "connected"
```

### 1.5 Tool Integration

**LSP Integration**:
- Connection: Persistent connection with auto-reconnect
- Protocol: JSON-RPC 2.0
- Messages: textDocument/didOpen, didChange, publishDiagnostics
- Timeout: 5 seconds
- Retry: 1 attempt

**Caching Strategy**:
- Key: file_path + content_hash
- TTL: 5 minutes
- Eviction: LRU (max 1000 entries)
- Invalidation: On file change

### 1.6 Success Metrics

- Validation latency (cached): < 100ms
- Validation latency (LSP): < 2s
- Error detection accuracy: > 99%
- False positive rate: < 1%
- Cache hit rate: > 60%

---

## 2. Library Navigator Agent

### 2.1 Overview

**Purpose**: Search and navigate theorem libraries using Loogle and LeanSearch

**Complexity**: Complex
**Effort**: 35-40 hours
**Phase**: 1 (Core Infrastructure)
**Dependencies**: None (foundational)

### 2.2 Input Parameters

```yaml
inputs:
  query:
    type: string
    description: "Search query (natural language or type pattern)"
    required: true
    example: "theorems about ring homomorphisms" or "_ * (_ ^ _)"
  
  search_mode:
    type: enum
    values: ["semantic", "type_pattern", "combined", "auto"]
    description: "Search strategy to use"
    required: false
    default: "auto"
  
  max_results:
    type: integer
    description: "Maximum number of results to return"
    required: false
    default: 20
    range: [1, 100]
  
  filter_context:
    type: object
    description: "Context for filtering results"
    required: false
    properties:
      available_imports: array[string]
      goal_type: string
      hypotheses: array[string]
```

### 2.3 Process Flow

```yaml
process:
  step_1_determine_strategy:
    action: "Determine search strategy"
    process:
      - "Analyze query type (natural language vs type pattern)"
      - "If auto mode, detect query type automatically"
      - "Select appropriate tool (LeanSearch vs Loogle)"
      - "Check cache for existing results"
    output: "Search strategy and cached results (if any)"
  
  step_2_execute_search:
    action: "Execute search"
    process:
      - "For semantic: Use LeanSearch API"
      - "For type_pattern: Use Loogle API"
      - "For combined: Use both and merge results"
      - "Handle timeouts and errors with fallback chain"
      - "Parse and normalize results"
    fallback_chain:
      - "Try LeanSearch (semantic, broad)"
      - "If fails, try Loogle (type-based, precise)"
      - "If fails, use local cache"
      - "If fails, return empty results with error"
    output: "Raw search results from tools"
  
  step_3_rank_filter:
    action: "Rank and filter results"
    process:
      - "Remove duplicates (same theorem from multiple sources)"
      - "Rank by relevance (tool score + heuristics)"
      - "Filter by context (available imports, goal type)"
      - "Limit to max_results"
      - "Add metadata (source, confidence, usage examples)"
    ranking_factors:
      - "Tool relevance score (weight: 0.5)"
      - "Name similarity to query (weight: 0.2)"
      - "Type similarity to goal (weight: 0.2)"
      - "Popularity/usage frequency (weight: 0.1)"
    output: "Ranked, filtered search results"
  
  step_4_cache_return:
    action: "Cache and return"
    process:
      - "Store results in cache with TTL"
      - "Update cache statistics"
      - "Return results with metadata"
    output: "Search results with metadata"
```

### 2.4 Output Format

```yaml
output:
  status:
    type: enum
    values: ["success", "partial", "cached", "error"]
  
  results:
    type: array
    items:
      name: string
      type: string
      module: string
      docstring: string (optional)
      source:
        type: enum
        values: ["loogle", "lean_search", "cache"]
      relevance_score: float [0.0, 1.0]
      usage_example: string (optional)
  
  metadata:
    search_time_ms: integer
    cache_hit: boolean
    search_mode_used: enum ["semantic", "type_pattern", "combined"]
    total_results_found: integer
    results_returned: integer
  
  example:
    status: "success"
    results:
      - name: "RingHom.map_mul"
        type: "∀ {R S : Type*} [Ring R] [Ring S] (f : R →+* S) (x y : R), f (x * y) = f x * f y"
        module: "Mathlib.Algebra.Ring.Hom.Defs"
        docstring: "A ring homomorphism preserves multiplication"
        source: "lean_search"
        relevance_score: 0.95
        usage_example: "apply RingHom.map_mul"
    metadata:
      search_time_ms: 1200
      cache_hit: false
      search_mode_used: "semantic"
      total_results_found: 45
      results_returned: 20
```

### 2.5 Tool Integration

**Loogle Integration**:
- API: https://loogle.lean-lang.org/api/search
- Method: GET
- Timeout: 3 seconds
- Retry: 1 attempt
- Cache TTL: 24 hours

**LeanSearch Integration**:
- API: https://leansearch.net/api/search
- Method: POST
- Timeout: 5 seconds
- Retry: 1 attempt
- Cache TTL: 1 hour

### 2.6 Success Metrics

- Search precision (relevant results): > 70%
- Search recall (finding known theorems): > 90%
- Average search time: < 2 seconds
- Cache hit rate: > 60%

---

## 3. Error Diagnostics Specialist

### 3.1 Overview

**Purpose**: Provide detailed error messages and fix suggestions

**Complexity**: Moderate
**Effort**: 25-30 hours
**Phase**: 1 (Core Infrastructure)
**Dependencies**: Syntax Validator, Library Navigator

### 3.2 Input Parameters

```yaml
inputs:
  diagnostic:
    type: object
    description: "Diagnostic from Syntax Validator"
    required: true
    properties:
      location: object
      severity: enum
      message: string
      code: string
      category: enum
  
  code_context:
    type: object
    description: "Code context around error"
    required: true
    properties:
      file_path: string
      surrounding_lines: array[string]
      available_imports: array[string]
      goal_state: object (optional)
```

### 3.3 Process Flow

```yaml
process:
  step_1_categorize:
    action: "Categorize error"
    process:
      - "Identify error category (type, elaboration, tactic, import)"
      - "Extract key information from error message"
      - "Find similar past errors in history"
    output: "Error category and key information"
  
  step_2_generate_fixes:
    action: "Generate fix suggestions"
    process:
      - "Match error pattern to known fixes"
      - "For type errors: suggest coercions, type annotations"
      - "For import errors: suggest missing imports"
      - "For tactic errors: suggest alternative tactics"
      - "Use Library Navigator to find relevant lemmas"
      - "Rank fixes by likelihood of success"
    output: "Ranked fix suggestions"
  
  step_3_explain:
    action: "Generate explanation"
    process:
      - "Create human-readable explanation"
      - "Explain why error occurred"
      - "Explain how fixes address the error"
      - "Provide examples if available"
    output: "Error explanation"
  
  step_4_learn:
    action: "Learn from resolution"
    process:
      - "Track which fix was applied (if any)"
      - "Update success statistics"
      - "Store in error history"
    output: "Updated error history"
```

### 3.4 Output Format

```yaml
output:
  status:
    type: enum
    values: ["success", "partial", "error"]
  
  category:
    type: enum
    values: ["type_error", "elaboration_error", "tactic_error", "import_error", "other"]
  
  explanation:
    summary: string
    detailed: string
    why_occurred: string
  
  fix_suggestions:
    type: array
    items:
      description: string
      code_change: string
      confidence: float [0.0, 1.0]
      rationale: string
      example: string (optional)
  
  similar_cases:
    type: array
    description: "Similar past errors and their resolutions"
  
  relevant_lemmas:
    type: array
    description: "Lemmas that might help resolve the error"
  
  example:
    status: "success"
    category: "type_error"
    explanation:
      summary: "Type mismatch: expected Nat, got Int"
      detailed: "The function expects a natural number (Nat) but received an integer (Int)"
      why_occurred: "Implicit coercion from Int to Nat is not available"
    fix_suggestions:
      - description: "Add explicit coercion to Nat"
        code_change: "Int.toNat x"
        confidence: 0.9
        rationale: "Convert Int to Nat explicitly"
        example: "let n : Nat := Int.toNat x"
      - description: "Change function to accept Int"
        code_change: "Change parameter type to Int"
        confidence: 0.7
        rationale: "Modify function signature to accept Int"
```

### 3.5 Success Metrics

- Fix acceptance rate: > 60%
- Explanation clarity rating: > 4/5
- Diagnostic time: < 200ms
- Repeated error reduction: > 30%

---

## 4. Tactic Recommender Agent

### 4.1 Overview

**Purpose**: Suggest relevant tactics based on goal state

**Complexity**: Complex
**Effort**: 30-35 hours
**Phase**: 1 (Core Infrastructure)
**Dependencies**: Syntax Validator, Library Navigator

### 4.2 Input Parameters

```yaml
inputs:
  goal:
    type: object
    description: "Current proof goal"
    required: true
    properties:
      target: string  # Goal to prove
      hypotheses: array[object]  # Available hypotheses
      type_context: array[string]  # Type class instances
  
  context:
    type: object
    description: "Proof context"
    required: true
    properties:
      recent_tactics: array[string]
      available_lemmas: array[string]
      proof_strategy: string (optional)
  
  max_suggestions:
    type: integer
    description: "Maximum number of tactics to suggest"
    required: false
    default: 5
    range: [1, 10]
```

### 4.3 Process Flow

```yaml
process:
  step_1_analyze_goal:
    action: "Analyze goal structure"
    process:
      - "Parse goal type (∀, ∃, ∧, ∨, →, etc.)"
      - "Identify goal pattern"
      - "Extract key components"
      - "Check hypothesis types"
    output: "Goal analysis"
  
  step_2_pattern_match:
    action: "Match to known patterns"
    process:
      - "Match goal structure to tactic patterns"
      - "∀ x, P x → suggest intro"
      - "A ∧ B → suggest constructor"
      - "∃ x, P x → suggest use"
      - "P → False → suggest contradiction"
    output: "Pattern-based suggestions"
  
  step_3_search_similar:
    action: "Search for similar goals"
    process:
      - "Use Library Navigator to find similar proved goals"
      - "Extract tactics from similar proofs"
      - "Adapt to current context"
    output: "Search-based suggestions"
  
  step_4_statistical:
    action: "Use statistical model"
    process:
      - "Check success rates of tactics for this goal type"
      - "Consider recent tactics used"
      - "Prioritize tactics with high success probability"
    output: "Statistical suggestions"
  
  step_5_rank:
    action: "Rank and combine suggestions"
    process:
      - "Combine pattern, search, and statistical suggestions"
      - "Remove duplicates"
      - "Rank by confidence"
      - "Limit to max_suggestions"
      - "Add rationale for each suggestion"
    output: "Ranked tactic suggestions"
```

### 4.4 Output Format

```yaml
output:
  status:
    type: enum
    values: ["success", "partial", "error"]
  
  suggestions:
    type: array
    items:
      tactic: string
      confidence: float [0.0, 1.0]
      rationale: string
      expected_outcome: string
      example_usage: string
      source:
        type: enum
        values: ["pattern", "search", "statistical", "combined"]
  
  metadata:
    analysis_time_ms: integer
    goal_pattern: string
    similar_goals_found: integer
  
  example:
    status: "success"
    suggestions:
      - tactic: "intro x"
        confidence: 0.95
        rationale: "Goal is a universal quantification (∀ x, P x)"
        expected_outcome: "Introduces x into context, goal becomes P x"
        example_usage: "intro x"
        source: "pattern"
      - tactic: "apply RingHom.map_mul"
        confidence: 0.75
        rationale: "Similar goals used this lemma successfully"
        expected_outcome: "Applies ring homomorphism multiplication property"
        example_usage: "apply RingHom.map_mul"
        source: "search"
    metadata:
      analysis_time_ms: 450
      goal_pattern: "forall_implication"
      similar_goals_found: 12
```

### 4.5 Success Metrics

- Top-3 acceptance rate: > 40%
- Average response time: < 500ms
- Goal pattern coverage: > 90%
- User satisfaction: > 4/5

---

## 5. Proof Optimizer Agent

### 5.1 Overview

**Purpose**: Analyze and optimize existing proofs

**Complexity**: Complex
**Effort**: 35-40 hours
**Phase**: 2 (Development Tools)
**Dependencies**: Syntax Validator, Library Navigator, Tactic Recommender

### 5.2 Input Parameters

```yaml
inputs:
  proof:
    type: object
    description: "Proof to optimize"
    required: true
    properties:
      file_path: string
      theorem_name: string
      proof_term: string
      goal: string
  
  optimization_level:
    type: enum
    values: ["conservative", "moderate", "aggressive"]
    description: "How aggressively to optimize"
    required: false
    default: "moderate"
  
  preserve_style:
    type: boolean
    description: "Whether to preserve proof style (tactic vs term mode)"
    required: false
    default: true
```

### 5.3 Process Flow

```yaml
process:
  step_1_analyze:
    action: "Analyze proof structure"
    process:
      - "Parse proof into steps"
      - "Identify tactic sequence"
      - "Measure proof size and complexity"
      - "Time proof compilation"
    output: "Proof analysis"
  
  step_2_detect_redundancy:
    action: "Detect redundant steps"
    process:
      - "Find repeated simp calls"
      - "Identify unnecessary case splits"
      - "Detect no-op tactics"
      - "Find redundant hypotheses"
    output: "Redundancy report"
  
  step_3_search_library:
    action: "Search for library lemmas"
    process:
      - "Use Library Navigator to find lemmas that prove subgoals"
      - "Identify custom proofs that duplicate library theorems"
      - "Suggest direct library lemma application"
    output: "Library replacement suggestions"
  
  step_4_try_automation:
    action: "Try automatic proof"
    process:
      - "Try Aesop for automatic proof"
      - "Try simp with minimal lemma set"
      - "Try decide for decidable goals"
      - "Compare with original proof"
    output: "Automatic proof (if found)"
  
  step_5_generate_report:
    action: "Generate optimization report"
    process:
      - "Combine all optimization opportunities"
      - "Estimate improvement (size, time)"
      - "Rank suggestions by impact"
      - "Generate optimized proof"
    output: "Optimization report"
```

### 5.4 Output Format

```yaml
output:
  status:
    type: enum
    values: ["success", "partial", "no_improvements", "error"]
  
  original_metrics:
    proof_size_lines: integer
    proof_size_chars: integer
    compilation_time_ms: integer
    tactic_count: integer
  
  optimized_proof:
    proof_term: string
    estimated_size_lines: integer
    estimated_compilation_time_ms: integer
  
  improvements:
    type: array
    items:
      type: enum ["redundancy", "library_lemma", "automation", "simplification"]
      description: string
      impact: enum ["high", "medium", "low"]
      confidence: float [0.0, 1.0]
      before: string
      after: string
  
  metrics:
    size_reduction_percent: float
    time_reduction_percent: float
    redundant_steps_removed: integer
  
  example:
    status: "success"
    original_metrics:
      proof_size_lines: 15
      proof_size_chars: 450
      compilation_time_ms: 250
      tactic_count: 8
    optimized_proof:
      proof_term: "by simp [RingHom.map_mul, RingHom.map_add]"
      estimated_size_lines: 1
      estimated_compilation_time_ms: 50
    improvements:
      - type: "library_lemma"
        description: "Replace custom proof with RingHom.map_mul"
        impact: "high"
        confidence: 0.95
        before: "have h1 : f (x * y) = f x * f y := ..."
        after: "apply RingHom.map_mul"
    metrics:
      size_reduction_percent: 93.3
      time_reduction_percent: 80.0
      redundant_steps_removed: 3
```

### 5.5 Success Metrics

- Proof size reduction: 20% average
- Compilation time improvement: 15% average
- Redundancy detection rate: > 85%
- Suggestion acceptance rate: > 50%

---

## 6-14. Remaining Specialists

The remaining specialists (Test Generator, Code Review Agent, Documentation Generator, Refactoring Assistant, Dependency Analyzer, Performance Profiler, Learning Path Generator, Proof Strategy Advisor, Concept Explainer) follow similar specification structures with:

1. **Overview**: Purpose, complexity, effort, phase, dependencies
2. **Input Parameters**: Detailed parameter specifications
3. **Process Flow**: Step-by-step workflow
4. **Output Format**: Structured output specification
5. **Tool Integration**: External tool details
6. **Success Metrics**: Measurable targets

Each specialist is detailed in the research report (Section 2) with:
- Capabilities
- Tool integration
- Implementation approach
- Use cases
- Dependencies
- Success metrics

---

## Summary

This document provides detailed specifications for all 14 specialist agents. Each specification includes:

- **Input Parameters**: What data the specialist needs
- **Process Flow**: How the specialist operates
- **Output Format**: What the specialist returns
- **Tool Integration**: How external tools are used
- **Success Metrics**: How to measure success

These specifications serve as the blueprint for implementation, ensuring consistency and completeness across all specialists.

---

*For complete implementation details, see `implementation-001.md` and the research report in `.opencode/specs/002_system_enhancements_research/reports/specialist-agents-web-research.md`.*
