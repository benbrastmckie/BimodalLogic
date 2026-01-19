---
next_project_number: 601
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 8
  completed: 188
  in_progress: 1
  not_started: 26
  abandoned: 18
  total: 209
priority_distribution:
  critical: 0
  high: 5
  medium: 4
  low: 2
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 600. Fix Subagent Metadata Passing in Agent System
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19

**Description**: Study the research output from /home/benjamin/Projects/ProofChecker/.claude/output/research.md which shows agents attempting to pass metadata in JSON blocks back to the primary agent, but the JSON is printing to console instead of being parsed. Research best practices for subagent metadata passing in Claude Code 2026. Improve the agent system to avoid printing JSON output to console and eliminate the 'continue' interruptions demonstrated in the research output.

---

### 599. Troubleshoot jq Escaping in Agent System
- **Effort**: 2-3 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19
- **Research**: [research-001.md](specs/599_troubleshoot_jq_escaping_agent_system/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/599_troubleshoot_jq_escaping_agent_system/plans/implementation-001.md)

**Description**: Troubleshoot jq escaping issues in agent system. The not-equals operator is being escaped when passed through bash, causing jq parse errors. Fix skill-task and related skills to properly handle jq operators. Document correct patterns in context files to ensure consistent jq usage across the system.

---

### 597. Re-prove main_provable_iff_valid in Metalogic_v2
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: lean
- **Created**: 2026-01-19
- **Research**: [research-001.md](specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/597_reprove_main_provable_iff_valid_metalogic_v2/plans/implementation-001.md)

**Description**: Re-prove main_provable_iff_valid within Metalogic_v2 to achieve full independence from old Metalogic/. This will allow complete deprecation of Theories/Bimodal/Metalogic/ directory.

---

### 585. Add Session Cleanup to Agents
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19

**Description**: Add explicit session cleanup stage to all agent return workflows. Before returning JSON result, agents should clear large context references from memory and log session completion. Add Stage 8 (Session Cleanup) to lean-implementation-agent, general-implementation-agent, latex-implementation-agent after their Stage 7 (Return Structured JSON). This reduces memory footprint before agent termination.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-12
- **Priority**: High
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 568. Expand Logos Test Coverage
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-18
- **Source**: Code Review 2026-01-17

**Description**: Expand test coverage for Logos layer to match Bimodal layer standards. Currently ~40 Logos theory files have limited or no test coverage. Create comprehensive test suite including integration tests for layer extensions and property-based testing for Logos semantics.

---

### 595. Remove Maintenance Directory and Fix Review State Management
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: meta
- **Research**: [research-001.md](specs/595_remove_maintenance_dir_fix_review_state/reports/research-001.md)
- **Created**: 2026-01-19

**Description**: Remove specs/maintenance/ directory and all documentation references (unused by any commands). Fix /review command to maintain reviews/state.json with brief descriptions, file links, and metadata. Ensure /review commits changes after updates.

---

### 596. Constructive Finite Model Bounds
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-18

**Description**: The Finite Model Property currently uses a trivial witness (identity function on satisfiability). Establish constructive finite model bounds instead, archiving the old method to the Bimodal/Boneyard/ once the constructive alternative is fully implemented with zero sorries.

---

### 483. Investigate LaTeX aux file corruption errors
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: latex

**Description**: When making changes to LaTeX files (e.g., 00-Introduction.tex), rebuilding sometimes produces "File ended while scanning use of \@newl@bel" and "\@@BOOKMARK" errors, plus "Extra }, or forgotten \endgroup" errors in the .aux file. Identify the root cause (likely corrupted auxiliary files from interrupted builds) and document solutions to avoid these errors.

---

### 431. WezTerm tab color notification for Claude Code input needed
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Research Report**: [research-001.md](498_verify_bridge_lemma_infrastructure/reports/research-001.md)
- **Language**: general
- **Research**: [research-001.md](specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

## Low Priority

### 598. Remove deprecated helpers from ContextProvability.lean
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-19

**Description**: Remove deprecated helper functions from ContextProvability.lean: `semantic_world_validity_implies_provable` (deprecated 2026-01-18) and `semantic_consequence_implies_semantic_world_truth` (deprecated 2026-01-18). These are marked `@[deprecated]` but can be deleted once confirmed unused.

---

### 470. Finite model computational optimization
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458

**Description**: Optimize FiniteCanonicalModel.lean for computational efficiency. Current implementation prioritizes correctness over performance. Identify and implement optimizations for the finite world state enumeration, task relation checking, and truth evaluation.

---

### 490. Complete decidability procedure
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 469

**Description**: Complete the decidability procedure for TM logic. The existing Decidability module has tableau infrastructure but needs: proof extraction from closed tableaux, completeness proof connecting to FMP, and full decide function verification. Extends Task 469.

---
