# Quick Start: Documentation Fixes

**Project**: #080_documentation_review  
**Estimated Time**: 6-8 hours for critical fixes  
**Prerequisites**: Git, text editor, bash shell

---

## Overview

This guide walks you through the first critical fixes for .opencode/ documentation. Complete these 5 tasks to resolve the most urgent issues.

**Total Time**: 6-8 hours  
**Impact**: Resolves 3 critical issues affecting agent functionality

---

## Prerequisites

### 1. Verify Current State

```bash
# Check you're in the right directory
pwd  # Should be /home/benjamin/Projects/ProofChecker

# Verify git status
git status  # Should be clean or have known changes

# Count agent files
ls .opencode/agent/subagents/*.md | wc -l  # Should be 12
ls .opencode/agent/subagents/specialists/*.md | wc -l  # Should be 31
```

### 2. Create Backup

```bash
# Create backup branch
git checkout -b docs-fixes-backup
git checkout main  # or your working branch

# Or create backup directory
cp -r .opencode .opencode.backup
```

---

## Task 1: Clarify Context Directory Structure (1-2 hours)

### Goal
Document the distinction between `/context/` (primary) and `.opencode/context/` (AI-specific subset)

### Steps

#### 1.1: Update .opencode/README.md

Open `.opencode/README.md` and add after line 104:

```markdown
### Context Directory Structure

**Two Context Locations**:
- **`/context/`**: Primary context directory with comprehensive domain knowledge
  - LEAN 4 domain knowledge (syntax, mathlib, concepts)
  - Logic domain knowledge (proof theory, semantics, metalogic)
  - Math domain knowledge (analysis, algebra, topology)
  - Core system patterns and standards
  - Builder templates for meta-system
  
- **`.opencode/context/`**: AI system-specific context subset
  - Repository conventions and schemas
  - Minimal domain-specific files for quick reference
  - References to primary `/context/` for comprehensive knowledge

**Agent Context Loading**:
- Agents load from both locations based on task requirements
- Primary domain knowledge: `/context/`
- System-specific conventions: `.opencode/context/`
```

#### 1.2: Update .opencode/ARCHITECTURE.md

Find the "Context Organization" section (around line 146) and add:

```markdown
## Context Directory Structure

The system uses two context locations:

1. **Primary Context** (`/context/`): Comprehensive domain knowledge
   - Maintained as primary source of truth
   - Contains complete LEAN 4, logic, and math knowledge
   - Shared across all system components

2. **AI-Specific Context** (`.opencode/context/`): System-specific subset
   - Contains repository conventions and schemas
   - May contain copies of frequently-used domain files
   - References primary context for comprehensive knowledge

Agents load context from both locations based on task requirements.
```

#### 1.3: Create .opencode/context/README.md

Create new file `.opencode/context/README.md`:

```markdown
# .opencode/context/ - AI System Context

## Overview

This directory contains AI system-specific context files. For comprehensive domain knowledge, see the primary `/context/` directory.

## Directory Structure

```
.opencode/context/
├── repo/           # Repository conventions and schemas
├── lean4/          # LEAN 4 domain knowledge (copied from /context/lean4/)
├── logic/          # Logic domain knowledge (copied from /context/logic/)
└── project/        # Project-specific context
```

## Context Loading

Agents load context from two locations:

1. **Primary Context** (`/context/`): Comprehensive domain knowledge
2. **AI-Specific Context** (`.opencode/context/`): System conventions and frequently-used files

## Relationship to Primary Context

- **Primary source**: `/context/` contains authoritative domain knowledge
- **AI subset**: `.opencode/context/` contains copies of frequently-used files
- **Updates**: When `/context/` files change, update copies in `.opencode/context/`

## Files in This Directory

### repo/
Repository-specific conventions:
- `documentation-standards.md` - Documentation guidelines
- `project-structure.md` - Project organization
- `state-schema.md` - State file formats
- `status-markers.md` - Status marker specification

### lean4/ (copied from /context/lean4/)
LEAN 4 domain knowledge for quick agent access

### logic/ (copied from /context/logic/)
Logic domain knowledge for quick agent access

### project/
Project-specific context and conventions
```

#### 1.4: Verify Changes

```bash
# Check files were updated
grep -A 5 "Context Directory Structure" .opencode/README.md
grep -A 5 "Context Directory Structure" .opencode/ARCHITECTURE.md
cat .opencode/context/README.md

# Commit changes
git add .opencode/README.md .opencode/ARCHITECTURE.md .opencode/context/README.md
git commit -m "docs: clarify context directory structure"
```

**Checkpoint**: ✅ Context directory structure documented in 3 files

---

## Task 2: Standardize Agent Counts (1 hour)

### Goal
Update all documentation to use consistent agent counts (12 primary, 31 specialists)

### Steps

#### 2.1: Find All References

```bash
# Find files mentioning agent counts
grep -r "7 Primary" .opencode/
grep -r "16 Specialist" .opencode/
grep -r "Primary Agents" .opencode/
```

#### 2.2: Update .opencode/README.md

Open `.opencode/README.md` and update:

**Line 12** (in "Primary Agents" section):
```markdown
### Primary Agents (12)
```

**Line 21** (in "Specialist Subagents" section):
```markdown
### Specialist Subagents (31)
```

#### 2.3: Update .opencode/ARCHITECTURE.md

Find and update all agent count references:
- "7 Primary Agents" → "12 Primary Agents"
- "16 Specialist" → "31 Specialist"

#### 2.4: Update .opencode/SYSTEM_SUMMARY.md

Find and update all agent count references:
- "7 Primary Agents" → "12 Primary Agents"
- "16 Specialist" → "31 Specialist"

#### 2.5: Verify Counts

```bash
# Verify actual counts
ls .opencode/agent/subagents/*.md | wc -l  # Should be 12
ls .opencode/agent/subagents/specialists/*.md | wc -l  # Should be 31

# Verify no old counts remain
grep -r "7 Primary" .opencode/  # Should return nothing
grep -r "16 Specialist" .opencode/  # Should return nothing

# Commit changes
git add .opencode/README.md .opencode/ARCHITECTURE.md .opencode/SYSTEM_SUMMARY.md
git commit -m "docs: standardize agent counts (12 primary, 31 specialists)"
```

**Checkpoint**: ✅ Agent counts consistent across all files

---

## Task 3: Fix LEAN 4 Context References (2-3 hours)

### Goal
Update all references to use correct paths for LEAN 4 context files

### Steps

#### 3.1: Find All LEAN 4 References

```bash
# Find files with LEAN 4 context references
grep -r "lean4/domain/" .opencode/ | cut -d: -f1 | sort -u
grep -r "lean4/standards/" .opencode/ | cut -d: -f1 | sort -u
grep -r "lean4/patterns/" .opencode/ | cut -d: -f1 | sort -u
grep -r "lean4/tools/" .opencode/ | cut -d: -f1 | sort -u
```

#### 3.2: Update References Strategy

**Decision**: Update references to point to `/context/lean4/` (primary location)

For each file found in 3.1, update references:
- `lean4/domain/` → `/context/lean4/domain/`
- `lean4/standards/` → `/context/lean4/standards/`
- `lean4/patterns/` → `/context/lean4/patterns/`
- `lean4/tools/` → `/context/lean4/tools/`

#### 3.3: Automated Update (Optional)

```bash
# Create update script
cat > /tmp/update-lean4-refs.sh << 'EOF'
#!/bin/bash
# Update LEAN 4 context references

find .opencode -name "*.md" -type f -exec sed -i \
  -e 's|lean4/domain/|/context/lean4/domain/|g' \
  -e 's|lean4/standards/|/context/lean4/standards/|g' \
  -e 's|lean4/patterns/|/context/lean4/patterns/|g' \
  -e 's|lean4/tools/|/context/lean4/tools/|g' \
  {} \;

echo "Updated LEAN 4 context references"
EOF

chmod +x /tmp/update-lean4-refs.sh
/tmp/update-lean4-refs.sh
```

#### 3.4: Verify Updates

```bash
# Check references were updated
grep -r "lean4/domain/" .opencode/ | grep -v "/context/lean4/domain/"  # Should be empty
grep -r "lean4/standards/" .opencode/ | grep -v "/context/lean4/standards/"  # Should be empty

# Verify files exist at referenced locations
ls /context/lean4/domain/
ls /context/lean4/standards/
ls /context/lean4/patterns/
ls /context/lean4/tools/

# Commit changes
git add .opencode/
git commit -m "docs: fix LEAN 4 context references to point to /context/"
```

**Checkpoint**: ✅ All LEAN 4 context references point to correct locations

---

## Task 4: Fix Broken Internal Links (1-2 hours)

### Goal
Update all broken internal links to correct paths

### Steps

#### 4.1: Find Broken Links

```bash
# Find references to non-existent paths
grep -r "context/core/" .opencode/ | grep -v "/context/core/"
grep -r "context/builder-templates/" .opencode/ | grep -v "/context/builder-templates/"
```

#### 4.2: Update Broken Links

For each broken link found:
- `.opencode/context/core/` → `/context/core/`
- `.opencode/context/builder-templates/` → `/context/builder-templates/`

#### 4.3: Automated Update (Optional)

```bash
# Create update script
cat > /tmp/fix-broken-links.sh << 'EOF'
#!/bin/bash
# Fix broken internal links

find .opencode -name "*.md" -type f -exec sed -i \
  -e 's|\.opencode/context/core/|/context/core/|g' \
  -e 's|context/core/|/context/core/|g' \
  -e 's|\.opencode/context/builder-templates/|/context/builder-templates/|g' \
  -e 's|context/builder-templates/|/context/builder-templates/|g' \
  {} \;

echo "Fixed broken internal links"
EOF

chmod +x /tmp/fix-broken-links.sh
/tmp/fix-broken-links.sh
```

#### 4.4: Verify Links

```bash
# Verify files exist at referenced locations
ls /context/core/
ls /context/builder-templates/

# Check no broken references remain
grep -r "\.opencode/context/core/" .opencode/  # Should be empty
grep -r "\.opencode/context/builder-templates/" .opencode/  # Should be empty

# Commit changes
git add .opencode/
git commit -m "docs: fix broken internal links to context/core/ and builder-templates/"
```

**Checkpoint**: ✅ All internal links functional

---

## Task 5: Add README Cross-References (30 minutes)

### Goal
Add cross-references between root README.md and .opencode/README.md

### Steps

#### 5.1: Update Root README.md

Open `/home/benjamin/Projects/ProofChecker/README.md` and add after the "Documentation" section (around line 280):

```markdown
### AI System Documentation

For AI system usage, agent workflows, and command interface, see [.opencode/README.md](.opencode/README.md).
```

#### 5.2: Update .opencode/README.md

Open `.opencode/README.md` and add at the top after line 5:

```markdown
> **Note**: For project overview, theoretical foundations, and Logos formal language, see the [root README.md](../README.md).
```

#### 5.3: Verify Cross-References

```bash
# Check cross-references added
grep -A 2 "AI System Documentation" README.md
grep "root README.md" .opencode/README.md

# Commit changes
git add README.md .opencode/README.md
git commit -m "docs: add cross-references between root and .opencode READMEs"
```

**Checkpoint**: ✅ Cross-references added between README files

---

## Verification

### Final Checks

```bash
# 1. Context directory structure documented
grep -A 5 "Context Directory Structure" .opencode/README.md
grep -A 5 "Context Directory Structure" .opencode/ARCHITECTURE.md
cat .opencode/context/README.md

# 2. Agent counts standardized
grep "Primary Agents" .opencode/README.md  # Should show (12)
grep "Specialist" .opencode/README.md  # Should show (31)

# 3. LEAN 4 references fixed
grep -r "lean4/domain/" .opencode/ | grep -v "/context/lean4/domain/"  # Should be empty

# 4. Broken links fixed
grep -r "\.opencode/context/core/" .opencode/  # Should be empty

# 5. Cross-references added
grep "root README.md" .opencode/README.md
grep "AI System Documentation" README.md
```

### Success Criteria

- [ ] Context directory structure documented in 3 files
- [ ] Agent counts consistent (12 primary, 31 specialists)
- [ ] All LEAN 4 context references point to `/context/`
- [ ] All internal links functional
- [ ] Cross-references between READMEs added

---

## Next Steps

After completing these critical fixes:

1. **Phase 2**: Copy LEAN 4 domain knowledge files (2-4 hours)
   - See PLAN.md Phase 2 for details
   
2. **Phase 3**: Consolidation & cleanup (4-6 hours)
   - Reduce SYSTEM_SUMMARY.md redundancy
   - Consolidate agent lists
   
3. **Phase 4**: Enhancement (3-5 hours)
   - Add examples and templates
   - Add verification commands
   
4. **Phase 5**: Polish (2-4 hours)
   - Advanced examples
   - Error handling guide
   - Automated validation

---

## Troubleshooting

### Issue: Can't find files in /context/

**Solution**: Verify you're in the project root directory:
```bash
pwd  # Should be /home/benjamin/Projects/ProofChecker
ls context/  # Should show core/, lean4/, logic/, etc.
```

### Issue: Git conflicts

**Solution**: Stash changes and reapply:
```bash
git stash
git pull
git stash pop
```

### Issue: Sed command not working

**Solution**: Use manual find-and-replace in your text editor instead of automated scripts

### Issue: Verification commands fail

**Solution**: Check file paths are correct:
```bash
ls .opencode/agent/subagents/  # Should show 12 .md files
ls .opencode/agent/subagents/specialists/  # Should show 31 .md files
```

---

## Support

For questions or issues:
1. Review [PLAN.md](PLAN.md) for detailed implementation steps
2. Check [CHECKLIST.md](CHECKLIST.md) for task tracking
3. Consult research report: `.opencode/specs/080_documentation_review/reports/research-001.md`

---

**Status**: Ready to execute  
**Estimated Time**: 6-8 hours  
**Impact**: Resolves 3 critical documentation issues
