# Specialist Agents for LEAN 4 Theorem Proving: Comprehensive Research Report

**Research Date:** December 16, 2025
**Version:** 1.0
**Status:** Complete

---

## Executive Summary

This report synthesizes comprehensive research on designing specialist agents for LEAN 4 theorem proving systems, with focus on tool integration, multi-agent coordination patterns, and implementation strategies. Key findings reveal that:

1. **LEAN 4 provides a rich LSP-based ecosystem** with powerful search tools (Loogle for type-based search, LeanSearch for semantic search), proof automation (Aesop), and a mature build system (Lake). These tools are production-ready and actively maintained.

2. **Specialist agent architecture should leverage single-responsibility principles** with well-defined interfaces. Each agent should focus on one specific aspect of theorem proving (syntax validation, tactic recommendation, library search, etc.) while coordinating through clear protocols.

3. **The Aesop proof automation framework exemplifies excellent design patterns** for extensible, rule-based systems with transparent operation modes. Its architecture of safe/unsafe/norm rules with customizable builders provides a template for specialist agent design.

4. **Tool integration requires careful consideration of caching and error recovery**. The LSP provides real-time verification feedback, while search tools need intelligent caching to maintain performance. All tools must handle graceful degradation when services are unavailable.

5. **Implementation priorities should start with foundational specialists** (syntax validator, LSP integrator) before building higher-level agents (tactic recommender, learning path generator). This creates a stable foundation for the entire system.

## 1. LEAN 4 Tools Deep Dive

### 1.1 Language Server Protocol (LSP) Integration

**Overview:**
LEAN 4's LSP implementation provides real-time verification, diagnostics, and interactive proof development. It's the foundation of the VS Code extension and can be integrated into custom tools.

**Key Capabilities:**
- Real-time type checking and elaboration
- Interactive goal state display
- Error and warning diagnostics with precise locations
- Hover information for definitions and types
- Go-to-definition and find-references
- Code completion and snippet support
- Document symbols and outline view

**Integration Approach:**
```lean
-- LSP communication uses JSON-RPC 2.0
-- Key message types:
-- - textDocument/didOpen: File opened
-- - textDocument/didChange: File modified
-- - textDocument/publishDiagnostics: Errors/warnings
-- - textDocument/hover: Type information
-- - textDocument/completion: Auto-complete suggestions
```

**Best Practices:**
- Keep LSP connection persistent to avoid reconnection overhead
- Batch document changes when possible
- Cache hover information for frequently accessed definitions
- Handle LSP crashes gracefully with automatic reconnection
- Use incremental document synchronization
- Respect LSP server capabilities (not all features may be available)

**Performance Considerations:**
- LSP can be slow on large files (>1000 lines)
- Enable `precompileModules` for better performance
- Use workspace symbols instead of full-text search when possible
- Monitor LSP server resource usage

### 1.2 Loogle: Type-Based Search

**Overview:**
Loogle (https://loogle.lean-lang.org/) provides type-signature-based search across LEAN 4 and Mathlib. It's designed for finding lemmas and definitions by their type shape.

**Search Modes:**

1. **By Constant:**
   ```
   Real.sin
   # Finds all lemmas mentioning sine function
   ```

2. **By Name Substring:**
   ```
   "differ"
   # Finds lemmas with "differ" in name
   ```

3. **By Subexpression Pattern:**
   ```
   _ * (_ ^ _)
   # Finds lemmas with product of power
   ```

4. **By Main Conclusion:**
   ```
   |- tsum _ = _ * tsum _
   # Finds lemmas with specific conclusion shape
   ```

5. **Combined Searches:**
   ```
   Real.sin, "two", tsum, _ * _, _ ^ _, |- _ < _ → _
   # Multiple filters (AND logic)
   ```

**Integration Patterns:**
- Use metavariables (`?a`, `?b`) for flexible pattern matching
- Patterns match in any order for function arguments
- Non-linear patterns supported (e.g., `Real.sqrt ?a * Real.sqrt ?a`)
- Available via CLI, VS Code, Neovim, and Zulip bot

**Caching Strategy:**
- Cache frequent type patterns
- Store mapping of common goals to relevant lemmas
- Invalidate cache on Mathlib updates
- Use local Loogle instance for better performance

**When to Use Loogle:**
- Finding lemmas by type signature
- Discovering theorems about specific functions
- Searching for rewrite rules
- Finding instances and type class implementations

### 1.3 LeanSearch: Semantic Search

**Overview:**
LeanSearch (https://leansearch.net/) provides natural language search over Mathlib4 using AI-powered semantic understanding.

**Capabilities:**
- Natural language queries ("theorems about continuity")
- Query augmentation for better results
- Relevance ranking of results
- Returns both theorem statements and definitions

**Integration Approach:**
```python
# LeanSearch API (hypothetical - based on typical ML search APIs)
query = "find theorems about ring homomorphisms"
results = lean_search.search(query, num_results=10, augment=True)
for result in results:
    print(f"{result.name}: {result.type}")
```

**Complementary Use with Loogle:**
- **LeanSearch**: When you know what you want conceptually but not the type
- **Loogle**: When you know the type pattern but not the name
- **Combined**: Start with LeanSearch for discovery, refine with Loogle for precision

**Best Practices:**
- Use query augmentation for better recall
- Combine with Loogle for validation
- Cache frequent queries
- Provide user feedback mechanism for result quality

### 1.4 Aesop: Proof Automation Framework

**Overview:**
Aesop (https://github.com/leanprover-community/aesop) is a white-box proof search tactic inspired by Isabelle's `auto`. It provides extensible, transparent automation.

**Architecture:**

```lean
-- Rule Types:
-- 1. Normalization rules (norm): Simplify goal, generate 0-1 subgoals
-- 2. Safe rules (safe): Preserve provability, applied eagerly
-- 3. Unsafe rules (unsafe): May backtrack, need success probabilities

-- Example rule registration:
@[aesop safe [constructors, cases]]
inductive NonEmpty : List α → Prop
  | cons : NonEmpty (cons x xs)

-- Rule builders:
-- - apply: Apply lemma to goal
-- - forward: Forward reasoning from hypotheses
-- - destruct: Case analysis with cleanup
-- - constructors: Try all constructors
-- - cases: Pattern match on hypotheses
-- - simp: Add to simplification set
-- - tactic: Custom tactic
```

**Key Design Patterns:**

1. **Rule Priority System:**
   - Normalization: By penalty (lower first)
   - Safe: By penalty (lower first)
   - Unsafe: By success probability (higher first)

2. **Search Strategy:**
   - Best-first search by default
   - Also supports depth-first, breadth-first
   - Goal priority: 100% initially, multiplied by rule success probability

3. **Built-in Normalization:**
   - Runs `simp_all` automatically
   - Handles `∧`, `∨`, `→`, `∀`, `∃` logically
   - Extensible with custom normalizers

4. **Transparency:**
   - `aesop?` generates proof scripts
   - Detailed tracing with `set_option trace.aesop true`
   - Shows which rules were tried and why

**Integration Lessons for Specialist Agents:**
- **Clear rule categorization** (norm/safe/unsafe) provides predictable behavior
- **Success probabilities** enable intelligent search prioritization
- **Proof script generation** enhances transparency and debugging
- **Extensible rule builders** allow domain-specific customization
- **Fixpoint normalization** ensures thorough goal simplification

### 1.5 Lake: Build System and Package Manager

**Overview:**
Lake is LEAN 4's integrated build system, now merged into the main LEAN 4 repository. It provides dependency management, incremental compilation, and cloud release support.

**Core Concepts:**

```lean
-- lakefile.lean structure:
package «my_project» {
  -- Lean library configuration
}

lean_lib «MyLib» {
  -- Library-specific settings
}

lean_exe «my_binary» {
  root := `Main
}

-- Dependency management:
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"
```

**Build System Features:**
- Incremental compilation with automatic dependency tracking
- Parallel builds for better performance
- Cloud releases for faster dependency fetching
- Custom build targets and scripts
- Integration with C/C++ via `extern_lib`

**Linting Integration:**
- Lake supports custom linting through build targets
- Can integrate style checks, documentation checks, etc.
- Linters run as part of build process
- Results can be cached for efficiency

**For Specialist Agents:**
- Use Lake's build system for batch operations
- Leverage cloud releases to avoid rebuilding dependencies
- Create custom Lake scripts for automated checks
- Integrate linters as build-time validators

### 1.6 Additional Tools

**ProofWidgets:**
- Interactive visualization of proofs and data structures
- JSX-like syntax for custom UI components
- Support for Penrose diagrams and Recharts plots
- Useful for tactic UI and proof exploration

**VS Code Extension:**
- Provides infoview for goal state display
- Integrates all LEAN 4 tools seamlessly
- Extensible through VS Code APIs
- Can be used as reference for custom tool UIs

## 2. Specialist Agent Designs

### 2.1 Syntax Validator Agent

**Purpose:** Real-time syntax validation and error detection through LSP integration.

**Capabilities:**
- Continuous syntax checking as files are edited
- Parse error detection and reporting
- Elaboration error identification
- Type error highlighting
- Warning detection (unused variables, deprecated syntax, etc.)

**Tool Integration:**
- **Primary:** LSP (textDocument/publishDiagnostics)
- **Secondary:** Custom parsers for pre-LSP validation

**Implementation Approach:**
```lean
-- Pseudo-code architecture:
structure SyntaxValidator where
  lspConnection : LSPConnection
  errorCache : HashMap FilePath (Array Diagnostic)
  
def SyntaxValidator.validateFile (validator : SyntaxValidator) 
    (file : FilePath) : Task (Array Diagnostic) := do
  -- Open document in LSP
  validator.lspConnection.sendNotification {
    method := "textDocument/didOpen"
    params := { uri := file.toString, ... }
  }
  
  -- Wait for diagnostics
  let diagnostics ← validator.lspConnection.waitForDiagnostics file
  
  -- Cache results
  validator.errorCache := validator.errorCache.insert file diagnostics
  
  return diagnostics
```

**Use Cases:**
1. **Pre-commit validation:** Check all files before Git commit
2. **CI/CD integration:** Validate pull requests automatically
3. **IDE support:** Real-time feedback during editing
4. **Batch validation:** Check entire projects for errors

**Error Recovery:**
- Reconnect to LSP on connection failure
- Use cached diagnostics when LSP unavailable
- Provide degraded service with syntax-only checks
- Queue validation requests during LSP restart

**Performance Optimization:**
- Only validate changed files (incremental)
- Debounce rapid edits (wait 500ms after last change)
- Parallelize validation of independent files
- Cache validation results with file hashes

**Dependencies:**
- None (foundational agent)

**Success Metrics:**
- Validation latency < 100ms for small files (<500 lines)
- Error detection accuracy > 99%
- False positive rate < 1%
- Memory usage < 100MB for typical projects

### 2.2 Tactic Recommender Agent

**Purpose:** Suggest relevant tactics based on current goal state and context.

**Capabilities:**
- Analyze goal structure and hypothesis types
- Suggest tactics likely to make progress
- Rank suggestions by probability of success
- Learn from successful proof patterns
- Provide explanations for recommendations

**Tool Integration:**
- **Primary:** LSP (goal state, context)
- **Secondary:** Loogle (similar proved goals), LeanSearch (conceptual similarity)
- **Tertiary:** Aesop (rule database for pattern matching)

**Implementation Approach:**
```lean
structure TacticRecommender where
  goalPatterns : HashMap GoalPattern (Array Tactic)
  successStats : HashMap Tactic (Nat × Nat)  -- (successes, attempts)
  loogleClient : LoogleClient
  lspConnection : LSPConnection

def TacticRecommender.recommend (rec : TacticRecommender)
    (goal : Goal) (context : Context) : Array TacticSuggestion := do
  -- Pattern matching approach
  let patternMatch ← rec.findMatchingPatterns goal
  
  -- Search-based approach
  let similarGoals ← rec.loogleClient.searchByType goal.target
  let tacticFromSimilar ← rec.extractTacticsFromProofs similarGoals
  
  -- Statistical approach
  let freqTactics ← rec.getMostSuccessfulTactics context
  
  -- Combine and rank suggestions
  let suggestions := patternMatch ++ tacticFromSimilar ++ freqTactics
  return rec.rankSuggestions suggestions goal context
```

**Recommendation Strategies:**

1. **Pattern-Based:**
   - Match goal structure to known patterns
   - E.g., `∀ x, P x → Q x` → suggest `intro`
   - E.g., `A ∧ B` → suggest `constructor`

2. **Type-Based:**
   - Use Loogle to find similar proved goals
   - Extract tactics from similar proofs
   - Adapt to current context

3. **Context-Based:**
   - Analyze available hypotheses
   - Suggest applicable theorems from context
   - Consider recently used tactics

4. **Statistical:**
   - Track tactic success rates
   - Learn from proof history
   - Prioritize tactics with high success probability

**Use Cases:**
1. **Interactive proof assistance:** Suggest next step during proof development
2. **Proof skeleton generation:** Create initial proof outline
3. **Stuck detection:** Identify when user is stuck and offer alternatives
4. **Learning tool:** Teach users common proof patterns

**Learning Mechanism:**
- Track which suggestions were accepted
- Update success probabilities based on outcomes
- Cluster similar goals for pattern recognition
- Periodically retrain on accumulated data

**Dependencies:**
- Syntax Validator (for valid goal states)
- Library Navigator (for theorem recommendations)

**Success Metrics:**
- Suggestion relevance (top-3 acceptance rate) > 40%
- Average response time < 500ms
- Coverage of common goal patterns > 90%
- User satisfaction rating > 4/5

### 2.3 Library Navigator Agent

**Purpose:** Search and navigate theorem libraries efficiently to find relevant definitions, lemmas, and theorems.

**Capabilities:**
- Type-based search via Loogle
- Semantic search via LeanSearch
- Module and namespace navigation
- Dependency graph traversal
- Documentation lookup
- Example usage finding

**Tool Integration:**
- **Primary:** Loogle (type search), LeanSearch (semantic search)
- **Secondary:** LSP (symbol lookup, references)
- **Tertiary:** Documentation parser

**Implementation Approach:**
```lean
structure LibraryNavigator where
  loogleClient : LoogleClient
  leanSearchClient : LeanSearchClient
  lspConnection : LSPConnection
  docCache : HashMap Name Documentation

def LibraryNavigator.search (nav : LibraryNavigator)
    (query : SearchQuery) : Array SearchResult := do
  match query with
  | .typePattern pattern =>
      -- Use Loogle for precise type matching
      nav.loogleClient.search pattern
  
  | .naturalLanguage text =>
      -- Use LeanSearch for semantic matching
      let semantic ← nav.leanSearchClient.search text
      -- Validate results with Loogle
      let validated ← semantic.filterM (λ r => nav.validateResult r)
      return validated
  
  | .byName name =>
      -- Use LSP for exact name lookup
      nav.lspConnection.findDefinition name
  
  | .relatedTo theorem =>
      -- Find theorems using or generalizing given theorem
      let refs ← nav.lspConnection.findReferences theorem
      let uses ← nav.findTheoremsUsing theorem
      return refs ++ uses
```

**Search Strategies:**

1. **Exploratory Search:**
   - Start with natural language query (LeanSearch)
   - Refine with type patterns (Loogle)
   - Browse related theorems (LSP references)

2. **Targeted Search:**
   - Know exact type → Loogle directly
   - Know name substring → Loogle name search
   - Know concept → LeanSearch

3. **Contextual Search:**
   - Given current goal, find applicable theorems
   - Filter by hypothesis availability
   - Rank by likelihood of success

**Use Cases:**
1. **Proof development:** Find relevant lemmas during proving
2. **Code understanding:** Navigate unfamiliar codebases
3. **Documentation:** Generate usage examples
4. **Learning:** Discover related theorems and concepts

**Caching Strategy:**
- Cache Loogle queries for 24 hours
- Cache LeanSearch results for 1 hour (fresher data needed)
- Cache LSP symbol information indefinitely (file-based invalidation)
- Implement LRU eviction for cache management

**Dependencies:**
- None (foundational agent)

**Success Metrics:**
- Search precision (relevant results) > 70%
- Search recall (finding known theorems) > 90%
- Average search time < 2 seconds
- Cache hit rate > 60%

### 2.4 Proof Optimizer Agent

**Purpose:** Analyze and optimize existing proofs for clarity, performance, and maintainability.

**Capabilities:**
- Detect redundant tactics
- Simplify proof scripts
- Suggest term-mode rewrites
- Identify expensive computations
- Recommend library lemmas to replace custom proofs
- Check for unnecessary `sorry`s
- Verify proof robustness (sensitivity to changes)

**Tool Integration:**
- **Primary:** LSP (proof elaboration, timing)
- **Secondary:** Aesop (automatic proof generation for comparison)
- **Tertiary:** Lake (build time analysis)

**Implementation Approach:**
```lean
structure ProofOptimizer where
  elaborationCache : HashMap Proof ElaborationResult
  libraryNavigator : LibraryNavigator
  aesopInstance : AesopConfig

def ProofOptimizer.optimize (opt : ProofOptimizer)
    (proof : Proof) : OptimizationReport := do
  -- Analyze proof structure
  let structure ← opt.analyzeStructure proof
  
  -- Check for redundancy
  let redundant ← opt.findRedundantSteps proof
  
  -- Search for library lemmas
  let libraryAlternatives ← opt.findLibraryReplacements proof
  
  -- Try automatic proof
  let autoProof? ← opt.tryAutomaticProof proof.goal
  
  -- Generate report
  return {
    redundantSteps := redundant
    libraryReplacements := libraryAlternatives
    automaticProof := autoProof?
    performanceMetrics := structure.timing
    suggestions := opt.generateSuggestions structure
  }
```

**Optimization Techniques:**

1. **Redundancy Elimination:**
   - Detect repeated `simp` calls
   - Identify unnecessary case splits
   - Remove no-op tactics

2. **Library Lemma Substitution:**
   - Find custom proofs that duplicate library theorems
   - Suggest direct library lemma application
   - Reduce proof maintenance burden

3. **Proof Simplification:**
   - Try Aesop for automatic proof
   - Convert tactic proofs to term proofs when shorter
   - Combine multiple tactics into single calls

4. **Performance Optimization:**
   - Identify slow tactics (e.g., `simp` with large lemma sets)
   - Suggest `simp only` with minimal lemma sets
   - Recommend `decide` for decidable goals

**Use Cases:**
1. **Code review:** Automated proof quality checks
2. **Refactoring:** Bulk proof optimization
3. **Performance tuning:** Reduce build times
4. **Learning:** Teach proof writing best practices

**Dependencies:**
- Syntax Validator (for valid proofs)
- Library Navigator (for finding lemmas)

**Success Metrics:**
- Proof size reduction: 20% average
- Compilation time improvement: 15% average
- Detection rate of redundancy: > 85%
- Suggestion acceptance rate: > 50%

### 2.5 Test Generator Agent

**Purpose:** Automatically generate test cases and examples for theorems and definitions.

**Capabilities:**
- Generate concrete examples for abstract theorems
- Create counterexamples for false conjectures
- Generate property-based tests
- Produce edge case tests
- Validate theorem hypotheses
- Generate documentation examples

**Tool Integration:**
- **Primary:** LSP (type information, elaboration)
- **Secondary:** Aesop (counterexample search)
- **Tertiary:** Random generation libraries

**Implementation Approach:**
```lean
structure TestGenerator where
  typeAnalyzer : TypeAnalyzer
  randomGen : RandomGen
  aesopConfig : AesopConfig

def TestGenerator.generateTests (gen : TestGenerator)
    (theorem : Theorem) : Array Test := do
  -- Analyze theorem structure
  let types ← gen.typeAnalyzer.analyzeTheorem theorem
  
  -- Generate random instances
  let randomTests ← gen.generateRandomTests types 100
  
  -- Generate edge cases
  let edgeCases ← gen.generateEdgeCases types
  
  -- Try to find counterexamples
  let counterexamples ← gen.searchCounterexamples theorem
  
  -- Validate hypothesis necessity
  let hypothesisTests ← gen.testHypothesisNecessity theorem
  
  return randomTests ++ edgeCases ++ hypothesisTests
```

**Test Generation Strategies:**

1. **Random Testing:**
   - Generate random values of required types
   - Check theorem holds on random instances
   - Use QuickCheck-style property testing

2. **Edge Case Testing:**
   - Test boundary values (0, 1, -1 for integers)
   - Test empty structures (empty lists, sets)
   - Test extreme values (max/min)

3. **Counterexample Search:**
   - Use Aesop's search to find counterexamples
   - Try to prove negation
   - SAT/SMT solver integration for decidable domains

4. **Hypothesis Testing:**
   - Remove each hypothesis and check if theorem fails
   - Find minimal hypothesis sets
   - Generate examples showing hypothesis necessity

**Use Cases:**
1. **Validation:** Verify theorem correctness before proof
2. **Documentation:** Auto-generate examples
3. **Debugging:** Find issues in theorem statements
4. **Education:** Provide concrete instances for learning

**Dependencies:**
- Syntax Validator (for valid theorems)
- Library Navigator (for related examples)

**Success Metrics:**
- Test coverage (branches covered) > 80%
- Counterexample finding rate (for false theorems) > 70%
- Example usefulness rating (manual review) > 4/5
- Generation time < 5 seconds per theorem

### 2.6 Documentation Generator Agent

**Purpose:** Automatically generate and maintain high-quality documentation for LEAN 4 code.

**Capabilities:**
- Extract docstrings and format them
- Generate API documentation
- Create usage examples
- Build dependency diagrams
- Generate module overviews
- Cross-reference related definitions
- Check documentation completeness

**Tool Integration:**
- **Primary:** LSP (symbol information, types)
- **Secondary:** Test Generator (for examples)
- **Tertiary:** Lake (module structure)

**Implementation Approach:**
```lean
structure DocGenerator where
  symbolAnalyzer : SymbolAnalyzer
  testGenerator : TestGenerator
  templateEngine : TemplateEngine

def DocGenerator.generateDocs (gen : DocGenerator)
    (module : Module) : Documentation := do
  -- Extract all symbols
  let symbols ← gen.symbolAnalyzer.extractSymbols module
  
  -- For each symbol, generate documentation
  let docs ← symbols.mapM λ symbol => do
    -- Get docstring
    let docstring := symbol.docstring
    
    -- Generate examples
    let examples ← gen.testGenerator.generateExamples symbol
    
    -- Find related symbols
    let related ← gen.findRelated symbol
    
    -- Build documentation entry
    return {
      name := symbol.name
      type := symbol.type
      docstring := docstring
      examples := examples
      related := related
      usage := gen.generateUsageGuide symbol
    }
  
  -- Generate module overview
  let overview := gen.generateOverview module docs
  
  return { overview := overview, entries := docs }
```

**Documentation Components:**

1. **API Reference:**
   - Type signatures
   - Parameter descriptions
   - Return value descriptions
   - Exception/error conditions

2. **Examples:**
   - Basic usage examples
   - Edge case handling
   - Common patterns
   - Anti-patterns to avoid

3. **Cross-References:**
   - Related definitions
   - Theorems using this definition
   - Generalizations and specializations
   - Historical context (if applicable)

4. **Module Overview:**
   - Purpose and scope
   - Key definitions and theorems
   - Dependency relationships
   - Usage guidelines

**Quality Checks:**
- Every public definition has docstring
- Examples compile and run
- Cross-references are valid
- Formatting is consistent
- Math notation is correct

**Use Cases:**
1. **API documentation:** Generate docs for libraries
2. **Code review:** Check documentation completeness
3. **Onboarding:** Help new contributors understand code
4. **Maintenance:** Keep docs synchronized with code

**Dependencies:**
- Test Generator (for examples)
- Library Navigator (for cross-references)

**Success Metrics:**
- Documentation coverage > 95%
- Example compilation rate = 100%
- User satisfaction > 4/5
- Doc generation time < 30 seconds per module

### 2.7 Error Diagnostics Specialist

**Purpose:** Provide detailed, helpful error messages and suggestions for fixing common errors.

**Capabilities:**
- Parse and categorize error messages
- Provide context-specific fix suggestions
- Detect common error patterns
- Generate fix-it hints
- Track error frequency
- Learn from error resolution

**Tool Integration:**
- **Primary:** LSP (diagnostic messages)
- **Secondary:** Library Navigator (for fix suggestions)
- **Tertiary:** Historical error database

**Implementation Approach:**
```lean
structure ErrorDiagnostician where
  errorPatterns : HashMap ErrorPattern FixSuggestion
  errorHistory : Array ErrorResolution
  libraryNavigator : LibraryNavigator

def ErrorDiagnostician.diagnose (diag : ErrorDiagnostician)
    (error : Diagnostic) : DiagnosticReport := do
  -- Categorize error
  let category := diag.categorizeError error
  
  -- Find similar past errors
  let similar ← diag.findSimilarErrors error
  
  -- Generate fix suggestions
  let fixes ← diag.generateFixSuggestions error category
  
  -- Search for helpful lemmas
  let relevantLemmas ← diag.findRelevantLemmas error
  
  return {
    category := category
    explanation := diag.explainError error category
    fixes := fixes
    similarCases := similar
    relevantLemmas := relevantLemmas
  }
```

**Error Categories:**

1. **Type Errors:**
   - Type mismatch
   - Missing type class instance
   - Universe level issues
   - Implicit argument failures

2. **Elaboration Errors:**
   - Ambiguous notation
   - Unknown identifier
   - Namespace issues
   - Syntax errors

3. **Tactic Errors:**
   - Tactic fails to apply
   - Goal mismatch
   - Hypothesis not found
   - Unsolved metavariables

4. **Import/Dependency Errors:**
   - Missing imports
   - Circular dependencies
   - Version mismatches

**Fix Suggestion Strategies:**

1. **Pattern Matching:**
   - "Type mismatch: expected X, got Y" → suggest coercion
   - "Unknown identifier Z" → suggest import or definition
   - "Failed to synthesize instance" → suggest `open` or instance

2. **Contextual Analysis:**
   - Check available imports
   - Analyze recent code changes
   - Consider similar working code

3. **Learning from History:**
   - Track which fixes were accepted
   - Prioritize historically successful fixes
   - Update fix patterns based on outcomes

**Use Cases:**
1. **Interactive development:** Real-time error help
2. **Automated fixing:** Suggest automated fixes for common errors
3. **Learning tool:** Help users understand error messages
4. **Code review:** Identify error-prone patterns

**Dependencies:**
- Syntax Validator (for error detection)
- Library Navigator (for fix suggestions)

**Success Metrics:**
- Fix suggestion acceptance rate > 60%
- Error explanation clarity rating > 4/5
- Diagnostic generation time < 200ms
- Reduction in repeated errors > 30%

### 2.8 Code Review Agent

**Purpose:** Perform automated code reviews checking for style, best practices, and potential issues.

**Capabilities:**
- Check code style compliance
- Detect anti-patterns
- Verify naming conventions
- Check proof structure
- Identify performance issues
- Verify documentation quality
- Suggest refactorings

**Tool Integration:**
- **Primary:** Lake (linting infrastructure)
- **Secondary:** LSP (code analysis)
- **Tertiary:** All other specialists for comprehensive checks

**Implementation Approach:**
```lean
structure CodeReviewer where
  styleChecker : StyleChecker
  lintRunner : LakeEnvironment
  specialists : Array Specialist

def CodeReviewer.review (reviewer : CodeReviewer)
    (changeset : Changeset) : ReviewReport := do
  -- Run style checks
  let styleIssues ← reviewer.styleChecker.check changeset
  
  -- Run linters via Lake
  let lintIssues ← reviewer.lintRunner.runLinters changeset
  
  -- Run specialist checks
  let specialistReports ← reviewer.specialists.mapM λ s =>
    s.reviewChangeset changeset
  
  -- Combine all findings
  let allIssues := styleIssues ++ lintIssues ++ 
                   specialistReports.bind (·.issues)
  
  -- Prioritize issues
  let prioritized := reviewer.prioritizeIssues allIssues
  
  return {
    summary := reviewer.generateSummary prioritized
    issues := prioritized
    suggestions := reviewer.generateSuggestions prioritized
  }
```

**Review Checks:**

1. **Style Compliance:**
   - Naming conventions (UpperCamelCase, snake_case)
   - Indentation and formatting
   - Import organization
   - Comment style

2. **Best Practices:**
   - Use of library lemmas over custom proofs
   - Proper type class usage
   - Appropriate tactic choices
   - Documentation completeness

3. **Performance:**
   - Expensive tactics
   - Large proof terms
   - Inefficient algorithms
   - Unnecessary computations

4. **Correctness:**
   - No `sorry`s in non-WIP code
   - Tests cover main functionality
   - Error handling present
   - Edge cases considered

**Review Levels:**
- **Blocking:** Must be fixed before merge
- **Warning:** Should be addressed
- **Suggestion:** Nice to have
- **Note:** Informational only

**Use Cases:**
1. **Pre-commit:** Check before committing
2. **CI/CD:** Automated PR reviews
3. **Learning:** Teach best practices
4. **Maintenance:** Enforce code quality

**Dependencies:**
- All other specialists (comprehensive review)

**Success Metrics:**
- False positive rate < 5%
- True positive rate (catches real issues) > 90%
- Review time < 2 minutes for typical PR
- Developer satisfaction > 4/5

### 2.9 Refactoring Assistant

**Purpose:** Assist with safe, automated code refactorings.

**Capabilities:**
- Rename definitions safely
- Extract lemmas from proofs
- Inline definitions
- Move definitions between modules
- Split/merge files
- Update imports automatically
- Preserve proof validity

**Tool Integration:**
- **Primary:** LSP (references, definitions)
- **Secondary:** Syntax Validator (verify changes)
- **Tertiary:** Lake (module structure)

**Implementation Approach:**
```lean
structure RefactoringAssistant where
  lspConnection : LSPConnection
  validator : SyntaxValidator
  moduleAnalyzer : ModuleAnalyzer

def RefactoringAssistant.rename (assistant : RefactoringAssistant)
    (old : Name) (new : Name) : Task Refactoring := do
  -- Find all references
  let refs ← assistant.lspConnection.findReferences old
  
  -- Validate new name doesn't conflict
  let conflicts ← assistant.checkNameConflicts new
  if !conflicts.isEmpty then
    throw s!"Name conflicts: {conflicts}"
  
  -- Generate edits
  let edits := refs.map λ ref =>
    { range := ref.range, newText := new.toString }
  
  -- Validate edits preserve correctness
  let validated ← assistant.validateRefactoring edits
  
  return { edits := edits, validation := validated }
```

**Refactoring Types:**

1. **Rename:**
   - Update all references
   - Update documentation
   - Check for shadowing
   - Preserve imports

2. **Extract Lemma:**
   - Identify reusable proof fragment
   - Generate lemma statement
   - Replace uses with lemma call
   - Add appropriate generalization

3. **Inline:**
   - Replace calls with definition
   - Simplify result
   - Remove unused definition
   - Update documentation

4. **Move:**
   - Move to different module
   - Update all imports
   - Adjust namespace
   - Check for circular dependencies

**Safety Guarantees:**
- All refactorings preserve compilation
- LSP verification after each step
- Atomic changes (all-or-nothing)
- Rollback on validation failure

**Use Cases:**
1. **Codebase cleanup:** Bulk refactoring
2. **Library reorganization:** Move definitions
3. **API evolution:** Safe renames
4. **Proof engineering:** Extract reusable lemmas

**Dependencies:**
- Syntax Validator (verify changes)
- Library Navigator (find references)

**Success Metrics:**
- Success rate (refactorings that compile) > 99%
- Rollback rate < 1%
- Refactoring time < 10 seconds
- User confidence rating > 4.5/5

### 2.10 Learning Path Generator

**Purpose:** Generate personalized learning paths for users based on their goals and current knowledge.

**Capabilities:**
- Assess user's current knowledge
- Identify knowledge gaps
- Suggest learning resources
- Generate practice exercises
- Track learning progress
- Adapt difficulty dynamically

**Tool Integration:**
- **Primary:** Library Navigator (concept dependencies)
- **Secondary:** Test Generator (exercises)
- **Tertiary:** Documentation Generator (learning materials)

**Implementation Approach:**
```lean
structure LearningPathGenerator where
  conceptGraph : ConceptDependencyGraph
  resourceLibrary : ResourceLibrary
  exerciseGenerator : ExerciseGenerator
  progressTracker : ProgressTracker

def LearningPathGenerator.generatePath (gen : LearningPathGenerator)
    (user : User) (goal : LearningGoal) : LearningPath := do
  -- Assess current knowledge
  let assessment ← gen.assessKnowledge user
  
  -- Find prerequisites for goal
  let prerequisites := gen.conceptGraph.getPrerequisites goal
  
  -- Identify gaps
  let gaps := prerequisites.filter λ prereq =>
    !assessment.knowledge.contains prereq
  
  -- Generate ordered learning sequence
  let sequence := gen.topologicalSort gaps
  
  -- For each concept, assign resources
  let path := sequence.map λ concept =>
    {
      concept := concept
      resources := gen.resourceLibrary.findResources concept
      exercises := gen.exerciseGenerator.generate concept
      estimatedTime := gen.estimateTime concept user.pace
    }
  
  return { steps := path, goal := goal }
```

**Learning Path Components:**

1. **Concept Dependency Graph:**
   ```
   Group Theory
   ├── Monoid
   │   └── Semigroup
   ├── Inverse
   └── Identity
   ```

2. **Resource Types:**
   - Tutorial articles
   - Example proofs
   - Interactive exercises
   - Video explanations (if available)
   - External references

3. **Exercise Generation:**
   - Fill-in-the-blank proofs
   - Theorem statement verification
   - Proof repair exercises
   - Concept application problems

4. **Progress Tracking:**
   - Concepts mastered
   - Exercise completion rate
   - Time spent per concept
   - Difficulty adjustments

**Personalization:**
- **Pace:** Adjust based on completion speed
- **Style:** Visual vs. textual learners
- **Background:** Math background vs. CS background
- **Goals:** Research vs. software verification

**Use Cases:**
1. **Onboarding:** Help new users learn LEAN 4
2. **Advanced learning:** Guide toward specific topics
3. **Certification:** Prepare for competency assessment
4. **Teaching:** Generate course materials

**Dependencies:**
- Library Navigator (concept structure)
- Test Generator (exercises)
- Documentation Generator (learning materials)

**Success Metrics:**
- Learning goal achievement rate > 70%
- User satisfaction > 4/5
- Exercise completion rate > 80%
- Time to competency (compared to unguided) -30%

### 2.11 Performance Profiler

**Purpose:** Profile proof compilation and identify performance bottlenecks.

**Capabilities:**
- Measure tactic execution time
- Identify slow proofs
- Suggest performance improvements
- Track build time trends
- Compare alternatives
- Generate performance reports

**Tool Integration:**
- **Primary:** LSP (elaboration timing)
- **Secondary:** Lake (build system)
- **Tertiary:** Proof Optimizer (suggestions)

**Implementation Approach:**
```lean
structure PerformanceProfiler where
  timingDatabase : TimingDatabase
  lspConnection : LSPConnection
  buildMonitor : BuildMonitor

def PerformanceProfiler.profile (profiler : PerformanceProfiler)
    (target : ProfileTarget) : PerformanceReport := do
  -- Measure compilation times
  let timing ← profiler.measureCompilation target
  
  -- Identify bottlenecks
  let bottlenecks := timing.filter λ entry =>
    entry.duration > profiler.threshold
  
  -- Analyze bottlenecks
  let analyses ← bottlenecks.mapM λ bottleneck =>
    profiler.analyzeBottleneck bottleneck
  
  -- Generate improvement suggestions
  let suggestions := analyses.bind λ analysis =>
    profiler.generateSuggestions analysis
  
  return {
    timing := timing
    bottlenecks := bottlenecks
    suggestions := suggestions
    trends := profiler.analyzeTrends target
  }
```

**Profiling Metrics:**

1. **Compilation Time:**
   - Per-file compilation
   - Per-definition elaboration
   - Tactic execution time
   - Total build time

2. **Resource Usage:**
   - Memory consumption
   - CPU utilization
   - Disk I/O
   - Cache hit rates

3. **Bottleneck Categories:**
   - Slow tactics (`simp`, `omega`, etc.)
   - Large proof terms
   - Expensive type class synthesis
   - Deep recursion

**Performance Optimization Suggestions:**

1. **Tactic-Level:**
   - Replace `simp` with `simp only [...]`
   - Use `decide` for decidable props
   - Avoid repeated `cases`
   - Use `aesop` for automation

2. **Proof-Level:**
   - Extract lemmas from large proofs
   - Use term-mode for simple goals
   - Factor out common subproofs
   - Parallelize independent proofs

3. **Build-Level:**
   - Restructure module dependencies
   - Reduce import depth
   - Use `precompileModules`
   - Enable Lake caching

**Use Cases:**
1. **CI optimization:** Reduce build times
2. **Development:** Identify slow proofs during development
3. **Code review:** Check for performance regressions
4. **Research:** Study proof complexity

**Dependencies:**
- Syntax Validator (for valid code)
- Proof Optimizer (for suggestions)

**Success Metrics:**
- Profiling overhead < 10%
- Bottleneck detection accuracy > 90%
- Suggested optimizations improve performance > 80% of time
- Average optimization improvement > 25%

### 2.12 Concept Explainer

**Purpose:** Generate natural language explanations of LEAN 4 concepts, definitions, and proofs.

**Capabilities:**
- Explain definitions in plain language
- Describe proof strategies
- Translate formal logic to intuition
- Provide analogies and examples
- Generate step-by-step proof walkthroughs
- Adapt explanations to user level

**Tool Integration:**
- **Primary:** LSP (symbol information)
- **Secondary:** Library Navigator (related concepts)
- **Tertiary:** LLM APIs (for natural language generation)

**Implementation Approach:**
```lean
structure ConceptExplainer where
  symbolAnalyzer : SymbolAnalyzer
  libraryNavigator : LibraryNavigator
  nlgEngine : NaturalLanguageGenerator

def ConceptExplainer.explain (explainer : ConceptExplainer)
    (concept : Concept) (level : ExpertiseLevel) : Explanation := do
  -- Analyze concept structure
  let structure ← explainer.symbolAnalyzer.analyze concept
  
  -- Find related concepts
  let related ← explainer.libraryNavigator.findRelated concept
  
  -- Generate natural language explanation
  let explanation ← explainer.nlgEngine.generate {
    concept := concept
    structure := structure
    related := related
    targetLevel := level
  }
  
  -- Add examples
  let examples ← explainer.generateExamples concept level
  
  return {
    summary := explanation.summary
    detailed := explanation.detailed
    examples := examples
    related := related
  }
```

**Explanation Strategies:**

1. **Definitional:**
   - "A group is a set with an operation..."
   - Formal → informal translation
   - Emphasize key properties
   - Provide counter-examples

2. **Proof Strategy:**
   - "This proof proceeds by induction..."
   - Identify proof pattern (induction, cases, etc.)
   - Explain high-level structure
   - Detail key steps

3. **Intuitive:**
   - "Think of it like..."
   - Use analogies from familiar domains
   - Visual explanations when possible
   - Connect to prior knowledge

4. **Historical:**
   - "This theorem was first proved by..."
   - Mathematical context
   - Motivation for the theorem
   - Applications

**Expertise Level Adaptation:**
- **Beginner:** Simple language, many examples, step-by-step
- **Intermediate:** Assume basic knowledge, focus on techniques
- **Advanced:** Technical details, connections to literature
- **Expert:** Concise, emphasize novelty

**Use Cases:**
1. **Learning:** Help users understand code
2. **Documentation:** Auto-generate explanations
3. **Code review:** Explain changes to reviewers
4. **Teaching:** Generate lecture materials

**Dependencies:**
- Library Navigator (related concepts)
- Documentation Generator (formatting)

**Success Metrics:**
- Explanation clarity rating > 4/5
- Comprehension improvement (measured by quiz) > 50%
- Generation time < 10 seconds
- User preference over manual explanations > 60%

### 2.13 Dependency Analyzer

**Purpose:** Analyze and optimize module dependencies to improve build times and code organization.

**Capabilities:**
- Build dependency graphs
- Detect circular dependencies
- Identify import bloat
- Suggest import reordering
- Find minimal import sets
- Analyze import impact
- Suggest module splits

**Tool Integration:**
- **Primary:** Lake (build system)
- **Secondary:** LSP (symbol usage)
- **Tertiary:** Graph analysis libraries

**Implementation Approach:**
```lean
structure DependencyAnalyzer where
  lakeEnv : LakeEnvironment
  graphBuilder : GraphBuilder
  lspConnection : LSPConnection

def DependencyAnalyzer.analyze (analyzer : DependencyAnalyzer)
    (project : Project) : DependencyReport := do
  -- Build dependency graph
  let graph ← analyzer.buildDependencyGraph project
  
  -- Detect issues
  let circular := analyzer.findCircularDeps graph
  let bloat := analyzer.findImportBloat graph
  let deep := analyzer.findDeepImports graph
  
  -- Analyze impact
  let criticalPaths := analyzer.findCriticalPaths graph
  let hotspots := analyzer.findHotspots graph
  
  -- Generate suggestions
  let suggestions := analyzer.generateSuggestions {
    circular := circular
    bloat := bloat
    deep := deep
    critical := criticalPaths
  }
  
  return {
    graph := graph
    issues := circular ++ bloat ++ deep
    suggestions := suggestions
    metrics := analyzer.computeMetrics graph
  }
```

**Analysis Types:**

1. **Circular Dependencies:**
   ```
   A imports B
   B imports C
   C imports A  -- circular!
   ```
   - Detect cycles in import graph
   - Suggest cycle breaking strategies
   - Generate refactoring plan

2. **Import Bloat:**
   - Modules importing unnecessarily
   - Transitive imports that could be direct
   - Unused imports
   - Redundant imports

3. **Deep Import Chains:**
   ```
   A → B → C → D → E → F  (depth 6)
   ```
   - Long dependency chains slow builds
   - Suggest shortcuts
   - Recommend module restructuring

4. **Critical Path Analysis:**
   - Modules that block many others
   - Bottleneck identification
   - Parallelization opportunities

**Optimization Strategies:**

1. **Import Minimization:**
   - Remove unused imports
   - Use more specific imports
   - Break up large modules

2. **Module Reorganization:**
   - Group related definitions
   - Create interface modules
   - Separate implementation from interface

3. **Parallelization:**
   - Identify independent modules
   - Restructure to enable parallel builds
   - Reduce critical path length

**Use Cases:**
1. **Build optimization:** Reduce compilation time
2. **Code organization:** Improve module structure
3. **Maintenance:** Detect problematic dependencies
4. **Refactoring:** Guide module splits/merges

**Dependencies:**
- None (foundational agent)

**Success Metrics:**
- Circular dependency detection: 100%
- Import bloat detection > 85%
- Build time improvement > 20% after optimization
- Suggestion acceptance rate > 70%

### 2.14 Proof Strategy Advisor

**Purpose:** Suggest high-level proof strategies based on theorem structure and mathematical domain.

**Capabilities:**
- Analyze theorem statement structure
- Identify proof patterns (induction, contradiction, etc.)
- Suggest proof strategies
- Provide skeleton proofs
- Explain strategy rationale
- Adapt to proof progress

**Tool Integration:**
- **Primary:** LSP (goal state)
- **Secondary:** Library Navigator (similar theorems)
- **Tertiary:** Historical proof database

**Implementation Approach:**
```lean
structure ProofStrategyAdvisor where
  patternMatcher : TheoremPatternMatcher
  strategyDatabase : StrategyDatabase
  libraryNavigator : LibraryNavigator

def ProofStrategyAdvisor.advise (advisor : ProofStrategyAdvisor)
    (theorem : Theorem) : StrategyAdvice := do
  -- Analyze theorem structure
  let structure := advisor.patternMatcher.analyze theorem
  
  -- Match to known patterns
  let patterns := advisor.patternMatcher.findMatches structure
  
  -- Find similar proved theorems
  let similar ← advisor.libraryNavigator.findSimilar theorem
  
  -- Extract strategies from similar proofs
  let strategies := similar.map (·.strategy)
  
  -- Rank strategies
  let ranked := advisor.rankStrategies strategies patterns
  
  -- Generate advice
  return {
    recommendedStrategy := ranked.head!
    alternatives := ranked.tail
    rationale := advisor.explainStrategy ranked.head! theorem
    skeleton := advisor.generateSkeleton ranked.head! theorem
  }
```

**Proof Strategies:**

1. **Induction:**
   - **When:** `∀ n : Nat, P n` or recursive structures
   - **Skeleton:**
     ```lean
     intro n
     induction n with
     | zero => sorry  -- base case
     | succ n ih => sorry  -- inductive step
     ```

2. **Contradiction:**
   - **When:** Proving `¬ P` or `P → False`
   - **Skeleton:**
     ```lean
     intro h
     -- derive contradiction from h
     exact absurd ... h
     ```

3. **Case Analysis:**
   - **When:** Hypothesis is disjunction or sum type
   - **Skeleton:**
     ```lean
     cases h with
     | inl ha => sorry  -- case A
     | inr hb => sorry  -- case B
     ```

4. **Constructive:**
   - **When:** Proving existence `∃ x, P x`
   - **Skeleton:**
     ```lean
     use <witness>
     sorry  -- prove P witness
     ```

5. **Forward Reasoning:**
   - **When:** Many hypotheses, complex goal
   - **Skeleton:**
     ```lean
     have h1 := ...  -- derive intermediate fact
     have h2 := ...  -- another fact
     exact ...  -- combine to prove goal
     ```

6. **Calculational:**
   - **When:** Proving equation or inequality chain
   - **Skeleton:**
     ```lean
     calc
       a = b := sorry
       _ = c := sorry
       _ = d := sorry
     ```

**Pattern Recognition:**
- `∀ x, P x → Q x` → typically intro + apply
- `A ∧ B → C` → intro + cases + constructor
- `∀ n : Nat, P n` → typically induction
- `∃ x, P x ∧ Q x` → typically constructor twice
- `a ≤ b ∧ b ≤ c → a ≤ c` → transitivity

**Use Cases:**
1. **Proof start:** Get initial direction
2. **Stuck state:** Try alternative strategy
3. **Learning:** Understand proof patterns
4. **Teaching:** Explain proof techniques

**Dependencies:**
- Library Navigator (similar theorems)
- Tactic Recommender (low-level tactics)

**Success Metrics:**
- Strategy relevance > 75%
- Skeleton usefulness (% code retained) > 60%
- Time to first working proof -40%
- User satisfaction > 4/5

## 3. Architecture Patterns

### 3.1 Agent Coordination Patterns

**Hierarchical Coordination:**
```
Orchestrator Agent
├── Syntax Validator
├── Library Navigator
├── Tactic Recommender (uses Library Navigator)
├── Proof Optimizer (uses Tactic Recommender)
└── Documentation Generator (uses multiple specialists)
```

**Pipeline Pattern:**
```
Code Change → Syntax Validator → Code Reviewer → 
  Proof Optimizer → Documentation Generator → Commit
```

**Blackboard Pattern:**
```
Shared Knowledge Base
├── Current Goal State (updated by all)
├── Available Tactics (from Tactic Recommender)
├── Relevant Lemmas (from Library Navigator)
└── Error Diagnostics (from Error Diagnostician)

All agents read from and write to blackboard
```

**Request-Response Pattern:**
```
User/Agent → Request → Specialist → Response → User/Agent
```

### 3.2 Context Management Strategies

**Context Size Limits:**
- Keep context under 10K tokens per agent
- Summarize when context exceeds limit
- Use retrieval for historical information

**Context Sharing:**
```lean
structure SharedContext where
  goalState : GoalState
  availableHypotheses : Array Hypothesis
  recentTactics : Array Tactic
  relevantLemmas : Array Lemma
  errorHistory : Array Error

-- Each agent has view of SharedContext
-- Updates propagate to all agents
```

**Context Prioritization:**
1. Current goal state (highest priority)
2. Recent tactics and changes
3. Error messages
4. Available lemmas
5. Historical information (lowest priority)

### 3.3 Error Handling Approaches

**Graceful Degradation:**
```lean
def searchWithFallback (query : Query) : Task SearchResult := do
  try
    -- Try LeanSearch (AI-powered)
    leanSearch.search query
  catch _ =>
    try
      -- Fall back to Loogle (type-based)
      loogle.search (query.toTypePattern)
    catch _ =>
      -- Final fallback: local search
      localSearch.search query
```

**Error Recovery Strategies:**
1. **Retry with Exponential Backoff:**
   - First failure: retry immediately
   - Second failure: wait 1 second
   - Third failure: wait 2 seconds
   - Fourth failure: wait 4 seconds
   - After 5 failures: give up

2. **Circuit Breaker:**
   ```lean
   structure CircuitBreaker where
     failureCount : Nat
     lastFailure : Option Timestamp
     state : BreakerState  -- Open | HalfOpen | Closed
   
   -- Open: Service unavailable, don't try
   -- HalfOpen: Test if service recovered
   -- Closed: Normal operation
   ```

3. **Fallback Chain:**
   - Primary service → Secondary service → Cache → Default

### 3.4 Artifact-Based Communication

**Artifact Types:**
```lean
inductive Artifact where
  | proofFragment : ProofTerm → Artifact
  | tacticSequence : Array Tactic → Artifact
  | diagnosticReport : Array Diagnostic → Artifact
  | documentation : DocString → Artifact
  | searchResults : Array SearchResult → Artifact
```

**Artifact Lifecycle:**
1. **Creation:** Agent produces artifact
2. **Validation:** Artifact checked for correctness
3. **Storage:** Artifact stored in shared space
4. **Retrieval:** Other agents access artifact
5. **Update:** Artifact modified by agents
6. **Archival:** Old artifacts moved to history

**Artifact Versioning:**
```lean
structure VersionedArtifact where
  content : Artifact
  version : Nat
  timestamp : Timestamp
  author : AgentId
  parent : Option ArtifactId
```

## 4. Tool Integration Matrix

| Specialist | LSP | Loogle | LeanSearch | Aesop | Lake | Other |
|------------|-----|--------|------------|-------|------|-------|
| Syntax Validator | ✓✓✓ | - | - | - | - | - |
| Tactic Recommender | ✓✓✓ | ✓✓ | ✓✓ | ✓ | - | Proof DB |
| Library Navigator | ✓✓ | ✓✓✓ | ✓✓✓ | - | - | Docs |
| Proof Optimizer | ✓✓✓ | ✓ | - | ✓✓✓ | ✓ | - |
| Test Generator | ✓✓✓ | - | - | ✓✓ | - | Random Gen |
| Documentation Generator | ✓✓✓ | ✓ | - | - | ✓✓ | Template Engine |
| Error Diagnostician | ✓✓✓ | ✓✓ | - | - | - | Error DB |
| Code Reviewer | ✓✓ | ✓ | - | - | ✓✓✓ | All Specialists |
| Refactoring Assistant | ✓✓✓ | - | - | - | ✓✓ | - |
| Learning Path Generator | ✓ | ✓✓ | ✓✓ | - | - | Concept Graph |
| Performance Profiler | ✓✓✓ | - | - | - | ✓✓✓ | - |
| Concept Explainer | ✓✓ | ✓✓ | ✓✓ | - | - | LLM APIs |
| Dependency Analyzer | ✓ | - | - | - | ✓✓✓ | Graph Lib |
| Proof Strategy Advisor | ✓✓✓ | ✓✓ | - | ✓ | - | Strategy DB |

Legend: ✓✓✓ = Primary, ✓✓ = Secondary, ✓ = Tertiary, - = Not used

## 5. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-4)

**Priority 1 - Core Infrastructure:**
1. **Syntax Validator** (Week 1)
   - LSP connection management
   - Diagnostic parsing
   - Error caching
   - **Success Criteria:** Can validate files and report errors reliably

2. **Library Navigator** (Week 2)
   - Loogle integration
   - LeanSearch integration
   - Result caching
   - **Success Criteria:** Can search and retrieve theorems accurately

3. **Error Diagnostician** (Week 3)
   - Error categorization
   - Basic fix suggestions
   - Pattern database
   - **Success Criteria:** Provides helpful error messages for common errors

4. **Integration Testing** (Week 4)
   - Test infrastructure setup
   - Basic coordination tests
   - Performance baselines
   - **Success Criteria:** All Phase 1 agents work together

### Phase 2: Development Tools (Weeks 5-8)

**Priority 2 - Developer Assistance:**
5. **Tactic Recommender** (Week 5-6)
   - Pattern-based suggestions
   - Type-based search integration
   - Success tracking
   - **Success Criteria:** Relevant suggestions for 50%+ of goals

6. **Proof Optimizer** (Week 7)
   - Redundancy detection
   - Library lemma suggestions
   - Basic Aesop integration
   - **Success Criteria:** Finds improvements in 30%+ of proofs

7. **Code Reviewer** (Week 8)
   - Style checking
   - Basic linting
   - Specialist coordination
   - **Success Criteria:** Catches 80%+ of style issues

### Phase 3: Advanced Features (Weeks 9-12)

**Priority 3 - Advanced Assistance:**
8. **Refactoring Assistant** (Week 9)
   - Safe renames
   - Extract lemma
   - Basic move operations
   - **Success Criteria:** 99%+ correctness on refactorings

9. **Test Generator** (Week 10)
   - Random test generation
   - Edge case generation
   - Basic counterexample search
   - **Success Criteria:** Generates useful tests for 70%+ of theorems

10. **Documentation Generator** (Week 11)
    - Docstring extraction
    - Example generation
    - Basic API docs
    - **Success Criteria:** Complete documentation for 90%+ of symbols

11. **Integration & Polish** (Week 12)
    - Performance optimization
    - Bug fixes
    - User testing
    - **Success Criteria:** System is stable and usable

### Phase 4: Analysis & Learning (Weeks 13-16)

**Priority 4 - Insights & Education:**
12. **Performance Profiler** (Week 13)
    - Timing measurement
    - Bottleneck identification
    - Suggestion generation
    - **Success Criteria:** Identifies bottlenecks accurately

13. **Dependency Analyzer** (Week 14)
    - Dependency graph construction
    - Circular dependency detection
    - Optimization suggestions
    - **Success Criteria:** Finds all circular dependencies

14. **Learning Path Generator** (Week 15)
    - Concept graph construction
    - Basic path generation
    - Resource assignment
    - **Success Criteria:** Generates coherent learning paths

15. **Proof Strategy Advisor** (Week 16)
    - Pattern recognition
    - Strategy database
    - Skeleton generation
    - **Success Criteria:** Helpful strategies for 70%+ of theorems

### Phase 5: Natural Language & Polish (Weeks 17-20)

**Priority 5 - Explanation & Enhancement:**
16. **Concept Explainer** (Week 17-18)
    - Natural language generation
    - Example generation
    - Level adaptation
    - **Success Criteria:** Clear explanations rated 4+/5

17. **System Integration** (Week 19)
    - Agent orchestration refinement
    - Context optimization
    - Performance tuning
    - **Success Criteria:** All agents work smoothly together

18. **User Interface** (Week 20)
    - Command-line interface
    - VS Code integration
    - Documentation
    - **Success Criteria:** System is easy to use

### Dependencies Between Specialists

```
Syntax Validator (foundational)
├── Tactic Recommender
│   ├── Proof Optimizer
│   └── Proof Strategy Advisor
├── Error Diagnostician
│   └── Code Reviewer
└── Refactoring Assistant

Library Navigator (foundational)
├── Tactic Recommender
├── Documentation Generator
├── Test Generator
├── Learning Path Generator
├── Concept Explainer
└── Proof Strategy Advisor

Performance Profiler (independent)
Dependency Analyzer (independent)
```

### Risk Mitigation

**High-Risk Items:**
1. **LSP stability:** LSP may crash or be slow
   - *Mitigation:* Robust error handling, automatic reconnection
   
2. **Search service availability:** Loogle/LeanSearch may be down
   - *Mitigation:* Caching, fallback to local search
   
3. **Performance:** Agents may be too slow
   - *Mitigation:* Profiling, caching, incremental updates

4. **Accuracy:** Suggestions may be wrong
   - *Mitigation:* Validation, user feedback, learning

**Medium-Risk Items:**
1. **Agent coordination complexity**
   - *Mitigation:* Simple protocols, clear interfaces
   
2. **Context management**
   - *Mitigation:* Size limits, summarization
   
3. **Tool version compatibility**
   - *Mitigation:* Version checking, compatibility layers

## 6. Key Research Findings (Top 10)

### 1. LEAN 4's LSP is production-ready and highly capable
The Language Server Protocol implementation in LEAN 4 provides real-time verification, rich diagnostics, and comprehensive IDE features. This makes it the natural foundation for any specialist agent system.

### 2. Dual search tools (Loogle + LeanSearch) provide complementary coverage
Type-based search (Loogle) excels at precise matching, while semantic search (LeanSearch) handles natural language queries. Using both provides comprehensive theorem discovery.

### 3. Aesop's architecture is an excellent template for extensible automation
The three-tiered rule system (norm/safe/unsafe), success probabilities, and transparent operation mode provide patterns applicable to specialist agent design.

### 4. Caching is critical for performance but requires careful invalidation
All external services (LSP, Loogle, LeanSearch) benefit from caching, but cache invalidation must be tied to file changes, dependency updates, and service availability.

### 5. Graceful degradation enables robust systems
When services fail, specialists should fall back to simpler approaches rather than failing completely. This maintains usability even under adverse conditions.

### 6. Proof script generation enhances transparency and trust
Following Aesop's `aesop?` pattern, agents should generate human-readable artifacts showing how they reached conclusions or suggestions.

### 7. Single-responsibility agents compose better than monolithic systems
Each specialist focusing on one task allows for clearer interfaces, easier testing, and better maintainability than attempting to build one "do-everything" agent.

### 8. Context management requires strict discipline
Unbounded context growth leads to poor performance and unreliable behavior. Agents must actively manage context size through summarization and prioritization.

### 9. Tool integration requires handling multiple failure modes
Networks fail, services go down, APIs change. Robust agents must handle connection failures, timeouts, version mismatches, and degraded service.

### 10. Learning from user feedback is essential
Agents should track which suggestions are accepted/rejected and use this feedback to improve. Simple success tracking can significantly boost relevance over time.

## 7. Bibliography

### Official LEAN 4 Resources
- LEAN 4 GitHub Repository: https://github.com/leanprover/lean4
- LEAN 4 Language Reference: https://lean-lang.org/doc/reference/latest/
- LEAN 4 VS Code Extension: https://github.com/leanprover/vscode-lean4
- Lake Build System: https://github.com/leanprover/lake (now merged into LEAN 4)

### Tool Documentation
- Loogle (Type Search): https://loogle.lean-lang.org/
  - GitHub: https://github.com/nomeata/loogle
- LeanSearch (Semantic Search): https://leansearch.net/
- Aesop (Proof Automation): https://github.com/leanprover-community/aesop
  - Paper: "Aesop: White-box Automation for Lean 4"
- ProofWidgets: https://github.com/leanprover-community/ProofWidgets4
  - Paper: "An Extensible User Interface for Lean 4" (ITP 2023)

### Mathlib Resources
- Mathlib4: https://github.com/leanprover-community/mathlib4
- Mathlib Documentation: https://leanprover-community.github.io/mathlib4_docs/
- Contribution Guide: https://leanprover-community.github.io/contribute/
- Style Guide: https://leanprover-community.github.io/contribute/style.html

### Multi-Agent Systems Research
- "AgentVerse: Facilitating Multi-Agent Collaboration" (arXiv:2308.10848)
  - Explores multi-agent coordination patterns and emergent behaviors
- "MetaGPT: Meta Programming for Multi-Agent Systems"
  - Discusses role-based agent coordination

### Community Resources
- Lean Zulip Chat: https://leanprover.zulipchat.com/
  - #lean4 channel for general discussion
  - #mathlib4 channel for library development
  - #new members channel for beginners
- Lean FRO (Focused Research Organization): https://lean-lang.org/fro/
- Reservoir (Package Repository): https://reservoir.lean-lang.org/

### Academic Papers
- "Theorem Proving in Lean" (Tutorial Book)
- "The Lean Mathematical Library" (CPP 2020)
- "Metaprogramming in Lean 4" (Technical Documentation)

### Related Proof Assistants (for comparison)
- Coq: https://coq.inria.fr/
- Isabelle/HOL: https://isabelle.in.tum.de/
- Agda: https://wiki.portal.chalmers.se/agda/

### Software Engineering Best Practices
- "Clean Architecture" by Robert C. Martin (for agent design principles)
- "Designing Data-Intensive Applications" by Martin Kleppmann (for caching strategies)
- "Release It!" by Michael T. Nygard (for error handling patterns)

---

## Appendix A: Tool Comparison Matrix

| Feature | LSP | Loogle | LeanSearch | Aesop | Lake |
|---------|-----|--------|------------|-------|------|
| **Primary Purpose** | IDE features | Type search | Semantic search | Automation | Build system |
| **Input Type** | File contents | Type patterns | Natural language | Goal state | Build config |
| **Output Type** | Diagnostics | Theorems | Theorems | Proof script | Compiled artifacts |
| **Performance** | Real-time | Fast (<1s) | Medium (1-3s) | Variable | Parallel |
| **Reliability** | High | High | Medium | High | High |
| **Offline Mode** | Yes | No (needs server) | No (needs server) | Yes | Yes |
| **Caching** | Built-in | Recommended | Recommended | N/A | Built-in |
| **Extension** | Via plugins | N/A | N/A | Highly extensible | Highly extensible |

## Appendix B: Example Integration Code

### B.1 LSP Integration Example
```lean
import Lean.Data.Lsp

structure LSPIntegration where
  process : IO.Process.Child
  requestId : Nat
  
def LSPIntegration.sendRequest (lsp : LSPIntegration) 
    (method : String) (params : Json) : IO Json := do
  let request := Json.mkObj [
    ("jsonrpc", "2.0"),
    ("id", lsp.requestId),
    ("method", method),
    ("params", params)
  ]
  -- Send request
  lsp.process.stdin.putStr (request.compress ++ "\n")
  -- Read response
  let response ← lsp.process.stdout.getLine
  return Json.parse response

def LSPIntegration.validateFile (lsp : LSPIntegration)
    (file : FilePath) : IO (Array Diagnostic) := do
  let params := Json.mkObj [
    ("textDocument", Json.mkObj [
      ("uri", s!"file://{file}")
    ])
  ]
  let response ← lsp.sendRequest "textDocument/publishDiagnostics" params
  -- Parse diagnostics from response
  return parseDiagnostics response
```

### B.2 Loogle Integration Example
```lean
import Lean.Data.Json

structure LoogleClient where
  baseUrl : String := "https://loogle.lean-lang.org"
  httpClient : HttpClient
  
def LoogleClient.search (client : LoogleClient) 
    (pattern : String) : IO (Array SearchResult) := do
  let url := s!"{client.baseUrl}/api/search?q={pattern}"
  let response ← client.httpClient.get url
  return parseSearchResults response

-- Example usage:
-- let client := { baseUrl := "...", httpClient := ... }
-- let results ← client.search "_ * (_ ^ _)"
```

### B.3 Agent Coordination Example
```lean
structure AgentOrchestrator where
  syntaxValidator : SyntaxValidator
  libraryNavigator : LibraryNavigator
  tacticRecommender : TacticRecommender
  
def AgentOrchestrator.assistProof (orch : AgentOrchestrator)
    (file : FilePath) (position : Position) : IO ProofAssistance := do
  -- Step 1: Validate syntax
  let diagnostics ← orch.syntaxValidator.validateFile file
  if !diagnostics.isEmpty then
    return { errors := diagnostics, suggestions := #[] }
  
  -- Step 2: Get goal state from LSP
  let goal ← orch.syntaxValidator.lspConnection.getGoalAt file position
  
  -- Step 3: Search for relevant lemmas
  let lemmas ← orch.libraryNavigator.findRelevantLemmas goal
  
  -- Step 4: Recommend tactics
  let tactics ← orch.tacticRecommender.recommend goal lemmas
  
  return {
    errors := #[]
    relevantLemmas := lemmas
    suggestedTactics := tactics
  }
```

---

**End of Report**

*This research report provides a comprehensive foundation for designing and implementing specialist agents for LEAN 4 theorem proving systems. The findings, tool analysis, and implementation roadmap should enable systematic development of a robust multi-agent system for proof automation and assistance.*
