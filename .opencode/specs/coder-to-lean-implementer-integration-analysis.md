# Integration Analysis: Valuable Elements from coder.md for implementer.md

**Date**: 2025-12-14  
**Purpose**: Identify valuable patterns from `coder.md` that could enhance `implementer.md` without bloating it

---

## Executive Summary

**Recommendation**: Add **3 specific enhancements** from `coder.md` to `implementer.md`:

1. **Error handling rules** - Stop on failure, report-first pattern
2. **Incremental execution** - One step at a time validation
3. **Context loading** - Load LEAN-specific coding standards before implementation

These additions would improve robustness without compromising the streamlined proof implementation focus.

---

## Analysis of coder.md Elements

### ✅ Worth Integrating

#### 1. **Critical Rules for Error Handling**

**From `coder.md`**:
```xml
<critical_rules priority="absolute" enforcement="strict">
  <rule id="stop_on_failure" scope="validation">
    STOP on test fail/build errors - NEVER auto-fix without approval
  </rule>
  
  <rule id="report_first" scope="error_handling">
    On fail: REPORT error → PROPOSE fix → REQUEST APPROVAL → Then fix (never auto-fix)
  </rule>
  
  <rule id="incremental_execution" scope="implementation">
    Implement ONE step at a time, validate each step before proceeding
  </rule>
</critical_rules>
```

**Why valuable for implementer**:
- **Stop on failure**: Currently, `implementer` returns errors to orchestrator, but doesn't explicitly forbid auto-fixing
- **Report-first**: Prevents the agent from silently "fixing" compilation errors that might indicate plan issues
- **Incremental execution**: Aligns with proof step-by-step nature - validate each tactic before proceeding

**How to adapt for LEAN**:
```xml
<critical_rules priority="absolute" enforcement="strict">
  <rule id="stop_on_compilation_failure">
    STOP on LEAN compilation errors - NEVER auto-fix without approval.
    Return error to @orchestrator for plan revision.
  </rule>
  
  <rule id="report_first" scope="error_handling">
    On compilation fail: REPORT error → PROPOSE fix → REQUEST APPROVAL → Then fix.
    Never silently modify the proof plan or tactics.
  </rule>
  
  <rule id="incremental_validation" scope="implementation">
    Validate each proof step incrementally. After each tactic is generated,
    verify it compiles before proceeding to the next step.
  </rule>
</critical_rules>
```

**Impact**: ⭐⭐⭐ High value, low bloat (adds ~15 lines)

---

#### 2. **Context Loading for LEAN Standards**

**From `coder.md`**:
```xml
<critical_context_requirement>
PURPOSE: Context files contain project-specific coding standards that ensure consistency, 
quality, and alignment with established patterns. Without loading context first, 
you will create code that doesn't match the project's conventions.

BEFORE any code implementation (write/edit), ALWAYS load required context files:
- Code tasks → .opencode/context/core/standards/code.md (MANDATORY)
- Language-specific patterns if available
</critical_context_requirement>
```

**Why valuable for implementer**:
- **LEAN style consistency**: Ensures generated proofs follow project conventions
- **Tactic patterns**: Load preferred tactic patterns (e.g., prefer `simp` over manual rewrites)
- **Naming conventions**: Consistent theorem/lemma naming

**How to adapt for LEAN**:
```xml
<context_loading>
  <requirement priority="high">
    BEFORE generating LEAN 4 code, load project-specific standards:
    - LEAN coding standards → .opencode/context/lean4/standards/lean-style.md
    - Tactic patterns → .opencode/context/lean4/patterns/tactic-patterns.md
    - Proof conventions → .opencode/context/lean4/standards/proof-conventions.md
  </requirement>
  
  <purpose>
    Ensures generated proofs follow project conventions for:
    - Tactic selection (prefer automation over manual steps)
    - Naming conventions (theorem/lemma/def naming patterns)
    - Code organization (import order, proof structure)
    - Documentation (docstring format for theorems)
  </purpose>
</context_loading>
```

**Impact**: ⭐⭐⭐ High value, low bloat (adds ~20 lines, but improves consistency significantly)

---

#### 3. **Incremental Validation Workflow**

**From `coder.md`**:
```xml
<stage id="4" name="Execute" when="approved" enforce="@incremental_execution">
  Implement ONE step at a time (never all at once)
  
  After each increment:
  - Run type checks if applicable
  - Run linting if configured
  - Run build checks
  - Execute relevant tests
</stage>
```

**Why valuable for implementer**:
- **Catch errors early**: Validate each tactic before generating the next
- **Better error messages**: Pinpoint which proof step failed
- **Faster iteration**: Don't generate entire proof only to find step 1 was wrong

**How to adapt for LEAN**:
```xml
<stage id="2" name="TacticalImplementation">
  <action>Implement each step of the proof plan using the appropriate tactics.</action>
  <process>
    1. For each step in the plan (e.g., "Apply theorem X"):
       a. Delegate to @tactic-selector to get the correct LEAN 4 tactic
       b. Pass the tactic to @code-generator to write the line of code
       c. **[NEW]** Incrementally validate: Compile the partial proof to verify the tactic works
       d. If compilation succeeds, append the line and proceed to next step
       e. If compilation fails, STOP and report error to @orchestrator
    2. Repeat for all steps in the plan.
  </process>
  <checkpoint>A complete, incrementally validated proof block has been generated.</checkpoint>
</stage>
```

**Impact**: ⭐⭐⭐ High value, medium bloat (adds ~10 lines, but significantly improves reliability)

---

### ❌ Not Worth Integrating

#### 1. **Approval Gates**

**From `coder.md`**:
```xml
<rule id="approval_gate" scope="all_execution">
  Request approval before ANY implementation (write, edit, bash).
</rule>
```

**Why NOT valuable for implementer**:
- **Already has approval**: The proof plan itself is the "approval" - it comes from `@planner`
- **Automated workflow**: `implementer` is meant to run automatically as part of `/prove` command
- **Wrong abstraction level**: User approves the plan, not each tactic

**Verdict**: ❌ Skip - would break automated workflow

---

#### 2. **Multi-Language Adaptation**

**From `coder.md`**:
```
Adapt to the project's language based on the files you encounter 
(TypeScript, Python, Go, Rust, etc.).
```

**Why NOT valuable for implementer**:
- **Single language**: `implementer` only works with LEAN 4
- **Already specialized**: No need for language detection

**Verdict**: ❌ Skip - not applicable

---

#### 3. **Generic Subagent Delegation**

**From `coder.md`**:
```
- `subagents/core/task-manager` - Feature breakdown (4+ files, >60 min)
- `subagents/code/coder-agent` - Simple implementations
- `subagents/code/tester` - Testing after implementation
```

**Why NOT valuable for implementer**:
- **Already has specialized subagents**: `@tactic-selector`, `@code-generator`, `@lean-linter`
- **Different workflow**: Proof implementation is not "feature breakdown"

**Verdict**: ❌ Skip - already has better LEAN-specific subagents

---

#### 4. **SOLID Principles / Clean Code Rhetoric**

**From `coder.md`**:
```
- Modular architecture design
- Functional programming patterns where appropriate
- SOLID principles adherence
- Scalable code structures
```

**Why NOT valuable for implementer**:
- **Different domain**: Formal proofs have different quality criteria (correctness, not scalability)
- **Already covered**: Quality standards section already addresses this (Correctness, Readability, Fidelity)

**Verdict**: ❌ Skip - not applicable to proof implementation

---

## Proposed Integration

### Enhanced implementer.md Structure

```xml
---
description: "Manages a team of subagents to write, lint, and verify LEAN 4 code based on a formal proof plan."
mode: primary
temperature: 0.1
---

# LEAN 4 Implementer

<context>
  [... existing context ...]
</context>

<role>
  [... existing role ...]
</role>

<task>
  [... existing task ...]
</task>

<!-- NEW: Critical Rules -->
<critical_rules priority="absolute" enforcement="strict">
  <rule id="stop_on_compilation_failure">
    STOP on LEAN compilation errors - NEVER auto-fix without approval.
    Return error to @orchestrator for plan revision.
  </rule>
  
  <rule id="report_first" scope="error_handling">
    On compilation fail: REPORT error → PROPOSE fix → REQUEST APPROVAL → Then fix.
    Never silently modify the proof plan or tactics.
  </rule>
  
  <rule id="incremental_validation" scope="implementation">
    Validate each proof step incrementally. After each tactic is generated,
    verify it compiles before proceeding to the next step.
  </rule>
</critical_rules>

<!-- NEW: Context Loading -->
<context_loading>
  <requirement priority="high">
    BEFORE generating LEAN 4 code, load project-specific standards:
    - LEAN coding standards → .opencode/context/lean4/standards/lean-style.md
    - Tactic patterns → .opencode/context/lean4/patterns/tactic-patterns.md
    - Proof conventions → .opencode/context/lean4/standards/proof-conventions.md
  </requirement>
  
  <purpose>
    Ensures generated proofs follow project conventions for:
    - Tactic selection (prefer automation over manual steps)
    - Naming conventions (theorem/lemma/def naming patterns)
    - Code organization (import order, proof structure)
    - Documentation (docstring format for theorems)
  </purpose>
</context_loading>

<workflow_execution>
  <stage id="1" name="PlanInterpretation">
    [... existing stage ...]
  </stage>

  <stage id="2" name="TacticalImplementation">
    <action>Implement each step of the proof plan using the appropriate tactics.</action>
    <process>
      1. For each step in the plan (e.g., "Apply theorem X"):
         a. Delegate to @tactic-selector to get the correct LEAN 4 tactic
         b. Pass the tactic to @code-generator to write the line of code
         c. **Incrementally validate**: Compile the partial proof to verify the tactic works
         d. If compilation succeeds, append the line and proceed to next step
         e. If compilation fails, STOP and report error to @orchestrator
      2. Repeat for all steps in the plan.
    </process>
    <checkpoint>A complete, incrementally validated proof block has been generated.</checkpoint>
  </stage>

  <stage id="3" name="ValidationAndLinting">
    [... existing stage with enhanced error handling ...]
    <decision>
      <if test="compilation fails">
        STOP. Report error to @orchestrator with:
        - Failed tactic/step
        - Compilation error message
        - Suggested plan revision
        DO NOT attempt to auto-fix.
      </if>
      <else>Proceed to finalize the file.</else>
    </decision>
  </stage>

  <stage id="4" name="Finalize">
    [... existing stage ...]
  </stage>
</workflow_execution>

[... rest of existing content ...]
```

---

## Impact Analysis

### Before Integration

**Current `implementer.md`**:
- **Lines**: 112
- **Error handling**: Basic (return error to orchestrator)
- **Validation**: End-of-workflow only
- **Context loading**: None
- **Robustness**: Medium

### After Integration

**Enhanced `implementer.md`**:
- **Lines**: ~160 (+48 lines, +43% size)
- **Error handling**: Explicit stop-on-failure, report-first pattern
- **Validation**: Incremental (after each tactic)
- **Context loading**: LEAN-specific standards loaded before generation
- **Robustness**: High

### Bloat Assessment

**Is +48 lines "bloat"?**

❌ **No, because**:
1. **Critical rules** (+15 lines): Essential for preventing silent failures
2. **Context loading** (+20 lines): Ensures consistency with project standards
3. **Incremental validation** (+13 lines): Catches errors early, saves time

**Total value**: ⭐⭐⭐⭐⭐ (5/5)  
**Bloat level**: ⭐⭐ (2/5) - Minimal bloat, high value

---

## Recommendation Summary

### ✅ Integrate These 3 Elements

1. **Critical Rules** (15 lines)
   - Stop on compilation failure
   - Report-first error handling
   - Incremental validation

2. **Context Loading** (20 lines)
   - Load LEAN style standards
   - Load tactic patterns
   - Load proof conventions

3. **Incremental Validation** (13 lines)
   - Validate each tactic before proceeding
   - Better error messages
   - Faster iteration

**Total addition**: ~48 lines (+43% size)  
**Value**: High robustness, consistency, and error handling  
**Bloat**: Minimal - all additions are high-value

### ❌ Do NOT Integrate

1. Approval gates (breaks automated workflow)
2. Multi-language adaptation (not applicable)
3. Generic subagent delegation (already has LEAN-specific subagents)
4. SOLID principles rhetoric (different domain)

---

## Implementation Plan

### Step 1: Add Critical Rules Section

Insert after `<task>` section, before `<workflow_execution>`.

### Step 2: Add Context Loading Section

Insert after `<critical_rules>`, before `<workflow_execution>`.

### Step 3: Enhance TacticalImplementation Stage

Update stage 2 to include incremental validation (step 1c-1e).

### Step 4: Enhance ValidationAndLinting Stage

Update stage 3 decision block to explicitly forbid auto-fixing.

### Step 5: Create Context Files (if they don't exist)

- `.opencode/context/lean4/standards/lean-style.md`
- `.opencode/context/lean4/patterns/tactic-patterns.md`
- `.opencode/context/lean4/standards/proof-conventions.md`

---

## Conclusion

**Yes, there are valuable elements from `coder.md` worth integrating into `implementer.md`:**

1. **Error handling rules** - Prevent silent failures
2. **Incremental validation** - Catch errors early
3. **Context loading** - Ensure consistency

These additions would make `implementer.md` more robust without compromising its streamlined focus on proof implementation. The +48 lines (+43% size) is justified by the significant improvement in reliability and consistency.

**After integration, we can safely remove `coder.md`.**
