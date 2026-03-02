---
description: Create a GitLab merge request for the current branch
allowed-tools: Bash(git:*), Bash(glab:*)
argument-hint: [--draft] [--assignee USER] [--label LABEL]
---

# /merge Command

Create a GitLab merge request for the current branch. Validates that you are not on `main`, pushes the branch to origin with upstream tracking, creates the MR via `glab mr create`, and displays the MR URL.

## Syntax

```
/merge [options]
```

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--draft` | Create merge request as a draft | false |
| `--assignee USER` | Assign MR to a user by username | (none) |
| `--label LABEL` | Add a label to the MR | (none) |

## Prerequisites

- Must be on a branch other than `main`
- Must have `glab` CLI installed and authenticated (`glab auth status`)
- Must have a GitLab remote configured as `origin`

## Execution

**EXECUTE NOW**: Follow these steps in sequence. Do not just describe what should happen - actually perform each step.

### STEP 1: Parse Arguments

**EXECUTE NOW**: Parse the command arguments to extract flags.

```
# Default values
draft=false
assignee=""
label=""

# Parse flags from $ARGUMENTS
```

Track:
- `--draft` -> set draft=true
- `--assignee USER` -> set assignee=USER
- `--label LABEL` -> set label=LABEL

**On success**: **IMMEDIATELY CONTINUE** to STEP 2.

---

### STEP 2: Validate Branch

**EXECUTE NOW**: Check that the current branch is not `main`.

```bash
current_branch=$(git branch --show-current)
```

**If branch is `main`**:
```
Error: Cannot create merge request from 'main' branch
=====================================================

You are currently on the 'main' branch.
Merge requests must be created from a feature branch.

Recovery:
1. Create a new branch: git checkout -b feature-branch
2. Make your changes and commit them
3. Run /merge again
```
**STOP** - execution cannot proceed from main branch.

**If branch is not `main`**: **IMMEDIATELY CONTINUE** to STEP 3.

---

### STEP 3: Push to Origin

**EXECUTE NOW**: Push the current branch to origin with upstream tracking.

```bash
git push -u origin HEAD
```

Capture the output and exit code.

**If push fails**:
```
Error: Failed to push branch to origin
======================================

{git error output}

Recovery:
- Check your git remote configuration: git remote -v
- Ensure you have write access to the repository
- Resolve any conflicts or upstream issues
- Try pushing manually: git push -u origin HEAD
```
**STOP** - execution cannot proceed without successful push.

**If push succeeds**: **IMMEDIATELY CONTINUE** to STEP 4.

---

### STEP 4: Create Merge Request

**EXECUTE NOW**: Create the merge request via glab CLI.

Build the glab command:
```bash
glab_cmd="glab mr create --fill --yes --target-branch main"

# Add optional flags
if [ "$draft" = true ]; then
  glab_cmd="$glab_cmd --draft"
fi
if [ -n "$assignee" ]; then
  glab_cmd="$glab_cmd --assignee $assignee"
fi
if [ -n "$label" ]; then
  glab_cmd="$glab_cmd --label $label"
fi

# Execute
$glab_cmd
```

Capture the output to extract the MR URL.

**If MR creation fails**:
```
Error: Failed to create merge request
=====================================

{glab error output}

Recovery:
- Check authentication: glab auth status
- Check repository access: glab repo view
- If MR already exists, glab will show the existing MR URL
- Try creating manually: glab mr create --fill
```
**STOP** - MR creation failed.

**If MR creation succeeds**: Extract the MR URL from the output and **IMMEDIATELY CONTINUE** to STEP 5.

---

### STEP 5: Report Results

**EXECUTE NOW**: Display the merge request information.

```
Merge Request Created
=====================

Branch: {current_branch}
Target: main

MR URL: {mr_url}
```

**STOP** - execution complete.

---

## Examples

### Basic Merge Request

```bash
# Create MR from current branch
/merge
```

### Draft Merge Request

```bash
# Create as draft (work in progress)
/merge --draft
```

### Assigned Merge Request

```bash
# Create and assign to a user
/merge --assignee johndoe
```

### Labeled Merge Request

```bash
# Create with a label
/merge --label "feature"
```

### Combined Options

```bash
# Create draft MR with assignee and label
/merge --draft --assignee johndoe --label "wip"
```

## Output

### Success

```
Merge Request Created
=====================

Branch: feature/add-new-modal
Target: main

MR URL: https://gitlab.com/user/project/-/merge_requests/42
```

### Error: On Main Branch

```
Error: Cannot create merge request from 'main' branch
=====================================================

You are currently on the 'main' branch.
Merge requests must be created from a feature branch.

Recovery:
1. Create a new branch: git checkout -b feature-branch
2. Make your changes and commit them
3. Run /merge again
```

### Error: Push Failed

```
Error: Failed to push branch to origin
======================================

error: failed to push some refs to 'origin'
hint: Updates were rejected because the remote contains work...

Recovery:
- Check your git remote configuration: git remote -v
- Ensure you have write access to the repository
- Resolve any conflicts or upstream issues
- Try pushing manually: git push -u origin HEAD
```

### Error: MR Creation Failed

```
Error: Failed to create merge request
=====================================

POST https://gitlab.com/api/v4/projects/.../merge_requests: 401 Unauthorized

Recovery:
- Check authentication: glab auth status
- Check repository access: glab repo view
- If MR already exists, glab will show the existing MR URL
- Try creating manually: glab mr create --fill
```

## Troubleshooting

### Not authenticated with GitLab

Run `glab auth login` to authenticate with your GitLab instance.

### Remote 'origin' not found

Configure the remote:
```bash
git remote add origin git@gitlab.com:user/project.git
```

### MR already exists for this branch

If a merge request already exists for the current branch, `glab` will display the existing MR URL. This is not an error.

### Push rejected due to conflicts

Resolve conflicts locally first:
```bash
git fetch origin main
git rebase origin/main
# or
git merge origin/main
```
Then run `/merge` again.

## Related Commands

- `/task` - Create a task for the work
- `/implement` - Implement the task
