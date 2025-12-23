#!/usr/bin/env bash
# validate-docs.sh - Automated documentation quality validation
# 
# This script validates the .opencode/ documentation system for:
# - Structural integrity (directories, files, counts)
# - Reference consistency (no broken links, correct paths)
# - Content quality (no TODOs, proper formatting)
# - System health (agent/command/context alignment)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Helper functions
error() {
    echo -e "${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check() {
    CHECKS=$((CHECKS + 1))
}

# Change to project root
cd "$(dirname "$0")/../.."

echo "========================================="
echo "  Documentation Validation Report"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="
echo ""

# ============================================
# Section 1: Directory Structure
# ============================================
echo "=== 1. Directory Structure ==="
check

# Check .opencode/context exists
if [ -d ".opencode/context" ]; then
    success ".opencode/context exists"
else
    error ".opencode/context missing"
fi

# Check old /context doesn't exist
if [ -d "context" ]; then
    warning "Old /context directory still exists - should be deleted after migration"
else
    success "Old /context directory removed"
fi

# Check required subdirectories
for dir in ".opencode/agent" ".opencode/agent/subagents" ".opencode/command" ".opencode/context" ".opencode/specs"; do
    check
    if [ -d "$dir" ]; then
        success "$dir exists"
    else
        error "$dir missing"
    fi
done

echo ""

# ============================================
# Section 2: Agent System
# ============================================
echo "=== 2. Agent System ==="
check

# Count primary agents
PRIMARY_COUNT=$(find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l)
if [ "$PRIMARY_COUNT" -eq 12 ] || [ "$PRIMARY_COUNT" -eq 5 ]; then
    success "Primary agents: $PRIMARY_COUNT"
else
    warning "Primary agents: $PRIMARY_COUNT (expected: 12 or 5)"
fi

# Count specialist subagents
if [ -d ".opencode/agent/subagents/specialists" ]; then
    SPECIALIST_COUNT=$(find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f 2>/dev/null | grep -v README | wc -l)
    if [ "$SPECIALIST_COUNT" -eq 32 ] || [ "$SPECIALIST_COUNT" -eq 0 ]; then
        success "Specialist subagents: $SPECIALIST_COUNT"
    else
        warning "Specialist subagents: $SPECIALIST_COUNT (expected: 32)"
    fi
else
    info "Specialist directory not yet created"
fi

# Verify agent files are not empty
check
EMPTY_AGENTS=$(find .opencode/agent -name "*.md" -type f -empty 2>/dev/null | wc -l)
if [ "$EMPTY_AGENTS" -eq 0 ]; then
    success "No empty agent files"
else
    error "Found $EMPTY_AGENTS empty agent files"
fi

echo ""

# ============================================
# Section 3: Command System
# ============================================
echo "=== 3. Command System ==="
check

# Count commands
COMMAND_COUNT=$(find .opencode/command -maxdepth 1 -name "*.md" -type f 2>/dev/null | grep -v README | wc -l)
if [ "$COMMAND_COUNT" -eq 12 ]; then
    success "Commands: $COMMAND_COUNT (expected: 12)"
else
    warning "Commands: $COMMAND_COUNT (expected: 12)"
fi

# Verify command files are not empty
check
EMPTY_COMMANDS=$(find .opencode/command -name "*.md" -type f -empty 2>/dev/null | wc -l)
if [ "$EMPTY_COMMANDS" -eq 0 ]; then
    success "No empty command files"
else
    error "Found $EMPTY_COMMANDS empty command files"
fi

# Check command README exists
check
if [ -f ".opencode/command/README.md" ]; then
    success "Command README exists"
else
    error "Command README missing"
fi

echo ""

# ============================================
# Section 4: Context Structure
# ============================================
echo "=== 4. Context Structure ==="
check

# Count context directories
CONTEXT_DIRS=$(find .opencode/context -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)
info "Context directories: $CONTEXT_DIRS"

# Check LEAN 4 subdirectories
if [ -d ".opencode/context/lean4" ]; then
    LEAN4_SUBDIRS=$(find .opencode/context/lean4 -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)
    if [ "$LEAN4_SUBDIRS" -ge 6 ]; then
        success "LEAN 4 subdirectories: $LEAN4_SUBDIRS (expected: ≥6)"
    else
        warning "LEAN 4 subdirectories: $LEAN4_SUBDIRS (expected: ≥6)"
    fi
fi

# Check logic subdirectories
if [ -d ".opencode/context/logic" ]; then
    LOGIC_SUBDIRS=$(find .opencode/context/logic -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)
    if [ "$LOGIC_SUBDIRS" -ge 5 ]; then
        success "Logic subdirectories: $LOGIC_SUBDIRS (expected: ≥5)"
    else
        warning "Logic subdirectories: $LOGIC_SUBDIRS (expected: ≥5)"
    fi
fi

# Verify context files are not empty
check
EMPTY_CONTEXT=$(find .opencode/context -name "*.md" -type f -empty 2>/dev/null | wc -l)
if [ "$EMPTY_CONTEXT" -eq 0 ]; then
    success "No empty context files"
else
    error "Found $EMPTY_CONTEXT empty context files"
fi

echo ""

# ============================================
# Section 5: Reference Consistency
# ============================================
echo "=== 5. Reference Consistency ==="
check

# Check for references to old /context/ path
OLD_CONTEXT_REFS=$(grep -r "](/context/" .opencode --include="*.md" 2>/dev/null | wc -l)
if [ "$OLD_CONTEXT_REFS" -eq 0 ]; then
    success "No references to old /context/ path in links"
else
    error "Found $OLD_CONTEXT_REFS references to old /context/ path in links"
fi

# Check for references to old context/ path (without leading /)
check
OLD_CONTEXT_REFS2=$(grep -r "\"context/" .opencode --include="*.md" 2>/dev/null | wc -l)
if [ "$OLD_CONTEXT_REFS2" -eq 0 ]; then
    success "No quoted context/ references"
else
    warning "Found $OLD_CONTEXT_REFS2 quoted context/ references (may need review)"
fi

echo ""

# ============================================
# Section 6: Content Quality
# ============================================
echo "=== 6. Content Quality ==="
check

# Check for TODO markers in documentation
TODO_COUNT=$(grep -r "TODO\|FIXME\|XXX" .opencode --include="*.md" 2>/dev/null | grep -v "TODO.md" | grep -v "validate-docs.sh" | wc -l)
if [ "$TODO_COUNT" -eq 0 ]; then
    success "No TODO/FIXME/XXX markers in documentation"
else
    warning "Found $TODO_COUNT TODO/FIXME/XXX markers in documentation"
fi

# Check for placeholder text
check
PLACEHOLDER_COUNT=$(grep -ri "lorem ipsum\|placeholder\|TBD\|coming soon" .opencode --include="*.md" 2>/dev/null | wc -l)
if [ "$PLACEHOLDER_COUNT" -eq 0 ]; then
    success "No placeholder text found"
else
    warning "Found $PLACEHOLDER_COUNT instances of placeholder text"
fi

echo ""

# ============================================
# Section 7: Agent Count Consistency
# ============================================
echo "=== 7. Agent Count Consistency ==="
check

# Check for incorrect agent counts in documentation (exclude specs directory - historical records)
INCORRECT_COUNTS=$(grep -r "7 Primary Agents\|16 Specialist" .opencode --include="*.md" --exclude-dir=specs 2>/dev/null | wc -l)
if [ "$INCORRECT_COUNTS" -eq 0 ]; then
    success "No outdated agent counts found"
else
    error "Found $INCORRECT_COUNTS references to outdated agent counts (7 primary, 16 specialists)"
fi

echo ""

# ============================================
# Section 8: File Integrity
# ============================================
echo "=== 8. File Integrity ==="
check

# Check for very small files (likely incomplete)
SMALL_FILES=$(find .opencode -name "*.md" -type f -size -100c 2>/dev/null | wc -l)
if [ "$SMALL_FILES" -eq 0 ]; then
    success "No suspiciously small files"
else
    warning "Found $SMALL_FILES files smaller than 100 bytes (may be incomplete)"
fi

# Check for duplicate filenames
check
DUPLICATES=$(find .opencode -name "*.md" -type f 2>/dev/null | xargs -n1 basename 2>/dev/null | sort | uniq -d | wc -l)
if [ "$DUPLICATES" -eq 0 ]; then
    success "No duplicate filenames found"
else
    info "Found $DUPLICATES duplicate filenames (may be intentional)"
fi

echo ""

# ============================================
# Section 9: Specs Directory
# ============================================
echo "=== 9. Specs Directory ==="
check

# Check TODO.md exists
if [ -f ".opencode/specs/TODO.md" ]; then
    success "TODO.md exists"
    TODO_TASKS=$(grep -c "^- \[ \]" .opencode/specs/TODO.md 2>/dev/null || echo 0)
    info "  Open tasks: $TODO_TASKS"
else
    error "TODO.md missing"
fi

# Check state.json exists
check
if [ -f ".opencode/specs/state.json" ]; then
    success "state.json exists"
    
    # Validate JSON if jq is available
    if command -v jq &> /dev/null; then
        if jq empty .opencode/specs/state.json 2>/dev/null; then
            success "  state.json is valid JSON"
        else
            error "  state.json is invalid JSON"
        fi
    fi
else
    warning "state.json missing"
fi

# Count project directories
check
PROJECT_COUNT=$(find .opencode/specs -maxdepth 1 -type d -name "[0-9]*" 2>/dev/null | wc -l)
info "Project directories: $PROJECT_COUNT"

echo ""

# ============================================
# Section 10: Cross-References
# ============================================
echo "=== 10. Cross-References ==="
check

# Check for cross-references between root README and .opencode/README
if [ -f "README.md" ] && grep -q ".opencode/README.md" README.md 2>/dev/null; then
    success "Root README references .opencode/README.md"
else
    warning "Root README doesn't reference .opencode/README.md"
fi

check
if [ -f ".opencode/README.md" ] && grep -q "README.md" .opencode/README.md 2>/dev/null; then
    success ".opencode/README.md references root README"
else
    warning ".opencode/README.md doesn't reference root README"
fi

# Check for references to agent catalog
check
if [ -f ".opencode/README.md" ] && grep -q "agent/README.md" .opencode/README.md 2>/dev/null; then
    success ".opencode/README.md references agent catalog"
else
    warning ".opencode/README.md doesn't reference agent catalog"
fi

echo ""

# ============================================
# Summary
# ============================================
echo "========================================="
echo "  Validation Summary"
echo "========================================="
echo ""
echo "Total checks: $CHECKS"
echo -e "${GREEN}Passed: $((CHECKS - ERRORS - WARNINGS))${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Errors: $ERRORS${NC}"
echo ""

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✓ All validation checks passed!${NC}"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation passed with warnings${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed with $ERRORS errors${NC}"
    exit 1
fi
