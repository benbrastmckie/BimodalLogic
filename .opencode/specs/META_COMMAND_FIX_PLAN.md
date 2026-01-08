# Meta Command Fix Implementation Plan

**Created**: 2026-01-08  
**Status**: IMPLEMENTED  
**Estimated Effort**: 3-5 hours  
**Priority**: High  
**Type**: meta

---

## Executive Summary

This plan revises the `/meta` command to support three clean, intuitive modes:

1. **`/meta {description}`** - Direct mode: Creates tasks immediately from description
2. **`/meta --ask {description}`** - Clarification mode: Asks follow-up questions before creating tasks
3. **`/meta`** - Full interactive mode: Conducts complete guided interview

### Current State vs. Desired State

**Current Implementation**:
- `/meta 294` - Task Mode (creates plan for existing task)
- `/meta "description"` - Prompt Mode (skips Stage 2, goes to Stage 3)
- `/meta` - Interactive Mode (full interview)

**Desired Implementation**:
- `/meta {description}` - Direct Mode (creates tasks immediately, no questions)
- `/meta --ask {description}` - Clarification Mode (asks targeted follow-up questions)
- `/meta` - Interactive Mode (full guided interview)

**Key Change**: Remove Task Mode (use `/plan` for existing tasks instead), add `--ask` flag for partial interactive mode.

---

## Problem Analysis

### Current Issues

1. **Task Mode is confusing**: `/meta 294` tries to create a plan for an existing task, but this is what `/plan 294` should do. Task Mode doesn't fit the `/meta` command's purpose (creating new systems).

2. **Prompt Mode asks too many questions**: When you provide a description, you want tasks created immediately, but Prompt Mode still goes through Stages 3-7 asking questions.

3. **No middle ground**: You either get full interactive mode (many questions) or Prompt Mode (still asks questions). There's no "ask a few clarifying questions" mode.

4. **Flag support missing**: The command doesn't support flags like `--ask` to modify behavior.

### What Works

- ✅ Interactive Mode (Stage 2-9) works well for full interviews
- ✅ Stage 8 creates tasks with plan artifacts via `status-sync-manager`
- ✅ Mode detection logic in Stage 1 is solid
- ✅ Meta task routing is configured in `/implement`

---

## Solution Design

### Principle: Three Clear Modes

1. **Direct Mode** (`/meta {description}`):
   - No questions asked
   - Infers everything from description
   - Creates tasks immediately
   - Fast and efficient for clear requirements

2. **Clarification Mode** (`/meta --ask {description}`):
   - Asks 3-5 targeted follow-up questions
   - Refines understanding before creating tasks
   - Balances speed and accuracy
   - Good for ambiguous requirements

3. **Interactive Mode** (`/meta`):
   - Full guided interview (Stages 2-7)
   - Comprehensive requirements gathering
   - Best for complex or unclear requirements

### Architecture Changes

**Remove**: Task Mode (use `/plan` for existing tasks)  
**Add**: `--ask` flag support  
**Modify**: Prompt Mode → Direct Mode (no questions)  
**Add**: Clarification Mode (new mode with `--ask` flag)

---

## Implementation Details

### Change 1: Update Mode Detection (Stage 1)

**Current Logic** (lines 162-232):
```
1. If empty → Interactive Mode
2. If first token is integer → Task Mode
3. Else → Prompt Mode
```

**New Logic**:
```
1. If empty → Interactive Mode
2. If starts with --ask → Clarification Mode
3. Else → Direct Mode
```

**Implementation**:

```xml
<stage id="1" name="ParseAndValidate">
  <action>Detect mode and parse arguments (Direct/Clarification/Interactive)</action>
  <process>
    1. Parse $ARGUMENTS:
       - If empty: mode = "interactive", skip to step 6
       - Extract first token: first_token=$(echo "$ARGUMENTS" | awk '{print $1}')
    
    2. Check for --ask flag:
       - if [[ "$first_token" == "--ask" ]]; then
           mode="clarification"
           description="${ARGUMENTS#--ask }"  # Remove --ask prefix
           description=$(echo "$description" | xargs)  # Trim whitespace
           if [[ -z "$description" ]]; then
             echo "Error: --ask flag requires a description"
             echo "Usage: /meta --ask {description}"
             exit 1
           fi
         else
           mode="direct"
           description="$ARGUMENTS"
         fi
    
    3. Validate description is non-empty (Direct/Clarification modes):
       - if [[ -z "$description" ]]; then
           echo "Error: Description required"
           echo "Usage: /meta {description} or /meta --ask {description} or /meta"
           exit 1
         fi
    
    4. Store mode and context:
       - mode: "direct" | "clarification" | "interactive"
       - If mode == "direct" OR mode == "clarification": description (full text)
       - If mode == "interactive": (no additional context)
    
    5. Determine stage execution path:
       - If mode == "direct": Skip Stages 2-7, proceed to Stage 8
       - If mode == "clarification": Skip Stage 2, proceed to Stage 3 (with limited questions)
       - If mode == "interactive": Execute all stages 2-9
    
    6. Log mode detection:
       - Log: "[INFO] Mode detected: $mode"
       - If mode == "direct": Log: "[INFO] Creating tasks directly from description"
       - If mode == "clarification": Log: "[INFO] Will ask follow-up questions before creating tasks"
       - If mode == "interactive": Log: "[INFO] Starting full interactive interview"
  </process>
  <validation>
    - mode must be set to "direct", "clarification", or "interactive"
    - If mode == "direct" OR mode == "clarification": description must be non-empty
    - Stage execution path must be determined
  </validation>
  <checkpoint>Mode detected, arguments parsed, stage path determined</checkpoint>
</stage>
```

---

### Change 2: Update Stage 2 (InitiateInterview)

**Current**: Skipped if mode != "interactive"  
**New**: Skipped if mode != "interactive" (no change needed)

---

### Change 3: Update Stage 3 (GatherDomainInformation)

**Current**: Pre-populates from target_domain in Prompt Mode, asks questions if incomplete  
**New**: 
- **Direct Mode**: Infer everything from description, no questions
- **Clarification Mode**: Ask 2-3 targeted questions about domain/purpose
- **Interactive Mode**: Full questioning (no change)

**Implementation**:

```xml
<stage id="3" name="GatherDomainInformation">
  <action>Collect domain, purpose, and target user information (CONDITIONAL: behavior varies by mode)</action>
  <process>
    1. Check mode and handle accordingly:
       
       a. If mode == "direct":
          - Log: "[INFO] Direct Mode - Inferring domain information from description"
          - Parse description to extract:
            * domain: Look for keywords (proof, verification, testing, deployment, etc.)
            * purpose: Use description as-is
            * target_users: Infer from domain (e.g., "researchers" for proof domain)
          - Use LLM to extract structured information:
            * "Extract domain, purpose, and target users from: {description}"
            * Example: "Add proof verification capabilities" → 
              domain="formal verification", purpose="add proof verification", target_users="researchers"
          - If extraction fails or is ambiguous:
            * Use generic values: domain="general", purpose=description, target_users="developers"
            * Log warning: "Could not extract specific domain, using generic values"
          - Skip to step 9 (no questions asked)
       
       b. If mode == "clarification":
          - Log: "[INFO] Clarification Mode - Asking targeted follow-up questions"
          - Parse description to extract initial context (same as Direct Mode)
          - Identify ambiguities or missing information:
            * Is domain clear? (e.g., "system" is vague, "proof verification" is clear)
            * Is purpose clear? (e.g., "improve workflow" is vague, "automate testing" is clear)
            * Are target users clear? (e.g., "users" is vague, "QA engineers" is clear)
          - Ask 2-3 targeted questions ONLY for ambiguous/missing information:
            * If domain unclear: "What domain is this for? (e.g., formal verification, testing, deployment)"
            * If purpose unclear: "What's the main goal? (e.g., automate X, improve Y, add Z capability)"
            * If target users unclear: "Who will use this? (e.g., researchers, developers, QA engineers)"
          - Capture responses and merge with extracted context
          - Skip to step 9 (limited questions)
       
       c. If mode == "interactive":
          - Continue with full interactive questioning (steps 2-8 below)
    
    2. (Interactive Mode only) Ask about domain:
       "What domain or field is this system for?
       
       Examples:
       - Formal verification (theorem proving, proof checking)
       - Software development (testing, deployment, code review)
       - Business operations (e-commerce, customer support)
       - Data engineering (pipelines, analytics, ML workflows)
       - Content creation (writing, editing, publishing)"
    
    3. (Interactive Mode only) Capture domain response
    
    4. (Interactive Mode only) Ask about purpose:
       "What's the primary purpose of this system?
       
       Examples:
       - Automate proof verification workflows
       - Streamline development and testing
       - Manage customer support tickets
       - Orchestrate data pipelines
       - Assist with content creation"
    
    5. (Interactive Mode only) Capture purpose response
    
    6. (Interactive Mode only) Ask about target users:
       "Who will use this system?
       
       Examples:
       - Researchers and theorem provers
       - Software developers and QA engineers
       - Customer support teams
       - Data engineers and analysts
       - Content writers and editors"
    
    7. (Interactive Mode only) Capture target_users response
    
    8. (Clarification Mode continuation) Merge extracted and asked information
    
    9. Detect domain type (all modes):
       - If domain contains "proof", "theorem", "verification", "lean": type = "formal_verification"
       - If domain contains "code", "software", "development", "testing": type = "development"
       - If domain contains "business", "customer", "support", "commerce": type = "business"
       - If domain contains "data", "pipeline", "analytics", "ML": type = "hybrid"
       - Else: type = "general"
    
    10. Store: domain, purpose, target_users, domain_type
  </process>
  <validation>
    - domain, purpose, target_users must be non-empty (inferred, extracted, or asked)
    - domain_type must be detected
    - If mode == "direct": All fields inferred from description
    - If mode == "clarification": At least domain and purpose must be clear after questions
    - If mode == "interactive": All fields collected via full questions
  </validation>
  <checkpoint>Domain information collected (inferred, clarified, or fully gathered)</checkpoint>
</stage>
```

---

### Change 4: Update Stage 4 (IdentifyUseCases)

**Current**: Skipped in Task Mode  
**New**: 
- **Direct Mode**: Infer use cases from description
- **Clarification Mode**: Ask 1-2 questions about use cases
- **Interactive Mode**: Full questioning (no change)

**Implementation**:

```xml
<stage id="4" name="IdentifyUseCases">
  <action>Explore use cases and prioritize capabilities (CONDITIONAL: behavior varies by mode)</action>
  <process>
    1. Check mode:
       
       a. If mode == "direct":
          - Log: "[INFO] Direct Mode - Inferring use cases from description"
          - Parse description to extract use cases:
            * Look for action verbs (automate, verify, test, deploy, etc.)
            * Look for workflow mentions (research → implement → verify)
            * Look for capability mentions (proof checking, test automation, etc.)
          - Use LLM to extract 3-5 use cases:
            * "Extract 3-5 use cases from: {description}"
            * Example: "Add proof verification capabilities" →
              1. Research proof strategies
              2. Implement proofs in Lean 4
              3. Verify proofs compile
          - Assign default complexity/priority:
            * complexity: "moderate" (default)
            * dependencies: "standalone" (default)
            * priority: "high" (default)
          - Skip to step 6
       
       b. If mode == "clarification":
          - Log: "[INFO] Clarification Mode - Asking about use cases"
          - Parse description to extract initial use cases (same as Direct Mode)
          - Ask 1-2 targeted questions:
            * "I identified these use cases: {list}. Are these correct? Any missing?"
            * If user adds/modifies: Update use cases list
            * If user confirms: Proceed with extracted use cases
          - Assign default complexity/priority (same as Direct Mode)
          - Skip to step 6
       
       c. If mode == "interactive":
          - Continue with full interactive questioning (steps 2-6 below)
    
    2. (Interactive Mode only) Ask about use cases:
       "What are the top 3-5 use cases or workflows you want to support?
       
       For each use case, describe:
       - What task needs to be done
       - What inputs are required
       - What outputs are expected
       
       Example for formal verification:
       1. Research proof strategies for a theorem
       2. Implement proof in Lean 4
       3. Verify proof compiles and passes tests
       
       Example for software development:
       1. Run tests and analyze failures
       2. Generate code based on specifications
       3. Review code for quality and standards"
    
    3. (Interactive Mode only) Capture use_cases (list of 3-5 items)
    
    4. (Interactive Mode only) For each use case, assess:
       a. Complexity: simple | moderate | complex
       b. Dependencies: standalone | depends on other use cases
       c. Priority: high | medium | low
    
    5. (Interactive Mode only) Ask clarifying questions if needed:
       - "Does use case X require results from use case Y?"
       - "Is use case X a one-step or multi-step process?"
       - "What tools or data does use case X need?"
    
    6. Store: use_cases with complexity, dependencies, priority
  </process>
  <validation>
    - Must have 3-5 use cases (inferred, clarified, or fully gathered)
    - Each use case must have complexity, dependencies, priority
    - At least one use case must be high priority
    - If mode == "direct": Use cases inferred from description
    - If mode == "clarification": Use cases confirmed with user
    - If mode == "interactive": Use cases fully gathered via questions
  </validation>
  <checkpoint>Use cases identified and prioritized</checkpoint>
</stage>
```

---

### Change 5: Update Stage 5 (AssessComplexity)

**Current**: Skipped in Task Mode  
**New**:
- **Direct Mode**: Infer complexity from use cases
- **Clarification Mode**: Ask 1 question about complexity
- **Interactive Mode**: Full questioning (no change)

**Implementation**:

```xml
<stage id="5" name="AssessComplexity">
  <action>Determine agent count, hierarchy, and knowledge requirements (CONDITIONAL: behavior varies by mode)</action>
  <process>
    1. Check mode:
       
       a. If mode == "direct":
          - Log: "[INFO] Direct Mode - Inferring complexity from use cases"
          - Analyze use cases to determine agent count:
            * 1-2 use cases, low complexity → 1-2 agents
            * 3-4 use cases, mixed complexity → 3-5 agents
            * 5+ use cases, high complexity → 5-8 agents
          - Determine hierarchy:
            * If use cases have dependencies → "hierarchical"
            * Else → "flat"
          - Infer knowledge areas from domain and use cases:
            * Extract key concepts (e.g., "proof strategies" from "proof verification")
            * Generate 3-5 knowledge areas
          - Determine state management:
            * If use cases mention "track", "progress", "status" → needs_state_management = true
            * Else → needs_state_management = false
          - Skip to step 9
       
       b. If mode == "clarification":
          - Log: "[INFO] Clarification Mode - Asking about complexity"
          - Infer initial complexity (same as Direct Mode)
          - Ask 1 targeted question:
            * "I recommend {agent_count} agents in a {hierarchy} structure. Does this sound right?"
            * If user agrees: Proceed with inferred values
            * If user disagrees: Ask "How many agents do you think you need?" and update
          - Infer knowledge areas and state management (same as Direct Mode)
          - Skip to step 9
       
       c. If mode == "interactive":
          - Continue with full interactive questioning (steps 2-9 below)
    
    2. (Interactive Mode only) Analyze use cases to determine agent count:
       - Simple domain (1-2 use cases, low complexity): 1-2 agents
       - Moderate domain (3-4 use cases, mixed complexity): 3-5 agents
       - Complex domain (5+ use cases, high complexity): 5-8 agents
    
    3. (Interactive Mode only) Ask about hierarchy:
       "Based on your use cases, I recommend {N} specialized agents.
       
       Should these agents:
       a) Work independently (flat structure)
       b) Have an orchestrator that coordinates them (hierarchical)
       
       Recommendation: {recommendation based on use case dependencies}"
    
    4. (Interactive Mode only) Capture hierarchy choice
    
    5. (Interactive Mode only) Ask about knowledge requirements:
       "What domain knowledge do these agents need?
       
       Examples:
       - Proof strategies and tactics (for formal verification)
       - Coding standards and best practices (for development)
       - Product catalog and pricing (for e-commerce)
       - Data schemas and transformations (for data engineering)
       
       List 3-5 key knowledge areas:"
    
    6. (Interactive Mode only) Capture knowledge_areas (list of 3-5 items)
    
    7. (Interactive Mode only) Ask about state management:
       "Do your workflows need to track state across multiple steps?
       
       Examples:
       - Track proof progress across research → implementation → verification
       - Track ticket status across creation → assignment → resolution
       - Track pipeline runs across stages
       
       Yes/No?"
    
    8. (Interactive Mode only) Capture needs_state_management (boolean)
    
    9. Store: agent_count, hierarchy, knowledge_areas, needs_state_management
  </process>
  <validation>
    - agent_count must be 1-8
    - hierarchy must be "flat" or "hierarchical"
    - knowledge_areas must have 3-5 items
    - needs_state_management must be boolean
    - If mode == "direct": All fields inferred from use cases
    - If mode == "clarification": Agent count/hierarchy confirmed with user
    - If mode == "interactive": All fields collected via full questions
  </validation>
  <checkpoint>Complexity assessed and architecture planned</checkpoint>
</stage>
```

---

### Change 6: Update Stage 6 (IdentifyIntegrations)

**Current**: Skipped in Task Mode  
**New**:
- **Direct Mode**: Infer integrations from description
- **Clarification Mode**: Ask 1 question about integrations
- **Interactive Mode**: Full questioning (no change)

**Implementation**:

```xml
<stage id="6" name="IdentifyIntegrations">
  <action>Discover external tool requirements and custom commands (CONDITIONAL: behavior varies by mode)</action>
  <process>
    1. Check mode:
       
       a. If mode == "direct":
          - Log: "[INFO] Direct Mode - Inferring integrations from description"
          - Parse description and domain to infer external tools:
            * If domain == "formal_verification" → ["Lean 4", "LSP"]
            * If domain == "development" → ["Git", "CI/CD"]
            * If domain == "business" → ["Database", "API"]
            * If domain == "hybrid" → ["Data tools"]
            * Else → []
          - Infer file types from domain:
            * If domain == "formal_verification" → [".lean"]
            * If domain == "development" → [".py", ".js", ".ts"]
            * Else → [".md", ".json"]
          - Generate 3-5 custom commands from use cases:
            * Extract action verbs from use cases
            * Create command names: /{verb} (e.g., /verify, /test, /deploy)
            * Generate descriptions from use case text
          - Skip to step 8
       
       b. If mode == "clarification":
          - Log: "[INFO] Clarification Mode - Asking about integrations"
          - Infer initial integrations (same as Direct Mode)
          - Ask 1 targeted question:
            * "I identified these integrations: {tools}. Any others needed?"
            * If user adds: Update external_tools list
            * If user confirms: Proceed with inferred values
          - Infer file types and commands (same as Direct Mode)
          - Skip to step 8
       
       c. If mode == "interactive":
          - Continue with full interactive questioning (steps 2-8 below)
    
    2. (Interactive Mode only) Ask about external tools:
       "What external tools or systems do your agents need to interact with?
       
       Examples:
       - Lean 4 compiler and LSP (for formal verification)
       - Git, GitHub, CI/CD (for development)
       - Databases, APIs (for business operations)
       - Data processing tools (for data engineering)
       
       List any external tools (or 'none'):"
    
    3. (Interactive Mode only) Capture external_tools (list or empty)
    
    4. (Interactive Mode only) Ask about file operations:
       "What types of files will your agents create or modify?
       
       Examples:
       - Lean 4 proof files (.lean)
       - Source code (.py, .js, .ts)
       - Configuration files (.json, .yaml)
       - Documentation (.md)
       
       List file types:"
    
    5. (Interactive Mode only) Capture file_types (list)
    
    6. (Interactive Mode only) Ask about custom commands:
       "What custom slash commands do you want?
       
       Examples:
       - /verify - Verify a proof
       - /test - Run tests
       - /deploy - Deploy to production
       - /analyze - Analyze data
       
       List 3-5 commands with brief descriptions:"
    
    7. (Interactive Mode only) Capture custom_commands (list of {name, description})
    
    8. Store: external_tools, file_types, custom_commands
  </process>
  <validation>
    - file_types must be non-empty
    - custom_commands must have 3-5 items
    - Each command must have name and description
    - If mode == "direct": All fields inferred from description/domain
    - If mode == "clarification": External tools confirmed with user
    - If mode == "interactive": All fields fully gathered via questions
  </validation>
  <checkpoint>Integration requirements identified</checkpoint>
</stage>
```

---

### Change 7: Update Stage 7 (ReviewAndConfirm)

**Current**: Skipped in Task Mode  
**New**:
- **Direct Mode**: Skip (no confirmation needed)
- **Clarification Mode**: Brief confirmation
- **Interactive Mode**: Full confirmation (no change)

**Implementation**:

```xml
<stage id="7" name="ReviewAndConfirm">
  <action>Present architecture summary and get user confirmation (CONDITIONAL: behavior varies by mode)</action>
  <process>
    1. Check mode:
       
       a. If mode == "direct":
          - Log: "[INFO] Direct Mode - Skipping confirmation, proceeding to task creation"
          - Skip to Stage 8
       
       b. If mode == "clarification":
          - Log: "[INFO] Clarification Mode - Brief confirmation"
          - Generate brief summary:
            "Based on your description and answers, I'll create:
            - {agent_count} agents ({hierarchy} structure)
            - {custom_commands.length} custom commands
            - Context files for {domain}
            
            Proceed? (yes/no)"
          - If user says "yes": Proceed to Stage 8
          - If user says "no": Ask "What would you like to change?" and go back to relevant stage
          - If user says "cancel": Exit with status "cancelled"
       
       c. If mode == "interactive":
          - Continue with full confirmation (steps 2-6 below)
    
    2. (Interactive Mode only) Generate architecture summary:
       "Here's the .opencode system I'll create for you:
       
       DOMAIN: {domain}
       PURPOSE: {purpose}
       USERS: {target_users}
       
       AGENTS ({agent_count}):
       {for each planned agent:}
       - {agent_name}: {agent_description}
       
       COMMANDS ({custom_commands.length}):
       {for each command:}
       - /{command.name}: {command.description}
       
       CONTEXT FILES:
       - Domain knowledge: {knowledge_areas}
       - Integration guides: {external_tools}
       - Standards and templates
       
       ARCHITECTURE:
       - Hierarchy: {hierarchy}
       - State management: {needs_state_management ? "Yes" : "No"}
       - Integration mode: {integration_mode}
       
       USE CASES:
       {for each use case:}
       {priority} - {use_case.description}
       "
    
    3. (Interactive Mode only) Ask for confirmation:
       "Does this architecture meet your needs?
       
       Options:
       a) Yes, create this system
       b) No, I want to revise {specific aspect}
       c) Cancel"
    
    4. (Interactive Mode only) If user says "Yes": Proceed to Stage 8
    
    5. (Interactive Mode only) If user says "No":
       a. Ask which aspect to revise
       b. Go back to relevant stage (3-6)
       c. Re-collect that information
       d. Return to Stage 7
    
    6. (Interactive Mode only) If user says "Cancel": Exit with status "cancelled"
  </process>
  <validation>
    - If mode == "direct": Stage skipped
    - If mode == "clarification": User must confirm or request changes
    - If mode == "interactive": Architecture summary must be complete, user must confirm
  </validation>
  <checkpoint>Architecture confirmed by user OR stage skipped</checkpoint>
</stage>
```

---

### Change 8: Update Stage 8 (CreateTasksWithArtifacts)

**Current**: Creates single plan for Task Mode, multiple tasks for Prompt/Interactive Mode  
**New**: Creates multiple tasks for all modes (Direct/Clarification/Interactive)

**Implementation**: No changes needed - Stage 8 already creates multiple tasks. Just remove Task Mode branch (step 1a).

---

### Change 9: Update Stage 9 (DeliverTaskSummary)

**Current**: Different output for Task Mode vs. Prompt/Interactive Mode  
**New**: Same output for all modes (Direct/Clarification/Interactive)

**Implementation**: No changes needed - Stage 9 already handles multiple tasks. Just remove Task Mode branch (step 1a).

---

### Change 10: Update Command Documentation

**File**: `.opencode/command/meta.md`

**Changes**:

1. Update usage section (lines 24-70):

```markdown
**Task Input (optional):** $ARGUMENTS (description, --ask description, or empty)

**Usage:** `/meta [--ask] [DESCRIPTION]`

# /meta Command

## Purpose

The `/meta` command creates tasks to implement new .opencode system capabilities. It supports three modes:

1. **Direct Mode** (`/meta {description}`): Creates tasks immediately from description
2. **Clarification Mode** (`/meta --ask {description}`): Asks follow-up questions before creating tasks
3. **Interactive Mode** (`/meta`): Conducts full guided interview to gather requirements

**Use this command when you need to**:
- Create a new .opencode system for a specific domain
- Extend an existing .opencode system with new capabilities
- Design and generate custom agents and commands
- Organize context files for a new domain or workflow

---

## Usage

```
/meta [--ask] [DESCRIPTION]
```

- **Direct Mode**: Provide description, tasks created immediately
- **Clarification Mode**: Provide description with --ask flag, answer follow-up questions
- **Interactive Mode**: No arguments, full guided interview

### Examples

```
# Example 1: Direct mode - create tasks immediately
/meta "Add proof verification capabilities to the system"

# Example 2: Direct mode - create new system
/meta "Create a system for managing customer support tickets with automated routing"

# Example 3: Clarification mode - ask follow-up questions
/meta --ask "Improve the testing workflow"

# Example 4: Interactive mode - full guided interview
/meta
> [Interactive interview follows]
```
```

2. Update Mode Detection section (lines 162-177):

```markdown
## Mode Detection

The /meta command automatically detects which mode to use based on $ARGUMENTS:

1. **Direct Mode Detection**:
   - Description provided without --ask flag
   - Example: `/meta "Add proof verification"`
   - Behavior: Creates tasks immediately, no questions asked

2. **Clarification Mode Detection**:
   - Description provided with --ask flag
   - Example: `/meta --ask "Improve testing"`
   - Behavior: Asks 3-5 targeted follow-up questions, then creates tasks

3. **Interactive Mode Detection**:
   - No arguments provided
   - Example: `/meta`
   - Behavior: Conducts full guided interview (6 stages)

### When to Use Each Mode

- **Use Direct Mode** when requirements are clear and complete
- **Use Clarification Mode** when requirements are somewhat clear but may need refinement
- **Use Interactive Mode** when requirements are unclear or complex

**Examples**:
- `/meta "Add proof verification capabilities"` - Clear requirement, use Direct Mode
- `/meta --ask "Improve the workflow"` - Vague requirement, use Clarification Mode
- `/meta` - No idea what you need, use Interactive Mode
```

3. Update workflow section to reflect new modes (lines 74-159)

---

### Change 11: Update Agent Documentation

**File**: `.opencode/agent/subagents/meta.md`

**Changes**:

1. Update `<system_context>` (lines 58-63):

```xml
<system_context>
  System builder that creates tasks to implement .opencode architectures. Supports three modes:
  1. Direct Mode (with description): Creates tasks immediately, no questions
  2. Clarification Mode (with --ask description): Asks 3-5 follow-up questions before creating tasks
  3. Interactive Mode (no arguments): Conducts full guided interview to gather requirements
</system_context>
```

2. Update `<execution_context>` (lines 73-78):

```xml
<execution_context>
  Full workflow ownership with Stage 8 (Postflight) execution.
  Returns standardized format per subagent-return-format.md for Stage 9.
  Mode detection: If starts with --ask → Clarification Mode,
  else if description non-empty → Direct Mode, else → Interactive Mode.
</execution_context>
```

3. Update `<mode_detection>` section (lines 93-123) to reflect new modes

4. Update all stage implementations (Stages 1-7) as detailed above

---

## Implementation Phases

### Phase 1: Update Mode Detection (1 hour) [COMPLETE]

**Goal**: Implement new mode detection logic with `--ask` flag support.

**Tasks**:
1. ✅ Update Stage 1 to detect Direct/Clarification/Interactive modes
2. ✅ Add `--ask` flag parsing
3. ✅ Remove Task Mode logic
4. ✅ Add validation for description in Direct/Clarification modes
5. ✅ Test mode detection with all three modes

**Validation**:
- `/meta "description"` → Direct Mode
- `/meta --ask "description"` → Clarification Mode
- `/meta` → Interactive Mode
- `/meta --ask` (no description) → Error with usage message

**Artifacts**:
- Updated `.opencode/agent/subagents/meta.md` (Stage 1, frontmatter, mode_detection)

---

### Phase 2: Update Stage 3 (Domain Information) (1 hour) [COMPLETE]

**Goal**: Implement Direct/Clarification/Interactive behavior for domain gathering.

**Tasks**:
1. ✅ Add Direct Mode logic (infer from description, no questions)
2. ✅ Add Clarification Mode logic (ask 2-3 targeted questions)
3. ✅ Keep Interactive Mode logic (full questions)
4. ✅ Test all three modes

**Validation**:
- Direct Mode: No questions asked, domain inferred correctly
- Clarification Mode: 2-3 questions asked, domain refined
- Interactive Mode: Full questions asked, domain gathered

**Artifacts**:
- Updated `.opencode/agent/subagents/meta.md` (Stage 3)

---

### Phase 3: Update Stages 4-6 (Use Cases, Complexity, Integrations) (1-2 hours) [COMPLETE]

**Goal**: Implement Direct/Clarification/Interactive behavior for remaining stages.

**Tasks**:
1. ✅ Update Stage 4 (Use Cases) with Direct/Clarification/Interactive logic
2. ✅ Update Stage 5 (Complexity) with Direct/Clarification/Interactive logic
3. ✅ Update Stage 6 (Integrations) with Direct/Clarification/Interactive logic
4. ✅ Test all three modes for each stage

**Validation**:
- Direct Mode: All information inferred, no questions
- Clarification Mode: 1-2 questions per stage, information refined
- Interactive Mode: Full questions, information gathered

**Artifacts**:
- Updated `.opencode/agent/subagents/meta.md` (Stages 4-6)

---

### Phase 4: Update Stage 7 (Review and Confirm) (30 minutes) [COMPLETE]

**Goal**: Implement Direct/Clarification/Interactive behavior for confirmation.

**Tasks**:
1. ✅ Add Direct Mode logic (skip confirmation)
2. ✅ Add Clarification Mode logic (brief confirmation)
3. ✅ Keep Interactive Mode logic (full confirmation)
4. ✅ Test all three modes

**Validation**:
- Direct Mode: No confirmation, proceeds directly to Stage 8
- Clarification Mode: Brief confirmation, user can approve/revise
- Interactive Mode: Full confirmation with detailed summary

**Artifacts**:
- Updated `.opencode/agent/subagents/meta.md` (Stage 7)

---

### Phase 5: Update Stage 8 and 9 (Task Creation and Summary) (30 minutes) [COMPLETE]

**Goal**: Remove Task Mode logic, ensure all modes create multiple tasks.

**Tasks**:
1. ✅ Remove Task Mode branch from Stage 8 (step 1a)
2. ✅ Remove Task Mode branch from Stage 9 (step 1a)
3. ✅ Ensure all modes create multiple tasks with plan artifacts
4. ✅ Test task creation for all three modes

**Validation**:
- All modes create multiple tasks (not single plan)
- All tasks have plan artifacts
- All plan links added to TODO.md and state.json

**Artifacts**:
- Updated `.opencode/agent/subagents/meta.md` (Stages 8-9, notes section)

---

### Phase 6: Update Documentation (30 minutes) [COMPLETE]

**Goal**: Update command and agent documentation to reflect new modes.

**Tasks**:
1. ✅ Update `.opencode/command/meta.md` with new usage, examples, mode detection
2. ✅ Update `.opencode/agent/subagents/meta.md` frontmatter and notes
3. ✅ Update `.opencode/specs/META_COMMAND_FIX_PLAN.md` status
4. ✅ Add examples for all three modes

**Validation**:
- Documentation is clear and accurate
- Examples cover all three modes
- Usage instructions are correct

**Artifacts**:
- Updated `.opencode/command/meta.md`
- Updated `.opencode/agent/subagents/meta.md` (frontmatter, notes)
- Updated `.opencode/specs/META_COMMAND_FIX_PLAN.md`

---

## Testing Strategy

### Unit Tests

1. **Mode Detection**:
   - `/meta "description"` → Direct Mode
   - `/meta --ask "description"` → Clarification Mode
   - `/meta` → Interactive Mode
   - `/meta --ask` → Error

2. **Direct Mode**:
   - Run `/meta "Add proof verification capabilities"`
   - Verify no questions asked
   - Verify tasks created immediately
   - Verify domain/purpose/use cases inferred correctly

3. **Clarification Mode**:
   - Run `/meta --ask "Improve the workflow"`
   - Verify 3-5 questions asked
   - Verify questions are targeted and relevant
   - Verify tasks created after questions answered

4. **Interactive Mode**:
   - Run `/meta`
   - Verify full interview conducted
   - Verify all stages executed
   - Verify tasks created after confirmation

### Integration Tests

1. **End-to-End Direct Mode**:
   - Run `/meta "Create proof verification system"`
   - Verify tasks created with plan artifacts
   - Run `/implement {task_number}` for first task
   - Verify implementation completes

2. **End-to-End Clarification Mode**:
   - Run `/meta --ask "Improve testing"`
   - Answer follow-up questions
   - Verify tasks created with plan artifacts
   - Run `/implement {task_number}` for first task
   - Verify implementation completes

3. **End-to-End Interactive Mode**:
   - Run `/meta`
   - Complete full interview
   - Verify tasks created with plan artifacts
   - Run `/implement {task_number}` for first task
   - Verify implementation completes

### Regression Tests

1. **Existing Meta Functionality**:
   - Run `/meta` in interactive mode
   - Verify interview process works
   - Verify can create simple system

2. **Meta Task Routing**:
   - Create meta task with `/meta "description"`
   - Run `/implement {task_number}`
   - Verify routes to `meta` agent

3. **Plan Artifact Creation**:
   - Run `/meta "description"` in any mode
   - Verify plan artifacts created
   - Verify plan links in TODO.md and state.json

---

## Success Criteria

### Functional Requirements

1. **Mode Detection Works**:
   - [ ] `/meta {description}` → Direct Mode
   - [ ] `/meta --ask {description}` → Clarification Mode
   - [ ] `/meta` → Interactive Mode
   - [ ] `/meta --ask` (no description) → Error

2. **Direct Mode Works**:
   - [ ] No questions asked
   - [ ] Domain/purpose/use cases inferred from description
   - [ ] Tasks created immediately
   - [ ] Plan artifacts linked to tasks

3. **Clarification Mode Works**:
   - [ ] 3-5 targeted questions asked
   - [ ] Questions are relevant and helpful
   - [ ] Tasks created after questions answered
   - [ ] Plan artifacts linked to tasks

4. **Interactive Mode Works**:
   - [ ] Full interview conducted (Stages 2-7)
   - [ ] All information gathered via questions
   - [ ] Tasks created after confirmation
   - [ ] Plan artifacts linked to tasks

### Non-Functional Requirements

1. **Performance**:
   - [ ] Direct Mode completes in <10s
   - [ ] Clarification Mode completes in <30s (excluding user input time)
   - [ ] Interactive Mode completes in <60s (excluding user input time)

2. **Usability**:
   - [ ] Clear mode detection
   - [ ] Helpful error messages
   - [ ] Good documentation
   - [ ] Examples for all modes

3. **Maintainability**:
   - [ ] Code follows existing patterns
   - [ ] No breaking changes
   - [ ] Clear comments
   - [ ] Minimal complexity

---

## Risks and Mitigations

### Risk 1: Inference Quality in Direct Mode
**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Use LLM to extract structured information from description
- Provide sensible defaults if extraction fails
- Log warnings when inference is uncertain
- User can always use Clarification Mode if Direct Mode doesn't work well

### Risk 2: Too Many Questions in Clarification Mode
**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Limit to 3-5 questions total across all stages
- Only ask about ambiguous/missing information
- Skip questions if information is clear from description

### Risk 3: Breaking Existing Workflows
**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Remove Task Mode (use `/plan` instead)
- Keep Interactive Mode unchanged
- Comprehensive regression testing
- Clear migration guide

### Risk 4: Flag Parsing Issues
**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Use simple flag parsing (check first token)
- Validate flag format
- Provide clear error messages
- Test edge cases (--ask without description, etc.)

---

## Migration Guide

### For Users Currently Using Task Mode

**Old**: `/meta 294` (create plan for existing task)  
**New**: `/plan 294` (use /plan command instead)

**Rationale**: Task Mode doesn't fit `/meta`'s purpose (creating new systems). Use `/plan` for existing tasks.

### For Users Currently Using Prompt Mode

**Old**: `/meta "description"` (asks questions in Stages 3-7)  
**New**: 
- `/meta "description"` (Direct Mode - no questions)
- `/meta --ask "description"` (Clarification Mode - few questions)

**Rationale**: Direct Mode is faster for clear requirements. Use `--ask` if you want questions.

### For Users Currently Using Interactive Mode

**Old**: `/meta` (full interview)  
**New**: `/meta` (full interview - no change)

**Rationale**: Interactive Mode unchanged.

---

## Timeline

**Total Estimated Effort**: 3-5 hours

- **Phase 1**: Update Mode Detection (1 hour)
- **Phase 2**: Update Stage 3 (1 hour)
- **Phase 3**: Update Stages 4-6 (1-2 hours)
- **Phase 4**: Update Stage 7 (30 minutes)
- **Phase 5**: Update Stages 8-9 (30 minutes)
- **Phase 6**: Update Documentation (30 minutes)

**Testing**: 1-2 hours (included in phases)

---

## Conclusion

This plan revises the `/meta` command to support three intuitive modes:

1. **`/meta {description}`** - Fast, no questions, tasks created immediately
2. **`/meta --ask {description}`** - Balanced, few questions, refined requirements
3. **`/meta`** - Comprehensive, full interview, detailed requirements

**Key Benefits**:
- ✅ **Intuitive**: Clear mode selection based on user needs
- ✅ **Flexible**: Three modes cover all use cases (fast, balanced, comprehensive)
- ✅ **Elegant**: Simple flag-based mode detection
- ✅ **Focused**: Removes confusing Task Mode (use `/plan` instead)
- ✅ **Fast**: Direct Mode creates tasks in <10s

**Key Changes**:
- Remove Task Mode (use `/plan` for existing tasks)
- Add `--ask` flag for Clarification Mode
- Convert Prompt Mode to Direct Mode (no questions)
- Add inference logic for Direct Mode
- Add targeted questioning for Clarification Mode
- Keep Interactive Mode unchanged

**Next Steps**:
1. Review this plan
2. Approve approach
3. Begin implementation with Phase 1

---

**Plan Version**: 2.0  
**Author**: Claude (OpenCode Assistant)  
**Review Status**: READY FOR REVIEW  
**Recommendation**: Implement all 6 phases (3-5 hours total)
