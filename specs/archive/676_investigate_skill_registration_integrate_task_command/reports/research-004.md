# Research Report: Task #676 - Checkpoint Placement Strategy Analysis

- **Task**: 676 - Investigate skill registration and integrate /task command with checkpoint pattern
- **Started**: 2026-01-25T18:42:36Z
- **Completed**: 2026-01-25T19:15:22Z
- **Effort**: 33 minutes
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - Web research on CLI architecture patterns
  - Web research on orchestration layer responsibilities
  - Web research on API Gateway patterns
  - Web research on cross-cutting concerns
  - Codebase analysis of current command/skill split
  - research-003.md (root cause analysis)
  - implementation-003.md (current plan)
- **Artifacts**: reports/research-004.md (this file)
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Current plan v3 (Option C)** proposes moving checkpoints to commands based on GitHub Issue #17351
- **Industry patterns strongly support command-level checkpoints** as the API Gateway/orchestration pattern
- **Commands are the natural transaction boundary** for state management in this architecture
- **Skills should remain thin delegators** without state management concerns
- **Plan v3 approach aligns with CQRS, Gateway Pattern, and cross-cutting concerns best practices**
- **Recommendation: PROCEED with Option C** - checkpoints belong in commands, not skills

## Context & Scope

This research evaluates where checkpoint operations (preflight/postflight) should be placed in the three-layer architecture:

```
Commands (.claude/commands/*.md)
    |
    v
Skills (.claude/skills/*/SKILL.md)
    |
    v
Agents (.claude/agents/*.md)
```

**Key Question**: Should preflight/postflight (status updates, git commits, artifact linking) happen in commands or skills?

**User Concern**: "I am not convinced that running preflight/postflight in commands as opposed to skills is the best solution."

## Findings

### 1. Current Architecture Analysis (Codebase)

**Commands (research.md) - Currently handle ALL checkpoints**:
- Lines 36-128: CHECKPOINT 1 (GATE IN) - validation, status update
- Lines 131-159: STAGE 2 (DELEGATE) - invoke skill
- Lines 162-226: CHECKPOINT 2 (GATE OUT) - validate results, update status
- Lines 229-253: CHECKPOINT 3 (COMMIT) - git commit

**Skills (skill-researcher/SKILL.md) - Currently attempt postflight**:
- Lines 68-83: Stage 2 preflight status update
- Lines 86-100: Stage 3 postflight marker creation
- Problem: Lines never execute due to Issue #17351 (subagent returns to main session)

**Key Observation**: Commands ALREADY implement full checkpoint pattern. Skills ATTEMPT to duplicate it but fail due to Claude Code limitation.

### 2. API Gateway Pattern (Industry Standard)

[Source: Microservices Pattern: API Gateway](https://microservices.io/patterns/apigateway.html), [Microsoft Learn: API gateways](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/gateway)

**Gateway Responsibilities** (maps to Commands):
1. **Routing** - Direct requests to appropriate services (skills/agents)
2. **Request Validation** - Verify preconditions before delegation
3. **Aggregation & Orchestration** - Call multiple services, aggregate results
4. **Security & Cross-Cutting Concerns** - Authentication, rate limiting, transaction management

**Anti-Pattern Warning**: "Usually it isn't a good idea to have a single API Gateway aggregating all the internal microservices of your application, as it acts as a monolithic aggregator or orchestrator and violates microservice autonomy."

**Application to This Architecture**:
- Commands = API Gateway layer
- Skills = Service routing layer
- Agents = Business logic/execution layer

**Checkpoint operations are cross-cutting concerns** that belong at the gateway level, not in services.

### 3. Cross-Cutting Concerns Placement

[Source: Cross-Cutting Concerns in Distributed System](https://www.geeksforgeeks.org/system-design/cross-cutting-concerns-in-distributed-system/), [Microsoft Learn: Crosscutting Concerns](https://learn.microsoft.com/en-us/previous-versions/msp-n-p/ee658105(v=pandp.10))

**Definition**: "Cross-cutting concerns are aspects of a program that affect several modules, without the possibility of being encapsulated in any of them."

**Examples**: Logging, transaction processing, privilege checking, persistence, monitoring

**State Management as Cross-Cutting Concern**:
- State updates (TODO.md, state.json) affect all workflow operations
- Git commits affect all completed operations
- Artifact linking affects all artifact-producing operations

**Best Practice**: Centralize cross-cutting concerns at the **orchestration layer** (commands), not in individual services (skills).

### 4. Transaction Boundaries

[Source: Mastering Transaction Boundaries](https://karinavarela.me/2020/06/28/mastering-transaction-boundaries/), [Transaction Boundaries: The Foundation of Reliable Systems](https://weblog.plexobject.com/archives/7001)

**Key Principle**: Transaction boundaries should be placed at the **coordination layer** that owns the state.

**In This Architecture**:
- Commands own the session lifecycle (generate session_id)
- Commands own the task state (read/write state.json)
- Commands own the git history (create commits)

**Why Commands Are the Natural Transaction Boundary**:
1. Commands initiate the workflow
2. Commands track the session_id
3. Commands are responsible for the complete operation
4. Commands can guarantee atomicity (all-or-nothing state updates)

**Why Skills Are NOT Transaction Boundaries**:
1. Skills don't own state (delegates to agents)
2. Skills don't persist results (agents write files)
3. Skills can't guarantee execution (Issue #17351 breaks postflight)

### 5. Command Pattern & Single Responsibility

[Source: Command Pattern](http://codebetter.com/iancooper/2011/04/27/why-use-the-command-processor-pattern-in-the-service-layer/), [Single Responsibility Principle](https://medium.com/@anderson.buenogod/understanding-the-single-responsibility-principle-srp-and-how-to-apply-it-in-c-net-projects-42d2c757d163)

**Command Pattern Benefits**:
- "Handlers split from the command processor have fewer dependencies than a service"
- "Operation script style domain service classes force consumers to depend on methods they don't use"
- Commands encapsulate operations with clear boundaries

**Responsibility Assignment**:

| Layer | Responsibility | Reason |
|-------|----------------|--------|
| Commands | Orchestration, validation, state management | Transaction boundary, owns session |
| Skills | Routing, agent selection, delegation | Service discovery and invocation |
| Agents | Business logic, artifact creation | Domain expertise, work execution |

**SRP Violation if Skills Handle Checkpoints**:
- Skills would have TWO responsibilities: routing AND state management
- Skills would violate "focus on updating a small part of the domain model"
- Skills would couple orchestration logic with delegation logic

### 6. CQRS Pattern (Command Query Responsibility Segregation)

[Source: CQRS Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs), [Microservices Pattern: CQRS](https://microservices.io/patterns/data/cqrs.html)

**Key Insight**: "Separating the read and write responsibilities results in cleaner, more maintainable models."

**Application to Checkpoint Placement**:

**Commands (Write Path)**:
- Update state (state.json, TODO.md)
- Create artifacts via delegation
- Commit to git
- Own the write transaction

**Skills (Query/Delegation Path)**:
- Query for appropriate agent
- Delegate work
- Return results
- No state modification

**Why This Separation Matters**:
- Commands can optimize for consistency (transaction guarantees)
- Skills can optimize for delegation (parallelism, specialization)
- Agents can optimize for execution (domain expertise)

### 7. Workflow Orchestration Best Practices

[Source: Workflow Orchestration: Key Facts and 5 Best Practices](https://appian.com/blog/acp/process-automation/workflow-orchestration-explained), [CircleCI: Workflow orchestration](https://circleci.com/docs/workflows/)

**Preflight/Postflight Pattern in Workflow Systems**:
- "Using a 'setup' job at the start of a workflow can be helpful to do some preflight checks"
- "lakeFS leverages pre-merge or post-commit hooks to enforce checks"
- Setup and teardown operations belong at the **workflow level**, not the task level

**State Machine Pattern**:
- "State machines let you codify the 'happy path' and all the alternate paths (errors, retries, timeouts) in one place"
- "Decoupling: The orchestration (state machine) is separated from the implementation of each task"

**In This Architecture**:
- Commands = Workflow orchestrator (state machine)
- Skills = Task selector/delegator
- Agents = Task implementation

**Recommendation**: "The orchestration (state machine) is separated from the implementation of each task, allowing you to modify the high-level workflow without rewriting the services performing the tasks."

### 8. AWS CLI Agent Orchestrator Pattern (Recent Industry Example)

[Source: AWS CLI Agent Orchestrator](https://aws.amazon.com/blogs/opensource/introducing-cli-agent-orchestrator-transforming-developer-cli-tools-into-a-multi-agent-powerhouse/)

**Three-Layer Architecture**:
1. **Supervisor Agent** - Coordinates workflow, decides when/which skills to apply
2. **Agent Skills** - Encapsulate specific, reusable capabilities
3. **Worker Agents** - Execute specialized tasks

**Key Design Decision**:
- Supervisor (command-level) handles orchestration
- Skills provide capabilities but don't manage state
- Workers execute tasks

**Parallel to This Project**:
- Commands = Supervisor agent
- Skills = Agent skills routing layer
- Agents = Worker agents

### 9. Root Cause: GitHub Issue #17351

**Technical Constraint**: When skills invoke subagents, control returns to main session, NOT the skill.

**Implication**: Any postflight code in the skill NEVER executes.

**Three Solutions**:
- **Option A (Workaround)**: Hook-based postflight (current, unreliable)
- **Option B (Limitation)**: No subagents (defeats architecture)
- **Option C (Structural)**: Move checkpoints to commands (aligns with best practices)

**Key Insight**: Issue #17351 isn't just a bug to work around - it's revealing that **checkpoints were in the wrong layer**.

## Decisions

1. **Checkpoints belong in commands** - This aligns with API Gateway, cross-cutting concerns, and transaction boundary patterns
2. **Skills should remain thin delegators** - Single responsibility: route to appropriate agent
3. **Option C is the correct architectural solution** - Not a workaround, but proper layer separation
4. **Current commands already implement checkpoints correctly** - research.md lines 36-253 show complete pattern
5. **Skills attempting postflight is architectural violation** - Duplicates command responsibility, breaks SRP

## Recommendations

### 1. PROCEED with Plan v3 Option C

**Rationale**:
- Aligns with API Gateway pattern (commands = gateway)
- Respects transaction boundaries (commands own state)
- Follows cross-cutting concerns placement (orchestration layer)
- Implements CQRS pattern (commands = write, skills = delegate)
- Matches industry orchestration patterns (setup/teardown at workflow level)

### 2. Strengthen Architectural Documentation

Document the three-layer responsibility model:

| Layer | Responsibilities | NOT Responsible For |
|-------|------------------|---------------------|
| Commands | Validation, state management, checkpoints, git commits, session tracking | Business logic, agent selection details |
| Skills | Agent selection, delegation context preparation, routing | State updates, artifact linking, git commits |
| Agents | Research/planning/implementation work, artifact creation | Status updates, transaction management |

### 3. Remove Postflight Logic from Skills

**Current skill-researcher.md lines 68-100**: Preflight/postflight logic

**Should be**: 3-5 step process:
1. Validate inputs
2. Select agent based on language
3. Prepare delegation context
4. Invoke agent via Task tool
5. Return agent's result (no modification)

### 4. Commands Should Be Idempotent

State update operations should check if already applied:
```bash
# Before adding artifact link, check if exists
existing=$(jq -r '.active_projects[] | select(.project_number == $N) | .artifacts[] | select(.path == "$path")' state.json)
if [ -z "$existing" ]; then
    # Add artifact
fi
```

### 5. Skills Should Validate But Not Modify State

Skills CAN:
- Read state.json to get task info
- Validate task exists
- Pass context to agent

Skills CANNOT:
- Update state.json status
- Create git commits
- Link artifacts in TODO.md

### 6. Session ID Management Pattern

**Commands generate and track session_id**:
```bash
# CHECKPOINT 1 (GATE IN)
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"

# Pass to skill
invoke_skill --session-id "$session_id"

# CHECKPOINT 2 (GATE OUT)
# Verify returned session_id matches
returned_sid=$(jq -r '.metadata.session_id' metadata.json)
if [ "$returned_sid" != "$session_id" ]; then
    error "Session ID mismatch"
fi

# CHECKPOINT 3 (COMMIT)
git commit -m "Session: $session_id"
```

## Risks & Mitigations

### Risk 1: Commands Become Too Complex

**Likelihood**: Medium
**Impact**: Medium
**Mitigation**: Template the checkpoint pattern. Commands should be 80% boilerplate from template.

### Risk 2: Duplicate Logic Across Commands

**Likelihood**: High
**Impact**: Low
**Mitigation**: Extract common checkpoint operations to shell functions or skill-status-sync utility.

### Risk 3: Skills May Still Be Invoked Directly

**Likelihood**: Low
**Impact**: Low
**Mitigation**: Skills work fine when invoked directly - they just don't do checkpoints. Commands are the normal entry point.

### Risk 4: Other Commands May Need Similar Updates

**Likelihood**: High
**Impact**: Medium
**Mitigation**: Plan v3 already sequences this: /research first, then /plan, then /implement. Incremental rollout reduces risk.

## Architectural Principles Summary

Based on industry research and best practices:

### Principle 1: Gateway Pattern
Commands are the API Gateway. They handle routing, validation, aggregation, and cross-cutting concerns (state management, transaction boundaries).

### Principle 2: Single Responsibility
Each layer has ONE primary responsibility:
- Commands: Orchestrate
- Skills: Delegate
- Agents: Execute

### Principle 3: Transaction Boundaries
State updates occur at the transaction boundary (commands), not in delegated services (skills).

### Principle 4: Cross-Cutting Concerns
Logging, state management, git commits are cross-cutting concerns that belong at the orchestration layer (commands).

### Principle 5: Separation of Write and Delegation
Commands handle writes (CQRS command path). Skills handle delegation (query/routing path). Clean separation.

### Principle 6: Fault Tolerance
Checkpoints in commands enable better error recovery - the stable context can retry, rollback, or log failures reliably.

## Appendix

### Search Queries Used
1. "CLI tool architecture checkpoint pattern preflight postflight command layer skill layer 2026"
2. "multi-layer CLI architecture commands delegating to skills agent orchestration best practices"
3. "state management checkpoint pattern command vs service layer CLI tool design"
4. "thin wrapper pattern command orchestration responsibility placement separation concerns"
5. "orchestration layer business logic checkpoint validation where to place responsibilities"
6. "workflow orchestration preflight postflight hooks state management best practices"
7. "single responsibility principle command handler service layer orchestrator pattern"
8. "gateway pattern API gateway responsibility validation routing orchestration microservices"
9. "cross-cutting concerns transaction boundaries where to place state management persistence"

### Key References

**Architecture Patterns**:
- [Introducing CLI Agent Orchestrator - AWS](https://aws.amazon.com/blogs/opensource/introducing-cli-agent-orchestrator-transforming-developer-cli-tools-into-a-multi-agent-powerhouse/)
- [AI Agent Orchestration Patterns - Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)
- [Microservices Pattern: API Gateway](https://microservices.io/patterns/apigateway.html)

**Design Patterns**:
- [Command Pattern in Service Layer](http://codebetter.com/iancooper/2011/04/27/why-use-the-command-processor-pattern-in-the-service-layer/)
- [CQRS Pattern - Azure](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- [Command Pattern - Refactoring Guru](https://refactoring.guru/design-patterns/command)

**Orchestration Best Practices**:
- [Workflow Orchestration - Appian](https://appian.com/blog/acp/process-automation/workflow-orchestration-explained)
- [Workflow orchestration - CircleCI](https://circleci.com/docs/workflows/)
- [Orchestration Layer - ScienceDirect](https://www.sciencedirect.com/topics/computer-science/orchestration-layer)

**Cross-Cutting Concerns**:
- [Cross-Cutting Concerns in Distributed System - GeeksforGeeks](https://www.geeksforgeeks.org/system-design/cross-cutting-concerns-in-distributed-system/)
- [Mastering Transaction Boundaries](https://karinavarela.me/2020/06/28/mastering-transaction-boundaries/)
- [Transaction Boundaries - PlexObject](https://weblog.plexobject.com/archives/7001)

**API Gateway Pattern**:
- [API Gateway Patterns - Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/gateway)
- [API Gateway Pattern - GeeksforGeeks](https://www.geeksforgeeks.org/system-design/api-gateway-patterns-in-microservices/)
- [API Gateway Pattern - Digital API](https://www.digitalapi.ai/blogs/api-gateway-pattern-in-a-microservices-architecture)

### Codebase Files Analyzed
- `.claude/commands/research.md` - Complete checkpoint implementation in command
- `.claude/skills/skill-researcher/SKILL.md` - Skill attempting postflight (broken by Issue #17351)
- `.claude/context/core/patterns/checkpoint-execution.md` - Checkpoint pattern documentation
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Thin wrapper pattern guide
- `specs/676_investigate_skill_registration_integrate_task_command/reports/research-003.md` - Root cause analysis
- `specs/676_investigate_skill_registration_integrate_task_command/plans/implementation-003.md` - Current plan

### Architectural Alignment

| Pattern | Commands Handle | Skills Handle | Alignment |
|---------|----------------|---------------|-----------|
| API Gateway | Routing, validation, cross-cutting | Service selection | ✅ Yes |
| CQRS | Write operations (state) | Query operations (delegation) | ✅ Yes |
| Transaction Boundary | State updates, commits | Work delegation | ✅ Yes |
| Cross-Cutting Concerns | Logging, state mgmt, git | Business routing | ✅ Yes |
| Single Responsibility | Orchestration | Delegation | ✅ Yes |
| Workflow Orchestration | Setup/teardown | Task execution | ✅ Yes |

**Conclusion**: Option C (checkpoints in commands) aligns with ALL six industry patterns.

## Final Verdict

**User's concern**: "I am not convinced that running preflight/postflight in commands as opposed to skills is the best solution."

**Research conclusion**: Industry patterns, architectural principles, and best practices **unanimously support checkpoints in commands**.

**Recommendation**: PROCEED with Plan v3 Option C. This is not just a workaround for Issue #17351 - it's the architecturally correct solution that aligns with:
- API Gateway pattern
- CQRS pattern
- Transaction boundary principles
- Cross-cutting concerns placement
- Single Responsibility Principle
- Workflow orchestration best practices

The user's intuition to question the placement was valuable - this research validates that Option C is not just pragmatic, but fundamentally sound architecture.
