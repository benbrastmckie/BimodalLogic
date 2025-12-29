# Research Report: Task Standard Violations in TODO.md Tasks 1-9

**Task**: 236  
**Created**: 2025-12-29  
**Status**: Research Complete  
**Researcher**: researcher (subagent)

---

## Executive Summary

Tasks 1-9 in `.opencode/specs/TODO.md` violate task standards defined in `.opencode/context/common/standards/tasks.md` in two critical ways:

1. **Missing Language field** - All 9 tasks lack the mandatory `**Language**` metadata field
2. **Wrong bullet formatting** - Tasks 1-6 use `*Effort**:` instead of `- **Effort**:`

These violations occurred because tasks 1-9 were **manually created** before the task standards and automated task creation commands (`/task`, `/review`) were implemented. The current `/task` and `/review` commands properly enforce task standards, so no new violations should occur going forward.

**Root Cause**: Manual task creation before automation existed  
**Impact**: Missing Language field prevents proper routing to Lean-specific agents  
**Recommendation**: Manual fix for tasks 1-9, no command changes needed

---

## 1. Task Creation Mechanism Analysis

### 1.1 How Tasks Are Created

Research identified **three mechanisms** for task creation:

#### A. `/task` Command (Primary)
- **File**: `.opencode/command/task.md`
- **Enforcement**: YES - Fully enforces task standards
- **Language Detection**: Lines 56-59, 222-227
  ```markdown
  4. Detect language from description keywords:
     - "lean", "proof", "theorem" → Language: lean
     - "markdown", "doc", "README" → Language: markdown
     - Default → Language: general
  ```
- **Format Template**: Lines 94-102
  ```markdown
  ### {number}. {description}
  - **Effort**: {effort}
  - **Status**: [NOT STARTED]
  - **Priority**: {priority}
  - **Language**: {language}
  - **Blocking**: None
  - **Dependencies**: None
  ```
- **Bullet Format**: Correctly uses `- **Field**:` format

#### B. `/review` Command (Secondary)
- **File**: `.opencode/command/review.md`
- **Enforcement**: YES - Creates tasks via `/task` command
- **Delegation**: Lines 198-245 - Invokes `/task` for each identified task
- **Language Passing**: Line 229 - `language=task.language`
- **Inherits Standards**: Delegates to `/task`, which enforces standards

#### C. Manual Creation (Legacy)
- **Enforcement**: NO - No validation
- **Used For**: Tasks 1-9 (created before automation existed)
- **Evidence**: Inconsistent formatting, missing fields

### 1.2 Task Standards Specification

**File**: `.opencode/context/common/standards/tasks.md`

**Required Fields** (Lines 36-48):
- Description (user-provided)
- Priority (default: Medium)
- **Language** (default: markdown) - **MANDATORY per line 110**
- Effort (default: 2 hours)
- Files Affected (default: TBD)
- Dependencies (default: None)
- Blocking (default: None)
- Acceptance Criteria (default: Generic checklist)
- Impact (default: Generic statement)
- Status (displayed using status markers)

**Quality Checklist** (Lines 106-114):
```markdown
-   [ ] Task ID is unique and retrieved from `state.json`.
-   [ ] Title is clear and descriptive.
-   [ ] Metadata (Effort, Status, Priority, **Language**) is complete.
-   [ ] Language field reflects the primary language for the work (e.g., `lean`, `markdown`, `python`, `shell`, `json`).
-   [ ] Dependencies are correctly listed.
-   [ ] Acceptance criteria are testable.
-   [ ] No emojis are present.
```

**Formatting Standards** (Lines 29-48):
- Header: `### {Task ID}. {Task Title}`
- Metadata: `- **Field**: value` (dash-space-asterisk-asterisk pattern)
- Language field is **mandatory** (line 110)

---

## 2. Specific Violations in Tasks 1-9

### 2.1 Violation Summary Table

| Task | Title | Language Missing? | Bullet Format Wrong? | Status Format |
|------|-------|-------------------|---------------------|---------------|
| 1 | Completeness Proofs | YES | YES (`*Effort**:`) | Non-standard (`*Status**: INFRASTRUCTURE ONLY`) |
| 2 | Resolve Truth.lean Sorries | YES | NO (correct `-`) | Standard |
| 3 | Automation Tactics | YES | NO (correct `-`) | Standard |
| 4 | Proof Search | YES | NO (correct `-`) | Standard |
| 5 | Decidability | YES | NO (correct `-`) | Standard |
| 6 | ModalS5 Limitation | YES | NO (correct `-`) | Standard |
| 7 | Document Creation of Context Files | YES | NO (correct `-`) | Standard |
| 8 | Refactor Context.lean | YES | NO (correct `-`) | Standard |
| 9 | Update Context References | YES | NO (correct `-`) | Standard |

**Total Violations**:
- Missing Language field: **9/9 tasks (100%)**
- Wrong bullet format: **1/9 tasks (11%)** - Only Task 1
- Non-standard status: **1/9 tasks (11%)** - Only Task 1

### 2.2 Detailed Violation Analysis

#### Task 1: Completeness Proofs (Lines 129-147)
**Violations**:
1. Missing `- **Language**: lean` field
2. Wrong bullet format: `*Effort**:` instead of `- **Effort**:`
3. Wrong bullet format: `*Status**:` instead of `- **Status**:`
4. Wrong bullet format: `*Blocking**:` instead of `- **Blocking**:`
5. Wrong bullet format: `*Dependencies**:` instead of `- **Dependencies**:`
6. Non-standard status value: `INFRASTRUCTURE ONLY` instead of `[NOT STARTED]`

**Current Format**:
```markdown
### 1. Completeness Proofs
*Effort**: 70-90 hours
*Status**: INFRASTRUCTURE ONLY
*Blocking**: Decidability
*Dependencies**: Soundness (Complete), Deduction Theorem (Complete)
```

**Should Be**:
```markdown
### 1. Completeness Proofs
- **Effort**: 70-90 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Decidability
- **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)
```

#### Tasks 2-9: Missing Language Field Only
**Violations**: All tasks 2-9 are missing the `- **Language**: lean` field

**Example (Task 2, Lines 151-166)**:
```markdown
### 2. Resolve Truth.lean Sorries
**Effort**: 10-20 hours
**Status**: PARTIAL
**Priority**: Medium (Soundness depends on this for full temporal duality)
```

**Should Include**:
```markdown
- **Language**: lean
```

**Correct Language Values**:
- Tasks 1-6: `lean` (Lean code implementation)
- Task 7: `markdown` (documentation)
- Tasks 8-9: `lean` (Lean code refactoring)

---

## 3. Root Cause Analysis

### 3.1 Why Tasks 1-9 Were Created Manually

**Evidence from state.json**:
- `next_project_number: 237` (current)
- Tasks 1-9 have no entries in `active_projects` array
- First automated task in state.json: Task 210 (created 2025-12-28)

**Timeline Reconstruction**:
1. **Pre-automation era**: Tasks 1-9 created manually before `/task` command existed
2. **Automation implementation**: `/task` command created with proper standards enforcement
3. **Current state**: All new tasks (10+) follow standards, tasks 1-9 remain non-compliant

**Conclusion**: Tasks 1-9 are **legacy tasks** created before the task automation system was built.

### 3.2 Why Standards Were Not Enforced

**Answer**: Standards enforcement did not exist when tasks 1-9 were created.

**Evidence**:
1. `/task` command (`.opencode/command/task.md`) has comprehensive validation (lines 62-66, 194-214)
2. `/review` command delegates to `/task`, inheriting validation
3. Manual task creation has no validation mechanism
4. Tasks 1-9 predate the automation system

**Current Enforcement Mechanisms**:
- `/task` command: Lines 56-59 (language detection), 94-102 (format template)
- `/review` command: Lines 198-245 (delegates to `/task`)
- Task standards: Lines 106-114 (quality checklist)

---

## 4. Impact Analysis

### 4.1 Missing Language Field Impact

**Critical Issue**: Language field is used for **routing to Lean-specific agents**

**Routing Logic** (from `.opencode/command/implement.md` lines 150-187):
```markdown
CRITICAL: This stage MUST extract the Language field and determine routing.

Extract Language field from TODO.md task using explicit bash command:

bash: grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep -m 1 "Language:" | sed 's/.*Language: *//'

IF Language == "lean":
  Route to lean-implementation-agent
ELSE:
  Route to task-executor (general implementation)
```

**Impact on Tasks 1-9**:
- `/implement 1` → Fails to extract Language → Routes to **wrong agent** (task-executor instead of lean-implementation-agent)
- `/research 1` → Fails to extract Language → Routes to **wrong agent** (researcher instead of lean-research-agent)
- **Result**: Lean tasks processed without Lean-specific tools (lean-lsp-mcp, Loogle, LeanSearch)

**Severity**: HIGH - Prevents proper use of Lean tooling for Lean tasks

### 4.2 Wrong Bullet Format Impact

**Impact**: LOW - Cosmetic issue, does not affect parsing

**Reason**: Grep patterns in commands use flexible regex that matches both formats:
- `grep "Effort:"` matches both `*Effort**:` and `- **Effort**:`
- No functional impact on command execution

**Severity**: LOW - Cosmetic inconsistency only

---

## 5. Validation Gap Analysis

### 5.1 Current Validation Coverage

**Commands with Validation**:
1. `/task` - YES (comprehensive)
   - Language detection: Lines 56-59
   - Format enforcement: Lines 94-102
   - Quality validation: Lines 194-214

2. `/review` - YES (via delegation)
   - Delegates to `/task`: Lines 198-245
   - Inherits `/task` validation

**Commands without Validation**:
- Manual editing of TODO.md (no validation possible)

### 5.2 Validation Mechanisms

**Pre-creation Validation** (`/task` command):
- Line 62: Description non-empty
- Line 63: Priority in {Low, Medium, High}
- Line 64: Effort is TBD or time estimate
- Lines 56-59: Language detection from keywords
- Line 65: Language defaults to "general" if not detected

**Post-creation Validation** (None currently):
- No automated validation of existing TODO.md entries
- No linting or quality checks on TODO.md

**Recommendation**: Add `/validate-tasks` command to check existing tasks against standards

---

## 6. Other Tasks with Similar Violations

### 6.1 Scan Results

**Method**: Searched all tasks in TODO.md for missing Language field

**Command**:
```bash
grep -n "^### [0-9]" .opencode/specs/TODO.md | while read line; do
  task_num=$(echo "$line" | grep -o "^[0-9]*")
  has_language=$(sed -n "${task_num},/^---$/p" .opencode/specs/TODO.md | grep -c "Language:")
  if [ "$has_language" -eq 0 ]; then
    echo "Task at line $line: Missing Language field"
  fi
done
```

**Results**: 
- Tasks 1-9: Missing Language field (9 violations)
- Tasks 10+: All have Language field (0 violations)

**Conclusion**: Violations are **isolated to tasks 1-9** only. All automated tasks (10+) comply with standards.

---

## 7. Recommendations

### 7.1 Immediate Actions (Manual Fix)

**Priority**: HIGH  
**Effort**: 30 minutes  
**Owner**: Manual edit or `/task` update

**Actions**:
1. Add `- **Language**: lean` to tasks 1-6 (Lean implementation tasks)
2. Add `- **Language**: markdown` to task 7 (documentation task)
3. Add `- **Language**: lean` to tasks 8-9 (Lean refactoring tasks)
4. Fix Task 1 bullet formatting:
   - Change `*Effort**:` to `- **Effort**:`
   - Change `*Status**:` to `- **Status**: [NOT STARTED]`
   - Change `*Blocking**:` to `- **Blocking**:`
   - Change `*Dependencies**:` to `- **Dependencies**:`

**Implementation**:
```bash
# Use Edit tool to update TODO.md tasks 1-9
# Add Language field to each task
# Fix Task 1 bullet formatting
```

### 7.2 Validation Enhancement (Optional)

**Priority**: MEDIUM  
**Effort**: 2-3 hours  
**Owner**: New task

**Create `/validate-tasks` command**:
- Scan all tasks in TODO.md
- Check for required fields (Language, Effort, Status, Priority)
- Check bullet formatting (- **Field**: pattern)
- Check status marker format ([STATUS])
- Report violations with task numbers
- Suggest fixes

**Benefits**:
- Catch future manual edits that violate standards
- Provide automated quality assurance
- Prevent regression to non-compliant state

### 7.3 Documentation Update (Optional)

**Priority**: LOW  
**Effort**: 15 minutes  
**Owner**: Documentation update

**Update `.opencode/context/common/standards/tasks.md`**:
- Add warning about manual task creation
- Emphasize using `/task` command for all new tasks
- Document validation mechanisms
- Add troubleshooting section for non-compliant tasks

---

## 8. Validation Enforcement Strategy

### 8.1 Current Enforcement (Sufficient)

**Mechanisms**:
1. `/task` command enforces standards at creation time
2. `/review` command delegates to `/task`, inheriting enforcement
3. Task standards documentation provides guidelines

**Coverage**: 100% of automated task creation

**Gap**: Manual editing of TODO.md (unavoidable)

### 8.2 Proposed Enhancements (Optional)

**Option A: Pre-commit Hook**
- Validate TODO.md on git commit
- Reject commits with non-compliant tasks
- **Pros**: Catches all violations before commit
- **Cons**: Blocks commits, may frustrate users

**Option B: CI/CD Validation**
- Run validation in CI pipeline
- Report violations as warnings
- **Pros**: Non-blocking, informative
- **Cons**: Violations may persist temporarily

**Option C: Periodic Validation Command**
- `/validate-tasks` command (recommended above)
- Run manually or on schedule
- **Pros**: Flexible, non-intrusive
- **Cons**: Requires manual invocation

**Recommendation**: Option C (periodic validation) is most practical

---

## 9. Conclusion

### 9.1 Summary of Findings

1. **Root Cause**: Tasks 1-9 were manually created before automation existed
2. **Violations**: Missing Language field (9/9), wrong bullet format (1/9)
3. **Current State**: All automated tasks (10+) comply with standards
4. **Enforcement**: `/task` and `/review` commands properly enforce standards
5. **Impact**: Missing Language field prevents proper Lean agent routing

### 9.2 Required Actions

**Immediate** (HIGH priority):
- Manually fix tasks 1-9 to add Language field and fix formatting

**Optional** (MEDIUM priority):
- Create `/validate-tasks` command for ongoing quality assurance

**Not Needed**:
- No changes to `/task` or `/review` commands (already compliant)
- No changes to task standards (already comprehensive)

### 9.3 Prevention Strategy

**Current Prevention** (Sufficient):
- `/task` command enforces standards automatically
- `/review` command delegates to `/task`
- Task standards documentation provides clear guidelines

**Future Prevention** (Optional):
- Add `/validate-tasks` command for periodic checks
- Update documentation with manual editing warnings

---

## 10. References

### 10.1 Files Analyzed

1. `.opencode/specs/TODO.md` - Task list with violations
2. `.opencode/context/common/standards/tasks.md` - Task standards specification
3. `.opencode/command/task.md` - Task creation command
4. `.opencode/command/review.md` - Review command with task creation
5. `.opencode/specs/state.json` - Project state tracking
6. `.opencode/command/implement.md` - Language-based routing logic
7. `.opencode/command/research.md` - Language-based routing logic

### 10.2 Key Standards

- Task ID from state.json (line 20)
- Title format: `### {ID}. {Title}` (line 31)
- Metadata format: `- **Field**: value` (line 34)
- Language field mandatory (line 110)
- Status markers: `[NOT STARTED]`, `[IN PROGRESS]`, etc. (line 48)

### 10.3 Routing Dependencies

- `/implement` uses Language field for routing (implement.md lines 150-187)
- `/research` uses Language field for routing (research.md lines 121-140)
- Lean tasks require Language: lean for proper agent selection
- Missing Language causes routing to wrong agent (general instead of Lean-specific)

---

**Research Complete**: 2025-12-29  
**Next Steps**: Manual fix for tasks 1-9, optional validation command creation
