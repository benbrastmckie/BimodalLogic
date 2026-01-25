#!/usr/bin/env bash
# System Validation Script for ProofChecker .opencode System
# Validates core components per DESIGN.md specification

set -e

echo "=== ProofChecker .opencode System Validation ==="
echo ""

ERRORS=0
WARNINGS=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((ERRORS++))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

info() {
    echo "[INFO] $1"
}

# Test 1: Verify no common/ references exist
echo "Test 1: Verifying no common/ directory references..."
if grep -r "common/" .opencode/agent/ .opencode/command/ .opencode/context/ 2>/dev/null | grep -v ".git" | grep -v "binary"; then
    fail "Found common/ references in system files"
else
    pass "No common/ references found"
fi
echo ""

# Test 2: Verify core directory structure
echo "Test 2: Verifying core directory structure..."
REQUIRED_DIRS=(
    ".opencode/context/core/standards"
    ".opencode/context/core/system"
    ".opencode/context/core/templates"
    ".opencode/context/core/workflows"
    ".opencode/context/project/lean4"
    ".opencode/context/project/logic"
    ".opencode/context/project/repo"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        pass "Directory exists: $dir"
    else
        fail "Directory missing: $dir"
    fi
done
echo ""

# Test 3: Verify key files exist
echo "Test 3: Verifying key system files..."
REQUIRED_FILES=(
    ".opencode/agent/orchestrator.md"
    ".opencode/agent/subagents/planner.md"
    ".opencode/agent/subagents/lean-planner.md"
    ".opencode/agent/subagents/researcher.md"
    ".opencode/agent/subagents/lean-research-agent.md"
    ".opencode/agent/subagents/implementer.md"
    ".opencode/agent/subagents/lean-implementation-agent.md"
    ".opencode/agent/subagents/status-sync-manager.md"
    ".opencode/agent/subagents/git-workflow-manager.md"
    ".opencode/command/research.md"
    ".opencode/command/plan.md"
    ".opencode/command/revise.md"
    ".opencode/command/implement.md"
    ".opencode/context/core/system/routing-logic.md"
    ".opencode/context/core/system/validation-rules.md"
    ".opencode/context/core/system/artifact-management.md"
    ".opencode/context/core/system/state-management.md"
    ".opencode/context/index.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "File exists: $file"
    else
        fail "File missing: $file"
    fi
done
echo ""

# Test 4: Verify language-based routing in commands
echo "Test 4: Verifying language-based routing configuration..."

check_routing() {
    local file=$1
    local command_name=$2
    
    if grep -q "language_based: true" "$file"; then
        if grep -q "lean:" "$file" && grep -q "default:" "$file"; then
            pass "$command_name has language-based routing with lean and default agents"
        else
            fail "$command_name has language_based:true but missing routing table"
        fi
    else
        warn "$command_name does not use language-based routing"
    fi
}

check_routing ".opencode/command/research.md" "/research"
check_routing ".opencode/command/plan.md" "/plan"
check_routing ".opencode/command/revise.md" "/revise"
check_routing ".opencode/command/implement.md" "/implement"
echo ""

# Test 5: Verify orchestrator has 5-stage workflow
echo "Test 5: Verifying orchestrator 5-stage workflow..."
ORCHESTRATOR=".opencode/agent/orchestrator.md"

if grep -q "PreflightValidation" "$ORCHESTRATOR"; then
    pass "Orchestrator has Stage 1 (PreflightValidation)"
else
    fail "Orchestrator missing Stage 1 (PreflightValidation)"
fi

if grep -q "DetermineRouting" "$ORCHESTRATOR"; then
    pass "Orchestrator has Stage 2 (DetermineRouting)"
else
    fail "Orchestrator missing Stage 2 (DetermineRouting)"
fi

if grep -q "RegisterAndDelegate" "$ORCHESTRATOR"; then
    pass "Orchestrator has Stage 3 (RegisterAndDelegate)"
else
    fail "Orchestrator missing Stage 3 (RegisterAndDelegate)"
fi

if grep -q "ValidateReturn" "$ORCHESTRATOR"; then
    pass "Orchestrator has Stage 4 (ValidateReturn)"
else
    fail "Orchestrator missing Stage 4 (ValidateReturn)"
fi

if grep -q "PostflightCleanup" "$ORCHESTRATOR"; then
    pass "Orchestrator has Stage 5 (PostflightCleanup)"
else
    fail "Orchestrator missing Stage 5 (PostflightCleanup)"
fi
echo ""

# Test 6: Verify subagent YAML frontmatter
echo "Test 6: Verifying subagent YAML frontmatter..."
SUBAGENTS=(
    ".opencode/agent/subagents/planner.md"
    ".opencode/agent/subagents/lean-planner.md"
    ".opencode/agent/subagents/researcher.md"
    ".opencode/agent/subagents/lean-research-agent.md"
)

for agent in "${SUBAGENTS[@]}"; do
    if head -n 50 "$agent" | grep -q "^name:" && \
       head -n 50 "$agent" | grep -q "^version:" && \
       head -n 50 "$agent" | grep -q "^mode: subagent"; then
        pass "$(basename $agent) has valid YAML frontmatter"
    else
        fail "$(basename $agent) has invalid or missing YAML frontmatter"
    fi
done
echo ""

# Test 7: Verify context_loading uses core/ not common/
echo "Test 7: Verifying context_loading paths use core/..."
if grep -r "context_loading:" .opencode/agent/subagents/*.md | grep "common/" > /dev/null 2>&1; then
    fail "Found common/ references in context_loading sections"
else
    pass "All context_loading paths use core/ directory"
fi
echo ""

# Test 8: Verify routing-logic.md has all 4 language-based commands
echo "Test 8: Verifying routing-logic.md documents all language-based commands..."
ROUTING_FILE=".opencode/context/core/system/routing-logic.md"

if grep -q "/research.*lean.*lean-research-agent" "$ROUTING_FILE" && \
   grep -q "/plan.*lean.*lean-planner" "$ROUTING_FILE" && \
   grep -q "/revise.*lean.*lean-planner" "$ROUTING_FILE" && \
   grep -q "/implement.*lean.*lean-implementation-agent" "$ROUTING_FILE"; then
    pass "routing-logic.md documents all 4 language-based commands"
else
    fail "routing-logic.md missing language-based routing documentation"
fi
echo ""

# Summary
echo "=== Validation Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ System validation passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ System validation failed with $ERRORS errors${NC}"
    exit 1
fi
