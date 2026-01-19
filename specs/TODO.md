---
next_project_number: 608
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 11
  completed: 197
  in_progress: 1
  not_started: 6
  abandoned: 18
  total: 220
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

## Medium Priority

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
- **Language**: general
- **Research**: [research-001.md](specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

### 605. Sync Plan Metadata Status with Task Status
- **Effort**: 2-3 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Started**: 2026-01-19
- **Research**: [research-001.md](specs/605_sync_plan_metadata_status_with_task_status/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/605_sync_plan_metadata_status_with_task_status/plans/implementation-002.md) (supersedes v1)

**Description**: Sync the **Status**: field in plan file metadata with the task status in TODO.md and state.json. Currently, implementation plans have a Status field in their YAML-like header (e.g., **Status**: [NOT STARTED]) that is not updated when the task progresses through research/plan/implement cycles. Update the preflight/postflight patterns in implementation skills to also update this status field in the plan file when task status changes.

---

## Low Priority

### 470. Finite model computational optimization
- **Status**: [IMPLEMENTING]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458
- **Research**: [research-001.md](specs/470_finite_model_computational_optimization/reports/research-001.md), [research-002.md](specs/470_finite_model_computational_optimization/reports/research-002.md)

**Description**: Optimize FiniteCanonicalModel.lean for computational efficiency. Current implementation prioritizes correctness over performance. Identify and implement optimizations for the finite world state enumeration, task relation checking, and truth evaluation.

---

### 490. Complete decidability procedure
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 469

**Description**: Complete the decidability procedure for TM logic. The existing Decidability module has tableau infrastructure but needs: proof extraction from closed tableaux, completeness proof connecting to FMP, and full decide function verification. Extends Task 469.

---

### 606. Fix Metalogic_v2 README accuracy
- **Effort**: 30 minutes
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Source**: Code Review 2026-01-18 (H2)
- **Research**: [research-001.md](specs/606_fix_metalogic_v2_readme_accuracy/reports/research-001.md)

**Description**: Update Metalogic_v2/README.md to accurately document the sorry count and locations. Current README incorrectly claims "All theorems in Metalogic_v2 are fully proven with no sorry statements" but there are 7 active sorries in the semantic bridge infrastructure. Document which theorems have sorries, their locations, and impact on downstream theorems.

---

### 607. Port Decidability to Metalogic_v2
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Source**: Code Review 2026-01-18 (M1)
- **Dependencies**: Task 470

**Description**: Port the Decidability/ infrastructure from old Metalogic/ to Metalogic_v2/ architecture. The old Decidability/ has 8 files (Tableau, SignedFormula, Saturation, DecisionProcedure, ProofExtraction, CountermodelExtraction, Correctness, Closure) totaling 61KB. Integrate with FMP as the bridge theorem following the representation-first architecture.

---
