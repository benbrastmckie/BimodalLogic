# Research Report: Atomic Number Reservation and CLI Command Design Best Practices

**Research ID:** research-001  
**Spec:** 165_make_add_command_single_description_with_immediate_number_increment  
**Date:** 2025-12-24  
**Researcher:** Web Research Specialist

## Executive Summary

This research investigates best practices for atomic number reservation patterns, CLI command design for task creation, and state management consistency. The findings strongly support an "increment-then-use" pattern for task number assignment, minimal-argument CLI design, and immediate state updates with proper error handling.

**Key Recommendations:**
1. Use **fetch-and-add** atomic operation pattern for task number assignment
2. Design CLI with **single required argument** (description) for maximum usability
3. Implement **immediate state updates** with rollback on failure
4. Follow **CLI Guidelines** principles for human-first design

---

## 1. Atomic Number Reservation Patterns

### 1.1 Fundamental Concepts

**Linearizability** is the gold standard for atomic operations in concurrent systems. An operation is linearizable if:
- It appears to occur instantaneously at some point between invocation and response
- All operations appear to execute in a total order consistent with real-time ordering
- The system maintains invariants across all concurrent operations

**Source:** Herlihy & Wing (1990), "Linearizability: A Correctness Condition for Concurrent Objects"

### 1.2 Atomic Operation Patterns

#### Pattern 1: Compare-and-Swap (CAS)
```
function cas(p: pointer to int, old: int, new: int) is
    if *p ≠ old
        return false
    *p ← new
    return true
```

**Characteristics:**
- Requires retry loop on failure
- Subject to ABA problem in some scenarios
- More complex but more flexible

**Use Case:** When you need conditional updates based on expected state

#### Pattern 2: Fetch-and-Add (FAA) ⭐ RECOMMENDED
```
function fetch_and_add(p: pointer to int, a: int) returns int
    done ← false
    while not done
        value ← *p
        done ← cas(p, value, value + a)
    return value + a
```

**Characteristics:**
- Unconditional increment
- Returns the NEW value after increment
- Simpler than CAS for counters
- No ABA problem for simple counters
- Hardware-supported on most modern CPUs (x86 XADD instruction since 486)

**Use Case:** Sequential ID generation, task numbering, atomic counters

**Performance:** On modern servers (2013 data):
- CAS is only 1.15x more expensive than non-cached load on Intel Xeon
- CAS is only 1.35x more expensive on AMD Opteron
- FAA has similar performance characteristics

**Source:** Wikipedia - Fetch-and-add, Compare-and-swap

### 1.3 Pattern Comparison for Task Numbering

| Pattern | Complexity | Race Conditions | Recommended For |
|---------|-----------|-----------------|-----------------|
| Read-Reserve-Increment | High | Possible | Never (unsafe) |
| Increment-Then-Use (FAA) | Low | None | Task numbering ✓ |
| CAS with retry | Medium | None | Conditional updates |

### 1.4 Recommendation for Task Numbering

**Use Fetch-and-Add pattern:**

```rust
// Pseudocode for task creation
fn create_task(description: String) -> Result<Task> {
    // 1. Atomically increment and get new number
    let task_number = fetch_and_add(&NEXT_TASK_NUMBER, 1);
    
    // 2. Create task with reserved number
    let task = Task {
        number: task_number,
        description,
        status: Status::Todo,
        created_at: now(),
    };
    
    // 3. Write to storage
    storage.write(task)?;
    
    // 4. Return task
    Ok(task)
}
```

**Benefits:**
- No race conditions
- Simple implementation
- Number is immediately reserved
- Failure after increment is acceptable (gaps in sequence are fine)
- Hardware-optimized on all modern platforms

---

## 2. CLI Command Design Best Practices

### 2.1 Core Principles from CLI Guidelines (clig.dev)

#### Human-First Design
> "If a command is going to be used primarily by humans, it should be designed for humans first."

**Key Tenets:**
1. **Ease of Discovery** - Help users learn without reading docs
2. **Conversation as the Norm** - CLI is a dialogue, not just commands
3. **Empathy** - Exceed user expectations at every turn
4. **Saying (Just) Enough** - Balance information density

#### The Basics (Must-Follow Rules)

**Arguments vs Flags:**
> "Prefer flags to args. It's a bit more typing, but it makes it much clearer what is going on."

**For Simple Actions:**
> "Multiple arguments are fine for simple actions against multiple files."

**For Different Things:**
> "If you've got two or more arguments for different things, you're probably doing something wrong. The exception is a common, primary action, where the brevity is worth memorizing."

### 2.2 Task Creation CLI Patterns

#### GitHub CLI Pattern (gh)
```bash
# Issue creation - requires title
gh issue create --title "Bug in parser"

# With body
gh issue create --title "Bug" --body "Description here"

# Interactive mode
gh issue create  # Prompts for title and body
```

**Characteristics:**
- Title is required (via flag or prompt)
- Body is optional
- Interactive fallback
- Clear, explicit flags

#### Heroku CLI Pattern
```bash
# App creation - name is optional
heroku apps:create
heroku apps:create myapp

# Clear help text with examples
heroku apps --help
```

**Characteristics:**
- Auto-generates names when not provided
- Single optional argument for common case
- Extensive help with examples

### 2.3 Best Practices for Task Creation

**From CLI Guidelines:**

1. **Prompt for user input** if not provided
   > "If a user doesn't pass an argument or flag, prompt for it."

2. **Never require a prompt**
   > "Always provide a way of passing input with flags or arguments. If stdin is not an interactive terminal, skip prompting and just require those flags/args."

3. **Display output on success**
   > "When a command changes the state of a system, it's especially valuable to explain what has just happened."

4. **Make it easy to see current state**
   > "If your program does a lot of complex state changes... make sure you make this easy to view."

### 2.4 Recommended Design for `/add` Command

**Option A: Single Required Argument (RECOMMENDED)**
```bash
# Simplest form - description is the argument
/add "Fix the parser bug"

# Returns immediately with task number
# Task #42 created: Fix the parser bug
```

**Benefits:**
- Minimal typing
- Clear and obvious
- Follows "common primary action" exception
- Description is the essential piece of information
- Number is auto-assigned immediately

**Option B: Flag-Based (More Explicit)**
```bash
/add --description "Fix the parser bug"

# Or short form
/add -d "Fix the parser bug"
```

**Benefits:**
- More explicit
- Easier to extend with additional flags
- Follows "prefer flags" guideline

**Recommendation:** Use Option A (single argument) because:
1. Task creation is the primary, most common action
2. Description is the only truly required piece of information
3. Brevity is valuable for frequently-used commands
4. Follows the "exception" rule from CLI Guidelines
5. Matches patterns from successful CLIs (e.g., `git commit -m "message"`)

---

## 3. State Management and Consistency Patterns

### 3.1 Idempotent Receiver Pattern

**From Martin Fowler's Patterns of Distributed Systems:**

> "Identify requests from clients uniquely so you can ignore duplicate requests when client retries."

**Key Principles:**
1. Assign unique ID to each client/request
2. Check if request already processed before executing
3. Return cached response if duplicate detected
4. Enables safe retries without side effects

**Application to Task Creation:**
- Task number serves as unique identifier
- Once assigned, number is permanent
- Retry with same number is idempotent
- State file acts as request log

### 3.2 State Update Strategies

#### Strategy 1: Immediate Update (RECOMMENDED)
```
1. Atomically increment counter → get task number
2. Create task object with number
3. Write to state file
4. If write fails → rollback not needed (gap is acceptable)
5. Return success with task number
```

**Benefits:**
- Simple and fast
- Number immediately visible
- Failure is obvious (no partial state)
- Gaps in numbering are acceptable and expected

#### Strategy 2: Deferred Update (NOT RECOMMENDED)
```
1. Read current max number
2. Create task object with next number
3. Write to state file
4. If write succeeds → update counter
5. If write fails → retry with new number
```

**Drawbacks:**
- Race condition between read and write
- Complex error handling
- Potential for duplicate numbers
- Requires locking or CAS

### 3.3 Crash-Only Software Principle

**From "Crash-only software: More than meets the eye" (LWN.net):**

> "If you can avoid needing to do any cleanup after operations, or you can defer that cleanup to the next run, your program can exit immediately on failure or interruption."

**Application:**
- No cleanup needed after task number increment
- State file is append-only or atomic-replace
- Next run can detect and handle incomplete tasks
- Ctrl-C is always safe

### 3.4 Rollback Patterns

**When to Rollback:**
- Never rollback the counter (gaps are fine)
- Rollback file writes on validation failure
- Rollback TODO.md updates if they fail

**How to Handle Failures:**

```rust
fn create_task(description: String) -> Result<Task> {
    // 1. Increment is permanent - no rollback
    let number = atomic_increment();
    
    // 2. Create task
    let task = Task::new(number, description);
    
    // 3. Validate before writing
    task.validate()?;
    
    // 4. Write to state (atomic operation)
    let state_result = write_state_atomic(&task);
    
    // 5. Update TODO.md (can fail independently)
    let todo_result = update_todo(&task);
    
    // 6. Handle partial failures
    match (state_result, todo_result) {
        (Ok(_), Ok(_)) => Ok(task),
        (Ok(_), Err(e)) => {
            warn!("Task created but TODO.md update failed: {}", e);
            Ok(task) // Task is created, TODO can be fixed later
        }
        (Err(e), _) => {
            error!("Failed to create task: {}", e);
            Err(e) // Number is lost but that's acceptable
        }
    }
}
```

### 3.5 Consistency Guarantees

**Linearizability for Task Creation:**
1. Each task creation appears to happen instantaneously
2. Task numbers are strictly increasing
3. No two tasks can have the same number
4. All users see the same ordering of task numbers

**Eventual Consistency for TODO.md:**
- TODO.md updates can lag behind state file
- Sync command can repair inconsistencies
- Users can manually fix TODO.md if needed
- State file is source of truth

---

## 4. Recommendations for `/add` Command Redesign

### 4.1 Command Signature

**Recommended:**
```bash
/add <description>
```

**Examples:**
```bash
/add "Implement atomic task numbering"
/add "Research CLI best practices"
/add "Fix TODO.md sync issues"
```

**Output:**
```
✓ Task #165 created: Implement atomic task numbering
  Status: todo
  Created: 2025-12-24 10:30:00
```

### 4.2 Implementation Pattern

```rust
pub fn add_task(description: String) -> Result<Task> {
    // 1. Validate input
    if description.trim().is_empty() {
        return Err("Description cannot be empty");
    }
    
    // 2. Atomically get next number (fetch-and-add)
    let task_number = state::next_task_number();
    
    // 3. Create task object
    let task = Task {
        number: task_number,
        description: description.trim().to_string(),
        status: Status::Todo,
        created_at: Utc::now(),
        updated_at: Utc::now(),
        tags: vec![],
        dependencies: vec![],
    };
    
    // 4. Write to state file (atomic)
    state::add_task(&task)?;
    
    // 5. Update TODO.md (best effort)
    if let Err(e) = todo::add_task(&task) {
        warn!("TODO.md update failed: {}", e);
        // Continue - state file is source of truth
    }
    
    // 6. Return success
    Ok(task)
}
```

### 4.3 Error Handling

**User-Facing Errors:**
```
✗ Error: Description cannot be empty
  Usage: /add <description>
  
✗ Error: Failed to write task to state file
  The task number #165 has been reserved but the task was not created.
  Please try again or contact support.
  
⚠ Warning: Task #165 created but TODO.md update failed
  You may need to run '/sync' to update TODO.md
```

### 4.4 State Consistency

**Invariants:**
1. Task numbers are unique and monotonically increasing
2. State file is the source of truth
3. TODO.md is eventually consistent with state file
4. Gaps in task numbers are acceptable

**Sync Strategy:**
- Provide `/sync` command to reconcile TODO.md with state
- Run sync automatically on certain operations
- Allow manual sync when needed
- Log sync operations for debugging

### 4.5 Testing Strategy

**Unit Tests:**
- Validate atomic number increment
- Test error handling for empty descriptions
- Verify state file writes
- Check TODO.md updates

**Integration Tests:**
- Concurrent task creation (race conditions)
- Partial failure scenarios
- State recovery after crashes
- TODO.md sync correctness

**Property Tests:**
- Task numbers are unique
- Task numbers are monotonic
- State file is always valid JSON
- No data loss on failures

---

## 5. Additional Considerations

### 5.1 Performance

**Atomic Operations:**
- Fetch-and-add is hardware-optimized
- Minimal overhead compared to file I/O
- No locking required
- Scales well with concurrent access

**File I/O:**
- State file writes are the bottleneck
- Use atomic write (write to temp, rename)
- Consider batching for bulk operations
- Cache in memory for reads

### 5.2 User Experience

**From CLI Guidelines:**

**Responsive is more important than fast:**
> "Print something to the user in <100ms."

**Show progress for long operations:**
> "If your program displays no output for a while, it will look broken."

**Make errors understandable:**
> "Catch errors and rewrite them for humans."

**Application:**
- Show task number immediately
- Confirm creation with clear message
- Explain any warnings or errors
- Suggest next steps

### 5.3 Future Extensions

**Possible Enhancements:**
- `--status` flag to set initial status
- `--tags` flag to add tags on creation
- `--depends-on` flag to set dependencies
- `--priority` flag for prioritization
- Interactive mode for complex tasks

**Maintain Simplicity:**
- Keep default case simple (just description)
- Add flags only when needed
- Don't require flags for common cases
- Provide good defaults

---

## 6. References

### Academic Sources
1. Herlihy, M. P., & Wing, J. M. (1990). "Linearizability: A Correctness Condition for Concurrent Objects." ACM Transactions on Programming Languages and Systems, 12(3), 463-492.

2. Herlihy, M. (1991). "Wait-free synchronization." ACM Trans. Program. Lang. Syst. 13(1): 124-149.

### Industry Standards
3. Command Line Interface Guidelines (clig.dev) - https://clig.dev
   - Comprehensive guide to CLI design
   - Human-first design principles
   - Concrete best practices

4. Martin Fowler - Patterns of Distributed Systems
   - Idempotent Receiver pattern
   - https://martinfowler.com/articles/patterns-of-distributed-systems/

### Technical Documentation
5. Wikipedia - Linearizability
   - https://en.wikipedia.org/wiki/Linearizability
   - Atomic operations and consistency models

6. Wikipedia - Compare-and-swap
   - https://en.wikipedia.org/wiki/Compare-and-swap
   - CAS implementation and use cases

7. Wikipedia - Fetch-and-add
   - https://en.wikipedia.org/wiki/Fetch-and-add
   - FAA implementation and performance

### Real-World Examples
8. GitHub CLI (gh) - https://github.com/cli/cli
   - Modern CLI design patterns
   - Task/issue creation workflows

9. "Crash-only software: More than meets the eye" (LWN.net)
   - Robustness through simplicity
   - State management patterns

---

## 7. Conclusion

The research strongly supports the following design for the `/add` command:

**Command Design:**
- Single required argument: description
- Immediate task number assignment using fetch-and-add
- Clear, immediate feedback to user
- Simple error handling with helpful messages

**Implementation Pattern:**
- Atomic increment for task number (no rollback)
- Immediate state file update
- Best-effort TODO.md update
- Eventual consistency with sync command

**Benefits:**
- No race conditions
- Simple and fast
- Excellent user experience
- Robust error handling
- Follows industry best practices

This design balances simplicity, performance, and correctness while providing an excellent user experience that follows established CLI design principles.
