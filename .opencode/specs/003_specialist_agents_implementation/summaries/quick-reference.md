# Quick Reference: 14 Specialist Agents

**Purpose**: Quick reference guide for using specialist agents in LEAN 4 ProofChecker

**Last Updated**: December 16, 2025

---

## When to Use Each Specialist

### During Proof Development

| Need | Use Specialist | Expected Result |
|------|----------------|-----------------|
| Validate LEAN syntax | `syntax-validator` | Diagnostics with errors/warnings |
| Find relevant theorems | `library-navigator` | Ranked list of matching theorems |
| Debug an error | `error-diagnostics` | Error explanation + fix suggestions |
| Get tactic suggestions | `tactic-recommender` | Ranked tactic suggestions |
| Simplify a proof | `proof-optimizer` | Optimized proof (shorter, faster) |

### During Refactoring

| Need | Use Specialist | Expected Result |
|------|----------------|-----------------|
| Rename safely | `refactoring-assistant` | Renamed code with all references updated |
| Extract lemma | `refactoring-assistant` | Extracted lemma + updated proof |
| Optimize proofs | `proof-optimizer` | Simplified proofs |
| Validate changes | `syntax-validator` | Validation report |
| Review quality | `code-reviewer` | Code review report with issues |

### During Documentation

| Need | Use Specialist | Expected Result |
|------|----------------|-----------------|
| Generate docs | `documentation-generator` | Auto-generated documentation |
| Create examples | `test-generator` | Test cases and examples |
| Explain concepts | `concept-explainer` | Natural language explanations |
| Validate examples | `syntax-validator` | Compilation status |

### During Review

| Need | Use Specialist | Expected Result |
|------|----------------|-----------------|
| Code review | `code-reviewer` | Comprehensive review report |
| Check dependencies | `dependency-analyzer` | Dependency graph + issues |
| Profile performance | `performance-profiler` | Performance report + bottlenecks |
| Suggest optimizations | `proof-optimizer` | Optimization suggestions |

### During Planning

| Need | Use Specialist | Expected Result |
|------|----------------|-----------------|
| Analyze dependencies | `dependency-analyzer` | Dependency map + complexity |
| Estimate performance | `performance-profiler` | Performance estimates |

### During Learning

| Need | Use Specialist | Expected Result |
|------|----------------|-----------------|
| Get proof strategy | `proof-strategy-advisor` | High-level proof strategy |
| Generate learning path | `learning-path-generator` | Personalized learning path |
| Understand concept | `concept-explainer` | Concept explanation |

---

## Input/Output Quick Reference

### syntax-validator

**Input**:
```yaml
file_path: "Logos/Core/Syntax.lean"
validation_level: "full"  # or "syntax_only", "type_check"
use_cache: true
```

**Output**:
```yaml
status: "success"  # or "degraded", "cached", "error"
diagnostics:
  - location: {line: 10, column: 5}
    severity: "error"
    message: "type mismatch"
    category: "type"
metadata:
  validation_time_ms: 150
  cache_hit: false
```

---

### library-navigator

**Input**:
```yaml
query: "theorems about ring homomorphisms"
search_mode: "auto"  # or "semantic", "type_pattern", "combined"
max_results: 20
```

**Output**:
```yaml
status: "success"
results:
  - name: "RingHom.map_mul"
    type: "f (x * y) = f x * f y"
    module: "Mathlib.Algebra.Ring.Hom.Defs"
    relevance_score: 0.95
metadata:
  search_time_ms: 1200
  search_mode_used: "semantic"
```

---

### error-diagnostics

**Input**:
```yaml
diagnostic:
  location: {line: 10, column: 5}
  severity: "error"
  message: "type mismatch: expected Nat, got Int"
  category: "type"
code_context:
  file_path: "Logos/Core/Syntax.lean"
  surrounding_lines: ["...", "...", "..."]
```

**Output**:
```yaml
status: "success"
category: "type_error"
explanation:
  summary: "Type mismatch: expected Nat, got Int"
  why_occurred: "Implicit coercion not available"
fix_suggestions:
  - description: "Add explicit coercion"
    code_change: "Int.toNat x"
    confidence: 0.9
```

---

### tactic-recommender

**Input**:
```yaml
goal_state:
  hypotheses:
    - {name: "n", type: "Nat"}
    - {name: "h", type: "n > 0"}
  conclusion: "n + 1 > 1"
context:
  available_imports: ["Mathlib.Data.Nat.Basic"]
  recent_tactics: ["intro", "cases"]
```

**Output**:
```yaml
status: "success"
suggestions:
  - tactic: "omega"
    confidence: 0.95
    rationale: "Goal is linear arithmetic"
  - tactic: "linarith"
    confidence: 0.85
    rationale: "Alternative for linear arithmetic"
metadata:
  recommendation_time_ms: 300
```

---

### proof-optimizer

**Input**:
```yaml
proof:
  file_path: "Logos/Core/Theorems.lean"
  theorem_name: "example_theorem"
  current_proof: "by intro h; cases h; ..."
optimization_level: "aggressive"  # or "conservative", "moderate"
```

**Output**:
```yaml
status: "success"
optimizations:
  - type: "redundancy_removal"
    description: "Removed redundant intro"
    before: "by intro h; intro g; ..."
    after: "by intro h g; ..."
    size_reduction: 15%
  - type: "automation"
    description: "Replaced tactics with aesop"
    before: "by intro; constructor; exact h; exact g"
    after: "by aesop"
    size_reduction: 60%
metadata:
  total_size_reduction: 35%
  compilation_time_improvement: 20%
```

---

### test-generator

**Input**:
```yaml
target:
  file_path: "Logos/Core/Syntax.lean"
  theorem_name: "example_theorem"
  type: "∀ n : Nat, n + 0 = n"
test_types: ["property", "edge_case", "counterexample"]
```

**Output**:
```yaml
status: "success"
tests:
  - type: "property"
    description: "Test with random natural numbers"
    code: "example (n : Nat) : n + 0 = n := by ..."
  - type: "edge_case"
    description: "Test with zero"
    code: "example : 0 + 0 = 0 := by ..."
metadata:
  tests_generated: 5
  coverage_estimate: 85%
```

---

### documentation-generator

**Input**:
```yaml
target:
  file_path: "Logos/Core/Syntax.lean"
  scope: "module"  # or "theorem", "definition", "file"
documentation_level: "comprehensive"  # or "minimal", "standard"
```

**Output**:
```yaml
status: "success"
documentation:
  module_doc: "# Syntax Module\n\nDefines syntax for..."
  theorem_docs:
    - name: "example_theorem"
      doc: "Proves that addition is commutative"
      examples: ["example : 1 + 2 = 2 + 1 := by ..."]
metadata:
  coverage: 95%
  examples_generated: 12
```

---

### code-reviewer

**Input**:
```yaml
changeset:
  files: ["Logos/Core/Syntax.lean", "Logos/Core/Theorems.lean"]
  scope: "comprehensive"  # or "quick", "focused"
review_aspects: ["style", "correctness", "performance", "documentation"]
```

**Output**:
```yaml
status: "success"
issues:
  - severity: "error"
    category: "style"
    description: "Line too long (>100 chars)"
    location: {file: "...", line: 42}
    suggestion: "Split into multiple lines"
  - severity: "warning"
    category: "performance"
    description: "Inefficient proof"
    suggestion: "Use aesop instead"
metadata:
  total_issues: 15
  false_positive_estimate: 2%
```

---

### refactoring-assistant

**Input**:
```yaml
operation: "rename"  # or "extract_lemma", "move", "inline"
target:
  file_path: "Logos/Core/Syntax.lean"
  name: "old_name"
  new_name: "new_name"
safety_level: "strict"  # or "moderate", "permissive"
```

**Output**:
```yaml
status: "success"
changes:
  - file: "Logos/Core/Syntax.lean"
    type: "rename"
    old: "old_name"
    new: "new_name"
    references_updated: 15
validation:
  all_files_compile: true
  no_breaking_changes: true
metadata:
  files_modified: 3
  references_updated: 15
```

---

### dependency-analyzer

**Input**:
```yaml
scope: "project"  # or "module", "file"
analysis_type: "comprehensive"  # or "quick", "focused"
check_for: ["cycles", "unused", "bloat"]
```

**Output**:
```yaml
status: "success"
dependency_graph:
  nodes: ["Module1", "Module2", ...]
  edges: [{from: "Module1", to: "Module2"}, ...]
issues:
  - type: "circular_dependency"
    modules: ["Module1", "Module2", "Module1"]
    severity: "error"
  - type: "unused_import"
    file: "Logos/Core/Syntax.lean"
    import: "Mathlib.Data.List.Basic"
    severity: "warning"
metadata:
  total_modules: 25
  circular_dependencies: 1
  optimization_potential: 20%
```

---

### performance-profiler

**Input**:
```yaml
target:
  scope: "project"  # or "module", "file", "theorem"
  file_path: "Logos/Core/Syntax.lean"
profiling_level: "detailed"  # or "quick", "comprehensive"
```

**Output**:
```yaml
status: "success"
profile:
  total_time: 45.2s
  bottlenecks:
    - location: "Logos/Core/Theorems.lean:complex_proof"
      time: 12.5s
      percentage: 27.7%
      suggestion: "Simplify proof or split into lemmas"
  breakdown:
    - module: "Logos.Core.Syntax"
      time: 5.2s
      percentage: 11.5%
metadata:
  profiling_overhead: 8%
```

---

### proof-strategy-advisor

**Input**:
```yaml
goal:
  statement: "∀ n : Nat, n + 0 = n"
  context: "Basic arithmetic"
difficulty: "auto"  # or "beginner", "intermediate", "advanced"
```

**Output**:
```yaml
status: "success"
strategies:
  - name: "Induction"
    confidence: 0.95
    description: "Use induction on n"
    skeleton: "by induction n with\n| zero => ...\n| succ n ih => ..."
    rationale: "Universal quantification over Nat"
  - name: "Simplification"
    confidence: 0.85
    description: "Use simp with Nat.add_zero"
    skeleton: "by simp [Nat.add_zero]"
metadata:
  strategies_considered: 5
  recommendation_time_ms: 500
```

---

### learning-path-generator

**Input**:
```yaml
learner_profile:
  current_level: "beginner"
  goals: ["understand modal logic", "prove soundness"]
  time_available: "4 weeks"
preferences:
  learning_style: "hands-on"
  pace: "moderate"
```

**Output**:
```yaml
status: "success"
learning_path:
  - week: 1
    topic: "Basic Modal Logic"
    concepts: ["box operator", "diamond operator"]
    exercises: ["exercise1.lean", "exercise2.lean"]
    resources: ["resource1.md", "resource2.md"]
  - week: 2
    topic: "Kripke Semantics"
    concepts: ["frames", "models", "truth"]
    exercises: ["exercise3.lean", "exercise4.lean"]
metadata:
  total_weeks: 4
  total_exercises: 20
  estimated_completion_time: "30 hours"
```

---

### concept-explainer

**Input**:
```yaml
concept: "Kripke frame"
context: "modal logic"
explanation_level: "beginner"  # or "intermediate", "advanced"
include_examples: true
```

**Output**:
```yaml
status: "success"
explanation:
  summary: "A Kripke frame is a structure (W, R) where..."
  detailed: "In modal logic, a Kripke frame provides..."
  examples:
    - description: "Simple frame with 3 worlds"
      code: "def simple_frame : Frame := ..."
  analogies:
    - "Think of worlds as states in a state machine"
  related_concepts: ["Kripke model", "accessibility relation"]
metadata:
  explanation_length: 500
  clarity_score: 4.5
```

---

## Common Patterns

### Pattern 1: Validate → Fix → Validate

```yaml
1. Use syntax-validator to find errors
2. Use error-diagnostics to get fix suggestions
3. Apply fixes
4. Use syntax-validator again to verify
```

### Pattern 2: Search → Recommend → Implement

```yaml
1. Use library-navigator to find relevant theorems
2. Use tactic-recommender to get tactic suggestions
3. Implement proof
4. Use syntax-validator to verify
```

### Pattern 3: Refactor → Optimize → Review

```yaml
1. Use refactoring-assistant for safe refactoring
2. Use proof-optimizer to simplify proofs
3. Use code-reviewer for quality check
4. Use syntax-validator to verify
```

### Pattern 4: Document → Test → Explain

```yaml
1. Use documentation-generator for auto-docs
2. Use test-generator for examples
3. Use concept-explainer for explanations
4. Use syntax-validator to verify examples
```

---

## Performance Tips

### Caching
- All specialists cache results
- Cache hit rates: 60-80% typical
- Clear cache if results seem stale

### Timeouts
- syntax-validator: 5s
- library-navigator: 2s (per search)
- error-diagnostics: 200ms
- tactic-recommender: 500ms
- proof-optimizer: 5s
- Others: 5-30s depending on complexity

### Batching
- Validate multiple files together
- Search for multiple theorems in parallel
- Generate multiple tests at once

---

## Error Handling

### All Specialists Support

**Graceful Degradation**:
- If tool unavailable, use cached results
- If cache empty, return partial results
- If complete failure, return error with details

**Fallback Chains**:
- library-navigator: LeanSearch → Loogle → Cache → Empty
- syntax-validator: LSP → Cache → Syntax-only → Error
- error-diagnostics: Pattern match → Library search → Generic

**Retry Strategies**:
- Automatic retry once on timeout
- Exponential backoff on repeated failures
- Circuit breaker after N failures

---

## Best Practices

### 1. Always Validate
Use `syntax-validator` after any code changes

### 2. Cache Aggressively
Enable caching for all specialists (default: true)

### 3. Handle Errors Gracefully
Check status field in output, handle "degraded" and "error" states

### 4. Use Appropriate Levels
- validation_level: "syntax_only" for quick checks
- optimization_level: "conservative" for safety
- documentation_level: "minimal" for quick docs

### 5. Combine Specialists
Use multiple specialists together for best results

### 6. Monitor Performance
Track response times and cache hit rates

### 7. Provide Feedback
Track which suggestions are accepted/rejected for learning

---

## Quick Troubleshooting

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Slow validation | LSP disconnected | Check LSP connection, use cache |
| No search results | Service unavailable | Check network, use cache |
| Inaccurate suggestions | Insufficient context | Provide more context (imports, hypotheses) |
| High memory usage | Large cache | Clear cache, reduce max_entries |
| Timeout errors | Complex operation | Increase timeout, simplify request |

---

## References

- Full specifications: `.opencode/agent/subagents/specialists/`
- Tool integration guides: `context/lean4/tools/`
- Implementation plan: `.opencode/specs/003_specialist_agents_implementation/plans/implementation-001.md`
