---
name: lean
agent: orchestrator
description: "Implement a LEAN 4 proof with intelligent multi-phase execution"
---

You are implementing a LEAN 4 proof for the ProofChecker project using an enhanced multi-phase workflow.

**Project Number:** $ARGUMENTS

**Usage:**
```
/lean NNN [--flags]
```

**Flags:**
- `--fast`: Skip research, optimization, and documentation phases (fastest execution)
- `--skip-research`: Skip pre-planning and research phases
- `--skip-optimization`: Skip proof optimization phase
- `--skip-docs`: Skip documentation generation phase
- `--full`: Execute all phases regardless of complexity (most thorough)
- `--help`: Show this help message

**Context Loaded:**
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/
@/home/benjamin/Projects/ProofChecker/.opencode/context/logic/
@/home/benjamin/Projects/ProofChecker/.opencode/context/core/system/artifact-management.md

## Multi-Phase Workflow

<workflow>
  <phase id="0" name="Input Validation & Configuration">
    <action>Parse input and determine execution strategy</action>
    <process>
      1. Parse project number from $ARGUMENTS
      2. Parse optional flags (--fast, --skip-*, --full, --help)
      3. If --help flag: Display usage information and exit
      4. Locate project directory: .opencode/specs/NNN_project/
      5. Locate implementation plan: .opencode/specs/NNN_project/plans/implementation-*.md
      6. Read plan and extract complexity level (if available)
      7. Determine phase execution strategy:
         - If --fast: Skip phases 1, 2, 5, 6
         - If --full: Execute all phases
         - If complexity = "simple": Skip phases 1, 2
         - If complexity = "moderate": Skip phase 1
         - If complexity = "complex": Execute all phases
         - Apply individual --skip-* flags
      8. Load project state from state.json (if exists)
      9. Validate prerequisites (dependencies completed)
      10. Create artifact directories if needed:
          - .opencode/specs/NNN_project/reports/
          - .opencode/specs/NNN_project/research/
          - .opencode/specs/NNN_project/examples/
          - .opencode/specs/NNN_project/summaries/
    </process>
    <output>
      - execution_config: Phase execution flags
      - project_context: Loaded plan, state, metadata
      - phase_skip_flags: Boolean flags for each phase
    </output>
    <error_handling>
      - Project not found → Error: "Project NNN not found. Use /task to create implementation plan."
      - Plan not found → Error: "Implementation plan not found for project NNN."
      - Invalid flags → Error: "Invalid flag. Use --help for usage."
      - Invalid project number → Error: "Invalid project number format."
    </error_handling>
    <skip_logic>Never skip this phase</skip_logic>
  </phase>

  <phase id="1" name="Pre-Planning Analysis" skippable="true">
    <condition>
      Execute if: NOT --skip-research AND NOT --fast AND complexity != "simple"
    </condition>
    <action>Analyze complexity and map dependencies</action>
    <routing parallel="true">
      <route to="@subagents/specialists/complexity-analyzer">
        <context_level>Level 2</context_level>
        <pass_data>
          - Task description from plan
          - Related research reports (if any)
          - Domain context (@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/domain/)
          - Domain context (@/home/benjamin/Projects/ProofChecker/.opencode/context/logic/domain/)
          - Existing codebase structure
        </pass_data>
        <expected_return>
          {
            "complexity_level": "simple|moderate|complex",
            "effort_estimate": "30min-2hr",
            "files_affected": 3,
            "challenges": ["Challenge 1", "Challenge 2"],
            "dependencies": ["Dep 1", "Dep 2"],
            "risk_factors": ["Risk 1"],
            "summary": "Brief complexity summary"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/complexity-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/dependency-mapper">
        <context_level>Level 2</context_level>
        <pass_data>
          - Task description
          - Complexity assessment (from complexity-analyzer)
          - Research reports (if any)
          - Existing codebase structure
          - LEAN library information
        </pass_data>
        <expected_return>
          {
            "required_imports": ["Import.Path.1", "Import.Path.2"],
            "dependent_definitions": ["Def1", "Def2"],
            "prerequisites": ["Prereq1", "Prereq2"],
            "library_functions": ["Mathlib.Function1", "Mathlib.Function2"],
            "summary": "Brief dependency summary"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/dependencies-001.md</output_artifact>
      </route>
    </routing>
    <output>
      - Complexity assessment report
      - Dependency map
      - Enriched context for Phase 3
    </output>
    <error_handling>
      - Specialist failure → Log warning, continue with partial data
      - Missing context → Use defaults, flag for manual review
      - Both specialists fail → Log warning, continue to Phase 2
    </error_handling>
    <skip_logic>
      Skip if: --skip-research flag OR --fast flag OR complexity = "simple"
    </skip_logic>
  </phase>

  <phase id="2" name="Research & Strategy" skippable="true">
    <condition>
      Execute if: NOT --skip-research AND NOT (--fast AND complexity = "simple")
    </condition>
    <action>Search libraries, suggest strategies, recommend tactics</action>
    <routing parallel="true">
      <route to="@subagents/specialists/library-navigator">
        <context_level>Level 2</context_level>
        <pass_data>
          - Theorem statements from plan
          - Type signatures
          - Keywords from task description
        </pass_data>
        <expected_return>
          {
            "similar_theorems": [
              {
                "name": "Mathlib.Theorem1",
                "similarity": 0.85,
                "source": "loogle",
                "type_signature": "...",
                "documentation": "..."
              }
            ],
            "relevant_definitions": [...],
            "summary": "Found 5 similar theorems in Mathlib"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/research/library-search-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/proof-strategy-advisor">
        <context_level>Level 2</context_level>
        <pass_data>
          - Theorem statements
          - Similar theorems (from library-navigator)
          - Complexity assessment (from Phase 1, if executed)
        </pass_data>
        <expected_return>
          {
            "strategies": [
              {
                "name": "Induction on n",
                "description": "...",
                "applicability": 0.95,
                "complexity": "medium",
                "skeleton": "theorem ... := by\n  induction n with\n  ...",
                "steps": [...]
              }
            ],
            "recommended_strategy": "Induction on n",
            "summary": "Recommend induction strategy"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/research/strategies-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/tactic-recommender">
        <context_level>Level 2</context_level>
        <pass_data>
          - Theorem statements
          - Proof strategies (from proof-strategy-advisor)
          - Goal states (if available)
        </pass_data>
        <expected_return>
          {
            "tactic_suggestions": [
              {
                "tactic": "induction n",
                "applicability": 0.9,
                "context": "For inductive types"
              }
            ],
            "tactic_sequences": [...],
            "summary": "Recommend induction, simp, rfl sequence"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/research/tactics-001.md</output_artifact>
      </route>
    </routing>
    <output>
      - Library search results
      - Proof strategies
      - Tactic recommendations
      - Enriched context for Phase 3
    </output>
    <error_handling>
      - No similar theorems → Continue with strategy suggestions
      - Strategy advisor fails → Continue with tactic recommendations
      - All specialists fail → Log warning, continue to implementation
      - Network timeout → Log warning, continue with partial results
    </error_handling>
    <skip_logic>
      Skip if: --skip-research flag OR (--fast flag AND complexity = "simple")
    </skip_logic>
  </phase>

  <phase id="3" name="Implementation">
    <action>Implement proofs using proof-developer with enriched context</action>
    <routing>
      <route to="@subagents/proof-developer">
        <context_level>Level 1</context_level>
        <pass_data>
          - Implementation plan
          - Complexity assessment (from Phase 1, if executed)
          - Dependency map (from Phase 1, if executed)
          - Library search results (from Phase 2, if executed)
          - Proof strategies (from Phase 2, if executed)
          - Tactic recommendations (from Phase 2, if executed)
          - All domain context (@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/)
          - All logic context (@/home/benjamin/Projects/ProofChecker/.opencode/context/logic/)
        </pass_data>
        <expected_return>
          {
            "project_number": NNN,
            "artifacts": [...],
            "summary": "Brief implementation summary",
            "files_modified": ["File1.lean", "File2.lean"],
            "verification_status": "passed|failed",
            "git_commits": [{"hash": "abc123", "message": "..."}],
            "documentation_needed": [...],
            "status": "completed|partial|failed"
          }
        </expected_return>
        <note>
          proof-developer will coordinate tactic-specialist, term-mode-specialist,
          metaprogramming-specialist, syntax-validator, and error-diagnostics as needed.
        </note>
      </route>
    </routing>
    <output>
      - Implemented LEAN files
      - Implementation summary: .opencode/specs/NNN_project/summaries/implementation-summary.md
      - Git commits
      - Verification status
    </output>
    <error_handling>
      - Type errors → Invoke error-diagnostics → Retry implementation
      - Specialist failure → Try alternative specialist or approach
      - Persistent errors → Document in summary, mark step as incomplete
      - Max retries (3) → Escalate to user with detailed error report
    </error_handling>
    <skip_logic>Never skip this phase (core functionality)</skip_logic>
  </phase>

  <phase id="4" name="Verification & Quality" skippable="true">
    <condition>
      Execute if: NOT --fast AND NOT --skip-verification
    </condition>
    <action>Verify proofs, review code, check style</action>
    <routing parallel="true">
      <route to="@subagents/specialists/verification-specialist">
        <context_level>Level 2</context_level>
        <pass_data>
          - Implemented files
          - Verification standards (@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/standards/)
          - Style guides
          - Proof conventions
        </pass_data>
        <expected_return>
          {
            "compliance_score": 92.5,
            "issues": [
              {
                "type": "style",
                "severity": "minor",
                "file": "File.lean",
                "line": 42,
                "description": "...",
                "suggestion": "..."
              }
            ],
            "summary": "92.5% compliant, 3 minor issues"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/verification-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/code-reviewer">
        <context_level>Level 2</context_level>
        <pass_data>
          - Implemented files
          - Code review standards
          - Proof patterns (@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/patterns/)
        </pass_data>
        <expected_return>
          {
            "review_score": 88.0,
            "issues": [
              {
                "category": "readability",
                "severity": "moderate",
                "description": "...",
                "suggestion": "..."
              }
            ],
            "strengths": ["Good tactic usage", "Clear structure"],
            "summary": "Good quality, minor readability improvements suggested"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/code-review-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/style-checker">
        <context_level>Level 2</context_level>
        <pass_data>
          - Implemented files
          - Style guide (@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/standards/lean4-style-guide.md)
        </pass_data>
        <expected_return>
          {
            "violations": [
              {
                "rule": "naming_convention",
                "file": "File.lean",
                "line": 15,
                "description": "...",
                "fix": "..."
              }
            ],
            "compliance_percentage": 95.0,
            "summary": "95% style compliant, 2 naming violations"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/style-check-001.md</output_artifact>
      </route>
    </routing>
    <output>
      - Verification report with compliance score
      - Code review report with suggestions
      - Style check report with violations
      - Aggregated quality score
    </output>
    <error_handling>
      - Specialist failure → Log warning, continue with other specialists
      - Critical issues found → Flag for user attention, suggest fixes
      - Low scores → Generate detailed improvement recommendations
    </error_handling>
    <skip_logic>
      Skip if: --fast flag OR --skip-verification flag
    </skip_logic>
  </phase>

  <phase id="5" name="Optimization" skippable="true">
    <condition>
      Execute if: NOT --skip-optimization AND NOT --fast AND proofs_length > 5_lines
    </condition>
    <action>Optimize proof size and performance</action>
    <routing sequential="true">
      <route to="@subagents/specialists/proof-simplifier">
        <context_level>Level 2</context_level>
        <pass_data>
          - Implemented proofs
          - Simplification patterns
          - Proof conventions
        </pass_data>
        <expected_return>
          {
            "simplifications": [
              {
                "theorem": "theorem_name",
                "original_lines": 15,
                "simplified_lines": 8,
                "changes": ["Removed redundant simp", "Combined tactics"],
                "simplified_proof": "..."
              }
            ],
            "total_reduction": "35% fewer lines",
            "summary": "Simplified 3 proofs, 35% reduction"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/simplification-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/proof-optimizer">
        <context_level>Level 2</context_level>
        <pass_data>
          - Simplified proofs (from proof-simplifier)
          - Optimization patterns
          - Performance targets
        </pass_data>
        <expected_return>
          {
            "optimizations": [
              {
                "theorem": "theorem_name",
                "optimization": "Replaced simp with rfl",
                "performance_gain": "20% faster compilation",
                "optimized_proof": "..."
              }
            ],
            "summary": "Optimized 2 proofs, 15% faster compilation"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/optimization-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/performance-profiler" conditional="true">
        <condition>compilation_time > 3s for any proof</condition>
        <context_level>Level 2</context_level>
        <pass_data>
          - Optimized proofs
          - Compilation metrics
        </pass_data>
        <expected_return>
          {
            "bottlenecks": [
              {
                "theorem": "theorem_name",
                "compilation_time": "5.2s",
                "bottleneck": "Complex simp call",
                "suggestion": "Split into smaller lemmas"
              }
            ],
            "summary": "1 bottleneck identified"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/performance-001.md</output_artifact>
      </route>
    </routing>
    <output>
      - Simplified proofs (applied to files)
      - Optimized proofs (applied to files)
      - Performance profile (if triggered)
      - Optimization summary
    </output>
    <error_handling>
      - Simplification breaks proof → Revert, document in report
      - Optimization breaks proof → Revert, document in report
      - Profiler fails → Skip profiling, continue
    </error_handling>
    <skip_logic>
      Skip if: --skip-optimization flag OR --fast flag OR all proofs < 5 lines
      Skip performance-profiler if: All compilation times < 3s
    </skip_logic>
  </phase>

  <phase id="6" name="Documentation" skippable="true">
    <condition>
      Execute if: NOT --skip-docs AND NOT --fast
    </condition>
    <action>Generate examples, docstrings, analyze gaps</action>
    <routing parallel="true">
      <route to="@subagents/specialists/example-builder">
        <context_level>Level 2</context_level>
        <pass_data>
          - Implemented theorems/definitions
          - Documentation standards
          - Example patterns
        </pass_data>
        <expected_return>
          {
            "examples": [
              {
                "theorem": "theorem_name",
                "example_code": "#eval ...",
                "description": "Example demonstrating...",
                "test_status": "passed"
              }
            ],
            "summary": "Generated 5 examples"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/examples/examples-001.md</output_artifact>
      </route>
      
      <route to="@subagents/specialists/documentation-generator">
        <context_level>Level 2</context_level>
        <pass_data>
          - Implemented files
          - Documentation standards (@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/standards/documentation-standards.md)
          - Docstring templates
        </pass_data>
        <expected_return>
          {
            "docstrings": [
              {
                "item": "theorem_name",
                "docstring": "/-- Theorem proving... -/",
                "applied": true
              }
            ],
            "summary": "Generated 8 docstrings"
          }
        </expected_return>
        <note>Docstrings applied directly to files</note>
      </route>
      
      <route to="@subagents/specialists/doc-analyzer">
        <context_level>Level 2</context_level>
        <pass_data>
          - Implemented files (with docstrings)
          - Documentation standards
          - Coverage requirements
        </pass_data>
        <expected_return>
          {
            "coverage": 92.5,
            "gaps": [
              {
                "item": "helper_lemma",
                "gap_type": "missing_docstring",
                "severity": "minor"
              }
            ],
            "bloat": [],
            "summary": "92.5% coverage, 1 minor gap"
          }
        </expected_return>
        <output_artifact>.opencode/specs/NNN_project/reports/documentation-001.md</output_artifact>
      </route>
    </routing>
    <output>
      - Examples file with test cases
      - Docstrings applied to code
      - Documentation gap analysis report
      - Updated files with documentation
    </output>
    <error_handling>
      - Example generation fails → Log warning, continue
      - Docstring application fails → Log warning, save to separate file
      - Doc analyzer fails → Skip analysis, continue
    </error_handling>
    <skip_logic>
      Skip if: --skip-docs flag OR --fast flag
      Skip example-builder if: No public theorems
      Skip doc-analyzer if: documentation-generator failed
    </skip_logic>
  </phase>

  <phase id="7" name="Finalization">
    <action>Aggregate results, update status, commit, return summary</action>
    <process>
      1. Aggregate all reports and artifacts
      2. Calculate overall metrics:
         - Total implementation time
         - Complexity vs. actual effort
         - Quality scores (verification, code review, style)
         - Optimization gains
         - Documentation coverage
      3. Update IMPLEMENTATION_STATUS.md:
         - Mark implemented theorems/definitions as complete
         - Update module completion percentages
         - Add notes about optimizations or issues
         - Update last modified date
      4. Git commit via git-workflow-manager:
         - Commit message format: "feat(#NNN): Implement {names}"
         - Include quality metrics in commit message
         - Include artifacts reference
      5. Create comprehensive summary document
      6. Update project state.json:
         - Project status, completion date, duration
         - Quality scores, artifacts, git commits
      7. Return summary and artifact references to user
    </process>
    <routing>
      <route to="@subagents/specialists/git-workflow-manager">
        <context_level>Level 2</context_level>
        <pass_data>
          - Modified files
          - Commit message template
          - Project metadata
          - Quality metrics
        </pass_data>
        <expected_return>
          {
            "commit_hash": "abc123",
            "commit_message": "feat(#NNN): Implement theorem_name"
          }
        </expected_return>
      </route>
    </routing>
    <output>
      - Comprehensive summary document: .opencode/specs/NNN_project/summaries/comprehensive-summary.md
      - Updated IMPLEMENTATION_STATUS.md
      - Git commit
      - Updated project state.json
      - User-facing summary with artifact references
    </output>
    <error_handling>
      - IMPLEMENTATION_STATUS.md update fails → Log warning, continue
      - Git commit fails → Log error, provide manual commit instructions
      - Summary generation fails → Return minimal summary
      - state.json update fails → Log warning, continue
    </error_handling>
    <skip_logic>Never skip this phase (required for completion)</skip_logic>
  </phase>
</workflow>

## Expected Output

Present to user:

```
✅ Implementation Complete: {Project Name}

**Project**: #NNN
**Duration**: {total_time}
**Complexity**: {level} (estimated: {estimate}, actual: {actual})

**Summary**: {3-5 sentence summary of what was implemented}

**Metrics**:
- Verification: {score}% ✅
- Code Review: {score}% ✅
- Style Compliance: {score}% ✅
- Optimization: {reduction}% size reduction, {speedup}% faster
- Documentation: {coverage}% coverage

**Files Modified**: {count}
- {file1}
- {file2}

**Git Commits**:
- {commit_hash}: {commit_message}

**Artifacts**:
- Implementation Summary: {path}
- Verification Report: {path}
- Code Review: {path}
- Optimization Report: {path}
- Documentation Analysis: {path}
- Examples: {path}

**Next Steps**:
- {recommendation_1}
- {recommendation_2}
```

Execute the multi-phase implementation workflow now.
