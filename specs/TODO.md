---
next_project_number: 876
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-11T22:21:25Z
task_counts:
  active: 9
  completed: 408
  in_progress: 1
  not_started: 7
  abandoned: 29
  total: 440
technical_debt:
  sorry_count: 146
  axiom_count: 20
  build_errors: 1
  status: manageable
---

# TODO

## Tasks

### 875. Create lean-specific teammate prompts
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: meta
- **Created**: 2026-02-11
- **Dependencies**: Task #872 (routing must exist before prompts can be used)

**Description**: Create lean-specific teammate prompt templates that instruct teammates to use lean-lsp MCP tools (leansearch, loogle, leanfinder, lean_goal, etc.) and follow proof-checking workflows. Store in .claude/context/core/templates/.

**Rationale**: Once task #872 implements language-aware routing, lean teammates need specialized prompts that include MCP tool access instructions and Lean 4 proof patterns. Generic teammate prompts lack lean-lsp context and result in attempts to implement Lean code without proper tooling.

---

### 874. Document --team flag in command files
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Language**: meta
- **Created**: 2026-02-11

**Description**: Add --team and --team-size documentation to /research, /plan, and /implement command files. Currently the orchestrator handles these flags but the commands do not document them.

---

### 873. Create teammate configuration system with model selection
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: meta
- **Created**: 2026-02-11

**Description**: Design and implement a teammate configuration mechanism that allows specifying model (e.g., Opus 4.6 for lean specialists, Sonnet 4.5 for general). Investigate TeammateTool model parameter usage.

**Current State**: Commands have `model` frontmatter in COMMAND.md files, but agents and skills do not. No mechanism exists to propagate model selection to spawned teammates. For Lean tasks requiring deep reasoning (Zorn's lemma, proof tactics), Opus 4.6 is needed, while general meta tasks can use faster/cheaper Sonnet 4.5.

---

### 872. Add language-aware teammate routing to team skills
- **Effort**: 3-4 hours
- **Status**: [PLANNED]
- **Language**: meta
- **Created**: 2026-02-11
- **Researched**: 2026-02-11
- **Planned**: 2026-02-11
- **Research**: [research-001.md](specs/872_language_aware_teammate_routing_team_skills/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/872_language_aware_teammate_routing_team_skills/plans/implementation-001.md)
- **Evidence**: [/implement --team 870 failure](.claude/output/implement.md) (lines 1740-1770)

**Description**: Modify skill-team-research, skill-team-plan, and skill-team-implement to check task language and spawn language-appropriate teammates. For lean tasks, teammates should use lean-research-agent/lean-implementation-agent patterns with access to lean-lsp MCP tools.

**Observed Failure**: During `/implement --team 870`, skill-team-implement attempted to implement Lean code directly using MCP tools (lean-lsp hover, loogle) instead of spawning lean-implementation-agent teammates. User had to interrupt and revert changes. The skill acknowledged it should have spawned specialized Lean agents but bypassed language routing entirely.

---

### 871. Implement safer git staging to prevent concurrent agent race conditions
- **Effort**: 6 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-11
- **Researched**: 2026-02-11
- **Planned**: 2026-02-11
- **Started**: 2026-02-11
- **Completed**: 2026-02-11
- **Research**: [research-001.md](specs/871_safer_git_staging_concurrent_agents/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/871_safer_git_staging_concurrent_agents/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260211.md](specs/871_safer_git_staging_concurrent_agents/summaries/implementation-summary-20260211.md)

**Description**: Address the race condition where concurrent agents using `git add -A` or `git add specs/` can accidentally overwrite files modified by other processes. Demonstrated by task 865 research agent (session sess_1770848379_6843ee) wiping TODO.md to empty while task 869 archival was completing.

**Root Cause**: Background agents stage all modified files in specs/ directory regardless of which files they actually created or modified. When multiple agents run concurrently, later commits can overwrite earlier changes.

**Proposed Solutions**:

1. **Targeted Git Staging** (Required):
   - Replace `git add -A` and `git add specs/` with explicit file staging
   - Agents should only stage files in their task directory: `specs/{N}_{SLUG}/`
   - Shared files (TODO.md, state.json, ROAD_MAP.md) require special handling

2. **Pre-Commit Validation** (Required):
   - Before commit, check `git diff --cached --name-only`
   - Verify staged files match expected scope for the operation
   - Abort if unexpected files are staged (e.g., other task directories, TODO.md during research)

3. **Staging Scope Rules** (Required):
   - Research agents: Stage only `specs/{N}_{SLUG}/reports/` + state.json + TODO.md
   - Plan agents: Stage only `specs/{N}_{SLUG}/plans/` + state.json + TODO.md
   - Implement agents: Stage modified source files + `specs/{N}_{SLUG}/summaries/` + state.json + TODO.md + plan file
   - Todo command: Stage entire `specs/` directory (by design, runs exclusively)

4. **File Locking Pattern** (Optional):
   - Create `.editing-{file}.lock` files to signal active edits
   - Check for locks before modifying shared files
   - Clean up stale locks (>1 hour old)

**Implementation Areas**:
- Update git commit patterns in skill postflight sections
- Add pre-commit validation helper in `.claude/utils/git-safety.md`
- Document staging scope rules in `.claude/rules/git-workflow.md`
- Add lock file protocol to `.claude/context/core/patterns/file-locking.md` (optional)

**Success Criteria**:
- No agent stages files outside its authorized scope
- Concurrent agents can run without file conflicts
- Clear error messages when staging validation fails

### 870. Zorn-based family selection for temporal coherence
- **Effort**: TBD
- **Status**: [PLANNED]
- **Language**: lean
- **Created**: 2026-02-11

**Description**: Use Zorn's lemma to construct IndexedMCSFamily with guaranteed cross-sign temporal coherence (forward_G, backward_H). This bypasses task 864's chain construction limitations where G phi at time t<0 cannot reach time t'>0 because chains extend away from time 0. Key approach: Define partial order on candidate families satisfying coherence properties, apply Zorn to obtain maximal element. See task 864 session 28-30 analysis for cross-sign challenge details, TemporalLindenbaum.lean for single-MCS Zorn infrastructure, DovetailingChain.lean:606,617 for blocked cross-sign cases. Critical: Ensure termination of Zorn argument, prove maximal family is actually an IndexedMCSFamily, handle witness enumeration for F/P formulas. Success eliminates DovetailingChain sorries at lines 606,617,633,640.

### 868. Reinstate lean-lsp MCP tools after GitHub issue resolution
- **Effort**: 1 hour
- **Status**: [BLOCKED]
- **Language**: meta
- **Created**: 2026-02-11
- **Blocked on**: lean-lsp-mcp issue #115 resolution

**Description**: Once lean-lsp-mcp issue #115 (server halts on lean_diagnostic_messages) is resolved, reinstate the blocked MCP tools. Follow the unblocking procedure: verify fix in repository, update package version, test tools manually, update blocked-mcp-tools.md to mark as UNBLOCKED, remove from CLAUDE.md blocked list, and restore documentation in mcp-tools-guide.md. Consider re-testing lean_file_outline as well since no specific open issue exists for it.

### 865. Construct canonical task frame for Bimodal completeness
- **Effort**: TBD
- **Status**: [RESEARCHING]
- **Language**: lean
- **Created**: 2026-02-05
- **Researched**: 2026-02-10
- **Research**: [research-001.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-001.md), [research-002.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-002.md), [research-003.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-003.md), [research-004.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-004.md), [research-005.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-005.md)

**Description**: Research and construct a canonical task frame (world-states, task relation, durations) for the Bimodal logic representation theorem. Define a two-place task relation w ⇒ u where: (1) φ ∈ u whenever □G φ ∈ w; (2) φ ∈ w whenever □H φ ∈ u; with witness conditions (GW) and (HW). World histories are functions τ from a totally ordered commutative group of durations to MCSs respecting the task relation. Key challenges: constructing durations from syntax, building a proper three-place task relation matching the semantics, and possibly using the two-place task relation to construct a topology (closeness via possible nearness in time) with durations abstracted as equivalence classes. The construction should culminate in a seed built from a consistent sentence of arbitrary complexity, with the canonical model satisfying the TruthLemma as the guiding North Star.

### 864. Implement recursive seed construction for Henkin model completeness
- **Effort**: 36 hours
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-05
- **Researched**: 2026-02-10
- **Planned**: 2026-02-10
- **Research**: [research-001.md](specs/864_recursive_seed_henkin_model/reports/research-001.md), [research-002.md](specs/864_recursive_seed_henkin_model/reports/research-002.md)
- **Plan**: [implementation-002.md](specs/864_recursive_seed_henkin_model/plans/implementation-002.md) (v2), [implementation-001.md](specs/864_recursive_seed_henkin_model/plans/implementation-001.md) (v1)

**Description**: Improving on task 843 and the various attempts tried there, develop a new strategy which proceeds by taking a consistent formula and using its recursive structure to define a seed which consists of a bundle of indexed families of MCSs. The idea is to start with a singleton CS indexed at 0 for the consistent sentence we start with. If the main operator is a Box, then every CS must include its argument. If the main operator is a negated Box, then some indexed family must have a CS indexed by the present time that includes the negation of its argument. If the main operator is H, then every CS indexed by a present and past time in the family must include the argument. If the main operator is a negated H, then some CS indexed by the present or past time in the family must include the negation of the argument. Similarly for G, but for the future. Negated modal operators require new indexed families to be created, and negated tense operators require new CSs at new indexes to be created. Boolean operators unpack in the usual way. This returns some indexed families with some CSs based on the logical form of the initial sentence. This is then completed to provide an appropriate Henkin model.

### 843. Remove singleFamily_modal_backward_axiom after Zorn lemma is proven
- **Effort**: 50-65 hours (revised v008)
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-03
- **Updated**: 2026-02-10
- **Researched**: 2026-02-05
- **Planned**: 2026-02-10
- **Depends**: Task 856
- **Related**: Task 856, Task 857
- **Research**: [research-001.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-001.md) through [research-017.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-017.md)
- **Plan**: [implementation-008.md](specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-008.md)

**Description**: Make Bimodal/Metalogic/ axiom-free and sorry-free for publication-ready completeness. Eliminate 2 completeness-chain axioms (singleFamily_modal_backward_axiom, temporally_saturated_mcs_exists) via temporal Lindenbaum construction and multi-family saturated BMCS. Delete 4 legacy eval_bmcs_truth_lemma sorries.

---

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [RESEARCHED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [IMPLEMENTING]
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean
 **Created**: 2026-01-26
 **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
 **Research**: [research-001.md](specs/685_derive_world_history_and_barcan_theorems/reports/research-001.md)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---


