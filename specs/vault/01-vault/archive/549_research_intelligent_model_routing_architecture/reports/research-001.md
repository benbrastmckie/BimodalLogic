# Research Report: Task #549

**Task**: 549 - research_intelligent_model_routing_architecture
**Started**: 2026-01-17T19:53:30Z
**Completed**: 2026-01-17T20:15:00Z
**Effort**: 2-3 hours
**Priority**: high
**Dependencies**: 548 (skill-to-agent delegation pattern)
**Sources/Inputs**: Codebase analysis, WebSearch (Anthropic docs, RouteLLM, industry research)
**Artifacts**: specs/549_research_intelligent_model_routing_architecture/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Three viable approaches exist for intelligent model routing: (1) rule-based task-type routing, (2) lightweight complexity classifiers, and (3) model cascades with deferral
- The existing `.claude/` architecture already has strong foundations for routing via language-based skill selection - model routing can extend this pattern
- Recommended approach: **Hybrid strategy** combining rule-based routing (cheapest, most predictable) with optional cascade escalation for ambiguous cases
- Cost savings of 36-85% are achievable while maintaining 90-95% quality parity with frontier models

## Context & Scope

### Research Questions

1. **Query complexity analyzers** - How to classify task complexity for model selection?
2. **Task-type based routing** - Matching task types to optimal models
3. **Model cascade patterns** - Escalation strategies from cheaper to more capable models
4. **Integration with .claude/ architecture** - Practical implementation approaches

### Constraints

- Must integrate with existing skill/agent forked subagent pattern
- Should not significantly increase routing latency
- Must be maintainable without ML training infrastructure
- Claude Code context: Opus 4.5, Sonnet 4, Haiku 3.5 as model tiers

## Findings

### 1. Industry Approaches to Model Routing

#### 1.1 Rule-Based Task-Type Routing (Simplest)

From Anthropic's documentation and Claude Code practices:

| Task Type | Recommended Model | Rationale |
|-----------|------------------|-----------|
| Simple questions, quick queries | Haiku 3.5 | Fast, cheap, sufficient for low complexity |
| Standard coding, feature development | Sonnet 4 | Balanced performance/cost for everyday work |
| Complex architecture, multi-file refactoring | Opus 4.5 | Maximum reasoning for complex trade-offs |
| Code reviews with judgment | Opus 4.5 | Requires architectural understanding |
| Documentation, formatting | Haiku 3.5 | Low complexity, high volume |
| Security/compliance code | Sonnet 4 (minimum) | Requires careful attention |

**Implementation heuristic from practitioners**: "If you spend more than 5 seconds thinking about which model to use: For complex design/research: Use opus. For everything else: Use sonnet."

**Claude Code's current approach**: Tactical model selection already happens behind the scenes - Haiku 3.5 is used for "routine grunt work" internally, while Opus is used for planning mode's complex reasoning.

#### 1.2 Lightweight Classifier-Based Routing (Medium Complexity)

**RouteLLM Framework** (LM-Sys/Berkeley) demonstrates several trained router approaches:

| Router Type | Description | Overhead |
|-------------|-------------|----------|
| Matrix Factorization (mf) | Learns scoring function for prompt/model fit | Low inference cost |
| BERT Classifier | Trained on preference data for binary model choice | ~100ms per query |
| Semantic Weighted (sw_ranking) | Weighted Elo based on prompt similarity | Moderate cost |
| Causal LLM | LLM-based classifier tuned on preference data | Higher cost |

**Scoring criteria from Anyscale/RouteLLM**:
- "Predict the score an expert evaluator would give to an AI assistant's response"
- Consider: helpfulness, relevance, adherence to facts, depth, creativity, detail
- "Infer the level of proficiency needed to address the question effectively"
- Scale 1-5, higher score = route to stronger model

**LLMRank feature-based approach**:
- Task type indicators (reasoning, completion, multiple choice, narrative)
- Knowledge requirements (world knowledge, temporal reasoning, context understanding)
- Output format expectations
- Scenario complexity (ambiguity, contextual difficulty)
- Prompt length (normalized)
- Language type

**Performance**: Trained routers can reduce costs by up to 85% while maintaining 95% GPT-4 performance.

#### 1.3 Model Cascades (Most Sophisticated)

Cascades differ from routers: routers decide *before* inference based on input, cascades decide *after* seeing an initial response.

**How cascades work**:
1. Cheap/fast model attempts the task first
2. Apply decision criterion (confidence, consistency, agreement)
3. If criterion fails, escalate to more powerful model
4. Return final response

**Key patterns**:

| Pattern | Decision Criterion | Cost Impact |
|---------|-------------------|-------------|
| FrugalGPT | BERT meta-model predicts response quality | High reduction |
| Mixture-of-Thoughts | Sample multiple reasoning chains, halt when they converge | Moderate reduction |
| C3PO | Compare weak vs strong model outputs for self-supervised thresholding | Variable |
| Speculative Cascades (Google) | Deferral rule based on model confidence | 36% cost reduction at 90% accuracy |

**Cost savings**: Task cascades reduce end-to-end cost by average 36% compared to model cascades at production scale.

### 2. Codebase Analysis - Existing Routing Patterns

The `.claude/` architecture already has sophisticated routing infrastructure:

#### 2.1 Language-Based Routing (Current)

From `.claude/context/core/routing.md`:

```
| Language | Research Skill | Implementation Skill |
|----------|---------------|---------------------|
| lean | skill-lean-research | skill-lean-implementation |
| latex | skill-researcher | skill-latex-implementation |
| general | skill-researcher | skill-implementer |
| meta | skill-researcher | skill-implementer |
| markdown | skill-researcher | skill-implementer |
```

This maps task *type* (by language) to *skill*, but not task *complexity* to *model*.

#### 2.2 Status-Based Routing (Current)

From `.claude/skills/skill-orchestrator/SKILL.md`:

```
| Operation | Allowed Statuses |
|-----------|------------------|
| research | not_started, planned, partial, blocked |
| plan | not_started, researched, partial |
| implement | planned, implementing, partial, researched |
```

Status transitions validate operation eligibility.

#### 2.3 Task Complexity Assessment (Current - Planning Phase)

From `.claude/context/core/workflows/task-breakdown.md`:

```
| Complexity | Criteria | Phase Count |
|------------|----------|-------------|
| Simple | <60 min, 1-2 files, no dependencies | 1-2 phases |
| Medium | 1-4 hours, 3-5 files, some dependencies | 2-4 phases |
| Complex | >4 hours, 6+ files, many dependencies | 4-6 phases |
```

This exists for *planning*, but could be adapted for *model selection*.

#### 2.4 Delegation Infrastructure (Current)

From `.claude/ARCHITECTURE.md`:
- Session ID tracking: `sess_{timestamp}_{random}`
- Depth limits: Maximum 3 levels
- Timeout configuration by operation type
- Return validation via subagent-return.md schema

### 3. Integration Approaches for .claude/ Architecture

#### 3.1 Approach A: Static Rule-Based Routing (Recommended for Phase 1)

**Design**:
- Extend skill/agent frontmatter with `model_preference` field
- Route by (language, operation, complexity_hint) tuple
- Use existing task metadata (effort, file_count, dependencies) as complexity signals

**Routing table**:

```yaml
# In skill frontmatter
model_routing:
  default: sonnet-4
  complexity_overrides:
    simple:    # <60min, 1-2 files
      model: haiku-3.5
      operations: [status_sync, file_format, simple_query]
    standard:  # 1-4 hours, typical work
      model: sonnet-4
      operations: [research, plan, implement]
    complex:   # >4 hours, architecture decisions
      model: opus-4.5
      operations: [architect, review, complex_research]
```

**Complexity detection heuristics** (no ML required):

| Signal | Simple | Standard | Complex |
|--------|--------|----------|---------|
| Effort field | <60 min | 1-4 hours | >4 hours |
| Files touched | 1-2 | 3-5 | 6+ |
| Dependencies | 0 | 1-3 | 4+ |
| Task keywords | "format", "rename", "update" | "implement", "add", "fix" | "architect", "redesign", "refactor" |
| Lean proofs | Simple lemma | Medium theorem | Complex dependent types |

**Pros**: Simple, predictable, no training required, deterministic costs
**Cons**: May misclassify edge cases, requires manual tuning

#### 3.2 Approach B: Lightweight Classifier Routing (Phase 2)

**Design**:
- Add routing classifier skill/agent
- Use prompt features to score complexity (0-1)
- Route based on threshold

**Feature extraction** (inspired by LLMRank):

```python
def extract_routing_features(task_context):
    return {
        # Structural features
        "prompt_length": len(task_context.description),
        "file_count": len(task_context.files_to_modify),
        "dependency_count": len(task_context.dependencies),

        # Semantic features (keyword-based)
        "requires_reasoning": contains_reasoning_keywords(task_context),
        "requires_creativity": contains_creative_keywords(task_context),
        "domain_specificity": domain_specificity_score(task_context.language),

        # Historical features
        "similar_task_model": lookup_similar_past_tasks(task_context),
        "avg_model_for_operation": historical_model_usage(task_context.operation),
    }
```

**Classifier options** (no GPU required):
1. **Logistic regression on features**: Simple, interpretable
2. **Decision tree on features**: Explainable rules
3. **LLM self-assessment**: Ask Haiku to rate complexity (cheap meta-call)

**Pros**: Adaptive, can learn from data, handles edge cases better
**Cons**: Requires feature engineering, needs training/calibration data

#### 3.3 Approach C: Cascade with Deferral (Phase 3)

**Design**:
- Start with Haiku for all tasks
- Add self-assessment step to detect uncertainty
- Escalate to Sonnet/Opus when:
  - Haiku expresses low confidence
  - Response fails validation
  - Detected "I'm not sure" patterns

**Implementation**:

```
1. Task → Haiku attempt
2. Haiku returns with confidence signal
3. If confidence < threshold OR validation fails:
   - Escalate to Sonnet
4. If Sonnet expresses uncertainty for architectural decision:
   - Escalate to Opus
5. Return final result
```

**Confidence signals**:
- Explicit: "I'm uncertain about..."
- Implicit: Response length anomalies, missing required sections
- Structural: Validation failures, incomplete artifacts

**Pros**: Most cost-efficient at scale, adapts to actual task difficulty
**Cons**: Higher latency (multiple model calls), more complex orchestration

### 4. Recommendations

#### 4.1 Recommended Implementation Strategy

**Phase 1: Static Rule-Based Routing** (Immediate)
- Extend orchestrator with model selection based on task metadata
- Use existing complexity signals (effort, files, dependencies)
- Predictable costs, easy to debug

**Phase 2: LLM Self-Assessment** (Short-term)
- Add cheap Haiku call to assess complexity before main model
- ~$0.001 per routing decision
- Improves edge case handling

**Phase 3: Cascade with Deferral** (Long-term)
- Implement for high-volume operations (research, simple fixes)
- Monitor quality metrics to tune thresholds

#### 4.2 Architecture Integration Points

1. **Skill frontmatter**: Add `model_preference` field
2. **Orchestrator routing.md**: Add model selection logic after language routing
3. **Delegation context**: Include `selected_model` in metadata
4. **Subagent return**: Track `model_used` in metadata for analytics
5. **New skill**: `skill-model-router` for complex routing decisions

#### 4.3 Complexity Scoring for .claude/ Tasks

Proposed scoring function:

```
complexity_score =
    0.3 * effort_factor +           # <1h=0, 1-4h=0.5, >4h=1
    0.2 * file_count_factor +       # 1-2=0, 3-5=0.5, 6+=1
    0.2 * dependency_factor +       # 0=0, 1-3=0.5, 4+=1
    0.2 * language_factor +         # meta/markdown=0, general=0.5, lean=1
    0.1 * operation_factor          # status_sync=0, implement=0.5, research=0.7

Model selection:
    score < 0.3  → Haiku 3.5
    score < 0.7  → Sonnet 4
    score >= 0.7 → Opus 4.5
```

## Decisions

1. **Recommended Phase 1 approach**: Static rule-based routing using existing task metadata
2. **Primary routing dimensions**: (operation_type, language, effort_estimate)
3. **Default model**: Sonnet 4 (safest balance of cost/capability)
4. **Escalation trigger**: Task explicitly marked as "research" type or >4 hours effort
5. **Deferral model for Phase 3**: Start with Haiku, use confidence-based escalation

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Misclassification causes quality issues | Medium | High | Start conservative (default to Sonnet), add override mechanism |
| Routing overhead negates cost savings | Low | Medium | Use simple rules first, minimize classifier latency |
| Model availability differences | Low | Medium | Graceful fallback to higher-tier model if preferred unavailable |
| User confusion about model selection | Medium | Low | Transparent logging, document routing logic |
| Cascade latency for time-sensitive tasks | Medium | Medium | Skip cascade for operations with explicit urgency flag |

## Appendix

### Search Queries Used

1. "Claude model routing complexity analysis task classification agent architecture 2026"
2. "LLM model cascade escalation pattern cheaper models to capable models 2026"
3. "AI agent query complexity analyzer task routing implementation 2025 2026"
4. "model router implementation LLM task complexity scoring criteria lightweight classifier"
5. "Claude Code model selection task complexity heuristics simple rules based routing"

### Key References

**Anthropic Resources**:
- [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents) - Routing patterns, task complexity
- [Choosing the Right Model](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model) - Model tier recommendations

**Framework Documentation**:
- [RouteLLM (LM-Sys)](https://github.com/lm-sys/RouteLLM) - Open-source routing framework
- [NVIDIA LLM Router Blueprint](https://build.nvidia.com/nvidia/llm-router) - Enterprise routing patterns
- [vLLM Semantic Router](https://www.redhat.com/en/blog/bringing-intelligent-efficient-routing-open-source-ai-vllm-semantic-router) - Semantic-based routing

**Research Papers**:
- [C3PO: Optimized Large Language Model Cascades](https://arxiv.org/html/2511.07396) - Cascade optimization
- [A Unified Approach to Routing and Cascading](https://arxiv.org/html/2410.10347v1) - Theory unification
- [Speculative Cascades (Google Research)](https://research.google/blog/speculative-cascades-a-hybrid-approach-for-smarter-faster-llm-inference/) - Hybrid approach

**Practitioner Guides**:
- [Claude Code Model Selection (eesel.ai)](https://www.eesel.ai/blog/claude-code-model-selection) - Practical heuristics
- [Ultimate Guide to AI Agent Routing (Botpress)](https://botpress.com/blog/ai-agent-routing) - Agent routing patterns
- [Claude Code Feature Request #16620](https://github.com/anthropics/claude-code/issues/16620) - Auto model selection discussion

### Related Codebase Files

- `.claude/context/core/routing.md` - Current language routing logic
- `.claude/skills/skill-orchestrator/SKILL.md` - Orchestrator routing implementation
- `.claude/context/core/workflows/task-breakdown.md` - Complexity assessment guidelines
- `.claude/context/core/formats/subagent-return.md` - Return format with metadata
- `.claude/ARCHITECTURE.md` - Overall system architecture

## Next Steps

1. Run /plan 549 to create implementation plan for model routing
2. Prioritize Phase 1 (static rule-based routing) for immediate value
3. Consider creating task 550 for Phase 2 (classifier-based routing) if Phase 1 succeeds
